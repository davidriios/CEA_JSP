<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="issi.presupuesto.PresDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCta" scope="session" class="java.util.Vector"/>
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PresMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String change = request.getParameter("change");
String consec = request.getParameter("consec");
int lastLineNo = 0;
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

boolean viewMode = false;
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;
if (consec == null) consec = "";

if (fg == null) throw new Exception("El Tipo de Comprobante no es válido. Por favor intente nuevamente!");
if (fp == null || fp.trim().equals(""))fp="comp_diario";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	<%
if (mode != null && !mode.trim().equals("view"))
{
%>
parent.form1BlockButtons(false);<%}%>

	calc(false);
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var totalDb=0.00,totalCr=0.00;
	var size=parseInt(document.form1.size.value,10);

	for(i=1;i<=size;i++)
	{
		var asignacion=eval('document.form1.asignacion'+i).value;
		if(asignacion !='' && asignacion != 'null')
		{totalDb+=parseFloat(asignacion); }
	}
	parent.document.form1.solicitado.value=(totalDb).toFixed(2);
	parent.document.form1.totalSolicitado2.value=(totalDb).toFixed(2);
	parent.document.form1.totalSolicitado.value=(totalDb).toFixed(2);
}

function doSubmit()
{
	var error=0;
	if(parent.form1Validation())
	{
		if(form1Validation())
		{
			document.form1.baction.value 				= parent.document.form1.baction.value;
			document.form1.anio.value 					= parent.document.form1.anio.value;
			document.form1.compania.value				= parent.document.form1.compania.value;
			document.form1.tipoInv.value 				= parent.document.form1.tipoInv.value;
			document.form1.descripcion.value		    = parent.document.form1.descripcion.value;
			document.form1.comentario.value 			= parent.document.form1.comentario.value;
			document.form1.consec.value 				= parent.document.form1.consec.value;
			document.form1.categoria.value 				= parent.document.form1.categoria.value;
			document.form1.estado.value 				= parent.document.form1.estado.value;
			document.form1.cantidad.value 				= parent.document.form1.cantidad.value;
			document.form1.prioridad.value 				= parent.document.form1.prioridad.value;

			if(parent.document.form1.tipoEntrada[0].checked)document.form1.tipoEntrada.value=parent.document.form1.tipoEntrada[0].value;
				else if(parent.document.form1.tipoEntrada[1].checked)document.form1.tipoEntrada.value=parent.document.form1.tipoEntrada[1].value;


			document.form1.destinoFinal.value 			= parent.document.form1.destinoFinal.value;
			document.form1.solicitado.value 			= parent.document.form1.solicitado.value;

			document.form1.precioCotUnt.value 			= parent.document.form1.precioCotUnt.value;
			document.form1.observaciones.value 			= parent.document.form1.observaciones.value;
			document.form1.codigoProveedor.value 		= parent.document.form1.codigoProveedor.value;
			//document.form1.descProveedor.value 			= parent.document.form1.descProveedor.value;
			document.form1.unidad.value 				= parent.document.form1.unidad.value;
			document.form1.preaprobado.value 		= parent.document.form1.preaprobado.value;
			document.form1.preaprobadoFecha.value 	= parent.document.form1.preaprobadoFecha.value;
			document.form1.preaprobadoUsuario.value = parent.document.form1.preaprobadoUsuario.value;
			document.form1.saveOption.value 		= parent.document.form1.saveOption.value;
			document.form1.fechaCreacion.value 		= parent.document.form1.fechaCreacion.value;
			document.form1.usuarioCreacion.value 	= parent.document.form1.usuarioCreacion.value;
			document.form1.fechaEnvio.value 		= parent.document.form1.fechaEnvio.value;
			document.form1.fechaRechazo.value 		= parent.document.form1.fechaRechazo.value;
			document.form1.motivoRechazo.value 		= parent.document.form1.motivoRechazo.value;
			document.form1.origen.value 			= parent.document.form1.origen.value;

			document.form1.voboEstado.value 		= parent.document.form1.voboEstado.value;
			document.form1.voboUsuario.value 		= parent.document.form1.voboUsuario.value;
			document.form1.voboFecha.value 		= parent.document.form1.voboFecha.value;


			if(document.form1.baction.value=='Guardar' ||document.form1.baction.value=='Enviar')document.form1.submit();

		}
		else error++;
	}
	else error++;

	if(error>0)
	{
		parent.form1BlockButtons(false);
		form1BlockButtons(false);
		return false;
	}
}

