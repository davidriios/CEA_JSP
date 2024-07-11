<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vEmp" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
sct0070: Utilizado x Jefe para aprobación
sct0070s: Utilizado x Secretaria para registro
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String codigo = request.getParameter("codigo");

if (fg == null) fg = "";
if (grupo == null) grupo = "";
if (area == null) area = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (codigo == null) codigo = "";
if (grupo.trim().equals("")) throw new Exception("El Grupo no es válido. Por favor intente nuevamente!");

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")) {
	iEmp.clear();
	vEmp.clear();
	if (mode.equalsIgnoreCase("add")) {
		sbSql.append("select codigo as grupo, descripcion as grupo_desc, to_char(sysdate,'dd/mm/yyyy') as fecha_solicitud, to_char(sysdate,'fmmm') as mes, to_char(sysdate,'yyyy') as anio, 'N' as aprobado from tbl_pla_ct_grupo where codigo = ");
		sbSql.append(grupo);
		sbSql.append(" and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdo = SQLMgr.getData(sbSql.toString());
		anio = cdo.getColValue("anio");
		mes = cdo.getColValue("mes");
	} else {
		if (anio.trim().equals("") || mes.trim().equals("") || codigo.trim().equals("")) throw new Exception("El Cambio de Turno no es válido. Por favor intente nuevamente!");

		sbSql.append("select to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.mes, a.anio, a.grupo, decode(a.emp_id,null,' ',''||a.emp_id) as emp_id, decode(a.provincia,null,' ',''||a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',''||a.tomo) as tomo, decode(a.asiento,null,' ',''||a.asiento) as asiento, nvl(a.num_empleado,' ') as num_empleado, a.motivo_cambio, nvl(a.observaciones,' ') as observaciones, (select descripcion from tbl_pla_ct_grupo where compania = a.compania and codigo = a.grupo) as grupo_desc, nvl((select primer_nombre||' '||primer_apellido from tbl_pla_empleado where emp_id = a.emp_id),' ') as nombre_empleado, nvl(a.aprobado,'N') as aprobado from tbl_pla_ct_enc_cambio_programa a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.anio = ");
		sbSql.append(anio);
		sbSql.append(" and a.mes = ");
		sbSql.append(mes);
		sbSql.append(" and a.grupo = ");
		sbSql.append(grupo);
		sbSql.append(" and a.codigo = ");
		sbSql.append(codigo);
		//sbSql.append(" and a.motivo_cambio = ");
		//sbSql.append(motivoCambio);
		cdo = SQLMgr.getData(sbSql.toString());
		if (!cdo.getColValue("aprobado").equalsIgnoreCase("N")) { mode = "view"; viewMode = true; }

		sbSql = new StringBuffer();
		sbSql.append("select a.secuencia, a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, to_char(a.fecha_tasignado,'dd/mm/yyyy') as fecha_tasignado, a.turno_asignado, a.turno_nuevo, to_char(a.fecha_tnuevo,'dd/mm/yyyy') as fecha_tnuevo, a.anio_ca, a.mes_ca, a.ta_programado, a.emp_id, (select primer_nombre||' '||primer_apellido from tbl_pla_empleado where emp_id = a.emp_id) as nombre_empleado, decode(a.turno_asignado,'A','Ausencia','LC','Libre Compensatorio','LS','Libre Semana','N','Nacional','PC','Permiso Con Sueldo','PS','Permiso Sin Sueldo','HD','Horas de Descanso','I','Incapacidad','LG','Licencia por Gravidez','V','Vacaciones','RP','Riesgo Profesional',nvl((select descripcion from tbl_pla_ct_turno where compania = a.compania and to_char(codigo) = a.turno_asignado),' ')) as turno_asignado_desc, decode(a.turno_nuevo,'A','Ausencia','LC','Libre Compensatorio','LS','Libre Semana','N','Nacional','PC','Permiso Con Sueldo','PS','Permiso Sin Sueldo','HD','Horas de Descanso','I','Incapacidad','LG','Licencia por Gravidez','V','Vacaciones','RP','Riesgo Profesional',nvl((select descripcion from tbl_pla_ct_turno where compania = a.compania and to_char(codigo) = a.turno_nuevo),' ')) as turno_nuevo_desc, decode(a.motivo_cambio,5,'A','R') as adic from tbl_pla_ct_det_cambio_programa a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.anio = ");
		sbSql.append(anio);
		sbSql.append(" and a.mes = ");
		sbSql.append(mes);
		sbSql.append(" and a.grupo = ");
		sbSql.append(grupo);
		sbSql.append(" and a.codigo = ");
		sbSql.append(codigo);
		//sbSql.append(" and a.motivo_cambio = ");
		//sbSql.append(motivoCambio);
		al = SQLMgr.getDataList(sbSql.toString());
		for (int i=0; i<al.size(); i++) {
			CommonDataObject det = (CommonDataObject) al.get(i);
			det.setAction("U");
			det.setKey(i + 1);
			iEmp.put(det.getKey(),det);
			vEmp.addElement(det.getColValue("emp_id"));
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Cambio de Turno - '+document.title;
function doSubmit(baction){if(form0Validation())window.frames['itemFrame'].doSubmit(baction);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(window.frames['itemFrame'],xHeight);}
function showEmpleadoList(){abrir_ventana('../common/select_ctempleado.jsp?fp=cambio_turno&grupo=<%=grupo%>&area=<%=area%>&anio=<%=anio%>&mes=<%=mes%>&ct=<%=codigo%>');}

function showList(){var empId=document.form0.emp_id.value;if(empId.trim()=='')alert('No hay seleccionado Empleado....Verifique...'); else abrir_ventana('../rhplanilla/empl_cambio_turno_list.jsp?empId='+empId+'&fp=cambio_turno&grupo=<%=grupo%>');}
function imprimir(){var empId=document.form0.emp_id.value;var fecha=document.form0.fecha_solicitud.value;abrir_ventana1('../rhplanilla/print_list_cambio_turno.jsp?empId='+empId+'&grupo=<%=grupo%>&anio=<%=anio%>&mes=<%=mes%>&codigo=<%=codigo%>&fecha='+fecha);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("codigo",codigo)%>
<%fb.appendJsValidation("if(document.form0.motivo_cambio.value==''){alert('Por favor seleccione el Motivo de Cambio!');error++;}");%>
		<tr class="TextPanel">
			<td colspan="4">Grupo: <%=cdo.getColValue("grupo")%> - <%=cdo.getColValue("grupo_desc")%></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%">Fecha Registro</td>
			<td width="45%">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha_solicitud"/>
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_solicitud")%>"/>
				<jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>"/>
				</jsp:include>
			</td>
			<td width="15%" align="right">Mes/A&ntilde;o</td>
			<td width="25%">
				<% if (mode.equalsIgnoreCase("add")) { %><%=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,false,0,"",null,"")%><% } else { %><%=fb.hidden("mes",cdo.getColValue("mes"))%><%=fb.select("mes_dsp","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,true,0,"",null,"")%><% } %>
				<%=fb.intBox("anio",cdo.getColValue("anio"),true,false,(!mode.equalsIgnoreCase("add")),5,4,"",null,"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>Solicitado por
			<td colspan="3">
				<%=fb.hidden("emp_id",cdo.getColValue("emp_id"))%>
				<%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,true,3,2,"",null,"")%>
				<%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,2,"",null,"")%>
				<%=fb.intBox("tomo",cdo.getColValue("tomo"),false,false,true,4,4,"",null,"")%>
				<%=fb.intBox("asiento",cdo.getColValue("asiento"),false,false,true,6,6,"",null,"")%>
				<%=fb.intBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,3,2,"",null,"")%>
				<%=fb.textBox("nombre",cdo.getColValue("nombre_empleado"),false,false,true,65,100,"",null,"")%>
				<%=fb.button("btnEmpleado","...",true,viewMode,null,"","onClick=\"javascript:showEmpleadoList()\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>Motivo</td>
			<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_pla_ct_motivo_cambio where compania = "+session.getAttribute("_companyId"),"motivo_cambio",cdo.getColValue("motivo_cambio"),false,viewMode,0,null,null,null,null,"S")%></td>
			<td><% if (mode.equalsIgnoreCase("add") || mode.equalsIgnoreCase("edit")) { %><%=fb.hidden("aprobado",cdo.getColValue("aprobado"))%><% } else { %>Aprobado?<%=fb.select("aprobado","A=ANULADO,N=PENDIENTE,S=APROBADO",cdo.getColValue("aprobado"),false,(viewMode || !cdo.getColValue("aprobado").equalsIgnoreCase("N")),0,"",null,"")%><% } %></td>
		</tr>
		<tr class="TextRow01" align="left">
			<td>Observaci&oacute;n:&nbsp;</td>
			<td colspan="3"><%=fb.textarea("observaciones",cdo.getColValue("observaciones"),false,false,viewMode,77,2)%></td>
		</tr>
		<tr>
			<td colspan="4"><iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0"src="../rhplanilla/reg_cambio_turno_det.jsp?mode=<%=mode%>&grupo=<%=grupo%>&area=<%=area%>&anio=<%=anio%>&mes=<%=mes%>&codigo=<%=codigo%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<% if (!mode.equalsIgnoreCase("add")) { %><a href="javascript:imprimir()"><img src="../images/printer.gif" border="0" width="20" height="20"></a><% } %>
				Opciones de Guardar:
				<% if (!mode.equalsIgnoreCase("approve")) { %><%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro<% } %>
				<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
				<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
				<%=fb.button("cancel","Cancelar",false,false,"","","onClick=\"javascript:closeWin()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (errCode.equals("1")) { %>
alert('<%=errMsg%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_cambio_turno.jsp")) { %>
window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_cambio_turno.jsp")%>';
<% } else { %>
window.opener.location='<%=request.getContextPath()%>/rhplanilla/list_cambio_turno.jsp?fg=<%=fg%>&grupo=<%=grupo%>&area=<%=area%>';
<% } %>
<% if (saveOption.equalsIgnoreCase("N")) { %>
setTimeout('newMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
setTimeout('openMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
 window.close();
<% } %>
<% } else throw new Exception(errMsg); %>
}
function newMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&grupo=<%=grupo%>&area=<%=area%>';}
function openMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=<%=(mode.equalsIgnoreCase("add"))?"edit":mode%>&grupo=<%=grupo%>&area=<%=area%>&mes=<%=mes%>&anio=<%=anio%>&codigo=<%=codigo%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>