<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="com.lowagie.text.Chunk"%>
<%@ page import="com.lowagie.text.Paragraph"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
CommonDataObject cdo   = new CommonDataObject();
CommonDataObject cdoF   = new CommonDataObject();

String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String appendFilter2 	 = "";
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();
String compania 			 = (String) session.getAttribute("_companyId");
String empIdCert			 = request.getParameter("empIdCert");
String nombreEmpRepr	 = request.getParameter("nombreEmpRepr");
String cargoEmpRepr	 	 = request.getParameter("cargoEmpRepr");
String observacion	 	 = request.getParameter("observacion");
String dirigidoA		 = request.getParameter("dirigidoA");
String nota		 	 	 = request.getParameter("nota");
String cedula		 	 = request.getParameter("cedula");
String anio		 	 	 = request.getParameter("anio");
String noEmpleado        = request.getParameter("noEmpleado");

double salarioNeto=0.00, totalDeduc=0.00;

String fg 	 = request.getParameter("fg");

if (appendFilter 	== null) appendFilter = "";
if (empIdCert 		== null) empIdCert = "";
if (nombreEmpRepr == null) nombreEmpRepr = "";
if (cargoEmpRepr 	== null) cargoEmpRepr = "";
if (observacion 	== null) observacion = "";
if (dirigidoA 		== null) dirigidoA = "";
if (nota			 		== null) nota = "";

/*if (fg.equals("carta"))
{

}
else funcion = "getParientes";*/

//--------------Parámetros--------------------//
if (!compania.equals(""))
{
	appendFilter += " and z.compania = "+compania;
	appendFilter2+= " and d.cod_compania = "+compania;
}

if (!empIdCert.equals(""))
{
	appendFilter += " and z.emp_id = "+empIdCert;
	appendFilter2+= " and d.emp_id = "+empIdCert;
}




	sql = " select w.certificacion,w.certificacion2,w.certificacion3,w.nombre_empleado,x.* from (select 'El suscrito(a), "+nombreEmpRepr+", con cédula de identidad personal número "+cedula+", debidamente facultado(a) y en representación de "+_comp.getNombre()+", con R.U.C. "+_comp.getRuc()+" y D.V "+_comp.getDigitoVerificador()+" para la presente y con pleno conocimiento de las responsabilidades que señalan las leyes de la República,' certificacion2, ' '||decode(a.sexo,'F','la  Sra. ','el  Sr. ')||a.nombre_empleado nombre_empleado,'  con cédula de identidad personal  No. ' certificacion, a.cedula1||', '||decode(a.estado,3,'laboró','labora')||' en nuestra empresa, devengó las siguientes remuneraciones y se le retuvo durante el año fiscal ' certificacion3, to_char(a.gasto_rep,'99,990.00') gastoRepDsp, a.gasto_rep gastoRep from (select z.emp_id, z.compania, z.cedula1, z.nombre_empleado, z.num_ssocial, z.fecha_ingreso, z.fecha_egreso, nvl(z.gasto_rep,0) gasto_rep, z.cargo, z.sexo, z.estado, z.unidad_organi from vw_pla_empleado z where z.emp_id is not null "+appendFilter+") a, tbl_sec_unidad_ejec b, tbl_pla_cargo c where a.cargo = c.codigo and a.unidad_organi = b.codigo and a.compania = b.compania and a.compania = c.compania) w ,( select sum(nvl(a.sal_bruto,0)+nvl(a.prima_produccion,0)- nvl(a.prima_antiguedad,0)- nvl(a.preaviso,0))sal_bruto,sum(nvl(a.sal_bruto,0)-nvl(a.decimo,0)-nvl(a.participacion_utilidades,0) - nvl(a.incentivo,0)- nvl(a.vacaciones,0)  - nvl(a.prima_antiguedad,0)- nvl(a.preaviso,0)) totalSalario,sum(nvl(a.decimo,0))totalDecimo,sum(nvl(a.g_representacion,0)-nvl(a.decimo_gasto_rep,0))totalGastoRep,sum(nvl(a.participacion_utilidades,0))totalParticipacion, decode(2011,a.anio,nvl((select sum(nvl(imp_renta,0))  from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla not in(2,3,6)),0)- sum(nvl(a.imp_renta_gasto,0)),nvl((select sum(nvl(imp_renta,0))  from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla not in(2,3,6)),0))totalImpRenta,sum(nvl(a.seg_educativo,0))totalSecEdu,sum(nvl(a.imp_renta_gasto,0))totalImpRentaGasto,sum(nvl(a.salario_especie,0))totalEspecie,sum(nvl(a.incentivo,0)+nvl(a.prima_produccion,0)) totalBon,sum(nvl(a.vacaciones,0)) totalVac,nvl((select sum(nvl(imp_Renta,0))totalImpRentaDecimo from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 2),0)totalImpRentaDecimo, nvl( (select nvl(sum(imp_Renta),0)totalImpBon from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 6),0)totalImpBon, nvl( (select nvl(sum(imp_Renta),0)totalImpParticipacion from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 9),0)totalImpParticipacion, nvl( (select nvl(sum(imp_Renta),0)totalImpVacacion from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 3),0)totalImpVacacion from tbl_pla_acumulado_empleado a where a.emp_id = "+empIdCert+" and a.num_empleado = '"+noEmpleado+"' and a.anio = "+anio+" and a.cod_compania = "+compania+" group by a.emp_id,a.num_empleado,a.anio,a.cod_compania)x";
	cdo = SQLMgr.getData(sql);

