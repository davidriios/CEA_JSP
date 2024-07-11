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
Reporte recibos_sin_distribuir.rdf
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
String pago_por = request.getParameter("pago_por");
String tipoCliente = request.getParameter("tipoCliente");

if (appendFilter == null) appendFilter = "";
if (pago_por == null) pago_por = "";
if(turno==null) turno = "";
if(caja==null) caja = "";
if (tipoCliente == null) tipoCliente = "";  
if(compania==null) compania = (String) session.getAttribute("_companyId");


//sbSql.append("select b.descripcion descCaja, a.* from  ( select to_char(x.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, x.paciente,x.admision, x.recibo, to_char(x.fecha_pago,'dd/mm/yyyy') fecha_pago, x.desc_pago, x.compania,x. anio, x.codigo, decode(x.pago_por,null,'DEP','C','Pre-F','F','Fact') as pago_por, tipo_transaccion, x.fac_codigo,x.tipo_cliente,nvl(x.pago_total,0) as pago_total, x.monto_pagado, nvl(apl.aplicado,0)as aplicado,nvl(ajd.ajustes_db,0)as ajustes_db,nvl(dist.distr,0) as distribuido,decode(x.pago_por,'F',nvl(ajcr.ajustes_cr,0),0) as ajustes_cr,(nvl(monto_pagado,0)-nvl(ajd.ajustes_db,0)-nvl(dist.distr,0)- nvl(ajcr.ajustes_cr,0)) as monto_x_distribuir,x.secuencia_pago, x.det_cod_transaccion, x.det_anio_trn,x. empresa,x.caja from consulta_dist x, (select nvl(sum(b.monto),0) aplicado,c.codigo from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b, tbl_cja_recibos c where a.codigo = b.codigo_transaccion and a.anio = b.tran_anio and a.compania = b.compania and a.codigo = c.ctp_codigo and a.anio = c.ctp_anio and a.compania = c.compania and a.rec_status <> 'I' group by c.codigo)apl,(select nvl(sum(decode(na.lado_mov,'D',na.monto)),0)ajustes_db ,na.recibo,cp.fac_codigo from  vw_con_adjustment_gral na /*, vw_cja_consulta_pagos cp*/ where na.recibo = x.recibo and na.compania = x.compania /*and na.centro is null and na.empresa is null and na.medico is null*/ and na.tipo_doc = 'R' and na.recibo is not null group by na.recibo , cp.fac_codigo) ajd,(select nvl(sum(d.monto),0)distr ,c.codigo,b.admi_secuencia from tbl_cja_transaccion_pago a , tbl_cja_detalle_pago b,tbl_cja_recibos c, tbl_cja_distribuir_pago d where a.codigo = b.codigo_transaccion and a.anio = b.tran_anio and a.compania = b.compania and a.codigo = c.ctp_codigo and a.anio = c.ctp_anio and a.compania = c.compania and b.codigo_transaccion = d.codigo_transaccion and b.tran_anio = d.tran_anio and b.secuencia_pago = d.secuencia_pago and b.compania = d.compania and d.codigo_transaccion = c.ctp_codigo and d.tran_anio = c.ctp_anio and d.compania = c.compania and a.rec_status <> 'I' group by c.codigo,b.admi_secuencia)dist ,( select sum(decode(na.lado_mov,'C',na.monto))ajustes_cr,cp.fac_codigo,na.recibo from vw_con_adjustment_gral na /*, vw_cja_consulta_pagos cp*/ where  na.recibo = x.recibo and na.compania = x.compania /*and na.centro is null and na.empresa is null and na.medico is null*/ and na.tipo_doc = 'R' and na.recibo is not null group by na.recibo, cp.fac_codigo ) ajcr where x.recibo = apl.codigo(+) and x.recibo = ajd.recibo(+) and x.fac_codigo=ajd.fac_codigo(+) and x.recibo = dist.codigo(+) and x.admision=dist.admi_secuencia(+) and x.recibo = ajcr.recibo(+) and x.fac_codigo=ajcr.fac_codigo(+) and x.recibo=ajcr.recibo(+) and (x.pago_total > nvl(apl.aplicado,0)) and (nvl(apl.aplicado,0) - nvl(ajd.ajustes_db,0) - nvl(dist.distr,0)- nvl(ajcr.ajustes_cr,0) )>0 and x.compania =");
sbSql.append("select to_char(x.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, x.paciente,x.admision, x.recibo, to_char(x.fecha_pago,'dd/mm/yyyy') fecha_pago, x.desc_pago, x.compania,x. anio, x.codigo, decode(x.pago_por,null,'DEP','C','Pre-F','F','Fact') as pago_por, tipo_transaccion, x.fac_codigo,x.tipo_cliente,nvl(x.pago_total,0) as pago_total, x.monto_pagado, nvl(apl.aplicado,0)as aplicado,nvl(aj.ajustes,0)as ajustes,nvl(dist.distr,0) as distribuido,(nvl(monto_pagado,0)-nvl(dist.distr,0)+ nvl(aj.ajustes,0)) as monto_x_distribuir,x.secuencia_pago, x.det_cod_transaccion, x.det_anio_trn,x. empresa,x.caja,(select cja.descripcion from tbl_cja_cajas cja where cja.codigo=x.caja and cja.compania =x.compania) descCaja from vw_cja_consulta_dist x, (select nvl(sum(b.monto),0) aplicado,c.codigo from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b, tbl_cja_recibos c where a.codigo = b.codigo_transaccion and a.anio = b.tran_anio and a.compania = b.compania and a.codigo = c.ctp_codigo and a.anio = c.ctp_anio and a.compania = c.compania and a.rec_status <> 'I' group by c.codigo)apl, (select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as ajustes,z.recibo,z.compania from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.factura is null and z.tipo_doc = 'R' and z.recibo is not null and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D') group by z.recibo,z.compania) aj,(select nvl(sum(d.monto),0)distr ,c.codigo,b.admi_secuencia from tbl_cja_transaccion_pago a , tbl_cja_detalle_pago b,tbl_cja_recibos c, tbl_cja_distribuir_pago d where a.codigo = b.codigo_transaccion and a.anio = b.tran_anio and a.compania = b.compania and a.codigo = c.ctp_codigo and a.anio = c.ctp_anio and a.compania = c.compania and b.codigo_transaccion = d.codigo_transaccion and b.tran_anio = d.tran_anio and b.secuencia_pago = d.secuencia_pago and b.compania = d.compania and d.codigo_transaccion = c.ctp_codigo and d.tran_anio = c.ctp_anio and d.compania = c.compania and a.rec_status <> 'I' group by c.codigo,b.admi_secuencia)dist where x.compania="); 
sbSql.append(compania);
if(!caja.trim().equals("")){
sbSql.append(" and x.caja = ");
sbSql.append(caja); }

