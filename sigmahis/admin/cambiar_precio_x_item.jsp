<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%> 
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%> 
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbTables = new StringBuffer();
StringBuffer sbCols = new StringBuffer();

String filter1 = request.getParameter("filter1");
String categoria = request.getParameter("categoria");
String tipoServ = request.getParameter("tipoServ");
String cds = request.getParameter("cds");
String nombre = request.getParameter("nombre");
String estado = request.getParameter("estado"); 
String venta = request.getParameter("venta");
String precioVenta = request.getParameter("precioVenta");
String codigo  = request.getParameter("codigo");
String porcentaje = request.getParameter("porcentaje");
String action = request.getParameter("action");
String roundTo = request.getParameter("roundTo");
String basis = request.getParameter("basis");
String processBy = request.getParameter("processBy"); 
String fg = request.getParameter("fg"); 
String actDesc ="";
  
if(fg.trim().equals("PROC")) actDesc +=" PROCEDIMIENTOS ";
else if(fg.trim().equals("USOS")) actDesc +=" TARIFA DE USOS ";
else if(fg.trim().equals("HAB"))actDesc +=" TIPOS DE CAMAS ";
if (categoria == null) categoria = "";
if (tipoServ == null) tipoServ = "";
if (cds == null) cds = "";
if (nombre == null) nombre = "";
if (estado == null) estado = "";
if (venta == null) venta = "";
if (precioVenta == null) precioVenta = "";
if (codigo == null) codigo = "";
if (fg == null) fg = "";

if (porcentaje == null) porcentaje = "0";
if (action == null) action = "1";
if (roundTo == null) roundTo = "";
if (basis == null) basis = "PV";
if (processBy == null) processBy = "I";
 
String warnMsg = "El cambio de precio se aplica sobre la BASE seleccionada (PRECIO VENTA) con valor diferente a cero.";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 400;
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

