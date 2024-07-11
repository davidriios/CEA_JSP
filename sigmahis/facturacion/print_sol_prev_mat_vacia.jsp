<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%//@ include file="../common/pdf_header.jsp"%>
<%
/**
======================================================================================
		FG             	REPORTE                DESCRIPCION
										CDC400260_A						 Solicitud Previa de Materiales Medicamentos
======================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();

String sql = "",desc ="";
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
String codCita = request.getParameter("codCita");
String fechaRegistro = request.getParameter("fechaRegistro");
String tipoSolicitud = request.getParameter("tipoSolicitud");

CommonDataObject cdoHeader = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();

//sql = "select c.codigo, c.nombre_paciente, to_char(c.fecha_cita,'dd/mm/yyyy') fecha_cita, to_char(c.hora_cita,'hh12:mi am') hora_cita, c.habitacion, c.observacion, c.empresa, c.fec_nacimiento, c.cod_paciente, c.admision, getAseguradora2(c.pac_id, c.admision, c.empresa) aseguradora, nvl(getfullNombreMedico(1, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') nombre_medico, nvl(getfullNombreMedico(2, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') anestesiologo, nvl(getcirculadorfullname(8, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') instrumentista, nvl(getcirculadorfullname(7, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') circulador from tbl_cdc_cita c where c.codigo = "+codCita+" and to_date(to_char(c.fecha_registro, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaRegistro+"', 'dd/mm/yyyy')";
sql = "select to_char(p.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento, c.codigo, c.nombre_paciente, to_char(c.fecha_cita,'dd/mm/yyyy') fecha_cita, to_char(c.hora_cita,'hh12:mi am') hora_cita, c.habitacion, nvl(c.observacion, (select join(cursor( select nvl(b.observacion, b.descripcion) from tbl_cdc_cita_procedimiento a,tbl_cds_procedimiento b where b.codigo=a.procedimiento and trunc(a.fecha_cita) = c.fecha_registro  and a.cod_cita=c.codigo),'; ') proced from dual)) observacion, c.empresa, c.fec_nacimiento, c.cod_paciente, c.admision, getAseguradora2(c.pac_id, c.admision, c.empresa) aseguradora, nvl(getfullNombreMedico(1, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') nombre_medico, nvl(getfullNombreMedico(2, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') anestesiologo, nvl(getcirculadorfullname(8, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') instrumentista, nvl(getcirculadorfullname(7, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') circulador, c.pac_id||' - '||c.admision cuenta,p.sexo,nvl(trunc(months_between(sysdate,p.fecha_nacimiento) / 12), 0) || ' A ' || nvl(mod(trunc(months_between(sysdate, p.fecha_nacimiento)), 12), 0) || ' M ' || round((sysdate - add_months( p.fecha_nacimiento, (nvl(trunc(months_between(sysdate, p.fecha_nacimiento) / 12), 0) * 12 + nvl(mod(trunc(months_between(sysdate, p.fecha_nacimiento)), 12), 0)))),0) || ' D ' edad,se.horaSalidaSa,se.horaEntradaSa,x.horaSalidaAn,x.horaEntradaAn,nvl(getfullNombreMedico(10, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ')asistente from tbl_cdc_cita c,vw_adm_paciente p,( select  nvl(to_char(hora_entrada, 'HH12:mi am'),' ') horaEntradaSa, nvl(to_char(hora_salida, 'HH12:mi am'),' ') horaSalidaSa,cita_fecha_reg fecha_registro,cita_codigo codigo from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and trunc(cita_fecha_reg) = to_date('"+fechaRegistro+"', 'dd/mm/yyyy') and (tipo_solicitud = 'Q')"+(tipoSolicitud.equals("A")?"":" and estado in ('T', 'E')")+" and rownum = 1 )se,(select  nvl(to_char(hora_entrada, 'HH12:mi am'),' ') horaEntradaAn, nvl(to_char(hora_salida, 'HH12:mi am'),' ') horaSalidaAn,cita_fecha_reg fecha_registro,cita_codigo codigo from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and trunc(cita_fecha_reg) = to_date('"+fechaRegistro+"', 'dd/mm/yyyy') and (tipo_solicitud = 'A') and estado in ('T', 'E') and rownum = 1 )x where c.codigo = "+codCita+" and c.fecha_registro= to_date('"+fechaRegistro+"', 'dd/mm/yyyy') and c.pac_id = p.pac_id(+) and trunc(c.fecha_registro) = se.fecha_registro(+) and c.codigo=se.codigo(+) and trunc(c.fecha_registro) = x.fecha_registro(+) and c.codigo=x.codigo(+) ";

cdoHeader = SQLMgr.getData(sql);
sql = "select a.descripcion desc_articulo, sd.art_familia || '-' || sd.art_clase || '-' || sd.cod_articulo cod_articulo, decode(sd.cantidad, null, ' ', 0, ' ', sd.cantidad) solicitud, decode(sd.entrega, null, ' ', 0, ' ', sd.entrega) entrega, decode(sd.adicion, null, ' ', 0, ' ', sd.adicion) adicion, decode(sd.devolucion, null, ' ', 0, ' ', sd.devolucion) devolucion, decode((nvl(sd.entrega, 0) + nvl(sd.adicion, 0) - nvl(sd.devolucion, 0)), 0, ' ', (nvl(sd.entrega, 0) + nvl(sd.adicion, 0) - nvl(sd.devolucion, 0))) utilizado from tbl_cdc_solicitud_det sd, tbl_cdc_solicitud_enc se, tbl_inv_articulo a where (a.compania = sd.compania and (a.cod_articulo = sd.cod_articulo) and (se.cita_codigo = sd.cita_codigo) and (se.cita_fecha_reg = sd.cita_fecha_reg) and (se.secuencia = sd.secuencia) and (sd.cita_codigo = "+codCita+") and (to_date(to_char(sd.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaRegistro+"', 'dd/mm/yyyy')) and (se.tipo_solicitud = '"+tipoSolicitud+"')"+(tipoSolicitud.equals("A")?"":" and se.estado in ('T', 'E')")+") order by a.descripcion";
al = SQLMgr.getDataList(sql);

sql = "";

//ArrayList alUsos = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 27; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = 27;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;
	System.out.println("nPages="+nPages);
	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";//print_articulos_consignacion.jsp
	String fileNamePrefix = "print_sol_prev_mat_vacia";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
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

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setHeader = new Vector();
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");

	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".58");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".07");
		setDetail.addElement(".07");
		setDetail.addElement(".07");

	String wh = "", groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 16.0f;

	//pdfHeader(pc, _comp, pCounter, nPages, depto,titulo, userName, fecha);

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable();
		pc.setFont(6, 0);
		pc.addBorderCols("Usuario: "+userName,0,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(fecha,1,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Página: "+pCounter+" de "+nPages,2,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
	pc.addTable();
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("SOLICITUD PREVIA",1,6, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("FECHA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("fecha_cita"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("HORA:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("hora_cita"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("QUIROFANO:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("habitacion"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("PACIENTE:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("nombre_paciente"),0,3, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(7, 0);
		pc.addBorderCols("Cita #:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("codigo"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("SEXO: ",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("sexo"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("EDAD:  ",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("edad"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("CUENTA #:  ",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("cuenta"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("FECHA NAC: ",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("fecha_nacimiento"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		
		pc.addBorderCols("ASEGURADORA: ",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("aseguradora"),0,3, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("CIRUGIA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 0);
		pc.addBorderCols(cdoHeader.getColValue("observacion"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("CIRUJANO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("nombre_medico"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("ASISTENTE:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("asistente"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		if(tipoSolicitud.equals("A")){
		pc.setFont(7, 0);
		pc.addBorderCols("PRE-OPERATORIO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("POST-OPERATORIO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("ANESTESIOLOGO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("anestesiologo"),0,3, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(7, 0);
		pc.addBorderCols("TIPO ANESTESIA:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		} else if(tipoSolicitud.equals("Q")){
		pc.setFont(7, 0);
		pc.addBorderCols("INTRUMENTISTA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("instrumentista"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(7, 0);
		pc.addBorderCols("CIRCULADOR:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("circulador"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		}
		
		pc.setFont(7, 0);
		pc.addBorderCols("ANESTESIA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Hora de Entrada (ANEST.):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("horaEntradaAn"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Hora de Salida (ANEST.):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("horaSalidaAn"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		//}

		pc.setFont(7, 0);
		pc.addBorderCols("Hora de Entrada (SALON):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("horaEntradaSa"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Hora de Salida (SALON):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("horaSalidaSa"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.copyTable("Header");
		pc.addCopiedTable("Header");
	
	pc.createTable();
		pc.setFont(8, 1);
		pc.addBorderCols((tipoSolicitud.equals("A")?"ANESTESIA":"QUIRURGICO"),1,6, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
	pc.addTable();
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Cód. Artículo",1);
		pc.addBorderCols("Materiales y Medicamentos   >> ADICIONALES <<",1);
		pc.addBorderCols("Solic.",1);
		pc.addBorderCols("Entr.",1);
		pc.addBorderCols("Adic.",1);
		pc.addBorderCols("Devol.",1);
		pc.addBorderCols("Total",1);
	pc.addTable();
	
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject)al.get(i);
		pc.createTable();
			pc.addBorderCols(cdo.getColValue("cod_articulo"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("desc_articulo"),0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("solicitud"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("entrega"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("adicion"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("devolucion"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
		pc.addTable();

	}//for i

	for (int i=0; i<28-al.size(); i++)
	{

		pc.createTable();
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
		pc.addTable();

	}//for i

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>