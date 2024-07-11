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
<!-- Clínica Hospital San Fernando               -->
<!-- Fecha: 15/05/2011                           -->
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

//if (mes   == null) throw new Exception("Por favor escoge un mes!");
if (anio  == null) throw new Exception("Introduzca el año!");
//if (periodo  == null) throw new Exception("Introduzca el Periodo!");
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


sql= "SELECT ALL pe.periodo_mes pe_periodo "+subqry1+", to_char(pe.fecha_final,'dd/mm/yyyy')   pe_fecha_final, to_char(pe.fecha_inicial,'dd/mm/yyyy') pe_fecha_inicial, pa.provincia       pa_provincia, pa.sigla pa_sigla, pa.tomo pa_tomo, pa.asiento pa_asiento, DECODE(pa.provincia,0,' ',00,' ',11,'B',12,'C',pa.provincia)||RPAD(DECODE(pa.sigla,'00','  ','0','  ',pa.sigla),2,' ')||'-'||LPAD(TO_CHAR(pa.tomo),5,'0')||'-'||LPAD(TO_CHAR(pa.asiento),6,'0') pa_cedula ,pa.sal_bruto pa_sal_bruto, pa.num_cheque pa_num_cheque, pa.cod_compania pa_compania, NVL(dd.tiempo_solicitado,0) dd_tiempo_solicitado, NVL(dd.tiempo_solicitado_dinero,0) dd_tiempo_solicitado_dinero, to_char(dd.fecha_inicio,'dd/mm/yyyy')dd_fecha_inicio, to_char(dd.fecha_final,'dd/mm/yyyy') dd_fecha_final,dd.dias_vac dd_dias_vac, dd.valor_vac dd_valor_vac, dd.dias_libres dd_dias_libres, dd.valor_libres dd_valor_libres,(NVL(dd.valor_vac,0)-NVL(dd.valor_libres,0)) dd_valor_neto ,(NVL(dd.dias_vac,0)-NVL(dd.dias_libres,0)) dd_dias_neto,dd.anio_ac dd_anio_ac, dd.periodo_ac dd_periodo_ac, dd.gasto_rep dd_gasto_rep, em.primer_nombre||' '||em.segundo_nombre||' '||em.primer_apellido||' '||NVL(em.apellido_casada,em.segundo_apellido) em_nombre_emp,em.num_empleado em_num_emp,em.num_ssocial em_num_ssocial,(NVL(dd.valor_vac,0)-NVL(dd.valor_libres,0)) dd_valor_mes,ROUND(dd.periodo_ac/2,0) dd_mes,pa.emp_id empId,nvl((select sum((NVL(valor_vac,0)-NVL(valor_libres,0))) from tbl_pla_dist_dias_vac where cod_compania = pa.cod_compania AND emp_id = pa.emp_id AND pa.anio = anio_pago AND pe.anio = anio_pago AND pe.periodo = quincena_pago and status in('PR','AP')),0) totalNeto,(select descripcion from tbl_pla_vac_parametro where mes = ROUND(dd.periodo_ac/2,0)  ) mes,(select decode(quincena1,dd.periodo_ac,'PRIMERA','SEGUNDA')quincena from tbl_pla_vac_parametro where mes = ROUND(dd.periodo_ac/2,0))quincena FROM tbl_pla_planilla_encabezado pe, tbl_pla_pago_empleado pa, tbl_pla_dist_dias_vac dd, tbl_pla_empleado em "+tablaX+" WHERE (pa.num_planilla = pe.num_planilla AND pa.cod_planilla = pe.cod_planilla AND pa.anio = pe.anio AND pa.cod_compania = pe.cod_compania) AND (pa.cod_compania = dd.cod_compania) AND pa.emp_id = dd.emp_id AND (pa.anio = dd.anio_pago) AND (pe.anio = dd.anio_pago)AND (pe.periodo = dd.quincena_pago)AND (pa.cod_compania = "+compania+")AND (dd.cod_compania = em.compania)AND dd.emp_id = em.emp_id AND (pe.anio = "+anio+") "+appendFilter+" AND (pe.cod_compania = "+compania+") AND (pe.cod_planilla = 3) and dd.status in('PR','AP') ORDER BY em.num_empleado,  ROUND(dd.periodo_ac/2,0)";

al = SQLMgr.getDataList(sql); 
System.out.println("sqlQuery == "+sql);


