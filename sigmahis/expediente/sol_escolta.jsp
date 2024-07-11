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
String fp = request.getParameter("fp");
String area = "", solicitado_por = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cdsFrom = request.getParameter("cdsFrom");
String cdsTo = request.getParameter("cdsTo");
String estado = request.getParameter("estado");

if (cdsFrom == null) cdsFrom = "";

String cds1 = (String) session.getAttribute("COD_CENTRO1");//utilizado para listado inicial
String cds2 = (String) session.getAttribute("COD_CENTRO2");//utilizado para centros adicionales

if (cds1 == null) cds1 = "";
if (cds2 == null) cds2 = "";
if (fp == null) fp = "";
String xCds = "";

if (!xCds.trim().equals("") && !cds2.trim().equals("") && !cds1.equals(cds2)) xCds += ","+cds2;
else if (!cds2.trim().equals("")) xCds = cds2;
if (xCds.trim().equals("")) throw new Exception("No hay centros de servicio registrado en las variables ambiente. Por favor consulte con su Administrador!");
if(request.getParameter("fecha")!=null) fecha = request.getParameter("fecha");
if (mode == null) mode = "add";

if (estado==null) estado = "P";
if(fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

//if (cdsFrom.equals("") ) cdsFrom = cds2;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Solicitudes - "+document.title;
function doAction(){loaded=false;checkPendingOM();}
function refreshDetail(){
	var fecha = (document.form1.fecha.value==null?"":document.form1.fecha.value);
	var estado = (document.form1.estado.value==null?"":document.form1.estado.value);
	var cdsFrom = (document.form1.cdsFrom.value==null?"":document.form1.cdsFrom.value);
	var cdsTo = (document.form1.cdsTo.value== null?"":document.form1.cdsTo.value);
	var fg = '<%=fg%>';
	setFrameSrc('itemFrame','../expediente/sol_escolta_det.jsp?fecha='+fecha+'&cdsFrom='+cdsFrom+'&cdsTo='+cdsTo+'&fg=&estado='+estado);

	checkPendingOM();
}
function checkPendingOM(){
	var gSol= parseInt(document.form1.gSol.value,10);
	var estado = document.form1.estado.value;
	//console.log("thebrain>.......................... "+estado);
	if( (gSol)>0 && estado=="P" ){
		document.getElementById('pendingMsg').style.display='';
		//setTimeout('replaySound(\'pendingSound\',5000)',10);
		soundAlert({delay:5000});
	}
}

function _parentReload(){
	window.location = window.location.href;
	//console.log("thebrain>..........................parent reloading...");
}

function getSol(sol){
   document.form1.gSol.value = sol;
   //console.log("thebrain>..........................from parent "+sol);
}

function printReport(id){
	var fecha = document.getElementById("fecha").value;
	var cdsFrom = document.getElementById("cdsFrom").value;
	var cdsTo = document.getElementById("cdsTo").value;
	var estado = document.getElementById("estado").value;
	if (typeof id == "undefined"){
		//print all
		abrir_ventana('print_sol_escolta.jsp?idSol=&fecha='+fecha+'&estado='+estado+'&cdsFrom='+cdsFrom+'&cdsTo='+cdsTo);
	}else{
		//print the selected one
		abrir_ventana('print_sol_escolta.jsp?idSol='+id);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - SOLICITUD DE LABORATORIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("clearHT","")%>
        		<%=fb.hidden("xCds",xCds)%>
				<%=fb.hidden("gSol","")%>
				<tr class="TextRow02">
					<td colspan="3"><cellbytelabel id="1">Solicitudes Anfitri&oacute;n Escolta</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td class="TableBottomBorder" colspan="3">
						<table width="100%">
							<tr>
								<td><cellbytelabel id="2">Fecha</cellbytelabel>
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
									</jsp:include>&nbsp;&nbsp;
								<cellbytelabel id="3">Estado</cellbytelabel>:<%=fb.select("estado","E=EJECUTANDO,C=CANCELADA,F=FINALIZADA,P=PENDIENTE",estado,false,false,0,"",null,"onChange=\"javascript:refreshDetail()\"")%>&nbsp;&nbsp;

								<cellbytelabel id="3">&Aacute;rea Origen</cellbytelabel>:
								<%//=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where codigo in ("+xCds+")","cdsFrom",cdsFrom,false,false,0,"Text10",null,null,null,(xCds.indexOf(",")==-1)?"":"T")%>

								<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where estado = 'A'","cdsFrom",cdsFrom,false,false,0,"Text10",null,null,null,"T")%>

								<cellbytelabel id="3">&Aacute;rea Destino</cellbytelabel>:
								<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where estado = 'A'","cdsTo",cdsTo,false,false,0,"Text10",null,null,null,"T")%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<%=fb.button("btnFiltro","Filtrar",true,false,null,null,"onClick=\"javascript:refreshDetail()\"")%>
								<%=fb.button("btnPrint","Imprimir",true,false,null,null,"onClick=\"javascript:printReport()\"")%>
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
						<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="100%" scrolling="yes" frameborder="0" border="0" src="../expediente/sol_escolta_det.jsp?fecha=<%=fecha%>&cdsFrom=<%=(cdsFrom!=null && !cdsFrom.trim().equals(""))?cdsFrom:xCds%>&fg=<%=fg%>&estado=<%=estado%>" style="height:3000px" > </iframe>
					</td>
				</tr>

				<tr class="TextRow01">
					<td colspan="3" align="right">
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
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
		//response.sendRedirect("../expediente/sol_escolta_det.jsp?mode="+mode+"&fecha="+fecha+"&cdsFrom="+cdsFrom+"&cdsTo="+cdsTo+"&cdsFrom="+cdsFrom+"&fg="+fg+"&fp="+fp+"&estado="+estado);
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
	window.location = '<%="../expediente/exp_sol_pacientes.jsp"%>?fecha=<%=fecha%>&area=<%=area%>&solicitado_por=<%=solicitado_por%>&fg=<%=fg%>&cdsFrom=<%=cdsFrom%>&estado=<%=estado%>';
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