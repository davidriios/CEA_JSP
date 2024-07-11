<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String curUserName = (String)session.getAttribute("_userName");
String curCompany = (String)session.getAttribute("_companyId");

if (fg == null) fg = "";
if (fp == null) fp = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (mode == null) mode = "";

if (request.getMethod().equalsIgnoreCase("GET")){
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script>
document.title = 'PARAMETROS EXTRAS '+document.title;
$(document).ready(function(){
  <%if(fp.trim().equalsIgnoreCase("CARGO_DOBLE_COB")){%>
     $("#empresa").change(function(c){
	   var cVal = ($(this).val()).split(":");
	   var empresa = cVal[0];
	   var prioridad = cVal[1];	 
	   var fg = "<%=fg%>";
	   var detallado = $("#detallado").is(":checked")?"Y":"N";

	   if (empresa){
	      switch (fg){
		    case 'DEV_NETO':abrir_ventana("../facturacion/print_cargo_dev_neto.jsp?noSecuencia=<%=noAdmision%>&pacId=<%=pacId%>&empresa="+empresa+"&prioridad="+prioridad+"&detallado="+detallado); break;
		    case 'DEV':abrir_ventana("../facturacion/print_cargo_dev.jsp?noSecuencia=<%=noAdmision%>&pacId=<%=pacId%>&empresa="+empresa+"&prioridad="+prioridad+"&detallado="+detallado); break;
			default: '';
		  } 
		 parent.hidePopWin(true);
	   }
	 });
  <%}%>
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td id="container">
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("fg",fg)%>
				 <%=fb.hidden("fp",fp)%>

				<tr>
					<td colspan="2" >
						
						<%if(fp.trim().equalsIgnoreCase("CARGO_DOBLE_COB")){%>	
						  <table width="100%" cellpadding="1" cellspacing="1">
						      <tr class="TextRow01">
							    <td colspan="2"><label for="detallado">Detallado?</label>
								 <input type="checkbox" name="detallado" id="detallado" title="Imprimir reporte detallado">
								</td>
							  </tr>
							  <tr class="TextRow01">
								<td width="20%">Aseguradora:</td>
								<td width="90">
								<%=fb.select(ConMgr.getConnection(),"select distinct em.codigo||':'||ba.prioridad as codigo, ba.prioridad||' - '||em.nombre, em.nombre from tbl_adm_beneficios_x_admision ba, tbl_adm_empresa em where nvl(ba.estado,'A')= 'A' and ba.pac_id = "+pacId+" and ba.admision = "+noAdmision+" and em.codigo = ba.empresa order by 3","empresa","",false,false,0,"Text10",null,null,null,"S")%>
								</td>
							  </tr>
						  </table>
						<%}%>	  
					  
					</td>
				</tr>
				
					<%=fb.formEnd(true)%>
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
%>
<!doctype html>
<html>
<head>
<script>
	function closeWindow(){
	}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>