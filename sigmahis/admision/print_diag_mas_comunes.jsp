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
<!-- Reporte: "Censo de Habitaciones por cargo"  -->

<!-- Fecha: 12/03/2010                            -->

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
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String tipo = request.getParameter("tipo");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String trimestre = request.getParameter("trimestre");
String medico = request.getParameter("medico");
String compania = (String) session.getAttribute("_companyId");
String mes1 ="";
String mes2 ="",descTitulo ="",descTitulo2="",descMes="";

if (tipo == null) tipo  = "";
if (mes == null) mes  = "";
if (anio == null) anio  = "";
if (trimestre == null) trimestre  = "";
if (medico == null) medico  = "";

sbSql.append(" select * from (select rownum as rn, a.* from (select  count(d.diagnostico) cantidad,d.diagnostico,(select nombre from tbl_cds_diagnostico where codigo =d.diagnostico) descDiag, min(d.orden_diag) orden  from tbl_adm_diagnostico_x_admision d,tbl_adm_admision a where  a.pac_id = d.pac_id and a.secuencia = d.admision and  d.tipo(+)='I' ");
if (!medico.trim().equals("")){
 sbSql.append(" and a.medico = '");
 sbSql.append(medico);
 sbSql.append("'");
}

if (!tipo.trim().equals("")&&tipo.trim().equals("M")){
descTitulo = " - POR MES ";
    if(mes.equals("01")) descMes = "ENERO";
	else if(mes.equals("02")) descMes = "FEBRERO";
	else if(mes.equals("03")) descMes = "MARZO";
	else if(mes.equals("04")) descMes = "ABRIL";
	else if(mes.equals("05")) descMes = "MAYO";
	else if(mes.equals("06")) descMes = "JUNIO";
	else if(mes.equals("07")) descMes = "JULIO";
	else if(mes.equals("08")) descMes = "AGOSTO";
	else if(mes.equals("09")) descMes = "SEPTIEMBRE";
	else if(mes.equals("10")) descMes = "OCTUBRE";
	else if(mes.equals("11")) descMes = "NOVIEMBRE";
	else descMes = "DICIEMBRE";

	descTitulo2 = " MES "+descMes+" - AÑO - "+anio;
sbSql.append(" and trunc(a.fecha_ingreso) >= to_date('01/");
sbSql.append(mes);
sbSql.append("/");
sbSql.append(anio);
sbSql.append("', 'dd/mm/yyyy')");

sbSql.append(" and trunc(a.fecha_ingreso) <= last_day(to_date('01/");
sbSql.append(mes);
sbSql.append("/");
sbSql.append(anio);
sbSql.append("', 'dd/mm/yyyy'))");
}
if (!tipo.trim().equals("")&&tipo.trim().equals("A")){
descTitulo = "  ";
	descTitulo2 = " AÑO "+anio;
sbSql.append(" and trunc(a.fecha_ingreso) >= to_date('01/01/");
sbSql.append(anio);
sbSql.append("', 'dd/mm/yyyy')");

sbSql.append(" and trunc(a.fecha_ingreso) <= last_day(to_date('01/12/");
sbSql.append(anio);
sbSql.append("', 'dd/mm/yyyy'))");
}
if (!tipo.trim().equals("")&&tipo.trim().equals("T")){
descTitulo = " - POR TRIMESTRE ";
if(trimestre.trim().equals("1")){
	mes1 ="01";
	mes2 = "03";
	descTitulo2 = " PRIMER TRIMESTRE - AÑO "+anio;
}else if(trimestre.trim().equals("2")){
	mes1 ="04";
	mes2 = "06";
		descTitulo2 = " SEGUNDO TRIMESTRE - AÑO "+anio;

}else if(trimestre.trim().equals("3")){
	mes1 ="07";
	mes2 = "09";
		descTitulo2 = " TERCER TRIMESTRE - AÑO "+anio;

}
else if(trimestre.trim().equals("3")){
	mes1 ="10";
	mes2 = "12";
	descTitulo2 = " CUARTO TRIMESTRE  - AÑO "+anio;

}
sbSql.append(" and trunc(a.fecha_ingreso) >= to_date('01/");
sbSql.append(mes1);
sbSql.append("/");
sbSql.append(anio);
sbSql.append("', 'dd/mm/yyyy')");

sbSql.append(" and trunc(a.fecha_ingreso) <= last_day(to_date('01/");
sbSql.append(mes2);
sbSql.append("/");
sbSql.append(anio);
sbSql.append("', 'dd/mm/yyyy'))");
}

sbSql.append("group by d.diagnostico order by 1 desc) a) where rn between 1 and 10");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = mon;
	String day=fecha.substring(0, 2);
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
	String title = "ADMISION";
	String subtitle = "DIAGNOSTICOS MAS COMUNES  "+descTitulo;
	String xtraSubtitle = "  "+descTitulo2;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
	    dHeader.addElement(".15");
		dHeader.addElement(".65"); 
	    dHeader.addElement(".20");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);

		pc.addBorderCols("NO",1,1,Color.lightGray);
		pc.addBorderCols("DIAGNOSTICO",1,1,Color.lightGray);
		pc.addBorderCols("CANTIDAD",1,1,Color.lightGray);
	pc.setTableHeader(2);

	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
      cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.addCols(" "+cdo.getColValue("rn"),1,1);
		pc.addCols(" "+cdo.getColValue("descDiag"),0,1);
		pc.addCols(" "+cdo.getColValue("cantidad"),1,1);

	  }//for i

	if (al.size() == 0)
	{
	   pc.addCols("No existen registros",1,dHeader.size());
	}
	
	
	 pc.addTable();
	 pc.close();
	response.sendRedirect(redirectFile);
}//get
%>


