<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");

if (cds == null ) cds = "";
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente");

sbSql.append("select nvl(get_sec_comp_param(")
	.append(session.getAttribute("_companyId"))
	.append(",'ADM_BARCODE_SHOW_ALLERGIC_LABEL'),'Y') as show_allergic_label, nvl(get_sec_comp_param(")
	.append(session.getAttribute("_companyId"))
	.append(",'EXP_EXCLU_ALERGIA'),'-1') as excl_allergy, nvl(get_sec_comp_param(")
	.append(session.getAttribute("_companyId"))
	.append(",'CDS_NEO'),'-1') as cds_neo, nvl(get_sec_comp_param(")
	.append(session.getAttribute("_companyId"))
	.append(",'ADM_FORMATO_BRAZALETE'),'1') as formato from dual");
CommonDataObject param = SQLMgr.getData(sbSql.toString());

if (cds.equals(param.getColValue("cds_neo"))) {
	response.sendRedirect("../admision/print_admision_barcode_neo.jsp?pacId="+pacId+"&noAdmision="+noAdmision+"&cds="+cds);
	return;
}

sbSql = new StringBuffer();
sbSql.append("select lpad(z.pac_id,10,'0')||lpad(y.secuencia,3,'0') as barcode, z.pac_id, y.secuencia");
sbSql.append(", nvl(y.name_match,z.primer_nombre)||decode(z.segundo_nombre,null,'',' '||z.segundo_nombre) as nombres, decode(z.primer_apellido,null,'',' '||nvl(y.lastname_match,z.primer_apellido))||decode(z.segundo_apellido,null,'',' '||z.segundo_apellido)||decode(z.estado_civil,'CS',decode(z.apellido_de_casada,null,'',' DE '||z.apellido_de_casada)) as apellidos");
sbSql.append(", coalesce(decode(z.pasaporte,null,'',z.pasaporte),to_char(z.provincia||'-'||z.sigla||'-'||z.tomo||'-'||z.asiento))||'-'||z.d_cedula as identidad, to_char(z.f_nac,'dd/mm/yyyy') as fecha, y.admi_madre");
sbSql.append(", decode('");
sbSql.append(param.getColValue("show_allergic_label"));
sbSql.append("','N',0,(select count(*) from tbl_sal_alergia_paciente a, tbl_sal_tipo_alergia b where a.tipo_alergia = b.codigo and a.pac_id = z.pac_id and b.es_alergia = 'S' and b.codigo not in (select column_value from table (select split('");
sbSql.append(param.getColValue("excl_allergy"));
sbSql.append("',',') from dual)))) as nAlergia");
sbSql.append(", x.descripcion as tipo_adm_desc, upper(replace(get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),'d'),'y','a')) as edad, decode(z.sexo,'F','Femenino','Masculino') as sexo, (select nombre_corto from tbl_sec_compania where codigo = y.compania) as nombreComp");
sbSql.append(" from vw_adm_paciente z, tbl_adm_admision y, tbl_adm_tipo_admision_cia x where z.pac_id = y.pac_id and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and y.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and y.categoria = x.categoria and y.tipo_admision = x.codigo and y.compania = x.compania");

CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

if ( cdo == null ) cdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET")) {
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String servletPath = request.getServletPath();
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+param.getColValue("formato")+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	boolean logoMark = false;
	boolean statusMark = false;
	boolean isLandscape = false;

	float width = 72 * 8f; //576
	float height = 72f;
	float leftRightMargin = 0.0f;
	float topMargin = 9.0f;
	float bottomMargin = 9.0f;
	float fontSize = 8f;
	float cHeight = fontSize + 4;
	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector vMain = new Vector();
	if (param.getColValue("formato").trim().equals("4")) {
		vMain.addElement(".06");
		vMain.addElement(".06");
		vMain.addElement(".16");
		vMain.addElement(".42");
		vMain.addElement(".29");
	} else if (!param.getColValue("formato").trim().equals("1")) {
		vMain.addElement(".06");
		vMain.addElement(".16");
		vMain.addElement(".42");
		vMain.addElement(".29");
		vMain.addElement(".06");
	} else {
		/**cb
		vMain.addElement(".30");
		vMain.addElement(".60");
		vMain.addElement(".30");
		**/
		vMain.addElement(".32");
		vMain.addElement(".56");
		vMain.addElement(".32");
	}

	Vector vDetail = new Vector();
	if (!param.getColValue("formato").trim().equals("1")) {
		/**cb
		vDetail.addElement(".08");
		vDetail.addElement(".10");
		vDetail.addElement(".09");//
		vDetail.addElement(".11");
		vDetail.addElement(".08");
		vDetail.addElement(".16");
		vDetail.addElement(".08");
		vDetail.addElement(".30");
		**/
		vDetail.addElement(".08");
		vDetail.addElement(".12");
		vDetail.addElement(".09");//
		vDetail.addElement(".11");
		vDetail.addElement(".08");
		vDetail.addElement(".19");
		vDetail.addElement(".08");
		vDetail.addElement(".25");
	} else {
		vDetail.addElement(".07");
		vDetail.addElement(".09");
		vDetail.addElement(".08");
		vDetail.addElement(".25");
		vDetail.addElement(".06");
		vDetail.addElement(".07");
		vDetail.addElement(".07");
		vDetail.addElement(".31");
	}

	String alergico = (cdo.getColValue("nAlergia").equals("0"))?"":"A L E R G I C O";

	pc.setNoColumnFixWidth(vDetail);
	pc.createTable("paciente",false,0,0.0f,width*(param.getColValue("formato").equals("1")?1f:.88f));

