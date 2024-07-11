
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

==============================================================================================
==============================================================================================
**/
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
int iconHeight = 20;
int iconWidth = 20;

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

  if (request.getParameter("cedula") != null && !request.getParameter("cedula").equals(""))
  {
    appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    searchOn = "provincia||'-'||sigla||'-'||tomo||'-'||asiento";
    searchVal = request.getParameter("cedula");
    searchType = "1";
    searchDisp = "Cédula";
  }
  else if (request.getParameter("emp_id") != null && !request.getParameter("emp_id").equals(""))
  {
    appendFilter += " and a.emp_id = "+request.getParameter("emp_id");
  }
  else if (request.getParameter("nombre") != null && !request.getParameter("nombre").equals(""))
  {
    appendFilter += " and upper(a.primer_nombre||' '||a.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "primer_nombre||' '||primer_apellido";
    searchVal = request.getParameter("nombre");
    searchType = "1";
    searchDisp = "Nombre";
  }

  else if (request.getParameter("ubic_seccion") != null && !request.getParameter("ubic_seccion").equals(""))
  {
    appendFilter += " and upper(a.ubic_seccion) like '%"+request.getParameter("ubic_seccion").toUpperCase()+"%'";
    searchOn = "ubic_seccion";
    searchVal = request.getParameter("ubic_seccion");
    searchType = "1";
    searchDisp = "Seccion";
  }
  else if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals(""))
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripcion";
  }
  
	sql="select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania,  a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido, nvl(c.ubic_rhseccion_dest,a.ubic_seccion) as seccion, b.descripcion as descripcion, t.descripcion||' / '||s.descripcion as tipoDesc, s.descripcion subDesc, to_char(c.fecha_doc,'dd/mm/yyyy') as fecha,  c.tipo_accion as tipo, c.sub_t_accion subtipo, c.estado, decode(c.estado,'T','TRAMITE','A','APROBADO','R','RECHAZADO','N','NULO','P','PROCESADO','E','EJECUTADA') as estado_dsp, c.fecha_efectiva, to_char(c.fecha_efectiva,'dd/mm/yyyy') as fEfectiva, (case when c.tipo_accion = 1 then 4 when c.tipo_accion = 2 then 0 when c.tipo_accion = 3 then 3  end) tab from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ap_accion_per c, tbl_pla_ap_tipo_accion t, tbl_pla_ap_sub_tipo s where a.compania = b.compania and a.emp_id = c.emp_id(+) and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = b.codigo and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = "+empId+" and c.tipo_accion = t.codigo and c.sub_t_accion = s.codigo and t.codigo =s.tipo_accion order by c.fecha_efectiva";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ap_accion_per c, tbl_pla_ap_tipo_accion t, tbl_pla_ap_sub_tipo s where a.compania = b.compania and a.emp_id = c.emp_id(+) and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = b.codigo  and c.compania = b.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = "+empId+" and c.tipo_accion = t.codigo and c.sub_t_accion = s.codigo and t.codigo =s.tipo_accion");

	sql="select codigo, descripcion  from  tbl_sec_unidad_ejec where nivel = 3 and compania="+(String) session.getAttribute("_companyId")+" order by codigo";
	sec = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

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
document.title = 'Recursos Humanos - Acción de Personal - '+document.title;

function Movilidad(tab,empId,accion)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=new&tipo_accion=2&mode=edit&emp_id='+empId+'&tab='+tab);
}

function VerMovilidad(tab,empId,accion,tipo,fecha, i, mode)
{
var fp='';
if(tab==4){
	var prov = eval('document.form0.prov'+i).value;
	var sigla = eval('document.form0.sigla'+i).value;
	var tomo = eval('document.form0.tomo'+i).value;
	var asiento = eval('document.form0.asiento'+i).value;
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion='+tipo+'&mode='+mode+'&emp_id='+empId+'&sub_tipo_accion='+accion+'&tab='+tab+'&fecha_doc='+fecha+'&prov='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento);
	fp='ingreso';
}else{
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&tipo_accion='+tipo+'&mode='+mode+'&emp_id='+empId+'&sub_tipo_accion='+accion+'&tab='+tab+'&fecha_doc='+fecha);
}
}
function Ingreso()
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion=1&tab=4');
}

