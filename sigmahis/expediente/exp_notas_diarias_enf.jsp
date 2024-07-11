<%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="NDEMgr" scope="page" class="issi.expediente.NotasDiariasEnfermeriaMgr" />

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
NDEMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();

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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NDNO";
if (id == null) id = "0";

if ( desc == null ) desc = "";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	al = SQLMgr.getDataPropertiesList("select nota from tbl_sal_notas_diarias_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"' order by id desc ");
	prop = SQLMgr.getDataProperties("select nota from tbl_sal_notas_diarias_enf where id="+id+" ");
	if (prop == null)
	{
		prop = new Properties();
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora",""+cDateTime.substring(11));
	}
	else modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Notas de Diarias de Enfermeria - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();checkViewMode();}
function isChecked(k){eval('document.form0.observacion'+k).disabled = !eval('document.form0.aplicar'+k).checked;if (eval('document.form0.aplicar'+k).checked){eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';}else{eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';}}
function setEvaluacion(code){window.location = '../expediente/exp_notas_diarias_enf.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id='+code;}
function add(){window.location = '../expediente/exp_notas_diarias_enf.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&id=0';}
function checkedFecha(){var x =0;var msg ='Seleccione ';if (eval('document.form0.fecha').value == ''){x++;msg +=' fecha '}if (eval('document.form0.hora').value == ''){x++;msg += ' , Hora';}if (x>0){ alert(msg);return false;}else return true;}
function imprimir(){abrir_ventana1('../expediente/print_exp_seccion_73.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&seccion=<%=seccion%>&desc=<%=desc%>');}
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
<tr class="TextRow02">
			<td colspan="3" align="right"></td>
		</tr>
