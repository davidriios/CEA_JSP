<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
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
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
String lista = request.getParameter("lista");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String aseguradora = request.getParameter("aseguradora");
String aseguradoraDesc = request.getParameter("aseguradoraDesc");
String categoria = request.getParameter("categoria");
boolean viewMode = false;
int iconHeight = 20;
int iconWidth = 20;

if(fg==null) fg = "";
if(fp==null) fp = "";

if(lista==null) lista = "";
if(tDate==null) tDate = "";
if(fDate==null) fDate = "";
if(aseguradora==null) aseguradora = "";
if(aseguradoraDesc==null) aseguradoraDesc = "";
if(categoria==null) categoria = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){

	if(!lista.equals("")) appendFilter = " and f.lista = "+lista;
	if(!tDate.equals("")) appendFilter += " and trunc(f.fecha_envio) >= to_date('"+fDate+"', 'dd/mm/yyyy')";
	if(!fDate.equals("")) appendFilter += " and trunc(f.fecha_envio) <= to_date('"+tDate+"', 'dd/mm/yyyy')";
	if(!aseguradora.equals("")) appendFilter += " and f.aseguradora = "+aseguradora;
	if(!categoria.equals("")) appendFilter += " and f.categoria = "+categoria;
	
 if (request.getParameter("categoria") != null)
 {
	sql = "select f.compania, to_char(f.fecha_envio, 'dd/mm/yyyy') fecha_envio, f.aseguradora, (select nombre from tbl_adm_empresa where codigo = f.aseguradora) aseguradora_desc, f.categoria, (select descripcion from tbl_adm_categoria_admision where codigo = f.categoria) categoria_desc, lista numero_lista, comentario, enviado_por usuario, f.usuario_creacion,f.facturar_a from tbl_fac_lista f where /*usuario_creacion = '"+(String) session.getAttribute("_userName")+"' and*/ f.fecha_recibido is null and f.enviado is null "+appendFilter+" order by f.aseguradora, f.categoria, lista, f.fecha_envio desc";
al = SQLMgr.getDataList(sql);
	sql = "select f.compania, to_char(f.fecha_envio, 'dd/mm/yyyy') fecha_envio, f.aseguradora, (select nombre from tbl_adm_empresa where codigo = f.aseguradora) aseguradora_desc, f.categoria, (select descripcion from tbl_adm_categoria_admision where codigo = f.categoria) categoria_desc, lista numero_lista, comentario, enviado_por usuario, to_char(fecha_recibido, 'dd/mm/yyyy') fecha_recibido,f.facturar_a from tbl_fac_lista f where /*usuario_creacion = '"+(String) session.getAttribute("_userName")+"' and */f.fecha_recibido is not null and f.enviado is not null "+appendFilter+" order by f.aseguradora, f.categoria, lista, f.fecha_envio desc";
al2 = SQLMgr.getDataList(sql);
}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturación- '+document.title;
function doAction(){}
function doSubmit(value){document.orden_pago.action.value = value;}
function reloadPage(){var categoria = document.search00.categoria.value;var aseguradora = document.search00.aseguradora.value;var aseguradoraDesc = document.search00.aseguradoraDesc.value;var fDate = document.search00.fDate.value;var tDate = document.search00.tDate.value;var lista = document.search00.lista.value;window.location = '../facturacion/editar_lista_envio.jsp?categoria='+categoria+'&aseguradora='+aseguradora+'&aseguradoraDesc='+aseguradoraDesc+'&fDate='+fDate+'&tDate='+tDate+'&lista='+lista;}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=edit_list_aseg');}
function printLista(prefix,k){var fecha_envio = eval('document.orden_pago.fecha_envio'+prefix+k).value;var aseguradora = eval('document.orden_pago.aseguradora'+prefix+k).value;
	var facturas_a =  eval('document.orden_pago.facturar_a'+prefix+k).value;
	var categoria =  eval('document.orden_pago.categoria'+prefix+k).value;
	var lista =  eval('document.orden_pago.numero_lista'+prefix+k).value;
	if(fecha_envio != '' && aseguradora != '' && facturas_a != '' && categoria != ''&&lista!='')abrir_ventana('../facturacion/print_list_envia_aseg.jsp?cod_empresa='+aseguradora+'&facturas_a='+facturas_a+'&lista='+lista+'&fecha_envio='+fecha_envio+'&categoria='+categoria);else alert('Los parametros no estan completos. Verifique!!');

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
    	<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td>
          	<table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextFilter">
          <%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
          <%=fb.formStart()%>
          <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
          <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
                <td colspan="6">
                  <cellbytelabel>Categor&iacute;a</cellbytelabel>
                  <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_adm_categoria_admision order by codigo","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
                  <cellbytelabel>Fecha Lista</cellbytelabel>:
                  <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="2" />
                  <jsp:param name="nameOfTBox1" value="fDate" />
                  <jsp:param name="valueOfTBox1" value="<%=fDate%>" />
                  <jsp:param name="nameOfTBox2" value="tDate" />
                  <jsp:param name="valueOfTBox2" value="<%=tDate%>" />
                  <jsp:param name="fieldClass" value="Text10" />
                  <jsp:param name="buttonClass" value="Text10" />
                  </jsp:include>
									<cellbytelabel>Num. Lista</cellbytelabel>:
									<%=fb.textBox("lista",lista,false,false,false,5,"Text10",null,null)%>
                  Aseguradora:
									<%=fb.intBox("aseguradora",aseguradora,false,false,false,5,"Text10",null,"")%> 
                  <%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,false,30,"Text10",null,null)%> 
                  <%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%> 
									<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
                  <%=fb.formEnd()%>
                </td>
              </tr>
              <%fb = new FormBean("orden_pago","","post");%>
              <%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("errCode","")%> <%=fb.hidden("errMsg","")%> 
			  <%=fb.hidden("saveOption","")%> <%=fb.hidden("clearHT","")%> 
			  <%=fb.hidden("action","")%> <%=fb.hidden("fg",fg)%>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>LISTA DE ENVIO DE FACTURAS PENDIENTES</cellbytelabel></td>
              </tr>
              <tr class="">
              	<td colspan="6">
		<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:240">
		<div id="list_op" width="100%" style="overflow;position:absolute">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center" width="10%"><cellbytelabel>Usuario</cellbytelabel></td>
                <td align="center" width="25%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
                <td align="center" width="35%"><cellbytelabel>Aseguradora</cellbytelabel></td>
                <td align="center" width="10%"><cellbytelabel>No. Lista</cellbytelabel></td>
                <td align="center" width="10%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
                <td align="center" width="5%">&nbsp;</td>
				<td align="center" width="5%">&nbsp;</td>
              </tr>
              <%
							for (int i=0; i<al.size(); i++){
								cdo = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
						%>
							<%=fb.hidden("usuario"+i,cdo.getColValue("usuario"))%>
							<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
							<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
							<%=fb.hidden("aseguradora"+i,cdo.getColValue("aseguradora"))%>
							<%=fb.hidden("numero_lista"+i,cdo.getColValue("numero_lista"))%>
							<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
							<%=fb.hidden("fecha_envio"+i,cdo.getColValue("fecha_envio"))%>
							<%=fb.hidden("facturar_a"+i,cdo.getColValue("facturar_a"))%>
							
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center"><%=cdo.getColValue("usuario")%> </td>
                <td><%=cdo.getColValue("categoria")%>-<%=cdo.getColValue("categoria_desc")%></td>
                <td><%=cdo.getColValue("aseguradora")%>-<%=cdo.getColValue("aseguradora_desc")%></td>
                <td align="center"><%=cdo.getColValue("numero_lista")%> </td>
                <td align="center"><%=cdo.getColValue("fecha_envio")%></td>
                <td align="center"><a href="javascript:showPopWin('../facturacion/cambiar_fecha_envio_lista.jsp?categoria=<%=cdo.getColValue("categoria")%>&aseguradora=<%=cdo.getColValue("aseguradora")%>&numero_lista=<%=cdo.getColValue("numero_lista")%>&fecha=<%=cdo.getColValue("fecha_envio")%>&fechaEnvio=<%=cdo.getColValue("fecha_envio")%>&facturado_a=<%=cdo.getColValue("facturar_a")%>&usuario=<%=cdo.getColValue("usuario_creacion")%>',winWidth*.55,_contentHeight*.35,null,null,'');"><font class="BoltText"><cellbytelabel>Cambiar Fecha</cellbytelabel></font></a></td>
				<td align="center"><authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Lista')" onClick="javascript:printLista('',<%=i%>)"></authtype></td>
              </tr>
              <%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <tr>
                <td colspan="6">&nbsp;</td>
              </tr>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>LISTA DE ENVIO DE FACTURAS ENVIADAS</cellbytelabel></td>
              </tr>
              <tr class="">
              	<td colspan="6">
		<div id="list_opMain2" width="100%" style="overflow:scroll;position:relative;height:240">
		<div id="list_op2" width="100%" style="overflow;position:absolute">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center"><cellbytelabel>Usuario</cellbytelabel></td>
                <td align="center"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
                <td align="center"><cellbytelabel>Aseguradora</cellbytelabel></td>
                <td align="center"><cellbytelabel>No. Lista</cellbytelabel></td>
                <td align="center"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
                <td align="center"><cellbytelabel>Fecha Recibido</cellbytelabel></td>
				 <td align="center">&nbsp;</td>
              </tr>
              <%
							for (int i=0; i<al2.size(); i++){
								cdo = (CommonDataObject) al2.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
						%>
						<%=fb.hidden("categoriaE"+i,cdo.getColValue("categoria"))%>
						<%=fb.hidden("aseguradoraE"+i,cdo.getColValue("aseguradora"))%>
						<%=fb.hidden("numero_listaE"+i,cdo.getColValue("numero_lista"))%>
						<%=fb.hidden("fecha_envioE"+i,cdo.getColValue("fecha_envio"))%>
						<%=fb.hidden("facturar_aE"+i,cdo.getColValue("facturar_a"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center"><%=cdo.getColValue("usuario")%> </td>
                <td><%=cdo.getColValue("categoria")%>-<%=cdo.getColValue("categoria_desc")%></td>
                <td><%=cdo.getColValue("aseguradora")%>-<%=cdo.getColValue("aseguradora_desc")%></td>
                <td align="center"><%=cdo.getColValue("numero_lista")%> </td>
                <td align="center"><%=cdo.getColValue("fecha_envio")%></td>
                <td align="center"><%=cdo.getColValue("fecha_recibido")%></td>
				<td align="center"><authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Lista')" onClick="javascript:printLista('E',<%=i%>)"></authtype></td>
              </tr>
              <%}%>
              <%=fb.hidden("keySize2",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <%=fb.formEnd(true)%>
              <!-- ================================   F O R M   E N D   H E R E   ================================ -->
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>
