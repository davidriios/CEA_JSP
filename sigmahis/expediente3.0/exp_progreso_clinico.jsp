<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<%
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
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String code = request.getParameter("code");
String fg = request.getParameter("fg");
String estado = request.getParameter("estado");
String usuarioCreacion = request.getParameter("usuario_creacion");
String key = "";
int progresoLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String userName = (String) session.getAttribute("_userName");

if (estado == null) estado = "";
if (usuarioCreacion == null) usuarioCreacion = "";
if (fg == null) fg = "";
if (code == null) code = "0";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
		ArrayList alH = SQLMgr.getDataList("select progreso_id, to_char(fecha, 'dd/mm/yyyy') fecha, to_char(fecha, 'hh12:mi am') hora, usuario_creacion, decode(status,'A', 'ACTIVO', 'I', 'INVALIDA') as status_dsp, (select nvl(reg_medico,codigo)||' - '||primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = z.medico) as medico from tbl_sal_progreso_clinico z where pac_id = "+pacId+" and admision = "+noAdmision+" order by 1 desc");
		if (code.equals("-1") && fg.equals("plan_salida") && alH.size() > 0) {
			CommonDataObject cdoH = (CommonDataObject) alH.get(0);
			code = cdoH.getColValue("progreso_id");
			viewMode = true;
		}

		if (!code.trim().equals("") || !code.trim().equals("0")) {
			 cdo = SQLMgr.getData("select to_char(fecha, 'dd/mm/yyyy') fecha, to_char(fecha, 'hh12:mi am') hora, observacion,  medico, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = medico ) nombre_medico, otros, usuario_creacion, decode(status,'A', 'ACTIVO', 'I', 'INVALIDA') as status_dsp from tbl_sal_progreso_clinico where pac_id = "+pacId+" and admision = "+noAdmision+" and progreso_id = "+code);
		}

		al = SQLMgr.getDataList("select h.codigo, h.descripcion, d.soap_id, d.seleccionar, h.es_default from tbl_sal_progreso_clinico_soap h, tbl_sal_progreso_clinico_det d where h.codigo = d.soap_id(+) and h.status = 'A' and d.pac_id(+) = "+pacId+" and admision(+) = "+noAdmision+" and d.progreso_id(+) = "+code+" order by h.orden");

		if (cdo == null) {
			cdo = new CommonDataObject();
			cdo.addColValue("progreso_id", code);
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("hora",cDateTime.substring(11));
			if(UserDet.getRefType().trim().equalsIgnoreCase("M")){
				 cdo.addColValue("nombre_medico",""+UserDet.getName());
				 cdo.addColValue("medico",""+UserDet.getRefCode());
			}
		} else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'Progreso Clinico - '+document.title;
var noNewHeight = true;
function doAction(){$("#loadingmsg").remove()}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=progreso');}
function getMedico(k){var medico=eval('document.form0.medico'+k).value;var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico ',' codigo=\''+medico+'\'','');eval('document.form0.nombre_medico'+k).value=medDesc;}}
function verProgreso(){abrir_ventana1('../expediente/exp_progreso_clinico_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');}

