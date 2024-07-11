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
String motivo=request.getParameter("motivo");
String desde=request.getParameter("desde");
String hasta=request.getParameter("hasta");
String mode=request.getParameter("mode");
boolean viewMode=false;

if (request.getMethod().equalsIgnoreCase("GET"))
{
 	if (grupo == null) throw new Exception("El Código de Grupo no es válido. Por favor intente nuevamente!");
	if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
	if (mode == null) mode="edit";

	if (mode.equals("view")) viewMode = true;
	if (desde == null) desde=fech;

    sql = "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.ta_hsal,'hh12:mi:ss am') as ta_hsal, to_char(a.ta_hent,'hh12:mi:ss am') as ta_hent, a.tiempo_horas, a.tiempo_minutos, a.mfalta, b.descripcion as mfaltaDesc, a.estado, a.causa FROM tbl_pla_inasistencia_emp a, tbl_pla_motivo_falta b WHERE  a.compania = "+(String) session.getAttribute("_companyId")+" and a.mfalta=b.codigo and a.mfalta="+motivo+" and trunc(a.fecha) = to_date("+fech+",'dd/mm/yyyy') and a.emp_id = "+empId;
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
   document.formAusencia.submit();
}
function addMotivo()
{
    abrir_ventana2("../common/search_motivo_falta.jsp?fp=ausencias_empleado");
}


function chkAlert(){
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
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("desde",desde)%>
			<%=fb.hidden("hasta",hasta)%>
			<%=fb.hidden("accion",aus.getColValue("estado"))%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td>Motivo de Auencia</td>
				<td><%=fb.intBox("mfalta",aus.getColValue("mfalta"),false,false,true,5,3)%><%=fb.textBox("mfaltaDesc",aus.getColValue("mfaltaDesc"),false,false,true,53,50)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addMotivo()\"")%></td>
				<td>Acci&oacute;n</td>
				<td><%=fb.select("estado","DS=DESCONTAR,ND=NO DESCONTAR,EL=ELIMINADA",aus.getColValue("estado"), false, false,0,"text10",null,"onChange=\"javascript:chkAlert();\"")%></td>
				
				
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
				<td>Observaci&oacute;n</td>
				<td><%=fb.textarea("causa",aus.getColValue("causa"),false,false,viewMode,49,3)%></td>
				<td>Devoluci&oacute;n</td>
				<td><%=fb.intBox("devolucion","",false,false,true,10,1)%></td>
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
   desde = request.getParameter("desde");
   hasta = request.getParameter("hasta");

   CommonDataObject cdo = new CommonDataObject();

   cdo.setTableName("tbl_pla_inasistencia_emp");
   cdo.addColValue("fecha",fecha);
   cdo.addColValue("hora_salida",request.getParameter("ta_hsal"));
   cdo.addColValue("hora_entrada",request.getParameter("ta_hent"));
   cdo.addColValue("tiempo_horas",request.getParameter("tiempo_horas"));
   cdo.addColValue("tiempo_minutos",request.getParameter("tiempo_minutos"));
   cdo.addColValue("mfalta",request.getParameter("mfalta"));
   cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"));
   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

   if(!request.getParameter("mfalta").equalsIgnoreCase("5"))   cdo.addColValue("estado","EL");
   else cdo.addColValue("estado",request.getParameter("estado"));

   cdo.addColValue("causa",request.getParameter("causa"));
   cdo.setWhereClause("ue_codigo="+grupo+" and emp_id="+empId+" and fecha=to_date('"+fecha+"','dd/mm/yyyy') and compania="+(String) session.getAttribute("_companyId"));
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
    window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_ausencia_list.jsp?grupo=<%=grupo%>&desde=<%=desde%>&hasta=<%=hasta%>&empId=<%=empId%>';
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