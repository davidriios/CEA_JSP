<%@ page errorPage="../error.jsp" %>
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

ArrayList  alIC,al = new ArrayList();
CommonDataObject cdoIC, cdoPacData, cdo  = new CommonDataObject();

String sql_1 = "", sql2 = "", sql3="";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
if(desc == null) desc = "";
String all = "";

/*if ( ic_id.equals("00") || ic_id.equals("0") || ic_id.equals("")){
	all = "";
}else{all = " and e.codigo="+ic_id;}*/


sql_1 = "select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido|| decode(AM.segundo_apellido, null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F', decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as nombremedico, esp.descripcion as descripcion, a.codigo as codIC, a.medico as medico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.observacion as observacion, nvl(a.cod_especialidad,' ') as codespecialidad, a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as fechamodificacion , to_char(a.HORA,'hh12:mi:ss am') as hora from TBL_SAL_INTERCONSULTOR_ESPEC a, tbl_adm_medico AM, tbl_adm_especialidad_medica esp Where a.pac_id(+)="+pacId+" and a.secuencia="+noAdmision+" and a.medico=AM.codigo(+) and esp.codigo(+)=a.cod_especialidad and (a.pac_id, a.secuencia) in (select sd.pac_id, sd.secuencia from tbl_sal_diagnostico_inter_esp sd)";

alIC = SQLMgr.getDataList(sql_1);

/*sql2 = "select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido|| decode(AM.segundo_apellido, null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F', decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as nombremedico, esp.descripcion as descripcion, a.medico as medico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.observacion as observacion, nvl(a.cod_especialidad,' ') as codespecialidad, a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as fechamodificacion , to_char(a.HORA,'hh12:mi:ss am') as hora from TBL_SAL_INTERCONSULTOR_ESPEC a, tbl_adm_medico AM, tbl_adm_especialidad_medica esp Where a.pac_id(+)="+pacId+" and a.secuencia="+noAdmision+" and a.medico=AM.codigo(+) and esp.codigo(+)=a.cod_especialidad and (a.pac_id, a.secuencia) in (select sd.pac_id, sd.secuencia from tbl_sal_diagnostico_inter_esp sd)";

intCon = (Interconsulta) sbb.getSingleRowBean(ConMgr.getConnection(), sql2, Interconsulta.class);*/



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
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

	float width = 82 * 8.5f;//612
	float height = 62 * 14f;//792
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
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 5;
	float cHeight = 90.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}



		Vector dHeader = new Vector();
		dHeader.addElement("16.70");
		dHeader.addElement("16.70");
		dHeader.addElement("16.70");
		dHeader.addElement("16.70");
		dHeader.addElement("16.70");
		dHeader.addElement("16.70");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(alIC.size()<1){
			pc.addCols("No hemmos encontrado registros!",1, dHeader.size());
		}else{

		for(int i = 0; i<alIC.size(); i++){
		   cdoIC = (CommonDataObject)alIC.get(i);

		pc.setFont(9,1);
		pc.addBorderCols("No.: "+(1+i),0,dHeader.size(),0f,1.5f,0f,0f,15.2f);
		pc.setFont(9,1,Color.white);
		pc.addBorderCols("Registro Médico",0,1,Color.gray);
		pc.addBorderCols("Nombre Médico",0,3,Color.gray);
		pc.addBorderCols("Especialidad",1,2,Color.gray);
		pc.setFont(7,0);
		pc.addCols(cdoIC.getColValue("medico"),0,1);
		pc.addCols(cdoIC.getColValue("nombremedico"),0,3);
		pc.addCols(cdoIC.getColValue("descripcion"),0,2);


		  sql3="select COD_INTERCONSULTA CODINTERCONSULTA, DIAGNOSTICO, nvl(e.OBSERVACION,' ') as OBSERVACION, CODIGO from  TBL_SAL_DIAGNOSTICO_INTER_ESP e where pac_id="+pacId+"and secuencia="+noAdmision+" and e.cod_interconsulta="+cdoIC.getColValue("codigo")+" order by codigo asc";

        al = SQLMgr.getDataList(sql3);

		pc.addCols("",0,dHeader.size(),7.2f);
		pc.setFont(9,1,Color.white);
		pc.addBorderCols("Registrado por",0,1,Color.gray);
		pc.addBorderCols("Registrado el",0,1,Color.gray);
		pc.addBorderCols("Modificado por",0,1,Color.gray);
		pc.addBorderCols("Modificado el",0,1,Color.gray);
		pc.addBorderCols("",0,2,Color.gray);
		pc.setFont(7,0);

		pc.addCols(cdoIC.getColValue("usuariocreacion"),0,1);
		pc.addCols(cdoIC.getColValue("fechacreacion"),0,1);
	    pc.addCols(cdoIC.getColValue("usuariomodificacion"),0,1);
	    pc.addCols(cdoIC.getColValue("fechamodificacion"),0,1);
		pc.addCols("",0,2);

		pc.addCols("",0,dHeader.size(),10.2f);
		pc.setFont(9,1);
		pc.addCols("Notas de la Interconsulta",0,dHeader.size());
		pc.addCols("",0,dHeader.size(),10.2f);
		pc.setFont(7,0);

		for (int j = 0; j<al.size(); j++){
			cdo = (CommonDataObject)al.get(j);
			pc.addCols((1+j)+". "+cdo.getColValue("OBSERVACION"),0,dHeader.size());
		} //end for 2
		pc.addCols("",0,dHeader.size(),10.2f);
	} // end for 1

}//end else

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>