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
900025	VER LISTA DE DETALLES
900027	AGREGAR DETALLE
900028	MODIFICAR DETALLE
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String date= CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String suesp=request.getParameter("suesp");
String espec=request.getParameter("espec");
String detalle=request.getParameter("detalle");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		//id = "0";
		cdo.addColValue("codigo_detalle","0");
	}
	else
	{
		//if (id == null) throw new Exception("El Detalle no es válido. Por favor intente nuevamente!");
		
sql = "select a.codigo_detalle as codigo_detalle, a.codigo_subesp as codeco,a.cod_clasif as codeclasificacion,a.cod_compania, a.cod_espec as cod, a.descripcion as nombre, b.codigo_espec as especificacion,b.cta_control as control, b.descripcion as nomb,c.cod_clasif as codes, c.descripcion  as nameclasificacion from tbl_con_detalle a, tbl_con_especificacion b,tbl_con_clasif_hacienda c where a.codigo_subesp =b.codigo_espec and  a.cod_espec =  b.cta_control and  a.cod_clasif=c.cod_clasif(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_espec='"+espec+"' and a.codigo_subesp='"+suesp+"' and a.codigo_detalle="+detalle;
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
document.title="Detalle - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Detalle - Edición - "+document.title;
<%}%>
</script>
<script language="javascript">
function add()
{
abrir_ventana1('../activos/list_especificacion.jsp');
}

function hacienda()
{
abrir_ventana1('../activos/list_clasificacion.jsp?id=2');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DETALLE"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
			
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("espec",espec)%>
			<%=fb.hidden("suesp",suesp)%>					
			<%=fb.hidden("detalle",detalle)%>	
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;Codificador de Cuentas</td>
				</tr>	
				<tr class="TextRow01" >
					<td width="10%">&nbsp;C&oacute;digo</td>
					<td width="90%"><%=fb.textBox("codeespec",cdo.getColValue("cod"),true,false,true,10)%>
					<%=fb.textBox("codesubesp",cdo.getColValue("codeco"),true,false,true,10)%>
					<%=fb.textBox("name",cdo.getColValue("nomb"),false,false,true,30)%>
					<%if(mode.equals("add")){%>
					<%=fb.button("btnespec",".:.",true,false,null,null,"onClick=\"javascript:add();\"")%>
					<%} else if(mode.equals("edit")){%>
					<%}%>
					</td>				
				</tr>								
				<tr class="TextHeader">
					<td colspan="2" class="">&nbsp;Generales de Detalle</td>
				</tr>					
				<tr>
					<td colspan="2">
							<table width="100%" cellpadding="0" cellspacing="1">
								<tr class="TextRow01">
									<td width="20%">&nbsp;Codigo</td>
									<td width="80%">&nbsp;<%=cdo.getColValue("codigo_detalle")%></td>									
								</tr>
								<tr class="TextRow01">
									<td>&nbsp;Descripci&oacute;n</td>
									<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,45)%></td>
								</tr>
								<%--<tr class="TextRow01">
									<td>&nbsp;% de Depreciaci&oacute;n</td>
									<td><%//=fb.decPlusZeroBox("depreciacion",cdo.getColValue("depreciacion"),false,false,false,10)%></td>									
								</tr>
								<tr class="TextRow01">
									<td>&nbsp;% de Mejora</td>
									<td><%//=fb.decPlusZeroBox("mejora",cdo.getColValue("mejora"),false,false,false,10)%></td>
								</tr>--%>
								<tr class="TextRow01">
									<td>&nbsp;Clasificaci&oacute;n</td>
									<td><%=fb.intBox("codeclasificacion",cdo.getColValue("codeclasificacion"),false,false,true,10)%>
									<%=fb.textBox("nameclasificacion",cdo.getColValue("nameclasificacion"),false,false,true,30)%>
									<%=fb.button("btnespec",".:.",true,false,null,null,"onClick=\"javascript:hacienda();\"")%>
									</td>
								</tr>
						</table>
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
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_con_detalle");
  cdo.addColValue("cod_espec",request.getParameter("codeespec"));
  cdo.addColValue("codigo_subesp",request.getParameter("codesubesp")); 	
  cdo.addColValue("descripcion",request.getParameter("nombre"));
  cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
  if (request.getParameter("codeclasificacion") != null)
  cdo.addColValue("cod_clasif",request.getParameter("codeclasificacion"));
  
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncCol("codigo_detalle");
	cdo.setAutoIncWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and cod_espec="+request.getParameter("codeespec")+" and codigo_subesp="+request.getParameter("codesubesp"));
	
	SQLMgr.insert(cdo);
  }
  else
  {
cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and cod_espec='"+request.getParameter("espec")+"' and  codigo_subesp='"+request.getParameter("suesp")+"' and codigo_detalle="+detalle);
//cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId"));

 %><%
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/activos/detalle_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/activos/detalle_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/activos/detalle_list.jsp';
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