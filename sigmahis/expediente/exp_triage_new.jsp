<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
SPMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
SignoPaciente sp = new SignoPaciente();
ArrayList al, alh = new ArrayList();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp= request.getParameter("fp");
String tipoPersona= request.getParameter("tipoPersona");
String subTitulo ="",appendFilter = "";
String desc = request.getParameter("desc");
String fc = request.getParameter("fc");

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
if(fc == null) fc = "";

String categoria= request.getParameter("categoria");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (fg == null){ fg = "TSV"; subTitulo ="TRIAGE/SIGNOS VITALES";}
else subTitulo ="SIGNOS VITALES";

if (fp == null) fp = "edit";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String hora1="";
int size = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "select a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc , to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(a.hora_registro,'hh12:mi am') as horaRegistro, decode(sp.status,'I','INVALIDO','VALIDO') as status FROM tbl_sal_signo_paciente a WHERE a.tipo_persona = 'T'  and a.pac_id="+pacId+" AND a.secuencia="+noAdmision+" order by  a.fecha_registro desc, a.hora_registro desc";

alh = SQLMgr.getDataList(sql);

sql = "SELECT nvl(observacion,' ') AS observacion, nvl(accion,' ') AS accion, nvl(categoria,' ') AS categoria, nvl(evacuacion,'N') as evacuacion, nvl(miccion,'N') as miccion, nvl(vomito,'N') as vomito, nvl(miccion_obs,' ') as miccionObs, nvl(evacuacion_obs,' ') as evacuacionObs, nvl(vomito_obs,' ') as vomitoObs, to_char(fecha,'dd/mm/yyyy') as fecha,to_char(fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(hora,'dd/mm/yyyy hh12:mi:ss am') as hora,to_char(hora_registro,'hh12:mi am') as horaRegistro, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_creacion as usuarioCreacion,dolor as dolor, escala as escala FROM tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
if (!viewMode) sql += " and status = 'A'";

	if(fp.trim().equals("agregar")){ sql +=" and to_date(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	}else{
		if(!fg.trim().equalsIgnoreCase("SV") && !fc.equals("")){
			sql +=appendFilter+" and fecha_creacion = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
		}else{
			sql +=" and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
			if (!viewMode) sql += " and status = 'A'";
			sql += ") ";
		}
	}
