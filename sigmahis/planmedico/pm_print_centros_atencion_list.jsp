<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String nombre = (request.getParameter("nombre")==null?"":request.getParameter("nombre"));
String ruc = (request.getParameter("ruc")==null?"":request.getParameter("ruc"));
String estado = (request.getParameter("estado")==null?"":request.getParameter("estado"));
String telefono = (request.getParameter("telefono")==null?"":request.getParameter("telefono"));
String idEmpresa = (request.getParameter("idEmpresa")==null?"":request.getParameter("idEmpresa"));

StringBuffer sbSql = new StringBuffer();

sbSql.append("select c.id id_centro, c.nombre, c.ruc, c.dv, c.direccion, c.usuario_creacion, to_char(c.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, c.usuario_modificacion, to_char(c.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, c.estado, c.observacion, c.telefono, c.fax, decode(c.estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc, t.descripcion tipo_centro from tbl_pm_centros_atencion c, tbl_pm_tipo_centro_atencion t where c.tipo_centro = t.id ");

	if(!nombre.equals("")){
		sbSql.append(" and c.nombre like '%");
		sbSql.append(nombre.trim());
		sbSql.append("%'");
	}
	if(!ruc.equals("")){
		sbSql.append(" and c.ruc like '%");
		sbSql.append(ruc.trim());
		sbSql.append("%'");
	}
	if(!estado.equals("")){
		sbSql.append(" and c.estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!telefono.equals("")){
		sbSql.append(" and c.telefono like '%");
		sbSql.append(telefono.trim());
		sbSql.append("%'");
	}
	if(!idEmpresa.equals("")){
		sbSql.append(" and c.id = ");
		sbSql.append(idEmpresa.trim());
		sbSql.append("");
	}
	sbSql.append(" order by c.id");

al = SQLMgr.getDataList(sbSql.toString());

if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = request.getParameter("__ct");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 10.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "LISTADO DE CENTOS DE ATENCION";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblContent = new Vector();
	tblContent.addElement(".10"); //Código
	tblContent.addElement(".50"); //Nombre
	tblContent.addElement(".20"); //RUC
	tblContent.addElement(".10"); //Teléfono
	tblContent.addElement(".10"); //Estado


	pc.setNoColumnFixWidth(tblContent);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblContent.size());

	pc.setFont(8, 1);
	pc.addCols(" ", 0,tblContent.size());

	pc.addBorderCols("Código",1,1);
	pc.addBorderCols("Título Centro",0,1);
	pc.addBorderCols("R.U.C",1,1);
	pc.addBorderCols("Teléfono",1,1);
	pc.addBorderCols("Estado",1,1);

	pc.setTableHeader(3);

	if (al.size()==0) {
		pc.addCols("No existen datos a cerca de empresas!",1,tblContent.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);

        pc.setFont(7, 0);
        pc.addCols(cdo1.getColValue("id_centro"),1,1);
        pc.addCols(cdo1.getColValue("nombre"),0,1);
        pc.addCols(cdo1.getColValue("ruc"),1,1) ;
        pc.addCols(cdo1.getColValue("telefono"),1,1) ;
        pc.addCols(" "+cdo1.getColValue("estado_desc"),1,1) ;

		}//End For

		pc.setFont(10,1);
		pc.addCols(al.size()+" Registro"+(al.size()>1?"s":"")+" en total",0,tblContent.size());

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>