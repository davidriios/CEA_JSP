<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "", appendFilter1 = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String secuencia = request.getParameter("secuencia");
String cod_pac = request.getParameter("cod_pac");
String fec_nacimiento = request.getParameter("fec_nacimiento");
String pac_id = request.getParameter("pac_id");
String seccion = request.getParameter("seccion");
String fecha = request.getParameter("fecha");
String tab = request.getParameter("tab");
String bal = request.getParameter("bal");
int LAdminLastLineNo = 0;
int LElimLastLineNo = 0;
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("LAdminLastLineNo") != null) LAdminLastLineNo = Integer.parseInt(request.getParameter("LAdminLastLineNo"));
if (request.getParameter("LElimLastLineNo") != null) LElimLastLineNo = Integer.parseInt(request.getParameter("LElimLastLineNo"));

if (request.getParameter("mode") == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{  appendFilter = ""; appendFilter1 = ""; 
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  
	if (request.getParameter("searchQuery")!= null)
  {  appendFilter = ""; 
    nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		//System.out.println("nextval...ahora con N..."+nextVal);
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
	if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
	if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
String code="",descripcion="";
  if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
  {  
  	appendFilter += " and  upper(CODIGO)  like '%"+request.getParameter("code").toUpperCase()+"%' ";
    code = request.getParameter("code");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {  
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%' ";
    descripcion = request.getParameter("descripcion");
  }
  
 if (fp.equalsIgnoreCase("balHidrico"))
	{
 if(tab.equalsIgnoreCase("0"))
   appendFilter += " and TIPO_LIQUIDO = 'I' ";
 else appendFilter += " and TIPO_LIQUIDO = 'E' ";
 
	sql="SELECT codigo , descripcion , tipo_liquido as tipo from tbl_sal_via_admin WHERE status='A' "+appendFilter+"  order by descripcion asc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
}
  
	
  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";
  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  if (nxtVal<=rowCount)
	{ nVal=nxtVal;
	}
  else nVal=rowCount;
  
  if(rowCount==0) pVal=0;
  else pVal=preVal;
		
//--------------------------------------------------

%>
<html>
<head>

<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Líquidos Administrados - '+document.title;
function setTipo(k)
{ 
	<%
	if (fp.equalsIgnoreCase("balHidrico"))//referencia balance hidrico--paciente
	{
	if(tab.equalsIgnoreCase("0"))
	{
%>
  eval('window.opener.document.form0.idAdmin'+<%=bal%>).value = eval('document.form0.codigo'+k).value;
	eval('window.opener.document.form0.descripcion'+<%=bal%>).value = eval('document.form0.descripcionVia'+k).value;
<%
	}
	else
	{
	%>
		 eval('window.opener.document.form1.idAdminE'+<%=bal%>).value = eval('document.form0.codigo'+k).value;
		 eval('window.opener.document.form1.descripcion'+<%=bal%>).value = eval('document.form0.descripcionVia'+k).value;
	<%	
	}
}
%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="SELECCION - LIQUIDOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("mode",""+mode)%>
			<%=fb.hidden("size",""+al.size())%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		  <%=fb.hidden("secuencia",secuencia)%>
		  <%=fb.hidden("cod_pac",cod_pac)%>
		  <%=fb.hidden("fec_nacimiento",fec_nacimiento)%>
			<%=fb.hidden("fecha",fecha)%>
		  <%=fb.hidden("pac_id",pac_id)%>
		  <%=fb.hidden("seccion",seccion)%>	
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("LAdminLastLineNo",""+LAdminLastLineNo)%>
			<%=fb.hidden("LElimLastLineNo",""+LElimLastLineNo)%>
			<%=fb.hidden("tab",tab)%>
		<td width="50%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel>
			<%=fb.textBox("code","",false,false,false,30,null,null,null)%>
			</td>
		<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>	
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>
<!--------------------------------------------------------  --->
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	  <tr>
  			  <td align="right">&nbsp;</td>
 	 </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("LAdminLastLineNo",""+LAdminLastLineNo)%>
<%=fb.hidden("LElimLastLineNo",""+LElimLastLineNo)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("fec_nacimiento",fec_nacimiento)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("seccion",seccion)%>	
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("code",code)%>	
<%=fb.hidden("descripcion",""+descripcion)%>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%//=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>	

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">




	<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
							<td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
							<td width="20%"><cellbytelabel id="6">tipo</cellbytelabel></td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcionVia"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setTipo(<%=i%>)" style="cursor:pointer">
		    <td><%=cdo.getColValue("codigo")%></td>
				<td><%=cdo.getColValue("descripcion")%></td>
				<td><%=cdo.getColValue("tipo")%></td>
				
		</tr>
<%
}
%>				
</table>
		</td>
	</tr>		
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1 )?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount<=nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%//=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//get 

%>