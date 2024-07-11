<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.DetalleResultadoNota"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />	
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="NEMgr" scope="page" class="issi.expediente.NotasEnfermeriaMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
SAL310111 Expediente Enfermeria
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NEMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String defaultAction = request.getParameter("defaultAction");
String appendFilter = "";
String groupBy = "";
String colsPan = "14";

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
if (fg == null) fg = "TD";

if (mode.equalsIgnoreCase("view")) viewMode = true;
if (fg.equalsIgnoreCase("HM")||fg.equalsIgnoreCase("HM2"))
{
	appendFilter = " and ne.no_hemodialisis is not null";
	colsPan ="12";
    
    if (fg.equalsIgnoreCase("HM2")) {
      appendFilter += " and ne.observacion = 'HM2' and ne.observacion = rn.comentario ";
    }
}
else appendFilter = " and ne.no_hemodialisis is null";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql="select distinct a.* from (select rn.codigo, decode(ne.no_hemodialisis,null,' ',ne.no_hemodialisis) as noHemodialisis, nvl(ne.maquina,' ') as maquina, nvl(ne.filtro,' ') as filtro, nvl(ne.solucion,' ') as solucion, decode(ne.peso_inicial,null,' ',ne.peso_inicial) as pesoInicial, decode(ne.peso_final,null,' ',ne.peso_final) as pesoFinal, to_char(rn.fecha_nota,'dd/mm/yyyy') as fechaNota, to_char(rn.hora,'hh12:mi:ss am') as hora, nvl(to_char(rn.fecha,'dd/mm/yyyy'),' ') as fecha, nvl(to_char(rn.hora_r,'hh12:mi am'),' ') as horaR, nvl(rn.temperatura,' ') as temperatura, nvl(rn.pulso,' ') as pulso, nvl(rn.p_arterial,' ') as pArterial, nvl(rn.respiracion,' ') as respiracion, nvl(rn.ultrafijacion,' ') as ultrafijacion, nvl(to_char(recormon_unid),' ') as recormon, nvl(rn.med_trat,' ') as medTrat, nvl(rn.observacion,' ') as observacion, to_char(rn.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, rn.usuario_creacion as usuarioCreacion, to_char(rn.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion, rn.usuario_modificacion as usuarioModificacion, rn.estado, ne.estado as estadoNota, nvl(rn.flujo_sanguineo,' ') as flujoSanguineo, nvl(rn.p_venosa,' ') as pVenosa, nvl(rn.p_transmembranica,' ') as pTransmembranica, rn.fecha_nota, to_date(to_char(rn.hora,'hh12:mi:ss am'),'hh12:mi:ss am') as hora_nota, rn.fecha as fecha_orden, to_date(to_char(rn.hora_r,'hh12:mi:ss am'),'hh12:mi:ss am') as hora_orden,rn.MICCION, rn.EVACUACION, rn.VOMITO, rn.EVACUACION_OBS as evacuacionObs, rn.MICCION_OBS as miccionObs, rn.VOMITO_OBS as vomitoObs, rn.COMENTARIO, rn.ACCION, rn.DIAGNOSTICOENF, rn.COMIDA, rn.COMIO, rn.CANTIDAD, rn.DOLOR, nvl(rn.FCARD,' ')FCARD, nvl(rn.PCARD,' ')PCARD, rn.PESO, rn.TALLA,rn.id from tbl_sal_resultado_nota rn, tbl_sal_notas_enfermeria ne where rn.pac_id="+pacId+" and rn.secuencia="+noAdmision+" and rn.estado='A' and rn.pac_id=ne.pac_id and rn.secuencia=ne.secuencia and rn.id=ne.id "+appendFilter+") a order by a.fecha_nota DESC, a.hora_nota DESC, a.fecha_orden, a.hora_orden";
	System.out.println("sql = "+sql);
	al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleResultadoNota.class);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Notas de Enfermería - '+document.title;

function doAction()
{
	hasPendingNotes();
}

function confirmNote(k)
{
	if(eval('document.form0.estado'+k).options[1].selected&&!confirm('¿Está segur@ que desea INVALIDAR la Nota?'))eval('document.form0.estado'+k).options[0].selected=true;
}

function isInvalidated()
{
<%
for (int i=0; i<al.size(); i++)
{
%>
	if(document.form0.estado<%=i%>.value=='I')return true;
<%
}
%>
	return false;
}

