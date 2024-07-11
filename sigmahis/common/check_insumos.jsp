<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleSolicitud"%>
<%@ page import="issi.expediente.SolicitudInsumos"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="insumos" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vInsumos" scope="session" class="java.util.Vector" />
<jsp:useBean id="sInsumo" scope="session" class="issi.expediente.SolicitudInsumos" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdoParam = new CommonDataObject();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String appendFilter = "", appendFilter1 = "";
String fp = request.getParameter("fp");
String change = request.getParameter("change");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = cDateTime.substring(6,10);
String cds = request.getParameter("cds");
String cda = request.getParameter("cda");
String desc = request.getParameter("desc");
String fechaCita = request.getParameter("fechaCita");
String codCita = request.getParameter("codCita");
String secuenciaCorte = request.getParameter("secuenciaCorte");
String barcode = request.getParameter("barcode");
String bar__code		= request.getParameter("bar__code")==null?"":request.getParameter("bar__code");
String byBarcode = "";

StringBuffer sbSql = new StringBuffer();

if (desc == null ) desc = "";
if (barcode == null) barcode = "";

int insumoLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("insumoLastLineNo") != null) insumoLastLineNo = Integer.parseInt(request.getParameter("insumoLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{  appendFilter = ""; appendFilter1 = "";

	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'CHECK_DISP'),'S') as valida_dsp, nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'EXP_SALES_SUPPLIES_FILTER_ENABLED'),'N') as saleItemFilter from dual");
	cdoParam = SQLMgr.getData(sbSql.toString());
	if(cdoParam ==null){cdoParam = new CommonDataObject(); cdoParam.addColValue("valida_dsp","S");}

	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

	if (request.getParameter("searchQuery")!= null)
	{  appendFilter = "";  appendFilter1 = "";
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		System.out.println("nextval...ahora con N..."+nextVal);
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
	if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
	if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}
	String codigo ="",descripcion ="",tipo="";
	String saleItem = request.getParameter("saleItem");
	if (saleItem == null) saleItem = "";
	if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
	{
			appendFilter  += " and upper(I.COD_ARTICULO) like '%"+request.getParameter("code").toUpperCase()+"%' ";
		appendFilter1 += " and upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%' ";
				codigo = request.getParameter("code");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{     appendFilter  += " and upper(A.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		appendFilter1 += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
			descripcion = request.getParameter("descripcion") ;

	}
	if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals(""))tipo = request.getParameter("tipo");
	if (!fp.equalsIgnoreCase("usosSop") && !saleItem.trim().equals("")) { appendFilter += " and nvl(a.venta_sino,'N') = '"+saleItem+"'"; }

	if (!barcode.trim().equals("")) {
			appendFilter += " and upper(trim(a.cod_barra)) = '"+barcode.toUpperCase()+"'";
			appendFilter1 += " and codigo_barra = '"+request.getParameter("barcode")+"'";

			barcode = "";
			byBarcode = "Y";
	}

	if ((fp.equalsIgnoreCase("listInsumo")||fp.equalsIgnoreCase("usosSop"))&&request.getParameter("tipo") != null)
	{
	if (request.getParameter("tipo") != null)
	{

	if (request.getParameter("tipo").trim().equals("T")) {
		sql="SELECT 'I' TIPO,i.cod_articulo as codigo,A.DESCRIPCION, nvl(I.DISPONIBLE,0)cantidad,  a.cod_flia as ART_FAMILIA, a.cod_clase as ART_CLASE, nvl(A.PRECIO_VENTA,0) as precio_venta, I.PRECIO COSTO, I.CODIGO_ALMACEN as CODIGO_ALMACEN,nvl(a.other3,'Y')afecta_inv, a.cod_barra FROM TBL_INV_INVENTARIO I, TBL_INV_ARTICULO A ,tbl_inv_familia_articulo fa WHERE  I.COMPANIA = "+(String) session.getAttribute("_companyId")+appendFilter +" AND I.CODIGO_ALMACEN = "+cda+" AND I.COMPANIA = A.COMPANIA AND I.COD_ARTICULO = A.COD_ARTICULO and fa.compania = a.compania and fa.cod_flia = a.cod_flia and fa.tipo_servicio is not null and a.estado = 'A' ";

		sql += " UNION ALL ";

		sql += " SELECT 'U' TIPO,CODIGO as CODIGO,DESCRIPCION, 0 cantidad,  0 ART_FAMILIA, 0 ART_CLASE, PRECIO_VENTA, 0 COSTO,0 CODIGO_ALMACEN,'N' afecta_inv, codigo_barra cod_barra FROM TBL_SAL_USO WHERE  COMPANIA = "+(String) session.getAttribute("_companyId")+ appendFilter1 +" and TIPO_SERVICIO IN ('02','03','04','05','14')  and estatus = 'A' ";
	} else {
		if(request.getParameter("tipo").trim().equals("I"))
		sql="SELECT 'I' TIPO,i.cod_articulo as codigo,A.DESCRIPCION, nvl(I.DISPONIBLE,0)cantidad,  a.cod_flia as ART_FAMILIA, a.cod_clase as ART_CLASE, nvl(A.PRECIO_VENTA,0) as precio_venta, I.PRECIO COSTO, I.CODIGO_ALMACEN as CODIGO_ALMACEN,nvl(a.other3,'Y')afecta_inv, a.cod_barra FROM TBL_INV_INVENTARIO I, TBL_INV_ARTICULO A ,tbl_inv_familia_articulo fa WHERE  I.COMPANIA = "+(String) session.getAttribute("_companyId")+appendFilter +" AND I.CODIGO_ALMACEN = "+cda+" AND I.COMPANIA = A.COMPANIA AND I.COD_ARTICULO = A.COD_ARTICULO and fa.compania = a.compania and fa.cod_flia = a.cod_flia and fa.tipo_servicio is not null and a.estado = 'A'";
		else if(request.getParameter("tipo").trim().equals("U"))
			sql=" SELECT 'U' TIPO,CODIGO as CODIGO,DESCRIPCION, 0 cantidad,  0 ART_FAMILIA, 0 ART_CLASE, PRECIO_VENTA, 0 COSTO,0 CODIGO_ALMACEN,'N' afecta_inv, codigo_barra cod_barra FROM TBL_SAL_USO WHERE  COMPANIA = "+(String) session.getAttribute("_companyId")+ appendFilter1 +" and TIPO_SERVICIO IN ('02','03','04','05','14')  and estatus = 'A' ";
		else sql="SELECT 'I' TIPO,i.cod_articulo as codigo,A.DESCRIPCION, nvl(I.DISPONIBLE,0)cantidad,  a.cod_flia as ART_FAMILIA, a.cod_clase as ART_CLASE, nvl(A.PRECIO_VENTA,0) as precio_venta, I.PRECIO COSTO, I.CODIGO_ALMACEN as CODIGO_ALMACEN,nvl(a.other3,'Y')afecta_inv, a.cod_barra FROM TBL_INV_INVENTARIO I, TBL_INV_ARTICULO A,tbl_inv_familia_articulo fa WHERE  I.COMPANIA = "+(String) session.getAttribute("_companyId")+appendFilter +" AND I.CODIGO_ALMACEN = "+cda+" AND I.COMPANIA = A.COMPANIA AND I.COD_ARTICULO = A.COD_ARTICULO and fa.compania = a.compania and fa.cod_flia = a.cod_flia and fa.tipo_servicio is not null and a.estado = 'A' union all SELECT 'U' TIPO,CODIGO as CODIGO,DESCRIPCION, 0 cantidad,  0 ART_FAMILIA, 0 ART_CLASE, PRECIO_VENTA, 0 COSTO,0 CODIGO_ALMACEN,'N' FROM TBL_SAL_USO WHERE  COMPANIA = "+(String) session.getAttribute("_companyId")+ appendFilter1 +" and TIPO_SERVICIO IN ('02','03','04','05','14')  and estatus = 'A' ";
	}

	sql +="  ORDER BY  1,2,5, 6 asc ";
al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

	}
	}


