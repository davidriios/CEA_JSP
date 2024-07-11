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
String emp_id = request.getParameter("emp_id");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

		 sql = "select a.primer_nombre||' '||a.segundo_nombre ||' '|| a.primer_apellido||' '||a.segundo_apellido as apellido, a.num_empleado as numempleado,   a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento cedula, a.provincia, a.sigla, a.tomo, a.asiento, to_char(a.fecha_ingreso,'dd/month/yyyy') as fechaing, a.emp_id, to_char(sysdate,'yyyy') - to_char(a.fecha_ingreso,'yyyy') as anio, to_char(sysdate,'mm') - to_char(a.fecha_ingreso,'mm') as meses, to_char(a.salario_base,'999,999,990.00') as salario, to_char(a.gasto_rep,'99,999,990.00') as gastorep, decode(c.estado,'P','PENDIENTE','A','APROBADO','N','ANULADO') as estado,b.denominacion , e.descripcion as depto,c.codigo, c.motivo_falta as tipos, to_char(c.fecha_inicio,'dd/mm/yyyy') as desdeSalida, to_char(c.fecha_final,'dd/mm/yyyy') as hastaSalida, to_char(c.fecha_retorno,'dd/mm/yyyy') as fechaRetorno, to_char(c.fecha_parto,'dd/mm/yyyy') as fechaParto,  c.cant_dias_pagar as diasPagar, c.CANT_QUINCENAS as quincenaSal, c.CANT_MESES as mesSal, c.CANT_DIAS as diaSal, c.tipo_subsidio, f.descripcion as descFalta, a.ubic_depto, c.comentario from tbl_pla_empleado a, tbl_pla_cargo b, tbl_sec_unidad_ejec e, tbl_pla_cc_licencia c, tbl_pla_motivo_falta f where a.compania = b.compania and a.cargo = b.codigo and a.compania = e.compania and a.ubic_depto = e.codigo and a.emp_id = c.emp_id and a.compania = c.compania and c.motivo_falta = f.codigo(+) and a.compania = "+session.getAttribute("_companyId")+appendFilter+" and a.emp_id = "+emp_id+" order by c.motivo_falta, a.ubic_depto";
		 
al = SQLMgr.getDataList(sql);

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
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LISTADO DE LICENCIA - INCAPAC - RIESGOS PROF.";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".15");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".10");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".15");
		
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(6, 1);
		pc.addBorderCols("Cédula ",0);	
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Fecha Desde",1);	
		pc.addBorderCols("Fecha Hasta",1);
		pc.addBorderCols("Fecha Retorno ",1);	
		pc.addBorderCols("Meses ",1);	
		pc.addBorderCols("Quinc.",1);
		pc.addBorderCols("Días ",1);	
		pc.addBorderCols("Días a Pagar",1);
		pc.addBorderCols("Observación",1);
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String  tipo = "";
			String  sub = "";
			
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
   		if (!tipo.equalsIgnoreCase(cdo.getColValue("tipos")))
			{
			pc.setFont(7, 4);
			pc.addCols(" "+cdo.getColValue("tipos")+" - "+cdo.getColValue("descFalta"),0,dHeader.size());
			sub ="";
			}
			 if (!sub.equalsIgnoreCase(cdo.getColValue("ubic_depto")))
			{
			
			pc.setFont(7, 1);
			pc.addCols("   [ "+cdo.getColValue("ubic_depto")+" ]   "+cdo.getColValue("depto"),0,dHeader.size());
			}
		pc.setFont(6, 0);
		pc.setVAlignment(0);
		 
		pc.addCols(" "+cdo.getColValue("cedula"),0,1);
			pc.addCols(" "+cdo.getColValue("apellido"),0,1);	
			pc.addCols(" "+cdo.getColValue("estado"),0,1);																			
			pc.addCols(" "+cdo.getColValue("desdeSalida"),1,1);	
			pc.addCols(" "+cdo.getColValue("hastaSalida"),1,1);	
			pc.addCols(" "+cdo.getColValue("fechaRetorno"),1,1);	
			pc.addCols(" "+cdo.getColValue("mesSal"),1,1);		
			pc.addCols(" "+cdo.getColValue("quincenaSal"),1,1);																			
			pc.addCols(" "+cdo.getColValue("diaSal"),1,1);	
			pc.addCols(" "+cdo.getColValue("diasPagar"),1,1);	
			pc.addCols(" "+cdo.getColValue("comentario"),0,1);	
		
		tipo=cdo.getColValue("tipos");	
		sub=cdo.getColValue("ubic_depto");	
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>