<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%> 
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCarDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCarDet" scope="session" class="java.util.Vector"/> 
<jsp:useBean id="iCarAjDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCarAjDet" scope="session" class="java.util.Vector"/> 
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
StringBuffer xCdsFilter = new  StringBuffer();
StringBuffer sbFilter = new  StringBuffer();
StringBuffer sbSql = new  StringBuffer();
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String renglon = request.getParameter("renglon");
String index = request.getParameter("index"); 
String cs = request.getParameter("cs"); 
String fg = request.getParameter("fg");  
String noAdmision=request.getParameter("noAdmision"); 
String pacienteId=request.getParameter("pacienteId");
String factura=request.getParameter("factura");  
String tr=request.getParameter("tr"); 
String nt=request.getParameter("nt"); 
String codigo= request.getParameter("codigo");
String codDet=request.getParameter("codDet"); 
String wh=request.getParameter("wh"); 
String valida_dsp = request.getParameter("valida_dsp"); 

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
String tipoServicio = request.getParameter("tipoServicio");
String trabajo = request.getParameter("trabajo");
String descripcion = request.getParameter("descripcion");
String setCds = request.getParameter("setCds");
if (tipoServicio == null) tipoServicio = "";
if (trabajo == null) trabajo = "";
if (descripcion == null) descripcion = "";      
if (cs == null) cs = "";      
if (fg == null) fg = "";      
if (setCds == null) setCds = "";  
if (wh == null) wh = "";      
if (valida_dsp == null) valida_dsp = "";      

