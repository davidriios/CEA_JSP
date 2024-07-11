<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<%

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

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String cds = request.getParameter("cds");
String cdsDesc = request.getParameter("cdsDesc");
String fechaAudit = request.getParameter("fechaAudit");
String fechaIngEgr = request.getParameter("fechaIngEgr");
String fg = request.getParameter("fg")==null?"NIEN":request.getParameter("fg");


sbSql.append(" select getHabitacion(");
sbSql.append(compania);
sbSql.append(",a.pac_id, a.secuencia) as cuarta, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(a.fecha_egreso,'dd/mm/yyyy') as fecha_egreso, a.pac_id||'-'||a.secuencia as pid, p.nombre_paciente, a.pac_id, a.secuencia /*************** ESCALAS **********************//*NORTON*/,( select total from tbl_sal_escala_norton where pac_id  = a.pac_id and secuencia =  a.secuencia and tipo = 'NO' and fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ");
sbSql.append(" and fecha_creacion = ( select max(fecha_creacion) from tbl_sal_escala_norton where pac_id  = a.pac_id and secuencia = a.secuencia and tipo = 'NO' and fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy')  ) ) as ulceras /*MORSE*/ ,( select se.total from tbl_sal_escalas se  where se.pac_id = a.pac_id and se.admision = a.secuencia and se.tipo ='MO' and se.fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') and fecha_mod = ( select max(fecha_mod) from tbl_sal_escalas where pac_id  = a.pac_id and admision =  a.secuencia and tipo = 'MO' and fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy')  ) ) as caidas /*DOLOR*/,( select se.total from tbl_sal_escalas se  where se.pac_id = a.pac_id and se.admision = a.secuencia and se.tipo ='WB' and se.fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') and fecha_mod = ( select max(fecha_mod) from tbl_sal_escalas where pac_id  = a.pac_id and admision = a.secuencia and tipo = 'WB' and fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy')  ) ) as dolor /*CONCENCIA*/ ,( select total from tbl_sal_escala_coma  where pac_id = a.pac_id and secuencia = a.secuencia and fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') and fecha_registro = ( select max(fecha_registro) from tbl_sal_escala_coma where pac_id  = a.pac_id and secuencia =  a.secuencia  and fecha = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy')  ) ) as concencia ");

sbSql.append(", ( select max(substr(a.descripcion, instr(a.descripcion,' ',-1) , length(a.descripcion))) as grado from tbl_sal_concepto_ulcera a, tbl_sal_det_ulcera_presion b where a.codigo = b.cod_concepto and b.pac_id = a.pac_id and b.secuencia = a.secuencia and a.descripcion like '%GRADO%' and trunc(fecha_up) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ");
sbSql.append(" and trunc(fecha_up) = (select max(fecha_up) from tbl_sal_det_ulcera_presion where pac_id = a.pac_id and secuencia = a.secuencia and a.codigo = b.cod_concepto and trunc(fecha_up) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ");
sbSql.append(" and rownum = 1) ) as eup ");

sbSql.append(" ,( select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = a.pac_id and admision = a.secuencia and orden_diag = 1 and tipo = 'I' and trunc(fecha_creacion) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ");
sbSql.append(" and fecha_creacion = (select max(fecha_creacion) from tbl_adm_diagnostico_x_admision where pac_id = a.pac_id and admision = a.secuencia and tipo = 'I' and trunc(fecha_creacion) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') and orden_diag = 1 and rownum = 1) and rownum = 1 ) as diag_ing ");

sbSql.append(" ,( select case when count(*) > 0 then 'X' else '-' end from tbl_sal_necesidad_paciente  where pac_id = a.pac_id and admision = a.secuencia and trunc(fecha_creacion) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ) as val_nec");

sbSql.append(" , ( select case when count(*) > 0 then 'X' else '-' end from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and tipo_signo='PO'  and personal = 'E' and status = 'A' and trunc(fecha) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ");

sbSql.append(" and trunc(fecha) = ( select max(fecha) from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and tipo_signo='PO' and personal = 'E' and status = 'A' and trunc(fecha) = to_date('");
sbSql.append(fechaAudit);
sbSql.append("','dd/mm/yyyy') ");
sbSql.append(" and rownum = 1) ) as sv ");


