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
/** SFPRES003 Presupuesto/Transacciones/Presupuesto de Inversiones - Check Horizontal
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
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoUE = new CommonDataObject();

String sql = "", appendFilter = "";
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String unidad = request.getParameter("unidad");
String compania = (String)session.getAttribute("_companyId");
String consec = request.getParameter("consec");
String tipoInv = request.getParameter("tipoInv");

if (anio == null ) anio = "";
if (unidad == null ) unidad = "";
if (consec == null ) consec = "";
if ( tipoInv == null ) tipoInv = "";

if (anio.equals("")) throw new Exception("No pudimos encontar un año válido, Por favor contacte un administrador!");

if (!unidad.equals("")) {
   appendFilter += " and AIA.CODIGO_UE = to_number("+unidad+")";
}

sql = "select s.codigo_ue, s.unidadEjec, s.justificacion, s.categoria, s.prioridad, sum(s.enero) enero, sum(s.febrero)febrero ,sum(s.marzo) marzo, sum(s.abril) abril, sum(s.mayo) mayo, sum(s.junio) junio, sum(s.julio) julio, sum(s.agosto) agosto, sum(s.septiembre) septiembre, sum(s.octubre) octubre, sum(s.noviembre) noviembre, sum(s.diciembre)diciembre, sum(s.enero+s.febrero+s.marzo+s.abril+s.mayo+s.junio+s.julio+s.agosto+s.septiembre+s.octubre+s.noviembre+s.diciembre) total_reng  from (SELECT AIA.CODIGO_UE, UE.DESCRIPCION unidadEjec, AIA.ANIO, TI.DESCRIPCION tipo_inversion, CIA.NOMBRE nombre_cia, UE.DESCRIPCION unidad, AIA.SOLICITADO, AIA.DESCRIPCION nombre_inversion,  AIA.COMENTARIO justificacion, TO_NUMBER(AIM.MES) MES, AIM.DESCRIPCION descripcion_mes,DECODE(AIA.CATEGORIA, 1, 'GENERADOR DE INGRESOS', 2, 'APOYO OPERATIVO', 3,'APOYO ADMINISTRATIVO') CATEGORIA,DECODE(AIA.PRIORIDAD, 1, 'URGENTE', 2,'MUY NECESARIO', 3, 'NECESARIO')  PRIORIDAD, AIA.PRIORIDAD NO_PRIORIDAD,DECODE(TO_NUMBER(AIM.MES),1,NVL(AIM.MONTO_SOLICITADO,0),0) ENERO,DECODE(TO_NUMBER(AIM.MES),2,NVL(AIM.MONTO_SOLICITADO,0),0) FEBRERO,DECODE(TO_NUMBER(AIM.MES),3,NVL(AIM.MONTO_SOLICITADO,0),0) MARZO,DECODE(TO_NUMBER(AIM.MES),4,NVL(AIM.MONTO_SOLICITADO,0),0) ABRIL,DECODE(TO_NUMBER(AIM.MES),5,NVL(AIM.MONTO_SOLICITADO,0),0) MAYO,DECODE(TO_NUMBER(AIM.MES),6,NVL(AIM.MONTO_SOLICITADO,0),0) JUNIO,DECODE(TO_NUMBER(AIM.MES),7,NVL(AIM.MONTO_SOLICITADO,0),0) JULIO,DECODE(TO_NUMBER(AIM.MES),8,NVL(AIM.MONTO_SOLICITADO,0),0) AGOSTO,DECODE(TO_NUMBER(AIM.MES),9,NVL(AIM.MONTO_SOLICITADO,0),0) SEPTIEMBRE,DECODE(TO_NUMBER(AIM.MES),10,NVL(AIM.MONTO_SOLICITADO,0),0) OCTUBRE,DECODE(TO_NUMBER(AIM.MES),11,NVL(AIM.MONTO_SOLICITADO,0),0) NOVIEMBRE,DECODE(TO_NUMBER(AIM.MES),12,NVL(AIM.MONTO_SOLICITADO,0),0) DICIEMBRE,aia.consec,aia.tipo_inv FROM TBL_CON_ANTE_INVERSION_ANUAL AIA, TBL_CON_ANTE_INVERSION_MENSUAL AIM,TBL_CON_TIPO_INVERSION TI, TBL_SEC_UNIDAD_EJEC UE, TBL_SEC_COMPANIA CIA WHERE ( (AIA.ANIO = AIM.ANIO) AND(AIA.TIPO_INV = AIM.TIPO_INV) AND(AIA.COMPANIA = AIM.COMPANIA) AND(AIA.CODIGO_UE = AIM.CODIGO_UE) AND(AIA.CONSEC = AIM.CONSEC) AND(AIA.TIPO_INV = TI.TIPO_INV) AND(AIA.COMPANIA = TI.COMPANIA) AND(CIA.CODIGO = UE.COMPANIA) AND(AIA.COMPANIA = CIA.CODIGO) AND(AIA.CODIGO_UE = UE.CODIGO) AND(AIA.ANIO = "+anio+")   AND(AIA.COMPANIA = "+compania+appendFilter+")  AND(NVL(AIM.MONTO_SOLICITADO,0) > 0)) /* and AIM.CONSEC = "+consec+" and AIM.TIPO_INV = "+tipoInv+" */ order by AIA.codigo_ue )s group by s.codigo_ue, s.unidadEjec, s.justificacion,s.consec,s.tipo_inv, s.categoria, s.prioridad";

