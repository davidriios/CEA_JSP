<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" buffer="16kb" autoFlush="true"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="vctcurso" scope="session" class="java.util.Vector" />
<jsp:useBean id="htcurso" scope="session" class="java.util.Hashtable"/>
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
int cursoLastLineNo = 0;
int expLastLineNo = 0;
int educaLastLineNo = 0;

if (request.getParameter("cursoLastLineNo") != null) cursoLastLineNo = Integer.parseInt(request.getParameter("cursoLastLineNo"));
if (request.getParameter("expLastLineNo") != null) expLastLineNo = Integer.parseInt(request.getParameter("expLastLineNo"));
if (request.getParameter("educaLastLineNo") != null) educaLastLineNo = Integer.parseInt(request.getParameter("educaLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";


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

  if (request.getParameter("codigo") != null)
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
	
  else if (request.getParameter("nombre") != null)
  {
    appendFilter += " and upper(nombre) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "nombre";
    searchVal = request.getParameter("nombre");
    searchType = "1";
    searchDisp = "Nombre";
  }
	
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	sql="select compania, codigo, nombre, area from tbl_pla_curso_di where compania="+(String) session.getAttribute("_companyId")+appendFilter+"order by nombre";
	al = SQLMgr.getDataList(sql);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_curso_di where compania="+(String) session.getAttribute("_companyId")+appendFilter);
	
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
document.title = 'Lista de Cursos a Dictar - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<%--<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>--%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - MANTENIMIENTO - LISTA DE CURSOS A DICTAR"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">		
<%
 fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>	
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("sig",sig)%>
				<%=fb.hidden("tom",tom)%>
				<%=fb.hidden("asi",asi)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
				<%=fb.hidden("expLastLineNo",""+expLastLineNo)%>
				<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				<td width="50%">&nbsp;C&oacute;digo
							<%=fb.textBox("codigo","",false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%></td>
				<%=fb.formEnd()%>	
				
<%
 fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("sig",sig)%>
				<%=fb.hidden("tom",tom)%>
				<%=fb.hidden("asi",asi)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
				<%=fb.hidden("expLastLineNo",""+expLastLineNo)%>
				<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				<td width="50%">&nbsp;Descripci&oacute;n
							<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%>	</td>
				<%=fb.formEnd()%>	
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
	fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("sig",sig)%>
<%=fb.hidden("tom",tom)%>
<%=fb.hidden("asi",asi)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
<%=fb.hidden("expLastLineNo",""+expLastLineNo)%>
<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
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
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
			</tr>
		</table>
	</td>
</tr>			

		

	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader">
				<td width="10%">&nbsp;</td>
				<td width="10%">&nbsp;C&oacute;digo</td>
				<td width="40%">&nbsp;Nombre</td>	
				<td width="30%">&nbsp;&Aacute;rea</td>
				<td width="10%">&nbsp;</td>
			</tr>
			<%
			for (int i=0; i<al.size(); i++)
			{
			 CommonDataObject cdo = (CommonDataObject) al.get(i);
			 String color = "TextRow02";
			 if (i % 2 == 0) color = "TextRow01";
			%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
			<%=fb.hidden("area"+i,cdo.getColValue("area"))%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td align="right"><%=preVal + i%>&nbsp;</td>
				<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
				<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
				<td>&nbsp;<%=cdo.getColValue("area")%></td>
				<td align="center"><%=(vctcurso.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%></td>
			</tr>
			<%
			}
			%>	
								
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->		
			</table>	
		</td>
	</tr>
	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
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
} 
else
{
 int size = Integer.parseInt(request.getParameter("size"));
 for (int i=0; i<size; i++)
 {
 	 if(request.getParameter("check"+i) != null)
	 {
	 CommonDataObject cdo = new CommonDataObject();

	cdo.addColValue("curso",request.getParameter("codigo"+i));
	cdo.addColValue("namecurso",request.getParameter("nombre"+i));
	//cdo.addColValue("codearea",request.getParameter("area"+i));
	cursoLastLineNo++;
	
	String key="";
	
	if(cursoLastLineNo<10)
	key="00"+cursoLastLineNo;
	else if(cursoLastLineNo<100)
	key="0"+cursoLastLineNo;
	else key=""+cursoLastLineNo;
	cdo.addColValue("key",key);
	try 
	{
	htcurso.put(key,cdo);
	vctcurso.add(cdo.getColValue("curso"));
	}//end Try
	catch(Exception e)
	{
		System.err.println(e.getMessage());
	}
	 }//End check
 }//End For
 
 if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&cursoLastLineNo="+cursoLastLineNo+"&expLastLineNo="+expLastLineNo+"&educaLastLineNo="+educaLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&cursoLastLineNo="+cursoLastLineNo+"&expLastLineNo="+expLastLineNo+"&educaLastLineNo="+educaLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.opener.location = '../rhplanilla/instructores_config.jsp?change=1&tab=1&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&cursoLastLineNo=<%=cursoLastLineNo%>&expLastLineNo=<%=expLastLineNo%>&educaLastLineNo=<%=educaLastLineNo%>';
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>