
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>  
<%@ page import="issi.inventory.Ajuste"%>
<%@ page import="issi.inventory.AjusteDetails"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="AjuDet" scope="session" class="issi.inventory.Ajuste" />
<jsp:useBean id="ajuArt" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ajuArtKey" scope="session" class="java.util.Hashtable" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";


String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String codProveedor = request.getParameter("codProveedor");
String index = request.getParameter("index");
String refType = request.getParameter("refType");
if(codProveedor==null) codProveedor = "";
if(fp==null) fp = "";
if(fg==null) fg = "SOC";
if(index==null) index = "";
if(refType==null) refType = "";
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
  
  String noFactura = "", anio= "", num_documento = "";

	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and anio_recepcion = "+request.getParameter("anio");  
		anio = request.getParameter("anio");      
	}	
	 if (request.getParameter("num_documento") != null && !request.getParameter("num_documento").trim().equals(""))
	{
		appendFilter += " and numero_documento = "+request.getParameter("num_documento");    
        num_documento = request.getParameter("num_documento");    
	}	
	if (request.getParameter("numero_factura") != null && !request.getParameter("numero_factura").trim().equals(""))
	{
		appendFilter += " and numero_factura like '"+request.getParameter("numero_factura")+"%'";    
	     noFactura  = request.getParameter("numero_factura");
	}
	
	sql = "select rm.anio_recepcion, rm.numero_documento, rm.numero_factura, rm.codigo_almacen, p.nombre_proveedor, a.descripcion nombre_almacen from tbl_inv_recepcion_material rm, tbl_com_proveedor p, tbl_inv_almacen a where rm.compania = "+ session.getAttribute("_companyId") +" and rm.cod_proveedor = p.cod_provedor and rm.cod_proveedor = "+ codProveedor +" and rm.estado = 'R' and rm.ref_cheque is null and (rm.monto_pagado is null /*or rm.monto_pagado = 0*/) and rm.numero_factura  <> 'NOTA_ENTREGA' and rm.compania = a.compania and rm.codigo_almacen = a.codigo_almacen "+appendFilter+" order by rm.numero_factura asc, rm.numero_documento, rm.anio_recepcion";
	if(fp!=null && fp.equals("ajuste") && fg !=null && fg.equals("ND")){
		sql = "select rm.anio_recepcion, rm.numero_documento, rm.numero_factura, rm.codigo_almacen, p.nombre_proveedor, a.descripcion nombre_almacen from tbl_inv_recepcion_material rm, tbl_com_proveedor p, tbl_inv_almacen a where rm.compania = "+ session.getAttribute("_companyId") +" and rm.cod_proveedor = p.cod_provedor and rm.cod_proveedor = "+ codProveedor +" and rm.compania = a.compania and rm.codigo_almacen = a.codigo_almacen "+appendFilter+" order by rm.numero_factura asc, rm.numero_documento, rm.anio_recepcion";
	} else if(fp!=null && fp.equals("orden_pago")){
		sql = "select rm.anio_recepcion, rm.numero_documento, rm.numero_factura, rm.codigo_almacen, p.nombre_proveedor, a.descripcion nombre_almacen, rm.monto_total, to_char(rm.fecha_documento, 'dd/mm/yyyy') || ' FACTURA ' || rm.numero_factura desc_factura from tbl_inv_recepcion_material rm, tbl_com_proveedor p, tbl_inv_almacen a where rm.compania = "+ session.getAttribute("_companyId") +" and rm.cod_proveedor = p.cod_provedor and rm.cod_proveedor = "+ codProveedor +" and rm.compania = a.compania and rm.codigo_almacen = a.codigo_almacen "+appendFilter+" order by rm.numero_factura asc, rm.numero_documento, rm.anio_recepcion";
	} 
		if(fp!=null && fp.equals("ajuste") && fg !=null && fg.equals("CXP")){
		
		if(refType.trim().equals("G")){appendFilter +=" and rm.tipo_factura='S'";}else{appendFilter +=" and rm.tipo_factura='I'";}
		sql = "select rm.anio_recepcion, rm.numero_documento, rm.numero_factura, rm.codigo_almacen, p.nombre_proveedor, a.descripcion nombre_almacen, rm.monto_total monto from tbl_inv_recepcion_material rm, tbl_com_proveedor p, tbl_inv_almacen a where rm.compania = "+ session.getAttribute("_companyId") +" and rm.cod_proveedor = p.cod_provedor and rm.cod_proveedor = "+ codProveedor +" and rm.estado = 'R' and rm.ref_cheque is null and rm.numero_factura  <> 'NOTA_ENTREGA' and rm.compania = a.compania(+) and rm.codigo_almacen = a.codigo_almacen(+) "+appendFilter+" order by rm.numero_factura asc, rm.numero_documento, rm.anio_recepcion";
	}
	
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Inventario - '+document.title;