function setProgreso(code, usuarioCreacion) {
	window.location = "../expediente3.0/exp_progreso_clinico.jsp?estado=<%=estado%>&seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&code="+code+"&usuario_creacion="+usuarioCreacion;
}
function add(){window.location = '../expediente3.0/exp_progreso_clinico.jsp?estado=<%=estado%>&modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&fg=<%=fg%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}

$(function(){
 $("#chkOtro").click(function(){
		if ( $(this).is(":checked") ) $("#otros").prop("readOnly", false)
		else $("#otros").val("").prop("readOnly", true)
 })
});

function doSubmit(form, value) {
	if (value == 'Inactivar' || value == 'Inactivar Super') {
		if ( confirm('Por favor confirmar que quieres inabilitar el Progreso # <%=code%>') ) __submitForm(form, value);
	} else {
			if ($("#chkOtro").is(":checked") && !$.trim($("#otros").val())  ) parent.CBMSG.error("Por favor llenar OTROS Plan de Cuidado Médico (SOAP)");
			else __submitForm(form, value);
	}
}

function printExp(option){
		if(!option) abrir_ventana("../expediente3.0/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=<%=code%>");
		else abrir_ventana("../expediente3.0/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=0");
}

function verHistorial() {
	$("#hist_container").toggle();
}
</script>
<style>
.greenirize{background-color:#bcf5a9 !important;}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' && document."+fb.getFormName()+".baction.value!='Inactivar' && document."+fb.getFormName()+".baction.value!='Inactivar Super')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("detSize",""+al.size())%>
<%=fb.hidden("progresoLineNo",""+progresoLineNo)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("usuario_creacion", usuarioCreacion)%>
<%=fb.hidden("estado", estado)%>
<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr>
				<td>
						<%if(!mode.trim().equals("view")){%>
							<button type="button" class="btn btn-inverse btn-sm" onclick="add()">
								<i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
							</button>
						<%}%>

						<button type="button" name="ver_progreso" id="ver_progreso"  class="btn btn-inverse btn-sm" onclick="javascript:verProgreso()"><i class="fa fa-eye fa-lg"></i> Ver Progreso</button>
						<%if(!code.equals("") && !code.equals("0")){%>
						<%=fb.button("imprimir","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:printExp()\"")%>
						<%}%>

						<button type="button" class="btn btn-inverse btn-sm" onclick="javascript:printExp(1)"><i class="fa fa-print fa-lg"></i> Imprimir Todos</button>

						<%if(alH.size() > 0){%>
						<button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
								<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
						</button>
						<%}%>

				</td>
		</tr>
		<tr><th class="bg-headtabla">LISTADO DE RESULTADOS</th></tr>
</table>

<div class="table-wrapper greenirize" id="hist_container" style="display:none">
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<thead>
				<tr class="bg-headtabla2">
						<th style="vertical-align: middle !important;">Progreso ID</th>
						<th style="vertical-align: middle !important;">M&eacute;dico</th>
						<th style="vertical-align: middle !important;">Fecha</th>
						<th style="vertical-align: middle !important;">Usuario</th>
						<th style="vertical-align: middle !important;"></th>
				</thead>
				<%for (int h = 0; h < alH.size(); h++){
					CommonDataObject cdoH = (CommonDataObject) alH.get(h);%>
					<tr class="pointer greenirize" onclick="setProgreso(<%=cdoH.getColValue("progreso_id")%>, '<%=cdoH.getColValue("usuario_creacion"," ")%>')">
							<td><%=cdoH.getColValue("progreso_id")%></td>
							<td><%=cdoH.getColValue("medico")%></td>
							<td><%=cdoH.getColValue("fecha")%> <%=cdoH.getColValue("hora")%></td>
							<td><%=cdoH.getColValue("usuario_creacion"," ")%></td>
							<td><span style="font-weight:bold"><%=cdoH.getColValue("status_dsp")%></span></td>
					</tr>
				<%}%>
				<tbody>
				</tbody>
		</table>
</div>

</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
		<tr class="bg-headtabla" align="center">
				<th width="20%"><cellbytelabel id="3">Fecha</cellbytelabel></th>
				<th width="20%"><cellbytelabel id="4">Hora</cellbytelabel></th>
				<th width="60%"><cellbytelabel id="5">M&eacute;dico</cellbytelabel></th>
		</tr>
		</thead>

		<tbody>
				<tr class="greenirize">
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								<jsp:param name="readonly" value="<%=(viewMode || cdo.getColValue("progreso_id") != null && !cdo.getColValue("progreso_id").trim().equals("0"))?"y":"n"%>"/>
								</jsp:include>
						</td>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="hora" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora")%>" />
								<jsp:param name="readonly" value="<%=(viewMode || cdo.getColValue("progreso_id") != null && !cdo.getColValue("progreso_id").trim().equals("0"))?"y":"n"%>"/>
								<jsp:param name="format" value="hh12:mi am" />
								</jsp:include>
						</td>
						<td class="controls form-inline">
								<%=fb.hidden("medico", cdo.getColValue("medico"))%>
								<%=fb.textBox("nombre_medico",cdo.getColValue("nombre_medico"),true,false,true,55,"form-control input-sm",null,null)%>
								<%=fb.button("btnMedico","...",true,viewMode,"btn btn-primary btn-sm",null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>

								<span style="font-weight:bold; float:right"><%=cdo.getColValue("status_dsp"," ")%></span>
						</td>
				</tr>
		<tr class="greenirize">
			<td colspan="3">
				<cellbytelabel id="6">Observaciones del M&eacute;dico</cellbytelabel>
				<%=fb.textarea("observacion",cdo.getColValue("observacion"),true,false,viewMode,80,12,2000,"form-control input-sm","width:100%","")%>
			</td>
		</tr>

				<tr class="bg-headtabla">
			<td colspan="3">Plan de Cuidado Médico (SOAP)</td>
		</tr>

				<%for (int d = 0; d < al.size(); d++){
				 CommonDataObject cdoD = (CommonDataObject) al.get(d);
				%>
						<%=fb.hidden("soap_id"+d, cdoD.getColValue("soap_id"))%>
						<%=fb.hidden("codigo_det"+d, cdoD.getColValue("codigo"))%>
						<tr class="greenirize">
								<td colspan="2"><%=cdoD.getColValue("descripcion")%></td>
								<td>
									<label class="pointer">
									SI&nbsp;<%=fb.radio("seleccionar"+d,"S", cdoD.getColValue("seleccionar")!=null && (cdoD.getColValue("seleccionar").equalsIgnoreCase("S")||cdoD.getColValue("es_default").equalsIgnoreCase("S")),viewMode,false,null,null,"")%>
									</label>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<label class="pointer">NO&nbsp;
									<%=fb.radio("seleccionar"+d,"N", cdoD.getColValue("seleccionar")!=null && cdoD.getColValue("seleccionar").equalsIgnoreCase("N") ,viewMode,false,null,null,"")%></label>
								</td>
						</tr>
				<%}%>

				<tr class="greenirize">
			<td colspan="3" class="controls form-inline">
							 <label class="pointer">
							 <%=fb.checkbox("chkOtro","",(cdo.getColValue("otros") != null), viewMode, "", "", "")%>
				<b><cellbytelabel id="6">Otros: Explique:</cellbytelabel></b></label>
				<%=fb.textarea("otros",cdo.getColValue("otros"),false, false,(viewMode ||  cdo.getColValue("otros") == null ),80,2,2000,"form-control input-sm","width:100%","")%>
			</td>
		</tr>
<%
fb.appendJsValidation("if(error>0)doAction();");
%>
</tbody>
</table>

<%//if(!fg.equalsIgnoreCase("plan_salida")){%>
<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
				<tr>
						<td>
								<input type="hidden" value="O" name="saveOption">
								<%=fb.button("save","Guardar",true,viewMode,"btn btn-sm btn-primary",null,"onClick='doSubmit(this.form, this.value)'")%>
								<%if(!usuarioCreacion.trim().equals("") && usuarioCreacion.equalsIgnoreCase(userName) && cdo.getColValue("status_dsp"," ").trim().equalsIgnoreCase("ACTIVO") ){%>
									<%=fb.button("inactivar1","Inactivar",true,estado.equalsIgnoreCase("F"),"btn btn-sm btn-danger",null,"onClick='doSubmit(this.form, this.value)'")%>
								<%}%>
								
								<authtype type="50">
								<%if(cdo.getColValue("status_dsp"," ").trim().equalsIgnoreCase("ACTIVO") ){%>
									<%=fb.button("inactivar2","Inactivar Super",true,estado.equalsIgnoreCase("F"),"btn btn-sm btn-warning",null,"onClick='doSubmit(this.form, this.value)'")%>
								<%}%>
								</authtype>
						 </td>
				</tr>
		</table>
</div>
<%//}%>

<%=fb.formEnd(true)%>
</div>
</div>
</html>
<%
}//GET
else
{
		String saveOption = request.getParameter("saveOption");
		String baction = request.getParameter("baction");
		int size = Integer.parseInt(request.getParameter("detSize"));
		al.clear();

		if (baction.equalsIgnoreCase("Inactivar") || baction.equalsIgnoreCase("Inactivar Super")) {
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_progreso_clinico");
			cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and progreso_id = "+code);

			cdo.addColValue("status", "I");
			cdo.addColValue("fecha_modificacion", cDateTime);
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"baction="+baction);
			SQLMgr.update(cdo);
			ConMgr.clearAppCtx(null);
		} else {

			String nextId = "";
			cdo = SQLMgr.getData("select  nvl(max(progreso_id),0)+1 next_id from tbl_sal_progreso_clinico");
			nextId = cdo.getColValue("next_id");
			code = nextId;

			CommonDataObject cdoH = new CommonDataObject();
			cdoH.setTableName("tbl_sal_progreso_clinico");
			cdoH.addColValue("progreso_id", nextId);
			cdoH.addColValue("pac_id", request.getParameter("pacId"));
			cdoH.addColValue("admision", request.getParameter("noAdmision"));
			cdoH.addColValue("fecha",request.getParameter("fecha")+" "+request.getParameter("hora"));
			cdoH.addColValue("observacion",request.getParameter("observacion"));
			cdoH.addColValue("medico",request.getParameter("medico"));
			cdoH.addColValue("otros",request.getParameter("otros"));
			cdoH.addColValue("fecha_creacion", cDateTime);
			cdoH.addColValue("usuario_creacion", userName);

			for (int i=0; i<size; i++) {
				CommonDataObject cdo2 = new CommonDataObject();
				cdo2.setTableName("tbl_sal_progreso_clinico_det");
				cdo2.addColValue("pac_id",request.getParameter("pacId"));
				cdo2.addColValue("admision",request.getParameter("noAdmision"));
				cdo2.addColValue("progreso_id", nextId);
				cdo2.addColValue("soap_id", request.getParameter("codigo_det"+i));
				cdo2.addColValue("seleccionar", request.getParameter("seleccionar"+i));
				cdo2.setAction("I");

				al.add(cdo2);
			}

			if (baction.equalsIgnoreCase("Guardar")){
				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				SQLMgr.save(cdoH, al, true, true, true, true);
				ConMgr.clearAppCtx(null);

				usuarioCreacion = userName;
			}
	}
%>
<html>
<head>
<script>
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
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code=<%=code%>&fg=<%=fg%>&estado=<%=estado%>&usuario_creacion=<%=usuarioCreacion%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>