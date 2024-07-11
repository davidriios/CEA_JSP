<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
ArrayList al = new ArrayList();
Hashtable ht = null;

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String fotosFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");

String mode = "", id = "", fg = "", sql = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{
	ht = CmnMgr.getMultipartRequestParametersValue(request,fotosFolder,20,true);
	mode = (String)ht.get("mode");
	fg = (String)ht.get("fg");
	id = (String)ht.get("id")==null?"0":(String)ht.get("id");
}else{
	mode = request.getParameter("mode");
	fg = request.getParameter("fg");
 	id = (request.getParameter("id")==null?"0":request.getParameter("id"));
}

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";

	}else{
		sql = "select id, nombre, titulo, path, estado, display_order, observacion observ, usuario_creacion, usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion,'dd/mm/yyyy') fecha_modificacion, decode(extra_logo_path,null,' ','"+fotosFolder.replaceAll(rootFolder,"..")+"/'||extra_logo_path) extra_logo, extra_logo_status logo_status from tbl_param_consentimientos where id = "+id+"";

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
	if (document.getElementById("nombre").value==""){
		alert("Usted debe introducir un t\xEDtulo!"); _continue=false;
	}else
	if(document.getElementById("order").value!="" && !isInteger(document.getElementById("order").value)){
		alert("El ordenamiento debe ser un n\xFAmero entero!"); _continue=false;
	}
	return _continue;
}
function _doSubmit(){
	if (canSubmit()) document.form0.submit();
		//console.log("thebrain.............> ");
}
function isInteger(n) {
    return (/^\d+$/.test(n+''));
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MANTENIMIENTO - CONSENTIMIENTOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null, FormBean.MULTIPART);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("empId","")%>
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
								<td width="20%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
								<td width="50%">
									<%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,70,300,null,null,"")%>
								</td>
								<td width="5%" align="right"><cellbytelabel>Estado</cellbytelabel></td>
								<td width="15%" ><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,null,null,null)%></td>
							</tr>

							<tr class="TextRow01">
								<td width="5%"><cellbytelabel>Ruta</cellbytelabel></td>
								<td colspan="3">
									<%=fb.textBox("path",cdo.getColValue("path"),false,false,false,60,300,null,null,"")%>
                                    &nbsp;T&iacute;tulo
									<%=fb.textBox("titulo",cdo.getColValue("titulo"),false,false,false,60,500,null,null,"")%>
								</td>
								<td align="right">Orden</td>
								<td><%=fb.textBox("order",cdo.getColValue("display_order"),false,false,false,5,3,null,null,"")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td width="5%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
								<td colspan="5">
									<table width="100%">
									<td><%=fb.textarea("observacion",cdo.getColValue("observ"),false,false,false,60,2,1000,null,null,"")%></td>
									<td>Otro Logo: <%=fb.fileBox("xtraLogo", cdo.getColValue("extra_logo"),true,false,16)%></td>
									<td>Mostrar en Impresi&oacute;n?<%=fb.checkbox("logoStatus", cdo.getColValue("logo_status"),(cdo.getColValue("logo_status")!=null&&!cdo.getColValue("logo_status").trim().equals("")&&cdo.getColValue("logo_status").trim().equals("1")),false,null,null,"")%></td>
									</table>
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
</body>
</html>
<%
}//GET
else
{
		String saveOption = (String)ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
		String baction = (String)ht.get("baction");

		String observ = ((String)ht.get("observacion")==null?"":(String)ht.get("observacion"));

		cdo = new CommonDataObject();

  		cdo.setTableName("tbl_param_consentimientos");
		cdo.addColValue("nombre", (String)ht.get("nombre"));
		cdo.addColValue("estado",(String)ht.get("estado"));
		cdo.addColValue("path",(String)ht.get("path"));
		cdo.addColValue("display_order",(String)ht.get("order"));
		cdo.addColValue("extra_logo_path",(String)ht.get("xtraLogo"));
		cdo.addColValue("extra_logo_status", ((String)ht.get("logoStatus")!=null?"1":"0"));
		cdo.addColValue("titulo",(String)ht.get("titulo"));

		//this will be escaped after each updating
		//cdo.addColValue("observacion",IBIZEscapeChars.forSingleQuots(observ).trim());

		cdo.addColValue("observacion",observ.replaceAll("'"," "));

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
			cdo.addColValue("usuario_creacion",(String)ht.get("usuarioCreacion"));
		    cdo.addColValue("fecha_creacion",(String)ht.get("fechaCreacion"));

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
	var fg = '<%=((String)ht.get("fg"))==null?"":(String)ht.get("fg")%>';
	alert('<%=SQLMgr.getErrMsg()%>');
	if(fg==""){
		window.opener.location = '<%=request.getContextPath()%>/admin/consentimiento_list.jsp';
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