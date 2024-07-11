<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Mapping"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="Map" scope="session" class="issi.admin.Mapping" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
//Mapping Map = new Map();
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String revenueId = request.getParameter("revenueId")==null?"":request.getParameter("revenueId");
String cCompany = (String)session.getAttribute("_companyId");

if (mode == null) mode = "add";

if (revenueId.trim().equals("") && mode.equalsIgnoreCase("edit") ) throw new Exception("El mapping AXA es inválido!");

if (mode.equalsIgnoreCase("edit")) viewMode = true;

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("edit")){
		sql="select a.id as revenueid, a.code as revenuecode, a.adm_type,a.cds,a.ts,a.description,a.comments,a.status, (select descripcion from tbl_cds_centro_Servicio where codigo = a.cds and rownum = 1) as cds_desc,  (select aa.descripcion from tbl_cds_tipo_servicio aa where aa.compania = "+cCompany+" and aa.codigo = a.ts) as ts_desc, a.prioridad from tbl_map_axa_revenue a where a.id = "+revenueId;
	
		cdo = SQLMgr.getData(sql);
	}
	else cdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script type="text/javascript">
document.title = 'ADMINISTRACIÓN - MAPPING CPT '+document.title;
function doAction(){
    var cds = $("#cds_code").val();
	var _filter = "<%=mode.equalsIgnoreCase("add")?"":"&revenueId="+revenueId%>";
	_filter+= "&parentMode=<%=mode%>";
	$("#iCPT").attr("src","../admin/mapping_cpt_det.jsp?cds="+cds+_filter);
	$("#iArt").attr("src","../admin/mapping_art_det.jsp?cds="+cds+_filter);
}

function showCdsList(){
  abrir_ventana("../common/sel_centro_servicio.jsp?fg=MAPPING_CPT");
}
function showTsList(){
  abrir_ventana("../common/check_tipo_servicio.jsp?fp=MAPPING_CPT");
}

$(document).ready(function(){
	
	$("#patient_type").change(function(e){
		$("#hasChanged").val("Y");
	});

	$("#save").click(function(){
		var f = document.getElementById('iCPT').contentWindow;
		var _doSubmit = true;
		var mode = "<%=mode%>";
		var cCompany = "<%=cCompany%>";
		var doFilter = true;
		f.document.getElementById("status").value = $("#status").val();
		f.document.getElementById("patient_type").value = $("#patient_type").val();
		f.document.getElementById("cds").value = $("#cds_code").val();
		f.document.getElementById("ts_code").value = $("#ts_code").val();
		f.document.getElementById("revenuecode").value = $("#revenuecode").val();
		f.document.getElementById("description").value = $("#description").val();
		f.document.getElementById("comments").value = $("#comments").val();
		f.document.getElementById("revenueId").value = $("#revenueId").val();
		f.document.getElementById("parentMode").value = "<%=mode%>";
		f.document.getElementById("cUrl").value = window.location.href;
		f.document.getElementById("prioridad").value = $("#prioridad").val();
		
		if (mode=="add") doFilter = true;
		else doFilter = $("#hasChanged").val() != "";
		
		if ($("#revenuecode").val() == "") {
		   alert("Por favor son obligatorios los campos con fondo amarillo!");
		  _doSubmit = false;
		}else {
		  var pt = $("#patient_type").val() || "-";
		  var cdsCode = $("#cds_code").val() || "-99999";
		  var ts = $("#ts_code").val() || "-";
		  var status = $("#status").val();
		  var rcode = $("#revenuecode").val();
		  //_filter = " adm_type " + ( pt == ""?" is null ":" = '"+pt+"'");
		  _filter = " adm_type = '"+pt+"'";
		  _filter+= " and  cds = "+cdsCode;
		  _filter+= " and  ts = '"+ts+"'";
		  _filter+= " and  status = '"+status+"'";
		  _filter+= " and company = "+cCompany;
		  _filter+= " and code = '"+rcode+"'";
		  		 		  
		  if ( doFilter && hasDBData('<%=request.getContextPath()%>','tbl_map_axa_revenue',_filter,'')  )
		  {
			alert("Ya tenemos registrada esta combinación de:\nCompañía ("+cCompany+")\nLugar de Servicio ("+pt+")\nCentro de Servicio ("+cdsCode+")\ny Tipo de Servicio ("+ts+")");
			_doSubmit = false;
		  }else {_doSubmit=true;}
		}

		if (_doSubmit===true) {
			f.doSubmit();
		}	
	});
	
	$("#cancel").click(function(){
		return window.close();
	});

});

