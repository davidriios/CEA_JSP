<%@ page errorPage="../error.jsp"%>
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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String id = request.getParameter("id");

if (appendFilter == null) appendFilter = "";
if (id == null) id = "";
if(!id.trim().equals(""))appendFilter += " and a.id ="+id;
sql = "select a.id,a.anio, det.secuencia, det.secuencia || ' - '||a.anio codigo,a.cod_tipo_ajuste, a.monto, to_char(a.fecha,'dd/mm/yyyy') fecha, det.observacion comentario, a.ref_id, a.numero_factura, decode(a.estado,'P','PENDIENTE','R','APROBADO','A','ANULADO') estadoDes, a.estado,(case when a.destino_ajuste in ('P', 'G') then (select c.nombre_proveedor from tbl_com_proveedor c where c.compania=a.compania and c.cod_provedor=to_number(a.ref_id)) when a.destino_ajuste = 'H' then (select m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = to_char(a.ref_id)) when a.destino_ajuste = 'E' then (select nombre from tbl_adm_empresa where codigo =a.ref_id) else 'S/NOMBRE' end) as nombre, b.descripcion,det.cta1,det.cta2,det.cta3,det.cta4,det.cta5,det.cta6,nvl((select descripcion from tbl_con_catalogo_gral where compania =a.compania and cta1=det.cta1 and cta2=det.cta2 and cta3=det.cta3 and cta4=det.cta4 and cta5=det.cta5 and cta6=det.cta6 ),'') descCuenta,a.observacion,det.monto montoDet,det.cta1||'.'||det.cta2||'.'||det.cta3||'.'||det.cta4||'.'||det.cta5||'.'||det.cta6 cuenta from tbl_cxp_ajuste_saldo_enc a, tbl_cxp_tipo_ajuste b, tbl_cxp_ajuste_saldo det  where a.cod_tipo_ajuste = b.cod_tipo_ajuste and a.id = det.id_ref and a.compania= det.cod_cia and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by det.secuencia ";
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
	String title = "CUENTAS POR PAGAR";
	String subtitle = "NOTAS DE AJUSTES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".16");
		dHeader.addElement(".27");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("  Código ",0);	
		pc.addBorderCols("  Descripción",0);
		pc.addBorderCols("  Provededor",0);
		pc.addBorderCols("  Estado ",1);
		pc.addBorderCols("  Fecha ",1);
		pc.addBorderCols("  Monto ",1);
		pc.addBorderCols("  Observación ",0);	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	String groupBy="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(!groupBy.trim().equals(cdo.getColValue("id")))
		{
			if(i!=0)pc.addCols(" ",0,dHeader.size());
			pc.setFont(8, 0);
			pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("estadoDes"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);
			
			pc.addCols(" ",0,dHeader.size());
			
			pc.addBorderCols(" CUENTA  ",1,4);
			pc.addBorderCols(" MONTO",0,1);
			pc.addBorderCols(" COMENTARIO",0,2);
		}
			pc.setFont(7, 0);
			pc.setVAlignment(0);

			pc.addCols(" "+cdo.getColValue("cuenta"),0,2);
			pc.addCols(" "+cdo.getColValue("descCuenta"),0,2);
			pc.addCols(" "+cdo.getColValue("montoDet"),0,1);
			pc.addCols(" "+cdo.getColValue("comentario"),0,2);

			groupBy = cdo.getColValue("id");
			
			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>