<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
String num_cheque = request.getParameter("num_cheque");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String tipo = request.getParameter("tipo");
String fg = request.getParameter("fg");

String compania = (String) session.getAttribute("_companyId");
if(appendFilter == null)appendFilter="";
if(tipo == null)tipo="N";

	sbSql.append("select distinct a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.beneficiario, a.monto_girado, to_char(a.f_emision,'dd/mm/yyyy') as f_emision, a.estado_cheque, decode(a.estado_cheque,'G','Girado') as estado_desc, a.anio, a.num_orden_pago");
	sbSql.append(", (select nombre from tbl_con_banco where compania = a.cod_compania and cod_banco = a.cod_banco) as nombre_banco");
	sbSql.append(", (select descripcion from tbl_con_cuenta_bancaria where cod_banco = a.cod_banco and compania = a.cod_compania and cuenta_banco = a.cuenta_banco) as nombre_cuenta");
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(", (case when d.monto != a.monto_girado or e.numero_factura in ('0','00') then 'F' when d.monto = a.monto_girado and e.numero_factura not in ('0','00') then 'V' else 'N' end) as tipo");
	else sbSql.append(", (case when d.monto != a.monto_girado or d.num_fact in ('0','00') then 'F' when d.monto = a.monto_girado and d.num_fact not in ('0','00') then 'V' else 'N' end) as tipo");
	sbSql.append(", decode(odp.cod_medico,null,decode(odp.cod_empresa,null,' ','E'),'M') as tipoBenef, odp.num_id_beneficiario, odp.cod_tipo_orden_pago");
	sbSql.append(" from tbl_con_cheque a, (select cod_compania, anio, num_orden_pago, sum(monto + nvl(itbm,0)) as monto");
	if (fg.equalsIgnoreCase("HON")) sbSql.append(", nvl(numero_factura,'0') as num_fact");
	sbSql.append(" from tbl_cxp_orden_de_pago_fact where tipo_docto = 'FAC' group by cod_compania, anio, num_orden_pago");
	if (fg.equalsIgnoreCase("HON")) sbSql.append(", nvl(numero_factura,'0')");
	sbSql.append(") d");
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(", tbl_cxp_orden_de_pago_fact e");
	sbSql.append(", tbl_cxp_orden_de_pago odp");
	sbSql.append(" where a.estado_cheque in ('G','P') and a.cod_compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(" and a.cod_compania_odp = d.cod_compania and a.anio = d.anio and a.num_orden_pago = d.num_orden_pago and a.cod_compania_odp = e.cod_compania and a.anio = e.anio and a.num_orden_pago = e.num_orden_pago and e.tipo_docto = 'FAC'");
	else sbSql.append(" and a.cod_compania_odp = d.cod_compania(+) and a.anio = d.anio(+) and a.num_orden_pago = d.num_orden_pago(+) and odp.generado <> 'H'");
	if (!fg.equalsIgnoreCase("HON")) {
		if (tipo.equalsIgnoreCase("N")) sbSql.append(" and (d.monto != a.monto_girado or nvl(e.numero_factura,'0') in ('0','00'))");
		else sbSql.append(" and (d.monto = a.monto_girado and e.numero_factura not in ('0','00'))");
	} else {
		if (tipo.equalsIgnoreCase("N")) sbSql.append(" and (d.monto != a.monto_girado or nvl(d.num_fact,'0') in ('0','00'))");
		else sbSql.append(" and (d.monto = a.monto_girado and d.num_fact not in ('0','00'))");
	}
	sbSql.append(" and odp.cod_tipo_orden_pago");
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(" in ( select column_value  from table( select split((select get_sec_comp_param(a.cod_compania,'CXP_TIPO_ORD_PAGO') from dual),',') from dual  )) ");
	else sbSql.append(" in (1,3)");
	sbSql.append(" and a.cod_compania_odp = odp.cod_compania and a.anio = odp.anio and a.num_orden_pago = odp.num_orden_pago order by a.cod_banco, f_emision desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = fecha.substring(3, 5);;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

		if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "LISTADO DE PAGOS SIN FACTURA";
	String subtitle = (tipo.equalsIgnoreCase("F"))?"- FACTURAS APLICADAS -":"- FACTURAS NO APLICADAS -";
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	String groupBy = "", groupBy2 = "", groupBy3 = "";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("No. Cheque",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CUENTA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("BANCARIA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("BENEFICIARIO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MONTO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA EMISION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ESTADO",1,1,cHeight * 2,Color.lightGray);

	pc.setTableHeader(2);

	double totUnidad = 0.00;
	int pxc = 0;
	int pxcat = 0;
	int pcant = 0;
	String pacId = "", admision = "";
	for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_banco"))){ // groupBy
			if (i != 0){
				pc.setFont(7, 1);
				pc.addCols("TOTAL X BANCO: ",2,4,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				pc.addCols("",0,2,cHeight);
				pc.addCols(" ",0,dHeader.size(),cHeight);
				totUnidad   = 0.00;
			}
			pc.addCols(" [ "+cdo.getColValue("cod_banco") + " ] " + cdo.getColValue("nombre_banco"),0,dHeader.size(),cHeight);
		}// groupBy

		pc.setFont(7, 0);

		pc.addCols(" "+cdo.getColValue("num_cheque"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("cuenta_banco"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombre_cuenta"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("beneficiario"),0,1,cHeight);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado")),2,1,cHeight);
		pc.addCols(" "+cdo.getColValue("f_emision"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("estado_desc"),1,1,cHeight);

		totUnidad += Double.parseDouble(cdo.getColValue("monto_girado"));

		groupBy = cdo.getColValue("cod_banco");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,dHeader.size());
	}	else {
			pc.setFont(7, 1);
				pc.addCols("TOTAL X BANCO: ",2,4,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				pc.addCols("",0,2,cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

