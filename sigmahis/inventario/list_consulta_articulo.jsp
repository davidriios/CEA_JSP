<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Delivery"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="DelMgr" scope="page" class="issi.inventory.DeliveryMgr" />
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
DelMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();
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
String costoCero = request.getParameter("costoCero");
String barCode ="", codRef = "", implantable = "";
if(punto==null) punto = "";
if(consigna==null) consigna = "";
if(cantidad==null) cantidad = "";
if(articulo==null) articulo = "";
if(descripcion==null) descripcion = "";
if(estado==null) estado = "";
if(costoCero==null) costoCero = "";



/*====================================================================================*/

/*====================================================================================*/


alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null || wh.trim().equals(""))
{
	if (alWh.size() > 0) wh = ((CommonDataObject) alWh.get(0)).getOptValueColumn();
	else wh = "";
}
else {
	appendFilter += " and al.codigo_almacen="+wh;
		 newFilter = " and r.codigo_almacen="+wh;
}

if (familyCode == null) familyCode = "";
if (!familyCode.equals(""))
{
	appendFilter += " and i.art_familia="+familyCode;

if (classCode == null) classCode = "";
if (!classCode.equals("")) appendFilter += " and i.art_clase="+classCode;
}
	
	if (request.getParameter("codRef") != null && !request.getParameter("codRef").equals("")) {
		codRef = request.getParameter("codRef");
		appendFilter += " and a.cod_Ref = '"+codRef+"'";
	}
	
	if (request.getParameter("implantable") != null && !request.getParameter("implantable").equals("")) {
		implantable = request.getParameter("implantable");
		appendFilter += " and a.implantable = '"+implantable+"'";
	}



