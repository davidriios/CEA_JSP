
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
200069	VER LISTA DE ORDEN DE COMPRA NORMAL
200070	IMPRIMIR LISTA DE ORDEN DE COMPRA NORMAL
200071	AGREGAR SOLICITUD DE ORDEN DE COMPRA NORMAL
200072	MODIFICAR SOLICITUD DE ORDEN DE COMPRA NORMAL
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*if (
!( SecMgr.checkAccess(session.getId(),"0") 
	|| ((SecMgr.checkAccess(session.getId(),"200069") || SecMgr.checkAccess(session.getId(),"200070") || SecMgr.checkAccess(session.getId(),"200071") || SecMgr.checkAccess(session.getId(),"200072"))) )
	) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();

int rowCount = 0;
int Sw=0;
String sql = "";
String appendFilter = "";
String filter = "",anio_doc="";

String estado = request.getParameter("estado");
String tipo = request.getParameter("tipo");
String num_doc = request.getParameter("num_doc");
String wh = request.getParameter("wh");
String proveedor = request.getParameter("proveedor");
String desc_proveedor = request.getParameter("desc_proveedor");

String fecha = "",fecha_ini="",fecha_fin="",fechav_ini="",fechav_fin="";
if (estado==null) estado="";
if (tipo==null) tipo="";
if (num_doc==null) num_doc="";
if (wh==null) wh=""; 
if (proveedor==null) proveedor=""; 

if (!estado.trim().equals(""))
	appendFilter += " and a.status = '"+estado+"'";
