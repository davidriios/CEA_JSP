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
==============================================================================================
==============================================================================================
**/
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
String newFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String grupo = request.getParameter("grupo");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (grupo == null) grupo = "";	
if (!grupo.equals(""))
{
	newFilter += " and c.grupo="+grupo;
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

  if (request.getParameter("cedula") != null)
  {
   if (fp.equalsIgnoreCase("pariente"))
	{
	 	appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
		searchOn = "a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento";
		searchVal = request.getParameter("cedula");
		searchType = "1";
		searchDisp = "Cédula";   	
	}
  }
  else if (request.getParameter("nombre") != null)
  {
    	if (fp.equalsIgnoreCase("pariente"))
	{
		appendFilter += " and upper(a.nombre||' '||a.apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		searchOn = "a.nombre||' '||a.apellido";
		searchVal = request.getParameter("nombre");
		searchType = "1";
		searchDisp = "Nombre";
	}
	
  }
   else if (request.getParameter("empleado") != null)
  {
    	if (fp.equalsIgnoreCase("pariente"))
	{
		appendFilter += " and upper(c.primer_nombre||' '||c.segundo_nombre||' '||c.primer_apellido||' '||c.segundo_apellido) like '%"+request.getParameter("empleado").toUpperCase()+"%'";
		searchOn = "c.primer_nombre||' '||c.primer_apellido";
		searchVal = request.getParameter("empleado");
		searchType = "1";
		searchDisp = "Empleado";
	}
	
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

     if (fp.equalsIgnoreCase("pariente") )
	{
	   sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento, c.calle_dir||' '||c.casa__dir as direccion, a.codigo as numEmpleado, a.cod_compania, a.sexo, to_char(trim(a.provincia),'00')||'-'||a.sigla||'-'||to_char(trim(a.tomo),'0000')||'-'||to_char(trim(a.asiento),'00000') as cedula,  a.nombre||' '||a.apellido as nombre, a.nombre as pnombre, a.apellido as papellido, (select descripcion from parentesco where a.parentesco=codigo) as parentesco,  nvl(to_char(c.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso,  nvl(to_char(c.fecha_puestoact,'dd/mm/yyyy'),' ') as fechaPuestoact, nvl(to_char(a.fecha_nacimiento,'dd/mm/yyyy'),' ') as fechaNacimiento, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre) as eNombre, c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_casada,null,'',' '||c.apellido_casada)) as eApellido, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_casada,null,'',' '||c.apellido_casada)) as empleado, c.sexo as esexo, c.provincia as eprovincia, c.sigla as esigla, c.tomo as etomo, c.asiento as easiento, c.emp_id as empId FROM tbl_pla_pariente a, tbl_pla_empleado c WHERE a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id = c.emp_id and a.cod_compania=c.compania "+newFilter+""+appendFilter; 
	
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_pariente a, tbl_pla_empleado c WHERE a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id = c.emp_id and a.cod_compania=c.compania "+newFilter+""+appendFilter);
	}

    if (fp.equalsIgnoreCase("becario") )
	{
	   sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento, a.calle_dir||' '||a.casa__dir as direccion, a.num_empleado as numEmpleado,  a.sexo, to_char(trim(a.provincia),'00')||'-'||a.sigla||'-'||to_char(trim(a.tomo),'0000')||'-'||to_char(trim(a.asiento),'00000') as cedula,  a.primer_nombre||' '||a.segundo_nombre as nombre, a.primer_apellido||' '||a.segundo_apellido as apellido,  a.num_ssocial as social, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso,  nvl(to_char(a.fecha_puestoact,'dd/mm/yyyy'),' ') as fechaPuestoact, nvl(to_char(a.fecha_nacimiento,'dd/mm/yyyy'),' ') as fechaNacimiento, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as eNombre, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada)) as eApellido, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada)) as empleado, a.emp_id as empId FROM tbl_pla_empleado a where a.compania="+(String) session.getAttribute("_companyId")+" "+newFilter+""+appendFilter; 
	
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM  tbl_pla_empleado a WHERE a.compania="+(String) session.getAttribute("_companyId")+" "+newFilter+""+appendFilter);
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
document.title = 'Parientes - '+document.title;

