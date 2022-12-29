using Toybox.System;

class SysStats {
    private var systemStats;
    private var isIcons;

    public function initialize(p_isIcons) {
        // Doc says this call will not return null;
        systemStats = System.getSystemStats();
        isIcons = p_isIcons;
    }

    public function getBattery() {
        var returnString = systemStats.battery != null ? systemStats.battery.format("%.0f") + "%" : "NA";

        if (isIcons) {
            return [returnString, I_BATTERY];
        }
        else {
            return returnString;
        }
    }

    public function getBatteryInDays(dayString) {
        var returnString = "NA";
        if (systemStats has :batteryInDays) {
            returnString = systemStats.batteryInDays != null ? systemStats.batteryInDays.format("%.1f") +  dayString : "NA";  
        }
        
        if (isIcons) {
            return [returnString, I_BATTERY];
        }
        else {
            return returnString;
        }
    }
}