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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("El Tipo de Alerg�a no es v�lido. Por favor intente nuevamente!");

		sql = "SELECT codigo, descripcion,nvl(es_alergia,'S')es_alergia, orden,es_default, status FROM tbl_sal_tipo_alergia WHERE codigo="+code+" order by orden";
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
document.title=" Tipo Alerg�a Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Tipo Alerg�a Edici�n - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="85%"><%=code%></td>				
				</tr>							
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,60)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Orden:
                    <%=fb.intBox("orden",cdo.getColValue("orden"),false,false,false,5,2)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Por defecto:
                    <%=fb.select("es_default","N=NO,S=SI",cdo.getColValue("es_default"),"")%>
                    </td>
				</tr>	
				<tr class="TextRow01">
					<td><cellbytelabel id="7">Es Alergia</cellbytelabel></td>
					<td><%=fb.select("es_alergia","S=SI, N=NO",cdo.getColValue("es_alergia"),"")%>
					
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado:
					<%=fb.select("status","A=Activo, I=Inactivo",cdo.getColValue("status"),"")%>
					</td>
				</tr>								
                <tr class="TextRow02">
					<td align="right" colspan="2">
						<cellbytelabel id="3">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="4">Crear Otro </cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel id="5">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="6">Cerrar</cellbytelabel> 
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
   
  cdo.setTableName("tbl_sal_tipo_alergia");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("activar_obs","N");
  cdo.addColValue("es_alergia",request.getParameter("es_alergia"));
  cdo.addColValue("orden",request.getParameter("orden"));
  cdo.addColValue("es_default",request.getParameter("es_default"));
  cdo.addColValue("status",request.getParameter("status"));

  if (mode.equalsIgnoreCase("add"))
  {
	cdo.setAutoIncCol("codigo");
	cdo.addPkColValue("codigo","");
	SQLMgr.insert(cdo);
    code = SQLMgr.getPkColValue("codigo");
  }
  else
  {
    cdo.setWhereClause("codigo="+code);

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/tipoalergia_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/tipoalergia_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/tipoalergia_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>