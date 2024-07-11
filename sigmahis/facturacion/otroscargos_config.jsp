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
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String code=request.getParameter("code");
String tipoCode=request.getParameter("tipoCode");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if (mode.equals("")) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
		
		if (tipoCode == null) throw new Exception("El Tipo de Otro Cargo no es válido. Por favor intente nuevamente!");
	}
	else
	{
		if (code == null) throw new Exception("El Código de Otro Cargo no es válido. Por favor intente nuevamente!");
		if (tipoCode == null) throw new Exception("El Tipo de Otro Cargo no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.descripcion, a.precio, a.costo, a.tipo_servicio as tipoServCode, b.descripcion as tipoServ, c.descripcion as tipo, a.activo_inactivo as estado FROM tbl_fac_otros_cargos a, tbl_cds_tipo_servicio b, tbl_fac_tipo_otros c WHERE a.tipo_servicio=b.codigo and a.codigo_tipo=c.codigo and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.codigo_tipo="+tipoCode+" and a.codigo="+code;
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
document.title=" Otros Cargos Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Otros Cargos Edición - "+document.title;
<%}%>

function addTipoServ()
{
  abrir_ventana2('../admision/habitacion_tiposervicio_list.jsp?id=3');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACIÓN - MANTENIMIENTO - OTROS CARGOS "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("tipoCode",tipoCode)%>
			
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="50%"><%=code%></td>
					<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="25%"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
				</tr>
				<tr class="TextRow01">
				    <td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>	
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,60)%></td>	
					<td><cellbytelabel>Precio</cellbytelabel></td>	
					<td><%=fb.decBox("precio",cdo.getColValue("precio"),false,false,false,11)%></td>			
				</tr>							
				<tr class="TextRow01">
				    <td><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
 			        <td colspan="3"><%=fb.textBox("tipoServCode",cdo.getColValue("tipoServCode"),true,false,true,5)%><%=fb.textBox("tipoServ",cdo.getColValue("tipoServ"),true,false,true,50)%><%=fb.button("btnTipoServ","...",true,false,null,null,"onClick=\"javascript:addTipoServ()\"")%></td>					
				</tr>
				<tr>
					<td colspan="4">
						<jsp:include page="../common/bitacora.jsp" flush="true">
							<jsp:param name="audTable" value="tbl_fac_otros_cargos"></jsp:param>
							<jsp:param name="audFilter" value="<%="codigo="+code+" and compania="+(String) session.getAttribute("_companyId")%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>									
                <tr class="TextRow02">
					<td align="right" colspan="4">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
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
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  cdo = new CommonDataObject();
  code = request.getParameter("code");
  tipoCode = request.getParameter("tipoCode");

  cdo.setTableName("tbl_fac_otros_cargos");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));  
  cdo.addColValue("activo_inactivo",request.getParameter("estado"));
  cdo.addColValue("precio",""+request.getParameter("precio"));
  cdo.addColValue("tipo_servicio",request.getParameter("tipoServCode"));  
  
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("codigo_tipo",tipoCode);    
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("codigo");
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("code")+"and compania="+(String) session.getAttribute("_companyId"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/otroscargos_list.jsp?tipoCode="+tipoCode))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/otroscargos_list.jsp?tipoCode="+tipoCode)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/otroscargos_list.jsp?tipoCode=<%=tipoCode%>';
<%
	}
	
	if (saveOption.equalsIgnoreCase("N"))																					
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&tipoCode=<%=tipoCode%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>