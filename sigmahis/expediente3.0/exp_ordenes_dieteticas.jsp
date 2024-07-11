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
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDietas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
<jsp:useBean id="orden" scope="page" class="issi.expediente.OrdenMedica" />
<jsp:useBean id="OrdMgr" scope="page" class="issi.expediente.OrdenMedicaMgr" />

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
SQLMgr.setConnection(ConMgr);
OrdMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

CommonDataObject cdo, cdo2 = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String medico = request.getParameter("medico");
String from = request.getParameter("from");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (id == null) id = "";
if (from == null) from = "";
if (medico == null) medico = "";
if (id.trim().equals("")) id = "0";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
int dLastLineNo =0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String tipoOrden ="3";
String cds ="3";
String tipoSolicitud ="P";
String subTipo ="";
if (request.getParameter("dLastLineNo") != null) dLastLineNo = Integer.parseInt(request.getParameter("dLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc == null) desc ="";



//sql = "select b.codigo value_col, b.descripcion label_col,b.codigo title_col, a.codigo||'-'||b.codigo key_col  from  TBL_CDS_TIPO_DIETA a,tbl_cds_subtipo_dieta b where a.codigo = b.codigo(+) order by a.codigo,b.codigo";
sql ="select b.codigo value_col, b.descripcion label_col,b.codigo title_col, b.cod_tipo_dieta key_col from tbl_cds_subtipo_dieta b order by b.descripcion ";
//sql="select /*a.codigo ,a.descripcion,*/ b.descripcion label_col,b.codigo title_col,a.codigo/*||'-'||b.codigo*/ key_col  from  TBL_CDS_TIPO_DIETA a,tbl_cds_subtipo_dieta b where a.codigo = b.cod_tipo_dieta(+)  order by a.codigo,b.codigo ";
		XMLCreator xc = new XMLCreator(ConMgr);
		 xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"subDietas.xml",sql);

sql = "select distinct a.codigo ordenMed,to_char(a.fecha,'dd/mm/yyyy') fechaOrden from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id=b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.tipo_orden = 3  and a.pac_id="+pacId+" and a.secuencia="+noAdmision+" order by a.codigo desc" ;
		//al2 = SQLMgr.getDataList(sql);
		al2 = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);
	if (change == null)
	{
		iDietas.clear();
		if(!id.trim().equals("0"))
		{

sql = "select p.cod_paciente, p.fec_nacimiento, p.secuencia,p.tipo_orden tipoOrden, p.orden_med ordenMed, p.codigo, p.nombre, to_char(p.fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(p.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, p.observacion, p.ejecutado, p.centro_servicio, p.usuario_creacion, p.fecha_creacion, p.usuario_modificacion, p.fecha_modificacion,p.tipo_dieta tipoDieta, p.cod_tipo_dieta codTipoDieta, p.tipo_tubo tipoTubo, p.fecha_orden, p.omitir_orden, p.pac_id, p.fecha_suspencion, p.obser_suspencion, p.estado_orden,t.codigo as cod, t.tubo as hasTubo from tbl_sal_detalle_orden_med p, tbl_cds_tipo_dieta t where p.tipo_orden = 3 and t.codigo = p.tipo_dieta and p.pac_id = "+pacId+" and p.secuencia = "+noAdmision+" and p.orden_med = "+id;

		//System.out.println("sql ===  "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);

		dLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			try
			{
				iDietas.put(key, al.get(i-1));//iInter.put(key, al.get(i-1));
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

			detOrd.setFechaOrden(cDateTime.substring(0,10));
			dLastLineNo++;
			if (dLastLineNo < 10) key = "00" + dLastLineNo;
			else if (dLastLineNo < 100) key = "0" + dLastLineNo;
			else key = "" + dLastLineNo;
			detOrd.setKey(""+key);

			try
			{
				iDietas.put(key, detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//else if (!viewMode) mode = "edit";
	}//change=null

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'Ordenes de Nutricion - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){document.form0.medico.value = '<%=from.equals("salida_pop")?medico:((UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"") %>';checkViewMode();var val = $("input[name='formaSolicitudX']:checked").val();setFormaSolicitud(val);}
function setEvaluacion(code){window.location = '../expediente3.0/exp_ordenes_dieteticas.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id='+code;}
function add(){window.location = '../expediente3.0/exp_ordenes_dieteticas.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id=0';}
function imprimirOrden(id){abrir_ventana1('../expediente/print_exp_seccion_37.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&tipoOrden=3&seccion=<%=seccion%>&idOrden='+id);}
var valSelWithText = new Array();
var valSelWithText2 = new Array();
function rem(sel){var txta = document.getElementById("observacion"+sel).value;arr1 = valSelWithText;arr2 = txta.split(",");valSelWithText = arr2;document.getElementById("multipleVal"+sel).value = valSelWithText;document.getElementById("observacion"+sel).value = document.getElementById("multipleVal"+sel).value;if( document.getElementById("observacion"+sel).value != "" )document.getElementById("info"+sel).innerHTML = "-Cuando elimina, elimina la coma, después cliquea afuera.<br />-Seleccione las opciones antes de introducir la observaci&oacute;n";else document.getElementById("info"+sel).innerHTML = "";}
function multSubTipo(sel){var objSel = document.getElementById('subTipo'+sel);var w = document.getElementById('subTipo'+sel).selectedIndex;var selected_text = document.getElementById('subTipo'+sel).options[w].text;var found = 0;for (i = 0; i<valSelWithText.length; i++){if(valSelWithText[i] == selected_text){found++;document.getElementById('subTipo'+sel).selectedIndex = "";break;}}if (found == 0 && selected_text != ""){valSelWithText.push(selected_text);if(valSelWithText.length > 10 ){alert("No se puede escoger mas de 10 sub dietas!");return false;}document.getElementById('subTipo'+sel).selectedIndex = "";}else{alert("Ese valor ya ha sido escogido o es un valor vacío!");return false;}document.getElementById("multipleVal"+sel).value = valSelWithText;document.getElementById("observacion"+sel).value = document.getElementById("multipleVal"+sel).value;if( document.getElementById("observacion"+sel).value != "" )document.getElementById("info"+sel).innerHTML = "-Cuando elimina, elimina la coma, después cliquea afuera.<br />-Seleccione las opciones antes de introducir la observaci&oacute;n";else document.getElementById("info"+sel).innerHTML = "";}
function hasTubo(tubo, sel){var total = parseInt(document.getElementById("tot").value.trim());for ( t = 0; t<total; t++ ){var tubocod = document.getElementById("tubocod"+t).value;var tuboref = document.getElementById("tuboref"+t).value;if ( (tubocod == tubo) && tuboref == "N" ){document.getElementById("tipoTubo"+sel).className = 'FormDataObjectDisabled form-control input-sm';document.getElementById("tipoTubo"+sel).disabled = true;}else{if( (tubocod == tubo) && tuboref == "S" ){document.getElementById("tipoTubo"+sel).className = 'FormDataObjectEnabled form-control input-sm';document.getElementById("tipoTubo"+sel).disabled = false;}}}}

function consultas(){
	abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=3&interfaz=');
}
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
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("dietaSize",""+iDietas.size())%>
<%=fb.hidden("dLastLineNo",""+dLastLineNo)%>
<%=fb.hidden("medico",medico)%>
<%=fb.hidden("sel","")%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("formaSolicitud","")%>

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
		<td>
				<%=fb.button("btnConsulta","Consultar",false,false,"btn btn-inverse btn-sm|fa fa-search fa-printico",null,"onclick='consultas()'")%>
				<%if(!mode.trim().equals("view")){ %>
					<%=fb.button("btnAdd","Agregar Orden",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick='add()'")%>
				<%}%>
				<%if(!modeSec.trim().equals("add")){ %>
					<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirOrden("+id+")\"")%>
				<%}%>
				<%if(al2.size()>0){%>
					<%=fb.button("btnPrintAll","Imprimir Todo",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirOrden(0)\"")%>
				<%}%>
		</td>
</tr>
<tr><th class="bg-headtabla">Listado de Ordenes</th></tr>
</table>

<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
		<tr class="bg-headtabla2">
		<th>&nbsp;</th>
		<th><cellbytelabel id="5">C&oacute;digo</cellbytelabel></th>
		<th><cellbytelabel id="6">Fecha</cellbytelabel></th>
		<th>&nbsp;</th>
</tr>
</thead>
<tbody>
<%
for (int i=1; i<=al2.size(); i++)
{
	DetalleOrdenMed det1 = (DetalleOrdenMed) al2.get(i-1);
%>
		<tr onClick="javascript:setEvaluacion(<%=det1.getOrdenMed()%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=det1.getOrdenMed()%></td>
				<td colspan="2"><%=det1.getFechaOrden()%></td>
		</tr>
<%}%>

</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
 <tbody>
		<tr class="TextRow01">
			<td colspan="4" class="controls form-inline"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>&nbsp;&nbsp;&nbsp;Usuario que Recibe, Transcribe, lee y Confirma:
					<%=fb.textBox("userCrea",UserDet.getName(),true, false,true,15,"form-control input-sm","","")%>
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,25,"form-control input-sm","","")%>
				<%=fb.button("btnMed","...",false,viewMode,"btn btn-inverse btn-sm|fa fa-ellipsis-h fa-printico",null,"onClick=\"javascript:showMedicList()\"")%>
				</td>
	</tr>
	<tr class="bg-headtabla2">
				 <td><cellbytelabel>Tipo de Dieta</cellbytelabel></td>
				 <td><cellbytelabel>Tipo de Tubo</cellbytelabel></td>
				 <td><cellbytelabel>Fecha</cellbytelabel></td>
				 <td class="text-center"><%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,null)%></td>
		</tr>
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iDietas);
int tot = 0;
for (int i=1; i<=iDietas.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iDietas.get(key);
	if((!detOrd.getCodigo().trim().equals("")) && !detOrd.getCodigo().trim().equals("0"))
	isReadOnly =true;
	else isReadOnly =false;
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha"+i,detOrd.getFechaOrden())%>
			<%=fb.hidden("codigo"+i,detOrd.getCodigo())%>

			<tr>
			<% sql = "SELECT codigo, descripcion, codigo, tubo as hasTubo FROM TBL_CDS_TIPO_DIETA ORDER  BY descripcion asc";
			for (int t = 0; t<SQLMgr.getDataList(sql).size(); t++){
					 cdo2 = (CommonDataObject)SQLMgr.getDataList(sql).get(t); %>
					 <%=fb.hidden("tuboref"+t,cdo2.getColValue("hasTubo"))%>
				 <%=fb.hidden("tubocod"+t,cdo2.getColValue("codigo"))%>
			<%}%>
			<%=fb.hidden("tot",""+SQLMgr.getDataList(sql).size())%>

		<td><%=fb.select(ConMgr.getConnection(),sql,"tipoDieta"+i,detOrd.getTipoDieta(),false,(viewMode||isReadOnly),0,"form-control input-sm",null,"onmouseover = \"hasTubo(this.value,"+i+")\" onChange=\"loadXML('../xml/subDietas.xml','subTipo"+i+"','"+detOrd.getCodTipoDieta()+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S'); hasTubo(this.value,"+i+")\"")%></td>

	 <%=fb.hidden("multipleVal"+i,detOrd.getObservacion())%>
	 <%=fb.hidden("hasTubo"+i,detOrd.getHasTubo())%>
	 <%=fb.hidden("fechaFin"+i,detOrd.getFechaFin())%>
				<td><%=fb.select("tipoTubo"+i,"G=GOTEO, N=BOLO",detOrd.getTipoTubo(),false,(viewMode||isReadOnly),0,"form-control input-sm",null,null,"","S")%></td>

		<td class="controls form-inline">
		<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="fechaInicio"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=detOrd.getFechaInicio()%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
		</jsp:include>
	 </td>


		<td class="text-center">
				<%=fb.submit("rem"+i,"x",true,isReadOnly||viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:removeItem(this.form.name,"+i+")\"")%>
		</td>


		</tr>
				<tr>
						<td colspan="2" class="controls form-inline"><cellbytelabel id="10">Sub Tipo Dieta</cellbytelabel><%=fb.select("subTipo"+i,"","",false,(viewMode||isReadOnly),0,"form-control input-sm",null,"onChange=\"multSubTipo("+i+")\"")%></td>
						<td colspan="2">
						<strong><span id = "info<%=i%>"></span></strong>
						</td>
						<script>loadXML('../xml/subDietas.xml','subTipo<%=i%>','<%=detOrd.getCodTipoDieta()%>','VALUE_COL','LABEL_COL',<%=(detOrd.getTipoDieta() != null && !detOrd.getTipoDieta().trim().equals(""))?detOrd.getTipoDieta():"document.form0.tipoDieta"+i+".value"%>,'KEY_COL','S');</script><!---->
				</tr>
				<tr>
				<td colspan="4">
				<cellbytelabel>Observaci&oacute;n</cellbytelabel><%=fb.textarea("observacion"+i,detOrd.getObservacion()!=null?detOrd.getObservacion().replace(",",", "):"",false,false,(viewMode||isReadOnly),70,0,2000,"form-control input-sm","ddddd","onBlur=\"rem("+i+")\"")%></td>
		 </tr>

<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>

</tbody>
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
</table>
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

	orden.setPacId(request.getParameter("pacId"));
	orden.setCodPaciente(request.getParameter("codPac"));
	orden.setFecNacimiento(request.getParameter("dob"));
	orden.setSecuencia(request.getParameter("noAdmision"));
	orden.setFecha(cDateTime.substring(0,10));
	orden.setMedico(request.getParameter("medico"));
	orden.setUsuarioCreacion((String) session.getAttribute("_userName"));
	orden.setFechaCreacion(cDateTime);
	orden.setUsuarioModif((String) session.getAttribute("_userName"));
	orden.setTelefonica("N");
	orden.setTipoSolicitud(""+tipoSolicitud);
	orden.setFormaSolicitud(request.getParameter("formaSolicitud"));
	//orden.setFechaCreacion(cDateTime);

	for (int i=1; i<=size; i++)
	{
		//cdo = new CommonDataObject();

		//cdo.setTableName("TBL_SAL_MEDICACION_PACIENTE");
		//cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
		//cdo.addColValue("SECUENCIA", request.getParameter("noAdmision"));
		//cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		//cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		//cdo.addColValue("PAC_ID",request.getParameter("pacId"));

		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setKey(request.getParameter("key"+i));
		detOrd.setCodigo(request.getParameter("codigo"+i));
		detOrd.setFechaOrden(request.getParameter("fecha"+i));

		detOrd.setTipoDieta(request.getParameter("tipoDieta"+i));

		//System.out.println("sub tipo de dieta ==========="+request.getParameter("subTipo"+i));
		detOrd.setCodTipoDieta(request.getParameter("subTipo"+i));
		detOrd.setTipoTubo(request.getParameter("tipoTubo"+i));
		detOrd.setObservacion(request.getParameter("observacion"+i));
		detOrd.setNombre(request.getParameter("nombre"+i));
		detOrd.setFechaFin(request.getParameter("fechaFin"+i));
		detOrd.setFechaInicio(request.getParameter("fechaInicio"+i));

		detOrd.setTipoSolicit(tipoSolicitud);
		detOrd.setCentroServicio(""+cds);
		detOrd.setTipoOrden(""+tipoOrden);
		detOrd.setEstado("A");

		detOrd.setHasTubo(request.getParameter("hasTubo"+i));


		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = key;
		else
		{
			try
			{
				iDietas.put(key,detOrd);
				orden.getDetalleOrdenMed().add(detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for

	if (!itemRemoved.equals(""))
	{
		iDietas.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&dLastLineNo="+dLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&medico="+medico+"&from="+from);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		//cdo = new CommonDataObject();
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setCodigo("0");
		detOrd.setFechaOrden(cDateTime.substring(0,10));
		detOrd.setFechaInicio(cDateTime);
		//cdo.addColValue("CODIGO","0");
		//cdo.addColValue("FECHA",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		dLastLineNo++;
		if (dLastLineNo < 10) key = "00" + dLastLineNo;
		else if (dLastLineNo < 100) key = "0" + dLastLineNo;
		else key = "" + dLastLineNo;
		//cdo.addColValue("key",key);
		detOrd.setKey(key);
		try
		{
			iDietas.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&dLastLineNo="+dLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&medico="+medico+"&from="+from);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equals("add"))
		{
				OrdMgr.addOrden(orden);
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
} else throw new Exception(OrdMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>&medico=<%=medico%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>