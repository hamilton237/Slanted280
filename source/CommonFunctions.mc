using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.System;
using Toybox.Graphics;

// Si on veut la string au milieu, desiredPosition est 50
function getStringPosition (stringWidth, desiredPosition, watchWidth){
    var stringPosition = (desiredPosition * watchWidth / 100) - (stringWidth / 2);
    return stringPosition;
    //return Math.round(stringPosition * 100 / watchWidth);
}

// Size is either height or width
function getPosFromPercent(percent, size){
    return percent * size / 100;
}

// Returns duration time in seconds between 2 times
function getTimeDiff(time1, time2){
    var options1 = {
        :year   => time1.year,
        :month  => time1.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
        :day    => time1.day,
        :hour   => time1.hour,
        :minute => time1.min,
        :second => time1.sec
    };
    var date1 as Gregorian = Gregorian.moment(options1); 

    var options2 = {
        :year   => time2.year,
        :month  => time2.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
        :day    => time2.day,
        :hour   => time2.hour,
        :minute => time2.min,
        :second => time2.sec
    };
    var date2 = Gregorian.moment(options2); 

    var result = date1.subtract(date2);

    return result;

}

/*
function drawMessagesIcon(dc, x, y, color){
	dc.setColor(color, Graphics.COLOR_BLACK);
	dc.setPenWidth(2);

	dc.drawRectangle(x-5, y-6, 20, 12);

	dc.drawLine(x-4, y-5, x+5, y);
	dc.drawLine(x+14, y-5, x+5, y);
	
	dc.setPenWidth(1);
}
*/

function drawBluetoothIcon(dc, x, y, color, bgColor){
	dc.setColor(color, bgColor);
	dc.setPenWidth(2);

	// Vertical line
	var x1 = x + 5;
	var x2 = x + 5;
	var y1 = y - 10;
	var y2 = y + 10;
	
	dc.drawLine(x1, y1, x2, y2);

	// Lower long diag
	x1 = x;
	x2 = x + 10;
	y1 = y - 5;
	y2 = y + 5;
	dc.drawLine(x1, y1, x2, y2);

	// Upper long diag
	x1 = x;
	x2 = x + 10;
	y1 = y + 5;
	y2 = y - 5;
	dc.drawLine(x1, y1, x2, y2);

	// Upper short diag
	x1 = x + 5;
	x2 = x + 10;
	y1 = y - 10;
	y2 = y - 5;
	dc.drawLine(x1, y1, x2, y2);

	// Lower short diag
	x1 = x + 5;
	x2 = x + 10;
	y1 = y + 10;
	y2 = y + 5;
	dc.drawLine(x1, y1, x2, y2);

	dc.setPenWidth(1);
}

function convertMsToSpeed(mps, isMetric) {
	// 1 m/s = 3.6 km/h
	// 1 m/s = 2.237 mph
	var speed = isMetric ? mps*3.6 : mps*2.237;
	return speed;
}

function celciusToFarenheit(celcius){
	return (celcius * 1.8) + 32;
}

function drawStatusIcon(dc, x, y, color, bgColor, dimension, iconsFont){
	var settings = System.getDeviceSettings();

	if (settings.phoneConnected){
		if (settings.notificationCount > 0){
			//drawMessagesIcon(dc, x, y, color);
			drawStr(dc, x+4, y+5, iconsFont, color, I_NOTIFICATIONS, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
		else{
			drawBluetoothIcon(dc, x, y, Graphics.COLOR_BLUE, bgColor);
		}
	}
}

 // Draws string with all parameters in 1 call. 
function drawStr(dc, x, y, font, color, str, alignment) {
	dc.setColor(color, Graphics.COLOR_TRANSPARENT);
	dc.drawText(x, y, font, str, alignment);
}