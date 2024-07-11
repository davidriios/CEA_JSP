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
<jsp:useBean id="iEsp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEsp" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSoc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iUbi" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vUbi" scope="session" class="java.util.Vector" />
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

CommonDataObject med = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
int espLastLineNo = 0;
int socLastLineNo = 0;
int ubiLastLineNo = 0;
boolean viewMode = false;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("espLastLineNo") != null) espLastLineNo = Integer.parseInt(request.getParameter("espLastLineNo"));
if (request.getParameter("socLastLineNo") != null) socLastLineNo = Integer.parseInt(request.getParameter("socLastLineNo"));
if (request.getParameter("ubiLastLineNo") != null) ubiLastLineNo = Integer.parseInt(request.getParameter("ubiLastLineNo"));
String tabFunctions = "'4=tabFunctions(4)'";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		med.addColValue("fechaDeNacimiento","");
		med.addColValue("codigo","");
		med.addColValue("provincia_ced","");
		med.addColValue("sigla","00");
		med.addColValue("tomo","");
		med.addColValue("asiento","");
		med.addColValue("pasaporte","");
		med.addColValue("reg_medico","");
		
		iEsp.clear();
		vEsp.clear();
		iSoc.clear();
		vSoc.clear();
		iUbi.clear();
		vUbi.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Médico no es válido. Por favor intente nuevamente!");

		sql = "select a.codigo, a.referencia, decode(a.tipo_id,'C','',a.identificacion) as pasaporte, a.primer_nombre as primerNombre, nvl(a.segundo_nombre, ' ') as segundoNombre, a.primer_apellido as primerApellido, nvl(a.segundo_apellido, ' ') as segundoApellido, nvl(a.apellido_de_casada, ' ') as apellidoDeCasada, a.sexo, decode(a.nacionalidad, null, ' ', a.nacionalidad) as nacionalidad, a.estado_civil as estadoCivil, decode(a.fecha_de_nacimiento, null, ' ', to_char(a.fecha_de_nacimiento, 'dd/mm/yyyy')) as fechaDeNacimiento, a.religion, nvl(a.digito_verificador, ' ') as digitoVerificador, nvl(a.direccion, ' ') as direccion, decode(a.comunidad, null, ' ', a.comunidad) as comunidad, decode(a.corregimiento, null, ' ', a.corregimiento) as corregimiento, decode(a.distrito, null, ' ', a.distrito) as distrito, decode(a.provincia, null, ' ', a.provincia) as provincia, decode(a.pais, null, ' ', a.pais) as pais, nvl(a.telefono, ' ') as telefono, nvl(a.zona_postal, ' ') as zonaPostal, nvl(a.apartado_postal, ' ') as apartadoPostal, nvl(a.bepper, ' ') as bepper, nvl(a.celular, ' ') as celular, nvl(a.lugar_de_trabajo, ' ') as lugarDeTrabajo, nvl(a.telefono_trabajo, ' ') as telefonoTrabajo, nvl(a.extension, ' ') as extension, a.estado, nvl(a.e_mail, ' ') as eMail, nvl(a.fax, ' ') as fax, nvl(a.observaciones, ' ') as observaciones, decode(a.cod_empresa, null, ' ', a.cod_empresa) as codEmpresa, nvl(a.beneficiario, ' ') as beneficiario, nvl(a.pagar_ben, ' ') as pagarBen, nvl(a.liquidable, ' ') as liquidable, nvl(a.retencion, ' ') as retencion, nvl(a.cuenta_bancaria, ' ') as cuentaBancaria, nvl(a.ruta_transito, ' ') as rutaTransito, nvl(a.tipo_cuenta, '') as tipoCuenta, decode(a.tipo_persona, null, ' ', a.tipo_persona) as tipoPersona, decode(a.tipo_medico, null, '','',1, a.tipo_medico) as tipoMedico, nvl(b.nacionalidad, 'NA') as nacionalidadDesc, nvl(c.descripcion, 'NA') as religionDesc, nvl(d.nombre_comunidad, ' ') as comunidadNombre, nvl(d.nombre_corregimiento, ' ') as corregimientoNombre, nvl(d.nombre_distrito, ' ') as distritoNombre, nvl(d.nombre_provincia, ' ') as provincianombre, nvl(d.nombre_pais, ' ') as paisnombre, nvl(e.nombre,' ') as empresaNombre, nvl(f.nombre_banco,' ') as rutaTransitoNombre,nvl(a.alquiler,'N') as alquiler, nvl(a.genera_odp, 'S') genera_odp,a.forma_pago,		nvl(a.tipo_id,'C') as tipo_id,a.provincia_ced, a.sigla,a.tomo,a.asiento,a.reg_medico,a.porc_retencion from tbl_adm_medico a, tbl_sec_pais b, tbl_adm_religion c, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito, decode(codigo_corregimiento,0,null,codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad  from vw_sec_regional_location) d, tbl_adm_empresa e, tbl_adm_ruta_transito f where a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and a.pais = d.codigo_pais(+) and a.provincia = d.codigo_provincia(+) and a.distrito = d.codigo_distrito(+) and a.corregimiento = d.codigo_corregimiento(+) and a.comunidad = d.codigo_comunidad(+) and a.cod_empresa=e.codigo(+) and a.ruta_transito=f.ruta(+) and a.codigo='"+id+"'";
		med = SQLMgr.getData(sql);

		if (change == null)
		{
			sql = "select a.especialidad, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, a.secuencia, b.descripcion as especialidadDesc from tbl_adm_medico_especialidad a, tbl_adm_especialidad_medica b where a.especialidad=b.codigo and a.medico='"+id+"' order by a.especialidad";
			al  = SQLMgr.getDataList(sql);

			iEsp.clear();
			vEsp.clear();
			iSoc.clear();
			vSoc.clear();
			iUbi.clear();
			vUbi.clear();

			espLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iEsp.put(key, cdo);
					vEsp.addElement(cdo.getColValue("especialidad"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sql = "select a.empresa, a.estado, nvl(a.comentario,' ') as comentario, b.nombre as empresaNombre from tbl_adm_medico_sociedad_medica a, tbl_adm_empresa b where a.empresa=b.codigo and a.medico='"+id+"' order by a.empresa";
			al  = SQLMgr.getDataList(sql);

			socLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iSoc.put(key, cdo);
					vSoc.addElement(cdo.getColValue("empresa"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sql = "select a.ubicacion, nvl(a.telefono,' ') as telefono, a.principal, b.descripcion as ubicacionDesc from tbl_adm_medico_ubicacion a, tbl_adm_ubicacion b where a.ubicacion=b.codigo and a.medico='"+id+"' order by a.ubicacion";
			al  = SQLMgr.getDataList(sql);

			ubiLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iUbi.put(key, cdo);
					vUbi.addElement(cdo.getColValue("ubicacion"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Médico -  Edición - '+document.title;

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function showEmpresaList()
{
	abrir_ventana1('../common/search_empresa.jsp?fp=medico');
}

function clearEmpresa()
{
	document.form0.codEmpresa.value = '';
	document.form0.empresaNombre.value = '';
}

function showUbicacionGeoList()
{
	abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=medico');
}

function clearPais()
{
	document.form0.pais.value = '';
	document.form0.paisNombre.value = '';
	document.form0.provincia.value = '';
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
	document.form0.provincia.value = '';
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

function showEspecialidadList()
{
  abrir_ventana1('../common/check_especialidad_med.jsp?fp=medico&mode=<%=mode%>&id=<%=id%>&espLastLineNo=<%=espLastLineNo%>&socLastLineNo=<%=socLastLineNo%>&ubiLastLineNo=<%=ubiLastLineNo%>');
}

function showSociedadList()
{
  abrir_ventana1('../common/check_empresa.jsp?fp=medico&mode=<%=mode%>&id=<%=id%>&espLastLineNo=<%=espLastLineNo%>&socLastLineNo=<%=socLastLineNo%>&ubiLastLineNo=<%=ubiLastLineNo%>');
}

function showUbicacionMedList()
{
  abrir_ventana1('../common/check_ubicacion_med.jsp?fp=medico&mode=<%=mode%>&id=<%=id%>&espLastLineNo=<%=espLastLineNo%>&socLastLineNo=<%=socLastLineNo%>&ubiLastLineNo=<%=ubiLastLineNo%>');
}

function principalChecked()
{
	if (document.form3.baction.value == 'Guardar' && <%=iUbi.size()%> != 0)
	{
<%
for (int i=1; i<=iUbi.size(); i++)
{
%>
		<%=(i==1)?"":"else "%>if (document.form3.principal<%=i%>.checked) return true;
<%
}
%>
		return false;
	}
	else return true;
}

function doAction()
{
	showHide(1);
	showHide(2);
	showHide(3);
	setId(false);
	ctrlEmpresa(document.form0.pagarBen.value);
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
	showEspecialidadList();
<%
		}
		else if (tab.equals("2"))
		{
%>
	showSociedadList();
<%
		}
		else if (tab.equals("3"))
		{
%>
	showUbicacionMedList();
<%
		}
	}
%>
}
function checkMedico(obj)
{
if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','codigo=\''+obj.value+'\'','<%=med.getColValue("codigo").trim()%>'))
			{
					 document.form0.codigo.value = '';
					 return true;
			} else return false;
}
function checkMed(obj)
{
if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','reg_medico=\''+obj.value+'\'','<%=med.getColValue("reg_medico").trim()%>'))
			{
					 document.form0.reg_medico.value = '';
					 return true;
			} else return false;
}

function ctrlEmpresa(val){
  if(val=="E"){
    //document.getElementById("codEmpresa").style.display="inline";
		document.getElementById("codEmpresa").className="FormDataObjectRequired";
		document.getElementById("empresaNombre").className="FormDataObjectRequired";
		document.getElementById("btnEmpresa").disabled=false;
  }else{
		document.getElementById("codEmpresa").value="";
		document.getElementById("empresaNombre").value="";
		document.getElementById("codEmpresa").className="FormDataObjectDisabled";
		document.getElementById("empresaNombre").className="FormDataObjectDisabled";
		document.getElementById("btnEmpresa").disabled=true;
	}
}
function _doSubmit(){
 	var tipo =  document.getElementById("pagarBen").value;
	var empresa =  document.getElementById("codEmpresa").value;
 	if(tipo =='E' && empresa ==''){CBMSG.warning("Estimado usuario para el tipo de beneficiario seleccionado debe agregar la Empresa!"); return false;}
    return true;
}
function setId(clearOnChange){
<%
	//if (!viewMode){
%>
	if (document.form0.tipo_id.value == 'C')
	{
		document.form0.pasaporte.className = 'FormDataObjectDisabled';
		document.form0.pasaporte.readOnly = true;
		if (clearOnChange) document.form0.pasaporte.value = '';

		document.form0.provincia_ced.className = 'FormDataObjectEnabled';
		document.form0.sigla.className = 'FormDataObjectEnabled';
		document.form0.tomo.className = 'FormDataObjectEnabled';
		document.form0.asiento.className = 'FormDataObjectEnabled';
		document.form0.provincia_ced.readOnly = false;
		document.form0.sigla.readOnly = false;
		document.form0.tomo.readOnly = false;
		document.form0.asiento.readOnly = false;
	}
	else if (document.form0.tipo_id.value == 'P')
	{
		document.form0.provincia_ced.className = 'FormDataObjectDisabled';
		document.form0.sigla.className = 'FormDataObjectDisabled';
		document.form0.tomo.className = 'FormDataObjectDisabled';
		document.form0.asiento.className = 'FormDataObjectDisabled';
		document.form0.provincia_ced.readOnly = true;
		document.form0.sigla.readOnly = true;
		document.form0.tomo.readOnly = true;
		document.form0.asiento.readOnly = true;
		if (clearOnChange)
		{
			document.form0.provincia_ced.value = '';
			document.form0.sigla.value = '';
			document.form0.tomo.value = '';
			document.form0.asiento.value = '';
		}

		document.form0.pasaporte.className = 'FormDataObjectEnabled';
		document.form0.pasaporte.readOnly = false;
	}
	chkReqCampos();
<%
	//}
%>
}
function chkReqCampos(){
	if(document.form0.tipo_id.value=='C'){
		document.form0.provincia_ced.className = 'FormDataObjectRequired';
		document.form0.sigla.className = 'FormDataObjectRequired';
		document.form0.tomo.className = 'FormDataObjectRequired';
		document.form0.asiento.className = 'FormDataObjectRequired';
		document.form0.pasaporte.className = 'FormDataObjectDisabled';
	} else {
		document.form0.provincia_ced.className = 'FormDataObjectDisabled';
		document.form0.sigla.className = 'FormDataObjectDisabled';
		document.form0.tomo.className = 'FormDataObjectDisabled';
		document.form0.asiento.className = 'FormDataObjectDisabled';
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
		if(isNaN(obj.value.trim())||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','tipo_id=\'C\' and provincia_ced=\''+obj.value+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=med.getColValue("provincia_ced").trim()%>'))
			{
					 document.form0.provincia_ced.value = '';
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
	var provincia=document.form0.provincia_ced.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim(); 
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','tipo_id=\'C\' and provincia_ced=\''+provincia+'\' and sigla=\''+replaceAll(obj.value,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=med.getColValue("sigla").trim().replaceAll("'","\\\\'")%>'))
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
	var provincia=document.form0.provincia_ced.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var asiento=document.form0.asiento.value.trim(); 
		if(isNaN(provincia)||isNaN(obj.value.trim())||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','tipo_id=\'C\' and provincia_ced=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\'','<%=med.getColValue("tomo").trim()%>'))
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
	var provincia=document.form0.provincia_ced.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(obj.value.trim()))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','tipo_id=\'C\' and provincia_ced=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\'','<%=med.getColValue("asiento").trim()%>'))
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
	 
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_medico','tipo_id=\'P\' and identificacion=\''+obj.value+'\'','<%=med.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')

}
function tabFunctions(tab){
	var iFrameName = '';
	if(tab==4) iFrameName='alquilerFrame';
	if(iFrameName!='')window.frames[iFrameName].doAction();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISIÓN - MANTENIMIENTO - MÉDICO"></jsp:param>
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
<%=fb.hidden("espSize",""+iEsp.size())%>
<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
<%=fb.hidden("socSize",""+iSoc.size())%>
<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
<%=fb.hidden("ubiSize",""+iUbi.size())%>
<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
<%=fb.hidden("fp",fp)%>
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
								Registro M&eacute;dico
							</td>
						    <td width="35%">
						    	<table width="100%">
						    		<tr>
						    			<td><%=fb.textBox("codigo",med.getColValue("codigo"),true,false,false,15,15,null,null,"onBlur=\"javascript:checkMedico(this)\"")%></td>
						    			<td>Referencia:<%=fb.textBox("referencia",med.getColValue("referencia"),false,false,false,10,10,null,null,null)%>
						    			</td>
						    		</tr>
						    	</table>
						    </td>
							<td width="15%" align="right">Estado</td>
						    <td width="35%"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",med.getColValue("estado"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="4">Registro M&eacute;dico Correcto</cellbytelabel></td>
							<td><%=fb.textBox("reg_medico",med.getColValue("reg_medico"),false,false,false,15,15,null,null,"onBlur=\"javascript:checkMed(this)\"")%></td>
							<td align="right">&nbsp;</td>
					    	<td>&nbsp;</td>
						</tr>
						
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="4">Primer Nombre</cellbytelabel></td>
							<td><%=fb.textBox("primerNombre",med.getColValue("primerNombre"),true,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="5">Sexo</cellbytelabel></td>
					    	<td><%=fb.select("sexo","F=FEMENINO,M=MASCULINO",med.getColValue("sexo"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="6">Segundo Nombre</cellbytelabel></td>
							<td><%=fb.textBox("segundoNombre",med.getColValue("segundoNombre"),false,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="7">Estado Civil</cellbytelabel></td>
							<td><%=fb.select("estadoCivil","CS=CASADO,DV=DIVORCIADO,ST=SOLTERO,VD=VIUDO,UN=UNIDO,SP=SEPARADO",med.getColValue("estadoCivil"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="8">Apellido Paterno</cellbytelabel></td>
							<td><%=fb.textBox("primerApellido",med.getColValue("primerApellido"),true,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="9">Fecha Nacimiento</cellbytelabel></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fechaDeNacimiento" />
								<jsp:param name="valueOfTBox1" value="<%=med.getColValue("fechaDeNacimiento")%>" />
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="10">Apellido Materno</cellbytelabel></td>
					    <td><%=fb.textBox("segundoApellido",med.getColValue("segundoApellido"),false,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="11">Tipo de Medico</cellbytelabel></td>
					    <td><%=fb.select("tipoMedico","1=NORMAL,2=ACCIONISTA",med.getColValue("tipoMedico"))%></td>
							<td></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="12">Apellido de Casada</cellbytelabel></td>
							<td><%=fb.textBox("apellidoDeCasada",med.getColValue("apellidoDeCasada"),false,false,false,30,30)%></td>
							<td align="right"><cellbytelabel id="13">Tipo de Persona</cellbytelabel></td>
					    <td><%=fb.select("tipoPersona","1=NATURAL,2=JURIDICA",med.getColValue("tipoPersona"))%></td>
						</tr>
						<tr class="TextRow01">
						  <td align="right"><cellbytelabel id="14">Retenci&oacute;n</cellbytelabel></td>
					    <td><%=fb.select("retencion","S=SI,N=NO",med.getColValue("retencion"))%></td>
							<td align="right"><cellbytelabel id="15">Ced. / Pas.:<%=fb.select("tipo_id","C=Cedula,P=Pasaporte",med.getColValue("tipo_id"),false,viewMode,0,null,null,"onChange=\"javascript:setId(true)\"")%></cellbytelabel></td>
					        <td>
							
							<%=fb.intBox("provincia_ced",med.getColValue("provincia_ced"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
							<%=fb.textBox("sigla",med.getColValue("sigla"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%>
							<%=fb.intBox("tomo",med.getColValue("tomo"),false,false,viewMode,5,4,null,null,"onBlur=\"javascript:checkTomo(this)\"")%>
							<%=fb.intBox("asiento",med.getColValue("asiento"),false,false,viewMode,6,6,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>
							<br>
							Pasaporte:<%=fb.textBox("pasaporte",med.getColValue("pasaporte"),false,false,viewMode,20,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%>
						
							<%//=fb.textBox("identificacion",med.getColValue("identificacion"),false,false,false,20,20)%>&nbsp;D.V.<%=fb.intBox("digitoVerificador",med.getColValue("digitoVerificador"),false,false,false,3,3)%></td>
						</tr> 
						<tr class="TextRow01">
						  <td align="right"><cellbytelabel id="16">Cheque a Nombre de</cellbytelabel></td>
					    <td><%=fb.select("pagarBen","M=MÉDICO,E=RAZON SOCIAL O EMPRESA",med.getColValue("pagarBen"),false,false,false,0,"","","onchange=ctrlEmpresa(this.value)","","M")%></td>
						 <td align="right"><cellbytelabel id="17">Empresa del Cheque</cellbytelabel></td>
					    <td>
								<%=fb.intBox("codEmpresa",med.getColValue("codEmpresa"),false,false,true,5,null,null,"onDblClick=\"javascript:clearEmpresa()\"")%>
								<%=fb.textBox("empresaNombre",med.getColValue("empresaNombre"),false,false,true,30,null,null,"onDblClick=\"javascript:clearEmpresa()\"")%>
								<%=fb.button("btnEmpresa","...",false,false,null,null,"onClick=\"javascript:showEmpresaList()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="18">Religi&oacute;n</cellbytelabel></td>
					    <td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo, codigo from tbl_adm_religion order by descripcion","religion",med.getColValue("religion"),"S")%></td>
							<td align="right"><cellbytelabel id="19">Nacionalidad</cellbytelabel></td>
					    <td><%=fb.select(ConMgr.getConnection(),"select codigo, nvl(nacionalidad,nombre)||' - '||codigo, codigo from tbl_sec_pais order by nvl(nacionalidad,nombre)","nacionalidad",med.getColValue("nacionalidad"),"S")%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="20">Beneficiario del Cheque</cellbytelabel></td>
					    <td><%=fb.textBox("beneficiario",med.getColValue("beneficiario"),false,false,false,30,100)%></td>
						  <td align="right"><cellbytelabel id="21">Liquidable</cellbytelabel></td>
							<td><%=fb.select("liquidable","S=SI,N=NO",med.getColValue("liquidable"))%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="21">Alquiler</cellbytelabel></td>
							<td><%=fb.select("alquiler","S=SI,N=NO",med.getColValue("alquiler"))%></td>
							<td align="right">Genera Orden de Pago (Plan M&eacute;dico)?</td>
					        <td><%=fb.select("genera_odp","S=Si,N=No",med.getColValue("genera_odp"))%></td>
						    
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>&nbsp;Forma de Pago</cellbytelabel></td>
							<td><%=fb.select("forma_pago","1=CHEQUE,2=ACH",med.getColValue("forma_pago"))%></td>
							<td colspan="2">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="44">Tipo de Cuenta</cellbytelabel></td>
					    	<td><%=fb.select("tipoCuenta","03=CORRIENTE,04=AHORRO,07=PRESTAMO,43=TARJ. CRÉDITO",med.getColValue("tipoCuenta"),"S")%>
							</td>
							<td align="right">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						
						 <tr class="TextRow01">
							<td align="right"><cellbytelabel id="42">Cuenta Bancaria</cellbytelabel></td>
					    	<td><%=fb.textBox("cuentaBancaria",med.getColValue("cuentaBancaria"),false,false,false,18,18)%></td>
							<td align="right"><cellbytelabel id="43">Ruta de Tr&aacute;nsito</cellbytelabel></td>
							<td><%=fb.select(ConMgr.getConnection(),"select ruta, nombre_banco||' - '||ruta from tbl_adm_ruta_transito order by nombre_banco, ruta","rutaTransito",med.getColValue("rutaTransito"),"S")%></td>
						</tr>
						
						 <tr class="TextRow01">
							<td align="right"><cellbytelabel id="42">Porcentaje de Retencion (Comision por Manejo de Honorarios Medicos en Hospital) % </cellbytelabel></td>
					    	<td><%=fb.decBox("porc_retencion",med.getColValue("porc_retencion"),false,false,false,5,"10.2",null,null,"")%>Ejemplo:5,10,15 </td> 
							<td align="right">&nbsp;</td>
							<td align="right">&nbsp;</td>
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
							<td width="35%"><%=fb.textBox("direccion",med.getColValue("direccion"),false,false,false,30,100)%></td>
							<td width="15%" align="right"><cellbytelabel id="24">Tel&eacute;fono</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("telefono",med.getColValue("telefono"),false,false,false,13,13)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="25">Tel&eacute;fono Celular</cellbytelabel></td>
							<td><%=fb.textBox("celular",med.getColValue("celular"),false,false,false,13,13)%></td>
							<td align="right"><cellbytelabel id="26">N&uacute;mero Beeper</cellbytelabel></td>
							<td><%=fb.textBox("bepper",med.getColValue("bepper"),false,false,false,13,13)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="27">Direcci&oacute;n Postal</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="28">Apartado</cellbytelabel></td>
							<td><%=fb.textBox("apartadoPostal",med.getColValue("apartadoPostal"),false,false,false,20,20)%></td>
							<td align="right"><!--<cellbytelabel id="29">Zona</cellbytelabel>--></td>
							<td><%/*=fb.textBox("zonaPostal",med.getColValue("zonaPostal"),false,false,false,20,20)*/%>
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
								<%=fb.intBox("pais",med.getColValue("pais"),false,false,true,6,null,null,"onDblClick=\"javascript:clearPais()\"")%>
								<%=fb.textBox("paisNombre",med.getColValue("paisNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearPais()\"")%>
							</td>
							<td align="right"><cellbytelabel id="32">Provincia</cellbytelabel></td>
							<td>
								<%=fb.intBox("provincia",med.getColValue("provincia"),false,false,true,6,null,null,"onDblClick=\"javascript:clearProvincia()\"")%>
								<%=fb.textBox("provinciaNombre",med.getColValue("provinciaNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearProvincia()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="33">Distrito</cellbytelabel></td>
							<td>
								<%=fb.intBox("distrito",med.getColValue("distrito"),false,false,true,6,null,null,"onDblClick=\"javascript:clearDistrito()\"")%>
								<%=fb.textBox("distritoNombre",med.getColValue("distritoNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearDistrito()\"")%>
							</td>
							<td align="right"><cellbytelabel id="34">Corregimiento</cellbytelabel></td>
							<td>
								<%=fb.intBox("corregimiento",med.getColValue("corregimiento"),false,false,true,6,null,null,"onDblClick=\"javascript:clearCorregimiento()\"")%>
								<%=fb.textBox("corregimientoNombre",med.getColValue("corregimientoNombre"),false,false,true,40,null,null,"onDblClick=\"javascript:clearCorregimiento()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="35">Comunidad</cellbytelabel></td>
							<td>
								<%=fb.intBox("comunidad",med.getColValue("comunidad"),false,false,false,6,null,null,"onDblClick=\"javascript:clearComunidad()\"")%>
								<%=fb.textBox("comunidadNombre",med.getColValue("comunidadNombre"),false,false,false,40,null,null,"onDblClick=\"javascript:clearComunidad()\"")%>
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
					    <td width="35%"><%=fb.textBox("lugarDeTrabajo",med.getColValue("lugarDeTrabajo"),false,false,false,40,80)%></td>
							<td width="15%" align="right"><cellbytelabel id="37">Tel&eacute;fono de Trabajo</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("telefonoTrabajo",med.getColValue("telefonoTrabajo"),false,false,false,13,13)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="38">Extensi&oacute;n Tel&eacute;fonica</cellbytelabel></td>
					    <td><%=fb.textBox("extension",med.getColValue("extension"),false,false,false,6,6)%></td>
							<td align="right"><cellbytelabel id="39">Correo Electronico</cellbytelabel></td>
							<td><%=fb.emailBox("eMail",med.getColValue("eMail"),false,false,false,40,100)%>
						</tr>
						<tr class="TextRow01">
						  <td align="right"><cellbytelabel id="40">N&uacute;mero de Fax</cellbytelabel></td>
					    <td><%=fb.textBox("fax",med.getColValue("fax"),false,false,false,13,13)%></td>
							<td align="right">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						</table>
          </td>
        </tr>

				<tr>
					<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="41">Observaciones</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel3">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="41">Observaciones</cellbytelabel></td>
							<td colspan="3"><%=fb.textarea("observaciones",med.getColValue("observaciones"),false,false,false,80,5)%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
<jsp:include page="../common/bitacora.jsp" flush="true">
	<jsp:param name="audTable" value="tbl_adm_medico"></jsp:param>
	<jsp:param name="audFilter" value="<%="codigo='"+id+"'"%>"></jsp:param>
</jsp:include>
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
<%=fb.hidden("espSize",""+iEsp.size())%>
<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
<%=fb.hidden("socSize",""+iSoc.size())%>
<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
<%=fb.hidden("ubiSize",""+iUbi.size())%>
<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
<%=fb.hidden("fp",fp)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="48">M&eacute;dico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="2">Registro M&eacute;dico</cellbytelabel></td>
							<td width="15%"><%=med.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel id="49">Nombre</cellbytelabel></td>
							<td width="55%">
								<%=med.getColValue("primerNombre")%>
								<%=(med.getColValue("segundoNombre") != null && !med.getColValue("segundoNombre").equals(""))?" "+med.getColValue("segundoNombre"):""%>
								<%=" "+med.getColValue("primerApellido")%>
								<%=(med.getColValue("segundoApellido") != null && !med.getColValue("segundoApellido").equals(""))?" "+med.getColValue("segundoApellido"):""%>
							</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="50">Especialidades del M&eacute;dico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="51">Secuencia</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="52">C&oacute;digo</cellbytelabel></td>
							<td width="60%"><cellbytelabel id="53">Nombre de la Especialidad</cellbytelabel></td>
							<td width="15%"><cellbytelabel id="54">A partir de</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addEspecialidad","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Especialidades")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iEsp);
for (int i=1; i<=iEsp.size(); i++)
{
  key = al.get(i - 1).toString();
  CommonDataObject cdo = (CommonDataObject) iEsp.get(key);
	String fechaCreacion = "fechaCreacion"+i;
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
						<%=fb.hidden("especialidad"+i,cdo.getColValue("especialidad"))%>
						<%=fb.hidden("especialidadDesc"+i,cdo.getColValue("especialidadDesc"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("secuencia")%></td>
							<td><%=cdo.getColValue("especialidad")%></td>
							<td><%=cdo.getColValue("especialidadDesc")%></td>
							<td align="center">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="<%=fechaCreacion%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCreacion")%>" />
								</jsp:include>
							</td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Especialidad")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="44">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="45">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel id="46">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="47">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
<%=fb.hidden("espSize",""+iEsp.size())%>
<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
<%=fb.hidden("socSize",""+iSoc.size())%>
<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
<%=fb.hidden("ubiSize",""+iUbi.size())%>
<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
<%=fb.hidden("fp",fp)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="48">M&eacute;dico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="2">Registro M&eacute;dico</cellbytelabel></td>
							<td width="15%"><%=med.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel id="49">Nombre</cellbytelabel></td>
							<td width="55%">
								<%=med.getColValue("primerNombre")%>
								<%=(med.getColValue("segundoNombre") != null && !med.getColValue("segundoNombre").equals(""))?" "+med.getColValue("segundoNombre"):""%>
								<%=" "+med.getColValue("primerApellido")%>
								<%=(med.getColValue("segundoApellido") != null && !med.getColValue("segundoApellido").equals(""))?" "+med.getColValue("segundoApellido"):""%>
							</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="55">Sociedad a las que Pertenece el M&eacute;dico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="52">C&oacute;digo</cellbytelabel></td>
							<td width="30%">Nombre de la Sociedad</td>
							<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>
							<td width="45%"><cellbytelabel id="56">Comentario</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addSociedad","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Sociedades")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iSoc);
for (int i=1; i<=iSoc.size(); i++)
{
  key = al.get(i - 1).toString();
  CommonDataObject cdo = (CommonDataObject) iSoc.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
						<%=fb.hidden("empresaNombre"+i,cdo.getColValue("empresaNombre"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("empresa")%></td>
							<td><%=cdo.getColValue("empresaNombre")%></td>
							<td align="center"><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
							<td align="center"><%=fb.textarea("comentario"+i,cdo.getColValue("comentario"),false,false,false,50,2)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="44">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="45">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel id="46">Mantener Abierto </cellbytelabel>
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="47">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%>
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
<%=fb.hidden("espSize",""+iEsp.size())%>
<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
<%=fb.hidden("socSize",""+iSoc.size())%>
<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
<%=fb.hidden("ubiSize",""+iUbi.size())%>
<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
<%=fb.hidden("fp",fp)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="48">M&eacute;dico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="2">Registro M&eacute;dico</cellbytelabel></td>
							<td width="15%"><%=med.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel id="49">Nombre</cellbytelabel></td>
							<td width="55%">
								<%=med.getColValue("primerNombre")%>
								<%=(med.getColValue("segundoNombre") != null && !med.getColValue("segundoNombre").equals(""))?" "+med.getColValue("segundoNombre"):""%>
								<%=" "+med.getColValue("primerApellido")%>
								<%=(med.getColValue("segundoApellido") != null && !med.getColValue("segundoApellido").equals(""))?" "+med.getColValue("segundoApellido"):""%>
							</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="57">Ubicaciones del M&eacute;dico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel31">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel id="52">C&oacute;digo</cellbytelabel></td>
							<td width="52%">Ubicaci&oacute;n</td>
							<td width="20%"><cellbytelabel id="24">Tel&eacute;fono</cellbytelabel></td>
							<td width="8%">Principal?</td>
							<td width="5%"><%=fb.submit("addUbicacion","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Ubicaciones")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iUbi);
for (int i=1; i<=iUbi.size(); i++)
{
  key = al.get(i - 1).toString();
  CommonDataObject cdo = (CommonDataObject) iUbi.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("ubicacion"+i,cdo.getColValue("ubicacion"))%>
						<%=fb.hidden("ubicacionDesc"+i,cdo.getColValue("ubicacionDesc"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("ubicacion")%></td>
							<td><%=cdo.getColValue("ubicacionDesc")%></td>
							<td align="center"><%=fb.textBox("telefono"+i,cdo.getColValue("telefono"),false,false,false,30)%></td>
							<td align="center"><%=fb.checkbox("principal"+i,"S",(cdo.getColValue("principal").equalsIgnoreCase("S")),false,null,null,"onClick=\"javascript:checkOne('form3','principal',"+iUbi.size()+",this,1)\"")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="44">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="45">Crear Otro </cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel id="46">Mantener Abierto </cellbytelabel>
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="47">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%fb.appendJsValidation("if(!principalChecked()){CBMSG.warning(\'Por favor asignar una ubicación principal!\');error++;}");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>

<!----------------------------------------ALQUILER-------------------------------------------------->
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
<%=fb.hidden("espSize",""+iEsp.size())%>
<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
<%=fb.hidden("socSize",""+iSoc.size())%>
<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
<%=fb.hidden("ubiSize",""+iUbi.size())%>
<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
<%=fb.hidden("fp",fp)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr id="panel30">
					<td colspan="6"><iframe name="alquilerFrame" id="alquilerFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../admision/reg_alquiler.jsp?mode=<%=mode%>&id_ref=<%=id%>&tipo=M&tab=4"></iframe></td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Médico'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Médico','Especialidad','Sociedad','Ubicación','Alquiler'),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),null);

<%
}
%>
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
	if (tab.equals("0")) //MEDICO
	{
		med = new CommonDataObject();

  		med.setTableName("tbl_adm_medico");
		med.addColValue("estado",request.getParameter("estado"));
		med.addColValue("primer_nombre",request.getParameter("primerNombre"));
		if (request.getParameter("sexo") != null && !request.getParameter("sexo").equals("")) med.addColValue("sexo",request.getParameter("sexo"));
		if (request.getParameter("segundoNombre") != null) med.addColValue("segundo_nombre",request.getParameter("segundoNombre"));
		if (request.getParameter("estadoCivil") != null) med.addColValue("estado_civil",request.getParameter("estadoCivil"));
		med.addColValue("primer_apellido",request.getParameter("primerApellido"));
		if (request.getParameter("fechaDeNacimiento") != null) med.addColValue("fecha_de_nacimiento",request.getParameter("fechaDeNacimiento"));
		if (request.getParameter("segundoApellido") != null) med.addColValue("segundo_apellido",request.getParameter("segundoApellido"));
		if (request.getParameter("digitoVerificador") != null) med.addColValue("digito_verificador",request.getParameter("digitoVerificador"));
		if (request.getParameter("apellidoDeCasada") != null) med.addColValue("apellido_de_casada",request.getParameter("apellidoDeCasada"));
		if (request.getParameter("tipoPersona") != null) med.addColValue("tipo_persona",request.getParameter("tipoPersona"));
		if (request.getParameter("tipoMedico") != null) med.addColValue("tipo_medico",request.getParameter("tipoMedico"));
		if (request.getParameter("retencion") != null) med.addColValue("retencion",request.getParameter("retencion"));
		if (request.getParameter("pagarBen") != null) med.addColValue("pagar_ben",request.getParameter("pagarBen"));
		if (request.getParameter("codEmpresa") != null) med.addColValue("cod_empresa",request.getParameter("codEmpresa"));
		if (request.getParameter("religion") != null) med.addColValue("religion",request.getParameter("religion"));
		if (request.getParameter("nacionalidad") != null) med.addColValue("nacionalidad",request.getParameter("nacionalidad"));
		if (request.getParameter("beneficiario") != null) med.addColValue("beneficiario",request.getParameter("beneficiario"));
		if (request.getParameter("liquidable") != null) med.addColValue("liquidable",request.getParameter("liquidable"));
		if (request.getParameter("alquiler") != null) med.addColValue("alquiler",request.getParameter("alquiler"));
		if (request.getParameter("direccion") != null) med.addColValue("direccion",request.getParameter("direccion"));
		if (request.getParameter("telefono") != null) med.addColValue("telefono",request.getParameter("telefono"));
		if (request.getParameter("celular") != null) med.addColValue("celular",request.getParameter("celular"));
		if (request.getParameter("bepper") != null) med.addColValue("bepper",request.getParameter("bepper"));
		if (request.getParameter("apartadoPostal") != null) med.addColValue("apartado_postal",request.getParameter("apartadoPostal"));
		if (request.getParameter("zonaPostal") != null) med.addColValue("zona_postal",request.getParameter("zonaPostal"));
		if (request.getParameter("pais") != null) med.addColValue("pais",request.getParameter("pais"));
		if (request.getParameter("provincia") != null) med.addColValue("provincia",request.getParameter("provincia"));
		if (request.getParameter("distrito") != null) med.addColValue("distrito",request.getParameter("distrito"));
		if (request.getParameter("corregimiento") != null) med.addColValue("corregimiento",request.getParameter("corregimiento"));
		if (request.getParameter("comunidad") != null) med.addColValue("comunidad",request.getParameter("comunidad"));
		if (request.getParameter("genera_odp") != null) med.addColValue("genera_odp",request.getParameter("genera_odp"));

		if (request.getParameter("reg_medico") != null) med.addColValue("reg_medico",request.getParameter("reg_medico"));
		if (request.getParameter("lugarDeTrabajo") != null) med.addColValue("lugar_de_trabajo",request.getParameter("lugarDeTrabajo"));
		if (request.getParameter("telefonoTrabajo") != null) med.addColValue("telefono_trabajo",request.getParameter("telefonoTrabajo"));
		if (request.getParameter("extension") != null) med.addColValue("extension",request.getParameter("extension"));
		if (request.getParameter("eMail") != null) med.addColValue("e_mail",request.getParameter("eMail"));
		if (request.getParameter("fax") != null) med.addColValue("fax",request.getParameter("fax"));

		if (request.getParameter("observaciones") != null) med.addColValue("observaciones",request.getParameter("observaciones"));
		if (request.getParameter("cuentaBancaria") != null) med.addColValue("cuenta_bancaria",request.getParameter("cuentaBancaria"));
		if (request.getParameter("rutaTransito") != null) med.addColValue("ruta_transito",request.getParameter("rutaTransito"));
		if (request.getParameter("tipoCuenta") != null) med.addColValue("tipo_cuenta",request.getParameter("tipoCuenta"));
		if (request.getParameter("forma_pago") != null) med.addColValue("forma_pago",request.getParameter("forma_pago"));

		med.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
		med.addColValue("fecha_modifica",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

		if (request.getParameter("referencia") != null ) med.addColValue("referencia",request.getParameter("referencia"));
		
		if (request.getParameter("tipo_id") != null) med.addColValue("tipo_id",request.getParameter("tipo_id")); 
		if (request.getParameter("provincia_ced") != null) med.addColValue("provincia_ced",request.getParameter("provincia_ced")); 
		if (request.getParameter("sigla") != null) med.addColValue("sigla",request.getParameter("sigla")); 
		if (request.getParameter("tomo") != null) med.addColValue("tomo",request.getParameter("tomo")); 
		if (request.getParameter("asiento") != null) med.addColValue("asiento",request.getParameter("asiento"));  
		med.addColValue("porc_retencion",request.getParameter("porc_retencion"));
		if (request.getParameter("tipo_id") != null)
		{
		 if (request.getParameter("tipo_id").trim().equals("C"))med.addColValue("identificacion",request.getParameter("provincia_ced")+"-"+request.getParameter("sigla")+"-"+request.getParameter("tomo")+"-"+request.getParameter("asiento"));
		 else med.addColValue("identificacion",request.getParameter("pasaporte"));
		 
		 }
   

	  	if (mode.equalsIgnoreCase("add"))
  		{
			med.addColValue("codigo",request.getParameter("codigo"));
			med.addColValue("usuario_adiciona",(String) session.getAttribute("_userName"));
			med.addColValue("fecha_adiciona",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

			SQLMgr.insert(med);
			id = request.getParameter("codigo");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			med.setWhereClause("codigo='"+id+"'");

			SQLMgr.update(med);
		}
	}
	else if (tab.equals("1")) //ESPECIALIDAD
	{
		int size = 0;
		if (request.getParameter("espSize") != null) size = Integer.parseInt(request.getParameter("espSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_especialidad");
			cdo.setWhereClause("medico='"+id+"'");
			if (request.getParameter("secuencia"+i) != null && !request.getParameter("secuencia"+i).equals("0"))
			{
				cdo.addColValue("secuencia",request.getParameter("secuencia"+i));
			}
			else
			{
				cdo.setAutoIncCol("secuencia");
				cdo.setAutoIncWhereClause("medico='"+id+"'");
			}
			cdo.addColValue("especialidad",request.getParameter("especialidad"+i));
			cdo.addColValue("medico",id);
			cdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"+i));

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("especialidadDesc",request.getParameter("especialidadDesc"+i));
			cdo.addColValue("fechaCreacion",request.getParameter("fechaCreacion"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iEsp.put(cdo.getColValue("key"),cdo);
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
			vEsp.remove(((CommonDataObject) iEsp.get(itemRemoved)).getColValue("especialidad"));
    	iEsp.remove(itemRemoved);

	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_especialidad");
			cdo.setWhereClause("medico="+id);

			al.add(cdo);
		}

		SQLMgr.insertList(al);
	}
	else if (tab.equals("2")) //SOCIEDAD
	{
		int size = 0;
		if (request.getParameter("socSize") != null) size = Integer.parseInt(request.getParameter("socSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_sociedad_medica");
			cdo.setWhereClause("medico='"+id+"'");
			cdo.addColValue("empresa",request.getParameter("empresa"+i));
			cdo.addColValue("medico",id);
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("comentario",request.getParameter("comentario"+i));

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("empresaNombre",request.getParameter("empresaNombre"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iSoc.put(cdo.getColValue("key"),cdo);
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
			vSoc.remove(((CommonDataObject) iSoc.get(itemRemoved)).getColValue("empresa"));
    	iSoc.remove(itemRemoved);

	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_sociedad_medica");
			cdo.setWhereClause("medico='"+id+"'");

			al.add(cdo);
		}

		SQLMgr.insertList(al);
	}
	else if (tab.equals("3")) //UBICACION
	{
		int size = 0;
		if (request.getParameter("ubiSize") != null) size = Integer.parseInt(request.getParameter("ubiSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_ubicacion");
			cdo.setWhereClause("medico='"+id+"'");
			cdo.addColValue("ubicacion",request.getParameter("ubicacion"+i));
			cdo.addColValue("medico",id);
			cdo.addColValue("telefono",request.getParameter("telefono"+i));
			cdo.addColValue("principal",(request.getParameter("principal"+i) == null)?"N":"S");

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("ubicacionDesc",request.getParameter("ubicacionDesc"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iUbi.put(cdo.getColValue("key"),cdo);
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
			vUbi.remove(((CommonDataObject) iUbi.get(itemRemoved)).getColValue("ubicacion"));
    	iUbi.remove(itemRemoved);

	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_ubicacion");
			cdo.setWhereClause("medico='"+id+"'");

			al.add(cdo);
		}

		SQLMgr.insertList(al);
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
	if (tab.equals("0"))
	{
		if(fp!= null && fp.equalsIgnoreCase("admision"))
		{
%>
		window.opener.location = '<%=request.getContextPath()%>/common/search_medico.jsp?fp=admision_medico_esp';
		window.close();
<%
		}
		else if(fp!= null && fp.equalsIgnoreCase("admision_new"))
		{
%>
		window.opener.location = '<%=request.getContextPath()%>/common/search_medico.jsp?fp=admision_medico_resp_new&fg=admision_new';
		window.close();
<%
		}
		else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/medico_list.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/medico_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/medico_list.jsp';
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
} else throw new Exception(SQLMgr.getErrMsg());
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