using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Time;

class Slanted280View extends WatchUi.WatchFace {

    // Each watch face can have a different amount of fields and placements
    // This section has to be consistent with the specific watch face
    private const TOP_FIELD = 0;
    private const UPPER_LEFT_FIELD = 1;
    private const UPPER_RIGHT_FIELD = 2;
    private const LOWER_LEFT_FIELD = 3;
    private const LOWER_RIGHT_FIELD = 4;
    private const BOTTOM_FIELD = 5;

    // Color variables
    var bgColor, gridColor, iconsColor;
    var mainColor, secondaryColor;
    var secondsColor, minutesColor, hourColor;
    var barColor, topProgressBarColor, bottomProgressBarColor;

    // Fields
    var fieldQty = 6;
    var field = new [fieldQty];
    var fieldValue = [ ["NA", I_NOICON], ["NA", I_NOICON], ["NA", I_NOICON], ["NA", I_NOICON], ["NA", I_NOICON], ["NA", I_NOICON] ];
    // Progress bars
    var topBar, topBarValue, bottomBar, bottomBarValue, progressBarSpacing;

    // Logic stuff and settings
    var batSaverThold, batSaverTime, lastDailyRefresh;
    var showSeconds, isMetric, is24Hour;
    var dayString;
    var iconsFont;
    var H, W;

    var isWeatherNotOk = false;
    var refreshWeather = 5; // Counter for weather not loading correctly after reboot

    // HR related
    var hrClipCoordinates; //clipXPosition, clipYPosition, clipXSize, clipYSize
    var hrCoordinates; // iconXPosition, strXPosition, YPosition, strFont, strColor
    var isHeartRate = false;
    var isEconomyMode = false;
    var isTooManyHrFields = false;
    var wasHeartRate = false;
    var isHrRefreshNeeded = false;
    var hrFieldNumber = -1;

    // Time related stuff
    public var amPm;

    public var hourStringXPosition;
    public var minStringXPosition;
    public var secStringXPosition;
    public var hoursString;
    public var minutesString;
    public var secondsString;

    public var secondsHeight;
    

    function initialize() {
        WatchFace.initialize();
        //clock = new Clock(); 
    }

