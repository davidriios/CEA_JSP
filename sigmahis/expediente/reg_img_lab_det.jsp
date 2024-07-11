<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="ELMgr" scope="page" class="issi.expediente.ExamenesLabMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htCPT" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCPTKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htOM" scope="page" class="java.util.Hashtable" />
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
ELMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String area = request.getParameter("area");
boolean viewMode = false;

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htCPT.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){
	<%
	if(type!=null && type.equals("1")){
	%>
	var fp				= document.form1.fp.value;
	var fg				= document.form1.fg.value;
	var fechaNac	= parent.document.paciente.fechaNacimiento.value;
	var admSec		= parent.document.paciente.admSecuencia.value;
	var codPac		= parent.document.paciente.codigoPaciente.value;
	var pac_id		= parent.document.paciente.pacienteId.value;
	var area			= parent.document.form0.area.value;

	abrir_ventana1('../common/sel_procedimiento.jsp?mode=<%=mode%>&fg='+fg+'&fp='+fp+'&cs='+area+'&admision='+admSec+'&pac_id='+pac_id);
	<%
	}
	%>
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	parent.document.form0.baction.value = valor;
	parent.document.form0.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.form1.baction.value 						= parent.document.form0.baction.value;
	document.form1.clearHT.value 						= parent.document.form0.clearHT.value;
	document.form1.area.value 							= parent.document.form0.area.value;
	document.form1.fechaNacimiento.value		= parent.document.paciente.fechaNacimiento.value;
	document.form1.codigoPaciente.value 		= parent.document.paciente.codigoPaciente.value;
	document.form1.pacienteId.value 				= parent.document.paciente.pacienteId.value;
	document.form1.admSecuencia.value 			= parent.document.paciente.admSecuencia.value;
	document.form1.medico.value 						= parent.document.form0.medico.value;
	var pac_id = document.form1.pacienteId.value;
	var admision = document.form1.admSecuencia.value;
	if (!parent.pacienteValidation() || !parent.form0Validation() || !form1Validation()){
		//return false;
	} else{
		//return true;
		if (document.form1.baction.value != 'Guardar')parent.form0BlockButtons(false);
		if (document.form1.baction.value == 'Guardar' && verCodSala(pac_id, admision)/* && verComentarios()*/) document.form1.submit();
		if (document.form1.baction.value == 'Agregar Procedimientos') document.form1.submit();
	}

}

function verCodSala(pac_id, admision){
	var colNames = "";
	var colValues = "";
	var cod_sala = getDBData('<%=request.getContextPath()%>','getCodSala('+pac_id+','+admision+') cod_sala','dual','','');
	if(cod_sala =='-1'){
		alert('El paciente tiene asignado más de una cama');
		document.form1.cod_sala.value = "";
		return false;
	} else {
		document.form1.cod_sala.value = cod_sala;
		return true;
	}
}

function calMonto(j, k){
}

function verComentarios(){
	var size = parseInt(<%=htCPT.size()%>);
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form1.comentario'+i).value==''){
			x++;
			break
		}
	}
	if(x>0){
		alert('Introduzca Comentarios!');
		parent.form0BlockButtons(false);
		return false;
	} else return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+htCPT.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fechaNacimiento","")%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("pacienteId","")%>
<%=fb.hidden("admSecuencia","")%>

<%=fb.hidden("medico","")%>
<%=fb.hidden("nombreMedico","")%>

<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>

