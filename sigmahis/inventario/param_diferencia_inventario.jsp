
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p?gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Inventario- '+document.title;
function doAction()
{
}

function showReporte(opt, xtraOpt)
{

var msg = '';
var company = eval('document.form0.compania').value ;
var almacen = eval('document.form0.almacen').value ;
var almacenDesc = $("#almacen option:selected").text();
var anaquelx = eval('document.form0.anaquelx').value ;
var anaquely = eval('document.form0.anaquely').value ;
var anio = eval('document.form0.anio').value ;
var consigna = eval('document.form0.consigna').value ;
var consecutivo = eval('document.form0.consecutivo').value ;
var soloDif = eval('document.form0.soloDif').value ;
var estado = eval('document.form0.estado').value ;
var estado_art = eval('document.form0.estado_art').value ;
var fechaNoContado = $("#fecha_no_contado").val();

if(almacen == "")
msg = ' Almacen ';
if(anio == "")
msg += ', a?o ';

if(msg == '')
{
	switch (opt){
	 case '1':
		if (!xtraOpt) abrir_ventana2('../inventario/print_diferencia_sistema.jsp?compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio='+anio+'&consigna='+consigna+'&consecutivo='+consecutivo+'&soloDif='+soloDif+'&estado='+estado+'&estado_art='+estado_art);
				else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_diferencia_sistema.rptdesign&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio='+anio+'&consigna='+consigna+'&consecutivo='+consecutivo+'&soloDif='+soloDif+'&estado='+estado+'&estado_art='+estado_art+'&pCtrlHeader=true&almacenDesc='+almacenDesc);
				break;
	case '2':
		if (!xtraOpt) abrir_ventana2('../inventario/print_diferencia_sistema_x_art.jsp?compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio='+anio+'&consigna='+consigna+'&consecutivo='+consecutivo+'&soloDif='+soloDif+'&estado='+estado+'&estado_art='+estado_art+'&almacenDesc='+almacenDesc);
				else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_diferencia_sistema_x_art.rptdesign&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio='+anio+'&consigna='+consigna+'&consecutivo='+consecutivo+'&soloDif='+soloDif+'&estado='+estado+'&estado_art='+estado_art+'&almacenDesc='+almacenDesc+'&pCtrlHeader=true')
				break;
	case '3':
			 if (fechaNoContado)
		 if (!xtraOpt) abrir_ventana2('../inventario/print_diferencia_sistema_no_contado.jsp?compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio='+anio+'&consigna='+consigna+'&consecutivo='+consecutivo+'&soloDif='+soloDif+'&estado='+estado+'&estado_art='+estado_art+'&almacenDesc='+almacenDesc+'&fecha_no_contado='+fechaNoContado);
				 else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_diferencia_sistema_no_contado.rptdesign&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio='+anio+'&consigna='+consigna+'&consecutivo='+consecutivo+'&soloDif='+soloDif+'&estado='+estado+'&estado_art='+estado_art+'&almacenDesc='+almacenDesc+'&fecha_no_contado='+fechaNoContado+'&pCtrlHeader=true')
			 else CBMSG.error("Por favor ingrese la fecha de no contados!");
			 break;
	default: CBMSG.error("No encontramos el reporte!");
	}

}
else alert('Seleccione '+msg);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE DIFERENCIA EN CONTEO FISICO VS SISTEMA"/>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="1">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>

	<tr class="TextFilter">
		<td width="15%">Compa&ntilde;ia</td>
		<td width="35%">
		<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania where codigo="+(String) session.getAttribute("_companyId")+" ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"")%>

		</td>
		<td width="15%">Almacen</td>
		<td width="35%">	<%=fb.select("almacen","","")%>

			<script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>





											</td>
		</tr>
		<tr class="TextFilter">
			<td>Anaquel Desde</td>
			<td><%=fb.textBox("anaquelx","",false,false,false,5)%></td>
			<td> Hasta</td>
			<td> <%=fb.textBox("anaquely","",false,false,false,5)%></td>
		</tr>

		<tr class="TextFilter">
			<td>A&ntilde;o</td>
			<td><%=fb.textBox("anio","",false,false,false,5)%></td>
			<td> Consecutivo</td>
			<td> <%=fb.textBox("consecutivo","",false,false,false,5)%></td>
		</tr>
		<tr class="TextFilter">
			<td>Diferencia</td><Td><%=fb.select("soloDif","N=TODOS,S=SOLO LOS ARTICULOS CON DIFERENCIAS","")%></td>
			<td colspan="2">F. no Contado
						<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha_no_contado" />
				<jsp:param name="valueOfTBox1" value="" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include> (No contados)
						</td>
		</tr>
		<tr class="TextFilter">
			<td>Consignaci&oacute;n</td><Td><%=fb.select("consigna","N=NO,S=SI","","T")%></td>
			<td>Estado de lista</td><td colspan="2">
						<%=fb.select("estado","P=PENDIENTE,C=NUEVA LISTA,I=INACTIVO,A=ACTIVO,N=ANULADO,X=TODOS","S")%>
						</td>
		</tr>
		<tr class="TextFilter">
			<td>Estados de los art&iacute;culos</td>
			<td colspan="3"><%=fb.select("estado_art","X=TODOS,A=ACTIVOS,I=INACTIVOS","S")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Reportes</td>
			<td colspan="3">
								<table width="100%">
									<tr>
										<td width="30%"><label class="pointer"><%=fb.radio("reporte","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Diferencia Conteo F&iacute;sico vs Sistema</label></td>
										<td width="10%"><a href="javascript:showReporte('1','E')" class="Link00Bold" title="F&iacute;sico vs Sistema">Excel</a></td>
										<td width="60%"></td>
									</tr>
									<tr>
										<td><label class="pointer"><%=fb.radio("reporte","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Diferencia Agrupado por Art&iacute;culos</label></td>
										<td><a href="javascript:showReporte('2','E')" class="Link00Bold" title="Agrupado por Art&iacute;culos">Excel</a></td>
									</tr>
									<authtype type="51">
									<tr>
										<td><label class="pointer"><%=fb.radio("reporte","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos No Contado con Existencia</label></td>
										<td><a href="javascript:showReporte('3','E')" class="Link00Bold" title="No Contado con Existencia">Excel</a></td>
									</tr>
									</authtype>
								</table>
						</td>
		</tr>

		</table>
</td>
</tr>

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET
%>
