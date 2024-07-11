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
<!-- Reporte: "Informe de Ingreso de Pacientes con sus Diagnósticos"  -->
<!-- Reporte: ADM10060, ADM_10039             -->
<!-- Fecha: 06/02/2010                        -->
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
String userName =UserDet.getUserName(); 
String sala = request.getParameter("sala");

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String categoriaDiag   = request.getParameter("categoriaDiag");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String horaini        = request.getParameter("horaini");
String horafin        = request.getParameter("horafin");
String medico        = request.getParameter("medico");

if (categoria == null)       categoria       = "";
if (centroServicio == null)  centroServicio  = "";
if (codAseguradora == null)  codAseguradora  = "";
if (categoriaDiag == null)   categoriaDiag   = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (sala == null) sala = "";
if (horaini == null) horaini = "";
if (horafin == null) horafin = "";
if (medico == null) medico = "";

//--------------Parámetros--------------------//
sbFilter.append(" and aa.compania = ");
sbFilter.append(compania);
if (!categoria.trim().equals("")) { sbFilter.append(" and aa.categoria = "); sbFilter.append(categoria); }
if (!centroServicio.trim().equals("")) { sbFilter.append(" and  aa.centro_servicio = "); sbFilter.append(centroServicio); }
if (!codAseguradora.trim().equals("")) { sbFilter.append(" and aba.empresa = "); sbFilter.append(codAseguradora); }
if (!categoriaDiag.trim().equals("")) { sbFilter.append(" and d.categoria = "); sbFilter.append(categoriaDiag); }
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
//--------------Query para obtener datos de Ingresos de Pacientes con su Diagnósticos--------------------//
sql =" select sysdate fechaActual,  (to_char(aa.fecha_nacimiento,'dd/mm/yyyy')||'('||aa.codigo_paciente||' - '||aa.secuencia||')') as codigoPaciente,  pac.nombre_paciente as nombrePaciente, cds.codigo codArea, cds.descripcion descArea, aa.pac_id as pacId, aa.secuencia as secuenciaAdmision,  '['||diag.tipo||'] '||decode(ds.COD_DIAG_SAL,null,diag.diagnostico,ds.COD_DIAG_SAL)||'  '||decode(d.observacion,null,d.nombre,d.observacion) descDiagnostico,  nvl(trunc(months_between(sysdate,nvl(pac.f_nac,aa.fecha_nacimiento))/12),0) as edadPac, pac.sexo as sexo,  to_char(aa.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(aa.am_pm,'hh12:mi pm') as fechaIngreso, pac.id_paciente as cedula  from tbl_adm_admision aa,vw_adm_paciente pac, tbl_cds_centro_servicio cds,  tbl_adm_diagnostico_x_admision diag, tbl_adm_beneficios_x_admision aba, tbl_cds_diagnostico d, tbl_adm_empresa ae, tbl_sal_adm_salida_datos ds  where  (diag.admision(+) = aa.secuencia) and (diag.pac_id(+) = aa.pac_id) and  (aa.codigo_paciente = pac.codigo) and (aa.fecha_nacimiento = pac.fecha_nacimiento) and  (aa.centro_servicio = cds.codigo) and  (diag.diagnostico  = d.codigo(+)) and  (aba.pac_id = aa.pac_id and  aba.admision = aa.secuencia and  aba.prioridad = 1 and  nvl(aba.estado,'A') = 'A' ) and  (ae.codigo = aba.empresa ) and  (ds.fec_nacimiento(+) = aa.fecha_nacimiento and ds.cod_paciente(+) = aa.codigo_paciente and  ds.secuencia(+)  = aa.secuencia) and  aa.estado in ('A','E','I') "+sbFilter+" order by cds.codigo, aa.fecha_ingreso, pac.nombre_paciente ";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
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
	String title = "ADMISION";
	String subtitle = "INGRESOS DE PACIENTES Y SUS DIAGNÓSTICOS";
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
	  dHeader.addElement(".07");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".09");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".36");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("FECHA ATENCION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID / ADMISION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("IDENTIFICACION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("SEXO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EDAD",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIAGNOSTICO",1,1,cHeight * 2,Color.lightGray);
	pc.setTableHeader(2);

	String groupBy = "", pacId= "", admision = "", groupByAdm = "",descArea="";
	int pacHombres = 0, pacMujeres = 0, pacSinGenero = 0;
	int pxc        = 0, pFinal = 0;
	for (int i=0; i<al.size(); i++)
	{
       cdo = (CommonDataObject) al.get(i);

	   // Inicio --- Agrupamiento x Centro
		  if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codArea")+" ] "+cdo.getColValue("descArea")))
		  { // groupBy
			   if (i != 0)
			   {// i - 3
				   pc.setFont(8, 1,Color.red);
	   			   pc.addBorderCols("   TOTAL DE PACIENTES EN  "+descArea+" . . . . .  "+ pxc,0,dHeader.size(), 0.0f, 0.5f, 0.0f, 0.0f);
				   pc.addCols(" ",0,dHeader.size(),cHeight);
				   pxc = 0;
	         	}// i - 3

				    pc.setFont(8, 1,Color.blue);
				    pc.addCols("AREA:",0,1,cHeight);
		        	pc.addCols("[ "+cdo.getColValue("codArea")+" ] "+cdo.getColValue("descArea"),0,dHeader.size(),cHeight);
		  }// groupBy
			// Fin --- Agrupamiento x Centro

	   // Inicio --- Agrupamiento x admision
		 if (!groupByAdm.equalsIgnoreCase(cdo.getColValue("codigoPaciente")))
		 { // groupByAdm
			   pc.setFont(7, 0);
			   pc.addBorderCols(" "+cdo.getColValue("fechaIngreso"),   1,1, 0.0f, 0.5f, 0.5f, 0.5f);
			   pc.addBorderCols(" "+cdo.getColValue("nombrePaciente"), 0,1, 0.0f, 0.5f, 0.5f, 0.5f);
			   pc.addBorderCols(cdo.getColValue("pacId")+"-"+(cdo.getColValue("secuenciaAdmision")), 0,1, 0.0f, 0.5f, 0.5f, 0.5f);
			   pc.addBorderCols(" "+cdo.getColValue("cedula"),         0,1, 0.0f, 0.5f, 0.5f, 0.5f);
			   pc.addBorderCols(" "+cdo.getColValue("sexo"),           1,1, 0.0f, 0.5f, 0.5f, 0.5f);
			   pc.addBorderCols(" "+cdo.getColValue("edadPac"),        1,1, 0.0f, 0.5f, 0.5f, 0.5f);
			   pc.addBorderCols(" "+cdo.getColValue("descDiagnostico"),0,1, 0.0f, 0.5f, 0.5f, 0.5f);
				
				pxc++;
				pFinal++;
				 
				if (cdo.getColValue("sexo").trim().equals("M")) pacHombres++;
				else if (cdo.getColValue("sexo").trim().equals("F"))pacMujeres++;
				else pacSinGenero++;

			}else{

			   pc.addBorderCols(" ",1,1, 0.0f, 0.0f, 0.5f, 0.5f);
			   pc.addBorderCols(" ",0,1, 0.0f, 0.0f, 0.5f, 0.5f);
			   pc.addBorderCols(" ",0,1, 0.0f, 0.0f, 0.5f, 0.5f);
			   pc.addBorderCols(" ",0,1, 0.0f, 0.0f, 0.5f, 0.5f);
			   pc.addBorderCols(" ",1,1, 0.0f, 0.0f, 0.5f, 0.5f);
			   pc.addBorderCols(" ",1,1, 0.0f, 0.0f, 0.5f, 0.5f);
			   pc.addBorderCols(" "+cdo.getColValue("descDiagnostico"),0,1, 0.0f, 0.0f, 0.5f, 0.5f);

		  	}// groupByAdm
			// Fin --- Agrupamiento x Admision

		  //pc.addBorderCols(" "+cdo.getColValue("descDiagnostico"),0,1,cHeight);

			groupByAdm = cdo.getColValue("codigoPaciente");
			groupBy = "[ "+cdo.getColValue("codArea")+" ] "+cdo.getColValue("descArea");
			descArea = cdo.getColValue("descArea");
	}//for i


	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
		// Total de pacientes del ultimo centro
	   pc.setFont(8, 1,Color.red);
	   pc.addBorderCols("   TOTAL DE PACIENTES EN  "+descArea+" . . . . .  "+ pxc,0,dHeader.size(), 0.0f, 0.5f, 0.0f, 0.0f);
	   pc.addCols(" ",0,dHeader.size(),cHeight);

	  //Totales Finales
		    pc.setFont(8, 1,Color.black);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addCols("  TOTAL DE HOMBRES: "+ pacHombres,0,dHeader.size(),Color.lightGray);
			pc.addCols("  TOTAL DE MUJERES:  "+ pacMujeres,0,dHeader.size(),Color.lightGray);
			pc.addCols("  TOTAL SIN GENERO:  "+ pacSinGenero,0,dHeader.size(),Color.lightGray);
			pc.addCols("  CANT. TOTAL DE PACIENTES:    "+ pFinal,0,dHeader.size(),Color.lightGray);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>


