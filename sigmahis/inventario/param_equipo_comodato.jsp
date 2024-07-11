
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String almacen = "";
String compania = (String) session.getAttribute("_companyId") ;
String fg = request.getParameter("fg");

if(fg == null ) fg = "EC";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario - '+document.title;
function doAction(){}
function showArea(){abrir_ventana('../inventario/sel_unid_ejec.jsp?fg=COMODATO');}
function showProv(){abrir_ventana('../inventario/sel_proveedor.jsp?fp=MAC');}
function showReporte(value)
{
	var fecha_i = eval('document.form0.fechaini').value;
	var fecha_f = eval('document.form0.fechafin').value;
		
	<%if(fg != null && (fg.trim().equals("EC")||fg.trim().equals("EC2"))){%>
	var area = eval('document.form0.codArea').value;

	if(value =='rpt_1')abrir_ventana('../inventario/print_equipo_comodato.jsp?fg=EC&tDate='+fecha_i+'&fDate='+fecha_f+'&unidad='+area);
	else if(value =='rpt_2'){
		   if(fecha_i.trim() && fecha_f.trim()) abrir_ventana('../inventario/print_monitoreo_cargos_eq_comodato.jsp?fg=CARGO&fDate='+fecha_i+'&tDate='+fecha_f+'&unidad='+area); 
		   else alert("Por favor introduzca un rango de fecha");}
	else if(value =='rpt_3'){ if(fecha_i.trim() && fecha_f.trim()) abrir_ventana('../inventario/print_monitoreo_cargos_eq_comodato.jsp?fg=ENT&fechaEntrega='+fecha_i+'&fechaEntregaFin='+fecha_f+'&unidad='+area); 
		   else alert("Por favor introduzca un rango de fecha");}
	
	<%}else if(fg != null && fg.trim().equals("MAC")){//movimiento de articulos a consignacion%>
	
	var prov = eval('document.form0.codProv').value;
	var wh = eval('document.form0.wh').value;
	var articulo = '';
	if(eval('document.form0.articulo'))articulo= eval('document.form0.articulo').value;
	var msg ='';
	//if(prov == "")msg +='Proveedor '
	//if(fecha_i == "")msg +=' , fecha inicial '
	//if(fecha_f == "")msg +=' , fecha Final '
	if(msg =='')
		abrir_ventana('../inventario/print_mov_articulo_consignacion.jsp?fg=EC&tDate='+fecha_i+'&fDate='+fecha_f+'&prov='+prov+'&wh='+wh+'&articulo='+articulo);
	else alert('Seleccione: '+msg);

	<%}else if(fg != null && fg.trim().equals("MINSA")){//Dispositivos Implantables%>
	
	var prov = eval('document.form0.codProv').value;
	var wh = eval('document.form0.wh').value;
	var articulo = '';
	if(eval('document.form0.articulo'))articulo= eval('document.form0.articulo').value;
	var msg ='';
	//if(prov == "")msg +='Proveedor '
	//if(fecha_i == "")msg +=' , fecha inicial '
	//if(fecha_f == "")msg +=' , fecha Final '
	if(msg =='')
		abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_inv_disp_med_implantable.rptdesign&almacen='+wh+'&fDate='+fecha_i+'&tDate='+fecha_f+'&articulo='+articulo+'&proveedor='+prov);	
	else alert('Seleccione: '+msg);

	<%}%>
}
function buscaArticulo(){abrir_ventana('../common/search_articulo.jsp?id=10&fp=CONSIG');} 

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg != null && (fg.trim().equals("EC")||fg.trim().equals("EC2"))){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE EQUIPOS EN COMODATO"></jsp:param>
	</jsp:include>

<%}else if(fg != null && fg.trim().equals("MAC")){//movimiento de articulos a consignacion%>

<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE MOVIMIENTO DE ARTICULOS A CONSIGNACION"></jsp:param>
	</jsp:include>

<%}else if(fg != null && fg.trim().equals("MINSA")){//movimiento de articulos a consignacion%>

<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DISPOSITIVOS MEDICOS IMPLANTABLES"></jsp:param>
	</jsp:include>

<%}%>
<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			
<%if(fg != null && (fg.trim().equals("MAC") || fg.trim().equals("MINSA"))){%>

<tr class="TextFilter">
	<td width="15%">
		ALMACEN</td>
		<td width="85%">
		<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by 1 asc","wh","",false,false,0,"Text10",null,null,null,"S")%>
		
	</td>
</tr>

<tr class="TextFilter">
			<td>PROVEEDOR</td>
			<td colspan="2">
				<%=fb.textBox("codProv","",false,false,false,5)%>
				<%=fb.textBox("descProv","",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProv()\"")%>	</td>
		</tr>
		<tr class="TextFilter">
			<td>ARTICULO</td>
			<td colspan="2">
				<%=fb.textBox("articulo","",false,false,false,10)%>
				<%=fb.textBox("descArticulo","",false,false,true,60)%>
				<%=fb.button("buscarArt","...",true,false,null,null,"onClick=\"javascript:buscaArticulo()\"")%>	</td>
		</tr>
	<%}%>
		<tr class="TextFilter">
			<td>FECHA</td>
			<td colspan="2"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include>
											 </td>

		</tr>
	<%if(fg != null && (fg.trim().equals("EC")||fg.trim().equals("EC2"))){%>
	
		<tr class="TextFilter">
			<td>UNIDAD ADMINISTRATIVA</td>
			<td colspan="2">
				<%=fb.textBox("codArea","",false,false,false,5)%>
				<%=fb.textBox("descArea","",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>
			</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="3">REPORTES</td>
		</tr>
		<tr class="TextRow01" style="cursor:pointer">
			<td colspan="3"> 
			<%=fb.radio("rpt_1","rpt_1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Equipos por Unidad</br>
	<%if(fg != null &&  fg.trim().equals("EC2")){%>		
			<%=fb.radio("rpt_1","rpt_2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Monitoreo de Cargos </br>
			<%=fb.radio("rpt_1","rpt_3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Entrega/Recepcion de Equipos
			<%//=fb.radio("rpt_1","rpt_4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> 
			<%}%>
			</td>
		</tr>
	<%}%>
		<%if(fg != null &&  (fg.trim().equals("MAC") || fg.trim().equals("MINSA"))){%>	
		<tr class="TextFilter">
			<td colspan="3" align="center"> <%=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>	</td>
		</tr>
		<%}%>
	
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
</td></tr>



</table>
</body>
</html>
<%
}//GET
%>
