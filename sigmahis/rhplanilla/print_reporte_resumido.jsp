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
PLANILLA: PLA0124
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTotXdir= new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
StringBuffer sql = new StringBuffer();

String _option = request.getParameter("opt");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

String subTitle = "";
String mesDesc ="";
if (mes == null)mes="";
if (fg == null)fg="";
if (fp == null)fp="";
if (!mes.trim().equals("")){
if (mes.trim().equals("01"))mesDesc = "ENERO";
if (mes.trim().equals("02"))mesDesc = "FEBRERO";
if (mes.trim().equals("03"))mesDesc = "MARZO";
if (mes.trim().equals("04"))mesDesc = "ABRIL";
if (mes.trim().equals("05"))mesDesc = "MAYO";
if (mes.trim().equals("06"))mesDesc = "JUNIO";
if (mes.trim().equals("07"))mesDesc = "JULIO";
if (mes.trim().equals("08"))mesDesc = "AGOSTO";
if (mes.trim().equals("09"))mesDesc = "SEPTIEMBRE";
if (mes.trim().equals("10"))mesDesc = "OCTUBRE";
if (mes.trim().equals("11"))mesDesc = "NOVIEMBRE";
if (mes.trim().equals("12"))mesDesc = "DICIEMBRE";
}
if (fg == null || fg.equals("")) throw new Exception("La opción de impresión no es válida!");
if (anio == null || anio.equals("") || mes == null || mes.equals("")) throw new Exception("El año o el mes no es válido!");

if (fg.equalsIgnoreCase("RES"))subTitle = "INFORME DE ACUMULADOS";
else if (fg.equalsIgnoreCase("DET"))subTitle = "INFORME DE ACUMULADOS - DETALLADO";
else if (fg.equalsIgnoreCase("RES2"))subTitle = "ACUMULADOS DE SALARIOS MENSUAL PARA GERENCIA GENERAL";


sql.append("select z.* from (select x.type");
if (!fp.trim().equals("SEC"))sql.append(", x.dpto_desc, x.sec_desc, x.depto, x.seccion ");
else sql.append(", ''dpto_desc, x.sec_desc, '' depto, x.seccion ");
sql.append(",(sum( x.sal_bruto)+sum(nvl(x.ausencia,0)+nvl(x.tardanza,0)+nvl(x.otros_egr,0))) sal_bruto, sum(x.extra) extra, sum(x.otros_ing) otros_ing, sum(x.decimo) decimo, sum(x.vacaciones) vacaciones, sum(x.preaviso) preaviso, sum(x.indemnizacion) indemnizacion, sum(x.gasto_rep) gasto_rep, sum(x.prima_produccion) prima_produccion, sum(x.incentivo) incentivo, sum(x.bonificacion) bonificacion, sum(x.participacion) participacion, sum(x.prima_antiguedad) prima_antiguedad, sum(x.sal_bruto+x.extra+x.otros_ing+x.decimo+x.vacaciones+x.preaviso+x.indemnizacion+x.gasto_rep+x.participacion+x.prima_antiguedad+nvl(x.bonificacion,0)+nvl(x.incentivo,0)) subtotal, -sum(nvl(x.ausencia,0)+nvl(x.tardanza,0)+nvl(x.otros_egr,0))otrosEgresos");
if (fg.equalsIgnoreCase("DET"))sql.append(",x.num_empleado,x.cedula,x.nombre_empleado ");
 sql.append(" from (select 'A' type, ae.anio anio, '-' t_mes, em.provincia, em.sigla, em.tomo, em.asiento, ae.num_empleado,em.cedula1 cedula,em.nombre_empleado,em.compania, em.ubic_depto depto , d.descripcion dpto_desc,s.descripcion sec_desc,  em.ubic_seccion seccion, (nvl(ae.sal_bruto,0)-(nvl(ae.decimo,0)+ nvl(ae.bonificacion,0)+ nvl(ae.participacion_utilidades,0)+ nvl(ae.incentivo,0)+ nvl(ae.vacaciones,0)+nvl(ae.otros_ing,0)+nvl(ae.otros_ing_fijos,0)+nvl(ae.alto_riesgo,0)+ nvl(ae.prima_antiguedad,0)+ nvl(ae.indemnizacion,0)+nvl(ae.preaviso,0)+ nvl(ae.extra,0))) sal_bruto, nvl(ae.extra,0) extra, nvl(ae.otros_ing,0)+nvl(ae.alto_riesgo,0) otros_ing, nvl(ae.decimo,0) decimo, nvl(ae.vacaciones,0)vacaciones, nvl(ae.preaviso,0)preaviso, nvl(ae.indemnizacion,0)  indemnizacion, nvl(ae.g_representacion,0)-nvl(ae.decimo_gasto_rep,0) gasto_rep, nvl(ae.prima_produccion,0) prima_produccion, nvl(ae.incentivo,0) incentivo, nvl(ae.bonificacion,0)bonificacion,nvl(ae.participacion_utilidades,0)participacion, nvl(ae.prima_antiguedad,0) prima_antiguedad, to_char(ae.periodos) periodos ,nvl(ae.ausencia,0)ausencia,nvl(ae.tardanza,0)tardanza,nvl(ae.otros_egr,0)otros_egr from vw_pla_empleado em, tbl_pla_acumulado_empleado ae, tbl_sec_unidad_ejec d , tbl_sec_unidad_ejec s where em.emp_id = ae.emp_id and em.compania = ae.cod_compania and ae.anio = ");
