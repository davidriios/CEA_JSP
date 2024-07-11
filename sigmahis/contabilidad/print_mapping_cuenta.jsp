<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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

StringBuffer sql = new StringBuffer();
StringBuffer sbTables = new StringBuffer();
StringBuffer sbFields = new StringBuffer();
StringBuffer sbWhere = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String cds = request.getParameter("cds");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String recibeMov = request.getParameter("recibeMov");

String table   ="";
String pWhere  ="";

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (cds == null) cds = "";
if (type == null) type = "";
if (recibeMov == null) recibeMov = "";


if(!type.trim().equals("5") && !type.trim().equals("6") && !type.trim().equals("7")&& !type.trim().equals("8"))
{
	sbFields.append(" ,c.descripcion descripcion,c.codigo tipo_cargo");
	sbTables.append(" tbl_cds_servicios_x_centros a,tbl_cds_tipo_servicio c,");
	sbWhere.append(" a.centro_servicio=b.codigo  and a.tipo_servicio = c.codigo and d.service_type(+) = a.tipo_servicio and d.cds(+) = a.centro_servicio and ");
}
else  sbWhere.append(" d.def_type(+) ='C' and d.cds(+) = b.codigo and ");

if(!recibeMov.trim().equals(""))sql.append(" select * from (");

sql.append("select x.*, (select descripcion from tbl_con_catalogo_gral where cta1 = x.cta1 and cta2 = x.cta2 and cta3 = x.cta3 and cta4 = x.cta4 and cta5 = x.cta5 and cta6 = x.cta6 and compania = x.compania) as ctaDesc,(select recibe_mov from tbl_con_catalogo_gral where cta1 = x.cta1 and cta2 = x.cta2 and cta3 = x.cta3 and cta4 = x.cta4 and cta5 = x.cta5 and cta6 = x.cta6 and compania = x.compania) as recibe_mov from ( select distinct b.codigo cds, b.descripcion centro_servicio_desc, d.cta1, d.cta2, d.cta3, d.cta4, d.cta5, d.cta6, d.compania, d.cta1||'.'||d.cta2||'.'||d.cta3||'.'||d.cta4||'.'||d.cta5||'.'||d.cta6 cuenta, decode(d.adm_type,'I','INGRESOS - IP','O','INGRESOS - OP','T','TODAS',' ') as descAdmType   ");
sql.append(sbFields.toString());
sql.append(" from ");
sql.append(sbTables.toString());
sql.append("  tbl_cds_centro_servicio b ,tbl_con_accdef d  where ");
sql.append(sbWhere.toString());
sql.append(" d.status(+)  ='A' and b.estado = 'A' and b.compania_unorg = ");
sql.append(session.getAttribute("_companyId"));
sql.append(" and d.compania(+) = ");
sql.append(session.getAttribute("_companyId"));

if(!cds.trim().equals(""))
{
sql.append(" and b.codigo=");
sql.append(cds);
}
if(!type.trim().equals(""))
{
sql.append(" and d.acctype_id(+) = ");
sql.append(type);
}

if(!type.trim().equals("5") && !type.trim().equals("6") && !type.trim().equals("7")&& !type.trim().equals("8"))
{
sql.append(" union   select distinct -1 cds, 'NO APLICA' centro_servicio_desc, d.cta1, d.cta2, d.cta3, d.cta4, d.cta5, d.cta6, d.compania, d.cta1||'.'||d.cta2||'.'||d.cta3||'.'||d.cta4||'.'||d.cta5||'.'||d.cta6 cuenta, decode(d.adm_type,'I','INGRESOS - IP','O','INGRESOS - OP','T','TODAS',' ') as descAdmType, c.descripcion descripcion, c.codigo tipo_cargo  from tbl_cds_tipo_servicio c, tbl_con_accdef d where d.service_type(+) = c.codigo  and d.status(+)  ='A' and c.genera_costo='S' and d.cds(+) = -1 and d.compania(+) = ");
sql.append(session.getAttribute("_companyId"));

/*
if(!cds.trim().equals(""))
{
sql.append(" and d.cds=");
sql.append(cds);
}*/
if(!type.trim().equals(""))
{
sql.append(" and d.acctype_id(+) = ");
sql.append(type);
}
}

sql.append(" order by 2,10,3 ) x ");

sbWhere = new StringBuffer();



if(fg.trim().equals("SC"))
{
	sbWhere.append(" where x.cta1 is null ");
}
if(fg.trim().equals("CC"))
{
	sbWhere.append(" where x.cta1 is not null ");
}

if(!recibeMov.trim().equals(""))
{
	sql.append(") where recibe_mov ='");
	sql.append(recibeMov);
	sql.append("'");
}

sql.append(" order by cds ");
if(!type.trim().equals("5") && !type.trim().equals("6") && !type.trim().equals("7")&& !type.trim().equals("8"))sql.append(",tipo_cargo ");


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
	String title = "CONTABILIDAD";
	String subtitle = "MAPPING DE CUENTAS POR CENTROS DE SERVICIOS";
	String xtraSubtitle = "";
	if(recibeMov.trim().equals("S"))xtraSubtitle +="RECIBE MOVIMIENTO ";
	else if(recibeMov.trim().equals("N"))xtraSubtitle +="NO RECIBE MOVIMIENTO ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
					dHeader.addElement(".35");
					dHeader.addElement(".15");
					dHeader.addElement(".50");




	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);

	//pc.setTableHeader(1);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto =0.0,totalCds =0.0,totalTa =0.0,total=0.0;
	int totalCantidad = 0, totalCantidadCds =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(!type.trim().equals("5") && !type.trim().equals("6") && !type.trim().equals("7")&& !type.trim().equals("8"))
		{
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds")))
			{

				pc.setFont(fontSize, 0,Color.blue);
				pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

				pc.setFont(fontSize, 0);
				pc.addBorderCols("Tipo Servicio",1,1);
				pc.addBorderCols("Categoría",1,1);
				pc.addBorderCols("Cuenta",1,1);

			}

			//pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"] [ "+cdo.getColValue("cuenta")+" ]",0,1);
			pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"] ",0,1);
			pc.addCols(cdo.getColValue("descAdmType"),1,1);
			pc.addCols(cdo.getColValue("cuenta")+" "+cdo.getColValue("ctaDesc"),0,1);

			groupBy = cdo.getColValue("cds");
		}else
		{
			if(i==0)
			{
				pc.addBorderCols("Centro Servicio",1,1);
				pc.addBorderCols("Categoría",1,1);
				pc.addBorderCols("Cuenta",1,1);
				pc.setTableHeader(2);
			}
			pc.addCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,1);
			pc.addCols(cdo.getColValue("descAdmType"),1,1);
			pc.addCols(cdo.getColValue("cuenta")+" "+cdo.getColValue("ctaDesc"),0,1);

		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);


	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.addCols(" ",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>