<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList val = new ArrayList();
String sql = "";
String newsql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String empId = request.getParameter("empId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id"); 
Company com= new Company ();


if (appendFilter == null) appendFilter = "";

sql = "select b.nombre as nombre, (e.primer_nombre||' '||e.primer_apellido) as nomEmpleado, to_char(d.sal_ausencia,'999,990.00') as bruto, to_char(d.gasto_rep,'999,990.00') as gastoRep, to_char(d.total_ded,'999,990.00') as descuento, to_char(d.sal_neto,'999,990.00') as neto, to_char(a.fecha_pago,'dd-mm-yyyy') as fechaPago, ltrim(b.nombre,18)||' del '||a.fecha_inicial||' al '||a.fecha_final as descripcion, d.cod_planilla as codPlanilla, d.num_cheque as cheque, d.num_planilla as numPlanilla, d.anio, e.emp_id as empId, e.num_empleado as numEmpleado, nvl(e.ubic_depto,ubic_seccion) as ubicDepto, nvl(f.descripcion,'Por designar ') as descDepto from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo";
al = SQLMgr.getDataList(sql);

newsql = "Select to_char(sum(d.sal_ausencia),'999,999,990.00') as sbruto, to_char(sum(d.gasto_rep),'999,999,990.00') as sgasto, to_char(sum(d.total_ded),'999,999,990.00') as sdes, to_char(sum(d.sal_neto),'999,999,990.00') as sneto from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo";

val =SQLMgr.getDataList(newsql);

sql="select a.codigo as compCode, a.nombre as compLegalName,nvl( a.ruc,'') as compRUCNo, nvl(a.apartado_postal,'') as compPAddress, a.zona_postal as compAddress, nvl(a.telefono,'') as compTel1, b.fecha_inicial||' al '||b.fecha_final as compDistrict, c.nombre as compLegalName from TBL_SEC_COMPANIA a, tbl_pla_planilla_encabezado b, tbl_pla_planilla c where b.num_planilla="+num+" and b.cod_planilla="+cod+" and b.anio = "+anio+" and a.codigo= b.cod_compania and a.codigo= c.compania and b.cod_planilla = c.cod_planilla and a.codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);


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
	String title = " "+com.getCompLegalName()+" [ "+num+" ] - [ "+anio+" ]";
	String subtitle = "Pago Correspondiente del :  "+com.getCompDistrict();
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".25");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
			

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Cheque",0);
		pc.addBorderCols("Nombre",1);													
		pc.addBorderCols("Num.Empleado",1);
		pc.addBorderCols("Seccion",1);	
		pc.addBorderCols("Salario",2);
		pc.addBorderCols("GastoRep.",2);													
		pc.addBorderCols("Deducciones",2);
		pc.addBorderCols("Salario Neto",2);	
		
				
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo.getColValue("cheque"),1,1);
		pc.addCols(" "+cdo.getColValue("nomEmpleado"),0,1);																			
		pc.addCols(" "+cdo.getColValue("numEmpleado"),1,1);
		pc.addCols(" "+cdo.getColValue("descDepto"),0,1);	
		pc.addCols(" "+cdo.getColValue("bruto"),2,1);
		pc.addCols(" "+cdo.getColValue("gastoRep"),2,1);																			
		pc.addCols(" "+cdo.getColValue("descuento"),2,1);
		pc.addCols(" "+cdo.getColValue("neto"),2,1);
		
			

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	int k=0;
					    CommonDataObject cdo1 = (CommonDataObject) val.get(k);
					
						pc.addCols(" TOTALES POR PLANILLA : ",2,4);
						pc.addCols(" "+cdo1.getColValue("sbruto"),2,1);
						pc.addCols(" "+cdo1.getColValue("sgasto"),2,1);																			
						pc.addCols(" "+cdo1.getColValue("sdes"),2,1);
						pc.addCols(" "+cdo1.getColValue("sneto"),2,1);
					
						
					
						pc.addCols(al.size()+" Empleados en Planilla",0,dHeader.size());
						
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>