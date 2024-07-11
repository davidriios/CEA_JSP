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

StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String uso = request.getParameter("uso");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");

if(uso== null) uso = "";
if(tDate == null ) tDate="";
if(fDate == null ) fDate="";


sbSql.append("select aa.* from (");
sbSql.append("select b.cod_uso,us.descripcion, a.admi_fecha_nacimiento f_nac,a.admi_codigo_paciente cod_pac, a.admi_secuencia admision,a.pac_id, c.nombre_paciente,nvl(sum(decode(b.tipo_transaccion,'C',b.cantidad)),0) - nvl(sum(decode(b.tipo_transaccion,'D',b.cantidad)),0) cantidad,nvl(sum(decode(b.tipo_transaccion,'C',b.cantidad*(b.monto+nvl(b.recargo,0)))),0) - nvl(sum(decode(b.tipo_transaccion,'D',b.cantidad*(b.monto+nvl(b.recargo,0)))),0) monto_total,(select to_char(fecha_ingreso,'dd/mm/yyyy') from tbl_adm_admision where pac_id=a.pac_id and secuencia =a.admi_secuencia and rownum = 1) fechaIngreso	,(select to_date(to_char(fecha_ingreso,'dd/mm/yyyy')||' '||to_char(am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') fecha_ingreso_ord from tbl_adm_admision where pac_id=a.pac_id and secuencia =a.admi_secuencia and rownum = 1) fechaIngresoOrd, to_char(b.fecha_cargo,'dd/mm/yyyy') as fecha_cargo ,b.fecha_cargo as fc from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b,vw_adm_paciente c,tbl_sal_uso us where b.cod_uso = us.codigo and b.compania = us.compania");
if(!fDate.trim().equals(""))
{
sbSql.append(" and b.fecha_creacion >= to_date('");
sbSql.append(tDate);
sbSql.append("','dd/mm/yyyy')");
}
if(!tDate.trim().equals(""))
{
sbSql.append(" and b.fecha_creacion <= to_date('");
sbSql.append(fDate);
sbSql.append("','dd/mm/yyyy')");
}
sbSql.append(" and c.pac_id = a.pac_id and a.compania = b.compania and a.pac_id = b.pac_id  and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and a.codigo = b.fac_codigo and to_char(a.centro_servicio) = (select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name = 'CDS_SOP') ");

if(!uso.trim().equals(""))
{
  sbSql.append(" and b.cod_uso = ");
  sbSql.append(uso);
}
sbSql.append(" having nvl(sum(decode(b.tipo_transaccion,'C',b.cantidad)),0) - nvl(sum(decode(b.tipo_transaccion,'D',b.cantidad)),0) > 0 group by b.cod_uso, us.descripcion,a.admi_fecha_nacimiento,a.admi_codigo_paciente,a.admi_secuencia,a.pac_id,c.nombre_paciente,a.compania, to_char(fecha,'dd/mm/yyyy'),b.fecha_cargo /*order by b.cod_uso,a.pac_id,  a.admi_secuencia*/ ");

sbSql.append(") aa order by aa.cod_uso,aa.fechaIngresoOrd,fc");

al = SQLMgr.getDataList(sbSql.toString());

	
if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String title = "INVENTARIO";
	String subtitle = "CARGOS DE USOS A PACIENTES EN SALON DE OPERACIONES";
	String xtraSubtitle = "DESDE" + tDate + "  HASTA  " +fDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	    dHeader.addElement(".40");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		dHeader.addElement(".10");
		dHeader.addElement(".12");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		//second row
		pc.addBorderCols("NOMBRE",0,1);
		pc.addBorderCols("ID PAC.",1,1);
		pc.addBorderCols("ADMISION",1,1);		
		pc.addBorderCols("FECHA INGRESO",1,1);
		pc.addBorderCols("FECHA CARGO",01,1);
		pc.addBorderCols("CANTIDAD",1,1);
		pc.addBorderCols("TOTAL",2,1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	
	String groupBy = "";
	int totalArt = 0;
	double total = 0.00,totalReporte=0.00,totalReporteArt=0;
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		pc.setFont(7, 0);
		if(!groupBy.trim().equals(cdo.getColValue("descripcion")))
		{
			pc.setFont(7, 1,Color.blue);
			if(i!=0)
			{
				pc.addCols("TOTAL",2,5);
				pc.addCols(""+totalArt,1,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(total),2,1);
				totalArt = 0;
				total = 0;
			}
			pc.addCols(" "+cdo.getColValue("cod_uso")+" - "+cdo.getColValue("descripcion"),0,dHeader.size());
		}
		pc.setFont(7, 0);
		pc.addCols("      "+cdo.getColValue("nombre_paciente"),0,1);
		pc.addCols(cdo.getColValue("pac_id"),1,1);
		pc.addCols(cdo.getColValue("admision"),1,1);		
		pc.addCols(cdo.getColValue("fechaIngreso"),1,1);
		pc.addCols(cdo.getColValue("fecha_cargo"),1,1);
		pc.addCols(""+cdo.getColValue("cantidad"),1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total")),2,1);
		
		total     += Double.parseDouble(cdo.getColValue("monto_total"));
		totalArt  += Integer.parseInt(cdo.getColValue("cantidad"));
		
		totalReporte     += Double.parseDouble(cdo.getColValue("monto_total"));
		totalReporteArt  += Integer.parseInt(cdo.getColValue("cantidad"));
		
		groupBy = cdo.getColValue("descripcion");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
		pc.setFont(7, 0,Color.blue);
		pc.addCols("TOTAL",2,5);
		pc.addCols(""+totalArt,1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(total),2,1);
		pc.addCols("TOTAL POR REPORTE",2,5);
		pc.addCols(""+totalReporteArt,1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totalReporte),2,1);
		
		//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>