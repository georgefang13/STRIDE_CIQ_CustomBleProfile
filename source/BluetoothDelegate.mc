//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class BluetoothDelegate extends BluetoothLowEnergy.BleDelegate {
    private var _profileManager as ProfileManager;

    private var _onScanResult as WeakReference?;
    private var _onConnection as WeakReference?;
    private var _onDescriptorWrite as WeakReference?;
    private var _onCharChanged as WeakReference?;

    //! Constructor
    //! @param profileManager The profile manager
    public function initialize(profileManager as ProfileManager) {
        BleDelegate.initialize();
        _profileManager = profileManager;
    }

    //! Handle new scan results being received
    //! @param scanResults An iterator of new scan results
public function onScanResults(scanResults as Iterator) as Void {
    System.println("BLE: onScanResults");
    for (var result = scanResults.next(); result != null; result = scanResults.next()) {
        if (result instanceof ScanResult) {
            System.println("BLE: Found device " + result.getDeviceName());
            var test = result.getServiceUuids();
            if (test != null) {
                System.println("Service UUIDs:"); 
                for (var uuid = test.next(); uuid != null; uuid = test.next()) { 
                    System.println(" " + uuid); 
                }
            }
            else { 
                System.println("No service UUIDs found for this device"); 
            }

            if (contains(result.getServiceUuids(), _profileManager.STRIDE_SERVICE)) {
                System.println("BLE: Found STRIDE service, broadcasting scan result");
                broadcastScanResult(result);
            }
        }
    }
}

    //! Handle pairing and connecting to a device
    //! @param device The device state that was changed
    //! @param state The state of the connection
    public function onConnectedStateChanged(device as Device, state as ConnectionState) as Void {
        System.println("BLE: onConnectedStateChanged");
        var onConnection = _onConnection;
        if (null != onConnection) {
            if (onConnection.stillAlive()) {
                (onConnection.get() as DeviceDataModel).procConnection(device);
            }
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void {
        System.println("BLE: onDescriptorWrite");
        var onDescriptorWrite = _onDescriptorWrite;
        if (null != onDescriptorWrite) {
            if (onDescriptorWrite.stillAlive()) {
                (onDescriptorWrite.get() as EnvironmentProfileModel).onDescriptorWrite(descriptor, status);
            }
        }
    }

    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param value The updated value of the characteristic
public function onCharacteristicChanged(char as Characteristic, data as ByteArray) as Void {
    switch (char.getUuid()) {
        case _profileManager.STRIDE_CHARACTERISTIC:
            System.println("Size of packet: " + data.size().toString());
            System.println("Received data from ESP32: " + data);
            WatchUi.requestUpdate();

            // Forward to the model (add this code)
            var onCharChanged = _onCharChanged;
            if (null != onCharChanged && onCharChanged.stillAlive()) {
                (onCharChanged.get() as EnvironmentProfileModel).onCharacteristicChanged(char, data);
            }

            decodeStepData(data.slice(0,4)); // step part 1
            decodeStepData(data.slice(4,8)); // step part 2
            decodeStepData(data.slice(8,12)); // step part 3
            break;
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

    //! Callback after Characteristic.requestWrite() is complete
    public function onCharacteristicWrite(char as Characteristic, status as BluetoothLowEnergy.Status) as Void {
        System.println("BLE: onCharacteristicWrite: " + char + " status = " + status);
        // TODO - If there is something in the queue then dequeue the next item and write it 
        // using Characteristic.requestWrite()
    }

    public function onProfileRegister(uuid as BluetoothLowEnergy.Uuid, status as BluetoothLowEnergy.Status) as Void {
        System.println("BLE: onProfileRegister: " + uuid + " status = " + status);
    }

    //! Store a new model to manage scan results
    //! @param model The model containing scan results
    public function notifyScanResult(model as ScanDataModel) as Void {
        _onScanResult = model.weak();
    }

    //! Store a new model to manage device data connections
    //! @param model The model for device data
    public function notifyConnection(model as DeviceDataModel) as Void {
        _onConnection = model.weak();
    }

    //! Store a new model to handle descriptor writes
    //! @param model The model for descriptors
    public function notifyDescriptorWrite(model as EnvironmentProfileModel) as Void {
        _onDescriptorWrite = model.weak();
    }

    //! Store a new model to handle characteristic changes
    //! @param model The model for characteristics
    public function notifyCharacteristicChanged(model as EnvironmentProfileModel) as Void {
        _onCharChanged = model.weak();
    }

    public function onScanStateChange(scanState as BluetoothLowEnergy.ScanState, status as BluetoothLowEnergy.Status) as Void {
        System.println("BLE: onScanStateChange: " + scanState + " status = " + status);
        var onScanResult = _onScanResult;
        if (null != onScanResult) {
            if (onScanResult.stillAlive()) {
                (onScanResult.get() as ScanDataModel).setScanState(scanState);
            }
        }
    }

    //! Perform a write. If BLE is busy then queue the operation to run later
    public function queueCharacteristicWrite(char as BluetoothLowEnergy.Characteristic, data as ByteArray) as Void {
        System.println("BLE: queueCharacteristicWrite() called");
        try {
            if ( data != null && data.size() > 0) {
                char.requestWrite(data, {:writeType=>BluetoothLowEnergy.WRITE_TYPE_WITH_RESPONSE});
            }
        }
        catch (ex) {
            System.println("BLE: queueCharacteristicWrite() Exception: " + ex.getErrorMessage());
            // TODO: Failed to write, queue the operation to be run when BLE is no longer busy
        }
    }

    //! Broadcast a new scan result
    //! @param scanResult The new scan result
    private function broadcastScanResult(scanResult as ScanResult) as Void {
        System.println("BLE: WE FOUND OUR DEVICE");
        var onScanResult = _onScanResult;
        if (null != onScanResult) {
            if (onScanResult.stillAlive()) {
                (onScanResult.get() as ScanDataModel).procScanResult(scanResult);
            }
        }
    }

    //! Get whether the iterator contains a specific uuid
    //! @param iter Iterator of uuid objects
    //! @param obj Uuid to search for
    //! @return true if object found, false otherwise
    private function contains(iter as Iterator, obj as Uuid) as Boolean {
        for (var uuid = iter.next(); uuid != null; uuid = iter.next()) {
            if (uuid.equals(obj)) {
                return true;
            }
        }

        return false;
    }

    


}
