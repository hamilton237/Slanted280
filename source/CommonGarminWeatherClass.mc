using Toybox.Weather;
using Toybox.Test;

class GarminWeather {
    private var _garminWeather;
    private var _hourlyForecast;
    private var _isMetric;
    private var _isIcons;

    public function initialize(isMetric, isIcons){
        _isMetric = isMetric;
        _isIcons = isIcons;
        _garminWeather = Weather.getCurrentConditions();
        _hourlyForecast = null;
    }

    public function getCurrentConditions() as Toybox.Lang.Boolean{
        var returnValue = true;

        if (_garminWeather == null) {
            _garminWeather = Weather.getCurrentConditions();
            if (_garminWeather == null) {
                returnValue=false;
            }
        }
        return returnValue;
    }

    public function getHourlyForecast() {
        if (_garminWeather != null) {
            _hourlyForecast = Weather.getHourlyForecast();
        }
    }

    public function getTemperature() {
        var returnString = "NA";
        if (_garminWeather != null && _garminWeather.temperature != null) {
            var temp = _isMetric ? _garminWeather.temperature : celciusToFarenheit(_garminWeather.temperature);
            returnString = temp.format("%.0f") + DEGREE_SYMBOL;
        }
        
        if (_isIcons) {
            return [returnString, I_TEMPERATURE];
        }
        else {
            return returnString;
        }
    }

    public function getTemperatureAndFeelsLike() {

        var returnString = "NA";

        if (_garminWeather != null && _garminWeather.temperature != null && _garminWeather.feelsLikeTemperature != null) {
            var temp = _isMetric ? _garminWeather.temperature : celciusToFarenheit(_garminWeather.temperature);
            var feelsLike = _isMetric ? _garminWeather.feelsLikeTemperature : celciusToFarenheit(_garminWeather.feelsLikeTemperature);
            returnString = temp.format("%.0f") + "/" + feelsLike.format("%.0f");
        }     
        
        if (_isIcons) {
            return [returnString, I_TEMPERATURE];
        }
        else {
            return returnString;
        }
    }

    public function getHumidity() {
         var returnString = (_garminWeather != null && _garminWeather.relativeHumidity != null )
                ? _garminWeather.relativeHumidity.format("%.0f") + "%" 
                : "NA";

        if (_isIcons) {
            return [returnString, I_HUMIDITY];
        }
        else {
            return returnString;
        }
    }

    public function getDewPoint() {
        var returnString = "NA";
        if (_garminWeather != null && _garminWeather.relativeHumidity != null && _garminWeather.temperature != null) {
            var dp = calcDewPoint(_garminWeather.temperature, _garminWeather.relativeHumidity);
            var dpUnit = _isMetric ? dp : celciusToFarenheit(dp);
            returnString = dpUnit.format("%.0f") + DEGREE_SYMBOL;
        }
        
        if (_isIcons) {
            return [returnString, I_DEWPOINT];
        }
        else {
            return returnString;
        }
    }

    public function getWindAndWindchill() {
        var returnString = "NA";
        if (_garminWeather != null && _garminWeather.windSpeed != null && _garminWeather.temperature != null) {
            var windSpeed = convertMsToSpeed(_garminWeather.windSpeed, _isMetric);
            var metricWindChill = calcWindchill (_garminWeather.temperature, windSpeed);
            var windChill = _isMetric ? metricWindChill : celciusToFarenheit(metricWindChill);
            returnString = windSpeed.format("%.0f") + "/" + windChill.format("%.0f");
        }

        if (_isIcons) {
            return [returnString, I_WINDCHILL];
        }
        else {
            return returnString;
        }
    }

    public function getHumidityAndHumidex() {
        var humid = (_garminWeather != null && _garminWeather.relativeHumidity != null )
                        ? _garminWeather.relativeHumidity.format("%.0f") + "%" 
                        : "NA";
        var humidex = (_garminWeather != null && _garminWeather.relativeHumidity != null && _garminWeather.temperature != null)
                        ? calcHumidex(_garminWeather.temperature, _garminWeather.relativeHumidity).format("%.0f")
                        : "NA";
        humidex = _isMetric ? humidex : celciusToFarenheit(humidex.toNumber()).format("%.0f");
        var returnString = humid + "/" + humidex;
        
        if (_isIcons) {
            return [returnString, I_HUMIDITY];
        }
        else {
            return returnString;
        }

    }

