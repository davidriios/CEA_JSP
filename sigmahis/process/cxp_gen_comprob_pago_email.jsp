<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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

StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();
String appendFilter = request.getParameter("appendFilter");
if (appendFilter == null) appendFilter = "";

sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CXP_COMPROB_ATTACHMENT_PATH'),'-') as attachment_path, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CXP_COMPROB_NOTE'),'-') as note, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CXP_COMPROB_NOTE_HON'),'-') as note1, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CXP_COMPROB_NOTE_PROV'),'-') as note2 from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p.getColValue("attachment_path").equals("-")) throw new Exception("El parámetro de la Ruta de Comprobantes de CXP [CXP_COMPROB_ATTACHMENT_PATH] no está definida!");
else if (CmnMgr.createFolderDos(p.getColValue("attachment_path"),"").equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta "+p.getColValue("attachment_path")+"! Intente nuevamente.");

sbSql = new StringBuffer();
sbSql.append("select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.cod_proveedor, a.beneficiario, a.beneficiario2, a.monto_girado, to_char(a.f_emision,'dd/mm/yyyy') as f_emision, a.estado_cheque, decode(a.estado_cheque,'G','Girado','P','Pagado','A','Anulado') as estado_desc, a.anio, a.num_orden_pago, a.che_user, nvl(a.id_lote,0) as id_lote, a.tipo_pago, decode(a.tipo_pago,1,'Cheque',2,'ACH',3,'Transferencia') as tipo_pago_desc, a.tipo_orden, decode(a.tipo_orden,1,'Médico',2,'Proveedor',3,'Beneficiario') as tipo_orden_desc, a.ch_reemplazo, case when nvl((select nvl(estado,'INA') from tbl_con_estado_anos where ano = to_number(to_char(a.f_emision,'yyyy')) and cod_cia = a.cod_compania),'ACT') = 'ACT' and nvl((select nvl(estatus,'X') from tbl_con_estado_meses where ano = to_number(to_char(a.f_emision,'yyyy')) and cod_cia = a.cod_compania and mes = to_number(to_char(a.f_emision,'mm')) ),'INA') <> 'CER' and nvl(comprobante,'N') = 'N' then 'S' else 'N' end as cambiarCta");
sbSql.append(", (select nombre from tbl_con_banco where compania = a.cod_compania and cod_banco = a.cod_banco) as nombre_banco");
sbSql.append(", (select descripcion from tbl_con_cuenta_bancaria where compania = a.cod_compania and cuenta_banco = a.cuenta_banco) as nombre_cuenta");
sbSql.append(", nvl((select case cod_tipo_orden_pago when 1 then (select decode(pagar_ben,'M',e_mail,(select e_mail from tbl_adm_empresa where codigo = y.cod_empresa)) from tbl_adm_medico y where codigo = to_char(z.cod_provedor)) when 2 then (select email from tbl_com_proveedor where cod_provedor = z.cod_provedor) when 3 then ");
	sbSql.append("case tipo_orden when 'E' then (select e_mail from tbl_adm_empresa where codigo = z.cod_provedor) when 'P' then (select e_mail from tbl_adm_paciente where pac_id = z.cod_provedor) when 'L' then (select email from tbl_cds_centro_servicio where codigo = z.cod_provedor) when 'D' then (select email from tbl_con_accionista where codigo = z.cod_provedor and compania = a.cod_compania) when 'O' then (select email from tbl_con_pagos_otros where codigo = z.cod_provedor and compania = z.cod_compania) when 'C' then (select email from tbl_com_proveedor where cod_provedor = z.cod_provedor) when 'U' then (select email from tbl_pla_empleado where emp_id = z.cod_provedor) end");
sbSql.append(" end from tbl_cxp_orden_de_pago z where anio = a.anio and num_orden_pago = a.num_orden_pago and cod_compania = a.cod_compania),' ') as email");
sbSql.append(", 'note'||(select case when cod_tipo_orden_pago < 3 then to_char(cod_tipo_orden_pago) /*when cod_tipo_orden_pago = 3 then tipo_orden*/ end from tbl_cxp_orden_de_pago z where anio = a.anio and num_orden_pago = a.num_orden_pago and cod_compania = a.cod_compania) as note_type");
sbSql.append(" from tbl_con_cheque a where a.cod_compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.estado_cheque != 'A'");
sbSql.append(appendFilter);
if (request.getParameter("regen") == null) sbSql.append(" and not exists (select null from tbl_sec_mail_q where msg_ref = 'CXP_CHK_COMPROB' and ref_key = a.cod_compania||'_ck'||a.num_cheque||'_op'||a.anio||'-'||a.num_orden_pago)");
sbSql.append(" order by a.id");
if (!appendFilter.trim().equals("")) al = SQLMgr.getDataList(sbSql.toString());
System.out.println(".............................................................."+al.size());
if(request.getMethod().equalsIgnoreCase("GET")) {

	int nMail = 0;
	int nNoMail = 0;
	for(int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (cdo.getColValue("email") != null && !cdo.getColValue("email").trim().equals("")) {

			StringBuffer sbRef = new StringBuffer();
			sbRef.append(session.getAttribute("_companyId"));
			sbRef.append("_ck");
			sbRef.append(cdo.getColValue("num_cheque"));
			sbRef.append("_op");
			sbRef.append(cdo.getColValue("anio"));
			sbRef.append("-");
			sbRef.append(cdo.getColValue("num_orden_pago"));

			StringBuffer sbSubject = new StringBuffer();
			sbSubject.append("COMPROBANTE PAGO - ").append(cdo.getColValue("beneficiario")).append(" (").append(cdo.getColValue("cod_proveedor")).append(")");

			StringBuffer sbMsg = new StringBuffer();
			sbMsg.append("Estimado ").append(cdo.getColValue("tipo_orden_desc")).append(", adjunto Orden de Pago #").append(cdo.getColValue("anio")).append("-").append(cdo.getColValue("num_orden_pago")).append(" - Cancelado por ").append(cdo.getColValue("tipo_pago_desc")).append(" #").append(cdo.getColValue("num_cheque")).append(".");
			//Additional Notes: 1-HON, 2-PROV, 3-OTRO (E-EMPRESA, P-PACIENTE, L-LIQUIDACION CDS, D-DIVIDENDO ACCIONISTA, O-PAGOS OTROS, C-CONTRATOS PROVEEDOR, U-EMPLEADO)
			if (!p.getColValue(cdo.getColValue("note_type")).trim().equals("") && !p.getColValue(cdo.getColValue("note_type")).equals("-")) sbMsg.append("\n\n").append(p.getColValue(cdo.getColValue("note_type")));

			StringBuffer sbPath = new StringBuffer(p.getColValue("attachment_path"));
			sbPath.append(sbRef);
			sbPath.append(".pdf");
//try {
%>
			<jsp:include page="../cxp/print_orden_pago.jsp">
				<jsp:param name="email" value=""></jsp:param>
				<jsp:param name="curCompany" value="<%=session.getAttribute("_companyId")%>"></jsp:param>
				<jsp:param name="orderYear" value="<%=cdo.getColValue("anio")%>"></jsp:param>
				<jsp:param name="noOrder" value="<%=cdo.getColValue("num_orden_pago")%>"></jsp:param>
				<jsp:param name="pdfPath" value="<%=sbPath.toString()%>"></jsp:param>
			</jsp:include>
<%
//} catch (Exception ex) {}

			CommonDataObject cdoM = new CommonDataObject();
			cdoM.setTableName("tbl_sec_mail_q");
			cdoM.addSeqColValue("msg_id","seq_secmail_q");
			cdoM.addColValue("msg_type","EMAIL");
			cdoM.addColValue("msg_ref","CXP_CHK_COMPROB");
			cdoM.addColValue("msg_from","CXP");
			cdoM.addColValue("msg_to",cdo.getColValue("email"));
			//cdoM.addColValue("msg_to","jacinto@issi-panama.com");
			cdoM.addColValue("msg_subject",sbSubject.toString());
			cdoM.addColValue("msg_text",sbMsg.toString());
			cdoM.addColValue("msg_status","A");
			cdoM.addColValue("msg_attach_flag","Y");
			cdoM.addColValue("msg_attach_file_path",sbPath.toString());
			cdoM.addColValue("ref_key",sbRef.toString());
			cdoM.addColValue("msg_sent_flag","N");
			cdoM.addColValue("msg_date","sysdate");
			SQLMgr.insert(cdoM,false);
			if (SQLMgr.getErrCode().equals("1")) nMail++;

		} else nNoMail++;
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'CXP - '+document.title;
window.opener.window.location.reload(true);
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CXP - COMPROBANTE PAGO"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="1">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellspacing="0">
		<tr class="TextHeader">
			<td width="60%" align="right">Total de comprobantes a generar:&nbsp;</td>
			<td width="40%">&nbsp;<%=al.size()%></td>
		</tr>
		<tr class="TextHeader">
			<td align="right">Total de beneficiarios sin correo:&nbsp;</td>
			<td>&nbsp;<%=nNoMail%></td>
		</tr>
		<tr class="TextHeader">
			<td align="right">Total de comprobantes y correos generados:&nbsp;</td>
			<td>&nbsp;<%=nMail%></td>
		</tr>
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
		<%=fb.formStart()%>
		<%=fb.hidden("appendFilter",appendFilter)%>
		<tr class="TextPager">
			<td align="center" colspan="2">
				<%//=fb.submit("regen","Regenerar Comprobantes",true,false,null,null,null)%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close();\"")%>
			</td>
		</tr>
		<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>