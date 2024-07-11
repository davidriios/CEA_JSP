<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
StringBuffer sql = new StringBuffer();

String anio = request.getParameter("anio");
String subTitle = "";
String empId = request.getParameter("empId");
String noEmpleado = request.getParameter("empNo");
String salario = request.getParameter("salario");
String fisco = request.getParameter("fisco");
String empName = request.getParameter("empName")==null?"":request.getParameter("empName");
String empMsalary = request.getParameter("empMsalary")==null?"":request.getParameter("empMsalary");
String egreso = request.getParameter("egreso")==null?"":request.getParameter("egreso");
String fechaIngreso = request.getParameter("fechaIngreso")==null?"":request.getParameter("fechaIngreso");
String antiguedad = request.getParameter("antiguedad")==null?"":request.getParameter("antiguedad");
String vacVencSalario = request.getParameter("vacVencSalario")==null?"0.00":request.getParameter("vacVencSalario");
String hayPlanilla = request.getParameter("hayPlanilla")==null?"N":request.getParameter("hayPlanilla");
String anioPago = request.getParameter("anioPago")==null?"0":request.getParameter("anioPago");
String periodoPago = request.getParameter("periodoPago")==null?"0":request.getParameter("periodoPago");
String salAPagar = request.getParameter("salAPagar")==null?"0":request.getParameter("salAPagar");
String rataHora = request.getParameter("rataHora")==null?"0":request.getParameter("rataHora");
String rataHoraGr = request.getParameter("rataHoraGr")==null?"0":request.getParameter("rataHoraGr");
String salAdescontar = request.getParameter("salAdescontar")==null?"0":request.getParameter("salAdescontar");
String diasLaborados = request.getParameter("diasLaborados")==null?"0":request.getParameter("diasLaborados");
String pVac = request.getParameter("pVac")==null?"":request.getParameter("pVac");
String pXiii = request.getParameter("pXiii")==null?"":request.getParameter("pXiii");
String pPreaviso = request.getParameter("pPreaviso")==null?"":request.getParameter("pPreaviso");
String pPrima = request.getParameter("pPrima")==null?"":request.getParameter("pPrima");
String pIndemn = request.getParameter("pIndemn")==null?"":request.getParameter("pIndemn");
String pRec25 = request.getParameter("pRec25")==null?"":request.getParameter("pRec25");
String pRec50 = request.getParameter("pRec50")==null?"":request.getParameter("pRec50");
String tsAnios = request.getParameter("tsAnios")==null?"0":request.getParameter("tsAnios");
String tsMeses = request.getParameter("tsMeses")==null?"0":request.getParameter("tsMeses");
String tsDias = request.getParameter("tsDias")==null?"0":request.getParameter("tsDias");
String gastoRep = request.getParameter("gastoRep")==null?"0":request.getParameter("gastoRep");
String motivoDesc = request.getParameter("motivoDesc")==null?"":request.getParameter("motivoDesc");
String trPaSt = request.getParameter("trPaSt")==null?"0":request.getParameter("trPaSt");
String vacSalario = request.getParameter("vacSalario")==null?"0":request.getParameter("vacSalario");
String vacPropSalario = request.getParameter("vacPropSalario")==null?"0":request.getParameter("vacPropSalario");
String vacGasto = request.getParameter("vacGasto")==null?"0":request.getParameter("vacGasto");
String vacPropGasto = request.getParameter("vacPropGasto")==null?"0":request.getParameter("vacPropGasto");
String xiiiAcumSalario = request.getParameter("xiiiAcumSalario")==null?"0":request.getParameter("xiiiAcumSalario");
String xiiiAcumGrep = request.getParameter("xiiiAcumGrep")==null?"0":request.getParameter("xiiiAcumGrep");
String trPaTrxBon = request.getParameter("trPaTrxBon")==null?"0":request.getParameter("trPaTrxBon");
String otBeneficiosValor = request.getParameter("otBeneficiosValor")==null?"0":request.getParameter("otBeneficiosValor");

if (empId == null) empId = "0";
if (noEmpleado == null) noEmpleado = "0";
if (anio == null || anio.equals("")) throw new Exception("El año no es válido!");
if (salario == null) salario = "";
if (fisco == null) fisco = "";

