//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class DeviceView extends WatchUi.View {

    // These probably belong in Profile manager or model
    static enum {
        GPIO_PAYLOAD_INDEX_LED4 = 0,
        GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT = 1,
        GPIO_PAYLOAD_INDEX_GPIO12_INPUT = 2,
	
	GPIO_PAYLOAD_SIZE_BYTES
    }

    static enum {
        LED_STATE_OFF = 0,
        LED_STATE_ON = 1,
	
	LED_STATE_COUNT,
    }

    static enum {
        GPIO_STATE_CLEARED = 0,
        GPIO_STATE_SET = 1,
	
	GPIO_STATE_COUNT
    }

    private var InitialYOffsetPercent = 0.12f;
    private var ButtonDimensionsPercent = 0.23f;
    private var ButtonXPaddingPercent = 0.07f;
    private var ButtonYPaddingPercent = 0.04f;
    private var GpioDataExpectedSize = 1;

    private var mDataModel as DeviceDataModel;
    private var mGpioDataByteArray as ByteArray;
    private var mYOffset as Number;
    private var mButtonPositionsSet as Boolean;
    private var mLedButtonPosition as Array<Number>;  // x, y, width, height
    private var mGpio11ButtonPosition as Array<Number>;  // x, y, width, height

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();

        mDataModel = dataModel;
        mGpioDataByteArray = [LED_STATE_OFF, GPIO_STATE_CLEARED, GPIO_STATE_SET]b;
        mYOffset = 0;
        mButtonPositionsSet = false;
        mLedButtonPosition = [0, 0, 0, 0];
        mGpio11ButtonPosition = [0, 0, 0, 0];
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        System.println("onUpdate()");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var isConnected = mDataModel.isConnected();
        var statusString;
        if (isConnected) {
            statusString = "Connected";
        } else {
            statusString = "Waiting for\nConnection...";
        }

        mYOffset = InitialYOffsetPercent * dc.getHeight();
        dc.drawText(dc.getWidth() / 2, InitialYOffsetPercent * dc.getHeight(), Graphics.FONT_MEDIUM, statusString, Graphics.TEXT_JUSTIFY_CENTER);
        mYOffset += dc.getFontHeight(Graphics.FONT_MEDIUM);

        var profile = mDataModel.getActiveProfile();
        if (isConnected && (profile != null)) {
            drawCustomData(dc, profile.getCustomDataByteArray());
            var gpioData = profile.getGpioDataByteArray();
            storeGpioData(gpioData);
            if (gpioData != null and gpioData.size() > 0) {
                drawButtons(dc);
                drawInputGpioText(dc);
            }
        }
    }

    //! Update the screen with the data received
    //! @param dc Device context
    //! @param customData The custom data
    private function drawCustomData(dc as Dc, customData as ByteArray?) as Void {
        System.println("drawCustomValue()");
        
        if (customData != null) {
            var font = Graphics.FONT_SYSTEM_SMALL;
            var dataSize = customData.size();
            var dataValuesLabel = "";
            if (dataSize > 0) {
                var HELLO_WORLD = true;
                if (HELLO_WORLD) {
                    // Treat incoming customData as text
                    var options = {
                        :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
                        :toRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
                        :encoding => StringUtil.CHAR_ENCODING_UTF8
                        };
                    dataValuesLabel = StringUtil.convertEncodedString(customData, options);
                } else {
                    // Treat in incoming customData as numeric, only print the first few
                    var MAX_DISPLAY_COUNT = 5;
                    var displayCount = dataSize > MAX_DISPLAY_COUNT ? MAX_DISPLAY_COUNT - 1 : dataSize - 1;
                    for (var i = 0; i < displayCount; i++) {
                        dataValuesLabel += customData[i].format("%3d") + ",";
                    }
                    dataValuesLabel += customData[displayCount].format("%3d");
                }
            }
            System.println("  dataValuesLabel " + dataValuesLabel);
            dc.drawText(dc.getWidth() / 2, mYOffset, font, dataValuesLabel, Graphics.TEXT_JUSTIFY_CENTER);
            mYOffset += dc.getFontHeight(font);

            System.println("  customData.size() " + dataSize);
            var dataSizeLabel = "dataSize: " + dataSize.toString();
            font = Graphics.FONT_SYSTEM_XTINY;
            dc.drawText(dc.getWidth() / 2, mYOffset, font, dataSizeLabel, Graphics.TEXT_JUSTIFY_CENTER);
            mYOffset += dc.getFontHeight(font);

            setButtonPositions(dc);  // Needs to happen after the custom data has been drawn the first time
        }
    }

    //! @param gpioData The GPIO data
    private function storeGpioData(gpioData as ByteArray?) as Void {
        if (gpioData != null) {
            // Nothing is printed to the screen, just variables stored and debug prints
            var gpioDataSize = gpioData.size();
            if (gpioDataSize > 0) {
                System.println("  gpioData.size() " + gpioDataSize);
                if (GpioDataExpectedSize == gpioDataSize) {
                    System.println("  " + gpioData);
                } else {
                    System.println("  Warning: gpioData.size() " + gpioDataSize + ", expected " + GpioDataExpectedSize);
                }
                
                if (gpioData[GPIO_PAYLOAD_INDEX_LED4] < LED_STATE_COUNT) {
                    mGpioDataByteArray[GPIO_PAYLOAD_INDEX_LED4]
                        = gpioData[GPIO_PAYLOAD_INDEX_LED4];
                } else {
                    System.println("unsupported state gpioData[GPIO_PAYLOAD_INDEX_LED4] "
                        + gpioData[GPIO_PAYLOAD_INDEX_LED4]);
                }

                if (gpioData[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT] < GPIO_STATE_COUNT) {
                    mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT]
                        = gpioData[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT];
                } else {
                    System.println("unsupported state gpioData[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT] "
                        + gpioData[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT]);
                }

                if (gpioData[GPIO_PAYLOAD_INDEX_GPIO12_INPUT] < GPIO_STATE_COUNT) {
                    mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO12_INPUT]
                        = gpioData[GPIO_PAYLOAD_INDEX_GPIO12_INPUT];
                } else {
                    System.println("unsupported state gpioData[GPIO_PAYLOAD_INDEX_GPIO12_INPUT] "
                        + gpioData[GPIO_PAYLOAD_INDEX_GPIO12_INPUT]);
                }
            }
        }
    }

    public function drawButtons(dc as Dc) as Void {
        System.println("drawButtons(), mGpioDataByteArray: " + mGpioDataByteArray);

        dc.setColor(
            mGpioDataByteArray[GPIO_PAYLOAD_INDEX_LED4] == LED_STATE_OFF ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_YELLOW,
            Graphics.COLOR_BLACK
        );
        dc.fillRectangle(
            mLedButtonPosition[0],
            mLedButtonPosition[1],
            mLedButtonPosition[2],
            mLedButtonPosition[3]
        );

        dc.setColor(
            mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT] == GPIO_STATE_CLEARED ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_YELLOW,
            Graphics.COLOR_BLACK
        );
        dc.fillRectangle(
            mGpio11ButtonPosition[0],
            mGpio11ButtonPosition[1],
            mGpio11ButtonPosition[2],
            mGpio11ButtonPosition[3]
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_SYSTEM_XTINY;
        var ledButtonXCenter = mLedButtonPosition[0] + mLedButtonPosition[2] / 2;
        var gpio11ButtonXCenter = mGpio11ButtonPosition[0] + mGpio11ButtonPosition[2] / 2;
        var buttonYCenter = mLedButtonPosition[1] + mLedButtonPosition[3] / 2 - dc.getFontHeight(font) / 2;
        dc.drawText(ledButtonXCenter, buttonYCenter, font, "LED_4", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(gpio11ButtonXCenter, buttonYCenter, font, "GPIO_11", Graphics.TEXT_JUSTIFY_CENTER);

        mYOffset = mGpio11ButtonPosition[1] + mGpio11ButtonPosition[3] + ButtonYPaddingPercent * dc.getHeight();
    }

    public function drawInputGpioText(dc as Dc) as Void {
        var screenCenter = dc.getWidth() / 2;
        var font = Graphics.FONT_SYSTEM_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(screenCenter, mYOffset, font, "GPIO 12 is:", Graphics.TEXT_JUSTIFY_CENTER);
        mYOffset += dc.getFontHeight(font);
        var isGpioSet = mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO12_INPUT] == GPIO_STATE_SET;
        var textGpio12 = isGpioSet ? "SET" : "CLEARED";
        dc.setColor(isGpioSet ? Graphics.COLOR_YELLOW : Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(screenCenter, mYOffset, font, textGpio12, Graphics.TEXT_JUSTIFY_CENTER);
        mYOffset += dc.getFontHeight(font);
    }

    private function setButtonPositions(dc as Dc) as Void {
        if (!mButtonPositionsSet) {
            var screenWidth = dc.getWidth();
            var screenXCenter = screenWidth / 2;
            var screenHeight = dc.getHeight();
            var buttonXPadding = ButtonXPaddingPercent * screenWidth;
            mYOffset += ButtonYPaddingPercent * screenHeight;
            mLedButtonPosition[2] = ButtonDimensionsPercent * screenWidth;  // width
            mLedButtonPosition[3] = ButtonDimensionsPercent * screenHeight;  // height
            mLedButtonPosition[0] = screenXCenter - buttonXPadding - mLedButtonPosition[2];  // x
            mLedButtonPosition[1] = mYOffset;  // y

            mGpio11ButtonPosition[2] = mLedButtonPosition[2]; // width
            mGpio11ButtonPosition[3] = mLedButtonPosition[3]; // height
            mGpio11ButtonPosition[0] = screenXCenter + buttonXPadding;  // x
            mGpio11ButtonPosition[1] = mYOffset;  // y

            mButtonPositionsSet = true;
        }
    }

    // Using a Selectable / Button Type would be better, but this will work as a hacky solution for now.
    public function onTapEvent(x as Number, y as Number) as Void {
        System.println("onTapEvent()");
        var gpioDataUpdated = false;

        if (x >= mLedButtonPosition[0] && x <= mLedButtonPosition[0] + mLedButtonPosition[2] &&
            y >= mLedButtonPosition[1] && y <= mLedButtonPosition[1] + mLedButtonPosition[3]) {
            mGpioDataByteArray[GPIO_PAYLOAD_INDEX_LED4]
                = mGpioDataByteArray[GPIO_PAYLOAD_INDEX_LED4] == LED_STATE_OFF
                ? LED_STATE_ON : LED_STATE_OFF;
            System.println("  new mGpioDataByteArray[GPIO_PAYLOAD_INDEX_LED4]: " + mGpioDataByteArray[GPIO_PAYLOAD_INDEX_LED4]);
            gpioDataUpdated = true;
        }

        if (x >= mGpio11ButtonPosition[0] && x <= mGpio11ButtonPosition[0] + mGpio11ButtonPosition[2] &&
            y >= mGpio11ButtonPosition[1] && y <= mGpio11ButtonPosition[1] + mGpio11ButtonPosition[3]) {
            mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT]
                = mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT] == GPIO_STATE_CLEARED
                ? GPIO_STATE_SET : GPIO_STATE_CLEARED;
            System.println("  new mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT]: " + mGpioDataByteArray[GPIO_PAYLOAD_INDEX_GPIO11_OUTPUT]);
            gpioDataUpdated = true;
        }

        // if (gpioDataUpdated) {
        //     var profile = mDataModel.getActiveProfile();
        //     if (mDataModel.isConnected() && profile != null) {
        //         profile.writeGpioDataByteArray(mGpioDataByteArray);
        //     }

        //     WatchUi.requestUpdate();
        // }
    }

    // Call this function to set a GPIO state. The new state is compared to the
    // existing state and if a change is being made then the full GPIO data array
    // will be written to the accessory.
    // TODO: Currnetly ONLY supports GPIO_PAYLOAD_INDEX_LED4. Need to add
    // support for other GPIOs.
    //! @param gpio indicates which gpio to set 
    //! @param on set to true to turn the gpio on, false to turn it off
    public function setGpioState(gpio as Number, on as Boolean) {
        var gpioDataUpdated = false;
        if (gpio == GPIO_PAYLOAD_INDEX_LED4) {
            if (on && mGpioDataByteArray[gpio] == LED_STATE_OFF) {
                mGpioDataByteArray[gpio] = LED_STATE_ON;
                gpioDataUpdated = true;
            }
            if (!on && mGpioDataByteArray[gpio] == LED_STATE_ON) {
                mGpioDataByteArray[gpio] = LED_STATE_OFF;
                gpioDataUpdated = true;
            }
        }
        if (gpioDataUpdated) {
            var profile = mDataModel.getActiveProfile();
            if (mDataModel.isConnected() && profile != null) {
                System.println("DeviceView::setGpioState gpio=" + gpio + "on=" + (on ? "yes": "no"));
                // profile.writeGpioDataByteArray(mGpioDataByteArray);
            }
            WatchUi.requestUpdate();
        }        
    }
}
