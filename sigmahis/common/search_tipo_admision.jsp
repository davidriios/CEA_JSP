<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator"/>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cds = request.getParameter("cds");
String cdsDesc = request.getParameter("cds_desc");
String catCode = request.getParameter("catCode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String pac_id = request.getParameter("pac_id");
String admision = request.getParameter("admision");
if (cds == null) cds = "";
if (!cds.trim().equals("")) { sbFilter.append(" and a.cod_centro = "); sbFilter.append(cds); }
if (catCode == null) catCode = "";
if (fg == null) fg = "";
if (cdsDesc == null) cdsDesc = "";
String context = request.getParameter("context")==null?"":request.getParameter("context");
String noResultClose = request.getParameter("noResultClose")==null?"":request.getParameter("noResultClose");

if (fg.equalsIgnoreCase("special")) catCode = "1";

if (!catCode.trim().equals("")) { sbFilter.append(" and a.cod_categoria = "); sbFilter.append(catCode); }
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");


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

	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.cod_tipo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_tipo_admision_cia where categoria = a.cod_categoria and codigo = a.cod_tipo and compania = "); sbFilter.append(session.getAttribute("_companyId")); sbFilter.append(" and upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%')"); }
    
    if (!cdsDesc.equals("")){
      
      sbFilter.append(" and exists (select descripcion from tbl_cds_centro_servicio where codigo = a.cod_centro ");
      sbFilter.append(" and descripcion like upper('%");
      sbFilter.append(cdsDesc);
      sbFilter.append("%')) ");
    
    }

	if (!UserDet.getUserProfile().contains("0"))
		if (session.getAttribute("_cds") != null) { sbFilter.append(" and a.cod_centro in ("); sbFilter.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))); sbFilter.append(")"); }
		else sbFilter.append(" and a.cod_centro in (-1)");


	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select a.cod_centro as centroServicio, a.cod_categoria as categoria, a.cod_tipo as tipoAdmision, a.cds_atencion, a.estado_ini_atencion");
		sbSql.append(", (select descripcion from tbl_cds_centro_servicio where codigo = a.cod_centro) as centroServicioDesc");
		sbSql.append(", (select estado_admision from tbl_cds_centro_servicio where codigo = a.cod_centro) as estadoAdm");
		sbSql.append(", (select descripcion from tbl_adm_categoria_admision where codigo = a.cod_categoria) as categoriaDesc");
		sbSql.append(", (select adm_type from tbl_adm_categoria_admision where codigo = a.cod_categoria) as adm_type");
		sbSql.append(", (select descripcion from tbl_adm_tipo_admision_cia where categoria = a.cod_categoria and codigo = a.cod_tipo and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(") as tipoAdmisionDesc");
		sbSql.append(" from tbl_adm_tipo_admision_x_cds a where exists (select null from tbl_cds_centro_servicio where codigo = a.cod_centro and estado = 'A' and si_no = 'S') and exists (select null from tbl_adm_tipo_admision_cia where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and categoria = a.cod_categoria and codigo = a.cod_tipo)");
		sbSql.append(sbFilter);
		sbSql.append(" order by 6, 8, 10");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);
	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from tbl_adm_tipo_admision_x_cds a where exists (select null from tbl_cds_centro_servicio where codigo = a.cod_centro and estado = 'A' and si_no = 'S') and exists (select null from tbl_adm_tipo_admision_cia where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and categoria = a.cod_categoria and codigo = a.cod_tipo)");
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
    
    String jsContext = "window.opener.";
    if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script type="text/javascript">
document.title = 'Tipo de Admisión - '+document.title;

function getMain(formx)
{
	formx.cds.value = document.search00.cds.value;
	formx.catCode.value = document.search00.catCode.value;
	return true;
}

