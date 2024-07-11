<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
Reporte
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
ArrayList al2 = new ArrayList();

CommonDataObject cdo2, cdoPacData = new CommonDataObject();

String sql = "", sqlTitle="";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEval = request.getParameter("fechaEval");
String cod_Historia = request.getParameter("cod_Historia");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fechaEval == null) fechaEval = "";
if (!fechaEval.trim().equals("")) appendFilter +=" and fecha_up=to_date('"+fechaEval+"','dd/mm/yyyy')";
if (desc == null ) desc = "";

sql = "select distinct a.calendar, a.yyyy, a.mm, a.dd, a.max_dd, a.codigo as cod_concepto, a.descripcion, nvl(b.seleccionar,'N') as seleccionar, to_char(a.calendar,'MON/yyyy','NLS_DATE_LANGUAGE=SPANISH') as descFecha, (select usuario_creacion from tbl_sal_ulcera_presion where pac_id = b.pac_id and secuencia = b.secuencia and fecha = b.fecha_up) usuario from (select z.calendar, z.yyyy, z.mm, z.dd, z.max_dd, y.codigo, y.descripcion, z.pac_id, z.secuencia from (select to_date(m.yyyy||m.mm||lpad(d.n,2,'0'),'yyyymmdd') as calendar, m.yyyy, m.mm, lpad(d.n,2,'0') as dd, m.max_dd ,m.pac_id, m.secuencia from (select distinct pac_id,  secuencia , to_char(fecha_up,'yyyy') as yyyy, to_char(fecha_up,'mm') as mm, to_char(last_day(fecha_up),'dd') as max_dd from tbl_sal_det_ulcera_presion where pac_id = "+pacId+" and secuencia = "+noAdmision+appendFilter+") m, (select level n from dual connect by level<=31) d where d.n<=m.max_dd) z, tbl_sal_concepto_ulcera y) a, tbl_sal_det_ulcera_presion b where a.calendar=b.fecha_up(+) and a.codigo=b.cod_concepto(+) /**/ and a.pac_id = b.pac_id(+) and a.secuencia = b.secuencia(+) /**/ order by a.yyyy, a.mm, a.codigo, a.dd";
al = SQLMgr.getDataList(sql);

