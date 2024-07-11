<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.cxp.OrdenPago"%>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */
UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo, OP = new CommonDataObject();

String sql = "", key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 

String doc = request.getParameter("doc")==null?"":request.getParameter("doc");
String __fecha = request.getParameter("fecha")==null?"":request.getParameter("fecha");

if (doc.trim().equals("") || __fecha.trim().equals("")) throw new Exception("El número de documento o la fecha es inválido(a)");

	//encabezado
	sql="select a.documento, decode(a.tipo_orden,'O','OTROS') as tipo_orden, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.beneficiario, to_char(a.monto,'999,999,999.00') monto, a.estado1, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc, a.observacion, a.motivo_rechazado, nvl((select descripcion from tbl_cxp_orden_clasificacion where estado = 'A' and codigo = a.clasificacion and rownum = 1),' ') as clasificacion, b.descripcion unidad_descripcion, c.nombre nom_beneficiario, nvl(c.ruc, ' ') ruc, nvl(to_char(c.digito_verificador), ' ') dv, nvl((select e.descripcion from tbl_cxp_usuario_x_unidad u, tbl_sec_unidad_ejec e where u.compania = "+(String) session.getAttribute("_companyId") + " and u.usuario = '"+(String) session.getAttribute("_userName")+"' and u.orden_pago in (1, 3) and (e.compania = u.compania and e.codigo = u.unidad_adm) and u.unidad_adm = a.unidad_adm1 and rownum = 1 ),' ') AS unidad_adm1 from tbl_cxp_orden_unidad a, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c where a.compania = b.compania and a.unidad_adm1 = b.codigo and a.compania = c.compania and a.beneficiario = c.codigo and a.compania = "+(String) session.getAttribute("_companyId") + " and a.documento = "+doc+" and trunc(a.fecha) = to_date('"+__fecha+"', 'dd/mm/yyyy')";
	OP = SQLMgr.getData(sql);
	
	//detalle
	sql="select a.unidad_adm, a.monto, a.observacion2, a.usuario_creacion, b.descripcion nombre_unidad from tbl_cxp_orden_unidad_det a, tbl_sec_unidad_ejec b where a.compania = b.compania and a.unidad_adm = b.codigo and a.compania = "+(String) session.getAttribute("_companyId") + " and a.documento = "+doc+" and trunc(a.fecha) = to_date('"+__fecha+"', 'dd/mm/yyyy') order by 1";
	
    al = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha =cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 20.0f;
	float topMargin = 10.0f;
	float bottomMargin = 0.0f;
	float headerFooterFont = 0f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CUENTAS POR PAGAR";
	String subtitle = "SOLICITUD DE ORDEN DE PAGO";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 14.0f;
	
	double montoTotal = 0.0;

	Vector dHeader = new Vector();
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");
	dHeader.addElement("10");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin * 2);
	footer.setFont(7,0);
	footer.setNoColumn(5);
	footer.createTable();
	footer.addBorderCols("APROBADO POR",1,1,0.0f,0.3f,0.0f,0.0f);
	footer.addCols("",0,1);
	footer.addBorderCols("REVISADO POR",1,1,0.0f,0.3f,0.0f,0.0f);
	footer.addCols("",0,1);
	footer.addBorderCols("VERIFICADO POR",1,1,0.0f,0.3f,0.0f,0.0f);
	
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
		pc.addBorderCols("No.Orden",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("documento"),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Tipo Orden",1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("tipo_orden"),0,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Unidad Solicitante",1,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("unidad_adm1"),0,3,0.1f,0.1f,0.1f,0.1f);
		
		pc.addBorderCols("Estado",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("estado1_desc"),0,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Clasificación",1,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("clasificacion"),0,5,0.1f,0.1f,0.1f,0.1f);
		
		pc.addBorderCols("A favor de",0,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("["+OP.getColValue("beneficiario")+"] "+OP.getColValue("nom_beneficiario"),0,8,0.1f,0.1f,0.1f,0.1f);
		
		pc.addBorderCols("RUC",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("ruc"),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("DV",1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("dv"),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Monto",2,5,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(OP.getColValue("monto"),0,1,0.1f,0.1f,0.1f,0.1f);
		
		pc.setFont(10,1,Color.white);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("AFECTA EL GASTO DE:",0,dHeader.size(),Color.lightGray);
		
		pc.setFont(8,1);
		pc.addBorderCols("Unidad Administrativa",0,5,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Detalle",0,4,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Monto",2,1,0.1f,0.1f,0.1f,0.1f);
		
		pc.setFont(8,0);
		for (int i = 0; i<al.size(); i++){
			cdo = (CommonDataObject)al.get(i);
		    pc.addCols("["+cdo.getColValue("unidad_adm")+"] "+cdo.getColValue("nombre_unidad"),0,5);
			pc.addCols(cdo.getColValue("observacion2"),0,4);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
			montoTotal += Double.parseDouble(cdo.getColValue("monto"));
		}
		
		pc.setFont(9,1);
		pc.addCols("Monto Total",2,9);
		pc.addCols(CmnMgr.getFormattedDecimal(""+montoTotal),2,1);
		
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