function setValues(i){
	var fg = document.detail.fg.value;
	var fp = document.detail.fp.value;

	if(fg=='CXP')
	{
	if(window.opener.document.form1.montoFact)window.opener.document.form1.montoFact.value = eval('document.detail.monto'+i).value;
	window.opener.document.form1.monto.value = eval('document.detail.monto'+i).value;
	window.opener.document.form1.numero_factura.value = eval('document.detail.numero_factura'+i).value;
		window.close();
	 } else {
	<%if(fp.equals("orden_pago")){%>
	window.opener.document.form1.num_factura<%=index%>.value = eval('document.detail.numero_factura'+i).value;
	window.opener.document.form1.anio_recepcion<%=index%>.value = eval('document.detail.anio_recepcion'+i).value;
	window.opener.document.form1.numero_documento<%=index%>.value = eval('document.detail.numero_documento'+i).value;
	window.opener.document.form1.monto_a_pagar<%=index%>.value = eval('document.detail.monto_total'+i).value;
	window.opener.document.form1.descripcion<%=index%>.value = eval('document.detail.desc_factura'+i).value;
	window.opener.verValues();
	window.close();
	<%} else {%>
	document.detail.anio_recepcion.value = eval('document.detail.anio_recepcion'+i).value;
	document.detail.numero_documento.value = eval('document.detail.numero_documento'+i).value;
	document.detail.numero_factura.value = eval('document.detail.numero_factura'+i).value;
	document.detail.codigo_almacen.value = eval('document.detail.codigo_almacen'+i).value;
	document.detail.nombre_almacen.value = eval('document.detail.nombre_almacen'+i).value;
	document.detail.submit();
    <%}%>
	
	}
	

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - SELECCION DE RECEPCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
        		<%=fb.hidden("index",index)%>
				<%=fb.hidden("refType",refType)%>
				<%=fb.hidden("codProveedor",codProveedor)%>
				<td width="25%">
					A&ntilde;o
					<%=fb.intBox("anio","",false,false,false,30)%>					
				</td>
				
				<td width="32%">
					No. Recepción
					<%=fb.textBox("num_documento","",false,false,false,30)%>					
				</td>
							
				<td width="34%">
					No. Factura
					<%=fb.textBox("numero_factura","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			   
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
        		<%=fb.hidden("index",index)%>
				<%=fb.hidden("codProveedor",codProveedor)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_documento",num_documento)%>
				<%=fb.hidden("numero_factura",noFactura)%>
				<%=fb.hidden("refType",refType)%>
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
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
        		<%=fb.hidden("index",index)%>
				<%=fb.hidden("codProveedor",codProveedor)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_documento",num_documento)%>
				<%=fb.hidden("numero_factura",noFactura)%>
				<%=fb.hidden("refType",refType)%>
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
		<tr class="TextHeader" align="center">
			<td width="5%">&nbsp;</td>
			<td width="10%">A&ntilde;o Recepci&oacute;n</td>
			<td width="10%">No. Recepci&oacute;n</td>
            <td width="40%">Proveedor</td>
			<td width="20%" align="right">No. Factura</td>
			<td width="15%" align="right">Monto</td>
		</tr>
<%
fb = new FormBean("detail","","post");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codProveedor",codProveedor)%>
				<%=fb.hidden("anio_recepcion","")%>
				<%=fb.hidden("numero_documento","")%>
				<%=fb.hidden("numero_factura","")%>
				<%=fb.hidden("codigo_almacen","")%>
				<%=fb.hidden("monto","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("anio_recepcion"+i,cdo.getColValue("anio_recepcion"))%>
		<%=fb.hidden("numero_documento"+i,cdo.getColValue("numero_documento"))%>
		<%=fb.hidden("numero_factura"+i,cdo.getColValue("numero_factura"))%>
		<%=fb.hidden("nombre_proveedor"+i,cdo.getColValue("nombre_proveedor"))%>
		<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
		<%=fb.hidden("nombre_almacen"+i,cdo.getColValue("nombre_almacen"))%>
		<%=fb.hidden("monto"+i,CmnMgr.getFormattedDecimal(cdo.getColValue("monto")))%>

    <%if(fp.equals("orden_pago")){%>
		<%=fb.hidden("monto_total"+i,cdo.getColValue("monto_total"))%>
		<%=fb.hidden("desc_factura"+i,cdo.getColValue("desc_factura"))%>
    <%}%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setValues(<%=i%>)" style="cursor:pointer">
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td><%=cdo.getColValue("anio_recepcion")%></td>
			<td><%=cdo.getColValue("numero_documento")%></td>
            <td><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="right"><%=cdo.getColValue("numero_factura")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
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
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
        		<%=fb.hidden("index",index)%>
				<%=fb.hidden("codProveedor",codProveedor)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_documento",num_documento)%>
				<%=fb.hidden("numero_factura",noFactura)%>
				<%=fb.hidden("refType",refType)%>
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
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
        		<%=fb.hidden("index",index)%>
				<%=fb.hidden("codProveedor",codProveedor)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_documento",num_documento)%>
				<%=fb.hidden("numero_factura",noFactura)%>
				<%=fb.hidden("refType",refType)%>
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
else
{
	System.out.println("=====================POST=====================");
	
	AjuDet.setAnioDoc(request.getParameter("anio_recepcion"));
	AjuDet.setNumeroDoc(request.getParameter("numero_documento"));
	AjuDet.setNumFactura(request.getParameter("numero_factura"));
	AjuDet.setCodigoAlmacen(request.getParameter("codigo_almacen"));
	AjuDet.setDescAlmacen(request.getParameter("nombre_almacen"));
	
	AjuDet.getAjusteDetail().clear();
	ajuArt.clear();
	ajuArtKey.clear();
	sql = "select c.cod_familia codFamilia, c.cod_clase codClase, c.cod_articulo codArticulo, a.descripcion articulo, c.articulo_und CantUnidad, c.cantidad_facturada cantFact, c.cantidad cantRec, c.cantidad * c.articulo_und cantidadAjuste, c.precio, a.consignacion_sino consignacionSN, d.disponible cantidadDisponible from tbl_inv_articulo a, tbl_inv_recepcion_material b, tbl_inv_detalle_recepcion c, tbl_inv_inventario d where (c.compania = "+session.getAttribute("_companyId")+" and c.cod_familia = a.cod_flia and c.cod_clase = a.cod_clase and c.cod_articulo = a.cod_articulo and c.compania = a.compania and c.compania = d.compania and c.cod_familia = d.art_familia and c.cod_clase = d.art_clase and c.cod_articulo = d.cod_articulo and b.codigo_almacen = d.codigo_almacen and (c.compania = b.compania and  c.numero_documento = b.numero_documento and  c.anio_recepcion = b.anio_recepcion) and (b.cod_proveedor = "+request.getParameter("codProveedor")+") and (c.anio_recepcion = "+request.getParameter("anio_recepcion")+") and (c.numero_documento = "+request.getParameter("numero_documento")+"))";
	
	System.out.println("recepcionItems:\n"+sql);
	
	AjuDet.setAjusteDetail(sbb.getBeanList(ConMgr.getConnection(), sql, AjusteDetails.class));
	String key = "";;	
	int keySize = AjuDet.getAjusteDetail().size();
	for(int i=0;i<keySize;i++){
		AjusteDetails det = (AjusteDetails) AjuDet.getAjusteDetail().get(i);
		if (i < 10) key = "00"+i;
		else if (i < 100) key = "0"+i;
		else key = ""+i;
		try {
			ajuArt.put(key, det);
			ajuArtKey.put(det.getCodFamilia()+"-"+det.getCodClase()+"-"+det.getCodArticulo(), key);
			System.out.println("addget item "+key);
		}	catch (Exception e)	{
			System.out.println("Unable to addget item "+key);
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	//var nom_proveedor = eval('document.detail.nombre_proveedor'+i).value;
	//var cod_almacacen = eval('document.detail.codigo_almacen'+i).value;
	var fp = '<%=request.getParameter("fp")%>';
	var fg = '<%=request.getParameter("fg")%>';
	if(fp=='ajuste'){
		if(fg=='ED' || fg=='ND'){
			window.opener.document.form1.anio_doc.value = <%=request.getParameter("anio_recepcion")%>;
			window.opener.document.form1.numero_doc.value = <%=request.getParameter("numero_documento")%>;
			window.opener.document.form1.num_factura.value = '<%=request.getParameter("numero_factura")%>';
			//window.opener.document.form1.nombre_proveedor.value = nom_proveedor;
			window.opener.document.form1.codigoAlmacen.value = <%=request.getParameter("codigo_almacen")%>;
			window.opener.document.form1.nombreAlmacen.value = '<%=request.getParameter("nombre_almacen")%>';
		}
	}
	window.opener.itemFrame.document.location = '../inventario/reg_ajuste_item.jsp?change=1';
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
