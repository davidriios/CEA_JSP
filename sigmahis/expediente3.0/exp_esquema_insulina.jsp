<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.EsquemaInsulinaMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEsquema" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
<jsp:useBean id="EIMgr" scope="page" class="issi.expediente.EsquemaInsulinaMgr" />
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
EIMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo =new CommonDataObject();
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
if (id.trim().equals("")) id = "0";
if (from == null) from = "";
if (medico == null) medico = "";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String tipoOrden ="8";
String cds ="";
String tipoSolicitud ="P";
String subTipo ="";
int sLastLineNo =0;
if (request.getParameter("sLastLineNo") != null) sLastLineNo = Integer.parseInt(request.getParameter("sLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{

ArrayList alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where status='A' and tipo_liquido='D' order by descripcion",CommonDataObject.class);


if(desc==null){cdo= (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	sql = "select distinct id codigo ,to_char(fecha,'dd/mm/yyyy hh12:mi am') fechaOrden, insulina nombre, decode(tipo,1,'RAPIDA',2,'LENTA', ' ') tipoInsulina, (select descripcion from tbl_sal_via_admin where codigo = via) as via from tbl_sal_esquema_insulina where  pac_id="+pacId+" and admision="+noAdmision+" order by id desc";
		al2 = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);
	if (change == null)
	{
		om = new OrdenMedica();
		session.setAttribute("om",om);
		iEsquema.clear();

		if(!id.trim().equals("0"))
		{

		sql = "select to_char(fecha,'dd/mm/yyyy') fechaOrden,codigo,escala descripcion,valor cantidad,insulina nombre, nvl(tipo,0) as tipoInsulina,forma_solicitud, via from tbl_sal_esquema_insulina where  pac_id="+pacId+" and admision="+noAdmision+" and id ="+id;
		System.out.println("sql det ===  "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);

		sLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			try
			{
				iEsquema.put(key, al.get(i-1));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		if (!viewMode) modeSec = "edit";
		}
		if (al.size() == 0)
		{
				if (!viewMode) modeSec = "add";

				DetalleOrdenMed detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("    <= 150 ");
				detOrd.setCantidad("0 UNIDADES");
				detOrd.setTipoInsulina("0");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("151 - 200 ");
				detOrd.setCantidad("2 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("201 - 250 ");
				detOrd.setCantidad("4 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("251 - 300 ");
				detOrd.setCantidad("8 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("   > 300 ");
				detOrd.setCantidad("10 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		}
	}//change=null

%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Esquema de Insulina - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){document.form0.medico.value = '<%=from.equals("salida_pop")?medico:((UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"")%>';checkViewMode();var val = $("input[name='formaSolicitudX']:checked").val();setFormaSolicitud(val);}
function setEvaluacion(code){window.location = '../expediente3.0/exp_esquema_insulina.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&desc=<%=desc%>&id='+code;}
function add(){window.location = '../expediente3.0/exp_esquema_insulina.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&from=<%=from%>&medico=<%=medico%>&desc=<%=desc%>';}
function imprimirOrden(){abrir_ventana1('../expediente3.0/print_exp_seccion_79.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipoOrden=8&id=<%=id%>&desc=<%=desc%>&exp=3.0');}

function canSubmit() {
	var proceed = true;
	if($("#tipo_insulina").val() == '0') {
		proceed = false;
		parent.CBMSG.error('Por favor escoge el tipo de Insulina!');
	} else if ( !$("#via_administracion").val()) {
	proceed = false;
		parent.CBMSG.error('Por favor escoge la vía de administración!');
	}
	return proceed;
}

$(function(){
		$("#tipo_insulina").change(function(){
				if(this.value == '2') {
					$(".can-be-hidden").hide();
				} else {
					$(".can-be-hidden").show();
				}
		});
});
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body class="body-forminside" onLoad="javascript:doAction()">
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
		<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("esSize",""+iEsquema.size())%>
		<%=fb.hidden("sLastLineNo",""+sLastLineNo)%>
		<%=fb.hidden("medico", medico)%>
	<%=fb.hidden("from",from)%>
		<%=fb.hidden("id",""+id)%>
		<%=fb.hidden("desc",desc)%>
	<%=fb.hidden("formaSolicitud","")%>

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
		<tr>
				<td>
						<%if(!mode.trim().equals("view")){%>
							<%=fb.button("btnAdd","Agregar Esquema",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onClick=\"javascript:add()\"")%>
						<%}%>

						<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirOrden()\"")%>
				</td>
		</tr>
		<tr><th class="bg-headtabla">Listado de Esquema de Insulina</th></tr>
</table>

<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
		<tr class="bg-headtabla2">
				<th><cellbytelabel id="5">C&oacute;digo</cellbytelabel></th>
				<th><cellbytelabel id="5">Fecha</cellbytelabel></th>
				<th><cellbytelabel id="5">Tipo Insulina</cellbytelabel></th>
				<th><cellbytelabel id="5">Insulina</cellbytelabel></th>
				<th><cellbytelabel id="5">V&iacute;a</cellbytelabel></th>
		</tr>
</thead>
<tbody>
<%
for (int i=1; i<=al2.size(); i++)
{
	DetalleOrdenMed det1 = (DetalleOrdenMed) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr onClick="javascript:setEvaluacion(<%=det1.getCodigo()%>)">
				<td><%=det1.getCodigo()%></td>
				<td><%=det1.getFechaOrden()%></td>
				<td><%=det1.getTipoInsulina()%></td>
				<td><%=det1.getNombre()%></td>
				<td><%=det1.getVia()%></td>
		</tr>
<%}%>

</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iEsquema);
for (int i=1; i<=iEsquema.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iEsquema.get(key);

if(i==1)
{%>
<tr class="TextRow01">
			<td colspan="3" class="controls form-inline"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
				<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>&nbsp;&nbsp;&nbsp;Usuario que Recibe, Transcribe, lee y Confirma:
					<%=fb.textBox("userCrea",UserDet.getName(),true, false,true,15,"form-control input-sm","","")%>
				&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,25,"form-control input-sm","","")%>
				<%=fb.button("btnMed","...",false,viewMode,"btn btn-inverse btn-sm|fa fa-ellipsis-h fa-printico",null,"onClick=\"javascript:showMedicList()\"")%>
				</td>
		</tr>
<tr>
		 <td class="controls form-inline" colspan="3">
				Tipo insulina&nbsp;&nbsp;
				<%=fb.select("tipo_insulina","0=-SELECCIONE-,1=RÁPIDA,2=LENTA", detOrd.getTipoInsulina(),false,viewMode,0,"form-control input-sm",null,null)%>
				<%=fb.textBox("insulina",detOrd.getNombre(),false,false,(viewMode||isReadOnly),50,100,"form-control input-sm",null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				V&iacute;a de Administraci&oacute;n&nbsp;&nbsp;
				<%=fb.select("via_administracion",alViaAd, detOrd.getVia(), false,viewMode,0,"form-control input-sm",null,null,"","S")%>
		 </td>
</tr>

<tr class="bg-headtabla2<%=!id.trim().equals("0")&&detOrd.getTipoInsulina().equals("2")?" hidden":" can-be-hidden"%>">
 <th><cellbytelabel id="6">Escala</cellbytelabel></th>
 <th><cellbytelabel id="7">Valor</cellbytelabel></th>
 <th class="text-center" style="vertical-align: middle !important;">

	<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,null)%>



 </th>
</tr>

<%
}


	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>

			<tr class="<%=!id.trim().equals("0")&&detOrd.getTipoInsulina().equals("2")?" hidden":" can-be-hidden"%>">
				<td width="35%"><%=fb.textBox("nombre"+i,detOrd.getDescripcion(),false,false,(viewMode||isReadOnly),20,30,"form-control input-sm",null,null)%></td>
				<td width="60%"><%=fb.textBox("cantidad"+i,detOrd.getCantidad(),false,false,(viewMode||isReadOnly),20,30,"form-control input-sm",null,null)%></td>

				<td width="5%">
								<%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:removeItem(this.form.name,"+i+")\"")%>
								</td>
			</tr>
<%
}
//fb.appendJsValidation("if(error>0)doAction();");
%>
</table>

<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
		</table> </div>


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
	if (request.getParameter("esSize") != null)
	size = Integer.parseInt(request.getParameter("esSize"));
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
	om.setCodigo(request.getParameter("id"));
	om.setVia(request.getParameter("via_administracion"));
	//om.setTipoSolicitud(""+tipoSolicitud);
	//om.setTipoSalida(request.getParameter("tipoSalida"));


	//om.setFechaCreacion(cDateTime);
	om.getDetalleOrdenMed().clear();
	//iEsquema.clear();
	for (int i=1; i<=size; i++)
	{
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		//detOrd.setCodigo(request.getParameter("codigo"+i));
		//detOrd.setFechaOrden(request.getParameter("fecha"+i));
		//detOrd.setFechaFin(request.getParameter("fechaFin"+i));
		//detOrd.setFechaInicio(cDateTime);
		//detOrd.setTipoSolicit(tipoSolicitud);
		//detOrd.setCentroServicio(""+cds);

		detOrd.setKey(request.getParameter("key"+i));
		detOrd.setTipoInsulina(request.getParameter("tipo_insulina"));
		detOrd.setNombre(request.getParameter("insulina"));
		detOrd.setVia(request.getParameter("via_administracion"));

				if(request.getParameter("tipo_insulina") != null && !request.getParameter("tipo_insulina").equals("2")){
						detOrd.setDescripcion(request.getParameter("nombre"+i));
						detOrd.setCantidad(request.getParameter("cantidad"+i));
				}

		detOrd.setTipoOrden(""+tipoOrden);
		detOrd.setEstado("A");


		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = key;
		else
		{
			try
			{
				iEsquema.put(key,detOrd);
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
		iEsquema.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&id="+request.getParameter("id")+"&desc="+desc+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		//cdo = new CommonDataObject();
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setDescripcion("");

		sLastLineNo++;
		if (sLastLineNo < 10) key = "00" + sLastLineNo;
		else if (sLastLineNo < 100) key = "0" + sLastLineNo;
		else key = "" + sLastLineNo;
		//cdo.addColValue("key",key);
		detOrd.setKey(key);
		try
		{
			iEsquema.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&id="+request.getParameter("id")+"&desc="+desc+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equals("add"))
		{
				om.setDescripcion("REVISAR EL ESQUEMA DE INSULINA DEL PACIENTE");
				EIMgr.addEsquema(om);
				id = EIMgr.getPkColValue("id");
		}
		else
		{
			om.setDescripcion("REVISAR EL ESQUEMA DE INSULINA DEL PACIENTE (HA SIDO MODIFICADO)");
			EIMgr.updateEsquema(om);
			id = request.getParameter("id");
		}

		ConMgr.clearAppCtx(null);


	}
	//session.removeAttribute("iEsquema");

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (EIMgr.getErrCode().equals("1"))
{
	session.removeAttribute("om");
%>
	alert('<%=EIMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%if(from.trim().equals("")){%>
	parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
		<%}%>

<%
	}
	else
	{
%>
	<%if(from.trim().equals("")){%>
		parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
} else throw new Exception(EIMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>&medico=<%=medico%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

