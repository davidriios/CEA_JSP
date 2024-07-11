<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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

ArrayList al = new ArrayList();
ArrayList alT = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoTitle = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlGroup = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String categoria = request.getParameter("categoria");
String tipoAdmision = request.getParameter("tipoAdmision");
String area = request.getParameter("area");
String aseguradora = request.getParameter("aseguradora");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String orderBy = request.getParameter("groupBy");
String tipoRep = request.getParameter("tipoRep");
String appendFilter = "";
if (categoria == null) categoria = "";
if (tipoAdmision == null) tipoAdmision = "";
if (area == null) area = "";
if (aseguradora == null) aseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (orderBy== null) orderBy = "";
if (tipoRep== null) tipoRep = "D";
String grupo = orderBy,nombreGrupo="";
String sub = request.getParameter("titulo");

if(orderBy.equals("1")){ 
	nombreGrupo = "categoria_desc as nombre_grupo,tipo_admision as grupo2";
	orderBy = "categoria,tipo_admision";
	//sub = "CATEGORIA DE ADMISION";
} else if(orderBy.equals("2")){ 
	nombreGrupo= "tipo_admision_desc as nombre_grupo ,categoria_desc as grupo2";
	orderBy = "tipo_admision,categoria";
	//sub = "TIPO DE ADMISION";
} else if(orderBy.equals("3")){ 
	nombreGrupo= "nombre_paciente as nombre_grupo,'' as grupo2";
	orderBy = "nombre_paciente,categoria,tipo_admision";
	//sub = "PACIENTE";
} else if(orderBy.equals("4")){
	nombreGrupo= "nombre_empresa as nombre_grupo,'' as grupo2";
	orderBy = "nombre_empresa,categoria ,tipo_admision";
	//sub = "ASEGURADORA";
}

String resGroupBy = "";
if(!categoria.equals("")){
	sbFilter.append(" and a.categoria = ");
	sbFilter.append(categoria);
}
if(!tipoAdmision.equals("")){
	sbFilter.append(" and a.tipo_admision = ");
	sbFilter.append(tipoAdmision);
}
if(!area.equals("")){
	sbFilter.append(" and a.centro_servicio = ");
	sbFilter.append(area);
}
if(!aseguradora.equals("")){
	sbFilter.append(" and f.cod_empresa = ");
	sbFilter.append(aseguradora);
}
if(!fechaini.equals("")){
	sbFilter.append(" and trunc(f.fecha) >= to_date('");
	sbFilter.append(fechaini);
	sbFilter.append("', 'dd/mm/yyyy')");
}
if(!fechafin.equals("")){
	sbFilter.append(" and trunc(f.fecha) <= to_date('");
	sbFilter.append(fechafin);
	sbFilter.append("', 'dd/mm/yyyy')");
}
sbSql.append("select a.*, ");
sbSql.append(nombreGrupo);
sbSql.append("  from (select a.pac_id, a.secuencia, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, a.categoria, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) categoria_desc, a.tipo_admision, (select descripcion from tbl_adm_tipo_admision_cia where categoria = a.categoria and codigo = a.tipo_admision and compania = a.compania) tipo_admision_desc, a.tipo_cta, a.centro_servicio, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) centro_servicio_desc, p.nombre_paciente, f.facturar_a, f.codigo codigo_factura, to_char(f.fecha, 'dd/mm/yyyy') fecha_factura, f.grang_total monto_factura, a.aseguradora cod_empresa, (select nombre from tbl_adm_empresa where codigo = a.aseguradora) nombre_empresa, nvl(ab.abono, 0) abono, to_char(ab.ultima_fecha, 'dd/mm/yyyy') ult_fecha_abono, nvl(pa.pagos, 0) pagos, to_char(pa.ultima_fecha, 'dd/mm/yyyy') ult_fecha_pago from tbl_adm_admision a, tbl_fac_factura f, vw_adm_paciente p, (select p.pac_id, dp.admi_secuencia admision, sum((case when trim(nvl(dp.fac_codigo, '0')) = '0' then monto else 0 end)) abono, max((case when trim(nvl(dp.fac_codigo, '0')) = '0' then fecha else null end)) ultima_fecha from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago dp where p.codigo = dp.codigo_transaccion and p.compania = dp.compania and p.anio = dp.tran_anio and nvl(p.rec_status,'A') <> 'I' group by p.pac_id, dp.admi_secuencia) ab, (select p.pac_id, p.codigo_empresa, dp.fac_codigo factura, sum((case when trim(nvl(dp.fac_codigo, '0')) = '0' then 0 else monto  end)) pagos, max((case when trim(nvl(dp.fac_codigo, '0')) = '0' then null else fecha end)) ultima_fecha from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago dp where p.codigo = dp.codigo_transaccion and p.compania = dp.compania and p.anio = dp.tran_anio and nvl(dp.fac_codigo, '0') != '0' and nvl(p.rec_status,'A') <> 'I' group by p.pac_id, p.codigo_empresa, dp.fac_codigo) pa where a.pac_id = p.pac_id and a.pac_id = f.pac_id and a.secuencia = f.admi_secuencia and f.estatus != 'A' and f.pac_id = ab.pac_id(+) and f.admi_secuencia = ab.admision(+) and f.codigo = pa.factura(+) ");
sbSql.append(sbFilter.toString());
sbSql.append(") a");
if(tipoRep.equals("D")){
	sbSql.append(" order by ");
	sbSql.append(orderBy);
}
if(tipoRep.equals("R")){ 
	if(grupo.equals("3")) resGroupBy = "pac_id, ";
	resGroupBy += "nombre_grupo, categoria, categoria_desc, tipo_admision, tipo_admision_desc, cod_empresa, nombre_empresa";
	sbSqlGroup.append("select ");
	sbSqlGroup.append(resGroupBy);
	sbSqlGroup.append(", ''  grupo2, count(secuencia) cant_admisiones, sum(monto_factura) monto_factura, sum(abono) abono, sum(pagos) pagos from (");
	sbSqlGroup.append(sbSql.toString());
	sbSqlGroup.append(") b group by ");
	sbSqlGroup.append(resGroupBy);
	sbSqlGroup.append(" order by ");
	sbSqlGroup.append(orderBy);
}

