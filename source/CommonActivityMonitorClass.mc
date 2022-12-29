import Toybox.ActivityMonitor;

class ActivityMon {
    private var activityMonitor;
    private var isIcons;

    public function initialize(p_isIcons) {
        // Doc says this call will not return null, but the fields in the class may return null
        activityMonitor = ActivityMonitor.getInfo();
        isIcons = p_isIcons;
    }

    public function getSteps() {
        var returnString = activityMonitor.steps != null ? activityMonitor.steps.format("%.0f") : "NA";

        if (isIcons) {
            return [returnString, I_STEPS];
        }
        else {
            return returnString;
        }
    }

    public function getCalories() {
        var returnString = activityMonitor.calories != null ? activityMonitor.calories.format("%.0f") : "NA";

        if (isIcons) {
            return [returnString, I_CALORIES];
        }
        else {
            return returnString;
        }
    }

    public function getFloorsClimbed () {
        var returnString = activityMonitor.floorsClimbed != null ? activityMonitor.floorsClimbed.format("%.0f") : "NA";
        
        if (isIcons) {
            return [returnString, I_FLOORSCLIMBED];
        }
        else {
            return returnString;
        }

    }

    public function getDistance (isMetric) {
        var distance = activityMonitor.distance != null ? activityMonitor.distance / 100000 : 0; // from cm to km
        if (!isMetric){
            distance = distance * 0.62137119;
        }
        var returnString = distance.format("%.0f");

        if (isIcons) {
            return [returnString, I_DISTANCE];
        }
        else {
            return returnString;
        }
    }


}