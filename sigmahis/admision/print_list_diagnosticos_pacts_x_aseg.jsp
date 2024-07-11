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
<!-- Reporte: "Informe de Diagnósticos de Pacientes x Aseguradora"  -->
<!-- Reporte: ADM_10013                       -->
<!-- Fecha: 03/02/2010                        -->
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
String sql = "";
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sala = request.getParameter("sala");

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String categoriaDiag   = request.getParameter("categoriaDiag");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String horaini        = request.getParameter("horaini");
String horafin        = request.getParameter("horafin");
String medico        = request.getParameter("medico");

if (categoria == null) categoria       = "";
if (centroServicio 	== null) centroServicio  = "";
if (codAseguradora 	== null) codAseguradora  = "";
if (categoriaDiag 	== null) categoriaDiag   = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (sala == null) sala 	= "";
if (horaini == null) horaini = "";
if (horafin == null) horafin = "";
if (medico == null) medico = "";

//--------------Parámetros--------------------//
// filtro por compañia
sbFilter.append(" and aa.compania = ");
sbFilter.append(compania);
// filtro por categoria de admision
if (!categoria.trim().equals("")) { sbFilter.append(" and aa.categoria = "); sbFilter.append(categoria); }
// filtro por centro de servicio
if (!centroServicio.trim().equals("")) { sbFilter.append(" and  aa.centro_servicio = "); sbFilter.append(centroServicio); }
// filtro por categoria de diagnostico
if (!categoriaDiag.trim().equals("")) { sbFilter.append(" and d.categoria = "); sbFilter.append(categoriaDiag); }
// filtro por aseguradora
if (!codAseguradora.trim().equals("")) { sbFilter.append(" and ab.empresa = "); sbFilter.append(codAseguradora); }
// filtro por rango de fecha de ingreso
if (!fechaini.trim().equals("")) { sbFilter.append(" and trunc(aa.fecha_ingreso) >= to_date('"); sbFilter.append(fechaini); sbFilter.append("', 'dd/mm/yyyy')"); }
if (!fechafin.trim().equals("")) { sbFilter.append(" and trunc(aa.fecha_ingreso) <= to_date('"); sbFilter.append(fechafin); sbFilter.append("', 'dd/mm/yyyy')"); }
if (!horaini.trim().equals("")) { sbFilter.append(" and to_date(to_char(aa.am_pm,'hh12:mi pm'),'hh12:mi pm') >= to_date('"); sbFilter.append(horaini); sbFilter.append("','hh12:mi pm')"); }
if (!horafin.trim().equals("")) { sbFilter.append(" and to_date(to_char(aa.am_pm,'hh12:mi pm'),'hh12:mi pm') <= to_date('"); sbFilter.append(horafin); sbFilter.append("','hh12:mi pm')"); }

if (!medico.trim().equals("")){
  sbFilter.append(" and aa.medico = '");
  sbFilter.append(medico);
  sbFilter.append("'");
}

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos Diagnósticos de Pacientes x Aseguradora-------------------------//
sql =
" select (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||aa.secuencia||')') as codigoPaciente,  pac.primer_apellido||' '||pac.segundo_apellido||' '||pac.apellido_de_casada||' '||pac.primer_nombre||' '||pac.segundo_nombre||' ( '||pac.id_paciente||' )' as nombrePaciente, pac.sexo as sexo, aa.medico codMedico,  med.primer_nombre||' '||med.primer_apellido nombreMedico, pac.pac_id as pacId,  nvl(trunc(months_between(sysdate,nvl(pac.f_nac,aa.fecha_nacimiento))/12),0) as edadPac,  getHabitacion(aa.compania, aa.pac_id, aa.secuencia) habitacion,  decode(diag.tipo,'I','INGRESO: '||diag.diagnostico||' - '||decode(d.observacion,null,d.nombre,d.observacion) ,'S','SALIDA: '||diag.diagnostico||' - '||decode(d.observacion,null,d.nombre,d.observacion)) as diagnostico, diag.orden_diag as ordenDiag,  aa.fecha_nacimiento, aa.codigo_paciente, aa.secuencia as secuenciaAdmision, pac.lugar_trabajo as direccionTrabajo,  pac.residencia_direccion as direccionResidencia, pac.telefono as telefonos,  aa.usuario_creacion as usuarioCrea, aa.categoria as codCategoria, aca.descripcion as descripcionCategoria,  ab.empresa as codAseguradora, emp.nombre as descAseguradora, aa.estado,  aa.centro_servicio as areaAtencion, cds.descripcion as descripcionCentro,  aa.fecha_creacion, aa.compania, to_char(aa.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(aa.am_pm,'hh12:mi pm') as fechaIngreso, trunc(nvl(aa.fecha_egreso,sysdate))-trunc(aa.fecha_ingreso) as diasEst from tbl_adm_admision aa, vw_adm_paciente pac, tbl_adm_beneficios_x_admision ab, tbl_adm_tipo_admision_cia t,  tbl_adm_categoria_admision aca, tbl_adm_empresa emp, tbl_cds_centro_servicio cds, tbl_adm_medico med  ,tbl_adm_diagnostico_x_admision diag, tbl_cds_diagnostico d  where  (aa.fecha_nacimiento = pac.fecha_nacimiento and aa.codigo_paciente = pac.codigo) and  (aa.categoria = t.categoria and aa.tipo_admision = t.codigo)   and  (aa.centro_servicio = cds.codigo) and (aa.medico = med.codigo) and  (aa.pac_id = ab.pac_id(+) and aa.secuencia = ab.admision(+)    and  ab.prioridad(+) = 1 and nvl(ab.estado(+),'A') = 'A' and  ab.empresa = emp.codigo(+)) and  t.categoria = aca.codigo and aa.estado  in ('A','E','I') "+sbFilter+" and(diag.pac_id(+) = aa.pac_id and diag.admision(+) = aa.secuencia and d.codigo(+) = diag.diagnostico)  order by descripcionCentro,areaAtencion, aa.categoria, emp.nombre, pac.primer_nombre,pac.segundo_nombre,pac.primer_apellido, aa.fecha_nacimiento,aa.codigo_paciente,aa.secuencia, diagnostico,ordenDiag ";
al = SQLMgr.getDataList(sql);

