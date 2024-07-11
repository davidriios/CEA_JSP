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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String grupo = request.getParameter("grupo");
String empId = request.getParameter("empId");
String mode = request.getParameter("mode");
String filtro ="PE";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
if (grupo == null) throw new Exception("El Código del Grupo no es válido. Por favor intente nuevamente!");

sql = "select to_char(a.periodof_inicio,'dd/mm/yyyy') fechai, to_char(a.periodof_final,'dd/mm/yyyy') fechaf, to_char(a.fecha_solicitud,'dd/mm/yyyy') as resuelto, a.anio , c.num_empleado as numEmp, a.dias_tiempo as tiempo, a.tipo, a.codigo, a.estado, a.observacion, a.dias_dinero as dinero, a.emp_id, c.primer_nombre||' '||c.primer_apellido as nombre,  a.provincia||'-'||a.sigla||'-'||a.tomo||' '||a.asiento cedula, c.num_empleado numEmp, decode(a.estado,'AP','APROBADA','PE','PENDIENTE','PR','PROCESADA','RE','RECHAZADA','AN','ANULADA') as estadoDesc from tbl_pla_sol_vacacion a,  tbl_pla_empleado c  where a.compania = "+(String) session.getAttribute("_companyId")+" and  a.emp_id = c.emp_id and a.compania = c.compania and  a.emp_id = "+empId+" order by a.fecha_solicitud desc";

al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function edit(k,flag)
{
   var empId;
   var grupo;
   var res="";
   var fg=""+flag;
  ///var r = eval('document.formSolicitud.resuelto').value ;
   var anio="";

   empId    = eval('document.formSolicitud.emp_id'+k).value;
   grupo    = document.formSolicitud.grupo.value;
   res      = eval('document.formSolicitud.cod'+k).value;
   anio     = eval('document.formSolicitud.anio'+k).value;
if(fg=="edit") 
  abrir_ventana1('../rhplanilla/empl_solicitud_config.jsp?anio='+anio+'&empId='+empId+'&grupo='+grupo+'&res='+res+'&fp=rrhh');
else 
abrir_ventana1('../rhplanilla/empl_solicitud_config.jsp?mode='+fg+'&anio='+anio+'&empId='+empId+'&grupo='+grupo+'&res='+res+'&fp=rrhh');
}

function aprobar(k)
{
   var empId;
   var grupo;
   var res="";
  ///var r = eval('document.formSolicitud.resuelto').value ;
   var anio="";

   empId    = eval('document.formSolicitud.emp_id'+k).value;
   grupo    = document.formSolicitud.grupo.value;
   res      = eval('document.formSolicitud.cod'+k).value;
   anio     = eval('document.formSolicitud.anio'+k).value;

   abrir_ventana1('../rhplanilla/empl_solicitud_config.jsp?mode=edit&fg=ap&anio='+anio+'&empId='+empId+'&grupo='+grupo+'&res='+res+'&fp=rrhh');

}

function imprimir(k)
{
   var empId;
   var grupo;
   var res="";
   var cod =""; 
   var anio="";

   empId    = eval('document.formSolicitud.emp_id'+k).value;
   grupo    = document.formSolicitud.grupo.value;
   res      = eval('document.formSolicitud.res'+k).value;
   anio     = eval('document.formSolicitud.anio'+k).value;
   cod      = eval('document.formSolicitud.cod'+k).value ;
 abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_sol_vacaciones.rptdesign&pCodigo='+cod+'&pAnio='+anio+'&pEmpId='+empId+'&pCtrlHeader=false');
  

}



</script>
</head>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

    <% fb = new FormBean("formSolicitud",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
   	<%=fb.hidden("grupo",grupo)%>
	<% if (al.size() > 0)
    {
	CommonDataObject cdo1 = (CommonDataObject) al.get(0);

	%>

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td colspan="2">Solicitud de Vacaciones de:</td>
			<td colspan="4"><%=cdo1.getColValue("nombre")%></td>
			<td colspan="2">Num. Emp.: <%=cdo1.getColValue("numEmp")%></td>
			<td colspan="1">&nbsp;</td>
			<td colspan="1">&nbsp;</td>
		</tr>
	<%

			}
	%>
		<tr class="TextHeader" align="center">
		   <td width="08%">Codigo</td>
			<td width="05%">Año</td>
			<td width="15%">F.Solicitud</td>
			<td width="12%">Inicio</td>
			<td width="11%">Final</td>
			<td width="08%">Tiempo</td>
			<td width="08%">Dinero</td>
			<td width="13%">Estado</td>
			<td width="8%">Acci&oacute;n</td>
			<td width="13%">Acci&oacute;n</td>

		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
	<%=fb.hidden("res"+i,cdo.getColValue("resuelto"))%>
	<%=fb.hidden("cod"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("resuelto")%></td>
			<td align="center"><%=cdo.getColValue("fechai")%></td>
			<td align="center"><%=cdo.getColValue("fechaf")%></td>
			<td align="center"><%=cdo.getColValue("tiempo")%></td>
			<td align="center"><%=cdo.getColValue("dinero")%></td>
			<td><%=cdo.getColValue("estadoDesc")%></td>

			<%
			if (filtro.equalsIgnoreCase(cdo.getColValue("estado")))
			{
			%>
			<td align="center">
			<authtype type="4"><a href="javascript:edit(<%=i%>,'edit')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype></td>
			<%  } else
			{
			%>

			<td align="center">
			<authtype type="1"><a href="javascript:edit(<%=i%>,'view')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype></td>
			<%
			}
			%>
			

			<%
			if (filtro.equalsIgnoreCase(cdo.getColValue("estado")))
			{
			%>
			<td align="center">
			<authtype type="6"><a href="javascript:aprobar(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar</a></authtype></td>
			<%  } else
			{
			%>
			<td align="center">
			<authtype type="2"><a href="javascript:imprimir(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></authtype></td>
			<%
			}
			%>


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
