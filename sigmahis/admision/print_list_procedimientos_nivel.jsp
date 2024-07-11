<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
StringBuffer sb = new StringBuffer();

if (appendFilter == null) appendFilter = "";

sb.append("select a.codigo, a.descripcion, nvl(a.observacion,'') as observacion, nvl(b.nombre,'SIN CATEGORIA') as categoria, nvl(a.precio,0) as precio ,n.nivel, n.nivel_nombre, n.ref_type, n.ref_code ");
sb.append(", case when n.ref_type = 1 then (select nombre from tbl_adm_empresa where codigo = n.ref_code and rownum = 1) when n.ref_type = 2 then (select nombre from tbl_cds_centro_servicio where codigo = n.ref_code and rownum = 1) when n.ref_type = 3 then (select descripcion from tbl_adm_categoria_admision where codigo = n.ref_code and rownum = 1) end as ref_desc,n.precio as precio_nivel, n.precio_oferta, to_char(n.fecha_ini_oferta, 'dd/mm/yyyy') fecha_ini_oferta, to_char(n.fecha_fin_oferta, 'dd/mm/yyyy') fecha_fin_oferta, oferta_aplica_emp from tbl_cds_procedimiento a, tbl_cds_tipo_categoria b , tbl_fac_nivel_precio n where a.tipo_categoria=b.codigo(+) ");
sb.append(appendFilter);
sb.append(" and a.codigo = n.cargo_code(+) ");
sb.append(" order by a.codigo, 6 ");

al = SQLMgr.getDataList(sb);

if (request.getMethod().equalsIgnoreCase("GET"))
{
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year = fecha.substring(6, 10);
String month = fecha.substring(3, 5);
String day = fecha.substring(0, 2);
String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");
String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
String subtitle = "LISTADO DE PROCEDIMIENTOS";
String xtraSubtitle = "CON NIVELES DE PRECIO";
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
float cHeight = 11.0f;

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader  = new Vector();
	dHeader .addElement(".06");
	dHeader .addElement(".30");
	dHeader .addElement(".38");
	dHeader .addElement(".20");
	dHeader .addElement(".06");
	
	Vector tblNivel  = new Vector();
	tblNivel .addElement(".05");
	tblNivel .addElement(".25");
	tblNivel .addElement(".25");
	tblNivel .addElement(".05");
	tblNivel .addElement(".10");
	tblNivel .addElement(".10");
	tblNivel .addElement(".10");
	tblNivel .addElement(".10");
	
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7, 1);
		pc.addBorderCols("Código",1);
		pc.addBorderCols("Descripción",1);
		pc.addBorderCols("Descripción Español",1);
		pc.addBorderCols("Categoría",1);
		pc.addBorderCols("Precio",1);
		pc.setTableHeader(2);

	
	String gProc = "";
	
	for (int i=0; i<al.size(); i++){
	
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		boolean showDet = cdo.getColValue("nivel") != null && !"".equals(cdo.getColValue("nivel"));
		
		if (!gProc.equals(cdo.getColValue("codigo"))){
					
			if(showDet && i!=0)pc.addCols(" ",1,dHeader.size());
			pc.setFont(6, 0); 
			pc.addCols(" "+cdo.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);
			pc.addCols(" "+cdo.getColValue("categoria"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1);
					
			
			if(showDet){
				pc.setNoColumnFixWidth(tblNivel);
				pc.createTable("nivelHdr");
					pc.setFont(7,1);
					//pc.addCols(" *** NIVELES *** ",1,tblNivel.size());
					pc.addBorderCols("Nivel",1,1,0.5f,0.5f,0.5f,0.0f);
					pc.addBorderCols("Nombre",0,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("Tipo",0,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("Precio",2,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("P.Oferta",2,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("FI.Oferta",1,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("FF.Oferta",1,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("Aplica Emp.",1,1,0.5f,0.5f,0.0f,0.5f);
									
				pc.useTable("main");
				pc.addTableToCols("nivelHdr",1,dHeader.size(),0f);
			}

		}
		
		if(showDet){
			pc.setNoColumnFixWidth(tblNivel);
			pc.createTable("nivelDet");
				pc.setFont(6,0);
				pc.addBorderCols(cdo.getColValue("nivel"),1,0,0.5f,0.0f,0.5f,0.0f);
				pc.addBorderCols(cdo.getColValue("nivel_nombre"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("ref_desc"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("precio_nivel"),2,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("precio_oferta"),2,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("fecha_ini_oferta"),1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("fecha_fin_oferta"),1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("oferta_aplica_emp"),1,1,0.5f,0.0f,0.0f,0.5f);
			
			pc.useTable("main");
			pc.addTableToCols("nivelDet",1,dHeader.size(),0f);
		}
		
		gProc = cdo.getColValue("codigo");
		
	}//for i
	
	if (al.size() == 0)pc.addCols("No existen registros",1,dHeader .size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>