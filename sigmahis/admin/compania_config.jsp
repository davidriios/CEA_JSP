<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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

String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")) code = "0";
	else
	{
		if (code == null) throw new Exception("La Compañia no es válida. Por favor intente nuevamente!");

		sql = "select a.codigo, a.nombre, a.actividad, a.representante_legal as repreLegal, a.direccion, a.telefono, a.fax, a.email, a.digito_verificador as digito, a.ruc, decode(a.logo,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("companyimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.logo) as logo, a.apartado_postal as apartado, a.zona_postal as zona, a.pais as paisCode, (select b.nombre_pais from vw_sec_regional_location b where b.codigo_pais= a.pais and nivel =0) as pais,(select b.nombre_provincia from vw_sec_regional_location b where b.codigo_pais= a.pais and b.codigo_provincia= a.provincia and nivel =1) as provincia,(select b.nombre_distrito from vw_sec_regional_location b where b.codigo_pais= a.pais and b.codigo_provincia= a.provincia and nivel =2 and b.codigo_distrito=a.distrito ) as distrito,(select b.nombre_corregimiento from vw_sec_regional_location b where b.codigo_pais= a.pais and b.codigo_provincia= a.provincia and nivel =3 and b.codigo_distrito=a.distrito and b.codigo_corregimiento =a.corregimiento ) as corregimiento, a.provincia as provCode,a.distrito as distCode,a.corregimiento as corregiCode,a.porc_farhosp as porcFarma, a.num_patronal as numPatronal,a.cedula_juridica as cedJuridica, a.cedula_natural as cedNatural, a.licencia, a.nombre_corto, a.impuesto, a.impuesto_renta,nvl(a.hospital,'N')as hospital, decode(a.logo_icon,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("companyimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.logo_icon) as logo_icon from tbl_sec_compania a where a.codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title=" Compañia - "+document.title;
function getRegionalLocation(){

  document.compania.paisCode.value = "";
  document.compania.pais.value = "";
  document.compania.provCode.value = "";
  document.compania.provincia.value = "";
  document.compania.distCode.value = "";
  document.compania.distrito.value = "";
  document.compania.corregiCode.value = "";
  document.compania.corregimiento.value ="";
  
  
  
   abrir_ventana1('../admin/ubic_geografica_list.jsp');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - ADMISION - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("compania",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel>Generales de la Compa&ntilde;&iacute;a</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%">
				<%=fb.textBox("codigo",cdo.getColValue("codigo"),false,false,true,5)%>
				<%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,viewMode,40,100)%>
			</td>
			<td width="15%"><cellbytelabel>Licencia</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("licencia",cdo.getColValue("licencia"),false,false,viewMode,40,15)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Actividad</td>
			<td><%=fb.textBox("actividad",cdo.getColValue("actividad"),false,false,viewMode,40)%></td>
			<td><cellbytelabel>D&iacute;gito Verif</cellbytelabel>.</td>
			<td><%=fb.textBox("digito",cdo.getColValue("digito"),false,false,viewMode,5,4)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Representante Legal</cellbytelabel></td>
			<td><%=fb.textBox("repreLegal",cdo.getColValue("repreLegal"),false,false,viewMode,40,100)%></td>
			<td>Ruc.</td>
			<td><%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,viewMode,40,20)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>C&eacute;dula Jur&iacute;dica</cellbytelabel></td>
			<td><%=fb.textBox("cedJuridica",cdo.getColValue("cedJuridica"),false,false,viewMode,40,18)%></td>
			<td><cellbytelabel>N&uacute;mero Patronal</cellbytelabel></td>
			<td><%=fb.textBox("numPatronal",cdo.getColValue("numPatronal"),false,false,viewMode,40,11)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>C&eacute;dula Natural</cellbytelabel></td>
			<td><%=fb.textBox("cedNatural",cdo.getColValue("cedNatural"),false,false,viewMode,40,16)%></td>
			<td>Porc. Farmacia</td>
			<td><%=fb.decBox("porcFarma",cdo.getColValue("porcFarma"),false,false,viewMode,40)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
			<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),true,false,viewMode,40,13)%></td>
			<td><cellbytelabel>Fax</cellbytelabel></td>
			<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,viewMode,40,13)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>E-mail</cellbytelabel></td>
			<td><%=fb.textBox("email",cdo.getColValue("email"),false,false,viewMode,40,100)%></td>
			<td><cellbytelabel>Logo</cellbytelabel></td>
			<td><%=fb.fileBox("logo",cdo.getColValue("logo"),false,viewMode,40)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Apto. Postal</cellbytelabel></td>
			<td><%=fb.textBox("apartado",cdo.getColValue("apartado"),false,false,viewMode,40,20)%></td>
			<td><cellbytelabel>Zona Postal</cellbytelabel></td>
			<td><%=fb.textBox("zona",cdo.getColValue("zona"),false,false,viewMode,40,20)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),true,false,viewMode,40,100)%></td>
			<td><cellbytelabel>Nombre Corto</cellbytelabel></td>
			<td><%=fb.textBox("nombre_corto",cdo.getColValue("nombre_corto"),false,false,viewMode,40,30)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Impuesto</cellbytelabel></td>
			<td><%=fb.decBox("impuesto",cdo.getColValue("impuesto"),true,false,viewMode,10,3.2,null,null,null)%></td>
			<td><cellbytelabel>Impuesto/Renta</cellbytelabel></td>
			<td><%=fb.decBox("impuesto_renta",cdo.getColValue("impuesto_renta"),false,false,viewMode,10,4.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Es Hospital</cellbytelabel></td>
			<td><%=fb.select("hospital","N=NO,S=SI",cdo.getColValue("hospital"),false,false,0,"Text10",null,"",null,"N")%></td>
			<td><cellbytelabel>Logo Icono</cellbytelabel></td>
			<td><%=fb.fileBox("logo_icon",cdo.getColValue("logo_icon"),false,viewMode,40)%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel>Ubicaci&oacute;n Geogr&aacute;fica</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Pa&iacute;s</cellbytelabel></td>
			<td>
				<%=fb.intBox("paisCode",cdo.getColValue("paisCode"),false,false,true,5)%>
				<%=fb.textBox("pais",cdo.getColValue("pais"),false,false,true,40)%>
				<%=fb.button("btnpais","...",true,viewMode,null,null,"onClick=\"javascript:getRegionalLocation()\"")%>
			</td>
			<td><cellbytelabel>Distrito</cellbytelabel></td>
			<td>
				<%=fb.intBox("distCode",cdo.getColValue("distCode"),false,false,true,5)%>
				<%=fb.textBox("distrito",cdo.getColValue("distrito"),false,false,true,40)%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Provincia</cellbytelabel></td>
			<td>
				<%=fb.intBox("provCode",cdo.getColValue("provCode"),false,false,true,5)%>
				<%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,40)%>
			</td>
			<td><cellbytelabel>Corregimiento</cellbytelabel></td>
			<td>
				<%=fb.intBox("corregiCode",cdo.getColValue("corregiCode"),false,false,true,5)%>
				<%=fb.textBox("corregimiento",cdo.getColValue("corregimiento"),false,false,true,40)%>
			</td>
		</tr>
		<tr class="TextRow02">
			<td align="right" colspan="4">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
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
	Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("companyimages"),20);
	String saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
	mode = (String) ht.get("mode");
	code = (String) ht.get("code");
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sec_compania");
	cdo.addColValue("codigo",(String) ht.get("codigo"));
	cdo.addColValue("nombre",(String) ht.get("nombre"));
	cdo.addColValue("actividad",(String) ht.get("actividad"));
	cdo.addColValue("representante_legal",(String) ht.get("repreLegal"));
	cdo.addColValue("direccion",(String) ht.get("direccion"));
	cdo.addColValue("telefono",(String) ht.get("telefono"));
	cdo.addColValue("fax",(String) ht.get("fax"));
	cdo.addColValue("email",(String) ht.get("email"));
	cdo.addColValue("digito_verificador",(String) ht.get("digito"));
	cdo.addColValue("ruc",(String) ht.get("ruc"));
	cdo.addColValue("logo",(String) ht.get("logo"));
	cdo.addColValue("apartado_postal",(String) ht.get("apartado"));
	cdo.addColValue("zona_postal",(String) ht.get("zona"));
	cdo.addColValue("pais",(String) ht.get("paisCode"));
	cdo.addColValue("provincia",(String) ht.get("provCode"));
	cdo.addColValue("distrito",(String) ht.get("distCode"));
	cdo.addColValue("corregimiento",(String) ht.get("corregiCode"));
	cdo.addColValue("porc_farhosp",(String) ht.get("porcFarma"));
	cdo.addColValue("num_patronal",(String) ht.get("numPatronal"));
	cdo.addColValue("cedula_juridica",(String) ht.get("cedJuridica"));
	cdo.addColValue("cedula_natural",(String) ht.get("cedNatural"));
	cdo.addColValue("licencia",(String) ht.get("licencia"));
	cdo.addColValue("nombre_corto",(String) ht.get("nombre_corto"));
	cdo.addColValue("impuesto",(String) ht.get("impuesto"));
	cdo.addColValue("impuesto_renta",(String) ht.get("impuesto_renta"));
	cdo.addColValue("hospital",(String) ht.get("hospital"));
	cdo.addColValue("logo_icon",(String) ht.get("logo_icon"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.setWhereClause("codigo="+ht.get("codigo"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/compania_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/compania_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/compania_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>