<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDieta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDieta" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCuidado" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCuidado" scope="session" class="java.util.Vector" />
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String noIndicacion = request.getParameter("no_indicacion")==null? "" : request.getParameter("no_indicacion");
String noDosis = request.getParameter("no_dosis")==null? "" : request.getParameter("no_dosis");
String noFrecuencia = request.getParameter("no_frecuencia")==null? "" : request.getParameter("no_frecuencia");
String noDuracion = request.getParameter("no_duracion")==null? "" : request.getParameter("no_duracion");
String fg = request.getParameter("fg")==null? "" : request.getParameter("fg");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (cds == null) cds = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";
if (tab == null) tab = "0";

if (request.getMethod().equalsIgnoreCase("GET")) {
 StringBuffer sbSql = new StringBuffer();
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

sql="select contacto ,parentezco_contacto ,telefono_contacto from tbl_adm_admision where pac_id = "+pacId+" and secuencia = "+noAdmision;
cdo1 = SQLMgr.getData(sql);
if(cdo1 == null)
{
	cdo1 =  new CommonDataObject();
	if (!viewMode) modeSec = "add";
}else if (!viewMode) modeSec = "edit";


if(change == null)
{
iMed.clear(); //MEDICAMENTOS
iDiag.clear();
vDiag.clear();
iDieta.clear();
vDieta.clear();
iCuidado.clear();
vCuidado.clear();

sql="select m.pac_id, m.admision, m.secuencia,m.medicamento, m.cantidad, m.indicacion, m.dosis, m.frecuencia, m.duracion, m.no_receta, m.invalido, nvl((select count(*) from tbl_sal_recetas a where a.pac_id = m.pac_id and a.admision = m.admision and a.id_recetas = m.no_receta and a.status = 'P'),0) as tot_imp from tbl_sal_salida_medicamento m where  m.pac_id = "+pacId+" and m.admision = "+noAdmision+" order by m.no_receta";
 al = SQLMgr.getDataList(sql);
	 for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);

			cdo.setKey(i);
			cdo.setAction("U");

			try
			{
				iMed.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.addColValue("secuencia","0");

			cdo.setKey(iMed.size()+1);
			cdo.setAction("I");

			try
			{
				iMed.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// DIAGNOSTICOS DE SALIDA.

		sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";
			al = SQLMgr.getDataList(sql);
			for (int i=0; i<al.size(); i++)
			{
		cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
		cdo.setAction("U");

				try
				{
					iDiag.put(cdo.getKey(),cdo);
					vDiag.addElement(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

		// DIETAS
		String join = fg.equalsIgnoreCase("PSLO") ? "(+)" : "";
	sql= "select a.codigo, a.tipo_dieta ,a.subtipo_dieta, a.observacion, b.descripcion descSubTipo,b.observacion obserSubDieta,c.descripcion descDieta from tbl_sal_salida_dieta a,tbl_cds_subtipo_dieta b,tbl_cds_tipo_dieta c where a.tipo_dieta = b.cod_tipo_dieta"+join+" and a.subtipo_dieta = b.codigo"+join+" and b.cod_tipo_dieta = c.codigo"+join+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.codigo ";

	al = SQLMgr.getDataList(sql);
			for (int i=0; i<al.size(); i++)
			{
		cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
		cdo.setAction("U");

				try
				{
					iDieta.put(cdo.getKey(),cdo);
					vDieta.addElement(cdo.getColValue("tipo_dieta") +"-"+cdo.getColValue("subtipo_dieta"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

		if (fg.equalsIgnoreCase("PSLO") && al.size() == 0){
		cdo = new CommonDataObject();
		cdo.setKey(iDieta.size()+1);
		cdo.setAction("I");
		cdo.addColValue("codigo","0");

		try
		{
			iDieta.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		}

		// CUIDADOS

	sql= " select a.codigo, a.pac_id, a.admision, a.guia_id, decode(a.guia_id,-1,a.guia_desc,b.nombre) as descGuia, a.observacion, a.recomendaciones from tbl_sal_salida_cuidado a, tbl_sal_guia b where a.guia_id = b.id(+) and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.status = 'A' order by a.codigo ";

		al = SQLMgr.getDataList(sql);
			for (int i=0; i<al.size(); i++)
			{
		cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
		cdo.setAction("U");

				try
				{
					iCuidado.put(cdo.getKey(),cdo);
					vCuidado.addElement(cdo.getColValue("guia_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

		if (fg.equalsIgnoreCase("PSLO") && al.size() == 0){
		cdo = new CommonDataObject();
		cdo.setKey(iCuidado.size()+1);
		cdo.setAction("I");
		cdo.addColValue("codigo","0");

		try
		{
			iCuidado.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		}

}//change
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/autocomplete_header.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE-PLAN DE SALIDA '+document.title;
function doAction(){
	newHeight();
	<%if (request.getParameter("type") != null){
		if (tab.equals("1")){%>showDiagnosticoList();<%}
		else {
			if (!fg.equalsIgnoreCase("PSLO")) {
				if ( tab.equals("3")){%>showDietaList();<%}
				else if (tab.equals("4")){%>showCuidadoList();<%}
			}
		}
	}%>
}
function showDiagnosticoList(){ abrir_ventana1('../common/check_diagnostico.jsp?fp=planSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&fg=<%=fg%>');}
function showDietaList(i){ abrir_ventana1('../common/check_dieta.jsp?fp=pSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&fg=<%=fg%>&index='+i);}
function showCuidadoList(i){abrir_ventana1('../common/check_cuidado.jsp?fp=pSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&fg=<%=fg%>&index='+i);}
function imprimir(){
abrir_ventana1('../expediente/print_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>');
}
function isAvalidNoRec(){
	var isValid = true;
	var recObj = [];
	var totMed = parseInt("<%=iMed.size()%>",10);
	for (i=0; i<totMed; i++){
		 if ($("#no_receta"+i).val())recObj.push($("#no_receta"+i).val());
	 if ( $("#no_receta"+i).val() && !isInteger($("#no_receta"+i).val()) ) {
		isValid = false;
		$("#no_receta"+i).select();
		break;
	 }else if ( parseInt($("#no_receta"+i).val()) < 1){isValid = false; break;}
	}
	//debug(recObj);
	recObj = removeDups(recObj);
	//debug(recObj);
	if (recObj[recObj.length-1] > recObj.length){isValid=false;}
	return isValid;
}

function alreadyPrintedAll(){
	 var t = parseInt("<%=iMed.size()%>");
	 var rObj = [];
	 var halt = false;
	 var d = 0;
	 for (r = 0; r<t; r++){
	 if ( $("#action"+r).val() == "I"){
		 rObj.push( $("#no_receta"+r).val() );
		 //debug("NO RECETA = R = "+r+" --- "+$("#no_receta"+r).val());
	 }
	 }
	 rObj = removeDups(rObj);
	 if (rObj.length > 0){
		 d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_recetas',"pac_id=<%=pacId%> and admision=<%=noAdmision%> and id_recetas in("+rObj+") and status = 'P' ",'');
	 if (d > 0) {alert("Perdona, pero usted está tratando de insertar un medicamento en una receta ya impresa!"); halt=true;$("#no_receta"+r).select();}
	 else halt = false;
	 }else{halt = false;}
	 return halt;
}

function alreadyPrinted(ind){
	var noReceta = $("#no_receta"+ind).val();
	var action = $("#action"+ind).val();
	var d, proceed = true;
	if (!isInteger(noReceta)) {alert("No es un número válido!"); $("#no_receta"+ind).select(); proceed = false;}
	else{
		d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_recetas',"pac_id=<%=pacId%> and admision=<%=noAdmision%> and id_recetas = "+noReceta+" and status = 'P' ",'');

		if (d>0 && "I" != action){
			alert("Usted está tratando de eliminar un medicamento ya impreso en una receta!");
		proceed = false;
		}else{removeItem('form2',ind); proceed = true;}
	}
	if (proceed===true) $("#form2").submit();
}

function invalidate(i) {
  var $btn = $("#inv"+i)
  var medicamento = $("#medicamento"+i).val()
  var secuencia = $("#secuencia"+i).val()
  $btn.prop('disabled',  true)
  
  if (confirm('Confirmar que quieres invalidar " '+medicamento+' " de una receta ya impresa.')) {
    $.ajax({
      url: '<%=request.getContextPath()+request.getServletPath()%>', 
      method: 'POST',
      data: {
        secuencia: secuencia,
        seccion: '<%=seccion%>',
        pacId: '<%=pacId%>',
        noAdmision: '<%=noAdmision%>',
        invalidating: 'Y',
        tab: '2',
      }
    }).done(function(response) {
      console.log(response)
    }).fail(function(response) {
      alert(response.responseJSON.msg || 'Error tratando de invalidar el medicamento')
    })
  } else {
    $btn.prop('disabled',  false)
  }
}
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
	<tr class="TextRow01">
		<td colspan="4" align="right"> <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a><!----->

		<jsp:include page="../common/btn_email_to_printer.jsp" flush="true">
			<jsp:param name="fg" value="PLAN_SALIDA"></jsp:param>
			<jsp:param name="xtraParam" value="<%="&pacId="+pacId+"&noAdmision="+noAdmision%>"></jsp:param>
			<jsp:param name="openInParent" value="y"></jsp:param>
		</jsp:include>

		</td>
	</tr>
	<tr>
		<td>
<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
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
				 <%=fb.hidden("tab","0")%>
				 <%=fb.hidden("mSize",""+iMed.size())%>
				 <%=fb.hidden("diagSize",""+iDiag.size())%>
				 <%=fb.hidden("dSize",""+iDieta.size())%>
				 <%=fb.hidden("cSize",""+iCuidado.size())%>
				 <%=fb.hidden("cds",""+cds)%>
								 <%=fb.hidden("desc",""+desc)%>
								 <%=fb.hidden("no_indicacion",noIndicacion)%>
								 <%=fb.hidden("no_dosis",noDosis)%>
								 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
								 <%=fb.hidden("no_duracion",noDuracion)%>
								 <%=fb.hidden("fg",fg)%>
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel id="2">DATOS GENERALES</cellbytelabel></td>
				</tr>
					<tr class="TextRow01">
					<td width="20%">&nbsp;</td>
					<td width="80%">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Contacto En Casa</cellbytelabel></td>
					<td> <%=fb.textBox("contacto",cdo1.getColValue("contacto"),false,false,viewMode,50)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Parentesco</cellbytelabel></td>
					<td><%=fb.textBox("parentezco",cdo1.getColValue("parentezco_contacto"),false,false,viewMode,50)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="5">Tel&eacute;fono</cellbytelabel> </td>
					<td><%=fb.textBox("telefono",cdo1.getColValue("telefono_contacto"),false,false,viewMode,25,20)%></td>
				</tr>

				<tr class="TextRow02">
					<td colspan="2" align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
					<%fb.appendJsValidation("if(error>0)doAction();");%>
					<%=fb.formEnd(true)%>
				</table>
	<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("mSize",""+iMed.size())%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("dSize",""+iDieta.size())%>
<%=fb.hidden("cSize",""+iCuidado.size())%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("desc",""+desc)%>
<%=fb.hidden("no_indicacion",noIndicacion)%>
<%=fb.hidden("no_dosis",noDosis)%>
<%=fb.hidden("no_frecuencia",noFrecuencia)%>
<%=fb.hidden("no_duracion",noDuracion)%>
<%=fb.hidden("fg",fg)%>
			<tr class="TextHeader">
						<td><cellbytelabel id="9">Diagnosticos de Salida</cellbytelabel></td>
					</tr>
			<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">

			<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
							<td width="65%"><cellbytelabel id="11">Nombre</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="12">Prioridad</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addDiagnostico","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnósticos")%></td>
						</tr>
<%
al.clear();
al = CmnMgr.reverseRecords(iDiag);
for (int i=0; i<iDiag.size(); i++)
{
		key = al.get(i).toString();
		cdo = (CommonDataObject) iDiag.get(key);
%>

						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("diagnostico"+i,cdo.getColValue("diagnostico"))%>
						<%=fb.hidden("diagnosticoDesc"+i,cdo.getColValue("diagnosticoDesc"))%>
						<%=fb.hidden("usuarioCreacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fechaCreacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("usuarioModificacion"+i,cdo.getColValue("usuario_modificacion"))%>
						<%=fb.hidden("fechaModificacion"+i,cdo.getColValue("fecha_modificacion"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("ordenDiag"+i,cdo.getColValue("ordenDiag"))%>
			<%}else{%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("diagnostico")%></td>
							<td><%=cdo.getColValue("diagnosticoDesc")%></td>
							<td align="center"><%=fb.intBox("ordenDiag"+i,cdo.getColValue("orden_diag"),true,false,viewMode,2)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diagnóstico")%></td>
						</tr>
<%			}
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
				<%fb.appendJsValidation("if(error>0)newHeight();");%>
					<%=fb.formEnd(true)%>
				</table>
	<!-- TAB1 DIV END HERE-->
</div>
<!-- TAB2 DIV START HERE---------------------------------------------------------------------------------------------->
<div class = "dhtmlgoodies_aTab">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				 <%=fb.hidden("dob","")%>
				 <%=fb.hidden("codPac","")%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("tab","2")%>
				 <%=fb.hidden("mSize",""+iMed.size())%>
				 <%=fb.hidden("diagSize",""+iDiag.size())%>
				 <%=fb.hidden("dSize",""+iDieta.size())%>
				 <%=fb.hidden("cSize",""+iCuidado.size())%>
				 <%=fb.hidden("cds",""+cds)%>
								 <%=fb.hidden("desc",""+desc)%>
								 <%=fb.hidden("no_indicacion",noIndicacion)%>
								 <%=fb.hidden("no_dosis",noDosis)%>
								 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
								 <%=fb.hidden("no_duracion",noDuracion)%>
				 <%=fb.hidden("fg",fg)%>
				 <%fb.appendJsValidation("if(isAvalidNoRec()==false){alert('Por favor verifique que el número de receta no exceda la cantidad de medicamentos y que sea un entero!');error++;}");%>
				 <%fb.appendJsValidation("if(alreadyPrintedAll()===true){error++;}");%>
					<tr class="TextHeader" >
						<td colspan="8"><cellbytelabel id="13">MEDICAMENTOS RECETADOS</cellbytelabel></td>
				</tr>
				<tr class="TextHeader" align="center">
							<td width="7%" class="Text10"><cellbytelabel>NO.RECETA</cellbytelabel></td>
							<td width="24%" class="Text10"><cellbytelabel>MEDICAMENTO</cellbytelabel></td>
														<td width="3%" class="Text10"><cellbytelabel>CANT.</cellbytelabel></td>
							<td width="17%" class="Text10"><cellbytelabel>INDICACION</cellbytelabel></td>
							<td width="15%" class="Text10"><cellbytelabel>DOSIS</cellbytelabel></td>
							<td width="15%" class="Text10"><cellbytelabel>FRECUENCIA</cellbytelabel></td>
							<td width="15%" class="Text10"><cellbytelabel>DURACION</cellbytelabel></td>
							<td width="4%">
							<%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Medicamento")%>
							</td>
					</tr>

				<%
				al.clear();
				al = CmnMgr.reverseRecords(iMed);
				int totImp = 0;

				for (int i = 0; i <iMed.size(); i++)
				{
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";

					key = al.get(i).toString();
				cdo = (CommonDataObject) iMed.get(key);
				totImp = Integer.parseInt(cdo.getColValue("tot_imp")==null || cdo.getColValue("tot_imp").equals("")?"0":cdo.getColValue("tot_imp"));
				%>
					 <%=fb.hidden("remove"+i,"")%>
					 <%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
					 <%=fb.hidden("action"+i,cdo.getAction())%>
					 <%=fb.hidden("key"+i,cdo.getKey())%>
					 <%=fb.hidden("tot_imp"+i,cdo.getColValue("tot_imp"))%>
					 <%=fb.hidden("invalido"+i,cdo.getColValue("invalido"))%>
				<%if(cdo.getAction().equalsIgnoreCase("D")){%>
					 <%=fb.hidden("medicamento"+i,cdo.getColValue("medicamento"))%>
					 <%=fb.hidden("cantidad"+i,cdo.getColValue("cantidad"))%>
					 <%=fb.hidden("indicacion"+i,cdo.getColValue("indicacion"))%>
					 <%=fb.hidden("dosis"+i,cdo.getColValue("dosis"))%>
					 <%=fb.hidden("frecuencia"+i,cdo.getColValue("frecuencia"))%>
					 <%=fb.hidden("duracion"+i,cdo.getColValue("duracion"))%>
				<%}else{
					 String noReceta = cdo.getColValue("no_receta")==null?"":cdo.getColValue("no_receta");
				%>
					<tr class="<%=color%>" align="center">
							<td><%=fb.intBox("no_receta"+i,noReceta.equals("")?"1":noReceta,true,false,(viewMode||totImp>0),4,2,"Text10",null,"")%></td>
							<td>
							<%///=fb.textBox("medicamento"+i,cdo.getColValue("medicamento"),true,false,(viewMode||totImp>0),50,100,"Text10",null,null)%>
							
							<%String sQueryString = "compania="+((String)session.getAttribute("_companyId"))+"&int_items="+cdoP.getColValue("int_items")+"&cds="+cds+"&soloBm="+cdoP.getColValue("soloBm")+"&validar_disp_om="+cdoP.getColValue("validar_disp_om","-");%>
              <jsp:include page="../common/autocomplete.jsp" flush="true">
                  <jsp:param name="fieldId" value="<%="medicamento"+i%>"/>
                  <jsp:param name="fieldValue" value="<%=cdo.getColValue("medicamento"," ").trim()%>"/>
                  <jsp:param name="fieldIsRequired" value="y"/>
                  <jsp:param name="fieldIsReadOnly" value="<%=(viewMode||totImp>0)%>"/>
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
              <td><%=fb.textBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,(viewMode||totImp>0),5,2,"Text10",null,null)%></td>
							<td><%=fb.textBox("indicacion"+i,cdo.getColValue("indicacion"),(noIndicacion.equals("") || noIndicacion.equals("N")),false,(viewMode||totImp>0),20,100,"Text10",null,null)%></td>
							<td><%=fb.textBox("dosis"+i,cdo.getColValue("dosis"),(noDosis.equals("") || noDosis.equals("N")),false,(viewMode||totImp>0),20,200,"Text10",null,null)%></td>
							<td><%=fb.textBox("frecuencia"+i,cdo.getColValue("frecuencia"),(noFrecuencia.equals("") || noFrecuencia.equals("N")),false,(viewMode||totImp>0),20,200,"Text10",null,null)%></td>
							<td><%=fb.textBox("duracion"+i,cdo.getColValue("duracion"),(noDuracion.equals("") || noDuracion.equals("N")),false,(viewMode||totImp>0),20,200,"Text10",null,null)%></td>
							<td>
							<%if(totImp > 0) {%>
                  <%=fb.button("inv"+i,"X",true,(viewMode||cdo.getColValue("invalido", "N").equalsIgnoreCase("Y")),null,null,"onClick=invalidate("+i+")","Invalidar")%>
							<%} else {%>
                  <%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=alreadyPrinted("+i+")","Eliminar")%>
							<%} %>
							</td>
					</tr><%}%>
	<%}%>


				<tr class="TextRow02">
					<td colspan="8" align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
				<%fb.appendJsValidation("if(error>0)newHeight();");%>
					<%=fb.formEnd(true)%>
				</table>

	<!-- TAB2 DIV END HERE------------------------------------------------------------------------------------------>
</div>

<!-- TAB3 DIV START HERE---------------------------------------------------------------------------------------------->
<div class = "dhtmlgoodies_aTab">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				 <%=fb.hidden("dob","")%>
				 <%=fb.hidden("codPac","")%>
				 <%=fb.hidden("pacId",pacId)%>
					 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("tab","3")%>
				 <%=fb.hidden("mSize",""+iMed.size())%>
				 <%=fb.hidden("diagSize",""+iDiag.size())%>
				 <%=fb.hidden("dSize",""+iDieta.size())%>
				 <%=fb.hidden("cSize",""+iCuidado.size())%>
				 <%=fb.hidden("cds",""+cds)%>
								 <%=fb.hidden("desc",""+desc)%>
								 <%=fb.hidden("no_indicacion",noIndicacion)%>
								 <%=fb.hidden("no_dosis",noDosis)%>
								 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
								 <%=fb.hidden("no_duracion",noDuracion)%>
				 <%=fb.hidden("fg",fg)%>

		 <tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="25%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel id="18">Dieta</cellbytelabel></td>
							<td width="45%"><cellbytelabel id="19">Observaci&oacute;n</cellbytelabel></td>
							<td width="5%">
				<%=fb.submit("addDieta","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Dieta")%></td>
						</tr>
<%
al.clear();
al = CmnMgr.reverseRecords(iDieta);
for (int i=0; i<iDieta.size(); i++)
{
		key = al.get(i).toString();
		cdo = (CommonDataObject) iDieta.get(key);
			String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow02";

%>
						 <%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("tipo_dieta"+i,cdo.getColValue("tipo_dieta"))%>
						<%=fb.hidden("subtipo_dieta"+i,cdo.getColValue("subtipo_dieta"))%>
						<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
		 <%if(cdo.getAction().equalsIgnoreCase("D")){%>
		 <%=fb.hidden("descDieta"+i,cdo.getColValue("descDieta"))%>
		 <%=fb.hidden("descSubTipo"+i,cdo.getColValue("descSubTipo"))%>
		 <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
		 <%}else{%>
			<tr class="<%=color%>">
							<td valign="middle"><%=fb.textBox("descDieta"+i,cdo.getColValue("descDieta"),!fg.equalsIgnoreCase("PSLO"),false,true,25,"Text10",null,null)%></td>
							<td><%=fb.textBox("descSubTipo"+i,cdo.getColValue("descSubTipo"),!fg.equalsIgnoreCase("PSLO"),false,true,25,"Text10",null,null)%>

				<%if(!viewMode && fg.equalsIgnoreCase("PSLO")){%>
				<button type="button" class="CellbyteBtn" onclick="showDietaList(<%=i%>)">...</button>
				<%}%>

				</td>
							<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,40,2,2000,"","width:100%","")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Dieta")%></td>
						</tr>
		<%}}%>
						</table>
					</td>
				</tr>




		<tr class="TextRow02">
						<td  align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
						</td>
					</tr>
					<%=fb.formEnd(true)%>
				</table>
	<!-- TAB3 DIV END HERE------------------------------------------------------------------------------------------>
</div>
<!-- TAB4 DIV START HERE---------------------------------------------------------------------------------------------->
<div class = "dhtmlgoodies_aTab">

				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				 <%=fb.hidden("dob","")%>
				 <%=fb.hidden("codPac","")%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("tab","4")%>
				 <%=fb.hidden("mSize",""+iMed.size())%>
				 <%=fb.hidden("diagSize",""+iDiag.size())%>
				 <%=fb.hidden("dSize",""+iDieta.size())%>
				 <%=fb.hidden("cSize",""+iCuidado.size())%>
				 <%=fb.hidden("cds",""+cds)%>
				 <%=fb.hidden("desc",""+desc)%>
								 <%=fb.hidden("no_indicacion",noIndicacion)%>
								 <%=fb.hidden("no_dosis",noDosis)%>
								 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
								 <%=fb.hidden("no_duracion",noDuracion)%>
				 <%=fb.hidden("fg",fg)%>
		<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
							<td width="40%"><cellbytelabel id="20">Guia</cellbytelabel></td>
				<td width="45%"><cellbytelabel id="19">Observaci&oacute;n</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addCuidado","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Cuidado")%></td>
						</tr>
<%
String recomendaciones = "";
al.clear();
al = CmnMgr.reverseRecords(iCuidado);
for (int i=0; i<iCuidado.size(); i++)
{
		key = al.get(i).toString();
		cdo = (CommonDataObject) iCuidado.get(key);
		
		recomendaciones = cdo.getColValue("recomendaciones"," ");

		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
%>
						<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("guia_id"+i,cdo.getColValue("guia_id"))%>
			<%=fb.hidden("descGuia"+i,cdo.getColValue("descGuia"))%>
			<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
			<%}else{%>
						<tr class="<%=color%>">
							<td valign="middle"><%=fb.textBox("guia_id"+i,cdo.getColValue("guia_id"),!fg.equalsIgnoreCase("PSLO"),false,true,5,"Text10",null,null)%></td>
							<td align="center"><%=fb.textBox("descGuia"+i,cdo.getColValue("descGuia"),!fg.equalsIgnoreCase("PSLO"),false,true,50,"Text10",null,null)%>

				<%if(!viewMode && fg.equalsIgnoreCase("PSLO")){%>
				<button type="button" class="CellbyteBtn" onclick="showCuidadoList(<%=i%>)">...</button>
				<%}%>

				</td>
				 <td align="center">
				 <%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,40,2,2000,"","width:100%","")%>
				 </td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Cuidado")%></td>
						</tr>
						
						
						
<%}}%>

						<tr class="TextRow01">
					<td>Recomendaciones</td>
					<td colspan="3">
						<%=fb.textarea("recomendaciones", recomendaciones,false,false,viewMode,40,2,2000,"","width:95%","")%>
					</td>
				</tr>

						</table>
					</td>
				</tr>
				
				



					<tr class="TextRow02">
						<td colspan="5" align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
						</td>
					</tr>
					<%=fb.formEnd(true)%>

				</table>
	<!-- TAB4 DIV END HERE------------------------------------------------------------------------------------------>
</div>
<!-- MAIN DIV END HERE -->
</div>
<script type="text/javascript">
<%

String tabLabel = "'Datos Generales','Diagnosticos De Salida','Medicamentos','Dietas','Cuidados'";
//if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Liquido Amniotico ','Tactos','Anestesia-Parto Normal','Parto Instrumental'";
%>
 initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
	</td>
</tr>
</table>

</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";

	if(tab.equals("0")) //
	{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_adm_admision");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia ="+request.getParameter("noAdmision"));
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modifica",cDateTime);
			cdo.addColValue("contacto",request.getParameter("contacto"));
			cdo.addColValue("parentezco_contacto",request.getParameter("parentezco"));
			cdo.addColValue("telefono_contacto",request.getParameter("telefono"));

			if (baction.equalsIgnoreCase("Guardar"))
			{
				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
				SQLMgr.update(cdo);
				ConMgr.clearAppCtx(null);
			}
	}
		else if (tab.equals("1")) //DIAGNOSTICOS
		{
		int size = 0;
		if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
	iDiag.clear();
		vDiag.clear();
	al.clear();
		for (int i=0; i<size; i++)
		{
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_adm_diagnostico_x_admision");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='S' and diagnostico='"+request.getParameter("diagnostico"+i)+"'");
		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("paciente",request.getParameter("codPac"));
		cdo2.addColValue("fecha_nacimiento", request.getParameter("dob"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("diagnostico",request.getParameter("diagnostico"+i));
		cdo2.addColValue("diagnosticoDesc",request.getParameter("diagnosticoDesc"+i));
		cdo2.addColValue("orden_diag",request.getParameter("ordenDiag"+i));
		cdo2.addColValue("tipo","S");
		cdo2.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"+i));
		cdo2.addColValue("fecha_creacion",request.getParameter("fechaCreacion"+i));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion",cDateTime);
		cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
		cdo2.setKey(i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			System.out.println(":::::::::::::::::::::::::::::::::: A = "+cdo2.getAction()+" -- "+request.getParameter("action"+i)+" "+(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")));
			try
			{
				iDiag.put(cdo2.getKey(),cdo2);
				if(!cdo2.getAction().trim().equals("D"))vDiag.add(cdo2.getColValue("diagnostico"));
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
		if (!itemRemoved.equals(""))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&fg="+fg);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&fg="+fg);
			return;
		}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_adm_diagnostico_x_admision");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='S'");
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
	}
	else if(tab.equals("2")) {
		if (request.getParameter("invalidating") != null) {
		  response.setContentType("application/json");
		  
		  com.google.gson.Gson gson = new com.google.gson.Gson();
		  com.google.gson.JsonObject json = new com.google.gson.JsonObject();
		  
		  json.addProperty("date", System.currentTimeMillis());
		  
		  CommonDataObject cdo2 = new CommonDataObject();
      cdo2.setTableName("tbl_sal_salida_medicamento");
      cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and secuencia="+request.getParameter("secuencia"));
			cdo2.addColValue("invalido", "Y");
      cdo2.addColValue("usuario_invalida", (String) session.getAttribute("_userName"));
      cdo2.addColValue("fecha_invalida", cDateTime);
      
      SQLMgr.update(cdo2);

      if (SQLMgr.getErrCode().equals("1")) {
         json.addProperty("error", false);
         json.addProperty("msg", "SecMgr inactivó satifactoriamente");
      } else {
         response.setStatus(500);
         json.addProperty("error", true);
         json.addProperty("msg", SQLMgr.getErrMsg());
      }
    
      out.print(gson.toJson(json));
		  return;
		  
		}	else {
			
			int size = 0;
			al.clear();
			iMed.clear();
			if (request.getParameter("mSize") != null) size = Integer.parseInt(request.getParameter("mSize"));

			for (int i=0; i<size; i++)
			{
					CommonDataObject cdo2 = new CommonDataObject();
					cdo2.setTableName("tbl_sal_salida_medicamento");
					cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and secuencia="+request.getParameter("secuencia"+i));
					cdo2.addColValue("pac_id",request.getParameter("pacId"));
					cdo2.addColValue("admision",request.getParameter("noAdmision"));
					cdo2.addColValue("no_receta",request.getParameter("no_receta"+i));
					cdo2.addColValue("tot_imp",request.getParameter("tot_imp"+i));
					cdo2.addColValue("invalido",request.getParameter("invalido"+i));
					cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
					cdo2.addColValue("fecha_modificacion",cDateTime);

				if (request.getParameter("secuencia"+i)==null || ( request.getParameter("secuencia"+i).trim().equals("0")||request.getParameter("secuencia"+i).trim().equals("")))
				{
					cdo2.setAutoIncCol("secuencia");
					cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
					cdo2.addColValue("fecha_creacion",cDateTime);
					cdo2.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
				}else cdo2.addColValue("secuencia",request.getParameter("secuencia"+i));

					cdo2.addColValue("medicamento",request.getParameter("medicamento"+i));
					cdo2.addColValue("cantidad",request.getParameter("cantidad"+i));
					cdo2.addColValue("indicacion",request.getParameter("indicacion"+i).trim().equals("")?"N/A":request.getParameter("indicacion"+i));
					cdo2.addColValue("dosis",request.getParameter("dosis"+i).trim().equals("")?"N/A":request.getParameter("dosis"+i));
					cdo2.addColValue("frecuencia",request.getParameter("frecuencia"+i).trim().equals("")?"N/A":request.getParameter("frecuencia"+i));
					cdo2.addColValue("duracion",request.getParameter("duracion"+i).trim().equals("")?"N/A":request.getParameter("duracion"+i));
					cdo2.setAction(request.getParameter("action"+i));
						cdo2.setKey(i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iMed.put(cdo2.getKey(),cdo2);
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_indicacion="+noIndicacion+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&fg="+fg);
				return;
		}
		if(baction.equals("+"))//Agregar
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.addColValue("secuencia","0");
			cdo2.addColValue("tot_imp","0");
			cdo2.addColValue("invalido","N");
			cdo2.setAction("I");
			cdo2.setKey(iMed.size()+1);

			try
			{
				iMed.put(cdo2.getKey(),cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_indicacion="+noIndicacion+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&fg="+fg);
			return;
		}

				if (baction.equalsIgnoreCase("Guardar"))
				{
					if (al.size() == 0)
					{
						CommonDataObject cdo3 = new CommonDataObject();

						cdo3.setTableName("tbl_sal_salida_medicamento");
						cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
						cdo3.setAction("I");
						al.add(cdo3);
					}

					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
					SQLMgr.saveList(al,true);
					ConMgr.clearAppCtx(null);
				}
			}
			}
			else if(tab.equals("3")) //
			{
			 int size = 0;
		if (request.getParameter("dSize") != null) size = Integer.parseInt(request.getParameter("dSize"));

	iDieta.clear();
	vDieta.clear();
	al.clear();
		for (int i=0; i<size; i++)
		{
		 CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_sal_salida_dieta");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo="+request.getParameter("codigo"+i));

		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));

		cdo2.addColValue("tipo_dieta",request.getParameter("tipo_dieta"+i));
		cdo2.addColValue("descDieta",request.getParameter("descDieta"+i));
		cdo2.addColValue("subtipo_dieta",request.getParameter("subtipo_dieta"+i));
		cdo2.addColValue("descSubTipo",request.getParameter("descSubTipo"+i));
		cdo2.addColValue("observacion",request.getParameter("observacion"+i));

		if (request.getParameter("codigo"+i).equals("") || request.getParameter("codigo"+i).equals("0")) {
			cdo2.addColValue("codigo", "(select nvl(max(codigo),0)+1 from tbl_sal_salida_dieta)");
		} else cdo2.addColValue("codigo",request.getParameter("codigo"+i));

			cdo2.addColValue("code",request.getParameter("tipo_dieta"+i)+"-"+ request.getParameter("subtipo_dieta"+i));
		cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
		cdo2.setKey(i);
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
		itemRemoved = cdo2.getKey();
		if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
		else cdo2.setAction("D");
		}

			if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iDieta.put(cdo2.getKey(),cdo2);
				al.add(cdo2);
				if(!cdo2.getAction().trim().equals("D"))vDieta.add(cdo2.getColValue("code"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		}

		if (!itemRemoved.equals(""))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&fg="+fg);
			return;
		}

		if (baction != null && baction.equals("+")) {
		if (fg.equalsIgnoreCase("PSLO")) {
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setAction("I");
			cdo2.addColValue("codigo", "0");
			cdo2.setKey(iDieta.size()+1);

			try
			{
				iDieta.put(cdo2.getKey(),cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&fg="+fg);
		return;

		}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_salida_dieta");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
	}
else if(tab.equals("4")) //
{
	int size = 0;
		if (request.getParameter("cSize") != null) size = Integer.parseInt(request.getParameter("cSize"));
	iCuidado.clear();
	vCuidado.clear();
	al.clear();
		for (int i=0; i<size; i++)
		{
		 CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_sal_salida_cuidado");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo="+request.getParameter("codigo"+i));

		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("observacion",request.getParameter("observacion"+i));
		cdo2.addColValue("guia_id",request.getParameter("guia_id"+i));
		cdo2.addColValue("descGuia",request.getParameter("descGuia"+i));
		cdo2.addColValue("recomendaciones",request.getParameter("recomendaciones"));

		if (request.getParameter("codigo"+i).equals("0")) {
			cdo2.addColValue("codigo", "(select nvl(max(codigo),0)+1 from tbl_sal_salida_cuidado)");
		} else cdo2.addColValue("codigo",request.getParameter("codigo"+i));

		cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
		//cdo2.addColValue("codigo",request.getParameter("codigo"+i));
		cdo2.addColValue("guia_desc",request.getParameter("descGuia"+i));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion","sysdate");
		if (cdo2.getAction().equalsIgnoreCase("I")) {
			cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo2.addColValue("fecha_creacion","sysdate");
		}
		cdo2.setKey(i);


		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iCuidado.put(cdo2.getKey(),cdo2);
				if(!cdo2.getAction().trim().equals("D"))vCuidado.add(cdo2.getColValue("guia_id"));
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		}

		if (!itemRemoved.equals(""))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&fg="+fg);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
		if (fg.equalsIgnoreCase("PSLO")) {
			CommonDataObject cdo2 = new CommonDataObject();
			cdo2.setAction("I");
			cdo2.addColValue("codigo", "0");
			cdo2.setKey(iCuidado.size()+1);

			try
			{
				iCuidado.put(cdo2.getKey(),cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&type=4&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&fg="+fg);
		return;
		}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_salida_cuidado");
			if (request.getParameter("recomendaciones")!= null && !"".equals(request.getParameter("recomendaciones"))) {
				cdo3.addColValue("codigo", "(select nvl(max(codigo),0)+1 from tbl_sal_salida_cuidado)");
				cdo3.addColValue("recomendaciones", request.getParameter("recomendaciones"));
				cdo3.addColValue("pac_id",request.getParameter("pacId"));
				cdo3.addColValue("admision",request.getParameter("noAdmision"));
				cdo3.addColValue("guia_id", "-1");
				cdo3.addColValue("guia_desc", "NA");
				cdo3.addColValue("observacion", "NA");
			} else cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
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
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&tab=<%=tab%>&desc=<%=desc%>&no_indicacion=<%=noIndicacion%>&no_dosis=<%=noDosis%>&no_frecuencia=<%=noFrecuencia%>&no_duracion=<%=noDuracion%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