if ((UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU")) && fg.trim().equals("SV")){ tipoPersona = "A";}
else if ((UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU")) && fg.trim().equals("TSV")) tipoPersona = "T";
else	if ((UserDet.getUserTypeCode().trim().equalsIgnoreCase("EM")) && fg.trim().equals("SV")) tipoPersona = "E";
else if (UserDet.getRefType().trim().equalsIgnoreCase("M")) tipoPersona = "M";

	if(tipoPersona != null && !tipoPersona.trim().equals(""))	appendFilter += " and tipo_persona='"+tipoPersona+"'";

	sp = (SignoPaciente) sbb.getSingleRowBean(ConMgr.getConnection(), sql, SignoPaciente.class);

	if(sp==null){
	sp = new SignoPaciente();
	sp.setFecha(cDateTime.substring(0,10));
	sp.setFechaRegistro(cDateTime.substring(0,10));
	sp.setHora(cDateTime);
	sp.setCategoria("4");
	sp.setHoraRegistro(CmnMgr.getCurrentDate("hh12:mi:ss am"));
	sp.setFechaCreacion(cDateTime);
	sp.setFechaModif(cDateTime);
	sp.setUsuarioCreacion((String) session.getAttribute("_userName"));
	sp.setUsuarioModif((String) session.getAttribute("_userName"));
	if (!viewMode) modeSec = "add";

	}
	else { if(!viewMode){modeSec = "edit";viewMode =true;} }//if (!viewMode) mode = "view";
	sql = "select a.*, nvl(b.sigla_um,' ') as sigla_um, nvl(c.resultado,' ') as resultado from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select aa.* from tbl_sal_detalle_signo aa, tbl_sal_signo_paciente s where s.pac_id="+pacId+" and s.secuencia="+noAdmision;
	if (!viewMode) sql += " and s.status = 'A'";
	sql += " and s.pac_id = aa.pac_id and s.secuencia = aa.secuencia and s.fecha = aa.fecha_signo and s.hora = aa.hora and s.tipo_persona = aa.tipo_persona";

	if(fp.trim().equals("agregar")) sql +=" and to_date(aa.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";

	else {
		if(!fg.trim().equalsIgnoreCase("SV") && !fc.equals("")){
			sql +=appendFilter+" and aa.fecha_creacion = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
		}else{
			sql +=appendFilter+" and aa.fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+appendFilter+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona";
			if (!viewMode) sql += " and status = 'A'";
			sql += ")) ";
		}
	}

	sql += ") c where a.codigo=b.cod_signo(+) and b.valor_default(+)='S' and a.codigo=c.signo_vital(+)";
	if(!viewMode) sql += " and a.status = 'A' ";
	sql += " order by a.orden ";
	al = SQLMgr.getDataList(sql);
	hora1=sp.getHora().substring(11);
		if ( fc.equals("") && alh.size() > 0 && !fp.trim().equals("agregar") ){viewMode = true;}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<style type="text/css">
ul.prioridad{list-style-type: square; margin-left:20px; text-align:justify;}
ul.prioridad li a:hover{color:#000000; background-color:#fbf4d4;}
ul.prioridad li{cursor:pointer;}
.tick{width:30px; height:30px; float:left;}
</style>
<script language="javascript">
document.title = 'Triage/Signos Vitales - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();setTimeout('checkLoaded()',100);checkViewMode();}
function viewList(){abrir_ventana1('../expediente/triage_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&seccion=<%=seccion%>');}
function add(){window.location = '../expediente/exp_triage.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=agregar&desc=<%=desc%>&seccion=<%=seccion%>';}
function setTriageDetail(){
	var size=parseInt(document.form0.size.value,10);
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','nvl(a.observacion,\' \') as observacion, nvl(a.accion,\' \') as accion, b.signo_vital, b.resultado','tbl_sal_signo_paciente a, tbl_sal_detalle_signo b','a.pac_id=<%=pacId%> and a.secuencia=<%=noAdmision%> and a.tipo_persona=\'T\' and a.status = \'A\' and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.tipo_persona=b.tipo_persona and a.fecha_creacion=b.fecha_creacion and a.fecha_creacion = (select max(fecha_creacion) from tbl_sal_signo_paciente where tipo_persona=\'T\' and status = \'A\' and pac_id=<%=pacId%> and secuencia=<%=noAdmision%>)'));
	if(r!=null&&r.length>0){
		for(i=0;i<r.length;i++){
			var c=r[i];
			for(j=0;j<size;j++){
				if(eval('document.form0.codigo'+j).value==c[2].trim()){eval('document.form0.valor'+j).value=c[3].trim();break;}
			}
		}
	}else alert('No hay datos de Signos Vitales en Triage!');
}
function checkLoaded(){if(parent.window.opener.loaded)window.focus();else setTimeout('checkLoaded()',100);}
function checkPersona(){var persona =	document.form0.tipoPersona.value;if(persona !=null && persona !='')return true;else{ alert('Usted no tiene asignado Tipo de Persona para Registrar en está Secci&oacute;n !!');return false;  }}
function setEscala(val){if(val=='S'){document.form0.escala.className = 'FormDataObjectEnabled';eval('document.form0.escala').disabled = false;} else {document.form0.escala.className = 'FormDataObjectDisabled';eval('document.form0.escala').disabled = true;	}}
function setDefault(){}
function setTriage1(h){var fecha = eval('document.form0.fechaR'+h).value ;var hora = eval('document.form0.horaR'+h).value ;var fc = eval('document.form0.fc'+h).value ;window.location = '../expediente/exp_triage.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc='+fc+'&fg=<%=fg%>&desc=<%=desc%>';}
function printExp(){abrir_ventana("../expediente/print_triage.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc=<%=fc%>&fg=<%=fg%>&desc=<%=desc%>&seccion=<%=seccion%>");}
function checkDate(){var hoy = '<%=CmnMgr.getCurrentDate("dd/mm/yyyy")%>';var newHoy =  new Date(hoy.substr(6),parseInt(hoy.substr(3,2),10)-1,hoy.substr(0,2));var choosenDate = document.getElementById("fechaRegistro").value;var choosenHour = document.getElementById("horaRegistro").value;var newchoosenDate  = new Date(choosenDate.substr(6),parseInt(choosenDate.substr(3,2),10)-1,choosenDate.substr(0,2));var flag = false;if (newchoosenDate>newHoy){	alert("La fecha no debe ser mas grande que la de hoy!");flag = false;}else{flag = true;}if ( !compareTime() ){alert("La hora no debe ser mas grande que la actual!");flag = false;}else{flag = true;}if ( flag ) return true;else return false;}
function compareTime(){var choosenHour = document.getElementById("horaRegistro").value;var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','dual','to_date(\''+choosenHour+'\',\'hh12:mi am\') > to_date(to_char(sysdate,\'hh12:mi am\'),\'hh12:mi am\')',''));if ( r > 0 ){return false;}else{return true;}}
function sortUnorderedList(ul,header){var mode = "<%=modeSec%>";var fc = "<%=fc%>";var alh = <%=alh.size()%>
var fp = "<%=fp%>";var flag = false;var cat = document.getElementById("categoria").value;if ( mode == "add" ){flag = true;}if (fc == "" && alh > 0 && fp != "agregar"){flag = false;}var categoria = "4";if ( flag ){var imagen1 = "", imagen2 = "",imagen3 = "",imagen4 = "", imagen = "<img src = '../images/black_tick.png' class='tick' />";var order = document.getElementById("order").value;if ( header == 1 ){categoria = 1; imagen1 = imagen; imagen2 = ""; imagen3 = ""; imagen4 = ""; }else if (header == 2){categoria = 2; imagen1 = ""; imagen2 = imagen; imagen3 = ""; imagen4 = "";}else if (header == 3){categoria = 3; imagen1 = ""; imagen2 = ""; imagen3 = imagen; imagen4 = "";}else{ categoria = 4; imagen1 = ""; imagen2 = ""; imagen3 = ""; imagen4 = imagen;}document.getElementById("tick1").innerHTML = imagen1;document.getElementById("tick2").innerHTML = imagen2;document.getElementById("tick3").innerHTML = imagen3;document.getElementById("tick4").innerHTML = imagen4;if(typeof ul == "string"){ul = document.getElementById(ul);}var lis = ul.getElementsByTagName("li");var vals = [];for(var i = 0, l = lis.length; i < l; i++){vals.push(lis[i].innerText);}if (vals.sort()){document.getElementById("order").value = "1";document.getElementById("prior"+header).innerHTML = "&nbsp;&nbsp;&uArr;";}if(order == "1"){if (vals.reverse()){document.getElementById("order").value = "0";document.getElementById("prior"+header).innerHTML = "&nbsp;&nbsp;&dArr;";}}for(var i = 0, l = lis.length; i < l; i++){lis[i].innerText = vals[i];}document.getElementById("categoria").value = categoria;}}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">


			<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("usuario_creac",sp.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creac",sp.getFechaCreacion())%>
<%=fb.hidden("hora1",sp.getHora())%>
<%=fb.hidden("fecha",sp.getFecha())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipoPersona",""+tipoPersona)%>
<%=fb.hidden("desc",desc)%>


<% if (!fg.trim().equalsIgnoreCase("SV")){ %>

<tr>
				 <td style="text-decoration:none;" colspan="4">
					 <div id="listado" width="100%" class="exp h100">
					 <div id="detListado" class="child">
						<table width="100%" cellpadding="1" cellspacing="0">
					 <tr class="TextRow02">
						<td>&nbsp;Listado de Triage</td>
												<td>&nbsp;</td>
										 <td align="right">
										 <%if(!fp.trim().equals("agregar")){%><a class="Link00" href="javascript:printExp()">[ Imprimir ]</a><%}%></td>
					 </tr>
					 <tr class="TextHeader" align="center">
						<td>Fecha</td>
						<td>Hora</td>
						<td>Usuario</td>
						<td>Estado</td>
					 </tr>
<%
for (int h = 1; h<=alh.size(); h++){
	CommonDataObject cdoh = (CommonDataObject) alh.get(h-1);
			String color = "TextRow02";
	 if (h % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("fechaR"+h,cdoh.getColValue("fechaRegistro"))%>
		<%=fb.hidden("horaR"+h,cdoh.getColValue("horaRegistro"))%>
				<%=fb.hidden("fc"+h, cdoh.getColValue("fecha_creacion"))%>
		 <!--//-->
										<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " align="center" onClick="setTriage1('<%=h%>')">
							 <td><%=cdoh.getColValue("fechaRegistro")%></td>
							 <td><%=cdoh.getColValue("horaRegistro")%></td>
							 <td><%=cdoh.getColValue("status")%></td>
							 <td><%=cdoh.getColValue("usuario_creacion")%></td>
										 </tr>
<%
} //end for historial
%>                  </table>
					</div>
					</div>
				 </td>
			 </tr>
<%}%>

				<tr class="TextRow01">
					<td colspan="4" align="right">
						<%=fb.button("addTriage","Agregar",true,(mode.trim().equals("view"))?true:false,null,null,"onClick=\"javascript:add()\"")%>
						<%=fb.button("listTriage","Ver S.Vitales",true,false,null,null,"onClick=\"javascript:viewList()\"")%>

						<% if (fg.trim().equals("SV") ){ %>
						<%=fb.button("setTriage","Traer S.Vitales",true,false,null,null,"onClick=\"javascript:setTriageDetail()\"")%>						<%}%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%" align="right">Fecha</td>
					<td width="35%">
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fechaRegistro" />
									<jsp:param name="valueOfTBox1" value="<%=sp.getFechaRegistro()%>" />
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
																		<jsp:param name="onChange" value="javascript:checkDate();" />
																		<jsp:param name="jsEvent" value="javascript:checkDate();" />
									</jsp:include>

					<%//=fb.textBox("fecha",sp.getFecha(),false,false,true,10)%></td>
					<td width="15%" align="right">Hora</td>
					<td width="35%">
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="format" value="hh12:mi:ss am" />
									<jsp:param name="nameOfTBox1" value="horaRegistro" />
									<jsp:param name="valueOfTBox1" value="<%=sp.getHoraRegistro()%>" />
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
									</jsp:include>
				<%//=fb.textBox("hora",hora1,false,false,true,11)%></td>
				</tr>
				<%if(!fg.trim().equals("SV")){%>
								<%=fb.hidden("categoria",sp.getCategoria())%>
<tr id="panel1">

				<%}else{%>
				<%=fb.hidden("categoria",sp.getCategoria())%>

				<tr class="TextRow01">
					 <td width="15%" align="right">Evacuacion:&nbsp;</td>
					 <td width="35%" colspan="4"><%=fb.checkbox("evacuacion","S",sp.getEvacuacion().trim().equals("S"),viewMode,null,null,"")%>
													 &nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("evacuacionObs", sp.getEvacuacionObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td>
				</tr>

				<tr class="TextRow01">
					<td width="15%" align="right">Micción:</td>
					 <td width="35%" colspan="4"><%=fb.checkbox("miccion","S",sp.getMiccion().trim().equals("S"),viewMode,null,null,"")%>
													 &nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("miccionObs", sp.getMiccionObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td></td>
				 </tr>

				<tr class="TextRow01">
					<td width="15%" align="right">Vómito:</td>
				 <td width="35%" colspan="4"><%=fb.checkbox("vomito","S",sp.getVomito().trim().equals("S"),viewMode,null,null,"")%>
&nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("vomitoObs", sp.getVomitoObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td></td>
				 </tr>

				<%}%>
					<tr class="TextRow01">
					<td width="15%" align="right">Dolor:</td>
				<td width="35%" colspan="3"><%=fb.select("dolor","S=Si,N=No",sp.getDolor(),false,viewMode,0,null,null,"onChange=\"javascript:setEscala(this.value)\"")%>
&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.intBox("escala",sp.getEscala(),false,false,viewMode,5,2)%>
&nbsp;&nbsp;</td></td>

</td>
				 </tr>
				 <!--<tr class="TextRow01">
					<td width="15%" align="right">Comida:</td>
					 <td width="35%" colspan="4"><%//=fb.select("comida","D=Desayuno,A=Almuerzo,M=Merienda,C=Cena",sp.getVomito(),false,viewMode,0,null,null,null)%>
&nbsp;&nbsp;Comio&nbsp;<%//=fb.select("comio","S=Si,N=No",sp.getVomito(),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;&nbsp;&nbsp;Cantidad&nbsp;<%//=fb.select("Cantidad","0=Nada,1=1/4,2=1/2,3=1/3,4=Todo",sp.getVomito(),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;</td></td>
				 </tr>
				<tr class="TextRow01">
					<td align="right">Observaci&oacute;n</td>
					<td><%//=fb.textarea("observacion", sp.getObservacion(), false, false, viewMode, 0, 5, "", "width:100%", "")%></td>
					<td align="right">Acci&oacute;n</td>
					<td><%//=fb.textarea("accion", sp.getAccion(), false, false, viewMode, 0, 5, "", "width:100%", "")%></td>
				</tr>-->
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellpadding="1" cellspacing="1">
							<tr align="center" class="TextHeader">
								<td width="35%">Factores</td>
								<td width="10%">Valor</td>
								<td width="5%">&nbsp;</td>
								<td width="35%"><%=(al.size() > 1)?"Factores":"&nbsp;"%></td>
								<td width="10%"><%=(al.size() > 1)?"Valor":"&nbsp;"%></td>
								<td width="5%">&nbsp;</td>
							</tr>
<%
int lc = 0;
int ic = 0;
size = al.size();
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (lc % 2 == 0) color = "TextRow01";

	if (ic == 0)
	{
%>
							<tr class="<%=color%>">
<%
	}
	ic++;
%>
								<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
								<td><%=cdo.getColValue("descripcion")%></td>
								<td align="center"><%=fb.textBox("valor"+i, cdo.getColValue("resultado"), false, false, viewMode, 6,10)%></td>
								<td><%=cdo.getColValue("sigla_um")%></td>
<%
	if (ic == 2 || (i + 1) == size)
	{
		if (ic != 2 && (i + 1) == size)
		{
%>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
<%
		}
		ic = 0;
		lc++;
%>
							</tr>
<%
	}
}
fb.appendJsValidation("\n\tif (!checkPersona()) error++;\n");
%>
						</table>
					</td>
				</tr>


<%if(!fg.trim().equals("SV")){%>
<tr>
<td colspan="5" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" >
<table width="100%" cellpadding="1" cellspacing="0">
<!--<tr class="TextPanel">
<td width="100%" align="left" ><font face="Courier New, Courier, mono">
<label id="plus1" style="display:none"></label><label id="minus1"></label></font>&nbsp;
<%//=fb.radio("categoria", "2",(sp.getCategoria().equals("2")),viewMode,false)%>
URGENTE&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td align="center"><%//=fb.radio("categoria", "3",(sp.getCategoria().equals("3")),viewMode,false,"","","onChange=\"javascript:setDefault(this.value)\"")%>
NO URGENTE&nbsp;&nbsp;&nbsp;</td>
<td align="right">&nbsp;&nbsp;&nbsp;<%//=fb.radio("categoria", "1",(!sp.getCategoria().equals("2")&&!sp.getCategoria().equals("3")),viewMode,false)%>
&nbsp;&nbsp;&nbsp;CRITICO</td>
</tr>-->
</table>
</td>
</tr>
<%=fb.hidden("order", "")%>
<%//=fb.hidden("categoria", "4")%>
		<td colspan="4">
			<table width="100%" cellpadding="1" cellspacing="1">
			<tr id="panel1" class="TextHeader" align="center">
					<td width="25%" class="BackgroundBlue" style="cursor:pointer; " onClick="sortUnorderedList('prioridad1',1);"><span style="display:;" id="tick1"><% if ( sp.getCategoria().equals("1") ){%><img src = '../images/black_tick.png' class='tick' /><%}%></span>
				PRIORIDAD 1<br />(AZUL)<span id="prior1">&nbsp;</span>
				</td>
				<td width="25%" style="background-color:#f00" style="cursor:pointer" onclick="sortUnorderedList('prioridad2',2)"><span style="display:;" id="tick2"><% if ( sp.getCategoria().equals("2") ){%><img src = '../images/black_tick.png' class='tick' /><%}%></span>
				PRIORIDAD 2<br />(ROJO)<span id="prior2">&nbsp;</span>
				</td>
				<td width="25%" style="background-color:#ffde00" style="cursor:pointer" onclick="sortUnorderedList('prioridad3',3)"><span style="display:;" id="tick3"><% if ( sp.getCategoria().equals("3") ){%><img src = '../images/black_tick.png' class='tick' /><%}%></span>
				PRIORIDAD 3<br />(AMARILLO)<span id="prior3">&nbsp;</span>
				</td>
				<td width="25%" style="background-color:#090" style="cursor:pointer" onclick="sortUnorderedList('prioridad4',4)"><span style="display:;" id="tick4">
				<% if ( sp.getCategoria().equals("4") ){%><img src = '../images/black_tick.png' class='tick' /><%}%></span>
				PRIORIDAD 4<br />(VERDE)<span id="prior4">&nbsp;</span>
				</td>
			</tr>
					<td width="25%" class="TextRow02" style="border:#004f9f solid 1px; padding-left:0;" valign="top">
					<span>
						 <ul class="prioridad" id="prioridad1">
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')">
							<a href="javascript:" class="Link00">POLITRAUMATISMO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">TRAUMO PENETRANTE DE CUALQUIER ETIOLOGIA O LOCALIZACI&Oacute;N</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')">
							<a href="javascript:" class="Link00">DETERIORO AGUDO DEL ESTADO DEL CONCIENCIA.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')">
							<a href="javascript:" class="Link00">SHOCK DE CUALQUIER ETIOLOGIA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">PARO CARADIORESPIRATORIO DE CUALQUIER ETIOLOGIA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DOLOR TORACICO CON PALIDEZ CUTANEA, HIPO O HIPERTENSI&Oacute;N ARTERIAL, CON ALTERACI&Oacute;N DE LA FRECUENCIA CARDIACA O INCREMENTO DE LA FRECUENCIA RESPIRATORIA.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ARRITMIA CARDIACA CON INESTABILIDAD HEMODINAMICA.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INFARTO AGUDO AL MIOCARDIO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DISNEA CON ALGUNOS DE LOS DATOS QUE ESPECIFICAN PARA EL DOLOR TORACICO.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">OBSTRUCCI&Oacute;N DE LA VIA AEREA POR CUERPO EXTRAÑO.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">CEFALEA INTENSA ACOMPAÑADA DE FIEBRE, ALTERACI&Oacute;N DE LA CONCIENCIA, HIPERTENSI&Oacute;N ARTERIAL, VOMITOS, FOCALIDAD NEUROLOGICA.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DOLOR ABDOMINAL CON INTENSIDAD DE 7-10</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">TENSION ARTERIAL MAYOR O IGUAL A 180/120</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HEMORRAGIAS DE VIAS DIGESTIVAS ALTAS O BAJAS CON INESTABILIDAD HEMODINAMICA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">QUEMADURA DE CUALQUIER ETIOLOGIA, MAYORES AL 20% DE EN CUALQUIER GRADO Y LOCALIZACI&Oacute;N</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INSUFICIENCIA RESPIRATORIA DE CUALQUIER ETIOLOGIA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESTATUS EPILEPTICO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">REACCI&Oacute;N ANAFILACTICA, CON COMPROMISO RESPIRATORIO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INTOXICACI&Oacute;N EXOGENA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESTATUS PSICOTICO AGUDO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SINCOPE DE CUALQUIER ETIOLOGIA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">TRABAJO DE PARTO EXPULSIVO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HEMORRAGIA AGUDA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">FRACTURA CON COMPROMISO NEURO-VASCULAR</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DIABETES DESCOMPENSADA Y OTRAS PATOLOGIAS METABOLICAS DESCOMPENSADAS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INSUFICIENCIA VASCULAR AGUDA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">QUEMADURA ELECTRICA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">CUERPO EXTRAÑO EN VIAS AEREAS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INTENTO DE SUICIDIO O AUTOLITICO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">MALTRATO INFANTIL</a></li>
						 </ul>
					</span>
				</td>
				<td width="25%" class="TextRow02" style="border:#f00 solid 1px; padding-left:0" valign="top">
					<span>
						 <ul class="prioridad" id="prioridad2">
						 <li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')">
						 <a href="javascript:" class="Link00">CRISIS ASMATICA CON INSUFICIENCIA RESPIRATORIA</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESTADO POSTICTAL</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HEMOPTISIS NO MASIVA</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">COLICO URETERAL DE INTENSIDAD DE 7-10</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SANGRADO VAGINAL DURANTE EL EMBARAZO</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DIABETES MELLITUS CON SIGNOS DE HIPO O HIPERGLICEMIA CON COMPROMISO DEL ESTADO GENERAL</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">QUEMADURAS DE 1&deg; Y 2&deg; GRADO, MENORES AL 20% DE LA SUPERFICIE CORPORAL Y QUE NO COMPROMETAN AREAS ESPECIALES</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">FRACTURAS DISTALES ESTABLES EN EXTREMIDADES, LUXACIONES CON COMPROMISO NEUROVASCULAR.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SINDROME FEBRIL EN NIÑOS CON T&deg; MAYOR DE 38&deg;</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">CEFALEA SEVERA (8-10) DE INICIO RECIENTE O CON SINTOMAS NEUROLOGICOS.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">VOMITOS PERSISTENTES CON DESHIDRATACI&Oacute;N MODERADA A SEVERA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ACCIDENTE CEREBRO VASCULAR TRANSITORIO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DELIRIUM TREMENS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">TRAUMA CRANEO ENCEFALICO MODERADO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">LUMBALGIA AGUDA MODERADA A SEVERA O CRONICA AGUDIZADA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">RETENCION URINARIA AGUDA.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INSUFICIENCIA RENAL CRONICA CON SIGNOS DE DESCOMPRESI&Oacute;N</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">MORDEDURA DE ANIMALES</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">PERDIDA SUBITA DE LA VISI&Oacute;N</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">VIOLACI&Oacute;N</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DIARREA QUE COMPROMETE EL ESTADO GENERAL</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESGUINCES SEVEROS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">CUERPOS EXTRAÑOS EN OJOS OIDOS O NARIZ</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">TROMBOSIS VENOSA PROFUNDA</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HEMORROIDES TROMBOSADAS O PROLAPSADAS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HERIDAS POR ARMA CORTOPUNZANTE SIN SANGRADO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">VERTIGO SEVERO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DOLOR PLEURITICO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HERIDAS INFECTADAS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ACCIDENTES DE TRANSITO O LABORALES SIN COMPROMISO DEL ESTADO GENERAL</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ABSCESOS PARA DRENAR CON DOLOR DE INTENSIDAD DE (7-10)</a></li>
						 </ul>
					</span>
				</td>

				<td width="25%" class="TextRow02" style="border:#ffde00 solid 1px; padding-left:0" valign="top">
					<span>
						 <ul class="prioridad"  id="prioridad3">

								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">VERTIGO LEVE</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">OTALGIA MODERADA</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INFECCIONES RESPIRATORIAS ALTAS NO COMPLICADAS EN NIÑOS</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00"></a>INFECCIONES SIN COMPROMISO DEL ESTADO GENERAL</li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">TRAUMA LEVE AISLADO, MAYOR DE 24 HORAS DE EVOLUCI&Oacute;N.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SINDROME FEBRIL EN ADULTOS CON T&deg; MAYOR DE 38&deg;.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ABRASIONES Y LESIONES SUPERFICIALES EN PIEL.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">LESIONES OSTEOMUSCULARES SIN DEFORMIDAD.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESPISTAXIS CON SIGNOS VITALES NORMALES.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HEMORRAGIAS SUBCONJUNTIVALES.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HERIDAS CONTUSAS SIN DEFORMIDAD</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HEMATURIA.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">CEFALEA AGUDA SIN SINTOMAS NEUROLOGICOS</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SINDROME ICTERICO.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SINDROME DIARREICO SIN COMPROMISO  DEL ESTADO GENERAL EN EL ADULTO.</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">METRORRAGIA LEVE, SIN COMPROMISO HEMODINAMICO</a></li>
							<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">LUMBALGIA AGUDA LEVE O CRONICA AGUDIZADA</a></li>
						 </ul>
					</span>
				</td>

				<td width="25%" class="TextRow02" style="border:#090 solid 1px; padding-left:0" valign="top">
					<span>
						 <ul class="prioridad"  id="prioridad4">

								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INFECCIONES RESPIRATORIAS ALTAS NO COMPLICADAS EN EL ADULTO</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESTADO GRIPAL EN ADULTOS</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">SINTOMAS GASTROINTESTINALES</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">HIPERTENSI&OacuteN ARTERIAL NO COMPLICADA</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DOLOR MUSCULO-ESQUELETICO LEVE.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ENFERMEDAD DERMATOLOGICA CRONICA</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DIARREA SIN COMPROMISO DEL ESTADO GENERAL EN ADULTOS.</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">INFECCI&Oacute;N URINARIA SIN COMPROMISO DEL ESTADO GENERAL</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">CEFALEA CRONICA LEVE</a></li>
								<li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ESTREÑIMIENTO</a></li>
							 <li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">ANOREXIA</a></li>
							 <li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">LEUCORREA</a></li>
							 <li onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoverc(this,'TextRow02')"><a href="javascript:" class="Link00">DISMINORREA</a></li>
						 </ul>
					</span>
				</td>

			</tr>

			</table>
		</td>
	</tr>

			<%}%>


				<tr class="TextRow02">
					<td colspan="4" align="right">
				Opciones de Guardar:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>

					 <% if ( fg.equalsIgnoreCase("SV") ){
					fb.appendJsValidation("if(!checkDate()){error++;}");
				 }
			 %>

<%=fb.formEnd(true)%>
			</table>


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

	SignoPaciente spa = new SignoPaciente();

	spa.setCodPaciente(request.getParameter("codPac"));
	spa.setSecuencia(request.getParameter("noAdmision"));
	spa.setFecNacimiento(request.getParameter("dob"));
	spa.setPacId(request.getParameter("pacId"));
	spa.setFecha(request.getParameter("fecha"));
	spa.setFechaRegistro(request.getParameter("fechaRegistro"));
	spa.setTipoSigno("PO");
	spa.setPersonal("E");
	spa.setUsuarioCreacion(request.getParameter("usuario_creac"));
	spa.setUsuarioModif((String) session.getAttribute("_userName"));
	spa.setFechaCreacion(request.getParameter("fecha_creac"));
	spa.setFechaModif(cDateTime);
	spa.setCategoria(request.getParameter("categoria"));
	spa.setEvacuacion(request.getParameter("evacuacion"));
	spa.setMiccion(request.getParameter("miccion"));
	spa.setVomito(request.getParameter("vomito"));
	spa.setVomitoObs(request.getParameter("vomitoObs"));
	spa.setMiccionObs(request.getParameter("miccionObs"));
	spa.setEvacuacionObs(request.getParameter("evacuacionObs"));
	spa.setHora(request.getParameter("hora1"));
	spa.setHoraRegistro(request.getParameter("horaRegistro"));

	if(request.getParameter("tipoPersona") == null || request.getParameter("tipoPersona").trim().equals("") || request.getParameter("tipoPersona").trim().equals("null")) {
	spa.setTipoPersona("T");
	}
	else
	{
	spa.setTipoPersona(request.getParameter("tipoPersona"));
	}


//	else throw new Exception("Usted no tiene asignado Tipo de Persona para Registrar en está Secci&oacute;n !!");

	//spa.setObservacion(request.getParameter("observacion"));
	spa.setAccion(request.getParameter("accion"));

		spa.setDolor(request.getParameter("dolor"));
			spa.setEscala(request.getParameter("escala"));

	size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		DetalleSignoPaciente spc = new DetalleSignoPaciente();

		spc.setResultado(request.getParameter("valor"+i));
		spc.setCodPaciente(request.getParameter("codPac"));
		spc.setFechaNacimiento(request.getParameter("dob"));
		spc.setSignoVital(request.getParameter("codigo"+i));
		spc.setSecuencia(request.getParameter("noAdmision"));
		spc.setPacId(request.getParameter("pacId"));

		//tipoPersona hace referencia a TBL_SAL_SIGNO_PACIENTE

		//if(!spa.getTipoPersona().trim().equals("null") || !spa.getTipoPersona().trim().equals("")) { // tipoPersona = A, pero con esa condición, se estan
		//pasando T a tbl_sal_detalle_signo T <> A, parent key not found.....

		if(!spa.getTipoPersona().trim().equals("null") || !spa.getTipoPersona().trim().equals("")) {
		spc.setTipoPersona(spa.getTipoPersona());
		 }
		else{
		spc.setTipoPersona("T");
		}

		spc.setHora(request.getParameter("hora1"));
		spc.setFechaSigno(request.getParameter("fecha"));
		spc.setUsuarioCreacion(request.getParameter("usuario_creac"));
		spc.setFechaCreacion(request.getParameter("fecha_creac"));
		spc.setUsuarioModificacion((String) session.getAttribute("_userName"));

		spc.setTipoSigno("PO");
		spc.setCodigo("1");
		if(!spc.getResultado().trim().equals("")){
			spa.addDetalleSignoPaciente(spc);
		}
	}


	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		SPMgr.add(spa);
		//id = TescMgr.getPkColValue("codigo");
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
		SPMgr.update(spa);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>

<script language="javascript">
function closeWindow()
{
<%
if (SPMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SPMgr.getErrMsg()%>');
<%
	if (modeSec.equalsIgnoreCase("add") && (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU")))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
	parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
	parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}
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
} else throw new Exception(SPMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