if(!fecha_ini.trim().equals("")){
sbSql.append(" and trunc(x.fecha_pago) >=to_date('");
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy') ");
 }
 if(!fecha_fin.trim().equals("")){
sbSql.append(" and trunc(x.fecha_pago) <=to_date('");
sbSql.append(fecha_fin);
sbSql.append("','dd/mm/yyyy') ");
 }
 
if(!pago_por.trim().equals("")){
sbSql.append(" and x.pago_por = '");
sbSql.append(pago_por);
sbSql.append("' "); }

if(!tipoCliente.trim().equals("")){
sbSql.append(" and x.tipo_cliente = '");
sbSql.append(tipoCliente);
sbSql.append("' ");}

 sbSql.append(" and x.recibo = apl.codigo(+) and x.recibo = aj.recibo(+)and x.compania = aj.compania(+)  and x.recibo = dist.codigo(+) and x.admision=dist.admi_secuencia(+) and (x.pago_total >= nvl(apl.aplicado,0)) and (nvl(apl.aplicado,0) -nvl(dist.distr,0)+ nvl(aj.ajustes,0) )>0 order by x.fecha_pago,x.caja asc");
  
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
	String title = "RECIBOS CON CUENTAS APLICADAS PENDIENTE DE DISTRIBUIR";
	String subtitle = "Desde:   "+fecha_ini + " Hasta: "+fecha_fin;
	String xtraSubtitle = "";
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
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".04");
			dHeader.addElement(".08");



	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);

		pc.setTableHeader(1);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "",groupBy3 = "";
	Double monto_fact =0.0, monto_total = 0.00,sub_total=0.00,sub_totalCaja=0.00,total=0.00,monto_x_distribuir=0.00;
	int recibo =0,reciboCaja=0,recTotal=0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		//CommonDataObject cdo1 = (CommonDataObject) al.get(x);

			if (!groupBy3.trim().equalsIgnoreCase(cdo.getColValue("recibo")))
			{
				if(i !=0)
				{
					pc.setFont(8, 0);
					pc.addCols("Total Aplicado Pendiente por Distribuir . . . . ", 2,6);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(monto_x_distribuir), 2,1);
					pc.addCols(" ", 2,6);
					monto_x_distribuir =0.00;
				}
			}
			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("fecha_pago")) && i!=0)
			{
				pc.setFont(groupSize, 1,Color.blue);
				pc.addCols("Cantidad de Recibos por fecha de pago . . .",2,4);
				pc.addCols(""+recibo,0,1);
				pc.addCols("Total",0,1);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(sub_total),0,7);
				sub_total=0.00;
				recibo =0;

			}
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")))
			{
				if(i !=0)
				{
					pc.setFont(groupSize, 1,Color.blue);
					pc.addCols("Tot. Recibos por caja . . .",2,4);
					pc.addCols(""+reciboCaja,0,1);
					pc.addCols("Total",0,1);
					pc.addCols("$"+CmnMgr.getFormattedDecimal(sub_totalCaja),0,7);
					sub_totalCaja=0.00;
					reciboCaja =0;
					pc.addCols("",0,dHeader.size());
				}
				pc.addBorderCols("CAJA:   ["+cdo.getColValue("caja")+"]   "+cdo.getColValue("descCaja"),0,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
			}

			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("fecha_pago")))
			{
				pc.addCols("FECHA DE PAGO " +cdo.getColValue("fecha_pago"),0,dHeader.size());
			}
			pc.setFont(fontSize, 0);

			if (!groupBy3.trim().equalsIgnoreCase(cdo.getColValue("recibo")))
			{


				pc.addCols("Recibo ",0,1);
				pc.setFont(9, 1,Color.red );
				pc.addCols(""+cdo.getColValue("recibo"),0,2);
					pc.setFont(fontSize, 0);
					pc.addCols("Concepto "+cdo.getColValue("desc_pago"),0,8);
					pc.addCols("Pago total "+CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")),0,3);

				pc.setFont(fontSize, 1);

					pc.addCols("Fecha Nac",0,1);
					pc.addCols("Pac #",1,1);
					pc.addCols("Admision",0,1);
					pc.addCols("Empresa",0,1);
					pc.addCols("Pago por",0,1);
					pc.addCols("Fact #",0,1);
					pc.addCols("M Aplic.",2,1);
					pc.addCols("M Dist",2,1);
					pc.addCols("Ajustes",2,1);
					pc.addCols("Por Distr.",2,1);
					pc.addCols("Transac. #",0,1);
					pc.addCols("Año",1,1);
					pc.addCols("Sec Pago",0,1);
					recibo ++;
					recTotal++;
					reciboCaja++;
			}

			pc.setFont(fontSize, 0);
			pc.addCols(" "+cdo.getColValue("fecha_nacimiento"), 0,1);
			pc.addCols(" "+cdo.getColValue("paciente"), 1,1);
			pc.addCols(" "+cdo.getColValue("admision"), 0,1);
			pc.addCols(" "+cdo.getColValue("empresa"), 0,1);
			pc.addCols(" "+cdo.getColValue("pago_por"), 0,1);
			pc.addCols(" "+cdo.getColValue("fac_codigo"), 0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_pagado")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("distribuido")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_x_distribuir")), 2,1);
			pc.addCols(" "+cdo.getColValue("det_cod_transaccion"), 0,1);
			pc.addCols(" "+cdo.getColValue("anio"), 1,1);
			pc.addCols(" "+cdo.getColValue("secuencia_pago"), 0,1);






		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("caja");
			groupBy2 = cdo.getColValue("fecha_pago");
			groupBy3 = cdo.getColValue("recibo");
			sub_total   += Double.parseDouble(cdo.getColValue("monto_x_distribuir"));
			sub_totalCaja  += Double.parseDouble(cdo.getColValue("monto_x_distribuir"));
			total  += Double.parseDouble(cdo.getColValue("monto_x_distribuir"));
			monto_x_distribuir +=  Double.parseDouble(cdo.getColValue("monto_x_distribuir"));
	}


	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
			pc.setFont(8, 0);
			pc.addCols("Total Aplicado Pendiente por Distribuir", 0,6);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(monto_x_distribuir), 2,1);
			pc.addCols(" ", 2,6);


			pc.setFont(groupSize, 1,Color.blue);
			pc.addCols("Cantidad de Recibos por fecha de pago . . .",2,4);
			pc.addCols(""+recibo,0,1);
			pc.addCols("Total",0,1);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(sub_total),0,7);

			pc.setFont(groupSize, 1,Color.blue);
			pc.addCols("Tot. Recibos por caja . . .",2,4);
			pc.addCols(""+reciboCaja,0,1);
			pc.addCols("Total",0,1);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(sub_totalCaja),0,7);

			pc.setFont(groupSize, 1,Color.blue);
			pc.addCols("Tot. Recibos por Reporte . . .",2,4);
			pc.addCols(""+recTotal,0,1);
			pc.addCols("Total",0,1);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(total),0,7);


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>