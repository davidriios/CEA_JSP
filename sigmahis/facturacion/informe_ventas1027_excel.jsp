<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.*" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page pageEncoding="UTF-8" contentType="application-/vnd.ms-excel charset=UTF-8"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String fp= request.getParameter("fp");
String fg= request.getParameter("fg");
String index = request.getParameter("index");
String nt = request.getParameter("nt");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String factura_dgi = request.getParameter("factura_dgi");
String tipo_doc = request.getParameter("tipo_doc");
String tipo_emision = request.getParameter("tipo_emision");
String cod_sucursal = request.getParameter("cod_sucursal");
String punto_de_fact = request.getParameter("punto_de_fact");
String tipo_de_contr = request.getParameter("tipo_de_contr");
String ruc_emisor = request.getParameter("ruc_emisor");
String dv_emisor = request.getParameter("dv_emisor");
String razon_social_emi = request.getParameter("razon_social_emi");
String codigo = request.getParameter("codigo");
String razon_social_rec = request.getParameter("razon_social_rec");
String tipo_receptor = request.getParameter("tipo_receptor");
String id_pasaporte = request.getParameter("id_pasaporte");
String pais_recep = request.getParameter("pais_recep");
String sum_items = request.getParameter("sum_items");
String itbms = request.getParameter("itbms");
String valor_isc = request.getParameter("valor_isc");
String t_impuestos = request.getParameter("t_impuestos");
String impreso = request.getParameter("impreso");
String ruc_receptor =request.getParameter("ruc_receptor");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbPrintListFilter = new StringBuffer();

int iconHeight = touch.equalsIgnoreCase("y")?36:20;
int iconWidth = touch.equalsIgnoreCase("y")?36:20;
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(fecha_ini==null) fecha_ini = fecha;
if(fecha_fin==null) fecha_fin = fecha;
if(factura_dgi==null) factura_dgi = "";
if(tipo_doc==null) tipo_doc = "";
if(tipo_emision==null) tipo_emision = "";
if(cod_sucursal==null) cod_sucursal = "";
if(punto_de_fact==null) punto_de_fact = "";
if(tipo_de_contr==null) tipo_de_contr = "";
if(dv_emisor==null) dv_emisor = "";
if(razon_social_emi==null) razon_social_emi = "";
if(codigo==null) codigo = "";
if(razon_social_rec==null) razon_social_rec = "";
if(tipo_receptor==null) tipo_receptor = "";
if(id_pasaporte==null) id_pasaporte = "";
if(pais_recep==null) pais_recep = "";
if(sum_items==null) sum_items = "";
if(itbms==null) itbms = "";
if(valor_isc==null) valor_isc = "";
if(t_impuestos==null) t_impuestos = "";
if(impreso==null) impreso = "";
if(ruc_receptor==null) ruc_receptor = "";
if(fp==null) fp = "";
if(fg==null) fg = "";

