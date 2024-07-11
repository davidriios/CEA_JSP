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
<!-- Reporte: Estadistica Urgencias - x Tipo Cons.  -->
<!-- Reporte: fac71013_b                 -->
<!-- Clínica Hospital San Fernando       -->
<!-- Fecha: 03/08/2010                   -->

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
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();
ArrayList al6 = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania = (String) session.getAttribute("_companyId");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String tipoAdmision    = request.getParameter("tipoAdmision");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (tipoAdmision == null) tipoAdmision = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos ---------------------------------//

// total de casos atendidos
sql = "select s.ord, s.descripcion, s.cantidad from ( select 1 ord, 'TOTAL DE CASOS ATENDIDOS' descripcion, count(*) cantidad from temp_urg_estadist t, tbl_adm_admision a where a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+" ) s  order by s.ord ";
al0 = SQLMgr.getDataList(sql);

// distribucion por sexo
sql = "select decode(p.sexo,'F', 'Femenino', 'M', 'Masculino', 'No Especificados') sexo,  count(*) cantidad   from temp_urg_estadist t, tbl_adm_paciente p, tbl_adm_admision a  where t.fecha_nacimiento = p.fecha_nacimiento   and t.codigo_paciente = p.codigo   and a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+"  group by decode(p.sexo,'F', 'Femenino','M', 'Masculino','No Especificados') order by 1";
al2 = SQLMgr.getDataList(sql);

// distribucion por edad
sql = "select tipo, count(*) cantidad from (select  case when ((TRUNC(SYSDATE - t.fecha_nacimiento) / 365) >= 18) then 'Pacientes Adultos' else 'Menores de 18 años' end tipo from temp_urg_estadist t,  adm_paciente p, tbl_adm_admision a  where p.fecha_nacimiento = t.fecha_nacimiento  and  p.codigo   = t.codigo_paciente and a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+") e group by e.tipo";
al3 = SQLMgr.getDataList(sql);

// distribucion por aseg, provincia, distrito, corregimiento
sql = "select d.ord, d.tipoGrupo, d.descripcion, d.cantidad from (select 1 ord, 'DISTRIBUCION POR ASEGURADORAS' tipoGrupo, nvl(e.nombre,'SIN ESPECIFICAR') descripcion, count(*) cantidad  from  TEMP_URG_ESTADIST t, tbl_adm_empresa e, tbl_adm_admision a where t.aseguradora = e.codigo and a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+"  group by  t.aseguradora, e.nombre      union     select 2 ord,  'DISTRIBUCION POR PROVINCIA' tipoGrupo, nvl(pro.nombre,'SIN ESPECIFICAR') descripcion,  count(*) cantidad  FROM  tbl_adm_paciente  p,  temp_urg_estadist t, sfplanilla.provincia  pro, tbl_adm_admision a WHERE t.fecha_nacimiento = p.fecha_nacimiento  and  t.codigo_paciente   = p.codigo and p.residencia_pais   = pro.pais(+)  and  p.residencia_provincia  = pro.codigo(+) and a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+" group by pro.codigo, pro.nombre       union       select 3 ord, 'DISTRIBUCION POR DISTRITO' tipoGrupo, nvl(dis.nombre,'SIN ESPECIFICAR') descripcion,  count(*) cantidad  from  tbl_adm_paciente  p, temp_urg_estadist t,  sfplanilla.distrito dis, tbl_adm_admision a  where t.fecha_nacimiento = p.fecha_nacimiento  and t.codigo_paciente   = p.codigo  and p.residencia_pais   = dis.pais(+)  and  p.residencia_provincia  =  dis.provincia(+) and  p.residencia_distrito  = dis.codigo(+) and a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+" group by dis.nombre       union       select  4 ord, 'DISTRIBUCION POR CORREGIMIENTO' tipoGrupo, nvl(co.nombre,'SIN ESPECIFICAR') descripcion,  count(*) cantidad  from   tbl_adm_paciente  p,  temp_urg_estadist t,  sfplanilla.corregimiento co, tbl_adm_admision a  where t.fecha_nacimiento = p.fecha_nacimiento  and t.codigo_paciente = p.codigo  and p.residencia_pais         = co.pais(+)  and  p.residencia_provincia = co.provincia(+)  and  p.residencia_distrito  = co.distrito(+)   and  p.residencia_corregimiento = co.codigo(+)  and  co.provincia = '8'  and  co.distrito  in (8,10) and a.fecha_nacimiento = t.fecha_nacimiento and a.codigo_paciente = t.codigo_paciente and a.secuencia = t.secuencia and a.tipo_admision = "+tipoAdmision+" group by co.nombre) d  order by d.ord asc, d.cantidad desc";
al4 = SQLMgr.getDataList(sql);

// obtener la descripcion del tipo de admision
sql = "select descripcion dspTipoAdmision from tbl_adm_tipo_admision_cia where categoria = 2 and codigo = "+tipoAdmision+" and compania ="+(String)session.getAttribute("_companyId");
cdo = SQLMgr.getData(sql);

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
	String subtitle = "CUARTO DE URGENCIAS - ESTADISTICA MENSUAL";
	String xtraSubtitle = cdo.getColValue("dspTipoAdmision")+"  -  DESDE "+fechaini+"  HASTA  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15"); //
		dHeader.addElement(".50");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15"); //

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(1);

	pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,dHeader.size());

	//==========================================================================
	// seccion de CASOS ATENDIDOS
	int vTotal	= 0;
	for (int i=0; i<al0.size(); i++)
	{
      cdo0= (CommonDataObject) al0.get(i);

	    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
			pc.setFont(8, 1);
	    pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols(cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco
	}


	//==========================================================================
	// seccion de DISTRIBUCION DE CASOS ATENDIDOS X SEXO
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	for (int i=0; i<al2.size(); i++)
	{
      cdo0 = (CommonDataObject) al2.get(i);

	    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
		  if (i == 0)
		  {
				pc.setFont(8, 1);
				pc.addCols(" ",0,1);    // en blanco 1ra col
				pc.addCols("DISTRIBUCION POR SEXO DE CASOS ATENDIDOS",0,4);    // titulo de la seccion
		  }
			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("sexo"),0,1);    				// descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco
	}


	//==========================================================================
	// seccion de DISTRIBUCION DE CASOS ATENDIDOS X EDAD
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	for (int i=0; i<al3.size(); i++)
	{
      cdo0 = (CommonDataObject) al3.get(i);

	    //Inicio -->> imprime el titulo para el grupo
		  if (i == 0)
		  {
				pc.setFont(8, 1);
				pc.addCols(" ",0,1);    // en blanco 1ra col
				pc.addCols("DISTRIBUCION POR EDAD DE CASOS ATENDIDOS",0,4);    // titulo de la seccion
		   }
			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("tipo"),0,1);    // descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco
	}


	//==========================================================================
	// seccion de DISTRIBUCION DE CASOS ATENDIDOS X ASEG, PROVINCIA, DISTRITO, CORREG.
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	String groupBy = "";
	for (int i=0; i<al4.size(); i++)
	{
      cdo0 = (CommonDataObject) al4.get(i);

			if(!groupBy.equalsIgnoreCase(cdo0.getColValue("tipoGrupo")))
			    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
			{
					pc.setFont(8, 1);
					pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
					pc.addCols(" ",0,1);    // en blanco 1ra col
					pc.addCols(cdo0.getColValue("tipoGrupo"),0,4);    // titulo de la seccion
			}
			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco

	    groupBy = cdo0.getColValue("tipoGrupo");
	}



	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
