<%@ page errorPage="../error.jsp"%>
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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

	sql=" select a.provincia, a.sigla, a.tomo, a.asiento, decode(a.provincia,0,' ',00,' ',11,'B',12,'C',a.provincia)||decode(a.sigla,'00','  ','0','  ',a.sigla)||'-'||to_char(a.tomo)||'-'||to_char(a.asiento) cedulaBecario, a.nombre||' '||a.apellido nombreBecario, to_char(a.fecha_nac,'dd-mm-yyyy')as fechaNac, decode(a.sexo,'F','FEMENINO','M','MASCULINO') sexo, a.num_ssocial as numSocial, a.direccion, a.telefono, a.estado, a.anio_cursa as anio, a.carrera, decode(a.educacion,'E','PUBLICA','P','PRIVADA') educacion, decode(a.turno,'V','VESPERTINO','N','NOCTURNO','M','MATUTINO')  turno, a.centro_edu as centro, to_char(a.fecha_ini_beca,'dd-mm-yyyy') as fechaIni, to_char(a.fecha_fin_beca,'dd-mm-yyyy') as fechaFin, a.nombre, c.num_empleado as numEmpleado, c.primer_nombre||' '||c.primer_apellido||' ' || decode(c.sexo,'F',decode(c.apellido_casada,null, c.segundo_apellido,'DE '||c.apellido_casada),'M',c.segundo_apellido)  as nombreEmp, decode(a.provincia_aso,0,' ',00,' ',11,'B',12,'C',a.provincia_aso)||decode(a.sigla_aso,'00','  ','0','  ',a.sigla) || '-' ||to_char(a.tomo_aso) || '-' ||to_char(a.asiento_aso) as  cedulaEmp, d.descripcion, d.monto from tbl_pla_becario a, tbl_sec_compania b, tbl_pla_tipo_beca d, tbl_pla_empleado c where c.compania = b.codigo and a.cod_compania = b.codigo and a.cod_beca = d.cod_beca and a.provincia_aso = c.provincia  and a.sigla_aso = c.sigla  and a.tomo_aso = c.tomo  and a.asiento_aso = c.asiento and a.estado = 'A' and a.cod_compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.apellido, a.nombre";

 al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LISTADO DE BECARIOS ACTIVOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
	
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	  
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		 
		 pc.addCols(" ",0,8);
		 
			pc.addCols("NOMBRE BECARIO ",0,1);
			pc.addCols(" "+cdo.getColValue("nombreBecario"),0,3);
			pc.addCols(" CEDULA: ", 0,1);
			pc.addCols(" "+cdo.getColValue("cedulaBecario"),0,3);
		
			pc.addCols("CENTRO EDUC.: ",0,1);
			pc.addCols(" "+cdo.getColValue("centro"),0,2);
			pc.addCols(" ( "+cdo.getColValue("educacion")+" ) ", 0,1);
			pc.addCols("TURNO: ",0,1);
			pc.addCols(" "+cdo.getColValue("turno"),0,1);
			pc.addCols("NIVEL: ",0,1);
			pc.addCols(" "+cdo.getColValue("anio"),0,1);			
			
	  	pc.addCols("NOMBRE PADRE: ",0,1);
			pc.addCols(" "+cdo.getColValue("nombreEmp"),0,3);
			pc.addCols(" CEDULA: ", 0,1);
			pc.addCols(" "+cdo.getColValue("cedulaEmp"),0,3);		
		
			pc.addCols("FECHA INICIO: ",0,1);
			pc.addCols(" "+cdo.getColValue("fechaIni"),0,1);
			pc.addCols(" FECHA FINAL: ", 0,1);
			pc.addCols(" "+cdo.getColValue("fechaFin"),0,1);	
			pc.addCols(" DIRECCION: ", 0,1);
			pc.addCols(" "+cdo.getColValue("direccion"),0,3);	
			
			pc.addCols("TIPO DE BECARIO: ",0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,5);
			pc.addCols("TELEFONO: ",0,1);
			pc.addCols(" "+cdo.getColValue("telefono"),0,1);
		
		pc.addCols(" ",0,8);
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>