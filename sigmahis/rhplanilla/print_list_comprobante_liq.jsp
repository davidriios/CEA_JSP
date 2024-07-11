<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" /> 
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR 
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();
Company com= new Company ();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String empId = request.getParameter("empId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id");  
String compania = (String) session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
 
if (appendFilter == null) appendFilter = "";

sql = "SELECT a.emp_id, TO_CHAR(a.fecha_egreso,'dd/mm/yyyy') egreso, TO_CHAR(a.fecha_docto,'dd/mm/yyyy') fecha, a.motivo, c.descripcion AS motivoDesc, a.periodo_pago, a.anio_pago, a.ts_anios, a.ts_meses, a.ts_dias, TO_CHAR (a.dl_desde,'dd/mm/yyyy') desdeTrx , tO_CHAR(a.dl_hasta,'dd/mm/yyyy') hastaTrx, a.dl_dias_laborados, a.dl_thoras_regulares, a.vac_venc_dias, nvl(a.vac_venc_salario,0) vac_venc_salario,round((nvl(a.vac_venc_salario,0) * p.seg_soc_emp) / 100,2) as ssocial_vac_venc, round((nvl(a.vac_venc_salario,0) * p.seg_edu_emp) / 100,2) as seduc_vac_venc,round((nvl(a.vac_venc_gasto,0) * p.seg_soc_emp) / 100,2) as ssocial_vacVencGr, round((nvl(a.vac_venc_gasto,0) * p.seg_edu_emp) / 100,2) as seduc_vacVencGr,nvl(a.vac_venc_gasto,0) vac_venc_gasto, a.vac_prop_periodos, nvl(a.vac_prop_salario,0) vac_prop_salario,  round((nvl(a.vac_venc_salario,0) * p.seg_soc_emp) / 100+(nvl(a.vac_prop_salario,0) * p.seg_soc_emp) / 100,2) as ssocial_vacprop, round((nvl(a.vac_venc_salario,0) * p.seg_edu_emp) / 100+(nvl(a.vac_prop_salario,0) * p.seg_edu_emp) / 100,2) as seduc_vacprop, nvl(a.vac_prop_gasto,0)  vac_prop_gasto, round((nvl(a.vac_prop_gasto,0) * p.seg_soc_emp) / 100,2) as ssocial_vacpropGr, round((nvl(a.vac_prop_gasto,0) * p.seg_edu_emp) / 100,2) as seduc_vacpropGr, nvl(a.xiii_prop_salario,0) xiii_prop_salario, nvl(a.xiii_prop_gasto,0) xiii_prop_gasto, (nvl(a.xiii_prop_gasto,0) * p.ssoc_xiiim_gasto_emp) / 100 as ssocial_xiii_prop_gasto, round((nvl(a.xiii_prop_salario,0) * p.ssoc_xiiim_emp) / 100,2) as ssoc_xiii_prop_salario, a.prm_acumulado, a.prm_promedio_sem, a.prm_anios, nvl(a.prm_anios_valor,0) prm_anios_valor, nvl(a.prm_meses,0) prm_meses, nvl(a.prm_meses_valor,0) prm_meses_valor, a.prm_dias, nvl(a.prm_dias_valor,0) prm_dias_valor, nvl(a.prm_anios_valor,0) + nvl(a.prm_meses_valor,0) + nvl(a.prm_dias_valor,0) as prima_antiguedad, nvl(a.ind_salario_ult6m,0) ind_salario_ult6m, nvl(a.ind_salario_ultmes,0) ind_salario_ultmes, a.ind_promedio_sem, a.ind_promedio_mes, nvl(a.ind_valor,0) ind_valor, a.recibe_preaviso, nvl(a.preaviso_valor,0) preaviso_valor, nvl(a.ot_beneficios_valor,0) ot_beneficios_valor, nvl(a.imp_ssocial,0) imp_ssocial, nvl(a.imp_seducat,0) imp_seducat, nvl(a.imp_renta_sv,0) imp_renta_sv, nvl(a.imp_renta_ip,0) imp_renta_ip, a.cxc_empleado, a.imp_periodos, a.prm_semanas, a.desc_preaviso, nvl(a.desc_preaviso_valor,0) desc_preaviso_valor, nvl(a.cxc_clinica,0) cxc_clinica, a.estado, a.dl_thoras_regulares, (nvl(a.dl_thoras_regulares,0) * nvl(a.rata_hora,0)) as ingresoTrx, round((nvl(a.dl_thoras_regulares,0) * nvl(a.rata_hora,0) * p.seg_soc_emp) / 100,2) as ssocial_trx, round((nvl(a.dl_thoras_regulares,0) * nvl(a.rata_hora,0) * p.seg_edu_emp) / 100,2) as seduc_trx, a.forma_pago, a.num_cheque, TO_CHAR(a.fecha_cheque,'dd/mm/yyyy') fechaCk, TO_CHAR(a.fecha_ingreso,'dd/mm/yyyy') fechaIngreso, nvl(a.xiii_acum_salario,0) xiii_acum_salario, nvl(a.xiii_acum_grep,0) xiii_acum_grep, a.observacion, a.ajuste_creado, nvl(a.salario_base,0) AS salarioMensual, nvl(b.GASTO_REP,0) AS gastoRep, nvl(a.rata_hora,0) AS rataHora, nvl(a.desc_preaviso_valor,0) desc_preaviso_valor, decode(desc_preaviso,'N','N','S') pagar_preaviso, c.PAGAR_INDEMN, c.PAGAR_PANTIG, c.PAGAR_VACACION, c.PAGAR_XIII_MES, c.pagar_recargo25, c.pagar_recargo50, 'Periodo  Quincenal del '||TO_CHAR(a.fecha_ingreso,'dd/mm/yyyy')||' al '||TO_CHAR(a.fecha_egreso,'dd-mm-yyyy') AS periodoTrab, a.unidad_organi, e.descripcion AS unidadDesc, f.denominacion AS cargoDesc, NVL(a.ts_anios,0)||'a '||NVL(a.ts_meses,0)||'m '||NVL(a.ts_dias,0)||'d' AS antiguedad, b.cedula1 cedula, b.num_ssocial, b.nombre_empleado nomEmpleado, b.num_empleado numEmpleado, nvl(a.ind_recargo25,0) ind_recargo25, p.seg_soc_emp, p.seg_edu_emp, DECODE(c.pagar_recargo50,'S',NVL(a.ind_valor,0)*50/100,'0.00') ind_recargo50 FROM TBL_PLA_LI_LIQUIDACION a, vw_pla_empleado b, TBL_PLA_LI_MOTIVO c, TBL_SEC_UNIDAD_EJEC e, TBL_PLA_CARGO f, tbl_pla_parametros p WHERE a.emp_id = b.emp_id AND a.compania = b.compania AND a.motivo = c.CODIGO AND a.compania = c.compania AND b.UBIC_SECCION = e.CODIGO AND b.compania = e.COMPANIA AND b.CARGO = f.CODIGO AND b.compania = f.COMPANIA and e.compania = p.cod_compania AND a.emp_id="+empId+" AND a.anio_pago = "+anio+" and a.periodo_pago = "+num+" AND a.compania="+(String) session.getAttribute("_companyId");
al = SQLMgr.getDataList(sql);

