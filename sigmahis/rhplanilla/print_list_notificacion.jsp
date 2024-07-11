<%@ page errorPage="../error.jsp"%>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdo1 = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fg = request.getParameter("fg");
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String cadena = request.getParameter("cadena");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (cadena == null ) cadena = "";
if (request.getParameter("cadena") != null) cadena = " and em.emp_id in "+cadena;


sql = "select to_char(adef.fecha,'dd/mm/yyyy') as adef_fecha, to_char(adef.ta_hent,'hh12:mi') as adef_ta_hent, to_char(adef.ta_hsal,'hh12:mi') as adef_ta_hsal, adef.motivo as adef_motivo, adef.tiempo_horas, adef.tiempo_minutos, em.primer_nombre||' '|| decode(em.sexo,'F',decode(em.apellido_casada, null,em.primer_apellido,decode(em.usar_apellido_casada,'S','DE '|| em.apellido_casada, em.primer_apellido)), em.primer_apellido) as em_nombre_empleado, em.num_empleado, em.num_ssocial em_num_ssocial, ue.descripcion as ue_descripcion, ue.codigo as ue_codigo, decode(adef.accion,'DV','Devoluc. x incapacidad el '||to_char(adef.fecha_a_devolver,'dd/mm/yyyy')) dsp_devolucion, adef.accion, ce.ubicacion_fisica from tbl_pla_temporal_asistencia adef, tbl_pla_empleado em, tbl_pla_ct_grupo ue, tbl_pla_ct_empleado ce where adef.compania = "+session.getAttribute("_companyId")+" and adef.ue_codigo = "+grupo+" and trunc(adef.fecha) >= to_date('"+desde+"','dd/mm/yyyy') and trunc(adef.fecha) <= to_date('"+hasta+"','dd/mm/yyyy') and em.emp_id = adef.emp_id and em.compania = adef.compania and ce.emp_id = em.emp_id and ce.compania = em.compania and ce.num_empleado = em.num_empleado and ce.grupo = adef.ue_codigo and ue.codigo = adef.ue_codigo and ue.compania = adef.compania and (ce.estado != 3 or (ce.estado = 3 and trunc(ce.fecha_egreso_grupo) >= to_date('"+desde+"','dd/mm/yyyy'))) "+cadena+" and (adef.tiempo_minutos + adef.tiempo_horas >= 0 /*and adef.motivo != 4*/) order by em.num_empleado, adef.fecha";


//and (ce.ubicacion_fisica = "+area+")
 al = SQLMgr.getDataList(sql);

