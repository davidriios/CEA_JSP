<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
	ArrayList alE = new ArrayList();
	CommonDataObject cdo = new CommonDataObject();

	String sql = "", appendFilter = "";;

	int total_pac_sin_benef = 0;
	int cupos_sop = 0;
	int totPacOtros  = 0,  totIngOtros = 0,  totEgrOtros = 0;
	int totActIntAdl = 0, totIngIntAdl = 0, totEgrIntAdl = 0;
	int totActIntPed = 0, totIngIntPed = 0, totEgrIntPed = 0 , totCuposSOP = 0, totCuposSOPfinal = 0;
	int totPacAct    = 0, totPacIng    = 0, totPacEgr    = 0;
	int totPacAct_IntAdult = 0, totPacIng_IntAdult = 0, totPacEgr_IntAdult = 0;
	int totPacAct_IntPed   = 0, totPacIng_IntPed   = 0, totPacEgr_IntPed   = 0;
	int tot_unidades = 0;

	if (appendFilter == null) appendFilter = "";

	sql = "select codigo, descripcion from tbl_cds_centro_servicio where flag_cds = 'SAL'";
	alE = SQLMgr.getDataList(sql);
	sql = "select count(*) as total";

	for(int i = 0; i<alE.size();i++){
		CommonDataObject cdoD = (CommonDataObject) alE.get(i);
		sql += ", nvl(sum(decode(cds.codigo, "+cdoD.getColValue("codigo")+", 1, 0)), 0) as centro_" + cdoD.getColValue("codigo");
	}
	sql += " from tbl_adm_cama_admision aca, tbl_adm_paciente p, tbl_adm_admision aa, tbl_sal_tipo_habitacion sth, tbl_sal_habitacion sh, tbl_cds_centro_servicio cds, tbl_sal_cama sc where aca.compania = aa.compania and aca.pac_id = aa.pac_id and aca.admision = aa.secuencia and aa.categoria in (1, 5) and aa.estado = 'A' and aa.compania = "+(String) session.getAttribute("_companyId")+" and aca.pac_id = p.pac_id and aca.cama = sc.codigo and aca.habitacion = sc.habitacion and aca.compania = sc.compania and aca.fecha_final is null and sc.habitacion = sh.codigo and sc.compania = sh.compania and sc.tipo_hab = sth.codigo and sc.compania = sth.compania and aca.habitacion = sh.codigo and sh.unidad_admin = cds.codigo and cds.flag_cds = 'SAL'";

	cdo = SQLMgr.getData(sql);

	//-----------------------------------------------------------------------------------------------//
	//--------------Query para el Detalle de Pactes. x Compañía de Seguros -------------------------//
	sql = "select distinct 1 princip, ae.nombre nombre_empresa, nvl(sum(decode(aa.estado,'I', 0,'E', 0,'A', decode(to_char(aca.fecha_final, 'dd/mm/yyyy'), to_char(sysdate, 'dd/mm/yyyy'), 0,1))),0) activos, sum(decode(aa.corte_cta,null, decode(to_char(aa.fecha_ingreso,'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 1,0),0)) ingresos, nvl(sum(decode(to_char(aa.fecha_egreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 1,0)),0) egresos, nvl(sum(decode(aa.estado,'I', 0,'E', 0,'A', decode(to_char(aca.fecha_final,'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 0, decode(cds.flag_cds,'ICU', 1,0)))),0) act_intadl, nvl(sum(decode(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), decode(cds.flag_cds,'ICU', 1,0),0)),0) ing_intadl, nvl(sum(decode(to_char(aa.fecha_egreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), decode(cds.flag_cds,'ICU', 1,0),0)),0) egr_intadl, nvl(sum(decode(aa.estado,'I', 0,'E', 0,'A', decode(to_char(aca.fecha_final,'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 0, decode(cds.flag_cds,'CUI', 1,0)))),0) act_intped, nvl(sum(decode(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), decode(cds.flag_cds,'CUI', 1,0),0)),0) ing_intped, nvl(sum(decode(to_char(aa.fecha_egreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), decode(cds.flag_cds,'CUI', 1,0),0)),0) egr_intped, count (aa.fecha_nacimiento || aa.codigo_paciente|| aa.secuencia) total, ae.codigo codigo_empr, nvl((select count (*) cupos from tbl_cdc_cita cc where cc.estado_cita in ('E', 'R') and cc.centro_servicio in (select codigo from tbl_cds_centro_servicio where flag_cds in('HEM','SOP','ENDO') and cc.fecha_cita = to_date (to_char(sysdate, 'dd/mm/yyyy'),'dd/mm/yyyy') and cc.empresa = ab.empresa)), 0) as cupos_sop from tbl_adm_beneficios_x_admision ab, tbl_adm_admision aa, tbl_adm_empresa ae, tbl_adm_cama_admision aca, tbl_sal_habitacion sh, tbl_cds_centro_servicio cds where aa.compania = "+(String) session.getAttribute("_companyId")+" and aa.categoria in (1) and aa.estado in ('A', 'I', 'E') and ab.prioridad = 1 and nvl(ab.estado, 'A') = 'A' and ab.pac_id = aa.pac_id and ab.admision = aa.secuencia and aca.compania = aa.compania and aca.pac_id = aa.pac_id and aca.admision = aa.secuencia and aca.habitacion = sh.codigo and (aca.fecha_final is null or to_date(to_char(aca.fecha_final, 'dd/mm/yyyy'),'dd/mm/yyyy') <> aca.fecha_inicio) and (aca.fecha_final is null or to_date(to_char(aca.fecha_final, 'dd/mm/yyyy'),'dd/mm/yyyy') >=to_date (to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy')) and (aa.fecha_egreso is null or aa.fecha_egreso >= to_date (to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy')) and ab.empresa = ae.codigo and sh.unidad_admin = cds.codigo group by ae.nombre, ae.codigo, ab.empresa having   sum(decode(aa.estado,'I', 0,'E', 0,'A', decode(to_char(aca.fecha_final,'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 0,1))) + sum(decode(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 1,0)) + sum(decode(to_char(aa.fecha_egreso, 'dd/mm/yyyy'),to_char(sysdate, 'dd/mm/yyyy'), 1,0)) <> 0 union select distinct 3 princip, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, count (aca.cama) tot_pac_sin_benef, 0, 0 from tbl_adm_cama_admision aca, tbl_adm_paciente p, tbl_adm_admision aa, tbl_sal_tipo_habitacion sth, tbl_sal_habitacion sh, tbl_cds_centro_servicio cds, tbl_sal_cama sc where aca.pac_codigo = aa.codigo_paciente and aca.compania = aa.compania and aca.pac_id = aa.pac_id and aa.compania = "+(String) session.getAttribute("_companyId")+" and aa.categoria in (1) and aa.estado = 'A' and aca.pac_id = p.pac_id and aca.cama = sc.codigo and aca.habitacion = sc.habitacion and aca.compania = sc.compania and aca.fecha_final is null and sc.habitacion = sh.codigo and sc.compania = sh.compania and sc.tipo_hab = sth.codigo and sc.compania = sth.compania and aca.habitacion = sh.codigo and sh.unidad_admin = cds.codigo and (aa.pac_id, aa.secuencia) not in (select distinct xaa.pac_id, xaa.secuencia from tbl_adm_beneficios_x_admision xab, tbl_adm_admision xaa, tbl_adm_empresa xae where xaa.compania = "+(String) session.getAttribute("_companyId")+" and xaa.categoria in (1) and xaa.estado in ('A', 'I', 'E') and xab.prioridad = 1 and nvl(xab.estado, 'A') = 'A' and xab.pac_id = xaa.pac_id and xab.admision = xaa.secuencia and xab.empresa = xae.codigo) order by 1, 2";
al = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String subtitle = "CENSO A LA FECHA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".23");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".07");

	double celdWidth = (1-0.14)/(alE.size()+1);
	Vector setSummary = new Vector();
		setSummary.addElement(".14");
		for(int i=0;i<=alE.size();i++){
		setSummary.addElement(""+celdWidth);
		}

		pc.setNoColumnFixWidth(setSummary);
		pc.createTable("subtabla", false, 0, 0.0f, width - (leftRightMargin * 2));
			pc.setFont(7, 1);
			pc.addBorderCols(" ",1,1,cHeight * 2);
			for(int i = 0; i<alE.size();i++){
				CommonDataObject cdoD = (CommonDataObject) alE.get(i);
				pc.addBorderCols(cdoD.getColValue("descripcion"),1,1,cHeight * 2);
			}
			pc.addBorderCols("TOTAL",1,1,cHeight * 2);

			pc.setFont(7, 0);
			pc.addBorderCols("TOTALES POR SALA",0,1,cHeight);
			for(int i = 0; i<alE.size();i++){
				CommonDataObject cdoD = (CommonDataObject) alE.get(i);
				pc.addBorderCols(cdo.getColValue("centro_"+cdoD.getColValue("codigo")),1,1,cHeight);
			}
			pc.addBorderCols(cdo.getColValue("total"),1,1,cHeight);
			pc.addBorderCols(" ",1,setSummary.size(),cHeight);


	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

		pc.addTableToCols("subtabla", 1, setDetail.size());

		//second row
	pc.useTable("main");
	pc.setNoColumnFixWidth(setDetail);
	//pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Detalle por Cía. de Seguros",1,1,Color.lightGray);
		pc.addBorderCols("G L O B A L",1,3,Color.lightGray);
		pc.addBorderCols("I N T E N S I V O  A D U L T O",1,3,Color.lightGray);
		pc.addBorderCols("C U I D A D O S  I N T E R M E D I O S",1,3,Color.lightGray);
		pc.addBorderCols("Cupos S. Op.",1,1,Color.lightGray);

		pc.addBorderCols("Nombre de la Compañía",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Ingresos",1);
		pc.addBorderCols("Egresos",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Ingresos",1);
		pc.addBorderCols("Egresos",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Ingresos",1);
		pc.addBorderCols("Egresos",1);
		pc.addBorderCols("Cantidad",1);

	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	//pc.setNoInnerColumnFixWidth(setDetail);
	//pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
	//pc.createInnerTable(true);


	//table body

	pc.setVAlignment(0);

	for (int i=0; i<al.size(); i++){

		cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("princip").trim().equals("1")){
			totPacOtros  += Integer.parseInt(cdo.getColValue("activos"));
			totIngOtros  += Integer.parseInt(cdo.getColValue("ingresos"));
			totEgrOtros  += Integer.parseInt(cdo.getColValue("egresos"));
			totActIntAdl += Integer.parseInt(cdo.getColValue("act_intadl"));
			totIngIntAdl += Integer.parseInt(cdo.getColValue("ing_intadl"));
			totEgrIntAdl += Integer.parseInt(cdo.getColValue("egr_intadl"));
			totActIntPed += Integer.parseInt(cdo.getColValue("act_intped"));
			totIngIntPed += Integer.parseInt(cdo.getColValue("ing_intped"));
			totEgrIntPed += Integer.parseInt(cdo.getColValue("egr_intped"));
			totCuposSOP  += Integer.parseInt(cdo.getColValue("cupos_sop"));//cupos s op.
		} else if(cdo.getColValue("princip").trim().equals("3")) total_pac_sin_benef = Integer.parseInt(cdo.getColValue("total"));

		//-------------------------------------------------------------------------------------//
		if (cdo.getColValue("princip").trim().equals("1")){
			//pc.createTable();
			pc.setFont(7, 0);
			pc.addBorderCols(" "+cdo.getColValue("nombre_empresa"),0,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("activos").trim().equals("0"))?cdo.getColValue("activos"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("ingresos").trim().equals("0"))?cdo.getColValue("ingresos"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("egresos").trim().equals("0"))?cdo.getColValue("egresos"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("act_intadl").trim().equals("0"))?cdo.getColValue("act_intadl"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("ing_intadl").trim().equals("0"))?cdo.getColValue("ing_intadl"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("egr_intadl").trim().equals("0"))?cdo.getColValue("egr_intadl"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("act_intped").trim().equals("0"))?cdo.getColValue("act_intped"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("ing_intped").trim().equals("0"))?cdo.getColValue("ing_intped"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("egr_intped").trim().equals("0"))?cdo.getColValue("egr_intped"):""),1,1,cHeight);
			pc.addBorderCols(" "+((!cdo.getColValue("cupos_sop").trim().equals("0"))?cdo.getColValue("cupos_sop"):""),1,1,cHeight);
			//pc.addTable();
		}
	}
	if (al.size() == 0)
	{
		//pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		//pc.addTable();
	}
	else
	{
		// ---------------- Variables para obtener los Totales Finales -------------------
		totPacAct  = totPacOtros + total_pac_sin_benef;
		totPacIng  = totIngOtros;
		totPacEgr  = totEgrOtros;

		totPacAct_IntAdult = totActIntAdl;
		totPacIng_IntAdult = totIngIntAdl;
		totPacEgr_IntAdult = totEgrIntAdl;

		totPacAct_IntPed   = totActIntPed;
		totPacIng_IntPed   = totIngIntPed;
		totPacEgr_IntPed   = totEgrIntPed;
		totCuposSOPfinal   = totCuposSOP;

		//--------------Tabla para Total de Pacientes Sin Aseguradora Asignada--------------------//
		//pc.createTable();
			pc.setFont(7, 1);
			pc.addBorderCols(" *Pactes. Sin Aseguradora Asignada(beneficio)",0,1,cHeight);
			pc.addBorderCols(" "+total_pac_sin_benef,1,1,cHeight);
			pc.addCols(" ",0,setDetail.size() - 2,cHeight);

			pc.addCols(" ",0,setDetail.size(),cHeight);
		//pc.addTable();

		//pc.createTable();
			pc.setFont(7, 2);
			pc.addCols(" Resumen:",0,setDetail.size(),cHeight);

			//--------------------------Tabla para los Totales de Pacientes de Otras Cías. de Seguros------------------------//
			pc.addCols(" Total de Pacientes Asegurados",0,1,cHeight);
			pc.addBorderCols(" "+totPacOtros,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols(" "+totIngOtros,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// - Integer.parseInt(ingresosAxa)
			pc.addBorderCols(" "+totEgrOtros,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// -Integer.parseInt(egresosAxa)
			pc.addBorderCols(" "+totActIntAdl,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols(" "+totIngIntAdl,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// - Integer.parseInt(ing_intAdult_Axa)
			pc.addBorderCols(" "+totEgrIntAdl,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// - Integer.parseInt(egr_intAdult_Axa)
			pc.addBorderCols(" "+totActIntPed,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols(" "+totIngIntPed,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// - Integer.parseInt(ing_intPediat_Axa)
			pc.addBorderCols(" "+totEgrIntPed,1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// - Integer.parseInt(egr_intPediat_Axa)
			pc.addBorderCols(" "+(totCuposSOP),1,1,0.5f,0.0f,0.0f,0.0f,cHeight);// - totCuposSOP_Axa//cupos s op.
		//pc.addTable();

		//--------------------------Tabla para los Totales Finales------------------------------------------------//
		//pc.createTable();
			pc.setFont(7, 1);
			pc.addCols(" Total de Pacientes",0,1,cHeight);
			pc.addCols(" "+totPacAct,1,1,cHeight);
			pc.addCols(" "+totPacIng,1,1,cHeight);
			pc.addCols(" "+totPacEgr,1,1,cHeight);
			pc.addCols(" "+totPacAct_IntAdult,1,1,cHeight);
			pc.addCols(" "+totPacIng_IntAdult,1,1,cHeight);
			pc.addCols(" "+totPacEgr_IntAdult,1,1,cHeight);
			pc.addCols(" "+totPacAct_IntPed,1,1,cHeight);
			pc.addCols(" "+totPacIng_IntPed,1,1,cHeight);
			pc.addCols(" "+totPacEgr_IntPed,1,1,cHeight);
			pc.addCols(" "+totCuposSOPfinal,1,1,cHeight);//cupos s op.
		//pc.addTable();

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>