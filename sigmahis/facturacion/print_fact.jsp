<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header_2.jsp"%>
<%
/*
=========================================================================
=========================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alFac = new ArrayList();
ArrayList alDet = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String factura = request.getParameter("factura");
String compania = request.getParameter("compania");
String fp = request.getParameter("fp");
String listId = request.getParameter("listId");
String categoria = request.getParameter("categoria");
String categoria_desc = request.getParameter("categoria_desc");
String yearList = request.getParameter("yearList");
String mesList = request.getParameter("mesList");
if (yearList == null) yearList = "0";
if (mesList == null) mesList = "";
String empresa = "";
String deducible = "N";//Default que no muestre deducible
try { deducible = java.util.ResourceBundle.getBundle("issi").getString("deducible"); } catch(Exception e) { deducible = "N"; }

if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (factura == null) factura = "";
if (compania == null) compania = "";
if (fp == null) fp = "";
if (listId == null) listId = "";
if (categoria == null) categoria = "";
if (categoria_desc == null) categoria_desc = "";

sbSql = new StringBuffer();
sbSql.append("select a.codigo, a.compania, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.pac_id, a.admi_secuencia, a.cod_empresa, a.facturar_a, a.lista, (select nombre_paciente2 from vw_adm_paciente where pac_id = a.pac_id) as nombre_paciente, (select nvl (trunc(months_between (sysdate, coalesce (f_nac, fecha_nacimiento)) / 12), 0) as edad from tbl_adm_paciente where pac_id = a.pac_id) as edad, (select(to_char(coalesce (f_nac, fecha_nacimiento),'dd/mm/yyyy')) as fecha_nac from tbl_adm_paciente where pac_id = a.pac_id) as fecha_nac, (select id_paciente from vw_adm_paciente where pac_id = a.pac_id) as identificacion, (select nombre from tbl_adm_empresa where codigo = a.cod_empresa) as nombre_aseguradora, (select (select primer_nombre||' '||segundo_nombre||' '||decode(apellido_de_casada,null,primer_apellido||' '||segundo_apellido,apellido_de_casada) from tbl_adm_medico where codigo = z.medico) from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admi_secuencia) as nombre_medico, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admi_secuencia) as categoria,/* decode((select admision from tbl_adm_beneficios_x_admision where prioridad = 1 and convenio_sol_emp = 'S' and pac_id = a.pac_id and admision = a.admi_secuencia and estado='A' ),null,decode(a.facturar_a,'P',0,'E',2),1) as tipo_factura,*/ (select poliza from tbl_adm_beneficios_x_admision g where g.pac_id = a.pac_id and admision = a.admi_secuencia and g.prioridad = 1 and g.estado = 'A') as poliza, a.estatus, nvl(a.total_honorarios,0) as total_honorarios, nvl(decode(a.facturar_a,'P',get_adm_doblecobertura_msg(a.pac_id,a.admi_secuencia)),' ') as doble_msg, nvl((select nombre from tbl_adm_responsable where pac_id = a.pac_id and admision = a.admi_secuencia and estado = 'A'),' ') as responsable, get_sec_comp_param(a.compania,'CDS_PAQ_PER') as cds_paq_per, nvl(a.num_aprobacion_axa, '') num_aprobacion_axa, (case when a.codigo = (select max(f.codigo) from tbl_fac_factura f where f.compania = a.compania and f.estatus != 'A' and f.pac_id = a.pac_id and f.admi_secuencia = a.admi_secuencia and f.facturar_a = 'E' and exists (select count(*)from tbl_fac_factura ff where f.compania = ff.compania and ff.estatus != 'A' and f.pac_id = ff.pac_id and f.admi_secuencia = ff.admi_secuencia and ff.facturar_a = 'E' having count(*) > 1)) then 'S' else 'N' end) seg_fact_dbl_cobert from tbl_fac_factura a where ");
if (!pacId.trim().equals("") && !admision.trim().equals(""))
{
	sbSql.append("a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(admision);
	sbSql.append(" and estatus != 'A'");
}
else if (!factura.trim().equals("") && !compania.trim().equals(""))
{
	sbSql.append("a.codigo = '");
	sbSql.append(factura);
	sbSql.append("' and a.compania = ");
	sbSql.append(compania);
}
else throw new Exception("La Admisión o la Factura no es válida. Por favor intente nuevamente!");
if (!factura.trim().equals("") && !compania.trim().equals("") && fp.equals("lista_envio"))
{
	sbSql.append(" and a.codigo = '");
	sbSql.append(factura);
	sbSql.append("' and a.compania = ");
	sbSql.append(compania);
}

alFac = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	if(fp.equals("lista_envio") && !yearList.equals("0")) year = yearList;

	String servletPath = request.getServletPath();

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
	if(!mesList.equals("")) month = mesList;

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = ResourceBundle.getBundle("path").getString("images")+"/anulado.png";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String subFolderName = "archivos";
	if(fp.equals("lista_envio")){
		directory = ResourceBundle.getBundle("path").getString("docs.files_axa")+"/";
		folderName=categoria_desc;
		if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	} else if(CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	float availHeight = 0.0f;//altura disponible para el ciclo for
	float headerHeight = 0.0f;//tamaño del encabezado
	float commentHeight = 0.0f;//tamaño del segmento de comentarios/observaciones
	float totalHeight = 0.0f;//tamaño del segmento de totales
	float honHeight = 0.0f;//tamaño del segmento de honorarios
	float gtotalHeight = 0.0f;//tamaño del segmento de gran total
	float footerHeight = 0.0f;//tamaño del footer
	float tempHeight = 0.0f;//altura anterior
	float detailHeight = 0.0f;//
	float tDetailHeight = 0.0f;//
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 20.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int headerFontSize = 8;
	int contentFontSize = 8;
	int footerFontSize = 7;

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin * 2);
	footer.setFont(footerFontSize,0);
	footer.setNoColumn(1);
	footer.createTable();
		footer.addCols("",0,1);
		footer.addCols("",0,1);
		footer.addCols("",0,1);
		footerHeight = footer.getTableHeight();

	Vector vInvoice = new Vector();
		vInvoice.addElement(".25");
		vInvoice.addElement(".10");
		//vInvoice.addElement(".10");
		//vInvoice.addElement(".06");
		//vInvoice.addElement(".14");
		//vInvoice.addElement(".12");
		//vInvoice.addElement(".14");

	Vector vContent = new Vector();
		vContent.addElement(".15");//.15
		vContent.addElement(".60");//.60
		vContent.addElement(".15");
		vContent.addElement(".10");

	Vector vTotal = new Vector();
		vTotal.addElement(".65");//.60
		vTotal.addElement(".35");//.40

	Vector vHon = new Vector();
		vHon.addElement(".15");
		vHon.addElement(".40");
		vHon.addElement(".15");
		vHon.addElement(".15");
		vHon.addElement(".15");

	String codFactPac = "";
	double hon_paciente = 0.00;
	double totalFactura = 0.00;
	for (int i=0; i<alFac.size(); i++)
	{
		CommonDataObject fac = (CommonDataObject) alFac.get(i);
		if(fac.getColValue("facturar_a").equalsIgnoreCase("P")){
			codFactPac = fac.getColValue("codigo");
			if(pacId==null || pacId.equals("")) pacId = fac.getColValue("pac_id");
		} else if (fac.getColValue("facturar_a").equalsIgnoreCase("E")) {
			empresa = fac.getColValue("cod_empresa");
		}

		String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+fac.getColValue("codigo")+"_"+fac.getColValue("compania")+"_"+pacId+"_"+admision+".pdf";
		
		if(fp.equals("lista_envio")) fileName=fac.getColValue("codigo")+"_.pdf";

		String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

		String title = "PROFORMA NO. "+fac.getColValue("facturar_a") + " - " + fac.getColValue("codigo");
		String subtitle = "";
		String xtraSubtitle = "";
		
		PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+(fp.equals("lista_envio")?"":"")+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, (fac.getColValue("estatus").equals("A")?true:false), statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());


/* * * * * * * * * * * * * * *   E N C A B E Z A D O   F A C T U R A   * * * * * * * * * * * * * * */
		pc.setNoColumnFixWidth(vInvoice);
		pc.createTable("invoice",false,0,leftRightMargin*2,width);
			//pc.setFont(headerFontSize,1);
			//pc.addCols("",0,1);
			pc.setFont(headerFontSize,0);
			//pc.addCols(fac.getColValue("lista"),0,1);
			pc.setFont(headerFontSize,0);
			//pc.addCols("",0,2);
			pc.setFont(headerFontSize,0);
			//pc.addCols("",0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("FECHA:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("fecha"),0,1);

			pc.setFont(headerFontSize,1);
			pc.addCols("CODIGO PACIENTE:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("pac_id"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("NOMBRE:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("nombre_paciente"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("CEDULA/PASAPORTE:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("identificacion"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("FECHA NAC.:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("fecha_nac"),0,1);

			pc.setFont(headerFontSize,1);
			pc.addCols("EDAD:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("edad"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("ASEGURADORA:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("nombre_aseguradora"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("POLIZA:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("poliza"),0,1);



			pc.setFont(headerFontSize,1);
			pc.addCols("MEDICO:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("nombre_medico"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("CATEGORIA:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("categoria"),0,2);

			pc.setFont(headerFontSize,1);
			pc.addCols("RESPONSABLE:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("responsable"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols(fac.getColValue("doble_msg"),1,2);
			pc.setFont(headerFontSize,0);

			if(fac.getColValue("num_aprobacion_axa")!=null && !fac.getColValue("num_aprobacion_axa").equals("")){
			pc.setFont(headerFontSize,1);
			pc.addCols("No. APROBACION AXA:",2,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(fac.getColValue("num_aprobacion_axa"),0,1);
			pc.setFont(headerFontSize,1);
			pc.addCols("",1,2);
			pc.setFont(headerFontSize,0);
			}



/* * * * * * * * * * * * * * *   T O T A L E S   * * * * * * * * * * * * * * */

		sbSql = new StringBuffer();
		sbSql.append("select nvl(subtotal,0) as subtotal, nvl(monto_descuento,0) as monto_descuento, nvl(monto_paciente,0) as monto_paciente, nvl(monto_total,0) as monto_total, nvl(grang_total,0) as gran_total, getCopago(compania,codigo) as copago, getGastosNoCubiertos(compania,codigo) as gastos_no_cubiertos");
		sbSql.append(", nvl((select nvl(grang_total,0) + nvl(monto_descuento2,0) + case when trunc(fecha) >= to_date('23/03/2012','dd/mm/yyyy') then nvl(monto_descuento,0) - nvl(total_honorarios,0) - nvl(getCopagoDet(compania,f.codigo,null,null,pac_id,admi_secuencia,'FTOT'),0) else nvl(-monto_descuento,0) end - nvl((select sum(monto) from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and imprimir_sino = 'S' and centro_servicio = ");
		sbSql.append(fac.getColValue("cds_paq_per"));
		sbSql.append("),0) from tbl_fac_factura z where facturar_a = 'P' and estatus <> 'A' and admi_secuencia = f.admi_secuencia and pac_id = f.pac_id and compania = f.compania),0) as totalPaciente, nvl((select sum(decode(tipo,'COP',monto,0)) as monto_copago from tbl_fac_estado_cargos_det where pac_id = f.pac_id and admi_secuencia = f.admi_secuencia and monto > 0),0) as montoCopago, nvl((select aplica_copago from tbl_adm_beneficios_acum where pac_id = f.pac_id AND admision = f.admi_secuencia and rownum = 1),'E') as aplica_copago, (select nvl(dsp_deducible,0) from tbl_fac_factura z where facturar_a = 'P' and estatus <> 'A' and admi_secuencia = f.admi_secuencia and pac_id = f.pac_id and compania = f.compania) as dsp_deducible, (select nvl(dsp_copago,0) from tbl_fac_factura z where facturar_a = 'P' and estatus <> 'A' and admi_secuencia = f.admi_secuencia and pac_id = f.pac_id and compania = f.compania) as dsp_copago, (select nvl(dsp_coaseguro,0) from tbl_fac_factura z where facturar_a = 'P' and estatus <> 'A' and admi_secuencia = f.admi_secuencia and pac_id = f.pac_id and compania = f.compania) as dsp_coaseguro from tbl_fac_factura f where codigo = '");
		sbSql.append(fac.getColValue("codigo"));
		sbSql.append("' and compania = ");
		sbSql.append(fac.getColValue("compania"));
		CommonDataObject facTotal = SQLMgr.getData(sbSql.toString());

		pc.setNoColumnFixWidth(vTotal);
		pc.createTable("total",false,0,0.0f,148.5f);//148.5f
			pc.setFont(headerFontSize,1);
			pc.addCols(" ",0,2);
			pc.addCols(" ",0,2);
			pc.addCols("SUB-TOTAL",0,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("subtotal")),2,1);

			pc.setFont(headerFontSize,1);
			pc.addCols("DESCUENTO",0,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("monto_descuento")),2,1);

			if (fac.getColValue("facturar_a").equalsIgnoreCase("E"))
			{
				double mPac = new Double(facTotal.getColValue("totalPaciente")).doubleValue();
System.out.println("------------"+facTotal.getColValue("aplica_copago")+">"+mPac+" -- COPAGO="+facTotal.getColValue("montoCopago"));
				if (facTotal.getColValue("aplica_copago").equalsIgnoreCase("A") || fac.getColValue("seg_fact_dbl_cobert").equals("S")) mPac -= new Double(facTotal.getColValue("montoCopago")).doubleValue();
				pc.setFont(headerFontSize,1);
				pc.addCols("MONTO PACIENTE",0,1);
				pc.setFont(headerFontSize,0);
				pc.addCols(CmnMgr.getFormattedDecimal(mPac),2,1);
			}

			pc.setFont(headerFontSize,1);
			pc.addCols("TOTAL FACTURA",0,1);
			pc.setFont(headerFontSize,0);
			 pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("monto_total")),2,1);
		totalHeight = pc.getTableHeight();


/* * * * * * * * * * * * * * *   G R A N   T O T A L   * * * * * * * * * * * * * * */
		pc.setNoColumnFixWidth(vTotal);
		pc.createTable("grand_total",false,0,0.0f,148.5f);//148.5f
			pc.setVAlignment(2);
			pc.setFont(headerFontSize,1);
			pc.addCols("TOTAL FACTURA\n+ HONORARIOS",0,1);
			pc.setFont(headerFontSize,0);
			pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("gran_total")),2,1);
		gtotalHeight = pc.getTableHeight();


/* * * * * * * * * * * * * * *   O B S E R V A C I O N E S   * * * * * * * * * * * * * * */
		pc.setVAlignment(0);
		pc.setNoColumnFixWidth(vTotal);
		pc.createTable("comment",false,0,0.0f,297.0f);
			pc.setFont(headerFontSize,1);
			pc.addCols(" ",0,2);

		{
			pc.setFont(contentFontSize,0);
			if (deducible.equalsIgnoreCase("S")) {
				pc.addCols("DEDUCIBLE DEL PACIENTE",0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("dsp_deducible")),2,1);
				pc.addCols("COPAGO DEL PACIENTE",0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("dsp_copago")),2,1);
				pc.addCols("COASEGURO DEL PACIENTE",0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("dsp_coaseguro")),2,1);
			} else if (fac.getColValue("facturar_a").equalsIgnoreCase("E") && fac.getColValue("seg_fact_dbl_cobert").equals("N")) {
				pc.addCols("COPAGO DEL PACIENTE",0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("montoCopago")),2,1);
			}

			/*pc.addCols("GASTOS NO CUBIERTOS O NO ELEGIBLE",0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("gastos_no_cubiertos")),2,1);*/
		}
		commentHeight = pc.getTableHeight();


