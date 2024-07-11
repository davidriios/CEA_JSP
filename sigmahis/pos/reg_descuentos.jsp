<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String creatorId = UserDet.getUserEmpId();

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String type=request.getParameter("type");
String compId=(String) session.getAttribute("_companyId");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String title = "";
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();

if(mode==null) mode="add";
boolean viewMode = false;
if(mode.equals("view")) viewMode = true;
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";
if (tab == null) tab = "0";

String key = "";
String apl_desc_global = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'APL_DESC_GLOBAL_POS'), 'N') as apl_desc_global from dual").getColValue("apl_desc_global");



if(request.getMethod().equalsIgnoreCase("GET")){

	if(mode.equalsIgnoreCase("add")) {
			title = "REGISTRAR";
			id = "";
			cdo.addColValue("id", "");
			cdo.addColValue("es_desc_global", "N");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	} else {
			title = "MODIFICAR";
			sbSql.append("select id, codigo, descripcion, tipo, valor, estado, compania, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, observacion,nvl(jubilado,'N')jubilado, nvl(aplica_todo_art, 'N') aplica_todo_art, nvl(es_desc_global, 'N') es_desc_global from tbl_par_descuento where id = ");
			sbSql.append(id);

			if (id == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			cdo = SQLMgr.getData(sbSql.toString());
			
			sbSql = new StringBuffer();
			
			
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
function doAction(){
null;
}

function doSubmit(form, valor){
    document.form1.baction.value = valor;
    if(form=='form1'){if(form1Validation()) document.form1.submit();}else if(form=='form2')window.frames['detFrame'].doSubmit();
}

function tabFunctions(tab){
	var iFrameName = '', iFrameLocation = '';
	if(tab==1 && document.form1.detalleShow.value=='N'){
		iFrameName='detFrame';
		iFrameLocation = '../pos/reg_descuento_det.jsp?id=<%=cdo.getColValue("id")%>&mode=<%=mode%>&loadInfo=S';
		document.form1.detalleShow.value='S';
	}
	if(iFrameLocation!='')window.frames[iFrameName].location=iFrameLocation;
}

function showReport(){
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=pos/descuento.rptdesign&idParam=<%=cdo.getColValue("id")%>');
}
$(document).ready(function(){
	$("#tipo").on("change", function(){
		if($(this).val()=='M') $("#section_apl_desc_global").show();
		else $("#section_apl_desc_global").hide();
	});
});
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<%if(!cdo.getColValue("id").equals("")){%>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Imprimir ]</a></authtype></td>
	</tr>
	<%}%>
	<tr>
		<td class="TableBorder">
		<div id="dhtmlgoodies_tabView1">
		<!--GENERALES TAB0-->
		<div class="dhtmlgoodies_aTab">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("tab","0")%>
		<%=fb.hidden("mode", mode)%>
		<%=fb.hidden("id", cdo.getColValue("id"))%>
		<%=fb.hidden("usuario_creacion", cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("change", change)%>
		<%=fb.hidden("baction", "")%>
		<%=fb.hidden("fg", fg)%>
		<%=fb.hidden("detalleShow", "N")%>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td align="right">C&oacute;digo:</td>
				<td><%=fb.textBox("codigo", cdo.getColValue("codigo"), true, false, false, 30, 30, "text12", "", "", "", false, "", "")%></td>
				<td align="right">Descripci&oacute;n:</td>
				<td><%=fb.textBox("descripcion", cdo.getColValue("descripcion"), false, false, false, 50, 100, "text12", "", "", "", false, "", "")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Tipo:</td>
				<td>
				<%=fb.select("tipo", "M=Monto,P=Porcentual,R=Regalia", cdo.getColValue("tipo"), false, false, 0, "text12", "", "", "", "", "", "", "")%>
				<%if(apl_desc_global.equals("S")){%>
				<section id="section_apl_desc_global" style="display:<%=cdo.getColValue("tipo").equals("M")?"":"none"%>;">
				Es Descuento Global?
				<%=fb.select("es_desc_global", "N=No,S=Si", cdo.getColValue("es_desc_global"), false, false, 0, "text12", "", "", "", "", "", "", "")%>
				</section>
				<%}%>
				</td>
				<td align="right">Valor:</td>
				<td><%=fb.decBox("valor", cdo.getColValue("valor"), true, false, false, 4, 12.4, "text12", "", "", "", false, "", "")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Comentario:</td>
				<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,50,3,2000,null,"","")%></td>
				<td align="right">Estado:</td>
				<td><%=fb.select("estado", "A=Activo,I=Inactivo", cdo.getColValue("estado"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Aplica Solo para Jubilado:</td>
				<td><%=fb.select("jubilado", "S=SI,N=NO", cdo.getColValue("jubilado"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
				<td align="right">Aplica a Todos los Art&iacute;culos:</td>
				<td><%=fb.select("aplica_todo_art", "N=NO, S=SI", cdo.getColValue("aplica_todo_art"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right">
				Opciones de Guardar: 
				<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro 
				<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto 
				<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
				<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit('"+fb.getFormName()+"', this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
			<%=fb.formEnd(true)%>
		</table>
</div>
<!--FAMILIAS O PRODUCTOS-->
<div class="dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",cdo.getColValue("id"))%>
			<tr class="TextRow01">
				<td colspan="4">Familias o Art&iacute;culos</td>
			</tr>
			<tr class="TextRow01"><td>
				<iframe id="detFrame" name="detFrame" frameborder="0" width="99%" height="100%" src="../pos/reg_descuento_det.jsp?mode=<%=mode%>" scroll="no"></iframe></td>
			</tr>
<%=fb.formEnd(true)%>
		</table>
</div>	
</div>		
<script type="text/javascript">
<%
String tabLabel = "'Descuento'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Detalle'";
String tabFunctions = "'1=tabFunctions(1)'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null, Array(<%=tabFunctions%>),null);
</script>
		</td>
	</tr>
</table>
<%
%>
</body>
</html>
<%
} else if(request.getMethod().equalsIgnoreCase("post")) {
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();
  cdo.setTableName("tbl_par_descuento");  
	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("codigo")!=null) cdo.addColValue("codigo", request.getParameter("codigo"));
	if(request.getParameter("descripcion")!=null) cdo.addColValue("descripcion", request.getParameter("descripcion"));
	if(request.getParameter("tipo")!=null) cdo.addColValue("tipo", request.getParameter("tipo"));
	if(request.getParameter("valor")!=null) cdo.addColValue("valor", request.getParameter("valor"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("jubilado")!=null) cdo.addColValue("jubilado", request.getParameter("jubilado"));
	if(request.getParameter("aplica_todo_art")!=null) cdo.addColValue("aplica_todo_art", request.getParameter("aplica_todo_art"));
	if(request.getParameter("es_desc_global")!=null) cdo.addColValue("es_desc_global", request.getParameter("es_desc_global"));
	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	String returnId = "";
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		if (mode.equalsIgnoreCase("add")){
			cdo.setAutoIncCol("id");
			cdo.addPkColValue("id","");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			SQLMgr.insert(cdo);
			returnId = SQLMgr.getPkColValue("id");
		} else {
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.setWhereClause("id="+cdo.getColValue("id"));
			SQLMgr.update(cdo);
			returnId = cdo.getColValue("id");
		}
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if(SQLMgr.getErrCode().equals("1")){
%>
    alert('<%=SQLMgr.getErrMsg()%>');
    window.opener.location = '<%=request.getContextPath()%>/pos/list_descuentos.jsp';
<%
    if (saveOption.equalsIgnoreCase("N")){
%>
    setTimeout('addMode()',500);
<%
    } else if (saveOption.equalsIgnoreCase("O")){
%>
    setTimeout('editMode()',500);
<%
    } else if (saveOption.equalsIgnoreCase("C")){
%>
    window.close();
<%
    }    
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}

function editMode()
{
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=returnId%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
