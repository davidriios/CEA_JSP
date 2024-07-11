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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdo1 = new CommonDataObject();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String periodo = request.getParameter("periodo");
String anio = request.getParameter("anio");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (appendFilter == null) appendFilter = "";

sql = "select temp.grupo, decode(emp.provincia,0,' ',00,' ',10,'0',11,'B',12,'C', emp.provincia)|| rpad(decode(emp.sigla,'00','  ','0','  ', emp.sigla),2,' ')||'-'||lpad(to_char(emp.tomo),3,'0')||'-'|| lpad(to_char(emp.asiento),6,'0') cedula , to_char(temp.fecha_inicio,'dd/mm/yyyy') fecha_inicio, to_char(temp.fecha_final,'dd/mm/yyyy') fecha_final, temp.tipo_trx, ttrx.descripcion dsp_tipo_transaccion, temp.comentario, temp.sub_tipo_trx, ttrx.descripcion||'  -  '||sttrx.descripcion dsp_subtipo_transaccion, temp.cantidad, temp.monto_unitario, temp.monto, emp.primer_nombre||' '|| decode(emp.sexo,'F',decode(emp.apellido_casada, null,emp.primer_apellido,decode(emp.usar_apellido_casada,'S','DE '|| emp.apellido_casada,emp.primer_apellido)),emp.primer_apellido)  nombre_empleado, temp.num_empleado, ue.descripcion  nombre_grupo, temp.accion, temp.anio_pago,  temp.quincena_pago,  emp.estado, 'Correspondiente a la '||decode(mod(ca.periodo,2),'0','2da Quincena de ','1ra Quincena de ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' de '||to_char(ca.fecha_inicial,'yyyy') quincena, est.descripcion estadoDesc from tbl_pla_transac_emp  temp,	tbl_pla_empleado emp, tbl_pla_ct_grupo ue, tbl_pla_tipo_transaccion ttrx, tbl_pla_sub_tipo_transaccion sttrx, tbl_pla_calendario ca, tbl_pla_estado_emp est where  (emp.compania = temp.compania and emp.emp_id = temp.emp_id) and (ue.codigo = temp.grupo and ue.compania = emp.compania) and (sttrx.compania = temp.compania and sttrx.transaccion = ttrx.codigo and sttrx.sub_tipo = temp.sub_tipo_trx) and (ttrx.codigo = temp.tipo_trx and ttrx.compania = temp.compania) and (temp.compania = "+session.getAttribute("_companyId")+" and temp.anio_reporta = "+anio+" and	temp.quincena_reporta = "+periodo+" and temp.grupo = "+grupo+" and temp.cod_planilla_pago = 1) and temp.aprobacion_estado = 'S' and ca.periodo = "+periodo+" and ca.tipopla= 1 and emp.estado = est.codigo order by temp.tipo_trx, emp.num_empleado";
 al = SQLMgr.getDataList(sql);

 sql = "select ue.descripcion nombre_unidad, ue.codigo ue_codigo,  'Correspondiente a la '||decode(mod(ca.periodo,2),'0','2da Quincena de ','1ra Quincena de ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' de '||to_char(ca.fecha_inicial,'yyyy') quincena, 'PERIODO DEL '||'"+desde+"'|| ' AL '||'"+hasta+"' as titulo from tbl_pla_calendario ca, tbl_pla_ct_grupo ue where ue.codigo="+grupo+" and ue.compania = "+session.getAttribute("_companyId")+" and ca.tipopla = 1 and ca.periodo =  "+periodo;
	cdo1 = SQLMgr.getData(sql);


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
	String title = "RECURSOS HUMANOS";
	String subtitle = " REPORTE DE OTROS PAGOS A EMPLEADOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".05");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
	
			pc.setFont(7, 4);
			pc.addCols("[ "+cdo1.getColValue("ue_codigo")+" ] "+cdo1.getColValue("nombre_unidad"),0,dHeader.size());
				
			pc.setFont(7, 1);
			pc.addCols(" "+cdo1.getColValue("quincena"),0,dHeader.size());
		
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String  tipo = "";
			String  sub = "";
			String  emp = "";
			String  motivo = "";
			String  t_he = "";
			String  t_hs = "";
			
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
 			
			if (!emp.equalsIgnoreCase(cdo.getColValue("dsp_subtipo_transaccion")))
			{
			pc.setFont(7, 1);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(" "+cdo.getColValue("dsp_subtipo_transaccion"),0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
			
		pc.addCols("Cédula",0,1);	
		pc.addCols("No.",1,1);
		pc.addCols("Nombre del Empleado",1,1);
		pc.addCols("Fecha Inicio",1,1);	
		pc.addCols("Fecha Final",1,1);
		pc.addCols("Cant.",2,1);	
		pc.addCols("Monto",2,1);	
		pc.addCols("Monto",2,1);
		pc.addCols("   Observaciones",0,2);
		
		pc.addCols(" ",0,6);	
		pc.addCols("Unitario",2,1);
		pc.addCols("Total",2,1);	
		pc.addCols(" ",0,2);
		}
	 
		pc.setFont(6, 0);
		pc.setVAlignment(0);
	
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);	
			pc.addCols(" "+cdo.getColValue("num_empleado"),1,1);																			
			pc.addCols(" "+cdo.getColValue("nombre_empleado"),0,1);	
			pc.addCols(" "+cdo.getColValue("fecha_inicio"),1,1);	
			pc.addCols(" "+cdo.getColValue("fecha_final"),1,1);	
			pc.addCols(" "+cdo.getColValue("cantidad"),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_unitario")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);	
			pc.addCols("   "+cdo.getColValue("comentario"),0,1);
			pc.addCols(" "+cdo.getColValue("accion"),1,1);
		
		
	  tipo=cdo.getColValue("nombre_grupo");	
		sub=cdo.getColValue("nombre_empleado");	
		emp=cdo.getColValue("dsp_subtipo_transaccion");	
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
	 	pc.addCols(" ",0,dHeader.size());
		pc.addCols(al.size()+" Registros en total",0,dHeader.size());
		
//	pc.addCols("El empleado está actualmente en Estado "+cdo.getColValue("estadoDesc")+" el pago se realizara en el periodo "+cdo.getColValue("anio_pago")+" - "+cdo.getColValue("periodo_pago")+" ",0,dHeader.size());
	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>