/* * * * * * * * * * * * * * *   H O N O R A R I O S   * * * * * * * * * * * * * * */
		sbSql = new StringBuffer();
		sbSql.append("select coalesce((select nvl(reg_medico,codigo) from tbl_adm_medico where codigo=medico),to_char(med_empresa)) as cod_soc_med, centro_servicio, descripcion, sum(nvl(monto,0) + nvl(descuento,0) + nvl(descuento2,0) + nvl(monto_paciente,0)) as monto_bruto, sum(nvl(monto,0))-nvl(getCopagoDet(compania,'");
		sbSql.append(fac.getColValue("codigo"));
		sbSql.append("',coalesce(medico,to_char(med_empresa)),(select descripcion from tbl_cds_centro_servicio where codigo=centro_servicio), ");
		sbSql.append(fac.getColValue("pac_id"));
		sbSql.append(",");
		sbSql.append(fac.getColValue("admi_secuencia"));
		sbSql.append(",'DETHON') ,0) as monto_neto,");
		//, sum(nvl(descuento,0)+nvl(descuento2,0)) as monto_desc
		if (fac.getColValue("facturar_a").equalsIgnoreCase("E")){
		sbSql.append("sum( nvl(descuento,0) + nvl(descuento2,0) + nvl(monto_paciente,0))+nvl(getCopagoDet(compania,'");
		sbSql.append(fac.getColValue("codigo"));
		sbSql.append("',coalesce(medico,to_char(med_empresa)),(select descripcion from tbl_cds_centro_servicio where codigo=centro_servicio),");
		sbSql.append(fac.getColValue("pac_id"));
		sbSql.append(",");
		sbSql.append(fac.getColValue("admi_secuencia"));
		sbSql.append(",'DETHON' ) ,0) ");
		}else sbSql.append("sum(nvl(descuento,0)+nvl(descuento2,0)) ");
		sbSql.append("monto_desc from tbl_fac_detalle_factura where fac_codigo = '");
		sbSql.append(fac.getColValue("codigo"));
		sbSql.append("' and compania = ");
		sbSql.append(fac.getColValue("compania"));
		sbSql.append(" and tipo != 'C' group by centro_servicio, descripcion, medico, med_empresa,compania");
		ArrayList alHon = SQLMgr.getDataList(sbSql.toString());

		pc.setNoColumnFixWidth(vHon);
		pc.createTable("honorario",false,0,0.0f,405.5f);
			pc.setFont(headerFontSize,1);
			pc.addCols("HONORARIOS",0,vHon.size());

			pc.addCols("CODIGO",1,1);
			pc.addCols("MEDICO",1,1);
			pc.addCols("CARGO",1,1);
			pc.addCols(((fac.getColValue("facturar_a").equalsIgnoreCase("E"))?"PAC. DED. + %":"DESCUENTO"),1,1);
			pc.addCols("SALDO",1,1);

		double tBruto = 0.00;
		double tDesc = 0.00;
		double tNeto = 0.00;
		for (int j=0; j<alHon.size(); j++)
		{
			CommonDataObject hon = (CommonDataObject) alHon.get(j);

			pc.setFont(contentFontSize,0);
			pc.addCols(hon.getColValue("cod_soc_med"),1,1);
			pc.addCols(hon.getColValue("descripcion"),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal(hon.getColValue("monto_bruto")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(hon.getColValue("monto_desc")),2,1);//(z!=0)?cdoHon.getColValue("monto_pac"):cdoHon.getColValue("monto_desc")
			pc.addCols(CmnMgr.getFormattedDecimal(hon.getColValue("monto_neto")),2,1);

			tBruto += Double.parseDouble(hon.getColValue("monto_bruto"));
			tDesc += Double.parseDouble(hon.getColValue("monto_desc"));
			tNeto += Double.parseDouble(hon.getColValue("monto_neto"));
		}
			pc.setFont(contentFontSize,1);
			pc.addCols("TOTALES",0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(tBruto),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(tDesc),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(tNeto),2,1);
		honHeight = pc.getTableHeight();


/* * * * * * * * * * * * * * *   D E T A L L E S   F A C T U R A   * * * * * * * * * * * * * * */
		pc.setNoColumnFixWidth(vContent);
		pc.createTable(true);
			pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, vContent.size());

			pc.addTableToCols("invoice",0,vContent.size());

			pc.setFont(headerFontSize,1);
			pc.resetVAlignment();
			/*
			pc.addCols("C O D I G O",1,1);
			pc.addCols("D E S C R I P C I O N",1,2);
			pc.addCols("M O N T O",1,1);
			*/
			pc.addCols(" ",1,4);
			pc.addCols(" ",1,4);
			pc.addCols(" ",1,4);
		pc.setTableHeader(3);
		headerHeight = pc.getTableHeight();

		float xtraHeight = ((totalHeight > commentHeight)?totalHeight:commentHeight) + ((gtotalHeight > honHeight)?gtotalHeight:honHeight);
		if (xtraHeight < 250) xtraHeight = 250;
		availHeight = height - (topMargin + bottomMargin + headerHeight + footerHeight + xtraHeight);
		//if (fac.getColValue("tipo_factura").equals("0"))
		{
			sbSql = new StringBuffer();
			/*
			sbSql.append("select 'Q' as tc, 2 as nivel, -1 as cds, a.descripcion, sum(nvl(a.monto,0)) as monto from tbl_fac_detalle_factura a where a.fac_codigo = '");
			sbSql.append(fac.getColValue("codigo"));
			sbSql.append("' and a.compania = ");
			sbSql.append(fac.getColValue("compania"));
			sbSql.append(" and a.tipo_cobertura = 'Q' group by a.descripcion");
			sbSql.append(" union select 'CO' as tc, 2 as nivel, -1 as cds, a.descripcion, sum(nvl(a.monto,0) + nvl(a.descuento,0) + nvl(a.monto_paciente,0) + nvl(a.descuento2,0)) as monto from tbl_fac_detalle_factura a where a.fac_codigo = '");
			sbSql.append(fac.getColValue("codigo"));
			sbSql.append("' and a.compania = ");
			sbSql.append(fac.getColValue("compania"));
			sbSql.append(" and a.centro_servicio <> 0 and a.tipo_cobertura = 'CO' group by a.descripcion");
			sbSql.append(" union select 'CO' as tc, 3 as nivel, a.centro_servicio as cds, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as descripcion, sum(nvl(a.monto,0) + nvl(a.descuento,0) + nvl(a.monto_paciente,0)) as monto from tbl_fac_detalle_factura a where a.fac_codigo = '");
			sbSql.append(fac.getColValue("codigo"));
			sbSql.append("' and a.compania = ");
			sbSql.append(fac.getColValue("compania"));
			sbSql.append(" and a.centro_servicio <> 0 and a.tipo_cobertura = 'CO' group by a.centro_servicio");
			sbSql.append(" union select 'MEDICAMENTOS' as tc, 2 as nivel, -1 as cds, a.descripcion, sum(nvl(a.monto,0) + nvl(a.descuento,0) + nvl(a.monto_paciente,0)) as monto from tbl_fac_detalle_factura a where a.fac_codigo = '");
			sbSql.append(fac.getColValue("codigo"));
			sbSql.append("' and a.compania = ");
			sbSql.append(fac.getColValue("compania"));
			sbSql.append(" and a.centro_servicio <> 0 and a.descripcion like '%MEDICAMENTOS%' group by a.descripcion");
			sbSql.append(" union select 'I' as tc, 1 as nivel, a.centro_servicio as cds, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as descripcion, sum(nvl(a.monto,0) + nvl(a.descuento,0) + nvl(a.descuento2,0) + nvl(a.monto_paciente,0)) as monto from tbl_fac_detalle_factura a where a.fac_codigo = '");
			sbSql.append(fac.getColValue("codigo"));
			sbSql.append("' and a.compania = ");
			sbSql.append(fac.getColValue("compania"));
			sbSql.append(" and a.centro_servicio <> 0  and (a.tipo_cobertura not in ('CO','Q') or a.tipo_cobertura is null) group by a.centro_servicio");
			*/
			sbSql.append("select a.centro_servicio as cds, /*nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),a.descripcion) as */descripcion, sum(nvl(a.monto,0) + nvl(a.descuento,0) + nvl(a.descuento2,0) + nvl(a.monto_paciente,0)) as monto from tbl_fac_detalle_factura a where a.fac_codigo = '");
			sbSql.append(fac.getColValue("codigo"));
			sbSql.append("' and a.compania = ");
			sbSql.append(fac.getColValue("compania"));
			sbSql.append(" and a.tipo = 'C' and a.imprimir_sino = 'S' group by a.centro_servicio,a.descripcion");
			alDet = SQLMgr.getDataList(sbSql.toString());
		}
		tDetailHeight = 0.0f;
		for (int j=0; j<alDet.size(); j++)
		{
			CommonDataObject det = (CommonDataObject) alDet.get(j);
			float tBorder = 0.0f;
			if (j == 0) tBorder = 0.5f;

			tempHeight = pc.getTableHeight();
			pc.setFont(contentFontSize,0);
			pc.addCols(det.getColValue("cds"),1,1);
			pc.addCols(det.getColValue("descripcion"),0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(det.getColValue("monto")),2,1);
			detailHeight = pc.getTableHeight() - tempHeight;
			tDetailHeight += detailHeight;
			if (tDetailHeight > availHeight)
			{
				int ltotal  = (new Double(""+((detailHeight - 4) / contentFontSize))).intValue();
				int ldisp = (new Double(""+((availHeight - (tDetailHeight - detailHeight) - 4) / contentFontSize))).intValue();
				int lpend = ltotal - ldisp;
				tDetailHeight = (lpend * contentFontSize) + 4;
			}
		}//alDet
		if (alDet.size() == 0) pc.addCols("No existen registros",1,vContent.size());
		else
		{
/* * * * * * * * * * * * * * *   R E L L E N O   * * * * * * * * * * * * * * */
			detailHeight = availHeight - tDetailHeight;
			pc.addCols(" ",0,1,detailHeight);
			pc.addCols(" ",0,2);
			pc.addCols(" ",0,1);
		}

		pc.addTableToCols("comment",0,2);
		pc.addTableToCols("total",0,2);

		pc.addCols(" ",0,4);

		pc.setVAlignment(2);
		pc.addTableToCols("honorario",0,2);
		pc.addTableToCols("grand_total",0,2);

		pc.flushTableBody(true);
		pc.close();
		//response.sendRedirect(redirectFile);
	}//alFac
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
function closeWindow(){<%for (int i=0; i<alFac.size(); i++) { CommonDataObject fac = (CommonDataObject) alFac.get(i); %>window.open('../pdfdocs/facturacion/<%=year%>/<%=month%>/<%=servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))%>_<%=fac.getColValue("codigo")%>_<%=fac.getColValue("compania")%>_<%=pacId%>_<%=admision%>.pdf','factura<%=i%>',getPopUpOptions(false,true,false,false));<% } %>window.close();}
</script>
</head>
<body <%/*if(fp!=null && fp.equals("lista_envio")){%>onLoad="javascript:window.close();"<%}*/%>>
<%if(fp!=null && fp.equals("lista_envio")){%>
<%} else {%>
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<%
StringBuffer sbTab = new StringBuffer();
for (int i=0; i<alFac.size(); i++)
{
	CommonDataObject fac = (CommonDataObject) alFac.get(i);
	if (sbTab.length() > 0) sbTab.append("','");
	sbTab.append(fac.getColValue("facturar_a"));
	sbTab.append(fac.getColValue("codigo"));
%>
<!-- TAB<%=i%> DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<%if(!codFactPac.equals("")){%>
<iframe name="print_fact_pac" id="print_fact_pac" frameborder="0" align="center" width="100%" height="30" scrolling="no" src="../common/reg_pago.jsp?tipoCliente=<%=fac.getColValue("facturar_a")%>"></iframe>
<%}%>
<iframe name="<%=fac.getColValue("codigo")%>" id="<%=fac.getColValue("codigo")%>" frameborder="0" align="center" width="100%" height="550" scrolling="no" src="../pdfdocs/facturacion/<%=year%>/<%=month%>/<%=servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))%>_<%=fac.getColValue("codigo")%>_<%=fac.getColValue("compania")%>_<%=pacId%>_<%=admision%>.pdf"></iframe>
<!-- TAB<%=i%> DIV END HERE-->
</div>
<%
}
%>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<% if (sbTab.length() > 0) { %>initTabs('dhtmlgoodies_tabView1',Array('<%=sbTab%>'),0,'100%','');<% } %>
function printFact(tipoCliente){
var refId='';
if(tipoCliente=='P')refId='<%=pacId%>';
else if(tipoCliente=='E')refId='<%=empresa%>';
abrir_ventana1('../caja/reg_recibo.jsp?tipoCliente='+tipoCliente+'&mode=add&fp=factura&pac_id=<%=pacId%>&factura=<%=codFactPac%>&refId='+refId);
}
</script><%}%>
</body>
</html>
<%
}//GET
%>
