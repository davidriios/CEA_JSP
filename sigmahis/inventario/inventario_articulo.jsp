<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
ArrayList artWh = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "/*********FILTER*******/";
String newFilter = "";
String wh = request.getParameter("wh");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String punto = request.getParameter("punto");
String consigna = request.getParameter("consigna");
String cantidad = request.getParameter("cantidad");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String subclassCode = request.getParameter("subclassCode");
String articulo = request.getParameter("articulo");
String descripcion = request.getParameter("descripcion");
String estado = request.getParameter("estado");

if(punto==null) punto = "";
if(consigna==null) consigna = "";
if(cantidad==null) cantidad = "";
if(articulo==null) articulo = "";
if(descripcion==null) descripcion = "";
if(estado==null) estado = "";

/*====================================================================================*/

/*====================================================================================*/

ArrayList alWh = new ArrayList();
StringBuffer sbSql = new StringBuffer();
sbSql.append("select codigo_almacen as optValueColumn, descripcion||' [ '||codigo_almacen||' ]' as optLabelColumn from tbl_inv_almacen where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by 2");
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

if(request.getMethod().equalsIgnoreCase("GET")) {
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario de Artículos  - '+document.title;
$(document).ready(function(){
	 $('input:radio[name=rptType]').click(function(c){
		 showBI($(this).val());
	 });
});
function showBI(type){
var consolidated=(document.search00.consolidated.checked)?document.search00.consolidated.value:'N';
var wh=document.search00.wh.value;
var family=document.search00.family.value;
var iClass=document.search00.iClass.value;
var code=document.search00.code.value;
var description=document.search00.description.value;
var barCode=document.search00.barCode.value;
var status=document.search00.status.value;
var allocation=document.search00.allocation.value;
var availability=document.search00.availability.value;
var price=document.search00.price.value;
var avgCost=document.search00.avgCost.value;
var codRef=document.search00.codRef.value||'';
var implantable=document.search00.implantable.value||'';
//var rptType=$('input:radio[name=rptType]:checked').val();
var rptType = type;
var qs='';
if(wh=='')wh='ALL';
if(family=='')family='ALL';
if(iClass=='')iClass='ALL';
if(code.trim()!='')qs+='&pCode='+code;
if(description.trim()!='')qs+='&pDescription='+description;
if(barCode.trim()!='')qs+='&pBarCode='+barCode;
if(status=='')status='T';
if(allocation=='')allocation='T';
if(availability=='')availability='T';
if(price=='')price='T';
if(avgCost=='')avgCost='T';
if(rptType==undefined||rptType==null||rptType==''){
	if(document.search00.rptType)rptType=document.getElementById("rptType").value;//send the first available value
	else rptType='I';
	//console.log('......................'+rptType);
}
abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/inventario.rptdesign&pConsolidated='+consolidated+'&pWarehouse='+wh+'&gpFamily='+family+'&gpClass='+iClass+'&pStatus='+status+qs+'&pAllocation='+allocation+'&pAvailability='+availability+'&pType='+rptType+'&pPrice='+price+'&pAvgCost='+avgCost+'&codRef='+codRef+'&implantable='+implantable);
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
	<jsp:param name="triggerFnOnKeypress" value="showBI"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - REPORTE - INVENTARIO DE ARTICULOS"></jsp:param>
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
			<td width="25%" align="right">Almac&eacute;n</td>
			<td width="75%"><%=fb.select("wh",alWh,"",false,false,false,0,"Text10","","onChange=\"javascript:if(document.search00.consolidated.checked)this.value='';\"","","T")%><%=fb.checkbox("consolidated","S",false,false,null,null,"onClick=\"javascript:document.search00.wh.value='';\"")%>Consolidado</td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Familia</td>
			<td>
				<%=fb.select("family","","",false,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','iClass','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');\"")%>
				<script language="javascript">loadXML('../xml/itemFamily.xml','family','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>','KEY_COL','T');</script>
			</td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Clase</td>
			<td>
				<%=fb.select("iClass","","",false,false,false,0,"Text10",null,null)%>
				<script>language="javascript">loadXML('../xml/itemClass.xml','iClass','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+document.search00.family.value,'KEY_COL','T');</script>
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
			<td><%=fb.textBox("barCode","",false,false,false,15,"Text10 ignore",null,"onkeypress=\"allowEnter(event);\" onFocus=\"this.select()\"")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Estado</td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Consignaci&oacute;n</td>
			<td><%=fb.select("allocation","N=NO,S=SI","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Con Disponibilidad</td>
			<td><%=fb.select("availability","N=NO,S=SI,+=POSITIVA,-=NEGATIVA","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Con Precio</td>
			<td><%=fb.select("price","N=NO,S=SI,+=POSITIVA,-=NEGATIVA","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Con Costo Promedio</td>
			<td><%=fb.select("avgCost","N=NO,S=SI,+=POSITIVA,-=NEGATIVA","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Cod Referencia</td>
			<td><%=fb.textBox("codRef","",false,false,false,15,"",null,"onFocus=\"this.select()\"")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Implantable</td>
			<td><%=fb.select("implantable","N=NO,S=SI","",false,false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><authtype type='50,51,52'>Tipo Reporte</authtype></td>
			<td>
				<authtype type='50'><%=fb.radio("rptType","I",false,false,false,null,null,null)%>INVENTARIO</authtype>
				<authtype type='50+51'></br></authtype>
				<authtype type='51'><%=fb.radio("rptType","C",false,false,false,null,null,null)%>CONTABILIDAD</authtype>
				<authtype type='51+52'></br></authtype>
				<authtype type='52'><%=fb.radio("rptType","G",false,false,false,null,null,null)%>GERENCIA</authtype>
			</td>
		</tr>
		<!--<tr class="TextFilter">
			<td>Pto. Reorden</td>
			<td><%//=fb.select("punto","M=MAYOR,ME=MENOR,I=IGUAL",punto,false,false,0,"Text10",null,null,"","T")%> <%//=fb.textBox("cantidad",cantidad,false,false,false,8,"Text10",null,null)%></td>
		</tr>-->
		</table>
</div>
</div>
		<!--<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
			<td colspan="2" align="center"><%=fb.button("showReport","Reporte",false,false,null,null,"onClick=\"javascript:showBI();\"")%></td>
		</tr>
		</table>-->
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>