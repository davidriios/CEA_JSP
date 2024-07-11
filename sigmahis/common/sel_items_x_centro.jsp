<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="FTransDet" scope="session" class="issi.facturacion.FactTransaccion" />
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
XML.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
int rowCount = 0;
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cs 				= request.getParameter("cs");
String index = request.getParameter("index");
String curIndex = request.getParameter("curIndex");
String context = request.getParameter("context")==null?"":request.getParameter("context");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (cs == null) cs = "";


if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

	String tipoServicio = request.getParameter("tipoServicio");
	String trabajo = request.getParameter("trabajo");
	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (tipoServicio == null) tipoServicio = "";
	if (trabajo == null) trabajo = "";
	if (codigo == null) codigo = "";
	if (!codigo.trim().equals("")){trabajo=codigo;}
	if (descripcion == null) descripcion = "";
	if (!tipoServicio.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("tipo_servicio = '"); sbFilter.append(tipoServicio); sbFilter.append("'"); }
	
	if (!trabajo.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(trabajo) like '%"); sbFilter.append(trabajo.toUpperCase()); sbFilter.append("%'"); }
	
	if (!descripcion.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }

		sbSql = new StringBuffer();
		//if (almacen != null && !almacen.trim().equals(""))
		//{
			//articulo
			sbSql.append("select (select nvl(tipo_servicio,' ') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as tipo_servicio, (select nvl((select descripcion from tbl_cds_tipo_servicio where codigo=z.tipo_servicio),' ') from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and compania = a.compania) as tipo_serv_desc, a.descripcion, ''||a.cod_articulo as trabajo, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, ");
			sbSql.append("0 as inv_almacen, a.cod_flia as art_familia, a.cod_clase as art_clase, a.cod_articulo as inv_articulo, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'S' as inventario,0 as cantidad_disponible, 0 as centro_costo,'ART' keyCargo from tbl_inv_articulo a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.estado = 'A' ");
			if(!cs.trim().equals("")){
			sbSql.append(" and exists (select z.tipo_servicio from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
			sbSql.append(cs);
			sbSql.append(" and tipo_servicio = z.tipo_servicio))");
			}
			sbSql.append(" union all ");
		//}*/
		//habitacion
		sbSql.append("select (select tipo_servicio from tbl_sal_habitacion where codigo = a.habitacion and compania = a.compania) as tipo_servicio, (select (select descripcion from tbl_cds_tipo_servicio where codigo=z.tipo_servicio) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as tipo_serv_desc, (select (select descripcion from tbl_cds_centro_servicio where codigo=z.unidad_admin) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as descripcion, ''||a.habitacion as trabajo, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, a.habitacion, a.tipo_hab as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'HAB' keyCargo from tbl_sal_cama a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estado_cama not in ('I') ");
			if(!cs.trim().equals("")){
			sbSql.append(" and exists (select z.unidad_admin from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania and z.unidad_admin = ");
		sbSql.append(cs);
		sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = z.unidad_admin and tipo_servicio = z.tipo_servicio))");
		}
		//producto_x_cds
		sbSql.append(" union all ");
		sbSql.append("select a.tser as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tser) as tipo_serv_desc, a.descripcion, /*nvl(a.cpt,''||a.codigo)*/ nvl(''||a.codigo,'') as trabajo, ' ' as procedimiento, 0 as otros_cargos, a.codigo as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, 0 as cod_uso, 0 as costo_art, nvl(a.incremento,'S') as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'PROD' keyCargo from tbl_cds_producto_x_cds a where a.estatus = 'A'  ");
			if(!cs.trim().equals("")){
			sbSql.append(" and a.cod_centro_servicio = ");
		sbSql.append(cs);}
		sbSql.append(" and  exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = a.cod_centro_servicio and tipo_servicio = a.tser)");

		//uso
		sbSql.append(" union all ");
		sbSql.append("select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as tipo_serv_desc, a.descripcion,/* ''||*/  ''||a.codigo as trabajo, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, a.codigo as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'USO' keyCargo from tbl_sal_uso a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estatus = 'A' ");
			if(!cs.trim().equals("")){
			sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = a.tipo_servicio)");}
		// PROCEDIMIENTO
		sbSql.append(" union all ");
		sbSql.append("select '07' as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo='07') as tipo_serv_desc, decode(a.observacion, null, a.descripcion, a.observacion) descripcion,/*''||*/ ''||a.codigo as trabajo, a.codigo  as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo ,'PROC' keyCargo from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo=b.cod_procedimiento and a.estado = 'A' ");
			if(!cs.trim().equals("")){
			sbSql.append(" and b.cod_Centro_servicio=");
		sbSql.append(cs);}
		sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append("  b.cod_Centro_servicio ");
		sbSql.append(" /*and tipo_servicio = '07' */ )");

	if(request.getParameter("trabajo") != null || request.getParameter("descripcion") != null) 
	{
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a "+sbFilter+" order by tipo_serv_desc, descripcion) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+") "+sbFilter);
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
  
  String jsContext = "window.opener.";
  if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Centro de Servicio - '+document.title;
