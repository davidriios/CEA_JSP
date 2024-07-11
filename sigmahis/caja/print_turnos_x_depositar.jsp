<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/*
=======================================================================================================
Reporte   TURNOS POR DEPOSITAR
=======================================================================================================
*/

SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
  UserDet=SecMgr.getUserDetails(session.getId());
  session.setAttribute("UserDet",UserDet);
  issi.admin.ISSILogger.setSession(session);
  CmnMgr.setConnection(ConMgr);
  SQLMgr.setConnection(ConMgr);
  CommonDataObject cdo = new CommonDataObject();
  String strCondicion = "";
  String appendFilter = request.getParameter("appendFilter");
  if(appendFilter== null)appendFilter="";
  String caja = request.getParameter("caja");
  String turno = request.getParameter("turno");
  String compania = request.getParameter("compania");
  String fecha_ini = request.getParameter("fechaini");
  String fecha_fin = request.getParameter("fechafin");
  String descCaja = request.getParameter("descCaja");
  String observacion = request.getParameter("observacion");
  String secuencia = request.getParameter("secuencia");
  String tipoCliente = request.getParameter("tipoCliente");
  String periodo = "";
  String fg = request.getParameter("fg");
  String regType = request.getParameter("regType");
  String tipoDep = request.getParameter("tipoDep");
  String fechaDesde = request.getParameter("fechaDesde");
  String fechaHasta = request.getParameter("fechaHasta");
  String sql = "", appendOrder="";
  String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
  String userName = UserDet.getUserName();
  ArrayList al   = new ArrayList();
  StringBuffer sbSql = new StringBuffer();

  if (observacion==null) observacion="";
  if (fecha_ini==null) fecha_ini = "";
  if (fecha_fin==null) fecha_fin = "";
  if (turno==null) turno = "";
  if (secuencia==null) secuencia = "";
  if (tipoCliente==null) tipoCliente = "";
  if (fg==null) fg = "";
  if (regType==null) regType = "EF";
  if (fechaDesde == null) fechaDesde = "";
if (fechaHasta == null) fechaHasta = "";

sbSql = new StringBuffer();
sbSql.append(" select codigo ||' - ' || descripcion as descripcion, get_sec_comp_param(-1, 'CJA_TP_MOV_TRANS') tipo_dep_transf from tbl_con_tipo_deposito where  codigo =");
sbSql.append(tipoDep);
cdo = SQLMgr.getData(sbSql);

sbSql = new StringBuffer();
sbSql.append("select x.* ,");

if(regType.trim().equals("EF")){
sbSql.append(" (nvl(x.efectivo,0)+nvl(x.cheque,0)) total_cierre, case when (nvl(x.efectivo,0)+nvl(x.cheque,0))-nvl(x.otros,0) > (nvl(x.total_cash,0)+nvl(x.total_cheque,0)) then (nvl(x.efectivo,0)+nvl(x.cheque,0)) -nvl(x.otros,0)-(nvl(x.total_cash,0)+nvl(x.total_cheque,0))  else 0 end as faltante,case when (nvl(x.efectivo,0)+nvl(x.cheque,0)-nvl(x.otros,0)) < (nvl(x.total_cash,0)+nvl(x.total_cheque,0)) then (nvl(x.total_cash,0)+nvl(x.total_cheque,0)-nvl(x.otros,0))-(nvl(x.efectivo,0)+nvl(x.cheque,0)) else 0 end as sobrante ");}
else if(regType.trim().equals("ACH"))
{
sbSql.append(" nvl(x.depAch,0) as total_cierre, case when nvl(x.depAch,0) > nvl(x.depositos,0) then nvl(x.depAch,0) - nvl(x.depositos,0) else 0 end as faltante,case when nvl(x.depAch,0) < nvl(x.depositos,0) then nvl(x.depositos,0)-nvl(x.depAch,0) else 0 end as sobrante ");
}
else
{
sbSql.append(" (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) as total_cierre, case when (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) > nvl(x.tarjetasCierre,0) then (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) - nvl(x.tarjetasCierre,0) else 0 end as faltante,case when (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) < nvl(x.tarjetasCierre,0) then nvl(x.tarjetasCierre,0)-(nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) else 0 end as sobrante ");
}

