<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String id = request.getParameter("id");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(mode.trim().equals("add")){
	sql = "select  a.nombre_empleado as nombreEmpRepr, c.denominacion cargoEmpRepr, a.emp_id as empIdRepr, nvl(a.num_empleado,' ') as numEmpleado,  (select descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_organi and compania=a.compania) as depto,a.cedula1 cedula from vw_pla_empleado a, tbl_pla_cargo c where a.compania="+(String)session.getAttribute("_companyId")+" and a.cargo = c.codigo and a.compania = c.compania  and c.firmar_carta_trabajo = 'S' and a.estado not in (3,13) and a.cargo = '63' ";
	cdo= SQLMgr.getData(sql);
	if(cdo==null)cdo= new CommonDataObject();
	id="0";

	cdo.addColValue("id","0");
	cdo.addColValue("fecha_desde","");
	cdo.addColValue("fecha_hasta",cDateTime.substring(0,10));
	cdo.addColValue("fecha_solicitud",cDateTime);
	cdo.addColValue("fecha_creacion",cDateTime);
	cdo.addColValue("fecha_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("impreso","N");
	cdo.addColValue("estado","A");
	}
	else
	{
		if (id == null) throw new Exception("El Numero de la solicitud no es válido. Por favor intente nuevamente!");
		sql=" select   s.compania,s.id,s.estado, s.usuario_creacion,s.usuario_modificacion,to_char(s.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion, s.emp_id empIdCert,to_char(s.fecha_solicitud,'dd/mm/yyyy hh12:mi:ss am')fecha_solicitud, s.emp_id_firma empIdRepr,s.destinatario1,s.destinatario2, s.destinatario3,s.referencia,to_char(s.fecha_desde,'dd/mm/yyyy')fecha_desde, to_char(s.fecha_hasta,'dd/mm/yyyy')fecha_hasta,to_char(s.fecha_impresion,'dd/mm/yyyy') fecha_impresion,s.observacion, nvl(s.impreso,'N')impreso,(select nombre_empleado from vw_pla_empleado where emp_id = s.emp_id_firma and compania=s.compania )nombreEmpRepr,(select c.denominacion from vw_pla_empleado e,tbl_pla_cargo c where e.emp_id = s.emp_id_firma and e.compania=s.compania and e.cargo = c.codigo and e.compania = c.compania)cargoEmpRepr,(select nombre_empleado from vw_pla_empleado where emp_id = s.emp_id and compania=s.compania ) nombreEmpCert from tbl_pla_sol_carta s where s.id ="+id+" and s.compania ="+(String) session.getAttribute("_companyId");
		cdo= SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Carta para licencias- '+document.title;
function doAction(){}
function showEmpCert(){abrir_ventana('../common/search_empleado.jsp?fp=cartaLicencia');}
function showEmpRepr(){abrir_ventana('../common/search_empleado.jsp?fp=cartaLicenciaRepre');}
function setFecha(value){if(value=='N'){document.form0.fecha_impresion.value='';}else if(value=='S' && document.form0.fecha_impresion.value==''){alert('Introduzca fecha de Impresion de la carta.!!');}}
function existsFecha(){var impreso = document.form0.impreso.value;if(impreso=='S' && document.form0.fecha_impresion.value==''){return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARTAS Y CERTIFICACIONES"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("empIdRepr",cdo.getColValue("empIdRepr"))%>
			<%=fb.hidden("deptoEmpRepr",cdo.getColValue("depto"))%>
			<%=fb.hidden("noEmpleado","")%>
			<%=fb.hidden("cedula",cdo.getColValue("cedula"))%>
			<%=fb.hidden("usuario_creacion",cdo.getColValue("usuario_creacion"))%>
			<%=fb.hidden("fecha_creacion",cdo.getColValue("fecha_creacion"))%>
			<%=fb.hidden("fecha_solicitud",cdo.getColValue("fecha_solicitud"))%>
			<%=fb.hidden("estado",cdo.getColValue("estado"))%>
			<%=fb.hidden("id",cdo.getColValue("id"))%>


   <table align="center" width="90%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" >
				   <td colspan="3">PARAMETROS</td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow01" >
				   <td width="40%" rowspan="2">Representante de la Empresa</td>
				   <td colspan="2">
							<%=fb.textBox("nombreEmpRepr",cdo.getColValue("nombreEmpRepr"),true,false,true,50)%>
							<%=fb.button("add","...",true,viewMode,null,null,"onClick=\"javascript:showEmpRepr()\"")%>
					 </td>
			  </tr>
			  <tr class="TextRow02">
			  	 <td colspan="2"><%=fb.textBox("cargoEmpRepr",cdo.getColValue("cargoEmpRepr"),false,false,true,60)%></td>
			  </tr>
				<tr class="TextRow01" >
				   <td width="40%">Empleado a Certificar</td>
				   <td colspan="2"><%=fb.textBox("empIdCert",cdo.getColValue("empIdCert"),true,false,true,10)%>
							<%=fb.textBox("nombreEmpCert",cdo.getColValue("nombreEmpCert"),true,false,true,50)%>
							<%=fb.button("add","...",true,viewMode,null,null,"onClick=\"javascript:showEmpCert()\"")%>
					 </td>
			  </tr>
			  <%=fb.hidden("deptoEmpCert","")%>
			  <%=fb.hidden("cargoEmpCert","")%>
			  <!--
			  <tr class="TextFilter">
			  	 <td colspan="2"><%//=fb.textBox("cargoEmpCert","",false,false,false,60)%></td>
			  </tr>
			  <tr class="TextFilter">
			  	 <td colspan="2"><%//=fb.textBox("deptoEmpCert","",false,false,false,60)%></td>
			  </tr>-->
				<tr class="TextRow02" >
				   <td width="40%" rowspan="3">Carta Dirigida a</td>
				   <td colspan="2"><%=fb.textBox("destinatario1",cdo.getColValue("destinatario1"),false,false,viewMode,70,60)%></td>
			  	</tr>
				<tr class="TextRow01" >
				   	<td colspan="2"><%=fb.textBox("destinatario2",cdo.getColValue("destinatario2"),false,false,viewMode,70,60)%></td>
			  	</tr>
				<tr class="TextRow02" >
				   	<td colspan="2"><%=fb.textBox("destinatario3",cdo.getColValue("destinatario3"),false,false,viewMode,70,60)%></td>
			  	</tr>
				<tr class="TextRow01" >
					<td>Referencia</td>
				   	<td colspan="2"><%=fb.textBox("referencia",cdo.getColValue("referencia"),false,false,viewMode,70,60)%></td>
			  	</tr>
				<tr class="TextRow02" >
				   <td>Observaciones</td>
				   <td colspan="2"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,0,3,180,"","width:70%","")%>
					 </td>
			  </tr>
			  <tr class="TextRow01">
					<td>Fecha</td>
					<td colspan="2"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="nameOfTBox1" value="fecha_desde" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_desde")%>" />
								<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
								<jsp:param name="nameOfTBox2" value="fecha_hasta" />
								<jsp:param name="valueOfTBox2" value="<%=cdo.getColValue("fecha_hasta")%>" />
						</jsp:include>
					</td>
				</tr>
				<%if(!mode.trim().equals("add")){%>
				<tr class="TextRow02" >
				   <td width="20%">Impreso</td>
				   <td width="20%" ><%=fb.select("impreso","S=SI,N=NO",cdo.getColValue("impreso"),false,viewMode,0,"Text10",null,"onChange=\"javascript:setFecha(this.value)\"")%>		 </td>
				   <td width="60%"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha_impresion" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_impresion")%>" />
								<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
						</jsp:include>
					</td>
			  	</tr>
				<%}else{%>
				<%=fb.hidden("impreso","N")%>
				<%=fb.hidden("fecha_impresion","")%>
				<%}%>
				<tr class="TextRow01" >
				<td colspan="3" align="right"> <%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>
	</table>
			</td>
	</tr>
   </table>
   			<%fb.appendJsValidation("if(document."+fb.getFormName()+".mode.value!='add'&&!existsFecha()){alert('Debe introducir la fecha de impresion!');error++;}");%>

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{

  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_sol_carta");
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("estado", request.getParameter("estado"));
  cdo.addColValue("emp_id",request.getParameter("empIdCert"));
  cdo.addColValue("fecha_solicitud",request.getParameter("fecha_solicitud"));
  cdo.addColValue("emp_id_firma",request.getParameter("empIdRepr"));
  cdo.addColValue("destinatario1",request.getParameter("destinatario1"));
  cdo.addColValue("destinatario2",request.getParameter("destinatario2"));
  cdo.addColValue("destinatario3",request.getParameter("destinatario3"));
  cdo.addColValue("referencia",request.getParameter("referencia"));
  cdo.addColValue("fecha_desde",request.getParameter("fecha_desde"));
  cdo.addColValue("fecha_hasta",request.getParameter("fecha_hasta"));
  cdo.addColValue("fecha_impresion",request.getParameter("fecha_impresion"));
  cdo.addColValue("observacion",request.getParameter("observacion"));
  cdo.addColValue("impreso",request.getParameter("impreso"));
  cdo.addColValue("fecha_modificacion",cDateTime);
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("fecha_creacion",cDateTime);
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.setAutoIncCol("id");
	SQLMgr.insert(cdo);
  }
  else
  {
  	cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"));
	cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"));
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and id="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_sol_carta.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_sol_carta.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_sol_carta.jsp';
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
