<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
Properties prop = new Properties();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String id = request.getParameter("id");
String fg = request.getParameter("fg");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
if(desc == null) desc = "";

	prop = SQLMgr.getDataProperties("select evaluacion from tbl_sal_nutricion_parenteral where id="+id+" ");

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


/*//control imgae

		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();

		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),90.0f,1);
		pc.addTable();
			*/
		Vector dHeader = new Vector();
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if (prop == null){
			pc.addCols("No encontramos registros!",1,dHeader.size());
		}else{

			pc.setFont(10,1, Color.white);
			pc.addCols("DATOS GENERALES",0,dHeader.size(), Color.gray);

			pc.setFont(7,0);
			pc.addBorderCols("Fecha "+prop.getProperty("fecha"),0,2);
			pc.addBorderCols("Hora inicio "+prop.getProperty("hora_inicio")+"     ml/Hrs",0,2);
			pc.addCols(" ",0,1);

			 pc.addBorderCols(prop.getProperty("peso")+ " (Kg)",1,1);
			 pc.addBorderCols("   X       "+prop.getProperty("volumen")+" (ml/por/día)",1,1);
			 pc.addBorderCols("   =       "+prop.getProperty("volumen_dia")+"       (ml/por/día)",1,1);
			 pc.addBorderCols("   24 Hrs = "+    prop.getProperty("volumen_total")+"      (ml/hrs)",1,1);
			 pc.addCols("",1,1);

			 pc.addBorderCols("Peso",1,1);
			 pc.addBorderCols("Volumen de Líquido NPT",1,1);
			 pc.addBorderCols("Volumen total por día",1,1);
			 pc.addBorderCols("Volumen total en 24 horas",1,1);
			 pc.addCols("",1,1);
			 pc.addCols(" ",0,dHeader.size(),5.2f);

			 pc.setFont(10,1, Color.white);
			 pc.addCols("MACRONUTRIENTES",0,dHeader.size(), Color.gray);

			 pc.setFont(7,0);
			 pc.addBorderCols("Aminoácidos:        "+prop.getProperty("macro1")+" Gms/Kg/Día",0,1);
             pc.addBorderCols("Tipo de A.A(%):        "+prop.getProperty("macro2")+" Gms/Kg/Día",0,1);
			 pc.addBorderCols("Volumen:        "+prop.getProperty("macro3")+" ml/24Hr.",0,1);
			 pc.addBorderCols("GM N:        "+prop.getProperty("macro4")+" ml/24Hr.",0,1);
			 pc.addCols("",0,1);

			 pc.addBorderCols("Aminoácidos Especiales:        "+prop.getProperty("macro5")+" Gms/Kg/Día.",0,2);
			 pc.addBorderCols("Volumen:        "+prop.getProperty("macro6")+" ml/24Hr.",0,1);
			 pc.addCols("",0,2);
			 pc.addCols("(REQUIERE APROBACION DEL SERVICIO DE SOPORTE NUTRICIONAL)",0, dHeader.size(),Color.green);
			 pc.addBorderCols("Dextrosa:       "+prop.getProperty("macro7")+" % final.",0,2);
			 pc.addCols("",0,1);
			 pc.addBorderCols("Volumen:       "+prop.getProperty("macro8")+" ml/24Hr.",0,1);
		     pc.addCols("",0,1);

			 pc.addBorderCols("Kcal:       "+prop.getProperty("macro9")+" % final.",0,1);
			 pc.addBorderCols("Lípidos 10%  20%      "+prop.getProperty("macro10")+" Gm/Kg/Día",0,1);
			 pc.addBorderCols(prop.getProperty("macro11"),0,1);
			 pc.addBorderCols("Volumen:       "+prop.getProperty("macro12")+" ml/24Hr.",0,1);
			 pc.addBorderCols("Kcal:       "+prop.getProperty("macro13"),0,1);
			 pc.addCols(" ",0,dHeader.size(),5.2f);

			 pc.setFont(10,1, Color.white);
			 pc.addCols("ELECTROLITOS(POR DIA)",0,dHeader.size(), Color.gray);

			 pc.setFont(7,0);
             pc.addBorderCols("NaCl:       ",0,1);
			 pc.addBorderCols(prop.getProperty("electro1"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro2"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("Insulina(Reg)",0,1);
			 pc.addBorderCols(prop.getProperty("electro6"),0,1);
			 pc.addBorderCols("U/día",0,1);
			 pc.addCols("",0,2);

			 pc.addBorderCols("Acetato Na:       ",0,1);
			 pc.addBorderCols(prop.getProperty("electro4"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro5"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("Gluconato de Calcio",0,1);
			 pc.addBorderCols(prop.getProperty("electro3"),0,1);
			 pc.addBorderCols(" ml/kg",0,1);
			 pc.addCols("",0,2);

			 pc.addBorderCols("Fosfato Na:       ",0,1);
			 pc.addBorderCols(prop.getProperty("electro7"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro8"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("Heparina",0,1);
			 pc.addBorderCols(prop.getProperty("electro9"),0,1);
			 pc.addBorderCols("U/día",0,1);
			 pc.addCols("",0,2);

			 pc.addBorderCols("KCL:       ",0,1);
			 pc.addBorderCols(prop.getProperty("electro10"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro11"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("Acetato K",0,1);
			 pc.addBorderCols(prop.getProperty("electro13"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro14"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("Fosfato K",0,1);
			 pc.addBorderCols(prop.getProperty("electro15"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro16"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("MgSO",0,1);
			 pc.addBorderCols(prop.getProperty("electro17"),0,1);
			 pc.addBorderCols(" mEq/kg",0,1);
			 pc.addBorderCols(prop.getProperty("electro18"),0,1);
			 pc.addBorderCols(" mEq/día",0,1);

			 pc.addBorderCols("Elementos Trazas:",0,1);
			 pc.addBorderCols(prop.getProperty("electro19"),0,1);
			 pc.addBorderCols("ml/24Hrs",0,1);
			 pc.addBorderCols("Zn Adicional:",0,1);
			 pc.addBorderCols(prop.getProperty("electro21")+ "        (mcg/día)",0,1);

			 pc.addBorderCols("ultivitaminas Pediátricas: ",0,1);

			 String ulvit1="",ulvit2="",ulvit3="";

			 if(prop.getProperty("electro20").equals("S")) ulvit1 = "1.5 ml si es menor de 1 kg";
			 if(prop.getProperty("electro22").equals("S")) ulvit2 = "3.25 ml si es menor de 1 - 3 kg";
			 if(prop.getProperty("electro23").equals("S")) ulvit3 = "5 ml si es menor de 3 kg";

			 pc.addBorderCols(ulvit1,0,1);
			 pc.addBorderCols(ulvit2,0,1);
		     pc.addBorderCols(ulvit3,0,1);
		     pc.addBorderCols("",0,1);

			 pc.addCols(" ",0,dHeader.size(),5.2f);
			 pc.addCols("Otros:",0,dHeader.size());
		     pc.addBorderCols(prop.getProperty("electro12"),0,dHeader.size());

		} //end else


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>