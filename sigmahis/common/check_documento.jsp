<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector" />
<%
/*
==================================================================================
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500013") || SecMgr.checkAccess(session.getId(),"500014") || SecMgr.checkAccess(session.getId(),"500015") || SecMgr.checkAccess(session.getId(),"500016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
int camaLastLineNo = 0;
int diagLastLineNo = 0;
int docLastLineNo = 0;
int benLastLineNo = 0;
int respLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
if (request.getParameter("respLastLineNo") != null) respLastLineNo = Integer.parseInt(request.getParameter("respLastLineNo"));

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

	if (fp.equalsIgnoreCase("admision")||fp.equalsIgnoreCase("admision_new"))
	{
		sql = "select codigo, nombre, area_revision as area from tbl_adm_documento where area_revision IN ('AD','AM') "+appendFilter+" order by nombre";
		al = SQLMgr.getDataList(sql);
		rowCount = CmnMgr.getCount("select count(*) from tbl_adm_documento where area_revision IN ('AD','AM') "+appendFilter);
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
document.title = 'Documentos - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE DOCUMENTOS"></jsp:param>
</jsp:include>
	
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
			<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">		
		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
				<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,5)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
				<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<td width="50%">
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>		

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("cds",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
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
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="35%"><cellbytelabel>&Aacute;rea de Revisi&oacute;n</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas los documentos listados!")%></td>
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
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=cdo.getColValue("area")%></td>
					<td align="center"><%=(vDoc.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%></td>
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
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
	if (fp.equalsIgnoreCase("admision_new"))docLastLineNo=iDoc.size();
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			Admision obj = new Admision();
System.out.println("********"+request.getParameter("codigo"+i));
			obj.setDocumento(request.getParameter("codigo"+i));
			obj.setDocumentoDesc(request.getParameter("nombre"+i));
			obj.setRevisadoAdmision("");
			docLastLineNo++;

			String key = "";
			if (docLastLineNo < 10) key = "00"+docLastLineNo;
			else if (docLastLineNo < 100) key = "0"+docLastLineNo;
			else key = ""+docLastLineNo;
			obj.setKey(key);
	
			try
			{
				iDoc.put(key, obj);
				vDoc.add(obj.getDocumento());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("admision"))
	{
%>
	window.opener.location = '../admision/admision_config.jsp?change=1&tab=3&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>';
<%
	} else if (fp.equalsIgnoreCase("admision_new"))
	{
%>
	window.opener.location = '../admision/admision_config_docto.jsp?change=1&tab=3&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&loadInfo=S';
<%
	}
%>
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