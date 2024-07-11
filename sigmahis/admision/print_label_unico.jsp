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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String nobarcode = request.getParameter("nobarcode");

sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'SAL_HIDE_PLABEL_AGE'),'N') as hide_age, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDS_NEO'),'-99999') as cds_neo, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'ADM_LABEL_SHOW_BARCODE'),'N') as show_barcode, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'ADM_LABEL_SHOW_BENEF'),'N') as show_benef, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'ADM_LABEL_SHOW_BENEF_EMPR'),'-') as show_benef_empr from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
boolean showBarcode = "SY".contains(p.getColValue("show_barcode").toUpperCase());
boolean showBenef = "SY".contains(p.getColValue("show_benef").toUpperCase());
if (nobarcode != null) showBarcode = false;

sbSql = new StringBuffer();
sbSql.append("select lpad(y.pac_id,10,'0')||lpad(y.secuencia,3,'0') as barcode, z.pac_id, y.secuencia, nvl(y.name_match,z.primer_nombre)||decode(z.segundo_nombre,null,'',' '||z.segundo_nombre) as nombres, decode(z.primer_apellido,null,'',' '||nvl(y.lastname_match,z.primer_apellido))||decode(z.segundo_apellido,null,'',' '||z.segundo_apellido)||decode(z.estado_civil,'CS',decode(z.apellido_de_casada,null,'',' DE '||z.apellido_de_casada)) as apellidos, coalesce(z.pasaporte,z.provincia||'-'||DECODE(z.sigla,'00',' ','0',' ',z.sigla||'-')||z.tomo||'-'||z.asiento)||'-'||z.d_cedula as identidad, to_char(coalesce(z.f_nac,z.fecha_nacimiento),'dd/mm/yyyy') as fecha, x.descripcion as tipo_adm_desc, c.nombre_corto as categoriaDesc, get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),null) as edad, get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),'mm') as edad_meses, get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),'dd') as edad_dias, decode(z.sexo,'F','Femenino','Masculino') as sexo, y.centro_servicio");

sbSql.append(", nvl((select (select nvl(abreviado,nombre) from tbl_adm_empresa where codigo = a.empresa) as empresa_nombre from tbl_adm_beneficios_x_admision a where a.pac_id = y.pac_id and a.admision = y.secuencia and a.estado = 'A' and a.prioridad = 1 and rownum = 1");
if (!p.getColValue("show_benef_empr").equals("-")) {
	sbSql.append(" and a.empresa in (select column_value from table(select split('");
	sbSql.append(p.getColValue("show_benef_empr"));
	sbSql.append("',',') from dual))");
}
sbSql.append("),' ') as empresa");

sbSql.append(" from vw_adm_paciente z, tbl_adm_admision y, tbl_adm_tipo_admision_cia x, tbl_adm_categoria_admision c");
sbSql.append(" where z.pac_id = y.pac_id and z.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and y.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and y.categoria = c.codigo and y.categoria = x.categoria and y.tipo_admision = x.codigo and y.compania = x.compania");
cdo = SQLMgr.getData(sbSql.toString());
boolean hideAge = ("SY".contains(p.getColValue("hide_age").toUpperCase()) && p.getColValue("cds_neo").equals(cdo.getColValue("centro_servicio")));//only hide from neo

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

	float width = 72 * 2.7f;//612
	float height = 72 * 1f;//792
	if (showBarcode) height = 72 * 1.5f;
	boolean isLandscape = false;
	float leftRightMargin = 0.1f;
	float topMargin = 0.1f;
	float bottomMargin = 0.1f;
	float headerFooterFont = 0.01f;
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

	pc.setNoColumnFixWidth(conte);
	pc.createTable("contenido",false,0,0,178);

			pc.setFont(8, 0);
						pc.addCols("Cta.: "+cdo.getColValue("pac_id")+"-"+cdo.getColValue("secuencia"),0,2);
			pc.setFont(8,1);
			pc.addCols(cdo.getColValue("fecha"),2,2);

			pc.addCols(cdo.getColValue("nombres"),0,4);
			pc.addCols(cdo.getColValue("apellidos"),0,4);

			pc.setFont(8,0);
			pc.addCols("Tipo :",0,1);
			pc.addCols(cdo.getColValue("categoriaDesc"),0,1);
			pc.addCols(cdo.getColValue("identidad"),0,2);

			pc.addCols("MR :",0,1);
			pc.addCols(cdo.getColValue("pac_id"),0,1);
						if (!hideAge){
								if(!cdo.getColValue("edad").equals("0")){pc.addCols(cdo.getColValue("edad")+"  Años",0,1);}
								else if(cdo.getColValue("edad_meses").equals("0"))
								{
								if(Integer.parseInt(cdo.getColValue("edad_dias"))>1){dia="Dias";}
								else{dia="Dia"; }
								pc.addCols(cdo.getColValue("edad_dias")+"  "+dia,0,1);
								}
								else pc.addCols(cdo.getColValue("edad_meses")+"  Meses",0,1);
						}else pc.addCols(" ",0,1);
			pc.addCols(cdo.getColValue("sexo"),0,1);

			float bcHeight = 40f;
			if (showBenef && cdo.getColValue("empresa").trim().length() > 0) {
				bcHeight = 30f;
				pc.setFont(7,0);
				pc.addCols(cdo.getColValue("empresa"),0,conte.size());
			}

			if (showBarcode) {
				Vector vBarcode = new Vector();
				vBarcode.addElement(".01");
				vBarcode.addElement(".98");
				vBarcode.addElement(".01");

				pc.setNoColumnFixWidth(vBarcode);
				pc.createTable("barcode",false,0,0,178);
				pc.setVAlignment(1);
				pc.addCols("",0,3);
				pc.addCols("",0,1);
				// pc.addImageCols(pc.getBarCode128(cdo.getColValue("barcode"),barFontSize, barHeight),bHeight,1);
				pc.addImageCols(pc.getBarCode128(cdo.getColValue("barcode"),6f, bcHeight), bcHeight, 1);
				pc.addCols("",0,1);

				pc.useTable("contenido");
				pc.addTableToCols("barcode",1,5);
			}

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		/*pc.setFont(10, 1);
		pc.addCols(title, 1, dHeader.size(),20.2f);
		pc.addCols("",1, dHeader.size(),10.2f);
		pc.addCols(subtitle, 1, dHeader.size(),20.2f);
		pc.addCols("", 1, dHeader.size(),10.2f);*/

		pc.setFont(8,0);
		for(int i=0; i<1; i++){
		if (i != 0) {pc.addCols(" ",0,dHeader.size(),15.0f);}
		pc.addTableToCols("contenido",1,dHeader.size());
		/*pc.addCols(" ",0,1);
		pc.addTableToCols("contenido",1,1);
		pc.addCols(" ",0,1);
		pc.addTableToCols("contenido",1,1);	*/

		}

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}//get
%>



