<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="NIEMgr" scope="page" class="issi.expediente.NotaIngresoEnfermeriaMgr"/>
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
NIEMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
Properties prop = new Properties();
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
String key = "";
String descLabel ="NOTAS DE INGRESO DE ENFERMERIA";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NIPA";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if(fg.trim().equals("NIPA")) descLabel += " - PARTOS";
if(fg.trim().equals("NIPE")) descLabel += " - PEDIATRIA";
if(fg.trim().equals("NINO")) descLabel += " - NEONATOLOGIA"; //echo
if(fg.trim().equals("NIEN")) descLabel += " - SALAS";


if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	cdo = SQLMgr.getData("select a.medico, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre, (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = a.pac_id and admision = a.secuencia and tipo = 'I' and orden_diag = 1) as diagnostico, (select (select coalesce(observacion,nombre) from tbl_cds_diagnostico where codigo = z.diagnostico) from tbl_adm_diagnostico_x_admision z where z.pac_id = a.pac_id and z.admision = a.secuencia and z.tipo = 'I' and z.orden_diag = 1) as descripcion from tbl_adm_admision a where pac_id = "+pacId+" and secuencia = "+noAdmision);
	if (cdo == null) cdo = new CommonDataObject();

	prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_ingreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");
	if (prop == null)
	{
		prop = new Properties();
		prop.setProperty("fecha",cDateTime.substring(0,10));
		prop.setProperty("hora",cDateTime.substring(11));
		if (cdo.getColValue("medico") != null) prop.setProperty("cod_medico",cdo.getColValue("medico"));
		if (cdo.getColValue("nombre") != null) prop.setProperty("nombre_medico",cdo.getColValue("nombre"));
		if (cdo.getColValue("diagnostico") != null) prop.setProperty("codDiag",cdo.getColValue("diagnostico"));
		if (cdo.getColValue("descripcion") != null) prop.setProperty("descDiag",cdo.getColValue("descripcion"));
	}
	else
	{
		if (!viewMode)modeSec = "edit";
	}
	if(!prop.getProperty("fecha").trim().equals(cDateTime.substring(0,10)))
	{
		if (!fg.trim().equals("NIPA") && !fg.trim().equals("NINO"))
		{   modeSec = "view";
			viewMode = true;
		}
		else{if(!viewMode)modeSec = "edit";}
	}
	
	ArrayList propAl = new ArrayList();
	if (fg.trim().equals("NINO") && Integer.parseInt(noAdmision) > 1 ){
	  propAl = SQLMgr.getDataPropertiesList("select nota from tbl_sal_nota_ingreso_enf where pac_id="+pacId+" and admision < "+noAdmision+" and tipo_nota = 'NINO'");
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
<%if(fg.trim().equals("NIEN")){%>
document.title = 'Notas de Ingresos Enfermeria - '+document.title;
<%}%>
function doAction(){newHeight();}
function getMedico(){var medico=eval('document.form0.cod_medico').value;var especMed = '';var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','b.especialidad,primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico a,tbl_adm_medico_especialidad b','a.codigo = b.medico(+) and b.secuencia(+) = 1 and  a.codigo=\''+medico+'\'','');if(medDesc!=''){var index = medDesc.indexOf('|');if(index > 0)especMed = medDesc.substring(0,index);eval('document.form0.nombre_medico').value=medDesc.substring(index+1);}else{alert('El Medico no Existe Verifique!');eval('document.form0.cod_medico').value='';eval('document.form0.cod_medico').focus();eval('document.form0.nombre_medico').value ='';}}}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=notas_enf');}
function showDiagnosticoList(){abrir_ventana1('../common/search_diagnostico.jsp?fp=notas_enf');}
function setCheck(j,k,obj){if(obj.checked){for (i=1; i<j; i++){eval('document.form0.desarrollo'+i).checked=false;eval('document.form0.desarrollo'+i).disabled = true;}for (l=k+1; l<35; l++){eval('document.form0.desarrollo'+l).checked=false;eval('document.form0.desarrollo'+l).disabled = true;}}else{for (s=1; s<=35; s++){eval('document.form0.desarrollo'+s).disabled = false;}}}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_70.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>");}
function ctrlEdema(p){if ( p == 'N' ){for ( i = 0; i<3; i++){document.forms.form0.edema2[i].disabled = true;document.forms.form0.edema2[i].checked = false;}}else{for ( i = 0; i<3; i++){document.forms.form0.edema2[i].disabled = false;}}}

