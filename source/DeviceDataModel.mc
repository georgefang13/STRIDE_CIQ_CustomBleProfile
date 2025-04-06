//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class DeviceDataModel {
    private var _scanResult as ScanResult;
    private var _device as Device?;
    private var _environmentProfile as EnvironmentProfileModel?;
    private var _dataModelFactory as DataModelFactory;
    private var _dataPageIndex as Integer;
    private var _currentSessionID as String;

    //! Constructor
    //! @param bleDelegate The BLE delegate for the model
    //! @param dataModelFactory The factory to create models
    //! @param scanResult The device scan result
    public function initialize(bleDelegate as BluetoothDelegate, dataModelFactory as DataModelFactory, scanResult as ScanResult) {
        _scanResult = scanResult;
        _dataModelFactory = dataModelFactory;

        bleDelegate.notifyConnection(self);

        _device = null;
        _environmentProfile = null;
        _dataPageIndex = 0;
        _currentSessionID = "";
    }

    //! Process a new device connection
    //! @param device The device that was connected
    public function procConnection(device as Device) as Void {
        if (device != _device) {
            // Not our device
            return;
        }

        if (device.isConnected()) {
            procDeviceConnected();
        }

        WatchUi.requestUpdate();
    }

    //! Pair the device associated with the current scan result
    public function pair() as Void {
        BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
        _device = BluetoothLowEnergy.pairDevice(_scanResult);
    }

    //! Unpair the current device
    public function unpair() as Void {
        if (_device != null) {
            BluetoothLowEnergy.unpairDevice(_device);
        }
        _device = null;
    }

    //! Get the active profile
    //! @return The current profile, or null if no device connected
    public function getActiveProfile() as EnvironmentProfileModel? {
        if (_device != null) {
            if (!_device.isConnected()) {
                return null;
            }
        }

        return _environmentProfile;
    }

    //! Get whether a device is connected
    //! @return true if connected, false otherwise
    public function isConnected() as Boolean {
        if (_device != null) {
            return _device.isConnected();
        }
        return false;
    }

    //! Update the profile after a is device connected
    private function procDeviceConnected() as Void {
        if (_device != null) {
            _environmentProfile = _dataModelFactory.getEnvironmentModel(_device);
        }
    }

    public function getDataPageIndex() as Integer {
        return _dataPageIndex;
    }
    public function setDataPageIndex(index as Integer) as Void {
        _dataPageIndex = index;
    }

    public function getCurrentSessionID() as String {
        return _currentSessionID;
    }
    public function setCurrentSessionID(sessionID as String) as Void {
        _currentSessionID = sessionID;
    }
    
}
