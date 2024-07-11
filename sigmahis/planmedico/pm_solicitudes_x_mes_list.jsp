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

String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String estado = "", anio = cDate.substring(6,10), mes = cDate.substring(3,5);
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

  if(request.getParameter("anio")!=null) anio = request.getParameter("anio");
  if(request.getParameter("mes")!=null) mes = request.getParameter("mes");
	if(request.getParameter("estado")!=null) {estado = request.getParameter("estado");userClickedIrButton = true;}

	sbSql.append("select s.id id_plan, s.id_cliente, s.estado, decode(s.estado,'P','Pendiente','A','Aprobado','Inactivo') estado_dsp, s.afiliados tipo_plan, a.descripcion || ' [ B/ ' || to_char(a.monto, '999,999.99') || ']' plan_desc, to_char(s.fecha_ini_plan,'dd/mm/yyyy') fecha_ini_plan, trim(to_char(s.fecha_ini_plan,'MONTH','NLS_DATE_LANGUAGE=SPANISH'))||' '||to_char(s.fecha_ini_plan,'yyyy') fecha_ini_plan_mes, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre) ||' '|| c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_responsable, to_char(s.fecha_ini_plan,'mm') s_mes, to_char(s.fecha_ini_plan,'yyyy') s_anio from tbl_pm_solicitud_contrato s, tbl_pm_cliente c, tbl_pm_afiliado a where c.estatus = 'A' and s.id_cliente = c.codigo and s.afiliados = a.id ");
	
	if (!estado.equals("")) {
    sbSql.append(" and s.estado = '");
    sbSql.append(estado);
    sbSql.append("'");
	}
	if (request.getParameter("mes")!=null && !request.getParameter("mes").equals("")) {
    sbSql.append(" and to_char(s.fecha_ini_plan,'mm') = '");
    sbSql.append(mes);
    sbSql.append("'");
	}
	if (!anio.equals("")) {
    sbSql.append(" and to_char(s.fecha_ini_plan,'yyyy') = '");
    sbSql.append(anio);
    sbSql.append("'");
	}
	
	sbSql.append(" order by 7,6");
	
	
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
   var sMes = "<%=mes%>" =="" ? "0" : "<%=mes%>";
   var sAnio = "<%=anio%>" =="" ? "0" : "<%=anio%>";
   var sPlan = "0";
   
   if (typeof option == "undefined") {}
   else if(option=='print'){
       if(getId() != "") {
          estado = document.getElementById("s_estado"+getId()).value;
          sMes = document.getElementById("s_mes"+getId()).value;
          sAnio = document.getElementById("s_anio"+getId()).value;
          sPlan = document.getElementById("id_plan"+getId()).value;
       }
       abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_solicitudes_x_mes.rptdesign&idPlan="+sPlan+"&pMes="+sMes+"&pAnio="+sAnio+"&pEstado="+estado+"&pCtrlHeader=false");
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
		  <td colspan="2">&nbsp;<cellbytelabel>A&ntilde;o</cellbytelabel>&nbsp;
		  <%=fb.textBox("anio",anio,false,false,false,4,4,null,null,"onClick=\"this.select()\"")%>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cellbytelabel>Mes</cellbytelabel>
			<%=fb.select(ConMgr.getConnection(),"select lpad(level, 2, '0') m_id, to_char((to_date('01/'||level||'/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy')),'Month','NLS_DATE_LANGUAGE=SPANISH') m_dsp from dual connect by level <= 12 order by 1","mes",mes,false,false,0,"", "", "", "", "S")%>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cellbytelabel>Estado</cellbytelabel>
			<%=fb.select("estado","A=Aprobado,I=Inactivo,P=Pendiente",estado,"T")%>
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
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
          <%=fb.hidden("anio",anio)%>
				  <%=fb.hidden("mes",mes)%>
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
	  <td width="5%" align="center">&nbsp;<cellbytelabel>#Plan</cellbytelabel></td>
	  <td width="30%" align="left">&nbsp;<cellbytelabel>Plan</cellbytelabel></td>
		<td width="5%" align="center">&nbsp;<cellbytelabel>#Resp</cellbytelabel></td>
		<td width="35%" align="left">&nbsp;<cellbytelabel>Nombre Responsable</cellbytelabel></td>
		<td width="10%" align="center">&nbsp;<cellbytelabel>Fecha Ini Plan</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curId","")%>
<%
				
				String groupByMes = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 				 
				 if (!groupByMes.equals(cdo.getColValue("fecha_ini_plan_mes"))){
				   
				 %>
				     <tr class="TextHeader01">
				       <td colspan="7"><%=cdo.getColValue("fecha_ini_plan_mes")%></td>
				     </tr>
				 <%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id_plan")%></td>
					<td align="left">&nbsp;<%=cdo.getColValue("plan_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("id_cliente")%></td>
					<td><%=cdo.getColValue("nombre_responsable")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_ini_plan")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_dsp")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("id_plan"+i,cdo.getColValue("id_plan"))%>
				<%=fb.hidden("s_mes"+i,cdo.getColValue("s_mes"))%>
				<%=fb.hidden("s_anio"+i,cdo.getColValue("s_anio"))%>
				<%=fb.hidden("s_estado"+i,cdo.getColValue("estado"))%>
				<%
				groupByMes = cdo.getColValue("fecha_ini_plan_mes");
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
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
          <%=fb.hidden("anio",anio)%>
				  <%=fb.hidden("mes",mes)%>
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