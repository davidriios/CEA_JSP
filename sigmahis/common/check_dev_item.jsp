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
	
	if (!cs.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("cds = '"); sbFilter.append(cs); sbFilter.append("'"); }
	if (!tipoServicio.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("tipo_servicio = '"); sbFilter.append(tipoServicio); sbFilter.append("'"); }
	
	if (!trabajo.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(trabajo) like '%"); sbFilter.append(trabajo.toUpperCase()); sbFilter.append("%'"); }
	
	if (!descripcion.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	 
	  
	
	
	sbSql.append("select tipo_servicio,tipo_serv_desc,descripcion,trabajo,inv_almacen,costo_art,inventario,keyCargo,precio,cds,cdsDesc,afecta_inv,nvl(sum(cantidad), 0) as cantidad,recargo from ( select a.tipo_cargo as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_cargo)  as tipo_serv_desc, a.descripcion,case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then ''||a.otros_cargos when a.cds_producto is not null then ''||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then ''||a.inv_articulo when a.cod_uso is not null then ''||a.cod_uso when a.cod_paq_x_cds is not null then ''||a.cod_paq_x_cds else ' ' end as trabajo,a.inv_almacen,nvl(a.costo_art,0) as costo_art, null as inventario,case when a.procedimiento is not null then 'PROC' when a.cds_producto is not null then 'PROD' when a.habitacion is not null then 'HAB' when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then  'ART' when a.cod_uso is not null then 'USO' when a.cod_paq_x_cds is not null then 'PAQ' else ' ' end as keyCargo, a.monto as precio,a.centro_servicio as cds,null as cdsDesc,'' as afecta_inv,nvl(sum (decode(a.tipo_transaccion,'D',a.cantidad*-1,a.cantidad)), 0) as cantidad,a.recargo "); 		
			sbSql.append(" from tbl_fac_detalle_transaccion a where  a.pac_id =");
sbSql.append(pacienteId);
sbSql.append("  and a.fac_secuencia =");
sbSql.append(noAdmision);
sbSql.append("  and a.compania =");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append("  and a.centro_servicio <> 0 group by a.tipo_cargo,a.descripcion,a.procedimiento,a.otros_cargos ,a.cds_producto ,a.habitacion,a.inv_almacen ,a.art_familia ,a.art_clase,a.inv_articulo,a.cod_uso,a.cod_paq_x_cds,nvl(a.costo_art,0), 'N',a.monto,a.centro_servicio,a.recargo  ");


sbSql.append(" union all select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)  as tipo_serv_desc, a.descripcion,a.trabajo,a.wh,nvl(a.costo,0) as costo_art, null as inventario,a.keyCargo, a.precio,a.cds,null as cdsDesc,'' as afecta_inv,nvl(sum (decode(a.tipo,'D',a.cantidad*-1,a.cantidad)), 0) as cantidad,a.recargo from tbl_con_adjustment_detail a where a.pac_id =");
sbSql.append(pacienteId);
sbSql.append("  and a.admision =");
sbSql.append(noAdmision);
sbSql.append("  and a.compania =");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" group by a.tipo_servicio,a.descripcion,a.trabajo,a.wh,nvl(a.costo,0),a.keyCargo, a.precio,a.cds,a.recargo ) group by tipo_servicio,tipo_serv_desc, descripcion, trabajo,inv_almacen,costo_art,inventario,keyCargo,precio,cds,cdsDesc,afecta_inv,recargo  ");			 
		
		
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
	var cantidadCargo 		= parseInt(eval('document.result.cantidadCargo'+i).value);
	//alert('xxxxxxxxx valida_dsp== <%=valida_dsp%>    WH = '+almacen+'   afecta_inv='+afecta_inv);
 		
		if(cantidadCargo <  cantidad)
		{
			CBMSG.warning('La cantidad a devolver es mayor que la cantidad registrada');
			eval('document.result.cantidad'+i).value = 0;
		} 
		else
		{
			setChecked(eval('document.result.cantidad'+i), eval('document.result.check'+i));
		}
		 
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
		<%=fb.hidden("cantidadCargo"+i,cdo.getColValue("cantidad"))%>
		<%=fb.hidden("costo_art"+i,cdo.getColValue("costo_art"))%>
		<%=fb.hidden("recargo"+i,cdo.getColValue("recargo"))%>
		<%=fb.hidden("inv_almacen"+i,cdo.getColValue("inv_almacen"))%> 

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
			    <%=fb.intBox("cantidad"+i,"0",false,false,((fp.equalsIgnoreCase("cargo_dev") && vCarAjDet.contains(cdo.getColValue("trabajo")+"-"+cdo.getColValue("keyCargo"))))?true:false,3, 4, "", "", "onChange=\"javascript:chkValue("+i+")\"","",false)%></td>
			
			<td><%=fb.decBox("precio"+i,cdo.getColValue("precio"),false,false,(fp.equalsIgnoreCase("cargo_dev")?true:false),15,15.2)%></td>
			<td align="center"><%=((fp.equalsIgnoreCase("cargo_dev") && vCarAjDet.contains(cdo.getColValue("trabajo")+"-"+cdo.getColValue("keyCargo"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("trabajo"),false,false)%></td>
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
	if (fp.equalsIgnoreCase("cargo_dev"))
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
				if(fp.equalsIgnoreCase("cargo_dev"))cdo.addColValue("estado","I"); 
				
				if(request.getParameter("cantidadCargo"+i)!= null || request.getParameter("cantidadCargo"+i)!=null)cdo.addColValue("cantidadCargo",request.getParameter("cantidadCargo"+i));
				if(request.getParameter("costo_art"+i)!= null || request.getParameter("costo_art"+i)!=null)cdo.addColValue("costo",request.getParameter("costo_art"+i));
				if(request.getParameter("recargo"+i)!= null || request.getParameter("recargo"+i)!=null)cdo.addColValue("recargo",request.getParameter("recargo"+i));
				if(request.getParameter("inv_almacen"+i)!= null || request.getParameter("inv_almacen"+i)!=null)cdo.addColValue("wh",request.getParameter("inv_almacen"+i));
	 
				cdo.addColValue("codigo","0");  

				if (fp.equalsIgnoreCase("cargo_dev"))cdo.setKey(iCarAjDet.size() + 1);
				cdo.setAction("I");

				try
				{
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
	 if (fp.equalsIgnoreCase("cargo_dev"))
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