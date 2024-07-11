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
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
StringBuffer sbSql = new StringBuffer();


if (appendFilter == null) appendFilter = "";


sbSql.append("select b.nombre AS nombre,e.nombre_empleado AS nomEmpleado, nvl(e.pasaporte,e.cedula1) AS cedula, e.tipo_renta||' '||e.num_dependiente  AS clave, e.rata_hora AS rata, nvl(d.salario,0) AS salbruto, nvl(d.gasto_rep,0)gastoRep, nvl(d.prima_antiguedad,0) AS prima, nvl(d.indemnizacion,0) AS indemnizacion, nvl(d.preaviso,0) AS preaviso, nvl(d.bonificacion,0) AS bonificacion, nvl(nvl(d.salario,0) + nvl(d.extra,0) + nvl(d.prima_antiguedad,0) + nvl(d.preaviso,0) + nvl(d.bonificacion,0) + nvl(d.gasto_rep,0) + nvl(d.indemnizacion,0) + nvl(d.xiii_mes,0) + nvl(d.vacacion,0) - nvl(d.otros_egr,0),0)  AS salbrutoTop, nvl(d.vacacion,0) AS vacacion, nvl(d.xiii_mes,0) AS decimo, nvl(d.extra,0) AS extra, nvl(d.seg_social,0) AS social, nvl(d.seg_educativo,0) AS educativo, nvl(d.imp_renta,0) AS renta,  nvl(d.ausencia,0) AS ausencia, nvl(d.tardanza,0) AS tardanza, nvl(d.otras_ded,0) AS otrasDed, nvl(d.total_ded,0) AS totDed,nvl(d.otros_ing_fijos,0) AS ingFijos, nvl(d.otros_ing,0) AS otrosIng, nvl(d.otros_egr,0) AS otrosEgr, nvl(d.sal_neto,0) AS salarioNeto, nvl(d.seg_social_gasto,0) AS ssGrep,  nvl(d.imp_renta_gasto,0) imp_renta_gasto, nvl(d.prima_produccion,0) AS primaProd, d.unidad_organi, TO_CHAR(a.fecha_pago,'dd/mm/yyyy') AS fechaPago, LTRIM(b.nombre,18)||' del '||to_char(a.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(a.fecha_final,'dd/mm/yyyy') AS descripcion, d.cod_planilla AS codPlanilla, d.num_cheque AS cheque, d.num_planilla AS numPlanilla, d.anio, e.emp_id AS empId, e.num_empleado AS numEmpleado, NVL(e.ubic_depto,e.ubic_seccion) AS ubicDepto, NVL(f.descripcion,'Por designar ') AS descDepto, e.ubic_seccion AS unidad from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_liquidacion d, vw_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = ");
sbSql.append(anio);
sbSql.append(" and d.num_planilla = ");
sbSql.append(num);
sbSql.append(" and d.cod_planilla = ");
sbSql.append(cod);
sbSql.append(" and a.num_planilla = d.num_planilla and a.cod_compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo order by e.ubic_seccion, e.num_empleado");
al = SQLMgr.getDataList(sbSql.toString());
sbSql = new  StringBuffer();

