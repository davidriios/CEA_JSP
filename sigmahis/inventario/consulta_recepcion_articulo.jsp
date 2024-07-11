<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

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
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String articulo = request.getParameter("articulo");
String appendFilter = "";
String wh = request.getParameter("wh"); 
String id = request.getParameter("id"); 
String prov = request.getParameter("prov"); 

if (articulo == null ) articulo= "";
if (wh == null ) wh= "";
if (prov == null ) prov= "";
if (appendFilter == null ) appendFilter = "";
//if (articulo == null || wh == null) throw new Exception("El Articulo no es válido. Por favor intente nuevamente!");
if (articulo == null ) throw new Exception("El Articulo no es válido. Por favor intente nuevamente!");

if (request.getParameter("articulo") != null && !request.getParameter("articulo").trim().equals(""))
	{
appendFilter += " and a.cod_flia||'-'||a.cod_clase||'-'||d.cod_articulo = '"+articulo+"'";
	}

if (request.getParameter("wh") != null && !request.getParameter("wh").trim().equals(""))
	{
	appendFilter += " and r.codigo_almacen = "+wh;
	}



if (request.getMethod().equalsIgnoreCase("GET"))
{



sql=" select nvl(a.descripcion,' ') desArticulo,a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo articulo,  nvl(p.nombre_proveedor,' ') desc_proveedor, to_char(r.fecha_creacion,'dd/mm/yyyy')  ultima_fecha, r.numero_factura factura, r.cod_proveedor, r.usuario_creacion usuario, sum(d.cantidad_facturada) comprada, r.numero_documento num_docto, r.anio_recepcion anio from tbl_inv_articulo a, tbl_com_proveedor p, tbl_inv_recepcion_material r, tbl_inv_detalle_recepcion d where p.cod_provedor = r.cod_proveedor and a.cod_articulo = d.cod_articulo and a.compania = r.compania and  r.anio_recepcion||r.numero_documento  = ( select   max(r.anio_recepcion||r.numero_documento)  v_recepcion from    tbl_inv_recepcion_material r, tbl_inv_detalle_recepcion d where r.anio_recepcion    = d.anio_recepcion and   r.numero_documento  = d.numero_documento and   r.compania          = d.compania and   r.estado            <> 'A' and   d.cantidad           > 0  and   r.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and   r.fecha_documento   = (select  max(fecha_documento) from    tbl_inv_recepcion_material r,  tbl_inv_detalle_recepcion d  where r.anio_recepcion    = d.anio_recepcion  and   r.numero_documento  = d.numero_documento  and   r.compania          = d.compania  and   r.estado            <> 'A'  and   d.cantidad           > 0  and   r.compania = "+(String) session.getAttribute("_companyId")+appendFilter+")) and   r.anio_recepcion    = d.anio_recepcion and   r.numero_documento  = d.numero_documento and   r.compania          = d.compania and   r.estado            <> 'A'  and   d.cantidad          > 0  and   r.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" group by  r.fecha_creacion, r.numero_factura, r.cod_proveedor,r.usuario_creacion, r.numero_documento, r.anio_recepcion ,nvl(a.descripcion,' ') ,a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo ,  nvl(p.nombre_proveedor,' ') ";  

	al = SQLMgr.getDataList(sql);
	
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Recepcion de Artículo - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}



</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">


<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="INFORMACION DE ULTIMA COMPRA DEL ARTICULO"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%//=fb.hidden("mode","")%>
<%//=fb.hidden("seccion","")%>
<%//=fb.hidden("size","")%>
<%//=fb.hidden("dob","")%>

<table width="75%" cellpadding="1" cellspacing="1" align="center">
  <%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
					
%>
  
  <tr align="left" class="TextHeader">
    <td width="31%">Artículo:</td>
    <td colspan="2"><%=cdo.getColValue("desArticulo")%></td>
  </tr>
  
  <tr align="left" class="TextRow01">
    <td width="25%">Proveedor:&nbsp;</td>
    <td width="10%" colspan="1" align="left"> <%=cdo.getColValue("cod_proveedor")%></td>
    <td width="65%"><%=cdo.getColValue("desc_proveedor")%></td>
  </tr>
  
  <tr align="left" class="TextRow01">
    <td width="31%">Fecha de Ultima Compra:&nbsp;</td>
    <td colspan="2" align="left"> <%=cdo.getColValue("ultima_fecha")%></td>
  </tr>
  
   <tr align="left" class="TextRow01">
    <td width="31%">Ultima Cantidad Comprada:&nbsp;</td>
    <td colspan="2" align="left"> <%=CmnMgr.getFormattedDecimal(cdo.getColValue("comprada"))%></td>
  </tr>

 <tr align="left" class="TextRow01">
    <td>Número de Factura :&nbsp;</td>
    <td colspan="2" align="left"> <%=cdo.getColValue("factura")%></td>
  </tr>
 
<tr align="left" class="TextRow01">
    <td>Recpción No. :&nbsp;</td>
    <td align="left"> <%=cdo.getColValue("num_docto")%></td>
    <td><%=cdo.getColValue("anio")%></td>
  </tr>
 
  <tr align="left" class="TextRow01">
    <td>Usuario Creación :&nbsp;</td>
    <td colspan="2" align="left"> <%=cdo.getColValue("usuario")%></td>
  </tr>
  <tr align="left" class="TextRow01">
    <td colspan="3" align="center"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
  </tr>
  <% 
  	}
	if (al.size() == 0)
	{
	%>
	 <tr align="left" class="TextRow01">
    <td width="31%">&nbsp;</td>
    <td  align="left"> No Hay Registro para este Artículo </td>
    <td >&nbsp;</td>
  </tr>
	<% }
	
	
%>
</table>
<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