if(fg.trim().equals("PROC")){ sbTables.append(" tbl_cds_procedimiento a ");sbCols.append(" coalesce(a.observacion,a.descripcion) as descripcion,a.precio, a.tipo_categoria as categoria,decode(a.estado,'A','ACTIVO', 'I','INACTIVO') as estadoDesc ,a.estado,( select nvl(nombre,'SIN CATEGORIA') from tbl_cds_tipo_categoria where codigo=a.tipo_categoria ) as descCategoria,  "); }
else if(fg.trim().equals("USOS")){sbTables.append(" tbl_sal_uso a");sbCols.append(" a.descripcion,a.precio_venta as precio, '' as categoria,decode(a.estatus,'A','ACTIVO', 'I','INACTIVO') as estadoDesc,a.estatus as estado, nvl((select descripcion from tbl_cds_tipo_servicio ts  where ts.codigo=a.tipo_servicio and ts.compania =a.compania ),' ')  descServicio , ");}
else if(fg.trim().equals("HAB")){sbTables.append(" tbl_sal_tipo_habitacion  a ");sbCols.append(" a.descripcion, a.precio,'' as categoria, decode(a.estatus,'A','ACTIVO', 'I','INACTIVO') as estadoDesc,a.estatus,'' centroDesc, ");} 


 	if (!estado.trim().equals("")) {if(fg.trim().equals("USOS"))sbFilter.append(" and upper(a.estatus) = '"); else if(fg.trim().equals("HAB"))sbFilter.append(" and upper(a.estatus) = '"); else sbFilter.append(" and upper(a.estado) = '");  
	
	sbFilter.append(estado); sbFilter.append("'"); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and a.codigo = '"); sbFilter.append(codigo); sbFilter.append("'"); }
	if (!nombre.trim().equals("")) {
		if(fg.trim().equals("PROC")) sbFilter.append(" and upper(coalesce(a.observacion,a.descripcion)) like '%");
		else if(fg.trim().equals("USOS"))sbFilter.append(" and upper(a.descripcion) like '%");
		else if(fg.trim().equals("HAB"))sbFilter.append(" and upper(a.descripcion) like '%");
		  
 		sbFilter.append(nombre.toUpperCase());sbFilter.append("%'"); 
 	}
	 
 	if (!tipoServ.trim().equals("")) { sbFilter.append(" and a.tipo_servicio='"); sbFilter.append(tipoServ); sbFilter.append("'"); }
	if (!categoria.trim().equals("")) { sbFilter.append(" and a.tipo_categoria="); sbFilter.append(categoria); }
	
 	if (precioVenta.equalsIgnoreCase("1")){ if(fg.trim().equals("USOS"))sbFilter.append(" and a.precio_venta > 0");else sbFilter.append(" and a.precio > 0");}
	else if (precioVenta.equalsIgnoreCase("0")){ if(fg.trim().equals("USOS"))sbFilter.append(" and nvl(a.precio_venta,0) = 0 ");else sbFilter.append(" and a.precio = 0");}
 	
 	if (request.getParameter("beginSearch") != null) {
		sbSql = new StringBuffer();
        
        sbSql.append("select ");
        sbSql.append(sbCols); 
		sbSql.append("a.codigo, (select count(*) from tbl_fac_pricexlote where codigo = a.codigo and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and tipo ='");
		sbSql.append(fg);
		sbSql.append("'  ) as precioHistorico from ");
		
        sbSql.append(sbTables);
         
        if(!fg.trim().equals("PROC")){sbSql.append(" where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));}
         else sbSql.append(" where a.codigo is not null ");
        
		sbSql.append(sbFilter);
		sbSql.append(" order by 4,1 ");
		System.out.println("SQL==="+sbSql.toString());
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - Articulos - '+document.title;
function doProcess(){
  var porcentaje=document.form0.porcentaje.value;
  var accion=document.form0.action.value;
  var roundTo=document.form0.roundTo.value;
  var basis=document.form0.basis.value;
  if(porcentaje=='0'||porcentaje=='')CBMSG.warning('Revise el porcentaje a aplicar!!');
  else showPopWin('../process/fac_cambiar_precio_lote.jsp?fp=BATCH_PRICE&actType=51&docType=BATCH_PRICE&compania=<%=session.getAttribute("_companyId")%>&codigo=<%=codigo%>&cds=<%=cds%>&fg=<%=fg%>&categoria=<%=categoria%>&tipoServ=<%=tipoServ%>&estado=<%=estado%>&nombre=<%=nombre%>&precioVenta=<%=precioVenta%>&accion='+accion+'&roundTo='+roundTo+'&basis='+basis+'&porcentaje='+porcentaje,winWidth*.75,winHeight*.65,null,null,'');
}
function forPrinting(){showPopWin('../inventario/print_precioxlote_param.jsp?fg=<%=fg%>&code=<%=(request.getParameter("codigo")==null?"":request.getParameter("codigo"))%>&actDesc=<%=actDesc%>',winWidth*.75,winHeight*.65,null,null,'');}
function getCheckedVal(){var al = "<%=al.size()%>";var total = 0;for (i = 0; i<al; i++){if (eval("document.formDetail.check"+i).checked==true){total++;}}return total;}
function showPriceHistory(ind){ 
	 var itemDesc=eval('document.formDetail.descripcion'+ind).value;
	 var itemCode=eval('document.formDetail.codigo'+ind).value;
	 showPopWin('../inventario/list_price_history.jsp?itemCode='+itemCode+'&fg=<%=fg%>&companyCode=<%=session.getAttribute("_companyId")%>&itemDesc='+itemDesc+'&itemFamilyDesc=<%=actDesc%>',winWidth*.75,winHeight*.65,null,null,'');
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function doSearch(){document.search00.submit();}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("fg",""+fg)%>
		
				<tr class="TextFilter">
			<td colspan="2">
			<%if(fg.trim().equals("PROC")){%>
				 <cellbytelabel>Categor&iacute;a</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, rango from tbl_cds_tipo_categoria order by 2","categoria",categoria,"T")%>
 			<%}if(fg.trim().equals("USOS")){%>
				 <cellbytelabel>Tipo Servicio </cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select distinct a.codigo, a.descripcion, a.codigo from tbl_cds_tipo_servicio a where compania ="+(String) session.getAttribute("_companyId")+"order by a.descripcion","tipoServ",tipoServ,"T")%><%}%>	
			
			</td>
		</tr>

		<tr class="TextFilter">
			<td colspan="2">
				<cellbytelabel>Estado</cellbytelabel>
				<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"T")%>
				
				<cellbytelabel>C&oacute;digo Item</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,10,null,null,null)%>
				<cellbytelabel>Descripcion</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,20,null,null,null)%>
				Precio:
				<%=fb.select("precioVenta","1|CON PRECIO,0|SIN PRECIO",precioVenta,false,false,0,null,null,null,null,"T",null,null,"|")%>
				<cellbytelabel>ACTUALIZAR POR</cellbytelabel>
				<%=fb.select("processBy","I=ITEM, P=PARAMETROS DE BUSQUEDA",processBy,false,false,0,"Text10",null,"onChange=\"javascript:doSearch()\"",null,"")%>
				<%//=fb.select("cds","",cds,false,false,0,"Text10",null,"onChange=\"javascript:doSearch()\"",null,(xCds.indexOf(",")==-1)?"":"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
<% if (processBy.equalsIgnoreCase("P")) { %>
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%> 
<%=fb.hidden("fg",""+fg)%>
		<tr class="TextHeader02">
			<td align="right"><label class="RedText"><%=warnMsg%></label></td>
		</tr>
		<tr class="TextHeader02">
			<td align="right">
				<cellbytelabel>Porcentaje</cellbytelabel>: <%=fb.decPlusBox("porcentaje",porcentaje,true,false,(al.size() == 0),5,2.2,"Text10","","")%>
				<cellbytelabel>Acci&oacute;n</cellbytelabel>: <%=fb.select("action","1=INCREMENTAR,-1=DECREMENTAR",action,true,false,(al.size() == 0),0,"S")%>
				<cellbytelabel>Aplicar Aproximaci&oacute;n: <%=fb.select("roundTo","0=NO,0.05=SI",roundTo,false,false,(al.size() == 0),0,null,null,null)%>
				<cellbytelabel>Base</cellbytelabel>: <%=fb.select("basis","PV=PRECIO VENTA",basis,true,false,(al.size() == 0),0)%>
				<authtype type="50"><%=fb.button("save","Actualizar Precio",true,(al.size() == 0),null,null,"onClick=\"javascript:doProcess()\"")%></authtype>
				<authtype type="0"><%=fb.button("printParam","Imprimir",true,(al.size() == 0),null,null,"onClick=\"javascript:forPrinting()\"")%></authtype>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
<% } %>
	</td>
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
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("nombre",nombre)%> 
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("fg",""+fg)%>
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
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("nombre",nombre)%> 
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("fg",""+fg)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<%fb = new FormBean("formDetail",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("nextVal",""+nxtVal)%>
<%=fb.hidden("previousVal",""+preVal)%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("nombre",nombre)%> 
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("fg",""+fg)%>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<% if (processBy.equalsIgnoreCase("I")) { %>
<%fb.appendJsValidation("if("+al.size()+"==0||(!document.formDetail.check.checked&&getCheckedVal()==0)){alert('Por favor seleccione al menos un (1) Item!');error++;}");%>
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextHeader02">
			<td align="right"><label class="RedText"><%=warnMsg%></label></td>
		</tr>
		<tr class="TextHeader02">
			<td align="right">
				<cellbytelabel>Porcentaje</cellbytelabel>: <%=fb.decPlusBox("porcentaje",porcentaje,true,false,(al.size() == 0),5,2.2,"","","")%>
				<cellbytelabel>Acci&oacute;n</cellbytelabel>: <%=fb.select("action","1=INCREMENTAR,-1=DECREMENTAR",action,true,false,(al.size() == 0),0,"S")%>
				<cellbytelabel>Aplicar Aproximaci&oacute;n: <%=fb.select("roundTo","0=NO,0.05=SI",roundTo,false,false,(al.size() == 0),0,null,null,null)%>
				<cellbytelabel>Base</cellbytelabel>: <%=fb.select("basis","PV=PRECIO VENTA",basis,true,false,(al.size() == 0),0)%>
				<authtype type="50"><%=fb.submit("save","Actualizar Precio",true,(al.size() == 0),null,null,null)%></authtype>
				<authtype type="0"><%=fb.button("printParam","Imprimir",true,(al.size() == 0),null,null,"onClick=\"javascript:forPrinting()\"")%></authtype>
			</td>
		</tr>
		</table>
<% } %>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Precio Anterior</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Precio Venta</cellbytelabel></td>  
			<td width="11%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="25%"><cellbytelabel><%if(fg.trim().equals("USOS")){%>Tipo Servicio<%}else if(fg.trim().equals("HAB")){%>&nbsp;<%}else if(fg.trim().equals("PROC")){%> Categoria<%}%></cellbytelabel></td>
			
<% if (processBy.equalsIgnoreCase("P")) { %>			
			<td width="5%">&nbsp;</td>
<% } else { %>
			<td width="5%"><authtype type="50"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Items listados!")%></authtype></td>
<% } %>
		</tr>
<%
String familyClass = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

 %>
 		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		 
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><% if (Integer.parseInt(cdo.getColValue("precioHistorico")) > 0) { %><a href="javascript:void(0);" class="Link00" onClick="javascript:showPriceHistory('<%=i%>')"><cellbytelabel>Ver</cellbytelabel></a><% } else { %>-<% } %></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>  
			<td align="center"><%=cdo.getColValue("estadoDesc")%></td>
			<td width="25%"><%if(fg.trim().equals("USOS")){%><%=cdo.getColValue("descServicio")%><%}else if(fg.trim().equals("HAB")){%><%=cdo.getColValue("centroDesc")%><%}else if(fg.trim().equals("PROC")){%> <%=cdo.getColValue("descCategoria")%><%}%></td>
			<td align="center"><% if (!processBy.equalsIgnoreCase("P")) { %><authtype type="50"><%=fb.checkbox("check"+i,"",false,false,null,null,"","")%></a></authtype><% } %></td>
		</tr>
<%
 }
%>
		</table>
</div>
</div>
	</td>
</tr>
<%=fb.formEnd(true)%>
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
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("nombre",nombre)%> 
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("fg",""+fg)%>
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
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("nombre",nombre)%> 
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("fg",""+fg)%>
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
}else {
	int size = Integer.parseInt(request.getParameter("size"));
	Hashtable<String,CommonDataObject> htParams = new Hashtable<String,CommonDataObject>(); 
	for (int i=0; i<size; i++) {
		if (request.getParameter("check"+i) != null) {
			CommonDataObject param = new CommonDataObject();
			sbSql = new StringBuffer();
			sbSql.append("{ call sp_fac_upd_pricexlote (?,?,?,?,?,?,?,?,?,?,?,?,?) }");
			param.setSql(sbSql.toString());
			param.addInNumberStmtParam(1,(String) session.getAttribute("_companyId")); 
			param.addInStringStmtParam(2,request.getParameter("codigo"+i)); 
			param.addInStringStmtParam(3,"");
			param.addInStringStmtParam(4,"");
			param.addInStringStmtParam(5,"");
			param.addInStringStmtParam(6,"");
			param.addInStringStmtParam(7,"");
			param.addInNumberStmtParam(8,request.getParameter("porcentaje"));
			param.addInNumberStmtParam(9,request.getParameter("action"));
			param.addInNumberStmtParam(10,request.getParameter("roundTo"));
			param.addInStringStmtParam(11,request.getParameter("basis"));
			param.addInNumberStmtParam(12,request.getParameter("precioVenta"));
            param.addInStringStmtParam(13,fg); 
			  
			param.setKey(htParams.size());
			param.setKey(htParams.size());
			try { htParams.put(param.getKey(),param); } catch(Exception e) { System.out.println("Unable to add params!"); }
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"estado="+estado+"&venta="+venta+"&codigo="+codigo+"&porcentaje="+request.getParameter("porcentaje")+"&action="+request.getParameter("action"));
	SQLMgr.executeCallableList(htParams);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
	var locationState = '<%=(request.getParameter("locationState")==null || request.getParameter("locationState").trim().equals("")?request.getContextPath()+"/admin/cambiar_precio_x_item.jsp":request.getParameter("locationState"))%>';
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert("<%=SQLMgr.getErrMsg()%>");
	window.location='<%=request.getContextPath()+request.getServletPath()%>?estado=<%=estado%>&fg=<%=fg%>&nombre=<%=nombre%>&venta=<%=venta%>&codigo=<%=codigo%>&action=<%=action%>&roundTo=<%=roundTo%>&categoria=<%=categoria%>&tipoServ=<%=tipoServ%>&searchQuery=<%=request.getParameter("searchQuery")%>&nextVal=<%=request.getParameter("nextVal")%>&previousVal=<%=request.getParameter("previousVal")%>&searchOn=<%=request.getParameter("searchOn")%>&searchVal=<%=request.getParameter("searchVal")%>&searchType=<%=request.getParameter("searchType")%>&searchDisp=<%=request.getParameter("searchDisp")%>&searchValFromDate=<%=request.getParameter("searchValFromDate")%>&searchValToDate=<%=request.getParameter("searchValToDate")%>&beginSearch=';
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>