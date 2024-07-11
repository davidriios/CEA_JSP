<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
				DESCRIPCION    										  NOMBRE REPORTES   FORMA         FLAG
				COMIDAS DE ACOMPAÑANTES             FAC_80096.RDF     FAC96054.FMB  CA
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String groupBy = "",groupByProv="";

int nGroup =0;
if(almacen== null) almacen = "4";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";

if(fDate.trim().equals("")&&tDate.trim().equals("")) throw new Exception("No existen parametros de busqueda seleccione los rangos de fecha !!!");
if (appendFilter == null) appendFilter = "";

System.out.println("fDate = "+fDate);


sql = " select nvl(xx.cant_res_des,0) cant_res_des,nvl(yy.cant_cli_des,0)cant_cli_des ,nvl(yy.cant_ped_des,0)cant_ped_des,nvl(xx.cant_res_alm,0) cant_res_alm,nvl(yy.cant_cli_alm,0)cant_cli_alm ,nvl(yy.cant_ped_alm,0)cant_ped_alm, nvl(xx.cant_res_cena,0) cant_res_cena,nvl(yy.cant_cli_cena,0)cant_cli_cena,nvl(yy.cant_ped_cena,0)cant_ped_cena, nvl(xx.cant_res_des,0)+nvl(yy.cant_cli_des,0)+nvl(yy.cant_ped_des,0) total_des ,nvl(xx.cant_res_alm,0)+nvl(yy.cant_cli_alm,0)+nvl(yy.cant_ped_alm,0) total_alm ,nvl(xx.cant_res_cena,0)+nvl(yy.cant_cli_cena,0)+nvl(yy.cant_ped_cena,0) total_cena, nvl(xx.monto_res_des,0) monto_res_des,nvl(yy.monto_cli_des,0)monto_cli_des ,nvl(yy.monto_ped_des,0)monto_ped_des,nvl(xx.monto_res_alm,0) monto_res_alm,nvl(yy.monto_cli_alm,0)monto_cli_alm ,nvl(yy.monto_ped_alm,0)monto_ped_alm, nvl(xx.monto_res_cena,0) monto_res_cena,nvl(yy.monto_cli_cena,0)monto_cli_cena,nvl(yy.monto_ped_cena,0)monto_ped_cena, nvl(xx.monto_res_des,0)+nvl(yy.monto_cli_des,0)+nvl(yy.monto_ped_des,0) total_monto_des ,nvl(xx.monto_res_alm,0)+nvl(yy.monto_cli_alm,0)+nvl(yy.monto_ped_alm,0) total_monto_alm ,nvl(xx.monto_res_cena,0)+nvl(yy.monto_cli_cena,0)+nvl(yy.monto_ped_cena,0) total_monto_cena from    ( SELECT  /* desayuno */ sum( case when t.inv_articulo = 4 then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1, 'C',nvl (t.cantidad, 0),0) ) else 0 end ) as cant_res_des, sum( case when t.inv_articulo = 4 then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_res_des /* almuerzo */  ,sum( case when t.inv_articulo = 5 then sum( decode (t.tipo_transaccion,'D', nvl (t.cantidad, 0)*-1,'C',nvl (t.cantidad, 0),0)) else 0 end ) as cant_res_alm, sum( case when t.inv_articulo = 5 then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_res_alm /* cena */  ,sum( case when t.inv_articulo = 6 then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1, 'C',nvl (t.cantidad, 0),0) ) else 0 end ) as cant_res_cena, sum( case when t.inv_articulo = 6 then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_res_cena from tbl_adm_admision a,tbl_fac_detalle_transaccion t WHERE a.compania = "+compania +" and a.ESTADO NOT IN ('N') and (t.compania = a.compania and to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fDate+"','dd/mm/yyyy'),to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+tDate+"','dd/mm/yyyy'),to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy')) and t.pac_id = a.pac_id and t.fac_secuencia  = a.secuencia  and  t.inv_almacen = 4 and t.art_familia = 34 and t.art_clase = 1  and t.inv_articulo  in (4,5,6) ) group by t.inv_articulo,t.tipo_transaccion    ) xx	,";