sql = "select ue.descripcion nombre_unidad, ue.codigo ue_codigo, 'Correspondiente a la '||decode(mod(ca.periodo,2),'0','2da Quincena de ','1ra Quincena de ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' de '||to_char(ca.fecha_inicial,'yyyy') quincena, 'PERIODO  :  del '||'"+desde+"'|| ' al '||'"+hasta+"' as titulo, to_char(to_date('"+cDate+"','dd/mm/yyyy'),'DD')||' DE '||to_char(to_date('"+cDate+"','dd/mm/yyyy'), 'FMMONTH','NLS_DATE_LANGUAGE=SPANISH')||' DE '||to_char(to_date('"+cDate+"','dd/mm/yyyy'),'yyyy') fecha from tbl_pla_calendario ca, tbl_pla_ct_grupo ue where ue.codigo="+grupo+" and ue.compania = "+session.getAttribute("_companyId")+" and trunc(ca.trans_desde) >= to_date('"+desde+"','dd/mm/yyyy') and trunc(ca.trans_hasta) <= to_date('"+hasta+"','dd/mm/yyyy') and ca.tipopla = 1";
cdo1 = SQLMgr.getData(sql);


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
	String title = "RECURSOS HUMANOS";
	String subtitle = " NOTIFICACIONES DE AUSENCIAS Y TARDANZAS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		dHeader.addElement(".18");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".20");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		  pc.setFont(6, 1);
		  pc.addCols(" ",0,7);
		  pc.addCols("TAR - Tardanzas",0,7);
		  pc.addCols("IEC - Inc.x.Enf.Común",0,1);
		  pc.addCols(" ",1,7);
		  pc.addCols("AUS - Ausencias",0,7);
	 	  pc.addCols("IRP - Inc.x.Riesgo Prof.",0,1);
		  pc.addCols(" ",1,7);
		  pc.addCols("PCS - Permiso c/sueldo",0,7);
		  pc.addCols("SUS - Suspensión",0,1);
		  pc.addCols(" ",1,7);
		  pc.addCols("PSS - Permiso s/sueldo ",0,8);

	   if (fg.equals("borrador"))
			{
	    pc.setFont(6, 1);
		  pc.addCols(" Este reporte es para la revisión de las notificaciones de ausencias y tardanzas y NO debe ser entregado al depto de PLANILLA ",0,dHeader.size());
		  } else {

		   pc.setFont(6, 1);
		  pc.addCols(" ",0,dHeader.size());
		  }

			pc.setFont(7, 4);
			pc.addCols("DEPARATMENTO : "+cdo1.getColValue("ue_codigo")+" - "+cdo1.getColValue("nombre_unidad"),0,dHeader.size());
			pc.addCols("FECHA :        "+cdo1.getColValue("fecha"),0,dHeader.size());
			pc.addCols(" "+cdo1.getColValue("titulo"),0,dHeader.size());

			pc.setFont(7, 1);
			pc.addCols(" "+cdo1.getColValue("quincena"),0,dHeader.size());

		pc.setFont(6, 1);
		pc.addCols("No.Emp.",0,1);
		pc.addCols("Nombre",1,1);
		pc.addCols("Fecha",1,1);
		pc.addCols("Turno",1,2);
		pc.addCols("Tiempo Desc.",1,2);
		pc.addCols("TAR",1,1);
		pc.addCols("AUS",1,1);
		pc.addCols("PCS ",1,1);
		pc.addCols("PSS",1,1);
		pc.addCols("IEC",1,1);
		pc.addCols("IRP",1,1);
		pc.addCols("SUS",1,1);
		pc.addCols("Uso Exclusivo",1,1);

		pc.addCols(" ",0,5);
		pc.addCols("h",1,1);
		pc.addCols("m",1,1);
		pc.addCols(" ",0,8);



	pc.setTableHeader(12);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String  tipo = "";
			String  sub = "";
			String  emp = "";
			String  motivo = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!emp.equalsIgnoreCase(cdo.getColValue("em_nombre_empleado")))
			{
			 if (!fg.equals("borrador"))
			{
			if (i!=0) {
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols("OBSERVACIONES : ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,2);
						pc.addBorderCols("EMPLEADO",1,3,0.0f,0.5f,0.0f,0.0f,0.0f);
						pc.addCols(" ",0,2);
						pc.addBorderCols("JEFE DE DEPARTAMENTO",1,7,0.0f,0.5f,0.0f,0.0f,0.0f);
						pc.addCols(" ",0,1);

				  pc.flushTableBody(true);
				  pc.addNewPage();


				} //pc.addNewPage();

				} else {
				pc.addCols(" ",0,dHeader.size());
				pc.addCols(" ",0,dHeader.size());
				}
			pc.setFont(7, 1);
			pc.addCols("   [ "+cdo.getColValue("num_empleado")+" ]  "+cdo.getColValue("em_nombre_empleado"),0,dHeader.size());
			}
		pc.setFont(6, 0);
		pc.setVAlignment(0);

			pc.addCols(" ",0,2);
			pc.addCols(" "+cdo.getColValue("adef_fecha"),0,1);
			pc.addCols(" "+cdo.getColValue("adef_ta_hent"),2,1);
			pc.addCols(" / "+cdo.getColValue("adef_ta_hsal"),0,1);
			pc.addCols(" "+cdo.getColValue("tiempo_horas"),1,1);
			pc.addCols(" "+cdo.getColValue("tiempo_minutos"),1,1);
			motivo = cdo.getColValue("adef_motivo");

			if(motivo.equals("5") || motivo.equals("19") || motivo.equals("49") || motivo.equals("13") || motivo.equals("54")
			|| motivo.equals("36") || motivo.equals("37") || motivo.equals("53") || motivo.equals("21")
			|| motivo.equals("39") || motivo.equals("9") || motivo.equals("40") || motivo.equals("38") || motivo.equals("43")) pc.addCols(" ",1,1);
			 else 	pc.addCols(" X ",1,1);
			if(motivo.equals("5")) pc.addCols(" X ",1,1);
			 else pc.addCols(" ",1,1);
			if(motivo.equals("19") || motivo.equals("40")) pc.addCols(" X ",1,1);
			 else pc.addCols(" ",1,1);
			if(motivo.equals("42") || motivo.equals("38")) pc.addCols(" X ",1,1);
			 else pc.addCols(" ",1,1);
			if(motivo.equals("13") || motivo.equals("43") || motivo.equals("35") || motivo.equals("54")) pc.addCols(" X ",1,1);
			 else pc.addCols(" ",1,1);
			if(motivo.equals("39")) pc.addCols(" X ",1,1);
			 else pc.addCols(" ",1,1);
			if(motivo.equals("9")) pc.addCols(" X ",1,1);
			 else pc.addCols(" ",1,1);
			pc.addCols(" "+cdo.getColValue("dsp_devolucion"),0,1);


	tipo=cdo.getColValue("ue_descripcion");
		sub=cdo.getColValue("quincena");
		  emp=cdo.getColValue("em_nombre_empleado");

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {

	 	pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		 if (!fg.equals("borrador"))
			{
	pc.addCols("OBSERVACIONES : ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,2);
	pc.addBorderCols("EMPLEADO",1,3,0.0f,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,2);
	pc.addBorderCols("JEFE DE DEPARTAMENTO",1,7,0.0f,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,1);
	}
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>