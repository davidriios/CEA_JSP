<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="usr" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="UserMgr" scope="page" class="issi.admin.UserMgr"/>
<jsp:useBean id="iProf" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProf" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iCds" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCds" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iUA" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUA" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iUAWH" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUAWH" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iCDSWH" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCDSWH" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iWhInv" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vWhInv" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iGT" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vGT" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iQx" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vQx" scope="session" class="java.util.Vector"/>
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
UserMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("USR");
ArrayList al = new ArrayList();
ArrayList alComp = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String userInfoOnly = request.getParameter("userInfoOnly");
String id = request.getParameter("id");
String key = "";
String tab = request.getParameter("tab");
String change = request.getParameter("change");
int timeout = 30;
try { timeout = Integer.parseInt(java.util.ResourceBundle.getBundle("issi").getString("inactivity.timeout")); } catch (Exception e) {}
if (timeout == 0) timeout = 30;

boolean viewMode = false;
if (mode == null) mode = "add";
if (userInfoOnly == null) userInfoOnly = "N";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";

String nNumber = null;
String nSpecialChar = null;
String specialChar = null;
String minLength = null;
String validDays = "30";
java.util.ResourceBundle rb = java.util.ResourceBundle.getBundle("password");
if (rb != null)
{
	nNumber = rb.getString("nNumber");
	nSpecialChar = rb.getString("nSpecialChar");
	specialChar = rb.getString("specialChar");
	minLength = rb.getString("minLength");
	validDays = rb.getString("validDays");

	if (nNumber == null || nNumber.trim().equals("")) nNumber = "0";
	if (nSpecialChar == null || nSpecialChar.trim().equals("")) nSpecialChar = "0";
	if (specialChar == null) specialChar = "+-*/#$%&()=¡!¿?[]{}";
	if (minLength == null || minLength.trim().equals("")) minLength = "7";
	if (validDays == null || validDays.trim().equals("")) validDays = "30";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	SQL2BeanBuilder sbb = new SQL2BeanBuilder();
	ArrayList alType = sbb.getBeanList(ConMgr.getConnection(),"select id as optValueColumn, description||' ['||code||']' as optLabelColumn, nvl(ref_type,'X') as optTitleColumn from tbl_sec_user_type where status = 'A' order by 2",CommonDataObject.class);
	StringBuffer sbTypeDesc = new StringBuffer();
	for (int i=0; i<alType.size(); i++) {
		if (!((CommonDataObject) alType.get(i)).getOptTitleColumn().equalsIgnoreCase("X")) {
			sbTypeDesc.append(", ");
			sbTypeDesc.append(((CommonDataObject) alType.get(i)).getOptLabelColumn());
		}
	}

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		usr.addColValue("user_name","");
		usr.addColValue("last_pass_change","");
		usr.addColValue("act_from","");
		usr.addColValue("act_until","");
		usr.addColValue("other1","30");
		iProf.clear();
		vProf.clear();
		iCds.clear();
		vCds.clear();
		iUA.clear();
		vUA.clear();
		iUAWH.clear();
		vUAWH.clear();
		iCDSWH.clear();
		vCDSWH.clear();
		iWhInv.clear();
		vWhInv.clear();
		iGT.clear();
		vGT.clear();
		iQx.clear();
		vQx.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select u.*, (case when exists (select null from tbl_sec_user_type t where t.id = decode(u.user_type,' ',-1,u.user_type) and t.ref_type = 'M' ) and exists (select null from tbl_adm_medico m where m.estado = 'I' and m.codigo = u.ref_code) then 'N' else 'S' end) estado_editable from vw_sec_users u where user_id = ");
		sbSql.append(id);
		usr = SQLMgr.getData(sbSql);

		//Compañía x Usuario
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo as company_id, a.nombre as company_name, decode(b.status,null,'I',b.status) as status, decode(b.comments,null,' ',b.comments) as comments, decode(b.company_id,null,' ','U') as action from tbl_sec_compania a, (select * from tbl_sec_user_comp where user_id = ");
		sbSql.append(id);
		sbSql.append(") b where a.codigo = b.company_id(+) and a.estado = 'A' order by 2");
		alComp = SQLMgr.getDataList(sbSql.toString());

		if (change == null)
		{
			iProf.clear();
			vProf.clear();
			iCds.clear();
			vCds.clear();
			iUA.clear();
			vUA.clear();
			iUAWH.clear();
			vUAWH.clear();
			iCDSWH.clear();
			vCDSWH.clear();
			iWhInv.clear();
			vWhInv.clear();
			iGT.clear();
			vGT.clear();
			iQx.clear();
			vQx.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.profile_id, (select profile_name from tbl_sec_profiles where profile_id = a.profile_id) as profile_name from tbl_sec_user_profile a where a.user_id = ");
			sbSql.append(id);
			sbSql.append(" and profile_id != 0 order by a.profile_id");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iProf.put(cdo.getKey(), cdo);
					vProf.addElement(cdo.getColValue("profile_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.cds, nvl(a.comments,' ') as comments, (select descripcion from tbl_cds_centro_servicio where codigo = a.cds) as cdsDesc,(select (select nombre from tbl_sec_compania where codigo =compania_unorg) from tbl_cds_centro_servicio where codigo = a.cds) as companiaDesc  from tbl_sec_user_cds a where a.user_id = ");
			sbSql.append(id);
			sbSql.append(" order by 3");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iCds.put(cdo.getKey(), cdo);
					vCds.addElement(cdo.getColValue("cds"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.compania, a.ua, nvl(a.comments,' ') as comments, (select descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.ua) as uaDesc, (select nombre from tbl_sec_compania where codigo = a.compania) as companiaNombre from tbl_sec_user_ua a where a.user_id = ");
			sbSql.append(id);
			sbSql.append(" order by 5, 4");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iUA.put(cdo.getKey(), cdo);
					vUA.addElement(cdo.getColValue("compania")+"-"+cdo.getColValue("ua"));//vUA.contains(cdo.getColValue("codigo")
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.compania, a.almacen as codigo_almacen, a.comments, (select descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.almacen) as desc_almacen, (select nombre from tbl_sec_compania where codigo = a.compania) as compania_name from tbl_sec_user_almacen a where a.user_id = ");
			sbSql.append(id);
			sbSql.append(" and a.ref_type = 'UA' order by 1, 2");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iUAWH.put(cdo.getKey(), cdo);
					vUAWH.addElement(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.compania, a.almacen as codigo_almacen, a.comments, (select descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.almacen) as desc_almacen, (select nombre from tbl_sec_compania where codigo = a.compania) as compania_name from tbl_sec_user_almacen a where a.user_id = ");
			sbSql.append(id);
			sbSql.append(" and a.ref_type = 'CDS' order by 1, 2");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iCDSWH.put(cdo.getKey(), cdo);
					vCDSWH.addElement(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.compania, a.almacen as codigo_almacen, a.comments, (select descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.almacen) as desc_almacen, (select nombre from tbl_sec_compania where codigo = a.compania) as compania_name from tbl_sec_user_almacen a where a.user_id = ");
			sbSql.append(id);
			sbSql.append(" and a.ref_type = 'INV' order by 1, 2");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iWhInv.put(cdo.getKey(), cdo);
					vWhInv.addElement(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			//Grupo Trabajo
			sbSql = new StringBuffer();
			sbSql.append("select a.grupo, a.usuario, a.compania, a.nombre, nvl(a.observacion,' ') as observacion, (select descripcion from tbl_pla_ct_grupo where codigo = a.grupo and compania = a.compania) as grupo_desc, (select nombre from tbl_sec_compania where codigo = a.compania) as compania_nombre from tbl_pla_ct_usuario_x_grupo a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.user_id = ");
			sbSql.append(id);
			sbSql.append(" order by 6");
			al  = SQLMgr.getDataList(sbSql.toString());
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try {
					iGT.put(cdo.getKey(),cdo);
					vGT.addElement(cdo.getColValue("grupo")+"-"+cdo.getColValue("compania"));
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
			//QUIROFANOS POR USUARIO
			sbSql = new StringBuffer();
			sbSql.append("select a.habitacion, b.descripcion as hab_desc,  a.user_id, a.compania,a.comments,(select descripcion from tbl_cds_centro_servicio where codigo =b.unidad_admin) centro  from tbl_sec_user_quirofano a , tbl_sal_habitacion b where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.user_id = ");
			sbSql.append(id);
			sbSql.append(" and b.compania = a.compania and b.codigo = a.habitacion order by 1");
			al  = SQLMgr.getDataList(sbSql.toString());
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try {
					iQx.put(cdo.getKey(),cdo);
					vQx.addElement(cdo.getColValue("habitacion"));
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}


		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Mantenimiento de Usuario - '+document.title;

function checkUserName(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_users','upper(user_name)=upper(\''+obj.value+'\')','<%=usr.getColValue("user_name")%>');
}

function showProfileList()
{
	abrir_ventana1('../common/check_profile.jsp?fp=user&mode=<%=mode%>&id=<%=id%>');
}

function showCdsList()
{
	abrir_ventana1('../common/check_cds.jsp?fp=user&mode=<%=mode%>&id=<%=id%>');
}

function showUnidadAdmList()
{
	abrir_ventana1('../common/check_unidad_adm.jsp?fp=user&mode=<%=mode%>&id=<%=id%>');
}

function showWhList(type)
{
	abrir_ventana1('../common/check_almacen.jsp?fp=user'+type+'&mode=<%=mode%>&id=<%=id%>');
}
function showHabList(){abrir_ventana1('../common/check_quirofano.jsp?fp=user&mode=<%=mode%>&id=<%=id%>');}

function doAction()
{
<%
	if (tab.equals("0"))
	{
%>
	referencesReadOnly();
<%
	}
		if (request.getParameter("type") != null)
		{
		if (tab.equals("1")){%>	showProfileList();<%}
		else if (tab.equals("2")){%>showCdsList();<%}
		else if (tab.equals("3")){%>showUnidadAdmList();<%}
		else if (tab.equals("4")){%>showWhList('_ua');<%}
		else if (tab.equals("5")){%>showWhList('_cds');<%}
		else if (tab.equals("7")){%>if(setEmployeeData()){showWhList('_inv');}<%}
		else if (tab.equals("8")){%>showGTList(<%=tab%>);<%}
		else if (tab.equals("9")){%>showHabList();<%}
	}
%>
}

function checkUserType(userType)
{
	var previousRefType=document.form0.refType.value;
	var refType=getSelectedOptionTitle(document.form0.userType,'');
	if (refType=='X')refType='';
	document.form0.refType.value=refType;
	if((previousRefType==''&&refType!='')||(previousRefType=='E'&&(refType=='M'||refType=='A'))||(previousRefType=='M'&&(refType=='E'||refType=='A'))||(previousRefType=='A'&&(refType=='M'||refType=='E')))
	{
		if(refType!='A')document.form0.name.value='';
		document.form0.refCode.value='';
		document.form0.refCodeDisplay.value='';
	}
	referencesReadOnly();
}

function referencesReadOnly()
{
	var refType=document.form0.refType.value;
	if(refType!='')
	{
		document.form0.name.readOnly=!(refType=='A');
		document.form0.refCodeDisplay.readOnly=true;
	}
	else
	{
		document.form0.name.readOnly=false;
		document.form0.refCodeDisplay.readOnly=false;
	}
}

function isValidPassword(){
	pass=document.form0.password.value;
	confirmPass=document.form0.confirmPassword.value;
	if(pass.trim()!=''){
		var errors=[];
		if(confirmPass.trim()==''){errors.push('Por favor confirmar la Contraseña!');document.form0.confirmPassword.focus();}
		else if(pass.trim()!=confirmPass.trim()){errors.push('La Contraseña es diferente a la confirmación!');document.form0.confirmPassword.focus();}
		<% if (rb != null) { %>
		else{
			if(pass.length<<%=minLength%>||pass.search(/[\s]/g)>=0){errors.push('- Mínimo <%=minLength%> carácteres (sin espacios)');}
			if(pass.search(/[a-záéíóúàèìòùäëïöüñ]/gi)<0){errors.push('- Letras');}
			if(<%=nNumber%>>0&&pass.replace(/[^0-9]/g,'').length<<%=nNumber%>){errors.push('- Mínimo <%=nNumber%> número(s)');}
			if(<%=nSpecialChar%>>0&&pass.replace(/[^<%=specialChar.replaceAll("\\\\","\\\\\\\\").replaceAll("]","\\\\]").replaceAll("-","\\\\-")%>]/g,'').length<<%=nSpecialChar%>){errors.push('- Mínimo <%=nSpecialChar%> carácter(es) especial(es) [ <%=specialChar%> ]');}
			if(errors.length>0)errors.unshift('La contraseña debe contener lo siguiente:');
		}
		<% } %>
		if(errors.length>0){alert(errors.join("\n"));return false;}
	}
	return true;
}
function isValidRefId()
{
	var id =document.form0.id.value;
	var refType =document.form0.refType.value;
	var refCode =document.form0.refCode.value;
	var status =document.form0.status.value;
	var oldStatus =document.form0.oldStatus.value;
	if(status =='A'){
	if(refType.trim()=='E'||refType.trim()=='M')
	{
		var cantidad = getDBData('<%=request.getContextPath()%>','count(*) as cantidad','tbl_sec_users','ref_code = \''+refCode+'\' and user_status = \'A\' and user_type in (select id from tbl_sec_user_type where ref_type = \''+refType+'\')','')
		if(parseInt(cantidad) >= 1 && oldStatus=='I')
		{
		alert('Ya existe un USUARIO ACTIVO con esta referencia!');
				return false;
		}
//select count(*) from tbl_sec_users where  ref_code = '520' and user_type in (select id from tbl_sec_user_type where ref_type = 'E') and user_status = 'A'
	}
	}
	return true;
}


function showList()
{
	var refType=document.form0.refType.value;
	if(refType=='E')abrir_ventana1('../common/search_empleado.jsp?fp=user&userId=<%=id%>');
	else if(refType=='M')abrir_ventana1('../common/search_medico.jsp?fp=user&userId=<%=id%>');
	else if(refType=='A')abrir_ventana1('../common/search_empresa.jsp?fp=user&userId=<%=id%>');
	else alert('Sólo aplica si es <%=sbTypeDesc.replace(0,2,"")%>!');
}
function selUsers()
{abrir_ventana1('../common/check_user.jsp?fp=user');}
function checkCompAction(k){if(eval('document.form6.compAction'+k).value.trim()=='')eval('document.form6.compAction'+k).value=(eval('document.form6.status'+k).value=='A')?'I':' ';}
function setEmployeeData()
{
	if('<%=usr.getColValue("user_type")%>'=='1')
	{
		return true;
	}
	else
	{
		alert('Solo se pueden asignar Almacenes para los Tipos de Usuarios Empleado!');
		return false;
	}
}
function showGTList(){abrir_ventana1('../common/check_grupo.jsp?fp=user&mode=<%=mode%>&id=<%=id%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - MANTENIMIENTO DE USUARIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("userInfoOnly",userInfoOnly)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
<%=fb.hidden("refType",usr.getColValue("ref_type"))%>
<%fb.appendJsValidation("if(checkUserName(document.form0.user))error++;");%>
<%fb.appendJsValidation("if(!isValidPassword())error++;");%>
<%fb.appendJsValidation("if(!isValidRefId())error++;");%>
<%fb.appendJsValidation("if(document.form0.default_compania.value==''){alert('Por favor seleccione la Compañía Designada!');error++;}");%>

				<tr class="TextRow02">
					<td colspan="4" align="right"><%=(viewMode || mode.equalsIgnoreCase("add"))?"":"** Dejar en blanco para conservar la contrase&ntilde;a actual"%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Tipo Usuario</cellbytelabel></td>
					<td><%=fb.select("userType",alType,usr.getColValue("user_type"),false,false,0,null,null,"onChange=\"javascript:checkUserType(this.value)\"",null," ")%></td>
					<td align="right"><cellbytelabel>Departamento</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"select id, code||' - '||name from tbl_sec_department where status = 'A' order by 2","department",usr.getColValue("department"),false,false,0," ")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Nombre</cellbytelabel></td>
					<td><%=fb.textBox("name",usr.getColValue("name"),true,viewMode,false,50,100,null,null,"")%></td>
					<td align="right"><cellbytelabel>Referencia</cellbytelabel></td>
					<td>
					<%=fb.hidden("refCode",usr.getColValue("ref_code"))%>
					<%=fb.textBox("refCodeDisplay",usr.getColValue("ref_code_display"),true,viewMode,false,15,15,null,null,"")%>
					<%=fb.button("btnList","...",true,false,null,null,"onClick=\"javascript:showList()\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td width="12%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
					<td width="38%"><%=fb.textBox("user",usr.getColValue("user_name"),true,viewMode,(!mode.equalsIgnoreCase("add")),15,15,null,null,"onBlur=\"javascript:checkUserName(this)\"")%></td>
					<td width="12%" align="right"><% if (mode.equalsIgnoreCase("edit")) { %><%=fb.checkbox("requestNewPassword","Y",false,false)%><% } %></td>
					<td width="38%"><% if (mode.equalsIgnoreCase("edit")) { %><label for="requestNewPassword"><cellbytelabel>Solicitar Cambio de Contrase&ntilde;a</cellbytelabel></label><% } %></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><%=(viewMode || mode.equalsIgnoreCase("add"))?"":"** "%>Contrase&ntilde;a</td>
					<td><%=fb.passwordBox("password","",(mode.equalsIgnoreCase("add")),viewMode,false,30)%> Ultimo Cambio <%=usr.getColValue("last_pass_change")%></td>
					<td align="right"><cellbytelabel>Confimar Contrase&ntilde;a</cellbytelabel></td>
					<td><%=fb.passwordBox("confirmPassword","",(mode.equalsIgnoreCase("add")),viewMode,false,30)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Reportes a</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"select user_id, name from tbl_sec_users where user_id != 0 order by name","reportTo",usr.getColValue("user_report_to"),false,viewMode,0)%></td>
					<td align="right" rowspan="5"><cellbytelabel>Comentarios</cellbytelabel></td>
					<td rowspan="5"><%=fb.textarea("comments",usr.getColValue("comments"),false,false,viewMode,60,5,2000,"","width:100%","")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Perfil Designado</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"select profile_id, profile_name from tbl_sec_profiles where profile_id != 0 order by profile_name","profileId",usr.getColValue("default_profile"),false,viewMode,0)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>e-mail</cellbytelabel></td>
					<td><%=fb.emailBox("email",usr.getColValue("user_email_id"),false,viewMode,false,40)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
					<td>
						<%=fb.select("status",(usr.getColValue("estado_editable")!=null && usr.getColValue("estado_editable").equals("N")?"I=Inactivo":"A=Activo,I=Inactivo"),usr.getColValue("user_status"),false,viewMode,0)%>
						<%=fb.hidden("oldStatus",usr.getColValue("user_status"))%>
						<%//=((usr.getColValue("user_status").equalsIgnoreCase("A"))?"Activo":"Inactivo")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td align="right">&nbsp;</td>
					<td><% if (UserDet.getUserProfile().contains("0")) { %><%=fb.checkbox("show_access","Y",(usr.getColValue("show_access") != null && usr.getColValue("show_access").equalsIgnoreCase("Y")),viewMode)%><label for="show_access"><cellbytelabel>Mostrar Accesos Controlados en la aplicaci&oacute;n</cellbytelabel></label><% } %>&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Bloqueado</cellbytelabel></td>
					<td><%=fb.select("block_status","N=No,Y=Si",usr.getColValue("block_status"),false,viewMode,0)%></td>
					<td align="right" rowspan="2"><cellbytelabel>Raz&oacute;n de Bloqueo</cellbytelabel></td>
					<td rowspan="2"><%=fb.textarea("block_reason",usr.getColValue("block_reason"),false,false,viewMode,60,2,100,"","width:100%","")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Tiempo Expiraci&oacute;n</cellbytelabel></td>
					<td><%=fb.select("other1","15=15 MINUTOS,30=30 MINUTOS,60=1 HORA,120=2 HORAS",usr.getColValue("other1"),false,false,viewMode,0,null,null,null,null,"S")%> Si no selecciona asignar&aacute; <%=timeout%> minutos</td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Compa&ntilde;&iacute;a Designada</cellbytelabel></td>
					<td colspan="3">
						<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,5,'0')||' - '||nombre from tbl_sec_compania where estado != 'I' order by nombre","default_compania",usr.getColValue("default_compania"),false,viewMode,0,null,null,null,null,"S")%>
						<cellbytelabel>Esta es la compa&ntilde;&iacute;a con la cual el usuario iniciar&aacute; el sistema</cellbytelabel>.
					</td>
				</tr>
				<%if(mode.trim().equals("add")){%>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Copiar Informaci&oacute;n de</cellbytelabel>:</td>
					<td colspan="3"><%=fb.textBox("userCopy","",false,false,true,15,15,null,null,"")%>
							<%=fb.textBox("userCopyDesc","",false,viewMode,true,30,null,null,"")%>
						<%=fb.button("addUs","...",true,viewMode,null,null,"onClick=\"javascript:selUsers()\"","Seleccionar usuario")%>
						</td>
				</tr>
				<%}%>
				<tr>
					<td colspan="4" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Para activar como cuenta temporal (No utilizar para cuentas permanentes)</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td colspan="4">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Inicia</cellbytelabel></td>
							<td width="35%">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="nameOfTBox1" value="act_from"/>
								<jsp:param name="valueOfTBox1" value="<%=usr.getColValue("act_from")%>"/>
								<jsp:param name="clearOption" value="true"/>
								</jsp:include>
							</td>
							<td width="15%" align="right"><cellbytelabel>Finaliza</cellbytelabel></td>
							<td width="35%">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="nameOfTBox1" value="act_until"/>
								<jsp:param name="valueOfTBox1" value="<%=usr.getColValue("act_until")%>"/>
								<jsp:param name="clearOption" value="true"/>
								</jsp:include>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="4">
						<jsp:include page="../common/bitacora.jsp" flush="true">
						<jsp:param name="audCollapsed" value="y"></jsp:param>
						<jsp:param name="audTable" value="tbl_sec_users"></jsp:param>
						<jsp:param name="audFilter" value="<%="user_id="+id%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("userName",usr.getColValue("user_name"))%>
<%=fb.hidden("name",usr.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
<%=fb.hidden("profileId",usr.getColValue("default_profile"))%>
				<tr class="TextRow02">
					<td align="right">* Perfil Designado</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Perfiles</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="75%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addProf","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Perfiles")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iProf);
for (int i=0; i<iProf.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iProf.get(key);
%>
						<%=fb.hidden("profile_id"+i,cdo.getColValue("profile_id"))%>
						<%=fb.hidden("profile_name"+i,cdo.getColValue("profile_name"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("profile_id")%></td>
							<td><%=cdo.getColValue("profile_name")%></td>
							<td align="center"><%=(cdo.getColValue("profile_id").trim().equals(usr.getColValue("default_profile")))?"*":fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%}
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("userName",usr.getColValue("user_name"))%>
<%=fb.hidden("name",usr.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centros de Servicios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="20%"><cellbytelabel>Compañia</cellbytelabel></td>
							<td width="35%"><cellbytelabel>Comentarios</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addCds","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Centros de Servicios")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iCds);
for (int i=0; i<iCds.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iCds.get(key);
%>
						<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
						<%=fb.hidden("cdsDesc"+i,cdo.getColValue("cdsDesc"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%if(cdo.getAction().equalsIgnoreCase("D")){%>
						<%=fb.hidden("comments"+i,cdo.getColValue("comments"))%>
						<%}if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("cds")%></td>
							<td><%=cdo.getColValue("cdsDesc")%></td>
							<td align="center"><%=cdo.getColValue("companiaDesc")%></td>
							<td align="center"><%=fb.textBox("comments"+i,cdo.getColValue("comments"),false,viewMode,false,50)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%}
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>



<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("userName",usr.getColValue("user_name"))%>
<%=fb.hidden("name",usr.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Unidades Administrativas</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel31">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Unidad</cellbytelabel></td>
							<td><cellbytelabel>Comentarios</cellbytelabel></td>
							<td><%=fb.submit("addUnidadAdm","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Unidades Administrativas")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iUA);
for (int i=0; i<iUA.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iUA.get(key);
%>
						<%=fb.hidden("ua"+i,cdo.getColValue("ua"))%>
						<%=fb.hidden("uaDesc"+i,cdo.getColValue("uaDesc"))%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("companiaNombre"+i,cdo.getColValue("companiaNombre"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%if(cdo.getAction().equalsIgnoreCase("D")){%>
						<%=fb.hidden("comments"+i,cdo.getColValue("comments"))%>
						<%}if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td width="5%"><%=cdo.getColValue("compania")%></td>
							<td width="30%"><%=cdo.getColValue("companiaNombre")%></td>
							<td width="5%"><%=cdo.getColValue("ua")%></td>
							<td width="25%"><%=cdo.getColValue("uaDesc")%></td>
							<td width="30%"align="center"><%=fb.textBox("comments"+i,cdo.getColValue("comments"),false,viewMode,false,35)%></td>
							<td width="5%" align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%}}%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>



<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel40">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Almacenes</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel41">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
							<td width="35%" rowspan="2"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
							<td width="5%" rowspan="2"><%=fb.submit("addUaWh","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Almacenes de Unidades Administrativas")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Comentarios</cellbytelabel></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iUAWH);
for (int i=0; i<iUAWH.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iUAWH.get(key);
%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("compania_name"+i,cdo.getColValue("compania_name"))%>
						<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
						<%=fb.hidden("desc_almacen"+i,cdo.getColValue("desc_almacen"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>

						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("compania")%></td>
							<td><%=cdo.getColValue("compania_name")%></td>
							<td><%=cdo.getColValue("codigo_almacen")%></td>
							<td><%=cdo.getColValue("desc_almacen")%></td>
							<td align="center"><%=fb.textBox("comments"+i,cdo.getColValue("comments"),false,viewMode,false,50)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%}}%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>



<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel50">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(51)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Almacenes Por centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51" style="display:none">+</label><label id="minus51">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel51">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
							<td width="35%" rowspan="2"><cellbytelabel>Comentarios</cellbytelabel></td>
							<td width="5%" rowspan="2"><%=fb.submit("addCdsWh","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Almacenes de Centros de Servicios")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iCDSWH);
for (int i=0; i<iCDSWH.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iCDSWH.get(key);
%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("compania_name"+i,cdo.getColValue("compania_name"))%>
						<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
						<%=fb.hidden("desc_almacen"+i,cdo.getColValue("desc_almacen"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%if(cdo.getAction().equalsIgnoreCase("D")){%>
						<%=fb.hidden("comments"+i,cdo.getColValue("comments"))%>
						<%}else if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("compania")%></td>
							<td><%=cdo.getColValue("compania_name")%></td>
							<td><%=cdo.getColValue("codigo_almacen")%></td>
							<td><%=cdo.getColValue("desc_almacen")%></td>
							<td align="center"><%=fb.textBox("comments"+i,cdo.getColValue("comments"),false,viewMode,false,50)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%}}%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>


<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("compSize",""+alComp.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Compa&ntilde;&iacute;as</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel61">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="15%"><cellbytelabel>Estado</cellbytelabel></td>
							<td width="45%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
							<td width="3%">&nbsp;</td>
						</tr>
<%
for (int i=0; i<alComp.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) alComp.get(i);
	String style = (cdo.getColValue("action").equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
	boolean isDefault = false;
	if (cdo.getColValue("company_id").trim().equals(usr.getColValue("default_compania"))) isDefault = true;
%>
						<%=fb.hidden("company_id"+i,cdo.getColValue("company_id"))%>
						<%=fb.hidden("company_name"+i,cdo.getColValue("company_name"))%>
						<%=fb.hidden("compAction"+i,cdo.getColValue("action"))%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<tr class="TextRow01" align="center"<%=style%>>
							<td><%=cdo.getColValue("company_id")%></td>
							<td align="left"><%=cdo.getColValue("company_name")%></td>
							<td>
								<% if (isDefault&& !cdo.getColValue("action").trim().equals("")) { %>
								<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
								<%=fb.select("statusDsp"+i,"A=ACTIVA,I=INACTIVA",cdo.getColValue("status"),false,true,0,"Text10",null,null)%>
								<% } else { %>
								<%=fb.select("status"+i,"A=ACTIVA,I=INACTIVA",cdo.getColValue("status"),false,viewMode,0,"Text10","","onChange=\"javascript:checkCompAction("+i+")\"")%>
								<% } %>
							</td>
							<td><%=fb.textarea("comments"+i,cdo.getColValue("comments"),false,viewMode,false,35,2)%></td>
							<td><%=isDefault?"*":""%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>

<!-- TAB7 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","7")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("invWhSize",""+iWhInv.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
<%fb.appendJsValidation("if(!setEmployeeData())error++;");%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel70">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(71)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Almacenes - Para Personal de inventario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus71" style="display:none">+</label><label id="minus71">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel71">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
							<td width="35%" rowspan="2"><cellbytelabel>Comentarios</cellbytelabel></td>
							<td width="5%" rowspan="2"><%=fb.submit("addCdsWh","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Almacenes de Inventario")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iWhInv);
for (int i=0; i<iWhInv.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iWhInv.get(key);
%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("compania_name"+i,cdo.getColValue("compania_name"))%>
						<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
						<%=fb.hidden("desc_almacen"+i,cdo.getColValue("desc_almacen"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("compania")%></td>
							<td><%=cdo.getColValue("compania_name")%></td>
							<td><%=cdo.getColValue("codigo_almacen")%></td>
							<td><%=cdo.getColValue("desc_almacen")%></td>
							<td align="center"><%=fb.textBox("comments"+i,cdo.getColValue("comments"),false,viewMode,false,50)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%}}%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB7 DIV END HERE-->
</div>
<!-- TAB8 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<%fb = new FormBean("form8",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","8")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("userName",usr.getColValue("user_name"))%>
<%=fb.hidden("name",usr.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("invWhSize",""+iWhInv.size())%>
<%=fb.hidden("gtSize",""+iGT.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(80)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Usuario</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus80" style="display:none">+</label><label id="minus80">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel80">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right">Usuario</td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right">Nombre</td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(81)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Grupo Trabajo Planilla</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus81" style="display:none">+</label><label id="minus81">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel81">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="30%">Grupo</td>
							<td width="33%">Compa&ntilde;&iacute;a</td>
							<td width="34%">Observaci&oacute;n</td>
							<td width="3%"><%=fb.submit("addGT","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Grupo Trabajo")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iGT);
for (int i=0; i<iGT.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iGT.get(key);
	String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
%>
						<%=fb.hidden("grupo"+i,cdo.getColValue("grupo"))%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("grupo_desc"+i,cdo.getColValue("grupo_desc"))%>
						<%=fb.hidden("compania_nombre"+i,cdo.getColValue("compania_nombre"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("gtAction"+i,cdo.getAction())%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01" align="center"<%=style%>>
							<td align="left"><%=cdo.getColValue("grupo")%> - <%=cdo.getColValue("grupo_desc")%></td>
							<td align="left"><%=cdo.getColValue("compania")%> - <%=cdo.getColValue("compania_nombre")%></td>
							<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,viewMode,false,35,2)%></td>
							<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
						<%}%>
<% } %>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>
				</table>

<!-- TAB8 DIV END HERE-->
</div>
<!-- TAB9 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<%fb = new FormBean("form9",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","9")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("userName",usr.getColValue("user_name"))%>
<%=fb.hidden("name",usr.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("uaSize",""+iUA.size())%>
<%=fb.hidden("uawhSize",""+iUAWH.size())%>
<%=fb.hidden("cdswhSize",""+iCDSWH.size())%>
<%=fb.hidden("invWhSize",""+iWhInv.size())%>
<%=fb.hidden("gtSize",""+iGT.size())%>
<%=fb.hidden("qxSize",""+iQx.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(90)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Usuario</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus90" style="display:none">+</label><label id="minus90">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel90">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right">Usuario</td>
							<td width="35%"><%=usr.getColValue("user_name")%></td>
							<td width="15%" align="right">Nombre</td>
							<td width="35%"><%=usr.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(91)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Grupo Trabajo Planilla</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus91" style="display:none">+</label><label id="minus91">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel91">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="30%">Habitacion</td>
							<td width="33%">Centro de Servicio</td>
							<td width="34%">Observaci&oacute;n</td>
							<td width="3%"><%=fb.submit("addHAB","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Habitacion")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iQx);
for (int i=0; i<iQx.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iQx.get(key);
	String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
%>
						<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("hab_desc"+i,cdo.getColValue("hab_desc"))%>
						<%=fb.hidden("centro"+i,cdo.getColValue("centro"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("habAction"+i,cdo.getAction())%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01" align="center"<%=style%>>
							<td align="left"><%=cdo.getColValue("habitacion")%> - <%=cdo.getColValue("hab_desc")%></td>
							<td align="left"><%=cdo.getColValue("centro")%></td>
							<td><%=fb.textarea("comments"+i,cdo.getColValue("comments"),false,viewMode,false,35,2)%></td>
							<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
						<%}%>
<% } %>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>
				</table>

<!-- TAB9 DIV END HERE-->
</div>


 <!-- =============================== IDONEIDAD ============================================ -->

<div class="dhtmlgoodies_aTab">
	 <iframe id="iidoneidad" name="iidoneidad" src="../rhplanilla/empleado_idoneidad.jsp?fp=user&nombre=<%=usr.getColValue("name")%>&user_name=<%=usr.getColValue("user_name")%>&user_id=<%=id%>&parent_mode=<%=mode%>" style="width:100%;height:500px"></iframe>
</div>
 <!-- ===============================IDONEIDAD ============================================ -->


<% if (isFpEnabled) { %>
<!-- TAB10 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="iFingerprint" id="iFingerprint" frameborder="0" align="center" width="100%" height="590" scrolling="no" src="../biometric/capture_fingerprint.jsp?mode=<%=mode%>&fp=user&type=USR&owner=<%=id%>"></iframe>
</div>
<!-- TAB10 DIV END HERE-->
<% } %>


<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Usuario'),0,'100%','');
<%
}
else
{ if(userInfoOnly.equalsIgnoreCase("Y")){
%>
initTabs('dhtmlgoodies_tabView1',Array('Usuario'),0,'100%','');
<%
}else{
%>
initTabs('dhtmlgoodies_tabView1',Array('Usuario','Perfiles','Centros de Servicios','Unidades Administrativas','Almacenes UA','Almacenes CDS','Compañías','Almacenes - Inventario','Grupo Trabajo Planilla','Quirofanos','Idoneidad'<% if (isFpEnabled) { %>,'Huella Digital'<% } %>),<%=tab%>,'100%','',null,null,<% if (isFpEnabled) { %>Array('11=if(window.frames["iFingerprint"])window.frames["iFingerprint"].doResetFrameHeight();')<% } else { %>[]<% } %>,[]);
<%
}}
%>
</script>

			</td>
		</tr>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";
	String errException = "";
	if(userInfoOnly.equalsIgnoreCase("Y")) saveOption="C";
	if (tab.equals("0")) //Usuario
	{
		UserDetail user = new UserDetail();

		user.setUserType(request.getParameter("userType"));
		user.setDepartment(request.getParameter("department"));
		user.setName(request.getParameter("name"));
		if (request.getParameter("refType") != null && !request.getParameter("refType").trim().equals("")) user.setRefCode(request.getParameter("refCode"));
		else user.setRefCode(request.getParameter("refCodeDisplay"));
		//user.setUserEmpId(request.getParameter("empId"));
		user.setUserName(request.getParameter("user"));
		user.setUserPassword(request.getParameter("password"));
		user.setUserReportTo(request.getParameter("reportTo"));
		user.setDefaultProfile(request.getParameter("profileId"));
		user.setComments(request.getParameter("comments"));
		user.setUserEmailId(request.getParameter("email"));
		user.setUserStatus(request.getParameter("status"));
		user.setUserSignaturePath("NA");

		user.setLastPassChange("sysdate");
		user.setBlockStatus(request.getParameter("block_status"));
		user.setBlockReason(request.getParameter("block_reason"));

		user.setDefaultCompania(request.getParameter("default_compania"));

		if (request.getParameter("userCopy") != null && !request.getParameter("userCopy").trim().equals("")) user.setUserIdCopy(request.getParameter("userCopy"));
		else user.setUserIdCopy("");

		user.setFechaModificacion("sysdate");
		user.setUsuarioModificacion(UserDet.getUserName());
		if (UserDet.getUserProfile().contains("0")) {
			if (request.getParameter("show_access") != null && request.getParameter("show_access").equalsIgnoreCase("Y")) user.setShowAccess("Y");
			else user.setShowAccess("N");
		}

		user.setActFrom(request.getParameter("act_from"));
		user.setActUntil(request.getParameter("act_until"));

		user.setOther1(request.getParameter("other1"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add")) {
			user.setFechaCreacion("sysdate");
			user.setUsuarioCreacion(UserDet.getUserName());
			user.setLastPassChange("sysdate - ("+validDays+" + 1)");
			UserMgr.add(user);
			id = UserMgr.getPkColValue("user_id");
			errCode = UserMgr.getErrCode();
			errMsg = UserMgr.getErrMsg();
		} else {
			if (request.getParameter("requestNewPassword") != null && request.getParameter("requestNewPassword").equalsIgnoreCase("Y")) user.setLastPassChange("sysdate - ("+validDays+" + 1)");
			else if (user.getUserPassword() != null && !user.getUserPassword().trim().equals("")) user.setLastPassChange("sysdate");
			user.setUserId(id);
			user.setUserIdCopy("");
			UserMgr.update(user);
			errCode = UserMgr.getErrCode();
			errMsg = UserMgr.getErrMsg();
		}
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1")) //Profiles
	{
		int size = 0;
		if (request.getParameter("profSize") != null) size = Integer.parseInt(request.getParameter("profSize"));
		String itemRemoved = "";

		UserDetail user = new UserDetail();
		user.setUserId(id);
		user.setDefaultProfile(request.getParameter("profileId"));

		user.setUserProfile(new Vector());
		vProf.clear();
		iProf.clear();
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setKey(i);
			cdo.addColValue("profile_id",request.getParameter("profile_id"+i));
			cdo.addColValue("profile_name",request.getParameter("profile_name"+i));
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X") && !cdo.getAction().equalsIgnoreCase("D"))
			{
				try
				{
					iProf.put(cdo.getKey(),cdo);
					vProf.add(cdo.getColValue("profile_id"));
					user.addUserProfile(request.getParameter("profile_id"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UserMgr.addUserProfile(user);
		errCode = UserMgr.getErrCode();
		errMsg = UserMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2")) //Centros de Servicios
	{
		int size = 0;
		if (request.getParameter("cdsSize") != null) size = Integer.parseInt(request.getParameter("cdsSize"));
		String itemRemoved = "";

		al.clear();
		vCds.clear();
		iCds.clear();
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_cds");
			cdo.setWhereClause("user_id="+id+" and cds="+request.getParameter("cds"+i));
			cdo.addColValue("user_id",id);
			cdo.addColValue("cds",request.getParameter("cds"+i));
			cdo.addColValue("cdsDesc",request.getParameter("cdsDesc"+i));
			cdo.addColValue("comments",request.getParameter("comments"+i));
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iCds.put(cdo.getKey(),cdo);
					vCds.add(cdo.getColValue("cds"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&id="+id);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_cds");
			cdo.setWhereClause("user_id="+id);
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("3")) //Unidades Administrativas
	{
		int size = 0;
		if (request.getParameter("uaSize") != null) size = Integer.parseInt(request.getParameter("uaSize"));
		String itemRemoved = "";

		al.clear();
		iUA.clear();
		vUA.clear();
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_ua");
			cdo.setWhereClause("user_id="+id+" and compania="+request.getParameter("compania"+i)+" and ua="+request.getParameter("ua"+i));
			cdo.addColValue("user_id",id);
			cdo.addColValue("compania",request.getParameter("compania"+i));
			cdo.addColValue("companiaNombre",request.getParameter("companiaNombre"+i));
			cdo.addColValue("ua",request.getParameter("ua"+i));
			cdo.addColValue("uaDesc",request.getParameter("uaDesc"+i));
			cdo.addColValue("comments",request.getParameter("comments"+i));
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iUA.put(cdo.getKey(),cdo);
					vUA.add(cdo.getColValue("compania")+"-"+cdo.getColValue("ua"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&id="+id);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_ua");
			cdo.setWhereClause("user_id="+id);
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("4") || tab.equals("5")|| tab.equals("7")) //Almacenes
	{
		int size = 0;
		String refType = "";
		if (tab.equals("4"))
		{
			if (request.getParameter("uawhSize") != null) size = Integer.parseInt(request.getParameter("uawhSize"));
			refType = "UA";
		}
		else if (tab.equals("5"))
		{
			if (request.getParameter("cdswhSize") != null) size = Integer.parseInt(request.getParameter("cdswhSize"));
			refType = "CDS";
		}
		else if (tab.equals("7"))
		{
			if (request.getParameter("invWhSize") != null) size = Integer.parseInt(request.getParameter("invWhSize"));
			refType = "INV";
		}
		String itemRemoved = "";

		al.clear();
		if (tab.equals("4")){iUAWH.clear();vUAWH.clear();}
		else if (tab.equals("5")){iCDSWH.clear();vCDSWH.clear();}
		else if (tab.equals("7")){iWhInv.clear();vWhInv.clear();}
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_almacen");
			cdo.setWhereClause("user_id="+id+" and ref_type='"+refType+"' and almacen ="+request.getParameter("codigo_almacen"+i)+" and compania="+request.getParameter("compania"+i));
			cdo.addColValue("user_id",id);
			cdo.addColValue("compania",request.getParameter("compania"+i));
			cdo.addColValue("almacen",request.getParameter("codigo_almacen"+i));
			cdo.addColValue("ref_type",refType);
			cdo.addColValue("comments",request.getParameter("comments"+i));

			cdo.setKey(i);
			cdo.addColValue("compania_name",request.getParameter("compania_name"+i));
			cdo.addColValue("codigo_almacen",request.getParameter("codigo_almacen"+i));
			cdo.addColValue("desc_almacen",request.getParameter("desc_almacen"+i));
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					if (tab.equals("4")){ iUAWH.put(cdo.getKey(),cdo);vUAWH.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));}
					else if (tab.equals("5")){iCDSWH.put(cdo.getKey(),cdo);vCDSWH.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));}
					else if (tab.equals("7")){iWhInv.put(cdo.getKey(),cdo);vWhInv.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));}
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&type=1&mode="+mode+"&id="+id);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_almacen");
			cdo.setWhereClause("user_id="+id+" and ref_type='"+refType+"'");
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("6")) //Compañías
	{
		int size = 0;
		if (request.getParameter("compSize") != null) size = Integer.parseInt(request.getParameter("compSize"));

		alComp.clear();
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setAction(request.getParameter("compAction"+i));
			cdo.setTableName("tbl_sec_user_comp");
			cdo.setWhereClause("user_id = "+id+" and company_id = "+request.getParameter("company_id"+i));

			if (baction.equalsIgnoreCase("Guardar") && cdo.getAction().equalsIgnoreCase("U")) {/*do not update pk values*/}
			else {
				cdo.addColValue("user_id",id);
				cdo.addColValue("company_id",request.getParameter("company_id"+i));
			}
			cdo.addColValue("status",request.getParameter("status"+i));
			cdo.addColValue("comments",request.getParameter("comments"+i));
			cdo.addColValue("company_name",request.getParameter("company_name"+i));
			if (cdo.getAction().trim().equals("") && !cdo.getColValue("comments").trim().equals("")) cdo.setAction("I");

			alComp.add(cdo);
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
			SQLMgr.saveList(alComp,true,false);
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
			errException = SQLMgr.getErrException();
			ConMgr.clearAppCtx(null);
		}
	}
	else if (tab.equals("8")) {//Grupo Trabajo Planilla
		int size = 0;
		if (request.getParameter("gtSize") != null) size = Integer.parseInt(request.getParameter("gtSize"));
		String itemRemoved = "";

		al.clear();
		iGT.clear();
		for (int i=0; i<size; i++) {
			CommonDataObject cdo = new CommonDataObject();

			cdo.setKey(i);
			cdo.setAction(request.getParameter("gtAction"+i));
			cdo.setTableName("tbl_pla_ct_usuario_x_grupo");
			cdo.setWhereClause("grupo = "+request.getParameter("grupo"+i)+" and user_id = "+id+" and compania = "+request.getParameter("compania"+i));
			//cdo.setWhereClause("grupo = "+request.getParameter("grupo"+i)+" and user_id = "+id);

			if (baction.equalsIgnoreCase("Guardar") && cdo.getAction().equalsIgnoreCase("U")) {/*do not update pk values*/}
			else {
				cdo.addColValue("grupo",request.getParameter("grupo"+i));
				cdo.addColValue("usuario",request.getParameter("userName"));
				cdo.addColValue("compania",request.getParameter("compania"+i));
				cdo.addColValue("user_id",id);
			}
			cdo.addColValue("nombre",request.getParameter("name"));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("grupo_desc",request.getParameter("grupo_desc"+i));
			cdo.addColValue("compania_nombre",request.getParameter("compania_nombre"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
				itemRemoved = request.getParameter("grupo"+i)+"-"+request.getParameter("compania"+i);
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X")) {
				try {
					iGT.put(cdo.getKey(),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}
		if (!itemRemoved.equals("")) {
			vGT.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;
		} else if (baction.equalsIgnoreCase("+")) {
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;
		} else if (baction.equalsIgnoreCase("Guardar")) {
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
			SQLMgr.saveList(al,true,false);
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
			errException = SQLMgr.getErrException();
			ConMgr.clearAppCtx(null);
		}
	 }
	 else if (tab.equals("9")) {//QUIROFANO
		int size = 0;
		if (request.getParameter("qxSize") != null) size = Integer.parseInt(request.getParameter("qxSize"));
		String itemRemoved = "";

		al.clear();
		iQx.clear();
		for (int i=0; i<size; i++) {
			CommonDataObject cdo = new CommonDataObject();

			cdo.setKey(i);
			cdo.setAction(request.getParameter("habAction"+i));
			cdo.setTableName("tbl_sec_user_quirofano");
			cdo.setWhereClause("habitacion = '"+request.getParameter("habitacion"+i)+"' and user_id = "+id+" and compania = "+request.getParameter("compania"+i));
			//cdo.setWhereClause("grupo = "+request.getParameter("grupo"+i)+" and user_id = "+id);

			if (baction.equalsIgnoreCase("Guardar") && cdo.getAction().equalsIgnoreCase("U")) {/*do not update pk values*/}
			else {
				cdo.addColValue("habitacion",request.getParameter("habitacion"+i));
				cdo.addColValue("usuario",request.getParameter("userName"));
				cdo.addColValue("compania",request.getParameter("compania"+i));
				cdo.addColValue("user_id",id);
			}
			cdo.addColValue("nombre",request.getParameter("name"));
			cdo.addColValue("comments",request.getParameter("comments"+i));
			cdo.addColValue("hab_desc",request.getParameter("hab_desc"+i));
			cdo.addColValue("centro",request.getParameter("centro"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
				itemRemoved = request.getParameter("habitacion"+i);
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X")) {
				try {
					iQx.put(cdo.getKey(),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals("")) {
			vQx.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;
		} else if (baction.equalsIgnoreCase("+")) {
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;
		} else if (baction.equalsIgnoreCase("Guardar")) {
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
			SQLMgr.saveList(al,true,false);
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
			errException = SQLMgr.getErrException();
			ConMgr.clearAppCtx(null);
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_user.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_user.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_user.jsp';
<%
		}
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
} else throw new Exception(errException);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>