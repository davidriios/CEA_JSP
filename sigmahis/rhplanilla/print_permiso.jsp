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
String fec=request.getParameter("fecha");
String empId=request.getParameter("empId");
String cod = request.getParameter("cod");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

		sql = "select to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora_salida,'hh:mi:ss') as salida,  a.motivo, a.mfalta, to_char(a.hora_entrada,'hh:mi:ss') as entrada, to_char(a.hora_desde,'hh:mi:ss') as desde,  to_char(a.hora_hasta,'hh:mi:ss ') as hasta, b.descripcion as mfaltaDesc, a.codigo, to_char(a.fecha_fin,'dd/mm/yyyy') as fechafinal, a.motivo_lic, decode(a.estado,'ND','No Descontar','DS','Descontar','PE','Pendiente','DV','Devolver') as estado, a.emp_id, m.descripcion as licDesc, c.primer_nombre||' '||c.primer_apellido as nombre, nvl(a.ue_codigo,'0') grupo, a.aprobado, a.forma_des, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_casada,null,'',' '||c.apellido_casada)) as nombreEmp, c.provincia||' '||c.sigla||' '||c.tomo||' '||c.asiento as cedula, c.num_empleado numEmp, e.descripcion depto from tbl_pla_permiso a, tbl_pla_motivo_falta b, tbl_pla_empleado c, tbl_pla_motivo_licencia m, tbl_sec_unidad_ejec e where a.mfalta=b.codigo and a.compania = "+(String) session.getAttribute("_companyId")+" and a.motivo_lic = m.codigo(+) and a.emp_id = c.emp_id and a.compania = c.compania and a.compania = e.compania and nvl(c.ubic_seccion, c.ubic_depto) = e.codigo and a.codigo = "+cod+" and a.emp_id = "+empId+" and to_char(a.fecha,'dd/mm/yyyy')= '"+fec+"'";

 al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "RECURSOS HUMANOS";
	String subtitle = " SOLICITUD DE PERMISO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row


	//pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
   		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols("",0,1);
		pc.addCols("NOMBRE : ",0,1);
		pc.addBorderCols(" "+cdo.getColValue("nombreEmp"),0,4,1,0,0,0);
		pc.addCols("CEDULA : ",1,1);
		pc.addBorderCols(" "+cdo.getColValue("cedula"),0,1,1,0,0,0);
		pc.addCols("No. : ",2,1);
		pc.addBorderCols(" "+cdo.getColValue("numEmp"),1,1,1,0,0,0);

		 pc.addCols(" ",0,dHeader.size());
/*
		 pc.addCols("",0,1);
		pc.addCols("DEPARTAMENTO : ",0,2);
		pc.addBorderCols(" "+cdo.getColValue("depto"),0,4,1,0,0,0);
		pc.addCols("  ",1,3);
*/
		 pc.addCols(" ",0,dHeader.size());

		pc.addCols("",0,1);
		pc.addCols("FECHA : ",0,1);
		pc.addBorderCols(" "+cdo.getColValue("fecha"),1,2,1,0,0,0);
		pc.addCols("DESDE : ",2,1);
		pc.addBorderCols(" "+cdo.getColValue("salida"),1,1,1,0,0,0);
		pc.addCols("HASTA : ",2,1);
		pc.addBorderCols(" "+cdo.getColValue("entrada"),1,1,1,0,0,0);
		pc.addCols("",0,2);


		 pc.addCols(" ",0,dHeader.size());


		pc.addCols(" ",0,2);
		pc.addBorderCols(" "+cdo.getColValue("fechafinal"),1,2,1,0,0,0);
		pc.addCols("DESDE : ",2,1);
		pc.addBorderCols(" "+cdo.getColValue("desde"),1,1,1,0,0,0);
		pc.addCols("HASTA : ",2,1);
		pc.addBorderCols(" "+cdo.getColValue("hasta"),1,1,1,0,0,0);
		pc.addCols("",0,2);

		pc.addCols(" ",0,dHeader.size());

		 pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,1);
		pc.addCols("MOTIVO : ",0,1);
		pc.addBorderCols(" "+cdo.getColValue("mfaltaDesc"),0,6,1,0,0,0);
		pc.addCols(" ",0,2);


		 pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,1);
		pc.addCols("OBSERVACIONES : ",0,2);
		pc.addCols(" "+cdo.getColValue("motivo"),0,5);
		pc.addCols(" ",0,2);

		 pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,1);
		pc.addCols("FIRMA DEL EMPLEADO : ",0,2);
		pc.addBorderCols(" ",0,3,1,0,0,0);
		pc.addCols(" ",0,4);


		 pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,1);
		pc.addCols("VoBo : ",0,1);
		pc.addBorderCols(" ",0,3,1,0,0,0);
		pc.addCols("VoBo : ",2,1);
		pc.addBorderCols(" ",0,3,1,0,0,0);
		pc.addCols(" ",0,1);

		pc.addCols(" ",0,1);
		pc.addCols("",0,1);
		pc.addCols("JEFE INMEDIATO ",1,3);
		pc.addCols(" ",0,1);
		pc.addCols("OFICINA DE PERSONAL ",1,3);
		pc.addCols(" ",0,1);



	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols("",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>