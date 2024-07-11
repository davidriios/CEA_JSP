<%//@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
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
CommonDataObject cdo, cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String userId   = UserDet.getUserId();
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String compania = (String) session.getAttribute("_companyId");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

	sql = " select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fc, b.descripcion, a.valor, a.observacion, c.descripcion as cds, medico_enterado, quien_recibe, quien_reporta, (select  primer_nombre|| ' '|| primer_apellido from tbl_adm_medico where codigo = medico_enterado and rownum = 1) medico_enterado_nombre, coalesce((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = quien_recibe and rownum = 1),(select  primer_nombre|| ' '|| primer_apellido from tbl_adm_medico where codigo = quien_recibe and rownum = 1 ), (select upper(name) from tbl_sec_users where ref_code  = quien_recibe and rownum = 1)) quien_recibe_nombre, (select nombre_empleado from vw_pla_empleado where to_char(emp_id) = quien_reporta and rownum = 1) quien_reporta_nombre from tbl_sal_val_criticos a, tbl_sal_cds_val_criticos b, tbl_cds_centro_servicio c where a.codigo_valor = b.codigo and a.compania = "+compania+" and b.cds = c.codigo and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.fecha_creacion";

	al = SQLMgr.getDataList(sql);

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	
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

	float width  = 72 * 8.5f;//612 
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 20.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = desc;
	String xtraSubtitle = "";
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    
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
	dHeader.addElement("15");
	dHeader.addElement("37");
	dHeader.addElement("15");
	dHeader.addElement("33");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
			
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		String gCds = "";
		
		if(al.size() < 1){
			pc.addCols("No encontramos resultados", 1, dHeader.size());
		}else{
		
			for(int i = 0; i<al.size(); i++){
			
				cdo = (CommonDataObject) al.get(i);
	
				if (!gCds.equals(cdo.getColValue("cds"))){  
				   pc.setFont(9, 1);
				   pc.addCols(cdo.getColValue("cds"),0,dHeader.size());
				   
				   pc.addBorderCols("FECHA",1 ,1);
				   pc.addBorderCols("PRUEBA",0 ,1);
				   pc.addBorderCols("VALOR CRÍTICO",1 ,1);
				   pc.addBorderCols("OBSERVACIÓN",0 ,1);
				}
				   
                pc.setFont(9, 0);	
                pc.addCols(cdo.getColValue("fc"),1 ,1);
                pc.addCols(cdo.getColValue("descripcion"),0 ,1);
                pc.addCols(cdo.getColValue("valor"),1 ,1);
                pc.addCols(cdo.getColValue("observacion"),0 ,1);
                
                pc.setFont(9, 1);
                pc.addCols("RECIBE, TRANSCRIBE, LEE Y CONFIRMA:",0,2);
                pc.setFont(9, 0);
                pc.addCols("["+cdo.getColValue("quien_recibe", UserDet.getRefCode())+"] "+cdo.getColValue("quien_recibe_nombre", " "),0,2);
                
                pc.setFont(9, 1);
                pc.addCols("QUIEN REPORTA:",0,2);
                pc.setFont(9, 0);
                pc.addCols("["+cdo.getColValue("quien_reporta")+"] "+cdo.getColValue("quien_reporta_nombre"," "),0,2);
                
                pc.setFont(9, 1);
                pc.addCols("MÉDICO ENTERADO:",0,2);
                pc.setFont(9, 0);
                pc.addCols("["+cdo.getColValue("medico_enterado")+"] "+cdo.getColValue("medico_enterado_nombre", " "),0,2);
                
                pc.addCols(" ",1,dHeader.size());
 
                gCds = cdo.getColValue("cds");
		
		    }
		}
pc.addTable();
if(isUnifiedExp){
pc.close();
response.sendRedirect(redirectFile);}
%>