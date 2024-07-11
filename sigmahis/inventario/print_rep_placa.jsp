<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
=========================================================================
REP_PLACA.RDF
=========================================================================
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
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fechaini = request.getParameter("fechaIni");
String fechafin = request.getParameter("fechaFin");
String secini = request.getParameter("secini");
String secfin = request.getParameter("secfin");
String fp = request.getParameter("fp");
String familyCode = request.getParameter("familyCode");
String clase = request.getParameter("clase");
String subClase = request.getParameter("subClase");
String anioRecep = request.getParameter("anioRecep");
String noRecep = request.getParameter("noRecep");
String codigoUso = request.getParameter("codigo_uso");

double customWidth = 2;
double customHeight = 1;
float barHeight = 30f;
float barFontSize = 6f;
float headerPerc = .10f;
int headerFontSize = 6;
String headerFieldSize = ".75,.25";
String headerField = "company_name,print_date";
float labelPerc = .10f;
int labelFontSize = 8;
String labelFieldSize = "1";
String labelField = "item_name";
float footerPerc = .10f;
int footerFontSize = 8;
String footerFieldSize = "1";
String footerField = "item_price";
Vector vHeaderFieldSize = new Vector();
Vector vHeaderField = new Vector();
Vector vLabelFieldSize = new Vector();
Vector vLabelField = new Vector();
Vector vFooterFieldSize = new Vector();
Vector vFooterField = new Vector();
try { customWidth = Double.parseDouble(ResourceBundle.getBundle("barcode").getString("inv.width")); } catch(Exception e) { System.out.println("Unable to set WIDTH, using default "+customWidth+"! Error: "+e); }
try { customHeight = Double.parseDouble(ResourceBundle.getBundle("barcode").getString("inv.height")); } catch(Exception e) { System.out.println("Unable to set HEIGHT, using default "+customHeight+"! Error: "+e); }
try { barHeight = Float.parseFloat(ResourceBundle.getBundle("barcode").getString("inv.barcode.height")); } catch(Exception e) { System.out.println("Unable to set BARCODE HEIGHT, using default "+barHeight+"! Error: "+e); }
try { barFontSize = Float.parseFloat(ResourceBundle.getBundle("barcode").getString("inv.barcode.fontsize")); } catch(Exception e) { System.out.println("Unable to set BARCODE FONTSIZE, using default "+barFontSize+"! Error: "+e); }

try { headerPerc = Float.parseFloat(ResourceBundle.getBundle("barcode").getString("inv.header.height")); } catch(Exception e) { System.out.println("Unable to set HEADER HEIGHT, using default "+headerPerc+"! Error: "+e); }
try { headerFontSize = Integer.parseInt(ResourceBundle.getBundle("barcode").getString("inv.header.fontsize")); } catch(Exception e) { System.out.println("Unable to set HEADER FONT SIZE, using default "+headerFontSize+"! Error: "+e); }
try { headerFieldSize = ResourceBundle.getBundle("barcode").getString("inv.header.field.size"); } catch(Exception e) { System.out.println("Unable to set HEADER FIELD SIZE, using default "+headerFieldSize+"! Error: "+e); }
try { headerField = ResourceBundle.getBundle("barcode").getString("inv.header.field"); } catch(Exception e) { System.out.println("Unable to set HEADER FIELD, using default "+headerField+"! Error: "+e); }

try { labelPerc = Float.parseFloat(ResourceBundle.getBundle("barcode").getString("inv.label.height")); } catch(Exception e) { System.out.println("Unable to set LABEL HEIGHT, using default "+labelPerc+"! Error: "+e); }
try { labelFontSize = Integer.parseInt(ResourceBundle.getBundle("barcode").getString("inv.label.fontsize")); } catch(Exception e) { System.out.println("Unable to set LABEL FONT SIZE, using default "+labelFontSize+"! Error: "+e); }
try { labelFieldSize = ResourceBundle.getBundle("barcode").getString("inv.label.field.size"); } catch(Exception e) { System.out.println("Unable to set LABEL FIELD SIZE, using default "+labelFieldSize+"! Error: "+e); }
try { labelField = ResourceBundle.getBundle("barcode").getString("inv.label.field"); } catch(Exception e) { System.out.println("Unable to set LABEL FIELD, using default "+labelField+"! Error: "+e); }

