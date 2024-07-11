<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.AplicacionBeneficio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDef" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDef" scope="session" class="java.util.Vector" />
<%
/*
==================================================================================
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500037") || SecMgr.checkAccess(session.getId(),"500038") || SecMgr.checkAccess(session.getId(),"500039") || SecMgr.checkAccess(session.getId(),"500040"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String key = "";
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String tab = request.getParameter("tab");
String cTab = request.getParameter("cTab");
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
int cobLastLineNo = 0;
int exclLastLineNo = 0;
int defLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (tab == null) tab = "0";
if (cTab == null) cTab = "0";
if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null || planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");
if (categoriaAdm == null || tipoAdm == null || clasifAdm == null) throw new Exception("La Clasificación del Plan no es válida. Por favor intente nuevamente!");
if (request.getParameter("cobLastLineNo") != null) cobLastLineNo = Integer.parseInt(request.getParameter("cobLastLineNo"));
if (request.getParameter("exclLastLineNo") != null) exclLastLineNo = Integer.parseInt(request.getParameter("exclLastLineNo"));
if (request.getParameter("defLastLineNo") != null) defLastLineNo = Integer.parseInt(request.getParameter("defLastLineNo"));

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
    appendFilter += " where upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter += " where upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
		{
			appendFilter += " where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
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
		sql = "select codigo, descripcion from tbl_adm_calculo_beneficio"+appendFilter+" order by descripcion";
		al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal,AplicacionBeneficio.class);
		rowCount = CmnMgr.getCount("select count(*) from tbl_adm_calculo_beneficio"+appendFilter);
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
document.title = 'Parámetros de Cálculo - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PARAMETRO DE CALCULO"></jsp:param>
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
				<%=fb.hidden("tab",tab)%>
				<%=fb.hidden("cTab",cTab)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("empresa",empresa)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("tipoPoliza",tipoPoliza)%>
				<%=fb.hidden("tipoPlan",tipoPlan)%>
				<%=fb.hidden("planNo",planNo)%>
				<%=fb.hidden("categoriaAdm",categoriaAdm)%>
				<%=fb.hidden("tipoAdm",tipoAdm)%>
				<%=fb.hidden("clasifAdm",clasifAdm)%>
				<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
				<%=fb.hidden("exclLastLineNo",""+exclLastLineNo)%>
				<%=fb.hidden("defLastLineNo",""+defLastLineNo)%>
				<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,20)%>
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
				<%=fb.hidden("tab",tab)%>
				<%=fb.hidden("cTab",cTab)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("empresa",empresa)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("tipoPoliza",tipoPoliza)%>
				<%=fb.hidden("tipoPlan",tipoPlan)%>
				<%=fb.hidden("planNo",planNo)%>
				<%=fb.hidden("categoriaAdm",categoriaAdm)%>
				<%=fb.hidden("tipoAdm",tipoAdm)%>
				<%=fb.hidden("clasifAdm",clasifAdm)%>
				<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
				<%=fb.hidden("exclLastLineNo",""+exclLastLineNo)%>
				<%=fb.hidden("defLastLineNo",""+defLastLineNo)%>
				<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
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
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab",cTab)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
<%=fb.hidden("exclLastLineNo",""+exclLastLineNo)%>
<%=fb.hidden("defLastLineNo",""+defLastLineNo)%>
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
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas los diagnósticos listados!")%></td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	AplicacionBeneficio ab = (AplicacionBeneficio) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,ab.getCodigo())%>
				<%=fb.hidden("descripcion"+i,ab.getDescripcion())%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=ab.getCodigo()%></td>
					<td><%=ab.getDescripcion()%></td>
					<td align="center"><%=(vDef.contains(ab.getCodigo()))?"Elegido":fb.checkbox("check"+i,ab.getCodigo(),false,false)%></td>
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
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			AplicacionBeneficio ab = new AplicacionBeneficio();

			ab.setCodigo(request.getParameter("codigo"+i));
			ab.setDescripcion(request.getParameter("descripcion"+i));
			ab.setSecuencia("0");
			defLastLineNo++;

			if (defLastLineNo < 10) key = "00"+defLastLineNo;
			else if (defLastLineNo < 100) key = "0"+defLastLineNo;
			else key = ""+defLastLineNo;
			ab.setKey(key);
	
			try
			{
				iDef.put(key, ab);
				vDef.add(ab.getCodigo());
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&cobLastLineNo="+cobLastLineNo+"&exclLastLineNo="+exclLastLineNo+"&defLastLineNo="+defLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&cobLastLineNo="+cobLastLineNo+"&exclLastLineNo="+exclLastLineNo+"&defLastLineNo="+defLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	window.opener.location = '../convenio/convenio_clasif.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&cobLastLineNo=<%=cobLastLineNo%>&exclLastLineNo=<%=exclLastLineNo%>&defLastLineNo=<%=defLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio"))
	{
%>	
 	window.opener.location = '../planmedico/pm_convenio_clasif.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&cobLastLineNo=<%=cobLastLineNo%>&exclLastLineNo=<%=exclLastLineNo%>&defLastLineNo=<%=defLastLineNo%>';
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