    // Load your resources here
    function onLayout(dc) as Void {
        W = dc.getWidth();
        H = dc.getHeight();

        iconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
        // Before loadSettings()
        //clock.setDc(dc);
        dayString = WatchUi.loadResource(Rez.Strings.Days);

        loadSettings();
 
        // After loadSettings
        lastDailyRefresh -= 1; // Force a daily refresh as watch face is loading in this method
        refreshBatSaverData(dc);
        //clock.calculatePositions(TIME_FONT, SECONDS_FONT, 30); 
        
        // Calculer les positions de l'horloge ici
        //Hour position
        
        var tempString = IS_COLON ? "88:" : "88";
        var stringWidth = dc.getTextWidthInPixels(tempString, TIME_FONT);
        hourStringXPosition = getStringPosition (stringWidth, HOUR_X_POS_PERC, W);

        //Minute position
        tempString = "88";
        var minStringWidth = dc.getTextWidthInPixels(tempString, TIME_FONT);
        minStringXPosition = hourStringXPosition + 1 + stringWidth;

        // Seconds position
        secStringXPosition = minStringXPosition + 1 + minStringWidth;

        // Seconds height
        secondsHeight = dc.getFontHeight(SECONDS_FONT);

        // HR Related
        if (isHeartRate) {
            calculateHrCoordinates(dc);
        }
        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function loadSettings() as Void {

        // HR related
        wasHeartRate = isHeartRate;
        isHeartRate = false;
        isHrRefreshNeeded = false;
        
        // Theme colors - Makes the whole display change in one setting
        // unless specifics are overridden
        var theme = Application.getApp().getProperty("ThemeColor");
        var themeColors = getThemeColors(theme);
        
        // Color overrides
        // Reference to theme colors
        // [MinutesColor, SecondsColor, MainColor, SecondaryColor, GridColor, IconsColor, TopBarColor, BottomBarColor]
        minutesColor = getColorCode(Application.getApp().getProperty("MinutesColor"), themeColors[0]);
        secondsColor = getColorCode(Application.getApp().getProperty("SecondsColor"), themeColors[1]);
        mainColor = getColorCode(Application.getApp().getProperty("MainFieldColor"), themeColors[2]);
        secondaryColor = getColorCode(Application.getApp().getProperty("SecondaryFieldColor"), themeColors[3]);
        gridColor = getColorCode(Application.getApp().getProperty("GridColor"), themeColors[4]);
        iconsColor = getColorCode(Application.getApp().getProperty("IconsColor"), themeColors[5]);
        topProgressBarColor = getColorCode(Application.getApp().getProperty("TopProgressBarColor"), themeColors[6]);
        bottomProgressBarColor = getColorCode(Application.getApp().getProperty("BottomProgressBarColor"), themeColors[7]);
        bgColor = getColorCode(themeColors[8], themeColors[8]);
        hourColor = (bgColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        barColor = (bgColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY;

        // Load field values     
        field[TOP_FIELD] = Application.getApp().getProperty("TopField");
        field[UPPER_LEFT_FIELD] = Application.getApp().getProperty("UpperLeftField");
        field[UPPER_RIGHT_FIELD] = Application.getApp().getProperty("UpperRightField");
        field[LOWER_LEFT_FIELD] = Application.getApp().getProperty("LowerLeftField");
        field[LOWER_RIGHT_FIELD] = Application.getApp().getProperty("LowerRightField");
        field[BOTTOM_FIELD] = Application.getApp().getProperty("BottomField");

        topBar = Application.getApp().getProperty("TopProgressBar");
        bottomBar = Application.getApp().getProperty("BottomProgressBar");
        progressBarSpacing = Application.getApp().getProperty("ProgressBarSpacing");

        // Random settings
        isMetric = Application.getApp().getProperty("Units") == 0 ? true : false;
        is24Hour = Application.getApp().getProperty("TimeDisplay") == 0 ? true : false;
        showSeconds = Application.getApp().getProperty("ShowSeconds") == 1 ? true : false;
        
        // Most data is only refreshed every X minutes to save battery, 
        // and some data, like the date, only needs refreshing once every day
        batSaverThold = new Time.Duration(Application.getApp().getProperty("RefreshMinutes") * 60);
        batSaverTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        lastDailyRefresh = batSaverTime.day;
        
        // HR related
        checkHrFields();
        if ( (isHeartRate) || (wasHeartRate && !isHeartRate) ) {
            isHrRefreshNeeded = true;
        }
    }

    function onSettingsChanged() as Void {
        loadSettings();
        // Recule d'un an pour être certain qu'un update aura lieu
        batSaverTime.year = batSaverTime.year.toNumber() - 1;
        lastDailyRefresh = lastDailyRefresh - 1;
    }

     function checkHrFields() {
        // Make sure there is only one HR field "on"
        for (var i = 0; i < fieldQty; i++) {
            switch(field[i]) {
                case C_HEARTRATE:
                    if (isHeartRate) {
                        // If there is already a HR field, the next one is switched to none
                        // Only one is supported
                        field[i] = C_NONE;
                    }
                    hrFieldNumber = i;
                    isHeartRate = true;
                    break;
            }
        }
    }

    function calculateHrCoordinates(dc) {
        var font = Graphics.FONT_SYSTEM_TINY;
        var clipHeight = dc.getFontHeight(font);
        var hrString = "88";
        var iconWidth = dc.getTextWidthInPixels(I_HEARTRATE, iconsFont);
        var strWidth = iconWidth + 1 + dc.getTextWidthInPixels(hrString, font);

        if (hrFieldNumber == TOP_FIELD) {
            var iconXPosition = getStringPosition (strWidth, TOP_X, W);
            var strXPosition = iconXPosition + 1 + iconWidth;
            var yPos = getPosFromPercent(TOP_Y, H);
            //clipXPosition, clipYPosition, clipXSize, clipYSize
            hrClipCoordinates = [(iconXPosition - iconWidth/2), (yPos-clipHeight/2), strWidth + 1 + iconWidth, clipHeight ];
            // iconXPosition, strXPosition, YPosition, strFont, strColor
            hrCoordinates = [iconXPosition, strXPosition, yPos, font, secondaryColor];  
        }
        else if (hrFieldNumber == UPPER_LEFT_FIELD) {
            var iconXPosition = getStringPosition (strWidth, UPPER_LEFT_X, W);
            var strXPosition = iconXPosition + 1 + iconWidth;
            var yPos = getPosFromPercent(UPPER_LEFT_Y, H);
            //clipXPosition, clipYPosition, clipXSize, clipYSize
            hrClipCoordinates = [(iconXPosition - iconWidth/2), (yPos-clipHeight/2), strWidth + 1 + iconWidth, clipHeight ];
            // iconXPosition, strXPosition, YPosition, strFont, strColor
            hrCoordinates = [iconXPosition, strXPosition, yPos, font, secondaryColor];  
        }
        else if (hrFieldNumber == UPPER_RIGHT_FIELD) {
            var iconXPosition = getStringPosition (strWidth, UPPER_RIGHT_X, W);
            var strXPosition = iconXPosition + 1 + iconWidth;
            var yPos = getPosFromPercent(UPPER_RIGHT_Y, H);
            //clipXPosition, clipYPosition, clipXSize, clipYSize
            hrClipCoordinates = [(iconXPosition - iconWidth/2), (yPos-clipHeight/2), strWidth + 1 + iconWidth, clipHeight ];
            // iconXPosition, strXPosition, YPosition, strFont, strColor
            hrCoordinates = [iconXPosition, strXPosition, yPos, font, secondaryColor];  
        }
        else if (hrFieldNumber == LOWER_LEFT_FIELD) {
            var iconXPosition = getStringPosition (strWidth, LOWER_LEFT_X, W);
            var strXPosition = iconXPosition + 1 + iconWidth;
            var yPos = getPosFromPercent(LOWER_LEFT_Y, H);
            //clipXPosition, clipYPosition, clipXSize, clipYSize
            hrClipCoordinates = [(iconXPosition - iconWidth/2), (yPos-clipHeight/2), strWidth + 1 + iconWidth, clipHeight ];
            // iconXPosition, strXPosition, YPosition, strFont, strColor
            hrCoordinates = [iconXPosition, strXPosition, yPos, font, secondaryColor];  
        }
        else if (hrFieldNumber == LOWER_RIGHT_FIELD) {
            var iconXPosition = getStringPosition (strWidth, LOWER_RIGHT_X, W);
            var strXPosition = iconXPosition + 1 + iconWidth;
            var yPos = getPosFromPercent(LOWER_RIGHT_Y, H);
            //clipXPosition, clipYPosition, clipXSize, clipYSize
            hrClipCoordinates = [(iconXPosition - iconWidth/2), (yPos-clipHeight/2), strWidth + 1 + iconWidth, clipHeight ];
            // iconXPosition, strXPosition, YPosition, strFont, strColor
            hrCoordinates = [iconXPosition, strXPosition, yPos, font, secondaryColor];  
        }
        else if (hrFieldNumber == BOTTOM_FIELD) {
            var iconXPosition = getStringPosition (strWidth, BOTTOM_X, W);
            var strXPosition = iconXPosition + 1 + iconWidth;
            var yPos = getPosFromPercent(BOTTOM_Y, H);
            //clipXPosition, clipYPosition, clipXSize, clipYSize
            hrClipCoordinates = [(iconXPosition - iconWidth/2), (yPos-clipHeight/2), strWidth + 1 + iconWidth, clipHeight ];
            // iconXPosition, strXPosition, YPosition, strFont, strColor
            hrCoordinates = [iconXPosition, strXPosition, yPos, font, secondaryColor];  
        }

        isHrRefreshNeeded = false;
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Necessary for refreshing after updates while in low power mode
        dc.clearClip();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Set background color
        dc.setColor(hourColor, bgColor);
        dc.clear();

        // use anti-aliased drawing for primitives (if available)
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // HR related
        // This should be done in loadSettings, but dc is not available there
        // So I'm doing it here
        if (isHrRefreshNeeded) {
            calculateHrCoordinates(dc);
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
        else if (isWeatherNotOk && refreshWeather > -1) {
            var settings = System.getDeviceSettings();
            if (settings.phoneConnected) {
                    refreshBatSaverData(dc);
                    refreshWeather--;
                }
            } 
        }

        // Draw the watch face
        // Time
        drawTime(dc,true);
        // Grid
        drawGrid(dc, gridColor, bgColor);	
        // Fields
        var color = Graphics.COLOR_WHITE;
        var alignment = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        drawField (fieldValue[TOP_FIELD], TOP_X, TOP_Y, secondaryColor, iconsFont, iconsColor, dc); 
        drawField (fieldValue[UPPER_LEFT_FIELD], UPPER_LEFT_X, UPPER_LEFT_Y, secondaryColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[UPPER_RIGHT_FIELD], UPPER_RIGHT_X, UPPER_RIGHT_Y, mainColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[LOWER_LEFT_FIELD], LOWER_LEFT_X, LOWER_LEFT_Y, mainColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[LOWER_RIGHT_FIELD], LOWER_RIGHT_X, LOWER_RIGHT_Y, secondaryColor, iconsFont, iconsColor, dc);
        drawField (fieldValue[BOTTOM_FIELD], BOTTOM_X, BOTTOM_Y, secondaryColor, iconsFont, iconsColor, dc); 

        // Bluetooth/Notifications
        drawStatusIcon(dc, getPosFromPercent(3, W), getPosFromPercent(50, H), iconsColor, bgColor, 1, iconsFont);
        
        // Top progress Bar
        drawStatusBar(dc, getPosFromPercent(UPPER_BAR_Y, H), progressBarSpacing, topBarValue.toNumber(), barColor, topProgressBarColor, bgColor, W);
        // Bottom progress bar 
        drawStatusBar(dc, getPosFromPercent(LOWER_BAR_Y, H), progressBarSpacing, bottomBarValue.toNumber(), barColor, bottomProgressBarColor, bgColor, W);

        // HR related
        if ( isHeartRate ) {
            drawHeartRate(hrClipCoordinates, hrCoordinates,  iconsFont, iconsColor, isEconomyMode, bgColor, dc);
        }
    
    }

    // 
    function onPartialUpdate(dc) as Void{
        // HR related
        if (isHeartRate && !showSeconds) {
            drawHeartRate(hrClipCoordinates, hrCoordinates,  iconsFont, iconsColor, isEconomyMode, bgColor, dc);
        }
        
        if (showSeconds) {
            drawTime(dc,false); 
        }
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
        isEconomyMode = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isEconomyMode = true;
    }

    function drawTime(dc, isFull){
        
        //clock.setTime();
        var clockTime = System.getClockTime();
        var isColon = IS_COLON;
        secondsString = clockTime.sec.format("%02d");

        if (is24Hour){
            hoursString = isColon ? clockTime.hour.format("%02d") + ":" : clockTime.hour.format("%02d") ;  
        }
        else{
            var hourTemp = clockTime.hour;
            if (clockTime.hour == 0) {
                amPm = "AM";
                hourTemp = 12;
            } else if (clockTime.hour < 12) {
                amPm = "AM";
            } else if (clockTime.hour == 12) {
                amPm = "PM";
            } else if (clockTime.hour > 12) {
                amPm = "PM";
                hourTemp -= 12;
            }
            hoursString = isColon ? hourTemp.format("%02d")  + ":": hourTemp.format("%02d");
        }

        minutesString = clockTime.min.format("%02d");        

        /*
        if(!isFull) {
            //Only seconds
  			var y = getPosFromPercent(SEC_Y_POS, H)-clock.secondsHeight/2;
  			dc.setClip(clock.secStringXPosition, y, W-clock.secStringXPosition, clock.secondsHeight);
  			dc.setColor(bgColor,bgColor);
            //dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_BLUE);
  			//clear anything that might show through from the previous time
  			dc.clear();  

            // Draw seconds only
            drawStr(dc, clock.secStringXPosition, getPosFromPercent(42, H), SECONDS_FONT, clock.secondsColor, clock.secondsString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);  	
     	} 
        // Affiche l'heure au complet
     	else {
            // Draw Time
            drawStr(dc, clock.hourStringXPosition, getPosFromPercent(TIME_Y_POS, H), TIME_FONT, clock.hourColor, clock.hoursString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            drawStr(dc, clock.minStringXPosition, getPosFromPercent(TIME_Y_POS, H), TIME_FONT, clock.minutesColor, clock.minutesString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            if (showSeconds) {
                drawStr(dc, clock.secStringXPosition, getPosFromPercent(SEC_Y_POS, H), SECONDS_FONT, clock.secondsColor, clock.secondsString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            if (!clock.is24Hour){
                drawStr(dc, clock.secStringXPosition, getPosFromPercent(AMPM_Y_POS, H), Graphics.FONT_SYSTEM_XTINY, clock.secondsColor, clock.amPm, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            
        } 
        */
        if(!isFull) {
            //Only seconds
  			var y = getPosFromPercent(SEC_Y_POS, H)-secondsHeight/2;
  			dc.setClip(secStringXPosition, y, W-secStringXPosition, secondsHeight);
  			dc.setColor(bgColor,bgColor);
            //dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_BLUE);
  			//clear anything that might show through from the previous time
  			dc.clear();  

            // Draw seconds only
            drawStr(dc, secStringXPosition, getPosFromPercent(42, H), SECONDS_FONT, secondsColor, secondsString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);  	
     	} 
        // Affiche l'heure au complet
     	else {
            // Draw Time
            drawStr(dc, hourStringXPosition, getPosFromPercent(TIME_Y_POS, H), TIME_FONT, hourColor, hoursString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            drawStr(dc, minStringXPosition, getPosFromPercent(TIME_Y_POS, H), TIME_FONT, minutesColor, minutesString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            if (showSeconds) {
                drawStr(dc, secStringXPosition, getPosFromPercent(SEC_Y_POS, H), SECONDS_FONT, secondsColor, secondsString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            if (!is24Hour){
                drawStr(dc, secStringXPosition, getPosFromPercent(AMPM_Y_POS, H), Graphics.FONT_SYSTEM_XTINY, secondsColor, amPm, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
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

        isWeatherNotOk = false;

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
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getTemperature();
                    break;
                case C_HUMIDITY:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getHumidity();
                    break;
                case C_DEWPOINT:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getDewPoint();
                    break;
                case C_CITY:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getCity();
                    break;
                case C_WIND:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getWind();
                    break;
                case C_WINDCHILL:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getWindchill();
                    break;
                case C_TEMPPLUSFEELSLIKE:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getTemperatureAndFeelsLike();
                    break;
                case C_WINDPLUSWINDCHILL:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getWindAndWindchill();
                    break;
                case C_HUMIDITYPLUSHUMIDEX:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getHumidityAndHumidex();
                    break;
                case C_DEWPOINTPLUSHUMIDEX:
                    if (garminWeather == null) {
                        garminWeather = new GarminWeather(isMetric, isIcons);
                        if (garminWeather.getCurrentConditions() == false) {
                            isWeatherNotOk = true;
                        }
                    }
                    fieldValue[i] = garminWeather.getDewpointAndHumidex();
                    break;
                case C_THREEHOURFORECAST:
                    // static function call
                    fieldValue[i] = GarminWeather.getThreeHourPrecipitation(isIcons);
                    break;
                case C_SUNEVENTS:
                    if (lastDailyRefresh != batSaverTime.day) {
                        if (garminWeather == null) {
                            garminWeather = new GarminWeather(isMetric, isIcons);
                            if (garminWeather.getCurrentConditions() == false) {
                                isWeatherNotOk = true;
                            }
                        }
                        fieldValue[i] = garminWeather.getSunEvents();
                    }
                    break;
                

                // Misc section
                case C_DATE:
                    if (lastDailyRefresh != batSaverTime.day) {
                        fieldValue[i] = getDate(batSaverTime, isIcons);
                    }
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

                case C_HEARTRATE:
                case C_NONE:
                    fieldValue[i] = ["", I_NOICON];
                    break;
                default:
                    break;
            }
        }

        // If one day has passed, change date
        if (lastDailyRefresh != batSaverTime.day) {
            lastDailyRefresh = batSaverTime.day;
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
