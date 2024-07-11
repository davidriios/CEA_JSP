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
int iconHeight = 24;
int iconWidth = 24;
String sql = "";
String appendFilter = "";
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String empId = request.getParameter("empId");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");

if (request.getMethod().equalsIgnoreCase("GET"))
{
    if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
	if (grupo == null) throw new Exception("El Código del Grupo no es válido. Por favor intente nuevamente!");
	if ((desde != null) && (hasta != null)) appendFilter = " and ((a.fecha >= to_date('"+desde+"','dd/mm/yyyy') and a.fecha <= to_date('"+hasta+"','dd/mm/yyyy') and (a.aprobado is null or a.aprobado = 'N' )) ) and a.accion <> 'EL' and a.aprobado = 'N' ";


	sql = "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, b.descripcion as mfaltaDesc, decode(a.accion,'ND','No Descontar','Descontar') as estado, a.emp_id, a.motivo as mfalta, c.primer_nombre||' '||c.primer_apellido as nombre, nvl(a.ue_codigo,'0') grupo, a.aprobado as aprobacion FROM tbl_pla_at_det_empfecha a, tbl_pla_motivo_falta b, tbl_pla_empleado c  WHERE a.motivo = b.codigo and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.ue_codigo = "+grupo+" and a.emp_id = c.emp_id and a.ue_codigo = "+grupo+" and a.emp_id = "+empId+" order by a.fecha desc";

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
   var fech;
   var motivo;

   empId = eval('document.formAusencia.emp_id'+k).value;
   grupo = document.formAusencia.grupo.value;
   desde = document.formAusencia.desde.value;
   hasta = document.formAusencia.hasta.value;
   fech = eval('document.formAusencia.fech'+k).value;
   motivo = eval('document.formAusencia.mot'+k).value;


 abrir_ventana1("../rhplanilla/empl_tardanza_config.jsp?empId="+empId+"&grupo="+grupo+"&motivo="+motivo+"&fech='"+fech+"'&desde="+desde+"&hasta="+hasta+"");
}

function view(empId,k,fecha)
{
var fech = "to_date('"+eval('document.formAusencia.fech'+k).value+"','dd/mm/yyyy')";
abrir_ventana("../rhplanilla/reg_marcacion.jsp?fg=tard&mode=view&grupo=<%=grupo%>&area=<%=area%>&iDate="+fech+"&fDate="+fech+"&empId="+empId);
}

</script>
</head>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
        <% fb = new FormBean("formAusencia",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
   		<%=fb.hidden("grupo",grupo)%>
   		<%=fb.hidden("area",area)%>
   		<%=fb.hidden("desde",desde)%>
   		<%=fb.hidden("hasta",hasta)%>

		<% if (al.size() > 0)
    {
	CommonDataObject cdo1 = (CommonDataObject) al.get(0);

	%>

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="15%">Ausencias de:</td>
			<td width="40%"><%=cdo1.getColValue("Nombre")%></td>
			<td width="15%"></td>
			<td width="10%">Grupo : <%=cdo1.getColValue("Grupo")%></td>
			<td width="10%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
		</tr>
	<%

			}
	%>



		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="15%">Fecha</td>
			<td width="40%">Motivo</td>
			<td width="15%">Acci&oacute;n</td>
			<td width="10%">Devoluci&oacute;n</td>
			<td width="10%">&nbsp;</td>
			<td width="10%">Marcacion</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("fech"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("mot"+i,cdo.getColValue("mfalta"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("Fecha")%></td>
			<td><%=cdo.getColValue("mfaltaDesc")%></td>
			<td><%=cdo.getColValue("estado")%></td>
			<td>&nbsp;</td>
			<td align="center"><a href="javascript:edit(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
			<td align="center"><authttype type='1'><a href="javascript:view(<%=cdo.getColValue("emp_id")%>,<%=i%>,<%=cdo.getColValue("fecha")%>)"><img src="../images/clock.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Ver Marcaciones"></a></authtype>&nbsp;</td>
		</tr>
<%
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    <%=fb.formEnd()%>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
