<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
if (tab == null) tab = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
sql="select a.cod_paciente, a.fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.sexo, a.peso, a.talla, a.condicion, a.apgar as apgar1, a.apgar5 as apgar2, a.alumbramiento as alumbramiento, a.utero, a.consulta, a.observa_consulta as observConsulta, a.cavidad_uterina as cavidad, a.observa_cavidad as cavidU, a.cicatriz_ant as cicatriz, a.observa_cicatriz as cicatrizAnt, a.ruptura_uterina as ruptura, a.observa_ruptura as observRuptura, a.consulta_ruptura as conductaRuptura, a.observa_rup_uterina as obsvConducta, a.conducta as conductaCica, a.conducta_obsv as observaConducta, a.cuello, a.tratamiento_cuello as observCuello, a.vagina, a.tratamiento_vagina as observVagina, a.perine, tratamiento_perine as observPerine, a.recto, a.tratamiento_recto as observRect, a.medico as codMedico, a.alumbramiento_obsv as observ, a.pac_id, b.codigo, b.primer_nombre||' '||b.segundo_nombre||' '||DECODE(b.apellido_de_casada,NULL,b.primer_apellido||' '||b.segundo_apellido) AS nombre_medico,a.alumbramiento_min minutos from tbl_sal_historia_nacido a, tbl_adm_medico b where a.medico=b.codigo and a.pac_id="+pacId;
	cdo = SQLMgr.getData(sql);

		if (cdo == null)
		{
				if (!viewMode) modeSec = "add";
				cdo = new CommonDataObject();
				cdo.addColValue("FECHA",cDateTime.substring(0,10));
				cdo.addColValue("CODIGO","1");
		}
		else if (!viewMode) modeSec = "edit";

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - HISTORIA OBSTETRICA PARTE II '+document.title;
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_hist_obstetrica');}
function doAction(){newHeight();parent.setHeight('iSecciones',330);}
function imprimir(){abrir_ventana1('../expediente/print_hist_obstetrica2.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>" ></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr class="TextRow01">
		<td colspan="4" align="right"><a href="javascript:imprimir()" class="Link00">[ Imprimir ]</a></td>
	</tr>
	<tr>
		<td>
	<table align="center" width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td>
<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<table width="100%" cellpadding="1" cellspacing="1" >
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
    <%=fb.hidden("desc",desc)%>
	<%=fb.hidden("tab","0")%>
	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="1">Fecha</cellbytelabel></td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fecha" />
		<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
		</jsp:include></td>
		<td align="right"> <cellbytelabel id="2">M&eacute;dico</cellbytelabel></td>
		<td><%=fb.hidden("CODIGO",cdo.getColValue("CODIGO"))%>
		<%=fb.textBox("codMedico",cdo.getColValue("codMedico"),true,false,viewMode,5)%>
		<%=fb.textBox("nombre_medico",cdo.getColValue("nombre_medico"),false,false,true,25)%><%=fb.button("medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%></td>
	</tr>
	<tr class="TextHeader" >
		<td colspan="4"><cellbytelabel id="3">DATOS RECIEN NACIDO</cellbytelabel></td>
	</tr>
	<tr class="TextRow01">
		<td width="20%" align="right"><cellbytelabel id="4">Sexo</cellbytelabel></td>
		<td width="20%"><%=fb.select("sexo","M= Masculino, F = Femenino, I = Indefinido",cdo.getColValue("sexo"))%></td>
		<td width="15%" align="right"><cellbytelabel id="5">Peso</cellbytelabel></td>
		<td width="45%"><%=fb.textBox("peso",cdo.getColValue("peso"),false,false,viewMode,15,15,"Text10",null,null)%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="6">Talla</cellbytelabel></td>
		<td><%=fb.textBox("talla",cdo.getColValue("talla"),false,false,viewMode,5,10,"Text10",null,null)%></td>
		<td align="right"><cellbytelabel id="7">Apgar 1</cellbytelabel></td>
		<td><%=fb.textBox("apgar1",cdo.getColValue("apgar1"),false,false,viewMode,5,1)%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right">&nbsp;</td>
		<td>&nbsp;</td>
		<td align="right"><cellbytelabel id="8">Apgar 5</cellbytelabel></td>
		<td><%=fb.textBox("apgar2",cdo.getColValue("apgar2"),false,false,viewMode,5,1)%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="9">Condici&oacute;n al Nacer</cellbytelabel> </td>
		<td colspan="3"><%=fb.textarea("condicion",cdo.getColValue("condicion"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<!--<tr class="TextHeader" >
		<td colspan="4">ALUMBRAMIENTO</td>
	</tr>
	<tr class="TextRow01">
		<td colspan="2" align="center"><%//=fb.select("alumbramiento","ES = Espontáneo, AR = Artificial, ME = Maniobras Externas, EM = Extracción Manual de Anexos, CO = Completa",cdo.getColValue("alumbramiento"))%></td>
		<td colspan="2"><%//=fb.textarea("observ",cdo.getColValue("observ"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td colspan="4">Minutos para el Alumbramiento. &nbsp;&nbsp;&nbsp;&nbsp; <%//=fb.intBox("minutos",cdo.getColValue("minutos"),false,false,viewMode,5,3)%></td>
	</tr>-->
	<tr class="TextRow02">
		<td colspan="4" align="right">
				<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
		</td>
	</tr>
	<%fb.appendJsValidation("if(error>0)doAction();");%>
	<%=fb.formEnd(true)%>
	</table>
	<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","1")%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("modeSec",modeSec)%>
	<%=fb.hidden("seccion",seccion)%>
	<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
	<%=fb.hidden("dob","")%>
	<%=fb.hidden("codPac","")%>
	<%=fb.hidden("pacId",pacId)%>
	<%=fb.hidden("noAdmision",noAdmision)%>
	<%=fb.hidden("desc",desc)%>
	<tr class="TextRow02">
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr class="TextHeader">
		<td colspan="3"><cellbytelabel id="13">REVISION POST-PARTO</cellbytelabel></td>
	</tr>
	<tr class="TextRow01">
		<td width="25%" align="right"><cellbytelabel id="14">&Uacute;tero</cellbytelabel></td>
		<td width="25%"><%=fb.hidden("CODIGO",cdo.getColValue("CODIGO"))%><%=fb.select("utero","C = Bien Contraido, H = Hipotonico",cdo.getColValue("utero"))%></td>
		<td width="50%" rowspan="2"><cellbytelabel id="15">Describa</cellbytelabel><br>
		<%=fb.textarea("observConsulta",cdo.getColValue("observConsulta"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="16">Consulta [&Uacute;tero]</cellbytelabel></td>
		<td><%=fb.select("consulta","M = Médica, Q = Quirúrgica, O = Otras",cdo.getColValue("consulta"))%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="17">Cavidad Uterina</cellbytelabel></td>
		<td><%=fb.select("cavidad","LI= Limpia e Indemne, RP = Con restos Placentaros, RT = Removidos totalmente, MA = Manual, IN = Instrumental",cdo.getColValue("cavidad"))%></td>
		<td><cellbytelabel id="15">Describa</cellbytelabel><br>
		<%=fb.textarea("cavidU",cdo.getColValue("cavidU"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="18">Cicatriz Anterior</cellbytelabel></td>
		<td><%=fb.select("cicatriz","I = Indemne, D = Dehiscencia de cicatriz anterior, P = Parcial (No traspasa Miometrio), A = Amplia (Traspasa Miometrio)",cdo.getColValue("cicatriz"))%></td>
		<td><cellbytelabel id="15">Describa</cellbytelabel><br>
		<%=fb.textarea("cicatrizAnt",cdo.getColValue("cicatrizAnt"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<!--<tr class="TextRow01">
		<td align="right">Conducta</td>
		<td><%//=fb.select("conductaCica","M = Médica, Q = Quirúrgica",cdo.getColValue("conductaCica"))%></td>
		<td><cellbytelabel id="15">Describa</cellbytelabel><br>
		<%//=fb.textarea("observaConducta",cdo.getColValue("observaConducta"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>-->
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="19">Ruptura Uterina</cellbytelabel></td>
		<td><%=fb.select("ruptura","S = Si, N = No",cdo.getColValue("ruptura"))%></td>
		<td><cellbytelabel id="20">Observaci&oacute;n</cellbytelabel><br>
		<%=fb.textarea("observRuptura",cdo.getColValue("observRuptura"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="21">Conducta</cellbytelabel></td>
		<td><%=fb.select("conductaRuptura","M = Médica, Q = Quirúrgica, O = Otras",cdo.getColValue("conductaRuptura"))%></td>
		<td><cellbytelabel id="20">Observaci&oacute;n</cellbytelabel><br>
		<%=fb.textarea("obsvConducta",cdo.getColValue("obsvConducta"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="22">Cuello</cellbytelabel></td>
		<td><%=fb.select("cuello","I = Indemne, L = Lacerado",cdo.getColValue("cuello"))%></td>
		<td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
		<%=fb.textarea("observCuello",cdo.getColValue("observCuello"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="24">Vagina</cellbytelabel></td>
		<td><%=fb.select("vagina","I = Indemne, L = Lacerado",cdo.getColValue("vagina"))%></td>
		<td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
		<%=fb.textarea("observVagina",cdo.getColValue("observVagina"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="35">Perine</cellbytelabel></td>
		<td><%=fb.select("perine","I = Indemne, L = Lacerado",cdo.getColValue("perine"))%></td>
		<td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
		<%=fb.textarea("observPerine",cdo.getColValue("observPerine"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel id="26">Recto</cellbytelabel></td>
		<td><%=fb.select("recto","I = Indemne, L = Lacerado",cdo.getColValue("recto"))%></td>
		<td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
		<%=fb.textarea("observRect",cdo.getColValue("observRect"),false,false,viewMode,60,4,2000,"","width:100%","")%></td>
	</tr>

<tr class="TextRow02">
	<td colspan="4" align="right">
				<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
	<!-- TAB1 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>
<script type="text/javascript">
<%  String tabLabel = "'Datos Recien Nacido'";
	String tabLabel2 = "'Datos Recien Nacido','Revisi&oacute;n Post-Parto'";
if (modeSec.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
<%
}
else
{
%>
//initTabs(mainContainerID,tabTitles,activeTab,width,height,closeButtonArray,additionalTab)
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel2%>),<%=tab%>,'100%','');

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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

//if(tab.equals("0")) //Datos Reción Nacido
//	{
			cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_historia_nacido");
		if(request.getParameter("peso")!= null)
		cdo.addColValue("PESO",request.getParameter("peso"));
		if(request.getParameter("talla")!=null)
		cdo.addColValue("TALLA",request.getParameter("talla"));
		if(request.getParameter("condicion")!= null)
		cdo.addColValue("CONDICION",request.getParameter("condicion"));
		if(request.getParameter("apgar1")!=null)
		cdo.addColValue("APGAR",request.getParameter("apgar1"));
		if(request.getParameter("apgar2")!=null)
		cdo.addColValue("APGAR5",request.getParameter("apgar2"));
		
		//if (request.getParameter("alumbramiento") != null)
		//	cdo.addColValue("ALUMBRAMIENTO",request.getParameter("alumbramiento"));
		
		//if(request.getParameter("minutos")!= null)
		//cdo.addColValue("alumbramiento_min",request.getParameter("minutos"));
		
		//if(request.getParameter("observ")!=null)				
		//cdo.addColValue("ALUMBRAMIENTO_OBSV",request.getParameter("observ"));
		
		
		if (request.getParameter("utero") != null)
		 cdo.addColValue("UTERO",request.getParameter("utero"));
		if (request.getParameter("consulta") != null)
			cdo.addColValue("CONSULTA",request.getParameter("consulta"));
		 if (request.getParameter("observConsulta") != null)
	 cdo.addColValue("OBSERVA_CONSULTA",request.getParameter("observConsulta"));
	 if (request.getParameter("cavidad") != null)
	 cdo.addColValue("CAVIDAD_UTERINA",request.getParameter("cavidad"));
	 if (request.getParameter("cavidU") != null)
	 cdo.addColValue("OBSERVA_CAVIDAD",request.getParameter("cavidU"));
	 if (request.getParameter("cicatriz") != null)
	 cdo.addColValue("CICATRIZ_ANT",request.getParameter("cicatriz"));
	 if (request.getParameter("cicatrizAnt") != null)
	 cdo.addColValue("OBSERVA_CICATRIZ",request.getParameter("cicatrizAnt"));
	 if (request.getParameter("ruptura") != null)
	 cdo.addColValue("RUPTURA_UTERINA",request.getParameter("ruptura"));
	 if(request.getParameter("observRuptura")!=null)
	 cdo.addColValue("OBSERVA_RUPTURA",request.getParameter("observRuptura"));
	 if(request.getParameter("conductaRuptura")!= null)
	 cdo.addColValue("CONSULTA_RUPTURA",request.getParameter("conductaRuptura"));
	 if(request.getParameter("obsvConducta")!=null)
	 cdo.addColValue("OBSERVA_RUP_UTERINA",request.getParameter("obsvConducta"));
	 if(request.getParameter("cuello")!=null)
	 cdo.addColValue("CUELLO",request.getParameter("cuello"));
	 if(request.getParameter("observCuello") != null)
	 cdo.addColValue("TRATAMIENTO_CUELLO",request.getParameter("observCuello"));
	 if(request.getParameter("vagina")!=null)
		 cdo.addColValue("VAGINA",request.getParameter("vagina"));
	 if(request.getParameter("observVagina")!= null)
		 cdo.addColValue("TRATAMIENTO_VAGINA",request.getParameter("observVagina"));
	 if(request.getParameter("perine")!= null)
	 cdo.addColValue("PERINE",request.getParameter("perine"));
	 if(request.getParameter("observPerine")!=null)
	 cdo.addColValue("TRATAMIENTO_PERINE",request.getParameter("observPerine"));
	 if(request.getParameter("recto")!=null)
	 cdo.addColValue("RECTO",request.getParameter("recto"));
	 if(request.getParameter("observRect")!=null)
	 cdo.addColValue("TRATAMIENTO_RECTO",request.getParameter("observRect"));
	 if(request.getParameter("codMedico")!=null)
	 cdo.addColValue("MEDICO",request.getParameter("codMedico"));
	 if(request.getParameter("conductaCica")!=null)
	 cdo.addColValue("CONDUCTA",request.getParameter("conductaCica"));
	 if(request.getParameter("observaConducta")!=null)
	 cdo.addColValue("CONDUCTA_OBSV",request.getParameter("observaConducta"));
 	 cdo.addColValue("fecha_modificacion",cDateTime);
	 cdo.addColValue("usuario_modificacion",((String) session.getAttribute("_userName")).trim());
	 
	 
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
			{
					cdo.addColValue("CODIGO","(SELECT nvl(max(CODIGO),0)+1 FROM tbl_sal_historia_nacido)");
					cdo.setAutoIncCol("CODIGO");
					cdo.addColValue("PAC_ID",request.getParameter("pacId"));
					cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
					cdo.addColValue("FEC_NACIMIENTO",request.getParameter("dob"));
					cdo.addColValue("FECHA",request.getParameter("fecha"));
					//System.out.println("\n\n FECHA="+request.getParameter("fecha"));
					cdo.addColValue("SEXO",request.getParameter("sexo"));
					
					cdo.addColValue("fecha_creacion",cDateTime);
					cdo.addColValue("usuario_creacion",((String) session.getAttribute("_userName")).trim());
	 
					SQLMgr.insert(cdo);
			}
			else if (modeSec.equalsIgnoreCase("edit"))
			{
				 cdo.setWhereClause("pac_id="+request.getParameter("pacId"));

				 SQLMgr.update(cdo);
			}
			ConMgr.clearAppCtx(null);
	//}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tab=<%=tab%>&desc=<%=desc%>';

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
