<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
PLANILLA: PLA0125
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTot = new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
String sql = "";

String _option = request.getParameter("opt");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String subTitle = "";
String cargo = (request.getParameter("cargo")==null?"":request.getParameter("cargo"));
String sec = (request.getParameter("sec")==null?"":request.getParameter("sec"));
String filter = "", filter2 = "";
String descMes="";
if(anio==null)anio="";
if(mes==null)mes="";

if (!mes.trim().equals("")){
    if (mes.equals("01")) descMes = "ENERO";
	else if (mes.equals("02")) descMes = "FEBRERO";
	else if (mes.equals("03")) descMes = "MARZO";
	else if (mes.equals("04")) descMes = "ABRIL";
	else if (mes.equals("05")) descMes = "MAYO";
	else if (mes.equals("06")) descMes = "JUNIO";
	else if (mes.equals("07")) descMes = "JULIO";
	else if (mes.equals("08")) descMes = "AGOSTO";
	else if (mes.equals("09")) descMes = "SEPTIEMBRE";
	else if (mes.equals("10")) descMes = "OCTUBRE";
	else if (mes.equals("11")) descMes = "NOVIEMBRE";
	else descMes = "DICIEMBRE";
 }

if (_option == null || _option.equals("")) throw new Exception("La opción de impresión no es válida!");
if (anio.trim().equals("") ||mes.trim().equals("")) throw new Exception("El año o el mes no es válido!");

if (_option.equalsIgnoreCase("sobre_tiempo")) {
     subTitle = "INFORME DE SALARIO Y SOBRETIEMPO";

	 if ( !cargo.equals(""))
	 {
	 filter += " AND EM.CARGO = "+cargo+"";
	 filter2 += " AND EM.CARGO = "+cargo+"";
	 }
	 if ( !sec.equals(""))
	 {
	 filter += " AND PA.UNIDAD_ORGANI = "+sec+"";
	 filter2 += " AND PL.UNIDAD_ORGANI = "+sec+"";
	 }
}

