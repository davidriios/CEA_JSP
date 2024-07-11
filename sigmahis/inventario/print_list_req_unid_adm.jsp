<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
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
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet=SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbCol = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String tr = request.getParameter("tr");
String tipo = request.getParameter("tipo");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String titulo = "";

if (tr == null || tr.trim().equals("")) throw new Exception("El Tipo de Requisición no es válido. Por favor intente nuevamente!");
if (tipo == null) tipo = "UA";

if (appendFilter == null) appendFilter = "";

if (tr.equalsIgnoreCase("RS")) {//Rechazar solicitud

	sbCol.append(", to_char(a.fecha_creacion,'mm') as mes, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am'),' ') as fecha_doc, decode(a.activa,'S',decode(a.estado_solicitud,'A','S','N'),'N') as entregar");

	titulo = "REQUISICIONES A RECHAZAR";

} else {

	sbCol.append(", to_char(a.fecha_documento,'mm') as mes, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am'),' ') as fecha_doc, ");
	if (!UserDet.getUserProfile().contains("0") && tr.equalsIgnoreCase("EA")) {
		sbCol.append(" case when a.activa = 'S' and a.estado_solicitud = 'A' and a.codigo_almacen_ent in (");
		if (session.getAttribute("_almacen_ua") != null) sbCol.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_almacen_ua")));
		else sbCol.append("-2");
		sbCol.append(") then 'S' else 'N' end");
	} else sbCol.append(" decode(a.activa,'S',decode(a.estado_solicitud,'A','S','N'),'N')");
	sbCol.append(" as entregar");

	if (tr.equalsIgnoreCase("UA")) titulo = "REQUISICION - MATERIALES Y EQUIPOS DE UNIDADES ADM.";
	else if (tr.equalsIgnoreCase("UAT")) titulo = "REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMI. TEMPORALES";
	else if (tr.equalsIgnoreCase("SM")) titulo = "REQUISICION - MATERIALES PARA SERVICIOS DE MANTENIMIENTOS";
	else if (tr.equalsIgnoreCase("EC")) titulo = "REQUISICION - MATERIALES ENTRE COMPAÑIAS";
	else if (tr.equalsIgnoreCase("EA")) titulo = "REQUISICION - MATERIALES ENTRE ALMACENES";
	else if (tr.equalsIgnoreCase("US")) titulo = "REQUISICION - MATERIALES PARA USOS DE SALAS";

}

sbSql = new StringBuffer();
sbSql.append("select a.fecha_creacion as fecha, a.compania, a.anio, a.solicitud_no, a.tipo_solicitud, decode(a.tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as desc_tipo_solicitud, a.estado_solicitud, DECODE(a.estado_solicitud,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') as desc_estado, nvl(a.activa,'N') as activa, a.compania_sol, a.codigo_almacen, a.fecha_creacion, nvl(decode(a.usuario_aprob,'null',' ',a.usuario_aprob),' ') as usuarioAprob, a.codigo_almacen_ent, decode('");
if (tr.equalsIgnoreCase("RS")) sbSql.append(tipo);
else sbSql.append(tr);
sbSql.append("','UA',(select codigo||' '||descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa),'SM',(select codigo||' '||descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa),'EC',(select codigo||' '||descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa),'EA',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen_ent),'US',(select codigo||' '||descripcion from tbl_cds_centro_servicio where codigo = a.codigo_centro and compania_unorg = a.compania),' ') as solicitado_por, decode('");
if (tr.equalsIgnoreCase("RS")) sbSql.append(tipo);
else sbSql.append(tr);
sbSql.append("','UA',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),'SM',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),'EC',(select codigo||' '||nombre from tbl_sec_compania where codigo = a.compania_sol),'EA',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),'US',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),' ') as solicitado_a");
sbSql.append(sbCol);
sbSql.append(" from tbl_inv_solicitud_req a where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(appendFilter);
sbSql.append(" order by 1 desc, 4 desc");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
	int maxLines = 55; //max lines of items
	int nItems = al.size(); //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	//calculating number of page
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_list_req_unid_adm";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);

	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
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
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".07");
		setDetail.addElement(".09");
		setDetail.addElement(".12");
		setDetail.addElement(".23");
		setDetail.addElement(".22");
		setDetail.addElement(".09");
		setDetail.addElement(".09");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	String title = "INVENTARIO";
	String subtitle = titulo;

	pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	pc.setFont(7, 1);
			pc.addBorderCols("",1);
			pc.addBorderCols("Año",1);
			pc.addBorderCols("No. Sol.",1);
			pc.addBorderCols("Tipo Solicitud",1);
			pc.addBorderCols("Fecha Doc.",1);
			pc.addBorderCols("Solicitado por",1);
			pc.addBorderCols("Solicitado a",1);
			pc.addBorderCols("Aprobado por",0);
			pc.addBorderCols("Estado",1);
	pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.createTable();
		pc.setFont(7, 0);
            pc.addCols(""+(1+i),1,1);
			pc.addCols(cdo.getColValue("anio"),1,1,cHeight);
			pc.addCols(cdo.getColValue("solicitud_no"),2,1,cHeight);
			pc.addCols(cdo.getColValue("desc_tipo_solicitud"),1,1,cHeight);
			pc.addCols(cdo.getColValue("fecha_doc"),1,1,cHeight);
			pc.addCols(cdo.getColValue("solicitado_por"),0,1,cHeight);
			pc.addCols(cdo.getColValue("solicitado_a"),0,1,cHeight);
			pc.addCols(cdo.getColValue("usuarioAprob"),0,1,cHeight);
			pc.addCols(cdo.getColValue("desc_estado"),1,1,cHeight);
		pc.addTable();
		lCounter++;


		if (lCounter >= maxLines) {
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
		}
	}//for i

	if (al.size() == 0) {
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	} else {
		pc.createTable();
			pc.addCols(al.size()+" Registros en total",0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>