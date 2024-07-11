<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.NotasEnfermeria"%>
<%@ page import="issi.expediente.DetalleResultadoNota"%>
<%@ page import="issi.expediente.CriteriosHemodialisis"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="NEMgr" scope="page" class="issi.expediente.NotasEnfermeriaMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NEMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDiag = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
boolean viewMode = false;
String sql = "";
String appendFilter = "";
String seccion = request.getParameter("seccion");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String defaultAction = request.getParameter("defaultAction");
StringBuffer sbSql = new StringBuffer();
int lastLineNo = 0;
String key = "";
if (id == null) id = "0";

if (fg == null)fg = "HM2";

if (defaultAction == null) defaultAction = "";
if (mode == null || mode.trim().equals("")) mode = "add";
if ((modeSec == null || modeSec.trim().equals("")) && !mode.equalsIgnoreCase("view")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (mode.trim().equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){

alDiag = sbb.getBeanList(ConMgr.getConnection(),"select id as optValueColumn, nombre_eng as optLabelColumn, id as optTitleColumn from tbl_cds_diagnostico_enf order by 2",CommonDataObject.class);

sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'EXP_TRAER_TRIAGE_NE'),'N') as set_triage from dual");
CommonDataObject cdoParam = (CommonDataObject) SQLMgr.getData(sbSql.toString());

ArrayList alC = SQLMgr.getDataList("select a.codigo, a.descripcion, b.observacion, b.cod_criterio from tbl_sal_criterios_hemo a, tbl_sal_criterios_hemo_det b where a.estado = 'A' and a.codigo = b.cod_criterio(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.id_nota(+) = "+id);
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
document.title = 'Notas de Enfermería - '+document.title;
var noNewHeight = true;
function doAction(){}
function setTriageDetail(k){
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','nvl(a.observacion,\' \') as observacion, nvl(a.accion,\' \') as accion, b.signo_vital, b.resultado','tbl_sal_signo_paciente a, tbl_sal_detalle_signo b','a.pac_id=<%=pacId%> and a.secuencia=<%=noAdmision%> and a.tipo_persona=\'T\' and a.status = \'A\' and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.tipo_persona=b.tipo_persona and b.signo_vital in (1,2,3,4,7,8) and a.fecha=b.fecha_signo and a.fecha_creacion = (select max(x.fecha_creacion) from tbl_sal_signo_paciente x,tbl_sal_detalle_signo z where x.tipo_persona=\'T\' and x.status = \'A\' and x.pac_id=<%=pacId%> and x.secuencia=<%=noAdmision%> and x.pac_id=z.pac_id and x.secuencia=z.secuencia and x.tipo_persona=z.tipo_persona and x.fecha=z.fecha_signo and z.signo_vital in (1,2,3,4,7,8))','order by b.fecha_creacion desc'));
	set4=false;
	set7=false;
	set8=false;
	if(r!=null&&r.length>0){
		for(i=0;i<r.length;i++){
			var c=r[i];
			if(c[2].trim()=='4'&&!set4){set4=true;eval('document.form0.pArterial'+k).value=c[3].trim();}
			else if(c[2].trim()=='7'&&!set7){set7=true;eval('document.form0.peso'+k).value=c[3].trim();}
			else if(c[2].trim()=='8'&&!set8){set8=true;eval('document.form0.talla'+k).value=c[3].trim();}
			if(set4&&set7&&set8)break;
		}
	}else alert('No hay datos en Triage!');
}

function isValidDetailsDateTime()
{
	size=parseInt(document.form0.size.value,10);
	for(i=1;i<=size;i++)
	{
		var fecha = eval('document.form0.fecha'+i).value.trim();
		var hora = eval('document.form0.horaR'+i).value.trim();
		if(fecha==''||hora=='')
		{
			alert('Por favor ingrese las fechas/horas en las notas!');
			return false;
		}
	}
	return true;
}

