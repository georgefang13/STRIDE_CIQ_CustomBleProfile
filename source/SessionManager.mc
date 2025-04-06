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
            :heelData  => [] as Array<String>,
            :middleData => [] as Array<String>,
            :toeData   => [] as Array<String>
        };
        
        System.println("Session started at " + _currentSession[:startTime]);
    }

    //! Add a new reading to the current session
    //! Each reading is an array of 8 numbers for heel, middle, or toe pressure.
    public function addReading(heel as Array<Number>, middle as Array<Number>, toe as Array<Number>) as Void {
        if (_currentSession == null) {
            System.println("No session started. Call startSession() first.");
            return;
        }
        _currentSession[:heelData].add("heelTest");
        _currentSession[:middleData].add("middleTest");
        _currentSession[:toeData].add("toeTest");
        System.println("Added reading, heel data: " + heel.toString());
        System.println("Added reading, middle data: " + middle.toString());
        System.println("Added reading, toe data: " + toe.toString());
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