if (request.getMethod().equalsIgnoreCase("GET"))
{    
    int recsPerPage = 100;
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
	
	if (!tipoServicio.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("tipo_servicio = '"); sbFilter.append(tipoServicio); sbFilter.append("'"); }
	
	if (!trabajo.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(trabajo) like '%"); sbFilter.append(trabajo.toUpperCase()); sbFilter.append("%'"); }
	
	if (!descripcion.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	 
	  
	
	
	sbSql.append("select (select nvl(tipo_servicio,' ') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as tipo_servicio, (select nvl((select descripcion from tbl_cds_tipo_servicio where codigo=z.tipo_servicio),' ') from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and compania = a.compania) as tipo_serv_desc, a.descripcion, ''||a.cod_articulo as trabajo, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, ");
			sbSql.append("0 as inv_almacen, a.cod_flia as art_familia, a.cod_clase as art_clase, a.cod_articulo as inv_articulo, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'S' as inventario,0 as cantidad_disponible, 0 as centro_costo,'ART' keyCargo, a.precio_venta as precio");
			sbSql.append(", null as cds,null as cdsDesc,a.other3 as afecta_inv "); 		
			sbSql.append(" from tbl_inv_articulo a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.estado = 'A' and a.venta_sino ='S' ");
			if(!cs.trim().equals("")){
			sbSql.append(" and exists (select z.tipo_servicio from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
			sbSql.append(cs);
			sbSql.append(" and tipo_servicio = z.tipo_servicio))");
			}
			if(!wh.trim().equals("")){
			sbSql.append(" and exists (select null from tbl_inv_inventario z where z.cod_articulo = a.cod_articulo and z.compania = a.compania and z.codigo_almacen=");
			sbSql.append(wh);
			sbSql.append("  )");
			}
			sbSql.append(" union all ");
		//}*/
		//habitacion
		sbSql.append("select (select tipo_servicio from tbl_sal_habitacion where codigo = a.habitacion and compania = a.compania) as tipo_servicio, (select (select descripcion from tbl_cds_tipo_servicio where codigo=z.tipo_servicio) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as tipo_serv_desc, (select (select descripcion from tbl_cds_centro_servicio where codigo=z.unidad_admin) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as descripcion, ''||a.codigo as trabajo, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, a.habitacion, a.tipo_hab as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'HAB' keyCargo,nvl((select precio from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania),0) as precio");
			
			if(setCds.trim().equals("S")){sbSql.append(", (select z.unidad_admin from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as cds ,(select (select descripcion from tbl_cds_centro_servicio where codigo=z.unidad_admin) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as cdsDesc"); }
			else sbSql.append(", null as cds ,null as cdsDesc "); 		
			sbSql.append(", '' as afecta_inv ");
			sbSql.append(" from tbl_sal_cama a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estado_cama not in ('I') ");
			if(!cs.trim().equals("")){
			sbSql.append(" and exists (select z.unidad_admin from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania and z.unidad_admin = ");
		sbSql.append(cs);
		sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = z.unidad_admin and tipo_servicio = z.tipo_servicio))");
		}
		//producto_x_cds
		sbSql.append(" union all ");
		sbSql.append("select distinct a.tser as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tser) as tipo_serv_desc, a.descripcion, /*nvl(a.cpt,''||a.codigo)*/ ''||a.codigo  as trabajo, ' ' as procedimiento, 0 as otros_cargos, a.codigo as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, 0 as cod_uso, 0 as costo_art, nvl(a.incremento,'S') as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'PROD' keyCargo,nvl(a.precio,0) as precio");
			sbSql.append(", null as cds,null as cdsDesc "); 
			sbSql.append(", '' as afecta_inv ");		
			sbSql.append(" from tbl_cds_producto_x_cds a where a.estatus = 'A'  ");
			if(!cs.trim().equals("")){
			sbSql.append(" and a.cod_centro_servicio = ");
		sbSql.append(cs);}
		sbSql.append(" and  exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = a.cod_centro_servicio and tipo_servicio = a.tser)");

		//uso
		sbSql.append(" union all ");
		sbSql.append("select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as tipo_serv_desc, a.descripcion,/* ''||*/  ''||a.codigo as trabajo, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, a.codigo as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'USO' keyCargo,nvl(a.precio_venta,0) as precio ");
			sbSql.append(", null as cds,null as cdsDesc "); 	
			sbSql.append(", '' as afecta_inv ");	
			sbSql.append(" from tbl_sal_uso a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estatus = 'A' ");
			if(!cs.trim().equals("")){
			sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = a.tipo_servicio)");}
		// PROCEDIMIENTO
		//if(setCds.trim().equals("S")){
		sbSql.append(" union all ");
		sbSql.append("select distinct '07' as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo='07') as tipo_serv_desc, decode(a.observacion, null, a.descripcion, a.observacion) descripcion,/*''||*/ ''||a.codigo as trabajo, a.codigo  as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo ,'PROC' keyCargo,nvl(a.precio,0) as precio ");
			if(setCds.trim().equals("S")){sbSql.append(", b.cod_Centro_servicio as cds ,(select descripcion from tbl_cds_centro_servicio where codigo=b.cod_Centro_servicio ) as cdsDesc"); }
			else sbSql.append(", null as cds ,null as cdsDesc "); 		
			sbSql.append(", '' as afecta_inv ");
			sbSql.append(" from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo=b.cod_procedimiento and a.estado = 'A' ");
			if(!cs.trim().equals("")){
			sbSql.append(" and b.cod_Centro_servicio=");
		sbSql.append(cs);}
		sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append("  b.cod_Centro_servicio ");
		sbSql.append(" /*and tipo_servicio = '07' */ )");
		
		
		
	if(request.getParameter("trabajo") != null) 
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
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Servicios - '+document.title;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function chkValue(i){ 
	var art_flia 			= '';
	var art_clase 			= '';
	var cod_art 			= eval('document.result.trabajo'+i).value;
	var cantidad 			= parseInt(eval('document.result.cantidad'+i).value);
	var afecta_inv 			= eval('document.result.afecta_inv'+i).value;
	var keyCargo 			= eval('document.result.keyCargo'+i).value;
	var cia					= '<%=session.getAttribute("_companyId")%>';
	var almacen				= '<%=wh%>';
	//alert('xxxxxxxxx valida_dsp== <%=valida_dsp%>    WH = '+almacen+'   afecta_inv='+afecta_inv);
	<%if(valida_dsp.trim().equals("S")){%>
	if(afecta_inv=='Y' && keyCargo=='ART')
	{
		var disponible = getInvDisponible('<%=request.getContextPath()%>', cia,almacen,art_flia,art_clase,cod_art);
		if(disponible <= 0)
		{
			alert('No hay disponibilidad para este artículo');
			eval('document.result.cantidad'+i).value = 0;
		} 
		else if(cantidad <= disponible)
		{
			setChecked(eval('document.result.cantidad'+i), eval('document.result.check'+i));
		} 
		else
		{
			alert('La cantidad introducida supera la disponible');
			
			eval('document.result.cantidad'+i).value = 0;
		}
	}
	<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE ITEMS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("renglon",""+renglon)%> 
<%=fb.hidden("index",""+index)%>  
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("setCds",setCds)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("factura",factura)%>
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("nt",nt)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("codDet",codDet)%> 
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("valida_dsp",valida_dsp)%>

		<tr class="TextFilter">
			<td width="40%">			
				Centro Servicio
				<%=fb.select(ConMgr.getConnection(),"select codigo  as optValueColumn, descripcion as optLabelColumn from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+((fp.trim().equals("cargo_dev"))?" and codigo="+cs:"")+" and estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))","cs",cs,false,false,0,"Text10",null,null,null,"T")%>
			&nbsp; &nbsp; &nbsp;
				Tipo Servicio
				<%=fb.select(ConMgr.getConnection(),"select distinct a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)||' - '||a.tipo_servicio as descripcion, a.tipo_servicio from tbl_cds_servicios_x_centros a where "+((!cs.trim().equals(""))?" a.centro_servicio="+cs+" and ":" ")+"  exists (select tipo_servicio from tbl_cds_tipo_servicio where codigo = a.tipo_servicio "+((fp.trim().equals("cargo_dev"))?" and codigo="+tipoServicio:"")+" ) order by 2 desc","tipoServicio",tipoServicio,false,false,0,"Text10",null,null,null,((fp.trim().equals("cargo_dev"))?"":"T"))%>
			 &nbsp; &nbsp; &nbsp;
				C&oacute;digo
				<%=fb.textBox("trabajo",trabajo,false,false,false,20,"Text10",null,null)%>
			&nbsp; &nbsp; &nbsp;
				Desc. de Cargo
				<%=fb.textBox("descripcion",descripcion,false,false,false,30,"Text10",null,null)%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextVal",""+(nxtVal))%>
<%=fb.hidden("previousVal",""+(preVal))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("renglon",""+renglon)%> 
<%=fb.hidden("index",""+index)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("setCds",setCds)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("factura",factura)%>
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("nt",nt)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("codDet",codDet)%> 
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("valida_dsp",valida_dsp)%>
        
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveNcont","Agregar y Continuar",true,false)%>
				<%=fb.submit("save","Agregar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
				<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader" align="center">
				<%if(setCds.trim().equals("S")){%>
				<td width="20%">Centro de Servicio</td>
				<td width="20%">Tipo Servicio</td>
				<td width="10%">C&oacute;digo</td>
				<td width="25%">Descripci&oacute;n</td>
				<%}else{%> 
				<td width="25%">Tipo Servicio</td>
				<td width="10%">C&oacute;digo</td>
				<td width="40%">Descripci&oacute;n</td>
				<%}%>
				
				<td width="10%">Cantidad</td>
				<td width="10%">Monto</td>
				<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los item listados!")%></td>
			</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
		<%=fb.hidden("keyCargo"+i,cdo.getColValue("keyCargo"))%>
		<%=fb.hidden("tipo_serv_desc"+i,cdo.getColValue("tipo_serv_desc"))%>
		<%=fb.hidden("trabajo"+i,cdo.getColValue("trabajo"))%>
		<%=fb.hidden("precioItem"+i,cdo.getColValue("precio"))%> 
		<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>  
		<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>  
		<%=fb.hidden("afecta_inv"+i,cdo.getColValue("afecta_inv"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"> 
			<%if(setCds.trim().equals("S")){%>
			<td><%=cdo.getColValue("cdsDesc")%></td><%}%>			
			<td><%=cdo.getColValue("cds")%>-<%=cdo.getColValue("tipo_serv_desc")%></td>
			<% if(cdo.getColValue("trabajo").indexOf("--")!=-1){ %>
			<td bgcolor="#FFFFFF" align="center"><%=cdo.getColValue("trabajo")%></td>
			<% }else{ %>
			<td align="center"><%=cdo.getColValue("trabajo")%></td>
			<% } %>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td><%//=fb.intBox("cantidad"+i,"",false,false,false,15,3)%>
			    <%=fb.intBox("cantidad"+i,"0",false,false,false,3, 4, "", "", "onChange=\"javascript:chkValue("+i+")\"","",false)%></td>
			
			<td><%=fb.decBox("precio"+i,cdo.getColValue("precio"),false,false,(fp.equalsIgnoreCase("cargo_dev")?true:false),15,15.2)%></td>
			<td align="center"><%=((fp.equalsIgnoreCase("cotizacion") && vCarDet.contains(cdo.getColValue("trabajo")+"-"+cdo.getColValue("keyCargo")))||(fp.equalsIgnoreCase("cargo_dev") && vCarAjDet.contains(cdo.getColValue("trabajo")+"-"+cdo.getColValue("keyCargo"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("trabajo"),false,false)%></td>
		</tr>
<%
}
%>
		</table>
</div>
</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveNcont2","Agregar y Continuar",true,false)%>
				<%=fb.submit("save2","Agregar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr> 

<%=fb.formEnd()%>
</table>
</body>
</html>
<%
} else {
	int size = Integer.parseInt(request.getParameter("size"));
	int hours = 0;
	int mins = 0;
	if (fp.equalsIgnoreCase("cotizacion")||fp.equalsIgnoreCase("cargo_dev"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
  
		 		cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+i));
				cdo.addColValue("keyCargo",request.getParameter("keyCargo"+i));
				cdo.addColValue("cds",request.getParameter("cs")); 
				cdo.addColValue("descTs",request.getParameter("tipo_serv_desc"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
				cdo.addColValue("precio",request.getParameter("precio"+i)); 
				cdo.addColValue("precioItem",request.getParameter("precioItem"+i));  
				cdo.addColValue("trabajo",request.getParameter("trabajo"+i));  
				cdo.addColValue("other1",request.getParameter("habitacion"+i)); 
				if(fp.equalsIgnoreCase("cargo_dev"))cdo.addColValue("afecta_inv",request.getParameter("afecta_inv"+i)); 
				if(setCds.trim().equals("S")&&fp.equalsIgnoreCase("cotizacion"))cdo.addColValue("cds",request.getParameter("cds"+i));  
				if(fp.equalsIgnoreCase("cargo_dev"))cdo.addColValue("estado","I"); 
				
				cdo.addColValue("codigo","0");  

				if (fp.equalsIgnoreCase("cotizacion"))cdo.setKey(iCarDet.size() + 1);
				if (fp.equalsIgnoreCase("cargo_dev"))cdo.setKey(iCarAjDet.size() + 1);
				cdo.setAction("I");

				try
				{
					if (fp.equalsIgnoreCase("cotizacion"))iCarDet.put(cdo.getKey(),cdo);
					if (fp.equalsIgnoreCase("cotizacion"))vCarDet.add(cdo.getColValue("trabajo")+"-"+cdo.getColValue("keyCargo"));
					if (fp.equalsIgnoreCase("cargo_dev"))iCarAjDet.put(cdo.getKey(),cdo);
					if (fp.equalsIgnoreCase("cargo_dev"))vCarAjDet.add(cdo.getColValue("trabajo")+"-"+cdo.getColValue("keyCargo"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
	
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{			
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cs="+cs+"&tipoServicio="+tipoServicio+"&trabajo="+trabajo+"&descripcion="+descripcion+"&renglon="+renglon+"&index="+index+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&beginSearch="+request.getParameter("beginSearch")+"&fg="+request.getParameter("fg")+"&setCds="+request.getParameter("setCds")+"&noAdmision="+request.getParameter("noAdmision")+"&pacienteId="+request.getParameter("pacienteId")+"&factura="+request.getParameter("factura")+"&tr="+request.getParameter("tr")+"&nt="+request.getParameter("nt")+"&codigo="+request.getParameter("codigo")+"&codDet="+request.getParameter("codDet")+"&wh="+request.getParameter("wh")+"&valida_dsp="+request.getParameter("valida_dsp"));
		return;		         
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cs="+cs+"&tipoServicio="+tipoServicio+"&trabajo="+trabajo+"&descripcion="+descripcion+"&renglon="+renglon+"&index="+index+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&beginSearch="+request.getParameter("beginSearch")+"&fg="+request.getParameter("fg")+"&setCds="+request.getParameter("setCds")+"&noAdmision="+request.getParameter("noAdmision")+"&pacienteId="+request.getParameter("pacienteId")+"&factura="+request.getParameter("factura")+"&tr="+request.getParameter("tr")+"&nt="+request.getParameter("nt")+"&codigo="+request.getParameter("codigo")+"&codDet="+request.getParameter("codDet")+"&wh="+request.getParameter("wh")+"&valida_dsp="+request.getParameter("valida_dsp"));
		return;
	}
	else if (request.getParameter("saveNcont") != null || request.getParameter("saveNcont2") != null )
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cs="+cs+"&tipoServicio="+tipoServicio+"&trabajo="+trabajo+"&descripcion="+descripcion+"&renglon="+renglon+"&index="+index+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&beginSearch="+request.getParameter("beginSearch")+"&fg="+request.getParameter("fg")+"&setCds="+request.getParameter("setCds")+"&noAdmision="+request.getParameter("noAdmision")+"&pacienteId="+request.getParameter("pacienteId")+"&factura="+request.getParameter("factura")+"&tr="+request.getParameter("tr")+"&nt="+request.getParameter("nt")+"&codigo="+request.getParameter("codigo")+"&codDet="+request.getParameter("codDet")+"&wh="+request.getParameter("wh")+"&valida_dsp="+request.getParameter("valida_dsp"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("cotizacion"))
	{
%>
	window.opener.location = '../facturacion/reg_cotizacion_det.jsp?change=1&mode=<%=mode%>&id=<%=id%>&renglon=<%=renglon%>&fp=<%=fg%>';
<%
	}else if (fp.equalsIgnoreCase("cargo_dev"))
	{
%>
	window.opener.location = '../facturacion/detalle_ajuste.jsp?change=1&mode=<%=mode%>&fp=<%=fp%>&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&factura=<%=factura%>&fg=<%=fg%>&tr=<%=tr%>&nt=<%=nt%>&cds=<%=cs%>&ts=<%=tipoServicio%>&codigo=<%=codigo%>&codDet=<%=codDet%>&wh=<%=wh%>'; 
<%
	}
%>   
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>