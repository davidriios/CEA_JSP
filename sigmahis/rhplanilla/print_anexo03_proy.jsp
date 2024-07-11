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
PLANILLA: anexo03_proy.rdf
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
String empId = request.getParameter("empId");
String noEmpleado = request.getParameter("noEmpleado");
if (empId == null) empId = "";
if (noEmpleado == null) noEmpleado = "";
if (anio == null || anio.equals("")) throw new Exception("El año no es válido!");

//sql = "select z.* ,(select r.rango_inicial_real from tbl_pla_rango_renta r where z.cf_total_ingresos  >  r.rango_inicial and z.cf_total_ingresos  <= r.rango_final /*and tipo ='S'*/)v_rango_inicial, (select r.porcentaje from tbl_pla_rango_renta r where z.cf_total_ingresos  >  r.rango_inicial and z.cf_total_ingresos  <= r.rango_final /*and tipo ='S'*/) v_porcentaje,nvl((select r.cargo_fijo from tbl_pla_rango_renta r where z.cf_total_ingresos > r.rango_inicial and z.cf_total_ingresos <= r.rango_final /*and tipo ='S'*/),0) v_cargo_fijo from (select cedula, dv, nombre_emp, tipo_renta, num_dependiente, case when round(nvl(periodos,0)/2,0) > 12 then 12 when round(nvl(periodos,0)/2,0)  = 0 then 1 else round(nvl(periodos,0)/2,0) end v_mes1, periodos, nvl(sal_bruto,0)+nvl(g_representacion,0) cf_ingresos_brutos,  nvl(v_ded_base,0) + nvl(num_dependiente,0) * nvl(valor_dependiente,0) cf_deduc, seg_educativo, ( nvl(v_ded_base,0) + nvl(num_dependiente,0) * nvl(valor_dependiente,0)+ seg_educativo  ) cf_total_deduc,  case when  ( (nvl(sal_bruto,0)+nvl(g_representacion,0) ) - ( nvl(v_ded_base,0) + nvl(num_dependiente,0) * nvl(valor_dependiente,0)+ seg_educativo  )  ) < 0 then 0 else ((nvl(sal_bruto,0)+nvl(g_representacion,0) ) - ( nvl(v_ded_base,0) + nvl(num_dependiente,0) * nvl(valor_dependiente,0)+ seg_educativo  ) ) end cf_total_ingresos, imp_renta, declarante from (select all decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),5,'0') cedula,  e.primer_nombre||' '|| decode(e.sexo,'F',decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||  e.apellido_casada, e.primer_apellido)),e.primer_apellido) nombre_emp, decode(nvl(e.gasto_rep,0),0,'N','S')  declarante, e.num_empleado, nvl(e.tipo_renta,'A') tipo_renta, nvl(e.num_dependiente,0) num_dependiente,decode(e.digito_verificador,null,'  ',rpad(e.digito_verificador,2,'0')) dv, a.anio, e.fecha_ingreso,nvl(pa.valor_dependiente,0) valor_dependiente,nvl(pa.gr_porc_no_renta,0) gr_porc_no_renta, nvl(pa.gr_limite_no_renta,0) gr_limite_no_renta,  nvl(cr.pago_base,0) v_ded_base/*  calcular_isr(e.tipo_renta, e.num_dependiente, e.salario_base, e.compania) isr */, sum((nvl(a.sal_bruto,0)+ nvl(a.salario_especie,0)+nvl(a.prima_produccion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ) ) sal_bruto, sum(  nvl(a.g_representacion,0) )  g_representacion, sum( (nvl(a.sal_bruto,0) +nvl(a.g_representacion,0) -nvl(a.indemnizacion,0) -nvl(a.prima_antiguedad,0) -nvl(a.preaviso,0) ) )  ingresos, sum( nvl(a.imp_renta,0) ) imp_renta, sum( nvl(a.seg_educativo,0) ) seg_educativo, sum( nvl(a.periodos,0) ) periodos from tbl_pla_pago_empleado p, tbl_pla_empleado e, tbl_pla_acumulado_empleado a, tbl_pla_parametros pa, tbl_pla_clave_renta cr where p.anio = "+anio+" and e.emp_id = p.emp_id and p.cod_compania = e.compania and a.cod_compania = p.cod_compania and a.anio = p.anio and a.emp_id = e.emp_id and pa.cod_compania = e.compania and e.compania = "+compania+"  and cr.clave = e.tipo_renta group by decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),5,'0'), e.primer_nombre||' '|| decode(e.sexo,'F',decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||  e.apellido_casada, e.primer_apellido)),e.primer_apellido), decode(nvl(e.gasto_rep,0),0,'N','S'), e.num_empleado, nvl(e.tipo_renta,'A'), nvl(e.num_dependiente,0), decode(e.digito_verificador,null,'  ',rpad(e.digito_verificador,2,'0')), a.anio, e.fecha_ingreso,nvl(pa.valor_dependiente,0) ,nvl(pa.gr_porc_no_renta,0) , nvl(pa.gr_limite_no_renta,0),  nvl(cr.pago_base,0)  order by e.num_empleado ) x)z ";


