import Toybox.ActivityMonitor;
import Toybox.Lang;

class ActivityMon {
    private var _activityMonitor as ActivityMonitor.Info;
    private var _isIcons as Boolean;

    public function initialize(isIcons as Boolean) {
        // Doc says this call will not return null, but the fields in the class may return null
        _activityMonitor = ActivityMonitor.getInfo();
        _isIcons = isIcons;
    }

    public function getSteps() {
        var returnString = _activityMonitor.steps != null ? _activityMonitor.steps.format("%.0f") : "NA";

        if (_isIcons) {
            return [returnString, I_STEPS];
        }
        else {
            return returnString;
        }
    }

    public function getCalories() {
        var returnString = _activityMonitor.calories != null ? _activityMonitor.calories.format("%.0f") : "NA";

        if (_isIcons) {
            return [returnString, I_CALORIES];
        }
        else {
            return returnString;
        }
    }

    public function getFloorsClimbed () {
        var returnString = _activityMonitor.floorsClimbed != null ? _activityMonitor.floorsClimbed.format("%.0f") : "NA";
        
        if (_isIcons) {
            return [returnString, I_FLOORSCLIMBED];
        }
        else {
            return returnString;
        }

    }

    public function getDistance (isMetric) {
        var distance = _activityMonitor.distance != null ? _activityMonitor.distance / 100000 : 0; // from cm to km
        if (!isMetric){
            distance = distance * 0.62137119;
        }
        var returnString = distance.format("%.0f");

        if (_isIcons) {
            return [returnString, I_DISTANCE];
        }
        else {
            return returnString;
        }
    }

    public function getRecoveryTime () {
        var recTime = _activityMonitor.timeToRecovery != null ? _activityMonitor.timeToRecovery : 0;

        var returnString = recTime.format("%.0f") + " h";

        if (_isIcons) {
            return [returnString, I_RECOVERYTIME];
        }
        else {
            return returnString;
        }
    }


}