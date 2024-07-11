<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

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

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql  	= "";
String emp_id= request.getParameter("emp_id");
String prov=request.getParameter("prov");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String num_empleado=request.getParameter("num");
String grupo=request.getParameter("grp");
String rata=request.getParameter("rath");
String id=request.getParameter("id");

if (emp_id == null ) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql="select b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, f.descripcion as descripcion, b.emp_id as emp_id, b.estado, c.denominacion, g.descripcion as estadodesc, b.num_empleado as num_empleado, b.rata_hora as rata, b.ubic_seccion as grupo from tbl_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c, tbl_pla_estado_emp g where b.compania = f.compania and b.ubic_seccion = f.codigo and b.compania = c.compania and b.cargo = c.codigo and b.estado = g.codigo and b.emp_id = "+emp_id+" and b.compania="+(String) session.getAttribute("_companyId");
al = SQLMgr.getDataList(sql);
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Registro de Transacciones - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}
function addVarios(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana1('../rhplanilla/reg_transac_config.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}



</script>
</head>
<body topmargin="10" leftmargin="10" rightmargin="10">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="REGISTRO DE TRANSACCIONES"></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("sig",sig)%>
<%=fb.hidden("tom",tom)%>
<%=fb.hidden("asi",asi)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("rata",rata)%>
<%=fb.hidden("num_empleado",num_empleado)%>

<table width="80%" cellpadding="1" cellspacing="1">
 
  
  <tr align="center" class="TextHeader">
    	<td colspan="1">&nbsp;</td>
    	<td colspan="4" align="center">PROCESO QUE DESEA REALIZAR</td>
    	<td colspan="1">&nbsp;</td>
  </tr>
	
  <tr align="center" class="TextHeader">
    	<td colspan="1" align="center"> &nbsp;</td>
    	<td colspan="4" align="center">Selleccione el Proceso</td>
    	<td colspan="1" align="center">&nbsp;</td>  
  </tr>
  
  <tr align="center" class="TextHeader">
    	<td colspan="6" align="center">&nbsp; </td>
   </tr>
  <%
 if (al.size() > 0)
	{
	cdo = (CommonDataObject) al.get(0);

		%>
  <tr align="center" class="TextRow01">
    <td align="center"><a href="javascript:addVarios(<%=cdo.getColValue("provincia")%>,'<%=cdo.getColValue("sigla")%>',<%=cdo.getColValue("tomo")%>,<%=cdo.getColValue("asiento")%>,<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("num_empleado")%>,<%=cdo.getColValue("rata")%>,<%=cdo.getColValue("grupo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Registrar Transacciones Varias</a></td>
  </tr>

   <%
	 }
	 %>

</table>
<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
