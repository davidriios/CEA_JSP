<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String subclase = request.getParameter("subclase");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String precioVenta = request.getParameter("precioVenta");
String codigo  = request.getParameter("codigo");
String porcentaje = request.getParameter("porcentaje");
String action = request.getParameter("action");
String roundTo = request.getParameter("roundTo");
String basis = request.getParameter("basis");
String processBy = request.getParameter("processBy");
String anaquel = request.getParameter("anaquel");
String almacen = request.getParameter("almacen");
String tipoPrecio = request.getParameter("tipoPrecio");

if (porcentaje == null) porcentaje = "0";
if (action == null) action = "1";
if (roundTo == null) roundTo = "";
if (basis == null) basis = "PV";
if (processBy == null) processBy = "I";
if (anaquel == null) anaquel = "";
if (almacen == null) almacen = "";
if (tipoPrecio == null) tipoPrecio = "";

/*sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'INV_UPD_BATCH_BY'),'P') as process_by from dual");
CommonDataObject cdo = SQLMgr.getData(sbSql);
if (cdo != null) processBy = cdo.getColValue("process_by");*/

XMLCreator xml = new XMLCreator(ConMgr);
xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"int_anaqueles_x_compania"+UserDet.getUserId()+".xml","select * from (select codigo as value_col, codigo||' - '||descripcion as label_col, compania||'@'||codigo_almacen as key_col  from tbl_inv_anaqueles_x_almacen ana where compania = "+(session.getAttribute("_companyId"))+" and cod_anaquel is not null union all select -99 as value_col, -99||' - SIN ANAQUEL' as label_col, compania||'@'||codigo_almacen as key_col  from tbl_inv_almacen ana where compania = "+(session.getAttribute("_companyId"))+" ) z order by 2 asc");

