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
REPORTE:  NOTA DE TERAPISTAS
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
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();

CommonDataObject cdo1, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String fechaProt = request.getParameter("fechaProt");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);



	// NOTAS.
	sql = "select a.pac_id, a.admision,  b.descripcion as tipo_terapia,  a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy') fecha_nota, a.fecha_creacion, a.nota_terapia     from tbl_SAL_NOTA_TERAPIA a, tbl_sal_tipo_terapia b     where a.codigo_terapia = b.codigo  and a.pac_id = "+pacId+"  and a.admision = "+noAdmision+"    order by fecha_creacion, usuario_creacion";
	al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	String subtitle = "NOTAS DE TERAPISTAS";
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
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".10");


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


			pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body

		pc.setFont(fontSize, 1);

//		pc.addBorderCols(" ",1,dHeader.size());
//		pc.addBorderCols(" ",1,dHeader.size());


if(al.size()<1){
	pc.addCols("No existen registros",1,dHeader.size());
}else{


	String groupBy = "";
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


		 		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("tipo_terapia")+"-"+cdo.getColValue("fecha_nota")+"-"+cdo.getColValue("usuario_creacion")))
				  { // groupBy
					   /* if (i != 0)
					     {
						      pc.flushTableBody(true);
						      pc.addNewPage();
					     }*/

						   pc.setFont(8, 1);
						   pc.addBorderCols("TIPO DE TERAPIA:    "+cdo.getColValue("tipo_terapia"),0,2,0.5f,0.5f,0.5f,0.5f,cHeight);
						   pc.addBorderCols("FECHA:   "+cdo.getColValue("fecha_nota"),1,1,0.5f,0.5f,0.5f,0.5f,cHeight);
						   pc.addBorderCols("REGISTRADO POR:   "+cdo.getColValue("usuario_creacion"),1,2,0.5f,0.5f,0.5f,0.5f,cHeight);

							pc.setFont(7, 0);
							pc.addBorderCols("NOTA DEL TERAPISTA",0,5,0.5f,0.0f,0.0f,0.0f);

				  }// groupBy

		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("nota_terapia"),0,5,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(" ",0,5,0.0f,0.0f,0.0f,0.0f);

		groupBy = cdo.getColValue("tipo_terapia")+"-"+cdo.getColValue("fecha_nota")+"-"+cdo.getColValue("usuario_creacion");

	}

	pc.addCols(" ",1,dHeader.size());
				//pc.addInnerTableCols("Nombre Medico:",0,1);
			//pc.addInnerTableCols(cdo1.getColValue("nombre_medico"),0,1);

	//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	
}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>