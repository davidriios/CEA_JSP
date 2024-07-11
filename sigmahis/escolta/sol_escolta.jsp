<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String area = "", solicitado_por = "";
String cDate= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha = (request.getParameter("fecha")==null?cDate.substring(0,10):request.getParameter("fecha"));
String cdsFrom = request.getParameter("cdsFrom");
String cdsTo = request.getParameter("cdsTo");
String estado = request.getParameter("estado");
String searchBySolId = request.getParameter("searchBySolId");
String cUserName = (String) session.getAttribute("_userName");

String appendFilter = "";


if (cdsFrom == null) cdsFrom = "";

String cds1 = (String) session.getAttribute("COD_CENTRO1");//utilizado para listado inicial
String cds2 = (String) session.getAttribute("COD_CENTRO2");//utilizado para centros adicionales

String imageFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");

if (cds1 == null) cds1 = "";
if (cds2 == null) cds2 = "";
if (fp == null) fp = "";
String xCds = "";

if (!xCds.trim().equals("") && !cds2.trim().equals("") && !cds1.equals(cds2)) xCds += ","+cds2;
else if (!cds2.trim().equals("")) xCds = cds2;
if (xCds.trim().equals("")) throw new Exception("No hay centros de servicio registrado en las variables ambiente. Por favor consulte con su Administrador!");

if (mode == null) mode = "add";
if (fg == null) fg = "AE";
if (cdsFrom == null) cdsFrom = "";
if (cdsTo == null) cdsTo = "";
if (searchBySolId == null) searchBySolId = "";

