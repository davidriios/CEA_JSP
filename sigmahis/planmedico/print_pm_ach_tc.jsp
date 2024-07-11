<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.awt.Color" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();
String anio = request.getParameter("anio");
String mesDesc = request.getParameter("mesDesc");
String tipoTrx = request.getParameter("tipoTrx");
String sql = "", idSol = (request.getParameter("idSol")==null?"":request.getParameter("idSol"));
String appendFilter = (request.getParameter("appendFilter")==null?"":request.getParameter("appendFilter"));
StringBuffer sbSql = new StringBuffer();

sbSql.append("select a.id, a.secuencia, a.id_contrato, a.id_cliente, (select nombre_paciente from vw_pm_cliente where codigo = a.id_cliente) nombre_cliente, a.estado, a.tipo_trx, (a.monto * a.periodo) monto, a.monto_app, a.id_corredor, to_char (a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char (a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.periodo, b.num_tarjeta_cta, to_char(decode(b.tipo, 'C', a.fecha_creacion, 'T', b.fecha_vence), 'dd/mm/yyyy') fecha_inicio, b.tipo, b.cod_banco, b.tipo_tarjeta, decode(a.tipo_trx, 'M','MANUAL',decode(b.tipo, 'C', 'ACH', 'T', (select descripcion from tbl_cja_tipo_tarjeta t where t.codigo = b.tipo_tarjeta))) tipo_tarjeta_desc, rownum no, (select nombre_banco from tbl_adm_ruta_transito where ruta = b.cod_banco) ruta_desc from tbl_pm_regtran_det a, (select id_solicitud, id, num_tarjeta_cta, fecha_inicio, tipo, cod_banco, tipo_tarjeta, fecha_vence from tbl_pm_cta_tarjeta where estado = 'A') b where a.estado != 'R' and a.id_contrato = b.id_solicitud(+) and a.id = ");
sbSql.append(idSol);
sbSql.append(" order by a.id_contrato desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = (tipoTrx.equals("TC")?"LISTA DE PAGOS DE CUOTAS POR TARJETA":"LISTA DE PAGOS DE CUOTAS POR DESCUENTO BANCARIO");
	String subtitle = "LOTE NO. "+idSol+" ["+anio+" - "+mesDesc+"]";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".04"); //No.
	setDetail.addElement(".09"); //Contrato
	setDetail.addElement(".24"); //Nombre tarjetahabiente
	setDetail.addElement(".15"); //Banco
	setDetail.addElement(".12"); //Tarjeta
	setDetail.addElement(".15"); //Numero Tarjeta
	setDetail.addElement(".10"); //Valor
	setDetail.addElement(".10"); //Validacion

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, UserDet.getUserName(), fecha, setDetail.size());

	//second row
	pc.setFont(8, 1);
	pc.addBorderCols("NO.",0,1);
	pc.addBorderCols("CONTRATO",1,1);
	pc.addBorderCols("NOMBRE",1,1);
	pc.addBorderCols("BANCO",1,1);
	pc.addBorderCols("TIPO",1,1);
	pc.addBorderCols("NUMERO",1,1);
	pc.addBorderCols("VALOR",1,1);
	if(tipoTrx.equals("TC")) pc.addBorderCols("VALIDACION",1,1);
	else pc.addBorderCols("FECHA GRABADO",1,1);

	pc.addCols("",0,setDetail.size());

	pc.setTableHeader(3);

	if (al.size() < 1) pc.addCols("*** No Encontramos Ningún Registro ***",1,setDetail.size());
	Double total = 0.00, monto = 0.00;
	pc.setFont(8, 0);
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);
		if (cdo.getColValue("tipo_trx").equalsIgnoreCase("M")) monto = Double.parseDouble(cdo.getColValue("monto_app"));
		else monto = Double.parseDouble(cdo.getColValue("monto"));
		total += monto;
		pc.addCols(cdo.getColValue("no"),0,1);
		pc.addCols(cdo.getColValue("id_contrato"),1,1);
		pc.addCols(cdo.getColValue("nombre_cliente"),1,1);
		pc.addCols(cdo.getColValue("ruta_desc"),1,1);
		pc.addCols(cdo.getColValue("tipo_tarjeta_desc"),1,1);
		pc.addCols(CmnMgr.getDecryptToShow(cdo.getColValue("num_tarjeta_cta"), -1),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(monto),2,1);
		pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
	}
	pc.addBorderCols("TOTAL", 2, 6, 0.0f, 0.5f, 0.0f, 0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(total), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
	pc.addBorderCols("", 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>