ArrayList alBit = SQLMgr.getDataList("select usuario_creacion uc,usuario_modificacion um,  to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fm from tbl_sal_ulcera_presion where pac_id = "+pacId+" and secuencia = "+noAdmision+(!fechaEval.trim().equals("")?" and fecha = to_date('"+fechaEval+"','dd/mm/yyyy') ":"")+"");

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "DEPARTAMENTO DE ENFERMERIA";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;
		PdfCreator footer = new PdfCreator();

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");
		
	Vector bitacora = new Vector();
		bitacora.addElement("25");
		bitacora.addElement("25");
		bitacora.addElement("25");
		bitacora.addElement("25");

	Vector dHeader = new Vector();
		dHeader.addElement(".36");//concepto
		dHeader.addElement(".02");//01
		dHeader.addElement(".02");//02
		dHeader.addElement(".02");//03
		dHeader.addElement(".02");//04
		dHeader.addElement(".02");//05
		dHeader.addElement(".02");//06
		dHeader.addElement(".02");//07
		dHeader.addElement(".02");//08
		dHeader.addElement(".02");//09
		dHeader.addElement(".02");//10
		dHeader.addElement(".02");//11
		dHeader.addElement(".02");//12
		dHeader.addElement(".02");//13
		dHeader.addElement(".02");//14
		dHeader.addElement(".02");//15
		dHeader.addElement(".02");//16
		dHeader.addElement(".02");//17
		dHeader.addElement(".02");//18
		dHeader.addElement(".02");//19
		dHeader.addElement(".02");//20
		dHeader.addElement(".02");//21
		dHeader.addElement(".02");//22
		dHeader.addElement(".02");//23
		dHeader.addElement(".02");//24
		dHeader.addElement(".02");//25
		dHeader.addElement(".02");//26
		dHeader.addElement(".02");//27
		dHeader.addElement(".02");//28
		dHeader.addElement(".02");//29
		dHeader.addElement(".02");//30
		dHeader.addElement(".02");//31
        
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
    

		PdfCreator pc=null;
		boolean isUnifiedExp=false;
		pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
		isUnifiedExp=true;}


	pc.setNoColumnFixWidth(dHeader);
	pc.createTable("leyenda");
		pc.addBorderCols(" ",0,dHeader.size());
		pc.addBorderCols("INICIALES DEL EVALUADOR",0,1);
		for (int k=0; k<31; k++) pc.addBorderCols(" ",0,1);

		pc.setVAlignment(0);
		// pc.setNoInnerColumnFixWidth(infoCol);
		// pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		// pc.createInnerTable(); (pc.getWidth() - (pc.getLeftRightMargin() * 2))
		pc.setNoColumnFixWidth(infoCol);
		pc.createTable("infoCol");
			pc.setFont(5, 0);
			pc.addCols(" ",0,infoCol.size());

			pc.setFont(9, 0);
			pc.addCols("G0 = Piel íntegra.",0,infoCol.size());
			pc.addCols("G1 = Enrojecimiento de la piel.  La misma permanece intacta.",0,infoCol.size());
			pc.addCols("G2 = La úlcera es superficial.  Aparece algún tipo de abrasión.  La piel pierde la dermis y/o la epidermis.",0,infoCol.size());
			pc.addCols("G3 = La piel pierde con el daño o la necrosis su consistencia.  Este daño no se extiende a mas allá de la fascia.  Clínicamente la úlcera se ve como un cráter profundo que puede comprometer los tejidos adyacentes.",0,infoCol.size());
			pc.addCols("G4 = El grosor de la piel se pierde debido a la necrosis tisular y daño al músculo, hueso o estructuras de soporte.  Hay compromiso de los tejidos adyacentes, asociados a fístulas. ",0,infoCol.size());
			pc.addCols(" ",0,infoCol.size());
			pc.addCols("Nota: Las observaciones y tratamientos se documentarán en la Hoja de Notas de Enfermera.",0,infoCol.size());
			pc.setFont(3, 0);
			pc.addCols(" ",0,infoCol.size());
			pc.resetVAlignment();
		//pc.addInnerTableToCols(dHeader.size());

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	//pc.setTableHeader(2);//create de table header (3 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	String mm = "";
	String concepto = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!mm.equals(cdo.getColValue("mm")))
		{
			if (i != 0)
			{
				pc.addTableToCols("leyenda",0,dHeader.size());
				pc.flushTableBody(true);
				pc.addNewPage();
			}

			pc.setFont(9, 1);
			pc.addCols(cdo.getColValue("descFecha"),0,dHeader.size());
			pc.setFont(7, 1);
			pc.addBorderCols("CARACTERISTICAS",0,1,0.0f,0.5f,0.5f,0.5f);
			pc.addBorderCols("FECHAS",1,dHeader.size()-1);

			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.5f,0.0f);
			for (int j=1; j<=31; j++) pc.addBorderCols(""+j,0,1);
		}
		pc.setFont(7, 0);
		if (!concepto.equals(cdo.getColValue("cod_concepto"))) pc.addBorderCols(cdo.getColValue("descripcion"),0,1);
		if (cdo.getColValue("seleccionar").equalsIgnoreCase("S"))
		{
			pc.setFont(7, 0,Color.WHITE);
            pc.addBorderCols(" ",0,1,Color.BLACK);
		}
		else if (cdo.getColValue("seleccionar").equalsIgnoreCase("N"))
		{
			pc.setFont(7, 0);
			pc.addBorderCols("",0,1);
		}
		if (cdo.getColValue("dd").equals(cdo.getColValue("max_dd")))
		{
			int fill = 31 - Integer.parseInt(cdo.getColValue("max_dd"));
			for (int j=0; j<fill; j++)
			{
				pc.setFont(7, 0);
				pc.addBorderCols(" ",0,1);
			}
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		mm = cdo.getColValue("mm");
		concepto = cdo.getColValue("cod_concepto");
	}
	
	
	if (alBit.size() > 0){
	
		pc.setNoColumnFixWidth(bitacora);
		pc.createTable("bitacora",false,1,0.0f,380.0f);
		pc.addCols(" ",0,bitacora.size());
		pc.setFont(7, 1);
		pc.addCols("Usuario Creación",0,1);
		pc.addCols("Fecha Creación",0,1);
		pc.addCols("Usuario Modificación",0,1);
		pc.addCols("Fecha Modificación",0,1);
		pc.setFont(7, 0);
		for (int b = 0; b<alBit.size(); b++){
		  CommonDataObject cdoBit = (CommonDataObject)alBit.get(b);
		  pc.addCols(cdoBit.getColValue("uc"),0,1);
		  pc.addCols(cdoBit.getColValue("fc"),0,1);
		  pc.addCols(cdoBit.getColValue("um"),0,1);
		  pc.addCols(cdoBit.getColValue("fm"),0,1);
		}
		
		pc.useTable("leyenda");
		pc.addTableToCols("bitacora",0,dHeader.size(),0.0f);
	}

	
	
	
	pc.useTable("main");
	pc.addTableToCols("leyenda",0,dHeader.size());
	
	pc.useTable("leyenda");
	pc.addTableToCols("infoCol",0,dHeader.size());
	
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>