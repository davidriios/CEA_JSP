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
Reporte sal10030   fg=NE
Reporte sal10030b  fg=null or blank
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
ArrayList al2= new ArrayList();
CommonDataObject cdoPacData = new CommonDataObject();

String sql = "", sqlTitle;
String appendFilter = request.getParameter("appendFilter");
String appendFilter0 = request.getParameter("appendFilter0");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaReporte = request.getParameter("fecha");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fp == null) fp = "TD";
if (desc == null) desc = "";

appendFilter +="  and ne.no_hemodialisis is not null  ";

if (request.getParameter("fecha") != null && !request.getParameter("fecha").equals("null") && !request.getParameter("fecha").equals("")){
    appendFilter +="  and ne.fecha = to_date('"+request.getParameter("fecha")+"', 'dd/mm/yyyy') ";
}

if (fg.trim().equals("NE"))appendFilter +=" and rn.estado = 'A' ";

sql = " select distinct a.* from ( select ne.no_hemodialisis, ne.maquina, ne.filtro, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = ne.medico_nefro and rownum = 1) medico_nefro, ne.compania, nvl(to_char(ne.hora_termino,'dd/mm/yyyy hh12:mi:ss am'),' ') hora_termino, ne.peso_inicial, ne.peso_final, rn.codigo, nvl(to_char(rn.fecha_nota,'dd/mm/yyyy'),' ') as fechaNota, nvl(to_char(rn.hora,'hh12:mi:ss am'),' ') as hora, nvl(to_char(rn.fecha,'dd/mm/yyyy'),' ') as fecha, nvl(to_char(rn.hora_r,'hh12:mi am'),' ') as horaR, rn.temperatura, rn.pulso, rn.p_arterial as pArterial, nvl(rn.respiracion,' ') respiracion, nvl(rn.ultrafijacion,' ') ultrafijacion,  nvl(rn.med_trat,' ')||decode(rn.recormon_unid,null,'','     ERITROPROY.: '||rn.recormon_unid||'UDS') med_trat, nvl(rn.observacion,' ') observacion , to_char(rn.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, rn.usuario_creacion as usuario, rn.estado, decode(rn.estado,'A','VALIDA','I','INVALIDA') as descEstado,nvl(flujo_sanguineo,' ') flujoSanguineo,nvl(p_venosa,' ') pVenosa , nvl(p_transmembranica,' ') pTransmembranica, rn.fecha_nota, to_date(to_char(rn.hora,'hh12:mi:ss am'),'hh12:mi:ss am') as hora_nota, rn.fecha as fecha_orden, to_date(to_char(rn.hora_r,'hh12:mi:ss am'),'hh12:mi:ss am') as hora_orden, ne.id, nvl(rn.FCARD,' ')fCard, nvl(rn.PCARD,' ')pCard, rn.peso, rn.talla  from tbl_sal_resultado_nota rn, tbl_sal_notas_enfermeria ne where rn.pac_id="+pacId+" and rn.secuencia="+noAdmision+" and rn.pac_id=ne.pac_id and rn.secuencia=ne.secuencia and rn.id=ne.id and rn.comentario = 'HM2' and rn.comentario = ne.observacion "+appendFilter+") a order by a.fecha_nota desc, a.hora_nota desc, a.fecha_orden, a.hora_orden";
al = SQLMgr.getDataList(sql);

