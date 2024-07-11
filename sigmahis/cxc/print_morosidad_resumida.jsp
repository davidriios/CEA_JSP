<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ include file="../common/pdf_header.jsp"%>


<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alTot = new ArrayList();
ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlTot = new StringBuffer();
//CommonDataObject cdoT = new CommonDataObject();
StringBuffer sbSql2 = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String compania = request.getParameter("compania");
String aseguradora = request.getParameter("aseguradora");
String fecha_inicial = request.getParameter("fecha");
String fecha_fin = request.getParameter("fecha_fin");
String categoria = request.getParameter("categoria");
String tipo_cta = request.getParameter("tipo_cta");
String pacId = request.getParameter("pacId");
String refType  = request.getParameter("refType");
String subRefType  = request.getParameter("subRefType");
String mostrar_factura  = request.getParameter("mostrar_factura");
String ex_tipo_clte  = request.getParameter("ex_tipo_clte");
String ex_sub_tipo_clte  = request.getParameter("ex_sub_tipo_clte");

String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
if (appendFilter == null) appendFilter = "";

if (compania == null ) compania = (String) session.getAttribute("_companyId");
if (aseguradora == null ) aseguradora = "";
if (categoria == null ) categoria = "";
if (tipo_cta == null ) tipo_cta = "";
if(refType == null) refType ="";
if(subRefType == null) subRefType ="";
if(mostrar_factura == null) mostrar_factura ="";
if(ex_tipo_clte == null) ex_tipo_clte ="";
if(ex_sub_tipo_clte == null) ex_sub_tipo_clte ="";

sbSql.append("select get_sec_comp_param(-1, 'TP_CLIENTE_OTROS') TP_CLIENTE_OTROS ,get_sec_comp_param(-1, 'CXC_MOR_RES_PART') as partRes from dual");
CommonDataObject _cd = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();

 sbSql.append(" select m.tipo_cta, decode(m.tipo_cta,'M','MEDICO','A','ASEGURADORA','J' ,'JUBILADO','P','PARTICULAR','N','JUNTA DIRECTIVA','E','EMPLEADO','O','OTROS CLIENTES','X','DETALLE AUX.') as desc_tipo_cta, case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then decode(m.tipo_cta,'A',to_char(m.aseguradora),'J',to_char(m.aseguradora),'P','PARTICULAR') else decode(m.tipo_cta, 'A', to_char(m.aseguradora), m.cedula) end as aseguradora,case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then   decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else  decode(m.tipo_cta, 'A', e.nombre, m.nombre || '-' || m.cedula) end    desc_empresa,case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then  decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else   nvl(e.nombre,  'PAGO NO APLICADO')  end as nombre_aseguradora, sum(nvl(m.scorriente,0)) scorriente, sum(nvl(m.s30,0)) s30, sum(nvl(m.s60,0)) s60, sum(nvl(m.s90,0)) s90, sum(nvl(m.s120,0)) s120, sum(nvl(m.s150,0)) s150, sum(nvl(m.scorriente,0) + nvl(m.s30,0) + nvl(m.s60,0) + nvl(m.s90,0) + nvl(m.s120,0) + nvl(m.s150,0)) saldo_actual from tbl_cxc_morosidades m, tbl_adm_empresa e, tbl_fac_factura f where  m.aseguradora = e.codigo(+) and m.cia = f.compania(+) and m.factura = f.codigo(+)");
sbSql.append(" and m.cia = ");
sbSql.append(compania);

if (tipo_cta.trim().equals("O")) {
sbSql.append(" and m.tipo_cta in('X','");
sbSql.append(tipo_cta);
sbSql.append("')");
}else {
	if (tipo_cta.trim().equals("A"))
	sbSql.append(" and m.tipo_cta in('A','J')");
	else if (tipo_cta.trim().equals("P"))
	sbSql.append(" and m.tipo_cta = 'P'");
	else if (tipo_cta.trim().equals("J"))
	sbSql.append(" and m.tipo_cta = 'J'");
	else if (!tipo_cta.trim().equals("")){
		sbSql.append(" and f.facturar_a = '");
		sbSql.append(tipo_cta);
		sbSql.append("'");
	}
}
if (!categoria.trim().equals("")){
sbSql.append(" and m.categoria = ");
sbSql.append(categoria);
}
if (!aseguradora.trim().equals("")){
sbSql.append(" and m.aseguradora = ");
sbSql.append(aseguradora);
}

if (mostrar_factura.trim().equals("E")){
	sbSql.append(" and exists (select null from tbl_fac_factura f where m.factura = f.codigo and m.cia=f.compania and (nvl(f.enviado, 'N') = 'S' or f.facturar_a = 'P' or (f.facturar_a in ('E', 'P') and nvl(substr(f.comentario, 1, 3), 'NA') = 'S/I')))");
} else if (mostrar_factura.trim().equals("N")){
	sbSql.append(" and exists (select null from tbl_fac_factura f where m.factura = f.codigo and m.cia=f.compania and nvl(f.enviado, 'N') = 'N' and f.facturar_a != 'P' and nvl(substr(f.comentario, 1, 3), 'NA') != 'S/I')");
}

