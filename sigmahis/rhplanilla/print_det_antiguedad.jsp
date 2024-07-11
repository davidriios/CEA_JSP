<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList tot = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String userName = UserDet.getUserName();
String fechaProc = request.getParameter("fecha");
String titulo = ""; 

CommonDataObject cdo2 = null;

if (fp == null) fp="";

if (appendFilter == null) appendFilter = "";

if(!fp.equalsIgnoreCase("sob")) 
{
appendFilter = " and a.tipo_aumento = 1 and to_date(to_char(a.fecha_aumento,'dd/mm/yyyy'),'dd/mm/yyyy') = '"+fechaProc+"' ";
titulo = "REPORTE DE EMPLEADOS POR ANTIGUEDAD ";
}

if (fp.equalsIgnoreCase("sob"))
{
appendFilter = " and a.tipo_aumento = 5 and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = '"+fechaProc+"' "; 
titulo = "INFORME DETALLADO DE AUMENTOS POR SOBRESUELDO ";
}

sql = "select to_char(a.fecha_aumento,'dd/mm/yyyy') fecha, to_char(a.fecha_anterior,'dd/mm/yyyy') fechaAnt, nvl(a.sueldo_anterior,0) sueldo_anterior,  nvl(a.aumento,0) aumento, a.comentarios, to_char(nvl(a.rata_x_hora,0),'99,990.00') rata_x_hora, e.provincia,e.sigla,e.tomo,e.asiento, e.primer_nombre||' '||e.primer_apellido as nomEmpleado, e.num_empleado, c.denominacion cargoDesc, nvl(e.ubic_seccion,e.seccion) seccion, u.descripcion unidadDesc, e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento as cedula, e.rata_hora rataEmp, to_char(e.fecha_ingreso,'dd/mm/yyyy') fechaIngreso, f.descripcion aumDesc, a.tipo_aumento, g.descripcion estDesc, nvl(a.sueldo_anterior,0) + nvl(a.aumento,0) nuevoSalario, (nvl(a.sueldo_anterior,0) + nvl(a.aumento,0)) / nvl(a.rata_x_hora,1) nuevaRata, to_char(sysdate,'dd/mm/yyyy') fechaHoy,  decode(e.sindicato,'S',1,0) sind, decode(e.sindicato,'N',1,0) conf, trunc(months_between(sysdate,e.fecha_ingreso)/12,0) anios, to_char(to_date('01/'||nvl(a.mes,12)||'/'||to_char(SYSDATE,'YYYY'),'DD/MM/YYYY'),'FMMONTH',  'NLS_DATE_LANGUAGE=SPANISH') meses from tbl_pla_aumento_cc a, tbl_pla_cargo c, tbl_pla_empleado e, tbl_pla_tipo_aumento f, tbl_pla_estado_emp g, tbl_sec_unidad_ejec u where a.compania = e.compania and  a.emp_id = e.emp_id and  e.cargo = c.codigo and  e.compania = c.compania  and a.compania = u.compania and nvl(e.ubic_seccion,e.seccion) = u.codigo and  a.tipo_aumento	= f.codigo and  a.compania = f.compania and a.compania= "+(String) session.getAttribute("_companyId")+ appendFilter + " and e.estado = g.codigo order by trunc(months_between(sysdate,e.fecha_ingreso)/12,0), e.num_empleado";
al = SQLMgr.getDataList(sql);



