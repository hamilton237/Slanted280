import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Slanted280App extends Application.AppBase {

    var mView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        mView = new Slanted280View() as Array<Views or InputDelegates>;
        return [mView];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        mView.onSettingsChanged();
        WatchUi.requestUpdate();
    }

}

function getApp() as Slanted280App {
    return Application.getApp() as Slanted280App;
}