if (fg.trim().equals("AE")){
	if (estado==null) estado = "T";
}else
if (fg.trim().equals("CR") || fg.trim().equals("CS")){
	estado = "E";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{

if (!fecha.trim().equals("")){
    appendFilter += " and trunc(s.fecha_ini_sol) = to_date('"+fecha+"','dd/mm/yyyy')";
}
if (!estado.trim().equals("") && !estado.trim().equals("T")){
    appendFilter += " and s.estado = '"+estado.toUpperCase()+"'";
}
if (!cdsFrom.trim().equals("")){
    appendFilter += " and s.del_cds in( "+cdsFrom+" )";
}
if (!cdsTo.trim().equals("")){
    appendFilter += " and s.al_cds in ( "+cdsTo+" )";
}
if (fg.trim().equals("CR")){
    appendFilter += " and s.al_cds is not null and s.sub_estado is not null";
}

//if (!fg.trim().equals("AE")) appendFilter += " and s.usuario_creacion = '"+cUserName+"' ";
if (!searchBySolId.trim().equals("")) appendFilter += " and s.id = "+searchBySolId;

sql = "select /*<SOL>*/ s.id id_sol,  decode( (select escolta_id from tbl_esc_hist_sol_escolta where sol_id = s.id and pac_id = s.pac_id and s.admision = admision and fg = '"+fg+"' and rownum = 1 ),null, s.escolta_id,(select escolta_id from tbl_esc_hist_sol_escolta where sol_id = s.id and pac_id = s.pac_id and s.admision = admision and fg = '"+fg+"' and rownum = 1) ) escolta_id, s.pac_id, s.admision, s.del_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.del_cds and rownum = 1) del_cds_dsp,  s.al_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.al_cds and rownum = 1) al_cds_dsp, s.cama_origen, s.cama_destino, s.observacion, to_char(s.fecha_ini_sol,'dd/mm/yyyy hh12:mi:ss am') f_ini_sol, to_char(s.fecha_fin_sol,'dd/mm/yyyy hh12:mi:ss am') fechaFinAtencion, s.usuario_creacion, to_char(s.fecha_creacion,'dd/mm/yyyy') f_crea, to_char(s.fecha_modificacion,'dd/mm/yyyy') f_mod, s.usuario_modificacion, s.estado, decode(s.estado,'E','EJECUTANDO','C','CANCELADA','F','FINALIZADA','P','PENDIENTE') estado_desc, s.cat_admision, s.observ, to_char(s.fecha_ini_ejec,'dd/mm/yyyy hh12:mi:ss am') fechaIncioAtencion, decode(s.sub_estado,'RECO','RECOGIDO DEL ORIGEN','RECD','RECIBIDO EN DESTINO','REG','REGRESARON AL ORIGEN','RETPAC','RETORNO ACTIVO','LIBESC','PROCESO LARGO') estadoActual, s.sub_estado, decode(s.sub_estado,'RECO',s.entregado_por,'RECD',s.recibido_por,'REG',s.recibido_regreso_por) subEstadoPor, decode(s.sub_estado,'RECO',to_char(s.fecha_entregado,'dd/mm/yyyy hh12:mi:ss am'),'RECD',to_char(s.fecha_recibido,'dd/mm/yyyy hh12:mi:ss am'),'REG',to_char(s.fecha_regreso,'dd/mm/yyyy hh12:mi:ss am'),sysdate) fechaSubEstado, s.tipo_sol, decode(s.tipo_sol,'T','TEMPORAL','PERMAMENTE') tipoSolDesc /*</SOL>*/ , /*<PAC>*/ p.nombre_paciente, p.id_paciente ced_pac /*</PAC>*/  ,/*<ESC>*/  decode(e.emp_id,null,'EXT','INT') tipo_esc, e.id id_esc, decode((select escolta_id from tbl_esc_hist_sol_escolta where sol_id = s.id and pac_id = s.pac_id and s.admision = admision and fg = '"+fg+"' and rownum = 1 ), null,e.primer_nombre||' '||e.segundo_nombre||' '||e.primer_apellido||' '||e.segundo_apellido, (select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido from tbl_esc_escolta where id = (select escolta_id from tbl_esc_hist_sol_escolta where sol_id = s.id and pac_id = s.pac_id and s.admision = admision and fg = '"+fg+"' and rownum = 1)) ) nombre_esc , coalesce(e.pasaporte,decode (e.provincia, 0, '', 00, '', e.provincia)|| decode (e.sigla, '00', '', '0', '', e.sigla)|| '-'|| e.tomo|| '-'|| e.asiento) ced_esc, e.emp_id, decode(image_path,null,' ','"+imageFolder.replaceAll(rootFolder,"..")+"/'||image_path) as foto /*</ESC>*/, observacion_cs, observacion_cr, (select id from tbl_esc_hist_sol_escolta where sol_id = s.id and pac_id = s.pac_id and s.admision = admision and fg = '"+fg+"' and rownum = 1) id_sol_hist from tbl_esc_sol_escolta s, vw_adm_paciente p, tbl_adm_admision a, tbl_esc_escolta e where s.pac_id = p.pac_id and p.pac_id = a.pac_id and s.admision = a.secuencia and a.pac_id = s.pac_id and s.escolta_id = e.id(+) /*<FILTRO>*/ "+appendFilter+" /*</FILTRO>*/";

  al = SQLMgr.getDataList(sql);

System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::::::::: PROCESSING..."+fg);

  String estadoDsp = "T=TODAS,E=EJECUTANDO,C=CANCELADA,F=FINALIZADA,P=PENDIENTE";
  if (!fg.trim().equals("AE")) {estado = "E"; estadoDsp="E=EJECUTANDO";}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Solicitudes - "+document.title;
function doAction(){loaded=false;
	/*var navig_agt = navigator.userAgent.toLowerCase();
var navig_kqr;
var navig_fox;
var navig_ie5;
var navig_chr;*/

	checkPendingOM();
	timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','_reload()');
}
function refreshDetail(idSol){
	var fecha = document.getElementById("fecha").value;
	var estado = (document.getElementById("estado")!=null?document.getElementById("estado").value:"E");
	var cdsFrom = document.getElementById("cdsFrom").value;
	var cdsTo = document.getElementById("cdsTo").value;
	var searchBySolId = (document.getElementById("searchBySolId")!=null?document.getElementById("searchBySolId").value:"");
	var fg = '<%=fg%>';
	if (typeof idSol != "undefined") searchBySolId = idSol;

    window.location = '../escolta/sol_escolta.jsp?fecha='+fecha+'&cdsFrom='+cdsFrom+'&cdsTo='+cdsTo+'&fg='+fg+'&estado='+estado+'&searchBySolId='+searchBySolId;
	checkPendingOM();
}
function checkPendingOM(){
	var gSol= "<%=al.size()%>";
	var fg= "<%=fg%>";
	var estado ="";

	if(fg.trim()!="AE"){estado="E";}
	else{
		estado = (document.form1.estado!=null?document.form1.estado.value:"P");
	}
	//remove
	//estado = "P";
	if( (gSol)>0 && (estado=="P" && fg=='AE') || (estado=="E" && fg!='AE') ){
		document.getElementById('pendingMsg').style.display='';
		//setTimeout('replaySound(\'pendingSound\',5000)',10);
		soundAlert({delay:5000});
	}
}
//reg_sol_escolta.jsp?mode=add&pacId=18&noAdmision=2&fromCDS=3&fromBed= &cdsAdmDesc=SALA DE EMERGENCIAS&admCategory=2&__ct=1356533982048
//TODO: Choose patient and its admision
        //Choose fromCDS
        //Based on fromWorkList
function createNewReq(){abrir_ventana('../escolta/reg_sol_escolta.jsp?mode=add');}

function _reload(){window.location = window.location.href;}

function printReport(id){
	var fecha = document.getElementById("fecha").value;
	var cdsFrom = document.getElementById("cdsFrom").value;
	var cdsTo = document.getElementById("cdsTo").value;
	var estado = document.getElementById("estado").value;
	if (typeof id == "undefined"){
		//print all
		//abrir_ventana('print_sol_escolta.jsp?idSol=&fecha='+fecha+'&estado='+estado+'&cdsFrom='+cdsFrom+'&cdsTo='+cdsTo);

		//Remove, just for testing purpose
		abrir_ventana('print_comprobante_sol_escolta.jsp?idSol=25&escortId=5');
	}else{
		abrir_ventana('print_sol_escolta.jsp?idSol='+id);
	}
}

function updateSolStatus(ind){
	document.getElementById("currentIndex").value  = ind;
	document.getElementById("currentUrl").value  = window.location.href;
	var solId = document.getElementById("solId"+ind).value;
	var toCds = document.getElementById("toCds"+ind).value;
	var toCdsDesc = document.getElementById("toCdsDesc"+ind).value;
	var curStatus = (document.getElementById("estado"+ind) != null?document.getElementById("estado"+ind).value:"");
	var escortId = document.getElementById("escortId"+ind).value;
	var curSubStatus = (document.getElementById("subEstado"+ind) != null?document.getElementById("subEstado"+ind).value:"");
    var fechaFinAtencion = (document.getElementById("fechaFinAtencion"+ind) != null?document.getElementById("fechaFinAtencion"+ind).value:"");
	if (canSubmit(solId,curStatus, escortId,curSubStatus,toCds,toCdsDesc,fechaFinAtencion)) document.form1.submit();
	//if (canSubmit(solId,curStatus, escortId,curSubStatus,toCds,toCdsDesc,fechaFinAtencion)) console.log("thebrain............. POSTING");

}

function canSubmit(sol,curStatus, escortId,curSubStatus,toCds,toCdsDesc,fechaFinAtencion){
	var fg = "<%=fg%>";
   if (curSubStatus==""){
   	     if (curStatus=="F" && fechaFinAtencion==""){
   	     	alert("Por favor indique la fecha / hora fin atención<>"+curSubStatus);
   	     	return false;
   	     }else
		 if (curStatus=="F" && hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and id=\''+sol+'\' and sub_estado = \'LIBESC\' ','') ){
   	     	alert("La orden todavía no puede ser finalizada!");
   	     	return false;
   	     }else
	   	 if(escortId == ""){
	   		alert("Para ejecutar la orden necesita asignarla a un escolta o anfitrión");
	   		return false;
	     }else
	     if( hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and id=\''+sol+'\'','') && curStatus=='E' ){
	      alert("Esta solicitud ya esta ejecutando!");
	      return false;
	     }else
	     if( hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and sub_estado is not null and id=\''+sol+'\'','') && curStatus=='C' ){
	      alert("Esta solicitud ya no puede ser ser cancelada!");
	      return false;
	     }else
		 if(fg=="CR"){
		    alert("Lo sentimos pero no sabemos que acción ejecutar!");
			return false;
		 }else
		 if(fg=="CS" && hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and id=\''+sol+'\' and sub_estado = \'RECO\' ','') ){
			alert("Lo sentimos pero no sabemos que acción ejecutar!");
			return false;
		 }
        return true;
    }else{
    	if(hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and sub_estado =\''+curSubStatus+'\' and id=\''+sol+'\'','')){
    		alert("Ya se ha ejecutado esta acción");
			return false;
    	}else
    	if( curSubStatus=="REG" && !hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and (sub_estado is not null and (sub_estado =\'RECO\' or sub_estado =\'RECD\' or sub_estado =\'RETPAC\')) and id=\''+sol+'\'','') ){
	        alert("No puede actualizar a RECIBE PACIENTE cuando aún no han salido!");
	        return false;
         }else
		 if( (curSubStatus=="RETPAC" || curSubStatus=="LIBESC") && !hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and (sub_estado is not null and (sub_estado =\'RECD\' or sub_estado =\'LIBESC\') ) and id=\''+sol+'\'','') ){
	        alert("Por favor indique primero RECIBO PACIENTE!!");
	        return false;
         }else
         if(toCds!="" && curSubStatus=="REG" && !hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and (sub_estado is not null and (sub_estado =\'RECD\' or sub_estado =\'RETPAC\') ) and id=\''+sol+'\'','') ){
         	alert("No ha llegado al destino ["+toCdsDesc+"] aún");
         	return false;
         }else
         if(fg=="CR" && toCds!="" && (curSubStatus !="RETPAC" && curSubStatus !="LIBESC") && !hasDBData('<%=request.getContextPath()%>','tbl_esc_sol_escolta','estado=\'E\' and (sub_estado is not null and sub_estado =\'RECO\') and id=\''+sol+'\'','') ){
         	alert("Aún no han salido del centro de origen<>!");
         	return false;
         }
		return true;
    }
//
}

function chooseEscort(ind){
	abrir_ventana('../common/search_escort.jsp?fp=escort&index='+ind);
}
</script>
<style type="text/css">
	.pointer{cursor: pointer; border: solid 1px;}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ANFITRIÓN O ESCOLTA - SOLICITUD DE ESCOLTA O ANFITRIÓN"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("clearHT","")%>
        		<%=fb.hidden("xCds",xCds)%>
				<%=fb.hidden("gSol","")%>
				<%=fb.hidden("currentIndex","")%>
				<%=fb.hidden("currentUrl","")%>

				<tr class="TextRow02">
					<td colspan="3" align="right">
					<% if (fg.trim().equals("AE")) {%>
						&nbsp;&nbsp;&nbsp;
						<img src="../images/printer.gif" width="48px" height="48px" alt="Imprimir Lista" class="pointer" onClick="javascript:printReport()">
						<%}%>
					</td>
				</tr>


				<tr><td colspan="3" style="background-color:green; color:#fff; font-weight:bold;"><label id="timerMsgTop"></label></td></tr>
				<tr class="TextRow01">
					<td class="TableBottomBorder" colspan="3">
						<table width="100%">
							<tr>
								<td><cellbytelabel id="2">Fecha</cellbytelabel>
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
									</jsp:include>&nbsp;&nbsp;

									<%if(fg.trim().equals("AE")){%>
								<cellbytelabel id="3">Estado</cellbytelabel>:<%=fb.select("estado",estadoDsp,estado,false,false,0,"",null,"onChange=\"javascript:refreshDetail()\"")%>&nbsp;&nbsp;
								#Sol.:&nbsp;<%=fb.textBox("searchBySolId",searchBySolId,false,false,false,10,10,null,null,"")%>&nbsp;&nbsp;&nbsp;
								<%}else{%>
								   #Sol.:&nbsp;<%=fb.textBox("searchBySolId",searchBySolId,false,false,false,10,10,null,null,"")%>&nbsp;&nbsp;&nbsp;
								<%}%>

								<cellbytelabel id="3">&Aacute;rea Origen</cellbytelabel>:
								<%//=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where codigo in ("+xCds+")","cdsFrom",cdsFrom,false,false,0,"Text10",null,null,null,(xCds.indexOf(",")==-1)?"":"T")%>

								<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where estado = 'A'","cdsFrom",cdsFrom,false,false,0,"Text10",null,null,null,"T")%>

								<cellbytelabel id="3">&Aacute;rea Destino</cellbytelabel>:
								<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where estado = 'A'","cdsTo",cdsTo,false,false,0,"Text10",null,null,null,"T")%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<%=fb.button("btnFiltro","IR",true,false,null,null,"onClick=\"javascript:refreshDetail()\"")%>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td width="15%">&nbsp;</td>
					<td width="70%" align="center"><font size="3" id="pendingMsg" style="display:none">Hay Solicitudes pendientes!</font><script language="javascript">blinkId('pendingMsg','red','white');</script><!--<embed id="pendingSound" src="../media/chimes.wav" autostart="false" width="0" height="0"></embed>--></td>
					<td width="15%" align="right">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">
						<!--<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="100%" scrolling="yes" frameborder="0" border="0" src="../expediente/sol_escolta_det.jsp?fecha=<%=fecha%>&cdsFrom=<%=(cdsFrom!=null && !cdsFrom.trim().equals(""))?cdsFrom:xCds%>&fg=<%=fg%>&estado=<%=estado%>" style="height:3000px" > </iframe>-->


						<table align="center" width="100%" cellpadding="1" cellspacing="1">

							<tr class="TextHeader">
								<td width="18%">Nombre Paciente</td>
								<td width="8%" align="center">PID - ADM.</td>
								<td width="10%" align="center">C&eacute;dula</td>
								<td width="15%">&Aacute;rea Actual</td>
								<td width="8%" align="center">Cama Actual</td>
								<td width="15%">&Aacute;rea Destino</td>
								<td width="8%" align="center">Cama Destino</td>
								<td width="18%" align="center">Acciones</td>
							</tr>


							<%
				String escortId = "", visibility="hidden";
				for (int i=0; i<al.size(); i++){
				 cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";

				// if ( !escortId.equals("escolta_id") ) {
			 %>
					<!--<tr class="TextHeader02">
						<td align="right">Escolta:&nbsp;&nbsp;&nbsp;</td>
						<td colspan="7"><%//=cdo.getColValue("nombre_esc")%> [<%//=cdo.getColValue("escolta_id")%>] [<%//=cdo.getColValue("ced_esc")%>]
						</td>
					</tr>-->
			    <% //} %>

			 <%if ( cdo.getColValue("sub_estado").equals("LIBESC") ) {%>
				<%=fb.hidden("escortId"+i,"")%>
			 <% }else{ %>
				<%=fb.hidden("escortId"+i,cdo.getColValue("escolta_id"))%>
			<% }%>

  				<%=fb.hidden("solId"+i,cdo.getColValue("id_sol"))%>
  				<%=fb.hidden("toCdsDesc"+i,cdo.getColValue("al_cds_dsp"))%>
  				<%=fb.hidden("toCds"+i,cdo.getColValue("al_cds"))%>
  				<%=fb.hidden("tipoSol"+i,cdo.getColValue("tipo_sol"))%>
  				<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
  				<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
				<%if(fg.trim().equals("AE")){%>
  				<%=fb.hidden("subEstadoTemp"+i,cdo.getColValue("sub_estado"))%>
  				<%=fb.hidden("idSolHist"+i,cdo.getColValue("id_sol_hist"))%>
				<%}%>

			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td><%=cdo.getColValue("nombre_paciente")%></td>
				<td align="center"><%=cdo.getColValue("pac_id")+" - "+cdo.getColValue("admision")%></td>
				<td align="center"><%=cdo.getColValue("ced_pac")%></td>
				<td>[<%=cdo.getColValue("del_cds")%>] <%=cdo.getColValue("del_cds_dsp")%></td>
				<td align="center"><%=cdo.getColValue("cama_origen")%></td>
				<% if ( !cdo.getColValue("al_cds").trim().equals("") ) {%>
					<td>[<%=cdo.getColValue("al_cds")%>] <%=cdo.getColValue("al_cds_dsp")%></td>
					<td align="center"><%=cdo.getColValue("cama_destino")%></td>
				<%}else{%>
				   <td colspan="2">[N/A]: <%=cdo.getColValue("observacion")%></td>
				<%}%>
				<td align="right">

					<%if ( fg.trim().equals("AE") && cdo.getColValue("id_sol_hist").trim().equals("") && (cdo.getColValue("estado").trim().equals("P")||cdo.getColValue("sub_estado").trim().equals("LIBESC")) ){%>
					   <img src="../images/edit.png" alt="Asignar Escolta" title="Asignar Escolta" onClick="javascript:chooseEscort('<%=i%>')" style="cursor:pointer" width="20px" height="20px">
					<%}%>

					<%

 						String ctrlEstado = "E=EJECUTAR,F=FINALIZAR,C=CANCELAR";
 						String escort = cdo.getColValue("escolta_id")==null?"":cdo.getColValue("escolta_id");
 						if (escort.trim().equals("")){
 						  ctrlEstado = "E=EJECUTAR,C=CANCELAR";
 						}else if (!escort.trim().equals("") && cdo.getColValue("estado").equals("E") && !cdo.getColValue("sub_estado").trim().equals("") ){
							ctrlEstado = "";
						    if (cdo.getColValue("sub_estado").trim().equals("LIBESC") && cdo.getColValue("id_sol_hist").trim().equals("") ) ctrlEstado += "R=REASIGNAR,";
 							ctrlEstado += "F=FINALIZAR";
 						}else if (cdo.getColValue("sub_estado").trim().equals("")){ctrlEstado = "C=CANCELAR";}

 						String ctrlSubEstado = "";

 						//Centro que solicita
						// DESPUES DE LOS ÚLTIMOS CAMBIOS
						//RECO: RECOGIDO ORIGEN
						//REG: RECIBE PACIENTE
						//RECD: RECIBIDO DESTINO

 						if (fg.trim().equals("CS")){
 							ctrlSubEstado = (cdo.getColValue("sub_estado")==null || cdo.getColValue("sub_estado").trim().equals("")?"RECO=ENTREGA PACIENTE":"");
 							if (cdo.getColValue("tipo_sol")!=null && cdo.getColValue("tipo_sol").equals("T")) ctrlSubEstado+=",REG=RECIBE PACIENTE";
 						}else
 						if (fg.trim().equals("CR")){
							// Centro que recibe (Si aplica)

							ctrlSubEstado = "";
						    if (cdo.getColValue("sub_estado").trim().equals("RECO")){
							   ctrlSubEstado = "RECD=RECIBIDO PACIENTE,";
							}
							if (cdo.getColValue("sub_estado").trim().equals("RECD") && cdo.getColValue("tipo_sol").trim().equals("T") ){
							   ctrlSubEstado = "LIBESC=SOL. LARGA,RETPAC=RETORNO";
							}
							if (cdo.getColValue("sub_estado").trim().equals("LIBESC")){
							   ctrlSubEstado = "RETPAC=RETORNO";
							}

 						}
					%>

					<!--CENTRO ANFITRION-->
                    <% if (fg.trim().equals("AE")) {%>

						<%=fb.select("estado"+i,ctrlEstado,cdo.getColValue("estado"),false,(cdo.getColValue("estado").trim().equals("C") || cdo.getColValue("estado").trim().equals("F")),0,"",null,"onChange=\"\"")%>
					<%}%>

					<!--CENTRO QUE SOLICITA: ACTUALIZA A RECOGIDO ORIGEN (RECO)-->
					<!--SI  ES TEMPORAL: ACTUALIZA A REGRESO (REG)-->

					<!-- CENTRO QUE RECIBE (SI APLICA): ACTUALIZA A RECIBO RECD-->

					<% if (fg.trim().equals("CS") || fg.trim().equals("CR")) {%>

						<%=fb.select("subEstado"+i,ctrlSubEstado,cdo.getColValue("sub_estado"),false,(!cdo.getColValue("estado").trim().equals("E")),0,"",null,"onChange=\"\"")%>
					<%}%>

					<%
						if (fg.trim().equals("CR") && cdo.getColValue("al_cds")!=null && !cdo.getColValue("al_cds").trim().equals("") && (!cdo.getColValue("sub_estado").trim().equals("RECD") || !cdo.getColValue("tipo_sol").trim().equals("P")) ){visibility="visible";}

						else if ((fg.trim().equals("CR") || fg.trim().equals("CS")) && cdo.getColValue("sub_estado")!=null && cdo.getColValue("sub_estado").trim().equals("REG")){visibility="hidden";}
						else if (fg.trim().equals("AE") &&  (cdo.getColValue("sub_estado") ==null || cdo.getColValue("sub_estado").trim().equals("") )  ){visibility="visible";}
						else if ( fg.trim().equals("CS")  && (cdo.getColValue("sub_estado")==null || cdo.getColValue("sub_estado").trim().equals("") || cdo.getColValue("al_cds").trim().equals("") )  ){visibility="visible";}

						else if ( fg.trim().equals("CS") && cdo.getColValue("tipo_sol").equals("T")  && (cdo.getColValue("sub_estado")==null || cdo.getColValue("sub_estado").trim().equals("RETPAC") )  ){visibility="visible";}


						else if (fg.trim().equals("AE") &&  (cdo.getColValue("sub_estado") !=null && (cdo.getColValue("sub_estado").trim().equals("REG") || cdo.getColValue("sub_estado").trim().equals("LIBESC")) )){visibility="visible";}

						else if (fg.trim().equals("AE") &&  ( cdo.getColValue("sub_estado") !=null && (  cdo.getColValue("sub_estado").trim().equals("RECO") && cdo.getColValue("tipo_sol").trim().equals("P") && cdo.getColValue("al_cds").trim().equals("")  ) )){visibility="visible";}

						System.out.println(":::::::::::::::::::::::::::::::::::::::::"+(cdo.getColValue("al_cds").trim().equals("") ));

					%>

					<% if ( cdo.getColValue("estado").trim().equals("P") || cdo.getColValue("estado").trim().equals("E") ) {%>
						<span id="panel<%=i%>" style="visibility:<%=visibility%>">
							<img src="../images/ok.gif" alt="Procesar" title="Procesar" onClick="javascript:updateSolStatus('<%=i%>')" style="cursor:pointer" width="20px" height="20px">
						</span>

					<%}else{%>
					    <img src="../images/readonly.png" alt="No esta pendiente" width="20px" height="20px">
					<%}%>
					<% if (fg.trim().equals("AE")) {%>
					<img src="../images/print_analysis.gif" alt="Imprimir orden" width="20px" height="20px" style="cursor:pointer" onClick="javascript:printReport('<%=cdo.getColValue("id_sol")%>')">
					<%}%>
				</td>
			</tr>

			<tr class="<%=color%>">
				<td colspan="8">
					<table width="100%" cellspacing="1" cellpadding="1">
						<tr>
							<td width="5%"><cellbytelabel>Anfitri&oacute;n</cellbytelabel>:</td>
							<td width="28%">
							<%if(!cdo.getColValue("sub_estado").trim().equals("LIBESC")){%>
							<%=fb.textBox("escInfo"+i,cdo.getColValue("nombre_esc")+" ["+cdo.getColValue("escolta_id")+"] ["+cdo.getColValue("ced_esc")+"]",false,false,true,40,0,null,null,"")%>

							<%if (!cdo.getColValue("foto").trim().equals("") && !fg.trim().equals("AE")){%>
							<img width="16" height="16" onmouseover="javascript:showImage('<%=cdo.getColValue("foto")%>')" onmouseout="javascript:hideImage()" src="../images/search.gif" border="0"/>
							<%}%>
							<%}else{%>
							   <%=fb.hidden("escInfo"+i,"")%>
							   <div>
							     <%=cdo.getColValue("nombre_esc")%>
								 <%if (!cdo.getColValue("foto").trim().equals("") && !fg.trim().equals("AE")){%>
								<img width="16" height="16" onmouseover="javascript:showImage('<%=cdo.getColValue("foto")%>')" onmouseout="javascript:hideImage()" src="../images/search.gif" border="0"/>
								<%}%>
							   </div>
							<%}%>
							</td>
							<td width="17%"><cellbytelabel>F.Sol</cellbytelabel>: <%=cdo.getColValue("f_ini_sol")%></td>
							<td width="50%">
								<% if (fg.trim().equals("AE")) {%>
								<cellbytelabel>Inicio Atenci&oacute;n</cellbytelabel>:
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="<%="fechaIncioAtencion"+i%>" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaIncioAtencion").trim().equals("")?cDate:cdo.getColValue("fechaIncioAtencion")%>" />
									<jsp:param name="readonly" value="<%=cdo.getColValue("estado").equals("P")?"n":"y"%>" />
									<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
									</jsp:include>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<cellbytelabel>Fin Atenci&oacute;n</cellbytelabel>:
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="<%="fechaFinAtencion"+i%>"  />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaFinAtencion")%>" />
									<jsp:param name="readonly" value="<%=cdo.getColValue("estado").equals("E")?"n":"y"%>" />
									<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
									</jsp:include>
									<%}else{%>
									<table width="100%">
									<% if (fg.trim().equals("CS")) {%>
									<tr><td>Observaci&oacute;n:</td> <td><%=fb.textarea("observacion_cs"+i,cdo.getColValue("observacion_cs"),false,false,false,40,2,300)%></td>
									<td align="center" class="Text12Bold"><a href="javascript:refreshDetail('<%=cdo.getColValue("id_sol")%>');">Filtrar</a> </td>
									 </tr>
									<%}%>

									<% if (fg.trim().equals("CR")) {%>
									 <tr><td>Observaci&oacute;n:</td> <td><%=fb.textarea("observacion_cr"+i,cdo.getColValue("observacion_cr"),false,false,false,40,2,300)%></td>
									<td align="center" class="Text12Bold"><a href="javascript:refreshDetail('<%=cdo.getColValue("id_sol")%>');">Filtrar</a> </td>
									 </tr>
									<%}%>
									</table>
									<%}%>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<% if (fg.trim().equals("AE") && ( !cdo.getColValue("observ").trim().equals("") || estado.trim().equals("T")  ) ){%>

				<tr class="<%=color%>">
					<td>Observaci&oacute;n</td>
					<td colspan="4">
						<%=fb.textarea("observ",cdo.getColValue("observ"),false,false,true,50,2,0)%>
					</td>
					<td colspan="2"><span class="Text12Bold">Estado</span>: <span class="GreenTextBold"><%=cdo.getColValue("estado_desc")%></span></td>
					<td align="center" class="Text12Bold"><a href="javascript:refreshDetail('<%=cdo.getColValue("id_sol")%>');">Filtrar</a> </td>
				</tr>

			<%} %>

             <%  if (fg.trim().equals("AE") && cdo.getColValue("estado").trim().equals("E") && !cdo.getColValue("sub_estado").trim().equals("") ){ %>

               <!--// only for Centro Anfitrion Escolta
               // Access control flag: fg = AE -->

               <tr class="<%=color%>">
               	 <td><cellbytelabel>Estado Actual:</cellbytelabel></td>
               	 <td colspan="2" id="estadoActual">
				 <label style="font-weight:bold;">
				 <%if(cdo.getColValue("sub_estado").equals("RETPAC") || cdo.getColValue("sub_estado").equals("LIBESC")){%>
						<span class="RedTextBold"><%=cdo.getColValue("estadoActual")%></span>
				 <%}else{%>
				    <%=cdo.getColValue("estadoActual")%>
				 <%}%>
				 </label></td>
               	 <td align="right"><cellbytelabel>Cambiado por:</cellbytelabel></td>
               	 <td colspan="2">
               	 	&nbsp;&nbsp;<%=cdo.getColValue("subEstadoPor")%>
               	 </td>
               	 <td colspan="2"><cellbytelabel>Cambiado el</cellbytelabel>: <%=cdo.getColValue("fechaSubEstado")%></td>
               </tr>

           	   <%}// Centro anfitrion escolta
           	   %>


			<%
			 } // for loop
			%>
						</table>

					</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
