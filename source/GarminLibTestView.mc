import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class GarminLibTestView extends WatchUi.WatchFace {


    var _settingsChanged =true;
    // ── ISTANZE — inizializzate in initialize() ────────────────

    // BatteryRenderer
    var _batteria;

    // ProgressBar (4 varianti)
    /*var _bar_or_ltr;   // orizzontale sinistra → destra
    var _bar_or_rtl;   // orizzontale destra → sinistra
    var _bar_ver_bot;  // verticale basso → alto
    var _bar_ver_top;  // verticale alto → basso

    // ProgressBarDash (4 varianti)
    var _barDash_or_ltr;
    var _barDash_or_rtl;
    var _barDash_ver_bot;
    var _barDash_ver_top;

    // ActivityRing
    var _ring1;
    var _ring2;

    // ActivityRingTick
    var _ringTick1;
    var _ringTick2;

    // ActivityRingDash
    var _ringDash1;
    var _ringDash2;

    // ActivityRingDot (onUpdate)
    var _ringDot1;
    var _ringDot2;*/

    //circle
    var _circleSx as Lang.Dictionary or Null = null;
    var _circleCntrl as Lang.Dictionary or Null = null;
    var _circleDx as Lang.Dictionary or Null = null;
    var _rectNotch as Lang.Dictionary or Null = null;
    var _rectCalendar as Lang.Dictionary or Null = null;

    // ActivityRingDot 
    var _ringDotProgress1;
    var _ringDotProgress2;
    var _datiRing1 as Lang.Dictionary or Null = null;
    var _datiRing2 as Lang.Dictionary or Null = null;

    var _colorFillRingDot1=null;//Graphics.COLOR_DK_GRAY;
    var _colorBackgRingDot1=null;//Graphics.COLOR_GREEN;

    var _colorFillRingDot2=null;//Graphics.COLOR_DK_GRAY;
    var _colorBackgRingDot2=null;//Graphics.COLOR_GREEN;

    // dimensioni

    //CERCHIO CENTRALE 
    var circle3X = 130;
    var circle3Y = 50;
    var rad3=40;

    //CERCHIO SINISTRA 
    var circle1X = 55;
    var circle1Y = 75;
    var rad1=30;
    
    //CERCHIO DESTRA
    var circle2X = 205;
    var circle2Y = 75;
    var rad2=30;        
    
    //RETTANGOLO GRANDE
    var rect1X = 160;
    var rect1Y = 130;
    var rect1W = 150;
    var rect1H = 40;
    
    //RETTANGOLO PICCOLO
    var rect2X = 145;
    var rect2Y = 170;
    var rect2W = 120;
    var rect2H = 25;

    var  _coordXtextRing2=0;
    var  _coordYtextRing2=0;

    var  _coordXtextRing1=0;
    var  _coordYtextRing1=0;

    var _coordXIconRing1=0;
    var _coordYIconRing1=0;

    var _coordXIconRing2=0;
    var _coordYIconRing2=0;

    // ──────────────────────────────────────────────────────────
    // MONITORING DATI GOAL
    // ──────────────────────────────────────────────────────────

  /*  var _goalSTEP = 10000; //default modificabile utente listEntry value="0"
    var _goalCALORIE = 2000; //default modificabile utente listEntry value="1"
    var _goalSTAIRS = 10; //default modificabile utente listEntry value="2"
    var _goalMINWEEK = 200; //default modificabile utente listEntry value="3"
    var _goalMINDAY = 20; //default modificabile utente listEntry value="4"
    var _goalSTRESS = 100; //default  value="5"    
    var _goalBODYBATTERY = 100; //default  value="6"        
*/
    // ──────────────────────────────────────────────────────────
    // ACTIVITY
    // ──────────────────────────────────────────────────────────
    /*var _activityRingDot1=0;
    var _activityRingDot2=0;*/




    function initialize() {
        Logger.log("initialize", "inizio");
        WatchFace.initialize();

        // in questa sezione devo usare colori di systema perchè ancora non sono caricati Palette
        /*
        // ── BatteryRenderer ────────────────────────────────────
        var colorsB = {
            "high"   => Graphics.COLOR_GREEN,
            "medium" => Graphics.COLOR_ORANGE,
            "low"    => Graphics.COLOR_RED
        } as Lang.Dictionary<Lang.String, Lang.Number>;
        _batteria = new BatteryRenderer(130, 200, 40, 16, colorsB, Graphics.FONT_XTINY, "orizzontale");

        // ── ProgressBar ────────────────────────────────────────
        var coloriBar = {
            "sfondo" => Graphics.COLOR_DK_GRAY,
            "fill"   => Graphics.COLOR_GREEN
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _bar_or_ltr = new ProgressBar(130, 200, 160, 8, coloriBar,
            { "orientamento" => "orizzontale", "rtl" => false } as Lang.Dictionary<Lang.String, Lang.Object>);

        _bar_or_rtl = new ProgressBar(130, 220, 160, 8, coloriBar,
            { "orientamento" => "orizzontale", "rtl" => true } as Lang.Dictionary<Lang.String, Lang.Object>);

        _bar_ver_bot = new ProgressBar(50, 130, 100, 8, coloriBar,
            { "orientamento" => "verticale", "rtl" => true } as Lang.Dictionary<Lang.String, Lang.Object>);

        _bar_ver_top = new ProgressBar(100, 130, 100, 8, coloriBar,
            { "orientamento" => "verticale", "rtl" => false } as Lang.Dictionary<Lang.String, Lang.Object>);

        // ── ProgressBarDash ────────────────────────────────────
        var coloriDash = {
            "sfondo"   => Graphics.COLOR_DK_GRAY,
            "fill"     => Graphics.COLOR_GREEN,
            "segmenti" => 10,
            "gap"      => 4
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _barDash_or_ltr = new ProgressBarDash(80, 100, 100, 8, coloriDash,
            { "orientamento" => "orizzontale", "rtl" => false } as Lang.Dictionary<Lang.String, Lang.Object>);

        _barDash_or_rtl = new ProgressBarDash(80, 130, 100, 8, coloriDash,
            { "orientamento" => "orizzontale", "rtl" => true } as Lang.Dictionary<Lang.String, Lang.Object>);

        _barDash_ver_bot = new ProgressBarDash(150, 100, 100, 8, coloriDash,
            { "orientamento" => "verticale", "rtl" => true } as Lang.Dictionary<Lang.String, Lang.Object>);

        _barDash_ver_top = new ProgressBarDash(180, 100, 100, 8, coloriDash,
            { "orientamento" => "verticale", "rtl" => false } as Lang.Dictionary<Lang.String, Lang.Object>);

        // ── ActivityRing ───────────────────────────────────────
        var cfgRing = {
            "spessore" => 8,
            "raggio"   => 100,
            "sfondo"   => Graphics.COLOR_DK_GRAY,
            "fill"     => Graphics.COLOR_RED
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ring1 = new ActivityRing(130, 130, 90, 0, true, cfgRing);
        _ring2 = new ActivityRing(130, 200, 90, 180, false, cfgRing);

        // ── ActivityRingTick ───────────────────────────────────
        var cfgTick = {
            "spessore"  => 8,
            "raggio"    => 100,
            "segmenti"  => 10,
            "lunghezza" => 6,
            "sfondo"    => Graphics.COLOR_DK_GRAY,
            "fill"      => Graphics.COLOR_RED,
            "colTacca"  => Graphics.COLOR_WHITE
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ringTick1 = new ActivityRingTick(130, 130, 90, 0, true, cfgTick);
        _ringTick2 = new ActivityRingTick(130, 130, 180, 270, false, cfgTick);

        // ── ActivityRingDash ───────────────────────────────────
        var cfgDash = {
            "spessore"  => 8,
            "raggio"    => 100,
            "segmenti"  => 12,
            "gap"       => 3,
            "sfondo"    => Graphics.COLOR_DK_GRAY,
            "fill"      => Graphics.COLOR_RED
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ringDash1 = new ActivityRingDash(130, 150, 90, 0, true, cfgDash);
        _ringDash2 = new ActivityRingDash(130, 130, 90, 180, false, cfgDash);

        // ── ActivityRingDot (onUpdate) ─────────────────────────
        var cfgDot = {
            "raggio"      => 100,
            "segmenti"    => 12,
            "raggioPunto" => 4,
            "sfondo"      => Graphics.COLOR_DK_GRAY,
            "fill"        => Graphics.COLOR_RED
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ringDot1 = new ActivityRingDot(130, 130, 90, 0, true, cfgDot);

        var cfgDot2 = {
            "raggio"      => 100,
            "segmenti"    => 12,
            "raggioPunto" => 4,
            "sfondo"      => Graphics.COLOR_DK_GRAY,
            "fill"        => Graphics.COLOR_GREEN
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ringDot2 = new ActivityRingDot(130, 130, 180, 270, false, cfgDot2);
        */



        // ── ActivityRingDot (sfondo) ───────────────────────────
        var cfgDotS1 = { //ESTERNO CON IL RAGGIO MAGGIORE
            "raggio"      => 110,
            "segmenti"    => 10,
            "raggioPunto" => 4,
            "sfondo"      => _colorBackgRingDot1,
            "fill"        => _colorFillRingDot1
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ringDotProgress1 = new ActivityRingDot(130, 130, 190, 255, false, cfgDotS1);
        _coordXtextRing1=130;
        _coordYtextRing1=110+130;
        _coordXIconRing1=130-110;
        _coordYIconRing1=130;

        var cfgDotS2 = {//INTERNO CON IL RAGGIO MINORE
            "raggio"      => 80,
            "segmenti"    => 8,
            "raggioPunto" => 4,
            "sfondo"      => _colorBackgRingDot2,
            "fill"        => _colorFillRingDot2
        } as Lang.Dictionary<Lang.String, Lang.Number>;

        _ringDotProgress2 = new ActivityRingDot(130, 130, 190, 255, false, cfgDotS2);
        _coordXtextRing2=130;
        _coordYtextRing2=80+130;
        _coordXIconRing2=130-80;
        _coordYIconRing2=130;
        Logger.log("initialize", "fine");
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void { //QUESTA FUNZIONE VIENE ESEGUITA 

        Logger.log("onShow : >>>>>>>>>>>>>>>>>>>>","SONO DENTRO : onShow dopo richiama onUpdate");

        _settingsChanged = true;        // forza rilettura Properties al risveglio
        var coords = WeatherCoords.getCoords();
            Logger.log("onShow", "coords: lat=" + coords[0] + " lon=" + coords[1]);

            var data = WeatherData.loadFromStorage();
            if (data != null) {
                Logger.log("onShow", "dati in cache, parsing...");
                WeatherData.parseData(data);
                Logger.log("onShow", "temp=" + WeatherData.getTempString() +
                        " vento=" + WeatherData.getWindString() +
                        " alba=" + WeatherData.getSunrise() +
                        " tramonto=" + WeatherData.getSunset());
                        WatchUi.requestUpdate();    // ← forza ridisegno
            } else {
                Logger.log("onShow", "nessun dato in cache");
            }
    }
    
    
    

    function onUpdate(dc as Dc) as Void {//VIENE ESEGUITA OGNI SECONDO 
        View.onUpdate(dc);





        // ── TimeManagement ─────────────────────────────────────
        /*
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        var time = TimeManagement.getTimeString() as Lang.Dictionary<String, String>;
        view.setText(time["timeString"]);
        Logger.log("onUpdate", "quadrante avviato");
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 30, Graphics.FONT_SMALL, time["timeString"], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(130, 60, Graphics.FONT_SMALL, time["ore"],        Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(130, 90, Graphics.FONT_SMALL, time["minuti"],     Graphics.TEXT_JUSTIFY_CENTER);
        */

        // ── BatteryRenderer ────────────────────────────────────
        /*
        _batteria.draw(dc);
        */

        // ── ProgressBar ────────────────────────────────────────
        /*
        _bar_or_ltr.setValori(75, 100);
        _bar_or_ltr.draw(dc);
        _bar_or_ltr.setColori(Graphics.COLOR_YELLOW, Graphics.COLOR_DK_GRAY);

        _bar_or_rtl.setValori(75, 100);
        _bar_or_rtl.draw(dc);

        _bar_ver_bot.setValori(75, 100);
        _bar_ver_bot.draw(dc);

        _bar_ver_top.setValori(75, 100);
        _bar_ver_top.draw(dc);
        */

        // ── ProgressBarDash ────────────────────────────────────
        /*
        _barDash_or_ltr.setValori(75, 100);
        _barDash_or_ltr.draw(dc);

        _barDash_or_rtl.setValori(75, 100);
        _barDash_or_rtl.draw(dc);

        _barDash_ver_bot.setValori(75, 100);
        _barDash_ver_bot.draw(dc);

        _barDash_ver_top.setValori(75, 100);
        _barDash_ver_top.draw(dc);
        */

        // ── ActivityRing ───────────────────────────────────────
        /*
        _ring1.setValori(75, 100);
        _ring1.draw(dc);

        _ring2.setValori(75, 100);
        _ring2.draw(dc);
        */

        // ── ActivityRingTick ───────────────────────────────────
        /*
        _ringTick1.setValori(75, 100);
        _ringTick1.draw(dc);

        _ringTick2.setValori(75, 100);
        _ringTick2.draw(dc);
        */

        // ── ActivityRingDash ───────────────────────────────────
        /*
        _ringDash1.setValori(75, 100);
        _ringDash1.draw(dc);

        _ringDash2.setValori(75, 100);
        _ringDash2.draw(dc);
        */

        // ── ActivityRingDot ────────────────────────────────────
        /*
        _ringDot1.setValori(75, 100);
        _ringDot1.draw(dc);

        _ringDot2.setValori(75, 100);
        _ringDot2.draw(dc);
        */

        // ── ActivityData ───────────────────────────────────────
        /*
        var steps      = ActivityData.getSteps();
        var calories   = ActivityData.getCalories();
        var distKm     = ActivityData.getDistanceKm();
        var floors     = ActivityData.getFloors() as Lang.Dictionary;
        var bodyBatt   = ActivityData.getBodyBattery();
        var activeMin  = ActivityData.getActiveMinutes();
        var activeWeek = ActivityData.getActiveMinutesWeek();
        var bbMidnight = ActivityData.getBodyBatteryMidnight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 60,  Graphics.FONT_SMALL, steps.format("%d") + " passi",          Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 80,  Graphics.FONT_SMALL, calories.format("%d") + " kcal",        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 100, Graphics.FONT_SMALL, distKm.format("%.1f") + " km",          Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 120, Graphics.FONT_SMALL, activeMin.format("%d") + " min attivi", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 140, Graphics.FONT_SMALL, activeWeek.format("%d") + " min/sett",  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 160, Graphics.FONT_SMALL,
            "↑" + (floors["climbed"] as Lang.Number).format("%d") +
            " ↓" + (floors["descended"] as Lang.Number).format("%d") + " piani",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 180, Graphics.FONT_SMALL, "BB: " + bodyBatt.format("%d") + "%",   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(130, 200, Graphics.FONT_SMALL, "BB mezzanotte: " + bbMidnight.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        */

        // ── Circle / CircleFill ────────────────────────────────
        /*
        Circle.draw(dc, 60, 130, 50, Graphics.COLOR_WHITE, 4);
        CircleFill.draw(dc, 190, 130, 50, Graphics.COLOR_GREEN);
        */

        // ── Rect / RectFill ────────────────────────────────────
        /*
        RectFill.draw(dc, 130, 130, 100, 40, Graphics.COLOR_BLUE, 0);
        RectFill.draw(dc, 130, 180, 100, 40, Graphics.COLOR_BLUE, 8);
        Rect.draw(dc, 130, 230, 100, 40, Graphics.COLOR_WHITE, 2, 0);
        Rect.draw(dc, 130, 80,  100, 40, Graphics.COLOR_WHITE, 2, 20);
        */

        // ── Palette ────────────────────────────────────────────
        /*
        Palette.stampaPalette(dc, "giallo",    50, 60, 18, 20, 3);
        Palette.stampaPalette(dc, "oro",       50, 90, 18, 20, 3);
        Palette.stampaPalette(dc, "arancione", 50, 120, 18, 20, 3);
        */

        // ── QUESTA CONDIZIONE VIENE VERIFICATA OGNI SECONDO MA LA VARIABILE VIENE GESTITA IN onShow
        if (_settingsChanged) // la parte statica 
            { 
                _getAndSetUpProperties(dc);
                _settingsChanged = false;
            }

        _aggiornaValore();   // ← sempre, ogni secondo e recupera i dati getInfo in funzione del tipo
        
        _drawSfondo1(dc); //le componenti "statiche"

        _drawDati(dc); // le componenti dinamiche

        
    }

    // ============================================================
    // SEZIONE PROPERTIES E TEMI
    // ============================================================
    function _getAndSetUpProperties(dc as Dc) as Void {
    
    
        var tema = Application.Properties.getValue("temiQuadrante") as Lang.Number;

        var goals = { // parametri che non dipendono dal tema
            "goalStep"    => Application.Properties.getValue("goalSTEP")    as Lang.Number,
            "goalCalorie" => Application.Properties.getValue("goalCALORIE") as Lang.Number,
            "goalStairs"  => Application.Properties.getValue("goalSTAIRS")  as Lang.Number,
            "goalMinWeek" => Application.Properties.getValue("goalMINWEEK") as Lang.Number,
            "goalMinDay"  => Application.Properties.getValue("goalMINDAY")  as Lang.Number
        };
        

        var tipo1 = Application.Properties.getValue("monitoringAttivita1") as Lang.Number;
        var tipo2 = Application.Properties.getValue("monitoringAttivita2") as Lang.Number;

    /* STRUTTURA DATI ATTIVITA 
    _datiRing<n>
    {
        "dati"
            {
                "tipo"
                "valore"
                "goal"
                "suffisso"
                }

        "tema"
            {
                "back"
                "fill"
                "font"
                "icona"
             }

    }*/
        _datiRing1 = {"dati" => _getParameterActivity(goals, tipo1),"tema"    => _getTemaActivity1(tipo1, tema)};
        _datiRing2 = {"dati" => _getParameterActivity(goals, tipo2),"tema"    => _getTemaActivity2(tipo2, tema)};

    /* STRUTTURA CIRCLE 
        _circle<n>
        {
            "tema"
                {
                    "back"
                    "stroke"
                }

        }*/
        _circleSx={"tema" =>  _getTemaCircleSx(tema)};
        _circleCntrl={"tema" => _getTemaCircleCntrl(tema)};
        _circleDx={"tema" => _getTemaCircleDx( tema)};

    /* STRUTTURA RECT 
        _rect<n>
        {
            "tema"
                {
                    "back"
                    "font1"
                    "font2"
                    "font3"
                }

        }*/        
        _rectNotch={"tema" => _getTemaRectNotch( tema)};
        _rectCalendar={"tema" => _getTemaRectCalendar( tema)};

    }

    // FUNZIONI ASSOCIATE AI TEMI
    //-----------------------------------------------------------------------
    // a partire  dal tema recupera i colori associati al back
    function _getTemaRectCalendar(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3,"font1"=>Palette.arancione1,"font2"=>Palette.arancione1,"font3"=>Palette.arancione1 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3,"font1"=>Palette.arancione1,"font2"=>Palette.arancione1,"font3"=>Palette.arancione1  };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2,"font1"=>Palette.arancione1,"font2"=>Palette.arancione1,"font3"=>Palette.arancione1  };
            case 4: return { "back" => Palette.grigio6, "stroke" => Palette.rosa3,"font1"=>Palette.arancione1,"font2"=>Palette.arancione1,"font3"=>Palette.arancione1  };
            default: return {
                "back"  => Application.Properties.getValue("retOreSfondo")  as Lang.Number,
                "font1"  => Application.Properties.getValue("coloreOre") as Lang.Number,
                "font2"  => Application.Properties.getValue("coloreMinuti") as Lang.Number,
                "font3"  => Application.Properties.getValue("coloreCalendario") as Lang.Number
            };
        }
    }
    
    // a partire  dal tema recupera i colori associati al back
    function _getTemaRectNotch(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3,"font1"=>Palette.arancione1,"font2"=>null,"font3"=>null };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3,"font1"=>Palette.arancione1,"font2"=>null,"font3"=>null  };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2,"font1"=>Palette.arancione1,"font2"=>null,"font3"=>null  };
            case 4: return { "back" => Palette.grigio6, "stroke" => Palette.rosa3,"font1"=>Palette.arancione1,"font2"=>null,"font3"=>null  };
            default: return {
                "back"  => Application.Properties.getValue("retMeteoSfondo")  as Lang.Number,
                "font1"  => Application.Properties.getValue("coloreCittaMeteo") as Lang.Number,
                "font2"  => null,
                "font3"  => null
            };
        }
    }

    // a partire  dal tema recupera i colori associati al back,stroke altrimenti va in default
    function _getTemaCircleDx(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3 };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2 };
            case 4: return { "back" => Palette.grigio6, "stroke" => Palette.rosa3 };
            default: return {
                "back"  => Application.Properties.getValue("cerchioDxSfondo")  as Lang.Number,
                "stroke"  => Application.Properties.getValue("cerchioDxContorno") as Lang.Number
            };
        }
    }

    function _getTemaCircleCntrl(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3 };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2 };
            case 4: return { "back" => Palette.grigio6, "stroke" => Palette.rosa3 };
            default: return {
                "back"  => Application.Properties.getValue("cerchioGrandeSfondo")  as Lang.Number,
                "stroke"  => Application.Properties.getValue("cerchioGrandeContorno") as Lang.Number
            };
        }
    }

    // a partire  dal tema recupera i colori associati al back,stroke altrimenti va in default
    function _getTemaCircleSx(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3 };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2 };
            case 4: return { "back" => Palette.grigio6, "stroke" => Palette.rosa3 };
            default: return {
                "back"  => Application.Properties.getValue("cerchioSxSfondo")  as Lang.Number,
                "stroke"  => Application.Properties.getValue("cerchioSxContorno") as Lang.Number
            };
        }
    }

    // a partire dal tipo e dal tema recupera i colori associati al back,fill e font e icona colorata e restituisce i valori default per l'attività 
    function _getTemaActivity1(tipo as Lang.Number, tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "fill" => Palette.giallo3,    "font" => Palette.giallo3,    "icona" => _getIconActivityFromTheme(tipo, tema) };
            case 2: return { "back" => Palette.grigio6, "fill" => Palette.arancione3, "font" => Palette.arancione3, "icona" => _getIconActivityFromTheme(tipo, tema) };
            case 3: return { "back" => Palette.grigio6, "fill" => Palette.ciano2,     "font" => Palette.ciano2,     "icona" => _getIconActivityFromTheme(tipo, tema) };
            case 4: return { "back" => Palette.grigio6, "fill" => Palette.rosa3,      "font" => Palette.rosa3,      "icona" => _getIconActivityFromTheme(tipo, tema) };
            default: return {
                "back"  => Application.Properties.getValue("coloreSfondoAttivita1")  as Lang.Number,
                "fill"  => Application.Properties.getValue("coloreRipienoAttivita1") as Lang.Number,
                "font"  => Application.Properties.getValue("coloreFontArcoEsterno")  as Lang.Number,
                "icona" => _getIconActivityFromColor(tipo, Application.Properties.getValue("coloreIconaAttivita1") as Lang.Number)
            };
        }
    }
    
    // a partire dal tipo e dal tema recupera i colori associati al back,fill e font e icona colorata e restituisce i valori default per l'attività  
    function _getTemaActivity2(tipo as Lang.Number, tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "fill" => Palette.giallo3,    "font" => Palette.giallo3,    "icona" => _getIconActivityFromTheme(tipo, tema) };
            case 2: return { "back" => Palette.grigio6, "fill" => Palette.arancione3, "font" => Palette.arancione3, "icona" => _getIconActivityFromTheme(tipo, tema) };
            case 3: return { "back" => Palette.grigio6, "fill" => Palette.ciano2,     "font" => Palette.ciano2,     "icona" => _getIconActivityFromTheme(tipo, tema) };
            case 4: return { "back" => Palette.grigio6, "fill" => Palette.rosa3,      "font" => Palette.rosa3,      "icona" => _getIconActivityFromTheme(tipo, tema) };
            default: return {
                "back"  => Application.Properties.getValue("coloreSfondoAttivita2")  as Lang.Number,
                "fill"  => Application.Properties.getValue("coloreRipienoAttivita2") as Lang.Number,
                "font"  => Application.Properties.getValue("coloreFontArcoInterno")  as Lang.Number,
                "icona" => _getIconActivityFromColor(tipo, Application.Properties.getValue("coloreIconaAttivita2") as Lang.Number)
            };
        }
    }
    // a partire dal tipo e del tema recupera icona colorata
    function _getIconActivityFromTheme(tipo as Lang.Number, tema as Lang.Number or Null) as BitmapResource or Null {
        var t = (tema != null) ? tema : 0 as Lang.Number;
        switch (tipo) {
            case ActivityType.ACTIVITY_PASSI:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconPassiGiallo3)        as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconPassiArancione3)     as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconPassiCiano2)         as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconPassiRosa3)          as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconPassi)               as BitmapResource;
                }
            case ActivityType.ACTIVITY_CALORIE:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconCalorieGiallo3)      as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconCalorieArancione3)   as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconCalorieCiano2)       as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconCalorieRosa3)        as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconCalorie)             as BitmapResource;
                }
            case ActivityType.ACTIVITY_GRADINI:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconPianiSalitiGiallo3)    as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconPianiSalitiArancione3) as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconPianiSalitiCiano2)     as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconPianiSalitiRosa3)      as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconPianiSaliti)           as BitmapResource;
                }
            case ActivityType.ACTIVITY_MIN_WEEK:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconMinWeekGiallo3)      as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconMinWeekArancione3)   as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconMinWeekCiano2)       as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconMinWeekRosa3)        as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconMinWeek)             as BitmapResource;
                }
            case ActivityType.ACTIVITY_MIN_DAY:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconMinDayGiallo3)       as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconMinDayArancione3)    as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconMinDayCiano2)        as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconMinDayRosa3)         as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconMinDay)              as BitmapResource;
                }
            case ActivityType.ACTIVITY_STRESS:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconStressGiallo3)       as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconStressArancione3)    as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconStressCiano2)        as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconStressRosa3)         as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconStress)              as BitmapResource;
                }
            case ActivityType.ACTIVITY_BODY_BATTERY:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconBodyBatteryGiallo3)    as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconBodyBatteryArancione3) as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconBodyBatteryCiano2)     as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconBodyBatteryRosa3)      as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconBodyBattery)           as BitmapResource;
                }
                
                default: return null;
            }
    }

    
    // FUNZIONI ASSOCIATE ALLE ATTIVITA E COLORI
    //-----------------------------------------------------------------------
    // a partire dal tipo restituisce valore default, goal, suffisso
    function _getParameterActivity(goals as Lang.Dictionary, tipo as Lang.Number) as Lang.Dictionary {
        switch (tipo) {
            case ActivityType.ACTIVITY_PASSI:        return { "tipo" => tipo, "valore" => 0, "goal" => goals["goalStep"]    as Lang.Number, "suffisso" => ""   };
            case ActivityType.ACTIVITY_CALORIE:      return { "tipo" => tipo, "valore" => 0, "goal" => goals["goalCalorie"] as Lang.Number, "suffisso" => "c"  };
            case ActivityType.ACTIVITY_GRADINI:      return { "tipo" => tipo, "valore" => 0, "goal" => goals["goalStairs"]  as Lang.Number, "suffisso" => "s"  };
            case ActivityType.ACTIVITY_MIN_WEEK:     return { "tipo" => tipo, "valore" => 0, "goal" => goals["goalMinWeek"] as Lang.Number, "suffisso" => "mw" };
            case ActivityType.ACTIVITY_MIN_DAY:      return { "tipo" => tipo, "valore" => 0, "goal" => goals["goalMinDay"]  as Lang.Number, "suffisso" => "md" };
            case ActivityType.ACTIVITY_STRESS:       return { "tipo" => tipo, "valore" => 0, "goal" => 100,                                "suffisso" => "%"  };
            case ActivityType.ACTIVITY_BODY_BATTERY: return { "tipo" => tipo, "valore" => 0, "goal" => 100,                                "suffisso" => "%"  };
            default:                                 return { 
                    "tipo" => tipo, 
                    "valore" => 0, 
                    "goal" => 1,                                   
                    "suffisso" => ""   
                    };
        }
    }

    function _getIconActivityFromColor(tipo as Lang.Number, colore as Lang.Number) as BitmapResource or Null {
        switch (tipo) {
            case ActivityType.ACTIVITY_PASSI:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconPassiGiallo3)        as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconPassiArancione3)     as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconPassiCiano2)         as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconPassiRosa3)          as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconPassiGrigio4)        as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconPassiNero2)          as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconPassi)               as BitmapResource;
                }
            case ActivityType.ACTIVITY_CALORIE:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconCalorieGiallo3)      as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconCalorieArancione3)   as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconCalorieCiano2)       as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconCalorieRosa3)        as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconCalorieGrigio4)      as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconCalorieNero2)        as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconCalorie)             as BitmapResource;
                }
            case ActivityType.ACTIVITY_GRADINI:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconPianiSalitiGiallo3)    as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconPianiSalitiArancione3) as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconPianiSalitiCiano2)     as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconPianiSalitiRosa3)      as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconPianiSalitiGrigio4)    as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconPianiSalitiNero2)      as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconPianiSaliti)           as BitmapResource;
                }
            case ActivityType.ACTIVITY_MIN_WEEK:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconMinWeekGiallo3)      as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconMinWeekArancione3)   as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconMinWeekCiano2)       as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconMinWeekRosa3)        as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconMinWeekGrigio4)      as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconMinWeekNero2)        as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconMinWeek)             as BitmapResource;
                }
            case ActivityType.ACTIVITY_MIN_DAY:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconMinDayGiallo3)       as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconMinDayArancione3)    as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconMinDayCiano2)        as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconMinDayRosa3)         as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconMinDayGrigio4)       as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconMinDayNero2)         as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconMinDay)              as BitmapResource;
                }
            case ActivityType.ACTIVITY_STRESS:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconStressGiallo3)       as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconStressArancione3)    as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconStressCiano2)        as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconStressRosa3)         as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconStressGrigio4)       as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconStressNero2)         as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconStress)              as BitmapResource;
                }
            case ActivityType.ACTIVITY_BODY_BATTERY:
                switch (colore) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconBodyBatteryGiallo3)    as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconBodyBatteryArancione3) as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconBodyBatteryCiano2)     as BitmapResource;
                    case 4:  return Application.loadResource(Rez.Drawables.iconBodyBatteryRosa3)      as BitmapResource;
                    case 5:  return Application.loadResource(Rez.Drawables.iconBodyBatteryGrigio4)    as BitmapResource;
                    case 6:  return Application.loadResource(Rez.Drawables.iconBodyBatteryNero2)      as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconBodyBattery)           as BitmapResource;
                }
            default: return null;
        }
    }
   
   
    // ============================================================
    // DATI - componenti dinamiche 
    // ============================================================

