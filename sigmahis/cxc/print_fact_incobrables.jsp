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

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdoXtra = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String fg  = request.getParameter("fg");
String lista  = request.getParameter("lista");
String anio  = request.getParameter("anio");
String titulo  = request.getParameter("titulo");

if (fg == null) fg = "FI";
if (appendFilter == null) appendFilter = "";
if (titulo == null) titulo = "";



sbSql.append("select (select nombre_paciente from vw_adm_paciente where pac_id = c.pac_id) as nombre_paciente, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = c.pac_id) as fechaNacimiento, c.codigo_paciente, c.secuencia, to_char(c.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, c.factura, c.lista, c.empresa, c.cobrador, c.rebajar, c.categoria, c.estado, c.monto_lista, c.usuario_creacion, c.fecha_creacion, c.usuario_modifica, c.fecha_modifica, c.anio, c.pase, c.pase_k, /*c.cuenta_i,*/c.pac_id, c.compania");
sbSql.append(", nvl((select sum(nvl(a_amount,monto_rebajado)) from tbl_cxc_det_cuentasm where compania = c.compania and anio = c.anio and lista = c.lista and factura = c.factura),0) as ajustar");
sbSql.append(", nvl((select sum(monto_rebajado) from tbl_cxc_det_cuentasm where compania = c.compania and anio = c.anio and lista = c.lista and factura = c.factura and empresa is null and medico is null),0) as centros");
sbSql.append(", nvl((select sum(monto_rebajado) from tbl_cxc_det_cuentasm where compania = c.compania and anio = c.anio and lista = c.lista and factura = c.factura and medico is not null),0) as medicos");
sbSql.append(", nvl((select sum(monto_rebajado) from tbl_cxc_det_cuentasm where compania = c.compania and anio = c.anio and lista = c.lista and factura = c.factura and empresa is not null),0) as empresas");
sbSql.append(", (select tipo_cta from tbl_adm_admision where pac_id = c.pac_id and secuencia = c.secuencia) as tipo_cta, (select nombre from tbl_adm_empresa where codigo = c.empresa) as empresa_name, getMontoCopago(c.compania, c.factura) as copago, (select descripcion from tbl_fac_tipo_ajuste where codigo = c.tipo_ajuste and compania = c.compania) as descAjuste from tbl_cxc_cuentasm c where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and c.anio =");
sbSql.append(anio);
sbSql.append(" and c.lista =");
sbSql.append(lista);
sbSql.append(" and c.rebajar = 'S' order by 1");
al = SQLMgr.getDataList(sbSql.toString());



sbSql = new  StringBuffer();
sbSql.append("select decode(to_char(x.empresa),null,decode(x.medico,null,decode(x.tipo_cds,'I','A','E','A','T','B'),'C'),'D') as orden, decode(to_char(x.empresa),null,decode(x.medico,null,to_char(x.centro),x.medico),to_char(x.empresa)) as codigo_cs, x.monto, nvl(decode(to_char(x.empresa),null,decode(x.medico,null,descCds,x.nom_med),x.nombre),'* * * * * * *') as descripcion from ( ");
	sbSql.append("select det.centro, det.medico, det.empresa, nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) as monto, nvl(cds.descripcion,det.descripcion) as descCds, med.primer_nombre||' '||med.primer_apellido||' '||decode(med.sexo,'F',decode(med.apellido_de_casada,null,med.segundo_apellido,med.apellido_de_casada),'M',med.segundo_apellido) as nom_med, e.nombre, nvl(cds.tipo_cds,'I') as tipo_cds from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_cds_centro_servicio cds, tbl_adm_medico med, tbl_adm_empresa e where cm.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and cm.anio = ");
	sbSql.append(anio);
	sbSql.append(" and cm.lista = ");
	sbSql.append(lista);
	sbSql.append(" and cm.rebajar = 'S' and (cm.lista = det.lista and cm.factura = det.factura) and det.centro = cds.codigo(+) and det.medico = med.codigo(+) and det.empresa = e.codigo(+) group by det.descripcion, det.centro, det.medico, det.empresa, cds.descripcion, med.primer_nombre||' '||med.primer_apellido||' '||decode(med.sexo,'F',decode(med.apellido_de_casada,null,med.segundo_apellido,med.apellido_de_casada),'M',med.segundo_apellido), e.nombre, nvl(cds.tipo_cds,'I')");