    public function getDewpointAndHumidex() {
        var returnString = "NA";
        if (_garminWeather != null && _garminWeather.relativeHumidity != null && _garminWeather.temperature != null) {
            var dp = calcDewPoint(_garminWeather.temperature, _garminWeather.relativeHumidity);
            var dpUnit = _isMetric ? dp : celciusToFarenheit(dp);
            var humidex = calcHumidex(_garminWeather.temperature, _garminWeather.relativeHumidity);
            humidex = _isMetric ? humidex : celciusToFarenheit(humidex);
            returnString = dpUnit.format("%.0f") + DEGREE_SYMBOL + "/" + humidex.format("%.0f");
        }

        if (_isIcons) {
            return [returnString, I_DEWPOINT];
        }
        else {
            return returnString;
        }
    }

    public function getCity() {
        var returnString = "Garmin";
        if (_garminWeather != null && _garminWeather.observationLocationName != null){
            var cityLong = _garminWeather.observationLocationName;
            var cityShort = "";
            var commaPos = cityLong.find(",");
            if (commaPos != null){
                cityShort = cityLong.substring(0, commaPos);
            }
            else{
                cityShort = cityLong;
            }
            var slashPos = cityShort.find("/");
            if (slashPos != null)
            {
                cityShort = cityShort.substring(0, slashPos);
            }
            // 10 first characters of the city
            returnString = cityShort.substring(0, 10);
        }
        
        if (_isIcons) {
            return [returnString, I_NOICON];
        }
        else {
            return returnString;
        }
    }

    public function getWind() {
        var returnString = "NA";
        if (_garminWeather != null && _garminWeather.windSpeed != null) {
            var windSpeed = convertMsToSpeed(_garminWeather.windSpeed, _isMetric);
            returnString = windSpeed.format("%.0f");
        }
        
        if (_isIcons) {
            return [returnString, I_WIND];
        }
        else {
            return returnString;
        }
    }

    public function getWindchill() {
        var returnString = "NA";
        if (_garminWeather != null && _garminWeather.windSpeed != null && _garminWeather.temperature != null) {
            var windSpeed = convertMsToSpeed(_garminWeather.windSpeed, _isMetric);
            var metricWindChill = calcWindchill (_garminWeather.temperature, windSpeed);
            var windChill = _isMetric ? metricWindChill : celciusToFarenheit(metricWindChill);
            returnString = windChill.format("%.0f");
        }
        
        if (_isIcons) {
            return [returnString, I_WINDCHILL];
        }
        else {
            return returnString;
        }
    }

    public function getSunEvents() {
        var sunRise = getSunRise();
        var sunSet = getSunSet();
        var returnString = "NA";
        
        // sunRise and sunSet may be null
        if (sunRise != null && sunSet != null){
            // Sun rise
            var sunRiseGreg = Time.Gregorian.info(sunRise, Time.FORMAT_MEDIUM);
            // Sun set
            var sunSetGreg = Time.Gregorian.info(sunSet, Time.FORMAT_MEDIUM);
            // From the doc, don't think those can be null, but I'm checking anyway
            if (sunRiseGreg.hour != null && sunRiseGreg.min != null && sunSetGreg.hour != null && sunSetGreg.min != null) {
                returnString = sunRiseGreg.hour + ":" + sunRiseGreg.min.format("%02d") + "-";
                returnString += sunSetGreg.hour + ":" + sunSetGreg.min.format("%02d");
            }
        }
        return [returnString, I_NOICON];
    }


    public static function getThreeHourPrecipitation() {
        var returnString = "NA";
        if (  _hourlyForecast != null &&
                _hourlyForecast[0].precipitationChance != null &&
                _hourlyForecast[1].precipitationChance != null &&
                _hourlyForecast[2].precipitationChance != null ) {

            var probRain0 = _hourlyForecast[0].precipitationChance;
            var probRain1 = _hourlyForecast[1].precipitationChance;
            var probRain2 = _hourlyForecast[2].precipitationChance;
            // The case of 100-100-100% is too long of a string
            if (probRain0 == 100 && probRain1 == 100 && probRain2 == 100){
                returnString = "<- 100% ->";
            }
            else{
                returnString = probRain0.format("%02d") + "/" + probRain1.format("%02d") + "/" + probRain2.format("%02d") + "%";
            }       
        }
        
        if (_isIcons) {
            return [returnString, I_NOICON];
        }
        else {
            return returnString;
        }
    }

