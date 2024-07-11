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
<!-- Desarrollado por: José A. Acevedo C.     -->
<!-- Reporte: "Informe de Egresos de Pacientes sólo en CUARTO URGENCIAS"  -->
<!-- Reporte: ADM_10031_E, ADM_10031_E_URG    -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 8/01/2010                         -->

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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String sala = request.getParameter("sala");

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String tipoAdmision    = request.getParameter("tipoAdmision");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (categoria == null)     categoria       = "";
if (tipoAdmision == null)  tipoAdmision    = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (sala == null) sala = "";

String appendFilter1 = "", appendFilter2 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and aa.compania = "+compania;
  }
if (!categoria.equals(""))
   {
   appendFilter1 += " and aa.categoria = "+categoria;
   }
if (!centroServicio.equals(""))
   {
     if (!centroServicio.equals("0"))
	   {
        appendFilter1 += " and  aa.centro_servicio = "+centroServicio;
		}
	 //else { appendFilter1 += " and aa.centro_servicio in (10,22) "; }
    }
if (!tipoAdmision.equals(""))
   {
    appendFilter1 += " and aa.tipo_admision = "+tipoAdmision;
   }
if (!codAseguradora.equals(""))
   {
    appendFilter1 += " and ab.empresa = "+codAseguradora;
	}
if (!fechaini.equals(""))
   {
    appendFilter1 += " and to_date(to_char(aa.fecha_egreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and to_date(to_char(aa.fecha_egreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Egresos de Pacientes en CU---------------------------------//
sql =
 "select aa.centro_servicio as areaAtencion, "
+" cds.DESCRIPCION as descripcionCentro, "
+" ab.empresa as codAseguradora, emp.nombre descAseguradora,  aa.pac_id, aa.secuencia,"
+" to_char(aa.fecha_nacimiento,'dd-mm-yyyy') as fechaNacimiento, "
+" nvl(trunc(months_between(sysdate,nvl(pac.f_nac,aa.fecha_nacimiento))/12),0) edadPac, "
+" pac.primer_apellido||' '||pac.segundo_apellido||' '||pac.apellido_de_casada||' '||pac.primer_nombre||' '||pac.segundo_nombre as nombrePaciente, "
+" pac.telefono||' / '||pac.telefono_urgencia as telefonos, "
+" pac.direccion_de_urgencia as direccionUrgencia, aa.categoria as codCategoria, "
+" aca.descripcion as descripcionCategoria, "
+" aa.fecha_egreso||' '|| to_char(aa.am_pm,'HH12:MI AM') as fechaEgreso "
+" from tbl_adm_admision aa, tbl_adm_beneficios_x_admision ab, tbl_adm_paciente pac, "
+" tbl_adm_empresa emp, tbl_cds_centro_servicio cds, tbl_adm_categoria_admision aca "
+" where "
+" (aa.fecha_nacimiento = pac.fecha_nacimiento and aa.codigo_paciente = pac.codigo) and "
+" (aa.pac_id = ab.pac_id(+) and aa.secuencia = ab.admision(+) "
+" and ab.empresa = emp.codigo(+) and ab.prioridad(+) = 1 and nvl(ab.estado(+),'A') = 'A' ) "
+" and aa.categoria = aca.codigo and (aa.centro_servicio = cds.codigo) and "
+" aa.estado in ('A','I','E') "+appendFilter1
+" order by descripcionCentro, areaAtencion, emp.nombre, aa.categoria";

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
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String subtitle = "INFORME DE PACIENTES EGRESADOS - DATOS ";
	String xtraSubtitle = "EN EL PERIODO DEL "+fechaini+" Al "+fechafin;


	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

      PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".09"); //
		dHeader.addElement(".25");
		dHeader.addElement(".13");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".15"); //
		dHeader.addElement(".33");

	String groupBy = "", groupBy2 = "", groupBy3 = "";
	
