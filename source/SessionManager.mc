import Toybox.Application;
import Toybox.System;
import Toybox.Lang;

class SessionManager {
    // The session is saved as a dictionary with a start time and arrays for each sensor part.
    private var _currentSession as Dictionary or Null;

    //! Starts a new session
    public function startSession() as Void {
        var myTime = System.getClockTime();
        System.println(myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d"));
        _currentSession = {
            :startTime => myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d"),
            :landData  => [] as Array<String>,
            :loadData => [] as Array<String>,
            :launchData   => [] as Array<String>
        };
        
        System.println("Session started at " + _currentSession[:startTime]);
    }

    //! Add a new reading to the current session
    //! Each reading is an array of 8 numbers for land, load, or launch pressure.
    public function addReading(land as Array<Number>, load as Array<Number>, launch as Array<Number>) as Void {
        if (_currentSession == null) {
            System.println("No session started. Call startSession() first.");
            return;
        }
        _currentSession[:landData].add("landTest");
        _currentSession[:loadData].add("loadTest");
        _currentSession[:launchData].add("launchTest");
        System.println("Added reading, land data: " + land.toString());
        System.println("Added reading, load data: " + load.toString());
        System.println("Added reading, launch data: " + launch.toString());
    }

    //! Save the current session to persistent storage
    public function saveSession() as Void {
        if (_currentSession == null) {
            System.println("No session to save.");
            return;
        }
        // Create a unique session ID based on start time.
        var sessionId = "session_" + _currentSession[:startTime].toString();
        System.println("Saving session with ID: " + sessionId);
        System.println("Session data: " + _currentSession);
        Application.Storage.setValue(sessionId, _currentSession);
        System.println("Saved session with ID: " + sessionId);
    }
}