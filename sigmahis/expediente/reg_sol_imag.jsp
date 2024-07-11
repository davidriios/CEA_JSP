<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String fg = request.getParameter("fg");
String expediente = request.getParameter("expediente");
String area = "", solicitado_por = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fechaHasta = CmnMgr.getCurrentDate("dd/mm/yyyy");
String codSolicitud = request.getParameter("cod_solicitud");
String codigo = request.getParameter("codigo");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String estado = request.getParameter("estado");
String incluir_admision = request.getParameter("incluir_admision");
if(incluir_admision==null) incluir_admision="N";
if(expediente==null) expediente = "S";
if(incluir_admision.equals("Y"))expediente="N";

System.out.println("...................incluir_admision.............."+incluir_admision);
/*
sql = "select codigo, descripcion from tbl_cds_centro_servicio where estado = 'A' and interfaz='RIS' and recibe_solicitud = 'S'";
al = SQLMgr.getDataList(sql);
for(int i=0;i<al.size();i++){
	CommonDataObject a = (CommonDataObject) al.get(i);
	area = a.getColValue("codigo");
	break;
}
*/
if(request.getParameter("area")!=null) area = request.getParameter("area");
if(request.getParameter("solicitado_por")!=null) solicitado_por = request.getParameter("solicitado_por");
if(request.getParameter("fecha")!=null) fecha = request.getParameter("fecha");
if(request.getParameter("fechaHasta")!=null) fechaHasta = request.getParameter("fechaHasta");
if (mode == null) mode = "add";
if (estado == null) estado = "S";

CommonDataObject p = (CommonDataObject) SQLMgr.getData("select nvl(get_sec_comp_param(-1,'EXP_SOL_RIS_CDS_EXPANDED'),'Y') as cds_expanded, nvl(get_sec_comp_param(-1,'EXP_SOL_RIS_CDS_REQ'),'-') as cds_req, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'EXP_SOL_RIS_FECHA_REQ'),'S') as fecha_req from dual");
if (p == null) {
	p = new CommonDataObject();
	p.addColValue("cds_expanded","Y");
	p.addColValue("cds_req","-");
	p.addColValue("fecha_req","S");	
}

