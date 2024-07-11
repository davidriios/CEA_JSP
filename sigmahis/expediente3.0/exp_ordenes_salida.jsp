<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.OrdenMedicaMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="java.io.*"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iSalida" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
<jsp:useBean id="OrdMgr" scope="page" class="issi.expediente.OrdenMedicaMgr" />
<jsp:useBean id="om" scope="session" class="issi.expediente.OrdenMedica" />
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
OrdMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList alS = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String medico = request.getParameter("medico");
String docId = request.getParameter("docId");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (id == null) id = "";
if (from == null) from = "";
if (medico == null) medico = "";
if (docId == null) docId = "";
if (id.trim().equals("")) id = "0";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
int sLastLineNo =0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String tipoOrden ="7";
String cds ="";
String tipoSolicitud ="P";
String subTipo ="";
if (request.getParameter("sLastLineNo") != null) sLastLineNo = Integer.parseInt(request.getParameter("sLastLineNo"));
String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	String medCode = "", medName = "";
	if (from.equals("salida_pop")) {
		if (medico.trim().equals("")) {
			issi.admin.UserDetail mud = (issi.admin.UserDetail) sbb.getSingleRowBean(ConMgr.getConnection(),"select nvl(reg_medico,codigo) as refCodeDisplay, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as name from tbl_adm_medico where codigo = "+medico,issi.admin.UserDetail.class);
			medCode = mud.getRefCodeDisplay();
			medName = mud.getName();
		}
	} else if (UserDet.getRefType().equalsIgnoreCase("M")) {
		medico = UserDet.getRefCode();
		medCode = UserDet.getRefCodeDisplay();
		medName = UserDet.getName();
	}

	alS = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_orden_salida order by 1",CommonDataObject.class);

	sbSql.append("select distinct a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, (select descripcion from tbl_sal_desc_estado_ord where estado = b.estado_orden) as estado, (select '[ '||nvl(reg_medico,codigo)||' ] '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as medico from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id = b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.tipo_orden = 7 and a.pac_id = ").append(pacId).append(" and a.secuencia = ").append(noAdmision).append(" order by a.codigo desc");
	al2 = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),OrdenMedica.class);



	if (change == null)
	{
		om = new OrdenMedica();
		session.setAttribute("om",om);
		iSalida.clear();

		sbSql = new StringBuffer();
		sbSql.append("select distinct a.codigo as ordenMed, to_char(a.fecha,'dd/mm/yyyy') as fechaOrden, a.tipo_salida as tipoSalida, nvl(a.relevo,'N') as relevo from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id = b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.tipo_orden = 7 and a.pac_id = ").append(pacId).append(" and a.secuencia = ").append(noAdmision).append(" order by a.codigo desc");
		//System.out.println("sql ===  "+sbSql);
		om = (OrdenMedica) sbb.getSingleRowBean(ConMgr.getConnection(), sbSql.toString(), OrdenMedica.class);
		if(om == null)
		{
			om = new OrdenMedica();
			om.setTipoSalida("A");
			om.setRelevo("N");
		}
		if(!id.trim().equals("0"))
		{




		sbSql = new StringBuffer();
		sbSql.append("select cod_paciente, fec_nacimiento, secuencia, tipo_orden as tipoOrden, orden_med as ordenMed, codigo, nombre, to_char(fecha_inicio,'dd/mm/yyyy hh12:mi am') as fechaInicio, nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') as fechaFin, observacion, ejecutado, centro_servicio, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion, tipo_dieta as tipoDieta, cod_tipo_dieta as codTipoDieta, tipo_tubo as tipoTubo, fecha_orden, omitir_orden, pac_id, fecha_suspencion, obser_suspencion, estado_orden, cod_salida as codSalida from tbl_sal_detalle_orden_med where tipo_orden = 7 and pac_id = ").append(pacId).append(" and secuencia = ").append(noAdmision).append(" and orden_med = ").append(id);
		//System.out.println("sql det ===  "+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleOrdenMed.class);

		sLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			try
			{
				iSalida.put(key, al.get(i-1));//iInter.put(key, al.get(i-1));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		}
		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			DetalleOrdenMed detOrd  = new DetalleOrdenMed();

			detOrd.setCodigo("0");
			detOrd.setTipoSolicit(""+tipoSolicitud);
			detOrd.setTipoOrden(""+tipoOrden);
			detOrd.setCentroServicio(""+cds);
			detOrd.setFechaInicio(cDateTime);
			detOrd.setCodSalida("1");

			detOrd.setFechaFin(cDateTime);
			detOrd.setFechaOrden(cDateTime.substring(0,10));
			sLastLineNo++;
			if (sLastLineNo < 10) key = "00" + sLastLineNo;
			else if (sLastLineNo < 100) key = "0" + sLastLineNo;
			else key = "" + sLastLineNo;
			detOrd.setKey(""+key);

			try
			{
				iSalida.put(key, detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//else if (!viewMode) mode = "edit";
	}//change=null

%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Ordenes Medicas de Salida - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){
	document.getElementById("admMedCode").innerHTML=parent.document.paciente.reg_medico.value;
	document.getElementById("admMedName").innerHTML=parent.document.paciente.nombreMedico.value;
<% if (UserDet.getUserProfile().contains("0")) { %>
	document.form0.medico.value=parent.document.paciente.medico.value;
	document.getElementById("medCode").innerHTML=parent.document.paciente.reg_medico.value;
	document.getElementById("medName").innerHTML=parent.document.paciente.nombreMedico.value;
<% } %>
	checkViewMode();
}
function setEvaluacion(code){window.location = '../expediente3.0/exp_ordenes_salida.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&id='+code;}
function add(){window.location = '../expediente3.0/exp_ordenes_salida.jsp?modeSec=add&mode=<%=mode%>&from=<%=from%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0';}
function imprimirOrden(){abrir_ventana1('../expediente/print_exp_seccion_75.jsp?pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&tipoOrden=7');}
function ordenSAlida(){var dia = getDBData('<%=request.getContextPath()%>','sysdate from dual ','dual','','');window.location = '../expediente3.0/exp_ordenes_salida.jsp?modeSec=add&mode=<%=mode%>&from=<%=from%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0';}
function setValidDate(k){var fecha = '<%=cDateTime.substring(0,10)%>';var fechaFin = eval('document.form0.fechaFin'+k).value ;var id = getDBData('<%=request.getContextPath()%>','(case when  to_date(\''+fechaFin.substring(0,10)+'\',\'dd/mm/yyyy\') between to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')  and to_date(to_char(sysdate+1,\'dd/mm/yyyy\'),\'dd/mm/yyyy\') and to_date(\''+fechaFin+'\',\'dd/mm/yyyy hh12:mi am\') >= to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')   then 0 else 1 end  ) as id/*,to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')*/','dual','','');if(id !='0'){alert('Estimado Usuario: Segun normas JCI no es permitido Dar salida en esta fecha. Verifique!');eval('document.form0.fechaFin'+k).value = '';return false;}else return true;}
function checkSalida(val){
	var tot, selVal;
	if( val != undefined ){
		tot = getDBData('<%=request.getContextPath()%>','count(*) total','tbl_sal_detalle_orden_med',"pac_id = <%=pacId%> and secuencia = <%=noAdmision%> and tipo_orden = 7 and estado_orden not in ('O','S') and cod_salida = "+val,'');if ( tot > 0 ){alert("Lo sentimos, pero esta opción ya ha sido usada para ese paciente!");return false;}else{return true;}
	}
	else if(!validateReqSeccion()) {
		form0BlockButtons(false); return false;
	 }
	else{
		for ( i = 1; i<=<%=iSalida.size()%>; i++ ){selVal = document.getElementById("codSalida"+i).value;if(selVal =='1'){if(!confirm('Al finalizar la atención el Expediente ya no estará disponible para modificaciones. ¿Está seguro que desea finalizar?')) return false;}tot = getDBData('<%=request.getContextPath()%>','count(*) total','tbl_sal_detalle_orden_med',"pac_id = <%=pacId%> and secuencia = <%=noAdmision%> and tipo_orden = 7 and estado_orden not in ('O','S') and cod_salida = "+selVal,'');if ( tot > 0 ){alert("Lo sentimos, pero esta opción ya ha sido usada para ese paciente!");break;return false;}else{return true;}}
	}
}

function validateReqSeccion() {
	var $indicator = $("#indicator");
	$indicator.html("Validando secciones mandatorias para cerrar el expediente...");
	var w = "codigo in(select secc_code from tbl_sal_exp_docs_secc where req_para_cerrar = 'Y' and doc_id in ( select doc_id from tbl_sal_exp_docs_profile where profile_id IN (<%=profiles%>)) and doc_id = <%=docId%>)";
	var d = getDBData('<%=request.getContextPath()%>','table_name, where_clause, descripcion','tbl_sal_expediente_secciones', w);
	var rows = splitRowsCols(d);

	for (var i = 0; i < rows.length; i++) {
		var table = rows[i][0];
		var where = rows[i][1];
		var name = rows[i][2];

		where = where.replace(/@@PACID/g, '<%=pacId%>').replace(/@@ADMISION/g, '<%=noAdmision%>');

		if (where.includes("@@FCF") && where.includes("@@FCT")) {
			 where = where.replace(/@@FCF/g, '(select trunc(fecha_ingreso) from tbl_adm_admision where pac_id = <%=pacId%> and secuencia = <%=noAdmision%>)').replace(/@@FCT/g, 'trunc(sysdate)');
		}

		if (table && where) {
			var res = getDBData('<%=request.getContextPath()%>','count(*)', table, where);

			if (!parseInt(res)) {
				 $indicator.css("color", "red").html("[ERROR] No se puede cerrar el Expediente sin antes llenar la sección: "+name);
				 form0BlockButtons(false);
				 return false;
			}
		}
	} // for

	$indicator.html("");
	return true;
}
</script>
<style>
#indicator {
margin-right: 20px;
font-weight: bold;
}
</style>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body class="body-forminside" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' && document."+fb.getFormName()+".baction.value!='Siguiente')return true;");%>
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
<%=fb.hidden("dietaSize",""+iSalida.size())%>
<%=fb.hidden("sLastLineNo",""+sLastLineNo)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("medico",medico)%>
<%=fb.hidden("docId",docId)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".medico.value.trim()==''){alert('Médico O/M inválido!');error++;}");%>

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
		<td>
				<%if(!mode.trim().equals("view")){%>
					<%=fb.button("btnAdd","Agregar Orden",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick='add()'")%>
				<%}%>
				<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirOrden()\"")%>
		</td>
</tr>
<tr><th class="bg-headtabla">Listado de Ordenes</th></tr>
</table>

<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
		<tr class="bg-headtabla2">
		<th>&nbsp;</td>
		<th><cellbytelabel>C&oacute;digo</cellbytelabel></th>
		<th><cellbytelabel>Fecha</cellbytelabel></th>
		<th><cellbytelabel>M&eacute;dico</cellbytelabel></th>
		<th><cellbytelabel>Estado</cellbytelabel></th>
		<th>&nbsp;</th>
</tr>
</thead>
<tbody>
<%
for (int i=1; i<=al2.size(); i++)
{
	OrdenMedica o = (OrdenMedica) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,o.getCodigo())%>
		<tr onClick="javascript:setEvaluacion(<%=o.getCodigo()%>)" style="text-decoration:none; cursor:pointer">
						<td><%=i%></td>
						<td><%=o.getCodigo()%></td>
						<td><%=o.getFecha()%></td>
						<td><%=o.getMedico()%></td>
						<td><%=o.getEstado()%></td>
						<td>&nbsp;</td>
		</tr>
<%}%>

</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<tr class="bg-headtabla">
	<th>M&eacute;dico Adm.: [ <label id="admMedCode"></label> ] <label id="admMedName"></label></th>
	<th colspan="2">M&eacute;dico O/M: [ <label id="medCode"><%=medCode%></label> ] <label id="medName"><%=medName%></label></th>
</tr>
<tr class="bg-headtabla">
		<th colspan="3">
		<label>
		<%=fb.radio("tipoSalida","A",(om.getTipoSalida()!=null && om.getTipoSalida().trim().equals("A") ),viewMode,false)%>
		<cellbytelabel id="7">AUTORIZADA</cellbytelabel>
		</label>
		&nbsp;&nbsp;&nbsp;
		<label>
		<%=fb.radio("tipoSalida","V",(om.getTipoSalida()!=null && om.getTipoSalida().trim().equals("V") ),viewMode,false)%>
		<cellbytelabel id="8">VOLUNTARIA</cellbytelabel>
		</label>
		&nbsp;
		<label>
		<%=fb.checkbox("relevo","S",(om.getRelevo().equalsIgnoreCase("S")),viewMode,null,null,"")%>
		<cellbytelabel id="9">¿Paciente Firm&oacute; formulario de relevo de responsabilidad.??</cellbytelabel>
		</label>
		&nbsp;&nbsp;&nbsp;
		<label>
		<%=fb.radio("tipoSalida","D",(om.getTipoSalida()!=null && om.getTipoSalida().trim().equals("D") ),viewMode,false)%>
		<cellbytelabel id="10">DEFUNCI&Oacute;N</cellbytelabel>
		</label>
		</td>
</tr>

<tr class="bg-headtabla2">
		 <th><cellbytelabel id="11">Descripci&oacute;n</cellbytelabel></th>
		 <th><cellbytelabel id="12">Observaciones</cellbytelabel></th>
		 <th class="text-center">
				<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,null)%>
		 </th>
