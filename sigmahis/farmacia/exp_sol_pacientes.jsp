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
String area = "", solicitado_por = "";
String cds = request.getParameter("cds");
String pacBarcode = request.getParameter("pacBarcode");
String paciente = request.getParameter("paciente");
String compania = (String) session.getAttribute("_companyId");
String companiaRef = "";
try {companiaRef =java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");}catch(Exception e){ companiaRef = "";}
if(companiaRef == null || companiaRef.trim().equals("")) companiaRef = "";
String compFar ="";
try {compFar =java.util.ResourceBundle.getBundle("farmacia").getString("compFar");}catch(Exception e){ compFar = "";}
if(compFar == null || compFar.trim().equals("")) compFar = "";
String status = request.getParameter("status");
String orden = request.getParameter("orden");
String timer = request.getParameter("timer");
String fecha ="";
String fechaHasta = "";

if(status == null)status="PP";
if (fg == null) fg = "ME";
if (timer == null) timer = "S";
if (orden == null) orden = "D";
//if (fg.trim().equals("BM")&& !compania.trim().equals(companiaRef) ) throw new Exception("Opcion Solo Para Compañia Hospital!");
//else 
 cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+compania+",'FAR_ALERTA_INTERVAL'),'0.5') alerta_interval, nvl(get_sec_comp_param("+compania+",'FAR_SET_FECHA'),'N') set_fecha, nvl(get_sec_comp_param(-1,'FAR_OM_CDS_EXPANDED'),'Y') as cds_expanded,nvl(get_sec_comp_param("+compania+",'USA_SYS_FAR_EXTERNA'),'N') as usa_sys_far_externa from dual");
 if (cdo == null) cdo = new CommonDataObject();

if(cdo.getColValue("set_fecha").trim().equals("S"))
{
  fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
  fechaHasta = CmnMgr.getCurrentDate("dd/mm/yyyy");
}

boolean excep=true;
if (fg.trim().equals("BM")){excep=false;}
else if (!fg.trim().equals("BM")){ 
if (compania.trim().equals(companiaRef)&&cdo.getColValue("usa_sys_far_externa","N").trim().equals("N")){excep=true;}
else excep=false;}

if(request.getParameter("fecha")!=null) fecha = request.getParameter("fecha");
if(request.getParameter("fechaHasta")!=null) fechaHasta = request.getParameter("fechaHasta");
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  String delay = cdo.getColValue("alerta_interval","0.5");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Farmacia - "+document.title;
var xHeight=0;
function doAction(){<%if(excep){%>CBMSG.warning('Estimado usuario la Opcion Seleccionada es solo para la Compañia Farmacia!');<%}%>loaded=false;checkPendingOM();xHeight=objHeight('_tblMain');resizeFrame();document.getElementById("pacBarcode").focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,250);}
function doSubmit(){var fecha = document.form1.fecha.value;var fechaHasta = document.form1.fechaHasta.value;var pacBarcode = document.form1.pacBarcode.value;
if(document.form1.pacBarcode.value!='')pacBarcode=getPB();
var paciente = document.form1.paciente.value;var status = document.form1.status.value;var cds = document.form1.cds.value;var orden = document.form1.orden.value;window.frames['itemFrame'].location='../farmacia/exp_sol_pacientes_det.jsp?fecha='+fecha+'&fechaHasta='+fechaHasta+'&fg=<%=fg%>&timer=<%=timer%>&paciente='+paciente+'&pacBarcode='+pacBarcode+'&estado='+status+'&cds='+cds+'&orden='+orden+'&timer=<%=timer%>&setFecha=<%=cdo.getColValue("set_fecha")%>&cdsExpanded=<%=cdo.getColValue("cds_expanded")%>';}
function checkPendingOM(){var gSol=parseInt(document.form1.gSol.value,10);if((gSol)>0){
document.getElementById('pendingMsg').style.display='';

var delay = parseInt("<%=delay%>" * 60 * 1000,10);
soundAlert({delay:delay});}}
function getPB(){ 
  var pb = $("#pacBarcode").val(), _pb = "";
  if (pb.indexOf("-") > 0){
	try{
	  _pb = pb.split("-");
	  _pb = _pb[0].lpad(10,"0")+""+_pb[1].lpad(3,"0");
	}catch(e){_pb="";}
  }else if (pb.trim().length == 13) _pb = pb;
  return _pb;
}

jQuery(document).ready(function(){
       $("#pacBarcode").keyup(function(e){
		var pacBrazalete = pacId = noAdmision = "";
		var key;
		(window.event) ? key = window.event.keyCode : key = e.which;
        var self = $(this);
		
		if(key == 13){
			pacBrazalete = getPB(self.val());
            pacId = parseInt(pacBrazalete.substr(0,10),10);
		    noAdmision = parseInt(pacBrazalete.substr(10),10); 
			doSubmit();
		}
	});
});