sql.append(anio);
sql.append(" and  ae.cod_compania= ");
sql.append(compania);
sql.append(" and ((  em.estado = 3 ) or (  em.estado <> 3 and (  em.fecha_egreso is null  or to_number(to_char(em.fecha_egreso,'YYYY'))<= ");
sql.append(anio);
sql.append("))) and em.ubic_depto = d.codigo and em.ubic_seccion = s.codigo and d.compania = em.compania and s.compania = em.compania )x  group by x.type,x.sec_desc,x.seccion ");
if (!fp.trim().equals("SEC"))sql.append(",x.dpto_desc,x.depto ");
if (fg.equalsIgnoreCase("DET"))sql.append(",x.num_empleado,x.cedula,x.nombre_empleado ");

sql.append(" union all ");
sql.append("select y.type ");
if (!fp.trim().equals("SEC"))sql.append(",y.dpto_desc, y.sec_desc, y.ubic_depto, y.unidad ");
else sql.append(", '' dpto_desc, y.sec_desc, '' ubic_depto, y.unidad ");
sql.append(",  (sum( y.sal_bruto)+sum(nvl(y.ausencia,0)+nvl(y.tardanza,0)+nvl(y.otros_egr,0))),sum(y.extras) ,sum(y.otros_ing), sum(y.decimo), sum(y.vacaciones), sum(y.preaviso),sum(y.indemnizacion) indemnizacion, sum(y.gasto_rep) gasto_rep, sum(y.prima_produccion) prima_produccion, sum(y.incentivo) incentivo, sum(y.bonificacion) bonificacion, sum(y.participacion) participacion, sum(y.prima_antiguedad) prima_antiguedad, sum(y.sal_bruto+y.extras+y.otros_ing+y.decimo+y.vacaciones+y.preaviso+y.indemnizacion+y.gasto_rep+y.prima_produccion+y.incentivo+bonificacion+y.participacion+y.prima_antiguedad) tot,-sum(nvl(y.ausencia,0)+nvl(y.tardanza,0)+nvl(y.otros_egr,0))otrosEgresos");
if (fg.equalsIgnoreCase("DET"))sql.append(",y.num_empleado,y.cedula,y.nombre_empleado ");

sql.append(" from( select 'M' type,te.anio, to_char(te.mes), te.provincia  , te.sigla , te.tomo , te.asiento , te.num_empleado, e.cedula1 cedula , e.ubic_depto ubic_depto,d.descripcion dpto_desc,s.descripcion sec_desc,te.unidad unidad,(nvl(te.sal_bruto,0))-(nvl(te.ausencias,0)+nvl(te.tardanzas,0)+nvl(te.otros_egresos,0)) sal_bruto, nvl(te.horas_extras,0) extras, nvl(te.otros_ingresos,0) otros_ing,  nvl(te.xiii_mes,0) decimo, nvl(te.vacaciones,0) vacaciones, nvl(te.preaviso,0) preaviso, nvl(te.indemnizacion,0) indemnizacion, nvl(te.gasto_rep,0) gasto_rep ,nvl(te.prima_produccion,0)prima_produccion , nvl(te.incentivo,0) incentivo, nvl(te.bonificacion,0) bonificacion , nvl(te.participacion_utilidades,0) participacion, nvl(te.prima_antiguedad,0) prima_antiguedad,'0',nvl(te.ausencias,0)ausencia,nvl(te.tardanzas,0)tardanza,nvl(te.otros_egresos,0)otros_egr,e.nombre_empleado from tbl_pla_acumulado_mensual  te,vw_pla_empleado e, tbl_sec_unidad_ejec s, tbl_sec_unidad_ejec d where te.cod_compania = ");
sql.append(compania);
sql.append(" and te.anio = ");
sql.append(anio);
sql.append(" and te.mes = ");
sql.append(mes);
sql.append(" and e.emp_id = te.emp_id and e.compania = te.cod_compania and s.codigo = te.unidad and d.codigo = e.ubic_depto and d.compania = te.cod_compania and s.compania = te.cod_compania )y group by y.type,y.sec_desc,y.unidad ");
if (!fp.trim().equals("SEC"))sql.append(",y.dpto_desc,y.ubic_depto ");
if (fg.equalsIgnoreCase("DET")){sql.append(",y.num_empleado,y.cedula,y.nombre_empleado ");
	 sql.append(" order by  4 asc, 5 asc, 21 asc, 1 desc");}