sql += " (select  /*desayuno pediatrico  */	   sum( case when t.inv_articulo = 1 and x.habitacion LIKE ('P%') then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1, 'C',nvl (t.cantidad, 0),0)) else 0 end ) as cant_ped_des, sum( case when t.inv_articulo = 1 and x.habitacion LIKE ('P%') then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_ped_des /* almuerzo pediatrico*/  ,sum( case when t.inv_articulo = 2 and x.habitacion LIKE ('P%') then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1, 'C',nvl (t.cantidad, 0),0) ) else 0 end ) as cant_ped_alm,sum( case when t.inv_articulo = 2 and x.habitacion LIKE ('P%') then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_ped_alm /* cena pediatrico */  ,sum( case when t.inv_articulo = 3 and x.habitacion LIKE ('P%') then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1,'C',nvl (t.cantidad, 0),0)) else 0 end ) as cant_ped_cena, sum( case when t.inv_articulo = 3 and x.habitacion LIKE ('P%') then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_ped_cena,   /* comidas clinica  */ 	   sum( case when t.inv_articulo = 1 and x.habitacion not LIKE ('P%') then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1,'C',nvl (t.cantidad, 0),0)) else 0 end ) as cant_cli_des, sum( case when t.inv_articulo = 1 and x.habitacion not LIKE ('P%') then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_cli_des /* almuerzo pediatrico*/  ,sum( case when t.inv_articulo = 2 and x.habitacion not LIKE ('P%') then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1, 'C',nvl (t.cantidad, 0),0) ) else 0 end ) as cant_cli_alm, sum( case when t.inv_articulo = 2 and x.habitacion not  LIKE ('P%') then sum (decode (t.tipo_transaccion, 'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)), 'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0) ) else 0 end ) as monto_cli_alm /* cena pediatrico */  ,sum( case when t.inv_articulo = 3 and x.habitacion not LIKE ('P%') then sum( decode (t.tipo_transaccion, 'D', nvl (t.cantidad, 0)*-1,'C',nvl (t.cantidad, 0),0)) else 0 end ) as cant_cli_cena,sum( case when t.inv_articulo = 3 and x.habitacion not LIKE ('P%') then sum (decode (t.tipo_transaccion,'D', (nvl (t.cantidad, 0)*-1 *nvl(t.monto,0)),'C',nvl (t.cantidad, 0)* nvl(t.monto,0),0)) else 0 end ) as monto_cli_cena   from tbl_adm_admision a, tbl_fac_detalle_transaccion t,tbl_adm_cama_admision ca ,( select max(a.hora_inicio)  v_fecha, a.pac_id, a.admision ,a.fecha_inicio,a.fecha_final,a.habitacion from tbl_adm_cama_admision a where a.compania = "+compania+" group by a.pac_id , a.admision ,a.fecha_inicio,a.fecha_final,a.habitacion)x where a.compania = "+compania+" and a.estado not in ('N') and (t.compania       = a.compania and to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fDate+"','dd/mm/yyyy'),to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+tDate+"','dd/mm/yyyy'),to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy')) and t.pac_id = a.pac_id and t.fac_secuencia        = a.secuencia and t.inv_almacen       = 4 and t.art_familia       = 34 and t.art_clase         = 1  and t.inv_articulo      in (1,2,3) ) and a.compania = ca.compania and a.pac_id = ca.pac_id  and a.secuencia = ca.admision and to_date(to_char(t.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy')   >= to_date(to_char(ca.fecha_inicio,'dd/mm/yyyy'),'dd/mm/yyyy') and ( x.fecha_final is null	  or  (to_date(to_char(t.fecha_cargo,'dd/mm/yyyy hh:mi:ss am' ),'dd/mm/yyyy hh:mi:ss am') < to_date(to_char(x.fecha_final,'dd/mm/yyyy hh:mi:ss am'),'dd/mm/yyyy hh:mi:ss am'))) and to_date(to_char(ca.hora_inicio,'dd/mm/yyyy hh:mi:ss am'),'dd/mm/yyyy hh:mi:ss am')   = to_date(to_char(x.v_fecha,'dd/mm/yyyy  hh:mi:ss am'),'dd/mm/yyyy  hh:mi:ss am') and x.admision = a.secuencia and x.pac_id = a.pac_id group by t.art_familia,t.art_clase,t.inv_articulo ,t.tipo_transaccion,t.cantidad,t.monto, x.habitacion )yy ";

cdo = SQLMgr.getData(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 55; //max lines of items
	int nLine  = 0;
	int nItems = 55; //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_comida_acomp";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+userId+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;//+"/"+UserDet.getUserId();
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".22");
		setDetail.addElement(".13");
		setDetail.addElement(".13");
		setDetail.addElement(".13");
		setDetail.addElement(".13");
		setDetail.addElement(".13");
		setDetail.addElement(".13");



	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	pdfHeader(pc, _comp, pCounter, nPages, "DEPARTAMENTO DE NUTRICION","COMIDAS DE ACOMPAÑANTES ",  userName, fecha);



	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("DESDE    "+fDate +" HASTA    "+tDate,1,setDetail.size());
	pc.addTable();

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("AREAS",1,1);
		pc.addBorderCols("DESAYUNOS",1,2);
		pc.addBorderCols("ALMUERZOS",1,2);
		pc.addBorderCols("CENA",1,2);
	pc.addTable();

	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols(" ",2,1);
		pc.addBorderCols("Cant.",1,1);
		pc.addBorderCols("Monto",1,1);
		pc.addBorderCols("Cant.",1,1);
		pc.addBorderCols("Monto",1,1);
		pc.addBorderCols("Cant.",1,1);
		pc.addBorderCols("Monto",1,1);
  pc.addTable();


	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols(" CLINICA",1,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_cli_des"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cli_des")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_cli_alm"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cli_alm")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_cli_cena"),1,1);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cli_cena")),2,1);
  pc.addTable();

	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("PEDIATRICO",1,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_ped_des"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_ped_des")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_ped_alm"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_ped_alm")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_ped_cena"),1,1);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_ped_cena")),2,1);
  pc.addTable();
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("RESIDENCIAL",1,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_res_des"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_res_des")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_res_alm"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_res_alm")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("cant_res_cena"),1,1);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_res_cena")),2,1);
  pc.addTable();

	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("TOTALES",1,1);
		pc.addBorderCols(" "+cdo.getColValue("total_des"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("total_monto_des")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("total_alm"),1,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("total_monto_alm")),2,1);
		pc.addBorderCols(" "+cdo.getColValue("total_cena"),1,1);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_monto_cena")),2,1);
  pc.addTable();


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>