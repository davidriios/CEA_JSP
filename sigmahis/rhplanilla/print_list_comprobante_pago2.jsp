<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>
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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();

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
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String userId = UserDet.getUserId();
String fg = request.getParameter("fg");
String secuencia = request.getParameter("secuencia");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
StringBuffer sbSql = new StringBuffer();


if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (secuencia == null) secuencia = "";
if (empId == null) empId = "";
if (mode == null) mode = "";

if(fg.trim().equals("AJ")){
	sbSql.append("select to_char(nvl(a.sal_bruto,0),'999,999,990.00') as salBruto, to_char(a.sal_neto,'999,999,990.00') as salNeto, to_char(nvl(a.ausencia,0),'999,999,990.00') as ausencia, to_char(nvl(a.seg_social,0)-nvl(a.seg_social_gasto,0),'999,990.00') as segSoc, to_char(nvl(a.seg_educativo,0),'999,990.00') as segEdu, to_char(nvl(a.imp_renta,0),'999,990.00') as impRen, to_char(nvl(a.fondo_com,0),'999,990.00') as fonCom, to_char(nvl(a.tardanza,0),'999,990.00') tardanza, to_char(nvl(a.otras_ded,00),'999,990.00') as otrasDed, to_char(nvl(a.total_ded,0) +  nvl(a.otros_egr,0),'999,999,990.00') as totDed, to_char(nvl(a.dev_multa,0),'999,990.00') as devMul, to_char(nvl(a.comision,0),'999,990.00'), to_char(nvl(a.gasto_rep,0),'99,999,990.00') as gasRep, to_char(nvl(a.ayuda_mortuoria,0),'999,990.00') as aMor, to_char(nvl(a.otros_ing,0),'999,999,990.00') as otrosIng, to_char(nvl(a.otros_egr,0),'999,999,990.00') as otrosEgr, to_char(a.alto_riesgo,'999,990.00') as altRiesgo, to_char(nvl(a.bonificacion,0),'999,990.00')bonificacion, to_char(nvl(a.extra,0),'999,999,990.00') as extra, to_char(nvl(a.prima_produccion,0),'999,999,990.00') as prima, to_char(nvl(a.indemnizacion,0),'99,999,990.00') indemnizacion, to_char(nvl(a.vacacion,0),'999,999,990.00')vacacion,to_char(nvl(a.pago_40porc,0),'999,999,990.00')pago_40porc,to_char(nvl(a.preaviso,0),'999,999,990.00')preaviso, to_char(nvl(a.xiii_mes,0),'999,999,990.00')decimo, to_char(nvl(a.prima_antiguedad,0),'999,999,990.00') primaAntiguedad,to_char(nvl(a.incentivo,0),'999,999,990.00')incentivo, 0 as aguiGas,to_char(nvl(a.tardanza,0),'999,999,990.00')tardanza, to_char(nvl(a.imp_renta_gasto,0),'999,990.00') as impRentaGasto, '' as cheque, to_char(nvl(a.seg_social_gasto,0),'999,990.00') as ssGasto, a.cod_planilla codigoPla, to_char((nvl(a.sal_bruto,0) + nvl(a.vacacion,0) + nvl(a.pago_40porc,0) + nvl(a.extra,0) + nvl(a.gasto_rep,0) + nvl(a.otros_ing,0) + nvl(a.otros_ing_fijos,0) + nvl(a.indemnizacion,0) + nvl(a.preaviso,0) + nvl(a.xiii_mes,0) + nvl(a.prima_antiguedad,0) + nvl(a.bonificacion,0) + nvl(a.incentivo,0) + nvl(a.prima_produccion,0)) - (nvl(a.ausencia,0) + nvl(a.tardanza,0)),'999,999,990.00')ingTot, 0 as salEsp, 0 as ssEsp, a.num_empleado as numEmpleado, to_char(a.num_cheque,'0000000') as numCheque, e.descripcion seccion, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd-mm-yyyy') as fechaInicial, b.cedula1 cedula, e.codigo, b.num_ssocial, to_char(c.fecha_final,'dd/mm/yyyy') as fechaFinal, c.estado, b.nombre_empleado as nomEmpleado, f.denominacion cargo, to_char(a.rata_hora,'999,990.00') as rataHora, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta, 'PLANILLA DE AJUSTES A - ' ||ltrim(d.nombre,18)||' del '||c.fecha_inicial||' al '||c.fecha_final as descripcion, b.num_cuenta, to_char(a.salario_base/2,'999,999,990.00') salarioBase from tbl_pla_pago_ajuste a, vw_pla_empleado b, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_pla_cargo f, tbl_sec_unidad_ejec e where a.emp_id = b.emp_id and a.cod_compania = b.compania and a.cod_compania = c.cod_compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and a.anio = c.anio and a.cod_compania = e.compania and nvl(b.seccion,b.ubic_seccion) = e.codigo and a.cod_compania = f.compania and b.cargo = f.codigo and a.num_planilla="+num+" and a.cod_planilla="+cod+" and a.anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.cod_compania=");
	sbSql.append( session.getAttribute("_companyId"));
if(!empId.trim().equals("")){sbSql.append(" and a.emp_id=");sbSql.append(empId);}
if(!secuencia.trim().equals("")){sbSql.append(" and a.secuencia=");	sbSql.append(secuencia);}

if(fg.trim().equals("AJ")&&!fp.trim().equals("CS"))sbSql.append(" and a.estado = 'PE'");
else if(fg.trim().equals("AJ")&& fp.trim().equals("CS"))sbSql.append(" and a.estado <> 'PE'");
if(mode.trim().equals("edit")){sbSql.append("  and a.acc_estado = 'N' and nvl(a.actualizar,'N') ='N' and a.vobo_estado ='N' ");}
 sbSql.append(" order by a.num_empleado,a.secuencia asc");
}else{
	sbSql.append("select to_char(a.sal_bruto,'999,999,990.00') as salBruto, to_char(a.sal_neto,'999,999,990.00') as salNeto, to_char(decode(a.salario_base,0,e.salario_base,nvl(a.sal_ausencia,0)+nvl(a.ausencia,0)+nvl(a.tardanza,0)),'999,999,990.00') salario_quinc, to_char(a.sal_ausencia,'999,999,990.00') as salAus, nvl(a.extra,00) extra, to_char(nvl(a.seg_social,0),'999,990.00') as segSoc, to_char(nvl(a.seg_educativo,0),'999,990.00') as segEdu, to_char(a.imp_renta,'999,990.00') as impRen, to_char(nvl(a.fondo_com,0),'999,990.00') as fonCom, to_char(nvl(a.tardanza,0),'999,990.00') tardanza, to_char(nvl(a.ausencia,0),'999,990.00') ausencia, nvl(a.otras_ded,0) as deduc, to_char(nvl(a.total_ded,0) + nvl(a.otros_egr,0),'999,999,990.00') as totDed, to_char(a.dev_multa,'999,990.00') as devMul, to_char(a.comision,'999,990.00'), to_char(nvl(a.gasto_rep,0),'99,999,990.00') as gasRep, to_char(nvl(a.ayuda_mortuoria,0),'999,990.00') as aMor, to_char(nvl(a.otros_ing,0),'999,999,990.00') as otroIng, to_char(nvl(a.otros_egr,0),'999,999,990.00') as otroEg, to_char(nvl(a.alto_riesgo,0),'999,990.00') as altRiesgo, to_char(nvl(a.bonificacion,0),'999,990.00'), to_char(nvl(a.extra,0),'999,999,990.00') as extra, to_char(nvl(a.prima_produccion,0),'999,999,990.00') as prima, to_char(nvl(a.aguinaldo_gasto,0),'999,990.00') as aguiGas, to_char(nvl(a.imp_renta_gasto,0),'999,990.00') as impGasto, a.cheque_pago as cheque, to_char(nvl(a.seg_social_gasto,0),'999,990.00') as ssGasto, to_char(to_number(nvl(a.sal_ausencia,0.00))+to_number(nvl(a.gasto_rep,0.00))+to_number(nvl(a.alto_riesgo,0.00)) + to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.bonificacion,0.00))+to_number(nvl(a.comision,0.00))+to_number(nvl(a.extra,0.00)) + to_number(nvl(a.otros_ing,0.00)),'999,999,990.00') as ingTot, to_char(to_number(nvl(a.alto_riesgo,0.00)) + to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.bonificacion,0.00))+to_number(nvl(a.comision,0.00))+to_number(nvl(a.extra,0.00)) + to_number(nvl(a.otros_ing,0.00)),'999,999,990.00') as ingTotComp, to_char(to_number(nvl(a.seg_educativo,0.00)) + to_number(nvl(a.otros_egr,0.00)) +to_number(nvl(a.otras_ded,0.00)),'999,999,990.00') as egrTotComp,to_char(nvl(a.salario_especie,0),'999,999,990.00') as salEsp, to_char(nvl(a.seg_social_especie,0),'999,990.00') as ssEsp, periodo_xiiimes as decimo, a.num_empleado as numEmpleado, to_char(a.num_cheque,'00000000000') as numCheque, f.descripcion seccion, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd/mm/yyyy') as fechaInicial, e.cedula1 cedula, f.codigo, e.num_ssocial, to_char(c.fecha_final,'dd/mm/yyyy') as fechaFinal, c.estado, e.nombre_empleado as nomEmpleado, g.denominacion cargo, to_char(nvl(a.rata_hora,0),'999,990.00') as rataHora, e.tipo_renta||'-'||to_char(e.num_dependiente,'990') as tipoRenta, ltrim(d.nombre,18)||' del '||to_char(c.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(c.fecha_final,'dd/mm/yyyy') as descripcion, e.num_cuenta, to_char(a.salario_base/2,'999,999,990.00') salarioBase, e.emp_id, round(MONTHS_BETWEEN (to_date(c.fecha_final,'dd/mm/yyyy') , to_date(e.fecha_ingreso,'dd/mm/yyyy')) * 1.5  ) as vac, a.cod_planilla codigoPla from tbl_pla_pago_empleado a, vw_pla_empleado e, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_pla_cargo g, tbl_sec_unidad_ejec f where a.emp_id = e.emp_id and a.cod_compania = e.compania and a.cod_compania = c.cod_compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and a.anio = c.anio and a.cod_compania = f.compania and nvl(e.seccion,e.ubic_seccion) = f.codigo and a.cod_compania = g.compania and e.cargo = g.codigo  and a.num_planilla=");
	sbSql.append(num);
	sbSql.append(" and a.cod_planilla=");
	sbSql.append(cod);
	sbSql.append(" and a.anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.cod_compania=");
sbSql.append(session.getAttribute("_companyId"));
if(!empId.trim().equals("")){sbSql.append(" and a.emp_id=");sbSql.append(empId);}

sbSql.append(appendFilter);
sbSql.append(" order by f.codigo ,nomEmpleado asc");

}
al = SQLMgr.getDataList(sbSql.toString());

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

	float width = 72 * 8.5f;//612
	float height = 396;//72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "PLANILLA DE AJUSTE ";
	String xtraSubtitle = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();	
		dHeader.addElement(".24");
		dHeader.addElement(".10");	
		dHeader.addElement(".15");
		dHeader.addElement(".05");
		dHeader.addElement(".24");
		dHeader.addElement(".11");
		dHeader.addElement(".11");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	//table body
	for (int i=0; i<al.size(); i++)
	{
		
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
	 
				pc.setFont(9, 1);
					pc.addCols("Depto :  "+cdo1.getColValue("codigo")+"  "+cdo1.getColValue("seccion"),0,dHeader.size());
				
					pc.addCols(""+cdo1.getColValue("numEmpleado")+"    "+cdo1.getColValue("nomEmpleado"),0,5);
					pc.addCols("Cédula :"+cdo1.getColValue("cedula"),0,2);
					
					pc.setFont("COURIER",9, 0, Color.gray);				
					pc.addCols(" ", 0,dHeader.size());
					
					pc.setFont("COURIER",9, 0, Color.gray);				
					pc.addCols(" ", 0,dHeader.size());
					
					pc.setFont("COURIER",9, 0, Color.gray);					
					pc.addCols("COMPROBANTE DE PAGO", 0,dHeader.size());
					
					pc.setFont("COURIER",9, 0, Color.gray);
					pc.addCols(""+cdo1.getColValue("descripcion"),1,dHeader.size());
				
					pc.addCols("# DE EMPLEADO  :"+cdo1.getColValue("numEmpleado"),1,1);
					//pc.addCols(" "+cdo1.getColValue("seccion"),1,4);		
					pc.addCols(""+cdo1.getColValue("nomEmpleado"),1,3);											
					pc.addCols("FECHA PAGO :"+cdo1.getColValue("fechaPago"),1,3);
				
				
					pc.addCols(" ",1,1);
					pc.addCols(" "+cdo1.getColValue("seccion") +"  -  "+cdo1.getColValue("cargo"),1,4);													
					pc.addCols(" ",1,2);
					
					pc.addCols("ClAVE DE RENTA  :"+cdo1.getColValue("tipoRenta"),1,1);
					pc.addCols("RATA X HORA  :"+cdo1.getColValue("rataHora"),1,2);	
					pc.addCols("CUENTA :"+cdo1.getColValue("num_cuenta"),1,2);												
					pc.addCols("# CK/TAL :"+cdo1.getColValue("numCheque"),1,2);
					
					pc.addBorderCols("* * * * I N G R E S O S  * * * * ",1,4);
					pc.addBorderCols("* * * *  E G R E S O S * * * * ",1,3);													
				
					pc.setFont("COURIER",9, 0, Color.gray);	
					
					if(fg.trim().equals("DEC")||fg.trim().equals("AJ"))pc.addCols("SALARIO REGULAR",0,1);
					else if(fg.trim().equals("INC"))pc.addCols("MONTO PAGADO",0,1);
					else pc.addCols("SUELDO BASE",0,1);
					
					if(fg.trim().equals("QUIN"))
					 pc.addCols(" "+cdo1.getColValue("salario_quinc"),2,2);	
					else pc.addCols(" "+cdo1.getColValue("salBruto"),2,2);
					
										
					pc.addCols(" ",1,1);
					pc.addCols("IMPUESTO SOBRE LA RENTA",0,1);
					pc.addCols(" "+cdo1.getColValue("impRen"),2,1);													
					pc.addCols(" ",1,1);
				
					pc.addCols("GASTO DE REPRESENTACION",0,1);
					pc.addCols(" "+cdo1.getColValue("gasRep"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("SEGURO SOCIAL",0,1);
					pc.addCols(" "+cdo1.getColValue("segSoc"),2,1);													
					pc.addCols(" ",1,1);
					
if(!fg.trim().equals("INC") && !fg.trim().equals("DEC")&& !fg.trim().equals("AJ")){
				
sql= "select 1 orden, sum(a.cantidad) cantidad, nvl(to_char(sum(decode(a.accion,'DS',a.monto*-1,a.monto)),'9999999990.00'),0)  monto, a.motivo_falta the_codigo, a.emp_id, substr(t.descripcion,1,28) descripcion from tbl_pla_aus_y_tard a , tbl_pla_motivo_falta t where a.compania =   "+(String) session.getAttribute("_companyId")+" and a.anio_des ="+anio+ " and a.quincena_des = "+num+" and a.cod_planilla_des = "+cod+" and a.emp_id="+cdo1.getColValue("emp_id")+" and a.motivo_falta = t.codigo and a.vobo_estado = 'S' group by a.emp_id, a.motivo_falta,t.descripcion ";
  sql += " union ";
	sql += "select  2 orden, sum(a.cantidad_aprob) cantidad, to_char(sum(nvl(a.monto,0)),'999999990.00') monto, a.the_codigo, a.emp_id,substr(decode(t.codigo,'20','HORAS NO DESCANSAD','21','TRABAJO EN DOMINGO','22','RECARGO 0.50','23','TRABAJO EN DÍA NACIONAL','24','COMPENSATORIO HORAS REG','25','HORAS NO DESCANSADAS 0.50','26','SOBRET.EN DIA LIBRE 1.50','27','INCAPACIDAD','28','INCAPACIDAD','29','REPOSICION DE HORAS','Horas Extra '||to_char(t.factor_multi,'990.00')),1,28) descripcion from tbl_pla_t_extraordinario a,tbl_pla_t_horas_ext t  where a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pag ="+anio+ " and a.quincena_pag = "+num+" and a.cod_planilla_pag = "+cod+" and a.emp_id="+cdo1.getColValue("emp_id")+" and a.the_codigo = t.codigo and the_codigo not in ('24','27','28') and a.vobo_estado = 'S' group by a.emp_id, a.the_codigo, decode(t.codigo,'20','HORAS NO DESCANSAD','21','TRABAJO EN DOMINGO','22','RECARGO 0.50','23','TRABAJO EN DÍA NACIONAL','24','COMPENSATORIO HORAS REG','25','HORAS NO DESCANSADAS 0.50','26','SOBRET.EN DIA LIBRE 1.50','27','INCAPACIDAD','28','INCAPACIDAD','29','REPOSICION DE HORAS','Horas Extra '||to_char(t.factor_multi,'990.00'))";
	sql += " union ";
	sql += "select  3 orden, sum(a.cantidad) cantidad, to_char(sum(nvl(a.monto,0)),'999999990.00') monto, a.tipo_trx, a.emp_id,substr(t.descripcion,1,28) descripcion from tbl_pla_transac_emp a,tbl_pla_tipo_transaccion t  where a.compania = t.compania and a.tipo_trx = t.codigo and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pago ="+anio+" and a.quincena_pago = "+num+" and a.cod_planilla_pago = "+cod+" and a.emp_id="+cdo1.getColValue("emp_id")+" and a.vobo_estado = 'S' and a.accion = 'PA' group by a.emp_id, a.tipo_trx, t.descripcion order by 1 ";
	

	alExtra = SQLMgr.getDataList(sql);

sql = "select 1 orden, 0 cantidad, '"+cdo1.getColValue("segEdu")+"' monto, 1 as cod_acreedor,"+cdo1.getColValue("emp_id")+", 'SEGURO EDUCATIVO'  descripcion from  dual";
sql += " union ";
sql += "select 2 orden, 1 cantidad, to_char(abs(nvl(a.monto,0)),'9999990.00') monto, a.cod_acreedor, a.emp_id, substr(ac.nombre_corto,1,24) descripcion from  tbl_pla_acreedor ac, tbl_pla_descuento_aplicado a, tbl_pla_descuento ds where a.anio = "+anio+" and  a.cod_planilla  = "+cod+" and a.num_planilla = "+num+" and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = ds.emp_id and a.emp_id="+cdo1.getColValue("emp_id")+" and ac.cod_acreedor = a.cod_acreedor and ac.compania = a.cod_compania and a.num_descuento = ds.num_descuento and  a.cod_compania  = ds.cod_compania ";
sql += " union ";
	sql += "select  3 orden, sum(a.cantidad) cantidad, to_char(sum(nvl(a.monto,0)),'999999990.00') monto, a.tipo_trx, a.emp_id, substr(t.descripcion,1,24) descripcion from tbl_pla_transac_emp a,tbl_pla_tipo_transaccion t  where a.compania = t.compania and a.tipo_trx = t.codigo and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pago ="+anio+" and a.quincena_pago = "+num+" and a.cod_planilla_pago = "+cod+" and a.emp_id="+cdo1.getColValue("emp_id")+" and a.vobo_estado = 'S' and a.accion = 'DE' group by a.emp_id, a.tipo_trx, t.descripcion order by 1 ";
  alDesc = SQLMgr.getDataList(sql);

		
				double totExtra=0.00,totDesc=0.00;
				int listSize=13;
		
				
				if(alExtra.size()==0 && alDesc.size()==0){
				System.out.println("Nada que hacer");
				}else{
				for(int extraI=0;extraI<listSize;extraI++){
				CommonDataObject cdoExtra=null,cdoDesc=null;
				if(extraI<alExtra.size()) {cdoExtra=(CommonDataObject) alExtra.get(extraI); 
				totExtra+=Double.parseDouble(cdoExtra.getColValue("monto"));
				}
				if(extraI<alDesc.size())  {cdoDesc=(CommonDataObject) alDesc.get(extraI); 
				totDesc+=Double.parseDouble(cdoDesc.getColValue("monto")) ; }
				//if(extraI>=alExtra.size() && extraI>=alDesc.size()) break;
				
				if(alExtra.size() > 0)if(extraI<alExtra.size()) {cdoExtra=(CommonDataObject) alExtra.get(extraI); totExtra+=Double.parseDouble(cdoExtra.getColValue("monto"));}
				if(alDesc.size() > 0)if(extraI<alDesc.size())  {cdoDesc=(CommonDataObject) alDesc.get(extraI); totDesc+=Double.parseDouble(cdoDesc.getColValue("monto")); }
				
 					pc.addCols((cdoExtra==null) ? " ":cdoExtra.getColValue("descripcion"),0,1);
					pc.addCols((cdoExtra==null) ? " ":cdoExtra.getColValue("cantidad"),2,1);		
					pc.addCols((cdoExtra==null) ? " ":cdoExtra.getColValue("monto"),2,1);													
					pc.addCols(" ",1,1);
					pc.addCols((cdoDesc==null) ? " ":cdoDesc.getColValue("descripcion"),0,1);
					pc.addCols((cdoDesc==null) ? " ":cdoDesc.getColValue("monto"),2,1);												
					pc.addCols(" ",1,1);
					
 				} // for ends here
				}//else ends here
				totExtra = Double.parseDouble(cdo1.getColValue("ingTotComp").replace(",","")) - Double.parseDouble(cdo1.getColValue("ausencia").replace(",","")) - Double.parseDouble(cdo1.getColValue("tardanza").replace(",","")) - totExtra;
				totDesc = Double.parseDouble(cdo1.getColValue("egrTotComp").replace(",","")) - totDesc;
				if(alExtra.size()>listSize || alDesc.size()>listSize){
 					
					pc.addCols("OTROS INGRESOS",0,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal("999,999,990.00",totExtra),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("OTROS EGRESOS",0,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal("999,999,990.00",totDesc),2,1);													
					pc.addCols(" ",1,1);
 				}
			}
				if(fg.trim().equals("INC")||fg.trim().equals("DEC")){
				
 					pc.addCols(" ",0,1);
					pc.addCols(" " ,2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("SEGURO EDUCATIVO",0,1);
					pc.addCols(" "+cdo1.getColValue("segEdu"),2,1);													
					pc.addCols(" ",1,1);
 
 					pc.addCols("OTROS INGRESOS",0,1);
					pc.addCols(""+cdo1.getColValue("otroIng"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("OTROS EGRESOS",0,1);
					pc.addCols(" "+cdo1.getColValue("otroEg"),2,1);													
					pc.addCols(" ",1,1);
			}	
				if(fg.trim().equals("AJ")){
					pc.addCols("AUSENCIA",0,1);
					pc.addCols(" "+cdo1.getColValue("ausencia"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("SEGURO EDUC.",0,1);
					pc.addCols(" "+cdo1.getColValue("segEdu"),2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("TARDANZAS",0,1);
					pc.addCols(" "+cdo1.getColValue("tardanza"),2,2);													
					pc.addCols("",1,1);
					pc.addCols("IMP. SOBRE LA RENTA GASTO",0,1);
					pc.addCols(" "+cdo1.getColValue("impRentaGasto"),2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("SOBRETIEMPO",0,1);
					pc.addCols(" "+cdo1.getColValue("extra"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("OTROS EGRESOS",0,1);
					pc.addCols(" "+cdo1.getColValue("otrosEgr"),2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("OTROS INGRESOS",0,1);
					pc.addCols(" "+cdo1.getColValue("otrosIng"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("OTRAS DED.",0,1);
					pc.addCols(" "+cdo1.getColValue("otrasDed"),2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("VACACIONES",0,1);
					pc.addCols(" "+cdo1.getColValue("vacacion"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("SEGURO SOCIAL GASTO REP.",0,1);
					pc.addCols(" "+cdo1.getColValue("ssGasto"),2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("XIII MES",0,1);
					pc.addCols(""+cdo1.getColValue("decimo"),2,2);													
					pc.addCols("",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("PRIMA DE PRODUCCIÓN",0,1);
					pc.addCols(" "+cdo1.getColValue("prima"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("BONIFICACIÓN",0,1);
					pc.addCols(" "+cdo1.getColValue("bonificacion"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("INCENTIVO",0,1);
					pc.addCols(" "+cdo1.getColValue("incentivo"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("INDEMNIZACION",0,1);
					pc.addCols(" "+cdo1.getColValue("indemnizacion"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("PREAVISO",0,1);
					pc.addCols(" "+cdo1.getColValue("preaviso"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("40% DE SALARIO",0,1);
					pc.addCols(" "+cdo1.getColValue("pago_40porc"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
					pc.addCols("PRIMA ANTIGUEDAD",0,1);
					pc.addCols(" "+cdo1.getColValue("primaAntiguedad"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols(" ",0,1);
					pc.addCols(" ",2,1);													
					pc.addCols(" ",1,1);
					
			}
					
					
					pc.addCols("TOTAL DE INGRESOS",2,1);
					pc.addCols(" "+cdo1.getColValue("ingTot"),2,2);													
					pc.addCols(" ",1,1);
					pc.addCols("TOTAL DE EGRESOS",2,1);
					pc.addCols(" "+cdo1.getColValue("totDed"),2,1);													
					pc.addCols(" ",1,1);
					
					pc.setFont("COURIER",9, 0, Color.gray);
					pc.addCols("SALARIO NETO ==",2,6);
					pc.addCols(" "+cdo1.getColValue("salNeto"),1,1);													
				
					//pc.setFont("COURIER",9, 0 ,Color.gray);
					//pc.addCols(" ",2,7);
				
				
					//pc.setFont("COURIER",9, 0, Color.gray);
					//pc.addCols("NOTA : *** Metas Internacionales de Seguridad del Paciente ***",1,7);
			 
			 	
				
				if(empId.trim().equals("") && secuencia.trim().equals("")){
				pc.flushTableBody(true);	
				pc.addNewPage(); 
				}
					
					
			
		
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	 pc.flushTableBody(true);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
