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
REPORTE:  RESUMEN CLINICO
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
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();

CommonDataObject cdo1, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


sql = "select nvl(aa.medico,' ') as medico,m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, nvl(em.descripcion,' ') especialidad,pad.dolencia_principal dolencia, pad.observacion enfermedad  from tbl_adm_especialidad_medica em,tbl_adm_medico_especialidad me ,tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca, tbl_sal_padecimiento_admision pad where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and m.codigo = me.medico(+) and me.secuencia(+) =1 and me.especialidad=em.codigo(+)  and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and aa.secuencia = pad.secuencia(+) and aa.pac_id = pad.pac_id(+)";

cdo1 = SQLMgr.getData(sql);

	// DIAGNOSTICOS DE SALIDA.
	sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";
	al = SQLMgr.getDataList(sql);
	//MEDICAMENTOS RECETADOS
 	//sql = "select codigo, to_char(fecha,'dd/mm/yyyy') as fechaOrden, medicamento, dosis, observacion, via_admin via, cod_grupo_dosis codGrupoDosis, cod_frecuencia codFrecuencia , cada, tiempo, frecuencia from tbl_sal_medicacion_paciente where pac_id="+pacId+" and secuencia="+noAdmision;
	sql="select trunc(to_date(fecha_suspencion,'dd/mm/yyyy') -  to_date(fecha_creacion,'dd/mm/yyyy'),0) duracion,  to_char(fecha_inicio,'dd/mm/yyyy') as fechaSolicitud, nombre, ejecutado, tipo_orden, codigo, orden_med from tbl_sal_detalle_orden_med where pac_id="+pacId+" and secuencia= "+noAdmision+" and omitir_orden='N' and tipo_orden = 2  order by fecha_inicio desc ";
	al1 = SQLMgr.getDataList(sql);
	//PROCEDIMIENTOS
	sql="select to_char(FECHA,'dd/mm/yyyy') fecha, pac_id, admision, cod_procedimiento as procedimiento, nombre_procedimiento as nombre from vw_proced_invasivo where pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha";
	//sql="select a.procedimiento,  to_char(a.fecha_orden,'dd/mm/yyyy') as fecha, a.nombre, a.ejecutado, a.tipo_orden, a.codigo, a.orden_med from tbl_sal_detalle_orden_med a   where a.pac_id= "+pacId+" and a.secuencia= "+noAdmision+" and a.omitir_orden='N' and a.tipo_orden = 1 order by a.fecha_creacion desc ";
	//sql=" select distinct a.codigo as procedimiento,to_char(b.fecha_inf,'dd/mm/yyyy') as fecha, a.descripcion as nombre, b.codigo as codigo, b.observacion as observacion, to_char(b.fecha_cultivo,'dd/mm/yyyy') as fechaCultivo, b.total_dias as totalDias from tbl_sal_infeccion a, tbl_sal_detalle_infeccion b where a.codigo=b.codigo and b.pac_id="+pacId+" and b.secuencia= "+noAdmision+"  order by a.codigo asc";
	al4 = SQLMgr.getDataList(sql);

	//RESUMEN CLINICO

			// sql="select a.progreso_id, a.pac_id, a.admision,to_char(a.fecha,'dd/mm/yyyy') fecha, a.medico, a.observacion, am.primer_nombre||decode(am.segundo_nombre,'','',' '||am.segundo_nombre)||' '||am.primer_apellido|| decode(am.segundo_apellido, null,'',' '||am.segundo_apellido)||decode(am.sexo,'f', decode(am.apellido_de_casada,'','',' '||am.apellido_de_casada)) as nombre_medico from tbl_sal_progreso_clinico a,tbl_adm_medico am where a.pac_id(+)="+pacId+" and a.admision="+noAdmision+" and a.medico=am.codigo";

  sql="select to_char(fecha_creac,'dd/mm/yyyy') fecha,resumen observacion from tbl_sal_resumen_clinico where pac_id= "+pacId+" and admision= "+noAdmision+" ";
	al2 = SQLMgr.getDataList(sql);
	//INTERCONSULTORES
	sql="select distinct /*e.codigo,*/ e.medico, e.cod_especialidad, decode(AM.APELLIDO_DE_CASADA,null, AM.PRIMER_APELLIDO||' '||AM.SEGUNDO_APELLIDO, AM.APELLIDO_DE_CASADA)||' '|| AM.PRIMER_NOMBRE||' '||AM.SEGUNDO_NOMBRE as nombre_medico, nvl(esp.descripcion,' ') as descripcionEsp from  tbl_sal_diagnostico_inter_esp di, tbl_adm_medico AM, tbl_adm_especialidad_medica esp, tbl_sal_interconsultor_espec e Where e.pac_id="+pacId+" and e.secuencia="+noAdmision+"and e.medico=AM.codigo and esp.codigo(+)=e.cod_especialidad  and di.cod_interconsulta =   e.codigo and di.pac_id=e.pac_id and di.secuencia= e.secuencia  ORDER BY e.medico desc";

	al3 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String subtitle = "RESUMEN CLINICO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}
    
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".10");


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
		pc.addInnerTableToCols(dHeader.size());


			pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body

		pc.setFont(fontSize, 1);
		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("DOLENCIA PRINCIPAL",0,5,cHeight,Color.GRAY);
		//pc.addBorderCols("DOLENCIA PRINCIPAL:  ",0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo1.getColValue("dolencia"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

		pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);

		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("ENFERMEDAD ACTUAL",0,5,cHeight,Color.GRAY);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo1.getColValue("enfermedad"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

		pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);

		//pc.setFont(fontSize, 1,Color.gray);
		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("DIAGNOSTICOS DE SALIDA",0,5,cHeight,Color.GRAY);
		//pc.addBorderCols("DIAGNOSTICOS DE SALIDA",0,dHeader.size());
		pc.setFont(fontSize, 1);
		pc.addBorderCols("     CODIGO",0,1);
		pc.addBorderCols("NOMBRE",1,3);
		pc.addBorderCols("PRIORIDAD",1,1);

	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols("     "+cdo.getColValue("diagnostico"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("diagnosticoDesc"),0,3,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("orden_diag"),1,1,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());


	//PROCEDIMIENTOS REALIZADOS
	//pc.setFont(fontSize, 1,Color.gray);
	//pc.addBorderCols("PROCEDIMIENTOS REALIZADOS",0,dHeader.size());
	pc.setFont(8, 0,Color.WHITE);
	pc.addBorderCols("PROCEDIMIENTOS REALIZADOS",0,5,cHeight,Color.GRAY);

	pc.setFont(fontSize, 1);
	pc.addBorderCols("DESCRIPCION",0,3);
	pc.addBorderCols("FECHA",0,1);
	pc.addBorderCols("CODIGO",1,1);

	/*pc.addCols(" ",1,dHeader.size());
	pc.addCols(" ",1,dHeader.size());*/
	for (int i=0; i<al4.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al4.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols(cdo.getColValue("nombre"),0,3,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("fecha"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("procedimiento"),0,1,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());


	//MEDICAMENTOS RECETADOS
	//pc.setFont(fontSize, 1,Color.gray);
	//pc.addBorderCols("MEDICAMENTOS INDICADOS",0,dHeader.size());
	pc.setFont(8, 0,Color.WHITE);
	pc.addBorderCols("MEDICAMENTOS INDICADOS",0,5,cHeight,Color.GRAY);

	pc.setFont(fontSize, 1);
	pc.addBorderCols("FECHA",0,1);
	pc.addBorderCols("MEDICAMENTO",0,4);
	//pc.addBorderCols("DURACION",1,1);

	for (int i=0; i<al1.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al1.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols(cdo.getColValue("fechaSolicitud"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("nombre"),0,4,0.5f,0.0f,0.0f,0.0f);
		//pc.addBorderCols(cdo.getColValue("duracion"),0,1,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());
	//DIETAS A SEGUIR
	//pc.setFont(fontSize, 1,Color.gray);
	//pc.addBorderCols("RESUMEN CLINICO",0,dHeader.size());
	pc.setFont(8, 0,Color.WHITE);
	pc.addBorderCols("RESUMEN CLINICO",0,5,cHeight,Color.GRAY);

	pc.setFont(fontSize, 1);
	pc.addBorderCols("     FECHA ",0,1);
	//pc.addBorderCols("MEDICO",1,1);
	pc.addBorderCols("OBSERVACION",1,4);

	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al2.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols("     "+cdo.getColValue("fecha"),0,1,0.5f,0.0f,0.0f,0.0f);
		//pc.addBorderCols(cdo.getColValue("nombre_medico"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observacion"),0,4,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());

	pc.addCols("NOMBRE DEL MEDICO: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("nombre_medico"),0,4,0.10f,0.0f,0.0f,0.0f);

	pc.addCols("ESPECIALIDAD: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("especialidad"),0,2,0.10f,0.0f,0.0f,0.0f);
	pc.addCols("REGISTRO: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("medico"),0,1,0.10f,0.0f,0.0f,0.0f);

	pc.addCols("",0,dHeader.size());
	pc.addCols("",0,dHeader.size());

	//pc.setFont(fontSize, 1,Color.gray);
	//pc.addBorderCols("MEDICOS INTERCONSULTORES ",0,dHeader.size());
	pc.setFont(8, 0,Color.WHITE);
	pc.addBorderCols("MEDICOS INTERCONSULTORES",0,5,cHeight,Color.GRAY);


	pc.setFont(fontSize, 1);
	pc.addBorderCols("     NOMBRE",0,2);
	pc.addBorderCols("ESPECIALIDAD",0,3);

	for (int i=0; i<al3.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al3.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols("     "+cdo.getColValue("nombre_medico"),0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("descripcionEsp"),0,3,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size()); 
	
	pc.setFont(8, 0,Color.WHITE);
	pc.addBorderCols("RECOMENDACIONES (Plan de Salida)",0,5,cHeight,Color.GRAY);
	pc.setFont(fontSize, 1);
	
	CommonDataObject cdo = SQLMgr.getData("SELECT distinct RECOMENDACIONES FROM tbl_sal_salida_cuidado WHERE pac_id = "+pacId+" AND ADMISION = "+noAdmision);
	if (cdo == null) cdo = new CommonDataObject();
	pc.addCols(cdo.getColValue("recomendaciones", " "),0,dHeader.size());
	
	pc.addCols(" ",1,dHeader.size()); 


	pc.addCols("FECHA DEL RESUMEN: ",0,1);
	pc.addBorderCols(" ",0,1,0.10f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,3);
	pc.addCols("",0,dHeader.size());

	pc.addCols("FIRMA Y SELLO DEL MEDICO TRATANTE:",0,1);
	pc.addBorderCols(" ",0,2,0.10f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,2);
	//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>