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
StringBuffer sbSql = new StringBuffer();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";
	} else {
		sbSql.append("select id_empresa, nombre, ruc, dv, direccion, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, estado, observacion, telefono, fax, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc from tbl_pm_empresa where id_empresa = ");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql.toString());
	}

    if (cdo == null) cdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Plan Médico -  Mantenimiento - '+document.title;
function doAction(){}

function _doSubmit(valor){
  if (isAValidForm()){
    document.form0.baction.value=valor;
    document.form0.submit();
	}
}
function isInteger(n) { return (/^\d+$/.test(n+''));}
function isAValidForm(){

    var nombre = document.getElementById("nombre").value;
    var telefono = document.getElementById("telefono").value;
    var direccion = document.getElementById("direccion").value;

    if ( 1 != 1){alert("The future depends on what we do in the present. Mahatma Gandhi");return false;}
    else
    if (nombre == "" || telefono == "" || direccion == "" ){
       alert("Por favor los campos con fondos amarillos no deben estar vacios!");return false;
    }
    return true;
}
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
			<%=fb.hidden("id",id)%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>
					<table width="100%" cellpadding="3" cellspacing="1">
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Nombre:</cellbytelabel></td>
							<td width="80%" colspan="3">
								<%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,70,100,null,null,"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>RUC:</cellbytelabel></td>
							<td width="30%">
								<%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,false,30,50,null,null,"")%>
							</td>
							<td width="20%" align="right"><cellbytelabel>DV:</cellbytelabel></td>
							<td width="30%">
								<%=fb.textBox("dv",cdo.getColValue("dv"),false,false,false,4,4,null,null,"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Tel&eacute;fono:</cellbytelabel></td>
							<td>
								<%=fb.textBox("telefono",cdo.getColValue("telefono"),true,false,false,30,30,null,null,"")%>
							</td>
							<td align="right"><cellbytelabel>Fax:</cellbytelabel></td>
							<td>
								<%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,30,30,null,null,"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Direcci&oacute;n:</cellbytelabel></td>
							<td>
								<%=fb.textarea("direccion", cdo.getColValue("direccion"), true, false, false, 70, 3, 1000, "text12", "", "", "", false, "", "")%>
							</td>
							<td align="right"><cellbytelabel>Observaci&oacute;n:</cellbytelabel></td>
							<td>
								<%=fb.textarea("observacion", cdo.getColValue("observacion"), false, false, false, 70, 3, 1000, "text12", "", "", "", false, "", "")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td colspan="4" align="right"><cellbytelabel>Estado:</cellbytelabel>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,null,null,null)%>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr class="TextRow02">
				<td align="right">
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit(this.value)\"")%>
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

	cdo = new CommonDataObject();
	cdo.setTableName("tbl_pm_empresa");

	if(request.getParameter("id_empresa")!=null) cdo.addColValue("id_empresa", request.getParameter("id_empresa"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("direccion")!=null) cdo.addColValue("direccion", request.getParameter("direccion"));
	if(request.getParameter("dv")!=null) cdo.addColValue("dv", request.getParameter("dv"));
	if(request.getParameter("fax")!=null) cdo.addColValue("fax", request.getParameter("fax"));
	if(request.getParameter("nombre")!=null) cdo.addColValue("nombre", request.getParameter("nombre"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("ruc")!=null) cdo.addColValue("ruc", request.getParameter("ruc"));
	if(request.getParameter("telefono")!=null) cdo.addColValue("telefono", request.getParameter("telefono"));

	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion", cDate);
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
		if (mode.equalsIgnoreCase("add")){
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",cDate);
			cdo.setAutoIncCol("id_empresa");
			SQLMgr.insert(cdo);
			id = cdo.getAutoIncCol();
		} else if (mode.equalsIgnoreCase("edit")) {
			cdo.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"));
			cdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"));
			cdo.setWhereClause("id_empresa = "+id);
			SQLMgr.update(cdo);
		}
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
		window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_empresa_list.jsp';
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