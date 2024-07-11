<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>

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
ArrayList alTS = new ArrayList();
ArrayList alDev = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String sql = "",desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String fg = request.getParameter("fg");
String tipo_aju = request.getParameter("tipo_aju");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (codigo==null) codigo = "";

sbSql.append("select a.id, a.compania, a.anio, a.mes, a.tipo_aju, a.tipo_ben, a.id_solicitud, a.id_referencia, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_aprobacion, 'dd/mm/yyyy') fecha_aprobacion, a.usuario_aprobacion, a.estado, a.observacion, (case when a.tipo_ben = 1 then (select v.nombre_paciente from vw_pm_cliente v where to_char(v.codigo) = a.id_referencia) else ''  end) referencia_desc, decode(a.tipo_ben, 1, 'CxC Afiliado', 2, 'CxP Medico', 3, 'CxP Empresa Reclamos') tipo_ben_desc, decode(a.tipo_aju, 1, 'Descuento a Factura', 2, 'Anular Pago', 3, 'Nota de Credito', 4, 'Nota de Credito CxP') tipo_aju_desc, (select sum(nvl(monto, 0)) from tbl_pm_ajuste_det d where a.compania = d.compania and a.id = d.id) monto, decode(a.estado, 'A', 'APROBADO', 'P', 'PENDIENTE', 'I', 'INACTIVO') estado_desc from tbl_pm_ajuste a where compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and a.id = ");
sbSql.append(codigo);
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
sbSql = new StringBuffer();
sbSql.append("select a.tipo_trx, a.id, a.compania, a.secuencia, a.estado, a.id_ref, a.anio, a.mes, a.monto, nvl(a.debito, 0) debito, nvl(a.credito, 0) credito, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, (case when b.tipo_aju in (1, 3) then b.id_solicitud||'_'||a.anio||'_'||a.mes when b.tipo_aju = 2 then b.id_solicitud||'_'||a.tipo_trx||'_'||a.id_ref else '' end) key, to_char(to_date(a.mes, 'mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes_desc, a.descripcion, decode(a.tipo_trx, 'M', 'PAGO MANUAL', 'ACH', 'ACH', 'TC','TARJETA DE CREDITO', tipo_trx) tipo_trx_desc from tbl_pm_ajuste_det a, tbl_pm_ajuste b where a.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and a.compania = b.compania and a.id = b.id");
sbSql.append(" and a.id = ");
sbSql.append(codigo);
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	boolean isLandscape = false;
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
	String title = "PLAN MEDICO";
	String subtitle = "AJUSTE "+cdo.getColValue("tipo_aju_desc");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".25");
		dHeader.addElement(".15");
		dHeader.addElement(".15");

	Vector vContent = new Vector();
		if(fg.equals("cxc") && (tipo_aju.equals("1") || tipo_aju.equals("3"))){
			vContent.addElement(".10");
			vContent.addElement(".15");
			vContent.addElement(".15");
		} else if(fg.equals("cxc") && tipo_aju.equals("2")){
			vContent.addElement(".20");
			vContent.addElement(".20");
		} else {
			vContent.addElement(".40");
		}	
		vContent.addElement(".40");
		vContent.addElement(".10");
		vContent.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	//Encabezado
			pc.setFont(8, 0);
			pc.addCols("Fecha:", 0,1);
			pc.addCols(""+cdo.getColValue("fecha_creacion"), 0,1);
			pc.addCols("No. de Ajuste :", 0,1);
			pc.addCols(""+cdo.getColValue("id"), 0,1);
			pc.addCols("Contrato :", 0,1);
			pc.addCols(""+cdo.getColValue("id_solicitud"), 0,1);

			pc.addCols("Tipo :", 0,1);
			pc.addCols(""+cdo.getColValue("tipo_ben_desc"), 0,1);
			pc.addCols("Tipo Ajuste :", 0,1);
			pc.addCols(""+cdo.getColValue("tipo_aju_desc"), 0,1);
			pc.addCols("Total :", 0,1);
			pc.setFont(8, 1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")), 0,2);

			pc.setFont(8, 0);
			pc.addCols("Referencia :", 0,1);
			pc.setFont(8, 1);
			pc.addCols(""+cdo.getColValue("referencia_desc"), 0,2);
			pc.addCols("Estado :"+cdo.getColValue("estado_desc"), 0,3);
			
			pc.setFont(8, 0);
			pc.addCols("Observacion : "+cdo.getColValue("observacion"), 0,dHeader.size());
	
			pc.setTableHeader(4);//create de table header
			
			pc.setNoColumnFixWidth(vContent);
			pc.createTable("det");

			if(fg.equals("cxc") && (tipo_aju.equals("1") || tipo_aju.equals("3"))){
				pc.addBorderCols("AÑO",1,1);
				pc.addBorderCols("MES",1,1);
				pc.addBorderCols("NO. FACT.",1,1);				
			} else if(fg.equals("cxc") && tipo_aju.equals("2")){
				pc.addBorderCols("NO. TRX",1,1);
				pc.addBorderCols("TIPO TRX",1,1);
			} else {
				pc.addBorderCols("RECLAMO",1,1);
			}
			pc.addBorderCols("DESCRIPCION",1);
			pc.addBorderCols("DEBITO",1);
			pc.addBorderCols("CREDITO",1);




	//table body
	String groupBy = "";
	String groupTitle = "";
	double totalDb = 0.00,totalCr = 0.00;
	double res = 0.00;

	String descripcion = "";
	String v_codigo = "";
	String v_monto = "";
	String v_descripcion = "";
	String v_factura = "";
	String usuario_creacion=cdo.getColValue("usuario_creacion"), usuario_aprob=cdo.getColValue("usuario_aprobacion"), fecha_creacion=cdo.getColValue("fecha_creacion"), fecha_aprob=cdo.getColValue("fecha_aprobacion");



		
			for (int i=0; i<al.size(); i++){
				CommonDataObject cd = (CommonDataObject) al.get(i);
	
				if(fg.equals("cxc") && (tipo_aju.equals("1") || tipo_aju.equals("3"))){
					pc.addCols(""+cd.getColValue("anio"), 1,1);
					pc.addCols(""+cd.getColValue("mes_desc"), 1,1);
					pc.addCols(""+cd.getColValue("id_ref"), 1,1);
				} else if(fg.equals("cxc") && tipo_aju.equals("2")){
					pc.addCols(""+cd.getColValue("id_ref"), 1,1);
					pc.addCols(""+cd.getColValue("tipo_trx_desc"), 1,1);
				} else {
					pc.addCols("", 1,1);
				}

				pc.addCols(""+cd.getColValue("descripcion"), 0,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cd.getColValue("debito")), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cd.getColValue("credito")), 2,1);
				totalDb += Double.parseDouble(cd.getColValue("debito"));
				totalCr += Double.parseDouble(cd.getColValue("credito"));
			}





	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{

				int colspan = 1;
				if(fg.equals("cxc") && (tipo_aju.equals("1") || tipo_aju.equals("3"))){
					colspan=4;
				} else if(fg.equals("cxc") && tipo_aju.equals("2")){
					colspan=3;
				} else {
					colspan=2;
				}
			pc.setFont(8, 1);
			pc.addCols("TOTAL", 2,colspan);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalDb), 2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCr), 2,1,0.0f,0.5f,0.0f,0.0f);

			pc.addCols("",0,vContent.size());
			pc.addCols("",0,vContent.size());

			pc.setFont(8, 0);
			pc.addCols("Registrado por: "+usuario_creacion,0,vContent.size());
			pc.addCols("Fecha Registro:"+fecha_creacion,0,vContent.size());

			pc.addCols("Aprobado por: "+usuario_aprob,0,vContent.size());
			pc.addCols("Fecha de aprobación: "+fecha_aprob,0,vContent.size());

			
      pc.useTable("main");
      pc.addTableToCols("det",0,dHeader.size());
			
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>