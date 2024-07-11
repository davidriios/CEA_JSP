<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");

String cds1 = (String) session.getAttribute("COD_CENTRO1");//utilizado para listado inicial
String cds2 = (String) session.getAttribute("COD_CENTRO2");//utilizado para centros adicionales
if (cds1 == null) cds1 = "";
if (cds2 == null) cds2 = "";
if (fp == null) fp = "";
String xCds = "";
if (!cds1.trim().equals("")) xCds = cds1;
if (!xCds.trim().equals("") && !cds2.trim().equals("") && !cds1.equals(cds2)) xCds += ","+cds2;
else if (!cds2.trim().equals("")) xCds = cds2;
if (xCds.trim().equals("")) throw new Exception("No hay centros de servicio registrado en las variables ambiente. Por favor consulte con su Administrador!");
if (cds == null) cds = cds1;

if(request.getParameter("fecha")!=null) fecha = request.getParameter("fecha");
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Solicitudes - "+document.title;
function doAlert(){loaded=false;checkPendingOM();}
function doSubmit(baction){document.form1.baction.value = baction;window.frames['itemFrame'].doSubmit();}
function printLabels(value){window.frames['itemFrame'].printLabels(value);}
function printAll(){var tipoComida = document.form1.tipoComida.value;abrir_ventana('../expediente/print_censo_dieta.jsp?tipoComida='+tipoComida);}
function printAllSol(){abrir_ventana('../expediente/print_censo_dieta.jsp');}
function refreshDetail()
{
	var fecha = document.form1.fecha.value;
	var estado = document.form1.estado.value;
	var cds1 = document.form1.cds.value;
	var cds    = '';
	if (cds1 == '') 	cds = '<%=xCds%>';
	else	cds = document.form1.cds.value;
	setFrameSrc('itemFrame','../expediente/exp_sol_pacientes_det.jsp?fecha='+fecha+'&cds='+cds+'&fg=<%=fg%>&fp=<%=fp%>&estado='+estado);
}
function checkPendingOM(){var gSol=parseInt(document.form1.gSol.value,10);if((gSol)>0){$('#pendingMsg').show(0);
//setTimeout('replaySound(\'pendingSound\',5000)',10);
soundAlert({delay:5000});
}}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();doAlert();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - SOLICITUD DE LABORATORIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1" id="_tblMain">
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("clearHT","")%>
						<%=fb.hidden("xCds",xCds)%>
				<%=fb.hidden("gSol","")%>
				<tr class="TextRow02">
					<td colspan="3"><cellbytelabel id="1">Solicitudes</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td class="TableBottomBorder" colspan="3">
						<table width="100%">
							<tr>
								<td width="18%"><cellbytelabel id="2">Fecha</cellbytelabel>
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="nameOfTBox1" value="fecha"/>
										<jsp:param name="valueOfTBox1" value="<%=fecha%>"/>
									</jsp:include>
									</td>
								<td width="40%">&nbsp;
								Estado:<%=fb.select("estado","P=PENDIENTES,C=CONFIRMADOS,A=AMBOS",estado,false,false,0,"",null,"onChange=\"javascript:refreshDetail()\"")%>

								
								<cellbytelabel id="3">Solicitado por</cellbytelabel>:
									<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where codigo in ("+xCds+")","cds",cds,false,false,0,"Text10",null,null,null,(xCds.indexOf(",")==-1)?"":"T")%>
									&nbsp;
									<%=fb.submit("Ir","Ir",true,false,null,null,"")%>

									</td>
								<td width="42%"><%if(fp.trim().equals("cons")){%>
								&nbsp;&nbsp;&nbsp;
								Tipo comida&nbsp;
								<%=fb.select("tipoComida","1=DESAYUNO,2=ALMUERZO,3=CENA,4=MERIENDA AM,5=MERIENDA PM,6=MERIENDA NOCHE","",false,false,0,"Text10",null,null,null,"T")%>
								&nbsp;
								<%=fb.button("impri","Label de Comida",true,false,null,null,"onClick=\"javascript:printLabels(this.value);\"")%>&nbsp;
								<%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printAll();\"")%>
								<%}%>

							<%//if(fg.trim().equalsIgnoreCase("NU")){%>
							<%//=fb.button("print","Imprimir Dieta",true,false,null,null,"onClick=\"javascript:printAllSol();\"")%>

							<%
							//}
							%>

								

								</td>
							</tr>
						</table>
					</td>
				</tr> <%if(!fp.equals("cons")){%>
				<tr>
					<td width="15%">&nbsp;</td>
					<td width="70%" align="center"><font size="3" id="pendingMsg" style="display:none">Hay Solicitudes pendientes!</font><script language="javascript">blinkId('pendingMsg','red','white');</script>
					<!--<embed id="pendingSound" src="../media/chimes.wav" autostart="false" width="0" height="0"></embed>-->
					</td>
					<td width="15%" align="right">&nbsp;</td>
				</tr><%}%>
				<tr>
					<td colspan="3">
						<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../expediente/exp_sol_pacientes_det.jsp?fecha=<%=fecha%>&cds=<%=(cds!=null && !cds.trim().equals(""))?cds:xCds%>&fg=<%=fg%>&fp=<%=fp%>&estado=<%=estado%>"></iframe>
					</td>
				</tr>

				<tr class="TextRow01">
					<td colspan="3" align="right">
						<%if(!fp.equals("cons")){%><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%><%}%>
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
		response.sendRedirect("../expediente/exp_sol_pacientes.jsp?mode="+mode+ "&change=1&type=2&fecha="+fecha+"&area="+area+"&solicitado_por="+solicitado_por+"&cds="+cds+"&fg="+fg+"&fp="+fp+"&estado="+estado);
		return;
	}
%>
<html>
<head>
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
	window.location = '<%="../expediente/exp_sol_pacientes.jsp"%>?fecha=<%=fecha%>&area=<%=area%>&solicitado_por=<%=solicitado_por%>&fg=<%=fg%>&fp=<%=fp%>&cds=<%=cds%>&estado=<%=estado%>';
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