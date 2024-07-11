<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
int lastLineNo = 0;

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle de Factura con Pagos - '+document.title;
function doAction(){newHeight();}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("lastLineNo",""+lastLineNo)%>
				<%=fb.hidden("keySize",""+HashDet.size())%>
        <tr class="TextHeader" align="center">
          <td width="5%"><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
          <td width="10%"><cellbytelabel>F. Ingreso</cellbytelabel></td>
          <td width="10%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
          <td width="25%"><cellbytelabel>Centro</cellbytelabel></td>
          <td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
          <td width="10%"><cellbytelabel>Factura</cellbytelabel></td>
          <td width="5%"><cellbytelabel>Tipo</cellbytelabel></td>
        </tr>
        <%
					String js = "";
				String fechaIngreso = "";
					al = CmnMgr.reverseRecords(HashDet);
					for (int i = 1; i <= HashDet.size(); i++)
					{
					key = al.get(i - 1).toString();
						CommonDataObject cdo2 = (CommonDataObject) HashDet.get(key);
					fechaIngreso = "fechaIngreso"+i;
				%>
        <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>
          <td align="center"><%=cdo2.getColValue("secuencia")%></td>
          <td align="center"><%=cdo2.getColValue("fecha_ingreso")%></td>
          <td align="center"><%=cdo2.getColValue("categoria_desc")%></td>
          <td><%=cdo2.getColValue("centroServicio")%></td>
          <td align="center"><%=cdo2.getColValue("estado_desc")%></td>
          <td align="center"><%=cdo2.getColValue("num_factura")%></td>
          <td align="center"><%=cdo2.getColValue("conta_cred_desc")%></td>
        </tr>
        <%
				}
			%>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</body>
</html>
<%
}//GET
else
{
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
parent.document.formRecibo.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
