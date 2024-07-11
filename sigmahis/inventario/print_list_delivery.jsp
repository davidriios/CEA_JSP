<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String titulo = "";
String fg = request.getParameter("fg");
String fgFilter = "";

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";

if (fg.equalsIgnoreCase("UA")) {
	fgFilter = " a.pac_anio is null and a.pac_solicitud_no is null and sr.tipo_transferencia = 'U' and a.compania = sr.compania and  ";
	titulo = "TRANSACCIONES - MAT. Y EQUIPOS PARA UNIDADES ADM.";
} else if (fg.equalsIgnoreCase("MP")) {
	fgFilter = "a.pac_anio is not null and a.pac_solicitud_no is not null and ";
	titulo = "TRANSACCIONES - MATERIALES PARA PACIENTES";
} else if (fg.equalsIgnoreCase("EC")) {
	fgFilter =" a.compania_sol = sr.compania and sr.tipo_transferencia = 'C' and ";
	titulo = "TRANSACCIONES - TRANSFERENCIA ENTRE COMPAÑÍAS";
} else if (fg.equalsIgnoreCase("EA")) {
	fgFilter = "a.compania =sr.compania and sr.tipo_transferencia = 'A' and  ";
	titulo = "TRANSACCIONES - TRANSFERENCIA ENTRE ALMACENES";
}

if (fg.equalsIgnoreCase("MP")) {

	sbSql.append("select a.anio, a.no_entrega as noEntrega, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, nvl(a.unidad_administrativa, 0) as unidadAdministrativa, a.pac_anio as reqAnio, a.req_tipo_solicitud as reqTipoSolicitud, decode(a.req_tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL', ' ') as reqTipoSolicitudDesc, a.pac_solicitud_no as reqSolicitudNo, a.codigo_almacen as codigoAlmacen, nvl(a.monto,0) as monto, b.descripcion as nombreAlmacen, ' ' as unidadAdminDesc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) as paciente, nvl(d.descripcion,' ') centroServDesc from tbl_inv_entrega_material a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d where ");
	sbSql.append(fgFilter);
	sbSql.append(" a.compania=b.compania and a.codigo_almacen=b.codigo_almacen and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" and a.pac_id = c.pac_id(+) and a.centro_servicio = d.codigo(+) order by a.codigo_almacen  asc, a.anio desc ,a.no_entrega desc");

} else {

	sbSql.append("select a.anio, a.no_entrega as noEntrega, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, a.unidad_administrativa as unidadAdministrativa, a.req_anio as reqAnio, a.req_tipo_solicitud as reqTipoSolicitud, decode(a.req_tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as reqTipoSolicitudDesc, a.req_solicitud_no as reqSolicitudNo, a.codigo_almacen as codigoAlmacen, nvl(a.monto,0) as monto, b.descripcion as nombreAlmacen, decode(sr.tipo_transferencia,'U',decode(a.unidad_administrativa,'7',decode(sr.codigo_centro,null,c.codigo||' '||c.descripcion,c.descripcion||' -- '||cs.codigo||' '||cs.descripcion),c.codigo||' '||c.descripcion ) ,'A', al.codigo_almacen||' '||al.descripcion,'C',c.codigo||' '||c.descripcion)  as unidadAdminDesc from tbl_inv_entrega_material a,tbl_inv_almacen al, tbl_inv_almacen b, tbl_sec_unidad_ejec c,tbl_inv_solicitud_req sr,tbl_cds_centro_servicio cs where ");
	sbSql.append(fgFilter);
	sbSql.append("  a.req_anio = sr.anio  and a.req_tipo_solicitud = sr.tipo_solicitud and a.req_solicitud_no = sr.solicitud_no and sr.compania=al.compania and sr.codigo_almacen=al.codigo_almacen and a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.compania_sol=c.compania(+) and a.unidad_administrativa=c.codigo(+) and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" and cs.codigo(+) = sr.codigo_centro  order by a.codigo_almacen  asc, a.anio desc ,a.no_entrega desc");

}
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
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
	String title = "INVENTARIO";
	String subtitle = titulo;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	if (fg.equalsIgnoreCase("MP")) {

		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".10");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".31");
		dHeader.addElement(".31");

	} else {

		dHeader.addElement(".05");
        
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".18");
		dHeader.addElement(".30");
		dHeader.addElement(".10");

	}

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Entrega",1,3);
		pc.addBorderCols("Requisicion",1,dHeader.size()-3);

		pc.addBorderCols("",1);
		pc.addBorderCols("Año",1);
		pc.addBorderCols("No.",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Año",1);
		pc.addBorderCols("No.",1);
		pc.addBorderCols((fg.equalsIgnoreCase("MP"))?"Nombre Paciente":"Tipo Solic.",1);
		pc.addBorderCols("Solicitado Por.",1);
		if (!fg.equalsIgnoreCase("MP")) pc.addBorderCols("Monto",1);
	pc.setTableHeader(3);//create de table header (3 rows) and add header to the table

	//table body
	String groupBy = "";
	double tMonto = 0.0;
	for (int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		tMonto += Double.parseDouble(cdo.getColValue("monto"));

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigoAlmacen"))) {

			pc.setFont(7,1);
			pc.addCols(" [ "+cdo.getColValue("nombreAlmacen")+" ] ",0,dHeader.size());

		}

		pc.setFont(7, 0);
		pc.addCols(""+(1+i),1,1);
		pc.addCols(cdo.getColValue("anio"),0,1);
		pc.addCols(cdo.getColValue("noEntrega"),0,1);
		pc.addCols(cdo.getColValue("fechaEntrega"),1,1);
		pc.addCols(cdo.getColValue("reqAnio"),1,1);
		pc.addCols(cdo.getColValue("reqSolicitudNo"),0,1);
		pc.addCols((fg.equalsIgnoreCase("MP")?cdo.getColValue("paciente"):cdo.getColValue("reqTipoSolicitudDesc")),0,1);
		pc.addCols((fg.equalsIgnoreCase("MP")?cdo.getColValue("centroServDesc"):cdo.getColValue("unidadAdminDesc")),0,1);
		if (!fg.equalsIgnoreCase("MP")) pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("codigoAlmacen");
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {

		pc.addCols(al.size()+" Registro(s) en total",0,(fg.equalsIgnoreCase("MP"))?dHeader.size():dHeader.size()-3);
		if (!fg.equalsIgnoreCase("MP")) pc.addCols(CmnMgr.getFormattedDecimal(tMonto),2,3);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>