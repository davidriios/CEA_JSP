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
<jsp:useBean id="SQLMgr" scope="session" class="issi.admin.SQLMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iOrdenes" scope="session" class="java.util.Hashtable" />
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
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String medico = request.getParameter("medico");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (id == null) id = "";
if (from == null) from = "";
if (id.trim().equals("")) id = "0";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
int sLastLineNo =0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String tipoOrden ="8";
String cds ="";
String tipoSolicitud ="P";
String subTipo ="";
if (request.getParameter("sLastLineNo") != null) sLastLineNo = Integer.parseInt(request.getParameter("sLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
		 sql = "select unique a.codigo ordenMed,to_char(a.fecha,'dd/mm/yyyy') fechaOrden, (select m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre) || ' ' ||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = a.medico ) as nombre from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id=b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.tipo_orden = 8  and a.pac_id="+pacId+" and a.secuencia="+noAdmision+" order by a.codigo desc" ;
		 al2 = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);

		StringBuilder sb = new StringBuilder();

		sb.append(" select ");
		sb.append(" o.tipo_ordenvarios tipoOrdenVarios, ");
		sb.append(" o.subtipo_ordenvarios subTipoOrdenVarios, ");
		sb.append(" o.tipo_orden tipoOrden, o.orden_med ordenMed, o.codigo, o.nombre, o.centro_servicio, ");
		sb.append(" h.codigo as header_code, h.descripcion as header_desc, s.codigo as sub_code, s.descripcion as sub_desc ");
		sb.append(" from TBL_CDS_ORDENMEDICA_VARIOS h ");
		sb.append(" inner join TBL_CDS_OM_VARIOS_SUBTIPO s on s.COD_TIPO_ORDENVARIOS = h.codigo ");
		if(id.trim().equals("0")) {
			sb.append(" and h.estatus = 'A' ");
		}
		sb.append(" left join tbl_sal_detalle_orden_med o on o.tipo_ordenvarios = h.codigo and o.subtipo_ordenvarios = s.codigo ");
		sb.append(" and o.tipo_orden = 8 ");
		sb.append(" and o.pac_id = ");
		sb.append(pacId);
		sb.append(" and o.secuencia = ");
		sb.append(noAdmision);
		sb.append(" and o.orden_med = ");
		sb.append(id);
		sb.append(" order by h.codigo, s.codigo");

		sql = sb.toString();

		al = SQLMgr.getDataList(sql);
%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Ordenes Medicas Varias - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){document.form0.medico.value = '<%=from.equals("salida_pop")?medico:((UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"")%>';checkViewMode();setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function setEvaluacion(code){window.location = '../expediente3.0/exp_ordenes_varias.jsp?modeSec=view&mode=<%=mode%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id='+code;}
function add(){window.location = '../expediente3.0/exp_ordenes_varias.jsp?modeSec=add&mode=<%=mode%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&from=<%=from%>&medico=<%=medico%>';}

function imprimirOrden(id){
	if(id) abrir_ventana1('../expediente/print_list_ordenmedica.jsp?fg=OV&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipoOrden=8&desc=<%=desc%>&id='+id);
	else abrir_ventana1('../expediente/print_list_ordenmedica.jsp?fg=OV&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipoOrden=8&desc=<%=desc%>');
}

function consultas(){
	abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=8&interfaz=');
}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}

function verHistorial() {
	$("#hist_container").toggle();
}

function canSubmit () {
	if ( !$("#nombreMedico").val() || ! $(".subTipoVarios:checked").length ) return false;

	return true;
}


$(function(){
	$(".subTipoVarios").click(function(){
		var self = $(this);
		var i = self.data('i');
		var $nombre = $("#nombre"+i);

		if (self.is(":checked")) $nombre.prop('readonly', false);
		else $nombre.prop('readonly', true).val('');
	});
	// toggle details
	 $(".areas-header").click(function(c){
			var that = $(this);
			var area = that.data('area');
			$("#area-det-"+area).toggle()
	 });
});
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
 <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
<%=fb.hidden("dietaSize",""+al.size())%>
<%=fb.hidden("sLastLineNo",""+sLastLineNo)%>
<%=fb.hidden("medico",medico)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("formaSolicitud","")%>
<%fb.appendJsValidation("if(!canSubmit()) {error++; return false;}");%>
<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
		<tr>
				<td>
				<%=fb.button("btnConsulta","Consultar",false,false,"btn btn-inverse btn-sm|fa fa-search fa-printico",null,"onclick='consultas()'")%>
				<%if(!mode.trim().equals("view")){%>
					<%=fb.button("btnAdd","Agregar Orden",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick='add()'")%>
				<%}%>
				<%if(modeSec.trim().equalsIgnoreCase("view")){%>
					<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirOrden("+id+")\"")%>
				<%}if(al2.size()>0){%>
					<%=fb.button("btnPrintAll","Imprimir Todo",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirOrden()\"")%>
					<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:verHistorial()\"")%>
				<%}%>
				</td>
		</tr>
</table>

<div class="table-wrapper" id="hist_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
		<tr class="bg-headtabla2">
				<th><cellbytelabel id="5">C&oacute;digo</cellbytelabel></th>
				<th><cellbytelabel id="6">Fecha</cellbytelabel></th>
				<th><cellbytelabel id="7">M&eacute;dico</cellbytelabel></th>
		</tr>
</thead>
<tbody>
<%
String cod = "";

for (int i=1; i<=al2.size(); i++)
{
	DetalleOrdenMed det1 = (DetalleOrdenMed) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if(!det1.getOrdenMed().equals(cod)){
%>
		<tr onClick="javascript:setEvaluacion(<%=det1.getOrdenMed()%>)" style="text-decoration:none; cursor:pointer">
				<td><%=det1.getOrdenMed()%></td>
				<td><%=det1.getFechaOrden()%></td>
				<td><%=det1.getNombre()%></td>
		</tr>
<%

	}
cod = det1.getOrdenMed();
}%>

