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

String cCompany = (String)session.getAttribute("_companyId");

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
  String codigo = "",descrip = "", status = "";
  if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
  {
    appendFilter += " and id = "+request.getParameter("code");
	codigo = request.getParameter("code");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%' or upper(nombre_corto) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip = request.getParameter("descripcion");
  }
  if (request.getParameter("status") != null && !request.getParameter("status").trim().equals(""))
  {
    appendFilter += " and status = '"+request.getParameter("status")+"'";
	status = request.getParameter("status");
  }
 
  if (request.getParameter("beginSearch") != null){
	sql = "SELECT id, nombre, nombre_corto, almacen, (select descripcion from tbl_inv_almacen where codigo_almacen = almacen and compania = company_id) as almacen_desc, archivo, qty_filas , status, decode(status,'A','Actualizado','I','Inactivo','P','Pendiente','R','Registrado','C','Cargado') as status_desc, to_char(fecha_creacion, 'yyyy') anio, anaquel,company_id compania, no_consecutivo consecutivo from tbl_inv_pdt_archivo where company_id = "+cCompany+appendFilter+" order by id desc ";
  
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
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
document.title = 'Inventario - Archivo PDT - '+document.title;
function add(){abrir_ventana('../inventario/cargar_archivo_pdt_config.jsp');}
function edit(id){abrir_ventana('../inventario/cargar_archivo_pdt_config.jsp?mode=edit&archivoId='+id);}
function printList(){abrir_ventana('../inventario/print_cargar_archivo_pdt_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
var xHeight=0;
function cargar(id, nombre){
	showPopWin('../common/run_process.jsp?fp=inventario&actType=1&docType=CONT_FISICO&docId='+id+'&docNo='+nombre+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');
}
function imprimir(id, consecutivo,company,almacen,anaquel,anio) {
 //abrir_ventana("../cellbyteWV/report_container.jsp?reportName=inventario/rpt_archivo_pdt.rptdesign&pArchivoId="+id+"&pCtrlHeader=false");
   abrir_ventana2('../inventario/print_diferencia_sistema.jsp?compania='+company+'&almacen='+almacen+'&anaquelx=&anaquely=&anio='+anio+'&consigna=N&consecutivo='+consecutivo+'&soloDif=S');
}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARCHIVO PDT"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Archivo PDT]</a></authtype></td>
	</tr>	
	<tr class="TextFilter">
	 <td>
	   <table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
			<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
			<td width="20%">C&oacute;digo&nbsp;<%=fb.textBox("code",codigo,false,false,false,10,null,null,null)%></td>
			<td width="80%">Nombre&nbsp;
				<%=fb.textBox("descripcion",descrip,false,false,false,30,null,null,null)%>
				&nbsp;&nbsp;Estado&nbsp;
				<%=fb.select("status","P=Pendiente,R=Registrado,A=Actualizado,I=Inactivo,C=Cargado",status,"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
		<%=fb.formEnd()%>	
		</tr>
	  </table>
     <td>
  	<tr>
		<td align="right">
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
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
				<%=fb.hidden("code",codigo)%>
				<%=fb.hidden("descripcion",descrip)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("code",codigo)%>
					<%=fb.hidden("descripcion",descrip)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
<tr>
  <td class="TableLeftBorder TableRightBorder" colspan="">
    <div id="_cMain" class="Container">
	  <div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader">
		<td width="5%" align="center">&nbsp;C&oacute;digo</td>
		<td width="30%">&nbsp;Nombre</td>
		<td width="15%">&nbsp;Nombre Corto</td>
		<td width="20%">&nbsp;Almac&eacute;n</td>
		<td width="10%">Archivo</td>
		<td width="5%" align="center">Qty Filas</td>
		<td width="7%" align="center">Estado</td>
		<td width="8%">&nbsp;</td>
	</tr>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre_corto")%></td>
					<td>&nbsp;<%=cdo.getColValue("almacen_desc")%></td>
					<td>&nbsp;<%=cdo.getColValue("archivo")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("qty_filas")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("status_desc")%></td>
					<td align="center">
					<%if(cdo.getColValue("status").equals("P") || cdo.getColValue("status").equals("R") || cdo.getColValue("status").equals("C")){%>
					<authtype type='4'>
					<a href="javascript:edit(<%=cdo.getColValue("id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>
					<%} else if(cdo.getColValue("status").equals("A") ) {%>
					<authtype type='2'>
					<a href="javascript:imprimir(<%=cdo.getColValue("id")%>,<%=cdo.getColValue("consecutivo")%>,<%=cdo.getColValue("compania")%>,<%=cdo.getColValue("almacen")%>,'<%=cdo.getColValue("anaquel")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a>
					<%}%>
					</authtype></td>
					
				</tr>
				<%
				}
				%>							
</table>	
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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