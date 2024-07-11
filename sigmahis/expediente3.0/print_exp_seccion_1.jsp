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

ArrayList al = new ArrayList();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String exp = request.getParameter("exp");

String customFirstTitle = request.getParameter("custom_first_title");
if (customFirstTitle == null) customFirstTitle = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if(desc == null) desc = "";
if(exp == null) exp = "";

sql = "select to_char(FECHA,'dd/mm/yyyy') as FECHA, to_char(HORA, 'hh12:mi:ss am') as HORA, OBSERVACION, DOLENCIA_PRINCIPAL, MOTIVO_HOSPITALIZACION, ALERGICO_A, get_idoneidad(usuario_creacion, 1) usuario_creacion, get_idoneidad(usuario_modificacion, 1) usuario_modificacion, to_char(FECHA_modificacion,'dd/mm/yyyy') as FECHA_modificacion, to_char(FECHA_modificacion, 'hh12:mi:ss am') as hora_modificacion from TBL_SAL_PADECIMIENTO_ADMISION where pac_id="+pacId+" and secuencia="+noAdmision;

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String subtitle = customFirstTitle;
	String xtraSubtitle = desc; //"DEL "+fechaini+" AL "+fechafin;
	
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
    cdoPacData.addColValue("is_landscape",""+isLandscape);
	}
	PdfCreator pc=null;
		
		boolean isUnifiedExp=false;
	
	//------------------------------------------------------------------------------------
      pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("30"); 
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("30");
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		String showHeader = request.getParameter("showHeader");
        if (showHeader == null) showHeader = "Y";
        if (showHeader.equals("Y")){
            pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
        } else {
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(desc,1,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
        }

		pc.setTableHeader(1);
		
		if (request.getParameter("is_tmp") != null && showHeader.equals("Y")) {
            issi.admin.Properties propL = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_cuestionarios where pac_id = "+pacId+" and admision = "+noAdmision+")");
            if (propL == null) propL = new issi.admin.Properties();
            
            CommonDataObject cdoL = SQLMgr.getData("select formulario from tbl_sal_nota_eval_enf_urg where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo_nota = 'NEEU'");
            if (cdoL == null) cdoL = new CommonDataObject();
            
            pc.setFont(11,1);
            pc.addCols("PACIENTE VULNERABLE: "+(!cdoL.getColValue("formulario"," ").trim().equals("") && !cdoL.getColValue("formulario"," ").trim().equals("15")?"    SI":"    NO"),0,dHeader.size());
            
            CommonDataObject cdoE = SQLMgr.getData("select edad, edad_mes from vw_adm_paciente where pac_id = "+pacId);
            if (cdoE == null) cdoE = new CommonDataObject();
            
            pc.setFont(11,0);
            if (Integer.parseInt(cdoE.getColValue("edad","0")) == 0 && Integer.parseInt(cdoE.getColValue("edad_mes","0")) <= 3) {
                pc.addCols("  -> PACIENTE NEONATO",0,dHeader.size());
            }
            
            ArrayList alL = SQLMgr.getDataList("select descripcion from tbl_sal_riesgo_vulnerab where codigo in("+cdoL.getColValue("formulario","-1")+")");
            for (int l = 0; l<alL.size(); l++) {
                pc.setFont(11,0);
                cdoL = (CommonDataObject) alL.get(l);
                pc.addCols("     -> "+cdoL.getColValue("descripcion"," "),0,dHeader.size());
            }
            pc.setFont(11,1);
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("VOLUNDAD MEDICA ANTICIPADA: "+(propL.getProperty("voluntades_anticipadas")!=null&&propL.getProperty("voluntades_anticipadas").equals("S")?"    SI":"    NO"),0,dHeader.size());
            pc.addCols("RCP: "+(propL.getProperty("no_no0")!=null&&propL.getProperty("no_no0").equals("0")?"    NO":"    SI"),0,dHeader.size());
                       
            pc.addCols(" ",0,dHeader.size());
        }

		pc.setFont(8, 1);
		pc.addCols("Fecha Creac.: "+(cdo.getColValue("FECHA")==null?"":cdo.getColValue("FECHA")), 0, 1,15.2f);
		pc.addCols("Hora: "+(cdo.getColValue("HORA")==null?"":cdo.getColValue("HORA")), 0, 1,15.2f);
		pc.addCols("Usuario: "+cdo.getColValue("usuario_creacion"," "),1,2);
		
		if (!cdo.getColValue("usuario_modificacion"," ").trim().equals("")) {
			pc.addCols("Fecha Modif.: "+cdo.getColValue("FECHA_modificacion"," "), 0, 1,15.2f);
			pc.addCols("Hora: "+cdo.getColValue("hora_modificacion"," "), 0, 1,15.2f);
			pc.addCols("Usuario: "+cdo.getColValue("usuario_modificacion"," "),1,2);
		}

		pc.addCols("",0,dHeader.size(), 10.2f);
		
		pc.setFont(8, 1,Color.white);
		pc.addCols("Dolencia Principal (Motivo de la consulta)", 0, dHeader.size(),Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("DOLENCIA_PRINCIPAL"), 0, dHeader.size());
		
		pc.addCols("",0,dHeader.size(), 20.2f);
		
		pc.setFont(8, 1,Color.white);
		pc.addCols("Historia de la Enfermedad Actual (inicio, síntomas, asistencia médica, hospitalización)", 0, dHeader.size(),Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("observacion"), 0, dHeader.size());
		
        if (exp.equals("")){
		pc.addCols("",0,dHeader.size(), 20.2f);
		
		pc.setFont(8, 1,Color.white);
		pc.addCols("Motivo de la Hospitalización", 0, dHeader.size(),Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("MOTIVO_HOSPITALIZACION"), 0, dHeader.size());
        
        pc.addCols("",0,dHeader.size(), 20.2f);
		
		pc.setFont(8, 1,Color.white);
		pc.addCols("Alérgico a", 0, dHeader.size(),Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("ALERGICO_A"), 0, dHeader.size());
        }
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>