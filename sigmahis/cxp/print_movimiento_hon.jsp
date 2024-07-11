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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlSI = new StringBuffer();
String userName = UserDet.getUserName();
String beneficiario = request.getParameter("beneficiario");
String tipo = request.getParameter("tipo");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";

	sbSql.append("select decode('");
	sbSql.append(tipo);
	sbSql.append("', 'E', (select nombre from tbl_adm_empresa e where e.codigo = ");
	sbSql.append(beneficiario);
	sbSql.append("), (select decode(m.sexo, 'F', 'Dra. ', 'Dr. ') || m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = '");
	sbSql.append(beneficiario);
	sbSql.append("')) nombre_beneficiario from dual");

	cdo1 = SQLMgr.getData(sbSql.toString());
	
	sbSql = new StringBuffer();

	sbSql.append("select * from (select 'E' tipo, 'H' tipo_doc, 'HONORARIOS' tipo_doc_desc, f.compania, f.codigo, f.fecha, to_char(f.fecha, 'dd/mm/yyyy') fecha_docto, p.nombre_paciente || ' - ' || f.pac_id || ' - ' || f.admi_secuencia || ' - No. Orden '|| getBoletasHon(f.pac_id, f.admi_secuencia, df.med_empresa) nombre_referencia, to_char(df.med_empresa) beneficiario, (select nombre from tbl_adm_empresa e where e.codigo = df.med_empresa) nombre_beneficiario, decode(df.monto, 0, df.monto_paciente, df.monto) debito, 0 credito from tbl_fac_factura f, tbl_fac_detalle_factura df, vw_adm_paciente p where f.codigo = df.fac_codigo and f.compania = df.compania and f.estatus = 'P' and df.centro_servicio = 0 and f.pac_id = p.pac_id and df.med_empresa is not null and df.monto > 0 union select 'M' tipo, 'H' tipo_doc, 'HONORARIOS' tipo_doc_desc, f.compania, f.codigo, f.fecha, to_char(f.fecha, 'dd/mm/yyyy') fecha_docto, p.nombre_paciente || ' - ' || f.pac_id || ' - ' || f.admi_secuencia || ' - No. Orden '|| getBoletasHon(f.pac_id, f.admi_secuencia, df.medico) nombre_referencia, df.medico beneficiario, (select decode(m.sexo, 'F', 'Dra. ', 'Dr. ') || m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = df.medico) nombre_beneficiario, decode(df.monto, 0, df.monto_paciente, df.monto) debito, 0 credito from tbl_fac_factura f, tbl_fac_detalle_factura df, vw_adm_paciente p where f.codigo = df.fac_codigo and f.compania = df.compania and f.estatus = 'P' and df.centro_servicio = 0 and f.pac_id = p.pac_id and df.med_empresa is null and df.monto > 0 union select 'E' tipo, 'P' tipo_doc, 'PAGO' tipo_doc_desc, c.cod_compania, c.num_cheque, c.f_emision, to_char(c.f_emision, 'dd/mm/yyyy') fecha_docto, c.beneficiario nombre_referencia, a.num_id_beneficiario beneficiario, (select nombre from tbl_adm_empresa e where e.codigo = a.cod_empresa) nombre_beneficiario, 0 debito, decode (c.estado_cheque, 'G', b.monto_a_pagar, 0) credito from   tbl_cxp_orden_de_pago a, tbl_cxp_detalle_orden_pago b, tbl_con_cheque c where a.estado = 'A' and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago and a.cod_compania = b.cod_compania and (a.cod_tipo_orden_pago = 3 and a.tipo_orden in ('E')) and a.anio = c.anio and a.num_orden_pago = c.num_orden_pago and a.cod_compania = c.cod_compania_odp union select 'M' tipo, 'P' tipo_doc, 'PAGO' tipo_doc_desc, c.cod_compania, c.num_cheque, c.f_emision, to_char(c.f_emision, 'dd/mm/yyyy') fecha_docto, c.beneficiario nombre_referencia, a.num_id_beneficiario beneficiario, (select decode(m.sexo, 'F', 'Dra. ', 'Dr. ') || m.primer_nombre || decode (m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode (m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode (m.sexo, 'F', decode (m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = a.cod_medico) nombre_beneficiario, 0 debito, decode (c.estado_cheque, 'G', b.monto_a_pagar, 0) credito from tbl_cxp_orden_de_pago a, tbl_cxp_detalle_orden_pago b, tbl_con_cheque c where a.estado = 'A' and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago and a.cod_compania = b.cod_compania and a.cod_tipo_orden_pago = 1 and a.anio = c.anio and a.num_orden_pago = c.num_orden_pago and a.cod_compania = c.cod_compania_odp) where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and beneficiario = '");
	sbSql.append(beneficiario);
	sbSql.append("' and tipo = '");
	sbSql.append(tipo);
	sbSql.append("'");
	
	sbSqlSI.append("select nvl(sum((case when fecha < to_date('");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("','dd/mm/yyyy') then debito end)), 0) - nvl(sum((case when fecha < to_date('");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("','dd/mm/yyyy') then credito end)), 0) saldo_inicial from (");
	sbSqlSI.append(sbSql.toString());
	sbSqlSI.append(")");
	System.out.println("SQL SI=\n"+sbSqlSI.toString());
	cdoSI = SQLMgr.getData(sbSqlSI.toString());

	sbSql.append(" and trunc(fecha) between to_date('");
	sbSql.append(fechaini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fechafin);
	sbSql.append("', 'dd/mm/yyyy')");

		System.out.println("SQL al=\n"+sbSql.toString());
		al = SQLMgr.getDataList(sbSql.toString());
		
		cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sbSql.toString()+")");

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
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "HONORARIOS Y PAGOS";
	String subtitle = beneficiario + " - " +cdo1.getColValue("nombre_beneficiario");
	String xtraSubtitle = "Fecha de Referencia entre " + fechaini + " - " + fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".05");
		infoCol.addElement(".48");
		infoCol.addElement(".10");
		infoCol.addElement(".07");
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

		//second row
		pc.setVAlignment(0);
		pc.addBorderCols("Tipo Doc.",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Descripción",0,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("No. Doc.",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Débito",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Crédito",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Saldo",1,1,0.5f,0.5f,0.0f,0.0f);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "";
	
	pc.setVAlignment(0);

	pc.addCols("Saldo Inicial",2,4);
	pc.addCols(" ",1,1);
	pc.addCols(" ",1,1);
	pc.addCols((cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")?CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial")):""),2,1);
	double saldo = 0.00;
	if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		saldo += Double.parseDouble(cdo.getColValue("debito"));
		saldo -= Double.parseDouble(cdo.getColValue("credito"));

		pc.setFont(6, 0);
		pc.addCols(cdo.getColValue("tipo_doc"),1,1);
		pc.addCols(cdo.getColValue("tipo_doc_desc")+(cdo.getColValue("tipo_doc").equals("H")? "  -  "+cdo.getColValue("nombre_referencia"):""),0,1);
		pc.addCols(cdo.getColValue("codigo"),1,1);
		pc.addCols(cdo.getColValue("fecha_docto"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(saldo),2,0);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	pc.setFont(7, 0);
	pc.addBorderCols("Total",2,4,0.0f,0.0f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("debito")),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("credito")),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo),2,1,0.0f,0.5f,0.0f,0.0f);

	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>