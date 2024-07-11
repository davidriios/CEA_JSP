<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OCDet" scope="session" class="issi.compras.OrdenCompra" />
<jsp:useBean id="ocArt" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ocArtKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
String appendFilter1 = "";
String appendFilter2 = "";


String mode = request.getParameter("mode");
String id = request.getParameter("id");
int anio = 2010;//Integer.parseInt(request.getParameter("anio"));
int prevAnio = anio -1;
String fp = request.getParameter("fp");
String filterProveedor = request.getParameter("filterProveedor");
String art_familia = "";
String art_clase = "";
String cod_articulo = "";
String descripcion = "";
String almacen = "";
String proveedor = "";
String proveedor_desc = "";
if(request.getParameter("art_familia")!=null) art_familia = request.getParameter("art_familia");
if(request.getParameter("art_clase")!=null) art_clase = request.getParameter("art_clase");
if(request.getParameter("cod_articulo")!=null) cod_articulo = request.getParameter("cod_articulo");
if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
if(request.getParameter("almacen")!=null) almacen = request.getParameter("almacen");
if(request.getParameter("proveedor")!=null) proveedor = request.getParameter("proveedor");
if(request.getParameter("proveedor_desc")!=null) proveedor_desc = request.getParameter("proveedor_desc");

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

	if (!art_familia.trim().equals("")) appendFilter += " and i.art_familia = "+art_familia;
	if (!art_clase.trim().equals("")) appendFilter += " and i.art_clase = "+art_clase;
	if (!cod_articulo.trim().equals("")) appendFilter += " and i.cod_articulo = "+cod_articulo;
	if (!descripcion.trim().equals("")) appendFilter += " and a.descripcion like '%"+descripcion.toUpperCase()+"%'";
	if (!almacen.trim().equals("")) appendFilter += " and i.codigo_almacen = "+almacen;
	if (!proveedor.trim().equals("")) appendFilter += " and ap.cod_provedor = "+proveedor;
	
	if(request.getParameter("almacen")!=null){
	sql = "select all 'CS' art_origen, to_char(r.requi_anio) requi_anio, to_char(r.requi_numero) requi_numero,a.cod_flia,a.cod_clase, a.cod_subclase,a.cod_articulo, a.descripcion articulo, a.cod_medida, dr.cantidad cantidad, a.itbm, dr.precio_cotizado, dr.especificacion, nvl(getCantArtTramite(r.compania, r.codigo_almacen, a.cod_articulo), 0) cant_tramite, p.nombre_proveedor, i.disponible cantidad_disponible, al.descripcion almacen_desc from tbl_inv_detalle_req dr, tbl_inv_arti_prov ap, tbl_inv_articulo a, tbl_inv_requisicion r, tbl_com_proveedor p, tbl_inv_inventario i, tbl_inv_almacen al where r.activa = 'S' AND r.estado_requi = 'A' and dr.compania = ap.compania and dr.cod_articulo = ap.cod_articulo and ap.compania = a.compania and ap.cod_articulo = a.cod_articulo and ap.cod_articulo = a.cod_articulo and r.compania = "+session.getAttribute("_companyId")+" AND dr.compania = r.compania AND dr.requi_numero = r.requi_numero AND dr.requi_anio = r.requi_anio AND estado_renglon  = 'P'" + appendFilter+" and ap.cod_provedor = p.cod_provedor and ap.tipo_proveedor = 1 and not exists (select 1 from tbl_com_comp_formales z where r.requi_anio = z.requi_anio and r.requi_numero = z.requi_numero) and dr.compania = i.compania and dr.cod_articulo = i.cod_articulo and i.compania = al.compania and i.codigo_almacen = al.codigo_almacen union all select 'PR' art_origen, '' requi_anio, '' requi_numero, a.cod_flia, a.cod_clase, a.cod_subclase, i.cod_articulo, a.descripcion, a.cod_medida, 0 cantidad, a.itbm, 0.precio_cotizado, ' ' especificacion, nvl(getCantArtTramite(i.compania, i.codigo_almacen, i.cod_articulo), 0) cant_tramite, p.nombre_proveedor, i.disponible cantidad_disponible, al.descripcion almacen_desc from tbl_inv_inventario i, tbl_inv_articulo a,tbl_inv_arti_prov ap, tbl_com_proveedor p, tbl_inv_almacen al where i.compania = "+session.getAttribute("_companyId")+" and i.cod_articulo = a.cod_articulo and (ap.compania = a.compania and ap.cod_articulo = a.cod_articulo) and i.disponible  < i.pto_reorden  "+appendFilter+" and ap.cod_provedor = p.cod_provedor and ap.tipo_proveedor = 1 and i.compania = "+session.getAttribute("_companyId")+" and i.compania = al.compania and i.codigo_almacen = al.codigo_almacen";

	al = SQLMgr.getDataList("select * from (select rownum as rn, tmp.* from ("+sql+") tmp where rownum <= "+nextVal+") where rn >= "+previousVal); 
	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sql+")");
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
document.title = 'Inventario - '+document.title;
</script>
<script language="javascript">
function verValue(i){
}

