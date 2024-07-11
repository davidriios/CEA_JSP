<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CommonDataObject cdo = new CommonDataObject();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
StringBuffer sbSql = new StringBuffer();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";
	} else {
		sbSql.append("select t.id, t.descripcion, t.estado from tbl_pm_tipo_centro_atencion t where t.id = ");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql.toString());
	}

    if (cdo == null) cdo = new CommonDataObject();
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Plan Médico -  Mantenimiento - '+document.title;
function doAction(){}

$(document).ready(function(){
 $("#save").click(function(){
	if ($("#descripcion").val()){
		document.form0.baction.value = "Guardar";
		$("#form0").submit();
	}else{
		CBMSG.error("Los campos con fondo amarillo son mandatorios!");
	}
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLAN MEDICO MANTENIMIENTO - CENTROS DE ATENCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>
					<table width="100%" cellpadding="3" cellspacing="1">
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>C&oacute;digo:</cellbytelabel></td>
							<td width="80%" colspan="3">
								<%=fb.textBox("id",id,false,false,true,10,100,null,null,"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Descripci&oacute;n:</cellbytelabel></td>
							<td width="80%" colspan="3">
								<%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,70,100,null,null,"")%>
								&nbsp;&nbsp;&nbsp;<cellbytelabel>Estado:</cellbytelabel>
								<%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,null,null,null)%>
							</td>
						</tr>
						
					</table>
				</td>
			</tr>
			<tr class="TextRow02">
				<td align="right">
					<%=fb.button("save","Guardar",true,false,"","","")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();
	cdo.setTableName("tbl_pm_tipo_centro_atencion");

	cdo.addColValue("id", request.getParameter("id"));
	cdo.addColValue("estado", request.getParameter("estado"));
	cdo.addColValue("descripcion", request.getParameter("descripcion"));
	
	System.out.println(".................................. "+request.getParameter("baction"));

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
		if (mode.equalsIgnoreCase("add")){
			cdo.setAutoIncCol("id");
			SQLMgr.insert(cdo);
			id = cdo.getAutoIncCol();
		} else if (mode.equalsIgnoreCase("edit")) {
			cdo.setWhereClause("id = "+id);
			SQLMgr.update(cdo);
		}
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	var fg = '<%=request.getParameter("fg")%>';
	alert('<%=SQLMgr.getErrMsg()%>');
	if(fg==""){
		window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_tipo_centros_atencion_list.jsp?beginSearch=Y';
		window.close();
	}else{opener.doRefresh(); window.close();}
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