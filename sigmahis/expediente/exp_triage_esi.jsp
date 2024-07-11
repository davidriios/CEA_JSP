<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
String sql = "", sqlTitle="";
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

if(desc == null) desc = "";
if(fc == null) fc = "";

String categoria= request.getParameter("categoria");

if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode == null||mode.trim().equals("")) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (fg == null){ fg = "TSV"; subTitulo ="TRIAGE/SIGNOS VITALES";}
else subTitulo ="SIGNOS VITALES";

if (fp == null) fp = "agregar";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String hora1="";
int size = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
System.out.println("mode *************************************************** "+mode);
if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "SELECT nvl(observacion,' ') AS observacion, nvl(accion,' ') AS accion, nvl(categoria,' ') AS categoria, nvl(evacuacion,'N') as evacuacion, nvl(miccion,'N') as miccion, nvl(vomito,'N') as vomito, nvl(miccion_obs,' ') as miccionObs, nvl(evacuacion_obs,' ') as evacuacionObs, nvl(vomito_obs,' ') as vomitoObs, to_char(fecha,'dd/mm/yyyy') as fecha,to_char(decode(observacion,'CONNEX',fecha,fecha_registro),'dd/mm/yyyy') as fechaRegistro, to_char(decode(observacion,'CONNEX',hora,hora_registro),'dd/mm/yyyy hh12:mi:ss am') as hora,to_char(decode(observacion,'CONNEX',hora,hora_registro),'hh12:mi am') as horaRegistro, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_creacion as usuarioCreacion,dolor as dolor, escala as escala FROM tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
if (!viewMode) sql += " and status = 'A'";

