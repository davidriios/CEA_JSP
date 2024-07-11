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
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String orden = request.getParameter("orden");
String chk_anulado = request.getParameter("chk_anulado");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (orden == null) orden = "DESC";

   sql = "select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.beneficiario, ' / '||a.beneficiario2 beneficiario2, a.monto_girado, to_char(a.f_emision, 'dd/mm/yyyy') f_emision, a.estado_cheque, decode(a.estado_cheque,'G','GIRADO','P','PAGADO','A','ANULADO') estado_desc, a.anio, a.num_orden_pago, b.nombre nombre_banco, c.descripcion nombre_cuenta,(select op.cod_tipo_orden_pago   from tbl_cxp_orden_de_pago op where anio=a.anio and num_orden_pago=a.num_orden_pago and cod_compania=a.cod_compania) tp_orden,(select (select descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago=op.cod_tipo_orden_pago)  from tbl_cxp_orden_de_pago op where anio=a.anio and num_orden_pago=a.num_orden_pago and cod_compania=a.cod_compania) as tipo_orden,(select decode(tipo_orden,'E','Empresa','P','Paciente','L','Liquidacion','D','Dividendo','O','Otros','C',decode(cod_tipo_orden_pago,4,'Corredor','Contratos'),'B','Beneficiario','M','Medico','S','Sociedad Medica') from tbl_cxp_orden_de_pago where anio=a.anio and num_orden_pago=a.num_orden_pago and cod_compania=a.cod_compania) as sub_tipo_orden   from tbl_con_cheque a, tbl_con_banco b, tbl_con_cuenta_bancaria c where a.cod_compania = b.compania and a.cod_banco = b.cod_banco and a.cod_compania = c.compania and a.cuenta_banco = c.cuenta_banco "+appendFilter+" and a.cod_compania = " + (String) session.getAttribute("_companyId");
	 if(chk_anulado.equals("N")) sql += " and a.estado_cheque != 'A'";
 if(fg.trim().equals("TP"))  
    if(orden.trim().equals("DESC"))   sql +=" order by 14 asc, 16 asc, to_number(regexp_replace(a.num_cheque,'[at|AT]?')) desc, to_date(a.f_emision,'dd/mm/yyyy') desc";
  
    else   sql +=" order by 14 asc, 16 asc, to_number(regexp_replace(a.num_cheque,'[at|AT]?')) asc, to_date(a.f_emision,'dd/mm/yyyy') asc";
 
 else  
  if(orden.trim().equals("DESC"))   sql +=" order by a.estado_cheque, to_number(regexp_replace(a.num_cheque,'[at|AT]?')) desc, to_date(a.f_emision,'dd/mm/yyyy') desc";
  
 else   sql +=" order by a.estado_cheque, to_number(regexp_replace(a.num_cheque,'[at|AT]?')) asc, to_date(a.f_emision,'dd/mm/yyyy') asc";


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String title = "CXP";
	String subtitle = "LISTADO DE CHEQUES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		
			dHeader.addElement(".15");
			dHeader.addElement(".25");
			dHeader.addElement(".29");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".15");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		
		pc.addBorderCols("BANCO",0);
		pc.addBorderCols("CUENTA BANCARIA",0);
		pc.addBorderCols("BENEFICIARIO",0);
		pc.addBorderCols("MONTO",1);
		pc.addBorderCols("NO. CHEQUE",1);
		pc.addBorderCols("FECHA EMISION",1);			
		
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
		

	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
	
	String gEstado = "",groupBy ="",groupBy2 ="";
	int cantChk = 0, cantChkF = 0,cantTipo=0;
	double montoChk = 0.0, montoChkF = 0.0,montoTipo=0.0;
	
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		groupBy  = cdo.getColValue("estado_desc");
		//groupBy2 = cdo.getColValue("sub_tipo_orden");
		if(fg.trim().equals("TP"))groupBy=cdo.getColValue("tipo_orden");
		
		if(fg.trim().equals("TP"))
		{
		   if (!groupBy2.equals(cdo.getColValue("sub_tipo_orden")))
			{
			 if (i != 0)
			 {
				pc.setFont(9,1);
				pc.addCols("TOTAL "+groupBy2+" ..... ",2,3);
				pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",montoTipo),2,1);
				pc.addCols("TOT CHK: ",2,1);
				pc.addCols(String.valueOf(cantTipo),1,1);
			  }
			  montoTipo = 0.0;
	      	  cantTipo = 0;
		   }
		}
		
		if (!gEstado.equals(groupBy))
		{
		  pc.setFont(9, 1);
		  if (i != 0)
		  {
		    pc.addCols("TOTAL "+gEstado+" ..... ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",montoChk),2,1);
			pc.addCols("TOT CHK: ",2,1);
		    pc.addCols(String.valueOf(cantChk),1,1);
		  }
 		  pc.addCols(groupBy,0,dHeader.size(),Color.lightGray);
		  cantChk = 0;
	      montoChk = 0.0;
		}
		
		if(fg.trim().equals("TP"))
		{
			pc.setFont(9,1);
			if (!groupBy2.equals(cdo.getColValue("sub_tipo_orden")))
			pc.addCols(cdo.getColValue("sub_tipo_orden"),0,dHeader.size(),Color.lightGray);
		}
		
		pc.setFont(8, 0);
		pc.addCols(" "+cdo.getColValue("cod_banco")+" - "+cdo.getColValue("nombre_banco"),0,1);
		pc.addCols(" "+cdo.getColValue("nombre_cuenta"),0,1);
		pc.addCols(" "+cdo.getColValue("beneficiario")+" "+cdo.getColValue("beneficiario2"," "),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado")),2,1);
		pc.addCols(" "+cdo.getColValue("num_cheque"),1,1);
		pc.addCols(" "+cdo.getColValue("f_emision"),1,1);
		
		gEstado = cdo.getColValue("estado_desc");
		if(fg.trim().equals("TP"))gEstado=cdo.getColValue("tipo_orden");
		groupBy2 = cdo.getColValue("sub_tipo_orden");
		
		cantChk++;
		cantChkF++;
		
		montoChk += Double.parseDouble(cdo.getColValue("monto_girado"));
		montoChkF += Double.parseDouble(cdo.getColValue("monto_girado"));
		
		montoTipo += Double.parseDouble(cdo.getColValue("monto_girado"));
		cantTipo ++;

		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		
	pc.setFont(9,1);
	
	pc.addCols("TOTAL "+groupBy2+" ..... ",2,3);
	pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",montoTipo),2,1);
	pc.addCols("TOT CHK: ",2,1);
	pc.addCols(String.valueOf(cantTipo),1,1);
	
	pc.addCols("TOTAL "+gEstado+" ..... ",2,3);
	pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",montoChk),2,1);
	pc.addCols("TOT CHK: ",2,1);
	pc.addCols(String.valueOf(cantChk),1,1);
	
	pc.addCols("TOTALES FINALES ..... ",2,3);
	pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",montoChkF),2,1);
	pc.addCols("TOT. CHK: ",2,1);
	pc.addCols(String.valueOf(cantChkF),1,1);
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>