<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();

String userName = UserDet.getUserName();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSql2 = new StringBuffer();

String refId = request.getParameter("refId");
String compId = (String) session.getAttribute("_companyId");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String referTo = request.getParameter("referTo");
String refType = request.getParameter("refType");
String pacId = request.getParameter("pacId");
String fg = request.getParameter("fg");
String pagos = request.getParameter("pagos");
String saldo_inicial = "0";
String tipo_fecha = request.getParameter("tipo_fecha");

if(fg==null)fg="";
if(pagos==null)pagos="";
if(tipo_fecha==null)tipo_fecha="";
if (fDate == null) fDate = "";

CommonDataObject cdoQry = new CommonDataObject();
cdoQry = SQLMgr.getData("select query from tbl_gen_query where id = 0 and refer_to = '"+referTo+"'");
saldo_inicial = cdoQry.getColValue("saldo_inicial");
System.out.println("query......=\n"+cdoQry.getColValue("query"));

sbSql = new StringBuffer();
sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac,'dd/mm/yyyy') as fecha_nacimiento, a.ruc, a.dv, decode(a.refer_to,'EMPL',(select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo),a.codigo) as num_empleado");
if (fg.equalsIgnoreCase("PAC") || referTo.equalsIgnoreCase("PAC")) sbSql.append(", direccion, telefono, responsable");
sbSql.append(" from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
sbSql.append(") a where nvl(compania,");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(") = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.codigo = '");
sbSql.append(refId);
sbSql.append("' order by nombre");
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());


