<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%> 
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id")==null?"":request.getParameter("id");
String userName = (String)session.getAttribute("_userName");
String compania = (String) session.getAttribute("_companyId");
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null || mode.trim().equals("")) mode = "add";

boolean viewMode = mode.equalsIgnoreCase("view");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){ id="0"; }
	else{
		if (id.trim().equals("")) throw new Exception("El ID del Centro de Transferencia no es válido. Por favor intente nuevamente!");
		
		sql = "select fa.id, fa.nombre, fa.status, fa.direccion, fa.telefonos from tbl_sal_centros_tranf fa where fa.compania="+(String) session.getAttribute("_companyId")+" and fa.id = "+id;
        cdo = SQLMgr.getData(sql);
        
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title="Expediente - Centros de Transferencia - "+document.title;

function doAction(){  }

  </script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - CENTROS DE TRANFERENCIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
<tr>
	<td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("tab","0")%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("id",id)%>

		<tr class="TextRow02">
			<td colspan="6">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="10%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="90%"><%=fb.intBox("codigo",id,false,false,true,20,3)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel>Estado</cellbytelabel>&nbsp;<%=fb.select("status","A=Activo, I=Inactivo",cdo.getColValue("status"))%>
            </td>
		</tr>
        <tr class="TextRow01">
			<td align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,viewMode,false,80,255)%></td>
		</tr>
        <tr class="TextRow01">
			<td align="right"><cellbytelabel>Tel&eacute;fonos</cellbytelabel></td>
			<td><%=fb.textBox("telefonos",cdo.getColValue("telefonos"),false,viewMode,false,80,255)%></td>
		</tr>
        <tr class="TextRow01">
			<td align="right"><cellbytelabel>Direcci&oacute;on</cellbytelabel></td>
			<td><%=fb.textarea("direccion",cdo.getColValue("direccion"),false,false,viewMode,255,2,255,"","width:70%","")%></td>
		</tr>
			
		<tr class="TextRow02">
			<td align="right" colspan="6">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>: 
				<%=fb.radio("saveOption","N",true,false,false)%><cellbytelabel id="9">Crear Otro </cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel> 
				<%=fb.radio("saveOption","C")%><cellbytelabel id="11">Cerrar</cellbytelabel> 
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.submit("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");

    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_centros_tranf");
    cdo.setAutoIncCol("id");
    cdo.addPkColValue("id","");
    
    cdo.addColValue("nombre",request.getParameter("nombre"));
    cdo.addColValue("status",request.getParameter("status"));
    cdo.addColValue("telefonos",request.getParameter("telefonos"));
    cdo.addColValue("direccion",request.getParameter("direccion"));
    cdo.addColValue("compania",compania);
    cdo.addColValue("usuario_modificacion",userName);
    cdo.addColValue("fecha_modificacion",curDate);
		
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    if (mode.equalsIgnoreCase("add")){	
        cdo.addColValue("usuario_creacion",userName);
        cdo.addColValue("fecha_creacion",curDate);
        
        SQLMgr.insert(cdo);
        id = SQLMgr.getPkColValue("id");
    }
    else{	
        cdo.setWhereClause("id = "+id);
        SQLMgr.update(cdo);
    }      
    ConMgr.clearAppCtx(null);
%>
<!doctype html>
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
	window.opener.location = '<%=request.getContextPath()%>/expediente/exp_centros_transferencia.jsp';
<%if (saveOption.equalsIgnoreCase("")){%>
	setTimeout('addMode()',500);
<%}else if (saveOption.equalsIgnoreCase("O")){%>
	setTimeout('editMode()',500);
<%}else if (saveOption.equalsIgnoreCase("C")){%>
	window.close();
<%}
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