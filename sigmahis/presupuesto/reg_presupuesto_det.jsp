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
int lastLineNo = 0;
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

boolean viewMode = false;
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;

if (fg == null) throw new Exception("La Accion no es válido. Por favor intente nuevamente!");
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
	newHeight();
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

	parent.document.form1.total.value=(totalDb).toFixed(2);
	parent.document.form1.asignacion_actual.value=(totalDb).toFixed(2);
}

function doSubmit()
{
	var error=0;
	if(parent.form1Validation())
	{
		if(form1Validation())
		{
			document.form1.baction.value 				= parent.document.form1.baction.value;
			document.form1.anio.value 				= parent.document.form1.anio.value;
			document.form1.unidad.value		      = parent.document.form1.unidad.value;
			document.form1.cta1.value 					= parent.document.form1.cta1.value;
			document.form1.cta2.value 					= parent.document.form1.cta2.value;
			document.form1.cta3.value 					= parent.document.form1.cta3.value;
			document.form1.cta4.value 					= parent.document.form1.cta4.value;
			document.form1.cta5.value 					= parent.document.form1.cta5.value;
			document.form1.cta6.value 					= parent.document.form1.cta6.value;

			document.form1.compania.value		= parent.document.form1.compania.value;
			document.form1.asignacion_actual.value	= parent.document.form1.asignacion_actual.value;
			document.form1.estado.value					= parent.document.form1.estado.value;
			document.form1.justificacion.value		= parent.document.form1.justificacion.value;
			document.form1.saveOption.value 		= parent.document.form1.saveOption.value;
			document.form1.fechaCreacion.value 		= parent.document.form1.fechaCreacion.value;
			document.form1.usuarioCreacion.value 		= parent.document.form1.usuarioCreacion.value;


			document.form1.asignacionAnterior.value		= parent.document.form1.asignacionAnterior.value;
			document.form1.ejecutadoDic.value	= parent.document.form1.ejecutadoDic.value;
			document.form1.ejecutado.value					= parent.document.form1.ejecutado.value;
			document.form1.estadoAprob.value		= parent.document.form1.estadoAprob.value;
			document.form1.fechaAprob.value 		= parent.document.form1.fechaAprob.value;
			document.form1.usuarioAprob.value 		= parent.document.form1.usuarioAprob.value;
			document.form1.companiaOrigen.value 		= parent.document.form1.companiaOrigen.value;
			document.form1.preaprobado.value 		= parent.document.form1.preaprobado.value;
			document.form1.preaprobadoFecha.value 		= parent.document.form1.preaprobadoFecha.value;
			document.form1.preaprobadoUsuario.value 		= parent.document.form1.preaprobadoUsuario.value;
			document.form1.fechaEnvio.value 		= parent.document.form1.fechaEnvio.value;
			document.form1.fechaRechazo.value 		= parent.document.form1.fechaRechazo.value;

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
<%=fb.hidden("unidad","")%>
<%=fb.hidden("cta1","")%>
<%=fb.hidden("cta2","")%>
<%=fb.hidden("cta3","")%>
<%=fb.hidden("cta4","")%>
<%=fb.hidden("cta5","")%>
<%=fb.hidden("cta6","")%>
<%=fb.hidden("compania","")%>
<%=fb.hidden("asignacion_actual","")%>
<%=fb.hidden("justificacion","")%>
<%=fb.hidden("total","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("fechaCreacion","")%>
<%=fb.hidden("usuarioCreacion","")%>


<%=fb.hidden("estado","")%>
<%=fb.hidden("asignacionAnterior","")%>
<%=fb.hidden("ejecutadoDic","")%>
<%=fb.hidden("ejecutado","")%>
<%=fb.hidden("estadoAprob","")%>
<%=fb.hidden("fechaAprob","")%>
<%=fb.hidden("usuarioAprob","")%>

<%=fb.hidden("companiaOrigen","")%>
<%=fb.hidden("preaprobado","")%>
<%=fb.hidden("preaprobadoFecha","")%>
<%=fb.hidden("preaprobadoUsuario","")%>
<%=fb.hidden("fechaEnvio","")%>
<%=fb.hidden("fechaRechazo","")%>

<tr class="TextHeader01" align="center">

	<%if(fg.trim().equals("UPO")){%>
	<td width="20%"><cellbytelabel>Mes</cellbytelabel></td>
	<td width="15%"><cellbytelabel>Asignaci&oacute;n</cellbytelabel></td>
  	<td width="15%"><cellbytelabel>Estado</cellbytelabel></td>
	<td width="50%"><cellbytelabel>Consumido</cellbytelabel></td>
    <%}else{%>
	<td width="60%"><cellbytelabel>Mes</cellbytelabel></td>
	<td width="40%"><cellbytelabel>Asignaci&oacute;n</cellbytelabel></td>
	<%}%>
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
<%=fb.hidden("anterior"+i,pres.getAnterior())%>
<%=fb.hidden("estadoAprob"+i,pres.getEstadoAprob())%>
<%=fb.hidden("fechaAprob"+i,pres.getFechaAprob())%>
<%=fb.hidden("usuarioAprob"+i,pres.getUsuarioAprob())%>
<%//=fb.hidden("companiaOrigen"+i,pres.getCompaniaOrigen())%>

<%=fb.hidden("preaprobado"+i,pres.getPreaprobado())%>
<%=fb.hidden("preaprobadoFecha"+i,pres.getPreaprobadoFecha())%>
<%=fb.hidden("preaprobadoUsuario"+i,pres.getPreaprobadoUsuario())%>
<%=fb.hidden("fechaCreacion"+i,pres.getFechaCreacion())%>
<%=fb.hidden("usuarioCreacion"+i,pres.getUsuarioCreacion())%>
<%=fb.hidden("estado"+i,pres.getEstado())%>
<%=fb.hidden("fechaEnvio"+i,pres.getFechaEnvio())%>
<%=fb.hidden("redistribuciones"+i,pres.getRedistribuciones())%>
<%=fb.hidden("traslados"+i,pres.getTraslados())%>

<tr class="TextRow01" align="center">

	<td><%=fb.textBox("mes"+i,pres.getMes(),false,false,true,3,"Text10",null,null)%>
	 		<%=fb.select("mesDesde"+i,"01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",pres.getMes(),false,true,0,null,null,null,"","")%></td>
	<td><%=fb.decBox("asignacion"+i,pres.getAsignacion(),false,false,(viewMode ||fg.trim().equals("UPO")),8,"",null,"onChange=\"javascript:calc(false)\"")%></td>
	<%if(fg.trim().equals("UPO")){%>
	<td><%=fb.select("estadoDes"+i,"ACT=ACTIVO,INA=INACTIVO,CER=CERRADO",pres.getEstado(),false,true,0,null,null,null,"","")%></td>
  	<td><%=fb.decBox("consumido"+i,pres.getConsumido(),false,false,viewMode,8,"Text10",null,"")%></td>
    <%}%>
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

	presup.setFg(fg);

	presup.setUnidad(request.getParameter("unidad"));
	presup.setAnio(request.getParameter("anio"));
	presup.setCta1(request.getParameter("cta1"));
	presup.setCta2(request.getParameter("cta2"));
	presup.setCta3(request.getParameter("cta3"));
	presup.setCta4(request.getParameter("cta4"));
	presup.setCta5(request.getParameter("cta5"));
	presup.setCta6(request.getParameter("cta6"));

	if(request.getParameter("compania") != null && !request.getParameter("compania").trim().equals(""))
	presup.setCompania(request.getParameter("compania"));
	else presup.setCompania((String) session.getAttribute("_companyId"));

	presup.setDescripcion(null);
	presup.setComentario(null);
	presup.setJustificacion(null);
	presup.setAsignacionActual(null);
	if (fg.equalsIgnoreCase("PO"))
	{
		presup.setJustificacion(request.getParameter("justificacion"));
		presup.setAsignacionActual(request.getParameter("asignacion_actual"));
	}
	presup.setEstado(request.getParameter("estado"));
	presup.setFechaCreacion(request.getParameter("fechaCreacion"));
	presup.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	presup.setFechaModificacion(cDateTime);
	presup.setUsuarioModificacion((String) session.getAttribute("_userName"));

	presup.setAsignacionAnterior(request.getParameter("asignacionAnterior"));
	presup.setEjecutadoDic(request.getParameter("ejecutadoDic"));
	presup.setEjecutado(request.getParameter("ejecutado"));
	presup.setEstadoAprob(request.getParameter("estadoAprob"));
	presup.setFechaAprob(request.getParameter("fechaAprob"));
	presup.setUsuarioAprob(request.getParameter("usuarioAprob"));

	presup.setCompaniaOrigen(request.getParameter("companiaOrigen"));
	presup.setPreaprobado(request.getParameter("preaprobado"));
	presup.setPreaprobadoFecha(request.getParameter("preaprobadoFecha"));
	presup.setPreaprobadoUsuario(request.getParameter("preaprobadoUsuario"));
	presup.setFechaEnvio(request.getParameter("fechaEnvio"));
	presup.setFechaRechazo(request.getParameter("fechaRechazo"));

	if (baction != null && baction.equalsIgnoreCase("Enviar"))
	{
		presup.setEstado("E");
		presup.setFechaEnvio(cDateTime.substring(0,10));
		presup.setUsuarioEnvio((String) session.getAttribute("_userName"));
	}

	String itemRemoved = "";
	for (int i=1; i<=size; i++)
	{
		PresDetail presDet = new PresDetail();
		if((request.getParameter("asignacion"+i) != null && !request.getParameter("asignacion"+i).trim().equals(""))||fg.trim().equals("UPO") )
		{
			presDet.setKey(request.getParameter("key"+i));
			//presDet.setAnio(request.getParameter("anio"));
			presDet.setMes(request.getParameter("mes"+i));
			presDet.setAsignacion(request.getParameter("asignacion"+i));

			presDet.setFechaCreacion(request.getParameter("fechaCreacion"+i));
			presDet.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
			presDet.setFechaModificacion(cDateTime);
			presDet.setUsuarioModificacion((String) session.getAttribute("_userName"));

			presDet.setAnterior(request.getParameter("anterior"+i));
			presDet.setEstadoAprob(request.getParameter("estadoAprob"+i));

			presDet.setFechaAprob(request.getParameter("fechaAprob"+i));
			presDet.setUsuarioAprob(request.getParameter("usuarioAprob"+i));
			//presDet.setCompaniaOrigen(request.getParameter("companiaOrigen"+i));
			presDet.setPreaprobado(request.getParameter("preaprobado"+i));
			presDet.setPreaprobadoFecha(request.getParameter("preaprobadoFecha"+i));
			presDet.setPreaprobadoUsuario(request.getParameter("preaprobadoUsuario"+i));
			presDet.setEstado(request.getParameter("estado"+i));
			presDet.setFechaEnvio(request.getParameter("fechaEnvio"+i));
			presDet.setTraslados(request.getParameter("traslados"+i));
			presDet.setRedistribuciones(request.getParameter("redistribuciones"+i));
			if (baction != null && baction.equalsIgnoreCase("Enviar"))
			{
				presDet.setEstado("E");
				presDet.setFechaEnvio(cDateTime.substring(0,10));
			}
			if(fg.trim().equals("UPO"))
			{
				presDet.setConsumido(request.getParameter("consumido"+i));
			}

			presup.getPresDetail().add(presDet);
		}

	}


	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"baction="+baction+"&mode="+mode+"&fp="+fp+"&fg="+fg);
	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{

		if(mode.trim().equals("add"))PresMgr.add(presup);
		else PresMgr.update(presup);
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