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
String change = "";
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String groupId = request.getParameter("groupId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fDate = request.getParameter("f_date");
String tDate = request.getParameter("t_date");
String key = "";
String refType = request.getParameter("refType");
int aTransfLastLineNo = 0;
String paramRespDet = "N";
try {paramRespDet =java.util.ResourceBundle.getBundle("issi").getString("auto.pram.resp");}catch(Exception e){ paramRespDet = "N";}

if (appendFilter == null) appendFilter = "";
if (groupId == null ) groupId = "0";
if (refType == null ) refType = "RES";
if (fDate == null ) fDate = "";
if (tDate == null ) tDate = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);

	sql= "select distinct  a.grupo_id, to_char(a.fecha,'dd/mm/yyyy hh12:mi am') fecha from tbl_sal_evolucion_hemodinamico a  where a.pac_id = "+pacId+" and a.admision = "+noAdmision+"  and  a.ref_type(+) ='"+refType+"' order by a.grupo_id desc";
 //al2 = SQLMgr.getDataList(sql);

	sql = "select a.usuario_creacion usuario";
    
    if (!groupId.trim().equals("0")) {
        sql += ", nvl(a.grupo_id, "+groupId+") grupo_id";
    } else sql += ",a.grupo_id";
    
    sql += ",a.modo_id, a.pac_id,a.admision, to_char(a.fecha,'dd/mm/yyyy')fecha ,to_char(a.fecha,'hh12:mi am')hora, a.valor,b.id,  b.descripcion,nvl(( select  z.descripcion  from tbl_sal_evolucion_param_det z  where z.id_param = a.parametro_id  and z.code=a.code_det /* and  y.estado = 'A'*/ ),a.valor) as detalle, (select descripcion||' ( '||codigo||' )' from tbl_sal_modo_ventilacion where id = a.modo_id) as modo_desc from tbl_sal_evolucion_respiratorio a, tbl_sal_evolucion_parametro b where b.id = a.parametro_id(+) and b.tipo = "+((refType.trim().equals("RES"))?"'RE'":"'HD'")+" and a.pac_id(+) = "+pacId+" and a.admision(+) = "+noAdmision+(!groupId.trim().equals("0")?" and a.grupo_id(+) = "+groupId:" ")+" and  a.ref_type(+) ='"+refType+"'";
    
    if (groupId.equals("") || groupId.equals("0")){
        if (!fDate.trim().equals("") && !tDate.trim().equals("")) sql += " and to_date(to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am')  between to_date('"+fDate+"','dd/mm/yyyy hh12:mi am') and to_date('"+tDate+"','dd/mm/yyyy hh12:mi am')";
    }

    sql += " order by a.grupo_id, b.orden";
	
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
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = !fDate.trim().equals("") && !tDate.trim().equals("") ? "DESDE: "+fDate+"    -    HASTA: "+tDate : "";
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
		dHeader.addElement(".20");
		dHeader.addElement(".30");
		dHeader.addElement(".30");
        
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

String groupByfecha = "";
String groupByhora = "";
String groupById = "";

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("FECHA",1,1);
		pc.addBorderCols("HORA",1,1);
		pc.addBorderCols("MODO VENT.",1,1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("VALOR",1);



	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	
    if (al.size() == 0)
        pc.addCols(" *** No hay registros ***",1,dHeader.size(),cHeight);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if ( !groupById.equals(cdo.getColValue("grupo_id")) ){
					pc.setFont(8,1,Color.white);
				if ( i!=0){
					pc.addCols("",0,dHeader.size());
				}
				pc.addCols("#: "+cdo.getColValue("grupo_id"),0,2,Color.lightGray);
				pc.addCols("Usuario: "+cdo.getColValue("usuario"),0,3,Color.lightGray);
				 }
			 pc.setFont(8,1);
			if ( !groupByfecha.equals(cdo.getColValue("fecha")+"-"+cdo.getColValue("grupo_id")) ){
				 pc.addCols(cdo.getColValue("fecha"),0,1);
			}else{pc.addCols("",0,1);}

			 if ( !groupByhora.equals(cdo.getColValue("hora")) ){
				 pc.addCols(cdo.getColValue("hora"),0,1);
				 pc.addCols(cdo.getColValue("modo_desc"),0,1);
			}else{pc.addCols("",0,2);}

		pc.setFont(8,0);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		if(paramRespDet.trim().equals("S")&&refType.trim().equals("RES")){pc.addCols(cdo.getColValue("detalle"),0,1);}
		else pc.addCols(cdo.getColValue("valor"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		groupByfecha = cdo.getColValue("fecha")+"-"+cdo.getColValue("grupo_id");
		groupByhora = cdo.getColValue("hora");
		groupById =  cdo.getColValue("grupo_id");
	}
	//}
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>