StringBuffer sbCaja = new StringBuffer();
StringBuffer sbUsuario = new StringBuffer();
if (UserDet.getUserProfile().contains("0")) {
	sbCaja.append("select codigo id, trim(to_char(codigo,'009')) ||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
	sbCaja.append((String) session.getAttribute("_companyId"));
	sbCaja.append(" and estado = 'A' order by descripcion");
} else {
	sbCaja.append("select codigo id, trim(to_char(codigo,'009')) ||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
	sbCaja.append((String) session.getAttribute("_companyId"));
	sbCaja.append(" and codigo in (");
	sbCaja.append((String) session.getAttribute("_codCaja"));
	sbCaja.append(") and ip = '");
	sbCaja.append(request.getRemoteAddr());
	sbCaja.append("' and estado = 'A' order by descripcion");
}
sbUsuario.append("select user_name, name from tbl_sec_users u where user_status = 'A' and exists (select null from tbl_cja_cajera c where compania = ");
sbUsuario.append((String) session.getAttribute("_companyId"));
sbUsuario.append(" and c.usuario = u.user_name) order by name");

	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'FAC_IMPRESO_SI_DGI'),'N') as impresoSi from dual");
	if (p == null) {

		p = new CommonDataObject();
		p.addColValue("impresoSi","N");

	}
	int recsPerPage=100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
	if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
	if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!codigo.trim().equals("")){
		sbFilter.append(" and a.codigo like'");
		sbFilter.append(codigo);
		sbFilter.append("'");
	}
	if (!razon_social_rec.trim().equals("")){
		sbFilter.append(" and a.cliente like '%");
		sbFilter.append(razon_social_rec);
		sbFilter.append("%'");
	}
	if (!fecha_ini.trim().equals("")){
		sbFilter.append(" and trunc(a.fecha) >= to_date('");
		sbFilter.append(fecha_ini);
		sbFilter.append("', 'dd/mm/yyyy')");
	}
	if (!fecha_fin.trim().equals("")){
		sbFilter.append(" and trunc(a.fecha) <= to_date('");
		sbFilter.append(fecha_fin);
		sbFilter.append("', 'dd/mm/yyyy')");
	}

	sbPrintListFilter.append(sbFilter.toString());
		sbSql.append("SELECT a.id, decode(a.codigo_dgi, '', a.codigo, a.codigo_dgi, a.codigo_dgi) factura_dgi, decode(a.tipo_docto, 'FACP', '01', 'FACT', '01', 'ND', '07', 'NDP', '07', 'NC', '04', 'NCP', '04') tipo_doc, to_char(a.fecha, 'YYYYMMDD') fecha, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'TIPO_DE_EMISION' ) tipo_emision, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'COD_SUCURSAL' ) cod_sucursal, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'PUNTO_DE_FACT' ) punto_de_fact, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'TIPO_DE_CONTRIBUYENTE' ) tipo_de_contr, c.ruc ruc_emisor, c.digito_verificador dv_emisor, c.nombre razon_social_emi, a.codigo, ( CASE WHEN a.tipo_docto = 'FACT' THEN a.monto - nvl(( SELECT SUM(monto) FROM tbl_fac_detalle_factura f WHERE f.compania = a.compania AND f.fac_codigo = a.codigo AND EXISTS( SELECT NULL FROM tbl_cds_centro_servicio cds WHERE cds.codigo = f.centro_servicio AND cds.tipo_cds = 'T' AND cds.codigo != 0 ) ), 0) ELSE a.monto END ) monto, nvl(a.impuesto, 0) itbms, a.cod_ref, nvl(( SELECT decode(ap.tipo_id_paciente, 'C', '02', 'P', '04') FROM tbl_adm_paciente ap WHERE ap.pac_id = a.pac_id ), '02') tipo_receptor, nvl(a.impreso, 'N') impreso, replace(decode(a.ruc_cedula, 'RUC', '', a.ruc_cedula, a.ruc_cedula), '-D') ruc_receptor, ( CASE WHEN a.facturar_a = 'E' THEN decode(a.cliente, a.cliente, a.campo4) ELSE a.cliente END ) razon_social_rec, ( SELECT ( CASE WHEN ap.tipo_id_paciente = 'C' THEN decode(ap.pasaporte, ap.pasaporte, '') ELSE ap.pasaporte END ) FROM tbl_adm_paciente ap WHERE ap.pac_id = a.pac_id ) id_pasaporte, ( SELECT ( CASE WHEN ap.tipo_id_paciente = 'C' THEN decode(b.nombre, b.nombre, '') ELSE b.nombre END ) FROM tbl_adm_paciente ap, tbl_sec_pais b WHERE ap.nacionalidad = b.codigo AND ap.pac_id = a.pac_id ) pais_recep, nvl(( SELECT SUM(nvl(precio, 0) * nvl(cantidad, 1)) itemtotalprice FROM tbl_fac_dgi_docto_det dd WHERE dd.id = a.id AND dd.compania = a.compania ), a.monto) sum_items, 0 valor_isc, nvl((a.impuesto + 0), 0) t_impuestos, to_char(nvl(a.fecha_impresion, impresion_timestamp), 'dd/mm/yyyy hh12:mi:ss am') fecha_impresion, ( SELECT estatus FROM tbl_fac_factura f WHERE f.codigo = a.codigo AND f.compania = a.compania AND f.estatus <> 'A' ) estado_de_factura, a.facturar_a, a.pac_id FROM tbl_fac_dgi_documents a, tbl_sec_compania c WHERE a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and a.compania = c.codigo");
	if (!impreso.trim().equals("")){
		sbSql.append(" and nvl(a.impreso, 'N') = '");
		sbSql.append(impreso);
		sbSql.append("'");
	 }
		sbSql.append(sbFilter.toString());

		sbSql.append(" order by a.fecha desc, nvl(a.fecha_impresion,impresion_timestamp) desc");
		
		if(request.getParameter("impreso") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) ");

		}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
	
	String nombreArchivo = "INFORME_VENTAS_1027.xls";
    response.setHeader("Content-Disposition","attachment;filename="+nombreArchivo);

