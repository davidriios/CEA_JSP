<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.HL7"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Cliente"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CltMgr" scope="page" class="issi.planmedico.ClienteMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CltMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String clientId = request.getParameter("clientId");
String referTo = request.getParameter("referTo");
String tipo = request.getParameter("tipo"); 
String fg = request.getParameter("fg"); 
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fechaIni= request.getParameter("fechaIni"); 
String fechaFin= request.getParameter("fechaFin"); 
boolean showFac = false;  
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (!mode.equalsIgnoreCase("add") && !mode.equalsIgnoreCase("edit")) viewMode = true;
if (fg == null) fg = "SEG";
String tabFunctions = "'1=tabFunctions(1)', '2=tabFunctions(2)', '5=tabFunctions(5)'";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoQry = new CommonDataObject();
cdoQry = SQLMgr.getData("select query  from tbl_gen_query where id = 0 and refer_to = '"+referTo+"'"); 
System.out.println("query......=\n"+cdoQry.getColValue("query"));

sbSql = new StringBuffer();
sbSql.append("select a.* /*a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, a.dv, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado*/ ");
//if(fg.trim().equals("PAC")||referTo.trim().equals("PAC"))sbSql.append(",direccion,telefono,responsable ");
sbSql.append(" from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
sbSql.append(") a where nvl(compania,1) = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.codigo = '");
sbSql.append(clientId);
sbSql.append("' order by nombre ");
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());
if(cdoHeader.getColValue("direccion") ==null)cdoHeader.addColValue("direccion","");
if(cdoHeader.getColValue("telefono") ==null)cdoHeader.addColValue("telefono","");


	System.out.println("::::::::::::::::::::::::::::::::::::::::::::::: TAB ="+tab);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Mantenimiento de Paciente - '+document.title;
function tabFunctions(tab){
	var iFrameName = '';
	if(tab==1) iFrameName='iFrameSeg';
	else if(tab==2) iFrameName='iFrameNota';
	else if(tab==3) iFrameName='iFrameFacturas';
	else if(tab==4) iFrameName='iFramePagos';
	else if(tab==5) iFrameName='iFrameFacturasRes';
	window.frames[iFrameName].doAction();
}
function doAction()
{ 
   maximizeWin();
	    
}
function showInfo(tab, id, mode){
	var iFrameName = '', page = '';
	if(tab==1){
		iFrameName='iFrameSeg';
		page = '../planmedico/reg_seguimiento.jsp?id_trx=<%=clientId%>&fg=<%=fg%>&id='+id+'&mode='+mode+'&tipo=<%=tipo%>';
	} else if(tab==2){
		iFrameName='iFrameNota';
		page = '../planmedico/reg_notas.jsp?id_trx=<%=clientId%>&fg=<%=fg%>&id='+id+'&mode='+mode+'&tipo=<%=tipo%>';
	}
	window.frames[iFrameName].location=page;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CXC - SEGUIMIENTOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
<div id="dhtmlgoodies_tabView1">
<!--GENERALES TAB0-->
<div class="dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clientId",clientId)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("tipo",tipo)%>
 
		<tr>
			<td colspan="2" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="1">Datos Principales</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel0">
			<td width="100%">
				<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="2">CODIGO:</cellbytelabel></td>
					<td width="25%"><%=cdoHeader.getColValue("codigo")%></td>
					<td width="15%"><cellbytelabel id="2">Nombre Cliente:</cellbytelabel></td>
					<td width="45%"><%=cdoHeader.getColValue("nombre")%></td>
				</tr>  
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="2">Dirección:</cellbytelabel></td>
					<td width="25%"><%=cdoHeader.getColValue("direccion")%></td>
					<td width="15%"><cellbytelabel id="2">&nbsp;</cellbytelabel></td>
					<td width="45%">&nbsp;</td>
				</tr> 
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="2">Telefono:</cellbytelabel></td>
					<td width="25%"><%=cdoHeader.getColValue("telefono")%></td>
					<td width="15%"><cellbytelabel id="2">&nbsp;</cellbytelabel></td>
					<td width="45%">&nbsp;</td>
				</tr> 
 				</table>
			</td>
 		</tr> 
 		<tr class="TextRow02">
			<td colspan="2" align="right">
							<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
 
<%=fb.formEnd(true)%>
		</table>
