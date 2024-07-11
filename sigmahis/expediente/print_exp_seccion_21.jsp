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

<!-- Desarrollado por: Oscar Hawkins      -->
<!-- Reporte: "reporte de tratamientos"-->
<!-- Reporte: ADM3087                          -->
<!-- Clínica Hospital San Fernando             -->
<!-- Fecha: 20/10/2010                         -->

<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();

CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdo2  = new CommonDataObject();
CommonDataObject cdo3  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();


String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String codigo = request.getParameter("codigo");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");

if ( desc == null ) desc = "";

if (appendFilter == null) appendFilter = "";

   cdop = SQLMgr.getPacData(pacId, noAdmision);
   
   
///////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////Datos Generales
   sql = "select nvl(x.residencia_direccion,' ') as residencia_direccion, nvl(x.telefono,' ') as telefono, nvl(x.telefono_trabajo,' ') as telefono_trabajo, nvl(x.lugar_trabajo,' ') as lugar_trabajo from (select nvl(a.residencia_direccion,' ') as residencia_direccion, nvl(a.telefono,' ') as telefono, nvl(a.telefono_trabajo,' ') as telefono_trabajo, nvl(a.lugar_trabajo,' ') as lugar_trabajo, a.pac_id from tbl_adm_paciente a where a.pac_id="+pacId+") x   ";  
 
   cdo1 = SQLMgr.getData(sql);
//-----------------------------------------------------------------------------------------------------

   
///////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////Aseguradora  
   sql="select  d.nombre as nombre_empresa, b.empresa as empresa, b.poliza as poliza, nvl(b.certificado,' ') as certificado, b.pac_id, b.admision from tbl_adm_beneficios_x_admision b, tbl_adm_empresa d where b.pac_id="+pacId+" and b.admision="+noAdmision+"   and  b.empresa=d.codigo(+)"; 
  
   al1 = SQLMgr.getDataList(sql);
//-----------------------------------------------------------------------------------------------------  
 
///////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////Responsable  
   sql="select nvl(c.nombre,' ') as nombre, ref_id as identificacion, (select descripcion from tbl_fac_tipo_cliente where codigo=c.ref_type and compania="+(String)session.getAttribute("_companyId")+" ) as tipo_identificacion, nvl(c.telefono_residencia,' ') as telefono_residencia, c.pac_id, c.admision from tbl_adm_responsable c where c.pac_id="+pacId+" and c.admision="+noAdmision+" ";
	al2 = SQLMgr.getDataList(sql);
//-----------------------------------------------------------------------------------------------------  

///////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////Diagnosticos
	sql = "select a.diagnostico, decode(b.observacion,null,b.nombre,b.observacion) nombre, a.orden_diag from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.pac_id="+pacId+" and a.admision="+noAdmision+" and a.tipo='I' and a.diagnostico=b.codigo order by a.orden_diag";
	al3 = SQLMgr.getDataList(sql);
