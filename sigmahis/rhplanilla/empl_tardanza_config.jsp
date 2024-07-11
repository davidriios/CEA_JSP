<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="aus" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String grupo=request.getParameter("grupo");
String empId=request.getParameter("empId");
String fech=request.getParameter("fech");
String motivoOld=request.getParameter("motivo");
String anio=request.getParameter("anio");
String periodo=request.getParameter("periodo");
String desde=request.getParameter("desde");
String hasta=request.getParameter("hasta");
String motivo =request.getParameter("motivo");
String mode=request.getParameter("mode");
boolean viewMode=false;

if (request.getMethod().equalsIgnoreCase("GET"))
{
 	if (grupo == null) throw new Exception("El Código de Grupo no es válido. Por favor intente nuevamente!");
	if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
		if (mode == null) mode="edit";

	if (mode.equals("view")) viewMode = true;

    sql = "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.ta_hsal,'hh24:mi:ss') as ta_hsal, to_char(a.ta_hent,'hh24:mi:ss') as ta_hent, a.tiempo_horas, a.tiempo_minutos, a.motivo mfalta, b.descripcion as mfaltaDesc, a.accion estado, a.observaciones as causa, a.anio, a.periodo FROM tbl_pla_at_det_empfecha a, tbl_pla_motivo_falta b WHERE  a.compania = "+(String) session.getAttribute("_companyId")+" and a.motivo=b.codigo and a.emp_id = "+empId+" and a.motivo="+motivoOld+" and to_char(a.fecha,'dd/mm/yyyy') ="+fech;
	aus = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
function doSubmit()
{
  var motivo = eval('document.formAusencia.mfalta').value;
  var causa = eval('document.formAusencia.causa').value;
	if(motivo == "55" && (causa == null ||causa =="")) {
	alert('Es requerido escribir la justificación en Observación...!!');
	
	} else  document.formAusencia.submit();
}
function addMotivo()
{
    abrir_ventana2("../common/search_motivo_falta.jsp?fp=tardanzas");
}

function chkAlert()
{
	var empId = document.formAusencia.empId.value;
	var grupo = document.formAusencia.grupo.value;
	var motivo = document.formAusencia.mfalta.value;
	var fech = document.formAusencia.fecha.value;
	var mode = document.formAusencia.mode.value;
	alert("Por favor Ud. no esta autorizado para cambiar el estado de la Acción ...!");
	document.formAusencia.estado.value = eval('document.formAusencia.accion').value;
	
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSO HUMANOS - PROCESO - AUSENCIA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	    <td class="TableBorder">
		    <table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		    <% fb = new FormBean("formAusencia",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("empId",empId)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("desde",desde)%>
			<%=fb.hidden("hasta",hasta)%>
			<%=fb.hidden("anio",aus.getColValue("anio"))%>
			<%=fb.hidden("motivoOld",motivo)%>
			<%=fb.hidden("motivo",aus.getColValue("motivo"))%>
			<%=fb.hidden("periodo",aus.getColValue("periodo"))%>
			<%=fb.hidden("accion",aus.getColValue("estado"))%>
			<%=fb.hidden("mode",mode)%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td>Motivo de Ausencia</td>
				<td><%=fb.intBox("mfalta",aus.getColValue("mfalta"),false,false,true,5,3)%><%=fb.textBox("mfaltaDesc",aus.getColValue("mfaltaDesc"),false,false,true,53,50)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addMotivo()\"")%></td>
				<td>Acci&oacute;n</td>
				
				<td><%=fb.select("estado","DS=DESCONTAR,ND=NO DESCONTAR",aus.getColValue("estado"), false, false,0,"text10",null,"onChange=\"javascript:chkAlert();\"")%></td>
		    <tr class="TextRow02">
		        <td width="12%">Fecha</td>
				<td width="48%"><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha"/>
					<jsp:param name="jsEvent" value="sumHoras()"/>
					<jsp:param name="valueOfTBox1" value="<%=(aus.getColValue("fecha")==null)?"":aus.getColValue("fecha")%>" />
					</jsp:include>
				</td>
				<td width="12%">Hras/Min</td>
				<td width="28%"><%=fb.intBox("tiempo_horas",aus.getColValue("tiempo_horas"),false,false,true,5,2)%>&nbsp;<%=fb.intBox("tiempo_minutos",aus.getColValue("tiempo_minutos"),false,false,true,5,2)%></td>
 		    </tr>
			<tr class="TextRow01">
				<td>Desde</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="ta_hent"/>
					<jsp:param name="format" value="hh24:mi:ss" />
					<jsp:param name="jsEvent" value="sumHoras()" />
					<jsp:param name="valueOfTBox1" value="<%=(aus.getColValue("ta_hent")==null)?"":aus.getColValue("ta_hent")%>" />
					</jsp:include>
				</td>
				<td>Hasta</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="ta_hsal"/>
					<jsp:param name="format" value="hh24:mi:ss" />
					<jsp:param name="jsEvent" value="sumHoras()" />
					<jsp:param name="valueOfTBox1" value="<%=(aus.getColValue("ta_hsal")==null)?"":aus.getColValue("ta_hsal")%>" />
					</jsp:include>
				</td>
		    </tr>
			<tr class="TextRow01" >
				<td>Observaci&oacute;n :</td>
				<td><%=fb.textarea("causa",aus.getColValue("causa"),false,false,false,49,3)%></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			<%
				 //Si error--, quita el error. Si error++, agrega el error.
				// js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";

				//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");
			%>
			<tr class="TextRow02">
				<td align="right" colspan="4"><%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>
			<tr>
			    <td colspan="4">&nbsp;</td>
			</tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
        </table>
	  </td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
   String fecha= "";

   grupo = request.getParameter("grupo");
   empId = request.getParameter("empId");
   fecha = request.getParameter("fecha");
   motivo = request.getParameter("mfalta");
   motivoOld = request.getParameter("motivoOld");
   anio = request.getParameter("anio");
   desde = request.getParameter("desde");
   hasta = request.getParameter("hasta");

   CommonDataObject cdo = new CommonDataObject();

   cdo.setTableName("tbl_pla_at_det_empfecha");
/*   cdo.addColValue("ue_codigo",grupo);
   cdo.addColValue("provincia",request.getParameter("provincia"+j));
   cdo.addColValue("sigla",request.getParameter("sigla"+j));
   cdo.addColValue("tomo",request.getParameter("tomo"+j));
   cdo.addColValue("asiento",request.getParameter("asiento"+j));
   cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
   cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));
   cdo.addColValue("emp_id",request.getParameter("empId"+j));*/
   cdo.addColValue("fecha",fecha);
	  cdo.addColValue("anio",request.getParameter("anio"));
   cdo.addColValue("ta_hsal",request.getParameter("ta_hsal"));
   cdo.addColValue("ta_hent",request.getParameter("ta_hent"));
   cdo.addColValue("tiempo_horas",request.getParameter("tiempo_horas"));
   cdo.addColValue("tiempo_minutos",request.getParameter("tiempo_minutos"));
   cdo.addColValue("motivo",request.getParameter("mfalta"));
   cdo.addColValue("accion",request.getParameter("estado"));
   cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"));

   cdo.addColValue("observaciones",request.getParameter("causa"));
   cdo.setWhereClause("ue_codigo="+grupo+" and motivo="+motivoOld+" and periodo="+periodo+" and anio="+anio+" and emp_id="+empId+" and fecha='"+fecha+"' and compania="+(String) session.getAttribute("_companyId"));
   SQLMgr.update(cdo);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
    window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_tardanza_list.jsp?grupo=<%=grupo%>&desde=<%=desde%>&hasta=<%=hasta%>&empId=<%=empId%>';
	window.close();
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