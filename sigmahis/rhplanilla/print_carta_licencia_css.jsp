<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: Tirza Monteza.                   -->
<!-- Reporte: carta_trab							                  -->
<!-- Reporte: CARTA DE TRABAJO  	                      -->
<!-- Clínica Hospital San Fernando                      -->
<!-- Fecha: 07/01/2011                                  -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alA = new ArrayList(); // aumentos
ArrayList alV = new ArrayList(); // vacaciones
CommonDataObject cdo   = new CommonDataObject();
String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String appendFilter2 	 = "";
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String compania 			 = (String) session.getAttribute("_companyId");
String empId			 = request.getParameter("empIdCert");
String nombreEmpRepr	 = request.getParameter("nombreEmpRepr");
String cargoEmpRepr	 	 = request.getParameter("cargoEmpRepr");
String observacion	 	 = request.getParameter("observacion");
String dirigidoA		 	 = request.getParameter("dirigidoA");
String fechaDesde		 	 			 = request.getParameter("fechaDesde");
String fechaHasta		 	 			 = request.getParameter("fechaHasta");
String nota		 	 			 = request.getParameter("nota");
StringBuffer sbSql  = new StringBuffer();
double salarioNeto=0.00, totalDeduc=0.00;

String fg 	 = request.getParameter("fg");
String id			 = request.getParameter("id");
if (id 		== null) id = "";
if (appendFilter 	== null) appendFilter = "";
if (empId 		== null) empId = "";
if (nombreEmpRepr == null) nombreEmpRepr = "";
if (cargoEmpRepr 	== null) cargoEmpRepr = "";
if (observacion 	== null) observacion = "";
if (dirigidoA 		== null) dirigidoA = "Caja de Seguro Social";
if (nota			 		== null) nota = "";
if (fechaDesde			 		== null) fechaDesde = "";
if (fechaHasta			 		== null) fechaHasta = "";

