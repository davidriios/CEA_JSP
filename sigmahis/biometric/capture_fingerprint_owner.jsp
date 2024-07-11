<%//@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

int iconHeight = 40;
int iconWidth = 40;
CommonDataObject oData = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbField = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String type = request.getParameter("type");
String owner = request.getParameter("owner");
String ckSample = request.getParameter("ckSample");
if (fp == null) fp = "";
if (type == null) type = "";
if (owner == null) owner = "";
if (ckSample == null) ckSample = "";
if (fp.trim().equals("")) throw new Exception("Origen inválido!");
if (type.trim().equals("")) throw new Exception("Tipo de Captura inválida!");

String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
CommonDataObject cdoP = new CommonDataObject();

if (owner.trim().equals("")) {

	oData.addColValue("ownerName","");
	oData.addColValue("ownerCode","");
	oData.addColValue("fpOwner","0");
	oData.addColValue("fpSession","0");
	if (type.equalsIgnoreCase("PAC")) oData.addColValue("xLabel6","FECHA NAC.:");
	else if (type.equalsIgnoreCase("USR"))oData.addColValue("xLabel6","CODIGO:");
} else {

	if (type.equalsIgnoreCase("USR")) {

		sbField.append(" name||' ('||user_name||')' as ownerName, user_id as ownerCode");
		sbField.append(", ':' as xLabel0, ' ' as xValue0");
		sbField.append(", ':' as xLabel1, ' ' as xValue1");
		sbField.append(", ':' as xLabel2, ' ' as xValue2");
		sbField.append(", ':' as xLabel3, ' ' as xValue3");
		sbField.append(", ':' as xLabel4, ' ' as xValue4");
		sbField.append(", ':' as xLabel5, ' ' as xValue5,'CODIGO:' as xLabel6");
		sbTable.append(" tbl_sec_users");
		sbFilter.append(" user_id = ");
		sbFilter.append(owner);

	} else if (type.equalsIgnoreCase("PAC")) {

		sbField.append(" a.nombre_paciente as ownerName, to_char(a.f_nac,'dd/mm/yyyy') as ownerCode");
		sbField.append(", 'EXP. ID:' as xLabel0, a.exp_id as xValue0");
		sbField.append(", 'SEXO:' as xLabel1, a.sexo as xValue1");
		sbField.append(", ':' as xLabel2, ' ' as xValue2");
		sbField.append(", decode(a.tipo_id_paciente,'P','PASAPORTE:','CEDULA') as xLabel3, decode(a.pasaporte,null,a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento,a.pasaporte)||decode(a.d_cedula,'D',null,'-'||a.d_cedula) as xValue3");
		sbField.append(", 'EDAD:' as xLabel4, replace(get_age(a.f_nac,sysdate,'d'),'y','a') as xValue4");
		sbField.append(", '<img height=\"16\" width=\"16\" src=\"../images/checkbox-'||decode(a.jubilado,'S','','un')||'checked.png\">' as xLabel5, 'JUBILADO' as xValue5,'FECHA NAC.:' as xLabel6");
		sbTable.append(" vw_adm_paciente a");
		sbFilter.append(" a.pac_id = ");
		sbFilter.append(owner);
		
		StringBuffer sbP = new StringBuffer();
		
		sbP.append(" select nvl(sum(nvl(a.grang_total,0)+ nvl(y.ajustes,0)-nvl(b.pagos,0)),0) saldo, count(a.codigo) tot_fac ");
    sbP.append(" from tbl_fac_factura a,(select sum(dp.monto) pagos,dp.compania,dp.fac_codigo from tbl_cja_detalle_pago dp where  ");
    sbP.append(" exists ( select 1 from tbl_cja_transaccion_pago where compania =dp.compania and anio =dp.tran_anio and codigo = dp.codigo_transaccion ");
    sbP.append(" and rec_status <> 'I' )group by dp.compania,dp.fac_codigo)b,(select nvl(sum(decode(z.lado_mov,'D',z.monto,'C',-z.monto)),0)ajustes, ");
    sbP.append(" z.compania,z.factura from vw_con_adjustment_gral z where z.tipo_doc ='F' group by z.compania,z.factura ) y where a.codigo=b.fac_codigo(+)  ");
    sbP.append(" and a.compania =b.compania(+) and a.pac_id = ");
    sbP.append(owner);
    sbP.append(" and a.compania = ");
    sbP.append((String) session.getAttribute("_companyId"));
    sbP.append(" and a.estatus <> 'A' ");
    sbP.append(" and a.facturar_a='P' and a.codigo=y.factura(+) ");
    sbP.append(" and a.compania =y.compania(+) ");
    
    cdoP = SQLMgr.getData(sbP.toString());
    if (cdoP == null) cdoP = new CommonDataObject();

	} else if (type.equalsIgnoreCase("EMP")) {

		sbField.append(" a.nombre_empleado as ownerName, '' as ownerCode");
		sbField.append(", 'EXP. ID:' as xLabel0, a.emp_id as xValue0");
		sbField.append(", 'SEXO:' as xLabel1, a.sexo as xValue1");
		sbField.append(", ':' as xLabel2, ' ' as xValue2");
		sbField.append(", 'CEDULA:' as xLabel3, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as xValue3");
		sbField.append(", 'EDAD:' as xLabel4, '' as xValue4");
		sbField.append(", '' as xLabel5, '' as xValue5,'FECHA NAC.:' as xLabel6");
		sbTable.append(" vw_pla_empleado a");
		sbFilter.append(" a.emp_id = ");
		sbFilter.append(owner);

	}

	sbSql.append("select");
	sbSql.append(sbField);
	sbSql.append(", (select count(*) from tbl_bio_fingerprint where owner_id = '");
	sbSql.append(owner);
	sbSql.append("' and capture_type = '");
	sbSql.append(type);
	sbSql.append("') as fpOwner");
	sbSql.append(", (select count(*) from tbl_bio_fingerprint_tmp where session_id = '");
	sbSql.append(session.getId());
	sbSql.append("' and capture_type = '");
	sbSql.append(type);
	sbSql.append("') as fpSession");
	sbSql.append(" from");
	sbSql.append(sbTable);
	sbSql.append(" where");
	sbSql.append(sbFilter);

	oData = SQLMgr.getData(sbSql.toString());
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){newHeight();<% if (/*oData.getColValue("fpOwner").equals("0") && */!oData.getColValue("fpSession").equals("0")) { %>parent.doRecord();<% } %>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%fb = new FormBean("ownerForm",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("type",type)%>
<%=fb.hidden("owner",owner)%>
<%=fb.hidden("ckSample",ckSample)%>
<tr align="center">
	<td width="87%" class="UpperCaseText">
		<table width="100%" border="0">
		<tr>
			<td width="5%" align="right">ID:</td>
			<td width="7%"><label id="ownerId" class="RedTextBold"><%=owner%></label></td>
			<td width="10%" align="right">NOMBRE:</td>
			<td colspan="3"><label id="ownerName" class="RedTextBold"><%=oData.getColValue("ownerName")%></label></td>
			<td width="8%" align="right"><label id="xLabel6"><%=oData.getColValue("xLabel6")%></label></td>
			<td width="12%"><label id="ownerCode" class="RedTextBold"><%=oData.getColValue("ownerCode")%></label></td>
			<td width="5%" align="right"><label id="xLabel0"><%=(oData.getColValue("xValue0") == null || oData.getColValue("xValue0").trim().equals(""))?"&nbsp;":oData.getColValue("xLabel0")%></label></td>
			<td width="10%"><label id="xLabel0" class="RedTextBold"><%=(oData.getColValue("xValue0") == null || oData.getColValue("xValue0").trim().equals(""))?"&nbsp;":oData.getColValue("xValue0")%></label></td>
		</tr>
		<tr>
			<td align="right"><label id="xLabel1"><%=(oData.getColValue("xValue1") == null || oData.getColValue("xValue1").trim().equals(""))?"&nbsp;":oData.getColValue("xLabel1")%></label></td>
			<td><label id="xValue1" class="RedTextBold"><%=(oData.getColValue("xValue1") == null || oData.getColValue("xValue1").trim().equals(""))?"&nbsp;":oData.getColValue("xValue1")%></label></td>
			<td align="right"><label id="xLabel2"><%=(oData.getColValue("xValue2") == null || oData.getColValue("xValue2").trim().equals(""))?"&nbsp;":oData.getColValue("xLabel2")%></label></td>
			<td width="16%"><label id="xValue2" class="RedTextBold"><%=(oData.getColValue("xValue2") == null || oData.getColValue("xValue2").trim().equals(""))?"&nbsp;":oData.getColValue("xValue2")%></label></td>
			<td width="9%" align="right"><label id="xLabel3"><%=(oData.getColValue("xValue3") == null || oData.getColValue("xValue3").trim().equals(""))?"&nbsp;":oData.getColValue("xLabel3")%></label></td>
			<td width="8%"><label id="xValue3" class="RedTextBold"><%=(oData.getColValue("xValue3") == null || oData.getColValue("xValue3").trim().equals(""))?"&nbsp;":oData.getColValue("xValue3")%></label></td>
			<td align="right"><label id="xLabel4"><%=(oData.getColValue("xValue4") == null || oData.getColValue("xValue4").trim().equals(""))?"&nbsp;":oData.getColValue("xLabel4")%></label></td>
			<td><label id="xValue4" class="RedTextBold"><%=(oData.getColValue("xValue4") == null || oData.getColValue("xValue4").trim().equals(""))?"&nbsp;":oData.getColValue("xValue4")%></label></td>
			<td align="right"><label id="xLabel5"><%=(oData.getColValue("xValue5") == null || oData.getColValue("xValue5").trim().equals(""))?"&nbsp;":oData.getColValue("xLabel5")%></label></td>
			<td><label id="xValue5" class="RedTextBold"><%=(oData.getColValue("xValue5") == null || oData.getColValue("xValue5").trim().equals(""))?"&nbsp;":oData.getColValue("xValue5")%></label></td>
		</tr>
		<%
		boolean showPendingConfirmation = false;
		if(!cdoP.getColValue("saldo"," ").trim().equals("") && !cdoP.getColValue("saldo","0").trim().equals("0")){
      showPendingConfirmation = true;
		%>
      <tr>
          <td colspan="10">Saldo Pendiente: <label id="pending-saldo" data-saldo="<%=cdoP.getColValue("saldo")%>" data-tot_fac="<%=cdoP.getColValue("tot_fac")%>" class="RedTextBold">
            <%=cdoP.getColValue("saldo")%></label>
          </td>
      </tr>
		<%}%>
		</table>
	</td>
	<td width="13%" align="right">
		<% if (oData.getColValue("fpSession").equals("0")) { %><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/blank.gif"><% } else { %><a href="javascript:parent.doRecord();"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/fingerprint-plus.png"></a><% } %><% if (oData.getColValue("fpOwner").equals("0")) { %><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/blank.gif"><% } else { %><a href="javascript:parent.doRemove();"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/fingerprint-remove.png"></a><% } %><% if (!owner.trim().equals("") && (ckSample.equals("1") || ckSample.equals("2") || ckSample.equals("3"))) { %><a href="javascript:parent.doNext();"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/next-icon.png"></a><% } %>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>