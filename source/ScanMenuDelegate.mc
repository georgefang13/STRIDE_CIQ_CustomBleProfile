//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class ScanMenuDelegate extends WatchUi.MenuInputDelegate {

    //! Constructor
    public function initialize() {
        System.println("We are in the scan menu!");
        MenuInputDelegate.initialize();
    }

    //! Handle a menu item being chosen
    //! @param item The identifier of the chosen item
    public function onMenuItem(item as Symbol) as Void {
        if (item == :item_1) {
            BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
            System.println("Scanning left foot");
        } else if (item == :item_2) {
            // BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
            
            System.println("Scanning right foot");

        } else if (item == :item_3) {
            BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
        }
    }
}
