<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList val = new ArrayList();
ArrayList tot = new ArrayList();
String sql = "";
String newsql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String empId = request.getParameter("empId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id"); 
CommonDataObject cdo2 = null;
Company com= new Company ();


if (appendFilter == null) appendFilter = "";

sql = "select distinct e.emp_id, b.nombre as nombre, e.nombre_empleado as nomEmpleado,  nvl(e.pasaporte,e.cedula1) as cedula, e.tipo_renta||' '||e.num_dependiente  as clave, e.rata_hora as rata, nvl(d.sal_bruto,0) as salbruto, nvl(d.gasto_rep,0) as gastoRep,  nvl(d.sal_bruto,0) + nvl(d.gasto_rep,0) as totbruto, nvl(d.comision,0) as comision, nvl(d.sal_neto,0) as neto, nvl(d.ausencia,0) as ausencia, nvl(d.sal_ausencia,0) + nvl(d.extra,0) + nvl(d.otros_ing,0) + nvl(d.alto_riesgo,0) +nvl(d.bonificacion,0) + nvl(d.gasto_rep,0) + nvl(d.prima_produccion,0) - nvl(d.otros_egr,0) as salbruto, nvl(d.sal_ausencia,0) as salAusencia, nvl(d.ausencia,0) + nvl(d.sal_ausencia,0) + nvl(d.tardanza,0) as salbase, nvl(d.extra,0) as extra, nvl(d.seg_social,0) as social, nvl(d.seg_educativo,0) as educativo, nvl(d.imp_renta,0) as renta,  nvl(d.fondo_com,0) as fondoCom, nvl(d.tardanza,0) as tardanza, nvl(d.otras_ded,0) as otrasDed, nvl(d.total_ded,0) as totDed, nvl(d.dev_multa,0) as multa, nvl(d.ayuda_mortuoria,0) as mortuoria, nvl(d.otros_ing,0) +  nvl(d.alto_riesgo,0) as otrosIng, nvl(d.otros_egr,0) as otrosEgr, nvl(d.otros_ing_fijos,0) as ingFijos, nvl(d.alto_riesgo,0) as riesgo,nvl(d.bonificacion,0) as bonificacion, nvl(d.prima_produccion,0) as prima, nvl(d.imp_renta_gasto,0) as gastoRenta, nvl(d.seg_social_gasto,0) as ssGrep,nvl(d.salario_especie,0) as salEspecie, nvl(d.seg_social_especie,0) as ssEspecie, nvl(d.aguinaldo_gasto,0) as aguinaldo, d.periodo_xiiimes as perDecimo, d.unidad_organi, to_char(a.fecha_pago,'dd/mm/yyyy') as fechaPago, d.periodo, d.cheque_pago as ckPago,  ltrim(b.nombre,18)||' del '||a.fecha_inicial||' al '||a.fecha_final as descripcion, d.cod_planilla as codPlanilla, d.num_cheque as cheque, d.num_planilla as numPlanilla, d.anio, e.emp_id as empId, e.num_empleado as numEmpleado, nvl(e.ubic_depto,e.ubic_seccion) as ubicDepto, nvl(f.descripcion,'Por designar ') as descDepto, e.ubic_seccion as unidad, to_char(g.fecha_inicio,'dd/mm/yyyy') as fechaini, to_char(g.fecha_final,'dd/mm/yyyy') as fechafin from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, vw_pla_empleado e, tbl_sec_unidad_ejec f, tbl_pla_det_vacacion g where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and d.anio = g.anio_pago and a.periodo = g.quincena_pago and a.cod_compania = g.cod_compania and d.emp_id = g.emp_id and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo and g.vac_anio >= to_char(sysdate,'yyyy')-2 order by e.ubic_seccion, e.num_empleado";
al = SQLMgr.getDataList(sql);

