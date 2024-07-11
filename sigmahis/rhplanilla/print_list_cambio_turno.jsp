<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupo = request.getParameter("grupo");
String codigo = request.getParameter("codigo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));

if (appendFilter == null) appendFilter = "";

sbSql.append("SELECT to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha, (select descripcion from tbl_pla_ct_motivo_cambio where codigo = a.motivo_cambio and compania = a.compania) as mfaltaDesc, a.codigo, decode(a.aprobado,'S','Aprobado','N','Registrado') as estado, d.emp_id, (select primer_nombre||' '||primer_apellido from tbl_pla_empleado where emp_id = d.emp_id) as nombre, nvl(a.grupo,'0') as grupo, a.aprobado, d.num_empleado, a.observaciones, to_char(d.fecha_tnuevo,'dd/mm/yyyy') as fechaNuevo,  nvl((select to_char(hora_entrada,'hh12:mi am')||' / '||to_char(hora_salida,'hh12:mi am') from tbl_pla_ct_turno where to_char(codigo) = d.turno_asignado and compania = d.compania),d.turno_asignado) as programado, nvl((select to_char(hora_entrada,'hh12:mi am')||' / '||to_char(hora_salida,'hh12:mi am') from tbl_pla_ct_turno where to_char(codigo) = d.turno_nuevo and compania = d.compania),d.turno_nuevo) as  realizar from tbl_pla_ct_enc_cambio_programa a, tbl_pla_ct_det_cambio_programa d where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and a.mes = ");
sbSql.append(mes);
sbSql.append(" and a.grupo = ");
sbSql.append(grupo);
/*sbSql.append(" and a.emp_id = ");
sbSql.append(empId);*/
sbSql.append(" and a.codigo = ");
sbSql.append(codigo);
sbSql.append(" and a.anio = d.anio and a.mes = d.mes and a.codigo = d.codigo and a.compania = d.compania and a.grupo = d.grupo order by a.fecha_solicitud desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "COMPROBANTE DE CAMBIO DE TURNO";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".35");
		dHeader.addElement(".35");
		dHeader.addElement(".15");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;


	//table body
	String obs = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(i==0)
		{
		  pc.setFont(7, 1);

					pc.addCols("  "+cdo.getColValue("mfaltaDesc"),0,dHeader.size());

					pc.addCols(" ",0,3);
					pc.addCols(" Fecha de Solicitud: "+cdo.getColValue("fecha"),1,1);
			pc.addCols(" ",0,dHeader.size());
			obs=cdo.getColValue("observaciones");


		}

		pc.setFont(7, 1);
		pc.setVAlignment(0);
			pc.addCols(" Yo, "+cdo.getColValue("nombre"),0,3);
			pc.addCols(" No.  "+cdo.getColValue("num_empleado"),1,1);


	pc.setFont(7, 1);
	pc.addCols("DIA",1,1);
	pc.addCols("TURNO PROGRAMADO",1,1);
	pc.addCols("TURNO A REALIZAR",1,1);
  pc.addCols("",1,1);

  pc.setFont(7, 0);
	pc.setVAlignment(0);
	pc.addCols(""+cdo.getColValue("fechaNuevo"),1,1);
	pc.addCols(""+cdo.getColValue("programado"),1,1);
	pc.addCols(""+cdo.getColValue("realizar"),1,1);
	pc.addCols("",1,1);


pc.addCols(" ",0,dHeader.size());
pc.addCols(" ",0,dHeader.size());
	pc.addCols("Firma  del  Trabajador  :  ",0,1);
	pc.addCols("____________________________________________________________________________________",0,2);
  pc.addCols("",0,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols(" ",0,dHeader.size());


	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{

	pc.setFont(7, 1);
	pc.addCols("Observaciones  :  ",0,dHeader.size());
	pc.setFont(7, 0);
	pc.addCols(""+obs,0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());

	pc.addCols(" ",0,dHeader.size());
	pc.addCols("______________________________________",0,dHeader.size());
	pc.addCols("          Firma de Autorizacion",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols("USUARIO : "+userName,0,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>