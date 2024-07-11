<%@ page errorPage="../error.jsp"%>
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
/**
=========================================================================
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String type = request.getParameter("type");
String id = request.getParameter("id");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String filtro_fecha_fact = request.getParameter("filtro_fecha_fact");
String agrupado = request.getParameter("agrupado");

if (filtro_fecha_fact == null) filtro_fecha_fact = "";
if (agrupado == null) agrupado = "";
if (type == null) type = "P";
if (id == null) id = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select distinct (select descripcion from tbl_fac_tipo_cliente tc where tc.compania = x.compania and tc.codigo = x.refer_type) refer_desc");
	sbSql.append(", decode(x.refer_type,(select get_sec_comp_param(x.compania,'TP_CLIENTE_PAC') from dual),(select nombre_paciente from vw_adm_paciente where pac_id = x.refer_id),(select getNombreCliente(x.compania,x.refer_type,x.refer_id) from dual)) as nombre");
	sbSql.append(", '01/'||to_char(sysdate,'mm/yyyy') as fecha_ini, to_char(last_day(sysdate),'dd/mm/yyyy') as fecha_fin,nvl(get_sec_comp_param(x.compania,'CXC_MOV_AGRUPADO'),'N') as agrupado from vw_cxc_mov_new x where refer_type = ");
	sbSql.append(type);
	sbSql.append(" and refer_id = '");
	sbSql.append(id);
	sbSql.append("'");
	/*
	if (type.equalsIgnoreCase("P"))
	{
		sbSql.append("select 'P' as tipo, pac_id as id, nombre_paciente as nombre, '01/'||to_char(sysdate,'mm/yyyy') as fecha_ini, to_char(last_day(sysdate),'dd/mm/yyyy') as fecha_fin from vw_adm_paciente where estatus = 'A' and pac_id = ");
		sbSql.append(id);
	}
	else
	{
		sbSql.append("select 'E', codigo, nombre, '01/'||to_char(sysdate,'mm/yyyy') as fecha_ini, to_char(last_day(sysdate),'dd/mm/yyyy') as fecha_fin from tbl_adm_empresa where estado = 'A' and codigo = ");
		sbSql.append(id);
	}*/
	CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
	if (fDate == null) fDate = cdo.getColValue("fecha_ini");
	if (tDate == null) tDate = cdo.getColValue("fecha_fin");
	if (request.getParameter("agrupado") == null) agrupado=cdo.getColValue("agrupado");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Movimientos - '+document.title;
function search(){var fDate=document.form0.fDate.value;var tDate=document.form0.tDate.value;var filtro_fecha_fact=document.form0.filtro_fecha_fact.value;var agrupado=document.form0.agrupado.value;window.frames['itemFrame'].location='../cxc/movimientos_det.jsp?type=<%=type%>&id=<%=id%>&fDate='+fDate+'&tDate='+tDate+'&filtro_fecha_fact='+filtro_fecha_fact+'&agrupado='+agrupado;}
function printMovimiento()
{	
	var id = document.form0.id.value;
	var fechaini = document.form0.fDate.value;
	var fechafin = document.form0.tDate.value;
	var type = document.form0.type.value;
	var agrupado=document.form0.agrupado.value;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_cxc_dett.rptdesign&fIniParam='+fechaini+'&fFinParam='+fechafin+'&refIdParam='+id+'&refTypeParam='+type+'&pAgrupado='+agrupado); 
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="MOVIMIENTOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("type",type)%>
<%=fb.hidden("id",id)%>
		<tr>
			<td>
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr>
					<td colspan="3" align="right">
					<authtype type='2'><a href="javascript:printMovimiento()" class="btn_link">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype>
					</td>
				</tr>
				<tr class="TextFilter">
					<td colspan="3">
						<cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fDate" />
						<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
						<jsp:param name="nameOfTBox2" value="tDate" />
						<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
						Usa Fecha Factura?<%=fb.select("filtro_fecha_fact","N=No,Y=Si",filtro_fecha_fact,false,false,0,"Text10",null,null,null,"")%>
						Agrupado por Doc..?<%=fb.select("agrupado","N=No,S=Si",agrupado,false,false,0,"Text10",null,null,null,agrupado)%>
						<%=fb.button("ir","Ir",true,false,"Text10","","onClick=\"javascript:search();\"")%>
					</td>
				</tr>
				<tr class="TextHeader02">
					<td width="30%"><cellbytelabel>C&oacute;digo</cellbytelabel>: <%=id%></td>
					<td width="50%"><cellbytelabel>Nombre</cellbytelabel>: <%=cdo.getColValue("nombre")%></td>
					<td width="20%" align="right"><%=cdo.getColValue("refer_desc")%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="500" scrolling="yes" src="../cxc/movimientos_det.jsp?type=<%=type%>&id=<%=id%>&fDate=<%=fDate%>&tDate=<%=tDate%>&agrupado=<%=agrupado%>"></iframe></td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
