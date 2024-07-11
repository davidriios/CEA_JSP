<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
500035	AGREGAR TIPO DE HABITACION
500036	MODIFICAR TIPO DE HABITACION
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500035") || SecMgr.checkAccess(session.getId(),"500036"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String compId = request.getParameter("compId");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
        fechaCrea = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userCrea = UserDet.getUserName(); //UserDet.getUserEmpId(); //mandaba error de que no se puede guardar username en blanco
		fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userMod = UserDet.getUserName(); //UserDet.getUserEmpId();
		
		//manda NAN cuando mode = add ya que getFormattedDecimal() esta recibiendo null
		cdo.addColValue("precio","0");
		cdo.addColValue("costo","0");
	}
	else
	{
		if (code == null) throw new Exception("El Tipo de Habitación no es válido. Por favor intente nuevamente!");

        fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userMod = UserDet.getUserEmpId();
		 
		sql = "SELECT codigo, compania, descripcion, categoria_hab as categoria, tipo_valor as tipoValor, nvl(precio,0) precio, nvl(costo,0) costo, estatus FROM tbl_sal_tipo_habitacion WHERE compania="+compId+" and codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Tipo de Habitación Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Tipo de Habitación Edición - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNICA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("compId",compId)%>
			<%=fb.hidden("userCrea",userCrea)%>
			<%=fb.hidden("userMod",userMod)%>
			<%=fb.hidden("fechaCrea",fechaCrea)%>
			<%=fb.hidden("fechaMod",fechaMod)%>
			
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="12%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
				<td width="38%"><%=code%></td>
				<td width="12%"><cellbytelabel id="2">Precio</cellbytelabel></td>
				<td width="38%"><%=fb.decBox("precio",CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),true,false,false,45)%></td>				
			</tr>							
			<tr class="TextRow01">
				<td><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
				<td><cellbytelabel id="4">Costo</cellbytelabel></td>
				<td><%=fb.decBox("costo",CmnMgr.getFormattedDecimal(cdo.getColValue("costo")),false,false,false,45)%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel id="5">Categor&iacute;a</cellbytelabel></td>
				<td><%=fb.select("categoria","P=Privada,S=Semi-Privada,E=Económica,T=Suite,Q=Quirofano,O=Otros",cdo.getColValue("categoria"))%></td>
				<td><cellbytelabel id="6">Tipo Valor</cellbytelabel></td>
				<td><%=fb.select("tipoValor","D=Diario,H=Hora,T=Tarifa",cdo.getColValue("tipoValor"))%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel id="">Estatus</cellbytelabel></td>
				<td colspan="3"><%=fb.select("estatus","A=Activo,I=Inactivo",cdo.getColValue("estatus"))%></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_sal_tipo_habitacion"); 
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("tipo_valor",request.getParameter("tipoValor"));
  cdo.addColValue("precio",request.getParameter("precio"));
  cdo.addColValue("costo",request.getParameter("costo"));
  cdo.addColValue("categoria_hab",request.getParameter("categoria"));
  //cdo.addColValue("usuario_creacion",request.getParameter("userCrea"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  //cdo.addColValue("fecha_creacion",request.getParameter("fechaCrea"));
  cdo.addColValue("fecha_modificacion",request.getParameter("fechaMod"));
  cdo.addColValue("estatus",request.getParameter("estatus"));
  
  if (mode.equalsIgnoreCase("add"))
  {	
    cdo.addColValue("usuario_creacion",request.getParameter("userCrea"));
	cdo.addColValue("fecha_creacion",request.getParameter("fechaCrea"));
		
	cdo.addColValue("compania",request.getParameter("compId")); 
    cdo.setAutoIncCol("codigo");
	cdo.setAutoIncWhereClause("compania="+request.getParameter("compId"));	
	SQLMgr.insert(cdo);
	
  }
  else
  {
    cdo.setWhereClause("compania="+request.getParameter("compId")+" and codigo="+request.getParameter("code"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/tipohabitacion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/tipohabitacion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/tipohabitacion_list.jsp';
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