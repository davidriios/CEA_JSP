<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Cama"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htCama" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htCamaKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htOM" scope="page" class="java.util.Hashtable"/>
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
AdmMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
boolean viewMode = false;
String usosAutCamas= "N";
try {usosAutCamas =java.util.ResourceBundle.getBundle("issi").getString("auto.cama.uso");}catch(Exception e){ usosAutCamas = "N";}

if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	//if (mode.equalsIgnoreCase("add") && change == null) htCama.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	chkCamasSinFechaFinal();
}

function chkCamasSinFechaFinal(){
	var camas = document.form1.contCama.value;
	if(camas>1){
		top.CBMSG.warning('Existe más de una cama sin fecha de salida!');
		parent.document.form0.save.disabled = true;
	}
}

function _doSubmit(valor){
	parent.document.form0.baction.value = valor;
	parent.document.form0.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.form1.baction.value 						= parent.document.form0.baction.value;
	document.form1.clearHT.value 						= parent.document.form0.clearHT.value;
	document.form1.fechaNacimiento.value		= parent.document.paciente.fechaNacimiento.value;
	document.form1.codigoPaciente.value 		= parent.document.paciente.codigoPaciente.value;
	document.form1.pacienteId.value 				= parent.document.paciente.pacienteId.value;
	document.form1.admSecuencia.value 			= parent.document.paciente.admSecuencia.value;
	document.form1.nombrePaciente.value 		= parent.document.paciente.nombrePaciente.value;
	document.form1.pasaporte.value 					= parent.document.paciente.pasaporte.value;
	document.form1.empresa.value 						= parent.document.paciente.empresa.value;
	document.form1.nombre_empresa.value 		= parent.document.paciente.empresaNombre.value;
	var pac_id = document.form1.pacienteId.value;
	var admision = document.form1.admSecuencia.value;
	if (!parent.pacienteValidation() || !parent.form0Validation() || !form1Validation()){
		parent.form0BlockButtons(false);
		newHeight();
	} else{
		if (document.form1.baction.value != 'Guardar') parent.form0BlockButtons(false);
		document.form1.submit();
	}
}

function setFHFinal(i){
	var fecha = "", hora = "";

	var fh = getDBData('<%=request.getContextPath()%>','to_char(sysdate,\'dd/mm/yyyy\') fecha_final, to_char(sysdate,\'HH12:mi AM\') hora_final','dual','','');
	var data = splitCols(fh);
	fecha = data[0];

	hora = data[1];
	eval('document.form1.fecha_final'+i).value = fecha;
	eval('document.form1.hora_final'+i).value = hora;
}

function selCama(i){avisarCAUT();abrir_ventana('../common/sel_hab_cama.jsp?fp=reasignar_cama&fg=reasignar_cama&index='+i);}
function avisarCAUT(){
<%if(usosAutCamas.trim().equals("S")){%>
	var totCamas = "<%=htCama.size()%>";
	var tot = 0;
	for (var i = 0; i<totCamas; i++){
		var cama = document.getElementById("cama"+i).value;
		var hab = document.getElementById("habitacion"+i).value;
		if (cama!="" && hab!=""){
		tot +=  parseInt(getDBData('<%=request.getContextPath()%>','count(*) tot ','tbl_sal_cargos_automaticos','cama = \''+cama+'\' and habitacion = \''+hab+'\' and estado=\'A\'',''));
	}
	}
 if (tot > 0){ top.CBMSG.warning("La cama asignada a esté paciente tiene configurada "+tot+" cargo"+(tot > 1?"s":"")+" automático"+(tot > 1?"s \n- Revise que los cargos configurado se le han cargado al paciente, de lo Contrario debe generarlos manualmente":""));}
  <%}%>
}
function ctrlObsPrecioAlt(index){
	var rowObj = document.getElementById("obsPrecioAltRow"+index);
	var obsPrecioAlt = document.getElementById("obsPrecioAlt"+index);

	if (eval('document.form1.precioAlt'+index).checked ) {
		obsPrecioAlt.className = 'FormDataObjectEnabled';
		obsPrecioAlt.disabled = false;
		rowObj.style.display = '';
	}else{
		obsPrecioAlt.className = 'FormDataObjectDisabled';
		obsPrecioAlt.disabled = true;
		rowObj.style.display = 'none';
	}

}
function usePrecioAlterno(k)
{
	if (eval('document.form1.precioAlt'+k).checked)
	{
		eval('document.form1.precio_alterno'+k).disabled = false;
		eval('document.form1.precio_alterno'+k).className = 'FormDataObjectEnabled';
	}
	else
	{
		eval('document.form1.precio_alterno'+k).disabled = true;
		eval('document.form1.precio_alterno'+k).className = 'FormDataObjectDisabled';
	}
	ctrlObsPrecioAlt(k);
}

