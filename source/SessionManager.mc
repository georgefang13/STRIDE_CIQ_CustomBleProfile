import Toybox.Application;
import Toybox.System;
import Toybox.Lang;
import Toybox.Attention;

class SessionManager {
    // The session is saved as a dictionary with a start time and arrays for each sensor part.
    private var _currentSession as Dictionary or Null;
    private var _deviceDataModel as DeviceDataModel;

    public function initialize(deviceDataModel as DeviceDataModel){
        _deviceDataModel = deviceDataModel;
    }

    //! Starts a new session
    public function startSession() as Void {
        Attention.playTone(Attention.TONE_LOUD_BEEP);

        var myTime = System.getClockTime();
        System.println(myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d"));
        _currentSession = {
            "startTime" => myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d"),
            "stepCount" => 0,
            "imuCount"  => 0,
            "landPad1" => 0,
            "landPad2" => 0,
            "landPad3" => 0,
            "landPad4" => 0,
            "landPad5" => 0,
            "landPad6" => 0,
            "landPad7" => 0,
            "landPad8" => 0,
            "loadPad1" => 0,
            "loadPad2" => 0,
            "loadPad3" => 0,
            "loadPad4" => 0,
            "loadPad5" => 0,
            "loadPad6" => 0,
            "loadPad7" => 0,
            "loadPad8" => 0,
            "launchPad1" => 0,
            "launchPad2" => 0,
            "launchPad3" => 0,
            "launchPad4" => 0,
            "launchPad5" => 0,
            "launchPad6" => 0,
            "launchPad7" => 0,
            "launchPad8" => 0,
            "footPathPoint1X" => 0,
            "footPathPoint1Y" => 0,
            "footPathPoint2X" => 0,
            "footPathPoint2Y" => 0,
            "footPathPoint3X" => 0,
            "footPathPoint3Y" => 0,
            "footPathPoint4X" => 0,
        };
        
        System.println("Session started at " + _currentSession["startTime"]);
        _deviceDataModel.setCurrentSessionID("session_" + _currentSession["startTime"].toString());
    }

    //! Add a new reading to the current session
    //! Each reading is an array of 8 numbers for land, load, or launch pressure.
    public function addReading(land as Array<Number>, load as Array<Number>, launch as Array<Number>, imuData as Array<Number>) as Void {
        if (_currentSession == null) {
            System.println("No session started. Call startSession() first.");
            return;
        }
        for (var i =1; i < 9; i++) {
            var landKey = "landPad" + i.toString(); 
            var loadKey = "loadPad" + i.toString();
            var launchKey = "launchPad" + i.toString();
            if (land[i-1] != null ){
                _currentSession[landKey] += land[i-1];
            } else {
                System.println("Land data is null for pad " + i.toString() + ". Skipping.");
            }
            
            if (load[i-1] != null ){
                _currentSession[loadKey] += load[i-1];
            } else {
                System.println("Load data is null for pad " + i.toString() + ". Skipping.");
            }

            if (launch[i-1] != null ){
                _currentSession[launchKey] += launch[i-1];
            } else {
                System.println("Launch data is null for pad " + i.toString() + ". Skipping.");
            }
        }
        System.println("Added reading, land data: " + land.toString());
        System.println("Added reading, load data: " + load.toString());
        System.println("Added reading, launch data: " + launch.toString());

        // Adding foot path points) {
        if (imuData[0] == 0 && imuData[1] == 0 && imuData[2] == 0 && imuData[3] == 0 && imuData[4] == 0 && imuData[5] == 0 && imuData[6] == 0) {
            System.println("IMU data is null. Skipping.");
        } else {
            _currentSession["footPathPoint1X"] += imuData[0];
            _currentSession["footPathPoint1Y"] += imuData[1];
            _currentSession["footPathPoint2X"] += imuData[2];
            _currentSession["footPathPoint2Y"] += imuData[3];
            _currentSession["footPathPoint3X"] += imuData[4];
            _currentSession["footPathPoint3Y"] += imuData[5];
            _currentSession["footPathPoint4X"] += imuData[6];
            _currentSession["imuCount"] += 1;
        }


        System.println("IMU Data: " + imuData.toString());

        // Incrementing step count
        _currentSession["stepCount"] += 1;
}

    //! Save the current session to persistent storage
    public function saveSession() as Void {
        Attention.playTone(Attention.TONE_STOP);
        if (_currentSession == null) {
            System.println("No session to save.");
            return;
        }
        // Create a unique session ID based on start time.
        var sessionId = "session_" + _currentSession["startTime"].toString();
        System.println("Saving session with ID: " + sessionId);
        System.println("Session data: " + _currentSession);

        Application.Storage.setValue(sessionId, _currentSession); // sessionId
        System.println("Saved session with ID: " + sessionId);
    }

}