String warnMsg = "El cambio de precio se aplica sobre la BASE seleccionada (PRECIO VENTA / COSTO PROMEDIO) con valor diferente a cero.<br>Al NO APLICAR APROXIMACION, el nuevo precio se redondea en BASE a la CANTIDAD DE DECIMALES definidos en la COMPAÑÍA.";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 400;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (familyCode == null) {
		familyCode = "";
		classCode = "";
	}
	if (subclase == null) subclase = "";
	if (estado == null) estado = "";
	if (consignacion == null) consignacion = "";
	if (venta == null) venta = "";
	if (precioVenta == null) precioVenta = "";
	if (codigo == null) codigo = "";

	if (!familyCode.trim().equals("")) {
		sbFilter.append(" and a.cod_flia = ");
		sbFilter.append(familyCode);

		if (classCode == null) classCode = "";
		if (!classCode.trim().equals("")) { sbFilter.append(" and a.cod_clase = "); sbFilter.append(classCode); }
	}
	if (!subclase.trim().equals("")) { sbFilter.append(" and a.cod_subclase = "); sbFilter.append(subclase); }
	if (!estado.trim().equals("")) { sbFilter.append(" and upper(a.estado) = '"); sbFilter.append(estado); sbFilter.append("'"); }
	if (!consignacion.trim().equals("")) { sbFilter.append(" and upper(a.consignacion_sino) = '"); sbFilter.append(consignacion); sbFilter.append("'"); }
	if (!venta.trim().equals("")) { sbFilter.append(" and upper(a.venta_sino) = '"); sbFilter.append(venta); sbFilter.append("'"); }
	if (precioVenta.equalsIgnoreCase("1")) sbFilter.append(" and a.precio_venta > 0");
	else if (precioVenta.equalsIgnoreCase("0")) sbFilter.append(" and nvl(a.precio_venta,0) = 0");
	else if (precioVenta.equalsIgnoreCase("-1")) sbFilter.append(" and exists (select null from tbl_inv_inventario where compania = a.compania and cod_articulo = a.cod_articulo and art_familia = a.cod_flia and art_clase = a.cod_clase and nvl(precio,0) >= nvl(a.precio_venta,0))");
	if (!codigo.trim().equals("")) { sbFilter.append(" and a.cod_articulo = "); sbFilter.append(codigo); }
	sbFilter.append(" and a.replicado_far='N' ");

	if (request.getParameter("beginSearch") != null) {
		sbSql = new StringBuffer();

				if (!anaquel.equals("") || !almacen.equals("")) sbSql.append("select distinct ");
				else sbSql.append("select ");

		sbSql.append("a.product_id as productId, a.compania as companyCode, a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as description, decode(a.consignacion_sino,'S','SI','NO') as isAppropiation, decode(a.venta_sino,'S','SI','NO') as isSaleItem, decode(a.estado,'A','ACTIVO','I','INACTIVO',' ') as status, a.cod_subclase as subclaseId, nvl(a.precio_venta,0) as salePrice,nvl(a.precio_venta_cr,0) as other10 ");
		sbSql.append(", (select nombre from tbl_inv_familia_articulo where compania = a.compania and cod_flia = a.cod_flia) as familyName");
		sbSql.append(", (select descripcion from tbl_inv_clase_articulo where compania = a.compania and cod_flia = a.cod_flia and cod_clase = a.cod_clase) as className");
		sbSql.append("");
		sbSql.append(", (select count(*) from tbl_inv_pricexlote where cod_articulo = a.cod_articulo and compania = a.compania) as priceHasBeenChanged from tbl_inv_articulo a");

				if (!anaquel.equals("") || !almacen.equals("")) sbSql.append(", tbl_inv_inventario i ");

				sbSql.append(" where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));

				if (!anaquel.equals("") || !almacen.equals("")) {
						sbSql.append(" and a.cod_articulo = i.cod_articulo and a.compania = i.compania ");

						if (!anaquel.equals("") && !anaquel.equals("-99")){
							sbSql.append(" and i.codigo_anaquel = ");
							sbSql.append(anaquel);
						}
						if (!almacen.equals("")){
								sbSql.append(" and i.codigo_almacen = ");
								sbSql.append(almacen);
								sbSql.append(" ");
						}
				}

		sbSql.append(sbFilter);
		sbSql.append(" order by 12,13,6");
		System.out.println("SQL==="+sbSql.toString());
		al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal, Item.class);
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
function doProcess(){
	var porcentaje=document.form0.porcentaje.value;
	var accion=document.form0.action.value;
	var roundTo=document.form0.roundTo.value;
	var basis=document.form0.basis.value;
	var tipoPrecio=document.form0.tipoPrecio.value;
	if(porcentaje=='0'||porcentaje=='')CBMSG.warning('Revise el porcentaje a aplicar!!');
	else showPopWin('../common/run_process.jsp?fp=BATCH_PRICE&actType=50&docType=BATCH_PRICE&familia=<%=familyCode%>&clase=<%=classCode%>&subclase=<%=subclase%>&almacen=<%=almacen%>&anaquel=<%=anaquel%>&articulo=<%=codigo%>&estado=<%=estado%>&consignacion=<%=consignacion%>&venta=<%=venta%>&precioVenta=<%=precioVenta%>&accion='+accion+'&roundTo='+roundTo+'&basis='+basis+'&porcentaje='+porcentaje+'&tipoPrecio='+tipoPrecio,winWidth*.75,winHeight*.65,null,null,'');
}
function forPrinting(){showPopWin('../inventario/print_precioxlote_param.jsp?familyCode=<%=(request.getParameter("familyCode")==null?"":request.getParameter("familyCode"))%>&classCode=<%=(request.getParameter("classCode")==null?"":request.getParameter("classCode"))%>&consignacion=<%=(request.getParameter("consignacion")==null?"":request.getParameter("consignacion"))%>&code=<%=(request.getParameter("code")==null?"":request.getParameter("code"))%>',winWidth*.75,winHeight*.65,null,null,'');}

function getCheckedVal(){
	var al = "<%=al.size()%>";
	var total = 0;
	for (i = 0; i<al; i++){
			if (eval("document.formDetail.check"+i).checked==true){
				total++;
			}
		}
		//console.log("thebrain> [getCheckedVal()] counting selected values... "+total);
	return total;
}

function showPriceHistory(ind){
	 var itemCode=eval('document.formDetail.itemCode'+ind).value;
	 var familyCode=eval('document.formDetail.familyCode'+ind).value;
	 var companyCode=eval('document.formDetail.companyCode'+ind).value;

	 //Es posible que no se haya guardado clase, familia a la hora de cambiar el precio
	 var itemDesc=eval('document.formDetail.itemDesc'+ind).value;
	 var itemFamilyDesc=eval('document.formDetail.itemFamilyDesc'+ind).value;
	 var itemClaseDesc=eval('document.formDetail.itemClaseDesc'+ind).value;

	 showPopWin('../inventario/list_price_history.jsp?itemCode='+itemCode+'&familyCode='+familyCode+'&companyCode='+companyCode+'&itemDesc='+itemDesc+'&itemFamilyDesc='+itemFamilyDesc+'&itemClaseDesc='+itemClaseDesc,winWidth*.85,winHeight*.65,null,null,'');
	 //console.log("thebrain> "+ind);
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function doSearch()
{
	document.search00.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("beginSearch","")%>
		<tr class="TextFilter">
			<td colspan="2">
				<cellbytelabel>Familia</cellbytelabel>
				<%=fb.select("familyCode","","",false,false,0,null,"width:130px","onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
				<script language="javascript">
				loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
				</script>
				<cellbytelabel>Clase</cellbytelabel>
				<%//=fb.select("classCode","","")%>
								<%=fb.select("classCode","","",false,false,0,null,"width:130px","",null,"")%>
				<script language="javascript">
				loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');
				</script>
				<cellbytelabel>Subclase</cellbytelabel>
				<%=fb.textBox("subclase",request.getParameter("subclase"),false,false,false,5,null,null,null)%>
								&nbsp;&nbsp;
								Almac&eacute;n
								<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(session.getAttribute("_companyId"))+" order by codigo_almacen","almacen",almacen,false, false, 0,null,"width:130px","onchange=loadXML('../xml/int_anaqueles_x_compania"+UserDet.getUserId()+".xml','anaquel','','VALUE_COL','LABEL_COL','"+(session.getAttribute("_companyId"))+"@'+this.value,'KEY_COL','')",null,"S")%>
				&nbsp;&nbsp;
				Anaquel:&nbsp;<%=fb.select("anaquel",anaquel,anaquel,false,false,0,null,"width:130px","",null,"S")%>
								<script>
				loadXML('../xml/int_anaqueles_x_compania<%=UserDet.getUserId()%>.xml','anaquel','<%=anaquel%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>@<%=almacen%>','KEY_COL','S');
				</script>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2">
				<cellbytelabel>Estado</cellbytelabel>
				<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"T")%>
				<cellbytelabel>Consignaci&oacute;n</cellbytelabel>
				<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"T")%>
				<cellbytelabel>Venta</cellbytelabel>
				<%=fb.select("venta","S=SI,N=NO",venta,false,false,0,"T")%>
				<%=fb.select("precioVenta","1|CON PRECIO,0|SIN PRECIO,-1|PRECIO <= COSTO",precioVenta,false,false,0,null,null,null,null,"T",null,null,"|")%>
				<cellbytelabel>C&oacute;digo Art&iacute;culo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,10,null,null,null)%>
				<cellbytelabel>ACTUALIZAR POR</cellbytelabel>
				<%=fb.select("processBy","I=ITEM, P=PARAMETROS DE BUSQUEDA",processBy,false,false,0,"Text10",null,"onChange=\"javascript:doSearch()\"",null,"")%>
				<%//=fb.select("cds","",cds,false,false,0,"Text10",null,"onChange=\"javascript:doSearch()\"",null,(xCds.indexOf(",")==-1)?"":"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
