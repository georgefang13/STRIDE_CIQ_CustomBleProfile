//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
// NOTES for Duke Students: This class is used for tracking the devices
// found in BLE scan. It allows the UI to loop over found devices and
// display the number of devices found.

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class ScanDataModel {
    private var _displayResult as Number;
    private var _scanResults as Array<ScanResult>;
    private var _scanState as BluetoothLowEnergy.ScanState = BluetoothLowEnergy.SCAN_STATE_OFF;

    //! Constructor
    //! @param bleDelegate The BLE delegate for this model
    public function initialize(bleDelegate as BluetoothDelegate) {
        System.println("ScanDataModel::initialize");
        bleDelegate.notifyScanResult(self);

        _scanResults = [] as Array<ScanResult>;
        _displayResult = 0;
    }

    //! Process a new scan result
    //! @param scanResult The new scan result
    public function procScanResult(scanResult as ScanResult) as Void {
        var newDevice = true;
        System.println("ScanDataModel::procScanResult");

        // Determine if this is a new Device
        for (var i = 0; i < _scanResults.size(); i++) {
            if (scanResult.isSameDevice(_scanResults[i])) {
                if (scanResult.getDeviceName() != null){
                    _scanResults[i] = scanResult;
                }
                newDevice = false;
                break;
            }
        }

        if (newDevice) {
            _scanResults.add(scanResult);
        }
        System.println("We are running on update again!");
        WatchUi.requestUpdate();
    }

    //! Update display to next result
    public function nextResult() as Void {
        if (_displayResult < (_scanResults.size() - 1)) {
            _displayResult++;
            WatchUi.requestUpdate();
        }
    }

    //! Update display to previous result
    public function previousResult() as Void {
        if (_displayResult > 0) {
            _displayResult--;
            WatchUi.requestUpdate();
        }
    }

    //! Get the current scan result
    //! @return The current scan result
    public function getDisplayResult() as ScanResult? {
        if (_scanResults.size() == 0) {
            return null;
        }

        return _scanResults[_displayResult];
    }

    //! Get the current display index
    //! @return The display index
    public function getDisplayIndex() as Number {
        if (_scanResults.size() == 0) {
            return 0;
        }

        return _displayResult + 1;
    }

    //! Get the number of scan results
    //! @return The number of scan results
    public function getResultCount() as Number {
        return _scanResults.size();
    }

    //! Update display to the new scan state
    public function setScanState(scanState as BluetoothLowEnergy.ScanState) as Void {
        _scanState = scanState;
        WatchUi.requestUpdate();
    }

    //! Get whether the watch is scanning
    //! @return true if scanning, false otherwise
    public function isScanning() as Boolean {
        return _scanState == BluetoothLowEnergy.SCAN_STATE_SCANNING;
    }
}