<%=fb.hidden("area","")%>
<%=fb.hidden("cod_sala","")%>
<%
String colspan = "4";
%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="<%=colspan%>" align="right">
	<%=fb.button("addProcedimientos", "Agregar Procedimientos", false, viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
	</td>
</tr>
<tr class="TextHeader" align="center">
	<td width="30%"><cellbytelabel id="1">&Aacute;rea</cellbytelabel></td>
	<td width="20%"><cellbytelabel id="2">CPT</cellbytelabel></td>
	<td width="47%"><cellbytelabel id="3">Descripci&oacute;n del Estudio</cellbytelabel></td>
	<td width="3%"></td>
</tr>
<%
if (htCPT.size() > 0) al = CmnMgr.reverseRecords(htCPT);
int sizeCS = 0;
String codCS = "";
for (int i=0; i<htCPT.size(); i++)
{
	key = al.get(i).toString();

	DetalleOrdenMed dom = (DetalleOrdenMed) htCPT.get(key);
	if(!dom.getCentroServicio().equals(codCS)){
		sizeCS++;
		codCS = dom.getCentroServicio();
	}
	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
	<%=fb.hidden("centro_servicio"+i,dom.getCentroServicio())%>
	<%=fb.hidden("centro_servicio_desc"+i,dom.getCentroServicioDesc())%>
	<%=fb.hidden("procedimiento"+i,dom.getProcedimiento())%>
	<%=fb.hidden("nombre_procedimiento"+i,dom.getNombreProcedimiento())%>
<tr class="<%=color%>" align="center">
	<td><%=fb.textBox("tipo_servicio"+i,dom.getCentroServicio()+" - "+ dom.getCentroServicioDesc(),false,false,true,40)%></td>
	<td><%=fb.textBox("trabajo"+i,dom.getProcedimiento(),false,false,true,10)%></td>
	<td><%=fb.textBox("descripcion"+i,dom.getNombreProcedimiento(),false,false,true,65)%></td>
	<td align="center" rowspan="2"><%=fb.submit("del"+i,"x",false,viewMode, "", "", "onClick = \"javascript:document.form1.baction.value='deleting';\"")%></td>
</tr>
<tr class="<%=color%>" align="center">
	<td colspan="3"><cellbytelabel id="4">Comentarios</cellbytelabel>:<%=fb.textarea("comentario"+i,dom.getObservacion(),false,false,false,100,2, 2000)%></td>
</tr>
	<%
}
%>
<%=fb.hidden("keySize",""+htCPT.size())%>
<%=fb.hidden("sizeCS",""+sizeCS)%>
</table>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	//System.out.println("-----------------------------------------------------");

	String dl = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");

	int size = 0;
	htCPT.clear();
	int lineNo = 0;

	OrdenMedica orm = new OrdenMedica();
	orm.setSecuencia(request.getParameter("admSecuencia"));
	orm.setFecNacimiento(request.getParameter("fechaNacimiento"));
	orm.setCodPaciente(request.getParameter("codigoPaciente"));
	orm.setPacId(request.getParameter("pacienteId"));
	orm.setMedico(request.getParameter("medico"));
	orm.setCentroServicio(request.getParameter("area"));
	orm.setTipoSolicitud("I"); // Q D P
	orm.setOrigen("S");
	orm.setTelefonica("N");
	orm.setEstado("S");
	orm.setUsuarioModif((String) session.getAttribute("_userName"));
	orm.setUsuarioCreacion((String) session.getAttribute("_userName"));
	orm.setFg("reg_img_lab");

	if(request.getParameter("cod_sala")!=null && !request.getParameter("cod_sala").equals("")) orm.setCodSala(request.getParameter("cod_sala"));

	htOM.put(""+size,orm);

	for (int i=0; i<keySize; i++){
		DetalleOrdenMed det = new DetalleOrdenMed();

		det.setProcedimiento(request.getParameter("procedimiento"+i));
		det.setNombreProcedimiento(request.getParameter("nombre_procedimiento"+i));
		det.setCentroServicio(request.getParameter("centro_servicio"+i));
		det.setCentroServicioDesc(request.getParameter("centro_servicio_desc"+i));
		det.setObservacion(request.getParameter("comentario"+i));
		det.setPrioridad("H");
		det.setEjecutado("N");
		det.setTipoOrden("1");
		det.setExtraerMuestra("N");
		det.setExpediente("S");
		det.setEstudioDev("N");
		det.setEstado("S");
		det.setTipoSolicit("P");

		if(i>0 && !det.getCentroServicio().equals(orm.getCentroServicio())){
			orm = new OrdenMedica();
			size++;
			orm.setSecuencia(request.getParameter("admSecuencia"));
			orm.setFecNacimiento(request.getParameter("fechaNacimiento"));
			orm.setCodPaciente(request.getParameter("codigoPaciente"));
			orm.setPacId(request.getParameter("pacienteId"));
			orm.setMedico(request.getParameter("medico"));
			orm.setTipoSolicitud("I"); // Q D P
			orm.setOrigen("S");
			orm.setTelefonica("N");
			orm.setEstado("S");
			orm.setUsuarioModif((String) session.getAttribute("_userName"));
			orm.setUsuarioCreacion((String) session.getAttribute("_userName"));
			orm.setFg("reg_img_lab");
			orm.setCentroServicio(det.getCentroServicio());
			if(request.getParameter("cod_sala")!=null && !request.getParameter("cod_sala").equals("")) orm.setCodSala(request.getParameter("cod_sala"));
			htOM.put(""+size,orm);
		}

		//System.out.println("del..."+i+"="+request.getParameter("del"+i));
		if(request.getParameter("del"+i)==null){

			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try {
				htCPT.put(key, det);
				htCPTKey.put(det.getProcedimiento()+"_"+det.getCentroServicio(), key);
				orm.getDetalleOrdenMed().add(det);
				//System.out.println("adding item ... "+key);
			}	catch (Exception e)	{
				//System.out.println("Unable to addget item "+key);
			}

		} else dl = "1";
	}


	//System.out.println("clearHT="+clearHT);
	if(!dl.equals("") || clearHT.equals("S") || (request.getParameter("addx")!=null && request.getParameter("addx").equals("+"))){
		response.sendRedirect("../expediente/reg_img_lab_det.jsp?mode="+mode+ "&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}


	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Agregar Procedimientos")){
		response.sendRedirect("../expediente/reg_img_lab_det.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp);
		return;
	}


	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ELMgr.addOrden(htOM);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if(ELMgr.getErrCode().equals("1")){%>
	parent.document.form0.errCode.value = <%=ELMgr.getErrCode()%>;
	parent.document.form0.errMsg.value = '<%=ELMgr.getErrMsg()%>';
	parent.document.form0.submit();
<%} else throw new Exception(ELMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
