// filepath: c:\STRIDE\ciq_projects\STRIDE_CIQ_CustomBleProfile\source\DataDelegate.mc
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class DataDelegate extends WatchUi.BehaviorDelegate {
    private var _deviceDataModel as DeviceDataModel;
    private var _parentView as DataView;
    private var _viewController as ViewController;
    private var _isSessionActive as Boolean = false;
    private var _sessionMgr as SessionManager;

    //! Constructor
    //! @param deviceDataModel The device data model
    //! @param parentView The parent view
    public function initialize(sessionMgr as SessionManager, deviceDataModel as DeviceDataModel, parentView as DataView, viewController as ViewController) {
        BehaviorDelegate.initialize();
        _deviceDataModel = deviceDataModel;
        _parentView = parentView;
        _viewController = viewController;
        _deviceDataModel.pair();
        _sessionMgr = sessionMgr;

    }

    // Example: Press the "Start" session on the START button, 
    // and the "Stop" session on the MENU button.
    // Adjust these methods as you see fit for your watch's button layout.
    public function onSelect() as Boolean {
        // Start or toggle session
        if(!_isSessionActive) {
            startSession();
        }
        else{
            stopSession();
        }
        return true;
    }

    //! Handle back button press
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // ! Handle menu button press
    // ! @return true if handled, false otherwise
    // public function onMenu() as Boolean {
    //     System.println("Pressed up button!");
    //     _viewController.pushScanMenu();
    //     return true;
    // }


    private function startSession() as Void {
        System.println("Starting session...");
        _isSessionActive = true;
        _sessionMgr.startSession();
    }

    private function stopSession() as Void {
        System.println("Stopping session...");
        _isSessionActive = false;
        //Save the session data somehow
        _sessionMgr.saveSession();
    }

}