</body>
</html>
<%
}else{

	CommonDataObject cdoSolEscort = new CommonDataObject();
	CommonDataObject cdoSolHist = new CommonDataObject();
	String currentIndex = ( request.getParameter("currentIndex")==null?"":request.getParameter("currentIndex") );
	String solId = "", cEstado = "";

  	cdoSolEscort.setTableName("tbl_esc_sol_escolta");
	cdoSolHist.setTableName("tbl_esc_hist_sol_escolta");

  	if ( request.getParameter("estado"+currentIndex) != null || request.getParameter("subEstado"+currentIndex) != null){
	    cdoSolEscort.addColValue("usuario_modificacion",cUserName);
		cdoSolEscort.addColValue("fecha_modificacion",cDate);
  	    if (request.getParameter("fg")!=null && request.getParameter("fg").equals("AE") ){

			if (!request.getParameter("estado"+currentIndex).trim().equals("R") && (request.getParameter("subEstadoTemp"+currentIndex) == null || request.getParameter("subEstadoTemp"+currentIndex).equals("")) ){
				cdoSolEscort.addColValue("escolta_id",request.getParameter("escortId"+currentIndex));
		    }

			if (!request.getParameter("estado"+currentIndex).trim().equals("R")){
				cdoSolEscort.addColValue("estado",request.getParameter("estado"+currentIndex));
		    }else{cdoSolEscort.addColValue("estado","E");}

			if (request.getParameter("estado"+currentIndex).trim().equals("F")){
				cdoSolEscort.addColValue("fecha_fin_sol",request.getParameter("fechaFinAtencion"+currentIndex));
		    }
		    if (request.getParameter("estado"+currentIndex).trim().equals("E")){
				cdoSolEscort.addColValue("fecha_ini_ejec",request.getParameter("fechaIncioAtencion"+currentIndex));
		    }
		}else if (request.getParameter("fg")!=null && request.getParameter("fg").equals("CS") ){
			cdoSolEscort.addColValue("sub_estado",request.getParameter("subEstado"+currentIndex));
			cdoSolEscort.addColValue("observacion_cs",IBIZEscapeChars.forSingleQuots(request.getParameter("observacion_cs"+currentIndex)));

			if(request.getParameter("tipoSol"+currentIndex).equals("P")){
				cdoSolEscort.addColValue("entregado_por",cUserName);
				cdoSolEscort.addColValue("fecha_entregado",cDate);
			}else if(request.getParameter("tipoSol"+currentIndex).equals("T") ){

			    cdoSolEscort.addColValue("entregado_por",cUserName);
				cdoSolEscort.addColValue("fecha_entregado",cDate);

				if (request.getParameter("subEstado"+currentIndex).equals("REG")){
				  cdoSolEscort.addColValue("recibido_regreso_por",cUserName);
				  cdoSolEscort.addColValue("fecha_regreso",cDate);
			    }
	    	}

	    }else if (request.getParameter("fg")!=null && request.getParameter("fg").equals("CR") ){
	    	cdoSolEscort.addColValue("sub_estado",request.getParameter("subEstado"+currentIndex));
	    	cdoSolEscort.addColValue("recibido_por",cUserName);
			cdoSolEscort.addColValue("fecha_recibido",cDate);
			cdoSolEscort.addColValue("observacion_cr", IBIZEscapeChars.forSingleQuots(request.getParameter("observacion_cr"+currentIndex)));
	    }

		if (!currentIndex.trim().equals("")){
			solId = request.getParameter("solId"+currentIndex);
			cEstado = request.getParameter("estado"+currentIndex);
		}
		cdoSolEscort.setWhereClause("id = "+solId);

    }else{
        cdoSolEscort = new CommonDataObject();
        cdoSolEscort.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
    	cdoSolEscort.setWhereClause("id = -1");
    }

	//SQLMgr.setErrCode("1");
     SQLMgr.update(cdoSolEscort);

	if (SQLMgr.getErrCode().equals("1") && request.getParameter("escortId"+currentIndex) != null && !request.getParameter("escortId"+currentIndex).equals("")){
	   cdoSolHist.setAutoIncCol("id");
	   cdoSolHist.addColValue("sol_id",request.getParameter("solId"+currentIndex));
	   cdoSolHist.addColValue("escolta_id",request.getParameter("escortId"+currentIndex));
	   cdoSolHist.addColValue("pac_id",request.getParameter("pacId"+currentIndex));
	   cdoSolHist.addColValue("admision",request.getParameter("admision"+currentIndex));
	   cdoSolHist.addColValue("fecha_ini_escolta",cDate);
	   cdoSolHist.addColValue("fecha_fin_escolta",request.getParameter("fechaFinAtencion"+currentIndex));
       cdoSolHist.addColValue("sub_estado",request.getParameter("subEstado"+currentIndex));
	   cdoSolHist.addColValue("fecha_Creacion",cDate);
	   cdoSolHist.addColValue("usuario_Creacion",cUserName);
	   cdoSolHist.addColValue("fg",request.getParameter("fg"));
	   SQLMgr.insert(cdoSolHist);
	}



%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function printReqOF(){
   var estado = "<%=cEstado%>";
   var idSol = "<%=solId%>";
   if (estado=="E"){
    	window.open('../escolta/print_comprobante_sol_escolta.jsp?idSol='+idSol+'&estado='+estado);
   }
}
function closeWindow()
{
<%
//	../expediente/

String currentUrl = (request.getParameter("currentUrl")==null?request.getContextPath()+"/expediente/sol_escolta.jsp?fecha="+request.getParameter("fecha")+"&cdsFrom="+request.getParameter("cdsFrom")+"&cdsTo="+request.getParameter("cdsTo")+"&fg="+request.getParameter("fg")+"&estado="+(request.getParameter("estado")==null?"E":request.getParameter("estado")):request.getParameter("currentUrl"));

if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	var currentUrl = "<%=currentUrl%>";
    currentUrl = currentUrl.split("&estado=");
    currentUrl = currentUrl[0]+(currentUrl[0].indexOf("?")!=-1?'&':'?')+'estado=<%=request.getParameter("estado"+currentIndex)%>';
    printReqOF();
	window.location = currentUrl;
<%

} else throw new Exception(SQLMgr.getErrMsg());
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