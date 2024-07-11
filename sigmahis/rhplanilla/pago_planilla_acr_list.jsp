
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
ArrayList newal = new ArrayList();
int rowCount = 0;
String sql = "";
String newsql = "";
String appendFilter = "";
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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
	
	String cheque = "";        // variables para mantener el valor de los campos filtrados en la consulta
	String nombre = "";
	String depto  = ""; 
	   
	if (request.getParameter("cheque") != null && !request.getParameter("cheque").trim().equals(""))
	{
		appendFilter += " and d.cod_acreedor like '%"+request.getParameter("cheque").toUpperCase()+"%' ";
		cheque     = request.getParameter("cheque");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
		appendFilter += " and upper(g.nombre) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
 		nombre    = request.getParameter("nombre");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	if (request.getParameter("depto") != null && !request.getParameter("depto").trim().equals(""))
	{
		appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("depto").toUpperCase()+"%'"; 
		depto  = request.getParameter("depto");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	} 
	if(request.getParameter("anio") != null)
	{
	sql= "select b.nombre as nombre, g.nombre as nomEmpleado, d.monto as monto, to_char(d.comision,'999,990.00') as comision, to_char(a.fecha_pago,'dd/mm/yyyy') as fechaPago, ltrim(b.nombre,18)||' del '||a.fecha_inicial||' al '||a.fecha_final as descripcion, d.cod_planilla as codPlanilla, d.num_planilla as numPlanilla, d.anio, d.num_cheque as cheque, g.cod_acreedor as codigo from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_pla_pago_acreedor d, tbl_pla_acreedor g where  a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and  a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania  and d.cod_acreedor = g.cod_acreedor and d.cod_compania = g.compania"+appendFilter;
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count  from ("+sql+")");
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
document.title = 'Planilla - '+document.title;
function add(){abrir_ventana1('../rhplanilla/calculo_planilla.jsp');}
function edit(empId,cod,anio,num,id){abrir_ventana1('../rhplanilla/pago_planilla_empleado.jsp?empId='+empId+'&cod='+cod+'&anio='+anio+'&num='+num+'&id='+id);}
function printList(cod,anio,num){abrir_ventana1('../rhplanilla/print_det_pagoacreedor.jsp?cod='+cod+'&anio='+anio+'&num='+num);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PAGO DE PLANILLA DE ACREEDORES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">		
<%fb = new FormBean("search11",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("cod",cod)%>
<%=fb.hidden("num",num)%>							
				<td width="50%">
					Cod. Acreedor:<%=fb.intBox("cheque",cheque,false,false,false,10)%>
				</td> 
				<td width="50%">
					Nombre Acreedor
					<%=fb.textBox("nombre",nombre,false,false,false,20)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
			</tr>
			</table>
<!-- ================   S E A R C H   E N G I N E S   E N D   H E R E   =================== -->
		</td>
	</tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList('<%=cod%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Lista ]</a> </authtype></td>
  </tr>
 <tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="6%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="39%">Total Registro(s) <%=rowCount%></td>
				<td width="35%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%> </td>
		<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ===========   R E S U L T S   S T A R T   H E R E   ============== -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tbody id="list">
		<tr class="TextHeader">
			<td width="10%">Cód. Acreedor</td>
			<td width="30%" align="left">Nombre del Acreedor</td>
			<td width="30%" align="left">Fecha de Pago</td>
			<td width="10%" align="center">Monto</td>
			<td width="10%" align="center"># Cheque</td>
			<td width="10%" align="center">Acci&oacute;n</td>
		</tr>
<%
String nombrePla = "";
double total=0.00;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
		 if (!nombrePla.equalsIgnoreCase(cdo.getColValue("nombre")))
				 {
				%>
				  
		 <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
          <td colspan="6" class="TitulosdeTablas"> [<%=cdo.getColValue("codPlanilla")%>] - [<%=cdo.getColValue("numPlanilla")%>] - <%=cdo.getColValue("descripcion")%></td>
     </tr>
				<%
				   }
				%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="left"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nomEmpleado")%></td>
			<td><%=cdo.getColValue("fechaPago")%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
			<td align="center"><%=cdo.getColValue("cheque")%></td>
			<td align="center"> <authtype type='1'>Ver&nbsp; 				
			<img src="../images/dwn.gif" onClick="javascript:showPopWin('../rhplanilla/pago_planilla_acreedor.jsp?acrId=<%=cdo.getColValue("codigo")%>&cod=<%=cdo.getColValue("codPlanilla")%>&num=<%=cdo.getColValue("numPlanilla")%>&anio=<%=cdo.getColValue("anio")%>&id=<%=i%>&total=<%=cdo.getColValue("monto")%>',winWidth*.95,_contentHeight*.85,null,null,'')" style="cursor:pointer"> </authtype>
		 
		</td>
		</tr>
<% total += Double.parseDouble(cdo.getColValue("monto"));
	nombrePla = cdo.getColValue("nombre");
}
%>
 </tbody>
		</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
 <tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextHeader01')">
				<td width="70%" align="right">&nbsp;Total</td>
				<td width="10%"align="center"><%=CmnMgr.getFormattedDecimal(total)%></td>
				<td width="10%"align="center">&nbsp;</td>
				<td width="10%"align="center">&nbsp;</td>
			</tr>
 		</table>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="35%">Total Registro(s) <%=rowCount%></td>
				<td width="35%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
			<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
			<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
			<%=fb.hidden("searchOn",searchOn)%>
			<%=fb.hidden("searchVal",searchVal)%>
			<%=fb.hidden("searchValFromDate",searchValFromDate)%>
			<%=fb.hidden("searchValToDate",searchValToDate)%>
			<%=fb.hidden("searchType",searchType)%>
			<%=fb.hidden("searchDisp",searchDisp)%>
			<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
 </body>
	</html>
<%
}//POST
%>
