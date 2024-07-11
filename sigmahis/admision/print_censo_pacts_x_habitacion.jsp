<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<!-- Reporte: "Censo de Habitaciones x Categ. de Admisión"  -->
<!-- Reporte: ADM3031                             -->
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
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String habitacion = request.getParameter("habitacion");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

if (habitacion == null) habitacion = "";
if (!habitacion.trim().equals("")) {

	sbFilter.append(" and exists (select null from tbl_adm_cama_admision where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null and habitacion = '");
	sbFilter.append(IBIZEscapeChars.forSingleQuots(habitacion));
	sbFilter.append("')");

} else sbFilter.append(" and exists (select null from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null and exists (select null from tbl_sal_habitacion where compania = z.compania and codigo = z.habitacion and quirofano != 2))");//se agrega este filtro para mantener las habitaciones mostrada en el filtro de la pantalla de parámetros admision/reportes_admision.jsp

//-----------------------------------------------------------------------------------------------//
//------------Query para obtener datos del Censo de Pacientes Hosp. x Habitacion--------------//
sbSql.append("select (select primer_nombre||' '||primer_apellido from vw_adm_paciente where pac_id = a.pac_id) as nombrePaciente");
sbSql.append(", (select decode(apellido_de_casada,null,primer_apellido,apellido_de_casada)||' '||primer_nombre from tbl_adm_medico where codigo = a.medico) as medico");
sbSql.append(",a.codigo_paciente as cod_pac, a.secuencia as noAdmision");
sbSql.append(", nvl((select decode(vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') from vw_adm_paciente where pac_id = a.pac_id),'-') as vip");
sbSql.append(", nvl((select (select decode(estado_cama,'M','MANTENIMIENTO','U','EN USO','D','DISPONIBLE','I','INACTIVO','T','TRAMITE',estado_cama) from tbl_sal_cama where compania = z.compania and habitacion = z.habitacion and codigo = z.cama) from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null),'-') as estadoCama");
sbSql.append(", nvl((select (select (select decode(categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','E','ECONOMICA','T','SUITE','Q','QUIROFANO','O','OTROS',categoria_hab) from tbl_sal_tipo_habitacion where compania = y.compania and codigo = y.tipo_hab) from tbl_sal_cama y where y.compania = z.compania and y.habitacion = z.habitacion and y.codigo = z.cama) from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null),'-') as categoriaHabit");
sbSql.append(", nvl(decode(a.corte_cta,null,to_char(a.fecha_ingreso,'dd/mm/yyyy'),busca_f_ingreso(to_char(a.fecha_ingreso,'dd/mm/yyyy'),a.secuencia,a.pac_id)),' ') as fechaIngreso");
sbSql.append(", (select z.cama from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null) as cama");
sbSql.append(", (select z.habitacion from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null) as habitacion");
sbSql.append(", (select (select descripcion from tbl_sal_habitacion where compania = z.compania and codigo = z.habitacion) from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null) as descHabit");
sbSql.append(", a.categoria");
sbSql.append(", (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as descCat");
sbSql.append(", (select (select (select descripcion from tbl_cds_centro_servicio where codigo = y.unidad_admin) from tbl_sal_habitacion y where y.compania = z.compania and y.codigo = z.habitacion) from tbl_adm_cama_admision z where compania = a.compania and pac_id = a.pac_id and admision = a.secuencia and fecha_final is null) as centro");
sbSql.append(", nvl((select nombre from tbl_adm_responsable where pac_id = a.pac_id and admision = a.secuencia and estado = 'A'),' ') as responsable");
sbSql.append(", a.secuencia, a.pac_id");
sbSql.append(" from tbl_adm_admision a where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.estado = 'A' and exists (select null from tbl_adm_categoria_admision where codigo = a.categoria and adm_type = 'I')");
sbSql.append(sbFilter);
sbSql.append(" order by 10 desc,9,12,17,16");

//cdo = SQLMgr.getData(sbSql.toString());
al = SQLMgr.getDataList(sbSql.toString());

//+" to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, "
//+" getfingreso_pactivos(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id,cama.cama) as fechaIngreso, "

if (request.getMethod().equalsIgnoreCase("GET"))
{
		String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	String subtitle = "CENSO DE PACIENTES HOSPITALIZADO POR HABITACIÓN  ";
	String xtraSubtitle = "DEL DÍA: "+fecha;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
			dHeader.addElement(".10");
		dHeader.addElement(".22"); //
		dHeader.addElement(".07");
		dHeader.addElement(".19");
		dHeader.addElement(".11");
		dHeader.addElement(".23");
		dHeader.addElement(".08");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
	footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
	footer.addCols("[ VIP/D/N ] "+"  Esta Columna indica el programa de Fidelización al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP   = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   DIST  = Paciente pertenece al programa de clientes DISTINGUIDOS.",0,dHeader.size());
footer.addCols("                   MED   = Paciente pertenece al grupo de MEDICOS del STAFF.",0,dHeader.size());
footer.addCols("                   JDIR  = Paciente pertenece al grupo de los miembros de la JUNTA DIRECTIVA o es familiar de alguno de los miembros.",0,dHeader.size());
footer.addCols("                   N     = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);

		pc.addBorderCols("CAMA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MEDICO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TIPO HAB.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("RESPONSABLE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F. INGRESO",1,1,cHeight * 2,Color.lightGray);

	pc.setTableHeader(2);

	String groupBy = "";
	int pxs = 0, pxcath = 0;
	for (int i=0; i<al.size(); i++)
	{
			cdo = (CommonDataObject) al.get(i);

			//Inicio --- Agrupamiento por Habitación

			if(!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("habitacion")+" ] "))
			{
			if (i != 0)
			 {//i-1
				 pc.setFont(8, 1,Color.red);
			 pc.addCols(" ",0,dHeader.size(),cHeight);
			 }//i-1
			 pc.setFont(8, 1,Color.blue);
			 pc.addCols("HABITACIÓN:",0,1,cHeight);
			 pc.addCols("[ "+cdo.getColValue("habitacion")+" ] ",0,dHeader.size(),cHeight);
		}//Fin --- Agrupamiento por Habitación

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("cama"),1,1,cHeight);
		pc.addCols(cdo.getColValue("nombrePaciente"),0,1,cHeight);
		pc.addCols(cdo.getColValue("pac_id"),1,1,cHeight);
		pc.addCols(cdo.getColValue("medico"),0,1,cHeight);
		pc.addCols(cdo.getColValue("categoriaHabit"),1,1,cHeight);
		pc.addCols(cdo.getColValue("responsable"),0,1,cHeight);
		pc.addCols(cdo.getColValue("fechaIngreso"),1,1,cHeight);
		pxcath++;

			 groupBy  = "[ "+cdo.getColValue("habitacion")+" ] ";
		}//for i

	if (al.size() == 0)
	{
		 pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
		pc.setFont(8, 1,Color.black);
		pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addCols(" GRAN TOTAL DE PACIENTES:   "+ al.size(),0,dHeader.size(),Color.lightGray);
	}
	 pc.addTable();
	 pc.close();
	response.sendRedirect(redirectFile);
}//get
%>


