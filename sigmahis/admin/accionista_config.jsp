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
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoParam = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fp = request.getParameter("fp"); 
String fg = request.getParameter("fg"); 
StringBuffer sbSql = null;

boolean viewMode = false;

if (tab == null) tab = "0";
if (mode == null) mode = "add";

 sbSql = new StringBuffer();
		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'POS_TIPO_CLTE_");
		sbSql.append(fg);
		sbSql.append("'),'-99') as tipo_cliente from dual");
		  cdoParam = SQLMgr.getData(sbSql.toString());
		  
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("fecha_nacimiento","");
		cdo.addColValue("codigo",""); 
		cdo.addColValue("provincia",""); 
		cdo.addColValue("sigla",""); 
		cdo.addColValue("tomo",""); 
		cdo.addColValue("asiento",""); 
		cdo.addColValue("pasaporte",""); 
		cdo.addColValue("d_cedula",""); 
		cdo.addColValue("tipo_cliente",""+cdoParam.getColValue("tipo_cliente")); 
		 
		
		
	}
	else
	{
		if (id == null) throw new Exception("El Codigo no es válido. Por favor intente nuevamente!");

		sql = "select a.codigo, a.descripcion,a.ruc, a.colaborador, a.forma_pago, a.tipo_cliente, a.dias_cr_limite, a.monto_cr_limite,decode(tipo_id,'C','',a.ruc) as pasaporte, a.aplica_descuento, a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion,a.direccion, a.correo, a.telefono, a.persona_contacto, a.primer_nombre, a.segundo_nombre, a.primer_apellido, a.segundo_apellido, a.apellido_de_casada, a.sexo, a.nacionalidad, a.estado_civil, a.tipo_id, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.religion, a.comunidad, a.corregimiento, a.distrito, a.provincia_dir, a.pais, a.zona_postal as zonaPostal, a.apartado_postal, a.celular, a.lugar_de_trabajo as lugar_trabajo, a.telefono_trabajo, a.extension, a.fax, a.provincia, a.sigla, a.tomo, a.asiento,(select nvl(d.nombre_comunidad, ' ')     from vw_sec_regional_location d where d.codigo_comunidad=a.comunidad and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia_dir and d.codigo_distrito=a.distrito and d.codigo_corregimiento=a.corregimiento and nivel=4) as comunidadNombre,(select nvl(d.nombre_corregimiento, ' ') from vw_sec_regional_location d where d.codigo_corregimiento=a.corregimiento  and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia_dir and d.codigo_distrito=a.distrito and nivel=3 ) as corregimientoNombre, (select nvl(d.nombre_distrito, ' ')      from vw_sec_regional_location d where d.codigo_distrito=a.distrito  and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia_dir and nivel=2) as distritoNombre, (select nvl(d.nombre_provincia, ' ')     from vw_sec_regional_location d where d.codigo_provincia=a.provincia_dir  and d.codigo_pais=a.pais and  nivel =1)  as provincianombre, (select nvl(d.nombre_pais, ' ')          from vw_sec_regional_location d where d.codigo_pais=a.pais and nivel =0) as paisnombre,a.d_cedula from tbl_cxc_cliente_particular a where a.codigo='"+id+"'";
		
		cdo = SQLMgr.getData(sql); 
		 
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Accionistas / J. Directiva -  Edición - '+document.title;
function showUbicacionGeoList(){abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=accionista');}
function clearPais()
{
	document.form0.pais.value = '';
	document.form0.paisNombre.value = '';
	document.form0.provincia_dir.value = '';
	document.form0.provinciaNombre.value = '';
	document.form0.distrito.value = '';
	document.form0.distritoNombre.value = '';
	document.form0.corregimiento.value = '';
	document.form0.corregimientoNombre.value = '';
	document.form0.comunidad.value = '';
	document.form0.comunidadNombre.value = '';
}
function clearProvincia()
{
	document.form0.provincia_dir.value = '';
	document.form0.provinciaNombre.value = '';
	document.form0.distrito.value = '';
	document.form0.distritoNombre.value = '';
	document.form0.corregimiento.value = '';
	document.form0.corregimientoNombre.value = '';
	document.form0.comunidad.value = '';
	document.form0.comunidadNombre.value = '';
}
function clearDistrito()
{
	document.form0.distrito.value = '';
	document.form0.distritoNombre.value = '';
	document.form0.corregimiento.value = '';
	document.form0.corregimientoNombre.value = '';
	document.form0.comunidad.value = '';
	document.form0.comunidadNombre.value = '';
}
function clearCorregimiento()
{
	document.form0.corregimiento.value = '';
	document.form0.corregimientoNombre.value = '';
	document.form0.comunidad.value = '';
	document.form0.comunidadNombre.value = '';
}
function clearComunidad()
{
	document.form0.comunidad.value = '';
	document.form0.comunidadNombre.value = '';
}  
function doAction()
{
 	setId(false); 
}

function _doSubmit(){return true;}
function setId(clearOnChange){
<%
	if (!viewMode)
	{
%>
	if (document.form0.tipo_id.value == 'C')
	{
		document.form0.pasaporte.className = 'FormDataObjectDisabled';
		document.form0.pasaporte.readOnly = true;
		if (clearOnChange) document.form0.pasaporte.value = '';

		document.form0.provincia.className = 'FormDataObjectEnabled';
		document.form0.sigla.className = 'FormDataObjectEnabled';
		document.form0.tomo.className = 'FormDataObjectEnabled';
		document.form0.asiento.className = 'FormDataObjectEnabled';
		document.form0.provincia.readOnly = false;
		document.form0.sigla.readOnly = false;
		document.form0.tomo.readOnly = false;
		document.form0.asiento.readOnly = false;
	}
	else if (document.form0.tipo_id.value == 'P')
	{
		document.form0.provincia.className = 'FormDataObjectDisabled';
		document.form0.sigla.className = 'FormDataObjectDisabled';
		document.form0.tomo.className = 'FormDataObjectDisabled';
		document.form0.asiento.className = 'FormDataObjectDisabled';
		document.form0.provincia.readOnly = true;
		document.form0.sigla.readOnly = true;
		document.form0.tomo.readOnly = true;
		document.form0.asiento.readOnly = true;
		if (clearOnChange)
		{
			document.form0.provincia.value = '';
			document.form0.sigla.value = '';
			document.form0.tomo.value = '';
			document.form0.asiento.value = '';
		}

		document.form0.pasaporte.className = 'FormDataObjectEnabled';
		document.form0.pasaporte.readOnly = false;
	}
	chkReqCampos();
<%
	}
%>
}
function chkReqCampos(){
	if(document.form0.tipo_id.value=='C'){
		document.form0.provincia.className = 'FormDataObjectRequired';
		document.form0.sigla.className = 'FormDataObjectRequired';
		document.form0.tomo.className = 'FormDataObjectRequired';
		document.form0.asiento.className = 'FormDataObjectRequired';
		document.form0.d_cedula.className = 'FormDataObjectRequired';
		document.form0.pasaporte.className = 'FormDataObjectDisabled';
	} else {
		document.form0.provincia.className = 'FormDataObjectDisabled';
		document.form0.sigla.className = 'FormDataObjectDisabled';
		document.form0.tomo.className = 'FormDataObjectDisabled';
		document.form0.asiento.className = 'FormDataObjectDisabled';
		document.form0.d_cedula.className = 'FormDataObjectDisabled';
		document.form0.pasaporte.className = 'FormDataObjectRequired';
	}

}
function checkProvincia(obj)
{
<%
	if (!viewMode)
	{
%>
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(obj.value.trim())||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'C\' and provincia=\''+obj.value+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("provincia").trim()%>'))
			{
					 document.form0.provincia.value = '';
					 return true;
			} else return false;
		}
<%
	}
%>
}

function checkSigla(obj)
{
<%if (!viewMode){%>
	var provincia=document.form0.provincia.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(obj.value,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>'))
			{
					 document.form0.sigla.value = '';
					 return true;
			} else return false;
		}
<%}%>
}

function checkTomo(obj)
{
<%
	if (!viewMode)
	{
%>
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(provincia)||isNaN(obj.value.trim())||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("tomo").trim()%>'))
			{
					 document.form0.tomo.value = '';
					 return true;
			} else return false;
		}
<%
	}
%>
}

