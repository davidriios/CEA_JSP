<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.ClasificacionPlan"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iClasif" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vClasif" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"400013") || SecMgr.checkAccess(session.getId(),"400014") || SecMgr.checkAccess(session.getId(),"400015") || SecMgr.checkAccess(session.getId(),"400016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String fp = request.getParameter("fp");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
int planLastLineNo = 0;
int clasifLastLineNo = 0;
String categoria = request.getParameter("categoria");
String tipo = request.getParameter("tipo");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("planLastLineNo") != null) planLastLineNo = Integer.parseInt(request.getParameter("planLastLineNo"));
if (tipoPoliza == null && tipoPlan == null && planNo == null) throw new Exception("El Plan del Convenio no es válido. Por favor intente nuevamente!");
if (request.getParameter("planLastLineNo") != null) planLastLineNo = Integer.parseInt(request.getParameter("planLastLineNo"));
if (request.getParameter("clasifLastLineNo") != null) clasifLastLineNo = Integer.parseInt(request.getParameter("clasifLastLineNo"));
if (categoria == null) categoria = "";
if (tipo == null) tipo = "";
if (!categoria.equals(""))
{
	appendFilter = " and a.categoria="+categoria;

	if (!tipo.equals("")) appendFilter += " and a.tipo="+tipo;
}

