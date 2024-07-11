<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
800054	AGREGAR  ACREEDORES DE EMPLEADOS
800055	MODIFICAR ACREEDORES DE EMPLEADOS
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800054") || SecMgr.checkAccess(session.getId(),"800055"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("code","0");
	}
	else
	{
		if (id == null) throw new Exception("El Acreedor del Empleado no es válido. Por favor intente nuevamente!");

		sql = "select a.acreedor_codigo as cot, a.cod_acreedor as code, a.compania, a.estado, a.nombre, a.nombre_corto as namecorto, a.direccion, nvl(a.email,'email@mail.com') as email, a.telefono, a.extension, a.fax, a.observacion, a.fecha_mod, a.usuario_mod, a.frecuencia_pago as frecuencia, a.cod_alterno as alterno, a.cuenta_bancaria as ctas, a.ruta, a.forma_pago as forma, a.generar_cheque as generar, a.tipo_cuenta as tipo, a.ruc, a.digito_verificador as digito, b.ruta as codigo, b.nombre_banco as rutaname, acreedor_codigo cod from tbl_pla_acreedor a, tbl_adm_ruta_transito b  where a.ruta=b.ruta(+) and compania="+(String) session.getAttribute("_companyId")+" and cod_acreedor="+id;
		cdo = SQLMgr.getData(sql);
	}



%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Acreedores de Empleados - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Acreedores de Empleados - Edición - "+document.title;
<%}%>
function rutass()
{
abrir_ventana1('../rhplanilla/list_ruta.jsp');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ACREEDORES DE EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ==================   F O R M   S T A R T   H E R E   ================= -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("cot",cdo.getColValue("cot"))%>
			<%=fb.hidden("code",cdo.getColValue("code"))%>
			<%=fb.hidden("alterno",cdo.getColValue("alterno"))%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01" >
				<td width="17%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="33%">&nbsp;<%=cdo.getColValue("code")%></td>
				<td width="20%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
				<td width="30%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,30,60)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Nombre Corto</cellbytelabel></td>
				<td><%=fb.textBox("nameCorto",cdo.getColValue("nameCorto"),true,false,false,30,50)%></td>
				<td>&nbsp;R.U.C.</td>
				<td><%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,false,30,30)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,30,60)%></td>
				<td>&nbsp;<cellbytelabel>D&iacute;gito Verificador</cellbytelabel></td>
				<td><%=fb.intBox("digito",cdo.getColValue("digito"),false,false,false,15,2)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
				<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
				<td>&nbsp;<cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
				<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,30,11)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Extensi&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("extension",cdo.getColValue("extension"),false,false,false,30,6)%></td>
				<td>&nbsp;<cellbytelabel>Fax</cellbytelabel></td>
				<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,15,11)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Email</cellbytelabel></td>
				<td><%=fb.emailBox("email",cdo.getColValue("email"),false,false,false,30,50)%></td>
				<td><cellbytelabel>&nbsp;Forma de Pago</cellbytelabel></td>
				<td><%=fb.select("forma","1=Cheque,2=ACH",cdo.getColValue("forma"))%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Frecuencia de Pago</cellbytelabel></td>
				<td><%=fb.select("frecuencia","1=I QUINCENA,2=II QUINCENA,3=AMBAS",cdo.getColValue("frecuencia"))%></td>
				<td>&nbsp;<cellbytelabel>Generar Cheque</cellbytelabel></td>
				<td><%=fb.checkbox("generar","S",(cdo.getColValue("generar") != null && cdo.getColValue("generar").equalsIgnoreCase("S")),false)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
				<td><%=fb.textBox("ctas",cdo.getColValue("ctas"),false,false,false,20,17)%></td>
				<td>&nbsp;<cellbytelabel>Tipo de Cuenta</cellbytelabel></td>
				<td><%=fb.select("tipo","A=CTA. AHORRO,C=CTA. CORRIENTE,P=CTA. PERSONAL",cdo.getColValue("tipo"))%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;# <cellbytelabel>Acreedor C&oacute;digo</cellbytelabel></td>
				<td><%=fb.intBox("cod",cdo.getColValue("cod"),false,false,false,20,2)%></td>
				<td>&nbsp;<cellbytelabel>C&oacute;digo Alterno</cellbytelabel></td>
				<td><%=fb.textBox("alterno",cdo.getColValue("alterno"),false,false,false,20,5)%></td>
			</tr>			
			<tr class="TextRow01">
			<td>&nbsp;<cellbytelabel>Ruta</cellbytelabel></td>
			<td><%=fb.intBox("ruta",cdo.getColValue("ruta"),false,false,true,10,9)%><%=fb.textBox("rutaname",cdo.getColValue("rutaname"),false,false,true,25)%><%=fb.button("btncta","Ir",true,false,null,null,"onClick=\"javascript:rutass();\"")%></td>
			<td>&nbsp;<cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
			<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,25,3,40,"","width:100%","")%></td>
			</tr>
			<tr class="TextRow02">
			<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

<!-- =========================   F O R M   E N D   H E R E   ====================== -->

			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_acreedor");
  cdo.addColValue("estado", request.getParameter("estado"));
  cdo.addColValue("nombre",request.getParameter("nombre"));
  cdo.addColValue("nombre_corto",request.getParameter("nameCorto"));

  cdo.addColValue("direccion",request.getParameter("direccion"));
  cdo.addColValue("email",request.getParameter("email"));
  cdo.addColValue("telefono",request.getParameter("telefono"));
  cdo.addColValue("extension",request.getParameter("extension"));
  cdo.addColValue("fax",request.getParameter("fax"));

  cdo.addColValue("observacion",request.getParameter("observacion"));
  cdo.addColValue("fecha_mod",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
  cdo.addColValue("frecuencia_pago",request.getParameter("frecuencia"));
  cdo.addColValue("cuenta_bancaria",request.getParameter("ctas"));
  cdo.addColValue("ruta",request.getParameter("ruta"));
  cdo.addColValue("forma_pago",request.getParameter("forma"));

  if (request.getParameter("generar") == null) cdo.addColValue("generar_cheque","N");
  else cdo.addColValue("generar_cheque",request.getParameter("generar"));
  cdo.addColValue("tipo_cuenta",request.getParameter("tipo"));
  cdo.addColValue("ruc",request.getParameter("ruc"));
  if (request.getParameter("digito") != null)
  cdo.addColValue("digito_verificador",request.getParameter("digito"));

  cdo.addColValue("acreedor_codigo",request.getParameter("cod"));

  cdo.addColValue("cod_alterno",request.getParameter("alterno"));


  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.setAutoIncCol("cod_acreedor");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_acreedor="+request.getParameter("id"));

	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/acredores_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/acredores_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/acredores_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>