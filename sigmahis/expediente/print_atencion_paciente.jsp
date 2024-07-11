<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
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

ArrayList alM = new ArrayList();
ArrayList alE = new ArrayList();
ArrayList alC = new ArrayList();
ArrayList alMD = new ArrayList();
ArrayList alED = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if (fp == null) fp = "";
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (appendFilter == null) appendFilter = "";

StringBuffer sbSql = new StringBuffer();
sbSql.append("select a.pac_id, a.secuencia, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(a.fecha_egreso,'dd/mm/yyyy') as fecha_egreso, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id=a.pac_id) as fecha_nacimiento, a.codigo_paciente, (select nombre_paciente from vw_adm_paciente where pac_id=a.pac_id) as nombre_paciente, (select id_paciente from vw_adm_paciente where pac_id=a.pac_id) as cedula_pasaporte from tbl_adm_admision a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noAdmision);
CommonDataObject pac = SQLMgr.getData(sbSql.toString());

//-----------------------------   R E S U M E N   -----------------------------
sbSql = new StringBuffer();
sbSql.append("select distinct a.medico, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombre, join(cursor(select y.descripcion from tbl_adm_medico_especialidad z, tbl_adm_especialidad_medica y where z.especialidad=y.codigo and z.medico=a.medico order by z.secuencia), ', ') as especialidad, a.tipo from (");
//P R O G R E S O   C L I N I C O
sbSql.append("select '' as tipo, medico from tbl_sal_progreso_clinico where pac_id=");
sbSql.append(pacId);
sbSql.append(" and admision=");
sbSql.append(noAdmision);
//I N T E R C O N S U L T A
sbSql.append(" union ");
sbSql.append("select '(i) ' as tipo, medico from tbl_sal_interconsultor_espec where pac_id=");
sbSql.append(pacId);
sbSql.append(" and secuencia=");
sbSql.append(noAdmision);
//A N E S T E S I O L O G O
sbSql.append(" union ");
sbSql.append("select '(a) ' as tipo, cod_anestesiologo from tbl_sal_eval_preanestesica where pac_id=");
sbSql.append(pacId);
sbSql.append(" and admision=");
sbSql.append(noAdmision);
sbSql.append(" and cod_anestesiologo is not null");
sbSql.append(") a order by 2");
alM = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
//D E T A L L E   D E   N O T A S   D E   E N F E R M E R I A
sbSql.append("select distinct a.usuario_creacion, (select name from tbl_sec_users where user_name=a.usuario_creacion) as nombre, '(e)' as tipo from tbl_sal_resultado_nota a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noAdmision);
//S I G N O S   V I T A L E S
sbSql.append(" union all ");
sbSql.append("select distinct a.usuario_creacion, (select name from tbl_sec_users where user_name=a.usuario_creacion) as nombre, '(a)' as tipo from tbl_sal_signo_paciente a where a.tipo_persona in ('T','A') and a.status = 'A' and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noAdmision);
//N O T A   D E   T E R A P I A
sbSql.append(" union all ");
sbSql.append("select distinct a.usuario_creacion, (select name from tbl_sec_users where user_name=a.usuario_creacion) as nombre, '(t)' as tipo from tbl_sal_nota_terapia a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admision=");
sbSql.append(noAdmision);
sbSql.append(" order by 2");
alE = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select distinct b.unidad_admin, (select descripcion from tbl_cds_centro_servicio where codigo=b.unidad_admin) as nombre from tbl_adm_cama_admision a, tbl_sal_habitacion b where a.habitacion=b.codigo and a.compania=b.compania and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admision=(select adm_root from tbl_adm_admision where pac_id=");
sbSql.append(pacId);
sbSql.append(" and secuencia=");
sbSql.append(noAdmision);
sbSql.append(")");
sbSql.append(" order by 2");
alC = SQLMgr.getDataList(sbSql.toString());

//-----------------------------   D E T A L L E   -----------------------------
sbSql = new StringBuffer();
//P R O G R E S O   C L I N I C O
sbSql.append("select to_char(a.fecha,'dd/mm/yyyy') as fecha_atencion, null as hora_atencion, a.medico, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombre, '' as tipo from tbl_sal_progreso_clinico a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admision=");
sbSql.append(noAdmision);
//I N T E R C O N S U L T A
sbSql.append(" union all ");
sbSql.append("select to_char(a.fecha,'dd/mm/yyyy') as fecha_atencion, null as hora_atencion, a.medico, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombre, '(i) ' as tipo from tbl_sal_interconsultor_espec a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noAdmision);
//A N E S T E S I O L O G O
sbSql.append(" union all ");
sbSql.append("select to_char(a.fecha,'dd/mm/yyyy') as fecha_atencion, to_char(a.fecha,'hh12:mi:ss am') as hora_atencion, a.cod_anestesiologo, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.cod_anestesiologo) as nombre, '(a)' as tipo from tbl_sal_eval_preanestesica a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admision=");
sbSql.append(noAdmision);
sbSql.append(" order by 1, 2, 4");
alMD = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
//D E T A L L E   D E   N O T A S   D E   E N F E R M E R I A
sbSql.append("select a.fecha_nota, a.hora, a.fecha, a.hora_r, to_char(a.fecha,'dd/mm/yyyy') as fecha_atencion, to_char(a.hora_r,'hh12:mi:ss am') as hora_atencion, a.usuario_creacion, (select name from tbl_sec_users where user_name=a.usuario_creacion) as nombre, '(e)' as tipo from tbl_sal_resultado_nota a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noAdmision);
//S I G N O S   V I T A L E S
sbSql.append(" union all ");
sbSql.append("select null, null, null, a.fecha, to_char(a.fecha,'dd/mm/yyyy') as fecha_atencion, to_char(a.hora,'hh12:mi:ss am') as hora_atencion, a.usuario_creacion, (select name from tbl_sec_users where user_name=a.usuario_creacion) as nombre, '(a)' as tipo from tbl_sal_signo_paciente a where a.tipo_persona in ('T','A') and a.status = 'A' and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noAdmision);
//N O T A   D E   T E R A P I A
sbSql.append(" union all ");
sbSql.append("select null, null, null, a.fecha_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_atencion, null as hora_atencion, a.usuario_creacion, (select name from tbl_sec_users where user_name=a.usuario_creacion) as nombre, '(t)' as tipo from tbl_sal_nota_terapia a where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admision=");
sbSql.append(noAdmision);
sbSql.append(" order by 1, 2, 3, 4, 8");
alED = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float fontSize = 8.0f;
	float pFontSize = 8.0f;
	float rFontSize = 7.0f;
	float dFontSize = 7.0f;
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
	String title = "ATENCION DEL PACIENTE";
	String subtitle = "";
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	Vector vFooter = new Vector();
		vFooter.addElement(".33");
		vFooter.addElement(".33");
		vFooter.addElement(".34");
	Vector vMain = new Vector();
		vMain.addElement(".005");
		vMain.addElement(".49");//291.06
		vMain.addElement(".01");
		vMain.addElement(".24");//142.56
		vMain.addElement(".01");
		vMain.addElement(".24");//142.56
		vMain.addElement(".005");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	footer.setFont(6,0);
	footer.setNoColumnFixWidth(vMain);
	footer.createTable();
		footer.addCols("",0,vMain.size(),0,null,0.5f,0.0f,0.0f,0.0f,null);
		footer.addCols("",0,vMain.size());

		footer.addCols("",0,1);
			footer.setVAlignment(0);
			footer.setNoColumnFixWidth(vFooter);
			footer.createTable("medico",true,0,0.0f,291.06f);
				footer.addCols("(i) = INTERCONSULTA",0,1);
				footer.addCols("(a) = ANESTESIA",0,1);
				footer.addCols("",0,1);
			footer.useTable("main");
		footer.addTableToCols("medico",1,1,0,null,null,0.5f,0.5f,0.5f,0.5f);
		footer.addCols("",0,1);
			footer.setVAlignment(0);
			footer.setNoColumnFixWidth(vFooter);
			footer.createTable("enfermera",true,0,0.0f,291.06f);
				footer.addCols("(e) = ENFEMERIA",0,1);
				footer.addCols("(a) = AUXILIAR",0,1);
				footer.addCols("(t) = TERAPIA",0,1);
			footer.useTable("main");
		footer.addTableToCols("enfermera",1,3,0,null,null,0.5f,0.5f,0.5f,0.5f);
		footer.addCols("",0,1);

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	Vector vHeader = new Vector();
		vHeader.addElement(".05");//tipo
		vHeader.addElement(".05");//fecha
		vHeader.addElement(".10");//fecha
		vHeader.addElement(".17");//hora
		vHeader.addElement(".20");//medico, enfermera, auxiliar, terapista
		vHeader.addElement(".43");//especialidad
	Vector vPac = new Vector();
		vPac.addElement("0.09");
		vPac.addElement("0.10");
		vPac.addElement("0.10");
		vPac.addElement("0.10");
		vPac.addElement("0.10");
		vPac.addElement("0.13");
		vPac.addElement("0.13");
		vPac.addElement("0.12");
		vPac.addElement("0.13");

	//table header
	pc.setNoColumnFixWidth(vMain);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, vMain.size());

		pc.setFont(fontSize,1,Color.WHITE);
		pc.addCols(". . . : : :   P A C I E N T E   : : : . . .",1,vMain.size(),Color.GRAY);
		pc.addCols("",1,vMain.size());

		pc.setNoColumnFixWidth(vPac);
		pc.createTable("pac",true,0,leftRightMargin*2);
			pc.setFont(pFontSize,1);
			pc.addCols("Paciente:",0,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("nombre_paciente"),1,4,null,0.5f,0.0f,0.0f,0.0f);
			pc.setFont(pFontSize,1);
			pc.addCols("Cédula/Pasaporte:",2,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("cedula_pasaporte"),1,1,null,0.5f,0.0f,0.0f,0.0f);
			pc.setFont(pFontSize,1);
			pc.addCols("Fecha Ingreso:",2,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("fecha_ingreso"),1,1,null,0.5f,0.0f,0.0f,0.0f);

			pc.setFont(pFontSize,1);
			pc.addCols("Fecha Nac.:",0,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("fecha_nacimiento"),1,2,null,0.5f,0.0f,0.0f,0.0f);
			pc.setFont(pFontSize,1);
			pc.addCols("Cód. Pac.:",2,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("codigo_paciente")+" ["+pac.getColValue("pac_id")+"]",1,1,null,0.5f,0.0f,0.0f,0.0f);
			pc.setFont(pFontSize,1);
			pc.addCols("Admisión:",2,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("secuencia"),1,1,null,0.5f,0.0f,0.0f,0.0f);
			pc.setFont(pFontSize,1);
			pc.addCols("Fecha Egreso:",2,1);
			pc.setFont(pFontSize,0);
			pc.addCols(pac.getColValue("fecha_egreso"),1,1,null,0.5f,0.0f,0.0f,0.0f);
		pc.useTable("main");
		pc.addTableToCols("pac",1,vMain.size());
		pc.addCols("",1,vMain.size());
	pc.setTableHeader(5);//create de table header (2 rows) and add header to the table



	pc.addCols(" ",1,vMain.size());
	pc.setFont(fontSize,1,Color.WHITE);
	pc.addCols(". . . : : :   R E S U M E N   D E   A T E N C I O N   : : : . . .",1,vMain.size(),Color.GRAY);
	pc.addCols("",1,vMain.size());

		pc.setVAlignment(0);
		pc.setNoColumnFixWidth(vHeader);
		pc.createTable("medico",true,0,0.0f,291.06f);
			pc.setFont(rFontSize,1);
			pc.addBorderCols("MEDIC@S ("+alM.size()+")",1,5,Color.LIGHT_GRAY);
			pc.addBorderCols("ESPECIALIDAD",1,1,Color.LIGHT_GRAY);
			pc.setTableHeader(1);

			pc.setFont(rFontSize,0);
			//table body
			for (int i=0; i<alM.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) alM.get(i);

				pc.addCols(cdo.getColValue("tipo"),1,1);
				pc.addCols(cdo.getColValue("nombre"),0,4);
				pc.addCols(cdo.getColValue("especialidad"),0,1);
				if ((i % 50 == 0) || ((i + 1) == alM.size()))
				{
					pc.useTable("main");
					pc.flushTableBody(true);
					pc.useTable("medico");
				}
			}
			if (alM.size() == 0) pc.addCols(" ",0,vHeader.size());
		pc.useTable("main");
	pc.addCols("",0,1);
	pc.addTableToCols("medico",1,1,0,null,null,0.5f,0.5f,0.5f,0.5f);
	pc.addCols("",0,1);
		pc.setNoColumnFixWidth(vHeader);
		pc.createTable("enfermera",true,0,0.0f,142.56f);
			pc.setFont(rFontSize,1);
			pc.addBorderCols("ENF., AUX. & TERAPISTAS ("+alE.size()+")",1,vHeader.size(),Color.LIGHT_GRAY);
			pc.setTableHeader(1);

			pc.setFont(rFontSize,0);
			//table body
			for (int i=0; i<alE.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) alE.get(i);

				pc.addCols(cdo.getColValue("tipo"),1,2);
				pc.addCols(cdo.getColValue("nombre"),0,vHeader.size()-2);
				if ((i % 50 == 0) || ((i + 1) == alE.size()))
				{
					pc.useTable("main");
					pc.flushTableBody(true);
					pc.useTable("enfermera");
				}
			}
			if (alE.size() == 0) pc.addCols(" ",0,vHeader.size());
		pc.useTable("main");
	pc.addTableToCols("enfermera",1,1,0,null,null,0.5f,0.5f,0.5f,0.5f);
	pc.addCols("",0,1);
		pc.setNoColumnFixWidth(vHeader);
		pc.createTable("cds",true,0,0.0f,142.56f);
			pc.setFont(rFontSize,1);
			pc.addBorderCols("CENTROS DE SERVICIO ("+alC.size()+")",1,vHeader.size(),Color.LIGHT_GRAY);
			pc.setTableHeader(1);

			pc.setFont(rFontSize,0);
			//table body
			for (int i=0; i<alC.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) alC.get(i);

				pc.addCols(cdo.getColValue("nombre"),0,vHeader.size());
				if ((i % 50 == 0) || ((i + 1) == alC.size()))
				{
					pc.useTable("main");
					pc.flushTableBody(true);
					pc.useTable("enfermera");
				}
			}
			if (alC.size() == 0) pc.addCols(" ",0,vHeader.size());
		pc.useTable("main");
	pc.addTableToCols("cds",1,1,0,null,null,0.5f,0.5f,0.5f,0.5f);
	pc.addCols("",0,1);



	pc.addCols(" ",1,vMain.size());
	pc.setFont(fontSize,1,Color.WHITE);
	pc.addCols(". . . : : :   D E T A L L E   D E   A T E N C I O N   : : : . . .",1,vMain.size(),Color.GRAY);
	pc.addCols("",1,vMain.size());

	pc.setVAlignment(0);
	pc.setNoColumnFixWidth(vHeader);
	pc.createTable("medico",true,0,0.0f,291.06f);
		pc.setFont(dFontSize,1);
		pc.addBorderCols("FECHA",1,3,Color.LIGHT_GRAY);
		pc.addBorderCols("HORA",1,1,Color.LIGHT_GRAY);
		pc.addBorderCols("MEDIC@S ("+alMD.size()+")",1,2,Color.LIGHT_GRAY);
		pc.setTableHeader(1);

		pc.setFont(dFontSize,0);
		//table body
		for (int i=0; i<alMD.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) alMD.get(i);

			pc.addCols(cdo.getColValue("tipo"),1,1);
			pc.addCols(cdo.getColValue("fecha_atencion"),1,2);
			pc.addCols(cdo.getColValue("hora_atencion"),1,1);
			pc.addCols(cdo.getColValue("nombre"),0,2);
			if ((i % 50 == 0) || ((i + 1) == alMD.size()))
			{
				pc.useTable("main");
				pc.flushTableBody(true);
				pc.useTable("medico");
			}
		}
		if (alMD.size() == 0) pc.addCols(" ",0,vHeader.size());
	pc.useTable("main");
	pc.addCols("",0,1);
	pc.addTableToCols("medico",1,1,0,null,null,0.5f,0.5f,0.5f,0.5f);
	pc.addCols("",0,1);
	pc.setNoColumnFixWidth(vHeader);
	pc.createTable("enfermera",true,0,0.0f,291.06f);
		pc.setFont(dFontSize,1);
		pc.addBorderCols("FECHA",1,3,Color.LIGHT_GRAY);
		pc.addBorderCols("HORA",1,1,Color.LIGHT_GRAY);
		pc.addBorderCols("ENF., AUX. & TERAPISTAS ("+alED.size()+")",1,2,Color.LIGHT_GRAY);
		pc.setTableHeader(1);

		pc.setFont(dFontSize,0);
		//table body
		for (int i=0; i<alED.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) alED.get(i);

			pc.addCols(cdo.getColValue("tipo"),1,1);
			pc.addCols(cdo.getColValue("fecha_atencion"),1,2);
			pc.addCols(cdo.getColValue("hora_atencion"),1,1);
			pc.addCols(cdo.getColValue("nombre"),0,2);
			if ((i % 50 == 0) || ((i + 1) == alED.size()))
			{
				pc.useTable("main");
				pc.flushTableBody(true);
				pc.useTable("enfermera");
			}
		}
		if (alED.size() == 0) pc.addCols(" ",0,vHeader.size());
	pc.useTable("main");
	pc.addTableToCols("enfermera",0,3,0,null,null,0.5f,0.5f,0.5f,0.5f);
	pc.addCols("",0,1);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>