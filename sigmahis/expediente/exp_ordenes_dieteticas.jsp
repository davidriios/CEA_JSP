<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

sql ="select b.codigo value_col, b.descripcion label_col,b.codigo title_col, b.cod_tipo_dieta key_col from tbl_cds_subtipo_dieta b ";

if (mode.equalsIgnoreCase("add") || modeSec.equalsIgnoreCase("add")) sql += " where b.status = 'A'";
sql += " order by b.descripcion ";

XMLCreator xc = new XMLCreator(ConMgr);
xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"subDietas.xml",sql);
	
sql = "select distinct a.codigo ordenMed,to_char(a.fecha,'dd/mm/yyyy') fechaOrden from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id=b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.tipo_orden = 3  and a.pac_id="+pacId+" and a.secuencia="+noAdmision+" order by a.codigo desc" ;
		
al2 = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);
	if (change == null)
	{
		iDietas.clear();
		if(!id.trim().equals("0"))
		{

sql = "select p.cod_paciente, p.fec_nacimiento, p.secuencia,p.tipo_orden tipoOrden, p.orden_med ordenMed, p.codigo, p.nombre, to_char(p.fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(p.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, nvl(p.observacion,' ') as observacion, p.ejecutado, p.centro_servicio, p.usuario_creacion, p.fecha_creacion, p.usuario_modificacion, p.fecha_modificacion,p.tipo_dieta tipoDieta, p.cod_tipo_dieta codTipoDieta, p.tipo_tubo tipoTubo, p.fecha_orden, p.omitir_orden, p.pac_id, p.fecha_suspencion, p.obser_suspencion, p.estado_orden,t.codigo as cod, t.tubo as hasTubo from tbl_sal_detalle_orden_med p, tbl_cds_tipo_dieta t where p.tipo_orden = 3 and t.codigo = p.tipo_dieta and p.pac_id = "+pacId+" and p.secuencia = "+noAdmision+" and p.orden_med = "+id;

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
	
	sql = "select codigo as optValueColumn, descripcion||' ('||codigo||')' as optLabelColumn, nvl(tubo,'N') as optTitleColumn from TBL_CDS_TIPO_DIETA";
	
	if (mode.equalsIgnoreCase("add") || modeSec.equalsIgnoreCase("add")) sql += " where status = 'A'";
	sql += " order by descripcion ";
	
	ArrayList alTiposDieta = sbb.getBeanList(ConMgr.getConnection(),sql,CommonDataObject.class);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Ordenes de Nutricion - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();document.form0.medico.value = <%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;checkViewMode();setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function setEvaluacion(code){window.location = '../expediente/exp_ordenes_dieteticas.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id='+code;}
function add(){window.location = '../expediente/exp_ordenes_dieteticas.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id=0';}
function imprimirOrden(opt){
	if(!opt) abrir_ventana1('../expediente/print_exp_seccion_37.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&tipoOrden=3&seccion=<%=seccion%>&idOrden=<%=id%>');
	else abrir_ventana1('../expediente/print_exp_seccion_37.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&tipoOrden=3&seccion=<%=seccion%>&idOrden=0');
}
var valSelWithText = new Array();
var valSelWithText2 = new Array();
function rem(sel){var txta = document.getElementById("observacion"+sel).value;arr1 = valSelWithText;arr2 = txta.split(",");valSelWithText = arr2;document.getElementById("multipleVal"+sel).value = valSelWithText;document.getElementById("observacion"+sel).value = document.getElementById("multipleVal"+sel).value;if( document.getElementById("observacion"+sel).value != "" )document.getElementById("info"+sel).innerHTML = "-Cuando elimina, elimina la coma, después cliquea afuera.<br />-Seleccione las opciones antes de introducir la observaci&oacute;n";else document.getElementById("info"+sel).innerHTML = "";}
function multSubTipo(el, index){
	var objSel = document.getElementById('subTipo'+index);
	var w = document.getElementById('subTipo'+index).selectedIndex;
	var selected_text = document.getElementById('subTipo'+index).options[w].text;
	var found = 0;
	var tipoDieta = $("#tipoDieta"+index).val();
	var $nombre = $("#nombre"+index);
	
	for (i = 0; i<valSelWithText.length; i++){
		if(valSelWithText[i] == selected_text){
			found++;document.getElementById('subTipo'+index).selectedIndex = "";break;
		}
	}
	if (found == 0 && selected_text != ""){
		valSelWithText.push(selected_text);
		if(valSelWithText.length > 10 ){
			alert("No se puede escoger mas de 10 sub dietas!");
			return false;
		}
		
		// getting observacion
		if (el.value) {
			var nombre = getDBData('<%=request.getContextPath()%>','observacion','TBL_CDS_SUBTIPO_DIETA',' COD_TIPO_DIETA = '+tipoDieta+' and codigo = '+el.value, '');
			if(nombre) $nombre.val($nombre.val() + ", "+nombre);
			
			console.log(tipoDieta, el.value, nombre)
		}
		// ---
		
		
		document.getElementById('subTipo'+index).selectedIndex = "";
	}else{
		alert("Ese valor ya ha sido escogido o es un valor vacío!");
		return false;
	}
	
	document.getElementById("multipleVal"+index).value = valSelWithText;
	document.getElementById("observacion"+index).value = document.getElementById("multipleVal"+index).value;
	if( document.getElementById("observacion"+index).value != "" )document.getElementById("info"+index).innerHTML = "-Cuando elimina, elimina la coma, después cliquea afuera.<br />-Seleccione las opciones antes de introducir la observaci&oacute;n";
	else document.getElementById("info"+index).innerHTML = "";
}

function hasTubo(el, i){
	var hasTubo = el.options[el.selectedIndex].title === 'S' || el.options[el.selectedIndex].title === 'Y';
	var $tipoTubo = $("#tipoTubo"+i+", #_tipoTubo"+i+"Dsp");
	var $observacion = $("#nombre"+i);
	
	if (hasTubo) {
		$tipoTubo.prop('disabled', false).removeClass('FormDataObjectDisabled').addClass('FormDataObjectEnabled');
	} else {
		$tipoTubo.prop('disabled', true).val('').removeClass('FormDataObjectEnabled').addClass('FormDataObjectDisabled');
	}
	
	$observacion.val('');
	
	// getting observacion
	if (el.value) {
		var observacion = getDBData('<%=request.getContextPath()%>','observacion','TBL_CDS_TIPO_DIETA',' codigo = '+el.value, '');
		if(observacion) $observacion.val(observacion);
	}
} 

function consultas(){
  abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=3&interfaz=');
} 
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr class="TextRow01">
					<td>
					<div id="main" width="100%" class="exp h100">
					<div id="detalle" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
                 <%=fb.hidden("desc",desc)%>
                 <%=fb.hidden("from",from)%>
                 <%=fb.hidden("medico",medico)%>
						<tr class="TextRow02">
							<td colspan="3">
                            &nbsp;<cellbytelabel id="1">Listado de Ordenes</cellbytelabel></td>
							<td align="right">
                           <a href="javascript:consultas()" class="Link00Bold">[ <cellbytelabel>Consultar</cellbytelabel> ]</a> 
                            <%if(!mode.trim().equals("view")){ %> <a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Orden</cellbytelabel> ] </a><%}%><%if(!modeSec.trim().equals("add")){ %>
						    <a href="javascript:imprimirOrden()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ] </a> <%}%>
                            <%if(al2.size()>0){%><a href="javascript:imprimirOrden(1)" class="Link00">[ <cellbytelabel id="4">Imprimir Todo</cellbytelabel> ] </a><%}%>
                            </td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="5">C&oacute;digo</cellbytelabel></td>
							<td  width="15%"><cellbytelabel id="6">Fecha</cellbytelabel></td>
							<td  width="65%">&nbsp;</td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	DetalleOrdenMed det1 = (DetalleOrdenMed) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,det1.getOrdenMed())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=det1.getOrdenMed()%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=det1.getOrdenMed()%></td>
				<td colspan="2"><%=det1.getFechaOrden()%></td>
		</tr>
<%}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>

	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
			<%=fb.hidden("tot",""+alTiposDieta.size())%>
			
			<%
			for (int t = 0; t<alTiposDieta.size(); t++){
				cdo2 = (CommonDataObject)alTiposDieta.get(t); %>
				<%=fb.hidden("tuboref"+t,cdo2.getOptTitleColumn())%>
				<%=fb.hidden("tubocod"+t,cdo2.getOptValueColumn())%>
			<%}%>
			
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
			<td colspan="4"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel> 
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>	
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,50,"","","")%>
				<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
			</td>
		</tr>
			<tr class="TextHeader" align="center">
				 <td width="30%"><cellbytelabel id="7">Tipo de Dieta</cellbytelabel></td>
				 <td width="20%"><cellbytelabel id="8">Tipo de Tubo</cellbytelabel></td>
				 <!--<td width="30%">Descripci&oacute;n</td>-->
				 <td width="45%"><cellbytelabel id="9">Hasta</cellbytelabel></td>
				<td width="5%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"","Agregar Orden")%></td>
			</tr>
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iDietas);
for (int i=1; i<=iDietas.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iDietas.get(key); 
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
			
      <%//=fb.hidden("tipoSolicit"+i,""+detOrd.getTipoSolicit())%>
			<%//=fb.hidden("cds"+i,""+detOrd.getCentroServicio())%>
			<%//=fb.hidden("tipoOrden"+i,""+detOrd.getTipoOrden())%>

			<tr class="<%=color%>" align="center">
			<td>
				<%=fb.select("tipoDieta"+i,alTiposDieta, detOrd.getTipoDieta(),false,false,viewMode,0,"Text10",null,"onChange=\"loadXML('../xml/subDietas.xml','subTipo"+i+"','"+detOrd.getCodTipoDieta()+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S'); hasTubo(this,"+i+")\"","","S","")%>

			   <%=fb.hidden("multipleVal"+i,detOrd.getObservacion())%>
			   <%=fb.hidden("hasTubo"+i,detOrd.getHasTubo())%>

				<%//=fb.textBox("descDieta"+i,detOrd.getNombreProcedimiento(),true,false,(viewMode||isReadOnly),20,"Text10",null,null)%>
				<%//=fb.textBox("descSubDieta"+i,detOrd.getDescripcion(),true,false,(viewMode||isReadOnly),20,"Text10",null,null)%>		</td><!--(detOrd.getHasTubo().equalsIgnoreCase("S")?-->
				<td><%=fb.select("tipoTubo"+i,"G=GOTEO,N=BOLO,M=NASOGÁSTRICO,O=OROGÁSTRICA,J=GASTROSTOMÍA",detOrd.getTipoTubo(),false,true,0,"Text10 tipo_tubo",null,null,"","S")%></td>
				<!--<td><%//=fb.textBox("nombre"+i,detOrd.getNombre(),true,false,(viewMode||isReadOnly),30,"Text10",null,null)%></td>-->
				<td><jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2" />                
                <jsp:param name="clearOption" value="true" />                
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>                
                <jsp:param name="nameOfTBox1" value="<%="fechaInicio"+i%>" />                
                <jsp:param name="valueOfTBox1" value="<%=detOrd.getFechaInicio()%>" />                
                <jsp:param name="nameOfTBox2" value="<%="fechaFin"+i%>" />                
                <jsp:param name="valueOfTBox2" value="<%=detOrd.getFechaFin()%>" />                
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>                
</jsp:include></td>
				<td rowspan="2"><%=fb.submit("rem"+i,"X",false,(viewMode||isReadOnly),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>
			<tr class="<%=color%>">
				<td><cellbytelabel id="10">Sub Tipo Dieta</cellbytelabel><br><%=fb.select("subTipo"+i,"","",false,viewMode,0,"Text10",null,"onChange=\"multSubTipo(this, "+i+")\"")%></td> <td colspan="2">
				<span id = "info<%=i%>"></span>
				</td>
		<script language="javascript">loadXML('../xml/subDietas.xml','subTipo<%=i%>','<%=detOrd.getCodTipoDieta()%>','VALUE_COL','LABEL_COL',<%=(detOrd.getTipoDieta() != null && !detOrd.getTipoDieta().trim().equals(""))?detOrd.getTipoDieta():"document.form0.tipoDieta"+i+".value"%>,'KEY_COL','S');</script><!---->						
							</tr>
							<tr class="<%=color%>">
                <td colspan="2">
                  <%=fb.textarea("observacion"+i,detOrd.getObservacion().replace(",",", "),false,false,true,40,4,2000,null,"","onBlur=\"rem("+i+")\"")%>
                </td>
							
                <td colspan="2">
                  <cellbytelabel id="11">Observaci&oacute;n</cellbytelabel><%=fb.textarea("nombre"+i,detOrd.getNombre(),false,false,(viewMode||isReadOnly),40,4,2000,null,"","")%>
                  </td>
              </tr>
		 
				<!------->
		 <!---<tr class="<%=color%>">
				<td colspan="4">Observación<%=fb.textarea("observacion"+i,detOrd.getObservacion(),false,false,(viewMode||isReadOnly),35,2,2000,null,"","")%></td>
		 </tr>--->


<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
			<tr class="TextRow02" >
				<td colspan="8" align="right">
                <%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
                </td>
			</tr>
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
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
		 
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setKey(request.getParameter("key"+i));
		detOrd.setCodigo(request.getParameter("codigo"+i));
		detOrd.setFechaOrden(request.getParameter("fecha"+i));

		detOrd.setTipoDieta(request.getParameter("tipoDieta"+i));

		//System.out.println("sub tipo de dieta ==========="+request.getParameter("subTipo"+i));
		detOrd.setCodTipoDieta(request.getParameter("subTipo"+i));
		
		if (request.getParameter("_tipoTubo"+i+"Dsp") != null && !"".equals(request.getParameter("_tipoTubo"+i+"Dsp")) )
			detOrd.setTipoTubo(request.getParameter("_tipoTubo"+i+"Dsp"));
		else detOrd.setTipoTubo(request.getParameter("tipoTubo"+i));
		
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