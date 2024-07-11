<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
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
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
	 sbSql.append("select a.enviado, to_char(a.fecha_recibido, 'dd/mm/yyyy') fecha_recibido, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_modificacion, to_char(a.system_date, 'dd/mm/yyyy') system_date, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.usuario_creacion, a.enviado_por, a.comentario, a.lista, a.aseguradora, (select nombre from tbl_adm_empresa e where e.codigo = a.aseguradora) aseguradora_desc, to_char(a.fecha_envio, 'dd/mm/yyyy') fecha_envio, a.compania, a.id, (select name from tbl_sec_users where user_name = a.usuario_creacion) usuario_creacion_name, decode(a.enviado, 'S', 'Si', 'N', 'No', a.enviado) enviado_desc, nvl((select name from tbl_sec_users where user_name = a.enviado_por ), '') enviado_por_name, decode(a.estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc,to_char(a.fecha_recibido_cxc, 'dd/mm/yyyy')as  fecha_recibido_cxc from tbl_fac_lista_envio a ");
  sbSql.append(" where a.compania = ");
  sbSql.append(session.getAttribute("_companyId"));
  sbSql.append(appendFilter);
  sbSql.append(" order by a.fecha_creacion desc");


al = SQLMgr.getDataList(sbSql.toString());

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "LISTAS DE ENVIO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		
	dHeader.addElement(".25");
	dHeader.addElement(".06");
	dHeader.addElement(".15");
	dHeader.addElement(".06");
	dHeader.addElement(".05");
	dHeader.addElement(".05");
	dHeader.addElement(".08");
	dHeader.addElement(".16");
	dHeader.addElement(".08");
	dHeader.addElement(".06");
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		
		pc.addBorderCols("Aseguradora",1);
		pc.addBorderCols("Fecha Creación",1);
		pc.addBorderCols("Usuario Creación",1);
		pc.addBorderCols("Fecha CXC",1);
		pc.addBorderCols("Lista/ID",1);
		pc.addBorderCols("Enviado",1);
		pc.addBorderCols("Fecha Envío",1);
		pc.addBorderCols("Enviado por",1);
		pc.addBorderCols("F. Recibido",1);
		pc.addBorderCols("Estado",1);
			
		
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
		

	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
	
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		pc.addCols(cdo.getColValue("aseguradora_desc"),0,1);
		pc.addCols(cdo.getColValue("fecha_creacion"),1,1);
		pc.addCols(cdo.getColValue("usuario_creacion_name"),0,1);
		pc.addCols(cdo.getColValue("fecha_recibido_cxc"),1,1);
		pc.addCols(cdo.getColValue("lista")+" ["+cdo.getColValue("id")+"]",1,1);
		pc.addCols(cdo.getColValue("enviado_desc"),1,1);
		pc.addCols(cdo.getColValue("fecha_envio"),1,1);
		pc.addCols(cdo.getColValue("enviado_por_name"),0,1);
		pc.addCols(cdo.getColValue("fecha_recibido"),1,1);
		pc.addCols(cdo.getColValue("estado_desc"),1,1);
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>