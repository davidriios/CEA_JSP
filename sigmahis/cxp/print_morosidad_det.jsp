<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ include file="../common/pdf_header.jsp"%>


<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
Hashtable ht = new Hashtable();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlTot = new StringBuffer();
CommonDataObject cdoT = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sala = request.getParameter("sala");
String compania = request.getParameter("compania");
String proveedor = request.getParameter("proveedor");
String fecha_inicial = request.getParameter("fecha");
String tipo_proveedor = request.getParameter("tipo_proveedor");
String con_morosidad = request.getParameter("con_morosidad");


String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
if (appendFilter == null) appendFilter = "";

if (compania == null ) compania = (String) session.getAttribute("_companyId");
if (proveedor == null ) proveedor = "";
if (tipo_proveedor == null ) tipo_proveedor = "";
if (con_morosidad == null ) con_morosidad = "";


sbSql.append("select nvl(to_char(m.cod_prov),' ') proveedor, substr(m.factura, 1, 2) tipo, (select nombre_proveedor from tbl_com_proveedor where cod_provedor = m.cod_prov) as nombre_proveedor, (select decode(dia_limite, 1,'15 Dias',2, '30 Dias',3, '45 Dias',4, '60 Dias', 5, '90 Dias', 6, '120 Dias') from tbl_com_proveedor where cod_provedor = m.cod_prov) as dias_limite, (select (select descripcion from tbl_com_tipo_proveedor where tipo_proveedor = p.tipo_prove) from tbl_com_proveedor p where cod_provedor = m.cod_prov) as tipo_proveedor_desc, m.cia ciap, to_char(m.fec_fac,'dd/mm/yyyy') f_factura, decode(substr(m.factura, 1, 1), 'P', '-', to_char(trunc(to_date('");
sbSql.append(fecha_inicial);
sbSql.append("', 'dd/mm/yyyy')-m.fec_fac))) dias_antiguedad, nvl(m.scorriente,0) s_corriente, nvl(m.s30,0) s30, nvl(m.s60,0) s60, nvl(m.s90,0) s90, nvl(m.s120,0) s120, nvl(m.factura,' ') factura, (nvl(scorriente,0) + nvl(s30,0) + nvl(s60,0) + nvl(s90,0) + nvl(s120,0))  saldo_actual from tbl_cxp_morosidad m where /*m.factura not like 'F SI_%' and*/ m.cia = ");
sbSql.append(compania);

if (!tipo_proveedor.trim().equals("")) {
sbSql.append(" and exists (select null from tbl_com_proveedor where cod_provedor = m.cod_prov and tipo_prove = '");
sbSql.append(tipo_proveedor);
sbSql.append("')");
}
if (!proveedor.trim().equals("")) {
sbSql.append(" and m.cod_prov = ");
sbSql.append(proveedor);
}

sbSql.append(" and to_date(m.fecha,'dd/mm/yyyy') <= to_date('");
sbSql.append(fecha_inicial);
sbSql.append("' ,'dd/mm/yyyy')");
if(con_morosidad.equals("S")){
sbSql.append(" and (NVL (m.scorriente, 0) + NVL (m.s30, 0) + NVL (m.s60, 0) + NVL (m.s90, 0) + NVL (m.s120, 0)) > 0");
}
sbSql.append(" order by 3, nvl(to_char(m.cod_prov),' '), m.fec_fac asc");  
al = SQLMgr.getDataList(sbSql.toString());

sbSqlTot.append("select tipo, sum(s_corriente) s_corriente, sum(s30) s30, sum(s60) s60, sum(s90) s90, sum(s120) s120, sum(saldo_actual) saldo_actual from (");
sbSqlTot.append(sbSql.toString());
sbSqlTot.append(") group by tipo order by tipo");
ArrayList alT = SQLMgr.getDataList(sbSqlTot.toString());

sbSql = new StringBuffer();
sbSql.append("select m.cod_prov proveedor, substr(m.factura, 1, 2) tipo, nvl(sum(m.scorriente),0) s_corriente, nvl(sum(m.s30),0) s30, nvl(sum(m.s60),0) s60, nvl(sum(m.s90),0) s90, nvl(sum(m.s120),0) s120, sum(nvl(scorriente,0) + nvl(s30,0) + nvl(s60,0) + nvl(s90,0) + nvl(s120,0)) saldo_actual from tbl_cxp_morosidad m where /*m.factura not like 'F SI_%' and*/ m.cia = ");
sbSql.append(compania);

if (!tipo_proveedor.trim().equals("")) {
sbSql.append(" and exists (select null from tbl_com_proveedor where cod_provedor = m.cod_prov and tipo_prove = '");
sbSql.append(tipo_proveedor);
sbSql.append("')");
}
if (!proveedor.trim().equals("")) {
sbSql.append(" and m.cod_prov = ");
sbSql.append(proveedor);
}

