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
<!-- Desarrollado por: José A. Acevedo C.         -->
<!-- Reporte: "EXPEDIENTE - EVALUACIÓN PREANESTESICA"  -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 01/06/2010                            -->
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
CommonDataObject cdoPacData, cdoTitle = new CommonDataObject();

String sql = "", sqlTitle="";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEval = request.getParameter("fecha");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

String code = request.getParameter("code");
if (appendFilter == null) appendFilter = "";
if (fechaEval== null) fechaEval = "";
if (code== null) code = "";
if (desc == null) desc = "";

//if (!fechaEval.trim().equals(""))
//appendFilter +=" and to_date(to_char(b.fecha_eval(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') =  to_date('"+fechaEval+"','dd/mm/yyyy hh12:mi am') ";

if (!code.trim().equals("") && !code.trim().equals("0"))
//appendFilter +=" and c.codigo_eval = "+code+" ";
appendFilter +=" and c.codigo_eval = "+code+" ";
sql = "select c.codigo_eval as codEval, "
+" c.cod_anestesiologo as codAnestesiologo, c.nombre_anestesiologo as nombreAnestesiologo, c.procedimiento as procedimiento, c.cirujano as cirujano, to_char(c.fecha,'dd/mm/yyyy') as fechaEvaluacion, to_char(c.fecha,'hh12:mi am') as hora "
+" from tbl_sal_eval_preanestesica c "
+" where "
+" c.pac_id = "+pacId+" and c.admision = "+noAdmision+appendFilter
+" order by c.fecha desc";

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
	String xtraSubtitle = " ";
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
		dHeader.addElement(".34");//.54
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".38");
        
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
    pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY );
	isUnifiedExp=true;}


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
		pc.addInnerTableToCols(dHeader.size());

	pc.setTableHeader(2);//create de table header (3 rows) and add header to the table


	pc.addCols(" ",0,dHeader.size());

	String groupBy = "";

	for (int i=0; i<al.size(); i++)
	{//for1
		CommonDataObject cdo = (CommonDataObject) al.get(i);

      if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codEval")))
		 { // groupBy
		    if (i != 0)
				{
				  pc.flushTableBody(true);
				  pc.addNewPage();
				}

			pc.setFont(8, 1);
			pc.addCols("Anestesiólogo:",0,2);
			pc.addCols(cdo.getColValue("nombreAnestesiologo"),0,1);
			pc.addCols("Doctor/Cirujano:   "+cdo.getColValue("cirujano"),0,3);
			pc.addCols("Procedimiento:",0,2);
			pc.addCols(cdo.getColValue("procedimiento"),0,4);

	        pc.addCols("Fecha de Evaluación:                 "+cdo.getColValue("fechaEvaluacion"),0,3);
		    pc.addCols("Hora de Eval:         "+cdo.getColValue("hora"),0,3);
		    pc.addCols(" ",0,dHeader.size());

		    pc.setFont(8, 1);
		    pc.addBorderCols("ANTECEDENTES",0,3);
		    pc.addBorderCols("SI",1);
		    pc.addBorderCols("NO",1);
		    pc.addBorderCols("OBSERVACION",1);

sql = "select b.codigo_eval as codEval, b.cod_respuesta as codRespuesta, a.id as pregunta, "
+"a.descripcion as descripcion, a.evaluable as evaluable, a.comentable as comentable, nvl(b.respuesta,'N') as respuesta, "
+" to_char(b.fecha_eval,'dd/mm/yyyy') as fechaEvaluacion, to_char(b.fecha_eval,'hh12:mi am') as hora,b.observacion as observacion "
+" , a.orden "
+" from tbl_sal_parametro a,(select * from tbl_sal_resp_ev_preanestesica where pac_id = "+pacId+" and secuencia = "+noAdmision+" and codigo_eval ="+cdo.getColValue("codEval")+") b  "
+" where "
+" a.id = b.pregunta(+) and a.status = 'A' and a.tipo = 'EPA' "
+" order by a.orden asc";

		al2 = SQLMgr.getDataList(sql);

		for (int j=0; j<al2.size(); j++)
		{//for2
			CommonDataObject cdo2 = (CommonDataObject) al2.get(j);

		    pc.setFont(8, 1);

		    if (cdo2.getColValue("evaluable").trim().equalsIgnoreCase("S"))
		    {//if 2
		  	   pc.addCols(cdo2.getColValue("descripcion"),0,3);

		       if (cdo2.getColValue("respuesta").trim().equalsIgnoreCase("S"))
		            pc.addBorderCols("S",1,1,Color.BLACK);
			    else pc.addBorderCols(" ",1,1);

			   if (cdo2.getColValue("respuesta").trim().equalsIgnoreCase("N"))
				    pc.addBorderCols(" ",1,1,Color.BLACK);
			    else pc.addBorderCols(" ",1,1);
			        pc.addCols(cdo2.getColValue("observacion"),0,1);
		    } else
		    {
	    	  pc.addCols(cdo2.getColValue("descripcion")+" :",0,2);
			  pc.addBorderCols(cdo2.getColValue("observacion"),0,5,0.5f,0.0f,0.0f,0.0f);
			  pc.addCols(" ",0,dHeader.size());
		    }//if 2
	     }//for2

	  }// groupBy

groupBy =  cdo.getColValue("codEval");

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}//for1

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}//GET
%>
