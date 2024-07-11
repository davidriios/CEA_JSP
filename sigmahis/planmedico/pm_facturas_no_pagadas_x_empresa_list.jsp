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
String estado = "P", noFactura = "";
boolean userClickedIrButton = false;
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

CommonDataObject cdoD = SQLMgr.getData("select to_char(last_day(add_months(sysdate,-1))+1,'dd/mm/yyyy') first_day, to_char(sysdate,'dd/mm/yyyy') c_date from dual");

String fechaIni = cdoD.getColValue("first_day"), fechaFin = cdoD.getColValue("c_date");

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

  if(request.getParameter("fecha_ini")!=null) fechaIni = request.getParameter("fecha_ini");
  if(request.getParameter("fecha_fin")!=null) fechaFin = request.getParameter("fecha_fin");
  if(request.getParameter("no_factura")!=null) noFactura = request.getParameter("no_factura");
	if(request.getParameter("estado")!=null) {estado = request.getParameter("estado");userClickedIrButton = true;}

	sbSql.append(" select f.estatus, fd.fac_codigo,fd.descripcion,fd.monto,fd.tipo,fd.descuento, e.id_empresa, e.nombre, f.nombre_cliente, to_char(f.fecha,'dd/mm/yyyy')f_factura from tbl_fac_detalle_factura fd, tbl_fac_factura f, tbl_pm_empresa e, tbl_pm_cliente c where fd.fac_codigo = f.codigo and fd.compania = f.compania and f.facturado_por = 'PLAN_MEDICO' and c.id_empresa = e.id_empresa and c.codigo = f.cod_otro_cliente ");
	
	if (!estado.equals("")) {
    sbSql.append(" and f.estatus = '");
    sbSql.append(estado);
    sbSql.append("'");
	}
	if (!noFactura.equals("")) {
    sbSql.append(" and fd.fac_codigo = '");
    sbSql.append(noFactura);
    sbSql.append("'");
	}
	if (!fechaIni.equals("") && !fechaFin.equals("") ) {
    sbSql.append(" and f.fecha between to_date('");
    sbSql.append(fechaIni);
    sbSql.append("','dd/mm/yyyy') and to_date('");
    sbSql.append(fechaFin);
    sbSql.append("','dd/mm/yyyy') ");
	}
	
	sbSql.append(" order by e.id_empresa /**/ ");
	
	
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
   var noFactura = "<%=noFactura%>" =="" ? "0" : "<%=noFactura%>";
   var fechaIni = "<%=fechaIni%>";
   var fechaFin = "<%=fechaFin%>";
   
   if (typeof option == "undefined") {}
   else if(option=='print'){
       if(getId() != "") {
          estado = document.getElementById("estado"+getId()).value;
          noFactura = document.getElementById("no_factura"+getId()).value;
          fechaIni = document.getElementById("fecha_ini").value;
          fechaFin = document.getElementById("fecha_fin").value;
       }
       if(fechaIni !="" || fechaFin != "")abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_facturas_nopagadas_x_empresa.rptdesign&noFactura="+noFactura+"&fechaIni="+fechaIni+"&fechaFin="+fechaFin+"&pEstado="+estado+"&pCtrlHeader=false");
       else alert("Es obligatorio un rango de Fecha!");
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
<%@ include file="../common/calendar_base.jsp" %>
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
		  <td colspan="2">&nbsp;<cellbytelabel>#Factura</cellbytelabel>&nbsp;
		  <%=fb.textBox("no_factura",noFactura,false,false,false,20,20,null,null,"onClick=\"this.select()\"")%>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fecha_ini" />
				<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
				<jsp:param name="nameOfTBox2" value="fecha_fin" />
				<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cellbytelabel>Estado</cellbytelabel>
			<%=fb.select("estado","A=Anulada,C=Cancelada,P=Pendiente",estado,"T")%>
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
				<%=fb.hidden("fecha_ini",fechaIni)%>
				<%=fb.hidden("fecha_fin",fechaFin)%>
				<%=fb.hidden("no_factura",noFactura)%>
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
          <%=fb.hidden("fecha_ini",fechaIni)%>
				<%=fb.hidden("fecha_fin",fechaFin)%>
				<%=fb.hidden("no_factura",noFactura)%>
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
	  <td width="7%" align="center">&nbsp;<cellbytelabel>#Factura</cellbytelabel></td>
	  <td width="39%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="5%" align="right">&nbsp;<cellbytelabel>Monto</cellbytelabel></td>
		<td width="35%">&nbsp;<cellbytelabel>Nombre Cliente</cellbytelabel></td>
		<td width="10%" align="center">&nbsp;<cellbytelabel>Fecha Generaci&oacute;n</cellbytelabel></td>
		<td width="3%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curId","")%>
<%
				
				String groupByEmp = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 				 
				 if (!groupByEmp.equals(cdo.getColValue("id_empresa"))){
				   
				 %>
				     <tr class="TextHeader01">
				       <td colspan="7">[<%=cdo.getColValue("id_empresa")%>] <%=cdo.getColValue("nombre")%></td>
				     </tr>
				 <%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("fac_codigo")%></td>
					<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
					<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td><%=cdo.getColValue("nombre_cliente")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("f_factura")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("no_factura"+i,cdo.getColValue("fac_codigo"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estatus"))%>
				<%
				groupByEmp = cdo.getColValue("id_empresa");
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
				<%=fb.hidden("fecha_ini",fechaIni)%>
				<%=fb.hidden("fecha_fin",fechaFin)%>
				<%=fb.hidden("no_factura",noFactura)%>
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
          <%=fb.hidden("fecha_ini",fechaIni)%>
				<%=fb.hidden("fecha_fin",fechaFin)%>
				<%=fb.hidden("no_factura",noFactura)%>
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