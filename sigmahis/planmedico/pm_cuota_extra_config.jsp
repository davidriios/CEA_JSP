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
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";
		cdo.addColValue("fecha_inicio", fecha);
		cdo.addColValue("porcentaje", "0");
	} else {
		sbSql.append("select id, id_solicitud, id_beneficiario, monto, to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_modificacion, to_char(fecha_aprobacion, 'dd/mm/yyyy') fecha_aprobacion, usuario_aprobacion, estado, observacion, nvl(tipo_cuota, 'N') tipo_cuota, nvl(porcentaje, 0) porcentaje, (select cuota_mensual from tbl_pm_solicitud_contrato sc where sc.id = a.id_solicitud) monto_contrato, (case when cuota_segun_edad = 0 then (select cuota_mensual from tbl_pm_solicitud_contrato sc where sc.id = a.id_solicitud) else cuota_segun_edad end) cuota_segun_edad from tbl_pm_cuota_extra a where id = ");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql.toString());
	}

    if (cdo == null) cdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
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

    var solicud = document.getElementById("id_solicitud").value;
    var monto = document.getElementById("monto").value;

    if ( 1 != 1){alert("The future depends on what we do in the present. Mahatma Gandhi");return false;}
    else
    if (id_solicitud == "" || monto == "" ){
       alert("Por favor los campos con fondos amarillos no deben estar vacios!");return false;
    }
    return true;
}

function addSolicitud(){
	abrir_ventana('../planmedico/pm_sel_solicitud.jsp?fp=cuota_extra');
}

function setMonto(){
	var porc = document.form0.porcentaje.value;
	var monto = document.form0.monto.value;
	var monto_contrato = document.form0.cuota_segun_edad.value;
	<%if(mode.equals("add")){%>
	if(document.form0.tipo_cuota.value=='P'){
		document.form0.monto.readOnly=true;
		if(monto_contrato!='' && !isNaN(monto_contrato) && monto_contrato != 0){
		document.form0.monto.value = (monto_contrato * (1 + (porc/100))).toFixed(2);
		} else alert('Introduzca Cuota de Contrato!');
	} else {
		document.form0.porcentaje.value = 0;
		document.form0.monto.readOnly=false;
		document.form0.monto.value = monto_contrato;
	}
	<%}%>
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
			<%=fb.hidden("usuario_creacion",cdo.getColValue("usuario_creacion"))%>
			<%=fb.hidden("fecha_creacion",cdo.getColValue("fecha_creacion"))%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("id_beneficiario",cdo.getColValue("id_beneficiario"))%>
			<%=fb.hidden("monto_original",cdo.getColValue("monto"))%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>
					<table width="100%" cellpadding="3" cellspacing="1">
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Solicitud:</cellbytelabel></td>
							<td width="80%" colspan="3">
								<%=fb.textBox("id_solicitud",cdo.getColValue("id_solicitud"),true,false,true,10,10)%>
								<%=fb.button("btnsolicitud","...",true,false,null,null,"onClick=\"javascript:addSolicitud()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Cuota Seg&uacute;n Edad:</cellbytelabel></td>
							<td width="80%" colspan="3">
								<%=fb.decBox("cuota_segun_edad",cdo.getColValue("cuota_segun_edad"),true,false,true,10,10.2)%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								Monto Contrato:
								<%=fb.decBox("monto_contrato",cdo.getColValue("monto_contrato"),true,false,true,10,10.2)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Monto <font class="RedTextBold">(SIN IMPUESTO)</font>:</cellbytelabel></td>
							<td width="80%" colspan="3">
								<%=fb.decBox("monto",cdo.getColValue("monto"),true,false,true,10,10.2)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Fecha Inicio:</cellbytelabel></td>
							<td width="80%" colspan="3">
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="nameOfTBox1" value="fecha_inicio"/>
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>"/>
							<jsp:param name="fieldClass" value="Text10"/>
							<jsp:param name="buttonClass" value="Text10"/>
							<jsp:param name="clearOption" value="true"/>
							</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Observaci&oacute;n:</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textarea("observacion", cdo.getColValue("observacion"), false, false, false, 70, 3, 1000, "text12", "", "", "", false, "", "")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Tipo Cuota:</cellbytelabel></td>
							<td colspan="3">
							<%=fb.select("tipo_cuota","P=Penalizacion,N=Normal",cdo.getColValue("tipo_cuota"),false,false,0,null,null,"onChange='javascript:setMonto();'")%>
							<cellbytelabel>Porcentaje:</cellbytelabel>
							<%=fb.decBox("porcentaje",cdo.getColValue("porcentaje"),false,false,false,10,10.2,"","","onChange='javascript:setMonto();'","",false)%>/100
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr class="TextRow02">
				<td align="right">
					<%=fb.button("save","Guardar",true,(mode.equals("view") || (cdo.getColValue("estado")!=null && (cdo.getColValue("estado").equals("F") || cdo.getColValue("estado").equals("A")))),null,null,"onClick=\"javascript:_doSubmit(this.value)\"")%>
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
	cdo.setTableName("tbl_pm_cuota_extra");

	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("monto")!=null) cdo.addColValue("monto", request.getParameter("monto"));
	if(request.getParameter("cuota_segun_edad")!=null) cdo.addColValue("cuota_segun_edad", request.getParameter("cuota_segun_edad"));
	if(request.getParameter("fecha_inicio")!=null) cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("id_solicitud")!=null) cdo.addColValue("id_solicitud", request.getParameter("id_solicitud"));
	if(request.getParameter("id_beneficiario")!=null) cdo.addColValue("id_beneficiario", request.getParameter("id_beneficiario"));
	if(request.getParameter("tipo_cuota")!=null && request.getParameter("tipo_cuota").equals("P")) {
		cdo.addColValue("tipo_cuota", request.getParameter("tipo_cuota"));
		if(request.getParameter("porcentaje")!=null) cdo.addColValue("porcentaje", request.getParameter("porcentaje"));
	}
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
		window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_cuota_extra_list.jsp';
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