function doSubmit(){
		document.form0.baction.value = parent.document.form0.baction.value;
	document.form0.saveOption.value = parent.document.form0.saveOption.value;
	document.form0.dob.value = parent.document.form0.dob.value;
	document.form0.codPac.value = parent.document.form0.codPac.value;
	document.form0.noHemodialisis.value = parent.document.form0.noHemodialisis.value;
	document.form0.maquina.value = parent.document.form0.maquina.value;
	document.form0.fecha.value = parent.document.form0.fecha.value;
	document.form0.hora.value = parent.document.form0.hora.value;
	document.form0.hora_termino.value = parent.document.form0.hora_termino.value;
	document.form0.medico_nefro.value = parent.document.form0.medico_nefro.value;
	document.form0.compania.value = parent.document.form0.compania.value;
	document.form0.idNe.value = parent.document.form0.idNe.value;

	if (document.form0.baction.value == 'Guardar' && !form0Validation()){
		form0BlockButtons(false);
		parent.form0BlockButtons(false);
		return false;
	}
	document.form0.submit();
}

function isAValidNoHemodialisis(){
	var fg = "<%=fg.trim()%>";
	var noHemo = $("#noHemodialisis").val();
	return isInteger(noHemo);
}

$(function(){
		$("#criterios").click(function(){
				$(".criterios").toggle();
		});

		$(".should-type").click(function(){
				var that = $(this);
				var i = that.data('index');
				if (that.is(":checked")) {
						$("#observacion_criterio_"+i).prop("readOnly", false);
				} else {
						$("#observacion_criterio_"+i).val("").prop("readOnly", true);
				}
		});
});
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()" style="margin-top: -57px;">
<div class="row">
		<div class="table-responsive" data-pattern="priority-columns">
		<table width="100%" class="table table-small-font table-bordered table-striped table-hover">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+HashDet.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("hora","")%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("defaultAction",defaultAction)%>

<%=fb.hidden("noHemodialisis","")%>
<%=fb.hidden("maquina","")%>
<%=fb.hidden("medico_nefro","")%>
<%=fb.hidden("compania","")%>
<%=fb.hidden("hora_termino","")%>
<%=fb.hidden("idNe",id)%>
<%=fb.hidden("totC",""+alC.size())%>

<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
<%fb.appendJsValidation("if("+HashDet.size()+"==0){alert('Por favor introduzca por lo menos una Nota de Enfermería!');error++;}");%>
<%fb.appendJsValidation("if(!isValidDetailsDateTime())error++;");%>
<%fb.appendJsValidation("if(!isAValidNoHemodialisis()){alert('Por favor introduzca un intero para el número de Hemodiálisis  !');error++;}");%>
<tr>
		<td colspan="7">
				<table width="100%" class="table table-small-font table-bordered table-striped table-hover">
						<tr class="bg-headtabla pointer" id="criterios">
							<td>Criterios</td>
							<td>Observaciones</td>
						</tr>

						<%for (int i = 0; i<alC.size(); i++) {
								CommonDataObject cdoC = (CommonDataObject) alC.get(i);%>
								<tr class="criterios">
										<td>
												<label class="pointer">
												<%=fb.checkbox("cod_criterio_"+i,cdoC.getColValue("codigo"),cdoC.getColValue("codigo","-1").equals(cdoC.getColValue("cod_criterio","-2")),viewMode,"should-type",null,"",""," data-index="+i)%>&nbsp;
												<%=cdoC.getColValue("descripcion")%>
												</label>
										</td>
										<td>
												<%=fb.textarea("observacion_criterio_"+i,cdoC.getColValue("observacion"),false,false,viewMode||cdoC.getColValue("observacion"," ").trim().equals(""),0,1,0,"form-control input-sm","width:100%","")%>
										</td>
								</tr>
						<%}%>
				</table>
		</td>
</tr>

