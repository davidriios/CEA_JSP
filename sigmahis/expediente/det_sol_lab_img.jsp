<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
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
String key = "";
String sql = "", fgSolX = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fecha = request.getParameter("fecha");
String area = request.getParameter("area");
String solicitado_por = request.getParameter("solicitado_por");
if(solicitado_por!=null && !solicitado_por.equals("")) fgSolX = " and a.cod_sala = "+solicitado_por;
if(fg ==null && fg.trim().equals("")) fg = "";
int total=0;
 
sql = "select decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.nombre_paciente, b.edad, decode(i.tipo_admision,1,nvl(j.abreviatura,j.descripcion)) as dsp_admitido, a.cod_procedimiento, decode(c.observacion,null,c.descripcion,c.observacion) as nombre_procedimiento, c.precio, f.primer_nombre||' '||f.segundo_nombre||' '||f.primer_apellido||' '||f.segundo_apellido as nombre_medico, f.codigo as medico_codigo, nvl(g.cama,' ') as cama, a.estado, nvl(a.comentario,' ') as comentario, nvl(a.observacion, ' ') as observacion, a.prioridad, a.usuario_creac as usuario_creacion, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.codigo, a.csxp_admi_secuencia as admision, a.cod_solicitud, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, b.codigo as cod_paciente, b.pac_id, e.cod_centro_servicio, i.categoria, i.embarazada,(select descripcion from tbl_cds_centro_servicio where codigo=a.cod_centro_servicio)descCds from tbl_cds_detalle_solicitud a, vw_adm_paciente b, tbl_cds_procedimiento c, /*tbl_cds_tipo_dieta d, */tbl_cds_solicitud e, tbl_adm_medico f, tbl_adm_atencion_cu g, tbl_adm_admision i, tbl_cds_centro_servicio j/*,tbl_cds_procedimiento_x_cds k*/ where (a.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz ='"+fg+"')) and a.estado in ('S') and a.estudio_dev='N' and a.estudio_realizado='N' "+(area!=null && !area.equals("")?" and a.cod_centro_servicio="+area:"")+fgSolX+" and trunc(a.fecha_solicitud)=to_date('"+fecha+"','dd/mm/yyyy') and a.pac_id=b.pac_id and a.cod_procedimiento=c.codigo(+)/* and a.cod_tipo_dieta=d.codigo(+)*/ and a.cod_solicitud=e.codigo and a.csxp_admi_secuencia=e.admi_secuencia and a.pac_id=e.pac_id and e.med_codigo_resp=f.codigo and e.admi_secuencia=g.secuencia(+) and e.pac_id=g.pac_id(+) and a.csxp_admi_secuencia=i.secuencia and a.pac_id=i.pac_id and i.centro_servicio=j.codigo and i.estado in ('A','E')/* and c.codigo=k.cod_procedimiento and e.cod_centro_servicio=k.cod_centro_servicio*/ order by i.pac_id, i.secuencia,a.cod_solicitud,a.codigo asc";
al = SQLMgr.getDataList(sql);
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,150);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg","")%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por","")%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("_timer","")%>
<table width="100%" align="center" id="_tblMain">
<tr class="TextHeader" align="center">
	<td colspan="8"><label id="timerMsgTop"></label></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="20%"><cellbytelabel id="1">C&eacute;d./Pasap</cellbytelabel>.</td>
	<td width="30%"><cellbytelabel id="2">Nombre del Paciente</cellbytelabel></td>
	<td width="5%"><cellbytelabel id="3">Edad</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="4">Cama</cellbytelabel></td>
	<td width="20%"><cellbytelabel id="5">Admitido por</cellbytelabel></td>
	<td width="5%"><cellbytelabel id="6">Pend</cellbytelabel>.</td>
	<td width="10%" colspan="2"></td>
</tr>
<tr> 
	<td colspan="8"> 
	<div id="_cMain" class="Container"> 
<div id="_cContent" class="ContainerContent"> 
  <table align="center" width="100%" cellpadding="0" cellspacing="1">

