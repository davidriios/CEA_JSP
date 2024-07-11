<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ENMgr" scope="page" class="issi.expediente.EvaluacionNutricionalMgr" />
<%
/**
==================================================================================
Fg = EA = Evaluacion Nutricional Adulto.
Fg = EN = Evaluacion Nutricional Neonatologia.
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
ENMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();
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
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String code = request.getParameter("id");
String cds = request.getParameter("cds");
String medico = request.getParameter("medico");
String from = request.getParameter("from");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (fg == null) fg = "EN";//Evaluacion Nutricional Adulto
if (id == null) id = "0";
if (desc == null) desc = "";
if (medico == null) medico = "";
if (from == null) from = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
    int tot = CmnMgr.getCount("select count(*) from tbl_sal_nutricion_parenteral where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = '"+fg+"' and fecha_creac = ( select max(fecha_creac) from tbl_sal_nutricion_parenteral where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = '"+fg+"' ) and round((sysdate -  fecha_creac ) * 24,2) >= 24.00");

    al = SQLMgr.getDataPropertiesList("select evaluacion from tbl_sal_nutricion_parenteral where pac_id="+pacId+" and admision="+noAdmision+"and tipo = '"+fg+"' order by id desc ");
    prop = SQLMgr.getDataProperties("select evaluacion from tbl_sal_nutricion_parenteral where id="+id+" ");
	
	if (prop == null)
	{ 
		prop = new Properties();
		prop.setProperty("id","0");
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora_inicio","");
        prop.setProperty("hora",cDateTime.substring(10));
		prop.setProperty("forma_solicitud","P");
	}
	else modeSec = "view";
    
    if (al.size() < 1) tot = 1;
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'Nutrición Parenteral Neonatal y Pediátrico - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){document.form0.medico.value = '<%=from.equals("salida_pop")?medico:((UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"")%>';checkViewMode();var val = $("input[name='formaSolicitudX']:checked").val();setFormaSolicitud(val);}
function setEvaluacion(code){window.location = '../expediente3.0/exp_nutricion_parenteral_neos.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id='+code+'&desc=<%=desc%>&cds=<%=cds%>&from=<%=from%>&medico=<%=medico%>';}
function add(){window.location = '../expediente3.0/exp_nutricion_parenteral_neos.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&desc=<%=desc%>&cds=<%=cds%>&from=<%=from%>&medico=<%=medico%>';}
function Calc(){var total = 0;var volumen =0;var peso=0;if(isNaN(eval('document.form0.peso').value) || eval('document.form0.peso').value=='') alert('Introduzca Peso correcto');else peso = parseFloat(eval('document.form0.peso').value);if(isNaN(eval('document.form0.volumen').value) || eval('document.form0.volumen').value=='') alert('Introduzca Volumen correcto');else volumen = parseFloat(eval('document.form0.volumen').value);total = peso * volumen;eval('document.form0.volumen_dia').value =total;}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_98.jsp?fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=code%>&desc=<%=desc%>");}
function printExpAll(){abrir_ventana("../expediente/print_exp_seccion_98_all.jsp?fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>");}

function verHistorial() {
  $("#hist_container").toggle();
}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
<style type="text/css">
<!--
.style1 {color: #0033CC}
-->
</style>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("medico",medico)%>
<%=fb.hidden("formaSolicitud","")%>
<%=fb.hidden("from",from)%>

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td class="controls form-inline">
    <%if(!mode.trim().equals("view") && tot > 0){%>    
        <button type="button" class="btn btn-inverse btn-sm" onClick="add()">
          <i class="fa fa-plus fa-printico"></i> <b><cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel></b>
        </button>
    <%}%>
    <%if(id.trim().equals("0")){%>
        <button type="button" class="btn btn-inverse btn-sm" onClick="printExpAll()"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todo</b></button>
    <%}else{%>
        
        <button type="button" class="btn btn-inverse btn-sm" onClick="printExp()"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todo</b></button>
     <%}%>
     <%if(al.size() > 0){%>
         <button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
            <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
          </button>
     <%}%>

</td>
</tr>
</table> 

<div class="table-wrapper" id="hist_container" style="display:none">  
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
<tr class="bg-headtabla2">
    <th>&nbsp;</th>
    <th><cellbytelabel id="5">Fecha</cellbytelabel></th>
    <th>Hora</th>
    <th>&nbsp;</th>
</tr>
</thead>
<tbody>
<%
for (int i=1; i<=al.size(); i++)
{
	Properties prop1 = (Properties) al.get(i-1);
%>
		<tr onClick="setEvaluacion(<%=prop1.getProperty("id")%>);" style="text-decoration:none; cursor:pointer">
            <td><%=prop1.getProperty("id")%></td>
            <td><%=prop1.getProperty("fecha")%></td>
            <td colspan="2"><%=prop1.getProperty("hora")%></td>
		</tr>
<%}%>
</tbody>
</table>
</div>           
 </div>
 
<table cellspacing="0" class="table table-small-font table-bordered table-striped"> 
    <tr class="bg-headtabla">
        <td colspan="3"><cellbytelabel id="6">DATOS GENERALES</cellbytelabel></td>
    </tr>
	<tr class="TextRow01">
		<td colspan="3" class="controls form-inline"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel> 
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>	&nbsp;&nbsp;&nbsp;Usuario que Recibe, Transcribe, lee y Confirma:
					<%=fb.textBox("userCrea",UserDet.getName(),true, false,true,15,"form-control input-sm","","")%>			
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,25,"form-control input-sm","","")%>
                <button type="button" class="btn btn-sm btn-inverse" onClick="showMedicList()" id="btnMed" name="btnMed"<%=viewMode?" disabled":""%>><i class="fa fa-ellipsis-h fa-printico"></i></button>
		</td>	
	</tr>	
    <tr>
        <td align="right"><cellbytelabel id="5">Fecha</cellbytelabel>&nbsp;</td>
        <td class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="dd/mm/yyyy"/>
            <jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel id="5">Hora</cellbytelabel>&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="hh12:mi:ss am"/>
            <jsp:param name="nameOfTBox1" value="hora" />
            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
        </td>
        <td class="controls form-inline">
            <cellbytelabel id="7">Hora Inicio</cellbytelabel>
            <%=fb.textBox("hora_inicio",prop.getProperty("hora_inicio"),false,false,viewMode,10,15,"form-control input-sm",null,null)%><cellbytelabel id="8">ml/Hrs</cellbytelabel>
		</td>
    </tr>

    <tr>
        <td colspan="3">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped"> 
            <tr class="TextRow01" align="center">
                <td width="15%" class="controls form-inline"><%=fb.decBox("peso",prop.getProperty("peso"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="9">(Kg)</cellbytelabel></td>
                <td width="25%" class="controls form-inline"> X <%=fb.decBox("volumen",prop.getProperty("volumen"),false,false,viewMode,7,"form-control input-sm",null,"onChange=\"javascript:Calc()\"")%><cellbytelabel id="10">(ml/por/dia)</cellbytelabel></td>
                <td width="25%" class="controls form-inline">= <%=fb.textBox("volumen_dia",prop.getProperty("volumen_dia"),false,false,viewMode,7,"form-control input-sm",null,"")%> <cellbytelabel id="10">(ml/por/dia)</cellbytelabel> </td>
                <td width="35%" class="controls form-inline"><cellbytelabel id="11">24 Hrs</cellbytelabel>= <%=fb.textBox("volumen_total",prop.getProperty("volumen_total"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="12">(ml/hrs)</cellbytelabel></td>
            </tr>
			
            <tr align="center" style="font-weight:bold">
                <td><cellbytelabel id="13">Peso</cellbytelabel></td>
                <td><cellbytelabel id="14">Volumen de Líquido NPT</cellbytelabel></td>
                <td><cellbytelabel id="15">Volumen total por dia</cellbytelabel></td>
                <td><cellbytelabel id="16">Volumen total en 24 horas</cellbytelabel></td>
            </tr>
					
		</table>
		</td>
	</tr>
    
    <tr class="bg-headtabla">
        <td colspan="3"><cellbytelabel id="17">MACRONUTRIENTES</cellbytelabel></td>
    </tr>
		
    <tr class="TextRow02">
        <td colspan="3">
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr class="TextRow01">
                    <td width="20%"><cellbytelabel id="18">Amino&aacute;cidos</cellbytelabel></td>
                    <td width="10%" class="controls form-inline"><%=fb.textBox("macro1",prop.getProperty("macro1"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="19">Gms/Kg/D&iacute;a</cellbytelabel></td>
                    <td width="20%" class="controls form-inline"><cellbytelabel id="20">Tipo de A.A(%)</cellbytelabel>:</td>
                    <td width="10%" class="controls form-inline"><%=fb.textBox("macro2",prop.getProperty("macro2"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="19">Gms/Kg/D&iacute;a</cellbytelabel></td>
                    <td width="10%" class="controls form-inline"><cellbytelabel id="21">Vol</cellbytelabel>.</td>
                    <td width="15%" class="controls form-inline"><%=fb.textBox("macro3",prop.getProperty("macro3"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="22">ml/24Hr</cellbytelabel>.</td>
                    <td width="25%" rowspan="2" class="controls form-inline"><cellbytelabel id="23">Gm N</cellbytelabel><%=fb.textBox("macro4",prop.getProperty("macro4"),false,false,viewMode,3,"form-control input-sm",null,"")%></td>
                </tr>
                <tr class="TextRow01">
                    <td><cellbytelabel id="25">Amino&aacute;cidos Especiales</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("macro5",prop.getProperty("macro5"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="19">Gms/Kg/D&iacute;a</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td><cellbytelabel id="21">Vol</cellbytelabel>.</td>
                    <td class="controls form-inline"><%=fb.textBox("macro6",prop.getProperty("macro6"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="22">ml/24Hr</cellbytelabel>.</td>
                </tr>
                <tr class="bg-headtabla2">
                    <td colspan="7"><cellbytelabel id="26">(REQUIERE APROBACIÓN DEL SERVICIO DE SOPORTE NUTRICIONAL)</cellbytelabel></td>
                </tr>
                <tr class="TextRow02">
                    <td><cellbytelabel id="27">Dextrosa</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("macro7",prop.getProperty("macro7"),false,false,viewMode,7,"form-control input-sm",null,"")%>% <cellbytelabel id="28">final</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td><cellbytelabel id="21">Vol</cellbytelabel>.</td>
                    <td class="controls form-inline"><%=fb.textBox("macro8",prop.getProperty("macro8"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="22">ml/24Hr</cellbytelabel>.</td>
                    <td class="controls form-inline">Kcal<%=fb.textBox("macro9",prop.getProperty("macro9"),false,false,viewMode,3,"form-control input-sm",null,"")%></td>
                </tr>
                <tr class="TextRow01">
                    <td><cellbytelabel id="29">L&iacute;pidos 10%  20%</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("macro10",prop.getProperty("macro10"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="19">Gms/Kg/D&iacute;a</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("macro11",prop.getProperty("macro11"),false,false,viewMode,7,"form-control input-sm",null,"")%></td>
                    <td>&nbsp;</td>
                    <td><cellbytelabel id="21">Vol</cellbytelabel>.</td>
                    <td class="controls form-inline"><%=fb.textBox("macro12",prop.getProperty("macro12"),false,false,viewMode,7,"form-control input-sm",null,"")%><cellbytelabel id="22">ml/24Hr</cellbytelabel>.</td>
                    <td class="controls form-inline">Kcal<%=fb.textBox("macro13",prop.getProperty("macro13"),false,false,viewMode,3,"form-control input-sm",null,"")%></td>
                </tr>
            </table>
        </td>
    </tr>
    
    <tr class="TextRow02">
        <td colspan="3">
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr class="bg-headtabla2">
                    <td colspan="10"><cellbytelabel id="30">ELECTROLITOS(POR DIA)</cellbytelabel></td>
                </tr>
                <tr class="TextRow01">
                    <td width="16%"><cellbytelabel id="31">NaCI</cellbytelabel></td>
                    <td width="13%" class="controls form-inline"><%=fb.textBox("electro1",prop.getProperty("electro1"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td width="5%"><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td width="5%">&nbsp;</td>
                    <td width="13%" class="controls form-inline"><%=fb.textBox("electro2",prop.getProperty("electro2"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td width="5%"><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                    <td width="5%">&nbsp;</td>
                    
                    <td><cellbytelabel id="34">Insulina(Reg)</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro6",prop.getProperty("electro6"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                    <td><cellbytelabel id="35">U/d&iacute;a</cellbytelabel></td>
                </tr>
						
                <tr class="TextRow01">
                    <td><cellbytelabel id="36">Acetato Na</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro4",prop.getProperty("electro4"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.textBox("electro5",prop.getProperty("electro5"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td width="15%"><cellbytelabel id="37">Gluconato de Calcio</cellbytelabel></td>
                    <td width="13%" class="controls form-inline"><%=fb.textBox("electro3",prop.getProperty("electro3"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                    <td width="10%"><cellbytelabel id="38">ml/kg</cellbytelabel></td>
                </tr>
                <tr class="TextRow01">
                    <td><cellbytelabel id="39">Fosfato Na</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro7",prop.getProperty("electro7"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.textBox("electro8",prop.getProperty("electro8"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td><cellbytelabel id="40">Heparina</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro9",prop.getProperty("electro9"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                    <td><cellbytelabel id="35">U/d&iacute;a</cellbytelabel></td>
                </tr>
                <tr class="TextRow01">
                    <td><cellbytelabel id="41">KCL</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro10",prop.getProperty("electro10"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.textBox("electro11",prop.getProperty("electro11"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                    <td rowspan="4" >&nbsp;</td>
                    <td rowspan="4" colspan="3" valign="top" class="controls form-inline"><cellbytelabel id="42">Otros</cellbytelabel> <%=fb.textarea("electro12",prop.getProperty("electro12"),false,false,viewMode,50,2,2000,"form-control input-sm","",null)%></td>
                </tr>
						
                <tr class="TextRow01">
                    <td><cellbytelabel id="43">Acetato K</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro13",prop.getProperty("electro13"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.textBox("electro14",prop.getProperty("electro14"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                </tr>
						
                <tr class="TextRow01">
                    <td><cellbytelabel id="44">Fosfato K</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro15",prop.getProperty("electro15"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.textBox("electro16",prop.getProperty("electro16"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                </tr>
                <tr class="TextRow01">
                    <td><cellbytelabel id="45">MgSO</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.textBox("electro17",prop.getProperty("electro17"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="32">mEq/kg</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.textBox("electro18",prop.getProperty("electro18"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="33">mEq/d&iacute;a</cellbytelabel></td>
                </tr>
                <tr class="TextRow01">
                    <td><cellbytelabel id="46">Elementos Trazas</cellbytelabel>:</td>
                    <td class="controls form-inline"><%=fb.textBox("electro19",prop.getProperty("electro19"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td><cellbytelabel id="22">ml/24Hr</cellbytelabel></td>
                    <td>&nbsp;</td>
                    <td rowspan="3" valign="middle" colspan="2" align="right"><cellbytelabel id="47">ultivitaminas Pediátricas</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.checkbox("electro20","S",(prop.getProperty("electro20").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
                    <td colspan="4"><cellbytelabel id="48">1.5 ml si es menor de 1 kg</cellbytelabel></td>
                </tr>
						
                <tr class="TextRow01">
                    <td><cellbytelabel id="49">Zn Adicional</cellbytelabel>:</td>
                    <td class="controls form-inline"><%=fb.textBox("electro21",prop.getProperty("electro21"),false,false,viewMode,5,"form-control input-sm",null,"")%></td>
                    <td>(<cellbytelabel id="50">mcg/d&iacute;a</cellbytelabel>)</td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.checkbox("electro22","S",(prop.getProperty("electro22").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
                    <td colspan="4"><cellbytelabel id="51">3.25 ml si es menor de 1 - 3 kg</cellbytelabel></td>
                </tr>
                <tr class="TextRow01">
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td class="controls form-inline"><%=fb.checkbox("electro23","S",(prop.getProperty("electro23").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
                    <td colspan="4"><cellbytelabel id="52">5 ml si es menor de 3 kg</cellbytelabel></td>
                </tr>
            </table>
			</td>
		</tr>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr class="TextRow02">
			<td colspan="3" align="right">
                <%=fb.hidden("saveOption","O")%>
                <%if(tot > 0){%>
                <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                <%}%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.parent.doRedirect(0)\"")%>
			</td>
		</tr>
    </table>
</div>    
<%fb.appendJsValidation("if(error>0)doAction();");%>
<%=fb.formEnd(true)%>
</div>
</div>
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

	prop.setProperty("fecha",request.getParameter("fecha"));
    prop.setProperty("hora",request.getParameter("hora"));
	prop.setProperty("hora_inicio",request.getParameter("hora_inicio"));
	
	//prop.setProperty("talla",request.getParameter("talla"));
	//prop.setProperty("peso",request.getParameter("peso"));
	prop.setProperty("id",request.getParameter("id"));
	prop.setProperty("tipo",""+fg);
	
	prop.setProperty("peso",request.getParameter("peso"));
	prop.setProperty("volumen",request.getParameter("volumen"));
	prop.setProperty("volumen_dia",request.getParameter("volumen_dia"));
	prop.setProperty("volumen_total",request.getParameter("volumen_total"));
	
	for(int l=1;l<=13;l++)
	{
		prop.setProperty("macro"+l,request.getParameter("macro"+l));
	}
	
	for(int k=1;k<=23;k++)
	{
		prop.setProperty("electro"+k,request.getParameter("electro"+k));
	}
	
	prop.setProperty("usuario_mod",(String) session.getAttribute("_userName"));
	prop.setProperty("fecha_mod",cDateTime);	
	prop.setProperty("medico",request.getParameter("medico"));
	prop.setProperty("fec_nacimiento", request.getParameter("dob"));
	prop.setProperty("cod_paciente",request.getParameter("codPac"));
	prop.setProperty("cds",request.getParameter("cds"));
	prop.setProperty("forma_solicitud",request.getParameter("formaSolicitud"));	
					
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg);
		if (modeSec.equalsIgnoreCase("add")) 
		{	
			prop.setProperty("usuario_creac",(String) session.getAttribute("_userName"));
			prop.setProperty("fecha_creac",cDateTime);
			ENMgr.add(prop);
			id = ENMgr.getPkColValue("id");
		}
		else ENMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ENMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ENMgr.getErrMsg()%>');
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
} else throw new Exception(ENMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&cds=<%=cds%>&from=<%=from%>&medico=<%=medico%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
















