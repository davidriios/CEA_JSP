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
if (code == null) code = "0";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		code = "0";
	}
	else{
		if (code == null) throw new Exception("El Parámetro Order Set no es válido. Por favor intente nuevamente!");

		sql = "SELECT DESCRIPCION, CODIGO_TIPO_OM, SUBTIPO, URL_ADD_PAGE, ESTADO, REQUIRE_EXTRA_INFO FROM TBL_OSET_TIPO_OM_CONFIG WHERE id = "+code;
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
document.title=" Parámetros Order Set Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Parámetros Order Set Edición - "+document.title;
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
					<td>
            <%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,80, 100)%>
					 </td>
				</tr>
				
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Tipo Orden</cellbytelabel></td>
					<td>
            <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from TBL_SAL_TIPO_ORDEN_MED order by 1","codigo_tipo_om",cdo.getColValue("codigo_tipo_om"),false,false,0,"",null,"",null,"S")%>
					 </td>
				</tr>
				
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Estado</cellbytelabel></td>
					<td>
            <%=fb.select("status","A=Activo, I=Inactivo",cdo.getColValue("status"),"")%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Sub Tipo
            <%=fb.select("subtipo","RIS=RIS,LIS=LIS,MED=MEDICAMENTO,NUT=DIETA,TRA=TRATAMIENTO,VAR=VARIAS,INT=INTERSONCULTA,BDS=BANCO DE SANGRE",cdo.getColValue("subtipo"),"S")%>
					 </td>
				</tr>
				
				<tr class="TextRow01">
					<td><cellbytelabel id="2">URL Agregar</cellbytelabel></td>
					<td>
            <%=fb.textBox("url_add_page",cdo.getColValue("url_add_page"),false,false,false,80, 100)%>
					 </td>
				</tr>
				
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Requiere extra info</cellbytelabel></td>
					<td>
            <%=fb.select("require_extra_info","N=NO,S=SI",cdo.getColValue("require_extra_info"),"")%>
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

</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  cdo = new CommonDataObject();
  code = request.getParameter("code");
   
  cdo.setTableName("TBL_OSET_TIPO_OM_CONFIG");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("estado",request.getParameter("status"));
  cdo.addColValue("codigo_tipo_om",request.getParameter("codigo_tipo_om"));
  cdo.addColValue("subtipo",request.getParameter("subtipo"));
  cdo.addColValue("url_add_page",request.getParameter("url_add_page"));
  cdo.addColValue("require_extra_info",request.getParameter("require_extra_info"));

  if (mode.equalsIgnoreCase("add")){
    cdo.addColValue("created_by", (String) session.getAttribute("_userName") );
    cdo.addColValue("date_created", cDateTime);
    
    cdo.setAutoIncCol("id");
    cdo.addPkColValue("id","");
    
    SQLMgr.insert(cdo);
    code = SQLMgr.getPkColValue("id");
  }
  else {
    cdo.addColValue("modified_by", (String) session.getAttribute("_userName") );
    cdo.addColValue("date_modified", cDateTime);
  
    cdo.setWhereClause("id = "+code);
	  SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/orderset/exp_oset_configs_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/orderset/exp_oset_configs_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/orderset/exp_oset_configs_list.jsp';
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