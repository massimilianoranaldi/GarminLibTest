import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class GarminLibTestView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        //esempio di uso del layout.xml
        /*
        //TimeManagement.getTimeString() 
        //----------------------------------------------------
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        
        
        var time = TimeManagement.getTimeString() as Lang.Dictionary<String, String>;;
        view.setText(time["timeString"]);
        
        Logger.log("onUpdate", "quadrante avviato");
        View.onUpdate(dc);

        // stringa completa
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 30, Graphics.FONT_SMALL, time["timeString"], Graphics.TEXT_JUSTIFY_CENTER);
        
        // ore 
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 60, Graphics.FONT_SMALL, time["ore"], Graphics.TEXT_JUSTIFY_CENTER);

        // minuti
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 90, Graphics.FONT_SMALL, time["minuti"], Graphics.TEXT_JUSTIFY_CENTER);        
        */
        View.onUpdate(dc);


        
        //BatteryRenderer.drawBatteria
        //----------------------------------------------------
        /*var colors = {
            "high"   => Graphics.COLOR_GREEN,
            "medium" => Graphics.COLOR_ORANGE,
            "low"    => Graphics.COLOR_RED
        };

        // orizzontale
        BatteryRenderer.drawBatteria(dc, 130, 200, 40, 16, colors, Graphics.FONT_XTINY, "orizzontale");

        // verticale
        BatteryRenderer.drawBatteria(dc, 130, 100, 16, 40, colors, Graphics.FONT_XTINY, "verticale");
        */

        //ProgressBar.draw
        //----------------------------------------------------
        /*
            var colori = {
                "sfondo" => Graphics.COLOR_DK_GRAY,
                "fill"   => Graphics.COLOR_GREEN
            } as Lang.Dictionary<Lang.String, Lang.Number>;

            // orizzontale sinistra → destra
            var config = {
                "orientamento" => "orizzontale",
                "rtl"          => false
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBar.draw(dc, 130, 200, 160, 8, 75, 100, colori, config);

            // orizzontale destra → sinistra
            config = {
                "orientamento" => "orizzontale",
                "rtl"          => true
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBar.draw(dc, 130, 220, 160, 8, 75, 100, colori, config);

            // verticale basso → alto
            config = {
                "orientamento" => "verticale",
                "rtl"          => true
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBar.draw(dc, 50, 130, 100, 8, 75, 100, colori, config);

            // verticale alto → basso
            config = {
                "orientamento" => "verticale",
                "rtl"          => false
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBar.draw(dc, 100, 130, 100, 8, 75, 100, colori, config);
        */


        //ProgressBarDash.draw
        //----------------------------------------------------
        /*    var colori = {
                "sfondo"   => Graphics.COLOR_DK_GRAY,
                "fill"     => Graphics.COLOR_GREEN,
                "segmenti" => 10,
                "gap"      => 4
            } as Lang.Dictionary<Lang.String, Lang.Number>;

            // orizzontale sinistra → destra
            var config = {
                "orientamento" => "orizzontale",
                "rtl"          => false
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBarDash.draw(dc, 80, 100, 100, 8, 75, 100, colori, config);

            // orizzontale sinistra → destra
             config = {
                "orientamento" => "orizzontale",
                "rtl"          => true
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBarDash.draw(dc, 80, 130, 100, 8, 75, 100, colori, config);
            // orizzontale   destra ->sinistra
             config = {
                "orientamento" => "verticale",
                "rtl"          => true
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBarDash.draw(dc, 150, 100, 100, 8, 75, 100, colori, config);

            // verticale alto ->basso
            config = {
                "orientamento" => "verticale",
                "rtl"          => false
            } as Lang.Dictionary<Lang.String, Lang.Object>;

            ProgressBarDash.draw(dc, 180, 100, 100, 8, 75, 100, colori, config);
*/

    //ActivityRing.draw
    //-----------------------------------------------
    /*    var cfg = {
            "spessore" => 8,
            "raggio"   => 100,
            "sfondo"   => Graphics.COLOR_DK_GRAY,
            "fill"     => Graphics.COLOR_RED
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        // cerchio orario da 90° a 0°
        ActivityRing.draw(dc, 130, 130, 75, 100, 90, 0, true, cfg);

        // cerchio antiorario da 90° a 180°
        ActivityRing.draw(dc, 130, 200, 75, 100, 90, 180, false, cfg);
    */
    //ActivityRingTick.draw
    //-----------------------------------------------
    /*    var cfg = {
            "spessore"  => 8,
            "raggio"    => 100,
            "segmenti"  => 10,
            "lunghezza" => 6,
            "sfondo"    => Graphics.COLOR_DK_GRAY,
            "fill"      => Graphics.COLOR_RED,
            "colTacca"  => Graphics.COLOR_WHITE
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        ActivityRingTick.draw(dc, 130, 130, 75, 100, 90, 0, true, cfg);

        ActivityRingTick.draw(dc, 130, 130, 75, 100, 180, 270, false, cfg);
    */
    
    
    //ActivityRingDash.draw
    //-----------------------------------------------
    /*var cfg = {
        "spessore"  => 8,
        "raggio"    => 100,
        "segmenti"  => 12,
        "gap"       => 3,
        "sfondo"    => Graphics.COLOR_DK_GRAY,
        "fill"      => Graphics.COLOR_RED
    } as Lang.Dictionary<Lang.String, Lang.Number>;

    // orario da 90° a 0°
    ActivityRingDash.draw(dc, 130, 150, 75, 100, 90, 0, true, cfg);

    // antiorario da 90° a 180°
    ActivityRingDash.draw(dc, 130, 130, 75, 100, 90, 180, false, cfg);
*/
    //ActivityRingDot.draw
    //-----------------------------------------------
