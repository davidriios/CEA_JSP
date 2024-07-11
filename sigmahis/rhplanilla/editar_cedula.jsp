<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fg == null) fg ="";
if(fp == null) fp ="";
if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("EmpleadoID no es válido. Por favor intente nuevamente!");

		sql = "select provincia, sigla, tomo, asiento, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, to_char(fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, num_empleado,pasaporte from tbl_pla_empleado where emp_id="+id;
		cdo = SQLMgr.getData(sql);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Recursos Humanos - '+document.title;

function verCedula(){
	var provincia=document.form1.provincia.value;
	var sigla=document.form1.sigla.value;
	var tomo=document.form1.tomo.value;
	var asiento=document.form1.asiento.value;
	var numero=document.form1.num_empleado.value;
	
	var provinciaold=document.form1.provincia_old.value;
	var siglaold=document.form1.sigla_old.value;
	var tomoold=document.form1.tomo_old.value;
	var asientoold=document.form1.asiento_old.value;
	
	var pasaporteold=document.form1.pasaporte_old.value;
	var pasaporte=document.form1.pasaporte.value;
	if(pasaporte !=''){
	
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',document.form1.pasaporte,'tbl_pla_empleado',' pasaporte=\''+document.form1.pasaporte.value+'\' ','<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')){ document.form1.pasaporte.value='';return false;}
	else return true;
	
	}else{
	var x = getDBData('<%=request.getContextPath()%>','count(*)','tbl_pla_empleado',' provincia='+provincia+' and sigla=\''+sigla+'\' and tomo='+tomo+' and asiento='+asiento+' and num_empleado='+numero,'');
	if(x=='1') {
		alert('Este número de cédula ya existe!');
		return false;
	} else return true;
	}	
	
}

function verNumEmpleado(){
	var numero=document.form1.num_empleado.value;
	var numeroOld=document.form1.num_empleado_old.value;
	
	var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_empleado',' num_empleado='+numero,'');
	if(x=='1') {
		alert('Este número de empleado ya existe!');
		return false;
	} else {		showPopWin('../common/run_process.jsp?fp=UPDNOEMP&actType=50&docType=UPDNOEMP&docId='+numero+'&docNo='+numero+'&compania=<%=(String) session.getAttribute("_companyId")%>&noEmpleado='+numero+'&codigo='+numeroOld+'&empId=<%=id%>',winWidth*.75,winHeight*.65,null,null,'');
return true;}
}

function checkPasaporte(obj)
{ 
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado',' pasaporte=\''+obj.value+'\' ','<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')){ document.form1.pasaporte.value='';return true;}
	else return false;

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EDITAR CEDULA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader01">
			<td align="right">Nombre:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("primer_nombre")%>&nbsp;
			<%=cdo.getColValue("segundo_nombre")%>&nbsp;
			<%=cdo.getColValue("primer_apellido")%>&nbsp;
			<%=cdo.getColValue("segundo_apellido")%>
      </td>
      <td align="right">Fecha de Nacimiento:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("fecha_nacimiento")%>
      </td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right">C&eacute;dula Anterior:</td>
			<td width="" colspan="1">
			<%=fb.textBox("provincia_old",cdo.getColValue("provincia"),true,false,true,3,null,null,"")%>
      <%=fb.textBox("sigla_old",cdo.getColValue("sigla"),true,false,true,3,null,null,"")%>
      <%=fb.textBox("tomo_old",cdo.getColValue("tomo"),true,false,true,3,null,null,"")%>
      <%=fb.textBox("asiento_old",cdo.getColValue("asiento"),true,false,true,3,null,null,"")%>/PASAPORTE:<%=fb.textBox("pasaporte_old",cdo.getColValue("pasaporte"),false,false,(fg.equals("num_empl")?true:false),15,20,null,null,"")%>
      </td>
	  <td width="15%" align="right">Número de Empleado:</td>
	  <td> <%=fb.textBox("num_empleado_old",cdo.getColValue("num_empleado"),true,false,true,10,null,null,"")%></td> 
		</tr>
		<tr class="TextHeader02">
			<td colspan="2">Ingresar Nueva C&eacute;dula:</td>
			<td colspan="2">Ingresar Nuevo Número de Empleado:</td>
		</tr>
    <tr class="TextRow01">
			<td width="15%" align="right">C&eacute;dula/Pasaporte Nuev@:</td>
			<td width="" colspan="1">
			<%=fb.textBox("provincia",cdo.getColValue("provincia"),true,false,(fg.equals("num_empl")?true:false),3,null,null,"")%>
      <%=fb.textBox("sigla",cdo.getColValue("sigla"),true,false,(fg.equals("num_empl")?true:false),3,null,null,"")%>
      <%=fb.textBox("tomo",cdo.getColValue("tomo"),true,false,(fg.equals("num_empl")?true:false),3,null,null,"")%>
      <%=fb.textBox("asiento",cdo.getColValue("asiento"),true,false,(fg.equals("num_empl")?true:false),3,null,null,"")%>
	  /PASAPORTE:<%=fb.textBox("pasaporte",cdo.getColValue("pasaporte"),false,false,(fg.equals("num_empl")?true:false),15,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%>
      </td>
	   <td width="15%" align="right">Número de Empleado:</td>
	  <td> <%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),true,false,(fg.equals("num_empl")?false:true),10,null,null,"")%></td> 
	
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="center">
				<%if(fg !=null &&  fg.trim().equals("num_empl")){%>
				<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"verNumEmpleado()\"")%>
				<%}else {%><%=fb.submit("save","Guardar",true,false)%><%}%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
<%
if(fg.equals("num_empl")) fb.appendJsValidation("if(!verNumEmpleado()) error++;");
else fb.appendJsValidation("if(!verCedula()) error++;");
%>
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

	cdo.setTableName("tbl_pla_empleado");
	if(request.getParameter("fg")!=null && request.getParameter("fg").equals("num_empl")){
	cdo.addColValue("num_empleado",request.getParameter("num_empleado"));
	} else {
	cdo.addColValue("provincia",request.getParameter("provincia"));
	cdo.addColValue("sigla",request.getParameter("sigla"));
	cdo.addColValue("tomo",request.getParameter("tomo"));
	cdo.addColValue("asiento",request.getParameter("asiento"));
	cdo.addColValue("pasaporte",request.getParameter("pasaporte"));
	}
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("edit"))
	{
    	cdo.setWhereClause("emp_id="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empleado_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empleado_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empleado_list.jsp?fp=<%=fp%>&fg=<%=fg%>';
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