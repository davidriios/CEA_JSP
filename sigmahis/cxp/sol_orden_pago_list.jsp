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
String sql = "";
String appendFilter = "";
String nom_beneficiario = request.getParameter("nom_beneficiario");
String documento = request.getParameter("documento");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String estado = request.getParameter("estado")==null?"":request.getParameter("estado");
if(nom_beneficiario == null) nom_beneficiario = "";
if(documento == null) documento = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";

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

	if (request.getParameter("nom_beneficiario") != null && !request.getParameter("nom_beneficiario").equals(""))
  {
    appendFilter += " and upper(c.nombre) like '%"+request.getParameter("nom_beneficiario").toUpperCase()+"%'";
  }

	 if (request.getParameter("documento") != null && !request.getParameter("documento").equals(""))
  {
    appendFilter += " and a.documento = "+request.getParameter("documento");
  }

  if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
  {
    appendFilter += " and trunc(a.fecha) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
	}

  if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
  {
    appendFilter += " and trunc(a.fecha) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
	}
   
 if (!estado.trim().equals("")) {
	appendFilter += " and a.estado1 = '"+estado+"'";
 }  
	
  sql = "select a.documento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.beneficiario, a.unidad_adm1, to_char(a.monto,'999,999,999.00') monto, a.estado1, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc, b.descripcion unidad_descripcion, c.nombre beneficiario_descripcion from tbl_cxp_orden_unidad a, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c where /*a.estado1 in('P','X','A') and (a.estado_final is null or estado_final='N') and*/ a.compania = b.compania and a.unidad_adm1 = b.codigo and a.compania = c.compania and a.beneficiario = c.codigo and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by a.fecha desc";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Pagos Otros - '+document.title;
var ignoreSelectAnyWhere = true;

function add()
{
	abrir_ventana('../cxp/reg_orden_pago.jsp');
}

function edit(code, fecha)
{
	abrir_ventana('../cxp/reg_orden_pago.jsp?mode=edit&documento='+code+'&fecha='+fecha);
}

function printList(){
 abrir_ventana2('../cxp/print_list_sol_orden_pago.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function printSol(doc,fecha){
  abrir_ventana('../cxp/print_sol_orden_pago.jsp?mode=edit&doc='+doc+'&fecha='+fecha);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">
	    		<authtype type='3'><a href="javascript:add()" class="Link00">[ Registro Nuevo ]</a></authtype>
	    	</td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td><cellbytelabel>Beneficiario</cellbytelabel>:
								<%=fb.textBox("nom_beneficiario",nom_beneficiario,false,false,false,40,"text10",null,"")%> 
                <cellbytelabel>Documento</cellbytelabel>:
                <%=fb.textBox("documento",documento,false,false,false,20,"text10",null,"")%> 
                <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha_desde" />
                <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
                <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
              </jsp:include>
			  &nbsp;&nbsp;&nbsp;Estado&nbsp;
			  <%=fb.select("estado","P=Pendiente,A=Aprobada,T=Autorizada,R=Procesada,N=Anulada,X=Rechazada",estado, false, false,0,"text10","T","","","T")%>
						<%=fb.submit("go","Ir")%>		  
            </td>
				    <%=fb.formEnd()%>	   </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		  		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
        <%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
        <%=fb.hidden("documento",documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
        <%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
        <%=fb.hidden("documento",documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
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
				<tr class="TextHeader">
					<td width="6%" align="center"><cellbytelabel>Documento</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
          <td width="30%"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="6%">&nbsp;</td>
					<td width="6%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("documento")%></td>
					<td><%=cdo.getColValue("fecha")%></td>
					<td><%=cdo.getColValue("unidad_adm1")%>&nbsp;-&nbsp;<%=cdo.getColValue("unidad_descripcion")%></td>
					<td><%=cdo.getColValue("beneficiario")%>&nbsp;-&nbsp;<%=cdo.getColValue("beneficiario_descripcion")%></td>
          <td align="right"><%=cdo.getColValue("monto")%>&nbsp;</td>
          <td><%=cdo.getColValue("estado1_desc")%></td>
					<td align="center">
					<authtype type='4'>
					<%if(cdo.getColValue("estado1").equals("P")){%>
					<a href="javascript:edit(<%=cdo.getColValue("documento")%>, '<%=cdo.getColValue("fecha")%>')" class="Link00Bold"><cellbytelabel>Editar</cellbytelabel></a>
					<%}%>
					</authtype>
					<td align="center">
					<authtype type='0'>
					<a href="javascript:printSol(<%=cdo.getColValue("documento")%>, '<%=cdo.getColValue("fecha")%>')" class="Link00Bold"><cellbytelabel>Imprimir</cellbytelabel></a></authtype>
					</td>
				</tr>
				<%
				}
				%>							
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
        <%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
        <%=fb.hidden("documento",documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
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
        <%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
        <%=fb.hidden("documento",documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
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