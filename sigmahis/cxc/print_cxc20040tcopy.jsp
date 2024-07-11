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

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sala = request.getParameter("sala");
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
if(sala == null) sala ="";
if(refType == null) refType ="";
if(subRefType == null) subRefType ="";
if(mostrar_factura == null) mostrar_factura ="";
if(ex_tipo_clte == null) ex_tipo_clte ="";
if(ex_sub_tipo_clte == null) ex_sub_tipo_clte ="";
sbSql.append("select get_sec_comp_param(-1, 'TP_CLIENTE_OTROS') TP_CLIENTE_OTROS from dual");
CommonDataObject _cd = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select decode(m.tipo_cta, 'A', 2, 1) as tipo, nvl (m.nombre, nvl ((select si.nombre from tbl_cxc_saldo_inicial si where si.tipo_ref = m.ref_type and si.compania = m.cia and si.id_cliente = m.ref_id and rownum = 1), ' ')) as nombre, nvl(m.aseguradora, 0) aseguradora, nvl(m.categoria, 0) categoria, nvl (m.tipo_cta, ' ') || decode(m.tipo_cta, 'A', '-' || nvl(m.aseguradora, 0), '') as tipo_cta, nvl((select nombre from tbl_adm_empresa e where e.codigo = m.aseguradora), 'PAGO NO APLICADO') nombre_aseguradora, decode(m.tipo_cta, 'M', 'MEDICO', 'A', 'ASEGURADORA', 'J', 'JUBILADO', 'P', 'PARTICULAR', 'N', 'JUNTA DIRECTIVA', 'E', 'EMPLEADO', 'O', 'OTROS CLIENTES', 'X', 'DETALLE AUX.') as desc_tipocta, decode(m.tipo_cta, 'A', 2, 1) || '-' || m.categoria || '-' || m.tipo_cta || decode(m.tipo_cta, 'A', '-' || nvl(m.aseguradora, 0), '') as key, m.categoria || ' ' || nvl(ca.descripcion, ' ') desccategoria, nvl(m.cia, 0) ciap, nvl (m.cedula, ' ') cedula, nvl(to_char(m.f_admision, 'dd/mm/yyyy'), ' ') f_admision, nvl(to_char (m.f_factura, 'dd/mm/yyyy'), ' ') f_factura, nvl(m.scorriente, 0) s_corriente, nvl(m.s30, 0) s30, nvl(m.s60, 0) s60, nvl(m.s90, 0) s90, nvl(m.s120, 0) s120, nvl(m.s150, 0) s150, nvl(m.factura, 0) factura, nvl(m.deb, 0) debito, nvl(m.cre, 0) credito, nvl(m.saldo_ant, 0) sal_anterior, nvl(m.estado_cobros, ' ') estado_cobros, (nvl(m.scorriente, 0) + nvl(m.s30, 0) + nvl(m.s60, 0) + nvl(m.s90, 0) + nvl(m.s120, 0) + nvl(m.s150, 0)) saldo_actual, nvl(ca.descripcion, ' ') as descripcion, decode(m.tipo_cta, 'A', nvl((select e.nombre from tbl_adm_empresa e where m.aseguradora = e.codigo), ' '), '') as desc_empresa, decode(nvl(f.enviado, 'N'), 'S', to_char(nvl(f.fecha_entrega_lista,f.fecha_envio), 'dd/mm/yyyy'), (case when facturar_a = 'P' or (facturar_a = 'E' and nvl(comentario, 'NA') = 'S/I') then to_char(fecha_enviado, 'dd/mm/yyyy') else ' ' end)) fecha_envio, (select distinct poliza from tbl_adm_beneficios_x_admision ba where ba.prioridad = 1 and ba.estado = 'A' and ba.pac_id = f.pac_id and ba.admision = f.admi_secuencia) poliza, (select   distinct certificado from   tbl_adm_beneficios_x_admision ba where ba.prioridad = 1 and ba.estado = 'A' and ba.pac_id = f.pac_id and ba.admision = f.admi_secuencia) certificado, (select descripcion from tbl_fac_tipo_cliente where codigo = m.ref_type and compania = m.cia) refdesc, f.pac_id || '-' || f.admi_secuencia as id_cliente from tbl_cxc_morosidades m, tbl_adm_categoria_admision ca, tbl_fac_factura f where m.factura = f.codigo(+) and m.cia = f.compania(+) and m.categoria = ca.codigo(+) and (nvl(m.scorriente, 0) + nvl(m.s30, 0) + nvl(m.s60, 0) + nvl(m.s90, 0) + nvl(m.s120, 0) + nvl(m.s150, 0)) <> 0 and m.fg IN ('MOR', 'RNA')");


