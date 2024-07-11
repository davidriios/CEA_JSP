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
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String curUserName = (String)session.getAttribute("_userName");
String key = "";

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NEEN";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");
	if (prop == null) prop = new Properties();
	else modeSec = "edit";

	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script>
var noNewHeight = true;
document.title = 'Notas de Egreso - '+document.title;
function doAction(){}
function isChecked(k){/*eval('document.form0.observacion'+k).disabled = !eval('document.form0.aplicar'+k).checked;if (eval('document.form0.aplicar'+k).checked){	eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';}else{eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';}*/}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_71.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fg=<%=fg%>&desc=<%=desc%>");}
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
<%=fb.hidden("usuario_creacion",(prop.getProperty("usuario_creacion")!=null&&!prop.getProperty("usuario_creacion").equals("")?prop.getProperty("usuario_creacion"):curUserName))%>
<%=fb.hidden("fecha_creacion",(prop.getProperty("fecha_creacion")!=null&&!prop.getProperty("fecha_creacion").equals("")?prop.getProperty("fecha_creacion"):curDate))%>
		<tr class="TextRow02">
			<td colspan="9" align="right"><a href="javascript:printExp();" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="9"><cellbytelabel id="2">EGRESO</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="3">Fecha</cellbytelabel>&nbsp;</td>
			<td colspan="3">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("view"))?"y":"n"%>"/>
				</jsp:include></td>
			<td align="right"><cellbytelabel id="4">Hora</cellbytelabel></td>
			<td colspan="4">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora"%>" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("view"))?"y":"n"%>"/>
				</jsp:include></td>
		</tr>

		<tr class="TextRow01">
			<td width="20%" align="right"><cellbytelabel id="5">Salida</cellbytelabel>:</td>
			<td width="15%" align="right"><cellbytelabel id="6">Autorizada</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("salida","AU",(prop.getProperty("salida").equalsIgnoreCase("AU")),viewMode,false)%></td>
			<td width="15%" align="right"><cellbytelabel id="7">Voluntaria</cellbytelabel></td>
			<td width="5%"  align="center"><%=fb.radio("salida","VO",(prop.getProperty("salida").equalsIgnoreCase("VO")),viewMode,false)%></td>
			<td width="15%" align="right">&nbsp;</td>
			<td width="5%"  align="center">&nbsp;</td>
			<td width="15%" align="right">&nbsp;</td>
			<td width="5%">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="8">Relevo de Responsabilidad</cellbytelabel></td>
			<td align="right"><cellbytelabel id="9">S&iacute;</cellbytelabel></td>
			<td align="center"><%=fb.radio("relevo","S",(prop.getProperty("relevo").equalsIgnoreCase("S")),viewMode,false)%></td>
			<td align="right"><cellbytelabel id="10">No</cellbytelabel></td>
			<td align="center"><%=fb.radio("relevo","N",(prop.getProperty("relevo").equalsIgnoreCase("N")),viewMode,false)%></td>
			<td align="right">&nbsp;</td>
			<td align="center">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="11">Signos Vitales</cellbytelabel>:</td>
			<td align="right"><cellbytelabel id="12">P/A</cellbytelabel>:</td>
			<td align="center"><%=fb.textBox("presion",prop.getProperty("presion"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right"><cellbytelabel id="13">P</cellbytelabel>:</td>
			<td align="center"><%=fb.textBox("pulso",prop.getProperty("pulso"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right"><cellbytelabel id="14">R</cellbytelabel>:</td>
			<td align="center"><%=fb.textBox("respiracion",prop.getProperty("respiracion"),false,false,viewMode,6,"Text10",null,null)%></td>
			<td align="right"><cellbytelabel id="15">T</cellbytelabel>:</td>
			<td align="center"><%=fb.textBox("temperatura",prop.getProperty("temperatura"),false,false,viewMode,6,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right" rowspan="2"><cellbytelabel id="16">Estado de Consciencia</cellbytelabel>:</td>
			<td align="right"><cellbytelabel id="17">Consciente</cellbytelabel>:</td>
			<td><%=fb.radio("estado","C",(prop.getProperty("estado").equalsIgnoreCase("C")),viewMode,false)%></td>
			<td colspan="6" rowspan="2"><%=fb.textBox("consciente1",prop.getProperty("consciente1"),false,false,viewMode,60,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="18">Orientado</cellbytelabel>:</td>
			<td><%=fb.radio("estado","O",(prop.getProperty("estado").equalsIgnoreCase("O")),viewMode,false)%></td>
			<!--<td colspan="6"><%//=fb.textBox("consciente2",prop.getProperty("consciente2"),false,false,viewMode,60,"Text10",null,null)%></td>-->
		</tr>

		<tr class="TextHeader">
			<td colspan="9"><cellbytelabel id="19">INTERVENCI&Oacute;N DE ENFERMER&Iacute;A</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="9">
				<div id="notas" width="100%" class="exp h300">
				<div id="notasDet" width="98%" class="child">
					<table align="center" width="100%" cellpadding="1" cellspacing="1">

						<tr class="TextHeader">
							<td width="35%"><cellbytelabel id="20">Condici&oacute;n</cellbytelabel></td>
							<td width="5%">&nbsp;</td>
							<td width="60%"><cellbytelabel id="21">Observaci&oacute;n</cellbytelabel></td>
						</tr>
						<tr>
							<td><cellbytelabel id="22">Educaci&oacute;n al paciente y al Familiar</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(1)\"")%></td>
							<td><%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="23">Cumplimiento de &Oacute;rdenes M&eacute;dicas</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(2)\"")%></td>
							<td><%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="24">Receta de Medicamentos</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(3)\"")%></td>
							<td><%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="25">Administraci&oacute;n de Medicinas</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(4)\"")%></td>
							<td><%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="26">Alimentaci&oacute;n por S.N.E.</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar5","S",(prop.getProperty("aplicar5").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(5)\"")%></td>
							<td><%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td>A<cellbytelabel id="27">limentaci&oacute;n por Gastrostom&iacute;a</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar6","S",(prop.getProperty("aplicar6").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(6)\"")%></td>
							<td><%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="28">Cambio de bolsa de colostom&iacute;a<</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar7","S",(prop.getProperty("aplicar7").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(7)\"")%></td>
							<td><%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="29">Cambio de bolsa de Ileostom&iacute;a</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar8","S",(prop.getProperty("aplicar8").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(8)\"")%></td>
							<td><%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="30">Uso de sonda de Foley</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar9","S",(prop.getProperty("aplicar9").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(9)\"")%></td>
							<td><%=fb.textarea("observacion9",prop.getProperty("observacion9"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="31">Retiro de Cat&eacute;ter Venoso central</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar10","S",(prop.getProperty("aplicar10").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(10)\"")%></td>
							<td><%=fb.textarea("observacion10",prop.getProperty("observacion10"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="32">Retiro de sello de Heparina</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar11","S",(prop.getProperty("aplicar11").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(11)\"")%></td>
							<td><%=fb.textarea("observacion11",prop.getProperty("observacion11"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="33">Hacer devoluci&oacute;n de Mat. y Med.</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar12","S",(prop.getProperty("aplicar12").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(12)\"")%></td>
							<td><%=fb.textarea("observacion12",prop.getProperty("observacion12"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="34">Orientaci&oacute;n a Cita m&eacute;dica</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar13","S",(prop.getProperty("aplicar13").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(13)\"")%></td>
							<td><%=fb.textarea("observacion13",prop.getProperty("observacion13"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="35">Retiro de marquilla</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar14","S",(prop.getProperty("aplicar14").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(14)\"")%></td>
							<td><%=fb.textarea("observacion14",prop.getProperty("observacion14"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="36">Sale en silla de ruedas</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar15","S",(prop.getProperty("aplicar15").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(15)\"")%></td>
							<td><%=fb.textarea("observacion15",prop.getProperty("observacion15"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr><tr>
							<td><cellbytelabel id="36">Sale en ambulancia</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar16","S",(prop.getProperty("aplicar16").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(16)\"")%></td>
							<td><%=fb.textarea("observacion16",prop.getProperty("observacion16"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="37">Sale solo</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar17","S",(prop.getProperty("aplicar17").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(17)\"")%></td>
							<td><%=fb.textarea("observacion17",prop.getProperty("observacion17"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="38">Acompañado por familiar</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar18","S",(prop.getProperty("aplicar18").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(18)\"")%></td>
							<td><%=fb.textarea("observacion18",prop.getProperty("observacion18"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="39">Acompañado de personal de Hogar</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar19","S",(prop.getProperty("aplicar19").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(19)\"")%></td>
							<td><%=fb.textarea("observacion19",prop.getProperty("observacion19"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="40">Acompañado por Mensajero</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar20","S",(prop.getProperty("aplicar20").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(20)\"")%></td>
							<td><%=fb.textarea("observacion20",prop.getProperty("observacion20"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="41">Entrega de Valores</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar21","S",(prop.getProperty("aplicar21").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(21)\"")%></td>
							<td><%=fb.textarea("observacion21",prop.getProperty("observacion21"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>
						<tr>
							<td><cellbytelabel id="42">Otros Datos</cellbytelabel></td>
							<td align="center"><%=fb.checkbox("aplicar22","S",(prop.getProperty("aplicar22").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked(22)\"")%></td>
							<td><%=fb.textarea("observacion22",prop.getProperty("observacion22"),false,false ,viewMode,55,2,2000,null,"'",null)%></td>
						</tr>

					</table>
				</div>
				</div>

			</td>
		</tr>


<%
fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td colspan="9" align="right">
				<cellbytelabel id="43">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="44">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="45">Cerrar</cellbytelabel>
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
	prop.setProperty("salida",request.getParameter("salida"));
	prop.setProperty("relevo",request.getParameter("relevo"));

	prop.setProperty("presion",request.getParameter("presion"));
	prop.setProperty("pulso",request.getParameter("pulso"));
	prop.setProperty("respiracion",request.getParameter("respiracion"));
	prop.setProperty("temperatura",request.getParameter("temperatura"));

	prop.setProperty("estado",request.getParameter("estado"));
	prop.setProperty("consciente1",request.getParameter("consciente1"));
	//prop.setProperty("consciente2",request.getParameter("consciente2"));

	prop.setProperty("usuario_modificacion",curUserName);
	prop.setProperty("fecha_modificacion",curDate);

	if (modeSec.equalsIgnoreCase("add")){
		prop.setProperty("usuario_creacion",curUserName);
		prop.setProperty("fecha_creacion",curDate);
	}else{
		 prop.setProperty("usuario_creacion",request.getParameter("usuario_creacion"));
		 prop.setProperty("fecha_creacion",request.getParameter("fecha_creacion"));
	}

	for(int k=1;k<=22;k++)
	{
		prop.setProperty("aplicar"+k,request.getParameter("aplicar"+k));
		prop.setProperty("observacion"+k,request.getParameter("observacion"+k));

	}

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
