/*

select x.* from( select sum(nvl(a.sal_bruto,0)-nvl(a.decimo,0)-nvl(a.participacion_utilidades,0) - nvl(a.bonificacion,0)- nvl(a.vacaciones,0)) totalSalario,sum(nvl(a.decimo,0))totalDecimo,sum(nvl(a.g_representacion,0))totalGastoRep,sum(nvl(a.participacion_utilidades,0))totalParticipacion,sum(nvl(a.imp_renta,0))totalImpRenta,sum(nvl(a.seg_educativo,0))totalSecEdu,sum(nvl(a.imp_renta_gasto,0))totalImpRentaGasto,sum(nvl(a.salario_especie,0))totalEspecie,sum(nvl(a.bonificacion,0)) totalBon,sum(nvl(a.vacaciones,0)) totalVac,nvl((select sum(nvl(imp_Renta,0))totalImpRentaDecimo from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 2),0)totalImpRentaDecimo, nvl( (select nvl(sum(imp_Renta),0)totalImpBon from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 6),0)totalImpBon, nvl( (select nvl(sum(imp_Renta),0)totalImpParticipacion from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 9),0)totalImpParticipacion, nvl( (select nvl(sum(imp_Renta),0)totalImpVacacion from  tbl_pla_pago_empleado where emp_id = a.emp_id and num_empleado=a.num_empleado and anio =a.anio and cod_compania= a.cod_compania and cod_planilla= 3),0)totalImpVacacion from tbl_pla_acumulado_empleado a where a.emp_id = "+empId+" and a.num_empleado = '"+noEmpleado+"' and a.anio = "+anio+" and a.cod_compania = "+compania+" group by a.emp_id,a.num_empleado,a.anio,a.cod_compania)x

    */
	sql = "select 'Panamá, '||to_char(sysdate,'dd')||' de '||to_char(sysdate,'FMmonth','NLS_DATE_LANGUAGE=SPANISH')||' de '||to_char(sysdate,'yyyy') fechaCarta,to_char(sysdate,'dd')||' de '||to_char(sysdate,'FMmonth','NLS_DATE_LANGUAGE=SPANISH')||' de '||to_char(sysdate,'yyyy') cartaHoy from dual";
	cdoF = SQLMgr.getData(sql);



