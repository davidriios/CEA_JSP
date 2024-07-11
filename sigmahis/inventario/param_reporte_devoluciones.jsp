
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String almacen = "";
String compania =  (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");

if(fg == null ) fg = "DUA";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario - Devoluciones- '+document.title;
function doAction()
{
}
function showProveedor()
{
	abrir_ventana('../inventario/sel_proveedor.jsp?fp=RDP');
}

function showArea()
{
		var fg = '';
		abrir_ventana1('../inventario/sel_unid_ejec.jsp?fg=DUA');
}
function clearText()
{
 document.form0.codArea.value="";
 document.form0.descArea.value="";
}
function clearDesc()
{
 document.form0.codProv.value  = "";
 document.form0.descProv.value = ""; 
 eval('document.form0.codProv').focus()

}
function showReporte2()
{
	
	var fecha_ini = eval('document.form0.fechaini').value;
	var fecha_fin = eval('document.form0.fechafin').value;
	
	<%if(fg.trim().equals("DUA")){%>
	var anio      = eval('document.form0.anio').value;
	var codigo    = eval('document.form0.codigo').value;
	var wh        = eval('document.form0.almacen').value;
	var depto     = eval('document.form0.depto').value;
	var titulo    = eval('document.form0.titulo').value;
	var area      = eval('document.form0.codArea').value;
	
 abrir_ventana1('../inventario/print_devoluciones_und.jsp?titulo='+titulo+'&depto='+depto+'&tDate='+fecha_ini+'&fDate='+fecha_fin+'&almacen='+wh+'&unidad='+area+'&anio='+anio+'&codigo='+codigo+'&compania=<%=compania%>');
<%}else if(fg.trim().equals("DA")){%>
	var wh_dev        = eval('document.form0.wh_dev').value;
	var wh_rec     = eval('document.form0.wh_rec').value;
	var anio      = eval('document.form0.anio').value;
	var codigo    = eval('document.form0.codigo').value;
	
 abrir_ventana1('../inventario/print_devoluciones_almacen.jsp?tDate='+fecha_ini+'&fDate='+fecha_fin+'&wh_dev='+wh_dev+'&wh_rec='+wh_rec+'&anioDev='+anio+'&noDev='+codigo);
<%}else if(fg.trim().equals("DP")){%>
var wh_dev        = eval('document.form0.wh_dev').value;
var codProv       = eval('document.form0.codProv').value;
var consignacion       = eval('document.form0.consignacion').value;
 abrir_ventana('../inventario/print_list_devolucion_cons.jsp?fg=RDP&tDate='+fecha_ini+'&fDate='+fecha_fin+'&wh='+wh_dev+'&codProv='+codProv+'&consignacion='+consignacion);
<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("DUA")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE DEVOUCIONES DE UNIDADES ADM."></jsp:param>
	</jsp:include>

	<%}else if(fg.trim().equals("DA")){%>

		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE DEVOUCIONES DE ALMACEN"></jsp:param>
	</jsp:include>
	<%}else if(fg.trim().equals("DP")){%>

		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE DEVOUCIONES DE PROVEEDORES"></jsp:param>
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
			<%if(fg.trim().equals("DUA")){%>
			<tr class="TextFilter">
				<td>Departamento</td>
				<td colspan="2"><%=fb.textBox("depto","",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Titulo</td>
				<td colspan="2"><%=fb.textBox("titulo","",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Almacen</td>
				<td colspan="2"><%=fb.select("almacen","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:""%>','KEY_COL','S');
			</script></td>
			</tr>

			<tr class="TextFilter">
			<td>Unidad Administrativa </td>
				<td colspan="2">
					<%=fb.textBox("codArea","",false,false,false,5,null,null,"onFocus=\"javascript:clearText()\"")%>
				 <%=fb.textBox("descArea","",false,false,true,50)%>
				 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>
			 </td>
			</tr>
			<%}else if(fg.trim().equals("DA")){%>
			
			<tr class="TextFilter">
				<td>Devuelto A:</td>
				<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select to_char(codigo_almacen) as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" union  select ' ' optvaluecolumn , 'TODOS LOS ALMACENES' from dual  order by 1","wh_dev","",false,false,0,"Text10",null,"T")%>

     </td>
			</tr>
			
			
			<tr class="TextFilter">
				<td>Devuelto Por</td>
				<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select to_char(codigo_almacen) as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" union  select ' ' optvaluecolumn , 'TODOS LOS ALMACENES' from dual  order by 1","wh_rec","",false,false,0,"Text10",null,"T")%></td>
			</tr>
			
			
			<%}else if(fg.trim().equals("DP")){%>
			
			<tr class="TextFilter">
				<td>Almacen</td>
				<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+"  order by 1","wh_dev","",false,false,0,"T")%>

     </td>
			</tr>
			
			
			<tr class="TextFilter">
				<td>Proveedor</td>
				<td colspan="2"><%=fb.textBox("codProv","",false,false,false,5,null,null,"onFocus=\"javascript:clearDesc()\"")%>
			 <%=fb.textBox("descProv","TODOS LOS PROVEEDORES",false,false,true,30)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>	</td>
			</tr>			<tr class="TextFilter">
				<td>Consignaci&oacute;n</td>
				<td colspan="2"><%=fb.select("consignacion","N=No,S=Si","","")%>	</td>
			</tr>
	
			<%}%>
			
			
			<tr class="TextFilter">
			<td>Fecha</td>
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
		
		<%if(!fg.trim().equals("DP")){%>	
		<tr class="TextFilter">
			<td >DEVOLUCION </td>
			<td colspan="2">Año <%=fb.textBox("anio","",false,false,false,5)%> &nbsp;&nbsp;# <%=fb.textBox("codigo","",false,false,false,5)%></td>	
		</tr>
		<%}%>
		<tr class="TextFilter">
			<td colspan="3" align="center"> <%=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte2()\"")%>	</td>
		</tr>	
			
			
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