function Egreso(tab,empId)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=e&tipo_accion=3&emp_id='+empId+'&tab='+tab);
}
function  printList()
{
abrir_ventana('../rhplanilla/print_list_accionmove.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function editExp(i,empId)
{
	var prov = eval('document.form0.prov'+i).value;
	var sigla = eval('document.form0.sigla'+i).value;
	var tomo = eval('document.form0.tomo'+i).value;
	var asiento = eval('document.form0.asiento'+i).value;
abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?fg=reIngreso&mode=edit&fp=rrhh&emp_id='+empId+'&prov='+prov+'&sig='+sigla+'&tom='+tomo+'&asi='+asiento);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - ACCIONES DE PERSONAL "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
		</td>
	</tr>
	<tr>

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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");	%>
<%=fb.formStart()%>

<!-- =========================   R E S U L T S   S T A R T   H E R E   ===================== -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
		<td width="30%">&nbsp;Departamento</td>
		<td width="10%">&nbsp;Fecha Accion</td>
		<td width="30%">&nbsp;Tipo / Sub Tipo Accion</td>
		<td width="10%">&nbsp;Estado</td>
		<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>

	</tr>
                <%
				String descripcion = "";
				String tipoAccion = "2";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
					tipoAccion = cdo.getColValue("tipo");
				 if (!descripcion.equalsIgnoreCase(cdo.getColValue("nombre")))
				 {
				%>

					 <tr align="left" class="TextHeader02">
                      <td colspan="8" class="TitulosdeTablas"> [<%=cdo.getColValue("cedula")%>] - <%=cdo.getColValue("nombre")%></td>
                   </tr>
				<%
				   }
				  %>
					 <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
					  <%=fb.hidden("accion",cdo.getColValue("subtipo"))%>
					  <%=fb.hidden("tipo",cdo.getColValue("tipo"))%>

					  <%=fb.hidden("prov"+i,cdo.getColValue("provincia"))%>
					  <%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
					  <%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
					  <%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;[<%=cdo.getColValue("seccion")%>]&nbsp;-&nbsp;<%=cdo.getColValue("descripcion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fEfectiva")%></td>
					<td>&nbsp;<%=cdo.getColValue("tipoDesc")%></td>
					<td>&nbsp;<%=cdo.getColValue("estado_dsp")%></td>
					<td align="center">
						<% //if (cdo.getColValue("estado").equalsIgnoreCase("R")&&!cdo.getColValue("estado").equalsIgnoreCase("P")&&!cdo.getColValue("estado").equalsIgnoreCase("A"))
						if (cdo.getColValue("estado").equalsIgnoreCase("T"))  {%>
						<authtype type='4'>
	        			<a href="javascript:VerMovilidad('<%=cdo.getColValue("tab")%>','<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("subtipo")%>','<%=cdo.getColValue("tipo")%>','<%=cdo.getColValue("fecha")%>', <%=i%>,'edit')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
	        	<% } else {%><authtype type='1'>
	        			<a href="javascript:VerMovilidad('<%=cdo.getColValue("tab")%>','<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("subtipo")%>','<%=cdo.getColValue("tipo")%>','<%=cdo.getColValue("fecha")%>', <%=i%>, 'view')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype>
	        	<%}%>
					</td>
					<td align="center">
						<% if (cdo.getColValue("estado").equalsIgnoreCase("T")&&cdo.getColValue("tab").equalsIgnoreCase("4")) {%>
<authtype type='54'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/check.gif" style="text-decoration:none; cursor:pointer" onMouseOver="" onMouseOver="javascript:displayElementValue('optDesc','Actualizar Expediente')" title="Actualizar Expediente" onMouseOut="javascript:displayElementValue('optDesc','Actualizar Expediente')" onClick="javascript:editExp(<%=i%>,<%=cdo.getColValue("emp_id")%>)"></authtype>
	        	<% }%>
					</td>
				</tr>
      <%descripcion =cdo.getColValue("nombre");
      }%>

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
	