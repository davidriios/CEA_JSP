<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.awt.Color" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="htMed" scope="page" class="java.util.Hashtable" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
CXP40000c.rdf  Honorarios Medicos.
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
ArrayList al2 = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String sql = "",desc ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String codigo = request.getParameter("codigo");
String compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");
String usuario = (String) session.getAttribute("_userName");
String fechaDesde = request.getParameter("fechaDesde");
String fechaH = request.getParameter("fecha");
String tipoR = request.getParameter("tipoR");
String tipo = request.getParameter("tipo");
String cta_cancelada = request.getParameter("cta_cancelada");
if (fg == null) fg = "";
if(fechaDesde == null) fechaDesde = "";
if(fechaH == null) fechaH = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(codigo == null) codigo = "";
if(tipo == null) tipo = "";
if(cta_cancelada==null) cta_cancelada = "N";
System.out.println("cta_cancelada........................="+cta_cancelada);

sbSql.append("select all r.cod_medico as cod_medico, nvl(getNombreHon(r.cod_medico,r.tipo,'','HON'),r.nombre_medico) as nombre_medico,nvl(r.monto,0) monto, nvl(r.monto_ajuste,0)monto_ajuste, r.tipo, to_char(r.fecha, 'dd/mm/yyyy') fecha, r.codigo_paciente, r.fecha_nacimiento, r.factura, r.recibo, r.tipo_cliente, r.admision, r.codigo_empresa, e.nombre nombre_empresa, decode(r.ach, 'S', 'ACH', 'N', '') ach, nvl(r.retencion,0)retencion, getPaciente(r.monto_ajuste, r.fecha_nacimiento, r.codigo_paciente, r.tipo_cliente, r.factura, r.recibo, r.admision, r.compania) nombre_paciente, decode(r.tipo_cliente, 'O', to_char(r.fecha, 'dd/mm/yyyy'), getFechaIngreso(r.pac_id,r.admision, r.factura)) fecha_ingreso,nvl(getSaldoHon(r.compania, '");
	sbSql.append(fechaH);
	sbSql.append("', r.cod_medico,r.tipo),0) as saldoFinal,decode(r.saldo_ini,'S','SALDO INICIAL',nvl(r.boleta,  nvl(getBoletasHon(r.pac_id,r.admision,nvl(r.cod_real_med_bk,r.cod_medico)),null)))  boletas,nvl(r.pagar,'S') as pagar,decode(r.tipo,'H', (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = r.cod_medico ),r.cod_medico )as cod_view from tbl_cxp_hon_det r, tbl_adm_empresa e where r.codigo_empresa = e.codigo(+) and r.compania = ");
sbSql.append(compania);

	if(cta_cancelada.equals("S")/*||cta_cancelada.equals("N")*/){
		sbSql.append(" and (exists (select null from tbl_fac_factura f where f.compania = r.compania and f.codigo = r.factura AND NVL(fn_cja_saldo_fact(f.facturar_a, f.compania, f.codigo, f.grang_total), -1) ");
		if(cta_cancelada.equals("S"))sbSql.append(" = 0 ");
		else if(cta_cancelada.equals("N"))sbSql.append(" <> 0 ");
		sbSql.append(" )  or r.factura='S/I' ) ");
	}
if(!codigo.trim().equals("")){sbSql.append(" and r.cod_medico='");sbSql.append(codigo);sbSql.append("'");}
if(!tipo.trim().equals("")){sbSql.append(" and r.tipo='");sbSql.append(tipo);sbSql.append("'");}
if(!fechaH.trim().equals("")){sbSql.append(" and trunc(r.fecha) <= to_date('");sbSql.append(fechaH);sbSql.append("', 'dd/mm/yyyy')");}
if(!fechaDesde.trim().equals("")){sbSql.append(" and trunc(r.fecha) >= to_date('");sbSql.append(fechaDesde);sbSql.append("', 'dd/mm/yyyy')");}

 sbSql.append(" and decode(monto_ajuste, null, 0, codigo_paciente) = 0 and pagar='S' and exists (select cod_medico, nvl(sum(nvl(monto_ajuste,0)), 0) + nvl(sum(nvl(monto,0)), 0) /*- nvl(sum(nvl(retencion,0)), 0)*/ total from tbl_cxp_hon_det h where h.compania = ");