<%
String paciente = "",regCodigo="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdod = (CommonDataObject) al.get(i);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("cod_paciente"+i,cdod.getColValue("cod_paciente"))%>
<%=fb.hidden("fecha_nacimiento"+i,cdod.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdod.getColValue("admision"))%>
<%=fb.hidden("codigo"+i,cdod.getColValue("codigo"))%>
<%=fb.hidden("precio"+i,cdod.getColValue("precio"))%>
<%=fb.hidden("cod_centro_servicio"+i,cdod.getColValue("cod_centro_servicio"))%>
<%=fb.hidden("identificacion"+i,cdod.getColValue("identificacion"))%>
<%=fb.hidden("nombre_paciente"+i,cdod.getColValue("nombre_paciente"))%>
<%=fb.hidden("cama"+i,cdod.getColValue("cama"))%>
<%=fb.hidden("nombre_medico"+i,cdod.getColValue("nombre_medico"))%>
<%=fb.hidden("estado"+i,cdod.getColValue("estado"))%>
<%=fb.hidden("comentario"+i,cdod.getColValue("comentario"))%>
<%=fb.hidden("observacion"+i,cdod.getColValue("observacion"))%>
<%=fb.hidden("prioridad"+i,cdod.getColValue("prioridad"))%>
<%=fb.hidden("usuario_creacion"+i,cdod.getColValue("usuario_creacion"))%>
<%=fb.hidden("fecha_solicitud"+i,cdod.getColValue("fecha_solicitud"))%>
<%=fb.hidden("cantidad"+i,cdod.getColValue("cantidad"))%>
<%=fb.hidden("cod_solicitud"+i,cdod.getColValue("cod_solicitud"))%>
<%=fb.hidden("comentario_cancela"+i,cdod.getColValue(""))%>
<%=fb.hidden("comentario_modifica"+i,cdod.getColValue(""))%>
<%=fb.hidden("embarazada"+i,cdod.getColValue("embarazada"))%>
<%=fb.hidden("categoria"+i,cdod.getColValue("categoria"))%>
<%=fb.hidden("medico_codigo"+i,cdod.getColValue("medico_codigo"))%>
<%=fb.hidden("solicitudPac"+i,cdod.getColValue("solicitudPac"))%>

<%if(!paciente.equals(cdod.getColValue("nombre_paciente"))){%>

	<table width="100%" cellpadding="1" cellspacing="0">
      <tr>
		<td colspan="8">
		 <table width="100%" cellpadding="1" cellspacing="0">
		  <tr class="TextPanel02">
			<td width="20%" align="center"><%=cdod.getColValue("identificacion")%><%=cdod.getColValue("cod_centro_servicio")%></td>
			<td width="30%">&nbsp;<%=cdod.getColValue("nombre_paciente")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("edad")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("cama")%></td>
			<td width="20%">&nbsp;<%=cdod.getColValue("dsp_admitido")%></td>
			<td width="5%" align="center"><img src="<%="../images/"+(cdod.getColValue("prioridad").equals("U")?"lampara_roja.gif":"lampara_blanca.gif")%>"></td>
			<td width="5%" align="right" onClick="javascript:showHide(<%=i%>)" style="text-decoration:none; cursor:pointer">[<font face="Courier New, Courier, mono"><label id="plus<%=i%>" style="display:none">+</label><label id="minus<%=i%>">-</label></font>]&nbsp;</td>
			<td width="5%" align="center"><%//=fb.checkbox("chkProc"+i,""+i,false, false, "", "", "onClick=\"javascript:setValues("+i+");\"")%></td>
		 </tr>
		 </table>
	    </td>
	  </tr>
      <tr id="panel<%=i%>">
	   <td colspan="8">
		<table width="100%" cellpadding="1" cellspacing="0">
		 <tr class="TextHeader01" align="center">
			<td width="%"><cellbytelabel id="7">COD. SOLIC.</cellbytelabel></td>
			<td width="%"><cellbytelabel id="7">CPT Code</cellbytelabel></td>
			<td width="%" align="left"><cellbytelabel id="8">Descripci&oacute;n del Estudio</cellbytelabel></td>
			<td width="%"><cellbytelabel id="9">Estado</cellbytelabel></td>
			<td width="%"><cellbytelabel id="10">Prior</cellbytelabel></td>
			<td width="%"><cellbytelabel id="20">Centro de Servicio</cellbytelabel></td>
		</tr> 
<% regCodigo = ""+i;
	}
%>
<%=fb.hidden("regCancelado"+i,""+regCodigo)%>

		 <tr class="<%=color%>" align="center">
			<td><%=cdod.getColValue("cod_solicitud")%>-<%=cdod.getColValue("codigo")%></td>
			<td><%=cdod.getColValue("cod_procedimiento")%></td>
			<td align="left"><%=cdod.getColValue("nombre_procedimiento")%></td>
			<td><%=fb.select("n_estado"+i,"S=PENDIENTE","",false,true,0,"",null,"")%></td>
			<td><img src="<%="../images/"+(cdod.getColValue("prioridad").equals("U")?"lampara_roja.gif":"lampara_blanca.gif")%>"></td>
			<td align="left"><%=cdod.getColValue("descCds")%></td>
		</tr>
<%
	paciente = cdod.getColValue("nombre_paciente");
	if(!paciente.equals(cdod.getColValue("nombre_paciente")) && i>0){
%>
		</table>
	   </td>
      </tr>
   </table>
   <%}%>
	
<%}%>
  </table>
  </div>
  </div>
 </td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>

<tr class="TextRow02">
	<td colspan="9" class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel id="11">Procedimientos Solicitados</cellbytelabel></td>
</tr>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
%>