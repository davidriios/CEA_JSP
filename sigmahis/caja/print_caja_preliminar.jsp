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

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fecha_ini = request.getParameter("fechaini");
String fecha_fin = request.getParameter("fechafin");

String caja = request.getParameter("caja");
String compania = request.getParameter("compania");
String estatus = request.getParameter("estatus");// estado del turno
String turno = request.getParameter("turno");// estado del turno

if (appendFilter == null) appendFilter = "";
if (caja == null) caja = "";
if (compania == null) compania = (String) session.getAttribute("_companyId");
if (fecha_ini == null) fecha_ini = "";
if (fecha_fin == null) fecha_fin = "";
if (estatus == null) estatus = "";
if (estatus.trim().equals("")) estatus = "A";
if (turno == null) turno = "";


sql.append("select 'A' tipo,a.caja,a.turno,0 f_codigo,sum(a.pago) pagoTotal, sum(-a.nc_pos) nc_pos, count(a.recibos) recibos,a.nombre_cajera ,nvl(a.hora_turno,'')hora_turno,'' forma_pago,a.descCaja,decode(a.turnoEstado,'A','ACTIVO','I','INCATIVO','S/E') turnoEstado from ( select distinct tp.compania,tp.recibo recibos,decode (tp.anulada,'S','** ANULADO **','N',null) estatus_recibo,tp.codigo_paciente,tp.pago_total pago,trunc (tp.fecha_creacion) fecha,tp.caja,'INICIO DE TURNO: '|| to_char (ct.hora_inicio, 'HH12:MI:SS AM')|| ' FIN DE TURNO: '|| to_char (ct.hora_final, 'HH12:MI:SS AM')hora_turno,'CAJER@: ' || cca.nombre nombre_cajera,tp.turno,tp.codigo_empresa,cc.descripcion descCaja,cc.ubicacion,tp.nombre nombre_del_cliente,tp.tipo_cliente,ctxc.estatus turnoEstado, nvl((select sum(f.net_amount) from tbl_fac_trx f where f.company_id = tp.compania and f.doc_type = 'NCR' and exists (select null from tbl_fac_trx ft where ft.doc_id = f.reference_id and ft.company_id = f.company_id and exists(select null from tbl_cja_detalle_pago dp where dp.fac_codigo = ft.other3 and dp.compania = tp.compania and dp.tran_anio = tp.anio and dp.codigo_transaccion = tp.codigo))), 0) nc_pos from tbl_cja_transaccion_pago tp,tbl_cja_cajera cca,tbl_cja_turnos ct,tbl_cja_cajas cc,tbl_cja_turnos_x_cajas ctxc where tp.compania = cc.compania and tp.caja = cc.codigo and tp.compania = ctxc.compania and tp.caja = ctxc.cod_caja and tp.turno = ctxc.cod_turno and cc.compania = ctxc.compania and cc.codigo = ctxc.cod_caja and ct.compania = ctxc.compania and ct.codigo = ctxc.cod_turno and cca.cod_cajera = ct.cja_cajera_cod_cajera and cca.compania = ct.compania");
if(!fecha_ini.trim().equals("")){sql.append(" and tp.fecha >= to_date('");sql.append(fecha_ini);sql.append("','dd/mm/yyyy')");}
if(!fecha_fin.trim().equals("")){sql.append(" and tp.fecha <= to_date('");sql.append(fecha_fin);sql.append("','dd/mm/yyyy')");}
if(!caja.trim().equals("")){sql.append(" and tp.caja=");sql.append(caja);}
if(!turno.trim().equals("")){sql.append(" and tp.turno=");sql.append(turno);}
sql.append(" and tp.compania=");sql.append(compania);