try { footerPerc = Float.parseFloat(ResourceBundle.getBundle("barcode").getString("inv.footer.height")); } catch(Exception e) { System.out.println("Unable to set FOOTER HEIGHT, using default "+footerPerc+"! Error: "+e); }
try { footerFontSize = Integer.parseInt(ResourceBundle.getBundle("barcode").getString("inv.footer.fontsize")); } catch(Exception e) { System.out.println("Unable to set FOOTER FONT SIZE, using default "+footerFontSize+"! Error: "+e); }
try { footerFieldSize = ResourceBundle.getBundle("barcode").getString("inv.footer.field.size"); } catch(Exception e) { System.out.println("Unable to set FOOTER FIELD SIZE, using default "+footerFieldSize+"! Error: "+e); }
try { footerField = ResourceBundle.getBundle("barcode").getString("inv.footer.field"); } catch(Exception e) { System.out.println("Unable to set FOOTER FIELD, using default "+footerField+"! Error: "+e); }

vHeaderFieldSize = CmnMgr.str2vector(headerFieldSize);
vHeaderField = CmnMgr.str2vector(headerField);
vLabelFieldSize = CmnMgr.str2vector(labelFieldSize);
vLabelField = CmnMgr.str2vector(labelField);
vFooterFieldSize = CmnMgr.str2vector(footerFieldSize);
vFooterField = CmnMgr.str2vector(footerField);

String barCode = request.getParameter("barCode");
int qtyToPrint = Integer.parseInt((request.getParameter("qtyToPrint")==null || request.getParameter("qtyToPrint").equals(""))?"1":request.getParameter("qtyToPrint"));
//--
if (secini == null) secini="";
if (secfin == null) secfin="";
if (fechaini == null) fechaini="";
if (fechafin == null) fechafin="";
//thebrain
if (barCode == null) barCode = "";
if (qtyToPrint < 1) qtyToPrint = 1;
if (familyCode == null) familyCode = "";
if (clase == null) clase = "";
if (subClase == null) subClase = "";
if (fp == null) fp = "";
if (anioRecep == null) anioRecep = "";
if (noRecep == null) noRecep = "";
if (codigoUso == null) codigoUso = "0";

//--

