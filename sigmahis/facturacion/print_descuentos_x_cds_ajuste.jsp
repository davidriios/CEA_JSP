<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
String admision = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String empresa = request.getParameter("aseguradora");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String fg = request.getParameter("fg");
String factId = request.getParameter("factId");
String tipoFecha =request.getParameter("tipoFecha");
String libro =request.getParameter("libro");
String aseguradora =request.getParameter("aseguradora");
String aseguradoraDesc =request.getParameter("aseguradoraDesc");
String fp = request.getParameter("fp"); 
if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (empresa == null) empresa = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (factId == null) factId = "";
if (tipoFecha == null) tipoFecha = "";
if (libro == null) libro = "";
if (aseguradora==null)aseguradora="";
if (aseguradoraDesc==null)aseguradoraDesc="";
if (fp==null)fp="";

sbSql = new StringBuffer();
sbSql.append("select cds,centro_servicio_desc,sum(monto) as monto,compania,cuenta,descAdmType from ( select a.centro cds, nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.centro),'S/C') centro_servicio_desc, sum(decode(a.lado_mov,'D',-nvl(a.monto,0),'C',nvl(a.monto,0)))  monto,a.compania,decode(c.group_type,'J',(c.cta1||'-'||c.cta2||'-'||c.cta3||'-'||c.cta4||'-'||c.cta5||'-'||c.cta6),nvl(nvl((select acc.cta1||'-'||acc.cta2||'-'||acc.cta3||'-'||acc.cta4||'-'||acc.cta5||'-'||acc.cta6 from tbl_con_accdef acc where acc.acctype_id =decode(f.cod_empresa,-1,6,get_sec_comp_param(a.compania,'CONT_ACCTYPE_CTA_DESC_AJ')) and acc.ref_table(+) = '-' and acc.ref_pk = '-' and acc.cds = a.centro and acc.service_type ='-' and acc.compania = a.compania and acc.status ='A' and acc.adm_type =f.adm_type),(select acc.cta1||'-'||acc.cta2||'-'||acc.cta3||'-'||acc.cta4||'-'||acc.cta5||'-'||acc.cta6 from tbl_con_accdef acc where acc.acctype_id =decode(f.cod_empresa,-1,6,5) and acc.ref_table(+) = '-' and acc.ref_pk = '-' and acc.cds = a.centro and acc.service_type ='-' and acc.compania = a.compania and acc.status ='A' and acc.adm_type ='T')),'S/C'))  cuenta, decode(f.adm_type,'I','INGRESOS IP','O','INGRESOS OP','T','TODAS')||decode(f.cod_empresa,-1,' JUB','') descAdmType from vw_con_adjustment_gral a, tbl_fac_tipo_ajuste c,tbl_fac_factura f where a.compania=");
sbSql.append(session.getAttribute("_companyId"));


sbSql.append(" and a.tipo_ajuste = c.codigo and a.compania = c.compania and c.group_type in ('B','C','J') and a.factura is not null  ");
if(!fp.trim().equals("PARAM"))sbSql.append(" and a.centro is not null  ");


	if (!fechaIni.trim().equals(""))
	{
	if(tipoFecha.trim().equals("A"))
	sbSql.append(" and trunc(a.fecha_aprob) >= to_date('");
	else sbSql.append(" and trunc(a.fecha) >= to_date('");

	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");

	}
	if (!fechaFin.trim().equals(""))
	{
		if(tipoFecha.trim().equals("A"))
		sbSql.append(" and trunc(a.fecha_aprob) <= to_date('");
		else sbSql.append(" and trunc(a.fecha) <= to_date('");

		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	if(!factId.trim().equals(""))
	{
		sbSql.append(" and a.factura = '");
		sbSql.append(factId);
		sbSql.append("'");
	}
sbSql.append(" and a.factura = f.codigo and a.compania = f.compania");

if(!fg.trim().equals(""))
{
	sbSql.append(" and a.tipo_doc = '");
	sbSql.append(fg);
	sbSql.append("'");
}
if(!aseguradora.trim().equals(""))
{
	sbSql.append(" and f.cod_empresa =");
	sbSql.append(aseguradora);
	sbSql.append("");
}
sbSql.append(" group by  a.centro,a.compania,f.adm_type,f.cod_empresa,c.group_type,c.cta1||'-'||c.cta2||'-'||c.cta3||'-'||c.cta4||'-'||c.cta5||'-'||c.cta6 having sum(decode(a.lado_mov,'D',nvl(a.monto,0),'C',-nvl(a.monto,0))) <> 0");
sbSql.append(") group by cds,centro_servicio_desc,compania,cuenta,descAdmType order by  cds ");

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "DESCUENTOS POR AJUSTES X CENTROS DE SERVICIOS "+(!aseguradoraDesc.trim().equals("")?"   Y ASEG. ( "+aseguradora+" - "+aseguradoraDesc+" )":"");;
	String xtraSubtitle = "DEL "+fechaIni+"  AL "+fechaFin ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 9;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
					dHeader.addElement(".40");
					dHeader.addElement(".10");
					dHeader.addElement(".15");
					dHeader.addElement(".20");
					dHeader.addElement(".15");




	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);
		pc.addBorderCols("Centro De Servicio",0,2);
		pc.addBorderCols("Tipo Adm",0,1);
		pc.addBorderCols("Cuenta",2,1);
		pc.addBorderCols("Monto",2,1);
	pc.setTableHeader(2);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto =0.0,totalCds =0.0,totalTa =0.0,total=0.0,totalCdsRecargo=0.0,totalRecargo=0.0;
	int totalCantidad = 0, totalCantidadCds =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


			monto  = Double.parseDouble(cdo.getColValue("monto"));
			total  += Double.parseDouble(cdo.getColValue("monto"));


			pc.addCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,2);
			pc.addCols(""+cdo.getColValue("descAdmType"),0,1);
			pc.addCols(""+cdo.getColValue("cuenta"),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
						pc.addBorderCols(" ",2,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTAL",2,dHeader.size()-1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1,0.5f,0.0f,0.0f,0.0f);//


	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>