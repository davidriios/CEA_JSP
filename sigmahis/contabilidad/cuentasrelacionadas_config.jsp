<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200019") || SecMgr.checkAccess(session.getId(),"200020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();	
String sql = "";
String mode = request.getParameter("mode");
String secuencia = request.getParameter("secuencia");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String codigo = request.getParameter("codigo");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		secuencia = "0";
		cta1 = "";
		cta2 = "";
		cta3 = "";
		cta4 = "";
		cta5 = "";
		cta6 = "";
		codigo = "0";	
	}
	else
	{
		if (secuencia == null) throw new Exception("La Secuencia no es válida. Por favor intente nuevamente!");
		if (cta1 == null || cta2 == null || cta3 == null || cta4 == null || cta5 == null || cta6 == null) throw new Exception("La Cuenta Financiera no es válida. Por favor intente nuevamente!");
		if (codigo == null) throw new Exception("El Tipo de Otros Cargos no es válido. Por favor intente nuevamente!");

		sql = "SELECT b.descripcion as tipoOtro, a.cta1_a, a.cta2_a, a.cta3_a, a.cta4_a, a.cta5_a, a.cta6_a, c.descripcion as cuenta, d.descripcion cuentaDesc FROM tbl_fac_otros_x_cuenta a, tbl_fac_tipo_otros b, tbl_con_catalogo_gral c, tbl_con_catalogo_gral d WHERE a.codigo=b.codigo and a.compania=b.compania and a.cta1=c.cta1 and a.cta2=c.cta2 and a.cta3=c.cta3 and a.cta4=c.cta4 and a.cta5=c.cta5 and a.cta6=c.cta6 and a.cta1_a=d.cta1(+) and a.cta2_a=d.cta2(+) and a.cta3_a=d.cta3(+) and a.cta4_a=d.cta4(+) and a.cta5_a=d.cta5(+) and a.cta6_a=d.cta6(+) and a.compania=c.compania and a.compania=d.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.secuencia="+secuencia+" and a.cta1="+cta1+" and a.cta2="+cta2+" and a.cta3="+cta3+" and a.cta4="+cta4+" and a.cta5="+cta5+" and a.cta6="+cta6+" and a.codigo="+codigo;
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Cuentas Relacionadas a Tipos Otros Cargos Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cuentas Relacionadas a Tipos Otros Cargos Edición - "+document.title;
<%}%>

function addTipo()
{
   abrir_ventana1('cuentarela_tiposotros_list.jsp?id=1');
}
function addCtaFina()
{
   abrir_ventana1('ctabancaria_catalogo_list.jsp?id=13');
}
function addCtaDesc()
{
   abrir_ventana1('ctabancaria_catalogo_list.jsp?id=14');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("secuencia",secuencia)%>
		
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01">
				<td width="20%">Tipo Otros Cargos</td>
				<td width="80%"><%=fb.intBox("codigo",codigo,true,false,true,11)%><%=fb.textBox("tipoOtro",cdo.getColValue("tipoOtro"),false,false,true,75)%><%=fb.button("btntipo","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:addTipo()\"")%></td>				
			</tr>
			<tr class="TextRow01">
				<td>Cuenta Financiera</td>
				<td><%=fb.textBox("cta1",cta1,true,false,true,3)%><%=fb.textBox("cta2",cta2,true,false,true,3)%><%=fb.textBox("cta3",cta3,true,false,true,3)%><%=fb.textBox("cta4",cta4,true,false,true,3)%><%=fb.textBox("cta5",cta5,true,false,true,3)%><%=fb.textBox("cta6",cta6,true,false,true,3)%><%=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,38)%><%=fb.button("btnctafina","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:addCtaFina()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Cuenta Descuento</td>
				<td><%=fb.textBox("cta1_a",cdo.getColValue("cta1_a"),false,false,true,3)%><%=fb.textBox("cta2_a",cdo.getColValue("cta2_a"),false,false,true,3)%><%=fb.textBox("cta3_a",cdo.getColValue("cta3_a"),false,false,true,3)%><%=fb.textBox("cta4_a",cdo.getColValue("cta4_a"),false,false,true,3)%><%=fb.textBox("cta5_a",cdo.getColValue("cta5_a"),false,false,true,3)%><%=fb.textBox("cta6_a",cdo.getColValue("cta6_a"),false,false,true,3)%><%=fb.textBox("cuentaDesc",cdo.getColValue("cuentaDesc"),false,false,true,43)%><%=fb.button("btnctadesc","...",true,false,null,null,"onClick=\"javascript:addCtaDesc()\"")%></td>
			</tr>	
			<tr>
				<td colspan="2">
					<jsp:include page="../common/bitacora.jsp" flush="true">
					<jsp:param name="audTable" value="tbl_fac_otros_x_cuenta"></jsp:param>
					<jsp:param name="audFilter" value="<%="compania="+(String) session.getAttribute("_companyId")+" and codigo="+codigo+" and secuencia="+secuencia+" and cta1="+cta1+" and cta2="+cta2+" and cta3="+cta3+" and cta4="+cta4+" and cta5="+cta5+" and cta6="+cta6%>"></jsp:param>
					</jsp:include>
				</td>
			</tr>				
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="2">&nbsp;</td>
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
  cta1 = request.getParameter("cta1");
  cta2 = request.getParameter("cta2");
  cta3 = request.getParameter("cta3");
  cta4 = request.getParameter("cta4");
  cta5 = request.getParameter("cta5");
  cta6 = request.getParameter("cta6");
  secuencia = request.getParameter("secuencia");
  codigo = request.getParameter("codigo");

  cdo = new CommonDataObject();

  cdo.setTableName("tbl_fac_otros_x_cuenta");
  if (request.getParameter("cta1_a") != null)
  cdo.addColValue("cta1_a",request.getParameter("cta1_a"));
  if (request.getParameter("cta2_a") != null)
  cdo.addColValue("cta2_a",request.getParameter("cta2_a"));
  if (request.getParameter("cta3_a") != null)
  cdo.addColValue("cta3_a",request.getParameter("cta3_a"));
  if (request.getParameter("cta4_a") != null)
  cdo.addColValue("cta4_a",request.getParameter("cta4_a"));
  if (request.getParameter("cta5_a") != null)
  cdo.addColValue("cta5_a",request.getParameter("cta5_a"));
  if (request.getParameter("cta6_a") != null)
  cdo.addColValue("cta6_a",request.getParameter("cta6_a"));   
  
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("cta1",cta1);  
 	cdo.addColValue("cta2",cta2);  
  	cdo.addColValue("cta3",cta3);  
  	cdo.addColValue("cta4",cta4);  
  	cdo.addColValue("cta5",cta5);  
    cdo.addColValue("cta6",cta6);
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
    cdo.addColValue("codigo",codigo);
    cdo.setAutoIncCol("secuencia");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("secuencia="+secuencia+" and cta1="+cta1+" and cta2="+cta2+" and cta3="+cta3+" and cta4="+cta4+" and cta5="+cta5+" and cta6="+cta6+" and codigo="+codigo+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/cuentasrelacionadas_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/cuentasrelacionadas_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/cuentasrelacionadas_list.jsp';
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