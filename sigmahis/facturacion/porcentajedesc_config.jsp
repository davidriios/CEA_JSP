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
================================================================================
600019	AGREGAR PORCENTAJE DE DESCUENTO
600020	MODIFICAR PORCENTAJE DE DESCUENTO
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String centroCode = request.getParameter("centro");
String tipoServCode = request.getParameter("tipoServ");
String catCode = request.getParameter("cat");
String tipoCode = request.getParameter("tipo");
String filter = "";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	   sql = "SELECT valor, tipo_valor FROM tbl_fac_tipo_descuento WHERE codigo="+tipoCode+" and compania="+(String) session.getAttribute("_companyId");
	   cdo = SQLMgr.getData(sql);
	}
	else
	{
		
				if (centroCode == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
				if (tipoServCode == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");
				if (catCode == null) throw new Exception("La Categor&iacute;a no es válida. Por favor intente nuevamente!");
				if (tipoCode == null) throw new Exception("El Tipo de Descuento no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.tipo_servicio as tipoServCode, b.descripcion as tipoServ, a.categoria as catCode, c.descripcion as cat, a.cds_codigo as centroCode, d.descripcion as centro, a.tipo_descuento as tipoCode, e.descripcion as desc_descuento, a.desc_individual as individual, a.monto, a.tipo FROM tbl_fac_porcentaje_desc a, tbl_cds_tipo_servicio b, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d, tbl_fac_tipo_descuento e WHERE a.tipo_servicio=b.codigo and a.categoria=c.codigo and a.cds_codigo=d.codigo and a.tipo_descuento=e.codigo and a.compania=e.compania   and a.tipo_servicio="+tipoServCode+" and a.categoria="+catCode+" and a.cds_codigo="+centroCode +"and a.tipo_descuento="+tipoCode+" and a.compania="+(String) session.getAttribute("_companyId")+filter;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Porcentajes de Descuentos Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Porcentajes de Descuentos Edición - "+document.title;
<%}%>

function addCentro()
{
   abrir_ventana2('../admision/habitacion_centroservicio_list.jsp?id=2&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
function addTipoServ()
{
   abrir_ventana2('../admision/habitacion_tiposervicio_list.jsp?id=2');
}
function addCat()
{
   abrir_ventana2('porcentajedesc_categoria_list.jsp?id=1');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>			
			<%=fb.hidden("tipoCode",tipoCode)%>
			
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td width="85%"><%=fb.textBox("centroCode",centroCode,true,false,true,5)%><%=fb.textBox("centro",cdo.getColValue("centro"),true,false,true,30)%><%=fb.button("btnCentro","...",true,(!mode.trim().equals("add")),null,null,"onClick=\"javascript:addCentro()\"")%></td>				
				</tr>							
				<tr class="TextRow01">
				    <td><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
 			        <td><%=fb.textBox("tipoServCode",tipoServCode,true,false,true,5)%><%=fb.textBox("tipoServ",cdo.getColValue("tipoServ"),true,false,true,30)%><%=fb.button("btnTipoServ","...",true,(!mode.trim().equals("add")),null,null,"onClick=\"javascript:addTipoServ()\"")%></td>					
				</tr>
				<tr class="TextRow01">
				    <td><cellbytelabel>Categor&iacute;a Admisi&oacute;n</cellbytelabel></td>
 			        <td><%=fb.textBox("catCode",catCode,true,false,true,5)%><%=fb.textBox("cat",cdo.getColValue("cat"),true,false,true,30)%><%=fb.button("btnCat","...",true,(!mode.trim().equals("add")),null,null,"onClick=\"javascript:addCat()\"")%></td>					
				</tr>						
				<tr class="TextRow01">
					<td><cellbytelabel>Desc. Individual</cellbytelabel></td>
					<td><%=fb.select("individual","N=No,S=Sí",cdo.getColValue("individual"))%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Tipo Valor</cellbytelabel></td>
					<td><%=fb.select("tipo","P=PORCENTAJE,M=MONEDA",cdo.getColValue("tipo"))%>&nbsp; 
						<%=fb.decBox("monto",cdo.getColValue("monto"),true,false,false,15,10.2)%></td>
				</tr>
                <tr class="TextRow02">
			        <td colspan="2" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  tipoServCode = request.getParameter("tipoServCode");
  catCode = request.getParameter("catCode");
  centroCode = request.getParameter("centroCode");
  tipoCode = request.getParameter("tipoCode");
  
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_fac_porcentaje_desc");
  cdo.addColValue("tipo_servicio",tipoServCode);  
  cdo.addColValue("categoria",catCode);
  cdo.addColValue("cds_codigo",centroCode);
  cdo.addColValue("desc_individual",request.getParameter("individual"));
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	 
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName")); 
  cdo.addColValue("monto",request.getParameter("monto"));
  cdo.addColValue("tipo",request.getParameter("tipo"));
  
  if (mode.equalsIgnoreCase("add"))
  { 
    cdo.addColValue("tipo_descuento",tipoCode);
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	 
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	//cdo.setAutoIncWhereClause("tipo_descuento="+request.getParameter("tipoCode")+" and compania="+(String) session.getAttribute("_companyId"));

	SQLMgr.insert(cdo);
  }
  else
  { 
    cdo.setWhereClause("tipo_servicio='"+tipoServCode+"' and categoria="+catCode+" and cds_codigo="+centroCode+" and tipo_descuento="+tipoCode+" and compania="+(String) session.getAttribute("_companyId"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/porcentajedesc_list.jsp?tipoCode="+tipoCode))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/porcentajedesc_list.jsp?tipoCode="+tipoCode)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/porcentajedesc_list.jsp?tipoCode=<%=tipoCode%>';
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