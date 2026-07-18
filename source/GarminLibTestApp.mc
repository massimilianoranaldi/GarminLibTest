import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

(:background)
class GarminLibTestApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    //METEO
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new GarminLibTestView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
    System.println("onSettingsChanged: inizio");
    var view = WatchUi.getCurrentView()[0] as GarminLibTestView;
    System.println("onSettingsChanged: view ottenuta");
    view._settingsChanged = true;
    System.println("onSettingsChanged: flag settato");
    WatchUi.requestUpdate();
    System.println("onSettingsChanged: fine");
    }



     // ** Necessario per registrare il BackgroundService ** <- PASSO 1 (meteo)
    function getServiceDelegate() as [System.ServiceDelegate] {
        return [new BackgroundService()];
    }

}

function getApp() as GarminLibTestApp {
    return Application.getApp() as GarminLibTestApp;
}