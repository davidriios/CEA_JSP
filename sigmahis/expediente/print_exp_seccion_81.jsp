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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al,al2,al3 = new ArrayList();
CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();
CommonDataObject cdo  = new CommonDataObject();

String sql = "";
String change = "";
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String groupId = request.getParameter("groupId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String key = "";
String code = request.getParameter("code");
int aTransfLastLineNo = 0;

if (appendFilter == null) appendFilter = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);

 sql="select  a.codigo_eval, a.diagnostico, coalesce(g.observacion,g.nombre) descDiagnostico, a.observacion observDiag from tbl_sal_eval_nutric_diag a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.codigo_eval = "+code+"  order by a.codigo_eval desc";

al = SQLMgr.getDataList(sql);


sql="select nvl(a.codigo,0) codigo,a.codigo_eval, g.id cod_guia,g.nombre,  a.observacion,a.cds,decode(nvl(a.aplicar,'N'),'S','SI','N','NO') aplicar  from tbl_sal_eval_nutric_plan a, tbl_sal_guia g where a.cod_guia(+) = g.id and a.codigo_eval(+) = "+code+" and g.tipo ='PA'  order by a.codigo asc";
al3 = SQLMgr.getDataList(sql);


if(desc==null) desc = "";

if(!code.trim().equals("0")){
	sql= " select nutric.codigo as codigo, to_char(nutric.fecha,'dd/mm/yyyy') as fecha, "
	+" nutric.eval_inicial, nutric.recomendacion, "
	+" nutric.observacion, nutric.evaluado_por, decode(clasificacion,1,'RIESGO DE DESNUTRICION',2,'DESNUTRICION', 3,'BAJO PESO',4,'NORMAL',5,'SOBREPESO',6,'OBESIDAD',7,'OBESIDAD MÓRBIDA') clasificacion,peso,talla,imc, decode(alimentacion, 1,'ADECUADO',2,'INADECUADO', 3,'EXCESIVO',4,'DEFICIENTE') alimentacion,actividad,patron,interaccion,terapia_nutricional,patron_alimentario "
	+" from tbl_sal_evaluacion_nutricion nutric "
	+" where "
	+" nutric.codigo = "+code
	+" order by to_date(to_char(nutric.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc ";

	cdo = SQLMgr.getData(sql);

}

if ( cdo == null ) cdo = new CommonDataObject();

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
	String title = "EXPEDIENTE" ;
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


		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

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


	    pc.setNoColumnFixWidth(dHeader);
	    pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(8,1,Color.white);
		pc.addCols("DATOS GENERALES",0,dHeader.size(),Color.gray);

		pc.setFont(8,0);
		pc.addCols("Fecha: "+(cdo.getColValue("fecha")==null?"":cdo.getColValue("fecha")),0,2);
		pc.addCols("Peso(Kg): "+(cdo.getColValue("peso")==null?"":cdo.getColValue("peso")),0,1);
		pc.addCols("Tala(M.): "+(cdo.getColValue("talla")==null?"":cdo.getColValue("talla")),0,2);
		pc.addCols("IMC: "+(cdo.getColValue("imc")==null?"":cdo.getColValue("imc")),0,6);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Evaluador: ",0,2);
		pc.addCols(cdo.getColValue("evaluado_por"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Clasificación Nutricional: ",0,2);
		pc.addCols(cdo.getColValue("clasificacion"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Patrón Alimentario Actual: ",0,2);
		pc.addCols(cdo.getColValue("alimentacion"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Actividad Física: ",0,2);
		pc.addCols(cdo.getColValue("actividad"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Patrón Usual de Alimentación: ",0,2);
		pc.addCols(cdo.getColValue("patron_alimentario"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Interacción Fármaco - Nutrientes:",0,2);
		pc.addCols(cdo.getColValue("interaccion"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Recomendaciones:",0,2);
		pc.addCols(cdo.getColValue("recomendacion"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Terapia Nutricional Ordenada:",0,2);
		pc.addCols(cdo.getColValue("terapia_nutricional"),0,9);
		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());

		pc.addCols("Observaciones:",0,2);
		pc.addCols(cdo.getColValue("observacion"),0,9);

		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8,1,Color.white);
		pc.addCols("DIAGNOSTICOS",0,dHeader.size(),Color.gray);

		pc.setFont(8,1);
		pc.addBorderCols("Diagnóstico",1,3);
		pc.addBorderCols("Descripción",1,4);
		pc.addBorderCols("Observación",1,4);

		if ( al.size() == 0 ) {
			pc.addCols(" No hemos encontrado diagnósticos!",1,dHeader.size());
		}else{
			for ( int d = 1; d<=al.size(); d++){
				cdo1 = (CommonDataObject)al.get(d-1);

				pc.addCols(cdo1.getColValue("diagnostico"),0,3);
				pc.addCols(cdo1.getColValue("descdiagnostico"),0,4);
				pc.addCols(cdo1.getColValue("observDiag"),0,4);
			}//for d
		} //else

		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8,1,Color.white);
		pc.addCols("PLAN DE ACCION",0,dHeader.size(),Color.gray);

		pc.setFont(8,1);
		pc.addBorderCols("Descripción",1,3);
		pc.addBorderCols("SI",1,1);
		pc.addBorderCols("Observación",1,7);

		if ( al3.size() == 0 ) {
			pc.addCols(" No hemos encontrado Acciones",1,dHeader.size());
		}else{
			for ( int a = 1; a<=al3.size(); a++){
				cdo1 = (CommonDataObject)al3.get(a-1);

				pc.addCols(cdo1.getColValue("nombre"),0,3);
				pc.addCols(cdo1.getColValue("aplicar"),0,1);
				pc.addCols(cdo1.getColValue("observacion"),0,7);
			}//for d
		} //else







	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>