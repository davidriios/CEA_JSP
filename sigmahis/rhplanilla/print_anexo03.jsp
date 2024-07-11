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
/**
==================================================================================
PLANILLA: anexo03.rdf
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
StringBuffer sql = new StringBuffer();

String anio = request.getParameter("anio");
String subTitle = "";
String empId = request.getParameter("empId");
String noEmpleado = request.getParameter("noEmpleado");
String salario = request.getParameter("salario");
String fisco = request.getParameter("fisco");
if (empId == null) empId = "";
if (noEmpleado == null) noEmpleado = "";
if (anio == null || anio.equals("")) throw new Exception("El año no es válido!");
if (salario == null) salario = "";
if (fisco == null) fisco = "";
//sql = "SELECT CEDULA, DV, NOMBRE_EMP, TIPO_RENTA, NUM_DEPENDIENTE, CASE WHEN ROUND(NVL(PERIODOS,0)/2,0) > 12 THEN 12 WHEN ROUND(NVL(PERIODOS,0)/2,0)  = 0 THEN 1 ELSE ROUND(NVL(PERIODOS,0)/2,0) END V_MES1, periodos, NVL(SAL_BRUTO,0)+NVL(G_REPRESENTACION,0) CF_INGRESOS_BRUTOS,  NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0) CF_DEDUC, SEG_EDUCATIVO, ( NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0)+ SEG_EDUCATIVO  ) CF_TOTAL_DEDUC,  CASE WHEN  ( (NVL(SAL_BRUTO,0)+NVL(G_REPRESENTACION,0) ) - ( NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0)+ SEG_EDUCATIVO  )  ) < 0 THEN 0 ELSE ((NVL(SAL_BRUTO,0)+NVL(G_REPRESENTACION,0) ) - ( NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0)+ SEG_EDUCATIVO  ) ) END CF_TOTAL_INGRESOS, IMP_RENTA, ISR, DECLARANTE  FROM (SELECT ALL DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)||RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||LPAD(TO_CHAR(E.ASIENTO),5,'0') CEDULA,  E.PRIMER_NOMBRE||' '|| DECODE(E.SEXO,'F',DECODE(E.APELLIDO_CASADA, NULL,E.PRIMER_APELLIDO, DECODE(E.USAR_APELLIDO_CASADA,'S','DE '||  E.APELLIDO_CASADA, E.PRIMER_APELLIDO)),E.PRIMER_APELLIDO) NOMBRE_EMP, DECODE(NVL(E.GASTO_REP,0),0,'N','S')  DECLARANTE, E.NUM_EMPLEADO, NVL(E.TIPO_RENTA,'A') TIPO_RENTA, NVL(E.NUM_DEPENDIENTE,0) NUM_DEPENDIENTE,DECODE(E.DIGITO_VERIFICADOR,NULL,'  ',RPAD(E.DIGITO_VERIFICADOR,2,'0')) DV, A.ANIO, E.FECHA_INGRESO,NVL(PA.VALOR_DEPENDIENTE,0) VALOR_DEPENDIENTE,NVL(PA.GR_PORC_NO_RENTA,0) GR_PORC_NO_RENTA, NVL(PA.GR_LIMITE_NO_RENTA,0) GR_LIMITE_NO_RENTA,  NVL(CR.PAGO_BASE,0) V_DED_BASE,  calcular_isr(E.TIPO_RENTA, E.NUM_DEPENDIENTE, E.SALARIO_BASE, E.COMPANIA) ISR , SUM((NVL(A.SAL_BRUTO,0)+ NVL(A.SALARIO_ESPECIE,0)+NVL(A.PRIMA_PRODUCCION,0) -NVL(A.INDEMNIZACION,0) -NVL(A.PRIMA_ANTIGUEDAD,0) -NVL(A.PREAVISO,0) ) ) SAL_BRUTO, SUM(  NVL(A.G_REPRESENTACION,0) )  G_REPRESENTACION, SUM( (NVL(A.SAL_BRUTO,0) +NVL(A.G_REPRESENTACION,0) -NVL(A.INDEMNIZACION,0) -NVL(A.PRIMA_ANTIGUEDAD,0) -NVL(A.PREAVISO,0) ) )  INGRESOS, SUM( NVL(A.IMP_RENTA,0) ) IMP_RENTA, SUM( NVL(A.SEG_EDUCATIVO,0) ) SEG_EDUCATIVO, SUM( NVL(A.PERIODOS,0) ) PERIODOS FROM TBL_PLA_PAGO_EMPLEADO P, TBL_PLA_EMPLEADO E, TBL_PLA_ACUMULADO_EMPLEADO A, TBL_PLA_PARAMETROS PA, TBL_PLA_CLAVE_RENTA CR WHERE P.ANIO = "+anio+" AND E.EMP_ID = P.EMP_ID AND P.COD_COMPANIA = E.COMPANIA AND A.COD_COMPANIA = P.COD_COMPANIA AND A.ANIO = P.ANIO AND A.EMP_ID = E.EMP_ID AND PA.COD_COMPANIA = E.COMPANIA AND E.COMPANIA = "+compania+"  AND CR.CLAVE = E.TIPO_RENTA GROUP BY DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)||RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||LPAD(TO_CHAR(E.ASIENTO),5,'0'), E.PRIMER_NOMBRE||' '|| DECODE(E.SEXO,'F',DECODE(E.APELLIDO_CASADA, NULL,E.PRIMER_APELLIDO, DECODE(E.USAR_APELLIDO_CASADA,'S','DE '||  E.APELLIDO_CASADA, E.PRIMER_APELLIDO)),E.PRIMER_APELLIDO), DECODE(NVL(E.GASTO_REP,0),0,'N','S'), E.NUM_EMPLEADO, NVL(E.TIPO_RENTA,'A'), NVL(E.NUM_DEPENDIENTE,0), DECODE(E.DIGITO_VERIFICADOR,NULL,'  ',RPAD(E.DIGITO_VERIFICADOR,2,'0')), A.ANIO, E.FECHA_INGRESO,NVL(PA.VALOR_DEPENDIENTE,0) ,NVL(PA.GR_PORC_NO_RENTA,0) , NVL(PA.GR_LIMITE_NO_RENTA,0),  NVL(CR.PAGO_BASE,0), calcular_isr(E.TIPO_RENTA, E.NUM_DEPENDIENTE, E.SALARIO_BASE, E.COMPANIA)  ORDER BY E.NUM_EMPLEADO ) X";
if (!fisco.trim().equals("")){sql.append(" select * from ( ");}
sql.append(" select z.*,case when round(nvl(z.periodos,0)/2,0) >12 then 12 when round(nvl(z.periodos,0)/2,0)  = 0 then 1 else round(nvl(z.periodos,0)/2,0) end v_periodos,z.sal_bruto + g_representacion total_ingresos,nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0) deducciones_dep,decode(sign((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))),-1,0,((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))) ) tot_ingresos,/*case when round(nvl(z.periodos,0)/2,0) >= 12 then */ getimpuestosisr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,decode(sign((z.sal_bruto)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))),-1,0,((z.sal_bruto)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))) ) ,'S','N')+ getimpuestosisr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,decode(sign((z.g_representacion)),-1,0,nvl(z.g_representacion,0)) ,'G','N') /*else 0 end*/ /* se comenta por que se agrega gasto rep case when round(nvl(z.periodos,0)/2,0) >= 12 then getimpuestosisr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,decode(sign((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))),-1,0,((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))) ) ,'S','N') else 0 end */ impuesto_causado from (select all  e.ubic_depto,e.ubic_seccion,decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0') cedula,e.nombre_empleado nombre_emp,decode(nvl(e.gasto_rep,0),0,'N','S')  declarante,nvl(e.tipo_renta,'A') tipo_renta, nvl(e.num_dependiente,0) num_dependiente,decode(e.digito_verificador,null,'  ',rpad(e.digito_verificador,2,'0')) dv,a.anio, e.fecha_ingreso,nvl(p.valor_dependiente,0) valor_dependiente,nvl(p.gr_porc_no_renta,0) gr_porc_no_renta, nvl(p.gr_limite_no_renta,0) gr_limite_no_renta,sum((nvl(a.sal_bruto,0)+ nvl(a.salario_especie,0)+nvl(a.prima_produccion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ) ) sal_bruto, sum(nvl(a.g_representacion,0))  g_representacion, sum((nvl(a.sal_bruto,0) +nvl(a.g_representacion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ))  ingresos,sum( nvl(a.imp_renta,0) ) imp_renta,0  seg_educativo, sum( nvl(a.periodos,0) ) periodos,nvl(cr.pago_base,0) pago_base from tbl_pla_acumulado_empleado a,vw_pla_empleado e, tbl_pla_parametros p, tbl_pla_temporal_emp te,tbl_pla_clave_renta cr where e.compania = ");
sql.append(compania);
sql.append(" and e.emp_id = a.emp_id and a.emp_id = te.emp_id and a.num_empleado = te.num_empleado and a.cod_compania = te.cod_compania and te.escoger = 'S' and e.compania =  a.cod_compania and p.cod_compania = e.compania and a.anio = ");
sql.append(anio);
if (!empId.trim().equals("")){sql.append(" and te.emp_id=");sql.append(empId);}
if (!noEmpleado.trim().equals("")){sql.append(" and te.num_empleado='");sql.append(noEmpleado);sql.append("'");}
sql.append(" and  a.sal_bruto > 0 and e.tipo_renta = cr.clave(+) group by e.ubic_depto,e.ubic_seccion,decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0'), e.nombre_empleado,decode(nvl(e.gasto_rep,0),0,'N','S'),nvl(e.tipo_renta,'A'), nvl(e.num_dependiente,0),decode(e.digito_verificador,null,'  ',rpad(e.digito_verificador,2,'0')),a.anio, e.fecha_ingreso,nvl(p.valor_dependiente,0),nvl(p.gr_porc_no_renta,0) ,nvl(p.gr_limite_no_renta,0),nvl(cr.pago_base,0) having sum((nvl(a.sal_bruto,0)+ nvl(a.salario_especie,0)+nvl(a.prima_produccion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ) ) +sum(  nvl(a.g_representacion,0) )  > 0 order by e.ubic_depto,e.ubic_seccion, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0'), e.nombre_empleado)z");

if (!salario.trim().equals("")){sql.append(" where  (nvl(z.sal_bruto,0) + nvl(z.g_representacion,0)) > 11000 ");}

if (!fisco.trim().equals("")){sql.append(" ) where (impuesto_causado <> imp_renta) ");} 


al = SQLMgr.getDataList(sql.toString());

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

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//1008
	boolean isLandscape = true;
	float leftRightMargin = 5.0f;
	float topMargin = 9.5f;
	float bottomMargin = 1.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "LISTA DE EMPLEADOS Y SUELDOS DEVENGADOS";
	String xtraSubtitle = "AÑO: "+anio ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".05");
	dHeader.addElement(".24");
	dHeader.addElement(".06");
	dHeader.addElement(".05");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	//dHeader.addElement(".10");
	//dHeader.addElement(".10");
	//dHeader.addElement(".10");
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	if ( al.size() == 0 ){
	    pc.setFont(8,1);
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols("****** NO EXISTEN REGISTROS! ******",1,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
	}else{
		
		double V_IMP_RENTA = 0.0;
		double V_VALOR_TABLA = 0.0;
		double V_VTABLA_RINICIAL = 0.0;
		double V_AJIMP_CAUSADO = 0.0; 
		double V_SALPROMEDIO = 0.0; 
		double V_EXENCION_LEY = 0.0;
		double V_FAVOR_FISCO = 0.0;
		double V_FAVOR_EMPL = 0.0;
		double V_COL25 = 0.0;
		double dif = 0.0;
		double tot_sal_bruto = 0.0, tot_ded_basica = 0.0, tot_seg_edu = 0.0,  tot_ded = 0.0, tot_renta_neta = 0.0, tot_imp_caus = 0.0, tot_aj_imp_caus = 0.0, tot_ext_61 = 0.0, tot_ret = 0.0, tot_aj_emp = 0.0, tot_fav_fisco = 0.0, tot_fav_emp = 0.0;
		
		CommonDataObject cdo2 = new CommonDataObject();
		
		pc.addBorderCols("CEDULA",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("DV",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("NOMBRE",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("GRUPO DEP.",10,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("PER",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("REMUNERACION  RECIBIDA",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("DED. BASICA DEPENDIENTES",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("SEGURO EDUCATIVO",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("TOTAL DE DEDUCCIONES",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("RENTA NETA GRAVABLE",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("IMPUESTO CAUSADO",2,1,1.5f,1.5f,0.0f,0.0f);
		//pc.addBorderCols("AJUSTE IMP. CAUSADO",2,1,1.5f,1.5f,0.0f,0.0f);
		//pc.addBorderCols("EXENCION LEY 61",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("RETENCIONES EN EL AÑO",2,1,1.5f,1.5f,0.0f,0.0f);
		//pc.addBorderCols("AJUSTE FAVOR EMP.",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("A FAVOR    FISCO",2,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("A FAVOR EMPLEADO",2,1,1.5f,1.5f,0.0f,0.0f);
	
	
		
		pc.setTableHeader(2);
		
		for ( int j = 0; j<al.size(); j++ ){
			cdo = (CommonDataObject) al.get(j);
			pc.addCols(""+cdo.getColValue("cedula"),0,1);
			pc.addCols(""+cdo.getColValue("dv"),1,1);
			pc.addCols(""+cdo.getColValue("nombre_emp"),0,1);
			pc.addCols(""+cdo.getColValue("tipo_renta"),1,1);
			pc.addCols(""+cdo.getColValue("v_periodos"),1,1);
			
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_ingresos")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("deducciones_dep")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("seg_educativo")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("deducciones_dep")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("tot_ingresos")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("impuesto_causado")),2,1); 
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("imp_renta")),2,1);
			
			V_IMP_RENTA = Double.parseDouble(cdo.getColValue("impuesto_causado"));
			V_COL25 = Double.parseDouble(cdo.getColValue("imp_renta"));
			
			dif = V_IMP_RENTA - V_COL25;
			//if (cdo.getColValue("declarante").equalsIgnoreCase("N"))
			//{
				if ( Integer.parseInt(cdo.getColValue("v_periodos")) >= 12 )
				{
					V_FAVOR_FISCO = V_IMP_RENTA - V_COL25;
					V_FAVOR_EMPL  =  V_COL25 - V_IMP_RENTA;
					
					if ( V_FAVOR_FISCO <= 0 )V_FAVOR_FISCO = 0.0;
					if (V_FAVOR_EMPL <= 0 )V_FAVOR_EMPL  = 0.0;
					
				}
				else 
				{
				    V_FAVOR_FISCO = V_IMP_RENTA - V_COL25;
					V_FAVOR_EMPL  =  V_COL25 - V_IMP_RENTA;
						/*if ( V_FAVOR_FISCO <= 0 ) 
						{
							V_FAVOR_FISCO = 0.0;
							V_FAVOR_EMPL  = 0.0;
						}*/
				}
			/*}
			else{V_FAVOR_FISCO = 0.0; V_FAVOR_EMPL  = 0.0;}*/
						
			//pc.addCols(""+CmnMgr.getFormattedDecimal(V_FAVOR_FISCO),2,1);//CF_FAVOR_FISCO
			//pc.addCols(""+CmnMgr.getFormattedDecimal(V_FAVOR_EMPL),2,1);//CF_FAVOR_EMPL
			
			if(dif > 0 )pc.addCols(""+CmnMgr.getFormattedDecimal(dif),2,1);
			else pc.addCols("0.00",2,1);
			
			if(dif < 0 )pc.addCols(""+CmnMgr.getFormattedDecimal(dif*-1),2,1);
			else pc.addCols("0.00",2,1);
			
		   tot_sal_bruto += Double.parseDouble(cdo.getColValue("total_ingresos"));
		   tot_ded_basica += Double.parseDouble(cdo.getColValue("deducciones_dep"));
		   tot_seg_edu += Double.parseDouble(cdo.getColValue("seg_educativo"));
		   tot_ded += Double.parseDouble(cdo.getColValue("deducciones_dep"));
		   tot_renta_neta += Double.parseDouble(cdo.getColValue("tot_ingresos"));
		   
		   tot_imp_caus += Double.parseDouble(cdo.getColValue("impuesto_causado"));
		   	   
		   tot_ret += Double.parseDouble(cdo.getColValue("IMP_RENTA"));
		   tot_fav_fisco += V_FAVOR_FISCO;
		   tot_fav_emp += V_FAVOR_EMPL;
		   
		   if ((j % 50 == 0) || ((j + 1) == al.size())) pc.flushTableBody(true);
			
		}//for j
		
		   pc.addCols(" ", 0, dHeader.size());
		   pc.setFont(8,1);
		   pc.addCols("T O T A L E S :",2,5);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_sal_bruto),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_ded_basica),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_seg_edu),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_ded),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_renta_neta),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_imp_caus),2,1,0.0f,1.0f,0.0f,0.0f);
		   //pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_aj_imp_caus),2,1,0.0f,1.0f,0.0f,0.0f);
		   //pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_ext_61),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_ret),2,1,0.0f,1.0f,0.0f,0.0f);
		   //pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_aj_emp),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_fav_fisco),2,1,0.0f,1.0f,0.0f,0.0f);
		   pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(tot_fav_emp),2,1,0.0f,1.0f,0.0f,0.0f);
		}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