function setTipoAdmision(k)
{
	var setValues = true;
	<%if (fp.equalsIgnoreCase("admision")){
		if(!pac_id.equals("") && !admision.equals("") && !fg.equalsIgnoreCase("special")){
	%>
			var categoria = getDBData('<%=request.getContextPath()%>', 'categoria_admi', 'tbl_adm_beneficios_x_admision', 'estado = \'A\' and pac_id = <%=pac_id%> and admision = <%=admision%> and prioridad = 1');
			if(categoria!='' && categoria!=eval('document.tipoAdmision.categoria'+k).value){
				alert('La Categoría seleccionada no concuerda con la que tiene el Beneficio asignado!');
				setValues = false;
			}
			var adm_type = getDBData('<%=request.getContextPath()%>', 'adm_type', 'tbl_adm_categoria_admision ca', 'exists (select 1 from tbl_adm_admision a where a.categoria = ca.codigo and pac_id = <%=pac_id%> and secuencia = <%=admision%> )');
			if(adm_type == 'I' && adm_type != eval('document.tipoAdmision.adm_type'+k).value){
				if(hasDBData('<%=request.getContextPath()%>', 'tbl_adm_cama_admision ca', 'pac_id = <%=pac_id%> and admision = <%=admision%>')){
				alert('Esta admision tiene cama asignada!');
				setValues = false;
				}
			}
			var categoria = getDBData('<%=request.getContextPath()%>', 'categoria', 'tbl_adm_admision', 'pac_id = <%=pac_id%> and secuencia = <%=admision%>');
			if(categoria!='' && categoria!=eval('document.tipoAdmision.categoria'+k).value){
				alert('La Categoría seleccionada no concuerda con la que tiene actualmente la admision!');
				setValues = false;
			}

		<%}%>
		if(setValues){
			<%=jsContext%>document.form0.centroServicio.value = eval('document.tipoAdmision.centroServicio'+k).value;
			<%=jsContext%>document.form0.centroServicioDesc.value = eval('document.tipoAdmision.centroServicioDesc'+k).value;
			<%=jsContext%>document.form0.categoria.value = eval('document.tipoAdmision.categoria'+k).value;
			<%=jsContext%>document.form0.categoriaDesc.value = eval('document.tipoAdmision.categoriaDesc'+k).value;
			<%=jsContext%>document.form0.tipoAdmision.value = eval('document.tipoAdmision.tipoAdmision'+k).value;
			<%=jsContext%>document.form0.tipoAdmisionDesc.value = eval('document.tipoAdmision.tipoAdmisionDesc'+k).value;
			<%=jsContext%>document.form0.estado.value = eval('document.tipoAdmision.estadoAdm'+k).value;
			
			if (<%=jsContext%>document.form0.centroServicioHidden) <%=jsContext%>document.form0.centroServicioHidden.value = eval('document.tipoAdmision.centroServicio'+k).value;
			if (<%=jsContext%>document.form0.centroServicioDescHidden) <%=jsContext%>document.form0.centroServicioDescHidden.value = eval('document.tipoAdmision.centroServicioDesc'+k).value;
			if(<%=jsContext%>document.form0.categoriaHidden) <%=jsContext%>document.form0.categoriaHidden.value = eval('document.tipoAdmision.categoria'+k).value;
			if(<%=jsContext%>document.form0.categoriaDescHidden) <%=jsContext%>document.form0.categoriaDescHidden.value = eval('document.tipoAdmision.categoriaDesc'+k).value;
			if(<%=jsContext%>document.form0.tipoAdmisionHidden) <%=jsContext%>document.form0.tipoAdmisionHidden.value = eval('document.tipoAdmision.tipoAdmision'+k).value;
			if(<%=jsContext%>document.form0.tipoAdmisionDescHidden) <%=jsContext%>document.form0.tipoAdmisionDescHidden.value = eval('document.tipoAdmision.tipoAdmisionDesc'+k).value;
		}
	<%}%>
	
	<%if(fg.equalsIgnoreCase("special")){%>
	    window.opener.document.form0.inabilitar_ben.value = 'Y';
		CBMSG.warning("Recuerde asignar Beneficio(s) y cama a la admisión hospitalizada!",{cb:function(r){
		  if (r=="Ok") window.close();
		}});
	<%}else{%>
		<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
           <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
		<%}else{%>
        window.close();
        <%}%>
	<%}%>
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();
<% if(context.equalsIgnoreCase("preventPopupFrame")) { if (al.size()==1){%>setTipoAdmision(0);<%}}%>
<%if(noResultClose.equals("1") && al.size() < 1){%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}%>
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%if(!context.equalsIgnoreCase("preventPopupFrame")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE TIPO DE ADMISION"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<%if(!context.equalsIgnoreCase("preventPopupFrame")){%>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
			<td colspan="2">
			<%sbSql = new StringBuffer();
		if(!UserDet.getUserProfile().contains("0"))
		{
			sbSql.append(" and a.codigo in (");
				if(session.getAttribute("_cds")!=null)
					sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
				else sbSql.append("-1");
			sbSql.append(")");
		}
		if (fg.equalsIgnoreCase("special")) sbSql.append(" and a.codigo in (select cod_centro from tbl_adm_tipo_admision_x_cds where cod_categoria = 1)");
		%>
				<cellbytelabel>CDS / &Aacute;rea</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select distinct a.codigo as value_col, a.descripcion as label_col, a.codigo as title_col from tbl_cds_centro_servicio a where a.estado='A'"+sbSql.toString()+" order by a.descripcion","cds",cds,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/categoria_adm_x_cds_x_user"+UserDet.getUserId()+".xml','catCode','"+catCode+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"",null,"T")%>
