<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="PUMgr" scope="page" class="issi.expediente.ProtocoloUniversalMgr" />
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
PUMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
Properties prop = new Properties();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();
boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String estado = request.getParameter("estado");
String key = "";
String descLabel ="PROTOCOLO UNIVERSAL "; 
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String id = request.getParameter("id");
String userName = (String) session.getAttribute("_userName");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "P1";
if (id == null) id = "0";
if (desc == null) desc = "";
if (estado == null) estado = "";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");


if (request.getMethod().equalsIgnoreCase("GET"))
{
al = SQLMgr.getDataPropertiesList("select protocolo from tbl_sal_protocolo_universal where pac_id="+pacId+" and admision="+noAdmision+" order by id desc ");
prop = SQLMgr.getDataProperties("select protocolo from tbl_sal_protocolo_universal where id="+id+" ");
	
	if (prop == null)
	{
	 	prop = new Properties();
		prop.setProperty("fecha",cDateTime.substring(0,10));
		prop.setProperty("hora",cDateTime.substring(11));
		prop.setProperty("fechaPausa",cDateTime.substring(0,10));
		prop.setProperty("horaPausa",cDateTime.substring(11));
        
        prop.setProperty("usuario_creacion", userName);
        prop.setProperty("fecha_creacion", cDateTime);
		
	}
	else modeSec = "edit";
	if(!prop.getProperty("fecha").trim().equals(cDateTime.substring(0,10)))
	{ 
		modeSec = "view";
		viewMode = true;
	}
sql=" select (select join(cursor(select a.descripcion||': '||b.observacion||' ' alergias from tbl_sal_tipo_alergia a, tbl_sal_alergia_paciente b where a.codigo=b.tipo_alergia and b.pac_id="+pacId+" ORDER BY a.DESCRIPCION  ),'; ') alergias from dual ) alergias  from dual";
	cdo1 = SQLMgr.getData(sql);//	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Protocolo Universal - '+document.title;
function doAction(){newHeight();}

function getMedico(fg){var medico='';
if(fg=='MED')medico=eval('document.form0.reg_medico').value;
else if(fg=='ANES')medico=eval('document.form0.reg_anestesiologo').value;
else if(fg=='PED')medico=eval('document.form0.reg_pediatra').value; 
else if(fg=='ASIS')medico=eval('document.form0.asistente_quirurgico').value; 

if(medico!=undefined && medico !=''){
var c=splitCols(getDBData('<%=request.getContextPath()%>','primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada)),a.codigo','tbl_adm_medico a',' nvl(a.reg_medico,a.codigo)=\''+medico+'\'',''));
if(c!=null){
	
	if(fg=='MED'){
	eval('document.form0.nombre_medico').value=c[0];
	eval('document.form0.cod_medico').value=c[1];}
	else if(fg=='ANES'){
	eval('document.form0.nombre_anestesiologo').value=c[0];
	eval('document.form0.anestesiologo').value=c[1];}
	else if(fg=='PED'){
	eval('document.form0.nombre_pediatra').value=c[0];
	eval('document.form0.pediatra').value=c[1];}
	else if(fg=='ASIS'){
	eval('document.form0.nombre_asistente').value=c[0];
	eval('document.form0.asistente').value=c[1];}
 
 }else
 {  
     CBMSG.warning('El Medico no Existe Verifique!');
	 if(fg=='MED'){
	 eval('document.form0.cod_medico').value='';
	 eval('document.form0.reg_medico').value='';
	 eval('document.form0.reg_medico').focus();
	 eval('document.form0.nombre_medico').value ='';}
	 else if(fg=='ANES'){ 
	 eval('document.form0.reg_anestesiologo').value='';
	 eval('document.form0.anestesiologo').value='';
	 eval('document.form0.reg_anestesiologo').focus();
	 eval('document.form0.nombre_anestesiologo').value ='';}
	 else if(fg=='PED'){  
	 eval('document.form0.reg_pediatra').value='';
	 eval('document.form0.pediatra').value='';
	 eval('document.form0.reg_pediatra').focus();
	 eval('document.form0.nombre_pediatra').value ='';} 
	 else if(fg=='ASIS'){
	eval('document.form0.nombre_asistente').value='';
	eval('document.form0.asistente').value='';
	eval('document.form0.asistente_quirurgico').focus();
	eval('document.form0.asistente_quirurgico').value='';}
 } 
}
}

 
function medicoList(fp){abrir_ventana1('../common/search_medico.jsp?fp='+fp);}
function personalList(fg){abrir_ventana1('../common/search_empleado.jsp?fp=pUniversal'+fg);}
function pediatraList(){abrir_ventana1('../common/search_medico.jsp?fp=pUniversalPed');}
function anestList(){abrir_ventana1('../common/search_medico.jsp?fp=pUniversalAnest');}
function showProcList(){abrir_ventana1('../common/sel_procedimiento.jsp?fp=protocolo');}
function chkMedico(){if(document.form0.baction.value=="Guardar"){if((eval('document.form0.cod_medico').value!='' && eval('document.form0.nombre_medico').value=='')||(eval('document.form0.cod_medico').value=='' && eval('document.form0.nombre_medico').value!='')){alert('El Medico no Existe Verifique!');eval('document.form0.cod_medico').value ='';eval('document.form0.nombre_medico').value ='';eval('document.form0.cod_medico').focus();return false;}else return true;}else return true;}
function showDiagnosticoList(){abrir_ventana1('../common/search_diagnostico.jsp?fp=pUniversal');}
function setEvaluacion(code){window.location = '../expediente/exp_protocolo_universal.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&estado=<%=estado%>&desc=<%=desc%>&id='+code;}
function add(){window.location = '../expediente/exp_protocolo_universal.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&estado=<%=estado%>&desc=<%=desc%>&id=0';}
function getPersonal(fg){var personal='';
if(fg=='CIRC')personal=eval('document.form0.circulador').value;
else if(fg=='INT')personal=eval('document.form0.instrumentista').value;
if(personal!=undefined && personal !=''){
var c=splitCols(getDBData('<%=request.getContextPath()%>','primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_casada,null,\'\',\' DE \'||apellido_casada))','vw_pla_empleado a',' emp_id=\''+personal+'\'',''));
if(c!=null){
if(fg=='CIRC'){
eval('document.form0.nombre_circulador').value=c[0]; }
else if(fg=='INT'){
eval('document.form0.nombre_instrumentista').value=c[0]; }
}
}
}


function printExp(option){
   if (typeof option == "undefined"){
       abrir_ventana("../expediente/print_protocolo_universal.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>");
   }else{
      abrir_ventana("../expediente/print_protocolo_universal.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>");
   }
}

</script>
<style type="text/css">
<!--
.style1 {color: #000000}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr class="TextRow01">
					<td>
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
						<tr class="TextRow02">
							<td colspan="5">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
							<td align="right">
							
							<%if(!id.equals("0")){%>
							     <a href="javascript:printExp()" class="Link00">[ <cellbytelabel id="32"><cellbytelabel>Imprimir</cellbytelabel></cellbytelabel> ]</a>
							<%}%>
							<a href="javascript:printExp('ALL')" class="Link00">[ <cellbytelabel id="33"><cellbytelabel>Imprimir Todo</cellbytelabel></cellbytelabel> ]</a>
							
							<%if(!estado.trim().equalsIgnoreCase("F")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaciones</cellbytelabel> ]</a><%}%></td>
						</tr>

						<tr class="TextHeader">
							<td width="5%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
                            <td width="15%"><cellbytelabel id="4">Fecha creaci&oacute;n</cellbytelabel></td>
                            <td width="15%"><cellbytelabel id="4">Por</cellbytelabel></td>
                            <td width="15%"><cellbytelabel id="4">Fecha modif.</cellbytelabel></td>
                            <td width="15%"><cellbytelabel id="4">Por</cellbytelabel></td>
                            <td width="35%">&nbsp;</td>
						</tr>
<%
for (int i=1; i<=al.size(); i++)
{
	Properties prop1 = (Properties) al.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,prop1.getProperty("id"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=prop1.getProperty("id")%>)" style="text-decoration:none; cursor:pointer">
				<td><%=prop1.getProperty("id")%></td>
				<td><%="".equals(prop1.getProperty("fecha_creacion")) ? prop1.getProperty("fecha") : prop1.getProperty("fecha_creacion")%></td>
				<td><%=prop1.getProperty("usuario_creacion")%></td>
				<td><%=prop1.getProperty("fecha_modificacion")%></td>
				<td><%=prop1.getProperty("usuario_modificacion")%></td>
				<td>&nbsp;</td>
				
		</tr>
<%}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>



<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",prop.getProperty("id"))%>
<%=fb.hidden("aplicar11",prop.getProperty("aplicar11"))%>
<%=fb.hidden("fecha_creacion",prop.getProperty("fecha_creacion"))%>
<%=fb.hidden("usuario_creacion",prop.getProperty("usuario_creacion"))%>
<%=fb.hidden("estado", estado)%>
<%=fb.hidden("desc", desc)%>
		<tr class="TextRow02">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="5">LISTADO ESTANDARIZADO DE VERIFICACI&Oacute;N</cellbytelabel></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="6">SECCION I: VERIFICACION DEL PROCEDIMIENTO QUIRURGICO</cellbytelabel></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8"><cellbytelabel id="7">LUGAR DE PROCEDENCIA DEL PACIENTE</cellbytelabel></td>
		</tr>
		
		<tr class="TextRow01">
			<td width="20%" align="right"><cellbytelabel id="8">Admision Adulto</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("admitido","AA",(prop.getProperty("admitido").equalsIgnoreCase("AA")),viewMode,false)%></td>
			<td width="20%" align="right"><cellbytelabel id="9">Sala de Hospital</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("admitido","SH",(prop.getProperty("admitido").equalsIgnoreCase("SH")),viewMode,false)%></td>
			<td width="20%" align="right"><cellbytelabel id="10">Cuarto de Urgencia</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("admitido","CU",(prop.getProperty("admitido").equalsIgnoreCase("CU")),viewMode,false)%></td>
			<td width="20%" align="right"><cellbytelabel id="11">Admision Ambulatoria</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("admitido","AM",(prop.getProperty("admitido").equalsIgnoreCase("AM")),viewMode,false)%></td>
		</tr>
		
		<tr class="TextRow02">
			<td colspan="6">1. <cellbytelabel id="12">¿Se Confirm&oacute; verbalmente el nombre del paciente?</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar1","N",(prop.getProperty("aplicar1").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar1","NA",(prop.getProperty("aplicar1").equalsIgnoreCase("NA")),viewMode,false)%>N/A
											</td>
		</tr>
		
		<tr class="TextRow01">
			<td colspan="6">2. <cellbytelabel id="13">¿Se Confirmó verbalmente la cédula o pasaporte del paciente?</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar2","N",(prop.getProperty("aplicar2").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar2","NA",(prop.getProperty("aplicar2").equalsIgnoreCase("NA")),viewMode,false)%>N/A
			</td>
		</tr>
		
		
		<tr class="TextRow02">
			<td colspan="6">3. <cellbytelabel id="14">¿Paciente tiene colocada su pulsera de identificación?</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar3","N",(prop.getProperty("aplicar3").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar3","NA",(prop.getProperty("aplicar3").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td>
		</tr>
		
		<tr class="TextRow01">
			<td colspan="6">4. <cellbytelabel id="15">¿Pulsera de identificación coincide con datos del paciente?</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar4","N",(prop.getProperty("aplicar4").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar4","NA",(prop.getProperty("aplicar4").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="16">VERIFICACION DE LA DISPONIBILIDAD DE LA DOCUMENTACION REQUERIDA</cellbytelabel></td>
		</tr>
		
		<tr class="TextRow02">
			<td colspan="6">5. <cellbytelabel id="17">La historia clinica</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar5","S",(prop.getProperty("aplicar5").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar5","S",(prop.getProperty("aplicar5").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar5","N",(prop.getProperty("aplicar5").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar5","NA",(prop.getProperty("aplicar5").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow01">
			<td colspan="6">6. <cellbytelabel id="18">La evaluación Pre-anestésica</cellbytelabel></td>
			<td colspan="2">
											<%=fb.radio("aplicar6","S",(prop.getProperty("aplicar6").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar6","N",(prop.getProperty("aplicar6").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar6","NA",(prop.getProperty("aplicar6").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow02">
			<td colspan="6">7. <cellbytelabel id="19">Consentimiento Informado de Sedación y Anestesia,firmado por paciente y médico</cellbytelabel>.</td>
			<td colspan="2"><%//=fb.checkbox("aplicar7","S",(prop.getProperty("aplicar7").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar7","S",(prop.getProperty("aplicar7").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar7","N",(prop.getProperty("aplicar7").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar7","NA",(prop.getProperty("aplicar7").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow01">
			<td colspan="6">8. <cellbytelabel id="20">Consentimiento Informado Quirúrgico, firmado por paciente y médico</cellbytelabel>.</td>
			<td colspan="2"><%//=fb.checkbox("aplicar8","S",(prop.getProperty("aplicar8").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar8","S",(prop.getProperty("aplicar8").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar8","N",(prop.getProperty("aplicar8").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar8","NA",(prop.getProperty("aplicar8").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow01">
			<td colspan="6">9. <cellbytelabel id="21">Autorizaciones de las compañías de seguro</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar9","S",(prop.getProperty("aplicar9").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar9","S",(prop.getProperty("aplicar9").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar9","N",(prop.getProperty("aplicar9").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar9","NA",(prop.getProperty("aplicar9").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow02">
			<td colspan="6">10. <cellbytelabel id="22">Exámenes de laboratorio del paciente correcto</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar10","S",(prop.getProperty("aplicar10").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar10","S",(prop.getProperty("aplicar10").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar10","N",(prop.getProperty("aplicar10").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar10","NA",(prop.getProperty("aplicar10").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow01">
			<td colspan="6">11. <cellbytelabel id="23">Exámenes de Imagenes del paciente correcto</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar11","S",(prop.getProperty("aplicar11").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right" colspan="2"><span class="style1"><cellbytelabel id="24">MRI</cellbytelabel></span>&nbsp;
			  <%//=fb.checkbox("aplicar12","S",(prop.getProperty("aplicar12").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar12","S",(prop.getProperty("aplicar12").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar12","N",(prop.getProperty("aplicar12").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
			<%=fb.radio("aplicar12","NA",(prop.getProperty("aplicar12").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
			<td align="right" colspan="2"><span class="style1"><cellbytelabel id="25">R-X</cellbytelabel></span> &nbsp;
			  <%//=fb.checkbox("aplicar13","S",(prop.getProperty("aplicar13").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar13","S",(prop.getProperty("aplicar13").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar13","N",(prop.getProperty("aplicar13").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
			<%=fb.radio("aplicar13","NA",(prop.getProperty("aplicar13").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
			<td align="right" colspan="2"><span class="style1"><cellbytelabel id="28">USG</cellbytelabel></span> &nbsp;
			  <%//=fb.checkbox("aplicar14","S",(prop.getProperty("aplicar14").equalsIgnoreCase("S")),viewMode,null,null,"")%>
														<%=fb.radio("aplicar14","S",(prop.getProperty("aplicar14").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar14","N",(prop.getProperty("aplicar14").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
			<%=fb.radio("aplicar14","NA",(prop.getProperty("aplicar14").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
			<td align="right" colspan="2"><span class="style1"><cellbytelabel id="29">CAT</cellbytelabel></span> &nbsp;
			  <%//=fb.checkbox("aplicar15","S",(prop.getProperty("aplicar15").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar15","S",(prop.getProperty("aplicar15").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar15","N",(prop.getProperty("aplicar15").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
			<%=fb.radio("aplicar15","NA",(prop.getProperty("aplicar15").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow01">
			<td colspan="6">12. <cellbytelabel id="30">Cruce de Sangre</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar16","S",(prop.getProperty("aplicar16").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar16","S",(prop.getProperty("aplicar16").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar16","N",(prop.getProperty("aplicar16").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar16","NA",(prop.getProperty("aplicar16").equalsIgnoreCase("NA")),viewMode,false)%>N/A 

			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="6">13. <cellbytelabel id="31">Cualquier tipo de producto sanguíneo</cellbytelabel> </td>
			<td colspan="2"><%//=fb.checkbox("aplicar17","S",(prop.getProperty("aplicar17").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar17","S",(prop.getProperty("aplicar17").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar17","N",(prop.getProperty("aplicar17").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar17","NA",(prop.getProperty("aplicar17").equalsIgnoreCase("NA")),viewMode,false)%>N/A 
</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="6">14. <cellbytelabel id="32">Implantes</cellbytelabel></td>
			<td colspan="2"><%//=fb.checkbox("aplicar18","S",(prop.getProperty("aplicar18").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar18","S",(prop.getProperty("aplicar18").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar18","N",(prop.getProperty("aplicar18").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar18","NA",(prop.getProperty("aplicar18").equalsIgnoreCase("NA")),viewMode,false)%>N/A 

			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="6">15. <cellbytelabel id="33">Dispositivos o equipo especial</cellbytelabel> </td>
			<td colspan="2"><%//=fb.checkbox("aplicar19","S",(prop.getProperty("aplicar19").equalsIgnoreCase("S")),viewMode,null,null,"")%>
											<%=fb.radio("aplicar19","S",(prop.getProperty("aplicar19").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel id="26">SI</cellbytelabel>
											<%=fb.radio("aplicar19","N",(prop.getProperty("aplicar19").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel id="27">NO</cellbytelabel>
											<%=fb.radio("aplicar19","NA",(prop.getProperty("aplicar19").equalsIgnoreCase("NA")),viewMode,false)%>N/A</td> 
		</tr>
		<tr class="TextRow01">
			<td>16. <cellbytelabel id="34">Medicamentos Suministrados</cellbytelabel></td>
			<td colspan="7"><%=fb.textarea("medicamentos",prop.getProperty("medicamentos"),false,false ,viewMode,60,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="35">SECCION II: MARCADO DEL SITIO DE LA INTERVENCI&Oacute;N</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td>17. <cellbytelabel id="36">Diagnostico</cellbytelabel></td>
			<td colspan="7">	
					<%=fb.textBox("codDiag",prop.getProperty("codDiag"),false,false,true,10,null,null,"")%>
					<%=fb.textBox("descDiag",prop.getProperty("descDiag"),false,viewMode,true,60)%>
					<%=fb.button("diagnostico","...",true,(viewMode),null,null,"onClick=\"javascript:showDiagnosticoList()\"","seleccionar Diagnostico")%></td>
		</tr>
		<tr class="TextRow02">
			<td>18. <cellbytelabel id="37">&Aacute;rea de la Cirug&iacute;a</cellbytelabel></td>
			<td colspan="7"><%=fb.textBox("areaCirugia",prop.getProperty("areaCirugia"),false,viewMode,false,60,null,null,"")%></td>
		</tr>
		
		<tr class="TextRow01">
			<td><cellbytelabel id="38">Fecha de Marcaci&oacute;n</cellbytelabel></td>
			<td colspan="3">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td><cellbytelabel id="39">Hora de Marcaci&oacute;n</cellbytelabel></td>
			<td colspan="3">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="40">SECCION III: EJECUCI&Oacute;N DE LA PAUSA QUIR&Uacute;RGICA</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="41">Alergias</cellbytelabel></td>
			<td colspan="7"><%=fb.textarea("alergias",(modeSec.trim().equals("add"))?cdo1.getColValue("alergias"):prop.getProperty("alergias"),false,false ,viewMode,60,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2"><cellbytelabel id="42">Procedimiento Quir&uacute;rgico Planificado</cellbytelabel></td>
			<td colspan="6">
					<%=fb.textBox("codProc",prop.getProperty("codProc"),false,false,true,10,null,null,"")%>
					<%=fb.textBox("descProc",prop.getProperty("descProc"),false,viewMode,true,60)%>
					<%=fb.button("procedimiento","...",true,(viewMode),null,null,"onClick=\"javascript:showProcList()\"","seleccionar Procedimiento")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="43">Sitio del Procedimiento Quir&uacute;rgico</cellbytelabel></td>
			<td colspan="7"><%=fb.textBox("sitioProc",prop.getProperty("sitioProc"),false,viewMode,false,60,null,null,"")%></td>
		</tr>
		<!---<tr class="TextRow02">
			<td rowspan="2">Posicion Del paciente</td>
			<td align="center"><%=fb.radio("posicion","SU",(prop.getProperty("posicion").equalsIgnoreCase("SU")),viewMode,false)%></td>
			<td>Supino</td>
			<td align="center"><%=fb.radio("posicion","LI",(prop.getProperty("posicion").equalsIgnoreCase("LI")),viewMode,false)%></td>
			<td>Litotom&iacute;a</td>
			<td align="center"><%=fb.radio("posicion","LD",(prop.getProperty("posicion").equalsIgnoreCase("LD")),viewMode,false)%></td>
			<td>Lat-Der</td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td align="center"><%=fb.radio("posicion","PR",(prop.getProperty("posicion").equalsIgnoreCase("PR")),viewMode,false)%></td>
			<td>Prono</td>
			<td align="center"><%=fb.radio("posicion","SE",(prop.getProperty("posicion").equalsIgnoreCase("SE")),viewMode,false)%></td>
			<td>Sentado</td>
			<td align="center"><%=fb.radio("posicion","LI",(prop.getProperty("posicion").equalsIgnoreCase("LI")),viewMode,false)%></td>
			<td>Lat-Izq</td>
			<td>&nbsp;</td>
		</tr>---->
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="44">M&eacute;dico Responsable</cellbytelabel></td>
			<td colspan="6">
					<%=fb.hidden("cod_medico",prop.getProperty("cod_medico"))%>
					<%=fb.textBox("reg_medico",prop.getProperty("reg_medico"),false,false,false,10,null,null,"onChange=\"javascript:getMedico('MED')\"")%>	
					<%=fb.textBox("nombre_medico",prop.getProperty("nombre_medico"),false,viewMode,true,60)%>
					<%=fb.button("medic","...",true,(viewMode),null,null,"onClick=\"javascript:medicoList('pUniversal')\"","seleccionar Medico")%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="45">Anestesi&oacute;logo</cellbytelabel></td>
			<td colspan="6">
					<%=fb.hidden("anestesiologo",prop.getProperty("anestesiologo"))%>
					<%=fb.textBox("reg_anestesiologo",prop.getProperty("reg_anestesiologo"),false,false,false,10,null,null,"onChange=\"javascript:getMedico('ANES')\"")%>
					<%=fb.textBox("nombre_anestesiologo",prop.getProperty("nombre_anestesiologo"),false,viewMode,true,60)%>
					<%=fb.button("anest","...",true,(viewMode),null,null,"onClick=\"javascript:anestList()\"","seleccionar Anestesi&oacute;logo")%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="46">Pediatra</cellbytelabel></td>
			<td colspan="6">
					<%=fb.hidden("pediatra",prop.getProperty("pediatra"))%>
					<%=fb.textBox("reg_pediatra",prop.getProperty("reg_pediatra"),false,false,false,10,null,null,"onChange=\"javascript:getMedico('PED')\"")%>
					<%=fb.textBox("nombre_pediatra",prop.getProperty("nombre_pediatra"),false,viewMode,true,60)%>
					<%=fb.button("pediat","...",true,(viewMode),null,null,"onClick=\"javascript:pediatraList()\"","seleccionar Pediatra")%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="47">Instrumentista</cellbytelabel></td>
			<td colspan="6"> 
					<%=fb.textBox("instrumentista",prop.getProperty("instrumentista"),false,false,false,10,null,null,"onChange=\"javascript:getPersonal('INT')\"")%>
					<%=fb.textBox("nombre_instrumentista",prop.getProperty("nombre_instrumentista"),false,viewMode,false,60)%>
					<%=fb.button("intru","...",true,(viewMode),null,null,"onClick=\"javascript:personalList('INT')\"","seleccionar Instrumentista")%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="47">Circuldor</cellbytelabel></td>
			<td colspan="6">
					<%=fb.textBox("circulador",prop.getProperty("circulador"),false,false,false,10,null,null,"onChange=\"javascript:getPersonal('CIRC')\"")%>
					<%=fb.textBox("nombre_circulador",prop.getProperty("nombre_circulador"),false,viewMode,false,60)%>
					<%=fb.button("circ","...",true,(viewMode),null,null,"onClick=\"javascript:personalList('CIRC')\"","seleccionar Circulador")%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="47">Asistente Quirúrgico</cellbytelabel></td>
			<td colspan="6">
					<%=fb.hidden("asistente",prop.getProperty("asistente"))%>
					<%=fb.textBox("asistente_quirurgico",prop.getProperty("asistente_quirurgico"),false,false,false,10,null,null,"onChange=\"javascript:getMedico('ASIS')\"")%>
					<%=fb.textBox("nombre_asistente",prop.getProperty("nombre_asistente"),false,viewMode,false,60)%>
					<%=fb.button("asist","...",true,(viewMode),null,null,"onClick=\"javascript:medicoList('pUniversalASIS')\"","seleccionar Asistente")%> 
					</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="47">Personal Adicional</cellbytelabel></td>
			<td colspan="6"><%=fb.textarea("p_adicional",prop.getProperty("p_adicional"),false,false,viewMode,60,2,2000,null,"",null)%></td>
		</tr>
		
		<tr class="TextRow01">
			<td colspan="6">¿ <cellbytelabel id="48">Ha Sido ejecutada la re-evaluación inmediata antes de la inducción anestésica</cellbytelabel>?</td>
			<td colspan="2"><%=fb.checkbox("aplicar20","S",(prop.getProperty("aplicar20").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="49">Fecha de Ejecuci&oacute;n</cellbytelabel></td>
			<td colspan="3">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fechaPausa" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fechaPausa")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td><cellbytelabel id="50">Hora de Ejecuci&oacute;n</cellbytelabel></td>
			<td colspan="3">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="horaPausa" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("horaPausa")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
		</tr>

	
<%
//fb.appendJsValidation("\n\tif (!chkMedico()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td colspan="9" align="right">
				<cellbytelabel id="50">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="51">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="52">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
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
	prop = new Properties();

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("admitido",request.getParameter("admitido"));
	prop.setProperty("id",request.getParameter("id"));
	for(int i=1;i<=20;i++)
	{
		prop.setProperty("aplicar"+i,request.getParameter("aplicar"+i));
	}
	prop.setProperty("medicamentos",request.getParameter("medicamentos"));
	
	
		
	prop.setProperty("codDiag",request.getParameter("codDiag"));
	prop.setProperty("descDiag",request.getParameter("descDiag"));
	prop.setProperty("areaCirugia",request.getParameter("areaCirugia"));

	prop.setProperty("instrumentista",request.getParameter("instrumentista"));
	prop.setProperty("nombre_instrumentista",request.getParameter("nombre_instrumentista"));
	 
	prop.setProperty("circulador",request.getParameter("circulador"));
	prop.setProperty("nombre_circulador",request.getParameter("nombre_circulador"));	  
					
	prop.setProperty("codProc",request.getParameter("codProc"));
	prop.setProperty("descProc",request.getParameter("descProc"));
	
	prop.setProperty("sitioProc",request.getParameter("sitioProc"));
	prop.setProperty("cod_medico",request.getParameter("cod_medico"));
	prop.setProperty("reg_medico",request.getParameter("reg_medico"));	
	prop.setProperty("nombre_medico",request.getParameter("nombre_medico"));
	prop.setProperty("anestesiologo",request.getParameter("anestesiologo"));
	prop.setProperty("reg_anestesiologo",request.getParameter("reg_anestesiologo"));
	prop.setProperty("nombre_anestesiologo",request.getParameter("nombre_anestesiologo"));
	
	prop.setProperty("pediatra",request.getParameter("pediatra"));
	prop.setProperty("reg_pediatra",request.getParameter("reg_pediatra"));
	prop.setProperty("nombre_pediatra",request.getParameter("nombre_pediatra"));
	prop.setProperty("fechaPausa",request.getParameter("fechaPausa"));
	prop.setProperty("horaPausa",request.getParameter("horaPausa"));
    
    prop.setProperty("usuario_creacion", request.getParameter("usuario_creacion"));
    prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion"));
    prop.setProperty("usuario_modificacion", userName);
    prop.setProperty("fecha_modificacion", cDateTime);

    prop.setProperty("fecha",request.getParameter("fecha"));
    prop.setProperty("hora",request.getParameter("hora"));
	
	prop.setProperty("asistente",request.getParameter("asistente"));
	prop.setProperty("asistente_quirurgico",request.getParameter("asistente_quirurgico"));
	prop.setProperty("nombre_asistente",request.getParameter("nombre_asistente"));
	prop.setProperty("p_adicional",request.getParameter("p_adicional"));

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) {
            PUMgr.add(prop);
            id = PUMgr.getPkColValue("id");
		}
		else {
            PUMgr.update(prop);
        }
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (PUMgr.getErrCode().equals("1"))
{
%>
	alert('<%=PUMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(PUMgr.getErrException());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&estado=<%=estado%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>