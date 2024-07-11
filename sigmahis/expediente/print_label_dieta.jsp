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
<jsp:useBean id="alOM" scope="session" class="java.util.ArrayList" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<!-- Desarrollado por: Oscar Hawkins        -->
<!-- Reporte: "label"  -->

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
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String noOrden = request.getParameter("noOrden");
String tipoComida = request.getParameter("tipoComida");
String compania = (String) session.getAttribute("_companyId");

String descComida = "";
if(tipoComida==null) tipoComida = "";
else if(tipoComida.equals("1")) descComida = "DESAYUNO";
else if(tipoComida.equals("2")) descComida = "ALMUERZO";
else if(tipoComida.equals("3")) descComida = "CENA";
else if(tipoComida.equals("4")) descComida = "MERIENDA AM";
else if(tipoComida.equals("5")) descComida = "MERIENDA PM";
else if(tipoComida.equals("6")) descComida = "MERIENDA NOCHE";
System.out.println("tipoComida...........="+tipoComida);
/*
Admision, nombre paciente, cama, tipo dieta  y si es:Desayuno, Almuerzo, Cena, Merienda AM, Merienda PM, Merienda Noche
*/
String ordenFilter = "and (";
for(int z=0; z<alOM.size();z++){
	CommonDataObject dom = (CommonDataObject) alOM.get(z);
	if(z!=0) ordenFilter += " or ";
	ordenFilter += " (z.pac_id = "+dom.getColValue("pac_id")+" and z.secuencia = "+dom.getColValue("admision")+")";// and a.orden_med = "+dom.getColValue("no_orden")+")";
}
ordenFilter += ")";
 sql = "select lpad(b.pac_id,10,'0')||lpad(z.secuencia,3,'0') as barcode, b.nombre_paciente, to_char (b.f_nac, 'dd/mm/yyyy') as f_nac, b.pac_id, z.secuencia, nvl (y.cama, y.sala) cama, gettipodieta(z.secuencia, z.pac_id) tipo_dieta, getsubtipodieta(z.secuencia, z.pac_id) sub_tipo_dieta, b.edad|| ' A ' || b.edad_mes || ' M ' as edad from vw_adm_paciente b, tbl_adm_admision z, (select   distinct cds, cama, cds.descripcion sala, pac_id, secuencia from tbl_adm_atencion_cu aca, tbl_sal_cama sc, tbl_sal_habitacion sh, tbl_cds_centro_servicio cds where (sc.compania = "+compania+" and sc.codigo = aca.cama) and (sh.compania = sc.compania and sh.codigo = sc.habitacion) and (cds.codigo = sh.unidad_admin)) y where z.pac_id = b.pac_id and z.pac_id = y.pac_id(+) and z.secuencia = y.secuencia(+)"+ordenFilter;
 
al = SQLMgr.getDataList(sql); 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	 String time = CmnMgr.getCurrentDate("ddmmyyyyhh12miss");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";
		
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
	
	float width = 72 * 1.25f;//612
	float height = 72 * 4f;//792
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 15.0f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "";
	String xtraSubtitle = " ";
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 3;
	float cHeight = 8.0f;
	String dia ="";
	
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	//imagen
		
		/*Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
		pc.addTable();	*/
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".30");	
		dHeader.addElement(".05");	
		dHeader.addElement(".30");
		dHeader.addElement(".05");	
		dHeader.addElement(".30");	
		
		Vector conte = new Vector();	    		
		conte.addElement(".13");	
		conte.addElement(".28");	
		conte.addElement(".17");	
		conte.addElement(".42");	

			
	for(int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		/*
		pc.setNoColumn(1);
		pc.createTable("image"+i,false);
			pc.addImageCols(pc.getBarCode128(cdo.getColValue("barcode"),0.0f,7.0f),8.0f,1);
		*/
	pc.setFont(7, 0);
	pc.setNoColumnFixWidth(conte);
		pc.createTable("contenido"+i,false);	 	
			
			pc.addBorderCols(fecha,1,2,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("Servicio:",2,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(descComida,0,1,0.0f,0.0f,0.0f,0.0f);
			
			pc.addBorderCols(cdo.getColValue("nombre_paciente"),1,conte.size(),0.0f,0.0f,0.0f,0.0f);
			
			pc.addBorderCols("Edad:",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("edad"),0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("Fecha Nac.:",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("f_nac"),0,1,0.0f,0.0f,0.0f,0.0f);

			pc.addBorderCols("Cama:",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("cama"),0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("Dieta:",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.setFont(6, 0);
			pc.addBorderCols(cdo.getColValue("tipo_dieta"),0,1,0.0f,0.0f,0.0f,0.0f);

			pc.setFont(6, 0);
			pc.addBorderCols(cdo.getColValue("sub_tipo_dieta"),0,conte.size(),0.0f,0.0f,0.0f,0.0f,20f);

		/*
		pc.useTable("image"+i);
		pc.addTableToCols("contenido"+i,1,1);
		*/
	}			
				
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
				
		pc.setFont(7,0);	
		for(int i=0; i<al.size(); i++){
			pc.useTable("main");
			//pc.addTableToCols("image"+i,1,dHeader.size());
			//pc.useTable("contenido"+i);
			pc.addTableToCols("contenido"+i,1,dHeader.size());
		//pc.addCols(" ",0,1);
		}
		
	if ( al.size() < 1 ) {
	   pc.addCols("No hay Registros!", 1,dHeader.size());
	}
	
	pc.addTable();  
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>



