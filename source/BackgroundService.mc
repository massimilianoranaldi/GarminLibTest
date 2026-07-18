//METEO

import Toybox.Background;
import Toybox.Lang;
import Toybox.System;

(:background)
class BackgroundService extends System.ServiceDelegate {

    static const URL as String =
        "https://meteo-garmin-worker.massimiliano-ranaldi.workers.dev";

    var _weatherService;   // ← istanza necessaria per method(:)

    function initialize() {
        ServiceDelegate.initialize();
        _weatherService = new WeatherService();
    }

    function onTemporalEvent() as Void {
        System.println("BackgroundService.onTemporalEvent");
        _weatherService.fetchMeteo(URL);   // ← chiama sull'istanza
    }

}