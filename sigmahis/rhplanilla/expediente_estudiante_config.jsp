<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr"       scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr"       scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet"      scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr"       scope="page"    class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr"       scope="page"    class="issi.admin.SQLMgr" />
<jsp:useBean id="fb"           scope="page"    class="issi.admin.FormBean" />
<%
/**
================================================================================
800059	AGREGAR EXPEDIENTE DEL ESTUDIANTE
800060	MODIFICAR EXPEDIENTE DEL ESTUDIANTE
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject emple = new CommonDataObject();
ArrayList al = new ArrayList();
String sql="";
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
String tab = request.getParameter("tab");
String id= request.getParameter("id");
String key = "";
String change = request.getParameter("change");
String code =request.getParameter("code");
if(tab == null)  tab = "0";
if(mode == null) mode ="add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		//emple.addColValue("EST_ID","0");
		emple.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("ingreso",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("contrato","");
		emple.addColValue("egreso","");
		emple.addColValue("puestoA","");
		emple.addColValue("aumento","");
		emple.addColValue("incapacidad","");
		emple.addColValue("sigla","00");
		
			
	}
	else
	{
	if (prov == null) throw new Exception("La Provincia no es válido. Por favor intente nuevamente!");
	if (sig == null) throw new Exception("La Sigla no es válido. Por favor intente nuevamente!");
	if (tom == null) throw new Exception("El Tomo no es válido. Por favor intente nuevamente!");
	if (asi == null) throw new Exception("El Asiento no es válido. Por favor intente nuevamente!");
	
	code="0";
	sql="Select DISTINCT a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, a.foto, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1, nvl(a.segundo_apellido,' ') as apellido2, nvl(a.num_ssocial, ' ') as seguro, a.licencia_conducir as conducir, a.salario_base as salario, nvl(a.calle_dir, ' ') as calle, nvl(a.casa__dir, ' ') as casa, nvl(a.apartado_postal, ' ') as apartado, nvl(a.zona_postal, ' ') as zona, nvl(a.telefono_casa, ' ') as telcasa, nvl(a.telefono_otro, ' ') as telotros, nvl(a.lugar_telefono, ' ') as tellugar, a.nacionalidad as nacionalidadCode, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha, a.estado_civil as civil, a.sexo, a.vive_madre as vivemadre, a.vive_padre as vivepadre, nvl(a.nombre_madre, ' ') as madre, nvl(a.nombre_padre, ' ') as padre, nvl(a.emergencia_llamar, ' ') as llamar, a.telefono_emergencia as telefonos, nvl(a.email,' ') AS email, a.fecha_creacion as creacion, nvl(a.comentario, ' ') as comentario, to_char(a.fecha_ingreso, 'dd/mm/yyyy') as ingreso, to_char(a.FECHA_EGRESO,'dd/mm/yyyy') as egreso, a.estado, decode(a.comunidad_dir, null, ' ',a.comunidad_dir ) as comunidadC, decode(a.corregimiento_dir, null, ' ',a.corregimiento_dir) as corregimientoC, decode(a.distrito_dir,  null,'',a.distrito_dir) as distritoC, decode(a.provincia_dir, null, ' ', a.provincia_dir) as provinciaC, decode(a.pais_dir, null, ' ', a.pais_dir ) as paisC, a.compania_uniorg, a.unidad_organi as seccion, nvl(a.tipo_sangre, ' ') as sang, nvl(a.rh, ' ') as sangre, nvl(a.cargo_jefe, ' ') as jefe, nvl(b.nacionalidad, 'NA') as nacionalidad, nvl(d.nombre_comunidad, ' ') as comunidadN, nvl(d.nombre_corregimiento, ' ') as corregimientoN, nvl(d.nombre_distrito, ' ') as distritoN, nvl(d.nombre_provincia, ' ') as provinciaN, nvl(d.nombre_pais, ' ') as paisN, g.codigo as dire, g.descripcion as namedireccion, h.codigo as se, h.descripcion as nameseccion,a.cargo_jefe as cargo, i.denominacion as nameCargo, a.carrera as firma, a.centro_educativo as ruta, decode(a.foto,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("fotosimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.foto) as foto from tbl_pla_estudiante a, tbl_sec_pais b,  (select codigo_pais, nombre_pais,  decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null, nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, tbl_sec_unidad_ejec g, tbl_sec_unidad_ejec h, tbl_pla_cargo i where a.nacionalidad = b.codigo(+) and a.pais_dir = d.codigo_pais(+) and a.provincia_dir = d.codigo_provincia(+) and a.distrito_dir = d.codigo_distrito(+) and a.corregimiento_dir = d.codigo_corregimiento(+) and a.comunidad_dir = d.codigo_comunidad(+)/* and a.nacionalidad = d.codigo_pais(+)*/ and a.unidad_organi=g.codigo(+) and a.compania=g.compania(+) and a.unidad_organi=h.codigo(+) and a.compania= h.compania(+) and a.cargo_jefe= i.codigo(+) and a.compania = i.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" AND a.COMPANIA_UNIORG="+(String) session.getAttribute("_companyId")+" and  a.PROVINCIA="+prov+" and a.SIGLA='"+sig+"' and a.TOMO="+tom+" and a.ASIENTO="+asi;

		emple = SQLMgr.getData(sql);
		
			
	}//End Edit
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript" type="text/javascript">
<%if (mode.equalsIgnoreCase("add"))
{%>
document.title="Expediente de Estudiante - Agregar - "+document.title;
<%}
else if (mode.equalsIgnoreCase("edit")){%>
document.title="Expediente de Estudiante - Edición - "+document.title;
<%}%>

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