ArrayList alVacP = new ArrayList();
ArrayList alPrima = new ArrayList();
ArrayList alDecimo = new ArrayList();

CommonDataObject cdoVac = SQLMgr.getData("select sum(sal_bruto) sal_bruto, display from (select p.sal_bruto, to_char(l.dl_desde,'dd \"de\" month', 'nls_date_language=spanish')||to_char(l.dl_hasta,'\" al \"dd \"de\" month \"de\" yyyy', 'nls_date_language=spanish') display from tbl_pla_li_pagos p, tbl_pla_li_liquidacion l where p.cod_compania = 1 and p.emp_id = "+empId+" and p.num_empleado = '"+noEmpleado+"' and trunc(p.fecha_inicio) = to_date('"+egreso+"','dd/mm/yyyy') and p.paga_dec = 'S' and l.emp_id = p.emp_id and l.compania = p.cod_compania and p.fecha_inicio = l.fecha_egreso ) group by display");

if(cdoVac ==null){cdoVac = new CommonDataObject(); cdoVac.addColValue("sal_bruto","0");cdoVac.addColValue("display","0");}

if (pVac.equals("S")){
	sql.append("select to_char(to_date('01/'||mes||'/'||anio,'dd/mm/yyyy'),'MONTH', 'nls_date_language=spanish')||' - '||anio as mes, sum(sal_bruto) sal_bruto from (select pp.descripcion, pp.mes, p.anio, p.periodo, p.sal_bruto from tbl_pla_li_vacaciones_prop p, tbl_pla_vac_parametro pp where p.emp_id = ");
	sql.append(empId);
	sql.append(" and p.cod_compania = ");
	sql.append(compania);
	sql.append(" and pp.quincena1 = p.periodo or pp.quincena2 =p.periodo order by p.anio,p.periodo) group by mes,anio order by anio, mes");

	alVacP = SQLMgr.getDataList(sql.toString());
}

if (pPrima.equals("S")){
	sql = new StringBuffer();
	sql.append("select a.anio, sum(a.sal_bruto) as sal_bruto from tbl_pla_li_pagos a, tbl_pla_vac_parametro b where cod_compania = ");
	sql.append(compania);
	sql.append(" and emp_id = ");
	sql.append(empId);
	sql.append(" and trunc(a.fecha_inicio) = to_date('");
	sql.append(egreso);
	sql.append("','dd/mm/yyyy') and (b.quincena1 = a.periodo or b.quincena2 = a.periodo) group by a.anio order by anio");

	alPrima = SQLMgr.getDataList(sql.toString());
}

//DECIMO XIII MES
if (pXiii.equals("S")){
	//hayPlanilla
	sql = new StringBuffer();
	sql.append("");
	//alDecimo = SQLMgr.getDataList(sql.toString());
}

