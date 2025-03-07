//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;

class ProfileManager {
    public const STRIDE_SERVICE = BluetoothLowEnergy.stringToUuid("90ca8ba1-ad86-407a-80ce-f2f1d256c27e");
    public const STRIDE_CHARACTERISTIC = BluetoothLowEnergy.stringToUuid("c04a0c51-1f6d-44ea-bd08-675a0a578e41");

        private const _envProfileDef = {
            :uuid => STRIDE_SERVICE,
            :characteristics => [
                {
                :uuid => STRIDE_CHARACTERISTIC,
                :descriptors => [BluetoothLowEnergy.cccdUuid()]
                }
                ]
        };

    //! Register the bluetooth profile
    public function registerProfiles() as Void {
        BluetoothLowEnergy.registerProfile(_envProfileDef);
    }
}