sql = "Select count(*) as tot, to_char(sum(d.sal_bruto),'999,990.00') as sbruto, to_char(sum(d.sal_bruto) + sum(d.gasto_rep),'999,990.00') as stotbruto, to_char(sum(d.gasto_rep),'999,990.00') as sgastoRep, to_char(sum(d.comision),'999,990.00') as scomision, to_char(sum(d.sal_neto),'999,990.00') as sneto, to_char(sum(d.ausencia),'999,990.00') as sausencia, to_char(sum(d.sal_ausencia),'999,990.00') as ssalAusencia, to_char(sum(d.extra),'999,990.00') as sextra, to_char(sum(d.ausencia) + sum(d.sal_ausencia) + sum(d.tardanza),'999,990.00') as ssalbase, to_char(sum(d.sal_ausencia) + sum(d.extra) + sum(d.otros_ing) + sum(d.alto_riesgo) + sum(d.bonificacion) + sum(d.gasto_rep) + sum(d.prima_produccion) - sum(d.otros_egr),'999,990.00')  as ssalbruto, to_char(sum(d.seg_social),'999,990.00') as ssocial, to_char(sum(d.seg_educativo),'999,990.00') as seducativo, to_char(sum(d.imp_renta),'999,990.00') as srenta,  to_char(sum(d.fondo_com),'999,990.00') as sfondoCom, to_char(sum(d.tardanza),'999,990.00') as stardanza, to_char(sum(d.otras_ded),'999,990.00') as sotrasDed, to_char(sum(d.total_ded),'999,990.00') as stotDed, to_char(sum(d.dev_multa),'999,990.00') as smulta, to_char(sum(d.ayuda_mortuoria),'999,990.00') as smortuoria, to_char(sum(d.otros_ing) + sum(d.alto_riesgo),'999,990.00') as sotrosIng, to_char(sum(d.otros_egr),'999,990.00') as sotrosEgr, to_char(sum(d.otros_ing_fijos),'999,990.00') as singFijos, to_char(sum(d.alto_riesgo),'999,990.00') as sriesgo,  to_char(sum(d.bonificacion),'999,990.00') as sbonificacion,  to_char(sum(d.prima_produccion),'999,990.00') as sprima, to_char(sum(d.imp_renta_gasto),'999,990.00') as sgastoRenta, to_char(sum(d.seg_social_gasto),'999,990.00') as sssGrep, to_char(sum(d.salario_especie),'999,990.00') as ssalEspecie, to_char(sum(d.seg_social_especie),'999,990.00') as sssEspecie, to_char(sum(d.aguinaldo_gasto),'999,990.00') as saguinaldo, e.forma_pago, g.descripcion,0 as segsoc, 0 as segedu, 0 as sdescempl from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f, tbl_pla_f_pago_emp g where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo and e.forma_pago = g.codigo" ; 

 sql += " group by  e.forma_pago, g.descripcion  union ";
 
 sql +=  "Select count(*) as tot, to_char(sum(d.sal_bruto),'999,990.00') as sbruto,  to_char(sum(d.sal_bruto) + sum(d.gasto_rep),'999,990.00') as stotbruto, to_char(sum(d.gasto_rep),'999,990.00') as sgastoRep, to_char(sum(d.comision),'999,990.00') as scomision, to_char(sum(d.sal_neto),'999,990.00') as sneto, to_char(sum(d.ausencia),'999,990.00') as sausencia, to_char(sum(d.sal_ausencia),'999,990.00') as ssalAusencia, to_char(sum(d.extra),'999,990.00') as sextra, to_char(sum(d.ausencia) + sum(d.sal_ausencia) + sum(d.tardanza),'999,990.00') as ssalbase, to_char(sum(d.sal_ausencia) + sum(d.extra) + sum(d.otros_ing) + sum(d.alto_riesgo) + sum(d.bonificacion) + sum(d.gasto_rep) + sum(d.prima_produccion) - sum(d.otros_egr),'999,990.00')  as ssalbruto, to_char(sum(d.seg_social),'999,990.00') as ssocial, to_char(sum(d.seg_educativo),'999,990.00') as seducativo, to_char(sum(d.imp_renta),'999,990.00') as srenta,  to_char(sum(d.fondo_com),'999,990.00') as sfondoCom, to_char(sum(d.tardanza),'999,990.00') as stardanza, to_char(sum(d.otras_ded),'999,990.00') as sotrasDed, to_char(sum(d.total_ded),'999,990.00') as stotDed, to_char(sum(d.dev_multa),'999,990.00') as smulta, to_char(sum(nvl(d.ayuda_mortuoria,0)),'999,990.00') as smortuoria, to_char(sum(d.otros_ing) + sum(d.alto_riesgo),'999,990.00') as sotrosIng, to_char(sum(d.otros_egr),'999,990.00') as sotrosEgr, to_char(sum(d.otros_ing_fijos),'999,990.00') as singFijos, to_char(sum(d.alto_riesgo),'999,990.00') as sriesgo,  to_char(sum(d.bonificacion),'999,990.00') as sbonificacion,  to_char(sum(d.prima_produccion),'999,990.00') as sprima, to_char(sum(d.imp_renta_gasto),'999,990.00') as sgastoRenta, to_char(sum(d.seg_social_gasto),'999,990.00') as sssGrep, to_char(sum(d.salario_especie),'999,990.00') as ssalEspecie, to_char(sum(d.seg_social_especie),'999,990.00') as sssEspecie, to_char(sum(d.aguinaldo_gasto),'999,990.00') as saguinaldo, 10 , 'FINAL ' as descripcion, round(nvl(g.seg_soc_pat,0)/100 * (sum(d.sal_ausencia) + sum(d.extra) + sum(d.otros_ing) + sum(d.alto_riesgo) + sum(d.gasto_rep) + sum(d.prima_produccion) - sum(d.otros_egr)),2) as segsoc, round(nvl(g.seg_edu_pat,0)/100 * (sum(d.sal_ausencia) + sum(d.extra) + sum(d.otros_ing) + sum(d.alto_riesgo) + sum(d.gasto_rep) + sum(d.prima_produccion) - sum(d.otros_egr)),2) as segedu, nvl(m.sdescempl,0)sdescempl from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f, tbl_pla_parametros g, (select sum(nvl(monto,0)) as sdescempl, cod_compania from tbl_pla_descuento_aplicado where anio(+) = "+anio+" and num_planilla(+) = "+num+" and cod_planilla(+) = "+cod+" and cod_grupo in(12, 21) group by cod_compania) m where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo and a.cod_compania = g.cod_compania  and a.cod_compania = m.cod_compania(+) group by  g.seg_soc_pat, g.seg_edu_pat, nvl(sdescempl,0) order by 1,2 " ; 

