<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = (request.getParameter("pacId")==null?"":request.getParameter("pacId"));
String consetimiento = (request.getParameter("consetimiento")==null?"":request.getParameter("consetimiento"));
String noAdmision = (request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision"));
String search = (request.getParameter("search")==null?"":request.getParameter("search"));
String cLang = (session.getAttribute("_locale")==null?"es":((java.util.Locale)session.getAttribute("_locale")).getLanguage());
String exp = (request.getParameter("exp")==null?"":request.getParameter("exp"));

if (consetimiento.trim().equals("")) throw new Exception("El ID de Consentimiento no esta definido.");

String appendFilter = (!search.trim().equals("")?" and upper(nombre) like '%"+search.toUpperCase()+"%'":"");
appendFilter+=" and id_pro = "+consetimiento;

if (pacId.trim().equals("")) throw new Exception("No pudimos encontrar el paciente!");
if (noAdmision.trim().equals("")) throw new Exception("No pudimos encontrar la admisión!");

al = SQLMgr.getDataList("select id, upper(nombre) as nombre, decode(nvl(instr(path,'?'),0),0,nvl(path,' '),substr(path,1,instr(path,'?') - 1)) as path, decode(nvl(instr(path,'?'),0),0,' ',substr(path,instr(path,'?') + 1)) as qs from tbl_param_consentimientos where nombre is not null and estado <> 'I' "+appendFilter+" order by display_order nulls last");

cdo = SQLMgr.getData("select nombre_paciente, id_paciente as identificacion from vw_adm_paciente where pac_id = "+pacId);

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Common - Consentimiento - '+document.title;
function doAction(){<%if(exp!=null && exp.equals("")){%>newHeight();<%}%>}
function printConsent(){
	var pacId = '<%=pacId%>', noAdmision = '<%=noAdmision%>', cLang = '<%=cLang%>';
	var tot = parseInt("<%=al.size()%>",10);
	__checked = new Array();
	for (i = 0; i<tot; i++){
		if($("#c"+i).prop("checked"))__checked.push($("#id"+i).val());
	}
	if (__checked.length < 1) CBMSG.error("Por favor seleccione al menos un consentimento!");
	else {
		$("#totSel").val(__checked.toString());
		$("#form0").submit();
	}
//	if (path != "") abrir_ventana(path+'?pacId='+pacId+'&pac_id='+pacId+'&noAdmision='+noAdmision+'&no_adm='+noAdmision+'&cLang='+cLang+'&idConsent='+id)
}
function manageConsent(id){
	 //console.log("thebrain.............> "+id);
	 if (typeof id == "undefined")
			abrir_ventana('../admin/consentimiento_config.jsp?fg=fromList');
	 else abrir_ventana('../admin/consentimiento_config.jsp?mode=edit&id='+id+'&fg=fromList');
}
function doRefresh(){/**/location.reload();}
function doSearch(){
  var q = document.form0.search.value;
  var pacId = document.form0.pacId.value;
  var noAdmision = document.form0.noAdmision.value;
  window.location = "../expediente3.0/sel_consentimiento.jsp?pacId="+pacId+"&noAdmision="+noAdmision+"&search="+q+'&consetimiento=<%=consetimiento%>&exp=<%=exp%>';
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Administración - Listado de Consentimiento"></jsp:param>
</jsp:include>
<table align="center" width="97%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="3" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("totSel","")%>
<%=fb.hidden("consetimiento",consetimiento)%>
<%=fb.hidden("exp",exp)%>
		<tr class="TextRow01 Text12Bold">
			<td colspan="3">Paciente:&nbsp;[<%=pacId+"-"+noAdmision%>]&nbsp;<%=cdo.getColValue("nombre_paciente")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C&eacute;dula/Pasaporte:&nbsp;<%=cdo.getColValue("identificacion")%></td>
		</tr>
		<tr class="TextRow02">
		    <td>
			<%=fb.textBox("search",search,false,false,false,40,"Text10",null,null)%>
			<%=fb.button("btnSearch","IR",true,false,"Text10",null,"onClick=doSearch()")%></td>
			<td align="right">
			<%=fb.button("btnPrintUp","Imprimir",true,false,"Text10",null,"onClick=printConsent()")%></td>
		</tr>
		<!--<tr>
			<td colspan="3" align="right"><authtype type='3'><a href="javascript:manageConsent()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Consentimiento</cellbytelabel> ]</a></authtype></td>
		</tr>-->
		<tr class="TextHeader">
			<td width="95%"><cellbytelabel>Nombre Consentimiento</cellbytelabel></td>
			<td width="5%" align="center"><cellbytelabel>&nbsp;<%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','c',"+al.size()+",this)\"","Seleccionar todos los Registros listados!")%></cellbytelabel></td>
		</tr>
<%
for (int c = 0; c<al.size(); c++){
	cdo = (CommonDataObject)al.get(c);
	String color = "TextRow02";
	if (c % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("path"+c,cdo.getColValue("path"))%>
		<%=fb.hidden("id"+c,cdo.getColValue("id"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><% if (cdo.getColValue("path") != null && !cdo.getColValue("path").trim().equals("")) { %><%=fb.checkbox("c"+c,"",false,false,null,null,"")%><% } %><!--<authtype type='3'><a href='javascript:manageConsent("<%=cdo.getColValue("id")%>")' class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="8">Editar</cellbytelabel></a></authtype>--></td>
		</tr>
<% } %>
<%=fb.formEnd()%>
	<tr class="TextRow02">
		<td colspan="2" align="right"><%=fb.button("btnPrintBtm","Imprimir",true,false,"Text10",null,"onClick=printConsent()")%></td>
	</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {
	session.setAttribute("_sel",request.getParameter("totSel"));
%>
<html>
<head>
<script>
function closeWindow(){
	window.open("../admision/print_unified_consent.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&pac_id=<%=pacId%>&no_adm=<%=noAdmision%>");
	document.location = "../expediente3.0/sel_consentimiento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&pac_id=<%=pacId%>&no_adm=<%=noAdmision%>&consetimiento=<%=consetimiento%>&exp=<%=exp%>";
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>