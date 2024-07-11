<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: José A. Acevedo C.         -->
<!-- Reporte: "Censo - Detalle Diario de Ubicación de Pacientes x Sala"  -->
<!-- Reporte: CENSO_MENSUAL_DET                   -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 17/03/2010                            -->

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
	ArrayList alE = new ArrayList();
CommonDataObject cdoT = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sala        = request.getParameter("sala");
String aseguradora = request.getParameter("aseguradora");
String fechaini    = request.getParameter("fechaini");

int totIntensivo = 0, totHospPediat = 0, totNeonat = 0;
int totSalad = 0, totSalaef = 0, totSalagh = 0, totSalaij = 0, totcIntermedios =0, totFinal = 0;

String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (aseguradora == null) aseguradora = "";

String appendFilter1 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
	{
	 appendFilter1 += " and a.compania = "+compania;
	}
if (!aseguradora.equals(""))
 {
	 appendFilter1 += " and aba.empresa = "+aseguradora;
 }

if (!fechaini.equals(""))
	 {
	 appendFilter1 += " and ((a.fecha_ingreso >= to_date('"+fechaini+"', 'dd/mm/yyyy') and   a.fecha_ingreso <= last_day(to_date('"+fechaini+"','dd/mm/yyyy'))) or  (a.fecha_egreso >= to_date('"+fechaini+"', 'dd/mm/yyyy') and   a.fecha_egreso <= last_day(to_date('"+fechaini+"', 'dd/mm/yyyy')))) and  to_date(to_char(cama.fecha_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechaini+"', 'dd/mm/yyyy') and (to_date(to_char(nvl(cama.fecha_final, sysdate), 'dd/mm/yyyy'), 'dd/mm/yyyy') > to_date('"+fechaini+"','dd/mm/yyyy')  or cama.fecha_final is null  or (to_date(to_char(nvl(cama.fecha_final, sysdate), 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaini+"', 'dd/mm/yyyy')  and cama.fecha_final > to_date('"+fechaini+" 11:00:00 pm', 'dd/mm/yyyy hh12:mi:ss am'))) " ;
	 }

//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener Totales Finales----------------------------------------------//

String sqlVar = "", sqlTot = "";
	sql = "select codigo, descripcion from tbl_cds_centro_servicio where flag_cds = 'SAL'";
	alE = SQLMgr.getDataList(sql);
	sql = "select distinct ";

	for(int i = 0; i<alE.size();i++){
		CommonDataObject cdoD = (CommonDataObject) alE.get(i);
		
		sql += " nvl(decode(cds.codigo, "+cdoD.getColValue("codigo")+", cama.cama, '0'),'0') as centro_" + cdoD.getColValue("codigo");
		sql += ", ";
		sqlVar += "nvl(decode(cds.codigo, "+cdoD.getColValue("codigo")+", cama.cama, '0'),'0'),"; 
		//if(i!=0) sqlTot += ", ";
		//sqlTot += "nvl(sum(decode(cds.codigo, "+cdoD.getColValue("codigo")+", 1, 0)),0) as centro_" + cdoD.getColValue("codigo");
	}

//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener Datos del Censo x Sala----------------------------------------//
sql += "  initcap(p.apellido_de_casada||' '||p.primer_apellido||' '||p.segundo_apellido||', '||p.primer_nombre) as nombrePaciente, a.codigo_paciente, a.secuencia, a.pac_id as pacId,'[' || a.pac_id || '] [' || a.secuencia||']' as clavePac,  to_char(a.fecha_ingreso,'dd/mm/yyyy') as fIngreso, to_char(a.fecha_egreso,'dd/mm/yyyy') as fEgreso,  to_char(cama.fecha_inicio,'dd/mm/yyyy') as fInicio, to_char(cama.fecha_final,'dd/mm/yyyy') as fFinal,  cama.cama as cama, salh.unidad_admin as sala, cds.abreviatura abv,  aba.empresa as codAseguradora, ae.nombre descAseguradora  from tbl_adm_admision a, tbl_adm_paciente p,  tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae, tbl_cds_centro_servicio cds,  tbl_adm_cama_admision cama, tbl_sal_cama salc, tbl_sal_habitacion salh  where (a.pac_id = p.pac_id) and  (a.pac_id = cama.pac_id and a.secuencia = cama.admision) and a.estado in ('A','E','I') and  a.categoria in (1,5) and (cama.compania = salc.compania and cama.habitacion = salc.habitacion and cama.cama = salc.codigo) and  (salc.compania = salh.compania and salc.habitacion = salh.codigo) and (salh.codigo = cama.habitacion) and  (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and  nvl(aba.estado(+),'A') = 'A' and aba.prioridad(+) = 1 and aba.empresa = ae.codigo(+)) and  (cds.codigo = salh.unidad_admin)"+appendFilter1+" group by "+sqlVar+"   initcap(p.apellido_de_casada||' '||p.primer_apellido||' '||p.segundo_apellido||', '||p.primer_nombre),a.codigo_paciente, a.secuencia, a.pac_id, ' [' || a.pac_id || '] [' || a.secuencia||']',  to_char(a.fecha_ingreso,'dd/mm/yyyy'), to_char(a.fecha_egreso,'dd/mm/yyyy'),  to_char(cama.fecha_inicio,'dd/mm/yyyy'), to_char(cama.fecha_final,'dd/mm/yyyy'),  cama.cama, salh.unidad_admin, cds.abreviatura, aba.empresa, ae.nombre /* order by 23,24,10 */";

