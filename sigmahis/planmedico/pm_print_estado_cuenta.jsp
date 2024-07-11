<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.CommonDataObject"%>
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

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String clientId = (request.getParameter("clientId")== null?"":request.getParameter("clientId"));
String fechaIni = request.getParameter("fechaIni") == null?"":request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin") == null?"":request.getParameter("fechaFin");
String estadoFact = request.getParameter("estadoFact") == null?"":request.getParameter("estadoFact");
String clientName = request.getParameter("clientName") == null?"":request.getParameter("clientName");
String compId=(String) session.getAttribute("_companyId");

StringBuffer sbSql = new StringBuffer();

	sbSql.append("select 'FAC' doc, d_fac.fac_codigo fac_cod, d_fac.descripcion fac_desc, to_char(fac.fecha,'dd/mm/yyyy') fecha_dsp, trunc(fac.fecha) fecha, d_fac.monto fac_monto, 0 pago_total, null cod_pago from tbl_fac_factura fac, tbl_fac_detalle_factura d_fac where fac.codigo = d_fac.fac_codigo and fac.compania = d_fac.compania and fac.facturar_a = 'O' and fac.facturado_por = 'PLAN_MEDICO' and fac.estatus <> 'A' and fac.cod_otro_cliente = '");
	sbSql.append(clientId);
	sbSql.append("' and fac.compania = ");
	sbSql.append(compId);
	sbSql.append(" and fac.cliente_otros = (select param_value from tbl_sec_comp_param where param_name = 'TIPO_CLTE_PLAN_MEDICO') ");
	
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(fac.fecha) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	
	sbSql.append(" union all select 'PAG', to_char(dp.fac_codigo), 'PAGO', to_char(p.fecha,'dd/mm/yyyy'), trunc(p.fecha), 0, p.pago_total, dp.codigo_transaccion from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago dp, tbl_fac_factura f  where dp.compania = p.compania and dp.codigo_transaccion = p.codigo  and dp.tran_anio = p.anio and p.tipo_cliente = 'O' and p.ref_id = ");
	sbSql.append(clientId);
	sbSql.append(" and p.ref_type = (select param_value from tbl_sec_comp_param where param_name = 'PM_TIPO_REF') and dp.anulada = 'N' ");
	sbSql.append(" and p.ref_type = (select param_value from tbl_sec_comp_param where param_name = 'PM_TIPO_REF') and dp.anulada = 'N' and f.codigo = dp.fac_codigo ");
	
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(p.fecha) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}

	sbSql.append(" order by 2,1,4 ");

al = SQLMgr.getDataList(sbSql.toString());

if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = request.getParameter("__ct");

	System.out.println("thebrain><>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 10.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "ESTADO DE CUENTA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblContent = new Vector();
	tblContent.addElement(".10"); //#Documento
	tblContent.addElement(".50"); //Descripción
	tblContent.addElement(".10"); //Fecha
	tblContent.addElement(".10"); //Facturado
	tblContent.addElement(".10"); //Pago
	tblContent.addElement(".10"); //Saldo
	
	String groupByFact = "";
	double totPagado = 0.0, totFacturado = 0.0, saldo = 0.0, totPagadoF = 0.0, totFacturadoF = 0.0;
	
	pc.setNoColumnFixWidth(tblContent);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblContent.size());

	pc.setFont(8, 1);
	pc.addCols("#Documento",0,1);
	pc.addCols("Descripción",0,1);
	pc.addCols("Fecha",1,1);
	pc.addCols("Facturado",2,1);
	pc.addCols("Pago",2,1);
	pc.addCols("Saldo",2,1);

	pc.setTableHeader(2);

	if (al.size()==0) {
		pc.addCols("No existen Registros",1,tblContent.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);
			
			if (!groupByFact.equals(cdo1.getColValue("fac_cod"))){
				if (i!=0){
					saldo = totFacturado - totPagado;
					pc.setFont(8, 1);
					pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo),2,tblContent.size(),0.0f,0.0f,0.1f,0.1f);
				}
				
				//HEADER
				
				pc.setFont(7, 0);
				pc.addBorderCols(cdo1.getColValue("fac_cod"),0,1,0.0f,0.1f,0.1f,0.0f);
				pc.addBorderCols(cdo1.getColValue("fac_desc"),0,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols(cdo1.getColValue("fecha_dsp"),1,1,0.0f,0.1f,0.0f,0.0f) ;
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("fac_monto")),2,1,0.0f,0.1f,0.0f,0.0f);
				pc.addBorderCols("",1,2,0.0f,0.1f,0.0f,0.1f) ;
				
				saldo = 0.0;
				totFacturado = 0.0;
				totPagado = 0.0;
			}
			
			if (cdo1.getColValue("doc").equalsIgnoreCase("PAG")) {
				pc.setFont(7, 0,Color.blue);
				pc.addBorderCols(cdo1.getColValue("cod_pago"),0,1,0.0f,0.0f,0.1f,0.0f);
				pc.addCols(cdo1.getColValue("fac_desc"),0,1);
				pc.addCols(cdo1.getColValue("fecha_dsp"),1,1) ;
				pc.addCols("",1,1) ;
				pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("pago_total")),2,1);
				pc.addBorderCols("",1,1,0.0f,0.0f,0.0f,0.1f) ;
			}
			
		   groupByFact = cdo1.getColValue("fac_cod");
		   totFacturado += Double.parseDouble(cdo1.getColValue("fac_monto")); 
		   totPagado += Double.parseDouble(cdo1.getColValue("pago_total"));
		   saldo = totFacturado-totPagado;
		   
		   totFacturadoF += Double.parseDouble(cdo1.getColValue("fac_monto"));
		   totPagadoF += Double.parseDouble(cdo1.getColValue("pago_total"));

		}//End For
		
		saldo = totFacturado - totPagado;
		pc.setFont(8, 1);
		//pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,tblContent.size());
		pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo),2,tblContent.size(),0.1f,0.0f,0.1f,0.1f);
		
		pc.setFont(8, 1, Color.red);
		pc.addCols("TOTAL EN FACTURAS",2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(totFacturadoF),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totPagadoF),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal((totFacturadoF-totPagadoF)),2,1);

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>