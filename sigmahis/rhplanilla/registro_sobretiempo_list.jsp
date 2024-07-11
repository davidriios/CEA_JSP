
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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String estado = request.getParameter("estado");
String cedula = request.getParameter("cedula");
String numero = request.getParameter("numero");
String nombre = request.getParameter("nombre");
String descripcion = request.getParameter("descripcion");
String cargo = request.getParameter("cargo");

if (estado == null) estado = "";
if (cedula == null) cedula = "";
if (numero == null) numero = "";
if (nombre == null) nombre = "";
if (descripcion == null) descripcion = "";
if (cargo == null) cargo = "";

String sqlEstado = "select codigo, descripcion from tbl_pla_estado_emp order by codigo";

String   ubic_seccion="",   rath ="", emp="";
String id = request.getParameter("id");
al = SQLMgr.getDataList(sqlEstado);
for(int i=0;i<al.size();i++){
	CommonDataObject cd = (CommonDataObject) al.get(i);
	codigo = cd.getColValue("codigo");
	break;
}

  if (!cedula.trim().equals(""))
   {
    appendFilter += " and upper(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
   }
   if (!numero.trim().equals(""))
	    {
	     appendFilter += " and upper(b.num_empleado) like '%"+request.getParameter("numero").toUpperCase()+"%'";
   }
  if (!nombre.trim().equals(""))
   {
    appendFilter += " and upper(b.primer_nombre||' '||b.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
   }
  if (request.getParameter("ubic_seccion") != null)
   {
    appendFilter += " and upper(b.ubic_seccion) like '%"+request.getParameter("ubic_seccion").toUpperCase()+"%'";
   }
   if (!estado.trim().equals(""))
   {
   	appendFilter += " and b.estado ='"+request.getParameter("estado")+"'";
   }
   if (!descripcion.trim().equals(""))
   {
    appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
   }
   if (!cargo.trim().equals(""))
   {
    appendFilter += " and upper(c.denominacion) like '%"+request.getParameter("cargo").toUpperCase()+"%'";
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

	sql="select distinct(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, f.descripcion as descripcion, b.emp_id as empId, b.estado, c.denominacion, g.descripcion as estadodesc, b.num_empleado as numEmpleado, nvl(b.rata_hora,'1') as rata, b.ubic_seccion as grupo, e.emp_id as filtro from tbl_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c, tbl_pla_estado_emp g, tbl_pla_t_extraordinario e where b.compania = f.compania and b.ubic_seccion = f.codigo and b.compania = c.compania and b.cargo = c.codigo and b.estado = g.codigo and b.emp_id = e.emp_id(+) and b.compania=e.compania(+) and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.ubic_seccion, b.primer_apellido";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
document.title = 'Planilla - Registro de Transacciones Sobretiempos - '+document.title;

function addNew(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_tran_list.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}

function add(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_sobretiempo_config.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}

function  printList()
{
  abrir_ventana('../rhplanilla/print_list_tipo_transaccion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - TRANSACCION - REGISTRO DE SOBRETIEMPO "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			
			<td width="50%">&nbsp;Nombre del Empleado &nbsp;
													<%=fb.textBox("nombre",nombre,false,false,false,40,null,null,null)%>
						</td>
						<td width="50%" height="22">&nbsp;N&uacute;mero de Empleado&nbsp;&nbsp;&nbsp;&nbsp;
										<%=fb.textBox("numero",numero,false,false,false,10,null,null,null)%>
				</td>
  </tr>

  <tr class="TextFilter">
				<td width="50%" height="22">&nbsp;N&uacute;mero de Cédula&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
											<%=fb.textBox("cedula",cedula,false,false,false,30,null,null,null)%>
					</td>

						    	<td width="50%">&nbsp;Descripción de la Secci&oacute;n
										 <%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
      </td>
	</tr>

  <tr class="TextFilter">
    	<td width="50%">&nbsp;Estado del Empleado&nbsp;
					<%=fb.select(ConMgr.getConnection(), sqlEstado, "estado",estado, "T")%>
      </td>

			<td width="50%">&nbsp;Cargo del Empleado &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("cargo",cargo,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>
      </td>
		<%=fb.formEnd()%>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800058"))
{
%>
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
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
				<%=fb.hidden("ubic_seccion",ubic_seccion)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("numero",numero)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cargo",cargo)%>
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
					<%=fb.hidden("ubic_seccion",ubic_seccion)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("numero",numero)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cargo",cargo)%>
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
		<tbody id="list">
  <tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
		<td width="20%">&nbsp;C&eacute;dula</td>
		<td width="38%">&nbsp;Nombre</td>
		<td width="17%">&nbsp;Num. Empleado</td>
		<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
	</tr>
                <%
				descripcion = "";
				emp ="";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if (!descripcion.equalsIgnoreCase(cdo.getColValue("descripcion")))
				 {
				%>
				   <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
                      <td colspan="6" class="TitulosdeTablas"> [<%=cdo.getColValue("seccion")%>] - <%=cdo.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				  %>
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%//=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("numEmpleado")%></td>
					<%
						emp = cdo.getColValue("empId");
					if (!emp.equalsIgnoreCase(cdo.getColValue("filtro")))
					 { %>
					<td> &nbsp; </td>
					<% } else { %>
					<td align="center">
<a href="javascript:showPopWin('../rhplanilla/reg_sobretiempo_list.jsp?empId=<%=cdo.getColValue("empId")%>&id=<%=i%>',winWidth*.80,_contentHeight*.80,null,null,'');"><font class="BoltText">Ver</font></a> </td>
            <%
             }
           %>

					<td align="center">
				<authtype type='3'>	<a href="javascript:add(<%=cdo.getColValue("provincia")%>,'<%=cdo.getColValue("sigla")%>',<%=cdo.getColValue("tomo")%>,<%=cdo.getColValue("asiento")%>,<%=cdo.getColValue("empId")%>,<%=cdo.getColValue("numEmpleado")%>,<%=cdo.getColValue("rata")%>,<%=cdo.getColValue("grupo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Registrar</a> </authtype>
					</td>

				</tr>
                            <%
	descripcion = cdo.getColValue("descripcion");
	emp = cdo.getColValue("empId");
}
%>
	 </tbody>
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
				<%=fb.hidden("ubic_seccion",ubic_seccion)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("numero",numero)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cargo",cargo)%>
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
					<%=fb.hidden("ubic_seccion",ubic_seccion)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("numero",numero)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cargo",cargo)%>
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
	