String showHideTrabajo = "Y"; 
CommonDataObject cdoSH = SQLMgr.getData("select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'SHOW_HIDE_TRABAJO') as showHideTrabajo from dual ");
showHideTrabajo = cdoSH.getColValue("showHideTrabajo")==null?"Y":cdoSH.getColValue("showHideTrabajo");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month =  fecha.substring(3, 5);;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	float height = 72 * 14f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "DIAGNOSTICOS DE PACIENTES POR ASEGURADORA";
	String xtraSubtitle = "DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".19");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".08");
		dHeader.addElement(showHideTrabajo.equals("Y")?".17":".26");
		dHeader.addElement(".18"); //MEDICO
		
		if(showHideTrabajo.equals("Y"))dHeader.addElement(".09"); // trabajo
		
		dHeader.addElement(".07"); //6
		dHeader.addElement(".04"); //3
		dHeader.addElement(".04");

	String groupBy = "", groupBy2 = "", groupBy3 = "";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("SEXO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EDAD",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("HABIT.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID/ ADMISION.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIAGNOSTICO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MEDICO",1,1,cHeight * 2,Color.lightGray);
		if(showHideTrabajo.equals("Y")) pc.addBorderCols("TRABAJO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F.INGRESO",1,1,cHeight * 2,Color.lightGray);
    	pc.addBorderCols("DIAS EST.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("USER",1,1,cHeight * 2,Color.lightGray);

	pc.setTableHeader(2);

	int pxs = 0;
	int pxc = 0;
	int pxcat = 0;
	int pcant = 0;
	String pacId = "", admision = "";
	for (int i=0; i<al.size(); i++)
	{
         cdo = (CommonDataObject) al.get(i);

		 // Inicio --- Agrupamiento x Aseguradora - Categoria - Centro
	if (!groupBy2.equalsIgnoreCase("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora")) && groupBy3.equalsIgnoreCase("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria")) && groupBy.equalsIgnoreCase("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro")))
		{// groupBy2
			   if (i != 0)
			      {// i - 2
				    pc.setFont(8, 1,Color.red);
				    pc.addCols("                      TOTAL DE PACIENTES X ASEGURADORA: "+pxs,0,dHeader.size(),cHeight);
					pc.addCols(" ",0,dHeader.size(),cHeight);
				    pxs = 0;

				    pc.setFont(8, 1,Color.blue);
				    pc.addCols("ASEG:",0,1,cHeight);
		 pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
				 }// i - 2
		     }// groupBy2
	 // Fin --- Agrupamiento x Aseguradora

	// Inicio --- Agrupamiento x Categoria y Centro
	 else if (!groupBy3.equalsIgnoreCase("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria"))&&groupBy.equalsIgnoreCase("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro")))
		  { // groupBy3
			if (i!=0)
			 { // i - 1
			   pc.setFont(8, 1,Color.red);
			   pc.addCols("                     TOTAL DE PACIENTES X ASEGURADORA: "+pxs,0,dHeader.size(),cHeight);
			   pc.addCols("                     TOTAL DE PACIENTES X CATEGORIA:        "+  pxcat,0,dHeader.size(),cHeight);
			   pxs   = 0;
			   pxcat = 0;

			   pc.setFont(8, 1,Color.blue);
			   pc.addCols("CATEGORIA:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria"),0,dHeader.size(),cHeight);
		       pc.addCols("ASEG:",0,1,cHeight);
		 pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
			 } // i - 1
		  } // groupBy3
	// Fin --- Agrupamiento x Categoria y Centro

	// Inicio --- Agrupamiento x Centro
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro")))
		   { // groupBy
			   if (i != 0)
			      {// i - 3
				    pc.setFont(8, 1,Color.red);
					pc.addCols("                     TOTAL DE PACIENTES X ASEGURADORA: "+pxs,0,dHeader.size(),cHeight);
			        pc.addCols("                     TOTAL DE PACIENTES X CATEGORIA:        "+  pxcat,0,dHeader.size(),cHeight);
				    pc.addCols("                     TOTAL DE PACIENTES X AREA:                   "+ pxc,0,dHeader.size(),cHeight);
					pc.addCols(" ",0,dHeader.size(),cHeight);
					pxs   = 0;
					pxcat = 0;
					pxc   = 0;
	               }// i - 3

				    pc.setFont(8, 1,Color.blue);
				    pc.addCols("AREA:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro"),0,dHeader.size(),cHeight);
		pc.addCols("CAT:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria"),0,dHeader.size(),cHeight);
		pc.addCols("ASEG:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
		  }// groupBy
	// Fin --- Agrupamiento x Centro

		pc.setFont(7, 0);
		//if (!pacId.trim().equals(cdo.getColValue("pacId")) && !admision.trim().equals(cdo.getColValue("secuenciaAdmision")))

		if ((!pacId.trim().equals(cdo.getColValue("pacId")) && !admision.trim().equals(cdo.getColValue("secuenciaAdmision")))||
		(pacId.trim().equals(cdo.getColValue("pacId")) && !admision.trim().equals(cdo.getColValue("secuenciaAdmision"))) ||
		(!pacId.trim().equals(cdo.getColValue("pacId")) && admision.trim().equals(cdo.getColValue("secuenciaAdmision"))) )
		{
		pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);//
		pc.addCols(" "+cdo.getColValue("sexo"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("edadPac"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);
		pc.addCols(cdo.getColValue("pacId")+"-"+(cdo.getColValue("secuenciaAdmision")),0,1);
		pc.addCols(" "+cdo.getColValue("diagnostico"),0,1);
        pc.addCols("["+cdo.getColValue("codMedico")+"] "+cdo.getColValue("nombreMedico"),0,1,cHeight);
		if(showHideTrabajo.equals("Y")) pc.addCols(" "+cdo.getColValue("direccionTrabajo"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1);
		pc.addCols(" "+cdo.getColValue("diasEst"),1,1);
		pc.addCols(" "+cdo.getColValue("usuarioCrea"),0,1,cHeight);
		pxs++;
		pxcat++;
		pxc++;
		pcant++;
		}else{
		pc.addCols(" ",0,1,cHeight);//
		pc.addCols(" ",1,1,cHeight);
		pc.addCols(" ",1,1,cHeight);
		pc.addCols(" ",1,1,cHeight);
		pc.addCols(" ",0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("diagnostico"),0,1);
        pc.addCols(" ",0,1,cHeight);
		if(showHideTrabajo.equals("Y"))pc.addCols(" ",0,1,cHeight);
		pc.addCols(" ",0,1,cHeight);
		pc.addCols(" ",0,1,cHeight);
		pc.addCols(" ",0,1,cHeight);
		}
		pacId    = cdo.getColValue("pacId");
		admision = cdo.getColValue("secuenciaAdmision");

groupBy = "[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro");
groupBy2 ="[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora");
groupBy3 = "[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria");

	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
			pc.setFont(8, 1,Color.red);
			pc.addCols("                      TOTAL DE PACIENTES X ASEGURADORA: "+pxs,0,dHeader.size(),cHeight);
			pc.addCols("                      TOTAL DE PACIENTES X CATEGORIA:        "+  pxcat,0,dHeader.size(),cHeight);
			pc.setFont(8, 1,Color.black);
			pc.addCols("                      TOTAL DE PACIENTES X AREA:                   "+ pxc,0,dHeader.size(),cHeight);
			pc.setFont(8, 1,Color.black);
			pc.addCols("                      CANT. TOTAL DE PACIENTES:                      "+pcant,0,dHeader.size(),cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

