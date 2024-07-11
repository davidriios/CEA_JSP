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
String emp_name = "", emp_code = "", estado = "";
boolean userClickedIrButton = false;
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

  if(request.getParameter("emp_code")!=null) emp_code = request.getParameter("emp_code");
  if(request.getParameter("emp_name")!=null) emp_name = request.getParameter("emp_name");
	if(request.getParameter("estado")!=null) {estado = request.getParameter("estado");userClickedIrButton = true;}

	sbSql.append("select s.id id_sol_plan, e.id_empresa, e.nombre emp_name, e.estado,decode(e.estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc_emp, c.codigo id_responsable,c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre) ||' '|| c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_responsable, nvl((select sum(costo_mensual) from tbl_pm_sol_contrato_det where id_cliente = s.id_cliente and id_solicitud = s.id), 0) costo_mensual, s.afiliados, (select a.descripcion || ' [ B/ ' || to_char(a.monto, '999,999.99') || ']' from tbl_pm_afiliado a where a.id = s.afiliados and a.estado = 'A' and rownum = 1) plan_desc from tbl_pm_empresa e, tbl_pm_cliente c , tbl_pm_solicitud_contrato s where s.fecha_ini_plan is not null and e.id_empresa = c.id_empresa and c.codigo = s.id_cliente ");
	if(!emp_code.equals("")){
		sbSql.append(" and e.id_empresa = ");
		sbSql.append(emp_code);
	}
	if(!estado.equals("")){
		sbSql.append(" and e.estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	sbSql.append(" order by e.id_empresa");
	
	if (userClickedIrButton){
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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;

function doAction(){changeAltTitleAttr();}

function manage(option){
   var estado = "<%=estado%>" =="" ? "ANY" : "<%=estado%>";
   var idEmp = "<%=emp_code%>" =="" ? "0" : "<%=emp_code%>";
   var empName = "<%=emp_name%>" =="" ? "TODAS LA EMPRESAS" : "<%=emp_name%>";
   var idResp = "0";
   
   if (typeof option == "undefined") {}
   else if(option=='print'){
       if(getId()!="") {
          estado = document.getElementById("estado_empresa"+getId()).value;
          idEmp = document.getElementById("id_empresa"+getId()).value;
          empName = document.getElementById("nombre_empresa"+getId()).value;
          idResp = document.getElementById("id_resp"+getId()).value;
       }
       abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_afiliados_x_empresa.rptdesign&pIdEmp="+idEmp+"&pEmpName="+empName+"&pEstado="+estado+"&idResp="+idResp+"&pCtrlHeader=false");
   }
}

function changeAltTitleAttr(obj){
	if (typeof obj != "undefined"){
	  if (getId()!=""){
		obj.alt = "Imprimir Listado # "+getId();
		obj.title = "Imprimir Listado # "+getId();
	  }
	}else{
	  document.getElementById("printImg").alt = "Imprimir Listado";
	  document.getElementById("printImg").title = "Imprimir Listado";
	}
  
}

function addEmp(){abrir_ventana("../planmedico/pm_sel_empresa.jsp?fp=rpt_afi_emp");}

function getId(){return document.getElementById("curId").value;}
function setId(curId){document.getElementById("curId").value = curId;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
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
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manage('print')" onMouseOver="javascript:changeAltTitleAttr(this)" id="printImg"/>
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
		  <td colspan="2">&nbsp;<cellbytelabel>Empresa</cellbytelabel>&nbsp;
		  <%=fb.textBox("emp_code",emp_code,false,false,true,5,4,null,null,"")%>
		  <%=fb.textBox("emp_name",emp_name,false,false,true,50,100,null,null,"")%>
		  <%=fb.button("btnEmp","...",false,false,null,null,"onclick=addEmp()")%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo",estado,"T")%>
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
				<%=fb.hidden("emp_name",emp_name)%>
				<%=fb.hidden("emp_code",emp_code)%>
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
          <%=fb.hidden("emp_name",emp_name)%>
          <%=fb.hidden("emp_code",emp_code)%>
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
	<tr class="TextHeader">
		<td width="5%" align="center">&nbsp;<cellbytelabel>#Resp</cellbytelabel></td>
		<td width="40%">&nbsp;<cellbytelabel>Nombre Responsable</cellbytelabel></td>
		<td width="5%" align="center">&nbsp;<cellbytelabel>#Sol</cellbytelabel></td>
		<td width="35%">&nbsp;<cellbytelabel>[#] Plan</cellbytelabel></td>
		<td width="10%" align="right"><cellbytelabel>Monto Mensual</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curId","")%>
<%
				
				String groupByEmpId = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 				 
				 if (!groupByEmpId.equals(cdo.getColValue("id_empresa"))){	 
				 %>
				     <tr class="TextHeader01">
				       <td colspan="6">[<%=cdo.getColValue("id_empresa")%>] <%=cdo.getColValue("emp_name")%></td>
				     </tr>
				 <%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id_responsable")%></td>
					<td><%=cdo.getColValue("nombre_responsable")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("id_sol_plan")%></td>
					<td>&nbsp;[<%=cdo.getColValue("afiliados")%>] <%=cdo.getColValue("plan_desc")%></td>
					<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("costo_mensual"))%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("id_empresa"+i,cdo.getColValue("id_empresa"))%>
				<%=fb.hidden("nombre_empresa"+i,cdo.getColValue("emp_name"))%>
				<%=fb.hidden("estado_empresa"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("id_resp"+i,cdo.getColValue("id_responsable"))%>
				<%
				groupByEmpId = cdo.getColValue("id_empresa");
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
				<%=fb.hidden("emp_name",emp_name)%>
				<%=fb.hidden("emp_code",emp_code)%>
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
          <%=fb.hidden("emp_name",emp_name)%>
          <%=fb.hidden("emp_code",emp_code)%>
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