al = SQLMgr.getDataList(tipoRep.equals("R")?sbSqlGroup.toString():sbSql.toString());

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISIONES FACTURADAS";
	String subtitle = "AGRUPADO POR "+sub;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		if(tipoRep.equals("D")){
			infoCol.addElement(".28");
			infoCol.addElement(".07");
			infoCol.addElement(".04");
			infoCol.addElement(".1");
			infoCol.addElement(".07");
			infoCol.addElement(".1");
			infoCol.addElement(".1");
			infoCol.addElement(".07");
			infoCol.addElement(".1");
			infoCol.addElement(".07");
		} else {
			if(grupo.equals("3")){
				infoCol.addElement(".2");
				infoCol.addElement(".2");
				infoCol.addElement(".2");
			} else {
				infoCol.addElement(".3");
				infoCol.addElement(".3");
			}			
			infoCol.addElement(".1");
			infoCol.addElement(".1");
			infoCol.addElement(".1");
			infoCol.addElement(".1");
		}
	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

		if(tipoRep.equals("D")){
			pc.addBorderCols("Cuenta",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Fecha Ing.",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Fact. A",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Cod. Fact.",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Fecha Fact.",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Monto",2,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Abono",2,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Fecha Ult. Abono",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Pago",2,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Fecha Ult. Pago",1,1,0.1f,0.1f,0.0f,0.0f);
		} else {
			if(!grupo.equals("1")) pc.addBorderCols("Categoria",0,1,0.1f,0.1f,0.0f,0.0f);
			if(!grupo.equals("2")) pc.addBorderCols("Tipo Admision",0,1,0.1f,0.1f,0.0f,0.0f);
			if(!grupo.equals("4")) pc.addBorderCols("Aseguradora",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Cant. Adm.",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Montos Fact.",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Abonos",1,1,0.1f,0.1f,0.0f,0.0f);
			pc.addBorderCols("Pagos",1,1,0.1f,0.1f,0.0f,0.0f);
		}
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "",groupBy2="";
	String descTotal = "";
	pc.setVAlignment(0);
	boolean printTotal = true, printMontoTotal = false, printPasivo = true, printPasivoCapital = true, printSubTotal = false;
	double saldo = 0.00, saldoGrupo = 0.00, saldoTotales = 0.00, tMonto=0.00, tAbono=0.00, tPagos=0.00, tMontoT=0.00, tAbonoT=0.00, tPagosT=0.00;
	int cantAdm = 0, cantAdmT = 0;
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("nombre_grupo"))){ // groupBy
			pc.setFont(7, 1);
			
			if(i!=0){
				if(tipoRep.equals("D")){
					pc.addBorderCols(" Subtotal",2,4,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+cantAdm,1,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tMonto),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tAbono),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols("",2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tPagos),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols("",2,1,0.0f,0.1f,0.0f,0.0f);
				} else {
					pc.addBorderCols(" Subtotal",2,(grupo.equals("3")?3:2),0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+cantAdm,2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tMonto),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tAbono),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tPagos),2,1,0.0f,0.1f,0.0f,0.0f);
				}
				
				tMonto = 0.00;
				tAbono = 0.00;
				tPagos = 0.00;
				cantAdm = 0;
			}

			printSubTotal = true;
			pc.setFont(8, 1);
			if(i!=0)pc.addCols(" ",0,infoCol.size());
			pc.addBorderCols(cdo.getColValue("nombre_grupo"),0,infoCol.size(),0.1f,0.1f,0.0f,0.0f);
			
			
		}
		
		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("nombre_grupo")) || !groupBy2.trim().equalsIgnoreCase(cdo.getColValue("grupo2")))
		{
		 	pc.setFont(8, 1);
		 	if(grupo.equals("2")||grupo.equals("3")||grupo.equals("4"))if(tipoRep.equals("D")) pc.addBorderCols("Cat.: "+cdo.getColValue("categoria")+" - "+cdo.getColValue("categoria_desc"),0,10,0.0f,0.0f,0.0f,0.0f);
			if(grupo.equals("1")||grupo.equals("3")||grupo.equals("4"))if(tipoRep.equals("D"))pc.addBorderCols("Tipo Adm.: "+cdo.getColValue("tipo_admision")+" - "+cdo.getColValue("tipo_admision_desc"),0,10,0.0f,0.0f,0.0f,0.0f);
			if(tipoRep.equals("D"))pc.addCols(" ",0,infoCol.size());
		}
			pc.setFont(7, 0);
		if(tipoRep.equals("D")){
		
			pc.addBorderCols(cdo.getColValue("pac_id")+" - "+cdo.getColValue("secuencia")+" / "+cdo.getColValue("nombre_paciente"),0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("fecha_ingreso"),1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("facturar_a"),1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("codigo_factura"),1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("fecha_factura"),1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_factura")),2,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("abono")),2,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("ult_fecha_abono"),1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")),2,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("ult_fecha_pago"),1,1,0.1f,0.0f,0.0f,0.0f);
		} else {
			if(!grupo.equals("1")) pc.addBorderCols(cdo.getColValue("categoria")+"-"+cdo.getColValue("categoria_desc"),0,1,0.0f,0.0f,0.0f,0.0f);
			if(!grupo.equals("2")) pc.addBorderCols(cdo.getColValue("tipo_admision")+"-"+cdo.getColValue("tipo_admision_desc"),0,1,0.0f,0.0f,0.0f,0.0f);
			if(!grupo.equals("4")) pc.addBorderCols(cdo.getColValue("cod_empresa")+"-"+cdo.getColValue("nombre_empresa"),0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("cant_admisiones"),2,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_factura")),2,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("abono")),2,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")),2,1,0.0f,0.0f,0.0f,0.0f);
		}
		
		groupBy = cdo.getColValue("nombre_grupo");
		groupBy2 = cdo.getColValue("grupo2");

		tMonto += Double.parseDouble(cdo.getColValue("monto_factura"));
		tAbono += Double.parseDouble(cdo.getColValue("abono"));
		tPagos += Double.parseDouble(cdo.getColValue("pagos"));
		if(tipoRep.equals("D")) cantAdm++;
		else cantAdm+=Integer.parseInt(cdo.getColValue("cant_admisiones"));

		tMontoT += Double.parseDouble(cdo.getColValue("monto_factura"));
		tAbonoT += Double.parseDouble(cdo.getColValue("abono"));
		tPagosT += Double.parseDouble(cdo.getColValue("pagos"));
		if(tipoRep.equals("D")) cantAdmT++;
		else cantAdmT+=Integer.parseInt(cdo.getColValue("cant_admisiones"));

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	if(al.size()>0){

			pc.setFont(7, 1);
			
			if(tipoRep.equals("D")){
				pc.addBorderCols(" Subtotal",2,4,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+cantAdm,1,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tMonto),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tAbono),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tPagos),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.1f,0.0f,0.0f);
			} else {
				pc.addBorderCols(" Subtotal",2,(grupo.equals("3")?3:2),0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+cantAdm,2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tMonto),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tAbono),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tPagos),2,1,0.0f,0.1f,0.0f,0.0f);
			}

			if(tipoRep.equals("D")){
				pc.addBorderCols(" TOTAL",2,4,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+cantAdmT,1,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tMontoT),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tAbonoT),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tPagosT),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.1f,0.0f,0.0f);
			} else {
				pc.addBorderCols(" TOTAL",2,(grupo.equals("3")?3:2),0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+cantAdmT,2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tMontoT),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tAbonoT),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tPagosT),2,1,0.0f,0.1f,0.0f,0.0f);
			}
	}
	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>