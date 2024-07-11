<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList tot = new ArrayList();
ArrayList val = new ArrayList(); 
String sql = "";
String newsql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String empId = request.getParameter("empId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String mes = request.getParameter("mes"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id"); 
CommonDataObject cdo2 = null;
Company com= new Company ();


if (appendFilter == null) appendFilter = "";

sql = "select to_char(a.excepciones,'00') as tipo_reg, nvl(e.num_ssocial,' ') as num_ssocial, to_char(e.provincia,'00') provincia, nvl(decode(e.sigla,'00','',e.sigla),'') as sigla, to_char(e.tomo,'00000') as tomo, to_char(e.asiento,'000000') as asiento,nvl(e.pasaporte, (to_char(e.provincia,'00')||' '||nvl(decode(e.sigla,'00','',e.sigla),'')||' '||to_char(e.tomo,'00000')||' '|| to_char(e.asiento,'000000'))) as cedula, a.nv_provincia, a.nv_sigla, a.nv_tomo, a.nv_asiento, rpad(substr(decode(sexo,'F',decode(apellido_casada, null, primer_apellido, decode(usar_apellido_casada,'S','DE '|| apellido_casada,primer_apellido)), primer_apellido),1,14),14,' ')  primer_apellido, e.primer_nombre, e.sexo, a.excepciones tc, a.departamento, a.num_empleado, a.ajuste, a.consecutivo, to_char(a.sal_bruto,'99,999,990.00') as sal_bruto, decode(a.excepciones,'73',0,a.sal_bruto) salario_cotiza, to_char(a.imp_renta,'99,999,990.00') as imp_renta, a.departamento, a.cod_reporte, a.cod_compania,  e.tipo_renta||decode(nvl(e.num_dependiente,0),10,'O',11,'P',12,'Q',13,'R',14,'S',15,'T',16,'U',17,'V',18,'X',19,'Y',20,'Z',nvl(e.num_dependiente,0)) clave, to_char(a.fondo_com,'99,999,990.00') as fondo_com, to_char(a.decimo,'99,999,990.00') as decimo, to_char(a.otros_ingresos,'99,999,990.00') as otros, a.observacion, b.anio from tbl_pla_retenciones a, tbl_pla_reporte_encabezado b, tbl_pla_parametros c, tbl_pla_empleado e where a.anio  = "+anio+" and a.mes = "+num+" and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and b.cod_compania = a.cod_compania and  c.cod_compania = a.cod_compania and e.compania = a.cod_compania and a.cod_reporte = "+cod+" and a.anio = b.anio and a.mes = b.mes and a.cod_reporte = b.cod_reporte and  a.emp_id = e.emp_id and c.estado = 'A' order by e.provincia, e.sigla, e.tomo, e.asiento, e.primer_apellido, e.primer_nombre";
al = SQLMgr.getDataList(sql);