System.err.println(sql);

sql = "select decode(accion,'DS',sum(monto),'DV',sum(monto*-1)) montoDesc from tbl_pla_aus_y_tard where emp_id = "+empId+" and anio_des = "+anio+" and quincena_des = "+num+" and estado_des = 'PE' and cod_planilla_des = 8 and accion <> 'ND' and compania="+(String) session.getAttribute("_companyId")+" group by accion";
	alDesc = SQLMgr.getDataList(sql);
	System.err.println(sql);


sql= "select nvl(sum(a.monto),0) montoExtra,  nvl(c.bonificacion,0) bonificacion, nvl(d.montoTrx,0) montoTrx from TBL_PLA_T_EXTRAORDINARIO a,  (SELECT SUM(NVL(monto,0)) bonificacion FROM TBL_PLA_T_EXTRAORDINARIO WHERE estado_pag = 'PE' AND cod_planilla_pag = 8 and quincena_pag = "+num+" and anio_pag = "+anio+" AND compania = "+(String) session.getAttribute("_companyId")+" AND emp_id = "+empId+" AND the_codigo = 30 ) c , (SELECT SUM(NVL(monto,0)) montoTrx FROM TBL_PLA_TRANSAC_EMP WHERE estado_pago = 'PE' AND cod_planilla_pago = 8 AND compania = "+(String) session.getAttribute("_companyId")+" AND emp_id = "+empId+" and quincena_pago = "+num+" and anio_pago = "+anio+" ) d WHERE a.emp_id = "+empId+" AND a.anio_pag = "+anio+" and a.quincena_pag = "+num+" AND a.estado_pag = 'PE' AND a.cod_planilla_pag = 8 AND a.compania= "+(String) session.getAttribute("_companyId")+" group by c.bonificacion, d.montoTrx";

	alExtra = SQLMgr.getDataList(sql);
	System.err.println(sql);