sql.append(" /*and tp.impreso = 'N' and tp.status = 'C'*/ and cc.estado = 'A' and nvl(tp.rec_status, 'A') <> 'I' and ctxc.estatus = '");
sql.append(estatus);
sql.append("' order by tp.recibo) a group by a.caja, a.nombre_cajera, a.hora_turno, a.turno, a.descCaja, a.turnoEstado union all select all 'B', a.caja, a.turno, a.fp_codigo, sum(monto_pagado) monto, 0 nc_pos, 0, a.nombre_cajera , a.hora_turno, a.forma_pago, '','' from ( select distinct fp.sec_trans_fp,decode (tp.anulada,'S','** ANULADO **','N',null) estatus_recibo,tp.recibo,fp.monto monto_pagado,tp.caja,'INICIO DE TURNO: '|| to_char (ct.hora_inicio, 'HH:MI:SS AM')|| ' FIN DE TURNO: '|| to_char (ct.hora_final, 'HH:MI:SS AM')hora_turno,'CAJER@: ' || cca.nombre nombre_cajera,tp.turno,cfp.descripcion forma_pago,fp.fp_codigo, cc.descripcion nombre_caja,cc.ubicacion,fp.tipo_tarjeta,tp.tipo_cliente from tbl_cja_transaccion_pago tp,tbl_cja_trans_forma_pagos fp,tbl_cja_cajera cca,tbl_cja_turnos ct,tbl_cja_cajas cc,tbl_cja_turnos_x_cajas ctxc,tbl_cja_forma_pago cfp where tp.compania = fp.compania(+) and tp.anio = fp.tran_anio(+) and tp.codigo = fp.tran_codigo(+) and fp.fp_codigo <> 0 and tp.compania = ctxc.compania and tp.caja = ctxc.cod_caja and tp.turno = ctxc.cod_turno and tp.compania = cc.compania and tp.caja = cc.codigo and cc.compania = ctxc.compania and cc.codigo = ctxc.cod_caja and ct.compania = ctxc.compania and ct.codigo = ctxc.cod_turno and cca.cod_cajera = ct.cja_cajera_cod_cajera and cca.compania = ct.compania and cfp.codigo(+) = fp.fp_codigo ");
if(!fecha_ini.trim().equals("")){sql.append(" and tp.fecha >= to_date('");sql.append(fecha_ini);sql.append("','dd/mm/yyyy')");}
if(!fecha_fin.trim().equals("")){sql.append(" and tp.fecha <= to_date('");sql.append(fecha_fin);sql.append("','dd/mm/yyyy')");}
if(!caja.trim().equals("")){sql.append(" and tp.caja=");sql.append(caja);}
if(!turno.trim().equals("")){sql.append(" and tp.turno=");sql.append(turno);}
sql.append(" and tp.compania=");sql.append(compania);

