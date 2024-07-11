<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");

if (familyCode == null)
{
	familyCode = "";
	classCode = "";
}
if (!familyCode.trim().equals(""))
{
	appendFilter.append(" and a.cod_flia = ");
	appendFilter.append(familyCode);

	if (classCode == null) classCode = "";
	if (!classCode.equals("")) {appendFilter.append(" and a.cod_clase = ");appendFilter.append(classCode);}
}
if (estado == null) estado = "";
if (!estado.trim().equals("")){appendFilter.append(" and upper(a.estado) = '");appendFilter.append(estado);appendFilter.append("'");}
if (consignacion == null) consignacion = "";
if (!consignacion.trim().equals("")){ appendFilter.append(" and upper(a.consignacion_sino) = '");appendFilter.append(consignacion);appendFilter.append("'");}
if (venta == null) venta = "";
if (!venta.trim().equals("")){appendFilter.append(" and upper(a.venta_sino) = '");appendFilter.append(venta);appendFilter.append("'");};

if (request.getMethod().equalsIgnoreCase("GET"))
{
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

	int recsPerPage=100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String codigo  = request.getParameter("code");              // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = request.getParameter("name");
	String subclase =request.getParameter("subclase");
	String barcode = "";
	String almacen = request.getParameter("almacen");
	if(codigo==null) codigo = "";
	if(descrip==null) descrip = "";
	if(subclase==null) subclase = "";
	if(almacen==null) almacen = "";
	if (!almacen.trim().equals("")){
		appendFilter.append(" and q.almacen = ");
		appendFilter.append(almacen);
	}
	if (!codigo.trim().equals("")){
		appendFilter.append(" and upper(a.cod_articulo) like '%");
		appendFilter.append(codigo);
		appendFilter.append("%'");
	}
	if (!descrip.equals("")){
		appendFilter.append(" and upper(a.descripcion) like '%");
		appendFilter.append(descrip.toUpperCase());
		appendFilter.append("%'");
	}
	if (request.getParameter("barcode") != null && !request.getParameter("barcode").equals(""))
	{
		barcode = request.getParameter("barcode");
		if (crypt) {
			try{barcode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		appendFilter.append(" and a.cod_barra = '");
		appendFilter.append(IBIZEscapeChars.forSingleQuots(barcode).trim());
		appendFilter.append("'");
		barcode = "";
	}
	if (!subclase.equals("")){
		appendFilter.append(" and a.cod_subclase like '%");
		appendFilter.append(subclase.toUpperCase());
		appendFilter.append("%'");
	}

	if(!almacen.equals("") && request.getParameter("familyCode") != null){
		sbSql.append("select a.product_id as productId, a.compania as companyCode, q.almacen, a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as description, b.nombre as familyName, c.descripcion as className, nvl(a.consignacion_sino, 'N') isAppropiation, nvl(a.venta_sino, 'N') isSaleItem, nvl(a.estado, ' ') status, a.cod_subclase as subClassCode, (select descripcion from tbl_inv_almacen ia where ia.compania = q.compania and ia.codigo_almacen = q.almacen) almacen_name, q.cantidad from tbl_inv_articulo a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c, tbl_inv_qty_inicial q where a.compania = b.compania and a.cod_flia = b.cod_flia and a.compania = c.compania and a.cod_flia = c.cod_flia and a.cod_clase = c.cod_clase and a.compania = q.compania and a.cod_articulo = q.cod_articulo and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(appendFilter);
		sbSql.append(" order by b.nombre, c.descripcion, a.descripcion");


	System.out.println("SQL:="+sbSql.toString());
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
}
	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - Articulos - '+document.title;
function add(){abrir_ventana('../inventario/reg_saldo_inicial.jsp');}
function edit(almacen, cod_articulo){abrir_ventana('../inventario/reg_saldo_inicial.jsp?mode=edit&almacen='+almacen+'&codigo='+cod_articulo);}
function editCostoProm(id){abrir_ventana('../inventario/editar_costo_promedio.jsp?mode=edit&id='+id);}
function  printList(){abrir_ventana('../inventario/print_list_articulos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter.toString())%>');}
function updateBC(){abrir_ventana("../inventario/reg_cod_barra_x_lote.jsp");}
function checkChar(){
	var barcode = $.URLEncode(document.search00.barcode.value);
	//alert(barcode);
	if(document.search00.barcode.value!='') document.search00.barcode.value=$.URLEncode(document.search00.barcode.value);
	document.search00.submit();
}

$.extend ({
URLEncode: function (s) {
s = encodeURIComponent (s);
s = s.replace (/\~/g, '%7E').replace (/\!/g, '%21').replace (/\(/g, '%28').replace (/\)/g, '%29').replace (/\'/g, '%27');
s = s.replace (/%20/g, '+');
return s;
},
URLDecode: function (s) {
s = s.replace (/\+/g, '%20');
s = decodeURIComponent (s);
return s;
}
});
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();document.search00.barcode.focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search00"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="name,test"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1" id="_tblMain">
	<tr>
		<td>
 <table width="100%" cellpadding="1" cellspacing="0">

<tr>
	<td colspan="4" align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo ]</a></authtype>
	</td>
</tr>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<td colspan="2">
		almac&eacute;n
		<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion","almacen",almacen,false,false,0, "text10", "", "", "", "S")%>
		Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');
		</script>
	</td>
</tr>
<tr class="TextFilter">
	<td >
		Estado
		<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"T")%>
		Consignaci&oacute;n
		<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"T")%>
		Venta
		<%=fb.select("venta","S=SI,N=NO",venta,false,false,0,"T")%>
	</td>
	<td width="50%"> Cod Subclase
		<%=fb.textBox("subclase",subclase,false,false,false,30,null,null,null)%>
		</td>
</tr>

<tr class="TextFilter">
	<td width="40%">
		C&oacute;digo
		<%=fb.textBox("code",codigo,false,false,false,30,null,null,null)%>
	</td>
	<td width="60%">
		Nombre
		<%=fb.textBox("name",descrip,false,false,false,50,null,null,null)%>

		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C&oacute;d Barra
		<%=fb.textBox("barcode",barcode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
		<%=fb.submit("go","Ir")%>
	</td>
<%=fb.formEnd()%>
</tr>
</table>
 </td>
</tr>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	<tr>
	<td align="right">&nbsp;<authtype type='0'><!--<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>--></authtype></td>
</tr>
 <tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
 <tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">C&oacute;digo</td>
			<td width="44%">Nombre</td>
			<td width="10%">Consignaci&oacute;n Si/No</td>
			<td width="10%">Venta Si/no</td>
			<td width="6%">Estado</td>
			<td width="10%">Cantidad Ini.</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String familyClass = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!familyClass.equalsIgnoreCase("["+cdo.getColValue("FamilyName")+"] "+cdo.getColValue("ClassName")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="7">[<%=cdo.getColValue("FamilyName")%>] <%=cdo.getColValue("ClassName")%></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("ItemCode")%></td>
			<td><%=cdo.getColValue("Description")%></td>
			<td align="center"><%=cdo.getColValue("IsAppropiation")%></td>
			<td align="center"><%=cdo.getColValue("IsSaleItem")%></td>
			<td align="center"><%=cdo.getColValue("Status")%></td>
			<td align="center"><%=cdo.getColValue("cantidad")%></td>
			<td align="center">
				<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("almacen")%>,<%=cdo.getColValue("ItemCode")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
			</td>
		</tr>
<%
	familyClass = "["+cdo.getColValue("FamilyName")+"] "+cdo.getColValue("ClassName");
}
%>
		</table>
	</div>
	</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>

			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>