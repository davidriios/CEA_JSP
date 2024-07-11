<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/> 
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr); 


ArrayList alTPR = new ArrayList();
StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String tipo = request.getParameter("tipo");
String id_ref = request.getParameter("id_ref");
String tab = request.getParameter("tab");

boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdo = new CommonDataObject();

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql.append("select compania, id, tipo, id_ref, to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(fecha_fin, 'dd/mm/yyyy') fecha_fin, id_articulo, id_descuento, estado, observacion, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, (select descripcion from tbl_inv_articulo where compania = aa.compania and cod_articulo = aa.id_articulo) desc_articulo, almacen, (select descripcion from tbl_par_descuento where id = aa.id_descuento) desc_descuento from tbl_adm_alquiler aa where compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and id_ref = '");
	sql.append(id_ref);
	sql.append("' and tipo = '");
	sql.append(tipo);
	sql.append("'");
	cdo = SQLMgr.getData(sql);
	if(cdo==null){
		cdo = new CommonDataObject();
		cdo.addColValue("id", "0");
		cdo.addColValue("fecha_inicio", "");
		cdo.addColValue("fecha_fin", "");
		cdo.addColValue("id_articulo", "");
		cdo.addColValue("id_descuento", "");
	}
 %>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);}
function doSubmit(action){
	document.form.baction.value = action;
	if(!formValidation()){
		formBlockButtons(false);
		return false
	} else {
		if($("#fecha_inicio").val()==''){
			alert('Introduzca Fecha Inicio!');
			formBlockButtons(false);
		} else if($("#fecha_fin").val()==''){
			alert('Introduzca Fecha Fin!');
			formBlockButtons(false);
		} else document.form.submit();
	}
}
function selArt(){
	abrir_ventana('../common/sel_articles_alquiler.jsp');
}
function selDesc(){
	if(document.form.id_articulo.value=='') alert('Debe seleccionar Articulo');
	else {
		const codigo = document.form.id_articulo.value;
		const descripcion = document.form.desc_articulo.value;
		showPopWin('../common/sel_descuento.jsp?fp=cafeteria&codigo='+codigo+'&descripcion='+descripcion,winWidth*.55,_contentHeight*.35,null,null,'');
	}	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("id_ref",id_ref)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("id",cdo.getColValue("id"))%>
<%=fb.hidden("almacen",cdo.getColValue("almacen"))%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
	<tr class="TextHeaderOver">
		<td width="100%">
			<table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
				<tr class="TextHeader02" height="21">
					<td align="center" width="90%"><cellbytelabel>Alquiler</cellbytelabel></td>
				</tr>
				<table width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextRow01">
						<td align="right">Fecha Inicio:</td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_inicio" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
								</jsp:include>
						</td>
						<td align="right">Fecha Fin:</td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_fin" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fin")%>" />
								</jsp:include>
						</td>
						<td colspan="2">&nbsp;</td>
					</tr>
					<tr class="TextRow01">
						<td align="right">Art&iacute;culo:</td>
						<td colspan="3">
						<%=fb.intBox("id_articulo",cdo.getColValue("id_articulo"),true,false,viewMode,10,10,null,null,"")%>
						<%=fb.textBox("desc_articulo",cdo.getColValue("desc_articulo"),false,false,viewMode,50,100,null,null,"")%>
						<%=fb.button("sel_art","...",true,false,null,null,"onClick=\"javascript:selArt()\"")%>
						</td>
						<td>Descuento:</td>
						<td>
						<%=fb.hidden("id_descuento",cdo.getColValue("id_descuento"))%>
						<%=fb.textBox("desc_descuento",cdo.getColValue("desc_descuento"),false,false,viewMode,50,100,null,null,"")%>
						<%=fb.button("sel_desc","...",true,false,null,null,"onClick=\"javascript:selDesc()\"")%>
						</td>
					</tr>
					<tr class="TextRow01">
						<td align="right">Observaci&oacute;n:</td>
						<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,80,5)%>
						</td>
						<td align="right">Estado:</td>
						<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%>
						</td>
					</tr>
				</table>
				
				<tr class="TextRow02">
					<td align="right">
					<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_adm_alquiler");

	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("tipo")!=null) cdo.addColValue("tipo", request.getParameter("tipo"));
	if(request.getParameter("id_ref")!=null) cdo.addColValue("id_ref", request.getParameter("id_ref"));
	if(request.getParameter("fecha_inicio")!=null) cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"));
	if(request.getParameter("fecha_fin")!=null) cdo.addColValue("fecha_fin", request.getParameter("fecha_fin"));
	if(request.getParameter("id_articulo")!=null) cdo.addColValue("id_articulo", request.getParameter("id_articulo"));
	if(request.getParameter("id_descuento")!=null) cdo.addColValue("id_descuento", request.getParameter("id_descuento"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("almacen")!=null) cdo.addColValue("almacen", request.getParameter("almacen"));
	if(request.getParameter("id")!=null && request.getParameter("id").equals("0")) cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	if(request.getParameter("id")!=null && request.getParameter("id").equals("0")) cdo.addColValue("fecha_creacion", "sysdate");
	if(request.getParameter("id")!=null && !request.getParameter("id").equals("0")) if(request.getParameter("usuario_modificacion")!=null) cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	if(request.getParameter("id")!=null && !request.getParameter("id").equals("0")) if(request.getParameter("fecha_modificacion")!=null) cdo.addColValue("fecha_modificacion", "sysdate");

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if(request.getParameter("id")!=null && request.getParameter("id").equals("0")){ 
		cdo.setAutoIncCol("id");
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		SQLMgr.insert(cdo);
	} else if(request.getParameter("id")!=null && !request.getParameter("id").equals("0")){ 
		cdo.setWhereClause("id="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));
		SQLMgr.update(cdo);

	}	
	ConMgr.clearAppCtx(null);
	%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<%if (SQLMgr.getErrCode().equals("1")){
	%>
		alert('<%=SQLMgr.getErrMsg()%>');
	<%
	} else throw new Exception(SQLMgr.getErrMsg());
%>
	parent.window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>