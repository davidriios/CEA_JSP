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
String nombre = "";
String ruc = "", estado="", telefono="";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");
String fp = request.getParameter("fp");
if(fp==null) fp="";

if (fp.trim().equals("")) throw new Exception("No pudimos determinar donde agregar la empresa!");

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
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

  if(request.getParameter("nombre")!=null) nombre = request.getParameter("nombre");
	if(request.getParameter("ruc")!=null) ruc = request.getParameter("ruc");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("telefono")!=null) telefono = request.getParameter("telefono");
	sbSql.append("select id_empresa, nombre, ruc, dv, direccion, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, estado, observacion, telefono, fax, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc from tbl_pm_empresa where 1=1 ");
	if(!nombre.equals("")){
		sbSql.append(" and nombre like '%");
		sbSql.append(nombre);
		sbSql.append("%'");
	}
	if(!ruc.equals("")){
		sbSql.append(" and ruc like '%");
		sbSql.append(ruc);
		sbSql.append("%'");
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!telefono.equals("")){
		sbSql.append(" and telefono like '%");
		sbSql.append(telefono);
		sbSql.append("%'");
	}
	sbSql.append(" order by id_empresa nulls last ");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");

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
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;
function doAction(){}
function manageSurvey(option){
   if (typeof option == "undefined") abrir_ventana('../planmedico/pm_empresa_config.jsp');
}
function setValues(i){
	<%if(fp.equals("cliente")){%>
	window.opener.form0.id_empresa.value=eval('document.form00.id_empresa'+i).value;
	window.opener.form0.lt_nombre.value=eval('document.form00.nombre'+i).value;
	window.opener.form0.lt_direccion.value=eval('document.form00.direccion'+i).value;
	window.opener.form0.lt_telefono.value=eval('document.form00.telefono'+i).value;
	<%}else if (fp.equals("rpt_afi_emp")){%>
	   window.opener.search01.emp_code.value=eval('document.form00.id_empresa'+i).value;
     window.opener.search01.emp_name.value=eval('document.form00.nombre'+i).value;
     window.opener.search01.submit();
	<%}%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr><%//="[2] IMPRIMIR       [3] REGISTRAR       [4] EDITAR"  %>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nueva Empresa" title="Registrar Nueva Empresa" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td colspan="2">&nbsp;<cellbytelabel id="2">Nombre</cellbytelabel>&nbsp;
			<%=fb.textBox("nombre",nombre,false,false,false,50,null,null,null)%>
			&nbsp;<cellbytelabel>Tel&eacute;fono</cellbytelabel>&nbsp;
			<%=fb.textBox("telefono",telefono,false,false,false,30,null,null,null)%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo",estado,"T")%>
			&nbsp;<cellbytelabel>RUC</cellbytelabel>&nbsp;
			<%=fb.textBox("ruc",ruc,false,false,false,30,null,null,null)%>
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<!--<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		</td>
	</tr>-->
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("telefono",telefono)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("telefono",telefono)%>
				<%=fb.hidden("estado",estado)%>
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
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="50%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="25%"><cellbytelabel>RUC</cellbytelabel></td>
		<td width="25%"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("id_empresa"+i,cdo.getColValue("id_empresa"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("direccion"+i,cdo.getColValue("direccion"))%>
				<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="setValues(<%=i%>)" style="cursor:pointer">
					<td align="center">&nbsp;<%=cdo.getColValue("id_empresa")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("ruc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("telefono")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
				</tr>
				<%
				}
				%>
<%=fb.formEnd(true)%>
</table>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("telefono",telefono)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("telefono",telefono)%>
				<%=fb.hidden("estado",estado)%>
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