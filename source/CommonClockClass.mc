import Toybox.Graphics;
class Clock {
    private var _dc;
    private var H;
    private var W;
    private var _isColon;
    
    public var is24Hour;
    public var amPm;

    public var hourColor;
    public var minutesColor;
    public var secondsColor;

    public var hourStringXPosition;
    public var minStringXPosition;
    public var secStringXPosition;
    public var hoursString;
    public var minutesString;
    public var secondsString;

    public var secondsHeight;
    
    public function initialize() {
        is24Hour    = false;
        amPm        = "";
        _isColon     = true;
    }

    public function setDc(dc as Dc) {
        _dc = dc;
        W = _dc.getWidth();
        H = _dc.getHeight();
    }

    public function set24Hour(pIs24Hour) {
        is24Hour = pIs24Hour;
    }

    public function setColon(isColon) {
        _isColon = isColon;
    }

    public function calculatePositions (pHourFont, pSecondsFont, pHourXPosPerc) {  
        //Hour position
        var tempString = _isColon ? "88:" : "88";
        var stringWidth = _dc.getTextWidthInPixels(tempString, pHourFont);
        hourStringXPosition = getStringPosition (stringWidth, pHourXPosPerc, W);

        //Minute position
        tempString = "88";
        var minStringWidth = _dc.getTextWidthInPixels(tempString, pHourFont);
        minStringXPosition = hourStringXPosition + 1 + stringWidth;

        // Seconds position
        secStringXPosition = minStringXPosition + 1 + minStringWidth;

        // Seconds height
        secondsHeight = _dc.getFontHeight(pSecondsFont);
    }

    public function setTime() {
        var clockTime = System.getClockTime();

        /*
        // From the API docs, getClockTime does not return null
        if (clockTime == null) {
            hoursString = "NA";
            minutesString = "NA";
            secondsString = "NA";
        }*/

        secondsString = clockTime.sec.format("%02d");

        if (is24Hour){
            hoursString = _isColon ? clockTime.hour.format("%02d") + ":" : clockTime.hour.format("%02d") ;  
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
            } else if (clockTime.hour > 12){
                amPm = "PM";
                hourTemp -= 12;
            }
            hoursString = _isColon ? hourTemp.format("%02d")  + ":": hourTemp.format("%02d");
        }

        minutesString = clockTime.min.format("%02d");
    }

}