al = SQLMgr.getDataList(sql);

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

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PRESUPUESTO DE INVERSION AÑO: "+anio;
	String subtitle = "INVERSION GENERAL";
	String xtraSubtitle = (cdoUE.getColValue("v_unidad")==null?"":cdoUE.getColValue("v_unidad"));
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
	infoCol.addElement(".32");
	infoCol.addElement(".25");
	infoCol.addElement(".15");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".09");
	infoCol.addElement(".10");

	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());
	
	String groupByUE = "", montoSol = "";
	double t_enero = 0.0, t_febrero = 0.0, t_marzo = 0.0, t_abril = 0.0, t_mayo = 0.0, t_junio = 0.0, t_julio = 0.0, t_agosto = 0.0, t_septiembre = 0.0, t_octubre = 0.0, t_noviembre = 0.0, t_diciembre = 0.0, total_reng = 0.0;
	
	pc.setVAlignment(0);
	
	pc.setFont(7,1);
	pc.addBorderCols("DESCRIPCION",1,1);
	pc.addBorderCols("TIPO DE APOYO",1,1);
	pc.addBorderCols("PRIORIDAD",1,1);
	pc.addBorderCols("ENE",1,1);
	pc.addBorderCols("FEB",1,1);
	pc.addBorderCols("MAR",1,1);
	pc.addBorderCols("ABR",1,1);
	pc.addBorderCols("MAY",1,1);
	pc.addBorderCols("JUN",1,1);
	pc.addBorderCols("JUL",1,1);
	pc.addBorderCols("AGO",1,1);
	pc.addBorderCols("SEP",1,1);
	pc.addBorderCols("OCT",1,1);
	pc.addBorderCols("NOV",1,1);
	pc.addBorderCols("DIC",1,1);
	pc.addBorderCols("TOTALES",1,1);
	
	pc.setTableHeader(2);
	//System.out.println("::::::::::::: The Brain ::::::::::::::::::::"+al.size());
	
	for ( int i = 0; i<al.size(); i++ ){
	    cdo = (CommonDataObject)al.get(i);
	   
	    if ( !groupByUE.trim().equals(cdo.getColValue("codigo_ue"))) {
		
				pc.addCols(" ",1,infoCol.size());
				pc.setFont(6,1,Color.white);
				pc.addCols("UNIDAD: "+cdo.getColValue("unidadEjec"),0,infoCol.size(),Color.gray);
				t_enero = 0.0; t_febrero = 0.0; t_marzo = 0.0; 
				t_abril = 0.0; t_mayo = 0.0; t_junio = 0.0;
				t_julio = 0.0; t_agosto = 0.0; t_septiembre = 0.0;
				t_octubre = 0.0; t_noviembre = 0.0; t_diciembre = 0.0; total_reng = 0.0;
		}		
				pc.setFont(6,0);
				pc.addCols(""+cdo.getColValue("justificacion"),0,1);
				pc.addCols(""+cdo.getColValue("categoria"),0,1);
				pc.addCols(""+cdo.getColValue("prioridad"),0,1);
				
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("enero")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("febrero")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("marzo")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("abril")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("mayo")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("junio")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("julio")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("agosto")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("septiembre")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("octubre")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("noviembre")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("diciembre")),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("total_reng")),2,1);
				
				t_enero += Double.parseDouble(cdo.getColValue("enero"));
				t_febrero += Double.parseDouble(cdo.getColValue("febrero"));
				t_marzo += Double.parseDouble(cdo.getColValue("marzo"));
				t_abril += Double.parseDouble(cdo.getColValue("abril"));
				t_mayo += Double.parseDouble(cdo.getColValue("mayo"));
				t_junio += Double.parseDouble(cdo.getColValue("junio"));
				t_julio += Double.parseDouble(cdo.getColValue("julio"));
				t_agosto += Double.parseDouble(cdo.getColValue("agosto"));
				t_septiembre += Double.parseDouble(cdo.getColValue("septiembre"));
				t_octubre += Double.parseDouble(cdo.getColValue("octubre"));
				t_noviembre += Double.parseDouble(cdo.getColValue("noviembre"));
				t_diciembre += Double.parseDouble(cdo.getColValue("diciembre"));
				total_reng += Double.parseDouble(cdo.getColValue("total_reng"));
				
			
		groupByUE = cdo.getColValue("codigo_ue");	
	} // for i 
	
	pc.setFont(7,1);
	pc.addCols("T O T A L E S:",0,3);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_enero),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_febrero),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_marzo),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_abril),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_mayo),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_junio),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_julio),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_agosto),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_septiembre),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_octubre),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_noviembre),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+t_diciembre),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+total_reng),2,1);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>