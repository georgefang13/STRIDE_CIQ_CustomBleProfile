// filepath: c:\STRIDE\ciq_projects\STRIDE_CIQ_CustomBleProfile\source\DataView.mc
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class AnalysisView extends WatchUi.View {
    private var _deviceDataModel as DeviceDataModel;

    //! Constructor
    public function initialize(deviceDataModel as DeviceDataModel) {
        View.initialize();
        _deviceDataModel = deviceDataModel;
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
        System.println("onUpdate()");
        // Clear the screen first
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var currSession = _deviceDataModel.getCurrentSessionID();
        var sessionDict = Application.Storage.getValue(currSession);
        
        // get the session data from the storage and average it
        System.println("Session: " + sessionDict);
        var arrays = sessionDictToArrays(sessionDict);
        var land = arrays[0];
        var load = arrays[1];
        var launch = arrays[2];
        var imuData = arrays[3];

        if(_deviceDataModel.getAnalysisPageIndex()==0){   
            //draw circles on side
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(30,200,6);
            dc.fillCircle(30,220,4);

            System.println("Land average: " + land);
            System.println("Load average: " + load);
            System.println("Launch average: " + launch);

            // Draw labels for land, load, launch
            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();
            var labelsY = screenHeight * 0.2;
            var landX = screenWidth * 0.2;
            var loadX = screenWidth * 0.5;
            var launchX = screenWidth * 0.8;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(landX, labelsY, Graphics.FONT_XTINY, "Land", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(loadX, labelsY, Graphics.FONT_XTINY, "Load", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(launchX, labelsY, Graphics.FONT_XTINY, "Launch", Graphics.TEXT_JUSTIFY_CENTER);

            // Draw the heat maps under neath the labels
            drawHeatMap(dc, land, 0.05);
            drawHeatMap(dc, load, 0.35);
            drawHeatMap(dc, launch, 0.65);
        } else if(_deviceDataModel.getAnalysisPageIndex()==1){
            // Draw circles on side
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(30,200,4);
            dc.fillCircle(30,220,6);

            // draw the imu data
            var x1y1 = imuData.slice(0, 2); // note this x is implied negative
            System.println("x1y1: " + x1y1);
            var x2y2 = imuData.slice(2, 4);
            System.println("x2y2: " + x2y2);
            var x3y3 = imuData.slice(4, 6); 
            System.println("x3y3: " + x3y3); 
            var point4 = imuData.slice(6, 7);
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
        }
    }

    private function sessionDictToArrays(sessionDict as Dictionary) as Array<Array<Number>> {
        var land = [] as Array<Number>;
        var load = [] as Array<Number>;
        var launch = [] as Array<Number>;
        var imuData = [] as Array<Number>;

        for (var i = 1; i <= 8; i++) {
            land.add(sessionDict["landPad" + i.toString()] / sessionDict["stepCount"]);
            load.add(sessionDict["loadPad" + i.toString()] / sessionDict["stepCount"]);
            launch.add(sessionDict["launchPad" + i.toString()] / sessionDict["stepCount"]);
        }

        imuData.add(sessionDict["footPathPoint1X"] / sessionDict["stepCount"]);
        imuData.add(sessionDict["footPathPoint1Y"] / sessionDict["stepCount"]);
        imuData.add(sessionDict["footPathPoint2X"] / sessionDict["stepCount"]);
        imuData.add(sessionDict["footPathPoint2Y"] / sessionDict["stepCount"]);
        imuData.add(sessionDict["footPathPoint3X"] / sessionDict["stepCount"]);
        imuData.add(sessionDict["footPathPoint3Y"] / sessionDict["stepCount"]);
        imuData.add(sessionDict["footPathPoint4X"] / sessionDict["stepCount"]);

        return [land, load, launch, imuData];
    }

    //! Draws a heat map of 8 pads arranged in a rough foot shape.
    //! The input is an Array of 8 numbers.
    private function drawHeatMap(dc as Dc, values as Array<Number>, xPos as Float) as Void {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        // Define a bounding box for the foot
        var footX = screenWidth * xPos; //0.2;      // left side of foot
        var footY = screenHeight * 0.4;    // top of foot
        var boxWidth = screenWidth * 0.3;   // how wide the foot spans
        var boxHeight = screenHeight * 0.35; // how tall the foot spans
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