sql="select a.codigo as compCode, a.nombre as compDescription, nvl( a.ruc,'') as compRUCNo, nvl(a.telefono,'') as compTel1, b.fecha_proceso as compDistrict,  a.actividad as compLicense, a.representante_legal as compLegalName, a.direccion as compAddress, a.fax as compFax1, a.num_patronal as compCountryId, a.cedula_juridica as compPAddress, a.cedula_natural as compClave, a.licencia as compState, d.correlativo as other3, upper(to_char(to_date(b.mes,'mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH')) as other1, b.anio as other2  from tbl_sec_compania a, tbl_pla_reporte_encabezado b, tbl_pla_reporte c, tbl_pla_parametros d where b.mes = "+num+" and b.cod_reporte="+cod+" and b.anio = "+anio+" and a.codigo= b.cod_compania and b.cod_reporte = c.cod_reporte and a.codigo = d.cod_compania and a.codigo="+(String) session.getAttribute("_companyId");
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

	float width = 72 * 14f;//612
	float height = 72 * 8.5f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CAJA DE SEGURO SOCIAL DE PANAMA ";
	String subtitle = "PLANILLA MENSUAL DE CUOTAS, APORTES E IMPUESTO SOBRE LA RENTA"; 
	String xtraSubtitle = "CORRESPONDIENTE AL MES DE :  "+com.getOther1()+"   DE   "+com.getOther2();
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".02");
		dHeader.addElement(".07");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".02");
		dHeader.addElement(".02");
		dHeader.addElement(".02");
		dHeader.addElement(".05");
		dHeader.addElement(".02");
		dHeader.addElement(".07");
		dHeader.addElement(".05");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".02");
		dHeader.addElement(".07");
		dHeader.addElement(".10");
		
			

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


	
	
	String unidad = "";
	String total = "FINAL";
		
		//second row
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
      
	  if (!unidad.equalsIgnoreCase(cdo.getColValue("cod_reporte")))
			{
			
						
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			
			pc.setFont(7, 1);
			pc.addCols("  ",0,2);
			pc.addCols(" NOMBRE DEL PATRONO: "+com.getCompDescription(),0,9);
			pc.addCols(" NOMBRE DEL LUGAR DE TRABAJO: ",2,3);
			pc.addCols(" "+com.getCompDescription(),0,4);
		
			
				pc.setFont(7, 1);
			pc.addCols("  ",0,2);
			pc.addCols(" DIRECCION FISCAL: "+com.getCompAddress(),0,9);
			pc.addCols(" ACTIVIDAD ECONOMICA: ",2,3);
			pc.addCols(" "+com.getCompLicense(),0,4);
			
				pc.setFont(7, 1);
			pc.addCols("  ",0,2);
			pc.addCols(" CEDULA JURIDICA: "+com.getCompPAddress(),0,8);
			pc.addCols(" CEDULA NATURAL: ",1,2);
			pc.addCols(" "+com.getCompClave(),0,2);
			pc.addCols(" LICENCIA: ",2,2);
			pc.addCols(" "+com.getCompState()+"          TELEFONO: "+com.getCompTel1(),0,2);
			
				pc.setFont(7, 1);
			pc.addCols("  ",0,2);
			pc.addCols(" REPRESENTANTE LEGAL: "+com.getCompLegalName(),0,16);
			
			pc.setFont(7, 1);
			pc.addCols("  ",0,2);
			pc.addCols(" CORRELATIVO: "+com.getOther3(),0,9);
			pc.addCols(" NUMERO PATRONAL: ",2,3);
			pc.addCols(" "+com.getCompCountryId(),0,4);
			
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			
		pc.setFont(7, 3);
		pc.addCols("C",0,1);
		pc.addCols("No.",0,1);													
		pc.addCols("CEDULA",1,1);
		pc.addCols("APELLIDO",1,1);
		pc.addCols("NOMBRE",1,1);	
		pc.addCols("S",1,1);	
		pc.addCols("TC",1,1);
		pc.addCols("DEP",1,1);													
		pc.addCols("No.",1,1);
		pc.addCols("DS",1,1);	
		pc.addCols("SALARIO",2,1);	
		pc.addCols("MONTO",2,1);	
		pc.addCols("CLAVE",2,1);
		pc.addCols("DECIMO",2,1);													
		pc.addCols("OTROS",2,1);
		pc.addCols("SIA.",2,1);	
		pc.addCols("CEDULA",2,1);
		pc.addCols("OBSERVACIONES",1,1);	
		
				
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
		pc.setFont(7, 3);
		pc.addCols("0",0,1);
		pc.addCols("SEGURO",0,2);													
		pc.addCols("",2,5);
		pc.addCols("EMP",1,1);
		pc.addCols("EF",1,1);
		pc.addCols(" ",1,1);
		pc.addCols("I/R",2,1);
		pc.addCols("I/R",2,1);
		pc.addCols("T. MES",2,1);
		pc.addCols("INGRESOS",2,1);
		pc.addCols("CAP",2,1);
		pc.addCols("NUEVA",2,1);
		pc.addCols("",2,1);
			//table body
		
		}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo.getColValue("tipo_reg"),0,1);
		pc.addCols(" "+cdo.getColValue("num_ssocial"),0,1);																			
		pc.addCols(" "+cdo.getColValue("cedula"),0,1);
		pc.addCols(" "+cdo.getColValue("primer_apellido"),0,1);	
		pc.addCols(" "+cdo.getColValue("primer_nombre"),0,1);
		pc.addCols(" "+cdo.getColValue("sexo"),1,1);																			
		pc.addCols(" "+cdo.getColValue("tipo_reg"),1,1);
		pc.addCols(" "+cdo.getColValue("departamento"),2,1);
		pc.addCols(" "+cdo.getColValue("num_empleado"),2,1);
		pc.addCols(" ",1,1);
		pc.addCols(" "+cdo.getColValue("sal_bruto"),2,1);	
		pc.addCols(" "+cdo.getColValue("imp_renta"),2,1);
		pc.addCols(" "+cdo.getColValue("clave"),2,1);																			
		pc.addCols(" "+cdo.getColValue("decimo"),2,1);
		pc.addCols(" "+cdo.getColValue("otros"),2,1);
		pc.addCols(" "+cdo.getColValue("ajuste"),2,1);
		pc.addCols(" ",2,1);
		pc.addCols(" "+cdo.getColValue("observacion"),2,1);
		
		
	
		
		unidad = cdo.getColValue("cod_reporte");
			

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	
			pc.setFont(7, 0);
			pc.addCols(" ",1, 1);
			pc.addBorderCols(" ",1, 17, 1.0f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addCols(" ",1, 1);

      for (int j=0; j<tot.size(); j++)
	{
		 cdo2 = (CommonDataObject) tot.get(j);
   
		pc.addCols(" ",2,5);
		pc.addCols(" -- SALARIO -- ",1,4);
		pc.addCols(" -- IMPUESTO R. -- ",1,3);
		pc.addCols(" -- EXCEPCIONES -- ",1,2);
		pc.addCols(" -- DECIMO T. M. -- ",1,2);
		pc.addCols(" -- TOTAL X. -- ",1,1);
		
	
		
			//cdo2 = (CommonDataObject) htUni.get(unidad);
			pc.addCols(" ",2,3);
			pc.addCols(" TOTALES FINALES :    ",2,3);
			
			pc.addCols(" ",2,12);
	
		pc.addTable();
	}
	
	pc.addNewPage();
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>