</tr>
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iSalida);
for (int i=1; i<=iSalida.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iSalida.get(key);
	if((!detOrd.getCodigo().trim().equals("")) && !detOrd.getCodigo().trim().equals("0"))
	isReadOnly =true;
	else isReadOnly =false;

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha"+i,detOrd.getFechaOrden())%>
			<%=fb.hidden("codigo"+i,detOrd.getCodigo())%>
						<%=fb.hidden("desc",desc)%>

<tr>
				<td class="controls form-inline">
				<%=fb.select("codSalida"+i,alS,detOrd.getCodSalida(),false,(viewMode||isReadOnly),0,"form-control input-sm",null,"onchange=\"checkSalida(this.value);\"")%>

								<%if(detOrd.getCodSalida()!=null && !detOrd.getCodSalida().trim().equals("") && detOrd.getCodSalida().trim().equals("1")){%>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
								<jsp:param name="nameOfTBox1" value="<%="fechaFin"+i%>" />
								<jsp:param name="jsEvent" value="<%="javascript:setValidDate("+i+")"%>" />
								<jsp:param name="valueOfTBox1" value="<%=detOrd.getFechaFin()%>" />
								<jsp:param name="readonly" value="<%=(viewMode||isReadOnly)?"y":"n"%>"/>
								</jsp:include>
					<%}else {%>
					<%=fb.hidden("fechaFin"+i,"")%>
					<%}%>
									</td>
				<td><%=fb.textarea("observacion"+i,detOrd.getObservacion(),true,false,(viewMode||isReadOnly),45,0,2000,"form-control input-sm","width:100%","")%></td>

				<td class="text-center">
					<%=fb.submit("rem"+i,"x",true,isReadOnly||viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:removeItem(this.form.name,"+i+")\"")%>
								</td>
			</tr>

<%
}
fb.appendJsValidation("if(!checkSalida()){ error++;}");
fb.appendJsValidation("if(error>0)doAction();");
%>
</table>

