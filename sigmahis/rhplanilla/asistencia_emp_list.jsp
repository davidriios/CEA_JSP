
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String ubic_seccion = "";
String cedula = "";
String descripcion = "";
String nombre = "";
String emp = "";

if (codigo == null) codigo = "";	
if (!codigo.equals(""))appendFilter = " and codigo="+codigo;

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

  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
    appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    cedula = request.getParameter("cedula");	
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(a.primer_nombre||' '||a.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");	
  }
  if (request.getParameter("ubic_seccion") != null && !request.getParameter("ubic_seccion").trim().equals(""))
  {
    appendFilter += " and upper(a.ubic_seccion) like '%"+request.getParameter("ubic_seccion").toUpperCase()+"%'";
    ubic_seccion = request.getParameter("ubic_seccion");	
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");	
  }
  
	sql="select distinct(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido, a.ubic_seccion as seccion, b.descripcion as descripcion, a.emp_id as empId, c.descripcion as estado, e.emp_id as filtro, nvl(d.descripcion,'POR DESIGNAR') as descGrupo, nvl(d.codigo,'9999') as codigoGrp from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_estado_emp c, tbl_pla_ct_empleado e , tbl_pla_ct_grupo d   where a.compania = b.compania and a.ubic_seccion = b.codigo and a.estado = c.codigo and a.estado <> 3 and (a.compania = e.compania(+) and a.emp_id = e.emp_id(+) and e.estado(+)<>2) and  a.compania="+(String) session.getAttribute("_companyId")+appendFilter+"  and e.compania = d.compania(+) and e.grupo = d.codigo(+) order by  nvl(d.codigo,'9999'), a.ubic_seccion, a.primer_apellido";
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
document.title = 'Planilla - Expedientes de Empleados - '+document.title;
function edit(prov,sig, tom, asi, id){abrir_ventana('../rhplanilla/emp_config.jsp?mode=edit&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&id='+id);}
function regEmp(id){abrir_ventana('../rhplanilla/emp_config.jsp?mode=regEmp&id='+id);}
function  printList(){abrir_ventana('../rhplanilla/print_list_expediente_empleados.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - CONTROL DE ASISTENCIA EMPLEADO "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">&nbsp;</td>
	</tr>	
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>	
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<tr class="TextFilter">
		<td width="50%">&nbsp;Sección&nbsp;
					<%=fb.textBox("ubic_seccion",ubic_seccion,false,false,false,30,null,null,null)%>
		</td>
		<td width="50%">&nbsp;Descripción
					<%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
		</td>
	</tr>
	<tr class="TextFilter">
		<td width="50%">&nbsp;Cédula&nbsp;&nbsp;
					<%=fb.textBox("cedula",cedula,false,false,false,30,null,null,null)%>
		</td>
		<td width="50%">&nbsp;Nombre &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   
					<%=fb.textBox("nombre",nombre,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>	</td>
	</tr>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	<%=fb.formEnd()%>	
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("nombre",""+nombre)%>
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
				<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("nombre",""+nombre)%>
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
		<td width="20%">&nbsp;C&eacute;dula</td>
		<td width="35%">&nbsp;Nombre</td>
		<td width="15%">&nbsp;Estado</td>
		<td width="15%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
		
	</tr>
                <%
				String descGrupo = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if (!descGrupo.equalsIgnoreCase(cdo.getColValue("codigoGrp")))
				 {
				%>
				   <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
                      <td colspan="5" class="TitulosdeTablas"> [<%=cdo.getColValue("codigoGrp")%>] - <%=cdo.getColValue("descGrupo")%></td>
                   </tr>
				<%
				   }
				  %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%//=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td>&nbsp;<%=cdo.getColValue("estado")%></td>
					<td align="center"><authtype type='4'>	<a href="javascript:edit('<%=cdo.getColValue("provincia")%>','<%=cdo.getColValue("sigla")%>','<%=cdo.getColValue("tomo")%>','<%=cdo.getColValue("asiento")%>','<%=cdo.getColValue("empId")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a> </authtype></td>
					<td align="center">
<%
	emp = cdo.getColValue("empId");
 if (!emp.equalsIgnoreCase(cdo.getColValue("filtro")))
	{
%>
				<authtype type='3'>	<a href="javascript:regEmp(<%=cdo.getColValue("empId")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Registrar</a> </authtype></td>
<%}  else  {%>
			<td>&nbsp;		</td>
			<%
			}
			%>							
				</tr>
                            <%
	descGrupo = cdo.getColValue("codigoGrp");
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
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("nombre",""+nombre)%>
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
				<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("nombre",""+nombre)%>
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

	