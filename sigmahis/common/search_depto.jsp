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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String grupo = "";
String fg = request.getParameter("fg");
if (fg == null)fg="";
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("grupo")!= null && !request.getParameter("grupo").equalsIgnoreCase(""))
{
    grupo = request.getParameter("grupo");
}

if (request.getMethod().equalsIgnoreCase("GET"))
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
  
  String codigo="",descripcion="";
  if (request.getParameter("codigo") != null &&!request.getParameter("codigo").trim().equals(""))
  {
	 	if(fp.equalsIgnoreCase("fisica"))appendFilter += " and upper(codigo_ubic) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		else if(fp.equalsIgnoreCase("entrada"))appendFilter += " and upper(codigo_entrada) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		else appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	 	codigo=request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }

	if (fp.equalsIgnoreCase("unidad"))
	{
		if(!fg.equalsIgnoreCase("DEPTO")&&!fg.equalsIgnoreCase("DIR")) appendFilter +=" and nivel=2 ";
		else if(fg.equalsIgnoreCase("DIR")) appendFilter +=" and nivel=1 ";
		else appendFilter +=" and nivel<3 ";
		sql = "select codigo, descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and estado = 'A' order by descripcion";
		
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) from tbl_sec_unidad_ejec where compania ="+(String) session.getAttribute("_companyId")+appendFilter+" ");
	}	
	
	if (fp.equalsIgnoreCase("seccion"))
	{
		sql = "select codigo, descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and nivel in(2,3) and estado = 'A' order by descripcion";
		
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) from tbl_sec_unidad_ejec where compania ="+(String) session.getAttribute("_companyId")+appendFilter+" and nivel = 3");
	}	
	
	if (fp.equalsIgnoreCase("activo"))
	{
		sql = "select codigo, descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and estado = 'A' order by descripcion";
		
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) from ("+sql+")");
	}	

	if (fp.equalsIgnoreCase("estado"))
	{
		sql = "select codigo, descripcion from tbl_pla_estado_emp where codigo <> '0' "+appendFilter+" order by descripcion";
		
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) from tbl_pla_estado_emp where  codigo <>'0' "+appendFilter);
	}	
	if (fp.equalsIgnoreCase("fisica"))
	{
		sql = "select codigo_ubic codigo, descripcion from tbl_con_ubic_fisica where codigo_ubic <> '0' and compania = "+(String)session.getAttribute("_companyId")+appendFilter+" order by descripcion";
		
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) from tbl_con_ubic_fisica where codigo_ubic <>'0' and compania = "+(String)session.getAttribute("_companyId")+appendFilter);
	}	
	
	if (fp.equalsIgnoreCase("entrada"))
	{
		sql = "select codigo_entrada codigo, descripcion from tbl_con_tipo_entrada where codigo_entrada <> '0' "+appendFilter+" order by codigo_entrada";
		
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) from tbl_con_tipo_entrada where codigo_entrada <>'0' "+appendFilter);
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
document.title = 'Departamentos - '+document.title;

function setArea(i)
{
<%
	if (fp.equalsIgnoreCase("unidad") )
	{
%>
		window.opener.document.formUnidad.depto.value = eval('document.formDepto.codigo'+i).value;
		window.opener.document.formUnidad.deptoDesc.value = eval('document.formDepto.descripcion'+i).value;
<%
    } else if(fp.equalsIgnoreCase("seccion"))
		{
%>		
		window.opener.document.formUnidad.sec.value = eval('document.formDepto.codigo'+i).value;
		window.opener.document.formUnidad.secDesc.value = eval('document.formDepto.descripcion'+i).value;
<%
    } else if(fp.equalsIgnoreCase("seccion"))
		{
%>		
		window.opener.document.formUnidad.sec.value = eval('document.formDepto.codigo'+i).value;
		window.opener.document.formUnidad.secDesc.value = eval('document.formDepto.descripcion'+i).value;
<%
    } else if(fp.equalsIgnoreCase("estado"))
		{
%>		
		window.opener.document.formUnidad.estados.value = eval('document.formDepto.codigo'+i).value;
		window.opener.document.formUnidad.estadoDesc.value = eval('document.formDepto.descripcion'+i).value;
<%
    }  else if(fp.equalsIgnoreCase("activo"))
		{
%>		
		if(window.opener.document.form1.ue_codigo)window.opener.document.form1.ue_codigo.value = eval('document.formDepto.codigo'+i).value;
		else if(window.opener.document.form0.ue_codigo)window.opener.document.form0.ue_codigo.value = eval('document.formDepto.codigo'+i).value;
		if(window.opener.document.form1.unidad_desc)window.opener.document.form1.unidad_desc.value = eval('document.formDepto.descripcion'+i).value;
		else if(window.opener.document.form0.unidad_desc)window.opener.document.form0.unidad_desc.value = eval('document.formDepto.descripcion'+i).value;
<%
    }  else if(fp.equalsIgnoreCase("fisica"))
		{
%>		
		if(window.opener.document.form1.nivel_codigo_ubic)window.opener.document.form1.nivel_codigo_ubic.value = eval('document.formDepto.codigo'+i).value;
		else if(window.opener.document.form0.nivel_codigo_ubic)window.opener.document.form0.nivel_codigo_ubic.value = eval('document.formDepto.codigo'+i).value;
		if(window.opener.document.form1.nivel_codigo_ubic)window.opener.document.form1.ubicacion_desc.value = eval('document.formDepto.descripcion'+i).value;
		else if(window.opener.document.form0.nivel_codigo_ubic)window.opener.document.form0.ubicacion_desc.value = eval('document.formDepto.descripcion'+i).value;
<%
    }  else if(fp.equalsIgnoreCase("entrada"))
		{
%>		
		if(window.opener.document.form1.entrada_codigo)window.opener.document.form1.entrada_codigo.value = eval('document.formDepto.codigo'+i).value;
		else if(window.opener.document.form0.entrada_codigo)window.opener.document.form0.entrada_codigo.value = eval('document.formDepto.codigo'+i).value;
		if(window.opener.document.form1.entrada_desc)window.opener.document.form1.entrada_desc.value = eval('document.formDepto.descripcion'+i).value;
		else if(window.opener.document.form0.entrada_desc)window.opener.document.form0.entrada_desc.value = eval('document.formDepto.descripcion'+i).value;
<%
    } 
%>		

		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE AREAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">		
					<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("fg",fg)%>
					<td width="50%">C&oacute;digo					
					<%=fb.textBox("codigo","",false,false,false,40)%>
					</td>
					<td width="50%"><cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>	
				
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("fg",fg)%>
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

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="80%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				</tr>
				<%
				fb = new FormBean("formDepto",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setArea(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
				</tr>
				<%
				}
				%>							
				<%=fb.formEnd()%>						
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("fg",fg)%>
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
	
