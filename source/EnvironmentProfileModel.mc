//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class EnvironmentProfileModel {
    private var _service as Service?;
    private var _profileManager as ProfileManager;
    private var _pendingNotifies as Array<Characteristic>;
    // private var _GpioCharacteristic as Characteristic;
    private var _BluetoothDelegate as BluetoothDelegate;
    private var _PhoneCommunication as PhoneCommunication;

    private var _custom_data_byte_array as ByteArray;
    private var _gpio_data_byte_array as ByteArray;

    //! Constructor
    //! @param delegate The BLE delegate for the model
    //! @param profileManager The profile manager for this model
    //! @param device The current device
    public function initialize(delegate as BluetoothDelegate, profileManager as ProfileManager, device as Device, phoneComm as PhoneCommunication) {
        _BluetoothDelegate = delegate;
        _BluetoothDelegate.notifyDescriptorWrite(self);
        _BluetoothDelegate.notifyCharacteristicChanged(self);

        _profileManager = profileManager;
        _service = device.getService(profileManager.STRIDE_SERVICE);
        _PhoneCommunication = phoneComm;

        _pendingNotifies = [] as Array<Characteristic>;
        _custom_data_byte_array = []b;
        _gpio_data_byte_array = []b;

        var service = _service;
        if (service != null) {
            var characteristics = service.getCharacteristics();
            var characteristic = characteristics.next() as Characteristic;
            while (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
                characteristic = characteristics.next() as Characteristic;
            }
        }

        activateNextNotification();
    }

    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param data The updated data of the characteristic
    public function onCharacteristicChanged(char as Characteristic, data as ByteArray) as Void {
        switch (char.getUuid()) {
            case _profileManager.STRIDE_CHARACTERISTIC:
                System.println("onCharacteristicChanged(), STRIDE_CHARACTERISTIC, data.size()=" + data.size());
                processCustomData(data);
                break;
            // case _profileManager.DUKE_GPIO_CHARACTERISTIC:
            //     System.println("onCharacteristicChanged(), DUKE_GPIO_CHARACTERISTIC, data.size()=" + data.size());
            //     processLedData(data);
            //     break;
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void {
        if (BluetoothLowEnergy.cccdUuid().equals(descriptor.getUuid())) {
            processCccdWrite();
        }
    }

    //! Get the custom data ByteArray
    //! @return The custom data ByteArray
    public function getCustomDataByteArray() as ByteArray? {
        if (_custom_data_byte_array.size() > 0) {
            return _custom_data_byte_array;
        }
        return null;
    }

    //! Get the custom GPIO data ByteArray
    //! @return The custom GPIO data ByteArray
    public function getGpioDataByteArray() as ByteArray? {
        if (_gpio_data_byte_array.size() > 0) {
            return _gpio_data_byte_array;
        }
        return null;
    }

    //! Update the GPIO data by writing to the BLE characteristic
    // public function writeGpioDataByteArray(writeGpioDataByteArray as ByteArray) as Void {
    //     _BluetoothDelegate.queueCharacteristicWrite(_GpioCharacteristic, writeGpioDataByteArray);
    // }

    //! Write the next notification to the descriptor
    private function activateNextNotification() as Void {
        if (_pendingNotifies.size() == 0) {
            System.println("activateNextNotification, _pendingNotifies.size() == 0");
            return;
        }

        System.println("activateNextNotification, _pendingNotifies.size(): " + _pendingNotifies.size());
        var char = _pendingNotifies[0];
        var cccd = char.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) {
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    //! Process a CCCD write operation
    private function processCccdWrite() as Void {
        System.println("processCccdWrite, _pendingNotifies.size(): " + _pendingNotifies.size());
        if (_pendingNotifies.size() > 1) {
            _pendingNotifies = _pendingNotifies.slice(1, _pendingNotifies.size());
            activateNextNotification();
        } else {
            _pendingNotifies = [] as Array<Characteristic>;
        }

    }

    //! Process and set the custom data
    //! @param data The new custom data
    private function processCustomData(data as ByteArray) as Void {
        System.println("processCustomData(), data.size()=" + data.size());
        _custom_data_byte_array = []b;
        _custom_data_byte_array.addAll(data);
        WatchUi.requestUpdate();
    }

    //! Process and set the custom data processLedData
    //! @param data The new custom data
    private function processLedData(data as ByteArray) as Void {
        System.println("processLedData(), data.size()=" + data.size());
        var old_gpio_data = _gpio_data_byte_array;
        _gpio_data_byte_array = []b;
        _gpio_data_byte_array.addAll(data);

        // Check for changes in LED state. Send the new state to the phone
        // if the LED has changed
        if ( ( _gpio_data_byte_array.size() > 0 && old_gpio_data.size() > 0
               && _gpio_data_byte_array[DeviceView.GPIO_PAYLOAD_INDEX_LED4] != old_gpio_data[DeviceView.GPIO_PAYLOAD_INDEX_LED4] )
             || (old_gpio_data.size() == 0 && _gpio_data_byte_array.size() > 0) ) {
            var message = _gpio_data_byte_array[DeviceView.GPIO_PAYLOAD_INDEX_LED4] == DeviceView.LED_STATE_OFF ?
                "LED4:state:off" : "LED4:state:on";
            _PhoneCommunication.transmitMessageToPhone(message);
        }

        WatchUi.requestUpdate();
    }
}