pc.setVAlignment(0);		
	    //pc.setNoColumnFixWidth(dHeader);
		//pc.createTable();			
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("titulos",false,0,0.0f,593f);	
        //pc.setNoColumn(7);
   //pc.setNoColumnFixWidth(dHeader);
   		pc.setFont(7, 1);
		pc.addBorderCols("FECHA NAC.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F. EGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ADMISION / PID",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EDAD",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TELEFONOS",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIRECCION RESIDENCIAL",1,1,cHeight * 2,Color.lightGray);
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	int pxs = 0;
	int pxc = 0;
	int pxcat = 0;
	for (int i=0; i<al.size(); i++)
	{
         cdo = (CommonDataObject) al.get(i);

		 if (!groupBy3.equalsIgnoreCase("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria")))
		  { // groupBy3
			if (i!=0)
			 { // i - 1
			   pc.setFont(8, 1,Color.red);
			   pc.addCols("                      TOTAL DE PACIENTES X CATEGORIA:        "+  pxcat,0,dHeader.size(),cHeight);
			   pxcat = 0;

		   pc.setFont(8, 1,Color.blue);
		   pc.addCols("CATEGORIA:",0,1,cHeight);
		   pc.addCols("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria"),0,dHeader.size(),cHeight);
			 } // i - 1
		  } // groupBy3

		// Inicio --- Agrupamiento x Aseguradora
				if (!groupBy2.equalsIgnoreCase("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro")+" [ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora")))
		{// groupBy2
			   if (i != 0)
			      {// i - 2
				    pc.setFont(8, 1,Color.red);
					pc.addCols("                      TOTAL DE PACIENTES X CATEGORIA:        "+  pxs,0,dHeader.size(),cHeight);
				    pc.addCols("                      TOTAL DE PACIENTES X ASEGURADORA: "+pxs,0,dHeader.size(),cHeight);
					pc.addCols(" ",0,dHeader.size(),cHeight);
				    pxs = 0;

				          pc.setFont(8, 1,Color.blue);
				          pc.addCols("ASEG:",0,1,cHeight);
		 pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
		                  pc.addCols("CAT:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria"),0,dHeader.size(),cHeight);
		 pc.useTable("main");
				 //pc.addTableToCols("titulos",1,dHeader.size());
				 pc.addTableToCols("titulos",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
				 }// i - 2
		     }// groupBy2
	 // Fin --- Agrupamiento x Aseguradora

	// Inicio --- Agrupamiento x Centro
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro")))
		   { // groupBy
			   if (i != 0)
			      {// i - 3
				     pc.setFont(8, 1,Color.black);
				     pc.addCols("                      TOTAL DE PACIENTES X CENTRO: "+ pxc,0,dHeader.size(),cHeight);
				     pxc = 0;
	               }// i - 3

				    pc.setFont(8, 1,Color.blue);
				    pc.addCols("CENTRO:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro"),0,dHeader.size(),cHeight);
				    pc.addCols("ASEG:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
			        pc.addCols("CAT:",0,1,cHeight);
		pc.addCols("[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria"),0,dHeader.size(),cHeight);
		pc.useTable("main");
				 //pc.addTableToCols("titulos",1,dHeader.size());
				 pc.addTableToCols("titulos",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
		    }// groupBy
	// Fin --- Agrupamiento x Centro

		pc.setFont(7, 0);
		pc.addCols("    "+cdo.getColValue("fechaNacimiento"),0,1,cHeight);
		pc.addCols("    "+cdo.getColValue("nombrePaciente"),0,1,cHeight);
		pc.addCols("    "+cdo.getColValue("fechaEgreso"),1,1,cHeight);
		pc.addCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("secuencia")),0,1);
		pc.addCols("    "+cdo.getColValue("edadPac"),1,1,cHeight);
		pc.addCols("    "+cdo.getColValue("telefonos"),0,1,cHeight);
		pc.addCols("    "+cdo.getColValue("direccionUrgencia"),0,1,cHeight);

groupBy = "[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro");
groupBy2 = "[ "+cdo.getColValue("areaAtencion")+" ] "+cdo.getColValue("descripcionCentro")+" [ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora");
groupBy3 = "[ "+cdo.getColValue("codCategoria")+" ] "+cdo.getColValue("descripcionCategoria");

		pxs++;
		pxc++;
		pxcat++;
	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
	  //Totales Finales
			pc.setFont(8, 1,Color.red);
			pc.addCols("                      TOTAL DE PACIENTES X CATEGORIA:        "+  pxs,0,dHeader.size(),cHeight);
			pc.addCols("                      TOTAL DE PACIENTES X ASEGURADORA: "+pxs,0,dHeader.size(),cHeight);
			pc.setFont(8, 1,Color.black);
			pc.addCols("                      TOTAL DE PACIENTES X CENTRO: "+ pxc,0,dHeader.size(),cHeight);
			pc.setFont(8, 1,Color.black);
			pc.addCols("                      CANT. TOTAL DE PACIENTES:        "+ al.size(),0,dHeader.size(),cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
