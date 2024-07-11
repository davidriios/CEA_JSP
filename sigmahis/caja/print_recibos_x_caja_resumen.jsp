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
Reporte cja71010.rdf
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

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
      String caja = request.getParameter("caja");
      String turno = request.getParameter("turno");
      String compania = request.getParameter("compania");
      String fecha_ini = request.getParameter("fechaini");
      String fecha_fin = request.getParameter("fechafin");
      String descCaja = request.getParameter("descCaja");

if (appendFilter == null) appendFilter = "";
if(turno==null) turno = "";
if(caja==null) caja = "";

turno = turno.trim();
if (!turno.equals("")) appendFilter += " and ctp.turno= "+turno;
if (!caja.equals("")) appendFilter += " and ctp.caja= "+caja;

sql.append("select   ctp.caja, ctp.turno, fp.descripcion, tc.cajero, sum(tfp.monto) monto from tbl_cja_cajas c, tbl_cja_transaccion_pago ctp, tbl_cja_trans_forma_pagos tfp, tbl_cja_forma_pago fp, (select a.codigo turno, b.cod_cajera||' - '||b.nombre cajero from tbl_cja_cajera b, tbl_cja_turnos a where a.cja_cajera_cod_cajera = b.cod_cajera and a.compania = b.compania and b.compania = ");
sql.append((String) session.getAttribute("_companyId"));
sql.append(") tc where c.compania = ");
sql.append(compania);
if(!fecha_ini.trim().equals("")){sql.append(" and ctp.fecha >=to_date('");sql.append(fecha_ini);sql.append("', 'dd/mm/yyyy')");}
if(!fecha_fin.trim().equals("")){sql.append(" and ctp.fecha <=to_date('");sql.append(fecha_fin);sql.append("', 'dd/mm/yyyy')");}

sql.append((turno.equals("")?"":" and ctp.turno = "+turno));
sql.append(" and ctp.compania = c.compania and ctp.caja = c.codigo and ctp.codigo = tfp.tran_codigo and ctp.compania = tfp.compania and ctp.anio = tfp.tran_anio and tfp.fp_codigo = fp.codigo and ctp.turno = tc.turno and ((ctp.rec_status = 'A') or (ctp.rec_status = 'I' ");
sql.append(appendFilter);
sql.append(" and ctp.turno <> ctp.turno_anulacion)) group by ctp.caja, ctp.turno, fp.descripcion, tc.cajero");
sql.append(" union ");
sql.append("select ctp.cod_caja caja, ctp.turno, fp.descripcion||' NC' descripcion, tc.cajero, sum(-tfp.monto) monto from tbl_cja_cajas c, tbl_fac_trx ctp, tbl_fac_trx_forma_pagos tfp, tbl_cja_forma_pago fp, (select a.codigo turno, b.cod_cajera || ' - ' || b.nombre cajero from tbl_cja_cajera b, tbl_cja_turnos a where a.cja_cajera_cod_cajera = b.cod_cajera and a.compania = b.compania and b.compania = ");
sql.append(compania);
sql.append(") tc where c.compania = ");
sql.append(compania);
if(!fecha_ini.trim().equals("")){sql.append(" and trunc(ctp.doc_date) >=to_date('");sql.append(fecha_ini);sql.append("', 'dd/mm/yyyy')");}
if(!fecha_fin.trim().equals("")){sql.append(" and trunc(ctp.doc_date) <=to_date('");sql.append(fecha_fin);sql.append("', 'dd/mm/yyyy')");}
sql.append(" and ctp.company_id = c.compania and ctp.cod_caja = c.codigo and ctp.doc_id = tfp.doc_id and ctp.company_id = tfp.compania and tfp.fp_codigo = fp.codigo and ctp.turno = tc.turno and ctp.doc_type = 'NCR'");
if (!turno.equals("")){sql.append(" and ctp.turno = ");sql.append(turno);}
if (!caja.equals("")){sql.append(" and ctp.cod_caja= ");sql.append(caja);}

sql.append("group by ctp.cod_caja, ctp.turno, fp.descripcion, tc.cajero");
sql.append(" order by 1, 2, 3");

al2 = SQLMgr.getDataList(sql);

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
	String title = "RESUMIDO POR CAJERO";
	String subtitle = "Desde:   "+fecha_ini + " Hasta: "+fecha_fin;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
          dHeader.addElement(".15");
          dHeader.addElement(".30");
          dHeader.addElement(".10");
          dHeader.addElement(".15");
          dHeader.addElement(".10");
          dHeader.addElement(".10");
          dHeader.addElement(".10");



	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());



	pc.setTableHeader(1);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto_fact =0.0, monto_total = 0.00;

	monto_total = 0.00;
	pc.setFont(fontSize, 0);
	if (al2.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		monto_fact = 0.00;
		pc.addBorderCols("TOTAL RESUMIDO",1,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
		String group = "";
		for (int i=0; i<al2.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al2.get(i);
			if(!group.equals(cdo.getColValue("turno")+"-"+cdo.getColValue("cajero"))){
				if(i!=0)pc.addCols("",0, dHeader.size());
				pc.addBorderCols(cdo.getColValue("turno")+" / "+cdo.getColValue("cajero"),0,7,0.0f,0.5f,0.0f,0.0f);

			}
			pc.addCols(cdo.getColValue("descripcion"),0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
			pc.addCols("",1,4);
			monto_total += Double.parseDouble(cdo.getColValue("monto"));
			group = cdo.getColValue("turno")+"-"+cdo.getColValue("cajero");
		}
		pc.addBorderCols("",0,2,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(monto_total),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("",1,4,0.0f,0.0f,0.0f,0.0f);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>