function printNotes(){
<%if(fg.trim().equalsIgnoreCase("HM2")){%>
    abrir_ventana2('../expediente3.0/print_notas_enfermeria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=CS&fp=<%=fg%>');
<%}else{%>
abrir_ventana2('../expediente/print_notas_enfermeria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=CS&fp=<%=fg%>'); 
<%}%>    
 }

function finalizeNotes()
{
	if(hasDBData('<%=request.getContextPath()%>','tbl_sal_notas_enfermeria','pac_id=<%=pacId%> and secuencia=<%=noAdmision%> and estado=\'P\''))
		if(executeDB('<%=request.getContextPath()%>','call sp_sal_finalizar_notas(<%=pacId%>,<%=noAdmision%>,\'<%=(String) session.getAttribute("_userName")%>\',\'<%=fg%>\')',''))
		{
			alert('Notas Pendientes finalizadas satisfactoriamente!');
			hasPendingNotes();
			window.opener.parent.window.opener.location.reload(true);
			//window.opener.window.location.reload();
			window.opener.window.location = '../expediente/exp_notas_enfermeria.jsp?seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&defaultAction=<%=defaultAction%>';

			//window.opener.window.parent.doRedirect(<%=seccion%>);
			setTimeout('checkLoaded()',100);
		}
		else alert('Hubo un error al tratar de finalizar las notas pendientes!');
	else alert('No hay notas pendiente por finalizar');
}

function hasPendingNotes()
{
	if(hasDBData('<%=request.getContextPath()%>','tbl_sal_notas_enfermeria','pac_id=<%=pacId%> and secuencia=<%=noAdmision%> and estado=\'P\'')) return true;
	else
	{
		document.formx.finalize.disabled=true;
<%
for (int i=0; i<al.size(); i++)
{
%>
		document.form0.estado<%=i%>.disabled=true;
<%
}
%>
		document.form0.save.disabled=true;
		return false;
	}
}