function printList(){var fecha = document.form1.fecha.value;var fechaHasta = document.form1.fechaHasta.value;var pacBarcode = document.form1.pacBarcode.value;
if(document.form1.pacBarcode.value!='')pacBarcode=getPB();
var paciente = document.form1.paciente.value;var status = document.form1.status.value;var cds = document.form1.cds.value;var orden = document.form1.orden.value;
 abrir_ventana('../farmacia/print_list_ordenes.jsp?fecha='+fecha+'&fechaHasta='+fechaHasta+'&fg=<%=fg%>&timer=<%=timer%>&paciente='+paciente+'&pacBarcode='+pacBarcode+'&estado='+status+'&cds='+cds+'&orden='+orden+'&setFecha=<%=cdo.getColValue("set_fecha")%>&cdsExpanded=<%=cdo.getColValue("cds_expanded")%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FARMACIA - SOLICITUD DE MEDICAMENTOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1"   id="_tblMain">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("timer",timer)%>
				<%=fb.hidden("clearHT","")%>
				<%=fb.hidden("gSol","")%>
				<tr class="TextRow02">
					<td colspan="3" class="RedTextBold"><cellbytelabel id="1">*Las descripciones en Rojo Corresponden  a Productos de Banco De Medicamentos</cellbytelabel></td>
				</tr>
				<tr>
					<td colspan="3" align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
				</tr>
				<tr class="TextRow01">
					<td class="TableBottomBorder" colspan="3">
						<table width="100%">
							<tr>
								<td><cellbytelabel>Fecha</cellbytelabel>
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
										<jsp:param name="nameOfTBox2" value="fechaHasta" />
										<jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
									</jsp:include>
                  <cellbytelabel id="3">Paciente</cellbytelabel>
									<%=fb.textBox("paciente","",false,false,false,25,"Text10",null,null)%>
                  <cellbytelabel id="4">Barcode</cellbytelabel>
                  <%=fb.textBox("pacBarcode","",false,false,false,20,"Text10",null,null)%>&nbsp;&nbsp;Estado: 
				  <%=fb.select("status","PP=PENDIENTE,R=RECIBIDO,P=POR DESPACHAR,A=DESPACHADO,D=DESAPROBADA",status,false,false,0,"Text10",null,null,null,"T")%>
				  <%sql = "select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where estado = 'A' /*and origen ='S'*/ and compania_unorg="+companiaRef+" order by descripcion";%><br>
				  <cellbytelabel id="4">Solicitado por</cellbytelabel>:
				  <%=fb.select(ConMgr.getConnection(), sql, "cds", cds, false, false, 0,"Text10",null,null,null, "T")%>
				  <cellbytelabel id="4">Orden</cellbytelabel>:<%=fb.select("orden","A=ASC,D=DESC",orden,false,false,0,"Text10",null,null,null,"T")%>
                  <%=fb.button("Ir","Ir",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%>
									</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td width="15%">&nbsp;</td>
					<td width="70%" align="center"><font size="3" id="pendingMsg" style="display:none">Hay Solicitudes pendientes!</font><script language="javascript">blinkId('pendingMsg','red','white');</script><!--<embed id="pendingSound" src="../media/chimes.wav" autostart="false" width="0" height="0"></embed>--></td>
					<td width="15%" align="right">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">
<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../farmacia/exp_sol_pacientes_det.jsp?fecha=<%=fecha%>&fechaHasta=<%=fechaHasta%>&fg=<%=fg%>&estado=<%=status%>&cds=<%=cds%>&timer=<%=timer%>&orden=<%=orden%>&setFecha=<%=cdo.getColValue("set_fecha")%>&cdsExpanded=<%=cdo.getColValue("cds_expanded")%>"></iframe>
					</td>
				</tr>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table>
		</td>
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

	if(request.getParameter("baction")!=null && (request.getParameter("baction").equalsIgnoreCase("Guardar"))){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	} else {
		response.sendRedirect("../farmacia/exp_sol_pacientes.jsp?mode="+mode+ "&change=1&type=2&fecha="+fecha+"&area="+area+"&solicitado_por="+solicitado_por+"&fg="+fg+"&timer="+timer+"&cds="+cds+"&status="+status+"&orden="+orden);
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
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
	window.location = '<%="../farmacia/exp_sol_pacientes.jsp"%>?fecha=<%=fecha%>&area=<%=area%>&solicitado_por=<%=solicitado_por%>&fg=<%=fg%>&timer=<%=timer%>&cds=<%=cds%>&pacBarcode=<%=pacBarcode%>&paciente=<%=paciente%>&status=<%=status%>&orden=<%=orden%>';
	
	
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