sbSql = new StringBuffer();
sbSql.append("select a.codigo as documento, a.admi_secuencia, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.admi_secuencia,0,' S/I')||(case when a.facturar_a = 'E' then ' '||(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) else decode(a.cod_otro_cliente,'");
sbSql.append(refId.toUpperCase());
sbSql.append("','',' - '||nvl(a.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id))) end) as descripcion, a.admi_secuencia as admision, a.grang_total as facturado, nvl(fn_get_monto_trx_fact(a.codigo,a.compania,'");
sbSql.append(tDate);
sbSql.append("'),0) as trx, a.f_anio as anio, to_char(a.fecha_envio,'dd/mm/yyyy') as fecha_envio_f, ' [ '||a.pac_id||'-'||a.admi_secuencia||' ]' as cuenta, nvl((select to_char(fecha_envio,'dd/mm/yyyy') from tbl_fac_lista_envio z where enviado = 'S' and estado = 'A' and rownum = 1 and exists (select null from tbl_fac_lista_envio_det where compania = a.compania and factura = a.codigo and id = z.id and estado = 'A')),' ') as fecha_envio, (select 'Poliza: '||poliza||' CERT: '||certificado from tbl_adm_beneficios_x_admision z where pac_id = a.pac_id and admision = a.admi_secuencia and nvl(estado,'A') = 'A' and empresa = a.cod_empresa and prioridad = 1 and rownum = 1) as certificado from (");

	sbSql.append("select * from tbl_fac_factura f where f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and f.cod_otro_cliente = '");
	sbSql.append(refId);
	sbSql.append("' and f.cliente_otros = ");
	sbSql.append(refType);
	sbSql.append(" and f.estatus <> 'A'");

	if(tipo_fecha.trim().equals("FF")) {

		if (!fDate.trim().equals("")) { sbSql.append(" and f.fecha >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(" and f.fecha <= to_date('");
		sbSql.append(tDate);
		sbSql.append("','dd/mm/yyyy')");

	} else {

		sbSql.append(" and exists (select null from tbl_fac_lista_envio z where enviado = 'S' and estado = 'A' and rownum = 1 and exists (select null from tbl_fac_lista_envio_det where compania = f.compania and factura = f.codigo and id = z.id and estado = 'A')");
		if (!fDate.trim().equals("")) { sbSql.append(" and trunc(fecha_envio) >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(" and trunc(fecha_envio) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("','dd/mm/yyyy'))"); 

	}
	if (pagos.equalsIgnoreCase("SP")) sbSql.append(" and get_fac_pagos_fac(f.codigo,f.compania) = 0 and fn_cja_saldo_fact(f.facturar_a,f.compania,f.codigo,f.grang_total) <> 0 ");
	else if(pagos.equalsIgnoreCase("PP")) sbSql.append(" and get_fac_pagos_fac(f.codigo,f.compania) <> 0 and fn_cja_saldo_fact(f.facturar_a,f.compania,f.codigo,f.grang_total) <> 0 ");

	sbSql.append(" union select * from tbl_fac_factura f where f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and exists (select null from tbl_adm_responsable where estado = 'A' and ref_id = '");
	sbSql.append(refId.toUpperCase());
	sbSql.append("' and ref_type=");
	sbSql.append(refType);
	sbSql.append(" and pac_id = f.pac_id and admision = f.admi_secuencia and f.facturar_a = 'P') and f.estatus <> 'A'");

	if(tipo_fecha.trim().equals("FF")) {

		if (!fDate.trim().equals("")) { sbSql.append(" and f.fecha >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(" and f.fecha <= to_date('");
		sbSql.append(tDate);
		sbSql.append("','dd/mm/yyyy')");

	} else {

		sbSql.append(" and exists (select null from tbl_fac_lista_envio z where enviado = 'S' and estado = 'A' and rownum = 1 and exists (select null from tbl_fac_lista_envio_det where compania = f.compania and factura = f.codigo and id = z.id and estado = 'A')");
		if (!fDate.trim().equals("")) { sbSql.append(" and trunc(fecha_envio) >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(" and trunc(fecha_envio) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("','dd/mm/yyyy'))"); 

	}
	if (pagos.equalsIgnoreCase("SP")) sbSql.append(" and get_fac_pagos_fac(f.codigo,f.compania) = 0 and fn_cja_saldo_fact(f.facturar_a,f.compania,f.codigo,f.grang_total) <> 0  ");
	else if(pagos.equalsIgnoreCase("PP")) sbSql.append(" and get_fac_pagos_fac(f.codigo,f.compania) <> 0 and fn_cja_saldo_fact(f.facturar_a,f.compania,f.codigo,f.grang_total) <> 0 ");

//sbSql.append(" and f.grang_total <> 0" );
sbSql.append(") a order by a.fecha, a.codigo");
al = SQLMgr.getDataList(sbSql.toString());
 
String pMes = request.getParameter("pMes");
String pAnio = request.getParameter("pAnio");
 
if(pMes==null)pMes="";
if(pAnio==null)pAnio="";
pMes  = tDate.substring(3,5);
pAnio = tDate.substring(6);
   
sbSql2 = new StringBuffer();
sbSql2.append(" select sum(case when (round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) >=0 and round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) < 30 ) then  facturado+trx   else 0 end) as scorriente,sum(case when (round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) >=30 and round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) < 60) then facturado+trx   else 0 end) as s30 ,sum(case when (round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) >=60 and round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) < 90) then facturado+trx   else 0 end) as s60 ,sum(case when (round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) >=90 and round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) < 120) then facturado+trx   else 0 end) as s90,sum(case when (round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) >=120 and round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) < 150) then facturado+trx   else 0 end) as s120,sum(case when (round(to_date('");
sbSql2.append(tDate);
sbSql2.append("','dd/mm/yyyy') - to_date(decode('"+tipo_fecha+"','FF',fecha,fecha_envio),'dd/mm/yyyy')) >=150) then facturado+trx   else 0 end) as s150  from ( "); 
sbSql2.append(sbSql);
sbSql2.append(")  "); 

CommonDataObject cdoCxc = SQLMgr.getData(sbSql2.toString()); 


if(cdoCxc == null ){ 
cdoCxc.addColValue("scorriente","0");
cdoCxc.addColValue("s30","0");
cdoCxc.addColValue("s60","0");
cdoCxc.addColValue("s90","0");
cdoCxc.addColValue("s120","0");
cdoCxc.addColValue("s150","0");
cdoCxc.addColValue("saldo_actual","0");
cdoCxc.addColValue("existe","N");
}// else cdoCxc.addColValue("existe","S");
cdoCxc.addColValue("descTitulo",CmnMgr.getFormattedDate(tDate,"MONTH yyyy","spanish"));



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
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	//String title = "RESUMEN DE FACTURAS";
	String title = "ESTADO DE CUENTA";
	String subtitle = ((!fDate.trim().equals(""))?"DESDE  "+fDate:"")+"    HASTA   "+tDate;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



	Vector dHeader=new Vector();
		dHeader.addElement(".12");
		dHeader.addElement(".08");
		dHeader.addElement(".16");
		dHeader.addElement(".16");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".11");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(headerFontSize,1);

				pc.addBorderCols(" ", 0, dHeader.size(), 0.0f, 0.5f, 0.0f, 0.0f);

				pc.addBorderCols("Cliente:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("nombre"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);

				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Id Clte:", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("codigo"), 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);

			if(fg.trim().equals("PAC")||referTo.trim().equals("PAC")){
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Dirección:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("direccion"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Cédula:", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("ruc"), 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);

				pc.setFont(headerFontSize, 1);
				pc.addCols("Teléfono:", 0, 1);
				pc.setFont(headerFontSize, 0);
				pc.addCols(cdoHeader.getColValue("telefono"), 0, 1);
				pc.setFont(headerFontSize, 1);
				pc.addCols("Responsable:", 0, 1);
				pc.setFont(headerFontSize, 0);
				pc.addCols(cdoHeader.getColValue("responsable"), 0, 3);
				pc.setFont(headerFontSize, 1);
				pc.addCols(" ", 2, 2);
				pc.setFont(headerFontSize, 0);
				pc.addCols(" ", 0, 2);
				}
				
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Expediente", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Fecha", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Fecha Envio", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Nombre Paciente", 1, 2, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Factura", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);				 
				pc.addBorderCols("Poliza/Cert. ", 1, 2, 0.5f, 0.5f, 0.0f, 0.0f); 
				pc.addBorderCols("Monto", 2, 2, 0.5f, 0.5f, 0.0f, 0.0f);

	//pc.setTableHeader(2);//create de table header

	//table body 
	double saldo = 0.00,saldo_fact=0.00,saldo_act=0.00;  
	float _top = 0.0f, _bottom = 0.00f;
	for (int i=0; i<al.size(); i++)
	{
		if (i == 0) pc.setTableHeader(4);
		pc.setFont(contentFontSize,0);

		CommonDataObject cdo = (CommonDataObject) al.get(i);
		  
			pc.resetFont();
			pc.setFont(contentFontSize, 0);
		  
			pc.addBorderCols(cdo.getColValue("cuenta"), 1, 1, 0.0f, _top, 0.5f, 0.0f);
			pc.addBorderCols(cdo.getColValue("fecha"), 0, 1, 0.0f, _top, 0.0f, 0.0f);
			pc.addBorderCols(cdo.getColValue("fecha_envio"), 1, 1, 0.0f, _top, 0.0f, 0.0f); 				
			pc.addBorderCols(cdo.getColValue("descripcion"), 0, 2, 0.0f, _top, 0.0f, 0.0f);
			
			pc.addBorderCols(cdo.getColValue("documento"), 1, 1, 0.0f, _top, 0.0f, 0.0f);
			pc.addBorderCols(cdo.getColValue("certificado"), 0, 2, 0.0f, _top, 0.0f, 0.0f);
			
			saldo_fact = Double.parseDouble(cdo.getColValue("facturado"))+Double.parseDouble(cdo.getColValue("trx"));
			
			pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo_fact), 2,2, 0.0f, _top, 0.0f, 0.5f);
			
			saldo += saldo_fact; 

			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
  				pc.addBorderCols("TOTAL FINAL : ", 2, 7, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo), 2, 3, 0.5f, 0.5f, 0.5f, 0.5f);
				
				pc.addBorderCols(" ", 2, 10, 0.0f, 0.0f, 0.0f, 0.0f);
 				 
				pc.setNoColumn(7);
				pc.createTable("totalMor",false,0,0.0f,width-(2*leftRightMargin));
				pc.addBorderCols("MOROSIDAD HASTA "+cdoCxc.getColValue("descTitulo"), 1, 7, 0.0f, 0.5f, 0.5f, 0.5f);
				
				//if(!cdoCxc.getColValue("existe").equals("N")){
				
				pc.addBorderCols("CORRIENTE", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 30 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 60 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 90 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 120 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 150 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("TOTAL", 1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("scorriente")),2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s30")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s60")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s90")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s120")), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s150")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				saldo_act =  Double.parseDouble(cdoCxc.getColValue("scorriente"))+Double.parseDouble(cdoCxc.getColValue("s30"))+Double.parseDouble(cdoCxc.getColValue("s60"))+Double.parseDouble(cdoCxc.getColValue("s90"))+Double.parseDouble(cdoCxc.getColValue("s120"))+Double.parseDouble(cdoCxc.getColValue("s150"));
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo_act), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				//}else {pc.addBorderCols("NO EXISTE REGISTROS DE MOROSIDAD GENERADA PARA "+cdoCxc.getColValue("descTitulo"), 1, 7, 0.5f, 0.5f, 0.5f, 0.5f);}
				
				pc.useTable("main");
				pc.addTableToCols("totalMor",0,dHeader.size()); 
				
				
	}

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>