<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoSI = new CommonDataObject();

String change = request.getParameter("change");
String key = "";
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlSI = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String beneficiario = request.getParameter("beneficiario");
String tipo = request.getParameter("tipo");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
boolean viewMode = false;
int lineNo = 0;

CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if (request.getMethod().equalsIgnoreCase("GET"))
{

	
	sbSql.append("select * from (select 'E' tipo, 'H' tipo_doc, 'HONORARIOS' tipo_doc_desc, f.compania, f.codigo, f.fecha, to_char(f.fecha, 'dd/mm/yyyy') fecha_docto, p.nombre_paciente || ' - ' || f.pac_id || ' - ' || f.admi_secuencia || ' - No. Orden '|| getBoletasHon(f.pac_id, f.admi_secuencia, df.med_empresa) nombre_referencia, to_char(df.med_empresa) beneficiario, (select nombre from tbl_adm_empresa e where e.codigo = df.med_empresa) nombre_beneficiario, decode(df.monto, 0, df.monto_paciente, df.monto) debito, 0 credito from tbl_fac_factura f, tbl_fac_detalle_factura df, vw_adm_paciente p where f.codigo = df.fac_codigo and f.compania = df.compania and f.estatus = 'P' and df.centro_servicio = 0 and f.pac_id = p.pac_id and df.med_empresa is not null and df.monto > 0 union select 'M' tipo, 'H' tipo_doc, 'HONORARIOS' tipo_doc_desc, f.compania, f.codigo, f.fecha, to_char(f.fecha, 'dd/mm/yyyy') fecha_docto, p.nombre_paciente || ' - ' || f.pac_id || ' - ' || f.admi_secuencia || ' - No. Orden '|| getBoletasHon(f.pac_id, f.admi_secuencia, df.medico) nombre_referencia, df.medico beneficiario, (select decode(m.sexo, 'F', 'Dra. ', 'Dr. ') || m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = df.medico) nombre_beneficiario, decode(df.monto, 0, df.monto_paciente, df.monto) debito, 0 credito from tbl_fac_factura f, tbl_fac_detalle_factura df, vw_adm_paciente p where f.codigo = df.fac_codigo and f.compania = df.compania and f.estatus = 'P' and df.centro_servicio = 0 and f.pac_id = p.pac_id and df.med_empresa is null and df.monto > 0 union select 'E' tipo, 'P' tipo_doc, 'PAGO' tipo_doc_desc, c.cod_compania, c.num_cheque, c.f_emision, to_char(c.f_emision, 'dd/mm/yyyy') fecha_docto, c.beneficiario nombre_referencia, a.num_id_beneficiario beneficiario, (select nombre from tbl_adm_empresa e where e.codigo = a.cod_empresa) nombre_beneficiario, 0 debito, decode (c.estado_cheque, 'G', b.monto_a_pagar, 0) credito from   tbl_cxp_orden_de_pago a, tbl_cxp_detalle_orden_pago b, tbl_con_cheque c where a.estado = 'A' and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago and a.cod_compania = b.cod_compania and (a.cod_tipo_orden_pago = 3 and a.tipo_orden in ('E')) and a.anio = c.anio and a.num_orden_pago = c.num_orden_pago and a.cod_compania = c.cod_compania_odp union select 'M' tipo, 'P' tipo_doc, 'PAGO' tipo_doc_desc, c.cod_compania, c.num_cheque, c.f_emision, to_char(c.f_emision, 'dd/mm/yyyy') fecha_docto, c.beneficiario nombre_referencia, a.num_id_beneficiario beneficiario, (select decode(m.sexo, 'F', 'Dra. ', 'Dr. ') || m.primer_nombre || decode (m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode (m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode (m.sexo, 'F', decode (m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = a.cod_medico) nombre_beneficiario, 0 debito, decode (c.estado_cheque, 'G', b.monto_a_pagar, 0) credito from tbl_cxp_orden_de_pago a, tbl_cxp_detalle_orden_pago b, tbl_con_cheque c where a.estado = 'A' and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago and a.cod_compania = b.cod_compania and a.cod_tipo_orden_pago = 1 and a.anio = c.anio and a.num_orden_pago = c.num_orden_pago and a.cod_compania = c.cod_compania_odp) where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and beneficiario = '");
	sbSql.append(beneficiario);
	sbSql.append("' and tipo = '");
	sbSql.append(tipo);
	sbSql.append("'");
	
	sbSqlSI.append("select nvl(sum((case when fecha < to_date('");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("','dd/mm/yyyy') then debito end)), 0) - nvl(sum((case when fecha < to_date('");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("','dd/mm/yyyy') then credito end)), 0) saldo_inicial from (");
	sbSqlSI.append(sbSql.toString());
	sbSqlSI.append(")");
	System.out.println("SQL SI=\n"+sbSqlSI.toString());
	cdoSI = SQLMgr.getData(sbSqlSI.toString());

	sbSql.append(" and trunc(fecha) between to_date('");
	sbSql.append(fechaini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fechafin);
	sbSql.append("', 'dd/mm/yyyy')");

		System.out.println("SQL al=\n"+sbSql.toString());
		al = SQLMgr.getDataList(sbSql.toString());
		
		cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sbSql.toString()+")");
		
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function ver(no, anio, tipo, fre_docto, tipo_docto)
{	
	if(tipo=='FACT' && (fre_docto == 'OC' || fre_docto == 'FC')) abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?mode=view&id='+no+'&anio='+anio);
	else if(tipo=='FACT' && (fre_docto == 'FR' || fre_docto == 'FC') && tipo_docto == 'I') abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?mode=view&id='+no+'&anio='+anio);
	else if(tipo=='FACT' && fre_docto == 'FR' && tipo_docto == 'S') abrir_ventana('../cxp/fact_prov.jsp?mode=view&numero_documento='+no+'&anio='+anio);	
	else if(tipo=='FACT' && fre_docto == 'FG') abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?mode=view&id='+no+'&anio='+anio);	
	else if(tipo=='ND' || tipo=='NC') abrir_ventana('../cxp/nota_ajuste_config.jsp?mode=?mode=view&code='+no+'&anio='+anio);
	else if(tipo=='PAGO') abrir_ventana('../cxp/orden_pago.jsp?mode=view&num_orden_pago='+no+'&anio='+anio);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="5%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
          <td align="center" width="45%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>No. Doc</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Saldo</cellbytelabel></td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="4"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%></td>
        </tr>
        <%
				double saldo = 0.00;
				if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
					saldo += Double.parseDouble(cdo.getColValue("debito"));
					saldo -= Double.parseDouble(cdo.getColValue("credito"));
          %>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center">
          <a href="javascript:ver('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_doc")%></a>
          </td>
          <td align="left"><%=cdo.getColValue("tipo_doc_desc")+(cdo.getColValue("tipo_doc").equals("H")? "  -  "+cdo.getColValue("nombre_referencia"):"")%></td>
          <td align="center"><%=cdo.getColValue("codigo")%></td>
          <td align="center"><%=cdo.getColValue("fecha_docto")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
          <td align="right">
					<font class="<%=(saldo<0?"GreenTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font>
          </td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="4"><cellbytelabel>Total</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("credito"))%></td>
          <td align="right"><font class="<%=(saldo<0?"GreenTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font></td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}%>