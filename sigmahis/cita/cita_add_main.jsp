<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr"	scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr"	scope="session" class="issi.admin.SecurityMgr"	/>
<jsp:useBean id="UserDet"	scope="session" class="issi.admin.UserDetail"	/>
<jsp:useBean id="CmnMgr"	scope="page"	class="issi.admin.CommonMgr"	/>
<jsp:useBean id="SQLMgr"	scope="page"	class="issi.admin.SQLMgr"		/>
<jsp:useBean id="fb"		scope="page"	class="issi.admin.FormBean"		/>
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

String sql="";
String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy"); 
if (request.getParameter("currDate")!= null) currDate = request.getParameter("currDate");

String act = "0"; //act=0 add, act=1 edit, act=2 transfer
if (request.getParameter("act")!= null) act = request.getParameter("act");

String from = "img"; //from=img simple.view, from=qui view.for.operating.room 
if (request.getParameter("from")!= null) from = request.getParameter("from");

String id = "0"; 
if (request.getParameter("id")!= null) id = request.getParameter("id");

String chab = "0"; //codigo del servicio.
if (request.getParameter("chab")!= null) chab = request.getParameter("chab");

String hora="";
CommonDataObject cdo = new CommonDataObject();
if(!id.equals("0")){
	sql=" SELECT a.CODIGO, TO_CHAR(a.HORA_CITA,'HH:MI AM') as HORA_CITA, TO_CHAR(a.FECHA_CITA,'dd/mm/yyyy') AS FECHA_CITA, a.ESTADO_CITA, a.MOTIVO_CITA, a.OBSERVACION, "+
	    " a.NOMBRE_PACIENTE, a.TELEFONO, a.HABITACION, a.PASAPORTE, a.PROVINCIA, a.SIGLA, a.TOMO, a.ASIENTO, a.D_CEDULA, a.CUARTO, a.COD_MEDICO, a.COD_PROCEDIMIENTO, a.FORMA_RESERVA, "+
		" (SELECT (m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO||' '||m.APELLIDO_DE_CASADA||' '||m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE) AS nom_medico FROM TBL_ADM_MEDICO m WHERE m.CODIGO=a.COD_MEDICO) AS NOMBRE_MEDICO, "+
		" (SELECT NVL(CP.OBSERVACION,CP.DESCRIPCION) AS CP_DESCRIPCION FROM TBL_CDS_PROCEDIMIENTO CP WHERE CP.CODIGO=a.COD_PROCEDIMIENTO) AS NOMBRE_PROCEDIMIENTO, "+
		" (SELECT e.NOMBRE FROM TBL_ADM_EMPRESA e WHERE e.CODIGO=a.EMPRESA) AS NOMBRE_EMPRESA "+
		" FROM TBL_CDC_CITA a WHERE a.CODIGO="+id;
	
	cdo = SQLMgr.getData(sql);
	currDate=cdo.getColValue("FECHA_CITA");
	hora=cdo.getColValue("HORA_CITA");
}

String Title = "";
if(act.equals("0")) Title="CITAS - NUEVA CITA";
if(act.equals("1")) Title="CITAS - EDITAR CITA";
if(act.equals("2")) Title="CITAS - TRASLADAR CITA";
if(act.equals("3")) Title="CITAS - CANCELAR CITA";

