import Toybox.Graphics;
import Toybox.WatchUi;

class MainView extends WatchUi.View {
    private var _scanDataModel as ScanDataModel;

    public function initialize(scanDataModel as ScanDataModel) {
        View.initialize();
        _scanDataModel = scanDataModel;
    }

    public function onUpdate(dc as Dc) as Void {
        var displayResult = _scanDataModel.getDisplayResult();


        // If we are not scanning, display home screen
        if(!_scanDataModel.isScanning()) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();

            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();

            var strideY = screenHeight * 0.35;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "STRIDE", Graphics.TEXT_JUSTIFY_CENTER);

            var scanTextY = strideY + dc.getFontHeight(Graphics.FONT_LARGE) + 15;
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, scanTextY, Graphics.FONT_SMALL, "Hold UP to Scan", Graphics.TEXT_JUSTIFY_CENTER);
        } 

        // If we have found a device
        else if (displayResult != null) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();

            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();

            var strideY = screenHeight * 0.35;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "Tap to connect", Graphics.TEXT_JUSTIFY_CENTER);
        } 
        
        // If we are scanning and haven't found a device yet
        else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();

            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();

            var strideY = screenHeight * 0.35;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "SCANNING...", Graphics.TEXT_JUSTIFY_CENTER);
        }


        System.println("MainView::onUpdate()");


    }



}