<tr class="TextRow01">
					<td>
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("desc",desc)%>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Notas Diarias</cellbytelabel></td>
							<td align="right">
							<%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Nota</cellbytelabel> ]</a><%}%>&nbsp;<a href="javascript:imprimir()" class="Link00">[<cellbytelabel id="3">Imprimir</cellbytelabel>]</a></td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="4">Fecha</cellbytelabel></td>
							<td  width="15%"><cellbytelabel id="5">Hora</cellbytelabel></td>
							<td  width="65%">&nbsp;</td>
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
				<td><%=i%></td>
				<td><%=prop1.getProperty("fecha")%></td>
				<td colspan="2"><%=prop1.getProperty("hora")%></td>

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
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>

		<tr class="TextRow02">
			<td colspan="13">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="13"><cellbytelabel id="6">NOTAS DIARIAS</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="4">Fecha</cellbytelabel>&nbsp;</td>
			<td colspan="4">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td align="right"><cellbytelabel id="5">Hora</cellbytelabel></td>
			<td colspan="5">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora"%>" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
				</tr>

		<tr class="TextRow02">
			<td width="15%" align="right"  rowspan="2"><strong><cellbytelabel id="7">Se Recibe R. Nac.</cellbytelabel>:</strong></td>
			<td width="10%" align="right"  rowspan="2"><cellbytelabel id="8">Bacinete</cellbytelabel></td>
		  <td width="3%"  align="center" rowspan="2"><%=fb.radio("llegada","BA",(prop.getProperty("llegada").equalsIgnoreCase("BA")),viewMode,false)%></td>
		  <td width="8%" align="right"  rowspan="2"><cellbytelabel id="9">Fototerapia</cellbytelabel></td>			
		  <td width="9%"  align="center" rowspan="2"><%=fb.radio("llegada","FO",(prop.getProperty("llegada").equalsIgnoreCase("FO")),viewMode,false)%></td>
		  <td width="8%" align="right"  rowspan="2"><cellbytelabel id="10">O2</cellbytelabel></td>			
		  <td width="4%"  align="center" rowspan="2"><%=fb.radio("llegada","O2",(prop.getProperty("llegada").equalsIgnoreCase("O2")),viewMode,false)%></td>
  			<td width="8%" align="right"  rowspan="2"></td>
		  <td width="5%"  align="center" rowspan="2"><cellbytelabel id="11">Incubadora</cellbytelabel></td>		  
		
		  <td width="14%" height="21" align="right"><cellbytelabel id="12">Abierto</cellbytelabel></td>
		  <td width="16%"  align="center"><%=fb.radio("llegada2","ABI",(prop.getProperty("llegada2").equalsIgnoreCase("ABI")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow02">
			<td width="14%" align="right"><cellbytelabel id="13">Cerrado</cellbytelabel></td>
		  <td width="16%"  align="center"><%=fb.radio("llegada2","CER",(prop.getProperty("llegada2").equalsIgnoreCase("CER")),viewMode,false)%></td>
		</tr>
		
			<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="14">Respiraci&oacute;n</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
			<td align="center"><%=fb.radio("respiracion","NOR",(prop.getProperty("respiracion").equalsIgnoreCase("NOR")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="16">Frecuencia</cellbytelabel></td>
			<td align="center"><%=fb.radio("respiracion","FRE",(prop.getProperty("respiracion").equalsIgnoreCase("FRE")),viewMode,false)%></td>
						<td width="8%" align="right"><cellbytelabel id="17">Quejido</cellbytelabel></td>
		  <td width="4%"  align="center" ><%=fb.radio("respiracion","QUE",(prop.getProperty("respiracion").equalsIgnoreCase("QUE")),viewMode,false)%></td>
		  	<td width="8%" align="right"><cellbytelabel id="18">Tiraje</cellbytelabel></td>
		  <td width="5%"  align="center"><%=fb.radio("respiracion","TIR",(prop.getProperty("respiracion").equalsIgnoreCase("TIR")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="19">Aleteo</cellbytelabel></td>
		  <td width="16%"  align="center" ><%=fb.radio("respiracion","ALE",(prop.getProperty("respiracion").equalsIgnoreCase("ALE")),viewMode,false)%></td>
		</tr>
		
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="20">Llanto</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="21">Fuerte</cellbytelabel></td>
			<td align="center"><%=fb.radio("llanto","FU",(prop.getProperty("llanto").equalsIgnoreCase("FU")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="22">D&eacute;bil</cellbytelabel></td>
			<td align="center"><%=fb.radio("llanto","DE",(prop.getProperty("llanto").equalsIgnoreCase("DE")),viewMode,false)%></td>
						<td width="8%" align="right" >&nbsp;</td>
		  <td width="4%"  align="center" >&nbsp;</td>
		  	<td width="8%" align="right" >&nbsp;</td>
		  <td width="5%"  align="center" >&nbsp;</td>
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="23">Sist. Nervioso</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="24">Activo</cellbytelabel></td>
			<td align="center"><%=fb.radio("actividad","AC",(prop.getProperty("actividad").equalsIgnoreCase("AC")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="25">Hipoactivo</cellbytelabel></td>
			<td align="center"><%=fb.radio("actividad","HI",(prop.getProperty("actividad").equalsIgnoreCase("HI")),viewMode,false)%></td>						
			<td align="right"><cellbytelabel id="26">Hipot&oacute;nico</cellbytelabel></td>
			<td align="center"><%=fb.radio("actividad","HIP",(prop.getProperty("actividad").equalsIgnoreCase("HIP")),viewMode,false)%></td>						
			<td align="right"><cellbytelabel id="27">Temblores</cellbytelabel></td>
			<td align="center"><%=fb.radio("actividad","TEM",(prop.getProperty("actividad").equalsIgnoreCase("TEM")),viewMode,false)%></td>						
			<td align="right"><cellbytelabel id="28">Convulsiones</cellbytelabel></td>
			<td align="center"><%=fb.radio("actividad","CON",(prop.getProperty("actividad").equalsIgnoreCase("CON")),viewMode,false)%></td>						
		</tr>
		<tr class="TextRow02">
			<td align="right"  rowspan="3"><strong><cellbytelabel id="29">Piel</cellbytelabel></strong></td>
			<td align="right"  rowspan="3"><cellbytelabel id="30">Rosada</cellbytelabel></td>
			<td align="center" rowspan="3"><%=fb.radio("piel","AC",(prop.getProperty("piel").equalsIgnoreCase("AC")),viewMode,false)%></td>
			
		 <td width="8%" align="right" rowspan="3"><cellbytelabel id="31">P&aacute;lida</cellbytelabel></td>
		  <td width="9%"  align="center" rowspan="3"><%=fb.radio("piel","PAL",(prop.getProperty("piel").equalsIgnoreCase("PAL")),viewMode,false)%></td>
		  <td width="8%" align="right"  rowspan="3"><cellbytelabel id="32">Cianosis</cellbytelabel></td>
		  <td width="4%"  align="center" rowspan="3"><%=fb.radio("piel","CIA",(prop.getProperty("piel").equalsIgnoreCase("CIA")),viewMode,false)%></td>
		  
		  <td align="right" rowspan="3"></td>
			<td align="center" rowspan="3"><cellbytelabel id="33">Ictericia</cellbytelabel></td>
			<td align="right"><cellbytelabel id="34">Leve</cellbytelabel></td>
			<td align="center"><%=fb.radio("piel2","LE",(prop.getProperty("piel2").equalsIgnoreCase("LE")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right"><cellbytelabel id="35">Moderada</cellbytelabel></td>
			<td align="center"><%=fb.radio("piel2","MO",(prop.getProperty("piel2").equalsIgnoreCase("MO")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow02">
		<td align="right"><cellbytelabel id="36">Severa</cellbytelabel></td>
			<td align="center"><%=fb.radio("piel2","SE",(prop.getProperty("piel2").equalsIgnoreCase("SE")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="37">Temperatura</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="38">Normotermico</cellbytelabel></td>
			<td align="center"><%=fb.radio("temperatura","NO",(prop.getProperty("temperatura").equalsIgnoreCase("NO")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="39">Hipotermico</cellbytelabel></td>
			<td align="center"><%=fb.radio("temperatura","HI",(prop.getProperty("temperatura").equalsIgnoreCase("HI")),viewMode,false)%></td>	
			<td align="right"></td>
			<td align="center">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>							
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="40">Succi&oacute;n</cellbytelabel></strong> </td>
			<td align="right"><cellbytelabel id="41">Buena</cellbytelabel></td>
			<td align="center"><%=fb.radio("succion","B",(prop.getProperty("succion").equalsIgnoreCase("B")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="42">Malo</cellbytelabel></td>
			<td align="center"><%=fb.radio("succion","M",(prop.getProperty("succion").equalsIgnoreCase("M")),viewMode,false)%></td>
			<td width="8%" align="right" >&nbsp;</td>
		  <td width="4%"  align="center" >&nbsp;</td>
		  <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
				<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="43">Higiene</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="44">General</cellbytelabel></td>
			<td align="center"><%=fb.radio("bano","G",(prop.getProperty("bano").equalsIgnoreCase("G")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="45">Parcial</cellbytelabel></td>
			<td align="center"><%=fb.radio("bano","P",(prop.getProperty("bano").equalsIgnoreCase("P")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
						<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="46">Profilaxis</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("profilaxis","S",(prop.getProperty("profilaxis").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("profilaxis","N",(prop.getProperty("profilaxis").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td width="8%" align="right"  >&nbsp;</td>
		    <td width="4%"  align="center" >&nbsp;</td>
		    <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		
			<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="49">Ombligo</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
			<td align="center"><%=fb.radio("Ombligo","NOR",(prop.getProperty("Ombligo").equalsIgnoreCase("NOR")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="50">Secreci&oacute;n</cellbytelabel></td>
			<td align="center"><%=fb.radio("Ombligo","SEC",(prop.getProperty("Ombligo").equalsIgnoreCase("SEC")),viewMode,false)%></td>
			<td width="8%" align="right"><cellbytelabel id="51">Enrojecimiento</cellbytelabel></td>
		  <td width="4%"  align="center"><%=fb.radio("Ombligo","ENR",(prop.getProperty("Ombligo").equalsIgnoreCase("ENR")),viewMode,false)%></td>
		  <td align="right"><cellbytelabel id="52">Hemorragia</cellbytelabel></td>
			<td align="center"><%=fb.radio("Ombligo","HEM",(prop.getProperty("Ombligo").equalsIgnoreCase("HEM")),viewMode,false)%></td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		
		
		
		<!--<tr class="TextRow02">
			<td align="right"><strong>Alcohol al 70%</strong></td>
			<td align="right">S&iacute;</td>
			<td align="center"><%//=fb.radio("alcohol","S",(prop.getProperty("alcohol").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right">No</td>
			<td align="center"><%//=fb.radio("alcohol","N",(prop.getProperty("alcohol").equalsIgnoreCase("N")),viewMode,false)%></td>	
			<td width="8%" align="right"  >&nbsp;</td>
		  <td width="4%"  align="center" >&nbsp;</td>
		  <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>				
			<td align="right" colspan="2">&nbsp;</td>
		</tr>-->
				<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="53">Orin&oacute;</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("orino","S",(prop.getProperty("orino").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("orino","N",(prop.getProperty("orino").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td width="8%" align="right"  >&nbsp;</td>
		   <td width="4%"  align="center" >&nbsp;</td>
		   <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="54">Heces</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("heces","SI",(prop.getProperty("heces").equalsIgnoreCase("SI")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("heces","NO",(prop.getProperty("heces").equalsIgnoreCase("NO")),viewMode,false)%></td>
			<td width="8%" align="right"  >&nbsp;</td>
		   <td width="4%"  align="center" >&nbsp;</td>
		   <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="55">Vomit&oacute;</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("vomito","S",(prop.getProperty("vomito").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("vomito","N",(prop.getProperty("vomito").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td width="8%" align="right"  >&nbsp;</td>
		  <td width="4%"  align="center" >&nbsp;</td>
		  <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="56">Meconio</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("meconio","S",(prop.getProperty("meconio").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("meconio","N",(prop.getProperty("meconio").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td width="8%" align="right"  >&nbsp;</td>
		  <td width="4%"  align="center" >&nbsp;</td>
		  <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		
		
		<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="57">Abdomen</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
			<td align="center"><%=fb.radio("abdomen","NOR",(prop.getProperty("abdomen").equalsIgnoreCase("NOR")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="58">Distendido</cellbytelabel></td>
			<td align="center"><%=fb.radio("abdomen","DIS",(prop.getProperty("abdomen").equalsIgnoreCase("DIS")),viewMode,false)%></td>
			<td width="8%" align="right"  >&nbsp;</td>
		  <td width="4%"  align="center" >&nbsp;</td>
		  <td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		
		
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="59">Relaci&oacute;n Madre-Hijo</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="60">Aceptaci&oacute;n</cellbytelabel></td>
			<td align="center"><%=fb.radio("apego","S",(prop.getProperty("apego").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td width="8%" align="right"><cellbytelabel id="61">Inseguridad</cellbytelabel></td>
		  <td width="9%"  align="center" ><%=fb.radio("apego","INS",(prop.getProperty("apego").equalsIgnoreCase("INS")),viewMode,false)%></td>
 			<td align="right"><cellbytelabel id="62">Rechazo</cellbytelabel></td>
			<td align="center"><%=fb.radio("apego","N",(prop.getProperty("apego").equalsIgnoreCase("N")),viewMode,false)%></td>
		  <td align="right"></td>
			<td align="center"></td>		
			<td align="right" colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"  rowspan="4"><strong><cellbytelabel id="63">Alimentaci&oacute;n</cellbytelabel></strong></td>
			<td align="right"  rowspan="4"><cellbytelabel id="64">Pecho exclusivo</cellbytelabel></td>
			<td align="center" rowspan="4"><%=fb.radio("alimentacion","PE",(prop.getProperty("alimentacion").equalsIgnoreCase("PE")),viewMode,false)%></td>
			<td align="right"  rowspan="4"><cellbytelabel id="65">F&oacute;rmula</cellbytelabel></td>
			<td align="center" rowspan="4"><%=fb.radio("alimentacion","FO",(prop.getProperty("alimentacion").equalsIgnoreCase("FO")),viewMode,false)%></td>
			<td width="8%" align="right"  rowspan="4" ><cellbytelabel id="66">Sonda</cellbytelabel></td>
		  <td width="4%"  align="center" rowspan="4"><%=fb.radio("alimentacion","SON",(prop.getProperty("alimentacion").equalsIgnoreCase("SON")),viewMode,false)%></td>
		  <td width="8%" align="right"  rowspan="4" ></td>
		  <td width="5%"  align="center" rowspan="4"><cellbytelabel id="67">Aceptaci&oacute;n</cellbytelabel></td>
			<td align="right"><cellbytelabel id="41">Buena</cellbytelabel></td>
			<td align="center"><%=fb.radio("alimentacionPor","SI",(prop.getProperty("alimentacionPor").equalsIgnoreCase("N")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="62">Rechazo</cellbytelabel></td>
			<td align="center"><%=fb.radio("alimentacionPor","EP",(prop.getProperty("alimentacionPor").equalsIgnoreCase("EP")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="68">Regurgitaci&oacute;n</cellbytelabel></td>
			<td align="center"><%=fb.radio("alimentacionPor","OT",(prop.getProperty("alimentacionPor").equalsIgnoreCase("OT")),viewMode,false)%></td>
		</tr>
		
		<tr class="TextRow01">
		<td align="right"><cellbytelabel id="55">Vomit&oacute;</cellbytelabel></td>
		<td align="center"><%=fb.radio("alimentacionPor","VOM",(prop.getProperty("alimentacionPor").equalsIgnoreCase("VOM")),viewMode,false)%></td>
		</tr>
		
		<tr class="TextRow02">
			<td align="right"><strong><cellbytelabel id="69">Circunscisi&oacute;n</cellbytelabel></strong></td>
			<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("circunscision","S",(prop.getProperty("circunscision").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("circunscision","N",(prop.getProperty("circunscision").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td align="right"></td>
			<td align="center"></td>
			<td align="right" colspan="6">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><strong><cellbytelabel id="70">Destrostix</cellbytelabel></strong></td>
			<td colspan="10"><%=fb.textBox("dextroxtis",prop.getProperty("dextroxtis"),false,false,viewMode,60,"Text10",null,null)%></td>
		</tr>

<%
fb.appendJsValidation("\n\tif (!checkedFecha()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");
%>
		<tr class="TextRow02">
			<td colspan="11" align="right">
				<cellbytelabel id="71">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="72">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="73">Cerrar</cellbytelabel>
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
	prop.setProperty("id",request.getParameter("id"));

	prop.setProperty("fecha",request.getParameter("fecha"));
	prop.setProperty("hora",request.getParameter("hora"));

	prop.setProperty("llegada",request.getParameter("llegada"));
	prop.setProperty("llegada2",request.getParameter("llegada2"));
	prop.setProperty("llanto",request.getParameter("llanto"));
	prop.setProperty("actividad",request.getParameter("actividad"));
	prop.setProperty("piel",request.getParameter("piel"));
	prop.setProperty("piel2",request.getParameter("piel2"));
	prop.setProperty("temperatura",request.getParameter("temperatura"));

//	prop.setProperty("tono_muscular",request.getParameter("tono_muscular"));
	prop.setProperty("bano",request.getParameter("bano"));
	prop.setProperty("profilaxis",request.getParameter("profilaxis"));
//	prop.setProperty("alcohol",request.getParameter("alcohol"));

	prop.setProperty("succion",request.getParameter("succion"));
	prop.setProperty("orino",request.getParameter("orino"));
	prop.setProperty("vomito",request.getParameter("vomito"));
	prop.setProperty("meconio",request.getParameter("meconio"));
	prop.setProperty("apego",request.getParameter("apego"));
	prop.setProperty("alimentacion",request.getParameter("alimentacion"));
	prop.setProperty("alimentacionPor",request.getParameter("alimentacionPor"));
//	prop.setProperty("alimentacionObs",request.getParameter("alimentacionObs"));
	prop.setProperty("circunscision",request.getParameter("circunscision"));
	prop.setProperty("dextroxtis",request.getParameter("dextroxtis"));
	
	prop.setProperty("abdomen",request.getParameter("abdomen"));
	prop.setProperty("heces",request.getParameter("heces"));
	prop.setProperty("Ombligo",request.getParameter("Ombligo"));
	prop.setProperty("respiracion",request.getParameter("respiracion"));
		
	


	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
		{
		 	NDEMgr.add(prop);
			id = NDEMgr.getPkColValue("id");
		}
		else NDEMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (NDEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NDEMgr.getErrMsg()%>');
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
} else throw new Exception(NDEMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
