/*
        var cfg = {
            "raggio"      => 100,
            "segmenti"    => 12,
            "raggioPunto" => 4,
            "sfondo"      => Graphics.COLOR_DK_GRAY,
            "fill"        => Graphics.COLOR_RED
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        // orario da 90° a 0°
        ActivityRingDot.draw(dc, 130, 130, 75, 100, 90, 0, true, cfg);

    cfg = {
            "raggio"      => 100,
            "segmenti"    => 12,
            "raggioPunto" => 4,
            "sfondo"      => Graphics.COLOR_DK_GRAY,
            "fill"        => Graphics.COLOR_GREEN
        } as Lang.Dictionary<Lang.String, Lang.Number>;
        // antiorario da 90° a 180°
        ActivityRingDot.draw(dc, 130, 130, 75, 100, 180, 270, false, cfg);
*/

    //ActivityData
    //-----------------------------------------------
    var steps      = ActivityData.getSteps();
    var calories   = ActivityData.getCalories();
    var distKm     = ActivityData.getDistanceKm();
    var floors     = ActivityData.getFloors() as Lang.Dictionary;
    var bodyBatt   = ActivityData.getBodyBattery();
    var activeMin  = ActivityData.getActiveMinutes();
    var activeWeek = ActivityData.getActiveMinutesWeek();
    var bbMidnight = ActivityData.getBodyBatteryMidnight();

dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
dc.drawText(130, 60,  Graphics.FONT_SMALL,
    steps.format("%d") + " passi",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 80,  Graphics.FONT_SMALL,
    calories.format("%d") + " kcal",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 100, Graphics.FONT_SMALL,
    distKm.format("%.1f") + " km",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 120, Graphics.FONT_SMALL,
    activeMin.format("%d") + " min attivi",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 140, Graphics.FONT_SMALL,
    activeWeek.format("%d") + " min/sett",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 160, Graphics.FONT_SMALL,
    "↑" + (floors["climbed"] as Lang.Number).format("%d") + "  ↓" + (floors["descended"] as Lang.Number).format("%d") + " piani",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 180, Graphics.FONT_SMALL,
    "BB: " + bodyBatt.format("%d") + "%",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

dc.drawText(130, 200, Graphics.FONT_SMALL,
    "BB mezzanotte: " + bbMidnight.format("%d") + "%",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }


        
    function onHide() as Void {
    }

 
    function onExitSleep() as Void {
    }


    function onEnterSleep() as Void {
    }
 
}
