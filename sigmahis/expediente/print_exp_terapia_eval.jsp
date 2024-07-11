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
REPORTE:  RESUMEN CLINICO
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
ArrayList al3 = new ArrayList();
ArrayList alParam = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();
CommonDataObject cdo3 = new CommonDataObject();
CommonDataObject cdoParam = new CommonDataObject();

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String seccion = request.getParameter("seccion");
String tipo = request.getParameter("tipo");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if(tipo == null) throw new Exception("El tipo no es válido. Por favor intente nuevamente ou contacte el administrador!");

// ----------------------------------- query para fecha, evaluador, motivo... ------------------------------------------ //
StringBuffer sbSql1 = new StringBuffer();
sbSql1.append("select codigo, motivo_terapia, nivel_funcional_previo, fecha_creacion fc,fecha_modificacion fm, usuario_modificacion um,usuario_creacion uc, to_char(fecha,'dd/mm/yyyy') fecha, to_char(fecha,'hh12:mi:ss am') hora, usuario_creacion, decode(nivel_terapia,'INI','INICIAL', 'INT','INTERMEDIO','ALT','ALTA','INICIAL') nivelterapia, problemas, metas_recomen from tbl_sal_terapia_eval where codigo = ");
sbSql1.append(code);
sbSql1.append(" and tipo = '");
sbSql1.append(tipo);
sbSql1.append("' and pac_id = ");
sbSql1.append(pacId);
sbSql1.append(" and admision = ");
sbSql1.append(noAdmision);

cdo = SQLMgr.getData(sbSql1.toString());

String evaluacion = "";
if(tipo.equals("ETO")){
    evaluacion = "'I','INDEPENDIENTE','MA','MODERADA ASISTENCIA','D','DEPENDIENTE','S','SUPERVISAADO','NE','NO EVALUADO','NA','NO APLICA'";
}else{
	if(tipo.equals("ETF")){
		evaluacion = "'C','COMPLETO','L','LIMITADO','S','SI','N','NO'";
	}
}


// ----------------------------------- query para los parametros -------------------------------------------------- //
StringBuffer sbSql2 = new StringBuffer();
		sbSql2.append("select id as paramPadre, 0 as paramDet, descripcion as paramDesc, evaluable, comentable, eval_values, 0 as fromEval, '' as observacion, id as paramID, 0 as evalDetId, '' as eval, 0 as paramDetId from tbl_Sal_parametro where status = 'A' and tipo = '");
		sbSql2.append(tipo);
		sbSql2.append("' union all select a.param_id, a.id, a.descripcion, a.evaluable, a.comentable, a.eval_values, e.codigo_eval, e.observacion, e.param_id, e.codigo,decode(e.evaluacion, ");
		sbSql2.append(evaluacion);
		sbSql2.append(" ), e.param_det_id  from tbl_Sal_parametro_Det a, tbl_sal_parametro b, tbl_sal_terapia_eval_det e where a.param_id = b.id and e.codigo_eval = ");
		sbSql2.append(code);
		sbSql2.append(" and a.status ='A' and b.status = 'A' and b.tipo = '");
		sbSql2.append(tipo);
		sbSql2.append("' and e.param_det_id = a.id order by 1,2");

		al = SQLMgr.getDataList(sbSql2.toString());