<tr class="bg-headtabla2">
		<td width="20%"><cellbytelabel id="2">Hora</cellbytelabel></td>
		<td width="20%"><cellbytelabel id="4">Peso</cellbytelabel></td>
		<td width="10%"><cellbytelabel id="5">Talla</cellbytelabel>.</td>
		<td width="18%"><cellbytelabel id="6">F.C</cellbytelabel></td>
		<td width="20%"><cellbytelabel id="11">P.A</cellbytelabel></td>
		<td width="10%"><cellbytelabel id="11">Dolor</cellbytelabel></td>
		<td width="2%" class="text-center">
				<%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Nota")%>
		</td>
</tr>

<%

al = CmnMgr.reverseRecords(HashDet);
for (int i=1; i<=HashDet.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleResultadoNota drn = (DetalleResultadoNota) HashDet.get(key);
	String displayNote = "";

	if (drn.getEstado() != null && drn.getEstado().equalsIgnoreCase("D")) displayNote = " style=\"display:none\"";
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("codigo"+i,drn.getCodigo())%>
		<%=fb.hidden("estado"+i,drn.getEstado())%>
		<%=fb.hidden("usuarioCreacion"+i,drn.getUsuarioCreacion())%>
		<%=fb.hidden("remove"+i,"")%>

		<%=fb.hidden("fecha"+i,drn.getFecha())%>
		<tr align="center"<%=displayNote%>>
			<td class="controls form-inline">
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi:ss am"/>
				<jsp:param name="nameOfTBox1" value="<%="horaR"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=drn.getHoraR()%>" />
				</jsp:include>
			</td>

						<td>
								<input class="form-control input-sm<%=viewMode?" disabled":""%>" value="<%=drn.getPeso()%>" name="peso<%=i%>" id="peso<%=i%>" maxlength="10" size="10%">
						</td>
						<td>
								<input class="form-control input-sm<%=viewMode?" disabled":""%>" value="<%=drn.getTalla()%>" name="talla<%=i%>" id="talla<%=i%>" maxlength="10" size="10%">
						</td>
						<td>
								<input class="form-control input-sm<%=viewMode?" disabled":""%>" value="<%=drn.getFCard()%>" name="fCard<%=i%>" id="fCard<%=i%>" maxlength="10" size="10%">
						</td>
						<td>
								<input class="form-control input-sm<%=viewMode?" disabled":""%>" value="<%=drn.getPArterial()%>" name="pArterial<%=i%>" id="pArterial<%=i%>" maxlength="10" size="10%">
						</td>
						<td>
								<input class="form-control input-sm<%=viewMode?" disabled":""%>" value="<%=drn.getDolor()%>" name="dolor<%=i%>" id="dolor<%=i%>" maxlength="1" size="10%">
						</td>


			<td>
								<%if(drn.getCodigo().equals("0") || drn.getUsuarioCreacion().trim().equals((String) session.getAttribute("_userName"))){%>
								 <%=fb.submit("rem"+i,"x",viewMode,false,"",null,"onClick=\"removeItem(this.form.name,"+i+"); __submitForm(this.form, this.value)\"","Eliminar")%>
								<%}%>
			</td>
		</tr>
				<tr <%=displayNote%>>
						<td colspan="7">
								<cellbytelabel id="16">Notas de la enfermera</cellbytelabel>
								<%=fb.textarea("observacion"+i,drn.getObservacion(),false,false,viewMode,0,1,2000,"form-control input-sm","width:100%","")%>
						</td>
				</tr>
		<%}%>
		</table>