if (!wh.trim().equals("")) appendFilter += " and a.cod_almacen="+wh;	

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);

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

	String vDoc="", vTipo="", vFecha="";
	if (!num_doc.trim().equals("")) 
	{
	vDoc = request.getParameter("num_doc");
	appendFilter += " and a.num_doc = "+vDoc;
   }
	if (!tipo.trim().equals(""))
	{
	vTipo = request.getParameter("tipo");
	appendFilter += " and a.tipo_compromiso = "+vTipo;
   }
	if ((request.getParameter("anio_doc") != null && !request.getParameter("anio_doc").trim().equals("")))
	{
		anio_doc = request.getParameter("anio_doc");
		appendFilter += "  and  a.anio = "+request.getParameter("anio_doc");
		
	}	
	if ((request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").trim().equals("")))
	{
		fecha_ini = request.getParameter("fecha_ini");
		appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+request.getParameter("fecha_ini")+"','dd/mm/yyyy') ";
		
	}
	if ((request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").trim().equals("")))
	{
		fecha_fin = request.getParameter("fecha_fin");
		appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+request.getParameter("fecha_fin")+"','dd/mm/yyyy') ";
		
	}	
	if ((request.getParameter("fechav_ini") != null && !request.getParameter("fechav_ini").trim().equals("")))
	{
		fechav_ini = request.getParameter("fecha_ini");
		appendFilter += " and to_date(to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+request.getParameter("fechav_ini")+"','dd/mm/yyyy') ";
		
	}
	if ((request.getParameter("fechav_fin") != null && !request.getParameter("fechav_fin").trim().equals("")))
	{
		fechav_fin = request.getParameter("fecha_fin");
		appendFilter += " and to_date(to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+request.getParameter("fechav_fin")+"','dd/mm/yyyy') ";
		
	}
	if ((request.getParameter("proveedor") != null && !request.getParameter("proveedor").trim().equals("")))
	{
		proveedor = request.getParameter("proveedor");
		appendFilter += "  and  a.cod_proveedor = "+request.getParameter("proveedor");
		
	}	
		
	String fields = "";       // variable para mantener el valor de los campos filtrados en la consulta
	/*	
	// Puedes buscar por año, solicitud, fecha, código o nombre del proveedor, código o nombre de almacen
	if (request.getParameter("fields") != null)
	{
	appendFilter += " and upper(a.anio||' '||a.num_doc||' '||to_char(a.fecha_documento,'dd/mm/yyyy')||' '||a.cod_proveedor||' '||b.nombre_proveedor||' '||a.cod_almacen||' '||c.descripcion) like '%"+request.getParameter("fields").toUpperCase()+"%'";
    searchOn = "";
    searchVal = request.getParameter("fields");
    searchType = "1";
    searchDisp = "Busqueda Combinada"; 
	fields   = request.getParameter("fields");  // variable para mantener el valor de los campos filtrados en la consulta
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
	appendFilter += " and upper(a.anio||' '||a.num_doc||' '||to_char(a.fecha_documento,'dd/mm/yyyy')||' '||a.cod_proveedor||' '||b.nombre_proveedor||' '||a.cod_almacen||' '||c.descripcion) like '%"+searchVal.toUpperCase()+"%'";
    }
	
	 if (searchType.equals("2"))
   {
     appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
	
	
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
  */
  if (!appendFilter.trim().equals("") || (!wh.trim().equals("0")) )
	{
	sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.compania, to_char(a.fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','F','APROBADO FINA','C','APROBADO CONTA','Z','CERRADO') desc_status, to_char(a.monto_total,'999,999,999,990.00') as monto_total, d.descripcion,  nvl(a.cod_proveedor, 0) || ' ' || nvl(b.nombre_proveedor, ' ') nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, a.numero_factura, to_char(nvl(a.fecha_entrega_vencimiento,''),'dd/mm/yyyy') as fechaVence, to_char(nvl(a.fecha_entrega_proveedor,''),'dd/mm/yyyy') as fechaProv,a.motivo as mot_cierre FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and a.compania = c.compania and a.tipo_compromiso = d.tipo_com and a.compania = "+session.getAttribute("_companyId") + appendFilter+""+filter+" order by a.cod_proveedor, a.tipo_compromiso, a.anio, a.fecha_documento, a.num_doc";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inventario - '+document.title;

function add(){abrir_ventana('../compras/reg_orden_compra_normal.jsp');}
function edit(anio, id, tp)
{
	if (tp==1)abrir_ventana('../compras/reg_orden_compra_normal.jsp?mode=view&id='+id+'&anio='+anio);
	else if (tp==2){abrir_ventana('../compras/reg_orden_compra_esp.jsp?mode=view&id='+id+'&anio='+anio);}
	else{abrir_ventana('../compras/reg_orden_compra_parcial.jsp?mode=view&id='+id+'&anio='+anio);}
}
function printDet(anio, id, tp, wh)
{
	if (tp==2)abrir_ventana('../compras/print_orden_especial.jsp?id='+id+'&num='+id+'&anio='+anio+'&tp='+tp+'&wh='+wh);		
	else if (tp==1){abrir_ventana('../compras/print_ordencompra.jsp?id='+id+'&anio='+anio+'&tp='+tp+'&wh='+wh);}
	else if (tp==3){abrir_ventana('../compras/print_orden_parcial.jsp?id='+id+'&num='+id+'&anio='+anio+'&tp='+tp+'&wh='+wh);}
}
function printList(){abrir_ventana('../compras/print_list_ordencompra_general.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>+<%=IBIZEscapeChars.forURL(filter)%>');}
function getMain(formX){formX.wh.value = document.searchMain.wh.value;return true;}
function buscaProv(){abrir_ventana1('../inventario/sel_recep_proveedor.jsp?fp=rep_orden_compra');}
$(function(){
  $(".observAyuda, .motivoAnul").tooltip({
	content: function () {

	  var $i = $(this).data("i");
	  var $type = $(this).data("type");
	  var $title = $($(this).prop('title'));
	  var $content;	 	  
	  if($type == "1" ) $content = $("#observAyudaCont"+$i).val(); 
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
  });
});

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRA - ORDEN DE COMPRA NORMAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
 
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

	<table width="100%" cellpadding="0" cellspacing="0">
	<tr class="TextFilter">
    	<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%> 
      	<%=fb.formStart(true)%>
      	<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
      	<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			
    <td colspan="3"> &nbsp;&nbsp; <cellbytelabel>Almac&eacute;n</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp; <%=fb.select("wh",alWh,wh, false, false, 0,"T")%>
    </td>
	</tr>
	
	<tr class="TextFilter">
    <td colspan="3"> &nbsp;&nbsp; <cellbytelabel>Documento</cellbytelabel> &nbsp;&nbsp;<%=fb.intBox("anio_doc",anio_doc,false,false,false,5,4)%><%=fb.textBox("num_doc",vDoc,false,false,false,10)%>
	    <cellbytelabel>Tipo de Compromiso</cellbytelabel> &nbsp;&nbsp;<%=fb.intBox("tipo",vTipo,false,false,false,10,5)%>  
		<cellbytelabel>Fecha de Vencimiento</cellbytelabel> &nbsp;&nbsp;&nbsp;
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fechav_ini" />
		<jsp:param name="valueOfTBox1" value="<%=fechav_ini%>" />
		<jsp:param name="nameOfTBox2" value="fechav_fin" />
		<jsp:param name="valueOfTBox2" value="<%=fechav_fin%>" />
		</jsp:include>
	</td>
	</tr>
	
	<tr class="TextFilter">
	<td colspan="3"> &nbsp;&nbsp;
		<cellbytelabel>Fecha Documento</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fecha_ini" />
		<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
		<jsp:param name="nameOfTBox2" value="fecha_fin" />
		<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
		</jsp:include>
		<cellbytelabel>Estado</cellbytelabel> 
		<%=fb.select("estado","A=Aprobado,N=Anulado,P=Pendiente,R=Procesado,T=Tramite,C=Aprob. cont.,F=Aprob. fin.,Z=Cerrado",estado, false, false, 0, "T")%> 
		&nbsp;
    <cellbytelabel>Proveedor</cellbytelabel>:
		<%=fb.intBox("proveedor",proveedor,false,false,true,5,null,null,"")%>
    <%=fb.textBox("desc_proveedor",desc_proveedor,false,false,true,40,null,null,"")%>
    <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaProv()\"")%>
		<%=fb.submit("go","Ir")%> </td>
					
       <%=fb.formEnd(true)%>
	</tr>
	</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fechav_ini",fechav_ini)%>
				<%=fb.hidden("fechav_fin",fechav_fin)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("num_doc",vDoc)%>
				<%=fb.hidden("anio_doc",anio_doc)%>
				<%=fb.hidden("tipo",vTipo)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fechav_ini",fechav_ini)%>
				<%=fb.hidden("fechav_fin",fechav_fin)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("num_doc",vDoc)%>
				<%=fb.hidden("anio_doc",anio_doc)%>
				<%=fb.hidden("tipo",vTipo)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
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
			<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="7%"><cellbytelabel>No. Solicitud</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Documento</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Factura</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Fecha de Vencimiento</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Monto</cellbytelabel></td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
		</tr>
<%
String descripcion = "";
String almacen = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
	if (!almacen.equalsIgnoreCase(cdo.getColValue("nombre_proveedor")))
	
	 {
%>
		
		<tr class="TextHeader01" align="left" bgcolor="#FFFFFF">
        <td colspan="10" class="TitulosdeTablas"> <%=cdo.getColValue("nombre_proveedor")%></td>
                   </tr>
				<%
				descripcion = "";
				   }
				 
	 if (!descripcion.equalsIgnoreCase(cdo.getColValue("descripcion")))
				 {
%>
		<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
        <td colspan="10" class="TitulosdeTablas"> [<%=cdo.getColValue("tipo_compromiso")%>] - <%=cdo.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				  %>
	<%=fb.hidden("observAyudaCont"+i,"<label class='observAyudaCont' style='font-size:11px'>"+(cdo.getColValue("mot_cierre")==null?"":cdo.getColValue("mot_cierre"))+"</label>")%>

		<tr  id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("num_doc")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"> <%=cdo.getColValue("numero_factura")%></td>
			<td align="center"><%=cdo.getColValue("fechaVence")%></td>
			<td align="center"><span class="observAyuda" title="" data-i="<%=i%>" data-type="1"><%=cdo.getColValue("desc_status")%></span></td>
			<td align="right"><%=cdo.getColValue("monto_total")%></td>
			<td align="center">	
				<authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>,<%=cdo.getColValue("tipo_compromiso")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link02Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype>
			</td>
			<td align="center">
				<authtype type='2'><a href="javascript:printDet(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>,<%=cdo.getColValue("tipo_compromiso")%>,'<%=cdo.getColValue("almacen_desc")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link02Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Imprimir</cellbytelabel></a></authtype>
			</td>
		</tr>
<%
     descripcion = cdo.getColValue("descripcion");
	 almacen = cdo.getColValue("nombre_proveedor");
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
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fechav_ini",fechav_ini)%>
				<%=fb.hidden("fechav_fin",fechav_fin)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("num_doc",vDoc)%>
				<%=fb.hidden("anio_doc",anio_doc)%>
				<%=fb.hidden("tipo",vTipo)%>
				<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fechav_ini",fechav_ini)%>
				<%=fb.hidden("fechav_fin",fechav_fin)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("num_doc",vDoc)%>
				<%=fb.hidden("anio_doc",anio_doc)%>
				<%=fb.hidden("tipo",vTipo)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
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
