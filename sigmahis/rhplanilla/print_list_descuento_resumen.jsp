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
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String p_proveedor = request.getParameter("p_proveedor");
String p_periodo_concat = request.getParameter("anio");
String formaPago = request.getParameter("formaPago");
String anioMes = "";
      

if (appendFilter == null) appendFilter = "";
if (formaPago == null) formaPago = "";
anioMes=anio;
anioMes += mes;

if (request.getParameter("p_proveedor") != null && !request.getParameter("p_proveedor").trim().equals(""))
  {
    appendFilter += " and da.cod_acreedor = "+p_proveedor;
  }
  if (!formaPago.trim().equals("")){appendFilter += " and pa.forma_pago = "+formaPago+"  ";}

cdo1 = SQLMgr.getData("select 'AL ' || to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')), 'dd') || ' DE ' || to_char(to_date('"+mes+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') || ' DEL "+anio+"' fecha from dual");

sql= " SELECT da.cod_acreedor, pa.nombre , e.num_empleado, e.cedula1 cedula, e.nombre_empleado, d.num_documento, 'R' procede, d.saldo saldo, nvl(SUM(da.monto),0) monto_total, pe.anio||'-'||pe.cod_planilla||'-'||pe.num_planilla planilla,pa.forma_pago,decode(pa.forma_pago,1,'CHEQUE','ACH')descFormapago,case when ( pa.cuenta_bancaria is not null or (pa.cuenta_bancaria is null and pa.tipo_cuenta = 'P' and d.num_cuenta is not null)) and pa.ruta is not null and da.num_cheque is null then 1 else 0 end existe, d.num_cuenta from tbl_pla_descuento_aplicado da, tbl_pla_planilla_encabezado pe, tbl_pla_descuento d, vw_pla_empleado e, tbl_pla_acreedor pa where (pe.anio = "+anio+" and to_number(TO_CHAR(pe.fecha_final,'mm'),'99') = "+mes+"  and pe.cod_compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and pe.cod_planilla in (select cod_planilla from tbl_pla_planilla where beneficiarios = 'EM') and pe.cod_planilla NOT IN (3)) and ((da.anio = pe.anio) and (da.cod_planilla = pe.cod_planilla) and (da.num_planilla = pe.num_planilla) and (da.cod_compania = pe.cod_compania)) and ((e.emp_id = da.emp_id) and (e.compania = da.cod_compania)) and ((d.emp_id = da.emp_id) and (d.cod_compania = da.cod_compania) and (d.num_descuento = da.num_descuento)) and pa.cod_acreedor = da.cod_acreedor and pa.compania = da.cod_compania group by da.cod_acreedor, pa.nombre, e.num_empleado, e.cedula1 , e.nombre_empleado, d.num_documento, 'R', d.saldo, pe.anio||'-'||pe.cod_planilla||'-'||pe.num_planilla,pa.forma_pago,decode(pa.forma_pago,1,'CHEQUE','ACH'),case when ( pa.cuenta_bancaria is not null or (pa.cuenta_bancaria is null and pa.tipo_cuenta = 'P' and d.num_cuenta is not null)) and pa.ruta is not null and da.num_cheque is null then 1 else 0 end, d.num_cuenta HAVING SUM(da.monto) <> 0 ";

sql += " union all select da.cod_acreedor, pa.nombre, e.num_empleado, e.cedula1 cedula,e.nombre_empleado, d.num_documento,'V1' procede, d.saldo, nvl(SUM(v.monto),0) monto_total, pe.anio||'-'||pe.cod_planilla||'-'||pe.num_planilla planilla ,pa.forma_pago,decode(pa.forma_pago,1,'CHEQUE','ACH')descFormapago,case when ( pa.cuenta_bancaria is not null or (pa.cuenta_bancaria is null and pa.tipo_cuenta = 'P' and d.num_cuenta is not null)) and pa.ruta is not null and da.num_cheque is null then 1 else 0 end existe, d.num_cuenta from tbl_pla_dist_desctos_vac v, tbl_pla_descuento_aplicado da, tbl_pla_descuento d, tbl_pla_planilla_encabezado pe, vw_pla_empleado e, tbl_pla_acreedor pa where ( /*pe.anio||TO_CHAR(pe.fecha_final,'mm')="+anio+"||"+mes+" and v.anio_ac||lpad(ROUND(v.periodo_ac/2,0) ,2,'0') = "+anio+"||"+mes+"*/ to_char(pe.anio,'fm0009')||to_number(to_char(pe.fecha_final,'mm'),'99')="+anio+"||"+mes+" and to_number(to_char(v.anio_ac,'fm0009')||to_number(to_char(round(v.periodo_ac/2,0),'fm09'))) = "+anio+"||"+mes+" and pe.cod_planilla = 3 and pe.cod_compania = "+(String) session.getAttribute("_companyId")+appendFilter+" ) and ((da.anio = pe.anio) and (da.cod_planilla = pe.cod_planilla) and (da.num_planilla = pe.num_planilla) and (da.cod_compania = pe.cod_compania )) and ((e.emp_id = da.emp_id) and (e.compania = da.cod_compania)) and ((d.emp_id = da.emp_id) and (d.cod_compania = da.cod_compania) and (d.num_descuento = da.num_descuento)) and ((v.cod_compania = da.cod_compania) and (v.anio = da.anio) and (v.cod_planilla = da.cod_planilla) and (v.num_planilla = da.num_planilla) and (v.cod_grupo = da.cod_grupo) and (v.cod_acreedor =da.cod_acreedor) and (v.num_descuento = da.num_descuento) and (v.emp_id = da.emp_id)) and pa.cod_acreedor = da.cod_acreedor and pa.compania = da.cod_compania group by da.cod_acreedor, pa.nombre, e.num_empleado, e.cedula1, e.nombre_empleado, d.num_documento, 'V1', d.saldo, pe.anio||'-'||pe.cod_planilla||'-'||pe.num_planilla ,pa.forma_pago,decode(pa.forma_pago,1,'CHEQUE','ACH'),case when ( pa.cuenta_bancaria is not null or (pa.cuenta_bancaria is null and pa.tipo_cuenta = 'P' and d.num_cuenta is not null)) and pa.ruta is not null and da.num_cheque is null then 1 else 0 end, d.num_cuenta having sum(da.monto) <> 0 ";

sql += "UNION  all select da.cod_acreedor, pa.nombre, e.num_empleado, e.cedula1 cedula, e.nombre_empleado, d.num_documento,'V2' procede, d.saldo, nvl(SUM(v.monto),0) pagar, pe.anio||'-'||pe.cod_planilla||'-'||pe.num_planilla planilla,pa.forma_pago,decode(pa.forma_pago,1,'CHEQUE','ACH')descFormapago,case when ( pa.cuenta_bancaria is not null or (pa.cuenta_bancaria is null and pa.tipo_cuenta = 'P' and d.num_cuenta is not null)) and pa.ruta is not null and da.num_cheque is null then 1 else 0 end, d.num_cuenta from tbl_pla_dist_desctos_vac v, tbl_pla_descuento_aplicado da, tbl_pla_descuento d, tbl_pla_planilla_encabezado pe, vw_pla_empleado e , tbl_pla_acreedor pa where to_char(pe.anio,'fm0009')||to_char(to_number(to_char(pe.fecha_final,'mm'),'99'),'fm09') < "+anioMes+" and to_char(pe.anio,'fm0009')||to_char(to_number(to_char(pe.fecha_final,'mm'),'99'),'fm09')  >= 201201 and to_number(to_char(v.anio_ac,'fm0009')||to_char(round(v.periodo_ac/2,0),'fm09')) = "+anioMes+" /* to_char(pe.anio,'fm0009')||to_char(to_number(to_char(pe.fecha_final,'mm'),'99'),'fm09') < "+anioMes+" and to_number(pe.anio||to_char(pe.fecha_final,'mm')) >= 201201 and to_number(v.anio_ac||to_char(round(v.periodo_ac/2,0),'fm09')) = to_number("+anio+"||"+mes+") */and pe.cod_planilla = 3 and pe.cod_compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and ((da.anio = pe.anio) and (da.cod_planilla = pe.cod_planilla) and (da.num_planilla = pe.num_planilla) and (da.cod_compania = pe.cod_compania)) and ((e.emp_id = da.emp_id) and (e.compania = da.cod_compania)) and ((d.emp_id = da.emp_id) and (d.cod_compania = da.cod_compania) and (d.num_descuento = da.num_descuento)) and ((v.cod_compania = da.cod_compania) and (v.anio = da.anio) and (v.cod_planilla = da.cod_planilla) and (v.num_planilla = da.num_planilla) and (v.cod_grupo = da.cod_grupo) and (v.cod_acreedor = da.cod_acreedor) and (v.num_descuento = da.num_descuento) and (v.emp_id =  da.emp_id)) and pa.cod_acreedor = da.cod_acreedor and pa.compania = da.cod_compania GROUP BY da.cod_acreedor, pa.nombre, e.num_empleado,e.cedula1,e.nombre_empleado, d.num_documento,'V2', d.saldo, pe.anio||'-'||pe.cod_planilla||'-'||pe.num_planilla,pa.forma_pago,decode(pa.forma_pago,1,'CHEQUE','ACH'),case when ( pa.cuenta_bancaria is not null or (pa.cuenta_bancaria is null and pa.tipo_cuenta = 'P' and d.num_cuenta is not null)) and pa.ruta is not null and da.num_cheque is null then 1 else 0 end, d.num_cuenta having sum(da.monto) <> 0 ";
 sql += " order by 1,3" ;


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String time = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");

	String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+time+"-"+UserDet.getUserId()+".pdf";

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
	String subtitle = "RESUMEN MENSUAL DE ACREEDORES";
	String xtraSubtitle = cdo1.getColValue("fecha");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
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
		pc.addBorderCols("# Empleado",0,1);
		pc.addBorderCols("Cédula",1,1);		
		pc.addBorderCols("Nombre",1,1);
		pc.addBorderCols("Forma Pago",1,1);
		pc.addBorderCols("Ref. ",1,1);
		pc.addBorderCols("No. Cuenta",1,1);
		pc.addBorderCols("Saldo",1,1);	
		pc.addBorderCols("Monto Descontado",1,1);		
		
						
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String sec = "";
	     double totDesc=0.00,totDescAch=0.00,total=0.00;
		 int contDesc;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
        
		if (!sec.equalsIgnoreCase(cdo.getColValue("cod_acreedor")))
			{
			
		if (i!=0)
		{
		
			pc.addCols(" ",0,7);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totDesc),2,1,0.0f,1f,0.0f,0.0f);
		}
			pc.setFont(7, 1);
			pc.addCols(" "+cdo.getColValue("cod_acreedor")+" - "+cdo.getColValue("nombre"),0,dHeader.size());
			totDesc = 0.00;
			}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("num_empleado"),0,1);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre_empleado"),0,1);	
			pc.addCols(" "+cdo.getColValue("descFormaPago"),0,1);	
			pc.addCols(" "+cdo.getColValue("planilla"),1,1);
			pc.addCols(" "+cdo.getColValue("num_cuenta"),1,1);
			pc.addCols(" "+cdo.getColValue("saldo"),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))+((cdo.getColValue("existe").trim().equals("0"))?"*":""),2,1);	
			
			totDesc += Double.parseDouble(cdo.getColValue("monto_total"));
			total += Double.parseDouble(cdo.getColValue("monto_total"));
			if(cdo.getColValue("forma_pago") != null && !cdo.getColValue("forma_pago").trim().equals("") && cdo.getColValue("forma_pago").trim().equals("2"))totDescAch += Double.parseDouble(cdo.getColValue("monto_total"));
		    //contDesc ++;
			
			sec=cdo.getColValue("cod_acreedor");	
	
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else 
	{
			
			pc.addCols(" ",0,6);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totDesc),2,2,0.0f,1f,0.0f,0.0f);
			
			pc.setFont(8, 0,Color.blue);
			pc.addCols("TOTAL DE DESCUENTOS: ",0,6);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,2,0.0f,0.05f,0.0f,0.0f);
			pc.addCols("TOTAL POR ACH ",0,6);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totDescAch),2,2,0.0f,0.05f,0.0f,0.0f);
			
			
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>