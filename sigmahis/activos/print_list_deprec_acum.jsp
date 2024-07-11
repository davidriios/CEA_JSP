<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/*
REPORTE DE ACTIVOS DEPRECIADOS   ACT0010.REF / ACT612.RDF

*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDet = new ArrayList();
String sql = "";
String sqlT = "";
String sqlU = "";

String desde = request.getParameter("desde");
String hasta  = request.getParameter("hasta");
String cuenta  = request.getParameter("cuenta");
String unidad  = request.getParameter("unidad");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(unidad == null) unidad = "";

if (!unidad.equals(""))
{
 appendFilter += " and a.ue_codigo = '"+unidad+"'";
}
if (!desde.equals(""))
{
 appendFilter += " and a.fecha_de_entrada >= '"+desde+"'";
}
if (!hasta.equals(""))
{
 appendFilter += " and a.fecha_de_entrada <= '"+hasta+"'";
}


sql= "select to_char(a.fecha_de_entrada,'dd/mm/yy') entrada, a.valor_inicial, m.monto_depre valor_deprem, to_char(a.final_garantia,'dd/mm/yy') final, a.secuencia, m.valor_activo_act  valor_actual, m.valor_act_ant valor_anterior, d.descripcion, ue.codigo, ue.descripcion unidad, a.observacion, e.descripcion desr, m.depre_acum_act, m.cd_ano anio, m.cd_mes mes from tbl_con_deprec_mensual m, tbl_con_activos a, tbl_con_detalle_otro d, tbl_sec_unidad_ejec ue, tbl_con_especificacion e where a.secuencia = m.activo_sec and a.compania = m.compania and a.compania ="+(String) session.getAttribute("_companyId")+appendFilter+ " and a.cuentah_detalle = d.codigo_detalle and a.compania = d.cod_compania and a.compania = ue.compania and a.ue_codigo = ue.codigo and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania order by a.secuencia, a.fecha_de_entrada";
 al = SQLMgr.getDataList(sql);

System.out.print("\n\n extraItems "+sql+"\n\n");

//sqlT = "select to_char(to_date(max(mes)||'/'||max(ano),'mm/yyyy'),' fmMonth yyyy','NLS_DATE_LANGUAGE=SPANISH') mes from tbl_con_control_depre where compania = 1 and estatus = 'CER'";

  double monto_total = 0.00,monto_total_ini =0.00,monto_total_dep=0.00;
	double total_act   = 0.00,total_ini =0.00,total_dep=0.00;
	double total_cta_act   = 0.00,total_cta_ini =0.00,total_cta_dep=0.00;


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String title = "CONTABILIDAD";
	String subtitle = "Listado de Activos Depreciados ";
	String xtraSubtitle = "" ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dDetalle = new Vector();
		dDetalle.addElement(".10");
		dDetalle.addElement(".40");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");


 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(6, 1);



	   int no = 0;
		 String cta = "";
		 String esp = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


		if(!esp.trim().equals(cdo.getColValue("mes")))
		{
		 if(i!=0)
		 {
		 pc.addCols("Total :  "+CmnMgr.getFormattedDecimal(total_act),2,6);
		 pc.addCols(" "+CmnMgr.getFormattedDecimal(total_dep),2,1);
		 total_act=0;
		 total_dep=0;
		 }

		pc.addCols(" Año :  "+cdo.getColValue("anio")+"   Mes :  "+cdo.getColValue("mes"),0,7);

		pc.addCols("Sec.",0,1);
		pc.addCols("Descripción ",0,1);
		pc.addCols("Valor Inicial ",2,1);
		pc.addCols("Valor Anterior ",2,1);
		pc.addCols("Monto Deprec. ",2,1);
		pc.addCols("Valor Actual ",2,1);
		pc.addCols("Deprec. Acum ",2,1);


		}

		pc.setFont(6, 0);
		pc.setVAlignment(0);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo.getColValue("secuencia"),0,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_inicial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_anterior")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_deprem")),2,1);
		  pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_actual")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("depre_acum_act")),2,1);


		esp  = cdo.getColValue("mes");
		total_act  += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_dep  += Double.parseDouble(cdo.getColValue("depre_acum_act"));

		total_cta_act += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_cta_dep += Double.parseDouble(cdo.getColValue("depre_acum_act"));

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
		pc.addCols("Total :  "+CmnMgr.getFormattedDecimal(total_act),2,6);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_dep),2,1);

		pc.addCols(" Total General :   "+CmnMgr.getFormattedDecimal(total_cta_act),2,6);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_dep),2,1);


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>