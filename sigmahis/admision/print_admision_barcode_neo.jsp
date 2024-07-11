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
	.append(",'ADM_FORMATO_BRAZALETE_NEO'),'-') as formatoNeo from dual");
CommonDataObject param = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select lpad(z.pac_id,10,'0')||lpad(y.secuencia,3,'0') as barcode, z.pac_id, y.secuencia");
sbSql.append(", nvl(y.name_match,z.primer_nombre)||decode(z.segundo_nombre,null,'',' '||z.segundo_nombre) as nombres, decode(z.primer_apellido,null,'',' '||nvl(y.lastname_match,z.primer_apellido))||decode(z.segundo_apellido,null,'',' '||z.segundo_apellido) as apellidos");
sbSql.append(", coalesce(decode(z.pasaporte,null,'',z.pasaporte),to_char(z.provincia||'-'||z.sigla||'-'||z.tomo||'-'||z.asiento))||case when (select count(*) from tbl_adm_neonato x where exists (select null from tbl_adm_neonato y where pac_id = z.pac_id and pac_id_madre = x.pac_id_madre and admsec_madre = x.admsec_madre and estado = 'A') and estado = 'A') > 1 then '-'||z.d_cedula else null end as identidad, to_char(z.f_nac,'dd/mm/yyyy') as fecha, y.admi_madre");
sbSql.append(", decode('");
sbSql.append(param.getColValue("show_allergic_label"));
sbSql.append("','N',0,(select count(*) from tbl_sal_alergia_paciente a, tbl_sal_tipo_alergia b where a.tipo_alergia = b.codigo and a.pac_id = z.pac_id and b.es_alergia = 'S' and b.codigo not in (select column_value from table (select split('");
sbSql.append(param.getColValue("excl_allergy"));
sbSql.append("',',') from dual)))) as nAlergia");
sbSql.append(", x.descripcion as tipo_adm_desc, upper(replace(get_age(z.f_nac,nvl(y.fecha_ingreso,y.fecha_creacion),'d'),'y','a')) as edad, decode(z.sexo,'F','Femenino','Masculino') as sexo, (select nombre_corto from tbl_sec_compania where codigo = y.compania) as nombreComp");
sbSql.append(", (select trim(m.primer_nombre)||' '||trim(m.primer_apellido) from tbl_adm_medico m where m.codigo = y.medico) as mednom");
sbSql.append(", (select trim(p.primer_nombre)||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre) from tbl_adm_paciente p where p.pac_id = y.pac_id_madre) as madrenom");
sbSql.append(", (select trim(p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido) from tbl_adm_paciente p where p.pac_id = y.pac_id_madre) as madreape");
sbSql.append(", (select coalesce(decode(c.pasaporte,null,'',c.pasaporte||'-'||c.d_cedula),to_char(c.provincia||'-'||c.sigla||'-'||c.tomo||'-'||c.asiento||'-'||c.d_cedula)) from tbl_adm_paciente c where c.pac_id = y.pac_id_madre) as ced");
sbSql.append(", (select to_char(xx.f_nac,'dd/mm/yyyy') from vw_adm_paciente xx where xx.pac_id = y.pac_id_madre) as fecha_nac_madre");
sbSql.append(", y.pac_id_madre");
sbSql.append(", (select to_char(coalesce((select hora_nacimiento from tbl_adm_neonato an where an.pac_id = h.pac_id), h.hora_nac),'hh12:mi am') from tbl_adm_paciente h where h.pac_id = z.pac_id) as hora_nacimiento");
sbSql.append(", (select trim(m.primer_nombre)||' '||trim(m.primer_apellido) from tbl_adm_medico m where m.codigo = y.medico and exists (select null from tbl_adm_medico_especialidad me where me.especialidad = 'PED' and me.medico = m.codigo)) as pediatra, z.d_cedula");
sbSql.append(" from vw_adm_paciente z, tbl_adm_admision y, tbl_adm_tipo_admision_cia x where z.pac_id = y.pac_id and z.pac_id = ");
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
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+param.getColValue("formatoNeo")+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	boolean logoMark = false;
	boolean statusMark = false;
	boolean isLandscape = false;

	float width = 72 * 4.5f; //324
	float height = 72f;
	float leftRightMargin = 0.0f;
	float topMargin = 9.0f;
	float bottomMargin = 9.0f;
	float fontSize = 8f;
	float fontSizeB = 6f;
	float cHeight = fontSize + 4;
	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();
	
if (param.getColValue("formatoNeo").equalsIgnoreCase("D")) {

	width = 72 * 11.252f; //810.44
	height = 72 * 2f;//144
	leftRightMargin = 0.0f;
	topMargin = 15.0f;
	bottomMargin = 15.0f;

} else if (param.getColValue("formatoNeo").equalsIgnoreCase("H2")) {

	width = 72 * 6.1f; //324
	height = 72 * 1.18f;

}

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

