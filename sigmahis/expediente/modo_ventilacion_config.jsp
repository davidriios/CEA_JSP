<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo1 = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Codigo del Parametro no es válido. Por favor intente nuevamente!");

		sql = "select id, codigo, descripcion,orden, status from tbl_sal_modo_ventilacion where id = "+id;
		
		cdo1 = SQLMgr.getData(sql);

	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Modo Ventilacion - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Modo Ventilacion - Edición - "+document.title;
<%}%>

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Modo Ventilaci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="10%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							    <td width="35%"><%=fb.textBox("codigo",cdo1.getColValue("codigo"),true,false,viewMode,20,30)%></td>														
								<td width="15%"><cellbytelabel id="3">Nombre</cellbytelabel></td>
							    <td width="40%"><%=fb.textBox("descripcion",cdo1.getColValue("descripcion"),true,false,viewMode,50,100)%></td>	
							</tr>	
							<tr class="TextRow01">
								<td><cellbytelabel id="4">Orden</cellbytelabel></td>
							    <td><%=fb.textBox("orden",cdo1.getColValue("orden"),true,false,false,5,2)%>
								<%//=fb.select("tipo","R=RESPIRATORIOS,H=HEMODINAMICOS",cdo1.getColValue("tipo"),false,viewMode,0,"Text10",null,null,"","")%></td>	
								<td><cellbytelabel id="5">Estado</cellbytelabel></td>
							    <td><%//=fb.textBox("descripcion",cdo1.getColValue("descripcion"),true,false,false,50,100)%>
								<%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo1.getColValue("status"),false,viewMode,0,"Text10",null,null,"","")%></td>	
							</tr>
						</table>
					</td>
				</tr>
				
				
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="7">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="8">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="9">Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
 
  cdo1 = new CommonDataObject();
  cdo1.setTableName("tbl_sal_modo_ventilacion");
  cdo1.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo1.addColValue("status",request.getParameter("status")); 
  cdo1.addColValue("orden",request.getParameter("orden"));
  cdo1.addColValue("codigo",request.getParameter("codigo")); 

  if (mode.equalsIgnoreCase("add"))
  {
    
	 	cdo1.setAutoIncCol("id");
		cdo1.addPkColValue("id","");
		
	SQLMgr.insert(cdo1);
	id = SQLMgr.getPkColValue("id");
  }
  else
  {
   cdo1.setWhereClause("id="+request.getParameter("id"));

	SQLMgr.update(cdo1);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/modo_ventilacion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/modo_ventilacion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/modo_ventilacion_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>