// SF
//sbSql.append(" ,nvl(( select 'X' from tbl_sal_examen_fisico where  pac_id = a.pac_id and admision= a.secuencia and tipo ='E' and nota_id is not null and (normal = 'A' OR observacion is not null)),'-') as ex_fis ");

sbSql.append(" ,nvl(( select 'X' from tbl_sal_examen_fisico where  pac_id = a.pac_id and admision= a.secuencia and tipo ='E' and (normal = 'A' OR observacion is not null)),'-') as ex_fis ");

sbSql.append(", nvl((select 'OK' from tbl_sal_educacion_paciente where pac_id=a.pac_id and admision= a.secuencia and trunc(fecha_creacion) = (select max(fecha_creacion) from tbl_sal_educacion_paciente where pac_id=a.pac_id and admision= a.secuencia) ),' ') as edu_pte ");

if (fg.trim().equals("NEEN")||fg.trim().equals("NENO")){
	sbSql.append(" , ( select count(*) from tbl_sal_orden_medica aa, tbl_sal_detalle_orden_med bb where aa.pac_id=bb.pac_id and aa.secuencia = bb.secuencia and aa.codigo = bb.orden_med and bb.tipo_orden = 7 and aa.pac_id = a.pac_id and aa.secuencia = a.secuencia and trunc(aa.fecha_creacion) = to_date('");
	sbSql.append(fechaAudit);
	sbSql.append("','dd/mm/yyyy') )  om_salida  ");
}
else if (fg.trim().equals("NIPA")){
	sbSql.append(" , ( select case when count(*) > 0 then 'SI' else 'NO' end from tbl_sal_nota_egreso_enf where pac_id = a.pac_id and admision = a.secuencia  and tipo_nota = 'NEPA' )  cond_nipa  ");
}
else if (fg.trim().equals("NINO")){
	sbSql.append(" , ( select case when count(*) > 0 then 'SI' else 'NO' end from tbl_sal_notas_diarias_enf where pac_id = a.pac_id and admision = a.secuencia  and tipo_nota = 'NDNO' )  as nota_seg  ");
}
else if (fg.trim().equals("NIEN")){
	sbSql.append(" , nvl( (select 'X' from tbl_sal_Resultado_nota where pac_id=a.pac_id and secuencia=a.secuencia and observacion is not null and fecha_nota = to_date('");
	sbSql.append(fechaAudit);
	sbSql.append("','dd/mm/yyyy') ");
	sbSql.append(" and fecha_creacion = ( select max(fecha_creacion) from tbl_sal_Resultado_nota where pac_id=a.pac_id and secuencia=a.secuencia and observacion is not null)) ,'-') as nota_seg ");
}


sbSql.append(" /**********************************************/  from tbl_adm_admision a, vw_adm_paciente p where a.pac_id = p.pac_id and a.centro_servicio = ");
sbSql.append(cds);