//System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"+sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	boolean isLandscape = ((!fp.trim().equals("HM"))?true:false);
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = "NOTAS DE LA ENFERMERA VALIDAS "+((fg.trim().equals("CS"))?" - INVALIDAS":"");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
}
	Vector dHeader = new Vector();
	if(!fp.trim().equals("HM"))
	{
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".07");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		
		dHeader.addElement(".13");
		dHeader.addElement(".24");
	}
	else
	{
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".04");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");

		dHeader.addElement(".15");
		dHeader.addElement(".17");
	}

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(fontSize, 0);
    footer.addBorderCols(" ",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
    footer.addCols("Firma de Enfermera(o): "+"__________________________                                                                 "+"                 Firma de Paciente: "+"__________________________",0,dHeader.size());
    footer.addBorderCols(" ",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());
	isUnifiedExp=true;}

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	
	//if(fp.trim().equals("HM")) //pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	if(!fp.trim().equals("HM2"))
	{
		pc.setFont(fontSize, 1);
		pc.addBorderCols("ESTADO",1);
		pc.addBorderCols("USER",1);
		pc.addBorderCols("FECHA",1);
		pc.addBorderCols("HORA",1);

		pc.addBorderCols("TEMP",1);
		pc.addBorderCols("PULSO",1);
		pc.addBorderCols("RESP.",1);
		pc.addBorderCols("P.ARTER.",1);
		pc.addBorderCols("F.CARD.",1);
		pc.addBorderCols("PUL.CARD.",1);
		pc.addBorderCols("PESO",1);
		pc.addBorderCols("TALLA",1);  
		pc.addBorderCols("MEDIC. Y TRAT.",1);
		pc.addBorderCols("NOTAS DE LA ENFERMERA",1);
		//pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	}

	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (fp.trim().equals("HM2"))
		{
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("fecha")))
			{
				if (i != 0)
				{
					pc.flushTableBody(true);
					pc.addNewPage();
				}
			}// groupBy

			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("id")))
			{
				pc.setFont(fontSize, 1);
				pc.addCols(" ",0,dHeader.size(),cHeight);
				pc.addBorderCols("HEMODIALISIS No.",1,2,0.5f,0.5f,0.5f,0.5f,cHeight);
				//pc.addCols(" no_hemodialisis: "+ cdo.getColValue("no_hemodialisis"),0,dHeader.size(),cHeight);
				pc.addBorderCols("MAQUINA",1,2,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols("FILTRO",1,2,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols("NEFROLOGO",1,6,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols("F.TERMINO",1,1,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols("COMPAÑIA",1,1,0.5f,0.5f,0.5f,0.5f,cHeight);

				pc.setFont(fontSize,0,Color.black);
				pc.addBorderCols(cdo.getColValue("no_hemodialisis"),1,2,0.5f,0.5f,0.5f,0.5f,cHeight);
				//pc.addCols(" no_hemodialisis: "+ cdo.getColValue("no_hemodialisis"),0,dHeader.size(),cHeight);
				pc.addBorderCols(cdo.getColValue("maquina"),1,2,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols(cdo.getColValue("filtro"),1,2,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols(cdo.getColValue("medico_nefro"),1,6,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols(cdo.getColValue("hora_termino"),1,1,0.5f,0.5f,0.5f,0.5f,cHeight);
				pc.addBorderCols(cdo.getColValue("compania"),1,1,0.5f,0.5f,0.5f,0.5f,cHeight);

				pc.setFont(fontSize, 1);
				pc.addBorderCols("ESTADO",1);
				pc.addBorderCols("USER",1);
				pc.addBorderCols("FECHA",1);
				pc.addBorderCols("HORA",1);

				pc.addBorderCols("T°",1);
				pc.addBorderCols("P",1);
				pc.addBorderCols("R",1);
				pc.addBorderCols("P/A",1);
				pc.addBorderCols("F.S",1);
				pc.addBorderCols("F.V",1);
				pc.addBorderCols("UF",1);
				pc.addBorderCols("PTM",1);
				pc.addBorderCols("MEDIC. Y TRAT.",1);
				pc.addBorderCols("NOTAS DE LA ENFERMERA",1);
			}// groupBy2
		}//fp=HM2

		if (cdo.getColValue("estado").trim().equalsIgnoreCase("I")) pc.setFont(fontSize, 0, Color.RED);
		else pc.setFont(fontSize, 0);
		pc.addBorderCols(cdo.getColValue("descEstado"),1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols(cdo.getColValue("usuario"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("fecha"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("horaR"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(fontSize, 0);
		pc.addBorderCols(cdo.getColValue("temperatura"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("pulso"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("respiracion"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("pArterial"),1,1,0.5f,0.0f,0.0f,0.0f);
		
		
		
		if(!fp.trim().equals("HM"))
		{
			pc.addBorderCols(cdo.getColValue("fCard"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("pCard"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("peso"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("talla"),1,1,0.5f,0.0f,0.0f,0.0f);
		}
		if(fp.trim().equals("HM"))
		{
			pc.addBorderCols(cdo.getColValue("flujoSanguineo"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("pVenosa"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("ultrafijacion"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("pTransmembranica"),1,1,0.5f,0.0f,0.0f,0.0f);
		}
		pc.addBorderCols(cdo.getColValue("med_trat"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observacion"),0,1,0.5f,0.0f,0.0f,0.0f);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		if (fp.trim().equals("HM2"))
		{
			groupBy = cdo.getColValue("fecha");
			groupBy2 = cdo.getColValue("id");
		}
	}

	if ((request.getParameter("fecha") != null && !request.getParameter("fecha").equals("")) && (fp.trim().equals("HM")))
	{
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addBorderCols("OBSERVACIONES MEDICAS.",1,14,0.5f,0.5f,0.5f,0.5f,cHeight);
			sql = "select to_char(p.fecha,'dd/mm/yyyy') as fechaObs,  m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, p.observacion as progreso_clinico from tbl_adm_admision aa, tbl_sal_progreso_clinico p, tbl_adm_medico m where aa.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and p.fecha = to_date('"+fechaReporte+"','dd/mm/yyyy') and p.pac_id=aa.pac_id and p.admision = aa.secuencia and p.medico=m.codigo(+) and aa.categoria = 2";
			al2 = SQLMgr.getDataList(sql);

			for (int c=0; c<al2.size(); c++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al2.get(c);

				pc.setFont(fontSize, 0);
				pc.addBorderCols("Médico: "+cdo2.getColValue("nombre_medico"),0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo2.getColValue("progreso_clinico"),0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
			}
	}

	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET

%>