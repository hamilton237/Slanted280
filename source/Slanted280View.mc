using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Time;
//using Toybox.Timer;

const TIME_FONT = Graphics.FONT_NUMBER_THAI_HOT;
const SECONDS_FONT = Graphics.FONT_SYSTEM_SMALL;
const FIELD_FONT = Graphics.FONT_SYSTEM_TINY;


const TIME_Y_POS = 50;
const AMPM_X_POS = 96;
const AMPM_Y_POS = 50;
const PROGBAR_UPPER_Y_POS = 32;
const PROGBAR_LOWER_Y_POS = 65;
const PROGBAR_THICKNESS = 2;
const GRID_LINE_WIDTH = 2;

const TOP_X = 50;
const TOP_Y = 6;

const UPPER_LEFT_X = 29;
const UPPER_LEFT_Y = 28;

const UPPER_RIGHT_X = 79;
const UPPER_RIGHT_Y = 31;

const LOWER_LEFT_X = 22;
const LOWER_LEFT_Y = 69;

const LOWER_RIGHT_X = 70;
const LOWER_RIGHT_Y = 72;

const BOTTOM_X = 50;
const BOTTOM_Y = 92;

const UPPER_BAR_Y = 16;
const LOWER_BAR_Y = 83;

const IS_ICONS = true; // watchface specific


const P_BGCOLOR = Graphics.COLOR_BLACK;
//const P_BGCOLOR = Graphics.COLOR_WHITE;
const P_ICONSCOLOR = Graphics.COLOR_LT_GRAY;
const P_GRIDCOLOR = Graphics.COLOR_LT_GRAY;
const P_FIELDCOLOR = Graphics.COLOR_WHITE;
const P_BARCOLOR = Graphics.COLOR_DK_GRAY;
const P_BARONCOLOR = Graphics.COLOR_BLUE;
const P_IS24HOUR = false;
const P_ISCOLON = false;
const P_ISMETRIC = true;
const P_MINUTESCOLOR = Graphics.COLOR_BLUE;
const P_SECONDSCOLOR = Graphics.COLOR_BLUE;
const P_BATSAVERTHOLD = 30;
const P_TOPFIELD = C_BATTERY;
const P_UPPERLEFTFIELD = C_THREEHOURFORECAST;
const P_UPPERRIGHTFIELD = C_DATE;
const P_LOWERLEFTFIELD = C_BODYBATTERY;
const P_LOWERRIGHTFIELD = C_ALTITUDE;
const P_BOTTOMFIELD = C_BODYBATTERY;
const P_TOPBAR = C_BATTERY;
const P_BOTTOMBAR = C_BODYBATTERY;
const P_PROGRESSBARSPACING = 30;
var bgColor;

class Slanted280View extends WatchUi.WatchFace {

    // Each watch face can have a different amount of fields and placements
    // This section has to be consistent with the specific watch face
    private const TOP_FIELD = 0;
    private const UPPER_LEFT_FIELD = 1;
    private const UPPER_RIGHT_FIELD = 2;
    private const LOWER_LEFT_FIELD = 3;
    private const LOWER_RIGHT_FIELD = 4;
    private const BOTTOM_FIELD = 5;

    var fieldQty = 6;
    var field = new [fieldQty];
    var fieldValue = ["NA", "NA", "NA", "NA", "NA", "NA"];
    var topBar, topBarValue, bottomBar, bottomBarValue, progressBarSpacing;

    // Misc variables
    var H, W;
    var gridColor;
    var clock;
    var batSaverThold, batSaverTime, lastDailyRefresh;
    var dayString;
    var iconsFont, iconsColor;
    var topFieldColor, upperLeftFieldColor, upperRightFieldColor, lowerLeftFieldColor, lowerRightFieldColor, bottomFieldColor;
    var barColor, topProgressBarColor, bottomProgressBarColor;

    var isMetric;

