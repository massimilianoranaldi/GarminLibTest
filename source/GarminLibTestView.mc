import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Timer;
import Toybox.WatchUi;

class GarminLibTestView extends WatchUi.WatchFace {

    var _settingsChanged =true;
    
    //Costanti grafici 
    const GRAFICO_RINGTICK = 1;
    const GRAFICO_PROGRESSBARDASH = 2;
    const GRAFICO_SEGMENTEDBAR = 3;

    //Costanti cerchi

    const CERCHIO_CENTRALE = 1;
    const CERCHIO_SX = 2;
    const CERCHIO_DX = 3;

    //Costanti anelli

    const ANELLO_INTERNO = 1;
    const ANELLO_ESTERNO = 2;
    

    // ── ISTANZE — inizializzate in initialize() ────────────────
    var _arc as SegmentedArc or Null = null;
    var _tema =0;
    var _heartBeat  = 0;
    var _hrTimer    as Timer.Timer or Null = null;

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

    var _colorFillRingDot1=null;
    var _colorBackgRingDot1=null;
    var _colorFillRingDot2=null;
    var _colorBackgRingDot2=null;

    //meteoUp/meteoDown
    var _cfgMeteoUp as Lang.Dictionary or Null = null;
    var _cfgMeteoDown as Lang.Dictionary or Null = null;

    //METEO item
    var _cfgMeteoItemSx as Lang.Dictionary or Null = null;
    var _cfgMeteoItemDx as Lang.Dictionary or Null = null;

    //ACTIVITY  item
    var _cfgActivityItemSx as Lang.Dictionary or Null = null;
    var _cfgActivityItemDx as Lang.Dictionary or Null = null;

    //HEART  item
    var _cfgHeartItemSx as Lang.Boolean  = false;
    var _cfgHeartItemDx as Lang.Boolean  = false;

    //System  item
    var _cfgSystemItemSx as Lang.Dictionary or Null = null;
    var _cfgSystemItemDx as Lang.Dictionary or Null = null;

    //SUN  item
    var _cfgSunItemSx as Lang.Dictionary or Null = null;
    var _cfgSunItemDx as Lang.Dictionary or Null = null;

    // dimensioni
    //CERCHIO CENTRALE 
    var circle3X = 130;
    var circle3Y = 50;
    var rad3=45;
    //CERCHIO SINISTRA 
    var circle1X = 50;
    var circle1Y = 75;
    var rad1=32;
    //CERCHIO DESTRA
    var circle2X = 210;
    var circle2Y = 75;
    var rad2=31;        
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

    // ============================================================
    // LIFECYCLE
    // ============================================================

