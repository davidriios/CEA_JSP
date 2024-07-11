<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetalleTransFormaPagos"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String sql = "";
if(anio==null) anio = "";
if(codigo==null) codigo = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

      if(!anio.equals("") && !codigo.equals("")){
				sql = " select a.fp_codigo, a.tipo_tarjeta, a.tipo_banco, a.monto, a.num_cheque, a.descripcion_banco, b.descripcion fp_codigo_desc, c.descripcion tipo_tarjeta_desc, decode(a.tipo_banco, 'L', 'LOCAL', 'E', 'EXTRANJERO') tipo_banco_desc FROM  tbl_cja_trans_forma_pagos a, tbl_cja_forma_pago b, tbl_cja_tipo_tarjeta c WHERE a.fp_codigo = b.codigo(+) and a.tipo_tarjeta = c.codigo(+) and a.compania = "+(String) session.getAttribute("_companyId")+" and a.tran_anio = "+anio+" and a.tran_codigo = "+codigo;
				al = SQLMgr.getDataList(sql);
			}

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Formas de Pago - '+document.title;
function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function setBAction(fName,actionValue){
}

function addBilletes(){ 
  abrir_ventana2('../caja/billetes_list.jsp?');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"><!-- onLoad="javascript:formCredito()"-->
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="FORMAS DE PAGO"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableBorder">

<table align="center" width="100%" cellpadding="0" cellspacing="1">   
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<tr class="TextHeader" align="center">
  <td width="15%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
  <td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
  <td width="20%"><cellbytelabel>Tarjetas de Cr&eacute;dito </cellbytelabel></td>
  <td width="10%"><cellbytelabel>Num Cheque</cellbytelabel> </td>                  
  <td width="20%"><cellbytelabel>Banco</cellbytelabel></td>
  <td width="10%"><cellbytelabel>Tipo Banco</cellbytelabel></td>
</tr>
<%
for (int i = 0; i < al.size(); i++) {
  CommonDataObject dtfp = (CommonDataObject) al.get(i);
%>
<tr class="TextRow01">
  <td><%=dtfp.getColValue("fp_codigo_desc")%> </td>
  <td><%=CmnMgr.getFormattedDecimal(dtfp.getColValue("monto"))%></td>
  <td><%=dtfp.getColValue("tipo_tarjeta_desc")%> </td>
  <td><%=dtfp.getColValue("num_cheque")%> </td>
  <td><%=dtfp.getColValue("descripcion_banco")%> </td>
  <td><%=dtfp.getColValue("tipo_banco_desc")%> </td>
</tr>
<%  }  %>
 <tr class="TextRow01">
   <td colspan="7" align="right">
   <%=fb.button("cancel","Cerrar",true,false,"Text10",null,"onClick=\"javascript:window.close()\"")%>
   </td>
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
%>