%>
<!DOCTYPE html>
<html>
	<head>
		<title>
			Informe De Ventas 1027
		</title>
	</head>
	<body>	
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextHeader">
				<h4>INFORME DE VENTAS 1027</h4>
				<td width="8%" align="center" rowspan="1">N&Uacute;MERO DE FACTURA</td>
		        <td width="4%" align="center" rowspan="1">TIPO DE DOCUMENTO</td>
		        <td width="5%" align="center" rowspan="1">FECHA DE EMISI&Oacute;N</td>
		        <td width="4%" align="center" rowspan="1">TIPO DE EMISI&Oacute;N</td>
		        <td width="4%" align="center" rowspan="1">C&Oacute;DIGO DE SUCURSAL</td>
		        <td width="4%" align="center" rowspan="1">PUNTO DE FACTURACI&Oacute;N</td>
		        <td width="4%" align="center" rowspan="1">TIPO DE CONTRIBUYENTE</td>
		        <td width="9%" align="center" rowspan="1">RUC EMISOR</td>
		        <td width="4%" align="center" rowspan="1">DV DEL RUC</td>
		        <td width="10%" align="center" rowspan="1">RAZ&Oacute;N SOCIAL EMISOR</td>
		        <td width="4%" align="center" rowspan="1">TIPO DE RECEPTOR</td>
		        <td width="9%" align="center" rowspan="1">RUC RECEPTOR</td>
		        <td width="10%" align="center" rowspan="1">RAZ&Oacute;N SOCIAL RECEPTOR</td>
		        <td width="9%" align="center" rowspan="1">IDENTIFICACI&Oacute;N PASAPORTE</td>
		        <td width="6%" align="center" rowspan="1">PA&Iacute;S DEL RECEPTOR</td>
		        <td width="6%" align="center" rowspan="1">SUMATORIA DE ITEMS</td>
		        <td width="6%" align="center" rowspan="1">VALOR ITBMS</td>
		        <td width="6%" align="center" rowspan="1">VALOR ISC</td>
		        <td width="6%" align="center" rowspan="1">SUMA TOTAL DE IMPUESTOS</td>
				<td width="6%" align="center" rowspan="1">VALOR TOTAL DE LA FACTURA</td>
			</tr>
			
			<%
			String flg = "S";
			String color = "";
	         for (int i=0; i<al.size(); i++)
	          {
	            CommonDataObject cdo = (CommonDataObject) al.get(i);
	             color = "TextRow02";
	            if (i % 2 == 0) color = "TextRow01";
            %>

	         <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		          <td align="right"><%=cdo.getColValue("factura_dgi")%></td>
		          <td align="right"><%=cdo.getColValue("tipo_doc")%></td>
		          <td align="right"><%=cdo.getColValue("fecha")%></td>
		          <td align="right"><%=cdo.getColValue("tipo_emision")%></td>
		          <td align="right"><%=cdo.getColValue("cod_sucursal")%></td>
		          <td align="right"><%=cdo.getColValue("punto_de_fact")%></td>
		          <td align="right"><%=cdo.getColValue("tipo_de_contr")%></td>
		          <td align="right"><%=cdo.getColValue("ruc_emisor")%></td>
		          <td align="right"><%=cdo.getColValue("dv_emisor")%></td>
		          <td align="right"><%=cdo.getColValue("razon_social_emi")%></td>
		          <td align="right"><%=cdo.getColValue("tipo_receptor")%></td>
		          <td align="right"><%=cdo.getColValue("ruc_receptor")%></td>
		          <td align="right"><%=cdo.getColValue("razon_social_rec")%></td>
		          <td align="right"><%=cdo.getColValue("id_pasaporte")%></td>
		          <td align="right"><%=cdo.getColValue("pais_recep")%></td>
		          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("sum_items"))%></td>
		          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("itbms"))%></td>
		          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("valor_isc"))%></td>
		          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("t_impuestos"))%></td>
		          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
	         </tr>
			<%
			   }
			if(al.size()==0){
			%>
				<tr>
				  <td align="center" colspan="11">No registros encontrados.</td>
				</tr>
			<%}
			else{
			    if (color.equals("TextRow02"))
				   {color = "TextRow01";}
				else{color = "TextRow02";}
				}
			%>
        </table>
    </body>
</html>