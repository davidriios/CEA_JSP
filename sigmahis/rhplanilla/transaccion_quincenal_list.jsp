<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
800057	VER LISTA DE EXPEDIENTE DEL EMPLEADO
800058	IMPRIMIR LA LISTA DE EXPEDIENTE DEL EMPLEADO
800059	AGREGAR EXPEDIENTE DEL EMPLEADO
800060	MODIFICAR EXPEDIENTE DEL EMPLEADO
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alSec = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String filter = "";
String unidadCode = request.getParameter("unidadCode");
String classCode = request.getParameter("classCode");
String secId = request.getParameter("codigo");

alSec = sbb.getBeanList(ConMgr.getConnection(), "select codigo, descripcion  from tbl_sec_unidad_ejec where nivel = '3' and compania="+(String) session.getAttribute("_companyId")+" order by codigo", CommonDataObject.class);


if (secId == null) secId = "0";
{
	if (alSec.size() > 0) secId = ((CommonDataObject) alSec.get(0)).getOptValueColumn();
	else secId = "";
}
else appendFilter = " and a.ubic_seccion="+secId;

	
if (unidadCode == null) unidadCode = "";	
if (!unidadCode.equals(""))
{
	appendFilter = " and ubic_seccion="+unidadCode;
}


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

  if (request.getParameter("cedula") != null)
  {
    appendFilter += " and upper(provincia||'-'||sigla||'-'||tomo||'-'||asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    searchOn = "provincia||'-'||sigla||'-'||tomo||'-'||asiento";
    searchVal = request.getParameter("cedula");
    searchType = "1";
    searchDisp = "Cédula";
  }
  else if (request.getParameter("nombre") != null)
  {
    appendFilter += " and upper(primer_nombre||' '||primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "primer_nombre||' '||primer_apellido";
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
	sql="select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido ,a.ubic_seccion unidadCode, b.descripcion from tbl_pla_empleado a, tbl_sec_unidad_ejec b where a.compania = b.compania and a.ubic_seccion = b.codigo and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.ubic_seccion,a.primer_apellido";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_empleado where compania="+(String) session.getAttribute("_companyId")+appendFilter);
	
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
document.title = 'Planilla - Transacciones Quincenales - '+document.title;

function add()
{
abrir_ventana('../rhplanilla/expediente_empleado_config.jsp');
}

function edit(prov,sig, tom, asi)
{
abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?mode=edit&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi);
}

function crear(prov,sig, tom, asi)
{
abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?mode=edit&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi);
}
function  printList()
{
abrir_ventana('print_list_expediente_empleado.jsp');
}
function getMain(formX)
{ 
	formX.unidadCode.value = document.search00.unidadCode.value;

	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - TRANSACCION - TRANSACCIONES QUINCENALES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">
			Almac&eacute;n
			<%=fb.select("secId",alSec,secId)%>
			<%=fb.submit("go","Ir")%>
		</td>
		<%=fb.formEnd()%>	
	</tr>
		  
				
		<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,             "onSubmit=\"javascript:return(getMain(this))\"");%>	
					<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("unidadCode","").replaceAll(" id=\"unidadCode\"","")%>
					<td width="50%">&nbsp;C&eacute;dula&nbsp;
			<%=fb.textBox("cedula","",false,false,false,30,null,null,null)%>
			<%=fb.submit("go","Ir")%></td>
		    <%=fb.formEnd()%>	
		    <%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
		    <%=fb.formStart()%>
		    <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="50%">&nbsp;Nombre
			<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%>
			<%=fb.submit("go","Ir")%>	</td>
		    <%=fb.formEnd()%>	
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800058"))
{
%>
		<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
<%
}
%>
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
	<tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
		<td width="20%">&nbsp;C&oacute;digo</td>
		<td width="55%">&nbsp;Nombre</td>
		<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
	</tr>
<%
                String  unidadClass = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 
				if (!unidadClass.equalsIgnoreCase("["+cdo.getColValue("unidadCode")+"] "+cdo.getColValue("Descripcion")))
					{
				%>
				<tr class="TextRow03">
					<td colspan="5">[<%=cdo.getColValue("unidadCode")%>] <%=cdo.getColValue("Descripcion")%></td>
				</tr>
				<%
					}
				%>
					
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800060"))
{
%>
					<a href="javascript:crear('<%=cdo.getColValue("provincia")%>','<%=cdo.getColValue("sigla")%>','<%=cdo.getColValue("tomo")%>','<%=cdo.getColValue("asiento")%>','<%=cdo.getColValue("asiento")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Registrar</a>
<%}%>
					</td>
							<td align="center">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800060"))
{
%>
					<a href="javascript:edit('<%=cdo.getColValue("provincia")%>','<%=cdo.getColValue("sigla")%>','<%=cdo.getColValue("tomo")%>','<%=cdo.getColValue("asiento")%>','<%=cdo.getColValue("asiento")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>
<%}%>
					</td>
				</tr>
	<%
					unidadClass = "["+cdo.getColValue("unidadCode")+"] "+cdo.getColValue("Descripcion");
				}
				%>						
								
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
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
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
}// else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>
	