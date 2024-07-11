<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.MedicamentosMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed"/>
<jsp:useBean id="orden" scope="page" class="issi.expediente.OrdenMedica"/>
<jsp:useBean id="medMgr" scope="page" class="issi.expediente.MedicamentosMgr"/>
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
medMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alDosis = new ArrayList();
ArrayList alViaAd = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "", sql2 ="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cds = request.getParameter("cds");
String toBeLocked = request.getParameter("to_be_locked")==null?"":request.getParameter("to_be_locked");
String compania = (String)session.getAttribute("_companyId");
String from = request.getParameter("from");
String medico = request.getParameter("medico");
String nombreMedico = request.getParameter("nombreMedico");
StringBuffer sbSql = new StringBuffer();
String far_externa = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (from == null) from = "";
if (medico == null) medico = (UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"";
if (nombreMedico == null) nombreMedico = (UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int medLastLineNo =0;
if (request.getParameter("medLastLineNo") != null) medLastLineNo = Integer.parseInt(request.getParameter("medLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'USA_SYS_FAR_EXTERNA'),'N') as far_externa, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'SAL_CAMPOS_OM_OBLIGATORIOS'),'N') as campos_obligatorios,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'EXP_MED_INCL_INT_ITEMS'),'N') as int_items,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'EXP_MED_INCL_SOLO_BM'),'N') as soloBm, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_EXT_VALIDA_DISP_OM'),'N') as validar_disp_om  from dual");
CommonDataObject cdoP = (CommonDataObject) SQLMgr.getData(sbSql.toString());
if (cdoP == null) cdoP = new CommonDataObject();
far_externa = cdoP.getColValue("far_externa");
boolean required = cdoP.getColValue("campos_obligatorios", "N").equalsIgnoreCase("S") || cdoP.getColValue("campos_obligatorios", "N").equalsIgnoreCase("Y");

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
		alDosis = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion/*||' - '||codigo*/ as optLabelColumn, codigo as optTitleColumn from tbl_sal_grupo_dosis order by descripcion",CommonDataObject.class);
		alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion/*||' - '||codigo*/ as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where tipo_liquido='M' order by descripcion",CommonDataObject.class);
	if (change == null)
	{
		iMed.clear();
		/*
		// 20100709 Se comentó la carga de medicamentos, ya que la pantalla de ahora en adelante se utilizará solo para registrar nuevas ordenes de medicamentos

		sql = "select codigo, to_char(fecha,'dd/mm/yyyy') as fechaOrden,  nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') as fechaFin, medicamento, dosis, concentracion, observacion, via_admin via, cod_grupo_dosis codGrupoDosis, cod_frecuencia codFrecuencia , cada, tiempo, frecuencia, stat from tbl_sal_medicacion_paciente where pac_id="+pacId+" and secuencia="+noAdmision+" order by codigo";

		//System.out.println("sql ===  "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);

		medLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			try
			{
				iMed.put(key, al.get(i-1));//iInter.put(key, al.get(i-1));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{*/
			if (!viewMode) modeSec = "add";
			DetalleOrdenMed detOrd  = new DetalleOrdenMed();

			detOrd.setCodigo("0");
			detOrd.setFechaOrden(cDateTime.substring(0,10));
			medLastLineNo++;
			if (medLastLineNo < 10) key = "00" + medLastLineNo;
			else if (medLastLineNo < 100) key = "0" + medLastLineNo;
			else key = "" + medLastLineNo;
			detOrd.setKey(""+key);

			try
			{
				iMed.put(key, detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		//}
		//else if (!viewMode) mode = "edit";
	}//change=null

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/autocomplete_header.jsp"%>
<script language="javascript">
document.title = 'MEDICAMENTO - '+document.title;
function doAction(){lockAutoComplete();/*newHeight();*/document.form0.medico.value = <%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());document.form0.medicamento<%=iMed.size()%>.focus();}
function verActivos(){abrir_ventana1('../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=A');}
function verOmitidos(){abrir_ventana1('../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=O');}
function verAdministrados(){abrir_ventana1('../expediente/exp_list_medicamento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function imprimir(){var noOrden ='';
if(document.form0.noOrden){if(document.form0.noOrden.value!=''&&document.form0.noOrden.value!='0') noOrden=document.form0.noOrden.value;}abrir_ventana('../expediente/print_exp_seccion_5.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&noOrden='+noOrden);}
var medi_a = new Array();
var mensaje_a = new Array();
function getMedi(){for ( c = 1; c<=<%=iMed.size()%>; c++ ){var medi_val = eval('document.form0.medicamento'+c).value;if ( medi_val != "" ){medi_a[(c-1)] = medi_val;}}var dataQry = "";var dataQry_a = new Array();if ( medi_a.length >= 1){for ( a = 1; a<=medi_a.length; a++ ){ dataQry += getDBData("<%=request.getContextPath()%>", "mensaje", "tbl_sal_medicamentos","compania = <%=(String)session.getAttribute("_companyId")%> and medicamento = '"+medi_a[a-1]+"' and mensaje is not null")+"#";}if ( dataQry != "" ){dataQry_a = ""+splitRowsCols(dataQry);}if(dataQry_a != "" ){mensaje_a = dataQry_a.split("#");}}}
function _alert(){if ( mensaje_a.length > 0 ){var msg = "";for ( a = 0; a<mensaje_a.length; a++ ){if(msg != mensaje_a[a] && mensaje_a[a] != ""){alert(mensaje_a[a]);} msg = mensaje_a[a];}}
}
function setFormaTxt(i){var sel = document.getElementById("forma"+i);var formaText = sel.options[sel.selectedIndex].text;var observacion = document.getElementById("observacion"+i).value;var yaEsta;if(sel.value != "" ){yaEsta = document.getElementById("observacion"+i).value.search(formaText+"<>\r\n");if (yaEsta==-1){document.getElementById("observacion"+i).value = formaText+"<>\r\n"+observacion;}}}
function devolverMed()
{var noOrden ='';var admCargo ='';
if(document.form0.noOrden.value!=''&&document.form0.noOrden.value!='0') noOrden=document.form0.noOrden.value;
if(document.form0.admCargo.value!='') admCargo=document.form0.admCargo.value;

abrir_ventana2('../farmacia/exp_orden_medicamentos_dev.jsp?mode=aprobar&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=A&noOrden='+noOrden+'&admCargo='+admCargo+'&fg=MEEXP&fp=');
}

function verifyDrug(){var error=0;for(i=1;i<=<%=iMed.size()%>;i++)if(!isValidDrug(i))error++;if(error>0)return false;return true;}

function verifyVia(){
	var error = 0;
	for(i=1;i<=<%=iMed.size()%>;i++) {
		if(!$("#via"+i).val() || !$("#forma"+i).val())error++;
	}
	if (error > 0 ) {return false;}
	return true;
}

function isValidDrug(k){
/*
1. Verificar si medicamento es controlado
	a. Si: continua con punto 2
	b. No: permite agregar medicamento y termina validación
2. Verificar si médico tiene control en medicamento
	a. Si: permite agregar y termina validación
	b. No: Si centro es controlado no permite agregar medicamento, de lo contrario permite agregar una vez.
*/
	var isCtrlDrug=false;
	var isCtrlMedic=false;
	var isCtrlCds=false;
	var drugName=eval('document.form0.medicamento'+k).value;
	var eDate=eval('document.form0.fechaFin'+k).value;
	if(drugName!=''){
	var c=splitCols(getDBData("<%=request.getContextPath()%>","z.codigo, join(cursor(select (select descripcion from tbl_adm_especialidad_medica where codigo = y.cod_especialidad) from tbl_sal_esp_medicamento y where y.cod_medicamento = z.codigo),', ')","tbl_sal_medicamentos z"," '"+drugName+"' like '%'||z.medicamento||'%' and z.antibio_ctrl = 'S' and z.status = 'A'"));
	if(c==null)return true;
	var drugId=c[0];
	var drugSpecialty=c[1];
	isCtrlDrug=(drugId!='');
	debug(isCtrlDrug);
	if(isCtrlDrug){
		if (eDate==''|| eDate==null)
		{
			var fechaLimite=getDBData("<%=request.getContextPath()%>"," /****************************/  to_char(sysdate+10,\'dd/mm/yyyy hh12:mi AM\')","dual");
			document.getElementById("fechaFin"+k).value = fechaLimite;
		}
		var medicRec='<%=(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():""%>';
		var fechaSuspension=getDBData("<%=request.getContextPath()%>"," to_char(trunc(sysdate)+10,'dd/mm/yyyy')","dual");
		//alert(fechaSuspension);
		//medicRec=prompt('Solo para prueba ingresar el Registro Médico',medicRec);
		if(medicRec==null||medicRec.trim()==''){
			alert('Solo para Personal Autorizado!');
			return false;
		}
		var medicSpecialty=getDBData("<%=request.getContextPath()%>","join(cursor(select (select descripcion from tbl_adm_especialidad_medica where codigo = z.cod_especialidad) from tbl_sal_esp_medicamento z, tbl_adm_medico_especialidad y where z.cod_medicamento = "+drugId+" and y.medico = '"+medicRec+"' and z.cod_especialidad = y.especialidad),', ')","dual");
		isCtrlMedic=(medicSpecialty!='');
		if(!isCtrlMedic){
			isCtrlCds=hasDBData("<%=request.getContextPath()%>","tbl_adm_atencion_cu z","z.pac_id = <%=pacId%> and z.secuencia = <%=noAdmision%> and exists (select null from tbl_cds_centro_servicio where codigo = z.cds and antibio_ctrl = 'S')");
			if(isCtrlCds){
				alert('El medicamento <'+drugName+'> es de uso CONTROLADO, solo puede ser ordenado por Médicos con especialidad(es): '+drugSpecialty+'!');
				return false;
			}else if(hasDBData("<%=request.getContextPath()%>","tbl_sal_detalle_orden_med z, tbl_sal_medicamentos y","z.pac_id = <%=pacId%> and z.secuencia = <%=noAdmision%> and z.tipo_orden = 2 and z.estado_orden = 'A' and y.antibio_ctrl = 'S' and y.status = 'A' and nvl(trim(substr(z.nombre,1,instr(z.nombre,'/',1)-1)),trim(z.nombre)) = trim(y.medicamento)")){
				alert('El Paciente ya tiene una Orden de Medicamento de uso CONTROLADO, por favor consultar con Médicos con especialidad(es): '+drugSpecialty+'!');
				return false;
			}//cds
		}//medic
		if(eDate.trim()!=''&&!hasDBData("<%=request.getContextPath()%>","dual","to_date('"+eDate.substring(0,10)+"','dd/mm/yyyy') between trunc(sysdate) and trunc(sysdate) + 10")){
			alert('Disculpe, no es posible suspender el medicamento <'+drugName+'> en una fecha MAYOR QUE 10 días o MENOR QUE la fecha de hoy!');
			return false;
		}
		alert('Recuerde evaluar esta ORDEN dentro de 10 DIAS a partir de HOY!');
	}//drug
	return true;
	}else{return false;}
}

function consultas(){
	abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=2&interfaz=');
}

function ctrlReadOnly(obj){
	var that = $(obj._elTextbox);
	var val = that.val();
	var toBeLocked = "<%=toBeLocked%>";
	$("#to_be_locked").val((toBeLocked?toBeLocked+",":"")+that.attr('id'));
	if(val) that.prop("readonly", true);
}

function lockAutoComplete(){
	var toBeLocked = $("#to_be_locked").val();
	var toBeLockedA = toBeLocked.split(",");

	for (i=0; i<toBeLockedA.length; i++){
		var $cField = $("#medicamento"+(i+1));
		if ($cField.length && $cField.attr('id') ==  toBeLockedA[i]&&$cField.val()) $cField.prop('readonly', true);
	}
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
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%fb.appendJsValidation("if(!verifyDrug()){error++;}");%>
		<%fb.appendJsValidation("if(!verifyVia()){CBMSG.error('Por favor llene todos los campos con fondos amarillos!');error++;}");%>
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
		<%=fb.hidden("medSize",""+iMed.size())%>
		<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
		<%=fb.hidden("medico",medico)%>
		<%=fb.hidden("cds",cds)%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("to_be_locked",toBeLocked)%>
		<%=fb.hidden("required",""+required)%>
		<%=fb.hidden("from",from)%>
		<%=fb.hidden("formaSolicitud","")%>
		<tr class="TextRow02">
			<td colspan="5" align="right">&nbsp;</td>
		</tr>
		<tr align="center" class="TextRow01">
			<td colspan="8" align="right"><a href="javascript:consultas()" class="Link00">[ <cellbytelabel id="1">Consultas</cellbytelabel> ]</a><a href="javascript:verActivos()" class="Link00">[ <cellbytelabel id="1">Ver Medic. Activos</cellbytelabel> ]</a> <a href="javascript:verOmitidos()" class="Link00">[<cellbytelabel id="2">Ver Medic. Omitidos</cellbytelabel> ]</a> <a href="javascript:verAdministrados()" class="Link00">[ <cellbytelabel id="3">Ver Medic. Administrados</cellbytelabel> ]</a> <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="4">Imprimir</cellbytelabel> ]</a>
			<%if(far_externa.trim().equals("N")){%>
			Admision (Solo Para Dev.)</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"select secuencia from tbl_adm_admision where pac_id="+pacId+" and adm_root="+noAdmision+" and estado not in ('I','N') ","admCargo",noAdmision,false,false,0,"Text10",null,null,"","")%>
			No. Orden:<%=fb.select(ConMgr.getConnection(),"select distinct nvl(codigo_orden_med,0) orden  from tbl_sal_orden_medica where pac_id="+pacId+" and secuencia = "+noAdmision+" order by 1 desc","noOrden","","S")%>

			<a href="javascript:devolverMed()" class="Link00">[ <cellbytelabel id="4">Devolver</cellbytelabel> ]</a><%}%>


			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="5"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",nombreMedico,true, false,true,50,"","","")%>
				<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
			</td>
		</tr><!---->
		<tr class="TextHeader" align="center">
			<td width="24%"><cellbytelabel id="5">Medicamento</cellbytelabel></td>
			<td width="21%"><cellbytelabel id="6">Concentr</cellbytelabel>.</td>
			<!--<td width="5%">Dosis</td>-->
			<td width="16%"><cellbytelabel id="7">Forma</cellbytelabel></td>
			<td width="37%"><cellbytelabel id="8">Frecuencia</cellbytelabel></td>
			<td width="2%"><%=fb.submit("agregarTop","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Medicamento")%></td>
		</tr>
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iMed);
for (int i=1; i<=iMed.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iMed.get(key);
	if((!detOrd.getCodigo().trim().equals("")) && !detOrd.getCodigo().trim().equals("0")) isReadOnly =true;
	else isReadOnly =false;

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("key"+i,key)%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("fecha"+i,detOrd.getFechaOrden())%>
<%=fb.hidden("codigo"+i,detOrd.getCodigo())%>
<%=fb.hidden("cod_frecuencia"+i,detOrd.getCodFrecuencia())%>
<%=fb.hidden("cForma"+i,detOrd.getCodGrupoDosis())%>
<%=fb.hidden("formaTxt"+i," ")%> <!-- Sirve para guardar la forma, en vez de modificar la clase etc. -->
<%=fb.hidden("cVia"+i,detOrd.getVia())%>
<%=fb.hidden("idArticulo"+i,detOrd.getIdArticulo())%>
<%=fb.hidden("compArticulo"+i,detOrd.getCompArticulo())%>
<%=fb.hidden("wh_bm"+i,detOrd.getWh())%>
		<tr class="<%=color%>" align="center">
						<td align="left" valign="top">
			<%String sQueryString = "compania="+compania+"&int_items="+cdoP.getColValue("int_items")+"&cds="+cds+"&soloBm="+cdoP.getColValue("soloBm")+"&validar_disp_om="+cdoP.getColValue("validar_disp_om","-");%>
			<jsp:include page="../common/autocomplete.jsp" flush="true">
					<jsp:param name="fieldId" value="<%="medicamento"+i%>"/>
					<jsp:param name="fieldValue" value="<%=detOrd.getMedicamento()%>"/>
					<jsp:param name="fieldIsRequired" value="y"/>
					<jsp:param name="fieldIsReadOnly" value="<%=(viewMode||isReadOnly)%>"/>
					<jsp:param name="fieldClass" value="Text10 __medicamentos"/>
					<jsp:param name="dObjId" value="<%="document.form0.idArticulo"+i%>"/>
					<jsp:param name="dObjRefer" value="<%="document.form0.compArticulo"+i%>"/>
					<jsp:param name="dObjXtra3" value="<%="document.form0.wh_bm"+i%>"/>
					<jsp:param name="containerSize" value="150%"/>
					<jsp:param name="maxDisplay" value="20"/>
					<jsp:param name="containerFormat" value="@@description"/>
					<jsp:param name="dsQueryString" value="<%=sQueryString%>"/>
					<jsp:param name="dsType" value="MED"/>
					<jsp:param name="containerOnSelect" value="ctrlReadOnly(this)"/>
				</jsp:include>
			</td>
			<td><%=fb.textBox("concentracion"+i,detOrd.getConcentracion(),required,false,(viewMode||isReadOnly),8,"Text10",null,null)%>	</td>
			<!--<td><%//=fb.textBox("dosis"+i,detOrd.getDosis(),true,false,(viewMode||isReadOnly),5,"Text10",null,null)%>	</td>-->
			<td>
						<%=fb.select("forma"+i,alDosis,detOrd.getCodGrupoDosis(),required,false,(viewMode||isReadOnly),0,"Text10",null,null,"","S","onchange=\"setFormaTxt("+i+")\"")%>
						<%//=fb.select("via"+i, alViaAd,detOrd.getVia(),        true, false,(viewMode||isReadOnly),0,"Text10",null,null,"","S")%>
						</td>
			<td><%=fb.textBox("frecuencia"+i,detOrd.getFrecuencia(),required,false,(viewMode||isReadOnly),25,"Text10",null,null)%>
						<%if(required){%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer RedTextBold"><%=fb.checkbox("stat"+i,"",(detOrd.getStat()!=null&&detOrd.getStat().equalsIgnoreCase("Y")),viewMode,null,null,"","STAT")%>&nbsp;STAT</label><%}%>
						</td>
			<td rowspan="2"><%=fb.submit("rem"+i,"X",false,(viewMode||isReadOnly),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
		<!--<tr class="<%=color%>"><td colspan="4"><%//=fb.button("chk_medica","Buscar Medicamentos",true,false,null,null,"onClick=\"javascript:check_medica("+i+");\"")%></td></tr>-->
		<tr class="<%=color%>">
			<td colspan="2"><%if(cdoP.getColValue("addCantidad").trim().equals("S")){%>Cantidad: <%=fb.intBox("cantidad"+i,detOrd.getCantidad(),true,false,viewMode,3,3)%></br><%}else{%>
			<%=fb.hidden("cantidad"+i,"")%><%}%>

			V&iacute;a de Admin. <%=fb.select("via"+i,alViaAd,detOrd.getVia(),true, false,(viewMode||isReadOnly),0,"Text10",null,null,"","S")%>
			<br>
			<label class="RedText"><cellbytelabel id="9">Fecha-hora suspensi&oacute;n</cellbytelabel>:</label>
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="fechaFin"+i%>"/>
				<jsp:param name="valueOfTBox1" value="<%=detOrd.getFechaFin()%>"/>
				<jsp:param name="readonly" value="<%=(viewMode||isReadOnly)?"y":"n"%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
			</jsp:include>
			</td>
			<td colspan="2"><cellbytelabel id="10">Observaciones</cellbytelabel><%=fb.textarea("observacion"+i,detOrd.getObservacion(),required,false,(viewMode||isReadOnly),40,3,2000,null,null,null)%></td>
		</tr>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
		<!--<tr class="TextHeader" align="center">
			<td width="24%">Medicamento</td>
			<td width="21%">Concentr.</td>
			<td width="22%">Dosis</td>
			<td width="16%">Forma</td>
			<td width="37%">Frecuencia</td>
			<td width="2%"><%//=fb.submit("agregarBottom","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Medicamento")%></td>
		</tr>-->
		<tr class="TextRow02" >
			<td colspan="8" align="right">
								<input type="hidden" value="O" name="saveOption">
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"")%>
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
	if (request.getParameter("medSize") != null)
	size = Integer.parseInt(request.getParameter("medSize"));

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
	orden.setFormaSolicitud(request.getParameter("formaSolicitud"));

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
		detOrd.setCodFrecuencia(request.getParameter("cod_frecuencia"+i));
		detOrd.setMedicamento(request.getParameter("medicamento"+i));
	//	detOrd.setDosis(request.getParameter("dosis"+i));
	detOrd.setCentroServicio(request.getParameter("cds"));
	detOrd.setDosis("0"+i);
		detOrd.setFechaFin(request.getParameter("fechaFin"+i));

		if(request.getParameter("forma"+i) !=null && !request.getParameter("forma"+i).trim().equals(""))
		detOrd.setCodGrupoDosis(request.getParameter("forma"+i));
		else detOrd.setCodGrupoDosis(request.getParameter("cForma"+i));

		if(request.getParameter("tiempo"+i) !=null && !request.getParameter("tiempo"+i).trim().equals(""))
		detOrd.setTiempo(request.getParameter("tiempo"+i));
		else detOrd.setTiempo(request.getParameter("cTiempo"+i));

		if(request.getParameter("via"+i) !=null && !request.getParameter("via"+i).trim().equals(""))
		detOrd.setVia(request.getParameter("via"+i));
		else detOrd.setVia(request.getParameter("cVia"+i));

		 if(request.getParameter("concentracion"+i) != null && !request.getParameter("concentracion"+i).trim().equals(""))
				 detOrd.setConcentracion(request.getParameter("concentracion"+i));
				 else detOrd.setConcentracion("");

		detOrd.setCada(request.getParameter("cada"+i));
		detOrd.setFrecuencia(request.getParameter("frecuencia"+i));

				if (request.getParameter("required")!=null && request.getParameter("required").equalsIgnoreCase("true")){
						if (request.getParameter("stat"+i) != null) detOrd.setStat("Y");
						else detOrd.setStat("N");
				}

		detOrd.setObservacion(request.getParameter("formaTxt"+i)+request.getParameter("observacion"+i));
		//detOrd.setDescripcion(detOrd.getMedicamento()+" "+detOrd.getConcentracion()+" "+detOrd.getDosis()+" "+detOrd.getCodGrupoDosis()+" "+detOrd.getCodFrecuencia()+" "+detOrd.getVia());
		detOrd.setDescripcion(detOrd.getMedicamento()+((!detOrd.getConcentracion().trim().equals(""))?" / "+detOrd.getConcentracion():""));
		//cdo.addColValue("COD_GRUPO_DOSIS",request.getParameter("forma"+i));
		//cdo.addColValue("CADA",request.getParameter("cada"+i));
		//cdo.addColValue("TIEMPO",request.getParameter("tiempo"+i));
		//cdo.addColValue("FRECUENCIA",request.getParameter("frecuencia"+i));
		//cdo.addColValue("VIA_ADMIN",request.getParameter("via"+i));
		//cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
		detOrd.setIdArticulo(request.getParameter("idArticulo"+i));
		detOrd.setCompArticulo(request.getParameter("compArticulo"+i));
		detOrd.setCantidad(request.getParameter("cantidad"+i));

		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = key;
		else
		{
			try
			{
				iMed.put(key,detOrd);
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
		iMed.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&medLastLineNo="+medLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&medico="+IBIZEscapeChars.forURL(request.getParameter("medico"))+"&nombreMedico="+IBIZEscapeChars.forURL(request.getParameter("nombreMedico"))+"&from="+request.getParameter("from")+"&cds="+cds+"&desc="+IBIZEscapeChars.forURL(desc)+"&to_be_locked="+toBeLocked);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		//cdo = new CommonDataObject();
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setCodigo("0");
		detOrd.setFechaOrden(cDateTime.substring(0,10));
		//cdo.addColValue("CODIGO","0");
		//cdo.addColValue("FECHA",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		medLastLineNo++;
		if (medLastLineNo < 10) key = "00" + medLastLineNo;
		else if (medLastLineNo < 100) key = "0" + medLastLineNo;
		else key = "" + medLastLineNo;
		//cdo.addColValue("key",key);
		detOrd.setKey(key);
		try
		{
			iMed.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&medLastLineNo="+medLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&medico="+IBIZEscapeChars.forURL(request.getParameter("medico"))+"&nombreMedico="+IBIZEscapeChars.forURL(request.getParameter("nombreMedico"))+"&from="+request.getParameter("from")+"&cds="+cds+"&desc="+IBIZEscapeChars.forURL(desc)+"&to_be_locked="+toBeLocked);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		medMgr.addDetalle(orden);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (medMgr.getErrCode().equals("1"))
{
%>
	alert('<%=medMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
	parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';

<%
	}
	else
	{
%>
	parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
} else throw new Exception(medMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=IBIZEscapeChars.forURL(desc)%>&to_be_locked=<%=toBeLocked%>&medico=<%=IBIZEscapeChars.forURL(medico)%>&nombreMedico=<%=IBIZEscapeChars.forURL(nombreMedico)%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>