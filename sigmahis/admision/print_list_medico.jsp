<%@ page errorPage="../error.jsp"%>
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

sbSql.append("select a.codigo,nvl(a.reg_medico,a.codigo) as reg_medico, a.identificacion, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as nombre, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as apellido, a.sexo, decode(a.nacionalidad, null, ' ', a.nacionalidad) as nacionalidad, a.estado_civil as estadoCivil, decode(a.fecha_de_nacimiento, null, ' ', to_char(a.fecha_de_nacimiento, 'dd/mm/yyyy')) as fechaDeNacimiento, a.religion, nvl(a.digito_verificador, ' ') as digitoVerificador, nvl(a.direccion, ' ') as direccion, decode(a.comunidad, null, ' ', a.comunidad) as comunidad, decode(a.corregimiento, null, ' ', a.corregimiento) as corregimiento, decode(a.distrito, null, ' ', a.distrito) as distrito, decode(a.provincia, null, ' ', a.provincia) as provincia, decode(a.pais, null, ' ', a.pais) as pais, nvl(a.telefono, ' ') as telefono, nvl(a.zona_postal, ' ') as zonaPostal, nvl(a.apartado_postal, ' ') as apartadoPostal, nvl(a.bepper, ' ') as bepper, nvl(a.celular, ' ') as celular, nvl(a.lugar_de_trabajo, ' ') as lugarDeTrabajo, nvl(a.telefono_trabajo, ' ') as telefonoTrabajo, nvl(a.extension, ' ') as extension, decode(a.estado,'A','ACTIVO','I','INACTIVO',a.estado) as estado, nvl(a.e_mail, ' ') as eMail, nvl(a.fax, ' ') as fax, nvl(a.observaciones, ' ') as observaciones, decode(a.cod_empresa, null, ' ', '['||a.cod_empresa||']') as codEmpresa, nvl(a.beneficiario, ' ') as beneficiario, nvl(a.pagar_ben, ' ') as pagarBen, nvl(a.liquidable, ' ') as liquidable, nvl(a.retencion, ' ') as retencion, nvl(a.cuenta_bancaria, ' ') as cuentaBancaria, nvl(a.ruta_transito, ' ') as rutaTransito, nvl(a.tipo_cuenta, ' ') as tipoCuenta, decode(a.tipo_persona, null, ' ', a.tipo_persona) as tipoPersona, nvl(b.nacionalidad, 'NA') as nacionalidadDesc, nvl(c.descripcion, 'NA') as religionDesc, nvl(d.nombre_comunidad, ' ') as comunidadNombre, nvl(d.nombre_corregimiento, ' ') as corregimientoNombre, nvl(d.nombre_distrito, ' ') as distritoNombre, nvl(d.nombre_provincia, ' ') as provincianombre, nvl(d.nombre_pais, ' ') as paisnombre, nvl(e.nombre,' ') as empresaNombre, nvl(f.nombre_banco,' ') as rutaTransitoNombre from tbl_adm_medico a, tbl_sec_pais b, tbl_adm_religion c, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito, decode(codigo_corregimiento,0,null,codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, tbl_adm_empresa e, tbl_adm_ruta_transito f where a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and a.pais = d.codigo_pais(+) and a.provincia = d.codigo_provincia(+) and a.distrito = d.codigo_distrito(+) and a.corregimiento = d.codigo_corregimiento(+) and a.comunidad = d.codigo_comunidad(+) and a.cod_empresa=e.codigo(+) and a.ruta_transito=f.ruta(+)");
sbSql.append(appendFilter);
sbSql.append(" order by 4,3");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "ADMISION";
	String subtitle = "MEDICO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".12");
		dHeader.addElement(".21");
		dHeader.addElement(".21");
		dHeader.addElement(".13");
		dHeader.addElement(".25");
		dHeader.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("Registro Médico",1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Apellido",1);
		pc.addBorderCols("Identificación",1);
		pc.addBorderCols("Empresa del Cheque",1);
		pc.addBorderCols("Estado",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	pc.setVAlignment(0);
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("reg_medico"),0,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(cdo.getColValue("apellido"),0,1);
		pc.addCols(cdo.getColValue("identificacion"),0,1);
		pc.addCols(cdo.getColValue("codEmpresa")+" "+cdo.getColValue("empresaNombre"),0,1);
		pc.addCols(cdo.getColValue("estado"),1,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>