if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount)
	{ nVal=nxtVal;
	}
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;

//--------------------------------------------------

%>
<html>
<head>
<%@ include file="nocache.jsp"%>
<%@ include file="header_param.jsp"%>
<script>
document.title = 'INSUMOS  - '+document.title;
function validar(obj,k){
var cant = parseInt(eval('document.insumo.cant_uso'+k).value,10);
var disponible = parseFloat(eval('document.insumo.cantidad'+k).value);
var tipoart = eval('document.insumo.tipo'+k).value;
var afecta_inv = eval('document.insumo.afecta_inv'+k).value;
var precio_venta = parseFloat(eval('document.insumo.precio_venta'+k).value);
var chkObj = eval('document.insumo.check'+k);
var check=false;
if(precio_venta<=0){
	alert('Precio Venta ('+precio_venta+') inválido! Por favor seleccione Items con Precio de Venta mayor que cero.');
	document.getElementById("cant_uso"+k).value="0";
	obj.focus();
}else{
	if(!isNaN(cant)){
		if(cant > 0 ){
			check=true;
	<%if(cdoParam.getColValue("valida_dsp").trim().equals("S")){%>
			if(afecta_inv=='Y'){
				if(disponible < cant && tipoart=="I" ){
					check=false;
					alert('No hay cantidad disponible!');
					document.getElementById("cant_uso"+k).value="0";
					obj.focus();
				}
			}
	<%}%>
		} else if(cant <= 0 ){
			alert('Cantidad debe ser Mayor a Cero');
		}
	}else alert('Cantidad inválida');
}
if(chkObj)chkObj.checked=check;
}
function checkQty(k){
	var cant = parseInt(eval('document.insumo.cant_uso'+k).value,10);
	if(cant<=0){
		//alert('Cantidad Inválida!');
		if(eval('document.insumo.check'+k))eval('document.insumo.check'+k).checked=false;
	}else if(eval('document.insumo.check'+k)&&eval('document.insumo.check'+k).checked) validar(eval('document.insumo.cant_uso'+k),k);
}

