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
        var isConnected = _deviceDataModel.isConnected();
        var profile = _deviceDataModel.getActiveProfile();

        System.println("isConnected: " + isConnected);
        System.println("profile: " + profile);
        if (isConnected && (profile != null)) {
            drawCustomData(dc, profile.getCustomDataByteArray());
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        var strideY = screenHeight * 0.35;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "WELCOME TO DATA VIEW", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawCustomData(dc as Dc, customData as ByteArray?) as Void {
        System.println("draw custom data function");
        if (customData != null){
            System.println("Drawing data (it is not null)");
            System.println(customData);
        }
    }



}