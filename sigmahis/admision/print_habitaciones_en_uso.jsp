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
<!-- Desarrollado por: José A. Acevedo C.         -->
<!-- Reporte: "Listado de Habitaciones en Uso x Sección"  -->
<!-- Reporte: ADM3060                             -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 11/03/2010                            -->        

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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  
String habitacion = request.getParameter("habitacion") == null ? "" : request.getParameter("habitacion");
String sala = request.getParameter("sala") == null ? "" : request.getParameter("sala");
String aseguradora = request.getParameter("aseguradora") == null ? "" : request.getParameter("aseguradora");
String cdsAdm = request.getParameter("cdsAdm");
String cdsAdmDesc = request.getParameter("cdsAdmDesc");
String compania = (String) session.getAttribute("_companyId");

if (cdsAdm == null) cdsAdm = "";
if (cdsAdmDesc == null) cdsAdmDesc = "";

sbFilter.append(" and a.compania = ");
sbFilter.append(compania);

if (!habitacion.trim().equals("")) { sbFilter.append(" and cama.habitacion = '"); sbFilter.append(habitacion); sbFilter.append("'"); }
if (!sala.trim().equals("")) { sbFilter.append(" and salh.unidad_admin = "); sbFilter.append(sala); }
if (!aseguradora.trim().equals("")) { sbFilter.append(" and aba.empresa = "); sbFilter.append(aseguradora); }
if (!cdsAdm.trim().equals("")) { sbFilter.append(" and a.centro_servicio = "); sbFilter.append(cdsAdm); }

sbSql.append("select all salh.unidad_admin as codSala, cds.descripcion as descSala, p.nombre_paciente as nombrePaciente, ' ('||a.pac_id||' - '||a.secuencia||')' as codigoPaciente, p.id_paciente as cedula, a.codigo_paciente as cod_pac, a.secuencia as noAdmision, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, decode(p.vip,'S','VIP','F','FREC','N') as vip, cama.cama as cama, cama.habitacion as habitacion, saltipoh.precio as precio, decode(med.apellido_de_casada,null,med.primer_apellido,med.apellido_de_casada)||' '||med.primer_nombre as medico from tbl_adm_admision a,vw_adm_paciente p, tbl_adm_medico med, tbl_cds_centro_servicio cds, tbl_adm_cama_admision cama, tbl_sal_cama salc, tbl_sal_habitacion salh, tbl_sal_tipo_habitacion saltipoh, tbl_adm_beneficios_x_admision aba where a.pac_id = p.pac_id  and (a.compania = cama.compania(+) and a.pac_id = cama.pac_id(+) and a.secuencia = cama.admision(+) and cama.fecha_final(+) is null) and a.estado = 'A' and a.categoria in (1,5) and (cama.compania = salc.compania and cama.habitacion = salc.habitacion and cama.cama = salc.codigo and salc.estado_cama = 'U') and (salc.compania = salh.compania and salc.habitacion = salh.codigo) and (salc.compania = saltipoh.compania and salc.tipo_hab = saltipoh.codigo) and (a.medico = med.codigo) and (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and nvl(aba.estado(+),'A') = 'A' and aba.prioridad(+) = 1) and (cds.codigo = salh.unidad_admin) ");
sbSql.append(sbFilter);
sbSql.append(" order by 1,2,13,9,7,6 ");
al = SQLMgr.getDataList(sbSql.toString());

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
	String subtitle = "HABITACIONES EN USO  "; 
	String xtraSubtitle = "";  
	//if (!cdsAdmDesc.trim().equals("")) xtraSubtitle = "ADMITIDO POR (CDS): "+cdsAdmDesc;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;	
	
	Vector dHeader = new Vector();  
	    dHeader.addElement(".11");
	    dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".10");
		dHeader.addElement(".18");
		dHeader.addElement(".26"); //
		dHeader.addElement(".17");				
		
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);  	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);		
		pc.addBorderCols("F. INGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("HAB.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CAMA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PRECIO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CODIGO PACIENTE",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CEDULA / PASP.",1,1,cHeight * 2,Color.lightGray);
				
	pc.setTableHeader(2);
	
	String groupBy = "";
	double varPrecio = 0, varPrecioxsala = 0, vartotPrecio = 0;
	int pxs = 0, pxcath = 0;
	for (int i=0; i<al.size(); i++)
	{			
      cdo = (CommonDataObject) al.get(i);	
	  
	    varPrecio = Double.parseDouble(cdo.getColValue("precio")); 

	    //Inicio --- Agrupamiento por Sala/Sección
      if(!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala")))
	    {
		  if (i != 0)  
		   {//i-1
		     pc.setFont(8, 1,Color.red);
			 pc.addCols(" ",0,dHeader.size(),cHeight);
			 pc.addCols("TOTAL DE CARGOS X CENTRO:                             "+"$"+CmnMgr.getFormattedDecimal(varPrecioxsala)+"                                  TOTAL DE PACTS. X SALA O SECCIÓN:      "+ pxs,0,dHeader.size(),cHeight);
			 pc.addCols(" ",0,dHeader.size(),cHeight);			
			 pxs    = 0;
			 varPrecioxsala = 0;
		   }//i-1		  		
		   pc.setFont(8, 1,Color.blue);  
		   pc.addCols("SALA:",0,1,cHeight);
		   pc.addCols("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"),0,dHeader.size(),cHeight);		   
		}//Fin --- Agrupamiento por Sala/Sección
  
		pc.setFont(7, 0);
		pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("cama"),1,1,cHeight);
		pc.addCols(" "+"$"+CmnMgr.getFormattedDecimal(varPrecio),2,1,cHeight);
		pc.addCols(" "+cdo.getColValue("codigoPaciente"),1,1,cHeight);			
		pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight); 
		pc.addCols(" "+cdo.getColValue("cedula"),0,1,cHeight);  		    
		pxs++;
	
	     groupBy  = "[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala");
	     varPrecioxsala = varPrecioxsala + varPrecio; 
	     vartotPrecio   = vartotPrecio   + varPrecio;    
	  }//for i

	if (al.size() == 0)  
	{		
	   pc.addCols("No existen registros",1,dHeader.size());    	         	
	}
	else   
	{//Totales Finales
	  pc.setFont(8, 1, Color.red);
  	  pc.addCols(" ",0,dHeader.size(),cHeight);
	  pc.addCols("TOTAL DE CARGOS X CENTRO:                             "+"$"+CmnMgr.getFormattedDecimal(varPrecioxsala)+"                                  TOTAL DE PACTS. X SALA O SECCIÓN:           "+ pxs,0,dHeader.size(),cHeight);
	  pc.setFont(8, 1,Color.black);    
	  pc.addCols(" ",0,dHeader.size(),cHeight);
pc.addCols("GRAN TOTAL DE CARGOS:                                   "+ CmnMgr.getFormattedDecimal(vartotPrecio)+"                                  GRAN TOTAL DE PACIENTES:                        "+ al.size(),0,dHeader.size(),Color.lightGray);  	  
	}    
	 pc.addTable();  
	 pc.close();    
	response.sendRedirect(redirectFile);     
}//get
%>