function checkAsiento(obj)
{
<%
	if (!viewMode)
	{
%>
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(obj.value.trim()))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("asiento").trim()%>'))
			{
				 document.form0.asiento.value = '';
				 return true;
			}
			else return false;
		}
<%
	}
%>
}
function checkPasaporte(obj)
{
	var dCedula=document.form0.d_cedula.value.trim();
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'P\' and ruc=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')

}
function checkDCedula(obj)
{
	var tipoId=document.form0.tipo_id.value;
	if(tipoId=='C')
	{
		var provincia=document.form0.provincia.value.trim();
		var sigla=document.form0.sigla.value.trim();
		var tomo=document.form0.tomo.value.trim();
		var asiento=document.form0.asiento.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')
		}
	}
	else if(tipoId='P')
	{
		var pasaporte=document.form0.pasaporte.value.trim();
		return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cxc_cliente_particular','tipo_id=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - MANTENIMIENTO - ACCIONISTA/JUNTA DIRECTIVA"></jsp:param>
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

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("d_cedula","D")%>
<%=fb.hidden("tipoClte",cdoParam.getColValue("tipo_cliente"))%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Generales</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right">
								<%=((fg.trim().equals("ACC"))?"ACCIONISTA":"JUNTA DIRECTIVA")%>
							</td>
						    <td width="35%">
						    	<table width="100%">
						    		<tr>
						    			<td><%=fb.textBox("codigo",cdo.getColValue("codigo"),false,true,false,15,15,null,null,"")%></td>
						    			<td>&nbsp;</td>
						    		</tr>
						    	</table>
						    </td>
							<td width="15%" align="right">Estado</td>
						    <td width="35%"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="4">Primer Nombre</cellbytelabel></td>
							<td><%=fb.textBox("primerNombre",cdo.getColValue("primer_nombre"),true,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="5">Sexo</cellbytelabel></td>
					    <td><%=fb.select("sexo","F=FEMENINO,M=MASCULINO",cdo.getColValue("sexo"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="6">Segundo Nombre</cellbytelabel></td>
							<td><%=fb.textBox("segundoNombre",cdo.getColValue("segundo_nombre"),false,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="7">Estado Civil</cellbytelabel></td>
							<td><%=fb.select("estadoCivil","CS=CASADO,DV=DIVORCIADO,ST=SOLTERO,VD=VIUDO,UN=UNIDO,SP=SEPARADO",cdo.getColValue("estado_civil"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="8">Apellido Paterno</cellbytelabel></td>
							<td><%=fb.textBox("primerApellido",cdo.getColValue("primer_apellido"),true,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="9">Fecha Nacimiento</cellbytelabel></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fechaNacimiento" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_nacimiento")%>" />
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="10">Apellido Materno</cellbytelabel></td>
					    <td><%=fb.textBox("segundoApellido",cdo.getColValue("segundo_apellido"),false,false,false,30,30)%></td>
							<td align="right">&nbsp;</td>
					    <td>&nbsp;</td>
							<td></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="12">Apellido de Casada</cellbytelabel></td>
							<td><%=fb.textBox("apellidoDeCasada",cdo.getColValue("apellido_de_casada"),false,false,false,30,30)%></td>
							<td align="right">&nbsp;</td>
					    <td>&nbsp;</td>
						</tr>
						
						<tr class="TextRow01">
						  <td align="right"><cellbytelabel id="14">Tipo Id.</cellbytelabel></td>
					    <td><%=fb.select("tipo_id","C=Cedula,P=Pasaporte",cdo.getColValue("tipo_id"),false,viewMode,0,null,null,"onChange=\"javascript:setId(true)\"")%></td>
							<td align="right"><cellbytelabel id="15">Cedula</cellbytelabel></td>
					        <td><%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
						<%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%>
						<%=fb.intBox("tomo",cdo.getColValue("tomo"),false,false,viewMode,5,4,null,null,"onBlur=\"javascript:checkTomo(this)\"")%>
						<%=fb.intBox("asiento",cdo.getColValue("asiento"),false,false,viewMode,6,6,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>
						<br>
						Pasaporte:<%=fb.textBox("pasaporte",cdo.getColValue("pasaporte"),false,false,viewMode,20,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%>
						
						</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="18">Religi&oacute;n</cellbytelabel></td>
					    <td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo, codigo from tbl_adm_religion order by descripcion","religion",cdo.getColValue("religion"),"S")%></td>
							<td align="right"><cellbytelabel id="19">Nacionalidad</cellbytelabel></td>
					    <td><%=fb.select(ConMgr.getConnection(),"select codigo, nvl(nacionalidad,nombre)||' - '||codigo, codigo from tbl_sec_pais order by nvl(nacionalidad,nombre)","nacionalidad",cdo.getColValue("nacionalidad"),"S")%></td>
						</tr> 
						   
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="22">Direcciones</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="23">Direcci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,30,100)%></td>
							<td width="15%" align="right"><cellbytelabel id="24">Tel&eacute;fono</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,13,13)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="25">Tel&eacute;fono Celular</cellbytelabel></td>
							<td><%=fb.textBox("celular",cdo.getColValue("celular"),false,false,false,13,13)%></td>
							<td align="right">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="27">Direcci&oacute;n Postal</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="28">Apartado</cellbytelabel></td>
							<td><%=fb.textBox("apartadoPostal",cdo.getColValue("apartado_postal"),false,false,false,20,20)%></td>
							<td align="right"><cellbytelabel id="29">Zona</cellbytelabel></td>
							<td><%=fb.textBox("zonaPostal",cdo.getColValue("zonaPostal"),false,false,false,20,20)%>
							</td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4">
								<cellbytelabel id="30">Ubicaci&oacute;n Geogr&aacute;fica</cellbytelabel>
								<%=fb.button("btnUbicacion","...",false,false,null,null,"onClick=\"javascript:showUbicacionGeoList()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="31">Pa&iacute;s</cellbytelabel></td>
							<td>
								<%=fb.intBox("pais",cdo.getColValue("pais"),false,false,true,6,null,null,"onDblClick=\"javascript:clearPais()\"")%>
								<%=fb.textBox("paisNombre",cdo.getColValue("paisNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearPais()\"")%>
							</td>
							<td align="right"><cellbytelabel id="32">Provincia</cellbytelabel></td>
							<td>
								<%=fb.intBox("provincia_dir",cdo.getColValue("provincia_dir"),false,false,true,6,null,null,"onDblClick=\"javascript:clearProvincia()\"")%>
								<%=fb.textBox("provinciaNombre",cdo.getColValue("provinciaNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearProvincia()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="33">Distrito</cellbytelabel></td>
							<td>
								<%=fb.intBox("distrito",cdo.getColValue("distrito"),false,false,true,6,null,null,"onDblClick=\"javascript:clearDistrito()\"")%>
								<%=fb.textBox("distritoNombre",cdo.getColValue("distritoNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearDistrito()\"")%>
							</td>
							<td align="right"><cellbytelabel id="34">Corregimiento</cellbytelabel></td>
							<td>
								<%=fb.intBox("corregimiento",cdo.getColValue("corregimiento"),false,false,true,6,null,null,"onDblClick=\"javascript:clearCorregimiento()\"")%>
								<%=fb.textBox("corregimientoNombre",cdo.getColValue("corregimientoNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearCorregimiento()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="35">Comunidad</cellbytelabel></td>
							<td>
								<%=fb.intBox("comunidad",cdo.getColValue("comunidad"),false,false,false,6,null,null,"onDblClick=\"javascript:clearComunidad()\"")%>
								<%=fb.textBox("comunidadNombre",cdo.getColValue("comunidadNombre"),false,false,false,40,null,null,"onDblClick=\"javascript:clearComunidad()\"")%>
							</td>
							<td align="right">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="36">Lugar de Trabajo</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel2">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="15%" align="right"><cellbytelabel id="36">Lugar de Trabajo</cellbytelabel></td>
								<td width="35%"><%=fb.textBox("lugarDeTrabajo",cdo.getColValue("lugar_Trabajo"),false,false,false,40,80)%></td>
								<td width="15%" align="right"><cellbytelabel id="37">Tel&eacute;fono de Trabajo</cellbytelabel></td>
								<td width="35%"><%=fb.textBox("telefonoTrabajo",cdo.getColValue("telefono_trabajo"),false,false,false,13,13)%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel id="38">Extensi&oacute;n Tel&eacute;fonica</cellbytelabel></td>
							<td><%=fb.textBox("extension",cdo.getColValue("extension"),false,false,false,6,6)%></td>
								<td align="right"><cellbytelabel id="39">Correo Electronico</cellbytelabel></td>
								<td><%=fb.emailBox("eMail",cdo.getColValue("correo"),false,false,false,40,100)%>
							</tr>
							<tr class="TextRow01">
							  <td align="right"><cellbytelabel id="40">N&uacute;mero de Fax</cellbytelabel></td>
							<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,13,13)%></td>
								<td align="right">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
						</table>
          </td>
        </tr> 
				 
				 
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="44">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="45">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel id="46">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="47">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<%fb.appendJsValidation("if(!_doSubmit()){error++;}");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>


<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('<%=(fg.trim().equals("ACC")?"ACCIONISTA":"JUNTA DIRECTIVA")%>'),0,'100%','');
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	fp = request.getParameter("fp");
	if (tab.equals("0")) //
	{
		cdo = new CommonDataObject();

  	    cdo.setTableName("tbl_cxc_cliente_particular");
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("primer_nombre",request.getParameter("primerNombre"));
		cdo.addColValue("primer_apellido",request.getParameter("primerApellido"));
		cdo.addColValue("descripcion",request.getParameter("primerNombre")+" "+request.getParameter("segundoNombre")+" "+request.getParameter("primerApellido")+" "+request.getParameter("segundoApellido"));
		
		if (request.getParameter("sexo") != null && !request.getParameter("sexo").equals("")) cdo.addColValue("sexo",request.getParameter("sexo"));
		if (request.getParameter("segundoNombre") != null) cdo.addColValue("segundo_nombre",request.getParameter("segundoNombre"));
		if (request.getParameter("estadoCivil") != null) cdo.addColValue("estado_civil",request.getParameter("estadoCivil"));
		if (request.getParameter("fechaNacimiento") != null) cdo.addColValue("fecha_nacimiento",request.getParameter("fechaNacimiento"));
		if (request.getParameter("segundoApellido") != null) cdo.addColValue("segundo_apellido",request.getParameter("segundoApellido")); 
		if (request.getParameter("apellidoDeCasada") != null) cdo.addColValue("apellido_de_casada",request.getParameter("apellidoDeCasada")); 
		if (request.getParameter("identificacion") != null) cdo.addColValue("identificacion",request.getParameter("identificacion")); 
		if (request.getParameter("religion") != null) cdo.addColValue("religion",request.getParameter("religion"));
		if (request.getParameter("nacionalidad") != null) cdo.addColValue("nacionalidad",request.getParameter("nacionalidad"));  
		if (request.getParameter("direccion") != null) cdo.addColValue("direccion",request.getParameter("direccion"));
		if (request.getParameter("telefono") != null) cdo.addColValue("telefono",request.getParameter("telefono"));
		if (request.getParameter("celular") != null) cdo.addColValue("celular",request.getParameter("celular")); 
		if (request.getParameter("apartadoPostal") != null) cdo.addColValue("apartado_postal",request.getParameter("apartadoPostal"));
		if (request.getParameter("zonaPostal") != null) cdo.addColValue("zona_postal",request.getParameter("zonaPostal"));
		if (request.getParameter("pais") != null) cdo.addColValue("pais",request.getParameter("pais"));
		if (request.getParameter("provincia_dir") != null) cdo.addColValue("provincia_dir",request.getParameter("provincia_dir"));
		if (request.getParameter("distrito") != null) cdo.addColValue("distrito",request.getParameter("distrito"));
		if (request.getParameter("corregimiento") != null) cdo.addColValue("corregimiento",request.getParameter("corregimiento"));
		if (request.getParameter("comunidad") != null) cdo.addColValue("comunidad",request.getParameter("comunidad")); 
		
		if (request.getParameter("tipo_id") != null) cdo.addColValue("tipo_id",request.getParameter("tipo_id")); 
		if (request.getParameter("provincia") != null) cdo.addColValue("provincia",request.getParameter("provincia")); 
		if (request.getParameter("sigla") != null) cdo.addColValue("sigla",request.getParameter("sigla")); 
		if (request.getParameter("tomo") != null) cdo.addColValue("tomo",request.getParameter("tomo")); 
		if (request.getParameter("asiento") != null) cdo.addColValue("asiento",request.getParameter("asiento"));  
   
		if (request.getParameter("lugarDeTrabajo") != null) cdo.addColValue("lugar_de_trabajo",request.getParameter("lugarDeTrabajo"));
		if (request.getParameter("telefonoTrabajo") != null) cdo.addColValue("telefono_trabajo",request.getParameter("telefonoTrabajo"));
		if (request.getParameter("extension") != null) cdo.addColValue("extension",request.getParameter("extension"));
		if (request.getParameter("eMail") != null) cdo.addColValue("correo",request.getParameter("eMail"));
		if (request.getParameter("fax") != null) cdo.addColValue("fax",request.getParameter("fax")); 

		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("tipo_cliente",request.getParameter("tipoClte")); 
		cdo.addColValue("d_cedula",request.getParameter("d_cedula")); 
		
		if (request.getParameter("tipo_id") != null)
		{
		
		 if (request.getParameter("tipo_id").trim().equals("C"))cdo.addColValue("ruc",request.getParameter("provincia")+"-"+request.getParameter("sigla")+"-"+request.getParameter("tomo")+"-"+request.getParameter("asiento"));
		 else cdo.addColValue("ruc",request.getParameter("pasaporte"));
		 
		 }

	  if (mode.equalsIgnoreCase("add"))
  	  {
			cdo.setAutoIncCol("codigo");
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
			
			SQLMgr.insert(cdo);
			id =SQLMgr.getPkColValue("codigo");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			cdo.setWhereClause("codigo='"+id+"'");

			SQLMgr.update(cdo);
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
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
 		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/accionista_list.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/accionista_list.jsp?fg="+fg)%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/accionista_list.jsp?fg=<%=fg%>';
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

function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>&fg=<%=fg%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>