sbSql.append(" and to_date(m.fecha,'dd/mm/yyyy') <= to_date('");
sbSql.append(fecha_inicial);
sbSql.append("' ,'dd/mm/yyyy')");

if (!pacId.trim().equals("")&&!tipo_cta.trim().equals("O")){
sbSql.append(" and m.pac_id = ");
sbSql.append(pacId);
}else  if (!pacId.trim().equals("")&&tipo_cta.trim().equals("O")){
sbSql.append(" and m.ref_id = '");
sbSql.append(pacId);
sbSql.append("'");
}
if (!refType.trim().equals("")) {
sbSql.append(" and m.ref_type =");
sbSql.append(refType);
}
if (!subRefType.trim().equals("")) {
sbSql.append(" and m.ref_id in (select to_char(codigo) from tbl_cxc_cliente_particular where compania =");
sbSql.append(compania);
sbSql.append(" and cliente_alquiler != 'S' and tipo_cliente=");
sbSql.append(subRefType);
sbSql.append(")");
}
if (!ex_tipo_clte.trim().equals("")) {
	sbSql.append(" and (m.ref_type not in (");
	sbSql.append(ex_tipo_clte);
	sbSql.append(", ");
	sbSql.append(_cd.getColValue("TP_CLIENTE_OTROS"));
	sbSql.append(")");
	if (!ex_sub_tipo_clte.trim().equals("")) {
		sbSql.append(" or (m.ref_type = ");
		sbSql.append(_cd.getColValue("TP_CLIENTE_OTROS"));
		sbSql.append(" and not exists (select null from tbl_cxc_cliente_particular cp where to_char (cp.codigo) = m.ref_id and tipo_cliente = ");
		sbSql.append(ex_sub_tipo_clte);
		sbSql.append("))");		
	}
	sbSql.append(")");
}
sbSql.append(" group by m.tipo_cta,decode(m.tipo_cta,'M','MEDICO','A','ASEGURADORA','J' ,'JUBILADO','P','PARTICULAR','N','JUNTA DIRECTIVA','E','EMPLEADO','O','OTROS CLIENTES','X','DETALLE AUX.'),case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y' then decode(m.tipo_cta,'A',to_char(m.aseguradora),'J',to_char(m.aseguradora),'P','PARTICULAR') else decode(m.tipo_cta, 'A', to_char(m.aseguradora), m.cedula) end  , case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then   decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else  decode(m.tipo_cta, 'A', e.nombre, m.nombre || '-' || m.cedula) end  , case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then  decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else   nvl(e.nombre,  'PAGO NO APLICADO')  end ");
//} 
 
if (tipo_cta.trim().equals("P")) sbSql.append(" order by 1, 2, 5, 4, 3 asc");
else sbSql.append(" order by 1, 2, 4, 3 asc");
al = SQLMgr.getDataList(sbSql.toString());