<% if (processBy.equalsIgnoreCase("P")) { %>
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("consignacion",consignacion)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("anaquel",anaquel)%>
<%=fb.hidden("almacen",almacen)%>
		<tr class="TextHeader02">
			<td align="right"><label class="RedText"><%=warnMsg%></label></td>
		</tr>
		<tr class="TextHeader02">
			<td align="right">
				<cellbytelabel>Porcentaje</cellbytelabel>: <%=fb.decPlusBox("porcentaje",porcentaje,true,false,(al.size() == 0),5,2.2,"Text10","","")%>
				<cellbytelabel>Acci&oacute;n</cellbytelabel>: <%=fb.select("action","1=INCREMENTAR,-1=DECREMENTAR",action,true,false,(al.size() == 0),0,"S")%>
				<cellbytelabel>Aplicar Aproximaci&oacute;n: <%=fb.select("roundTo","0=NO,0.05=SI",roundTo,false,false,(al.size() == 0),0,null,null,null)%>
				<cellbytelabel>Base</cellbytelabel>: <%=fb.select("basis","PV=PRECIO VENTA,CP=COSTO PROMEDIO,RECEP=P. ULTIMA COMPRA",basis,true,false,(al.size() == 0),0)%>
				<cellbytelabel>Tipo Precio</cellbytelabel>: <%=fb.select("tipoPrecio","PCO=PRECIO VENTA CONTADO,PCR=PRECIO VENTA CREDITO",tipoPrecio,true,false,(al.size() == 0),0)%>
				<authtype type="50"><%=fb.button("save","Actualizar Precio",true,(al.size() == 0),null,null,"onClick=\"javascript:doProcess()\"")%></authtype>
				<authtype type="0"><%=fb.button("printParam","Imprimir",true,(al.size() == 0),null,null,"onClick=\"javascript:forPrinting()\"")%></authtype>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
<% } %>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("consignacion",consignacion)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("anaquel",anaquel)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("beginSearch","")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("consignacion",consignacion)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("anaquel",anaquel)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("beginSearch","")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<%fb = new FormBean("formDetail",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("consignacion",consignacion)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("nextVal",""+nxtVal)%>
<%=fb.hidden("previousVal",""+preVal)%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("anaquel",anaquel)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("beginSearch","")%>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<% if (processBy.equalsIgnoreCase("I")) { %>
<%fb.appendJsValidation("if("+al.size()+"==0||(!document.formDetail.check.checked&&getCheckedVal()==0)){alert('Por favor seleccione al menos un (1) Artículo!');error++;}");%>
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextHeader02">
			<td align="right"><label class="RedText"><%=warnMsg%></label></td>
		</tr>
		<tr class="TextHeader02">
			<td align="right">
				<cellbytelabel>Porcentaje</cellbytelabel>: <%=fb.decPlusBox("porcentaje",porcentaje,true,false,(al.size() == 0),5,2.2,"","","")%>
				<cellbytelabel>Acci&oacute;n</cellbytelabel>: <%=fb.select("action","1=INCREMENTAR,-1=DECREMENTAR",action,true,false,(al.size() == 0),0,"S")%>
				<cellbytelabel>Aplicar Aproximaci&oacute;n: <%=fb.select("roundTo","0=NO,0.05=SI",roundTo,false,false,(al.size() == 0),0,null,null,null)%>
				<cellbytelabel>Base</cellbytelabel>: <%=fb.select("basis","PV=PRECIO VENTA,CP=COSTO PROMEDIO,RECEP=P. ULTIMA COMPRA",basis,true,false,(al.size() == 0),0)%>
				<cellbytelabel>Tipo Precio</cellbytelabel>: <%=fb.select("tipoPrecio","PCO=PRECIO VENTA CONTADO,PCR=PRECIO VENTA CREDITO",tipoPrecio,true,false,(al.size() == 0),0)%>
				<authtype type="50"><%=fb.submit("save","Actualizar Precio",true,(al.size() == 0),null,null,null)%></authtype>
				<authtype type="0"><%=fb.button("printParam","Imprimir",true,(al.size() == 0),null,null,"onClick=\"javascript:forPrinting()\"")%></authtype>
			</td>
		</tr>
		</table>
<% } %>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Precio Anterior</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Precio Venta</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Precio Venta Cr</cellbytelabel></td>
			<td width="14%"><cellbytelabel>Consignaci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Venta</cellbytelabel></td>
<% if (processBy.equalsIgnoreCase("P")) { %>
			<td width="11%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
<% } else { %>
			<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="5%"><authtype type="50"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los articulos listados!")%></authtype></td>
<% } %>
		</tr>
<%
String familyClass = "";
for (int i=0; i<al.size(); i++) {
	Item item = (Item) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!familyClass.equalsIgnoreCase("["+item.getFamilyName()+"] "+item.getClassName())) {
%>
		<tr class="TextHeader01">
			<td colspan="9">[<%=item.getFamilyName()%>] <%=item.getClassName()%></td>
		</tr>
<% } %>
		<%=fb.hidden("itemCode"+i,item.getItemCode())%>
		<%=fb.hidden("familyCode"+i,item.getFamilyCode())%>
		<%=fb.hidden("companyCode"+i,item.getCompanyCode())%>
		<%=fb.hidden("classCode"+i,item.getClassCode())%>
		<%=fb.hidden("subclaseId"+i,item.getSubclaseId())%>
		<%=fb.hidden("isAppropiation"+i,item.getIsAppropiation())%>
		<%=fb.hidden("isSaleItem"+i,item.getIsSaleItem())%>
		<%=fb.hidden("status"+i,item.getStatus())%>
		<%=fb.hidden("salePrice"+i,item.getSalePrice())%>
		<%=fb.hidden("code"+i,item.getItemCode())%>
		<%=fb.hidden("priceHasBeenChanged"+i,item.getPriceHasBeenChanged())%>
		<%=fb.hidden("itemDesc"+i,item.getDescription())%>
		<%=fb.hidden("itemFamilyDesc"+i,item.getFamilyName())%>
		<%=fb.hidden("itemClaseDesc"+i,item.getClassName())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=item.getItemCode()%></td>
			<td><%=item.getDescription()%></td>
			<td align="center"><% if (Integer.parseInt(item.getPriceHasBeenChanged()) > 0) { %><a href="javascript:void(0);" class="Link00" onClick="javascript:showPriceHistory('<%=i%>')"><cellbytelabel>Ver</cellbytelabel></a><% } else { %>-<% } %></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(item.getSalePrice())%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(item.getOther10())%></td>
			<td align="center"><%=item.getIsAppropiation()%></td>
			<td align="center"><%=item.getIsSaleItem()%></td>
			<td align="center"><%=item.getStatus()%></td>
			<td align="center"><% if (!processBy.equalsIgnoreCase("P")) { %><authtype type="50"><%=fb.checkbox("check"+i,"",false,false,null,null,"","")%></a></authtype><% } %></td>
		</tr>
<%
	familyClass = "["+item.getFamilyName()+"] "+item.getClassName();
}
%>
		</table>
