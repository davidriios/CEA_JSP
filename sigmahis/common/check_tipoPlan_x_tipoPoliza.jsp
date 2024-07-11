<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.PlanConvenio"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iPlan" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPlan" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"400009") || SecMgr.checkAccess(session.getId(),"400010") || SecMgr.checkAccess(session.getId(),"400011") || SecMgr.checkAccess(session.getId(),"400012"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
int planLastLineNo = 0;
String tipoPoliza = request.getParameter("tipoPoliza");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("planLastLineNo") != null) planLastLineNo = Integer.parseInt(request.getParameter("planLastLineNo"));
if (tipoPoliza == null) tipoPoliza = "";	
if (!tipoPoliza.equals("")) appendFilter = " and a.poliza="+tipoPoliza;

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

  if (request.getParameter("tipoPlan") != null)
  {
    appendFilter += " and upper(a.tipo_plan) like '%"+request.getParameter("tipoPlan").toUpperCase()+"%'";
    searchOn = "a.tipo_plan";
    searchVal = request.getParameter("tipoPlan");
    searchType = "1";
    searchDisp = "Tipo Plan";
  }
  else if (request.getParameter("nombre") != null)
  {
    appendFilter += " and upper(a.nombre) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "a.nombre";
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
  
	if (fp.equalsIgnoreCase("convenio") || fp.equalsIgnoreCase("pm_convenio"))
	{
		sql = "select a.tipo_plan as tipoPlan, a.poliza, a.nombre, a.comentario, b.nombre as nombrePoliza from tbl_adm_tipo_plan a, tbl_adm_tipo_poliza b where a.poliza=b.codigo"+appendFilter+" order by a.poliza, a.tipo_plan";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_adm_tipo_plan a, tbl_adm_tipo_poliza b where a.poliza=b.codigo"+appendFilter);
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
document.title = 'Tipo Plan por Poliza - '+document.title;

function getMain(formX)
{
	formX.tipoPoliza.value = document.search00.tipoPoliza.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCIONAR TIPO PLAN POR POLIZA"></jsp:param>
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
					<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
					<td colspan="2">
					<cellbytelabel>Tipo de P&oacute;liza</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo from tbl_adm_tipo_poliza order by nombre","tipoPoliza",tipoPoliza,"T")%>
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
					<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
					<%=fb.hidden("tipoPoliza","").replaceAll(" id=\"tipoPoliza\"","")%>
					<td width="50%">
					<cellbytelabel>Tipo Plan</cellbytelabel>
					<%=fb.textBox("tipoPlan","",false,false,false,5)%>
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
					<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
					<%=fb.hidden("tipoPoliza","").replaceAll(" id=\"tipoPoliza\"","")%>
					<td width="50%">
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre","",false,false,false,30)%>
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
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
	<tr>
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
					<td width="30%"><cellbytelabel>Tipo Plan</cellbytelabel></td>
					<td width="60%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="10%"><%//=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas las empresas listadas!")%></td>
				</tr>
<%
String poliza = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!poliza.equalsIgnoreCase(cdo.getColValue("poliza")))
	{
%>
				<tr class="TextHeader01">
					<td colspan="3"><cellbytelabel>TIPO POLIZA</cellbytelabel>: [<%=cdo.getColValue("poliza")%>] <%=cdo.getColValue("nombrePoliza")%></td>
				</tr>
<%
	}
%>
				<%=fb.hidden("tipoPoliza"+i,cdo.getColValue("poliza"))%>
				<%=fb.hidden("nombreTipoPoliza"+i,cdo.getColValue("nombrePoliza"))%>
				<%=fb.hidden("tipoPlan"+i,cdo.getColValue("tipoPlan"))%>
				<%=fb.hidden("nombreTipoPlan"+i,cdo.getColValue("nombre"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("tipoPlan")%></td>
					<td><%=cdo.getColValue("nombre")%></td>					
					<td align="center"><%=/*(vPlan.contains(cdo.getColValue("poliza")+"-"+cdo.getColValue("tipoPlan")))?"Elegido":*/fb.checkbox("check"+i,cdo.getColValue("poliza")+"-"+cdo.getColValue("tipoPlan"),false,false,null,null,"onClick=\"javascript:document."+fb.getFormName()+".submit();\"")%></td>
				</tr>
<%
	poliza = cdo.getColValue("poliza");
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
}
else
{
	String pcTipoPoliza = "";
	String pcTipoPlan = "";
	String pcPlanNo = "";
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			PlanConvenio pc = new PlanConvenio();

			pc.setTipoPoliza(request.getParameter("tipoPoliza"+i));
			pc.setNombreTipoPoliza(request.getParameter("nombreTipoPoliza"+i));
			pc.setTipoPlan(request.getParameter("tipoPlan"+i));
			pc.setNombreTipoPlan(request.getParameter("nombreTipoPlan"+i));
			pc.setSecuencia("0");
			pc.setEstado("A");
			planLastLineNo++;
			
			pcTipoPoliza = pc.getTipoPoliza();
			pcTipoPlan = pc.getTipoPlan();
			pcPlanNo = pc.getSecuencia();

			String key = "";
			if (planLastLineNo < 10) key = "00"+planLastLineNo;
			else if (planLastLineNo < 100) key = "0"+planLastLineNo;
			else key = ""+planLastLineNo;
			pc.setKey(key);
	
			try
			{
				iPlan.put(pc.getKey(), pc);
				vPlan.add(pc.getTipoPoliza()+"-"+pc.getTipoPlan());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&planLastLineNo="+planLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&planLastLineNo="+planLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	window.opener.location = '../convenio/convenio_config.jsp?change=1&tab=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=pcTipoPoliza%>&tipoPlan=<%=pcTipoPlan%>&planNo=<%=pcPlanNo%>&planLastLineNo=<%=planLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio"))
	{
%>	
	window.opener.location = '../planmedico/pm_convenio_config.jsp?change=1&tab=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=pcTipoPoliza%>&tipoPlan=<%=pcTipoPlan%>&planNo=<%=pcPlanNo%>&planLastLineNo=<%=planLastLineNo%>';	
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