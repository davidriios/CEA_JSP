<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();

int rowCount = 0;
String sql = "";
String appendFilter = "";

String estado = request.getParameter("estado");
String wh = request.getParameter("wh");
String anio ="",num_doc="";
String fecha = "",desc_prov="",prov ="",fecha_ini="",fecha_fin="",tipo="";
String validarEstadoOc = java.util.ResourceBundle.getBundle("issi").getString("validarOc");
if(validarEstadoOc==null) validarEstadoOc="N";

if(estado==null){
	estado = "";
	//appendFilter += " and a.status = ''";
} else if(!estado.trim().equals("")){
	appendFilter += " and a.status = '"+estado+"'";
}

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
/*if (wh == null)
{
	if (alWh.size() > 0)
	{
		wh = ((CommonDataObject) alWh.get(0)).getOptValueColumn();
		appendFilter += " and a.cod_almacen="+wh;
	}
	else wh = "";
}
else

*/
if (wh != null && !wh.trim().equals(""))
{
	appendFilter += " and a.cod_almacen="+wh;
}

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
	if (request.getParameter("num_doc") != null && !request.getParameter("num_doc").trim().equals(""))
	{
		num_doc = request.getParameter("num_doc");
		appendFilter += " and upper(a.num_doc) like '%"+request.getParameter("num_doc").toUpperCase()+"%'";
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		anio = request.getParameter("anio");
		appendFilter += " and a.anio = "+request.getParameter("anio"); 
	}
	if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals("") )
	{
	fecha = request.getParameter("fecha");
	appendFilter += " and to_dete(to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy'),'dd/mm/yyyy') =  to_date('"+request.getParameter("fecha")+"','dd/mm/yyyy'";
 	}
	if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals(""))
	{
	tipo = request.getParameter("tipo");
	appendFilter += " and a.tipo_compromiso = "+request.getParameter("tipo");
  	}
	if (request.getParameter("prov") != null && !request.getParameter("prov").trim().equals(""))
	{
		prov = request.getParameter("prov");
		appendFilter += " and a.cod_proveedor = "+request.getParameter("prov");
	}
	if (request.getParameter("desc_prov") != null && !request.getParameter("desc_prov").trim().equals(""))
	{
		desc_prov = request.getParameter("desc_prov");
		appendFilter += " and b.nombre_proveedor like '%"+request.getParameter("desc_prov").toUpperCase()+"%'";
 	}
	if ((request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").trim().equals("")))
	{
		fecha_ini = request.getParameter("fecha_ini");
 		appendFilter += " and trunc(a.fecha_documento) >= to_date('"+request.getParameter("fecha_ini")+"','dd/mm/yyyy')";
 	}
	if (( request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").trim().equals("")))
	{
		fecha_fin = request.getParameter("fecha_fin");
		appendFilter += " and trunc(a.fecha_documento) <= to_date('"+request.getParameter("fecha_fin")+"','dd/mm/yyyy') ";
	}
 	String fields = "";       // variable para mantener el valor de los campos filtrados en la consulta
 	if (!appendFilter.trim().equals(""))
	{
	sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.compania, to_char(a.fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','F','APROBADO FINA','C','APROBADO CONTA','Z','CERRADO') desc_status, to_char(a.monto_total,'999,999,999,990.00') as monto_total, d.descripcion,  nvl(a.cod_proveedor, 0) || ' ' || nvl(b.nombre_proveedor, ' ') nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, a.numero_factura, to_char(nvl(a.fecha_entrega_vencimiento,''),'dd/mm/yyyy') as fechaVence, to_char(nvl(a.fecha_entrega_proveedor,''),'dd/mm/yyyy') as fechaProv, (case when a.status = 'A'/* and a.monto_total < 1000 then 'S' when a.status = 'C' and a.monto_total between 1000.01 and 2500 then 'S' when a.status = 'F' and a.monto_total > 2500 then 'S'*/ then 'S' else 'N' end) entregar,a.motivo as mot_cierre FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and a.compania = c.compania and a.tipo_compromiso = d.tipo_com and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by  a.tipo_compromiso, a.anio desc, a.fecha_documento desc, a.num_doc desc";

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Entrega de Ordenes al Proveedor - '+document.title;
function edit(anio, id, tp, st){if (tp==1){abrir_ventana('../compras/reg_orden_compra_normal.jsp?fg=EOC&mode=view&id='+id+'&anio='+anio);}else{abrir_ventana('../compras/reg_orden_compra_parcial.jsp?fg=EOC&mode=view&id='+id+'&anio='+anio+'&tp='+tp+'&status='+st);}}    
function cerrar(anio, id){showPopWin('../process/inv_cerrar_orden_prov.jsp?anio='+anio+'&id='+id,winWidth*.65,_contentHeight*.75,null,null,'');}
function printDet(num,anio, tp, wh, st){abrir_ventana('../compras/print_orden_parcial.jsp?num='+num+'&anio='+anio+'&tp='+tp+'&wh='+wh+'&status='+st);}
function printList(){abrir_ventana('../compras/print_list_ordencompra_general.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}

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
<jsp:param name="title" value="COMPRA - ORDEN DE ENTREGA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">

	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextFilter">
		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

		<td width="45%">
			<cellbytelabel>Almac&eacute;n</cellbytelabel>
			<%=fb.select("wh",alWh,wh, false, false, 0,"T")%>

		</td>
	<td width="35%">
	<cellbytelabel>Tipo de Compromiso</cellbytelabel>
	<%=fb.select(ConMgr.getConnection(),"select tipo_com, '[ '||tipo_com||' ] '||descripcion from tbl_com_tipo_compromiso where estatus='A'   order by tipo_com","tipo",tipo,false,false,0,"")%>
	 </td>
	 <td width="20%">
		Estado 	<%//=fb.select("estado","A=Aprobado,N=Anulado,P=Pendiente,R=Procesado,T=Trámite,C=Aprobado Cont.,F=Aprobado Fina.",estado, false, false, 0, "T")%>
		<%=fb.select("estado","A=Aprobado,N=Anulado,P=Pendiente,R=Procesado,T=Trámite,Z=Cerrado",estado, false, false, 0, "T")%>
	 </td>

	</tr>


	<tr class="TextFilter">
					<td>
						<cellbytelabel>N&uacute;mero</cellbytelabel>
						<%=fb.textBox("anio",anio,false,false,false,10)%>
						<%=fb.textBox("num_doc",num_doc,false,false,false,10)%>
						<cellbytelabel>Fecha de Vencimiento</cellbytelabel>
						<%=fb.textBox("fecha",fecha,false,false,false,10)%>
		 </td>
				 <td colspan="2"> 					<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2"/>
											<jsp:param name="clearOption" value="true"/>
											<jsp:param name="nameOfTBox1" value="fecha_ini"/>
											<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>"/>
											<jsp:param name="nameOfTBox2" value="fecha_fin"/>
											<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>"/>
											</jsp:include>


		 </td>
		 </tr>
		<tr class="TextFilter">
		 <td colspan="3">	<cellbytelabel>C&oacute;digo Prov</cellbytelabel>.
		 <%=fb.textBox("prov",prov,false,false,false,10)%>
		 <cellbytelabel>Nombre Prov</cellbytelabel>.
		 <%=fb.textBox("desc_prov",desc_prov,false,false,false,30)%>

		 <%=fb.submit("go","Ir")%>
		 </td>
		</tr>
			<%=fb.formEnd()%>
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
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("desc_prov",desc_prov)%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
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
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("desc_prov",desc_prov)%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
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
			<td width="4%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="4%"><cellbytelabel>No. Solicitud</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Documento</cellbytelabel></td>
			<td width="24%"><cellbytelabel>Proveedor</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Factura</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha de Entrega</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha de Vencimiento</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="7%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
<%
String descripcion = "";
String almacen = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	 if (!descripcion.equalsIgnoreCase(cdo.getColValue("descripcion")))
	 {%>
		<tr align="left" bgcolor="#FFFFFF" class="TextHeader01">
				<td colspan="11" class="TitulosdeTablas"> [<%=cdo.getColValue("tipo_compromiso")%>] - <%=cdo.getColValue("descripcion")%></td>
									 </tr>
	<%}%>
<%=fb.hidden("observAyudaCont"+i,"<label class='observAyudaCont' style='font-size:11px'>"+(cdo.getColValue("mot_cierre")==null?"":cdo.getColValue("mot_cierre"))+"</label>")%>
		<tr  id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("num_doc")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td> <%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"> <%=cdo.getColValue("numero_factura")%></td>
			<td align="center"><%=cdo.getColValue("fechaProv")%></td>
			<td align="center"><%=cdo.getColValue("fechaVence")%></td>
			<td align="center">
			
			<span class="observAyuda" title="" data-i="<%=i%>" data-type="1"><%=cdo.getColValue("desc_status")%></span>
			</td>
			<td align="center">&nbsp;
			<%
			if (cdo.getColValue("entregar").equalsIgnoreCase("S")){
			%>
			<a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>,<%=cdo.getColValue("tipo_compromiso")%>,'<%=cdo.getColValue("status")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextblack')"><cellbytelabel>Entregar</cellbytelabel></a>
			<%
			}
            if (cdo.getColValue("status")!=null && (cdo.getColValue("status").equals("A")||cdo.getColValue("status").equals("C")||cdo.getColValue("status").equals("F")) ){
			%>
              <br><authtype type='50'><a href="javascript:cerrar(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextblack')"><cellbytelabel>Cerrar</cellbytelabel></a></authtype>
            <%}%>
			</td>
			<td align="center">

<%if(cdo.getColValue("status").trim().equals("A")||validarEstadoOc.trim().equals("N")){%>
		<authtype type='2'><a href="javascript:printDet(<%=cdo.getColValue("num_doc")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("tipo_compromiso")%>,'<%=cdo.getColValue("almacen_desc")%>,<%=cdo.getColValue("desc_status")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextblack')"><cellbytelabel>Imprimir</cellbytelabel></a></authtype><%}%>
		
			</td>
		</tr>
<%descripcion = cdo.getColValue("descripcion");
}%>
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
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("desc_prov",desc_prov)%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
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
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("desc_prov",desc_prov)%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>