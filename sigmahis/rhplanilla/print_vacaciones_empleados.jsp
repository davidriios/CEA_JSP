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
<!-- Pantalla: "Reportes de Disribuición de días de vacacciones"           -->
<!-- Reportes: PLA0090                           -->

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
ArrayList alTot = new ArrayList();
ArrayList alMonto = new ArrayList();
ArrayList alRes = new ArrayList();
Hashtable _mes = new Hashtable();
Hashtable itotDet = new Hashtable();
Hashtable iMonto = new Hashtable();
CommonDataObject cdo = new CommonDataObject();	
CommonDataObject cdoT = new CommonDataObject();	
CommonDataObject cdoMonto = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();
CommonDataObject cdoTotF = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String mes   = request.getParameter("mes");
String anio   = request.getParameter("anio");
String periodo   = request.getParameter("periodo");
String empId   = request.getParameter("empId");
String noEmpleado   = request.getParameter("noEmpleado");
String fechaDesde   = request.getParameter("fechaDesde");
String fechaHasta   = request.getParameter("fechaHasta");
String subqry1 = "", tablaX="";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String sbTotDet = "";
if (anio  == null)anio="";
if (empId  == null)empId="";
if (noEmpleado  == null)noEmpleado="";
if (fechaDesde  == null)fechaDesde="";
if (fechaHasta  == null)fechaHasta="";

if (mes != null ){
  _mes.put("1","ENERO");
  _mes.put("2","FEBRERO");
  _mes.put("3","MARZO");
  _mes.put("4","ABRIL");
  _mes.put("5","MAYO");
  _mes.put("6","JUNIO");
  _mes.put("7","JULIO");
  _mes.put("8","AGOSTO");
  _mes.put("9","SEPTIEMBRE");
  _mes.put("10","OCTUBRE");
  _mes.put("11","NOVIEMBRE");
  _mes.put("12","DICIEMBRE");
 }

if (appendFilter == null) appendFilter = "";
if (periodo.trim().equals("1")) appendFilter += " and pe.periodo = ("+mes+" * 2)-1";
else if (periodo.trim().equals("2")) appendFilter += " and pe.periodo = ("+mes+" * 2) ";
else if (periodo.trim().equals("3")){//appendFilter +=" and trunc(dd.fecha_inicio) >= to_date('01/"+mes+"/"+anio+"','dd/mm/yyyy')";
  //appendFilter +=" and (round(dd.periodo_ac/2,0)  = "+mes+" or round(pe.periodo/2,0) = "+mes+")";
//appendFilter +=" and trunc(dd.fecha_final) <= last_day(to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy')) ";
}
if (!empId.trim().equals("")) appendFilter += " and pa.emp_id  = "+empId;
if (!noEmpleado.trim().equals("")) appendFilter += " and pa.num_empleado = '"+noEmpleado+"'";
if (!fechaDesde.trim().equals("")) appendFilter += " and trunc(dd.fecha_inicio)>=to_date('"+fechaDesde+"','dd/mm/yyyy') ";
if (!fechaHasta.trim().equals("")) appendFilter += " and trunc(dd.fecha_final)<=to_date('"+fechaHasta+"','dd/mm/yyyy') ";
if (!anio.trim().equals("")) appendFilter += " and pe.anio="+anio;

sql= "select 1 ord, rownum as sec,nvl(em.seccion,em.ubic_seccion) depto, em.emp_id,dd.totalNeto,(select descripcion from tbl_sec_unidad_ejec e where pa.cod_compania = e.compania and nvl(em.seccion,em.ubic_seccion) = e.codigo ) descDepto,em.nombre_empleado nombre,em.num_empleado,to_char(dd.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(dd.fecha_final,'dd/mm/yyyy') fecha_final,dd.comentario,to_char(em.fecha_ingreso,'dd/mm/yyyy')f_ingreso,dd.dias,em.salario_base,nvl(mod(trunc(months_between(sysdate, em.fecha_ingreso)), 12), 0)  meses,nvl(trunc(months_between(sysdate,em.fecha_ingreso) / 12), 0) anios,dd.anio_ac FROM tbl_pla_planilla_encabezado pe, tbl_pla_pago_empleado pa,(select  nvl(sum((NVL(valor_vac,0)-NVL(valor_libres,0))),0) totalNeto ,emp_id,cod_compania,anio_pago,quincena_pago, fecha_inicio,fecha_final, (select nvl(trim(comentario),observacion)  from tbl_pla_sol_vacacion where emp_id=d.emp_id and anio_pago =d.anio_pago and periodo_pago=quincena_pago and estado='PR') as comentario ,tiempo_solicitado as dias,d.anio_ac from tbl_pla_dist_dias_vac d where  status in('PR','AP') group by  d.anio_ac,tiempo_solicitado,emp_id,cod_compania,anio_pago,quincena_pago,fecha_inicio,fecha_final )dd, vw_pla_empleado em where (pa.num_planilla = pe.num_planilla AND pa.cod_planilla = pe.cod_planilla AND pa.anio = pe.anio AND pa.cod_compania = pe.cod_compania) AND pa.cod_compania = dd.cod_compania AND pa.emp_id = dd.emp_id AND pa.anio = dd.anio_pago AND pe.anio = dd.anio_pago AND pe.periodo = dd.quincena_pago AND pa.cod_compania = "+compania+appendFilter+" AND dd.cod_compania = em.compania AND dd.emp_id = em.emp_id AND pe.cod_planilla = 3 union all select 2 ord, rownum as sec,  nvl(emp.seccion,emp.ubic_seccion) depto,a.emp_id,nvl(fn_pla_monto_vacaciones_pend(a.cod_compania,a.emp_id,a.anio,nvl(sum(a.dias_pendiente_dinero),0)),0) as monto_pend,(select descripcion from tbl_sec_unidad_ejec e where a.cod_compania = e.compania and nvl(emp.seccion,emp.ubic_seccion) = e.codigo ) descDepto,emp.nombre_empleado nombre,emp.num_empleado,'' as fecha_inicio,'' fecha_final,'' as comentario,to_char(emp.fecha_ingreso,'dd/mm/yyyy')f_ingreso,nvl(sum(a.dias_pendiente_dinero),0) dias_dinero,emp.salario_base,nvl(mod(trunc(months_between(sysdate, emp.fecha_ingreso)), 12), 0)  meses,nvl(trunc(months_between(sysdate,emp.fecha_ingreso) / 12), 0) anios_ant,a.anio,nvl(sum(case when a.estado in (3, 4, 5) then a.dias_pendiente end),0) dias_dispo, nvl(sum(case when a.estado in (3, 5) then a.dias_pendiente end),0) dias_pend, nvl(sum(case when a.estado = 4 then a.dias_pendiente end),0) dias_res from tbl_pla_vacacion a,vw_pla_empleado emp where a.estado in (3, 4, 5) and a.cod_compania ="+compania+" and emp.estado <> 3 and emp.emp_id = a.emp_id and emp.compania = a.cod_compania having nvl(sum(a.dias_pendiente_dinero),0)  <> 0 group by rownum,a.emp_id,a.anio,a.cod_compania,emp.salario_base,emp.seccion,emp.ubic_seccion,emp.nombre_empleado,emp.num_empleado,emp.fecha_ingreso,to_char(emp.fecha_ingreso,'dd/mm/yyyy') ORDER BY 3,7,1,9 asc  ";

