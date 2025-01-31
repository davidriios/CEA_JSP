<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="java.util.ArrayList" %>
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
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet=SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

			sql=" select decode(a.tipo_equipo,'CO','COMODATO','SF','SIN FACTURAR') tipo_equipo, a.no_equipo, a.nombre, a.unidad_adm, a.compania, a.estado, a.modelo, a.serie, a.comentarios, to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada,    a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy') fecha_creacion, ue.descripcion desc_unidad    /*a.tipo_equipo */ ,decode(a.estado,'A','ACTIVO','I','INACTIVO',a.estado)estadoDesc,decode(a.estado_uso, 'U','USO','D','DISPONIBLE',a.estado_uso)estadoUsoDesc from tbl_inv_comodato_equipos a,    tbl_sec_unidad_ejec ue where a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.unidad_adm = ue.codigo(+) and a.compania=ue.compania(+)  order by a.no_equipo desc"; 

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");
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
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "EQUIPOS COMODATO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".24");
		setDetail.addElement(".15");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".24");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Modelo",1);
		pc.addBorderCols("Fecha Doc.",1);
		pc.addBorderCols("Tipo",0);
		pc.addBorderCols("Unidad Adm.",0);
		pc.addBorderCols("Estado",0);
		pc.addBorderCols("Estado Uso",0);


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
			pc.addCols(" "+cdo1.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo1.getColValue("modelo"),0,1);
			pc.addCols(" "+cdo1.getColValue("fecha_entrada"),1,1);
			pc.addCols(" "+cdo1.getColValue("tipo_equipo"),0,1);
			pc.addCols(" "+cdo1.getColValue("desc_unidad"),0,1);
			pc.addCols(" "+cdo1.getColValue("estadoDesc"),0,1);
			pc.addCols(" "+cdo1.getColValue("estadoUsoDesc"),0,1);	
	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,setDetail.size());
	}
	

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>