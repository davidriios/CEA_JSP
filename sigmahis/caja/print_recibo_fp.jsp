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
ArrayList alAnul = new ArrayList();
ArrayList alFp = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String compania = request.getParameter("compania");
String fechaDesde = request.getParameter("fechaini");
String fechaHasta = request.getParameter("fechafin");
String descCaja = request.getParameter("descCaja");
String formaPago = request.getParameter("formaPago");
String verFacturas = request.getParameter("verFacturas");
String fp = request.getParameter("fp");

if (appendFilter == null) appendFilter = "";
if(turno==null) turno = "";
if(fechaDesde==null) fechaDesde = "";
if(fechaHasta==null) fechaHasta = "";
if(formaPago==null) formaPago = "";
if(caja==null) caja = "";
if(verFacturas==null)verFacturas="";
if(fp==null)fp="";

sbSql.append("select 1 as ord, tp.anio, tp.codigo, tp.caja, tp.turno, tp.tipo_cliente, tp.recibo, tp.pago_total, to_char(tp.fecha,'dd/mm/yyyy') as fecha, tp.descripcion, decode(tp.tipo_cliente,'P',tp.pac_id,'E',tp.codigo_empresa) as codigoCliente, tp.nombre||decode(tp.nombre,tp.nombre_adicional,null,' / '||tp.nombre_adicional)||decode(tp.rec_status,'I',' (ANULADO)') as nombreCliente, nvl(fp.monto,0) as montoFp, fp.fp_codigo, nvl((select sum(nvl(dp.monto,0)) as montoAplicado from tbl_cja_detalle_pago dp where dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio),0) as montoAplicado, nvl((select sum(monto) as montoDistribuido from tbl_cja_distribuir_pago where compania = tp.compania and tran_anio = tp.anio and codigo_transaccion = tp.codigo),0) as montoDistribuido, (select descripcion from tbl_cja_cajas where codigo = tp.caja and compania = tp.compania) as descCaja, tp.usuario_creacion as usuario, (select substr(descripcion,0,10) from tbl_cja_forma_pago where codigo = fp.fp_codigo) as formaPago, ");
if(verFacturas.trim().equals("S"))sbSql.append(" nvl((select join(cursor(select fac_codigo from tbl_cja_detalle_pago dp where dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio group by fac_codigo having sum(nvl(monto,0)) <> 0),',') from dual),' ')");
else sbSql.append(" ' ' ");
sbSql.append(" as facturas, nvl(tp.rec_status,'A') as recStatus, case when nvl(tp.rec_status,'A') = 'I' and tp.turno = tp.turno_anulacion/* and nvl(tp.anulacion_sup,'X') <> 'S'*/ and nvl(tp.afectar_saldo,'X') <> 'S' then 'N' else 'S' end as sumarRec, case when fp.fp_codigo = 2 then nvl(to_char(fp.num_cheque),fp.no_referencia) when fp.fp_codigo in (0,1) then ' ' else fp.no_referencia end no_referencia from tbl_cja_transaccion_pago tp, tbl_cja_trans_forma_pagos fp where tp.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" /* and nvl(tp.rec_status,'A') <> 'I'*/ and tp.codigo = fp.tran_codigo(+) and tp.compania = fp.compania(+) and tp.anio = fp.tran_anio(+)");

if(!fechaDesde.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) >= to_date('");
	sbSql.append(fechaDesde);
	sbSql.append("','dd/mm/yyyy')");
}
if(!fechaHasta.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("','dd/mm/yyyy')");
}
if(!formaPago.trim().equals(""))
{
	sbSql.append(" and fp.fp_codigo = ");
	sbSql.append(formaPago);
}
if(!caja.trim().equals(""))
{
	sbSql.append(" and tp.caja = ");
	sbSql.append(caja);
}
if(!turno.trim().equals(""))
{
	sbSql.append(" and  tp.turno = ");
	sbSql.append(turno); 
}

sbSql.append(" union all ");
sbSql.append("select 3, 0 as anio, tp.doc_id as codigo, tp.cod_caja as caja, tp.turno, 'O' as tipo_cliente, to_char(tp.doc_id) as recibo, -tp.net_amount as pago_total, to_char(tp.doc_date,'dd/mm/yyyy') as fecha, tp.client_name as descripcion, 0 as codigocliente, tp.client_name as nombrecliente, nvl(-fp.monto,0) as montofp, fp.fp_codigo, 0 as montoaplicado, 0 as montodistribuido, (select descripcion from tbl_cja_cajas where codigo = tp.cod_caja and compania = tp.company_id) as desccaja, tp.created_by as usuario, (select substr(descripcion,0,15) from tbl_cja_forma_pago where codigo = fp.fp_codigo)||' NC' as formapago, ' ' as facturas, ' ' as recStatus, 'S', case when fp.fp_codigo = 2 then to_char(fp.num_cheque) when fp.fp_codigo in (0,1) then ' ' else fp.no_referencia end as no_referencia from tbl_fac_trx tp, tbl_fac_trx_forma_pagos fp where tp.company_id = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and tp.doc_type = 'NCR' and tp.tipo_factura = 'CO' and tp.doc_id = fp.doc_id(+) and tp.company_id = fp.compania(+)");
if(!fechaDesde.trim().equals(""))
{
	sbSql.append(" and trunc(tp.doc_date) >= to_date('");
	sbSql.append(fechaDesde);
	sbSql.append("','dd/mm/yyyy')");
}
if(!fechaHasta.trim().equals(""))
{
	sbSql.append(" and trunc(tp.doc_date) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("', 'dd/mm/yyyy')");
}
if(!formaPago.trim().equals(""))
{
	sbSql.append(" and fp.fp_codigo = ");
	sbSql.append(formaPago);
}
if(!caja.trim().equals(""))
{
	sbSql.append(" and tp.cod_caja = ");
	sbSql.append(caja);
}
if(!turno.trim().equals(""))
{
	sbSql.append(" and tp.turno = ");
	sbSql.append(turno);
}

sbSql.append(" order by 1, 4, 5, 7, 14 asc");
al = SQLMgr.getDataList(sbSql.toString());


//-----------------------------------------------------------



alFp = SQLMgr.getDataList("select sum(nvl(montoFp,0)) as montoFp, fp_codigo, (select descripcion from tbl_cja_forma_pago where codigo = fp_codigo) as formaPago from ("+sbSql.toString()+") where sumarRec = 'S' group by fp_codigo, formaPago");

sbSql = new StringBuffer(); 
sbSql.append("select 2 as ord, tp.anio, tp.codigo, tp.caja, tp.turno, tp.tipo_cliente, tp.recibo, tp.pago_total, to_char(tp.fecha_anulacion,'dd/mm/yyyy') as fecha, tp.descripcion, decode(tp.tipo_cliente,'P',tp.pac_id,'E',tp.codigo_empresa) as codigoCliente, tp.nombre||decode(tp.nombre,tp.nombre_adicional,null,' / '||tp.nombre_adicional)||decode(tp.rec_status,'I',' (ANULADO)') as nombreCliente, (select descripcion from tbl_cja_cajas where codigo = tp.caja and compania = tp.compania) as descCaja, tp.usuario_creacion as usuario, fn_cja_getFormaPago(tp.compania,tp.anio,tp.codigo) as forma_pago, nvl(tp.rec_status,'A') as recStatus, case when nvl(tp.rec_status,'A') = 'I' and tp.turno = tp.turno_anulacion/* and nvl(tp.anulacion_sup,'X') <> 'S'*/ and nvl(tp.afectar_saldo,'X') <> 'S' then 'N' else 'S' end as sumarRec, (select ctp.recibo from tbl_cja_trans_forma_pagos fpa,tbl_cja_transaccion_pago ctp where fpa.fp_codigo = '0' and ctp.compania = fpa.compania and ctp.anio = fpa.tran_anio and ctp.codigo = fpa.tran_codigo and fpa.no_referencia = tp.recibo and fpa.compania = tp.compania and ctp.rec_status <> 'I' and rownum = 1) as remp_por, tp.xtra1 as recibo_manual, tp.usuario_anulacion,'' as no_referencia from tbl_cja_transaccion_pago tp where tp.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append("/* and nvl(tp.rec_status,'A') <> 'I'*/ /*and tp.codigo = fp.tran_codigo(+) and tp.compania = fp.compania(+) and tp.anio = fp.tran_anio(+)*/");

if(!fechaDesde.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) >= to_date('");
	sbSql.append(fechaDesde);
	sbSql.append("','dd/mm/yyyy')");
}
if(!fechaHasta.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("','dd/mm/yyyy')");
}
if(!formaPago.trim().equals(""))
{
	sbSql.append(" and exists( select null from tbl_cja_trans_forma_pagos fp where tp.codigo = fp.tran_codigo and tp.compania = fp.compania and tp.anio = fp.tran_anio and fp.fp_codigo = ");
	sbSql.append(formaPago);
	sbSql.append(")");
}
if(!caja.trim().equals(""))
{
	sbSql.append(" and tp.caja = ");
	sbSql.append(caja);
}
sbSql.append(" and (tp.turno <> tp.turno_anulacion or tp.anulacion_sup = 'S')"); 

if(!turno.trim().equals(""))
{
	sbSql.append(" and (tp.turno_anulacion = ");
	sbSql.append(turno);
	sbSql.append(" or ( tp.turno=");
	sbSql.append(turno);
	sbSql.append(" and tp.anulacion_sup = 'S' ) ) ");
	
}
sbSql.append(" order by 1, 4, 5, 7, 14 asc");

alAnul = SQLMgr.getDataList(sbSql.toString());



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
	boolean isLandscape = (verFacturas.trim().equals("S"))?true:false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = (fp.trim().equals("FP"))?"RECIBOS POR FORMA DE PAGO":"RECIBOS PAGADOS POR CAJA"+(!turno.equals("")?" - TURNO #"+turno:"");
	String subtitle = "Desde:   "+fechaDesde + " Hasta: "+fechaHasta;
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


		Vector dHeader=new Vector();
          if(!verFacturas.trim().equals("S")){
		  dHeader.addElement(".05");
          dHeader.addElement(".08");
          dHeader.addElement(".18");
          dHeader.addElement(".08");
          dHeader.addElement(".09");
          dHeader.addElement(".09");
          dHeader.addElement(".09");
		  dHeader.addElement(".09");
		  dHeader.addElement(".17"); //
		  dHeader.addElement(".08");
		  }
		  else
		  {
		  dHeader.addElement(".05");
          dHeader.addElement(".08");
          dHeader.addElement(".18");
          dHeader.addElement(".08");
          dHeader.addElement(".08");
          dHeader.addElement(".08");
		  dHeader.addElement(".08");
          dHeader.addElement(".08");
		  dHeader.addElement(".08");
		  dHeader.addElement(".18"); //
		  dHeader.addElement(".08");
		  }
		
		Vector dHeader2 = new Vector();
		dHeader2.addElement(".08");
		dHeader2.addElement(".08");
		dHeader2.addElement(".35");
		dHeader2.addElement(".09");
		dHeader2.addElement(".20");
		dHeader2.addElement(".10");
		dHeader2.addElement(".10");


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);
		pc.addBorderCols("TURNO",0,1);
		pc.addBorderCols("RECIBO NO.",0,1);
		pc.addBorderCols("CLIENTE",0,1);
		pc.addBorderCols("FECHA",1,1);
		pc.addBorderCols("TOTAL",1,1);
		pc.addBorderCols("APLICADO",1,1);
		if(verFacturas.trim().equals("S"))pc.addBorderCols("FACTURAS",1,1);
		pc.addBorderCols("DISTRIBUIDO",1,1);
		pc.addBorderCols("USUARIO",1,1);
		pc.addBorderCols("FORMA PAGO",1,1);
		pc.addBorderCols("MONTO F. P.",1,1);

	pc.setTableHeader(2);

	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy1 = "";
	Double totalCaja =0.0, totalAplicado= 0.00, totalDistribuido= 0.00,totalAplicadoCja= 0.00,totalDistribuidoCja= 0.00,total=0.00,totalFpCja=0.00,totalFp=0.00;
	int signoRec =1;
	String printFac="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
			signoRec =1;
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")+"-"+cdo.getColValue("ord")))
			{
				
				if(i!=0)
				{
					pc.setFont(7, 0);
					pc.addCols("Total por caja: ", 2, 4);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCaja), 2, 1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totalAplicadoCja), 2, 1);
					if(verFacturas.trim().equals("S"))pc.addCols(" ", 1,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDistribuidoCja), 2, 1);
					pc.addCols(" ", 0, 2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totalFpCja), 2, 1);
					pc.addCols(" ", 0, dHeader.size());
					totalCaja = 0.00;
					totalAplicadoCja= 0.00;
					totalDistribuidoCja= 0.00;
					totalFpCja  = 0.00;
				}
				pc.addCols("CAJA: "+cdo.getColValue("caja")+" - "+cdo.getColValue("descCaja"),0,dHeader.size());
				if(cdo.getColValue("ord").trim().equals("2")){pc.setFont(7, 0,Color.red);
				pc.addCols("RECIBOS ANULADOS EN OTROS TURNOS (SUPERVISOR)",0,dHeader.size());}
				if(cdo.getColValue("ord").trim().equals("3"))pc.addCols("NOTAS DE CREDITOS",0,dHeader.size());
				if(i!=0)pc.addCols(" ", 0, dHeader.size());
				
			}
			    if(cdo.getColValue("recStatus").trim().equals("I")&&!cdo.getColValue("ord").trim().equals("1"))signoRec=-1;
				
				pc.setFont(7, 0);
				if(!groupBy1.trim().equals(cdo.getColValue("recibo")))
				{
				
				if(cdo.getColValue("recStatus").trim().equals("I"))pc.setFont(7, 0,Color.red);
				
				pc.addCols(" "+cdo.getColValue("turno"), 0,1);
				pc.addCols(" "+cdo.getColValue("recibo"), 0,1);
				pc.addCols(" "+cdo.getColValue("nombreCliente"), 0,1);
				pc.addCols(" "+cdo.getColValue("fecha"), 1,1);
				if(cdo.getColValue("sumarRec").trim().equals("S"))
				{
				pc.addCols(" "+(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("pago_total").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")), 2,1);
				pc.addCols(" "+(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("montoAplicado").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("montoAplicado")), 2,1);
				if(verFacturas.trim().equals("S")){if(cdo.getColValue("facturas").length() <=100)pc.addCols(""+cdo.getColValue("facturas"), 1,1);else{ pc.addCols(" ",1,1);printFac="S";} }
				pc.addCols(" "+(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("montoDistribuido").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("montoDistribuido")), 2,1);
				}
				else
				{
					pc.addCols("-", 2,1);
					pc.addCols("-", 2,1);
					if(verFacturas.trim().equals("S"))pc.addCols("-", 2,1);
					pc.addCols("-", 2,1);
				}
				
				pc.addCols(" "+cdo.getColValue("usuario"),1,1);
				}
				else if(verFacturas.trim().equals("S"))pc.addCols(" ",1,9); else pc.addCols(" ",1,8);
				if(cdo.getColValue("recStatus").trim().equals("I"))pc.setFont(7, 0,Color.red);
				if(cdo.getColValue("sumarRec").trim().equals("S"))
				{pc.addCols(" "+cdo.getColValue("formaPago")+" - "+cdo.getColValue("no_referencia"), 0,1);
				pc.addCols(" "+(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("montoFp").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("montoFp")),2,1);}
				else {pc.addCols("-", 0,1);
					pc.addCols("-", 0,2);
				}
				if(printFac.trim().equals("S"))
				{
					pc.addCols(" "+cdo.getColValue("facturas"),0,dHeader.size());
					printFac ="";
				}
				
				
				
				//pc.addCols("Forma de Pago: "+cdo.getColValue("forma_pago_monto"), 0, dHeader.size());

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("caja")+"-"+cdo.getColValue("ord");
			if(!groupBy1.trim().equals(cdo.getColValue("recibo"))){
			
			if(cdo.getColValue("sumarRec").trim().equals("S"))
			{
				
 					total +=signoRec*Double.parseDouble(cdo.getColValue("pago_total"));
					totalAplicadoCja+=signoRec*Double.parseDouble(cdo.getColValue("montoAplicado"));
					totalDistribuidoCja+=signoRec*Double.parseDouble(cdo.getColValue("montoDistribuido"));
		
					totalCaja +=signoRec*Double.parseDouble(cdo.getColValue("pago_total"));
					totalAplicado+=signoRec*Double.parseDouble(cdo.getColValue("montoAplicado"));
					totalDistribuido+=signoRec*Double.parseDouble(cdo.getColValue("montoDistribuido"));
			 }
			}
			groupBy1 = cdo.getColValue("recibo");
			if(cdo.getColValue("sumarRec").trim().equals("S")){
			if(cdo.getColValue("recStatus").trim().equals("I")&&!cdo.getColValue("ord").trim().equals("1"))signoRec=-1;else signoRec=1;
			totalFpCja+=signoRec*Double.parseDouble(cdo.getColValue("montoFp"));
			totalFp+=signoRec*Double.parseDouble(cdo.getColValue("montoFp"));}

	}

	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.addCols("Total por caja: ", 2, 4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCaja), 2, 1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalAplicadoCja), 2, 1);
			if(verFacturas.trim().equals("S"))pc.addCols(" ", 1,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDistribuidoCja), 2, 1);
			pc.addCols(" ", 0,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalFpCja), 2, 1);
			pc.addCols("Total por reporte: ", 2, 4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total), 2, 1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalAplicado), 2, 1);
			if(verFacturas.trim().equals("S"))pc.addCols(" ", 1,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDistribuido), 2, 1);
			pc.addCols(" ", 0,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalFp), 2, 1);


	}
	
	/*
	===================================================================================================================
	===================================================================================================================
	*/
	if (al.size() != 0)
	{
			pc.addCols(" ",1,dHeader.size());
			pc.addBorderCols("TOTAL RESUMIDO",1,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
			double montoTotal =0.00;

			for (int i=0; i<alFp.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) alFp.get(i);
				pc.addCols(cdo.getColValue("formaPago"),0,4);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("montoFp")),2,1);
				if(verFacturas.trim().equals("S"))pc.addCols(" ", 1,1);
				pc.addCols(" ",1,5);
				montoTotal += Double.parseDouble(cdo.getColValue("montoFp"));
			}
			pc.addBorderCols("",0,4,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(montoTotal),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols("",1,5,0.0f,0.0f,0.0f,0.0f);
			if(verFacturas.trim().equals("S"))pc.addCols(" ", 1,1);
	}
	
	/*
	===================================================================================================================
	===================================================================================================================
	*/	
	pc.setVAlignment(0);
	pc.addCols("  ",1,dHeader.size());
	pc.addCols(" RECIBOS ANULADOS",1,dHeader.size());
	pc.useTable("main");
	pc.flushTableBody(true);
	//delete previous rows
	pc.deleteRows(-1);
	int nColsFact =0;
	if(verFacturas.trim().equals("S")) nColsFact =1;
	
	pc.addBorderCols("Turno",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Recibo No.",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Nombre",1,(3+nColsFact),0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Fecha Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Forma Pagado",1,2 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Monto Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("U. Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	
	pc.addBorderCols("Turno",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Recibo No.",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Nombre",1,(3+nColsFact),0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Fecha Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Forma Pagado",1,2 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Monto Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("U. Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	//pc.setTableHeader(1);
	String groupByCaja	 = "";
	double subTotalCja=0.00,totalAn=0.00;
	for (int a = 0; a<alAnul.size(); a++){
		CommonDataObject cdo1 = (CommonDataObject) alAnul.get(a);
		if (!groupByCaja.trim().equalsIgnoreCase(cdo1.getColValue("caja")))
		{
			if(a!=0)
			{
				pc.setFont(8, 1,Color.black);
				pc.addCols("Monto Anulado por caja  .   .   .   .   .   .   .   .   .   .   ",2,(5+nColsFact));
				pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalCja)),2,1);
				pc.addCols(" ",2,1);
				pc.addCols(" ",0,dHeader.size(),cHeight);
				subTotalCja =0.00;
			}
			pc.setFont(8, 1,Color.black);
			pc.addCols("Caja:",0,1);
			pc.addCols(cdo1.getColValue("caja")+" - "+cdo1.getColValue("descCaja"),0,(9+nColsFact));
		}
		// contenido
		pc.setFont(7, 0);
		pc.addCols(cdo1.getColValue("turno"), 0,1);
		pc.addCols(cdo1.getColValue("recibo"), 0,1);
		pc.addCols(cdo1.getColValue("nombreCliente")+( cdo1.getColValue("remp_por")!=null && !cdo1.getColValue("remp_por").equals("")?" - REEMPLAZADO POR: "+cdo1.getColValue("remp_por"):"" ), 0,(3+nColsFact));
		pc.addCols(cdo1.getColValue("fecha"), 0,1);
		pc.setFont(6, 0);
		pc.addCols(cdo1.getColValue("forma_pago"),2,2);
		pc.setFont(7, 0);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("pago_total")), 2,1);
		pc.addCols(cdo1.getColValue("usuario_anulacion"), 0,1);
		
		subTotalCja +=Double.parseDouble(cdo1.getColValue("pago_total"));
		totalAn += Double.parseDouble(cdo1.getColValue("pago_total"));
		
		groupByCaja = cdo1.getColValue("caja");
	
	}//for a

	if (alAnul.size() != 0)
	{
			pc.setFont(8, 1,Color.black);
			pc.addCols("Monto Anulado por caja  .   .   .   .   .   .   .   .   .   .   ",2,(7+nColsFact));
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalCja)),2,2);
			pc.addCols(" ",2,1);
			
			pc.addCols(" ",0,dHeader.size(),cHeight); 

			pc.addCols("Total Anulado   .   .   .   .   .   .   .   .   .   .   ",2,(7+nColsFact));
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalAn)), 2,2);
			pc.addCols(" ",2,1);
	}
	
	pc.addCols(" ",0,dHeader.size(),cHeight); 

			pc.addCols("Total Final   .   .   .   .   .   .   .   .   .   .   ",2,(7+nColsFact));
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(total-totalAn)), 2,2);
			pc.addCols(" ",2,1);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

 }//GET
%>