else sql.append(" order by  4 asc, 5 asc, 1 desc");
sql.append(" )z /*where z.sal_bruto <> 0 */ ");

if (fg.equalsIgnoreCase("DET")) sql.append(" order by  4 asc, 5 asc, 21 asc, 1 desc");
else sql.append(" order by  4 asc, 5 asc, 1 desc");

if (fg.equalsIgnoreCase("RES2"))
{
	sql= new StringBuffer();
sql.append("select y.type ,y.dpto_desc,y.unidad depto,(sum( y.sal_bruto)+sum(nvl(y.ausencia,0)+nvl(y.tardanza,0)+nvl(y.otros_egr,0)))sal_bruto,sum(y.extras)extra ,sum(y.otros_ing)otros_ing, sum(y.decimo)decimo, sum(y.vacaciones)vacaciones, sum(y.preaviso)preaviso,sum(y.indemnizacion) indemnizacion, sum(y.gasto_rep) gasto_rep, sum(y.prima_produccion) prima_produccion, sum(y.incentivo) incentivo, sum(y.bonificacion) bonificacion, sum(y.participacion) participacion, sum(y.prima_antiguedad)prima_antiguedad, sum(y.sal_bruto+y.extras+y.otros_ing+y.decimo+y.vacaciones+y.preaviso+y.indemnizacion+y.gasto_rep+y.prima_produccion+y.incentivo+bonificacion+y.participacion+y.prima_antiguedad) subtotal,sum(nvl(y.ausencia,0)+nvl(y.tardanza,0)+nvl(y.otros_egr,0))otrosEgresos from( select 'M' type,te.anio, to_char(te.mes), te.provincia  , te.sigla , te.tomo , te.asiento , te.num_empleado, e.cedula1 cedula ,d.descripcion dpto_desc,te.unidad unidad,(nvl(te.sal_bruto,0))-(nvl(te.ausencias,0)+nvl(te.tardanzas,0)+nvl(te.otros_egresos,0)) sal_bruto, nvl(te.horas_extras,0) extras, nvl(te.otros_ingresos,0) otros_ing, nvl(te.xiii_mes,0) decimo, nvl(te.vacaciones,0) vacaciones, nvl(te.preaviso,0) preaviso, nvl(te.indemnizacion,0) indemnizacion, nvl(te.gasto_rep,0) gasto_rep ,nvl(te.prima_produccion,0)prima_produccion , nvl(te.incentivo,0) incentivo, nvl(te.bonificacion,0) bonificacion , nvl(te.participacion_utilidades,0) participacion, nvl(te.prima_antiguedad,0) prima_antiguedad,'0',nvl(te.ausencias,0)ausencia,nvl(te.tardanzas,0)tardanza,nvl(te.otros_egresos,0)otros_egr,e.nombre_empleado from tbl_pla_acumulado_mensual  te,vw_pla_empleado e, tbl_sec_unidad_ejec d where te.cod_compania =");
sql.append(compania);
sql.append(" and te.anio = ");
sql.append(anio);
sql.append(" and te.mes = ");
sql.append(mes);
sql.append(" and e.emp_id = te.emp_id and e.compania = te.cod_compania and d.codigo = te.unidad and d.compania = te.cod_compania  )y group by y.type , y.unidad ,y.dpto_desc  order by  3 ");
}
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
	float bottomMargin = 8.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = subTitle;
	String xtraSubtitle = "CORRESPONDIENTE AL MES DE "+mesDesc+" DE "+anio ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	if(fg.trim().equals("DET")){
	dHeader.addElement(".33");
	dHeader.addElement(".05");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".08");}
	else{
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
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	}

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

		 String groupDepto = "";
		 String groupSeccion = "",groupBy1= "";
		 String descDepto = "";
		 String descSec = "";
		 String groupByEmp = "";
		 double salRegularDepto = 0.0, extraDepto = 0.0, otrosIngDepto =0.0,decimoDepto=0.0,vacacionesDepto=0.0,preavisoDepto=0.0,indemDepto=0.0,gatoRepDepto=0.0;
		 double primaProdDepto = 0.0, incentivoDepto = 0.0, bonifDepto =0.0,primaAntDepto =0.0, otrosEgrDepto=0.0,subTotalDepto=0.0;
		 double salRegularDeptoAn = 0.0, extraDeptoAn = 0.0, otrosIngDeptoAn =0.0,decimoDeptoAn=0.0,vacacionesDeptoAn=0.0,preavisoDeptoAn=0.0,indemDeptoAn=0.0,gatoRepDeptoAn=0.0;
		 double primaProdDeptoAn = 0.0, incentivoDeptoAn = 0.0, bonifDeptoAn =0.0,primaAntDeptoAn =0.0, otrosEgrDeptoAn=0.0,subTotalDeptoAn=0.0;

		 double salRegularSec = 0.0, extraSec = 0.0, otrosIngSec =0.0,decimoSec=0.0,vacacionesSec=0.0,preavisoSec=0.0,indemSec=0.0,gatoRepSec=0.0;
		 double primaProdSec = 0.0, incentivoSec = 0.0, bonifSec =0.0,primaAntSec =0.0, otrosEgrSec=0.0,subTotalSec=0.0;
		 double salRegularSecAn = 0.0, extraSecAn = 0.0, otrosIngSecAn =0.0,decimoSecAn=0.0,vacacionesSecAn=0.0,preavisoSecAn=0.0,indemSecAn=0.0,gatoRepSecAn=0.0;
		 double primaProdSecAn = 0.0, incentivoSecAn = 0.0, bonifSecAn =0.0,primaAntSecAn =0.0, otrosEgrSecAn=0.0,subTotalSecAn=0.0;

		 double salRegularF = 0.0, extraF = 0.0, otrosIngF =0.0,decimoF=0.0,vacacionesF=0.0,preavisoF=0.0,indemF=0.0,gatoRepF=0.0;
		 double primaProdF = 0.0, incentivoF = 0.0, bonifF =0.0,primaAntF =0.0, otrosEgrF=0.0,subTotalF=0.0;
		 double salRegularAnF = 0.0, extraAnF = 0.0, otrosIngAnF =0.0,decimoAnF=0.0,vacacionesAnF=0.0,preavisoAnF=0.0,indemAnF=0.0,gatoRepAnF=0.0;
		 double primaProdAnF = 0.0, incentivoAnF = 0.0, bonifAnF =0.0,primaAntAnF =0.0, otrosEgrAnF=0.0,subTotalAnF=0.0;

		 String groupTot = "";


		pc.addCols(" ",1,dHeader.size());
		if(fg.trim().equals("DET")) pc.addCols("Empleado",2,1);
		pc.addCols(" ",2,1);
		pc.addCols("Sueldo Regular",2,1);
		pc.addCols("Sueldo Extra",2,1);
		pc.addCols("Otros ing.",2,1);
		pc.addCols("XIII Mes",2,1);
		pc.addCols("Vacaciones",2,1);
		pc.addCols("Preaviso",2,1);
		pc.addCols("Idemnización",2,1);
		pc.addCols("Gastos Rep.",2,1);
		pc.addCols("Prima Producc.",2,1);
		pc.addCols("Incentivo",2,1);
		pc.addCols("Bonificación",2,1);
		pc.addCols("Prima Antigu.",2,1);
		pc.addCols("Otros Egr.",2,1);
		pc.addCols("Subtotal",2,1);

		pc.addCols("===================================================================================================================================================================================================================================================",1,dHeader.size());

		pc.setTableHeader(4);

		for ( int i = 0; i<al.size();i++){

		   cdo = (CommonDataObject)al.get(i);

		 	if(!fp.trim().equals("SEC")) groupBy1=cdo.getColValue("seccion")+"-"+cdo.getColValue("depto");
			else groupBy1= cdo.getColValue("seccion");

		   if ( !groupSeccion.equals(groupBy1) && !fg.equalsIgnoreCase("RES2")){
			if ( i!=0)
			{
				pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
				pc.setFont(8,1,Color.blue);
				pc.addCols("               *** TOTALES PARA: "+descSec+" ***",0,dHeader.size());
				pc.setFont(8,1);
				if(fg.trim().equals("DET"))pc.addCols("M",2,2);
				else pc.addCols("M",2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(salRegularSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(extraSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosIngSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(decimoSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(vacacionesSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(preavisoSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(indemSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(gatoRepSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaProdSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(incentivoSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(bonifSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaAntSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(subTotalSec),2,1);

				if(fg.trim().equals("DET"))pc.addCols("A",2,2);
				else pc.addCols("A",2,1);

				pc.addCols(CmnMgr.getFormattedDecimal(salRegularSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(extraSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosIngSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(decimoSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(vacacionesSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(preavisoSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(indemSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(gatoRepSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaProdSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(incentivoSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(bonifSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaAntSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(subTotalSecAn),2,1);

			   salRegularSec = 0.0; extraSec = 0.0; otrosIngSec =0.0;decimoSec=0.0;vacacionesSec=0.0;preavisoSec=0.0;indemSec=0.0;gatoRepSec=0.0;
		       primaProdSec = 0.0; incentivoSec = 0.0; bonifSec =0.0;primaAntSec =0.0; otrosEgrSec=0.0;subTotalSec=0.0;
		       salRegularSecAn = 0.0; extraSecAn = 0.0; otrosIngSecAn =0.0;decimoSecAn=0.0;vacacionesSecAn=0.0;preavisoSecAn=0.0;indemSecAn=0.0;gatoRepSecAn=0.0;
		       primaProdSecAn = 0.0; incentivoSecAn = 0.0; bonifSecAn =0.0;primaAntSecAn =0.0; otrosEgrSecAn=0.0;subTotalSecAn=0.0;

		}
	}//groupSec


			   if ( !groupDepto.equals(cdo.getColValue("depto")) && !fg.equalsIgnoreCase("RES2")){
				if ( i!=0)
				{

					pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);

					//pc.addCols(" ",0,1,Color.red);
					pc.setFont(8,1,Color.red);
					pc.addCols("*** TOTALES PARA: "+descDepto+" ***",0,dHeader.size());
					pc.setFont(8,1);
					if(fg.trim().equals("DET"))pc.addCols("M",2,2);
					else pc.addCols("M",2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(salRegularDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(extraDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosIngDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(decimoDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(vacacionesDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(preavisoDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(indemDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(gatoRepDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaProdDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(incentivoDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(bonifDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaAntDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(subTotalDepto),2,1);


					if(fg.trim().equals("DET"))pc.addCols("A",2,2);
					else pc.addCols("A",2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(salRegularDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(extraDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosIngDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(decimoDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(vacacionesDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(preavisoDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(indemDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(gatoRepDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaProdDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(incentivoDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(bonifDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaAntDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(subTotalDeptoAn),2,1);

					salRegularDepto = 0.0; extraDepto = 0.0; otrosIngDepto =0.0;decimoDepto=0.0;vacacionesDepto=0.0;preavisoDepto=0.0;indemDepto=0.0;gatoRepDepto=0.0;
				    primaProdDepto = 0.0; incentivoDepto = 0.0; bonifDepto =0.0;primaAntDepto =0.0; otrosEgrDepto=0.0;subTotalDepto=0.0;
				    salRegularDeptoAn = 0.0;extraDeptoAn = 0.0;otrosIngDeptoAn =0.0;decimoDeptoAn=0.0;vacacionesDeptoAn=0.0;preavisoDeptoAn=0.0;indemDeptoAn=0.0;gatoRepDeptoAn=0.0;
				    primaProdDeptoAn = 0.0; incentivoDeptoAn = 0.0; bonifDeptoAn =0.0;primaAntDeptoAn =0.0; otrosEgrDeptoAn=0.0;subTotalDeptoAn=0.0;
					pc.addCols(" ",0,dHeader.size());
			}
					pc.setFont(10,1,Color.blue);
					pc.addCols(cdo.getColValue("depto")+"        "+cdo.getColValue("dpto_desc"),0,dHeader.size());
					pc.setFont(7,0);
		}//groupDepto
		else if(fg.equalsIgnoreCase("RES2"))
		{
					pc.setFont(10,1,Color.blue);
					pc.addCols(cdo.getColValue("depto")+"        "+cdo.getColValue("dpto_desc"),0,dHeader.size());
					pc.setFont(7,0);
		}
		if (!groupSeccion.equals(groupBy1)&&!fg.equalsIgnoreCase("RES2"))
		{
					pc.addCols("",0,dHeader.size());
					pc.setFont(8,1);
					pc.addCols(cdo.getColValue("seccion")+"        "+cdo.getColValue("sec_desc"),0,dHeader.size());
		}
			  pc.setFont(8,0);
			   if(fg.trim().equals("DET"))if(!groupByEmp.trim().equals(cdo.getColValue("num_empleado"))){
			   pc.addCols(" ",0,dHeader.size());
			   pc.addCols(""+cdo.getColValue("num_empleado")+" - "+cdo.getColValue("cedula")+" - "+cdo.getColValue("nombre_empleado"),0,1);}
			   else pc.addCols(" ",2,1);

			   if(!fg.equalsIgnoreCase("RES2"))pc.addCols(" "+cdo.getColValue("type"),2,1);
			   else pc.addCols(" ",2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("SAL_BRUTO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("EXTRA")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("OTROS_ING")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("DECIMO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("VACACIONES")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("PREAVISO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("INDEMNIZACION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("GASTO_REP")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("PRIMA_PRODUCCION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("INCENTIVO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("BONIFICACION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("PRIMA_ANTIGUEDAD")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("otrosEgresos")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("Subtotal")),2,1);


			   if (cdo.getColValue("type").equals("A")){


				   salRegularDeptoAn +=Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				   extraDeptoAn +=Double.parseDouble(cdo.getColValue("EXTRA"));
				   otrosIngDeptoAn +=Double.parseDouble(cdo.getColValue("OTROS_ING"));
				   decimoDeptoAn +=Double.parseDouble(cdo.getColValue("DECIMO"));
				   vacacionesDeptoAn +=Double.parseDouble(cdo.getColValue("VACACIONES"));
				   preavisoDeptoAn +=Double.parseDouble(cdo.getColValue("PREAVISO"));
				   indemDeptoAn +=Double.parseDouble(cdo.getColValue("INDEMNIZACION"));
				   gatoRepDeptoAn +=Double.parseDouble(cdo.getColValue("GASTO_REP"));
				   primaProdDeptoAn +=Double.parseDouble(cdo.getColValue("PRIMa_PRODUCCION"));
				   incentivoDeptoAn +=Double.parseDouble(cdo.getColValue("INCENTIVO"));
				   bonifDeptoAn +=Double.parseDouble(cdo.getColValue("BONIFICACION"));
				   primaAntDeptoAn +=Double.parseDouble(cdo.getColValue("PRIMA_ANTIGUEDAD"));
				   otrosEgrDeptoAn +=Double.parseDouble(cdo.getColValue("otrosEgresos"));
				   subTotalDeptoAn +=Double.parseDouble(cdo.getColValue("Subtotal"));

				   salRegularSecAn +=Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				   extraSecAn +=Double.parseDouble(cdo.getColValue("EXTRA"));
				   otrosIngSecAn +=Double.parseDouble(cdo.getColValue("OTROS_ING"));
				   decimoSecAn +=Double.parseDouble(cdo.getColValue("DECIMO"));
				   vacacionesSecAn +=Double.parseDouble(cdo.getColValue("VACACIONES"));
				   preavisoSecAn +=Double.parseDouble(cdo.getColValue("PREAVISO"));
				   indemSecAn +=Double.parseDouble(cdo.getColValue("INDEMNIZACION"));
				   gatoRepSecAn +=Double.parseDouble(cdo.getColValue("GASTO_REP"));
				   primaProdSecAn +=Double.parseDouble(cdo.getColValue("PRIMA_PRODUCCION"));
				   incentivoSecAn +=Double.parseDouble(cdo.getColValue("INCENTIVO"));
				   bonifSecAn +=Double.parseDouble(cdo.getColValue("BONIFICACION"));
				   primaAntSecAn +=Double.parseDouble(cdo.getColValue("PRIMA_ANTIGUEDAD"));
				   otrosEgrSecAn +=Double.parseDouble(cdo.getColValue("otrosEgresos"));
				   subTotalSecAn +=Double.parseDouble(cdo.getColValue("Subtotal"));

				   salRegularAnF +=Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				   extraAnF +=Double.parseDouble(cdo.getColValue("EXTRA"));
				   otrosIngAnF +=Double.parseDouble(cdo.getColValue("OTROS_ING"));
				   decimoAnF +=Double.parseDouble(cdo.getColValue("DECIMO"));
				   vacacionesAnF +=Double.parseDouble(cdo.getColValue("VACACIONES"));
				   preavisoAnF +=Double.parseDouble(cdo.getColValue("PREAVISO"));
				   indemAnF +=Double.parseDouble(cdo.getColValue("INDEMNIZACION"));
				   gatoRepAnF +=Double.parseDouble(cdo.getColValue("GASTO_REP"));
				   primaProdAnF +=Double.parseDouble(cdo.getColValue("PRIMA_PRODUCCION"));
				   incentivoAnF +=Double.parseDouble(cdo.getColValue("INCENTIVO"));
				   bonifAnF +=Double.parseDouble(cdo.getColValue("BONIFICACION"));
				   primaAntAnF +=Double.parseDouble(cdo.getColValue("PRIMA_ANTIGUEDAD"));
				   otrosEgrAnF +=Double.parseDouble(cdo.getColValue("otrosEgresos"));
				   subTotalAnF +=Double.parseDouble(cdo.getColValue("Subtotal"));

			   }else{
				   salRegularDepto +=Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				   extraDepto +=Double.parseDouble(cdo.getColValue("EXTRA"));
				   otrosIngDepto +=Double.parseDouble(cdo.getColValue("OTROS_ING"));
				   decimoDepto +=Double.parseDouble(cdo.getColValue("DECIMO"));
				   vacacionesDepto +=Double.parseDouble(cdo.getColValue("VACACIONES"));
				   preavisoDepto +=Double.parseDouble(cdo.getColValue("PREAVISO"));
				   indemDepto +=Double.parseDouble(cdo.getColValue("INDEMNIZACION"));
				   gatoRepDepto +=Double.parseDouble(cdo.getColValue("GASTO_REP"));
				   primaProdDepto +=Double.parseDouble(cdo.getColValue("PRIMA_PRODUCCION"));
				   incentivoDepto +=Double.parseDouble(cdo.getColValue("INCENTIVO"));
				   bonifDepto +=Double.parseDouble(cdo.getColValue("BONIFICACION"));
				   primaAntDepto +=Double.parseDouble(cdo.getColValue("PRIMA_ANTIGUEDAD"));
				   otrosEgrDepto +=Double.parseDouble(cdo.getColValue("otrosEgresos"));
				   subTotalDepto +=Double.parseDouble(cdo.getColValue("Subtotal"));
			   if(!fg.equalsIgnoreCase("RES2")){
				   salRegularSec +=Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				   extraSec +=Double.parseDouble(cdo.getColValue("EXTRA"));
				   otrosIngSec +=Double.parseDouble(cdo.getColValue("OTROS_ING"));
				   decimoSec +=Double.parseDouble(cdo.getColValue("DECIMO"));
				   vacacionesSec +=Double.parseDouble(cdo.getColValue("VACACIONES"));
				   preavisoSec +=Double.parseDouble(cdo.getColValue("PREAVISO"));
				   indemSec +=Double.parseDouble(cdo.getColValue("INDEMNIZACION"));
				   gatoRepSec +=Double.parseDouble(cdo.getColValue("GASTO_REP"));
				   primaProdSec +=Double.parseDouble(cdo.getColValue("PRIMA_PRODUCCION"));
				   incentivoSec +=Double.parseDouble(cdo.getColValue("INCENTIVO"));
				   bonifSec +=Double.parseDouble(cdo.getColValue("BONIFICACION"));
				   primaAntSec +=Double.parseDouble(cdo.getColValue("PRIMA_ANTIGUEDAD"));
				   otrosEgrSec +=Double.parseDouble(cdo.getColValue("otrosEgresos"));
				   subTotalSec +=Double.parseDouble(cdo.getColValue("Subtotal"));
				    }
				   salRegularF +=Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				   extraF +=Double.parseDouble(cdo.getColValue("EXTRA"));
				   otrosIngF +=Double.parseDouble(cdo.getColValue("OTROS_ING"));
				   decimoF +=Double.parseDouble(cdo.getColValue("DECIMO"));
				   vacacionesF +=Double.parseDouble(cdo.getColValue("VACACIONES"));
				   preavisoF +=Double.parseDouble(cdo.getColValue("PREAVISO"));
				   indemF +=Double.parseDouble(cdo.getColValue("INDEMNIZACION"));
				   gatoRepF +=Double.parseDouble(cdo.getColValue("GASTO_REP"));
				   primaProdF +=Double.parseDouble(cdo.getColValue("PRIMA_PRODUCCION"));
				   incentivoF +=Double.parseDouble(cdo.getColValue("INCENTIVO"));
				   bonifF +=Double.parseDouble(cdo.getColValue("BONIFICACION"));
				   primaAntF +=Double.parseDouble(cdo.getColValue("PRIMA_ANTIGUEDAD"));
				   otrosEgrF +=Double.parseDouble(cdo.getColValue("otrosEgresos"));
				   subTotalF +=Double.parseDouble(cdo.getColValue("Subtotal"));

			   }

			if(!fg.equalsIgnoreCase("RES2")){
			   groupDepto= cdo.getColValue("depto");
			   if(!fp.trim().equals("SEC"))groupSeccion = cdo.getColValue("seccion")+"-"+cdo.getColValue("depto");
			   else groupSeccion = cdo.getColValue("seccion");
			   descDepto = cdo.getColValue("dpto_desc");
			   descSec = cdo.getColValue("sec_desc");
			   groupByEmp =cdo.getColValue("num_empleado");
			   }


		}//for i

			if(!fg.trim().equals("RES2")){
				pc.setFont(8,1);
				pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size());
				pc.setFont(8,1,Color.blue);
				pc.addCols("               *** TOTALES PARA: "+descSec+" ***",0,dHeader.size());
				pc.setFont(8,1);
				if(fg.trim().equals("DET"))pc.addCols("M",2,2);
				else pc.addCols("M",2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(salRegularSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(extraSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosIngSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(decimoSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(vacacionesSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(preavisoSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(indemSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(gatoRepSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaProdSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(incentivoSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(bonifSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaAntSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrSec),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(subTotalSec),2,1);

				if(fg.trim().equals("DET"))pc.addCols("A",2,2);
				else pc.addCols("A",2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(salRegularSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(extraSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosIngSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(decimoSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(vacacionesSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(preavisoSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(indemSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(gatoRepSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaProdSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(incentivoSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(bonifSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(primaAntSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrSecAn),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(subTotalSecAn),2,1);

		   //}
			   if(!groupDepto.trim().equals("")){

					pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
					pc.setFont(8,1,Color.red);
					pc.addCols("*** TOTALES PARA: "+descDepto+" ***",0,dHeader.size());
					pc.setFont(8,1);
					if(fg.trim().equals("DET"))pc.addCols("M",2,2);
					else pc.addCols("M",2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(salRegularDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(extraDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosIngDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(decimoDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(vacacionesDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(preavisoDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(indemDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(gatoRepDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaProdDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(incentivoDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(bonifDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaAntDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrDepto),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(subTotalDepto),2,1);

					if(fg.trim().equals("DET"))pc.addCols("A",2,2);
					else pc.addCols("A",2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(salRegularDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(extraDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosIngDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(decimoDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(vacacionesDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(preavisoDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(indemDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(gatoRepDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaProdDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(incentivoDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(bonifDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaAntDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrDeptoAn),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(subTotalDeptoAn),2,1);


		}
	}//RES2
		pc.setFont(8,1);

		pc.addCols("====================================================================================================================================================================================================================",1,dHeader.size());

		pc.setFont(8,1,Color.blue);
		pc.addCols(" ",1,dHeader.size());
		if(fg.trim().equals("RES2")){pc.setFont(8,1,Color.red);pc.addCols("****** TOTALES FINALES "+((fg.trim().equals("RES2"))?" MES DE "+mesDesc+" DE "+anio:" "),0,dHeader.size());}
		else pc.addCols("****** TOTALES FINALES ******"+((fg.trim().equals("RES2"))?" MES DE "+mesDesc+" DE "+anio:" "),1,dHeader.size());
		pc.setFont(8,1);
		if(fg.trim().equals("DET"))pc.addCols("M",2,2);
		else if(fg.trim().equals("RES2")) pc.addCols(" ",2,1);
		else pc.addCols("M",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(salRegularF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(extraF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosIngF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(decimoF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(vacacionesF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(preavisoF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(indemF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(gatoRepF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaProdF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(incentivoF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(bonifF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaAntF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(subTotalF),2,1);

					if(!fg.trim().equals("RES2")){
					if(fg.trim().equals("DET"))pc.addCols("A",2,2);
					else pc.addCols("A",2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(salRegularAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(extraAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosIngAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(decimoAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(vacacionesAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(preavisoAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(indemAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(gatoRepAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaProdAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(incentivoAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(bonifAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(primaAntAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(otrosEgrAnF),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(subTotalAnF),2,1);;
			 	}


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