sql= "select z.mes , z.quincena, z.anio, sum(z.dd_valor_neto) neto, sum(z.dd_gasto_rep) gasto from ( SELECT  (select descripcion from tbl_pla_vac_parametro where mes = ROUND(dd.periodo_ac/2,0)  ) mes,(select decode(quincena1,dd.periodo_ac,'PRIMERA','SEGUNDA')quincena from tbl_pla_vac_parametro where mes = ROUND(dd.periodo_ac/2,0))quincena,  (NVL(dd.valor_vac,0)-NVL(dd.valor_libres,0)) dd_valor_neto , nvl(dd.gasto_rep,0) dd_gasto_rep,  (NVL(dd.valor_vac,0)-NVL(dd.valor_libres,0)) dd_valor_mes, (nvl((select sum((NVL(valor_vac,0)-NVL(valor_libres,0))) from tbl_pla_dist_dias_vac where cod_compania = pa.cod_compania AND emp_id = pa.emp_id AND pa.anio = anio_pago AND pe.anio = anio_pago AND pe.periodo = quincena_pago and status in('PR','AP')),0)) totalNeto , dd.anio_ac anio FROM tbl_pla_planilla_encabezado pe, tbl_pla_pago_empleado pa, tbl_pla_dist_dias_vac dd, tbl_pla_empleado em "+tablaX+"  WHERE (pa.num_planilla = pe.num_planilla AND pa.cod_planilla = pe.cod_planilla AND pa.anio = pe.anio AND pa.cod_compania = pe.cod_compania) AND (pa.cod_compania = dd.cod_compania) AND pa.emp_id = dd.emp_id AND (pa.anio = dd.anio_pago) AND (pe.anio = dd.anio_pago) AND (pe.periodo = dd.quincena_pago)AND ((pa.cod_compania = "+compania+")) AND (dd.cod_compania = em.compania) AND dd.emp_id = em.emp_id AND (pe.anio = "+anio+") "+appendFilter+" AND (pe.cod_compania = "+compania+") AND (pe.cod_planilla = 3) and dd.status in('PR','AP')) z group by z.mes, z.quincena, z.anio order by 3,1,2 ";
alRes = SQLMgr.getDataList(sql); 
System.out.println("sqlQuery Resumen== "+sql);


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
	String subtitle = "DISTRIBUCIÓN DIAS DE VACACIONES";
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
	dHeader.addElement(".15"); //NOMBRE	
	dHeader.addElement(".15"); //CEDULA	
	dHeader.addElement(".10"); //SS
	dHeader.addElement(".10"); //T DIAS
	dHeader.addElement(".10"); //DINERO
	dHeader.addElement(".10"); //MONTO	
		
							
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

    pc.setFont(8, 1);
	
	pc.setVAlignment(1);
	pc.addCols(" ",0,dHeader.size());
	pc.addBorderCols("No.",1,1,1.0f,1.0f,0.0f,0.0f,20f);	
	pc.addBorderCols("NOMBRE DEL EMPLEADO",0,2,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("CÉDULA",1,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("S.SOCIAL",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("T.DÍAS",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("T.DINERO",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("MONTO",1,1,1.0f,1.0f,0.0f,0.0f);
	
	pc.addCols(" ",0,dHeader.size());	  
	double totalDias =0.00,totalSalario =0.00,totalGrep=0.00 ;
	double totalDiasEmp =0.00,totalSalarioEmp =0.00,totalGrepEmp=0.00 ;
	double totalMes =0.00,totalSalarioMes =0.00,totalGrepMes=0.00 ;
	double totalEmp =0.00;
	pc.setFont(8,0);
	
	String groupByEmp = "";
	for ( int i = 0; i<al.size(); i++ ){
		cdo = (CommonDataObject)al.get(i);
	
		if(!groupByEmp.equals(cdo.getColValue("empId")) ){
			
		if ( i != 0 ){
		    
				 pc.setFont(8,1,Color.red);
				 pc.addCols("        TOTALES      ==>     ",0,2);
				 pc.addCols(""+totalDiasEmp,1,1);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalSalarioEmp),1,2);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalGrepEmp),1,2);
				 pc.addCols("",3,2);
				 pc.setFont(8,0);
				 pc.addCols(" ",0,dHeader.size());
				 
				 totalDiasEmp=0.00;
				 totalSalarioEmp=0.00;
				 totalGrepEmp=0.00;
		}
		
		pc.addCols(cdo.getColValue("em_num_emp"),1,1);
		pc.addCols(cdo.getColValue("em_nombre_emp"),0,2);
		pc.addCols(cdo.getColValue("pa_cedula"),1,1);
		pc.addCols(cdo.getColValue("em_num_ssocial"),1,1);
	    pc.addCols(cdo.getColValue("dd_tiempo_solicitado"),1,1);
		pc.addCols(cdo.getColValue("dd_tiempo_solicitado_dinero"),1,1);
		//dd_valor_neto
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalNeto")),1,1);
	
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8,1,Color.white);
	    pc.addCols("                  Periódo de Vacacciones del :         "+cdo.getColValue("dd_fecha_inicio")+ "         hasta el:         "+cdo.getColValue("dd_fecha_final"),0,dHeader.size(),Color.gray); 
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8,0);
				
	}//groupByEmp
	
	   if ( !groupByEmp.equals(cdo.getColValue("empId")) ){
	   
	   // pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	   pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
		pc.addCols("MES",1,1);
		pc.addCols("QUINCENA",1,1);
		pc.addCols("DÍAS",1,1);
		pc.addCols("SALARIO",1,1);
		pc.addCols("GASTO REP.",1,1);
		pc.addCols(" ",1,3);
	
	    //pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);		
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
	 }
		
		
		pc.addCols(cdo.getColValue("mes"),1,1);
		pc.addCols(cdo.getColValue("quincena"),1,1);
		pc.addCols(cdo.getColValue("dd_dias_vac"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("dd_valor_neto")),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("dd_gasto_rep")),1,1);
		pc.addCols(" ",1,3);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
		
		totalDias += Double.parseDouble(cdo.getColValue("dd_dias_vac"));
		totalDiasEmp += Double.parseDouble(cdo.getColValue("dd_dias_vac"));
		totalSalario += Double.parseDouble(cdo.getColValue("dd_valor_neto"));
		totalSalarioEmp += Double.parseDouble(cdo.getColValue("dd_valor_neto"));
		totalGrep += Double.parseDouble(cdo.getColValue("dd_gasto_rep"));
		totalGrepEmp += Double.parseDouble(cdo.getColValue("dd_gasto_rep"));
		
		pc.addCols("",0,dHeader.size());
		
	
	   groupByEmp = cdo.getColValue("empId");
	}//for	  
				 pc.setFont(8,1,Color.red);
				 pc.addCols("        TOTALES      ==>     ",0,2);
				 pc.addCols(""+totalDiasEmp,1,1);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalSalarioEmp),1,1);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalGrepEmp),1,1);
				 pc.addCols(" ",1,3);
				 pc.setFont(8,0);
				 pc.addCols("  ",0,dHeader.size());
				 

	pc.addCols(" * * * * * TOTALES FINALES  * * * * *",1,5);
	pc.addCols(" ",1,3);
	
	pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
	pc.addCols("DESDE   -    HASTA",1,2);
	pc.addCols("SALARIO",1,2);
	pc.addCols("GASTO REP.",1,2);
	pc.addCols(" ",1,4);
	pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
		
	pc.addCols(""+fechaDesde+"  -  "+fechaHasta,1,2);
	pc.addCols(CmnMgr.getFormattedDecimal(totalSalario),1,2);
	pc.addCols(CmnMgr.getFormattedDecimal(totalGrep),1,2);
	pc.addCols(" ",1,5);	
    pc.addCols("  ",0,dHeader.size());	
	
	pc.setFont(8,1);
	pc.addCols("  TOTALES POR MES Y POR PERIODO ",0,5);
	pc.addCols(" ",1,3);	
    pc.addCols("Periodo de Vacaciones ",1,2);	
	pc.addCols("Sal. Vacaciones",2,2);	
	pc.addCols("Gasto Rep. ",2,2);
    pc.addCols(" ",1,2);		
		
		String groupByMes = "";
	for ( int i = 0; i<alRes.size(); i++ ){
		cdo = (CommonDataObject)alRes.get(i);
		
   if(!groupByMes.equals(cdo.getColValue("mes")) ){
			
		if ( i != 0 ){
   
   	 pc.setFont(8,1);
				 pc.addCols("        TOTALES      ==>     ",1,2);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalSalarioMes),2,2);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalGrepMes),2,2);
				 pc.addCols("",1,2);
				 pc.setFont(8,0);
				 pc.addCols(" ",0,dHeader.size());
				 
				 totalMes=0.00;
				 totalSalarioMes=0.00;
				 totalGrepMes=0.00;
		}
		}
		pc.setFont(8,0);
		pc.addCols(cdo.getColValue("mes")+" - "+cdo.getColValue("anio"),1,1);
		pc.addCols(cdo.getColValue("quincena"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("neto")),2,2);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("gasto")),2,2);
		pc.addCols(" ",1,2);
		//pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
		
		totalSalarioMes += Double.parseDouble(cdo.getColValue("neto"));
		totalGrepMes += Double.parseDouble(cdo.getColValue("gasto"));
		
		pc.addCols("",0,dHeader.size());
		
	
	   groupByMes = cdo.getColValue("mes");
	  
	}//for	  
   
    pc.setFont(8,1);
				 pc.addCols("        TOTALES      ==>     ",1,2);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalSalarioMes),2,2);
				 pc.addCols(""+CmnMgr.getFormattedDecimal(totalGrepMes),2,2);
				 pc.addCols(" ",1,2);
				 pc.setFont(8,0);
				 pc.addCols("  ",0,dHeader.size());
				 
	pc.setFont(8,2);			 
   pc.addCols("TOTALES FINALES",1,2);
	pc.addCols(CmnMgr.getFormattedDecimal(totalSalario),2,2);
	pc.addCols(CmnMgr.getFormattedDecimal(totalGrep),2,2);
	pc.addCols(" ",1,2);	
    pc.addCols("  ",0,dHeader.size());	
   
   
   if(al.size() == 0)pc.addCols("No Existen registros",1,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