sbSql.append("SELECT 'A' orden, COUNT(*) AS tot, sum(nvl(d.salario,0)) sbruto,sum(nvl(d.gasto_rep,0))sgastoRep,sum(nvl(d.prima_antiguedad,0)) sprima,sum(nvl(d.indemnizacion,0)) sindemnizacion,sum(nvl(d.preaviso,0))spreaviso,sum(nvl(d.bonificacion,0)) sbonificacion,sum(nvl(d.salario,0)) + sum(nvl(d.extra,0)) + sum(nvl(d.gasto_rep,0))+ sum(nvl(d.otros_ing,0)) + sum(nvl(d.vacacion,0)) + sum(nvl(d.preaviso,0)) + sum(nvl(d.xiii_mes,0)) +sum(nvl(d.prima_antiguedad,0))+sum(nvl(d.indemnizacion,0)) + sum(nvl(d.prima_produccion,0)) + sum(nvl(d.otros_ing_fijos,0)) + sum(nvl(d.otros_ing,0)) - sum(nvl(d.otros_egr,0))ssalbruto,sum(nvl(d.vacacion,0)) AS svacacion,sum(nvl(d.xiii_mes,0)) sdecimo, sum(nvl(d.extra,0))sextra,sum(nvl(d.seg_social,0)) ssocial,sum(nvl(d.seg_educativo,0))seducativo,sum(nvl(d.imp_renta,0))srenta,sum(nvl(d.tardanza,0)) stardanza, sum(nvl(d.otras_ded,0))sotrasDed,sum(nvl(d.total_ded,0))stotDed,sum(nvl(d.otros_ing_fijos,0)) singFijos, sum(nvl(d.otros_ing,0))sotrosIng,sum(nvl(d.otros_egr,0))sotrosEgr, sum(nvl(d.sal_neto,0))ssalNeto,sum(nvl(d.seg_social_gasto,0))sssGrep,sum(nvl(d.imp_renta_gasto,0))sgastoRenta,sum(nvl(d.prima_produccion,0))sprimaProd,e.forma_pago,g.descripcion,0 segsoc, 0 segedu, 0 sdescempl from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_liquidacion d, vw_pla_empleado e, tbl_sec_unidad_ejec f, tbl_pla_f_pago_emp g where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = ");
sbSql.append(anio);
sbSql.append(" and d.num_planilla = ");
sbSql.append(num);
sbSql.append(" and d.cod_planilla = ");
sbSql.append(cod);
sbSql.append(" and a.num_planilla = d.num_planilla and a.cod_compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo and e.forma_pago = g.codigo /*and g.codigo = 1*/  group by  e.forma_pago, g.descripcion,'A'");
 
sbSql.append(" union all ");

sbSql.append("SELECT 'B',COUNT(*) AS tot, sum(nvl(d.salario,0)) sbruto,sum(nvl(d.gasto_rep,0))sgastoRep,sum(nvl(d.prima_antiguedad,0)) sprima,sum(nvl(d.indemnizacion,0)) sindemnizacion,sum(nvl(d.preaviso,0))spreaviso,sum(nvl(d.bonificacion,0)) sbonificacion,sum(nvl(d.salario,0)) + sum(nvl(d.extra,0)) + sum(nvl(d.gasto_rep,0))+ sum(nvl(d.otros_ing,0)) + sum(nvl(d.vacacion,0)) + sum(nvl(d.preaviso,0)) + sum(nvl(d.xiii_mes,0))+sum(nvl(d.prima_antiguedad,0))+sum(nvl(d.indemnizacion,0))+ sum(nvl(d.prima_produccion,0)) + sum(nvl(d.otros_ing_fijos,0)) + sum(nvl(d.otros_ing,0)) - sum(nvl(d.otros_egr,0))ssalbruto,sum(nvl(d.vacacion,0)) AS svacacion,sum(nvl(d.xiii_mes,0)) sdecimo, sum(nvl(d.extra,0))sextra,sum(nvl(d.seg_social,0)) ssocial,sum(nvl(d.seg_educativo,0))seducativo,sum(nvl(d.imp_renta,0))srenta,sum(nvl(d.tardanza,0)) stardanza, sum(nvl(d.otras_ded,0))sotrasDed,sum(nvl(d.total_ded,0))stotDed,sum(nvl(d.otros_ing_fijos,0)) singFijos, sum(nvl(d.otros_ing,0))sotrosIng,sum(nvl(d.otros_egr,0))sotrosEgr, sum(nvl(d.sal_neto,0))ssalNeto,sum(nvl(d.seg_social_gasto,0))sssGrep,sum(nvl(d.imp_renta_gasto,0))sgastoRenta,sum(nvl(d.prima_produccion,0))sprimaProd, 10 , 'FINAL ' descripcion, round(nvl(g.seg_soc_pat,0)/100 * (sum(nvl(d.extra,0)) + sum(nvl(d.otros_ing,0))  + sum(nvl(d.gasto_rep,0)) + sum(nvl(d.prima_produccion,0)) - sum(nvl(d.otros_egr,0))),2) AS segsoc, round(nvl(g.seg_edu_pat,0)/100 * (sum(nvl(d.extra,0)) + sum(nvl(d.otros_ing,0)) + sum(nvl(d.gasto_rep,0)) + sum(nvl(d.prima_produccion,0)) - sum(nvl(d.otros_egr,0))),2) AS segedu, m.sdescempl from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_liquidacion d, tbl_pla_empleado e, tbl_sec_unidad_ejec f, tbl_pla_parametros g, (select sum(nvl(monto,0)) as sdescempl, cod_compania from tbl_pla_descuento_aplicado where anio(+) = ");
sbSql.append(anio);
sbSql.append(" and num_planilla(+) = ");
sbSql.append(num);
sbSql.append(" and cod_planilla(+) = ");
sbSql.append(cod);
sbSql.append(" and cod_grupo in(12, 21) group by cod_compania) m where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = ");
sbSql.append(anio);
sbSql.append(" and d.num_planilla = ");
sbSql.append(num);
sbSql.append(" and d.cod_planilla = ");
sbSql.append(cod);
sbSql.append(" and a.num_planilla = d.num_planilla and a.cod_compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo and a.cod_compania = g.cod_compania  and a.cod_compania = m.cod_compania(+) group by  g.seg_soc_pat, g.seg_edu_pat, sdescempl,'B' order by 1");
val =SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();

