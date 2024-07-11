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
/** SFPRES002 Presupuesto/Transacciones/Presupuesto de Inversiones
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

String sql = "", appendFilter = "", xtraQuery1 = "", xtraQuery2 = "";
String tableUE = "", appendFilter2 = "", xtraGroupBy = "";
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
   cdoUE = SQLMgr.getData("select descripcion v_unidad from unidad_ejec where codigo = TO_NUMBER("+unidad+")and compania = "+compania+"");
}else{
   xtraQuery1 = "aca.unidad, UE.DESCRIPCION unidadEjec, ";
   xtraQuery2 = "x.unidad, x.unidadEjec, ";
   tableUE = " , tbl_sec_unidad_ejec UE";
   appendFilter2 = " and aca.unidad = UE.codigo";
   xtraGroupBy = "x.unidad, x.unidadEjec, ";
}

sql = "SELECT AIA.CODIGO_UE, UE.DESCRIPCION unidadEjec, AIA.ANIO, TI.DESCRIPCION tipo_inversion, CIA.NOMBRE nombre_cia, UE.DESCRIPCION unidad, AIA.CONSEC, AIA.SOLICITADO , AIA.DESCRIPCION nombre_inversion,  AIA.COMENTARIO justificacion, aia.descripcion,TO_NUMBER(AIM.MES) MES, to_char( to_date(AIM.mes||'-'||AIA.anio,'mm-yyyy'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') nombre_mes,  nvl(AIM.MONTO_SOLICITADO,0)monto_solicitado, AIM.DESCRIPCION descripcion_mes,DECODE(AIA.CATEGORIA, 1, 'GENERADOR DE INGRESOS', 2, 'APOYO OPERATIVO', 3,'APOYO ADMINISTRATIVO') CATEGORIA,DECODE(AIA.PRIORIDAD, 1, 'URGENTE', 2,'MUY NECESARIO', 3, 'NECESARIO')  PRIORIDAD,AIA.CANTIDAD,AIM.TIPO_INV ,AIM.consec FROM TBL_CON_ANTE_INVERSION_ANUAL AIA, TBL_CON_ANTE_INVERSION_MENSUAL AIM,TBL_CON_TIPO_INVERSION TI, TBL_SEC_UNIDAD_EJEC UE, TBL_SEC_COMPANIA CIA WHERE  (AIA.ANIO = AIM.ANIO) AND(AIA.TIPO_INV = AIM.TIPO_INV) AND(AIA.COMPANIA = AIM.COMPANIA) AND(AIA.CODIGO_UE = AIM.CODIGO_UE) AND(AIA.CONSEC = AIM.CONSEC) AND(AIA.TIPO_INV = TI.TIPO_INV) AND(AIA.COMPANIA = TI.COMPANIA) AND(CIA.CODIGO = UE.COMPANIA) AND(AIA.COMPANIA = CIA.CODIGO) AND(AIA.CODIGO_UE = UE.CODIGO) AND(AIA.ANIO = "+anio+")   AND(AIA.COMPANIA = "+compania+appendFilter+") AND(NVL(AIM.MONTO_SOLICITADO,0) > 0) /* and AIM.CONSEC = "+consec+" and AIM.TIPO_INV = "+tipoInv+" */ ORDER by AIA.CODIGO_UE,AIM.TIPO_INV,AIM.consec, to_number(aim.mes)";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ANTEPROYECTO DEL PRESUPUESTO DE INVERSION AÑO: "+anio;
	String subtitle = (cdoUE.getColValue("v_unidad")==null?"":cdoUE.getColValue("v_unidad"));//"En Balboas";
	String xtraSubtitle = "";//(cdoUE.getColValue("v_unidad")==null?"":cdoUE.getColValue("v_unidad"));
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();

	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".05");
	infoCol.addElement(".13");
	infoCol.addElement(".07");
	infoCol.addElement(".10");
	infoCol.addElement(".10");

	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());
	
	
	
	pc.setTableHeader(2);
	pc.setVAlignment(0);
	
	Double montoTotal=0.00,montoSol=0.00;
	String groupByUE = "", groupBy2="";
	for ( int i = 0; i<al.size(); i++ ){
	    cdo = (CommonDataObject)al.get(i);
	   
	    
		
		//AIM.TIPO_INV ,AIM.consec 
		if ( !groupByUE.trim().equals(cdo.getColValue("codigo_ue"))) {
		    
			if ( i!=0 ){
			    pc.setFont(8,1);
				pc.addBorderCols(" ",1,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
				pc.addBorderCols("MONTO TOTAL POR UNIDAD:",0,11,0.0f,0.0f,0.5f,0.0f);
				pc.setFont(8,5);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(montoTotal),1,3,0.0f,0.0f,0.0f,0.5f);
				pc.addBorderCols("",1,infoCol.size(),0.5f,0.0f,0.5f,0.5f,1f);
			}
			pc.addCols(" ",1,infoCol.size());
			pc.setFont(8,1,Color.white);
			pc.addCols("UNIDAD: "+cdo.getColValue("unidadEjec"),0,infoCol.size(),Color.gray);
		}
		
		if (!groupBy2.trim().equals(cdo.getColValue("codigo_ue")+"_"+cdo.getColValue("tipo_inv")+"_"+cdo.getColValue("consec")))
		{
			if ( i!=0 ){
			    pc.setFont(8,1);
				pc.addBorderCols(" ",1,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
				pc.addBorderCols("MONTO SOLICITADO:",0,11,0.0f,0.0f,0.5f,0.0f);
				pc.setFont(8,5);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(montoSol),1,3,0.0f,0.0f,0.0f,0.5f);
				pc.addBorderCols("",1,infoCol.size(),0.5f,0.0f,0.5f,0.5f,1f);
				//pc.addCols("",1,infoCol.size());
				
			}
			montoSol =0.00;
		    pc.setFont(8,1);
		    pc.addBorderCols("TIPO INVERSION:",0,3,0.0f,0.5f,0.5f,0.0f);
			pc.setFont(8,0);
			pc.addBorderCols(""+cdo.getColValue("tipo_inversion"),0,infoCol.size()-3,0.0f,0.5f,0.0f,0.5f);
			pc.addBorderCols("",0,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
			
			pc.setFont(8,1);
		    pc.addBorderCols("DESCRIPCION:",0,3,0.0f,0.0f,0.5f,0.0f);
			pc.setFont(8,0);
			pc.addBorderCols(""+cdo.getColValue("justificacion"),0,infoCol.size()-3,0.0f,0.0f,0.0f,0.5f);
			pc.addBorderCols("",0,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
			
			pc.setFont(8,1);
		    pc.addBorderCols("JUSTIFICACION:",0,3,0.0f,0.0f,0.5f,0.0f);
			pc.setFont(8,0);
			pc.addBorderCols(""+cdo.getColValue("nombre_inversion"),0,infoCol.size()-3,0.0f,0.0f,0.0f,0.5f);
			pc.addBorderCols("",0,infoCol.size(),0.0f,0.0f,0.5f,0.5f);

			pc.setFont(8,1);
		    pc.addBorderCols("PRIORIDAD DE LA COMPRA:",0,4,0.0f,0.0f,0.5f,0.0f);
			pc.setFont(8,0);
			pc.addCols(""+cdo.getColValue("prioridad"),0,3);
			
			pc.addCols(" ",0,3);
			pc.setFont(8,1);
			pc.addCols("TIPO DE APOYO:",0,1);
			pc.setFont(8,0);
			pc.addBorderCols(""+cdo.getColValue("categoria"),0,3,0.0f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
			
			pc.setFont(8,1);
		    pc.addBorderCols("      MES ESPERADO PARA ADQUIRIR EL EQUIPO",0,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
			
		}
		
		pc.setFont(8,0);	
        pc.addBorderCols("          "+cdo.getColValue("nombre_mes"),0,4,0.0f,0.0f,0.5f,0.0f);
		pc.addCols(""+cdo.getColValue("cantidad"),1,2);
        pc.addCols(""+cdo.getColValue("descripcion_mes"),0,5); 	
		pc.addCols(CmnMgr.getFormattedDecimal(""+cdo.getColValue("monto_solicitado")),2,2);
        pc.addBorderCols(" ",2,1,0.0f,0.0f,0.0f,0.5f);		

	    groupByUE   = cdo.getColValue("codigo_ue");
		montoSol    += Double.parseDouble(cdo.getColValue("monto_solicitado"));
		montoTotal  += Double.parseDouble(cdo.getColValue("monto_solicitado"));
		groupBy2    = cdo.getColValue("codigo_ue")+"_"+cdo.getColValue("tipo_inv")+"_"+cdo.getColValue("consec");
	}//for
	
	pc.addBorderCols(" ",1,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
	pc.setFont(8,1);
	pc.addBorderCols("MONTO SOLICITADO:",0,11,0.0f,0.0f,0.5f,0.0f);
	pc.setFont(8,5);
	pc.addCols(CmnMgr.getFormattedDecimal(montoSol),2,2);
	pc.addBorderCols("",2,1,0.0f,0.0f,0.0f,0.5f);
	pc.addBorderCols("",1,infoCol.size(),0.5f,0.0f,0.5f,0.5f,1f);
	
	pc.setFont(8,1);
	pc.addBorderCols(" ",1,infoCol.size(),0.0f,0.0f,0.5f,0.5f);
	pc.addBorderCols("MONTO TOTAL POR UNIDAD:",0,11,0.0f,0.0f,0.5f,0.0f);
	pc.setFont(8,5);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(montoTotal),1,3,0.0f,0.0f,0.0f,0.5f);
	pc.addBorderCols("",1,infoCol.size(),0.5f,0.0f,0.5f,0.5f,1f);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>