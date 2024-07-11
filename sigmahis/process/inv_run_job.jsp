<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String fp = request.getParameter("fp");
String actType = request.getParameter("actType");
String docType = request.getParameter("docType");
String docDesc = "", actDesc = "";
if (fp.trim().equals("")) throw new Exception("El Origen no es válido. Por favor consulte con su Administrador!");
if (docType.trim().equals("")) throw new Exception("El Documento no es válido. Por favor consulte con su Administrador!");
if (actType.trim().equals("")) throw new Exception("La Acción no es válida. Por favor consulte con su Administrador!");
if (docType.equalsIgnoreCase("EMAIL_FV")) docDesc = "ENVIAR CORREO POR VENCIMIENTO DE INSUMO/ARTICULOS";

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("actType",actType)%>
<%=fb.hidden("docType",docType)%>
		<tr class="TextHeader" align="center">
			<td><%=actDesc%> <%=docDesc%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right" colspan="2">
				<%=fb.submit("save","Enviar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&actType="+actType+"&docType="+docType+"&compania="+session.getAttribute("_companyId"));
	if (docType.equalsIgnoreCase("EMAIL_FV")) {

		if (actType.equalsIgnoreCase("1")) {

			sbSql.append("select to_number(nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'MESES_VENCIMIENTO_MED_INSUMO'),'3')) as mes_med, to_number(nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'MESES_VENCIMIENTO_EXCE_COSTO'),'1')) as mes_excl_cost, nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'COD_TIPO_SERV_INS'),'-') as ts_ins, nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'COD_TIPO_SERV_MED'),'-') as ts_med, replace(nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'EMAIL_LOTE_FECHA_VENCE'),'-'),',',';') as email, nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'INV_LOTE_FECHA_VENCE_ATCH_PATH'),'-') as atch_path, to_char(sysdate,'dd/mm/yyyy') as msg_date from dual");
			CommonDataObject p = SQLMgr.getData(sbSql.toString());
			if (p.getColValue("ts_ins").equals("-")) throw new Exception("El parámetro del Tipo de Servicio Insumo [COD_TIPO_SERV_INS] no está definida!");
			if (p.getColValue("ts_med").equals("-")) throw new Exception("El parámetro del Tipo de Servicio Medicamento [COD_TIPO_SERV_MED] no está definida!");
			if (p.getColValue("email").equals("-")) throw new Exception("El parámetro del Email de Lote Fecha Vencimiento [INV_LOTE_FECHA_VENCE_ATCH_PATH] no está definida!");
			if (p.getColValue("atch_path").equals("-")) throw new Exception("El parámetro de la Ruta de Lote Fecha Vencimiento [INV_LOTE_FECHA_VENCE_ATCH_PATH] no está definida!");
			else if (CmnMgr.createFolderDos(p.getColValue("atch_path"),"").equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta "+p.getColValue("atch_path")+"! Intente nuevamente.");

			sbSql = new StringBuffer();
			sbSql.append("select 'FAMILIA|CODIGO|DESCRIPCION|LOTE|FECHA VENCE|EXCEPCION COSTO' as texto, 0 as rec_type, null as excepcion_costo, null as familia, null as cod_articulo from dual union all ");
			sbSql.append("select distinct (select nombre from tbl_inv_familia_articulo where compania = a.compania and cod_flia = a.cod_flia)||'|'||al.cod_articulo||'|'||a.descripcion||'|'||al.no_lote||'|'||to_char(al.fecha_vence,'dd/mm/yyyy')||'|'||nvl(a.excepcion_costo,'N') as texto, 1 as rec_type, nvl(a.excepcion_costo,'N') as excepcion_costo, (select nombre from tbl_inv_familia_articulo where compania = a.compania and cod_flia = a.cod_flia) as familia, al.cod_articulo from tbl_inv_art_lote al, tbl_inv_articulo a where al.compania = a.compania and al.cod_articulo = a.cod_articulo and al.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and ( (nvl(a.excepcion_costo,'N') = 'N' and al.fecha_vence <= add_months(trunc(sysdate),");
			sbSql.append(p.getColValue("mes_med"));
			sbSql.append(")) or (nvl(a.excepcion_costo,'N') = 'S' and al.fecha_vence <= add_months(trunc(sysdate),");
			sbSql.append(p.getColValue("mes_excl_cost"));
			sbSql.append(")) ) and al.fecha_vence >= trunc(sysdate) and exists (select null from tbl_inv_familia_articulo where compania = a.compania and cod_flia = a.cod_flia and tipo_servicio in ('");
			sbSql.append(p.getColValue("ts_med"));
			sbSql.append("','");
			sbSql.append(p.getColValue("mes_ins"));
			sbSql.append("')) order by 2, 3, 4, 5");

			StringBuffer sbPath = new StringBuffer(p.getColValue("atch_path"));
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("_path",p.getColValue("atch_path"));
			cdo.addColValue("_sql",sbSql.toString());
			sbPath.append(CmnMgr.createTxtFile(cdo,false));

			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sec_mail_q");
			cdo.addSeqColValue("msg_id","seq_secmail_q");
			cdo.addColValue("msg_type","EMAIL");
			cdo.addColValue("msg_ref","INV_LOTE_FECHA_VENCE");
			cdo.addColValue("msg_from","INVENTARIO");
			cdo.addColValue("msg_to",p.getColValue("email"));
			//cdo.addColValue("msg_to","jacinto@issi-panama.com");
			cdo.addColValue("msg_subject",new StringBuffer("ARTICULOS PROXIMOS A VENCER - ").append(p.getColValue("msg_date")).toString());
			cdo.addColValue("msg_text","ESTIMADO COLABORADOR, ADJUNTO SE ENCUENTRA EL LISTADO DE ARTICULOS PROXIMO A EXPIRAR A PARTIR DEL DIA DE HOY!");
			cdo.addColValue("msg_status","A");
			cdo.addColValue("msg_attach_flag","Y");
			cdo.addColValue("msg_attach_file_path",sbPath.toString());
			cdo.addColValue("msg_sent_flag","N");
			cdoM.addColValue("msg_date","sysdate");
			SQLMgr.insert(cdo,false);

		}

	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin(false);
	parent.window.location.reload(true);
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>