<div class="footerform">
		 <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">

		<tr>
			<td>
				<span id="indicator"></span>
				<%=fb.hidden("saveOption","O")%>
				<%=(UserDet.getUserProfile().contains("0") || UserDet.getRefType().trim().equalsIgnoreCase("M") || UserDet.getXtra5().trim().equalsIgnoreCase("S"))?fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null):""%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>

		</table>
		</div>
		<%=fb.formEnd(true)%>
		</div>

		<!-- FIN contenido del sitio aqui-->
		</div>


</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int size = 0;
	if (request.getParameter("dietaSize") != null)
	size = Integer.parseInt(request.getParameter("dietaSize"));

		System.out.println("::::::::::::::::::::::::::::::::::::::: baction = "+baction);

	al.clear();
	om.setPacId(request.getParameter("pacId"));
	om.setCodPaciente(request.getParameter("codPac"));
	om.setFecNacimiento(request.getParameter("dob"));
	om.setSecuencia(request.getParameter("noAdmision"));
	om.setFecha(cDateTime.substring(0,10));
	om.setMedico(request.getParameter("medico"));
	om.setUsuarioCreacion((String) session.getAttribute("_userName"));
	om.setFechaCreacion(cDateTime);
	om.setUsuarioModif((String) session.getAttribute("_userName"));
	om.setTelefonica("N");
	om.setTipoSolicitud(""+tipoSolicitud);
	om.setTipoSalida(request.getParameter("tipoSalida"));

	if (request.getParameter("relevo") != null && request.getParameter("relevo").equalsIgnoreCase("S"))
	om.setRelevo(request.getParameter("relevo"));

	//om.setFechaCreacion(cDateTime);
