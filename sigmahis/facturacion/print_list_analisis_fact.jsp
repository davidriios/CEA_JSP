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
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");

if(fg==null) fg = "AFA";
if (appendFilter == null) appendFilter = "";


if (fg.equalsIgnoreCase("POS")) {

	sbSql.append("select distinct (select getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente) from dual) as nombre, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, (select descripcion from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referDesc from tbl_fac_factura a where a.estatus <> 'A' and  a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" order by 1");

} else {

	sbSql = new StringBuffer();
	sbSql.append("select a.codigo as cod_factura, a.numero_factura, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo, a.estatus, a.grang_total, a.admi_codigo_paciente as codigo,decode(a.facturar_a,'O',(select getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente) from dual),(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre, a.admi_secuencia, a.pac_id, a.cod_empresa, decode(a.facturar_a,'P','Paciente','E','Empresa','O','Otros') as tipo_factura, to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.admi_codigo_paciente, (select d.nombre from tbl_adm_empresa d where d.codigo = a.cod_empresa) as nombre_empresa, decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA') as estatusDesc");
	sbSql.append(", nvl(join(cursor(select distinct (select lista from tbl_fac_lista_envio where compania = led.compania and id = led.id) from tbl_fac_lista_envio_det led where led.estado = 'A' and led.factura = a.codigo and led.compania = a.compania and exists (select null from tbl_fac_lista_envio where compania = led.compania and id = led.id and estado = 'A')),', '),' ') as lista");
	sbSql.append(", a.tipo_cobertura, a.compania, a.facturar_a, nvl((select count(*) from tbl_fac_dgi_documents where tipo_docto in ('FACP','FACT') and impreso = 'Y' and codigo = a.codigo),0) as facImpresa, nvl((select id from tbl_fac_dgi_documents where tipo_docto in('FACP','FACT') and codigo = a.codigo and rownum = 1 and compania = a.compania),0) as ref_dgi, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, decode(comentario,'S/I','S','N') as saldoInicial, (select fn_cja_saldo_fact(a.facturar_a, a.compania,a.codigo,a.grang_total) from dual) as saldo, a.f_anio as anio, a.comentario_an, usuario_anulacion, to_char(fecha_anulacion,'dd/mm/yyyy') as fecha_anulacion from tbl_fac_factura a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	//sbSql.append(" and a.facturar_a in('E','P') ");
	sbSql.append(appendFilter);
	//sbSql.append(" order by a.fecha desc, a.codigo desc");
	sbSql.append(" order by a.f_anio desc,a.numero_factura desc");

}
al = SQLMgr.getDataList(sbSql.toString());

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
	String title = "FACTURACION";
	String subtitle = "ANALISIS Y FACTURACION";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".04");
		dHeader.addElement(".06");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8,1);
		pc.addBorderCols("Factura",0);
		pc.addBorderCols("Tipo Fact.",1);
		pc.addBorderCols("F. Fact.",1);
		pc.addBorderCols("No. Pac.",1);
		pc.addBorderCols("Adm.",1);
		pc.addBorderCols("F. Nac.",1);
		pc.addBorderCols("Nombre",0);
		pc.addBorderCols("Cia. Seguros",0);
		pc.addBorderCols("Estado",0);
		pc.addBorderCols("Lista",1);
		pc.addBorderCols("Monto",1);
		pc.addBorderCols("Saldo",1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	pc.setVAlignment(0);
	pc.setFont(8,0);

	double monto = 0.00,saldo = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		pc.addCols(cdo.getColValue("cod_factura"),0,1);
		pc.addCols(cdo.getColValue("tipo_factura"),1,1);
		pc.addCols(cdo.getColValue("fecha"),0,1);
		pc.addCols(cdo.getColValue("pac_id"),1,1);
		pc.addCols(cdo.getColValue("admi_secuencia"),1,1);
		pc.addCols(cdo.getColValue("fecha_nacimiento"),0,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(cdo.getColValue("nombre_empresa"),0,1);
		pc.addCols(cdo.getColValue("estatusDesc"),0,1);
		pc.addCols(cdo.getColValue("lista"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);
		monto += Double.parseDouble(cdo.getColValue("grang_total"));
		saldo += Double.parseDouble(cdo.getColValue("saldo"));

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		pc.setFont(8,1);
		pc.addCols(new StringBuffer().append(al.size()).append(" Registros").toString(),0,8);
		pc.addCols("Total ------------------------->",2,2);
		pc.addCols(CmnMgr.getFormattedDecimal(monto),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>