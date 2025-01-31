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
Reporte
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String code = request.getParameter("code");
String fg = request.getParameter("fg");

if (appendFilter == null) appendFilter = "";
if (desc == null) desc = "";
if (code == null ) code = "0";
if (fg == null) fg="";
if(fg.trim().equals("TD"))code="0";
cdop = SQLMgr.getPacData(pacId, noAdmision);

  sql = "select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy') as FECHA_CREA, USUARIO_MODIF, to_char(FECHA_CREAC,'hh12:mi:ss am') as hora_creac, EKG , (select  primer_nombre || ' ' ||segundo_nombre || ' ' || decode(apellido_de_casada, null, primer_apellido|| ' ' || segundo_apellido,primer_apellido||' '|| apellido_de_casada) as nombre_medico from tbl_adm_medico where codigo=medico ) nombre_medico from TBL_SAL_PROCEDIMIENTO_PACIENTE where pac_id="+pacId+" and secuencia="+noAdmision+(!code.equals("")&&!code.equals("0")?" and codigo = "+code:"")+" order by FECHA_CREAC DESC";

  if (fg.equalsIgnoreCase("exp_seccion")){

    sql = "SELECT rs.CODIGO||'-'||c.codigo AS codigo, c.observacion as observacion, c.nombre as DESCRIPCION, to_char(c.fecha_creacion,'dd/mm/yyyy') as FECHA_CREA, to_char(c.fecha_creacion,'hh12:mi:ss am') as hora_creac, c.estado_orden as estado,(select descripcion from tbl_sal_desc_estado_ord where estado=c.estado_orden) as estadoDesc,  decode(c.prioridad,'H','HOY','M','MA?ANA','U','URGENTE','O','OTROS',prioridad) as prioridad,(select  primer_nombre || ' ' ||segundo_nombre || ' ' || decode(apellido_de_casada, null, primer_apellido|| ' ' || segundo_apellido,primer_apellido||' '|| apellido_de_casada) as nombre_medico from tbl_adm_medico where codigo=rs.medico ) as nombre_medico,nvl(rs.telefonica,'N')telefonica,to_char(omitir_fecha,'dd/mm/yyyy')omitir_fecha,c.centro_servicio cds  FROM tbl_sal_detalle_orden_med c, TBL_SAL_ORDEN_MEDICA rs WHERe rs.pac_id =c.pac_id and rs.secuencia=c.secuencia and rs.codigo = c.orden_med and rs.pac_id="+pacId+" and rs.secuencia="+noAdmision;

   if (!code.equals("")&&!code.equals("0")) sql +=" and rs.codigo = "+code;

   sql +=" order by  c.centro_servicio asc,c.fecha_creacion asc ";

  }

		al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

	float width = 77 * 8.5f;//612
	float height = 73 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";;
	String subtitle = desc;
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".55");
		dHeader.addElement(".15");

        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }

  PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("FECHA",1,1);
		pc.addBorderCols("HORA",1,1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("MEDICO SOLICITANTE",1);



	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.addCols(cdo.getColValue("FECHA_CREA"),0,1);
		pc.addCols(cdo.getColValue("hora_creac"),0,1);
		pc.addCols(cdo.getColValue("DESCRIPCION"),0,1);
		pc.addCols(cdo.getColValue("nombre_medico"),1,1);
        System.out.println(cdo);

	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());


pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>