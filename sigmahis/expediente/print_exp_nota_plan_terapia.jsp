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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
//CommonDataObject cdo = new CommonDataObject();

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

if (seccion == null || seccion == "") throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tipo == null || tipo == "") throw new Exception("El tipo no es válido. Por favor intente nuevamente ou contacte el administrador!");
if (code == null || code == "") throw new Exception("El Código no es válido. Por favor intente nuevamente ou contacte el administrador!");

StringBuffer sbSql = new StringBuffer();

 sbSql.append("select codigo, to_char(fecha,'dd/mm/yyyy') fecha, to_char(fecha,'hh12:mi am') hora, evaluado_por ");
	    if(tipo.equalsIgnoreCase("NDP")) sbSql.append(" , frecuencia_nota ");
	    sbSql.append(" ,problemas, metodo, plan");
	    if(tipo.equalsIgnoreCase("PDT")) sbSql.append(", RESUMEN_EVAL, INTERPRETACION, OBJETIVOS, GRADO_METODO ");
		sbSql.append(" from tbl_sal_nota_plan_terapia ");

		if(!code.equals("0")){
		    sbSql.append(" where codigo = ");
		    sbSql.append(code);

			cdo = SQLMgr.getData(sbSql.toString());

		}else{
		    sbSql.append(" where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and secuencia = ");
			sbSql.append(noAdmision);
			sbSql.append(" and tipo = '");
			sbSql.append(tipo);
			sbSql.append("'");
			al = SQLMgr.getDataList(sbSql.toString());
		}

		//System.out.println("::::::::::::::::"+cdo);

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
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
    
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".50");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(1);

	//pc.setVAlignment(0);

	if(cdo == null){
		pc.addCols("No se ha encontrado regsitros!",0,dHeader.size(),15f);
	}else{

	       pc.setFont(9,1,Color.white);
		   pc.addCols("Fecha",1,1,Color.gray);
		   pc.addCols("Hora",1,1,Color.gray);
		   pc.addCols("Evaluador",1,1,Color.gray);
		   pc.addCols("",1,3,Color.gray);
		   pc.addCols("",1,dHeader.size(),8f);


		if(al.size() >= 1){

		   for(int a = 0; a<al.size(); a++){
			   cdo = (CommonDataObject)al.get(a);

			  pc.setNoColumnFixWidth(dHeader);
	          pc.createTable("tbl1",false,0,0.0f,594f);

			   pc.setFont(8,0);
			   pc.addCols(cdo.getColValue("fecha"),1,1);
			   pc.addCols(cdo.getColValue("hora"),1,1);
			   pc.addCols(cdo.getColValue("evaluado_por"),1,3);
			   pc.addCols("nnn",0,1);
			   pc.addCols("",0,dHeader.size(),8f);

			if(tipo.equalsIgnoreCase("PDT")){
				 pc.setFont(9,1,Color.gray);
                 pc.addCols("Resumen de la Evaluacion:",0,2);
				 pc.setFont(8,0);
                 pc.addCols(cdo.getColValue("resumen_eval"),0,4);
		    }

		    if(tipo.equalsIgnoreCase("NDP")){
				pc.setFont(9,1,Color.gray);
				 pc.addCols("Frecuencia de la Nota:",0,2);
				 pc.setFont(8,0);
				 if(cdo.getColValue("frecuencia_nota")!=null && cdo.getColValue("frecuencia_nota").equalsIgnoreCase("D")){
				     pc.addCols("DIARIA",0,4);
				 }
				 if(cdo.getColValue("frecuencia_nota")!=null && cdo.getColValue("frecuencia_nota").equalsIgnoreCase("S")){
				     pc.addCols("SEMANAL",0,4);
				 }
              } //end if tipo is NDP

			  pc.setFont(9,1,Color.gray);
			  pc.addCols("Problemas Encontrados: ",0,2);
			  pc.setFont(8,0);
			  pc.addBorderCols(cdo.getColValue("Problemas"),0,4,0.1f,0.1f,0.1f,0.0f);

		    if(tipo.equalsIgnoreCase("PDT")){
				 pc.setFont(9,1,Color.gray);
                 pc.addCols("Interpretacion:",0,2);
				 pc.setFont(8,0);
                 pc.addBorderCols(cdo.getColValue("interpretacion"),0,4,0.1f,0.1f,0.1f,0.0f);
				 pc.setFont(9,1,Color.gray);
				 pc.addCols("Objetivos: ",0,2);
				 pc.setFont(8,0);
			     pc.addBorderCols(cdo.getColValue("objetivos"),0,4,0.1f,0.1f,0.1f,0.0f);
		     }

		   pc.setFont(9,1,Color.gray);
		   pc.addCols("Metodo: ",0,2);
		   pc.setFont(8,0);
		   pc.addBorderCols(cdo.getColValue("metodo"),0,4,0.1f,0.1f,0.1f,0.0f);

		   if(tipo.equalsIgnoreCase("PDT")){
			    pc.setFont(9,1,Color.gray);
                pc.addCols("Graduacion del Metodo:",0,2);
				pc.setFont(8,0);
                pc.addBorderCols(cdo.getColValue("grado_metodo"),0,4,0.1f,0.1f,0.1f,0.0f);
		     }

		   pc.setFont(9,1,Color.gray);
		   pc.addCols("Plan: ",0,2);
		   pc.setFont(8,0);
		   pc.addBorderCols(cdo.getColValue("plan"),0,4,0.1f,0.1f,0.1f,0.0f);

		   pc.useTable("main");
	       pc.addTableToCols("tbl1",1,dHeader.size(),0,null,null,0.1f,0.1f,0.1f,0.1f);
		   pc.addCols("",0,dHeader.size(),8f);

	   }//end for

} //al.size() >= 1

		else
		if (cdo != null){
		    pc.setFont(8,0);
			   pc.addCols(cdo.getColValue("fecha"),1,1);
			   pc.addCols(cdo.getColValue("hora"),1,1);
			   pc.addCols(cdo.getColValue("evaluado_por"),1,3);
			   pc.addCols("",0,1);
			   pc.addCols("",0,dHeader.size(),8f);

			if(tipo.equalsIgnoreCase("PDT")){
				 pc.setFont(9,1,Color.gray);
                 pc.addCols("Resumen de la Evaluacion:",0,2);
				 pc.setFont(8,0);
                 pc.addCols(cdo.getColValue("resumen_eval"),0,4);
		    }

		    if(tipo.equalsIgnoreCase("NDP")){
				pc.setFont(9,1,Color.gray);
				 pc.addCols("Frecuencia de la Nota:",0,2);
				 pc.setFont(8,0);
				 if(cdo.getColValue("frecuencia_nota")!=null && cdo.getColValue("frecuencia_nota").equalsIgnoreCase("D")){
				     pc.addCols("DIARIA",0,4);
				 }
				 if(cdo.getColValue("frecuencia_nota")!=null && cdo.getColValue("frecuencia_nota").equalsIgnoreCase("S")){
				     pc.addCols("SEMANAL",0,4);
				 }
              } //end if tipo is NDP

			  pc.setFont(9,1,Color.gray);
			  pc.addCols("Problemas Encontrados: ",0,2);
			  pc.setFont(8,0);
			  pc.addBorderCols(cdo.getColValue("Problemas"),0,4,0.1f,0.1f,0.1f,0.0f);

		    if(tipo.equalsIgnoreCase("PDT")){
				 pc.setFont(9,1,Color.gray);
                 pc.addCols("Interpretacion:",0,2);
				 pc.setFont(8,0);
                 pc.addBorderCols(cdo.getColValue("interpretacion"),0,4,0.1f,0.1f,0.1f,0.0f);
				 pc.setFont(9,1,Color.gray);
				 pc.addCols("Objetivos: ",0,2);
				 pc.setFont(8,0);
			     pc.addBorderCols(cdo.getColValue("objetivos"),0,4,0.1f,0.1f,0.1f,0.0f);
		     }

		   pc.setFont(9,1,Color.gray);
		   pc.addCols("Metodo: ",0,2);
		   pc.setFont(8,0);
		   pc.addBorderCols(cdo.getColValue("metodo"),0,4,0.1f,0.1f,0.1f,0.0f);

		   if(tipo.equalsIgnoreCase("PDT")){
			    pc.setFont(9,1,Color.gray);
                pc.addCols("Graduacion del Metodo:",0,2);
				pc.setFont(8,0);
                pc.addBorderCols(cdo.getColValue("grado_metodo"),0,4,0.1f,0.1f,0.1f,0.0f);
		     }

		   pc.setFont(9,1,Color.gray);
		   pc.addCols("Plan: ",0,2);
		   pc.setFont(8,0);
		   pc.addBorderCols(cdo.getColValue("plan"),0,4,0.1f,0.1f,0.1f,0.0f);

		}// if cdo is not null








	}//end else

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>