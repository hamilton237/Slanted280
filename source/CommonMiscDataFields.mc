function getDate(batSaverTime, isIcons) {
    var returnString = batSaverTime.day_of_week + " " + batSaverTime.day;

    if (isIcons) {
        return [returnString, I_NOICON];
    }
    else {
        return returnString;
    }
}

function getBodyBatteryField(isIcons) {
    var bodyBattery = getBodyBattery();

    var returnString = bodyBattery + "%";

    if (isIcons) {
        return [returnString, I_BODYBATTERY];
    }
    else {
        return returnString;
    }
}

function getBaroPressureField(isIcons) {
    var baroPressure = getBaroPressure();

    var returnString = baroPressure.format("%.0f");

    if (isIcons) {
        return [returnString, I_PRESSURE];
    }
    else {
        return returnString;
    }
}

function getAltitudeField(isMetric, isIcons) {
    var returnString;
    var altitude = getAltitude();
    if (isMetric) {
        returnString = altitude.format("%.0f");
    }
    else {
        var feet = altitude * 3.28084;
        returnString = feet.format("%.0f");
    }

    if (isIcons) {
        return [returnString, I_ALTITUDE];
    }
    else {
        return returnString;
    }
}

function getBaroPressure(){

	var baroPressure = 0;

	// Check device for SensorHistory compatibility
	if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
		var baroIterator = Toybox.SensorHistory.getPressureHistory({:period => 1});
		var baroIt = baroIterator.next();
		
		if ((baroIt != null) && (baroIt.data != null)) {
			var baro = baroIt.data;
            baroPressure = baro / 100; //pa -> millibars
        }
	}

	return baroPressure;
}

function getBaroPressurePercent(baroPressure){

	var high = 1013 + 50; // High pressure (100%) = 1050 mb
	var low = 1013 - 50; // Low pressure (0%) = 950 mb
	
	if (baroPressure > high) {baroPressure = high;}
	if (baroPressure < low) {baroPressure = low;}
	var baroPressurePct = baroPressure - low;

	return baroPressurePct;

}

function getAltitude(){

	var altitude = 0;

	// Check device for SensorHistory compatibility
	if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
		var altIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
		var altIt = altIterator.next();
		
		if ((altIt != null) && (altIt.data != null)) {
			altitude = altIt.data;
		}
	}

	return altitude;
}

function getDewPoint(temp, humidity) {
	var dewPoint = 0;
	var a1 = 17.625;
	var b1 = 243.04;
			
	dewPoint = (b1 * (Math.ln(humidity / 100.0) + (a1 * temp)/(b1 + temp ))) / (a1 - Math.ln( humidity / 100.0) - a1 * temp/( b1 + temp ));

	return dewPoint;
}

function getBodyBattery() {
	
	var bodyBattery = 0;

	// Check device for SensorHistory compatibility
	if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
		// Set up the method with parameters
		var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({ :Number => 1 });
		var bodyBatteryIt = bbIterator.next();
	
		if (bodyBatteryIt != null && bodyBatteryIt.data != null) {
            bodyBattery = bodyBatteryIt.data;
        }	
	}
	return bodyBattery.format("%.0f");
}
