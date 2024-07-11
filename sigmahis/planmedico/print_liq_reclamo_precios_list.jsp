<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.awt.Color" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String)session.getAttribute("_companyId");
String status = request.getParameter("estado");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String id_clasif = request.getParameter("id_clasif");

StringBuffer sbSql = new StringBuffer();
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

    if (codigo == null) codigo = "";
    if (descripcion == null) descripcion = "";
    if (status==null) status = "";
if (id_clasif==null) id_clasif= "";
    
    sbSql = new StringBuffer();
    sbSql.append("select l.id, lpad(l.codigo_precio,15,' ') codigo_precio, l.descripcion, l.precio, decode(l.estado,'A','Activo','Inactivo') estado_desc, nvl((select descripcion from tbl_pm_clasif_lista_precio lp where lp.id = l.id_clasif), 'NO ASIGNADO') clasificacion_desc, nvl(l.id_clasif, 0) id_clasif from tbl_pm_lista_precios l where 1=1 ");
    
    if (!codigo.trim().equals("")) {
      sbSql.append(" and l.codigo_precio = '");
      sbSql.append(codigo);
      sbSql.append("'");
    }
    
    if (!descripcion.trim().equals("")) {
      sbSql.append(" and l.descripcion like '%");
      sbSql.append(descripcion);
      sbSql.append("%'");
    }
    
    if (!status.trim().equals("")) {
      sbSql.append(" and l.estado = '");
      sbSql.append(status);
      sbSql.append("'");
    }
		if(!id_clasif.equals("")){
				sbSql.append(" and id_clasif = ");
				sbSql.append(id_clasif);
			}
    
    sbSql.append(" order by nvl(l.id_clasif, 0) asc, lpad(l.codigo_precio,15,' ')");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "PLAN MEDICO";
	String subtitle = "LIQUIDACION DE RECLAMO";
	String xtraSubtitle = "LISTADO DE PRECIO";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement("15"); //Codigo
	setDetail.addElement("55"); //descripcion
    setDetail.addElement("15"); //Precio
    setDetail.addElement("15"); //Estado

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, UserDet.getUserName(), fecha, setDetail.size());

	//second row
	pc.setFont(8, 1);
	pc.addBorderCols("CODIGO",0,1);
	pc.addBorderCols("DESCRIPCION",0,1);
	pc.addBorderCols("PRECIO",1,1);
	pc.addBorderCols("ESTADO",1,1);

	pc.addCols("",0,setDetail.size());

	pc.setTableHeader(3);

	if (al.size() < 1) pc.addCols("*** No Encontramos Ningún Registro ***",1,setDetail.size());

	pc.setFont(8, 0);
	String grp = "";
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);
		if(!cdo.getColValue("id_clasif").equals(grp)){
			pc.addBorderCols(cdo.getColValue("clasificacion_desc"),0,setDetail.size(),0.5f,0.5f,0.0f,0.0f);
		}

		pc.addCols(cdo.getColValue("codigo_precio"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1);
		pc.addCols(cdo.getColValue("estado_desc"),1,1);
		grp=cdo.getColValue("id_clasif");
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>