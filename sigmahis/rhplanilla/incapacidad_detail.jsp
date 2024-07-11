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
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200019") || SecMgr.checkAccess(session.getId(),"200020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();  
String sql="";
String area=request.getParameter("area");
String provincia=request.getParameter("provincia");
String sigla=request.getParameter("sigla");
String tomo=request.getParameter("tomo");
String asiento=request.getParameter("asiento");
String numEmpleado=request.getParameter("numEmpleado");
String fecha=request.getParameter("fecha");
String codigo=request.getParameter("codigo");

if (request.getMethod().equalsIgnoreCase("GET"))
{
    if (area == null) throw new Exception("El area no es válido. Por favor intente nuevamente!");
    if (provincia == null) throw new Exception("La Provincia no es válida. Por favor intente nuevamente!");
	if (sigla == null) throw new Exception("La Sigla no es válida. Por favor intente nuevamente!");
	if (tomo == null) throw new Exception("El Tomo no es válido. Por favor intente nuevamente!");
	if (asiento == null) throw new Exception("El Asiento no es válido. Por favor intente nuevamente!");
	if (numEmpleado == null) throw new Exception("El Número de Empleado no es válido. Por favor intente nuevamente!");
	if (fecha == null) throw new Exception("La Fecha no es válida. Por favor intente nuevamente!");
	if (codigo == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");

    sql = "SELECT a.ue_codigo as ueCodigo, a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado as numEmpleado, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora_salida,'hh24:mi:ss') as horaSalida, to_char(a.hora_entrada,'hh24:mi:ss') as horaEntrada, decode(a.tiempo_horas,null,' ',a.tiempo_horas) as tiempoHoras, decode(a.tiempo_minutos,null,' ',a.tiempo_minutos) as tiempoMinutos, decode(a.mfalta,null,' ',a.mfalta) as mfalta, b.descripcion as mfaltaDesc, a.codigo, a.estado, nvl(a.lugar_nombre,' ') as lugarNombre, decode(a.lugar,null,' ',a.lugar) as lugar, nvl(a.motivo,' ') as motivo FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+provincia+" and a.sigla="+sigla+" and a.tomo="+tomo+" and a.asiento="+asiento+" and a.ue_codigo="+area+" and a.num_empleado="+numEmpleado+" and a.mfalta=b.codigo(+)";
    cdo = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Incapacidad Edición - "+document.title;
</script>
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="RHPLANILLA - REGISTRO DE ASISTENCIA DE EMPLEADOS - INCAPACIDADES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
      <table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
      <%fb = new FormBean("formIncap",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%=fb.formStart(true)%>
      <%=fb.hidden("provincia",provincia)%>
	  <%=fb.hidden("sigla",sigla)%>
	  <%=fb.hidden("tomo",tomo)%>
	  <%=fb.hidden("asiento",asiento)%>
	  <%=fb.hidden("numEmpleado",numEmpleado)%>

	  <%=fb.hidden("area",area)%>
    
      <tr>
        <td colspan="6">&nbsp;</td>
      </tr>
      <tr class="TextRow02">
        <td colspan="6">&nbsp;</td>
      </tr>     
      <tr class="TextRow01">
	      <td>C&oacute;digo</td>
		  <td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,10,1)%></td>	
	      <td>Motivo</td>
		  <td colspan="3"><%=fb.intBox("mfalta",cdo.getColValue("mfalta"),false,false,true,5,3)%><%=fb.textBox("mfaltaDesc",cdo.getColValue("mfaltaDesc"),false,false,true,63,50)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addMotivo()\"")%></td>		  		        
	  </tr>				 
	  <tr class="TextRow02" >
	      <td width="12%">Fecha</td>
		  <td width="22%"><jsp:include page="../common/calendar.jsp" flush="true">
			  <jsp:param name="noOfDateTBox" value="1" />
			  <jsp:param name="clearOption" value="true" />
			  <jsp:param name="nameOfTBox1" value="fecha"/>	
			  <jsp:param name="jsEvent" value="sumHoras()"/>					
			  <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha")==null)?"":cdo.getColValue("fecha")%>" />
			  </jsp:include>
		  </td>
          <td width="12%">Desde</td>
		  <td width="30%">
		      <jsp:include page="../common/calendar.jsp" flush="true">
			  <jsp:param name="noOfDateTBox" value="1" />
			  <jsp:param name="nameOfTBox1" value="horaEntrada"/>
			  <jsp:param name="format" value="hh24:mi:ss" />
			  <jsp:param name="jsEvent" value="sumHoras()" />
			  <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("horaEntrada")==null)?"":cdo.getColValue("horaEntrada")%>" />
		  	  
			  </jsp:include>
		  </td>
		  <td width="12%">Hasta</td>
		  <td width="12%">
			  <jsp:include page="../common/calendar.jsp" flush="true">
			  <jsp:param name="noOfDateTBox" value="1" />
			  <jsp:param name="nameOfTBox1" value="horaSalida"/>
			  <jsp:param name="format" value="hh24:mi:ss" />
			  <jsp:param name="jsEvent" value="sumHoras()" />
			  <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("horaSalida")==null)?"":cdo.getColValue("horaSalida")%>" />
			  </jsp:include>
		  </td>
	  </tr>	  
	  <tr class="TextRow01" >
	      <td>Acci&oacute;n</td>
		  <td><%=fb.select("estado","ND=No Descontar,DS=Descontar",cdo.getColValue("estado"))%></td>	  
		  <td>Hras.</td>
		  <td><%=fb.intBox("tiempoHoras",cdo.getColValue("tiempoHoras"),false,false,true,9,2)%></td>
		  <td>Min.</td>
		  <td><%=fb.intBox("tiempoMinutos",cdo.getColValue("tiempoMinutos"),false,false,true,9,2)%></td>
      </tr>	  
	  <tr class="TextRow02">
		  <td>Tipo de Lugar</td>
		  <td><%=fb.select("lugar","1=Hospital Punta Pacifica,2=Caja de Seguro Social,3=Clínica Externa,4=Centro Médico,5=Otro",cdo.getColValue("lugar"),false,false,0)%></td>
		  <td>Nombre Lugar</td>
		  <td colspan="3"><%=fb.textBox("lugarNombre",cdo.getColValue("lugarNombre"),false,false,false,74,60)%></td>
	  </tr>
      <tr class="TextRow01" >
		  <td>Observaci&oacute;n</td>
		  <td colspan="5"><%=fb.textarea("motivo",cdo.getColValue("motivo"),false,false,false,96,4)%></td>
	  </tr>
      <tr class="TextRow02">
		  <td align="right" colspan="6"><%=fb.submit("save","Guardar",true,false)%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	  </tr>	 
      <tr>
        <td colspan="6">&nbsp;</td>
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
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close  
  area=request.getParameter("area");
  provincia=request.getParameter("provincia");
  sigla=request.getParameter("sigla");
  tomo=request.getParameter("tomo");
  asiento=request.getParameter("asiento");
  numEmpleado=request.getParameter("numEmpleado");
  fecha=request.getParameter("fecha");
  codigo=request.getParameter("codigo");
  
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_pla_incapacidad");
  cdo.addColValue("ue_codigo",area);
  cdo.addColValue("provincia",provincia);
  cdo.addColValue("sigla",sigla);
  cdo.addColValue("tomo",tomo);
  cdo.addColValue("asiento",asiento);
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("numEmpleado",numEmpleado);
  cdo.addColValue("fecha",fecha);
  cdo.addColValue("codigo",codigo); 
  cdo.addColValue("mfalta",request.getParameter("mfalta"));
  cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"));
  cdo.addColValue("hora_salida",request.getParameter("horaSalida"));
  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("hora_salida",request.getParameter("horaSalida"));
  cdo.addColValue("lugar",request.getParameter("lugar"));
  cdo.addColValue("lugar_nombre",request.getParameter("lugarNombre"));
  cdo.addColValue("motivo",request.getParameter("motivo"));
  
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());  
  cdo.setWhereClause("ue_codigo="+area+" and provincia="+provincia+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and num_empleado="+numEmpleado+" and fecha='"+fecha+"' and codigo="+codigo);

  SQLMgr.update(cdo);
  
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/incapacidad_detail.jsp?provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&numEmpleado="+numEmpleado+"&area="+area+"&fecha="+fecha+"&codigo="+codigo))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/incapacidad_detail.jsp?provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&numEmpleado="+numEmpleado+"&area="+area+"&fecha="+fecha+"&codigo="+codigo)%>';
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