sbSql.append(compania);
sbSql.append(" and r.cod_medico = h.cod_medico and r.tipo = h.tipo and r.odp_numero is null and pagar='S' group by cod_medico having " );
if(tipoR.equals("PP"))sbSql.append(" nvl(sum(nvl(monto_ajuste,0)), 0) + nvl(sum(nvl(monto,0)), 0) /*- nvl(sum(nvl(retencion,0)), 0)*/ > 0");
else sbSql.append(" nvl(sum(nvl(monto_ajuste,0)), 0) + nvl(sum(nvl(monto,0)), 0) /*- nvl(sum(nvl(retencion,0)), 0)*/ <= 0");
sbSql.append(" ) order by r.nombre_medico asc,r.recibo asc,r.fecha desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")){
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CUENTAS POR PAGAR";
	String subtitle = "HONORARIOS MEDICOS POR PAGAR";
	String xtraSubtitle = "DESDE "+fechaDesde+"  HASTA  "+fechaH;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".30");
		dHeader.addElement(".06");
		dHeader.addElement(".10");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".17");
		dHeader.addElement(".05");
		dHeader.addElement(".07");
		dHeader.addElement(".07");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Paciente",1);
		pc.addBorderCols("F. Dist",1);
		pc.addBorderCols("Boletas",1);
		pc.addBorderCols("F. Adm",1);
		pc.addBorderCols("Factura",1,1);
		pc.addBorderCols("Recibo",1);
		pc.addBorderCols("Cia. Seguro",1);
		pc.addBorderCols("Retencion",1);
		pc.addBorderCols("Ajuste",1);
		pc.addBorderCols("Monto",1);

	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	int contratos =0,contratosTotal =0;
	double totalRetencion =0.00,totalAjuste =0.00,totalMonto =0.00,total =0.00,granTotal=0.00,totalActual=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_medico")))
		{
			if(i!=0)
			{ 
				pc.addCols("Totales: ", 2,7);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalRetencion), 2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalAjuste), 2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalMonto), 2,1,0.0f,0.1f,0.0f,0.0f);
				pc.setFont(groupFontSize, 1,Color.blue);
				pc.addCols("Total por Medico: ", 2,9);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(total), 2,1,0.0f,0.0f,0.0f,0.0f);
				totalRetencion =0.00;
				totalAjuste =0.00;
				totalMonto =0.00;
				total =0.00;
				pc.addCols("Saldo Actual  por Medico: ", 2,9);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalActual), 2,1,0.0f,0.0f,0.0f,0.0f);
				pc.addCols(" ",1,dHeader.size());
			}
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_medico")))
		{
		pc.setFont(groupFontSize, 1,Color.blue);
		/*
		if(cdo.getColValue("nombre_cargo").equals("") || cdo.getColValue("nombre_cargo").equals(cdo.getColValue("nombre_medico"))) 
			pc.addBorderCols("Medico: "+cdo.getColValue("cod_medico")+" "+cdo.getColValue("nombre_medico"), 0,5,0.0f,0.1f,0.0f,0.0f);
		else if(!cdo.getColValue("nombre_cargo").equals("") || !cdo.getColValue("nombre_cargo").equals(cdo.getColValue("nombre_medico"))) {
			pc.addBorderCols("Medico: "+cdo.getColValue("cod_medico")+" "+cdo.getColValue("nombre_medico"), 0,2,0.0f,0.1f,0.0f,0.0f);
			pc.setFont(groupFontSize, 1,Color.red);
			pc.addBorderCols("Medico Cargo: [ "+cdo.getColValue("cod_real_med")+" "+cdo.getColValue("nombre_cargo") + " ]", 0,3,0.0f,0.1f,0.0f,0.0f);
		}
		*/
		pc.addBorderCols("Medico: "+cdo.getColValue("cod_view")+" "+cdo.getColValue("nombre_medico"), 0,5,0.0f,0.1f,0.0f,0.0f);
		pc.setFont(groupFontSize, 1,Color.red);
		pc.addBorderCols(cdo.getColValue("ach"), 0,5,0.0f,0.1f,0.0f,0.0f);
		}

		pc.setFont(contentFontSize, 0);

		pc.addCols(""+cdo.getColValue("nombre_paciente"),0,1);
		pc.addCols(""+cdo.getColValue("fecha"), 1,1);
		pc.addCols(""+cdo.getColValue("boletas"), 1,1);
		pc.addCols(""+cdo.getColValue("fecha_ingreso"), 1,1);
		pc.addCols(""+cdo.getColValue("factura"), 1,1);
		pc.addCols(""+cdo.getColValue("recibo"), 1,1);
		pc.addCols(""+cdo.getColValue("nombre_empresa"), 0,1);
		pc.addCols(""+(cdo.getColValue("retencion")!=null && !cdo.getColValue("retencion").equals("")?CmnMgr.getFormattedDecimal(cdo.getColValue("retencion")):""), 2,1);
		pc.addCols(""+(cdo.getColValue("monto_ajuste")!=null && !cdo.getColValue("monto_ajuste").equals("")?CmnMgr.getFormattedDecimal(cdo.getColValue("monto_ajuste")):""), 2,1);
		pc.addCols(""+(cdo.getColValue("monto")!=null && !cdo.getColValue("monto").equals("")?CmnMgr.getFormattedDecimal(cdo.getColValue("monto")):""), 2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy  = cdo.getColValue("cod_medico");
		totalActual = Double.parseDouble(cdo.getColValue("saldoFinal"));
		totalRetencion += Double.parseDouble(cdo.getColValue("retencion"));
		totalAjuste += Double.parseDouble(cdo.getColValue("monto_ajuste"));
		totalMonto += Double.parseDouble(cdo.getColValue("monto"));
		total += (Double.parseDouble(cdo.getColValue("monto_ajuste"))+Double.parseDouble(cdo.getColValue("monto"))) - Double.parseDouble(cdo.getColValue("retencion"));
		granTotal += (Double.parseDouble(cdo.getColValue("monto_ajuste"))+Double.parseDouble(cdo.getColValue("monto"))) - Double.parseDouble(cdo.getColValue("retencion"));
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.addCols("Totales: ", 2,7);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalRetencion), 2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalAjuste), 2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalMonto), 2,1,0.0f,0.1f,0.0f,0.0f);
		pc.setFont(groupFontSize, 1,Color.blue);
		pc.addCols("Total por Medico: ", 2,9);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(total), 2,1,0.0f,0.0f,0.0f,0.0f);
		
		pc.addCols("Saldo Actual  por Medico: ", 2,9);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalActual), 2,1,0.0f,0.0f,0.0f,0.0f);
		pc.addCols(" ",1,dHeader.size());		
		pc.addCols("Total de Honorarios a pagar:", 2,9);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(granTotal), 2,1);
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>