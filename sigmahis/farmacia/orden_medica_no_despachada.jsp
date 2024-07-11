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
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cds = request.getParameter("cds");
String fechaHasta = fecha;


if (cds == null) cds = "";

String cds1 = (String) session.getAttribute("COD_CENTRO1");//utilizado para listado inicial
String cds2 = (String) session.getAttribute("COD_CENTRO2");//utilizado para centros adicionales
if (cds1 == null) cds1 = "";
if (cds2 == null) cds2 = "";
if (fg == null) fg = "ME";

String xCds = "";
if (!cds1.trim().equals("")) {xCds = cds1; if (cds.trim().equals("")) cds = cds1;}
if (!xCds.trim().equals("") && !cds2.trim().equals("") && !cds1.equals(cds2)) xCds += ","+cds2;
else if (!cds2.trim().equals("")) xCds = cds2;
//if (xCds.trim().equals("")) throw new Exception("No hay centros de servicio registrado en las variables ambiente. Por favor consulte con su Administrador!");
if(request.getParameter("fecha")!=null) fecha = request.getParameter("fecha");
if(request.getParameter("fechaHasta")!=null) fechaHasta = request.getParameter("fechaHasta");
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Farmacia- "+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();document.getElementById("pacBarcode").focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,250);}
function doSubmit(){var fecha = document.form1.fecha.value;var fechaHasta = document.form1.fechaHasta.value;var pacBarcode = document.form1.pacBarcode.value;if(document.form1.pacBarcode.value!='')pacBarcode=getPB();var paciente = document.form1.paciente.value;window.frames['itemFrame'].location='../farmacia/orden_medica_no_despachada_det.jsp?fecha='+fecha+'&fechaHasta='+fechaHasta+'&fg=<%=fg%>&paciente='+paciente+'&pacBarcode='+pacBarcode;}
function printOrden(){var fecha = document.form1.fecha.value;var fechaHasta = document.form1.fechaHasta.value;var pacBarcode = document.form1.pacBarcode.value;var paciente = document.form1.paciente.value;abrir_ventana('../farmacia/print_ordenes_no_despachadas.jsp?fg=NODESP&fechaOrden='+fecha+'&fechaHasta='+fechaHasta+'&pacBarcode='+pacBarcode+'&paciente='+paciente);}
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

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - SOLICITUD DE LABORATORIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1" id="_tblMain">
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
				<%=fb.hidden("clearHT","")%>
				<tr class="TextRow02">
					<td colspan="3"><cellbytelabel id="1">Solicitudes</cellbytelabel></td>
				</tr>
				<tr>
					<td colspan="3" align="right">&nbsp;<authtype type='0'><a href="javascript:printOrden()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
                  <cellbytelabel id="3">Paciente</cellbytelabel>
									<%=fb.textBox("paciente","",false,false,false,40,"Text10",null,null)%>
                  <cellbytelabel id="4">Barcode</cellbytelabel>
                  <%=fb.textBox("pacBarcode","",false,false,false,20,"Text10",null,null)%>
									<%=fb.button("Ir","Ir",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%>
									</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="3">
					<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../farmacia/orden_medica_no_despachada_det.jsp?fecha=<%=fecha%>&fechaHasta=<%=fechaHasta%>&cds=<%=(fg.trim().equals("NU"))?cds:xCds%>&fg=<%=fg%>"></iframe>
					</td>
				</tr>
				<%=fb.formEnd(true)%>
				</table>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
		response.sendRedirect("../farmacia/orden_medica_despachada.jsp?mode="+mode+ "&change=1&type=2&fecha="+fecha+"&fechaHasta="+fechaHasta+"&area="+area+"&solicitado_por="+solicitado_por+"&cds="+cds+"&fg="+fg);
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
	window.location = '<%="../farmacia/orden_medica_despachada.jsp"%>?fecha=<%=fecha%>&area=<%=area%>&solicitado_por=<%=solicitado_por%>&fg=<%=fg%>&cds=<%=cds%>';
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