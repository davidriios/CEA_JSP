<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ include file="../common/pdf_header.jsp"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String appendFilterXtra = request.getParameter("appendFilterXtra");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String fp = request.getParameter("fp");
if (appendFilter == null) appendFilter = "";
if (appendFilterXtra == null) appendFilterXtra = "";
if (fp == null) fp = "";

if(!appendFilter.trim().equals("")){
    
	if (fp.trim().equals("RE")) appendFilter += " and c.estado_cita = 'E' and c.admision is not null";
	
    sql = "select aa.* from(select c.habitacion, sh.descripcion as habitacion_desc, c.codigo, to_char(fecha_cita,'dd/mm/yyyy') as fecha_cita,to_char(c.hora_cita,'hh12:mi am') as hora_cita ,(select join(cursor( select '['||p.codigo||'] '||p.descripcion from tbl_cdc_cita_procedimiento cp, tbl_cds_procedimiento p where cp.procedimiento = p.codigo and cp.cod_cita = c.codigo and fecha_cita = c.fecha_cita ) ,' ; ') as procedimientos from dual) as procedimientos,(select m.primer_nombre||' '||m.primer_apellido from tbl_adm_medico m, tbl_cdc_personal_cita pe where pe.cod_cita = c.codigo and m.codigo = pe.medico and pe.funcion = 1 and pe.fecha_cita = c.fecha_cita and pe.medico = c.cod_medico and rownum = 1) as medico,getcama(c.pac_id,c.hosp_amb,'') as cama, c.pac_id||'-'||c.admision as pid, c.nombre_paciente, case when c.admision is null then (select nombre from tbl_adm_empresa where codigo = c.empresa and rownum = 1) else getAseguradora2(c.pac_id,c.admision,null) end as empresa, decode(c.estado_cita,'R','RESERVADA','C','CANCELADA','E','REALIZADA','T','TRANSFERIDA') as estado_cita, c.codigo as cod_cita, p.id_paciente cedula, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nac, c.persona_reserva, nvl(c.nombre_medico_externo,c.nombre_medico) nombre_medico_externo, decode(c.forma_reserva,'T','TELEFONICA','E','E-MAIL','PERSONALMENTE') forma_reserva, decode(c.cita_cirugia,'E','ELECTIVA','URGENCIA') tipo_cita, decode(c.hosp_amb,'H','HOSPITALIZADA','AMBULAORIA') tipo_atencion from tbl_cdc_cita c, vw_adm_paciente p ,tbl_sal_habitacion sh where c.pac_id = p.pac_id(+) and sh.compania = c.compania and sh.codigo=c.habitacion AND sh.quirofano = 2 and c.compania = "+compania+appendFilter+" order by c.habitacion, c.hora_cita desc, c.hora_cita ) aa where 1=1 "+appendFilterXtra;
	
	al = SQLMgr.getDataList(sql);
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CITAS";
	String subtitle = "SALON DE OPERACION";
	String xtraSubtitle = fp.equals("RE")?"CITAS REALIZADAS":"";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		if (fp.trim().equals("RE"))dHeader.addElement(".37");
		else dHeader.addElement(".30");
		dHeader.addElement(".15");
		dHeader.addElement(".18");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
		if (!fp.trim().equals("RE"))dHeader.addElement(".07");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(2);
	pc.setFont(8, 1);
	pc.addBorderCols("Fecha",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Procedimientos",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Médico",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Paciente",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Sala",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Aseguradora",1,1,cHeight,Color.lightGray);
	if (!fp.trim().equals("RE"))pc.addBorderCols("Estado",1,1,cHeight,Color.lightGray);
	
	pc.setVAlignment(0);
	
	String gHabitacion = "";
	int totXhab = 0;
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		
		if (i!=0){
		  if (!gHabitacion.equals(cdo.getColValue("habitacion"))){
			pc.addCols("TOTAL: "+totXhab,0,dHeader.size(),Color.lightGray);
			totXhab=0;	
		  }
		}
		
		if (!gHabitacion.equals(cdo.getColValue("habitacion"))){
			pc.setFont(8, 1,Color.white);
			if (i!=0) pc.addCols(" ",0,dHeader.size());
			pc.addCols(cdo.getColValue("habitacion_desc"),0,dHeader.size(),Color.lightGray);
		}

 		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("fecha_cita")+" "+cdo.getColValue("hora_cita"),0,1);
		pc.addCols(cdo.getColValue("procedimientos"),0,1);
		pc.addCols(cdo.getColValue("medico"),0,1);
		pc.addCols(cdo.getColValue("nombre_paciente"),0,1);
		pc.addCols(cdo.getColValue("cama"),1,1);
		pc.addCols(cdo.getColValue("empresa"),0,1);
		if (!fp.trim().equals("RE")) pc.addCols(cdo.getColValue("estado_cita"),1,1);
		
		gHabitacion = cdo.getColValue("habitacion");
		totXhab++;
		
	}//for i

	if (al.size() == 0){
	  pc.addCols("No existen registros",1,dHeader.size());
	}else {
	  pc.addCols("TOTAL: "+totXhab,0,dHeader.size(),Color.lightGray);
	  totXhab = 0;
	  pc.setFont(10, 1);
	  pc.addCols(" ",0,dHeader.size());
	  pc.addBorderCols("Total: "+al.size(),0,dHeader.size(),1f,1f,0f,0f);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>