<% sbSql = new StringBuffer();
		if(!UserDet.getUserProfile().contains("0"))
		{
			sbSql.append(" and a.cod_centro in (");
				if(session.getAttribute("_cds")!=null)
					sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
				else sbSql.append("-1");
			sbSql.append(")");
		}
		if (fg.equalsIgnoreCase("special")) sbSql.append(" and a.cod_centro in (select cod_centro from tbl_adm_tipo_admision_x_cds where cod_categoria = 1)");
XML.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"categoria_adm_x_cds_x_user"+UserDet.getUserId()+".xml", "select distinct a.cod_categoria as value_col, b.descripcion as label_col, a.cod_centro as key_col, a.cod_categoria as title_col from tbl_adm_tipo_admision_x_cds a, tbl_adm_categoria_admision b where a.cod_categoria=b.codigo "+sbSql.toString()+" order by b.descripcion");
%>
				Categor&iacute;a
				<%=fb.select("catCode",catCode,"","T")%>
				<script language="javascript">
				loadXML('../xml/categoria_adm_x_cds_x_user<%=UserDet.getUserId()%>.xml','catCode','<%=catCode%>','VALUE_COL','LABEL_COL',<%=((UserDet.getUserProfile().contains("0"))?"'":"'"+UserDet.getUserId()+"|")%><%=(!cds.trim().equals(""))?cds+"'":"'+document.search00.cds.value"%>,'KEY_COL','T');
				</script>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,5,null,null,null)%>
			</td>
			<td width="50%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion","",false,false,false,40,null,null,null)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<%}%>
<tr>
	<td align="right">&nbsp;</td>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("catCode",catCode).replaceAll(" id=\"catCode\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("catCode",catCode).replaceAll(" id=\"catCode\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="65%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Genera Atenci&oacute;n</cellbytelabel>?</td>
		</tr>
<%fb = new FormBean("tipoAdmision",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%
String centroServicio = "";
String categoria = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (cdo.getColValue("cds_atencion") != null && !cdo.getColValue("cds_atencion").trim().equals("") && (cdo.getColValue("estado_ini_atencion") == null || cdo.getColValue("estado_ini_atencion").trim().equals(""))) color += " RedText";
%>
		<%=fb.hidden("centroServicio"+i,cdo.getColValue("centroServicio"))%>
		<%=fb.hidden("centroServicioDesc"+i,cdo.getColValue("centroServicioDesc"))%>
		<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
		<%=fb.hidden("categoriaDesc"+i,cdo.getColValue("categoriaDesc"))%>
		<%=fb.hidden("tipoAdmision"+i,cdo.getColValue("tipoAdmision"))%>
		<%=fb.hidden("tipoAdmisionDesc"+i,cdo.getColValue("tipoAdmisionDesc"))%>
		<%=fb.hidden("estadoAdm"+i,cdo.getColValue("estadoAdm"))%>
		<%=fb.hidden("adm_type"+i,cdo.getColValue("adm_type"))%>
		<%=fb.hidden("cds_atencion"+i,cdo.getColValue("cds_atencion"))%>
		<%=fb.hidden("estado_ini_atencion"+i,cdo.getColValue("estado_ini_atencion"))%>
<%
	if (!centroServicio.equalsIgnoreCase(cdo.getColValue("centroServicio")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="3"><cellbytelabel>CDS / &Aacute;rea</cellbytelabel>: [<%=cdo.getColValue("centroServicio")%>] <%=cdo.getColValue("centroServicioDesc")%></td>
		</tr>
<%
	}
	if (!centroServicio.equalsIgnoreCase(cdo.getColValue("centroServicio")) || !categoria.equalsIgnoreCase(cdo.getColValue("categoria")))
	{
%>
		<tr class="TextHeader02">
			<td colspan="3">&nbsp;&nbsp;&nbsp;<cellbytelabel>CATEGORIA</cellbytelabel>: [<%=cdo.getColValue("categoria")%>] <%=cdo.getColValue("categoriaDesc")%></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setTipoAdmision(<%=i%>)" style="cursor:pointer">
			<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("tipoAdmision")%></td>
			<td><%=cdo.getColValue("tipoAdmisionDesc")%></td>
			<td align="center"><%=(cdo.getColValue("cds_atencion") != null && !cdo.getColValue("cds_atencion").trim().equals(""))?"SI":"NO"%><!--<%=cdo.getColValue("cds_atencion")%>/<%=cdo.getColValue("estado_ini_atencion")%>--></td>
		</tr>
<%
	centroServicio = cdo.getColValue("centroServicio");
	categoria = cdo.getColValue("categoria");
}
%>
<%=fb.formEnd()%>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("catCode",catCode).replaceAll(" id=\"catCode\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("catCode",catCode).replaceAll(" id=\"catCode\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
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
}
%>