import Toybox.Graphics;
class Clock {
    private var dc;
    private var H;
    private var W;
    private var isColon;
    
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
        isColon     = true;
    }

    public function setDc(pDc as Dc) {
        dc = pDc;
        W = dc.getWidth();
        H = dc.getHeight();
    }

    public function set24Hour(pIs24Hour) {
        is24Hour = pIs24Hour;
    }

    public function setColon(pIsColon) {
        isColon = pIsColon;
    }

    public function calculatePositions (pHourFont, pSecondsFont, pHourXPosPerc) {  
        //Hour position
        var tempString = isColon ? "88:" : "88";
        var stringWidth = dc.getTextWidthInPixels(tempString, pHourFont);
        hourStringXPosition = getStringPosition (stringWidth, pHourXPosPerc, W);

        //Minute position
        tempString = "88";
        var minStringWidth = dc.getTextWidthInPixels(tempString, pHourFont);
        minStringXPosition = hourStringXPosition + 1 + stringWidth;

        // Seconds position
        secStringXPosition = minStringXPosition + 1 + minStringWidth;

        // Seconds height
        secondsHeight = dc.getFontHeight(pSecondsFont);
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
            hoursString = isColon ? clockTime.hour.format("%02d") + ":" : clockTime.hour.format("%02d") ;  
        }
        else{
            var hourTemp = clockTime.hour;
            if (clockTime.hour == 0) {
                amPm = "A";
                hourTemp = 12;
            } else if (clockTime.hour < 12) {
                amPm = "A";
            } else if (clockTime.hour == 12) {
                amPm = "P";
            } else if (clockTime.hour > 12){
                amPm = "P";
                hourTemp -= 12;
            }
            hoursString = isColon ? hourTemp.format("%02d")  + ":": hourTemp.format("%02d");
        }

        minutesString = clockTime.min.format("%02d");
    }

}

