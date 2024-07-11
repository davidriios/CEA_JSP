<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
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

StringBuffer sbSqlVendor = new StringBuffer();
sbSqlVendor.append("select cod_provedor as optValueColumn, nombre_proveedor||' [ '||cod_provedor||' ]' as optLabelColumn from tbl_com_proveedor where compania = ");
sbSqlVendor.append(session.getAttribute("_companyId"));
sbSqlVendor.append(" and estado_proveedor = 'ACT' order by 2");

StringBuffer sbSqlBrand = new StringBuffer();
sbSqlBrand.append("select marca_id as optValueColumn, descripcion||' [ '||codigo||' ]' as optLabelColumn, marca_id as optTitleColumn from tbl_inv_marca where compania = ");
sbSqlBrand.append(session.getAttribute("_companyId"));
sbSqlBrand.append(" and estado = 'A' order by 2");

if (request.getMethod().equalsIgnoreCase("GET")) {
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario de Artículos - '+document.title;
function showBI(){
var vendor=document.search00.vendor.value;
var brand=document.search00.brand.value;
var family=document.search00.family.value;
var clazz=document.search00.clazz.value;
var code=document.search00.code.value;
var description=document.search00.description.value;
var barCode=document.search00.barCode.value;
var status=document.search00.status.value;
var datos=document.search00.datos.value;
var qs='';
if(vendor=='')vendor=0;
if(brand=='')brand=0;
if(family=='')family=0;
if(clazz=='')clazz=0;
if(code.trim()!='')qs+='&pCode='+code;
if(description.trim()!='')qs+='&pDescription='+description;
if(barCode.trim()!='')qs+='&pBarCode='+barCode;
if(status=='')status='T';
abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/articulo_proveedor.rptdesign&pVendor='+vendor+'&pBrand='+brand+'&gpFamily='+family+'&gpClass='+clazz+'&datosParam='+datos+'&pStatus='+status+qs);
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();chkRptType();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
function chkRptType(idx){if(idx==undefined||idx==null||idx=='')idx=0;$('input:radio[name=rptType]').attr('checked',false);$('input:radio[name=rptType]:nth('+idx+')').attr('checked',true);}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true">
	<jsp:param name="formEl" value="search00"></jsp:param>
	<jsp:param name="barcodeEl" value="barCode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value=""></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - REPORTE - ARTICULOS POR PROVEEDOR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<tr>
	<td class="TableBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
			<td width="25%" align="right">Proveedor</td>
			<td width="75%"><%=fb.select(ConMgr.getConnection(),sbSqlVendor.toString(),"vendor","",false,false,false,0,"Text10","","onChange=\"javascript:if(document.search00.consolidated.checked)this.value='';\"","","T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Marca</td>
			<td><%=fb.select(ConMgr.getConnection(),sbSqlBrand.toString(),"brand","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Familia</td>
			<td>
				<%=fb.select("family","","",false,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','clazz','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');\"")%>
				<script language="javascript">loadXML('../xml/itemFamily.xml','family','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>','KEY_COL','T');</script>
			</td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Clase</td>
			<td>
				<%=fb.select("clazz","","",false,false,false,0,"Text10",null,null)%>
				<script>language="javascript">loadXML('../xml/itemClass.xml','clazz','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+document.search00.family.value,'KEY_COL','T');</script>
			</td>
		</tr>
		<tr class="TextFilter">
			<td align="right">C&oacute;digo</td>
			<td><%=fb.textBox("code","",false,false,false,8,"Text10",null,null)%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Descripci&oacute;n</td>
			<td><%=fb.textBox("description","",false,false,false,30,"Text10",null,null)%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">C&oacute;digo Barra</td>
			<td><%=fb.textBox("barCode","",false,false,false,50,"Text10 ignore",null,"onkeypress=\"allowEnter(event);\" onFocus=\"this.select()\"")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Estado</td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Datos</td>
			<td><%=fb.select("datos","M=Mantenimiento,T=Transacciones","",false,false,false,0,"Text10",null,null,null,"")%></td>
		</tr>
		</table>
</div>
</div>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
			<td colspan="2" align="center"><%=fb.button("showReport","Reporte",false,false,null,null,"onClick=\"javascript:showBI();\"")%></td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>