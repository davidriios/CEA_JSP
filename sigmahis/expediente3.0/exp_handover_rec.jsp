<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
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
<jsp:useBean id="THMgr" scope="page" class="issi.expediente.TrasladoHandover" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
THMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
Properties prop = new Properties();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String code = request.getParameter("code");
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String compania = (String) session.getAttribute("_companyId");
String fp = request.getParameter("fp");

if (estado == null) estado = "";
if (code == null) code = "0";
if (cds == null) cds = "-9";
if (fg == null) fg = "SAD";
if (fp == null) fp = "REC";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

CommonDataObject cdoSV = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (!code.trim().equals("0")) {
			prop = SQLMgr.getDataProperties("select params from tbl_sal_traslado_handover where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code);

			if (prop == null) {
				prop = new Properties();
			} else {
				if(!viewMode) modeSec = "edit";
			}

		}  
 
		session.setAttribute("_prop", prop);
		session.setAttribute("_SQLMgr", SQLMgr);

	 boolean isComplete = false;
	 
	 if(fp.trim().equals("REC")) isComplete = prop != null && !"".equals(prop.getProperty("persona_que_recibe_nombre"));
	 else if(fp.trim().equals("REC2")) isComplete = prop != null && !"".equals(prop.getProperty("persona_que_rep"));
     else isComplete = prop != null && !"".equals(prop.getProperty("persona_rec"));
	 
	 if (!isComplete && !modeSec.equalsIgnoreCase("add")) {
	 
			 if(fp.trim().equals("REC")){prop.setProperty("persona_que_recibe_nombre", UserDet.getName());prop.setProperty("fecha_rec", cDateTime.substring(0,10));}
			 else if(fp.trim().equals("REC2"))prop.setProperty("persona_que_rep", UserDet.getName());
			 else prop.setProperty("persona_rec", UserDet.getName());
	 }

	 //if (estado.equalsIgnoreCase("F")) isComplete = true;

	 System.out.println(":::::::::::::::::::::::::::::::::::::::::: isComplete = "+isComplete);

%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
var noNewHeight = true;

function cdsList(option) {
 var fg = 'recibe';
 abrir_ventana1('../common/search_centro_servicio.jsp?fp=handover&fg=<%=fp%>');
}
function canSubmit() {
	var proceed = true; 
	return proceed;
}
function shouldTypeRadio(check, textareaIndex) {
	if (check == true) $("#obser_"+textareaIndex).prop("readOnly", false)
	else $("#obser_"+textareaIndex).val("").prop("readOnly", true)
}
function shouldTypeRadioList(check, textareaIndex) {
	if (check == true) $("#obser_"+textareaIndex).prop("readOnly", false)
	else $("#obser_"+textareaIndex).val("").prop("readOnly", true)
}   
function empleadoList(opt){ 
		abrir_ventana1('../common/search_empleado.jsp?fp=handover&fg=<%=fp%>&index=');
}
</script> 
</head>
<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form01",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>  
<%//fb.appendJsValidation("if(!canSubmit()) { error++; }");%>  
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("code", code)%>
<%=fb.hidden("estado", estado)%>

		 
						<% 
Vector vCampos=new Vector();

if(fp.trim().equals("REC")){
vCampos.addElement("persona_que_recibe_nombre");
vCampos.addElement("persona_que_recibe");
vCampos.addElement("centro_servicio_recibe");
vCampos.addElement("centro_servicio_recibe_desc");
vCampos.addElement("comentario_rec1"); 
vCampos.addElement("fecha_rec"); 

}else{

vCampos.addElement("fecha_regreso");
vCampos.addElement("persona_que_rep");
vCampos.addElement("persona_rec");
vCampos.addElement("rec2_1");
vCampos.addElement("obser_1"); 
vCampos.addElement("rec2_2"); 
vCampos.addElement("obser_2"); 
vCampos.addElement("obser_3"); 
vCampos.addElement("obser_4"); 
vCampos.addElement("condicion_0"); 
vCampos.addElement("condicion_1"); 
vCampos.addElement("condicion_2"); 
vCampos.addElement("condicion_3"); 
vCampos.addElement("condicion_4"); 
vCampos.addElement("condicion_5"); 
vCampos.addElement("condicion_6"); 
vCampos.addElement("rec3_1"); 
vCampos.addElement("condicion2_0");
vCampos.addElement("condicion2_1"); 
vCampos.addElement("condicion2_2"); 
vCampos.addElement("condicion2_3"); 
vCampos.addElement("condicion2_4"); 
vCampos.addElement("persona_que_rep_id"); 

}

						
for (java.util.Enumeration e = prop.propertyNames(); e.hasMoreElements();) {
String campo = (String)e.nextElement();
 
if(!vCampos.contains(campo)){
		 %> 
		 <%=fb.hidden(""+campo,""+prop.getProperty(campo))%> 		 
	<%} }%>
						  

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr class="pointer" id="ss">
				<td style="background-color: YELLOW !important"><b>SERVICIO DE APOYO</b></td>
		</tr>
		<%if(fp.trim().equals("REC")){%>
		
		<tr class="ss">
				<td class="controls form-inline">
						<b>Fecha:</b>
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_rec" />
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
								<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_rec")%>" />
								<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
						</jsp:include>
						 
				</td>
		</tr>		
		<tr class="ss">
				<td class="controls form-inline">
						<b>Persona que recibe el reporte:</b>&nbsp;<%=fb.textBox("persona_que_recibe_nombre", prop.getProperty("persona_que_recibe_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						<%=fb.hidden("persona_que_recibe","")%>
						<%=fb.button("btn_quien_recibe","...",true,(isComplete||viewMode),null,null,"onClick=\"javascript:empleadoList(1)\"","seleccionar empleados")%>

						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<b>&Aacute;rea:</b>&nbsp;<%=fb.textBox("centro_servicio_recibe_desc", prop.getProperty("centro_servicio_recibe_desc"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						<%=fb.hidden("centro_servicio_recibe","")%>
						<%=fb.button("btn_cds_recibe","...",true,(isComplete||viewMode),null,null,"onClick=\"javascript:cdsList(2)\"","seleccionar centros")%>
				</td>
		</tr>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Comentario:</b>&nbsp;
						&nbsp;&nbsp;&nbsp;&nbsp;
						&nbsp;<%=fb.textBox("comentario_rec1", prop.getProperty("comentario_rec1"),false,false,(isComplete||viewMode),30,"form-control input-sm","display:inline; width:300px",null)%>
				</td>
		</tr>
		
		<%}if(fp.trim().equals("REC2")){%>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Fecha:</b>
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_regreso" />
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
								<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_regreso")%>" />
								<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
						</jsp:include>
						 
				</td>
		</tr>

		<tr class="ss">
				<td class="controls form-inline">
						<b>Persona que reporta:</b>&nbsp;<%=fb.textBox("persona_que_rep", prop.getProperty("persona_que_rep"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						 <%=fb.hidden("persona_que_rep_id", prop.getProperty("persona_que_rep_id"))%>
						 <%=fb.button("btn_quien_rec","...",true,(isComplete||viewMode),null,null,"onClick=\"javascript:empleadoList(3)\"","seleccionar empleados")%>
				</td>
		</tr>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Persona que recibe el reporte:</b>&nbsp;<%=fb.textBox("persona_rec", prop.getProperty("persona_rec"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%> 
						<%//=fb.button("btn_quien_rec","...",true,(isComplete||viewMode),null,null,"onClick=\"javascript:empleadoList(3)\"","seleccionar empleados")%>

						 
				</td>
		</tr>
		
		<tr class="ss">
				<td class="controls form-inline">
						<b>Se realizó el procedimiento/tratamiento:</b>&nbsp;
						<label class="pointer"><%=fb.radio("rec2_1","0",(prop.getProperty("rec2_1")!=null && prop.getProperty("rec2_1").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 1)'")%>&nbsp;SI</label>
						&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.radio("rec2_1","1",(prop.getProperty("rec2_1")!=null && prop.getProperty("rec2_1").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(true, 1)'","","")%>&nbsp;NO</label>

						&nbsp;&nbsp;&nbsp;&nbsp;
						(Observacion):&nbsp;<%=fb.textBox("obser_1", prop.getProperty("obser_1"),false,false,viewMode||prop.getProperty("obser_1").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
				</td>
		</tr>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Presento algun evento:</b>&nbsp;
						<label class="pointer"><%=fb.radio("rec2_2","0",(prop.getProperty("rec2_2")!=null && prop.getProperty("rec2_2").equalsIgnoreCase("0")),viewMode,false,"", null,"onClick='shouldTypeRadio(true, 2)'")%>&nbsp;SI</label>
						&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.radio("rec2_2","1",(prop.getProperty("rec2_2")!=null && prop.getProperty("rec2_2").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(true, 2)'","","")%>&nbsp;NO</label>

						&nbsp;&nbsp;&nbsp;&nbsp;
						(Observacion):&nbsp;<%=fb.textBox("obser_2", prop.getProperty("obser_2"),false,false,viewMode||prop.getProperty("obser_2").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
				</td>
		</tr>
		<tr class="ss">
				<td> 
						<label class="pointer"><%=fb.checkbox("condicion_0","0",prop.getProperty("condicion_0").equals("0"),viewMode,"",null,"","","")%>&nbsp;Valor Crítico</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion_1","1",prop.getProperty("condicion_1").equals("1"),viewMode,"",null,"","","")%>&nbsp;Reacción alérgica</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion_2","2",prop.getProperty("condicion_2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Dolor</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion_3","3",prop.getProperty("condicion_3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Sangrado</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion_4","4",prop.getProperty("condicion_4").equals("4"),viewMode,"",null,"","","")%>&nbsp;Hipotensión</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion_5","5",prop.getProperty("condicion_5").equals("5"),viewMode,"",null,"","","")%>&nbsp;Desaturación</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion_6","6",prop.getProperty("condicion_6").equals("6"),viewMode,"",null,"","","")%>&nbsp;Otros</label>
						<%=fb.textBox("obser_3", prop.getProperty("obser_3"),false,false,viewMode,30,"form-control input-sm","display:inline; width:300px",null)%>
				</td>
		</tr>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Paciente Estable:</b>&nbsp;
						<label class="pointer"><%=fb.radio("rec3_1","0",(prop.getProperty("rec3_1")!=null && prop.getProperty("rec3_1").equalsIgnoreCase("0")),viewMode,false,"", null,"")%>&nbsp;SI</label>
						&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.radio("rec3_1","1",(prop.getProperty("rec3_1")!=null && prop.getProperty("rec3_1").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%>&nbsp;NO</label>
				</td>
		</tr>
		<tr class="ss">
				<td> <b>Recomendaciones:</b>&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion2_0","0",prop.getProperty("condicion2_0").equals("0"),viewMode,"",null,"","","")%>&nbsp;Extensión </label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion2_1","1",prop.getProperty("condicion2_1").equals("1"),viewMode,"",null,"","","")%>&nbsp;Comprensión </label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion2_2","2",prop.getProperty("condicion2_2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Hidratación</label>&nbsp;&nbsp;&nbsp;		
						<label class="pointer"><%=fb.checkbox("condicion2_3","3",prop.getProperty("condicion2_3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Ninguna</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("condicion2_4","4",prop.getProperty("condicion2_4").equals("4"),viewMode,"",null,"","","")%>&nbsp;Otros</label>&nbsp;&nbsp;&nbsp;  
						<%=fb.textBox("obser_4", prop.getProperty("obser_4"),false,false,viewMode,30,"form-control input-sm","display:inline; width:300px",null)%>
						
				</td>
		</tr>
		
        <%}%>
</table>

<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			 <td>
						Opciones de Guardar:
						
						<%=fb.submit("save","Guardar",true,(isComplete||viewMode),"",null,"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.hidePopWin(false)\"")%>
				</td>
		</tr>
		</table>
</div>

<%=fb.formEnd(true)%>
</div>
</div>
</body>

</html>

<%
} else {
	    prop = new Properties();
	 
		prop.setProperty("pac_id",request.getParameter("pac_id"));
		prop.setProperty("admision",request.getParameter("admision"));
		prop.setProperty("codigo",request.getParameter("codigo"));
		prop.setProperty("usuario_creacion",request.getParameter("usuario_creacion"));
		prop.setProperty("fecha_creacion",request.getParameter("fecha_creacion"));
		prop.setProperty("usuario_modificacion", UserDet.getUserName());
		prop.setProperty("fecha_modificacion", cDateTime);

		if(request.getParameter("fecha_traslado")!= null)prop.setProperty("fecha_traslado", request.getParameter("fecha_traslado"));
		if(request.getParameter("medico")!= null)prop.setProperty("medico", request.getParameter("medico"));
		if(request.getParameter("medico_nombre")!= null)prop.setProperty("medico_nombre", request.getParameter("medico_nombre"));
		if(request.getParameter("persona_que_reporta")!= null)prop.setProperty("persona_que_reporta", request.getParameter("persona_que_reporta"));
		if(request.getParameter("cds_persona_que_reporta")!= null)prop.setProperty("cds_persona_que_reporta", request.getParameter("cds_persona_que_reporta"));
		
		if(request.getParameter("persona_que_recibe_nombre") != null)prop.setProperty("persona_que_recibe_nombre", request.getParameter("persona_que_recibe_nombre"));
		if(request.getParameter("fecha_rec") != null)prop.setProperty("fecha_rec", request.getParameter("fecha_rec"));
		
		if(request.getParameter("persona_que_recibe") != null)prop.setProperty("persona_que_recibe", request.getParameter("persona_que_recibe"));
		if(request.getParameter("centro_servicio_recibe_desc") != null)prop.setProperty("centro_servicio_recibe_desc", request.getParameter("centro_servicio_recibe_desc"));
		if(request.getParameter("centro_servicio_recibe") != null)prop.setProperty("centro_servicio_recibe", request.getParameter("centro_servicio_recibe"));
		
		if(request.getParameter("motivo")!= null)prop.setProperty("motivo", request.getParameter("motivo"));
		if(request.getParameter("alergia")!= null)prop.setProperty("alergia", request.getParameter("alergia"));
		if(request.getParameter("aislamiento")!= null)prop.setProperty("aislamiento", request.getParameter("aislamiento"));
		if(request.getParameter("historia_medica_relevante")!= null)prop.setProperty("historia_medica_relevante", request.getParameter("historia_medica_relevante"));
		if(request.getParameter("reporte_transferencia")!= null)prop.setProperty("reporte_transferencia", request.getParameter("reporte_transferencia"));
		if(request.getParameter("totLista")!= null)prop.setProperty("totLista", request.getParameter("totLista"));
		if(request.getParameter("riesgo_caida")!= null)prop.setProperty("riesgo_caida", request.getParameter("riesgo_caida"));
		if(request.getParameter("otros_reg_importantes")!= null)prop.setProperty("otros_reg_importantes", request.getParameter("otros_reg_importantes"));
		if(request.getParameter("condicion_actual")!= null)prop.setProperty("condicion_actual", request.getParameter("condicion_actual")); 
		if(request.getParameter("escala")!= null)prop.setProperty("escala", request.getParameter("escala"));
		if(request.getParameter("presion_arterial")!= null)prop.setProperty("presion_arterial", request.getParameter("presion_arterial"));
		if(request.getParameter("frecuencia_cardica")!= null)prop.setProperty("frecuencia_cardica", request.getParameter("frecuencia_cardica"));
		if(request.getParameter("temperatura")!= null)prop.setProperty("temperatura", request.getParameter("temperatura"));
		if(request.getParameter("respiracion")!= null)prop.setProperty("respiracion", request.getParameter("respiracion"));
		if(request.getParameter("gen_alerta")!=null && !request.getParameter("gen_alerta").trim().equals("")) prop.setProperty("gen_alerta", request.getParameter("gen_alerta"));
		 

		if(request.getParameter("fecha_regreso")!= null)prop.setProperty("fecha_regreso", request.getParameter("fecha_regreso"));
		
		if(request.getParameter("persona_que_rep")!= null)prop.setProperty("persona_que_rep", request.getParameter("persona_que_rep"));
		if(request.getParameter("persona_rec")!= null)prop.setProperty("persona_rec", request.getParameter("persona_rec"));
		if(request.getParameter("rec2_1")!= null)prop.setProperty("rec2_1", request.getParameter("rec2_1"));
		if(request.getParameter("obser_1")!= null)prop.setProperty("obser_1", request.getParameter("obser_1"));
		if(request.getParameter("rec2_2")!= null)prop.setProperty("rec2_2", request.getParameter("rec2_2"));
		if(request.getParameter("obser_2")!= null)prop.setProperty("obser_2", request.getParameter("obser_2"));
		if(request.getParameter("obser_3")!= null)prop.setProperty("obser_3", request.getParameter("obser_3"));
		if(request.getParameter("obser_4")!= null)prop.setProperty("obser_4", request.getParameter("obser_4"));
		if(request.getParameter("condicion_0")!= null)prop.setProperty("condicion_0", request.getParameter("condicion_0"));
		if(request.getParameter("condicion_1")!= null)prop.setProperty("condicion_1", request.getParameter("condicion_1"));
		if(request.getParameter("condicion_2")!= null)prop.setProperty("condicion_2", request.getParameter("condicion_2"));
		if(request.getParameter("condicion_3")!= null)prop.setProperty("condicion_3", request.getParameter("condicion_3"));
		if(request.getParameter("condicion_4")!= null)prop.setProperty("condicion_4", request.getParameter("condicion_4"));
		if(request.getParameter("condicion_5")!= null)prop.setProperty("condicion_5", request.getParameter("condicion_5"));
		if(request.getParameter("condicion_6")!= null)prop.setProperty("condicion_6", request.getParameter("condicion_6"));
		if(request.getParameter("rec3_1")!= null)prop.setProperty("rec3_1", request.getParameter("rec3_1"));
		if(request.getParameter("condicion2_0")!= null)prop.setProperty("condicion2_0", request.getParameter("condicion2_0"));
		if(request.getParameter("condicion2_1")!= null)prop.setProperty("condicion2_1", request.getParameter("condicion2_1"));
		if(request.getParameter("condicion2_2")!= null)prop.setProperty("condicion2_2", request.getParameter("condicion2_2"));
		if(request.getParameter("condicion2_3")!= null)prop.setProperty("condicion2_3", request.getParameter("condicion2_3"));
		if(request.getParameter("condicion2_4")!= null)prop.setProperty("condicion2_4", request.getParameter("condicion2_4"));
		if(request.getParameter("persona_que_rep_id")!= null)prop.setProperty("persona_que_rep_id", request.getParameter("persona_que_rep_id"));
       
			
		if(request.getParameter("comentario_rec1")!=null && !request.getParameter("comentario_rec1").trim().equals("")) prop.setProperty("comentario_rec1", request.getParameter("comentario_rec1"));

		for (int i = 0; i < 20; i++) {
				if (request.getParameter("observacion"+i) != null && !request.getParameter("observacion"+i).trim().equals("")) prop.setProperty("observacion"+i, request.getParameter("observacion"+i));
				if (request.getParameter("req_equipos_"+i) != null && !request.getParameter("req_equipos_"+i).trim().equals("")) prop.setProperty("req_equipos_"+i, request.getParameter("req_equipos_"+i));
				if (request.getParameter("req_pers_"+i) != null && !request.getParameter("req_pers_"+i).trim().equals("")) prop.setProperty("req_pers_"+i, request.getParameter("req_pers_"+i));
		}

		int totLista = request.getParameter("totLista")!=null&&!request.getParameter("totLista").trim().equals("") ? Integer.parseInt(request.getParameter("totLista")) : 0;

		for (int i = 0; i < totLista; i++) {
				if (request.getParameter("seleccionado_"+i) != null) prop.setProperty("seleccionado_"+i, request.getParameter("seleccionado_"+i));
				if (request.getParameter("observacion_lista_"+i) != null && !request.getParameter("observacion_lista_"+i).trim().equals("")) prop.setProperty("observacion_lista_"+i, request.getParameter("observacion_lista_"+i));
		}
		
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			THMgr.update(prop);
		ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow(){
<% if (THMgr.getErrCode().equals("1")) { %>
	alert('<%=THMgr.getErrMsg()%>'); 
	parent.hidePopWin(false);
<%	 
} else throw new Exception(THMgr.getErrMsg());
%>
} 
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
