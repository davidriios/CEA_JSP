
<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PresMgr.setConnection(ConMgr);


String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");

if (mode == null) mode = "add";
if (fg == null) fg = "";
if(anio ==null)anio=""+(Integer.parseInt(cDateTime.substring(6, 10))+1);
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Envio  de Presupuesto - '+document.title;
function doAction()
{
}
function selUnidad()
{
abrir_ventana('../inventario/sel_unid_ejec.jsp?fg=ENVPRES');
}
function enviarPres(fp)
{
	var fg = '<%=fg%>';
	document.form0.baction.value = fp;
	var anio = document.form0.anio.value;
	var unidad = document.form0.unidad.value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	var table ='';
	var filter ='',msg='';
	
	if (fg =='PO'){ table ='tbl_con_ante_cuenta_anual';msg='Una vez que el presupuesto es ENVIADO no podrá efectuar modificaciones al mismo.  Seguro que desea ejecutarlo?';filter='and unidad = ';}else{ table ='tbl_con_ante_inversion_anual';msg='Este proceso cambiará el estado del presupuesto de BORRADOR a ENVIADO para su revisión. Una vez que el estado es cambiado no podrá efectuar modificaciones al mismo. Seguro que desea ejecutarlo?';filter=' and codigo_ue =';  }


	if(unidad != ''){
	
var enviado  =getDBData('<%=request.getContextPath()%>','nvl(count(*),0)',table,'anio='+anio+filter+unidad+' and compania='+compania+'and estado <> \'E\'','');

if (enviado ==0)
{
	alert('	El presupuesto de la Unidad seleccionada ya fue enviado o no tiene un presupuesto registrado para el año indicado... Verifique');
}
else{
		if(confirm(msg))
		{
			document.form0.submit();
		}
		else alert('Proceso Cancelado por el Usuario..');

	}
	}else alert('Seleccione unidad Administrativa');

}
function rechazarPres(fp)
{
	var fg = '<%=fg%>';
	document.form0.baction.value = fp;
	var anio = document.form0.anio.value;
	var unidad = document.form0.unidad.value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	var table ='';
	var filter ='';
	
	if (fg =='PO') table ='tbl_con_ante_cuenta_anual';else table ='tbl_con_ante_inversion_anual';
	if (fg =='PO') filter='and unidad = ';else filter=' and NVL(APROBADO,\'N\')  =\'N\' and codigo_ue =';  
	

	if(unidad != ''){
	
var enviado  =getDBData('<%=request.getContextPath()%>','nvl(count(*),0)',table,' anio='+anio+filter+unidad+' and compania='+compania+' and estado <> \'B\'','');

if (enviado ==0)
{
	alert('	El presupuesto de la Unidad seleccionada está en estado BORRADOR');
}
else{
		if(confirm('Este proceso cambiará el estado del presupuesto de ENVIADO a BORRADOR para su modificación y ajuste por parte del Jefe responsable. Seguro que desea ejecutarlo??'))
		{
			document.form0.submit();
		}
		else alert('Proceso Cancelado por el Usuario..');

	}
	}else alert('Seleccione unidad Administrativa');

}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ENVIO DE PRESUPUESTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextRow01">
					<td width="20%"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
					<td width="80%"><%=fb.textBox("unidad","",true,false,false,10)%>
					<%=fb.textBox("descUnidad","",false,false,true,40)%>
									<%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:selUnidad()\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Presupuesto</cellbytelabel> <%=(fg.trim().equals("OP"))?"Operativo":" de Inversiones"%> del año:</td>
					<td><%=fb.textBox("anio",anio,true,false,false,10)%></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center">
   <authtype type='50'><%=fb.button("enviar","* * * ENVIAR PRESUPUESTO PREELIMINAR PARA PREAPROBACION * * *",false,false,"","","onClick=\"javascript:enviarPres('enviar')\"")%></authtype>
   <authtype type='51'><%=fb.button("rechazar","* * * RECHAZAR PRESUPUESTO PREELIMINAR * * *",false,false,"","","onClick=\"javascript:rechazarPres('rechazar')\"")%></authtype>
					</td>
				</tr>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
 String baction = request.getParameter("baction");

	Presupuesto presup = new Presupuesto();
	
	presup.setFg(fg);
	presup.setUnidad(request.getParameter("unidad"));
	presup.setAnio(request.getParameter("anio"));
	presup.setPreaprobadoUsuario((String) session.getAttribute("_userName"));
	presup.setCompania((String) session.getAttribute("_companyId"));
	presup.setUsuarioModificacion((String) session.getAttribute("_userName"));
	presup.setPreaprobadoFecha(cDateTime);
	
	
	if (baction != null && baction.equalsIgnoreCase("enviar"))
	{presup.setEstado("E");presup.setFechaEnvio(cDateTime.substring(0,10));}
	else if (baction != null && baction.equalsIgnoreCase("rechazar"))
	{presup.setEstado("B");presup.setFechaRechazo(cDateTime);}
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null)
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
<%
if (PresMgr.getErrCode().equals("1"))
{
%>
	alert('<%=PresMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/param_envio_pres.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/param_envio_pres.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/presupuesto/param_envio_pres.jsp?fg=<%=fg%>&anio=<%=anio%>';
<%
	}
%>
	//window.close();
<%
} else throw new Exception(PresMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

