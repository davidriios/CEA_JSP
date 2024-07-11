<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String tipo=request.getParameter("tipo");
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("fechainicial",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("fechafinal","");
		cdo.addColValue("transdesde","");
		cdo.addColValue("transhasta","");
		cdo.addColValue("fechacierre","");
		cdo.addColValue("cambios","");
		cdo.addColValue("descuentos","");
	}
	else
	{
		if (id == null) throw new Exception("El Calendario de Planillas no es válido. Por favor intente nuevamente!");

		sql = "select a.TIPOPLA as codePlanilla, a.PERIODO, to_char(a.FECHA_INICIAL,'dd/mm/yyyy') as fechainicial, to_char(a.FECHA_FINAL,'dd/mm/yyyy') as fechafinal, to_char(a.TRANS_DESDE,'dd/mm/yyyy') as transdesde, to_char(a.TRANS_HASTA,'dd/mm/yyyy') as transhasta, to_char(a.FECHA_CIERRE,'dd/mm/yyyy') as fechacierre, to_char(a.CIERRE_CAMBIO_TURNO,'dd/mm/yyyy') as cambios, to_char(a.CIERRE_DESCUENTOS,'dd/mm/yyyy') as descuentos,b.tipopla as codigo, b.descripcion as planilla from TBL_PLA_CALENDARIO a, tbl_pla_tipo_planilla b where a.TIPOPLA=b.tipopla and a.periodo="+id+" and a.tipopla = "+tipo;
		cdo = SQLMgr.getData(sql);
	}



%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Calendario de Planillas - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Calendario de Planillas - Edición - "+document.title;
<%}%>
function tipo()
{
abrir_ventana1('../rhplanilla/list_planilla.jsp?id=3');
}
function chkNullValues(){

	var x = 0;
	var msg='';
	if(document.form1.fechainicial.value ==''){
		msg += ', Fecha Inicial';
		x++;
	}if(document.form1.fechafinal.value==''){
		msg += ', Fecha Final';
		x++;
	} if(document.form1.fechacierre.value==''){
		msg += ', Fecha Cierre';
		x++;
	}
	if(document.form1.transdesde.value==''){
		msg += ', Fecha Transaccion desde';
		x++;
	} 
	if(document.form1.transhasta.value==''){
		msg += ',  Fecha Transaccion Hasta';
		x++;
	} 
	if(msg!='')alert('Seleccione valor en'+msg+'!');
	if(x>0)	return false;
	else return true;
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CALENDARIO DE PLANILLAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>	
			<tr class="TextRow01">
				<td>&nbsp;Tipo de Planilla</td>
				<td><%=fb.intBox("codePlanilla",cdo.getColValue("codePlanilla"),true,false,true,15,2)%>
					<%=fb.textBox("planilla",cdo.getColValue("planilla"),false,false,true,25)%>
					<%=fb.button("btnplanilla","...",true,false,null,null,"onClick=\"javascript:tipo()\"")%>
				</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Calendario Anual</td>
			</tr>	
			<tr class="TextRow01">
				<td width="20%">&nbsp;Per&iacute;odo</td>
				<td width="80%">&nbsp;<%=id%></td>
			</tr>		
			<tr class="TextRow01">
				<td>&nbsp;Fecha Inicial</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fechainicial"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechainicial")%>" />
										</jsp:include>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Fecha Final</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fechafinal"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechafinal")%>" />
										</jsp:include>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Fecha de Cierre</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fechacierre"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechacierre")%>" />
										</jsp:include>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Transacciones</td>
				<td>Desde&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="transdesde"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("transdesde")%>" />
										</jsp:include>&nbsp;&nbsp;Hasta&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="transhasta"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("transhasta")%>" />
										</jsp:include></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Cierre</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Cambio de Turnos</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="cambios"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("cambios")%>" />
										</jsp:include></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Cambio de Descuentos</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="descuentos"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("descuentos")%>" />
										</jsp:include></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%fb.appendJsValidation("\n\tif (!chkNullValues()) error++;\n");%>
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
  cdo = new CommonDataObject();
  cdo.setTableName("TBL_PLA_CALENDARIO");
  cdo.addColValue("TIPOPLA", request.getParameter("codePlanilla")); 
  //cdo.addColValue("PERIODO",request.getParameter("nombre"));
  cdo.addColValue("FECHA_INICIAL",request.getParameter("fechainicial"));
  cdo.addColValue("FECHA_FINAL",request.getParameter("fechafinal"));
  cdo.addColValue("TRANS_DESDE",request.getParameter("transdesde"));
  cdo.addColValue("TRANS_HASTA",request.getParameter("transhasta"));
  cdo.addColValue("FECHA_CIERRE",request.getParameter("fechacierre"));
  cdo.addColValue("CIERRE_CAMBIO_TURNO",request.getParameter("cambios"));
   cdo.addColValue("CIERRE_DESCUENTOS",request.getParameter("descuentos"));
  
 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.setAutoIncWhereClause("TIPOPLA="+request.getParameter("codePlanilla"));
	cdo.setAutoIncCol("PERIODO");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("PERIODO="+request.getParameter("id")+" and TIPOPLA="+request.getParameter("codePlanilla"));

	SQLMgr.update(cdo);
  }
ConMgr.clearAppCtx(null);

  
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
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/calendario_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/calendario_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calendario_list.jsp';
<%
	}
%>
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