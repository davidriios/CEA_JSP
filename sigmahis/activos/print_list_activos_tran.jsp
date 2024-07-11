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
REPORTE DE ACTIVOS MOVIMIENTO   ACT006.RDF

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
String placa  = request.getParameter("placa");
String tipoTransf  = request.getParameter("tipoTransf");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(cuenta == null) cuenta = "";
if(placa == null) placa = "";
if(tipoTransf == null) tipoTransf = "";
if (!cuenta.equals(""))
{
 appendFilter += " and c.cta1_activo||'.'||c.cta2_activo||'.'||c.cta3_activo||'.'||c.cta4_activo||'.'||c.cta5_activo||'.'|| c.cta6_activo  like '"+cuenta+"%'";
}
if (!desde.equals(""))
{
 appendFilter += " and a.fecha_de_entrada >= to_date('"+desde+"','dd/mm/yyyy')";
}
if (!hasta.equals(""))
{
 appendFilter += " and a.fecha_de_entrada <= to_date('"+hasta+"','dd/mm/yyyy')";
}
if (!tipoTransf.equals(""))
{
 appendFilter += " and t.tipo_transf = '"+tipoTransf+"'";
}


if (!placa.equals(""))
{
 appendFilter += " and a.secuencia = '"+placa+"'";
}
sql = " select a.secuencia, d.descripcion, to_char(t.fecha_transaccion,'dd/mm/yyyy') fecha, t.num_doc, to_char(t.fecha_envio,'dd/mm/yyyy') envio, to_char(t.fecha_finalizacion,'dd/mm/yyyy') final, ue.descripcion unid_destino, t.unid_remitente, decode(t.tipo_transf,'DEFINI','Permanente','TEMP','Temporal') tipo_transf, to_char(m.fecha_transaccion,'dd/mm/yyyy') fecha_mejora, m.n_mejora, m.valor monto from tbl_sec_unidad_ejec ue,	tbl_con_detalle d, tbl_con_detalle_transfs dt, tbl_con_transferencia t, tbl_con_mejora m, tbl_con_activos a where ue.codigo(+) = t.unid_destino and dt.act_secue(+) = a.secuencia and t.num_doc(+) = dt.tras_num and d.cod_espec = a.cuentah_activo and d.codigo_subesp = a.cuentah_espec and d.codigo_detalle = a.cuentah_detalle and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.cod_compania = a.compania and t.compania = a.compania and dt.tras_compania = a.compania order by a.secuencia";

al = SQLMgr.getDataList(sql);


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
	String subtitle = "ADMINISTRACION DE BIENES PATRIMONIALES";
	String xtraSubtitle = "INFORME DE MOVIMIENTO DE UN ACTIVO";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dDetalle = new Vector();
		dDetalle.addElement(".12");
		dDetalle.addElement(".13");
		dDetalle.addElement(".12");
		dDetalle.addElement(".13");
		dDetalle.addElement(".10");
		dDetalle.addElement(".20");
		dDetalle.addElement(".20");

 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(6, 1);
	    int no = 0;
		 String cod = "";
		 String esp = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(!cod.trim().equals(cdo.getColValue("secuencia")))
		{
		pc.setFont(6, 1);
		pc.addCols("  PLACA :    "+cdo.getColValue("secuencia")+"    "+cdo.getColValue("descripcion"),0,dDetalle.size());
		}
		pc.setNoColumnFixWidth(dDetalle);

		pc.addCols("     Transferencias  ",0,dDetalle.size());

		pc.addCols("Fecha de Transacción",1,1);
		pc.addCols("No. Documento ",0,1);
		pc.addCols("Fecha Envio ",1,1);
		pc.addCols("Fecha de Finalización ",1,1);
		pc.addCols("Tipo ",1,1);
		pc.addCols("Unidad Destino ",1,1);
		pc.addCols("Unidad Remitente ",1,1);

		pc.setFont(6, 0);
		pc.setVAlignment(0);

			pc.addCols(" "+cdo.getColValue("fecha"),0,1);
			pc.addCols(" "+cdo.getColValue("num_doc"),0,1);
			pc.addCols(" "+cdo.getColValue("envio"),1,1);
			pc.addCols(" "+cdo.getColValue("final"),1,1);
			pc.addCols(" "+cdo.getColValue("tipo_transf"),1,1);
			pc.addCols(" "+cdo.getColValue("unid_destino"),0,1);
			pc.addCols(" "+cdo.getColValue("unid_remitente"),1,1);

		pc.addCols(" ",0,dDetalle.size());
		pc.addCols("     Mejoras  ",0,dDetalle.size());

		pc.addCols("Fecha de Mejora",1,2);
		pc.addCols("No. Documento ",1,1);
		pc.addCols("Monto ",1,2);
		pc.addCols(" ",0,2);

		pc.addCols(" "+cdo.getColValue("fecha_mejora"),1,2);
		pc.addCols(" "+cdo.getColValue("n_mejora"),1,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,2);
		pc.addCols(" ",0,2);

		cod  = cdo.getColValue("secuencia");

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
	pc.addCols("  ",0,dDetalle.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>