CommonDataObject cdoFirma = SQLMgr.getData("select (select initcap(e.nombre_empleado)||'\n'||c.denominacion from tbl_pla_cargo c, vw_pla_empleado e where c.codigo = get_sec_comp_param("+compania+",'RH_JEFE_RRHH') and c.compania = "+compania+" and c.codigo = e.cargo and e.estado=1) jefe_rrhh, (select initcap(e.nombre_empleado)||'\n'||c.denominacion from tbl_pla_cargo c, vw_pla_empleado e where c.codigo = get_sec_comp_param("+compania+",'RH_JEFE_CONT') and c.compania = "+compania+" and c.codigo = e.cargo and e.estado=1) jefe_cont from dual");

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
	float height = 72 * 11f;//1008
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "CÁLCULO DE TERMINACIÓN DE CONTRATO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	
	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	footer.setFont(7,0);
	
	footer.setNoColumn(3);
	footer.createTable();
	footer.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
	footer.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
	footer.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
	footer.addCols(cdoFirma.getColValue("jefe_rrhh"),0,1);
	footer.addCols(cdoFirma.getColValue("jefe_cont"),1,1);
	footer.addCols("Colaborador",1,1);


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	double totVacPro = 0.0, totPrima = 0.0, vacProp = 0.0, gastoRepP = 0.0, totalSemanas=0.0,prima=0.0,preaviso = 0.0, indemnizacion=0.0;
	double salRegApagar = (Double.parseDouble(rataHora)*Double.parseDouble(diasLaborados)+Double.parseDouble(salAPagar))-Double.parseDouble(salAdescontar);
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.setFont(8,1);
		pc.addCols("* *  CAUSAL * *     "+motivoDesc,0,dHeader.size());
		
		pc.setFont(8,0);
		pc.addBorderCols("Nombre:",0,1,0.0f,0.5f,0.5f,0.5f);
		pc.addBorderCols(empName,0,dHeader.size()-1,0.0f,0.5f,0.0f,0.5f);
		
		pc.addBorderCols("Salario Base:",0,1,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols(empMsalary,1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("F.Ingreso",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols(fechaIngreso,1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("F.Egreso",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols(egreso,1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Tiempo trabajado",1,2,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols(antiguedad,0,2,0.5f,0.5f,0.0f,0.5f);
		
		pc.addCols("",0,dHeader.size());
		
		pc.addBorderCols("Salario Regular: "+cdoVac.getColValue("display")==null?"0":cdoVac.getColValue("display")+ ": ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(""+salRegApagar),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,dHeader.size()-3,0.0f,0.0f,0.0f,0.0f);
		
		//VACACIONES
		if (pVac.equals("S")){
			pc.addCols(" ",0,dHeader.size());
			
			pc.setFont(8,1);
			pc.addCols(" ",0,3);
			pc.addBorderCols("VACACIONES PROPORCIONALES:",1,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(8,0);
			for (int i=0; i<alVacP.size();i++){
				cdo = (CommonDataObject)alVacP.get(i);
				
				pc.addCols(" ",0,3);
				pc.addCols(cdo.getColValue("mes"),0,2);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("sal_bruto")),2,1);			
				pc.addCols(" ",0,4);
				
				totVacPro += Double.parseDouble(cdo.getColValue("sal_bruto"));
			}
			
			totVacPro = totVacPro + salRegApagar;
			vacProp = totVacPro/11;
			
			pc.addCols(" ",0,3);
			pc.addCols("--",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(""+salRegApagar),2,1);			
			pc.addCols(" ",0,4);

			pc.setFont(9,1);
			pc.addCols(" ",0,3);
			pc.addCols("Total",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(""+totVacPro),2,1);			
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(vacProp)+" (VACACIONES PROPORCIONALES)",1,4);
			
			pc.addCols("",1,dHeader.size()-4);			
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal((vacVencSalario))+" (VACACIONES VENCIDAS)",1,4);
		}
		
		//DECIMO XIII MES
		if (pXiii.equals("S")){
			pc.addCols(" ",0,dHeader.size());
			
			double totDecimo = 0.0;
			
			pc.setFont(8,1);
			pc.addCols(" ",0,3);
			pc.addBorderCols("XIII MES:",1,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(8,0);
			for (int i=0; i<alDecimo.size();i++){
				cdo = (CommonDataObject)alDecimo.get(i);
				
				pc.addCols(" ",0,3);
				pc.addCols(cdo.getColValue("mes"),0,2);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("sal_bruto")),2,1);			
				pc.addCols(" ",0,4);
				
				totDecimo += Double.parseDouble(cdo.getColValue("sal_bruto"));
			}
			
			totDecimo = totDecimo + salRegApagar;
			
			pc.addCols(" ",0,3);
			pc.addCols("--",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(""+salRegApagar),2,1);			
			pc.addCols(" ",0,4);

			pc.setFont(9,1);
			pc.addCols(" ",0,3);
			pc.addCols("Total",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(""+totDecimo),2,1);			
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal((totDecimo/12))+" (XIII MES PROPORCIONAL)",1,4);
		}
		
		//PRIMA ANTIGUEDAD
		if (pPrima.equals("S")){
			
			double accumulado = 0.0, vPromedio = 0.0;
			String[] getPlaLiqPrimaAnt = {};
			gastoRepP = Double.parseDouble(gastoRep)/11.0;
			
			CommonDataObject cdoAc = SQLMgr.getData("select getPlaLiqPrimaAnt("+compania+", "+empId+", '"+egreso+"', '"+fechaIngreso+"', "+tsAnios+",'"+noEmpleado+"') as getPlaLiqPrimaAnt, nvl(round("+tsAnios+" *52+("+tsMeses+"*52)/12 + (("+tsDias+"/30)*52)/12,2),0.0000000000001) total_semanas from dual ");
			

			try{
				getPlaLiqPrimaAnt = (cdoAc.getColValue("getPlaLiqPrimaAnt")).split("\\|");
				accumulado = Double.parseDouble(getPlaLiqPrimaAnt[0]);
				totalSemanas = Double.parseDouble(cdoAc.getColValue("total_semanas"));
			}catch(Exception e){
			    accumulado = 0.0;
				e.printStackTrace();
			}
			
			accumulado = accumulado +vacProp+Double.parseDouble(vacVencSalario)+gastoRepP+Double.parseDouble(gastoRep)+Double.parseDouble(salAPagar)-Double.parseDouble(salAdescontar);
			
			vPromedio = accumulado / totalSemanas;
			System.out.println(":::::::::::::::::::::::::::::::::::::::::::vPromedio= "+vPromedio);
		
			pc.addCols(" ",0,dHeader.size());
			pc.setFont(8,1);
			pc.addCols(" ",0,3);
			pc.addBorderCols("PRIMA ANTIGUEDAD:",1,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(8,0);
			for (int i=0; i<alPrima.size();i++){
				cdo = (CommonDataObject)alPrima.get(i);
				
				pc.addCols(" ",0,3);
				pc.addCols(cdo.getColValue("anio"),0,2);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("sal_bruto")),2,1);			
				pc.addCols(" ",0,4);
				
				totPrima += Double.parseDouble(cdo.getColValue("sal_bruto"));
			}
			pc.addCols(" ",0,3);
			pc.addCols("Vacciones Proporcionales",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(""+vacProp),2,1);			
			pc.addCols(" ",0,4);
			
			totPrima += vacProp;
			
			pc.setFont(8,0);
			pc.addCols(" ",0,3);
			pc.addCols("Total",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(""+totPrima),2,1);			
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+accumulado),1,1);
			pc.addCols(tsAnios,1,1);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+(vPromedio*Double.parseDouble(tsAnios))),1,1);
			pc.addCols("",1,1);
			
			pc.addCols(" ",0,6);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+totalSemanas),1,1);
			pc.addCols(tsMeses,1,1);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+(vPromedio*Double.parseDouble(tsMeses)/12)),1,1);
			pc.addCols("",1,1);
			
			pc.addCols(" ",0,6);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+vPromedio),1,1);
			pc.addCols(tsDias,1,1);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+( (vPromedio/12)/30)*Double.parseDouble(tsDias) ),1,1);
			pc.addCols("",1,1);
			
			prima = ( (vPromedio*Double.parseDouble(tsAnios)) +(vPromedio*Double.parseDouble(tsMeses)/12) + ((vPromedio/12)/30)*Double.parseDouble(tsDias));
			
			pc.setFont(8,1);
			pc.addCols("(PRIMA DE ANTIGUEDAD):",2,8);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+prima),1,1);
			pc.addCols("",1,1);
		}
		
		if (pIndemn.equals("N")){
		    String idenmData = request.getParameter("idenmData")==null?"":"";
			String[] _idenmData = {};
			double inSalUlt6Meses = 0.0, inPromedioSem = 0.0;
			
			if (!idenmData.trim().equals("")){
				try{
					_idenmData = idenmData.split("\\|");
					inSalUlt6Meses = Double.parseDouble(_idenmData[2]);
					inPromedioSem = Double.parseDouble(_idenmData[1]);
					indemnizacion = Double.parseDouble(_idenmData[4]);
					
					if (Double.parseDouble(_idenmData[0])>Double.parseDouble(_idenmData[3])) preaviso = Double.parseDouble(_idenmData[0]);
					else preaviso= Double.parseDouble(_idenmData[3]);
	
				}catch(Exception e){
				}
			}
			
			pc.addCols(" ",0,dHeader.size());
			pc.setFont(8,1);
			pc.addCols(" ",0,3);
			pc.addBorderCols("INDEMNIZACION:",1,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,4);
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(8,0);
			pc.addCols("",0,3);
			pc.addCols("Promedio últimos 6 meses:",0,2);
			pc.setFont(8,1);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+inSalUlt6Meses),1,1);
			pc.setFont(8,0);
			pc.addCols("Tot Semanas",1,1);
			pc.addCols("",1,3);
			
			pc.addCols("",0,3);
			pc.addCols("Promedio Semanal:",0,2);
			pc.setFont(8,1);
			pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+inPromedioSem),1,1);
			pc.setFont(8,0);
			pc.addCols(""+CmnMgr.getFormattedDecimal(""+totalSemanas),1,1);
			pc.setFont(7,1);
			pc.addCols("Indemnización",0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(""+indemnizacion),1,1);
			pc.addCols("",0,1);
			
			pc.addCols(" ",0,3);
			pc.addBorderCols("PREAVISO:",0,5,0.0f,0.0f,0.0f,0.0f);
			
			pc.addCols(CmnMgr.getFormattedDecimal(""+preaviso),1,1);
			pc.addCols("",0,1);
		}
		
		double salarioApagar = Double.parseDouble(rataHora)*Double.parseDouble(diasLaborados);
		double salarioApagarGr = Double.parseDouble(rataHoraGr)*Double.parseDouble(diasLaborados);
		double salarioLiq = salarioApagar + Double.parseDouble(salAPagar) - Double.parseDouble(trPaTrxBon) - Double.parseDouble(salAdescontar);
				
		double pAcumXiiiSal = Double.parseDouble(xiiiAcumSalario) + salarioLiq + Double.parseDouble(cdoVac.getColValue("sal_bruto")==null?"0":cdoVac.getColValue("sal_bruto"));
		
		double xiiiSalario = pAcumXiiiSal + Double.parseDouble(vacPropSalario) + Double.parseDouble(vacSalario);
		double xiiiSalarioGrep = Double.parseDouble(xiiiAcumGrep) + salarioApagarGr + Double.parseDouble(vacGasto)+Double.parseDouble(xiiiAcumGrep);
				
		CommonDataObject cdoT = SQLMgr.getData("select getPlaLiqImpuestos("+compania+","+empId+","+salAdescontar+","+prima+","+preaviso+","+salarioApagar+","+salarioApagarGr+","+salAPagar+","+trPaSt+","+vacSalario+","+vacGasto+","+vacPropSalario+","+vacPropGasto+","+(xiiiSalario/12)+","+(xiiiSalarioGrep/12)+","+indemnizacion+","+preaviso+","+otBeneficiosValor+",null"+",'"+egreso+"'"+","+tsAnios+",(select tipo_renta from tbl_pla_empleado where emp_id="+empId+")"+",(select num_dependiente from tbl_pla_empleado where emp_id="+empId+")"+","+trPaTrxBon+") as totLiq from dual");
		
		double totLiq = 0.0, impSobreLaRenta=0.0, impSeguroSocial=0, impSeguroEducativo=0, totNetApagar=0;

		try{
		   String _totLiq[] = (cdoT.getColValue("totLiq")).split("\\|");
		  totLiq = Double.parseDouble(_totLiq[1]);
		  impSobreLaRenta = Double.parseDouble(_totLiq[10]);
		  impSeguroSocial = Double.parseDouble(_totLiq[3]);
		  impSeguroEducativo = Double.parseDouble(_totLiq[5]);
		  totNetApagar = totLiq - impSobreLaRenta - impSeguroEducativo - impSeguroSocial;
		}catch(Exception e){
		  e.printStackTrace();
		}
		
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("TOTAL BRUTO DE LIQUIDACION:",2,8);
		pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+totLiq),1,1);
		pc.addCols("",0,1);
		
		pc.setFont(8,0);
		pc.addCols("Impuesto sobre la renta:",2,8);
		pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+impSobreLaRenta),1,1);
		pc.addCols("",0,1);
		
		pc.addCols("Seguro Social:",2,8);
		pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+impSeguroSocial),1,1);
		pc.addCols("",0,1);
		
		pc.addCols("Seguro Educativo:",2,8);
		pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+impSeguroEducativo),1,1);
		pc.addCols("",0,1);
		
		pc.setFont(8,1);
		pc.addCols("NETO A RECIBIR:",2,8);
		pc.addCols("B/. "+CmnMgr.getFormattedDecimal(""+totNetApagar),1,1);
		pc.addCols("",0,1);
		
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>