    function initialize() {
        //Logger.log("initialize", "inizio");
        WatchFace.initialize();

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
        //Logger.log("initialize", "fine");
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void {
        //Logger.log("onShow : >>>>>>>>>>>>>>>>>>>>","SONO DENTRO : onShow dopo richiama onUpdate");
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
            _hrTimer = new Timer.Timer();
            _hrTimer.start(method(:onHeartBeat), 500, true);
    }

    function onHeartBeat() as Void {
        _heartBeat = (_heartBeat + 1) % 3;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

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

    function onHide() as Void {
        if (_hrTimer != null) { _hrTimer.stop(); _hrTimer = null; }
    }

    function onExitSleep() as Void {
        _settingsChanged = true;
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
        _hrTimer = new Timer.Timer();
        _hrTimer.start(method(:onHeartBeat), 500, true);
    }

    function onEnterSleep() as Void {
        if (_hrTimer != null) { 
            _hrTimer.stop(); 
            _hrTimer = null; 
        }
    }

    // ============================================================
    // SETUP — lettura Properties e dispatcher item
    // ============================================================

    function _getAndSetUpProperties(dc as Dc) as Void {
        var tema = Application.Properties.getValue("temiQuadrante") as Lang.Number;
        _tema=tema;

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
        "dati"  { "tipo" "valore" "goal" "suffisso" }
        "tema"  { "back" "fill" "font" "icona" }
    }*/
        _datiRing1 = {"dati" => _getParameterActivity(goals, tipo1),"tema" => _getTemaActivity1(tipo1, tema)};
        _datiRing2 = {"dati" => _getParameterActivity(goals, tipo2),"tema" => _getTemaActivity2(tipo2, tema)};

    /* STRUTTURA CIRCLE 
        _circle<n> { "tema" { "back" "stroke" } }*/
        _circleSx    = {"tema" => _getTemaCircleSx(tema)};
        _circleCntrl = {"tema" => _getTemaCircleCntrl(tema)};
        _circleDx    = {"tema" => _getTemaCircleDx(tema)};

    /* STRUTTURA RECT 
        _rect<n> { "tema" { "back" "font1" "font2" "font3" } }*/        
        _rectNotch    = {"tema" => _getTemaRectNotch(tema)};
        _rectCalendar = {"tema" => _getTemaRectCalendar(tema)};

    /* STRUTTURA DATI METEO UP/DOWN 
    _cfgMeteoUp<n> { "valore" "icona16" "icona24" "fontColor" }*/
        var meteoUp   = Application.Properties.getValue("cerchioGrandeMeteoUp")   as Lang.Number;
        var meteoDown = Application.Properties.getValue("cerchioGrandeMeteoDown") as Lang.Number;
        _cfgMeteoUp   = getIconValueMeteoStatica(meteoUp,   tema,CERCHIO_CENTRALE);
        _cfgMeteoDown = getIconValueMeteoStatica(meteoDown, tema,CERCHIO_CENTRALE);

        var itemCerchioSx = Application.Properties.getValue("cerchioSinistraItems") as Lang.Number;
        getItemsSx(itemCerchioSx, _tema);

        var itemCerchioDx = Application.Properties.getValue("cerchioDestraItems") as Lang.Number;
        getItemsDx(itemCerchioDx, _tema);
    }

    function getItemsSx(itemCerchioSx as Lang.Number, tema as Lang.Number) as Void {
        // reset — solo il campo pertinente verrà valorizzato
        _cfgMeteoItemSx    = null;
        _cfgSunItemSx      = null;
        _cfgSystemItemSx   = null;
        _cfgHeartItemSx    = false;
        _cfgActivityItemSx = null;

        switch (itemCerchioSx) {
            // meteo
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
                _cfgMeteoItemSx = getIconValueMeteoStatica(itemCerchioSx, tema,CERCHIO_SX);
                break;
            // Alba e Tramonto
            case 7:
                _cfgSunItemSx = getSunItem(tema,CERCHIO_SX);
                break;
            // Informazioni Sistema (batteria+bluetooth)
            case 8:
                _cfgSystemItemSx = getSystemItem(tema,CERCHIO_SX);
                break;
            // Frequenza Cardiaca
            case 9:
                _cfgHeartItemSx = true;
                break;
            // Attività
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
                _cfgActivityItemSx = getAttivitaItem(itemCerchioSx, tema,CERCHIO_SX);
                break;
            default:
                break;
        }
    }

    function getItemsDx(itemCerchioDx as Lang.Number, tema as Lang.Number) as Void {
        // reset
        _cfgMeteoItemDx    = null;
        _cfgSunItemDx      = null;
        _cfgSystemItemDx   = null;
        _cfgHeartItemDx    = false;
        _cfgActivityItemDx = null;

        switch (itemCerchioDx) {
            // meteo
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
                _cfgMeteoItemDx = getIconValueMeteoStatica(itemCerchioDx, tema,CERCHIO_DX);
                break;
            // Alba e Tramonto
            case 7:
                _cfgSunItemDx = getSunItem(tema,CERCHIO_DX);
                break;
            // Informazioni Sistema (batteria+bluetooth)
            case 8:
                _cfgSystemItemDx = getSystemItem(tema,CERCHIO_DX);
                break;
            // Frequenza Cardiaca
            case 9:
                _cfgHeartItemDx = true;
                break;
            // Attività
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
                _cfgActivityItemDx = getAttivitaItem(itemCerchioDx, tema,CERCHIO_DX);
                break;
            default:
                break;
        }
    }

    // ============================================================
    // TEMA — colori per ogni elemento grafico
    // ============================================================

    // a partire  dal tema recupera i colori associati al back,stroke altrimenti va in default
    function _getTemaCircleSx(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3 };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2 };
            case 4: return { "back" => Palette.rosa1, "stroke" => Palette.rosa3 };
            case 5: return { "back" => Palette.blu5, "stroke" => Palette.ciano2 };
            default: return {
                "back"   => Application.Properties.getValue("cerchioSxSfondo")   as Lang.Number,
                "stroke" => Application.Properties.getValue("cerchioSxContorno") as Lang.Number
            };
        }
    }

    function _getTemaCircleCntrl(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3 };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2 };
            case 4: return { "back" => Palette.nero2, "stroke" => Palette.rosa3 };
            case 5: return { "back" => Palette.verde5, "stroke" => Palette.giallo3 };
            default: return {
                "back"   => Application.Properties.getValue("cerchioGrandeSfondo")   as Lang.Number,
                "stroke" => Application.Properties.getValue("cerchioGrandeContorno") as Lang.Number
            };
        }
    }

    // a partire  dal tema recupera i colori associati al back,stroke altrimenti va in default
    function _getTemaCircleDx(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => Palette.giallo3 };
            case 2: return { "back" => Palette.grigio6, "stroke" => Palette.arancione3 };
            case 3: return { "back" => Palette.grigio6, "stroke" => Palette.ciano2 };
            case 4: return { "back" => Palette.nero1, "stroke" => Palette.rosa3 };
            case 5: return { "back" => Palette.verde5, "stroke" => Palette.giallo3 };
            default: return {
                "back"   => Application.Properties.getValue("cerchioDxSfondo")   as Lang.Number,
                "stroke" => Application.Properties.getValue("cerchioDxContorno") as Lang.Number
            };
        }
    }

    // a partire  dal tema recupera i colori associati al back
    function _getTemaRectNotch(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => null,    "font1"=>Palette.arancione1, "font2"=>null, "font3"=>null };
            case 2: return { "back" => Palette.grigio6, "stroke" => null, "font1"=>Palette.arancione1, "font2"=>null, "font3"=>null };
            case 3: return { "back" => Palette.grigio6, "stroke" => null,     "font1"=>Palette.arancione1, "font2"=>null, "font3"=>null };
            case 4: return { "back" => Palette.rosa3, "stroke" => null,      "font1"=>Palette.bianco1, "font2"=>null, "font3"=>null };
            case 5: return { "back" => Palette.verde5, "stroke" => null,      "font1"=>Palette.oro2, "font2"=>null, "font3"=>null };
            default: return {
                "back"  => Application.Properties.getValue("retMeteoSfondo")   as Lang.Number,
                "font1" => Application.Properties.getValue("coloreCittaMeteo") as Lang.Number,
                "font2" => null,
                "font3" => null
            };
        }
    }

    // a partire  dal tema recupera i colori associati al back
    function _getTemaRectCalendar(tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "stroke" => null,    "font1"=>Palette.arancione1, "font2"=>Palette.arancione1, "font3"=>Palette.arancione1 };
            case 2: return { "back" => Palette.grigio6, "stroke" => null, "font1"=>Palette.arancione1, "font2"=>Palette.arancione1, "font3"=>Palette.arancione1 };
            case 3: return { "back" => Palette.grigio6, "stroke" => null,     "font1"=>Palette.arancione1, "font2"=>Palette.arancione1, "font3"=>Palette.arancione1 };
            case 4: return { "back" => Palette.bianco1, "stroke" => null,      "font1"=>Palette.rosa3, "font2"=>Palette.nero2, "font3"=>Palette.rosa3 };
            case 5: return { "back" => Palette.oro2, "stroke" => null,      "font1"=>Palette.verde5, "font2"=>Palette.marrone3, "font3"=>Palette.nero1 };
            default: return {
                "back"  => Application.Properties.getValue("retOreSfondo")      as Lang.Number,
                "font1" => Application.Properties.getValue("coloreOre")         as Lang.Number,
                "font2" => Application.Properties.getValue("coloreMinuti")      as Lang.Number,
                "font3" => Application.Properties.getValue("coloreCalendario")  as Lang.Number
            };
        }
    }
 
    // a partire dal tipo e dal tema recupera i colori associati al back,fill e font e icona colorata e restituisce i valori default per l'attività 
    //ANELLO ESTERNO
    function _getTemaActivity1(tipo as Lang.Number, tema as Lang.Number) as Lang.Dictionary {
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "fill" => Palette.giallo3,    "font" => Palette.giallo3,    "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_ESTERNO) };
            case 2: return { "back" => Palette.grigio6, "fill" => Palette.arancione3, "font" => Palette.arancione3, "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_ESTERNO) };
            case 3: return { "back" => Palette.grigio6, "fill" => Palette.ciano2,     "font" => Palette.ciano2,     "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_ESTERNO) };
            case 4: return { "back" => Palette.grigio6, "fill" => Palette.rosa3,      "font" => Palette.rosa3,      "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_ESTERNO) };
            case 5: return { "back" => Palette.verde5, "fill" => Palette.oro2,      "font" => Palette.arancione3,      "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_ESTERNO) };
            default: return {
                "back"  => Application.Properties.getValue("coloreSfondoAttivita1")  as Lang.Number,
                "fill"  => Application.Properties.getValue("coloreRipienoAttivita1") as Lang.Number,
                "font"  => Application.Properties.getValue("coloreFontArcoEsterno")  as Lang.Number,
                "icona" => _getIconActivityFromColor(tipo, Application.Properties.getValue("coloreIconaAttivita1") as Lang.Number)
            };
        }
    }

    // a partire dal tipo e dal tema recupera i colori associati al back,fill e font e icona colorata e restituisce i valori default per l'attività  
    //ANELLO INTERNO
    function _getTemaActivity2(tipo as Lang.Number, tema as Lang.Number) as Lang.Dictionary {
        
        switch (tema) {
            case 1: return { "back" => Palette.grigio6, "fill" => Palette.giallo3,    "font" => Palette.giallo3,    "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_INTERNO) };
            case 2: return { "back" => Palette.grigio6, "fill" => Palette.arancione3, "font" => Palette.arancione3, "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_INTERNO) };
            case 3: return { "back" => Palette.grigio6, "fill" => Palette.ciano2,     "font" => Palette.ciano2,     "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_INTERNO) };
            case 4: return { "back" => Palette.rosa3, "fill" => Palette.bianco1,      "font" => Palette.bianco1,      "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_INTERNO) };
            case 5: return { "back" => Palette.blu5, "fill" => Palette.ciano2,      "font" => Palette.bianco1,      "icona" => _getIconActivityFromTheme(tipo, tema,ANELLO_INTERNO) };
            default: return {
                "back"  => Application.Properties.getValue("coloreSfondoAttivita2")  as Lang.Number,
                "fill"  => Application.Properties.getValue("coloreRipienoAttivita2") as Lang.Number,
                "font"  => Application.Properties.getValue("coloreFontArcoInterno")  as Lang.Number,
                "icona" => _getIconActivityFromColor(tipo, Application.Properties.getValue("coloreIconaAttivita2") as Lang.Number)
            };
        }
    }

    function getCfgRingTick(tema as Lang.Number or Null,lato as Lang.Number) as Lang.Dictionary {
        var t = (tema != null) ? tema : 0;
        var fontColor=Palette.bianco1;
        switch (t) {
            case 1:  return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, "sfondo" => Palette.grigio6, "fill" => Palette.giallo3,    "colTacca" => Palette.bianco1,"fontColor" => fontColor };
            case 2:  return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, "sfondo" => Palette.grigio6, "fill" => Palette.arancione3, "colTacca" => Palette.bianco1,"fontColor" => fontColor };
            case 3:  return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, "sfondo" => Palette.grigio6, "fill" => Palette.ciano2,     "colTacca" => Palette.bianco1,"fontColor" => fontColor };
            case 4:  return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, "sfondo" => Palette.grigio6, "fill" => Palette.rosa3,      "colTacca" => Palette.bianco1,
            "fontColor"=> (lato == CERCHIO_SX) ? Palette.nero1 : fontColor};
            case 5:  return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, 
            "sfondo" => (lato == CERCHIO_SX) ? Palette.blu2 : Palette.marrone3,//Palette.marrone3, 
            "fill" => (lato == CERCHIO_SX) ? Palette.ciano2 : Palette.verde3,//Palette.verde3,    
            "colTacca" => (lato == CERCHIO_SX) ? Palette.bianco2 : Palette.oro2,
            "fontColor" => fontColor};
            case 6:  return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, "sfondo" => Palette.grigio6, "fill" => Palette.bianco1,    "colTacca" => Palette.nero2,"fontColor" => fontColor   };
            default: return { "spessore" => 5, "raggio" => 25, "segmenti" => 10, "lunghezza" => 7, "sfondo" => Palette.blu2,    "fill" => Palette.ciano3,     "colTacca" => Palette.bianco1,"fontColor" => fontColor };
        }
    }

    function getCfgProgressBarDash(tema as Lang.Number or Null,lato as Lang.Number) as Lang.Dictionary {
        var t = (tema != null) ? tema : 0;
        switch (t) {
            case 1:  return { "segmenti" => 10, "gap" => 2, "sfondo" => Palette.grigio6, "fill" => Palette.giallo3    };
            case 2:  return { "segmenti" => 10, "gap" => 2, "sfondo" => Palette.grigio6, "fill" => Palette.arancione3 };
            case 3:  return { "segmenti" => 10, "gap" => 2, "sfondo" => Palette.grigio6, "fill" => Palette.ciano2     };
            case 4:  return { "segmenti" => 10, "gap" => 2, "sfondo" => Palette.grigio6, "fill" => Palette.rosa3      };
            case 5:  return { "segmenti" => 10, "gap" => 2, 
            "sfondo" => (lato == CERCHIO_SX) ? Palette.blu2 :Palette.marrone4, 
            "fill" => (lato == CERCHIO_SX) ? Palette.ciano2 :Palette.oro2   
            };
            case 6:  return { "segmenti" => 10, "gap" => 2, "sfondo" => Palette.grigio6, "fill" => Palette.bianco1    };
            default: return { "segmenti" => 10, "gap" => 2, "sfondo" => Palette.nero1,   "fill" => Palette.verde3     };
        }
    }

    function getCfgSegmentedBar(tema as Lang.Number or Null,lato as Lang.Number) as Lang.Array {
        var t = (tema != null) ? tema : 0;

        var c1 = Palette.rosso2; //0-25%
        var c2 = Palette.arancione3;//25-50%
        var c3 = Palette.giallo3;//50-75%
        var c4 = Palette.verde2;//75-100%
        var fontColor=Palette.bianco1;

        switch (t) {
            case 1:  c1 = Palette.rosso2;  c2 = Palette.arancione3; c3 = Palette.giallo4;    c4 = Palette.giallo3;    break;
            case 2:  c1 = Palette.rosso3;  c2 = Palette.arancione4; c3 = Palette.arancione3; c4 = Palette.arancione2; break;
            case 3:  c1 = Palette.rosso2;  c2 = Palette.ciano5;     c3 = Palette.ciano4;     c4 = Palette.ciano2;     break;
            case 4:  {
                c1 = Palette.rosso3;  
                c2 = Palette.viola4;     
                c3 = Palette.rosa3;      
                c4 = Palette.rosa2;  
                fontColor=(lato==CERCHIO_SX) ? Palette.nero1 : Palette.bianco1;
                break;}
            case 5:  c1 = Palette.rosso3; c2 = Palette.arancione3;    c3 = Palette.verde3;    c4 = Palette.verde2;    break;
            case 6:  c1 = Palette.rosso4;  c2 = Palette.arancione4; c3 = Palette.giallo4;    c4 = Palette.verde4;     break;
            default: c1 = Palette.rosso2;  c2 = Palette.arancione3; c3 = Palette.giallo3;    c4 = Palette.verde2;     break;
        }

        return [
            { "startVal" => 0,  "endVal" => 100, "spessore" => 3, "colore" => Palette.nero1, "stondato" => false ,"fontColor"=>fontColor},
            { "startVal" => 0,  "endVal" => 25,  "spessore" => 5, "colore" => c1,            "stondato" => true  ,"fontColor"=>fontColor},
            { "startVal" => 25, "endVal" => 50,  "spessore" => 5, "colore" => c2,            "stondato" => true  ,"fontColor"=>fontColor},
            { "startVal" => 50, "endVal" => 75,  "spessore" => 5, "colore" => c3,            "stondato" => true  ,"fontColor"=>fontColor},
            { "startVal" => 75, "endVal" => 100, "spessore" => 5, "colore" => c4,            "stondato" => true  ,"fontColor"=>fontColor}
        ] as Lang.Array;
    }

    // ============================================================
    // ITEM — costruzione cfg per ogni tipo di contenuto
    // ============================================================

    function getIconValueMeteoStatica(tipo as Lang.Number, tema as Lang.Number or Null,lato as Lang.Number) as Dictionary {
        var t = (tema != null) ? tema : 0 as Lang.Number;

        var icon16    = null;
        var icon24    = null;
        var value     = "n.d.";
        var fontColor = Palette.bianco1;

        // ── fontColor dal tema ────────────────────────────────────────
        switch (t) {
            case 1:  fontColor = Palette.giallo3;    break;
            case 2:  fontColor = Palette.arancione3; break;
            case 3:  fontColor = Palette.ciano2;     break;
            case 4:  
                        {
                if(lato == CERCHIO_SX)
                {fontColor=Palette.nero1;}
                else 
                {fontColor=Palette.rosa3;}
            
            
            break;}
            
            case 5: 
            {
                if(lato == CERCHIO_SX)
                {fontColor=Palette.ciano2;}
                else 
                {fontColor=Palette.marrone1;}
            
            
            break;}
            case 6:  fontColor = Palette.nero2;      break;
            default: fontColor = Palette.bianco1;    break;
        }

        // ── icona e valore dal tipo ───────────────────────────────────
        switch (tipo) {
            case 0: // Temperatura Percepita
                value = WeatherData.getTempPercepitaString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.termometro_giallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.termometro_arancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.termometro_ciano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.termometro_rosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.termometro_bianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.termometro_nero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.termometro_bianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.termometro_giallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.termometro_arancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.termometro_ciano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.termometro_rosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.termometro_bianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.termometro_nero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.termometro_bianco1_24x24)    as BitmapResource; break;
                }
                break;
            case 1: // Velocità Vento
                value = WeatherData.getWindString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.windGiallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.windArancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.windCiano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.windRosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.windBianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.windNero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.windBianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.windGiallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.windArancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.windCiano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.windRosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.windBianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.windNero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.windBianco1_24x24)    as BitmapResource; break;
                }
                break;
            case 2: // Copertura Cielo
                value = WeatherData.getCloudString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.cloudyGiallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.cloudyArancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.cloudyCiano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.cloudyRosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.cloudyBianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.cloudyNero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.cloudyBianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.cloudyGiallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.cloudyArancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.cloudyCiano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.cloudyRosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.cloudyBianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.cloudyNero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.cloudyBianco1_24x24)    as BitmapResource; break;
                }
                break;
            case 3: // Umidità
                value = WeatherData.getHumidityString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.rainGiallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.rainArancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.rainCiano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.rainRosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.rainBianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.rainNero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.rainBianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.rainGiallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.rainArancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.rainCiano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.rainRosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.rainBianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.rainNero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.rainBianco1_24x24)    as BitmapResource; break;
                }
                break;
            case 4: // Probabilità Precipitazione
                value = WeatherData.getPrecipProbabilityString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.umbrellaGiallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.umbrellaArancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.umbrellaCiano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.umbrellaRosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.umbrellaBianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.umbrellaNero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.umbrellaBianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.umbrellaGiallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.umbrellaArancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.umbrellaCiano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.umbrellaRosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.umbrellaBianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.umbrellaNero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.umbrellaBianco1_24x24)    as BitmapResource; break;
                }
                break;
            case 5: // Indice UV
                value = WeatherData.getUvString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.uvGiallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.uvArancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.uvCiano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.uvRosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.uvBianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.uvNero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.uvBianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.uvGiallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.uvArancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.uvCiano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.uvRosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.uvBianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.uvNero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.uvBianco1_24x24)    as BitmapResource; break;
                }
                break;
            case 6: // Livello Pioggia
                value = WeatherData.getPrecipString();
                switch (t) {
                    case 1:  icon16 = Application.loadResource(Rez.Drawables.pioggiaGiallo3_16x16)    as BitmapResource; break;
                    case 2:  icon16 = Application.loadResource(Rez.Drawables.pioggiaArancione3_16x16) as BitmapResource; break;
                    case 3:  icon16 = Application.loadResource(Rez.Drawables.pioggiaCiano2_16x16)     as BitmapResource; break;
                    case 4:  icon16 = Application.loadResource(Rez.Drawables.pioggiaRosa3_16x16)      as BitmapResource; break;
                    case 5:  icon16 = Application.loadResource(Rez.Drawables.pioggiaBianco1_16x16)    as BitmapResource; break;
                    case 6:  icon16 = Application.loadResource(Rez.Drawables.pioggiaNero2_16x16)      as BitmapResource; break;
                    default: icon16 = Application.loadResource(Rez.Drawables.pioggiaBianco1_16x16)    as BitmapResource; break;
                }
                switch (t) {
                    case 1:  icon24 = Application.loadResource(Rez.Drawables.pioggiaGiallo3_24x24)    as BitmapResource; break;
                    case 2:  icon24 = Application.loadResource(Rez.Drawables.pioggiaArancione3_24x24) as BitmapResource; break;
                    case 3:  icon24 = Application.loadResource(Rez.Drawables.pioggiaCiano2_24x24)     as BitmapResource; break;
                    case 4:  icon24 = Application.loadResource(Rez.Drawables.pioggiaRosa3_24x24)      as BitmapResource; break;
                    case 5:  icon24 = Application.loadResource(Rez.Drawables.pioggiaBianco1_24x24)    as BitmapResource; break;
                    case 6:  icon24 = Application.loadResource(Rez.Drawables.pioggiaNero2_24x24)      as BitmapResource; break;
                    default: icon24 = Application.loadResource(Rez.Drawables.pioggiaBianco1_24x24)    as BitmapResource; break;
                }
                break;
        }

        return { "icona16" => icon16, "icona24" => icon24, "valore" => value, "fontColor" => fontColor };
    }

    function getSunItem(tema as Lang.Number or Null,lato as Lang.Number) as Dictionary {

        Logger.log("getSunItem>>>>>>>>>>","lato="+lato+" tema="+tema);
        var t = (tema != null) ? tema : 0;

        // ── id drawable e colori font per ogni tema ───────────────────
        var idAlbaOn     = Rez.Drawables.sunriseSeaGiallo3_16x16;
        var idTramontoOn = Rez.Drawables.sunsetSeaArancione3_16x16;
        var fontAlbaOn   = Palette.giallo3; // è chiaro e visibile quando sono nelle ore NOTTURNE e sto andando verso alba
        var fontTramontoOn = Palette.arancione2; // è chiaro e visibile quando sono nelle ore DIURNE e sto andando verso tramonto
        var fontAlbaOff=Palette.grigio4;
        var fontTramontoOff=Palette.grigio4;

        switch (t) {
            case 1: // giallo3 → alba=giallo3 / tramonto=rosa3
                idAlbaOn       = Rez.Drawables.sunriseSeaGiallo3_16x16;
                idTramontoOn   = Rez.Drawables.sunsetSeaRosa3_16x16;
                fontAlbaOn     = Palette.giallo3;
                fontTramontoOn = Palette.rosa3;
                break;
            case 2: // arancione3 → alba=ciano2 / tramonto=arancione3
                idAlbaOn       = Rez.Drawables.sunriseSeaCiano2_16x16;
                idTramontoOn   = Rez.Drawables.sunsetSeaArancione3_16x16;
                fontAlbaOn     = Palette.ciano2;
                fontTramontoOn = Palette.arancione3;
                break;
            case 3: // ciano2 → alba=ciano2 / tramonto=giallo3
                idAlbaOn       = Rez.Drawables.sunriseSeaCiano2_16x16;
                idTramontoOn   = Rez.Drawables.sunsetSeaGiallo3_16x16;
                fontAlbaOn     = Palette.ciano2;
                fontTramontoOn = Palette.giallo3;
                break;
            case 4: // rosa3 → alba=rosa3 / tramonto=giallo3
                Logger.log("getSunItem>>>>>>>>>>"," entrato gestione case 4 ");
                idAlbaOn       = Rez.Drawables.sunriseSeaRosa3_16x16;
                idTramontoOn   = (lato==CERCHIO_SX) ? Rez.Drawables.sunsetSeaRosa3_16x16 : Rez.Drawables.sunsetSeaGiallo3_16x16;
                fontAlbaOn     = Palette.rosa3;
                fontTramontoOn = (lato==CERCHIO_SX) ? Palette.rosa3 : Palette.giallo3;
                
                fontAlbaOff    =Palette.grigio3;
                fontTramontoOff=Palette.grigio3;
                break;
            case 5: // grigio4 → alba=bianco1 / tramonto=arancione3
                idAlbaOn       = Rez.Drawables.sunriseSeaGiallo3_16x16;
                idTramontoOn   = Rez.Drawables.sunsetSeaArancione3_16x16;
                fontAlbaOn     = Palette.giallo3;
                fontTramontoOn = Palette.arancione3;
                fontAlbaOff    =Palette.grigio3;
                fontTramontoOff=Palette.grigio3;
                break;
            case 6: // nero2 → alba=giallo3 / tramonto=ciano2
                idAlbaOn       = Rez.Drawables.sunriseSeaGiallo3_16x16;
                idTramontoOn   = Rez.Drawables.sunsetSeaCiano2_16x16;
                fontAlbaOn     = Palette.giallo3;
                fontTramontoOn = Palette.ciano2;
                break;
            default: // 0 bianco1 → alba=giallo3 / tramonto=arancione3
                idAlbaOn       = Rez.Drawables.sunriseSeaGiallo3_16x16;
                idTramontoOn   = Rez.Drawables.sunsetSeaArancione3_16x16;
                fontAlbaOn     = Palette.giallo3;
                fontTramontoOn = Palette.arancione2;
                break;
        }

        return {
            "iconaAlbaOn"      => Application.loadResource(idAlbaOn)                              as BitmapResource,
            "iconaAlbaOff"     => Application.loadResource(Rez.Drawables.sunriseSeaGrigio4_16x16) as BitmapResource,
            "iconaTramontoOn"  => Application.loadResource(idTramontoOn)                          as BitmapResource,
            "iconaTramontoOff" => Application.loadResource(Rez.Drawables.sunsetSeaGrigio4_16x16)  as BitmapResource,
            "fontAlbaOn"       => fontAlbaOn,
            "fontAlbaOff"      => fontAlbaOff,
            "fontTramontoOn"   => fontTramontoOn,
            "fontTramontoOff"  => fontTramontoOff
        };
    }

    function getSystemItem(tema as Lang.Number or Null,lato as Lang.Number) as Dictionary {

        var t = (tema != null) ? tema : 0;

        var idBtOn    = Rez.Drawables.bluetoothCiano2;
        var idBolt    = Rez.Drawables.boltBianco1;
        var fontColor = Palette.bianco1;
        var cb1       = Palette.rosso2;
        var cb2       = Palette.arancione1;
        var cb3       = Palette.arancione3;
        var cb4       = Palette.verde2;

        switch (t) {
            case 1: // giallo3
                idBtOn    = Rez.Drawables.bluetoothGiallo3;
                idBolt    = Rez.Drawables.boltGiallo3;
                fontColor = Palette.giallo3;
                cb1 = Palette.rosso2;    cb2 = Palette.arancione3; cb3 = Palette.giallo4;    cb4 = Palette.giallo3;
                break;
            case 2: // arancione3
                idBtOn    = Rez.Drawables.bluetoothArancione3;
                idBolt    = Rez.Drawables.boltArancione3;
                fontColor = Palette.arancione3;
                cb1 = Palette.rosso3;    cb2 = Palette.arancione4; cb3 = Palette.arancione3; cb4 = Palette.arancione2;
                break;
            case 3: // ciano2
                idBtOn    = Rez.Drawables.bluetoothCiano2;
                idBolt    = Rez.Drawables.boltCiano2;
                fontColor = Palette.ciano2;
                cb1 = Palette.rosso2;    cb2 = Palette.ciano5;     cb3 = Palette.ciano4;     cb4 = Palette.ciano2;
                break;
            case 4: // rosa3
                idBtOn    = Rez.Drawables.bluetoothRosa3;
                idBolt    = Rez.Drawables.boltRosa3;
                fontColor = (lato == CERCHIO_SX)? Palette.nero1 : Palette.rosa3;
                cb1 = Palette.rosso3;    cb2 = Palette.viola4;     cb3 = Palette.rosa3;      cb4 = Palette.rosa2;
                break;
            case 5: // grigio4
                //idBtOn    = Rez.Drawables.bluetoothNero2;
                //case 5: fontColor = (lato == CERCHIO_SX) ? Palette.ciano2 : Palette.verde3; break;
                idBtOn    = (lato == CERCHIO_SX)?Rez.Drawables.bluetoothCiano2 : Rez.Drawables.bluetoothNero2;
                idBolt    = Rez.Drawables.boltBianco1;
                fontColor = Palette.bianco1;
                cb1 = Palette.rosso3;   cb2 = Palette.arancione3;    cb3 = Palette.verde3;    cb4 = Palette.verde2;
                break;
            case 6: // nero2
                idBtOn    = Rez.Drawables.bluetoothBianco1;
                idBolt    = Rez.Drawables.boltBianco1;
                fontColor = Palette.bianco1;
                cb1 = Palette.rosso4;    cb2 = Palette.arancione4; cb3 = Palette.giallo4;    cb4 = Palette.verde4;
                break;
            default: // 0 bianco1
                idBtOn    = Rez.Drawables.bluetoothCiano2;
                idBolt    = Rez.Drawables.boltBianco1;
                fontColor = Palette.bianco1;
                cb1 = Palette.rosso2;    cb2 = Palette.arancione1; cb3 = Palette.arancione3; cb4 = Palette.verde2;
                break;
        }

        return {
            "iconaBluetoothOn"  => Application.loadResource(idBtOn)                           as BitmapResource,
            "iconaBluetoothOff" => Application.loadResource(Rez.Drawables.bluetoothGrigio4)   as BitmapResource,
            "iconaBatteria"     => Application.loadResource(idBolt)                           as BitmapResource,
            "fontColor" => fontColor,
            "colBatt1"  => cb1, "colBatt2" => cb2, "colBatt3" => cb3, "colBatt4" => cb4
        };
    }

    function getAttivitaItem(tipoAttivita as Lang.Number, tema as Lang.Number or Null,lato as Lang.Number) as Dictionary {

        var t = (tema != null) ? tema : 0;

        // ── fontColor dal tema ────────────────────────────────────────
        var fontColor = Palette.bianco1;
        switch (t) {
            case 1:  fontColor = Palette.giallo3;    break;
            case 2:  fontColor = Palette.arancione3; break;
            case 3:  fontColor = Palette.ciano2;     break;
            case 4:  fontColor = (lato == CERCHIO_SX) ? Palette.nero1 : Palette.rosa3;      break;
            case 5: fontColor = (lato == CERCHIO_SX) ? Palette.ciano2 : Palette.verde3; break;
            case 6:  fontColor = Palette.nero2;      break;
            default: fontColor = Palette.bianco1;    break;
        }

        // ── valore, goal, suffisso dal tipo ──────────────────────────
        var valore      = 0;
        var goal        = 1;
        var suffisso    = "";
        var tipoGrafico = 0;

        var info = ActivityMonitor.getInfo();

        switch (tipoAttivita) {
            case 10: // Passi
                valore   = (info.steps != null)             ? info.steps                   : 0;
                goal     = Application.Properties.getValue("goalSTEP") as Lang.Number;
                suffisso = "";
                tipoGrafico=GRAFICO_RINGTICK;
                break;
            case 11: // Calorie
                valore   = (info.calories != null)          ? info.calories                : 0;
                goal     = Application.Properties.getValue("goalCALORIE") as Lang.Number;
                suffisso = "c";
                tipoGrafico=GRAFICO_RINGTICK;
                break;
            case 12: // Piani Saliti
                valore   = (info.floorsClimbed != null)     ? info.floorsClimbed           : 0;
                goal     = Application.Properties.getValue("goalSTAIRS") as Lang.Number;
                suffisso = "s";
                tipoGrafico=GRAFICO_PROGRESSBARDASH;
                break;
            case 13: // Minuti Attività Settimana
                valore   = (info.activeMinutesWeek != null) ? info.activeMinutesWeek.total : 0;
                goal     = Application.Properties.getValue("goalMINWEEK") as Lang.Number;
                suffisso = "mw";
                tipoGrafico=GRAFICO_RINGTICK;
                break;
            case 14: // Minuti Attività Giorno
                valore   = (info.activeMinutesDay != null)  ? info.activeMinutesDay.total  : 0;
                goal     = Application.Properties.getValue("goalMINDAY") as Lang.Number;
                suffisso = "md";
                tipoGrafico=GRAFICO_RINGTICK;
                break;
            case 15: // Stress
                valore   = ActivityData.getStress().toNumber();
                goal     = 100;
                suffisso = "%";
                tipoGrafico=GRAFICO_SEGMENTEDBAR;
                break;
            case 16: // Body Battery
                valore   = ActivityData.getBodyBattery().toNumber();
                goal     = 100;
                suffisso = "%";
                tipoGrafico=GRAFICO_SEGMENTEDBAR;
                break;
        }

        // ── icona 24x24 dal tipo e dal tema ──────────────────────────
        var icona = null;

        switch (tipoAttivita) {
            case 10: // Passi
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconPassiGiallo3)       as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconPassiArancione3)    as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconPassiCiano2)        as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconPassiRosa3)         as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconPassi)       as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconPassiNero2)         as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconPassi)              as BitmapResource; break;
                }
                break;
            case 11: // Calorie
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconCalorieGiallo3)     as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconCalorieArancione3)  as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconCalorieCiano2)      as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconCalorieRosa3)       as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconCalorie)     as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconCalorieNero2)       as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconCalorie)            as BitmapResource; break;
                }
                break;
            case 12: // Piani Saliti
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconPianiSalitiGiallo3)    as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconPianiSalitiArancione3) as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconPianiSalitiCiano2)     as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconPianiSalitiRosa3)      as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconPianiSaliti)    as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconPianiSalitiNero2)      as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconPianiSaliti)           as BitmapResource; break;
                }
                break;
            case 13: // Min Settimana
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconMinWeekGiallo3)     as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconMinWeekArancione3)  as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconMinWeekCiano2)      as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconMinWeekRosa3)       as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconMinWeek)     as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconMinWeekNero2)       as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconMinWeek)            as BitmapResource; break;
                }
                break;
            case 14: // Min Giorno
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconMinDayGiallo3)      as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconMinDayArancione3)   as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconMinDayCiano2)       as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconMinDayRosa3)        as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconMinDay)      as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconMinDayNero2)        as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconMinDay)             as BitmapResource; break;
                }
                break;
            case 15: // Stress
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconStressGiallo3)      as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconStressArancione3)   as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconStressCiano2)       as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconStressRosa3)        as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconStress)      as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconStressNero2)        as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconStress)             as BitmapResource; break;
                }
                break;
            case 16: // Body Battery
                switch (t) {
                    case 1:  icona = Application.loadResource(Rez.Drawables.iconBodyBatteryGiallo3)    as BitmapResource; break;
                    case 2:  icona = Application.loadResource(Rez.Drawables.iconBodyBatteryArancione3) as BitmapResource; break;
                    case 3:  icona = Application.loadResource(Rez.Drawables.iconBodyBatteryCiano2)     as BitmapResource; break;
                    case 4:  icona = Application.loadResource(Rez.Drawables.iconBodyBatteryRosa3)      as BitmapResource; break;
                    case 5:  icona = Application.loadResource(Rez.Drawables.iconBodyBattery)    as BitmapResource; break;
                    case 6:  icona = Application.loadResource(Rez.Drawables.iconBodyBatteryNero2)      as BitmapResource; break;
                    default: icona = Application.loadResource(Rez.Drawables.iconBodyBattery)           as BitmapResource; break;
                }
                break;
        }

        return {
            "tipo"        => tipoAttivita,
            "tipoGrafico" => tipoGrafico,
            "valore"      => valore,
            "goal"        => goal,
            "suffisso"    => suffisso,
            "fontColor"   => fontColor,
            "icona"       => icona
        };
    }

    // ============================================================
    // ACTIVITY — helper interni per gli anelli attività principali
    // ============================================================

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
            default: return { "tipo" => tipo, "valore" => 0, "goal" => 1, "suffisso" => "" };
        }
    }

    // a partire dal tipo e del tema recupera icona colorata
    function _getIconActivityFromTheme(tipo as Lang.Number, tema as Lang.Number or Null,lato as Lang.Number) as BitmapResource or Null {
        var t = (tema != null) ? tema : 0 as Lang.Number;
        switch (tipo) {
            case ActivityType.ACTIVITY_PASSI:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconPassiGiallo3)        as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconPassiArancione3)     as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconPassiCiano2)         as BitmapResource;
                    case 4:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconPassi
                                : Rez.Drawables.iconPassiRosa3
                            ) as BitmapResource;

                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconPassi
                                : Rez.Drawables.iconPassiArancione3
                            ) as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconPassi)               as BitmapResource;
                }
            case ActivityType.ACTIVITY_CALORIE:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconCalorieGiallo3)      as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconCalorieArancione3)   as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconCalorieCiano2)       as BitmapResource;
                    case 4:  
                        return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconCalorie
                                : Rez.Drawables.iconCalorieRosa3
                            ) as BitmapResource;
                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconCalorie
                                : Rez.Drawables.iconCalorieArancione3
                            ) as BitmapResource;
                    default: return Application.loadResource(Rez.Drawables.iconCalorie)             as BitmapResource;
                }
            case ActivityType.ACTIVITY_GRADINI:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconPianiSalitiGiallo3)    as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconPianiSalitiArancione3) as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconPianiSalitiCiano2)     as BitmapResource;
                    case 4:  
                        return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconPianiSaliti
                                : Rez.Drawables.iconPianiSalitiRosa3
                            ) as BitmapResource;
                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconPianiSaliti
                                : Rez.Drawables.iconPianiSalitiArancione3
                            ) as BitmapResource;                    
                    default: return Application.loadResource(Rez.Drawables.iconPianiSaliti)           as BitmapResource;
                }
            case ActivityType.ACTIVITY_MIN_WEEK:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconMinWeekGiallo3)      as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconMinWeekArancione3)   as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconMinWeekCiano2)       as BitmapResource;
                    case 4:  
                        return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconMinWeek
                                : Rez.Drawables.iconMinWeekRosa3
                            ) as BitmapResource;
                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconMinWeek
                                : Rez.Drawables.iconMinWeekArancione3
                            ) as BitmapResource;                      
                    default: return Application.loadResource(Rez.Drawables.iconMinWeek)             as BitmapResource;
                }
            case ActivityType.ACTIVITY_MIN_DAY:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconMinDayGiallo3)       as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconMinDayArancione3)    as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconMinDayCiano2)        as BitmapResource;
                    case 4:  
                        return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconMinDay
                                : Rez.Drawables.iconMinDayRosa3
                            ) as BitmapResource;
                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconMinDay
                                : Rez.Drawables.iconMinDayArancione3
                            ) as BitmapResource;                      
                    default: return Application.loadResource(Rez.Drawables.iconMinDay)              as BitmapResource;
                }
            case ActivityType.ACTIVITY_STRESS:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconStressGiallo3)       as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconStressArancione3)    as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconStressCiano2)        as BitmapResource;
                    case 4:  
                        return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconStress
                                : Rez.Drawables.iconStressRosa3
                            ) as BitmapResource;
                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconStress
                                : Rez.Drawables.iconStressArancione3
                            ) as BitmapResource;                      
                    default: return Application.loadResource(Rez.Drawables.iconStress)              as BitmapResource;
                }
            case ActivityType.ACTIVITY_BODY_BATTERY:
                switch (t) {
                    case 1:  return Application.loadResource(Rez.Drawables.iconBodyBatteryGiallo3)    as BitmapResource;
                    case 2:  return Application.loadResource(Rez.Drawables.iconBodyBatteryArancione3) as BitmapResource;
                    case 3:  return Application.loadResource(Rez.Drawables.iconBodyBatteryCiano2)     as BitmapResource;
                    case 4:  
                        return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconBodyBattery
                                : Rez.Drawables.iconBodyBatteryRosa3
                            ) as BitmapResource;                    
                    case 5:  return Application.loadResource(
                            (lato == ANELLO_INTERNO)
                                ? Rez.Drawables.iconBodyBattery
                                : Rez.Drawables.iconBodyBatteryArancione3
                            ) as BitmapResource;                        
                    default: return Application.loadResource(Rez.Drawables.iconBodyBattery)           as BitmapResource;
                }
            default: return null;
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

    // ── chiamata ad ogni onUpdate() — aggiorna solo il valore ─────
    function _aggiornaValore() as Void {
        if (_datiRing1 == null || _datiRing2 == null) { return; }

        var info = ActivityMonitor.getInfo();

        var statico1 = _datiRing1["dati"] as Lang.Dictionary;
        statico1["valore"] = _leggiValore(info, statico1["tipo"] as Lang.Number);

        var statico2 = _datiRing2["dati"] as Lang.Dictionary;
        statico2["valore"] = _leggiValore(info, statico2["tipo"] as Lang.Number);


        // ── Item cerchi laterali — AGGIORNAMENTO MANCANTE ─────────
        if (_cfgActivityItemSx != null) {
            (_cfgActivityItemSx as Lang.Dictionary)["valore"] =
                _leggiValoreAttivita(info, (_cfgActivityItemSx as Lang.Dictionary)["tipo"] as Lang.Number);
        }
        if (_cfgActivityItemDx != null) {
            (_cfgActivityItemDx as Lang.Dictionary)["valore"] =
                _leggiValoreAttivita(info, (_cfgActivityItemDx as Lang.Dictionary)["tipo"] as Lang.Number);
        }        
    }

    function _leggiValoreAttivita(info as ActivityMonitor.Info, tipo as Lang.Number) as Lang.Number {
        switch (tipo) {
            case 10: return info.steps             != null ? info.steps                    : 0;
            case 11: return info.calories          != null ? info.calories                 : 0;
            case 12: return info.floorsClimbed     != null ? info.floorsClimbed            : 0;
            case 13: return info.activeMinutesWeek != null ? info.activeMinutesWeek.total  : 0;
            case 14: return info.activeMinutesDay  != null ? info.activeMinutesDay.total   : 0;
            case 15: return ActivityData.getStress().toNumber();
            case 16: return ActivityData.getBodyBattery().toNumber();
            default: return 0;
        }
    }
    function _leggiValore(info as ActivityMonitor.Info, tipo as Lang.Number) as Lang.Number {
        switch (tipo) {
            case 0: return info.steps             != null ? info.steps                    : 0;
            case 1: return info.calories          != null ? info.calories                 : 0;
            case 2: return info.floorsClimbed     != null ? info.floorsClimbed            : 0;
            case 3: return info.activeMinutesWeek != null ? info.activeMinutesWeek.total  : 0;
            case 4: return info.activeMinutesDay  != null ? info.activeMinutesDay.total   : 0;
            case 5: return ActivityData.getStress().toNumber();
            case 6: return ActivityData.getBodyBattery().toNumber();
            default: return 0;
        }
    }

    // ============================================================
    // METEO — icona dinamica dal codice WMO
    // ============================================================

    function _getIconMeteo(code as Lang.Number) as BitmapResource or Null {
        var iconId;
        switch (code) {
            case 0:  iconId = Rez.Drawables.wiDaySunnyColored;         break;
            case 1:  iconId = Rez.Drawables.wiDaySunnyOvercastColored; break;
            case 2:  iconId = Rez.Drawables.wiDayCloudyColored;        break;
            case 3:  iconId = Rez.Drawables.wiCloudyColored;           break;
            case 45: iconId = Rez.Drawables.wiDayFogColored;           break;
            case 48: iconId = Rez.Drawables.wiDayHazeColored;          break;
            case 51: iconId = Rez.Drawables.wiDaySprinkleColored;      break;
            case 53: iconId = Rez.Drawables.wiSprinkleColored;         break;
            case 55: iconId = Rez.Drawables.wiRainMixColored;          break;
            case 61: iconId = Rez.Drawables.wiDayRainColored;          break;
            case 63: iconId = Rez.Drawables.wiRainColored;             break;
            case 65: iconId = Rez.Drawables.wiRainWindColored;         break;
            case 71: iconId = Rez.Drawables.wiDaySnowColored;          break;
            case 73: iconId = Rez.Drawables.wiSnowColored;             break;
            case 75: iconId = Rez.Drawables.wiSnowWindColored;         break;
            case 80: iconId = Rez.Drawables.wiDayShowersColored;       break;
            case 81: iconId = Rez.Drawables.wiShowersColored;          break;
            case 82: iconId = Rez.Drawables.wiStormShowersColored;     break;
            case 95: iconId = Rez.Drawables.wiThunderstormColored;     break;
            default: return null;
        }
        return Application.loadResource(iconId) as BitmapResource;
    }

    // ============================================================
    // DRAW — funzioni di disegno primitive
    // ============================================================

    //allinea testo e icona distribuendo lo spazio su una riga - usata per ITEM del meteo nel cerchio centrale - ITEM UP/DOWN
    function _drawTestoIcona(dc as Dc, cx as Lang.Number, cy as Lang.Number,
                            icona as BitmapResource, testo as Lang.String,
                            font as Graphics.FontDefinition,fontColor as Lang.Number, maxW as Lang.Number,gapx as Lang.Number) as Void {

        var tw     = dc.getTextDimensions(testo, font)[0];
        var iconaW = icona.getWidth(); 
        var iconaH = icona.getHeight();
        var gap    = gapx;
        var totalW = tw + gap + iconaW; 

        var startX = cx - totalW / 2;
        
        dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            startX, 
            cy,
            font,
            testo,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawBitmap(
            startX + tw + gap,
            cy - iconaH / 2,
            icona);
    }

    //allinea icona e testo distribuendo lo spazio su una riga usata per ITEM del meteo nel cerchio centrale - ITEM  CENTRALE
    function _drawIconaETesto(dc as Dc, cx as Lang.Number, cy as Lang.Number, 
                            icona as BitmapResource, testo as Lang.String, 
                            font as Graphics.FontDefinition, maxW as Lang.Number, gapx as Lang.Number) as Void {

        var iconaW  = icona.getWidth();
        var iconaH  = icona.getHeight();
        var testoW  = dc.getTextDimensions(testo, font)[0];
        var testoH  = dc.getTextDimensions(testo, font)[1];
        var gap     = gapx;

        var totaleW = iconaW + gap + testoW;
        if (totaleW > maxW) {
            gap     = 2;
            totaleW = iconaW + gap + testoW;
        }

        var startX = cx - totaleW / 2;

        var iconaY = cy - iconaH / 2;
        var testoY = cy - testoH / 2;

        dc.drawBitmap(startX, iconaY, icona);

        dc.drawText(
            startX + iconaW + gap,
            testoY,
            font,
            testo,
            Graphics.TEXT_JUSTIFY_LEFT);
    }

    //usata per ITEM del meteo nei cerchi laterali
    function _drawIconaTestoVerticale(dc as Dc,
                                    cx as Lang.Number,
                                    cy as Lang.Number,
                                    icona as BitmapResource,
                                    testo as Lang.String,
                                    colore as Lang.Number) as Void {

        dc.setColor(colore, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 12, Graphics.FONT_XTINY,
            testo,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawBitmap(
            cx - icona.getWidth()  / 2,
            cy - icona.getHeight() / 2 + 12,
            icona);
    }

    function _drawRingTick(dc as Dc,
                            cx as Lang.Number,
                            cy as Lang.Number,
                            icona as BitmapResource,
                            testo as Lang.String,
                            valore as Lang.Number,
                            goal as Lang.Number,
                            cfg as Lang.Dictionary) as Void {

        var ring = new ActivityRingTick(cx, cy, -45, 225, false, cfg);
        ring.setValori(valore, goal);
        ring.draw(dc);

        dc.setColor(cfg["fontColor"] as Lang.Number, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 3, Graphics.FONT_XTINY,
            testo,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawBitmap(
            cx - icona.getWidth()  / 2,
            cy - icona.getHeight() / 2 + 18,
            icona);
    }

    function _drawProgressBarDash(dc as Dc,
                                cx as Lang.Number,
                                cy as Lang.Number,
                                icona as BitmapResource,
                                testo as Lang.String,
                                valore as Lang.Number,
                                goal as Lang.Number,
                                lunghezza as Lang.Number,
                                cfg as Lang.Dictionary) as Void {

        var bar = new ProgressBarDash(cx, cy, lunghezza, 8, cfg,
            { "orientamento" => "orizzontale", "rtl" => false } as Lang.Dictionary<Lang.String, Lang.Object>);
        bar.setValori(valore, goal);
        bar.draw(dc);

        dc.setColor(cfg["fontColor"]as Lang.Number, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 15, Graphics.FONT_XTINY,
            testo,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawBitmap(
            cx - icona.getWidth()  / 2,
            cy - icona.getHeight() / 2 + 18,
            icona);
    }

    function _drawBarraSegmentata(dc as Dc,
                                cx as Lang.Number,
                                cy as Lang.Number,
                                icona as BitmapResource,
                                valore as Lang.Number,
                                testo as Lang.String,
                                lunghezza as Lang.Number,
                                cfg as Lang.Array) as Void {

        var bar = new SegmentedBar(cx, cy, lunghezza, true, 100);
        var fontColor = (cfg[0] as Lang.Dictionary)["fontColor"] as Lang.Number;

        for (var i = 0; i < cfg.size(); i++) {
            var seg = cfg[i] as Lang.Dictionary;
            bar.addSegmento(
                seg["startVal"] as Lang.Number,
                seg["endVal"]   as Lang.Number,
                seg["spessore"] as Lang.Number,
                seg["colore"]   as Lang.Number,
                seg["stondato"] as Lang.Boolean);
        }

        bar.setMarker(valore, 5, Palette.bianco1);
        bar.draw(dc);

        dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 15, Graphics.FONT_XTINY,
            testo,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawBitmap(
            cx - icona.getWidth()  / 2,
            cy - icona.getHeight() / 2 + 18,
            icona);
    }

    //disegna , in uno dei quadranti circolari di dx e sx , la composizione di sistema : blutooth e batteria
    function _drawSystem(dc as Dc, cx as Lang.Number, cy as Lang.Number, raggio as Lang.Number, cfg as Lang.Dictionary) as Void {

        var raggioArco  = raggio - 7;
        var avanzamento = 180.0 / 100.0;
        var batteria    = System.getSystemStats().battery;

        var arc = new SegmentedArc(cx, cy, 180, 0, true, raggioArco);
        arc.addSegmento(180,                               (180-avanzamento*25).toNumber(),  3, cfg["colBatt1"] as Lang.Number, false);
        arc.addSegmento((180-avanzamento*25).toNumber(),   (180-avanzamento*50).toNumber(),  5, cfg["colBatt2"] as Lang.Number, false);
        arc.addSegmento((180-avanzamento*50).toNumber(),   (180-avanzamento*75).toNumber(),  7, cfg["colBatt3"] as Lang.Number, false);
        arc.addSegmento((180-avanzamento*75).toNumber(),   (180-avanzamento*100).toNumber(), 9, cfg["colBatt4"] as Lang.Number, false);
        arc.setMarker((180 - avanzamento * batteria).toNumber(), 4, Palette.bianco1);
        arc.draw(dc);

        var iconaBatt = cfg["iconaBatteria"] as BitmapResource;
        dc.drawBitmap(
            cx - iconaBatt.getWidth()  / 2,
            cy - iconaBatt.getHeight(),
            iconaBatt);

        dc.setColor(cfg["fontColor"] as Lang.Number, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx, cy + 5,
            Graphics.FONT_XTINY,
            batteria.toNumber().toString() + "%",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var btConnesso = System.getDeviceSettings().phoneConnected;
        var btIcona = btConnesso
            ? cfg["iconaBluetoothOn"]  as BitmapResource
            : cfg["iconaBluetoothOff"] as BitmapResource;

        dc.drawBitmap(
            cx - btIcona.getWidth()  / 2,
            cy - btIcona.getHeight() / 2 + 20,
            btIcona);
    }

    //disegna , in uno dei quadranti circolari di dx e sx , la composizione alba/tramonto     
    function _drawSunriseSunset(dc as Dc, cx as Lang.Number, cy as Lang.Number,cfg as Lang.Dictionary) as Void {

        var time        = TimeManagement.getTimeString() as Lang.Dictionary;
        var oraCorrente = (time["ore"] as Lang.String).toNumber();

        var sunriseStr  = WeatherData.getSunrise() != null ? WeatherData.getSunrise() : "--:--";
        var sunsetStr   = WeatherData.getSunset()  != null ? WeatherData.getSunset()  : "--:--";

        var oraAlba     = WeatherData.getSunrise() != null ? (WeatherData.getSunrise().substring(0,2) as Lang.String).toNumber() : 6;
        var oraTramonto = WeatherData.getSunset()  != null ? (WeatherData.getSunset().substring(0,2)  as Lang.String).toNumber() : 22;

        var isGiorno = (oraCorrente >= oraAlba && oraCorrente < oraTramonto);

        var iconaSunrise = isGiorno
            ? cfg["iconaAlbaOff"]
            : cfg["iconaAlbaOn"];

        var iconaSunset = isGiorno
            ? cfg["iconaTramontoOn"]
            : cfg["iconaTramontoOff"];

        dc.drawBitmap(cx - iconaSunrise.getWidth() / 2 - 10, cy - iconaSunrise.getHeight() / 2, iconaSunrise);
        dc.drawBitmap(cx - iconaSunset.getWidth()  / 2 + 10, cy - iconaSunset.getHeight()  / 2, iconaSunset);

        dc.setColor(isGiorno ? cfg["fontAlbaOff"] : cfg["fontAlbaOn"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 17, Graphics.FONT_XTINY, sunriseStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(isGiorno ? cfg["fontTramontoOn"] : cfg["fontTramontoOff"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 15, Graphics.FONT_XTINY, sunsetStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

        function _drawSfondoTema(dc as Dc, tema as Lang.Number) as Void {

        // ── Colore sfondo dal tema ────────────────────────────────
            var colSfondo;
            switch (tema) {
                case 4:  colSfondo = Palette.nero2; break;  // Love
                case 5:  colSfondo = Palette.nero2; break;  // Military
                
                default: colSfondo = Palette.nero2;    break;
            }
            dc.setColor(colSfondo, colSfondo);
            dc.clear();

            // ── Immagini tematiche ────────────────────────────────────
            switch (tema) {


                case 4: // Military
                    var love = Application.loadResource(Rez.Drawables.heartsLoveTheme) as BitmapResource;
                    dc.drawBitmap(200 - love.getWidth() / 2, 210 - love.getHeight() / 2, love);


                    break;

                case 5: // Military
                    var fighter = Application.loadResource(Rez.Drawables.fighterMilitaryTheme) as BitmapResource;
                    dc.drawBitmap(200 - fighter.getWidth() / 2, 210 - fighter.getHeight() / 2, fighter);

                    var tank = Application.loadResource(Rez.Drawables.tankMilitaryTheme) as BitmapResource;
                    dc.drawBitmap(225 - tank.getWidth() / 2, 170 - tank.getHeight() / 2, tank);
                    break;

                default:
                    break;
            }
        }
        //disegna la frequenza cardiaca e il battito 
        function _drawHeartRate(dc as Dc, cx as Lang.Number, cy as Lang.Number) as Void {

            var hrIcona;
            switch (_heartBeat) {
                case 0:  hrIcona = Application.loadResource(Rez.Drawables.heartSmall)  as BitmapResource; break;
                case 1:  hrIcona = Application.loadResource(Rez.Drawables.heartMedium) as BitmapResource; break;
                default: hrIcona = Application.loadResource(Rez.Drawables.heartBig)    as BitmapResource; break;
            }

            dc.drawBitmap(
                cx - hrIcona.getWidth()  / 2,
                cy - hrIcona.getHeight() / 2 - 5,
                hrIcona);

            var hr = ActivityData.getHeartRate();
            dc.setColor(Palette.bianco1, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                cx, cy + 10,
                Graphics.FONT_XTINY,
                hr.toString() + "bpm",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }


        // ============================================================
        // DRAW — funzioni principali di composizione
        // ============================================================

        // ── componenti grafiche pure, nessun dato dinamico ────────
        function _drawSfondo1(dc as Dc) as Void {

            //IMPOSTA SFONDO
            _drawSfondoTema(dc, _tema);
            



            //DISEGNA CERCHIO+BORDO CENTRALE
            CircleFill.draw(dc, circle3X, circle3Y, rad3, (_circleCntrl["tema"] as Lang.Dictionary)["back"]   as Lang.Number);
            Circle.draw(dc,     circle3X, circle3Y, rad3, (_circleCntrl["tema"] as Lang.Dictionary)["stroke"] as Lang.Number, 2);

            //DISEGNA CERCHIO+BORDO SINISTRA
            CircleFill.draw(dc, circle1X, circle1Y, rad1, (_circleSx["tema"] as Lang.Dictionary)["back"]   as Lang.Number);
            Circle.draw(dc,     circle1X, circle1Y, rad1, (_circleSx["tema"] as Lang.Dictionary)["stroke"] as Lang.Number, 2);

            //DISEGNA CERCHIO+BORDO DESTRA
            CircleFill.draw(dc, circle2X, circle2Y, rad2, (_circleDx["tema"] as Lang.Dictionary)["back"]   as Lang.Number);
            Circle.draw(dc,     circle2X, circle2Y, rad2, (_circleDx["tema"] as Lang.Dictionary)["stroke"] as Lang.Number, 2);

            //DISEGNA RETTANGOLO GRANDE
            RectFill.draw(dc, rect1X, rect1Y, rect1W, rect1H, (_rectCalendar["tema"] as Lang.Dictionary)["back"] as Lang.Number, 20);

            //DISEGNA RETTANGOLO PICCOLO
            RectFill.draw(dc, rect2X, rect2Y, rect2W, rect2H, (_rectNotch["tema"] as Lang.Dictionary)["back"] as Lang.Number, 12);
        }

    //funzione principale che disegna il quadrante
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

            // SCRIVI ORA+CALENDARIO NEL RETTANGOLO GRANDE (fisso)
            //----------------------------------------------------------------------------------------
            var calendario = TimeManagement.getDateInfo() as Lang.Dictionary<Lang.String, Lang.String>;
            var time = TimeManagement.getTimeString() as Lang.Dictionary<String, String>;
            var dim = dc.getTextDimensions(calendario["giorno"].substring(0, 2), Graphics.FONT_XTINY);

            var fontOra=(_rectCalendar["tema"] as Lang.Dictionary)["font1"] as Lang.Number;
            var fontCalendario=(_rectCalendar["tema"] as Lang.Dictionary)["font3"] as Lang.Number;
            var fontMinuti=(_rectCalendar["tema"] as Lang.Dictionary)["font2"] as Lang.Number;
            
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

            // SCRIVI NEL RETTANGOLO PICCOLO  (fisso)
            //----------------------------------------------------------------------------------------
            var city = WeatherData.getCity();
            var wtime = WeatherData.getWeatherTime();
            var meteoStr = (city != null ? city : "--") + " " + (wtime != null ? wtime : "--");
            var fontCitta=(_rectNotch["tema"] as Lang.Dictionary)["font1"] as Lang.Number;
            dc.setColor(fontCitta, Graphics.COLOR_TRANSPARENT);
            dc.drawText((rect2X - rect2W / 2) + 15, rect2Y, Graphics.FONT_XTINY, meteoStr,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

            // SCRIVI NEL CERCHIO CNTRL 
            //----------------------------------------------------------------------------------------
            if (WeatherData._wcode != null) {
                var iconIdMeteo = _getIconMeteo(WeatherData._wcode);
                if (iconIdMeteo != null) {
                    _drawIconaETesto(dc, circle3X, circle3Y, iconIdMeteo, WeatherData.getTempString(), Graphics.FONT_TINY, 90, 5);
                }
            }
            var offsetY=(rad3/2).toNumber();
            var corda = MathUtils.corda(rad3, offsetY);

            //posizione UP
            if (_cfgMeteoUp != null && _cfgMeteoUp["icona16"] != null) {
                _drawTestoIcona(dc, circle3X, circle3Y-24, _cfgMeteoUp["icona16"], _cfgMeteoUp["valore"], Graphics.FONT_XTINY, _cfgMeteoUp["fontColor"], corda, 4);
            }

            //posizione DOWN
            if (_cfgMeteoDown != null && _cfgMeteoDown["icona16"] != null) {
                _drawTestoIcona(dc, circle3X, circle3Y+24, _cfgMeteoDown["icona16"], _cfgMeteoDown["valore"], Graphics.FONT_XTINY, _cfgMeteoDown["fontColor"], corda, 4);
            }

            // SCRIVI NEL CERCHIO SX 
            //----------------------------------------------------------------------------------------
            if (_cfgMeteoItemSx != null) {
                //Logger.log("drawDati","METEO ITEM");
                _drawIconaTestoVerticale(dc, circle1X, circle1Y,_cfgMeteoItemSx["icona24"],_cfgMeteoItemSx["valore"],_cfgMeteoItemSx["fontColor"]);
            } else if (_cfgSunItemSx != null) {
                //Logger.log("drawDati","SUN ITEM");
                _drawSunriseSunset(dc,circle1X,circle1Y,_cfgSunItemSx);
            } else if (_cfgSystemItemSx != null) {
                //Logger.log("drawDati","SYSTEM ITEM");
                _drawSystem(dc, circle1X, circle1Y, rad1,_cfgSystemItemSx);
            } else if (_cfgHeartItemSx) {
                //Logger.log("drawDati","HEART ITEM");
                _drawHeartRate(dc, circle1X, circle1Y);
            } else if (_cfgActivityItemSx != null) {
                //Logger.log("drawDati","ACTIVITY ITEM ....");
                switch (_cfgActivityItemSx["tipoGrafico"]) {
                    case GRAFICO_RINGTICK:
                    {
                        var cfgTick = getCfgRingTick(_tema,CERCHIO_SX);
                        _drawRingTick(dc, circle1X, circle1Y, 
                            _cfgActivityItemSx["icona"],
                            MathUtils.formatNumberCompact(_cfgActivityItemSx["valore"]).toString(),
                            _cfgActivityItemSx["valore"],
                            _cfgActivityItemSx["goal"], 
                            cfgTick);
                    }
                    break;
                    case GRAFICO_PROGRESSBARDASH:
                    {
                        var cfgDash=getCfgProgressBarDash(_tema,CERCHIO_SX);
                        _drawProgressBarDash(dc, circle1X, circle1Y, 
                            _cfgActivityItemSx["icona"],
                            (_cfgActivityItemSx["valore"]).toString(),
                            _cfgActivityItemSx["valore"] as Lang.Number,
                            10, 50, cfgDash);
                    }
                    break;
                    case GRAFICO_SEGMENTEDBAR:
                    {
                        var cfgSegmBar=getCfgSegmentedBar(_tema,CERCHIO_SX);
                        _drawBarraSegmentata(dc, circle1X, circle1Y, 
                            _cfgActivityItemSx["icona"], 
                            _cfgActivityItemSx["valore"], _cfgActivityItemSx["valore"].toString() + "%", 50, cfgSegmBar);
                    }
                    break;
                }
            }

            // SCRIVI NEL CERCHIO DX 
            //----------------------------------------------------------------------------------------
            if (_cfgMeteoItemDx != null) {
                //Logger.log("drawDati","METEO ITEM DX");
                _drawIconaTestoVerticale(dc, circle2X, circle2Y,_cfgMeteoItemDx["icona24"],_cfgMeteoItemDx["valore"],_cfgMeteoItemDx["fontColor"]);
            } else if (_cfgSunItemDx != null) {
                //Logger.log("drawDati","SUN ITEM DX");
                _drawSunriseSunset(dc,circle2X,circle2Y,_cfgSunItemDx);
            } else if (_cfgSystemItemDx != null) {
                //Logger.log("drawDati","SYSTEM ITEM DX");
                _drawSystem(dc, circle2X,circle2Y, rad2,_cfgSystemItemDx);
            } else if (_cfgHeartItemDx) {
                //Logger.log("drawDati","HEART ITEM");
                _drawHeartRate(dc, circle2X,circle2Y);
            } else if (_cfgActivityItemDx != null) {
                //Logger.log("drawDati","ACTIVITY ITEM ....");
                switch (_cfgActivityItemDx["tipoGrafico"]) {
                    case GRAFICO_RINGTICK:
                    {
                        var cfgTick = getCfgRingTick(_tema,CERCHIO_DX);
                        _drawRingTick(dc, circle2X, circle2Y, 
                            _cfgActivityItemDx["icona"],
                            MathUtils.formatNumberCompact(_cfgActivityItemDx["valore"]).toString(),
                            _cfgActivityItemDx["valore"],
                            _cfgActivityItemDx["goal"], 
                            cfgTick);
                    }
                    break;
                    case GRAFICO_PROGRESSBARDASH:
                    {
                        var cfgDash=getCfgProgressBarDash(_tema,CERCHIO_DX);
                        _drawProgressBarDash(dc, circle2X, circle2Y, 
                            _cfgActivityItemDx["icona"],
                            (_cfgActivityItemDx["valore"]).toString(),
                            _cfgActivityItemDx["valore"] as Lang.Number,
                            10, 50, cfgDash);
                    }
                    break;
                    case GRAFICO_SEGMENTEDBAR:
                    {
                        var cfgSegmBar=getCfgSegmentedBar(_tema,CERCHIO_DX);
                        _drawBarraSegmentata(dc, circle2X, circle2Y, 
                            _cfgActivityItemDx["icona"], 
                            _cfgActivityItemDx["valore"], _cfgActivityItemDx["valore"].toString() + "%", 50, cfgSegmBar);
                    }
                    break;
                }
            }
    }

}
