import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class AnalysisDelegate extends WatchUi.BehaviorDelegate {
    private var _parentView as AnalysisView;
    private var _viewController as ViewController;

    //! Constructor
    //! @param deviceDataModel The device data model
    //! @param parentView The parent view
    public function initialize(parentView as AnalysisView, viewController as ViewController) {
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

}