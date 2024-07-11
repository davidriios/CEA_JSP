<%@ page errorPage="../error.jsp"%>
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
String sql = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";

	}else{
		sql = "select id, pregunta, estado, tipo_pregunta, observacion, usuario_creacion, usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion,'dd/mm/yyyy') fecha_modificacion from tbl_pm_cuestionario_salud where id = "+id+"";
		sql = "select id, pregunta, estado, tipo_pregunta, observacion, usuario_creacion, usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion,'dd/mm/yyyy') fecha_modificacion from tbl_pm_cuestionario_salud where id = "+id+"";

		cdo = SQLMgr.getData(sql);
    }

    if (cdo == null) cdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
document.title = 'Consentimiento -  Mantenimiento - '+document.title;
function doAction(){}

function canSubmit(){
	var _continue = true;
	if (document.getElementById("pregunta").value==""){
		alert("Usted debe introducir una pregunta!"); _continue=false;
	}
	return _continue;
}
function _doSubmit(){
	if (canSubmit()) document.form0.submit();
		//console.log("thebrain.............> ");
}
function isInteger(n) { return (/^\d+$/.test(n+''));}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLAN MEDICO MANTENIMIENTO - CUESTIONARIO"></jsp:param>
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
				<%=fb.hidden("usuarioCreacion",cdo.getColValue("usuario_creacion"))%>
				<%=fb.hidden("fechaCreacion",cdo.getColValue("fecha_creacion"))%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td>
						<table width="100%" cellpadding="3" cellspacing="1">
							<tr class="TextRow01">
								<td width="5%">ID</td>
								<td width="5%"><%=fb.textBox("id",id,false,false,true,5,5,null,null,"")%></td>
								<td width="20%" align="right"><cellbytelabel>Pregunta:</cellbytelabel></td>
								<td width="40%">
									<%=fb.textBox("pregunta",cdo.getColValue("pregunta"),true,false,false,70,500,null,null,"")%>
								</td>
								<td width="15%" align="right"><cellbytelabel>Tipo Pregunta:</cellbytelabel></td>
								<td width="15%" ><%=fb.select("tipo_pregunta","0=Otro,1=Si/No",cdo.getColValue("tipo_pregunta"),false,false,0,null,null,null)%></td>
							</tr>
							<tr class="TextRow01">

								<td colspan="3"><cellbytelabel>Estado:</cellbytelabel>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

								<%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,null,null,null)%>
								</td>
								<td colspan="4"><cellbytelabel>Observaci&oacute;n:</cellbytelabel>
									<%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,60,2,1000,null,null,"")%>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<%=fb.formEnd(true)%>

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
		String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
		String baction = request.getParameter("baction");

		String observ = (request.getParameter("observacion")==null?"":request.getParameter("observacion"));

		cdo = new CommonDataObject();

  		cdo.setTableName("tbl_pm_cuestionario_salud");

		cdo.addColValue("pregunta", request.getParameter("pregunta"));
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("tipo_pregunta",request.getParameter("tipo_pregunta"));
		cdo.addColValue("observacion",IBIZEscapeChars.forSingleQuots(observ).trim());

		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion", cDate);

	  if (mode.equalsIgnoreCase("add")){

	  		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",cDate);

			cdo.setAutoIncCol("id");

			SQLMgr.insert(cdo);
			id = cdo.getAutoIncCol();
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			cdo.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"));
		    cdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"));

			cdo.setWhereClause("id="+id+"");

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
	var fg = '<%=request.getParameter("fg")%>';
	alert('<%=SQLMgr.getErrMsg()%>');
	if(fg==""){
		window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_cuestionario_list.jsp';
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