<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="inc" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sql="";
String grupo=request.getParameter("grupo");
String empId=request.getParameter("empId");
String cod = request.getParameter("cod");
String fech = request.getParameter("fecha");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String sw = "S";

boolean viewMode = false;
if (mode == null) mode = "add";
if (fp == null) fp = "ver";
if(mode.trim().equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
 	if (grupo == null) throw new Exception("El Código de Grupo no es válido. Por favor intente nuevamente!");
	if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");

    sql = "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, a.codigo, to_char(a.hora_salida,'hh12:mi am') as hora_salida, to_char(a.hora_entrada,'hh12:mi am') as hora_entrada, a.tiempo_horas tiempo, a.tiempo_minutos, a.mfalta, b.descripcion as mfaltaDesc, a.codigo, a.estado, a.lugar_nombre, a.lugar, a.motivo, a.forma_des, a.aprobado, a.no_referencia FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.mfalta=b.codigo and a.codigo ="+cod+" and a.emp_id="+empId+" and trunc(fecha) = to_date('"+fech+"','dd/mm/yyyy') and a.compania="+(String) session.getAttribute("_companyId")+" and ue_codigo="+grupo;
	inc = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
<%@ include file="../common/tab.jsp" %>

<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
function doSubmit()
{
  document.form1.submit();
}
function addMotivo()
{
    abrir_ventana2("../common/search_motivo_falta.jsp?fp=incapacidades_empleado");
}
function doAction(){
}

function validateEstado() {
	  var estado = eval('document.form1.estado').value;
	  var motivo = eval('document.form1.mfalta').value;

      //alert('ESTADO='+estado+' ;   MOTIVO='+motivo);

	  if (estado == '' || estado == null)
	  {

		    if (motivo =='39')	document.form1.estado.value="DS";
		    else  alert ('Sr. Usuario: Favor indique la ACCION  a realizar (descontar / no descontar');

	  }  else
	  {
			if (estado=='ND' && motivo=='39') {
				alert('Los RIESGOS PROFESIONALES solo permiten la ACCION DESCONTAR!!!');
				document.form1.estado.value="DS";
			}
	  }
	  return false;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECURSOS HUMANOS - PROCESO - INCAPACIDAD"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	    <td class="TableBorder">
		    <table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("empId",empId)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("desde",desde)%>
			<%=fb.hidden("hasta",hasta)%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("baction","")%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>

			<tr class="TextRow01">
				<td width="12%">Motivo</td>
				<td width="48%"><%=fb.intBox("mfalta",inc.getColValue("mfalta"),false,viewMode,true,5,3)%><%=fb.textBox("mfaltaDesc",inc.getColValue("mfaltaDesc"),false,false,true,53,50)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addMotivo()\"")%></td>
				<td width="15%">No.</td>
				<td width="25%"><%=fb.intBox("codigo",inc.getColValue("codigo"),false,viewMode,true,16,1)%></td>
			</tr>
			<tr class="TextRow02">
				<td>Fecha</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha"/>
					<jsp:param name="jsEvent" value="sumHoras()"/>
					<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("fecha")==null)?"":inc.getColValue("fecha")%>" />
					</jsp:include>
				</td>
				<td>Hras/Min.</td>
				<td><%=fb.intBox("tiempoHoras",inc.getColValue("tiempo"),false,false,true,5,2)%>&nbsp;<%=fb.intBox("tiempoMinutos",inc.getColValue("tiempo_minutos"),false,false,true,5,2)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Desde</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="horaSalida"/>
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="jsEvent" value="sumHoras()" />
					<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("hora_salida")==null)?"":inc.getColValue("hora_salida")%>" />
					</jsp:include>
				</td>
				<td>Hasta</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="horaEntrada"/>
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="jsEvent" value="sumHoras()" />
					<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("hora_entrada")==null)?"":inc.getColValue("hora_entrada")%>" />
					</jsp:include>
				</td>
			</tr>
			<tr class="TextRow02">
				<td>Nombre Lugar</td>
				<td><%=fb.textBox("lugarNombre",inc.getColValue("lugar_nombre"),false,false,false,65,60)%></td>
				<td>Tipo de Lugar</td>
				<td><%=fb.select("lugar","1=Clínica San Fernando,2=Caja de Seguro Social,3=Clínica Externa,4=Centro Médico,5=Otro",inc.getColValue("lugar"))%></td>
			</tr>
			<tr class="TextRow02">
				<td>Observaci&oacute;n</td>
  			    <td><%=fb.textarea("motivo",inc.getColValue("motivo"),false,false,false,49,4)%></td>
				<td>Acci&oacute;n</td>
				<td><%=fb.select("estado","ND=No Descontar,DS=Descontar",inc.getColValue("estado"),false,false,0,"","","onChange=\"javascript:validateEstado()\"",null,"")%> </td>

			</tr>
			<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
			<td> No. de Incapacidad :</td>
			<td>  	<%=fb.intBox("no_referencia",inc.getColValue("no_referencia"),true,false,false,12,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>
			</tr>

			<tr class="TextRow02">
			 <td colspan="3">&nbsp;</td>
				<% if(!fp.equalsIgnoreCase("aprob"))
				{
				%>
			<td> &nbsp;</td>
				<% } else {
				%>
			<td> Estado
				<%=fb.select("aprobado","S=Aprobado",inc.getColValue("aprobado"))%></td>
				<% } %>
				<%
			 //Si error--, quita el error. Si error++, agrega el error.
			// js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
			//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");
			%>
			</tr>

			<tr class="TextRow02">
			<td colspan="4" align="right">
			<%=fb.submit("save","Guardar",true,viewMode)%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
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
   String errCode = "";
   String errMsg = "";
   if (request.getParameter("baction").equalsIgnoreCase("Guardar") || request.getParameter("baction").equalsIgnoreCase("cerrar"))
   	{
   		errCode = request.getParameter("errCode");
   		errMsg = request.getParameter("errMsg");
   	}

   String fecha = "";
   String codigo = "";
   String aprob = "N";

   grupo = request.getParameter("grupo");
   empId = request.getParameter("empId");
   fecha = request.getParameter("fecha");
   codigo = request.getParameter("codigo");
   aprob = request.getParameter("aprobado");
   desde = request.getParameter("desde");
   hasta = request.getParameter("hasta");

   CommonDataObject cdo = new CommonDataObject();

   cdo.setTableName("tbl_pla_incapacidad");
/*   cdo.addColValue("ue_codigo",grupo);
   cdo.addColValue("provincia",request.getParameter("provincia"+j));
   cdo.addColValue("sigla",request.getParameter("sigla"+j));
   cdo.addColValue("tomo",request.getParameter("tomo"+j));
   cdo.addColValue("asiento",request.getParameter("asiento"+j));
   cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
   cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));
   cdo.addColValue("emp_id",request.getParameter("empId"+j));*/
   cdo.addColValue("fecha",fecha);
   cdo.addColValue("hora_salida",request.getParameter("horaSalida"));
   cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"));
   cdo.addColValue("tiempo_horas",request.getParameter("tiempoHoras"));
   cdo.addColValue("tiempo_minutos",request.getParameter("tiempoMinutos"));
   cdo.addColValue("mfalta",request.getParameter("mfalta"));
   cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"));
//   cdo.addColValue("codigo",request.getParameter("codigo"));
   cdo.addColValue("estado",request.getParameter("estado"));
   cdo.addColValue("lugar_nombre",request.getParameter("lugarNombre"));
   cdo.addColValue("lugar",request.getParameter("lugar"));
   cdo.addColValue("motivo",request.getParameter("motivo"));
    cdo.addColValue("no_referencia",request.getParameter("no_referencia"));
//   cdo.addColValue("forma_des","1");
   cdo.addColValue("aprobado",aprob);

   cdo.setWhereClause("ue_codigo="+grupo+" and emp_id="+empId+" and fecha=to_date('"+fecha+"','dd/mm/yyyy') and codigo="+codigo+" and compania="+(String) session.getAttribute("_companyId"));
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

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_incapacidad_list.jsp?grupo=<%=grupo%>&empId=<%=empId%>&desde=<%=desde%>&hasta=<%=hasta%>';

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