<%=fb.formEnd(true)%>
</div>
	</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	int totC = Integer.parseInt(request.getParameter("totC"));
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

	NotasEnfermeria ne = new NotasEnfermeria();
	ne.setPacId(pacId);
	ne.setSecuencia(noAdmision);
	ne.setFecNacimiento(request.getParameter("dob"));
	ne.setCodPaciente(request.getParameter("codPac"));
	ne.setFecha(request.getParameter("fecha"));
	ne.setHora(request.getParameter("hora"));
		ne.setNoHemodialisis(request.getParameter("noHemodialisis"));
	ne.setMaquina(request.getParameter("maquina"));
	ne.setHoraTermino(request.getParameter("hora_termino"));
	ne.setCompania(request.getParameter("compania"));
	ne.setMedicoNefro(request.getParameter("medico_nefro"));
		ne.setObservacion("HM2");

	if (modeSec.equalsIgnoreCase("edit")) ne.setId(request.getParameter("idNe"));
	ne.setUsuarioCreacion((String) session.getAttribute("_userName"));
	ne.setUsuarioModif((String) session.getAttribute("_userName"));

	String ItemRemoved = "";
	for (int i=1; i<=size; i++){
		DetalleResultadoNota drn = new DetalleResultadoNota();

		drn.setCodigo(request.getParameter("codigo"+i));
		drn.setEstado(request.getParameter("estado"+i));
		drn.setFecha(request.getParameter("fecha"+i));
		drn.setHoraR(request.getParameter("horaR"+i));

		drn.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
		drn.setUsuarioModificacion((String) session.getAttribute("_userName"));

		drn.setPArterial(request.getParameter("pArterial"+i));
				drn.setDolor(request.getParameter("dolor"+i));
		drn.setAccion(request.getParameter("accion"+i));
		drn.setFCard(request.getParameter("fCard"+i));
		drn.setPeso(request.getParameter("peso"+i));
		drn.setTalla(request.getParameter("talla"+i));
				drn.setObservacion(request.getParameter("observacion"+i));
				drn.setComentario("HM2");

		drn.setCategoria("1");

		drn.setKey(request.getParameter("key"+i));
		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			ItemRemoved = key;
			drn.setEstado("D");
		}
				try{
						HashDet.put(key, drn);
						ne.addDetalleResultadoNota(drn);
				}
				catch(Exception e){
						System.err.println(e.getMessage());
				}
	}

	if (!ItemRemoved.equals("")){
				response.sendRedirect("../expediente3.0/exp_cuid_pac_hemo_det.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo="+lastLineNo+"&change=1&defaultAction="+defaultAction+"&id="+id);
		return;
	}
	if (baction != null && baction.trim().equalsIgnoreCase("+")){
		DetalleResultadoNota drn = new DetalleResultadoNota();

		drn.setCodigo("0");
		drn.setEstado("A");
		String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
		drn.setFecha(cDate.substring(0,10));
		drn.setHoraR(cDate.substring(11));
		drn.setUsuarioCreacion((String) session.getAttribute("_userName"));

		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;
		drn.setKey(""+lastLineNo);

		try{
			HashDet.put(key, drn);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}

		response.sendRedirect("../expediente3.0/exp_cuid_pac_hemo_det.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo="+lastLineNo+"&change=1&defaultAction="+defaultAction+"&id="+id);
		return;
	}

		al.clear();

		for (int i = 0; i<totC; i++){
				if (request.getParameter("cod_criterio_"+i) != null) {
						CriteriosHemodialisis ch = new CriteriosHemodialisis();
						ch.setCodigoCriterio(request.getParameter("cod_criterio_"+i));
						ch.setObservacion(request.getParameter("observacion_criterio_"+i));

						ne.addCriteriosHemo(ch);
				}
		}

	if (baction != null && baction.trim().equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) NEMgr.add(ne);
		else if (modeSec.equalsIgnoreCase("edit")) NEMgr.update(ne);
		ConMgr.clearAppCtx(null);
				System.out.println(".................................................. 1");
	}

%>
<html>
<head>
<script>
function closeWindow()
{
<%if (NEMgr.getErrCode().equals("1")){%>
	parent.document.form0.errCode.value='<%=NEMgr.getErrCode()%>';
	parent.document.form0.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(NEMgr.getErrMsg())%>';
	parent.document.form0.submit();
<%} else throw new Exception(NEMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>