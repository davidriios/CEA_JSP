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
/*
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDet = new ArrayList();
String sql = "";
String sqlT = "";
String sqlU = "";

String desde = request.getParameter("desde");
String hasta  = request.getParameter("hasta");
String cuenta  = request.getParameter("cuenta");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String unidad  = request.getParameter("unidad");
String proveedor  = request.getParameter("proveedor");
String activo = request.getParameter("activo");
String estatus = request.getParameter("estatus");
String fechaFinal = request.getParameter("fechaFinal");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");

if(appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(cuenta == null) cuenta = "";
if(proveedor == null) proveedor = "";
if(unidad == null) unidad = "";
if(activo == null) activo = "";
if(estatus == null) estatus = "";
if(fechaFinal == null) fechaFinal = "";
if(mes == null) mes = "";
if(anio == null) anio = "";
if (!anio.equals(""))
{
 appendFilter += "and d.cod_ano = "+anio;
}
if (!mes.equals(""))
{
 appendFilter += "and d.cod_mes = "+mes;
}

if (!cuenta.equals(""))
{
 appendFilter += "and ( h.cta1_depre_acum||'.'||h.cta2_depre_acum||'.'||h.cta3_depre_acum||'.'||h.cta4_depre_acum||'.'||h.cta5_depre_acum||'.'||h.cta6_depre_acum  like '%"+cuenta+"%' or nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))||'.'|| nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))  like '%"+cuenta+"%'  )";
}
if (!desde.equals(""))
{
 appendFilter += "and a.fecha_de_entrada >= to_date('"+desde+"','dd/mm/yyyy')";
}
if (!hasta.equals(""))
{
 appendFilter += "and a.fecha_de_entrada <= to_date('"+hasta+"','dd/mm/yyyy')";
}
if (!proveedor.equals(""))
{
 appendFilter += " and a.cod_provee = '"+proveedor+"'";
}
if (!unidad.equalsIgnoreCase(""))
{
 appendFilter += " and a.ue_codigo = "+unidad;
}
if (!activo.equalsIgnoreCase(""))
{
 appendFilter += " and a.secuencia = '"+activo+"'";
}
if (!estatus.equalsIgnoreCase(""))
{
 appendFilter += " and a.estatus = '"+estatus+"'";
}
        		 
 
sql ="select a.secuencia,a.observacion,nvl((select c.descripcion from tbl_sec_unidad_ejec c where c.compania = a.compania and c.codigo=a.ue_codigo),' ') as unidad_desc,to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada,nvl((select p.nombre_proveedor from tbl_com_proveedor p where p.cod_provedor=a.cod_provee),' ') as proveedor_desc,a.valor_inicial,nvl(a.valor_actual,0) valor_actual,nvl(a.vida_estimada,'0') vida_estimada,nvl(a.valor_deprem,0) valor_deprem,nvl(d.monto_depre,0) as depreciacion ,nvl(d.depre_acum_act,0) acum_deprec,to_char(a.final_garantia,'dd/mm/yyyy') final_garantia,b.descripcion listado_activo,h.cta1_depre_acum||'-'||h.cta2_depre_acum||'-'||h.cta3_depre_acum||'-'||h.cta4_depre_acum||'-'||h.cta5_depre_acum||'-'||h.cta6_depre_acum as cuentaActivo,h.cta1_depre_acum||'-'||h.cta2_depre_acum||'-'||h.cta3_depre_acum||'-'||h.cta4_depre_acum||'-'||h.cta5_depre_acum||'-'||h.cta6_depre_acum as cuenta_depre, nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))||'.'|| nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))||'.'||nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia)) as cuenta_gasto, h.descripcion cuentah_desc  from tbl_con_activos a, tbl_con_detalle_otro b,tbl_con_especificacion h,tbl_con_temporal_depreciacion d  where a.compania="+(String)session.getAttribute("_companyId")+" and a.secuencia = d.activo_sec and a.compania = d.compania and a.compania=b.cod_compania and a.cuentah_detalle=b.codigo_detalle(+)  and a.cuentah_activo =h.cta_control(+) and a.cuentah_espec = h.codigo_espec(+) and a.compania = h.compania(+)  "+appendFilter+"  order by h.cta1_depre_acum||'-'||h.cta2_depre_acum||'-'||h.cta3_depre_acum||'-'||h.cta4_depre_acum||'-'||h.cta5_depre_acum||'-'||h.cta6_depre_acum, a.cuentah_activo||'-'||a.cuentah_espec||'-'||a.cuentah_detalle||'-'||b.descripcion,a.secuencia  ";
al = SQLMgr.getDataList(sql);

  double monto_total = 0.00, monto_total_ini=0.00, monto_total_dep=0.00;
	double total_act = 0.00,total_ini=0.00, total_dep=0.00;
	double total_cta_act = 0.00,total_cta_ini=0.00, total_cta_dep=0.00;
	double total_act_listado = 0.00,total_ini_listado=0.00, total_dep_listado=0.00;
	double total_acum_deprec = 0.00, total_cta_acum_deprec = 0.00, total_acum_deprec_listado = 0.00;
	double tot_final_acum_deprec = 0.00;

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
	String title = "CONTABILIDAD";
	String subtitle = "LISTADO DE DEPRECIACION";
	String xtraSubtitle = "ACTIVOS POR CUENTAS CONTABLES ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dDetalle = new Vector();
		dDetalle.addElement(".04");
		dDetalle.addElement(".16");
		dDetalle.addElement(".14");
		dDetalle.addElement(".11");
		dDetalle.addElement(".11");
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".05");
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".07");

 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(6, 1);

		pc.addCols("COD.ACTIVO",1,1);
		pc.addCols("DESCRIPCION",0,1);
		pc.addCols("DEPARTAMENTO",0,1);
		pc.addCols("CUENTA DEPREC.",1,1);
		pc.addCols("CUENTA GASTO",1,1);
		pc.addCols("VALOR INICIAL",2,1);
		pc.addCols("VALOR ACTUAL",2,1);
		pc.addCols("VIDA ESTIMADA",1,1);
		pc.addCols("DEPREC. MENS.",2,1);
		pc.addCols("DEPREC. ACUM.",2,1);
		pc.addCols("FINAL GARANTIA",0,1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

		//second row
		pc.setFont(7, 1);

	   int no = 0;
		 String cod = "";
		 String esp = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
 
		pc.setFont(7, 0);
		pc.setVAlignment(0);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo.getColValue("secuencia"),0,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);
			pc.addCols(" "+cdo.getColValue("unidad_desc"),0,1);
			pc.addCols(" "+cdo.getColValue("cuenta_depre"),1,1);
			pc.addCols(" "+cdo.getColValue("cuenta_gasto"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_inicial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_actual")),2,1);
			pc.addCols(" "+cdo.getColValue("vida_estimada"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("depreciacion")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("acum_deprec")),2,1);
			pc.addCols(" "+cdo.getColValue("final_garantia"),1,1);

		cod  = cdo.getColValue("cuentaActivo");
		esp  = cdo.getColValue("listado_activo");
		total_act  += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_ini  += Double.parseDouble(cdo.getColValue("valor_inicial"));
		total_dep  += Double.parseDouble(cdo.getColValue("depreciacion"));		
		tot_final_acum_deprec += Double.parseDouble(cdo.getColValue("acum_deprec"));


	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
		pc.setFont(7, 1);
		
		pc.addCols("",1,dDetalle.size());

		pc.addCols(" TOTAL FINAL . . . . . ",2,5);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ini),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_act),2,1);
		pc.addCols("  ",0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_dep),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(tot_final_acum_deprec),2,1);
		pc.addCols("  ",0,1);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>