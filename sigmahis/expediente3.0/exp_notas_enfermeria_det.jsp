<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.NotasEnfermeria"%>
<%@ page import="issi.expediente.DetalleResultadoNota"%>
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
/**
==================================================================================
SAL310111 Expediente Enfermeria
FG = TD - todas las secciones .
FG = HM - hemodialisis.
==================================================================================
**/
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
String defaultAction = request.getParameter("defaultAction");
StringBuffer sbSql = new StringBuffer();
int lastLineNo = 0;
String key = "";

if (fg == null)fg = "TD";// todas las secciones

if (defaultAction == null) defaultAction = "";
//if (defaultAction.equals("1")) mode = "";
if (mode == null || mode.trim().equals("")) mode = "add";
if ((modeSec == null || modeSec.trim().equals("")) && !mode.equalsIgnoreCase("view")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
//if (!defaultAction.equals("1") || mode.trim().equals("view")) viewMode=true;
//if ((!defaultAction.equals("1") && mode.trim().equals("view"))&&modeSec.trim().equals("view")) viewMode=true;
if (mode.trim().equals("view")) viewMode=true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
alDiag = sbb.getBeanList(ConMgr.getConnection(),"select id as optValueColumn, nombre_eng as optLabelColumn, id as optTitleColumn from tbl_cds_diagnostico_enf order by 2",CommonDataObject.class);
sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_TRAER_TRIAGE_NE'),'N') as set_triage from dual");
	CommonDataObject cdoParam = (CommonDataObject) SQLMgr.getData(sbSql.toString());


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
	set1=false;
	set2=false;
	set3=false;
	set4=false;
	set7=false;
	set8=false;
	if(r!=null&&r.length>0){
		for(i=0;i<r.length;i++){
			var c=r[i];
			if(i==0)eval('document.form0.observacion'+k).value=c[0].trim();//observacion
			if(c[2].trim()=='1'&&!set1){set1=true;eval('document.form0.temperatura'+k).value=c[3].trim();}
			else if(c[2].trim()=='2'&&!set2){set2=true;eval('document.form0.pulso'+k).value=c[3].trim();}
			else if(c[2].trim()=='3'&&!set3){set3=true;eval('document.form0.respiracion'+k).value=c[3].trim();}
			else if(c[2].trim()=='4'&&!set4){set4=true;eval('document.form0.pArterial'+k).value=c[3].trim();}
			else if(c[2].trim()=='7'&&!set7){set7=true;eval('document.form0.peso'+k).value=c[3].trim();}
			else if(c[2].trim()=='8'&&!set8){set8=true;eval('document.form0.talla'+k).value=c[3].trim();}
			if(set1&&set2&&set3&&set4&&set7&&set8)break;
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

function doSubmit()
{
	document.form0.baction.value = parent.document.form0.baction.value;
	document.form0.saveOption.value = parent.document.form0.saveOption.value;
	document.form0.dob.value = parent.document.form0.dob.value;
	document.form0.codPac.value = parent.document.form0.codPac.value;
	document.form0.fecha.value = parent.document.form0.fecha.value;
	document.form0.hora.value = parent.document.form0.hora.value;
	document.form0.idNe.value = parent.document.form0.idNe.value;
	<%if(fg.trim().equals("HM")){%>
	document.form0.noHemodialisis.value = parent.document.form0.noHemodialisis.value;
	document.form0.maquina.value = parent.document.form0.maquina.value;
	document.form0.filtro.value = parent.document.form0.filtro.value;
	document.form0.solucion.value = parent.document.form0.solucion.value;
	document.form0.pesoInicial.value = parent.document.form0.pesoInicial.value;
	document.form0.pesoFinal.value = parent.document.form0.pesoFinal.value;

	<%}%>
	if (document.form0.baction.value == 'Guardar' && !form0Validation())
	{
		form0BlockButtons(false);
		parent.form0BlockButtons(false);
		return false;
	}
	document.form0.submit();
}

function isAValidNoHemodialisis(){
	var fg = "<%=fg.trim()%>";
	var noHemo = $("#noHemodialisis").val();
	if(fg=="HM") return isInteger(noHemo);
	else return true;
}

</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
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
<%=fb.hidden("filtro","")%>
<%=fb.hidden("solucion","")%>
<%=fb.hidden("pesoInicial","")%>
<%=fb.hidden("pesoFinal","")%>
<%=fb.hidden("idNe","")%>

<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
<%fb.appendJsValidation("if("+HashDet.size()+"==0){alert('Por favor introduzca por lo menos una Nota de Enfermería!');error++;}");%>
<%fb.appendJsValidation("if(!isValidDetailsDateTime())error++;");%>
<%fb.appendJsValidation("if(!isAValidNoHemodialisis()){alert('Por favor introduzca un intero para el número de Hemodiálisis  !');error++;}");%>

		<%if(!fg.trim().equals("HM")){%>
			<tr class="bg-headtabla2">
			<th width="12%"><cellbytelabel id="1">Fecha</cellbytelabel></th>
			<th width="12%"><cellbytelabel id="2">Hora</cellbytelabel></th>
			<th width="7%"><cellbytelabel id="3">Temp.</cellbytelabel></th>
			<th width="4%"><cellbytelabel id="4">Pulso</cellbytelabel></th>
			<th width="7%"><cellbytelabel id="5">Resp</cellbytelabel>.</th>
			<th width="7%"><cellbytelabel id="6">P.Art</cellbytelabel>.</th>
			<th width="6%"><cellbytelabel id="7">F.Card.</cellbytelabel></th>
			<th width="6%"><cellbytelabel id="8">Pul.Card.</cellbytelabel></th>
			<th width="5%"><cellbytelabel id="9">Peso</cellbytelabel></th>
			<th width="6%"><cellbytelabel id="10">Talla</cellbytelabel></th>
			<th width="2%">&nbsp;</td>
			<th width="8%" class="text-center">
								<%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Nota")%>
						</td>
		</tr>
		<%}else{%>
		<tr class="bg-headtabla2">
			<th width="12%"><cellbytelabel id="2">Hora</cellbytelabel></th>
			<th width="12%"><cellbytelabel id="6">P.Art.</cellbytelabel></th>
			<th width="8%"><cellbytelabel id="4">Pulso</cellbytelabel></th>
			<th width="4%"><cellbytelabel id="5">Resp</cellbytelabel>.</th>
			<th width="8%"><cellbytelabel id="3">Temp</cellbytelabel>.</th>
			<th width="7%"><cellbytelabel id="11">F. S</cellbytelabel></th>
			<th width="6%"><cellbytelabel id="12">P. V</cellbytelabel></th>
			<th width="6%"><cellbytelabel id="23">UF</cellbytelabel></th>
			<th width="6%"><cellbytelabel id="14">P.T.M</cellbytelabel></th>
			<th width="2%" class="text-center">
								<%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Nota")%>
						</th>
		</tr>

		<%}%>
<%

al = CmnMgr.reverseRecords(HashDet);
for (int i=1; i<=HashDet.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleResultadoNota drn = (DetalleResultadoNota) HashDet.get(key);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String displayNote = "";

	if (drn.getEstado() != null && drn.getEstado().equalsIgnoreCase("D")) displayNote = " style=\"display:none\"";
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("codigo"+i,drn.getCodigo())%>
		<%=fb.hidden("estado"+i,drn.getEstado())%>
		<%=fb.hidden("usuarioCreacion"+i,drn.getUsuarioCreacion())%>
		<%=fb.hidden("remove"+i,"")%>
		<%if(!fg.trim().equals("HM")){%>

		<tr align="left"<%=displayNote%>>
			<td class="controls form-inline">
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=drn.getFecha()%>" />
				</jsp:include>
			</td>
			<td class="controls form-inline">
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="horaR"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=drn.getHoraR()%>" />
				</jsp:include>
			</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getTemperatura()%>" name="temperatura<%=i%>" id="temperatura<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getPulso()%>" name="pulso<%=i%>" id="pulso<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getRespiracion()%>" name="respiracion<%=i%>" id="respiracion<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getPArterial()%>" name="pArterial<%=i%>" id="pArterial<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getFCard()%>" name="fCard<%=i%>" id="fCard<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getPCard()%>" name="pCard<%=i%>" id="pCard<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getPeso()%>" name="peso<%=i%>" id="peso<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md" value="<%=drn.getTalla()%>" name="talla<%=i%>" id="talla<%=i%>" maxlength="10"<%=viewMode?" readonly":""%> size="10%">
								 </div>
						</td>

			<td>
								<div class="form-group m-xs-2">
										<% if (cdoParam.getColValue("set_triage").trim().equals("S")){ %>
												<button name="setTriage" id="setTriage" type="button" class="btn btn-inverse btn-sm<%=viewMode?" disabled":""%>" onclick="setTriage('<%=i%>')"><b>Tria</b></button>
										<%}%>
								</div>
						</td>
						<td class="text-center" style="vertical-align: middle !important;">
								<%if(drn.getCodigo().equals("0") || drn.getUsuarioCreacion().trim().equals((String) session.getAttribute("_userName"))){%>
										<%=fb.submit("rem"+i,"x",viewMode,false,"",null,"onClick=\"removeItem(this.form.name,"+i+"); __submitForm(this.form, this.value)\"","Eliminar")%>
								<%}%>
						</td>
		</tr>

				<tr class="<%=color%>"<%=displayNote%>>

		<%if(!fg.trim().equals("HM")){%>
						<tr class=""<%=displayNote%>>
								<td colspan="6">
								<cellbytelabel id="15">Medicina y Tratamientos</cellbytelabel>
								<%=fb.textarea("medTrat"+i,drn.getMedTrat(),false,false,viewMode,0,3,2000,"form-control input-sm","width:100%","")%>
								</td>
								<td colspan="6">
								<cellbytelabel id="16">Notas de la enfermera</cellbytelabel>
								<%=fb.textarea("observacion"+i,drn.getObservacion(),false,false,viewMode,0,3,2000,"form-control input-sm","width:100%","")%>
								</td>
						</tr>
		<tr>

<td colspan="12" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" <%=displayNote%>>
<table width="100%" cellpadding="1" cellspacing="0">
<tr class="bg-headtabla">
<td >&nbsp;<cellbytelabel id="17">Otros Detalles</cellbytelabel></td>
<td width="37%" align="right" >[<font face="Courier New, Courier, mono">
	<label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
</tr>
</table>
</td>
</tr>

	<tr id="panel1">
	<td colspan="12">
	<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="<%=color%>"<%=displayNote%>>
						<td><strong class="pull-right"><cellbytelabel id="18">Evacuaci&oacute;n</cellbytelabel>:&nbsp;</strong></td>
						<td colspan="11">
						<%=fb.checkbox("evacuacion"+i,"S",drn.getEvacuacion().trim().equals("S"),viewMode,null,null,"")%>
&nbsp;&nbsp;&nbsp;<%=fb.textarea("evacuacionObs"+i, drn.getEvacuacionObs(), false, false, viewMode, 0, 1, "form-control input-sm", "width:75%", "")%></td>
</tr>

<tr class="<%=color%>" <%=displayNote%> >
<td width="12%" align="right"><strong class="pull-right"><cellbytelabel id="19">Micci&oacute;n</cellbytelabel>:&nbsp;</strong></td>
<td colspan="11"><%=fb.checkbox("miccion"+i,"S",drn.getMiccion().trim().equals("S"),viewMode,null,null,"")%>
&nbsp;&nbsp;&nbsp;<%=fb.textarea("miccionObs"+i, drn.getMiccionObs(), false, false, viewMode, 0, 1, "form-control input-sm", "width:75%", "")%></td>
</tr>

<tr class="<%=color%>"<%=displayNote%>>
<td><strong class="pull-right"><cellbytelabel id="20">V&oacute;mito</cellbytelabel>:&nbsp;</strong></td>
 <td colspan="11"><%=fb.checkbox("vomito"+i,"S",drn.getVomito().trim().equals("S"),viewMode,null,null,"")%>
 &nbsp;&nbsp;&nbsp;<%=fb.textarea("vomitoObs"+i, drn.getVomitoObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td>	 </tr>

<tr class="<%=color%>"<%=displayNote%>>
<td><strong class="pull-right"><cellbytelabel id="21">Dolor</cellbytelabel>:&nbsp;</strong></td>
<td><%=fb.select("dolor"+i,"S=Si,N=No",drn.getDolor(),false,viewMode,0,"form-control input-md",null,null)%>
&nbsp;&nbsp;</td>
<td colspan="10">&nbsp;</td>
	 </tr>


<tr class="<%=color%>"<%=displayNote%>>
<td align="right"><strong class="pull-right"><cellbytelabel id="22">Comida</cellbytelabel>:&nbsp;</strong></td>
<td>
		<%=fb.select("comida"+i,"D=Desayuno,A=Almuerzo,M=Merienda,C=Cena",drn.getComida(),false,viewMode,0,"form-control input-md",null,null)%>
</td>
<td><strong class="pull-right">Comi&oacute;?&nbsp;</strong></td>
<td><%=fb.select("comio"+i,"S=Si,N=No",drn.getComio(),false,viewMode,0,"form-control input-md",null,null)%></td>
<td><strong class="pull-right">Cantidad&nbsp;</strong></td>
<td>
	<%=fb.select("cantidad"+i,"0=Nada,1=1/4,2=1/2,3=1/3,4=Todo",drn.getCantidad(),false,viewMode,0,"form-control input-md",null,null)%>
</td>
<td colspan="6"></td>


</tr>


</table>
</td>
</tr>



<tr>
<td colspan="12" onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer" <%=displayNote%>>
<table width="100%" cellpadding="1" cellspacing="0">
<tr class="bg-headtabla">

<td>&nbsp;<cellbytelabel id="25">Diagnostico Enfermera (NANDA)</cellbytelabel></td>
<td width="37%" align="right" >[<font face="Courier New, Courier, mono">
	<label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
</tr>
</table>
</td>
</tr>

<tr  id="panel3">
	<td colspan="12">
	<table width="100%" cellpadding="1" cellspacing="1">
<tr id="panel3" class="<%=color%>" <%=displayNote%>>
<td colspan="12"><%=fb.select("diagnosticoEnf"+i,alDiag,drn.getDiagnosticoEnf(),false,(viewMode),0,"form-control input-md",null,null,"","S")%></td>
</tr>
<tr class="<%=color%>"<%=displayNote%>>
<td width="12%" align="left"><cellbytelabel id="26">Observaci&oacute;n</cellbytelabel></td>
<td width="38%" align="left" ><%=fb.textarea("comentario"+i, drn.getComentario(), false, false, viewMode, 0, 1, "form-control input-sm", "width:100%", "")%></td>
<td width="7%" align="center"><cellbytelabel id="27">Acci&oacute;n</cellbytelabel></td>
<td width="43%" ><%=fb.textarea("accion"+i, drn.getAccion(), false, false, viewMode, 0, 1, "form-control input-sm", "width:100%", "")%></td>
</tr>

</table>
</td>
</tr>
<%} else {%>
				<td colspan="2">
						<cellbytelabel id="15">Medicina y Tratamientos</cellbytelabel>
						<%=fb.textarea("medTrat"+i,drn.getMedTrat(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%>
				</td>
				<td colspan="1">
						<cellbytelabel id="28">Recormon(uds)</cellbytelabel>
						<%=fb.textarea("recormon"+i,drn.getRecormon(),false,false,viewMode,10,4,2000,"form-control input-sm","width:100%","")%>
				</td>
				<td colspan="4">
				<cellbytelabel id="16">Notas de la enfermera</cellbytelabel>
				<%=fb.textarea("observacion"+i,drn.getObservacion(),false,false,viewMode,60,4,2000,"form-control input-sm","width:100%","")%>


<%}%>
</tr>
		<%}else{%>
		<%=fb.hidden("fecha"+i,drn.getFecha())%>
		<tr align="center"<%=displayNote%>>
			<td class="controls form-inline">
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="horaR"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=drn.getHoraR()%>" />
				</jsp:include>
			</td>
			<td>
								 <div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getPArterial()%>" name="pArterial<%=i%>" id="pArterial<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getPulso()%>" name="pulso<%=i%>" id="pulso<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getRespiracion()%>" name="respiracion<%=i%>" id="respiracion<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getTemperatura()%>" name="temperatura<%=i%>" id="temperatura<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getFlujoSanguineo()%>" name="flujoSanguineo<%=i%>" id="flujoSanguineo<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getPVenosa()%>" name="pVenosa<%=i%>" id="pVenosa<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getUltrafijacion()%>" name="ultrafijacion<%=i%>" id="ultrafijacion<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td>
								<div class="form-group m-xs-2">
										<input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=drn.getPTransmembranica()%>" name="pTransmembranica<%=i%>" id="pTransmembranica<%=i%>" maxlength="10" size="10%">
								</div>
						</td>
			<td rowspan="2">
								<%if(drn.getCodigo().equals("0") || drn.getUsuarioCreacion().trim().equals((String) session.getAttribute("_userName"))){%>
								 <%=fb.submit("rem"+i,"x",viewMode,false,"",null,"onClick=\"removeItem(this.form.name,"+i+"); __submitForm(this.form, this.value)\"","Eliminar")%>
								<%}%>
			</td>
		</tr>
		<tr class="<%=color%>"<%=displayNote%>>
				<%if(!fg.trim().equals("HM")){%>
						<td colspan="4">
							<cellbytelabel id="15">Medicina y Tratamientos</cellbytelabel>
							<%=fb.textarea("medTrat"+i,drn.getMedTrat(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%>
						</td>
						<td colspan="5">
							<cellbytelabel id="16">Notas de la enfermera</cellbytelabel>
							<%=fb.textarea("observacion"+i,drn.getObservacion(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%>
						</td>
				<%}  else {%>
						<td colspan="3">
							<cellbytelabel id="15">Medicina y Tratamientos</cellbytelabel>
							<%=fb.textarea("medTrat"+i,drn.getMedTrat(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%>
						</td>
						<td width="7%">
							<cellbytelabel>Eritropoyetina (uds)</cellbytelabel>: <%=fb.textBox("recormon"+i,drn.getRecormon(),false,false,viewMode,2,20,"form-control input-sm",null,null)%>
			</td>
						<td width="5%" colspan="5">
							<cellbytelabel id="16">Notas de la enfermera</cellbytelabel>
							<%=fb.textarea("observacion"+i,drn.getObservacion(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%>
			</td>
				<%}%>
		</tr>

		<%}%>
<%
}
%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

	NotasEnfermeria ne = new NotasEnfermeria();
	ne.setPacId(pacId);
	ne.setSecuencia(noAdmision);
	ne.setFecNacimiento(request.getParameter("dob"));
	ne.setCodPaciente(request.getParameter("codPac"));
	ne.setFecha(request.getParameter("fecha"));
	ne.setHora(request.getParameter("hora"));
	if (baction != null && baction.trim().equalsIgnoreCase("Guardar"))ne.setHora(cDateTime.substring(11));
	if (modeSec.equalsIgnoreCase("edit")) ne.setId(request.getParameter("idNe"));
	ne.setUsuarioCreacion((String) session.getAttribute("_userName"));
	ne.setUsuarioModif((String) session.getAttribute("_userName"));
	if(fg.trim().equals("HM"))
	{
		ne.setNoHemodialisis(request.getParameter("noHemodialisis"));
		ne.setMaquina(request.getParameter("maquina"));
		ne.setFiltro(request.getParameter("filtro"));
		ne.setSolucion(request.getParameter("solucion"));
		ne.setPesoInicial(request.getParameter("pesoInicial"));
		ne.setPesoFinal(request.getParameter("pesoFinal"));
	}
	String ItemRemoved = "";
	for (int i=1; i<=size; i++)
	{

		System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::. REMOVE = "+request.getParameter("remove"+i));
		DetalleResultadoNota drn = new DetalleResultadoNota();

		drn.setCodigo(request.getParameter("codigo"+i));
		drn.setEstado(request.getParameter("estado"+i));
		drn.setFecha(request.getParameter("fecha"+i));
		drn.setHoraR(request.getParameter("horaR"+i));

		drn.setTemperatura(request.getParameter("temperatura"+i));
		drn.setPulso(request.getParameter("pulso"+i));
		drn.setPArterial(request.getParameter("pArterial"+i));
		drn.setRespiracion(request.getParameter("respiracion"+i));
		drn.setMedTrat(request.getParameter("medTrat"+i));
		drn.setObservacion(request.getParameter("observacion"+i));
		drn.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));

		if(request.getParameter("evacuacion"+i) != null )drn.setEvacuacion(request.getParameter("evacuacion"+i));
		else drn.setEvacuacion("N");
		drn.setEvacuacionObs(request.getParameter("evacuacionObs"+i));
		if(request.getParameter("miccion"+i) != null )drn.setMiccion(request.getParameter("miccion"+i));
		else drn.setMiccion("N");
		drn.setMiccionObs(request.getParameter("miccionObs"+i));
		if(request.getParameter("vomito"+i) != null )drn.setVomito(request.getParameter("vomito"+i));
		else drn.setVomito("N");
		drn.setVomitoObs(request.getParameter("vomitoObs"+i));

		drn.setDolor(request.getParameter("dolor"+i));
		drn.setComida(request.getParameter("comida"+i));
		drn.setComio(request.getParameter("comio"+i));

		drn.setCantidad(request.getParameter("cantidad"+i));


		drn.setAccion(request.getParameter("accion"+i));
		drn.setComentario(request.getParameter("comentario"+i));
		drn.setFCard(request.getParameter("fCard"+i));
		drn.setPCard(request.getParameter("pCard"+i));
		drn.setPeso(request.getParameter("peso"+i));
		drn.setTalla(request.getParameter("talla"+i));
		drn.setDiagnosticoEnf(request.getParameter("diagnosticoEnf"+i));
		drn.setUsuarioModificacion((String) session.getAttribute("_userName"));



		if(fg.trim().equals("HM"))
		{
			drn.setFlujoSanguineo(request.getParameter("flujoSanguineo"+i));
			drn.setPVenosa(request.getParameter("pVenosa"+i));
			drn.setPTransmembranica(request.getParameter("pTransmembranica"+i));
			drn.setUltrafijacion(request.getParameter("ultrafijacion"+i));
			drn.setRecormon(request.getParameter("recormon"+i));

		}

		drn.setCategoria("1");

		drn.setKey(request.getParameter("key"+i));
		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			ItemRemoved = key;
			drn.setEstado("D");
		}
		/*else
		{*/
			try
			{
				HashDet.put(key, drn);
				ne.addDetalleResultadoNota(drn);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		//}
	}

	if (!ItemRemoved.equals(""))
	{
		//HashDet.remove(ItemRemoved);
		response.sendRedirect("../expediente3.0/exp_notas_enfermeria_det.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo="+lastLineNo+"&change=1&defaultAction="+defaultAction);
		return;
	}
	if (baction != null && baction.trim().equalsIgnoreCase("+"))
	{
		DetalleResultadoNota drn = new DetalleResultadoNota();

		drn.setCodigo("0");
		drn.setEstado("A");
		String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
		drn.setFecha(cDate.substring(0,10));
		drn.setHoraR(cDate.substring(11));
		drn.setUsuarioCreacion((String) session.getAttribute("_userName"));
		drn.setEvacuacion("N");
		drn.setMiccion("N");
		drn.setVomito("N");


		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;
		drn.setKey(""+lastLineNo);

		try
		{
			HashDet.put(key, drn);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect("../expediente3.0/exp_notas_enfermeria_det.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo="+lastLineNo+"&change=1&defaultAction="+defaultAction);
		return;
	}

	if (baction != null && baction.trim().equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) NEMgr.add(ne);
		else if (modeSec.equalsIgnoreCase("edit")) NEMgr.update(ne);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
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