function useOtherPrice()
{
	var camaSize=parseInt(document.form1.size.value,10);
	if(camaSize>1){
		for(i=1;i<=camaSize;i++)
		{
			if(eval('document.form1.precioAlt'+i).checked&&(eval('document.form1.precio_alterno'+i).value.trim()=='' || eval('document.form1.obsPrecioAlt'+i).value.trim()=='') )
			{
				top.CBMSG.warning('Usted ha marcado el Precio Alterno, por lo tanto debe introducir el monto del Precio Alterno y el motivo!');
				return false;
			}
		}
	}
	if(eval('document.form1.precioAlt').checked&&(eval('document.form1.precio_alterno').value.trim()=='' || eval('document.form1.obsPrecioAlt').value.trim()=='') )
	{
		top.CBMSG.warning('Usted ha marcado el Precio Alterno, por lo tanto debe introducir el monto del Precio Alterno y el motivo!');
		return false;
	}
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+htCama.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fechaNacimiento","")%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("pacienteId","")%>
<%=fb.hidden("admSecuencia","")%>
<%=fb.hidden("nombrePaciente","")%>
<%=fb.hidden("pasaporte","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("empresa","")%>
<%=fb.hidden("nombre_empresa","")%>
<%fb.appendJsValidation("if(document.form1.baction.value=='Guardar'&&!useOtherPrice())error++;");%>
<%fb.appendJsValidation("if(document.form1.hora_final0.value!='' && !isValidateDate(document.form1.hora_final0.value,'hh12:mi am')){top.CBMSG.warning('Formato de Hora inválida. Para Hora  hh12:mi am !');error++;}");%>
<%fb.appendJsValidation("if((document.form1.fecha_final0.value!='' && !isValidateDate(document.form1.fecha_final0.value,'dd/mm/yyyy'))){top.CBMSG.warning('Formato de fecha inválida. Para Fecha dd/mm/yyyy  !');error++;}");%>

<%
String colspan = "9";
%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td width="10%">Cama</td>
	<td width="10%">Habitaci&oacute;n</td>
	<td width="35%">Sala</td>
	<td width="15%" colspan="2">Fecha de Entrada</td>
	<td width="15%" colspan="2">Fecha de Salida</td>
	<td width="3%">&nbsp;</td>
	<td width="12%">Precio Alterno</td>
</tr>
<%
if (htCama.size() > 0) al = CmnMgr.reverseRecords(htCama);
int contCama = 0;
for (int i=0; i<htCama.size(); i++)
{
	key = al.get(i).toString();

	CommonDataObject cdo = (CommonDataObject) htCama.get(key);
	if(cdo.getColValue("fecha_final")== null || cdo.getColValue("fecha_final").equals("")) contCama++;
	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
	<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
	<%=fb.hidden("cod_sala"+i,cdo.getColValue("cod_sala"))%>
	<%=fb.hidden("desc_sala"+i,cdo.getColValue("desc_sala"))%>
	<%=fb.hidden("fecha_inicio"+i,cdo.getColValue("fecha_inicio"))%>
	<%=fb.hidden("hora_inicio"+i,cdo.getColValue("hora_inicio"))%>
	<%//=fb.hidden(""+i,cdo.getDataValue(""))%>
<tr class="<%=color%>" align="center">
	<td><%=cdo.getColValue("cama")%></td>
	<td><%=cdo.getColValue("habitacion")%></td>
	<td><%=cdo.getColValue("cod_sala")%>&nbsp;<%=cdo.getColValue("desc_sala")%></td>
	<td><%=cdo.getColValue("fecha_inicio")%></td>
	<td><%=cdo.getColValue("hora_inicio")%></td>
	<td><%=fb.textBox("fecha_final"+i,cdo.getColValue("fecha_final"),(cdo.getColValue("fecha_final").equals("")?true:false),false,false,10)%></td>
	<td><%=fb.textBox("hora_final"+i,cdo.getColValue("hora_final"),(cdo.getColValue("fecha_final").equals("")?true:false),false,false,6)%></td>
	<td align="center">&nbsp;
	<%
	if(cdo.getColValue("fecha_final").equals("") && cdo.getColValue("hora_final").equals("")){
	%>
	<%=fb.button("set"+i,".",false,viewMode,null,null,"onClick=\"javascript:setFHFinal("+i+")\"")%>
	<%
	}
	%>
	</td>
	<td>&nbsp;
	<%
	if(cdo.getColValue("fecha_final").equals("") && cdo.getColValue("hora_final").equals("")){
	%>
	<%=fb.checkbox("precioAlt"+i,"S",(cdo.getColValue("precio_alt") != null && cdo.getColValue("precio_alt").equalsIgnoreCase("S")),false,null,null,"onClick=\"javascript:usePrecioAlterno("+i+")\"","Utilizar Precio Alterno")%>


	<%=fb.decBox("precio_alterno"+i,cdo.getColValue("precio_alterno"),false,(cdo.getColValue("precio_alt")!=null&&!cdo.getColValue("precio_alt").equalsIgnoreCase("S")),false,10, 8.2)%>
	<%
	}
	%>
	</td>
</tr>
<tr class="TextRow01" id="obsPrecioAltRow<%=i%>">
				<td colspan="2">Motivo del precio alternativo</td>
				<td colspan="7"><%=fb.textarea("obsPrecioAlt"+i,cdo.getColValue("motivo_precio_alt"),false,!(cdo.getColValue("precio_alt") != null && cdo.getColValue("precio_alt").equalsIgnoreCase("S")),viewMode,80,2,200)%>
				</td>
			</tr>
	<%
}
String color = "";

if (htCama.size()%2 == 0) color = "TextRow02";
else color = "TextRow01";
%>
<tr class="<%=color%>" align="center">
	<td><%=fb.textBox("cama","",true,false,true,10)%></td>
	<td><%=fb.textBox("habitacion","",true,false,true,10)%></td>
	<td><%=fb.textBox("cod_sala","",true,false,true,10)%><%=fb.textBox("desc_sala","",true,false,true,45)%></td>
	<td><%=fb.textBox("fecha_inicio","",false,false,true,10)%></td>
	<td><%=fb.textBox("hora_inicio","",false,false,true,10)%></td>
	
	<td><%=fb.textBox("fecha_final","",false,false,true,10)%></td>
	<td><%=fb.textBox("hora_final","",false,false,true,10)%></td>
	
	
	<td align="center"><%=fb.button("sel","...",false,viewMode,null,null,"onClick=\"javascript:selCama()\"")%></td>
	<td><%=fb.checkbox("precioAlt","S",false,false,null,null,"onClick=\"javascript:usePrecioAlterno('')\"","Utilizar Precio Alterno")%>
	<%=fb.decBox("precio_alterno","",false,true,false,10, 8.2)%></td>
</tr>
<tr class="TextRow01" id="obsPrecioAltRow">
		<td colspan="2">Motivo del precio alternativo</td>
		<td colspan="7"><%=fb.textarea("obsPrecioAlt","",false,true,viewMode,80,2,200)%>
		</td>
</tr>

<%=fb.hidden("keySize",""+htCama.size())%>
<%=fb.hidden("contCama",""+contCama)%>
</table>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	System.out.println("-----------------------------------------------------");

	int keySize = Integer.parseInt(request.getParameter("keySize"));

	ArrayList alCamas = new ArrayList();
	System.out.println("keySize="+keySize);
	Cama det = new Cama();
	for (int i=0; i<keySize; i++){
		det = new Cama();
		det.setFechaNacimiento(request.getParameter("fechaNacimiento"));
		det.setPacCodigo(request.getParameter("codigoPaciente"));
		det.setPacId(request.getParameter("pacienteId"));
		det.setOther1(request.getParameter("nombrePaciente"));
		det.setOther2(request.getParameter("pasaporte"));
		det.setOther3(request.getParameter("empresa"));
		det.setOther4(request.getParameter("nombre_empresa"));
		det.setOther5("REASIGNAR_CAMA");
		det.setAdmision(request.getParameter("admSecuencia"));
		det.setUserCrea((String) session.getAttribute("_userName"));
		det.setUserMod((String) session.getAttribute("_userName"));
		det.setCompania((String) session.getAttribute("_companyId"));

		det.setCodigo(request.getParameter("codigo"+i));
		det.setCama(request.getParameter("cama"+i));
		det.setHabitacion(request.getParameter("habitacion"+i));
		det.setCodSala(request.getParameter("cod_sala"+i));
		det.setDescSala(request.getParameter("desc_sala"+i));
		det.setFechaFinal(request.getParameter("fecha_final"+i));
		det.setHoraFinal(request.getParameter("hora_final"+i));
		if (request.getParameter("precioAlt"+i) != null && request.getParameter("precioAlt"+i).equalsIgnoreCase("S"))
		{
			det.setPrecioAlt("S");
			det.setPrecioAlterno(request.getParameter("precio_alterno"+i));

			det.setMotivoPrecioAlt(request.getParameter("obsPrecioAlt"+i));
		}
		else
		{
			det.setPrecioAlt("N");
			det.setPrecioAlterno("");
		}
		alCamas.add(det);
	}

	det = new Cama();
	det.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	det.setPacCodigo(request.getParameter("codigoPaciente"));
	det.setPacId(request.getParameter("pacienteId"));
	det.setAdmision(request.getParameter("admSecuencia"));
	det.setUserCrea((String) session.getAttribute("_userName"));
	det.setUserMod((String) session.getAttribute("_userName"));
	det.setCompania((String) session.getAttribute("_companyId"));

	det.setCodigo(request.getParameter("codigo"));
	det.setCama(request.getParameter("cama"));
	det.setHabitacion(request.getParameter("habitacion"));
	det.setCodSala(request.getParameter("cod_sala"));
	det.setDescSala(request.getParameter("desc_sala"));
	det.setFechaFinal(request.getParameter("fecha_final"));
	det.setHoraFinal(request.getParameter("hora_final"));

	if (request.getParameter("precioAlt") != null && request.getParameter("precioAlt").equalsIgnoreCase("S"))
	{
		det.setPrecioAlt("S");
		det.setPrecioAlterno(request.getParameter("precio_alterno"));

		det.setMotivoPrecioAlt(request.getParameter("obsPrecioAlt"));
	}
	else
	{
		det.setPrecioAlt("N");
		det.setPrecioAlterno("");
	}
	det.setOther1(request.getParameter("nombrePaciente"));
	det.setOther2(request.getParameter("pasaporte"));
	det.setOther3(request.getParameter("empresa"));
	det.setOther4(request.getParameter("nombre_empresa"));
	det.setOther5("REASIGNAR_CAMA");

	alCamas.add(det);


	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.reasignarCama(alCamas);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	parent.document.form0.errCode.value = <%=AdmMgr.getErrCode()%>;
	parent.document.form0.errMsg.value = '<%=AdmMgr.getErrMsg()%>';
	parent.document.form0.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>