sbSql.append(" and m.cia = ");
sbSql.append(compania);

if(!tipo_cta.equals("")){
	if (tipo_cta.trim().equals("A"))
	sbSql.append(" and m.tipo_cta in('A','J')");
	else if (tipo_cta.trim().equals("P"))
	sbSql.append(" and m.tipo_cta = 'P'");
	else {
		sbSql.append(" and m.tipo_cta = '");
		sbSql.append(tipo_cta);
		sbSql.append("'");
	}
}
if (!refType.trim().equals("")) {
sbSql.append(" and m.ref_type =");
sbSql.append(refType);
}

if (/*tipo_cta.trim().equals("A") && */!aseguradora.trim().equals("")){
sbSql.append(" and m.aseguradora = ");
sbSql.append(aseguradora);

}
if (!categoria.trim().equals("")){
sbSql.append(" and m.categoria = ");
sbSql.append(categoria);
}

if (mostrar_factura.trim().equals("E")){
	sbSql.append(" and (nvl(f.enviado, 'N') = 'S' or f.facturar_a = 'P' or f.facturar_a = 'P' or (f.facturar_a in ('E', 'P') and nvl(substr(f.comentario, 1, 3), 'NA') = 'S/I'))");
} else if (mostrar_factura.trim().equals("N")){
	sbSql.append(" and (nvl(f.enviado, 'N') = 'N' and f.facturar_a != 'P' and nvl(substr(f.comentario, 1, 3), 'NA') != 'S/I')");
}


