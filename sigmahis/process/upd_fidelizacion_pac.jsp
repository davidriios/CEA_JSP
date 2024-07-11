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

if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("ID no es válido. Por favor intente nuevamente!");

		sql = "select primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, to_char(coalesce(f_nac,fecha_nacimiento), 'dd/mm/yyyy') fecha_nacimiento, codigo, vip, nvl(trunc(months_between(sysdate,coalesce(f_nac,fecha_nacimiento))/12),0) as edad, sexo, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'ADM_EDAD_JUB_F'),0) as edad_jub_mujeres, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'ADM_EDAD_JUB_M'),0) as edad_jub_varones from tbl_adm_paciente where pac_id="+id;
		cdo = SQLMgr.getData(sql);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function checkFidelizacion(){
	var vip=$("#vip").val();
	var edad=$("#edad").val();
	var sexo=$("#sexo").val();
	var edad_jub='';
	var msg=''; 
	if(vip=='T'||vip=='P'){
		if(vip=='T'){
			if(edad.trim()=='')msg=' Fecha de Nacimiento del Paciente.';
			if(sexo=='F')edad_jub='<%=cdo.getColValue("edad_jub_mujeres")%>';
			else if(sexo=='M')edad_jub='<%=cdo.getColValue("edad_jub_varones")%>';
			else msg+=' Sexo del Paciente.';
			if(parseInt(edad)<parseInt(edad_jub)&&parseInt(edad_jub)!=0)msg+=' Paciente no Tiene la edad para Jubilado/ tercera edad.';			
		}
		if(msg!=''){
			CBMSG.error("Por favor Revisar:"+msg);
			return false;
		}else return true;
	}
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EDITAR FECHA DE NACIMIENTO"></jsp:param>
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
<%=fb.hidden("edad",cdo.getColValue("edad"))%>
<%=fb.hidden("sexo",cdo.getColValue("sexo"))%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader01">
			<td align="right"><cellbytelabel id="1">Nombre</cellbytelabel>:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("primer_nombre")%>&nbsp;
			<%=cdo.getColValue("segundo_nombre")%>&nbsp;
			<%=cdo.getColValue("primer_apellido")%>&nbsp;
			<%=cdo.getColValue("segundo_apellido")%>
      </td>
      <td align="right"><cellbytelabel id="2">Fecha de Nacimiento</cellbytelabel>:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("fecha_nacimiento")%>
      </td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel id="3">Programa Fidelizacion</cellbytelabel>:</td>
			<td width="" colspan="3">
			
			<%=fb.select(ConMgr.getConnection(),"select vip as code, descripcion,empresa FROM tbl_adm_tipo_paciente order by id","vip_old",cdo.getColValue("vip"),false,true,0,"text10","","")%> 
      </td>
		</tr>
		
		<tr class="TextHeader02">
			<td colspan="4"><cellbytelabel id="5">Nuevo Programa Fidelizacion</cellbytelabel>:</td>
		</tr>
    <tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel id="6">Programa de Fidelizacion Nuevo:</cellbytelabel>:</td>
			<td width="" colspan="3"> <%=fb.select(ConMgr.getConnection(),"select vip as code, descripcion,empresa FROM tbl_adm_tipo_paciente order by id","vip",cdo.getColValue("vip"),false,false,0,"text10","","")%>
      </td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="center">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
<%fb.appendJsValidation("if(!checkFidelizacion()){error++;}");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>
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

	cdo.setTableName("tbl_adm_paciente");
	cdo.addColValue("vip",request.getParameter("vip"));
	//cdo.addColValue("codigo",request.getParameter("codigo"));

	if (mode.equalsIgnoreCase("edit"))
	{
    cdo.setWhereClause("pac_id="+request.getParameter("id"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.update(cdo);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript" src="../js/global.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>'); 
	parent.hidePopWin(false);
	parent.window.location.reload(true);
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