// ── chiamata ad ogni onUpdate() — aggiorna solo il valore ─────
    function _aggiornaValore() as Void {
        if (_datiRing1 == null || _datiRing2 == null) { return; }

        var info = ActivityMonitor.getInfo();

        var statico1 = _datiRing1["dati"] as Lang.Dictionary;
        statico1["valore"] = _leggiValore(info, statico1["tipo"] as Lang.Number);

        var statico2 = _datiRing2["dati"] as Lang.Dictionary;
        statico2["valore"] = _leggiValore(info, statico2["tipo"] as Lang.Number);
    }

    function _leggiValore(info as ActivityMonitor.Info, tipo as Lang.Number) as Lang.Number {
        switch (tipo) {
            case 0: return info.steps             != null ? info.steps                    : 0;
            case 1: return info.calories          != null ? info.calories                 : 0;
            case 2: return info.floorsClimbed     != null ? info.floorsClimbed            : 0;
            case 3: return info.activeMinutesWeek != null ? info.activeMinutesWeek.total  : 0;
            case 4: return info.activeMinutesDay  != null ? info.activeMinutesDay.total   : 0;
            case 5: return ActivityData.getStress();       // SensorHistory — API separata
            case 6: return ActivityData.getBodyBattery();  // SensorHistory — API separata
            default: return 0;
        }
    }
  
        function _drawDati(dc as Dc) as Void {

            // DISEGNA ARCHI ATTIVITA
            //----------------------------------------------------------------------------------------
            if (_datiRing1 == null || _datiRing2 == null) { return; }

            var statico1 = _datiRing1["dati"] as Lang.Dictionary;
            var tema1    = _datiRing1["tema"]    as Lang.Dictionary;
            var statico2 = _datiRing2["dati"] as Lang.Dictionary;
            var tema2    = _datiRing2["tema"]    as Lang.Dictionary;

            //ATTIVITA 1
            _ringDotProgress1.setValori(statico1["valore"], statico1["goal"]);
            _ringDotProgress1.setColori(tema1["fill"] as Lang.Number, tema1["back"] as Lang.Number);
            _ringDotProgress1.draw(dc);
            dc.setColor(tema1["font"] as Lang.Number, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_coordXtextRing1, _coordYtextRing1, Graphics.FONT_TINY,
                MathUtils.formatNumberCompact(statico1["valore"]) + (statico1["suffisso"] as Lang.String),
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawBitmap(
                _coordXIconRing1 - (tema1["icona"] as BitmapResource).getWidth() / 2,
                _coordYIconRing1 - (tema1["icona"] as BitmapResource).getHeight() / 2,
                tema1["icona"] as BitmapResource);

             //ATTIVITA 2
            _ringDotProgress2.setValori(statico2["valore"], statico2["goal"]);
            _ringDotProgress2.setColori(tema2["fill"] as Lang.Number, tema2["back"] as Lang.Number);
            _ringDotProgress2.draw(dc);
            dc.setColor(tema2["font"] as Lang.Number, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_coordXtextRing2, _coordYtextRing2, Graphics.FONT_TINY,
                MathUtils.formatNumberCompact(statico2["valore"]) + (statico2["suffisso"] as Lang.String),
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawBitmap(
                _coordXIconRing2 - (tema2["icona"] as BitmapResource).getWidth() / 2,
                _coordYIconRing2 - (tema2["icona"] as BitmapResource).getHeight() / 2,
                tema2["icona"] as BitmapResource);

            
            // SCRIVI ORA+CALENDARIO NEL RETTANGOLO GRANDE
            //----------------------------------------------------------------------------------------
            var calendario = TimeManagement.getDateInfo() as Lang.Dictionary<Lang.String, Lang.String>;
            var time = TimeManagement.getTimeString() as Lang.Dictionary<String, String>;
            var dim = dc.getTextDimensions(calendario["giorno"].substring(0, 2), Graphics.FONT_XTINY);

            var fontOra=(_rectCalendar["tema"] as Lang.Dictionary)["font1"] as Lang.Number;
            var fontCalendario=(_rectCalendar["tema"] as Lang.Dictionary)["font2"] as Lang.Number;
            var fontMinuti=(_rectCalendar["tema"] as Lang.Dictionary)["font3"] as Lang.Number;
            
            dc.setColor(fontCalendario, Graphics.COLOR_TRANSPARENT);
            dc.drawText(205, 130 - dim[1] / 2, Graphics.FONT_XTINY,
                (calendario["mese"].substring(0, 3)).toUpper(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(205, 130 + dim[1] / 2, Graphics.FONT_XTINY,
                calendario["giorno"].substring(0, 2) + " " + calendario["numGiorno"],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
            dc.setColor(fontOra, Graphics.COLOR_TRANSPARENT);
            dc.drawText(rect1X - rect1W / 2 + rect1H + 15, rect1Y,
                Graphics.FONT_NUMBER_MILD, time["ore"],
                Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            dc.setColor(fontMinuti, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                (rect1X - rect1W / 2 + rect1H) + dc.getTextDimensions(time["ore"], Graphics.FONT_NUMBER_MILD)[0] + 5,
                rect1Y, Graphics.FONT_SYSTEM_MEDIUM, ":" + time["minuti"],
                Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // SCRIVI NEL RETTANGOLO PICCOLO 
            //----------------------------------------------------------------------------------------
            var city = WeatherData.getCity();
            var wtime = WeatherData.getWeatherTime();
            var meteoStr = (city != null ? city : "--") + " " + (wtime != null ? wtime : "--");
            var fontCitta=(_rectNotch["tema"] as Lang.Dictionary)["font1"] as Lang.Number;
            dc.setColor(fontCitta, Graphics.COLOR_TRANSPARENT);
            dc.drawText((rect2X - rect2W / 2) + 15, rect2Y, Graphics.FONT_XTINY, meteoStr,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

              
        }

    // ============================================================
    // SFONDO — componenti grafiche pure, nessun dato dinamico
    // ============================================================
    function _drawSfondo1(dc as Dc) as Void { //questa non puo essere fatta dentro initialize perchè ancora non c'è il DC
       



      
        //DISEGNA CERCHIO+BORDO CENTRALE
        
        CircleFill.draw(dc, circle3X, circle3Y, rad3, (_circleCntrl["tema"] as Lang.Dictionary)["back"] as Lang.Number);
        Circle.draw(dc, circle3X, circle3Y, rad3, (_circleCntrl["tema"] as Lang.Dictionary)["stroke"] as Lang.Number, 2);
       

        //DISEGNA CERCHIO+BORDO SINISTRA
        CircleFill.draw(dc, circle1X, circle1Y, rad1, (_circleSx["tema"] as Lang.Dictionary)["back"] as Lang.Number);
        Circle.draw(dc, circle1X, circle1Y, rad1, (_circleSx["tema"] as Lang.Dictionary)["stroke"] as Lang.Number, 2);


        //DISEGNA CERCHIO+BORDO DESTRA
        CircleFill.draw(dc, circle2X, circle2Y, rad2, (_circleDx["tema"] as Lang.Dictionary)["back"] as Lang.Number);
        Circle.draw(dc, circle2X, circle2Y, rad2, (_circleDx["tema"] as Lang.Dictionary)["stroke"] as Lang.Number, 2);
      

        //DISEGNA RETTANGOLO GRANDE
        RectFill.draw(dc, rect1X, rect1Y, rect1W, rect1H, (_rectCalendar["tema"] as Lang.Dictionary)["back"] as Lang.Number, 20);
        
         
        //DISEGNA RETTANGOLO PICCOLO
        RectFill.draw(dc, rect2X, rect2Y, rect2W, rect2H, (_rectNotch["tema"] as Lang.Dictionary)["back"] as Lang.Number, 12);
        


    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _settingsChanged = true;  // ← aggiungi questa riga
        var coords = WeatherCoords.getCoords();
        Logger.log("onExitSleep", "coords: lat=" + coords[0] + " lon=" + coords[1]);

        WeatherCoords.saveCoords(coords);
        Logger.log("onExitSleep", "coordinate salvate");

        WeatherService.registerTimer(30);
        Logger.log("onExitSleep", "timer registrato");

        var data = WeatherData.loadFromStorage();
        if (data != null) {
            WeatherData.parseData(data);
            Logger.log("onExitSleep", "dati meteo aggiornati");
            WatchUi.requestUpdate();    // ← forza ridisegno
        }
    }

    function onEnterSleep() as Void {
    }

}
