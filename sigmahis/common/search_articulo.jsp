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
<jsp:useBean id="vCAUT" scope="session" class="java.util.Vector" />
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String filter = "",filter1 = "";
String index = "";
String id = "";
String fp =  request.getParameter("fp");
String almacen =  request.getParameter("almacen");
String familia =  request.getParameter("familia");
String clase =  request.getParameter("clase");
String subclase =  request.getParameter("subclase");
String curIndex =  request.getParameter("curIndex");
String codigo ="",desc ="";
String cCama = request.getParameter("cCama");
String cHab = request.getParameter("cHab");

if(fp == null )      fp = "";
if(almacen == null ) almacen = "";
if(familia == null ) familia = "";
if(clase == null )   clase = "";
if(subclase == null )   subclase = "";
if (curIndex==null) curIndex = "0";
if (cCama==null) cCama= "";
if (cHab==null) cHab= "";

if(!familia.trim().equals("")) filter += " and a.cod_flia ="+familia;
if(!clase.trim().equals(""))   filter += " and a.cod_clase ="+clase;
if(!subclase.trim().equals(""))   filter += " and a.cod_subclase ="+subclase;

String companiaFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");
if (companiaFar == null || companiaFar.trim().equals("")) companiaFar = "1";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (request.getParameter("filter") != null) filter = request.getParameter("filter");
	if (request.getParameter("id") != null) id = request.getParameter("id");
	if (request.getParameter("index") != null) index = request.getParameter("index");

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
	if (request.getParameter("codFlia") != null && (request.getParameter("codClase") != null))
 {
	 filter += " and (a.cod_flia) = '"+request.getParameter("codFlia")+"' and (a.cod_clase) = '"+request.getParameter("codClase")+"'";
	}

	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo = request.getParameter("codigo");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	desc = request.getParameter("descripcion");
	}

	if(fp != null && !fp.trim().equals(""))
	{
		if(fp.trim().equals("cargos_aut")||fp.trim().equals("RHA")||fp.trim().equals("EUAA")) if(!almacen.trim().equals("")) appendFilter += " and i.codigo_almacen  = "+almacen;
		if(fp.trim().equalsIgnoreCase("CONSIG"))appendFilter += " and a.consignacion_sino  ='S' ";
		if(fp.trim().equals("RHA")||fp.trim().equals("EUAA"))
		{

			sql="select distinct a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as item, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code,nvl(cf.fecha_corrida,' ') fecha_corrida ,nvl(SUBSTR(cf.fecha_corrida,1,10),' ') fecha_ini , to_char(sysdate,'dd/mm/yyyy') fecha_fin, ' ' as type  from  tbl_inv_inventario i , tbl_inv_articulo a, (select df.cod_familia ,df.cod_clase,df.cod_articulo ,  nvl(to_char(cf.fecha_corrida,'dd/mm/yyyy hh:mi:ss am '),' ') fecha_corrida ,cf.almacen from tbl_inv_detalle_fisico df,tbl_inv_conteo_fisico cf  where (df.almacen = cf.almacen and  df.cf1_consecutivo = cf.consecutivo and  df.cf1_anio = cf.anio) and  cf.estatus = 'A'  and  cf.asiento_sino = 'S' ";
			if(!familia.trim().equals(""))sql +=" and df.cod_familia ="+familia;
			if(!clase.trim().equals(""))sql +=" and df.cod_clase ="+clase;
			 sql +=" and cf.compania ="+(String) session.getAttribute("_companyId")+"  )cf where   (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and (i.compania = "+(String) session.getAttribute("_companyId")+filter+appendFilter + ")  and cf.cod_articulo(+) = i.cod_articulo and cf.almacen(+) = i.codigo_almacen order by  a.cod_flia, a.cod_clase, a.descripcion  asc ";


		}
		else if(fp.trim().equals("cargos_aut")){
		sql = "select distinct a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as item, a.compania||'-'||a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, fa.tipo_servicio,(select count(*) from tbl_sal_cargos_automaticos aa where aa.compania = a.compania and aa.codigo_item = a.cod_articulo and aa.tipo_referencia = 'AR' and aa.cama='"+cCama+"' and aa.habitacion='"+cHab+"') tot, ' ' as type  from tbl_inv_almacen al, tbl_inv_inventario i , tbl_inv_familia_articulo fa , tbl_inv_clase_articulo ca, tbl_inv_articulo a where (a.compania = ca.compania and a.cod_flia = ca.cod_flia and a.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen) and (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and (i.compania = "+(String) session.getAttribute("_companyId")+appendFilter + "  and i.art_familia =  decode('"+familia+ "', '', i.art_familia, '"+familia+"')  and i.art_clase =decode('"+clase+ "', '', i.art_clase, '"+clase+"') and a.estado ='A' and a.other3='N')  order by a.descripcion  asc ";
	} else if(fp.trim().equalsIgnoreCase("saldo_inicial")){
		sql = "select distinct a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as item, a.compania||'-'||a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, fa.tipo_servicio, fa.nombre familia_name, ca.descripcion clase_name, a.cod_subclase subclase, sa.descripcion subclase_name, a.cod_barra,a.product_id , ' ' as type from tbl_inv_almacen al, tbl_inv_inventario i, tbl_inv_familia_articulo fa, tbl_inv_clase_articulo ca, tbl_inv_articulo a, tbl_inv_subclase sa where (a.compania = ca.compania and a.cod_flia = ca.cod_flia and a.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen) and (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and (i.compania = "+(String) session.getAttribute("_companyId")+appendFilter + "  and i.art_familia =  decode('"+familia+ "', '', i.art_familia, '"+familia+"')  and i.art_clase =decode('"+clase+ "', '', i.art_clase, '"+clase+"') and a.estado ='A') and ca.compania = sa.compania and ca.cod_flia = sa.cod_flia and ca.cod_clase = sa.cod_clase and a.cod_subclase = sa.subclase_id  order by a.descripcion  asc ";
	} else if (fp.trim().equalsIgnoreCase("alertas_restringidos")) {
		String bmFilter = "", farFilter = "";

		if (request.getParameter("codigo")!=null&&!request.getParameter("codigo").trim().equals("")) {
			bmFilter += " and bm.cod_flia||'-'||bm.cod_clase||'-'||bm.cod_articulo like '%"+request.getParameter("codigo")+"%'";
			farFilter += " and a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo like '%"+request.getParameter("codigo")+"%'";
		}

		if (request.getParameter("descripcion")!=null&&!request.getParameter("descripcion").trim().equals("")) {
			bmFilter += " and a.descripcion like '%"+request.getParameter("descripcion")+"%'";
			farFilter += " and a.descripcion like '%"+request.getParameter("descripcion")+"%'";
		}

	sql = "select distinct bm.cod_flia as familyCode, bm.cod_clase as classCode, bm.cod_articulo as itemCode, upper(a.descripcion) as item, bm.compania||'-'||bm.cod_flia||'-'||bm.cod_clase||'-'||bm.cod_articulo as code, 'BANCO' type from tbl_inv_articulo a, tbl_inv_articulo_bm bm where bm.compania = a.compania and bm.cod_articulo = a.cod_articulo and a.compania = "+(String) session.getAttribute("_companyId")+bmFilter+" and a.estado = 'A' and bm.estado = 'A' union all select distinct a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as item, a.compania||'-'||a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, 'FARMACIA' type from tbl_inv_articulo a where estado = 'A' and venta_sino ='S' and compania = "+companiaFar+farFilter+" order by 4";
	}
	else
	sql = "SELECT a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as item, a.compania||'-'||a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, ' ' as type FROM tbl_inv_articulo a WHERE a.compania="+(String) session.getAttribute("_companyId")+appendFilter+""+filter+" ORDER BY a.descripcion";
 }
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM (" +sql+")");


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
document.title = 'Articulos - '+document.title;

