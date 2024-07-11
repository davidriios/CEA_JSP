<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.contabilidad.DetalleClasificacion" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<jsp:useBean id="ITEMS_KEY" scope="session" class="java.util.Vector" />
<jsp:useBean id="ITEMS" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo2" scope="page" class="issi.admin.CommonDataObject" />

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
String indexCod_campos = request.getParameter("indexCod_campos");
String indexDescripcion = request.getParameter("indexDescripcion");
String key = "";
String change = "";
String id = request.getParameter("id");
int lastLineNo = 0;

if(request.getParameter("lastLineNo")!=null){ lastLineNo=Integer.parseInt(request.getParameter("lastLineNo")); }


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
  String codigo = "", descripcion ="";
  if (request.getParameter("secuencia_campos") != null && !request.getParameter("secuencia_campos").trim().equals(""))
  {
    appendFilter += " and upper(secuencia_campos) like '"+request.getParameter("secuencia_campos").toUpperCase()+"%'";
    codigo = request.getParameter("secuencia_campos");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  { 
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  
  sql = "SELECT secuencia_campos, descripcion FROM tbl_con_lista_campos where estado ='A'  "+appendFilter+" order by descripcion";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+") ");

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
document.title = 'Hacienda Agregar - '+document.title;
function enviar(Cod_campos, descripcion, indexCod_campos, indexDescripcion)
{
  eval('window.opener.document.form1.'+indexCod_campos).value = Cod_campos;
  eval('window.opener.document.form1.'+indexDescripcion).value = descripcion;
  /*
  window.opener.document.form1.tipoHabCode[index].value = code;
  window.opener.document.form1.tipoHab.value = name;
  window.opener.document.form1.catHab.value = catHab;
  window.opener.document.form1.index.value = index;
  */
  window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - ACTIVO FIJO - MANTENIMIENTO - CLASIF. DE ACTIVOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">    
<tr>
<td>
<table width="100%" cellpadding="0" cellspacing="0">


<tr class="TextFilter">	                    
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td width="50%">C&oacute;digo					
					<%=fb.textBox("secuencia_campos",codigo,false,false,false,40)%>
					</td>							
				    <td width="50%">Descripci&oacute;n
					<%=fb.textBox("descripcion",descripcion,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>				   	
					</tr>
<%=fb.formEnd()%>	
</table>
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
					<%=fb.hidden("secuencia_campos",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
					<%=fb.hidden("id",id)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<% fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp"); %>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("secuencia_campos",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>					
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
					<%=fb.hidden("id",id)%>
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

<% fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
<%=fb.formStart(true)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>

	
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td colspan="4" align="right">
<%=fb.submit("save","Guardar",true,false,null,null,"")%>
<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
</td>
</tr>
<tr class="TextHeader" align="center">
<td width="5%">&nbsp;</td>
<td width="25%">C&oacute;digo</td>
<td width="60%">Descripci&oacute;n</td>
<td width="10%">&nbsp;</td>	
</tr>				
<!-- ======================================== I N I C I O ================================================== -->
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("code"+i,cdo.getColValue("secuencia_campos"))%>
<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>

<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
<td align="right"><%=preVal + i%>&nbsp;</td>
<td><%=cdo.getColValue("secuencia_campos")%>
</td>
<td>
<%=cdo.getColValue("descripcion")%>
</td>
<td align="center"><%=(ITEMS_KEY.contains(cdo.getColValue("secuencia_campos")))?"elegido":fb.checkbox("check"+i,""+cdo.getColValue("secuencia_campos"),false,false)%></td>
</tr>
<% } %>
<!-- ============================================ F I N ====================================================== -->
<tr>
<td colspan="4" align="right">
<%=fb.submit("save","Guardar",true,false,null,null,"")%>
<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
</td>
</tr>
</table>
<%=fb.hidden("maximo",""+al.size())%>
<%=fb.formEnd(true)%>
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
					<%=fb.hidden("secuencia_campos",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
					<%=fb.hidden("id",id)%>
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
					<%=fb.hidden("secuencia_campos",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
					<%=fb.hidden("id",id)%>
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
} //GET
else {

int maximo = Integer.parseInt(request.getParameter("maximo"));


for (int i=0; i<maximo; i++){ 
		
		if(request.getParameter("check"+i)!=null)
		{
			DetalleClasificacion det = new DetalleClasificacion(); 
			//cdo.addColValue("cod_campos",""+request.getParameter("check"+i));
			//cdo.addColValue("descripcion",""+request.getParameter("descripcion"+i));
			det.setStatus("A");//add
			det.setId(request.getParameter("code"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			++lastLineNo;
				if (lastLineNo < 10) key = "00" + lastLineNo;
				else if (lastLineNo < 100) key = "0" + lastLineNo;
				else key = "" + lastLineNo;		
			 ITEMS.put(key, det); 
			 ITEMS_KEY.addElement(request.getParameter("code"+i));
		 } 
}



%>

<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/hacienda_campo.jsp?change=1&lastLineNo=<%=lastLineNo%>&id=<%=id%>';
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

