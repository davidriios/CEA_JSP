<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");

if (mode == null) mode = "add";
if (fp == null) fp = "";

String expVersion = "1"; 
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (pacId != null && noAdmision != null)
	{ 
		sql = "select a.*, rownum secuencia from (select a.secuencia as noAdmision, to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am') as fechaIngreso, a.categoria, a.tipo_admision as tipoAdmision, c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, b.cds as centroServicio, z.descripcion as centroServicioDesc, a.pac_id pacId, to_char(b.fecha_atencion,'dd/mm/yyyy') fechaAtencion from tbl_adm_admision a, tbl_adm_atencion_cu b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, tbl_cds_centro_servicio z, tbl_adm_paciente p where a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and b.cds=z.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id = p.pac_id and p.exp_id="+pacId+" /*and a.secuencia!="+noAdmision+"*/ order by  /*to_date( to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') */ a.secuencia desc ) a";
		System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Historial de Expediente - "+document.title;

function openExpediente(noAdmision,cds,i)
{
<%
if (fp.equalsIgnoreCase("paciente"))
{
%>
	parent.window.location='..'+top.document.location.pathname.replace('<%=request.getContextPath()%>','')+'?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision+'&fp=paciente&cds='+cds;

<%
}
else
{
%>
	var catId = document.getElementById("catId"+i).value;
	var pacId = document.getElementById("pacId"+i).value;
	var cds = document.getElementById("cds"+i).value;
	var careDate = document.getElementById("fechaAtencion"+i).value;
	
	<% if (expVersion.equalsIgnoreCase("2")) { %>
	parent.window.location = "../expediente/expediente_iconificado.jsp?pacId="+pacId+"&noAdmision="+noAdmision+"&mode=view&cds="+cds+"&estado=P&careDate="+careDate+"&catId="+careDate+"&fp=history";
	<% } else { %>
	<% if (expVersion.equalsIgnoreCase("3")) { %>
	var page='../expediente3.0/expediente.jsp';
	<% } else { %>
	var page='../expediente/expediente_config.jsp';
	<% } %>
	openWin(page+'?mode=view&pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds+'&fp=history&catId='+catId,'expediente_config_history',getPopUpOptions(true,true,true,true));
	<% } %>
	
	
<%
}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" class="TextRow02">
<table width="100%" cellpadding="1" cellspacing="1">
<tr class="TextHeader" align="center">
  <td width="16%" class="Text10"><cellbytelabel id="1">Fecha Ingreso</cellbytelabel></td>
  <td width="4%" class="Text10"><cellbytelabel id="2">No. Adm.</cellbytelabel></td>
  <td width="22%" class="Text10"><cellbytelabel id="3">Categor&iacute;a</cellbytelabel></td>
  <td width="26%" class="Text10"><cellbytelabel id="4">Tipo Admisi&oacute;n</cellbytelabel></td>
  <td width="32%" class="Text10"><cellbytelabel id="5">Centro Servicio</cellbytelabel></td>
</tr>
<%fb = new FormBean("formCat",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%
for (int i=0; i<al.size(); i++)
{
	Admision adm = (Admision) al.get(i);

	if (adm.getFechaIngreso() != null && !adm.getFechaIngreso().trim().equals(""))
	{
%>
<tr class="TextRow03" onClick="javascript:openExpediente(<%=adm.getNoAdmision()%>,<%=adm.getCentroServicio()%>,<%=i%>)" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow03')">
  <td align="center" class="Text10"><%=adm.getFechaIngreso()%></td>
  <td align="center" class="Text10"><%=adm.getNoAdmision()%></td>
  <td class="Text10">[<%=adm.getCategoria()%>] <%=adm.getCategoriaDesc()%></td>
  <td class="Text10">[<%=adm.getTipoAdmision()%>] <%=adm.getTipoAdmisionDesc()%></td>
  <td class="Text10">[<%=adm.getCentroServicio()%>] <%=adm.getCentroServicioDesc()%></td>
</tr>

<%=fb.hidden("catId"+i ,adm.getCategoria())%>
<%=fb.hidden("pacId"+i ,adm.getPacId())%>
<%=fb.hidden("cds"+i ,adm.getCentroServicio())%>
<%=fb.hidden("fechaAtencion"+i ,adm.getFechaAtencion())%>
<%
	}
}
if (al.size() == 0)
{
%>
<tr class="TextRow03">
  <td colspan="5" align="center"><cellbytelabel id="6">No existen admisiones anteriores</cellbytelabel>!!</td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>