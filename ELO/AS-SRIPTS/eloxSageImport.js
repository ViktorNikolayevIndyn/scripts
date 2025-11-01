//Import the Indexserver API classes.
importPackage(Packages.de.elo.ix.client);
importPackage(Packages.de.elo.mover.main);
importPackage(Packages.de.elo.mover.main.pdf);
importPackage(Packages.de.elo.mover.main.tiff);
importPackage(Packages.de.elo.mover.main.utils);
importPackage(Packages.de.elo.mover.utils);
importPackage(Packages.java.lang);
importPackage(Packages.java.sql);
importPackage(Packages.java.io);
importPackage(Packages.org.apache.commons.io);
importPackage(Packages.javax.mail);
importPackage(Packages.javax.mail.internet);
importPackage(Packages.java.util);
importPackage(Packages.org.apache.commons.lang);
importPackage(Packages.org.apache.commons.httpclient);
importPackage(Packages.org.apache.commons.httpclient.methods);
importPackage(Packages.org.json);

var EM_VERSION_NO = "21.01.000 Build 001";


var NAME;
var ARCDATE;
var DOCDATE;
var OBJCOLOR;
var OBJDESC;
var OBJTYPE;
var ARCHIVINGMODE;
var ACL;
var BACKUP_ACL;

var EM_ACT_SORD;

var EM_PARENT_ID;
var EM_PARENT_ACL;

var EM_NEW_DESTINATION = new Array();
var EM_FIND_RESULT = null;
var EM_START_INDEX = 0;
var EM_MASK_LOADED = -1;
var EM_WRITE_CHANGED = false;
var EM_TW_MAINPARENT = true;
var EM_WITH_LOCK = false;
var EM_ALLOWALLMASKS = false;
var EM_FIND_INFO = null;
const EM_SYS_STDSEL = SordC.mbLean;
var EM_SYS_SELECTOR;

var EM_TEMP;
var EM_ERROR;

// Parameter für manuell getriggerte Ausführung
var EM_PARAM1;
var EM_PARAM2;
var EM_PARAM3;
var EM_PARAM4;
var EM_PARAM5;
var EM_PARAM6;
var EM_PARAM7;
var EM_PARAM8;
var EM_PARAM9;
var EM_PARAM10;
var EM_USERID;

// Tree walk parameter
var EM_TREE_STATE;
var EM_PARENT_SORD;
var EM_ROOT_SORD;
var EM_INDEX_LOADED;
var EM_TREE_LEVEL;
var EM_SAVE_TREE_ROOT;
var EM_TREE_EVAL_CHILDREN;
var EM_TREE_ABORT_WALK;
var EM_TREE_MAX_LEVEL;

// Workflow
var EM_TASKLIST;
var EM_WF_NEXT;
var EM_WF_NODE;
var EM_WF_STATUS;
var EM_WF_FILTER_NAME;
var EM_WF_WITH_DELETED = false;
var EM_WF_USER_DELAY_DATE = "";
var EM_WF_SELECTOR = SordC.mbLean;

var EM_WF_EXPORT_ROOT = "c:\\temp\\wfexport";

// Mail
var MAIL_SESSION;
var MAIL_SMTP_HOST;
var MAIL_INBOX;
var MAIL_STORE;
var MAIL_MESSAGE;
var MAIL_POINTER;
var MAIL_MESSAGES;
var MAIL_DELETE_ARCHIVED;
var MAIL_ALLOW_DELETE;
var MAIL_CONNECT_NAME;

// 
function EM_Events() {
}

var EM_EventsI = new EM_Events();

//EM_Events.prototype.tferUserWrite = function(destination, source, translator)
//EM_Events.prototype.tferUserFillup = function(destination, source, translator)
//EM_Events.prototype.tferSordWrite = function(destination, sord, userTranslator, guidProvider)
//EM_Events.prototype.tferSordFillup = function(sord, source, userTranslator)
//EM_Events.prototype.tferWorkflowWrite = function(destination, wfDiagram, translator)
//EM_Events.prototype.tferWorkflowFillup = function(wfDiagram, source, translator)
//EM_Events.prototype.tferMapWrite = function(destination, mapData)
//EM_Events.prototype.tferMapFillup = function(mapData, source)


// JDBC Database connections
//
// driver: Java class name of the JDBC driver, see driver documentation
// url: Connection URL to the database, see driver documentation
// user, password: Database login credentials, if needed
// initdone: internal field, always initialize with false
// classloaded: internal field, always initialize with false
// dbcn: internal field, always initialize with null

var EM_connections = [
{
driver: 'org.postgresql.Driver',
url: 'jdbc:postgresql://localhost/elo',
user: '',
password: '',
initdone: false,
classloaded: false,
dbcn: null
},
{
driver: 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
url: 'jdbc:sqlserver://JOST-SQL:1433',
user: 'elodb',
password: '32-4-160-98-28-45-64-208-35-236-4-187-171-24-174-36',
initdone: false,
classloaded: false,
dbcn: null
},
{
driver: 'oracle.jdbc.OracleDriver',
url: 'jdbc:oracle:thin:@srvoracle:1521:eloorcl',
user: 'elodb',
password: 'elodb',
initdone: false,
classloaded: false,
dbcn: null
},
{
driver: 'com.ibm.db2.jcc.DB2Driver',
url: 'jjdbc:db2://srvt02:50000/elotestu',
user: 'elodb',
password: 'elodb',
initdone: false,
classloaded: false,
dbcn: null
},
{
driver: 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
url: 'jdbc:sqlserver://JOST-SQL:1435;instanceName=DIAMANT',
user: 'sa',
password: '7sVJw78U9Kj9',
initdone: false,
classloaded: false,
dbcn: null
},
{
driver: 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
url: 'jdbc:sqlserver://JOST-SQL:1437',
user: 'ELO-Importer',
password: 'CtzugHVtzEVyMv272MIh!',
initdone: false,
classloaded: false,
dbcn: null
}
];

// Direct index line access variables.
// Duplicate group names are only defined at
// the first occurrence.

// From Mask PA-Personalakte
var PANAME;
var PAVORNAME;
var PANR;
var PAFILIALE;
var PAASTRASSE;
var PAEINDATUM;
var PAGEBDATUM;
var PAJUBIL;
var PAAUSTRITT;
var PAEINGRUPP;
var PAEINGAM;
var PAUNTERBR1;
var PAUNTBIS1;
var PAUNTERBR2;
var PAUNTBIS2;
var PAUNTERBR3;
var PAUNTBIS3;
var PAUNTVON4;
var PAUNTBIS4;
var PADATUM;
var PAABTEILUNG;
var PAEINSTUF;
var PASTD;
var PAGEHALT;
var PAZULAGE;
var PAGESAMT;
var PAPLZ;
var PAORT;
var PAANREDE;
var PATITEL;
var PATELEFON;
var PAGESCHLECHT;
var PAFAMSTAND;
var PAGEBNAME;
var PAHANDY;
var PAETIN;
var PASTATUS;
var PAABGLEICH;



// Compiled code from search definition
var EM_SEARCHNAME;
var EM_SEARCHVALUE;
var EM_SEARCHCOUNT;
var EM_SEARCHMASK;
var EM_IDATEFROM;
var EM_IDATETO;
var EM_XDATEFROM;
var EM_XDATETO;
var EM_FOLDERMASK = "1";

function onStart(){ 
log.info("*********************************************  Start SAGEIMPORT ************************************************");
};

function onEnd(){ 
log.info("*********************************************  Ende SAGEIMPORT ************************************************");
};

function initSearch(){
  EM_SEARCHNAME = "PAABGLEICH";
  EM_SEARCHVALUE = "1";
  EM_SEARCHCOUNT = 600;
  EM_SEARCHMASK = 14;
  EM_IDATEFROM = "";
  EM_IDATETO = "";
  EM_XDATEFROM = "";
  EM_XDATETO = "";
};

// start of namespace sys
var sys = new Object();
sys = {


processRules: function (Sord) {
  try {
    sys.processRule1(Sord);
  } catch (e) {
    EM_ERROR = e;
    log.info("Exception caught: " + EM_ERROR);
    sys.processRule2(Sord);
    return;
  }
},

processRule1: function (Sord) {
  // Rule: Regel1
  //Generated Rule code : 
  log.debug("Process Rule .");
if (Sord.lockId == -1) {
  EM_FOLDERMASK = 1;

//  ***************** E-Mail-Empfänger für Jubiläums-Hinweis *****************************
  mail.setSmtpHost("localhost");
  var Empfaenger1 = "laura.wohnsiedler@mode-jost.de";
  var Empfaenger2 = "anke.richter@mode-jost.de";


  if (PANR != "0"){
     
                 
  if (PANR ==5059) {
  PANR = PANR ;
  }
     
  if (PANR =="5059") {
  PANR = PANR ;
  }

    var sql = "SELECT TOP 1 A.MDNr,A.ANNr,M.NR,M.Bez FROM [HR_Jost].[dbo].[ANKost_LV] A JOIN [HR_Jost].[dbo].[MDKoSt] M ON M.Id=A.KoSt where ANNr='"+PANR+"'" ;
    var res = db.getLine(5, sql);
    if (res != null){
    PAABTEILUNG = res.Bez;
    }

    var sql = "SELECT TOP 1 MDNr, ANNr,AbrTag, AbrMon, AbrJahr,Wert,LANr FROM [HR_Jost].[dbo].[ANBruttolohn] where ANNr='"+PANR+"' and (LANr='100' or LANr='110')" ;
    var res = db.getLine(5, sql);
    if (res != null){
    PADATUM=""+((res.AbrTag < 10) ? ("0" + res.AbrTag) : res.AbrTag)+"."+((res.AbrMon < 10) ? ("0" + res.AbrMon) : res.AbrMon) +"."+res.AbrJahr;
    PAGEHALT=res.Wert;
    }

    var sql = "SELECT DISTINCT A.MDNr,A.ANNr, SUM(DISTINCT A.Wert) AS Butto  FROM [HR_Jost].[dbo].[ANBruttolohn] A INNER JOIN [HR_Jost].[dbo].[Lohnart_Tab] L ON A.LANr=L.LANr WHERE SVPfl= 1 and  A.ANNr='"+PANR+"' GROUP BY A.MDNr,A.ANNr ORDER BY A.MDNr,A.ANNr";   
   var res = db.getLine(5, sql);
    if (res != null){
    PAGESAMT=res.Brutto;
    }

    var sql = "SELECT DISTINCT OD_abper,A.OD_MDNr,A.OD_ANNr,A.OD_VergGr,T.Bezeichnung,A3.AZWo AS Wochenarbeitszeit FROM [HR_Jost].[dbo].[ANMonatswerteOD_Stamm] A JOIN [HR_Jost].[dbo].[TarifVergGr] T ON T.VergGrID=A.OD_VergGr JOIN [HR_Jost].[dbo].[ANMonatswerte_Stamm] A2 ON A2.MDNr=A.OD_MDNr AND A2.ANNr=A.OD_ANNr JOIN [HR_Jost].[dbo].[KO_Arbeitszeit_Wochen_LT] A3 ON A3.KO_Arbeitszeit_ID=A2.AZTab WHERE A.OD_ANNr='"+PANR+"' ORDER BY A.OD_abper DESC,A.OD_MDNr,A.OD_ANNr";

   var res = db.getLine(5, sql);
    if (res != null){
    if (res.Bezeichnung!= ''){
	    PAEINSTUF = res.Bezeichnung;
    } else {
      PAEINSTUF = "AT";
    }
    if (res.Wochenarbeitszeit  > 1){
  	 PASTD = res.Wochenarbeitszeit ;
   } else {
      PASTD = 'Aush.';
   }

    }

    var sql = "SELECT TOP 1  Vorname,Name,Titel,Strasse,Plz as Plz,Ort,Telefon,Funktelefon,mann,GebName,GebOrt,Convert(varchar,Eintritt,104) as Eintritt,Convert(varchar,Austritt,104) as Austritt,TIN,Convert(varchar,GebDat,104) as GebDat FROM [HR_Jost].[dbo].[Arbeitnehmer]  where MDNr=1 and  ANNr ="+PANR ; // and istGeloescht = 'FALSE'
    var res = db.getLine(5, sql);
    if (res != null){
      NAME = res.Name + ", " + res.Vorname + " [ " + PANR + " ]";


      PANAME = res.Name;
      PAVORNAME = res.Vorname;
      PAASTRASSE = res.Strasse;
      PAGEBDATUM = res.GebDat;
      PAPLZ = res.Plz;
      PAORT = res.Ort;
      if (res.mann == 0) {
         PAANREDE = "Frau";
         PAGESCHLECHT = "W";
         } else {
         PAANREDE = "Herr";
         PAGESCHLECHT = "M";
      }
      PATITEL = res.Titel;
      PATELEFON = res.Telefon;
      //PAFAMSTAND = res.p_fam_stand;
      PAGEBNAME = res.GebName;
      PAHANDY = res.Funktelefon;
      PAETIN = res.TIN;
      PAEINDATUM = res.Eintritt;

      var itag = res.Eintritt.substring(0,2);
      var imon = res.Eintritt.substring(3,5);
      var ijahr = res.Eintritt.substring(6,10);
     // log.info("*********** Eintritt" + ijahr + "***" + imon + "***" + itag);
      var jubil = new Date(ijahr, Number(imon)-1, itag);
      var aktDate = new Date();
      aktDate.setHours(0,0,0,0);
      var notedate = new Date();
      notedate.setHours(0,0,0,0);
      notedate.setDate(notedate.getDate() + 30);
      var docObjId = Sord.getId();
      var wfName = "Jubiläum: " + NAME;
      const wfTemplate = "Jubilaeum";


      if (res.Austritt.length == 10) {
         PAABGLEICH="0";
         PAJUBIL=""; 
         PAAUSTRITT = res.Austritt;
         NAME = NAME + " - Ausgeschieden -";
         bt.moveTo(Sord, "¶Personal¶Personalakten¶Ausgeschiedene Mitarbeiter¶"+res.Austritt.substring(6,10));
         EM_WRITE_CHANGED = true;
         } else {
         PAABGLEICH="1";
         PAAUSTRITT = "";
// 10-jähriges Jubiläum  **************************************************************************************
	 jubil.setFullYear(jubil.getFullYear() + 10);
	 if (jubil.getTime() > aktDate.getTime()) {
	  itag=jubil.getDate();
	   if (itag < 10){
	    itag = "0" + itag;
		};
	  imon=jubil.getMonth()+1;
	   if (imon < 10) {
	    imon = "0" + imon;
		};
         ijahr=jubil.getFullYear();
         PAJUBIL = itag + "." + imon + "." + ijahr + "  (10)";
         //log.info("*********** JUBIL: " + PAJUBIL);
         if (jubil.getTime() == notedate.getTime()){
         wf.startWorkflow(wfTemplate, wfName,docObjId);
         var mailtext = "Es steht das 10-jährige Jubiläum von " + NAME + " an."
         mail.sendMail("administrator@mode-jost.de",Empfaenger1, "Jubiläum", mailtext);   
         mail.sendMail("administrator@mode-jost.de",Empfaenger2, "Jubiläum", mailtext);   
         }
	 } else {
// 25-jähriges Jubiläum  **************************************************************************************
	  jubil.setFullYear(jubil.getFullYear() + 15);
	  if (jubil.getTime() > aktDate.getTime()) {
	   itag=jubil.getDate();
	   if (itag < 10){
	    itag = "0" + itag;
		};
	   imon=jubil.getMonth()+1;
	   if (imon < 10) {
	    imon = "0" + imon;
		};
	  ijahr=jubil.getFullYear();
          PAJUBIL = itag + "." + imon + "." + ijahr + "  (25)";
        //log.info("*********** JUBIL: " + PAJUBIL);
          if (jubil.getTime() == notedate.getTime()){
          wf.startWorkflow(wfTemplate, wfName,docObjId);
          var mailtext = "Es steht das 25-jährige Jubiläum von " + NAME + " an."
          mail.sendMail("administrator@mode-jost.de",Empfaenger1, "Jubiläum", mailtext);   
          mail.sendMail("administrator@mode-jost.de",Empfaenger2, "Jubiläum", mailtext);   
          }
	  } else {
// 40-jähriges Jubiläum  **************************************************************************************
	  jubil.setFullYear(jubil.getFullYear() + 15);
	  if (jubil.getTime() > aktDate.getTime()) {
	   itag=jubil.getDate();
	   if (itag < 10){
	    itag = "0" + itag;
		};
	   imon=jubil.getMonth()+1;
	   if (imon < 10) {
	    imon = "0" + imon;
		};
	   ijahr=jubil.getFullYear();
	   PAJUBIL = itag + "." + imon + "." + ijahr + "  (40)";
         //log.info("*********** JUBIL: " + PAJUBIL);
           if (jubil.getTime() == notedate.getTime()){
           wf.startWorkflow(wfTemplate, wfName,docObjId);
           var mailtext = "Es steht das 40-jährige Jubiläum von " + NAME + " an."
           mail.sendMail("administrator@mode-jost.de",Empfaenger1, "Jubiläum", mailtext);   
           mail.sendMail("administrator@mode-jost.de",Empfaenger2, "Jubiläum", mailtext);   
          }
	  } else {
// 45-jähriges Jubiläum  **************************************************************************************
	  jubil.setFullYear(jubil.getFullYear() + 5);
	  if (jubil.getTime() > aktDate.getTime()) {
	   itag=jubil.getDate();
	   if (itag < 10){
	    itag = "0" + itag;
		};
	   imon=jubil.getMonth()+1;
           if (imon < 10) {
	    imon = "0" + imon;
		};
	   ijahr=jubil.getFullYear();
	   PAJUBIL = itag + "." + imon + "." + ijahr + "  (45)";
          //log.info("*********** JUBIL: " + PAJUBIL);
           if (jubil.getTime() == notedate.getTime()){
           wf.startWorkflow(wfTemplate, wfName,docObjId);
           var mailtext = "Es steht das 45-jährige Jubiläum von " + NAME + " an."
           mail.sendMail("administrator@mode-jost.de",Empfaenger1, "Jubiläum", mailtext);   
           mail.sendMail("administrator@mode-jost.de",Empfaenger2, "Jubiläum", mailtext);   
           }
	  }
	   PAJUBIL = "";
	  }
	 }
	 }  //else von (jubil.getTime() > aktDate.getTime())

// Ende Jubiläums-Prüfung  *******************************************************************************************

} //Wenn kein Austrittsdatum gesetzt ist


    } //res != null

    ddate = new Date();
    PASTATUS = "Abgeglichen am: " +  ddate ;

    EM_WRITE_CHANGED = true;
  } //PANR == "0"

} //if (Sord.lockId == -1)


},

processRule2: function (Sord) {
  // Rule: Global Error Rule
  //Generated Error Rule, clear all old destinations, reset ACL
  EM_NEW_DESTINATION = new Array();
  ACL = BACKUP_ACL;
  log.info("Process Error Rule Global Error Rule.");
  EM_FOLDERMASK = 1;
  //Index line changes
   mail.setSmtpHost("localhost");  
   var Empfaenger3 = "elo@mode-jost.de";
   var Empfaenger4 = "laura.wohnsiedler@mode-jost.de";
 mail.sendMail("administrator@mode-jost.de", Empfaenger3, "Sageimport", "Fehler in Rule Sageimport! \nBitte Logbuch prüfen! - Pers-Nr: "+PANR + "  ID: " + Sord.id); 
 mail.sendMail("administrator@mode-jost.de", Empfaenger4, "Sageimport", "Fehler in Rule Sageimport! \nBitte Logbuch prüfen! - Pers-Nr: "+PANR + "  ID: " + Sord.id); 

},

finalErrorRule: function (Sord) {
  sys.processRule2(Sord);
},


// Compiled code: write read lines of mask: PA-Personalakte
loadIndexLines14: function (Sord) { 
  log.debug('Get Index Lines of mask 14');
  PANAME = elo.getIndexValue2(Sord, 0, 3000);
  PAVORNAME = elo.getIndexValue2(Sord, 1, 3000);
  PANR = elo.getIndexValue2(Sord, 2, 3000);
  PAFILIALE = elo.getIndexValue2(Sord, 3, 3000);
  PAASTRASSE = elo.getIndexValue2(Sord, 4, 3000);
  PAEINDATUM = elo.getIndexValue2(Sord, 5, 3001);
  PAGEBDATUM = elo.getIndexValue2(Sord, 6, 3001);
  PAJUBIL = elo.getIndexValue2(Sord, 7, 3001);
  PAAUSTRITT = elo.getIndexValue2(Sord, 8, 3001);
  PAEINGRUPP = elo.getIndexValue2(Sord, 9, 3000);
  PAEINGAM = elo.getIndexValue2(Sord, 10, 3001);
  PAUNTERBR1 = elo.getIndexValue2(Sord, 11, 3001);
  PAUNTBIS1 = elo.getIndexValue2(Sord, 12, 3001);
  PAUNTERBR2 = elo.getIndexValue2(Sord, 13, 3001);
  PAUNTBIS2 = elo.getIndexValue2(Sord, 14, 3001);
  PAUNTERBR3 = elo.getIndexValue2(Sord, 15, 3001);
  PAUNTBIS3 = elo.getIndexValue2(Sord, 16, 3001);
  PAUNTVON4 = elo.getIndexValue2(Sord, 17, 3001);
  PAUNTBIS4 = elo.getIndexValue2(Sord, 18, 3001);
  PADATUM = elo.getIndexValue2(Sord, 19, 3001);
  PAABTEILUNG = elo.getIndexValue2(Sord, 20, 3000);
  PAEINSTUF = elo.getIndexValue2(Sord, 21, 3000);
  PASTD = elo.getIndexValue2(Sord, 22, 3000);
  PAGEHALT = elo.getIndexValue2(Sord, 23, 3000);
  PAZULAGE = elo.getIndexValue2(Sord, 24, 3000);
  PAGESAMT = elo.getIndexValue2(Sord, 25, 3000);
  PAPLZ = elo.getIndexValue2(Sord, 26, 3000);
  PAORT = elo.getIndexValue2(Sord, 27, 3000);
  PAANREDE = elo.getIndexValue2(Sord, 28, 3000);
  PATITEL = elo.getIndexValue2(Sord, 29, 3000);
  PATELEFON = elo.getIndexValue2(Sord, 30, 3000);
  PAGESCHLECHT = elo.getIndexValue2(Sord, 31, 3000);
  PAFAMSTAND = elo.getIndexValue2(Sord, 32, 3000);
  PAGEBNAME = elo.getIndexValue2(Sord, 33, 3000);
  PAHANDY = elo.getIndexValue2(Sord, 34, 3000);
  PAETIN = elo.getIndexValue2(Sord, 35, 3000);
  PASTATUS = elo.getIndexValue2(Sord, 36, 3000);
  PAABGLEICH = elo.getIndexValue2(Sord, 37, 3008);
  EM_MASK_LOADED = 14;
},

loadIndexLines: function (Sord) {
  sys.clearAll()
  var maskNo = Sord.getMask();
  if (maskNo == 14) {
    sys.loadIndexLines14(Sord);
  } else {
    log.debug("Unknown mask id found, template vars not filled");
  }
},


// Clear all Index Line Vars
clearAll: function() {
  PANAME = "";
  PAEINGAM = "";
  PATELEFON = "";
  PADATUM = "";
  PAEINGRUPP = "";
  PAORT = "";
  PAZULAGE = "";
  PAUNTBIS3 = "";
  PAUNTBIS2 = "";
  PATITEL = "";
  PAUNTERBR3 = "";
  PAUNTVON4 = "";
  PAUNTBIS4 = "";
  PAPLZ = "";
  PAHANDY = "";
  PAUNTERBR2 = "";
  PAGEBDATUM = "";
  PAUNTERBR1 = "";
  PAFAMSTAND = "";
  PAFILIALE = "";
  PANR = "";
  PASTATUS = "";
  PAABGLEICH = "";
  PAABTEILUNG = "";
  PAUNTBIS1 = "";
  PAGESCHLECHT = "";
  PAAUSTRITT = "";
  PAGESAMT = "";
  PAEINSTUF = "";
  PAVORNAME = "";
  PAGEBNAME = "";
  PAEINDATUM = "";
  PASTD = "";
  PAGEHALT = "";
  PAASTRASSE = "";
  PAANREDE = "";
  PAETIN = "";
  PAJUBIL = "";
},

// Compiled code: write index lines of mask: PA-Personalakte
storeIndexLines14: function (Sord) { 
  log.debug('Set Index Lines of mask 14');
  elo.setIndexValue2(Sord, 0,  3000,  PANAME);
  elo.setIndexValue2(Sord, 1,  3000,  PAVORNAME);
  elo.setIndexValue2(Sord, 2,  3000,  PANR);
  elo.setIndexValue2(Sord, 3,  3000,  PAFILIALE);
  elo.setIndexValue2(Sord, 4,  3000,  PAASTRASSE);
  elo.setIndexValue2(Sord, 5,  3001,  PAEINDATUM);
  elo.setIndexValue2(Sord, 6,  3001,  PAGEBDATUM);
  elo.setIndexValue2(Sord, 7,  3001,  PAJUBIL);
  elo.setIndexValue2(Sord, 8,  3001,  PAAUSTRITT);
  elo.setIndexValue2(Sord, 9,  3000,  PAEINGRUPP);
  elo.setIndexValue2(Sord, 10,  3001,  PAEINGAM);
  elo.setIndexValue2(Sord, 11,  3001,  PAUNTERBR1);
  elo.setIndexValue2(Sord, 12,  3001,  PAUNTBIS1);
  elo.setIndexValue2(Sord, 13,  3001,  PAUNTERBR2);
  elo.setIndexValue2(Sord, 14,  3001,  PAUNTBIS2);
  elo.setIndexValue2(Sord, 15,  3001,  PAUNTERBR3);
  elo.setIndexValue2(Sord, 16,  3001,  PAUNTBIS3);
  elo.setIndexValue2(Sord, 17,  3001,  PAUNTVON4);
  elo.setIndexValue2(Sord, 18,  3001,  PAUNTBIS4);
  elo.setIndexValue2(Sord, 19,  3001,  PADATUM);
  elo.setIndexValue2(Sord, 20,  3000,  PAABTEILUNG);
  elo.setIndexValue2(Sord, 21,  3000,  PAEINSTUF);
  elo.setIndexValue2(Sord, 22,  3000,  PASTD);
  elo.setIndexValue2(Sord, 23,  3000,  PAGEHALT);
  elo.setIndexValue2(Sord, 24,  3000,  PAZULAGE);
  elo.setIndexValue2(Sord, 25,  3000,  PAGESAMT);
  elo.setIndexValue2(Sord, 26,  3000,  PAPLZ);
  elo.setIndexValue2(Sord, 27,  3000,  PAORT);
  elo.setIndexValue2(Sord, 28,  3000,  PAANREDE);
  elo.setIndexValue2(Sord, 29,  3000,  PATITEL);
  elo.setIndexValue2(Sord, 30,  3000,  PATELEFON);
  elo.setIndexValue2(Sord, 31,  3000,  PAGESCHLECHT);
  elo.setIndexValue2(Sord, 32,  3000,  PAFAMSTAND);
  elo.setIndexValue2(Sord, 33,  3000,  PAGEBNAME);
  elo.setIndexValue2(Sord, 34,  3000,  PAHANDY);
  elo.setIndexValue2(Sord, 35,  3000,  PAETIN);
  elo.setIndexValue2(Sord, 36,  3000,  PASTATUS);
  elo.setIndexValue2(Sord, 37,  3008,  PAABGLEICH);
},

storeIndexLines: function (Sord) {
  if (EM_MASK_LOADED == -1) { return; }
  var maskNo = Sord.getMask();
  if (maskNo == 14) {
    sys.storeIndexLines14(Sord);
  } else {
    throw("Invalid mask id found, store aborted.");
  }
},


}
//end of namespace sys


//JavaScript Template: DOKinform_as
//Begin of DOKinform_as

// ----------------------Version history --------------------------------------------------------
// 2015-05-12	UG	new function: lookupIndexByLine3s
// 2015-05-26   	MS    new function: getWfBaseUrl
// 2015-06-18	MS	new function: createFeedentry, getUserGuid
// 2015-08-28   	MS    new function: updateVersionFromSord
// 2015-09-22	MS	new function: for logging: initialisation, initialisationCSV, info, debug, error, infocsv, debugcsv, errorcsv
// 2015-10-06   	MS     new function: getActiveNodeByName
// 2015-12-02	UG	new function: lookupIndexByLineSord (CONTRACTmanager, IndexDoc)
// 2016-01-21	UG	bugfix formatValue
// 2016-02-26   MS      new function: getTimestampSQL
// 2016-02-26   MS      new function: setACL(sord, acl)
// 2016-02-26   MS      new function: setIndexValue(sord, groupName, value)
// 2016-04-08	UG	restore old fuction findcollectnodes2
// 2016-06-16   MS      new function: lookupIndexByLine4s
// 2016-07-29   MS      new function: getUTCTimestampSQL
// 2016-10-14   MS      new functions to forward the wf by node name: forwardForeignNodesByName(wfCollectNodes, nodename) and forwardForeignNodeByName(wfCollectNode, nodename)
// ------------------------------------------------------------------------------------------------

importPackage(Packages.java.lang);
importPackage(Packages.java.io);
importPackage(Packages.de.elo.ix.client);
importPackage(Packages.org.apache.commons.lang.time);
importPackage(Packages.de.elo.ix.client.feed);

var di = new Object();

di = {
    logFile: "",
    CSVLOGFileINFO: "",
    CSVLOGFileDEBUG: "",
    CSVLOGFileERROR: "",
    wkhtmltopdf: "C:\\ELOprofessional\\prog\\wkhtmltopdf\\wkhtmltopdf.exe",
    //urlFirstPart: getWfBaseUrl(),

    // Formatiert eine Zahl zu deutschen Zahlformat mit Punkt zwischen Tausenden Stellen 
    formatValue: function (val) {
        log.info("start vaformatValue of = " + val);
        if (isNaN(val)) {
			//2016-01-21 bugfix
            //return val.replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
			return val.replace('.', '').replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
        } else {
            var stringField = '' + val;
            return stringField.replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
        }
    },
    /** 
     * Gibt das ISO-Datum aus
     */
    getIsoDateToday: function () {
        // Aktuelles Datum incl. Bestandteile auslesen und  konvertieren:
        var Datum = new Date();
        var Tag = Datum.getDate().toString();
        var Monat0 = Datum.getMonth() + 1;
        var Monat = Monat0.toString();
        var Jahr = Datum.getFullYear().toString();

        // Datum-/ Zeit Bestandteile ggf. um "0" erweitern:
        if (Tag.length == 1) {
            var Tag = "0" + Tag;
        }
        if (Monat.length == 1) {
            var Monat = "0" + Monat;
        }
        var DatumISO = Jahr + "" + Monat + "" + Tag;
        return DatumISO;
    },
    /** 
     * Gibt den Zeitstempel nach dem Muster YYYYMMTT Stunde Minute Sekunde aus
     */
    getTimestampNow: function () {
        // Aktuelles Datum und Uhrzeit incl. Bestandteile auslesen und  konvertieren:
        var Datum = new Date();
        var Tag = Datum.getDate().toString();
        var Monat0 = Datum.getMonth() + 1;
        var Monat = Monat0.toString();
        var Jahr = Datum.getFullYear().toString();
        var Stunde = Datum.getHours().toString();
        var Minute = Datum.getMinutes().toString();
        var Sekunde = Datum.getSeconds().toString();


        // Datum-Bestandteile ggf. um "0" erweitern:
        if (Tag.length == 1) {
            var Tag = "0" + Tag;
        }
        if (Monat.length == 1) {
            var Monat = "0" + Monat;
        }

        var DatumISO = Jahr + "" + Monat + "" + Tag;

        // Zeit Bestandteile ggf. um "0" erweitern:
        if (Stunde.length == 1) {
            var Stunde = "0" + Stunde;
        }
        if (Minute.length == 1) {
            var Minute = "0" + Minute;
        }
        if (Sekunde.length == 1) {
            var Sekunde = "0" + Sekunde;
        }

        var timeStamp = DatumISO + " " + Stunde + "" + Minute + "" + Sekunde;
        return timeStamp;
    },
    /** 
     * Gibt den Zeitstempel nach dem Muster TT.MM.YYYY  Stunde:Minute:Sekunde aus
     */
    getTimestampNowFormatted: function () {
        // Aktuelles Datum und Uhrzeit incl. Bestandteile auslesen und  konvertieren:
        var Datum = new Date();
        var Tag = Datum.getDate().toString();
        var Monat0 = Datum.getMonth() + 1;
        var Monat = Monat0.toString();
        var Jahr = Datum.getFullYear().toString();
        var Stunde = Datum.getHours().toString();
        var Minute = Datum.getMinutes().toString();
        var Sekunde = Datum.getSeconds().toString();


        // Datum-Bestandteile ggf. um "0" erweitern:
        if (Tag.length == 1) {
            var Tag = "0" + Tag;
        }
        if (Monat.length == 1) {
            var Monat = "0" + Monat;
        }

        var Datum = Tag + "." + Monat + "." + Jahr;

        // Zeit Bestandteile ggf. um "0" erweitern:
        if (Stunde.length == 1) {
            var Stunde = "0" + Stunde;
        }
        if (Minute.length == 1) {
            var Minute = "0" + Minute;
        }
        if (Sekunde.length == 1) {
            var Sekunde = "0" + Sekunde;
        }

        var timeStamp = Datum + " " + Stunde + ":" + Minute + ":" + Sekunde;
        return timeStamp;
    },
    /** 
     * Gibt das Map-Data von ein Sord aus
     * @param sordId: ID von Sord
     */
    mapData: function SordMap(sordId) {
        this.sordId = sordId;
        this.map = [];

        SordMap.prototype.addKeyValue = function (key, value) {
            this.map.push(new KeyValue(key, value));
        };

        SordMap.prototype.write = function () {
            ixConnect.ix().checkinMap(MapDomainC.DOMAIN_SORD, this.sordId, this.sordId, this.map, LockC.NO);
        };

        SordMap.prototype.read = function () {
            var data = {};
            var items = ixConnect.ix().checkoutMap(MapDomainC.DOMAIN_SORD, this.sordId, null, LockC.NO).items;
            items.forEach(function (item) {
                data[item.key] = item.value;
            });
            this.data = data;
        };

        SordMap.prototype.getValue = function (key) {
            if (this.data[key]) {
                return this.data[key];
            }
            return "";
        };
    },
    /** 
     * F�gt den HTML-Vorlagen von Worflow-Formularen zum PDF-Dokument
     */
    appendFrozenForm: function (wfCollectNode, sord) {

        var formName = this.getFormName(wfCollectNode);

        var ticket = ixConnect.getLoginResult().getClientInfo().getTicket();
        var urlParams = new Array();
        urlParams.push("wfid=" + wfCollectNode.flowId);
        urlParams.push("nodeid=" + wfCollectNode.nodeId);
        urlParams.push("ticket=" + ticket);
        urlParams.push("lang=de")

        var url = this.getWfBaseUrl() + "/" + formName + ".jsp?" + urlParams.join("&");

        var tempFile = File.createTempFile("FrozenForm" + sord.id + "_", ".pdf");
        var tempFilePath = tempFile.getAbsolutePath();

        this.convertHtmlToPdf(url, tempFilePath);

        if (sord.type < SordC.LBT_DOCUMENT) {
            this.importDocument(sord, tempFile);
        } else {
            this.mergeWorkflowAsPDF(sord, tempFile);
        }
        tempFile["delete"]();
    },
    getFormName: function (wfCollectNode) {

        var wfdiag = wf.readActiveWorkflow(false);
        var formSpec = wfdiag.nodes[wfCollectNode.nodeId].formSpec;
        var formStartPos = formSpec.indexOf("[") + 1;
        var formEndPos = formSpec.indexOf("(");
        return formSpec.substring(formStartPos, formEndPos);
    },
    convertHtmlToPdf: function (url, destPath) {

        log.debug("url=" + url);
        log.debug("destPath=" + destPath);
        var proc = Runtime.getRuntime().exec([this.wkhtmltopdf, url, destPath]);

        var br = new BufferedReader(new InputStreamReader(proc.getErrorStream()));
        var line = null;
        while ((line = br.readLine()) != null) {
            log.debug(line);
        }

        var returnCode = proc.waitFor();
        log.debug("returnCode=" + returnCode);
    },
    importDocument: function (sord, file) {

        var ed = ixConnect.ix().createDoc(sord.id, "", null, EditInfoC.mbSordDocAtt);
        ed.sord.name = "Prozessdokumentation BNR " + BESTELLNR;
        ed.sord.mask = 0; // Maske Frei Eingabe

        ed.document.docs = [new DocVersion()];
        ed.document.docs[0].ext = ixConnect.getFileExt(file);
        ed.document.docs[0].pathId = ed.sord.path;
        ed.document.docs[0].encryptionSet = ed.sord.details.encryptionSet;
        ed.document = ixConnect.ix().checkinDocBegin(ed.document);
        ed.document.docs[0].uploadResult = ixConnect.upload(ed.document.docs[0].url, file);
        ed.document = ixConnect.ix().checkinDocEnd(ed.sord, SordC.mbAll, ed.document, LockC.NO);
        log.debug("Import frozen form: sord.id=" + ed.document.objId + ", sord.name=" + ed.sord.name);
    },
    mergeWorkflowAsPDF: function (sord, wFile) {
        try {

            //1. Sord als File auschecken
            var path = 'C:/DOKinform/temp/' + sord.getId();
            var sFile = ix.downloadDocument(path, sord);

            //2. Beide Dateien mergen
            var resultFilePath = 'C:/DOKinform/temp/' + sord.getId() + '_result.pdf';
            path = path + '.pdf';
            var wFilePath = "" + wFile.getAbsolutePath();
            var message = Packages.de.arivato.Do.merge(wFilePath, path, resultFilePath);
            var resultFile = new File(resultFilePath);
            log.info(message);

            //3. Sord wieder einschecken
            this.uploadNewVersion(sord, resultFile);
            fu.deleteFile(resultFile);


        } catch (err) {
            log.info('--->Exception in function mergeWorkflowAsPDF: ' + err);
        }
    }, /** 
     * Ladet eine neue Version des bestehnden Archiv-Dokuments
     * @param arcDoc: das Archiv-Dokument
     * @param newFile: der Pfad zum neuen Dokument in Hochkommas
     */
    uploadNewVersion: function (arcDoc, newFile) {
        try {
            var jfile = new Packages.java.io.File(newFile);
            ed = ixConnect.ix().checkoutDoc(arcDoc.id, null, EditInfoC.mbAll, LockC.NO);
            doc = ed.document;
            var extension = /[^.]+$/.exec(newFile);
            log.info("Document extension is " + extension);
            doc.getDocs()[0].setExt(extension);
            doc = ixConnect.ix().checkinDocBegin(doc);
            try {
                var inputStream = new FileInputStream(newFile);
                log.info("InputStream is created");
                doc.docs[0].uploadResult = ixConnect.upload(doc.docs[0].url, inputStream, jfile.length(), extension);
                log.info("Document is successfully uploaded");
                inputStream.close();
            } catch (error) {
                log.info("--->Exception in function uploadNewVersion: " + error);
            }
            doc = ixConnect.ix().checkinDocEnd(null, null, doc, LockC.NO);
        } catch (err) {
            log.info('--->Exception in function uploadNewVersion: ' + err);
        }
    },
    /** 
     * Ladet eine neue Version vom Sord auf das bestehnden Archiv-Dokument
     * @param arcDoc: das Archiv-Dokument
     * @param newDoc: Sord
     * @param downloadPath: full temp path to download a document
     */
    updateVersionFromSord: function (arcDoc, newDoc, downloadPath) {
        try {
            var newFile = ix.downloadDocument(downloadPath, newDoc);
            var jfile = new Packages.java.io.File(newFile);
            ed = ixConnect.ix().checkoutDoc(arcDoc.id, null, EditInfoC.mbAll, LockC.NO);
            doc = ed.document;
            var extension = /[^.]+$/.exec(newFile);
            log.info("Document extension is " + extension);
            doc.getDocs()[0].setExt(extension);
            doc = ixConnect.ix().checkinDocBegin(doc);
            try {
                var inputStream = new FileInputStream(newFile);
                log.info("InputStream is created");
                doc.docs[0].uploadResult = ixConnect.upload(doc.docs[0].url, inputStream, jfile.length(), extension);
                log.info("Document is successfully uploaded");
                inputStream.close();
            } catch (error) {
                log.info("--->Exception in function uploadNewVersion: " + error);
            }
            doc = ixConnect.ix().checkinDocEnd(null, null, doc, LockC.NO);
        } catch (err) {
            log.info('--->Exception in function uploadNewVersion: ' + err);
        }
    },
    /** 
     * Ladet eine neue Version des bestehnden Archiv-Dokuments mit Verschlagwortung
     * @param arcDoc: das Archiv-Dokument
     * @param newFile: der Pfad zum neuen Dokument in Hochkommas
     * @param kwArray: eine Array mit den Werten f�r Indexfelder. Ist nur 50-Stellen lang
     */
    uploadNewVersionWithKeywording: function (arcDoc, newFile, kwArray) {
        try {
            var jfile = new Packages.java.io.File(newFile);
            ed = ixConnect.ix().checkoutDoc(arcDoc.id, null, EditInfoC.mbSordDoc, LockC.NO);
            var objKeys = ed.sord.getObjKeys();
            for (var i = 0; i < 50; i++) {
                if (kwArray[i] != null) {
                    objKeys[i].data[0] = kwArray[i];
                }
            }
            ed.sord.setObjKeys(objKeys);
            doc = ed.document;
            var extension = /[^.]+$/.exec(newFile);
            log.info("Document extension is " + extension);
            doc.getDocs()[0].setExt(extension);
            doc = ixConnect.ix().checkinDocBegin(doc);
            try {
                var inputStream = new FileInputStream(newFile);
                log.info("InputStream is created");
                doc.docs[0].uploadResult = ixConnect.upload(doc.docs[0].url, inputStream, jfile.length(), extension);
                log.info("Document is successfully uploaded");
                inputStream.close();
            } catch (error) {
                log.info("--->Exception in function uploadNewVersion: " + error);
            }
            doc = ixConnect.ix().checkinDocEnd(ed.sord, SordC.mbAll, doc, LockC.NO);
        } catch (err) {
            log.info('--->Exception in function uploadNewVersion: ' + err);
        }
    },
    getMapValue: function (sord, key) {

        var mapData = ixConnect.ix().checkoutMap(MapDomainC.DOMAIN_SORD, sord.id, [key], LockC.NO);
        if (mapData && mapData.items && mapData.items.length > 0) {
            return mapData.items[0].value;
        }

        return "";
    },
    setMapValue: function (sord, key, value) {
        ixConnect.ix().checkinMap(MapDomainC.DOMAIN_SORD, sord.id, sord.id, [new KeyValue(key, value)], LockC.NO);
    },
    setIndexValueSpalte: function (sord, column, indexField) {
        try {
            if (di.getMapValue(sord, column + 1) != '') {
                var i = 1;
                var sachkonten = '';
                for (; ; ) {
                    var sachKonto = di.getMapValue(sord, column + i);
                    if (sachKonto == '') {
                        break;
                    }
                    sachkonten = sachkonten + sachKonto + '�';
                    i++;
                }
                var editInfodel = ixConnect.ix().checkoutSord(sord.id, EditInfoC.mbAll, LockC.NO);
                var key;
                for (var i = 0; i < 49; i++) {
                    if (editInfodel.sord.getObjKeys()[i] != null) {
                        key = editInfodel.sord.getObjKeys()[i];
                        if (key.name == indexField) {
                            var data = sachkonten.split('�');
                            key.setData(data);
                            break;
                        }
                    }
                }
                ixConnect.ix().checkinSord(editInfodel.sord, new SordZ(SordC.mbAll), LockC.NO);
            }
        } catch (err) {
            throw err;
        }
    },
    /** 
     * Gibt ein Array von Sords, die die selben Parameter haben wie die nachfolgende Argumente, aus
     * @param maskId: Masken ID
     * @argument groupName1: Name des ersten Indexfelds 
     * @param groupName2: Name des zweiten Indexfelds
     * @param value1: Inhalt des ersten Indexfelds
     * @param value2: Inhalt des zweiten Indexfelds
     */
    setIndexValueSpalten: function (sord, column1, column2, indexField) {
        try {
            var sachkonten = '';

            if (di.getMapValue(sord, column1 + 1) != '') {
                var i = 1;
                for (; ; ) {
                    var sachKonto = di.getMapValue(sord, column1 + i);
                    if (sachKonto == '') {
                        break;
                    }
                    sachkonten = sachkonten + sachKonto + '�';
                    i++;
                }
            }

            if (di.getMapValue(sord, column2 + 1) != '') {
                var i = 1;
                for (; ; ) {
                    var sachKonto = di.getMapValue(sord, column2 + i);
                    if (sachKonto == '') {
                        break;
                    }
                    sachkonten = sachkonten + sachKonto + '�';
                    i++;
                }
            }

            var editInfodel = ixConnect.ix().checkoutSord(sord.id, EditInfoC.mbAll, LockC.NO);
            var key;
            for (var i = 0; i < 49; i++) {
                if (editInfodel.sord.getObjKeys()[i] != null) {
                    key = editInfodel.sord.getObjKeys()[i];
                    if (key.name == indexField) {
                        var data = sachkonten.split('�');
                        key.setData(data);
                        break;
                    }
                }
            }
            ixConnect.ix().checkinSord(editInfodel.sord, new SordZ(SordC.mbAll), LockC.NO);

        } catch (err) {
            throw err;
        }
    },
    /** 
     * Gibt ein Array von Sords, die die selben Parameter haben wie die nachfolgende Argumente, aus
     * @param maskId: Masken ID
     * @argument groupName1: Name des ersten Indexfelds 
     * @param groupName2: Name des zweiten Indexfelds
     * @param value1: Inhalt des ersten Indexfelds
     * @param value2: Inhalt des zweiten Indexfelds
     */
    lookupIndexByLine2s: function (maskId, groupName1, groupName2, value1, value2) {

        var findInfo = new FindInfo();
        var findByIndex = new FindByIndex();
        if (maskId != "") {
            findByIndex.maskId = maskId;
        }


        var objKey1 = new ObjKey();
        var keyData1 = new Array(1);
        keyData1[0] = value1;
        objKey1.setName(groupName1);
        objKey1.setData(keyData1);

        var objKey2 = new ObjKey();
        var keyData2 = new Array(1);
        keyData2[0] = value2;
        objKey2.setName(groupName2);
        objKey2.setData(keyData2);

        var objKeys = new Array(2);
        objKeys[0] = objKey1;
        objKeys[1] = objKey2;

        findByIndex.setObjKeys(objKeys);
        findInfo.setFindByIndex(findByIndex);

        var findResult = ixConnect.ix().findFirstSords(findInfo, 1000, SordC.mbAll);
        ixConnect.ix().findClose(findResult.getSearchId());

        if (findResult.sords.length == 0) {
            return 0;
        }

        return findResult.sords;
    },
    lookupIndexByLine3s: function (maskId, groupName1, groupName2, groupName3, value1, value2, value3) {

        var findInfo = new FindInfo();
        var findByIndex = new FindByIndex();
        if (maskId != "") {
            findByIndex.maskId = maskId;
        }


        var objKey1 = new ObjKey();
        var keyData1 = new Array(1);
        keyData1[0] = value1;
        objKey1.setName(groupName1);
        objKey1.setData(keyData1);

        var objKey2 = new ObjKey();
        var keyData2 = new Array(1);
        keyData2[0] = value2;
        objKey2.setName(groupName2);
        objKey2.setData(keyData2);

        var objKey3 = new ObjKey();
        var keyData3 = new Array(1);
        keyData3[0] = value3;
        objKey3.setName(groupName3);
        objKey3.setData(keyData3);

        var objKeys = new Array(3);
        objKeys[0] = objKey1;
        objKeys[1] = objKey2;
        objKeys[2] = objKey3;

        findByIndex.setObjKeys(objKeys);
        findInfo.setFindByIndex(findByIndex);

        var findResult = ixConnect.ix().findFirstSords(findInfo, 1000, SordC.mbAll);
        ixConnect.ix().findClose(findResult.getSearchId());

        if (findResult.sords.length == 0) {
            return 0;
        }

        return findResult.sords;
    }, lookupIndexByLine4s: function (maskId, groupName1, groupName2, groupName3, groupName4, value1, value2, value3, value4) {

        var findInfo = new FindInfo();
        var findByIndex = new FindByIndex();
        if (maskId != "") {
            findByIndex.maskId = maskId;
        }


        var objKey1 = new ObjKey();
        var keyData1 = new Array(1);
        keyData1[0] = value1;
        objKey1.setName(groupName1);
        objKey1.setData(keyData1);

        var objKey2 = new ObjKey();
        var keyData2 = new Array(1);
        keyData2[0] = value2;
        objKey2.setName(groupName2);
        objKey2.setData(keyData2);

        var objKey3 = new ObjKey();
        var keyData3 = new Array(1);
        keyData3[0] = value3;
        objKey3.setName(groupName3);
        objKey3.setData(keyData3);
        
        var objKey4 = new ObjKey();
        var keyData4 = new Array(1);
        keyData4[0] = value4;
        objKey4.setName(groupName4);
        objKey4.setData(keyData4);

        var objKeys = new Array(4);
        objKeys[0] = objKey1;
        objKeys[1] = objKey2;
        objKeys[2] = objKey3;
        objKeys[3] = objKey4;

        findByIndex.setObjKeys(objKeys);
        findInfo.setFindByIndex(findByIndex);

        var findResult = ixConnect.ix().findFirstSords(findInfo, 1000, SordC.mbAll);
        ixConnect.ix().findClose(findResult.getSearchId());

        if (findResult.sords.length == 0) {
            return 0;
        }

        return findResult.sords;
    },
	
    /** 
     * Gibt das erste (!!) Sords, mit den Parameter wie die nachfolgende Argumente, aus
     * @param maskId: Masken ID
     * @argument groupName: Name des  Indexfelds 
     * @param value: Inhalt des  Indexfelds
     */	
	lookupIndexByLineSord: function (maskId, groupName, value) {
		var findInfo = new FindInfo();
		var findByIndex = new FindByIndex();
		if (maskId != "") {
		  findByIndex.maskId = maskId;
		}

		var objKey = new ObjKey();
		var keyData = new Array(1);
		keyData[0] = value;
		objKey.setName(groupName);
		objKey.setData(keyData);

		var objKeys = new Array(1);
		objKeys[0] = objKey;

		findByIndex.setObjKeys(objKeys);
		findInfo.setFindByIndex(findByIndex);

		var findResult = ixConnect.ix().findFirstSords(findInfo, 1, SordC.mbMin);
		ixConnect.ix().findClose(findResult.getSearchId());

		if (findResult.sords.length == 0) {
		  return 0;
		}

		return findResult.sords[0];
  },
	
	
    /** 
     * Gibt auktuelles Datum nach TT.MM.YYYY Muster aus
     */
    getDateToday: function () {
        // Aktuelles Datum incl. Bestandteile auslesen und  konvertieren:
        var Datum = new Date();
        var Tag = Datum.getDate().toString();
        var Monat0 = Datum.getMonth() + 1;
        var Monat = Monat0.toString();
        var Jahr = Datum.getFullYear().toString();

        // Datum-/ Zeit Bestandteile ggf. um "0" erweitern:
        if (Tag.length == 1) {
            var Tag = "0" + Tag;
        }
        if (Monat.length == 1) {
            var Monat = "0" + Monat;
        }
        //var DatumISO = Jahr + "" + Monat + "" + Tag;
        var DatumISO = Tag + '.' + Monat + '.' + Jahr;
        return DatumISO;
    },
    /** 
     * Findet das Dokument f�r dem ein Workflow vorliegt und der Name der aktuellen Knote ist "nodeNames" 
     * @param wfCollectNode: Konoten-Name des Workflows
     */
    findCollectNodes: function (sordId, nodeNames) {
        var findTasksInfo = new FindTasksInfo();
        findTasksInfo.allUsers = true;
        findTasksInfo.inclWorkflows = true;
        findTasksInfo.objId = sordId;
        var findResult = ixConnect.ix().findFirstTasks(findTasksInfo, 100);
        ixConnect.ix().findClose(findResult.searchId);
        var activeNodes = [];
        findResult.tasks.forEach(function (task) {
            if (nodeNames.indexOf(task.wfNode.nodeName) > -1) {
                log.debug("Active node found: wfCollectNode.flowName=" + task.wfNode.flowName + ", wfCollectNode.nodeName=" + task.wfNode.nodeName);
                activeNodes.push(task.wfNode);
            }
        });
        return activeNodes;
    },
	
	
    /** 
     * Findet das Dokument f�r dem ein Workflow vorliegt und der Name der aktuellen Knote ist genau gleich "nodeNames" 
     * @param wfCollectNode: Konoten-Name des Workflows
     */
	 //VWD //
    findCollectNodes2: function(sordId, nodeNames) {
        var findTasksInfo = new FindTasksInfo();
        findTasksInfo.allUsers = true;
        findTasksInfo.inclWorkflows = true;
        findTasksInfo.objId = sordId;
        var findResult = ixConnect.ix().findFirstTasks(findTasksInfo, 100);
        ixConnect.ix().findClose(findResult.searchId);
        var activeNodes = [];
        findResult.tasks.forEach(function(task) {
            if (nodeNames == task.wfNode.nodeName) {
                log.debug("Active node found: wfCollectNode.flowName=" + task.wfNode.flowName + ", wfCollectNode.nodeName=" + task.wfNode.nodeName);
                activeNodes.push(task.wfNode);
            }
        });
        return activeNodes;
    },		
	
    /** 
     * Die Workflow-Knoten von Dokumente (nicht der Sord, der durch Such-Regel gefunden wurde) werden weitergeleitet. 
     * @param wfCollectNode: Konoten-Name des Workflows
     */
    forwardForeignNodes: function (wfCollectNodes) {
        try {
            wfCollectNodes.forEach(function (wfCollectNode) {
                this.forwardForeignNode(wfCollectNode);
            }, this);
        } catch (err) {
            throw err;
        }
    },
    /** 
     * Der Workflow f�r einen Dokument (nicht der Sord, der durch Such-Regel gefunden wurde) werden weitergeleitet. 
     * @param wfCollectNode: Konoten-Name des Workflows
     */
    forwardForeignNode: function (wfCollectNode) {
        try {
            var wfEditNode = ixConnect.ix().beginEditWorkFlowNode(wfCollectNode.flowId, wfCollectNode.nodeId, LockC.YES);
            if (wfEditNode.succNodes.length == 1) {
                var succNodeId = wfEditNode.succNodes[0].id;
                log.debug("ForwardForeignNode: flowName=" + wfCollectNode.flowName + ", nodeName=" + wfCollectNode.nodeName + ", succNodeId=" + succNodeId);
                ixConnect.ix().endEditWorkFlowNode(wfCollectNode.flowId, wfCollectNode.nodeId, false, false, wfCollectNode.nodeName, "Forwarded by ELOas", [succNodeId]);
            } else {
                log.debug("Successor node not clear: flowName=" + wfCollectNode.flowName + ", nodeName=" + wfCollectNode.nodeName + ", succNodes.length=" + wfEditNode.succNodes.length);
                ixConnect.ix().endEditWorkFlowNode(wfCollectNode.flowId, wfCollectNode.nodeId, false, true, "", "", null);
            }
        } catch (err) {
            throw err;
        }
    },	
	
    /** 
     * Die Workflow-Knoten von Dokumente (nicht der Sord, der durch Such-Regel gefunden wurde) werden weitergeleitet. 
     * @param wfCollectNode: Knoten-Name des Workflows
     */
    forwardForeignNodesByName: function (wfCollectNodes, nodename) {
        try {
            wfCollectNodes.forEach(function (wfCollectNode) {
                this.forwardForeignNodeByName(wfCollectNode, nodename);
            }, this);
        } catch (err) {
            throw err;
        }
    },
    /** 
     * Der Workflow f�r einen Dokument (nicht der Sord, der durch Such-Regel gefunden wurde) werden weitergeleitet. 
     * @param wfCollectNode: Konoten-Name des Workflows
     */
    forwardForeignNodeByName: function (wfCollectNode, nodename) {
        try {
            var wfEditNode = ixConnect.ix().beginEditWorkFlowNode(wfCollectNode.flowId, wfCollectNode.nodeId, LockC.YES);
                var succNodeId = -1;
				for(var nextNodeCounter = 0; nextNodeCounter < wfEditNode.succNodes.length; nextNodeCounter++){
					if(wfEditNode.succNodes[nextNodeCounter].name == nodename){
						succNodeId = wfEditNode.succNodes[nextNodeCounter].id
					}
				}
				if(succNodeId != -1){
					log.debug("ForwardForeignNode: flowName=" + wfCollectNode.flowName + ", nodeName=" + wfCollectNode.nodeName + ", succNodeId=" + succNodeId);
					ixConnect.ix().endEditWorkFlowNode(wfCollectNode.flowId, wfCollectNode.nodeId, false, false, wfCollectNode.nodeName, "Forwarded by ELOas", [succNodeId]);
				}else{
					log.warn("Invalid next node name");
				}
        } catch (err) {
            throw err;
        }
    },
    /** 
     * Diese Funktion �berpr�ft, ob Seitenzahlen zwei mal vorkommen. Als Parameter �bernimmt sie den Barcode-String in Form von �123456;1�65432;2 oder �123456-1;1�65432-2;2
     * @param bcString: Barcode-String in Hochkomma
     */
    hasNotDuplicates: function (bcString) {
        var bc = bcString;
        var pageNumbers = [];
        var i = 0;
        while (bc.length != 0) {
            while (bc.substr(0, 1) == "�") {
                bc = bc.substr(1, bc.length);
            }
            if (bc.indexOf(';') > -1) {
                bc = bc.substr(bc.indexOf(';') + 1, bc.length);
                if (bc.indexOf('�') > -1) {
                    pageNumbers[i] = bc.substr(0, bc.indexOf('�'));
                    bc = bc.substr(bc.indexOf('�'), bc.length);
                } else {
                    pageNumbers[i] = bc;
                    bc = '';
                }
            }
            i++;
        }
        var valuesSoFar = {};
        for (var i = 0; i < pageNumbers.length; ++i) {
            var value = pageNumbers[i];
            if (Object.prototype.hasOwnProperty.call(valuesSoFar, value)) {
                return false;
            }
            valuesSoFar[value] = true;
        }
        return true;
    },
    /** 
     * Gibt den Pfad von Ordner aus
     * @param sord: Ordner 
     * @param archiveName: Name des Archivs in Hochkomma
     */
    getFolderPath: function (sord, archiveName) {
        var parent = ixConnect.ix().checkoutSord(sord.parentId, SordC.mbAllIndex, LockC.NO);
        var parentName = parent.name;
        var path = parentName + '\�' + sord.name;
        while (parentName != archiveName) {
            var tmpParent = ixConnect.ix().checkoutSord(parent.parentId, SordC.mbAllIndex, LockC.NO);
            parentName = tmpParent.name;
            path = parentName + '\�' + path;
            parent = tmpParent;
        }
        return path;
    },
    /** 
     * Gibt den Pfad von einem Dokumenten aus
     * @param sord: Dokument 
     * @param archiveName: Name des Archivs in Hochkomma
     */
    getDocumentPath: function (sord, archiveName) {
        var parent = ixConnect.ix().checkoutSord(sord.parentId, SordC.mbAllIndex, LockC.NO);
        var parentName = parent.name;
        var path = parentName;
        while (parentName != archiveName) {
            var tmpParent = ixConnect.ix().checkoutSord(parent.parentId, SordC.mbAllIndex, LockC.NO);
            parentName = tmpParent.name;
            path = parentName + '\�' + path;
            parent = tmpParent;
        }
        return path;
    },
    /** 
     * F�gt einen neuen Ordner im Archiv ein 
     * @param parentID: parentID f�r Ordner 
     * @param maskID: ID f�r Maske (Zahl oder Name) 
     * @param bez: ObjShort f�r Ordner 
     */
    insertFolder: function (parentID, maskID, bez) {
        var editInfo = new EditInfoC();
        var LOCK = new LockC();
        var SORD = new SordC();
        var ed = ixConnect.ix().createSord(parentID, maskID, editInfo.getMbSord());
        var sord = ed.getSord();
        sord.setName(bez);
        var objID = ixConnect.ix().checkinSord(sord, SORD.getMbAll(), LOCK.getYES());
        return objID;
    },
    /** 
     * L�scht alle Sonderzeichen und umwandelt alle Umlaute 
     * @param expression: Eine String-Variable, die von Sonderzeichen befreit werden soll
     * @param deleteBlank: Eine Boolean-Variable, die f�rs L�schen der Leerzeichen auf true und sonst auf false gesetzt wird  
     */
    cleanUp: function (expression, deleteBlank) {
        var tmp = expression;
        tmp = tmp.replace(/�/g, 'oe');
        tmp = tmp.replace(/�/g, 'Oe');
        tmp = tmp.replace(/�/g, 'ae');
        tmp = tmp.replace(/�/g, 'Ae');
        tmp = tmp.replace(/�/g, 'ue');
        tmp = tmp.replace(/�/g, 'Ue');
        tmp = tmp.replace(/�/g, 'ss');
        tmp = tmp.replace(/�/g, 'e');
        tmp = tmp.replace(/[^0-9a-zA-Z ]/g, '');
        if (deleteBlank) {
            tmp = tmp.replace(/ /g, '');
        }
        return tmp;
    },
    /** 
     * Schneidet nach dem ersten Pipe alle Zeichen aus einer String-Eingabe-Variable und gibt das Ergebnis aus
     * @param stringWithPipe: Eine String-Variable, die Zeichen Pipe enth�lten kann
     */
    cutAfterPipe: function (stringWithPipe) {
        var outPut = stringWithPipe;
        if (outPut.indexOf('|') > -1) {
            outPut = outPut.substr(0, outPut.indexOf('|'));
        }
        return outPut;
    },
    /** 
     * Gibt den Timestamp von einem Sord
     * @param String: id von Sord
     */
    getSordTStamp: function (id) {
        return ixConnect.ix().checkoutSord(id, EditInfoC.mbAll, LockC.NO).sord.TStamp;
    },
    /** 
     * L�scht das Sord-Objekt
     * @param Sord: sord
     */
    deleteSord: function (sord) {
        var delOpts = new DeleteOptions();
        delOpts.deleteFinally = true;
        ix.deleteSord(sord.parentId, sord.id, LockC.NO, delOpts);
    },
    //ELOas Treewalk ACL auf alle Eintr�ge vererben, vorhandene ACL l�schen
    swapAclTree: function (sord, newACL, includeRefs) {
        log.debug(" ---> Start swapAclTree of: " + sord.name);
        log.debug(" ---  Include references = " + includeRefs);
        log.debug("   >> Set new ACL: " + newACL);
        this.swapAcl(sord, newACL);
        var children = this.collectChildrenRef(sord.id, includeRefs);
        log.debug(" ---  Found Children: " + children.length);
        if (!children) {
            return;
        }
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            var isDocument = child.type >= SordC.LBT_DOCUMENT && child.type <= SordC.LBT_DOCUMENT_MAX;
            if (isDocument) {
                log.debug(" ---- work on doc...");
                //this.processDocument(child, newACL);
                this.swapAcl(sord, newACL);
            }
            log.debug(i + ": work on folder...");
            this.swapAclTree(child, newACL, includeRefs);
        }
    },
    //ELOas Direct-Treewalk
    processDocument: function (sord, newACL) {
        log.info(" ---> Start processDocument: " + sord.name);
        this.swapAcl(sord, newACL);
        //  log.debug("processDocument: " + sord.refPaths[0].pathAsString + "�" + sord.name);

    },
    //ACL-String (verschl�sselte ACL) auf Sord �bertagen, vorhandene ACL l�schen 
    swapAcl: function (sord, newACL) {
        log.info(" ---> Start swapACL for Sord: " + sord.name + " (id = " + sord.id + ")");
        log.debug("   >> set ACL to: " + newACL);
        var editInfo = ixConnect.ix().checkoutSord(sord.id, EditInfoC.mbAll, LockC.NO);
        var mysord = editInfo.sord;
        log.debug("read old ACL = " + mysord.acl);
        mysord.setAclItems(null);
        mysord.setAcl(newACL);
        log.debug("set new ACL = " + mysord.acl);
        ixConnect.ix().checkinSord(mysord, SordC.mbAll, LockC.NO);
        log.debug(" ---  checkin done...");
    },
    //aus ix-blbliothek �bernommen, Parameter noRef hinhzugef�gt. bei true werden nur echte Children und keine Referenzen gefunden
    collectChildrenRef: function (parentId, noRef) {
        var findInfo = new FindInfo();
        var findChildren = new FindChildren();
        findChildren.parentId = parentId;
        findChildren.mainParent = !noRef;
        findInfo.findChildren = findChildren;

        var findResult = ixConnect.ix().findFirstSords(findInfo, 1000, SordC.mbAll);
        ixConnect.ix().findClose(findResult.searchId);

        return findResult.sords;
    },
    getWfBaseUrl: function () {
        var wfBaseUrl = "";
        if (wfBaseUrl == "") {
            wfBaseUrl = di.getUserOption("Client.1398.1.0.Options.EloWfUrl.", UserProfileC.USERID_ALL);
            /*   if (this.wfBaseUrl == "")) {
             log.warn("ELOwf base URL is empty.");
             } */
        }
        log.info("wfBaseUrl= " + wfBaseUrl);
        return wfBaseUrl;
    },
    getUserOption: function (key, userId) {

        var keyValue = new KeyValue(key, "");
        var userProfile = new UserProfile([keyValue], userId);
        userProfile = ixConnect.ix().checkoutUserProfile(userProfile, LockC.NO);
        if (userProfile) {
            var options = userProfile.options;
            if (options.length > 0) {
                return options[0].value;
            }
        }
        return "";
    },
    createFeedentry: function (username, feedText, ObjectID) {
        var user = di.getUserGuid(username);
        var feed = ixConnect.getFeedService();
        var action = feed.createAction(EActionType.UserComment, ObjectID);
        action.setType(EActionType.UserComment);
        action.setText(feedText);
        action.setUserGuid(user);
        feed.checkinAction(action, ActionC.mbAll);
        log.debug("-- new feedentry created with text = " + feedText);
    },
    getUserGuid: function (username) {
        var userGuid = "";
        var users = ixConnect.ix().checkoutUsers(null, CheckoutUsersC.ALL_USERS_AND_GROUPS_RAW, LockC.NO);
        for (var i = 0; i < users.length; i++) {
            if (username == users[i].name) {
                userGuid = users[i].guid;
                break;
            }
        }
        log.debug("-- guid for user " + username + " = " + userGuid);
        return userGuid;
    },
    /*  di.initialisation(logpath, "ELOas_Name.log");
     *  di.info('message');
     */
    initialisation: function (path, fileName) {
        logFile = new File(path + File.separator + fileName);
    },
    info: function (message) {
        var fileWriter = new FileWriter(logFile, true);
        var buffWriter = new BufferedWriter(fileWriter);
        var Datum = new Date();
        buffWriter.write(di.getTimestampNowFormatted() + "," + Datum.getMilliseconds() + " " + "INFO - " + message + "\n");
        buffWriter.flush();
    },
    debug: function (message) {
        var fileWriter = new FileWriter(logFile, true);
        var buffWriter = new BufferedWriter(fileWriter);
        var Datum = new Date();
        buffWriter.write(di.getTimestampNowFormatted() + "," + Datum.getMilliseconds() + " " + "DEBUG - " + message + "\n");
        buffWriter.flush();
    },
    error: function (message) {
        var fileWriter = new FileWriter(logFile, true);
        var buffWriter = new BufferedWriter(fileWriter);
        var Datum = new Date();
        buffWriter.write(di.getTimestampNowFormatted() + "," + Datum.getMilliseconds() + " " + "ERROR - " + message + "\n");
        buffWriter.flush();
    },
    /*
     * di.initialisationCSV(logpath, "Name.csv", "info", "YES");
     * di.infocsv('message');
     */
    initialisationCSV: function (CSVInfopath, CSVInfofileName, level, activate) {
        if (activate == "YES") {
            if (level == "info")
                CSVLOGFileINFO = new File(CSVInfopath + File.separator + CSVInfofileName);
            else if (level == "debug")
                CSVLOGFileDEBUG = new File(CSVInfopath + File.separator + CSVInfofileName);
            else if (level == "error")
                CSVLOGFileERROR = new File(CSVInfopath + File.separator + CSVInfofileName);
        }
    },
    infocsv: function (message) {
        try {
            var fileWriter = new FileWriter(CSVLOGFileINFO, true);
            var buffWriter = new BufferedWriter(fileWriter);
            buffWriter.write(di.getTimestampNowFormatted() + ";" + message + "\n");
            buffWriter.flush();
        } catch (e) {

        }
    },
    debugcsv: function (message) {
        try {
            var fileWriter = new FileWriter(CSVLOGFileDEBUG, true);
            var buffWriter = new BufferedWriter(fileWriter);
            buffWriter.write(di.getTimestampNowFormatted() + ";" + message + "\n");
            buffWriter.flush();
        } catch (e) {

        }
    },
    errorcsv: function (message) {
        try {
            var fileWriter = new FileWriter(CSVLOGFileERROR, true);
            var buffWriter = new BufferedWriter(fileWriter);
            buffWriter.write(di.getTimestampNowFormatted() + ";" + message + "\n");
            buffWriter.flush();
        } catch (e) {

        }
    },
    getActiveNodeByName: function (wfDiagram, nodeName) {
        var nodes = wfDiagram.getNodes();
        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];
          if (node.getName() == nodeName && node.exitDateIso == '' && node.enterDateIso > 0 ) {
            return node;
          }
        }
        return null;
    },
    /** 
     * Gibt den Zeitstempel nach dem Muster YYYY-MM-TTTStunde:Minute:Sekunde.000 (2016-02-26T09:44:12.000) aus
     */
    getTimestampSQL: function () {
	var Datum = new Date();
	var Tag = Datum.getDate().toString();
	var Monat0 = Datum.getMonth() + 1;
	var Monat = Monat0.toString();
	var Jahr = Datum.getFullYear().toString();
	var Stunde = Datum.getHours().toString();
	var Minute = Datum.getMinutes().toString();
	var Sekunde = Datum.getSeconds().toString();
	if (Tag.length == 1) {
		Tag = "0" + Tag;
	}
	if (Monat.length == 1) {
		Monat = "0" + Monat;
	}
	if (Stunde.length == 1) {
		Stunde = "0" + Stunde;
	}
	if (Minute.length == 1) {
		Minute = "0" + Minute;
	}
	if (Sekunde.length == 1) {
		Sekunde = "0" + Sekunde;
	}
        return Jahr + '-' + Monat + '-' + Tag + 'T' + Stunde + ':' + Minute + ':' + Sekunde + '.000';
    },
	/** 
     * Gibt den UTC Zeitstempel nach dem Muster YYYY-MM-TTTStunde:Minute:Sekunde.000 (2016-02-26T09:44:12.000) aus
     */
    getUTCTimestampSQL: function () {
		var now = new Date();
		var Datum = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds());
		var Tag = Datum.getDate().toString();
		var Monat0 = Datum.getMonth() + 1;
		var Monat = Monat0.toString();
		var Jahr = Datum.getFullYear().toString();
		var Stunde = Datum.getHours().toString();
		var Minute = Datum.getMinutes().toString();
		var Sekunde = Datum.getSeconds().toString();
		if (Tag.length == 1) {
			Tag = "0" + Tag;
		}
		if (Monat.length == 1) {
			Monat = "0" + Monat;
		}
		if (Stunde.length == 1) {
			Stunde = "0" + Stunde;
		}
		if (Minute.length == 1) {
			Minute = "0" + Minute;
		}
		if (Sekunde.length == 1) {
			Sekunde = "0" + Sekunde;
		}
		return Jahr + '-' + Monat + '-' + Tag + 'T' + Stunde + ':' + Minute + ':' + Sekunde + '.000';
    },
    /** 
     * setACL(Sord, "�RWDEL:Group1�RWEL:Group2�R:Jeder")
     */
    setACL: function (sord, acl){
        var items = acl.split("�");
        var cnt = items.length;
        var aclItems = new Array(cnt);
        for (var i = 0; i < cnt; i++) {
                aclItems[i] = new AclItem();
        }
        sord.setAclItems(aclItems);
        for (var i = 0; i < cnt; i++) {
                elo.fillupAclItem(aclItems[i], items[i]);
        }
    },
    setIndexValue: function (sord, groupName, value){
    for(var objKeysCounter = 0; objKeysCounter < sord.getObjKeys().length; objKeysCounter++ ){
        if(sord.getObjKeys()[objKeysCounter].name == groupName)
            elo.setIndexValue(sord, objKeysCounter, value);
        }
    }
}
// end of namespace DOKinform_as




//JavaScript Template: aclu
// JavaScript Dokument
// @Deprecated

/**
 * @class aclu
 * @singleton
 */
var aclu = new ELOAclUtils();

function ELOAclUtils() {
}

/**
 * @method aclsSplitGroup
 * Trennt die einzelnen Gruppen aus der angegebenen Gruppe.
 * 
 * @param {IXConnection} connection Indexserver-Verbindung
 * @param {Number} fromGroup ID der Ausgangsgruppe
 * @param {Number} toGroup1 ID der ersten Zielgruppe
 * @param {Number} toGroup2 ID der zweiten Zielgruppe
 */
ELOAclUtils.prototype.aclsSplitGroup = function(connection, fromGroup, toGroup1, toGroup2) {
  this.processAcls(connection, 1, fromGroup, toGroup1, toGroup2, 31, 31);
}

/**
 * @method aclsMergeGroups
 * Fügt die einzelnen Gruppen in die angegebene Zielgruppe ein.
 * 
 * @param {IXConnection} connection Indexserver-Verbindung
 * @param {Number} mergeGroup1 Erste Gruppe
 * @param {Number} mergeGroup2 Zweite Gruppe
 * @param {Number} toGroup Zielgruppe
 */
ELOAclUtils.prototype.aclsMergeGroups = function(connection, mergeGroup1, mergeGroup2, toGroup) {
  this.processAcls(connection, 2, mergeGroup1, mergeGroup2, toGroup, 0, 0);
}

/**
 * @method aclsRemoveGroup
 * Entfernt die angegebene Gruppe aus den Berechtigungen.
 * 
 * @param {IXConnection} connection Indexserver-Verbindung
 * @param {AclItem} group ID der Gruppe
 */
ELOAclUtils.prototype.aclsRemoveGroup = function(connection, group) {
  this.processAcls(connection, 3, group, 0, 0, 0, 0);
}

/**
 * @method processAcls
 * Bearbeitet die angegebenen Berechtigungsgruppen anhand des angegebenen Modus.
 * 
 * @param {IXConnection} connection Indexserver-Verbindung
 * @param {Number} mode Modus
 * @param {Number} group1 Erste Gruppe
 * @param {Number} group2 Zweite Gruppe
 * @param {Number} group3 Dritte Gruppe
 * @param {Number} access2 Zweite Berechtigungsflags
 * @param {Number} access3 Dritte Berechtigungsflags
 */
ELOAclUtils.prototype.processAcls = function(connection, mode, group1, group2, group3, access2, access3) {
  db.init(connection);
  var dbcn = EM_connections[connection].dbcn;
  var stmt = dbcn.createStatement();
  
  var fromGroup = 0;
  var toGroup1 = 3;
  var toGroup2 = 12;
  
  var cmd;
  var sGroup1 = aclu.encode20Bit(group1);
  var sGroup2 = aclu.encode20Bit(group2);
  
  switch (mode) {
    case 1:
      // Eine Gruppe in zwei Gruppen aufsplitten
      cmd = "select distinct objacl from thiele.dbo.objekte where objacl like '%7_" + sGroup1 + "%'";
      break;
      
    case 2:
      // Zwei Gruppen in eine Gruppe zusammenfügen
      cmd = "select distinct objacl from thiele.dbo.objekte where objacl like '%7_" + sGroup1 + "%' and objacl like '%7_" + sGroup2 + "%'";
      break;
      
    case 3:
      // Anwender/Gruppe löschen
      cmd = "select distinct objacl from thiele.dbo.objekte where objacl like '%7_" + sGroup1 + "%'";
      break;
  }
      
  var result = stmt.executeQuery(cmd);
  var modifications = new Array();
  log.debug("Collect Change List");
  
  while (result.next()) {
    var acl = result.getString(1);
    log.debug("ACL: " + acl);
    var items = this.splitAcl(acl);
    var newItems;
    
    switch (mode) {
      case 1:
        newItems = this.splitGroup(items, group1, group2, access2, group3, access3);
        break;
        
      case 2:
        newItems = this.mergeGroups(items, group1, group2, group3, 10);
        break;
        
      case 3:
        newItems = this.removeGroup(items, group1);
        break;
    }
    
    var newAcl = aclu.joinAcl(newItems);
    
    var job = new Object();
    job.oldAcl = acl;
    job.newAcl = newAcl;
    modifications.push(job);
    
    log.debug("NEW ACL: " + newAcl);
  }
  
  result.close();
  
  log.debug("Update DB ACLs");
  for (var i = 0; i < modifications.length; i++) {
    var job = modifications[i];
    var ucmd = "update thiele.dbo.objekte set objacl = '" + job.newAcl +
               "' where objacl = '" + job.oldAcl + "'";
    log.info("CMD: " + ucmd);
    stmt.executeUpdate(ucmd);
  }
  
  stmt.close();
}

/**
 * @method encodeDigit
 * Liefert ein Zeichen aus dem angegebenen 5 Bit Wert zurück.
 * 
 * @param {Number} value 5 bit Wert
 * @returns {String} Zeichen
 */
ELOAclUtils.prototype.encodeDigit = function(value) {
  if (value > 25) {
    return String.fromCharCode(value + 22);
  } else {
    return String.fromCharCode(value + 65);
  }
}

/**
 * @method decodeDigit
 * Liefert einen 5 bit Wert aus dem angegebenen Zeichen zurück.
 * 
 * @param {Number} valueString Zeichen
 * @param {Number} position Position
 * @returns {Number} 5 bit Wert
 */
ELOAclUtils.prototype.decodeDigit = function(valueString, position) {
  var val = valueString.charCodeAt(position);
  if (val > 64) {
    return val - 65;
  } else {
    return val - 22;
  }
}

/**
 * @method encode20Bit
 * Liefert vier Zeichen aus dem angegebenen 20 bit Wert zurück.
 * 
 * @param {Number} value 20 bit Wert
 * @returns {String} Zeichen
 */
ELOAclUtils.prototype.encode20Bit = function(value) {
  var res = "";
  
  for (var i = 0; i < 4; i++) {
    var part = value & 31;
    res += this.encodeDigit(part);    
    value = value / 32;
  }
  
  return res;
}

/**
 * @method decode20Bit
 * Liefert einen 20 Bit Wert aus den angegebenen vier Zeichen zurück.
 * 
 * @param {String} value Vier Zeichen
 * @returns {Number} 20 Bit Wert
 */
ELOAclUtils.prototype.decode20Bit = function(value) {
  value = String(value);
  
  var res = 0;
  for (var i = value.length - 1; i >= 0; i--) {
    res = (res * 32) + this.decodeDigit(value, i);
  }
  
  return res;
}

/**
 * @method getAcl
 * Liefert einen 6 Zeichen acl String aus der Anwender oder Gruppennummer,
 * den Zugriffsrechten und dem Typ (6: Schlüssel, 7: User/Group) zurück.
 * 
 * @param {Number} userOrGroupId
 * @param {Number} accessMask
 * @param {Number} aclType
 * @returns {String} Acl String
 */
ELOAclUtils.prototype.getAcl = function(userOrGroupId, accessMask, aclType) {
  var res = "7";
  
  if (aclType != undefined) {
    res = aclType;
  }
  
  res += this.encodeDigit(accessMask);
  res += this.encode20Bit(userOrGroupId);
  
  return res;
}

/**
 * @method splitAcl
 * Liefert eine Liste mit Berechtigungen aus dem angegebenen Berechtigungsstring zurück.
 * 
 * @param {String} aclString Berechtigungsstring
 * @returns {Array} Liste mit Berechtigungen
 */
ELOAclUtils.prototype.splitAcl = function(aclString) {
  aclString = String(aclString);
  var res = new Array();
  var len = aclString.length;
  
  var andGroupCounter = 0;
  var isInAndGroup = false;
  var lastItem;
  
  for (var i = 0; i < len; i += 6) {
    var item = new Object();
    item.id = this.decode20Bit(aclString.substring(i + 2, i + 6));
    item.access = this.decodeDigit(aclString, i + 1);
    item.type = aclString.substring(i, i + 1);
    
    if (item.access == 0) {
      if (!isInAndGroup) {
        andGroupCounter++;
        lastItem.andGroupId = andGroupCounter;
        isInAndGroup = true;
      }
      
      item.andGroupId = andGroupCounter;
    } else {
      isInAndGroup = false;
      item.andGroupId = 0;
    }
    
    res.push(item);
    lastItem = item;
  }
  
  return res;
}

/**
 * @method joinAcl
 * Fügt die angegebene ACL-Items Liste zu einem ACL-String zusammen.
 * 
 * @param {Array} aclItemList Liste mit Berechtigungen
 * @returns {String} ACL-String
 */
ELOAclUtils.prototype.joinAcl = function(aclItemList) {
  var res = "";
  
  for (var i = 0; i < aclItemList.length; i++) {
    if (aclItemList[i].type == "*") {
      continue;
    }
    
    res += this.getAcl(aclItemList[i].id, aclItemList[i].access, aclItemList[i].type);
  }
  
  return res;
}

/**
 * @method removeGroup
 * Entfernt die Gruppe aus der angegebenen Berechtigungsliste.
 * 
 * @param {Array} aclItemList Liste mit Berechtigungen
 * @param {AclItem} searchGroup Zu entfernende Gruppe
 * @returns {ArrayList} Liste mit Berechtigungen
 */
ELOAclUtils.prototype.removeGroup = function(aclItemList, searchGroup) {
  for (var i = 0; i < aclItemList.length; i++) {
    var item = aclItemList[i];
    if ((item.id == searchGroup) && (item.type == '7')) {
      var oldaccess = item.access;
      aclItemList.splice(i, 1);
      if ((i < aclItemList.length) && (aclItemList[i].access == 0)) {
        // Entfernter Eintrag war Starteintrag einer UND Gruppe, 
        // Berechtigungen auf neuen Starteintrag übertragen.
        aclItemList[i].access = oldaccess;
      }
      i--;
    }
  }
  
  return aclItemList;
}

/**
 * @method mergeGroups
 * Fügt zwei Gruppen zu einer Gruppe zusammen. Die beiden Gruppen dürfen nicht Mitglied
 * unterschiedlicher UND-Gruppen sein und sie dürfen jeweils nur einmal vorkommen.
 * 
 * @param {Array} aclItemList Liste mit Berechtigungen
 * @param {AclItem} mergeGroup1 Erste Gruppe
 * @param {AclItem} mergeGroup2 Zweite Gruppe
 * @param {AclItem} destGroup Zielgruppe
 * @param {Number} mergeMode Einfügemodus
 * @returns {Array} Liste mit Berechtigungen
 */
ELOAclUtils.prototype.mergeGroups = function(aclItemList, mergeGroup1, mergeGroup2, destGroup, mergeMode) {
  for (var g1 = 0; g1 < aclItemList.length; g1++) {
    var item1 = aclItemList[g1];
    if ((item1.id == mergeGroup1) && (item1.type == "7")) {
      var startg2 = 0;
      var endg2 = aclItemList.length;
      
      if (item1.andGroupId > 0) {
        // Nur diese UND Gruppe durchsuchen
        startg2 = g1 + 1;
        var actAG = item1.andGroupId;
        
        for (var l = startg2; l < aclItemList.length; l++) {
          var litem = aclItemList[l];
          if (litem.andGroupId != actAG) {
            endg2 = l;
            break;
          }
        }
      }
        
      for (var g2 = 0; g2 < aclItemList.length; g2++) {
        var item2 = aclItemList[g2];
        if ((item2.id == mergeGroup2) && (item2.type == "7")) {
          var acl1 = item1.access;
          var acl2 = item2.access;
          var acl = acl1;
          switch (mergeMode) {
            case 1:
              acl = acl1;
              break;
              
            case 2:
              acl = acl2;
              break;
              
            case 10:
              acl = acl1 | acl2;
              break;
              
            case 20:
              acl = acl2 & acl2;
              break;
          }
          item1.id = destGroup;
          item1.access = acl;
          aclItemList.splice(g2, 1);
          break;
        }
      }
      
      return aclItemList;
    }
  }
  
  return aclItemList;
}

/**
 * @method splitGroup
 * Teilt eine Gruppe in zwei Gruppen auf. Dabei kann eine BitMaske
 * mit den maximalen Rechten bestimmt werden.
 * 
 * @param {Array} aclItemList Liste mit Berechtigungen
 * @param {AclItem} searchGroup Gruppe, nach der aufgeteilt wird
 * @param {AclItem} destGroup1 Erste Zielgruppe
 * @param {Number} maxAccess1 Erste Bitmaske
 * @param {AclItem} destGroup2 Zweite Zielgruppe
 * @param {Number} maxAccess2 Zweite Bitmaske
 * @returns {Array} Liste mit Berechtigungen
 */
ELOAclUtils.prototype.splitGroup = function(aclItemList, searchGroup, destGroup1, maxAccess1, destGroup2, maxAccess2) {
  for (var i = 0; i < aclItemList.length; i++) {
    var item = aclItemList[i];
    if ((item.id == searchGroup) && (item.type == '7')) {
      var oldaccess = item.access;
      var newaccess1 = oldaccess & maxAccess1;
      var newaccess2 = oldaccess & maxAccess2;
      
      var newItem1 = null;
      var newItem2 = null;
      
      if ((oldaccess == 0) || (newaccess1 > 0)) {
        newItem1 = new Object();
        newItem1.id = destGroup1;
        newItem1.access = newaccess1;
        newItem1.type = item.type;
        newItem1.andGroupId = item.andGroupId;
      }
      
      if ((oldaccess == 0) || (newaccess2 > 0)) {
        newItem2 = new Object();
        newItem2.id = destGroup2;
        newItem2.access = newaccess2;
        newItem2.type = item.type;
        newItem2.andGroupId = item.andGroupId;
      }
      
      if ((newItem1 == null) && (newItem2 == null)) {
        aclItemList.splice(i, 1);
        if ((i < aclItemList.length) && (aclItemList[i].access == 0)) {
          // Entfernter Eintrag war Starteintrag einer UND Gruppe, 
          // Berechtigungen auf neuen Starteintrag übertragen.
          aclItemList[i].access = oldaccess;
        }
        i--;
      } else if ((newItem1 != null) && (newItem2 == null)) {
        aclItemList[i] = newItem1;
      } else if ((newItem1 == null) && (newItem2 != null)) {
        aclItemList[i] = newItem2;
      } else {
        aclItemList[i] = newItem1;
        aclItemList.splice(i + 1, 0, newItem2);
      }      
    }
  }
  
  return aclItemList;
}

/**
 * @method sanityze
 * Entfernt redundante Einträge aus der angegebenen Berechtigungsliste.
 * 
 * @param {Array} aclItems Liste mit Berechtigungen
 * @returns {Array} Bereinigte Liste mit Berechtigungen
 */
ELOAclUtils.prototype.sanityze = function(aclItems) {
  for (var i = 0; i < aclItems.length; i++) {
    var item = aclItems[i];
    if (item.andGroupId == 0) {
      for (var j = i + 1; j < aclItems.length; j++) {
        var item2 = aclItems[j];
        if ((item2.andGroupId == 0) && (item2.id == item.id) && (item2.type == item.type)) {
          item.access = item.access | item2.access;
          aclItems.splice(j, 1);
          j--;
        }
      }
    } else {
      var agi = item.andGroupId;
      for (var k = i + 1; k < aclItems.length; k++) {
        var item3 = aclItems[k];
        if (item3.andGroupId != agi) {
          break;
        }
        
        if ((item3.id == item.id) && (item3.type == item.type)) {
          aclItems.splice(k, 1);
          k--;
        }
      }
    }
  }
  
  return aclItems;
}

/**
 * @method toString
 * Liefert eine String-Darstellung der angegebenen Berechtigungen zurück.
 * 
 * @param {Array} aclItems Liste mit Berechtigungen
 * @returns {String} String-Darstellung der Berechtigungen
 */
ELOAclUtils.prototype.toString = function(aclItems) {
  var res = new Array();
  
  for (var i = 0; i < aclItems.length; i++) {
    var item = aclItems[i];
    res.push("Id: " + item.id + ", Ac: " + item.access + ", Ty: " + item.type + ", Gp: " + item.andGroupId);
  }
  
  return res.join(" ## ");
}




//JavaScript Template: addr
// ELO AddRights Library

/**
 * @class addr
 * @singleton
 */
var addr = new Addr();

function Addr() {
  this.templateRoot = "ARCPATH:¶Administration¶UserManager¶";
  this.taskCache = {};
}

/**
 * @method process
 * Setzt die entsprechenden Benutzerrechte.
 * 
 * @param {WFCollectNode} node Workflow-Knoten
 */
Addr.prototype.process = function(node) {
  log.info(node.nodeName);
  if (node.nodeComment == "processUserRights") {
    this.getUserInfo(node);
    this.getMapInfo(node);
    this.processGroups();
    this.setUserInfo();
    log.info("Forward");
    EM_WF_NEXT = "0";
  }
}

/**
 * @method processGroups
 * Setzt die entsprechenden Benutzergruppen.
 */
Addr.prototype.processGroups = function() {
  var addGroups = {};
  var subGroups = {};
  
  for (var i = 0; i < this.items.length; i++) {
    var item = this.items[i];
    var itemId = item.id;
    
    if (item.add) {
      if (this.userTasks.indexOf(itemId) < 0) {
        this.userTasks.push(itemId);
      }
    } else {
      var removePos = this.userTasks.indexOf(itemId);
      if (removePos >= 0) {
        var groups = this.getGroups(itemId);
        this.userTasks.splice(removePos, 1);
        this.insertGroups(subGroups, groups);
      }
    }
  }
  
  for (var i = 0; i < this.userTasks.length; i++) {
    var id = this.userTasks[i];
    var groups = this.getGroups(id);
    this.insertGroups(addGroups, groups);
  }

  this.addGroups = addGroups;
  this.subGroups = subGroups;  
}

/**
 * @method insertGroups
 * Fügt die Gruppen in der angegebenen Liste ein.
 * 
 * @param {Array} dest Liste für die Gruppen
 * @param {Array} groups Liste mit den vorhandenen Gruppen
 */
Addr.prototype.insertGroups = function(dest, groups) {
  for (var i = 0; i < groups.length; i++) {
    var grp = groups[i];
    dest[grp] = grp;
  }
}

/**
 * @method getUserInfo
 * Liest die Benutzerinformation aus dem angegebenen Workflow-Knoten.
 * 
 * @param {WFCollectNode} node Workflow-Knoten
 */
Addr.prototype.getUserInfo = function(node) {
  var objId = node.objId;
  this.userData = ixConnect.ix().checkoutSord(objId, EM_SYS_SELECTOR, LockC.NO);
  var desc = String(this.userData.desc.trim());
  this.userTasks = (desc) ? desc.split(/,/g) : [];
  
  var name = this.userData.name;
  var parts = name.split("\\.");
  this.userInfo = ixConnect.ix().checkoutUsers([parts[1]], CheckoutUsersC.BY_IDS_RAW, LockC.NO)[0];
}

/**
 * @method setUserInfo
 * Setzt die aktuelle Benutzerinformation.
 */
Addr.prototype.setUserInfo = function() {
  var report = "Zugeteilte Aufgaben: <br>";
  for (var i = 0; i < this.items.length; i++) {
    var item = this.items[i];
    var prefix = (item.add) ? "<br>+ " : "<br>- ";
    var name = this.taskCache[item.id].name;
    report = report + prefix + name;
  }
  ix.addFeedComment(this.userData.guid, 0, report);
  
  this.userData.desc = this.userTasks.join(",");
  ixConnect.ix().checkinSord(this.userData, EM_SYS_SELECTOR, LockC.NO);
  
  var oldGroups = this.userInfo.groupList;
  var newGroups = [];
  for (var i = 0; i < oldGroups.length; i++) {
    var grp = oldGroups[i];
    if (!this.subGroups[grp]) {
      newGroups.push(grp);
    }
  }
  
  for each (grp in this.addGroups) {
    newGroups.push(grp);
  }
  
  this.userInfo.groupList = newGroups;
  ixConnect.ix().checkinUsers([this.userInfo], CheckinUsersC.WRITE, LockC.NO);
}

/**
 * @method getGroups
 * Liefert eine Liste mit den vorhandenen Gruppen zurück.
 * 
 * @param {Number} taskId ID der Aufgabe
 * @returns {Array} Liste mit den vorhandenen Gruppen
 */
Addr.prototype.getGroups = function(taskId) {
  var taskInfo = ixConnect.ix().checkoutSord(taskId, EM_SYS_SELECTOR, LockC.NO);
  this.taskCache[taskId] = taskInfo;
  
  var parts = taskInfo.desc.split("###");
  var groups = parts[1].split(",");
  for (var i = 0; i < groups.length; i++) {
    groups[i] = String(groups[i].trim());
  }
  
  return groups;
}

/**
 * @method getMapInfo
 * Liefert eine Liste mit den Map-Einträgen des angegebenen Workflow-Knotens zurück.
 * 
 * @param {WFCollectNode} node Workflow-Knoten
 * @returns {Array} Liste mit den Map-Einträgen
 */
Addr.prototype.getMapInfo = function(node) {
  var entries = ixConnect.ix().checkoutMap(MapDomainC.DOMAIN_WORKFLOW_ACTIVE, node.flowId, null, LockC.NO).items;
  var info = {};
  for (var i = 0; i < entries.length; i++) {
    var entry = entries[i];
    info[entry.key] = entry.value;
  }
  
  var result = [];
  for (var cnt = 1; cnt < 100; cnt++) {
    var addSub = info["URAS" + cnt];
    if (!addSub) {
      break;
    }
    addSub = String(addSub.trim());
    
    var id = info["URID" + cnt];
    if (!id) {
      break;
    }
    id = String(id.trim());
    
    var item = {add: addSub === "ADD", id: id};
    result.push(item);
  }
  
  this.items = result;
}



//JavaScript Template: bt
var Sords = new Array();
var showVersion = true;
var idleStateMessage = "";

// start namespace bt
/**
 * @class bt
 * @singleton
 */
var bt = new Object();


/**
 * Führt die AS-Regel mit den angegebenen Parametern aus.
 * 
 * @param {String} name Regelname
 * @param {Number} num Regelnummer
 * @param {String} userid Benutzer ID
 * @param {String} param1 Erster Parameter
 * @param {String} param2 Zweiter Parameter
 * @param {String} param3 Dritter Parameter
 * @param {String} param4 Vierter Parameter
 * @param {String} param5 Fünfter Parameter
 * @param {String} param6 Sechster Parameter
 * @param {String} param7 Siebter Parameter
 * @param {String} param8 Achter Parameter
 * @param {String} param9 Neunter Parameter
 * @param {String} param10 Zehnter Parameter
 */
function btExecuteRuleset(name, num, userid, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10) {
  return bt.executeRuleset(name, num, userid, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10);
}


bt = {  

  /**
   * Führt die AS-Regel mit den angegebenen Parametern aus.
   * 
   * @param {String} name Name der ELOas Regel
   * @param {Number} num Regelnummer
   * @param {String} userid Benutzer ID
   * @param {String} param1 Erster Parameter
   * @param {String} param2 Zweiter Parameter
   * @param {String} param3 Dritter Parameter
   * @param {String} param4 Vierter Parameter
   * @param {String} param5 Fünfter Parameter
   * @param {String} param6 Sechster Parameter
   * @param {String} param7 Siebter Parameter
   * @param {String} param8 Achter Parameter
   * @param {String} param9 Neunter Parameter
   * @param {String} param10 Zehnter Parameter
   * @returns {String} Ergebnis der Ausführung
   */
  executeRuleset: function (name, num, userid, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10) {
    if (showVersion) {
      log.info("Start processing, Lib Version: " + EM_VERSION_NO);
      showVersion = false;
    }
        
    if (ruleset.getStop && ruleset.getStop()) {
      log.info("executeRuleset interrupted " + ruleset.getStop());
      return;
    }

    EM_USERID = userid;

    if (param1 != "") {
      EM_SEARCHVALUE = param1;
    }

    EM_PARAM1 = param1;
    EM_PARAM2 = param2;
    EM_PARAM3 = param3;
    EM_PARAM4 = param4;
    EM_PARAM5 = param5;
    EM_PARAM6 = param6;
    EM_PARAM7 = param7;
    EM_PARAM8 = param8;
    EM_PARAM9 = param9;
    EM_PARAM10 = param10;
    EM_TREE_STATE = 1;
    EM_SYS_SELECTOR = EM_SYS_STDSEL;

    try {
      log.debug("Execute " + EM_SEARCHNAME);

      onStart();
      if (EM_SEARCHNAME == "TREEWALK") {
        bt.doTreeWalk();
      } else if (EM_SEARCHNAME == "WORKFLOW") {
        bt.doWorkflow();
      } else if (EM_SEARCHNAME == "DIRECT") {
        bt.doDirect();
      } else if (EM_SEARCHNAME.indexOf("MAILBOX") == 0) {
        bt.doMail();
      } else if (EM_SEARCHNAME == "TILE") {
        bt.doTile();
      } else {
        bt.executeSearch();
        elo.processResultSet();
      }
      onEnd();
    } catch (ex) {
      log.info("Error in executeRuleset: " + ex);
    }

    log.info("Stop status: " + (ruleset.getStop && ruleset.getStop()));
    sysExitRuleset();

    if (idleStateMessage != "") {
      return idleStateMessage;
    } else {
      return "Idle...";
    }    
  },

  /**
   * Diese Funktion loggt das Verlassen des Moduls.
   */
  exitRuleset: function () {
    log.debug("Exit Base Templates");
  },

  /**
   * Führt die aktuelle direkte ELOas Regel aus.
   */
  doDirect: function () {
    var sord;
 
    if (EM_SEARCHVALUE != "" && EM_SEARCHVALUE != null && EM_SEARCHVALUE != undefined) {
      var members = (EM_WITH_LOCK) ? SordC.mbLean : EM_SYS_SELECTOR;
      var items = EM_SEARCHVALUE.split(",");
      for (var i = 0; i < items.length; i++) {
        EM_SEARCHVALUE = items[i];
        var sord = ixConnect.ix().checkoutSord(EM_SEARCHVALUE, members, LockC.NO);
        bt.processObject(sord);
      }
    } else {
      sord = new Sord();
      EM_ACT_SORD = sord;
      sys.processRules(sord);
    }
  },

  /**
   * Versendet eine neue E-Mail.
   */
  doMail: function () {
    try {
      var conName = EM_SEARCHNAME.substring(8);
      mail.connectImap(conName);
      while (mail.nextMessage()) {
        if (ruleset.getStop && ruleset.getStop()) {
          log.info("doMail interrupted");
          return;
        }
        
        var editInfo = ixConnect.ix().createDoc(EM_SEARCHVALUE, EM_SEARCHMASK, null, EditInfoC.mbSord);
        var sord = editInfo.getSord();
        sord.name = MAIL_MESSAGE.getSubject();
        bt.processObject(sord);
      }
      mail.closeImap();
    } catch (ex) {
      log.error("Error collecting emails: " + ex);
      return;
    }
  },

  /**
   * Archiviert die Dateien aus einem Verzeichnis über die eingestellte DropZone-Kachel.
   */
  doTile: function () {
    var tileName = EM_SEARCHVALUE;
    log.debug("tileName=" + tileName);
    Packages.de.elo.mover.main.tiles.TileUtils.archiveWithTile(tileName);
  },

  /**
   * Arbeitet die vorhandenen Workflows ab.
   */
  doWorkflow: function () {
    var result, fti, idx = 0;

    try {
      fti = new FindTasksInfo();
      fti.inclWorkflows = true;
      fti.lowestPriority = 2;
      fti.highestPriority = 0;

      fti.sordZ = (typeof EM_WF_SELECTOR !== "undefined") ? EM_WF_SELECTOR : SordC.mbLean;
      fti.inclDeleted = (typeof EM_WF_WITH_DELETED !== "undefined") ? EM_WF_WITH_DELETED : false;
      fti.inclGroup = (typeof EM_WF_WITH_GROUP !== "undefined") ? EM_WF_WITH_GROUP : false;

      result = ixConnect.ix().findFirstTasks(fti, EM_SEARCHCOUNT);
      for (;;) {
        if (ruleset.getStop && ruleset.getStop()) {
          log.info("doWorkflow interrupted");
          return;
        }

        EM_TASKLIST = result.tasks;

        try {
          bt.processTaskList();
        } catch (ex2) {
          log.error("Error processing task list: " + ex2);
        }

        if (!result.moreResults) {
          break;
        }

        idx += EM_TASKLIST.length;
        result = ixConnect.ix().findNextTasks(result.searchId, idx, EM_SEARCHCOUNT);
      }
    } catch (ex) {
      log.error("Error collecting task list: " + ex);
      return;
    } finally {
      if (result) {
        ixConnect.ix().findClose(result.searchId);
      }
    }
  },

  /**
   * Arbeitet die Workflows in der Aufgabenliste ab.
   */
  processTaskList: function () {
    var i, node, sord;

    for (i = 0; i < EM_TASKLIST.length; i++) {
      if (ruleset.getStop && ruleset.getStop()) {
        log.info("processTaskList interrupted");
        return;
      }

      node = EM_TASKLIST[i].wfNode;
      if (node) {
        if (EM_WF_FILTER_NAME && (EM_WF_FILTER_NAME != node.nodeName)) {
          log.debug("Filter - ignore task: " + node.nodeName);
          continue;
        }

        if (EM_WF_USER_DELAY_DATE && (EM_WF_USER_DELAY_DATE < node.userDelayDateIso)) {
          // Optional zurückgestellte Knoten ignorieren
          log.debug("Filter - ignore delayed node: " + node.nodeName);
          continue;
        }

        try {
          sord = EM_TASKLIST[i].sord || ixConnect.ix().checkoutSord(node.objId, EM_WF_SELECTOR, LockC.NO);

          if (sord && (EM_ALLOWALLMASKS || (sord.mask == EM_SEARCHMASK))) {
            EM_WF_NEXT = "";
            EM_WF_NODE = node;
            EM_WF_STATUS = node.flowStatus;
            bt.processObject(sord);
            bt.processNextWf(node);
          }

        } catch (ex) {
          log.warn("Error processing task item: " + ex);
        }
      }
    }

    ruleset.setStatusMessage("Wait.");
  },

  /**
   * Arbeitet den nächsten Workflowknoten ab.
   * 
   * @param {WFCollectNode} node Workflow-Knoten
   */
  processNextWf: function (node) {
    if (EM_WF_NEXT != "") {
      var succList = new Array();

      try {
        var wfNode = ixConnect.ix().beginEditWorkFlowNode(node.getFlowId(), node.getNodeId(), LockC.YES);
        var nodeName = wfNode.getNode().getName();
        var succNodes = wfNode.getSuccNodes();
        var parts = EM_WF_NEXT.split("¶");
        for (var p = 0; p < parts.length; p++) {
          var part = parts[p];
          var succNo = Number(part);
          if (isFinite(succNo) && (succNo >= 0) && (succNo < succNodes.length)) {
            succList.push(succNodes[succNo].getId());
          } else {
            for (var i = 0; i < succNodes.length; i++) {
              if (part == succNodes[i].getName()) {
                succList.push(succNodes[i].getId());
                break;
              }
            }
          }
        }

        var comment = wfNode.node.comment;
        if (comment) {
          if (comment.indexOf("processed by ELOas") == -1) {
            comment = comment + "\n\nprocessed by ELOas";
          }
        } else {
          comment = "processed by ELOas";
        }
        
        ixConnect.ix().endEditWorkFlowNode(node.getFlowId(), node.getNodeId(), false, false, nodeName, comment, succList);

        if (EM_WF_STATUS != node.flowStatus) {
          var workflow = wf.readWorkflow(node.flowId, true);
          var nodes = workflow.nodes;
          for(var n = 0; n < nodes.length; n++) {
            var root = nodes[n];
            if (root.id == 0) {
              root.yesNoCondition = EM_WF_STATUS;
              break;
            }
          }
          wf.writeWorkflow(workflow);
        }
      } catch (ex) {
        log.error("Confirm workflow node exception: " + ex);
        var wfdiag = wf.readWorkflow(node.getFlowId(), false);
        try {
          ixConnect.ix().checkinWorkFlow(wfdiag, WFDiagramC.mbOnlyLock, LockC.YES);
        } catch (ex2) {
          log.error("Cannot unlock workflow: " + ex2);
        }
      }
    }
  },

  /**
   * Arbeitet die Einträge eines Teilbaums ab.
   */
  doTreeWalk: function () {
    try {
      EM_SAVE_TREE_ROOT = false;
      EM_TREE_ABORT_WALK = false;
      EM_TREE_MAX_LEVEL = 32;
      var members = (EM_WITH_LOCK) ? SordC.mbLean : EM_SYS_SELECTOR;
      var sord = ixConnect.ix().checkoutSord(EM_SEARCHVALUE, members, LockC.NO);
      var name = sord.name;
      log.debug("Process tree: " + name);
      EM_ROOT_SORD = sord;
      bt.walkLevel(0, sord);
      if (EM_SAVE_TREE_ROOT) {
        ixConnect.ix().checkinSord(sord, EM_SYS_SELECTOR, LockC.NO);
      }
      log.debug("Exit process tree");
    } catch (ex) {
      log.warn("Cannot process tree " + EM_SEARCHVALUE + " : " + ex);
    }
  },

  /**
   * Läuft den angegebenen Level durch und arbeitet die Einträge ab. 
   * 
   * @param {Number} actLevel Level
   * @param {Sord} parentSord Metadaten des übergeordneten Eintrags
   */
  walkLevel: function (actLevel, parentSord) {
    if ((actLevel > EM_TREE_MAX_LEVEL) || EM_TREE_ABORT_WALK) {
      log.debug("Tree walk aborted: " + actLevel + " : " + EM_TREE_MAX_LEVEL + " : " + EM_TREE_ABORT_WALK);
      return;
    }

    var findInfo = new FindInfo();
    var findChildren = new FindChildren();
    findChildren.setParentId(parentSord.getId());
    findChildren.setMainParent(EM_TW_MAINPARENT);
    findInfo.setFindChildren(findChildren);

    var members = (EM_WITH_LOCK) ? SordC.mbMin : EM_SYS_SELECTOR;
    var findResult = ixConnect.ix().findFirstSords(findInfo, EM_SEARCHCOUNT, members);
    var idx = 0;

    if (ruleset.getStop && ruleset.getStop()) {
      log.info("walkLevel 1 interrupted");
      return;
    }
    
    // Read all entries before processing of the subitems because of the search timeout
    var sords = findResult.sords;
    while (findResult.isMoreResults()) {
      if (ruleset.getStop && ruleset.getStop()) {
        log.info("walkLevel 3 interrupted");
        break;
      }
      
      idx = sords.length;
      findResult = ixConnect.ix().findNextSords(findResult.getSearchId(), idx, EM_SEARCHCOUNT, members);
      sords = ArrayUtils.addAll(sords, findResult.sords);
    }
    
    ixConnect.ix().findClose(findResult.getSearchId());
    log.debug("Process Sord list, length: " + sords.length);

    // Process the item list
    var i;
    for (i = 0; i < sords.length; i++) {
      log.debug("TW Interrupt status: " + (ruleset.getStop && ruleset.getStop()) + ", id: " + Thread.currentThread().id);
      if (EM_TREE_ABORT_WALK) {
        log.debug("Tree walk aborted");
        break;
      }

      if (ruleset.getStop && ruleset.getStop()) {
        log.info("walkLevel 2 interrupted");
        break;
      }
      
      log.debug("Process Sord: " + sords[i].name);

      EM_TREE_STATE = 0;
      EM_TREE_LEVEL = actLevel;
      EM_PARENT_SORD = parentSord;
      EM_TREE_EVAL_CHILDREN = true;
      bt.processObject(sords[i]);

      if (EM_TREE_EVAL_CHILDREN) {
        bt.walkLevel(actLevel + 1, sords[i]);
      } else {
        log.debug("Tree walk, eval children suppressed");
      }

      EM_TREE_STATE = 1;
      EM_TREE_LEVEL = actLevel;
      EM_PARENT_SORD = parentSord;
      bt.processObject(sords[i]);
    }
  },

  /**
   * Führt eine Suche nach Einträgen aus.
   */
  executeSearch: function () {
    log.info("Start Execute Search");
    try {
      if (EM_FIND_RESULT == null) {
        bt.startNewSearch();
      } else {
        bt.continueSearch();
      }
    } catch (ex) {
      log.info("Search aborted: " + ex);
      Sords = [];
      EM_FIND_RESULT = null;
    }
  },

  /**
   * Startet eine neue Suche nach einer Objekt-ID oder nach einem Index.
   */
  startNewSearch: function () {
    if (EM_SEARCHNAME == "OBJIDS") {
      return bt.startNewSearchObjIds(EM_SEARCHVALUE);
    } else if (EM_SEARCHNAME.substring(0, 3) == "RF_") {
      return bt.startRegisteredFunctionSearch(EM_SEARCHNAME, EM_SEARCHVALUE);
    } else {
      return bt.startNewSearchIndex();
    }
  },

 /**
  * Führt eine registrierte Indexserver-Funktion aus.
  * 
  * @param {String} rfFunctionName Funktionsbezeichnung
  * @param {String} rfFunctionParam Funktionsparameter
  */
  startRegisteredFunctionSearch: function(rfFunctionName, rfFunctionParam) {
    var result = ixConnect.ix().executeRegisteredFunctionString(rfFunctionName, rfFunctionParam);
    return bt.startNewSearchObjIds(result);
  },
  
  /**
   * Startet eine neue Suche nach Objekt-IDs.
   */
  startNewSearchObjIds: function (searchvalue) {
    ruleset.setStatusMessage("Loading objids...");
    var findInfo = new FindInfo();
    var findByIndex = new FindByIndex();

    var objKey = new ObjKey();
    var keyData = new Array(1);
    keyData[0] = "";
    objKey.setName("*");
    objKey.setData(keyData);

    var objKeys = new Array(1);
    objKeys[0] = objKey;

    findByIndex.setObjKeys(objKeys);
    findInfo.setFindByIndex(findByIndex);

    var findOptions = new Packages.de.elo.ix.client.FindOptions();
    var ids = searchvalue.split(",");
    findOptions.setObjIds(ids);
    findInfo.setFindOptions(findOptions);

    var members = (EM_WITH_LOCK) ? SordC.mbMin : EM_SYS_SELECTOR;
    EM_FIND_RESULT = ixConnect.ix().findFirstSords(findInfo, EM_SEARCHCOUNT, members);
    EM_START_INDEX = 0;
    bt.getSearchResult();
  },

  /**
   * Startet eine neue Suche nach einem Index.
   */
  startNewSearchIndex: function () {
    ruleset.setStatusMessage("Searching...");
    var findInfo;
    
    if (EM_FIND_INFO) {
      findInfo = EM_FIND_INFO;	
    } else { 
      findInfo = new FindInfo();
      var findByIndex = new FindByIndex();

      if (EM_SEARCHNAME == "ELOTIMESTAMP") {
        findByIndex.name = "*";
        var findOptions = new Packages.de.elo.ix.client.FindOptions();
        findOptions.TStamp = EM_SEARCHVALUE;
        findInfo.findOptions = findOptions;
      } else {
        var values = EM_SEARCHVALUE.split("¶");
        var names = EM_SEARCHNAME.split("¶");
        var cnt = (values.length < names.length) ? values.length : names.length;
        
        var objKeys = new Array();
        for (var k = 0; k < cnt; k++) {
          var objKey = new ObjKey();
          objKey.name = names[k];
          objKey.data = [values[k]];
          objKeys.push(objKey);
        }

        findByIndex.setObjKeys(objKeys);
      }

      findByIndex.setMaskId(EM_SEARCHMASK);

      if ((EM_XDATEFROM != "") || (EM_XDATETO != "")) {
        var xdate = elo.decodeDate(EM_XDATEFROM) + "..." + elo.decodeDate(EM_XDATETO);
        findByIndex.setXDateIso(xdate);
        log.debug("Find by XDate: " + xdate);
      }

      if ((EM_IDATEFROM != "") || (EM_IDATETO != "")) {
        var idate = elo.decodeDate(EM_IDATEFROM) + "..." + elo.decodeDate(EM_IDATETO);
        findByIndex.setIDateIso(idate);
        log.debug("Find by IDate: " + idate);
      }

      findInfo.setFindByIndex(findByIndex);
    }
    
    var members = (EM_WITH_LOCK) ? SordC.mbMin : EM_SYS_SELECTOR;
    EM_FIND_RESULT = ixConnect.ix().findFirstSords(findInfo, EM_SEARCHCOUNT, members);
    EM_START_INDEX = 0;
    bt.getSearchResult();
  },

  /**
   * Arbeitet den weiteren Teil der Suchergebnisse ab.
   */
  continueSearch: function () {
    var members = (EM_WITH_LOCK) ? SordC.mbMin : EM_SYS_SELECTOR;
    EM_FIND_RESULT = ixConnect.ix().findNextSords(EM_FIND_RESULT.getSearchId(), EM_START_INDEX, EM_SEARCHCOUNT, members);
    bt.getSearchResult();
  },

  /**
   * Liefert das aktuelle Suchergebnis zurück.
   */
  getSearchResult: function () {
    Sords = EM_FIND_RESULT.getSords();
    ruleset.setMoreResults(EM_FIND_RESULT.isMoreResults());
    log.debug("More results available: " + EM_FIND_RESULT.isMoreResults());

    if (EM_FIND_RESULT.isMoreResults()) {
      EM_START_INDEX += Sords.length;
    } else {
      ixConnect.ix().findClose(EM_FIND_RESULT.getSearchId());
      EM_FIND_RESULT = null;
      EM_START_INDEX = 0;
    }

    log.info("Execute Search done, " + Sords.length + " entries found.");
    ruleset.setStatusMessage(Sords.length + " entries found");
  },

  /**
   * Arbeitet den angegebenen Repository-Eintrag ab.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   */
  processObject: function(Sord) {
    if (ruleset.getStop && ruleset.getStop()) {
      log.info("processObject interrupted");
      return;
    }
    
    if (EM_WITH_LOCK) {
      if (Sord.lockId < 99990) {
        var lockedSord;

        try {          
          lockedSord = ixConnect.ix().checkoutSord(Sord.id, EM_SYS_SELECTOR, LockC.YES);
          bt.processObjectLocal(lockedSord);
        } catch(e) {
          log.info("Lock conflict, item ignored: " + Sord.id + " : " + Sord.name + " : Reason: " + e);
        } finally {
          if (lockedSord) {
            ixConnect.ix().checkinSord(lockedSord, SordC.mbOnlyUnlock, LockC.YES);
          }
        }
      } else {
        log.debug("Locked item ignored: " + Sord.id + " : " + Sord.name);
      }
    } else {
      bt.processObjectLocal(Sord);
    }
  },

  /**
   * Arbeitet den angegebenen Repository-Eintrag ab.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   */
  processObjectLocal: function(Sord) {
    EM_ACT_SORD = Sord;
    elo.loadBaseData(Sord);
    log.info("Sord: " + NAME + "   State: " + EM_TREE_STATE);
    ruleset.setStatusMessage("Process: " + NAME);

    try {
      EM_MASK_LOADED = -1;
      sys.loadIndexLines(Sord);
      EM_INDEX_LOADED = EM_MASK_LOADED >= 0;
    } catch (ex) {
      EM_INDEX_LOADED = false;
    }

    if (EM_TREE_STATE == 1) {
      EM_NEW_DESTINATION = new Array();
    } else {
      EM_NEW_DESTINATION = undefined;
    }

    EM_WRITE_CHANGED = false;
    sys.processRules(Sord);
    log.debug("EM_WRITE_CHANGED: " + EM_WRITE_CHANGED);

    try {
      elo.storeBaseData(Sord);
      if (EM_INDEX_LOADED) {
        sys.storeIndexLines(Sord);
      }

      if (EM_TREE_STATE == 1) {
        bt.moveFinally(Sord);

        if (EM_WRITE_CHANGED) {
          ixConnect.ix().checkinSord(Sord, EM_SYS_SELECTOR, LockC.NO);
        }
      }
    } catch (e) {
      EM_ERROR = e;
      log.info("Error on store or move: " + EM_ERROR);
      try {
        sys.finalErrorRule(Sord);
        elo.storeBaseData(Sord);
        sys.storeIndexLines(Sord);
        if (EM_TREE_STATE == 1) {
          bt.moveFinally(Sord);
          ixConnect.ix().checkinSord(Sord, EM_SYS_SELECTOR, LockC.NO);
        }
      } catch (e) {
        log.error("Error in Error Rule: " + e);
      }
    }
  },

  /**
   * Verschiebt den aktuellen Repository-Eintrag an der angegebenen 
   * Repository-Position.
   * 
   * @param {Sord} SordNotUsed Unbenutzter Parameter
   * @param {String} destination Neue Repository-Position
   */
  moveTo: function (SordNotUsed, destination) {
    if (destination != "*") {
      log.debug("MoveTo " + destination);
      destination = EM_FOLDERMASK + "¶¶¶." + destination;
    } else {
      log.debug("MoveTo: Keep actual position.");
    }

    EM_NEW_DESTINATION.push(destination);
  },

  /**
   * Verschiebt den angegebenen Repository-Eintrag endgültig im ersten vorhandenen 
   * Zielpfad.
   * 
   * @param {Sord} Sord Metadaten des Repository-Eintrags
   */
  moveFinally: function (Sord) {
    if (EM_NEW_DESTINATION.length > 0) {
      var destPath = EM_NEW_DESTINATION[0];
      if (destPath != "*") {
        var destId = elo.preparePath(destPath);
        log.debug("Dest: " + destId + "   Source: " + Sord.getParentId());

        if ((destId > 0) && (destId != Sord.getParentId())) {
          ixConnect.ix().copySord(destId, Sord.getGuid(), null, CopySordC.MOVE);
          Sord.setParentId(destId);
        }
      }

      var i;
      for (i = 1; i < EM_NEW_DESTINATION.length; i++) {
        var destId = elo.preparePath(EM_NEW_DESTINATION[i]);
        log.debug("Add. Ref: Dest: " + destId + "   Source: " + Sord.getParentId());

        if ((destId > 0) && (destId != Sord.getParentId())) {
          ixConnect.ix().copySord(destId, Sord.getGuid(), null, CopySordC.REFERENCE);
        }
      }
    }
  }

  // end of namespace bt
};



//JavaScript Template: cal
// start namespace cal
var EM_CALENDAR_BASE = "ARCPATH:¶Sitzungen¶Kalender¶";

// Unterhalb der Kalender-Basis können beliebige Ordner mit Kalendereinträge stehen.
// Der Ordnernamen enthält dabei den Kalendernamen und der Zusatztext die Liste mit
// den freien Tagen. Feiertage, die auf ein Wochenende fallen, dürfen nicht eingetragen
// werden, andernfalls werden sie doppelt abgezogen.
// Der Zusatztext enthält pro Zeile einen Feiertag in der Form:
// <Datum (ISO)>:<Faktor>:<Name>
//
// Das Datum wird in der Form YYYYMMDD eingetragen um Probleme mit unterschiedlichen
// Datumszonen zu vermeiden. Der Faktor kann einen Wert zwischen 0 und 1 einnehmen
// (z.B. für einen halben Tag am 24.12 - 0.5). Der Name dient nur zur besseren
// Übersicht, er wird nicht weiter ausgewertet.

/**
 * @class cal
 * @singleton
 */
var cal = new Object();
cal = {

/**
 * Liefert die Anzahl der Arbeitstage zwischen zwei Datumsangaben unter Berücksichtigung 
 * des Kalenders und der Wochenende (Sa und So) zurück.
 * 
 * @param {String} calendarName Kalendername
 * @param {String} fromDate "Von"-Datum
 * @param {String} toDate "Bis"-Datum
 * @returns {Number} Anzahl der Arbeitstage
 */
getWorkDays: function(calendarName, fromDate, toDate) {
  var dates = cal.getCalendar(calendarName);
  log.debug("Public holidays count: " + dates.length);
  var fd = cal.getDateFromIso(fromDate);
  var td = cal.getDateFromIso(toDate);
  var workDays = cal.getNumberOfWorkDays(fd, td);
  log.debug("Weekdays count: " + workDays);

  for (var i = 0; i < dates.length; i++) {
    if ((dates[i] >= fd) && (dates[i] <= td)) {
      workDays -= dates[i].factor;
      log.debug("Remove date: " + dates[i] + " : " + dates[i].dayname);
    }
  }

  log.debug("Workingdays count: " + workDays);
  return workDays;
},

/**
 * Liefert eine Liste mit den Datumsangaben zu einem Kalender zurück.
 * 
 * @param {String} calendarName Kalendername
 * @returns {Array} Liste mit Datumsangaben
 */
getCalendar: function(calendarName) {
  if (!calendarName) {
    calendarName = "Feiertage";
  }
  
  var calSord = ixConnect.ix().checkoutSord(EM_CALENDAR_BASE + calendarName, EM_SYS_SELECTOR, LockC.NO);
  if (calSord) {
    var desc = calSord.desc;
    var lines = desc.split("\\n");
    var dates = new Array();
    for (var i = 0; i < lines.length; i++) {
      var items = lines[i].split(":");
      var iso = items[0];
      var factor = items[1];
      var name = items[2];
      var nextDate = cal.getDateFromIso(iso);
      var wday = nextDate.getDay();
      log.debug(wday + " : " + nextDate);
      if ((wday > 0) && (wday < 6)) {
        // Keine Wochenend-Feiertage aufnehmen
        nextDate.factor = factor;
        nextDate.dayname = name;
        dates.push(nextDate);
      }
    }

    return dates;
  } else {
    return null;
  }
},

/**
 * Liefert ein Java-Datum aus dem angegebenen Datumsstring zurück (YYYYMMDD oder YYYY-MM-DD).
 * 
 * @param {String} isoDateString ISO-Datum
 * @returns {Date} Java-Datum
 */
getDateFromIso: function(isoDateString) {
  if (isoDateString.charAt(4) == 45) {
    return new Date(isoDateString.substring(0,4), Number(isoDateString.substring(5,7)) - 1, isoDateString.substring(8,10));
  } else {
    return new Date(isoDateString.substring(0,4), Number(isoDateString.substring(4,6)) - 1, isoDateString.substring(6,8));
  }
},

/**
 * Liefert die Anzahl der Wochentage zwischen zwei Terminen zurück.
 * 
 * @param {String} fromDate Start-Datum
 * @param {String} toDate Ende-Datum
 * @returns {Number} Anzahl der Wochentage
 */
getNumberOfWorkDays: function(fromDate, toDate) {
  var days1 = Math.floor(fromDate.getTime() / 86400000);
  var wday1 = fromDate.getDay();
  var days2 = Math.floor(toDate.getTime() / 86400000);
  var wday2 = toDate.getDay();

  if (days1 > days2) {
    var temp = days2;
    days2 = days1;
    days1 = temp;
    temp = wday2;
    wday2 = wday1;
    wday1 = temp;
  }

  var startOffset = (wday1 == 0) ? 1 : 0;
  var endOffset = (wday2 == 6) ? 1 : 0;
  var weekendDiff = 2 * Math.floor((days2 - days1 + wday1 - wday2) / 7);
  var diff = days2 - days1 + 1 - startOffset - endOffset - weekendDiff;

  return diff;
}

} // end of namespace cal




//JavaScript Template: cnt
// start of namespace cnt

/**
 * @class cnt
 * @singleton
 */
var cnt = new Object();
cnt = {

  /**
   * Liefert den Wert des angegebenen Counter-Objekts zurück.
   * 
   * @param {String} counterName Counter-Name
   * @param {Boolean} autoIncrement Counter automatisch erhöhen
   * @returns {String} Counter-Wert
   */
  getCounterValue: function (counterName, autoIncrement) {
    var counterNames = new Array(1);
    counterNames[0] = counterName;
    var counterInfo = ixConnect.ix().checkoutCounters(counterNames, autoIncrement, LockC.NO);
    return counterInfo[0].getValue();
  },

  /**
   * Erzeugt ein Counter mit dem angegebenen initialen Wert.
   * 
   * @param {String} counterName Counter-Name
   * @param {String} initialValue Initialer Wert
   */
  createCounter: function (counterName, initialValue) {
    var counterInfo = new CounterInfo();
    counterInfo.setName(counterName);
    counterInfo.setValue(initialValue);

    var info = new Array(1);
    info[0] = counterInfo;

    ixConnect.ix().checkinCounters(info, LockC.NO);
  },

  /**
   * Liefert eine neue Track-ID aus den angegebene Daten zurück.
   * 
   * @param {String} counterName Counter-Name
   * @param {String} prefix Präfix
   * @returns {String} Track-ID
   */
  getTrackId: function (counterName, prefix) {
    var tid = cnt.getCounterValue(counterName, true);
    return cnt.calcTrackId(tid, prefix);
  },

  /**
   * Liefert eine neue Track-ID aus den angegebenen Daten zurück.
   * 
   * @param {String} trackId Track-ID
   * @param {String} prefix Präfix
   * @returns {String} Track-ID
   */
  calcTrackId: function (trackId, prefix) {
    var chk = 0;
    var tmp = trackId;

    while (tmp > 0) {
      chk = chk + (tmp % 10);
      tmp = Math.floor(tmp / 10);
    }

    return prefix + "" + trackId + "C" + (chk % 10);
  },

  /**
   * Überprüft den angegebenen Wert.
   * 
   * @param {Number} value Wert
   * @param {Number} checksum Checksumme
   * @returns {Boolean} Der Wert is gültig
   */
  checkId: function (value, checksum) {
    var chk = 0;

    while (value > 0) {
      chk = chk + (value % 10);
      value = Math.floor(value / 10);
    }

    return (chk % 10) == checksum;
  },

  /**
   * Liefert die Track-ID aus den angegebenen Daten zurück.
   * 
   * @param {String} text Text
   * @param {String} prefix Präfix
   * @param {Number} length Länge
   * @returns {Number} Track-ID oder -1
   */
  findTrackId: function (text, prefix, length) {
    text = " " + text + " ";

    var pattern = "\\s" + prefix + "\\d+C\\d\\s";
    if (length > 0) {
      pattern = "\\s" + prefix + "\\d{" + length + "}C\\d\\s";
    }

    var val = text.match(new RegExp(pattern, "g"));
    if (!val) {
      return -1;
    }

    for (var i = 0; i < val.length; i++) {
      var found = val[i];
      var number = found.substr(prefix.length + 1, found.length - prefix.length - 4);
      var checksum = found.substr(found.length - 2, 1);
      if (this.checkId(number, checksum)) {
        return number;
      }
    }

    return -1;
  }

}
// end of namespace cnt



//JavaScript Template: db
// start of namespace db

/**
 * @class db
 * @singleton
 */
var db = new Object();
db = {

  /**
   * Initialisiert die angegebene Datenbank-Verbindung.
   * 
   * @param {Number} connectId ID/Nummer der Datenbank-Verbindung
   */
  init: function (connectId) {
    if (EM_connections[connectId].initdone == true) {
      return;
    }

    log.debug("Now init JDBC driver");
    var driverName = EM_connections[connectId].driver;
    var dbUrl = EM_connections[connectId].url;
    var dbUser = EM_connections[connectId].user;
    var dbPassword = EM_connections[connectId].password;
    if (emConnect.decryptAs) {
      dbPassword = emConnect.decryptAs(dbPassword);
    }
    
    try {
      if (!EM_connections[connectId].classloaded) {
        Class.forName(driverName).newInstance();

        log.debug("Register driver JDBC");        
        EM_connections[connectId].classloaded = true;
      }

      log.debug("Get Connection");
      EM_connections[connectId].dbcn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

      log.debug("Init done.");
    } catch (e) {
      log.warn("JDBC Exception: " + e);
    }

    EM_connections[connectId].initdone = true;
  },

  /**
   * Schließt die verwendeten Datenbank-Verbindungen.
   */
  exitRuleset: function () {
    log.debug("dbExit");

    for (i = 0; i < EM_connections.length; i++) {
      if (EM_connections[i].initdone) {
        if (EM_connections[i].dbcn) {
          try {
            EM_connections[i].dbcn.close();
            EM_connections[i].initdone = false;
            log.debug("Connection closed: " + i);
          } catch (e) {
            log.warn("Error closing database " + i + ": " + e);
          }
        }
      }
    }
  },

  /**
   * Führt die angegebene Datenbankabfrage aus und liefert die 
   * Anzahl der geänderten Tabellenzeilen zurück.
   * 
   * @param {Number} connection Nummer der Datenbank-Verbindung
   * @param {String} sqlCommand SQL-Befehl
   * @returns {Number} Anzahl der geänderten Tabellen-Zeilen
   */
  doUpdate: function (connection, sqlCommand) {
    db.init(connection);

    log.debug("createStatement for update: " + sqlCommand);
    var p = EM_connections[connection].dbcn.createStatement();

    log.debug("executeUpdate");
    var changedRowsCount = p.executeUpdate(sqlCommand);
    log.debug("changedRowsCount=" + changedRowsCount);

    p.close();
    return changedRowsCount;
  },

  /**
   * Führt die angegebene "PreparedStatement"-Datenbankabfrage aus 
   * und liefert die Anzahl der geänderten Tabellenzeilen zurück.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} sqlCommand SQL-Befehl
   * @param {String[]} params Liste mit Parametern
   * @returns {Number} Anzahl der geänderten Tabellenzeilen
   */
  doUpdate2: function (connection, sqlCommand, params) {
    db.init(connection);

    log.debug("createPreparedStatement for update: " + sqlCommand);
    try {
      // PreparedStatement mit den angegebenen Parametern erzeugen
      var p = EM_connections[connection].dbcn.prepareStatement(sqlCommand);
      for (var count=0; count < params.length; count++) {
        p.setObject(count+1, params[count]);
      }

      // Datenbankbefehl ausführen
      log.debug("executeUpdate");
      var changedRowsCount = p.executeUpdate();
      log.debug("changedRowsCount=" + changedRowsCount);
      return changedRowsCount;

    } finally {
        // Datenbank-Objekt freigeben
        if (p) {
          p.close();
        }
    }
  },

  /**
   * Führt die angegebene Datenbankabfrage aus und liefert das Ergebnis 
   * der Abfrage zurück.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} qry Datenbankabfrage
   * @returns {Object} Ergebnis der Datenbankabfrage
   */
  getLine: function (connection, qry) {
    function dbResult(qry) {
      db.init(connection);

      log.debug("createStatement");
      var p = EM_connections[connection].dbcn.createStatement();

      log.debug("executeQuery");
      var rss = p.executeQuery(qry);

      log.debug("read result");
      if (rss.next()) {
        var metaData = rss.getMetaData();
        var cnt = metaData.getColumnCount();
        for (var i = 1; i <= cnt; i++) {
          var name = String(metaData.getColumnLabel(i));
          var value = String(rss.getString(i) || "");

          this[name] = value;
          if (i == 1) {
            this.first = value;
          }
        }
      }

      rss.close();
      p.close();
    }

    var res = new dbResult(qry);

    log.debug("getLine done.");
    return res;
  },

  /**
   * Führt die angegebene "PreparedStatement"-Datenbankabfrage aus und liefert
   * das Ergebnis der Abfrage zurück.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} qry Datenbankabfrage mit Platzhaltern
   * @param {String[]} params Liste mit Parametern für die Datenbankabfrage
   * @returns {Object} Ergebnis der Datenbankabfrage
   */
  getLine2: function (connection, qry, params) {
    function dbResult(qry) {
      db.init(connection);

      log.debug("createPreparedStatement");
      try {
        // PreparedStatement mit den angegebenen Parametern erzeugen
        var p = EM_connections[connection].dbcn.prepareStatement(qry);
        for (var count=0; count < params.length; count++) {
          p.setObject(count+1, params[count]);
        }

        // Datenbankabfrage ausführen
        log.debug("executeQuery");        
        var rss = p.executeQuery();

        // Datenbankergebnis ermitteln
        log.debug("read result");
        if (rss.next()) {
          var metaData = rss.getMetaData();
          var cnt = metaData.getColumnCount();
          for (var i = 1; i <= cnt; i++) {
            var name = String(metaData.getColumnLabel(i));
            var value = String(rss.getString(i) || "");

            this[name] = value;
            if (i == 1) {
              this.first = value;
            }
          }
        }

        } finally {
            // Datenbank-Objekte freigeben
            if (rss) {
              rss.close();
            }
          
            if (p) {
              p.close();
            }
       }
    }

    var res = new dbResult(qry);

    log.debug("getLine2 done.");
    return res;
  },

  /**
   * Führt die angegebene Datenbank-Abfrage aus und liefert den ersten 
   * Wert des Abfrageergebnisses zurück.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} qry Datenbankabfrage
   * @returns {Object} Erster Wert des Abfrageergebnisses
   */
  getColumn: function (connection, qry) {
    var res = db.getLine(connection, qry);
    return res.first;
  },

  /**
   * Führt die angegebene "PreparedStatement"-Datenbankabfrage aus und liefert den
   * ersten Wert des Abfrageergebnisses zurück.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} qry Datenbankabfrage mit Platzhaltern
   * @param {String[]} params Liste mit Parametern
   * @returns {Object} Erster Wert des Abfrageergebnisses
   */
  getColumn2: function (connection, qry, params) {
    // Erster Wert der "PreparedStatement"-Abfrage ermitteln
    var res = db.getLine2(connection, qry, params);
    return res.first;
  },

  /**
   * Führt die angegebene Datenbankabfrage aus und liefert den ersten Wert des
   * Abfrageergebnisses zurück. Falls kein Wert vorhanden ist, wird der Default-Wert 
   * zurückgegeben.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} qry Datenbankabfrage
   * @param {String} defaultValue Default-Wert
   * @returns {Object} Erster Wert des Abfrageergebnisses
   */
  getColumnWithDefault: function (connection, qry, defaultValue) {
    var res = db.getLine(connection, qry);
    return (res.first) ? res.first : defaultValue;
  },

 /**
  * Führt die angegebene "PreparedStatement"-Datenbankabfrage aus und liefert den
  * ersten Wert des Abfrageergebnisses zurück. Falls kein Wert vorhanden ist wird 
  * der Default-Wert zurückgegeben.
  * 
  * @param {Number} connection Nummer der Datenbankverbindung
  * @param {String} qry Datenbankabfrage mit Platzhaltern
  * @param {String} defaultValue Default-Wert
  * @param {String[]} params Liste mit Parametern für die Datenbankabfrage
  * @returns {Object} Erster Wert des Abfrageergebnisses
  */
  getColumnWithDefault2: function (connection, qry, defaultValue, params) {
    // Erster Wert der "PreparedStatement"-Abfrage ermitteln
    var res = db.getLine2(connection, qry, params);
    return (res.first) ? res.first : defaultValue;
  },

  /**
   * Führt die angegebene Datenbankabfrage aus und liefert die angegebene 
   * Anzahl an Zeilen des Abfrageergebnisses zurück.
   * 
   * @param {Number} connection Nummer der Datenbankverbindung
   * @param {String} qry Datenbankabfrage
   * @param {Number} maxRows Maximale Anzahl an Zeile
   * @returns {Object} Ergebnis der Datenbankabfrage
   */
  getMultiLine: function (connection, qry, maxRows) {
    function makeRow(metaData, rss) {
      var cnt = metaData.getColumnCount();
      for (var col = 1; col <= cnt; col++) {
        var name = String(metaData.getColumnLabel(col));
        var value = String(rss.getString(col) || "");
        this[name] = value;
      }
    }

    db.init(connection);

    log.debug("createStatement");
    var p = EM_connections[connection].dbcn.createStatement();

    log.debug("executeQuery");
    var rss = p.executeQuery(qry);

    log.debug("read result");
    var result = new Array();
    if (rss.next()) {
      var metaData = rss.getMetaData();
      for (var i = 0; i < maxRows; i++) {
        result[i] = new makeRow(metaData, rss);
        if (!rss.next()) {
          break;
        }
      }
    }

    rss.close();
    p.close();

    return result;
  },

  /**
   * Führt die angegebene "PreparedStatement"-Datenbankabfrage aus und liefert
   * die angegebene Anzahl an Zeilen des Abfrageergebnisses zurück.
   * 
   * @param {Number} connection Nummer der Datenbankanbindung
   * @param {String} qry Datenbankabfrage
   * @param {Number} maxRows Maximale Anzahl an Zeilen
   * @param {String[]} params Liste mit Parametern für die Datenbankabfrage
   * @returns {Object} Ergebnis der Datenbankabfrage
   */
  getMultiLine2: function (connection, qry, maxRows, params) {
    function makeRow(metaData, rss) {
      var cnt = metaData.getColumnCount();
      for (var col = 1; col <= cnt; col++) {
        var name = String(metaData.getColumnLabel(col));
        var value = String(rss.getString(col) || "");
        this[name] = value;
      }
    }

    db.init(connection);

    log.debug("createPreparedStatement");
    try {
      // PreparedStatement mit den angegebenen Parametern erzeugen
      var p = EM_connections[connection].dbcn.prepareStatement(qry);
      for (var count=0; count < params.length; count++) {
        p.setObject(count+1, params[count]);
      }

      // Datenbankabfrage ausführen
      log.debug("executeQuery");
      var rss = p.executeQuery();

      // Datenbankergebnis ermitteln
      log.debug("read result");
      var result = new Array();
      if (rss.next()) {
        var metaData = rss.getMetaData();
        for (var i = 0; i < maxRows; i++) {
          result[i] = new makeRow(metaData, rss);
          if (!rss.next()) {
            break;
          }
        }
      }

    } finally {
        // Datenbank-Objekte freigeben
        if (rss) {
          rss.close();
        }
    
        if (p) {
          p.close();
        }
    }

    return result;
  }

}
// end of namespace db

function dbExitRuleset() {
  return db.exitRuleset();
}



//JavaScript Template: dex
var dexRoot = "c:\\temp\\";

// start of namespace dex

/**
 * @class dex
 * @singleton
 */
var dex = new Object();
dex = {

  /**
   * Liefert die ID des "Document"-Objektes des angegebenen Repository-Eintrags.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   * @returns {String} ID des "Document"-Objektes
   */
  processDoc: function (Sord) {
    log.debug("Status: " + PDSTATUS + ", Name: " + NAME);

    if (PDSTATUS == "Aktiv: zur Löschung vorgesehen") {
      return dex.deleteDoc(Sord);
    } else if (PDSTATUS == "Aktiv: Freigegeben") {
      return dex.exportDoc(Sord);
    }

    return "";
  },

  /**
   * Löscht den angegebenen Repository-Eintrag.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   * @returns {Number} ID des "Document"-Objektes
   */
  deleteDoc: function (Sord) {
    dex.deleteFile(PDPATH1);
    dex.deleteFile(PDPATH2);
    dex.deleteFile(PDPATH3);
    dex.deleteFile(PDPATH4);
    dex.deleteFile(PDPATH5);

    PDSTATUS = "Nicht mehr aktiv / Gelöscht";
    return Sord.getDoc();
  },

  /**
   * Löscht die angegebene Datei.
   * 
   * @param {String} destPath Dateipfad
   */
  deleteFile: function (destPath) {
    if (destPath == "") {
      return;
    }

    var file = new File(dexRoot + destPath);
    if (file.exists()) {
      log.debug("Delete expired version: " + dexRoot + destPath);
      file["delete"]();
    }
  },

  /**
   * Liefert die ID des "Document"-Objektes aus den angegebenen Metadaten zurück.
   * 
   * @param {Sord} Sord Metadaten vom Repository-Dokument
   * @returns {Number} ID des "Document"-Objektes
   */
  exportDoc: function (Sord) {
    var editInfo = ixConnect.ix().checkoutDoc(Sord.getId(), null, EditInfoC.mbSordDoc, LockC.NO);
    var url = editInfo.document.docs[0].getUrl();
    dex.copyFile(url, PDPATH1);
    dex.copyFile(url, PDPATH2);
    dex.copyFile(url, PDPATH3);
    dex.copyFile(url, PDPATH4);
    dex.copyFile(url, PDPATH5);

    return Sord.getDoc();
  },

  /**
   * Kopiert das Repository-Dokument im angegebenen Pfad.
   * 
   * @param {String} url URL des Repository-Dokuments
   * @param {String} destPath Pfad der Zieldatei
   */
  copyFile: function (url, destPath) {
    if (destPath == "") {
      return;
    }

    log.debug("Path: " + dexRoot + destPath);
    var file = new File(dexRoot + destPath);
    if (file.exists()) {
      log.debug("Delete old version.");
      file["delete"]();
    }

    ixConnect.download(url, file);
  },

  /**
   * Liefert den Inhalt der angegebenen Datei als ein String zurück.
   * 
   * @param {String} sourcePath Dateipfad
   * @returns {String} Dateiinhalt
   */
  asString: function (sourcePath) {
    var file = new File(dexRoot + sourcePath);
    var text = FileUtils.readFileToString(file, "UTF-8");
    return text;
  },

  /**
   * Erstellt eine Datei mit dem angegebenen Inhalt.
   * 
   * @param {String} destPath Dateipfad
   * @param {String} data Dateiinhalt
   * @param {String} encoding Dateikodierung
   */
  asFile: function(destPath, data, encoding) {
    var file = new File(dexRoot + destPath);
    FileUtils.write(file, data, encoding);
  }
  
}
// end of namespace dex



//JavaScript Template: docx
// start namespace docx

/**
 * @class docx
 * @singleton
 */
var docx = new Object();

const docx_statusIndexLine = 5;
const docx_exportStatusMsg = "EXPORTED";
const docx_importStatusMsg = "IMPORTED";
const docx_asExportDir = "Analyze";
const docx_asImportDir = "Import";
const docx_asErrorDir = "Error";
const docx_asDoneDir = "Done";

const docx_xmlTemplate = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n' +
  '<!DOCTYPE STACK SYSTEM "System\Config\DTD\sfx_import.dtd">\n' +
  '<STACK Category="Invoice" LocationType="File" Priority="5" StackID="MyCompany %TimeStamp%" SubSystem="Invoice">\n' +
  '<ATTRIBUTES>\n' +
  '  <KeyValuePair Key="$Dpi" Value="300"/>\n' +
  '  <KeyValuePair Key="$ScanDate" Value="%Scandatum%"/>\n' +
  '  <KeyValuePair Key="$ArchivId" Value="%Guid%"/>\n' +
  '  <KeyValuePair Key="$ArchivDocId" Value="%Id%"/>\n' +
  '</ATTRIBUTES>\n' +
  '%Images%\n' +
  '</STACK>\n';

const docx_imageTemplate = '<IMAGE DocID="0000" ImageID="%ImageId%" Skipped="%Skipped%" LocationID="%Guid%-%ImageId%.%Ext%"/>\n';
//<IMAGE DocID="0000" ImageID="001" Skipped="TRUE" LocationID="(AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE)-001.tif"/>
//<IMAGE DocID="0000" ImageID="002" Skipped="TRUE" LocationID="(AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE)-002.tif"/>

docx = {
  mapData: undefined,
  
  // TODO: Hier werden die zu übernehmenden Felder aufgelistet
  /**
   * Arbeitet die angegebenen Daten ab.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @param {Object} data Daten
   */
  processSord: function(sord, data) {
    var objKeys = sord.objKeys;
    var fg = data.PROCESS.DOCUMENT.FIELDGROUP;
    sord.XDateIso = this.getFieldValue(fg, 'VE_NAV_LAST_CHANGE', 'D');
    
    // Indexzeilen
    this.assignField(fg, 'INV_NUMBER', objKeys, 0, "S");
    this.assignField(fg, 'INV_AMOUNT', objKeys, 1, "S");
    this.assignField(fg, 'VE_NAME', objKeys, 2, "S");
    this.assignField(fg, 'INV_DATE', objKeys, 3, "D");
    this.assignField(fg, 'INV_CASH_DISCOUNT_DATE', objKeys, 4, "D");
    
    // MAP Felder
    this.assignMap(fg, 'INV_TAX_RATE', 'TAX_RATE', 'N');
    this.assignMap(fg, 'INV_TAX_AMOUNT', 'TAX_AMOUNT', 'N');
    this.assignMap(fg, 'INV_TAX_CODE', 'TAX_CODE', 'S');
  },
  
  /**
   * Meldet zurück, ob es sich beim angegebenen Eintrag um eine Rechnung handelt.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @returns {Boolean} Eintrag ist eine Rechnung
   */
  checkForInvoice: function(sord) {
    return sord.name == "Rechnung";
  },
  
  /**
   * Importiert den angegebenen Pfad.
   * 
   * @param {String} path Verzeichnispfad
   */
  importCmd: function (path) {
    log.debug("Execute command import: " + path);
    this.importDir(path);
    log.debug("Import Done.");
  },

  /**
   * Importiert das angegebene Verzeichnis.
   * 
   * @param {String} path Verzeichnispfad
   */
  importDir: function(path) {
    var impDirName = path + File.separator + docx_asImportDir;
    var impDir = new File(impDirName);
    var impFiles = impDir.list();
   
    for (var i = 0; i < impFiles.length; i++) {
      var destDir = docx_asDoneDir;
      var fileName = impFiles[i];
      try {
        this.importFile(impDirName, fileName);
      } catch(e) {
        destDir = docx_asErrorDir;
      }
      
      log.debug("Import done, move file " + fileName + " to " + destDir);
      var destDirName = path + File.separator + destDir;
      fu.rename(impDirName + File.separator + fileName, destDirName + File.separator + fileName);
    }
  },
  
  /**
   * Importiert die angegebene Datei.
   * 
   * @param {String} path Dateipfad
   * @param {String} file Dateiname
   */
  importFile: function(path, file) {
    log.debug("Process file: " + file);
    var xmlText = String(fu.asString(path + File.separator + file, "UTF-8")); 
    var headerEnd = xmlText.indexOf("<STACK");
    if (headerEnd > 0) {
      xmlText = xmlText.substring(headerEnd);
    }
    var stack = new XML(xmlText);
    this.mapData = new Array();
    
    var attributes = stack.ATTRIBUTES;
    var destination = attributes.KeyValuePair.(@Key=='$ArchivId');
    var guid = destination.@Value;
    log.info(destination.@Value);
    var sord = ixConnect.ix().checkoutSord(guid, EM_SYS_SELECTOR, LockC.YES);
    this.processSord(sord, stack);
    this.storeData(sord);
  },
  
  /**
   * Speichert die angegebenen Daten.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   */
  storeData: function(sord) {
    try {
      var id = sord.id;
      sord.objKeys[docx_statusIndexLine].data = [ docx_importStatusMsg ];
      
      ixConnect.ix().checkinMap(MapDomainC.DOMAIN_SORD, id, id, this.mapData, LockC.NO);
      ixConnect.ix().checkinSord(sord, EM_SYS_SELECTOR, LockC.YES);
    } catch(e) {
      ixConnect.ix().checkinSord(sord, SordC.mbOnlyLock, LockC.YES);
      throw(e);
    }
  },
  
  /**
   * Fügt die angegebenen Map-Daten in der Liste mit den Map-Daten ein.
   * 
   * @param {Object} data Map-Daten
   * @param {String} attribPrefix Attribut-Präfix
   * @param {String} mapPräfix Map-Präfix
   * @param {Object} ty Wert 
   */
  assignMap: function(data, attribPrefix, mapPrefix, ty) {
    var prefixLen = attribPrefix.length;
    var cnt = data.FIELD.length();
    
    for (var i = 0; i < cnt; i++) {
      var field = data.FIELD[i];
      var name = field.@Name;
      if (name.substring(0, prefixLen) == attribPrefix) {
        var mapName = mapPrefix + name.substring(prefixLen);
        var value = field.@Value;
        value = this.processValue(value, ty);
        var kv = new KeyValue(mapName, value);
        this.mapData.push(kv);
      }
    }
  },
  
  /**
   * Setzt die Daten in der angegebenen Indexzeile.
   * 
   * @param {Array} data Daten der Indexzeile
   * @param {String} attribName Attributname
   * @param {Array} objKeys Liste mit Indexzeilen
   * @param {Number} Nummer der Indexzeile
   * @param {Object} ty Wert
   */
  assignField: function(data, attribName, objKeys, indexLineNo, ty) {
    value = this.getFieldValue(data, attribName, ty);
    objKeys[indexLineNo].data = [value];
  },
  
  /**
   * Liefert den Wert des angegeben Feldes zurück.
   * 
   * @param {Object} data Daten
   * @param {attribName} Attributname
   * @param {String} ty Wert
   */
  getFieldValue: function(data, attribName, ty) {
    var item = data.FIELD.(@Name==attribName);
    var value = item.@Value;
    
    return this.processValue(value, ty);
  },
  
  /**
   * Liefert den bearbeiteten Wert zurück.
   * 
   * @param {String} value Wert
   * @param {String} ty Wert
   * @returns {String} Bearbeiteten Wert
   */
  processValue: function(value, ty) {
    value = String(value);
    
    if (ty == "D") {
      value = this.processDate(value);
    } else if (ty == "N") {
      value = this.processNumber(value);
    }
    
    return value;
  },
  
  /**
   * Liefert einen angepassten Wert zurück.
   * 
   * @param {String} value Anzupassender Wert
   * @returns {String} Angepasster Wert
   */
  processNumber: function(value) {
    // TODO Punkt, Komma Anpassung
    return value;
  },
  
  /**
   * Liefert ein formattiertes Datum zurück.
   * 
   * @param {String} unformattedDate Nicht formattiertes Datum
   * @returns {String} formattiertes Datum
   */
  processDate: function(unformattedDate) {
    ufd = unformattedDate;
    
    if ((ufd.length == 10) && (ufd.substring(2,3) == ".")) {
      return ufd.substring(6) + ufd.substring(3, 5) + ufd.substring(0, 2);
    } else if ((ufd.length == 8) && (ufd.substring(2,3) == ".")) {
      return "20" + ufd.substring(6) + ufd.substring(3, 5) + ufd.substring(0, 2);
    } else {
      return ufd;
    }
  },
  
  /**
   * Erstellt eine XML-Datei mit den angegebenen Daten.
   * 
   * @param {String} path Dateipfad
   * @param {Sord} sord Metadaten des Eintrags
   */
  exportCmd: function (path, sord) {
    if (sord.type < 254) {
      this.createXmlFile(path, sord);
    } else {
      log.warn("Es können nur Ordner als DocExtractor Quelle aufgeführt werden: " + sord.id + " : " + sord.name);
    }
    return;
  },
  
  /**
   * Erstellt eine XML-Datei für den angegebenen Repository-Eintrag im angegebenen Pfad.
   * 
   * @param {String} path Dateipfad
   * @param {Sord} sord Metadaten des Eintrags
   */
  createXmlFile: function(path, sord) {
    var destPathName = path + File.separator + docx_asExportDir;

    var imageData = this.exportFiles(destPathName, sord);
    var fileContent = this.fillupXmlTemplate(sord, imageData);
    var destXmlFile = destPathName + File.separator + sord.guid + ".xml";
    fu.asFile(destXmlFile, fileContent, "UTF-8");
  },
  
  /**
   * Exportiert die Dateien im angegeben Pfad und liefert eine Liste mit den Dateien zurück.
   * 
   * @param {String} path Exportpfad
   * @param {Sord} sord Metadaten des Eintrags
   * @returns {Array} Liste mit den exportierten Dateien
   */
  exportFiles: function(path, sord) {
    var xmlData = new Array();
    var sords = ix.collectChildren(sord.id);
    
    for (var i = 0; i < sords.length; i++) {
      log.info(sords[i].name);
      var image = this.fillupImage(path, sord.guid, sords[i], i);
      xmlData.push(image);
    }
    
    return xmlData.join("");
  },
  
  /**
   * Ersetzt einige Platzhalter im aktuellen ImageTemplate aus den angegebenen Daten.
   * 
   * @param {String} path Dateipfad
   * @param {String} guid GUID des Eintrags
   * @param {Sord} sord Metadaten des Eintrags
   * @param {Number} cnt Nummer
   * @returns {String} Ersetzten Text
   */
  fillupImage: function(path, guid, sord, cnt) {
    var isInvoice = this.checkForInvoice(sord);
    
    var text = docx_imageTemplate;
    text = text.replace(/\%Guid\%/, guid);
    text = text.replace(/\%ImageId\%/g, cnt);
    text = text.replace(/\%Skipped\%/, isInvoice ? "FALSE" : "TRUE");
    text = text.replace(/\%Ext%/g, sord.docVersion.ext);
    
    var fileName = path + File.separator + guid + "-" + cnt;
    ix.downloadDocument(fileName, sord);
    
    return text;
  },
  
  /**
   * Ersetzt einige Platzhalter im aktuellen xml-Template aus den angegebenen Daten.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @param {Object} imageData Bilddaten
   * @returns {String} Ersetzten Text
   */
  fillupXmlTemplate: function(sord, imageData) {
    var text = docx_xmlTemplate;
    text = text.replace(/\%Guid\%/, sord.guid);
    text = text.replace(/\%Id\%/, sord.id);
    text = text.replace(/\%Scandatum\%/, sord.IDateIso);
    text = text.replace(/\%TimeStamp\%/, new Date());
    text = text.replace(/\%Images\%/, imageData);
    
    return text;
  }
  
} // end of namespace docx



//JavaScript Template: elo
// start namespace elo

/**
 * @class elo
 * @singleton
 */
var elo = new Object();
elo = {

  /**
   * Liefert den Wert der angegebenen Indexzeile zurück.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @param {String} groupName Gruppennamen
   * @param {String} defaultValue Default-Wert
   * @returns {String} Wert der Indexzeile
   */
  getIndexValueByName: function(sord, groupName, defaultValue) {
    var objKeys = sord.objKeys;
    for (var i = 0; i < objKeys.length; i++) {
      var key = objKeys[i];
      if (key.name == groupName) {
        return this.formatKeyData(key.data);
      }
    }
    
    return defaultValue;
  },
  
  /**
   * Liefert den Wert der angegebenen Indexzeile zurück.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   * @param {Number} lineNo Zeilennummer
   * @returns {String} Wert der Indexzeile
   */
  getIndexValue: function (Sord, lineNo) {
    var objKey = Sord.getObjKeys()[lineNo];
    if (!objKey) {
      return "";
    }

    return this.formatKeyData(objKey.data);
  },
  
  /**
   * Liefert den Wert der angegebenen Indexzeile zurück.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   * @param {Number} lineNo Zeilennummer
   * @param {Number} lineType Typ der Indexzeile
   * @returns {String} Wert der Indexzeile
   */
  getIndexValue2: function (Sord, lineNo, lineType) {
    var objKey = Sord.getObjKeys()[lineNo];
    if (!objKey) {
      return "";
    }
    
    if (lineType == DocMaskLineC.TYPE_RELATION) {
      return elo.formatKeyData(objKey.displayData);
    } else {
      return elo.formatKeyData(objKey.data);
    }
  },

  /**
   * Liefert eine Zeichenkette mit den formattierten Daten zurück.
   * 
   * @param {Array} keyData Liste mit Daten
   * @returns {String} Zeichenkette mit den formattierten Daten
   */
  formatKeyData: function(keyData) {
    if (keyData && keyData.length > 0) {
      if (keyData.length == 1) {
        return keyData[0] + "";
      } else {
        var result = "";
        var i;
        for (i = 0; i < keyData.length; i++) {
          result = result + "¶" + keyData[i];
        }
        result = result.substr(1);
        return result;
      }
    } else {
      return "";
    }
  },
  
  /**
   * Setzt den Wert der angegebenen Indexzeile.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @param {String} groupName Gruppenname
   * @param {String} value Wert der Indexzeile
   */
  setIndexValueByName: function(sord, groupName, value) {
    var objKeys = sord.objKeys;
    for (var i = 0; i < objKeys.length; i++) {
      if (objKeys[i].name == groupName) {
        this.setIndexValue(sord, i, value);
        return;
      }
    }
  },
  
  /**
   * Setzt den Wert der angegebenen Indexzeile.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @param {Number} lineNo Zeilennummer
   * @param {String} text Wert der Indexzeile
   */
  setIndexValue: function (sord, lineNo, text) {
    if (text) {
      text = String(text);
      var objKey = sord.objKeys[lineNo];
      if (text.indexOf("¶") > -1) {
        var keyData = text.split("¶");
        objKey.data = keyData;
      } else {
        objKey.data = [ text ];
      }
    } else {
      if (text != null) {
        var text = String(text);
        if (text.equals("")) {
          var objKeyData = sord.objKeys[lineNo].data;
          if ((objKeyData) && (objKeyData.length > 0) && (objKeyData[0] != "")) {
            sord.objKeys[lineNo].data = [text];
          }
        }
      }
    }
  },

  /**
   * Setzt den Wert der angegebenen Indexzeile.
   * 
   * @param {Sord} sord Metadaten des Eintrags
   * @param {Number} lineNo Zeilennummer
   * @param {Number} lineType Typ der Indexzeile
   * @param {String} text Wert der Indexzeile
   */
  setIndexValue2: function (sord, lineNo, lineType, text) {
    if (lineType == DocMaskLineC.TYPE_RELATION) {
      return;
    }
     
    elo.setIndexValue(sord, lineNo, text);
  },

  /**
   * Legt den angegebenen Repository-Pfad an falls der Pfad nicht vorhanden ist.
   * 
   * @param {String} destPath Repository-Pfad
   * @returns {Number} Objekt-ID des letzten Pfadeintrags
   */
  preparePath: function (destPath) {
    return elo.prepareDynPath(destPath, "");
  },

  /**
   * Legt den angegebenen dynamischen Pfad an.
   * 
   * @param {String} destPath Zielpfad
   * @param {String} memo Zusatztext
   * @returns {Number} Objekt-ID des letzten Pfadeintrags
   */
  prepareDynPath: function (destPath, memo) {
    log.debug("PreparePath: " + destPath);
    var temp = destPath.split("¶¶¶.");
    if (temp.length == 2) {
      EM_FOLDERMASK = temp[0];
      destPath = temp[1];
    } else {
      EM_FOLDERMASK = "1";
    }

    try {
      var allowCreate = false;
      var checkOutPath = destPath;
      if (isNaN(destPath)) {
        checkOutPath = "ARCPATH:" + destPath;
        allowCreate = true;
      }
      var editInfo = ixConnect.ix().checkoutSord(checkOutPath, EditInfoC.mbOnlyId, LockC.NO);
      log.debug("Path found, GUID: " + editInfo.getSord().getGuid() + "   ID: " + editInfo.getSord().getId());
      EM_PARENT_ID = editInfo.getSord().getId();
      EM_PARENT_ACL = editInfo.getSord().getAclItems();
      return editInfo.getSord().getId();
    } catch (e) {
      log.debug("Path not found, create new: " + destPath + ", use foldermask: " + EM_FOLDERMASK);
    }

    if (!allowCreate) {
      return -1;
    }

    EM_PARENT_ID = -1;

    items = destPath.split("¶");

    var sordList = new Array(items.length - 1);

    var i;
    for (i = 1; i < items.length; i++) {
      log.debug("Split " + i + " : " + items[i]);
      var sord = new Sord();
      sord.setMask(EM_FOLDERMASK);
      sord.setName(items[i]);

      if (i == (items.length - 1)) {
        sord.setDesc(memo);
      }

      sordList[i - 1] = sord;
    }

    log.debug("now checkinSordPath");
    var ids = ixConnect.ix().checkinSordPath("1", sordList, new SordZ(SordC.mbName | SordC.mbMask | SordC.mbDesc | SordC.mbObjKeys));
    log.debug("checkin done: id: " + ids[ids.length - 1]);

    return ids[ids.length - 1];
  },

  /**
   * Lädt die Basisdaten aus dem angegebenen Repository-Eintrag.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   */
  loadBaseData: function (Sord) {
    NAME = String(Sord.name);
    DOCDATE = String(Sord.getXDateIso());
    ARCDATE = String(Sord.getIDateIso());
    OBJCOLOR = String(Sord.kind);
    OBJDESC = String(Sord.desc);
    OBJTYPE = String(Sord.type);
    ARCHIVINGMODE = Sord.getDetails().getArchivingMode() - 2000;
    ACL = elo.getACLString(Sord);
    BACKUP_ACL = ACL;
  },

  /**
   * Speichert die Basisdaten im angegebenen Repository-Eintrag.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   */
  storeBaseData: function (Sord) {
    if (NAME != "") {
      Sord.setName(NAME);
    }
    Sord.setXDateIso(DOCDATE);
    Sord.setIDateIso(ARCDATE);
    Sord.setKind(OBJCOLOR);
    Sord.setDesc(OBJDESC);
    Sord.setType(OBJTYPE);
    Sord.getDetails().setArchivingMode(ARCHIVINGMODE + 2000);
    elo.processAcl(Sord);
  },

  /**
   * Setzt die Werte in der angegebenen Berechtigung ("AclItem"-Objekt).
   * 
   * @param {AclItem} aclItem Berechtigung
   * @param {String} oneItem Berechtigungen als String
   */
  fillupAclItem: function (aclItem, oneItem) {
    if (oneItem == "PARENT") {  
      aclItem.type = AclItemC.TYPE_INHERIT;  
      return;  
    }  
    
    var parts = oneItem.split(":");
    var cnt = parts.length;
    if (cnt > 1) {
      var itemType = AclItemC.TYPE_GROUP;
      var access = parts[0];
      var mask = 0;
      if (access.indexOf("R") >= 0) {
        mask = mask | AccessC.LUR_READ;
      }
      
      if (access.indexOf("W") >= 0) {
        mask = mask | AccessC.LUR_WRITE;
      }
      
      if (access.indexOf("D") >= 0) {
        mask = mask | AccessC.LUR_DELETE;
      }
      
      if (access.indexOf("E") >= 0) {
        mask = mask | AccessC.LUR_EDIT;
      }
      
      if (access.indexOf("L") >= 0) {
        mask = mask | AccessC.LUR_LIST;
      }
      
      if (access.indexOf("P") >= 0) {
        mask = mask | AccessC.LUR_PERMISSION;
      }
      
      if (access.indexOf("U") >= 0) {
        itemType = AclItemC.TYPE_USER;
      }
      aclItem.setAccess(mask);
      aclItem.setName(parts[1]);
      aclItem.setType(itemType);

      if (cnt > 2) {
        var andGroups = new Array(cnt - 2);
        var i;
        for (i = 2; i < cnt; i++) {
          andGroups[i - 2] = new IdName();
          andGroups[i - 2].setName(parts[i]);
        }
        aclItem.setAndGroups(andGroups);
      }
    }
  },

  /**
   * Setzt die aktuellen Berechtigungen im angegebenen Repository-Eintrag.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   */
  processAcl: function (Sord) {
    if (ACL == "PARENT") {
      var aclItems = new Array(1);
      var parentAcl = new AclItem(0, 0, "", AclItemC.TYPE_INHERIT);
      aclItems[0] = parentAcl;
      Sord.setAclItems(aclItems);
    } else if (ACL != "") {
      var items = ACL.split("¶");
      var cnt = items.length;
      var aclItems = new Array(cnt);
      var i;

      for (i = 0; i < cnt; i++) {
        aclItems[i] = new AclItem();
      }

      Sord.setAclItems(aclItems);
    }

    for (i = 0; i < cnt; i++) {
      elo.fillupAclItem(aclItems[i], items[i]);
    }

  },

 /**
   * Liefert die Berechtigungen vom angegebenen Repository-Eintrag als 
   * eine Zeichenkette zurück.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   * @returns {String} Berechtigungen als eine Zeichenkette
   */
  getACLString: function (Sord) {
    var sb = new StringBuilder();
    var i;
    var cnt = Sord.aclItems.length;

    for (i = 0; i < cnt; i++) {
      if (i != 0) {
        sb.append("¶");
      }

      var itemType = Sord.aclItems[i].getType();
      if (itemType == AclItemC.TYPE_USER) {
        sb.append("U");
      }

      var mask = Sord.aclItems[i].getAccess();
      if (mask & AccessC.LUR_READ) {
        sb.append("R");
      };
      
      if (mask & AccessC.LUR_WRITE) {
        sb.append("W");
      };
      
      if (mask & AccessC.LUR_DELETE) {
        sb.append("D");
      };
      
      if (mask & AccessC.LUR_EDIT) {
        sb.append("E");
      };
      
      if (mask & AccessC.LUR_LIST) {
        sb.append("L");
      };
      
      if (mask & AccessC.LUR_PERMISSION) {
        sb.append("P");
      };
      sb.append(":");
      sb.append(Sord.aclItems[i].getName());

      var andGroups = Sord.aclItems[i].getAndGroups();
      if (andGroups) {
        var k;
        for (k = 0; k < andGroups.length; k++) {
          sb.append(":");
          sb.append(andGroups[k].getName());
        }
      }
    }

    return sb.toString();
  },

  /**
   * Führt die Regeln des aktuellen Regelsatzes aus.
   */
  processResultSet: function () {
    var i;
    for (i = 0; i < Sords.length; i++) {
      if (ruleset.getStop && ruleset.getStop()) {
        log.debug("Abort processResultSet, interrupted");
        return;
      }
      
      bt.processObject(Sords[i]);
    }

    if (!ruleset.getInterval().isManuallyTriggered()) {
      ruleset.setStatusMessage("Wait.");
    }
  },

  /**
   * Setzt die Maske im angegebenen Repository-Eintrag.
   * 
   * @param {Sord} Sord Metadaten des Eintrags
   * @param {String} newMaskId ID der neuen Maske
   */
  changeMask: function (Sord, newMaskId) {
    log.debug("Switch to new MaskId: " + newMaskId);
    var editInfo = ixConnect.ix().changeSordMask(Sord, newMaskId, EditInfoC.mbSord);
    Sord.setMask(editInfo.getSord().getMask());
    Sord.setMaskName(editInfo.getSord().getMaskName());
    Sord.setObjKeys(editInfo.getSord().getObjKeys());
  },

  /**
   * Fügt führende Nullen in der angegebenen Zeichenkette ein.
   * 
   * @param {String} val Wert
   * @param {Number} len Anzahl der Nullen
   * @returns {String} Zeichenkette mit führenden Nullen
   */
  pad: function (val, len) {
    val = String(val);
    while (val.length < len) val = "0" + val;
    return val;
  },

  /**
   * Liefert das aktuelle Datum im ISO-Format zurück. 
   * 
   * @returns {String} Aktuelles Datum im ISO-Format
   */
  toDayAsIso: function() {
    var dt = new Date();
    var mon = dt.getMonth() + 1;
    var day = dt.getDate();
    var txt = "" + dt.getFullYear() + ((mon < 10) ? ("0" + mon) : mon) + ((day < 10) ? ("0" + day) : day);
    return txt;
  },

  /**
   * Konvertiert das angegebene Datum in einem UTC-Datum.
   * 
   * @param {Date} date Normales Datum
   * @returns {Date} UTC-Datum
   */
  convertDateToUTC: function (date) {
    return new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(),
                    date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds());
  },

  /**
   * Liefert ein ISO-Datum aus dem angegebenen Java-Datum zurück.
   * 
   * @param {Date} date Java-Datum
   * @returns {String} ISO-Datum
   */
  isoDate: function (date) {
    return elo.pad(date.getFullYear(), 4) + elo.pad(date.getMonth() + 1, 2) + elo.pad(date.getDate(), 2);
  },

  /**
   * Liefert den Zeitstempel des angegebenen Java-Datums zurück.
   * 
   * @param {Date} date Java-Datum
   * @returns {String} Zeitstempel vom Java-Datum
   */
  timeStamp: function(date) {
    return elo.pad(date.getFullYear(), 4) + "." +
           elo.pad(date.getMonth() + 1, 2) + "." +
           elo.pad(date.getDate(), 2) + "." +
           elo.pad(date.getHours(), 2) + "." +
           elo.pad(date.getMinutes(), 2) + "." +
           elo.pad(date.getSeconds(), 2);
  },

  /**
   * Liefert ein ISO-Datum aus dem angegebenen Text zurück.
   * 
   * @param {String} text Text
   * @returns {String} ISO-Datum
   */
  decodeDate: function (text) {
    if (text == "") {
      return text;
    }
    
    if (text.charAt(0) == '+') {
      text = text.substring(1);
      var now = new Date();

      var dateOffset = (24 * 60 * 60 * 1000) * text;
      now.setTime(now.getTime() + dateOffset);

      return elo.isoDate(now);
    } else if (text.charAt(0) == '-') {
      text = text.substring(1);
      var now = new Date();

      var dateOffset = 0 - ((24 * 60 * 60 * 1000) * text);
      now.setTime(now.getTime() + dateOffset);

      return elo.isoDate(now);
    } else {
      return text;
    }
  },

  /**
   * Setzt die angegebene Status-Nachricht im aktuellen Regelsatz.
   * 
   * @param {String} text Status-Nachricht
   */
  setAnswer: function (text) {
    ruleset.setStatusMessage(text);
  },

  /**
   * Setzt die angegebene Download-Datei im aktuellen Regelsatz.
   * 
   * @param {String} fileName Dateiname
   * @param {String} contentType Content Type
   */
  setDownloadFile: function (fileName, contentType) {
    ruleset.setDownloadFile(fileName, contentType);
  },

  /**
   * Loggt die angegebene Fehlermeldung.
   * 
   * @param {Exception} exception Fehlermeldung
   */
  logStackTrace: function (exception) {
    var e2 = exception.rhinoException;
    if (e2) {
      log.debug(e2.scriptStackTrace);

      var sw = new StringWriter();
      var pw = new PrintWriter(sw, true);
      e2.printStackTrace(pw);
      pw.flush();
      sw.flush();

      log.debug(sw.toString());
    }
  },

 /**
  * Erzeugt eine Liste mit Objekten für die dynamische Stichwortliste.
  * 
  * @param {Object} dynResultTable Dynamische Stichwortliste
  * @returns {Array} Liste mit Objekten
  */
 dynamicKeywordsObject: function(dynResult) {
   var items = {};
   if(typeof dynResult == "undefinied") {
     return items;
   }

   var groupNames = dynResult.keyNames;
   var dynResultTable = dynResult.table;

   for(var i=0; i<dynResultTable.size(); i++) {
      var currRow = dynResultTable.get(i);
      var obj = new Object();
      for (var j=0; j<currRow.size(); j++) {
        if (groupNames && groupNames.get(j)) {
	   obj[groupNames.get(j)] = currRow.get(j);
	}
      } 
      items[i] = obj;
   }

   return items;
 }

}
// end of namespace elo



/**
 * @class StringBuilder
 * Erzeugt eine neue Instanz der Klasse "StringBuilder" und 
 * fügt den angegebenen Wert ein.
 * 
 * @param {String} value Wert
 * @returns {StringBuilder}
 */
function StringBuilder(value) {
  this.strings = new Array("");
  this.append(value);
}

/**
 * @method append
 * Fügt den angegebenen Wert am Ende der Instanz ein.
 * 
 * @param {String} value Wert
 */
StringBuilder.prototype.append = function (value) {
  if (value) {
    this.strings.push(value);
  }
}

/**
 * @method clear
 * Löscht den Inhalt des aktuellen StringBuilders.
 */
StringBuilder.prototype.clear = function () {
  this.strings.length = 1;
}

/**
 * @method toString
 * Liefert die aktuelle Instanz als eine Zeichenkette zurück.
 * 
 * @returns {String} Aktuelle Instanz als Zeichenkette
 */
StringBuilder.prototype.toString = function () {
  return this.strings.join("");
}



//JavaScript Template: exif
// Liest EXIF-Daten aus JPEG-Dateien.
//
// Verwendung:
//
// var myFileInfo = new Exif();
// myFileInfo.readFromFile("c:\\temp\\myPicture.jpg");
// var height = myFileInfo.valueOf("Image Height");
//
// var archiveDocInfo = new Exif();
// archiveDocInfo.readFromDoc(Sord.id);
// var xres = archiveDocInfo.valueOf("X Resolution");
//

importPackage(Packages.com.drew.imaging);
importPackage(Packages.com.drew.metadata);

/**
 * @class Exif
 */
function Exif() {
  this.metadata = null;
}

/**
 * @method readFromFile
 * Liest die EXIF-Daten aus der angegebenen Bild-Datei.
 * 
 * @param {File} file Bilddatei
 */
Exif.prototype.readFromFile = function(file) {
  if (file instanceof String) {
    file = new File(file);
  }
  
  this.metadata = ImageMetadataReader.readMetadata(file);
  
  this.map = new Array();
  var dirs = this.metadata.directories.iterator();
  while(dirs.hasNext()) {
    var dir = dirs.next();
    var tags = dir.tags.iterator();
    while (tags.hasNext()) {
      var tag = tags.next();
      this.map[tag.tagName] = tag.description;
      log.info("Tag: " + tag.tagName + " : " + tag.description);
    }
  }
}

/**
 * @method readFromDoc
 * Liest die EXIF-Daten aus dem angegebenen Repository-Dokument.
 * 
 * @param {String} objid ID des Repository-Dokuments
 */
Exif.prototype.readFromDoc = function(objid) {
  var tempFile = fu.getTempFile(objid);
  if (tempFile) {
    this.readFromFile(tempFile);
    fu.deleteFile(tempFile);
  }
}

/**
 * @method valueOf
 * Liefert den Wert des angegebenen Schlüssels zurück.
 * 
 * @param {String} tagName Schlüssel
 * @returns {Object} Wert des Schlüssels
 */
Exif.prototype.valueOf = function(tagName) {
  return this.map[tagName];
}

/**
 * @method getMetadata
 * Liefert die aktuellen Metadaten zurück.
 * 
 * @returns {Object} Metadaten
 */
Exif.prototype.getMetadata = function() {
  return this.metadata;
}

/**
 * @method getAllTags
 * Liefert die Liste mit den Tag-Daten zurück.
 * 
 * @returns {Array} Liste mit Tag-Daten
 */
Exif.prototype.getAllTags = function() {
  return this.map;
}




//JavaScript Template: fu
// start namespace fu

/**
 * @class fu
 * @singleton
 */
var fu = new Object();

fu = {

  /**
   * Löscht die ungültigen Zeichen aus dem angegebenen Dateinamen.
   * 
   * @param {String} fileName Name der Datei
   * @returns {String} Der konvertierte Dateiname
   */
  clearSpecialChars: function (fileName) {
    var newFileName = fileName.replaceAll("\\W", "_");
    return newFileName;
  },

  /**
   * Liefert eine temporäre Datei für das angegebene Repository-Dokument zurück.
   * 
   * @param {String} sordId Id des Repository-Dokuments
   * @returns {File} Temporäre Datei
   */
  getTempFile: function (sordId) {
    var editInfo = ixConnect.ix().checkoutDoc(sordId, null, EditInfoC.mbSordDoc, LockC.NO);
    var url = editInfo.document.docs[0].url;
    var ext = "." + editInfo.document.docs[0].ext;
    var name = fu.clearSpecialChars(editInfo.sord.name);

    var temp = File.createTempFile(name, ext);
    log.debug("Temp file: " + temp.getAbsolutePath());

    ixConnect.download(url, temp);

    return temp;
  },

  /**
   * Fügt die angegebene Datei als eine neue Dokumentversion ein.
   * 
   * @param {String} objId ID des Repository-Dokuments
   * @param {File} docFile Lokale Datei
   */
  addVersion: function(objId, docFile) {
    var editInfo = ixConnect.ix().checkoutDoc(objId, null, EditInfoC.mbSordDoc, LockC.NO);
    var doc = editInfo.document;
    var ext = this.getExt(docFile.name);
    
    doc.docs[0].ext = ext;
    doc = ixConnect.ix().checkinDocBegin(doc);
    
    var url = doc.docs[0].url;
    var uploadResult = ixConnect.upload(url, docFile);
    
    doc.docs[0].uploadResult = uploadResult;
    doc = ixConnect.ix().checkinDocEnd(null, null, doc, LockC.NO);
  },
  
  /**
   * Fügt die angegebene Datei als eine neue Dokumentversion ein.
   * 
   * @param {String} objId ID des Repository-Dokuments
   * @param {File} docFile Lokale Datei
   * @param {String} version Versionsbezeichnung
   * @param {String} comment Versionskommentar
   * @param {Boolean} isMilestone Nicht löschbare Version erstellen
   */
  addVersion2: function(objId, docFile, version, comment, isMilestone) {
    var item = new Document();
    item.setObjId(objId);
    var docs = [];
    docs[0] = new DocVersion();
    docs[0].setExt(ixConnect.getFileExt(docFile.getName()));
    var sord = ixConnect.ix().checkoutSord(objId, EditInfoC.mbSordDoc, LockC.NO).getSord();
    docs[0].setPathId(sord.getPath());
    item.setDocs(docs);

    // CheckinDocBegin: let Indexserver generate an URL to upload the document
    item = ixConnect.ix().checkinDocBegin(item);

    // Upload the document
    var uploadResult = ixConnect.upload(item.getDocs()[0].getUrl(), docFile);
    item.getDocs()[0].setUploadResult(uploadResult);
    item.getDocs()[0].setVersion(version);
    item.getDocs()[0].setComment(comment);
    item.getDocs()[0].setMilestone(isMilestone);

    item = ixConnect.ix().checkinDocEnd(null, null, item, LockC.YES);
  },
  
  /**
   * Löscht die angegebene Datei.
   * 
   * @param {File} delFile Zu löschende Datei
   */
  deleteFile: function (delFile) {
    delFile["delete"]();
  },

  /**
   * Liefert den Inhalt der angegebenen Datei als Text zurück.
   * 
   * @param {String} sourcePath Dateipfad
   * @param {String} encoding Kodierung
   * @returns {String} Dateiinhalt als Text
   */
  asString: function (sourcePath, encoding) {
    var file = new File(sourcePath);
    var text = FileUtils.readFileToString(file, encoding);
    return text;
  },

  /**
   * Speichert den Textinhalt in der angegebenen Zieldatei.
   * 
   * @param {String} destPath Pfad der Zieldatei
   * @param {String} data Dateiinhalt
   * @param {String} encoding Kodierung
   */
  asFile: function(destPath, data, encoding) {
    var file = new File(destPath);
    FileUtils.writeStringToFile(file, data, encoding);
  },

  /**
   * Benennt die angegebene Datei in die neue Datei um.
   * 
   * @param {String} oldName Aktueller Dateiname
   * @param {String} newName Neuer Dateiname
   * @param {Boolean} overwrite existierende Zieldatei überschreiben
   * @returns {Boolean} Umbenennen erfolgreich
   */
  rename: function(oldName, newName, overwrite) {
    var oldFile = new File(oldName);
    var newFile = new File(newName);

    if (overwrite && newFile.exists()) {
      fu.deleteFile(newFile);
    }

    return oldFile.renameTo(newFile);
  },

  /**
   * Liefert die Dateiendung aus dem angegebenen Dateinamen zurück.
   * 
   * @param {String} fileName Dateiname
   * @returns {String} Dateiendung
   */
  getExt: function(fileName) {
    fileName = String(fileName);
    var dotPos = fileName.lastIndexOf(".");
    if ((dotPos > 0) && (dotPos < (fileName.length - 1))) {
      return fileName.substring(dotPos + 1).toLowerCase();
    } else {
      return "";
    }
  },
  
  /**
   * Liefert eine Dateibezeichnung aus dem angegebenen Datum zurück.
   * 
   * @param {Date} date Datum
   * @returns {String} Dateibezeichnung
   */
  fileNameDate: function(date) {
    function pad(n) {
      return n < 10 ? '0' + n : n;
    }
    
    return date.getUTCFullYear()+'-'
    + pad(date.getUTCMonth()+1)+'-'
    + pad(date.getUTCDate())+'T'
    + pad(date.getUTCHours())+'-'
    + pad(date.getUTCMinutes())+'-'
    + pad(date.getUTCSeconds())+'Z';
  },
  
  /**
   * Konvertiert die Quelldatei zu der angegebenen Ziel Pdf-Datei.
   * 
   * @param {String} sourceName Name der Quelldatei
   * @param {String} destName Name der Ziel Pdf-Datei
   * @returns {Boolean} Konvertierung erfolgreich
   */
  convertToPdf: function(sourceName, destName) {
    var converted = false;
    
    var ext = this.getExt(sourceName);
    if ((ext == "doc") || (ext == "docx")) {
      log.debug("Convert MS-Word document");
      var doc = new com.aspose.words.Document(sourceName);
      doc.save(destName);
      converted = true;
      
    } else if ((ext == "xls") || (ext == "xlsx")) {
      log.debug("Convert MS-Excel document");
      var workbook = new com.aspose.cells.Workbook(sourceName);      
      workbook.save(destName, com.aspose.cells.FileFormatType.PDF);
      converted = true;
         
    } else if ((ext == "ppt") || (ext == "pptx")) {
      log.debug("Convert MS-Powerpoint document");
      var pdfFile = new File(destName);
      var outputStream = new java.io.FileOutputStream(pdfFile);
      var presentation = new com.aspose.slides.Presentation(sourceName);
      presentation.save(outputStream, com.aspose.slides.SaveFormat.Pdf);
      outputStream.close();
      converted = true;
    }
    
    return converted;
  },
  
  /**
   * Erstellt eine neue PDF-Version für das angegebene Repository-Dokument.
   * 
   * @param {String} objid ID des Repository-Dokuments
   */
  convertAsNewVersion: function(objid) {
    var sourceFile = this.getTempFile(objid);
    var destFile = new File(sourceFile.path + ".pdf");
    
    if (this.convertToPdf(sourceFile.path, destFile.path)) {
      this.addVersion(objid, destFile);
      destFile["delete"]();
    }
    
    sourceFile["delete"]();
  }

};
// end of namespace fu



//JavaScript Template: ix
// start namespace ix
importPackage(Packages.de.elo.ix.client.feed);

/**
 * @class ix
 * @singleton
 */
var ix = new Object();

ix = {
  docTypeCache: {},
   
  /**
  * Fügt eine neue Dateianbindung an das angegebene 
  * Repository-Dokument hinzu.
  *
  * @param {String} objId Objekt-ID des Zieldokuments
  * @param {File} file Dateianbindung
  */
  addAttachment: function(objId, file) {
    var editInfo = ixConnect.ix().checkoutDoc(objId, null, EditInfoC.mbSordDocAtt, LockC.NO);
    var doc = editInfo.document;
    var ext = fu.getExt(file.name);
    
    var atts = new Array();
    atts.push(new DocVersion());
    
    doc.atts = atts;
    doc.atts[0].ext = ext;
    doc = ixConnect.ix().checkinDocBegin(doc);
    
    var url = doc.atts[0].url;
    var uploadResult = ixConnect.upload(url, file);
    
    doc.atts[0].uploadResult = uploadResult;
    doc = ixConnect.ix().checkinDocEnd(null, null, doc, LockC.NO);
  },
  
  /**
  * Fügt eine neue Dateiversion an das angegebene 
  * Metadatenobjekt an. Der Aufrufer muss sicherstellen, 
  * dass es sich um ein ELO Dokument und nicht um einen 
  * Ordner handelt.
  *
  * @param {Sord} sord Metadaten des Zieldokuments
  * @param {File} file Datei mit der neuen Dokumentenversion
  */
  addDocument: function(sord, file) {
    var ext = fu.getExt(file.name);
    var actDoc = new DocVersion();
    actDoc.ext = ext;
    
    var docs = new Array();
    docs.push(actDoc);
    
    var document = new Document();
    if (sord.id) {
      document.objId = sord.id;
    }
    document.docs = docs;
    
    document = ixConnect.ix().checkinDocBegin(document);
    var result = ixConnect.upload(document.docs[0].url, file);
    document.docs[0].setUploadResult(result);
    
    document = ixConnect.ix().checkinDocEnd(sord, SordC.mbAll, document, LockC.YES);
  },
  
  /**
  * Verschiebt alle Dateien der Dokumenten-Untereinträge
  * eines ELO Ordners in den angegebenen Speicherpfad.
  *
  * @param {String} sordId Objekt-ID des Startordners
  * @param {String} newPathId Pfad-ID für die verschobenen Dateien
  */
  moveToPath: function(sordId, newPathId) {
    var navInfo = new NavigationInfo();
    navInfo.startIDs = [sordId];
    
    var procInfo = new ProcessInfo();
    procInfo.procMoveDocumentsToStoragePath = new ProcessMoveDocumentsToStoragePath();
    procInfo.procMoveDocumentsToStoragePath.pathId = newPathId;
    
    this.backgroundJobLoop(navInfo, procInfo);
  },
  
  /**
   * Wartet bis der angegebene Indexserver-Hintergrundprozess fertig ist.
   * 
   * @param {NavigationInfo} navInfo Indexserver-Objekt mit den abzuarbeitenden Einträgen 
   * @param {ProcessInfo} procInfo Indexserver-Objekt mit den Prozess-Einstellungen
   */
  backgroundJobLoop: function(navInfo, procInfo) {
    var jobState = ixConnect.ix().processTrees(navInfo, procInfo);
    while (jobState && jobState.jobRunning) {
      Thread.currentThread().sleep(1000);
      jobState = ixConnect.ix().queryJobState(jobState.jobGuid, true, true, true);
    }
  },
  
  /**
  * Liest den Inhalt der Indexzeile mit dem angegebenen 
  * Namen aus einem ELO "Sord"-Objekt.
  *
  * @param {Sord} sord Metadaten eines Eintrags
  * @param {String} name Gruppenname der Indexzeile
  * @returns {String} Inhalt der Indexzeile 
  */
  getIndexValueByName: function(sord, name) {
    var objKeys = sord.objKeys;
    for (var i = 0; i < objKeys.length; i++) {
      var key = objKeys[i];
      if (key.name == name) {
        if (key.data.length > 0) {
          return String(key.data[0]);
        } else {
          return "";
        }
      }
    }

    return "";
  },

  /**
  * Liefert das "ObjKey"-Objekt einer Indexzeile mit dem angegebenen 
  * Namen aus dem "Sord"-Objekt zurück.
  *
  * @param {Sord} sord Metadaten eines Eintrags
  * @param {String} name Gruppenname der Indexzeile
  * @returns {ObjKey} Indexzeile 
  */
  getKeyByName: function(sord, name) {
    var objKeys = sord.objKeys;
    log.debug("keys: " + objKeys.length + " : " + name);
    for (var i = 0; i < objKeys.length; i++) {
      var key = objKeys[i];
      log.debug("key " + key.id + " name : " + key.name);
      if (key.name == name) {
        log.debug("key found");
        return key;
      }
    }

    log.debug("no key found: " + name);
    return null;
  },

  /**
  * Sucht in einem "Sord"-Objekt nach einer Indexzeile
  * mit dem angegebenen Namen und füllt das "Data"-Feld
  * der Indexzeile mit dem angegebenen Wert.
  *
  * @param {Sord} sord Metadaten eines Eintrags
  * @param {String} name Gruppenname der Indexzeile
  * @param {String} value Einzutragender Wert
  */
  setIndexValueByName: function(sord, name, value) {
    var objKeys = sord.objKeys;
    for (var i = 0; i < objKeys.length; i++) {
      var key = objKeys[i];
      if (key.name == name) {
        key.data = [value];
      }
    }
  },
  
  /**
  * Ermittelt den ELO Dokumenttyp aus der Dateiendung des
  * angegebenen Dateinamens aus der ELO Konfiguration.
  *
  * @param {String} filename Dateiname
  * @returns {Number} ID des Dokumenttyps
  */
  lookupDocType: function(filename) {
    var now = new Date();
    if (!this.docTypeCache.createTime || (now.getTime() - this.docTypeCache.createTime.getTime()) > 100000) {
      log.debug("Reload document type cache.");
      this.docTypeCache.sordTypes = ixConnect.ix().checkoutSordTypes(null, SordTypeC.mbNoIcons, LockC.NO);
      this.docTypeCache.createTime = now;
    }
    
    var extensionStart = filename.lastIndexOf(".");
    if ((extensionStart < 0) || (extensionStart == (filename.length - 1))) {
      throw "No file extension found";
    }
    
    var fileExt = filename.substring(extensionStart + 1);
    for (var i = 0; i < this.docTypeCache.sordTypes.length; i++) {
      var extensions = this.docTypeCache.sordTypes[i].extensions;
      
      if (extensions) {
        for (var ext = 0; ext < extensions.length; ext++) {
          if (extensions[ext].equalsIgnoreCase(fileExt)) {
            return this.docTypeCache.sordTypes[i].id;
          }
        }
      }
    }
    
    return -1;
  },
  
  /**
  * Lädt maximal die ersten 1000 Nachfolgereinträge
  * eines ELO Ordners.
  *
  * @param {String} parentId Objekt-ID des Ordners
  * @param {Boolean} withRefs Auch Referenzen laden
  * @returns {Sord[]} Liste mit Untereintägen 
  */
  collectChildren: function(parentId, withRefs) {
    var findInfo = new FindInfo();
    var findChildren = new FindChildren();
    findChildren.parentId = parentId;
    findChildren.mainParent = !withRefs;
    findInfo.findChildren = findChildren;
    
    var findResult = ixConnect.ix().findFirstSords(findInfo, 1000, EM_SYS_SELECTOR);
    ixConnect.ix().findClose(findResult.searchId);

    return findResult.sords;
  },

  /**
  * Löscht einen Eintrag oder eine Referenz.
  *
  * @param {String} parentId ID des übergeordneten Ordners
  * @param {String} objId Objekt-ID des Eintrags
  * @returns {Boolean} Löschergebnis 
  */
  deleteSord: function (parentId, objId) {
    log.info("Delete SORD: ParentId = " + parentId + ",  ObjectId = " + objId);
    return ixConnect.ix().deleteSord(parentId, objId, LockC.NO, null);
  },

  /**
   * Liefert die Objekt-ID des angegebenen Repository-Pfades zurück.
   * 
   * @param {String} archivePath Repository-Pfad des Eintrags
   * @returns {Number} Objekt-ID des Eintrags
   */
  lookupIndex: function (archivePath) {
    log.info("Lookup Index: " + archivePath);
    var editInfo = ixConnect.ix().checkoutSord("ARCPATH:" + archivePath, EditInfoC.mbOnlyId, LockC.NO);
    if (editInfo) {
      return editInfo.getSord().getId();
    } else {
      return 0;
    }
  },

  /**
  * Ermittelt die ELO Objekt-ID zu einem gesuchten Eintrag aus Maskennummer
  * und Indexzeile.
  *
  * @param {String} maskId Gesuchte Maske
  * @param {String} groupName Name der Indexzeile
  * @param {String} value Inhalt der Indexzeile
  * @returns {Number} Objekt-ID des Eintrags
  */
  lookupIndexByLine: function (maskId, groupName, value) {
    var findInfo = new FindInfo();
    var findByIndex = new FindByIndex();
    if (maskId != "") {
      findByIndex.maskId = maskId;
    }

    var objKey = new ObjKey();
    var keyData = new Array(1);
    keyData[0] = value;
    objKey.setName(groupName);
    objKey.setData(keyData);

    var objKeys = new Array(1);
    objKeys[0] = objKey;

    findByIndex.setObjKeys(objKeys);
    findInfo.setFindByIndex(findByIndex);

    var findResult = ixConnect.ix().findFirstSords(findInfo, 1, SordC.mbMin);
    ixConnect.ix().findClose(findResult.getSearchId());

    if (findResult.sords.length == 0) {
      return 0;
    }

    return findResult.sords[0].id;
  },

  /**
  * Ermittelt die ELO Objekt-ID zu einem gesuchten Eintrag aus Maskennummer
  * und zwei Indexzeilen.
  *
  * @param {String} maskId Gesuchte Maske
  * @param {String} groupName1 Name der ersten Indexzeile
  * @param {String} groupName2 Name der zweiten Indexzeile
  * @param {String} value1 Inhalt der ersten Indexzeile
  * @param {String} value2 Inhalt der zweiten Indexzeile
  * @returns {Number} Objekt-ID des Eintrags
  */
  lookupIndexByLine2: function (maskId, groupName1, groupName2, value1, value2) {
    var findInfo = new FindInfo();
    var findByIndex = new FindByIndex();
    if (maskId != "") {
      findByIndex.maskId = maskId;
    }

    var objKey1 = new ObjKey();
    var keyData1 = new Array(1);
    keyData1[0] = value1;
    objKey1.setName(groupName1);
    objKey1.setData(keyData1);

    var objKey2 = new ObjKey();
    var keyData2 = new Array(1);
    keyData2[0] = value2;
    objKey2.setName(groupName2);
    objKey2.setData(keyData2);

    var objKeys = new Array(2);
    objKeys[0] = objKey1;
    objKeys[1] = objKey2;

    findByIndex.setObjKeys(objKeys);
    findInfo.setFindByIndex(findByIndex);

    var findResult = ixConnect.ix().findFirstSords(findInfo, 1, SordC.mbMin);
    ixConnect.ix().findClose(findResult.getSearchId());

    if (findResult.sords.length == 0) {
      return 0;
    }

    return findResult.sords[0].id;
  },

  /**
  * Sucht einen Eintrag mit der angegebenen Maskennummer
  * und Indexzeileninhalt.
  *
  * @param {String} maskNo Gesuchte Maske
  * @param {String} groupName Name der zu durchsuchenden Indexzeile
  * @param {String} value Gesuchter Indexwert
  * @returns {Sord} Metadaten des Eintrags
  */
  findEntry: function (maskNo, groupName, value) {
    ruleset.setStatusMessage("Searching...");
    var findInfo = new FindInfo();
    var findByIndex = new FindByIndex();

    var objKey = new ObjKey();
    var keyData = new Array(1);
    keyData[0] = value;
    objKey.setName(groupName);
    objKey.setData(keyData);

    var objKeys = new Array(1);
    objKeys[0] = objKey;

    findByIndex.setObjKeys(objKeys);
    if (maskNo != "") {
      findByIndex.maskId = maskNo;
    }
    findInfo.setFindByIndex(findByIndex);
    
    var findResult = ixConnect.ix().findFirstSords(findInfo, 1, EM_SYS_SELECTOR);
    var sords = findResult.getSords();
    ixConnect.ix().findClose(findResult.getSearchId());

    if (sords && sords.length > 0) {
      return sords[0];
    } else {
      return new Sord();
    }
  },

  /**
  * Erzeugt, beginnend mit einem Startordner, den angegebenen
  * Unterpfad mit der angegebenen Maske.
  *
  * @param {String} startId Objekt-ID vom Startordner
  * @param {String} destPath Unterpfad, beginnend ab dem Startordner
  * @param {Number} folderMask Maske für neu anzulegende Ordner
  * @returns {Number} Objekt-ID des letzten Ordners
  */
  createSubPath: function (startId, destPath, folderMask) {
    log.debug("createPath: " + destPath);

    try {
      var editInfo = ixConnect.ix().checkoutSord("ARCPATH[" + startId + "]:" + destPath, EditInfoC.mbOnlyId, LockC.NO);
      log.debug("Path found, GUID: " + editInfo.getSord().getGuid() + "   ID: " + editInfo.getSord().getId());
      return editInfo.getSord().getId();
    } catch (e) {
      log.debug("Path not found, create new: " + destPath + ", use foldermask: " + folderMask);
    }

    items = destPath.split("¶");
    var sordList = new Array(items.length - 1);
    for (var i = 1; i < items.length; i++) {
      log.debug("Split " + i + " : " + items[i]);
      var sord = new Sord();
      sord.setMask(folderMask);
      sord.setName(items[i]);

      sordList[i - 1] = sord;
    }

    log.debug("now checkinSordPath");
    var ids = ixConnect.ix().checkinSordPath(startId, sordList, new SordZ(SordC.mbName | SordC.mbMask));
    log.debug("checkin done: id: " + ids[ids.length - 1]);

    return ids[ids.length - 1];
  },

  /**
  * Gibt den Volltext eines ELO Dokuments in einem String zurück.
  *
  * @param {String} objId Objekt-ID des Dokuments
  * @returns {String} Volltextinhalt des Dokuments
  */
  getFulltext: function (objId) {
    var editInfo = ixConnect.ix().checkoutDoc(objId, null, EditInfoC.mbSordDoc, LockC.NO);
    var url = editInfo.document.docs[0].fulltextContent.url;
    var ext = "." + editInfo.document.docs[0].fulltextContent.ext;
    var name = fu.clearSpecialChars(editInfo.sord.name);

    var temp = File.createTempFile(name, ext);
    log.debug("Temp file: " + temp.getAbsolutePath());

    ixConnect.download(url, temp);
    var text = FileUtils.readFileToString(temp, "UTF-8");
    temp["delete"]();

    return text;
  },

  /**
  * Lädt die Arbeitsversion eines ELO Dokuments in eine lokale Datei herunter.
  *
  * @param {String} pathAndFileName Vollständiger lokaler Pfad für die zu lesende Datei
  * @param {Sord} sord Metadaten eines Eintrags
  * @returns {String} Pfad der erstellten lokalen Datei
  */
  downloadDocument: function (pathAndFileName, sord) {
    var url = sord.docVersion.url;
    var ext = "." + sord.docVersion.ext;
    var file = new File(pathAndFileName + ext);

    ixConnect.download(url, file);

    return file.path;
  },

  /**
  * Lädt die Arbeitsversion eines ELO Dokuments herunter und gibt den Inhalt 
  * als String zurück.
  *
  * @param {Sord} sord Metadaten eines Dokuments
  * @returns {String} Dokumentinhalt als String
  */
  downloadAsString: function (sord) {
    var url = sord.docVersion.url;
    var ext = "." + sord.docVersion.ext;

    var temp = File.createTempFile("ELOasDownloadAsString", ext);
    log.debug("Temp file: " + temp.getAbsolutePath());

    ixConnect.download(url, temp);
    var text = FileUtils.readFileToString(temp, "UTF-8");
    temp["delete"]();

    return text;
  },
  
  /**
   * Löscht eine Dokumentenversion anhand der Versionsnummer.
   * Optional kann die Version auch dauerhaft entfernt werden,
   * andernfalls wird sie nur logisch gelöscht.
   *
   * @param {String } id ELO Objekt-ID des Eintrags aus dem gelöscht werden soll
   * @param {String} version Versionsnummer des zu löschenden Dokuments
   * @param {Boolean} deleteFinally Löscht alle als gelöscht markierten Versionen dauerhaft
   * @returns {Boolean} Löschergebnis 
   **/
  deleteVersion: function(id, version, deleteFinally) {
    try {
      var itemData = ixConnect.ix().checkoutDoc(id, "-1", EditInfoC.mbDocument, LockC.YES);
      var docs = itemData.document.docs;
      for (var i = 0; i < docs.length; i++) {
        if (docs[i].version == version) {
          docs[i].deleted = true;
          ixConnect.ix().checkinDocEnd(null, null,itemData.document, LockC.NO);
        
          if (deleteFinally) {
            this.deleteDocumentFile(id);
          }
          
          return true;
       }
     }
    } catch(ex) {
      log.warn("Exception while deleting the document version: " + ex);
    } finally {
      var unlockSord = new Sord();
      unlockSord.id = id;
      ixConnect.ix().checkinSord(unlockSord, SordC.mbOnlyUnlock, LockC.YES );
    }
  
    return false;
  },

  /**
   * Diese Funktion löscht dauerhaft alle als gelöscht markierten
   * Dokumentenversionen des angegebenen Dokuments.
   * 
   * @param {String} documentId Objekt-ID des Dokuments
   **/
  deleteDocumentFile: function(documentId) {
    var delOptions = new DeleteOptions();
    delOptions.deleteCertainDocumentVersionsOnly = true;
    delOptions.deleteFinally = true;
    ixConnect.ix().deleteSord(null, documentId, LockC.NO, delOptions);
  },

  /**
  * Löscht alle Dokumente mit überschrittenen Verfallsdatum.
  * 
  * @param {Boolean} deleteFinally Dokumente dauerhaft löschen 
  */
  deleteOldDocs: function (deleteFinally) {
    var delOpts = new DeleteOptions();
    delOpts.setDeleteExpiredOnly(true);
    delOpts.setDeleteFinally(false);
    log.info("Start logically delete Objects");
    ixConnect.ix().cleanupStart(delOpts);

    if (deleteFinally) {
      log.debug("Wait for end of deletion process");
      for (;;) {
        var jobState = ixConnect.ix().cleanupState();
        if (!jobState.jobRunning) {
          break;
        }
        log.debug("still running");
        Thread.sleep(10000);
      }

      delOpts.setDeleteFinally(true);
      log.info("Start delete Objects (finally: " + deleteFinally + ")");
      ixConnect.ix().cleanupStart(delOpts);
    }
  },

  totalCount : 0,
  hourCount : 0,
  dayCount : 0,
  
  /**
  * Ermittelt die Anzahl der aktuell angemeldeten Benutzer sowie
  * der in der letzten Stunde und des laufenden Tags maximal 
  * angemeldeten Benutzer.
  *
  * Diese Funktion muss regelmäßig aufgerufen werden wenn die
  * Stunden und Tageswerte benötigt werden (z.B. alle 5 Minuten).
  * 
  * @returns {Object} Objekt mit der Anzahl der angemeldeten Benutzer  
  */
  getLoginCount: function () {
    var values = ixConnect.ix().checkoutUsers(null, CheckoutUsersC.SESSION_USERS_RAW, LockC.NO);
    
    if (log.isDebugEnabled()) {
      for (var i = 0; i < values.length; i++) {
        log.debug("- " + i + " : " + values[i].id + " : " + values[i].name);
      }
    }
    
    var actCount = values.length;
    
    if (actCount > this.hourCount) {
      this.hourCount = actCount;
    }
    
    if (actCount > this.dayCount) {
      this.dayCount = actCount;
    }
    
    if (actCount > this.totalCount) {
      this.totalCount = actCount;
    }
    
    var result = { nowCount: actCount, hourCount : this.hourCount, dayCount : this.dayCount, totalCount : this.totalCount, hourChanged : false, dayChanged : false };
    
    var now = new Date();
    var day = now.getDate();
    if (day != this.day) {
      this.day = day;
      this.dayCount = 0;
      result.dayChanged = true;
    }
    
    var hour = now.getHours();
    if (hour != this.hour) {
      this.hour = hour;
      this.hourCount = 0;
      result.hourChanged = true;
    }
    
    return result;
  },
  
  /**
  * Fügt einen Skript-Kommentar im Feed eines Repository-Eintrags
  * hinzu.
  *
  * @param {String} eloObjectGuid ELO Objekt-GUID (nicht die Objekt-ID) des Eintrags
  * @param {String} user ELO Benutzer - im Augenblick noch ohne Funktion aufgrund einer IX Einschränkung
  * @param {String} comment Text (kein HTML-Text) der in den Feed eingetragen werden soll
  */
  addFeedComment: function(eloObjectGuid, user, comment) {
    var feed = ixConnect.feedService;
    
    var action = feed.createAction(EActionType.AutoComment, eloObjectGuid);
    action.setText(comment);
    feed.checkinAction(action, ActionC.mbAll);
  }
  
};
// end of namespace ix



//JavaScript Template: json
/**
 * @class JSON
 * @singleton
 */ 
/** 
 * @method stringify
 * 
 * @param {Any} value
 * Any JavaScript value, usually an object or array.
 * @returns {String}
 */

/** 
 * @method parse
 * 
 * This method parses a JSON text to produce an object or array. It can throw a SyntaxError exception.
 * 
 * @param {String} serialized String to parse.
 * @returns {Object|Array}
 */

/*
    json2.js
    2011-10-19

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html


    This code should be minified before deployment.
    See http://javascript.crockford.com/jsmin.html

    USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
    NOT CONTROL.


    This file creates a global JSON object containing two methods: stringify
    and parse.

        JSON.stringify(value, replacer, space)
            value       any JavaScript value, usually an object or array.

            replacer    an optional parameter that determines how object
                        values are stringified for objects. It can be a
                        function or an array of strings.

            space       an optional parameter that specifies the indentation
                        of nested structures. If it is omitted, the text will
                        be packed without extra whitespace. If it is a number,
                        it will specify the number of spaces to indent at each
                        level. If it is a string (such as '\t' or '&nbsp;'),
                        it contains the characters used to indent at each level.

            This method produces a JSON text from a JavaScript value.

            When an object value is found, if the object contains a toJSON
            method, its toJSON method will be called and the result will be
            stringified. A toJSON method does not serialize: it returns the
            value represented by the name/value pair that should be serialized,
            or undefined if nothing should be serialized. The toJSON method
            will be passed the key associated with the value, and this will be
            bound to the value

            For example, this would serialize Dates as ISO strings.

                Date.prototype.toJSON = function (key) {
                    function f(n) {
                        // Format integers to have at least two digits.
                        return n < 10 ? '0' + n : n;
                    }

                    return this.getUTCFullYear()   + '-' +
                         f(this.getUTCMonth() + 1) + '-' +
                         f(this.getUTCDate())      + 'T' +
                         f(this.getUTCHours())     + ':' +
                         f(this.getUTCMinutes())   + ':' +
                         f(this.getUTCSeconds())   + 'Z';
                };

            You can provide an optional replacer method. It will be passed the
            key and value of each member, with this bound to the containing
            object. The value that is returned from your method will be
            serialized. If your method returns undefined, then the member will
            be excluded from the serialization.

            If the replacer parameter is an array of strings, then it will be
            used to select the members to be serialized. It filters the results
            such that only members with keys listed in the replacer array are
            stringified.

            Values that do not have JSON representations, such as undefined or
            functions, will not be serialized. Such values in objects will be
            dropped; in arrays they will be replaced with null. You can use
            a replacer function to replace those with JSON values.
            JSON.stringify(undefined) returns undefined.

            The optional space parameter produces a stringification of the
            value that is filled with line breaks and indentation to make it
            easier to read.

            If the space parameter is a non-empty string, then that string will
            be used for indentation. If the space parameter is a number, then
            the indentation will be that many spaces.

            Example:

            text = JSON.stringify(['e', {pluribus: 'unum'}]);
            // text is '["e",{"pluribus":"unum"}]'


            text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
            // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

            text = JSON.stringify([new Date()], function (key, value) {
                return this[key] instanceof Date ?
                    'Date(' + this[key] + ')' : value;
            });
            // text is '["Date(---current time---)"]'


        JSON.parse(text, reviver)
            This method parses a JSON text to produce an object or array.
            It can throw a SyntaxError exception.

            The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.

            Example:

            // Parse the text. Values that look like ISO date strings will
            // be converted to Date objects.

            myData = JSON.parse(text, function (key, value) {
                var a;
                if (typeof value === 'string') {
                    a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                    if (a) {
                        return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                            +a[5], +a[6]));
                    }
                }
                return value;
            });

            myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                var d;
                if (typeof value === 'string' &&
                        value.slice(0, 5) === 'Date(' &&
                        value.slice(-1) === ')') {
                    d = new Date(value.slice(5, -1));
                    if (d) {
                        return d;
                    }
                }
                return value;
            });


    This is a reference implementation. You are free to copy, modify, or
    redistribute.
*/

/*jslint evil: true, regexp: true */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
    call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
    getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
    lastIndex, length, parse, prototype, push, replace, slice, stringify,
    test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

var JSON;
if (!JSON) {
    JSON = {};
}

(function () {
    'use strict';

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf())
                ? this.getUTCFullYear()     + '-' +
                    f(this.getUTCMonth() + 1) + '-' +
                    f(this.getUTCDate())      + 'T' +
                    f(this.getUTCHours())     + ':' +
                    f(this.getUTCMinutes())   + ':' +
                    f(this.getUTCSeconds())   + 'Z'
                : null;
        };

        String.prototype.toJSON      =
            Number.prototype.toJSON  =
            Boolean.prototype.toJSON = function (key) {
                return this.valueOf();
            };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ? '"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string'
                ? c
                : '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' : '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0
                    ? '[]'
                    : gap
                    ? '[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']'
                    : '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if (typeof rep[i] === 'string') {
                        k = rep[i];
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.prototype.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0
                ? '{}'
                : gap
                ? '{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}'
                : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.prototype.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/
                    .test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function'
                    ? walk({'': j}, '')
                    : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
}());




//JavaScript Template: lead
// start of namespace lead

/**
 * @class lead
 * @singleton
 */
var lead = new Object();

// Konstanten
var LEAD_DOCMASK = "0";
var LEAD_ITEMMASK = 340;
var LEAD_FOLDERMASK = 341;

lead = {

  /**
   * Setzt die angegebene Indexzeile im übergeordneten Repository-Eintrag.
   * 
   * @param {Object} indexLine Indexzeile
   */
  copyIndexToParent: function (indexLine) {
    elo.setIndexValue(EM_PARENT_SORD, indexLine, elo.getIndexValue(EM_ACT_SORD, indexLine));
  },

  /**
   * Erstellt einen dynamischen Ordner aus den angegebenen Metadaten.
   * 
   * @param {Sord} sord Metadaten eines Eintrags
   * @param {String} status Status
   */
  makeDynReg: function (sord, status) {
    var memo = "!+ , objkeys k1, objkeys k2 where objid = k1.parentid and k1.parentid = k2.parentid and k1.okeyname = 'ELO_LISTA' and k1.okeydata like '";
    memo = memo + status + " - %' and k2.okeyname = 'ELO_LIPRT' and k2.okeydata = '";
    memo = memo + NAME + "' and objtype < 254";
    var basePath = sord.getRefPaths()[0].getPathAsString();
    var delim = basePath.substring(0, 1);
    var name = Leadstatus[status];
    elo.prepareDynPath(basePath + delim + sord.name + delim + name, memo);
  },

  /**
   * Liefert den Indexaufbau des angegebenen Ordners als eine Zeichenkette zurück.
   * 
   * @param {Sord} sord Metadaten eines Repository-Eintrags
   * @returns {String} Indexaufbau des Ordners
   */
  folderIndexToString: function (sord) {
    var i;
    var res = "#";

    for (i = 0; i < 11; i++) {
      res = res + elo.getIndexValue(sord, i) + "#";
    }

    return res;
  }

}
// end of namespace lead



//JavaScript Template: mail
﻿// start namespace mail
var mail = new Object();
mail = {

  connectImap_GMAIL: function () {
    log.debug("Connect Mailbox GMAIL");
    var props = new Properties();
    props.setProperty("mail.imap.host", "imap.gmail.com");
    props.setProperty("mail.imap.port", "993");
    props.setProperty("mail.imap.connectiontimeout", "5000");
    props.setProperty("mail.imap.timeout", "5000");
    props.setProperty("mail.imap.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
    props.setProperty("mail.imap.socketFactory.fallback", "false");
    props.setProperty("mail.store.protocol", "imaps");

    var session = Session.getDefaultInstance(props);
    log.debug("Get Store");
    MAIL_STORE = session.getStore("imaps");
    log.debug("Connect elojforum");
    MAIL_STORE.connect("imap.gmail.com", "abc@gmail.com", "1234");
    var folder = MAIL_STORE.getDefaultFolder();
    //MAIL_INBOX = folder.getFolder("INBOX");
    MAIL_INBOX = folder.getFolder("[Google Mail]/Gesendet");
    log.debug("Open folder");
    MAIL_INBOX.open(Folder.READ_WRITE);
    log.debug("Get Messages");
    MAIL_MESSAGES = MAIL_INBOX.getMessages();
    MAIL_DELETE_ARCHIVED = false;
  },

  finalizeImap_GMAIL: function () {
    if (MAIL_DELETE_ARCHIVED && MAIL_ALLOW_DELETE) {
      message.setFlag(Flags.Flag.SEEN, true);
    }
  },

  nextImap_GMAIL: function () {
    for (;;) {
      if (MAIL_POINTER >= MAIL_MESSAGES.length) {
        log.debug("No more Messages (" + MAIL_MESSAGES.length + ")");
        return false;
      }

      MAIL_MESSAGE = MAIL_MESSAGES[MAIL_POINTER];
      log.debug("Process Message: " + MAIL_MESSAGE.subject);
      var flags = MAIL_MESSAGE.getFlags();
      if (flags.contains(Flags.Flag.SEEN)) {
        MAIL_POINTER++;
        continue;
      }

      MAIL_ALLOW_DELETE = false;
      MAIL_POINTER++;
      return true;
    }

    return false;
  },

  setSmtpHost: function (smtpHost) {
    if (MAIL_SMTP_HOST != smtpHost) {
      MAIL_SMTP_HOST = smtpHost;
      MAIL_SESSION = undefined;
    }
  },

  startSession: function () {
    if (MAIL_SESSION == undefined) {
      var props = new Properties();
      props.put("mail.smtp.host", MAIL_SMTP_HOST);
      props.put("mail.smtp.user","administrator@mode-jost.de");
      props.put("mail.smtp.port","25");  
      props.put("mail.smtp.auth", "false");
      props.put("mail.smtp.ssl.enable", "false");  
      props.put("mail.smtp.from","administrator@mode-jost.de");  
      props.put("mail.transport.protocol","smtp");
      props.put("mail.smtp.starttls.enable", "false");
      MAIL_SESSION = Session.getInstance(props, null);
    }
  },

  sendMail: function (addrFrom, addrTo, subject, body) {
    this.sendMailInternal(addrFrom, addrTo, subject, body, null);
  },

  sendHtmlMail: function (addrFrom, addrTo, subject, body) {
    this.sendMailInternal(addrFrom, addrTo, subject, null, body);
  },

   sendMailInternal: function (addrFrom, addrTo, subject, textBody, htmlBody) {
    mail.startSession();
    var msg = new MimeMessage(MAIL_SESSION);
    var inetFrom = new InternetAddress(addrFrom);
    msg.setFrom(inetFrom);

    var parts = addrTo.split(";");
    for (var i = 0; i < parts.length; i++) {
      var inetTo = new InternetAddress(parts[i]);
      msg.addRecipient(Message.RecipientType.TO, inetTo);
    }    
    
    msg.setSubject(subject);
    
    if (textBody) {
      msg.setText(textBody);
    }
    
    if (htmlBody) {
      msg.setContent(htmlBody, "text/html; charset=utf-8");
    }
    
    Transport.send(msg);
  },
  
  sendMailWithAttachment: function (addrFrom, addrTo, subject, body, attachId, isHtml) {
    var tempFile = fu.getTempFile(attachId);
    this.sendMailWithAttachmentFile(addrFrom, addrTo, subject, body, tempFile, isHtml);

    tempFile["delete"]();
  },
  
  sendMailWithAttachmentFile: function (addrFrom, addrTo, subject, body, file, isHtml) {
    mail.startSession();
    var msg = new MimeMessage(MAIL_SESSION);
    var inetFrom = new InternetAddress(addrFrom);
    msg.setFrom(inetFrom);

    var parts = addrTo.split(";");
    for (var i = 0; i < parts.length; i++) {
      var inetTo = new InternetAddress(parts[i]);
      msg.addRecipient(Message.RecipientType.TO, inetTo);
    }

    msg.setSubject(subject);

    var textPart = new MimeBodyPart();
    if (isHtml) {
      textPart.setContent(body, "text/html; charset=utf-8");
    } else {
      textPart.setContent(body, "text/plain");
    }

    var attachFilePart = new MimeBodyPart();
    attachFilePart.attachFile(file);

    var mp = new MimeMultipart();
    mp.addBodyPart(textPart);
    mp.addBodyPart(attachFilePart);
    msg.setContent(mp);
    Transport.send(msg);
  },

  connectImap: function (connectionName) {
    mail["connectImap_" + connectionName]();
    MAIL_POINTER = 0;
    MAIL_CONNECT_NAME = connectionName;
  },


  nextMessage: function () {
    if (mail["nextImap_" + MAIL_CONNECT_NAME]) {
      if (MAIL_POINTER > 0) {
        mail.finalizePreviousMessage(MAIL_MESSAGE);
      }

      return mail["nextImap_" + MAIL_CONNECT_NAME]();
    } else {
      // default implementation
      if (MAIL_POINTER > 0) {
        mail.finalizePreviousMessage(MAIL_MESSAGE);
      }

      if (MAIL_POINTER >= MAIL_MESSAGES.length) {
        return false;
      }

      MAIL_MESSAGE = MAIL_MESSAGES[MAIL_POINTER];
      MAIL_ALLOW_DELETE = false;
      MAIL_POINTER++;
      return true;
    }
  },

  finalizePreviousMessage: function (message) {
    if (mail["finalizeImap_" + MAIL_CONNECT_NAME]) {
      mail["finalizeImap_" + MAIL_CONNECT_NAME]();
    } else {
      if (MAIL_DELETE_ARCHIVED && MAIL_ALLOW_DELETE) {
        message.setFlag(Flags.Flag.DELETED, true);
      }
    }
  },


  closeImap: function () {
    if (mail["closeImap_" + MAIL_CONNECT_NAME]) {
      mail["closeImap_" + MAIL_CONNECT_NAME]();
    } else {
      MAIL_INBOX.close(true);
      MAIL_STORE.close();
    }
  },

  getBodyText: function (message) {
    var content = message.content;
    if (content instanceof String) {
      return content;
    } else if (content instanceof Multipart) {
      var cnt = content.getCount();
      for (var i = 0; i < cnt; i++) {
        var part = content.getBodyPart(i);
        var ct = part.contentType;
        if (ct.match("^TEXT/PLAIN") == "TEXT/PLAIN") {
          return part.content;
        }
      }
    }

    return "";
  },

  getSender: function (message) {
    var adress = message.sender;
    return adress.toString();
  },

  getRecipients: function (message, delimiter) {
    var adresses = message.allRecipients;

    var cnt = 0;
    if (adresses) {
      cnt = adresses.length;
    }
    var hasMany = cnt > 1;

    var result = "";
    for (var i = 0; i < cnt; i++) {
      if (hasMany) {
        result = result + delimiter;
      }
      result = result + adresses[i].toString();
    }

    return result;
  }

}
// end of namespace mail



//JavaScript Template: noti
// ELO Notification Services Library

/**
 * @class notify
 * @singleton
 */
var notify = new Notify();

function Notify() {
  this.templateRoot = "ARCPATH:¶Administration¶ELOas Base¶Misc¶";
  this.templatePath = this.templateRoot + "wfreminder";
  this.optionKey = "ELOas.SendWfAsMail";
  this.showMailBody = false;
}

/**
 * @method checkAddFeed
 * Prüft nach, ob der aktuelle Workflow-Eintrag einen
 * konfigurierten Feed Kommentar enthält. So ein Knoten hat
 * in der Arbeitsanweisung einen Text beginnend mit #wfaddfeed
 * oder #wfmailandfeed. Wenn so ein Knoten vorliegt, wird
 * ein neuer Feed Eintrag mit den aktuellen Parametern eingetragen.
 */
Notify.prototype.checkAddFeed = function() {
  this.withIndex = true;
  var comment = EM_WF_NODE.nodeComment;
  if (comment.startsWith("#wfaddfeed") || comment.startsWith("#wfmailandfeed")) {
    var props = this.getProperties(comment);
    
    var templateName = props.getProperty("feedtemplate");
    if (!templateName) {
      templateName = "wffeed";
    }
    
    var template = this.getTemplate(this.templateRoot + templateName);
    var msg = "";

    if ((typeof(notifyCallback) == "object") && notifyCallback.formatFeedMessage) {
      msg = notifyCallback.formatFeedMessage(template, EM_WF_NODE, EM_ACT_SORD, props);
    }
    
    if (!msg) {
      msg = this.substituteVars2(template, EM_WF_NODE, EM_ACT_SORD, props);
    }
    
    ix.addFeedComment(EM_ACT_SORD.guid, 0, msg);    
    log.debug("Add feed entry done.");    
    EM_WF_NEXT = "0";
  }
}

/**
 * @method checkSendMail
 * Prüft nach, ob der aktuelle Workflow-Eintrag einen
 * konfigurierten Mail Kommentar enthält. So ein Knoten hat
 * in der Arbeitsanweisung einen Text beginnend mit #wfsendmail
 * oder #wfmailandfeed. Wenn so ein Knoten vorliegt, wird
 * eine EMail mit den aktuellen Parametern versandt.
 */
Notify.prototype.checkSendMail = function() {
  this.withIndex = true;
  var comment = EM_WF_NODE.nodeComment;
  if (comment.startsWith("#wfsendmail") || comment.startsWith("#wfmailandfeed")) {
    var props = this.getProperties(comment);
    
    var templateName = props.getProperty("template");
    var recipient = this.getMailUser(props.getProperty("recipient"));
    var sender = this.getMailUser(props.getProperty("sender"));
    var subject = props.getProperty("subject");
    if (!subject) {
      subject = EM_ACT_SORD.name;
    }
    
    if ((typeof(notifyCallback) == "object") && notifyCallback.getSubject) {
      var text = notifyCallback.getSubject(EM_WF_NODE, EM_ACT_SORD, props);
      if (text) {
        subject = text;
      }
    }
    
    if (!templateName) {
      templateName = "wfmail";
    }
    var template = this.getTemplate(this.templateRoot + templateName);
    var msg = "";

    if ((typeof(notifyCallback) == "object") && notifyCallback.formatMessage) {
      msg = notifyCallback.formatMessage(template, EM_WF_NODE, EM_ACT_SORD, props);
    }
    
    if (!msg) {
      msg = this.substituteVars2(template, EM_WF_NODE, EM_ACT_SORD, props);
    }
    
    var withAttachment = props.getProperty("withattachment");
    if (withAttachment) {
      withAttachment = withAttachment == "true";
    }
    
    if (withAttachment) {
      mail.sendMailWithAttachment(sender, recipient, subject, msg, EM_ACT_SORD.id, true);
    } else {
      mail.sendHtmlMail(sender, recipient, subject, msg);
    }
    
    log.debug("Send mail to " + recipient + " done.");    
    EM_WF_NEXT = "0";
  }
}

/**
 * @method getMailUser
 * Ermittelt zu einem Konfigurationseintrag die eingestellte
 * EMail Adresse.
 * Wenn der Eintrag mit $ELO$ beginnt, wird der folgende Teil als
 * ELO Anwendername verwendet. Daraus wird dann die E-Mail Adresse ausgelesen.
 * Beginnt der Eintrag mit $INDEX$, wird der folgende Teil als
 * Gruppenname der Indexzeile interpretiert. Der Inhalt dieser
 * Indexzeile wird dann als E-Mail Adresse verwendet.
 * Lautet der Eintrag $PARENT$ wird der Eigentümer des Vorgängerknotens
 * als ELO Anwender verwendet. Daraus wird dann die E-Mail Adresse ausgelesen.
 *
 * @param {String} user Kennung für die E-Mail Adresse
 * @returns {String} E-Mail Benutzer
 */
Notify.prototype.getMailUser = function(user) {
  if ((typeof(notifyCallback) == "object") && notifyCallback.getMailUser) {
    var text = notifyCallback.getMailUser(user);
    if (text) {
      return text;
    }
  }

  if (!user) {
    return "";
  }
  
  if (user.startsWith("$ELO$")) {
    var eloUser = user.substring(5);
    user = this.getMailAddress(eloUser);
  } else if (user.startsWith("$INDEX$")) {
    var groupName = user.substring(7);
    user = elo.getIndexValueByName(EM_ACT_SORD, groupName, "");
  } else if (user == "$PARENT$") {
    var eloUser = this.getParentUserName();
    user = this.getMailAddress(eloUser);
  }
  
  return user;
}

/**
 * @method getParent
 * Liefert den Vorgängerknoten des aktuellen Workflow-Knotens.
 * Falls es mehr als ein Vorgänger gibt, wird ein zufälliger
 * Knoten aus der Liste der Vorgänger ausgewählt.
 * 
 * @returns {WFNode} Vorgängerknoten
 */
Notify.prototype.getParent = function() {
  var myNodeId = EM_WF_NODE.nodeId;
  var wfDiagram = ixConnect.ix().checkoutWorkFlow(EM_WF_NODE.flowId, WFTypeC.ACTIVE, WFDiagramC.mbAll, LockC.NO);
  var links = wfDiagram.matrix.assocs;
  for (var i = 0; i < links.length; i++) {
    var link = links[i];
    if (link.nodeTo == myNodeId) {
      var parentNodeId = link.nodeFrom;
      var nodes = wfDiagram.nodes;
      for (var j = 0; j < nodes.length; j++) {
        var node = nodes[j];
        if (node.id == parentNodeId) {
          return node;
        }
      }
    }
  }
  
  return null;
}

/**
 * @method getParentUserName
 * Liefert den Anwender des Vorgängerknotens des aktuellen Workflow Knotens.
 * Falls es mehr als ein Vorgänger gibt, wird ein zufälliger Knoten aus der 
 * Liste der Vorgänger ausgewählt.
 * 
 * @returns {String} Benutzer des Vorgängerknotens
 */
Notify.prototype.getParentUserName = function() {
  var parent = this.getParent();
  return (parent) ? parent.userName : null;
}

/**
 * @method processAllUsers
 * Liest die komplette ELO Anwenderliste aus und prüft für
 * jeden Anwender nach, ob dieser eine Workflow-Überwachung
 * angemeldet hat und führt diese aus.
 *
 * @param {String} replyTo E-Mail Adresse des Empfängers
 * @param {String} subject Betreff der E-Mail
 * @param {Boolean} withGroups Auch Gruppentermine in die Prüfung einbeziehen
 * @param {Boolean} withDeputies Auch Vertretungstermine in die Prüfung einbeziehen
 * @param {Boolean} withIndex Die zu versendende E-Mail kann auch Indexzeilenwerte enthalten
 */
Notify.prototype.processAllUsers = function(replyTo, subject, withGroups, withDeputies, withIndex) {
  var users = ixConnect.ix().checkoutUsers(null, CheckoutUsersC.ALL_USERS_RAW, LockC.NO);

  for (var u = 0; u < users.length; u++) {
    this.processUserItems(users[u].id, replyTo, subject, withGroups, withDeputies, withIndex);
  }
}

/**
 * @method processUserItems
 * Prüft für den angegebenen Benutzer nach, ob dieser eine
 * Workflow-Überwachung angemeldet hat und führt diese aus.
 *
 * @param {String} userId Zu prüfender Benutzer
 * @param {String} replyTo E-Mail Adresse des Empfängers
 * @param {String} subject Betreff der E-Mail
 * @param {Boolean} withGroups Auch Gruppentermine in die Prüfung einbeziehen
 * @param {Boolean} withDeputies Auch Vertretungstermine in die Prüfung einbeziehen
 * @param {Boolean} withIndex Die zu versendende Mail kann auch Indexzeilenwerte enthalten
 */
Notify.prototype.processUserItems = function(userId, replyTo, subject, withGroups, withDeputies, withIndex) {
  log.debug("Check Settings of user: " + userId);
  var ix = ixConnect.ix();
  
  try {
    if (!this.loadReportFlags(userId)) {
      log.debug("EMail report disabled by user option");
      return;
    }
    
    log.debug("Start Process User Items of user: " + userId);
    
    if (!this.withWeekend) {
      var day = new Date().getDay();
      var isWeekend = (day == 6) || (day == 0);
      if (isWeekend) {
        log.debug("Do not send mail at weekend days");
        return;
      }
    }
    
    withGroups = Boolean(withGroups & this.withGroups);
    withDeputies = Boolean(withDeputies & this.withDeputies);
    
    var wfInfo = this.prepareFindInfo(userId, withGroups, withDeputies, withIndex);
    this.startUser(userId, replyTo, subject, withIndex);
    this.prepareTable();
    
    var findResult = ix.findFirstTasks(wfInfo, 1000);
    var index = 0;
    for (;;) {
      var tasks = findResult.tasks;
      log.debug("Found: " + tasks.length);
      for (var i = 0; i < tasks.length; i++) {
        var task = tasks[i];
        if ((typeof(notifyCallback) == "object") && notifyCallback.filterTask) {
          if (!notifyCallback.filterTask(task)) {
            continue;
          }
        }
        
        this.processTask(task);
      }
      
      if (!findResult.moreResults) {
        break;
      }
      
      index += tasks.length;
      findResult = ix.findNextTasks(findResult.searchId, index, 1000);
    }
    
    ix.findClose(findResult.searchId);
    this.finalize();
  } catch(e) {
    log.warn("Error processing Notification List: " + e);
  }
  
  log.debug("End Process User Items");
}

/**
 * @method finalize
 * Schließt die aktuelle Abarbeitung ab.
 */
Notify.prototype.finalize = function() {
  log.debug("Start finalize");
  if ((this.lines.length > 0) || this.sendAlways) {
    log.debug("Lines: " + this.lines.length);
    var text = this.headerPart + this.lines.join("\r\n") + this.footerPart;
    
    var mailAddress = this.getMailAddress(this.userId);
    log.debug("Send to Address: " + mailAddress);
    if (mailAddress) {
      if (this.showMailBody) {
        // only for debugging
        var tempFile = File.createTempFile("wfnotify", ".html");
        FileUtils.writeStringToFile(tempFile, text, "UTF-8");
        Packages.java.awt.Desktop.desktop.open(tempFile);
      }
      
      if ((typeof(notifyCallback) == "object") && notifyCallback.beforeSend) {
        text = notifyCallback.beforeSend(text);
      }

      if (text) {
        log.info("now send mail to " + mailAddress + text);
        mail.sendHtmlMail(this.replyTo, mailAddress, this.subject, text);
      }
    } else {
      log.warn("User request without mail address: " + this.userId);
    }
  }
}

/**
 * @method processTask
 * Arbeitet die angegebene ELO-Aufgabe ab.
 * 
 * @param {UserTask} task ELO-Aufgabe
 */
Notify.prototype.processTask = function(task) {
  var wfNode = task.wfNode;
  log.debug(wfNode.nodeName);
  
  if (this.onlyOnce) {
    var mapid = "NOTIFY_SENT_" + wfNode.nodeId;
    var values = ixConnect.ix().checkoutMap(MapDomainC.DOMAIN_WORKFLOW_ACTIVE, wfNode.flowId, [mapid], LockC.NO);
    if (values && values.items.length > 0) {
      var data = values.items[0].value;  
      if (data == "sent") {
        log.info("Sent entry ignored: " + wfNode.flowId + " - " + wfNode.nodeId);
        return;
      }
    }

    var item = new KeyValue();
    item.key = mapid;
    item.value = "sent";
    ixConnect.ix().checkinMap(MapDomainC.DOMAIN_WORKFLOW_ACTIVE, wfNode.flowId, wfNode.objId, [item], LockC.NO);
  }
  
  var text = this.getTableLine(task);
  text = this.substituteVars(text, task);
  
  this.lines.push(text);
}

/**
 * @method startUser
 * Setzt die angegebenen Benutzereigenschaften.
 * 
 * @param {String} userId Benutzer-ID
 * @param {String} replyTo E-Mail Empfänger
 * @param {String} subject E-Mail Betreff
 * @param {Boolean} withIndex Indexzeilen versenden
 */
Notify.prototype.startUser = function(userId, replyTo, subject, withIndex) {
  this.userId = userId;
  this.replyTo = replyTo;
  this.subject = subject;
  this.withIndex = withIndex;
  this.linePart = null;
  this.lines = new Array();
  this.lineCache = new Object();
}

/**
 * @method prepareFindInfo
 * Erstellt ein Objekt für die Suche nach ELO-Aufgaben.
 * 
 * @param {String} userId Benutzer-ID
 * @param {Boolean} withGroups Inklusive Gruppen
 * @param {Boolean} withDeputies Inklusive Vertretungen
 * @param {Boolean} withIndex Inklusive Indexzeilen
 * @returns {FindTasksInfo} Objekt für die Suche nach Aufgaben
 */
Notify.prototype.prepareFindInfo = function(userId, withGroups, withDeputies, withIndex) {
  var wfInfo = new FindTasksInfo();
  wfInfo.inclDeputy = withDeputies;
  wfInfo.inclGroup = withGroups;
  wfInfo.inclWorkflows = true;
  wfInfo.inclOverTimeForSuperior = true;
  wfInfo.lowestPriority = UserTaskPriorityC.LOWEST;
  wfInfo.highestPriority = UserTaskPriorityC.HIGHEST;
  wfInfo.userIds = [userId];

  if (withIndex) {
    wfInfo.sordZ = SordC.mbAllIndex;
  }
  
  return wfInfo;
}

/**
 * @method substituteVars
 * Ersetzt einige Knoten-Eigenschaften im Text mit den angegebenen Daten.
 * 
 * @param {String} text Text
 * @param {UserTask} task Aufgabe
 * @returns {String} Bearbeiteten Text
 */
Notify.prototype.substituteVars = function(text, task) {
  return this.substituteVars2(text, task.wfNode, task.sord);
}

/**
 * @method substituteVars2
 * Ersetzt einige Knoten-Eigenschaften im Text mit den angegebenen Daten.
 * 
 * @param {String} text Text
 * @param {WFNode} node Workflow-Knoten
 * @param {Sord} sord Metadaten des Eintrags
 * @param {Object} props Properties
 * @returns {String} Bearbeiteten Text
 */
Notify.prototype.substituteVars2 = function(text, node, sord, props) {
  var startDate = this.formatDate(node.activateDateWorkflowIso);
  var timeLimit = this.formatDate(node.timeLimitIso);
  
  text = text.replace("$$nodeName$$", node.nodeName);
  text = text.replace("$$userName$$", node.userName);
  text = text.replace("$$flowName$$", node.flowName);
  text = text.replace("$$flowStatus$$", node.flowStatus);
  text = text.replace("$$activateDate$$", startDate);
  text = text.replace("$$timeLimit$$", timeLimit);
  text = text.replace("$$objName$$", node.objName);

  text = text.replace("$$objGuid$$", node.objGuid);
  text = text.replace("$$objId$$", node.objId);

  if (this.withIndex) {
    if (sord) {
      text = text.replace("$$maskName$$", sord.maskName);

      var sordMask = ixConnect.ix().checkoutDocMask(sord.maskName, DocMaskC.mbAll, LockC.NO);
      var maskLines = sordMask.getLines();
      var objKeys = sord.objKeys;
      
      for (var k = 0; k < objKeys.length; k++) {
        var key = objKeys[k];
        var value = "";
        if (key.data && (key.data.length > 0)) {
          if ((maskLines[key.id]) && (maskLines[key.id].getType() == DocMaskLineC.TYPE_ISO_DATE)) {
	    value = Packages.de.elo.mover.utils.ELOAsDateUtils.displayDateFromIsoWithTime(key.data[0]);
	  } else {
	    value = key.data[0];
          }
        }
        
        text = text.replace("$$ixkey_" + key.id + "$$", value);
        text = text.replace("$$ixgroup_" + key.name + "$$", value);
      }
    }
  }
    
  if (this.isOverTimeLimit(node)) {
    text = text.replace(/\$\$className\$\$/g, "urgent");
  } else if (node.userId != this.userId) {
    text = text.replace(/\$\$className\$\$/g, "group");
  } else {
    text = text.replace(/\$\$className\$\$/g, "normal");
  }
  
  if (props) {
    var allNames = props.propertyNames();    
    while (allNames.hasMoreElements()) {
      var pname = allNames.nextElement();
      var pvalue = props.getProperty(pname);
      
      if (pvalue) {
        text = text.replace("$$param." + pname + "$$", pvalue);
      }
    }
  }
  
  // alle übergebliebenen Platzhalter löschen
  text = text.replace(/\$\$\w+\$\$/g, "");  
  return text;
}

/**
 * @method isOverTimeLimit
 * Meldet zurück, ob der angegebene Workflow-Knoten eine Zeitüberschreitung hat.
 * 
 * @param {WFNode} node Workflow-Knoten
 * @returns {Boolean} Workflow-Knoten hat eine Zeitüberschreitung
 */
Notify.prototype.isOverTimeLimit = function(node) {
  if (node.isOverTimeLimit()) {
    return true;
  }
  
  var esc = node.timeLimitEscalations;
  for (var i = 0; i < esc.length; i++) {
    if (esc[i].isOverTimeLimit()) {
      return true;
    }
  }
  
  return false;
}

/**
 * @method formatDate
 * Formattiert das angegebene ISO-Datum.
 * 
 * @param {String} isoDate ISO-Datum
 * @returns {String} Formattiertes ISO-Datum
 */
Notify.prototype.formatDate = function(isoDate) {
  isoDate = String(isoDate);
  
  if (isoDate.length == 8) {
    return isoDate.substring(6, 8) + "." + isoDate.substring(4, 6) + "." + isoDate.substring(0, 4);
  }

  if (isoDate.length == 14) {
    return isoDate.substring(6, 8) + "." + isoDate.substring(4, 6) + "." + isoDate.substring(0, 4) +
           "  " + isoDate.substring(8, 10) + ":" + isoDate.substring(10, 12) + ":" + isoDate.substring(12);
  }
  
  return isoDate;
}

/**
 * @method getTableLine
 * Liefert die Tabellenzeile für die angegebene ELO-Aufgabe zurück.
 * 
 * @param {Object} task ELO-Aufgabe
 * @returns {Object} Tabellenzeile
 */
Notify.prototype.getTableLine = function(task) {
  if ((typeof(notifyCallback) == "object") && notifyCallback.getTableLine) {
    var line = notifyCallback.getTableLine(task);
    if (line != null) {
      return line;
    }
  }
  
  if (this.withIndex) {
    var sord = task.sord;
    if (sord) {
      var maskName = sord.maskName;
      if (this.lineCache[maskName]) {
        return this.lineCache[maskName];
      }
      
      try {
        var maskTemplate = this.getTemplate(this.templatePath + "_" + maskName);
        this.lineCache[maskName] = maskTemplate;
        return maskTemplate;
      } catch(e) {
        log.debug("No Mask Template found, use default template");
        this.lineCache[maskName] = this.linePart;
      }
    }
  }
  
  return this.linePart;
}

/**
 * @method prepareTable
 * Bereitet eine Tabelle vor.
 */
Notify.prototype.prepareTable = function() {
  var template = this.getTemplate(this.templatePath);
  var splitPos1 = template.indexOf("<!--ListStart-->");
  var splitPos2 = template.indexOf("<!--ListEnd-->");
  
  if ((splitPos1 < 0) || (splitPos2 < 0)) {
    throw "Invalid List Template, start or end position missing";
  }
  
  this.headerPart = template.substring(0, splitPos1);
  this.linePart = template.substring(splitPos1 + 16, splitPos2);
  this.footerPart = template.substring(splitPos2 + 14);
}

/**
 * @method getTemplate
 * Liefert den Template-Inhalt aus dem angegebenen Pfad zurück.
 * 
 * @param {String} templatePath Template-Pfad
 * @returns {String} Template-Inhalt
 */
Notify.prototype.getTemplate = function(templatePath) {
  var editInfo = ixConnect.ix().checkoutSord(templatePath, EditInfoC.mbSordDoc, LockC.NO);
  var url = editInfo.sord.docVersion.url;
  
  var tempFile = File.createTempFile("wfnotifytemplate", ".html");
  ixConnect.download(url, tempFile);
  
  var text = FileUtils.readFileToString(tempFile, "UTF-8");
  tempFile["delete"]();
  
  return String(text);
}

/**
 * @method loadReportFlags
 * Lädt die Benutzer-Flags für den Report für den angegebenen Benutzer.
 * 
 * @param {Number} userId Benutzer-ID
 * @returns {Boolean} Laden der Flags war erfolgreich
 */
Notify.prototype.loadReportFlags = function(userId) {
  this.profileFlags = 0;
  var profile = new UserProfile();
  var key = new KeyValue();
  key.key = this.optionKey;
  profile.options = [key];
  profile.userId = userId;
  
  profile = ixConnect.ix().checkoutUserProfile(profile, LockC.NO);
  
  if (!profile.options || (profile.options.length == 0)) {
    return false;
  }
  
  for (var i = 0; i < profile.options.length; i++) {
    if (profile.options[i].key == this.optionKey) {
      var opt = Number(profile.options[i].value);
      
      this.enableMail = (opt & 1) != 0;
      this.sendAlways = (opt & 2) != 0;
      this.withGroups = (opt & 4) != 0;
      this.withDeputies = (opt & 8) != 0;
      this.withWeekend = (opt & 16) != 0;
      this.onlyOnce = (opt & 32) != 0;
      
      return this.enableMail;
    }
  }
  
  return false;
}

/**
 * @method getMailAddress
 * Liest die konfigurierte E-Mail Adresse eines ELO-Benutzers aus.
 *
 * @param {String} userId ID des Benutzers
 * @returns {String} E-Mail Adresse des Benutzers
 */
Notify.prototype.getMailAddress = function(userId) {
  var users = ixConnect.ix().checkoutUsers([userId], CheckoutUsersC.BY_IDS, LockC.NO);
  return users[0].userProps[1];
}

/**
 * @method getProperties
 * Erzeugt aus einem String ein Java "Properties"-Objekt. Dieses
 * enthält Schlüssel-Wert Paare mit Konfigurationsdaten.
 *
 * @param {String} description Text der Properties, z.B. aus dem Memo Text
 * @returns {Properties} "Properties"-Objekt
 */
Notify.prototype.getProperties = function(description) {
  var reader = new Packages.java.io.StringReader(description);
  var props = new Packages.java.util.Properties();
  props.load(reader);
  return props;
}




//JavaScript Template: notifyCallback

/**
 * @class NotifyCallback
 */
function NotifyCallback() {
}

var notifyCallback = new NotifyCallback();

/**
 * @method filterTask
 * Meldet zurück, ob die angegebene Aufgabe die Filterkriterien erfüllt.
 * 
 * @param {Object} task Aufgabe
 * @returns {Boolean} Aufgabe erfüllt die Filterkriterien
 */
NotifyCallback.prototype.filterTask = function(task) {
  return true;
}

/**
 * @method beforeSend
 * Diese Funktion wird vor dem Versenden der E-Mail ausgeführt.
 * 
 * @param {String} text Ursprünglicher Text
 * @returns {String} Angepassten Text
 */
NotifyCallback.prototype.beforeSend = function(text) {
  return text;
}

/**
 * @method getTableLine
 * Liefert eine Tabellenzeile zurück.
 * 
 * @param {Object} task Aufgabe
 * @returns {Object} Tabellenzeile
 */
NotifyCallback.prototype.getTableLine = function(task) {
  return null;
}

/**
 * @method getMailUser
 * Liefert den E-Mail Benutzer zurück.
 * 
 * @param {String} userName Benutzername
 * @returns {Object} E-Mail Benutzer
 */
NotifyCallback.prototype.getMailUser = function(userName) {
  return null;
}

/**
 * @method formatMessage
 * Liefert die formattierte Nachricht zurück.
 * 
 * @param {Object} template Vorlage
 * @param {WFNode} node Workflow-Knoten
 * @param {Sord} sord Metadaten des Eintrags
 * @param {Properties} properties Formattierungsangaben
 * @returns {String} Formattierte Nachricht
 */
NotifyCallback.prototype.formatMessage = function(template, node, sord, properties) {
  return null;
}

/**
 * @method getSubject
 * Liefert den Betreff aus den angegebenen Daten zurück.
 * 
 * @param {WFNode} node Workflow-Knoten
 * @param {Sord} sord Metadaten des Eintrags
 * @param {Properties} properties Weitere Angaben
 * @returns {String} Betreff
 */
NotifyCallback.prototype.getSubject = function(node, sord, properties) {
  return null;
}





//JavaScript Template: run
// start namespace run

/**
 * @class run
 * @singleton
 */
var run = new Object();
run = {

  /**
   * Führt den angegebenen Befehl (das externe Programm) aus.
   * 
   * @param {String} command Auszuführender Befehl
   */
  execute: function (command) {
    log.debug("Execute command: " + command);
    var p = Runtime.getRuntime().exec(command);
    p.waitFor();
    log.debug("Done.");
  },

  /**
   * Liefert den freien Speicher zurück.
   *  
   * @returns {Number} freier Speicher
   */
  freeMemory: function () {
    return Runtime.getRuntime().freeMemory();
  },

  /**
   * Liefert den maximal verfügbaren Speicher zurück.
   * 
   * @returns {Number} verfügbarer Speicher
   */
  maxMemory: function () {
    return Runtime.getRuntime().maxMemory();
  }

} // end of namespace run



//JavaScript Template: tfer
// start namespace tfer
function TfReference(parentGuid, objectGuid, deleted) {
  this.jsonClass = "TfReference";
  this.parentGuid = String(parentGuid);
  this.objectGuid = String(objectGuid);
  this.deleted = deleted;
}

TfReference.prototype.fillup = function(reference) {
}

function TfUserOptions(options) {
  this.items = new Array();
  if (!options) {
    return;
  }
  
  for (var i = 0; i < options.length; i++) {
    var opt = String(options[i].key) + "¶" + String(options[i].value);
    this.items.push(opt);
  }
}

TfUserOptions.prototype.fillup = function(options) {
  for (var i = 0; i < this.items.length; i++) {
    var item = this.items[i];
    var pos = item.indexOf("¶");
    if (pos > 0) {
      var key = item.substring(0, pos);
      var value = item.substring(pos + 1);
      var kv = new KeyValue(key, value);
      options.push(kv);
    }
  }
}

function TfMapData(mapData, objGuid) {
  this.jsonClass = "TfMapData";
  this.id = Number(mapData.id);
  this.name = String(mapData.domainName);
  this.guid = String(mapData.guid);
  this.objId = Number(mapData.objId);
  this.objGuid = String(objGuid);
  
  this.items = new Array();
  var it = mapData.items;
  for (var i = 0; i < it.length; i++) {
    var mapItem = it[i];
    var item = new Object();
    item.key = String(mapItem.key);
    item.value = String(mapItem.value);
    this.items.push(item);
  }
  
  if (EM_EventsI && (typeof EM_EventsI.tferMapWrite == "function")) {
    EM_EventsI.tferMapWrite(this, mapData);
  }
}

TfMapData.prototype.fillup = function(mapData) {
  mapData.id = this.id;
  mapData.domainName = this.name;
  mapData.guid = this.guid;
  mapData.objId = this.objId;
  
  var cnt = this.items.length;
  result = new Array(cnt);
  for (var i = 0; i < cnt; i++) {
    var item = this.items[i];
    var kv = new KeyValue(item.key, item.value);
    result[i] = kv;
  }
  
  mapData.setItems(result);
  
  if (EM_EventsI && (typeof EM_EventsI.tferMapFillup == "function")) {
    EM_EventsI.tferMapFillup(wfDiagram, this, translator);
  }
}

function TfWorkflow(wfDiagram, translator) {
  this.jsonClass = "TfWorkflow";
  this.id = Number(wfDiagram.id);
  this.name = String(wfDiagram.name);
  this.guid = String(wfDiagram.guid);
  
  this.aclItems = new TfObjAcls(wfDiagram.aclItems);
  this.completionDateIso = String(wfDiagram.completionDateIso);
  this.deleted = Boolean(wfDiagram.deleted);
  this.flags = Number(wfDiagram.flags);
  this.objType = Number(wfDiagram.objType);
  this.overTimeLimit = Boolean(wfDiagram.overTimeLimit);
  this.ownerGuid = translator.fromId(Number(wfDiagram.ownerId)).guid;
  log.info("export: " + this.ownerGuid + " : " + wfDiagram.ownerId);
  this.prio = Number(wfDiagram.prio);
  this.processOnServerId = String(wfDiagram.processOnServerId);
  this.startDateIso = String(wfDiagram.startDateIso);
  this.timeLimitIso = String(wfDiagram.timeLimitIso);
  this.timeLimitUserName = String(wfDiagram.timeLimitUserName);
  
  this.matrix = new TfWfMatrix(wfDiagram.matrix);
  this.nodes = new TfWfNodes(wfDiagram.nodes, translator);
  this.timeLimitEscalations = new TfWfTimeLimits(wfDiagram.timeLimitEscalations);
  
  if (EM_EventsI && (typeof EM_EventsI.tferWorkflowWrite == "function")) {
    EM_EventsI.tferWorkflowWrite(this, wfDiagram, translator);
  }
}

TfWorkflow.prototype.fillup = function(wfDiagram, translator) {
  wfDiagram.name = this.name;
  wfDiagram.guid = this.guid;
  
  wfDiagram.completionDateIso = this.completionDateIso;
  wfDiagram.deleted = this.deleted;
  wfDiagram.flags = this.flags;
  wfDiagram.objType = this.objType;
  wfDiagram.overTimeLimit = this.overTimeLimit;
  wfDiagram.ownerId = translator.fromGuid(this.ownerGuid).id;
  log.info("import: " + this.ownerGuid + " : " + wfDiagram.ownerId);
  wfDiagram.prio = this.prio;
  wfDiagram.processOnServerId = this.processOnServerId;
  wfDiagram.startDateIso = this.startDateIso;
  wfDiagram.timeLimitIso = this.timeLimitIso;
  wfDiagram.timeLimitUserName = this.timeLimitUserName;
  wfDiagram.timeLimitUserId = -1;
  
  var objAcls = new Array();
  var jAcls = this.aclItems;
  jAcls.fillup = TfObjAcls.prototype.fillup;
  jAcls.fillup(objAcls);
  wfDiagram.aclItems = objAcls;
  
  var matrix = new WFNodeMatrix();
  var jmatrix = this.matrix;
  jmatrix.fillup = TfWfMatrix.prototype.fillup;
  jmatrix.fillup(matrix);
  wfDiagram.matrix = matrix;
  
  var nodes = new Array();
  var jnodes = this.nodes;
  jnodes.fillup = TfWfNodes.prototype.fillup;
  jnodes.fillup(nodes, translator);
  wfDiagram.nodes = nodes;
  
  var timeLimits = new Array();
  var jtimeLimits = this.timeLimitEscalations;
  jtimeLimits.fillup = TfWfTimeLimits.prototype.fillup;
  jtimeLimits.fillup(timeLimits);
  wfDiagram.timeLimitEscalations = timeLimits;
  
  if (EM_EventsI && (typeof EM_EventsI.tferWorkflowFillup == "function")) {
    EM_EventsI.tferWorkflowFillup(wfDiagram, this, translator);
  }
}

function TfWfNodes(nodes, translator) {
  var result = new Array();
  if (!nodes) {
    return result;
  }
  
  for (var i = 0; i < nodes.length; i++) {
    var jnode = new TfWfNode(nodes[i], translator);
    result.push(jnode);
  }
  
  return result;
}

TfWfNodes.prototype.fillup = function(nodes, translator) {
  for (var i = 0; i < this.length; i++) {
    var node = new WFNode();
    var jnode = this[i];
    jnode.fillup = TfWfNode.prototype.fillup;
    jnode.fillup(node, translator);
    nodes.push(node);
  }
}

function TfWfNode(node, translator) {
  this.id = Number(node.id);
  this.name = String(node.name);
  
  this.allowActivate = Boolean(node.allowActivate);
  this.comment = String(node.comment);
  this.delayDateIso = String(node.delayDateIso);
  this.delayDays = Number(node.delayDays);
  this.userGuid = translator.fromId(Number(node.userId)).guid;
  this.department2Guid = translator.fromId(Number(node.department2)).guid;
  this.designDepartmentGuid = translator.fromId(Number(node.designDepartment)).guid;
  this.enterDateIso = String(node.enterDateIso);
  this.exitDateIso = String(node.exitDateIso);
  this.flags = Number(node.flags);
  this.formSpec = String(node.formSpec);
  this.iconId = String(node.iconId);
  this.inUseDateIso = String(node.inUseDateIso);
  this.isNext = Number(node.isNext);
  this.label = String(node.label);
  this.labelTranslationKey = String(node.labelTranslationKey);
  this.moveCyclePosX = Number(node.moveCyclePosX);
  this.nameTranslationKey = String(node.nameTranslationKey);
  this.nbOfDonesToExit = Number(node.nbOfDonesToExit);
  this.onEnter = String(node.onEnter);
  this.onExit = String(node.onExit);
  this.overTimeLimit = Boolean(node.overTimeLimit);
  this.posX = Number(node.posX);
  this.posY = Number(node.posY);
  this.processOnServerId = String(node.processOnServerId);
  this.timeLimit = String(node.timeLimit);
  this.timeLimitIso = String(node.timeLimitIso);
  this.type = Number(node.type);
  this.userDelayDateIso = String(node.userDelayDateIso);
  this.yesNoCondition = String(node.yesNoCondition);
  
  this.scriptNames = new TfStringArray(node.scriptNames);
  this.objKeyNames = new TfStringArray(node.objKeyNames);
  this.timeLimitEscalations = new TfWfTimeLimits(node.timeLimitEscalations);
}

TfWfNode.prototype.fillup = function(node, translator) {
  node.id = this.id;
  node.name = this.name;
  
  node.allowActivate = this.allowActivate;
  node.comment = this.comment;
  node.delayDateIso = this.delayDateIso;
  node.delayDays = this.delayDays;
  node.userId = translator.fromGuid(this.userGuid).id;
  node.department2 = translator.fromGuid(this.department2Guid).id;
  node.designDepartment = translator.fromGuid(this.designDepartmentGuid).id;
  node.enterDateIso = this.enterDateIso;
  node.exitDateIso = this.exitDateIso;
  node.flags = this.flags;
  node.formSpec = this.formSpec;
  node.iconId = this.iconId;
  node.inUseDateIso = this.inUseDateIso;
  node.isNext = this.isNext;
  node.label = this.label;
  node.labelTranslationKey = this.labelTranslationKey;
  node.moveCyclePosX = this.moveCyclePosX;
  node.nameTranslationKey = this.nameTranslationKey;
  node.nbOfDonesToExit = this.nbOfDonesToExit;
  node.onEnter = this.onEnter;
  node.onExit = this.onExit;
  node.overTimeLimit = this.overTimeLimit;
  node.posX = this.posX;
  node.posY = this.posY;
  node.processOnServerId = this.processOnServerId;
  node.timeLimit = this.timeLimit;
  node.timeLimitIso = this.timeLimitIso;
  node.type = this.type;
  node.userDelayDateIso = this.userDelayDateIso;
  node.yesNoCondition = this.yesNoCondition;
  
  node.scriptNames = this.scriptNames;
  node.objKeyNames = this.objKeyNames;
  
  var timeLimits = new Array();
  var jtimeLimits = this.timeLimitEscalations;
  jtimeLimits.fillup = TfWfTimeLimits.prototype.fillup;
  jtimeLimits.fillup(timeLimits);
  node.timeLimitEscalations = timeLimits;
}

function TfStringArray(strings) {
  var result = new Array();
  if (!strings) {
    return result;
  }
  
  for (var i = 0; i < strings.length; i++) {
    result.push(String(strings[i]));
  }
  return result;
}

function TfWfTimeLimits(limits) {
  var result = new Array();
  if (!limits) {
    return result;
  }
  
  for (var i = 0; i < limits.length; i++) {
    var jlimit = new TfWfTimeLimit(limits[i]);
    result.push(jlimit);
  }
  
  return result;
}

TfWfTimeLimits.prototype.fillup = function(limits) {
  for (var i = 0; i < this.length; i++) {
    var jlimit = this[i];
    jlimit.fillup = TfWfTimeLimit.prototype.fillup;
    var limit = new WFTimeLimit();
    jlimit.fillup(limit);
    limits.push(limit);
  }
}

function TfWfTimeLimit(limit) {
  this.overTimeLimit = Boolean(limit.overTimeLimit);
  this.timeLimit = Number(limit.timeLimit);
  this.timeLimitIso = String(limit.timeLimitIso);
  this.userName = String(limit.userName);
}

TfWfTimeLimit.prototype.fillup = function(limit) {
  limit.overTimeLimit = this.overTimeLimit;
  limit.timeLimit = this.timeLimit;
  limit.timeLimitIso = this.timeLimitIso;
  limit.userName = this.userName;
  limit.userId = -1;
}
  
function TfWfMatrix(matrix) {
  var assocs = matrix.assocs;
  var result = new Array();
  if (!assocs) {
    return result;
  }
  
  
  for (var i = 0; i < assocs.length; i++) {
    var jassoc = new TfWfAssoc(assocs[i]);
    result.push(jassoc);
  }
  
  return result;
}

TfWfMatrix.prototype.fillup = function(matrix) {
  var assocs = new Array();
  
  for (var i = 0; i < this.length; i++) {
    var assoc = new WFNodeAssoc();
    var jassoc = this[i];
    jassoc.fillup = TfWfAssoc.prototype.fillup;
    jassoc.fillup(assoc);
    assocs.push(assoc);
  }
  
  matrix.assocs = assocs;
}

function TfWfAssoc(assoc) {
  this.done = Boolean(assoc.done);
  this.nodeFrom = Number(assoc.nodeFrom);
  this.nodeTo = Number(assoc.nodeTo);
  this.type = Number(assoc.type);
}

TfWfAssoc.prototype.fillup = function(assoc) {
  assoc.done = this.done;
  assoc.nodeFrom = this.nodeFrom;
  assoc.nodeTo = this.nodeTo;
  assoc.type = this.type;
}

function TfMask(docMask, workflowTranslator, keywordsProvider) {
  this.jsonClass = "TfMask";
  this.id = Number(docMask.id);
  this.name = String(docMask.name);
  this.guid = String(docMask.guid);
  
  this.barcode = String(docMask.barcode);
  this.kind = Number(docMask.DKind);
  this.path = Number(docMask.DPath);
  this.flowName = workflowTranslator.nameFromId(docMask.flowId);
  this.flowName2 = workflowTranslator.nameFromId(docMask.flowId2);
  this.index = String(docMask.index);
  this.lifetime = String(docMask.lifetime);
  this.nameTranslationKey = String(docMask.nameTranslationKey);
  this.textTranslationKey = String(docMask.textTranslationKey);
  this.text = String(docMask.text);  

  this.aclItems = new TfObjAcls(docMask.aclItems);
  this.docAclItems = new TfObjAcls(docMask.docAclItems);

  var det = docMask.details;
  var jdet = new Object();
  jdet.archivingMode = Number(det.archivingMode);
  jdet.createIndexPath = Boolean(det.createIndexPath);
  jdet.createIndexReferencesPaths = Boolean(det.createIndexReferencesPaths);
  jdet.documentMask = Boolean(det.documentMask);
  jdet.folderMask = Boolean(det.folderMask);
  jdet.searchMask = Boolean(det.searchMask);
  jdet.encryptionSet = Number(det.encryptionSet);
  jdet.fulltext = Boolean(det.fulltext);
  jdet.releaseDocument = Boolean(det.releaseDocument);
  jdet.sortOrder = Number(det.sortOrder);
  this.details = jdet;
  
  this.lines = new TfMaskLines(docMask.lines, keywordsProvider);  
}

TfMask.prototype.fillup = function(docMask, workflowTranslator, keywordsProvider) {
  docMask.name = this.name;
  docMask.guid = this.guid;
  
  docMask.barcode = this.barcode;
  docMask.DKind = this.kind;
  docMask.DPath = this.path;
  docMask.flowId = workflowTranslator.idFromName(this.flowName);
  docMask.flowId2 = workflowTranslator.idFromName(this.flowName2);
  docMask.index = this.index;
  docMask.lifetime = this.lifetime;
  docMask.nameTranslationKey = this.nameTranslationKey;
  docMask.textTranslationKey = this.textTranslationKey;
  docMask.text = this.text;

  var objAcls = new Array();
  var jAcls = this.aclItems;
  jAcls.fillup = TfObjAcls.prototype.fillup;
  jAcls.fillup(objAcls);
  docMask.aclItems = objAcls;
  var objDAcls = new Array();
  var jDAcls = this.docAclItems;
  jDAcls.fillup = TfObjAcls.prototype.fillup;
  jDAcls.fillup(objDAcls);
  docMask.docAclItems = objDAcls;

  var det = new DocMaskDetails();
  var jdet = this.details;
  det.archivingMode = jdet.archivingMode;
  det.createIndexPath = jdet.createIndexPath;
  det.createIndexReferencesPaths = jdet.createIndexReferencesPaths;
  det.documentMask = jdet.documentMask;
  det.encryptionSet = jdet.encryptionSet;
  det.folderMask = jdet.folderMask;
  det.fulltext = jdet.fulltext;
  det.releaseDocument = jdet.releaseDocument;
  det.searchMask = jdet.searchMask;
  det.sortOrder = jdet.sortOrder;
  docMask.details = det;
  
  var lines = new Array();
  var jlines = this.lines;
  jlines.fillup = TfMaskLines.prototype.fillup;
  jlines.fillup(lines, keywordsProvider);
  docMask.lines = lines;
}

function TfMaskLines(lines, keywordsProvider) {
  var jlines = new Array();
  
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    var jline = new TfMaskLine(line, keywordsProvider);
    jlines.push(jline);
  }
  
  return jlines;
}

TfMaskLines.prototype.fillup = function(lines, keywordsProvider) {
  for (var i = 0; i < this.length; i++) {
    var line = new DocMaskLine();
    var jline = this[i];
    jline.fillup = TfMaskLine.prototype.fillup;
    jline.fillup(line, keywordsProvider);
    lines.push(line);
  }
}

function TfMaskLine(line, keywordsProvider) {
  this.id = Number(line.id);
  this.name = String(line.name);
  
  this.access = Number(line.access);
  this.canEdit = Boolean(line.canEdit);
  this.comment = String(line.comment);
  this.commentTranslationKey = String(line.commentTranslationKey);
  this.defaultValue = String(line.defaultValue);
  this.disableWordWheel = Boolean(line.disableWordWheel);
  this.editCol = Number(line.editCol);
  this.editRow = Number(line.editRow);
  this.editWidth = Number(line.editWidth);
  this.externalData = String(line.externalData);
  this.hidden = Boolean(line.hidden);
  this.important = Boolean(line.important);
  this.inherit = Boolean(line.inherit);
  this.inheritFromParent = Boolean(line.inheritFromParent);
  this.key = String(line.key);
  this.labelCol = Number(line.labelCol);
  this.labelRow = Number(line.labelRow);
  this.max = Number(line.max);
  this.min = Number(line.min);
  this.nameTranslationKey = String(line.nameTranslationKey);
  this.nextTab = Boolean(line.nextTab);
  this.onlyBuzzwords = Boolean(line.onlyBuzzwords);
  this.postfixAsterix = Boolean(line.postfixAsterix);
  this.prefixAsterix = Boolean(line.prefixAsterix);
  this.readOnly = Boolean(line.readOnly);
  this.serverScriptName = String(line.serverScriptName);
  this.tabIndex = Number(line.tabIndex);
  this.tabOrder = Number(line.tabOrder);
  this.translate = Boolean(line.translate);
  this.lineType = Number(line.type);
  this.version = Boolean(line.version);
  
  this.aclItems = new TfObjAcls(line.aclItems);
  
  this.keywords = new TfKeywords(this.key, keywordsProvider);
}

TfMaskLine.prototype.fillup = function(line, keywordsProvider) {
  line.id = this.id;
  line.name = this.name;
  
  line.access = this.access;
  line.canEdit = this.canEdit;
  line.comment = this.comment;
  line.commentTranslationKey = this.commentTranslationKey;
  line.defaultValue = this.defaultValue;
  line.disableWordWheel = this.disableWordWheel;
  line.editCol = this.editCol;
  line.editRow = this.editRow;
  line.editWidth = this.editWidth;
  line.externalData = this.externalData;
  line.hidden = this.hidden;
  line.important = this.important;
  line.inherit = this.inherit;
  line.inheritFromParent = this.inheritFromParent;
  line.key = this.key;
  line.labelCol = this.labelCol;
  line.labelRow = this.labelRow;
  line.max = this.max;
  line.min = this.min;
  line.nameTranslationKey = this.nameTranslationKey;
  line.nextTab = this.nextTab;
  line.onlyBuzzwords = this.onlyBuzzwords;
  line.postfixAsterix = this.postfixAsterix;
  line.prefixAsterix = this.prefixAsterix;
  line.readOnly = this.readOnly;
  line.serverScriptName = this.serverScriptName;
  line.tabIndex = this.tabIndex;
  line.tabOrder = this.tabOrder;
  line.translate = this.translate;
  line.type = this.lineType;
  line.version = this.version;
  
  var objAcls = new Array();
  var jAcls = this.aclItems;
  jAcls.fillup = TfObjAcls.prototype.fillup;
  jAcls.fillup(objAcls);
  line.aclItems = objAcls;
  
  var keywordList = new KeywordList();
  var jKeys = this.keywords;
  jKeys.fillup = TfKeywords.prototype.fillup;
  jKeys.fillupChildren = TfKeywords.prototype.fillupChildren;
  jKeys.fillup(keywordList);
  if (keywordList.id != "") {
    keywordsProvider.saveList(keywordList);
  }
}

function TfKeywords(name, keywordsProvider) {
  var list = keywordsProvider.getList(name);
  if (!list) {
    return;
  }
  
  this.name = String(list.id);
  this.guid = String(list.guid);
  
  // work around um Indexserver Bug: wenn über die GUID eingelesen wird,
  // dann wird das GUID Feld nicht gesetzt.
  if (this.guid == "") {
    this.guid = name;
  }
  // End work around
  
  this.jsonClass = "TfKeywords";
  this.children = this.listChildren(list.children);
}

TfKeywords.prototype.listChildren = function(childList) {
  var result = new Array();
  
  if (!childList) {
    return result;
  }
  
  for (var i = 0; i < childList.length; i++) {
    var item = childList[i];
    var jitem = new Object();
    jitem.add = Boolean(item.add);
    jitem.enabled = Boolean(item.enabled);
    jitem.id = String(item.id);
    jitem.raw = Boolean(item.raw);
    jitem.text = String(item.text);
    
    jitem.children = this.listChildren(item.children);
    result.push(jitem);
  }
  
  return result;
}

TfKeywords.prototype.fillup = function(keywords) {
  if (!this.name) {
    return;
  }
  
  keywords.id = this.name;
  keywords.guid = this.guid;
  
  var childList = this.fillupChildren(this.children);
  if (childList) {
    keywords.children = childList;
  }
}

TfKeywords.prototype.fillupChildren = function(children) {
  if (!children || (children.length == 0)) {
    return null;
  }
  
  var childList = new Array();
  for (var i = 0; i < children.length; i++) {
    var child = children[i];
    var item = new Keyword();
    item.add = child.add;
    item.enabled = child.enabled;
    item.id = child.id;
    item.raw = child.raw;
    item.text = child.text;
    item.children = this.fillupChildren(child.children);
    childList.push(item);
  }
  
  return childList;
}

function TfSord(sord, userTranslator, guidProvider) {
  this.jsonClass = "TfSord";
  this.id = Number(sord.id);
  this.name = String(sord.name);
  this.guid = String(sord.guid);

  this.childCount = Number(sord.childCount);
  this.delDateIso = String(sord.delDateIso);
  this.deleted = Boolean(sord.deleted);
  this.details = new TfSordDetails(sord.details);
  this.IDateIso = String(sord.IDateIso);
  this.kind = Number(sord.kind);
  this.maskName = String(sord.maskName);
  this.parentGuid = guidProvider.guidFromId(sord.parentId);
  this.ownerGuid = userTranslator.fromId(sord.ownerId).guid;
  this.type = Number(sord.type);
  this.XDateIso = String(sord.XDateIso);

  var objKeys = sord.objKeys;
  var jKeys = new Array();
  for (var k = 0; k < objKeys.length; k++) {
    jKeys.push(new TfObjKey(objKeys[k]));
  }
  this.objKeys = jKeys;

  this.aclItems = new TfObjAcls(sord.aclItems);
  
  this.desc = String(sord.desc);
  this.hiddenText = String(sord.hiddenText);
  
  if (EM_EventsI && (typeof EM_EventsI.tferSordWrite == "function")) {
    EM_EventsI.tferSordWrite(this, sord, userTranslator, guidProvider);
  }
}

TfSord.prototype.fillup = function(sord, userTranslator) {
  sord.name = this.name;
  sord.guid = this.guid;
  
  sord.childCount = this.childCount;
  sord.delDateIso = this.delDateIso;
  sord.deleted = Boolean(this.deleted);
  sord.IDateIso = this.IDateIso;
  sord.kind = this.kind;
  sord.maskName = this.maskName;
  sord.ownerId = userTranslator.fromGuid(this.ownerGuid).id;
  sord.type = this.type;
  sord.XDateIso = this.XDateIso;

  var jdetails = this.details;
  var details = new SordDetails();
  jdetails.fillup = TfSordDetails.prototype.fillup;
  jdetails.fillup(details);
  sord.details = details;
  
  var keys = this.objKeys;
  var objKeys = new Array();
  for (var k = 0; k < keys.length; k++) {
    var key = keys[k];
    key.fillup = TfObjKey.prototype.fillup;
    var newKey = new ObjKey();
    key.fillup(this.id, newKey);

    objKeys.push(newKey);
  }
  sord.objKeys = objKeys;

  var objAcls = new Array();
  var jAcls = this.aclItems;
  jAcls.fillup = TfObjAcls.prototype.fillup;
  jAcls.fillup(objAcls);
  sord.aclItems = objAcls;
  
  sord.desc = this.desc;
  sord.hiddenText = this.hiddenText;
  
  if (EM_EventsI && (typeof EM_EventsI.tferSordFillup == "function")) {
    EM_EventsI.tferSordFillup(sord, this, userTranslator);
  }
}

function TfSordDetails(details) {
  this.archivingMode = Number(details.archivingMode);
  this.arcReplEnabled = Boolean(details.arcReplEnabled);
  this.encryptionSet = Number(details.encryptionSet);
  this.fulltext = Boolean(details.fulltext);
  this.replRoot = Boolean(details.replRoot);
  this.sortOrder = Number(details.sortOrder);
  this.translateSordName = Boolean(details.translateSordName);
}

TfSordDetails.prototype.fillup = function(details) {
  details.archivingMode = this.archivingMode;
  details.arcReplEnabled = this.arcReplEnabled;
  details.encryptionSet = this.encryptionSet;
  details.fulltext = this.fulltext;
  details.replRoot = this.replRoot;
  details.sortOrder = this.sortOrder;
  details.translateSordName = this.translateSordName;
}

function TfObjKey(objKey) {
  this.name = String(objKey.name);
  this.id = Number(objKey.id);
  this.data = new Array();

  for (var d = 0; d < objKey.data.length; d++) {
    this.data.push(String(objKey.data[d]));
  }
}

TfObjKey.prototype.fillup = function(objId, objKey) {
  objKey.id = this.id;
  objKey.objId = objId;
  objKey.name = this.name;
  objKey.data = this.data;
}

function TfObjAcls(objAcls) {
  var jAcls = new Array();

  for (var i = 0; i < objAcls.length; i++) {
    jAcls.push(new TfObjAcl(objAcls[i]));
  }

  this.objAcls = jAcls;
}

TfObjAcls.prototype.fillup = function(objAcls) {
  for (var i = 0; i < this.objAcls.length; i++) {
    var acl = this.objAcls[i];
    var newAcl = new AclItem();
    acl.fillup = TfObjAcl.prototype.fillup;
    acl.fillup(newAcl);

    objAcls.push(newAcl);
  }
}

function TfObjAcl(objAcl) {
  this.access = Number(objAcl.access);
  this.name = this.getName(objAcl.id, objAcl.name);
  this.type = Number(objAcl.type);

  var groups = new Array();
  var andGroups = objAcl.andGroups;
  if (andGroups) {
    for (var i = 0; i < andGroups.length; i++) {
      groups.push(this.getName(andGroups[i].id, andGroups[i].name));
    }
  }

  this.andGroups = groups;
}

TfObjAcl.prototype.getName = function(id, name) {
  if ((id < 0) || (id == UserInfoC.ID_EVERYONE_GROUP)) {
    return String(id);
  } else {
    return String(name);
  }
}

TfObjAcl.prototype.fillup = function(objAcl) {
  objAcl.access = this.access;
  objAcl.name = this.name;
  objAcl.type = this.type;
  objAcl.id = -1;

  var groups = new Array();

  for (var i = 0; i < this.andGroups.length; i++) {
    var group = new IdName();
    group.name = this.andGroups[i];
    group.id = -1;

    groups.push(group);
  }

  objAcl.andGroups = groups;
}

function TfColors(colorDatas) {
  this.jsonClass = "TfColors";
  var jColor = new Array();
  for (var i = 0; i < colorDatas.length; i++) {
    jColor.push(new TfColor(colorDatas[i]));
  }

  this.colorData = jColor;
}

TfColors.prototype.fillup = function(colorDatas) {
  for (var i = 0; i < this.colorData.length; i++) {
    var data = this.colorData[i];
    data.fillup = TfColor.prototype.fillup;

    col = new ColorData();
    data.fillup(col);
    colorDatas.push(col);
  }
}

function TfColor(colorData) {
  this.id = Number(colorData.id);
  this.name = String(colorData.name);
  this.RGB = Number(colorData.RGB);
  this.guid = String(colorData.guid);
}

TfColor.prototype.fillup = function(colorData) {
  colorData.id = this.id;
  colorData.name = this.name;
  colorData.RGB = this.RGB;
  colorData.guid = this.guid;
}

function TfUser(userInfo, translator) {
  this.jsonClass = "TfUser";
  this.guid = String(userInfo.guid);
  this.name = String(userInfo.name);
  this.id = Number(userInfo.id);
  this.desc = String(userInfo.desc);
  this.flags = Number(userInfo.flags);
  this.flags2 = Number(userInfo.flags2);
  this.lastLoginIso = String(userInfo.lastLoginIso);
  this.parent = translator.fromId(Number(userInfo.parent)).guid;
  this.superiorId = translator.fromId(Number(userInfo.superiorId)).guid;
  this.tStamp = String(userInfo.tStamp);
  this.ugtype = userInfo.type; 

  this.groupList = new Array();
  if (userInfo.groupList != null) {
    for (var i = 0; i < userInfo.groupList.length; i++) {
      var guid = translator.fromId(Number(userInfo.groupList[i])).guid;
      this.groupList.push(guid);
    }
  }

  this.keyList = new Array();
  if (userInfo.keylist != null) {
    for (var i = 0; i < userInfo.keylist.length; i++) {
      this.keyList.push(Number(userInfo.keylist[i]));
    }
  }

  this.userProps = new Array();
  for (var i = 0; i < userInfo.userProps.length; i++) {
    var prop = userInfo.userProps[i];
    this.userProps.push((prop == null) ? "" : String(prop));
  }
  
  if (EM_EventsI && (typeof EM_EventsI.tferUserWrite == "function")) {
    EM_EventsI.tferUserWrite(this, userInfo, translator);
  }
}

TfUser.prototype.fillup = function(userInfo, translator) {
  userInfo.desc = this.desc;
  userInfo.flags = this.flags;
  userInfo.flags2 = this.flags2;
  userInfo.guid = this.guid;
  userInfo.name = this.name;
  userInfo.type = this.ugtype;
  userInfo.lastLoginIso = this.lastLoginIso;
  userInfo.superiorId = translator.fromGuid(this.superiorId).id;
  userInfo.parent = translator.fromGuid(this.parent).id;
  
  var idList = new Array();
  for (var i = 0; i < this.groupList.length; i++) {
    var item = translator.fromGuid(this.groupList[i]);
    if (item.id != -1) {
      idList.push(item.id);
    }
  }
  userInfo.groupList = idList;
  
  userInfo.keylist = this.keyList;
  userInfo.userProps = this.userProps;
  
  if (EM_EventsI && (typeof EM_EventsI.tferUserFillup == "function")) {
    EM_EventsI.tferUserFillup(userInfo, this, translator);
  }
}

function TfKeywordsProvider() {
  this.kwCache = new Object();
}

TfKeywordsProvider.prototype.getList = function(name) {
  var item = this.kwCache[name];
  
  if (!item) {
    try {
      item = ixConnect.ix().checkoutKeywordList(name, KeywordC.mbEdit, 100000, LockC.NO);
    } catch(e) {
      item = null;
    }
    this.kwCache[name] = item;
  }
  
  return item;
}

TfKeywordsProvider.prototype.saveList = function(list) {
  ixConnect.ix().checkinKeywordList(list, LockC.NO);
}

function TfGuidProvider() {
  this.guidCache = new Object();
}

TfGuidProvider.prototype.addGuid = function(id, guid) {
  this.guidCache[id] = guid;
}

TfGuidProvider.prototype.guidFromId = function(id) {
  var guid = this.guidCache[id];
  
  if (!guid) {
    var editInfo = ixConnect.ix().checkoutSord(id, EditInfoC.mbOnlyId, LockC.NO);
    guid = String(editInfo.sord.guid);
    this.guidCache[id] = guid;
  }
  
  return guid;
}

function TfWorkflowTranslator() {
  this.wfCache = new Object();
}

TfWorkflowTranslator.prototype.addItem = function(id, name) {
  this.wfCache[id] = name;
}

TfWorkflowTranslator.prototype.nameFromId = function(id) {
  if (id == -1) {
    return "";
  }
  
  var cache = this.wfCache;
  
  var item = cache[id];
  if (!item) {
    var wf = ixConnect.ix().checkoutWorkflowTemplate(String(id), "", WFDiagramC.mbAll, LockC.NO);
    item = String(wf.name);
    cache[id] = item;
  }
  
  return item;
}

TfWorkflowTranslator.prototype.idFromName = function(name) {
  if (name == "") {
    return -1;
  }
  
  var cache = this.wfCache;
  
  var item = cache[name];
  if (!item) {
    var wf = ixConnect.ix().checkoutWorkflowTemplate(name, "", WFDiagramC.mbAll, LockC.NO);
    item = String(wf.id);
    cache[name] = item;
  }
  
  return item;
}

function TfUserIdTranslator() {
  var users = ixConnect.ix().checkoutUsers(null, CheckoutUsersC.ALL_USERS_AND_GROUPS_RAW , LockC.NO);
  
  var len = users.length;
  var jusers = new Array(len);
  for (var i = 0; i < len; i++) {
    var actUser = users[i];
    var newUser = new Object();
    newUser.id = Number(actUser.id);
    newUser.guid = String(actUser.guid);
    newUser.name = String(actUser.name);
    log.debug("User: " + actUser.id + " : " + actUser.name + " : " + actUser.guid);
    jusers[i] = newUser;
  }
  
  jusers.push( {id: -1, guid:"-1", name:"-1"});
  jusers.push( {id: -2, guid:"-2", name:"-2"});
  jusers.push( {id: -3, guid:"-3", name:"-3"});
  
  this.userCache = jusers;
  this.emptyUser = {id: -1, guid:"", name: ""};
}

TfUserIdTranslator.prototype.addItem = function(uid, uguid, uname) {
  this.userCache.push( {id: uid, guid: uguid, name: uname} );
}

TfUserIdTranslator.prototype.fromGuid = function(guid) {
  var len = this.userCache.length;
  
  for (var i = 0; i < len; i++) {
    if (this.userCache[i].guid == guid) {
      return this.userCache[i];
    }
  }
  
  return this.emptyUser;
}

TfUserIdTranslator.prototype.fromId = function(id) {
  var len = this.userCache.length;
  
  for (var i = 0; i < len; i++) {
    if (this.userCache[i].id == id) {
      return this.userCache[i];
    }
  }
  
  return this.emptyUser;
}

TfUserIdTranslator.prototype.fromName = function(name) {
  var len = this.userCache.length;
  
  for (var i = 0; i < len; i++) {
    if (this.userCache[i].name == name) {
      return this.userCache[i];
    }
  }
  
  return this.emptyUser;
}

// end of namespace tfer



//JavaScript Template: tfex
// start namespace tfex

/**
 * @class tfex
 * @singleton
 */
var tfex = new Object();

tfex = {
  restrictSordsToGroup: null,
  restrictSordsToMasks: new Object(),
  addSordMaps: Boolean,
  
  /**
   * Exportiert die Daten in die angegebene Datei.
   * 
   * @param {Object} parts Export-Teile
   * @param {String} fileName Dateiname
   */
  doExport: function(parts, fileName) {
    var tempName = fileName + ".$$$";
    log.info("Start export to " + tempName);
    var zip = new ZipParts(tempName, ZipParts.ReadWrite.Write);
    
    try {
      this.exportParts(parts, zip);
      log.info("Export completed.");
    } catch(e) {
      log.error("Error writing transfer file: " + e);
      fileName = fileName + "-ERROR-" + fu.fileNameDate(new Date()) + ".zip";
    } finally {
      try {
        zip.close();
      } catch(e) {
        log.error("Error closing export file: " + e);
      }
    }
    
    fu.rename(tempName, fileName, true);
    log.info("Export file available: " + fileName);
  },
  
  /**
   * Exportiert die Workflow-Daten in die angegebene Datei.
   * 
   * @param {Object} wfData Workflow-Daten
   * @param {File} fileName Dateiname
   * @param {Boolean} isReturn Skript vor dem Zurückkehren ausführen
   */
  doWfExport: function(wfData, fileName, isReturn) {
    var restrictToGroup = wfData.restrictGroup;
    var restrictToMasks = wfData.masks;
    
    var tempName = fileName + ".$$$";
    log.info("Start workflow export to " + tempName + ", restrict: " + restrictToGroup);
    
    if (restrictToGroup == "") {
      restrictToGroup = null;
    }
    this.restrictSordsToGroup = restrictToGroup;
    if (restrictToGroup) {
      log.info("Restrict Sord export to Group: " + restrictToGroup);
    }
    this.restrictSordsToMasks = restrictToMasks;
    this.exportMode = wfData.exportMode;
    
    var zip = new ZipParts(tempName, ZipParts.ReadWrite.Write);
    
    try {
      var scriptName = (isReturn) ? wfData.scriptBeforeReturn : wfData.scriptBeforeSend;
      if (scriptName && wftransport[scriptName]) {
        wftransport[scriptName](wfData);
      }
      
      part = JSON.stringify(wfData);
      zip.addUtf8Part(part);
      
      var parts = '[{"type": "sord", "guid": "' + wfData.eloObjGuid +
                  '", "createPath": "ARCPATH:' + wfData.destination + '"}]';
      this.exportParts(parts, zip);
      log.info("Export completed.");
    } catch(e) {
      log.error("Error writing transfer file: " + e);
      fileName = fileName + "-ERROR-" + fu.fileNameDate(new Date()) + ".zip";
    } finally {
      try {
        zip.close();
      } catch(e) {
        log.error("Error closing export file: " + e);
      }
    }
    
    this.restrictSordsToGroup = null;
    fu.rename(tempName, fileName, true);
    log.info("Wf-Export file available: " + fileName);
  },
  
  /**
   * Exportiert die einzelnen Export-Teile in die angegebene Datei.
   * 
   * @param {Object} parts Export-Teile (Befehle)
   * @param {File} zipFile ZIP-Datei
   */
  exportParts: function(parts, zipFile) {
    var userTranslator = new TfUserIdTranslator();
    var workflowTranslator = new TfWorkflowTranslator();
    var keywordsProvider = new TfKeywordsProvider();
    var guidProvider = new TfGuidProvider();
    
    var commands = JSON.parse(parts);
    
    for (var iCmd = 0; iCmd < commands.length; iCmd++) {
      var part;
      var cmd = commands[iCmd];
      var name = cmd.type;
      if (name == "marker") {
        log.info("Export marker, filter: " + cmd.filter);
        var colorInfo = ixConnect.ix().checkoutColors(LockC.NO);
        var jColorInfo = new TfColors(colorInfo);
        part = JSON.stringify(jColorInfo);
      } else if (name == "sord") {
        log.info("Export sord, guid: " + cmd.guid);
        if (!cmd.mode) {
          cmd.mode = 2;
        }
        if (!cmd.levels) {
          cmd.levels = 32;
        }
        cmd.rootNode = true;
        this.exportSords(cmd, zipFile, userTranslator, guidProvider);
        part = undefined;
      } else if (name == "user") {
        log.info("Export user, guid: " + cmd.guid);
        var userInfo = ixConnect.ix().checkoutUsers([cmd.guid], CheckoutUsersC.BY_IDS_RAW, LockC.NO);
        var profile = new UserProfile();
        profile.excludeDefaultValues = true;
        profile.excludeGroupValues = true;
        profile.userId = userInfo[0].id
        var userOptions = ixConnect.ix().checkoutUserProfile(profile, LockC.NO);
        
        var juser = new TfUser(userInfo[0], userTranslator);
        juser.options = new TfUserOptions(userOptions.options);
        
        part = JSON.stringify(juser);
      } else if (name == "mask") {
        log.info("Export mask, guid: " + cmd.guid);
        var mask = ixConnect.ix().checkoutDocMask(cmd.guid, DocMaskC.mbAll, LockC.NO);
        var jmask = new TfMask(mask, workflowTranslator, keywordsProvider);
        part = JSON.stringify(jmask);
      } else if (name == "wftemplate") {
        log.info("Export workflow, guid: " + cmd.guid);
        var flow = ixConnect.ix().checkoutWorkflowTemplate(cmd.guid, null, WFDiagramC.mbAll, LockC.NO);
        var jflow = new TfWorkflow(flow, userTranslator);
        part = JSON.stringify(jflow);
      } else if (name == "keywords") {
        log.info("Export keyword list, guid: " + cmd.guid);
        var jkeywords = new TfKeywords(cmd.guid, keywordsProvider);
        part = JSON.stringify(jkeywords);
      } else {
        log.error("Unknown command: " + name);
        continue;
      }

      if (part) {
        zipFile.addUtf8Part(part);
      }
    }
  },
  
  /**
   * Exportiert die angegebenen "Sord"-Objekte.
   * 
   * @param {String} cmd Befehl
   * @param {File} zipFile ZIP-Datei
   * @param {TfUserIdTranslator} userTranslator UserIdTranslator
   * @param {TfGuidProvider} guidProvider GUID-Provider
   */
  exportSords: function(cmd, zipFile, userTranslator, guidProvider) {
    if (cmd.levels < 1) {
      log.info("Too many nested levels. Recursion stopped.");
      return;
    }
    
    var pendingFile = null;
    var editInfo = ixConnect.ix().checkoutDoc(cmd.guid, null, EditInfoC.mbAll, LockC.NO);
    var sord = editInfo.sord;
    guidProvider.addGuid(String(sord.id), String(sord.guid));
    var found = true;
    var part;
    
    var isReference = cmd.parentObjId && (cmd.parentObjId != sord.parentId);
    log.debug("Process " + sord.id + " - Is Reference: " + isReference);
    
    // Sordmap Einträge mitnehmen?
    this.addSordMaps = (cmd.mode & 8) != 0;
    
    // Referenzen erhalten?
    this.keepRefs = (cmd.mode & 16) != 0;
    
    // Dokumente mit exportieren?
    this.exportMask = cmd.mode & 7;
    
    if (this.restrictSordsToGroup) {
      var aclItems = sord.aclItems;
      found = false;
      for (var i = 0; i < aclItems.length; i++) {
        var item = aclItems[i];
        if ((item.name == this.restrictSordsToGroup) && (!item.andGroups || (item.andGroups.length == 0))) {
          found = true;
          break;
        }
      }
      
      if (!found) {
        log.info("Sord skipped (group): " + sord.id + ": " + sord.name);
        if (this.exportMode != "partial") {
          cmd.createPath = null;
          return;
        }
      }
    }
    
    if (this.restrictSordsToMasks && (this.restrictSordsToMasks.length > 0)) {
      if (!this.restrictSordsToMasks[sord.maskName]) {
        log.info("Sord skipped (mask): " + sord.id + ": " + sord.name);
        found = false;
        if (this.exportMode != "partial") {
          cmd.createPath = null;
          return;
        }
      }
    }
    
    if (found) {
      if (isReference && this.keepRefs) {
        var deleted = true;
        for (var refs = 0; refs < sord.parentIds.length; refs++) {
          if (sord.parentIds[refs] == cmd.parentGuid) {
            deleted = false;
            break;
          }
        }
        
        var jReference = new TfReference(cmd.parentGuid, cmd.guid, deleted);
        part = JSON.stringify(jReference);
        zipFile.addUtf8Part(part);
        return;
      }  
        
      var jsord = new TfSord(sord, userTranslator, guidProvider);
      if (editInfo.document && editInfo.document.docs && (editInfo.document.docs.length > 0)) {
        if (this.exportMask < 2) {
          log.debug("Mode 1: Do not export documents.");
          return;
        }
        
        pendingFile = editInfo.document.docs[0];
        jsord.docExt = String(pendingFile.ext);
      }
      
      if (cmd.createPath) {
        jsord.createPath = cmd.createPath;
        cmd.createPath = null;
      }
      jsord.rootNode = cmd.rootNode;
      
      part = JSON.stringify(jsord);
      zipFile.addUtf8Part(part);
      
      if (pendingFile) {
        // Dokument - Datei rausschreiben
        var temp = File.createTempFile("docfile", "." + pendingFile.ext);
        log.debug("Temp file: " + temp.getAbsolutePath());

        ixConnect.download(pendingFile.url, temp);
        pendingFile = null;
        log.debug("Download done.");
        
        zipFile.addFilePart(temp);
        log.debug("File part added.");
        fu.deleteFile(temp);
      }
      
      if (this.addSordMaps) {
        var map = ixConnect.ix().checkoutMap(MapDomainC.DOMAIN_SORD , sord.id, null, LockC.NO);
        var jmap = new TfMapData(map, sord.guid);
        part = JSON.stringify(jmap);
        zipFile.addUtf8Part(part);
      }
    }
    
    if ((sord.type < 254) && !sord.deleted) {
      // Ordner - Untereinträge rausschreiben
      cmd.rootNode = false;
      
      var findInfo = new FindInfo();
      var findChildren = new FindChildren();
      var findOptions = new Packages.de.elo.ix.client.FindOptions();
      
      findOptions.inclDeleted = true;
      findChildren.parentId = sord.id;
      
      findInfo.findChildren = findChildren;
      findInfo.findOptions = findOptions;
      
      var findResult = ixConnect.ix().findFirstSords(findInfo, 1000, SordC.mbMin);
      ixConnect.ix().findClose(findResult.searchId);
      
      var sords = findResult.sords;
      cmd.levels--;
      for (var i = 0; i < sords.length; i++) {
        cmd.parentObjId = Number(sord.id);
        cmd.parentGuid = String(sord.guid);
        cmd.guid = String(sords[i].guid);
        log.info("Export sord child, guid: " + cmd.guid);
        this.exportSords(cmd, zipFile, userTranslator, guidProvider);
      }
      cmd.levels++;
    }
  }
  
}






//JavaScript Template: tfim
// start namespace tfim

/**
 * @class tfim
 * @singleton
 */
var tfim = new Object();

tfim = {
  pendingFlowData: null,
  importAlways: false,
  pendingRefs: [],
  
  /**
   * Importiert die angegebene Datei (falls die Datei existiert).
   * 
   * @param {String} fileName Dateiname
   */
  checkForImport: function(fileName) {
    var file = new File(fileName);
    if (file.exists()) {
      log.info("Transfer file found: " + fileName);
      var tempName = fileName + "-" + fu.fileNameDate(new Date()) + ".zip";
      fu.rename(fileName, tempName);
      log.info("Process temp file: " + tempName);
      
      try {
        log.info("Start check loop");
        this.doImport(tempName, false, true);
      } catch(e) {
        fu.rename(fileName, fileName + "-ERRORCHECK.zip");
        log.error("Check failed: " + e);
        throw e;
      }
      
      this.clear();
      
      log.info("Start import");
      try {
        this.doImport(tempName, false, false);
        log.info("Import done.");
      } catch(e) {
        log.warn("Abort import with error: " + e);
        fu.rename(fileName, fileName + "-ERROR.zip");
      }
    }
  },
  
  /**
   * Importiert das angegebene Verzeichnis.
   * 
   * @param {String} dirName Verzeichnisname
   */
  checkForImportDir: function(dirName) {
    var dir = new File(dirName);
    var items = dir.list();
    if (!items) {
      // nothing to do
      return;
    }
    
    for (var i = 0; i < items.length; i++) {
      var name = items[i];
      var tempName = dirName + "\\Processing" + name;
      try {
        if (name.startsWith("EX")) {
          fu.rename(dirName + "\\" + name, tempName);
          log.info("Process temp file: " + tempName);
          this.doImport(tempName, false, false);
          fu.deleteFile(new File(tempName));
          log.info("WF-Import done.");
        }
      } catch(e) {
        var errorName = dirName + "\\ERROR_" + name;
        fu.rename(tempName, errorName);
        log.warn("Abort import with error: " + errorName + " : " + e);
      }
    }
  },
  
  /**
   * Führt einen Importvorgang durch.
   * 
   * @param {String} fileName Dateiname
   * @param {Boolean} withDelete Inklusive gelöschte Einträge
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  doImport: function(fileName, withDelete, onlyCheck) {
    var hasError = false;
    var errorMessage;
    
    var zipi = new ZipParts(fileName, ZipParts.ReadWrite.Read);
    this.pendingFlowData = null;
    this.pendingRefs = [];
    
    for (;;) {
      var txt = zipi.getUtf8Part();
      if (txt == null) {
        break;
      }
      
      try {
        this.processPart(zipi, txt, onlyCheck);
      } catch(e) {
        hasError = true;
        errorMessage = e;
        log.error("Error reading transfer file: " + e);
        break;
      }
    }
    
    zipi.close();
    
    if (this.pendingRefs.length > 0) {
      this.addPendingRefs(this.pendingRefs);
    }
    
    if (this.pendingFlowData) {
      var scriptName = this.pendingFlowData.scriptAfterReturn;
      if (scriptName && wftransport[scriptName]) {
        log.debug("callback started: " + scriptName);
        try {
          wftransport[scriptName](this.pendingFlowData);
          log.debug("callback done: " + scriptName);
        } catch(e) {
          log.warn("Error in callback function: " + scriptName);
          hasError = true;
        }
      }

      wf.createOrConfirmFlowFromZip(this.pendingFlowData, hasError, errorMessage);
      log.debug("Workflow started or confirmed.");
    }
    
    if (withDelete && !hasError) {
      var file = new File(fileName);
      fu.deleteFile(file);
    }
    
    if (hasError) {
      throw e;
    }
  },
  
  /**
   * Erstellt die benötigten Referenzen.
   * 
   * @param {Array} refs Liste mit Referenzen
   */
  addPendingRefs: function(refs) {
    for (var i = 0; i < refs.length; i++) {
      var ref = refs[i];
      if (ref.deleted) {
        ixConnect.ix().deleteSord(ref.parentGuid, ref.objectGuid, LockC.NO, null);
      } else {
        ixConnect.ix().refSord(null, ref.parentGuid, ref.objectGuid, -1);
      }
    }
  },
  
  /**
   * Importiert den angegebenen Import-Teil.
   * 
   * @param {ZipParts} zipi Import-Teil
   * @param {Object} part Zu importierender "UTF8"-Teil
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processPart: function(zipi, part, onlyCheck) {
    log.info(((onlyCheck) ? "checkPart" : "processPart: ") + part.substring(0,100));
  
    var jsonObj = JSON.parse(part);
    var jsonClass = jsonObj.jsonClass;
    
    if (EM_EventsI && (typeof EM_EventsI.tfimProcessPartFillup == "function")) {
      EM_EventsI.tfimProcessPartFillup(zipi, jsonClass, onlyCheck, newParentGuids);
    }
  
    if (jsonClass == "TfColors") {
      this.processColors(jsonObj, onlyCheck);
    } else if (jsonClass == "TfSord") {
      this.processSord(zipi, jsonObj, onlyCheck);
    } else if (jsonClass == "TfMask") {
      this.processMask(jsonObj, onlyCheck);
    } else if (jsonClass == "TfWorkflow") {
      this.processWorkflow(jsonObj, onlyCheck);
    } else if (jsonClass == "TfUser") {
      this.processUser(jsonObj, onlyCheck);
    } else if (jsonClass == "TfKeywords") {
      this.processKeywords(jsonObj, onlyCheck);
    } else if (jsonClass == "TfFlowData") {
      this.processFlowData(jsonObj, onlyCheck);
    } else if (jsonClass == "TfMapData") {
      this.processMapData(jsonObj, onlyCheck);
    } else if (jsonClass == "TfReference") {
      this.pendingRefs.push(jsonObj);
    }
  },
  
  /**
   * Importiert die angegebenen Map-Daten.
   * 
   * @param {Object} jmapData Map-Daten
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processMapData: function(jmapData, onlyCheck) {
    if (onlyCheck) {
      
    } else {
      jmapData.fillup = TfMapData.prototype.fillup;
      var mapData = new MapData();
      jmapData.fillup(mapData);
      if (!mapData.guid) {
        log.info("Map import canceled by callback function");
        return;
      }
      
      if (jmapData.objGuid == this.lastWrittenSordGuid) {
        ixConnect.ix().checkinMap(mapData.domainName, this.lastWrittenSordId, this.lastWrittenSordId, mapData.items, LockC.NO);
      } else {
        log.warn("Unrelated MapData ignored. Found: " + mapData.guid + ", expected: " + this.lastWrittenSordGuid);
      }
    }
  },
  
  /**
   * Importiert die angegebenen Workflows.
   * 
   * @param {Object} flowData Workflow-Daten
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processFlowData: function(flowData, onlyCheck) {
    if (onlyCheck) {
    } else {
      this.pendingFlowData = flowData;
    }
  },
  
  /**
   * Importiert den angegebenen Repository-Eintrag.
   * 
   * @param {ZipParts} zipi Import-Teil
   * @param {Object} jsord Metadaten des Eintrags
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processSord: function(zipi, jsord, onlyCheck) {
    if (onlyCheck) {
      var flags = this.getFlags();
      if ((flags & AccessC.FLAG_EDITSTRUCTURE) == 0) {
        throw "Missing Edit Structure Access Right, cannot import folders or documents.";
      }
      
      if (!jsord.rootNode) {
        jsord.parentGuid = this.rootId;
      }
    }
    
    if (!this.translator) {
      this.translator = new TfUserIdTranslator();
    }
    
    var docFile;
    if (jsord.docExt) {
      docFile = File.createTempFile("docfile", "." + jsord.docExt);
      log.debug("Temp file: " + docFile.getAbsolutePath());

      zipi.getFilePart(docFile);
    }

    jsord.fillup = TfSord.prototype.fillup;
    var editInfo;
    try {
      editInfo = ixConnect.ix().checkoutDoc(jsord.guid, null, EditInfoC.mbAll, LockC.NO);
      log.debug("Read existing Sord: " + jsord.guid + " : " + editInfo.sord.name);
      if (onlyCheck && jsord.rootNode) {
        this.rootId = jsord.guid;
        log.info("Root sord loaded: " + jsord.name + " at " + jsord.guid);
      }
    } catch(e) {
      var dest = jsord.parentGuid;
      if (jsord.createPath && (jsord.createPath != "ARCPATH:")) {
        dest = jsord.createPath;
      }
      
      if (onlyCheck) {
        if (jsord.rootNode) {
          this.rootId = dest;
          log.info("Root sord loaded: " + jsord.name + " at " + dest);
        }
        return;
      }
      
      log.info("Create new Sord at " + dest);
      try {
        if (jsord.docExt) {
          editInfo = ixConnect.ix().createDoc(dest, jsord.maskName, null, EditInfoC.mbAll);
        } else {
          editInfo = ixConnect.ix().createSord(dest, jsord.maskName, EditInfoC.mbAll);
        }
      } catch(e) {
        log.info("Cannot create new entry at: " + dest + ", reason: " + e);
        if (this.pendingFlowData) {
          dest = this.pendingFlowData.eloObjGuid;
          if (jsord.docExt) {
            editInfo = ixConnect.ix().createDoc(dest, jsord.maskName, null, EditInfoC.mbAll);
          } else {
            editInfo = ixConnect.ix().createSord(dest, jsord.maskName, EditInfoC.mbAll);
          }
        } else {
          throw(e);
        }
      }
    }
    
    var localDeleted = editInfo.sord.deleted;
    jsord.fillup(editInfo.sord, this.translator);
    var remoteDeleted = editInfo.sord.deleted;
    
    if (!editInfo.sord.guid) {
      log.info("Sord import canceled by callback function");
      return;
    }
    
    if (onlyCheck) {
      if (((editInfo.sord.access & AccessC.LUR_WRITE) == 0) && (editInfo.sord.id != -1)) {
        throw ("Missing write access at object: " + editInfo.sord.name);
      }
      
      if (jsord.docExt) {
      }
    } else {
      if (localDeleted && !remoteDeleted) {
        this.restoreSord(editInfo.sord.guid);
      }
      
      var id = ixConnect.ix().checkinSord(editInfo.sord, SordC.mbAll, LockC.NO);
      log.debug("Sord written: " + id);
      
      this.lastWrittenSordId = id;
      this.lastWrittenSordGuid = editInfo.sord.guid;
      
      editInfo.sord.id = id;
      
      if (jsord.docExt) {
        if (this.checkForMd5Version(editInfo, docFile)) {
          log.info("DocVersion is available, not import needed.");
        } else {
          log.info("Update sord document file: " + jsord.docExt);
          var doc = new Packages.de.elo.ix.client.Document();
          var dv = new DocVersion();
          dv.pathId = editInfo.sord.path;
          dv.ext = jsord.docExt;
          dv.encryptionSet = editInfo.sord.details.encryptionSet;
          doc.docs = [dv];
          doc = ixConnect.ix().checkinDocBegin(doc);
          dv = doc.docs[0];
          var url = dv.url;
          log.debug("Upload file: " + url);
          var uploadResult = ixConnect.upload(url, docFile);
          dv.uploadResult = uploadResult;
          doc = ixConnect.ix().checkinDocEnd(editInfo.sord, SordC.mbAll, doc, LockC.NO);
        }
        
        log.debug("Delete temp file: " + docFile.name);
        fu.deleteFile(docFile);
        log.debug("Update done.");
      }
      
      if (remoteDeleted) {
        this.deleteSord(editInfo.sord.guid);
      }
    }
  },
  
  /**
   * Stellt den angegebenen gelöschten Repository-Eintrag wieder.
   * 
   * @param {String} objid Objekt-ID des Eintrags
   */
  restoreSord: function(objid) {
    var options = new RestoreOptions();
    options.singleObject = false;
    ixConnect.ix().restoreSord(objid, options);
  },
  
  /**
   * Löscht den angegebenen Repository-Eintrag.
   * 
   * @param {String} objid Objekt-ID des Eintrags
   */
  deleteSord: function(objid) {
    ixConnect.ix().deleteSord(null, objid, LockC.NO, null);
  },
  
  /**
   * Überprüft, ob eine Datei mit demselbem MD5-Wert im Repository vorhanden ist.
   * 
   * @param {EditInfo} editInfo Metadaten des Eintrags
   * @param {File} file Datei
   * @returns {Boolean} Datei ist im Repository vorhanden
   */
  checkForMd5Version: function(editInfo, file) {
    if (this.importAlways) {
      log.debug("Import always, no md5 check");
      return false;
    }
    
    try {
      var md5 = ixConnect.getFileMd5(file);
      log.debug("Search for md5 version: " + md5);
      var docs = editInfo.document.docs;
      
      if (docs.length > 0) {
        var doc = docs[0];
        log.debug("Active version, MD: " + doc.md5);
        if (doc.md5 == md5) {
          log.debug("Md5 version found.");
          return true;
        }
      }
    } catch(e) {
      log.info("Error searching md5 Version: " + e);
    }
    
    log.debug("New document: " + editInfo.sord.id);
    return false;
  },
  
  /**
   * Importiert die angegebenen Farben.
   * 
   * @param {Object} jsonObj Objekt für die Farben
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processColors: function(jsonObj, onlyCheck) {
    if (onlyCheck) {
      var flags = this.getFlags();
      if ((flags & AccessC.FLAG_EDITCONFIG) == 0) {
        throw "Missing EditConfig Access Right, cannot import color marker.";
      }
      
      return;
    }
    
    var cols = new Array();
    jsonObj.fillup = TfColors.prototype.fillup;
    jsonObj.fillup(cols);
    
    ixConnect.ix().checkinColors(cols, LockC.NO);
  },
  
  /**
   * Importiert die angegebenen Benutzer.
   * 
   * @param {Object} juser Objekt für die Benutzer
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processUser: function(juser, onlyCheck) {
    var checkOwner = true;
    if (onlyCheck) {
      var flags = this.getFlags();
      if ((flags & AccessC.FLAG_SUBADMIN) == 0) {
        throw "Missing Edit User Access Right, cannot import users or groups.";
      }
      if ((flags & AccessC.FLAG_ADMIN) != 0) {
        checkOwner = false;
      }
    }
    
    if (!this.translator) {
      this.translator = new TfUserIdTranslator();
    }
    
    var user;
    try {
      user = ixConnect.ix().checkoutUsers([juser.guid], CheckoutUsersC.BY_IDS_RAW, LockC.NO)[0];
    } catch(e) {
      user = new Packages.de.elo.ix.client.UserInfo();
      user.id = -1;
    }
    
    juser.fillup = TfUser.prototype.fillup;
    juser.fillup(user, this.translator);
    if (!user.guid) {
      log.info("User import canceled by callback function");
      return;
    }
  
    if (onlyCheck) {
      if (checkOwner) {
        if (user.parent != this.userId) {
          throw "Cannot edit user: " + user.name;
        }
      }
      this.translator.addItem(user.id, user.guid, user.name);
    } else {
      var ids = ixConnect.ix().checkinUsers([user], CheckinUsersC.WRITE, LockC.NO);
      
      var profile = new UserProfile();
      profile.excludeDefaultValues = true;
      profile.excludeGroupValues = true;
      profile.userId = ids[0];
      var items = new Array();
      var joptions = juser.options;
      joptions.fillup = TfUserOptions.prototype.fillup;
      joptions.fillup(items);
      profile.options = items;
      ixConnect.ix().checkinUserProfile(profile, LockC.NO);
      
      this.translator.addItem(ids[0], user.guid, user.name);
    }
  },
  
  /**
   * Importiert die angegebenen Workflows.
   * 
   * @param {Object} jworkflow Workflow-Daten
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processWorkflow: function(jworkflow, onlyCheck) {
    if (onlyCheck) {
      var flags = this.getFlags();
      if ((flags & AccessC.FLAG_EDITWF) == 0) {
        throw "Missing Edit Workflow Access Right, cannot import workflow templates.";
      }
    }

    if (!this.translator) {
      this.translator = new TfUserIdTranslator();
    }
  
    if (!this.wfTranslator) {
      this.wfTranslator = new TfWorkflowTranslator();
    }
    
    var workflow;
    try {
      workflow = ixConnect.ix().checkoutWorkflowTemplate(jworkflow.guid, null, WFDiagramC.mbAll, LockC.NO);
    } catch(e) {
      log.info(e);
      workflow = new WFDiagram();
      workflow.id = -1;
    }
    
    jworkflow.fillup = TfWorkflow.prototype.fillup;
    jworkflow.fillup(workflow, this.translator);
    if (!workflow.guid) {
      log.info("Import canceled by callback function");
      return;
    }
    
    if (onlyCheck) {
      this.wfTranslator.addItem(workflow.id, workflow.name);
    } else {
      ixConnect.ix().checkinWorkflowTemplate(workflow, WFDiagramC.mbAll, LockC.NO);
    }
  },
  
  /**
   * Importiert die angegebenen Stichwortlisten.
   * 
   * @param {Object} jkeywords Objekt für die Stichwortlisten
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processKeywords: function(jkeywords, onlyCheck) {
    if (onlyCheck) {
      return;
    }
    
    if (!this.keywordsProvider) {
      this.keywordsProvider = new TfKeywordsProvider();
    }
    
    var keywords = new KeywordList();
    jkeywords.fillup = TfKeywords.prototype.fillup;
    jkeywords.fillupChildren = TfKeywords.prototype.fillupChildren;
    jkeywords.fillup(keywords);
    if (keywords.id != "") {
      this.keywordsProvider.saveList(keywords);
    }
  },
  
  /**
   * Importiert die angegeben Masken.
   * 
   * @param {Object} jmask Objekt für die Masken
   * @param {Boolean} onlyCheck Nur überprüfen
   */
  processMask: function(jmask, onlyCheck) {
    if (onlyCheck) {
      var flags = this.getFlags();
      if ((flags & AccessC.FLAG_EDITMASK) == 0) {
        throw "Missing Edit Mask Access Right, cannot import masks.";
      }
      
      return;
    }

    if (!this.wfTranslator) {
      this.wfTranslator = new TfWorkflowTranslator();
    }
    
    if (!this.keywordsProvider) {
      this.keywordsProvider = new TfKeywordsProvider();
    }
    
    var mask;
    var id = jmask.guid;
    try {
      log.debug("Try read mask: " + id);
      mask = ixConnect.ix().checkoutDocMask(id, DocMaskC.mbAll, LockC.NO);
      log.debug("Mask found");
    } catch(e) {
      log.info("Create new mask: " + id);
      mask = new DocMask();
      mask.id = -1;
    }
    
    jmask.fillup = TfMask.prototype.fillup;
    jmask.fillup(mask, this.wfTranslator, this.keywordsProvider);
    if (!mask.guid) {
      log.info("Mask import canceled by callback function");
      return;
    }
    
    ixConnect.ix().checkinDocMask(mask, DocMaskC.mbAll, LockC.NO);
    log.debug("Update mask: " + mask.name);
  },
  
  /**
   * Liefert die Benutzer-Flags zurück.
   * 
   * @returns {Number} Benutzer-Flags
   */
  getFlags: function() {
    if (!this.flags) {
      this.flags = ixConnect.loginResult.user.flags;
    }
    
    return this.flags;
  },
  
  /**
   * Liefert die ID des aktuellen Benutzers zurück.
   * 
   * @returns {Number} ID des aktuellen Benutzers
   */
  getUser: function() {
    if (!this.userId) {
      this.userId = ixConnect.loginResult.user.id;
    }
    
    return this.userId;
  },
  
  /**
   * Gibt die belegten Programm-Ressourcen frei.
   */
  clear: function() {
    this.translator = null;
    this.wfTranslator = null;
    this.keywordsProvider = null;
  }
  
}






//JavaScript Template: transferCallback
// JavaScript Dokument




//JavaScript Template: wf
// start namespace wf

/**
 * @class wf
 * @singleton
 */
var wf = new Object();

wf = {

 /**
  * Ergänzt den angegebenen Workflowknoten um eine parallele Liste
  * von Anwendern. Wenn der Knoten einen Nachfolger hat, wird eine
  * Kenntnisname erzeugt, besitzt der Knoten zwei Nachfolger, wird
  * eine Freigabe erzeugt (1. Nachfolger: Freigabe, 2. Nachfolger:
  * Abgelehnt).
  *
  * Der Parameter userNodeName kann entweder ein String enthalten,
  * dann bekommen alle Knoten den gleichen Namen. Oder es wird ein
  * Array mit der gleichen Länge wie userList übergeben, dann erhält
  * jeder Anwenderwenderknoten den entsprechenden Namen aus dem
  * userNodeName Array.
  *
  * var userList = ["Musterfrau", "Mustermann"];
  * var nodeNames = ["Rechnung Prüfen","Rechnung überweisen"]; 
  *
  * @param {Number} workflowId Workflow-ID
  * @param {Number} nodeId Knotennummer innerhalb des Workflows
  * @param {Array} userList Liste(String-Array) mit den Benutzernamen
  * @param {String} userNodeName Bezeichnung für die neu erzeugten Knoten
  * @param {Object} copyProcessor Callback-Funktion zum Kopieren der Knotenfelder
  */
  expandNodeParallel: function(workflowId, nodeId, userList, userNodeName, copyProcessor) {
    var flow, node, matrix, successorId, firstSuccessor, sndSuccessor;
    
    try {
      flow = this.readWorkflow(workflowId, true);
      var nodeInserter = new NodeInserter(flow);
      node = wf.getNodeById(flow, nodeId);
      matrix = flow.matrix.assocs;
      for (var a = 0; a < matrix.length; a++) {
        var assoc = matrix[a];
        if (assoc.nodeFrom == nodeId) {
          if (!firstSuccessor) {
            firstSuccessor = wf.getNodeById(flow, assoc.nodeTo);
          } else if (!sndSuccessor) {
            sndSuccessor = wf.getNodeById(flow, assoc.nodeTo);
          } else {
            break;
          }
        }
      }
        
      nodeInserter.insertNodesParallel(node, firstSuccessor, sndSuccessor, userList, userNodeName, copyProcessor);
      nodeInserter.finalyze();
      this.writeWorkflow(flow);
      flow = null;
    } finally {
      if (flow) {
        this.unlockWorkflow(flow);
      }
    }
  },
  
 /**
  * Ergänzt den angegebenen Workflowknoten um eine sequenzielle Liste
  * von Anwendern. Wenn der Knoten einen Nachfolger hat, wird eine
  * Kenntnisname erzeugt, besitzt der Knoten zwei Nachfolger, wird
  * eine Freigabe erzeugt (1. Nachfolger: Freigabe, 2. Nachfolger:
  * Abgelehnt).
  *
  * Der Parameter userNodeName kann entweder ein String enthalten,
  * dann bekommen alle Knoten den gleichen Namen. Oder es wird ein
  * Array mit der gleichen Länge wie userList übergeben, dann erhält
  * jeder Anwenderwenderknoten den entsprechenden Namen aus dem
  * userNodeName Array.
  *
  * @param {Number} workflowId Workflow-ID
  * @param {Number} nodeId Knotennummer innerhalb des Workflows
  * @param {Array} userList String-Array mit den Benutzernamen
  * @param {String} userNodeName Bezeichnung für die neu erzeugten Knoten
  * @param {Object} copyProcessor Callback-Funktion zum Kopieren der Knotenfelder
  */
  expandNodeLinear: function(workflowId, nodeId, userList, userNodeName, copyProcessor) {
    var flow, node, matrix, firstSuccessor, sndSuccessor;
    
    try {
      flow = this.readWorkflow(workflowId, true);
      var nodeInserter = new NodeInserter(flow);
      node = wf.getNodeById(flow, nodeId);
      matrix = flow.matrix.assocs;
      for (var a = 0; a < matrix.length; a++) {
        var assoc = matrix[a];
        if (assoc.nodeFrom == nodeId) {
          if (!firstSuccessor) {
            firstSuccessor = wf.getNodeById(flow, assoc.nodeTo);
          } else if (!sndSuccessor) {
            sndSuccessor = wf.getNodeById(flow, assoc.nodeTo);
          } else {
            break;
          }
        }
      }
        
      nodeInserter.insertNodesLinear(node, firstSuccessor, sndSuccessor, userList, userNodeName, copyProcessor);
      nodeInserter.finalyze();
      this.writeWorkflow(flow);
      flow = null;
    } finally {
      if (flow) {
        this.unlockWorkflow(flow);
      }
    }
  },
  
  /**
   * Liefert den Workflow mit der angegebenen ID zurück.
   * 
   * @param {String} workflowId Workflow-ID
   * @param {Boolean} withLock Workflow-Sperre setzen
   * @returns {WFDiagram} Workflow-Diagramm
   */
  readWorkflow: function (workflowId, withLock) {
    log.debug("Read Workflow Diagram, WorkflowId = " + workflowId);
    return ixConnect.ix().checkoutWorkFlow(String(workflowId), WFTypeC.ACTIVE, WFDiagramC.mbAll, (withLock) ? LockC.YES : LockC.NO);
  },

  /**
   * Liefert den aktiven Workflow mit der eingegebenen ID zurück.
   * 
   * @param {Boolean} withLock Workflow-Sperre setzen
   * @returns {WFDiagram} Workflow-Diagramm
   */
  readActiveWorkflow: function (withLock) {
    var flowId = EM_WF_NODE.getFlowId();
    return wf.readWorkflow(flowId, withLock);
  },

  /**
   * Speichert den angegebenen Workflow auf dem Indexserver.
   * 
   * @param {WFDiagram} wfDiagram Workflow-Diagramm
   */
  writeWorkflow: function (wfDiagram) {
    ixConnect.ix().checkinWorkFlow(wfDiagram, WFDiagramC.mbAll, LockC.YES);
  },

  /**
   * Entsperrt den angegebenen Workflow.
   * 
   * @param {WFDiagram} wfDiagram Workflow
   */
  unlockWorkflow: function (wfDiagram) {
    ixConnect.ix().checkinWorkFlow(wfDiagram, WFDiagramC.mbOnlyLock, LockC.YES);
  },

  /**
  * Beendet alle laufenden Workflows zu einer ELO Objekt-ID.
  *
  * @param {String} objectId Objekt-Id des Eintrags
  */
  deleteAllWorkflowsOfObject: function (objectId) {
    var fti = new FindTasksInfo();
    fti.allUsers = true;
    fti.objId = objectId;
    fti.inclWorkflows = true;
    fti.lowestPriority = UserTaskPriorityC.LOWEST;
    
    var fr = ixConnect.ix().findFirstTasks( fti, 100 );
    try {
      while (true) {
        var tasks = fr.tasks;
        log.debug( "tasks.count=" + tasks.length );
        for (var i=0; i < tasks.length; i++) {
          var flowId = tasks[i].wfNode.flowId;
          this.terminateWorkflow( flowId );
        }
        
        if (!fr.isMoreResults()) break;
        
        idx += fr.tasks.length;
        fr = ixConnect.ix().findNextTasks( fr.searchId, idx, 100 );
      }
    } finally {
      if (fr != null) {
        ixConnect.ix().findClose( fr.searchId );
      }
    }
  },

  /**
  * Beendet den angegebenen Workflow.
  *
  * @param {String} flowId ID des zu beendenden Workflows
  */
  terminateWorkflow: function( flowId ) {
    log.debug( "terminateWorkflow: flowId=" + flowId );
    ixConnect.ix().terminateWorkFlow( flowId, LockC.NO );
  },
  
  /**
   * Liefert den Workflow-Knoten mit dem angegebenen Namen zurück.
   * 
   * @param {WFDiagram} wfDiagram Workflow-Diagramm
   * @param {String} nodeName Knotenname
   * @returns {WFNode} Workflowknoten
   */
  getNodeByName: function (wfDiagram, nodeName) {
    var nodes = wfDiagram.getNodes();
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node.getName() == nodeName) {
        return node;
      }
    }

    return null;
  },

  /**
   * Liefert den Workflow-Knoten mit der angegebenen ID zurück.
   * 
   * @param {WFDiagram} wfDiagram Workflow-Diagramm
   * @param {Number} nodeId Knoten-ID
   * @returns {WFNode} Workflowknoten
   */
  getNodeById: function (wfDiagram, nodeId) {
    var nodes = wfDiagram.getNodes();
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node.id == nodeId) {
        return node;
      }
    }

    return null;
  },

  /**
   * Setzt den angegebenen Knoten-Benutzer im angegebenen Workflow-Knoten.
   * 
   * @param {String} nodeName Knotenname
   * @param {String} nodeUserName Knotenbenutzer
   */
  changeNodeUser: function (nodeName, nodeUserName) {
    var diag = wf.readActiveWorkflow(true);
    var node = wf.getNodeByName(diag, nodeName);
    if (node) {
      var userInfos = ixConnect.ix().checkoutUsers([nodeUserName], CheckoutUsersC.BY_IDS, LockC.NO);
      var userInfo = (userInfos && userInfos.length > 0) ? userInfos[0] : null;
      if (userInfo) {
        node.setDesignDepartment(userInfo.id);
      }
      node.setUserName(nodeUserName);
      wf.writeWorkflow(diag);
    } else {
      wf.unlockWorkflow(diag);
    }
  },

  /**
   * Ersetzt den angegebenen Benutzer im aktiven Workflow.
   * 
   * @param {String} oldUser Aktueller Benutzer
   * @param {String} newUser Neuer Benutzer
   */
  changeAllUsers: function (oldUser, newUser) {
    var changed = false;
    var diag = wf.readActiveWorkflow(true);
    var nodes = diag.getNodes();
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node.userName == oldUser) {
        node.userName = newUser;
        changed = true;
      }
    }
    
    if (changed) {
      wf.writeWorkflow(diag);
    } else {
      wf.unlockWorkflow(diag);
    }
  },

  /**
   * Kopiert den Knotenbenutzer vom Quellknoten in den Zielknoten.
   * 
   * @param {String} sourceNodeName Bezeichnung des Quellknotens
   * @param {String} destinationNodeName Bezeichnung des Zielknotens
   * @returns {String} Knotenbenutzer oder null
   */
  copyNodeUser: function (sourceNodeName, destinationNodeName) {
    var diag = wf.readActiveWorkflow(true);
    var sourceNode = wf.getNodeByName(diag, sourceNodeName);
    var destNode = wf.getNodeByName(diag, destinationNodeName);

    if (sourceNode && destNode) {
      var user = sourceNode.getUserName();
      destNode.setUserName(user);
      wf.writeWorkflow(diag);
      return user;
    } else {
      wf.unlockWorkflow(diag);
      return null;
    }
  },

  /**
   * Startet einen neuen Workflow mit den angegebenen Daten.
   * 
   * @param {String} templateName Workflow-Vorlage
   * @param {String} flowName Workflow-Name
   * @param {String} objectId Objekt-ID
   * @returns {Number} ID des neuen Workflows
   */
  startWorkflow: function (templateName, flowName, objectId) {
    return ixConnect.ix().startWorkFlow(templateName, flowName, objectId);
  },
  
  /**
   * Liefert die Properties des angegebenen Workflow-Knotens zurück.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @returns {Properties} Knoten-Eigenschaften
   */
  getNodeProperties: function(node) {
    var desc = (node.nodeComment) ? node.nodeComment : node.comment;
    log.debug("Props of " + ((node.nodeName) ? node.nodeName : node.name) + " : " + desc);
    var props = new java.util.Properties();
    var reader = new java.io.StringReader(desc);
    props.load(reader);
    return props;
  },
  
  /**
   * Liefert den Nachfolgerknoten des angegebenen Workflow-Knotens zurück.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @returns {WFNode} Nachfolgerknoten
   */
  getSuccessor: function(node) {
    var editNode = ixConnect.ix().beginEditWorkFlowNode(node.flowId, node.nodeId, LockC.NO);
    var succNodes = editNode.succNodes;
    if (succNodes && succNodes.length > 0) {
      return succNodes[0];
    } else {
      return null;
    }
  },
  
  /**
   * Setzt die angegebenen Knoten-Eigenschaften.
   * 
   * @param {WFDiagram} flow Workflow
   * @param {String} flowId Workflow-ID
   * @param {String} objId ID des Eintrags
   * @param {Number} sourceWaitId ID des Nachfolgerknotens
   * @param {Number} newOwner ID des neuen Eigentümers
   * @param {Number} returnTo Benutzer für die Workflow-Rückgabe
   * @param {Number} flowObjId Objekt-ID des Eintrags
   */
  fillupFlow: function(flow, flowId, objId, sourceWaitId, newOwner, returnTo, flowObjId) {
    flow.objId = flowObjId;
    flow.id = -1;
    flow.type = WFTypeC.ACTIVE;
  
    var nodes = flow.nodes;
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      var props = this.getNodeProperties(node);
      if (props.getProperty("type") == "return") {
        var desc = node.comment + "\r\nflowid=" + flowId + 
                                  "\r\nnodeid=" + sourceWaitId + 
                                  "\r\nrootid=" + objId + 
                                  "\r\nserver=" + returnTo + "\r\n";
        node.comment = desc;        
      }
      
      if (newOwner && (node.id != 0) && (newOwner != "null") && (node.userId == -2)) {
        node.userId = -1;
        node.userName = newOwner;
      }
    }
  },
  
  /**
   * Erstellt oder leitet einen Workflow weiter aus der ZIP-Datei.
   * 
   * @param {Object} flowData Workflow-Daten
   * @param {Boolean} hasError Fehler vorhanden
   * @param {String} errorMessage Fehlermeldung
   */
  createOrConfirmFlowFromZip: function(flowData, hasError, errorMessage) {
    if (flowData.flowName == "") {
      this.confirmFlowFromZip(flowData, hasError, errorMessage);
    } else {
      this.createFlowFromZip(flowData, hasError, errorMessage);
    }
  },
  
  /**
   * Erstellt einen Workflow aus der angegebenen ZIP-Datei.
   * 
   * @param {Object} flowData Workflow-Daten
   * @param {Boolean} hasError Fehler vorhanden
   * @param {String} errorMessage Fehlermeldung
   */
  createFlowFromZip: function(flowData, hasError, errorMessage) {
    var flow = ixConnect.ix().checkoutWorkFlow(flowData.flowName, WFTypeC.TEMPLATE, WFDiagramC.mbAll, LockC.NO);
    if (flowData.subName) {
      flow.name = flowData.subName;
    }
    
    var objGuid = flowData.eloObjGuid;
    if (flowData.remoteWfObjId && (flowData.remoteWfObjId.length == 38)) {
      objGuid = flowData.remoteWfObjId;
    }
    
    this.fillupFlow(flow, flowData.waitFlowId, flowData.eloObjGuid, flowData.waitNodeId, flowData.newOwner, flowData.returnTo, objGuid);
    
    log.info("Start Subworkflow: " + flowData.flowName);
    ixConnect.ix().checkinWorkFlow(flow, WFDiagramC.mbAll, LockC.NO);
  },
  
  /**
   * Leitet einen Workflow aus der angegebenen ZIP-Datei weiter.
   * 
   * @param {Object} flowData Workflow-Daten
   * @param {Boolean} hasError Fehlermeldung vorhanden
   * @param {String} errorMessage Fehlermeldung
   */
  confirmFlowFromZip: function(flowData, hasError, errorMessage) {
    var flowId = flowData.waitFlowId;
    var nodeId = flowData.waitNodeId;
    try {
      var flowNode = ixConnect.ix().beginEditWorkFlowNode(flowId, nodeId, LockC.YES);
      var nodeComment = flowNode.node.comment;
      
      if (hasError) {
        nodeComment = nodeComment + "\r\n\r\n" + errorMessage;
      }
      
      var succNodes = flowNode.succNodes;
      var succNodeIds = new Array();
      for (var n = 0; n < succNodes.length; n++) {
        var succNode = succNodes[n];
        var isErrorNode = succNode.name == "OnError";
        
        if (isErrorNode == hasError) {
          succNodeIds.push(succNode.id);
        }
      }
      ixConnect.ix().endEditWorkFlowNode(flowId, nodeId, false, false, flowNode.node.name, nodeComment, succNodeIds);
    } catch(e) {
      // only unlock
      ixConnect.ix().endEditWorkFlowNode(flowId, nodeId, false, true, null, null, null);
      throw(e);
    }
  },
  
  /**
   * Startet einen Workflow mit den angegebenen Daten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {Properties} props Workflow-Properties
   */
  startRemoteFlow: function(node, props) {
    var serverName = props.getProperty("server");
    var flowName = props.getProperty("call");
    var destination = props.getProperty("destination");
    var newOwner = props.getProperty("newowner");
    if (!newOwner) {
      newOwner = "";
    }
    var returnTo = props.getProperty("returnto");
    if (flowName) {
      var succ = this.getSuccessor(node);
      if (serverName == "local") {
        var flow = ixConnect.ix().checkoutWorkFlow(flowName, WFTypeC.TEMPLATE, WFDiagramC.mbAll, LockC.NO);
        this.fillupFlow(flow, node.flowId, node.objId, succ.id, newOwner, returnTo, "");
        ixConnect.ix().checkinWorkFlow(flow, WFDiagramC.mbAll, LockC.NO);
      } else {
        var flowData = new Object();
        this.fillStandardProps(node, props, flowData);
        flowData.serverName = String(serverName);
        flowData.flowName = String(flowName);
        flowData.destination = String(destination);
        flowData.waitFlowId = String(node.flowId);
        flowData.waitNodeId = String(succ.id);
        flowData.eloObjGuid = String(node.objGuid);
        flowData.newOwner = String(newOwner);
        flowData.returnTo = String(returnTo);
        this.createExport(node, flowData, false);
      }
      EM_WF_NEXT = "0";
    }
  },
  
  /**
   * Setzt die Standard-Properties im angegebenen Workflow-Knoten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {Properties} props Workflow-Properties
   * @param {Object} flowData Workflow-Daten
   */
  fillStandardProps: function(node, props, flowData) {
    flowData.jsonClass = "TfFlowData";
    
    var restrict = this.sanitize(props.getProperty("restrict"));
    flowData.restrictGroup = restrict;
    
    var masks = props.getProperty("masks");
    if (masks) {
      masks = String(masks);
      flowData.masks = new Object();
      var items = masks.split("¶");
      for (var it = 0; it < items.length; it++) {
        flowData.masks[items[it]] = true;
      }
    } else {
      flowData.masks = null;
    }
    
    var subname = this.sanitize(props.getProperty("subname"));
    flowData.subName = subname;
    
    var exportMode = this.sanitize(props.getProperty("export"));
    flowData.exportMode = exportMode;
    
    var scriptName = this.sanitize(props.getProperty("scriptbeforesend"));
    flowData.scriptBeforeSend = scriptName;
    scriptName = this.sanitize(props.getProperty("scriptbeforereturn"));
    flowData.scriptBeforeReturn = scriptName;
    scriptName = this.sanitize(props.getProperty("scriptafterreturn"));
    flowData.scriptAfterReturn = scriptName;
  },
  
  /**
   * Liefert einen JavaScript-String aus dem angegebenen Text zurück.
   * 
   * @param text Text
   * @returns {String} JavaScript-String
   */
  sanitize: function(text) {
    if (text) {
      text = String(text);
    } else {
      text = "";
    }
    
    return text;
  },
  
  /**
   * Exportiert den angegebenen Workflow-Knoten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {Object} flowData Workflow-Daten
   * @param {Boolean} isReturn Zurückgeben
   */
  createExport: function(node, flowData, isReturn) {
    var fileName = EM_WF_EXPORT_ROOT + "\\" + flowData.serverName + "\\EX" + node.flowId + "." + node.nodeId + "." + Math.floor(Math.random() * 1000000000) + ".zip";
    tfex.doWfExport(flowData, fileName, isReturn);
  },
  
  /**
   * Gibt den angegebenen Workflow-Knoten zurück.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {Properties} props Workflow-Properties
   */
  returnRemoteFlow: function(node, props) {
    var remoteFlowId = props.getProperty("flowid");
    var remoteNodeId = props.getProperty("nodeid");
    if ((remoteFlowId >= 0) && (remoteNodeId >= 0)) {
      var editNode = ixConnect.ix().beginEditWorkFlowNode(remoteFlowId, remoteNodeId, LockC.YES);
      
      var succList = [editNode.succNodes[0].id];
      ixConnect.ix().endEditWorkFlowNode(remoteFlowId, remoteNodeId, false, false, editNode.node.name, "returned from " + node.nodeName, succList);
    }
    EM_WF_NEXT= "0";
  },
  
  /**
   * Exportiert einen Remote Workflow-Knoten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {Properties} props Workflow-Properties
   */
  exportRemoteFlow: function(node, props) {
    var flowData = new Object();
    this.fillStandardProps(node, props, flowData);
    flowData.serverName = String(props.getProperty("server"));
    flowData.flowName = String(props.getProperty("flowName") || "");
    flowData.destination = String(props.getProperty("destination") || "");
    flowData.waitFlowId = String(props.getProperty("flowid"));
    flowData.waitNodeId = String(props.getProperty("nodeid"));
    var rootId = String(props.getProperty("rootid"));
    if (rootId.length != 38) {
      rootId = String(node.objGuid);
    }
    flowData.eloObjGuid = rootId;
    flowData.newOwner = String("");
    flowData.returnTo = String("");
    this.createExport(node, flowData, true);
    EM_WF_NEXT= "0";
  },
  
  /**
   * Arbeitet einen Remote Workflow-Knoten ab.
   * 
   * @param {WFNode} node Workflow-Knoten
   */
  processRemoteWorkflow: function(node) {
    var workflow;
    try {
      workflow = ixConnect.ix().checkoutWorkFlow(node.flowId , WFTypeC.ACTIVE, WFDiagramC.mbOnlyLock, LockC.YES);
    } catch(e) {
      log.info("Locked workflow ignored: " + node.flowId);
      EM_WF_NEXT = "";
      return;
    }
    log.debug("Lock Ok");
  
    var props = this.getNodeProperties(node);
    var type = props.getProperty("type");
	
    if (type == "remoteflow") {
      this.startRemoteFlow(node, props);
    } else if (type == "return") {
      var server = props.getProperty("server");
      if (!server || (server == "local")) {
        this.returnRemoteFlow(node, props);
      } else {
        this.exportRemoteFlow(node, props);
      }
    }
    
    if (EM_WF_NEXT == "") {
      // Unlock wird nicht vom ELOas durchgeführt
      log.debug("Unlock by wf module");
      try {
        ixConnect.ix().checkinWorkFlow(workflow, WFDiagramC.mbOnlyLock, LockC.YES);
      } catch (ex2) {
        log.error("Cannot unlock Workflow: " + ex2);
      }
    }
  },
    
  /**
   * Erstellt einen Workflow-Report für den angegebenen Workflow-Knoten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {Sord} sord Metadaten des Eintrags
   */
  createWFReport: function(node, sord) {
    var flow = this.readWorkflow(node.flowId, false);
    var text = new Array();
    
    this.fillHeader(text, flow);
    this.fillNodes(text, flow);
    this.fillFooter(text);
    
    this.storeReport(text, sord);
  },
  
  /**
   * Speichert den Report für den angegebenen Repository-Eintrag.
   * 
   * @param {String} text Report
   * @param {Sord} sord Metadaten des Eintrags
   */
  storeReport: function(text, sord) {
    var name = fu.clearSpecialChars(sord.name);
    var file = File.createTempFile(name, ".html");
    FileUtils.writeStringToFile(file, text.join(""), "UTF-8");
    
    if (sord.type < 254) {
      // Insert document
      var docMask = "Freie Eingabe";
      var versDescr = "ELOas version";
      var versComment = "ELOas workflow report";
      var newDocId = Packages.de.elo.mover.utils.ELOAsUtils.insertIntoArchive(emConnect, file, sord.id, docMask, versDescr, versComment, false);
      log.info("newDocId=" + newDocId);
      var newDocSord = ixConnect.ix().checkoutSord(newDocId, SordC.mbLean, LockC.YES);
      newDocSord.name = "Workflow report";
      ixConnect.ix().checkinSord(newDocSord, SordC.mbLean, LockC.YES);
    } else {
      // Insert attachment
      ix.addAttachment(sord.id, file);
    }
  },
 
  /**
   * Liefert das formattierte ISO-Datum zurück.
   * 
   * @param {String} isoDate ISO-Datum
   * @returns {String} Formattiertes ISO-Datum
   */  
  formatIsoDate: function(isoDate) {
    isoDate = String(isoDate);
    if (isoDate.length > 11) {
      return isoDate.substring(6, 8) + "." + isoDate.substring(4, 6) + "." + isoDate.substring(0, 4) + " - " + isoDate.substring(8, 10) + ":" + isoDate.substring(10, 12);
    } else if (isoDate.length > 7) {
      return isoDate.substring(6, 8) + "." + isoDate.substring(4, 6) + "." + isoDate.substring(0, 4);
    } else if (isoDate.length == 0) {
      return "";
    } else {
      return isoDate;
    }
  },
  
  /**
   * Fügt die Anfangs HTML-Zeilen im angegebenen Text ein.
   * 
   * @param {String} text Text
   * @param {WFDiagram} flow Workflow-Diagramm
   */
  fillHeader: function(text, flow) {
    var wfName = www.toHtml(flow.name);
    text.push("<html><head><title>Workflow-Report : ");
    text.push(wfName);
    text.push('</title></head><body bgcolor="#ffffff" text="#000000" style="font-family:Tahoma,Arial,sans-serif;">');
    text.push('<table><tr><td colspan=2><h1>Workflow Abschlussbericht</h></td></tr>');
    text.push("<tr><td>&nbsp;</td></tr><tr><td><b>Workflowname</b></td><td><b>");
    text.push(wfName);
    text.push("</b></td></tr><tr><td><b>Abschlussdatum</b></td><td><b>");
    text.push(new Date());
    text.push("</b></td></tr></table><p>");
    text.push('<table border="0" CELLPADDING="8" cellspacing="0">');
    text.push('<tr bgcolor="#c0d0ff"><th align="left">Nr.</th><th align="left">Startdatum</th><th align="left">Endedatum</th><th align="left">Anwender</th><th align="left">Knoten</th><th align="left">Bemerkung</th></tr>');
  },
  
  /**
   * Fügt die abschließende HTML-Zeile im angegebenen Text ein.
   * 
   * @param {String} text Text
   */
  fillFooter: function(text) {
    text.push("</table></body></html>");
  },
  
  /**
   * Setzt den Text in allen Workflow-Knoten im angegebenen Workflow.
   * 
   * @param {String} text Text
   * @param {WFDiagram} flow Workflow
   */
  fillNodes: function(text, flow) {
    var nodes = flow.nodes;
    var line = 1;
    
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node.type == 2) {
        this.fillNode(text, node, line);
        line++;
      }
    }
  },
  
 /**
  * Setzt die Eigenschaften im angegebenen Workflow-Knoten.
  * 
  * @param {String} text Text
  * @param {WFNode} node Workflow-Knoten
  * @param {Number} line Zeile
  */
  fillNode: function(text, node, line) {
    var user = node.userTerminate;
    if (user == "") {
      user = node.userName;
    }
    
    text.push("<tr bgcolor=");
    text.push( (line % 2) ? "#f5f8ff" : "#eef0ff" );
    text.push('><td valign="top" align="left">');
    text.push(line);
    text.push('</td><td valign="top" align="left">');
    text.push(this.formatIsoDate(node.enterDateIso));
    text.push('</td><td valign="top" align="left">');
    text.push(this.formatIsoDate(node.exitDateIso));
    text.push('</td><td valign="top" align="left">');
    text.push(www.toHtml(user));
    text.push('</td><td valign="top" align="left">');
    text.push(www.toHtml(node.name));
    text.push('</td><td valign="top" align="left">');
    text.push(www.toHtml(node.comment));
    text.push("</td></tr>");
  },
  
  /**
   * Setzt den Kommentar im angegebenen Workflow-Knoten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {String} newComment Kommentar
   */
  adjustNodeComment: function(node, newComment) {
    var flow = ixConnect.ix().checkoutWorkFlow(node.flowId, WFTypeC.ACTIVE, WFDiagramC.mbAll, LockC.YES);
    var nodes = flow.nodes;
    var id = node.nodeId;
    
    for (var i = 0; i < nodes.length; i++) {
      var nd = nodes[i];
      if (nd.id == id) {
        nd.comment = newComment;
        break;
      }
    }
    
    ixConnect.ix().checkinWorkFlow(flow, WFDiagramC.mbAll, LockC.YES);
  },
  
  /**
   * Überprüft den Sub-Workflow des angegebenen Workflow-Knotens.
   * 
   * @param {WFNode} node Workflow-Knoten
   */
  checkSubWorkflow: function(node) {
    log.debug("Check node: " + node.flowName);
    var props = wf.getNodeProperties(node);
    var command = props.get("Command");
    var subflow = props.get("TemplateName");
    var subname = props.get("FlowName");
    
    if (command == "callSWF") {
      if (subflow) {
        var subName = props.get("FlowName");
        log.info("Start Subworkflow: " + subflow);
        var subflowId = ixConnect.ix().startWorkFlow(subflow, subName || node.objName, node.objId);
        var nodeComment = "Command=waitSWF\r\nFlowId=" + subflowId + "\r\nTemplateName=" + subflow;
        if (subname) {
          nodeComment = nodeComment + "\r\nFlowName=" + subname;
        }
        wf.adjustNodeComment(node, nodeComment);
        log.info("Wait for termination of the subworkflow " + subflowId);
      }
    } else if (command == "waitSWF") {
      var waitForWfId = props.get("FlowId");
      log.debug("Check termination state of " + waitForWfId);
      try {
        var flow = ixConnect.ix().checkoutWorkFlow(waitForWfId, WFTypeC.ACTIVE, WFDiagramC.mbOnlyLock, LockC.NO);
        log.debug("Still available");
      } catch(e) {
        e = String(e);
        log.debug("Not reachable: " + e);
        if (e.indexOf("[ELOIX:5023]") >= 0) {
          log.info("Subworkflow " + waitForWfId + " terminated, resume workflow.");
          var comment = "Command=callSWF\r\nTemplateName=" + subflow;
          if (subname) {
            comment = comment + "\r\nFlowName=" + subname;
          }
          var wfNode = ixConnect.ix().beginEditWorkFlowNode(node.flowId, node.nodeId, LockC.YES);
          var nodeName = wfNode.node.name;
          var succList = wfNode.succNodes;
          ixConnect.ix().endEditWorkFlowNode(node.flowId, node.nodeId, false, false, nodeName, comment, [succList[0].id]);
        }
      }
    }
  },

  /**
   * Kopiert wichtige Knoten-Eigenschaften im angegebenen Workflow-Knoten.
   * 
   * @param {WFNode} node Workflow-Knoten
   * @param {WFNode} startNode Workflow-Knoten, dessen Eigenschaften kopiert werden
   * @param {String} firstSuccessor Erster Nachfolgeknoten
   * @param {String} sndSuccessor Zweiter Nachfolgeknoten
   */
  defaultCopyProcessor: function(node, startNode, firstSuccessor, sndSuccessor) {
    node.comment = startNode.comment;
    node.department2 = startNode.department2;
    node.formSpec = startNode.formSpec;
    node.processOnServerId = startNode.processOnServerId;
  }

}
// end of namespace wf 

// Private Hilfsfunktionen für die "expandNode"-Funktionen
function NodeInserter(flow) {
  this.flow = flow;
  this.nodes = this.copyNodes(flow);
  this.assocs = this.copyAssocs(flow);
};

NodeInserter.prototype.finalyze = function() {
  this.flow.nodes = this.nodes;
  this.flow.matrix.assocs = this.assocs;
};

NodeInserter.prototype.insertNodesParallel = function(startNode, firstSuccessor, sndSuccessor, userList, userNodeName, copyProcessor) {
  if (userList.length > 20) {
    throw("Maximum of 20 successors exceeded.");
  }
  
  var nextId = this.nextFreeNodeId();
  var scatter, gather, abort;
  scatter = new WFNode();
  scatter.id = nextId++;
  scatter.name = startNode.name;
  scatter.type = WFNodeC.TYPE_SPLITNODE;
  scatter.posY = startNode.posY + 80;
  scatter.posX = startNode.posX;
  scatter.userId = -1;
  this.nodes.push(scatter);
  
  if (firstSuccessor) {
    gather = new WFNode();
    gather.id = nextId++;
    gather.name = firstSuccessor.name;
    gather.type = WFNodeC.TYPE_COLLECTNODE;
    gather.nbOfDonesToExit = -1;
    gather.posY = firstSuccessor.posY - 80;
    gather.posX = firstSuccessor.posX;
    gather.userId = -1;
    this.nodes.push(gather);
    
    if (sndSuccessor) {
      abort = new WFNode();
      abort.id = nextId++;
      abort.name = sndSuccessor.name;
      abort.type = WFNodeC.TYPE_COLLECTNODE;
      abort.nbOfDonesToExit = 1;
      abort.posY = sndSuccessor.posY - 80;
      abort.posX = sndSuccessor.posX;
      abort.userId = -1;
      this.nodes.push(abort);
    }
  }
  
  this.addScatterGather(startNode, firstSuccessor, sndSuccessor, scatter, gather, abort);
  var nodesList = this.addUsers(nextId, startNode, firstSuccessor, sndSuccessor, scatter, gather, abort, userList, userNodeName, copyProcessor);
  
  if (abort) {
    abort.formSpec = nodesList;
  }
};

NodeInserter.prototype.insertNodesLinear = function(startNode, firstSuccessor, sndSuccessor, userList, userNodeName, copyProcessor) {
  var nextId = this.nextFreeNodeId();
  var actSuccessor = firstSuccessor;
  
  for (var u = userList.length - 1; u >= 0; u--) {
    var user = userList[u];
    var name = (typeof(userNodeName) == "string") ? userNodeName : userNodeName[u];
    var userNode = this.createUserNode(nextId++, name, user);
    userNode.posY = startNode.posY + (u + 1) * 80;
    userNode.posX = startNode.posX - u * 40;
    
    if (copyProcessor) {
      copyProcessor(userNode, startNode, firstSuccessor, sndSuccessor);
    }
    
    this.nodes.push(userNode);
    if (actSuccessor) {
      this.addAssoc(userNode.id, actSuccessor.id);
      
      if (sndSuccessor) {
        this.addAssoc(userNode.id, sndSuccessor.id);
      }
    }
    
    actSuccessor = userNode;
  }
  
  this.adjustStartNode(startNode.id, actSuccessor.id);
};
  
NodeInserter.prototype.addUsers = function(nextId, startNode, firstSuccessor, sndSuccessor, scatter, gather, abort, userList, userNodeName, copyProcessor) {
  var nodesList = "";
  for (var i = 0; i < userList.length; i++) {
    if (i > 0) { nodesList += ","; };
    nodesList += nextId;
    
    var name = (typeof(userNodeName) == "string") ? userNodeName : userNodeName[i];
    var userNode = this.createUserNode(nextId++, name, userList[i]);
    userNode.posY = scatter.posY + 80;
    userNode.posX = scatter.posX + i * 200;
    
    if (copyProcessor) {
      copyProcessor(userNode, startNode, firstSuccessor, sndSuccessor);
    }
    
    this.nodes.push(userNode);
    
    this.addAssoc(scatter.id, userNode.id);
    
    if (gather) {
      this.addAssoc(userNode.id, gather.id);
    }
    
    if (abort) {
      this.addAssoc(userNode.id, abort.id);
    }
  }
  
  if (gather) {
    nodesList += "," + gather.id;
  }
  
  return nodesList;
};
  
NodeInserter.prototype.addScatterGather = function(startNode, firstSuccessor, sndSuccessor, scatter, gather, abort) {
  var found1 = false;
  var foundA = false;
  for (var i = 0; i < this.assocs.length; i++) {
    var assoc = this.assocs[i];
    if (firstSuccessor && (assoc.nodeFrom == startNode.id) && (assoc.nodeTo == firstSuccessor.id)) {
      assoc.nodeTo = scatter.id;
      found = true;
    }
    if (sndSuccessor && (assoc.nodeFrom == startNode.id) && (assoc.nodeTo == sndSuccessor.id)) {
      assoc.nodeFrom = abort.id;
      foundA = true;
    }
  }
  
  if (!found1) {
    this.addAssoc(startNode.id, scatter.id);
  }
  
  if (gather) {
    this.addAssoc(gather.id, firstSuccessor.id);
  }
  
  if (abort && !foundA) {
    this.addAssoc(abort.id, sndSuccessor.id);
  }
};
  
NodeInserter.prototype.createUserNode = function(id, name, user) {
  var node = new WFNode();
  node.id = id;
  node.userName = user;
  node.name = name;
  node.type = WFNodeC.TYPE_PERSONNODE;
  node.flags = WFNodeC.FLAG_ONE_SUCCESSOR;
  return node;
};
  
NodeInserter.prototype.adjustStartNode = function(startNodeId, firstUserNodeId) {
  for (var i = this.assocs.length - 1; i >= 0; i--) {
    if (this.assocs[i].nodeFrom == startNodeId) {
      this.assocs.splice(i, 1);
    }
  }
  
  this.addAssoc(startNodeId, firstUserNodeId);
};

NodeInserter.prototype.nextFreeNodeId = function() {
  var nodes = this.flow.nodes;
  var maxId = 0;
  for (var i = 0; i < nodes.length; i++) {
    if (nodes[i].id > maxId) {
      maxId = nodes[i].id;
    }
  }
  
  return maxId + 1;
};
  
NodeInserter.prototype.copyNodes = function(flow) {
  var jsNodes = new Array();
  var nodes = flow.nodes;
  for (var i = 0; i < nodes.length; i++) {
    jsNodes.push(nodes[i]);
  }
  
  return jsNodes;
};
  
NodeInserter.prototype.copyAssocs = function(flow) {
  var jsAssocs = new Array();
  var assocs = flow.matrix.assocs;
  for (var i = 0; i < assocs.length; i++) {
    jsAssocs.push(assocs[i]);
  }
  
  return jsAssocs;
};
  
NodeInserter.prototype.addAssoc = function(from, to) {
  var assoc = new WFNodeAssoc();
  assoc.nodeFrom = from;
  assoc.nodeTo = to;
  this.assocs.push(assoc);
};




//JavaScript Template: wftransport
// JavaScript Dokument

/**
 * @class Wftransport
 */
function Wftransport() {
}

var wftransport = new Wftransport();

/**
 * @method beforeSend
 * Skriptaufruf vor dem Versenden der Workflow-Daten.
 * 
 * @param {Object} wfData Workflow-Daten
 */
Wftransport.prototype.beforeSend = function(wfData) {
  log.warn("Skriptaufruf beforeSend");
  log.warn(wfData);
  wfData.remoteWfObjId = "(E4246684-9E37-B835-0E4A-D9D4FC0AC214)";
}

/**
 * @method afterReturn
 * Skriptaufruf nach dem Zurückkehren aus der Funktion. 
 * 
 * @param {Object} wfData Workflow-Daten
 */
Wftransport.prototype.afterReturn = function(wfData) {
  log.warn("Skriptaufruf afterReturn");
  log.warn(wfData);
}

/**
 * @method beforeReturn
 * Skriptaufruf vor dem Zurückkehren aus der Funktion.
 * 
 * @param {Object} wfData Workflow-Daten
 */
Wftransport.prototype.beforeReturn = function(wfData) {
  log.warn("Skriptaufruf beforeReturn");
  log.warn(wfData);
}



//JavaScript Template: www
// start namespace www

/**
 * @class www
 * @singleton
 */
var www = new Object();

www = {

  /**
   * Liefert den Inhalt als Text aus der angegebenen URL zurück.
   * 
   * @param {String} url URL
   * @returns {String} URL Inhalt
   */
  get: function(url) {
    var client = new Packages.org.apache.http.impl.client.DefaultHttpClient();
    var method = new Packages.org.apache.http.client.methods.HttpGet(url);

    var response = client.execute(method);
    var content = Packages.org.apache.http.util.EntityUtils.toString(response.entity);
    
    return content;
  },

  /**
   * Liefert einen HTML-Text mit den ersetzten Sonderzeichen aus dem angegebenen Text zurück.
   * 
   * @param {String} text
   * @returns {String} Text mit ersetzten Sonderzeichen
   */
  toHtml: function(text) {
    text = String(text).replace("&", "&amp;");
    text = text.replace("<", "&lt;");
    text = text.replace(">", "&gt;");
    return text;
  },

  /**
   * Liefert ein UTF8-Array aus dem angegebenen JSON-String zurück.
   * 
   * @param {String} str JSON-String
   * @returns {Array}
   */
  toUTF8Array: function (str) {
    var utf8 = [];
    for (var i=0; i < str.length; i++) {
      var charcode = str.charCodeAt(i);
      if (charcode < 0x80) utf8.push(charcode);
      else if (charcode < 0x800) {
        utf8.push(0xc0 | (charcode >> 6),   
                0x80 | (charcode & 0x3f));  
      }
      else if (charcode < 0xd800 || charcode >= 0xe000) {
        utf8.push(0xe0 | (charcode >> 12),   
                0x80 | ((charcode>>6) & 0x3f),   
                0x80 | (charcode & 0x3f));  
      }  
      // surrogate pair
      else {
        i++;
        // UTF-16 encodes 0x10000-0x10FFFF by
        // subtracting 0x10000 and splitting the
        // 20 bits of 0x0-0xFFFFF into two halves
        charcode = 0x10000 + (((charcode & 0x3ff)<<10)  
                   | (str.charCodeAt(i) & 0x3ff));  
        utf8.push(0xf0 | (charcode >>18),   
                  0x80 | ((charcode>>12) & 0x3f),   
                  0x80 | ((charcode>>6) & 0x3f),   
                  0x80 | (charcode & 0x3f));  
      }
    }

    return utf8;
  } 

}; // end of namespace www



//JavaScript Template: zugf
// Zugferd Library

/**
 * @class zugf
 * @singleton
 */
var zugf = {
  // Liste der XML Pfade zur Übertragung in Indexzeilen. Die Indexzeilen werden über den Gruppennamen ausgewählt.
  // Es gibt zwei Sonderzeilen: "name" - diese Daten werden in die Kurzbezeichnung übertragen und "docdate" - diese
  // Daten werden in das XDateISO (Dokumentendatum) übertragen.
  indexMapping : [
    {name: "docdate", path: "/CrossIndustryDocument/HeaderExchangedDocument/IssueDateTime/DateTimeString/text()"},
    {name: "name", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeAgreement/SellerTradeParty/Name/text()"},
    {name: "ERENAME", path: "/CrossIndustryDocument/HeaderExchangedDocument/Name/text()"},
    {name: "EREKRNAME", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeAgreement/SellerTradeParty/Name/text()"},
    {name: "EREKRZIP", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeAgreement/SellerTradeParty/PostalTradeAddress/PostcodeCode/text()"},
    {name: "EREKRSTREET", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeAgreement/SellerTradeParty/PostalTradeAddress/LineOne/text()"},
    {name: "EREKRCITY", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeAgreement/SellerTradeParty/PostalTradeAddress/CityName/text()"},
    {name: "EREINVNR", path: "/CrossIndustryDocument/HeaderExchangedDocument/ID/text()"},
    {name: "EREDATE", path: "/CrossIndustryDocument/HeaderExchangedDocument/IssueDateTime/DateTimeString/text()"},
    {name: "EREDELIVERY", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeDelivery/ActualDeliverySupplyChainEvent/OccurrenceDateTime/DateTimeString/text()"},
    {name: "ERESKONTOPER", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeSettlement/SpecifiedTradePaymentTerms/ApplicableTradePaymentDiscountTerms/CalculationPercent/text()", normalize : true},
    {name: "ERESKONTODAYS", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeSettlement/SpecifiedTradePaymentTerms/ApplicableTradePaymentDiscountTerms/BasisPeriodMeasure/text()", normalize : true},
    {name: "ERENETTO", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeSettlement/SpecifiedTradeSettlementMonetarySummation/TaxBasisTotalAmount/text()", normalize : true},
    {name: "EREUMST", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeSettlement/SpecifiedTradeSettlementMonetarySummation/TaxTotalAmount/text()", normalize : true},
    {name: "EREBRUTTO", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeSettlement/SpecifiedTradeSettlementMonetarySummation/GrandTotalAmount/text()", normalize : true}
  ],
  
  // Liste der XML Pfade zur Übertragung in Map Felder ("Weitere Infos") des Sord Objekts.
  mapMapping : [
    {name: "CURRENCY", path: "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/ApplicableSupplyChainTradeSettlement/InvoiceCurrencyCode/text()"}
  ],
  
  // Der nachfolgende Bereich definiert die Artikelpositionen, davon gibt es beliebig viele.
  // über ein Eintrag itemsPaths wird der Start einer Artikelposition definiert. Das itemMapping
  // definiert dann die einzelnen Spalten der Position. Die Positionsdaten werden immer in 
  // durchnummerierte Map Felder abgelegt.
  itemsPath : "/CrossIndustryDocument/SpecifiedSupplyChainTradeTransaction/IncludedSupplyChainTradeLineItem",

  itemMapping : [
    {name: "AMOUNT", path: "./SpecifiedSupplyChainTradeSettlement/SpecifiedTradeSettlementMonetarySummation/LineTotalAmount/text()", normalize: true},
    {name: "UST", path: "./SpecifiedSupplyChainTradeSettlement/ApplicableTradeTax/ApplicablePercent/text()", normalize: true},
    {name: "COUNT", path: "./SpecifiedSupplyChainTradeDelivery/BilledQuantity/text()", normalize: true},
    {name: "UNITPRICE", path: "./SpecifiedSupplyChainTradeAgreement/NetPriceProductTradePrice/ChargeAmount/text()", normalize: true},
    {name: "BEZ", path: "./SpecifiedTradeProduct/Name/text()"}
  ],
  
  item : null,
  map  : null,
  
  /**
  * Führt eine Verarbeitung der Rechnungsdaten durch.
  * 
  * 1. Prüft, ob es sich um eine Zugferd Rechnung handelt.
  * 2. Liest die Zugferd Daten in die Metadaten ein.
  * 3. Speichert die eingelesenen Daten (optional).
  *
  * @param {Sord} sord Metadaten des Eintrags
  * @param {Boolean} withSave Eingelesene Metadaten speichern
  * @returns {Boolean} Ergebnis der Operation true/false
  */
  process : function(sord, withSave) {
    this.item = sord;
    this.map = new Array();
    
    this.xmlFile = this.extract(sord.id);
    
    try {
      if (this.xmlFile) {
        var zfDoc = new Packages.de.elo.mover.main.XPathReader(this.xmlFile);
        log.info("Document read");
        
        this.storeIndex(zfDoc);
        (new File(this.xmlFile))["delete"]();
        
        if (withSave) {
          this.storeData();
        }
        
        return true;
      }
    } catch(e) {
      log.warn("Zugferd error: " + e);
    }
    
    return false;
  },
  
  /**
  * Liest die Datei zum Dokument ein und trennt die XML Datei
  * ab. Das lokale PDF Dokument wird anschließend gelöscht und
  * der Dateipfad zur XML Datei zurückgegeben. Es ist Aufgabe
  * der aufrufenden Funktion die XML Datei nach Abschluss der
  * Aktion zu löschen.
  *
  * Im Fehlerfall wird null zurückgegeben.
  *
  * @param {String} sordId Objekt-ID des PDF Dokuments
  * @returns {String} Dateipfad der XML-Datei mit den Zugferd Daten oder null
  */
  extract : function(sordId) {
    var pdfFile = fu.getTempFile(sordId);
    var xmlFileName = pdfFile.path + ".xml";
    
    try {
      var res = Packages.de.elo.mover.main.Utils.splitZugferd(pdfFile.path, xmlFileName);
      log.info("Result of Split: " + res);
      pdfFile["delete"]();
      return xmlFileName;
    } catch(e) {
      log.warn("Error splitting zugferd file: " + pdfFile.path);
      return null;
    }
  },
  
  /**
  * Liefert ein Array mit den zuletzt eingelesenen
  * Map Daten des Dokuments zurück.
  *
  * @returns {Array} Map-Array
  */
  getMap : function() {
    return this.map;
  },

  /**
  * Wird beim Einlesen von Zahlen aufgerufen und kann optional
  * das Format an die jeweiligen lokalen Einstellungen anpassen.
  * Hier können Tausendertrennzeichen eingefügt oder Nachkommastellen
  * mit einem Komma statt Punkt abgetrennt werden.
  * 
  * @param {String} value Eingelesene Zahl
  * @returns {String} Formatierte Zahl zum Speichern in den Metadaten
  */  
  normalize : function(value) {
    var tmp = value.replace(".", ",");
    return tmp;
  },
  
  /**
  * Speichert die aktuellen Meta- und Map-Daten.
  */
  storeData : function() {
    ixConnect.ix().checkinSord(this.item, EM_SYS_SELECTOR, LockC.NO);
    ixConnect.ix().checkinMap(MapDomainC.DOMAIN_SORD, this.item.id, this.item.id, this.map, LockC.NO);
  },
  
  /**
  * private Funktionen, nicht zur externen Verwendung
  */
  setValue : function(lineName, value) {
    if (lineName == "docdate") {
      this.item.XDateIso = value;
    } else if (lineName == "name") {
      this.item.name = value;
    } else {
      var keys = this.item.objKeys;
      
      for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (key.name == lineName) {
          key.data = [value];
        }
      }
    }
  },
  
  storeIndex : function(zfDoc) {
    this.map = new Array();    
    this.fillupIndex(zfDoc, this.indexMapping);
    this.fillupMap(zfDoc, this.mapMapping);
    this.fillupItems(zfDoc, this.itemsPath, this.itemMapping);
  },
  
  fillupItems : function(zfDoc, itemsPath, mapping) {
    var count = zfDoc.selectItems(itemsPath);
    log.info("Item count: " + count);

    for (var line = 0; ;) {
      if (!zfDoc.nextItem()) {
        break;
      }
  
      for (var i = 0; i < mapping.length; i++) {
        var item = mapping[i];
        var value = zfDoc.getItemText(item.path);
        if ((i == 0) && (value == "")) {
          // Wenn der erste Wert nicht vorhanden ist, dann den ganzen Block ignorieren
          break;
        }
        
        if (i == 0) {
          line++;
        }
        
        if (item.normalize) {
          value = this.normalize(value);
        }
        
        var keyValue = new KeyValue(item.name + line, value);
        this.map.push(keyValue);
      }
    }
  },
  
  fillupIndex : function(zfDoc, mapping) {
    for (var i = 0; i < mapping.length; i++) {
      var item = mapping[i];
      var value = zfDoc.getNodeText(item.path);
      if (item.normalize) {
        value = this.normalize(value);
      }
      
      this.setValue(item.name, value);
    }
  },
  
  fillupMap : function(zfDoc, mapping) {
    for (var i = 0; i < mapping.length; i++) {
      var item = mapping[i];
      var value = zfDoc.getNodeText(item.path);
      if (item.normalize) {
        value = this.normalize(value);
      }
      
      var keyValue = new KeyValue(item.name, value);
      this.map.push(keyValue);
    }
  }
  
}





function sysExitRuleset() {
  dbExitRuleset();

}


initSearch();
