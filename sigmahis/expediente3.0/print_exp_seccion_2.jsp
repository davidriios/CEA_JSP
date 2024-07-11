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
Reporte sal10050
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
ArrayList al2= new ArrayList();

CommonDataObject cdo1, cdoPacData, cdoTitle = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEscala = request.getParameter("fechaEscala");
String id = request.getParameter("id");
String cds = request.getParameter("cds");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String showHeader = request.getParameter("showHeader");
if (showHeader == null) showHeader = "Y";

String customFirstTitle = request.getParameter("custom_first_title");
if (customFirstTitle == null) customFirstTitle = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

System.out.println("................................................. >>> "+request.getParameter("showHeader"));

sql="SELECT b.admision, a.codigo AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion, decode(a.grupo,1,'PATOLOGICO','NO PATOLOGICO') as grupo_desc, a.grupo, get_idoneidad(usuario_creacion, 1) usuario_creacion, get_idoneidad(usuario_modificacion, 1)usuario_modificacion, to_char(FECHA_CREACION, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(FECHA_MODIFICACION , 'dd/mm/yyyy hh12:mi am') fecha_modificacion from TBL_SAL_DIAGNOSTICO_PERSONAL a, TBL_SAL_ANTECEDENTE_PERSONAL b where a.CODIGO = b.ANTECEDENTE AND b.PAC_ID = "+pacId+" /*and (b.admision = "+noAdmision+" or b.admision is null)*/ order by b.admision, a.grupo, a.orden ";

al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

if(desc == null) desc = "";

	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
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

	float width = 82 * 8.5f;//612
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
	String subtitle = customFirstTitle;
	String xtraSubtitle = desc;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	String si = "", no = "";
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	Vector dHeader = new Vector();
		dHeader.addElement(".30");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".40");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
        
		PdfCreator pc=null;

		boolean isUnifiedExp=false;

	//------------------------------------------------------------------------------------
      pc = (PdfCreator) session.getAttribute("printExpedienteUnico");

if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		
        if (showHeader.equals("Y")){
            pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
        } else {
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(desc,1,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
        }
        
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

		//second row
		pc.setFont(8,1);
		pc.addBorderCols("DIAGNOSTICO",1,1);
		pc.addBorderCols("SI",1,1);
		pc.addBorderCols("NO",1,1);
		pc.addBorderCols("OBSERVACION",1,1);
		pc.addBorderCols("CREAC.",1,1);
		pc.addBorderCols("MODIF.",1,1);

	pc.setTableHeader(1);//create de table header (3 rows) and add header to the table

	pc.setVAlignment(0);
	pc.setFont(7,0);
    
    String group = "", admision = "";
    
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

	   if(cdo.getColValue("valor").trim().equals("S")){ si = "x"; no = "";} else{si=""; no = "x";}
       
       if(!admision.equals(cdo.getColValue("admision"))){
        if (i != 0) pc.addCols(" ",0,dHeader.size());
        pc.addCols("ADM # "+cdo.getColValue("admision"," "),0,dHeader.size(),Color.gray);
       } 
       
       if(!group.equals(cdo.getColValue("grupo"))){
        pc.addCols("    "+cdo.getColValue("grupo_desc"," "),0,dHeader.size(),Color.lightGray);
       } 

	   pc.addCols("    "+cdo.getColValue("descripcion"," "),0,1);
	   pc.addCols("    "+si,1,1);
	   pc.addCols("    "+no,1,1);
	   pc.addCols("    "+cdo.getColValue("observacion"," "),0,1);
	   pc.addCols(cdo.getColValue("fecha_creacion"," ")+" / "+cdo.getColValue("usuario_creacion"," "),0,1);
	   pc.addCols(cdo.getColValue("fecha_modificacion"," ")+" / "+cdo.getColValue("usuario_modificacion"," "),0,1);

	   pc.addBorderCols("",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
       
       admision = cdo.getColValue("admision");
       group = cdo.getColValue("grupo");
	}

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}//GET
%>