if (request.getMethod().equalsIgnoreCase("GET"))
{
		String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
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
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "";
	String xtraSubtitle = "";
	int contentFontSize = 12;
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 9;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".10");



	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.addCols("",1,dHeader.size(),cHeight*6);
	pc.setTableHeader(1);
	// titulos de columnas
	pc.setFont(12, 1);
	// lineas en blanco
	pc.addCols("",1,dHeader.size(),cHeight*3);
	pc.addCols("C E R T I F I C A C I Ó N",1,dHeader.size());
	pc.addCols("RETENCIONES EFECTUADAS POR EL EMPLEADOR",1,dHeader.size());
	pc.addCols("",1,dHeader.size(),cHeight*3);
	pc.setFont(10, 0);
	// dirigida a
	pc.addCols("",0,1);
	pc.setFont(10,1);
	pc.addCols(dirigidoA,0,6);
	pc.addCols("",1,dHeader.size(),cHeight*2);
	pc.setFont(10,0);
	// cuerpo del a carta
	Paragraph p = new Paragraph();
	p.setLeading(0.0f,1.0f);//double space
	p.setAlignment(0);//justified
	//p.setFirstLineIndent(25.0f);//indentation
	p.add(new Chunk("El  suscrito(a), ",pc.getFont()));
	pc.setFont(contentFontSize,1);
	//nombreEmpRepr = nombreEmpRepr +"AVFDGBHT";
	 
	if(nombreEmpRepr.length() <16)p.add(new Chunk("         "+nombreEmpRepr+"       ",pc.getFont()));
	else p.add(new Chunk(" "+nombreEmpRepr+" ",pc.getFont()));
	pc.setFont(contentFontSize,0);
	p.add(new Chunk(" , con cédula de identidad personal número ",pc.getFont()));
	//p.setFirstLineIndent(25.0f);//indentation	
	p.add(new Chunk(" "+cedula+", ",pc.getFont()));
	p.add(new Chunk(" debidamente facultado(a) y en representación de ",pc.getFont()));
	p.add(new Chunk(" "+_comp.getNombre()+", con R.U.C. "+_comp.getRuc()+" y D.V "+_comp.getDigitoVerificador(),pc.getFont()));
	p.add(new Chunk(" para la presente y con pleno conocimiento de las responsabilidades que señalan las leyes de la República,",pc.getFont()));
	 
	
	pc.addCols("",1,1);
	//pc.addCols(cdo.getColValue("certificacion2"),0,5);
	pc.addCols(p,0,5);
	pc.addCols("",1,1);
	pc.addCols("",1,dHeader.size(),cHeight);
	pc.addCols("",1,1);
	pc.addCols("C E R T I F I C A",1,5);
	pc.addCols("",1,1);
	/*pc.addCols("",1,1);
	pc.addCols(cdo.getColValue("certificacion"),0,5);
	pc.addCols("",1,1);*/
	pc.addCols("",1,dHeader.size(),cHeight);
	p = new Paragraph();
	p.setLeading(0.0f,1.0f);//double space
	p.setAlignment(0);//justified
	//p.setFirstLineIndent(25.0f);//indentation
	if(cdo.getColValue("nombre_empleado").length()+cdo.getColValue("certificacion").length() < 60)
	p.add(new Chunk("Que "+cdo.getColValue("nombre_empleado")+" ",pc.getFont()));
	else p.add(new Chunk("Que        "+cdo.getColValue("nombre_empleado")+"         ",pc.getFont()));
	 
	pc.setFont(contentFontSize,0);
	p.add(new Chunk(cdo.getColValue("certificacion")+" ",pc.getFont()));
	
	p.add(new Chunk(cdo.getColValue("certificacion3")+" ",pc.getFont()));
	pc.setFont(contentFontSize,1);
	p.add(new Chunk(""+anio,pc.getFont()));
	pc.setFont(contentFontSize,0);
	p.add(new Chunk(" , las siguientes sumas:",pc.getFont()));
		pc.addCols("",1,1);
		pc.addCols(p,0,5);
		pc.addCols("",1,1);
	
	
	//****************** desglose ***********************
		// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight);
	pc.setFont(10,1);
	pc.addCols("",1,1);
	pc.addCols("CONCEPTO",1,2);
	pc.addCols("INGRESOS RECIBIDOS",1,1);
	pc.addCols("SUMA RETENIDA IMPUESTO S / R",1,1);
	pc.addCols("SUMA RETENIDA SEGURO EDUC.",1,1);
	pc.addCols("",1,1);
	// salario base
	pc.addCols("",1,1);
	pc.addCols("SALARIO",0,2);
	pc.setFont(8,0);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalSalario")),2,1);
	
	double imp_renta=0.00,impRenta=0.00,salario=0.00;
		imp_renta= Double.parseDouble(cdo.getColValue("totalImpRenta"));
		
		
	pc.addCols(""+CmnMgr.getFormattedDecimal(imp_renta),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalSecEdu")),2,1);
	pc.addCols("",1,1);
	// gasto representacion
	pc.setFont(10,1);
	pc.addCols("",1,1);
	pc.addCols("GASTOS DE REPRESENTACION",0,2);
	pc.setFont(8,0);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalGastoRep")),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalImpRentaGasto")),2,1);
	pc.addCols("0.00",2,1);
	pc.addCols("",1,1);
	//decimo
	pc.setFont(10,1);
	pc.addCols("",1,1);
	pc.addCols("DECIMO TERCER MES",0,2);
	pc.setFont(8,0);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalDecimo")),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalImpRentaDecimo")),2,1);
	pc.addCols("0.00",2,1);
	pc.addCols("",1,1);
	//Vacaciones
	pc.setFont(10,1);
	pc.addCols("",1,1);
	pc.addCols("VACACIONES",0,2);
	pc.setFont(8,0);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalVac")),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalImpVacacion")),2,1);
	pc.addCols("0.00",2,1);
	pc.addCols("",1,1);
	//Bonificaciones
	pc.setFont(10,1);
	pc.addCols("",1,1);
	pc.addCols("BONIFICACIONES",0,2);
	pc.setFont(8,0);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalBon")),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalImpBon")),2,1);
	pc.addCols("0.00",2,1);
	pc.addCols("",1,1);
	pc.setFont(10,1);
	pc.addCols("",1,1);
	pc.addCols("PARTICIPACION EN UTILIDADES",0,2);
	pc.setFont(8,0);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalParticipacion")),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalImpParticipacion")),2,1);
	pc.addCols("0.00",2,1);
	pc.addCols("",1,1);
	


	salarioNeto   = Double.parseDouble(cdo.getColValue("sal_bruto"))+Double.parseDouble(cdo.getColValue("totalGastoRep"));
	
	impRenta   = Double.parseDouble(cdo.getColValue("totalImpRenta"))+Double.parseDouble(cdo.getColValue("totalImpRentaGasto"))+(Double.parseDouble(cdo.getColValue("totalImpRentaDecimo"))+Double.parseDouble(cdo.getColValue("totalImpVacacion"))+Double.parseDouble(cdo.getColValue("totalImpBon"))+Double.parseDouble(cdo.getColValue("totalImpParticipacion")));
	
	
	// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight);
	// SALARIO NETO
	pc.setFont(10,0);
	pc.addCols("",1,1);
	pc.addCols("TOTAL",0,2);
	pc.setFont(10,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(salarioNeto),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(impRenta),2,1);
	pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totalSecEdu")),2,1);
	pc.addCols("",1,2);
	// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight);
	
	
	pc.setFont(10,0);

	p = new Paragraph();
	p.setLeading(0.0f,1.0f);//double space
	p.setAlignment(0);//justified
	//p.setFirstLineIndent(25.0f);//indentation
	p.add(new Chunk("La información contenida en esta certificación es totalmente cierta y reposa en nuestros archivos la cual pongo a disposición de la Dirección General de Ingresos.",pc.getFont()));
	pc.addCols("",1,1);
	pc.addCols(p,0,5);
	pc.addCols("",1,1);
	
	// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight*2);
	
	pc.setFont(10,0);
	pc.addCols("",1,1);
	pc.addCols("Expedida y firmada hoy, "+cdoF.getColValue("cartaHoy"),0,5);
	pc.addCols("",1,1);
	// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight);
	// información adicional
	pc.setFont(10,0);
	pc.addCols("",1,1);
	pc.addCols(observacion,0,4);
	pc.addCols("",1,1);
	// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight);
	// nota al final antes de despedida de la carta
	pc.addCols("",1,1);
	pc.addCols(nota,0,4);
	pc.addCols("",1,1);
	// lineas en blanco
	pc.addCols(" ",1,dHeader.size(),cHeight*2);
	// firma
	pc.addCols("",1,1);
	pc.addCols("Atentamente,",0,5);
	pc.addCols("",1,dHeader.size(),cHeight*3);
	pc.addCols("",1,1);
	pc.addCols("Lic. "+nombreEmpRepr+"      "+cedula,0,5);
	pc.addCols("",1,1);
	pc.addCols("",1,1);
	pc.addCols(cargoEmpRepr,0,5);
	pc.addCols("",1,1);
	pc.addCols("",1,1);
	pc.addCols(" ",0,dHeader.size()-1);



	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