//----------------------------------------------------------------------------------------------------- 	
	
		

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha =cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
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
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612 
	float height = 72 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement(".10"); 
		dHeader.addElement(".10");
		dHeader.addElement(".10"); 
		dHeader.addElement(".10");
		dHeader.addElement(".10"); 
		dHeader.addElement(".10");
		dHeader.addElement(".10"); 
		dHeader.addElement(".10");
        dHeader.addElement(".10"); 
		dHeader.addElement(".10");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);
		
		pc.setVAlignment(0);
		
		//---------------------- Datos Generales ------------------------
		pc.setFont(9, 1,Color.white);
		pc.addCols("Datos Generales",0,dHeader.size(),16f,Color.gray);
		pc.addCols("",0,dHeader.size());
		
		pc.setFont(9, 0, Color.gray);
		pc.addCols("Teléfono de Residencia:",0,2);
		pc.setFont(9,0);
		pc.addCols(cdo1.getColValue("telefono"),0,2);
		  pc.addCols("",0,1);
		pc.setFont(9, 0, Color.gray);
		pc.addCols("Teléfono de Oficina:",0,2);
		pc.setFont(9,0);
		pc.addCols(cdo1.getColValue("telefono_trabajo"),0,2);
	    pc.addCols("",0,dHeader.size());
	   
		pc.setFont(9, 0, Color.gray);
		pc.addCols("Dirección:",0,1);
		pc.setFont(9,0);
		pc.addCols(cdo1.getColValue("residencia_direccion"),0,9);
		pc.addCols("",0,dHeader.size());
		
		pc.setFont(9, 0, Color.gray);
		pc.addCols("Lugar de Trabajo:",0,2);
		pc.setFont(9,0);
		pc.addCols(cdo1.getColValue("lugar_trabajo"),0,8);
		pc.addCols("",0,dHeader.size(),10f);
		//---------------------- Datos Generales ------------------------
		
			
		//---------------------- Datos de la Aseguradora ----------------
		pc.setFont(9, 1, Color.white);
		pc.addCols("Datos de la Aseguradora",0,dHeader.size(),16f,Color.gray);
		//pc.addCols("",0,dHeader.size());
		
		pc.setFont(9, 0, Color.gray);
		pc.addBorderCols("Compañía de Seguro",0,6,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Póliza",0,2,0.1f,0.1f,0.0f,0.0f);
		pc.addBorderCols("Certificado",0,2,0.1f,0.1f,0.1f,0.1f);
		
		pc.setFont(9, 0);
		for ( int s = 0; s<al1.size(); s++ ){ 
		   
		   cdo1 = (CommonDataObject)al1.get(s);
		   pc.addCols(cdo1.getColValue("nombre_empresa"),0,6);
		   pc.addCols(cdo1.getColValue("poliza"),0,2);
		   pc.addCols(cdo1.getColValue("certificado"),0,2);
		}
		pc.addCols("",0,dHeader.size(),10f);
		//---------------------- Datos de la Aseguradora ----------------
		
		
		//---------------------- Datos Responsable ----------------------
		pc.setFont(9, 1, Color.white);
		pc.addCols("Datos del Responsable",0,dHeader.size(),16f,Color.gray);
		//pc.addCols("",0,dHeader.size());
		
		pc.setFont(9, 0, Color.gray);
		pc.addBorderCols("Nombre",0,3,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Télefono",0,2,0.1f,0.1f,0.0f,0.0f);
		pc.addBorderCols("Tipo de identificación",0,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Identificación",0,3,0.1f,0.1f,0.1f,0.1f);
		
		pc.setFont(9, 0);
		for ( int r = 0; r<al2.size(); r++ ){ 
		   
		   cdo2 = (CommonDataObject)al2.get(r);
		   pc.addCols(cdo2.getColValue("nombre"),0,3);
		   pc.addCols(cdo2.getColValue("telefono_residencia"),0,2);
		   pc.addCols(cdo2.getColValue("tipo_identificacion"),0,2);
		   pc.addCols(cdo2.getColValue("identificacion"),0,3);
		}
		pc.addCols("",0,dHeader.size(),10f);
		//---------------------- Datos Responsable ----------------------
		
		
		//---------------------- Diagnosticos Ingresos ----------------------
		pc.setFont(9, 1, Color.white);
		pc.addCols("Diagnósticos de Ingreso",0,dHeader.size(),16f,Color.gray);
		//pc.addCols("",0,dHeader.size());
		
		pc.setFont(9, 0, Color.gray);
		pc.addBorderCols("Código",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Nombre",0,8,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Orden",0,1,0.1f,0.1f,0.1f,0.1f);
		
		pc.setFont(9, 0);
		for ( int d = 0; d<al3.size(); d++ ){ 
		   
		   cdo3 = (CommonDataObject)al3.get(d);
		   pc.addCols(cdo3.getColValue("diagnostico"),0,1);
		   pc.addCols(cdo3.getColValue("nombre"),0,8);
		   pc.addCols(cdo3.getColValue("orden_diag"),0,1);
		}
		//---------------------- Diagnosticos Ingresos  ----------------------

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET

%>