if (param.getColValue("formato").trim().equals("4")) {

		pc.setVAlignment(2);
		pc.setFont(fontSize,0);
		pc.addCols("Nombre:",0,1);
		pc.setFont(fontSize+2,1);
		pc.addCols(cdo.getColValue("apellidos")+", "+cdo.getColValue("nombres"),0,vDetail.size() - 1,cHeight + 2);

		pc.setVAlignment(0);
		pc.setFont(fontSize,0);
		pc.addCols("PID:",0,1);
		pc.addCols(cdo.getColValue("pac_id"),0,1);
		pc.addCols("F. Nac.:",0,1);
		pc.addCols(cdo.getColValue("fecha"),0,1);
		pc.addCols("Ced/Pas:",0,1);
		pc.addCols(cdo.getColValue("identidad"),0,1);
		pc.addCols("Edad:",2,1);
		pc.addCols(cdo.getColValue("edad"),0,1);

		pc.addCols("No. Adm.:",0,1);
		pc.addCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("secuencia")),0,1,cHeight);
		pc.addCols("Tipo Adm.:",0,1);
		pc.addCols(cdo.getColValue("tipo_adm_desc"),0,3);
		pc.addCols("Sexo:",2,1);
		pc.addCols(cdo.getColValue("sexo"),0,1);

		pc.setFont(11,1,Color.RED);
		pc.addCols(alergico,0,vDetail.size());

} else {

		pc.setFont(fontSize,0);
		pc.addCols("PID:",0,1);
		pc.addCols(cdo.getColValue("pac_id"),0,1);
		pc.addCols("Nombre:",0,1);
		if (!param.getColValue("formato").trim().equals("1")) pc.addCols(cdo.getColValue("nombres"),0,3,cHeight);
		else pc.addCols(cdo.getColValue("nombres"),0,3,cHeight);
		pc.addCols("Ced/Pas:",0,1);
		pc.addCols(cdo.getColValue("identidad"),0,1);

		pc.addCols(" ",0,3);
		if (!param.getColValue("formato").trim().equals("1")) pc.addCols(cdo.getColValue("apellidos"),0,3,cHeight);
		else pc.addCols(cdo.getColValue("apellidos"),0,3,cHeight);
		pc.addCols("F. Nac.:",0,1);
		pc.addCols(cdo.getColValue("fecha"),0,1);

		pc.addCols("No. Adm.:",0,1);
		pc.addCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("secuencia")),0,1,cHeight);
		pc.addCols("Tipo Adm.:",0,1);
		if (!param.getColValue("formato").trim().equals("1")) pc.addCols(cdo.getColValue("tipo_adm_desc"),0,3);
		else {
			pc.addCols(cdo.getColValue("tipo_adm_desc"),0,1);
			pc.addCols("Sexo:",2,1);
			pc.addCols(cdo.getColValue("sexo"),0,1);
		}
		pc.addCols("Edad:",0,1);
		pc.addCols(cdo.getColValue("edad"),0,1);

}

	pc.setNoColumn(1);
	pc.createTable("imageLogo",false,0,0.0f,0.06f*width);
		pc.setVAlignment(2);
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogoIcon() != null && !_comp.getLogoIcon().trim().equals(""))?_comp.getLogoIcon():"blank.gif"),0.0f,1);

	pc.setNoColumn(1);
	pc.createTable("imageBC",false,0,0.0f,0.34f*width);
		pc.setVAlignment(2);
		pc.addImageCols(pc.getBarCode128(cdo.getColValue("barcode"),0.0f,8.0f),0.0f,1);

	pc.setNoColumn(1);
	pc.createTable("imageBCQR",false,0,0.0f,0.06f*width);
		pc.setVAlignment(2);
		pc.addImageCols(pc.getBarCodeQR(cdo.getColValue("barcode")),0.0f,1);

	pc.setNoColumnFixWidth(vMain);
	pc.createTable();
		pc.setVAlignment(0);
		if (param.getColValue("formato").trim().equals("2")) {

			pc.setFont(fontSize * 1.75f,1);
			pc.addCols(cdo.getColValue("nombreComp"),0,1,3f * cHeight);
			pc.addTableToCols("paciente",1,3);
			pc.addCols("",0,1,3f * cHeight);

		} else if (param.getColValue("formato").trim().contains("3")) {

			pc.setVAlignment(1);
			if (!param.getColValue("formato").trim().toUpperCase().contains("R")) pc.addTableToCols("imageLogo",1,1);
			else pc.addCols(" ",1,1);
			pc.addTableToCols("paciente",1,3);
			if (param.getColValue("formato").trim().toUpperCase().contains("R")) pc.addTableToCols("imageLogo",1,1);
			else pc.addCols("",1,1);

		} else if (param.getColValue("formato").trim().contains("4")) {

			pc.setVAlignment(1);
			pc.addTableToCols("imageLogo",1,1);
			pc.addTableToCols("imageBCQR",1,1);
			pc.addTableToCols("paciente",1,3);
			//pc.addCols(" ",1,3);

		} else {

			pc.addTableToCols("paciente",1,3);

		}

		if (!param.getColValue("formato").trim().contains("4")) {

			pc.setVAlignment(1);
			if (!param.getColValue("formato").trim().equals("1")) pc.addCols(" ",0,1);
			pc.setFont(11,1,Color.RED);
			pc.addCols(alergico,0,1,18.0f);
			pc.setFont(fontSize,0);
			if (!param.getColValue("formato").trim().equals("1")) pc.addTableToCols("imageBC",1,1);
			else pc.addTableToCols("imageBC",1,2);

			if (!param.getColValue("formato").trim().equals("1")) {
				pc.setFont(fontSize,0);
				pc.addCols("Sexo:         "+cdo.getColValue("sexo"),0,1);
				pc.addCols(" ",0,1);
			}

		}

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get


%>