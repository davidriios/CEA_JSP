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
==========================================================================================

==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdoE = new CommonDataObject();

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String grupo = request.getParameter("grupo");
String empId = request.getParameter("empId");
String sw = "S";
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");

if (request.getMethod().equalsIgnoreCase("GET"))
{
    if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
	if (grupo == null) throw new Exception("El Código del Grupo no es válido. Por favor intente nuevamente!");
	if ((desde != null) && (hasta != null)) appendFilter = " and (a.fecha >= to_date('"+desde+"','dd/mm/yyyy') and a.fecha <= to_date('"+hasta+"','dd/mm/yyyy'))" ;

	sql = "select e.cedula1 as cedula, e.nombre_empleado, c.emp_id, '['||g.codigo||'] - '||g.descripcion dspGrupo  from tbl_pla_ct_empleado c, tbl_pla_ct_grupo g, vw_pla_empleado e where c.emp_id = "+empId+" and c.compania = "+(String) session.getAttribute("_companyId")+" and c.grupo ="+grupo+" and c.compania = g.compania and c.grupo = g.codigo and e.compania = c.compania and e.emp_id = c.emp_id";
	cdoE = SQLMgr.getData(sql);

	sql = "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, b.descripcion as mfaltaDesc, a.codigo, decode(a.estado,'ND','No Descontar','DS','Descontar','PE','Pendiente','DV','Devolver') as estado, a.emp_id, c.primer_nombre||' '||c.primer_apellido as nombre, nvl(a.ue_codigo,'0') grupo, a.aprobado, a.motivo_lic licencia from tbl_pla_permiso a, tbl_pla_motivo_falta b, tbl_pla_empleado c where a.mfalta=b.codigo and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = c.emp_id and a.compania = c.compania  and a.ue_codigo = "+grupo+" and a.emp_id = "+empId+" order by a.fecha desc";
	al = SQLMgr.getDataList(sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function edit(k)
{
   var empId;
   var grupo;
   var codi;
	 var fecha;

   empId = eval('document.formPermiso.emp_id'+k).value;
   grupo = document.formPermiso.grupo.value;
   codi  = eval('document.formPermiso.cod'+k).value;
	 fecha = eval('document.formPermiso.fecha'+k).value;

   abrir_ventana1('../rhplanilla/empl_permiso_config.jsp?mode=edit&empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha);
}

function aprueba(k)
{
   var empId;
   var grupo;
   var codi;
	 var fecha;

   empId = eval('document.formPermiso.emp_id'+k).value;
   grupo = document.formPermiso.grupo.value;
   codi = eval('document.formPermiso.cod'+k).value;
	 fecha = eval('document.formPermiso.fecha'+k).value;

   abrir_ventana1('../rhplanilla/empl_permiso_config.jsp?empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha);
}

function ver(k)
{
   var empId;
   var grupo;
   var codi;
	 var fecha;

   empId = eval('document.formPermiso.emp_id'+k).value;
   grupo = document.formPermiso.grupo.value;
   codi = eval('document.formPermiso.cod'+k).value;
	 fecha = eval('document.formPermiso.fecha'+k).value;

   abrir_ventana1('../rhplanilla/empl_permiso_config.jsp?mode=view&empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha);
}

function printRep(k)
{
   var empId;
   var grupo;
   var codi;
   var fecha;
	 var lic;

   empId = eval('document.formPermiso.emp_id'+k).value;
   grupo = document.formPermiso.grupo.value;
   codi = eval('document.formPermiso.cod'+k).value;
	 fecha = eval('document.formPermiso.fecha'+k).value;
	 lic  = eval('document.formPermiso.licencia'+k).value;


	if(lic == null || lic == "")
	{
   abrir_ventana1('../rhplanilla/print_permiso.jsp?empId='+empId+'&cod='+codi+'&fecha='+fecha);
	 } else
	 {
	 abrir_ventana1('../rhplanilla/print_permiso_lic.jsp?empId='+empId+'&cod='+codi+'&fecha='+fecha);
	 }
}

</script>
</head>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td align="right" colspan="4">
		<a href="javascript:add()" class="Link00">[ Registrar Nuevo Permiso ]</a>
	</td>
  </tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

    <% fb = new FormBean("formPermiso",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
 	<%=fb.hidden("grupo",grupo)%>
 	<%=fb.hidden("empId",empId)%>
	<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td colspan="6">1P E R M I S O S&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R E G I S T R A D O S</td>
		</td>
		<tr class="TextHeader" align="center">
			<td width="15%"><%=cdoE.getColValue("cedula")%></td>
			<td width="35%"><%=cdoE.getColValue("nombre_empleado")%></td>
			<td colspan="4"><%=cdoE.getColValue("dspGrupo")%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="15%">Fecha</td>
			<td width="35%">Motivo</td>
			<td width="5%">No.</td>
			<td width="17%">Acci&oacute;n</td>
			<td width="10%">&nbsp;</td>
			<td width="18%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";

	if (i % 2 == 0) color = "TextRow01";
%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("cod"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("licencia"+i,cdo.getColValue("licencia"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("mfaltaDesc")%></td>
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td align="center"><%=cdo.getColValue("estado")%></td>
			<%  if (!sw.equalsIgnoreCase(cdo.getColValue("aprobado")) && desde == null)
			{
			%>
			<td align="center"><a href="javascript:edit(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
			<td><a href="javascript:aprueba(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar</a>&nbsp;/&nbsp; <a href="javascript:printRep(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></td>
			<% } else { %>
			<td align="center"><a href="javascript:ver(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></td>
			<td align="center"> <a href="javascript:printRep(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></td>
			<% } %>
		</tr>

<%
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
        <%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
