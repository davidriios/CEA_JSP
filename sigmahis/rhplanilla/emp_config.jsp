<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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
800054	AGREGAR  ACREEDORES DE EMPLEADOS
800055	MODIFICAR ACREEDORES DE EMPLEADOS
================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800054") || SecMgr.checkAccess(session.getId(),"800055"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("code","0");
	}
	else
	{
	if (id == null) throw new Exception("El  Empleado no es válido. Por favor intente nuevamente!");

		sql = "select a.provincia||'-'||a.sigla||'-'||a.tomo||' '||a.asiento as cedula, a.provincia as prov, a.sigla as sig, a.tomo as tom, a.asiento as asi, a.compania, a.num_empleado as numEmp, a.emp_id as id,  a.primer_nombre||' '||primer_apellido as nombre, a.ubic_fisica as ubic, a.num_empleado as numEmp, e.estado, e.estadoDesc, e.grupo, e.grupoDesc, e.ingreso, e.egreso, e.descripcion, e.ubicacion_fisica, a.ubic_fisica||' - '||u.descripcion as ubicFisica, a.cargo||' - '||g.denominacion as cargo from tbl_pla_empleado a, tbl_sec_unidad_ejec u,  tbl_pla_cargo g, (select decode(e.estado,'1','ACTIVO','2','INACTIVO') as estadoDesc, e.estado, e.grupo, b.descripcion, c.descripcion as grupoDesc, e.ubicacion_fisica,   e.compania, e.emp_id,  to_char(e.fecha_ingreso_grupo,'dd/mm/yyyy') as ingreso, to_char(e.fecha_egreso_grupo,'dd/mm/yyyy') as egreso from  tbl_sec_unidad_ejec b, tbl_pla_ct_grupo c, tbl_pla_ct_empleado e where e.ubicacion_fisica = b.codigo and e.compania = b.compania and e.grupo = c.codigo and e.compania = c.compania and e.compania="+(String) session.getAttribute("_companyId")+" and e.emp_id="+id+") e where u.codigo = a.ubic_fisica and u.compania = a.compania and a.cargo = g.codigo and a.compania = g.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id= e.emp_id(+) and a.compania = e.compania(+) and a.estado<>3 and a.emp_id="+id;
		
		
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
document.title=" Empleados - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("regEmp")){%>
document.title=" Empleados - Edición - "+document.title;
<%}%>
function empgrp()
{
abrir_ventana1('../common/search_ct_grupo.jsp');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE EMPLEADOS"></jsp:param>
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
			<%=fb.hidden("uFisica",cdo.getColValue("ubic"))%>
            <%=fb.hidden("provincia",cdo.getColValue("prov"))%>
            <%=fb.hidden("sigla",cdo.getColValue("sig"))%>
            <%=fb.hidden("tomo",cdo.getColValue("tom"))%>
            <%=fb.hidden("asiento",cdo.getColValue("asi"))%>
		
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="20%">&nbsp;N&uacute;mero de Empleado </td>
				<td width="30%">&nbsp;<%=fb.textBox("num_empleado",cdo.getColValue("numEmp"),true,false,true,10)%></td>
				<td width="17%">&nbsp;Nombre</td>
			  <td width="33%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,30)%></td>
			</tr>	
			
			<tr class="TextRow01" >
				<td width="20%">&nbsp;Cargo </td>
				<td width="30%">&nbsp;<%=fb.textBox("cargo",cdo.getColValue("cargo"),true,false,false,40)%></td>
				<td width="17%">&nbsp;Ubicacion Fìsica</td>
			  <td width="33%"><%=fb.textBox("ubicFisica",cdo.getColValue("ubicFisica"),true,false,false,40)%></td>
			</tr>	
			
			<tr class="TextRow01">
				<td>&nbsp;Estado</td>
				<td><%=fb.select("estado","1=Activo,2=Inactivo",cdo.getColValue("estado"))%></td>
				<td>&nbsp;Grupo</td>				
				<td><%=fb.intBox("grupo",cdo.getColValue("grupo"),true,false,true,8)%><%=fb.textBox("grupoDesc",cdo.getColValue("grupoDesc"),false,false,true,25)%><%=fb.button("btngrp","Ir",true,false,null,null,"onClick=\"javascript:empgrp();\"")%></td>
			</tr>
					
			<tr class="TextRow01">
				<td>&nbsp;Fecha de Ingreso</td>
				 <td>	<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="ingreso" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("ingreso")==null)?"":cdo.getColValue("ingreso")%>" />
							</jsp:include>	</td>
				
				<td>&nbsp;Fecha de Egreso</td>
				 <td>	<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="egreso" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("egreso")==null)?"":cdo.getColValue("egreso")%>" />
							</jsp:include>	</td>
			</tr>
			
			<tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
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
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_ct_empleado");
    
  cdo.addColValue("estado", request.getParameter("estado")); 
  cdo.addColValue("fecha_ingreso_grupo", request.getParameter("ingreso")); 
   if (request.getParameter("egreso") != null && !request.getParameter("egreso").trim().equals("")) cdo.addColValue("fecha_egreso_grupo",request.getParameter("egreso")); 
  cdo.addColValue("grupo", request.getParameter("grupo"));
  cdo.addColValue("num_empleado", request.getParameter("num_empleado"));
  cdo.addColValue("ubicacion_fisica", request.getParameter("uFisica"));
  cdo.addColValue("fecha_modificacion",cDateTime);
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName")); 
  
  
  if (mode.equalsIgnoreCase("add") || mode.equalsIgnoreCase("regEmp"))
  {
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",cDateTime);
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
	cdo.addColValue("provincia", request.getParameter("provincia"));
  cdo.addColValue("sigla", request.getParameter("sigla"));
  cdo.addColValue("tomo", request.getParameter("tomo"));
  cdo.addColValue("asiento", request.getParameter("asiento"));
	
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("id")+ " and estado="+request.getParameter("estado"));

	SQLMgr.update(cdo);
  }
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/asistencia_emp_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/asistencia_emp_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/asistencia_emp_list.jsp';
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