    public static function getThreeHourTemperature() {
        var returnString = "NA";
        if (  _hourlyForecast != null &&
                _hourlyForecast[0].temperature != null &&
                _hourlyForecast[1].temperature != null &&
                _hourlyForecast[2].temperature != null ) {

            var temp0 = _isMetric ? _hourlyForecast[0].temperature : celciusToFarenheit(_hourlyForecast[0].temperature);
            var temp1 = _isMetric ? _hourlyForecast[1].temperature : celciusToFarenheit(_hourlyForecast[1].temperature);
            var temp2 = _isMetric ? _hourlyForecast[2].temperature : celciusToFarenheit(_hourlyForecast[2].temperature);
            
            returnString = temp0.format("%01d") + "/" + temp1.format("%01d") + "/" + temp2.format("%01d") + DEGREE_SYMBOL;

            // If string length is too long, only keep two hours
            if (returnString.length() >= 10){
                returnString = temp0.format("%01d") + "/" + temp1.format("%01d") + DEGREE_SYMBOL;
            }   
        }
        
        if (_isIcons) {
            return [returnString, I_NOICON];
        }
        else {
            return returnString;
        }
    }

    // Private methods
    private function calcDewPoint(temp, humidity) {
        var dewPoint = 0;
        var a1 = 17.625;
        var b1 = 243.04;
                
        try{
            dewPoint = (b1 * (Math.ln(humidity / 100.0) + (a1 * temp)/(b1 + temp ))) / (a1 - Math.ln( humidity / 100.0) - a1 * temp/( b1 + temp ));
        }
        catch (exception){
            dewPoint = -99;
        }
        return dewPoint;
    }

    private function calcHumidex(temp, humidity) {
        var humidex = 0;
        var dewPoint = 0;
        var pressionPartielle = 0;
        var deltaHumidex = 0;
        var exposant = 0;
        var e = 2.71828;

        try {
            // Basic math test to see if wind or humidity is NaN because advanced math crashes without hitting the catch if it's the case
            var uselessTest = temp *2;
            uselessTest = humidity *2;

            dewPoint = calcDewPoint(temp, humidity);
            if (dewPoint == -1000){
                humidex = -1000;
            }
            else{
                exposant = 5417.753 * ((1/273.16)-(1/(273.16 + dewPoint)));
                pressionPartielle = 6.11 * Math.pow(e, exposant);
                deltaHumidex = 0.5555 * (pressionPartielle - 10);
                humidex = temp + Math.round(deltaHumidex);
            }
        }
        catch (exception){
            humidex = -1000;
        }

        return humidex;
    }

    private function calcWindchill(temp, wind){
        var windchill = -100;

        try{
            // Basic math test to see if wind is NaN because Math.pow crashes without hitting the catch if that happens
            var uselessTest = wind * 2;
            if (wind == 0) {
                windchill = temp;
            }
            else {
                windchill = 13.12 + (0.6215 * temp) - (11.37 * Math.pow(wind, 0.16)) + (0.3965 * temp * Math.pow(wind, 0.16));
            }
        }
        catch(exception){
            windchill = -1000;
        }
        return windchill;
    }

    private function convertMsToSpeed(mps, isMetric) {
        // 1 m/s = 3.6 km/h
        // 1 m/s = 2.237 mph
        var speed = isMetric ? mps*3.6 : mps*2.237;
        return speed;
    }

    private function celciusToFarenheit(celcius){
        return (celcius * 1.8) + 32;
    }

    // May return null
    private function getSunRise() {
        var sunRise = null;
        if (_garminWeather != null && _garminWeather.observationLocationPosition != null) {
            sunRise = Weather.getSunrise(_garminWeather.observationLocationPosition, Time.now());
        }
        return sunRise;
    }

    // May return null
    private function getSunSet() {
        var sunSet = null;
        if (_garminWeather != null && _garminWeather.observationLocationPosition != null) {
            sunSet = Weather.getSunset(_garminWeather.observationLocationPosition, Time.now());
        }
        return sunSet;
    }

}