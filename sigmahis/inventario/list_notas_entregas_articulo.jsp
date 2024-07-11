<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
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
StringBuffer sbSql = new StringBuffer();


String mode = request.getParameter("mode");
String id = request.getParameter("id");
int anio = 2010;//Integer.parseInt(request.getParameter("anio"));
int prevAnio = anio -1;
String fp = request.getParameter("fp");
String filterProveedor = request.getParameter("filterProveedor");
String art_familia = "",codProv="",tipo="";
String art_clase = "";
String cod_articulo = "";
String descripcion = "";
String almacen = "";
String fDate = "";
String tDate = "";
if(request.getParameter("art_familia")!=null) art_familia = request.getParameter("art_familia");
if(request.getParameter("art_clase")!=null) art_clase = request.getParameter("art_clase");
if(request.getParameter("cod_articulo")!=null) cod_articulo = request.getParameter("cod_articulo");
if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
if(request.getParameter("almacen")!=null) almacen = request.getParameter("almacen");
if(request.getParameter("fDate")!=null) fDate = request.getParameter("fDate");
if(request.getParameter("tDate")!=null) tDate = request.getParameter("tDate");
if(request.getParameter("codProv")!=null) codProv = request.getParameter("codProv");
if(request.getParameter("tipo")!=null) tipo = request.getParameter("tipo");
else tipo ="NE";

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
	 
	CommonDataObject _cdo = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual");
	if(fDate.equals("")) fDate=_cdo.getColValue("fecha_ini");
	if(tDate.equals("")) tDate=_cdo.getColValue("fecha_fin");

	sbSql = new StringBuffer();
	sbSql.append("select rm.compania,rm.anio_recepcion||' - '||rm.numero_documento as trx,rm.anio_recepcion as anio,rm.numero_documento as no_doc,rm.codigo_almacen, a.cod_flia, a.cod_clase, a.cod_articulo, a.descripcion,(select descripcion from tbl_inv_almacen ia where ia.compania = rm.compania and ia.codigo_almacen = rm.codigo_almacen) almacen_desc,(nvl (d.cantidad,0)* nvl(d.articulo_und,1)) cantidad,to_char(rm.fecha_documento,'dd/mm/yyyy') as fecha,( select  p.nombre_proveedor from tbl_com_proveedor p where rm.cod_proveedor = p.cod_provedor and p.compania=rm.compania) nameProv from  tbl_inv_recepcion_material rm,tbl_inv_detalle_recepcion d ,tbl_inv_articulo  a where  rm.anio_recepcion=d.anio_recepcion and rm.numero_documento=d.numero_documento and rm.compania=d.compania  and rm.estado = 'R' and d.cod_articulo =a.cod_articulo and  rm.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	 
	if (!tipo.equals("")){
		sbSql.append(" and rm.fre_documento ='");
		sbSql.append(tipo); 
		sbSql.append("'");
	}
	if (!codProv.equals("")){
		sbSql.append(" and rm.cod_proveedor = ");
		sbSql.append(codProv); 
	}
	if (!art_familia.equals("")){
		sbSql.append(" and a.cod_flia = ");
		sbSql.append(art_familia); 
	}
	if (!art_clase.equals("")){
		sbSql.append(" and a.cod_clase = ");
		sbSql.append(art_clase); 
	}
	if (!cod_articulo.equals("")){
		sbSql.append(" and a.cod_articulo = ");
		sbSql.append(cod_articulo); 
	}
	if (!descripcion.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(descripcion.toUpperCase());
		sbSql.append("%'"); 
	}
	if (!almacen.equals("")){
		sbSql.append(" and rm.codigo_almacen = ");
		sbSql.append(almacen); 
	}
	if (!fDate.equals("")){
		sbSql.append(" and trunc(rm.fecha_documento) >= to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy')"); 
	}
	if (!tDate.equals("")){
		sbSql.append(" and trunc(rm.fecha_documento) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy')"); 
	}
	sbSql.append(" order by rm.codigo_almacen, a.descripcion,rm.anio_recepcion desc,rm.numero_documento desc");
	
	if(request.getParameter("cod_articulo")!=null){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	
	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sbSql.toString()+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
</script>
<script language="javascript">

function showMov(id,anio,articulo){abrir_ventana('../inventario/reg_recepcion_nentrega.jsp?fg=&mode=view&id='+id+'&anio='+anio+'&articulo='+articulo);}
function print(){
	abrir_ventana("../inventario/print_kardex.jsp?art_familia=<%=art_familia%>&art_clase=<%=art_clase%>&cod_articulo=<%=cod_articulo%>&descripcion=<%=descripcion.toUpperCase()%>&almacen=<%=almacen%>&fDate=<%=fDate%>&tDate=<%=tDate%>");
}
function clearP()
{
document.search01.descProv.value = "";
document.search01.codProv.value = "";
}
function showProveedor(){abrir_ventana('../compras/sel_proveedor.jsp?fp=nentrega');}

</script>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;<!--<a href="javascript:print()">[ Imprimir ]</a>--></td>
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
				<td><%//=sbSql.toString()%>
        	Almac&eacute;n:
          <%=fb.select(ConMgr.getConnection(),"SELECT codigo_almacen, codigo_almacen ||'-'||descripcion descripcion FROM TBL_INV_ALMACEN a WHERE compania = "+session.getAttribute("_companyId") +" ORDER BY descripcion","almacen",almacen,false,false,0,"text10",null,"","","S")%> 
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
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fDate" />
					<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
					<jsp:param name="nameOfTBox2" value="tDate" />
					<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
					</jsp:include>
					Prov:
					<%=fb.textBox("codProv",codProv,false,false,false,5,null,null,"onFocus=\"javascript:clearP()\"")%>
				<%=fb.textBox("descProv","TODOS LOS PROVEEDORES",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>
				Tipo Doc
				<%=fb.select("tipo","NE=NOTAS DE ENTREGA,FG=FACTURAS A CONSIGNACION",tipo,"S")%>
				
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
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
        <%=fb.hidden("codProv",codProv)%>
        <%=fb.hidden("tipo",tipo)%>
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
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
        <%=fb.hidden("codProv",codProv)%>
        <%=fb.hidden("tipo",tipo)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("articles","","post","");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("codProv",codProv)%>
        <%=fb.hidden("tipo",tipo)%>
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader">
				<td width="12%" align="center" rowspan="2">Almac&eacute;n</td>
				<td width="12%" align="center" rowspan="2">Proveedor</td>
				<td width="18%" align="center" colspan="3">C&oacute;digo</td>
				<td width="27%" align="center" rowspan="2">Descripci&oacute;n</td>
				<td width="12%" align="center" rowspan="2">Trx. </td>
				<td width="12%" align="center" rowspan="2">Fecha</td>
				<td width="11%" align="center" rowspan="2">Cantidad</td> 
			</tr>
			<tr class="TextHeader">
				<td width="6%" align="center">Familia</td>
				<td width="6%" align="center">Clase</td>
				<td width="6%" align="center">Art&iacute;culo</td>
			</tr>
<% 
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
      <td align="left"><%=cdo.getColValue("almacen_desc")%></td>
	  <td align="left"><%=cdo.getColValue("nameProv")%></td>
			<td align="center"><%=cdo.getColValue("cod_flia")%></td>
			<td align="center"><%=cdo.getColValue("cod_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td> 
			<td align="center" onClick="javascript:showMov(<%=cdo.getColValue("no_doc")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("cod_articulo")%>)" class="RedTextBold" style="cursor:pointer">
			<label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%=cdo.getColValue("trx")%>&nbsp;&nbsp;</label></label>
			</td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("cantidad")%></td>
			
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
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
        <%=fb.hidden("codProv",codProv)%>
        <%=fb.hidden("tipo",tipo)%>
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
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
        <%=fb.hidden("codProv",codProv)%>
        <%=fb.hidden("tipo",tipo)%>
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
}
%>