sbSql.append(" and to_date(m.fecha,'dd/mm/yyyy') <= to_date('");
sbSql.append(fecha_inicial);
sbSql.append("' ,'dd/mm/yyyy')");
if (!pacId.trim().equals("")&&!tipo_cta.trim().equals("O")){
sbSql.append(" and m.pac_id = ");
sbSql.append(pacId);
}else  if (!pacId.trim().equals("")&&tipo_cta.trim().equals("O")){sbSql.append(" and m.ref_id = '");
sbSql.append(pacId);
sbSql.append("'");
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

sbSql.append(" union all ");
sbSql.append("  select 1 as tipo, nvl(m.nombre, nvl((select si.nombre from tbl_cxc_saldo_inicial si where si.tipo_ref = m.ref_type and si.compania = m.cia and si.id_cliente = m.ref_id and rownum = 1),' ')) nombre, m.aseguradora aseguradora, m.categoria, NVL(m.tipo_cta,' ') tipo_cta, nvl((select nombre from tbl_adm_empresa e where e.codigo = m.aseguradora), 'PAGO NO APLICADO') nombre_aseguradora, decode(m.tipo_cta,'M','MEDICO','A','ASEGURADORA','J' ,'JUBILADO','P','PARTICULAR','N','JUNTA DIRECTIVA','E','EMPLEADO','O','OTROS CLIENTES','X','DETALLE AUX.') as desc_tipocta,1||'-'||m.categoria||'-'||m.tipo_cta as key,m.categoria||' ' descCategoria,m.cia ciap, m.cedula ,to_char(m.f_admision,'dd/mm/yyyy') f_admision,to_char(m.f_factura,'dd/mm/yyyy') f_factura, nvl(m.scorriente,0) s_corriente, nvl(m.s30,0) s30, nvl(m.s60,0) s60, nvl(m.s90,0) s90, nvl(m.s120,0) s120,  nvl(m.s150,0) s150, nvl(m.factura,' ') factura,nvl(m.deb,0) debito,nvl(m.cre,0) credito,nvl(m.saldo_ant,0) sal_anterior,nvl(m.estado_cobros,' ')estado_cobros,(nvl(scorriente,0) + nvl(s30,0) + nvl(s60,0) + nvl(s90,0) + nvl(s120,0) + nvl(s150,0))  saldo_actual,' ' descripcion, ' ' as desc_empresa, ' ' fecha_envio,' ' poliza, ' ' certificado,(select descripcion from tbl_fac_tipo_cliente where codigo=m.ref_type and compania=m.cia) refDesc, ' ' as id_cliente from tbl_cxc_morosidades m where  (nvl(m.scorriente, 0) + nvl(m.s30, 0) + nvl(m.s60, 0) + nvl(m.s90, 0) + nvl(m.s120, 0) + nvl(m.s150, 0)) <> 0  and m.fg IN ('AUX') and m.cia = ");
sbSql.append(compania);
sbSql.append(" and to_date(m.fecha,'dd/mm/yyyy') <= to_date('");
sbSql.append(fecha_inicial);
sbSql.append("' ,'dd/mm/yyyy') ");

if (!refType.trim().equals("")) {
sbSql.append(" and m.ref_type =");
sbSql.append(refType);
}

if (!pacId.trim().equals("")){
sbSql.append(" and m.ref_id = '");
sbSql.append(pacId);
sbSql.append("'");}

if (!aseguradora.trim().equals("")){
sbSql.append(" and m.aseguradora = ");
sbSql.append(aseguradora);
}
if(!tipo_cta.equals("")){
	if(tipo_cta.equals("A")){
		sbSql.append(" and to_char(m.ref_type) = get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(", 'TP_CLIENTE_EMP')");
	} else if(tipo_cta.equals("P")){
		sbSql.append(" and to_char(m.ref_type) = get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(", 'TP_CLIENTE_PAC')");
	} else if(tipo_cta.equals("O")){
		sbSql.append(" and tipo_cta = 'X'");
	}
}

if(tipo_cta.trim().equals("O"))sbSql.append(" order by 5,2 asc");
else if(tipo_cta.trim().equals("P"))sbSql.append(" order by 1,6,3,4,2 asc");
else sbSql.append(" order by 1,3,4,2 asc");
al = SQLMgr.getDataList(sbSql.toString());

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
	float height = 72 * 14f;//792
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
	String title = "REPORTE DE MOROSIDAD";
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


		double saldo_anterior_tipo = 0,saldo_debito_tipo = 0,saldo_credito_tipo = 0,saldo_actual_tipo = 0,saldo_corriente_tipo = 0,saldo_a30_tipo = 0,saldo_a60_tipo = 0;
		double saldo_a90_tipo = 0,saldo_a120_tipo = 0,saldo_a150_tipo = 0;

		double saldo_anterior_cat = 0,saldo_debito_cat = 0,saldo_credito_cat  = 0,saldo_actual_cat  = 0,saldo_corriente_cat = 0;
		double saldo_a30_cat  = 0,saldo_a60_cat  = 0,saldo_a90_cat  = 0,saldo_a120_cat  = 0,saldo_a150_cat  = 0;

		double sub_saldo_anterior  = 0,sub_saldo_debito = 0,sub_saldo_credito =0,sub_saldo_actual=0,sub_saldo_corriente = 0;
		double sub_saldo_a30  = 0,sub_saldo_a60 = 0,sub_saldo_a90 = 0,sub_saldo_a120 = 0,sub_saldo_a150 = 0;

		double saldo_anterior_final = 0,saldo_debito_final = 0,saldo_credito_final =0,saldo_actual_final=0,saldo_corriente_final = 0;
		double saldo_a30_final  = 0,saldo_a60_final = 0,saldo_a90_final = 0,saldo_a120_final = 0,saldo_a150_final = 0,sal_anterior=0;
		double tsub_saldo_actual = 0, tsub_saldo_corriente = 0, tsub_saldo_a30 = 0, tsub_saldo_a60 = 0, tsub_saldo_a90 = 0, tsub_saldo_a120 = 0, tsub_saldo_a150 = 0;

				Vector dHeader=new Vector();
				  dHeader.addElement(".05");
				  dHeader.addElement(".14");
					dHeader.addElement(".08");
					dHeader.addElement(".05");
					dHeader.addElement(".05");
					dHeader.addElement(".05");
					dHeader.addElement(".05");
					dHeader.addElement(".08");
					dHeader.addElement(".08");
					//dHeader.addElement(".05");
					//dHeader.addElement(".04");
					//dHeader.addElement(".04");
					dHeader.addElement(".06");
					dHeader.addElement(".06");
					dHeader.addElement(".06");
					dHeader.addElement(".06");
					dHeader.addElement(".06");
					dHeader.addElement(".06");
					dHeader.addElement(".06");



				pc.setNoColumnFixWidth(dHeader);
				pc.createTable();
				pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

				pc.setFont(headerFontSize,1);
				pc.addBorderCols("Nombre del Paciente",0,2);
				pc.addBorderCols("Cédula/Ruc",0);
				if(!tipo_cta.trim().equals("O"))pc.addBorderCols("F. Adm.",0);
				else pc.addBorderCols(" ",0);
				pc.addBorderCols("F. Factura",0);
				pc.addBorderCols("Factura #",0);
				if(!tipo_cta.trim().equals("O")){pc.addBorderCols("F. Envio",0);
				pc.addBorderCols("Poliza",0);
				pc.addBorderCols("Certificado",0);}
				else pc.addBorderCols(" Tipo Cliente",0,3);
				//pc.addBorderCols("S. Anterior",2);
				//pc.addBorderCols("Debito",2);
				//pc.addBorderCols("Credito",2);
				pc.addBorderCols("S. Actual",2);
				pc.addBorderCols("Corriente",2);
				pc.addBorderCols("A 30 dias",2);
				pc.addBorderCols("A 60 dias",2);
				pc.addBorderCols("A 90 dias",2);
				pc.addBorderCols("A 120 dias",2);
				pc.addBorderCols("A 150 dias",2);

				pc.setTableHeader(2);//create de table header

			//table body
			String groupBy = "", groupBy2 = "", groupBy3="", groupBy4="";
			String groupTitle = "",groupTitle2 = "",groupTitle3="";
			String tipo="";
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i);

				if (!groupBy2.equalsIgnoreCase(cdo1.getColValue("categoria")))
				{
					if (i != 0)
					{
						pc.setFont(8, 1,Color.blue);
						pc.addCols("Total x categoria "+groupTitle2,0,9);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_actual_cat), 2,1);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_corriente_cat), 2,1);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a30_cat), 2,1);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a60_cat), 2,1);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a90_cat), 2,1);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a120_cat), 2,1);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a150_cat), 2,1);

						saldo_anterior_cat = 0;
						saldo_debito_cat = 0;saldo_credito_cat  = 0;saldo_actual_cat  = 0;saldo_corriente_cat = 0;
						saldo_a30_cat  = 0;saldo_a60_cat  = 0;saldo_a90_cat  = 0;saldo_a120_cat  = 0;saldo_a150_cat  = 0;
					}
			  }
				if (!groupBy4.equalsIgnoreCase(cdo1.getColValue("nombre_aseguradora")) && tipo_cta.equals("P"))
				{
					if (i != 0)
					{
						pc.setFont(8, 1,Color.blue);
						pc.addCols(" TOTAL "+groupBy4, 0,9);

						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_actual), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_corriente), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a30), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a60), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a90), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a120), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a150), 2,1);

						pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,0.0f);

						tsub_saldo_actual = 0; tsub_saldo_corriente = 0; tsub_saldo_a30 = 0;
						tsub_saldo_a60 = 0; tsub_saldo_a90 = 0; tsub_saldo_a120 = 0; tsub_saldo_a150 = 0;
					}
			  }				
				if (!groupBy.equalsIgnoreCase(cdo1.getColValue("tipo_cta")+"-"+cdo1.getColValue("aseguradora")))
				{
					if (i != 0)
					{
						pc.setFont(8, 1,Color.blue);
						pc.addCols("TOTAL X "+groupTitle, 0,9);

						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_actual_tipo), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_corriente_tipo), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a30_tipo), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a60_tipo), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a90_tipo), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a120_tipo), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a150_tipo), 2,1);

						pc.addCols(" ",0,dHeader.size());

						saldo_anterior_tipo = 0;saldo_debito_tipo = 0;saldo_credito_tipo = 0;
						saldo_actual_tipo = 0;saldo_corriente_tipo = 0;saldo_a30_tipo = 0;
						saldo_a60_tipo = 0;saldo_a90_tipo = 0;saldo_a120_tipo = 0;saldo_a150_tipo = 0;
					}


			  }// x aseg.

				if (!groupBy3.equalsIgnoreCase(cdo1.getColValue("tipo")))
				{
					if (i != 0)
					{
						pc.setFont(8, 1,Color.blue);
						pc.addCols(" "+groupTitle3, 0,9);

						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_actual), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_corriente), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a30), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a60), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a90), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a120), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a150), 2,1);

						pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,0.0f);

						sub_saldo_anterior = 0;sub_saldo_debito = 0;sub_saldo_credito = 0;
						sub_saldo_actual = 0;sub_saldo_corriente = 0;sub_saldo_a30 = 0;
						sub_saldo_a60 = 0;sub_saldo_a90 = 0;sub_saldo_a120 = 0;sub_saldo_a150 = 0;
					}
			  }


				if (!groupBy.equalsIgnoreCase(cdo1.getColValue("tipo_cta")+"-"+cdo1.getColValue("aseguradora")))
				{
					pc.setFont(8, 1,Color.blue);
					if(cdo1.getColValue("tipo").trim().equals("1"))	groupTitle  =  cdo1.getColValue("desc_tipocta");
					else groupTitle  =  cdo1.getColValue("desc_tipocta")+"  "+cdo1.getColValue("aseguradora")+" "+cdo1.getColValue("desc_empresa");

					pc.addCols("TIPO:  "+groupTitle, 0,dHeader.size());
					groupTitle2 = cdo1.getColValue("descCategoria");
				}
				if (!groupBy4.equalsIgnoreCase(cdo1.getColValue("nombre_aseguradora")) && tipo_cta.equals("P"))
				{
					pc.addCols("ASEGURADORA:  "+cdo1.getColValue("nombre_aseguradora"), 0,dHeader.size());
				}
				if (!groupBy2.equalsIgnoreCase(cdo1.getColValue("categoria")))
				{
					pc.addCols("CATEGORIA:  "+cdo1.getColValue("descCategoria"), 0,dHeader.size());
				}





				  pc.setFont(8, 0);
					pc.addCols(""+cdo1.getColValue("id_cliente"),0,1);
					pc.addCols(""+cdo1.getColValue("nombre"),0,1);
					pc.addCols(""+cdo1.getColValue("cedula"),0,1);
					pc.addCols(""+cdo1.getColValue("f_admision"),0,1);
					pc.addCols(""+cdo1.getColValue("f_factura"),0,1);
					pc.addCols(""+cdo1.getColValue("factura"),0,1);
					if(!tipo_cta.trim().equals("O")){

					pc.addCols(""+cdo1.getColValue("fecha_envio"),0,1);
					pc.addCols(""+cdo1.getColValue("poliza"),0,1);
					pc.addCols(""+cdo1.getColValue("certificado"),0,1);}
					else pc.addCols(""+cdo1.getColValue("refDesc"),0,3);


					sal_anterior = Double.parseDouble(cdo1.getColValue("saldo_actual"))-Double.parseDouble(cdo1.getColValue("debito"))+Double.parseDouble(cdo1.getColValue("credito"));


					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_actual")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s_corriente")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s30")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s60")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s90")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s120")),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s150")),2,1);

					groupTitle2 =  cdo1.getColValue("descCategoria");
					//groupTitle  =  cdo1.getColValue("desc_tipocta")+"-"+cdo1.getColValue("desc_empresa");
					groupBy     = cdo1.getColValue("tipo_cta")+"-"+cdo1.getColValue("aseguradora");
					groupBy2    = cdo1.getColValue("categoria");
					tipo        = cdo1.getColValue("tipo");
					groupBy3    = cdo1.getColValue("tipo");
					groupBy4		= cdo1.getColValue("nombre_aseguradora");

					if(!tipo_cta.trim().equals("O")){if(tipo.trim().equals("1"))
					groupTitle3  = "TOTAL DE PARTICULAR(todo lo que no es aseguradora)";
					else groupTitle3  = "TOTAL ASEGURADORA";}
					else groupTitle3  = "TOTAL DE OTROS CLIENTES";



					saldo_anterior_final  		+= sal_anterior;
					saldo_debito_final    		+= Double.parseDouble(cdo1.getColValue("debito"));
					saldo_credito_final   		+= Double.parseDouble(cdo1.getColValue("credito"));
					saldo_actual_final  			+= Double.parseDouble(cdo1.getColValue("saldo_actual"));
					saldo_corriente_final  	  += Double.parseDouble(cdo1.getColValue("s_corriente"));
					saldo_a30_final						+= Double.parseDouble(cdo1.getColValue("s30"));
					saldo_a60_final						+= Double.parseDouble(cdo1.getColValue("s60"));
					saldo_a90_final						+= Double.parseDouble(cdo1.getColValue("s90"));
					saldo_a120_final					+= Double.parseDouble(cdo1.getColValue("s120"));
					saldo_a150_final					+= Double.parseDouble(cdo1.getColValue("s150"));


					saldo_anterior_cat        += sal_anterior;
					saldo_debito_cat          += Double.parseDouble(cdo1.getColValue("debito"));
					saldo_credito_cat         += Double.parseDouble(cdo1.getColValue("credito"));
					saldo_actual_cat          += Double.parseDouble(cdo1.getColValue("saldo_actual"));
					saldo_corriente_cat       += Double.parseDouble(cdo1.getColValue("s_corriente"));
					saldo_a30_cat             += Double.parseDouble(cdo1.getColValue("s30"));
					saldo_a60_cat             += Double.parseDouble(cdo1.getColValue("s60"));
					saldo_a90_cat             += Double.parseDouble(cdo1.getColValue("s90"));
					saldo_a120_cat            += Double.parseDouble(cdo1.getColValue("s120"));
					saldo_a150_cat            += Double.parseDouble(cdo1.getColValue("s150"));

					saldo_anterior_tipo       += sal_anterior;
					saldo_debito_tipo         += Double.parseDouble(cdo1.getColValue("debito"));
					saldo_credito_tipo        += Double.parseDouble(cdo1.getColValue("credito"));
					saldo_actual_tipo         += Double.parseDouble(cdo1.getColValue("saldo_actual"));
					saldo_corriente_tipo      += Double.parseDouble(cdo1.getColValue("s_corriente"));
					saldo_a30_tipo            += Double.parseDouble(cdo1.getColValue("s30"));
					saldo_a60_tipo            += Double.parseDouble(cdo1.getColValue("s60"));
					saldo_a90_tipo            += Double.parseDouble(cdo1.getColValue("s90"));
					saldo_a120_tipo           += Double.parseDouble(cdo1.getColValue("s120"));
					saldo_a150_tipo           += Double.parseDouble(cdo1.getColValue("s150"));

					sub_saldo_anterior        += sal_anterior;
					sub_saldo_debito          += Double.parseDouble(cdo1.getColValue("debito"));
					sub_saldo_credito         += Double.parseDouble(cdo1.getColValue("credito"));
					sub_saldo_actual          += Double.parseDouble(cdo1.getColValue("saldo_actual"));
					sub_saldo_corriente       += Double.parseDouble(cdo1.getColValue("s_corriente"));
					sub_saldo_a30             += Double.parseDouble(cdo1.getColValue("s30"));
					sub_saldo_a60             += Double.parseDouble(cdo1.getColValue("s60"));
					sub_saldo_a90             += Double.parseDouble(cdo1.getColValue("s90"));
					sub_saldo_a120            += Double.parseDouble(cdo1.getColValue("s120"));
					sub_saldo_a150            += Double.parseDouble(cdo1.getColValue("s150"));

					tsub_saldo_actual          += Double.parseDouble(cdo1.getColValue("saldo_actual"));
					tsub_saldo_corriente       += Double.parseDouble(cdo1.getColValue("s_corriente"));
					tsub_saldo_a30             += Double.parseDouble(cdo1.getColValue("s30"));
					tsub_saldo_a60             += Double.parseDouble(cdo1.getColValue("s60"));
					tsub_saldo_a90             += Double.parseDouble(cdo1.getColValue("s90"));
					tsub_saldo_a120            += Double.parseDouble(cdo1.getColValue("s120"));
					tsub_saldo_a150            += Double.parseDouble(cdo1.getColValue("s150"));


		}

		if (al.size()==0)pc.addCols("No existe Registros para este Reporte ",1,dHeader.size());
		else
		{

				pc.setFont(8, 1,Color.blue);
				if(!tipo_cta.trim().equals("O")){
				pc.addCols("Total x categoria "+groupTitle2,0,9);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_actual_cat), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_corriente_cat), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a30_cat), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a60_cat), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a90_cat), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a120_cat), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a150_cat), 2,1);

				}

				if (tipo_cta.equals("P"))
				{
						pc.setFont(8, 1,Color.blue);
						pc.addCols(" TOTAL "+groupBy4, 0,9);

						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_actual), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_corriente), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a30), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a60), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a90), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a120), 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(tsub_saldo_a150), 2,1);

						pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,0.0f);
			  }

				pc.setFont(8, 1,Color.blue);
				pc.addCols("TOTAL X "+groupTitle, 0,9);

				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_actual_tipo), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_corriente_tipo), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a30_tipo), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a60_tipo), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a90_tipo), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a120_tipo), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(saldo_a150_tipo), 2,1);

				pc.addCols(" ",0,dHeader.size());

				pc.setFont(8, 1,Color.blue);
				pc.addCols(" "+groupTitle3, 0,9);

				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_actual), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_corriente), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a30), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a60), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a90), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a120), 2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(sub_saldo_a150), 2,1);

				pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,0.0f);
				pc.setFont(8, 0);
				pc.addBorderCols(" ",0,9);

				pc.addBorderCols("S. Actual",2,1);
				pc.addBorderCols("Corriente",2,1);
				pc.addBorderCols("A 30 dias",2,1);
				pc.addBorderCols("A 60 dias",2,1);
				pc.addBorderCols("A 90 dias",2,1);
				pc.addBorderCols("A 120 dias",2,1);
				pc.addBorderCols("A +150 dias",2,1);

				pc.setFont(8, 1,Color.blue);
				pc.addCols("TOTALES ", 0,9);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_actual_final),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_corriente_final), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a30_final), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a60_final), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a90_final), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a120_final), 2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo_a150_final), 2,1);


		}



pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

