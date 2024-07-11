<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
CommonDataObject cdoCta = new CommonDataObject();

StringBuffer sql = new StringBuffer();
StringBuffer appendFilterP = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();
StringBuffer appendFilter2 = new StringBuffer();
String userName = UserDet.getUserName();
String estado  = "";   // variable para mantener el valor de los campos filtrados en la consulta
String codigo  = "";
String nombre  = "",tipo_prov="";
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String fp = request.getParameter("fp");
String tipoFac = request.getParameter("tipoFac");
String doc_morosidad = request.getParameter("doc_morosidad");
String prov_saldo = request.getParameter("prov_saldo");
String fg = request.getParameter("fg");
String comprob = request.getParameter("comprob");
String anio = request.getParameter("anio");
String consecutivo = request.getParameter("consecutivo");
if(fg==null) fg = "";
if(prov_saldo==null) prov_saldo = "";
String vista ="vw_cxp_mov_proveedor";
if(fg.trim().equals("MG"))vista ="vw_cxp_mov_proveedor_mg";
String compania = (String) session.getAttribute("_companyId");
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(tipoFac==null) tipoFac="";

if (request.getParameter("estado") != null) estado = request.getParameter("estado");
if (request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
if (request.getParameter("nombre") != null) nombre = nombre.replaceAll("/","").replaceAll("'"," ");



if (request.getParameter("tipo_prov") != null) tipo_prov = request.getParameter("tipo_prov");

	appendFilterP.append(" and pp.compania = ");
	appendFilterP.append((String) session.getAttribute("_companyId"));

	if (!estado.equals("")){
		appendFilterP.append(" and pp.estado_proveedor = '");
		appendFilterP.append(request.getParameter("estado").toUpperCase());
		appendFilterP.append("'");
	}
 //else appendFilter=appendFilter+" and upper(p.estado_proveedor)<> 'INA'";

	if (!codigo.equals("")){
		appendFilterP.append(" and upper(pp.cod_provedor) like '%");
		appendFilterP.append(request.getParameter("codigo").toUpperCase());
		appendFilterP.append("%'");
	}
	if (!nombre.equals("")){
		appendFilterP.append(" and upper(pp.nombre_proveedor) like '%");
		appendFilterP.append(IBIZEscapeChars.forSingleQuots(request.getParameter("nombre").toUpperCase()));
		appendFilterP.append("%'");
	}
	if (!tipo_prov.equals("")){
		appendFilterP.append(" and upper(pp.tipo_prove) = '");
		appendFilterP.append(request.getParameter("tipo_prov").toUpperCase());
		appendFilterP.append("'");
	}
	if (tipoFac!=null && !tipoFac.equals("")){
		appendFilter.append(" and upper(v.fg) != '");
		appendFilter.append(tipoFac.toUpperCase());
		appendFilter.append("'");
	}
	if(doc_morosidad==null) doc_morosidad="";
	if(!doc_morosidad.equals("")){
		appendFilter.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		appendFilter.append(doc_morosidad);
		appendFilter.append("'");
		appendFilter2.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		appendFilter2.append(doc_morosidad);
		appendFilter2.append("'");
	}
	if (anio!=null && !anio.equals("")){
		appendFilter.append(" and v.anio_comprob=");
		appendFilter.append(anio);
	}
	if (consecutivo!=null && !consecutivo.equals("")){
		appendFilter.append(" and v.consecutivo=");
		appendFilter.append(consecutivo);
	}
	if (comprob!=null && !comprob.equals("")){
		appendFilter.append(" and upper(v.comprob) = '");
		appendFilter.append(comprob.toUpperCase());
		appendFilter.append("'");
	}

	sql = new StringBuffer();
	sql.append("select pp.compania, pp.cod_provedor codigo, pp.nombre_proveedor nombre, decode (pp.estado_proveedor, 'ACT', 'ACTIVO', 'INA', 'INACTIVO') as estado_desc, nvl(v.saldo_inicial, 0) saldo_inicial, nvl(p.debito, 0) debito, nvl(p.credito, 0) credito, nvl(p.movimiento, 0) movimiento, nvl(v.saldo_inicial,0) + nvl(p.movimiento,0) saldo, pp.cat_cta1||'-'||pp.cat_cta2||'-'||pp.cat_cta3||'-'||pp.cat_cta4||'-'||pp.cat_cta5||'-'||pp.cat_cta6||' - '||(select descripcion from tbl_con_catalogo_gral where compania=pp.compania and cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6=pp.cat_cta1||'-'||pp.cat_cta2||'-'||pp.cat_cta3||'-'||pp.cat_cta4||'-'||pp.cat_cta5||'-'||pp.cat_cta6 ) cuenta from (select v.cod_proveedor, v.compania, sum(nvl(v.debito, 0)) debito,  sum(nvl(v.credito, 0)) credito, sum(nvl(v.debito, 0) - nvl(v.credito, 0)) movimiento from ");
	sql.append(vista);
	sql.append(" v where v.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(appendFilter.toString());
	sql.append(" and trunc(v.fecha_documento) between to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy') and  to_date('");
	sql.append(fechafin);
	sql.append("', 'dd/mm/yyyy') and nvl(v.tipo_doc,'OT')  !='FACTP' group by v.compania, v.cod_proveedor) p, tbl_com_proveedor pp, (select compania, cod_proveedor, sum(nvl (debito, 0) - nvl(credito, 0)) saldo_inicial from ");
	sql.append(vista);
	sql.append(" where trunc(fecha_documento) < to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy') and nvl(tipo_doc,'OT') !='FACTP'");
	if(tipoFac!=null && !tipoFac.equals("")){
		sql.append(" and fg != '");
		sql.append(tipoFac);
		sql.append("'");
	}
	sql.append(appendFilter2.toString());
	sql.append(" group by compania, cod_proveedor) v where v.cod_proveedor(+) = pp.cod_provedor and v.compania(+) = pp.compania and p.cod_proveedor(+) = pp.cod_provedor and p.compania(+) = pp.compania");
	sql.append(appendFilterP.toString());
	if(prov_saldo.equals("CS")){
		sql.append(" and nvl(p.movimiento, 0) + nvl(v.saldo_inicial, 0) <> 0");
	} else if(prov_saldo.equals("SS")){
		sql.append(" and nvl(p.movimiento, 0) + nvl(v.saldo_inicial, 0) = 0");
	}	sql.append(" order by pp.nombre_proveedor");
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
	String title = "SALDO DE PROVEEDORES";
	String subtitle = "DEL "+fechaini+" AL "+fechafin;
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
			dHeader.addElement(".10");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");


PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);

			pc.addCols("CODIGO",1,1);
			pc.addCols("NOMBRE",0,1);
			pc.addCols("CUENTA",0,1);
			pc.addCols("SALDO INICIAL",2,1);
			pc.addCols("DEBITO",2,1);
			pc.addCols("CREDITO",2,1);
			pc.addCols("SALDO",2,1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	String db = "DB";
	double movimiento=0.00,saldoInicial=0.00,saldoActual =0.00,saldoDebito=0.00,saldoCredito=0.00;



	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		 saldoInicial   += Double.parseDouble(cdo.getColValue("saldo_inicial"));
		 movimiento     += Double.parseDouble(cdo.getColValue("saldo"));
		 saldoDebito    += Double.parseDouble(cdo.getColValue("debito"));
		 saldoCredito   += Double.parseDouble(cdo.getColValue("credito"));
		 saldoActual    += Double.parseDouble(cdo.getColValue("saldo"));



			pc.addCols(""+cdo.getColValue("codigo"),1,1);
			pc.addCols(""+cdo.getColValue("nombre"),0,1);
			pc.addCols(""+cdo.getColValue("cuenta"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);

			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	pc.addBorderCols(" Total  ",2,3,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldoInicial),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldoDebito),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldoCredito),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldoActual),2,1,0.0f,0.5f,0.0f,0.0f);

	pc.addCols(" ",1,dHeader.size());
	pc.addCols(" ",1,dHeader.size());

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>