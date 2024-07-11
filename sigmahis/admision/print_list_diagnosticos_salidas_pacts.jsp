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
<!-- Reporte: "Informe de Salidas de Pacientes con su Diagnóstico"  -->
<!-- Reporte: SAL8001844                      -->
<!-- Fecha: 10/02/2010                        -->
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
CommonDataObject cdo  = new CommonDataObject();
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

if (categoria 			== null) categoria       = "";
if (centroServicio 	== null) centroServicio  = "";
if (codAseguradora 	== null) codAseguradora  = "";
if (categoriaDiag 	== null) categoriaDiag   = "";
if (fechaini 				== null) fechaini 			 = "";
if (fechafin 				== null) fechafin 			 = "";
if (sala 						== null) sala 					 = "";
if (horaini == null) horaini = "";
if (horafin == null) horafin = "";
if (medico == null) medico = "";

//--------------Parámetros--------------------//
sbFilter.append(" and ad.compania = ");
sbFilter.append(compania);
if (!categoria.trim().equals("")) { sbFilter.append(" and ad.categoria = "); sbFilter.append(categoria); }
if (!centroServicio.trim().equals("")) { sbFilter.append(" and  ad.centro_servicio = "); sbFilter.append(centroServicio); }
if (!categoriaDiag.trim().equals("")) { sbFilter.append(" and ad.categoria = "); sbFilter.append(categoriaDiag); }
if (!codAseguradora.trim().equals("")) { sbFilter.append(" and ab.empresa = "); sbFilter.append(codAseguradora); }
if (!fechaini.trim().equals("")) { sbFilter.append(" and trunc(ad.fecha_ingreso) >= to_date('"); sbFilter.append(fechaini); sbFilter.append("', 'dd/mm/yyyy')"); }
if (!fechafin.trim().equals("")) { sbFilter.append(" and trunc(ad.fecha_ingreso) <= to_date('"); sbFilter.append(fechafin); sbFilter.append("', 'dd/mm/yyyy')"); }
if (!horaini.trim().equals("")) { sbFilter.append(" and to_date(to_char(ad.am_pm,'hh12:mi pm'),'hh12:mi pm') >= to_date('"); sbFilter.append(horaini); sbFilter.append("','hh12:mi pm')"); }
if (!horafin.trim().equals("")) { sbFilter.append(" and to_date(to_char(ad.am_pm,'hh12:mi pm'),'hh12:mi pm') <= to_date('"); sbFilter.append(horafin); sbFilter.append("','hh12:mi pm')"); }

if (!medico.trim().equals("")){
  sbFilter.append(" and ad.medico = '");
  sbFilter.append(medico);
  sbFilter.append("'");
}

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Salidas de Pacientes con su Diagnósticos--------------------//
sql = " select distinct x1.codPac, x1.estado, x1.codAdmision, x1.aseguradora, x1.tipo_admision, x1.fechaNac, x1.diasH, x1.cedula, x1.nombrePaciente, x1.codMedico, x1.nombreMedico, x1.fechaIngreso, x1.fechaEgreso, x1.pacId , getDiagnosticos(x1.pac_id, x1.codAdmision, 'I') diagIngreso, getDiagnosticos(x1.pac_id, x1.codAdmision, 'S') diagSalida   from ( SELECT ad.codigo_paciente AS codPac, ad.estado, ad.pac_id as pac_id,  ad.secuencia AS codAdmision, ad.aseguradora, ad.tipo_admision,  DECODE (ad.fecha_egreso, NULL, ROUND (SYSDATE - ad.fecha_ingreso), ROUND (ad.fecha_egreso - ad.fecha_ingreso)) AS diasH,  DECODE (pa.provincia            ||'-'|| pa.sigla|| '-'|| pa.tomo|| '-'|| pa.asiento|| '-'|| pa.d_cedula,NULL, pa.pasaporte,  pa.provincia|| '-'|| pa.sigla|| '-'|| pa.tomo|| '-'|| pa.asiento|| '-'|| pa.d_cedula) AS cedula, pa.primer_apellido||', '||  pa.primer_nombre  AS nombrePaciente, TO_CHAR (ad.fecha_nacimiento, 'dd-mm-yyyy') AS fechaNac,  ad.medico AS codMedico,  md.primer_nombre || ' ' || md.primer_apellido AS nombreMedico,  TO_CHAR (ad.fecha_ingreso, 'dd-mm-yyyy')||' '||to_char(ad.am_pm,'hh12:mi pm') AS fechaIngreso,  TO_CHAR (ad.fecha_egreso, 'dd-mm-yyyy') AS fechaEgreso, ad.pac_id AS pacId  FROM tbl_adm_paciente pa, tbl_adm_admision ad, tbl_adm_medico md, tbl_adm_empresa emp, tbl_adm_beneficios_x_admision ab  WHERE (ad.fecha_nacimiento = pa.fecha_nacimiento  AND ad.codigo_paciente = pa.codigo)  AND (ad.medico = md.codigo)  AND (ad.aseguradora = emp.codigo)  AND ( ad.fecha_nacimiento = ab.fecha_nacimiento  AND ad.codigo_paciente = ab.paciente   AND ad.secuencia = ab.admision)  AND (ab.empresa = emp.codigo(+))  AND (ab.prioridad(+) = 1 "+sbFilter+" AND NVL (ab.estado(+), 'A') = 'A')  AND  ad.estado IN ('A', 'I', 'E') ) x1  order by x1.nombrePaciente ";

cdo = SQLMgr.getData(sql);

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String subtitle = "SALIDAS DE PACIENTES Y SUS DIAGNÓSTICOS";
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
    dHeader.addElement(".15");
	dHeader.addElement(".06");
    dHeader.addElement(".09");
    dHeader.addElement(".06");
	dHeader.addElement(".22");
	dHeader.addElement(".06");
	dHeader.addElement(".20");
	dHeader.addElement(".06");
	dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7, 1);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID / ADMISION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("IDENTIFICACION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA NAC.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIAGNOSTICO DE ADM.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA INGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIAGNOSTICO DE SALIDA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA EGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MEDICO",1,1,cHeight * 2,Color.lightGray);

	pc.setTableHeader(2);

	int pac = 0;
	String varDiagSalida = " ", pacId = " ";
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		pc.setFont(7, 0);

		  pc.addBorderCols(" "+cdo.getColValue("nombrePaciente"),0,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(cdo.getColValue("pacId")+"-"+(cdo.getColValue("codAdmision")), 0,1, 0.0f, 0.5f, 0.5f, 0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("cedula"),0,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("fechaNac"),0,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("diagIngreso"),0,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("fechaIngreso"),1,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("diagSalida"),0,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("fechaEgreso"),1,1,0.0f,0.5f,0.5f,0.5f);
		  pc.addBorderCols(" "+cdo.getColValue("nombreMedico"),0,1,0.0f,0.5f,0.5f,0.5f);
		  pac++;
			pacId=cdo.getColValue("pacId");
	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{ //Totales Finales
		    pc.setFont(8, 1,Color.black);
			pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
			pc.addCols("  CANT. TOTAL DE PACIENTES:    "+pac,0,dHeader.size(),Color.lightGray);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