sql = "select count(*)  as count, sum(a.aumento) as totmonto, sum(decode(e.sindicato,'S',1,0)) totsind, sum(decode(e.sindicato,'N',1,0)) totconf, trunc(months_between(sysdate,e.fecha_ingreso)/12,0) anios, to_char(to_date('01/'||nvl(a.mes,12)||'/'||to_char(SYSDATE,'YYYY'),'DD/MM/YYYY'),'FMMONTH',  'NLS_DATE_LANGUAGE=SPANISH') meses from tbl_pla_aumento_cc a, tbl_pla_cargo c, tbl_pla_empleado e, tbl_pla_tipo_aumento f, tbl_pla_estado_emp g, tbl_sec_unidad_ejec u where a.compania = e.compania and  a.emp_id = e.emp_id and  e.cargo = c.codigo and  e.compania = c.compania  and a.compania = u.compania and nvl(e.ubic_seccion,e.seccion) = u.codigo and  a.tipo_aumento	= f.codigo and  a.compania = f.compania and a.compania= "+(String) session.getAttribute("_companyId")+ appendFilter + " and e.estado = g.codigo group by trunc(months_between(sysdate,e.fecha_ingreso)/12,0), to_char(to_date('01/'||nvl(a.mes,12)||'/'||to_char(SYSDATE,'YYYY'),'DD/MM/YYYY'),'FMMONTH',  'NLS_DATE_LANGUAGE=SPANISH') order by 5,6 ";
tot =SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String montoTotal = "";
	
	Hashtable htUni = new Hashtable();

	for (int i=0; i<tot.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) tot.get(i);

		htUni.put(cdo1.getColValue("anios"),cdo1);
			
	}
	
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
	String title = "PLANILLA";
	String subtitle = " "+titulo;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		
		dHeader.addElement(".50");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addCols("NOMBRE DEL EMPLEADO",0,1);
		pc.addCols("No. EMPLEADO",1,1);
		pc.addCols("FECHA INGRESO",1,1);
		pc.addCols("AUMENTO",2,1);
		
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
			
		pc.setFont(7, 1);
		pc.addCols("FECHA DE AUMENTO :  "+fechaProc,0,1);
		pc.addCols("  ",0,3);
		
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
				
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    String sec = "";
	String totalAcr = "";
	double totAcr = 0.00;
	int totSala = 0;
	int totSaln = 0;
	int cont=0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!sec.equalsIgnoreCase(cdo.getColValue("anios")))
		{
		if (i!=0)
		{
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		cdo2 = (CommonDataObject) htUni.get(sec);
		pc.addCols("Empleados : "+cdo2.getColValue("count"),2,1);
		pc.addCols(" Sindicalizados : "+cdo2.getColValue("totsind"),2,1);
		pc.addCols(" Confianza : "+cdo2.getColValue("totconf"),2,1);
		pc.addCols(" Total : "+CmnMgr.getFormattedDecimal(cdo2.getColValue("totmonto")),2,1);
		//pc.addTable();
		sec =  cdo.getColValue("anios");
		
		pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
				
		}
		pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols("AÑOS :   "+cdo.getColValue("anios"),0,4);
		
			
		}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("nomEmpleado"),0,1);
		pc.addCols(cdo.getColValue("num_empleado"),1,1);
		pc.addCols(cdo.getColValue("fechaIngreso"),1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("aumento")),2,1);
	
	
		sec =  cdo.getColValue("anios");
		cont = cont	+ 1;
      //  montoTotal += cdo.getColValue("monto");
		totAcr += Double.parseDouble(cdo.getColValue("aumento"));
		totSala += Double.parseDouble(cdo.getColValue("sind"));
		totSaln += Double.parseDouble(cdo.getColValue("conf"));
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	
	pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
	
	pc.setFont(7, 0);
		pc.setVAlignment(0);
		cdo2 = (CommonDataObject) htUni.get(sec);
		pc.addCols("Empleados : "+cdo2.getColValue("count"),2,1);
		pc.addCols(" Sindicalizados : "+cdo2.getColValue("totsind"),2,1);
		pc.addCols(" Confianza : "+cdo2.getColValue("totconf"),2,1);
		pc.addCols(" Total : "+CmnMgr.getFormattedDecimal(cdo2.getColValue("totmonto")),2,1);
	//	totalAcr += cdo2.getColValue("aumento");
		//pc.addTable();
	
	pc.setFont(7, 0);
	pc.addCols("",0,dHeader.size());
			
	pc.addCols(" TOTALES FINALES :  "+al.size()+"  EMPLEADOS : ",2,1);
	pc.addCols(" Total Sindicalizados : "+totSala,2,1);
	pc.addCols(" Total Confianza : "+totSaln,2,1);
	pc.addCols(" Aumento :  "+CmnMgr.getFormattedDecimal(""+totAcr),2,1);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>