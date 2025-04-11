// filepath: c:\STRIDE\ciq_projects\STRIDE_CIQ_CustomBleProfile\source\DataView.mc
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class DataView extends WatchUi.View {
    private var _deviceDataModel as DeviceDataModel;
    private var _sessionMgr as SessionManager;

    //! Constructor
    //! @param deviceDataModel The model containing the device data
    public function initialize(sessionMgr as SessionManager, deviceDataModel as DeviceDataModel) {
        View.initialize();
        _deviceDataModel = deviceDataModel;
        _sessionMgr = sessionMgr;

    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
        System.println("onUpdate()");
        // Clear the screen first
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        //first data page
        if(_deviceDataModel.getDataPageIndex()==0){
            // Check connection and profile
            var isConnected = _deviceDataModel.isConnected();
            var profile = _deviceDataModel.getActiveProfile();
            System.println("isConnected: " + isConnected);
            System.println("profile: " + profile);
            
            if (isConnected && (profile != null)) {
                var customData = profile.getCustomDataByteArray();
                System.println("Data: " + customData);
                // Draw heat map using the land (first step) data
                drawCustomData(dc, customData);
                //draw circles on side
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(30,200,6);
                dc.fillCircle(30,220,4);
            }
            else {
                var screenWidth = dc.getWidth();
                var screenHeight = dc.getHeight();
                var strideY = screenHeight * 0.35;
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "Connecting...", Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            // draw text on the screen saying Hi Page 2
            // var screenWidth = dc.getWidth();
            // var screenHeight = dc.getHeight();
            // var strideY = screenHeight * 0.35;
            // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            // dc.drawText(screenWidth / 2, strideY, Graphics.FONT_LARGE, "IMU Data", Graphics.TEXT_JUSTIFY_CENTER);
            // var currSession = _deviceDataModel.getCurrentSessionID();
            // System.println(Application.Storage.getValue(currSession));

            // Draw circles on side
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(30,200,4);
            dc.fillCircle(30,220,6);

            // Check connection and profile
            var isConnected = _deviceDataModel.isConnected();
            var profile = _deviceDataModel.getActiveProfile();
            System.println("isConnected: " + isConnected);
            System.println("profile: " + profile);
            
            if (isConnected && (profile != null)) {
                // Save the data to the session
                var customData = profile.getCustomDataByteArray();
                System.print("Land");
                var land = decodeStepData(customData.slice(0, 4)); // step part 1
                System.print("Load");
                var load = decodeStepData(customData.slice(4, 8)); // step part 2
                System.print("Launch");
                var launch = decodeStepData(customData.slice(8, 12)); // step part 3
                var imuData = decodeStepData(customData.slice(13, 20)); // imu data
                _sessionMgr.addReading(land, load, launch, imuData);

                // Process IMU Data
                // (0,0) (13,14) (15,16) (17,18) (19, 0)
                var x1y1 = customData.slice(13, 15); // note this x is implied negative
                System.println("x1y1: " + x1y1);
                var x2y2 = customData.slice(15, 17);
                System.println("x2y2: " + x2y2);
                var x3y3 = customData.slice(17, 19); 
                System.println("x3y3: " + x3y3); 
                var point4 = customData.slice(19, 20);
                System.println("point4: " + point4);

                // Draw graph and title
                var screenWidth = dc.getWidth();
                var screenHeight = dc.getHeight();
                var strideY = screenHeight * 0.2;
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(screenWidth / 2, strideY, Graphics.FONT_MEDIUM, "IMU Data", Graphics.TEXT_JUSTIFY_CENTER);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawLine(screenWidth*0.3, screenHeight*0.35, screenWidth*0.3, screenHeight*0.8); // y axis
                dc.drawLine(screenWidth*0.2, screenHeight*0.8, screenWidth*0.8, screenHeight*0.8); // x axis

                // Calculate points - max y is 100 max x is 200
                var x1 = (0.3 - ((x1y1[0]/255)*0.5)) * screenWidth; // x was /200 and y was /100
                var y1 = (((x1y1[1]/255)*0.45) + 0.35) * screenHeight; 

                var x2 = (((x2y2[0]/255)*0.5) + 0.3) * screenWidth;
                var y2 = (((x2y2[1]/255)*0.45) + 0.35) * screenHeight;

                var x3 = (((x3y3[0]/255)*0.5) + 0.3) * screenWidth;
                var y3 = (((x3y3[1]/255)*0.45) + 0.35) * screenHeight;

                var x4 = (((point4[0]/255)*0.45) + 0.35) * screenHeight;
                var y4 = 0.35 * screenWidth;

                // Draw points
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(0.3 * screenWidth, 0.8 * screenHeight, 4); // origin
                dc.fillCircle(x1, y1, 4);
                dc.fillCircle(x2, y2, 4);
                dc.fillCircle(x3, y3, 4);
                dc.fillCircle(x4, y4, 4);

                // Connect points
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
                dc.drawLine(0.3 * screenWidth, 0.8 * screenHeight, x1, y1); // origin to point 1
                dc.drawLine(x1, y1, x2, y2); // point 1 to point 2
                dc.drawLine(x2, y2, x3, y3); // point 2 to point 3
                dc.drawLine(x3, y3, x4, y4); // point 3 to point 4

            } else {
                var screenWidth = dc.getWidth();
                var screenHeight = dc.getHeight();
                var strideY = screenHeight * 0.35;
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(screenWidth / 2, strideY, Graphics.FONT_MEDIUM, "IMU Connecting...", Graphics.TEXT_JUSTIFY_CENTER);
            }

        }
    }

    private function drawCustomData(dc as Dc, customData as ByteArray?) as Void {
        System.println("draw custom data function");
        if (customData != null) {
            System.print("Land");
            var land = decodeStepData(customData.slice(0, 4)); // step part 1
            System.print("Load");
            var load = decodeStepData(customData.slice(4, 8)); // step part 2
            System.print("Launch");
            var launch = decodeStepData(customData.slice(8, 12)); // step part 3
            var imuData = decodeStepData(customData.slice(13, 20)); // step part 4
            // Save the data to the session
            _sessionMgr.addReading(land, load, launch, imuData);


            drawHeatMap(dc, land);
            drawHeatMap(dc, load);
            drawHeatMap(dc, launch);




            // var y =150; // Starting y-coordinate for drawing text
            // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

            // dc.drawText(10, y, Graphics.FONT_XTINY, "land: " + land.toString(), Graphics.TEXT_JUSTIFY_LEFT);
            // y += 60; // Move down for the next line
            // dc.drawText(10, y, Graphics.FONT_XTINY, "load: " + load.toString(), Graphics.TEXT_JUSTIFY_LEFT);
            // y += 60; // Move down for the next line
            // dc.drawText(10, y, Graphics.FONT_XTINY, "launch: " + launch.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
        else {
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

    //! Draws a heat map of 8 pads arranged in a rough foot shape.
    //! The input is an Array of 8 numbers.
 private function drawHeatMap(dc as Dc, values as Array<Number>) as Void {
    var screenWidth = dc.getWidth();
    var screenHeight = dc.getHeight();

    // Define a bounding box for the foot
    var footX = screenWidth * 0.2;      // left side of foot
    var footY = screenHeight * 0.15;    // top of foot
    var boxWidth = screenWidth * 0.6;   // how wide the foot spans
    var boxHeight = screenHeight * 0.7; // how tall the foot spans
    var padRadius = 10;                // circle radius

    //
    // Row 1 (top row - 2 pads): values[0], values[1]
    //
    var row1Y = footY + (boxHeight * 0.05);
    var pad0X = footX + (boxWidth * 0.38);  
    var pad1X = footX + (boxWidth * 0.58);

    dc.setColor(getColorForValue(values[1]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad0X, row1Y, padRadius);

    dc.setColor(getColorForValue(values[0]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad1X, row1Y, padRadius);

    //
    // Row 2 (second row - 3 pads): values[2], values[3], values[4]
    //
    var row2Y = footY + (boxHeight * 0.3);
    var pad2X = footX + (boxWidth * 0.3);
    var pad3X = footX + (boxWidth * 0.5);
    var pad4X = footX + (boxWidth * 0.7);

    dc.setColor(getColorForValue(values[4]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad2X, row2Y, padRadius);

    dc.setColor(getColorForValue(values[3]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad3X, row2Y, padRadius);

    dc.setColor(getColorForValue(values[2]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad4X, row2Y, padRadius);

    //
    // Row 3 (third row - 1 pad): values[5]
    //
    var row3Y = footY + (boxHeight * 0.55);
    var pad5X = footX + (boxWidth * 0.42);

    dc.setColor(getColorForValue(values[5]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad5X, row3Y, padRadius);

    //
    // Row 4 (bottom row - 2 pads): values[6], values[7]
    //
    var row4Y = footY + (boxHeight * 0.8);
    var pad6X = footX + (boxWidth * 0.4);
    var pad7X = footX + (boxWidth * 0.6);

    dc.setColor(getColorForValue(values[7]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad6X, row4Y, padRadius);

    dc.setColor(getColorForValue(values[6]), Graphics.COLOR_BLACK);
    dc.fillCircle(pad7X, row4Y, padRadius);
}


    //! Returns a color based on the pressure value
    private function getColorForValue(val as Number) as Number {
        if (val >= 0 and val <= 1) {
            return 0xffff04;  
        } else if (val >= 2 and val <= 3) {
            return 0xffe200;        
        } else if (val >= 4 and val <= 5) {
            return 0xffc600;     
        } else if (val >= 6 and val <= 7) {
            return 0xffa800;     
        } else if (val >= 8 and val <= 9) {
            return 0xf88401;
        } else if (val >= 10 and val <= 11) {
            return 0xea5800;     
        } else if (val >= 12 and val <= 13) {
            return 0xdb2c00;  
        } else {
            return 0xcc0100;
        }
    }
}