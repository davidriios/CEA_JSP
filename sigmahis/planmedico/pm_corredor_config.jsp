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
		sbSql.append("select id, nombre, identificacion, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, estado, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc, porc_comision, observacion, cuenta_bancaria, ruta_transito, tipo_cuenta, nvl((select nombre_banco from tbl_adm_ruta_transito where ruta = ruta_transito), '') ruta, nvl(genera_odp, 'S') genera_odp, nvl(por_comision_inicial, 0) por_comision_inicial from tbl_pm_corredor  where id = ");
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
    var identificacion = document.getElementById("identificacion").value;
    var porc_comision = document.getElementById("porc_comision").value;

    if ( 1 != 1){alert("The future depends on what we do in the present. Mahatma Gandhi");return false;}
    else
    if (nombre == "" || identificacion == "" || porc_comision == "" ){
       alert("Por favor los campos con fondos amarillos no deben estar vacios!");return false;
    }
    return true;
}

function listEmpresa()
{
		abrir_ventana('../convenio/empresa_rutatransito_list.jsp?id=3');
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
							<td width="20%" align="right"><cellbytelabel>Identificaci&oacute;n:</cellbytelabel></td>
							<td width="30%">
								<%=fb.textBox("identificacion",cdo.getColValue("identificacion"),true,false,false,30,50,null,null,"")%>
							</td>
							<td width="20%" align="right"><cellbytelabel>Porc. Comisi&oacute;n:</cellbytelabel></td>
							<td width="30%">
								<%=fb.textBox("porc_comision",cdo.getColValue("porc_comision"),true,false,false,4,4,null,null,"")%>
								Porc. Comisi&oacute;n Inicial:
								<%=fb.textBox("por_comision_inicial",cdo.getColValue("por_comision_inicial"),true,false,false,4,4,null,null,"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Observaci&oacute;n:</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textarea("observacion", cdo.getColValue("observacion"), false, false, false, 70, 3, 1000, "text12", "", "", "", false, "", "")%>
							</td>
						</tr>
						<tr class="TextRow01">
								 <td><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
								 <td><%=fb.textBox("cuenta_bancaria",cdo.getColValue("cuenta_bancaria"),false,false,false,50,18)%></td>
								 <td><cellbytelabel>Tipo de Cuenta</cellbytelabel></td>
								 <td>
								 <%=fb.select("tipo_cuenta","03=CORRIENTE,04=AHORRO,07=PRESTAMO,43=TARJ. CRÉDITO",cdo.getColValue("tipo_cuenta"))%>
								 </td>
							 </tr>
							 <tr class="TextRow02">
								 <td><cellbytelabel>Ruta de Tr&aacute;sito</cellbytelabel></td>
								 <td colspan="3">
								 <%=fb.textBox("ruta_transito",cdo.getColValue("ruta_transito"),false,false,true,5,9)%>
								 <%=fb.textBox("ruta",cdo.getColValue("ruta"),false,false,true,35)%>
								<%=fb.button("btnruta","...",true,false,null,null,"onClick=\"javascript:listEmpresa()\"")%></td>
							 </tr>
						<tr class="TextRow01">
							 <td><cellbytelabel>Genera Orden de Pago (Plan M&eacute;dico)?</cellbytelabel></td>
							 <td>
							 <%=fb.select("genera_odp","S=Si,N=No",cdo.getColValue("genera_odp"))%>
							 </td>
							<td align="right"><cellbytelabel>Estado:</cellbytelabel>
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
	cdo.setTableName("tbl_pm_corredor");

	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id_empresa"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("nombre")!=null) cdo.addColValue("nombre", request.getParameter("nombre"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("identificacion")!=null) cdo.addColValue("identificacion", request.getParameter("identificacion"));
	if(request.getParameter("porc_comision")!=null) cdo.addColValue("porc_comision", request.getParameter("porc_comision"));
	if(request.getParameter("por_comision_inicial")!=null) cdo.addColValue("por_comision_inicial", request.getParameter("por_comision_inicial"));
	if(request.getParameter("cuenta_bancaria")!=null) cdo.addColValue("cuenta_bancaria", request.getParameter("cuenta_bancaria"));
	if(request.getParameter("ruta_transito")!=null) cdo.addColValue("ruta_transito", request.getParameter("ruta_transito"));
	if(request.getParameter("tipo_cuenta")!=null) cdo.addColValue("tipo_cuenta", request.getParameter("tipo_cuenta"));
	if(request.getParameter("genera_odp")!=null) cdo.addColValue("genera_odp", request.getParameter("genera_odp"));

	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion", cDate);
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
		if (mode.equalsIgnoreCase("add")){
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",cDate);
			cdo.setAutoIncCol("id");
			SQLMgr.insert(cdo);
			id = cdo.getAutoIncCol();
		} else if (mode.equalsIgnoreCase("edit")) {
			cdo.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"));
			cdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"));
			cdo.setWhereClause("id= "+id);
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
		window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_corredor_list.jsp';
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