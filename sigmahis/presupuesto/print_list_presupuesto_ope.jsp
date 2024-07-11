<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
CommonDataObject cdo = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String sql = "";
String tableName = "",sbField="";
String userName = UserDet.getUserName();
String compania = (String)session.getAttribute("_companyId");
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));
String titulo = "";

if ( fg.equals("") ) throw new Exception("No hemos encontrado un Flag Válido!");

if ( appendFilter == null ) appendFilter = "";

Hashtable iMes = new Hashtable();
iMes.put("01","ENERO");
iMes.put("02","FEBRERO");
iMes.put("03","MARZO");
iMes.put("04","ABRIL");
iMes.put("05","MAYO");
iMes.put("06","JUNIO");
iMes.put("07","JULIO");
iMes.put("08","AGOSTO");
iMes.put("09","SEPTIEMBRE");
iMes.put("10","OCTUBRE");
iMes.put("11","NOVIEMBRE");
iMes.put("12","DICIEMBRE");

if ( fg.equals("PO") ) {
	titulo = "PRESUPUESTO OPERATIVO";
    tableName=" tbl_con_ante_cuenta_anual";
	sbField = " ,nvl(a.asignacion_actual,0) asignacion,nvl(a.estado,'N') estado ";
}else if(fg.trim().equals("UPO")){
	tableName=" tbl_con_cuenta_anual";
	sbField = " ,nvl(a.asignacion,0) asignacion,'N' estado ";
}

sql = "select a.anio, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5,a.cta6, a.compania, a.unidad, a.compania_origen companiaOrigen,a.preaprobado, to_char(a.preaprobado_fecha,'dd/mm/yyyy') preaprobadoFecha, a.preaprobado_usuario preaprobadoUsuario,cg.descripcion desccuenta ,ue.descripcion descunidad,(select descripcion from tbl_con_cla_ctas  where codigo_clase = cg.tipo_Cuenta )descTipoCta, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5 cuenta"+sbField+" from "+tableName+" a,tbl_con_catalogo_gral cg ,tbl_sec_unidad_ejec ue where  ue.nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  ))  /* and ue.codigo < 100  */ and a.compania="+compania+appendFilter+" and a.cta1 =cg.cta1 and a.cta2 =cg.cta2 and a.cta3 =cg.cta3 and a.cta4 =cg.cta4 and a.cta5 =cg.cta5 and a.cta6 =cg.cta6 and a.compania_origen =cg.compania and a.unidad = ue.codigo and a.compania = ue.compania order by a.anio desc,a.unidad asc";

if ( fg.trim().equals("PI") ){
    titulo = "PRESUPUESTO DE INVERSIONES";

	sql = "select  a.anio,a.consec,a.compania, nvl(a.solicitado,0) solicitado, a.codigo_ue unidad, a.estado,ue.descripcion descunidad ,a.tipo_inv tipoInv,(select descripcion from tbl_con_tipo_inversion where compania = "+compania+" and tipo_inv =a.tipo_inv )descTipoInv from tbl_con_ante_inversion_anual a,tbl_sec_unidad_ejec ue where  a.compania="+compania+appendFilter+" and a.codigo_ue = ue.codigo and a.compania = ue.compania order by anio desc";
}

al = SQLMgr.getDataList(sql);

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PRESUPUESTO";
	String subtitle = titulo;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".20");
	dHeader.addElement(".20");
	dHeader.addElement(".20");
	dHeader.addElement(".20");
	dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setVAlignment(0);

	if ( fg.trim().equals("PO") || fg.trim().equals("UPO") ){
		pc.setFont(8,1);
		pc.addBorderCols("Año",1,1);
		pc.addBorderCols("Unidad",1,1);
		pc.addBorderCols("Cuenta",1,1);
		pc.addBorderCols("Descripción",1,1);
		pc.addBorderCols("Tipo Cta.",1,1);
		pc.addBorderCols("Asignación",1,1);
	}

	if ( fg.trim().equals("PI") ){
		pc.setFont(8,1);
		pc.addBorderCols("Año",1,1);
		pc.addBorderCols("Unidad",1,2);
		pc.addBorderCols("Tipo Inversión",1,2);
		pc.addBorderCols("Asignación",1,1);
	}

	pc.setTableHeader(2);

	for ( int i = 0; i<al.size(); i++ ){

		cdo = (CommonDataObject)al.get(i);
	    pc.setFont(8,0);

		if ( fg.trim().equals("PO") || fg.trim().equals("UPO") ){
			pc.addCols(cdo.getColValue("anio"),1,1);
			pc.addCols(cdo.getColValue("descUnidad"),0,1);
			pc.addCols(cdo.getColValue("cuenta"),0,1);
			pc.addCols(cdo.getColValue("descCuenta"),0,1);
			pc.addCols(cdo.getColValue("descTipoCta"),0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("asignacion")),2,1);
		}

		if ( fg.trim().equals("PI") ){
		    pc.addCols(cdo.getColValue("anio"),1,1);
			pc.addCols("["+cdo.getColValue("unidad")+"] - "+cdo.getColValue("descUnidad"),0,2);
			pc.addCols(cdo.getColValue("descTipoInv"),0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("solicitado")),2,1);
		}

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}//for i

	if ( al.size() == 0 ){
	   pc.addCols("***** No Hay Data *****",1,dHeader.size());
	}

	//System.out.println("::::::::::::: The Brain ::::::::::::::::::::"+al.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>