if (fg.trim().equals("NIEN")||fg.trim().equals("NIPA")||fg.trim().equals("NINO")) {
	/*sbSql.append(" and trunc(a.fecha_ingreso) = to_date('");
	sbSql.append(fechaIngEgr);
	sbSql.append("','dd/mm/yyyy') ");
	sbSql.append(" order by a.fecha_ingreso");*/
}
else {
	/*sbSql.append(" and trunc(a.fecha_egreso) = to_date('");
	sbSql.append(fechaIngEgr);
	sbSql.append("','dd/mm/yyyy') ");
	sbSql.append(" order by a.fecha_egreso");*/
}

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

	float width = 72* 8.5f;//612
	float height = 72 * 14f;//1008
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " GERENCIA DE ENFERMERIA";
	String subTitle = "AUDITORIA DEL EXPEDIENTE";

	String xtraSubtitle = "";
	if (fg.equals("NIEN"))xtraSubtitle = "NOTAS DE INGRESO DE ENFERMERIA";
	else if (fg.equals("NEEN"))xtraSubtitle = "NOTAS DE EGRESO DE ENFERMERIA";
	else if (fg.equals("NIPA"))xtraSubtitle = "NOTAS DE INGRESO DE PARTOS";
	else if (fg.equals("NINO"))xtraSubtitle = "NOTAS DE INGRESO NEONATOLOGIA";
	else if (fg.equals("NENO"))xtraSubtitle = "NOTAS DE EGRESO NEONATOLOGIA";

	//NDNO

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblImg = new Vector();
	tblImg.addElement("1");
	pc.setNoColumnFixWidth(tblImg);
	pc.createTable();

	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);
	pc.addTable();

	Vector dHeader = new Vector();
	dHeader.addElement("4.25");
	dHeader.addElement("4.25");

	/**/
	dHeader.addElement("6.05");
	dHeader.addElement("6.05");
	dHeader.addElement("6.05");
	dHeader.addElement("6.05");
	dHeader.addElement("6.05");
	/**/

	dHeader.addElement("3.25");
	dHeader.addElement("3.25");
	dHeader.addElement("3.25");
	dHeader.addElement("5.25");
	dHeader.addElement("2.25");
	dHeader.addElement("3.25");
	dHeader.addElement("3.25");
	dHeader.addElement("6.25");
	dHeader.addElement("6.25");
	dHeader.addElement("6.25");
	dHeader.addElement("6.25");
	dHeader.addElement("6.25");
	dHeader.addElement("6.25");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	pc.setFont(10, 1);

	pc.addCols(title, 1, dHeader.size(),15.2f);
	pc.addCols(subTitle, 1, dHeader.size());
	pc.addCols(xtraSubtitle, 1, dHeader.size());
	pc.addCols("", 1, dHeader.size(), 10.2f);

	pc.setVAlignment(0);

	pc.setFont(10, 0);
	pc.addCols("Fecha: "+fechaAudit, 0, 3);
	pc.addCols("Sala: "+cdsDesc, 0, 8);
	pc.addCols("Turno: ", 0, 2);
	pc.addBorderCols(" ", 0, 2, 0.5f,0.0f,0.0f,0.0f);
	pc.addCols("", 0, 5);

	pc.addCols("", 1, dHeader.size());


	pc.setFont(7, 1);

	if (fg.equals("NIEN")||fg.equals("NIPA")||fg.equals("NINO")){

		pc.addBorderCols("",0,7);
		pc.addBorderCols("ESCALAS",1,5);
		pc.addBorderCols("NOTAS",1,6);
		pc.addBorderCols((fg.equals("NIEN")||fg.equals("NIPA")?"OTROS":""),1,2);

		pc.addBorderCols("Cuarto",0,1);
		pc.addBorderCols("F.Ingreso",1,1);
		pc.addBorderCols("Nombre Paciente",0,5);

		pc.addBorderCols("Ulceras",1,1);
		pc.addBorderCols("Caídas",1,1);
		pc.addBorderCols("Dolor",1,1);

		if (fg.equals("NIEN")){
			pc.addBorderCols("Conciencia",1,1);
		}else{
			pc.addBorderCols(" ",1,1);
		}

		pc.addBorderCols("",1,1);

		pc.addBorderCols("INGRESO",1,2);
		pc.addBorderCols("NOTA.SEG",1,1);
		pc.addBorderCols("TAMIZAJE",1,1);
		pc.addBorderCols("EX.FIS",1,1);
		pc.addBorderCols("COND.ESP.",1,1);

		pc.addCols((fg.equals("NIEN")||fg.equals("NIPA")?"VAL.NEC":""),1,1);
		pc.addBorderCols((fg.equals("NIEN")||fg.equals("NIPA")?"EDUC.PTE":""),1,1, 0.0f,0.0f,0.5f,0.5f);

		pc.addBorderCols(" -- ",1,7);

		pc.addBorderCols("N",1,1);
		pc.addBorderCols("M",1,1);
		pc.addBorderCols("D",1,1);

		if (fg.equals("NIEN")){
			pc.addBorderCols("G",1,1);
		}else{
			pc.addBorderCols(" ",1,1);
		}

		pc.addBorderCols("EUP",1,1);

		pc.addBorderCols("S/V",1,1);
		pc.addBorderCols("Dx.",1,1);

		pc.addBorderCols(" -- ",1,4);
		pc.addBorderCols(" ",1,1, 0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(" ",1,1, 0.5f,0.0f,0.5f,0.5f);
	}
	else if (fg.equals("NEEN")||fg.equals("NENO")){
			pc.addBorderCols("",0,7);
		pc.addBorderCols("ORDEN MEDICA",1,2);
		pc.addBorderCols("N. DE EGRESO",1,2);
		pc.addBorderCols(fg.equals("NEEN")?"ESTADO CONCIENCIA":"VIA NACIMIENTO",1,4);
		pc.addBorderCols("CONDICION",1,1);
		pc.addCols("",0,4);

		pc.addBorderCols("Cuarto",0,1);
		pc.addBorderCols("F.Egreso",1,1);
		pc.addBorderCols("Nombre Paciente",0,5);

		pc.addBorderCols("SI",1,1);
		pc.addBorderCols("NO",1,1);

		pc.addBorderCols("SI",1,1);
		pc.addBorderCols("NO",1,1);

		pc.addBorderCols(fg.equals("NEEN")?"Conciente":"Cesárea",1,2);
		pc.addBorderCols(fg.equals("NEEN")?"Orientado":"Parto",1,2);

		pc.addBorderCols("*",1,1);

		pc.addCols("",0,4);
	}

	pc.setFont(7, 0);
	for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);

			if (fg.equals("NIEN") || fg.equals("NIPA") || fg.equals("NINO")){
			// SF: fecha_creacion

				String sqlImc = "select evaluacion from tbl_sal_nutricion_parenteral where pac_id = "+cdo.getColValue("pac_id")+" and admision= "+cdo.getColValue("secuencia")+" and tipo = 'ENRS' and nvl(trunc(fecha_creac),to_date('"+fechaAudit+"','dd/mm/yyyy')) = to_date('"+fechaAudit+"','dd/mm/yyyy') and id = (select max(id) from tbl_sal_nutricion_parenteral where pac_id = "+cdo.getColValue("pac_id")+" and admision= "+cdo.getColValue("secuencia")+" and tipo = 'ENRS' and nvl(trunc(fecha_creac),to_date('"+fechaAudit+"','dd/mm/yyyy')) = to_date('"+fechaAudit+"','dd/mm/yyyy') )";

				//  SF: and nota_id is not null
				String sqlPropIng = "select nota from tbl_sal_nota_ingreso_enf where pac_id = "+cdo.getColValue("pac_id")+" and admision = "+cdo.getColValue("secuencia")+" and tipo_nota = '"+fg+"'";

				Properties propImc, propIng = new Properties();
				propImc = SQLMgr.getDataProperties(sqlImc);
				propIng  = SQLMgr.getDataProperties(sqlPropIng);

				pc.addBorderCols(cdo.getColValue("cuarta"),0,1);
				pc.addBorderCols(cdo.getColValue("fecha_ingreso"),1,1);
				pc.addBorderCols(cdo.getColValue("pid")+" - "+cdo.getColValue("nombre_paciente"),0,5);
				pc.addBorderCols(cdo.getColValue("ulceras"),1,1);
				pc.addBorderCols(cdo.getColValue("caidas"),1,1);
				pc.addBorderCols(cdo.getColValue("dolor"),1,1);

				if (fg.equals("NIEN")){
					pc.addBorderCols(cdo.getColValue("concencia"),1,1);
				}else{
					pc.addBorderCols(" ",1,1);
				}
				pc.addBorderCols(cdo.getColValue("eup"),1,1);

				pc.addBorderCols(cdo.getColValue("sv"),1,1);
				pc.addBorderCols(cdo.getColValue("diag_ing"),1,1);


				//NOTA.SEG
				if (fg.equals("NIEN")){
						pc.addBorderCols(cdo.getColValue("nota_seg"),1,1);
				}else if(fg.equals("NIPA")){
					String notaSeg = "";
				if (propIng!=null){
					if (!propIng.getProperty("presentacion").equals("") || !propIng.getProperty("situacion").equals("")||!propIng.getProperty("dorso").equals("") ||!propIng.getProperty("actividad").equals("") ||!propIng.getProperty("can_dura").equals("") ||!propIng.getProperty("membranas").equals("") ||!propIng.getProperty("liquido").equals("")||!propIng.getProperty("fcf").equals("")) notaSeg = "X";
				}
					pc.addBorderCols(notaSeg,1,1);
				}else if (fg.equals("NINO")){
					pc.addBorderCols(cdo.getColValue("nota_seg"),1,1);
				}

				pc.addBorderCols((propImc!=null && propImc.getProperty("volumen_dia")!=null?propImc.getProperty("volumen_dia"):""),1,1);

				pc.addBorderCols(cdo.getColValue("ex_fis"),1,1);

				//pc.addBorderCols((propIng!=null && propIng.getProperty("codDiag")!=null?propIng.getProperty("codDiag"):""),1,1);

			 String condEsp = "-";

			 if(propIng!=null) {
				 if (fg.equals("NIEN")){
					for (int p = 1; p<=8; p++){
						 if (propIng.getProperty("aplicar"+p) != null && propIng.getProperty("aplicar"+p).equals("S") && propIng.getProperty("observacion"+p) != null && !propIng.getProperty("observacion"+p).equals("") ){
						 condEsp = "X";
						 }
					}
				}else if (fg.equals("NINO")){
						if ( !propIng.getProperty("apgar1").equals("")||!propIng.getProperty("apgar5").equals("")||!propIng.getProperty("llanto").equals("")||!propIng.getProperty("piel").equals("")||!propIng.getProperty("piel2").equals("")||!propIng.getProperty("malformacion").equals("")||!propIng.getProperty("profilaxis").equals("")||!propIng.getProperty("profilaxis2").equals("")||!propIng.getProperty("queda_en").equals("")||!propIng.getProperty("o2").equals("")||!propIng.getProperty("permeabilidad").equals("")||!propIng.getProperty("permeabilidadCo").equals("") ){
						 condEsp = "X";
					}
				}
			 }

			 if (fg.equals("NIEN")||fg.equals("NINO")){
				pc.addBorderCols(condEsp,1,1);
			 }else if(fg.equals("NIPA")){
				 pc.addBorderCols(cdo.getColValue("cond_nipa"),1,1);
			 }

			 pc.addBorderCols(fg.equals("NIEN")||fg.equals("NIPA")?cdo.getColValue("val_nec"):"",1,1);
			 pc.addBorderCols(fg.equals("NIEN")||fg.equals("NIPA")?cdo.getColValue("edu_pte"):"",1,1);

			}else if (fg.equals("NEEN") || fg.equals("NENO") ){

			 String sqlRelevo = "select nota from tbl_sal_nota_egreso_enf where pac_id="+cdo.getColValue("pac_id")+" and admision="+cdo.getColValue("secuencia")+" and tipo_nota = '"+fg+"'";

				Properties propRelevo = new Properties();
				propRelevo = SQLMgr.getDataProperties(sqlRelevo);

				pc.addBorderCols(cdo.getColValue("cuarta"),0,1);
			pc.addBorderCols(cdo.getColValue("fecha_egreso"),1,1);
			pc.addBorderCols(cdo.getColValue("pid")+" - "+cdo.getColValue("nombre_paciente"),0,5);

			int omSal = Integer.parseInt(cdo.getColValue("om_salida")==null?"0":cdo.getColValue("om_salida"));
			String omS=(omSal>=1?"X":"");
			String omN=(omSal<1?"X":"");

			pc.addBorderCols(omS,1,1);
			pc.addBorderCols(omN,1,1);

			pc.addBorderCols((propRelevo!=null && propRelevo.getProperty("relevo").equals("S")?"SI":""),1,1);

			pc.addBorderCols((propRelevo==null || (propRelevo.getProperty("relevo").equals("")||propRelevo.getProperty("relevo").equals("N"))?"NO":""),1,1);

			if (fg.equals("NEEN")){
				pc.addBorderCols((propRelevo!=null && propRelevo.getProperty("estado").equals("C")?"X":""),1,2);
				pc.addBorderCols((propRelevo!=null && propRelevo.getProperty("estado").equals("O")?"X":""),1,2);
			}else{
				pc.addBorderCols((propRelevo!=null && propRelevo.getProperty("viaNacimiento").equals("CE")?"X":""),1,2);
				pc.addBorderCols((propRelevo!=null && propRelevo.getProperty("viaNacimiento").equals("PA")?"X":""),1,2);
			}

			 String cond = "-";

			 if(propRelevo!=null) {
				for (int p = 1; p<=22; p++){
					 if (propRelevo.getProperty("aplicar"+p) != null && propRelevo.getProperty("aplicar"+p).equals("S") )cond = "X";
				}
			 }

			pc.addBorderCols(cond,1,1);

			pc.addCols("",0,4);

		}



	}//for

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>