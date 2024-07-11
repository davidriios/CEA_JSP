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
REPORTE:  PLAN DE SALIDA
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

CommonDataObject cdo1, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String toBeMailed = request.getParameter("toBeMailed")==null?"":request.getParameter("toBeMailed");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
if (desc == null ) desc = "";
if (fg == null ) fg = "";

sql = "select  nvl(aa.medico,' ') as medico,m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, nvl(aa.contacto,' ')contacto ,nvl(aa.parentezco_contacto,' ')parentezco_contacto ,nvl(aa.telefono_contacto,' ') telefono_contacto,nvl(em.descripcion,' ') especialidad,nvl(m.telefono_trabajo,' ') telefonoMedico,nvl(m.lugar_de_trabajo,' ')direccionTrabajo, to_char(aa.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, aa.usuario_creacion  from tbl_adm_especialidad_medica em,tbl_adm_medico_especialidad me ,tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and m.codigo = me.medico(+) and me.secuencia(+) =1 and me.especialidad=em.codigo(+)  and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null";

cdo1 = SQLMgr.getData(sql);

	// DIAGNOSTICOS DE SALIDA.
	sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, to_char(a.fecha_modificacion,'hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";
	al = SQLMgr.getDataList(sql);
	//MEDICAMENTOS RECETADOS
	sql="select pac_id, admision, secuencia,medicamento, cantidad, indicacion, dosis, duracion, to_char(fecha_creacion,'dd/mm/yyyy') as fecha_creacion, usuario_creacion from tbl_sal_salida_medicamento where pac_id = "+pacId+" and admision = "+noAdmision;
	al1 = SQLMgr.getDataList(sql);

	String join = fg.equalsIgnoreCase("PSLO") ? "(+)" : "";

	//DIETAS
	sql= "select a.tipo_dieta ,a.subtipo_dieta, a.observacion, b.descripcion descSubTipo,b.observacion obserSubDieta,c.descripcion descDieta from tbl_sal_salida_dieta a,tbl_cds_subtipo_dieta b,tbl_cds_tipo_dieta c where a.tipo_dieta = b.cod_tipo_dieta"+join+" and a.subtipo_dieta = b.codigo"+join+" and b.cod_tipo_dieta = c.codigo"+join+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.codigo";
	al2 = SQLMgr.getDataList(sql);

	//CUIDADOS EN CASA
	sql= " select a.pac_id, a.admision, a.guia_id, decode(a.guia_id,-1,a.guia_desc,b.nombre) as descGuia, a.observacion, a.recomendaciones from tbl_sal_salida_cuidado a, tbl_sal_guia b where a.guia_id = b.id(+) and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.status = 'A' order by a.codigo";
	al3 = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	String fecha2 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String fecha = fecha2.substring(0,10);
	String date = fecha2.substring(10);
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
		cdoPacData.addColValue("is_landscape",""+isLandscape);
		}

	PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();
			dHeader.addElement(".20");
			dHeader.addElement(".20");
			dHeader.addElement(".20");
			dHeader.addElement(".15");
			dHeader.addElement(".25");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha2, dHeader.size());

		pc.setFont(fontSize, 1,Color.gray);

		pc.addCols("Fecha:  "+cdo1.getColValue("fecha_creacion"),0,1);
		pc.addCols("Hora: "+cdo1.getColValue("usuario_creacion"),0,4);
		pc.addCols(" ",0,dHeader.size());


		pc.addCols("Contacto en Casa:",0,1);
		pc.addCols(cdo1.getColValue("contacto"),0,1);
		pc.addCols("Tel:  "+cdo1.getColValue("telefono_contacto"),0,2);
		pc.addCols("Parentesco:   "+cdo1.getColValue("parentezco_contacto"),0,1);

		pc.addCols(" ",0,dHeader.size());
		pc.setTableHeader(5);

		pc.addBorderCols("DIAGNOSTICOS DE SALIDA",0,dHeader.size());
		pc.setFont(fontSize, 1);
		pc.addBorderCols("     CODIGO",0,1);
		pc.addBorderCols("USER - FECHA",1,1);
		pc.addBorderCols("NOMBRE",1,2);
		pc.addBorderCols("PRIORIDAD",1,1);

	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols("     "+cdo.getColValue("diagnostico"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("usuario_creacion")+" - "+cdo.getColValue("fecha_creacion"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("diagnosticoDesc"),0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("orden_diag"),1,1,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());
	//MEDICAMENTOS RECETADOS
	pc.setFont(fontSize, 1,Color.gray);
	pc.addBorderCols("MEDICAMENTOS RECETADOS",0,dHeader.size());

	pc.setFont(fontSize, 1);
	pc.addBorderCols("MEDICAMENTO",1,1);
	pc.addBorderCols("INDICACION",1,1);
	pc.addBorderCols("DOSIS",1,1);
	pc.addBorderCols("DURACION",1,1);
	pc.addBorderCols("USER - FECHA",1,1);

	for (int i=0; i<al1.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al1.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols(cdo.getColValue("medicamento")+(!cdo.getColValue("cantidad"," ").trim().equals("")?"   ##"+cdo.getColValue("cantidad"):""),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("indicacion"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("dosis"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("duracion"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("usuario_creacion")+" - "+cdo.getColValue("fecha_creacion"),0,1,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());
	//DIETAS A SEGUIR
	pc.setFont(fontSize, 1,Color.gray);
	pc.addBorderCols("DIETAS A SEGUIR",0,dHeader.size());

	pc.setFont(fontSize, 1);
	pc.addBorderCols("     CODIGO",0,1);
	pc.addBorderCols("DIETA",1,1);
	pc.addBorderCols("OBSERVACION",1,3);

	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al2.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols("     "+cdo.getColValue("descDieta","0"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("descSubTipo","0"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observacion"),0,3,0.5f,0.0f,0.0f,0.0f);
	}
	pc.addCols(" ",1,dHeader.size());

	pc.setFont(fontSize, 1,Color.gray);
	pc.addBorderCols("CUIDADOS EN CASA ",0,dHeader.size());

	pc.setFont(fontSize, 1);
	pc.addBorderCols("     CODIGO",0,1);
	pc.addBorderCols("DESCRIPCION",1,2);
	pc.addBorderCols("OBSERVACION",1,2);
	
	String recomendaciones = "";
	for (int i=0; i<al3.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al3.get(i);

		pc.setFont(fontSize, 0);
		pc.addBorderCols("     "+cdo.getColValue("guia_id"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("descGuia"),0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observacion"),0,2,0.5f,0.0f,0.0f,0.0f);
		
		recomendaciones = cdo.getColValue("recomendaciones"," ");
	}
	pc.addCols(" ",1,dHeader.size());
	
	pc.setFont(fontSize, 1,Color.gray);
	pc.addBorderCols("RECOMENDACIONES",0,dHeader.size());
	pc.setFont(fontSize, 1);
	pc.addBorderCols(recomendaciones,0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());

	pc.addCols("NOMBRE DEL MEDICO: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("nombre_medico"),0,2,0.10f,0.0f,0.0f,0.0f);
	pc.addCols("ESPECIALIDAD: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("especialidad"),0,1,0.10f,0.0f,0.0f,0.0f);

	pc.addCols("DIRECCION DEL CONSULTORIO: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("direccionTrabajo"),0,4,0.10f,0.0f,0.0f,0.0f);
	pc.addCols("TELEFONO: ",0,1);
	pc.addBorderCols(" "+cdo1.getColValue("telefonoMedico"),0,1,0.10f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,3);
	pc.addCols("FIRMA DEL PACIENTE O RESPONSABLE: ________________________________________",0,3);
	pc.addCols("FECHA: _______________________",0,2);
	pc.addCols("FIRMA DE LA ENFERMERA ORIENTADORA: ______________________________________________",0,dHeader.size());


if ( al.size() == 0 ){
		pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(toBeMailed.trim().equalsIgnoreCase("Y")) {
		pc.close();
		out.print(directory+folderName+"/"+year+"/"+month+"/"+fileName);
		isUnifiedExp = false;
}else
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>