$(function(){
  $(".history").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#historyCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}

  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">

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
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td colspan="9" align="right">&nbsp;<a href="javascript:printExp();" class="Link00">[Imprimir]</a></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="9">INGRESO</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Fecha&nbsp;</td>
			<td colspan="3">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>"/>
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td align="right">Hora</td>
			<td colspan="4">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora"/>
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>"/>
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
		</tr>

		<%if(!fg.trim().equals("NINO")){%>
		<tr class="TextRow01">
			<td width="20%" align="right">Admitido por:</td>
			<td width="15%" align="right">Admisi&oacute;n</td>
			<td width="5%"  align="center"><%=fb.radio("admitido","A",(prop.getProperty("admitido").equalsIgnoreCase("A")),viewMode,false)%></td>
			<td width="15%" align="right">Urgencia</td>
			<td width="5%"  align="center"><%=fb.radio("admitido","U",(prop.getProperty("admitido").equalsIgnoreCase("U")),viewMode,false)%></td>
			<td width="15%" align="right">SOP</td>
			<td width="5%"  align="center"><%=fb.radio("admitido","S",(prop.getProperty("admitido").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td width="15%" align="right">Otro</td>
			<td width="5%"  align="center"><%=fb.radio("admitido","O",(prop.getProperty("admitido").equalsIgnoreCase("O")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Llega en:</td>
			<td align="right">Camilla</td>
			<td align="center"><%=fb.radio("llegada","C",(prop.getProperty("llegada").equalsIgnoreCase("C")),viewMode,false)%></td>
			<td align="right">Caminando</td>
			<td align="center"><%=fb.radio("llegada","CA",(prop.getProperty("llegada").equalsIgnoreCase("CA")),viewMode,false)%></td>
			<td align="right">Silla Ruedas</td>
			<td align="center"><%=fb.radio("llegada","S",(prop.getProperty("llegada").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right">En Brazos</td>
			<td align="center"><%=fb.radio("llegada","EB",(prop.getProperty("llegada").equalsIgnoreCase("EB")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Acompa&ntilde;ado por:</td>
			<td align="right">Familiar</td>
			<td align="center"><%=fb.radio("acompaniante","F",(prop.getProperty("acompaniante").equalsIgnoreCase("F")),viewMode,false)%></td>
			<td align="right">Camillero</td>
			<td align="center"><%=fb.radio("acompaniante","C",(prop.getProperty("acompaniante").equalsIgnoreCase("C")),viewMode,false)%></td>
			<td align="right">Personal Enf.</td>
			<td align="center"><%=fb.radio("acompaniante","E",(prop.getProperty("acompaniante").equalsIgnoreCase("E")),viewMode,false)%></td>
			<td align="right">M&eacute;dico</td>
			<td align="center"><%=fb.radio("acompaniante","M",(prop.getProperty("acompaniante").equalsIgnoreCase("M")),viewMode,false)%></td>
		</tr>

		<tr class="TextRow01">
			<td align="right">&nbsp;</td>
			<td align="right">S&oacute;lo</td>
			<td align="center"><%=fb.radio("acompaniante","S",(prop.getProperty("acompaniante").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right" colspan="6">&nbsp;</td>
		</tr>

		<tr class="TextRow01">
			<td align="right">Religi&oacute;n</td>
			<td align="right">Cat&oacute;lica</td>
			<td align="center"><%=fb.radio("religion","CA",(prop.getProperty("religion").equalsIgnoreCase("CA")),viewMode,false)%></td>
			<td align="right">Evang&eacute;lica</td>
			<td align="center"><%=fb.radio("religion","EV",(prop.getProperty("religion").equalsIgnoreCase("EV")),viewMode,false)%></td>
			<td align="right">Cristiana</td>
			<td align="center"><%=fb.radio("religion","CR",(prop.getProperty("religion").equalsIgnoreCase("CR")),viewMode,false)%></td>
			<td align="right">Otras</td>
			<td align="center"><%=fb.radio("religion","OT",(prop.getProperty("religion").equalsIgnoreCase("OT")),viewMode,false)%></td>
		</tr>
		<%}%>
		<%if(fg.trim().equals("NINO")){%>

		<tr class="TextRow01">
			<td width="20%" align="right">Diagn&oacute;stico:</td>
			<td width="15%" align="right">RNT-AEG</td>
			<td width="5%"  align="center"><%=fb.radio("diagnostico","RNT_AEG",(prop.getProperty("diagnostico").equalsIgnoreCase("RNT_AEG")),viewMode,false)%></td>
			<td width="15%" align="right">RNT-PEG</td>
			<td width="5%"  align="center"><%=fb.radio("diagnostico","RNT_PEG",(prop.getProperty("diagnostico").equalsIgnoreCase("RNT_PEG")),viewMode,false)%></td>
			<td width="15%" align="right">RNT-GEG</td>
			<td width="5%"  align="center"><%=fb.radio("diagnostico","RNT_GEG",(prop.getProperty("diagnostico").equalsIgnoreCase("RNT_GEG")),viewMode,false)%></td>
			<td width="5%" align="left">RNprT-AEG</td>
			<td width="15%"  align="left"><%=fb.radio("diagnostico","RNprT_AEG",(prop.getProperty("diagnostico").equalsIgnoreCase("RNprT_AEG")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td>&nbsp;</td>
			<td align="right">OTROS</td>
			<td align="center"><%=fb.radio("diagnostico","OT",(prop.getProperty("diagnostico").equalsIgnoreCase("OT")),viewMode,false)%></td>
			<td align="right" colspan="6">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Llega en:</td>
			<td align="right">Incubadora</td>
			<td align="center"><%=fb.radio("llegada","IN",(prop.getProperty("llegada").equalsIgnoreCase("IN")),viewMode,false)%></td>
			<td align="right">Otro</td>
			<td align="center"><%=fb.radio("llegada","OT",(prop.getProperty("llegada").equalsIgnoreCase("OT")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Acompa&ntilde;ado por:</td>
			<td align="right">Enf. Obste.</td>
			<td align="center"><%=fb.radio("acompaniante","EO",(prop.getProperty("acompaniante").equalsIgnoreCase("EO")),viewMode,false)%></td>
			<td align="right">Pediatra</td>
			<td align="center"><%=fb.radio("acompaniante","PE",(prop.getProperty("acompaniante").equalsIgnoreCase("PE")),viewMode,false)%></td>
			<td align="right" colspan="4">&nbsp;</td>
		</tr>
		<%}%>
		<tr class="TextRow01">
			<td align="right">Signos Vitales:</td>
			<td align="right">Presi&oacute;n Arterial:</td>
			<td align="center"><%=fb.textBox("presion",prop.getProperty("presion"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right">Pulso:</td>
			<td align="center"><%=fb.textBox("pulso",prop.getProperty("pulso"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right">Respiraci&oacute;n:</td>
			<td align="center"><%=fb.textBox("respiracion",prop.getProperty("respiracion"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="left">Temperatura:</td>
			<td align="left"><%=fb.textBox("temperatura",prop.getProperty("temperatura"),false,false,viewMode,6,"Text10",null,null)%></td>
		</tr>
		
		<% if (fg.equals("NINO")){
			 String peso = "";
		     Properties p = new Properties();
		     for (int o=0; o<propAl.size(); o++){
			  p = (Properties)propAl.get(o);
			  if (p.getProperty("peso").trim() != null && !p.getProperty("peso").trim().equals("")) peso = p.getProperty("peso") +((o+1)==propAl.size()?"":" <> ");       
		     }
		%>
			<%=fb.hidden("historyCont0","<label class='historyCont' style='font-size:11px'>"+peso+"</label>")%>		
		<%}%>
		
		
		<%//if(fg.trim().equals("NIE")){%>
		<tr class="TextRow01">
			<td align="right">&nbsp;</td>
			<td align="right"><span class="history" title="" data-i="0"><span class="Link00 pointer">Peso</span></span></td>
			<td align="center"><%=fb.textBox("peso",prop.getProperty("peso"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right">Talla </td>
			<td align="center"><%=fb.textBox("talla",prop.getProperty("talla"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right">Dolor:&nbsp;&nbsp;&nbsp;S&iacute;</td>
			<td align="center"><%=fb.radio("dolor","S",(prop.getProperty("dolor").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="center">No</td>
			<td align="left"><%=fb.radio("dolor","N",(prop.getProperty("dolor").equalsIgnoreCase("N")),viewMode,false)%></td>

		</tr>
		<%//}%>
		<%if(!fg.trim().equals("NINO")){%>
		<tr class="TextRow01">
			<td align="right">M&eacute;dico:</td>
			<td colspan="8">
					<%=fb.textBox("cod_medico",prop.getProperty("cod_medico"),false,false,true,10,null,null,"onChange=\"javascript:getMedico()\"")%>
					<%=fb.textBox("nombre_medico",prop.getProperty("nombre_medico"),false,viewMode,true,60)%>
					<%=fb.button("medico","...",true,(viewMode),null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
		</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Diagn&oacute;stico:</td>
			<td colspan="8">
					<%=fb.textBox("codDiag",prop.getProperty("codDiag"),false,false,true,10,null,null,"")%>
					<%=fb.textBox("descDiag",prop.getProperty("descDiag"),false,viewMode,true,60)%>
					<%=fb.button("diagnostico","...",true,(viewMode),null,null,"onClick=\"javascript:showDiagnosticoList()\"","seleccionar Diagnostico")%>
		</td>
		<tr class="TextRow01">
			<td align="right">Observaci&oacute;n <br>( DX de Enfermer&iacute;a)</td>
			<td colspan="8"><%=fb.textarea("obserEnf",prop.getProperty("obserEnf"),false,false ,viewMode,60,2,2000,null,"",null)%></td>
		</tr>
		</tr>
		<%}if(fg.trim().equals("NIEN")){%>
		<tr class="TextHeader">
			<td colspan="9" align="left">EVALUACION: CONDICION ESPECIAL </td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Pr&oacute;tesis Dental</td>
			<td><%=fb.checkbox("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Pr&oacute;tesis Corporal</td>
			<td><%=fb.checkbox("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Invidente</td>
			<td><%=fb.checkbox("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Hipoacusia</td>
			<td><%=fb.checkbox("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Mudo</td>
			<td><%=fb.checkbox("aplicar5","S",(prop.getProperty("aplicar5").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Muleta</td>
			<td><%=fb.checkbox("aplicar6","S",(prop.getProperty("aplicar6").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Bast&oacute;n</td>
			<td><%=fb.checkbox("aplicar7","S",(prop.getProperty("aplicar7").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
		<td align="left">Valores Personales</td>
			<td><%=fb.checkbox("aplicar8","S",(prop.getProperty("aplicar8").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left" colspan="7"><%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>

<%}%>
<%if(fg.trim().equals("NIPA")){//Notas de Ingresos Partos%>
		<tr class="TextHeader">
			<td colspan="9" align="left">HISTORIA OBSTETRICA</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Gesta:</td>
			<td><%=fb.textBox("gesta",prop.getProperty("gesta"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right" colspan="2">Para:</td>
			<td colspan="5"><%=fb.textBox("para",prop.getProperty("para"),false,false,viewMode,6,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Aborto:</td>
			<td><%=fb.textBox("aborto",prop.getProperty("aborto"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right" colspan="2">Cesárea:</td>
			<td colspan="5"><%=fb.textBox("cesarea",prop.getProperty("cesarea"),false,false,viewMode,6,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">F.U.M:</td>
			<td><%=fb.textBox("fum",prop.getProperty("fum"),false,false,viewMode,10,"Text10",null,null)%></td>
			<td align="right" colspan="2">F.P.P:</td>
			<td colspan="5"><%=fb.textBox("fpp",prop.getProperty("fpp"),false,false,viewMode,10,"Text10",null,null)%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="9" align="left">MANIOBRA DE LEOPOLD</td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="3">Presentación:</td>
			<td align="right">Cef&aacute;lico:</td>
			<td align="center"><%=fb.radio("presentacion","CE",(prop.getProperty("presentacion").equalsIgnoreCase("CE")),viewMode,false)%></td>
			<td align="right" rowspan="2">Situación:</td>
			<td align="right">Longitudinal</td>
			<td align="center"><%=fb.radio("situacion","LO",(prop.getProperty("situacion").equalsIgnoreCase("LO")),viewMode,false)%></td>
			<td rowspan="2" align="right">Dorso</td>
			<td align="right">Derecho</td>
			<td align="center"><%=fb.radio("dorso","DE",(prop.getProperty("dorso").equalsIgnoreCase("DE")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Sacro:</td>
			<td align="center"><%=fb.radio("presentacion","SA",(prop.getProperty("presentacion").equalsIgnoreCase("SA")),viewMode,false)%></td>
			<td align="right">Transverso</td>
			<td align="center"><%=fb.radio("situacion","TR",(prop.getProperty("situacion").equalsIgnoreCase("TR")),viewMode,false)%></td>
			<td align="right">Izquierdo</td>
			<td align="center"><%=fb.radio("dorso","IZ",(prop.getProperty("dorso").equalsIgnoreCase("IZ")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Pod&aacute;lico:</td>
			<td align="center"><%=fb.radio("presentacion","PO",(prop.getProperty("presentacion").equalsIgnoreCase("PO")),viewMode,false)%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Actividad Uterina:</td>
			<td align="right">Regular:</td>
			<td align="center"><%=fb.radio("actividad","RE",(prop.getProperty("actividad").equalsIgnoreCase("RE")),viewMode,false)%></td>
			<td align="right">Irregular:</td>
			<td align="center"><%=fb.radio("actividad","IR",(prop.getProperty("actividad").equalsIgnoreCase("IR")),viewMode,false)%></td>
			<td align="right" colspan="2">Cant-Frec-Durac</td>
			<td align="center"><%=fb.textBox("can_dura",(prop.getProperty("can_dura")!=null?prop.getProperty("can_dura"):""),false,false,viewMode,6,"Text10",null,null)%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Membranas:</td>
			<td align="right">&Iacute;ntegras:</td>
			<td align="center"><%=fb.radio("membranas","I",(prop.getProperty("membranas").equalsIgnoreCase("I")),viewMode,false)%></td>
			<td align="right">Rotas:</td>
			<td align="center"><%=fb.radio("membranas","R",(prop.getProperty("membranas").equalsIgnoreCase("R")),viewMode,false)%></td>
			<td align="right" colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="2">L&iacute;quido Amni&oacute;tico:</td>
			<td align="right" rowspan="2">Claro:</td>
			<td align="center" rowspan="2"><%=fb.radio("liquido","CL",(prop.getProperty("liquido").equalsIgnoreCase("CL")),viewMode,false)%></td>
			<td align="right" rowspan="2">Meconial:</td>
			<td align="right">Fluido:</td>
			<td align="center"><%=fb.radio("liquido","FL",(prop.getProperty("liquido").equalsIgnoreCase("FL")),viewMode,false)%></td>
			<td align="right">Sanguinolento</td>
			<td align="center"><%=fb.radio("liquido","SA",(prop.getProperty("liquido").equalsIgnoreCase("SA")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Espeso:</td>
			<td align="center"><%=fb.radio("liquido","ES",(prop.getProperty("liquido").equalsIgnoreCase("ES")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">F.C.F:</td>
			<td colspan="8"><%=fb.textBox("fcf",prop.getProperty("fcf"),false,false,viewMode,20,"Text10",null,null)%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="9" align="left">TACTO VAGINAL</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="3">Dilataci&oacute;n(cms)</td>
			<td colspan="3">Altura(Plano)</td>
			<td colspan="3">Presentaci&oacute;n</td>
		</tr>
<%
for (int i=1; i<=4; i++)
{
%>
		<tr class="TextRow01" align="center">
			<td colspan="3"><%=fb.textBox("dilatacion"+i,prop.getProperty("dilatacion"+i),false,false,viewMode,30,"Text10",null,null)%></td>
			<td colspan="3"><%=fb.textBox("altura"+i,prop.getProperty("altura"+i),false,false,viewMode,30,"Text10",null,null)%></td>
			<td colspan="3"><%=fb.textBox("presentacion"+i,prop.getProperty("presentacion"+i),false,false,viewMode,30,"Text10",null,null)%></td>
		</tr>
<%
}
%>
		<tr class="TextHeader">
			<td colspan="9" align="left"></td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="3">Edema:</td>
			<td align="right" rowspan="3">S&iacute;:</td>
			<td align="center" rowspan="3"><%=fb.radio("edema","S",(prop.getProperty("edema").equalsIgnoreCase("S")),viewMode,false,null,null,"onclick=\"ctrlEdema(this.value)\"")%></td>
			<td align="right">Leve:</td>
			<td align="center"><%=fb.radio("edema2","LE",(prop.getProperty("edema2").equalsIgnoreCase("LE")),viewMode,false)%></td>
			<td align="right" rowspan="3">No</td>
			<td align="center" rowspan="3"><%=fb.radio("edema","N",(prop.getProperty("edema").equalsIgnoreCase("N")),viewMode,false,null,null,"onclick=\"ctrlEdema(this.value)\"")%></td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Moderado:</td>
			<td align="center"><%=fb.radio("edema2","MO",(prop.getProperty("edema2").equalsIgnoreCase("MO")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Severo:</td>
			<td align="center"><%=fb.radio("edema2","SE",(prop.getProperty("edema2").equalsIgnoreCase("SE")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>

	<%}
//	if(fg.trim().equals("NIPA")||fg.trim().equals("NIPE")){//Notas de Ingresos Partos/Pediatria%>


		<tr class="TextRow01">
			<td align="right">Historia Actual</td>
			<td colspan="8"><%=fb.textarea("histActual",prop.getProperty("histActual"),false,false ,viewMode,60,2,2000,null,"",null)%></td>
		</tr>
<%//}%>
<%if(fg.trim().equals("NIPE")){//Notas de Ingresos Partos/Pediatria%>
		<tr class="TextRow01">
			<td align="right">Plan de Cuidado Inicial</td>
			<td colspan="8"><%=fb.textarea("plan_incial",prop.getProperty("plan_incial"),false,false ,viewMode,60,2,2000,null,"",null)%></td>
		</tr>
<%}%>


<%if(fg.trim().equals("NINO")){%>
		<tr class="TextHeader">
			<td colspan="9" align="left">CONDICION GENERAL</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">APGAR  min 1</td>
			<td colspan="4"><%=fb.textBox("apgar1",prop.getProperty("apgar1"),false,false,viewMode,20,"Text10",null,null)%></td>
			<td align="right">APGAR  min 5</td>
			<td colspan="4"><%=fb.textBox("apgar5",prop.getProperty("apgar5"),false,false,viewMode,20,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Llanto</td>
			<td align="right">Fuerte</td>
			<td align="center"><%=fb.radio("llanto","F",(prop.getProperty("llanto").equalsIgnoreCase("F")),viewMode,false)%></td>
			<td align="right">D&eacute;bil</td>
			<td align="center"><%=fb.radio("llanto","D",(prop.getProperty("llanto").equalsIgnoreCase("D")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="3">Piel</td>
			<td align="right" rowspan="3">Acrocianosis</td>
			<td align="center" rowspan="3"><%=fb.radio("piel","A",(prop.getProperty("piel").equalsIgnoreCase("A")),viewMode,false)%></td>
			<td align="right">Miembros S.</td>
			<td align="center"><%=fb.radio("piel2","MS",(prop.getProperty("piel2").equalsIgnoreCase("MS")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Miembros I.</td>
			<td align="center"><%=fb.radio("piel2","MI",(prop.getProperty("piel2").equalsIgnoreCase("MI")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Ambos.</td>
			<td align="center"><%=fb.radio("piel2","AM",(prop.getProperty("piel2").equalsIgnoreCase("AM")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Malformaciones Cong&eacute;nitas</td>
			<td align="right">No</td>
			<td align="center"><%=fb.radio("malformacion","N",(prop.getProperty("malformacion").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td align="right">S&iacute;</td>
			<td align="center"><%=fb.radio("malformacion","S",(prop.getProperty("malformacion").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td colspan="4">Cuales &nbsp;<%=fb.textarea("obserMalformacion",prop.getProperty("obserMalformacion"),false,false ,viewMode,30,2,2000,null,"",null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="2">Profil&aacute;xis</td>
			<td align="right" rowspan="2">No</td>
			<td align="center" rowspan="2"><%=fb.radio("profilaxis","N",(prop.getProperty("profilaxis").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td align="right" rowspan="2">S&iacute;</td>
			<td align="center" rowspan="2"><%=fb.radio("profilaxis","S",(prop.getProperty("profilaxis").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td colspan="2" align="left">Eritromicina Ung&uuml;ento Oft.</td>
			<td colspan="2" align="left"><%=fb.radio("profilaxis2","EU",(prop.getProperty("profilaxis2").equalsIgnoreCase("EU")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2" align="right">Otros.</td>
			<td colspan="2" align="center"><%=fb.radio("profilaxis2","OT",(prop.getProperty("profilaxis2").equalsIgnoreCase("OT")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Queda En:</td>
			<td align="right">Incub. Cerrada</td>
			<td align="center"><%=fb.radio("queda_en","IC",(prop.getProperty("queda_en").equalsIgnoreCase("IC")),viewMode,false)%></td>
			<td align="right">Incub. Abierta</td>
			<td align="center"><%=fb.radio("queda_en","IA",(prop.getProperty("queda_en").equalsIgnoreCase("IA")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="2">Recibiendo O2:</td>
			<td align="right">2 LTS</td>
			<td align="center"><%=fb.radio("o2","2L",(prop.getProperty("o2").equalsIgnoreCase("2L")),viewMode,false)%></td>
			<td align="right">4 LTS</td>
			<td align="center"><%=fb.radio("o2","CL",(prop.getProperty("o2").equalsIgnoreCase("CL")),viewMode,false)%></td>
			<td align="right">6 LTS</td>
			<td align="center"><%=fb.radio("o2","SL",(prop.getProperty("o2").equalsIgnoreCase("SL")),viewMode,false)%></td>
			<td align="left">8 LTS</td>
			<td align="left"><%=fb.radio("o2","OL",(prop.getProperty("o2").equalsIgnoreCase("OL")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">10 LTS</td>
			<td align="center"><%=fb.radio("o2","DL",(prop.getProperty("o2").equalsIgnoreCase("DL")),viewMode,false)%></td>
			<td align="right" colspan="7">&nbsp;</td>
		</tr>
		<!--<tr class="TextRow01">
			<td align="right">Dextroxtis</td>
			<td colspan="8"><%//=fb.textBox("dextroxtis",prop.getProperty("dextroxtis"),false,false,viewMode,40,"Text10",null,null)%></td>
		</tr>-->
		<!--<tr class="TextRow01">
			<td align="right">Dolor:</td>
			<td align="right">S&iacute;</td>
			<td align="center"><%//=fb.radio("dolor","S",(prop.getProperty("dolor").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right">No</td>
			<td align="center"><%//=fb.radio("dolor","N",(prop.getProperty("dolor").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>-->

		<tr class="TextRow01">
			<td align="right">Permeabilidad Anal:</td>
			<td align="right">S&iacute;</td>
			<td align="center"><%=fb.radio("permeabilidad","S",(prop.getProperty("permeabilidad").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right">No</td>
			<td align="center"><%=fb.radio("permeabilidad","N",(prop.getProperty("permeabilidad").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Permeabilidad Coanas:</td>
			<td align="right">S&iacute;</td>
			<td align="center"><%=fb.radio("permeabilidadCo","S",(prop.getProperty("permeabilidadCo").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right">No</td>
			<td align="center"><%=fb.radio("permeabilidadCo","N",(prop.getProperty("permeabilidadCo").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
<%}%>



<%
//fb.appendJsValidation("\n\t if (!chkMedico()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td colspan="9" align="right">
				Opciones de Guardar:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
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
	prop.setProperty("tipo_nota",request.getParameter("fg"));

	prop.setProperty("admitido",request.getParameter("admitido"));
	prop.setProperty("llegada",request.getParameter("llegada"));
	prop.setProperty("acompaniante",request.getParameter("acompaniante"));
	prop.setProperty("religion",request.getParameter("religion"));

	prop.setProperty("fecha",request.getParameter("fecha"));
	prop.setProperty("hora",request.getParameter("hora"));
	prop.setProperty("diagnostico",request.getParameter("diagnostico"));
	//prop.put("llegada",request.getParameter("llegada"));
	//prop.put("acompaniante",request.getParameter("acompaniante"));

	prop.setProperty("presion",request.getParameter("presion"));
	prop.setProperty("pulso",request.getParameter("pulso"));
	prop.setProperty("respiracion",request.getParameter("respiracion"));
	prop.setProperty("temperatura",request.getParameter("temperatura"));
	prop.setProperty("peso",request.getParameter("peso"));
	prop.setProperty("talla",request.getParameter("talla"));

	prop.setProperty("cod_medico",request.getParameter("cod_medico"));
	prop.setProperty("nombre_medico",request.getParameter("nombre_medico"));
	prop.setProperty("codDiag",request.getParameter("codDiag"));
	prop.setProperty("descDiag",request.getParameter("descDiag"));

	prop.setProperty("aplicar1",request.getParameter("aplicar1"));
	prop.setProperty("observacion1",request.getParameter("observacion1"));
	prop.setProperty("aplicar2",request.getParameter("aplicar2"));
	prop.setProperty("observacion2",request.getParameter("observacion2"));
	prop.setProperty("aplicar3",request.getParameter("aplicar3"));
	prop.setProperty("observacion3",request.getParameter("observacion3"));
	prop.setProperty("aplicar4",request.getParameter("aplicar4"));
	prop.setProperty("observacion4",request.getParameter("observacion4"));
	prop.setProperty("aplicar5",request.getParameter("aplicar5"));
	prop.setProperty("observacion5",request.getParameter("observacion5"));
	prop.setProperty("aplicar6",request.getParameter("aplicar6"));
	prop.setProperty("observacion6",request.getParameter("observacion6"));
	prop.setProperty("aplicar7",request.getParameter("aplicar7"));
	prop.setProperty("observacion7",request.getParameter("observacion7"));
	prop.setProperty("aplicar8",request.getParameter("aplicar8"));
	prop.setProperty("observacion8",request.getParameter("observacion8"));

	prop.setProperty("gesta",request.getParameter("gesta"));
	prop.setProperty("para",request.getParameter("para"));
	prop.setProperty("aborto",request.getParameter("aborto"));
	prop.setProperty("cesarea",request.getParameter("cesarea"));
	prop.setProperty("fum",request.getParameter("fum"));
	prop.setProperty("fpp",request.getParameter("fpp"));
	prop.setProperty("presentacion",request.getParameter("presentacion"));
	prop.setProperty("situacion",request.getParameter("situacion"));
	prop.setProperty("dorso",request.getParameter("dorso"));
	prop.setProperty("actividad",request.getParameter("actividad"));
	prop.setProperty("can_dura",request.getParameter("can_dura"));
	prop.setProperty("membranas",request.getParameter("membranas"));
	prop.setProperty("liquido",request.getParameter("liquido"));
	prop.setProperty("fcf",request.getParameter("fcf"));
	prop.setProperty("dilatacion1",request.getParameter("dilatacion1"));
	prop.setProperty("altura1",request.getParameter("altura1"));
	prop.setProperty("presentacion1",request.getParameter("presentacion1"));
	prop.setProperty("dilatacion2",request.getParameter("dilatacion2"));
	prop.setProperty("altura2",request.getParameter("altura2"));
	prop.setProperty("presentacion2",request.getParameter("presentacion2"));
	prop.setProperty("dilatacion3",request.getParameter("dilatacion3"));
	prop.setProperty("altura3",request.getParameter("altura3"));
	prop.setProperty("presentacion3",request.getParameter("presentacion3"));
	prop.setProperty("dilatacion4",request.getParameter("dilatacion4"));
	prop.setProperty("altura4",request.getParameter("altura4"));
	prop.setProperty("presentacion4",request.getParameter("presentacion4"));
	prop.setProperty("edema",request.getParameter("edema"));
	prop.setProperty("edema2",request.getParameter("edema2"));

	prop.setProperty("obserEnf",request.getParameter("obserEnf"));
	prop.setProperty("histActual",request.getParameter("histActual"));

	prop.setProperty("apgar1",request.getParameter("apgar1"));
	prop.setProperty("apgar5",request.getParameter("apgar5"));
	prop.setProperty("llanto",request.getParameter("llanto"));
	prop.setProperty("piel",request.getParameter("piel"));
	prop.setProperty("piel2",request.getParameter("piel2"));
	prop.setProperty("malformacion",request.getParameter("malformacion"));
	prop.setProperty("obserMalformacion",request.getParameter("obserMalformacion"));
	prop.setProperty("profilaxis",request.getParameter("profilaxis"));
	prop.setProperty("profilaxis2",request.getParameter("profilaxis2"));
	prop.setProperty("queda_en",request.getParameter("queda_en"));
	prop.setProperty("o2",request.getParameter("o2"));
	//prop.setProperty("dextroxtis",request.getParameter("dextroxtis"));
	prop.setProperty("permeabilidad",request.getParameter("permeabilidad"));
	prop.setProperty("permeabilidadCo",request.getParameter("permeabilidadCo"));

	prop.setProperty("plan_incial",request.getParameter("plan_incial"));
	prop.setProperty("dolor",request.getParameter("dolor"));

	/*
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	prop.put("",request.getParameter(""));
	*/

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) NIEMgr.add(prop);
		else NIEMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (NIEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NIEMgr.getErrMsg()%>');
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
} else throw new Exception(NIEMgr.getErrException());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>