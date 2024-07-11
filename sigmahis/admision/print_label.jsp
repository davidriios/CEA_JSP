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
String compania = (String) session.getAttribute("_companyId");


 sql = "select lpad("+pacId+",10,'0')||lpad("+noAdmision+",3,'0') as barcode, z.pac_id, y.secuencia, nvl(y.name_match,z.primer_nombre)||decode(z.segundo_nombre,null,'',' '||z.segundo_nombre) nombres, decode(z.primer_apellido,null,'',' '||nvl(y.lastname_match,z.primer_apellido))||decode(z.segundo_apellido,null,'',' '||z.segundo_apellido)||decode(z.estado_civil,'CS',decode(z.apellido_de_casada,null,'',' DE '||z.apellido_de_casada)) as apellidos, coalesce(z.pasaporte,z.provincia||'-'||DECODE(z.sigla,'00',' ','0',' ',z.sigla||'-')||z.tomo||'-'||z.asiento)||'-'||z.d_cedula AS identidad, to_char(z.f_nac,'dd/mm/yyyy') as fecha, x.descripcion tipo_adm_desc, c.nombre_corto as categoriaDesc, get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),null) as edad, get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),'mm') as edad_meses, get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),'dd') as edad_dias, decode(z.sexo,'F','Femenino','Masculino') sexo, case when (get_sec_comp_param("+compania+",'SAL_HIDE_PLABEL_AGE') = 'S' OR get_sec_comp_param("+compania+",'SAL_HIDE_PLABEL_AGE') = 'Y') AND get_sec_comp_param("+compania+",'CDS_NEO') = y.centro_servicio then 'Y' else 'N' end hide_age from vw_adm_paciente z, tbl_adm_admision y, tbl_adm_tipo_admision_cia x, tbl_adm_categoria_admision c where z.pac_id = y.pac_id and z.pac_id="+pacId+" and y.secuencia = "+noAdmision+" and y.categoria=c.codigo and y.categoria = x.categoria and y.tipo_admision = x.codigo and y.compania = x.compania";

cdo = SQLMgr.getData(sql);

if (cdo == null){
	cdo = new CommonDataObject();
	cdo.addColValue("hide_age","N");
}

boolean hideAge = cdo.getColValue("hide_age","N").equalsIgnoreCase("Y");

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
	float leftRightMargin = 18.0f;
	float topMargin = 30.0f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "";
	String xtraSubtitle = " ";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 3;
	float cHeight = 8.0f;
	String dia ="";

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

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
		conte.addElement(".20");
		conte.addElement(".22");
		conte.addElement(".33");
		conte.addElement(".25");

		pc.setFont(8, 0);
	pc.setNoColumnFixWidth(conte);
	pc.createTable("contenido",false,0,0,178);
			pc.addCols("PID: "+cdo.getColValue("pac_id")+"-"+cdo.getColValue("secuencia"),0,2);
			pc.setFont(8, 1);
			pc.addCols(cdo.getColValue("fecha"),2,2);

			pc.setFont(8,1);
			pc.addCols(cdo.getColValue("nombres"),0,4);

			pc.addCols(cdo.getColValue("apellidos"),0,4);

			pc.setFont(8,0);
			pc.addCols("Tipo :",0,1);
			pc.addCols(cdo.getColValue("categoriaDesc"),0,1);
			pc.addCols(cdo.getColValue("identidad"),0,2);

			pc.addCols("MR :",0,1);
			pc.addCols(cdo.getColValue("pac_id"),0,1);
						if (!hideAge){
								if(!cdo.getColValue("edad").equals("0")){
									 pc.addCols(cdo.getColValue("edad")+"  Años",0,1);
								}
								else if(cdo.getColValue("edad_meses").equals("0")){
										if(Integer.parseInt(cdo.getColValue("edad_dias"))>1){
											dia="Dias";
										}
										else{dia="Dia"; }
										pc.addCols(cdo.getColValue("edad_dias")+"  "+dia,0,1);
								}
								else pc.addCols(cdo.getColValue("edad_meses")+"  Meses",0,1);
						}else pc.addCols(" ",0,1);
			pc.addCols(cdo.getColValue("sexo"),0,1);


	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		/*pc.setFont(10, 1);
		pc.addCols(title, 1, dHeader.size(),20.2f);
		pc.addCols("",1, dHeader.size(),10.2f);
		pc.addCols(subtitle, 1, dHeader.size(),20.2f);
		pc.addCols("", 1, dHeader.size(),10.2f);*/

		pc.setFont(8,0);
		for(int i=0; i<10; i++){
		if (i != 0) {pc.addCols(" ",0,dHeader.size(),15.0f);}
		pc.addTableToCols("contenido",1,1);
		pc.addCols(" ",0,1);
		pc.addTableToCols("contenido",1,1);
		pc.addCols(" ",0,1);
		pc.addTableToCols("contenido",1,1);

		}

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}//get
%>