function chkQty(){
	var x = 0;
	if(x==0) return true;
	else return false;
}

function confirma(obj){
	obj.checked = confirm('Confirma que desea hacer una orden de compra de este articulo a pesar de que ya está en trámite en otra orden de compra?');
}

function chkRequisicion(j){
}

function buscaProv(){
	abrir_ventana2('../compras/sel_proveedor.jsp?fp=sol_punto_reorden');
}

function clearText(){
	document.search01.proveedor.value = '';
	document.search01.proveedor_desc.value = '';
}

function print(){
	abrir_ventana("../inventario/print_art_sol_compra_punto_orden.jsp?art_familia=<%=art_familia%>&art_clase=<%=art_clase%>&cod_articulo=<%=cod_articulo%>&descripcion=<%=descripcion.toUpperCase()%>&almacen=<%=almacen%>&proveedor=<%=proveedor%>&proveedor_desc=<%=proveedor_desc%>");
}
</script>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;<a href="javascript:print()">[ Imprimir ]</a></td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
				<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
			<tr class="TextFilter">
				<td>
        	Almac&eacute;n:
          <%=fb.select(ConMgr.getConnection(),"SELECT codigo_almacen, codigo_almacen ||'-'||descripcion descripcion FROM TBL_INV_ALMACEN a WHERE compania = "+session.getAttribute("_companyId") +" ORDER BY descripcion","almacen",almacen,false,false,0,"text10",null,"","","T")%> 
          Proveedor:
					<%=fb.intBox("proveedor",proveedor,false,false,true,5,null,null,"onDblClick=\"javacript:clearText();\"")%> 
          <%=fb.textBox("proveedor_desc",proveedor_desc,false,false,true,40,null,null,"onDblClick=\"javacript:clearText();\"")%> 
          <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaProv()\"")%> 
				</td>
			</tr>
			<tr class="TextFilter">
				<td>
					Familia
					<%=fb.intBox("art_familia",art_familia,false,false,false,5,10,"Text10","","")%>
          &nbsp;
					Clase
					<%=fb.intBox("art_clase",art_clase,false,false,false,5,10,"Text10","","")%>
          &nbsp;
					Art&iacute;culo
					<%=fb.intBox("cod_articulo",cod_articulo,false,false,false,10,10,"Text10","","")%>
          &nbsp;
					Descripci&oacute;n
					<%=fb.textBox("descripcion",descripcion,false,false,false,25,100,"Text10","","")%>
					<%=fb.submit("go","Ir")%>
				</td>
			</tr>
				<%=fb.formEnd()%>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("proveedor_desc",proveedor_desc)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("proveedor_desc",proveedor_desc)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<%
//onSubmit=\"javascript:return (chkQty())\"
fb = new FormBean("articles","","post","");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
	<td align="left" class="TableLeftBorder TextInfo">* Art&iacute;culos se encuentran en otra requisicion aprobada y sin entregar!</td>
	<td align="right" class="TableRightBorder">&nbsp;</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader">
      	<td width="5%" align="center" rowspan="2">Sol. Anio</td>
      	<td width="5%" align="center" rowspan="2">Sol. No</td>
				<td width="20%" align="center" colspan="3">C&oacute;digo</td>
				<td width="28%" align="center" rowspan="2">Descripci&oacute;n</td>
				<td width="12%" align="center" rowspan="2">Proveedor</td>
				<td width="3%" align="center" rowspan="2">Und.</td>
				<td width="15%" align="center" rowspan="2">Almac&eacute;n</td>
				<td width="6%" align="center" rowspan="2">Cant. Disponible</td>
				<td width="6%" align="center" rowspan="2">Cant. Tramite</td>
			</tr>
			<tr class="TextHeader">
				<td width="6%" align="center">Familia</td>
				<td width="6%" align="center">Clase</td>
				<td width="8%" align="center">Art&iacute;culo</td>
			</tr>
<%
String flg = "S";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(cdo.getColValue("art_origen")!=null && cdo.getColValue("art_origen").equals("PR")){
		color = "TextRow10";
		if (i % 2 == 0) color = "TextRow09";
		if(flg.equals("S")){
		%>
		<tr class="TextHeader">
        <td align="left" colspan="11">Art&iacute;culos bajo Punto de Reorden</td>
		</tr>
    <%
			flg = "N";
		}	
	}
	
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("requi_anio")%></td>
			<td align="center"><%=cdo.getColValue("requi_numero")%></td>
			<td align="center"><%=cdo.getColValue("cod_flia")%></td>
			<td align="center"><%=cdo.getColValue("cod_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("articulo")%></td>
			<td align="left"><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="center"><%=cdo.getColValue("cod_medida")%></td>
      <td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"><%=cdo.getColValue("cantidad_disponible")%></td>
			<td align="center"><%=cdo.getColValue("cant_tramite")%></td>
		</tr>
	<%
}
if(al.size()==0){
%>
		<tr><td align="center" colspan="11">No registros encontrados.</td></tr>
<%}%>		
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("proveedor_desc",proveedor_desc)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("proveedor_desc",proveedor_desc)%>
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