sbSqlTot.append("select desc_tipo_cta descripcion ,sum(scorriente) scorriente, sum(s30) s30, sum(s60) s60, sum(s90) s90, sum(s120) s120, sum(s150) s150, sum(saldo_actual) saldo_actual from (");
sbSqlTot.append(sbSql.toString());
sbSqlTot.append(") group by desc_tipo_cta");
/*
if (!tipo_cta.trim().equals("O")) {
sbSqlTot.append(" union all select  'PARTICULARES' descripcion, nvl(sum(scorriente),0) scorriente, nvl(sum(s30),0) s30, nvl(sum(s60),0) s60, nvl(sum(s90),0) s90, nvl(sum(s120),0) s120, nvl(sum(s150),0) s150, nvl(sum(saldo_actual),0) saldo_actual from (");
sbSqlTot.append(sbSql.toString());
sbSqlTot.append(") group by 'PARTICULARES' ");}
*/
//cdoT = SQLMgr.getData(sbSqlTot.toString());
alTot = SQLMgr.getDataList(sbSqlTot.toString());

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
	String title = "REPORTE DE MOROSIDAD RESUMIDO";
	if(mostrar_factura.equals("E")) title += " [ FACTURAS ENVIADAS ]";
	else if(mostrar_factura.equals("N")) title += " [ FACTURAS NO ENVIADAS ]";
	else title += " [ FACTURAS ENVIADAS Y NO ENVIADAS ]";
	String subtitle = " AL "+fecha_inicial;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



				Vector dHeader=new Vector();
					dHeader.addElement(".30");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");



				pc.setNoColumnFixWidth(dHeader);
				pc.createTable();
				pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

				pc.setFont(headerFontSize,1);
				if (tipo_cta.trim().equals("O"))pc.addBorderCols("Nombre Cliente",0);
				else pc.addBorderCols("Nombre Aseguradora",0);
				pc.addBorderCols("Corriente",2);
				pc.addBorderCols("A 30 dias",2);
				pc.addBorderCols("A 60 dias",2);
				pc.addBorderCols("A 90 dias",2);
				pc.addBorderCols("A 120 dias",2);
				pc.addBorderCols("A 150 dias",2);
				pc.addBorderCols("Total por Cia.",2);

				pc.setTableHeader(2);//create de table header

			//table body
			String groupBy = "",groupBy2 = "",groupBy3="";
			String groupTitle = "",groupTitle2 = "",groupTitle3="";
			String tipo="";
			double totalScorriente=0.00,totalS30=0.00,totalS60=0.00,totalS90=0.00,totalS120=0.00,totalS150=0.00,totalSaldoActual=0.00;
			double atotalScorriente=0.00,atotalS30=0.00,atotalS60=0.00,atotalS90=0.00,atotalS120=0.00,atotalS150=0.00,atotalSaldoActual=0.00;
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i);

					if(!groupBy.equals(cdo1.getColValue("desc_tipo_cta"))){
						pc.setFont(8, 1);
						pc.addBorderCols(""+cdo1.getColValue("desc_tipo_cta"),0,8);
					}
					if(!groupBy2.equals(cdo1.getColValue("nombre_aseguradora")) && tipo_cta.equals("P")){
						pc.setFont(8, 1);
						if(i!=0){
						pc.addBorderCols("Total "+groupBy2,0,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalScorriente),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS30),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS60),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS90),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS120),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS150),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalSaldoActual),2,1);
						
						atotalScorriente = 0;
						atotalS30 = 0;
						atotalS60 = 0;
						atotalS90 = 0;
						atotalS120 = 0;
						atotalS150 = 0;
						atotalSaldoActual = 0;}
						pc.addBorderCols(""+cdo1.getColValue("nombre_aseguradora"),0,8);
//						pc.setFont(8, 0);

					}
					pc.setFont(8, 0);
					pc.addBorderCols(""+cdo1.getColValue("desc_empresa"),0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("scorriente")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s30")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s60")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s90")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s120")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s150")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_actual")),2,1);
					groupBy = cdo1.getColValue("desc_tipo_cta");
					groupBy2 = cdo1.getColValue("nombre_aseguradora");

					atotalScorriente += Double.parseDouble(cdo1.getColValue("scorriente"));
					atotalS30 += Double.parseDouble(cdo1.getColValue("s30"));
					atotalS60 += Double.parseDouble(cdo1.getColValue("s60"));
					atotalS90 += Double.parseDouble(cdo1.getColValue("s90"));
					atotalS120 += Double.parseDouble(cdo1.getColValue("s120"));
					atotalS150+= Double.parseDouble(cdo1.getColValue("s150"));
					atotalSaldoActual += Double.parseDouble(cdo1.getColValue("saldo_actual"));
					
		}

		if (al.size()==0)pc.addCols("No existe Registros para este Reporte ",1,dHeader.size());

		if(al.size()!=0 && alTot.size() !=0)
		{
			if(tipo_cta.equals("P")){
						pc.setFont(8, 0);
						pc.addBorderCols("Total "+groupBy2,0,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalScorriente),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS30),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS60),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS90),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS120),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalS150),2,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(atotalSaldoActual),2,1);
			}
				for (int i=0; i<alTot.size(); i++)
					{
					CommonDataObject cdoT = (CommonDataObject) alTot.get(i);

					pc.setFont(8, 1,Color.blue);
					pc.addBorderCols("TOTAL "+cdoT.getColValue("descripcion"), 0,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("scorriente")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s30")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s60")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s90")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s120")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s150")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("saldo_actual")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);

					totalScorriente += Double.parseDouble(cdoT.getColValue("scorriente"));
					totalS30 += Double.parseDouble(cdoT.getColValue("s30"));
					totalS60 += Double.parseDouble(cdoT.getColValue("s60"));
					totalS90 += Double.parseDouble(cdoT.getColValue("s90"));
					totalS120 += Double.parseDouble(cdoT.getColValue("s120"));
					totalS150+= Double.parseDouble(cdoT.getColValue("s150"));
					totalSaldoActual += Double.parseDouble(cdoT.getColValue("saldo_actual"));

				}
					pc.addCols("  ",1,dHeader.size());
					pc.addBorderCols("TOTALES ", 0,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalScorriente),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalS30),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalS60),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalS90),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalS120),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalS150),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalSaldoActual),2,1, 0.0f, 0.5f, 0.0f, 0.0f);

		}



pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

