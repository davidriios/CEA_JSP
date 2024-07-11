<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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

StringBuffer sbSql = new StringBuffer();

sbSql.append(" select p.codigo, dp.fac_codigo, p.recibo, p.caja, p.ref_id, p.turno, c.descripcion caja_desc, dp.doc_a_nombre, p.pago_total, decode(dp.pago_por,'F','FACTURA','D','DEPOSITO','R','REMANENTE','N/A') pago_por, to_char(p.fecha ,'dd/mm/yyyy') fecha, cj.nombre cajero from tbl_cja_detalle_pago dp , tbl_cja_transaccion_pago p, tbl_cja_cajas c /*--------------*/ ,tbl_cja_cajas_x_cajero cc, tbl_cja_cajera cj, tbl_cja_turnos t, tbl_cja_turnos_x_cajas tc where dp.compania = p.compania and dp.codigo_transaccion = p.codigo  and dp.tran_anio = p.anio and p.tipo_cliente = 'O' and p.ref_type = (select param_value from tbl_sec_comp_param where param_name = 'PM_TIPO_REF') and dp.anulada = 'N' and c.codigo = p.caja and c.compania = p.compania  /*--------------*/ and cc.cod_cajero = cj.cod_cajera and t.cja_cajera_cod_cajera = cj.cod_cajera and tc.compania = t.compania and tc.cod_turno = t.codigo and tc.cod_caja = c.codigo and tc.compania = c.compania and rownum = 1 and  cc.cod_caja = p.caja and cc.compania_caja = c.compania and t.codigo = p.turno  and p.ref_id = ");

	sbSql.append(clientId);
	
	if(!fechaIni.equals("") && !fechaFin.equals("")){
		sbSql.append(" and trunc(p.fecha) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(" order by p.fecha desc ");

al = SQLMgr.getDataList(sbSql.toString());

if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

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
	String subtitle = "LISTADO DE PAGOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblContent = new Vector();
	tblContent.addElement(".10"); //#Trans
	tblContent.addElement(".10"); //Factura
	tblContent.addElement(".30"); //Nombre
	tblContent.addElement(".20"); //Caja
	tblContent.addElement(".10"); //Cajer@
	tblContent.addElement(".10"); //Fecha Pago
	tblContent.addElement(".10"); //Monto
	
	pc.setNoColumnFixWidth(tblContent);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblContent.size());

	pc.setFont(8, 1);
	pc.addBorderCols("#Trans",1,1);
	pc.addBorderCols("#Factura",1,1);
	pc.addBorderCols("Cliente",0,1);
	pc.addBorderCols("Caja",0,1);
	pc.addBorderCols("Cajer@",0,1);
	pc.addBorderCols("F.Pago",1,1);
	pc.addBorderCols("Monto",2,1);

	pc.setTableHeader(2);

	if (al.size()==0) {
		pc.addCols("No existen datos a cerca de planes!",1,tblContent.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);
			
			pc.setFont(7, 0);
			pc.addCols(cdo1.getColValue("codigo"),1,1);
			pc.addCols(cdo1.getColValue("fac_codigo"),1,1);
			pc.addCols(cdo1.getColValue("doc_a_nombre"),0,1);
			pc.addCols("["+cdo1.getColValue("caja")+"] "+cdo1.getColValue("caja_desc"),0,1) ;
			pc.addCols(cdo1.getColValue("cajero"),0,1) ;
			pc.addCols(cdo1.getColValue("fecha"),1,1) ;
			pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("pago_total")),2,1) ;
						
		}//End For

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>