<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Pantalla: "Reportes de vacacciones"           -->
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
ArrayList alRes = new ArrayList();
CommonDataObject cdo = new CommonDataObject();	

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String anio   = request.getParameter("anio");
String periodo   = request.getParameter("periodo");
String empId   = request.getParameter("empId");
String noEmpleado   = request.getParameter("noEmpleado");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String fechaInicio   = request.getParameter("fechaInicio");
if (empId == null)empId="";
if (anio == null)anio="";
if (periodo == null)periodo="";
if (noEmpleado == null)noEmpleado="";
if (fechaInicio == null)fechaInicio="";

sql.append("select e.num_empleado,e.nombre_empleado,e.cedula1 cedula,e.salario_base, to_char(e.fecha_ingreso,'dd/mm/yyyy') fechaIngreso ,(select denominacion from tbl_pla_cargo where codigo=e.cargo) descCargo,(select max(anio) from tbl_pla_vacacion where cod_compania=s.compania and anio_pago=s.anio_pago and quincena_pago=s.periodo_pago and emp_id =e.emp_id) anioVacacion, /*to_char(s.periodof_inicio,'dd/mm/yyyy') fechaInicio, to_char(s.periodof_final,'dd/mm/yyyy') fechaFinal*/ to_char(s.periodof_inicio,'dd fmMonth yyyy','NLS_DATE_LANGUAGE=SPANISH')fechaInicio, to_char(s.periodof_final,'dd fmMonth yyyy','NLS_DATE_LANGUAGE=SPANISH')  fechaFinal from vw_pla_empleado e,tbl_pla_sol_vacacion s where e.emp_id=");
sql.append(empId);
sql.append(" and e.compania=");
sql.append(compania);
sql.append(" and e.emp_id=s.emp_id and e.compania = s.compania and s.anio_pago=");
sql.append(anio);
sql.append(" and s.periodo_pago=");
sql.append(periodo);
cdo = SQLMgr.getData(sql.toString());
		
sql = new StringBuffer();
sql.append("select a.secuencia,to_char(a.fecha_inicio, 'dd/mm/yyyy') fechaInicio, a.anio, a.secuencia, a.periodo, b.descripcion mes, decode(b.quincena1, a.periodo, 'PRIMERA', 'SEGUNDA') quincena,sal_bruto salBruto, gasto_rep gastoRep, salario_especie salarioEspecie, emp_id empId from tbl_pla_temporal_vac a, tbl_pla_vac_parametro b where (a.periodo = b.quincena1 or a.periodo = b.quincena2) and cod_compania =");
sql.append(compania);
if (!empId.trim().equals("")){sql.append(" and a.emp_id  = ");sql.append(empId);}
//if (!noEmpleado.trim().equals("")) {sql.append(" and a.num_empleado  = '");sql.append(noEmpleado);sql.append("'");}
if (!fechaInicio.trim().equals("")) {sql.append(" and trunc(a.fecha_inicio)= to_date('");sql.append(fechaInicio);sql.append("','dd/mm/yyyy')");} 
sql.append(" order by a.secuencia asc ");
al = SQLMgr.getDataList(sql.toString()); 

