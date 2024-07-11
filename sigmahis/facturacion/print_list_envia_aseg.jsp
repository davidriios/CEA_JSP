<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
 reporte :   COM0000.rdf
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdoH = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String compania = (String) session.getAttribute("_companyId");
String cod_empresa     = request.getParameter("cod_empresa");
String facturas_a   = request.getParameter("facturas_a");
String lista    = request.getParameter("lista");
String fecha_envio     = request.getParameter("fecha_envio");
String categoria     = request.getParameter("categoria");

sql ="select a.compania, to_char(a.fecha_envio, 'dd/mm/yyyy') fecha_envio, a.facturar_a, a.aseguradora, b.nombre aseguradora_desc, a.categoria, c.descripcion categoria_desc, a.lista, a.comentario, a.enviado_por,to_char(a.fecha_recibido, 'dd/mm/yyyy') fecha_recibido from tbl_fac_lista a, tbl_adm_empresa b, tbl_adm_categoria_admision c where a.aseguradora = b.codigo and a.categoria = c.codigo and a.compania = "+compania+" and a.aseguradora = "+cod_empresa+" and a.facturar_a = '"+facturas_a+"' and a.lista = "+lista+" and trunc(fecha_envio) = to_date('"+fecha_envio+"', 'dd/mm/yyyy') and a.categoria="+categoria;
cdoH = SQLMgr.getData(sql);
if(cdoH == null){cdoH =new CommonDataObject();}

sql = "select b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombre_paciente, to_char(b.fecha_nacimiento,'dd/mm/yyyy') || '-' || b.codigo || '-' || a.secuencia cod_paciente, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, to_char(a.fecha_egreso, 'dd/mm/yyyy') fecha_egreso, a.dias_hospitalizados, (select poliza from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and nvl(estado, 'A') = 'A' and empresa = f.cod_empresa and prioridad = (case when f.tipo_cobertura is null then 1 when tipo_cobertura = 'D' then 2 end)) poliza, (select certificado from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and nvl(estado, 'A') = 'A' and empresa = f.cod_empresa and prioridad = (case when f.tipo_cobertura is null then 1 when tipo_cobertura = 'D' then 2 end)) certificado, f.codigo factura, f.grang_total, c.codigo centro_servicio, c.descripcion centro_servicio_desc from tbl_fac_factura f, tbl_adm_admision a, tbl_adm_paciente b, tbl_cds_centro_servicio c where ((f.facturar_a = '"+facturas_a+"') and f.estatus in ('P','C') and trunc(f.fecha_enviado) = to_date('"+fecha_envio+"', 'dd/mm/yyyy')) and f.cod_empresa = "+cod_empresa+" and f.lista = "+lista+" and f.pac_id = a.pac_id and  f.admi_secuencia = a.secuencia and f.pac_id = b.pac_id and a.categoria = "+categoria+" and a.centro_servicio = c.codigo order by c.codigo, a.fecha_ingreso";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String time_stamp = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+time_stamp+"_"+UserDet.getUserId()+".pdf";

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
	String statusPath = ResourceBundle.getBundle("path").getString("images")+"/anulado.png";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float dispHeight = 0.0f;//altura disponible para el ciclo for 
	float headerHeight = 0.0f;//tamaño del encabezado
	float innerHeight = 0.0f;//tamaño del detalle
	float footerHeight = 0.0f;//tamaño del footer
	float modHeight = 0.0f;//tamaño del relleno en blanco
	float antHeight = 0.0f;//
	float finHeight = 0.0f;//
	float extra = 0.0f;//
	//float total = 0.0f;//
	float innerTableHeight = 0.0f;
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 30.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMPAÑIA: "+ cdoH.getColValue("aseguradora_desc");
	String subtitle = "LISTA NO. "+ lista;
	String xtraSubtitle = "CATEGORIA "+ cdoH.getColValue("categoria_desc");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 25.0f;
	int  j = 0;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);

	Vector infoCol = new Vector();
		infoCol.addElement(".34");
		infoCol.addElement(".13");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".05");
		infoCol.addElement(".07");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".09");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "";
	String descTotal = "";
	pc.setVAlignment(0);
	boolean printSubTotal = true;
	double subtotal = 0.00, total = 0.00;
	int count = 0, totCount = 0;
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("centro_servicio"))){ // groupBy
			pc.setFont(7, 0);
			if(i!=0 && printSubTotal){
				pc.addBorderCols("TOTAL PACIENTES POR CENTRO:",2,2,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+count,2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols("TOTAL",2,5,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(subtotal),2,1,0.0f,0.1f,0.0f,0.0f);
				subtotal = 0.00;
				count=0;
			}
			pc.setFont(7, 0);
			pc.addBorderCols("CENTRO: "+cdo.getColValue("centro_servicio_desc"),1,9,0.0f,0.1f,0.0f,0.0f);
			
			pc.setFont(7, 0, Color.blue);
			pc.addBorderCols("ASEGURADO O DEPENDIENTE",1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("CODIGO PACIENTE",0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("F. INGRESO",1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("F. EGRESO",1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("DIAS",1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("POLIZA",0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("CERT.",1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("FACTURA",1,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("TOTAL",1,1,0.1f,0.0f,0.0f,0.0f);
		}
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("nombre_paciente"),0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("cod_paciente"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("fecha_ingreso"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("fecha_egreso"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("dias_hospitalizados"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("poliza"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("certificado"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("factura"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total")),2,1,0.0f,0.0f,0.0f,0.0f);

		groupBy = cdo.getColValue("centro_servicio");
		subtotal += Double.parseDouble(cdo.getColValue("grang_total"));
		total += Double.parseDouble(cdo.getColValue("grang_total"));
		count++;
		totCount++;
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	if(al.size()>0){
		if(printSubTotal)
		{
			pc.addBorderCols("TOTAL PACIENTES POR CENTRO:",2,2,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+count,2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols("TOTAL",2,5,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(subtotal),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols("TOTAL DE PACIENTES:",2,2,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+totCount,2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols("TOTAL",2,5,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.1f,0.0f,0.0f);
		}
		pc.addBorderCols("",0,9,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("OBSERVACIONES:",0,9,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdoH.getColValue("comentario"),0,9,0.5f,0.5f,0.5f,0.5f, 24.0f);

		pc.addBorderCols("",0,9,0.0f,0.0f,0.0f,0.0f);

		pc.addBorderCols("Enviado por: "+cdoH.getColValue("enviado_por"),0,5,0.0f,0.5f,0.5f,0.0f);
		pc.addBorderCols("Recibido por: ",0,4,0.0f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Fecha de Envío: "+cdoH.getColValue("fecha_envio"),0,5,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols("Fecha de Recibido: "+cdoH.getColValue("fecha_recibido"),0,4,0.5f,0.0f,0.0f,0.5f);
	}

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>