function checkLoaded()
{
	if(window.opener.parent.window.opener.loaded&&window.opener.loaded)window.focus();
	else setTimeout('checkLoaded()',100);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="NOTAS DE ENFERMERIA"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("formx",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<a href="javascript:printNotes()" class="Link00">[ <cellbytelabel id="1">Imprimir Notas V&aacute;lidas e Inv&aacute;lidas</cellbytelabel> ]</a>
				<%=fb.button("finalize","Finalizar Notas",true,viewMode,null,null,"onClick=\"javascript:finalizeNotes()\"")%>			</td>
		</tr>
<%=fb.formEnd()%>
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>			</td>
		</tr>
		</table>
	    <table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
          <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
          <%=fb.formStart(true)%> <%=fb.hidden("baction","")%> <%=fb.hidden("pacId",pacId)%> <%=fb.hidden("noAdmision",noAdmision)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("seccion",seccion)%> <%=fb.hidden("defaultAction",defaultAction)%> <%=fb.hidden("fg",fg)%> <%=fb.hidden("size",""+al.size())%>
          <%fb.appendJsValidation("if(!isInvalidated())error++;");%>
          <%if(!fg.trim().equals("HM") && !fg.trim().equals("HM2")){%>
          <tr align="center" class="TextHeader">
            <td width="12%"><cellbytelabel id="2">Fecha Hora</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="3">Temp</cellbytelabel>.</td>
            <td width="8%"><cellbytelabel id="4">Pulso</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="5">Resp</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="6">P.Art</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="7">F.Card</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="8">Pul.Card</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="9">Peso</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="10">Talla</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="11">Creado Por</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="12">Modificado Por</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="13">Estado</cellbytelabel></td>
          </tr>
          <%}else{%>
            <%if(fg.trim().equals("HM2")){%>
            <tr align="center" class="TextHeader">
                <td width="20%"><cellbytelabel id="2">Hora</cellbytelabel></td>
                <td width="10%"><cellbytelabel id="4">Peso</cellbytelabel></td>
                <td width="10%"><cellbytelabel id="5">Talla</cellbytelabel>.</td>
                <td width="20%"><cellbytelabel id="6">F.C</cellbytelabel></td>
                <td width="20%"><cellbytelabel id="11">P.A</cellbytelabel></td>
                <td width="10%"><cellbytelabel id="11">Dolor</cellbytelabel></td>
                <td width="10%"><cellbytelabel id="11">Estado</cellbytelabel></td>
             </tr>   
            <%}else{%>
          <tr align="center" class="TextHeader">
            <td width="12%"><cellbytelabel id="2">Fecha Hora</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="3">Temp</cellbytelabel>.</td>
            <td width="8%"><cellbytelabel id="4">Pulso</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="5">Resp</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="6">P.Art</cellbytelabel></td>
            <td width="6%"><cellbytelabel id="7">P / A</cellbytelabel></td>
            <td width="6%"><cellbytelabel id="8">F. S.</cellbytelabel></td>
            <td width="6%"><cellbytelabel id="9">F. V</cellbytelabel></td>
            <td width="7%"><cellbytelabel id="10">UF</cellbytelabel></td>
            <td width="7%"><cellbytelabel id="11">P.T.M</cellbytelabel></td>
           <td width="8%"><cellbytelabel id="12">Creado Por</cellbytelabel></td>
            <td width="8%"><cellbytelabel id="13">Modificado Por</cellbytelabel></td>
             <td width="8%"><cellbytelabel id="14">Estado</cellbytelabel></td>
          </tr>
          <%}%>
          <%
}

for (int i=0; i<al.size(); i++)
{
	DetalleResultadoNota drn = (DetalleResultadoNota) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
          <%=fb.hidden("fechaNota"+i,drn.getFechaNota())%> <%=fb.hidden("hora"+i,drn.getHora())%> <%=fb.hidden("codigo"+i,drn.getCodigo())%>
		  <%=fb.hidden("id"+i,drn.getId())%>
          <%if(fg.trim().equals("HM") && !groupBy.equalsIgnoreCase(drn.getFechaNota()+drn.getHora())){%>
          <tr class="<%=color%>" align="center">
            <td colspan="<%=colsPan%>"><table width="100%" cellpadding="1" cellspacing="1">
                <tr class="TextHeader01">
                  <td width="20%"><cellbytelabel id="15">Hemodialisis</cellbytelabel> #<%=drn.getNoHemodialisis()%></td>
                  <td width="20%"><cellbytelabel id="16">M&aacute;quina</cellbytelabel>: <%=drn.getMaquina()%></td>
                  <td width="20%"><cellbytelabel id="17">Filtro</cellbytelabel>: <%=drn.getFiltro()%></td>
                  <td width="20%"><cellbytelabel id="18">Peso Inicial</cellbytelabel>: <%=drn.getPesoInicial()%></td>
                  <td width="20%"><cellbytelabel id="19">Peso Final</cellbytelabel>: <%=drn.getPesoFinal()%></td>
                </tr>
            </table></td>
          </tr>
          <%}%>
          
          <%if(fg.trim().equalsIgnoreCase("HM2")){%>
            <tr class="<%=color%>" align="center">
                <td><%=drn.getFecha()%> <%=drn.getHoraR()%></td>
                <td><%=drn.getPeso()%></td>
                <td><%=drn.getTalla()%></td>
                <td><%=drn.getFCard()%></td>
                <td><%=drn.getPArterial()%></td>
                <td><%=drn.getDolor()%></td>
                <td align="center"><%=fb.select("estado"+i,"A=VALIDA,I=INVALIDA",drn.getEstado(),false,(drn.getEstadoNota().trim().equals("F")||(viewMode|| !drn.getUsuarioCreacion().trim().equals((String) session.getAttribute("_userName")))),0,null,null,"onChange=\"javascript:confirmNote("+i+");\"")%></td>
            </tr>
          <%} else {%>
          
          <tr class="<%=color%>" align="center">
            <td><%=drn.getFecha()%> <%=drn.getHoraR()%></td>
            <td><%=drn.getTemperatura()%></td>
            <td><%=drn.getPulso()%></td>
            <td><%=drn.getRespiracion()%></td>
            <td><%=drn.getPArterial()%></td>
            <%if(!fg.trim().equals("HM")){%>
			<td><%=drn.getFCard()%></td>
            <td><%=drn.getPCard()%></td>
            <td><%=drn.getPeso()%></td>
            <td><%=drn.getTalla()%></td>
			<%}%>
            <%if(fg.trim().equals("HM")){%>
            <td><%=drn.getFlujoSanguineo()%></td>
            <td><%=drn.getPVenosa()%></td>
            <td><%=drn.getUltrafijacion()%></td>
            <td><%=drn.getPTransmembranica()%></td>
            <%}%>
            <td><%=drn.getUsuarioCreacion()%><br>
                <%=drn.getFechaCreacion()%></td>
            <td><%=drn.getUsuarioModificacion()%><br>
                <%=drn.getFechaModificacion()%></td>
			<%if(!fg.trim().equals("HM")){%>	
            <td rowspan="5" align="center"><%=fb.select("estado"+i,"A=VALIDA,I=INVALIDA",drn.getEstado(),false,(drn.getEstadoNota().trim().equals("F")||(viewMode|| !drn.getUsuarioCreacion().trim().equals((String) session.getAttribute("_userName")))),0,null,null,"onChange=\"javascript:confirmNote("+i+");\"")%></td>
			<%}else{%>
			<td align="center"><%=fb.select("estado"+i,"A=VALIDA,I=INVALIDA",drn.getEstado(),false,(drn.getEstadoNota().trim().equals("F")||(viewMode|| !drn.getUsuarioCreacion().trim().equals((String) session.getAttribute("_userName")))),0,null,null,"onChange=\"javascript:confirmNote("+i+");\"")%></td>
			<%}%>
          </tr>
          <%}%>
          <%if(!fg.trim().equals("HM") && !fg.trim().equals("HM2")){%>
          <tr class="<%=color%>">
            <td colspan="5"><label class="TextHeader">&nbsp;<cellbytelabel id="20">Medicinas y Tratamientos</cellbytelabel>:&nbsp;</label>
                <%=fb.textarea("A",drn.getMedTrat(),false,true,viewMode,40,3,2000,null,"width:100%","")%> </td>
            <td colspan="6"><label class="TextHeader">&nbsp;<cellbytelabel id="21">Notas de la Enfermera</cellbytelabel>:&nbsp;</label>
                <%=fb.textarea("A",drn.getObservacion(),false,true,viewMode,40,3,2000,null,"width:100%","")%> </td>
          </tr>
          <tr class="<%=color%>">
            <td width="11%" align="right"><label class="TextHeader"><cellbytelabel id="22">Evacuaci&oacute;n</cellbytelabel>:</label></td>
            <td colspan="14"><%=fb.checkbox("B","S",drn.getEvacuacion().trim().equals("S"),true,null,null,"")%>
                <label >&nbsp;&nbsp;<cellbytelabel id="23">Observaci&oacute;n</cellbytelabel>:&nbsp;</label>
              <%=fb.textarea("B", drn.getEvacuacionObs(), false, true, true, 0, 1, "", "width:75%", "")%></td>
          </tr> 
		 
		  
		  
          <tr class="<%=color%>">
            <td width="11%" align="right"><label class="TextHeader"><cellbytelabel id="24">Micci&oacute;n</cellbytelabel>:</label></td>
            <td colspan="14"><%=fb.checkbox("B","S",drn.getMiccion().trim().equals("S"),true,null,null,"")%>
                <label >&nbsp;&nbsp;<cellbytelabel id="23">Observaci&oacute;n</cellbytelabel>:&nbsp;</label>
              <%=fb.textarea("B",drn.getMiccionObs(), false, true, true, 0, 1, "", "width:75%", "")%></td>
          </tr>
          <tr class="<%=color%>">
            <td width="11%" align="right"><label class="TextHeader"><cellbytelabel id="25">V&oacute;mito</cellbytelabel>:</label></td>
            <td colspan="14"><%=fb.checkbox("B","S",drn.getVomito().trim().equals("S"),true,null,null,"")%> &nbsp;&nbsp;
                <label ><cellbytelabel id="23">Observaci&oacute;n</cellbytelabel>:&nbsp;</label>
              <%=fb.textarea("B", drn.getVomitoObs(), false, true, true, 0, 1, "", "width:75%", "")%></td>
          </tr>
          <tr class="<%=color%>">
            <td width="11%" align="right"><label class="TextHeader"><cellbytelabel id="26">Dolor</cellbytelabel>:</label></td>
            <td colspan="14"><%=fb.select("B","S=Si,N=No",drn.getDolor(),false,true,0,null,null,null)%> &nbsp;&nbsp;</td>
          </tr>
          <tr class="<%=color%>">
            <td width="11%" align="right"><label class="TextHeader"><cellbytelabel id="27">Comida</cellbytelabel>:</label></td>
            <td colspan="14"><%=fb.select("B","D=Desayuno,A=Almuerzo,M=Merienda,C=Cena",drn.getComida(),false,true,0,null,null,null)%>
                <label>&nbsp;&nbsp;<cellbytelabel id="28">Comi&oacute;</cellbytelabel>&nbsp;</label>
              <%=fb.select("B","S=Si,N=No",drn.getComio(),false,true,0,null,null,null)%>
              <label >&nbsp;&nbsp;&nbsp;&nbsp;Cantidad&nbsp;</label>
              <%=fb.select("B","0=Nada,1=1/4,2=1/2,3=1/3,4=Todo",drn.getCantidad(),false,true,0,null,null,null)%>&nbsp;&nbsp;</td>
          </tr>
		  
         <!-- <tr class="<%//=color%>">
            <td align="left" ><label>Observaci&oacute;n</label></td>
            <td width="37%" align="left" colspan="5" ><%//=fb.textarea("B", drn.getComentario(), false, true, true, 0, 3, "", "width:100%", "")%></td>
            <td width="8%" align="right" ><label>Acci&oacute;n</label></td>
            <td width="44%" align="left" colspan="8"><%//=fb.textarea("B", drn.getAccion(), false, true, true, 0, 3, "", "width:100%", "")%></td>
          </tr> -->
		  
		  
<tr class="<%=color%>">
<td colspan="12"><label class="TextHeader">&nbsp;<cellbytelabel id="29">Nota Enfermera</cellbytelabel>:&nbsp;</label>		
<%=fb.select(ConMgr.getConnection(),"select id, nombre_eng from tbl_cds_diagnostico_enf ","diagnosticoEnf",drn.getDiagnosticoEnf(),false,true,0,"Text10",null,null,"","")%></td>
</tr>

          <tr class="<%=color%>">
            <td colspan="5"><label class="TextHeader">&nbsp;<cellbytelabel id="23">Observaci&oacute;n</cellbytelabel>:&nbsp;</label>
                <%=fb.textarea("A",drn.getComentario(),false,true,viewMode,40,3,2000,null,"width:100%","")%> </td>         
            <td colspan="9"><label class="TextHeader">&nbsp;<cellbytelabel id="30">Acci&oacute;n</cellbytelabel>:&nbsp;</label>
                <%=fb.textarea("B",drn.getAccion(),false,true,viewMode,40,3,2000,null,"width:100%","")%> </td>
          </tr>
		  
		  <tr align="center" class="TextHeader">
			<tr align="center">
						<tr align="center" class="TextHeader">
							<td width="12%"><cellbytelabel id="2">Fecha Hora</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="3">Temp</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel id="4">Pulso</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="5">Resp</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel id="6">P / A</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="8">F. S</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel id="9">F. V</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="10">UF</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="11">P.T.M</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="12">Creado Por</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="13">Modif. Por</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="14">Estado</cellbytelabel></td>
						</tr>
          <%}else{
	}
	groupBy = drn.getFechaNota()+drn.getHora();
}
%>
          <tr class="TextRow02">
            <td colspan="<%=colsPan%>" align="right"> <cellbytelabel id="31">Opciones de Guardar</cellbytelabel>:
              <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
                <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="32">Mantener Abierto</cellbytelabel> <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="33">Cerrar</cellbytelabel> <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%> </td>
          </tr>
          <%=fb.formEnd(true)%>
        </table></td>
</tr>
</table>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	fg = request.getParameter("fg");
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("estado"+i) != null && request.getParameter("estado"+i).equalsIgnoreCase("I"))
		{
			DetalleResultadoNota drn = new DetalleResultadoNota();

			drn.setPacId(pacId);
			drn.setSecuencia(noAdmision);
			drn.setFechaNota(request.getParameter("fechaNota"+i));
			drn.setHora(request.getParameter("hora"+i));
			drn.setCodigo(request.getParameter("codigo"+i));
			drn.setEstado(request.getParameter("estado"+i));
			drn.setUsuarioCreacion((String) session.getAttribute("_userName"));
			drn.setUsuarioModificacion((String) session.getAttribute("_userName"));
			drn.setId(request.getParameter("id"+i));

			al.add(drn);
		}
	}

	if (baction != null && baction.trim().equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		NEMgr.invalidarNotasEnfermeria(al);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (NEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NEMgr.getErrMsg()%>');
<%
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
	window.close();
<%
	}
} else throw new Exception(NEMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&defaultAction=<%=defaultAction%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&defaultAction=<%=defaultAction%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>