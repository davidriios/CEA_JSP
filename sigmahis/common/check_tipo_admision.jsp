<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTAdm" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTAdm" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500005") || SecMgr.checkAccess(session.getId(),"500006") || SecMgr.checkAccess(session.getId(),"500007") || SecMgr.checkAccess(session.getId(),"500008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);


CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String catCode = request.getParameter("catCode");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int tServLastLineNo = 0;
int userLastLineNo = 0;
int tAdmLastLineNo = 0;
int pamLastLineNo = 0;
int procLastLineNo = 0;
int docLastLineNo = 0;

if (catCode == null) catCode = "";
if (!catCode.equals("")) appendFilter = " and a.categoria="+catCode;
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("tServLastLineNo") != null) tServLastLineNo = Integer.parseInt(request.getParameter("tServLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));
if (request.getParameter("tAdmLastLineNo") != null) tAdmLastLineNo = Integer.parseInt(request.getParameter("tAdmLastLineNo"));
if (request.getParameter("pamLastLineNo") != null) pamLastLineNo = Integer.parseInt(request.getParameter("pamLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));

if (request.getParameter("mode") == null) mode = "add";

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
    appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "a.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "a.descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
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

	if (fp.equalsIgnoreCase("cds_references"))
	{
		sql = "select a.categoria, a.codigo as tipoAdmision, a.descripcion as tipoAdmisionDesc, b.descripcion as categoriaDesc from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b where a.categoria=b.codigo and a.compania="+((String) session.getAttribute("_companyId"))+appendFilter+" order by b.descripcion, a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b where a.categoria=b.codigo and a.compania="+((String) session.getAttribute("_companyId"))+appendFilter+"");
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
document.title = 'Tipo de Admisión - '+document.title;

function getMain(formx)
{
	formx.catCode.value = document.search00.catCode.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE TIPO DE ADMISION"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">
<%
fb = new FormBean("search00",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
					<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
					<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
					<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
					<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
					<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
					<td colspan="2">
					<cellbytelabel>Categor&iacute;a</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_adm_categoria_admision order by descripcion","catCode",catCode,"T")%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>		
				</tr>

				<tr class="TextFilter">		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath(),fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("catCode","").replaceAll(" id=\"catCode\"","")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
					<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
					<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
					<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
					<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
					<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
					<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,40,null,null,null)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>		

<%
fb = new FormBean("search02",request.getContextPath()+request.getServletPath(),fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("catCode","").replaceAll(" id=\"catCode\"","")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
					<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
					<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
					<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
					<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
					<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
					<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40,null,null,null)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>		
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>
	
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("tipoAdmision",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("id",id)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("catCode",catCode).replaceAll(" id=\"catCode\"","")%>
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

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="30%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los tipos de admisiones listados!")%></td>
				</tr>
<%
String categoria = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
				<%=fb.hidden("categoriaDesc"+i,cdo.getColValue("categoriaDesc"))%>
				<%=fb.hidden("tipoAdmision"+i,cdo.getColValue("tipoAdmision"))%>
				<%=fb.hidden("tipoAdmisionDesc"+i,cdo.getColValue("tipoAdmisionDesc"))%>
<%
	if (!categoria.equalsIgnoreCase(cdo.getColValue("categoria")))
	{
%>
				<tr class="TextHeader01">
					<td colspan="3">[<%=cdo.getColValue("categoria")%>] <%=cdo.getColValue("categoriaDesc")%></td>
				</tr>
<%
	}
%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("tipoAdmision")%></td>
					<td><%=cdo.getColValue("tipoAdmisionDesc")%></td>
					<td align="center"><%=(vTAdm.contains(cdo.getColValue("categoria")+"-"+cdo.getColValue("tipoAdmision")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("categoria")+"-"+cdo.getColValue("tipoAdmision"),false,false)%></td>
				</tr>
<%
	categoria = cdo.getColValue("categoria");
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
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("codCategoria",request.getParameter("categoria"+i));
			cdo.addColValue("categoriaDesc",request.getParameter("categoriaDesc"+i));
			cdo.addColValue("codTipo",request.getParameter("tipoAdmision"+i));
			cdo.addColValue("tipoAdmisionDesc",request.getParameter("tipoAdmisionDesc"+i));
			tAdmLastLineNo++;

			String key = "";
			if (tAdmLastLineNo < 10) key = "00"+tAdmLastLineNo;
			else if (tAdmLastLineNo < 100) key = "0"+tAdmLastLineNo;
			else key = ""+tAdmLastLineNo;
			cdo.addColValue("key",key);
	
			try
			{
				iTAdm.put(key, cdo);
				vTAdm.add(cdo.getColValue("codCategoria")+"-"+cdo.getColValue("codTipo"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	if (fp.equalsIgnoreCase("cds_references"))
	{
%>
	window.opener.location = '../admin/reg_cds_references.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>';
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