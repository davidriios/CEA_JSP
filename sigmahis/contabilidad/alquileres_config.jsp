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
900075	AGREGAR ALQUILER
900076	MODIFICAR ALQUILER
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900075") || SecMgr.checkAccess(session.getId(),"900076"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";		
	}
	else
	{
		if (id == null) throw new Exception("El Alquiler no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.cod_alquiler as codigo, a.descripcion, a.cod_tipo_alq as tipoCode, b.descripcion as tipo, a.estatus, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, nvl(a.ubicacion_cons,'0') as ubicacionCode, nvl(c.nombre,' ') as ubicacion, a.piso_cons as piso, a.consultorio FROM tbl_cxc_alquileres a, tbl_cxc_tipo_alquiler b, tbl_cxc_ubicaciones c WHERE a.cod_tipo_alq=b.cod_tipo_alq and a.compania=b.compania and a.ubicacion_cons=c.ubicacion and a.cod_alquiler="+id+" and a.compania="+(String) session.getAttribute("_companyId");
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
document.title="Alquiler Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Alquiler Edición - "+document.title;
<%}%>

function addtipo()
{
   abrir_ventana1('alquiler_tipos_list.jsp');
}
function addcuenta()
{
   abrir_ventana1('ctabancaria_catalogo_list.jsp?id=7');
}
function addubic()
{
   abrir_ventana1('alquiler_ubicacion_list.jsp');
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
			<%=fb.hidden("id",id)%>
		
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>			
			<tr class="TextRow01">
				<td width="10%">C&oacute;digo</td>
				<td width="50%"><%=id%></td>	
				<td width="10%">Estado</td>
				<td width="30%"><%=fb.select("estatus","A=Libre,I=Ocupado",cdo.getColValue("estatus"))%></td>				
			</tr>							
			<tr class="TextRow01">
				<td>Descripci&oacute;n</td>
				<td colspan="3"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,58)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Tipo</td>
				<td colspan="3"><%=fb.textBox("tipoCode",cdo.getColValue("tipoCode"),false,false,false,5)%><%=fb.textBox("tipo",cdo.getColValue("tipo"),false,false,false,48)%><%=fb.button("btntipo","...",true,false,null,null,"onClick=\"javascript:addtipo()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Cuenta Contable</td>
				<td colspan="3"><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,false,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,false,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,false,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,false,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,false,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,false,3)%><%=fb.button("btncuenta","...",true,false,null,null,"onClick=\"javascript:addcuenta()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Ubicaci&oacute;n</td>
				<td><%=fb.textBox("ubicacionCode",cdo.getColValue("ubicacionCode"),false,false,false,5)%><%=fb.textBox("ubicacion",cdo.getColValue("ubicacion"),false,false,false,48)%><%=fb.button("btnubic","...",true,false,null,null,"onClick=\"javascript:addubic()\"")%></td>
				<td>Piso</td>
				<td><%=fb.textBox("piso",cdo.getColValue("piso"),false,false,false,8)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Consultorio</td>
				<td colspan="3"><%=fb.textBox("consultorio",cdo.getColValue("consultorio"),false,true,false,58)%></td>
			</tr>					
			<tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="4">&nbsp;</td>
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

  cdo.setTableName("tbl_cxc_alquileres");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("cod_tipo_alq",request.getParameter("tipoCode"));
  cdo.addColValue("ubicacion_cons",request.getParameter("ubicacionCode"));
  cdo.addColValue("piso_cons",request.getParameter("piso"));
  //cdo.addColValue("consultorio",request.getParameter("consultorio"));    
  cdo.addColValue("estatus",request.getParameter("estatus")); 
  cdo.addColValue("cta1",request.getParameter("cta1"));  
  cdo.addColValue("cta2",request.getParameter("cta2"));  
  cdo.addColValue("cta3",request.getParameter("cta3"));  
  cdo.addColValue("cta4",request.getParameter("cta4"));  
  cdo.addColValue("cta5",request.getParameter("cta5"));  
  cdo.addColValue("cta6",request.getParameter("cta6"));  
    
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
 	cdo.setAutoIncCol("cod_alquiler");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("cod_alquiler="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/alquileres_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/alquileres_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/alquileres_list.jsp';
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