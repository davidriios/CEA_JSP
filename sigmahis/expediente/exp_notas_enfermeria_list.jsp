<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.expediente.DetalleResultadoNota"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="NEMgr" scope="page" class="issi.expediente.NotasEnfermeriaMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
/**
==================================================================================
CONSULTA DE NOTAS DE ENFERMERIA
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
String modeSec = request.getParameter("modeSec");
String fg = request.getParameter("fg");
String defaultAction = request.getParameter("defaultAction");
String appendFilter = "";
String groupBy = "";
String colsPan = "11";

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if(fg == null)fg="";
if(mode == null)mode="";
if(modeSec == null)modeSec="";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (fg.equalsIgnoreCase("HM")){
	appendFilter = " and ne.no_hemodialisis is not null and nvl(ne.observacion,' ') <> 'HM2'";
	colsPan ="12";
}
else if (fg.equalsIgnoreCase("HM2")) {
    appendFilter = " and ne.no_hemodialisis is not null and nvl(ne.observacion,' ') = 'HM2'";
	colsPan ="12";
}
else appendFilter = " and ne.no_hemodialisis is null";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql="select distinct a.* from (select rn.codigo, ne.no_hemodialisis, ne.peso_inicial, ne.peso_final, ne.solucion, ne.filtro, to_char(rn.fecha_nota,'dd/mm/yyyy') as fechaNota, to_char(rn.hora,'hh12:mi:ss am') as hora, nvl(to_char(rn.fecha,'dd/mm/yyyy'),' ') as fecha, nvl(to_char(rn.hora_r,'hh12:mi am'),' ') as horaR, nvl(rn.temperatura,' ') as temperatura, nvl(rn.pulso,' ') as pulso, nvl(rn.p_arterial,' ') as pArterial, nvl(rn.respiracion,' ') as respiracion, nvl(rn.ultrafijacion,' ') as ultrafijacion, nvl(to_char(recormon_unid),' ') as recormon, nvl(rn.med_trat,' ') as medTrat, nvl(rn.observacion,' ') as observacion, to_char(rn.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, rn.usuario_creacion as usuarioCreacion, to_char(rn.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion, rn.usuario_modificacion as usuarioModificacion, rn.estado,ne.estado estadoNota, nvl(rn.flujo_sanguineo,' ') as flujoSanguineo, nvl(rn.p_venosa,' ') as pVenosa, nvl(rn.p_transmembranica,' ') as pTransmembranica, to_date(to_char(rn.fecha_nota,'dd/mm/yyyy'),'dd/mm/yyyy') as fecha_orden, to_date(to_char(rn.hora,'hh12:mi:ss am'),'hh12:mi:ss am') as hora_orden, rn.fecha as fecha_det, to_date(to_char(rn.hora_r,'hh12:mi:ss am'),'hh12:mi:ss am') as hora_det,rn.MICCION, rn.EVACUACION, rn.VOMITO, rn.EVACUACION_OBS, rn.MICCION_OBS, rn.VOMITO_OBS, rn.COMENTARIO, rn.ACCION, rn.DIAGNOSTICOENF, rn.COMIDA, rn.COMIO, rn.CANTIDAD, rn.DOLOR, rn.FCARD, rn.PCARD, rn.PESO, rn.TALLA,rn.id from tbl_sal_resultado_nota rn, tbl_sal_notas_enfermeria ne where rn.pac_id="+pacId+" and rn.secuencia="+noAdmision+"  and rn.pac_id=ne.pac_id and rn.secuencia=ne.secuencia and rn.id=ne.id "+appendFilter+") a order by a.fecha_orden desc, a.hora_orden desc, a.fecha_det, a.hora_det";
	//System.out.println("sql = "+sql);
	al =  SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Notas de Enfermería - '+document.title;
function printNotes(){abrir_ventana2('../expediente<%=fg.trim().equalsIgnoreCase("HM2")?"3.0":""%>/print_notas_enfermeria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=CS&fp=<%=fg%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="VER NOTAS DE ENFERMERIA"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("formx",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
		<tr class="TextRow02">
			<td colspan="4" align="right"><a href="javascript:printNotes()" class="Link00">[ <cellbytelabel id="1">Imprimir Notas V&aacute;lidas e Inv&aacute;lidas</cellbytelabel> ]</a>
			</td>
		</tr>
<%=fb.formEnd()%>
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("defaultAction",defaultAction)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("if(!isInvalidated())error++;");%>

	<%if(!fg.trim().equals("HM")){%>
	<!--<tr align="center" class="TextHeader">
			<td width="12%"><cellbytelabel>Fecha Hora</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Temp</cellbytelabel>.</td>
			<td width="10%"><cellbytelabel>Pulso</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Resp</cellbytelabel></td>
			<td width="10%"><cellbytelabel>P.Art</cellbytelabel></td>
			<td width="8%"><cellbytelabel>F.Card</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Pul.Card</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Peso</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Talla</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Creado Por</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Modificado Por</cellbytelabel></td>
		</tr>-->
		<%}else{%>

		<%}%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

				if ((!groupBy.trim().equalsIgnoreCase(cdo.getColValue("id")))){
				
				 if(fg.trim().equals("HM"))
					{ // groupBy
					%>
						<tr  class="TextHeader" align="center">
							 <td><cellbytelabel>Hemodialisis No</cellbytelabel>.: <%=cdo.getColValue("no_hemodialisis")%>
							 <td><cellbytelabel>Filtro</cellbytelabel>: <%=cdo.getColValue("filtro")%>
							 <td colspan=5><cellbytelabel>Soluci&oacute;n</cellbytelabel>: <%=cdo.getColValue("solucion")%>
							 <td colspan=2><cellbytelabel>Peso Inicial</cellbytelabel>: <%=cdo.getColValue("peso_inicial")%>
							 <td colspan=2><cellbytelabel>Peso Final</cellbytelabel>: <%=cdo.getColValue("peso_final")%>
						 </tr>

						<tr align="center" class="TextHeader">
							<td width="12%"><cellbytelabel>Fecha Hora</cellbytelabel></td>
							<td width="6%"><cellbytelabel>Temp</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel>Pulso</cellbytelabel></td>
							<td width="6%"><cellbytelabel>Resp</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel>P / A</cellbytelabel></td>
							<td width="6%"><cellbytelabel>F. S</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel>F. V</cellbytelabel></td>
							<td width="7%"><cellbytelabel>UF</cellbytelabel></td>
							<td width="7%"><cellbytelabel>P.T.M</cellbytelabel></td>
							<td width="9%"><cellbytelabel>Creado Por</cellbytelabel></td>
							<td width="9%"><cellbytelabel>Modificado Por</cellbytelabel></td>
						</tr>

						<%}else{%>
						<tr align="center" class="TextHeader">
							<td width="12%"><cellbytelabel>Fecha Hora</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Temp</cellbytelabel>.</td>
							<td width="10%"><cellbytelabel>Pulso</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Resp</cellbytelabel></td>
							<td width="10%"><cellbytelabel>P.Art</cellbytelabel></td>
							<td width="8%"><cellbytelabel>F.Card</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Pul.Card</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Peso</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Talla</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Creado Por</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Modificado Por</cellbytelabel></td>
						</tr>	 
							 
				      <%}}// groupBy
					  %>
		<tr class="<%=color%>" align="center">
			<td><%=cdo.getColValue("fecha")%> <%=cdo.getColValue("horaR")%></td>
			<td><%=cdo.getColValue("temperatura")%></td>
			<td><%=cdo.getColValue("pulso")%></td>
			<td><%=cdo.getColValue("respiracion")%></td>
			<td><%=cdo.getColValue("pArterial")%></td>
			<%if(!fg.trim().equals("HM")){%>
			<td><%=cdo.getColValue("fcard")%></td>
			<td><%=cdo.getColValue("pcard")%></td>
			<td><%=cdo.getColValue("peso")%></td>
			<td><%=cdo.getColValue("talla")%></td>
			<%}%>
			<%if(fg.trim().equals("HM")){%>
				<td><%=cdo.getColValue("flujoSanguineo")%></td>
				<td><%=cdo.getColValue("pVenosa")%></td>
				<td><%=cdo.getColValue("ultrafijacion")%></td>
				<td><%=cdo.getColValue("pTransmembranica")%></td>
			<%}%>
			<td><%=cdo.getColValue("usuarioCreacion")%><br><%=cdo.getColValue("fechaCreacion")%></td>
			<td><%=cdo.getColValue("usuarioModificacion")%><br><%=cdo.getColValue("fechaModificacion")%></td>
		</tr>

		<%if(!fg.trim().equals("HM") && !fg.trim().equals("HM2")){%>

		<tr class="<%=color%>">
		<td colspan="5"><label class="TextHeader">&nbsp;<cellbytelabel>Medicinas y Tratamientos</cellbytelabel>:&nbsp;</label> <%=fb.textarea("medTrat"+i,cdo.getColValue("medTrat"),false,true,true,40,3,2000,null,"width:100%","")%></td>
<td colspan="5"><label class="TextHeader">&nbsp;Notas de la Enfermera:&nbsp;</label><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,true,true,40,3,2000,null,"width:100%","")%>
 </td>
 <td><%=fb.select("estado"+i,"A=VALIDA,I=INVALIDA",cdo.getColValue("estado"),false,true,0,null,null,"")%></td>
	</tr>

		<tr>
<td colspan="12" style="text-decoration:none; cursor:pointer" >
<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextPanel">
<td >&nbsp;<cellbytelabel>Otro Detalles</cellbytelabel></td>
<td width="37%" align="right" ><font face="Courier New, Courier, mono">
	<label id="plus1" style="display:none"></label><label id="minus1"></label></font>&nbsp;</td>
</tr>
</table>
</td>
</tr>

	<tr  id="panel1">
	<td colspan="12">
	<table width="100%" cellpadding="1" cellspacing="1"  align="left">

<tr class="<%=color%>">
<td width="11%" align="right"><label class="TextHeader"><cellbytelabel>Evacuaci&oacute;n</cellbytelabel>:</label></td>
<td colspan="11"><%=fb.checkbox("evacuacion"+i,"S",cdo.getColValue("evacuacion").trim().equals("S"),true,null,null,"")%>
<label >&nbsp;&nbsp;Observación:&nbsp;</label><%=fb.textarea("evacuacion_obs"+i, cdo.getColValue("EVACUACION_OBS"), false, true, true, 0, 1, "", "width:75%", "")%></td>
</tr>

<tr class="<%=color%>">
<td width="11%" align="right"><label class="TextHeader"><cellbytelabel>Micci&oacute;n</cellbytelabel>:</label></td>
<td colspan="11"><%=fb.checkbox("miccion"+i,"S",cdo.getColValue("miccion").trim().equals("S"),true,null,null,"")%>
<label >&nbsp;&nbsp;Observación:&nbsp;</label><%=fb.textarea("miccion_obs"+i,cdo.getColValue("MICCION_OBS"), false, true, true, 0, 1, "", "width:75%", "")%></td>
</tr>

<tr class="<%=color%>">
<td width="11%" align="right"><label class="TextHeader"><cellbytelabel>V&oacute;mito</cellbytelabel>:</label></td>
 <td colspan="11"><%=fb.checkbox("vomito"+i,"S",cdo.getColValue("vomito").trim().equals("S"),true,null,null,"")%>
 &nbsp;&nbsp;<label >Observación:&nbsp;</label><%=fb.textarea("VOMITO_OBS"+i, cdo.getColValue("VOMITO_OBS"), false, true, true, 0, 1, "", "width:75%", "")%></td>	 </tr>


<tr class="<%=color%>">
<td width="11%" align="right"><label class="TextHeader"><cellbytelabel>Dolor</cellbytelabel>:</label></td>
<td colspan="11"><%=fb.select("dolor"+i,"S=Si,N=No",cdo.getColValue("dolor"),false,true,0,null,null,null)%>
&nbsp;&nbsp;</td>
	 </tr>

<tr class="<%=color%>">
<td width="11%" align="right"><label class="TextHeader"><cellbytelabel>Comida</cellbytelabel>:</label></td>
<td colspan="11"><%=fb.select("comida"+i,"D=Desayuno,A=Almuerzo,M=Merienda,C=Cena",cdo.getColValue("comida"),false,true,0,null,null,null)%>
<label>&nbsp;&nbsp;<cellbytelabel>Comio</cellbytelabel>&nbsp;</label><%=fb.select("comio"+i,"S=Si,N=No",cdo.getColValue("comio"),false,true,0,null,null,null)%><label >&nbsp;&nbsp;&nbsp;&nbsp;Cantidad&nbsp;</label><%=fb.select("cantidad"+i,"0=Nada,1=1/4,2=1/2,3=1/3,4=Todo",cdo.getColValue("cantidad"),false,true,0,null,null,null)%>&nbsp;&nbsp;</td>
</tr>

<!--<tr class="<%//=color%>">
<td align="right"><label>Observaci&oacute;n</label></td>
<td width="37%" ><%//=fb.textarea("B", cdo.getColValue("comentario"), false, true, true, 0, 3, "", "width:100%", "")%></td>

<td width="8%" align="right"><label>Acci&oacute;n</label></td>
<td width="44%" ><%//=fb.textarea("B", cdo.getColValue("accion"), false, true, true, 0, 3, "", "width:100%", "")%></td>
</tr>-->
</table>
</td>
</tr>
<tr>
<td colspan="12"  style="text-decoration:none; cursor:pointer" >
<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextPanel">
<td >&nbsp;<cellbytelabel>Diagn&oacute;stico Enfermera (NANDA)</cellbytelabel></td>
<td width="37%" align="right" ><font face="Courier New, Courier, mono">
	<label id="plus3" style="display:none"></label><label id="minus3"></label></font>&nbsp;</td>
</tr>
</table>
</td>
</tr>

<tr id="panel3" class="TextRow02" >
<td colspan="12"><%=fb.select(ConMgr.getConnection(),"select id, nombre_eng from tbl_cds_diagnostico_enf ","diagnosticoEnf"+i,cdo.getColValue("DIAGNOSTICOENF"),false,true,0,"Text10",null,null,"","S")%></td>
</tr>

<tr class="<%=color%>">
<td colspan="5"><label class="TextHeader">&nbsp;<cellbytelabel>Observaci&oacute;n</cellbytelabel>:&nbsp;</label> <%=fb.textarea("comentario"+i,cdo.getColValue("comentario"),false,true,true,40,3,2000,null,"width:100%","")%></td>
<%//=cdo.getColValue("recormon")%>
<td colspan="6"><label class="TextHeader">&nbsp;Accion:&nbsp;</label> <%=fb.textarea("accion"+i,cdo.getColValue("accion"),false,true,true,40,3,2000,null,"width:100%","")%></td>
</tr>

<!--<tr align="center" class="TextHeader">
			<tr align="center">
						<tr align="center" class="TextHeader">
							<td width="12%"><cellbytelabel>Fecha Hora</cellbytelabel></td>
							<td width="6%"><cellbytelabel>Temp</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel>Pulso</cellbytelabel></td>
							<td width="6%"><cellbytelabel>Resp</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel>P / A</cellbytelabel></td>
							<td width="6%"><cellbytelabel>F. S</cellbytelabel>.</td>
							<td width="6%"><cellbytelabel>F. V</cellbytelabel></td>
							<td width="7%"><cellbytelabel>UF</cellbytelabel></td>
							<td width="7%"><cellbytelabel>P.T.M</cellbytelabel></td>
							<td width="9%"><cellbytelabel>Creado Por</cellbytelabel></td>
							<td width="9%"><cellbytelabel>Modif. Por</cellbytelabel></td>
						</tr>-->




<%}else{

}
	if (fg.trim().equals("HM"))
	{
			groupBy = cdo.getColValue("id");
	}

}
%>
		</table>
</div>
</div>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td colspan="<%=colsPan%>" align="right">
				<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
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
}//GET
%>