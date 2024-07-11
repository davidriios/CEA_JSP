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
String anio = request.getParameter("anio");
String mes  = request.getParameter("mes");
String unidad  = request.getParameter("unidad");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");

if(fg == null) fg ="t";   // temporal
if (appendFilter == null) appendFilter = "";

	CommonDataObject cdUD = SQLMgr.getData("select (to_char(last_day(to_date('01/'||to_char("+mes+", '09')||'/'||'"+anio+"', 'DD/MM/YYYY')), 'DD')) ||' de '|| to_char(to_date(to_char("+mes+",'09'),'MM'),'MONTH', 'NLS_DATE_LANGUAGE=SPANISH') ||' de '|| to_char("+anio+") ud from dual");
	String dia = (cdUD.getColValue("ud"));


if (fg.trim().equals("t"))
{
		sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1,nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2, nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4,nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6,a.ue_codigo, u.DESCRIPCION, d.cod_ano, d.cod_mes, to_char(a.fecha_de_entrada,'dd/mm/yyyy') entrada, a.valor_inicial, d.monto_depre, to_char(a.final_garantia,'dd/mm/yyyy') final, a.secuencia, d.valor_activo_act actual, o.descripcion otro, a.observacion from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u, tbl_con_detalle_otro o where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = o.codigo_detalle and a.compania = o.cod_compania and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" and a.ue_codigo = "+unidad+" order by  a.fecha_de_entrada";
		al = SQLMgr.getDataList(sql);
		//sqlT= "select sum(nvl(a.valor_inicial,0)) tot_inicial, sum(nvl(d.monto_depre,0)) tot_depre, sum(nvl(d.valor_activo_act,0)) tot_actual from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u, tbl_con_detalle_otro o where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = o.codigo_detalle and a.compania = o.cod_compania and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" and a.ue_codigo = "+unidad;
} else {
		sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1,nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2, nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3, nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4, nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6, a.ue_codigo, u.DESCRIPCION, d.cd_ano  cod_ano, d.cd_mes cod_mes, to_char(a.fecha_de_entrada,'dd/mm/yyyy') entrada, a.valor_inicial, d.monto_depre, to_char(a.final_garantia,'dd/mm/yyyy') final, a.secuencia, d.valor_activo_act actual, o.descripcion otro, a.observacion from tbl_con_deprec_mensual d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u, tbl_con_detalle_otro o where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = o.codigo_detalle and a.compania = o.cod_compania and d.cd_ano = "+anio+" and d.cd_mes = "+mes+" and a.ue_codigo = "+unidad+" order by  a.fecha_de_entrada";
		al = SQLMgr.getDataList(sql);
		//sqlT= "select sum(nvl(a.valor_inicial,0)) tot_inicial, sum(nvl(d.monto_depre,0)) tot_depre, sum(nvl(d.valor_activo_act,0)) tot_actual from tbl_con_deprec_mensual d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u, tbl_con_detalle_otro o where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = o.codigo_detalle and a.compania = o.cod_compania and d.cd_ano = "+anio+" and d.cd_mes = "+mes+" and a.ue_codigo = "+unidad;
}

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
	String title = "CONTABILIDAD";
	String subtitle = "Activos por Unidad Administrativa";
	String xtraSubtitle = "Depreciación hasta el : " +cdUD.getColValue("ud");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	Vector dDetalle = new Vector();
		dDetalle.addElement(".08");
		dDetalle.addElement(".20");
		dDetalle.addElement(".28");
		dDetalle.addElement(".08");
		dDetalle.addElement(".10");
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".10");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


 	pc.setNoColumnFixWidth(dDetalle);
	//table header
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

	//second row
	pc.setFont(7, 1);

		pc.addBorderCols("SEC.",0,1);
		pc.addBorderCols("DESCRIPCION ",0,1);
		pc.addBorderCols("OBSERVACION ",1,1);
		pc.addBorderCols("ENTRADA ",1,1);
		pc.addBorderCols("VALOR INICIAL ",2,1);
		pc.addBorderCols("VALOR DEPREC.",2,1);
		pc.addBorderCols("FECHA FINAL ",1,1);
		pc.addBorderCols("VALOR ACTUAL ",2,1);
		pc.setTableHeader(3);

	//table body
	pc.setVAlignment(0);
  int no = 0;
  double tot_inicial =0.00, tot_depre =0.00, tot_actual =0.00;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (i==0)
		{
			pc.setFont(8, 1);
			pc.addCols("Departamento: "+cdo.getColValue("descripcion"),0,dDetalle.size());
		}

		pc.setFont(7, 0);
		//pc.setVAlignment(0);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo.getColValue("secuencia"),0,1);
			pc.addCols(" "+cdo.getColValue("otro"),0,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);
			pc.addCols(" "+cdo.getColValue("entrada"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_inicial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_depre")),2,1);
			pc.addCols(" "+cdo.getColValue("final"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("actual")),2,1);
			 
			tot_inicial   += Double.parseDouble(cdo.getColValue("valor_inicial"));
		    tot_depre += Double.parseDouble(cdo.getColValue("monto_depre"));
		    tot_actual   += Double.parseDouble(cdo.getColValue("actual"));

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
		//CommonDataObject cdo1 = SQLMgr.getData(sqlT);

		pc.setFont(8, 1);

		pc.addCols(" Total . . . . . . . . . .",2,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(tot_inicial),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(tot_depre),2,1);
		pc.addCols(" ",0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(tot_actual),2,1);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>