val =SQLMgr.getDataList(sql);

sql="select a.codigo as compCode, a.nombre as compLegalName,nvl( a.ruc,'') as compRUCNo, nvl(a.apartado_postal,'') as compPAddress, a.zona_postal as compAddress, nvl(a.telefono,'') as compTel1, to_char(b.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(b.fecha_final,'dd/mm/yyyy') as compDistrict, c.nombre as compLegalName from TBL_SEC_COMPANIA a, tbl_pla_planilla_encabezado b, tbl_pla_planilla c where b.num_planilla="+num+" and b.cod_planilla="+cod+" and b.anio = "+anio+" and a.codigo= b.cod_compania and a.codigo= c.compania and b.cod_planilla = c.cod_planilla and a.codigo="+(String) session.getAttribute("_companyId");

com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
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

	float width = 72 * 14f;//612
	float height = 72 * 8.5f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " "+com.getCompLegalName()+" [ "+num+" ] - [ "+anio+" ]";
	String subtitle = "Pago Correspondiente del :  "+com.getCompDistrict();
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".14");
		dHeader.addElement(".03");
		dHeader.addElement(".04");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".07");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		
			

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	
	String unidad = "";
	String total = "FINAL";
	int totalUnidad =0;
	boolean delPacDet = false;
	double totalUnidadBruto =0.00,totalUnidadGasto =0.00,totalUnidadSubbruto =0.00,totalUnidadSsocial =0.00;
	double totalUnidadSeduc =0.00,totalUnidadRenta =0.00,totalUnidadOtrasDed =0.00,totalUnidadDed =0.00,totalUnidadNeto =0.00;
		//second row
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
      
	  		if (!unidad.equalsIgnoreCase(cdo.getColValue("unidad")))
			{
			
			if(i != 0)
			{
		
			pc.setFont(7, 0);
			pc.addCols(" ",1, 1);
			pc.addBorderCols(" ",1, 15, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 1);
			
			//cdo2 = (CommonDataObject) htUni.get(unidad);
			pc.addCols(" TOTALES POR UNIDAD :    ",2,5);
			pc.addCols(" "+totalUnidad,1,2);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadBruto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadGasto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSubbruto),2,1);//cdo2.getColValue("stotbruto")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSsocial),2,1);//cdo2.getColValue("ssocial")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSeduc),2,1);	//cdo2.getColValue("seducativo")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadRenta),2,1);//cdo2.getColValue("srenta")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadOtrasDed),2,1);//cdo2.getColValue("sotrasDed")																		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadDed),2,1);//cdo2.getColValue("stotDed")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadNeto),2,1);//cdo2.getColValue("sneto")
			pc.addCols(" ",2,1);
			
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			
			totalUnidad =0;
			totalUnidadBruto =0.00;totalUnidadGasto =0.00;
			totalUnidadSubbruto =0.00;totalUnidadSsocial =0.00;
			totalUnidadSeduc =0.00;totalUnidadRenta =0.00;
			totalUnidadOtrasDed =0.00;totalUnidadDed =0.00;
			totalUnidadNeto =0.00;
					
			}
			
			pc.setFont(7, 0);
			
			if(i!=0){
			pc.flushTableBody(true);
			pc.deleteRows(-1);
			}
					
			pc.addCols("",0,dHeader.size());	
			pc.setFont(7, 4);
			pc.addCols("Unidad :  ",0,1);
			pc.addCols(" [ "+cdo.getColValue("unidad")+" ]  "+cdo.getColValue("descDepto"),0,16);
			
			
		pc.setFont(7, 3);
		pc.addCols("No.Empl",0,1);
		pc.addCols("Cedula",0,1);
		pc.addCols("Nombre del Empleado",0,1);	
		pc.addCols("Clave Renta",0,1);
		pc.addCols("Rata",0,1);												
		pc.addCols("Periodo de Vacaciones",1,2);
		pc.addCols("Salario Bruto",2,1);
		pc.addCols("Gasto Rep.",2,1);
		pc.addCols("Vacaciones",2,1);
		pc.addCols("Seguro Soc.",2,1);													
		pc.addCols("Seguro Educ.",2,1);
		pc.addCols("Imp. Renta",2,1);	
		pc.addCols("Descuento Acr.",2,1);	
		pc.addCols("Total Deduc.",2,1);
		pc.addCols("Sal.Neto",2,1);													
		pc.addCols("Cheque /Tal.",2,1);
		if(i == 0){pc.setTableHeader(3);delPacDet = true;}
			
		}
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo.getColValue("numEmpleado"),0,1);
		pc.addCols(" "+cdo.getColValue("cedula"),0,1);
		pc.addCols(" "+cdo.getColValue("nomEmpleado"),0,1);	
		pc.addCols(" "+cdo.getColValue("clave"),0,1);																			
		pc.addCols(" "+cdo.getColValue("rata"),0,1);																		
		pc.addCols(" "+cdo.getColValue("fechaini"),1,1);
		pc.addCols(" "+cdo.getColValue("fechafin"),1,1);	
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("salbruto")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("gastoRep")),2,1);																			
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("totbruto")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("social")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("educativo")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("renta")),2,1);	
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("otrasDed")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("totDed")),2,1);																			
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("neto")),2,1);
		pc.addCols(" "+cdo.getColValue("cheque"),2,1);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		//pc.addCols(" "+cdo.getColValue("cedula"),0,2);
		//pc.addCols(" "+cdo.getColValue("clave"),0,1);																			
		//pc.addCols(" "+cdo.getColValue("rata"),0,12);
		
		unidad = cdo.getColValue("unidad");
		
		totalUnidadBruto  +=Double.parseDouble(cdo.getColValue("salbruto"));
		totalUnidadGasto  +=Double.parseDouble(cdo.getColValue("gastoRep"));
		totalUnidadSubbruto  +=Double.parseDouble(cdo.getColValue("totbruto"));
		totalUnidadSsocial  +=Double.parseDouble(cdo.getColValue("social"));
		totalUnidadSeduc  +=Double.parseDouble(cdo.getColValue("educativo"));
		totalUnidadOtrasDed  +=Double.parseDouble(cdo.getColValue("otrasDed"));
		totalUnidadDed   +=Double.parseDouble(cdo.getColValue("totDed"));
		totalUnidadNeto  +=Double.parseDouble(cdo.getColValue("neto"));
		totalUnidadRenta +=Double.parseDouble(cdo.getColValue("renta"));
		totalUnidad ++;

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.setFont(7, 0);
			pc.addCols(" ",1, 1);
			pc.addBorderCols(" ",1, 15, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 1);
		
			pc.addCols(" TOTALES POR UNIDAD :    ",2,5);			
			pc.addCols(" "+totalUnidad,1,2);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadBruto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadGasto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSubbruto),2,1);//cdo2.getColValue("stotbruto")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSsocial),2,1);//cdo2.getColValue("ssocial")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSeduc),2,1);	//cdo2.getColValue("seducativo")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadRenta),2,1);//cdo2.getColValue("srenta")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadOtrasDed),2,1);//cdo2.getColValue("sotrasDed")																		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadDed),2,1);//cdo2.getColValue("stotDed")
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadNeto),2,1);//cdo2.getColValue("sneto")
			pc.addCols(" ",2,1);
			//pc.addCols(" ",0,dHeader.size());
	if (val.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.flushTableBody(true);	
		pc.addNewPage();

		pc.setFont(7, 3);
		pc.addCols(" ",0,4);
		pc.addCols("Empleados",2,2);												
		pc.addCols("Vacaciones",2,1);
		pc.addCols("Gasto de Rep.",2,1);	
		pc.addCols("Total Vacaciones",2,1);
		pc.addCols("Seguro Social",2,1);													
		pc.addCols("Seguro Educativo",2,1);
		pc.addCols("Impuesto Renta",2,1);	
		pc.addCols("Descuento Acreedores",2,1);	
		pc.addCols("Total Deducciones",2,1);
		pc.addCols("Salario Neto",2,1);	
		pc.addCols("",2,1);													
		
	//table body
	
	for (int i=0; i<val.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) val.get(i);
      
	  	pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
		
			pc.addCols(" ",2,2);
			pc.addCols(" "+cdo.getColValue("descripcion")+" :  ",0,2);
			pc.addCols(" "+cdo.getColValue("tot"),2,2);
			pc.addCols(" "+cdo.getColValue("sbruto"),2,1);
			pc.addCols(" "+cdo.getColValue("sgastoRep"),2,1);
			pc.addCols(" "+cdo.getColValue("stotbruto"),2,1);
			pc.addCols(" "+cdo.getColValue("ssocial"),2,1);
			pc.addCols(" "+cdo.getColValue("seducativo"),2,1);	
			pc.addCols(" "+cdo.getColValue("srenta"),2,1);
			pc.addCols(" "+cdo.getColValue("sotrasDed"),2,1);																			
			pc.addCols(" "+cdo.getColValue("stotDed"),2,1);
			pc.addCols(" "+cdo.getColValue("sneto"),2,1);
			pc.addCols(" ",2,1);
			
		if (total.equalsIgnoreCase(cdo.getColValue("descripcion")))
			{	
			
			String segpat = "" +cdo.getColValue("segsoc");
			String edupat = ""+cdo.getColValue("segedu");
			
			pc.setFont(8, 0);
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(7, 0);
			pc.addCols(" ",1, 6);
			pc.addBorderCols(" ",1, 5, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 6);
			
			pc.setFont(7, 0);
			pc.addCols(" ",1, 6);
			pc.addBorderCols("RESUMEN ",1, 5, 1.5f, 1.5f, 1.5f,1.5f,cHeight);
			pc.addCols(" ",1, 6);
			
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("SALARIO BRUTO ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sbruto"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("GASTO DE REPRESENTACION ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sgastoRep"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("PRIMA DE PRODUCCION ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sprima"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("HORAS EXTRAS ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sextra"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("OTROS INGRESOS ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sotrosIng"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("BONIFICACIONES ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sbonificacion"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("AUSENCIAS ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sausencia"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("TARDANZAS ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("stardanza"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("OTROS EGRESOS ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sotrosEgr"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("SEGURO SOCIAL(EMP) ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("ssocial"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("SEGURO EDUCATIVO(EMP) ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("seducativo"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("SEGURO SOCIAL(PAT) ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+segpat,2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("SEGURO EDUCATIVO(PAT) ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+edupat,2,1);
			pc.addCols(" ",0,4);
			
					pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("IMPUESTO / RENTA ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("srenta"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("DESCUENTOS ACREEDORES ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sotrasDed"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("CXC EMPLEADOS ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sdescempl")),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("AYUDA MORTUORIO ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("smortuoria"),2,1);
			pc.addCols(" ",0,4);
			
			pc.addCols("",0,dHeader.size());
			pc.addCols(" ",0,4);
			pc.addCols("SALARIO NETO ",0,3);
			pc.addBorderCols(" ",1, 4, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("sneto"),2,1);
			pc.addCols(" ",0,4);
			
			}
			
			}
			
			
			
		}		
	}
	pc.flushTableBody(true);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>