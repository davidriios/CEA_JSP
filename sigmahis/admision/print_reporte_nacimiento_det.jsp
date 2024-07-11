<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alE = new ArrayList();

String sql = "", appendFilter = "";
	
String mes  = request.getParameter("mes");
String mesDesc = request.getParameter("mesDesc");
String anio = request.getParameter("anio");
String nh = request.getParameter("nh");
	
if (mes == null) mes = "";
if (mesDesc == null) mesDesc = "";
if (anio == null) anio = "";
if (nh == null) nh = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "REPORTE DE NACIMIENTO DETALLADO";
	String xtraSubtitle = ((mesDesc.trim().equals(""))?"AÑO ":(mesDesc+" "))+anio;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
        
  StringBuffer sb = new StringBuffer();
	sb.append("select extract(month from nvl(z.f_nac,z.fecha_nacimiento)) as mm, to_char(nvl(z.f_nac,z.fecha_nacimiento),'MONTH','NLS_DATE_LANGUAGE = spanish') as mes, to_char(nvl(z.f_nac,z.fecha_nacimiento),'dd/mm/yyyy') as dob, z.pac_id, (select min(secuencia) from tbl_adm_admision where pac_id = z.pac_id and estado != 'N') as admision, z.primer_nombre||decode(z.segundo_nombre,null,null,' '||z.segundo_nombre)||' '||z.primer_apellido||decode(z.segundo_apellido,null,null,' '||z.segundo_apellido) as nombre_paciente, z.sexo, decode(z.sexo,'M',1,0) as sexom, decode(z.sexo,'F',1,0) as sexof from tbl_adm_paciente z where extract(year from nvl(z.f_nac,z.fecha_nacimiento)) = ");
	sb.append(anio);
	if (!mes.trim().equals("")) {
		sb.append(" and extract(month from nvl(z.f_nac,z.fecha_nacimiento)) = ");
		sb.append(mes);
	}
	if (!nh.trim().equals("")) sb.append(" and z.nh = 'S' and exists (select null from tbl_adm_admision where pac_id = z.pac_id and estado != 'N')");
	sb.append(" and z.estatus = 'A' order by 1, z.sexo, nvl(z.f_nac,z.fecha_nacimiento)");
  al = SQLMgr.getDataList(sb.toString());
    
	Vector setDetail = new Vector();
    setDetail.addElement(".15");
    setDetail.addElement(".10");
    setDetail.addElement(".55");
    setDetail.addElement(".10");
    setDetail.addElement(".10");

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
    pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

    pc.setFont(10,1);
    pc.addBorderCols("CUENTA",0,1);
    pc.addBorderCols("F. NAC.",1,1);
    pc.addBorderCols("NOMBRE",1,1);
    pc.addBorderCols("MASC.",1,1);
    pc.addBorderCols("FEME.",1,1);
    pc.setTableHeader(2);
		String groupBy = "";
		int t = 0, tm = 0, tf = 0;
    for (int i = 0; i < al.size(); i++) {
			cdo = (CommonDataObject) al.get(i);
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("mes"))) {
				pc.setFont(10,1);
				if (i != 0) {
					pc.addCols(" TOTAL DE "+groupBy+" ---> "+t,2,setDetail.size() - 2);
					pc.addCols(""+tm,2,1);
					pc.addCols(""+tf,2,1);
				}
				pc.addCols(cdo.getColValue("mes"),0,setDetail.size());
				t = 0;
				tm = 0;
				tf = 0;
			}
			pc.setFont(10,0);
			pc.addCols(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision"),0,1);
			pc.addCols(cdo.getColValue("dob"),1,1);
			pc.addCols(cdo.getColValue("nombre_paciente"),0,1);
			pc.addCols((cdo.getColValue("sexom").equals("0"))?"":"*",1,1);
			pc.addCols((cdo.getColValue("sexof").equals("0"))?"":"*",1,1);
			
			t++;
			tm += Integer.parseInt(cdo.getColValue("sexom","0"));
			tf += Integer.parseInt(cdo.getColValue("sexof","0"));
			groupBy = cdo.getColValue("mes");
    }
    
		pc.setFont(10,1);
		pc.addCols(" TOTAL DE "+groupBy+" ---> "+t,2,setDetail.size() - 2);
		pc.addCols(""+tm,2,1);
		pc.addCols(""+tf,2,1);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>