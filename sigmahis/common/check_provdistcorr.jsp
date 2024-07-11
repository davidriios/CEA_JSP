<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iUser" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUser" scope="session" class="java.util.Vector"/>
<jsp:useBean id="cop" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="copKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="hastusua" scope="session" class="java.util.Hashtable"/>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String compania = request.getParameter("compania");
String unidad_ejec = request.getParameter("unidad_ejec");
int tServLastLineNo = 0;
int userLastLineNo = 0;
int tAdmLastLineNo = 0;
int pamLastLineNo = 0;
int procLastLineNo = 0;
int docLastLineNo = 0;
int profLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("tServLastLineNo") != null) tServLastLineNo = Integer.parseInt(request.getParameter("tServLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));
if (request.getParameter("tAdmLastLineNo") != null) tAdmLastLineNo = Integer.parseInt(request.getParameter("tAdmLastLineNo"));
if (request.getParameter("pamLastLineNo") != null) pamLastLineNo = Integer.parseInt(request.getParameter("pamLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

String codigo_ubicacion = request.getParameter("codigo_ubicacion");
String provdistcorr = request.getParameter("provdistcorr");
if (codigo_ubicacion == null) codigo_ubicacion = "";
if (provdistcorr == null) provdistcorr = "";

String context = request.getParameter("context")==null?"":request.getParameter("context");

String jsContext = "window.opener.";
if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";

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

	//if (!UserDet.getUserProfile().contains("0")) {
		//do not display users with profile 0
		//sbFilter.append(" and not exists (select null from tbl_sec_user_profile where profile_id = 0 and user_id = a.user_id)")}

	if (!codigo_ubicacion.trim().equals("")) { sbFilter.append(" and upper(a.codigo_ubicacion) like '%"); sbFilter.append(codigo_ubicacion.toUpperCase()); sbFilter.append("%'"); }
	if (!provdistcorr.trim().equals("")) { sbFilter.append(" and upper(a.provdistcorr) like '%"); sbFilter.append(provdistcorr.toUpperCase()); sbFilter.append("%'"); }

	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select a.codigo_ubicacion, a.provdistcorr from TBL_ADM_FE_PROVDISTCORR a where 1 = 1");
		sbSql.append(sbFilter);
		sbSql.append(" order by a.codigo_ubicacion");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);
	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from TBL_ADM_FE_PROVDISTCORR A WHERE 1 = 1");
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
document.title = 'Usuario - '+document.title;

function setValues(i){
	<%if(fp.equalsIgnoreCase("run_process")){%>
	window.opener.document.formDetalle.ubicacion_fe.value=eval('document.usuario.codigo_ubicacion'+i).value;
	/*if(window.opener.document.formDetalle.nombre.value!=eval('document.usuario.name'+i).value)
		if(window.opener.document.form0.nombre.value.trim()==''||confirm('El Nombre es diferente al del Usuario seleccionado. ¿Desea cambiarlo?'))
			window.opener.document.form0.nombre.value=eval('document.usuario.name'+i).value.toUpperCase();*/
	<%} else if(fp.equalsIgnoreCase("user")){%>
	window.opener.document.form0.userCopyDesc.value = 	eval('document.usuario.name'+i).value;
	window.opener.document.form0.userCopy.value = 	eval('document.usuario.user_id'+i).value;
	<%}else if(fp.equalsIgnoreCase("trazabilidad")){%>
		if(<%=jsContext%>document.search01.userId)<%=jsContext%>document.search01.userId.value = eval('document.usuario.user_id'+i).value;
		if(<%=jsContext%>document.search01.nombreUsuario)<%=jsContext%>document.search01.nombreUsuario.value = eval('document.usuario.name'+i).value;
	<%} else {%>
	window.opener.document.form.usuario<%=id%>.value = 	eval('document.usuario.user_name'+i).value;
	<%}%>

	<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
			 <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
	<%}else{%>window.close();<%}%>
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();
<% if(context.equalsIgnoreCase("preventPopupFrame") && al.size()==1) { %> setValues(0); <%} %>
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE USUARIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("compania",""+compania)%>
<%=fb.hidden("unidad_ejec",""+unidad_ejec)%>
			<td width="50%">
				<cellbytelabel>Código Ubicaci&oacute;n</cellbytelabel>
				<%=fb.textBox("codigo_ubicacion","",false,false,false,40)%>
			</td>
			<td width="50%">
				<cellbytelabel>PROVINCIA-DISTRITO-CORREGIMIENTO</cellbytelabel>
				<%=fb.textBox("provdistcorr","",false,false,false,50)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("usuario",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
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
<%=fb.hidden("provdistcorr",provdistcorr)%>
<%=fb.hidden("codigo_ubicacion",codigo_ubicacion)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("compania",""+compania)%>
<%=fb.hidden("unidad_ejec",""+unidad_ejec)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<% if (!fp.equalsIgnoreCase("run_process") && !fp.equalsIgnoreCase("user") && !fp.equalsIgnoreCase("cajero") && !fp.equalsIgnoreCase("trazabilidad")) { %><%=fb.submit("save","Guardar",true,false)%><% } %>
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
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" id="list">
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel>Código Ubicación</cellbytelabel></td>
			<td width="60%"><cellbytelabel>PROVINCIA-DISTRITO-CORREGIMIENTO</cellbytelabel></td>
			<td width="10%"><% if (!fp.equalsIgnoreCase("cuadro_autorizacion") && !fp.equalsIgnoreCase("user")) { %><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los usuarios listados!")%><% } %></td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("user_id"+i,cdo.getColValue("user_id"))%>
		<%=fb.hidden("codigo_ubicacion"+i,cdo.getColValue("codigo_ubicacion"))%>
		<%=fb.hidden("provdistcorr"+i,cdo.getColValue("provdistcorr"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" <%=(fp.equalsIgnoreCase("run_process") || fp.equalsIgnoreCase("cajero")|| fp.equalsIgnoreCase("user") || fp.equalsIgnoreCase("trazabilidad")? "style=\"cursor:pointer\" onClick=\"javascript:setValues("+i+");\"":"")%>>
			<td><%=cdo.getColValue("codigo_ubicacion")%></td>
			<td><%=cdo.getColValue("provdistcorr")%></td>
			<td align="center">
			<% if (!fp.equalsIgnoreCase("cuadro_autorizacion") && !fp.equalsIgnoreCase("run_process") && !fp.equalsIgnoreCase("user")&& !fp.equalsIgnoreCase("trazabilidad")) { %>
				<% if (fp.equalsIgnoreCase("user_orden_pago")) { %>
					<%=(copKey.containsKey(cdo.getColValue("codigo_ubicacion")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo_ubicacion"),false,false)%>
				<% } else { %>
					<%=((fp.equalsIgnoreCase("cds_references") && vUser.contains(cdo.getColValue("codigo_ubicacion"))) ||(fp.equalsIgnoreCase("alert") && vUser.contains(cdo.getColValue("codigo_ubicacion")))||(fp.equalsIgnoreCase("gruposPla") && vUser.contains(cdo.getColValue("codigo_ubicacion"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo_ubicacion"),false,false)%>
				<% } %>
			<% } %>
			</td>
		</tr>
<% } %>
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
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<% if (!fp.equalsIgnoreCase("cuadro_autorizacion") && !fp.equalsIgnoreCase("user") && !fp.equalsIgnoreCase("run_process") && !fp.equalsIgnoreCase("trazabilidad")) { %><%=fb.submit("save","Guardar",true,false)%><% } %>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	int size = Integer.parseInt(request.getParameter("size"));
	int userLine = cop.size();
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			if (fp.equalsIgnoreCase("cds_references"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("user_name",request.getParameter("user_name"+i));
				cdo.addColValue("name",request.getParameter("name"+i));
				cdo.addColValue("user_id",request.getParameter("user_id"+i));
				cdo.addColValue("observacion","");
				cdo.addColValue("creaAdmision","");
				cdo.addColValue("consultaAdmision","");
				userLastLineNo++;

				String key = "";
				if (userLastLineNo < 10) key = "00"+userLastLineNo;
				else if (userLastLineNo < 100) key = "0"+userLastLineNo;
				else key = ""+userLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iUser.put(key, cdo);
					vUser.add(cdo.getColValue("usuario"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("alert"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("user_id",request.getParameter("user_id"+i));
				cdo.addColValue("user_name",request.getParameter("user_name"+i));
				cdo.addColValue("name",request.getParameter("name"+i));
				cdo.addColValue("comments","");

				cdo.setKey(iUser.size()+1);
				cdo.setAction("I");
				try
				{
					iUser.put(cdo.getKey(), cdo);
					vUser.add(cdo.getColValue("user_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("user_orden_pago"))
			{
				CommonDataObject cdo = new CommonDataObject();
				userLine++;
				cdo.addColValue("usuario",request.getParameter("user_name"+i));
				cdo.addColValue("nombre",request.getParameter("name"+i));

				String key = "";
				if (userLine < 10) key = "00"+userLine;
				else if (userLine < 100) key = "0"+userLine;
				else key = ""+userLine;
				cdo.addColValue("key",key);

				try
				{
					cop.put(key, cdo);
					copKey.put(cdo.getColValue("usuario"), key);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("gruposPla"))
			{
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("usuario",request.getParameter("user_name"+i));
				cdo.addColValue("nombre",request.getParameter("name"+i));
				cdo.addColValue("user_id",request.getParameter("user_id"+i));

				cdo.setKey(hastusua.size()+1);
				cdo.setAction("I");

				try
				{
					hastusua.put(cdo.getKey(), cdo);
					vUser.add(cdo.getColValue("user_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&profLastLineNo="+profLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&provdistcorr="+request.getParameter("provdistcorr")+"&codigo_ubicacion="+request.getParameter("codigo_ubicacion")+"&compania="+compania+"&unidad_ejec="+unidad_ejec+"&context="+context);
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&profLastLineNo="+profLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&provdistcorr="+request.getParameter("provdistcorr")+"&codigo_ubicacion="+request.getParameter("codigo_ubicacion")+"&compania="+compania+"&unidad_ejec="+unidad_ejec+"&context="+context);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("cds_references"))
	{
%>
	window.opener.location = '../admin/reg_cds_references.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("alert"))
	{
%>
	window.opener.location = '../admin/reg_alert.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&profLastLineNo=<%=profLastLineNo%>&userLastLineNo=<%=userLastLineNo%>';
<%
	} else if (fp.equalsIgnoreCase("user_orden_pago"))
	{
%>
	window.opener.location = '../cxp/usuario_x_unid_adm_op_det.jsp?change=1&mode=<%=mode%>&compania=<%=compania%>&unidad_ejec=<%=unidad_ejec%>';
<%
	}else if (fp.equalsIgnoreCase("gruposPla"))
	{
%>
	window.opener.location = '../rhplanilla/areasalto_riesgo_config.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>';
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