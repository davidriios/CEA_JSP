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

/*===============================================================================
fg = t=obtener datos de tbl_con_temporal_depreciacion
		 d=obtener datos de tbl_con_deprec_mensual
================================================================================*/

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDet = new ArrayList();
String sql = "";
String sqlT = "";
String sqlU = "";
String anio = request.getParameter("anio");
String mes  = request.getParameter("mes");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");

if(fg == null) fg ="t";   // temporal

if (appendFilter == null) appendFilter = "";


CommonDataObject cdUD = SQLMgr.getData("select (to_char(last_day(to_date('01/'||to_char("+mes+", '09')||'/'||'"+anio+"', 'DD/MM/YYYY')), 'DD')) ||' de '|| to_char(to_date(to_char("+mes+",'09'),'MM'),'MONTH', 'NLS_DATE_LANGUAGE=SPANISH') ||' de '|| to_char("+anio+") ud from dual");
String dia = (cdUD.getColValue("ud"));


if (fg.trim().equals("t"))
	{
		sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1,nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2,nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4,nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6,a.ue_codigo, u.DESCRIPCION, sum(d.monto_depre) totales, d.cod_ano, d.cod_mes from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" group by a.gasto1,a.gasto2,a.gasto3,a.gasto4,a.gasto5,a.gasto6,  a.compania,a.ue_codigo,a.cod_flia,u.descripcion,d.cod_ano,d.cod_mes order by u.descripcion ";
		al = SQLMgr.getDataList(sql);

		sql= "select e.cta1_depre_acum,e.cta2_depre_acum, e.cta3_depre_acum, e.cta4_depre_acum, e.cta5_depre_acum,e.cta6_depre_acum, e.descripcion desc_acum, e.cta_control||e.codigo_espec codes, sum(nvl(d.monto_depre,0)) tot_acum, sum(nvl(d.depre_acum_act,0)) tot_depre_acum, d.cod_ano, d.cod_mes from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e where a.secuencia = d.activo_sec and a.compania = d.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" group by e.cta1_depre_acum, e.cta2_depre_acum, e.cta3_depre_acum, e.cta4_depre_acum, e.cta5_depre_acum, e.cta6_depre_acum, e.descripcion, e.cta_control||e.codigo_espec, d.cod_ano, d.cod_mes";
		alDet = SQLMgr.getDataList(sql);

	} else {

		sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1, nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2, nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4, nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6, a.ue_codigo, u.DESCRIPCION, sum(d.monto_depre) totales, d.cd_ano  cod_ano, d.cd_mes  cod_mes from tbl_con_deprec_mensual d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cd_ano = "+anio+" and d.cd_mes = "+mes+" group by a.gasto1,a.gasto2,a.gasto3,a.gasto4,a.gasto5,a.gasto6,  a.compania,a.ue_codigo,a.cod_flia, u.DESCRIPCION, d.cd_ano, d.cd_mes   order by u.descripcion";
		al = SQLMgr.getDataList(sql);

		sql= "select e.cta1_depre_acum,e.cta2_depre_acum, e.cta3_depre_acum, e.cta4_depre_acum, e.cta5_depre_acum,e.cta6_depre_acum, e.descripcion desc_acum, e.cta_control||e.codigo_espec codes, sum(nvl(d.monto_depre,0)) tot_acum, sum(nvl(d.depre_acum_act,0)) tot_depre_acum, d.cd_ano cod_ano, d.cd_mes cod_mes from tbl_con_deprec_mensual d, tbl_con_activos a, tbl_con_especificacion e where a.secuencia = d.activo_sec and a.compania = d.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cd_ano = "+anio+" and d.cd_mes = "+mes+" group by e.cta1_depre_acum, e.cta2_depre_acum, e.cta3_depre_acum, e.cta4_depre_acum, e.cta5_depre_acum, e.cta6_depre_acum, e.descripcion, e.cta_control||e.codigo_espec, d.cd_ano, d.cd_mes";
		alDet = SQLMgr.getDataList(sql);

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
	String subtitle = "RESUMEN DE ACTIVO FIJO POR DEPARTAMENTO Y DEPRECIACION ACUMULADA";
	String xtraSubtitle = "Depreciación hasta el : " +cdUD.getColValue("ud");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dDetalle = new Vector();
		dDetalle.addElement(".32");
		dDetalle.addElement(".04");
		dDetalle.addElement(".04");
		dDetalle.addElement(".04");
		dDetalle.addElement(".04");
		dDetalle.addElement(".04");
		dDetalle.addElement(".04");
		dDetalle.addElement(".15");
		dDetalle.addElement(".14");
		dDetalle.addElement(".15");

 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(8, 1);
		pc.addCols("DEPARTAMENTO",0,1);
		pc.addCols("CUENTA GASTO DE DEPRECIACION ",1,6);
		pc.addCols(" ",1,1);
		pc.addCols("DEPRECIACION ",2,1);
		pc.addCols(" ",1,1);
		pc.setTableHeader(2);
		
	   int no = 0;
	   double totales =0.00,tot_depre_acum =0.00,tot_acum =0.00;
  
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(8, 0);
		pc.setVAlignment(0);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("cta1"),2,1);
			pc.addCols(" "+cdo.getColValue("cta2"),2,1);
			pc.addCols(" "+cdo.getColValue("cta3"),2,1);
			pc.addCols(" "+cdo.getColValue("cta4"),2,1);
			pc.addCols(" "+cdo.getColValue("cta5"),2,1);
			pc.addCols(" "+cdo.getColValue("cta6"),2,1);
			pc.addCols(" ",1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("totales")),2,1);
	        pc.addCols(" ",1,1);
			
			totales += Double.parseDouble(cdo.getColValue("totales"));

			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
		pc.setFont(8,1);
		pc.addCols(" TOTALES . . . . . "+CmnMgr.getFormattedDecimal(totales),2,7);
		pc.addCols(" ",0,3);
		
		pc.addCols(" ",1,10);

		pc.addCols("NOMBRE DE LA CUENTA",0,1);
		pc.addCols("CUENTA DEPRECIACION ACUMULADA",1,6);
		pc.addCols("MONTO MENSUAL    ",2,1);
		pc.addCols("DEPRECIACION ACUMULADA",2,1);
		pc.addCols(" ",1,1);

		for (int j=0 ; j<alDet.size(); j++)
		{
		 pc.setFont(8,0);
		 CommonDataObject cdo2 = (CommonDataObject) alDet.get(j);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo2.getColValue("desc_acum"),0,1);
			pc.addCols(" "+cdo2.getColValue("cta1_depre_acum"),2,1);
			pc.addCols(" "+cdo2.getColValue("cta2_depre_acum"),2,1);
			pc.addCols(" "+cdo2.getColValue("cta3_depre_acum"),2,1);
			pc.addCols(" "+cdo2.getColValue("cta4_depre_acum"),2,1);
			pc.addCols(" "+cdo2.getColValue("cta5_depre_acum"),2,1);
			pc.addCols(" "+cdo2.getColValue("cta5_depre_acum"),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("tot_acum")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("tot_depre_acum")),2,1);
		    pc.addCols(" ",1,1);
			
			tot_acum += Double.parseDouble(cdo2.getColValue("tot_acum"));
			tot_depre_acum += Double.parseDouble(cdo2.getColValue("tot_depre_acum"));

			if ((j % 50 == 0) || ((j + 1) == alDet.size())) pc.flushTableBody(true);
		}
		if (alDet.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
		pc.setFont(8,1);
		pc.addCols(" TOTALES . . . . . ",2,7);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(tot_acum),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(tot_depre_acum),2,1);
		pc.addCols(" ",0,1);

		}
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>