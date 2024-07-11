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

ArrayList al,al2 = new ArrayList();
CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();

String sql = "";
String lqs = "";
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
String fp = request.getParameter("fp");
String exp = request.getParameter("exp");
String key = "";
String tipoOrden ="8";
int aTransfLastLineNo = 0;

if (appendFilter == null) appendFilter = "";
if ( id == null ) id = "0";
if ( fp == null ) fp = "";
if ( exp == null ) exp = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);
  
 if ( !id.equals("0") ){
	 appendFilter +=" and id = "+id;
 }

  sql = "select id, to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fechaOrden,codigo,escala,valor,insulina"+(exp.equals("3.0")?", nvl(tipo,0) tipo_insulina, decode(tipo,1,'RAPIDA',2,'LENTA') tipo_insulina_desc ":"")+" from tbl_sal_esquema_insulina where  pac_id="+pacId+" and admision="+noAdmision+appendFilter;
  
  if (fp.trim().equalsIgnoreCase("exp_kardex")) sql += " order by fecha desc";
		al = SQLMgr.getDataList(sql);
		
		if(desc==null) desc = ""; 

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
	String title ="EXPEDIENTE" ;
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
		dHeader.addElement(".20");
		dHeader.addElement(".30");
		dHeader.addElement(".25");
		dHeader.addElement(".25");
        
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

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	//pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

		//second row
		

	String groupByid = "";	
	pc.setVAlignment(0);
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if ( !groupByid.trim().equals(cdo.getColValue("id")) ){
			
			if ( i!= 0 ){
				pc.addCols(" ",0,dHeader.size());
			}

            pc.setFont(8, 1,Color.white);
            
            if (exp.equals("3.0")){
                pc.addBorderCols(cdo.getColValue("fechaOrden"),0,1,Color.gray);
                pc.addBorderCols("TIPO: "+cdo.getColValue("tipo_insulina_desc"),0,1,Color.gray);
                pc.addBorderCols("Obs.: "+cdo.getColValue("insulina"),0,2,Color.gray);
            }
            else {
                pc.addBorderCols("FECHA: "+cdo.getColValue("fechaOrden"),0,2,Color.gray);
                pc.addBorderCols("INSULINA: "+cdo.getColValue("insulina"),0,2,Color.gray);
            }
			
			if (exp.equals("3.0")){
                if (!cdo.getColValue("tipo_insulina","0").equals("2")) {
                    pc.setFont(8, 1);
                    pc.addBorderCols("ESCALA",1,2);
                    pc.addBorderCols("VALOR",1,2);
                }
            } else {
                pc.setFont(8, 1);
                pc.addBorderCols("ESCALA",1,2);
                pc.addBorderCols("VALOR",1,2);
            }
		}
		
        if (exp.equals("3.0")){
            if (!cdo.getColValue("tipo_insulina","0").equals("2")) {
                pc.setFont(8, 0);
                pc.addCols("["+cdo.getColValue("codigo")+"] "+cdo.getColValue("escala"),0,2);
                pc.addCols(cdo.getColValue("valor"),0,2);
            }
        } else {
            pc.setFont(8, 0);
            pc.addCols("["+cdo.getColValue("codigo")+"] "+cdo.getColValue("escala"),0,2);
            pc.addCols(cdo.getColValue("valor"),0,2);
        }
		


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
		groupByid = cdo.getColValue("id");
	}
	//}
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>