function returnValue(i,op)
{
	var code = eval('document.form1.itemCode'+i).value;
	var name = eval('document.form1.item'+i).value;
	var flia = eval('document.form1.familyCode'+i).value;
	var clase = eval('document.form1.classCode'+i).value;
	var codigo = eval('document.form1.codigo'+i).value;
	var tipoServ = eval('document.form1.tipo_servicio'+i).value;

		switch(op)
		{
			 case 1:
					 eval('window.opener.document.formPuntos.codArticulo<%=index%>').value = code;
					 eval('window.opener.document.formPuntos.codArticuloDesc<%=index%>').value = name;
					 eval('window.opener.document.formPuntos.codFlia<%=index%>').value = flia;
					 eval('window.opener.document.formPuntos.codClase<%=index%>').value = clase;
					 break;
			 case 2:
					 eval('window.opener.document.form0.codigo').value = code;
					 eval('window.opener.document.form0.descArticulo').value = name;
					 if(window.opener.document.form0.familyCode<%=index%>)eval('window.opener.document.form0.familyCode<%=index%>').value = flia;
					 if(window.opener.document.form0.classCode<%=index%>&&window.opener.cargarClase)window.opener.cargarClase();
					 if(window.opener.document.form0.classCode<%=index%>)eval('window.opener.document.form0.classCode<%=index%>').value = clase;
					 break;
			 case 3:
					 eval('window.opener.document.form1.cod_articulo<%=index%>').value = code;
					 eval('window.opener.document.form1.desc_articulo<%=index%>').value = name;
					 eval('window.opener.document.form1.cod_flia<%=index%>').value = flia;
					 eval('window.opener.document.form1.cod_clase<%=index%>').value = clase;
					 eval('window.opener.document.form1.codigo_articulo<%=index%>').value = codigo;
					 break;
			 case 4:
					 eval('window.opener.document.form1.familyCode').value = flia;
					 eval('window.opener.document.form1.clase').value = clase;
					 if(window.opener.cargarClase)window.opener.cargarClase();
					 eval('window.opener.document.form1.code').value = code;
					 eval('window.opener.document.form1.name').value = name;
					 eval('window.opener.document.form1.fecha_corrida').value =  eval('document.form1.fecha_corrida'+i).value;
					 eval('window.opener.document.form1.fechaini').value =  eval('document.form1.fecha_ini'+i).value;
						eval('window.opener.document.form1.fechafin').value =  eval('document.form1.fecha_fin'+i).value;
					 break;
			 case 5:
					 eval('window.opener.document.form1.familyCode').value = flia;
					 eval('window.opener.document.form1.clase').value = clase;
					 if(window.opener.cargarClase)window.opener.cargarClase();
					 eval('window.opener.document.form1.code').value = code;
					 eval('window.opener.document.form1.name').value = name;
						break;
			case 6:

					 if (eval('document.form1.ignoreClick'+i)!=null) return false;
					 eval('window.opener.document.form0.codigo_item<%=curIndex%>').value = code;
					 eval('window.opener.document.form0.descripcion<%=curIndex%>').value = name;
					 eval('window.opener.document.form0.tipo_servicio<%=curIndex%>').value = tipoServ;
					 eval('window.opener.document.form0.familia<%=curIndex%>').value = flia;
					 eval('window.opener.document.form0.clase<%=curIndex%>').value = clase;
					 break;
			 case 7:
					 eval('window.opener.document.form1.familia').value = flia;
					 eval('window.opener.document.form1.familia_name').value = eval('document.form1.familia_name'+i).value;
					 eval('window.opener.document.form1.clase').value = clase;
					 eval('window.opener.document.form1.clase_name').value = eval('document.form1.clase_name'+i).value;
					 eval('window.opener.document.form1.subclase').value = eval('document.form1.subclase'+i).value;
					 eval('window.opener.document.form1.subclase_name').value = eval('document.form1.subclase_name'+i).value;
					 eval('window.opener.document.form1.cod_articulo').value = code;
					 if(eval('window.opener.document.form1.cod_barra'))eval('window.opener.document.form1.cod_barra').value = eval('document.form1.cod_barra'+i).value;
					 eval('window.opener.document.form1.product_id').value = eval('document.form1.product_id'+i).value;
					 eval('window.opener.document.form1.observacion').value = name;
					 eval('window.opener.document.form1.nombre').value = name;
						break;
			 case 8:
					 window.opener.document.search00.code.value = code;
					 window.opener.document.search00.name.value = name;
					 if(window.opener.loadLote)window.opener.loadLote();
					 break;
			case 9:
					 eval('window.opener.document.form0.codigo').value = code;
					 eval('window.opener.document.form0.descArticulo').value = name;
					 if(window.opener.document.form0.familyCode)eval('window.opener.document.form0.familyCode').value = flia;
					 if(window.opener.document.form0.classCode)eval('window.opener.document.form0.classCode').value = clase;
					 break;
			 case 10:
					 eval('window.opener.document.form0.articulo').value = code;
					 eval('window.opener.document.form0.descArticulo').value = name;
					 if(window.opener.document.form0.familyCode)eval('window.opener.document.form0.familyCode').value = flia;
					 if(window.opener.document.form0.classCode)eval('window.opener.document.form0.classCode').value = clase;
					 break;
			 case 11:
					 eval('window.opener.document.form0.codigo').value = code;
					 eval('window.opener.document.form0.descArticulo').value = name;
					 break;
			 case 12:
					 eval('window.opener.document.form0.medCode').value = code;
					 eval('window.opener.document.form0.medicamento').value = name;
					 break;
			 case 13:
					 if(eval('window.opener.document.form0.familyCode'))eval('window.opener.document.form0.familyCode').value = flia;
					 if(eval('window.opener.document.form0.classCode'))eval('window.opener.document.form0.classCode').value = clase;
					 if(eval('window.opener.document.form0.classCode')&&window.opener.cargarClase)window.opener.cargarClase();
					 eval('window.opener.document.form0.articulo').value = code;
					 eval('window.opener.document.form0.name').value = name;
						break;
		}
	 window.close();


}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - ARTICULODS "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">

					<%
						fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
						<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
						<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("almacen",almacen)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("subclase",subclase)%>
					<%=fb.hidden("curIndex",curIndex)%>
					 <tr class="TextFilter">
						<td width="25%"><cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,10)%>

					</td>

				<td width="75%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion",desc,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>

					</tr>
					<%=fb.formEnd()%>
			</table>
		</td>
	</tr>