sql = new StringBuffer();
sql.append("select  v.dias_pendiente_dinero dinero, v.dias_pendiente, v.anio,v.estado,(select descricion from tbl_pla_estado_vac where codigo = v.estado) estadoVac from vw_pla_empleado a,tbl_pla_vacacion v where a.compania=");
sql.append(compania);
sql.append(" and a.emp_id = v.emp_id and v.anio >= to_number(to_char(sysdate, 'yyyy'))-2 and v.emp_id =");
sql.append(empId);
sql.append(" order by v.anio desc ");
alRes = SQLMgr.getDataList(sql.toString()); 


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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECURSOS HUMANOS/PLANILLA";
	String subtitle = "PLANILLA DE VACACIONES ";
	String xtraSubtitle = " SALARIOS ACUMULADOS ULTIMOS 11 MESES ";//" DEL "+fechaini+" AL "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".15");
	dHeader.addElement(".25");
	dHeader.addElement(".25");
	dHeader.addElement(".35");
							
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

    pc.setFont(8, 1);
	
	pc.setVAlignment(1);
	pc.addCols(" ",0,dHeader.size());
	pc.addCols("No.:"+cdo.getColValue("num_empleado")+"  "+cdo.getColValue("nombre_empleado"),0,2);	
	pc.addCols("Cédula:"+cdo.getColValue("cedula"),0,1);	
	pc.addCols("Cargo:"+cdo.getColValue("descCargo"),0,1);	
		
	pc.addCols("Salario Base:"+cdo.getColValue("salario_base"),0,1);	
	pc.addCols("Fecha de Ingreso:"+cdo.getColValue("fechaIngreso"),0,1);	
	pc.addCols(" ",0,2);
	
	pc.addCols("Vacaciones:   Del "+cdo.getColValue("fechaInicio")+"   al   "+cdo.getColValue("fechaFinal"),0,4);	
	pc.addCols(" ",0,dHeader.size());
	pc.addBorderCols("SEC",1,1);
	pc.addBorderCols("PERIODO/MES",1,1);
	pc.addBorderCols("SALARIO",2,1);
	pc.addBorderCols("GASTO REPRESENTACION",2,1);

	double salBruto =0.00,gastoRep =0.00,valorVac=0.00,valorVacGrep =0.00;
	pc.setFont(8,0);
	
	
	String groupByEmp = "";
	for ( int i = 0; i<al.size(); i++ ){
		CommonDataObject cdo1 = (CommonDataObject)al.get(i);
		
		pc.addCols(cdo1.getColValue("secuencia"),1,1);
		pc.addCols(cdo1.getColValue("mes")+" - "+cdo1.getColValue("quincena"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("salBruto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("gastoRep")),2,1);
		
			
		salBruto += Double.parseDouble(cdo1.getColValue("salBruto"));
		gastoRep += Double.parseDouble(cdo1.getColValue("gastoRep"));
	}
		
		valorVac = (salBruto/11);
		valorVacGrep = (gastoRep/11);
		 pc.addCols("",0,dHeader.size());
		
		 
		 pc.setFont(8,1);
		 pc.addCols("TOTAL ULTIMOS 11 MESES      ==>     ",2,2);
		 pc.addCols(""+CmnMgr.getFormattedDecimal(salBruto),2,1);
		 pc.addCols(""+CmnMgr.getFormattedDecimal(gastoRep),2,1);
		 
		 pc.addCols("VACACIONES     ==>     ",2,2);
		 pc.addCols(""+CmnMgr.getFormattedDecimal(valorVac),2,1);
		 pc.addCols(""+CmnMgr.getFormattedDecimal(valorVacGrep),2,1);
		 
		 pc.addCols("  ",0,dHeader.size());
		 //if((valorVac+valorVacGrep) > Double.parseDouble(cdo.getColValue("salario_base")))		 
		 pc.addCols("B/. "+CmnMgr.getFormattedDecimal(valorVac+valorVacGrep),1,2);
		 //else pc.addCols("B/. "+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base")),1,2);
		 pc.setFont(8,1);
		 pc.addCols(" Equivalente a 30 días de Vacacion segun el calculo de los acumulados, que corresponden al año "+cdo.getColValue("anioVacacion")+".",0,4);
	     pc.setFont(8,0);
		 
		 pc.setFont(8,1);
		 pc.addCols("B/. "+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base")),1,2);
		 pc.addCols(" SALARIO MENSUAL ",0,4);
	     pc.setFont(8,0);
		 pc.addCols("  ",0,dHeader.size());
		 pc.addCols("  ",0,dHeader.size());
   
		 pc.addBorderCols(" HISTORIAL:   VACACIONES PENDIENTES",0,dHeader.size());
		 
		 pc.addBorderCols("AÑO",1,1);
		 pc.addBorderCols("ESTADO",1,1);
		 pc.addBorderCols("TIEMPO",1,1);
		 pc.addBorderCols("DINERO",1,1);
		 
		 for ( int i = 0; i<alRes.size(); i++ ){
		CommonDataObject cdo1 = (CommonDataObject)alRes.get(i);
		
		pc.addCols(cdo1.getColValue("anio"),1,1);
		pc.addCols(cdo1.getColValue("estadoVac"),0,1);
		pc.addCols(cdo1.getColValue("dias_pendiente"),1,1);
		pc.addCols(cdo1.getColValue("dinero"),1,1);
		}

	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
