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
800013	VER LISTA DE TIPO DE EMPLEADO
800014	IMPRIMIR LISTA DE TIPO DE EMPLEADO
800015	AGREGAR TIPO DE EMPLEADO
800016	MODIFICAR TIPO DE EMPLEADO
==================================================================================
**/
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
	String anio = request.getParameter("anio");
		if (request.getParameter("anio") == null) anio = CmnMgr.getCurrentDate("yyyy");
		


	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(a.cod_planilla) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo     = request.getParameter("codigo");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
		appendFilter += " and upper(b.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descrip    = request.getParameter("descripcion");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	if (request.getParameter("fecha_pago") != null && !request.getParameter("fecha_pago").trim().equals(""))
	{
		appendFilter += " and to_char(a.fecha_pago,'dd/mm/yyyy') =to_date('"+request.getParameter("fecha_pago")+"','dd/mm/yyyy')";
		horas_ext  = request.getParameter("fecha_pago");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
			appendFilter += " and to_number(a.anio) like '%"+request.getParameter("anio").toUpperCase()+"%'";
			anio  = request.getParameter("anio");  
	}
	
	if(request.getParameter("anio") != null)
	{
	sql = "select a.anio, a.cod_planilla as codPlanilla, decode(a.estado,'B','Borrador','D','Definitiva','A','Anulada') as descEstado, a.num_planilla as numPlanilla, a.periodo, to_char(a.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(a.fecha_inicial,'dd/mm/yyyy') as fechaInical, to_char(a.fecha_final,'dd/mm/yyyy') as fechaFinal, a.estado, ltrim(b.nombre,18)||' del '||a.fecha_inicial||' al '||a.fecha_final as descripcion, b.nombre as nombre, a.cod_compania compania, a.anio||' - '||a.num_planilla as descPla,nvl(b.fg,'N')fg ,(select x.cod_banco from tbl_pla_parametros x where x.cod_compania = a.cod_compania ) as banco,(select  x.cuenta_bancaria from tbl_pla_parametros x where x.cod_compania = a.cod_compania ) as cuenta from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and b.beneficiarios = 'EM' and a.cod_compania=b.compania"+appendFilter+" and a.cod_compania = "+(String) session.getAttribute("_companyId") + "order by a.cod_planilla asc, a.fecha_pago desc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
	document.title = 'Planilla - '+document.title;
function add(){	abrir_ventana('../rhplanilla/calculo_planilla.jsp');}
function view(cod,num,anio,cia,fg,estado,banco,cuenta){ if(fg=='AJ')abrir_ventana('../rhplanilla/reg_pagoajuste_list.jsp?codPlanillaAj='+cod+'&noPlanillaAj='+num+'&anioAj='+anio+'&cia='+cia+'&fg='+fg+'&estado='+estado); else if(fg!='LIQ')abrir_ventana('../rhplanilla/pago_planilla_list.jsp?cod='+cod+'&num='+num+'&anio='+anio+'&cia='+cia+'&fg='+fg+'&estado='+estado+'&banco='+banco+'&cuenta='+cuenta); else abrir_ventana('../rhplanilla/pago_planilla_liquidacion_list.jsp?cod='+cod+'&num='+num+'&anio='+anio+'&cia='+cia+'&estado='+estado+'&banco='+banco+'&cuenta='+cuenta);}
function borrar(cod,num,anio,cia){if(confirm('Está seguro de    B O R R A R    la  Planilla.')){showPopWin('../common/run_process.jsp?fp=DELPLA&actType=51&docType=DELPLA&docId='+cod+' - '+anio+' - '+num+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&codPlanilla='+cod+'&numPlanilla='+num,winWidth*.75,winHeight*.65,null,null,'');}else alert('Proceso Cancelado por el usuario.');}
function aprobar(cod,num,anio,cia){if(confirm('Está seguro de    A P R O B A R     la  Planilla.\nQuedará en Estado D E F I N I T I V A .... Desea Continuar!!')){showPopWin('../common/run_process.jsp?fp=DELPLA&actType=6&docType=DELPLA&docId='+cod+' - '+anio+' - '+num+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&codPlanilla='+cod+'&numPlanilla='+num,winWidth*.75,winHeight*.65,null,null,'');}else alert('Proceso Cancelado por el usuario.');}
function asiento(cod,num,anio,cia){abrir_ventana('../rhplanilla/asiento_planilla_list.jsp?cod='+cod+'&num='+num+'&anio='+anio+'&cia='+cia);}
function printList(){abrir_ventana('../rhplanilla/print_list_calculo_planilla.jsp?fp=emp&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - CALCULO DE PLANILLA "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Planilla ]</a></authtype></td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="25%">
					Planilla
					<%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where compania="+(String) session.getAttribute("_companyId")+"  order by 1","codigo",codigo,false,false,0,"Text10",null,null,null,"S")%> 
				</td>
				<td width="25%">
					Descripción 
					<%=fb.textBox("descripcion",descrip,false,false,false,20)%>
				</td>
				<td width="25%">
					Fecha de Pago.
					<%=fb.textBox("fecha_pago",horas_ext,false,false,false,10)%>
				</td>
				<td width="25%">
						Año <%=fb.select(ConMgr.getConnection(),"select distinct(anio) codigo, anio from tbl_pla_planilla_encabezado order by anio desc","anio",anio,"T")%>
				            	<%=fb.submit("go","Ir")%>
				</td>
			</tr>
		<%=fb.formEnd()%>  
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descrip)%>
				<%=fb.hidden("fecha_pago",""+horas_ext)%>
				<%=fb.hidden("anio",""+anio)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descrip)%>
				<%=fb.hidden("fecha_pago",""+horas_ext)%>
				<%=fb.hidden("anio",""+anio)%>
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
			
			<td width="10%">Año/# Planilla</td>
			<td width="45%">Descripci&oacute;n</td>
			<td width="15%">Fecha de Pago</td>
			<td width="10%">Estado</td>
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
            <td colspan="5" class="TitulosdeTablas"> [<%=cdo.getColValue("codPlanilla")%>] - <%=cdo.getColValue("nombre")%></td>
            </tr>
				<%
				   }
				%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="left"><%=cdo.getColValue("descPla")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("fechaPago")%></td>
			<td align="center"><%=cdo.getColValue("descEstado")%></td>
			<td align="center">	
			<authtype type='1'><a href="javascript:view(<%=cdo.getColValue("codPlanilla")%>,<%=cdo.getColValue("numPlanilla")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>,'<%=cdo.getColValue("fg")%>','<%=cdo.getColValue("estado")%>','<%=cdo.getColValue("banco")%>','<%=cdo.getColValue("cuenta")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">  Ver&nbsp;&nbsp;&nbsp;&nbsp;</a></authtype>
			
			
<%  if (!estado.equalsIgnoreCase(cdo.getColValue("estado")))
 {
%>
   <authtype type='50'><a href="javascript:asiento(<%=cdo.getColValue("codPlanilla")%>,<%=cdo.getColValue("numPlanilla")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>)" class="Link06Bold" onMouseOver="setoverc(this,'Link06Bold')" onMouseOut="setoutc(this,'Link06Bold')">&nbsp;Planilla Cerrada&nbsp;</a></authtype>

	<% } else {
	%>
	<authtype type='6'><a href="javascript:aprobar(<%=cdo.getColValue("codPlanilla")%>,<%=cdo.getColValue("numPlanilla")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">&nbsp;Aprobar&nbsp;&nbsp;</a></authtype>
	
	<authtype type='51'><a href="javascript:borrar(<%=cdo.getColValue("codPlanilla")%>,<%=cdo.getColValue("numPlanilla")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("compania")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Borrar</a></authtype>
<% }%>


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
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("searchDisp",""+searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descrip)%>
				<%=fb.hidden("fecha_pago",""+horas_ext)%>
				<%=fb.hidden("anio",""+anio)%>
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
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descrip)%>
				<%=fb.hidden("fecha_pago",""+horas_ext)%>
				<%=fb.hidden("anio",""+anio)%>
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