al = SQLMgr.getDataList(sql); 

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
	String title = "RECURSOS HUMANOS";
	String subtitle = "VACACIONES TOMADAS Y PENDIENTES (VENCIDAS)";
	String xtraSubtitle = "";//" DEL "+fechaini+" AL "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".15"); //NO
	dHeader.addElement(".15"); //NOMBRE
	dHeader.addElement(".15"); //Ingreso	
	dHeader.addElement(".15"); //Sueldo Base 	
	dHeader.addElement(".10"); //Desde
	dHeader.addElement(".10"); //Hasta
	dHeader.addElement(".10"); //Canti Dias
	dHeader.addElement(".10"); //Año	
	dHeader.addElement(".10"); //Observacion
		
							
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

    pc.setFont(8, 1);
	
	pc.setVAlignment(1);
	
	pc.addCols(" ",0,dHeader.size());	  
	double totalDias =0.00,totalSalario =0.00,totalGrep=0.00 ;
	double totalDiasEmp =0.00,totalSalarioEmp =0.00,totalGrepEmp=0.00 ;
	double totalMes =0.00,totalSalarioMes =0.00,totalGrepMes=0.00 ;
	double totalEmp =0.00;
	pc.setFont(8,0);
	
	String groupByEmp = "";
	for ( int i = 0; i<al.size(); i++ ){
		cdo = (CommonDataObject)al.get(i);
	
		if(!groupByEmp.equals(cdo.getColValue("empId")))
		{
			pc.addCols("Departamento: "+cdo.getColValue("descDepto"),0,dHeader.size());
			pc.addCols("No. Empleado: "+cdo.getColValue("num_empleado"),0,1);
			pc.addCols("Nombre: "+cdo.getColValue("nombre"),0,2);
			pc.addCols("F. Ingreso: "+cdo.getColValue("f_ingreso"),0,2);
			pc.addCols("Salario Base:"+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base")),0,2); 
			pc.addCols("Ant: Años:"+cdo.getColValue("anios")+" - Meses:"+cdo.getColValue("meses"),0,2); 
		}//groupByEmp
	
	   if ( !groupByEmp.equals(cdo.getColValue("empId")) ){
	   
	   // pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	   pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
		pc.addCols("SEC.",1,1);
		pc.addCols("DESDE",1,1);
		pc.addCols("HASTA",1,1);
		pc.addCols("CANT. DIAS",1,1);
		pc.addCols("PERIODO",1,1);
		pc.addCols("OBSERVACION",1,4);
	
	    //pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);		
	   pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
	 }
		
		if(cdo.getColValue("ord").trim().equals("1")){
		pc.addCols(cdo.getColValue("sec"),1,1);
		pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
		pc.addCols(cdo.getColValue("fecha_final"),1,1);
		pc.addCols(cdo.getColValue("dias"),1,1);
		pc.addCols(cdo.getColValue("anio_ac"),1,1);
		pc.addCols(" ",1,4);
		}
		else
		{
		
		}
		/*pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
		
		totalDias += Double.parseDouble(cdo.getColValue("dd_dias_vac"));
		totalDiasEmp += Double.parseDouble(cdo.getColValue("dd_dias_vac"));
		totalSalario += Double.parseDouble(cdo.getColValue("dd_valor_neto"));
		totalSalarioEmp += Double.parseDouble(cdo.getColValue("dd_valor_neto"));
		totalGrep += Double.parseDouble(cdo.getColValue("dd_gasto_rep"));
		totalGrepEmp += Double.parseDouble(cdo.getColValue("dd_gasto_rep"));
		
		pc.addCols("",0,dHeader.size());*/
		
	
	   groupByEmp = cdo.getColValue("empId");
	}//for	  
				
				 
		
   if(al.size() == 0)pc.addCols("No Existen registros",1,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
