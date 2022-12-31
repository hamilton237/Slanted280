using Toybox.System;

class SysStats {
    private var _systemStats;
    private var _isIcons;

    public function initialize(isIcons) {
        // Doc says this call will not return null;
        _systemStats = System.getSystemStats();
        _isIcons = isIcons;
    }

    public function getBattery() {
        var returnString = _systemStats.battery != null ? _systemStats.battery.format("%.0f") + "%" : "NA";

        if (_isIcons) {
            return [returnString, I_BATTERY];
        }
        else {
            return returnString;
        }
    }

    public function getBatteryInDays(dayString) {
        var returnString = "NA";
        if (_systemStats has :batteryInDays) {
            returnString = _systemStats.batteryInDays != null ? _systemStats.batteryInDays.format("%.1f") +  dayString : "NA";  
        }
        
        if (_isIcons) {
            return [returnString, I_BATTERY];
        }
        else {
            return returnString;
        }
    }
}