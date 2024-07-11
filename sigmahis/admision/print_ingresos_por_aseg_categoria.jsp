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
<!-- Desarrollado por: Tirza Monteza.                          -->
<!-- Reporte: "Ingresos de Pacientes por Aseguradors /Centro"  -->
<!-- Reporte: ADM_X_ASEG_MOD                                   -->
<!-- Clínica Hospital San Fernando                             -->
<!-- Fecha: 26/06/2010                                         -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();

String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String sala 					 = request.getParameter("sala");
String compania 			 = (String) session.getAttribute("_companyId");

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
   appendFilter1 += " and a.compania = "+compania;
  }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and a.centro_servicio = "+centroServicio;
	}
if (!fechaini.equals(""))
   {
    appendFilter1 += " and a.fecha_ingreso >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and a.fecha_ingreso <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   }
if (!categoria.equals(""))
   {
   appendFilter1 += " and a.categoria = "+categoria;
   }
if (!tipoAdmision.equals(""))
   {
    appendFilter1 += " and a.tipo_admision = "+tipoAdmision;
   }
if (!codAseguradora.equals(""))
    {
	 appendFilter1 += " and b.empresa = "+codAseguradora;
	}
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Ingresos de Pacientes---------------------------------//
sql = " SELECT ALL  e.NOMBRE desc_empresa, CAT.DESCRIPCION CATEGORIA, cds.DESCRIPCION desc_cds, "
    + " ' ['||a.SECUENCIA||']' adm, a.PAC_ID pac_id, "
		+ " to_char(a.FECHA_INGRESO,'dd/mm/yyyy') FECHA_INGRESO, a.fecha_ingreso as fing, a.DIAS_ESTIMADOS, a.DIAS_HOSPITALIZADOS, a.MEDICO cod_med, "
		+ " p.nombre_paciente  paciente, "
		+ " p.id_paciente cedula, "
		+ " DECODE(a.FECHA_EGRESO, NULL,ROUND(SYSDATE - a.FECHA_INGRESO), ROUND(a.FECHA_EGRESO - a.FECHA_INGRESO)) diasHosp "
	  + " FROM TBL_ADM_ADMISION a, TBL_CDS_CENTRO_SERVICIO cds,vw_adm_paciente p, TBL_ADM_BENEFICIOS_X_ADMISION b, TBL_ADM_EMPRESA e, TBL_ADM_CATEGORIA_ADMISION CAT "
		+ " WHERE a.CENTRO_SERVICIO = cds.CODIGO "
		+ " AND a.pac_id = p.pac_id " 
		+ " AND CAT.CODIGO = a.CATEGORIA "
		+ " AND b.PAC_ID = a.PAC_ID "
		+ " AND b.ADMISION = a.SECUENCIA "
		+ " AND b.PRIORIDAD = 1 and a.corte_cta is null "
		+ " AND NVL(b.ESTADO, 'A') = 'A' "
		+ " AND a.ESTADO IN ('A','E','I') "
		+ " AND e.CODIGO = b.EMPRESA "
		+ appendFilter1
		+ " ORDER BY 1, 2, 6, 3 ";

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
	String subtitle = "INGRESOS DE PACIENTES POR COMPAÑIA ASEGURADORA / CATEGORIA";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");

	Vector infoCol = new Vector();
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(2);

	pc.addBorderCols("Nombre del Paciente",1,8,cHeight*2,Color.lightGray);
	pc.addBorderCols("Días",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("PID / Admisión ",1,3,cHeight*2,Color.lightGray);
	pc.addBorderCols("Centro de Servicio",1,6,cHeight*2,Color.lightGray);
	pc.addBorderCols("F.Ingreso",1,2,cHeight*2,Color.lightGray);


	String groupByAseg	 = "";		// para agrupar por aseguradora
	String groupByCat = "";		// para agrupar por ccategoria
	int aCounter = 0;				// para la cantidad de pacientes por aseguradora
	int	cCounter = 0;				// para la cantidad de pacientes por centro
	int	tCounter = 0;				// para la cantidad total de pacientes
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		// Agrupar por Centro de admision
		if (!groupByAseg.trim().equalsIgnoreCase(cdo.getColValue("desc_empresa")))
		{
					pc.setFont(9, 1,Color.black);
					if (i != 0)  // imprime total de pactes por centro
					{
						pc.addCols("Total de Pacientes "+groupByCat+". . . . . . "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
						pc.addCols(" ",0,dHeader.size(),cHeight);

						pc.addCols(String.valueOf(aCounter)+"  Pacientes de "+groupByAseg,0,dHeader.size(),cHeight*2,Color.lightGray);
						pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					pc.addCols("Aseguradora :"+cdo.getColValue("desc_empresa"),0,dHeader.size(),cHeight*2);
					aCounter = 0;
					cCounter = 0;
					groupByCat = "";
					groupByAseg = "";
		}

		// Agrupar por Centro de admision
		if (!groupByCat.trim().equalsIgnoreCase(cdo.getColValue("CATEGORIA")))
		{
					pc.setFont(9, 1,Color.black);
					if (i != 0 && cCounter != 0)  // imprime total de pactes por centro
					{
						pc.addCols("Total de Pacientes "+groupByCat+":   "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					pc.addCols(cdo.getColValue("CATEGORIA"),0,dHeader.size(),cHeight*2);
					cCounter = 0;
		}

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("paciente"),0,8);
		pc.addCols(cdo.getColValue("diasHosp"),0,1);
		pc.addCols(cdo.getColValue("pac_id")+" - "+(cdo.getColValue("adm")),0,3);
		pc.addCols(cdo.getColValue("desc_cds"),0,6);
		pc.addCols(cdo.getColValue("FECHA_INGRESO"),1,2);

		aCounter++;
		cCounter++;
		tCounter++;

		groupByCat = cdo.getColValue("CATEGORIA");
		groupByAseg = cdo.getColValue("desc_empresa");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.setFont(9, 1,Color.black);
			pc.addCols("Total de Pacientes "+groupByCat+":   "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			pc.setFont(9, 1,Color.black);
			pc.addCols(String.valueOf(aCounter)+"  Pacientes de "+groupByAseg,0,dHeader.size(),cHeight*2);
			pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,dHeader.size(),cHeight);

	  //Totales Finales
		  pc.addCols(" ",0,dHeader.size(),cHeight);
		  pc.addCols(" TOTAL FINAL DE PACIENTES:   "+String.valueOf(tCounter),0,dHeader.size(),cHeight*2,Color.lightGray);
		  pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
