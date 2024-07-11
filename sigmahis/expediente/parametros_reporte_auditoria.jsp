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
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reportes de Auditoría del Expediente - '+document.title;
function doAction(){}

$(function(){
   
   $(".rpt").click(function(){
     var cds = $("#cds").val();
     var fechaAudit = $("#fechaAudit").val() || "<%=fecha.substring(0,10)%>";
     var fechaIngEgr = $("#fechaIngEgr").val() || "<%=fecha.substring(0,10)%>";
     var cdsDesc = $("#cds option:selected").text();
	 
     var opt = $(this).val();

	 switch (opt){
	   case "1": abrir_ventana("../expediente/print_nota_ing_enf.jsp?fg=NIEN&cds="+cds+"&fechaAudit="+fechaAudit+"&cdsDesc="+cdsDesc+"&fechaIngEgr="+fechaIngEgr); break;
	   case "2": abrir_ventana("../expediente/print_nota_ing_enf.jsp?fg=NEEN&cds="+cds+"&fechaAudit="+fechaAudit+"&cdsDesc="+cdsDesc+"&fechaIngEgr="+fechaIngEgr); break;
	   case "3": abrir_ventana("../expediente/print_nota_ing_enf.jsp?fg=NIPA&cds="+cds+"&fechaAudit="+fechaAudit+"&cdsDesc="+cdsDesc+"&fechaIngEgr="+fechaIngEgr); break;
	   case "4": abrir_ventana("../expediente/print_nota_ing_enf.jsp?fg=NINO&cds="+cds+"&fechaAudit="+fechaAudit+"&cdsDesc="+cdsDesc+"&fechaIngEgr="+fechaIngEgr); break;
	   case "5": abrir_ventana("../expediente/print_nota_ing_enf.jsp?fg=NENO&cds="+cds+"&fechaAudit="+fechaAudit+"&cdsDesc="+cdsDesc+"&fechaIngEgr="+fechaIngEgr); break;
	   default: "";
	 }
	 
   });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REPORTE DE AUDITORIA DEL EXPEDIENTE"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td><table align="center" width="75%" cellpadding="1" cellspacing="1">
        <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
        <tr class="TextHeader">
          <td colspan="2"><cellbytelabel>Reporte de Auditor&iacute;a del Expediente</cellbytelabel></td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Sala</cellbytelabel></td>
          <td><%=fb.select(ConMgr.getConnection(), "select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio order by descripcion", "cds", "",false,false,0,"")%></td>
        </tr>
        <tr class="TextRow01">
          <td colspan="2">
		  <cellbytelabel>Fecha Auditor&iacute;a</cellbytelabel>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fechaAudit" />
          <jsp:param name="valueOfTBox1" value="<%=fecha.substring(0,10)%>" />
          </jsp:include>
		  &nbsp;&nbsp;
		  <cellbytelabel>Fecha Ingreso/Egreso</cellbytelabel>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fechaIngEgr" />
          <jsp:param name="valueOfTBox1" value="<%=fecha.substring(0,10)%>" />
          </jsp:include>
          </td>
        </tr>
		<tr class="TextHeader">
          <td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
        </tr>
        <tr class="TextRow01">
          <td colspan="2">
		     
			 <input type="radio" class="rpt" name="rpt" id="rpt1" value="1" />
			 <label for="rpt1"><cellbytelabel>Reporte Notas de Ingreso de Enfermer&iacute;a </cellbytelabel></label>
			 <br />
			 <input type="radio" class="rpt" name="rpt" id="rpt2"  value="2" />
			 <label for="rpt2"><cellbytelabel>Reporte Notas de Egreso de Enfermer&iacute;a </cellbytelabel></label>
			 <br />
			 <input type="radio" class="rpt" name="rpt" id="rpt3"  value="3" />
			 <label for="rpt3"><cellbytelabel>Reporte Notas de Ingreso Partos</cellbytelabel></label><br />
			 <input type="radio" class="rpt" name="rpt" id="rpt4"  value="4" />
			 <label for="rpt4"><cellbytelabel>Reporte Notas de Ingreso Neonatolog&iacute;a</cellbytelabel></label><br />
			 <input type="radio" class="rpt" name="rpt" id="rpt5"  value="5" />
			 <label for="rpt5"><cellbytelabel>Reporte Notas de Egreso Neonatolog&iacute;a</cellbytelabel></label>
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
%>