if(request.getParameter("fecha")==null&&p.getColValue("fecha_req").trim().equals("N")){ fecha = "";fechaHasta = "";}
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Imagenología- "+document.title;
<%}%>
function doSubmit(baction){document.form1.baction.value = baction;var estado ='';var req=reqInfo(true);if(baction=='Generar Cargo'){if(req.pacId!=''){estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id='+req.pacId+' and secuencia='+req.admCorte+' ','');}}var descEstado='';if(estado =='I')descEstado=' INACTIVA ';else if(estado =='N')descEstado=' ANULADA ';if((baction=='Generar Cargo' && (estado !='I' && estado !='N'))||baction=='Cancelar Estudio'){form1BlockButtons(true);}if(baction=='Generar Cargo'){if(estado !='I' && estado !='N'){window.frames['itemFrame'].doSubmit();}else {alert('La Admision se encuentra en estado:'+descEstado+'. No puede Registrar Cargos !!!');}}else window.frames['itemFrame'].doSubmit();}
function reqInfo(showAlert){if(showAlert==undefined)showAlert=true;var idx=document.form1.regChecked.value;var isValid=false;var pacId='';var admisionRoot='';var admCorte='';var admision='';var codSolicitud='';var codigo='';if(idx.trim()==''){if(showAlert)alert('Por favor seleccione el Estudio!');}else{pacId=document.form1.pacId.value;admisionRoot=document.form1.admision.value;admision=document.form1.admision.value;admCorte=document.form1.admCorte.value;codSolicitud=document.form1.cod_solicitud.value;codigo=document.form1.codigo.value;isValid=true;}return{isValid:isValid,idx:idx,pacId:pacId,admisionRoot:admisionRoot,admision:admision,codSolicitud:codSolicitud,codigo:codigo,admCorte:admCorte};}
function printOrder(value){var cdsSel = document.form1.cdsSel.value;
var req='';
if(cdsSel!='')req=reqInfo(false);
else req=reqInfo(true);

if(req.pacId!='' || cdsSel!='')if(value =='1')abrir_ventana2('../expediente/print_sol_imagenologia.jsp?fg=IMG&interfaz=RIS&pacId='+req.pacId+'&noAdmision='+req.admisionRoot+'&codSolicitud='+req.codSolicitud+'&codSolicitudDet='+req.codigo+'&estado=<%=estado%>&cdsSel='+cdsSel);
//else{abrir_ventana('../expediente/print_sol_imagenologia.jsp?pacId='+req.pacId+'&noAdmision='+req.admisionRoot+'&fg=area=');}
}
function checkPendingOM(){var gSol=parseInt(document.form1.gSol.value,10);if((gSol)>0){
document.getElementById('pendingMsg').style.display='';
//setTimeout('replaySound(\'pendingSound\',5000)',10);
soundAlert({delay:5000});
}}
$( document ).ready(function() {
	var estado = $("#estado").val();
	$("#incluir_admision").prop('disabled',(estado!='T'));
});
$(function(){
	$("#estado").on('change', function(){
		console.log(this.value);
		$("#incluir_admision").prop('disabled',(this.value!='T'));
	});
});
var xHeight=0;
function doAction(){loaded=true;checkPendingOM();xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - SOLICITUD DE IMAGENOLOGIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("fg",fg)%>
       			<%=fb.hidden("expediente",expediente)%>
				<%=fb.hidden("clearHT","")%>
				<%=fb.hidden("regChecked","")%>
				<%=fb.hidden("pacId","")%>
				<%=fb.hidden("admision_root","")%>
				<%=fb.hidden("admision","")%>
				<%=fb.hidden("cod_solicitud","")%>
				<%=fb.hidden("codigo","")%>
				<%=fb.hidden("admCorte","")%>
				<%=fb.hidden("gSol","")%>			
				<%=fb.hidden("cdsSel","")%>

				<tr class="TextRow02">
					<td colspan="3"><cellbytelabel id="1">Solicitud de Imagenolog&iacute;a</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td class="TableBottomBorder" colspan="3">
						<table width="100%">
							<tr>
								<td><cellbytelabel id="2">Fecha</cellbytelabel>
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
										<jsp:param name="nameOfTBox2" value="fechaHasta" />
										<jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
									</jsp:include> 
									&nbsp;
								<%
								sql = "select codigo, descripcion from tbl_cds_centro_servicio where estado = 'A' and recibe_solicitud = 'S' "+(expediente.equals("S")?" and interfaz='RIS'":" and flag_cds in ('IMA', 'CAR', 'LAB','EJE')");
								
								%>
								&nbsp;Estado:<%=fb.select("estado","S=PENDIENTE,T=CARGO GENERADO,A=ANULADA",estado,false,false,0,"Text10",null,null,null,"")%>&nbsp; <cellbytelabel id="3">&Aacute;reas</cellbytelabel>:&nbsp; <%=fb.select(ConMgr.getConnection(), sql, "area", area, false, false, 0, "T")%>
								<%
								sql = "select codigo, descripcion from tbl_cds_centro_servicio where estado = 'A' and sol_interfaz_ris is not null  order by descripcion";
								%>
								&nbsp;<cellbytelabel id="4">Solicitado por</cellbytelabel>:
								<%=fb.select(ConMgr.getConnection(), sql, "solicitado_por", solicitado_por,"T")%>
								<%=fb.checkbox("incluir_admision", "Y", (incluir_admision!=null && incluir_admision.equals("Y")), false)%>
								Ver de Admisi&oacute;n?
								<%=fb.submit("Ir","Ir",true,false,null,null,"")%></td>
							</tr>
						</table>
					</td>
				</tr>
				
				<tr>
					<td width="15%">&nbsp;</td>
					<td width="70%" align="center"><font size="3" id="pendingMsg" style="display:none"><cellbytelabel id="5">Hay Solicitudes pendientes</cellbytelabel>!</font><script language="javascript">blinkId('pendingMsg','red','white');</script><!--<embed id="pendingSound" src="../media/chimes.wav" autostart="false" width="0" height="0"></embed>--></td>
					<td width="15%" align="right">&nbsp;</td>
				</tr>
				
				<tr>
					<td colspan="3">
					<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="0" scrolling="yes" src="../expediente/reg_sol_imag_item.jsp?fecha=<%=fecha%>&fechaHasta=<%=fechaHasta%>&area=<%=area%>&solicitado_por=<%=solicitado_por%>&expediente=<%=expediente%>&cdsExpanded=<%=p.getColValue("cds_expanded")%>&cdsReq=<%=p.getColValue("cds_req")%>&estado=<%=estado%>" style="height:3000px" >
						</iframe>
						</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="5">Informaci&oacute;n que se desea obtener / Sospecha Diagn&oacute;stica</cellbytelabel></td>
					<td><cellbytelabel id="6">Comentarios</cellbytelabel></td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td rowspan="3"><%=fb.textarea("comentario","",false,false,true,45,4,2000)%></td>
					<td rowspan="3"><%=fb.textarea("observacion","",false,false,false,45,4,2000)%></td>
					<td>
						<%=(estado.trim().equals("S"))?fb.button("cargo","Generar Cargo",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\""):""%>
						<%=fb.button("estudio","Solicitar Estudio",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>
						<%=fb.button("print_orden","Imprimir Procedimiento Seleccionado",false,false,"","","onClick=\"javascript:printOrder(1)\"")%>
						<authtype type='50'><%=(estado.trim().equals("S"))?fb.button("cancelar","Cancelar Estudio",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\""):""%></authtype>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>
						<%=fb.button("print_cargo","Detalle de Cargos",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
						<%//=fb.button("asignar","Asignar Cita",true,true,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3"><cellbytelabel id="7">Creado</cellbytelabel>:&nbsp;
						<%=fb.textBox("usuario_creacion","", false, false, true, 20, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "")%>
						<%=fb.textBox("fecha_solicitud","", false, false, true, 20, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="3" align="right">&nbsp;</td>
				</tr>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String errCode = "";
	String errMsg = "";
	if(request.getParameter("baction")!=null && (request.getParameter("baction").equalsIgnoreCase("Generar Cargo") || request.getParameter("baction").equalsIgnoreCase("Cancelar Estudio"))){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	} else {
		response.sendRedirect("../expediente/reg_sol_imag.jsp?mode="+mode+ "&change=1&type=2&fecha="+fecha+"&fechaHasta="+fechaHasta+"&area="+area+"&solicitado_por="+solicitado_por+"&expediente="+expediente+"&estado="+estado+"&incluir_admision="+incluir_admision);
		return;
	}
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (request.getParameter("baction").equalsIgnoreCase("Cancelar"))
{
%>
	window.close();
<%
}
else
{
	
	if (errCode.equals("1"))
	{
%>
	alert('<%=errMsg%>');
    abrir_ventana2('../expediente/print_hoja_trabajo_lab.jsp?fg=IMG&interfaz=RIS&pacId=<%=pacId%>&noAdmision=<%=admision%>&codSolicitud=<%=codSolicitud%>&codSolicitudDet=<%=codigo%>');

	window.location = '<%="../expediente/reg_sol_imag.jsp"%>?fecha=<%=fecha%>&fechaHasta=<%=fechaHasta%>&area=<%=area%>&solicitado_por=<%=solicitado_por%>&estado=<%=estado%>&incluir_admision=<%=incluir_admision%>';
<%
	} else throw new Exception(errMsg);
}
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