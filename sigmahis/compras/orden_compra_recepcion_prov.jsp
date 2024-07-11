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

String sql = "";
String empId = request.getParameter("empId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id");  

if (id == null || anio == null) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, d.descripcion, a.monto_total as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(a.monto_pagado,'0.00') as monto_pago, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion as tipoOrden, f.descripcion as articulo, e.cantidad, to_char(e.cantidad - nvl(e.entregado,'0'),'999,999,990') as pendiente, to_char(e.monto_articulo,'999,999,990.00') as montoArticulo, e.estado_renglon as estadoRenglon, a.explicacion, e.entregado as cantEntregada "
+ " from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_detalle_compromiso e, tbl_inv_articulo f "
+ " where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and "
+ " a.compania = c.compania and a.compania = e.compania and a.num_doc = e.cf_num_doc and a.tipo_compromiso = e.cf_tipo_com and e.cod_familia = f.cod_flia and e.cod_clase = f.cod_clase and e.cod_articulo = f.cod_articulo and e.compania = f.compania and a.anio = e.cf_anio and a.tipo_compromiso = d.tipo_com and a.anio = "+anio+" and a.num_doc = "+id+" and a.status = 'A' and a.tipo_compromiso <> 3 and e.estado_renglon ='P' and a.compania = "+session.getAttribute("_companyId")+" order by a.cod_proveedor, a.anio, a.fecha_documento, a.num_doc";	

al = SQLMgr.getDataList(sql); 
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Compras - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}


function printList(anio,num)
{
	abrir_ventana('../compras/print_orden.jsp?anio='+anio+'&num='+num);
 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="COMPRAS"></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("cod",cod)%>
<%=fb.hidden("num",cod)%>
<%=fb.hidden("anio",anio)%>

<table align="center" width="90%" cellpadding="1" cellspacing="1">
<tr>
	<td class="TableLeftBorder TableRightBorder">
  <a href="javascript:printList('<%=anio%>','<%=id%>')" class="Link00">[ <cellbytelabel>Imprimir Orden</cellbytelabel> ]</a>
       
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%
for (int i=0; i<1; i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	
%>
		<table align="center" width="90%" cellpadding="1" cellspacing="1">
		<tbody id="list">
		<tr class="TextHeader" align="center">
			 <td colspan="6"> <cellbytelabel>ORDEN DE COMPRA PENDIENTE DE ENTREGA POR RECEPCION</cellbytelabel></td>
  </tr>
  
<tr align="center" class="TextHeader">
    <td width="15%" ># <cellbytelabel>Orden de Compra</cellbytelabel>:&nbsp; </td>
	<td width="15%"><%=cdo.getColValue("ordenNum")%> </td>
	<td width="20%">&nbsp; </td>
	<td width="20%">&nbsp; </td>
    <td width="15%" ><cellbytelabel>Estado</cellbytelabel>:&nbsp;</td>
	<td width="15%" ><%=cdo.getColValue("desc_status")%></td>
  </tr>
  
  <tr align="center" class="TextHeader">
    <td colspan="6"> <cellbytelabel>Proveedor</cellbytelabel> : &nbsp;<%=cdo.getColValue("nombre_proveedor")%></td>
	</tr>
	 <tr align="center" class="TextHeader">
    <td colspan="6"><p><cellbytelabel>Saldo</cellbytelabel> &nbsp; <%=cdo.getColValue("saldo")%> </td>
  </tr>
  
  <tr align="center" class="TextHeader">
  <td colspan="1" align="center">* <cellbytelabel>Fecha</cellbytelabel>  * </td>
    <td colspan="2" align="center">* * * *  <cellbytelabel>&Aacute;rticulo</cellbytelabel>   * * * * </td>
	<td colspan="1" align="center"> <cellbytelabel>Cantidad Solicitada</cellbytelabel> </td>
	<td colspan="1" align="center"> <cellbytelabel>Cantidad Pendiente</cellbytelabel></td>
	<td colspan="1" align="center">* <cellbytelabel>Monto Unidad</cellbytelabel>  * </td>
	
  </tr>
  <%
  
  
  }
  %>
<%
String descripcion = "";
String almacen = "";

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
	if (!almacen.equalsIgnoreCase(cdo1.getColValue("nombre_proveedor")))
	
	 {
%>
		
		<tr class="TextHeader01" align="left" bgcolor="#FFFFFF">
     
	    <td colspan="6" class="TitulosdeTablas"> <%=cdo1.getColValue("nombre_proveedor")%></td>
        
		           </tr>
				<%
				descripcion = "";
				   }
				 
	 if (!descripcion.equalsIgnoreCase(cdo1.getColValue("descripcion")))
				 {
%>
		<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
        <td colspan="6" class="TitulosdeTablas"> [<%=cdo1.getColValue("tipo_compromiso")%>] - <%=cdo1.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				  %>
		
		<tr  id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td colspan="1" align="center"> <%=cdo1.getColValue("fecha_documento")%></td>
			<td colspan="2" align="left"><%=cdo1.getColValue("articulo")%></td>
			<td colspan="1" align="center"><%=cdo1.getColValue("cantidad")%></td>
			<td colspan="1" align="center"><%=cdo1.getColValue("pendiente")%></td>
			<td colspan="1" align="right"><%=cdo1.getColValue("montoArticulo")%></td>
			
			
			
		</tr>
<%
     descripcion = cdo1.getColValue("descripcion");
	 almacen = cdo1.getColValue("nombre_proveedor");
}
%>
 </tbody>	
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>

</table>





<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