function doSubmitArt(revenueId){
	
		var art = document.getElementById('iArt').contentWindow;
		art.document.getElementById("revenueId").value = revenueId;
		art.doSubmit();
}
function doSubmit(revenueId){
	if(document.form1.revenueId.value=='') document.form1.revenueId.value=revenueId;
	document.form1.submit();
}
function showRep()
{
    abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admin/mapping_cpt.rptdesign&pCtrlHeader=false&pCodigo=<%=revenueId%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="ADMINISTRACIÓN - MAPPING CPT"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr class="TextRow02" >
		<td colspan="6">&nbsp;</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("revenueId",revenueId)%>
			<%=fb.hidden("hasChanged","")%>
			<tr class="TextHeader" >
				<td colspan="2">MAPPING CPT</td>
			</tr>
			<tr class="TextRow01">
				<td width="10%" align="right">Mapping AXA</td>
				<td width="90%"><%=fb.textBox("revenuecode",cdo.getColValue("revenuecode"),true,false,false,10)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Prioridad&nbsp;
				<%=fb.select("prioridad","T=Tipo Servicio,C=Centro Servicio,L=Cat. Admision",cdo.getColValue("prioridad"),"S")%>
				</td>
			</tr>
			<tr class="TextRow01">		
				<td width="10%" align="right">Descripci&oacute;n&nbsp;&nbsp;</td>
				<td width="90%"><%=fb.textBox("description",cdo.getColValue("description"),false,false,false,70,100)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado&nbsp;
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo.getColValue("status"))%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Categoria Admisi&oacute;n&nbsp;
				<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_adm_categoria_admision order by codigo asc","patient_type",cdo.getColValue("adm_type"),false,false,0,null,null,null, "", "S")%>
				<%//=fb.select("patient_type","I=Inpatient,O=Outpatient",cdo.getColValue("adm_type"),"S")%>
				</td>
			</tr>
			<tr class="TextRow01">		
				<td width="10%" align="right">Centro Servicio</td>
				<td width="90%">
				
				<%=fb.textBox("cds_code",cdo.getColValue("cds"),false,false,true,7)%>
				<%=fb.textBox("cds_desc",cdo.getColValue("cds_desc"),false,false,true,50,0)%>
				<%=fb.button("btnCds","...",true,false,null,null,"onClick=javascript:showCdsList()")%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tipo Servicio&nbsp;
				<%=fb.textBox("ts_code",cdo.getColValue("ts"),false,false,true,7)%>
				<%=fb.textBox("ts_desc",cdo.getColValue("ts_desc"),false,false,true,50,0)%>
				<%=fb.button("btnTs","...",true,false,null,null,"onClick=javascript:showTsList()")%>
				</td>
			</tr>
			<tr class="TextRow01">		
				<td width="10%" align="right">Comentario</td>
				<td width="90%"><%=fb.textarea("comments", cdo.getColValue("comments"), false, false, false, 0, 3,2000, "", "width:70%", "")%>
				&nbsp;<%=fb.button("btnPrint","IMPRIMIR",true,false,null,null,"onClick=javascript:showRep()")%>
				</td>
			</tr>
			
			<tr class="TextRow02">
				<td colspan="6" align="right">
				<iframe id="iCPT" name="iCPT" src="" style="width:100%; height:200px; border:none"></iframe>
				</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="6" align="right">
				<iframe id="iArt" name="iArt" src="" style="width:100%; height:200px; border:none"></iframe>
				</td>
			</tr>

			<tr class="TextRow02">
				<td colspan="6" align="right">
				<%=fb.button("save","Guardar",true,false,null,null,"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"")%>
				</td>
			</tr>
			<%fb.appendJsValidation("if(error>0)newHeight();");%>
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%} else {
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.save(Map.getCdo(),Map.getAlCpt(),true,true,true,false);
	SQLMgr.saveList(Map.getAlArt(),true,true,false,true);
	ConMgr.clearAppCtx(null);
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
	alert('<%=SQLMgr.getErrMsg()%>');
	window.opener.document.location = "../admin/mapping_cpt_list.jsp?beginSearch=";
	window.document.location = "../admin/mapping_cpt.jsp?mode=edit&revenueId=<%=revenueId%>";
	//parent.window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%}%>