sbSql.append(" and to_date(m.fecha,'dd/mm/yyyy') <= to_date('");
sbSql.append(fecha_inicial);
sbSql.append("' ,'dd/mm/yyyy') group by m.cod_prov, substr(m.factura, 1, 2)");

ArrayList alP = SQLMgr.getDataList(sbSql.toString());
for(int i=0;i<alP.size();i++){
	CommonDataObject cdoP = (CommonDataObject) alP.get(i);
	ht.put(cdoP.getColValue("proveedor")+"_"+cdoP.getColValue("tipo"), cdoP);
}


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
	String title = "REPORTE DE MOROSIDAD DETALLADO";
	String subtitle = " AL "+fecha_inicial;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
  
		
				Vector dHeader=new Vector();
				  //dHeader.addElement(".36");
					dHeader.addElement(".08");
					dHeader.addElement(".15");
					dHeader.addElement(".10");
					dHeader.addElement(".11");
					dHeader.addElement(".11");
					dHeader.addElement(".11");
					dHeader.addElement(".11");
					dHeader.addElement(".11");
					dHeader.addElement(".11");



				pc.setNoColumnFixWidth(dHeader);
				pc.createTable();
				pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

				pc.setFont(headerFontSize,1);
				//pc.addBorderCols("Nombre del Proveedor",0);
				pc.addBorderCols("Fecha Factura",0);
				pc.addBorderCols("# Factura/Doc.",0);
				pc.addBorderCols("Días Antigüedad",0);
				pc.addBorderCols("S. Actual",2);
				pc.addBorderCols("Corriente",2);
				pc.addBorderCols("A 30 dias",2);
				pc.addBorderCols("A 60 dias",2);
				pc.addBorderCols("A 90 dias",2);
				pc.addBorderCols("A 120 dias",2);
				
				pc.setTableHeader(2);//create de table header

			//table body
			String groupBy = "";
			boolean printNombreProv = true;
			CommonDataObject cdoHT = new CommonDataObject();
			CommonDataObject cdoSHT = new CommonDataObject();
			double s_a=0.00, s_c=0.00, s30=0.00, s60=0.00, s90=0.00, s120=0.00;
			double sp_a=0.00, sp_c=0.00, sp30=0.00, sp60=0.00, sp90=0.00, sp120=0.00;
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		
				if (!groupBy.equalsIgnoreCase(cdo1.getColValue("proveedor")))
				{
					if (i != 0)
					{
						if(ht.containsKey(groupBy+"_F")){
							cdoHT = (CommonDataObject) ht.get(groupBy+"_F");
							pc.setFont(8, 1,Color.blue);
							pc.addBorderCols("TOTAL SIN PAGOS ADELANTADOS", 2,3,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("saldo_actual")),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s_corriente")),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s30")),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s60")),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s90")),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s120")),2,1,0.0f,0.5f,0.0f,0.0f);
							s_a=Double.parseDouble(cdoHT.getColValue("saldo_actual"));
							s_c=Double.parseDouble(cdoHT.getColValue("s_corriente"));
							s30=Double.parseDouble(cdoHT.getColValue("s30"));
							s60=Double.parseDouble(cdoHT.getColValue("s60"));
							s90=Double.parseDouble(cdoHT.getColValue("s90"));
							s120=Double.parseDouble(cdoHT.getColValue("s120"));
						}
						
						if(ht.containsKey(groupBy+"_P")){
							cdoHT = (CommonDataObject) ht.get(groupBy+"_P");
							sp_a=Double.parseDouble(cdoHT.getColValue("saldo_actual"));
							sp_c=Double.parseDouble(cdoHT.getColValue("s_corriente"));
							sp30=Double.parseDouble(cdoHT.getColValue("s30"));
							sp60=Double.parseDouble(cdoHT.getColValue("s60"));
							sp90=Double.parseDouble(cdoHT.getColValue("s90"));
							sp120=Double.parseDouble(cdoHT.getColValue("s120"));

							pc.setFont(8, 1,Color.red); 
							pc.addBorderCols("TOTAL CON PAGOS ADELANTADOS", 2,3,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s_a+sp_a),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s_c+sp_c),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s30+sp30),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s60+sp60),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s90+sp90),2,1,0.0f,0.5f,0.0f,0.0f);
							pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s120+sp120),2,1,0.0f,0.5f,0.0f,0.0f);
						}
						
						pc.addCols(" ",0,dHeader.size());
						printNombreProv = true;
						
					}
			  }// x aseg. 
				
				  pc.setFont(8, 0);
					if(printNombreProv)pc.addBorderCols("["+cdo1.getColValue("proveedor")+"] "+cdo1.getColValue("nombre_proveedor")+" - "+cdo1.getColValue("dias_limite"),1,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
					if(cdo1.getColValue("tipo").trim().equals("P"))pc.setFont(8, 1,Color.red);
					 
					pc.addCols(""+cdo1.getColValue("f_factura"),0,1);
					pc.addCols(""+cdo1.getColValue("factura"),0,1);

					pc.addCols(""+cdo1.getColValue("dias_antiguedad"),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_actual")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s_corriente")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s30")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s60")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s90")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s120")),2,1);
					
					groupBy    =  cdo1.getColValue("proveedor");
					printNombreProv = false;
					s_a=0.00; s_c=0.00; s30=0.00; s60=0.00; s90=0.00; s120=0.00;
					
		}		
		
		if (al.size()==0)pc.addCols("No existe Registros para este Reporte ",1,dHeader.size());
		else
		{
			if(ht.containsKey(groupBy+"_F")){
				cdoHT = (CommonDataObject) ht.get(groupBy+"_F");
				pc.setFont(8, 1,Color.blue);
				pc.addBorderCols("TOTAL SIN PAGOS ADELANTADOS", 2,3,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("saldo_actual")),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s_corriente")),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s30")),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s60")),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s90")),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoHT.getColValue("s120")),2,1,0.0f,0.5f,0.0f,0.0f);
				s_a=Double.parseDouble(cdoHT.getColValue("saldo_actual"));
				s_c=Double.parseDouble(cdoHT.getColValue("s_corriente"));
				s30=Double.parseDouble(cdoHT.getColValue("s30"));
				s60=Double.parseDouble(cdoHT.getColValue("s60"));
				s90=Double.parseDouble(cdoHT.getColValue("s90"));
				s120=Double.parseDouble(cdoHT.getColValue("s120"));
			}
			if(ht.containsKey(groupBy+"_P")){
				cdoHT = (CommonDataObject) ht.get(groupBy+"_P");
				sp_a=Double.parseDouble(cdoHT.getColValue("saldo_actual"));
				sp_c=Double.parseDouble(cdoHT.getColValue("s_corriente"));
				sp30=Double.parseDouble(cdoHT.getColValue("s30"));
				sp60=Double.parseDouble(cdoHT.getColValue("s60"));
				sp90=Double.parseDouble(cdoHT.getColValue("s90"));
				sp120=Double.parseDouble(cdoHT.getColValue("s120"));
				pc.setFont(8, 1,Color.red);
				pc.addBorderCols("TOTAL CON PAGOS ADELANTADOS", 2,3,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s_a+sp_a),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s_c+sp_c),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s30+sp30),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s60+sp60),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s90+sp90),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s120+sp120),2,1,0.0f,0.5f,0.0f,0.0f);
			}
			
			pc.addCols(" ",0,dHeader.size());
			for(int k=0;k<alT.size();k++){
				cdoT = (CommonDataObject) alT.get(k);
				if(cdoT.getColValue("tipo").equals("F")){
					pc.setFont(8, 1,Color.blue);
					pc.addCols("TOTALES SIN PAGOS ADELANTADOS", 2,3);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("saldo_actual")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s_corriente")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s30")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s60")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s90")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s120")),2,1);
					s_a=Double.parseDouble(cdoT.getColValue("saldo_actual"));
					s_c=Double.parseDouble(cdoT.getColValue("s_corriente"));
					s30=Double.parseDouble(cdoT.getColValue("s30"));
					s60=Double.parseDouble(cdoT.getColValue("s60"));
					s90=Double.parseDouble(cdoT.getColValue("s90"));
					s120=Double.parseDouble(cdoT.getColValue("s120"));
				} else {
					pc.setFont(8, 1,Color.red);
					sp_a=Double.parseDouble(cdoT.getColValue("saldo_actual"));
					sp_c=Double.parseDouble(cdoT.getColValue("s_corriente"));
					sp30=Double.parseDouble(cdoT.getColValue("s30"));
					sp60=Double.parseDouble(cdoT.getColValue("s60"));
					sp90=Double.parseDouble(cdoT.getColValue("s90"));
					sp120=Double.parseDouble(cdoT.getColValue("s120"));
					pc.addCols("TOTALES CON PAGOS ADELANTADOS", 2,3);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s_a+sp_a),2,1,0.0f,0.5f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s_c+sp_c),2,1,0.0f,0.5f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s30+sp30),2,1,0.0f,0.5f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s60+sp60),2,1,0.0f,0.5f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s90+sp90),2,1,0.0f,0.5f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(s120+sp120),2,1,0.0f,0.5f,0.0f,0.0f);
				}
			}
		}

pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>				