</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered">
 <tr class="TextRow01">
			<td colspan="3" class="controls form-inline"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>	&nbsp;&nbsp;&nbsp;Usuario que Recibe, Transcribe, lee y Confirma:
					<%=fb.textBox("userCrea",UserDet.getName(),true, false,true,15,"form-control input-sm","","")%>
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,25,"form-control input-sm","","")%>
				<%=fb.button("btnMed","...",false,viewMode,"btn btn-inverse btn-sm|fa fa-ellipsis-h fa-printico",null,"onClick=\"javascript:showMedicList()\"")%>
				</td>
	</tr>
<tr class="bg-headtabla2">
		<th width="30%"><cellbytelabel id="9">SubTipo</cellbytelabel></th>
		<th width="70%"><cellbytelabel id="11">Descripci&oacute;n</cellbytelabel> <%//=al.size()%></th>
</tr>
<%
String group = "";
boolean isReadOnly = false;
int x = 1;
for (int i=1; i<=al.size(); i++)
{
	key = al.get(i-1).toString();
	//DetalleOrdenMed detOrd = (DetalleOrdenMed) iOrdenes.get(key);
	CommonDataObject detOrd = (CommonDataObject) al.get(i-1);
	//if(detOrd.getCodigo() != null && !detOrd.getCodigo().trim().equals("") && !detOrd.getCodigo().trim().equals("0")) isReadOnly =true;
	if(detOrd.getColValue("codigo") != null && !detOrd.getColValue("codigo").trim().equals("") && !detOrd.getColValue("codigo").trim().equals("0")) isReadOnly =true;
	else isReadOnly =false;

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha"+i, detOrd.getColValue("fechaOrden", cDateTime.substring(0,10)))%>
			<%=fb.hidden("codigo"+i, detOrd.getColValue("codigo"))%>
			<%=fb.hidden("tipoVarios"+i, detOrd.getColValue("header_code"))%>

<%
if ( !group.equals(detOrd.getColValue("header_code")) ) {
%>
<% if (i > 1) { %>
			</table>
		</td>
	</tr>
<% } %>
	<tr class="bg-headtabla pointer areas-header" data-area="<%=detOrd.getColValue("header_code")%>">
		<td colspan="2">Tipo: <%=detOrd.getColValue("header_desc")%></td>
	</tr>
	<tr style="display:none" id="area-det-<%=detOrd.getColValue("header_code")%>">
		<td colspan="2">
			<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<%
x = 1;
} else x++;
%>

<tr class="<%=color%>">
	<td width="30%">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label>
		<%=fb.checkbox("subTipoVarios"+i,detOrd.getColValue("sub_code"),detOrd.getColValue("sub_code").equals(detOrd.getColValue("subTipoOrdenVarios")),viewMode||isReadOnly,"subTipoVarios",null,"onClick=\"javascript:isChecked("+i+")\"",null," data-i=\""+i+"\"")%>
			<%=detOrd.getColValue("sub_desc")%>
		</label>
	</td>

	<td width="70%">
	 <%=fb.textarea("nombre"+i,detOrd.getColValue("nombre"),false,false,(viewMode||isReadOnly||detOrd.getColValue("nombre").equals("")),44,1,2000,"form-control input-sm","width:100%","")%>
	</td>
</tr>
<%


group = detOrd.getColValue("header_code");
}
%>
<% if (al.size() > 0) { %>
			</table>
		</td>
	</tr>
<% } %>
</table>

<%
fb.appendJsValidation("if(error>0)doAction();");
%>

<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int size = 0;
	if (request.getParameter("dietaSize") != null)
	size = Integer.parseInt(request.getParameter("dietaSize"));

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
	om.setFormaSolicitud(request.getParameter("formaSolicitud"));

	om.getDetalleOrdenMed().clear();
	iOrdenes.clear();

	for (int i=1; i<=size; i++) {
			if (request.getParameter("subTipoVarios"+i) != null) {
				DetalleOrdenMed detOrd = new DetalleOrdenMed();

				detOrd.setKey(request.getParameter("key"+i));
				detOrd.setCodigo(request.getParameter("codigo"+i));
				detOrd.setFechaOrden(request.getParameter("fecha"+i));

				detOrd.setNombre(request.getParameter("nombre"+i));
				detOrd.setFechaInicio(cDateTime);

				detOrd.setTipoOrden(tipoOrden);
				detOrd.setEstado("A");
				detOrd.setTipoOrdenVarios(request.getParameter("tipoVarios"+i));
				detOrd.setSubTipoOrdenVarios(request.getParameter("subTipoVarios"+i));

				key = request.getParameter("key"+i);

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = key;
			else{
				try
				{
					iOrdenes.put(key,detOrd);
					om.getDetalleOrdenMed().add(detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//End else
		}
	}//for

	if (!itemRemoved.equals(""))
	{
		iOrdenes.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&from="+from+"&medico="+medico);
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
			iOrdenes.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&from="+from+"&medico="+medico);
		return;
	}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equals("add"))
		{
				OrdMgr.addOrden(om);
				id = OrdMgr.getPkColValue("id");
		}
		ConMgr.clearAppCtx(null);
	}

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
	alert('<%=OrdMgr.getErrMsg()%>');
<%	session.removeAttribute("om");
	session.removeAttribute("iOrdenes");

	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
	<%if(from.trim().equals("")){%>
	if(parent.window.opener) parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
		<%}%>
<%
	}
	else
	{
%>
	<%if(from.trim().equals("")){%>
		if(parent.window.opener) parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&medico=<%=medico%>&from=<%=from%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
