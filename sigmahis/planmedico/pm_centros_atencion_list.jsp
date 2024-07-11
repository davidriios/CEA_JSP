<%//@ page errorPage="../error.jsp"%>
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
	sbSql.append("select c.id id_centro, c.nombre, c.ruc, c.dv, c.direccion, c.usuario_creacion, to_char(c.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, c.usuario_modificacion, to_char(c.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, c.estado, c.observacion, c.telefono, c.fax, decode(c.estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc, t.descripcion tipo_centro from tbl_pm_centros_atencion c, tbl_pm_tipo_centro_atencion t where c.tipo_centro = t.id ");
	if(!nombre.equals("")){
		sbSql.append(" and nombre like '%");
		sbSql.append(nombre.trim());
		sbSql.append("%'");
	}
	if(!ruc.equals("")){
		sbSql.append(" and c.ruc like '%");
		sbSql.append(ruc.trim());
		sbSql.append("%'");
	}
	if(!estado.equals("")){
		sbSql.append(" and c.estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!telefono.equals("")){
		sbSql.append(" and c.telefono like '%");
		sbSql.append(telefono.trim());
		sbSql.append("%'");
	}
	sbSql.append(" order by c.id nulls last ");
	
	if (request.getParameter("beginSearch") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;

function doAction(){changeAltTitleAttr();}

function manageSurvey(option){
   if (typeof option == "undefined") abrir_ventana('../planmedico/pm_centros_atencion_config.jsp');
   else if(option=='edit'){
      if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
      else abrir_ventana('../planmedico/pm_centros_atencion_config.jsp?mode=edit&id='+getCurVal());
   }
   else if(option=='print'){
      abrir_ventana('../planmedico/pm_print_centros_atencion_list.jsp?nombre=<%=nombre%>&ruc=<%=ruc%>&estado=<%=estado%>&telefono=<%=telefono%>&idEmpresa='+getCurVal());
   }
}

function changeAltTitleAttr(obj,type,ctx){
  var opt = {"edit":"Editar","print":"Imprimir"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
	  if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
	  }
	}else{
	  document.getElementById("printImg").alt = "Imprimir Lista Centro de atención";
	  document.getElementById("editImg").alt = "Seleccione un Centro de atención a Editar";
	  document.getElementById("printImg").title = "Imprimir Lista Centro de atención";
	  document.getElementById("editImg").title = "Seleccione un Centro de atención a Editar";
	}
}

function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal){document.getElementById("curVal").value = curVal;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Centro de atención"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nuevo centro" title="Registrar Nuevo centro" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" width="32px" height="32px" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Centro de atención')" id="editImg"/>
			</authtype>&nbsp;
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Centro de atención')" id="printImg"/>
			</authtype>
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td colspan="2">&nbsp;<cellbytelabel id="2">Nombre</cellbytelabel>&nbsp;
			<%=fb.textBox("nombre",nombre,false,false,false,30,null,null,null)%>
			&nbsp;<cellbytelabel>Tel&eacute;fono</cellbytelabel>&nbsp;
			<%=fb.textBox("telefono",telefono,false,false,false,15,null,null,null)%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo",estado,"T")%>
			&nbsp;<cellbytelabel>RUC</cellbytelabel>&nbsp;
			<%=fb.textBox("ruc",ruc,false,false,false,10,null,null,null)%>
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("telefono",telefono)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("beginSearch","")%>
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
		<td width="30%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="20%">&nbsp;<cellbytelabel>Tipo Centro</cellbytelabel></td>
		<td width="25%"><cellbytelabel>RUC</cellbytelabel></td>
		<td width="25%"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
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
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id_centro")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("tipo_centro")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("ruc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("telefono")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id_centro")+")\"")%>
					</td>
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
				<%=fb.hidden("beginSearch","")%>
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
				<%=fb.hidden("beginSearch","")%>
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