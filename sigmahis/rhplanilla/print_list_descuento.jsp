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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
sql="select b.provincia||' '||b.sigla||'-'||b.tomo||' '||b.asiento as cedula, b.num_descuento , b.cod_grupo, b.cod_acreedor as code, decode(b.estado,'D','DESCONTAR','N','NO DESCONTAR','P','PENDIENTE','E','ELIMINADO') as estado, to_char(b.monto_total,'999,999,990.00') monto_total, to_char(b.saldo,'999,999,990.00') saldo, to_char(b.descontado,'999,999,990.00') descontado,  to_char(b.descuento_mensual,'999,999,990.00') descuento_mensual, to_char(b.descuento1,'999,999,990.00') descuento1, to_char(b.descuento2,'999,999,990.00') descuento2, to_char(b.fecha_inicial,'dd/mm/yyyy') as fecharec, b.num_documento, to_char(b.fecha_creacion,'dd/mm/yyyy') fecha_creacion, b.fecha_mod, b.usuario_mod, b.cod_compania, b.observaciones, b.num_cuenta, b.tipo_cuenta, b.autoriza_descto_cia, b.autoriza_descto_anio, b.autoriza_descto_codigo, b.emp_id, e.primer_nombre||' '||decode(e.apellido_casada,null,e.primer_apellido,'DE '||e.apellido_casada) as name, e.primer_apellido||' '||e.primer_nombre as nameR, e.unidad_organi, c.descripcion as unidadName, e.salario_base, e.rata_hora, d.nombre as grupoaName,f.nombre as acredorName, e.emp_id as empId, e.num_empleado from tbl_pla_descuento b, tbl_pla_empleado e, tbl_pla_grupo_descuento d, tbl_pla_acreedor f, tbl_sec_unidad_ejec c where b.provincia=e.provincia and b.sigla=e.sigla and b.tomo=e.tomo and b.asiento=e.asiento and b.cod_compania=e.compania(+) and b.cod_grupo=d.cod_grupo(+) and b.cod_acreedor=f.cod_acreedor(+) and b.COD_COMPANIA=f.compania(+) and e.unidad_organi=c.codigo(+) and b.COD_COMPANIA= c.compania and b.cod_compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by e.primer_nombre, e.primer_apellido";

al = SQLMgr.getDataList(sql);

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
	String title = "PLANILLA";
	String subtitle = "DESCUENTOS DE EMPLEADOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  dHeader.addElement(".05");
		dHeader.addElement(".30");
		dHeader.addElement(".21");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".05");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Código",0,1);
		pc.addBorderCols("Nombre Acreedor",1,1);
		pc.addBorderCols("Tipo de descuento",1,1);
		pc.addBorderCols("Estado",1,1);
		pc.addBorderCols("Monto",1,1);
		pc.addBorderCols("Descontado",1,1);
		pc.addBorderCols("Saldo",1,1);
		pc.addBorderCols("Desc1",1,1);
		pc.addBorderCols("Desc2",1,1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String sec = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!sec.equalsIgnoreCase(cdo.getColValue("nameR")))
			{

			pc.setFont(7, 1);
			pc.addCols("ID: "+cdo.getColValue("empId")+"    No. Empleado:    "+cdo.getColValue("num_empleado")+"    -    "+cdo.getColValue("name"),0,dHeader.size());
			}

		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("code"),0,1);
			pc.addCols(" "+cdo.getColValue("acredorName"),0,1);
			pc.addCols(" "+cdo.getColValue("grupoaName"),0,1);
			pc.addCols(" "+cdo.getColValue("estado"),1,1);
			pc.addCols(" "+cdo.getColValue("monto_total"),2,1);
			pc.addCols(" "+cdo.getColValue("descontado"),2,1);
			pc.addCols(" "+cdo.getColValue("saldo"),2,1);
			pc.addCols(" "+cdo.getColValue("descuento1"),2,1);
			pc.addCols(" "+cdo.getColValue("descuento2"),2,1);



		sec=cdo.getColValue("nameR");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>