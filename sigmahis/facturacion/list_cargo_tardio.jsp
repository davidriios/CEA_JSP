<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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

  String codigo  = "",centro="",name_centro="";  // variable para mantener el valor de los campos filtrados en la consulta
	String nombre  = "" , admision ="", fecha_nac ="" , paciente ="";
  if (request.getParameter("paciente") != null && !request.getParameter("paciente").trim().equals(""))  
  {
    appendFilter += " and  a.paciente = "+request.getParameter("paciente");
	paciente     = request.getParameter("paciente");   // utilizada para mantener el paciente por el cual se filtró
  }
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))  
  {
    appendFilter += " and upper(a.secuencia) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");   // utilizada para mantener el código por el cual se filtró
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals("")){
    appendFilter += " and upper(p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre     = request.getParameter("nombre");  // utilizada para mantener la descripción del paciente
  }
  if (request.getParameter("admision") != null && !request.getParameter("admision").trim().equals(""))  
  {
    appendFilter += " and a.admision  ="+request.getParameter("admision");
	admision     = request.getParameter("admision");   // utilizada para mantener la admision por el cual se filtró
  }
  if (request.getParameter("fecha_nac") != null && !request.getParameter("fecha_nac").trim().equals(""))  
  {
    appendFilter += " and  trunc(p.f_nac) = to_date('"+request.getParameter("fecha_nac")+"','dd/mm/yyyy')";
	fecha_nac     = request.getParameter("fecha_nac");   // utilizada para mantener la admision por el cual se filtró
  }
  if (request.getParameter("centro") != null && !request.getParameter("centro").trim().equals(""))  
  {
    appendFilter += " and a.centro  ="+request.getParameter("centro");
	centro     = request.getParameter("centro");   // utilizada para mantener la admision por el cual se filtró
  }
  if (request.getParameter("name_centro") != null && !request.getParameter("name_centro").trim().equals(""))  
  {
    appendFilter += " and upper(c.descripcion) like '%"+request.getParameter("name_centro").toUpperCase()+"%'";
	name_centro     = request.getParameter("name_centro");   // utilizada para mantener el código por el cual se filtró
  }
  sql = "select a.secuencia,a.estatus, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.paciente, a.admision, a.centro,a.observacion, a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy')as fecha_creacion ,a.usuario_modifica, to_char(a.fecha_modifica,'dd/mm/yyyy') as fecha_modifica, a.pase,a.pase_k,a.pac_id,c.descripcion, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre from tbl_fac_cargo_tardio a, tbl_cds_centro_servicio c ,vw_adm_paciente p where a.centro = c.codigo and a.pac_id=p.pac_id "+appendFilter;
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Listado de Explicacion Cargo Tardio- '+document.title;

function add()
{
	abrir_ventana('../facturacion/exp_cargo_tardio.jsp');
}
function edit(id,admision,pac_id,centro)
{
		abrir_ventana('../facturacion/exp_cargo_tardio.jsp?mode=view&secuencia='+id+'&admision='+admision+'&pac_id='+pac_id+'&centro='+centro);
}
function printList()
{
	abrir_ventana('../facturacion/print_list_exp_cargo_tardio.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function buscaUE()
{
	abrir_ventana1('../common/search_centro_servicio.jsp?fp=CTF');
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPLICACION CARGO TARDIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
<td align="right">&nbsp;
        <authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Explicaci&oacute;n de Cargo Tardio</cellbytelabel> ]</a></authtype>
</td>
</tr>
<tr>
<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<tr class="TextFilter">
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<td width="25%"><cellbytelabel>Secuencia Explicaci&oacute;n</cellbytelabel>
<%=fb.intBox("codigo",codigo,false,false,false,5,10,null,null,null)%>
</td>



<td width="75%">


<cellbytelabel>Fecha Nac</cellbytelabel>.
	<jsp:include page="../common/calendar.jsp" flush="true">
	<jsp:param name="noOfDateTBox" value="1" />
	<jsp:param name="clearOption" value="true" />
	<jsp:param name="nameOfTBox1" value="fecha_nac" />
	<jsp:param name="valueOfTBox1" value="<%=fecha_nac%>" />
	</jsp:include>
	<cellbytelabel>Cod. Paciente</cellbytelabel>
<%=fb.intBox("paciente",paciente,false,false,false,4,null,null,null)%>
<cellbytelabel>Admisi&oacute;n</cellbytelabel>
<%=fb.textBox("admision",admision,false,false,false,4,null,null,null)%>

	<cellbytelabel>Nombre Paciente</cellbytelabel>
<%=fb.textBox("nombre",nombre,false,false,false,30,null,null,null)%>


</td>	
</tr>

<tr class="TextFilter">
<td colspan="2">
<cellbytelabel>Centro servicio</cellbytelabel> 
<%=fb.textBox("centro",centro,false,false,false,5,null,null,null)%>
<%=fb.textBox("name_centro",name_centro,false,false,false,30,null,null,null)%>
<%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaUE()\"")%>
<%=fb.submit("go","Ir")%>

</td>	
</tr>


<%=fb.formEnd()%>



</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("fecha_nac",fecha_nac)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("name_centro",name_centro)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("fecha_nac",fecha_nac)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("name_centro",name_centro)%>
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
	
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr class="TextHeader" align="center">
<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
<td width="5%"><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
<td width="8%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
<td width="32%" align="left"><cellbytelabel>Paciente</cellbytelabel></td>
<td width="30%" align="left"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
<td width="10%">&nbsp;</td>
</tr>	
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<tr  align="center" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td><%=cdo.getColValue("secuencia")%></td>		
<td><%=cdo.getColValue("fecha_creacion")%></td>		
<td><%=cdo.getColValue("admision")%></td>
<td><%=cdo.getColValue("fecha_nacimiento")%></td>	
<td align="left"><%=cdo.getColValue("nombre")%></td>
<td align="left"><%=cdo.getColValue("descripcion")%></td>
<td align="center">&nbsp;
<authtype type='1'><a href="javascript:edit('<%=cdo.getColValue("secuencia")%>','<%=cdo.getColValue("admision")%>','<%=cdo.getColValue("pac_id")%>','<%=cdo.getColValue("centro")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
</td>
</tr>
<% } %>	
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("paciente",paciente)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("centro",centro)%>
				<%=fb.hidden("name_centro",name_centro)%>			
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("fecha_nac",fecha_nac)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("name_centro",name_centro)%>
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
}
%>