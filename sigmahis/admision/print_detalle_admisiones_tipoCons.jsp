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
<!-- Desarrollado por: Tirza Monteza     -->
<!-- Reporte: Detalle admisiones x tipo consulta  -->
<!-- Reporte: adm_10038                   -->
<!-- Clínica Hospital San Fernando       -->
<!-- Fecha: 04/08/2010                   -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");/*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo0 = new CommonDataObject();

ArrayList al0 = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania = (String) session.getAttribute("_companyId");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos ---------------------------------//

// detalle de admisiones
sql = "select c.descripcion centroServicio, t.descripcion tipoAdmision, decode(p.apellido_de_casada,null,p.primer_apellido||' '||p.segundo_apellido, p.apellido_de_casada||' '||p.primer_apellido||' '||p.segundo_apellido)||', '||p.primer_nombre||' '||p.segundo_nombre as nombrePac, to_char(a.fecha_nacimiento,'dd-mm-yyyy')||' - '||a.codigo_paciente||' - '||a.secuencia admision, decode(p.f_nac, null, to_number(trunc( (sysdate - p.fecha_nacimiento) / 365) ) ,  to_number(trunc( (sysdate - p.f_nac) / 365 ) ) )  edad, to_char(p.f_nac,'dd-mm-yyyy')  fecha_corregida, case when ((TRUNC(SYSDATE - u.fecha_nacimiento) / 365) >= 18) then 'ADULTO' else 'MENOR' end as rangoEdad, a.usuario_creacion  from temp_urg_estadist u, tbl_adm_admision a, tbl_adm_tipo_admision_cia t, tbl_adm_paciente p, tbl_cds_centro_servicio c where a.fecha_nacimiento = u.fecha_nacimiento and  a.codigo_paciente  = u.codigo_paciente  and  a.secuencia  = u.secuencia  and  a.compania  = 1  and  a.categoria = t.categoria   and  a.tipo_admision = t.codigo   and  a.compania   = t.compania  and  a.centro_servicio = c.codigo   and  p.fecha_nacimiento = a.fecha_nacimiento  and  p.codigo   = a.codigo_paciente   order by 1,2,3";
al0 = SQLMgr.getDataList(sql);


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
	String subtitle = "CUARTO DE URGENCIAS - ADMISIONES POR TIPO DE CONSULTA";
	String xtraSubtitle = "DESDE "+fechaini+"  HASTA  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".50"); //
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10"); //


		pc.createTable("titulos",false);
		pc.setVAlignment(0);
		pc.setFont(8, 1);
		pc.addBorderCols("Nombre Paciente",1,1);
		pc.addBorderCols("Admisión",1,1);
		pc.addBorderCols("Edad",1,1);
		pc.addBorderCols("Creado Por",1,1);
		pc.addBorderCols("FechaNac. Corregida",1,1);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addTableToCols("titulos",0,dHeader.size());

	pc.setTableHeader(2);

	//==========================================================================
	// DETALLE DE PACIENTES POR TIPO DE ATENC.
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	// totales por centro
	int vTotalAdxC	= 0;			// total adultos
	int vTotalMexC	= 0;			// total menores
	int vTotalxC		= 0;			// total general

	// totales x tipo
	// totales por centro
	int vTotalAdxT	= 0;			// total adultos
	int vTotalMexT	= 0;			// total menores
	int vTotalxT		= 0;			// total general

	// totales generales
	int vTotalAdxG	= 0;			// total adultos
	int vTotalMexG	= 0;			// total menores
	int vTotalxG		= 0;			// total general
	// group by
	String groupByCentro = "";
	String groupByTipo = "";

	for (int i=0; i<al0.size(); i++)
	{
      cdo0 = (CommonDataObject) al0.get(i);

			// GroupBy por Centro de Servicio
			if(!groupByCentro.equalsIgnoreCase(cdo0.getColValue("centroServicio")))
			{
				if (i!=0)
				{
					pc.setFont(8, 1);
					// totales por tipo
					pc.addCols("Total para "+groupByTipo,2,1);    // titulo de la seccion
					pc.addCols("Adultos: "+String.valueOf(vTotalAdxT),1,1);
					pc.addCols(" ",0,1);
					pc.addCols("Menores: "+String.valueOf(vTotalMexT),1,1);
					pc.addCols("Total: "+String.valueOf(vTotalxT),1,1);

					// totales por centro
					pc.addCols("Total para "+groupByCentro,2,1);    // titulo de la seccion
					pc.addCols("Adultos: "+String.valueOf(vTotalAdxC),1,1);
					pc.addCols(" ",0,1);
					pc.addCols("Menores: "+String.valueOf(vTotalMexC),1,1);
					pc.addCols("Total: "+String.valueOf(vTotalxC),1,1);

					vTotalAdxT	= 0;			// total adultos
					vTotalMexT	= 0;			// total menores
					vTotalxT		= 0;			// total general

					// totales generales
					vTotalAdxC	= 0;			// total adultos
					vTotalMexC	= 0;			// total menores
					vTotalxC		= 0;			// total general
				}

				pc.setFont(8, 1);
				pc.addCols(" ",0,dHeader.size());
				pc.addCols(cdo0.getColValue("centroServicio"),0,dHeader.size());
			}


			// groupBy por Tipo de Admision
			if(!groupByTipo.equalsIgnoreCase(cdo0.getColValue("tipoAdmision")))
			{
				if (i!=0 && vTotalxT !=0)
				{
					pc.setFont(8, 1);
					// totales por tipo
					pc.addCols("Total para "+groupByTipo,2,1);    // titulo de la seccion
					pc.addCols("Adultos: "+String.valueOf(vTotalAdxT),1,1);
					pc.addCols(" ",0,1);
					pc.addCols("Menores: "+String.valueOf(vTotalMexT),1,1);
					pc.addCols("Total: "+String.valueOf(vTotalxT),1,1);

					vTotalAdxT	= 0;			// total adultos
					vTotalMexT	= 0;			// total menores
					vTotalxT		= 0;			// total general

				}

				pc.setFont(8, 1);
				pc.addCols(" ",0,dHeader.size());
				pc.addCols(cdo0.getColValue("tipoAdmision"),0,dHeader.size());
			}

			// imprimir detalle de pacientes
			pc.setFont(8, 0);
	    pc.addCols(cdo0.getColValue("nombrePac"),0,1);
	    pc.addCols(cdo0.getColValue("admision"),0,1);
	    pc.addCols(cdo0.getColValue("edad"),1,1);
	    pc.addCols(cdo0.getColValue("usuario_creacion"),1,1);
	    pc.addCols(cdo0.getColValue("fecha_corregida"),1,1);

			// acumular valores
			if (cdo0.getColValue("rangoEdad").equals("ADULTO"))
			{
					vTotalAdxT++;
					vTotalAdxC++;
					vTotalAdxG++;
			} else
			{
					vTotalMexT++;
					vTotalMexC++;
					vTotalMexG++;
			}

			vTotalxT++;
			vTotalxC++;
			vTotalxG++;

	    groupByCentro = cdo0.getColValue("centroServicio");
	    groupByTipo = cdo0.getColValue("tipoAdmision");
	}

	if (al0.size() > 0)
	{
		pc.setFont(8, 1);
		// totales por tipo
		pc.addCols("Total para "+groupByTipo,2,1);    // titulo de la seccion
		pc.addCols("Adultos: "+String.valueOf(vTotalAdxT),2,1);
		pc.addCols(" ",0,1);
		pc.addCols("Menores: "+String.valueOf(vTotalMexT),2,1);
		pc.addCols("Total: "+String.valueOf(vTotalxT),2,1);


		// totales por centro
		pc.addCols("Total para "+groupByCentro,2,1);    // titulo de la seccion
		pc.addCols("Adultos: "+String.valueOf(vTotalAdxC),2,1);
		pc.addCols(" ",0,1);
		pc.addCols("Menores: "+String.valueOf(vTotalMexC),2,1);
		pc.addCols("Total: "+String.valueOf(vTotalxC),2,1);
	}

	// totales del reporte
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("* * *   T O T A L E S   P O R   R E P O R T E   * * *",1,dHeader.size());
	pc.addCols("Total de Pacientes menores de 18 años . . .",2,4);
	pc.addCols(String.valueOf(vTotalMexG),2,1);

	pc.addCols("Total de Adultos . . .",2,4);
	pc.addBorderCols(String.valueOf(vTotalAdxG),2,1,0.5f,0.0f,0.0f,0.0f);

	pc.addCols("Total de Admisiones . . .",2,4);
	pc.addCols(String.valueOf(vTotalxG),2,1);


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