sql.append("select z.*,nvl(z.pago_base,0)+(nvl(z.num_dependiente,0)* nvl(z.valor_dependiente,0))+nvl(z.total_seceduc,0) total_decucciones,/*total_ingresos := */(z.total_ingresos + z.total_gr) - (nvl(z.pago_base,0)+(nvl(z.num_dependiente,0)* nvl(z.valor_dependiente,0))) tot_ingresos,/*isr causado*/getImpuestosIsr(z.total_gr,z.gr_porc_no_renta,z.gr_limite_no_renta,0,'G','N') isrGrp,getImpuestosIsr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,z.total_ingresos,'S','N')isrSalario,nvl(getImpuestosIsr(z.total_gr,z.gr_porc_no_renta,z.gr_limite_no_renta,0,'G','N'),0)+nvl(getImpuestosIsr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,z.total_ingresos,'S','N'),0) impCausado from ( select all a.num_empleado noEmpleado,e.provincia,e.sigla,e.tomo,e.asiento,decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||rpad(decode(e.sigla,'00','  ','0','  ',e.sigla),2,' ')||'-'||lpad(to_char(e.tomo),3,'0')||'-'||lpad(to_char(e.asiento),6,'0') cedula,e.primer_nombre||' '||e.primer_apellido||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.segundo_apellido,'DE '||e.apellido_casada),'M',e.segundo_apellido) nombre_emp, decode(e.digito_verificador,null,' ',rpad(e.digito_verificador,2,'0')) dv,nvl(e.tipo_renta,'A') tipo_renta,nvl(e.tipo_renta,'A')||nvl(e.num_dependiente,0) clave_renta,nvl(a.periodos,0) periodos,nvl(e.num_dependiente,0) num_dependiente,a.anio,/*V_INGRESOS    :=    (:SAL_BRUTO + NVL(:CF_SAL_PROYECTADO,0))+ NVL(:CF_XIII_PROYECTADO,0);*/(nvl(a.sal_bruto,0)+nvl(a.prima_produccion,0)+ nvl(a.salario_especie,0))+nvl(getSalarioProyectado(e.compania,");
sql.append(anio);
sql.append(",1,nvl(round(e.salario_base/2,2),0)),0)+nvl(getSalarioProyectado(e.compania,");
sql.append(anio);
sql.append(",2,nvl(e.salario_base,0)),0) total_ingresos,/*:CF_GREP := (:G_REPRESENTACION + NVL(:CF_GREP_PROYECTADO,0));*/ nvl(a.g_representacion,0)+nvl(getSalarioProyectado(e.compania,");
sql.append(anio);
sql.append(",1,round(nvl(e.gasto_rep,0)/2,2)),0)+nvl(getSalarioProyectado(e.compania,");
sql.append(anio);
sql.append(",2,nvl(e.gasto_rep,0)),0)total_gr,nvl(cr.pago_base,0) * nvl(p.valor_dependiente,0) deducciones_dep, round(nvl(getSalarioProyectado(e.compania,");
sql.append(anio);
sql.append(",1,nvl(round(e.salario_base/2,2),0)),0) * 0.0125,2)+nvl(a.seg_educativo,0) total_seceduc,(nvl(a.sal_bruto,0)+nvl(a.prima_produccion,0)+ nvl(a.salario_especie,0)) sal_bruto, nvl(a.g_representacion,0) g_representacion, nvl(a.imp_renta,0) imp_renta, nvl(a.seg_educativo,0) seg_educativo,e.fecha_ingreso,nvl(p.valor_dependiente,0) valor_dependiente,round(e.salario_base/2,2) salario_quinc,e.salario_base,nvl(e.gasto_rep,0)  gasto_rep,round(e.gasto_rep/2,2)  grep_quinc,nvl(p.gr_porc_no_renta,0)   gr_porc_no_renta, nvl(p.gr_limite_no_renta,0)  gr_limite_no_renta,nvl(cr.pago_base,0)pago_base,(nvl(a.sal_bruto,0)+nvl(a.prima_produccion,0)+ nvl(a.salario_especie,0)) salarioDevengado from tbl_pla_acumulado_empleado a,tbl_pla_empleado e,tbl_pla_parametros p, tbl_pla_temporal_emp te,tbl_pla_clave_renta cr where e.compania =");
sql.append(compania);
sql.append(" and a.anio = ");
sql.append(anio);
if (!empId.trim().equals("")){sql.append(" and te.emp_id=");sql.append(empId);}
if (!noEmpleado.trim().equals("")){sql.append(" and te.num_empleado='");sql.append(noEmpleado);sql.append("'");}
sql.append(" and a.sal_bruto > 0 and a.emp_id = te.emp_id and a.num_empleado     = te.num_empleado and a.cod_compania = te.cod_compania and te.escoger = 'S' and e.emp_id  = a.emp_id and e.compania   = a.cod_compania and p.cod_compania = e.compania and e.tipo_renta = cr.clave order by a.num_empleado,e.primer_nombre )z");

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
	dHeader.addElement(".05");
	dHeader.addElement(".10");
	dHeader.addElement(".25");
	dHeader.addElement(".05");
	dHeader.addElement(".05");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");

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

		double tot_sal_bruto = 0.0, tot_ded_basica = 0.0, tot_seg_edu = 0.0,  tot_ded = 0.0, tot_renta_neta = 0.0, tot_imp_caus = 0.0, tot_aj_imp_caus = 0.0, tot_ext_61 = 0.0, tot_ret = 0.0, tot_aj_emp = 0.0, tot_fav_fisco = 0.0, tot_fav_emp = 0.0,favor_emp=0.00,favor_fisco =0.00,total_gr =0.00,totalDevengado=0.00;

		CommonDataObject cdo2 = new CommonDataObject();

		pc.addBorderCols("NO.",1,1);
		pc.addBorderCols("CEDULA",1,1);
		pc.addBorderCols("NOMBRE",1,1);
		pc.addBorderCols("DV",1,1);
		pc.addBorderCols("GRUPO DEP.",1,1);
		pc.addBorderCols("PER",1,1);
		pc.addBorderCols("SAL. DEV.",1,1);
		pc.addBorderCols("SALARIO REC. + PROY.",1,1);
		pc.addBorderCols("GASTOS REP. REC. + PROY.",1,1);

		pc.addBorderCols("DEDUC. DEP",1,1);
		pc.addBorderCols("SEGURO EDUC.",1,1);
		pc.addBorderCols("TOTAL DE DEDUCCIONES",1,1);
		pc.addBorderCols("RENTA NETA GRAVABLE",1,1);
		pc.addBorderCols("IMPUESTO CAUSADO",1,1);
		//pc.addBorderCols("AJUSTE IMP. CAUSADO",1,1);
	    //pc.addBorderCols("EXENCION LEY 61",1,1);
		pc.addBorderCols("RETENCIONES EN EL AÑO",1,1);
		//pc.addBorderCols("AJUSTE FAVOR EMP.",1,1);
		pc.addBorderCols("A FAVOR FISCO",1,1);
		pc.addBorderCols("A FAVOR EMPLEADO",1,1);

		pc.setTableHeader(2);

		for ( int j = 0; j<al.size(); j++ ){
			cdo = (CommonDataObject) al.get(j);
			pc.addCols(""+cdo.getColValue("noEmpleado"),0,1);
			pc.addCols(""+cdo.getColValue("cedula"),0,1);
			pc.addCols(""+cdo.getColValue("nombre_emp"),0,1);
			pc.addCols(""+cdo.getColValue("dv"),1,1);
			pc.addCols(""+cdo.getColValue("clave_renta"),1,1);
			pc.addCols(""+cdo.getColValue("periodos"),1,1);

			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salarioDevengado")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_ingresos")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_gr")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("deducciones_dep")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_seceduc")),2,1);

			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_decucciones")),2,1); //
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("tot_ingresos")),2,1); //
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("impCausado")),2,1);//CF_AJIMP_CAUSADO 0
      		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("imp_renta")),2,1);

			 favor_fisco = Double.parseDouble(cdo.getColValue("impCausado"))- Double.parseDouble(cdo.getColValue("imp_renta"));
			 if(favor_fisco <= 0){
				pc.addCols("0",2,1); favor_fisco=0.00;}
			 else pc.addCols(""+CmnMgr.getFormattedDecimal(favor_fisco),2,1);
			  favor_emp = Double.parseDouble(cdo.getColValue("imp_renta"))- Double.parseDouble(cdo.getColValue("impCausado"));
			 if(favor_emp <= 0){
				pc.addCols("0",2,1);favor_emp=0.00;}
			 else pc.addCols(""+CmnMgr.getFormattedDecimal(favor_emp),2,1);

		   tot_sal_bruto += Double.parseDouble(cdo.getColValue("total_ingresos"));
		   total_gr += Double.parseDouble(cdo.getColValue("total_gr"));
		   tot_ded_basica += Double.parseDouble(cdo.getColValue("deducciones_dep"));

		   tot_seg_edu += Double.parseDouble(cdo.getColValue("total_seceduc"));
		   tot_ded += Double.parseDouble(cdo.getColValue("total_decucciones"));
		   tot_renta_neta += Double.parseDouble(cdo.getColValue("tot_ingresos"));
		   tot_imp_caus += Double.parseDouble(cdo.getColValue("impCausado"));
		   tot_ret += Double.parseDouble(cdo.getColValue("imp_renta"));
		   tot_fav_fisco += favor_fisco;
		   tot_fav_emp   += favor_emp;
		   totalDevengado += Double.parseDouble(cdo.getColValue("salarioDevengado"));


		   if ((j % 50 == 0) || ((j + 1) == al.size())) pc.flushTableBody(true);

		}//for j

		   pc.addCols(" ", 0, dHeader.size());
		   pc.setFont(8,1);
		   pc.addCols("T O T A L E S :",2,6);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(totalDevengado),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_sal_bruto),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(total_gr),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_ded_basica),2,1);

		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_seg_edu),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_ded),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_renta_neta),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_imp_caus),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_ret),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_fav_fisco),2,1);
		   pc.addCols(""+CmnMgr.getFormattedDecimal(tot_fav_emp),2,1);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