    function initialize() {
        WatchFace.initialize();
        clock = new Clock(); 
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        W = dc.getWidth();
        H = dc.getHeight();

        iconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
        // Before loadSettings()
        clock.setDc(dc);
        dayString = "j";
        //dayString = WatchUi.loadResource(Rez.Strings.Days);

        loadSettings();
 
        // After loadSettings
        refreshBatSaverData(dc);
        //calculateDailyData(dc); 
        clock.calculatePositions(TIME_FONT, SECONDS_FONT, 30);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function loadSettings() as Void {
        
        // Loading the colors of the display
        bgColor = P_BGCOLOR;
        gridColor = P_GRIDCOLOR;
        iconsColor = P_ICONSCOLOR;
        topFieldColor = P_FIELDCOLOR;
        upperLeftFieldColor = P_FIELDCOLOR;
        upperRightFieldColor = P_FIELDCOLOR;
        lowerLeftFieldColor = P_FIELDCOLOR;
        lowerRightFieldColor = P_FIELDCOLOR;
        bottomFieldColor = P_FIELDCOLOR;
        barColor = P_BARCOLOR;
        topProgressBarColor = P_BARONCOLOR;
        bottomProgressBarColor = P_BARONCOLOR;


        // Random settings
        isMetric = P_ISMETRIC;
        

        // Most data is only refreshed every X minutes to save battery, 
        // and some data, like the date, only needs refreshing once every day
        batSaverThold = new Time.Duration(P_BATSAVERTHOLD * 60);
        //batSaverThold = new Time.Duration(Application.getApp().getProperty("RefreshMinutes") * 60);
        batSaverTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        lastDailyRefresh = batSaverTime.day;

        // Setting up the clock object, that gives time
        clock.set24Hour(P_IS24HOUR);
        clock.setColon(P_ISCOLON);
        clock.hourColor = (bgColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        clock.minutesColor = P_MINUTESCOLOR;
        clock.secondsColor = P_SECONDSCOLOR;

        // Load field values
        field[TOP_FIELD] = P_TOPFIELD;
        field[UPPER_LEFT_FIELD] = P_UPPERLEFTFIELD;
        field[UPPER_RIGHT_FIELD] = P_UPPERRIGHTFIELD;
        field[LOWER_LEFT_FIELD] = P_LOWERLEFTFIELD;
        field[LOWER_RIGHT_FIELD] = P_LOWERRIGHTFIELD;
        field[BOTTOM_FIELD] = P_BOTTOMFIELD;
        //field[UPPER_LEFT_FIELD] = Application.getApp().getProperty("UpperLeftField");
        //field[UPPER_RIGHT_FIELD] = Application.getApp().getProperty("UpperRightField");
        //field[LOWER_LEFT_FIELD] = Application.getApp().getProperty("LowerLeftField");
        //fleld[LOWER_RIGHT_FIELD] = Application.getApp().getProperty("LowerRightField");

        topBar = P_TOPBAR;
        bottomBar = P_BOTTOMBAR;
        progressBarSpacing = P_PROGRESSBARSPACING;
        //topBar = Application.getApp().getProperty("TopProgressBar");
        //bottomBar = Application.getApp().getProperty("BottomProgressBar");
        //progressBarSpacing = Application.getApp().getProperty("ProgressBarSpacing");
        
    }

    function onSettingsChanged() as Void {
        loadSettings();
        // Recule d'un an pour être certain qu'un update aura lieu
        //batSaverTime.year = batSaverTime.year.toNumber() - 1;
        //lastDailyRefresh = lastDailyRefresh - 1;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Set background color
        dc.setColor(clock.hourColor, bgColor);
        dc.clear();

        // use anti-aliased drawing for primitives (if available)
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // Some stuff needs to be refreshed only occasionnally
        //isRefreshNeeded = false;
        var tempTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var tempDuration = getTimeDiff(tempTime, batSaverTime);

        // If threshold time is exceeded, all data that is only recalculated occasionnally 
        // needs to be refreshed
        if (tempDuration.greaterThan(batSaverThold)){
            refreshBatSaverData(dc);
            batSaverTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            //isRefreshNeeded = true;
        }

        /*
        if (tempTime.day != lastDailyRefresh){
            calculateDailyData(dc);
            lastDailyRefresh = tempTime.day;
        }
        */

        // Draw the watch face
        // Time
        drawTime(dc,true);
        // Grid
        drawGrid(dc, gridColor, bgColor);	
        // Fields
        var color = Graphics.COLOR_WHITE;
        var alignment = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        drawField (fieldValue[TOP_FIELD], TOP_X, TOP_Y, topFieldColor, iconsFont, iconsColor, dc); 
        drawField (fieldValue[UPPER_LEFT_FIELD], UPPER_LEFT_X, UPPER_LEFT_Y, upperLeftFieldColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[UPPER_RIGHT_FIELD], UPPER_RIGHT_X, UPPER_RIGHT_Y, upperRightFieldColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[LOWER_LEFT_FIELD], LOWER_LEFT_X, LOWER_LEFT_Y, lowerLeftFieldColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[LOWER_RIGHT_FIELD], LOWER_RIGHT_X, LOWER_RIGHT_Y, lowerRightFieldColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[BOTTOM_FIELD], BOTTOM_X, BOTTOM_Y, bottomFieldColor, iconsFont, iconsColor, dc); 

        // Bluetooth/Notifications
        drawStatusIcon(dc, getPosFromPercent(3, W), getPosFromPercent(50, H), iconsColor, bgColor, 1, iconsFont);
        
        // Top progress Bar
        drawStatusBar(dc, getPosFromPercent(UPPER_BAR_Y, H), progressBarSpacing, topBarValue.toNumber(), barColor, topProgressBarColor, bgColor, W);
        // Bottom progress bar 
        drawStatusBar(dc, getPosFromPercent(LOWER_BAR_Y, H), progressBarSpacing, bottomBarValue.toNumber(), barColor, bottomProgressBarColor, bgColor, W);
    }

    // Draws a field with an Icon and a String
    // For watchfaces without icons, just call drawStr directly
    function drawField (fieldValue, xPos, yPos, color, iconsFont, iconsColor, dc) {
        
        if (fieldValue == null || fieldValue[0] == null || fieldValue[1] == null) {
            return;
        }
        
        var stringXPosition;
        var yPosition = getPosFromPercent(yPos, H);

        var fieldString = fieldValue[0];
        var fieldIcon = fieldValue[1]; 

        if (fieldIcon == I_NOICON){
            var stringWidth = dc.getTextWidthInPixels(fieldString, FIELD_FONT);
            stringXPosition = getStringPosition (stringWidth, xPos, W);
        }
        else{
            var iconWidth = dc.getTextWidthInPixels(fieldIcon, iconsFont);
            var stringWidth = iconWidth + 1 + dc.getTextWidthInPixels(fieldString, FIELD_FONT);
            var iconXPosition = getStringPosition (stringWidth, xPos, W);
            stringXPosition = iconXPosition + 1 + iconWidth;

            // Draw the icon
            drawStr(dc, iconXPosition, yPosition, iconsFont, iconsColor, fieldIcon, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Draw the fieldString
        drawStr(dc, stringXPosition, yPosition, FIELD_FONT, color, fieldString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    function drawTime(dc, isFull){
        
        clock.setTime();

        if(!isFull) {
            //Only seconds
  			var y = getPosFromPercent(50, H)-clock.secondsHeight/2;
  			dc.setClip(clock.secStringXPosition, y, W-clock.secStringXPosition, clock.secondsHeight);
  			dc.setColor(bgColor,bgColor);
            //dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_BLUE);
  			//clear anything that might show through from the previous time
  			dc.clear();  

            // Draw seconds only
            drawStr(dc, clock.secStringXPosition, getPosFromPercent(50, H), SECONDS_FONT, clock.secondsColor, clock.secondsString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);  	
     	} 
        // Affiche l'heure au complet
     	else {
            // Draw Time
            drawStr(dc, clock.hourStringXPosition, getPosFromPercent(TIME_Y_POS, H), TIME_FONT, clock.hourColor, clock.hoursString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            drawStr(dc, clock.minStringXPosition, getPosFromPercent(TIME_Y_POS, H), TIME_FONT, clock.minutesColor, clock.minutesString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            drawStr(dc, clock.secStringXPosition, getPosFromPercent(TIME_Y_POS, H), SECONDS_FONT, clock.secondsColor, clock.secondsString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            if (clock.is24Hour){
                drawStr(dc,getPosFromPercent(AMPM_X_POS, W), getPosFromPercent(AMPM_Y_POS, H), Graphics.FONT_SYSTEM_XTINY, clock.secondsColor, clock.amPm, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            
        }
    }

    // Draws the watch face grid
    function drawSquaredGrid(dc, lineColor, bgColor) {
        
        dc.setPenWidth(2);

        dc.setColor(Graphics.COLOR_DK_GRAY, bgColor);

        // Progess Bar high
        //dc.fillRectangle(0, getPosFromPercent(PROGBAR_UPPER_Y_POS, H), W, getPosFromPercent(PROGBAR_THICKNESS, H));
        //drawProgressBar(PROGBAR_UPPER_Y_POS,1, Graphics.COLOR_RED, Graphics.COLOR_DK_GRAY, "icon", dc);

        // Progress bar low
        //dc.fillRectangle (0, getPosFromPercent(PROGBAR_LOWER_Y_POS, H), W, getPosFromPercent(PROGBAR_THICKNESS, H));
        //drawProgressBar(PROGBAR_LOWER_Y_POS, 99, Graphics.COLOR_RED, Graphics.COLOR_DK_GRAY, "icon", dc);


        dc.setColor(lineColor, bgColor);
        // Upper vertical lines
        var x1 = 0.35 * W;
        var x2 = x1;
        var y1 = 0.16 * H;
        var y2 = 0.29 * H;
        dc.drawLine(x1, y1, x2, y2);

        x1 = 0.65 * W;
        x2 = x1;
        y1 = 0.16 * H;
        y2 = 0.29 * H;
        dc.drawLine(x1, y1, x2, y2);

         // Lower vertical lines
        x1 = 0.35 * W;
        x2 = x1;
        y1 = 0.83 * H;
        y2 = 0.7 * H;
        dc.drawLine(x1, y1, x2, y2);

        x1 = 0.65 * W;
        x2 = x1;
        y1 = 0.83 * H;
        y2 = 0.7 * H;
        dc.drawLine(x1, y1, x2, y2);

        dc.setPenWidth(1);
        
    }

    function drawWeatherGrid(dc, lineColor, bgColor) {
        dc.setColor(lineColor, bgColor);
        
        var x1 = 0;
        var x2 = 0.53 * W;
        var y1 = 0.35 * H;
        var y2 = 0.35 * H;
        dc.drawLine(x1, y1, x2, y2);

        var arcRadius = 20;
        dc.drawArc(x2 - (arcRadius*2 /3) - 2, y2 - (arcRadius*2/3), arcRadius, dc.ARC_COUNTER_CLOCKWISE, 320, 40);
 
        x1 = 0.60 * W;
        x2 = W;
        y1 = 0.35 * H;
        y2 = 0.35 * H;
        dc.drawLine(x1, y1, x2, y2);

        arcRadius = 23;
        dc.drawArc(x1 - arcRadius, y1 - (arcRadius/3) + 4, arcRadius, dc.ARC_COUNTER_CLOCKWISE, 350, 85);

        x1 = 0;
        x2 = 0.35 * W;
        y1 = 0.64 * H;
        y2 = 0.64 * H;
        dc.drawLine(x1, y1, x2, y2);

        arcRadius = 20;
        dc.drawArc(x2 - (arcRadius*2 /3) - 2, y2 + (arcRadius*2/3), arcRadius, dc.ARC_CLOCKWISE, 40, 320);

        x1 = 0.42 * W;
        x2 = W;
        y1 = 0.64 * H;
        y2 = 0.64 * H;
        dc.drawLine(x1, y1, x2, y2);

        arcRadius = 23;
        dc.drawArc(x1 - arcRadius, y1 + (arcRadius/3) -4, arcRadius, dc.ARC_CLOCKWISE, 5, 280);
    }

    function drawGrid(dc, lineColor, bgColor) {  
        // Lines positions
        var line1_y = 0.34 * H;
        var line1_x1 = 0;
        var line1_x2 = 0.50 * W;
        // line2
        var line2_y = 0.25 * H;
        var line2_x1 = 0.65 * W;
        var line2_x2 = W;
        //var line2 = [line2_x1, line2_x2, line2_y];
        // line3
        var line3_y = 0.75 * H;
        var line3_x1 = 0;
        var line3_x2 = 0.35 * W;
        //var line3 = [line3_x1, line3_x2, line3_y];
        // line4
        var line4_y = 0.66 * H;
        var line4_x1 = 0.50 * W;
        var line4_x2 = W;
        //var line4 = [line4_x1, line4_x2, line4_y];

        dc.setPenWidth(GRID_LINE_WIDTH);

        dc.setColor(lineColor, bgColor);
        dc.drawLine(line1_x1, line1_y , line1_x2, line1_y);
        dc.drawLine(line2_x1, line2_y , line2_x2, line2_y);
        dc.drawLine(line1_x2, line1_y, line2_x1 - 15, line2_y);
        dc.drawLine(line1_x2 + 15, line1_y, line2_x1, line2_y);
        dc.drawLine(line3_x1, line3_y , line3_x2, line3_y);
        dc.drawLine(line4_x1, line4_y , line4_x2, line4_y);
        dc.drawLine(line3_x2, line3_y, line4_x1 - 15, line4_y);
        dc.drawLine(line3_x2 + 15, line3_y, line4_x1, line4_y);

        dc.setPenWidth(1);

    }

    function drawProgressBar(y, percent, onColor, offColor, icon, dc) {
        // Vu que le cadran est rond
        var zeroPercentPos = getPosFromPercent(2, W);
        var barWidth = getPosFromPercent(93, W);
        var onPos = getPosFromPercent(percent, barWidth) + zeroPercentPos;
        var yPos = getPosFromPercent(y, H);
        var thickness = getPosFromPercent(PROGBAR_THICKNESS, H);

        dc.setColor(onColor, bgColor);
        dc.fillRectangle(zeroPercentPos, yPos , onPos, thickness);

        dc.setColor(offColor, bgColor);
        dc.fillRectangle(onPos + 10, yPos, W - onPos, thickness);
    }

    function refreshBatSaverData(dc){

        var systemStats = null;
        var activityMonitor = null;
        var garminWeather = null;

        var isIcons = IS_ICONS; 

        // Get values for all fields
        for (var i = 0; i < fieldQty; i++) {
            switch(field[i]) {
                // SystemStats section
                case C_BATTERY:
                    if (systemStats == null) {
                        systemStats = new SysStats(isIcons);
                    }
                    fieldValue[i] = systemStats.getBattery();
                    break;
                case C_BATTERYDAYS:
                    if (systemStats == null) {
                        systemStats = new SysStats(isIcons);
                    }
                    fieldValue[i] = systemStats.getBatteryInDays(dayString);
                    break;

                // Activity Monitor section
                case C_STEPS:
                    if (activityMonitor == null) {
                        activityMonitor = new ActivityMon(isIcons);
                    }
                    fieldValue[i] = activityMonitor.getSteps();
                    break;
                case C_CALORIES:
                    if (activityMonitor == null) {
                        activityMonitor = new ActivityMon(isIcons);
                    }
                    fieldValue[i] = activityMonitor.getCalories();
                    break;
                case C_FLOORSCLIMBED:
                    if (activityMonitor == null) {
                        activityMonitor = new ActivityMon(isIcons);
                    }
                    fieldValue[i] = activityMonitor.getFloorsClimbed();
                    break;
                case C_DISTANCE:
                    if (activityMonitor == null) {
                        activityMonitor = new ActivityMon(isIcons);
                    }
                    fieldValue[i] = activityMonitor.getDistance(isMetric);
                    break;

                // Garmin Weather section
                case C_TEMPERATURE:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getTemperature();
                    break;
                case C_HUMIDITY:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getHumidity();
                    break;
                case C_DEWPOINT:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getDewPoint();
                    break;
                case C_CITY:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getCity();
                    break;
                case C_WIND:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getWind();
                    break;
                case C_WINDCHILL:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getWindchill();
                    break;
                case C_TEMPPLUSFEELSLIKE:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getTemperatureAndFeelsLike();
                    break;
                case C_WINDPLUSWINDCHILL:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getWindAndWindchill();
                    break;
                case C_HUMIDITYPLUSHUMIDEX:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getHumidityAndHumidex();
                    break;
                case C_DEWPOINTPLUSHUMIDEX:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getDewpointAndHumidex();
                    break;
                case C_THREEHOURFORECAST:
                    // static function call
                    fieldValue[i] = GarminWeather.getThreeHourPrecipitation(isIcons);
                    break;
                case C_SUNEVENTS:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                    }
                    fieldValue[i] = garminWeather.getSunEvents();
                    break;

                // Misc section
                case C_DATE:
                    fieldValue[i] = getDate(batSaverTime, isIcons);
                    break;
                case C_BODYBATTERY:
                    fieldValue[i] = getBodyBatteryField(isIcons);
                    break;
                case C_PRESSURE:
                    fieldValue[i] = getBaroPressureField(isIcons);
                    break;
                case C_ALTITUDE:
                    fieldValue[i] = getAltitudeField(isMetric, isIcons);
                    break;
                default:
                    break;
            }
        }

        // Get values for progress bars
        // Top Bar
        topBarValue = getBarValue(topBar);

        // BottomBar
        bottomBarValue = getBarValue(bottomBar);
    }

    function getBarValue(barSetting){
        var returnValue = 0;

        switch (barSetting){
            case C_BATTERY:
                var systemStats = System.getSystemStats();
                returnValue = (systemStats != null && systemStats.battery != null) ? systemStats.battery : 0;
                break;

            case C_BODYBATTERY:
                var bodyBattery = getBodyBattery();
                returnValue = bodyBattery != null ? bodyBattery : 0;
                break;

            case C_PRESSURE:
                var baroPressure = getBaroPressure();
                var baroPressurePct = getBaroPressurePercent(baroPressure);
                returnValue = baroPressurePct != null ? baroPressurePct : 0;
                break;

            case C_STEPS:
                returnValue = 0;
                var activityMonitor = ActivityMonitor.getInfo();
                if (activityMonitor.steps != null && activityMonitor.stepGoal != null) {
                    returnValue = activityMonitor.steps * 100 / activityMonitor.stepGoal;
                }
                break;

            default:
                returnValue = 0;
                break;
        }

        return returnValue;
    }

}