if(request.getMethod().equalsIgnoreCase("GET"))
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

  if (fp.equalsIgnoreCase("convenio") || fp.equalsIgnoreCase("pm_convenio"))
  {
 	sql = "select a.categoria, a.tipo, a.codigo, a.descripcion, b.descripcion as catName, c.descripcion as tipoName from tbl_adm_clasif_x_tipo_adm a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_cia c where a.categoria=b.codigo and a.categoria=c.categoria and a.tipo=c.codigo"+appendFilter+" order by b.descripcion, c.descripcion, a.descripcion";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_adm_clasif_x_tipo_adm a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_cia c where a.categoria=b.codigo and a.categoria=c.categoria and a.tipo=c.codigo"+appendFilter+"");
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
document.title = 'Clasificación de Admisión - '+document.title;

function getMain(formx)
{
	formx.categoria.value = document.search00.categoria.value;
	formx.tipo.value = document.search00.tipo.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CLASIFICACION DE ADMISION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>	
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("secuencia",secuencia)%>
					<%=fb.hidden("tipoPoliza",tipoPoliza)%>
					<%=fb.hidden("tipoPlan",tipoPlan)%>
					<%=fb.hidden("planNo",planNo)%>
					<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
					<%=fb.hidden("clasifLastLineNo",""+clasifLastLineNo)%>
					<td colspan="2">
					<cellbytelabel>Categor&iacute;a</cellbytelabel>			            
					<%=fb.select(ConMgr.getConnection(), "Select codigo, descripcion From tbl_adm_categoria_admision order by descripcion","categoria",categoria,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemTipo.xml','tipo','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"",null,"T")%>
					<cellbytelabel>Tipo</cellbytelabel>
					<%=fb.select("tipo","","")%>
					<script language="javascript">
					loadXML('../xml/itemTipo.xml','tipo','<%=tipo%>','VALUE_COL','LABEL_COL','<%=categoria%>','KEY_COL','T');
					</script>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
				
        <tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>	
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("secuencia",secuencia)%>
					<%=fb.hidden("tipoPoliza",tipoPoliza)%>
					<%=fb.hidden("tipoPlan",tipoPlan)%>
					<%=fb.hidden("planNo",planNo)%>
					<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
					<%=fb.hidden("clasifLastLineNo",""+clasifLastLineNo)%>
					<%=fb.hidden("categoria","").replaceAll(" id=\"categoria\"","")%>
					<%=fb.hidden("tipo","").replaceAll(" id=\"tipo\"","")%>
		      <td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>	

<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("secuencia",secuencia)%>
					<%=fb.hidden("tipoPoliza",tipoPoliza)%>
					<%=fb.hidden("tipoPlan",tipoPlan)%>
					<%=fb.hidden("planNo",planNo)%>
					<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
					<%=fb.hidden("clasifLastLineNo",""+clasifLastLineNo)%>
					<%=fb.hidden("categoria","").replaceAll(" id=\"categoria\"","")%>
					<%=fb.hidden("tipo","").replaceAll(" id=\"tipo\"","")%>
					<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
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
fb = new FormBean("planPoliza",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("clasifLastLineNo",""+clasifLastLineNo)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("tipo",tipo)%>
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
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas las empresas listadas!")%></td>
				</tr>
<%
String cDesc = "";
String tDesc = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	
	if (i % 2 == 0) color = "TextRow01";
	
	if (!cDesc.equalsIgnoreCase(cdo.getColValue("catName")))
	{
		tDesc = "";
%>
				<tr class="TextHeader01">
					<td colspan="4"><cellbytelabel>CATEGORIA DE ADMISION</cellbytelabel>: [<%=cdo.getColValue("categoria")%>] <%=cdo.getColValue("catName")%></td>
				</tr>
<%
	}
	if (!tDesc.equalsIgnoreCase(cdo.getColValue("tipoName")))
	{
%>
				<tr class="TextHeader02">
					<td colspan="4">&nbsp;&nbsp;&nbsp;<cellbytelabel>TIPO DE ADMISION</cellbytelabel>: [<%=cdo.getColValue("tipo")%>] <%=cdo.getColValue("tipoName")%></td>
				</tr>
<%
	}
%>
				<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
				<%=fb.hidden("categoriaDesc"+i,cdo.getColValue("catName"))%>
				<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
				<%=fb.hidden("tipoDesc"+i,cdo.getColValue("tipoName"))%>
				<%=fb.hidden("clasificacion"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("clasificacionDesc"+i,cdo.getColValue("descripcion"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=(vClasif.contains(cdo.getColValue("categoria")+"-"+cdo.getColValue("tipo")+"-"+cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("categoria")+"-"+cdo.getColValue("tipo")+"-"+cdo.getColValue("codigo"),false,false)%></td>
				</tr>
<%
	cDesc = cdo.getColValue("catName");
	tDesc = cdo.getColValue("tipoName");
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
			ClasificacionPlan cp = new ClasificacionPlan();

			cp.setCategoriaAdmi(request.getParameter("categoria"+i));
			cp.setCategoriaAdmiDesc(request.getParameter("categoriaDesc"+i));
			cp.setTipoAdmi(request.getParameter("tipo"+i));
			cp.setTipoAdmiDesc(request.getParameter("tipoDesc"+i));
			cp.setClasifAdmi(request.getParameter("clasificacion"+i));
			cp.setClasifAdmiDesc(request.getParameter("clasificacionDesc"+i));
			cp.setEstado("A");
			clasifLastLineNo++;

			String key = "";
			if (clasifLastLineNo < 10) key = "00"+clasifLastLineNo;
			else if (clasifLastLineNo < 100) key = "0"+clasifLastLineNo;
			else key = ""+clasifLastLineNo;
			cp.setKey(key);
	
			try
			{
				iClasif.put(cp.getKey(), cp);
				vClasif.add(cp.getCategoriaAdmi()+"-"+cp.getTipoAdmi()+"-"+cp.getClasifAdmi());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&planLastLineNo="+planLastLineNo+"&clasifLastLineNo="+clasifLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&planLastLineNo="+planLastLineNo+"&clasifLastLineNo="+clasifLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	if (fp.equalsIgnoreCase("convenio"))
	{
%>
	window.opener.location = '../convenio/convenio_plan.jsp?change=1&tab=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&planLastLineNo=<%=planLastLineNo%>&clasifLastLineNo=<%=clasifLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio"))
	{
%>	
	window.opener.location = '../planmedico/pm_convenio_plan.jsp?change=1&tab=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&planLastLineNo=<%=planLastLineNo%>&clasifLastLineNo=<%=clasifLastLineNo%>';
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