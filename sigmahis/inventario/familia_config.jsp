<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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

StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")) {
	if (mode.equalsIgnoreCase("add")) {
		id = "0";
		cdo.addColValue("code","0");
	} else {
		if (id == null) throw new Exception("La Familia de Articulos no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.cod_flia as code, a.compania, a.nombre as name,'' as ctas1, '' as ctas2, '' as ctas3, '' as ctas4,'' as ctas5,'' as ctas6, nvl(a.tipo_servicio,' ') as servicio, a.usuario_creacion as usuarioC, a.usuario_modificacion as usuarioM, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fmodific, ' ' as nivel, a.placa as placas, nvl(a.marbete,'N') as marbete, nvl(a.incremento_venta,'N') as incremento_venta, a.porc_incremento,a.porc_inc_far");
		sbSql.append(", nvl((select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_servicio and compania = a.compania),' ') as otro"); 
    sbSql.append(", a.item_decoration, nvl(a.consignacion,' ') as consignacion, nvl(a.costo_cero,' ') as costo_cero");
		sbSql.append(" from tbl_inv_familia_articulo a where a.cod_flia = ");
		sbSql.append(id);
		sbSql.append(" and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdo = SQLMgr.getData(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Familia de Articulos - "+document.title;
function tipo(){abrir_ventana1('../admin/list_servicio.jsp?fp=invent');}
function cuenta(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=familia');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - FAMILIA DE ARTICULOS"></jsp:param>
</jsp:include>

<table width="99%" cellpadding="5" cellspacing="0" border="0" align="center">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("code",cdo.getColValue("code"))%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2" align="left">&nbsp;Familia de Articulos</td>
		</tr>
		<tr class="TextRow01">
			<td width="19%">&nbsp;C&oacute;digo</td>
			<td width="81%"><%=cdo.getColValue("code")%></td>
		</tr>
		<tr class="TextRow01">
			<td>&nbsp;Nombre de la Familia</td>
			<td><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,44,80)%></td>
		</tr>
		<!--<tr class="TextRow01">
			<td>&nbsp;Cuenta Financiera</td>
			<td>
				<%//=fb.textBox("ctas1",cdo.getColValue("ctas1"),false,false,true,3,3)%>
				<%//=fb.textBox("ctas2",cdo.getColValue("ctas2"),false,false,true,3,2)%>
				<%//=fb.textBox("ctas3",cdo.getColValue("ctas3"),false,false,true,3,3)%>
				<%//=fb.textBox("ctas4",cdo.getColValue("ctas4"),false,false,true,3,3)%>
				<%//=fb.textBox("ctas5",cdo.getColValue("ctas5"),false,false,true,3,3)%>
				<%//=fb.textBox("ctas6",cdo.getColValue("ctas6"),false,false,true,3,3)%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>&nbsp;Nombre de la Cuenta</td>
			<td>
				<%//=fb.textBox("nameCuenta",cdo.getColValue("nameCuenta"),false,false,true,80,80)%>
				<%//=fb.button("btnCtas",".:.",true,false,null,null,"onClick=\"javascript:cuenta()\"","Agregar Cuentas")%>
			</td>
		</tr>-->
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2" align="left">&nbsp;Otros Campos de Familia de Articulos</td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;Tipo de Servicio</td>
			<td>
				<%=fb.textBox("servicio",cdo.getColValue("servicio"),true,false,true,10,5)%>
				<%=fb.textBox("otro",cdo.getColValue("otro"),true,false,true,35,80)%>
				<%=fb.button("btntipo","...",true,false,null,null,"onClick=\"javascript:tipo()\"","Agregar Servicios")%>
			</td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;&nbsp;</td>
			<td><!--<%//=fb.textBox("nivel",cdo.getColValue("nivel"),true,false,false,5,3)%>-->&nbsp;Activo Fijo&nbsp;<%=fb.checkbox("placas","S",(cdo.getColValue("placas") != null && cdo.getColValue("placas").equalsIgnoreCase("S")),false)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;Incremento en Precio de Venta&nbsp;</td>
			<td><%=fb.checkbox("incremento_venta","S",(cdo.getColValue("incremento_venta") != null && cdo.getColValue("incremento_venta").equalsIgnoreCase("S")),false)%>Porcentaje<%=fb.decBox("porc_incremento",cdo.getColValue("porc_incremento"),false,false,false,3,3)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;Impresion de Marbete&nbsp;</td>
			<td><%=fb.checkbox("marbete","S",(cdo.getColValue("marbete") != null && cdo.getColValue("marbete").equalsIgnoreCase("S")),false)%></td>
		</tr>
        <tr class="TextRow01" >
			<td>&nbsp;Colores&nbsp;</td>
			<td>
                Fondo y Texto&nbsp;<%=fb.select("item_decoration","redBlack=Rojo y negro,redWhite=Rojo y blanco,greenBlack=Verde y negro,greenWhite=Verde y blanco,yellowBlack=Amarillo y negro, yellowWhite=Amarillo y blanco,blueBlack=Azul y negro, blueWhite=Azul y blanco,pinkBlack=Rosado y negro,pinkWhite=Rosado y blanco",cdo.getColValue("item_decoration"),false,false,0,"","","",null,"S")%>
            </td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;Incremento en Precio de Venta&nbsp; Art. Replicado</td>
			<td>Porcentaje<%=fb.decBox("porc_inc_far",cdo.getColValue("porc_inc_far"),false,false,false,3,3)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;Familia de Consignaci&oacute;n&nbsp;</td>
			<td><%=fb.checkbox("consignacion","S",(cdo.getColValue("consignacion") != null && cdo.getColValue("consignacion").equalsIgnoreCase("S")),false)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;Permite costo Cero &nbsp;</td>
			<td><%=fb.checkbox("costo_cero","S",(cdo.getColValue("costo_cero") != null && cdo.getColValue("costo_cero").equalsIgnoreCase("S")),false)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_inv_familia_articulo");
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("nombre",request.getParameter("name"));
	if(request.getParameter("ctas1")==null)cdo.addColValue("cat_cta1","");
    else cdo.addColValue("cat_cta1",request.getParameter("ctas1"));
	if(request.getParameter("ctas2")==null)cdo.addColValue("cat_cta2","");
    else cdo.addColValue("cat_cta2",request.getParameter("ctas2"));
	if(request.getParameter("ctas3")==null)cdo.addColValue("cat_cta3","");
    else cdo.addColValue("cat_cta3",request.getParameter("ctas3"));
	if(request.getParameter("ctas4")==null)cdo.addColValue("cat_cta4","");
    else cdo.addColValue("cat_cta4",request.getParameter("ctas4"));
	if(request.getParameter("ctas5")==null)cdo.addColValue("cat_cta5","");
    else cdo.addColValue("cat_cta5",request.getParameter("ctas5"));
	if(request.getParameter("ctas6")==null)cdo.addColValue("cat_cta6","");
    else cdo.addColValue("cat_cta6",request.getParameter("ctas6"));
	if(request.getParameter("nivel")==null)cdo.addColValue("nivel","");
    else cdo.addColValue("nivel",request.getParameter("nivel"));
    
    if(request.getParameter("item_decoration") != null) cdo.addColValue("item_decoration",request.getParameter("item_decoration"));
	
	//cdo.addColValue("cat_cta1",request.getParameter("ctas1"));
	//cdo.addColValue("cat_cta2",request.getParameter("ctas2"));
	//cdo.addColValue("cat_cta3",request.getParameter("ctas3"));
	//cdo.addColValue("cat_cta4",request.getParameter("ctas4"));
	//cdo.addColValue("CAT_CTA5",request.getParameter("ctas5"));
	//cdo.addColValue("CAT_CTA6",request.getParameter("ctas6"));
	cdo.addColValue("tipo_servicio",request.getParameter("servicio"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	//cdo.addColValue("nivel",request.getParameter("nivel"));
	if (request.getParameter("placas") == null) cdo.addColValue("placa","N");
	else cdo.addColValue("placa",request.getParameter("placas"));
	if (request.getParameter("marbete") == null) cdo.addColValue("marbete","N");
	else cdo.addColValue("marbete",request.getParameter("marbete"));
	if (request.getParameter("incremento_venta") == null) cdo.addColValue("incremento_venta","N");
	else cdo.addColValue("incremento_venta",request.getParameter("incremento_venta"));
	cdo.addColValue("porc_incremento",request.getParameter("porc_incremento"));
	cdo.addColValue("porc_inc_far",request.getParameter("porc_inc_far"));
	cdo.addColValue("consignacion",request.getParameter("consignacion"));
	cdo.addColValue("costo_cero",request.getParameter("costo_cero"));

	cdo.setCreateXML(true);
	cdo.setFileName("itemFamily.xml");
	cdo.setOptValueColumn("cod_flia");
	cdo.setOptLabelColumn("cod_flia||' - '||nombre");
	cdo.setKeyColumn("compania");
	cdo.setXmlWhereClause("");

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add")) {
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
		cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.setAutoIncCol("cod_flia");
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));

		SQLMgr.insert(cdo);
	} else {
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_flia="+request.getParameter("code"));

		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/familia_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/familia_list.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/inventario/familia_list.jsp';
<% } %>
	window.close();
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