if (fp.equalsIgnoreCase("tarifa_uso")) {
  
    sbSql.append("select a.codigo_barra as barcode, ' ' item_name from tbl_sal_uso a where a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and a.codigo = ");
    sbSql.append(codigoUso);
} else {

  if (!fp.equalsIgnoreCase("articulos")) {

    if (!fechaini.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_de_entrada) >= to_date('"); sbFilter.append(fechaini); sbFilter.append("','dd/mm/yyyy')"); }
    if (!fechafin.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_de_entrada) <= to_date('"); sbFilter.append(fechafin); sbFilter.append("','dd/mm/yyyy')"); }
    if (!secini.trim().equals("")) { sbFilter.append(" and a.secuencia_placa >= '"); sbFilter.append(secini); sbFilter.append("'"); }
    if (!secfin.trim().equals("")) { sbFilter.append(" and a.secuencia_placa <= '"); sbFilter.append(secfin); sbFilter.append("'"); }

    sbSql.append("select a.placa as barcode, ' ' item_name from tbl_con_temp_activo a where a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(sbFilter);

  } else {

    sbSql.append("select a.cod_barra as barcode, a.descripcion as item_name, to_char(a.precio_venta,'$9,999,990.00') as item_price, (select nombre_corto from tbl_sec_compania where codigo = a.compania) as company_name, to_char(sysdate,'dd/mm/yyyy') as print_date from tbl_inv_articulo a where a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));

    if (!barCode.trim().equals("")) {
        System.out.println(":::::::::::::::::::::::::::::::::::::::::::: DECODING... "+request.getParameter("barCode"));
      sbSql.append(" and a.cod_barra = '"); 
      try{barCode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barCode"),"barCode",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}   
        sbSql.append(IBIZEscapeChars.forSingleQuots(barCode.toUpperCase()));
      sbSql.append("'");
    } else sbSql.append(" and a.cod_barra is not null");
    if (!familyCode.trim().equals("")) { sbSql.append(" and a.cod_flia = "); sbSql.append(familyCode); }
    if (!clase.trim().equals("")) { sbSql.append(" and a.cod_clase = "); sbSql.append(clase); }
    if (!subClase.trim().equals("")) { sbSql.append(" and a.cod_subclase = "); sbSql.append(subClase); }
    if (!anioRecep.trim().equals("") && !noRecep.trim().equals("")) {
      sbSql.append(" and exists (select 1 from tbl_inv_detalle_recepcion dr where dr.anio_recepcion = ");
      sbSql.append(anioRecep);
      sbSql.append(" and dr.numero_documento = ");
      sbSql.append(noRecep);
      sbSql.append(" and dr.compania = a.compania and dr.cod_familia = a.cod_flia and dr.cod_clase = a.cod_clase and dr.cod_articulo = a.cod_articulo)");
    }

    sbSql.append(" order by a.cod_flia, a.cod_clase, a.cod_articulo");

  }
}
System.out.println(":::::::::::::::::::::::::::::::::::::::");
System.out.println(sbSql.toString());
System.out.println(":::::::::::::::::::::::::::::::::::::::");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {

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
	String logoPath = null;
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = (int) (72 * customWidth);
	int height = (int) (72 * customHeight);
	boolean isLandscape = false;
	float leftRightMargin = 0.1f;
	float topMargin = 0.1f;
	float bottomMargin = 0.1f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector dHeader = new Vector();
		dHeader.addElement(".01");
		dHeader.addElement(".98");
		dHeader.addElement(".01");

	float availHeight = height - (topMargin + bottomMargin) - .1f;
	float hHeight = (headerFontSize + 4.f);//header height
	float lHeight = (labelFontSize + 4.f);//label height
	float fHeight = 0.0f;//footer height
	if(footerFontSize>0)fHeight =(footerFontSize + 4.f);//footer height
	float bHeight = availHeight - (hHeight + lHeight + fHeight);

	if (headerFontSize > (availHeight * headerPerc) - 4) headerFontSize = (int) ((availHeight * headerPerc) - 4);
	if (labelFontSize > (availHeight * labelPerc) - 4) labelFontSize = (int) ((availHeight * labelPerc) - 4);
	if (footerFontSize > (availHeight * footerPerc) - 4) footerFontSize = (int) ((availHeight * footerPerc) - 4);

	//table header
	pc.setNoColumn(1);
	pc.createTable();

	for (int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setNoColumnFixWidth(vHeaderFieldSize);
		pc.createTable("header");
			pc.setFont(headerFontSize,0);
			for (int f=0; f<vHeaderFieldSize.size() && f<vHeaderField.size(); f++) pc.addCols(cdo.getColValue(vHeaderField.get(f).toString()),1,1,hHeight);
			for (int f=0; f<(vHeaderFieldSize.size() - vHeaderField.size()); f++) pc.addCols("",0,1,hHeight);

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("barcode");
			pc.setVAlignment(1);
			pc.addCols("",0,1);
			pc.addImageCols(pc.getBarCode128(cdo.getColValue("barcode"),barFontSize, barHeight),bHeight,1);
			pc.addCols("",0,1);

		pc.setNoColumnFixWidth(vLabelFieldSize);
		pc.createTable("label");
			pc.setFont(labelFontSize,0);
			for (int f=0; f<vLabelFieldSize.size() && f<vLabelField.size(); f++) pc.addCols(cdo.getColValue(vLabelField.get(f).toString()),1,1,lHeight);
			for (int f=0; f<(vLabelFieldSize.size() - vLabelField.size()); f++) pc.addCols("",0,1,lHeight);
		if(!footerFieldSize.trim().equals("0")){
		pc.setNoColumnFixWidth(vFooterFieldSize);
		pc.createTable("footer");
			pc.setFont(footerFontSize,0);
			for (int f=0; f<vFooterFieldSize.size() && f<vFooterField.size(); f++) pc.addCols(cdo.getColValue(vFooterField.get(f).toString()),1,1,fHeight);
			for (int f=0; f<(vFooterFieldSize.size() - vFooterField.size()); f++) pc.addCols("",0,1,fHeight);
			}

		pc.resetVAlignment();
		pc.useTable("main");
		for (int q = 0; q<qtyToPrint; q++) {
			if (headerPerc > 0) pc.addTableToCols("header",0,1,(availHeight * headerPerc));
			pc.addTableToCols("barcode",0,1,(availHeight * (1f - (headerPerc + labelPerc + footerPerc))));
			pc.addTableToCols("label",0,1,(availHeight * labelPerc));
			if (footerPerc > 0) pc.addTableToCols("footer",0,1,(availHeight * footerPerc));

			pc.flushTableBody(true);
			pc.addNewPage();
		} //for q
	}//for i

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>