al = SQLMgr.getDataList(sql);

/*
sql = "select distinct " + sqlTot + " from tbl_adm_admision a, tbl_adm_paciente p,  tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae, tbl_cds_centro_servicio cds,  tbl_adm_cama_admision cama, tbl_sal_cama salc, tbl_sal_habitacion salh  where (a.pac_id = p.pac_id) and  (a.pac_id = cama.pac_id and a.secuencia = cama.admision) and a.estado in ('A','E','I') and  a.categoria in (1,5) and (cama.compania = salc.compania and cama.habitacion = salc.habitacion and cama.cama = salc.codigo) and  (salc.compania = salh.compania and salc.habitacion = salh.codigo) and (salh.codigo = cama.habitacion) and  (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and  nvl(aba.estado(+),'A') = 'A' and aba.prioridad(+) = 1 and aba.empresa = ae.codigo(+)) and (cds.codigo = salh.unidad_admin)"+appendFilter1;

cdoT = SQLMgr.getData(sql);
*/
if (request.getMethod().equalsIgnoreCase("GET"))
{
		String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String subtitle = "CENSO - DETALLE DE PACIENTES POR SALA";
	String xtraSubtitle = " ";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	double celdWidth = (1-0.20)/(alE.size()+1);
	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		for(int i=0;i<alE.size();i++){
		dHeader.addElement(""+celdWidth);
		}

	/*
	Vector dHeader = new Vector();
		dHeader.addElement(".22"); //
		dHeader.addElement(".09"); //
		dHeader.addElement(".09");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".08");
		*/

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	//extrae data para los totales Finales por Sala

	String groupBy = "", pacId = "";
	int pxs = 0, totlinea = 0 ;
	for (int i=0; i<al.size(); i++)
	{
			cdo = (CommonDataObject) al.get(i);

		//Inicio --Agrupamiento x Aseguradora
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora")))
		 {//groupBy
			 if (i != 0)
			{
			 pc.setFont(8, 1,Color.red);
			 pc.addCols("  TOTAL DE PACIENTES X ASEG: "+ pxs,0,dHeader.size(),cHeight);
			 pc.addCols(" ",0,dHeader.size(),cHeight);
			 pxs = 0;
			}
			pc.setFont(8, 1,Color.blue);
			pc.addCols("ASEG: [ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
			pc.addCols("Detalle de Pacientes por Sala el Día: "+fechaini,0,dHeader.size(),cHeight);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			pc.setFont(7, 1);
			pc.addBorderCols("PACIENTE",1,1,cHeight, Color.lightGray);
			for(int j = 0; j<alE.size();j++){
				CommonDataObject cdoD = (CommonDataObject) alE.get(j);
				pc.addBorderCols(cdoD.getColValue("descripcion"),1,1,cHeight, Color.lightGray);
			}

		 }//groupBy
		 //Fin --Agrupamiento x Aseguradora

		pc.setFont(7, 0);
		if(!pacId.trim().equals(cdo.getColValue("pacId"))){
			pc.addBorderCols(" "+cdo.getColValue("nombrePaciente")+" "+cdo.getColValue("clavePac"),0,1);
			pxs++;
		}else{
			pc.addCols(" ",0,1);
		}
		for(int j = 0; j<alE.size();j++){
			CommonDataObject cdoD = (CommonDataObject) alE.get(j);
			pc.addBorderCols(cdo.getColValue("centro_"+cdoD.getColValue("codigo")),1,1);
		}

		pacId = cdo.getColValue("pacId");

		groupBy = "[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora");

		}//for i

	if (al.size() == 0)
	{
		 pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
	 /*
		pc.setFont(8, 1);
		pc.addBorderCols("TOTAL DE PACIENTES:",0,1,cHeight);
		pc.addBorderCols(" "+(totIntensivo!=0?totIntensivo:""),1,1,cHeight);
		pc.addBorderCols(" "+(totHospPediat!=0?totHospPediat:""),1,1,cHeight);
		pc.addBorderCols(" "+(totNeonat!=0?totNeonat:""),1,1,cHeight);
		pc.addBorderCols(" "+(totSalad!=0?totSalad:""),1,1,cHeight);
		pc.addBorderCols(" "+(totSalaef!=0?totSalaef:""),1,1,cHeight);
		pc.addBorderCols(" "+(totSalagh!=0?totSalagh:""),1,1,cHeight);
		pc.addBorderCols(" "+(totSalaij!=0?totSalaij:""),1,1,cHeight);
		pc.addBorderCols(" "+(totcIntermedios!=0?totcIntermedios:""),1,1,cHeight);
		pc.addBorderCols(" "+totFinal,1,1,cHeight);
		*/
	}
	 pc.addTable();
	 pc.close();
	response.sendRedirect(redirectFile);
}//get
%>


