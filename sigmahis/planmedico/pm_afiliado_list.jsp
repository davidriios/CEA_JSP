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
String id = "", descripcion = "";
String estado="", cuota_mensual="", cm_oper="", cantMax = "", cantMin = "";
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

  if(request.getParameter("id")!=null) id = request.getParameter("id");
	if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("cuota_mensual")!=null) cuota_mensual = request.getParameter("cuota_mensual");
	if(request.getParameter("cm_oper")!=null) cm_oper = request.getParameter("cm_oper");
	if(request.getParameter("cant_max")!=null) cantMax = request.getParameter("cant_max");
	if(request.getParameter("cant_min")!=null) cantMin = request.getParameter("cant_min");

	sbSql.append("select id, descripcion, monto, estado, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, observacion, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc, cant_min||' - '||cant_max cant_min_max  from tbl_pm_afiliado where 1=1 ");
	if(!id.equals("")){
		sbSql.append(" and id = ");
		sbSql.append(id);
	}
	if(!descripcion.equals("")){
		sbSql.append(" and descripcion like '%");
		sbSql.append(descripcion);
		sbSql.append("%'");
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!cuota_mensual.equals("")){
		sbSql.append(" and monto ");
		sbSql.append(cm_oper);
		sbSql.append(cuota_mensual);
	}
	if(!cantMin.equals("")){
		sbSql.append(" and cant_min = ");
		sbSql.append(cantMin);
	}
	if(!cantMax.equals("")){
		sbSql.append(" and cant_max = ");
		sbSql.append(cantMax);
	}

	sbSql.append(" order by id nulls last ");
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
document.title = 'Plan Medicico - Mantenimiento - Afiliado por Plan - '+document.title;

function doAction(){changeAltTitleAttr();}

function manageSurvey(option){
   if (typeof option == "undefined") abrir_ventana('../planmedico/reg_afiliado.jsp');
   else if(option=='edit'){
    if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else abrir_ventana('../planmedico/reg_afiliado.jsp?mode=edit&id='+getCurVal());
   }
   else if (option=='print'){
      if (getCurVal() != ""){
        abrir_ventana("../planmedico/pm_print_afiliados_list.jsp?idAfiliado="+getCurVal());
      }else{
        abrir_ventana("../planmedico/pm_print_afiliados_list.jsp?idAfiliado=<%=id%>&descripcion=<%=descripcion%>&estado=<%=estado%>&cantMin=<%=cantMin%>&cantMax=<%=cantMax%>&cuotaMensual=<%=cuota_mensual%>&cmOper=<%=cm_oper%>");
      }
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
	  document.getElementById("printImg").alt = "Imprimir Lista Afiliado por Plan";
	  document.getElementById("editImg").alt = "Seleccione una Plan a Editar";
	  document.getElementById("printImg").title = "Imprimir Lista Afiliado por Plan";
	  document.getElementById("editImg").title = "Seleccione una Plan a Editar";
	}
}

function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal){document.getElementById("curVal").value = curVal;}
//window.ignorePage = false;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr><%//="[2] IMPRIMIR       [3] REGISTRAR       [4] EDITAR"  %>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nuevo Afiliado por Plan" title="Registrar Nuevo Afiliado por Plan" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" width="32px" height="32px" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Afiliado por Plan')" id="editImg" />
			</authtype>&nbsp;
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Afiliado por Plan')" id="printImg"/>
			</authtype>
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">&nbsp;<cellbytelabel id="2">C&oacute;digo</cellbytelabel>&nbsp;
			<%=fb.intBox("id",id,false,false,false,5,10,"Text10",null,null)%>
			&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel>&nbsp;
			<%=fb.textBox("descripcion",descripcion,false,false,false,30,"Text10",null,"")%>
			&nbsp;<cellbytelabel>Cantidad Afiliados entre </cellbytelabel>&nbsp;
			<%=fb.intBox("cant_min", cantMin, false, false, false, 2, 2, "text12", "", "", "", false, "", "")%>
			&nbsp;y&nbsp;
			<%=fb.intBox("cant_max", cantMax, false, false, false, 2, 2, "text12", "", "", "", false, "", "")%>

			&nbsp;<cellbytelabel>Cuota Mensual</cellbytelabel>&nbsp;
			<select id="cm_oper" name="cm_oper" size="0" class="Text12">
				<option value = ">" <%=(cm_oper.equals(">")?"selected":"")%>>&gt;</option>
				<option value = ">=" <%=(cm_oper.equals(">=")?"selected":"")%>>&gt;=</option>
				<option value = "=" <%=(cm_oper.equals("=")?"selected":"")%>>=</option>
				<option value = "<=" <%=(cm_oper.equals("<=")?"selected":"")%>>&lt;=</option>
				<option value = "<" <%=(cm_oper.equals("<")?"selected":"")%>>&lt;</option>
			</select>
			<%=fb.decBox("cuota_mensual", cuota_mensual, false, false, false, 12, 12.2, "text12", "", "", "", false, "", "")%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;

			&nbsp;&nbsp;&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo",estado,"T")%>
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
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cm_oper",cm_oper)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
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
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cm_oper",cm_oper)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
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
		<td width="40%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>Min</cellbytelabel> - <cellbytelabel>Max</cellbytelabel></td>
		<td width="25%"><cellbytelabel>Cuota Mensual</cellbytelabel></td>
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
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=cdo.getColValue("cant_min_max")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("monto")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+")\"")%>
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
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cm_oper",cm_oper)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
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
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cm_oper",cm_oper)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
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