System.out.println("modeSec ========"+modeSec+" **** fp ==="+fp+"   fg =*************************************   fg =============="+fg+"    fc ========================="+fc);

	if (fp.equalsIgnoreCase("agregar")||modeSec.trim().equals("add")) sql +=" and to_date(decode(observacion,'CONNEX',fecha,fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	else {if (!fg.equalsIgnoreCase("SV") && fc != null) {
		sql +=appendFilter+" and decode(observacion,'CONNEX',fecha,fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
	} else {
		sql +=" and decode(observacion,'CONNEX',fecha,fecha_creacion) = (select max(decode(observacion,'CONNEX',fecha,fecha_creacion))fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
		if (!viewMode) sql += " and status = 'A'";
		sql += ") ";
	}
}
	System.out.println("UserDet.getRefType() = "+UserDet.getRefType()+" UserDet.getUserTypeCode() = "+UserDet.getUserTypeCode());
	if (fg.equalsIgnoreCase("TSV") && (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().equalsIgnoreCase("AU") || UserDet.getUserTypeCode().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().equalsIgnoreCase("ES"))) tipoPersona = "T";
	else if (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().equalsIgnoreCase("AU")) tipoPersona = "A";
	else if (UserDet.getUserTypeCode().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().equalsIgnoreCase("ES")) tipoPersona = "E";
	else if (UserDet.getRefType().equalsIgnoreCase("M")) tipoPersona = "M";

	if (tipoPersona != null && !tipoPersona.trim().equals("")) 	appendFilter += " and tipo_persona='"+tipoPersona+"'";
	sp = (SignoPaciente) sbb.getSingleRowBean(ConMgr.getConnection(), sql, SignoPaciente.class);

	String xtraH = "";
	if (tipoPersona != null && !tipoPersona.trim().equals("")) xtraH = " and sp.tipo_persona = '"+tipoPersona+"'";

	String sqlH = "select sp.usuario_creacion, to_char(sp.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc , to_char(decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char( decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_registro) ,'dd/mm/yyyy') as fechaRegistro, decode(sp.observacion,'CONNEX','Connex - ',' ')||to_char( decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_registro) ,'dd/mm/yyyy') as fechaRegistroDsp, to_char(decode(sp.observacion,'CONNEX',sp.hora,sp.hora_registro),'hh12:mi am') as horaRegistro, decode(sp.status,'I','INVALIDO','VALIDO') as status FROM tbl_sal_signo_paciente sp WHERE sp.tipo_persona = 'T'  and sp.pac_id="+pacId+" AND sp.secuencia="+noAdmision+" order by sp.fecha_creacion desc";

	alh = SQLMgr.getDataList(sqlH);

	if(sp==null){System.out.println("SIGNO VITAL ES  NULO ");
	sp = new SignoPaciente();
	sp.setFecha(cDateTime.substring(0,10));
	sp.setFechaRegistro(cDateTime.substring(0,10));
	sp.setHora(cDateTime);
	sp.setCategoria("0");
	sp.setHoraRegistro(CmnMgr.getCurrentDate("hh12:mi:ss am"));
	sp.setFechaCreacion(cDateTime);
	sp.setFechaModif(cDateTime);
	sp.setUsuarioCreacion((String) session.getAttribute("_userName"));
	sp.setUsuarioModif((String) session.getAttribute("_userName"));
	if (!viewMode) mode = "add";

	}
	else { if(!viewMode){mode = "edit";viewMode =true;} }//if (!viewMode) mode = "view";
	sql = "select a.*, nvl(b.sigla_um,' ') as sigla_um, nvl(c.resultado,' ') as resultado from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select aa.* from tbl_sal_detalle_signo aa, tbl_sal_signo_paciente s where s.pac_id="+pacId+" and s.secuencia="+noAdmision;
	if (!viewMode) sql += " and s.status = 'A'";
	sql += " and s.pac_id = aa.pac_id and s.secuencia = aa.secuencia and s.fecha = aa.fecha_signo and s.hora = aa.hora and s.tipo_persona = aa.tipo_persona";

	if(fp.trim().equals("agregar")) sql +=" and to_date(decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	else {
		if(!fg.trim().equalsIgnoreCase("SV") && fc != null){
			sql +=appendFilter+" and decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
		} else {
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

	String printTriageESI = "ES";
	try{printTriageESI=java.util.ResourceBundle.getBundle("issi").getString("printTriageESI");}catch(Exception e){}
%>

<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<style type="text/css">
/*
.nourgente:hover{background-color: #008000;}
.critico:hover{background-color: #F00;}
.urgente:hover{background-color: #ff0;}
.nourgente:hover,.critico:hover,.urgente:hover{color:#000;}
*/
</style>
<script language="javascript">
document.title = 'Triage/Signos Vitales - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();setTimeout('checkLoaded()',100);}
function viewList(){abrir_ventana1('../expediente/triage_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&seccion=<%=seccion%>');}
function add(){window.location = '../expediente/exp_triage_esi.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=agregar&desc=<%=desc%>&seccion=<%=seccion%>';}
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
function checkPersona(){var persona =	document.form0.tipoPersona.value;if(persona !=null && persona !='')return true;	else{ alert('Usted no tiene asignado Tipo de Persona para Registrar en está Secci&oacute;n !!');return false; }}
function setEscala(val){if(val=='S'){document.form0.escala.className = 'FormDataObjectEnabled';	eval('document.form0.escala').disabled = false;} else {document.form0.escala.className = 'FormDataObjectDisabled';eval('document.form0.escala').disabled = true;}}
function setDefault(){}
function setTriage1(h){var fecha = eval('document.form0.fechaR'+h).value ;var hora = eval('document.form0.horaR'+h).value ;var fc = eval('document.form0.fc'+h).value ;window.location = '../expediente/exp_triage_esi.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc='+fc+'&fg=<%=fg%>&desc=<%=desc%>&fp=view';}
function printExp(){abrir_ventana("../expediente/print_triage.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc=<%=fc%>&fg=TSV_ESI&desc=<%=desc%>&seccion=<%=seccion%>&tipoPersona=<%=tipoPersona%>");}
function checkDate(){var hoy = '<%=CmnMgr.getCurrentDate("dd/mm/yyyy")%>';var newHoy =  new Date(hoy.substr(6),parseInt(hoy.substr(3,2),10)-1,hoy.substr(0,2));var choosenDate = document.getElementById("fechaRegistro").value;var choosenHour = document.getElementById("horaRegistro").value;var newchoosenDate  = new Date(choosenDate.substr(6),parseInt(choosenDate.substr(3,2),10)-1,choosenDate.substr(0,2));var flag = false;if (newchoosenDate>newHoy){alert("La fecha no debe ser mas grande que la de hoy!");flag = false;}else{flag = true;}if ( !compareTime() ){alert("La hora no debe ser mas grande que la actual!");flag = false;}else{flag = true;}if ( flag ) return true;else return false;}
function compareTime(){var choosenHour = document.getElementById("horaRegistro").value;var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','dual','to_date(\''+choosenHour+'\',\'hh12:mi:ss am\') > to_date(to_char(sysdate,\'hh12:mi:ss am\'),\'hh12:mi:ss am\')',''));	if ( r > 0 ){ return false;	}else{return true;}}
$(document).ready(function(r){
	var fg = "<%=fg%>";
	$("#save").click(function(c){
	if(fg != "SV" && !$('[name="categoria"]').is(":checked")) {
		alert("Por favor seleccione una categoría!");
		c.preventDefault();
	}
 });

 var orgiginalBg=$("#critico_w").css('background-color');
 $("#critico_w, #urgente_w, #nourgente_w").hover(
		function() {
		var obj = $(this);
		var _this_id = obj.attr('id');
		var cat = $(this).find('input:radio').is(':disabled');
		if (!cat){
			if (_this_id=='critico_w')obj.css({background:'#F00',color:'#000'});
			else if (_this_id=='urgente_w')obj.css({background:'#ff0',color:'#000'});
			else if (_this_id=='nourgente_w')obj.css({background:'#008000',color:'#000'});

		}
	},
		function() {
		 var cat = $(this).find('input:radio').is(':disabled');
		 if (!cat)$(this).css({background:orgiginalBg,color:'#fff'});});
});

