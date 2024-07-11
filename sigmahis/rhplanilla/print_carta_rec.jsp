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
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<!-- Desarrollado por: Oscar Hawkins        -->
<!-- Reporte: "Informe de Valores del paciente"  -->
<!-- Reporte: ADM3087                         -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 18/10/2010                        -->

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
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy ");
String compania = (String) session.getAttribute("_companyId");

String emp_id       = request.getParameter("emp_id");

 sql = " select a.nombre_empleado nombre, DECODE(a.provincia,0,' ',00,' ',11,'B',12,'C',a.provincia)||RPAD(DECODE(a.sigla,'00','  ','0','  ', a.sigla),2,' ')||'-'||TO_CHAR(a.tomo)||'-'||TO_CHAR(a.asiento) as cedula, a.emp_id as empId, a.num_empleado as numero, a.num_ssocial as social, c.denominacion, trim(to_char(to_date('"+fecha+"', 'dd/mm/yyyy'),'DD \"de\"  month\"de\" YYYY', 'NLS_DATE_LANGUAGE=SPANISH')) dia_largo, to_char(a.fecha_ingreso,' DD \"de\" month \"de\" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') fechain, to_char(a.fecha_egreso,'DD \"de\" month \"de\" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') fechafin, nvl(d.firma,' ') firma, nvl(d.cargo_firma,' ') cargo_firma  from  vw_pla_empleado a ,tbl_pla_cargo c, (SELECT  nvl(INITCAP(E.PRIMER_NOMBRE)||' '||DECODE(E.SEXO,'F',DECODE(E.APELLIDO_CASADA, NULL,INITCAP(E.PRIMER_APELLIDO),DECODE(E.USAR_APELLIDO_CASADA,'S','de '|| INITCAP(E.APELLIDO_CASADA),INITCAP(E.PRIMER_APELLIDO))),INITCAP(E.PRIMER_APELLIDO)),'') firma, nvl(f.DENOMINACION,'') cargo_firma FROM vw_PLA_EMPLEADO e, TBL_PLA_CARGO f WHERE E.COMPANIA = 1  AND E.ESTADO <> 3 AND f.CODIGO(+) = E.CARGO AND f.COMPANIA(+) = E.COMPANIA AND nvl(f.FIRMAR_CARTA_TRABAJO,'S') = 'S' ) d where  a.cargo=c.codigo and c.estado='A' and a.compania="+compania+"and a.emp_id="+emp_id;

cdo = SQLMgr.getData(sql);
 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 
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
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
//	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";	
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 28.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = true;
	String xtraCompanyInfo = "";
	String title = "A QUIEN CONCIERNE";
	String subtitle = "";
	String xtraSubtitle = " ";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 11;
	float cHeight = 12.0f;
	
	String consentimientoGeneral=" Durante su permanencia en esta empresa realizó su trabajo con honradez y responsabilidad. "+
                                   "Sin otro particular, nos suscribimos.\n\n\n";	
							 

	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	//imagen
		
		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
	//	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
		pc.addImageCols(companyImageDir+"/"+("blank.gif"),80.0f,1);
		pc.addTable();	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".06");
		dHeader.addElement(".17");	
		dHeader.addElement(".18");	
		dHeader.addElement(".17");
		dHeader.addElement(".13");		
		dHeader.addElement(".24");	
		dHeader.addElement(".05");		
		  	
			
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
		for(int c=0; c<13; c++){
	pc.addCols("", 1, dHeader.size());
	}
	
	
	    pc.setFont(11, 0);
		pc.addCols("",0,1);
		pc.addCols("Panamá, " +cdo.getColValue("dia_largo"),0, 7,20.2f);
		pc.addCols("",0,1);
		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.setFont(12, 1);
		pc.addCols(title, 1,  dHeader.size(),20.2f);
		
		
		pc.addCols("",1, dHeader.size(),10.2f);
		
		pc.addCols("",0,1);
		pc.addCols(subtitle, 1, 7,20.2f);
		pc.addCols("",0,1);
		
		pc.addCols("", 1, dHeader.size(),10.2f);
	
		pc.setFont(11, 0);
		
		pc.addCols("",0,1);
		pc.addCols("Estimados Señores:",0,5);
		pc.addCols("",0,1);
		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);
		pc.addCols("     Por  este  medio  certificamos  que   el   señor(a): ",0,3);
		pc.addBorderCols(cdo.getColValue("nombre"),0,2,0.5f,0.0f,0.0f,0.0f);	
		pc.addCols("",0,1);
		
		pc.addCols("",0,1);	
		pc.addCols("con  cédula   de  identidad   personal ",0,2);
		pc.addBorderCols(cdo.getColValue("cedula"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" laboró   en   esta  empresa  desde  el",1,2);	
		pc.addCols("",0,1);	
		
		
		pc.addCols("",0,1);	
		pc.addCols(cdo.getColValue("fechain")+"       hasta   el    "+cdo.getColValue("fechafin"),0,4);
		pc.addCols("   con   el   cargo   de",0,1);		
		pc.addCols("",0,1);
		
		pc.addCols("",0,1);	
		pc.addCols(cdo.getColValue("denominacion"),0,6);
		
		
		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);
		pc.addCols(consentimientoGeneral,0,5);
		pc.addCols("",0,1);
		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);	
		pc.addCols("Atentamente",0,6); 		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);	
		pc.addBorderCols("",0,2,1f,0.0f,0.0f,0.0f);
		pc.addCols("",0,4);
		
		pc.addCols("",0,1);	
		pc.addCols(cdo.getColValue("firma"),0,6);
		
		pc.addCols("",0,1);	
		pc.addCols(cdo.getColValue("cargo_firma"),0,6);
		
			
	pc.setTableHeader(2);
	
	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	pc.addTable();  
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>

