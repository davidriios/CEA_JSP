<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*
*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sql= new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
int iconHeight = 40;
int iconWidth = 40;
String  file837= "N";
try {file837 =java.util.ResourceBundle.getBundle("issi").getString("file837");}catch(Exception e){ file837 = "N";}

if(fg==null) fg = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 50;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  String factura   = "", fDate="", tDate="", feFDate="", feTDate="", aseguradora="", aseguradora_desc="", enviado="",id="", lista = "";
	if(request.getParameter("factura")!=null) factura = request.getParameter("factura");
	if(request.getParameter("aseguradora")!=null) aseguradora = request.getParameter("aseguradora");
	if(request.getParameter("aseguradora_desc")!=null) aseguradora_desc = request.getParameter("aseguradora_desc");
	if(request.getParameter("fDate")!=null) fDate = request.getParameter("fDate");
	if(request.getParameter("tDate")!=null) tDate = request.getParameter("tDate");
	if(request.getParameter("feFDate")!=null) feFDate = request.getParameter("feFDate");
	if(request.getParameter("feTDate")!=null) feTDate = request.getParameter("feTDate");
	if(request.getParameter("enviado")!=null) enviado = request.getParameter("enviado");
	if(request.getParameter("lista")!=null) lista = request.getParameter("lista");
	if(request.getParameter("id")!=null) id = request.getParameter("id");
	String cds = request.getParameter("cds");
	String categoria = request.getParameter("categoria");
	if (cds == null) cds = "";
	if(categoria==null) categoria = "";

  if (!factura.trim().equals("")){
    sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed where a.id = ed.id and ed.factura like '");
		sbFilter.append(factura);
		sbFilter.append("%')");
  }
  if (!aseguradora.trim().equals("")){
    sbFilter.append(" and a.aseguradora = ");
		sbFilter.append(aseguradora);
  }
  if (!fDate.trim().equals("")){
    sbFilter.append(" and a.fecha_creacion >= to_date('");
		sbFilter.append(fDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!tDate.trim().equals("")){
    sbFilter.append(" and a.fecha_creacion <= to_date('");
		sbFilter.append(tDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!feFDate.trim().equals("")){
    sbFilter.append(" and a.fecha_envio >= to_date('");
		sbFilter.append(feFDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!feTDate.trim().equals("")){
    sbFilter.append(" and a.fecha_envio <= to_date('");
		sbFilter.append(feTDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!enviado.trim().equals("")){
    sbFilter.append(" and a.enviado = '");
		sbFilter.append(enviado);
		sbFilter.append("'");
  }
  if (!id.trim().equals("")){
      sbFilter.append(" and a.id = ");
  		sbFilter.append(id);
  }
  if (!lista.trim().equals("")){
      sbFilter.append(" and a.lista = ");
  		sbFilter.append(lista);
  }
		if (cds.trim().equalsIgnoreCase("")) {
			if (!UserDet.getUserProfile().contains("0")) {
				sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed, tbl_adm_admision ad where ed.id = a.id and ed.compania = a.compania and ed.pac_id = ad.pac_id and ed.admision = ad.secuencia and ed.compania = ad.compania and ad.centro_servicio in (select codigo from tbl_cds_centro_servicio where si_no = 'S') and ad.centro_servicio in (select cds from tbl_sec_user_cds where user_id=");
				sbFilter.append(UserDet.getUserId());
				sbFilter.append("))");
			}
		} else {
			sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed, tbl_adm_admision ad where ed.id = a.id and ed.compania = a.compania and ed.pac_id = ad.pac_id and ed.admision = ad.secuencia and ed.compania = ad.compania and ad.centro_servicio in (select codigo from tbl_cds_centro_servicio where si_no = 'S' ) and ad.centro_servicio = ");
			sbFilter.append(cds);
			sbFilter.append(")");
		}
		if(!categoria.equals("")){
			sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed where ed.id = a.id and ed.compania = a.compania and ed.categoria = ");
			sbFilter.append(categoria);
			sbFilter.append(")");
		}
			if(request.getParameter("feFDate")!=null){
  sql.append("select a.enviado, to_char(a.fecha_recibido, 'dd/mm/yyyy')as  fecha_recibido, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_modificacion, to_char(a.system_date, 'dd/mm/yyyy') system_date, to_char(a.fecha_creacion, 'dd/mm/yyyy') as fecha_creacion, a.usuario_creacion, a.enviado_por, a.comentario, a.lista, a.aseguradora, (select nombre from tbl_adm_empresa e where e.codigo = a.aseguradora) aseguradora_desc, to_char(a.fecha_envio, 'dd/mm/yyyy') as fecha_envio, a.compania, a.id, (select name from tbl_sec_users where user_name = a.usuario_creacion) usuario_creacion_name, decode(a.enviado, 'S', 'Si', 'N', 'No', a.enviado) enviado_desc, nvl((select name from tbl_sec_users where user_name = a.enviado_por ), '') enviado_por_name,(case when a.aseguradora in (select column_value from table(select split((select get_sec_comp_param(a.compania,'COD_EMP_AXA') from dual),',') from dual))  then 'S' else 'N' end ) is_axa, join(cursor((select distinct descripcion from tbl_cds_centro_servicio cds where exists (select null from tbl_adm_admision adm where adm.centro_servicio = cds.codigo and adm.compania = cds.compania_unorg and exists (select null from tbl_fac_lista_envio_det ld where ld.pac_id = adm.pac_id and ld.admision = adm.secuencia and ld.id = a.id and ld.compania = a.compania)))), ', ') area_admite ,to_char(a.fecha_recibido_cxc, 'dd/mm/yyyy')as  fecha_recibido_cxc,nvl((select genera_archivo from tbl_adm_empresa e where e.codigo = a.aseguradora),'N') as genera_file from tbl_fac_lista_envio a ");
  sql.append(" where a.compania = ");
  sql.append(session.getAttribute("_companyId"));
  sql.append(sbFilter.toString());
	sql.append("and a.aseguradora in (select codigo from tbl_adm_empresa where grupo_empresa = get_sec_comp_param (1, 'LIQ_RECL_TIPO_EMP'))");
  sql.append(" order by a.fecha_creacion desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql.toString()+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var xHeight=0;
function printList(){abrir_ventana('../facturacion/print_list_envio.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg=<%=fg%>');}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=consFact');}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}

function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function addAseguradora(){
	abrir_ventana1('../common/search_empresa.jsp?fp=list_envio');
}
function showReport(){
	var aseguradora 		= document.search01.aseguradora.value;
	var aseguradora_desc 		= document.search01.aseguradora_desc.value;
	var fDate 			= document.search01.fDate.value;
	var tDate 			= document.search01.tDate.value;
	var enviado 			= document.search01.enviado.value;
	if(enviado=='') CBMSG.warning('Seleccionar facturas enviadas Si/No!');
	else if(aseguradora=='') CBMSG.warning('Seleccione Aseguradora!');
	else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/list_aseguradora.rptdesign&enviadoParam='+enviado+'&aseguradoraParam='+aseguradora+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&aseguradoraDescParam='+aseguradora_desc);
}

function setLista(i){
	window.opener.document.search01.p_lista.value=eval('document.form0.id'+i).value;
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
 <jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - LISTAS DE ENVIO"></jsp:param>
</jsp:include>
 <table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
  <tr>
    <td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("fg",fg)%>
        <tr class="TextFilter">
        <td>
				<cellbytelabel>No. Factura</cellbytelabel><%=fb.textBox("factura",factura,false,false,false,10)%>
				&nbsp;&nbsp;
				<cellbytelabel>Empresa</cellbytelabel>
				<%=fb.hidden("aseguradora", aseguradora)%>
				<%=fb.textBox("aseguradora_desc",aseguradora_desc,false,false,true,36,"Text10",null,null)%>
				<%=fb.button("btnAseguradora","...",true,false,null,null,"onClick=\"javascript:addAseguradora()\"")%>
				&nbsp;&nbsp;
				<cellbytelabel>F. Creaci&oacute;n</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				<jsp:param name="nameOfTBox2" value="tDate" />
				<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				&nbsp;&nbsp;
				<cellbytelabel>F. Envio</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="feFDate" />
				<jsp:param name="valueOfTBox1" value="<%=feFDate%>" />
				<jsp:param name="nameOfTBox2" value="feTDate" />
				<jsp:param name="valueOfTBox2" value="<%=feTDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
				<td colspan="3">
						<%StringBuffer sbSql = new StringBuffer();
					if (!UserDet.getUserProfile().contains("0")) { sbSql.append(" and codigo in (select cds from tbl_sec_user_cds where user_id="); sbSql.append(UserDet.getUserId()); sbSql.append(")"); }
					%>
				<cellbytelabel id="1">&Aacute;rea</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_cds_centro_servicio where si_no = 'S' and estado='A' "+sbSql.toString()+" order by 2 asc","cds",cds,false,false,0,"Text10","width:175px",null,null,"T")%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No. Lista: <%=fb.textBox("lista",lista,false,false,false,10,"Text10",null,null)%>&nbsp;Lista ID: <%=fb.textBox("id",id,false,false,false,10,"Text10",null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;
					Cat. Admisi&oacute;n:
					<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_adm_categoria_admision order by codigo asc","categoria",categoria,false,false,0,null,null,null, "", "S")%>
					&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Enviado</cellbytelabel>
				<%=fb.select("enviado","S=Si,N=No",enviado,false,false,0,"Text10",null,null,null,"S")%>
				<%=fb.submit("go","Ir")%></td>
		</tr>
		<%=fb.formEnd(true)%>
      </table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

    </td>
  </tr>
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
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
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
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("enviado",enviado)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
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

<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

    <table align="center" width="100%" cellpadding="0" cellspacing="1">
    <tr class="TextHeader" align="center">
			<td width="17%"><cellbytelabel>Aseguradora</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel>.</td>
			<td width="6%"><cellbytelabel>Fecha CXC</cellbytelabel>.</td>
			<td width="5%"><cellbytelabel>Lista/ID</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Enviado</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Envio</cellbytelabel></td>
			<td width="16%"><cellbytelabel>Enviado por</cellbytelabel></td>
			<td width="6%"><cellbytelabel>F. Recibido</cellbytelabel></td>
			<td width="18%"><cellbytelabel>Area Admite</cellbytelabel></td>
    </tr>
		<%
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
		%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("is_axa"+i,cdo.getColValue("is_axa"))%>
		<%=fb.hidden("enviado"+i,cdo.getColValue("enviado"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<%=fb.hidden("fecha_envio"+i,cdo.getColValue("fecha_envio"))%>
		<%=fb.hidden("genera_file"+i,cdo.getColValue("genera_file"))%>
		<%=fb.hidden("aseguradora"+i,cdo.getColValue("aseguradora"))%>

    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onDblClick="javascript:setLista(<%=i%>)">
      <td align="center"><%=cdo.getColValue("aseguradora_desc")%></td>
			<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
      <td align="center"><%=cdo.getColValue("usuario_creacion_name")%></td>
	  <td align="center"><%=cdo.getColValue("fecha_recibido_cxc")%></td>
      <td align="center"><%=cdo.getColValue("lista")%>&nbsp;&nbsp;[<%=cdo.getColValue("id")%>]</td>
      <td align="center"><%=cdo.getColValue("enviado_desc")%></td>
      <td align="center"><%=cdo.getColValue("fecha_envio")%></td>
      <td align="center"><%=cdo.getColValue("enviado_por_name")%></td>
	  <td align="center"><%=cdo.getColValue("fecha_recibido")%></td>
      <td align="center"><%=cdo.getColValue("area_admite")%></td>
    </tr>
<%
}
%>
    </table>
<%=fb.formEnd()%>
</div>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

  </td>
</tr>
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
        <%=fb.hidden("fg",fg)%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("enviado",enviado)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
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
        <%=fb.hidden("fg",fg)%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("enviado",enviado)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
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