function addAccount(objVal)
{
	if(parent.document.form1.anio.value!='')
	{
		setBAction('form1',objVal);
		document.form1.submit();
	}
	else
	{
		alert('Por favor introduzca el año!');
		parent.document.form1.anio.focus();
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iCta.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("compania","")%>
<%=fb.hidden("tipoInv","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("comentario","")%>
<%=fb.hidden("consec",consec)%>
<%=fb.hidden("categoria","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("cantidad","")%>
<%=fb.hidden("prioridad","")%>
<%=fb.hidden("tipoEntrada","")%>
<%=fb.hidden("destinoFinal","")%>
<%=fb.hidden("solicitado","")%>
<%=fb.hidden("precioCotUnt","")%>
<%=fb.hidden("observaciones","")%>
<%=fb.hidden("codigoProveedor","")%>
<%=fb.hidden("unidad","")%>
<%=fb.hidden("preaprobado","")%>
<%=fb.hidden("preaprobadoFecha","")%>
<%=fb.hidden("preaprobadoUsuario","")%>
<%=fb.hidden("usuarioCreacion","")%>
<%=fb.hidden("fechaCreacion","")%>
<%=fb.hidden("fechaEnvio","")%>
<%=fb.hidden("fechaRechazo","")%>
<%=fb.hidden("motivoRechazo","")%>
<%=fb.hidden("origen","")%>
<%=fb.hidden("voboEstado","")%>
<%=fb.hidden("voboUsuario","")%>
<%=fb.hidden("voboFecha","")%>
<%=fb.hidden("total","")%>
<%=fb.hidden("saveOption","")%>

<tr class="TextHeader02" align="center">
	<td width="20%"><cellbytelabel>Mes</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Asignaci&oacute;n</cellbytelabel></td>
	<td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
</tr>
<%
al = CmnMgr.reverseRecords(iCta);
for (int i=1; i<=iCta.size(); i++)
{
	key = al.get(i - 1).toString();
	PresDetail pres = (PresDetail) iCta.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("key"+i,pres.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("preaprobado"+i,pres.getPreaprobado())%>
<%=fb.hidden("estadoAprob"+i,pres.getEstadoAprob())%>
<%=fb.hidden("estado"+i,pres.getEstado())%>
<%=fb.hidden("preaprobadoFecha"+i,pres.getPreaprobadoFecha())%>
<%=fb.hidden("preaprobadoUsuario"+i,pres.getPreaprobadoUsuario())%>
<%=fb.hidden("usuarioCreacion"+i,pres.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion"+i,pres.getFechaCreacion())%>
<%=fb.hidden("usuarioAprob"+i,pres.getUsuarioAprob())%>
<%=fb.hidden("fechaAprob"+i,pres.getFechaAprob())%>
<%=fb.hidden("aprobado"+i,pres.getAprobado())%>
<%=fb.hidden("fechaEnvio"+i,pres.getFechaEnvio())%>
<%=fb.hidden("fechaRchazo"+i,pres.getFechaRechazo())%>

<tr class="TextRow01" align="center">

	<td><%=fb.textBox("mes"+i,pres.getMes(),false,false,true,3,"Text10",null,null)%>
	 <%=fb.select("mesDesde"+i,"01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",pres.getMes(),false,true,0,null,null,null,"","")%></td>
	<td><%=fb.decBox("asignacion"+i,pres.getAsignacion(),false,false,viewMode,8,"Text10",null,"onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.textarea("descripcion"+i,pres.getDescripcion(),false,false,viewMode,80,1,2000)%></td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	Presupuesto presup = new Presupuesto();

	presup.setFg("PI");
	presup.setUnidad(request.getParameter("unidad"));
	presup.setAnio(request.getParameter("anio"));
	if(request.getParameter("compania") != null && !request.getParameter("compania").trim().equals(""))
	presup.setCompania(request.getParameter("compania"));
	else presup.setCompania((String) session.getAttribute("_companyId"));
	presup.setTipoInv(request.getParameter("tipoInv"));
	presup.setDescripcion(request.getParameter("descripcion"));
	presup.setComentario(request.getParameter("comentario"));
	presup.setJustificacion(null);
	presup.setAsignacionActual(null);
	presup.setConsec(request.getParameter("consec"));
	presup.setCategoria(request.getParameter("categoria"));
	presup.setEstado(request.getParameter("estado"));
	presup.setCantidad(request.getParameter("cantidad"));
	presup.setPrioridad(request.getParameter("prioridad"));
	presup.setTipoEntrada(request.getParameter("tipoEntrada"));
	presup.setDestinoFinalBienactual(request.getParameter("destinoFinal"));
	presup.setSolicitado(request.getParameter("solicitado"));
	presup.setPrecioCotUnt(request.getParameter("precioCotUnt"));
	presup.setObservaciones(request.getParameter("observaciones"));
	presup.setCodigoProveedor(request.getParameter("codigoProveedor"));
	presup.setPreaprobado(request.getParameter("preaprobado"));
	presup.setPreaprobadoFecha(request.getParameter("preaprobadoFecha"));
	presup.setPreaprobadoUsuario(request.getParameter("preaprobadoUsuario"));
	presup.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	presup.setFechaCreacion(request.getParameter("fechaCreacion"));
	presup.setUsuarioModificacion((String) session.getAttribute("_userName"));
	presup.setFechaModificacion(cDateTime);
	presup.setFechaEnvio(request.getParameter("fechaEnvio"));
	presup.setFechaRechazo(request.getParameter("fechaRechazo"));
	presup.setMotivoRechazo(request.getParameter("motivoRechazo"));
	presup.setOrigen(request.getParameter("origen"));
	presup.setVoboEstado(request.getParameter("voboEstado"));
	presup.setVoboUsuario(request.getParameter("voboUsuario"));
	presup.setVoboFecha(request.getParameter("voboFecha"));

	if (baction != null && baction.equalsIgnoreCase("Enviar"))
	{
		presup.setEstado("E");
		presup.setFechaEnvio(cDateTime.substring(0,10));
	}


	String itemRemoved = "";
	for (int i=1; i<=size; i++)
	{
		PresDetail presDet = new PresDetail();
		if(request.getParameter("asignacion"+i) != null && !request.getParameter("asignacion"+i).trim().equals(""))
		{
			presDet.setKey(request.getParameter("key"+i));
			//presDet.setAnio(request.getParameter("anio"));
			presDet.setMes(request.getParameter("mes"+i));
			presDet.setAsignacion(request.getParameter("asignacion"+i));
			presDet.setPreaprobado(request.getParameter("preaprobado"+i));
			presDet.setEstadoAprob(request.getParameter("estadoAprob"+i));
			presDet.setEstado(request.getParameter("estado"+i));
			presDet.setDescripcion(request.getParameter("descripcion"+i));
			presDet.setPreaprobadoFecha(request.getParameter("preaprobadoFecha"+i));
			presDet.setPreaprobadoUsuario(request.getParameter("preaprobadoUsuario"+i));

			presDet.setFechaAprob(request.getParameter("fechaAprob"+i));
			presDet.setUsuarioAprob(request.getParameter("usuarioAprob"+i));
			presDet.setAprobado(request.getParameter("aprobado"+i));

			presDet.setFechaCreacion(request.getParameter("fechaCreacion"+i));
			presDet.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
			presDet.setFechaModificacion(cDateTime);
			presDet.setUsuarioModificacion((String) session.getAttribute("_userName"));
			presDet.setFechaEnvio(request.getParameter("fechaEnvio"+i));
			presDet.setFechaRechazo(request.getParameter("fechaRechazo"+i));

			if (baction != null && baction.equalsIgnoreCase("Enviar"))
			{
				presDet.setEstado("E");
				presDet.setFechaEnvio(cDateTime.substring(0,10));
			} else presDet.setEstado("B");

			presup.getPresDetail().add(presDet);
		}

	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"baction="+baction+"&mode="+mode+"&fp="+fp+"&fg="+fg);
	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{

		if(mode.trim().equals("add")){PresMgr.add(presup);consec = PresMgr.getPkColValue("consec");}
		else PresMgr.updateInv(presup);
	}
	else if (baction != null && baction.equalsIgnoreCase("Enviar"))
	{
		PresMgr.enviarPres(presup);

	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (PresMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=PresMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=PresMgr.getErrMsg()%>';
	parent.document.form1.consec.value = '<%=consec%>';
	parent.document.form1.compania.value = '<%=presup.getCompania()%>';
	parent.document.form1.submit();
	<%} else throw new Exception(PresMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>