sql.append(" /*and tp.impreso = 'N' and tp.status = 'C'*/ and cc.estado = 'A' and nvl(tp.rec_status, 'A') <> 'I' and ctxc.estatus = '");
sql.append(estatus);
sql.append("' union all select distinct fp.sec_trans_fp, null estatus_recibo, to_char(tp.doc_id) recibo, -fp.monto monto_pagado, tp.cod_caja, 'INICIO DE TURNO: ' || to_char (ct.hora_inicio, 'HH:MI:SS AM') || ' FIN DE TURNO: ' || to_char(ct.hora_final, 'HH:MI:SS AM') hora_turno, 'CAJER@: ' || cca.nombre nombre_cajera, tp.turno, cfp.descripcion || ' NC' forma_pago, fp.fp_codigo, cc.descripcion nombre_caja, cc.ubicacion, fp.tipo_tarjeta, 'O' tipo_cliente from tbl_fac_trx tp, tbl_fac_trx_forma_pagos fp, tbl_cja_cajera cca, tbl_cja_turnos ct, tbl_cja_cajas cc, tbl_cja_turnos_x_cajas ctxc, tbl_cja_forma_pago cfp where tp.company_id = fp.compania(+) and tp.doc_id = fp.doc_id(+) and tp.doc_type = 'NCR' and fp.fp_codigo <> 0 and tp.company_id = ctxc.compania and tp.cod_caja = ctxc.cod_caja and tp.turno = ctxc.cod_turno and tp.company_id = cc.compania and tp.cod_caja = cc.codigo and cc.compania = ctxc.compania and cc.codigo = ctxc.cod_caja and ct.compania = ctxc.compania and ct.codigo = ctxc.cod_turno and cca.cod_cajera = ct.cja_cajera_cod_cajera and cca.compania = ct.compania and cfp.codigo(+) = fp.fp_codigo");
if(!fecha_ini.trim().equals("")){sql.append(" and trunc (tp.doc_date) >= to_date('");sql.append(fecha_ini);sql.append("','dd/mm/yyyy')");}
if(!fecha_fin.trim().equals("")){sql.append(" and trunc (tp.doc_date) <= to_date('");sql.append(fecha_fin);sql.append("','dd/mm/yyyy')");}
if(!caja.trim().equals("")){sql.append(" and tp.cod_caja=");sql.append(caja);}
if(!turno.trim().equals("")){sql.append(" and tp.turno=");sql.append(turno);}
sql.append(" and tp.company_id = ");
sql.append(compania);
sql.append("/*and tp.impreso = 'N'and tp.status = 'C'*/ and cc.estado = 'A' and ctxc.estatus = 'A' order by 3 )a group by a.forma_pago,a.fp_codigo,a.caja,a.nombre_cajera ,a.hora_turno,a.turno order by 2,3,1,4 ");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "PRELIMINAR DE CAJA";
	String subtitle = "";
	String xtraSubtitle ="";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 7;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
					dHeader.addElement(".25");
					dHeader.addElement(".20");
					dHeader.addElement(".30");
					dHeader.addElement(".25");



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
	Double monto =0.0,aplicado =0.0,totalTurno =0.0,totalCaja =0.0,montoTotal =0.00;
	boolean printTotal = false;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);



		if(cdo.getColValue("tipo").trim().equals("A"))
		{
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")) && i!=0)
			{
				pc.setFont(fontSize, 0,Color.blue);
				pc.addCols("Totales ---------------------->",0,1);

				pc.addCols(""+CmnMgr.getFormattedDecimal(montoTotal),2,1);
				pc.addCols("",2,2);
				montoTotal = 0.00;
				pc.addCols(" ",0,dHeader.size());

			}

			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")))
			{	pc.setFont(fontSize, 0,Color.blue);
				pc.addCols("CAJA:   "+cdo.getColValue("caja"),0,2);
				pc.addCols(""+cdo.getColValue("descCaja"),0,2);

				//pc.addCols("TOTAL RECAUDADO POR CAJA:   "+CmnMgr.getFormattedDecimal(totalCaja),0,dHeader.size());
				//totalCaja=0.00;
			}



			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("caja")+"-"+cdo.getColValue("turno")))
			{	pc.setFont(fontSize, 0);
				pc.addCols("TURNO:       "+cdo.getColValue("turno"),0,1);
				pc.addCols("ESTADO:      "+cdo.getColValue("turnoEstado"),0,1);
				pc.addCols(""+cdo.getColValue("hora_turno"),0,2);

				pc.addCols(""+cdo.getColValue("nombre_cajera"),0,dHeader.size());

				pc.addCols("TOTAL RECAUDADO POR TURNO:   ",0,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("pagoTotal")),0,1);

				pc.addCols("RECIBOS:   "+cdo.getColValue("recibos"),0,2);

				if(Double.parseDouble(cdo.getColValue("nc_pos"))!=0.00){
					pc.addCols("Notas de Credito Otros Ingresos",0,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("nc_pos")),0,1);
					pc.addCols("",0,2);
				}

				printTotal=false;
			}


			totalCaja += Double.parseDouble(cdo.getColValue("pagoTotal")) ;
			if(Double.parseDouble(cdo.getColValue("nc_pos"))!=0.00) totalCaja += Double.parseDouble(cdo.getColValue("nc_pos"));

			//totalTurno += Double.parseDouble(cdo.getColValue("pagoTotal")) ;
		}else {
			if (!printTotal)
			{
				pc.setFont(fontSize, 0,Color.blue);
				pc.addCols("TOTAL RECAUDADO POR CAJA:   ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCaja),0,3);
				totalCaja=0.00;
				pc.addCols(" ",0,dHeader.size());
				pc.addCols("RESUMEN POR FORMA DE PAGO",0,dHeader.size());
				printTotal=true;
			}

			pc.setFont(fontSize, 0);
			montoTotal += Double.parseDouble(cdo.getColValue("pagoTotal")) ;

			pc.addCols(""+cdo.getColValue("forma_pago"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("pagoTotal")),2,1);
			pc.addCols(" ",0,2);
			//pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);

		}

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy  = cdo.getColValue("caja");
			groupBy3  = cdo.getColValue("caja");
			groupBy2 = cdo.getColValue("caja")+"-"+cdo.getColValue("turno");
	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			//pc.addCols("TOTAL RECAUDADO POR CAJA:   "+CmnMgr.getFormattedDecimal(totalCaja),0,dHeader.size());
			pc.setFont(fontSize, 0,Color.blue);
			pc.addCols("Totales ---------------------->",0,1);

			pc.addCols(""+CmnMgr.getFormattedDecimal(montoTotal),2,1);
			pc.addCols("",2,2);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>