sbSql.append("select a.codigo as compCode, a.nombre as compLegalName,nvl( a.ruc,'') as compRUCNo, nvl(a.apartado_postal,'') as compPAddress, a.zona_postal as compAddress, nvl(a.telefono,'') as compTel1, to_char(b.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(b.fecha_final,'dd/mm/yyyy') as compDistrict, c.nombre as compLegalName from TBL_SEC_COMPANIA a, tbl_pla_planilla_encabezado b, tbl_pla_planilla c where b.num_planilla=");
sbSql.append(num);
sbSql.append(" and b.cod_planilla=");
sbSql.append(cod);
sbSql.append(" and b.anio = ");
sbSql.append(anio);
sbSql.append(" and a.codigo= b.cod_compania and a.codigo= c.compania and b.cod_planilla = c.cod_planilla and a.codigo=");
sbSql.append(session.getAttribute("_companyId"));
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Company.class);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
		dHeader.addElement(".04");
		dHeader.addElement(".06");
		dHeader.addElement(".11");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
			

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.addCols(" ",1, dHeader.size());
	pc.setTableHeader(2);
	
	String unidad = "";
	String total = "FINAL";
	double totalUnidadBruto =0.00,totalUnidadGasto =0.00,totalUnidadPrima =0.00,totalUnidadSsocial =0.00,totalUnidadIndemnizacion=0.00,totalUnidadPreaviso=0.00;
	double totalUnidadBonificacion=0.00,totalUnidadDecimo=0.00,totalUnidadVacacion=0.00,totalUnidadSeduc =0.00,totalUnidadRenta =0.00,totalUnidadOtrasDed =0.00,totalUnidadDed =0.00,totalUnidadNeto =0.00,totalUnidadOtrosEgr=0.00,totalUnidadSubbruto=0.00;
	int totalUnd =0;
															
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
			pc.addBorderCols(" ",1, 20, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 1);
			
			pc.addCols(" TOTALES POR UNIDAD :    "+totalUnd,2,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadBruto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadGasto),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadPrima),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadIndemnizacion),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadPreaviso),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadBonificacion),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadVacacion),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadDecimo),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadOtrosEgr),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSubbruto),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSsocial),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSeduc),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadRenta),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadOtrasDed),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadDed),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadNeto),2,1);
			pc.addCols(" ",2,1);
			
			pc.setFont(7, 0);
			pc.addCols(" ",0,dHeader.size());
			
				totalUnd=0;
				totalUnidadBruto=0.00;
				totalUnidadGasto=0.00;
				totalUnidadPrima=0.00;
				totalUnidadIndemnizacion=0.00;
				totalUnidadPreaviso=0.00;
				totalUnidadBonificacion=0.00;
				totalUnidadVacacion=0.00;
				totalUnidadDecimo=0.00;
				totalUnidadOtrosEgr=0.00;
				totalUnidadSubbruto=0.00;
				totalUnidadSsocial=0.00;
				totalUnidadSeduc=0.00;
				totalUnidadRenta=0.00;
				totalUnidadOtrasDed=0.00;
				totalUnidadNeto=0.00;
					
			}
			
			pc.setFont(7, 4);
			pc.addCols("Unidad :  ",0,1);
			pc.addCols(" [ "+cdo.getColValue("unidad")+" ]  "+cdo.getColValue("descDepto"),0,21);
			
			pc.setFont(7, 0);
		pc.addCols("No.Empl",0,1);
		pc.addCols("Cedula",0,1);
		pc.addCols("Nombre",0,1);	
		pc.addCols("Clave Renta",0,1);
		pc.addCols("Rata",0,1);		
		pc.addCols("Salario",2,1);
		pc.addCols("Gasto.Rep",2,1);	
		pc.addCols("Prima Ant.",2,1);														
		pc.addCols("Indem.",2,1);													
		pc.addCols("Preaviso",2,1);
		pc.addCols("Bonificacion",2,1);	
		pc.addCols("Vacaciones",2,1);	
		pc.addCols("Décimo",2,1);
		pc.addCols("Otros Egr.",2,1);													
		pc.addCols("Sal. Bruto",2,1);
		pc.addCols("Seg. Social",2,1);	
		pc.addCols("Seg. Educ.",2,1);	
		pc.addCols("Imp Renta",2,1);	
		pc.addCols("Desc. Acr",2,1);
		pc.addCols("Tot. Ded.",2,1);													
		pc.addCols("Sal. Neto",2,1);
		pc.addCols("Cheque /Tal.",2,1);	
				
		}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo.getColValue("numEmpleado"),0,1);
		pc.addCols(" "+cdo.getColValue("cedula"),0,1);
		pc.addCols(" "+cdo.getColValue("nomEmpleado"),0,1);	
		pc.addCols(" "+cdo.getColValue("clave"),0,1);		
		pc.addCols(" "+cdo.getColValue("rata"),0,1);									
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("salbruto")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("gastoRep")),2,1);	
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("prima")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("indemnizacion")),2,1);																			
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("preaviso")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("bonificacion")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("vacacion")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("decimo")),2,1);	
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("otrosEgr")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("salbrutoTop")),2,1);																			
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("social")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("educativo")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("renta")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("otrasDed")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("totDed")),2,1);																			
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("salarioNeto")),2,1);
		pc.addCols(" "+cdo.getColValue("cheque"),2,1);
		
		
	
		totalUnidadBruto  +=Double.parseDouble(cdo.getColValue("salbruto"));
		totalUnidadGasto  +=Double.parseDouble(cdo.getColValue("gastoRep"));
		totalUnidadPrima  +=Double.parseDouble(cdo.getColValue("prima"));
		totalUnidadIndemnizacion  +=Double.parseDouble(cdo.getColValue("indemnizacion"));
		totalUnidadPreaviso  +=Double.parseDouble(cdo.getColValue("preaviso"));
		totalUnidadBonificacion  +=Double.parseDouble(cdo.getColValue("bonificacion"));
		totalUnidadVacacion  +=Double.parseDouble(cdo.getColValue("vacacion"));
		totalUnidadDecimo  +=Double.parseDouble(cdo.getColValue("decimo"));
		totalUnidadOtrosEgr  +=Double.parseDouble(cdo.getColValue("otrosEgr"));
		totalUnidadSubbruto  +=Double.parseDouble(cdo.getColValue("salbrutoTop"));
		totalUnidadSsocial  +=Double.parseDouble(cdo.getColValue("social"));
		totalUnidadSeduc  +=Double.parseDouble(cdo.getColValue("educativo"));
		totalUnidadRenta +=Double.parseDouble(cdo.getColValue("renta"));
		totalUnidadOtrasDed  +=Double.parseDouble(cdo.getColValue("otrasDed"));
		totalUnidadDed   +=Double.parseDouble(cdo.getColValue("totDed"));
		totalUnidadNeto  +=Double.parseDouble(cdo.getColValue("salarioNeto"));
		
		totalUnd ++;									
		
		
		unidad = cdo.getColValue("unidad");
			

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	
			pc.setFont(7, 0);
			pc.addCols(" ",1, 1);
			pc.addBorderCols(" ",1, 20, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 1);
			pc.addCols(" TOTALES POR UNIDAD :    "+totalUnd,2,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadBruto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadGasto),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadPrima),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadIndemnizacion),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadPreaviso),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadBonificacion),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadVacacion),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadDecimo),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadOtrosEgr),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSubbruto),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSsocial),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadSeduc),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadRenta),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadOtrasDed),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadDed),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnidadNeto),2,1);
			pc.addCols(" ",2,1);
	
	
	if (val.size() == 0) pc.addCols(" ",1,dHeader.size());
	else
	{
		if(al.size()> 2){
			pc.flushTableBody(true);
			pc.addNewPage();}
		pc.addCols(" ",1,dHeader.size());
		pc.setFont(7, 0);
		pc.addCols(" ",1,4);		
		pc.addCols("Empleados",1,1);												
		pc.addCols("Salario",2,1);
		pc.addCols("Gasto.Rep",2,1);	
		pc.addCols("Prima Ant.",2,1);
		pc.addCols("Indem.",2,1);													
		pc.addCols("Preaviso",2,1);
		pc.addCols("Bonificacion",2,1);	
		pc.addCols("Vacaciones",2,1);	
		pc.addCols("Décimo",2,1);
		pc.addCols("Otros",2,1);													
		pc.addCols("Sal. Bruto",2,1);
		pc.addCols("Seg. Social",2,1);	
		pc.addCols("Seg. Educ.",2,1);	
		pc.addCols("Imp. Renta",2,1);	
		pc.addCols("Desc. Acr.",2,1);
		pc.addCols("Tot. Ded.",2,1);													
		pc.addCols("Sal. Neto",2,2);
	
	for (int i=0; i<val.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) val.get(i);
      
	  	pc.setFont(8, 0);
		pc.addCols(" ",0,dHeader.size());
		
			pc.addCols(" "+cdo.getColValue("descripcion")+" :",1,4);
			pc.addCols(" "+cdo.getColValue("tot"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sbruto")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sgastoRep")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sprima")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sindemnizacion")),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("spreaviso")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sbonificacion")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("svacacion")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sdecimo")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sotrosEgr")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ssalbruto")),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ssocial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("seducativo")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("srenta")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sotrasDed")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("stotDed")),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ssalNeto")),2,2);
			
		if (total.equalsIgnoreCase(cdo.getColValue("descripcion")))
			{	
			
			String segpat = "" +cdo.getColValue("segsoc");
			String edupat = ""+cdo.getColValue("segedu");
			
			pc.addCols(" ",0,dHeader.size());
			
			pc.addCols(" ",1, 6);
			pc.addBorderCols(" ",1, 10, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 6);
			
			pc.addCols(" ",1, 6);
			pc.addBorderCols("RESUMEN ",1,10, 1.5f, 1.5f, 1.5f,1.5f,cHeight);
			pc.addCols(" ",1, 6);
			
			pc.addCols(" ",0,6);
			pc.addCols("SALARIO BRUTO ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ssalbruto")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("GASTO DE REPRESENTACION ",0,3);
			//pc.addBorderCols(" ",1, 2, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sgastoRep")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("PRIMA DE ANTIGUEDAD ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sprima")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("INDEMNIZACION ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sindemnizacion")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("PREAVISO ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("spreaviso")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("BONIFICACIONES ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sbonificacion")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("VACACIONES ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("svacacion")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("DECIMO TERCER MES ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sdecimo")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("OTROS EGRESOS ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sotrosEgr")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("SEGURO SOCIAL(EMP) ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ssocial")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("SEGURO EDUCATIVO(EMP) ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("seducativo")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("IMPUESTO / RENTA ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("srenta")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("DESCUENTOS ACREEDORES ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sotrasDed")),2,3);
			pc.addCols(" ",0,9);
			
			pc.addCols(" ",0,6);
			pc.addCols("SALARIO NETO ",0,3);
			pc.addCols(" ",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ssalNeto")),2,3);
			pc.addCols(" ",0,9);
					
		
			}
		}
	}		
	//pc.addNewPage();
	}
	pc.flushTableBody(true);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>