if(request.getMethod().equalsIgnoreCase("GET"))
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
	if (request.getParameter("consigna") != null && !request.getParameter("consigna").trim().equals(""))
	{
	appendFilter += " and a.consignacion_sino= '"+request.getParameter("consigna")+"'";
	}
	 if (request.getParameter("punto") != null && request.getParameter("cantidad") != null)
	{
		if (request.getParameter("punto").trim().equals("M"))
				appendFilter += " and i.pto_reorden >= "+request.getParameter("cantidad");
		else if (request.getParameter("punto").trim().equals("ME"))
				appendFilter += " and i.pto_reorden <= "+request.getParameter("cantidad");
		else if (request.getParameter("punto").trim().equals("I"))
				appendFilter += " and i.pto_reorden = "+request.getParameter("cantidad");
	}

	if (request.getParameter("articulo") != null && !request.getParameter("articulo").trim().equals(""))
	{
		appendFilter += " and upper(i.cod_articulo) like '%"+request.getParameter("articulo").toUpperCase()+"%'";
	}
	if (request.getParameter("costoCero") != null && !request.getParameter("costoCero").trim().equals("")&& request.getParameter("costoCero").trim().equals("S"))
	{
		appendFilter += " and nvl(i.precio,0) =0";
	}
	 if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	}
	 if (request.getParameter("subclassCode") != null && !request.getParameter("subclassCode").trim().equals(""))
	{
		appendFilter += " and a.cod_subclase = "+request.getParameter("subclassCode");
	}
	 if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
		appendFilter += " and a.estado = '"+request.getParameter("estado")+"'";
	}

	if (request.getParameter("barcode") != null && !request.getParameter("barcode").trim().equals(""))
	{
		barCode = request.getParameter("barcode");
		if (crypt) {
			try{barCode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		appendFilter += " and a.cod_barra = '"+IBIZEscapeChars.forSingleQuots(barCode).trim()+"'";
		barCode = "";
	}

	 if(!appendFilter.trim().equals(""))
	{
	appendFilter +=" and replicado_far='N' ";
		sql = "select a.cod_flia cod_familia, a.cod_clase ,i.cod_articulo, nvl(a.descripcion,' ') desArticulo,al.descripcion descAlmacen , i.codigo_almacen, nvl(i.disponible,0) disponible, nvl(i.pto_reorden,0)pto_reorden, nvl(i.pto_max_existencia,0)pto_max_existencia, nvl(i.ultimo_precio,0) ultimo_precio, a.cod_flia||'-'||a.cod_clase||'-'||i.cod_articulo articulo , to_char(i.ultima_compra,'dd/mm/yyyy')ultimo_compra, nvl(i.precio,0)precio, nvl((select codigo||' - '||descripcion from tbl_inv_anaqueles_x_almacen where compania = i.compania and codigo_almacen = i.codigo_almacen and codigo = i.codigo_anaquel),'- SIN ANAQUEL -') codigo_anaquel, nvl(i.descuento,0)descuento, nvl(i.porcentaje,0)porcentaje, nvl(i.costo_por_almacen,0)costo_x_almacen, nvl(i.saldo_activo,0)saldo_activo, nvl(i.reservado,0)reservado, nvl(i.transito,0)transito, nvl(i.disp_ant_pamd,0)disp_ant_pamd, nvl(i.rebajado,' ')rebajado,nvl(a.precio_venta,0) precioVenta, a.cod_barra,nvl(a.precio_venta_cr,0) as precioVenta_cr from tbl_inv_inventario i,tbl_inv_articulo a,tbl_inv_almacen al where i.cod_articulo = a.cod_articulo(+) and i.compania = a.compania(+) and i.COMPANIA = "+(String) session.getAttribute("_companyId")+" and i.codigo_almacen = al.codigo_almacen(+) and i.compania = al.compania(+) "+appendFilter +" order by i.codigo_almacen,a.cod_flia, a.cod_clase,i.cod_articulo asc";



al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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

	/*Hashtable htAlmacen = new Hashtable();
	for (int i=0; i<artWh.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) artWh.get(i);

		 htAlmacen.put(cdo.getColValue("articulo"),cdo);
	}*/


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - Consulta  - '+document.title;

function printList(bi)
{
	if(!bi) abrir_ventana('print_list_consulta_articulo.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
	else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_list_consulta_articulo.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&pCtrlHeader=true');
}

function view(familia, clase, articulo)
{
	abrir_ventana('../inventario/list_consulta_articulo.jsp?mode=view&articulo='+articulo);

}

function ver(id, wh, j)
{
	abrir_ventana('../inventario/consulta_recepcion_articulo.jsp?articulo='+id+'&wh='+wh);

}


function getMain(formX)
{
	formX.wh.value         = document.searchMain.wh.value;
	formX.familyCode.value = document.searchMain.familyCode.value;
	formX.classCode.value  = document.searchMain.classCode.value;
	formX.consigna.value   = document.searchMain.consigna.value;
	formX.punto.value      = document.searchMain.punto.value;

	return true;
}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true">
	<jsp:param name="formEl" value="searchMain"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value=""></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - REPORTE - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="7" align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
//{
%>
<%
//}
%>
		&nbsp;
		</td>
	</tr>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

	<tr class="TextFilter">
		<td colspan="5">
			Almac&eacute;n:&nbsp;
			<%=fb.select("wh",alWh,wh,false, false, 0, "text10", "", "", "Almacén", "T")%>
		</td>
		<td colspan="2">Estado:<%=fb.select("estado","A=Activo,I=Inactivo", estado,false, false, 0,"text10",null,"")%></td>
		</tr>
	<tr class="TextFilter">
		<td width="30%" colspan="3">Familia:
			<%=fb.select("familyCode","","",false,false,0,"text10",null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');loadXML('../xml/subclase.xml','subclassCode','"+subclassCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value+'-'+document.searchMain.classCode.value,'KEY_COL','T')\"")%>
			<script language="javascript">
			loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
			</script>
			</td>
			<td width="30%" colspan="3">
			Clase:
			<%=fb.select("classCode","","",false,false,0,"text10",null,"onChange=\"javascript:loadXML('../xml/subclase.xml','subclassCode','"+subclassCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.searchMain.familyCode.value+'-'+this.value,'KEY_COL','T')\"")%>
			<script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.searchMain.familyCode.value"%>,'KEY_COL','T');
			</script>
			</td>
			<td width="40%" colspan="2">
			Subclase:
			<%=fb.select("subclassCode","","",false,false,0,"text10",null,"")%>
			<script language="javascript">
			loadXML('../xml/subclase.xml','subclassCode','<%=subclassCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-<%=(familyCode != null && !familyCode.equals(""))?familyCode:"document.searchMain.familyCode.value"%>-<%=(classCode != null && !classCode.equals(""))?classCode:"document.searchMain.classCode.value"%>','KEY_COL','T');
			</script>
			</td>
		</tr>
		<tr class="TextFilter">
		 <td> Consignaci&oacute;n:
		 <br>
		 <%=fb.select("consigna","N=NO, S=SI",consigna,false,false,0,"Text10",null,null,"","T")%>
		 </td>
		 <td>
		 Costo Cero:
		 <br>
		 <%=fb.select("costoCero","N=NO, S=SI",costoCero,false,false,0,"Text10",null,null,"","T")%>
		 </td>
		 <td width="25%">Pto. Reorden:<br>
		 <%=fb.select("punto","M=MAYOR, ME=MENOR, I=IGUAL",punto,false,false,0,"Text10",null,null,"","T")%> <%=fb.textBox("cantidad",cantidad,false,false,false,8,null,null,null)%>
		</td>
		<td width="35%">
		 Cod. Articulo/Descripci&oacute;n:<br>
			<%=fb.textBox("articulo",articulo,false,false,false,8,null,null,null)%>
			<%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
		</td>
		 <td>
		C.Barra <%=fb.textBox("barcode",barCode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
		</td>
	<td>
		Cod. Rererencia:<br>
		<%=fb.textBox("codRef",codRef,false,false,false,15,"",null,"onFocus=\"this.select()\"")%>
	</td>
	<td>
		Implantable?:<br>
		<%=fb.select("implantable","S=SI,N=NO",implantable,false,false,0,"T")%><%=fb.submit("go","Ir")%>
	</td>
	</tr>
		<%=fb.formEnd()%>
<!------>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
//{
%>
	 <authtype type='0'>
			<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
			<a href="javascript:printList(1)" class="Link00">[ Imprimir Lista (Excel) ]</a>
	 </authtype>
<%
//}
%>
		&nbsp;
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp" );
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
		<%=fb.hidden("punto",punto).replaceAll(" id=\"punto\"","")%>
		<%=fb.hidden("consigna",consigna).replaceAll(" id=\"consigna\"","")%>
		<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
		<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
		<%=fb.hidden("cantidad",cantidad).replaceAll(" id=\"cantidad\"","")%>
		<%=fb.hidden("articulo",articulo).replaceAll(" id=\"articulo\"","")%>
		<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
		<%=fb.hidden("costoCero",""+costoCero)%>
<%=fb.hidden("codRef",codRef)%>
<%=fb.hidden("implantable",implantable)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
			<%=fb.hidden("punto",punto).replaceAll(" id=\"punto\"","")%>
			<%=fb.hidden("consigna",consigna).replaceAll(" id=\"consigna\"","")%>
			<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
			<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
			<%=fb.hidden("cantidad",cantidad).replaceAll(" id=\"cantidad\"","")%>
			<%=fb.hidden("articulo",articulo).replaceAll(" id=\"articulo\"","")%>
				<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
			<%=fb.hidden("costoCero",""+costoCero)%>
<%=fb.hidden("codRef",codRef)%>
<%=fb.hidden("implantable",implantable)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tbody id="list">
	<tr class="TextHeader" align="center">
		<td colspan="15">Consulta De Art&iacute;culos en Inventario</td>
	</tr>
	<tr class="TextHeader" align="center">
		<td colspan="3" width="10%">Código</td>
	<td width="5%">C.Barra</td>
		<td width="15%">Descripción</td>
		<td width="5%" align="right">Disponible</td>
		<td width="11%">Almacen</td>
		<td width="05%" align="right">Pto Reorden</td>
	<td width="12%">Ubic.</td>
	<td width="07%" align="right">Existencia Max.</td>
	<td width="06%" align="right">C. Promedio</td>
	<td width="06%" align="right">Precio Venta</td>
	<td width="06%" align="right">Ultimo Precio</td>
	<td width="05%" align="right">Precio Venta Cr</td>
	<td width="06%" align="right"></td>
	</tr>
				<%
				String whName = "";
				for (int i=0; i<al.size(); i++)
				{
					 CommonDataObject cdo = (CommonDataObject) al.get(i);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";

				 %>
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

					<td align="center"><%=cdo.getColValue("cod_familia")%></td>
					<td align="center"><%=cdo.getColValue("cod_clase")%></td>
					<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td align="center"><%=cdo.getColValue("cod_barra")%></td>
					<td><%=cdo.getColValue("desArticulo")%></td>
					<td align="right"><%=cdo.getColValue("disponible")%></td>
					<td><%=cdo.getColValue("descAlmacen")%></td>
			<td align="right"><%=cdo.getColValue("pto_reorden")%></td>
			<td><%=cdo.getColValue("codigo_anaquel")%></td>
					<td align="right"><%=cdo.getColValue("pto_max_existencia")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("precio"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("precioVenta"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("ultimo_precio"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("precioVenta_cr"))%></td>


			<td align="center">

			<!--  Ver&nbsp;<img src="../images/dwn.gif" onClick="javascript:ver('<%=cdo.getColValue("articulo")%>',<%=cdo.getColValue("codigo_almacen")%>,<%=i%>)" style="cursor:pointer">--->


			 <a href="javascript:ver('<%=cdo.getColValue("articulo")%>',<%=cdo.getColValue("codigo_almacen")%>,<%=i%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a><!--------->
			</td>


				</tr>
				<%
					whName = cdo.getColValue("descAlmacen");
				}
				%>
		 </tbody>
</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
				<%=fb.hidden("punto",punto).replaceAll(" id=\"punto\"","")%>
				<%=fb.hidden("consigna",consigna).replaceAll(" id=\"consigna\"","")%>
				<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
				<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
				<%=fb.hidden("cantidad",cantidad).replaceAll(" id=\"cantidad\"","")%>
				<%=fb.hidden("articulo",articulo).replaceAll(" id=\"articulo\"","")%>
				<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
		<%=fb.hidden("costoCero",""+costoCero)%>
<%=fb.hidden("codRef",codRef)%>
<%=fb.hidden("implantable",implantable)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
			<%=fb.hidden("punto",punto).replaceAll(" id=\"punto\"","")%>
			<%=fb.hidden("consigna",consigna).replaceAll(" id=\"consigna\"","")%>
			<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
			<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
			<%=fb.hidden("cantidad",cantidad).replaceAll(" id=\"cantidad\"","")%>
			<%=fb.hidden("articulo",articulo).replaceAll(" id=\"articulo\"","")%>
			<%=fb.hidden("descripcion",descripcion).replaceAll(" id=\"descripcion\"","")%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
			<%=fb.hidden("costoCero",""+costoCero)%>
<%=fb.hidden("codRef",codRef)%>
<%=fb.hidden("implantable",implantable)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
