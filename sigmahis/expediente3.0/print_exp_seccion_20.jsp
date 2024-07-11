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

<!-- Desarrollado por: Oscar Hawkins      -->
<!-- Reporte: "reporte de tratamientos"-->
<!-- Reporte: ADM3087                          -->
<!-- Clínica Hospital San Fernando             -->
<!-- Fecha: 20/10/2010                         -->

<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdop  = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String codigo = request.getParameter("codigo");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fp = request.getParameter("fp");
String orden = request.getParameter("orden");
String fechaCreacion = request.getParameter("fecha_creacion");

if (appendFilter == null) appendFilter = "";
if ( desc == null ) desc = "";
if ( fp == null ) fp = "";
if ( orden == null ) orden = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);


sql.append("select get_idoneidad(c.usuario_creacion, 1) usuario_creacion, get_idoneidad(usuario_modificacion, 1)usuario_modificacion, c.fecha_creacion, to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fecha_creacion_dsp ,a.codigo as codigo, a.descripcion , c.observacion , c.nombre as nombre, to_char(c.fecha_inicio,'dd/mm/yyyy') as fecha, to_char(c.fecha_orden,'hh12:mi:ss am') as hora, c.estado_orden as estado,(select descripcion from tbl_sal_desc_estado_ord where estado=c.estado_orden) as estadodesc, c.prioridad as prioridad,(select  primer_nombre || ' ' ||segundo_nombre || ' ' || decode(apellido_de_casada, null, primer_apellido|| ' ' || segundo_apellido,primer_apellido||' '|| apellido_de_casada) as nombre_medico from tbl_adm_medico where codigo=rs.medico ) as nombre_medico,to_char(c.fecha_modificacion,'dd/mm/yyyy hh12:mi am') as fecha_modificacion,to_char(omitir_fecha,'dd/mm/yyyy')omitir_fecha,to_char(c.fecha_fin,'dd/mm/yyyy hh12:mi:ss am')fecha_fin from tbl_sal_tratamiento a, tbl_sal_detalle_orden_med c, tbl_sal_orden_medica rs where c.tipo_orden='4' and rs.secuencia=c.secuencia and c.pac_id=rs.pac_id and c.cod_tratamiento=a.codigo and rs.codigo=c.orden_med and rs.pac_id=");
sql.append(pacId);
sql.append(" and rs.secuencia=");
sql.append(noAdmision);


if (!orden.equals("") && !orden.equals("0")) {
    sql.append(" and c.orden_med in(");
    sql.append(orden);
    sql.append(")");
}

if (fp.trim().equalsIgnoreCase("exp_kardex")) {
  sql.append(" and upper(a.descripcion) like '%INHALOTERAPIA%' ");
} else if (fp.trim().equalsIgnoreCase("exp_kardex_not")) {
  sql.append(" and upper(a.descripcion) not in ('INHALOTERAPIA') ");
}

sql.append(" order by c.fecha_creacion desc ");

		al = SQLMgr.getDataList(sql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
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
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = "O/M TRATAMIENTOS";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;

	String si,no ;

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


   String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
   String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";


		Vector dHeader = new Vector();
		dHeader.addElement("30");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("30");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setVAlignment(0);

		pc.setFont(8, 1);
		pc.addBorderCols("DIAGNOSTICO/TRATAMIENTO",1);
		pc.addBorderCols("MEDICO SOLICITANTE",1);
		pc.addBorderCols("FECHA HASTA/ OMISION",1);
		pc.addBorderCols("OBSERVACION",1);
		pc.setTableHeader(2);

		String gFecha = "";

		for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!gFecha.equals(cdo.getColValue("fecha_creacion")) ) {
		  if (i != 0 ) pc.addCols(" ", 0, dHeader.size());
		  pc.setFont(9, 1);
		  
		  pc.addCols("Creac.: "+cdo.getColValue("fecha_creacion_dsp"," ")+" / "+cdo.getColValue("usuario_creacion"," "),0,2);
		  pc.addCols("Modif.: "+cdo.getColValue("fecha_modificacion"," ")+" / "+cdo.getColValue("usuario_modificacion"," "),0,2);
		}

    pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("nombre_medico"),0,1);
		pc.addCols(""+cdo.getColValue("fecha_fin")+"/"+cdo.getColValue("omitir_fecha"),0,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		gFecha = cdo.getColValue("fecha_creacion");
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>