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

String compania = (String)session.getAttribute("_companyId");
String status = request.getParameter("estado");
String codigo = request.getParameter("codigo");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String descripcion = request.getParameter("descripcion");
String cds = request.getParameter("cds");
String tipoTrx = request.getParameter("tipoTrx");
String noAprob = request.getParameter("no_aprob");
String noPoliza = request.getParameter("no_poliza");

StringBuffer sbSql = new StringBuffer();
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

if (codigo == null) codigo = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (descripcion == null) descripcion = "";
if (cds == null) cds = "";
if (tipoTrx == null) tipoTrx = "";
if (noAprob == null) noAprob = "";
if (noPoliza == null) noPoliza = "";
if (status == null) status = "";

sbSql = new StringBuffer();
     sbSql.append("select l.codigo, l.no_aprob, nvl(l.descripcion,'N/A') as observacion, l.total, l.nombre_cliente, l.cedula_cliente, l.tipo_transaccion, case when l.tipo = 1 then e.nombre when l.tipo = 0 then case when (select medico from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = 1 and empresa is null and honorario_por = 'M' and rownum = 1 ) is not null then (select 'Dr(a). '||primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = (select medico from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = ");
    sbSql.append(compania);
    sbSql.append(" and empresa is null and honorario_por = 'M' and rownum = 1 )) when (select empresa from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = 1 and medico is null and honorario_por = 'E' and rownum = 1 ) is not null then (select nombre from tbl_adm_empresa where codigo = (select empresa from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = 1 and medico is null and honorario_por = 'E' and rownum = 1 )) end when l.tipo = 2 then l.nombre_cliente  end as empresa, l.poliza, l.status, decode(case when l.no_odp is not null then 'D' else l.status end, 'A', 'Aprobado', 'P', 'Pendiente', 'N', 'Anulado', 'R','Rechazado', 'D', 'Pagado') estado_desc, to_char(l.fecha_creacion,'dd/mm/yyyy') fc, nvl(l.from_cargos, 'N') from_cargos, decode(l.tipo,0,'Honorario',1,'Empresa',2,'Beneficiario',' ') tipo from tbl_pm_liquidacion_reclamo l, tbl_pm_centros_atencion e where l.empresa = e.id ");
    
    if (!codigo.trim().equals("")) {
      sbSql.append(" and l.codigo = ");
      sbSql.append(codigo);
    }
    
    if (!cds.trim().equals("")) {
      sbSql.append(" and l.centro_servicio = ");
      sbSql.append(cds);
    }
    
    if (!descripcion.trim().equals("")) {
      sbSql.append(" and l.nombre_cliente like '%");
      sbSql.append(descripcion);
      sbSql.append("%'");
    }
    
    if (!tipoTrx.trim().equals("")) {
      sbSql.append(" and l.tipo_transaccion = '");
      sbSql.append(tipoTrx);
      sbSql.append("'");
    }
    
     if (!noAprob.trim().equals("")) {
      sbSql.append(" and l.no_aprob = '");
      sbSql.append(noAprob);
      sbSql.append("'");
    }
    
    if (!noPoliza.trim().equals("")) {
      sbSql.append(" and l.poliza = '");
      sbSql.append(noPoliza);
      sbSql.append("'");
    }
    
    if (!status.trim().equals("")) {
      sbSql.append(" and l.status = '");
      sbSql.append(status);
      sbSql.append("'");
    }
    
    if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
      sbSql.append(" and trunc(l.fecha) between to_date('");
      sbSql.append(fechaIni);
      sbSql.append("','dd/mm/yyyy') and to_date('");
      sbSql.append(fechaFin);
      sbSql.append("','dd/mm/yyyy')");
    }
    
    sbSql.append(" order by 1 desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
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
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "LISTADO DE LIQUIDACION DE RECLAMO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".05"); //Póliza
	setDetail.addElement(".06"); //No. Aprob
	setDetail.addElement(".08"); //Tipo Liq.
	setDetail.addElement(".25"); //Empresa
	setDetail.addElement(".25"); //Cliente
	setDetail.addElement(".10"); //Cédula
	setDetail.addElement(".07"); //Fecha
	setDetail.addElement(".07"); //Estado
	setDetail.addElement(".07"); //Monto

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, UserDet.getUserName(), fecha, setDetail.size());

	//second row
	pc.setFont(7, 1);
	pc.addBorderCols("POLIZA",0,1);
	pc.addBorderCols("NO.RECL.",1,1);
	pc.addBorderCols("TIPO LIQ.",1,1);
    
	pc.addBorderCols("A FAVOR DE",0,1);
	pc.addBorderCols("CLIENTE",0,1);
	pc.addBorderCols("CEDULA",1,1);
	pc.addBorderCols("FECHA",1,1);
	pc.addBorderCols("ESTADO",1,1);
	pc.addBorderCols("MONTO",1,1);

	pc.addCols("",0,setDetail.size());

	pc.setTableHeader(3);

	if (al.size() < 1) pc.addCols("*** No Encontramos Ningún Registro ***",1,setDetail.size());
    
    double total = 0.00;

	pc.setFont(7, 0);
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);

		pc.addCols(cdo.getColValue("poliza"),0,1);
		pc.addCols(cdo.getColValue("no_aprob"),1,1);
		pc.addCols(cdo.getColValue("tipo"),1,1);
		pc.addCols(cdo.getColValue("empresa"),0,1);
		pc.addCols(cdo.getColValue("nombre_cliente"),0,1);
		pc.addCols(cdo.getColValue("cedula_cliente"),1,1);
		pc.addCols(cdo.getColValue("fc"),1,1);
		pc.addCols(cdo.getColValue("estado_desc"),1,1);
		pc.addCols(cdo.getColValue("total"),2,1);
        
        total += Double.parseDouble(cdo.getColValue("total","0"));
	}
      pc.addCols("",0,setDetail.size());
      pc.setFont(8, 1);
      pc.addCols("Total",2,6);
      pc.addCols(""+total,2,1);
      
       pc.addCols(" ",0,setDetail.size());
       pc.addCols(" ",0,setDetail.size());
       pc.addCols("Aprobado por:",1,2);
       pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
       pc.addCols("",0,2);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>