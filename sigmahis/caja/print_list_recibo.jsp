<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
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
StringBuffer sbSql = new StringBuffer();
String tipoCliente = request.getParameter("tipoCliente");
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("hh12mmssam");
String sPorAplicar = request.getParameter("por_aplicar")==null?"":request.getParameter("por_aplicar");
String fechaDesde = request.getParameter("fechaDesde")==null?"":request.getParameter("fechaDesde");
String fechaHasta = request.getParameter("fechaHasta")==null?"":request.getParameter("fechaHasta");

if (tipoCliente == null) throw new Exception("El Tipo de Recibo no es válido. Por favor intente nuevamente!");
else if (tipoCliente.equalsIgnoreCase("P")||tipoCliente.equalsIgnoreCase("F")) tipoCliente = " - PACIENTE";
else if (tipoCliente.equalsIgnoreCase("E")) tipoCliente = " - EMPRESA";
else if (tipoCliente.equalsIgnoreCase("O")) tipoCliente = " - OTROS";
else if (tipoCliente.equalsIgnoreCase("A")) tipoCliente = " - ALQUILER";
if (appendFilter == null) appendFilter = "";
if (fp == null) fp = "";

		if (!sPorAplicar.trim().equals("")){
		   sbSql.append("select aaa.* from ( ");
		}
		sbSql.append("select a.compania, a.codigo, a.recibo, a.anio, a.caja, decode(a.tipo_cliente,'O',decode(a.cliente_alq,'S','A',a.tipo_cliente),tipo_cliente)tipo_cliente, a.codigo_paciente, a.pago_total, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.descripcion, a.rec_impreso, a.rec_status, decode(a.rec_status,'A','ACTIVO','I','ANULADO',a.rec_status) as estado, a.nombre, a.nombre_adicional");
		sbSql.append(", (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo) as aplicado");
		sbSql.append(", (select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')) as ajustado,nvl(a.tipo_rec,'M')tipoRec, a.ref_TYPE, a.sub_ref_id");
		sbSql.append(" from tbl_cja_transaccion_pago a");
		sbSql.append(" where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(appendFilter);
		sbSql.append(" order by a.anio desc, a.codigo desc");
		
		if (!sPorAplicar.trim().equals("")){
		   sbSql.append(")aaa where (aaa.pago_total - aaa.aplicado + aaa.ajustado) > 0");
		}


/*
sbSql.append("select a.compania, a.codigo, a.recibo, a.anio, a.caja, decode(a.tipo_cliente,'O',decode(a.cliente_alq,'S','A',a.tipo_cliente),tipo_cliente)tipo_cliente, a.codigo_paciente, a.pago_total, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.descripcion,'N' rec_impreso, nvl(a.anulada,'N') rec_status,
decode(a.rec_status,'A','ACTIVO','I','ANULADO',a.rec_status) as estado,decode(a.nombre,null,decode(a.tipo_cliente,'P',p.nombre_paciente,'E',e.nombre,'S/N'),a.nombre) nombre, a.nombre_adicional");
		sbSql.append(", (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo) as aplicado");
		sbSql.append(", (select nvl(sum(decode(z.lado_mov,'D',-z.monto,'C',decode(z.referencia,99,0,z.monto))),0) from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')) as ajustado");
		sbSql.append(" from tbl_cja_transaccion_pago a,vw_adm_paciente p,tbl_adm_empresa e");
		sbSql.append(" where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(appendFilter);
		sbSql.append(" and a.pac_id=p.pac_id(+) and a.codigo_empresa = e.codigo(+) order by a.anio desc, a.codigo desc");*/
		
al = SQLMgr.getDataList(sbSql.toString());
ArrayList alT = new ArrayList();
StringBuffer sbSqlT = new StringBuffer();
sbSqlT.append("select compania, ref_TYPE, sub_ref_id, NVL((select descripcion from tbl_fac_tipo_cliente tc where compania = a.compania and tc.codigo = a.ref_TYPE), 'N/A') tipo_cliente, nvl((select descripcion from tbl_cxc_tipo_otro_cliente where compania = a.compania and id = a.sub_ref_id), 'N/A') sub_tipo_cliente, sum(a.pago_total) pago_total, sum(a.aplicado) aplicado, sum(a.ajustado) ajustado from (");
sbSqlT.append(sbSql.toString());
sbSqlT.append(") a group by compania, ref_TYPE, sub_ref_id order by 4");
alT = SQLMgr.getDataList(sbSqlT.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+time+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String title = "CAJA";
	String subtitle = "RECIBOS"+tipoCliente;
	String xtraSubtitle = "";
	if(!fechaDesde.trim().equals("")&&!fechaHasta.trim().equals(""))xtraSubtitle =" DESDE "+fechaDesde+" HASTA "+fechaHasta;
	else if(!fechaDesde.trim().equals("")&&fechaHasta.trim().equals(""))xtraSubtitle =" DEL "+fechaDesde;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".13");
		dHeader.addElement(".05");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".17");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

		Vector dRes = new Vector();
		dRes.addElement(".30");
		dRes.addElement(".30");
		dRes.addElement(".10");
		dRes.addElement(".10");
		dRes.addElement(".10");
		dRes.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(fontSize,1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Recibo",1);
		pc.addBorderCols("Caja",1);
		pc.addBorderCols("Cliente",1);
		pc.addBorderCols("Nombre Adicional",1);
		pc.addBorderCols("Concepto",1);
		pc.addBorderCols("Pago",1);
		pc.addBorderCols("Aplicado",1);
		pc.addBorderCols("Ajustado",1);
		pc.addBorderCols("Por Aplicar",1);
		pc.addBorderCols("Estado",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	double totalPag = 0.0;
	double aplicadoPag = 0.0;
	double ajustadoPag = 0.0;
	double porAplicarPag = 0.0;

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

	double total = Double.parseDouble(cdo.getColValue("pago_total"));
	double aplicado = (cdo.getColValue("aplicado") != null)?Double.parseDouble(cdo.getColValue("aplicado")):0.0;
	double ajustado = (cdo.getColValue("ajustado") != null)?Double.parseDouble(cdo.getColValue("ajustado")):0.0;
	double porAplicar = Math.round((total - aplicado + ajustado) * 100);
	
	  totalPag  += total;
	  aplicadoPag += aplicado;
	  ajustadoPag += ajustado;
	  porAplicarPag += porAplicar;

		
		pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols((fp.equalsIgnoreCase("ARC")?cdo.getColValue("tipo_cliente")+"-":"")+cdo.getColValue("recibo"),1,1);
		pc.addCols(cdo.getColValue("caja"),1,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(cdo.getColValue("nombre_adicional"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(aplicado),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(ajustado),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(porAplicar / 100),2,1);
		pc.addCols(cdo.getColValue("estado"),1,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else { 		
		pc.setFont(fontSize,0,Color.blue);
		pc.addCols("  T O T A L :",2,6);
		pc.addCols(CmnMgr.getFormattedDecimal(totalPag),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(aplicadoPag),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(ajustadoPag),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(porAplicarPag / 100),2,1);
		pc.addCols(" ",2,1);
		totalPag = 0.00; aplicadoPag = 0.00; ajustadoPag = 0.00; porAplicarPag = 0.00;
		pc.addTable();
		pc.setNoColumnFixWidth(dRes);
		pc.createTable();

		pc.setFont(fontSize,1);
		pc.addBorderCols("TIPO CLIENTE",1);
		pc.addBorderCols("SUB TIPO CLIENTE",1);
		pc.addBorderCols("PAGADO",1);
		pc.addBorderCols("APLICADO",1);
		pc.addBorderCols("AJUSTADO",1);
		pc.addBorderCols("POR APLICAR",1);

		for (int i=0; i<alT.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) alT.get(i);
			double total = Double.parseDouble(cdo.getColValue("pago_total"));
			double aplicado = (cdo.getColValue("aplicado") != null)?Double.parseDouble(cdo.getColValue("aplicado")):0.0;
			double ajustado = (cdo.getColValue("ajustado") != null)?Double.parseDouble(cdo.getColValue("ajustado")):0.0;
			double porAplicar = Math.round((total - aplicado + ajustado) * 100);

			pc.setFont(fontSize-1,0);
			pc.setVAlignment(0);
			pc.addCols(cdo.getColValue("tipo_cliente"),0,1);
			pc.addCols(cdo.getColValue("sub_tipo_cliente"),0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(aplicado),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(ajustado),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(porAplicar / 100),2,1);
	
			totalPag  += total;
			aplicadoPag += aplicado;
			ajustadoPag += ajustado;
			porAplicarPag += porAplicar;			
		}
			pc.setFont(fontSize,0,Color.blue);
			pc.addCols("  T O T A L :",2,2);
			pc.addCols(CmnMgr.getFormattedDecimal(totalPag),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(aplicadoPag),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(ajustadoPag),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(porAplicarPag / 100),2,1);
		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>