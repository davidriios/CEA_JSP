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
ArrayList sec = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String empId = request.getParameter("emp_id");

if (codigo == null) codigo = "";
if (!codigo.equals(""))
{
	appendFilter = " and codigo="+codigo;

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
  String  cedula ="",nombre="",ubic_seccion="",descripcion="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals("") )
  {
    appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    cedula = request.getParameter("cedula");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals("") )
  {
    appendFilter += " and upper(a.primer_nombre||' '||a.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }
  if (request.getParameter("ubic_seccion") != null && !request.getParameter("ubic_seccion").trim().equals("") )
  {
    appendFilter += " and upper(a.ubic_seccion) like '%"+request.getParameter("ubic_seccion").toUpperCase()+"%'";
    ubic_seccion = request.getParameter("ubic_seccion");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("") )
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  


		 sql = "select a.primer_nombre||' '||a.segundo_nombre ||' '|| a.primer_apellido||' '||a.segundo_apellido as apellido, a.num_empleado as numempleado,   a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento cedula, a.provincia, a.sigla, a.tomo, a.asiento, to_char(a.fecha_ingreso,'dd/month/yyyy') as fechaing, a.emp_id, to_char(sysdate,'yyyy') - to_char(a.fecha_ingreso,'yyyy') as anio, to_char(sysdate,'mm') - to_char(a.fecha_ingreso,'mm') as meses, to_char(a.salario_base,'999,999,990.00') as salario, to_char(a.gasto_rep,'99,999,990.00') as gastorep, decode(c.estado,'P','PENDIENTE','A','APROBADO','N','ANULADO') as estado,b.denominacion , e.descripcion as depto,c.codigo, c.motivo_falta as tipos, to_char(c.fecha_inicio,'dd/mm/yyyy') as desdeSalida, to_char(c.fecha_final,'dd/mm/yyyy') as hastaSalida, to_char(c.fecha_retorno,'dd/mm/yyyy') as fechaRetorno, to_char(c.fecha_parto,'dd/mm/yyyy') as fechaParto,  c.cant_dias_pagar as diasPagar, c.CANT_QUINCENAS as quincenaSal, c.CANT_MESES as mesSal, c.CANT_DIAS as diaSal, c.tipo_subsidio, decode(c.motivo_falta,'35','INCAPACIDAD',f.descripcion) as descFalta from tbl_pla_empleado a, tbl_pla_cargo b, tbl_sec_unidad_ejec e, tbl_pla_cc_licencia c, tbl_pla_motivo_falta f where a.compania = b.compania and a.cargo = b.codigo and a.compania = e.compania and a.ubic_depto = e.codigo and a.emp_id = c.emp_id and a.compania = c.compania and c.motivo_falta = f.codigo(+) and a.compania = "+session.getAttribute("_companyId")+" and a.emp_id = "+empId;



	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) from ("+sql+")");
  
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
document.title = 'Recursos Humanos - Licencias Incapacidades Riesgos Prof. - '+document.title;

function Movilidad(tab,empId,accion)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=new&tipo_accion=2&mode=edit&emp_id='+empId+'&tab='+tab);
}

function edit(cod,empid,fec)
{
abrir_ventana1('../rhplanilla/licencia_config.jsp?mode=edit&empid='+empid+'&cod='+cod);
}

function VerMovilidad(tab,empId,accion,tipo,fecha)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=e&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+accion+'&tab='+tab+'&fecha='+fecha);
}
function Ingreso()
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion=1&tab=4');
}

function Egreso(tab,empId)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=e&accion=3&emp_id='+empId+'&tab='+tab);
}
function  printList()
{
abrir_ventana('../rhplanilla/print_list_licencia_emp.jsp?emp_id=<%=empId%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - LICENCIAS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">
	</td>
	</tr>


</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></td>
	</tr>
	<tr>

	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	  <td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
			<% fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<!-- =========================   R E S U L T S   S T A R T   H E R E   ===================== -->
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");	%>
<%=fb.formStart()%>
<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
		<%
	if (al.size()>0)
	{
	CommonDataObject cdo = (CommonDataObject) al.get(0);

	%>
	<tr class="TextHeader" align="center">
		<td colspan="4">&nbsp;<%=cdo.getColValue("apellido")%></td>
	  <td colspan="3">&nbsp;<%=cdo.getColValue("cedula")%></td>
	</tr>
	<%
	}
	%>
	<tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
		<td width="28%">&nbsp;Motivo de Falta</td>
		<td width="12%">&nbsp;Fecha Inicial</td>
		<td width="12%">&nbsp;Fecha Final</td>
		<td width="10%">&nbsp;Cant. de Días</td>
		<td width="12%">&nbsp;Estado</td>
		<td width="8%">&nbsp;Acción</td>
	</tr>

                <%
				String tipoAccion = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 tipoAccion = cdo.getColValue("estado");
				 if (i % 2 == 0) color = "TextRow01";
				 %>
				  <%=fb.hidden("emp_id",cdo.getColValue("emp_id"))%>

				  <%=fb.hidden("accion",cdo.getColValue("subtipo"))%>
				  <%=fb.hidden("tipo",cdo.getColValue("tipo"))%>
				  <%=fb.hidden("codigo",cdo.getColValue("codigo"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("descFalta")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("desdeSalida")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("hastaSalida")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("diasPagar")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado")%></td>
					<td align="center"><a href="javascript:edit('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("desdeSalida")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>
					</td>
				</tr>
	<%
	}
    %>

</table>

<!-- =====================   R E S U L T S   E N D   H E R E   ===================== -->
<%=fb.formEnd()%>
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
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
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
