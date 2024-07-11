<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DatosCirugia"%>
<%@ page import="issi.expediente.DetalleRecuperacion"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="DCMgr" scope="page" class="issi.expediente.DatosCirugiaMgr" />
<jsp:useBean id="iHashAnest" scope="session" class="java.util.Hashtable" />
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
DCMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

DatosCirugia cirugia = new DatosCirugia();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (desc == null) desc = "";

String filter = "";
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int tHe=0, tM15=0, tM30=0, tM60=0, tM90=0, tM120=0, tHs=0;
String id_cirugia = request.getParameter("id_cirugia");
String key = "";
int ld = 0;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (id_cirugia != null && !id_cirugia.trim().equals("") && id_cirugia.equals("0"))
	{
		 if (!viewMode) modeSec ="add";
		//viewMode = false;
	}
	if (id_cirugia != null && !id_cirugia.trim().equals("") && id_cirugia.equals("0")) filter = id_cirugia;
	else filter = "(select nvl(max(codigo),0) elMax from TBL_SAL_DATOS_CIRUGIA where pac_id="+pacId+" and secuencia="+noAdmision+")";
	iHashAnest.clear();
	sql = "select codigo, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi am') as fecha_creacion, to_char(fecha_registro,'dd/mm/yyyy') as fecha_registro, usuario_creacion, usuario_modif, to_char(fecha_modif,'dd/mm/yyyy hh12:mi am') as fecha_modif from tbl_sal_datos_cirugia where pac_id="+pacId+" and secuencia="+noAdmision+"order by codigo desc";
	al2 = SQLMgr.getDataList(sql);
	for (int i=1; i<=al2.size(); i++)
	{
		cdo = (CommonDataObject) al2.get(i-1);
		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;
		cdo.addColValue("key",key);
		try
		{
			iHashAnest.put(key, cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}//for

	sql = "select a.codigo, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, nvl(to_char(a.hora_inicio,'hh12:mi:ss am'),' ') as horaInicio, nvl(to_char(a.hora_final,'hh12:mi:ss am'),' ') as horaFinal, a.tipo_cirugia as tipoCirugia, a.procedimiento, diagnostico, observaciones, emp_provincia as empProvincia, emp_sigla as empSigla, a.emp_tomo as empTomo, a.emp_asiento as empAsiento, a.emp_compania as empCompania, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif, nvl(to_char(a.hora_anes,'hh12:mi:ss am'),' ') as horaAnes, nvl(to_char(a.hora_anes_f,'hh12:mi:ss am'),' ') as horAnesF, a.emp_id as empId, a.procedimiento_desc as procedimientoDesc from tbl_sal_datos_cirugia a where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.codigo="+filter;
	cirugia = (DatosCirugia) sbb.getSingleRowBean(ConMgr.getConnection(), sql, DatosCirugia.class);
	if(cirugia == null)
	{
		cirugia = new DatosCirugia();
		cirugia.setCodigo("0");
		cirugia.setFechaRegistro(cDateTime.substring(0,10));
		cirugia.setHoraInicio("");
		cirugia.setHoraFinal("");
		cirugia.setEmpCompania((String) session.getAttribute("_companyId"));
		//cirugia.setTipoCirugia("PRO");//('CME', 'PRO', 'CMA'
		cirugia.setDiagnostico("490");
		cirugia.setUsuarioCreacion(UserDet.getUserName());
		cirugia.setUsuarioModif(UserDet.getUserName());
		cirugia.setFechaCreacion(cDateTime);
		cirugia.setFechaModif(cDateTime);
		cirugia.setHoraAnes("");
		cirugia.setHoraAnesF("");
		if (!viewMode) modeSec = "add";
	}else {
    if (cirugia.getFechaRegistro() != null && !cirugia.getFechaRegistro().equals(cDateTime.substring(0,10))) viewMode = true;
    if (!viewMode) modeSec = "edit";
  }
	
	sql = "select b.dat_cirugia as datCirugia, a.codigo, 0 as codAnestesia, a.descripcion, -1 as codEscala,  b.minutos, nvl(b.escala_he,-1) as escalaHe, nvl(b.escala_min15,-1) as escalamin15, nvl(b.escala_min30,-1) as escalamin30, nvl(b.escala_min60,-1) as escalamin60, nvl(b.escala_min90,-1) as escalamin90, nvl(b.escala_min120,-1) as escalamin120, nvl(b.escala_hs,-1) as escalaHs from TBL_SAL_RECUPERACION_ANESTESIA a, (select dat_cirugia, recup_anestesia, detalle_recup, minutos, escala_he, escala_min15, escala_min30, escala_min60, escala_min90, escala_min120, escala_hs from TBL_SAL_RECUPERACION where pac_id="+pacId+" and secuencia="+noAdmision+"and dat_cirugia="+filter+" order by 2) b where a.codigo=b.recup_anestesia(+) union select 0, a.recup_anestesia, a.codigo, a.descripcion, a.escala as escala, -1, -1, 00, 00, 00, 00, 00, 00 FROM TBL_SAL_DETALLE_RECUPERACION a order by 2, 3";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'RECUPERACION DE ANESTESIA - '+document.title;
function setEscala(val,k,cod){
	var campo=eval('document.form0.time').value;
	eval('document.form0.'+campo+k).value=val;
	if(eval('document.form0.valAnterior').value!="0"){
		eval('document.form0.total'+campo).value=parseInt(eval('document.form0.total'+campo).value)-parseInt(eval('document.form0.valAnterior').value);
		eval('document.form0.total'+campo).value=parseInt(eval('document.form0.total'+campo).value)+parseInt(eval('document.form0.'+campo+k).value);
	}else eval('document.form0.total'+campo).value=parseInt(eval('document.form0.total'+campo).value)+parseInt(eval('document.form0.'+campo+k).value);
	eval('document.form0.valAnterior').value="0";
	ocultar('',k,'');
	eval('document.form0.codAnestesia'+k).value=cod;
}
function doAction(){setHeight();}
function setHeight(){newHeight();}
function ocultar(obj,nombreCapa,val){
	var escala = "obs-"+nombreCapa;
	if(document.getElementById(escala).style.visibility=="visible"){
		document.getElementById(escala).style.visibility="hidden";
		document.getElementById(escala).style.height="1";
		document.getElementById(escala).style.display="none";
	}else{
		document.getElementById(escala).style.visibility="visible";
		document.getElementById(escala).style.height="";
		document.getElementById(escala).style.display="";
	}
	if(val!=''){
		eval('document.form0.time').value=val;
		if(eval('document.form0.'+val+nombreCapa).value!="")eval('document.form0.valAnterior').value=eval('document.form0.'+val+nombreCapa).value;
		else eval('document.form0.valAnterior').value="0";
	}
	setHeight();
}
function procedimientoList(){abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=exp_recuperacion_anestesia');}
function setEvaluacion(k){
  var code=eval('document.listado.codigo'+k).value;
  var fecha=eval('document.listado.fechaRegistro'+k).value;
  var mode='view';
  if(fecha=='<%=cDateTime.substring(0,10)%>'){mode='edit';}
  window.location= '../expediente/exp_recuperacion_anestesia.jsp?modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_cirugia='+code+'&desc=<%=desc%>';
}
function add(){window.location='../expediente/exp_recuperacion_anestesia.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_cirugia=0&desc=<%=desc%>';}
function printExp(){var id_cirugia = document.getElementById("codigoCirugia").value;abrir_ventana("../expediente/print_exp_seccion_42.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&id_cirugia="+id_cirugia);}
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
	<td colspan="8">
		<div id="proc" width="100%" class="exp h100">
		<div id="proced" width="98%" class="child">
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td colspan="5">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
			<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%>&nbsp;&nbsp;<a href="javascript:printExp();" class="Link00">[Imprimir]</a></td>
		</tr>
		<tr class="TextHeader">
			<td width="5%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="4">Fecha creaci&oacute;n</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="4">Por</cellbytelabel></td>
            <td width="15%"><cellbytelabel id="4">Fecha modif.</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="4">Por</cellbytelabel></td>
			<td width="35%"></td>
		</tr>
<%
al2 = CmnMgr.reverseRecords(iHashAnest);
for (int i=1; i<=iHashAnest.size(); i++)
{
	key = al2.get(i-1).toString();
	CommonDataObject cdo1 = (CommonDataObject) iHashAnest.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
		<%=fb.hidden("fechaRegistro"+i,cdo1.getColValue("fecha_registro"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=i%>)" style="text-decoration:none; cursor:pointer">
			<td><%=cdo1.getColValue("codigo")%></td>
			<td><%=cdo1.getColValue("fecha_creacion")%></td>
			<td><%=cdo1.getColValue("usuario_creacion")%></td>
			<td><%=cdo1.getColValue("fecha_modif")%></td>
			<td><%=cdo1.getColValue("usuario_modif")%></td>
			<td></td>
		</tr>
<%
}
%>
<%=fb.formEnd(true)%>
		</table>
		</div>
		</div>
	</td>
</tr>
<tr>
	<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table width="100%" border="0" cellpadding="1" cellormcing="1">
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
<%=fb.hidden("time","")%>
<%=fb.hidden("valAnterior","0")%>
<%=fb.hidden("usuarioCreacion",cirugia.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",cirugia.getFechaCreacion())%>
<%=fb.hidden("usuarioModif",cirugia.getUsuarioModif())%>
<%=fb.hidden("fechaModif",cirugia.getFechaModif())%>
<%=fb.hidden("datCirugia",cirugia.getCodigo())%>
<%=fb.hidden("tipoCirugia",cirugia.getTipoCirugia())%>
<%=fb.hidden("diagnostico",cirugia.getDiagnostico())%>
<%=fb.hidden("empProvincia",cirugia.getEmpProvincia())%>
<%=fb.hidden("empSigla",cirugia.getEmpSigla())%>
<%=fb.hidden("empTomo",cirugia.getEmpTomo())%>
<%=fb.hidden("empAsiento",cirugia.getEmpAsiento())%>
<%=fb.hidden("empCompania",cirugia.getEmpCompania())%>
<%=fb.hidden("horaAnes",cirugia.getHoraAnes())%>
<%=fb.hidden("horaAnesF",cirugia.getHoraAnesF())%>
<%=fb.hidden("empId ",cirugia.getEmpId())%>
<%=fb.hidden("desc ",desc)%>
<%
if (id_cirugia != null && id_cirugia.trim().equals("0") ){
%>
<%=fb.hidden("codigoCirugia",""+id_cirugia)%>
<%}else{
CommonDataObject cdoCod = new CommonDataObject();
cdoCod = SQLMgr.getData(filter);
%>
<%=fb.hidden("codigoCirugia",cdoCod.getColValue("elMax"))%>
<%}%>
		<tr class="TextRow01">
			<td colspan="8">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="TextRow01">
				<tr>
					<td width="25%">
						<cellbytelabel id="4">Fecha</cellbytelabel>:
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fechaRegistro" />
						<jsp:param name="valueOfTBox1" value="<%=cirugia.getFechaRegistro()%>" />
						</jsp:include>
					</td>
					<td width="35%">
						<cellbytelabel id="5">Hora Entrada</cellbytelabel>:
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="hh12:mi:ss am"/>
						<jsp:param name="nameOfTBox1" value="horaInicio" />
						<jsp:param name="valueOfTBox1" value="<%=cirugia.getHoraInicio()%>" />
						</jsp:include>
					</td>
					<td width="40%">
						<cellbytelabel id="6">Hora Salida</cellbytelabel>:
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="hh12:mi:ss am"/>
						<jsp:param name="nameOfTBox1" value="horaFinal" />
						<jsp:param name="valueOfTBox1" value="<%=cirugia.getHoraFinal()%>" />
						</jsp:include>
					</td>
				</tr>
				<tr>
					<td><cellbytelabel id="7">Operaci&oacute;n</cellbytelabel></td>
					<td colspan="2">
						<%=fb.hidden("procedimiento",cirugia.getProcedimiento())%>
						<%=fb.textarea("procedimientoDesc",cirugia.getProcedimientoDesc(),true,false,viewMode,60,2,2000)%>
						<%//=fb.textBox("procedimiento",cirugia.getProcedimiento(),true,false,true,5)%>
						<%//=fb.textBox("desProc",cirugia.getDescripcion(),false,true,viewMode,55)%>
						<%//=fb.button("oper","...",true,viewMode,null,null,"onClick=\"javascript:procedimientoList()\"","seleccionar Operación")%>
					</td>
				</tr>
				<tr>
					<td><cellbytelabel id="8">Observaciones</cellbytelabel>: </td>
					<td colspan="2"><%=fb.textarea("observaciones",cirugia.getObservaciones(),false,false,viewMode,60,3,2000,null,null,null)%></td>
					<td>&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="8"><cellbytelabel id="9">Escala de Recuperaci&oacute;n Post - Anestesica</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="50%">&nbsp;</td>
			<td width="7%"><cellbytelabel id="10">HE</cellbytelabel></td>
			<td width="7%">15</td>
			<td width="7%">30</td>
			<td width="7%">60</td>
			<td width="7%">90</td>
			<td width="7%">120</td>
			<td width="7%"><cellbytelabel id="11">HS</cellbytelabel></td>
		</tr>
<%
String cod = "";
String codAnt = "";
int lc = 0;
for (int i=0; i<al.size(); i++)
{
	key = al.get(i).toString();
	cdo = (CommonDataObject) al.get(i);
	cod = cdo.getColValue("codigo");

	if(cdo.getColValue("escalaHe").equals("-1"))
	cdo.addColValue("escalaHe","");
	else tHe += (Integer.parseInt(cdo.getColValue("escalaHe")));
	if(cdo.getColValue("escalaMin15").equals("-1")) cdo.addColValue("escalaMin15","");
	else tM15 += Integer.parseInt(cdo.getColValue("escalaMin15"));
	if(cdo.getColValue("escalaMin30").equals("-1")) cdo.addColValue("escalaMin30","");
	else tM30 += Integer.parseInt(cdo.getColValue("escalaMin30"));
	if(cdo.getColValue("escalaMin60").equals("-1")) cdo.addColValue("escalaMin60","");
	else tM60 += Integer.parseInt(cdo.getColValue("escalaMin60"));
	if(cdo.getColValue("escalaMin90").equals("-1")) cdo.addColValue("escalaMin90","");
	else tM90 += Integer.parseInt(cdo.getColValue("escalaMin90"));
	if(cdo.getColValue("escalaMin120").equals("-1")) cdo.addColValue("escalaMin120","");
	else tM120 += Integer.parseInt(cdo.getColValue("escalaMin120"));
	if(cdo.getColValue("escalaHs").equals("-1")) cdo.addColValue("escalaHs","");
	else tHs += Integer.parseInt(cdo.getColValue("escalaHs"));
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(cdo.getColValue("codAnestesia").equals("0"))
	{
		color = "TextRow02";
		if (ld % 2 == 0) color = "TextRow01";
		ld++;
%>
		<%=fb.hidden("codigo"+ld,cdo.getColValue("codigo"))%>
		<%=fb.hidden("codAnestesia"+ld,cdo.getColValue("codAnestesia"))%>
		<tr align="center" class="<%=color%>">
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%=fb.intBox("he"+ld,cdo.getColValue("escalaHe"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','he')\"")%></td>
			<td><%=fb.intBox("min15"+ld,cdo.getColValue("escalaMin15"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','min15')\"")%></td>
			<td><%=fb.intBox("min30"+ld,cdo.getColValue("escalaMin30"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','min30')\"")%></td>
			<td><%=fb.intBox("min60"+ld,cdo.getColValue("escalaMin60"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','min60')\"")%></td>
			<td><%=fb.intBox("min90"+ld,cdo.getColValue("escalaMin90"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','min90')\"")%></td>
			<td><%=fb.intBox("min120"+ld,cdo.getColValue("escalaMin120"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','min120')\"")%></td>
			<td><%=fb.intBox("hs"+ld,cdo.getColValue("escalaHs"),false,false,viewMode,1,8,null,null,"onClick=\"javascript:ocultar(this,'"+ld+"','hs')\"")%></td>
		</tr>
		<tr class="<%=color%>">
			<td colspan="8">
				<div id="obs-<%=ld%>" style="visibility:hidden;display:none;">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="Textheader">
					<td width="10%">&nbsp;</td>
					<td width="60%"><cellbytelabel id="12">Descripci&oacute;n</cellbytelabel></td>
					<td  width="30%"><cellbytelabel id="13">Escala</cellbytelabel></td>
				</tr>
<%
	}
	else
	{
		if(!cdo.getColValue("codEscala").equals("-1"))//cod.equals(cdo.getColValue("codigo"))
		{
			lc++;
%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEscala(<%=cdo.getColValue("codEscala")%>,<%=ld%>,<%=cdo.getColValue("codAnestesia")%>)" style="cursor:pointer">
					<td>&nbsp;</td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("codEscala")%></td>
				</tr>
<%
		}
	}
	if(i<al.size()-1)
	{
		cdo = (CommonDataObject) al.get(i+1);
		codAnt = cdo.getColValue("codigo");
	}
	else
	{
%>
				</table>
				</div>
			</td>
		</tr>
<%
	}
	if(!codAnt.equals(cod))
	{
%>
				</table>
				</div>
			</td>
		</tr>
<%
	}
}
%>
		<tr class="TextRow01" align="center">
			<td align="right"><cellbytelabel id="14">Total</cellbytelabel>:</td>
			<td><%=fb.intBox("totalhe",""+tHe+"", false, false, true, 2)%></td>
			<td><%=fb.intBox("totalmin15",""+tM15+"", false, false, true, 2)%></td>
			<td><%=fb.intBox("totalmin30",""+tM30+"", false, false, true, 2, "Text10", "", "")%></td>
			<td><%=fb.intBox("totalmin60",""+tM60+"", false, false, true, 2, "Text10", "", "")%></td>
			<td><%=fb.intBox("totalmin90",""+tM90+"", false, false, true, 2, "Text10", "", "")%></td>
			<td><%=fb.intBox("totalmin120",""+tM120+"", false, false, true, 2, "Text10", "", "")%></td>
			<td><%=fb.intBox("totalhs",""+tHs+"", false, false, true, 2, "Text10", "", "")%></td>
		</tr>
		<tr class="TextRow02" align="right">
			<td colspan="8">
                <%=fb.hidden("saveOption","O")%>
				<!--<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
				<%//=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
				<%//=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="16">Mantener Abierto</cellbytelabel>
				<%//=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="17">Cerrar</cellbytelabel>-->
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.hidden("size",""+ld)%>
<%fb.appendJsValidation("if(error>0)setHeight();");%>
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

	DatosCirugia newdatos = new DatosCirugia();
	newdatos.setCodigo(request.getParameter("datCirugia"));
	newdatos.setSecuencia(request.getParameter("noAdmision"));
	newdatos.setCodPaciente(request.getParameter("codPac"));
	newdatos.setFecNacimiento(request.getParameter("dob"));
	newdatos.setFechaRegistro(request.getParameter("fechaRegistro"));
	newdatos.setHoraInicio(request.getParameter("horaInicio"));
	newdatos.setHoraFinal(request.getParameter("horaFinal"));
	newdatos.setTipoCirugia(request.getParameter("tipoCirugia"));
	newdatos.setProcedimiento(request.getParameter("procedimiento"));
	newdatos.setProcedimientoDesc(request.getParameter("procedimientoDesc"));
	newdatos.setDiagnostico(request.getParameter("diagnostico"));
	newdatos.setObservaciones(request.getParameter("observaciones"));
	newdatos.setEmpProvincia(request.getParameter("empProvincia"));
	newdatos.setEmpSigla(request.getParameter("empSigla"));
	newdatos.setEmpTomo(request.getParameter("empTomo"));
	newdatos.setEmpAsiento(request.getParameter("empAsiento"));
	newdatos.setEmpCompania(request.getParameter("empCompania"));
	newdatos.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	newdatos.setFechaCreacion(request.getParameter("fechaCreacion"));
	newdatos.setUsuarioModif(UserDet.getUserName());
	newdatos.setFechaModif(cDateTime);
	if(request.getParameter("horaInicio") != null)newdatos.setHoraInicio(request.getParameter("horaInicio"));
	else newdatos.setHoraInicio("");
	if(request.getParameter("horaFinal") != null)newdatos.setHoraFinal(request.getParameter("horaFinal"));
	else newdatos.setHoraFinal("");
	newdatos.setPacId(request.getParameter("pacId"));
	newdatos.setEmpId(request.getParameter("empId"));

	int size = 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
	for (int i=1; i<= size; i++)
	{
		DetalleRecuperacion detRec = new DetalleRecuperacion();
		//== null || request.getParameter("he"+i).trim().equals("")
		//if(!request.getParameter("he"+i).trim().equals("") )//&& !request.getParameter("codAnestesia"+i).equals("0"))
		//{
			detRec.setDatCirugia(request.getParameter("datCirugia"));
			detRec.setSecuencia(request.getParameter("noAdmision"));
			detRec.setCodPaciente(request.getParameter("codPac"));
			detRec.setFecNacimiento(request.getParameter("dob"));
			detRec.setRecupAnestesia(request.getParameter("codigo"+i));
			//detRec.setDetalleRecup(request.getParameter("codAnestesia"+i));
			//detRec.setMinutos(request.getParameter("minutos"));
			detRec.setEscalaHe(request.getParameter("he"+i));
			detRec.setEscalaMin15(request.getParameter("min15"+i));
			detRec.setEscalaMin30(request.getParameter("min30"+i));
			detRec.setEscalaMin60(request.getParameter("min60"+i));
			detRec.setEscalaMin90(request.getParameter("min90"+i));
			detRec.setEscalaMin120(request.getParameter("min120"+i));
			detRec.setEscalaHs(request.getParameter("hs"+i));
			detRec.setPacId(request.getParameter("pacId"));
			newdatos.addDetalleRecuperacion(detRec);
		//}
	}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) DCMgr.add(newdatos);
		else if (modeSec.equalsIgnoreCase("edit")) DCMgr.update(newdatos);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (DCMgr.getErrCode().equals("1"))
{
%>
	alert('<%=DCMgr.getErrMsg()%>');
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
} else throw new Exception(DCMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>