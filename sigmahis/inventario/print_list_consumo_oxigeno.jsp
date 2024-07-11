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

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String compania =  compania = (String) session.getAttribute("_companyId");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}

if (fDate == null) fDate = "";
if (tDate == null) tDate = "";
if (appendFilter == null) appendFilter = "";
  
sql.append(" select ");
if(cdsDet.trim().equals("S"))sql.append("a.centro_servicio ");
else sql.append(" b.centro_servicio ");
sql.append("  as cds, c.descripcion as descCentro, a.descripcion as descInsumo, nvl(sum(decode(a.tipo_transaccion,'C',a.cantidad)),0) + nvl(sum(decode(a.tipo_transaccion,'H',a.cantidad)),0) - nvl(sum(decode(a.tipo_transaccion,'D',a.cantidad)),0) as cantidad, nvl(sum(decode(a.tipo_transaccion,'C',a.cantidad*(a.monto+nvl(a.recargo,0)))),0) + nvl(sum(decode(a.tipo_transaccion,'H',a.cantidad*(a.monto+nvl(a.recargo,0)))),0) - nvl(sum(decode(a.tipo_transaccion,'D',a.cantidad*(a.monto+nvl(a.recargo,0)))),0) as total from tbl_fac_detalle_transaccion a, tbl_fac_transaccion b, tbl_cds_centro_servicio c where a.tipo_cargo =get_sec_comp_param(b.compania,'TP_SER_OXIG') and a.cod_uso is not null and a.compania = b.compania and a.pac_id = b.pac_id and a.fac_secuencia = b.admi_secuencia and a.tipo_transaccion = b.tipo_transaccion  and b.compania = ");
sql.append(compania);
sql.append(appendFilter);
if(!fDate.trim().equals("")){sql.append(" and a.fecha_creacion >= to_date('");sql.append(fDate);sql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sql.append(" and a.fecha_creacion <= to_date('");sql.append(tDate);sql.append("','dd/mm/yyyy')");}

sql.append(" and a.fac_codigo = b.codigo ");
if(cdsDet.trim().equals("S"))sql.append(" and  a.centro_servicio ");
else sql.append(" and b.centro_servicio ");
sql.append(" = c.codigo having nvl(sum(decode(a.tipo_transaccion,'C',a.cantidad*(a.monto+nvl(a.recargo,0)))),0) + nvl(sum(decode(a.tipo_transaccion,'H',a.cantidad*(a.monto+nvl(a.recargo,0)))),0) - nvl(sum(decode(a.tipo_transaccion,'D',a.cantidad*(a.monto+nvl(a.recargo,0)))),0) > 0 ");
sql.append(" group by  ");
if(cdsDet.trim().equals("S"))sql.append(" a.centro_servicio, ");
else sql.append(" b.centro_servicio, ");

sql.append(" c.descripcion, a.descripcion order by c.descripcion");
 
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
	String title = "FACTURACION";
	String subtitle = "LISTADO DE CONSUMO DE OXIGENO";
	String xtraSubtitle = "DEL "+fDate+"  AL "+tDate ;
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
					dHeader.addElement(".35");
					dHeader.addElement(".15");
					dHeader.addElement(".15");    
	

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
			pc.addBorderCols("CENTRO",0,1);
			pc.addBorderCols("DESCRIPCION",0,1);
			pc.addBorderCols("CANTIDAD",1,1);
			pc.addBorderCols("TOTAL",1,1);
			pc.setTableHeader(2);
 
	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double total=0.0;
	int totalCantidad = 0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i); 		
		 
			pc.setFont(8, 1);
 		    pc.addCols(""+cdo.getColValue("descCentro"),0,1); 			
		    pc.addCols(""+cdo.getColValue("descInsumo"),0,1);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
			total += Double.parseDouble(cdo.getColValue("total"));
			totalCantidad  += Integer.parseInt(cdo.getColValue("cantidad"));
		
	}//for i

	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{			
			pc.addCols("TOTAL ",1,2);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCantidad),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total),2,1);
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>