if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 30; //max lines of items
		int nItems = al.size(); //number of items
		System.out.print("\n\n Items "+nItems+"\n\n");
		int extraItems = nItems % maxLines;
		System.out.print("\n\n extraItems "+extraItems+"\n\n");
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page
		
		//****************************************************
		// Calcular el número de páginas que tendrá el reporte
		//****************************************************
		if (extraItems == 0)
		   nPages = (nItems / maxLines);
			//System.out.print("\n\n nPages "+nPages+"\n\n");
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;
		String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;
	
		String folderName = "rhplanilla";  
		String fileNamePrefix = "print_list_comprobante_liq";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = null;
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

		String day=fecha.substring(0, 2);
		//System.out.println("Year is: "+year+" Month is: "+month+" Day is: "+day);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		
					
			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
			
			int headerFooterFont = 4;
			int width = 612;
			int height = 792;
			boolean isLandscape = false;
			StringBuffer sbFooter = new StringBuffer();
				
			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;
						
				
			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

			
	//Verificar
		int no = 0;				
		int lCounter = 0;
		int pCounter = 1;
		float cHeight = 14.0f;
		
		double 	totTrExtra = 0.00;
	double  seg_soc = 0.00, seg_edu = 0.00;
	int 	contExtra = 0;
	int 	contDesc = 0;
	double 	totNeto = 0.00, totNetoTrx = 0.00;	
	double 	totNetoTrxGr = 0.00, totNetoVac = 0.00;	
	double 	totNetoVacGr = 0.00, totNetoXm = 0.00;
	double 	totNetoPr = 0.00, totNetoXmGr = 0.00;
	double 	totNetoPrGr = 0.00, totNetoPant = 0.00;
	double 	totNetoInd = 0.00, totNetoInd25 = 0.00;
	double 	totNetoPra = 0.00, totNetoIsrEsp = 0.00;
	
	double 	totNetoIng = 0.00, totNetoSsocial = 0.00;
	double 	totNetoSeduc = 0.00, totNetoIsr = 0.00;
	double  totNetoPagar = 0.00;
	double totDesc = 0.00 , totPreDesc = 0.00;
	double totExtra = 0.00 ,  totBoni = 0.00,totNetoVacGrVenc=0.00;
		
		for (int j=1; j<=nPages; j++)
{
			Vector setHeader0=new Vector();
					   setHeader0.addElement(".2");
					   setHeader0.addElement(".8");
					   setHeader0.addElement(".2");
			
				Vector setHeader2=new Vector();
					setHeader2.addElement(".25");
					setHeader2.addElement(".10");	
					setHeader2.addElement(".15");
					setHeader2.addElement(".15");
					setHeader2.addElement(".05");
					setHeader2.addElement(".20");
					setHeader2.addElement(".10");										
		
																														
				if (al.size()==0) {
						pc.createTable();
							pc.addCols("No existe el código seleccionado",1,5);
						pc.addTable();

						}
				else{
					if (al.size() > 0)
					{
						//for(int i=0;i<maxLines;i++)
						for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
						{
						 CommonDataObject			cdo1 = (CommonDataObject) al.get(i);
	 
							no += 1;			
					pc.setNoColumnFixWidth(setHeader0);

				pc.createTable();
					pc.setFont(8, 1);					
					pc.addCols(" ", 0,3);
				pc.addTable();
										
				Vector setHeader3 = new Vector();
				setHeader3.addElement(".1000");
				pc.setNoColumnFixWidth(setHeader3);
										
				pc.createTable();
					pc.setFont(12, 0);
					pc.addImageCols(""+logoPath,30.0f,1);
				pc.addTable();
				
				pc.createTable();
					pc.setFont(12, 0);
						pc.addCols(""+_comp.getNombre(),1, 1);
				pc.addTable();
							
	
				pc.createTable();
					pc.setFont(9, 0);					
					pc.addCols("PLANILLA DE LIQUIDACIONES", 1,7);
				pc.addTable();
					
				pc.createTable();
					pc.setFont(9, 0);					
					pc.addCols(" ", 0,1);
				pc.addTable();
				
					
					pc.setNoColumnFixWidth(setHeader2);			
				pc.createTable();
				pc.setFont(9, 0);
					pc.addCols(""+cdo1.getColValue("periodoTrab"),1,7);
				pc.addTable();	

						
								
				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	

				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	
				
				pc.createTable();
				pc.setFont(9, 0);
					pc.addCols(""+cdo1.getColValue("numEmpleado")+"    " +cdo1.getColValue("nomEmpleado"),0,1);
					pc.addCols(""+cdo1.getColValue("cargoDesc"),1,3);
					pc.addCols(" Ced.:"+cdo1.getColValue("cedula"),1,3);
				pc.addTable();	
										
				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	
														
				pc.createTable();	
					pc.addCols("     Fecha de Entrada : "+cdo1.getColValue("fechaIngreso"),0,2);
					pc.addCols(" ",1,2);													
					pc.addCols("Sueldo Mensual :",0,2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("salarioMensual")),2,1);
				pc.addTable();	
							
				pc.createTable();	
					pc.addCols("     Terminación a la fecha : "+cdo1.getColValue("egreso"),0,2);
					pc.addCols(" ",1,2);													
					pc.addCols("Gasto de Representación:",0,2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("gastoRep")),2,1);
				pc.addTable();	
								
				pc.createTable();	
					pc.addCols("     Antiguedad : "+cdo1.getColValue("antiguedad"),0,2);
					pc.addCols(" ",1,2);													
					pc.addCols("Ingreso Base :",0,2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("salarioMensual")),2,1);
				pc.addTable();	
					
				pc.createTable();	
					pc.addCols(" ",1,4);													
					pc.addCols("Tarifa x Hora :",0,2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("rataHora")),2,1);
				pc.addTable();	
					
										
				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	


		
				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	
				
				pc.createTable();
					pc.setFont(9, 1);					
					pc.addCols("  ---  CAUSAL ----------", 0,4);
					pc.addCols("  ---  LIQUIDAR ----------", 1,3);
				pc.addTable();

				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	


				pc.createTable();
					pc.setFont(9, 2);					
					pc.addCols("  "+cdo1.getColValue("motivoDesc"), 0, 4);
					pc.setFont(8, 0);
					pc.addBorderCols(" "+cdo1.getColValue("PAGAR_VACACION"), 1,1);
					pc.addCols("  Vacaciones ", 0,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(8, 0);					
					pc.addCols("  ", 0,4);
					pc.addBorderCols(" "+cdo1.getColValue("PAGAR_XIII_MES"), 1,1);
					pc.addCols("  XIII Mes ", 0,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(8, 0);					
					pc.addCols("  ", 0,4);
					pc.addBorderCols(" "+cdo1.getColValue("pagar_preaviso"), 1,1);
					pc.addCols("  Preaviso ", 0,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(8, 0);					
					pc.addCols("  ", 0,4);
					pc.addBorderCols(" "+cdo1.getColValue("PAGAR_PANTIG"), 1,1);
					pc.addCols("  Prima de Antiguedad ", 0,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(8, 0);					
					pc.addCols("  ", 0,4);
					pc.addBorderCols(" "+cdo1.getColValue("PAGAR_INDEMN"), 1,1);
					pc.addCols("  Indemnización ", 0,2);
				pc.addTable();
			
				pc.createTable();
					pc.setFont(8, 0);					
					pc.addCols("  ", 0,4);
					pc.addBorderCols(" "+cdo1.getColValue("pagar_recargo25"), 1,1);
					pc.addCols("  Recargo 25% sobre Indemnización ", 0,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(8, 0);					
					pc.addCols("  ", 0,4);
					pc.addBorderCols(" "+cdo1.getColValue("pagar_recargo50"), 1,1);
					pc.addCols("  Recargo 50% sobre Indemnización ", 0,2);
				pc.addTable();

				pc.createTable();	
					pc.addCols("  ",0,7);
				pc.addTable();	


				pc.createTable();
				pc.setFont(9, 0);
					pc.addBorderCols("* * * * / R E S U M E N /  * * * * ",1,7);													
				pc.addTable();
				
				for (int k=0; k<alDesc.size(); k++)
				{
				
				CommonDataObject cdo3 = (CommonDataObject) alDesc.get(k);
				totDesc = Double.parseDouble(cdo3.getColValue("montoDesc").replace(",",""));
				}
			
			
			for (int h=0; h<alExtra.size(); h++)
				{
				
				CommonDataObject cdo4 = (CommonDataObject) alExtra.get(h);
				totExtra = Double.parseDouble(cdo4.getColValue("montoExtra").replace(",","")) +
					Double.parseDouble(cdo4.getColValue("montoTrx").replace(",",""));
				totBoni = Double.parseDouble(cdo4.getColValue("bonificacion").replace(",",""));
				}
   
   				pc.createTable();
				pc.setFont(9, 0);
					pc.addBorderCols("Detalle",1,1);
					pc.addBorderCols("Ingresos",1,1);
					pc.addBorderCols("Impuesto S/Renta",1,1);
					pc.addBorderCols("Seguro Social",1,2);
					pc.addBorderCols("Seguro Educativo",1,1);
					pc.addBorderCols("Neto a Pagar",1,1);
				pc.addTable();
				
				totTrExtra = Double.parseDouble(cdo1.getColValue("ingresoTrx").replace(",","")) + totExtra - totDesc;
				seg_soc = (totTrExtra * Double.parseDouble(cdo1.getColValue("seg_soc_emp").replace(",","")))/ 100;
				seg_edu = ((totTrExtra - totBoni) * Double.parseDouble(cdo1.getColValue("seg_edu_emp").replace(",",""))) / 100;
				totNeto = Double.parseDouble(cdo1.getColValue("ingresoTrx").replace(",","")) + totExtra - totDesc - seg_soc - seg_edu;
						
					pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Ingreso Pendiente",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totTrExtra),2,1);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(seg_soc),2,2);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(seg_edu),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNeto),2,1);
				pc.addTable();


				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Ingreso Pendiente x Gtos. Rep.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("gastoRep")),2,1);
					pc.addBorderCols("",1,1);
					pc.addBorderCols("",1,2);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("gastoRep")),2,1);
				pc.addTable();

				totNetoVac = Double.parseDouble(cdo1.getColValue("vac_prop_salario").replace(",",""))+Double.parseDouble(cdo1.getColValue("vac_venc_salario").replace(",",""))- 
				Double.parseDouble(cdo1.getColValue("imp_renta_sv").replace(",","")) -	
				Double.parseDouble(cdo1.getColValue("ssocial_vacprop").replace(",","")) - Double.parseDouble(cdo1.getColValue("seduc_vacprop").replace(",",""));
				
			    pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Vacaciones",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("vac_prop_salario")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("imp_renta_sv")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ssocial_vacprop")),2,2);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("seduc_vacprop")),2,1);
					//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoVac),2,1);
					pc.addBorderCols(" ",2,1);
				pc.addTable();
				
				 pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Vacaciones Vencidas",0,1);
					
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("vac_venc_salario")),2,1);
					pc.addBorderCols(" ",2,4);
					//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("imp_renta_sv")),2,1);
					//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ssocial_vacprop")),2,2);
					//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("seduc_vacprop")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoVac),2,1);
				pc.addTable();
		
		totNetoVacGrVenc = Double.parseDouble(cdo1.getColValue("vac_venc_gasto").replace(",","")) - Double.parseDouble(cdo1.getColValue("ssocial_vacVencGr").replace(",","")) - Double.parseDouble(cdo1.getColValue("seduc_vacVencGr").replace(",",""));
		
				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Vacaciones Venc. x Gastos Rep.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("vac_venc_gasto")),2,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ssocial_vacVencGr")),2,2);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("seduc_vacVencGr")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoVacGrVenc),2,1);
					//pc.addBorderCols(" ",2,1);
				pc.addTable();
				

				totNetoVacGr = Double.parseDouble(cdo1.getColValue("vac_prop_gasto").replace(",","")) - Double.parseDouble(cdo1.getColValue("ssocial_vacpropGr").replace(",","")) - Double.parseDouble(cdo1.getColValue("seduc_vacpropGr").replace(",",""));
				
			    pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Vacaciones x Gastos Rep.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("vac_prop_gasto")),2,1);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ssocial_vacpropGr")),2,2);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("seduc_vacpropGr")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoVacGr),2,1);
				pc.addTable();


				totNetoXm = Double.parseDouble(cdo1.getColValue("xiii_prop_salario").replace(",","")) - Double.parseDouble(cdo1.getColValue("ssoc_xiii_prop_salario").replace(",",""));
				
			    pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Décimo Tercer Mes ",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("xiii_prop_salario")),2,1);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ssoc_xiii_prop_salario")),2,2);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoXm),2,1);
				pc.addTable();

	  
				totNetoXmGr = Double.parseDouble(cdo1.getColValue("xiii_prop_gasto").replace(",","")) - Double.parseDouble(cdo1.getColValue("ssocial_xiii_prop_gasto").replace(",",""));
				
			    pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("Décimo Tercer Mes x Gtos. Rep.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("xiii_prop_gasto")),2,1);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ssocial_xiii_prop_gasto")),2,2);
					pc.addBorderCols("",1,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoXmGr),2,1);
				pc.addTable();


	  
			    pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Preaviso.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("preaviso_valor")),2,1);
					pc.addBorderCols("",1,4);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("preaviso_valor")),2,1);
				pc.addTable();

				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Preaviso x Gasto de Rep.",0,1);
					pc.addBorderCols("",1,1);
					pc.addBorderCols("",1,4);
					pc.addBorderCols("",1,1);
				pc.addTable();

				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Prima de Antiguedad.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("prima_antiguedad")),2,1);
					pc.addBorderCols("",1,4);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("prima_antiguedad")),2,1);
				pc.addTable();


				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Indemnización.",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ind_valor")),2,1);
					pc.addBorderCols("",1,4);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ind_valor")),2,1);
				pc.addTable();

				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Indemnización.(Recargo 25%)",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ind_recargo25")),2,1);
					pc.addBorderCols("",1,4);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ind_recargo25")),2,1);
				pc.addTable();
				
					pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Indemnización.(Recargo 50%)",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ind_recargo50")),2,1);					pc.addBorderCols("",1,4);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("ind_recargo50")),2,1);
				pc.addTable();

				
				if(!cdo1.getColValue("desc_preaviso_valor").equals("0"))
				totPreDesc = Double.parseDouble(cdo1.getColValue("desc_preaviso_valor").replace(",","")) * -1 ;
				else totPreDesc = Double.parseDouble(cdo1.getColValue("desc_preaviso_valor").replace(",",""));


				pc.createTable();
				pc.setFont(8, 0);
					pc.addBorderCols("* Preaviso (Desc).",0,1);
					pc.addBorderCols(""+totPreDesc,2,1);
					pc.addBorderCols("",1,4);
					pc.addBorderCols(""+totPreDesc,2,1);
				pc.addTable();

			
				pc.createTable();	
				pc.setFont(9, 0);
					pc.addCols(" ",2,7);
			 pc.addTable();	


	totNetoIng = totTrExtra + Double.parseDouble(cdo1.getColValue("vac_prop_salario").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("vac_prop_gasto").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("xiii_prop_salario").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("xiii_prop_gasto").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("preaviso_valor").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("prima_antiguedad").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ind_valor").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ind_recargo25").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ind_recargo50").replace(",","")) +
	totPreDesc+Double.parseDouble(cdo1.getColValue("vac_venc_salario").replace(",",""))+Double.parseDouble(cdo1.getColValue("vac_venc_gasto").replace(",",""));

	totNetoIsr = Double.parseDouble(cdo1.getColValue("imp_renta_sv").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("imp_renta_ip").replace(",","")) ;

    totNetoSsocial = seg_soc + Double.parseDouble(cdo1.getColValue("ssocial_vacprop").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ssocial_vacpropGr").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ssoc_xiii_prop_salario").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ssocial_xiii_prop_gasto").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("ssocial_vacVencGr").replace(",",""));
	
	totNetoSeduc = seg_edu + Double.parseDouble(cdo1.getColValue("seduc_vacprop").replace(",","")) +
	Double.parseDouble(cdo1.getColValue("seduc_vacpropGr").replace(",",""))+Double.parseDouble(cdo1.getColValue("seduc_vacVencGr").replace(",","")) ;

	
		totNetoPagar = totNetoIng - totNetoIsr - totNetoSsocial - totNetoSeduc;

			 
				pc.createTable();	
				pc.setFont(9, 0);
					pc.addCols("TOTALES ",0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoIng),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoIsr),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoSsocial),2,2);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoSeduc),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totNetoPagar),2,1);
			 pc.addTable();	

			pc.createTable();	
				pc.setFont(9, 0);
					pc.addCols(" ",2,7);
			 pc.addTable();	
			 
		 	pc.createTable();	
					pc.addCols("  ",0,7);
			pc.addTable();	

			pc.createTable();	
					pc.addCols("  ",0,7);
			pc.addTable();
			 
			pc.createTable();	
				pc.setFont(9, 0);
					pc.addCols("Elaborado por : ____________________________________ ",0,3);
					pc.addCols("Aprobado por : __________________________________",2,3);
					pc.addCols("",2,1);
			 pc.addTable();	
										
							if ((i + 1) == nItems) break;
						}//End For
						}//End If
						if((no+2)<=maxLines){
				}else{
					pc.addNewPage();
				}
				}
			}//End For
			pc.close();
				response.sendRedirect(redirectFile);
				}
				%>
				