</div>
</div>
	</td>
</tr>
<%=fb.formEnd(true)%>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("consignacion",consignacion)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("anaquel",anaquel)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("beginSearch","")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("consignacion",consignacion)%>
<%=fb.hidden("venta",venta)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("action",action)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("anaquel",anaquel)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("beginSearch","")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}else {
	int size = Integer.parseInt(request.getParameter("size"));
	Hashtable<String,CommonDataObject> htParams = new Hashtable<String,CommonDataObject>();
	for (int i=0; i<size; i++) {
		if (request.getParameter("check"+i) != null) {
			CommonDataObject param = new CommonDataObject();
			sbSql = new StringBuffer();
			System.out.println("estado == "+request.getParameter("estado"));
			sbSql.append("{ call sp_inv_upd_pricexlote (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }");
			param.setSql(sbSql.toString());
			param.addInNumberStmtParam(1,(String) session.getAttribute("_companyId"));
			param.addInNumberStmtParam(2,request.getParameter("familyCode"+i));
			param.addInNumberStmtParam(3,request.getParameter("classCode"+i));
			param.addInNumberStmtParam(4,request.getParameter("itemCode"+i));
			param.addInNumberStmtParam(5,request.getParameter("subclaseId"+i));
			param.addInNumberStmtParam(6,request.getParameter("porcentaje"));
			param.addInNumberStmtParam(7,request.getParameter("action"));
			param.addInNumberStmtParam(8,request.getParameter("roundTo"));
			param.addInStringStmtParam(9,request.getParameter("basis"));
			param.addInStringStmtParam(10,"");
			param.addInNumberStmtParam(11,request.getParameter("almacen"));
			param.addInNumberStmtParam(12,request.getParameter("anaquel"));
			param.addInStringStmtParam(13,request.getParameter("estado"));
			param.addInStringStmtParam(14,request.getParameter("consignacion"));
			param.addInStringStmtParam(15,request.getParameter("venta"));
			param.addInStringStmtParam(16,request.getParameter("tipoPrecio"));
			param.setKey(htParams.size());
			try { htParams.put(param.getKey(),param); } catch(Exception e) { System.out.println("Unable to add params!"); }
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"familyCode="+familyCode+"&classCode="+classCode+"&subclase="+subclase+"&estado="+estado+"&consignacion="+consignacion+"&venta="+venta+"&codigo="+codigo+"&porcentaje="+request.getParameter("porcentaje")+"&action="+request.getParameter("action")+"&almacen="+almacen+"&anaquel="+anaquel+"&roundTo="+request.getParameter("roundTo")+"&basis="+request.getParameter("basis"));
	SQLMgr.executeCallableList(htParams);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
	var locationState = '<%=(request.getParameter("locationState")==null || request.getParameter("locationState").trim().equals("")?request.getContextPath()+"/inventario/cambiar_precio_x_lote.jsp":request.getParameter("locationState"))%>';
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert("<%=SQLMgr.getErrMsg()%>");
	window.location='<%=request.getContextPath()+request.getServletPath()%>?familyCode=<%=familyCode%>&classCode=<%=classCode%>&subclase=<%=subclase%>&estado=<%=estado%>&consignacion=<%=consignacion%>&venta=<%=venta%>&codigo=<%=codigo%>&action=<%=action%>&roundTo=<%=roundTo%>&searchQuery=<%=request.getParameter("searchQuery")%>&nextVal=<%=request.getParameter("nextVal")%>&previousVal=<%=request.getParameter("previousVal")%>&searchOn=<%=request.getParameter("searchOn")%>&searchVal=<%=request.getParameter("searchVal")%>&searchType=<%=request.getParameter("searchType")%>&searchDisp=<%=request.getParameter("searchDisp")%>&searchValFromDate=<%=request.getParameter("searchValFromDate")%>&searchValToDate=<%=request.getParameter("searchValToDate")%>&anaquel=<%=request.getParameter("anaquel")%>&almacen=<%=request.getParameter("almacen")%>&beginSearch=';
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>