// filepath: c:\STRIDE\ciq_projects\STRIDE_CIQ_CustomBleProfile\source\DataDelegate.mc
import Toybox.Lang;
import Toybox.WatchUi;

class DataDelegate extends WatchUi.BehaviorDelegate {
    private var _deviceDataModel as DeviceDataModel;
    private var _parentView as DataView;
    private var _viewController as ViewController;

    //! Constructor
    //! @param deviceDataModel The device data model
    //! @param parentView The parent view
    public function initialize(deviceDataModel as DeviceDataModel, parentView as DataView, viewController as ViewController) {
        BehaviorDelegate.initialize();
        _deviceDataModel = deviceDataModel;
        _parentView = parentView;
        _viewController = viewController;
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

}