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
<jsp:useBean id="NEEMgr" scope="page" class="issi.expediente.NotaEgresoEnfermeriaMgr" />
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
NEEMgr.setConnection(ConMgr);

Properties prop = new Properties();
CommonDataObject cdo = new CommonDataObject();
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NEPA";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");
	
	if (prop == null)
	{
	 	prop = new Properties();
		prop.setProperty("fecha",cDateTime.substring(0,10));
		prop.setProperty("hora",cDateTime.substring(11));
	}
	else modeSec = "edit";
	if(!prop.getProperty("fecha").trim().equals(cDateTime.substring(0,10)))
	{ 
		modeSec = "view";
		viewMode = true;
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
<%if(fg.trim().equals("NEPA")){%>
document.title = 'Notas del Parto - '+document.title;
<%}%>

function doAction(){newHeight();}
function getMedico(){var medico=eval('document.form0.cod_medico').value;var especMed = '';var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','b.especialidad,primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico a,tbl_adm_medico_especialidad b','a.codigo = b.medico(+) and b.secuencia(+) = 1 and  a.codigo=\''+medico+'\'','');if(medDesc!=''){var index = medDesc.indexOf('|'); if(index > 0)especMed = medDesc.substring(0,index);eval('document.form0.nombre_medico').value=medDesc.substring(index+1);}else{ alert('El Medico no Existe Verifique!');eval('document.form0.cod_medico').value='';eval('document.form0.cod_medico').focus();}}}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=notas_enf');}
function chkMedico(){if(document.form0.baction.value=="Guardar"){if(eval('document.form0.cod_medico').value!='' && eval('document.form0.nombre_medico').value==''){alert('El Medico no Existe Verifique!');eval('document.form0.cod_medico').value ='';eval('document.form0.cod_medico').focus();return false;}else return true;}else return true;}
function showDiagnosticoList(){abrir_ventana1('../common/search_diagnostico.jsp?fp=notas_enf');}
function printExp(){ abrir_ventana1('../expediente/print_exp_seccion_72.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>');}
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
<%=fb.hidden("desc",desc)%>

		<tr class="TextRow02">
			<td colspan="8" align="right"><a href="javascript:printExp();">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="2">PARTO</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="3">Fecha</cellbytelabel>&nbsp;</td>
			<td colspan="3">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td align="right"><cellbytelabel id="4">Hora</cellbytelabel></td>
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
			<td width="21%" align="right"><cellbytelabel id="5">Parto Vaginal</cellbytelabel>:</td>
			<td width="16%" align="right"><cellbytelabel id="6">EMLD</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("parto","EL",(prop.getProperty("parto").equalsIgnoreCase("EL")),viewMode,false)%></td>
			<td width="16%" align="right"><cellbytelabel id="7">EM</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("parto","EM",(prop.getProperty("parto").equalsIgnoreCase("EM")),viewMode,false)%></td>
			<td width="16%" align="right">&nbsp;</td>
			<td width="5%"  align="center">&nbsp;</td>
			<td width="16%" align="right">&nbsp;</td>
		</tr>
		
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="8">Datos Recien Nacido</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right" colspan="8">
					<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="2%" rowspan="2">&nbsp;</td>
							<td width="12%" colspan="2"><cellbytelabel id="9">Sexo</cellbytelabel></td>
							<td width="25%" rowspan="2"><cellbytelabel id="10">Apgar</cellbytelabel></td>
							<td width="25%" rowspan="2"><cellbytelabel id="11">Peso</cellbytelabel></td>
							<td width="25%" rowspan="2"><cellbytelabel id="12">Semanas</cellbytelabel></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td><cellbytelabel id="13">Femenino</cellbytelabel></td>
							<td><cellbytelabel id="14">Masculino</cellbytelabel></td>
						</tr>
						<tr class="TextRow01" align="center">
							<td>1.</td>
							<td><%=fb.radio("sexo1","F",(prop.getProperty("sexo1").equalsIgnoreCase("F")),viewMode,false)%></td>
							<td><%=fb.radio("sexo1","M",(prop.getProperty("sexo1").equalsIgnoreCase("M")),viewMode,false)%></td>
							<td><%=fb.textBox("apgar1",prop.getProperty("apgar1"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("peso1",prop.getProperty("peso1"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("semanas1",prop.getProperty("semanas1"),false,false,viewMode,10,"Text10",null,null)%></td>
						</tr>
						<tr class="TextRow01" align="center">
							<td>2.</td>
							<td><%=fb.radio("sexo2","F",(prop.getProperty("sexo2").equalsIgnoreCase("F")),viewMode,false)%></td>
							<td><%=fb.radio("sexo2","M",(prop.getProperty("sexo2").equalsIgnoreCase("M")),viewMode,false)%></td>
							<td><%=fb.textBox("apgar2",prop.getProperty("apgar2"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("peso2",prop.getProperty("peso2"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("semanas2",prop.getProperty("semanas2"),false,false,viewMode,10,"Text10",null,null)%></td>
						</tr>
						<tr class="TextRow01" align="center">
							<td>3.</td>
							<td><%=fb.radio("sexo3","F",(prop.getProperty("sexo3").equalsIgnoreCase("F")),viewMode,false)%></td>
							<td><%=fb.radio("sexo3","M",(prop.getProperty("sexo3").equalsIgnoreCase("M")),viewMode,false)%></td>
							<td><%=fb.textBox("apgar3",prop.getProperty("apgar3"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("peso3",prop.getProperty("peso3"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("semanas3",prop.getProperty("semanas3"),false,false,viewMode,10,"Text10",null,null)%></td>
						</tr>
						<tr class="TextRow01" align="center">
							<td>4.</td>
							<td><%=fb.radio("sexo4","F",(prop.getProperty("sexo4").equalsIgnoreCase("F")),viewMode,false)%></td>
							<td><%=fb.radio("sexo4","M",(prop.getProperty("sexo4").equalsIgnoreCase("M")),viewMode,false)%></td>
							<td><%=fb.textBox("apgar4",prop.getProperty("apgar4"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("peso4",prop.getProperty("peso4"),false,false,viewMode,10,"Text10",null,null)%></td>
							<td><%=fb.textBox("semanas4",prop.getProperty("semanas4"),false,false,viewMode,10,"Text10",null,null)%></td>
						</tr>
					</table>
			</td>
		</tr>
		
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="15">M&eacute;dico</cellbytelabel>:</td>
			<td colspan="7">
					<%=fb.textBox("cod_medico",prop.getProperty("cod_medico"),false,false,(viewMode),10,null,null,"onChange=\"javascript:getMedico()\"")%>
					<%=fb.textBox("nombre_medico",prop.getProperty("nombre_medico"),false,viewMode,true,60)%>
					<%=fb.button("medico","...",true,(viewMode),null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%></td>
		</tr>
		
		<tr class="TextRow01">
			<td align="right" rowspan="2"><cellbytelabel id="16">L&iacute;quido Amniotico</cellbytelabel>:</td>
			<td align="right" rowspan="2"><cellbytelabel id="17">Claro</cellbytelabel>:</td>
			<td align="center" rowspan="2"><%=fb.radio("liquido","CL",(prop.getProperty("liquido").equalsIgnoreCase("CL")),viewMode,false)%></td>
			<td align="right" rowspan="2"><cellbytelabel id="18">Meconial</cellbytelabel>:</td>
			<td align="right"><cellbytelabel id="19">Fluido</cellbytelabel>:</td>
			<td align="center"><%=fb.radio("liquido","FL",(prop.getProperty("liquido").equalsIgnoreCase("FL")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="20">Sanguinolento</cellbytelabel></td>
			<td align="center"><%=fb.radio("liquido","SA",(prop.getProperty("liquido").equalsIgnoreCase("SA")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="21">Espeso</cellbytelabel>:</td>
			<td align="center"><%=fb.radio("liquido","ES",(prop.getProperty("liquido").equalsIgnoreCase("ES")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="22">Malformaciones Cong&eacute;nitas</cellbytelabel></td>
			<td align="right"><cellbytelabel id="23">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("malformacion","N",(prop.getProperty("malformacion").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="24">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("malformacion","S",(prop.getProperty("malformacion").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td colspan="3"><cellbytelabel id="25">Cuales</cellbytelabel> &nbsp;<%=fb.textarea("obserMalformacion",prop.getProperty("obserMalformacion"),false,false ,viewMode,35,2,2000,null,"",null)%> </td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="26">Apego Madre e Hijos</cellbytelabel></td>
			<td align="right"><cellbytelabel id="24">S&iacute</cellbytelabel>;</td>
			<td align="center"><%=fb.radio("apego","S",(prop.getProperty("apego").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="23">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("apego","N",(prop.getProperty("apego").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td align="right" rowspan="2"><cellbytelabel id="27">Placenta</cellbytelabel></td>
			<td align="right" rowspan="2"><cellbytelabel id="28">Nace</cellbytelabel></td>
			<td align="center" rowspan="2"><%=fb.radio("placenta","NA",(prop.getProperty("placenta").equalsIgnoreCase("NA")),viewMode,false)%></td>
			<td align="right" ><cellbytelabel id="29">Duncan</cellbytelabel></td>
			<td align="center"><%=fb.radio("placenta2","DU",(prop.getProperty("placenta2").equalsIgnoreCase("DU")),viewMode,false)%></td>
			<td align="right" rowspan="2"><cellbytelabel id="30">Retenci&oacute;n</cellbytelabel></td>
			<td align="center" rowspan="2"><%=fb.radio("placenta","RE",(prop.getProperty("placenta").equalsIgnoreCase("RE")),viewMode,false)%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td align="right" ><cellbytelabel id="31">Schultz</cellbytelabel></td>
			<td align="center"><%=fb.radio("placenta2","SC",(prop.getProperty("placenta2").equalsIgnoreCase("SC")),viewMode,false)%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="2"><cellbytelabel id="32">Sutura Episotam&iacute;a</cellbytelabel></td>
			<td align="right" rowspan="2"><cellbytelabel id="24">S&iacute;</cellbytelabel></td>
			<td align="center" rowspan="2"><%=fb.radio("sutura","S",(prop.getProperty("sutura").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right" ><cellbytelabel id="33">Cromico 0-0</cellbytelabel></td>
			<td align="center"><%=fb.radio("sutura2","CR",(prop.getProperty("sutura2").equalsIgnoreCase("CR")),viewMode,false)%></td>
			<td><%=fb.textBox("suturaDesc1","",false,false,viewMode,15,"Text10",null,null)%></td>
			<td align="right" rowspan="2"><cellbytelabel id="23">No</cellbytelabel></td>
			<td align="center" rowspan="2"><%=fb.radio("sutura","N",(prop.getProperty("sutura").equalsIgnoreCase("N")),viewMode,false)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right" ><cellbytelabel id="34">Caprosyn 0-0</cellbytelabel></td>
			<td align="center"><%=fb.radio("sutura2","CA",(prop.getProperty("sutura2").equalsIgnoreCase("CA")),viewMode,false)%></td>
			<td><%=fb.textBox("suturaDesc2","",false,false,viewMode,15,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="35">&Uacute;tero</cellbytelabel></td>
			<td align="right"><cellbytelabel id="36">Relajado</cellbytelabel></td>
			<td align="center"><%=fb.radio("utero","R",(prop.getProperty("utero").equalsIgnoreCase("R")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="37">Contraido</cellbytelabel></td>
			<td align="center"><%=fb.radio("utero","C",(prop.getProperty("utero").equalsIgnoreCase("C")),viewMode,false)%></td>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="3"><cellbytelabel id="38">Loquias</cellbytelabel></td>
			<td align="right"><cellbytelabel id="39">Rubras</cellbytelabel></td>
			<td align="center"><%=fb.radio("loquias","RU",(prop.getProperty("loquias").equalsIgnoreCase("RU")),viewMode,false)%></td>
			<td align="right" rowspan="3"><cellbytelabel id="40">Cantidad</cellbytelabel></td>
			<td align="right"><cellbytelabel id="41">Abundante</cellbytelabel></td>
			<td align="center"><%=fb.radio("cantidad","AB",(prop.getProperty("cantidad").equalsIgnoreCase("AB")),viewMode,false)%></td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="42">Albas</cellbytelabel></td>
			<td align="center"><%=fb.radio("loquias","AL",(prop.getProperty("loquias").equalsIgnoreCase("AL")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="43">Moderada</cellbytelabel></td>
			<td align="center"><%=fb.radio("cantidad","MO",(prop.getProperty("cantidad").equalsIgnoreCase("MO")),viewMode,false)%></td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="44">Serosa</cellbytelabel></td>
			<td align="center"><%=fb.radio("loquias","SE",(prop.getProperty("loquias").equalsIgnoreCase("SE")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="45">Leve</cellbytelabel></td>
			<td align="center"><%=fb.radio("cantidad","LE",(prop.getProperty("cantidad").equalsIgnoreCase("LE")),viewMode,false)%></td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="46">Se Traslada a puerperio</cellbytelabel></td>
			<td align="right"><cellbytelabel id="47">Mediato</cellbytelabel></td>
			<td align="center"><%=fb.radio("traslada","ME",(prop.getProperty("traslada").equalsIgnoreCase("ME")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="48">Immediato</cellbytelabel></td>
			<td align="center"><%=fb.radio("traslada","IM",(prop.getProperty("traslada").equalsIgnoreCase("IM")),viewMode,false)%></td>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="49">Observaciones</cellbytelabel></td>
			<td colspan="8"><%=fb.textarea("observacion",prop.getProperty("observacion"),false,false ,viewMode,55,2,2000,null,"",null)%></td>
		</tr>
		

<%
fb.appendJsValidation("\n\tif (!chkMedico()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td colspan="8" align="right">
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
	prop.setProperty("tipo_nota",request.getParameter("fg"));
	prop.setProperty("fecha",request.getParameter("fecha"));
	prop.setProperty("hora",request.getParameter("hora"));

	prop.setProperty("parto",request.getParameter("parto"));
	
	/** SECCION DE VARIOS REGISTROS PARA LOS CASOS DE PARTOS MULTIPLES **/
	
	prop.setProperty("sexo1",request.getParameter("sexo1"));
	prop.setProperty("apgar1",request.getParameter("apgar1"));
	prop.setProperty("peso1",request.getParameter("peso1"));
	prop.setProperty("semanas1",request.getParameter("semanas1"));
	
	prop.setProperty("sexo2",request.getParameter("sexo2"));
	prop.setProperty("apgar2",request.getParameter("apgar2"));
	prop.setProperty("peso2",request.getParameter("peso2"));
	prop.setProperty("semanas2",request.getParameter("semanas2"));
	
	prop.setProperty("sexo3",request.getParameter("sexo3"));
	prop.setProperty("apgar3",request.getParameter("apgar3"));
	prop.setProperty("peso3",request.getParameter("peso3"));
	prop.setProperty("semanas3",request.getParameter("semanas3"));
	
	prop.setProperty("sexo4",request.getParameter("sexo4"));
	prop.setProperty("apgar4",request.getParameter("apgar4"));
	prop.setProperty("peso4",request.getParameter("peso4"));
	prop.setProperty("semanas4",request.getParameter("semanas4"));
	
	prop.setProperty("cod_medico",request.getParameter("cod_medico"));
	prop.setProperty("nombre_medico",request.getParameter("nombre_medico"));
	prop.setProperty("liquido",request.getParameter("liquido"));
	prop.setProperty("malformacion",request.getParameter("malformacion"));
	prop.setProperty("obserMalformacion",request.getParameter("obserMalformacion"));
	prop.setProperty("apego",request.getParameter("apego"));
	prop.setProperty("placenta",request.getParameter("placenta"));
	
	prop.setProperty("placenta2",request.getParameter("placenta2"));
	prop.setProperty("sutura",request.getParameter("sutura"));
	prop.setProperty("sutura2",request.getParameter("sutura2"));
	prop.setProperty("suturaDesc1",request.getParameter("suturaDesc1"));
	prop.setProperty("suturaDesc2",request.getParameter("suturaDesc2"));
	prop.setProperty("utero",request.getParameter("utero"));
	prop.setProperty("loquias",request.getParameter("loquias"));

	prop.setProperty("cantidad",request.getParameter("cantidad"));
	prop.setProperty("traslada",request.getParameter("traslada"));
	prop.setProperty("observacion",request.getParameter("observacion"));
	
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) NEEMgr.add(prop);
		else NEEMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (NEEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NEEMgr.getErrMsg()%>');
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
} else throw new Exception(NEEMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
















