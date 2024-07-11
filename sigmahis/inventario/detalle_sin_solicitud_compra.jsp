
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="detalle" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("detalle",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Detalle - '+document.title;
function addTipo(i)
{
  abrir_ventana1('');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>		
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			    
			   <tr class="TextHeader">
			   	<td colspan="12" align="right"><%=fb.button("btnAgregar","Agregar",true,false,null,null,null)%></td>
			   </tr>
			   <tr class="TextHeader" align="center">
					<td colspan="3" class="Text10">Código</td>
					<td class="Text10">Descripci&oacute;n</td>
					<td class="Text10">Cant. Fac&nbsp;</td>
					<td class="Text10">Cant. Rec&nbsp;</td>						
					<td class="Text10">Und.</td>
					<td class="Text10">Art. x Und.</td>
					<td class="Text10">Costo</td>
					<td class="Text10">Var</td>
					<td class="Text10">Total</td>
					<td class="Text10">&nbsp;</td>
				</tr>	
<!--				<tr class="TextRow01">
					<td width="5%">000</td>
					<td width="5%">123</td>
					<td width="5%">84597</td>
					<td width="33%">Compra de Equipo Psado</td>
					<td width="6%">125.25</td>
					<td width="6%">125</td>
					<td width="6%">50</td>
					<td width="6%">1025</td>
					<td width="8%">1532.25</td>
					<td width="5%">Na</td>
					<td width="8%">12616.25</td>
					<td width="10%"><%=fb.button("btnElminar","Eliminar",true,false,null,null,null)%></td>
				</tr>
				<tr class="TextRow01">
					<td>000</td>
					<td>123</td>
					<td>84597</td>
					<td>Compra de Equipo Psado</td>
					<td>125.25</td>
					<td>125</td>
					<td>50</td>
					<td>1025</td>
					<td>1532.25</td>
					<td>Na</td>
					<td>12616.25</td>
					<td><%=fb.button("btnElminar","Eliminar",true,false,null,null,null)%></td>
				</tr>	
					
-->	
				<tr class="TextRow01">
					<td width="6%">&nbsp;</td>
					<td width="6%">&nbsp;</td>
					<td width="6%">&nbsp;</td>
					<td width="33%">&nbsp;</td>
					<td width="5%">&nbsp;</td>
					<td width="5%">&nbsp;</td>
					<td width="5%">&nbsp;</td>
					<td width="6%">&nbsp;</td>
					<td width="8%">&nbsp;</td>
					<td width="5%">&nbsp;</td>
					<td width="8%"></td>
					<td width="10%" align="center"><%=fb.button("btnElminar","X",true,false,null,null,null)%></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="10" align="right">Sub.Total1&nbsp;</td>
					<td></td>
					<td><%=fb.intBox("subtotal",cdo.getColValue("subtotal"), false,false,false,5)%></td>
				</tr>	
				<tr class="TextRow01">
					<td align="right" colspan="6">Total de la Factura&nbsp;</td>
					<td colspan="2"><%=fb.intBox("subtotal",cdo.getColValue("subtotal"), false,false,false,10)%></td>
					<td>&nbsp;</td>
					<td align="right">Descuento&nbsp;</td>
					<td>&nbsp;<%=fb.intBox("desc",cdo.getColValue("desc"), false,false,false,1 )%>%</td>
					<td><%=fb.intBox("subtotal",cdo.getColValue("subtotal"), false,false,false,5)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right" colspan="6">Ajuste&nbsp;</td>
					<td colspan="3">&nbsp;</td>
					
					<td align="right">Sub.Total2&nbsp;</td>
					<td>&nbsp;</td>
					<td><%=fb.intBox("subtotal2",cdo.getColValue("subtotal2"), false,false,false,5)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right" colspan="10">Total&nbsp;</td>
					<td>&nbsp;</td>
					<td><%=fb.intBox("subtotal2",cdo.getColValue("subtotal2"), false,false,false,5)%></td>
				</tr>						 	
            <%=fb.formEnd(true)%>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