</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("filter",filter)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("familia",familia)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("descripcion",desc)%>
				<%=fb.hidden("subclase",subclase)%>
		<%=fb.hidden("curIndex",curIndex)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
					%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("almacen",almacen)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",desc)%>
					<%=fb.hidden("subclase",subclase)%>
			<%=fb.hidden("curIndex",curIndex)%>
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
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<%if(fp.equalsIgnoreCase("cargos_aut")){%>
						 <td>&nbsp;</td>
					<%}%>
					<%if(fp.equalsIgnoreCase("RHA")){%>
						 <td width="15%">&nbsp;Fecha Conteo</td>
					<%}%>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("itemCode"+i,cdo.getColValue("itemCode"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("code"))%>
				<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
				<%=fb.hidden("item"+i,cdo.getColValue("item"))%>
				<%=fb.hidden("familyCode"+i,cdo.getColValue("familyCode"))%>
				<%=fb.hidden("classCode"+i,cdo.getColValue("classCode"))%>
				<%if(fp != null && fp.trim().equals("RHA")){%>
				<%=fb.hidden("fecha_corrida"+i,cdo.getColValue("fecha_corrida"))%>

				<%=fb.hidden("fecha_ini"+i,cdo.getColValue("fecha_ini"))%>
				<%=fb.hidden("fecha_fin"+i,cdo.getColValue("fecha_fin"))%>
				<%} else if(fp != null && fp.trim().equals("SALDO_INICIAL")){%>
				<%=fb.hidden("familia_name"+i,cdo.getColValue("familia_name"))%>
				<%=fb.hidden("clase_name"+i,cdo.getColValue("clase_name"))%>
				<%=fb.hidden("subclase"+i,cdo.getColValue("subclase"))%>
				<%=fb.hidden("subclase_name"+i,cdo.getColValue("subclase_name"))%>
				<%=fb.hidden("cod_barra"+i,cdo.getColValue("cod_barra"))%>
				<%=fb.hidden("product_id"+i,cdo.getColValue("product_id"))%>
				<%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>,<%=id%>)" style="cursor:pointer">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("code")%></td>
					<td><%=cdo.getColValue("item")%> <%if (fp.trim().equalsIgnoreCase("alertas_restringidos")) {%>/ <b><%=cdo.getColValue("type")%></b><%}%></td>
					<%if(fp.equalsIgnoreCase("cargos_aut")){%>
						 <td align="center">
							<%if(cdo.getColValue("tot")!=null &&Integer.parseInt(cdo.getColValue("tot")) > 0||vCAUT.contains("AR-"+cdo.getColValue("itemCode"))){%>
							Elegido
						<%=fb.hidden("ignoreClick"+i,"S")%>
						<%}%>
						 </td>
					<%}%>
					<%if(fp.equalsIgnoreCase("RHA")){%>
					<td align="center"><%=cdo.getColValue("fecha_corrida")%></td>
					<%}%>
				</tr>
				<%
				}
				%>
			<%=fb.formEnd(true)%>
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
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("filter",filter)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("familia",familia)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("descripcion",desc)%>
				<%=fb.hidden("subclase",subclase)%>
		<%=fb.hidden("curIndex",curIndex)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("almacen",almacen)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",desc)%>
					<%=fb.hidden("subclase",subclase)%>
			<%=fb.hidden("curIndex",curIndex)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
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