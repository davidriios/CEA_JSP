<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: Tirza Monteza.             -->
<!-- Reporte: "Programa de citas x cuarto Admin"  -->
<!-- Reporte: CDC400050_IMAG                      -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 09/08/2010                            -->
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();
CommonDataObject cdo0  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String centro = request.getParameter("centro");
String compania = (String) session.getAttribute("_companyId");
String fechaCita = request.getParameter("fechaCita");

if (centro == null) centro = "";
if (fechaCita == null) fechaCita = "";
if (appendFilter == null) appendFilter = "";

//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Ingresos de Pacientes---------------------------------//
sql = "select   a.habitacion  habitacion, d.descripcion  nombreArea, a.cuarto as cuarto, a.fecha_cita as fecha, a.hora_cita   as hora, to_char(a.hora_cita,'hh12:mi am')  as horaCita, a.telefono as telefono, a.observacion as observacion, a.fec_nacimiento   as fec_nac, a.cod_paciente  as cod_pac, a.nombre_paciente  as nombre_paciente, decode(a.tipo_paciente,'IN','INTERNO','EXTERNO') as tipo_paciente, decode( c.observacion, null, c.descripcion, c.observacion )   as procedimiento, a.fecha_registro||a.codigo   as clave, a.empresa as aseguradora, /*** medico >>>***/(select    min('Dr.'||substr(tbl_adm_medico.primer_nombre,1,1)||'. '||tbl_adm_medico.primer_apellido) from  tbl_adm_medico, tbl_cdc_personal_cita where  (tbl_cdc_personal_cita.medico  = tbl_adm_medico.codigo) /*and   (tbl_cdc_personal_cita.funcion = 5)*/ and   (a.fecha_registro||a.codigo)   = ((to_char(tbl_cdc_personal_cita.fecha_cita))||(to_char(tbl_cdc_personal_cita.cod_cita))) and rownum = 1  ) medico   /**>> FROM >>>***/ from   tbl_cdc_cita a, tbl_cdc_cita_procedimiento b, tbl_cds_procedimiento c, tbl_sal_habitacion d /***>> WHERE >>>**/ where    (b.fecha_cita(+)  = a.fecha_registro  and   b.cod_cita(+)  = a.codigo ) and     b.procedimiento = c.codigo(+)  and  d.codigo = a.habitacion   and   d.compania = a.compania  and   d.unidad_admin  = a.centro_servicio  and    a.fecha_cita   = to_date('"+fechaCita+"','dd-mm-yyyy')  and   a.centro_servicio    = "+centro+" /***centro al q se reportan ejm 885***/  and    a.compania = "+compania+"   and  a.estado_cita in ('R','E') order by  a.habitacion /*d.descripcion*/, a.hora_cita asc";
al = SQLMgr.getDataList(sql);

sql = "select to_char(to_date('"+fechaCita+"','dd/mm/yyyy'),'fmDay dd,  fmMonth yyyy','NLS_DATE_LANGUAGE=SPANISH') textoDia from dual";
cdo0 = SQLMgr.getData(sql);

//System.out.println(" --------------------->>>> "+sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

  if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

  String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "P R O G R A M A   D E   C I T A S";
	String subtitle = cdo0.getColValue("textoDia");
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
	dHeader.addElement(".05");
	dHeader.addElement(".16");
	dHeader.addElement(".06");
	dHeader.addElement(".05");
	dHeader.addElement(".05");
	dHeader.addElement(".11");
	dHeader.addElement(".27");
	dHeader.addElement(".25");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setVAlignment(0);
	pc.setFont(9, 1);
	pc.addBorderCols("Hora",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Paciente",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Teléfono",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Tipo",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Cuarto",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Médico",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Procedimiento",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Observaciones",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.setFont(7, 1);
	pc.setTableHeader(2);

	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("nombreArea")))
		{
			if (i!=0)
			{
				pc.addCols(" ",0,dHeader.size(),cHeight);
			}
			pc.setFont(9, 1,Color.black);
			pc.addBorderCols(cdo.getColValue("nombreArea"),0,dHeader.size(),cHeight*2);
		}

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("horaCita"),0,1);
		pc.addCols(cdo.getColValue("nombre_paciente"),0,1);
		pc.addCols(cdo.getColValue("telefono"),0,1);
		pc.addCols(cdo.getColValue("tipo_paciente"),0,1);
		pc.addCols(cdo.getColValue("cuarto"),0,1);
		pc.addCols(cdo.getColValue("medico"),0,1);
		pc.addCols(cdo.getColValue("procedimiento"),0,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);

		groupBy = cdo.getColValue("nombreArea");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>