function agregar()
{
abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=empleNac');
}


function nacion()
{
abrir_ventana1('../rhplanilla/list_pais.jsp?id=1');
}

function Direcciones()
{
abrir_ventana1('../rhplanilla/list_direccion.jsp?fp=estudiante');
}

function Secciones()
{
abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=empleado');
}

function Cargosss()
{
abrir_ventana1('../rhplanilla/list_cargo.jsp?id=2');
}

function Formassss()
{
abrir_ventana1('../rhplanilla/list_forma.jsp?fp=estudiante');
}

function clearPais()
{
	document.form0.paisCode.value = '';
	document.form0.paisName.value = '';
	document.form0.provinciaCode.value = '';
	document.form0.provinciaName.value = '';
	document.form0.distritoCode.value = '';
	document.form0.distritoName.value = '';
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarPaisDir()
{
	document.form0.paisC.value = '';
	document.form0.paisN.value = '';
	document.form0.provinciaC.value = '';
	document.form0.provinciaN.value = '';
	document.form0.distritoC.value = '';
	document.form0.distritoN.value = '';
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';	
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearProvincia()
{
	document.form0.provinciaCode.value = '';
	document.form0.provinciaName.value = '';
	document.form0.distritoCode.value = '';
	document.form0.distritoName.value = '';
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarProvinDir()
{
	document.form0.provinciaC.value = '';
	document.form0.provinciaN.value = '';
	document.form0.distritoC.value = '';
	document.form0.distritoN.value = '';
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearDistrito()
{
	document.form0.distritoCode.value = '';
	document.form0.distritoName.value = '';
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarDistritDir()
{
	document.form0.distritoC.value = '';
	document.form0.distritoN.value = '';
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearCorregimiento()
{
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarCorregDir()
{
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';	
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearComunidad()
{
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function doAction()
{
	calculanor();
	//showHide(1);
	showHide(2);
	//showHide(3);
}

function calculanor(){ 

var hoy;
var edad;
var fecha;

	if (document.form0.fecha.value!="")
	{ 	
	fecha=document.form0.fecha.value;
	hoy=new Date() ;
	
    var array_fecha = fecha.split("/") ;
    if (array_fecha.length!=3) 	document.form0.edades.value=" ";
	
    var ano ;
    ano = parseInt(array_fecha[2]); 
    if (isNaN(ano))  document.form0.edades.value="";

    var mes ;
    mes = parseInt(array_fecha[1]); 
    if (isNaN(mes)) 
       document.form0.edades.value=" ";

    var dia ;
    dia = parseInt(array_fecha[0]); 
    if (isNaN(dia)) 
       document.form0.edades.value=" ";

    edad=hoy.getFullYear()- ano - 1; //-1 porque no se si ha cumplido años ya este año 

    if (hoy.getMonth() + 1 - mes < 0) //+ 1 porque los meses empiezan en 0 
	   document.form0.edades.value= edad ;
    if (hoy.getMonth() + 1 - mes > 0) 
       document.form0.edades.value= edad+1 ;

    if (hoy.getUTCDate() - dia >= 0) 
       document.form0.edades.value=edad + 1;
	   document.form0.edades.value=edad + 1;
	}
	
}




</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE DE ESTUDIANTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr>
          <td>
<!--<div id="dhtmlgoodies_tabView1">            
<div class="dhtmlgoodies_aTab">-->
<table width="100%" align="center" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
	<%=fb.formStart(true)%> 
	<%=fb.hidden("tab","0")%> 
	<%=fb.hidden("mode",mode)%> 
	<%=fb.hidden("prov",prov)%> 
	<%=fb.hidden("sig",sig)%> 
	<%=fb.hidden("tom",tom)%> 
	<%=fb.hidden("asi",asi)%> 
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("baction","")%> 
	<%=fb.hidden("code",code)%>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(0)" style="text-decorationl:none; cursor:pointer">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
                	<td width="95%">&nbsp;Expediente de Estudiante <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Generales del Estudiante</td>
                    <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
                </tr>
            </table>
		</td>
    </tr>
    <tr id="panel0">
      <td>
		<table width="100%" cellpadding="1" cellspacing="1">
        	<tr class="TextRow01">
				<td>&nbsp;C&eacute;dula</td>
                <td colspan="1"><%=fb.intBox("provincia",emple.getColValue("provincia"),true,mode.equals("edit"),false,5,2)%> 
						  <%=fb.textBox("sigla",emple.getColValue("sigla"),true,mode.equals("edit"),false,5,2)%> 
						  <%=fb.intBox("tomo",emple.getColValue("tomo"),true,mode.equals("edit"),false,5,4)%> 
						  <%=fb.intBox("asiento",emple.getColValue("asiento"),true,mode.equals("edit"),false,5,5)%></td>
           
		    	<td colspan="1">&nbsp;&nbsp;&nbsp;&nbsp;Foto</td>
				<td><%=fb.fileBox("foto",emple.getColValue("foto"),false,false,20)%></td>
		   
		   
		    </tr>
			<tr class="TextRow01">
            	<td width="17%">&nbsp;Primer Nombre</td>
                <td width="33%"><%=fb.textBox("nombre1",emple.getColValue("nombre1"),true,false,false,30,30)%></td>
                <td width="20%">&nbsp;Segundo Nombre</td>
                <td width="30%"><%=fb.textBox("nombre2",emple.getColValue("nombre2"),false,false,false,30,30)%></td>
			</tr>
			<tr class="TextRow01">
			    <td>&nbsp;Primer Apellido</td>
				<td><%=fb.textBox("apellido1",emple.getColValue("apellido1"),true,false,false,30,30)%></td>
                <td>&nbsp;Segundo Apellido</td>
                <td><%=fb.textBox("apellido2",emple.getColValue("apellido2"),false,false,false,30,30)%></td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Fecha Nacimiento</td>
                <td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("fecha")%>" />
							<jsp:param name="jsEvent" value="calculanor()" />
							</jsp:include>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Edad:&nbsp;&nbsp;
							<%=fb.textBox("edades","",false,false,true,5)%></td>
				<td>&nbsp;No. S.S.</td>
                <td><%=fb.textBox("seguro", emple.getColValue("seguro"),false,false,false,15,20)%></td>
             </tr>
            <tr class="TextRow01">
             	<td>&nbsp;Sexo</td>
                <td><%=fb.select("sexo","F=FEMENINO, M=MASCULINO",emple.getColValue("sexo"))%></td>
                <td>&nbsp;Nacionalidad</td>
                <td><%=fb.intBox("nacionalidadCode",emple.getColValue("nacionalidadCode"),true,false,true,5)%> 
						  <%=fb.textBox("nacionalidad",emple.getColValue("nacionalidad"),false,false,true,23)%><%=fb.button("btndireccion","Ir",true,false,null,null,"onClick=\"javascript:nacion()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Estado</td>
                <td><%=fb.select("estado","A=ACTIVO, R=RETIRADO",emple.getColValue("estado"))%></td>
				<td>&nbsp;Estado Civil</td>
                <td><%=fb.select("civil","CS=CASADO, DV=DIVORCIADO, SP=SEPARADO, ST=SOLTERO, UN=UNIDO, VD=VIUDO ",emple.getColValue("civil"))%></td>
            </tr>
            <tr class="TextHeader">
            	<td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull;&nbsp;Direcci&oacute;n</td>
             </tr>
            <tr class="TextRow01">
             	<td>&nbsp;Pa&iacute;s</td>
                 <td><%=fb.intBox("paisC",emple.getColValue("paisC"),false,false,true,5,null,null,"onDblClick=\"javascript:limpiarPaisDir()\"")%> 
						  <%=fb.textBox("paisN",emple.getColValue("paisN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarPaisDir()\"")%><%=fb.button("btndireccion","Ir",true,false,null,null,"onClick=\"javascript:agregar();\"")%></td>
                 <td>&nbsp;Provincia</td>
                 <td><%=fb.intBox("provinciaC",emple.getColValue("provinciaC"),false,false,true,5,null,null,"onDblClick=\"javascript:limpiarProvinDir()\"")%><%=fb.textBox("provinciaN",emple.getColValue("provinciaN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarProvinDir()\"")%> </td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Distrito</td>
                <td><%=fb.intBox("distritoC",emple.getColValue("distritoC"),false,false,true,5,null,null,"onDblClick=\"javascript:limpiarDistritDir()\"")%><%=fb.textBox("distritoN",emple.getColValue("distritoN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarDistritDir()\"")%> </td>
                <td>&nbsp;Corregimiento</td>
                <td><%=fb.intBox("corregimientoC",emple.getColValue("corregimientoC"),false,false,true,5,null,null,"onDblClick=\"javascript:limpiarCorregDir()\"")%> <%=fb.textBox("corregimientoN",emple.getColValue("corregimientoN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarCorregDir()\"")%> </td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Comunidad</td>
                <td><%=fb.intBox("comunidadC",emple.getColValue("comunidadC"),false,false,true,5,null,null,"onDblClick=\"javascript:clearComunidad()\"")%><%=fb.textBox("comunidadN",emple.getColValue("comunidadN"),false,false,true,23,null,null,"onDblClick=\"javascript:clearComunidad()\"")%> </td>
                <td>&nbsp;Calle</td>
                <td><%=fb.textBox("calle",emple.getColValue("calle"),false,false,false,34,50)%></td>                        
		    </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Casa</td>
                <td colspan="3"><%=fb.textBox("casa",emple.getColValue("casa"),false,false,false,34,50)%></td>
            </tr>
            <tr class="TextHeader">
            	<td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull;&nbsp;Telefono</td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Tel. Casa</td>
                <td><%=fb.textBox("telcasa",emple.getColValue("telcasa"),false,false,false,34,11)%></td>
                <td>&nbsp;Tel. Otros</td>
                <td><%=fb.textBox("telotros",emple.getColValue("telotros"),false,false,false,34,11)%></td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Tel. Lugar</td>
                <td colspan="3"><%=fb.textBox("tellugar",emple.getColValue("tellugar"),false,false,false,34,11)%></td>
            </tr>
            <tr class="TextHeader">
            	<td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull;&nbsp;Direccion Postal</td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Apartado</td>
                <td><%=fb.textBox("apartado",emple.getColValue("apartado"),false,false,false,34,20)%></td>
                <td>&nbsp;Zona</td>
                <td><%=fb.textBox("zona",emple.getColValue("zona"),false,false,false,34,20)%></td>
            </tr>
            <tr class="TextRow01">
            	<td>&nbsp;Correo Electronico</td>
                <td colspan="3"><%=fb.emailBox("email",emple.getColValue("email"),false,false,false,34,100)%></td>
            </tr>
        </table>
	  </td>
    </tr>
    <tr>
    	<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
			<table width="100%" cellpadding="1" cellspacing="0">
            	<tr class="TextPanel">
                	<td width="95%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Generales de Trabajo</td>
                    <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
                </tr>
             </table>             
		</td>
    </tr>
	<tr id="panel1">
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" align="center">
				 <tr class="TextRow01">
					<td width="17%">&nbsp;Salario Base</td>
					<td><%=fb.decBox("salario",emple.getColValue("salario"),true,false,false,20,13.2)%></td>
					<td width="20%">&nbsp;Direcci&oacute;n</td>
					<td width="30%"><%=fb.intBox("direccion",emple.getColValue("dire"),false,false,true,5,4)%> <%=fb.textBox("namedireccion",emple.getColValue("namedireccion"),false,false,true,23)%><%=fb.button("btnDireccion","Ir",true,false,null,null,"onClick=\"javascript:Direcciones();\"")%></td>
				  </tr>
                 <tr class="TextRow01">
                 	<td>&nbsp;Unidad Administrativa </td>
                   	<td><%=fb.intBox("seccion",emple.getColValue("seccion"),true,false,true,5,4)%> <%=fb.textBox("nameseccion",emple.getColValue("nameseccion"),false,false,true,23)%> <%=fb.button("btnSeccion","Ir",true,false,null,null,"onClick=\"javascript:Secciones();\"")%> </td>
                    <td>&nbsp;Cargo Jefe </td>
                    <td><%=fb.textBox("cargo",emple.getColValue("cargo"),true,false,true,5,12)%> <%=fb.textBox("nameCargo",emple.getColValue("nameCargo"),false,false,true,23)%> <%=fb.button("btnCargo","Ir",true,false,null,null,"onClick=\"javascript:Cargosss()\"")%> </td>
                 </tr>
				 <tr class="TextRow01">
					 <td>&nbsp;Centro Educativo </td>
					 <td><%=fb.textBox("ruta",emple.getColValue("ruta"),false,false,false,34,60)%></td>
					 <td>&nbsp;Carrera</td>
					 <td><%=fb.textBox("firma",emple.getColValue("firma"),false,false,false,34,60)%></td>
				 </tr>
                 <tr class="TextRow01">
                 	<td>&nbsp;Fecha de Ingreso</td>
                    <td><jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />                      
                            <jsp:param name="nameOfTBox1" value="ingreso" />                      
                            <jsp:param name="valueOfTBox1" value="<%=emple.getColValue("ingreso")%>" />                      
                          </jsp:include></td>
                    <td>&nbsp;Fecha Egreso</td>
                    <td><jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />                      
                            <jsp:param name="nameOfTBox1" value="egreso" />                      
                            <jsp:param name="valueOfTBox1" value="<%=emple.getColValue("egreso")%>" />                      
                          </jsp:include></td>
                  </tr>
             </table>
		</td>
	</tr>
    <tr>
    	<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
				  <td width="95%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Otros Datos del Estudiante </td>
				  <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
				</tr>
            </table>
		</td>
    </tr>
	<tr id="panel2">
    	<td>
			<table width="100%" align="center" cellpadding="1" cellspacing="1">
            	<tr class="TextRow01">
                	<td width="18%">&nbsp;Lic. de Conducir</td>
                    <td width="32%"><%=fb.checkbox("conducir","S",(emple.getColValue("conducir") != null && emple.getColValue("conducir").equalsIgnoreCase("S")),false)%> </td>
                    <td width="17%">&nbsp;Tipo Sangre</td>
                    <td><%=fb.select(ConMgr.getConnection()," select distinct tipo_sangre  from tbl_bds_tipo_sangre order by tipo_sangre ","sang",emple.getColValue("sang"))%> <%=fb.select(ConMgr.getConnection()," select distinct rh from tbl_bds_tipo_sangre order by rh","sangre",emple.getColValue("sangre"))%> </td>
                </tr>
                <tr class="TextRow01">
                	<td>&nbsp;Nombre de la Madre</td>
                    <td><%=fb.textBox("madre",emple.getColValue("madre"),false,false,false,35,80)%></td>
                    <td>&nbsp;Nombre de Padre</td>
                    <td><%=fb.textBox("padre",emple.getColValue("padre"),false,false,false,35,80)%></td>
                 </tr>
                <tr class="TextRow01">
                 	<td>&nbsp;Vive Madre?</td>
                    <td><%=fb.checkbox("vivemadre","S",(emple.getColValue("vivemadre") != null && emple.getColValue("vivemadre").equalsIgnoreCase("S")),false)%></td>
                    <td>&nbsp;Vive Padre?</td>
                    <td><%=fb.checkbox("vivepadre","S",(emple.getColValue("vivepadre") != null && emple.getColValue("vivepadre").equalsIgnoreCase("S")),false)%></td>
                 </tr>
                <tr class="TextHeader">
                  	<td colspan="4">&nbsp;Emergencia</td>
				</tr>
                <tr class="TextRow01">
                  	<td>&nbsp;Llamar a</td>
                    <td><%=fb.textBox("llamar",emple.getColValue("llamar"),false,false,false,35,80)%></td>
                    <td>&nbsp;Tel&eacute;fono</td>
                    <td><%=fb.textBox("telefonos",emple.getColValue("telefonos"),false,false,false,35,11)%></td>
                </tr>
                <tr class="TextRow01">
                  	<td>&nbsp;Comentario</td>
                    <td colspan="3"><%=fb.textarea("comentario",emple.getColValue("comentario"),false,false,false,88,3,2000,null,"width='100%'",null)%></td>
                </tr>
             </table>
		</td>
    </tr>
    <tr class="TextRow02">
    	<td align="right"> Opciones de Guardar: 
		<%=fb.radio("saveOption","N")%>Crear Otro 
		<%=fb.radio("saveOption","O")%>Mantener Abierto 
		<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
		<%=fb.submit("save","Guardar",true,false)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
     </tr>
<%=fb.formEnd(true)%>
</table>
<!--</div>
<script type="text/javascript">
<%
//if (mode.equalsIgnoreCase("add"))
//{
%>
initTabs('dhtmlgoodies_tabView1',Array('Empleado'),0,'100%','');
<%
//}
//else
//{
%>
<%
//}
%>
</script>
-->          </td>
        </tr>
       </table>
	</td>
  </tr>
</table>
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET 
else
{ 


Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("fotosimages"),20);

	String saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = (String) ht.get("baction");
	id = (String) ht.get("id");
	mode = (String) ht.get("mode");
	code = (String) ht.get("code");
	prov = (String) ht.get("prov");
	sig  = (String) ht.get("sig"); 
	tom  = (String) ht.get("tom"); 
	asi  = (String) ht.get("asi");
		
	if(tab.equals("0")) //Generales de Estudiante
	{
   	  emple = new CommonDataObject();
	  emple.setTableName("tbl_pla_estudiante");	    
	  emple.addColValue("PRIMER_NOMBRE", (String) ht.get("nombre1")); 
	  emple.addColValue("SEGUNDO_NOMBRE",(String) ht.get("nombre2"));	
	  if((String) ht.get("apellido1")!= null)
	  emple.addColValue("PRIMER_APELLIDO",(String) ht.get("apellido1"));
	  if((String) ht.get("apellido2")!= null)
	  emple.addColValue("SEGUNDO_APELLIDO",(String) ht.get("apellido2"));	  
	  if((String) ht.get("casada")!= null)	  
	  emple.addColValue("NUM_SSOCIAL",(String) ht.get("seguro"));
	  if ((String) ht.get("conducir") == null) emple.addColValue("LICENCIA_CONDUCIR","N"); 
	  else emple.addColValue("LICENCIA_CONDUCIR",(String) ht.get("conducir"));
	  if((String) ht.get("salario")!=null)
	  emple.addColValue("SALARIO_BASE",(String) ht.get("salario"));
	  if((String) ht.get("calle")!=null)
	  emple.addColValue("CALLE_DIR",(String) ht.get("calle"));
	  if((String) ht.get("casa")!=null)
	  emple.addColValue("CASA__DIR",(String) ht.get("casa")); 
	  if((String) ht.get("zona")!= null)  
	  emple.addColValue("ZONA_POSTAL",(String) ht.get("zona"));
	  if((String) ht.get("apartado")!=null)  
      emple.addColValue("APARTADO_POSTAL",(String) ht.get("apartado"));
	  if((String) ht.get("telcasa") != null)
	  emple.addColValue("TELEFONO_CASA",(String) ht.get("telcasa"));
	  if((String) ht.get("telotros")!=null)  
  	  emple.addColValue("TELEFONO_OTRO",(String) ht.get("telotros"));
	  if((String) ht.get("tellugar")!= null)
   	  emple.addColValue("LUGAR_TELEFONO",(String) ht.get("tellugar"));
	  if((String) ht.get("nacionalidadCode")!=null)
	  emple.addColValue("NACIONALIDAD",(String) ht.get("nacionalidadCode"));
	  emple.addColValue("FECHA_NACIMIENTO",(String) ht.get("fecha")); 
	  emple.addColValue("ESTADO_CIVIL",(String) ht.get("civil"));
	  emple.addColValue("SEXO",(String) ht.get("sexo"));
	  if((String) ht.get("madre")!=null)
	  emple.addColValue("NOMBRE_MADRE",(String) ht.get("madre"));
	  if((String) ht.get("padre")!=null)
      emple.addColValue("NOMBRE_PADRE",(String) ht.get("padre"));
      if ((String) ht.get("vivemadre") == null) emple.addColValue("VIVE_MADRE","N"); 
	  else emple.addColValue("VIVE_MADRE",(String) ht.get("vivemadre"));
	  if ((String) ht.get("vivepadre") == null) emple.addColValue("VIVE_PADRE","N"); 
	  else emple.addColValue("VIVE_PADRE",(String) ht.get("vivepadre"));  
	  if((String) ht.get("llamar")!=null)
      emple.addColValue("EMERGENCIA_LLAMAR",(String) ht.get("llamar"));  
	  if((String) ht.get("telefonos")!=null)
	  emple.addColValue("TELEFONO_EMERGENCIA",(String) ht.get("telefonos"));
	  if((String) ht.get("email")!= null)
	  emple.addColValue("EMAIL",(String) ht.get("email"));
	  if((String) ht.get("foto")!=null)
	  emple.addColValue("foto",(String) ht.get("foto"));	  
      emple.addColValue("FECHA_MODIFICACION","sysdate");
  	  emple.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName")); 
	  if((String) ht.get("comentario")!=null)
	  emple.addColValue("COMENTARIO",(String) ht.get("comentario")); 
	  if((String) ht.get("ingreso")!=null)
	  emple.addColValue("FECHA_INGRESO",(String) ht.get("ingreso"));
	  if((String) ht.get("egreso")!=null)	
	  emple.addColValue("FECHA_EGRESO",(String) ht.get("egreso"));  
	  if((String) ht.get("estado")!=null)
	  emple.addColValue("ESTADO",(String) ht.get("estado"));
	  if ((String) ht.get("provinciaC") != null)	
	  emple.addColValue("PROVINCIA_DIR",(String) ht.get("provinciaC"));
	  if ((String) ht.get("paisC") != null)	
	  emple.addColValue("PAIS_DIR",(String) ht.get("paisC")); 
	  if ((String) ht.get("corregimientoC") != null)	
	  emple.addColValue("CORREGIMIENTO_DIR",(String) ht.get("corregimientoC"));  
	  if ((String) ht.get("distritoC") != null)	
	  emple.addColValue("DISTRITO_DIR",(String) ht.get("distritoC"));
	  if ((String) ht.get("comunidadC") != null)	
	  emple.addColValue("COMUNIDAD_DIR",(String) ht.get("comunidadC")); 
	  emple.addColValue("compania",(String) session.getAttribute("_companyId"));
	  emple.addColValue("compania_uniorg",(String) session.getAttribute("_companyId"));
	  emple.addColValue("unidad_organi",(String) session.getAttribute("_companyId"));
	  emple.addColValue("UNIDAD_ORGANI",(String) ht.get("seccion"));
	  if((String) ht.get("sang")!=null)
      emple.addColValue("TIPO_SANGRE",(String) ht.get("sang")); 	
	  if ((String) ht.get("sangre") != null)
	  emple.addColValue("RH",(String) ht.get("sangre")); 	
      if((String) ht.get("cargo")!=null)
	  emple.addColValue("CARGO_JEFE",(String) ht.get("cargo"));
	  emple.addColValue("CENTRO_EDUCATIVO",(String) ht.get("ruta"));
	  emple.addColValue("CARRERA",(String) ht.get("firma"));
	  
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  { 
		emple.addColValue("COMPANIA_UNIORG",(String) session.getAttribute("_companyId"));	
		emple.addColValue("provincia",(String) ht.get("provincia"));
		//emple.addColValue("EST_ID",(String) ht.get("estId"));
		 emple.addColValue("sigla",(String) ht.get("sigla"));
		emple.addColValue("tomo",(String) ht.get("tomo"));	
		emple.addColValue("asiento",(String) ht.get("asiento"));	
		emple.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 	
		emple.addColValue("fecha_creacion","sysdate");	
		emple.setAutoIncCol("EST_ID");  
		
		SQLMgr.insert(emple);
		prov = (String) ht.get("provincia");
		sig  = (String) ht.get("sigla"); 
		tom  = (String) ht.get("tomo"); 
		asi  = (String) ht.get("asiento");
	}
  else
  {
  	emple.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and PROVINCIA="+prov+" and SIGLA='"+sig+"' and TOMO="+tom+" and ASIENTO="+asi);

		SQLMgr.update(emple);
  }
	ConMgr.clearAppCtx(null);
}//End Tab de Generales de Empleado
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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/expediente_estudiante_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/expediente_estudiante_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/expediente_estudiante_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