if (param.getColValue("formatoNeo").equalsIgnoreCase("D")) {

	Vector vMain = new Vector();
		vMain.addElement("288");// ? left margin.356
		vMain.addElement("126");// 1.75 baby.1555
		vMain.addElement("108");// 1.5 break.1333
		vMain.addElement("216");// 3 mother.2664
		vMain.addElement("72");// 1 right margin.0888
	Vector bDetail = new Vector();
		bDetail.addElement("63");
		bDetail.addElement("63");
	Vector mDetail = new Vector();
		mDetail.addElement("140.4");
		mDetail.addElement("75.6");

	pc.setNoColumn(1);
	pc.createTable("babyL",false,0,0.0f,63f);
		pc.setFont(fontSizeB,1);
		pc.addCols("HN: "+cdo.getColValue("hora_nacimiento"),0,1);
		pc.addCols("FN: "+cdo.getColValue("fecha"),0,1);
		pc.addCols("Sexo: "+cdo.getColValue("sexo"),0,1);

	pc.setNoColumn(1);
	pc.createTable("babyR",false,0,0.0f,63f);
		pc.setFont(fontSizeB,1);
		pc.addCols("FN: "+cdo.getColValue("fecha_nac_madre"),0,1);
		pc.addCols("Dr. "+cdo.getColValue("pediatra"),0,1);

	pc.setNoColumn(1);
	pc.createTable("babyBarcode",false,0,0.0f,120f);
		pc.addImageCols(pc.getBarCode128(cdo.getColValue("barcode"),0.0f,10.0f),0.0f,1);

	pc.setNoColumnFixWidth(bDetail);
	pc.createTable("baby",false,0,0.0f,126f);
		pc.setFont(fontSizeB,1);
		pc.addCols(cdo.getColValue("nombres").toUpperCase(),0,2);
		pc.addCols(cdo.getColValue("apellidos").toUpperCase()+" ["+cdo.getColValue("d_cedula")+"]",0,2);
		pc.addTableToCols("babyL",0,1);
		pc.addTableToCols("babyR",0,1);
		pc.addTableToCols("babyBarcode",0,2);

	pc.setNoColumn(1);
	pc.createTable("motherL",false,0,0.0f,140.4f);
		pc.setFont(fontSize,1);
		pc.addCols("FN: "+cdo.getColValue("fecha_nac_madre"),0,1);
		pc.addCols("Dr. "+cdo.getColValue("pediatra"),0,1);

	pc.setNoColumn(1);
	pc.createTable("motherR",false,0,0.0f,75.6f);
		pc.setFont(fontSize - 1,1);
		pc.addCols("HN: "+cdo.getColValue("hora_nacimiento"),0,1);
		pc.addCols("FN: "+cdo.getColValue("fecha"),0,1);
		pc.addCols("Sexo: "+cdo.getColValue("sexo"),0,1);

	pc.setNoColumnFixWidth(bDetail);
	pc.createTable("mother",false,0,0.0f,216f);
		pc.setFont(fontSize,1);
		pc.addCols(cdo.getColValue("madrenom").toUpperCase(),0,2);
		pc.addCols(cdo.getColValue("madreape").toUpperCase(),0,2);
		pc.addTableToCols("motherL",0,1);
		pc.addTableToCols("motherR",0,1);

	pc.setNoColumnFixWidth(vMain);
	pc.createTable();
		pc.setFont(fontSize,1);
		pc.setVAlignment(0);
		pc.addCols("",0,1,114f);
		pc.addTableToCols("baby",0,1,0,null,null,0.00f,0.00f,0.00f,0.00f);
		pc.addCols("",0,1);
		pc.setVAlignment(2);
		//pc.addTableToCols("mother",0,1,0,null,null,0.00f,0.00f,0.00f,0.00f);
		pc.addCols("",0,1);
		pc.addCols("",0,1);

} else if (param.getColValue("formatoNeo").equalsIgnoreCase("H2")) {

	Vector vMain = new Vector();
		vMain.addElement(".32");
		vMain.addElement(".56");
		vMain.addElement(".32");
	Vector tblLft = new Vector();
		tblLft.addElement(".40");
		tblLft.addElement(".60");
	Vector tblRgt = new Vector();
		tblRgt.addElement(".38");
		tblRgt.addElement(".62");
	Vector tblOther = new Vector();
		tblOther.addElement("1");

	pc.setNoColumnFixWidth(tblLft);
	pc.createTable("left",false,0,0.0f,75);
		pc.setFont(6,1);
		pc.addCols("Nombre:",0,1);

		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("nombres").toUpperCase()+ " "+cdo.getColValue("apellidos").toUpperCase(),0,1,35f);

		pc.setFont(6,1);
		pc.addCols("FN:",0,1);
		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("fecha"),0,1);

		pc.setFont(6,1);
		pc.addCols("HN:",0,1);
		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("hora_nacimiento"),0,1);

		pc.setFont(6,1);
		pc.addCols("Sexo: ",0,1);
		pc.setFont(5,1);
		pc.addCols(cdo.getColValue("sexo"),0,1);

	pc.setNoColumnFixWidth(tblOther);
	pc.createTable("other",false,0,0.0f,162);
		pc.addCols("",0,1,1f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f,17f);
		pc.setVAlignment(1);
		pc.addBorderCols("BEBE "+cdo.getColValue("d_cedula")+"                                          MADRE",1,1,0.0f,0.00f,0.0f,0.0f,30f);
		pc.addBorderCols("",0,1,0.0f,0.00f,0.0f,0.0f,17f);

	pc.setNoColumnFixWidth(tblRgt);
	pc.createTable("right",false,0,0.0f,75);
		pc.setFont(6,1);
		pc.addCols("Madre:",2,1);

		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("madrenom")+" "+cdo.getColValue("madreape"),0,1,30f);

		pc.setFont(6,1);
		pc.addCols("FN:",1,1);
		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("fecha_nac_madre"),0,1);

		pc.setFont(6,1);
		pc.addCols("Dr.:",1,1);
		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("pediatra"),0,1);

		pc.setFont(6,1);
		pc.addCols("Pac. Id:",2,1);
		pc.setFont(6,1);
		pc.addCols(cdo.getColValue("pac_id_madre")+"-"+cdo.getColValue("admi_madre"),0,1);

	pc.setNoColumnFixWidth(vMain);
	pc.createTable();
		pc.setVAlignment(0);
		pc.addTableToCols("left",0,1,0,null,null,0.00f,0.00f,0.00f,0.00f);
		pc.addTableToCols("other",1,1,0,null,null,0.0f,0.0f,0.0f,0.0f);
		pc.addTableToCols("right",2,1,0,null,null,0.0f,0.0f,0.0f,0.0f);

} else {

	Vector vMain = new Vector();
		vMain.addElement(".30");
		vMain.addElement(".60");
		vMain.addElement(".30");
	Vector tblLft = new Vector();
		tblLft.addElement(".38");
		tblLft.addElement(".62");
	Vector tblRgt = new Vector();
		tblRgt.addElement(".38");
		tblRgt.addElement(".62");
	Vector tblOther = new Vector();
		tblOther.addElement("1");

	pc.setNoColumnFixWidth(tblLft);
	pc.createTable("left",false,0,0.0f,75);
		pc.setFont(6,0);
		pc.addCols("Nombre:",0,1);
		pc.setFont(5,0);
		pc.addCols(cdo.getColValue("nombres")+ " "+cdo.getColValue("apellidos"),0,1,24f);

		pc.setFont(6,0);
		pc.addCols("CED:",0,1);
		pc.setFont(5,0);
		pc.addCols((cdo.getColValue("identidad")!=null?cdo.getColValue("identidad").replace("/",""):""),0,1);

		pc.setFont(6,0);
		pc.addCols("FN:",0,1);
		pc.setFont(5,0);
		pc.addCols(cdo.getColValue("fecha"),0,1);

		pc.setFont(6,0);
		pc.addCols("ADM: "+noAdmision,0,1);
		pc.setFont(5,0);
		pc.addCols("Sexo: "+cdo.getColValue("sexo"),0,1);

	pc.setNoColumnFixWidth(tblOther);
	pc.createTable("other",false,0,0.0f,162);
		pc.addCols("",0,1,1f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f,17f);
		pc.setVAlignment(1);
		pc.addBorderCols("HN: "+cdo.getColValue("hora_nacimiento"),1,1,0.0f,0.05f,0.0f,0.0f,17f);
		pc.addBorderCols("",0,1,0.0f,0.05f,0.0f,0.0f,17f);

	pc.setNoColumnFixWidth(tblRgt);
	pc.createTable("right",false,0,0.0f,75);
		pc.setFont(6,0);
		pc.addCols("Madre:",2,1);
		pc.setFont(5,0);
		pc.addCols(cdo.getColValue("madrenom")+" "+cdo.getColValue("madreape"),0,1,15f);

		pc.setFont(6,0);
		pc.addCols("CED:",1,1);
		pc.setFont(5,0);
		pc.addCols((cdo.getColValue("ced")!=null?cdo.getColValue("ced").replace("/",""):""),0,1);

		pc.setFont(6,0);
		pc.addCols("Dr.:",1,1);
		pc.setFont(5,0);
		pc.addCols(cdo.getColValue("mednom"),0,1);

		pc.setFont(6,0);
		pc.addCols("ADM.:",2,1);
		pc.setFont(5,0);
		pc.addCols(cdo.getColValue("admi_madre")+" FN: "+cdo.getColValue("fecha_nac_madre"),0,1);


	pc.setNoColumnFixWidth(vMain);
	pc.createTable();
		pc.setVAlignment(0);
		pc.addTableToCols("left",0,1,0,null,null,0.05f,0.05f,0.05f,0.05f);
		pc.addTableToCols("other",1,1,0,null,null,0.0f,0.0f,0.0f,0.0f);
		pc.addTableToCols("right",2,1,0,null,null,0.1f,0.1f,0.1f,0.1f);

}

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>