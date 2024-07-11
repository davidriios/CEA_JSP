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
<!-- Desarrollado por: José A. Acevedo C.                             -->
<!-- Reporte: "Listado de Personas que Participaron de un Evento en " -->
<!--          "Particular y Regresaron a la Clínica (PEDIATRÍA) "     -->
<!-- Reporte: ADM70022_C                                              -->
<!-- Clínica Hospital San Fernando                                    -->
<!-- Fecha: 25/06/2010                                                -->

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
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String compania = (String) session.getAttribute("_companyId");

String evento    = request.getParameter("evento");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (evento == null)   evento    = "";
if (fechaini == null) fechaini  = "";
if (fechafin == null) fechafin  = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and ae.compania = "+compania;  
  }

if (!evento.equals(""))
{
 appendFilter1 +=" and ae.tipo_evento = "+evento;
}

if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') > to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
 appendFilter1 += " and to_date(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Listado de Personas que Participaron de un Evento en----------------//
//--------------" Particular y Regresaron a la Clínica (PEDIATRÍA) "-----------------------------------//
sql = 
" select ae.secuencia, aa.fecha_nacimiento, aa.codigo_paciente, aa.secuencia, aa.pac_id as pacId, "
+" (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||ae.secuencia||')') as codigoPaciente, "
+" ae.nombre_nino||' '||ae.apellido_p_nino||' '||ae.apellido_p_nino nombreNino, "
+" ae.primer_nombre||' '||substr(ae.segundo_nombre,1,20)||' '||decode(substr(ae.apellido_casada,1,15),null,ae.primer_apellido||' '||ae.segundo_apellido,substr(ae.apellido_casada,1,15)) nombrePadreMadre, "
+" ae.telefono_residencial telfResidencial, ae.telefono_oficina telfOficina, ae.telefono_celular celular, ae.e_mail mail, " 
+" aa.categoria as codCategoria, aca.descripcion as descripcionCategoria, aa.centro_servicio, "
+" cds.descripcion as descripcionCentro, ad.diagnostico, decode(d.observacion,null,d.nombre,d.observacion) as descDiagnostico, "
+" to_char(aa.fecha_ingreso,'dd-mm-yyyy') as fechaIngreso, to_char(aa.fecha_egreso,'dd-mm-yyyy') as fechaEgreso, "
+" ae.pediatra as pediatra, ae.tipo_evento evento, ev.descripcion descEvento "
+" from tbl_adm_admision aa, tbl_adm_paciente ap, tbl_adm_diagnostico_x_admision ad, "
+" tbl_cds_diagnostico d, tbl_adm_categoria_admision aca, tbl_cds_centro_servicio cds, "
+" tbl_adm_encuesta ae, tbl_adm_eventos ev "
+" where "
+" (aa.pac_id = ap.pac_id) and (ad.pac_id = aa.pac_id and ad.admision = aa.secuencia and d.codigo = ad.diagnostico) and "
+" (ae.fecha_nacimiento_nino =  aa.fecha_nacimiento) and (ae.tipo_evento = ev.codigo and ae.tipo_encuesta = '2') and "
+" (aca.codigo = aa.categoria) and (aa.centro_servicio = cds.codigo) "+appendFilter1
+" group by ae.secuencia, aa.fecha_nacimiento, aa.codigo_paciente, aa.secuencia, aa.pac_id, "
+" (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||ae.secuencia||')'), "
+" ae.nombre_nino||' '||ae.apellido_p_nino||' '||ae.apellido_p_nino, "
+" ae.primer_nombre||' '||substr(ae.segundo_nombre,1,20)||' '||decode(substr(ae.apellido_casada,1,15),null,ae.primer_apellido||' '||ae.segundo_apellido,substr(ae.apellido_casada,1,15)), "
+" ae.telefono_residencial, ae.telefono_oficina, ae.telefono_celular, ae.e_mail, "
+" aa.categoria, aca.descripcion,  aa.centro_servicio, cds.descripcion, ad.diagnostico, "
+" decode(d.observacion,null,d.nombre,d.observacion), to_char(aa.fecha_ingreso,'dd-mm-yyyy'), "
+" to_char(aa.fecha_egreso,'dd-mm-yyyy'), ae.pediatra, ae.tipo_evento, ev.descripcion "
+" order by  ae.tipo_evento, ev.descripcion, 2,3,4,1 ";  

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
	String subtitle = "PERSONAS QUE REGRESARON A LA CLÍNICA (PEDIATRIA)";
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

		dHeader.addElement(".08");
        dHeader.addElement(".08");
		dHeader.addElement(".13");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".08");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".15");
		dHeader.addElement(".06");		
		dHeader.addElement(".16");	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.setFont(7, 1);			
		pc.addBorderCols("CODIGO PACIENTE",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("NOMBRE DEL NIÑO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE PADRE / MADRE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TELF. RES.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TELF. OFIC.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TELF. CEL.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CATEGORIA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F. INGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F. EGRESO",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("AREA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PEDIATRA",1,1,cHeight * 2,Color.lightGray);						
		pc.addBorderCols("DIAGNOSTICO",1,1,cHeight * 2,Color.lightGray);		
		
	pc.setTableHeader(2);
	
	int pxc = 0;		
	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);	
		
		// Inicio --- Agrupamiento x Evento	
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento")))
		 {// groupBy
		    
			if (i != 0)
		     {// i
				  pc.setFont(8, 1,Color.red);									
				  pc.addCols("  TOTAL DE PAC. X EVENTO: "+ pxc,0,dHeader.size(),cHeight);					   	
				  pc.addCols(" ",0,dHeader.size(),cHeight);  
				  pxc = 0;	 
			 }// i
			  
			  pc.setFont(8, 1,Color.blue); 
			  pc.addCols("EVENTO:",0,1,cHeight);
		      pc.addCols("[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento"),0,dHeader.size());			
			
	     }// groupBy
		// Fin --- Agrupamiento x Evento	 
		 
		    pc.setFont(7, 0);		
			pc.addCols(" "+cdo.getColValue("codigoPaciente"),0,1,cHeight);//	
			pc.addCols(" "+cdo.getColValue("nombreNino"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("nombrePadreMadre"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("telfResidencial"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("telfOficina"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("celular"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcionCategoria"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fechaEgreso"),1,1);			
			pc.addCols(" "+cdo.getColValue("descripcionCentro"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("pediatra"),0,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("descDiagnostico"),0,1,cHeight); 
			pxc++;
			
		groupBy = "[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento");
		 
	}//for i

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales	
	        pc.setFont(8, 1,Color.red);
			pc.addCols(" TOTAL DE PAC. X EVENTO:       "+ pxc,0,dHeader.size(),cHeight);				
			pc.setFont(8, 1,Color.black);			
			pc.addCols(" GRAN TOTAL DE PACIENTES:   "+ al.size(),0,dHeader.size(),Color.lightGray);	  
			//pc.addCols(dHeader.size()+" Registros en total",0,cHeight); 		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>


