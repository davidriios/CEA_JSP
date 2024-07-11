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
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
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
String appendFilter1 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and a.compania = "+compania; 
  }
if (!categoria.equals(""))
   {
   appendFilter1 += " and a.categoria = "+categoria;
   }
if (!tipoAdmision.equals(""))
   {
    appendFilter1 += " and a.tipo_admision = "+tipoAdmision;
   }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and a.centro_servicio = "+centroServicio;
	}
if (!codAseguradora.equals(""))
    {
	 appendFilter1 += " and aba.empresa = "+codAseguradora;
	}
if (!fechaini.equals(""))
   {
    appendFilter1 += " and to_date(to_char(a.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and to_date(to_char(a.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   }
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Ingresos de Pacientes---------------------------------//
sql.append( "select all p.pac_id, p.nombre_paciente as nombrePaciente, p.id_paciente as cedula,a.codigo_paciente as cod_pac, a.secuencia as noAdmision, nvl(decode(a.corte_cta,null,to_char(a.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id)),' ')as fechaIngreso, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fIngreso, a.categoria as categoria, decode(a.categoria,1,'HOSP',3,'AMB.',2,'URG.',4,'OPD.') as descripcion_cat , a.tipo_admision as tipoAdmision, t.descripcion as descripcion_tipoadm, a.centro_servicio as centroServicio, cds.descripcion as descripcion_centro,  ae.codigo as codAseguradora, ae.nombre as descAseguradora, decode(p.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip, nvl(trunc(months_between(a.fecha_ingreso,nvl(p.f_nac,p.f_nac))/12),0) as edadPac, p.sexo, p.apartado_postal as codigoPaciente from tbl_adm_admision a, vw_adm_paciente p , tbl_adm_tipo_admision_cia t, tbl_cds_centro_servicio cds , tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae where a.pac_id = p.pac_id and (a.categoria = t.categoria and a.tipo_admision = t.codigo) and a.corte_cta is null and a.centro_servicio = cds.codigo and (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and aba.prioridad(+) = 1 and nvl(aba.estado(+),'A') = 'A' and aba.empresa = ae.codigo(+)) and a.estado not in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'ADM_EXCLU_EST_ADM') from dual),',') from dual  )) /*and a.fecha_egreso is null*/  ");
sql.append(appendFilter1);
sql.append(" order by a.centro_servicio , ae.nombre, a.categoria ");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String subtitle = "INFORME DE INGRESOS DE PACIENTES DEL DIA "+fechaini;
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;	
	
	Vector dHeader = new Vector();		
		dHeader.addElement(".20"); //
		dHeader.addElement(".11");
		dHeader.addElement(".06");
		dHeader.addElement(".09");
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".12");
		dHeader.addElement(".15"); //
		dHeader.addElement(".16");	
	
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);		
	
	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();		
	footer.setFont(6, 0);
	footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);	   	
footer.addCols("[ VIP/D/N ] "+"  Esta Columna indica el programa de Fidelización al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP   = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   DIST  = Paciente pertenece al programa de clientes DISTINGUIDOS.",0,dHeader.size());
footer.addCols("                   MED   = Paciente pertenece al grupo de MEDICOS del STAFF.",0,dHeader.size());
footer.addCols("                   JDIR  = Paciente pertenece al grupo de los miembros de la JUNTA DIRECTIVA o es familiar de alguno de los miembros.",0,dHeader.size());
footer.addCols("                   N     = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
		//footerHeight = footer.getTableHeight();
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());  	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);		
		pc.addBorderCols("NOMBRE PACIENTE",1,1,Color.lightGray);
		pc.addBorderCols("CODIGO REFERENCIA",1,1,Color.lightGray);
		pc.addBorderCols("PID",1,1,Color.lightGray);
		pc.addBorderCols("IDENTIFICACION",1,1,Color.lightGray);
		pc.addBorderCols("F. INGRESO",1,1,Color.lightGray);
		pc.addBorderCols("CAT.",1,1,Color.lightGray);
		pc.addBorderCols("TIPO ADMISION",1,1,Color.lightGray);
		pc.addBorderCols("AREA DE SERVICIO",1,1,Color.lightGray);
		pc.addBorderCols("ASEGURADORA",1,1,Color.lightGray); 	
	pc.setTableHeader(2);

	int mSex = 0;
	int fSex = 0;
	int nChild = 0;
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{		
    cdo = (CommonDataObject) al.get(i);	    
	   
		pc.setFont(7, 0);		
		pc.addCols(cdo.getColValue("nombrePaciente"),0,1);		
		pc.addCols(cdo.getColValue("codigoPaciente"),0,1);
		pc.addCols(cdo.getColValue("pac_id"),1,1);
		pc.addCols(cdo.getColValue("cedula"),0,1);
		pc.addCols(cdo.getColValue("fechaIngreso"),0,1);
		pc.addCols(cdo.getColValue("descripcion_cat"),1,1);
		pc.addCols(cdo.getColValue("descripcion_tipoadm"),0,1);
		pc.addCols(cdo.getColValue("descripcion_centro"),0,1);
		pc.addCols(cdo.getColValue("descAseguradora"),0,1);
		
		if (cdo.getColValue("sexo").equalsIgnoreCase("M")) mSex++;
		else fSex++;
		if (Integer.parseInt(cdo.getColValue("edadPac")) < 18) nChild++;
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}//for i

	if (al.size() == 0)
	{		
			pc.addCols("No hay resultados!",1,dHeader.size());		
	}
	else 
	{
	  //Totales Finales						
		  pc.setFont(8, 1,Color.black);
		  pc.addCols(" ",0,dHeader.size(),cHeight);
		  pc.addCols(" TOTAL DE PACIENTES:   "+al.size(),0,dHeader.size(),Color.lightGray);
			pc.addCols(" TOTAL DE HOMBRES:     "+mSex,0,dHeader.size(),Color.lightGray);
			pc.addCols(" TOTAL DE MUJERES:     "+fSex,0,dHeader.size(),Color.lightGray);
			//pc.addCols(" TOTAL DE INFANTES:    "+nChild,0,dHeader.size(),Color.lightGray);
		  pc.addCols(" ",0,dHeader.size(),cHeight);	   		    
			}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>