sbSql.append(" ) x order by 1, 2");
al2 = SQLMgr.getDataList(sbSql.toString());



sbSql = new  StringBuffer();
sbSql.append("select nvl(z.montoClinica,0) as montoClinica, nvl(z.montoTerceros,0) as montoTerceros, nvl(z.montoMedicos,0) as montoMedicos, nvl(z.montoEmpresas,0) as montoEmpresas, nvl(z.montoClinica,0) + nvl(z.montoTerceros,0) + nvl(z.montoMedicos,0) + nvl(z.montoEmpresas,0) as totalAnual, nvl(z.revCentros,0) as revCentros, nvl(z.revTerceros,0) as revTerceros, nvl(z.revMedicos,0) as revMedicos, nvl(z.revEmpresas,0) as revEmpresas, nvl(z.revCentros,0) + nvl(z.revTerceros,0) + nvl(z.revMedicos,0) + nvl(z.revEmpresas,0) as totalRev, nvl(z.clinicaLista,0) as clinicaLista, nvl(z.medicosLista,0) as medicosLista, nvl(z.empresasLista,0) as empresasLista, nvl(z.tercerosLista,0) as tercerosLista, nvl(z.clinicaLista,0) + nvl(z.medicosLista,0) + nvl(z.empresasLista,0) + nvl(z.tercerosLista,0) as totalLista from ( ");

	sbSql.append("select ( ");
		sbSql.append("select sum(monto) from (");
			sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) as monto from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_cds_centro_servicio cds where (cm.lista <= ");
			sbSql.append(lista);
			sbSql.append(" and cm.anio = ");
			sbSql.append(anio);
			sbSql.append(" and cm.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and cm.rebajar = 'S') and (cm.lista = det.lista and cm.factura = det.factura and cm.compania = det.compania) and det.centro is not null and det.centro = cds.codigo and cds.tipo_cds in ('I','E','T')");
			sbSql.append(" union select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det where (cm.lista <= ");
			sbSql.append(lista);
			sbSql.append(" and cm.anio = ");
			sbSql.append(anio);
			sbSql.append(" and cm.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and cm.rebajar = 'S') and (cm.factura = det.factura and cm.lista = det.lista and cm.compania = det.compania) and det.medico is null and det.empresa is null and det.centro is null");
		sbSql.append(")");
	sbSql.append(" ) as montoClinica, (");
		sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_cds_centro_servicio cds where (cm.lista <= ");
		sbSql.append(lista);
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cm.rebajar = 'S') and (cm.factura = det.factura and cm.lista = det.lista and cm.compania = det.compania) and (det.centro = cds.codigo and cds.tipo_cds = 'T')");
	sbSql.append(" ) as montoTerceros, ( ");
		sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_adm_medico med where (cm.lista <= ");
		sbSql.append(lista);
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cm.rebajar = 'S') and (cm.lista = det.lista and  cm.factura = det.factura and cm.compania = det.compania) and det.centro is null and det.empresa is null and det.medico is not null and det.medico = med.codigo");
	sbSql.append(" ) as montoMedicos, ( ");
		sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_adm_empresa emp where (cm.lista <= ");
		sbSql.append(lista);
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cm.rebajar = 'S') and (cm.lista = det.lista and cm.factura = det.factura and cm.compania = det.compania) and det.centro is null and det.medico is null and det.empresa is not null and det.empresa = emp.codigo");
	sbSql.append(" ) as montoEmpresas, ( ");
		sbSql.append("select sum(nvl(revCentros,0)) from (");
			sbSql.append("select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)) as revCentros from tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n, tbl_cds_centro_servicio cds where to_char(n.fecha,'yyyy') = ");
			sbSql.append(anio);
			sbSql.append(" and n.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and n.tipo_ajuste = '92' and (n.compania = d.compania and n.codigo = d.nota_ajuste) and (d.centro is not null and d.centro <> 0 and d.centro = cds.codigo and   cds.tipo_cds in ('E','I'))");
			sbSql.append(" union select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)) from tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n where to_char(n.fecha,'yyyy') = ");
			sbSql.append(anio);
			sbSql.append(" and n.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and n.tipo_ajuste = '92' and (n.compania = d.compania and n.codigo = d.nota_ajuste) and d.medico is null and d.empresa is null and d.centro is null and (d.descripcion like ('PERDIEM%') or d.descripcion like('COPAGO%') or d.descripcion like ('%PAQUETE DE DIALISIS%') or d.descripcion like ('%PAQUETE%'))");
		sbSql.append(")");
	sbSql.append(" ) as revCentros, ( ");
		sbSql.append("select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)) from tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n, tbl_cds_centro_servicio cds where to_char(n.fecha,'yyyy') = ");
		sbSql.append(anio);
		sbSql.append(" and n.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and (n.tipo_ajuste = '92') and (n.compania = d.compania and n.codigo = d.nota_ajuste) and d.centro is not null and (d.centro = cds.codigo and cds.tipo_cds = 'T')");
	sbSql.append(") as revTerceros, ( ");
		sbSql.append("select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)) from tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n, tbl_adm_medico med where to_char(n.fecha,'yyyy') = ");
		sbSql.append(anio);
		sbSql.append(" and n.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and (n.tipo_ajuste = '92') and (n.compania = d.compania and n.codigo = d.nota_ajuste) and (d.centro is null or d.centro = 0) and d.empresa is null and d.medico is not null and d.medico = med.codigo");
	sbSql.append(" ) as revMedicos, ( ");
		sbSql.append("select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)) as revEmpresas from tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n, tbl_adm_empresa emp where  to_char(n.fecha,'yyyy') = ");
		sbSql.append(anio);
		sbSql.append(" and n.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and (n.tipo_ajuste = '92') and (n.compania = d.compania and n.codigo = d.nota_ajuste) and (d.centro is null or d.centro = 0) and d.medico is null and d.empresa is not null and d.empresa = emp.codigo");
	sbSql.append(") as revEmpresas, ( ");
		sbSql.append("select sum(monto) from (");
			sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) as monto from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_cds_centro_servicio cds where (cm.lista = ");
			sbSql.append(lista);
			sbSql.append(" and cm.anio = ");
			sbSql.append(anio);
			sbSql.append(" and cm.rebajar = 'S') and (cm.lista = det.lista and cm.factura = det.factura and cm.compania = det.compania) and det.medico is null and det.empresa is null and  det.centro > 0 and (det.centro = cds.codigo and cds.tipo_cds in ('I','E'))");
			sbSql.append(" union select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det where (cm.lista = ");
			sbSql.append(lista);
			sbSql.append(" and cm.anio = ");
			sbSql.append(anio);
			sbSql.append(" and cm.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and cm.rebajar = 'S') and (cm.factura = det.factura and cm.lista = det.lista and cm.compania = det.compania) and det.medico is null and det.empresa is null and det.centro is null");
		sbSql.append(")");
	sbSql.append(" ) as clinicaLista, ( ");
		sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) as terceros from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_cds_centro_servicio cds where (cm.lista = ");
		sbSql.append(lista);
		sbSql.append(" and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.rebajar = 'S') and (cm.factura = det.factura and cm.lista = det.lista and cm.compania = det.compania) and (det.centro = cds.codigo and cds.tipo_cds = 'T')");
	sbSql.append(" ) as tercerosLista, ( ");
		sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_adm_medico med where (cm.lista = ");
		sbSql.append(lista);
		sbSql.append(" and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.rebajar = 'S') and (cm.lista = det.lista and cm.factura = det.factura and cm.compania = det.compania) and (det.centro is null or det.centro = 0) and det.empresa is null and det.medico is not null and det.medico = med.codigo");
	sbSql.append(" ) as medicosLista, ( ");
		sbSql.append("select nvl(sum(nvl(det.a_amount,det.monto_rebajado)),0) from tbl_cxc_cuentasm cm, tbl_cxc_det_cuentasm det, tbl_adm_empresa emp where (cm.lista = ");
		sbSql.append(lista);
		sbSql.append(" and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.rebajar = 'S') and (cm.lista = det.lista and cm.factura = det.factura and  cm.compania = det.compania) and det.centro is null and det.medico is null and det.empresa is not null and det.empresa = emp.codigo");
	sbSql.append(") as empresasLista from dual");

sbSql.append(" ) z");
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

if(al.size() !=0)cdoXtra = (CommonDataObject) al.get(0);
else cdoXtra.addColValue("descAjuste","");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
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

	String servletPath = request.getServletPath();
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	boolean logoMark = true;
	boolean statusMark = false;
	boolean isLandscape = false;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 7;
	int groupFontSize = 7;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();

	String xtraCompanyInfo = "";
	String title = "CUENTAS POR COBRAR";
	String subtitle = "ENVIO DE CUENTAS INCOBRABLES - "+cdoXtra.getColValue("descAjuste");
	String xtraSubtitle = " LISTA  NO:  "+anio+"   -   "+lista + " " + titulo;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".13");
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".04");
		dHeader.addElement(".06");
		dHeader.addElement(".11");
		dHeader.addElement(".06");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Paciente",1,2);
		pc.addBorderCols("Fecha Nac.",1);
		pc.addBorderCols("Pac.ID",1);
		pc.addBorderCols("Adm.",1);
		pc.addBorderCols("Factura",1);
		pc.addBorderCols("Aseguradora",1);
		pc.addBorderCols("Fecha Ingreso",1);
		pc.addBorderCols("Tipo Cta",1);
		pc.addBorderCols("Centros",1);
		pc.addBorderCols("Médicos",1);
		pc.addBorderCols("Empresas",1);
		pc.addBorderCols("Saldo",1);
		pc.addBorderCols("Ajustar",1);

	pc.setTableHeader(2);//create de table header

	//table body
	double ajustar = 0, saldo = 0, total = 0,granTotal = 0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		pc.setVAlignment(0);
		pc.setFont(6, 0);
		pc.addCols(cdo1.getColValue("nombre_paciente"),0,2);
		pc.addCols(cdo1.getColValue("fechaNacimiento"),1,1);
		pc.addCols(cdo1.getColValue("pac_id"),1,1);
		pc.addCols(cdo1.getColValue("secuencia"),1,1);
		pc.addCols(cdo1.getColValue("factura"),1,1);
		pc.addCols(cdo1.getColValue("empresa_name"),1,1);
		pc.addCols(cdo1.getColValue("fechaIngreso"),1,1);

		pc.addCols(cdo1.getColValue("tipo_cta"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("centros")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("medicos")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("empresas")),2,1);

		saldo = Double.parseDouble(cdo1.getColValue("centros")) +Double.parseDouble(cdo1.getColValue("medicos"))+Double.parseDouble(cdo1.getColValue("empresas"))/*-Double.parseDouble(cdo1.getColValue("copago"))*/;
		//total += saldo;
		ajustar = Double.parseDouble(cdo1.getColValue("ajustar"));
		total += ajustar;

		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(ajustar),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}

	/*================================================================================*/
		pc.addCols(" ",0,dHeader.size());

		pc.setFont(contentFontSize,1);
		pc.addCols(" ",0,9);
		pc.addBorderCols(" MONTO DE LA LISTA   B/.",1,3);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,2);
		pc.setFont(contentFontSize,0);

		pc.addCols(" ",0,dHeader.size());

		pc.addCols(" ",0,9);
		pc.addCols("Monto Clínica:      B/.",2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("clinicaLista")),2,2);

		pc.addCols(" ",0,9);
		pc.addCols("Monto Terceros:   B/.",2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("tercerosLista")),2,2);

		pc.addCols(" ",0,9);
		pc.addCols("Monto Médicos:    B/.",2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("medicosLista")),2,2);

		pc.addCols(" ",0,9);
		pc.addCols("Monto Empresa:   B/.",2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("empresasLista")),2,2);

		pc.addCols(" ",0,9);
		pc.addCols("Cantidad de Facturas ",2,3);
		pc.addCols(" "+al.size(),2,2);
	/*================================================================================*/
	pc.flushTableBody(true);


	pc.addNewPage();
		pc.deleteRows(-1);
		pc.addCols(" ",0,dHeader.size());

		pc.setFont(contentFontSize,1);
		pc.addBorderCols(" * * * ACUMULADO INCOBRABLES POR AÑO FISCAL * * * ",1,6);
		pc.addCols(" ",0,9);

		pc.setFont(contentFontSize,0);
		pc.addCols(" ",0,1);
		pc.addCols("Monto",2,1);
		pc.addCols("Monto Reversión",2,2);
		pc.addCols(" ",0,11);

		pc.addCols("Clínica:         B/.",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoClinica")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revCentros")),2,2);
		pc.addCols(" ",0,11);

		pc.addCols("Terceros:      B/.",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoTerceros")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revTerceros")),2,2);
		pc.addCols(" ",0,11);

		pc.addCols("Médicos:       B/.",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoMedicos")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revMedicos")),2,2);
		pc.addCols(" ",0,11);

		pc.addCols("Empresa:       B/.",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoempresas")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revEmpresas")),2,2);
		pc.addCols(" ",0,11);

		pc.addCols("TOTAL . . . . . . . . . . B/.",0,1);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalAnual")),2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalRev")),2,2,0.0f,0.1f,0.0f,0.0f);
		pc.addCols(" ",0,11);

		pc.setFont(contentFontSize,1);
		pc.addCols("GRAN   TOTAL ",2,2);
		granTotal = Double.parseDouble(cdoHeader.getColValue("totalAnual")) - Double.parseDouble(cdoHeader.getColValue("totalRev"));
		pc.addCols(CmnMgr.getFormattedDecimal(granTotal),2,2);
		pc.addCols(" ",0,11);
		pc.setFont(contentFontSize,0);

		pc.addBorderCols("",1,dHeader.size(),0.5f,0.0f,0.0f,0.0f);


		double tClinica = 0.00;
		double tDesc = 0.00;
		double tNeto = 0.00;
		int key =0,x=0;
		String groupBy ="";
		pc.addCols(" ",1,dHeader.size());
		pc.flushTableBody(true);

		for (int j=0; j<al2.size(); j++) {

			CommonDataObject cli = (CommonDataObject) al2.get(j);

			if(!groupBy.trim().equals(cli.getColValue("orden"))){
			pc.setFont(headerFontSize,1);
			if( j!=0)
			{
				//pc.addCols(" ",1,dHeader.size());

				if(groupBy.trim().equals("A"))
					pc.addCols("TOTAL CENTROS CLINICA",0,4);
				else if(groupBy.trim().equals("B"))
					pc.addCols("TOTAL CENTROS TERCEROS",0,4);
				else if(groupBy.trim().equals("C"))
					pc.addCols("TOTAL MÉDICOS",0,4);
				else if(groupBy.trim().equals("D"))
					pc.addCols("TOTAL EMPRESAS",0,4);


					pc.addBorderCols(CmnMgr.getFormattedDecimal(tClinica),2,2,0.0f,0.1f,0.0f,0.0f);
					pc.addCols(" ",1,6);
					pc.addCols(" ",1,dHeader.size());

			}
			if(cli.getColValue("orden").trim().equals("A")) pc.addCols("CENTROS CLINICA",0,4);
			else if(cli.getColValue("orden").trim().equals("B")) pc.addCols("CENTROS TERCEROS ",0,4);
			else if(cli.getColValue("orden").trim().equals("C")) pc.addCols("MÉDICOS",0,4);
			else if(cli.getColValue("orden").trim().equals("D")) pc.addCols("EMPRESAS",0,4);
			pc.addCols("MONTO",2,2);
			pc.addCols(" ",1,9);
			tClinica =0;
		}

		pc.setFont(contentFontSize,0);
		pc.addCols("    "+cli.getColValue("descripcion"),0,4);
		pc.addCols(CmnMgr.getFormattedDecimal(cli.getColValue("monto")),2,2);
		pc.addCols(" ",1,9);

		tClinica += Double.parseDouble(cli.getColValue("monto"));
		groupBy = cli.getColValue("orden");

	}
		pc.setFont(contentFontSize,1);
		if(groupBy.trim().equals("A")) pc.addCols("TOTAL CENTROS CLINICA",0,4);
		else if(groupBy.trim().equals("B")) pc.addCols("TOTAL CENTROS TERCEROS",0,4);
		else if(groupBy.trim().equals("C")) pc.addCols("TOTAL MÉDICOS",0,4);
		else if(groupBy.trim().equals("D")) pc.addCols("TOTAL EMPRESAS",0,4);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(tClinica),2,2,0.0f,0.1f,0.0f,0.0f);
		pc.addCols(" ",1,9);

		pc.addCols(" ",1,dHeader.size());

		pc.addCols("Autorizado por:  ______________________________________________",0,9);
		pc.addCols("Fecha:  ___________________________",0,6);

		pc.addCols(" ",1,dHeader.size());

		pc.addCols("Recibido por:    ______________________________________________",0,9);
		pc.addCols("Fecha:  ___________________________",0,6);

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>