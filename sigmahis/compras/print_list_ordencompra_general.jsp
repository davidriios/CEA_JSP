<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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
Reporte
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
String appendFilter = request.getParameter("appendFilter");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

String sql = "";
if (appendFilter == null) appendFilter = "";

sql = "SELECT a.anio, a.tipo_compromiso as tipo, a.num_doc, a.compania, to_char(fecha_documento,'dd/mm/yyyy') as fcomp, d.descripcion as nombre_compromiso, a.monto_total as total, nvl(a.numero_factura, ' ') numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence, nvl(a.monto_pagado,'0.00') as pagado, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','Z','CERRADA') as estado, '[ '||nvl(a.cod_proveedor, -1) || '] ' || nvl(b.nombre_proveedor, ' ') as nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion as almacen_desc, (a.monto_total - nvl(a.monto_pagado,'0.00')) as saldo, nvl(a.cod_proveedor,-1) as codigo,  a.anio||'-'||a.num_doc as numero,a.motivo,a.status from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and a.compania = c.compania and a.tipo_compromiso = d.tipo_com and a.compania = "+compania+ appendFilter+" order by a.cod_proveedor";

al = SQLMgr.getDataList(sql);

sbSql = new StringBuffer();
sbSql.append("select sum(total) total, count(distinct numero) cant_odc, sum((select sum(cantidad) from tbl_com_detalle_compromiso dc where dc.compania =  a.compania and dc.cf_anio = a.anio and dc.cf_num_doc = a.num_doc and dc.cf_tipo_com = a.tipo)) cant_articulos from (");
sbSql.append(sql);
sbSql.append(") a");
CommonDataObject cdoT = SQLMgr.getData(sbSql);
if(cdoT==null){
	cdoT = new CommonDataObject();
	cdoT.addColValue("total", "0");
	cdoT.addColValue("cant_odc", "0");
	cdoT.addColValue("cant_articulos", "0");
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "DEPARTAMENTO DE COMPRAS";
	String subtitle = "COMPROMISOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector setDetail = new Vector();		
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".20");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath,displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

		//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());

		pc.setFont(7, 1);
		pc.addBorderCols("Fecha/Comp",0);
		pc.addBorderCols("Compromiso",0);
		pc.addBorderCols("Tipo de Compromiso",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Tipo Pago ",1);
		pc.addBorderCols("Factura",1);
		pc.addBorderCols("Monto Total",2);
		pc.addBorderCols("Monto Pagado",2);
		pc.addBorderCols("Saldo",2);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);
    
	Double total=0.00,pagado=0.00,saldo=0.00;
	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo")))
		 {

			pc.setFont(7, 1,Color.blue);
			if (i==0)
			{
				pc.addBorderCols("Proveedor ....: "+cdo.getColValue("nombre_proveedor"), 0,setDetail.size(),cHeight);
			}
			else
			{
				pc.addCols("Total por Proveedor ....: ", 2,6,cHeight);
				pc.addCols(""+total,2,1);
				pc.addCols(""+pagado,2,1);
				pc.addCols(""+saldo,2,1);
				
				pc.flushTableBody(true);
				pc.addNewPage();
				
				pc.addBorderCols("Proveedor ....: "+cdo.getColValue("nombre_proveedor"), 0,setDetail.size(),cHeight);
				
				total =0.00;
				pagado =0.00;
				saldo =0.00;
				
			}
		}	 

			pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("fcomp"),0,1);

			pc.addCols(" "+cdo.getColValue("numero"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre_compromiso"),1,1);
			pc.addCols(" "+cdo.getColValue("estado"),1,1);
			pc.addCols(" "+cdo.getColValue("tipo_pago"),1,1);
			pc.addCols(" "+cdo.getColValue("numero_factura"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("pagado")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);
 			
			if(cdo.getColValue("status").trim().equals("Z"))
			{
				pc.setFont(9, 0,Color.red); 
				pc.addCols("Mot. Cierre:",0,1); 
				pc.addCols(cdo.getColValue("motivo"),0,8);
				 
 			}
			
			total += Double.parseDouble(cdo.getColValue("total"));
			pagado += Double.parseDouble(cdo.getColValue("pagado"));
			saldo += Double.parseDouble(cdo.getColValue("saldo"));
			groupBy = cdo.getColValue("codigo");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,setDetail.size());
	}
	else
	{		
			pc.setFont(7, 1,Color.blue);
			pc.addCols("Total por Proveedor ....: ", 2,6,cHeight);
			pc.addCols(""+total,2,1);
			pc.addCols(""+pagado,2,1);
			pc.addCols(""+saldo,2,1);
			
			pc.addCols("TOTAL DE O/C", 2, setDetail.size()-1);
			pc.addCols(cdoT.getColValue("cant_odc"), 2, 1);
			pc.addCols("TOTAL DE ARTICULOS EN O/C", 2, setDetail.size()-1);
			pc.addCols(cdoT.getColValue("cant_articulos"), 2, 1);
			pc.addCols("TOTAL EN MONTOS EN O/C", 2, setDetail.size()-1);
			pc.addCols(cdoT.getColValue("total"), 2, 1);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>