function doAction(){<% if(context.equalsIgnoreCase("preventPopupFrame")) { if (al.size()==1){%> setValue(0); <%}}%>}
function setValue(i)
{
  <%if (fp.equalsIgnoreCase("convenio_beneficio_new")){%>
    <%=jsContext%>document.getElementById("codigo_detalle<%=curIndex%>").value = eval('document.detail.trabajo'+i).value;
    <%=jsContext%>document.getElementById("desc_detalle<%=curIndex%>").value = eval('document.detail.descripcion'+i).value;  
	 <%=jsContext%>document.getElementById("ref_type<%=curIndex%>").value = eval('document.detail.keyCargo'+i).value;  
	  //<%=jsContext%>document.getElementById("tipo_servicio<%=curIndex%>").value = eval('document.detail.tipo_servicio'+i).value;  
  <%}else{%>
			window.opener.document.form0.items.value = eval('document.detail.trabajo'+i).value;
			window.opener.document.form0.descripcion.value = eval('document.detail.descripcion'+i).value;
			if(window.opener.document.form0.keyCargo)window.opener.document.form0.keyCargo.value = eval('document.detail.keyCargo'+i).value;
	<%}%>		
	 <%if(context.equalsIgnoreCase("preventPopupFrame")){%>
           <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
		<%}else{%>window.close();<%}%>

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE SERVICIOS POR CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("curIndex",curIndex)%> 
<%=fb.hidden("context",context)%>
<%=fb.hidden("codigo",codigo)%>
			<td width="40%">
				Tipo Servicio
				<%=fb.select(ConMgr.getConnection(),"select distinct a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)||' - '||a.tipo_servicio as descripcion, a.tipo_servicio from tbl_cds_servicios_x_centros a where "+((!cs.trim().equals(""))?" a.centro_servicio="+cs+" and ":" ")+"  exists (select tipo_servicio from tbl_cds_tipo_servicio where codigo = a.tipo_servicio) order by 2 desc","tipoServicio",tipoServicio,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<td width="12%">
				C&oacute;digo
				<%=fb.textBox("trabajo",trabajo,false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="35%">
				Desc. de Cargo
				<%=fb.textBox("descripcion",descripcion,false,false,false,30,"Text10",null,null)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("curIndex",curIndex)%> 
<%=fb.hidden("context",context)%>
<%=fb.hidden("codigo",codigo)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("curIndex",curIndex)%> 
<%=fb.hidden("context",context)%>
<%=fb.hidden("codigo",codigo)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
String onSubmit = "";
//if(fg.equals("FH")) onSubmit = "onSubmit=\"javascript:return(chkValues())\"";
fb = new FormBean("detail","","post",onSubmit);
%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("curIndex",curIndex)%> 
<%=fb.hidden("context",context)%>
<%=fb.hidden("codigo",codigo)%>
		<tr>
			<td align="right" colspan="6"></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%">Servicio</td>
			<td width="33%">Descripci&oacute;n</td>
			<td width="10%">C&oacute;digo</td>
			<td width="34%">Descripci&oacute;n</td>
			<td width="3%">&nbsp;</td>
		</tr>
<%=fb.hidden("cs",cs)%>
<%
String onCheck = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	//onCheck = "onClick=\"javascript:chkValues("+i+");\"";
	%>
<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
<%=fb.hidden("tipo_serv_desc"+i,cdo.getColValue("tipo_serv_desc"))%>
<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
<%=fb.hidden("trabajo"+i,cdo.getColValue("trabajo"))%>
<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
<%=fb.hidden("servicio_hab"+i,cdo.getColValue("servicio_hab"))%>
<%=fb.hidden("cds_producto"+i,cdo.getColValue("cds_producto"))%>
<%=fb.hidden("cod_uso"+i,cdo.getColValue("cod_uso"))%>
<%=fb.hidden("centro_costo"+i,cdo.getColValue("centro_costo"))%>
<%=fb.hidden("costo_art"+i,cdo.getColValue("costo_art"))%>
<%=fb.hidden("procedimiento"+i,cdo.getColValue("procedimiento"))%>
<%=fb.hidden("otros_cargos"+i,cdo.getColValue("otros_cargos"))%>
<%=fb.hidden("usar_alert"+i,cdo.getColValue("usar_alert"))%>
<%=fb.hidden("precio1_"+i,cdo.getColValue("precio1"))%>
<%=fb.hidden("precio2_"+i,cdo.getColValue("precio2"))%>
<%=fb.hidden("recargo"+i,cdo.getColValue("recargo"))%>
<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>

<%=fb.hidden("tipo_cargo"+i,cdo.getColValue("tipo_cargo"))%>
<%=fb.hidden("cod_paq_x_cds"+i,cdo.getColValue("cod_paq_x_cds"))%>
<%=fb.hidden("tipo_transaccion"+i,cdo.getColValue("tipo_transaccion"))%>
<%=fb.hidden("fac_codigo"+i,cdo.getColValue("fac_codigo"))%>
<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
<%=fb.hidden("fecha_cargo"+i,cdo.getColValue("fecha_cargo"))%>

<%=fb.hidden("cant_cargo"+i,cdo.getColValue("cantidad_cargo"))%>
<%=fb.hidden("cant_devolucion"+i,cdo.getColValue("cantidad_devolucion"))%>
<%=fb.hidden("inv_almacen"+i,cdo.getColValue("inv_almacen"))%>
<%=fb.hidden("art_familia"+i,cdo.getColValue("art_familia"))%>
<%=fb.hidden("art_clase"+i,cdo.getColValue("art_clase"))%>
<%=fb.hidden("inv_articulo"+i,cdo.getColValue("inv_articulo"))%>
<%=fb.hidden("inventario"+i,cdo.getColValue("inventario"))%>
<%=fb.hidden("cantidad_disponible"+i,cdo.getColValue("cantidad_disponible"))%>
<%=fb.hidden("keyCargo"+i,cdo.getColValue("keyCargo"))%>
<%
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = "";

%>		
    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValue('<%=i%>')">

			<td align="center"><%=cdo.getColValue("tipo_servicio")%></td>
			<td>&nbsp;<%=cdo.getColValue("tipo_serv_desc")%></td>
			<% if(cdo.getColValue("trabajo").indexOf("--")!=-1){ %>
			<td bgcolor="#FFFFFF" align="center"><%=cdo.getColValue("trabajo")%></td>
			<% }else{ %>
			<td align="center"><%=cdo.getColValue("trabajo")%></td>
			<% } %>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="right"></td> 
		</tr>
<%
}
if(al.size()==0){
%>
		<tr align="center" class="TextRow01">
			<td colspan="6">No Registros Encontrados</td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("curIndex",curIndex)%> 
<%=fb.hidden("context",context)%>
<%=fb.hidden("codigo",codigo)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("curIndex",curIndex)%> 
<%=fb.hidden("context",context)%>
<%=fb.hidden("codigo",codigo)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//get
%>