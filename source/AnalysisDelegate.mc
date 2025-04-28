import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class AnalysisDelegate extends WatchUi.BehaviorDelegate {
    private var _parentView as AnalysisView;
    private var _viewController as ViewController;
    private var _deviceDataModel as DeviceDataModel;


    //! Constructor
    //! @param deviceDataModel The device data model
    //! @param parentView The parent view
    public function initialize(parentView as AnalysisView, viewController as ViewController, deviceDataModel as DeviceDataModel) {
        _deviceDataModel = deviceDataModel;
        BehaviorDelegate.initialize();
        _parentView = parentView;
        _viewController = viewController;
    }

    //! Handle back button press
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    public function onSwipe(_swipeEvent) as Boolean {
        
        if (_swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
            System.println("Swiped up on AnalysisView!");
            //set a page index variable
            _deviceDataModel.setAnalysisPageIndex(1);
            WatchUi.requestUpdate();
            return true;
        } else if (_swipeEvent.getDirection() == WatchUi.SWIPE_DOWN) {
            System.println("Swiped down on AnalysisView!");
            // If on the second page, stop the session
            _deviceDataModel.setAnalysisPageIndex(0);
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

}