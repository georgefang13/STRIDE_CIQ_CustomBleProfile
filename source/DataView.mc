// filepath: c:\STRIDE\ciq_projects\STRIDE_CIQ_CustomBleProfile\source\DataView.mc
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class DataView extends WatchUi.View {
    private var _deviceDataModel as DeviceDataModel;

    //! Constructor
    //! @param deviceDataModel The model containing the device data
    public function initialize(deviceDataModel as DeviceDataModel) {
        View.initialize();
        
        _deviceDataModel = deviceDataModel;
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
        System.println("onUpdate()");

        // Clear the screen first
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Check connection and profile
        var isConnected = _deviceDataModel.isConnected();
        var profile = _deviceDataModel.getActiveProfile();
        System.println("isConnected: " + isConnected);
        System.println("profile: " + profile);
        
        if (isConnected && (profile != null)) {
            System.println("Data: " + profile.getCustomDataByteArray());
            drawCustomData(dc, profile.getCustomDataByteArray());
        }
        else{
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();

            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();

            var strideY = screenHeight * 0.35;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "DATA VIEW", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    private function drawCustomData(dc as Dc, customData as ByteArray?) as Void {
        System.println("draw custom data function");
        if (customData != null) {
            var heel = decodeStepData(customData.slice(0, 4)); // step part 1
            var middle = decodeStepData(customData.slice(4, 8)); // step part 2
            var toe = decodeStepData(customData.slice(8, 12)); // step part 3

            var y =150; // Starting y-coordinate for drawing text
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

            dc.drawText(10, y, Graphics.FONT_XTINY, "HEEL: " + heel.toString(), Graphics.TEXT_JUSTIFY_LEFT);
            y += 60; // Move down for the next line

            dc.drawText(10, y, Graphics.FONT_XTINY, "MIDDLE: " + middle.toString(), Graphics.TEXT_JUSTIFY_LEFT);
            y += 60; // Move down for the next line

            dc.drawText(10, y, Graphics.FONT_XTINY, "TOE: " + toe.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
        else{
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();

            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();

            var strideY = screenHeight * 0.35;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, strideY, Graphics.FONT_SMALL, "Waiting for data...", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
    }


    private function decodeStepData(bytes as ByteArray) as Array<Number> {
        var values = [] as Array<Number>;
        for (var i = 0; i < 4; i++) {
            var b = bytes[i];
            var highNibble = (b >> 4) & 0xF;
            var lowNibble = b & 0xF;
            values.add(highNibble);
            values.add(lowNibble);
        }
        System.println(values);
        return values;
    }


}