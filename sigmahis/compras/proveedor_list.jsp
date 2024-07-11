<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String tipoPersona = request.getParameter("tipoPersona");
String estado = request.getParameter("estado");
String tipo_prov = request.getParameter("tipo_prov");
String vetado = request.getParameter("vetado");
String cuenta = request.getParameter("cuenta");
String cuenta_banco = request.getParameter("cuenta_banco");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (tipoPersona == null) tipoPersona = "";
if (estado == null) estado = "";
if (tipo_prov == null) tipo_prov = "";
if (vetado == null) vetado = "";
if (cuenta == null) cuenta = "";
if (cuenta_banco == null) cuenta_banco = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!codigo.trim().equals("")) { sbFilter.append(" and cod_provedor like '%"); sbFilter.append(codigo); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre_proveedor) like '%"); sbFilter.append(IBIZEscapeChars.forSingleQuots(nombre.toUpperCase())); sbFilter.append("%'"); }
	if (!tipoPersona.trim().equals("")) { sbFilter.append(" and upper(tipo_persona) like '%"); sbFilter.append(tipoPersona); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and estado_proveedor = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
    if (!tipo_prov.trim().equals("")){sbFilter.append(" and upper(tipo_prove) = '");sbFilter.append(tipo_prov.toUpperCase());sbFilter.append("'");}
	if (!vetado.trim().equals("")) { sbFilter.append(" and vetado = '"); sbFilter.append(vetado.toUpperCase()); sbFilter.append("'");}
    
    if (cuenta.equalsIgnoreCase("S")) {
        sbFilter.append(" and cuenta_bancaria is not null");
    } else if (cuenta.equalsIgnoreCase("N")) {
        sbFilter.append(" and cuenta_bancaria is null");
    }
		
		if(!cuenta_banco.equals("")){
			sbFilter.append(" and cuenta_bancaria like '%");
			sbFilter.append(cuenta_banco);
			sbFilter.append("%'");
		}

	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select cod_provedor as codigo, nombre_proveedor as nombre, compania, decode(estado_proveedor,'ACT','ACTIVO','INA','INACTIVO') as estado, contacto_compra as contacto, telefono, local_internacional, decode(tipo_persona,'1','NATURAL','2','JURIDICO','3','EXTRANJERO') as tipo_persona, ruc, digito_verificador dv, (case when (select count(*) from tbl_con_pagos_otros cp where cp.tipo_codigo = 'P' and to_char(p.cod_provedor) = cp.codigo_original) <> 0 then 'N' else 'S' end) replicar,decode(nvl(p.vetado,'N'),'N','NO','S','SI')  as vetado, cuenta_bancaria from tbl_com_proveedor p where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 2");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);
	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from tbl_com_proveedor where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());

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
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Proveedor - '+document.title;
function add(){abrir_ventana('../compras/proveedor_config.jsp');}
function edit(code){abrir_ventana('../compras/proveedor_config.jsp?mode=edit&code='+code);}
function printList(fg){abrir_ventana('../compras/print_list_proveedores.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg='+fg);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function replicar(name, ruc, dv, id){
	abrir_ventana('../cxp/pagos_otros_config.jsp?replicar=S&fp=proveedor&r_name='+name+'&r_ruc='+ruc+'&r_dv='+dv+'&r_id='+id);
}
function editCuenta(code){abrir_ventana('../compras/proveedor_config.jsp?mode=edit&code='+code+'&fg=CONTA');}
function excel(){
	var codigo = document.search00.codigo.value||'';
	var nombre = document.search00.nombre.value||'';
	var tipo_prov = document.search00.tipo_prov.value||'';
	var tipoPersona = document.search00.tipoPersona.value||'';
	var estado = document.search00.estado.value||'';
	var vetado = document.search00.vetado.value||'';
	var cuenta = document.search00.cuenta.value||'';
	var cuenta_banco = document.search00.cuenta_banco.value||'';
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=compras/rpt_list_proveedores.rptdesign&codigo='+codigo+'&nombre='+nombre+'&tipo_prov='+tipo_prov+'&tipoPersona='+tipoPersona+'&estado='+estado+'&vetado='+vetado+'&cuenta='+cuenta+'&cuenta_banco='+cuenta_banco);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Proveedor </cellbytelabel>]</a></authtype></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td>
				<cellbytelabel>C&oacute;digo</cellbytelabel><br>
				<%=fb.intBox("codigo",codigo,false,false,false,5)%> 
				</td>
				<td>
				<cellbytelabel>Nombre</cellbytelabel><br>
				<%=fb.textBox("nombre",nombre,false,false,false,20)%> 
				</td>
				<td>
        Tipo Prov.:<br><%=fb.select(ConMgr.getConnection(), "select tipo_proveedor, descripcion||' - '||tipo_proveedor as descripcion from tbl_com_tipo_proveedor", "tipo_prov",tipo_prov,false,false,0,null,"width:120px",null,null,"S")%>
				</td>
				<td>
				<cellbytelabel>Tipo Persona</cellbytelabel><br>
				<%=fb.select("tipoPersona","1=NATURAL,2=JURIDICO,3=EXTRANJERO",tipoPersona,false,false,0,null,"width:80px",null,null,"T")%> 
				</td>
				<td>
				<cellbytelabel>Estado</cellbytelabel><br>
				<%=fb.select("estado","ACT=ACTIVO,INA=INACTIVO",estado,false,false,false,0,null,null,null,null,"T")%>
				</td>
				<td>
				Vetado:<br><%=fb.select("vetado","S=SI,N=NO",vetado,false,false,false,0,null,null,null,null,"T")%>
				</td>
				<td>
        Cuenta:<br><%=fb.select("cuenta","S=SI,N=NO",cuenta,false,false,false,0,null,null,null,null,"T")%>
				</td>
				<td>
				Cta. Banco:<br>
				<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,false,20)%> 
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right"> <authtype type='51'> <a href="javascript:printList('CTA')" class="Link00">[ <cellbytelabel>Imprimir Lista Con Cuenta</cellbytelabel> ]</a>  <a href="javascript:excel()" class="Link00">[ <cellbytelabel>Excel</cellbytelabel> ]</a> </authtype>
		<authtype type='0'> <a href="javascript:printList('')" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipoPersona",tipoPersona)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipoPersona",tipoPersona)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader">
			<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="8%"><cellbytelabel>TipoPersona</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Contacto</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Vetado</cellbytelabel></td>
			<td width="8%" align="center"><cellbytelabel>Cuenta</cellbytelabel></td>
			<td width="4%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
			<td width="11%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("tipo_persona")%></td>
			<td><%=cdo.getColValue("contacto")%></td>
			<td><%=cdo.getColValue("telefono")%></td>
			<td><%=cdo.getColValue("estado")%></td>
			<td><%=cdo.getColValue("vetado")%></td>
			<td align="center"><%=cdo.getColValue("cuenta_bancaria")%></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
			<td align="center">&nbsp;<authtype type='52'><a href="javascript:editCuenta(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar Cuenta</cellbytelabel></a></authtype></td>
			<td align="center">&nbsp;<authtype type='50'><%if(cdo.getColValue("replicar").equals("S")){%><a href="javascript:replicar('<%=cdo.getColValue("nombre")%>','<%=cdo.getColValue("ruc")%>','<%=cdo.getColValue("dv")%>',<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Replicar Pago Otro</cellbytelabel></a><%}%></authtype></td>
		</tr>
<% } %>
		</table>
</div>
</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipoPersona",tipoPersona)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipoPersona",tipoPersona)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>