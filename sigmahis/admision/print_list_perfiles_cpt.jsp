<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.awt.Color"%>
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


SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter")==null?"":request.getParameter("appendFilter");

sbSql.append("select z.id as id_profile, z.nombre as profile_name, decode(z.estado,'A','ACTIVO','INACTIVO') as profile_status, nvl(y.id_cpt,' ') as id_cpt, decode(y.cod_cds,null,' ',y.cod_cds) as cod_cds");
sbSql.append(", nvl((select nvl(observacion, descripcion) from tbl_cds_procedimiento where codigo = x.cod_procedimiento),' ') as cpt_desc");
sbSql.append(", nvl((select descripcion from tbl_cds_centro_servicio where codigo = x.cod_centro_servicio),' ') as cds_desc");
sbSql.append(", (select precio from tbl_cds_procedimiento where codigo = x.cod_procedimiento) as precio");
sbSql.append(" from tbl_cdc_cpt_profile z, tbl_cdc_cpt_x_profiles y, tbl_cds_procedimiento_x_cds x");
sbSql.append(" where z.id = y.id_profile(+) and y.id_cpt = x.cod_procedimiento(+) and y.cod_cds = x.cod_centro_servicio(+)");
sbSql.append(appendFilter);
sbSql.append(" order by z.id");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String title = "ADMISION";
	String subtitle = "PERFILES CPT";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".10"); //COD CPT
	setDetail.addElement(".50"); //NOMBRE CPT
	setDetail.addElement(".30"); //CDS
	setDetail.addElement(".10"); //PRECIO

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

	//second row
	pc.setFont(8, 1);
	pc.addBorderCols("COD. CPT",1,1);
	pc.addBorderCols("NOMBRE CPT",0,1);
	pc.addBorderCols("CENTRO DE SERVICIO",0,1);
	pc.addBorderCols("PRECIO",1,1);

	pc.addCols("",0,setDetail.size());

	pc.setFont(7, 0);
	String profileId = "";
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);

		if ( !profileId.equals(cdo.getColValue("id_profile")) ) {
		  pc.setFont(8, 1,Color.white);
		   pc.addCols("PERFIL: ["+cdo.getColValue("id_profile")+"] "+cdo.getColValue("profile_name")+"    "+cdo.getColValue("profile_status"),0,setDetail.size(),Color.lightGray);
		}
		pc.setFont(7, 0);

		pc.addCols(cdo.getColValue("id_cpt"),1,1);
		pc.addCols(cdo.getColValue("cpt_desc"),0,1);
		pc.addCols("["+cdo.getColValue("cod_cds")+"] "+cdo.getColValue("cds_desc"),0,1);
		pc.addCols(cdo.getColValue("precio"),2,1);

		profileId = cdo.getColValue("id_profile").trim();
	}
	
	pc.setFont(8, 1);
	if (0==al.size()) pc.addCols("*** No hay registros! ***",1,setDetail.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>