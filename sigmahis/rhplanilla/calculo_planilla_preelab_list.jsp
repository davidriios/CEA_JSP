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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String userName = UserDet.getUserName();
String userId   = UserDet.getUserId();

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	
	String codigo    = "";       
	String descrip   = "";
	String horas_ext = "";

	if (request.getParameter("codigo") != null)
	{
		appendFilter += " and upper(a.cod_reporte) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "a.cod_reporte";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
		codigo     = request.getParameter("codigo");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	else if (request.getParameter("descripcion") != null)
	{
		appendFilter += " and upper(b.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "b.nombre";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
		descrip    = request.getParameter("descripcion");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	else if (request.getParameter("fecha_proceso") != null)
	{
		//appendFilter += " where horas_tiempoext ="+request.getParameter("horas_tiempoext");
		appendFilter += " and to_char(a.fecha_proceso,'dd/mm/yyyy') like '%"+request.getParameter("fecha_proceso").toUpperCase()+"%'";
    searchOn = "to_char(a.fecha_proceso,'dd/mm/yyyy')";
    searchVal = request.getParameter("fecha_proceso");
    searchType = "2";
    searchDisp = "Fecha de Proceso";
		horas_ext  = request.getParameter("fecha_proceso");  
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
    else if (searchType.equals("2"))
    {
			appendFilter += " and "+searchOn+"="+searchVal;
    }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

	sql = "select a.anio, a.cod_reporte as codReporte, a.mes, to_char(a.fecha_proceso,'dd/mm/yyyy') as fechaProceso,  b.nombre as nombre, a.cod_compania compania, a.partida, decode(a.mes,'1','ENERO','2','FEBRERO','3','MARZO','4','ABRIL','5','MAYO','6','JUNIO','7','JULIO','8','AGOSTO','9','SEPTIEMBRE','10','OCTUBRE','11','NOVIEMBRE','12','DICIEMBRE') as mesDesc,  b.nombre||' de '||decode(a.mes,'1','ENERO','2','FEBRERO','3','MARZO','4','ABRIL','5','MAYO','6','JUNIO','7','JULIO','8','AGOSTO','9','SEPTIEMBRE','10','OCTUBRE','11','NOVIEMBRE','12','DICIEMBRE') as descripcion from tbl_pla_reporte_encabezado a, tbl_pla_reporte b where  a.cod_reporte = b.cod_reporte and a.cod_compania = "+(String) session.getAttribute("_companyId") + appendFilter + " order by a.cod_reporte asc, a.fecha_proceso desc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_pla_reporte_encabezado a, tbl_pla_reporte b where  a.cod_reporte = b.cod_reporte and a.cod_compania = "+(String) session.getAttribute("_companyId") + appendFilter );

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
	document.title = 'Planilla - Retenciones'+document.title;

function add()
{
	abrir_ventana('../rhplanilla/calculo_planilla_preelab.jsp');
}

function edit1()
{
	abrir_ventana('../rhplanilla/pago_planilla_list.jsp');
}
function edit(cod,num,anio,cia)
{
	abrir_ventana('../rhplanilla/pago_planilla_preelab_list.jsp?cod='+cod+'&num='+num+'&anio='+anio+'&cia='+cia);
}
function borrar(cod,mes,anio,cia)

{
var proceso = 'Del';
	if(confirm('Se Borrará la Planilla.... Desea Continuar'))
 	{
		if(executeDB('<%=request.getContextPath()%>','call sp_pla_elimina_encab_preelab('+cod+','+cia+','+mes+','+anio+')'))
			{
			alert('La Planilla ha sido Borrada Satisfactoriamente!');	
			 window.location.reload(true);
			 } else alert('No se ha podido borrar la Planilla...Consulte al Administrador!');
	}
}

function aprobar(cod,mes,anio,cia)
{
var p_user = '<%=(String) session.getAttribute("_userName")%>';

if(confirm('Se Creará el Archivo DETALLE.TXT .... Desea Continuar'))
	{
if(executeDB('<%=request.getContextPath()%>','call sp_pla_crea_esysmeca('+anio+','+cod+','+mes+','+cia+')'))
		{
		alert('Se creó Archivo DETALLE.TXT ... Satisfactoriamente!');	
		window.location.reload(true);
		} else alert('No se ha podido generar el archivo TXT...Consulte al Administrador!');
	}
}

function printList()
{
	abrir_ventana('../rhplanilla/print_list_calculo_planilla_preelab.jsp?fp=emp&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - RETENCIONES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800015"))
{
%>
			<a href="javascript:add()" class="Link00">[ Registrar Nueva Planilla ]</a>
<%
}
%>
		</td>
  </tr>
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
				<td width="33%">
					C&oacute;digo de Planilla
	        <%=fb.intBox("codigo",codigo,false,false,false,10)%>					<%=fb.submit("go","Ir")%>				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="34%">
					Descripción 
					<%=fb.textBox("descripcion",descrip,false,false,false,20)%>
					<%=fb.submit("go","Ir")%>				</td>
				<%=fb.formEnd()%>
<%
fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="33%">
					Fecha de Proceso.
					<%=fb.textBox("fecha_proceso",horas_ext,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>				</td>
				<%=fb.formEnd()%>			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800014"))
{
%>
			<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
<%
}
%>
			&nbsp;
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

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			
			<td width="10%">Año</td>
			<td width="45%">Descripci&oacute;n</td>
			<td width="15%">Fecha de Pago</td>
			<td width="10%">Mes</td>
			<td width="20%">Acci&oacute;n</td>
		</tr>
<%
String nombre = "";
String estado = "B";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	
	if (i % 2 == 0) color = "TextRow01";
	
		 if (!nombre.equalsIgnoreCase(cdo.getColValue("nombre")))
				 {
				%>
				  
			<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
            <td colspan="5" class="TitulosdeTablas"> [<%=cdo.getColValue("codReporte")%>] - <%=cdo.getColValue("nombre")%></td>
            </tr>
				<%
				   }
				%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("fechaProceso")%></td>
			<td align="center"><%=cdo.getColValue("mesDesc")%></td>
			<td align="center">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800016"))
{
%>
			
			<a href="javascript:edit(<%=cdo.getColValue("codReporte")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">  Ver&nbsp;&nbsp;&nbsp;&nbsp;</a>
			
	<a href="javascript:aprobar(<%=cdo.getColValue("codReporte")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">&nbsp; ESysmeca&nbsp;&nbsp;</a>
	
	<a href="javascript:borrar(<%=cdo.getColValue("codReporte")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Borrar</a>

<% } %>
			</td>
		</tr>
<%
	nombre = cdo.getColValue("nombre");
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
}
%>
