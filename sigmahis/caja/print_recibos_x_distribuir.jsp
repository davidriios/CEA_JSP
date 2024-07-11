<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
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
==================================================================================
Reporte cja71004.rdf
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

String sql = "";
StringBuffer sbSql = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
      String caja = request.getParameter("caja");
      String turno = request.getParameter("turno");
      String compania = request.getParameter("compania");
      String fecha_ini = request.getParameter("fechaini");
      String fecha_fin = request.getParameter("fechafin");
      String descCaja = request.getParameter("descCaja");
	  String tipoCliente = request.getParameter("tipoCliente"); 

if (appendFilter == null) appendFilter = "";
if(turno==null) turno = "";
if(caja==null) caja = "";
if(tipoCliente == null) tipoCliente = ""; 
if(compania==null) compania = (String) session.getAttribute("_companyId");


sbSql.append("select xx.*,xx.pago_total -nvl(xx.aplicado,0)+ nvl(xx.ajustado,0)porAplicar, nvl(xx.aplicado,0)-nvl(xx.distribuido,0) as pendiente from ( select x.codigo, a.pago_total, a.caja,cja.descripcion as desccaja, a.descripcion , to_char(a.fecha,'dd/mm/yyyy')as fecha,(select nvl(sum(b.monto),0) aplicado from tbl_cja_detalle_pago b where b.compania=a.compania and b.tran_anio=a.anio and b.codigo_transaccion=a.codigo) aplicado,(select nvl(sum(d.monto),0)distr from tbl_cja_detalle_pago b,tbl_cja_distribuir_pago d where b.compania=a.compania and b.tran_anio=a.anio and b.codigo_transaccion=a.codigo and b.codigo_transaccion = d.codigo_transaccion and b.tran_anio = d.tran_anio and b.secuencia_pago = d.secuencia_pago and b.compania = d.compania ) distribuido,(select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')) as ajustado from tbl_cja_transaccion_pago a, tbl_cja_recibos x,tbl_cja_cajas cja  where  a.compania= ");
sbSql.append(compania);

if(!caja.trim().equals(""))
{
	sbSql.append(" and a.caja = ");
	sbSql.append(caja);
}
if(!tipoCliente.trim().equals("")){
sbSql.append(" and a.tipo_cliente = '");
sbSql.append(tipoCliente);
sbSql.append("' ");}
if(!fecha_ini.trim().equals("")){
sbSql.append(" and trunc(a.fecha) >=to_date('");  
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy') ");
 }
 if(!fecha_fin.trim().equals("")){
sbSql.append(" and trunc(a.fecha) <=to_date('");
sbSql.append(fecha_fin);
sbSql.append("','dd/mm/yyyy') ");
 }
sbSql.append("  and a.caja=cja.codigo(+) and cja.compania=a.compania and a.tipo_cliente in ('P','E') and a.rec_status <> 'I' and a.codigo = x.ctp_codigo and a.anio = x.ctp_anio and a.compania = x.compania	) xx where xx.pago_total >= nvl(xx.aplicado,0) and nvl(xx.aplicado,0)-nvl(xx.distribuido,0)+ nvl(xx.ajustado,0)  > 0 order by xx.caja asc,xx.fecha,xx.codigo");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String time = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";

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
	String title = "RECIBOS PENDIENTE POR DISTRIBUIR";
	String subtitle = "TIPOS DE CLIENTES: PACIENTES Y EMPRESAS";
	String xtraSubtitle = "Desde:   "+fecha_ini + " Hasta: "+fecha_fin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 7;
	int groupSize =8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


		  Vector dHeader=new Vector();
          	dHeader.addElement(".08");
			dHeader.addElement(".10");
			dHeader.addElement(".25");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".09");


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);
		pc.addBorderCols("Fecha",0);
		pc.addBorderCols("Codigo",1);
		pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Pago total",1);		
		pc.addBorderCols("Ajustes",2,1);
		pc.addBorderCols("Por Aplicar",2,1);		
		pc.addBorderCols("Aplicado",1);
		pc.addBorderCols("Distribuido",1);
		pc.addBorderCols("Pendiente",1);
		pc.setTableHeader(2);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto_fact =0.0, monto_total = 0.00,sub_total=0.00,pendiente = 0.00;
	int recibo =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		//CommonDataObject cdo = (CommonDataObject) al.get(x);

			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")) && i !=0)
			{
				pc.setFont(groupSize, 1,Color.blue);
				pc.addCols("Sub-Total por Caja . . .",2,7);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(sub_total),2,2);
				pc.addCols("Total de Recibos pendiente por Caja . . .",2,3);
				pc.addCols(""+recibo,0,6);
				sub_total=0.00;
				recibo=0;
				pc.addCols(" ",0,dHeader.size());
			}

			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")))
			{
				pc.setFont(groupSize, 1,Color.blue);
				pc.addBorderCols("CAJA:   ["+cdo.getColValue("caja")+"]   "+cdo.getColValue("descCaja"),0,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
			}

			pc.setFont(fontSize, 0);

			pendiente = Double.parseDouble(cdo.getColValue("pendiente"));


			pc.addCols(" "+cdo.getColValue("fecha"), 0,1);
			pc.addCols(" "+cdo.getColValue("codigo"), 1,1);
			pc.addCols(" "+cdo.getColValue("descripcion"), 0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ajustado")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("porAplicar")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("aplicado")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("distribuido")), 2,1);
			//pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ajustesdb")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(pendiente), 2,1);

			monto_total += pendiente ;
			sub_total   += pendiente;
			recibo ++;


		   if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("caja");
	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
			pc.setFont(groupSize, 1,Color.blue);

			pc.setFont(groupSize, 1,Color.blue);
			pc.addCols("Sub-Total por Caja . . .",2,7);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(sub_total),2,2);
			pc.addCols("Total de Recibos pendiente por Caja . . .",2,3);
			pc.addCols(""+recibo,0,6);

			pc.addCols("Total de Recibos por Reporte . . .",2,3);
			pc.addCols(""+al.size(),0,1);
			pc.addCols("Gran Total por Reporte . . .",2,3);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(monto_total),2,2);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>