sql = "SELECT ca.codigo,ca.denominacion, pa.unidad_organi unidad, '[ '||pa.unidad_organi||' ] '||u.descripcion seccion, pa.provincia, pa.sigla, pa.tomo, pa.asiento, NVL(pa.num_empleado,'0') num_empleado, DECODE(pa.cod_planilla,1,'ACTIVO',2,'VACACIONES','VER CODIGO') estado, em.nombre_empleado, em.cedula1 cedula,sum(nvl(pa.sal_bruto,0)-nvl(pa.extra,0)-nvl(pa.bonificacion,0)) salario,sum(nvl(pa.extra,0)) sobretiempo, sum(nvl(pa.sal_bruto,0)-nvl(pa.bonificacion,0)) total from  tbl_pla_pago_empleado pa, tbl_pla_planilla_encabezado pe,vw_pla_empleado em, tbl_pla_cargo ca, tbl_sec_unidad_ejec u where pe.cod_compania = pa.cod_compania and ca.codigo = em.cargo and ca.compania = em.compania and pe.anio = pa.anio and   pe.cod_planilla = pa.cod_planilla and pe.num_planilla  = pa.num_planilla  and  em.emp_id = pa.emp_id and em.compania = pa.cod_compania and pa.cod_planilla = 1 and pa.cod_compania = "+compania+" and to_number(to_char(pe.fecha_pago,'MM')) = "+mes+" and to_number(to_char(pe.fecha_pago,'YYYY')) = "+anio+filter+"  and pa.unidad_organi = u.codigo and pa.cod_compania = u.compania group by ca.codigo,ca.denominacion, pa.unidad_organi, '[ '||pa.unidad_organi||' ] '||u.descripcion, pa.provincia, pa.sigla, pa.tomo, pa.asiento, nvl(pa.num_empleado,'0'), decode(pa.cod_planilla,1,'ACTIVO',2,'VACACIONES','VER CODIGO'), em.nombre_empleado ,em.cedula1 having sum(nvl(pa.sal_bruto,0)-nvl(pa.extra,0)) <> 0 or sum(nvl(pa.extra,0)) <> 0 union select ca.codigo, ca.denominacion, pl.unidad_organi unidad, '[ '||pl.unidad_organi||' ] '||u.descripcion seccion, pl.provincia, pl.sigla, pl.tomo, pl.asiento, nvl(pl.num_empleado,'0') num_empleado, decode(pl.cod_planilla,8,'LIQUIDADO','VER CODIGO') estado, em.nombre_empleado,em.cedula1 cedula,SUM(NVL(pl.salario,0)-NVL(pl.extra,0)) salario,SUM(NVL(pl.extra,0)) sobretiempo, SUM(NVL(pl.salario,0)  ) total FROM TBL_PLA_PAGO_LIQUIDACION pl, TBL_PLA_PLANILLA_ENCABEZADO pe, vw_pla_empleado em, TBL_PLA_CARGO ca, tbl_sec_unidad_ejec u WHERE  pe.cod_compania = pl.cod_compania AND pe.anio  = pl.anio AND pe.cod_planilla  = pl.cod_planilla AND pe.num_planilla  = pl.num_planilla  AND ca.codigo = em.cargo AND ca.compania = em.compania AND em.emp_id = pl.emp_id AND em.compania  = pl.cod_compania AND pl.cod_compania  = "+compania+" AND TO_NUMBER(TO_CHAR(pe.fecha_pago,'MM')) 	= "+mes+" AND  TO_NUMBER(TO_CHAR(pe.fecha_pago,'YYYY'))= "+anio+filter2+" AND pl.cod_planilla = 8 and pl.unidad_organi = u.codigo and pl.cod_compania = u.compania GROUP BY ca.codigo, ca.denominacion, pl.unidad_organi, '[ '||pl.unidad_organi||' ] '||u.descripcion, pl.provincia, pl.sigla, pl.tomo, pl.asiento, pl.num_empleado, DECODE(pl.cod_planilla,8,'LIQUIDADO','VER CODIGO'),em.nombre_empleado,em.cedula1 HAVING SUM(NVL(pl.salario,0)-NVL(pl.extra,0)) <> 0 OR SUM(NVL(pl.extra,0)) <> 0 ORDER BY 3,1,11";

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
	float headerFooterFont = 5f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = subTitle;
	String xtraSubtitle = "CORRESPONDIENTE AL MES DE "+descMes+" DE "+anio ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".13");
	dHeader.addElement(".30");
	dHeader.addElement(".11");
	dHeader.addElement(".12");
	dHeader.addElement(".12");
	dHeader.addElement(".12");


	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


	//create de table header (2 rows) and add header to the table


		pc.addCols("NO. EMP.",0,1);
		pc.addCols("CEDULA",1,1);
		pc.addCols("NOMBRE DEL COLABORADOR",0,1);
		pc.addCols("ESTADO",1,1);
		pc.addCols("SALARIO",2,1);
		pc.addCols("SOBRETIEMPO",2,1);
		pc.addCols("TOTAL",2,1);
		pc.setFont(9,1);
		pc.addBorderCols("",0,7, 1f, 0.0f, 0.0f, 0.0f);
	pc.setTableHeader(3);
	double totalSalCargo = 0.00, totalExtraCargo = 0.00,totalCargo = 0.00;
	double totalSalUnidad = 0.00, totalExtraUnidad = 0.00,totalUnidad = 0.00;
	double totalSalFinal = 0.00, totalExtraFinal = 0.00,totalFinal = 0.00;
	String unidad="",groupBy1="";

	for ( int i = 0; i<al.size(); i++ ){

		cdo = (CommonDataObject) al.get(i);
		pc.setFont(8,1);

		if(i !=0)
		{
			if (!groupBy1.trim().equals(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo")))
			{
				pc.addCols(" TOTALES POR CARGO:  ",1,4);
				pc.addCols(CmnMgr.getFormattedDecimal(totalSalCargo),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalExtraCargo),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalCargo),2,1);
				totalSalCargo=0.00;
				totalExtraCargo=0.00;
				totalCargo=0.00;
				//pc.addCols(" ",0,dHeader.size());
			}
		}

		if (!unidad.trim().equals(cdo.getColValue("unidad")))
		{
			if(i !=0)
			{
				pc.addCols(" TOTALES POR UNIDAD:  ",1,4);
				pc.addCols(CmnMgr.getFormattedDecimal(totalSalUnidad),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalExtraUnidad),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalUnidad),2,1);
				totalSalUnidad=0.00;
				totalExtraUnidad=0.00;
				totalUnidad=0.00;
				pc.setFont(7,0);
				pc.addCols(" ",0,dHeader.size());
			}
			pc.setFont(8,1);
			pc.addCols("   UNIDAD:     "+cdo.getColValue("seccion"),0,dHeader.size());
			groupBy1="";
		}
		if (!groupBy1.trim().equals(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo")))
		{

			pc.addCols("   CARGO:     "+cdo.getColValue("denominacion"),0,dHeader.size());
			pc.addBorderCols("",0,dHeader.size(), 0.5f, 0.0f, 0.0f, 0.0f);

		}


		pc.setFont(8,0);
		pc.addCols(cdo.getColValue("num_empleado"),0,1);
	    pc.addCols(cdo.getColValue("cedula"),0,1);
		pc.addCols(cdo.getColValue("nombre_empleado"),0,1);
		pc.addCols(cdo.getColValue("estado"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("salario")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("sobretiempo")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);


		totalSalCargo += Double.parseDouble(cdo.getColValue("salario"));
		totalExtraCargo += Double.parseDouble(cdo.getColValue("sobretiempo"));
		totalCargo += Double.parseDouble(cdo.getColValue("total"));

		totalSalUnidad += Double.parseDouble(cdo.getColValue("salario"));
		totalExtraUnidad += Double.parseDouble(cdo.getColValue("sobretiempo"));
		totalUnidad += Double.parseDouble(cdo.getColValue("total"));

		totalSalFinal += Double.parseDouble(cdo.getColValue("salario"));
		totalExtraFinal += Double.parseDouble(cdo.getColValue("sobretiempo"));
		totalFinal += Double.parseDouble(cdo.getColValue("total"));

		groupBy1=cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo");
		unidad=cdo.getColValue("unidad");


//FINALES TOTALES

if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}//for i
if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{


	pc.setFont(9,1);

		pc.addCols(" TOTALES POR CARGO:  ",1,4);
		pc.addCols(CmnMgr.getFormattedDecimal(totalSalCargo),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalExtraCargo),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalCargo),2,1);

		pc.addCols(" TOTALES POR UNIDAD:  ",1,4);
		pc.addCols(CmnMgr.getFormattedDecimal(totalSalUnidad),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalExtraUnidad),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalUnidad),2,1);


	pc.addBorderCols("",0,7, 1f, 0.0f, 0.0f, 0.0f);
	pc.addCols(" TOTAL DE EMPLEADOS: "+al.size(),1,2);
	pc.addCols(" TOTALES FINALES: ",1,2);
	pc.addCols(CmnMgr.getFormattedDecimal(totalSalFinal),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(totalExtraFinal),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(totalFinal),2,1);

	pc.setFont(9,1);
	pc.addBorderCols("",0,7, 1f, 0.0f, 0.0f, 0.0f);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>