</div>
				<!-- TAB2 DIV START HERE [SEGUIMIENTO]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","1")%>
				<%=fb.hidden("id_trx","")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("clientId",clientId)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("tipo",tipo)%>

					<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameSeg" id="iFrameSeg" frameborder="0" align="center" width="100%" height="220" scrolling="yes" src="../planmedico/reg_seguimiento.jsp?tipo=<%=tipo%>&id_trx=<%=clientId%>&mode=<%=mode%>&fg=<%=fg%>&tab=1"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				<!-- TAB2 DIV END HERE [SEGUIMIENTO]-->
				</div>
				<!-- TAB3 DIV START HERE [NOTAS]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","2")%>
				<%=fb.hidden("mode",mode)%> 
				<%=fb.hidden("baction","")%> 
				<%=fb.hidden("clientId",clientId)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("tipo",tipo)%>

					<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameNota" id="iFrameNota" frameborder="0" align="center" width="100%" height="220" scrolling="yes" src="../planmedico/reg_notas.jsp?tipo=<%=tipo%>&id_trx=<%=clientId%>&mode=<%=mode%>&fg=<%=fg%>&tab=2"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB3 DIV END HERE [NOTAS]-->

				<% if (showFac) {%>

				<!-- TAB4 DIV START HERE [FACTURAS]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","3")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%=fb.hidden("baction","")%>				
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("tipo",tipo)%>
					<tr class="TextPanel">
						<td colspan="3">FACTURAS DETALADO</td>
						<td align="right">
						   <%=fb.button("ir","Imprimir",true,false,"","","onClick=\"javascript:_goAndPrint('F');\"")%>
						</td>
					</tr>
					 <tr class="TextPanel">
						<td colspan="4"><cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIniF"%>" />
						<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
						<jsp:param name="nameOfTBox2" value="<%="fechaFinF"%>" />
						<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado Factura
						<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cja_tipo_transaccion order by codigo","estadofactF","",false,viewMode,0,null,null,null,null,"T")%>
							<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:_goAndFilter('F');\"")%>
						</td>
                    </tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameFacturas" id="iFrameFacturas" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../planmedico/pm_facturas_list.jsp?clientId=<%=clientId%>&mode=<%=mode%>&tab=3"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB4 DIV END HERE [FACTURAS]-->
				<% } %>

				<!-- TAB5 DIV START HERE [ESTADO DE CUENTA]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","4")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%=fb.hidden("baction","")%> 
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("tipo",tipo)%>
					<tr class="TextFilter">
						<td colspan="3">ESTADO DE CUENTA</td>
						<td align="right">
						   <%=fb.button("ir","Imprimir",true,false,"","","onClick=\"javascript:_goAndPrint('P');\"")%>
						</td>
					</tr>
					<tr class="TextFilter">
						<td colspan="4"><cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIniP"%>" />
						<jsp:param name="valueOfTBox1" value="" />
						<jsp:param name="nameOfTBox2" value="<%="fechaFinP"%>" />
						<jsp:param name="valueOfTBox2" value="" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
							<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:_goAndFilter('P');\"")%>
						</td>
                    </tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFramePagos" id="iFramePagos" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../planmedico/pm_estado_cuenta_list.jsp?clientId=<%=clientId%>&mode=<%=mode%>&clientName=<%=cdoHeader.getColValue("nombre")%>&tab=4"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB5 DIV END HERE [PAGOS]-->
				<% if (showFac) {%>

				<!-- TAB4 DIV START HERE [FACTURAS]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","5")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%=fb.hidden("baction","")%> 
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("tipo",tipo)%>
					<tr class="TextPanel">
						<td colspan="3">FACTURAS</td>
						<td align="right">
						   <%//=fb.button("ir","Imprimir",true,false,"","","onClick=\"javascript:_goAndPrint('F');\"")%>
						</td>
					</tr>
					 <tr class="TextPanel">
						<td colspan="4"><cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIniFR"%>" />
						<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
						<jsp:param name="nameOfTBox2" value="<%="fechaFinFR"%>" />
						<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado Factura
						<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cja_tipo_transaccion order by codigo","estadofactFR","",false,viewMode,0,null,null,null,null,"T")%>
							<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:_goAndFilter('FR');\"")%>
						</td>
                    </tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameFacturasRes" id="iFrameFacturasRes" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../planmedico/pm_facturas_list_res.jsp?clientId=<%=clientId%>&mode=<%=mode%>&tab=3"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB5 DIV END HERE [FACTURAS]-->
				<% } %>
			</div>
<script type="text/javascript">
<%
String tabInactivo="";
String tabLabel = "'Generales'";
if (!mode.equalsIgnoreCase("add")) {
	tabLabel += ",'Seguimiento', 'Notas'";
	 
		//if (showFac) tabLabel += ", 'Facturas Detallado','Estado de Cuenta','Facturas'";
		//else tabLabel += ",'Estado de Cuenta'";
 }
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[]);
</script>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
 	cdo = new CommonDataObject();
 
	Cliente _cdo = new Cliente();
 		 
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>';
}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=edit&tab=<%=tab%>&clientId=<%=clientId%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%} //POST%>