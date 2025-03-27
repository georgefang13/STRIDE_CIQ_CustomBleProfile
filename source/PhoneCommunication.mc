//
// Copyright 2024 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;

// Just for debug prints
class CommListener extends Communications.ConnectionListener {
    function initialize() {
        Communications.ConnectionListener.initialize();
    }

    function onComplete() {
        System.println("CommListener: Transmit Complete");
    }

    function onError() {
        System.println("CommListener: Transmit Failed");
    }
}

class PhoneCommunication {
    //  private var _deviceDataModel as DeviceDataModel?;
    private var _deviceView as DeviceView?;
    private var _isSimulator = false;
    private var msgFromPhoneMethod;

    function initialize() {
        // The Communications class is used to connection to a smartphone. In the simulator,
        // dialogs will pop up with "Please connect an Android device to ADB" if an Android
        // device is not attached. Set _isSimulator to false to re-enable Communications functionality
        // when running in the CIQ simulator. The below System.Stats values appear to be hard
        // coded in the simulator. This is a hack but it seems to work for now.
        var systemStats = System.getSystemStats();
        _isSimulator = (systemStats != null && 50.0 == systemStats.battery &&
                        5.0 == systemStats.batteryInDays && false == systemStats.charging &&
                        systemStats.solarIntensity == null);
        // _isSimulator = false;  // Uncomment to enable phone Communications in simulator

        msgFromPhoneMethod = self.method(:handleMessageFromPhone);
        if(Communications has :registerForPhoneAppMessages) {
            if (!_isSimulator) {
                Communications.registerForPhoneAppMessages(msgFromPhoneMethod);
            }
        }
    }

    // Called when a message is received from the phone
    function handleMessageFromPhone(msg) {
        System.println("PhoneComm::handleMessageFromPhone");
        // Example message:
        //    "LED4:set:on" - turn on LED4
        //    "LED4:set:off" - turn off LED4
        if (msg != null && msg.data instanceof Toybox.Lang.String) {
            System.println("PhoneComm::handleMessageFromPhone( " + msg.data + " ) called");
        }
        // TODO: Filter out old (stale) messages. Since the phone may queue messages for delivery 
        // while it is waiting to be connected to the watch, the messages could become stale and 
        // might should be ignored. Adding a timestamp or a sequence number to the message might help.        
    }

    function setDeviceView(dv as DeviceView) as Void {
        System.println("PhoneCommunication::setDeviceView");
        _deviceView = dv;
    }

    // Send a message to the application running on the phone
    function transmitMessageToPhone(message as Toybox.Lang.String) {
        System.println("PhoneCommunication::transmitMessageToPhone(" + message + ")");
        var listener = new CommListener();
        try {
            if (!_isSimulator) {
                Communications.transmit(message, null, listener);
            }
        }
        catch (ex) {
            System.println("PhoneCommunication::transmitMessageToPhone() exception: " + ex.getErrorMessage());
        }
    }

}