om.getDetalleOrdenMed().clear();
	iSalida.clear();
	for (int i=1; i<=size; i++)
	{
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setKey(request.getParameter("key"+i));
		detOrd.setCodigo(request.getParameter("codigo"+i));
		detOrd.setFechaOrden(request.getParameter("fecha"+i));

		detOrd.setObservacion(request.getParameter("observacion"+i));
		//detOrd.setNombre(request.getParameter("nombre"+i));
		detOrd.setFechaFin(request.getParameter("fechaFin"+i));
		detOrd.setFechaInicio(cDateTime);

		detOrd.setTipoSolicit(tipoSolicitud);
		//detOrd.setCentroServicio(""+cds);
		detOrd.setTipoOrden(""+tipoOrden);
		detOrd.setEstado("A");
		detOrd.setCodSalida(request.getParameter("codSalida"+i));


		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = key;
		else
		{
			try
			{
				iSalida.put(key,detOrd);
				om.getDetalleOrdenMed().add(detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for

	if (!itemRemoved.equals(""))
	{
		iSalida.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setCodigo("0");
		detOrd.setFechaOrden(cDateTime.substring(0,10));
		detOrd.setFechaInicio(cDateTime);
		sLastLineNo++;
		if (sLastLineNo < 10) key = "00" + sLastLineNo;
		else if (sLastLineNo < 100) key = "0" + sLastLineNo;
		else key = "" + sLastLineNo;
		detOrd.setKey(key);
		try
		{
			iSalida.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("Siguiente"))
	{

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equals("add"))
		{
				OrdMgr.addOrden(om);
				id = OrdMgr.getPkColValue("id");
		}
		ConMgr.clearAppCtx(null);


	}
	session.removeAttribute("om");
	session.removeAttribute("iSalida");

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (OrdMgr.getErrCode().equals("1"))
{
%>
		<%if(from.equals("")){%>alert('<%=OrdMgr.getErrMsg()%>');<%}%>
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
	<%if(from.equals("salida_pop")){%>
	<%}else{%>
		parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
		<%}%>

<%
	}
	else
	{
%>
	<%if(from.equals("salida_pop")){%>
	<%}else{%>
		parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
	<%}%>
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
} else throw new Exception(OrdMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>&medico=<%=medico%>&docId=<%=docId%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

