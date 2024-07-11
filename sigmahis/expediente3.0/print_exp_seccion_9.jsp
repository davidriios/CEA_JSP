<%@ page errorPage="../error.jsp"%>
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

<!-- Desarrollado por: Oscar Hawkins      -->
<!-- Reporte: "Informe de Pacientes Fallecidos"-->
<!-- Reporte: ADM3087                          -->
<!-- Clínica Hospital San Fernando             -->
<!-- Fecha: 20/10/2010                         -->

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
CommonDataObject cdo,cdoUsr, cdoPacData = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String fp = request.getParameter("fp");
String compania = (String) session.getAttribute("_companyId");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (fp == null) fp = "";

sql="select to_char(fecha_creacion,'dd/mm/yyyy')fecha, to_char(fecha_creacion,'hh12:mi:ss am') hora,usuario_creacion,usuario_modificacion from (select min(fecha_creacion) fecha_creacion,max(fecha_modificacion) fecha_modificacion, usuario_creacion,usuario_modificacion from tbl_sal_antecedente_neonatal where fecha_creacion is not null and rownum =1 and pac_id="+pacId+" group by usuario_creacion,usuario_modificacion)";
cdoUsr = SQLMgr.getData(sql);
if(cdoUsr == null ){cdoUsr =new CommonDataObject();cdoUsr.addColValue("fecha","");cdoUsr.addColValue("hora","");cdoUsr.addColValue("usuario_creacion","");cdoUsr.addColValue("usuario_modificacion","");}

sql = "select a.codigo, a.descripcion, b.cod_paciente, to_char(b.fec_nacimiento,'dd/mm/yyyy') as fecha, nvl(b.cod_medida,' ') as medida, b.cod_neonatal as code, nvl(b.valor_alfanumerico,'') as valor, b.valor_numero as valornum, b.observacion, b.pac_id,b.usuario_creacion,to_char(b.fecha_creacion,'dd/mm/yyyy')fecha_creacion from tbl_sal_factor_neonatal a, tbl_sal_antecedente_neonatal b where 1=1";

if (fp.trim().equalsIgnoreCase("nutricional_riesgo")) sql += " and a.codigo = b.cod_neonatal and b.pac_id = "+pacId;
else sql += " and a.codigo=b.cod_neonatal(+) and b.pac_id(+)="+pacId;
sql += " order by a.orden ";

al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	if(desc == null) desc = "";
	
	 String fecha = cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
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
	String title =  "EXPEDIENTE";//"Antecedentes Neonatal / Pediatrico";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	String si,no ;
	
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

   String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
   String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";

			
		Vector dHeader = new Vector();
		dHeader.addElement("25"); 
		dHeader.addElement("8");
		dHeader.addElement("8");
		dHeader.addElement("15");
		dHeader.addElement("25");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, cDateTime, dHeader.size());
		
		pc.setVAlignment(0);	
		pc.setFont(7, 0);
		
		pc.addCols("Fecha Creac.:  "+cdoUsr.getColValue("fecha"),0,1);
		pc.addCols("Hora Creac.: "+cdoUsr.getColValue("hora"),0,2);
		pc.addCols("Registrado por: "+cdoUsr.getColValue("usuario_creacion"),0,1);
		pc.addCols("Modificado por: "+cdoUsr.getColValue("usuario_modificacion"),0,1);
		pc.addCols("",0,5);
		
		pc.addBorderCols("Descripción",1 ,1);
		pc.addBorderCols("SI",1 ,1);
		pc.addBorderCols("NO",1 ,1);
		pc.addBorderCols("Valor",1 ,1);
		pc.addBorderCols("Observación",1 ,1);
		pc.setTableHeader(3);
		for(int i = 0; i<al.size(); i++){
		
		cdo = (CommonDataObject) al.get(i);
				
		if(cdo.getColValue("valor") != ""){
		    si =  "x"; //iconChecked;
			no = ""; //iconUnchecked;
		}else{
		    si = ""; //iconUnchecked;
			no = "x"; //iconChecked;
		}
		
		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(si,1,1);
		pc.addCols(no,1,1);
		pc.addCols(cdo.getColValue("valorNum"),1,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		
		pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,15.2f);
		}
		
		pc.addCols("",1,dHeader.size(),30.2f);
		
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",0,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