function showHelp(lng){
	if (lng && lng=="es") abrir_ventana("../expediente/triage_esi_spanish.pdf");
	else abrir_ventana("../expediente/triage_esi.pdf");
}
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
<%=fb.hidden("cI","")%>

<% if (!fg.trim().equalsIgnoreCase("SV")){ %>

<tr>
				 <td style="text-decoration:none;" colspan="4">
					 <div id="listado" width="100%" class="exp h100">
					 <div id="detListado" class="child">
						<table width="100%" cellpadding="1" cellspacing="0">
					 <tr class="TextRow02">
						<td>&nbsp;<cellbytelabel>Listado de Triage</cellbytelabel></td>
												<td>&nbsp;</td>
										 <td align="right">

										 <authtype type="50">
										 <%if(printTriageESI.equals("EN")){%><a class="Link00" href="javascript:showHelp()">[ <cellbytelabel>Triage ESI - EN</cellbytelabel> ]</a><%}else{%>
										 <a class="Link00" href="javascript:showHelp('es')">[ <cellbytelabel>Triage ESI - ES</cellbytelabel> ]</a><%}%>
										 </authtype>

										 <%if(!fp.trim().equals("agregar")){%><a class="Link00" href="javascript:printExp()">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a><%}%></td>
					 </tr>
					 <tr class="TextHeader" align="center">
						<td><cellbytelabel>Fecha</cellbytelabel></td>
						<td><cellbytelabel>Hora</cellbytelabel></td>
						<td><cellbytelabel>Usuario</cellbytelabel></td>
						<td><cellbytelabel>Estado</cellbytelabel></td>
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
							 <td><%=cdoh.getColValue("fechaRegistroDsp")%></td>
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
						<%=fb.button("setTriage","Traer S.Vitales",true,false,null,null,"onClick=\"javascript:setTriageDetail()\"")%>

						<%=fb.button("btnHelp","Ayuda",true,false,null,null,"onClick=parent.showHelp()")%>
						<%}%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="35%">
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="nameOfTBox1" value="fechaRegistro"/>
									<jsp:param name="valueOfTBox1" value="<%=sp.getFechaRegistro()%>"/>
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
																		<jsp:param name="onChange" value="javascript:checkDate();"/>
																		<jsp:param name="jsEvent" value="javascript:checkDate();"/>
									</jsp:include>

					<%//=fb.textBox("fecha",sp.getFecha(),false,false,true,10)%></td>
					<td width="15%" align="right"><cellbytelabel>Hora</cellbytelabel></td>
					<td width="35%">
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi:ss am"/>
									<jsp:param name="nameOfTBox1" value="horaRegistro"/>
									<jsp:param name="valueOfTBox1" value="<%=sp.getHoraRegistro()%>"/>
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
									</jsp:include>
				<%//=fb.textBox("hora",hora1,false,false,true,11)%></td>
				</tr>
				<%if(!fg.trim().equals("SV")){%>

<tr id="panel1">

				<%}else{%>
				<%=fb.hidden("categoria",sp.getCategoria())%>

				<tr class="TextRow01">
					 <td width="15%" align="right"><cellbytelabel>Evacuaci&oacute;n</cellbytelabel>:&nbsp;</td>
					 <td width="35%" colspan="4"><%=fb.checkbox("evacuacion","S",sp.getEvacuacion().trim().equals("S"),viewMode,null,null,"")%>
													 &nbsp;&nbsp;Observaci&oacute;n:&nbsp;<%=fb.textarea("evacuacionObs", sp.getEvacuacionObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td>
				</tr>

				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>Micci&oacute;n</cellbytelabel>:</td>
					 <td width="35%" colspan="4"><%=fb.checkbox("miccion","S",sp.getMiccion().trim().equals("S"),viewMode,null,null,"")%>
													 &nbsp;&nbsp;Observaci&oacute;n:&nbsp;<%=fb.textarea("miccionObs", sp.getMiccionObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td></td>
				 </tr>

				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>V&oacute;mito</cellbytelabel>:</td>
				 <td width="35%" colspan="4"><%=fb.checkbox("vomito","S",sp.getVomito().trim().equals("S"),viewMode,null,null,"")%>
&nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("vomitoObs", sp.getVomitoObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td></td>
				 </tr>

				<%}%>
					<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>Dolor</cellbytelabel>:</td>
				<td width="35%" colspan="3"><%=fb.select("dolor","S=Si,N=No",sp.getDolor(),false,viewMode,0,null,null,"onChange=\"javascript:setEscala(this.value)\"")%>
&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.intBox("escala",sp.getEscala(),false,false,viewMode,5,2)%>
&nbsp;&nbsp;</td>
</td>
				 </tr>
				 <%--<tr class="TextRow01">
					<td width="15%" align="right">Comida:</td>
					 <td width="35%" colspan="4"><%//=fb.select("comida","D=Desayuno,A=Almuerzo,M=Merienda,C=Cena",sp.getVomito(),false,viewMode,0,null,null,null)%>
&nbsp;&nbsp;Comio&nbsp;<%//=fb.select("comio","S=Si,N=No",sp.getVomito(),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;&nbsp;&nbsp;Cantidad&nbsp;<%//=fb.select("Cantidad","0=Nada,1=1/4,2=1/2,3=1/3,4=Todo",sp.getVomito(),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;</td></td>
				 </tr>
				<tr class="TextRow01">
					<td align="right">Observaci&oacute;n</td>
					<td><%//=fb.textarea("observacion", sp.getObservacion(), false, false, viewMode, 0, 5, "", "width:100%", "")%></td>
					<td align="right">Acci&oacute;n</td>
					<td><%//=fb.textarea("accion", sp.getAccion(), false, false, viewMode, 0, 5, "", "width:100%", "")%></td>
				</tr>--%>
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellpadding="1" cellspacing="1">
							<tr align="center" class="TextHeader">
								<td width="10%"><cellbytelabel>Factores</cellbytelabel></td>
								<td width="35%"><cellbytelabel>Valor</cellbytelabel></td>
								<td width="5%">&nbsp;</td>
								<td width="35%">
									<%//=(al.size() > 1)?"Factores":"&nbsp;"%>
									<%if(al.size() > 1){%><cellbytelabel>Factores</cellbytelabel><%}else{%>&nbsp;<%}%>
								</td>
								<td width="10%">
									<%//=(al.size() > 1)?"Valor":"&nbsp;"%>
									<%if(al.size() > 1){%><cellbytelabel>Valores</cellbytelabel><%}else{%>&nbsp;<%}%>
								</td>
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
System.out.println(" i= "+i+"  descripcion == "+cdo.getColValue("descripcion"));
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
								<td align="center">
								<%String di = "\""+i+"\"";
									String bgColor = "#fff", title="";
									String resultado = "0.0";
									double res = 0.0;
								%>

								<%if(cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals("1")){
									 resultado = ( (cdo.getColValue("resultado").trim()==null || cdo.getColValue("resultado").trim().equals("")) && cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals("1") ) ? "0.0":cdo.getColValue("resultado");
									 //res = Double.parseDouble(resultado);
								%>
									<%--<span style="width:15px;height:15px; display:<%=res>0.0?"inline-block":"none"%>;">&nbsp;</span>	--%>
								<%}%>

								<%=((cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals("1"))?fb.decBox("valor"+i, cdo.getColValue("resultado"), false, false, viewMode, 6,"7.2","slider",null,null,null,false, " data-index="+di):fb.textBox("valor"+i, cdo.getColValue("resultado"), false, false, viewMode, 6,10,"slider",null,null,null,false, " data-index="+di))%>
								<%if(cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals("1")){

								//if ( res < 36.5 ) {bgColor = "#1DCBEA"; title="Hipotermia";}
								//else if ( res >= 36.5 && res <= 37.5 ) {bgColor = "#00f"; title="Normal";}
								//else if ( res > 37.5 ) {bgColor = "#f00"; title="Hipertermia ";}
								%>
									<%--<span style="width:15px;height:15px;background:<%=bgColor%>; display:<%=res>0.0?"inline-block":"none"%>; cursor:pointer" class="hint hint--right" data-hint="<%=title%>">&nbsp;</span>--%>
								<%}%>
								</td>
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
<!--
.nourgente:hover{background-color: #008000;}
.critico:hover{background-color: #F00;}
.urgente:hover{background-color: #ff0;}
.nourgente:hover,.critico:hover,.urgente:hover{color:#000;}
-->


<tr>
<td colspan="5" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" >
<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextPanel">
<td width="33%" align="left" id="critico_w"<%=sp.getCategoria().equals("1")?" style='background:#F00;color:#000'":""%>>
<input type="radio" name="categoria" id="critico"  value="1"<%=sp.getCategoria().equals("1")?" checked":""%> <%=viewMode?"disabled":""%> />
<label for="critico" style="cursor:pointer"><cellbytelabel>PRIORIDAD 1</cellbytelabel></label>
</td>
<td align="left" width="33%"  id="urgente_w"<%=sp.getCategoria().equals("2")?" style='background:#ff0;color:#000'":""%>>
<input type="radio" name="categoria" id="urgente" value="2"<%=sp.getCategoria().equals("2")?" checked":""%> <%=viewMode?"disabled":""%> /> <label for="urgente"  style="cursor:pointer"><cellbytelabel>PRIORIDAD 2</cellbytelabel></label>
</td>
<td align="left" width="34%" id="nourgente_w"<%=sp.getCategoria().equals("3")?" style='background:#008000;color:#000'":""%>>
<input type="radio" name="categoria" id="nourgente" value="3"<%=sp.getCategoria().equals("3")?" checked='checked'":""%> <%=viewMode?"disabled":""%> />
<label for="nourgente" style="cursor:pointer"><cellbytelabel>PRIORIDAD 3</cellbytelabel></label>
</td>
</tr>
</table>
</td>
</tr>

		<td colspan="4">
			<table width="100%" cellpadding="1" cellspacing="1">
			<tr  align="left" class="TextRow02">
				<td>Para Cardiorespiratorio</td>
				<td>Dolor de cabeza intenso y comienzo súbito</td>
				 <td>Crisis hipertensivas sin factores de riesgos cardiovascular para su vida</td>
			</tr>
			<tr  align="left" class="TextRow01">
				<td>Apnea</td>
				<td>Compromiso del estado de conciencia</td>
				<td>Hemorragias recientes (no activas)</td>
			</tr>
			<tr  align="left" class="TextRow02">
			 <td>Quemadura de vías aéreas</td>
				<td>Estado de confusión, Letárgico</td>
				<td>Niños con saturación de oxígeno entre 90-95%</td>
			</tr>
			<tr  align="left" class="TextRow01">
				<td>Insuficiencia respiratoria severa</td>
				<td>Cardiopatías</td>
				<td>Convulsiones de pacientes epilépticos</td>
			</tr>
			<tr  align="left" class="TextRow02">
				<td>Status convulsivo</td>
				<td>Hipertensión arterial</td>
				<td>Vomito persistente en niños</td>
			</tr>
			<tr class="TextRow01">
					 <td>Intoxicaciones</td>
				<td>Signos de deshidratación en niño pequeño</td>
				<td>Cuadro gastrointestinal en adultos</td>
			</tr>
			<tr class="TextRow02">
				<td>Hemorragia severa</td>
				<td>Reacción alérgica severa</td>
				<td>Fractura de cadera o de una extremidad</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;</td>
				<td>Trauma ocular</td>
				<td>Aspiración de cuerpo extraño sin dificultad respiratoria</td>
			</tr>
			<tr class="TextRow02">
					<td>&nbsp;</td>
				<td>Hemorragia mayor</td>
				<td>Diarreas</td>
			</tr>
			<tr class="TextRow01">
					<td>&nbsp;</td>
				<td>Traumatismo moderado</td>
				<td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
					<td>&nbsp;</td>
				<td>Dolor severo en escala de 7 a 10</td>
				<td>&nbsp;</td>
			</tr>
			</table>
		</td>
	</tr>

			<%}%>


				<tr class="TextRow02">
					<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
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
	if (mode.equalsIgnoreCase("add"))
	{
		SPMgr.add(spa);
		//id = TescMgr.getPkColValue("codigo");
		fc=spa.getFechaCreacion();
	}
	else if (mode.equalsIgnoreCase("edit"))
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
	if (mode.equalsIgnoreCase("add") && (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU")))
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&fc=<%=fc%>&fp=view';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
