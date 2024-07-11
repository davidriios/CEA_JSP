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
PLANILLA: anexo03_descto.rdf
==================================================================================

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
String justificacion  = request.getParameter("justificacion");
String empId = request.getParameter("empId");
String noEmpleado = request.getParameter("noEmpleado");
if (empId == null) empId = "";
if (noEmpleado == null) noEmpleado = "";
if (anio == null || anio.equals("")) throw new Exception("El año no es válido!");
if (justificacion == null||justificacion=="null")justificacion="";
if (justificacion.trim().equals("")) justificacion="IMPUESTO SOBRE LA RENTA DEL "+anio; 

//sql = "SELECT CEDULA, DV, NOMBRE_EMP, TIPO_RENTA, NUM_DEPENDIENTE, CASE WHEN ROUND(NVL(PERIODOS,0)/2,0) > 12 THEN 12 WHEN ROUND(NVL(PERIODOS,0)/2,0)  = 0 THEN 1 ELSE ROUND(NVL(PERIODOS,0)/2,0) END V_MES1, periodos, NVL(SAL_BRUTO,0)+NVL(G_REPRESENTACION,0) CF_INGRESOS_BRUTOS,  NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0) CF_DEDUC, SEG_EDUCATIVO, ( NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0)+ SEG_EDUCATIVO  ) CF_TOTAL_DEDUC,  CASE WHEN  ( (NVL(SAL_BRUTO,0)+NVL(G_REPRESENTACION,0) ) - ( NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0)+ SEG_EDUCATIVO  )  ) < 0 THEN 0 ELSE ((NVL(SAL_BRUTO,0)+NVL(G_REPRESENTACION,0) ) - ( NVL(V_DED_BASE,0) + NVL(NUM_DEPENDIENTE,0) * NVL(VALOR_DEPENDIENTE,0)+ SEG_EDUCATIVO  ) ) END CF_TOTAL_INGRESOS, IMP_RENTA, ISR, DECLARANTE  FROM (SELECT ALL DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)||RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||LPAD(TO_CHAR(E.ASIENTO),5,'0') CEDULA,  E.PRIMER_NOMBRE||' '|| DECODE(E.SEXO,'F',DECODE(E.APELLIDO_CASADA, NULL,E.PRIMER_APELLIDO, DECODE(E.USAR_APELLIDO_CASADA,'S','DE '||  E.APELLIDO_CASADA, E.PRIMER_APELLIDO)),E.PRIMER_APELLIDO) NOMBRE_EMP, DECODE(NVL(E.GASTO_REP,0),0,'N','S')  DECLARANTE, E.NUM_EMPLEADO, NVL(E.TIPO_RENTA,'A') TIPO_RENTA, NVL(E.NUM_DEPENDIENTE,0) NUM_DEPENDIENTE,DECODE(E.DIGITO_VERIFICADOR,NULL,'  ',RPAD(E.DIGITO_VERIFICADOR,2,'0')) DV, A.ANIO, E.FECHA_INGRESO,NVL(PA.VALOR_DEPENDIENTE,0) VALOR_DEPENDIENTE,NVL(PA.GR_PORC_NO_RENTA,0) GR_PORC_NO_RENTA, NVL(PA.GR_LIMITE_NO_RENTA,0) GR_LIMITE_NO_RENTA,  NVL(CR.PAGO_BASE,0) V_DED_BASE,  calcular_isr(E.TIPO_RENTA, E.NUM_DEPENDIENTE, E.SALARIO_BASE, E.COMPANIA) ISR , SUM((NVL(A.SAL_BRUTO,0)+ NVL(A.SALARIO_ESPECIE,0)+NVL(A.PRIMA_PRODUCCION,0) -NVL(A.INDEMNIZACION,0) -NVL(A.PRIMA_ANTIGUEDAD,0) -NVL(A.PREAVISO,0) ) ) SAL_BRUTO, SUM(  NVL(A.G_REPRESENTACION,0) )  G_REPRESENTACION, SUM( (NVL(A.SAL_BRUTO,0) +NVL(A.G_REPRESENTACION,0) -NVL(A.INDEMNIZACION,0) -NVL(A.PRIMA_ANTIGUEDAD,0) -NVL(A.PREAVISO,0) ) )  INGRESOS, SUM( NVL(A.IMP_RENTA,0) ) IMP_RENTA, SUM( NVL(A.SEG_EDUCATIVO,0) ) SEG_EDUCATIVO, SUM( NVL(A.PERIODOS,0) ) PERIODOS FROM TBL_PLA_PAGO_EMPLEADO P, TBL_PLA_EMPLEADO E, TBL_PLA_ACUMULADO_EMPLEADO A, TBL_PLA_PARAMETROS PA, TBL_PLA_CLAVE_RENTA CR WHERE P.ANIO = "+anio+" AND E.EMP_ID = P.EMP_ID AND P.COD_COMPANIA = E.COMPANIA AND A.COD_COMPANIA = P.COD_COMPANIA AND A.ANIO = P.ANIO AND A.EMP_ID = E.EMP_ID AND PA.COD_COMPANIA = E.COMPANIA AND E.COMPANIA = "+compania+"  AND CR.CLAVE = E.TIPO_RENTA GROUP BY DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)||RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||LPAD(TO_CHAR(E.ASIENTO),5,'0'), E.PRIMER_NOMBRE||' '|| DECODE(E.SEXO,'F',DECODE(E.APELLIDO_CASADA, NULL,E.PRIMER_APELLIDO, DECODE(E.USAR_APELLIDO_CASADA,'S','DE '||  E.APELLIDO_CASADA, E.PRIMER_APELLIDO)),E.PRIMER_APELLIDO), DECODE(NVL(E.GASTO_REP,0),0,'N','S'), E.NUM_EMPLEADO, NVL(E.TIPO_RENTA,'A'), NVL(E.NUM_DEPENDIENTE,0), DECODE(E.DIGITO_VERIFICADOR,NULL,'  ',RPAD(E.DIGITO_VERIFICADOR,2,'0')), A.ANIO, E.FECHA_INGRESO,NVL(PA.VALOR_DEPENDIENTE,0) ,NVL(PA.GR_PORC_NO_RENTA,0) , NVL(PA.GR_LIMITE_NO_RENTA,0),  NVL(CR.PAGO_BASE,0), calcular_isr(E.TIPO_RENTA, E.NUM_DEPENDIENTE, E.SALARIO_BASE, E.COMPANIA)  ORDER BY E.NUM_EMPLEADO ) X";
sql.append("select * from (select x.*, case when x.declarante ='N' and x.v_periodos >= 12 then  decode( sign((x.impuesto_causado - x.imp_renta)),-1,0,(x.impuesto_causado - x.imp_renta)) else 0 end valor_fisco,case when x.declarante ='N' and x.v_periodos >= 12 then  decode( sign((x.imp_renta - x.impuesto_causado)),-1,0,(x.imp_renta - x.impuesto_causado )) else 0 end valor_empleado,	(select descripcion from tbl_sec_unidad_ejec where compania = x.compania and codigo = x.unidad_organi) descUnidad from (select z.*,case when round(nvl(z.periodos,0)/2,0) > 12 then 12 when round(nvl(z.periodos,0)/2,0)  = 0 then 1 else round(nvl(z.periodos,0)/2,0) end v_periodos,z.sal_bruto + g_representacion total_ingresos,nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0) deducciones_dep,decode(sign((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))),-1,0,((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))) ) tot_ingresos,case when round(nvl(z.periodos,0)/2,0) > 12 then getimpuestosisr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,decode(sign((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))),-1,0,((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) +  nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))) ) ,'S','N') else 0 end impuesto_causado from (select all  e.ubic_depto,e.ubic_seccion,decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0') cedula,e.nombre_empleado nombre_emp,decode(nvl(e.gasto_rep,0),0,'N','S')  declarante,nvl(e.tipo_renta,'A') tipo_renta, nvl(e.num_dependiente,0) num_dependiente,decode(e.digito_verificador,null,'  ',rpad(e.digito_verificador,2,'0')) dv,a.anio, e.fecha_ingreso,nvl(p.valor_dependiente,0) valor_dependiente,nvl(p.gr_porc_no_renta,0) gr_porc_no_renta, nvl(p.gr_limite_no_renta,0) gr_limite_no_renta,sum((nvl(a.sal_bruto,0)+ nvl(a.salario_especie,0)+nvl(a.prima_produccion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ) ) sal_bruto, sum(nvl(a.g_representacion,0))  g_representacion, sum((nvl(a.sal_bruto,0) +nvl(a.g_representacion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ))  ingresos,sum( nvl(a.imp_renta,0) ) imp_renta,0  seg_educativo, sum( nvl(a.periodos,0) ) periodos,nvl(cr.pago_base,0) pago_base,e.num_ssocial,e.compania,e.unidad_organi,e.num_empleado  from tbl_pla_acumulado_empleado a,vw_pla_empleado e, tbl_pla_parametros p, tbl_pla_temporal_emp te,tbl_pla_clave_renta cr where e.compania = ");
sql.append(compania);
sql.append(" and e.emp_id = a.emp_id and a.emp_id = te.emp_id and a.num_empleado = te.num_empleado and a.cod_compania = te.cod_compania and te.escoger = 'S' and e.compania =  a.cod_compania and p.cod_compania = e.compania and a.anio = ");
sql.append(anio);
if (!empId.trim().equals("")){sql.append(" and te.emp_id=");sql.append(empId);}
if (!noEmpleado.trim().equals("")){sql.append(" and te.num_empleado='");sql.append(noEmpleado);sql.append("'");}
sql.append(" and  a.sal_bruto > 0 and e.tipo_renta = cr.clave(+) group by e.ubic_depto,e.ubic_seccion,decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0'), e.nombre_empleado,decode(nvl(e.gasto_rep,0),0,'N','S'),nvl(e.tipo_renta,'A'), nvl(e.num_dependiente,0),decode(e.digito_verificador,null,'  ',rpad(e.digito_verificador,2,'0')),a.anio, e.fecha_ingreso,nvl(p.valor_dependiente,0),nvl(p.gr_porc_no_renta,0) ,nvl(p.gr_limite_no_renta,0),nvl(cr.pago_base,0),e.num_ssocial ,e.compania,e.unidad_organi,e.num_empleado having sum((nvl(a.sal_bruto,0)+ nvl(a.salario_especie,0)+nvl(a.prima_produccion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ) ) +sum(  nvl(a.g_representacion,0) )  > 0 order by e.ubic_depto,e.ubic_seccion, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0'), e.nombre_empleado)z)x) where  nvl(valor_fisco,0) > 0  ");
al = SQLMgr.getDataList(sql.toString());

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
	float height = 72 * 14f;//1008
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 9.5f;
	float bottomMargin = 1.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "AUTORIZACION DE DESCUENTO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".05");
	dHeader.addElement(".07");
	dHeader.addElement(".08");
	dHeader.addElement(".15");
	dHeader.addElement(".15");
	dHeader.addElement(".20");
	dHeader.addElement(".25");
	dHeader.addElement(".05");
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);
	
				
		for ( int j = 0; j<al.size(); j++ )
		{
			cdo = (CommonDataObject) al.get(j);
			
			pc.addCols(" ",0,1);
			pc.addCols("Yo,   ",0,1);
			pc.addBorderCols(cdo.getColValue("nombre_emp"),0,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(",con cédula de indentidad   No.",0,1);
			pc.addBorderCols(cdo.getColValue("cedula")+" ",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("y  Seguro  Social  No.",0,2);
			pc.addBorderCols(cdo.getColValue("num_ssocial"),0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("  autorizo a descontar de mi salario la suma de  B/. _______________ hasta completar la suma de B/.",0,3);
			
			pc.addCols(" ",0,1);
			//
			pc.addCols(" ",0,1);
			pc.addBorderCols(cdo.getColValue("valor_fisco"),0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("  correspondiente  a ",0,2);
			pc.addBorderCols(""+justificacion,0,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("  que la empresa tuvo que pagar al Ministerio de Economía y Finanzas.",0,6);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(" ",0,1);
			pc.addCols("Este descuento se efectuará a partir de la  ______________________________  quincena del mes de  _________________  de  ________________________.",0,6);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,dHeader.size());
			
			pc.addCols(" ",0,1);
			pc.addCols("Compañia ",0,2);
			pc.addBorderCols(""+_comp.getNombre(),0,5,0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,1);
			pc.addCols("Departamento ",0,2);
			pc.addBorderCols(""+cdo.getColValue("descUnidad"),0,5,0.5f,0.0f,0.0f,0.0f);
					
		    pc.addCols(" ",0,1);
			pc.addCols("Empleado No. ",0,2);
			pc.addBorderCols(""+cdo.getColValue("num_empleado"),0,5,0.5f,0.0f,0.0f,0.0f);	
			
			pc.addCols(" ",0,dHeader.size());
			
			pc.addCols(" ",0,1);
			pc.addCols("PARTIDAS",1,6);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("Cantidades",1,4);
			pc.addCols("Valor",1,2);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,dHeader.size());
			
			pc.addCols(" ",0,1);
			pc.addCols("________________________       X ",1,4);
			pc.addCols("B/. ___________________",1,2);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("________________________       X ",1,4);
			pc.addCols("B/. ___________________",1,2);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("________________________       X ",1,4);
			pc.addCols("B/. ___________________",1,2);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("________________________       X ",1,4);
			pc.addCols("B/. ___________________",1,2);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("________________________       X ",1,4);
			pc.addCols("B/. ___________________",1,2);
			pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,1);
			pc.addCols("    Atentamente. ",0,7);
			
			pc.addCols(" ",0,1);
			pc.addCols("________________________   ",0,4);
			pc.addCols("________________________   ",0,2);
			pc.addCols(" ",0,1);
			
			
			pc.addCols(" ",0,1);
			pc.addCols("TRABAJADOR",0,4);
			pc.addCols("EMPRESA",0,2);
			pc.addCols(" ",0,1);                      

                                   
			
			pc.flushTableBody(true);
			pc.addNewPage();
			
		   if ((j % 50 == 0) || ((j + 1) == al.size())) pc.flushTableBody(true);
			
		}//for j
		
		  
		if ( al.size() == 0 ){
	    pc.setFont(8,1);
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols("****** NO EXISTEN REGISTROS! ******",1,dHeader.size());
		}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
