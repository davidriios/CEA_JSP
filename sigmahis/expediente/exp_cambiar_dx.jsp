<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codPac = request.getParameter("codPac");
String fechaNacimiento = request.getParameter("fechaNacimiento");
String desc = request.getParameter("desc");

String fp = request.getParameter("fp");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (fp == null) fp = "EXP";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
    //if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	sql = "SELECT a.cod_paciente AS cod_paciente, a.secuencia AS secuencia, to_char(a.fec_nacimiento,'dd/mm/yyyy') AS fec_nacimiento, a.pac_id AS pac_id, a.hospitalizar AS hospitalizar, a.transf AS transf, to_char(a.hora_transf,'hh12:mi:ss am') AS hora_transf, a.cod_diag_sal AS cod_diag_sal, to_char(a.hora_salida,'hh12:mi:ss am') AS hora_salida, a.cond AS cond, a.hora_incap AS hora_incap, to_char(a.horai_incap,'hh12:mi:ss am') AS horai_incap, to_char(a.horaf_incap,'hh12:mi:ss am') AS horaf_incap, a.dia_incap AS dia_incap, to_char(a.diai_incap,'dd/mm/yyyy') AS diai_incap, to_char(a.diaf_incap,'dd/mm/yyyy') AS diaf_incap, a.ref_cons_ext AS ref_cons_ext, a.instruccion_med AS instruccion_med, a.cod_medico_turno AS cod_medico_turno, a.cod_especialidad_ce AS cod_especialidad_ce, a.especialista_p AS especialista_p, a.estado AS estado, a.observacion AS observacion, (SELECT coalesce(observacion,nombre) FROM tbl_cds_diagnostico WHERE codigo=a.cod_diag_sal) as nombre_diagnostico, (SELECT primer_nombre||decode(segundo_nombre,null,' ','  '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ','  '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.ref_cons_ext) as medico_ref, (SELECT primer_nombre||decode(segundo_nombre,null,' ',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico_turno) as medico_turn, (SELECT descripcion FROM tbl_adm_especialidad_medica WHERE codigo=a.cod_especialidad_ce) AS especialidad_nom FROM tbl_sal_adm_salida_datos a WHERE pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);
	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();

		cdo.addColValue("hospitalizar","N");
		cdo.addColValue("cond","I");
		cdo.addColValue("hora_transf","");
		cdo.addColValue("horaf_incap","");
		cdo.addColValue("diai_incap","");
		cdo.addColValue("horai_incap","");
		cdo.addColValue("diaf_incap","");
		cdo.addColValue("hora_salida","");
	}
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Cambiar Diagnostico de Salida - '+document.title;
function doAction(){}
function addDxSalida(){abrir_ventana1('../common/search_diagnostico.jsp?fp=addDxSalida&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function addDrConsultaExt(){abrir_ventana1('../common/search_medico.jsp?fp=medico_id');}
function addEntregaDr(){abrir_ventana1('../common/search_medico.jsp?fp=addEntregaDr');}
function printSalida(){}
function addDiag(){var diagnostico = eval('document.form001.dx_id').value;var diag_ant = eval('document.form001.diagnostico').value;var observ = eval('document.form001.justificacion').value;var fechaNacimiento = eval('document.form001.fechaNacimiento').value;var msg = '';if(diagnostico == "") msg ='Seleccione Diagnòstico ';if(observ.length < 5)	msg +=' Debe justificar esta acción!...  Sea lo más explicito posible';if(msg == ""){if(confirm('¿Está seguro que desea Cambiar el diagnòstico de salida de estè Paciente ?')){if(executeDB('<%=request.getContextPath()%>','call sp_insertar_diagnostico_sal(\''+fechaNacimiento+'\',<%=codPac%>,<%=pacId%>,<%=noAdmision%>,\''+diagnostico+'\',\''+diag_ant+'\',\''+observ+'\',\'<%=session.getAttribute("_userName")%>\')','')){alert('Diagnóstico Modificado!');window.close();}else alert('Error al Actualizar los Datos de Salida');}else alert('Actualizacion de Diagnòstico Cancelado !');}else alert(' '+msg+'!');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Cambiar Diagnostico de Salida"></jsp:param>
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
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
<%fb = new FormBean("form001",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fechaNacimiento",fechaNacimiento)%>
<%=fb.hidden("diagnostico",cdo.getColValue("cod_diag_sal"))%>

		
		
		<tr class="Textrow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="Textrow01">
			<td width="15%"></td>
			<td width="35%">&nbsp;</td>
			<td width="15%">&nbsp;</td>
			<td width="35%">&nbsp;</td>
		</tr>
		<tr class="Textrow01">
			<td><cellbytelabel id="1">Dx. de Salida</cellbytelabel></td>
			<td colspan="3">
				<%=fb.textBox("dx_id",cdo.getColValue("cod_diag_sal"),false,false,true,2)%>
				<%=fb.textBox("dx_descripcion",cdo.getColValue("nombre_diagnostico"),false,false,true,40)%>
				<%=fb.button("btn_dx_salida","...",true,viewMode,null,null,"onClick=\"javascript:addDxSalida()\"")%>
			</td>
		</tr>
		

		<tr class="Textrow01">
			<td><cellbytelabel id="2">Justificaci&oacute;n Del Cambio</cellbytelabel></td>
			<td colspan="3"><%=fb.textarea("justificacion","", false, false, viewMode, 0, 4, 2000,"", "width:100%", "")%></td>
		</tr>
				
		<tr class="Textrow02">
			<td colspan="4" align="right">
				<!--Opciones de Guardar:
				<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
				<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar -->
				<%=fb.button("btn_dx_salida","Cambiar Diagnòstico",true,viewMode,null,null,"onClick=\"javascript:addDiag()\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
<%
}//GET
%>
