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
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupo = request.getParameter("grupo");
String unidad = request.getParameter("unidad");

if (appendFilter == null) appendFilter = "";


	 sql= "select adef.compania  aeun_compania, adef.ue_codigo aeun_ue_codigo, to_char(adef.provincia,'09')||adef.sigla||'-'||to_char(adef.tomo,'09999')||'-'||to_char(adef.asiento,'099999')  adem_cedula , to_char(adef.fecha,'DD-MM-YYYY') adef_fecha, adef.ta_hent adef_ta_hent, adef.ta_hsal adef_ta_hsal, adef.motivo adef_motivo, adef.tiempo_horas adef_tiempo_horas, adef.tiempo_minutos adef_tiempo_minutos, em.primer_nombre||' '|| decode(em.sexo,'F',decode(em.apellido_casada, null,em.primer_apellido,decode(em.usar_apellido_casada,'S','DE '|| em.apellido_casada,em.primer_apellido)),em.primer_apellido) em_nombre_empleado, em.num_empleado em_num_empleado, em.num_ssocial em_num_ssocial, co.nombre  co_nombre, ue.descripcion ue_descripcion, ue.codigo ue_codigo, co.logo, decode(adef.accion,'DV','Devoluc. x incapacidad el '||to_char(adef.fecha_a_devolver,'dd/mm/yyyy')) dsp_devolucion, adef.accion, ce.ubicacion_fisica,  to_char(ca.fecha_inicial,'FMMONTH','NLS_DATE_LANGUAGE = SPANISH') as mes,'Correspondiente a la '||decode(mod(ca.periodo,2),'0','2da Quincena ','1ra Quincena de ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' de '||to_char(ca.fecha_inicial,'yyyy') quincena, to_char(ca.fecha_cierre + 1,'dd/mm/yyyy') fechaEntrega from tbl_pla_temporal_asistencia adef, tbl_pla_empleado em, compania co, tbl_pla_ct_grupo ue, tbl_pla_ct_empleado ce, tbl_pla_calendario ca where ((adef.compania = "+session.getAttribute("_companyId")+") and (adef.ue_codigo = "+grupo+") and (to_date(to_char(adef.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= '"+desde+"') and (to_date(to_char(adef.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= '"+hasta+"') and (em.emp_id = adef.emp_id) and (em.compania = adef.compania) and (ce.emp_id = em.emp_id) and (ce.compania = em.compania) and (ce.num_empleado = em.num_empleado) and (ce.grupo = adef.ue_codigo) and (co.codigo = em.compania) and (adef.compania = co.codigo) and (co.codigo = em.compania) and (ue.codigo = adef.ue_codigo) and (ue.compania = adef.compania) and (ce.ubicacion_fisica like "+area+")) and (ce.estado <> 3 or (ce.estado = 3 and fecha_egreso_grupo >= '"+desde+"')) and (ce.estado <> 3  or (ce.estado = 3 and fecha_egreso_grupo  >= '"+desde+"')) and (to_date(to_char(ca.trans_desde,'dd/mm/yyyy'),'dd/mm/yyyy') >= '"+desde+"') and (to_date(to_char(ca.trans_hasta,'dd/mm/yyyy'),'dd/mm/yyyy') <= '"+hasta+"') and ca.tipopla = 1 order by em.num_empleado, adef.fecha";		

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
	String subtitle = " NOTIFICACIONES DE AUSENCIAS Y TARDANZAS";
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
		pc.addBorderCols("Cedula ",0);	
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Fecha Desde",1);	
		pc.addBorderCols("Fecha Hasta",1);
		pc.addBorderCols("Fecha Retorno ",1);	
		pc.addBorderCols("Meses ",1);	
		pc.addBorderCols("Quinc.",1);
		pc.addBorderCols("Dias ",1);	
		pc.addBorderCols("Dias a Pagar",1);
		pc.addBorderCols("Observacion",1);
	
	
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
			pc.addCols("   [ "+cdo.getColValue("ubic_depto")+" ]   "+cdo.getColValue("descripcion"),0,dHeader.size());
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