sbSql.append(" from (select a.session_id turno, nvl(a.total_cash,0) total_cash , nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_EFECTIVO'),0) as efectivo,nvl(a.total_cheque,0)as total_cheque,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_CHEQUE'),0) as cheque,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TARJETAS_DB'),0) as tarjetasDb,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TARJETAS_CR'),0) as tarjetasCr,nvl(a.total_accdeposit,0) as depositos, nvl(a.total_creditcard,0)+nvl(a.total_debitcard,0) as tarjetasCierre,nvl(a.final_total,0)as final_total,/*nvl((select nvl(sum(nvl(tp.pago_total,0)),0) as pago_total from tbl_cja_transaccion_pago tp where tp.compania = a.company_id and tp.turno = a.session_id and (tp.rec_status = 'A' or (tp.rec_status = 'I' and tp.turno <> tp.turno_anulacion))),0) total_cja,*/ nvl(a.otros,0)as otros,tc.cod_caja caja,to_char(t.fecha, 'dd/mm/yyyy') fecha,c.nombre nombre_cajera, d.descripcion nombre_caja,0 montoDevTarjeta,a.depositar,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TRANS_ACH'),0) as depAch");
if(regType.trim().equals("EF"))sbSql.append(" ,nvl(a.diferencia,-0) ");
else if(regType.trim().equals("TR"))sbSql.append(" ,nvl(a.dif_tarjeta,-0) ");
else if(regType.trim().equals("ACH"))sbSql.append(" ,nvl(a.dif_ach,-0) ");
sbSql.append(" as diferencia from tbl_cja_sesdetails a,tbl_cja_turnos t,tbl_cja_turnos_x_cajas tc, tbl_cja_cajera c, tbl_cja_cajas d  where a.session_id =t.codigo and a.company_id =t.compania and a.company_id =");
 sbSql.append((String) session.getAttribute("_companyId"));
 if(fg.equals("DEP"))sbSql.append(" and a.depositar='S'");
else sbSql.append(" and a.depositar='N'");

if (!fechaDesde.trim().equals("")){ sbSql.append(" and t.fecha >=to_date('");sbSql.append(fechaDesde);sbSql.append("','dd/mm/yyyy')");}
if (!fechaHasta.trim().equals("")){ sbSql.append(" and t.fecha <=to_date('");sbSql.append(fechaHasta);sbSql.append("','dd/mm/yyyy')");}
 
sbSql.append(" and tc.cod_turno = t.codigo and t.cja_cajera_cod_cajera = c.cod_cajera and tc.cod_caja = d.codigo and tc.compania = d.compania and tc.compania = c.compania and not exists (select null from tbl_cja_turno_cierre y where y.estado = 'A' and y.turno = a.session_id and y.compania = a.company_id and y.reg_type ='");
sbSql.append(regType);
sbSql.append("') /*and  not exists (select 1 from (select to_number(nvl(column_value,-1)) turnos  from table( select split((select join(cursor(select nvl(mb.turnos_cierre,'-1') from tbl_con_movim_bancario mb where turnos_cierre is not null and reg_type ='");
sbSql.append(regType);
sbSql.append("' and compania =");
sbSql.append((String) session.getAttribute("_companyId"));
//select join(cursor(select nvl(mb.turnos_cierre,'-1') from tbl_con_movim_bancario mb where mb.compania =1 and turnos_cierre is not null and compania =1),'|') from dual
sbSql.append("),'|') from dual ),'|') from dual )) y where  y.turnos =a.session_id)*/ ");

sbSql.append(" ) x ");
if(regType.trim().equals("EF")){sbSql.append(" where  ((nvl(efectivo,0) + nvl(cheque,0))<> 0  or  (nvl(total_cash,0)+ nvl(total_cheque,0)) <> 0) ");}
else if(regType.trim().equals("ACH")){sbSql.append(" where  (nvl(depAch,0) <> 0  or  nvl(depositos,0) <> 0) ");}
else sbSql.append(" where  ((nvl(tarjetasCr,0) + nvl(tarjetasDb,0))<> 0  or nvl(tarjetasCierre,0)<> 0)");
sbSql.append("order by x.caja,x.turno");