String display = "inline";
if(from.equals("qui")) display="none";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function displayWin(obj) {
	var img = document.getElementById(obj + 'img');
	var msg = document.getElementById(obj);
	var estado = img.src.match('Plus')
	if(estado=='Plus'){
		msg.style.display = 'block';
		img.src = '../images/off_Minus.gif'
	} else {
		msg.style.display = 'none';
		img.src = '../images/on_Plus.gif'
	}
}
function openCitaParam(act){
	if(act!=''){abrir_ventana1('../cita/cita_add_param.jsp?act='+act+'&chab=<%=chab%>');}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true"><jsp:param name="title" value="<%=Title%>"></jsp:param></jsp:include>

<% if(from.equals("qui")){%> 
<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
	<tr>
		<td width="2%" >&nbsp;</td>
		<td width="96%">&nbsp;<cellbytelabel>Detalles de Cita</cellbytelabel>&nbsp;<img src="../images/on_Plus.gif" id="PatientDetimg" border="0" alt="Mostra/Ocultar Detalles de la Cita"  onClick="javascript:displayWin('PatientDet')" style="cursor:hand;"></td>  
		<td width="2%" >&nbsp;</td>
	</tr>
</table>	
<%}%>

<div id="PatientDet" style="display:<%=display%>;">
<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
<%fb = new FormBean("frmPatient",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("act",act)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("chab",chab)%>
<%
String hr="", mn="", am="";
if(!hora.equals("")){
	hr=hora.substring(0,2);
	mn=hora.substring(3,5);
	am=hora.substring(6,8);
}
boolean locked=true;
if(act.equals("0")){
	locked=false;
}
%>		
<tr>
	<td width="2%">&nbsp;</td>
	<td valign="top" width="96%">
	<fieldset>
	<legend><cellbytelabel>Fecha</cellbytelabel>&nbsp;<%
	if(act.equals("0")){
	%>	
	<jsp:include page="../common/calendar.jsp" flush="true"><jsp:param name="noOfDateTBox" value="1"/><jsp:param name="nameOfTBox1" value="fecha"/><jsp:param name="valueOfTBox1" value="<%=currDate%>"/></jsp:include>
	<%
    }else{
	%>
	<%=fb.textBox("fecha", currDate, false, false, true, 20)%>    
    <%
	}
	%>&nbsp;&nbsp;&nbsp;<cellbytelabel>Hora</cellbytelabel>&nbsp;<%=fb.select("hora","01,02,03,04,05,06,07,08,09,10,11,12",hr,false,locked,0,"","width:40px;",null)%>:<%=fb.select("minuto","00,30",mn,false,locked,0,"","width:40px;",null)%>&nbsp;<%=fb.select("ampm","AM,PM",am,false,locked,0,"","width:50px;",null)%>
	</legend>
		<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
		<tr>
			<td colspan="4" class="BlueContent">&nbsp;</td>
		</tr>	
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>Nombre del Paciente</cellbytelabel></td>
			<td class="BlueContent"><%=fb.textBox("nombre", cdo.getColValue("NOMBRE_PACIENTE"), true, false, false, 40)%></td>
			<td class="BlueContent">&nbsp;<cellbytelabel>Forma</cellbytelabel></td>
			<td class="BlueContent"><%=fb.select("forma","TELEFONICA,PERSONALMENTE, E-MAIL,OTRA",cdo.getColValue("FORMA_RESERVA"),false,false,0,"","width:115px;",null)%>&nbsp;<%=fb.textBox("contacto", "", false, false, false, 20)%></td>
		</tr>	
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>C&eacute;dula</cellbytelabel></td>
			<td class="BlueContent"><%=fb.textBox("cedula", "", false, false, false, 40)%></td>
			<td class="BlueContent">&nbsp;<cellbytelabel>Pasaporte</cellbytelabel></td>
			<td class="BlueContent"><%=fb.textBox("pasaporte", cdo.getColValue("PASAPORTE"), false, false, false, 40)%></td>
		</tr>			
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
			<td class="BlueContent"><%=fb.textBox("telefono", cdo.getColValue("TELEFONO"), false, false, false, 40)%></td>
			<td class="BlueContent">&nbsp;<cellbytelabel>Sala/Cuarto(Ubicaci&oacute;n)</cellbytelabel></td>
			<td class="BlueContent"><%=fb.textBox("cuarto", cdo.getColValue("CUARTO"), true, false, false, 40)%></td>
		</tr>	
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>Tipo de Paciente</cellbytelabel></td>
			<td class="BlueContent"><%=fb.select("tipopaciente","PACIENTE EXTERNO,PACIENTE INTERNO","",false,false,0,"","width:266px;",null)%></td>
			<td class="BlueContent">&nbsp;<cellbytelabel>Compa&ntilde;&iacute;a de Seguro</cellbytelabel></td>
			<td class="BlueContent"><%=fb.hidden("ciaseguro", "")%><%=fb.textBox("dciaseguro", "", false, true, false, 37)%><%=fb.button("btnciaseguro", "...", false, false, "", "", "onClick=\"javascript:openCitaParam('0')\"")%></td>
		</tr>	
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>M&eacute;dico</cellbytelabel></td>
			<td class="BlueContent"><%=fb.hidden("medico", cdo.getColValue("COD_MEDICO"))%><%=fb.textBox("dmedico", cdo.getColValue("NOMBRE_MEDICO"), false, true, false, 37)%>&nbsp;<%=fb.button("btnmedico", "...", false, false, "", "", "onClick=\"javascript:openCitaParam('1')\"")%></td>
			<td class="BlueContent">&nbsp;<cellbytelabel>Tipo de Cita</cellbytelabel></td>
			<td class="BlueContent"><%=fb.select("tipocita","EFECTIVA,OTRO","",false,false,0,"","width:266px;",null)%></td>
		</tr>	
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>Procedimiento</cellbytelabel></td>
			<td class="BlueContent"><%=fb.hidden("procedure", cdo.getColValue("COD_PROCEDIMIENTO"))%><%=fb.textBox("dprocedure", cdo.getColValue("NOMBRE_PROCEDIMIENTO"), true, true, false, 37)%><%=fb.button("btnprocedure", "...", false, false, "", "", "onClick=\"javascript:openCitaParam('2')\"")%></td>
			<td class="BlueContent">&nbsp;<cellbytelabel>Tiempo Total &nbsp;Aproximado</cellbytelabel></td>
			<td class="BlueContent">Hrs.<%=fb.textBox("hrs", cdo.getColValue("HORA_EST"), true, false, false, 3)%>&nbsp;Min.<%=fb.textBox("min", cdo.getColValue("MIN_EST"), true, false, false, 3)%></td>
		</tr>	
		<tr>
			<td class="BlueContent" >&nbsp;<cellbytelabel>Observaciones</cellbytelabel>&nbsp;</td>
			<td class="BlueContent" colspan="3"><%=fb.textarea("observaciones", cdo.getColValue("OBSERVACION"), true, false, false, 90, 2)%></td>
		</tr>	
		<tr>
			<td width="15%" class="BlueContent">&nbsp;</td>
			<td width="35%" class="BlueContent">&nbsp;</td>
			<td width="15%" class="BlueContent">&nbsp;</td>
			<td width="35%" class="BlueContent">&nbsp;</td>
		</tr>
		<%if(act.equals("2")){%>
		<tr>
			<td colspan="4">
			<fieldset>
			<legend><cellbytelabel>Traslado</cellbytelabel></legend>
			<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
			<tr>
				<td width="50%" class="BlueContent">&nbsp;<cellbytelabel>Fecha</cellbytelabel>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=currDate%>"/></jsp:include></td>
				<td width="50%" class="BlueContent">&nbsp;<cellbytelabel>Hora de la Cita</cellbytelabel>&nbsp;<%=fb.select("thora","01,02,03,04,05,06,07,08,09,10,11,12","",false,false,0,"","width:40px;",null)%>:<%=fb.select("tminuto","00,30","",false,false,0,"","width:40px;",null)%>&nbsp;<%=fb.select("tampm","A.M.,P.M.","",false,false,0,"","width:50px;",null)%></td>
			</tr>	
			</table>	
			</fieldset>
			</td>
		</tr>	
		<%}%>

		<%if(!from.equals("qui")){%>
		<tr>
			<td class="BlueContent" colspan="4" align="right"><%=fb.submit("save","Guardar",true,false)%>&nbsp;<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>	
		<%}%>
		</table>
	</fieldset>
	</td>
	<td width="2%">&nbsp;</td>
</tr>
<%=fb.formEnd()%> 	
</table>
</div>

<%if(from.equals("qui")){%>
	<iframe name="iquirofano" id="iquirofano" frameborder="0" align="center" width="100%" height="450" scrolling="no" src="cita_add_operation.jsp?act=<%=act%>&from=<%=from%>"></iframe>
<%}%>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}else{

//INSERT INTO CDC_CITA (CODIGO, FECHA_REGISTRO, FEC_NACIMIENTO, COD_PACIENTE, FECHA_CITA,HORA_CITA, HORA_LLAMADA, CENTRO_SERVICIO, COD_TIPO, ESTADO_CITA,PERSONA_RESERVA, FORMA_RESERVA, MOTIVO_CITA, ANESTESIA, OBSERVACION,EMP_COMPANIA, EMP_PROVINCIA, EMP_SIGLA, EMP_TOMO, EMP_ASIENTO,HABITACION, COMPANIA_HAB, EMPRESA, FECHA_CREACION, USUARIO_CREACION,FECHA_MODIF, USUARIO_MODIF, HORA_EST, MIN_EST, NOMBRE_PACIENTE,CITA_CIRUGIA, JUBILADO, PATALOGIA, HOSP_AMB, DESTINO_PAT, COMPANIA,COD_MEDICO, COD_ESPECIALIDAD, TIPO_PAMD, COD_PROCEDIMIENTO, CUARTO,TIPO_PACIENTE, TELEFONO,ADMISION)
//VALUES (V_CODIGO, TO_DATE(TO_CHAR(V_SYSFECHA,'DD-MM-YYYY'),'DD-MM-YYYY'),:CITA.FEC_NACIMIENTO, :CITA.COD_PACIENTE, TO_DATE(TO_CHAR(:CG$CTRL.FECHA,'DD-MM-YYYY'),'DD-MM-YYYY'), TO_DATE(TO_CHAR(:CG$CTRL.FECHA,'DD-MM-YYYY')||' '||TO_CHAR(:CITA.HORA_CITA,'HH12:MI AM'),'DD-MM-YYYY HH12:MI AM'), V_SYSFECHA, 885, :CITA.COD_TIPO, 'R', NULL, :CITA.FORMA_RESERVA, NULL, 'N', :CITA.OBSERVACION,NULL, NULL, NULL, NULL, NULL,:CITA.HABITACION, 1, :CITA.EMPRESA, V_SYSFECHA, USER, V_SYSFECHA, USER, :CITA.HORA_EST, :CITA.MIN_EST, :CITA.NOMBRE_PACIENTE,:CITA.CITA_CIRUGIA, NULL, NULL, NULL, NULL, :GLOBAL.CG$COMPANIA,NULL, NULL, NULL, NULL, :CITA.CUARTO, :CITA.TIPO_PACIENTE, :CITA.TELEFONO,:CITA.ADMISION);

//INTO TBL_CDC_PERSONAL_CITA (CODIGO, FECHA_CITA, COD_CITA, FUNCION, MEDICO, OBSERVACION,USUARIO_CREACION, FECHA_CREACION, USUARIO_MODIF, FECHA_MODIF)
//VALUES (V_CODIGO_PROC, TO_DATE(TO_CHAR(V_SYSFECHA,'DD-MM-YYYY'),'DD-MM-YYYY'), V_CODIGO,5, :CITA.MEDICO, NULL, USER, V_SYSFECHA, USER, V_SYSFECHA);

//INSERT INTO TBL_CDC_CITA_PROCEDIMIENTO (CODIGO, COD_CITA, FECHA_CITA, PROCEDIMIENTO, OBSERVACION, TIPO_C,USUARIO_CREACION, FECHA_CREACION, USUARIO_MODIF, FECHA_MODIF)
//VALUES (V_CODIGO_PROC, V_CODIGO, TO_DATE(TO_CHAR(V_SYSFECHA,'DD-MM-YYYY'),'DD-MM-YYYY'),:CITA.PROCEDIMIENTO, NULL, NULL, USER, V_SYSFECHA, USER, V_SYSFECHA);

%>

<%
}
%>