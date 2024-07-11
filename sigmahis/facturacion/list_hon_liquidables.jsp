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
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String tipo = request.getParameter("tipo");

if(tipo == null) tipo = "E";


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

  if (request.getParameter("codigo") != null )
  {
		if(tipo.trim().equals("E"))
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		else appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
	else if (request.getParameter("nombre") != null && tipo.trim().equals("M"))
  {
    appendFilter += " and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = " primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))";
    searchVal = request.getParameter("nombre");
    searchType = "1";
    searchDisp = "Nombre Medico";
  }
  else if (request.getParameter("nombre") != null && tipo.trim().equals("E"))
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


if(tipo.trim().equals("E"))
{

sql="select 'E' type, to_char(codigo) codigo, nvl(liquidable_sino,'N') liquidable, nombre,' ' segundo_nombre,' ' primer_apellido,' ' segundo_apellido,' ' apellido_casada  from tbl_adm_empresa where tipo_empresa = 1 "+appendFilter+"order by codigo ";

}
else if(tipo.trim().equals("M"))
{
	sql="select 'M' type, codigo, nvl(liquidable,'N') liquidable,primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) nombre from tbl_adm_medico where codigo is not null  "+appendFilter;
}

   rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

/*
sql="select codigo, nvl(liquidable,'N') liquidable, primer_nombre,  nvl(segundo_nombre,' ')segundo_nombre, primer_apellido, nvl(segundo_apellido,' ')segundo_apellido,    nvl(apellido_de_casada,' ')apellido_casada  from tbl_adm_medico ";
al2 = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a)");
   rowCount += CmnMgr.getCount("select count(*) from ("+sql+")");
*/
if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";

  if (searchVal != null && !searchVal.equals("")) searchValDisp=searchVal;
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
document.title = 'Honorarios Liquidables - '+document.title;
function getMain(formx)
{
  formx.tipo.value = document.search03.tipo.value;
  return true;
}
function cambiar(i,val)
{
var codigo = eval('document.form0.codigo'+i).value ;
var tipo = eval('document.form0.tipo'+i).value ;
var liquidable = eval('document.form0.liquidable'+i).value ;
	if(liquidable != val)
	{
		if(confirm('Cambiar Liquidable'))
		{
			if(tipo =="E")
			{
			if(executeDB('<%=request.getContextPath()%>','update tbl_adm_empresa set liquidable_sino = \''+val+'\' where tipo_empresa = 1 and codigo = '+codigo,''))
				{
					CBMSG.warning('Cambio Realizado...');
					window.location.reload(true);
				}
			}
			else if(tipo =="M")
			{
			if(executeDB('<%=request.getContextPath()%>','update tbl_adm_medico set liquidable = \''+val+'\' where codigo = \''+codigo+'\'',''))
				{
					alert('Cambio Realizado...');
					window.location.reload(true);
				}
			}
		}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DEFINICIÓN DE MÉDICOS Y SOCIEDADES MÉDICAS LIQUIDABLES "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("tipo","").replaceAll(" id=\"tipo\"","")%>
				<td width="35%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel>
							<%=fb.textBox("codigo","",false,false,false,25,null,null,null)%>
							<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>

				<%
				fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("tipo","").replaceAll(" id=\"tipo\"","")%>
				<td width="35%">&nbsp;<cellbytelabel>Nombre</cellbytelabel>
							<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
				<%
				fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="30%">&nbsp;<cellbytelabel>Empresa / M&eacute;dicos</cellbytelabel>
							<%=fb.select("tipo","E=EMPRESA, M=MEDICOS ",tipo,false,false,0,"Text10",null,null)%>
							<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>


			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>

</table>
<tr><td colspan="2">&nbsp;</td></tr>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
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
<div id="sociedadesMain" width="100%" style="overflow:scroll;position:relative;height:350">
<div id="sociedades" width="98%" style="overflow;position:absolute">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
	<%=fb.hidden("sizeMed",""+al2.size())%>
	<%=fb.hidden("sizeEmp",""+al.size())%>
<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">

	<tr class="TextHeader">
		<td width="10%" colspan="4"><cellbytelabel>Sociedades M&eacute;dicas</cellbytelabel></td>
	</tr>
	<tr class="TextHeader">
	  <td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="50%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel> </td>
	  <td width="20%" align="center" colspan="2">&nbsp;<cellbytelabel>Liquidable</cellbytelabel></td>
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
	<%=fb.hidden("liquidable"+i,cdo.getColValue("liquidable"))%>
	<%=fb.hidden("tipo"+i,cdo.getColValue("type"))%>

	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
		<td align="center">
		<%=fb.radio("status"+i,"",cdo.getColValue("liquidable").trim().equals("S"),false,false,null,null,"onClick=\"javascript:cambiar("+i+",'S')\"")%>Si</td>
		<td align="center">
		<%=fb.radio("status"+i,"N",cdo.getColValue("liquidable").trim().equalsIgnoreCase("N"),false,false,null,null,"onClick=\"javascript:cambiar("+i+",'N')\"")%>No</td>
	</tr>
	<%
	}
	%>

</table>
<%=fb.formEnd()%>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>

<!--

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="medicosMain" width="100%" style="overflow:scroll;position:relative;height:150">
<div id="medicos" width="98%" style="overflow;position:absolute">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<!--<%fb = new FormBean("form01",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
	<%=fb.hidden("sizeMed",""+al2.size())%>
	<%=fb.hidden("sizeEmp",""+al.size())%>

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">

	<tr class="TextHeader">
		<td width="10%" colspan="4">Mèdicos</td>
	</tr>
	<tr class="TextHeader">
	  <td width="10%">&nbsp;Còdigo</td>
		<td width="15%">&nbsp;Primer Nombre</td>
		<td width="15%">&nbsp;Segundo Nombre</td>
		<td width="15%">&nbsp;Primer Apellido</td>
		<td width="15%">&nbsp;Segundo Apellido</td>
		<td width="15%">&nbsp;Apellido Casada </td>
	  <td width="15%" align="center" colspan="2">&nbsp;Liquidable</td>
	</tr>

	<%
	for (int i=0; i<al2.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al2.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("liquidable"+i,cdo.getColValue("liquidable"))%>

	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td>&nbsp;<%=cdo.getColValue("primer_nombre")%></td>
		<td>&nbsp;<%=cdo.getColValue("segundo_nombre")%></td>
		<td>&nbsp;<%=cdo.getColValue("primer_apellido")%></td>
		<td>&nbsp;<%=cdo.getColValue("segundo_apellido")%></td>
		<td>&nbsp;<%=cdo.getColValue("apellido_casada")%></td>
		<td align="center">
		<%=fb.radio("status"+i,"",cdo.getColValue("liquidable").trim().equals("S"),false,false,null,null,"")%>Si</td>
		<td align="center">
		<%=fb.radio("status"+i,"N",cdo.getColValue("liquidable").trim().equalsIgnoreCase("N"),false,false,null,null,"")%>No</td>
	</tr>
	<%
	}
	%>

</table>
<%=fb.formEnd()%>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	<!--</td>
</tr>
</table>

--->



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
					<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
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