al = SQLMgr.getDataList(sbSql.toString());

  if(request.getMethod().equalsIgnoreCase("GET")) {

    double montoTotal = 0.00;
    double subTotal = 0.00;
    double pendiente = 0.00;
    String r_caja = "";
    String descripcion = "";
    int recibo = 0, reciboCaja = 0;

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam")+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float dispHeight = 0.0f;//altura disponible para el ciclo for
	float headerHeight = 0.0f;//tamaño del encabezado
	float innerHeight = 0.0f;//tamaño del detalle
	float footerHeight = 0.0f;//tamaño del footer
	float modHeight = 0.0f;//tamaño del relleno en blanco
	float antHeight = 0.0f;//
	float finHeight = 0.0f;//
	float extra = 0.0f;//
	float total = 0.0f;//
	float innerTableHeight = 0.0f;
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CAJA";
	String subtitle = "TURNOS "+(fg.equals("DEP")?" PARA DEPOSITAR":"PENDIENTES POR DEPOSITAR");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	float cHeight = 25.0f;
	int  j = 0;

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	Vector dHeader = new Vector();
		dHeader.addElement(".17");
		dHeader.addElement(".08");
		dHeader.addElement(".17");
		dHeader.addElement(".08");
		
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

		footer.setNoColumnFixWidth(dHeader);
		footer.createTable();
		footer.setFont(8, 0);
		footer.addCols("Observaciones: ",0,dHeader.size());
		footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.addBorderCols(" DEPOSITOS DE:"+cdo.getColValue("descripcion"),1,dHeader.size());

	pc.addBorderCols("Caja",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("F. Turno",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Cajer@",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Turno",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Tot. Sist.",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	if(regType.trim().equals("EF")){
	pc.addBorderCols("Efectivo",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Cheque",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Otros",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("SOB./FALT.",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	}
	else if(tipoDep.equals(cdo.getColValue("tipo_dep_transf")))
	{
	pc.addBorderCols("DB",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("CR",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("SOB./FALT.",2,2 ,0.5f, 0.5f, 0.0f, 0.5f);
	}else
	{
	pc.addBorderCols("Tarjeta DB",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Tarjeta CR",2,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("SOB./FALT.",2,2 ,0.5f, 0.5f, 0.0f, 0.5f);
	}
	
	
	
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);

	String groupByCaja	 = "";
	String diferencia ="0";
    Double totCierre =0.00,totEfectivo=0.00,totCheque=0.00,totOtros=0.00,totTarjetasDb=0.00,totTarjetasCr=0.00,totDiferencia=0.00;
	for (int i=0; i<al.size(); i++)
	{
		 diferencia = "0";
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		pc.setFont(7, 0);
		pc.addCols(cdo1.getColValue("nombre_caja"), 0,1);
		pc.addCols(cdo1.getColValue("fecha"), 0,1);
		pc.addCols(cdo1.getColValue("nombre_cajera"), 0,1);
		pc.addCols(cdo1.getColValue("turno"), 0,1);	
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("total_cierre")), 2,1);
		if(regType.trim().equals("EF")){
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("efectivo")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("cheque")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("otros")), 2,1);
		}else{
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("tarjetasDb")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("tarjetasCr")), 2,1);
		
		}
		
		
		if(cdo1.getColValue("diferencia") !=null && !cdo1.getColValue("diferencia").trim().equals("")&& !cdo1.getColValue("diferencia").trim().equals("-0") )diferencia = cdo1.getColValue("diferencia");
		/*else{
		if(cdo1.getColValue("faltante") !=null && !cdo1.getColValue("faltante").trim().equals("")&& !cdo1.getColValue("faltante").trim().equals("0"))
		diferencia = cdo1.getColValue("faltante");
		else if(cdo1.getColValue("sobrante") !=null && !cdo1.getColValue("sobrante").trim().equals("")&& !cdo1.getColValue("sobrante").trim().equals("0"))
		diferencia = cdo1.getColValue("sobrante");}*/
		if(Double.parseDouble(diferencia)<0)
		 pc.addCols("("+CmnMgr.getFormattedDecimal("###,##0.00",(Double.parseDouble(diferencia)*-1))+")", 2,((regType.trim().equals("EF"))?1:2));
		else pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00",diferencia), 2,((regType.trim().equals("EF"))?1:2));
		
		
		
		totCierre += Double.parseDouble(cdo1.getColValue("total_cierre"));
		totEfectivo += Double.parseDouble(cdo1.getColValue("efectivo"));
		totCheque += Double.parseDouble(cdo1.getColValue("cheque"));
		totOtros += Double.parseDouble(cdo1.getColValue("otros"));
		totTarjetasDb += Double.parseDouble(cdo1.getColValue("tarjetasDb"));
		totTarjetasCr += Double.parseDouble(cdo1.getColValue("tarjetasCr"));
		totDiferencia  += Double.parseDouble(diferencia);
		

	} // fin del ciclo for
	if (al.size() == 0) pc.addCols("No existen registros ",1,dHeader.size());
	else
	{
		pc.addCols(" ", 0,dHeader.size()); 
		pc.setFont(8, 0,Color.blue);
		pc.addCols("TOTALES: ", 1,4); 
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00",totCierre), 2,1);
		if(regType.trim().equals("EF")){
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", totEfectivo), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", totCheque), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", totOtros), 2,1);
		}else{
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", totTarjetasDb), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00", totTarjetasCr), 2,1);
		
		}
		
		if(totDiferencia<0)
		 pc.addCols("("+CmnMgr.getFormattedDecimal("###,##0.00",(totDiferencia*-1))+")", 2,((regType.trim().equals("EF"))?1:2));
		else pc.addCols(""+CmnMgr.getFormattedDecimal("###,##0.00",totDiferencia), 2,((regType.trim().equals("EF"))?1:2));
		
	
	}
	 

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

 }//GET

%>