function doAction() {
	document.search01.barcode.focus();

	<%if(byBarcode.trim().equals("Y") && al.size() == 1){%>
	 $("#cant_uso0").val(1);
	<%}%>
}

function barcodeSearch(e) {
	if(e.keyCode == 13) {
		var lastBarcode = $("#last_barcode").val();
		var currentBarcode = e.target.value;

		if (currentBarcode) {
			if (lastBarcode && lastBarcode == currentBarcode) {
				 var oldVal = $(".cant_uso"+currentBarcode).val() || 0;
				 oldVal++;
					$(".cant_uso"+currentBarcode).val(oldVal).change();
			} else $("#search01").submit();
		}

	} // enter
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<jsp:include page="title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION - INSUMOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="1">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("mode",""+mode)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("insumoLastLineNo",""+insumoLastLineNo)%>
			<%=fb.hidden("cds",""+cds)%>
			<%=fb.hidden("cda",""+cda)%>
						<%=fb.hidden("desc",desc)%>
			<%=fb.hidden("fechaCita",fechaCita)%>
			<%=fb.hidden("codCita",codCita)%>
			<%=fb.hidden("secuenciaCorte",secuenciaCorte)%>

		<td width="100%">
			<cellbytelabel>Tipo</cellbytelabel>:<%if(fp.trim().equals("usosSop")){%><%=fb.select("tipo","U=USOS",tipo,false,false,0,"T")%><%}else{%>
			<%=fb.select("tipo","T=- TODOS -,I=INVENTARIO,U=USOS",tipo,false,false,0,"")%><%}%>
			<cellbytelabel>C&oacute;digo</cellbytelabel>
			<%=fb.textBox("code","",false,false,false,30,null,null,null)%>
			<cellbytelabel>Descripci&oacute;n</cellbytelabel>
			<%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
			<% if (!fp.equalsIgnoreCase("usosSop") && "SY".contains(cdoParam.getColValue("saleItemFilter"))) { %>
			<cellbytelabel>Art&iacute;culo Venta</cellbytelabel>
			<%=fb.select("saleItem","S=SI,N=NO",saleItem,false,false,0,"T")%>
			<% } else { %>
			<%=fb.hidden("saleItem",saleItem)%>
			<% } %>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<cellbytelabel>Barcode</cellbytelabel>
				<%=fb.textBox("barcode","",false,false,false,10,0,"ignore",null,"onkeypress=\"barcodeSearch(event);\", onFocus=\"this.select()\"",null,false,"placeholder='Código Barra'")%>
			<%=fb.submit("go","Ir")%>
		</td>

		<%=fb.hidden("bar__code",bar__code)%>
		<%=fb.hidden("last_barcode", request.getParameter("barcode")!=null && !request.getParameter("barcode").equals("") ? request.getParameter("barcode") : "")%>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>
<!--------------------------------------------------------  --->
<table align="center" width="99%" cellpadding="1" cellspacing="0">
		<tr>
					<td align="right">&nbsp;</td>
	 </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("insumo",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("mode",""+mode)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("insumoLastLineNo",""+insumoLastLineNo)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("cda",""+cda)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("secuenciaCorte",secuenciaCorte)%>
<%=fb.hidden("saleItem",saleItem)%>
<%=fb.hidden("barcode",barcode)%>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save1","Agregar",true,false)%>&nbsp;&nbsp;<%=fb.submit("addCont1","Agregar y Continuar")%>
						<%=fb.button("cancel1","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">



	<tr class="TextHeader" align="center">
		<td width="8%"><cellbytelabel>Codigo Uso</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Tipo</cellbytelabel></td>
		<td width="33%"><cellbytelabel>Descripcion</cellbytelabel></td>
		<%if(!fp.trim().equals("usosSop")){%>
		<td width="15%"><cellbytelabel>C&oacute;digo Art&iacute;culo</cellbytelabel></td>
		<td width="16%"><cellbytelabel>Familia</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Clase</cellbytelabel></td>
		<td width="5%"><cellbytelabel>Disponible</cellbytelabel></td>
		<%}else{%><td width="5%" colspan="4">&nbsp;</td> <%}%>
		<td width="5%"><cellbytelabel>Cantidad</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>

<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "",key2="";

	if(cdo.getColValue("tipo") != null && cdo.getColValue("tipo").trim().equals("U"))
	key = (String) cdo.getColValue("codigo")+cdo.getColValue("tipo");
	else key = (String) cdo.getColValue("codigo")+cdo.getColValue("art_clase")+cdo.getColValue("art_familia");
	%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("familia"+i,cdo.getColValue("ART_FAMILIA"))%>
		<%=fb.hidden("clase"+i,cdo.getColValue("ART_CLASE"))%>
		<%=fb.hidden("articulo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("DESCRIPCION"))%>
		<%=fb.hidden("cantidad"+i,cdo.getColValue("cantidad"))%>
		<%=fb.hidden("precio_venta"+i,cdo.getColValue("PRECIO_VENTA"))%>
		<%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<%=fb.hidden("almacen"+i,cdo.getColValue("CODIGO_ALMACEN"))%>
		<%=fb.hidden("renglon"+i,"0")%>
		<%=fb.hidden("afecta_inv"+i,cdo.getColValue("afecta_inv"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<%if(cdo.getColValue("tipo").equals("U")){%>
				<td><%=cdo.getColValue("codigo")%></td>
				<%} else{%><td>0</td><%}%>
				<td align="center">
					<%if(cdo.getColValue("tipo", " ").equalsIgnoreCase("I")){%>
					INVENTARIO
					<%} else if(cdo.getColValue("tipo", " ").equalsIgnoreCase("U")){%>
					USOS
					<%}%>
				</td>
				<td><%=cdo.getColValue("DESCRIPCION")%></td>
				<%if(!fp.trim().equals("usosSop")){%>
				<%if(cdo.getColValue("tipo").equals("I")){%>
				<td><%=cdo.getColValue("codigo")%></td>
				<%} else{%><td>0</td><%}%>
				<td><%=cdo.getColValue("ART_FAMILIA")%></td>
				<td><%=cdo.getColValue("ART_CLASE")%></td>
				<td><%=cdo.getColValue("cantidad")%></td>
				<%}else{%><td colspan="4">&nbsp;</td> <%}%>


				<%if(vInsumos.contains(key)){%>
				<td><%=fb.intBox("cant_uso"+i,((DetalleSolicitud) insumos.get(key)).getCantidadUso(),true,false,false,3,null,null,"onBlur=\"javascript:validar(this,'"+i+"')\"")%></td>
				<%}else{%>
				<td><%=fb.intBox("cant_uso"+i,"0",true,((cdo.getColValue("cantidad").equals("0") &&cdo.getColValue("afecta_inv").equals("Y"))&&cdoParam.getColValue("valida_dsp").trim().equals("S")&& cdo.getColValue("tipo").equals("I")),false,3,"cant_uso"+cdo.getColValue("cod_barra"),null,"onBlur=\"javascript:validar(this,'"+i+"');\" onFocus=\"this.select();\"")%></td>
				<%}%>
				<td align="center"><%=(vInsumos.contains(cdo.getColValue("codigo")+cdo.getColValue("art_clase")+cdo.getColValue("art_familia")) || vInsumos.contains(cdo.getColValue("codigo")+cdo.getColValue("tipo")))?"Elegido":(((cdo.getColValue("cantidad").equals("0")&&cdo.getColValue("afecta_inv").equals("Y"))&&cdoParam.getColValue("valida_dsp").trim().equals("S")&& cdo.getColValue("tipo").equals("I"))?"":fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:checkQty("+i+");\""))%></td>
		</tr>
<%
}
%>
</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1 )?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount<=nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Agregar",true,false)%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
</body>
</html>
<%
}//get
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	//String cda = "";
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
					DetalleSolicitud detal = new DetalleSolicitud();

					detal.setRenglon(request.getParameter("renglon"+i));
					detal.setArtFamilia(request.getParameter("familia"+i));
					detal.setArtClase(request.getParameter("clase"+i));
					detal.setCodArticulo(request.getParameter("codigo"+i));
					if(request.getParameter("tipo"+i).equals("U"))
					detal.setCodUso(request.getParameter("codigo"+i));
					else
					detal.setCodUso("0");
					detal.setTipo(request.getParameter("tipo"+i));
					detal.setCantidad(request.getParameter("cantidad"+i));
					detal.setCantidadUso(request.getParameter("cant_uso"+i));
					detal.setPrecio(request.getParameter("precio_venta"+i));
					detal.setCosto(request.getParameter("costo"+i));
					detal.setAfectaInv(request.getParameter("afecta_inv"+i));

					//detal.setEstado("P");
					detal.setAnio(request.getParameter("anio"));
					detal.setDescripcion(request.getParameter("descripcion"+i));
					//cda = request.getParameter("almacen"+i);
			insumoLastLineNo=insumos.size()+1;
			String key = "";
			if (insumoLastLineNo < 10) key = "00"+insumoLastLineNo;
			else if (insumoLastLineNo < 100) key = "0"+insumoLastLineNo;
			else key = ""+insumoLastLineNo;
			//cdo.addColValue("key",key);

			try
			{
				//if(!((DetalleSolicitud) insumos.get(key)).getTipo().equals("U"))
				if(detal.getTipo().equals("U")){
					key = detal.getCodArticulo()+detal.getTipo();
					insumos.put(key,detal);
					vInsumos.addElement(detal.getCodArticulo()+detal.getTipo());
					}
				else
				{
					key = detal.getCodArticulo()+detal.getArtClase()+detal.getArtFamilia();
					insumos.put(key,detal);
					vInsumos.addElement(detal.getCodArticulo()+detal.getArtClase()+detal.getArtFamilia());
					System.out.println("tipo I");
				}
				//vInsumos.addElement(((DetalleSolicitud) insumos.get(key)).getCodUso());

						//vInsumos.add(((DetalleSolicitud) insumos.get(key)).getCodUso(),((DetalleSolicitud) insumos.get(key)).getArtClase(),((DetalleSolicitud)insumos.get(key)).getArtFamilia());

						//vInsumos.addElement(((DetalleSolicitud) insumos.get(key)).getCodArticulo(),insumos.get(key)).getCodClase(),insumos.get(key)).getArtFamilia());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// if checked
	}//for
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cds="+request.getParameter("cds")+"&cda="+request.getParameter("cda")+"&desc="+desc+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&tipo="+request.getParameter("tipo")+"&fechaCita="+request.getParameter("fechaCita")+"&codCita="+request.getParameter("codCita")+"&secuenciaCorte="+request.getParameter("secuenciaCorte")+"&saleItem="+request.getParameter("saleItem")+"&barcode="+request.getParameter("barcode")+"&bar__code="+bar__code);
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cds="+request.getParameter("cds")+"&cda="+request.getParameter("cda")+"&desc="+desc+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&tipo="+request.getParameter("tipo")+"&fechaCita="+request.getParameter("fechaCita")+"&codCita="+request.getParameter("codCita")+"&secuenciaCorte="+request.getParameter("secuenciaCorte")+"&saleItem="+request.getParameter("saleItem")+"&barcode="+request.getParameter("barcode")+"&bar__code="+bar__code);

		return;
	}
	if(request.getParameter("addCont")!=null||request.getParameter("addCont1")!=null){
		response.sendRedirect("../common/check_insumos.jsp?fp="+fp+"&noAdmision="+noAdmision+"&seccion="+seccion+"&pacId="+pacId+"&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&cds="+cds+"&cda="+cda+"&desc="+desc+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&tipo="+request.getParameter("tipo")+"&fechaCita="+fechaCita+"&codCita="+codCita+"&secuenciaCorte="+request.getParameter("secuenciaCorte")+"&saleItem="+request.getParameter("saleItem")+"&barcode="+request.getParameter("barcode")+"&bar__code="+bar__code);
		return;
		}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("listInsumo"))
	{

%>
	window.opener.location = '../expediente/exp_solicitar_insumos.jsp?seccion=<%=seccion%>&change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&insumoLastLineNo=<%=insumoLastLineNo%>&cds=<%=cds%>&cda=<%=cda%>&desc=<%=desc%>&secuenciaCorte=<%=secuenciaCorte%>&bar__code=<%=bar__code%>';
<%
	}else if (fp.equalsIgnoreCase("usosSop"))
	{

%>
	window.opener.location = '../facturacion/reg_cargo_dev_det_su.jsp?fp=<%=fp%>&change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&cda=<%=cda%>&desc=<%=desc%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&bar__code=<%=bar__code%>';
<%
	}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>