function setEmpleado(k)
{
<%
				if (fp.equalsIgnoreCase("pariente"))
	{
%>
	  window.opener.document.form0.nombre.value = eval('document.empleado.enombre'+k).value;
	  window.opener.document.form0.apellido.value = eval('document.empleado.papellido'+k).value;
	  window.opener.document.form0.fecha.value = eval('document.empleado.fechaNacimiento'+k).value;
	  window.opener.document.form0.sexo.value = eval('document.empleado.sexo'+k).value;
	  window.opener.document.form0.provincia.value = eval('document.empleado.provincia'+k).value;
	  window.opener.document.form0.sigla.value = eval('document.empleado.sigla'+k).value;
	  window.opener.document.form0.tomo.value = eval('document.empleado.tomo'+k).value;
	  window.opener.document.form0.asiento.value = eval('document.empleado.asiento'+k).value;
	  window.opener.document.form0.direccion.value = eval('document.empleado.direccion'+k).value;
	  window.opener.document.form0.provinciaAso.value = eval('document.empleado.eprovincia'+k).value;
	  window.opener.document.form0.siglaAso.value = eval('document.empleado.esigla'+k).value;
	  window.opener.document.form0.tomoAso.value = eval('document.empleado.etomo'+k).value;
	  window.opener.document.form0.asientoAso.value = eval('document.empleado.easiento'+k).value;
	  window.opener.document.form0.nombreAso.value = eval('document.empleado.eNombre'+k).value;
	  window.opener.document.form0.apellidoAso.value = eval('document.empleado.eApellido'+k).value;
	  window.opener.document.form0.observacion.value = eval('document.empleado.parentesco'+k).value;
	  window.opener.document.form0.empId.value = eval('document.empleado.empId'+k).value;
	  
<%
	} else 
				if (fp.equalsIgnoreCase("becario"))
	{
%>
	  window.opener.document.form0.nombre.value = eval('document.empleado.eNombre'+k).value;
	  window.opener.document.form0.apellido.value = eval('document.empleado.eApellido'+k).value;
	  window.opener.document.form0.fecha.value = eval('document.empleado.fechaNacimiento'+k).value;
	  window.opener.document.form0.sexo.value = eval('document.empleado.sexo'+k).value;
	  window.opener.document.form0.provincia.value = eval('document.empleado.provincia'+k).value;
	  window.opener.document.form0.sigla.value = eval('document.empleado.sigla'+k).value;
	  window.opener.document.form0.tomo.value = eval('document.empleado.tomo'+k).value;
	  window.opener.document.form0.asiento.value = eval('document.empleado.asiento'+k).value;
	  window.opener.document.form0.direccion.value = eval('document.empleado.direccion'+k).value;
	  window.opener.document.form0.numSsocial.value = eval('document.empleado.social'+k).value;
	  window.opener.document.form0.provinciaAso.value = eval('document.empleado.provincia'+k).value;
	  window.opener.document.form0.siglaAso.value = eval('document.empleado.sigla'+k).value;
	  window.opener.document.form0.tomoAso.value = eval('document.empleado.tomo'+k).value;
	  window.opener.document.form0.asientoAso.value = eval('document.empleado.asiento'+k).value;
	  window.opener.document.form0.nombreAso.value = eval('document.empleado.eNombre'+k).value;
	  window.opener.document.form0.apellidoAso.value = eval('document.empleado.eApellido'+k).value;
	//  window.opener.document.form0.observacion.value = eval('document.empleado.parentesco'+k).value;
	  window.opener.document.form0.empId.value = eval('document.empleado.empId'+k).value;
	  
<%
	}
	
	
%>			
				
		
		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<td width="33%">
					<cellbytelabel>C&eacute;dula</cellbytelabel>					
					<%=fb.textBox("cedula","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>					</td>
					<%=fb.formEnd()%>
				
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<td width="33%">
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>					</td>
					<%=fb.formEnd()%>	
<%
fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
				  <td width="34%">
					<cellbytelabel>Empleado</cellbytelabel>
					<%=fb.textBox("empleado","",false,false,false,30)%><%=fb.submit("go","Ir")%></td>
					<%=fb.formEnd()%>				</tr>
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
					<td width="20%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Parentesco</cellbytelabel> </td>
					<td width="30%"><cellbytelabel>Empleado</cellbytelabel> </td>
				</tr>
<%
fb = new FormBean("empleado",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("eNombre"+i,cdo.getColValue("eNombre"))%>
				<%=fb.hidden("eApellido"+i,cdo.getColValue("eApellido"))%>
				<%=fb.hidden("direccion"+i,cdo.getColValue("direccion"))%>
				<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fechaNacimiento"))%>
				<%=fb.hidden("pnombre"+i,cdo.getColValue("pnombre"))%>
				<%=fb.hidden("papellido"+i,cdo.getColValue("papellido"))%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("eprovincia"+i,cdo.getColValue("eprovincia"))%>
				<%=fb.hidden("esigla"+i,cdo.getColValue("esigla"))%>
				<%=fb.hidden("etomo"+i,cdo.getColValue("etomo"))%>
				<%=fb.hidden("easiento"+i,cdo.getColValue("easiento"))%>
				<%=fb.hidden("empId"+i,cdo.getColValue("empId"))%>
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
				<%=fb.hidden("parentesco"+i,cdo.getColValue("parentesco"))%>
				
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEmpleado(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("parentesco")%></td>
					<td><%=cdo.getColValue("empleado")%></td>
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
	