if (request.getMethod().equalsIgnoreCase("GET"))
{

	if(desc == null) desc = "";

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}
    
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".50");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(2);
		//second row
		pc.setVAlignment(0);

		if(tipo.equals("ETO")){
		    pc.setFont(9,1,Color.white);
			pc.addCols("Actividad de la vida diaria",0,dHeader.size(),Color.gray);
			pc.addCols("",0,dHeader.size(),9f);
        }else{
			if(tipo.equals("ETF")){
			   pc.setFont(9,1,Color.white);
			   pc.addCols("Nivel de la terapia:",0,2,Color.gray);
			   pc.addCols(cdo.getColValue("nivelterapia"),0,2,Color.gray);
			   pc.addCols("",0,4,Color.gray);
			   pc.addCols("",0,dHeader.size(),9f);
			}
		}

			pc.setFont(8,0);
			pc.addCols("Fecha - Hora:",0,1);
			pc.addBorderCols(cdo.getColValue("fecha")+ " "+cdo.getColValue("hora"),0,5,0.0f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			pc.addCols("Evaluado por:",0,1);
			pc.addBorderCols(cdo.getColValue("uc"),0,5,0.0f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			pc.addCols("Motivo de Intervencion de Terapia Ocupacional:",0,3);
			pc.addBorderCols(cdo.getColValue("motivo_terapia"),0,3,0.0f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

		if(tipo.equals("ETO")){
			pc.addCols("Nivel funcional previo a la hospitalizacion:",0,3);
			pc.addBorderCols(cdo.getColValue("nivel_funcional_previo"),0,3,0.0f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),15f);
		}

			pc.setFont(9,1,Color.white);
			pc.addCols("Evaluaciones",0,dHeader.size(),Color.gray);
			pc.addCols("",0,dHeader.size(),6f);




		if(al.size() < 1){
			pc.addCols("No hay registros!",1,dHeader.size());
		}
		else{

		String paramPadre = "";

		    pc.setFont(7,1);
		    pc.addBorderCols("Contraindicaciones/Precauciones",0,3,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("Evaluacion",1,2,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("Comentarios",1,1,0.1f,0.1f,0.1f,0.1f);

		for(int i = 0; i<al.size();i++){

			cdoParam = (CommonDataObject) al.get(i);

			if(paramPadre.trim().equals(cdoParam.getColValue("paramPadre").trim())){

			   pc.setFont(7,0);
			   if(cdoParam.getColValue("evaluable").equalsIgnoreCase("S")){
			      pc.addBorderCols(cdoParam.getColValue("paramDesc"),0,3,0.1f,0.1f,0.1f,0.1f);
			      pc.addBorderCols(cdoParam.getColValue("eval"),0,2,0.1f,0.1f,0.1f,0.1f);
			      pc.addBorderCols(cdoParam.getColValue("observacion"),0,1,0.1f,0.1f,0.1f,0.1f);
			   }else{
				  pc.addBorderCols(cdoParam.getColValue("paramDesc"),0,3,0.0f,0.0f,0.0f,0.0f);
			      //pc.addBorderCols(cdoParam.getColValue("eval"),0,2,0.1f,0.1f,0.1f,0.1f);
			      //pc.addBorderCols(cdoParam.getColValue("observacion"),0,1,0.1f,0.1f,0.1f,0.1f);
			   }
			}else{
			   pc.setFont(7,1);

			   pc.addCols("",0,dHeader.size(),7f);

			    if(cdoParam.getColValue("evaluable").equalsIgnoreCase("S")){
			      pc.addBorderCols(cdoParam.getColValue("paramDesc"),0,3,0.1f,0.1f,0.1f,0.1f);
			      pc.addBorderCols(cdoParam.getColValue("eval"),0,2,0.1f,0.1f,0.1f,0.1f);
			      pc.addBorderCols(cdoParam.getColValue("observacion"),0,1,0.1f,0.1f,0.1f,0.1f);
			   }else{
				  pc.addBorderCols(cdoParam.getColValue("paramDesc"),0,6,0.0f,0.0f,0.0f,0.0f);
			      //pc.addBorderCols(cdoParam.getColValue("eval"),0,2,0.1f,0.1f,0.1f,0.1f);
			     // pc.addBorderCols(cdoParam.getColValue("observacion"),0,1,0.1f,0.1f,0.1f,0.1f);
			   }
			}

		  paramPadre = cdoParam.getColValue("paramPadre");

		} //for

		}//end else

		if(tipo.equals("ETF")){
			   pc.addCols("",0,dHeader.size(),10f);
			   pc.setFont(7,0);
			   pc.addBorderCols("Problemas: ",0,2,0.1f,0.1f,0.1f,0.1f);
			   pc.addBorderCols(cdo.getColValue("problemas"),0,4,0.1f,0.1f,0.1f,0.1f);
			   pc.addBorderCols("Metas/Recomendaciones: ",0,2,0.1f,0.1f,0.1f,0.1f);
			   pc.addBorderCols(cdo.getColValue("metas_recomen"),0,4,0.1f,0.1f,0.1f,0.1f);

		}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>