//--------------Parámetros--------------------//
if (!compania.equals(""))		appendFilter += " and a.compania = "+compania;
  
	sbSql.append("select  (select 'No. SS Patronal '||num_patronal patrono from tbl_sec_compania where codigo=");
	sbSql.append(compania);
	sbSql.append(") patrono,'Panamá, '||to_char(sysdate,'dd')||' de '||to_char(sysdate,'FMmonth','NLS_DATE_LANGUAGE=SPANISH')||' de '||to_char(sysdate,'yyyy') fechaCarta,'Hacemos constar que '||decode(a.sexo,'F','la Sra. ','el Sr. ')||a.nombre_empleado||',  con cédula de identidad personal número  '||a.cedula1||'  y seguro social No.  '||decode(a.num_ssocial,'9999999',a.cedula1,a.num_ssocial)||', presenta el siguiente desglose de salarios:' certificacion ,a.emp_id,to_char(b.fecha_desde,'dd/mm/yyyy')fechaDesde, to_char(b.fecha_hasta,'dd/mm/yyyy')fechaHasta,b.destinatario1,b.destinatario2,b.destinatario3,b.observacion,(select nombre_empleado from vw_pla_empleado where emp_id = b.emp_id_firma and compania=b.compania )nombreEmpRepr ,(select c.denominacion from vw_pla_empleado e,tbl_pla_cargo c where e.emp_id = b.emp_id_firma and e.compania=b.compania and e.cargo = c.codigo and e.compania = c.compania)cargoEmpRepr from vw_pla_empleado a,tbl_pla_sol_carta b where  a.emp_id = b.emp_id and a.compania=b.compania and b.id=");
	sbSql.append(id);
	sbSql.append(appendFilter.toString());
	cdo = SQLMgr.getData(sbSql.toString());

	sbSql  = new StringBuffer();
	sbSql.append("select descripcion,sum(nvl(salario,0))+ sum(nvl(ausencias,0)+nvl(tardanzas,0))salario, sum(nvl(extra,0))extras, sum(nvl(vacacion,0))vacacion, sum(nvl(ausencias,0)+nvl(tardanzas,0)) ausencias ,sum((nvl(salario,0)+nvl(extra,0)+nvl(vacacion,0))+ (nvl(ausencias,0)+nvl(tardanzas,0))-(nvl(ausencias,0)+nvl(tardanzas,0))) total,mes,anio from ( select  pe.anio,pe.fecha_pago,pe.periodo, pd.num_planilla, pd.emp_id, pd.cod_planilla,pl.cod_concepto, to_char(to_date(pe.fecha_pago,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') descripcion, pd.num_empleado,nvl(decode(pd.cod_pla_aj,'3',0,decode(pd.cod_planilla,'1',pd.sal_ausencia,'7',pd.sal_ausencia,0)),0) salario, nvl(pd.extra,0)+nvl(pd.otros_ing,0) as extra, nvl(decode(pd.cod_planilla,'2',pd.sal_ausencia,0),0) decimo,nvl(decode(pd.cod_pla_aj,'3',pd.sal_ausencia,0 /*decode(pd.cod_planilla,'3',pd.sal_ausencia,0)*/),0) vacacion, nvl(decode(pd.cod_planilla,'5',pd.sal_ausencia,'7',pd.bonificacion,0),0) bonificacion, nvl(decode(pd.cod_planilla,'6',pd.sal_ausencia,0),0) incentivo, nvl(pd.otros_ing,0) otros_ingresos, nvl(pd.gasto_rep,0) gasto_rep, nvl(pd.ausencia,0) ausencias, nvl(pd.tardanza,0) tardanzas, nvl(pd.otros_egr,0)+nvl(pd.otras_ded,0) otros_egresos, 0 otros, nvl(pd.seg_social,0) seg_social, nvl(pd.seg_educativo,0) seg_educativo, nvl(pd.imp_renta,0) imp_renta, 0 prima_antiguedad, 0 indemnizacion, 0 preaviso, nvl(pd.sal_neto,0) sal_neto, nvl(nvl(pd.sal_ausencia,0)+nvl(pd.ausencia,0)+nvl(pd.tardanza,0),pd.sal_bruto) sal_bruto, nvl(pd.otras_ded,0) otras_ded, nvl(pe.planilla_mensual,'N') planilla_mensual, decode(pe.periodo_mes,1,'PRIMERA','SEGUNDA') quincena,nvl(pd.prima_produccion,0) primaProd,'A' descType,to_char(pe.fecha_pago,'mm')mes from  tbl_pla_pago_empleado pd, tbl_pla_planilla_encabezado pe, tbl_pla_planilla pl where pd.cod_compania = ");
	sbSql.append(compania);
	sbSql.append(" and pd.emp_id =");
	sbSql.append(cdo.getColValue("emp_id"));
	sbSql.append(" and trunc(pe.fecha_pago) <= to_date('");	
	sbSql.append(cdo.getColValue("fechaHasta"));	
	sbSql.append("','dd/mm/yyyy')  and trunc(pe.fecha_pago) >= to_date('");
	sbSql.append(cdo.getColValue("fechaDesde"));
	sbSql.append("','dd/mm/yyyy') and pe.cod_planilla = pd.cod_planilla and pe.num_planilla = pd.num_planilla and pl.cod_planilla = pe.cod_planilla and pl.compania = pe.cod_compania and pe.anio = pd.anio and pe.cod_compania = pd.cod_compania union all  select   pe.anio,pe.fecha_pago,pe.periodo,pd.num_planilla,pd.emp_id, pd.cod_planilla, pl.cod_concepto,to_char(to_date(pe.fecha_pago,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') descripcion, pd.num_empleado,nvl(pd.salario,0)salario,nvl(pd.extra,0)+nvl(pd.otros_ing,0) as extra,nvl(pd.xiii_mes,0)decimo,nvl(pd.vacacion,0)vacacion,nvl(pd.bonificacion,0)bonificacion, 0 incentivo, nvl(pd.otros_ing,0) otros_ingresos, nvl(pd.gasto_rep,0)gasto_rep,nvl(pd.ausencia,0)ausencia, nvl(pd.tardanza,0)tardanzas,nvl(pd.otros_egr,0)otros_egresos, 0 otros,nvl(pd.seg_social,0) seg_social, nvl(pd.seg_educativo,0) seg_educativo, nvl(pd.imp_renta,0) imp_renta, nvl(pd.prima_antiguedad,0)prima_antiguedad,  nvl(pd.indemnizacion,0) indemnizacion, nvl(pd.preaviso,0) preaviso, nvl(pd.sal_neto,0) sal_neto,nvl(nvl(pd.salario,0) + nvl(pd.extra,0) + nvl(pd.prima_antiguedad,0) + nvl(pd.preaviso,0) + nvl(pd.bonificacion,0) + nvl(pd.gasto_rep,0) + nvl(pd.indemnizacion,0) + nvl(pd.xiii_mes,0) + nvl(pd.vacacion,0) - nvl(pd.otros_egr,0),0) sal_bruto, nvl(pd.otras_ded,0) otras_ded,nvl(pe.planilla_mensual,'N') planilla_mensual, decode(pe.periodo_mes,1,'PRIMERA','SEGUNDA') quincena,nvl(pd.prima_produccion,0) primaProd,'B' descType,to_char(pe.fecha_pago,'mm')mes from tbl_pla_pago_liquidacion pd,tbl_pla_planilla pl,tbl_pla_planilla_encabezado pe where pd.cod_compania =");
	sbSql.append(compania);
	sbSql.append(" and pd.emp_id =");
	sbSql.append(cdo.getColValue("emp_id"));
	sbSql.append(" and trunc(pe.fecha_pago) <= to_date('");	
	sbSql.append(cdo.getColValue("fechaHasta"));	
	sbSql.append("','dd/mm/yyyy')  and trunc(pe.fecha_pago) >= to_date('");
	sbSql.append(cdo.getColValue("fechaDesde"));
	sbSql.append("','dd/mm/yyyy')  and pe.cod_planilla = pd.cod_planilla and pe.num_planilla = pd.num_planilla and pe.anio = pd.anio and pe.cod_compania =pd.cod_compania  and pl.cod_planilla = pe.cod_planilla and pl.compania = pe.cod_compania ");
	
	sbSql.append(" union all ");
	sbSql.append(" select  vac.anio_ac,vac.fecha_inicio as fecha_pago,vac.periodo_ac, vac.quincena_pago, pd.emp_id, pd.cod_planilla,pl.cod_concepto,to_char(to_date('01/'||lpad(round(nvl(vac.periodo_ac,0)/2),2,'0')||'/'||vac.anio_ac,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH')  descripcion, pd.num_empleado,0 as salario,0 as extra, 0 decimo,sum(nvl(valor_vac,0)-nvl(valor_libres,0)) as  vacacion,0 bonificacion,0 incentivo,0 otros_ingresos,0 gasto_rep, 0 ausencias, 0 tardanzas,0 otros_egresos, 0 otros, 0 seg_social, 0 seg_educativo, 0 imp_renta, 0 prima_antiguedad, 0 indemnizacion, 0 preaviso,0 sal_neto,0 sal_bruto, 0 otras_ded, 'N' planilla_mensual,'' quincena,0 primaProd,'A' descType,lpad(round(nvl(vac.periodo_ac,0)/2),2,'0') as mes from tbl_pla_pago_empleado pd, tbl_pla_planilla_encabezado pe, tbl_pla_planilla pl,tbl_pla_dist_dias_vac vac where pd.cod_compania = ");
	sbSql.append(compania);
	sbSql.append(" and pd.emp_id =");
	sbSql.append(cdo.getColValue("emp_id"));
	sbSql.append(" and trunc(vac.fecha_inicio) <= to_date('");	
	sbSql.append(cdo.getColValue("fechaHasta"));	
	sbSql.append("','dd/mm/yyyy') and trunc(vac.fecha_final) >= to_date('");
	sbSql.append(cdo.getColValue("fechaDesde"));
	sbSql.append("','dd/mm/yyyy') and vac.emp_id =pd.emp_id and vac.anio_pago=pd.anio and vac.status ='PR' and vac.quincena_pago=pd.num_planilla and pe.cod_planilla = pd.cod_planilla and pe.num_planilla = pd.num_planilla and pl.cod_planilla = pe.cod_planilla and pl.compania = pe.cod_compania and pe.anio = pd.anio and pe.cod_compania = pd.cod_compania group by vac.anio_ac,vac.fecha_inicio,vac.periodo_ac, vac.quincena_pago, pd.emp_id, pd.cod_planilla,pl.cod_concepto,pd.num_empleado order by 1 desc,2 desc,3 desc, 4 desc ) group by descripcion,mes,anio order by anio,mes");
	al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = mon;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 9;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		
		dHeader.addElement(".05");
		dHeader.addElement(".23");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		dHeader.addElement(".13");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		dHeader.addElement(".12");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(1);
	// titulos de columnas
	pc.setFont(7, 1);

	pc.setFont(10, 0);
	// lineas en blanco
	pc.addCols("",1,dHeader.size(),cHeight*10);
	// fecha de la carta
	pc.addCols(" ",0,1);
	pc.addCols(cdo.getColValue("fechaCarta"),0,dHeader.size()-1);
	// lineas en blanco
	pc.addCols(" ",1,dHeader.size(),cHeight*4);
	// dirigida a
	pc.addCols(" ",0,1);
	pc.addCols("Señores",0,dHeader.size()-1);
	pc.addCols(" ",0,1);
	pc.setFont(8, 0);
	pc.addCols(""+cdo.getColValue("destinatario1"),0,dHeader.size());
	pc.addCols(" ",0,1);
	pc.addCols(""+cdo.getColValue("destinatario2"),0,dHeader.size());
	pc.addCols(" ",0,1);
	pc.addCols(""+cdo.getColValue("destinatario3"),0,dHeader.size());
	
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size(),cHeight*2);
	pc.setFont(10,0);
	// saludo
	pc.addCols(" ",0,1);
	pc.addCols("Estimados Señores:",0,dHeader.size()-1);
	pc.addCols(" ",1,dHeader.size(),cHeight*2);
	pc.setFont(10,0);
	// cuerpo del a carta
	pc.addCols(" ",1,1);
	pc.addCols(" "+cdo.getColValue("certificacion"),0,dHeader.size()-1);
	//pc.addCols("",1,1);

	//****************** desglose ***********************
	// linea en blanco
	pc.addCols("",1,dHeader.size(),cHeight);
		pc.setFont(10,1);			
		pc.addCols(" ",0,1);
		pc.addBorderCols("MES",0,1);
		pc.addBorderCols("AÑO",1,1);
		pc.addBorderCols("S/REGULAR",2,1);
		pc.addBorderCols("EXTRA/O. ING",2,1);
		pc.addBorderCols("VACACION",2,1);
		pc.addBorderCols("AUSENCIAS/TARDANZAS",2,1);
		pc.addBorderCols("TOTAL",2,1);
				
	if (al.size()!=0)
	{
		for (int i=0; i<al.size(); i++)
		{
				CommonDataObject cdoD = (CommonDataObject) al.get(i);
				pc.setFont(10,0);
				pc.addCols(" ",0,1);
				pc.addBorderCols(cdoD.getColValue("descripcion"),0,1);
				pc.addBorderCols(cdoD.getColValue("anio"),1,1);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("salario")),2,1);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("extras")),2,1);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("vacacion")),2,1);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("ausencias")),2,1);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("total")),2,1);
						
				//
				/*pc.setFont(10,1);
				pc.addCols("",1,1);
				pc.addCols("SALARIO MENSUAL",0,2);
				pc.addCols("B/. "+CmnMgr.getFormattedDecimal(cdoD.getColValue("salario_mensual")),2,1);
				pc.addCols("",1,2);*/

				// desglose de vacaciones
				//sql ="select  a.fecha_inicio, to_char(a.fecha_inicio,'dd/mm/yyyy')||'    al   '||to_char(a.fecha_final,'dd/mm/yyyy')    periodo,  sum(nvl(a.valor_vac,0)-nvl(a.valor_libres,0))  total_vacacion  from   tbl_pla_dist_dias_vac a  where a.tiempo_concedido_dinero > 0  and  a.tiempo_concedido_dinero is not null  and a.emp_id ="+empId+"  and  a.cod_compania ="+compania+"  and a.anio_ac="+cdoD.getColValue("anio")+" and round(a.periodo_ac/2,0)="+cdoD.getColValue("mes")+"  and a.status ='PR' group by  a.fecha_inicio, to_char(a.fecha_inicio,'dd/mm/yyyy')||'    al   '||to_char(a.fecha_final,'dd/mm/yyyy')  order by a.fecha_inicio " ;
				//alV = SQLMgr.getDataList(sql);
				/*if (alV.size()!=0)
				{
						for (int k=0; k<alV.size(); k++)
						{
								CommonDataObject cdoV = (CommonDataObject) alV.get(k);
								pc.setFont(9,0);
								pc.addCols(" ",1,1);
								pc.addCols("VACACIONES      "+cdoV.getColValue("periodo"),0,2);
								pc.addCols("B/. "+CmnMgr.getFormattedDecimal(cdoV.getColValue("total_vacacion")),2,1);
								pc.addCols(" ",1,2);
						}
				}*/
				//pc.addCols("",1,dHeader.size(),cHeight*2);
				//totalDeduc   += Double.parseDouble(cdoD.getColValue("descuento_mensual"));
		}
	}


	// lineas en blanco
	pc.addCols(" ",1,dHeader.size());
	//Nota
	pc.addCols(" ",1,1);
	pc.addCols(" "+cdo.getColValue("observacion"),0,dHeader.size()-1);
	// lineas en blanco
	pc.addCols(" ",1,dHeader.size());
	// texto final carta
	pc.setFont(10,0);
	pc.addCols(" ",1,1);
	pc.addCols("En espera que la información brindada sea la solicitada por ustedes, queda de usted,",0,dHeader.size()-1);
	pc.addCols("",1,dHeader.size(),cHeight*2);
	// firma
	pc.setFont(10,0);
	pc.addCols(" ",1,1);
	pc.addCols("Atentamente,",0,dHeader.size()-1);
	pc.addCols(" ",1,dHeader.size(),cHeight*2);
	pc.addCols(" ",1,1);
	pc.addCols("Lic. "+cdo.getColValue("nombreEmpRepr"),0,dHeader.size()-1);
	pc.addCols(" ",1,1);
	pc.addCols(cdo.getColValue("cargoEmpRepr"),0,dHeader.size()-1);
	pc.addCols("",1,1);
	pc.setFont(10,1);
	pc.addCols(cdo.getColValue("patrono"),0,dHeader.size()-1);
	/*pc.addCols("",1,1);
	pc.setFont(10,0);
	pc.addCols("/"+userName,0,dHeader.size()-1);*/



	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

