
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
String fecha = "",desc_prov="",prov ="",nombre_proveedor="",cod_proveedor ="",fecha_ini="",fecha_fin="",tipo="", factura="", check="";

if(estado==null){
	estado = "";
	//appendFilter += " and a.status = ''";
} else if(!estado.trim().equals("")){
	appendFilter += " and a.estado = '"+estado+"'";
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

	
	if (request.getParameter("cod_proveedor") != null && !request.getParameter("cod_proveedor").trim().equals(""))
	{
		cod_proveedor = request.getParameter("cod_proveedor");
		appendFilter += " and a.cod_proveedor = "+request.getParameter("cod_proveedor");
	}
	if (request.getParameter("nombre_proveedor") != null && !request.getParameter("nombre_proveedor").trim().equals(""))
	{
		nombre_proveedor = request.getParameter("nombre_proveedor");
		appendFilter += " and b.nombre_proveedor like '%"+request.getParameter("nombre_proveedor").toUpperCase()+"%'";
		
	}
	if ((request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").trim().equals("")) &&( request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").trim().equals("")))
	{
		fecha_ini = request.getParameter("fecha_ini");
		fecha_fin = request.getParameter("fecha_fin");
		appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+request.getParameter("fecha_ini")+"','dd/mm/yyyy') and to_date('"+request.getParameter("fecha_fin")+"','dd/mm/yyyy') ";
		
	}
	
		if (request.getParameter("check") != null && !request.getParameter("check").trim().equals(""))
	{
		check = request.getParameter("check");
		if(check.trim().equals("T"))
		{
			
			appendFilter += " and (a.monto_pagado is null or a.monto_pagado = 0.00 or a.monto_total > a.monto_pagado or a.monto_total < a.monto_pagado) ";
			
		}
		else {  appendFilter += " and (a.ref_cheque IS NULL or a.monto_pagado IS NULL) ";
	}
	}
	
	

	String fields = "";       // variable para mantener el valor de los campos filtrados en la consulta
		

	if (!appendFilter.trim().equals(""))
	{
	if (!check.trim().equals(""))
	{
	sql = "select a.anio_recepcion anio, a.numero_documento, a.explicacion, nvl(a.monto_total,0) monto, a.numero_factura, a.codigo_almacen, to_char(a.fecha_documento,'dd/mm/yyyy') fecha, nvl(a.itbm,0) itbm, nvl(a.subtotal,0) subtotal, a.fre_documento, a.cf_anio, a.cf_num_doc, a.cf_tipo_com, nvl(a.monto_pagado,0) monto_pagado, a.cod_proveedor, a.tipo_factura, a.estado, a.asiento_sino, a.ref_cheque, nvl(a.ajuste,0) ajuste, nvl(a.descuento,0) descuento, nvl(a.porcentaje,0) porcentaje, decode(a.estado,'R','RECIBIDA','A','ANULADA','') estadoDes, a.numero_entrega, a.ref_ach, a.rec_sop_pamd, a.correccion, a.cod_concepto, b.nombre_proveedor proveedor, c.descripcion almacen , 'N' marcado from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c where a.compania = b.compania(+) and a.cod_proveedor = b.cod_provedor(+) and a.codigo_almacen = c.codigo_almacen(+) and a.compania = c.compania(+) and a.estado='R' and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by a.cod_proveedor, a.anio_recepcion, a.numero_documento";
	
	

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	System.out.println("sql = "+al.size()+"//"+sql);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
	}
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
document.title = 'Saldo de Facturas - '+document.title;


function edit(anio, id, tp, st)
{
 if (tp==2)
	{
	abrir_ventana('../compras/reg_orden_compra_esp.jsp?fg=EOC&mode=delivery&id='+id+'&anio='+anio);
	}
	else 
	{
	abrir_ventana('../compras/reg_orden_compra_parcial.jsp?fg=EOC&mode=view&id='+id+'&anio='+anio+'&tp='+tp+'&status='+st);
	}
}

function printDet(anio, num, tp, wh, st)
{
	if (tp==2)
	{
	abrir_ventana('../compras/print_orden_especial.jsp?num='+num+'&anio='+anio+'&tp='+tp+'&wh='+wh+'&status='+st);
		
}
	else 
	{
	abrir_ventana('../compras/print_orden_parcial.jsp?num='+num+'&anio='+anio+'&tp='+tp+'&wh='+wh+'&status='+st);
	}
	
}
function printList()
{
	abrir_ventana('../compras/print_list_ordencompra_general.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function buscaPR()
{
	 abrir_ventana1("../common/search_proveedor.jsp?fp=ajuste");
}

function setMonto(j)
{
var cantidad	= eval('document.form2.monto'+j).value;
var year	= eval('document.form2.anio'+j).value;
var docNo	= eval('document.form2.numero_documento'+j).value;
var numck	= eval('document.form2.cheque'+j).value;
var anula = 0;

if(eval('document.form2.marcado'+j).checked)
{
	if(executeDB('<%=request.getContextPath()%>','update tbl_inv_recepcion_material set  monto_pagado = \''+cantidad+'\' , ref_cheque =\''+numck+'\',fecha_mod = sysdate  where compania = <%=session.getAttribute("_companyId")%> and anio_recepcion = '+year+'  and numero_documento = '+docNo))
	{
	eval('document.form2.monto_pagado'+j).value = cantidad;
	eval('document.form2.marcado'+j).value = 'S';
	} else eval('document.form2.monto_pagado'+j).value = 0.00;
				
	} else 
	{
	if(executeDB('<%=request.getContextPath()%>','update tbl_inv_recepcion_material set  monto_pagado = \''+anula+'\' , ref_cheque =\''+numck+'\',fecha_mod = sysdate  where compania = <%=session.getAttribute("_companyId")%> and anio_recepcion = '+year+'  and numero_documento = '+docNo))
	{
		eval('document.form2.marcado'+j).value = '';
		eval('document.form2.monto_pagado'+j).value = 0.00;
	} else eval('document.form2.monto_pagado'+j).value = 0.00;
	}
}



function verifyCheck()
{
var saldo = eval('document.form1.check').value;
var fact = eval('document.form1.factura').value;
	//	if (eval('document.form1.factura').checked)
			if (saldo=="S")
				{
						document.form1.check.viewMode = true;
						document.form1.factura.checked = false;
				}
	else if (fact=="S")
			{
						document.form1.factura.checked = true;
						document.form1.check.checked = false;
				}
}



</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CUENTAS POR PAGAR - SALDO DE FACTURAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
 
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

	<table width="100%" cellpadding="0" cellspacing="1">
  
  <tr class="TextFilter">
    <%fb = new FormBean("form1",request.getContextPath()+"/common/urlRedirect.jsp");%> 
      <%=fb.formStart()%>
      <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
      <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		
        <td width="50%"> <cellbytelabel>Fecha B&uacute;squeda</cellbytelabel> : 
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha_ini" />
						<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
						<jsp:param name="nameOfTBox2" value="fecha_fin" />
						<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
						</jsp:include>
				</td>	
				<td width="50%">
				<cellbytelabel>Estado</cellbytelabel> 	<%=fb.select("estado","R=RECIBIDA,A=ANULADA",estado, false, false, 0, "T")%> 
			 </td>
		 </tr>
		
		<tr class="TextFilter"> 		
		 <td colspan="2">	<cellbytelabel>C&oacute;digo de Proveedor</cellbytelabel> :  
		 	<%=fb.textBox("cod_proveedor",cod_proveedor,false,false,false,5,null,null,null)%>
		 	<%=fb.textBox("nombre_proveedor",nombre_proveedor,false,false,false,40,null,null,null)%>
			<%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaPR()\"")%> 
		 	&nbsp;&nbsp; <cellbytelabel>Busqueda</cellbytelabel> :
			&nbsp;&nbsp;
			<%=fb.select("check","T=SALDO DE FACTURAS, F=FACTURAS POR PROVEEDOR",check,"S")%>
			&nbsp;<%=fb.submit("go","Ir")%> 
		 </td>
		</tr>
			<%=fb.formEnd()%>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;
					
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
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("desc_prov",desc_prov)%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("check",check)%>
				<%=fb.hidden("num_doc",num_doc)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("desc_prov",desc_prov)%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("check",check)%>
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
		<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<tbody id="list">
		
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>N&uacute;mero</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Registro</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Fecha</cellbytelabel> </td>
			<td width="15%"><cellbytelabel>N&uacute;mero Factura</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Monto Total</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Monto Pagado</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="10%"><cellbytelabel>No. Cheque</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Pagar</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
		</tr>
<%
String descripcion = "";
String almacen = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	 if (!descripcion.equalsIgnoreCase(cdo.getColValue("proveedor")))
	 {%>
		<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
        <td colspan="10" class="TitulosdeTablas"> [<%=cdo.getColValue("cod_proveedor")%>] - <%=cdo.getColValue("proveedor")%></td>
                   </tr>
	<%}%>
						<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
						<%=fb.hidden("numero_documento"+i,cdo.getColValue("numero_documento"))%>
						<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
						<%=fb.hidden("cheque"+i,cdo.getColValue("ref_cheque"))%>
						<%=fb.hidden("proveedor"+i,cdo.getColValue("proveedor"))%>
						<%=fb.hidden("factura"+i,cdo.getColValue("numero_fatura"))%>
		
		
	<tr  id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("numero_documento")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td> <%=cdo.getColValue("numero_factura")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
			<td align="right"> <%=fb.decBox("monto_pagado"+i, CmnMgr.getFormattedDecimal(cdo.getColValue("monto_pagado")),false,false,false,10)%> </td>
			<td align="center"><%=cdo.getColValue("estadoDes")%></td>
			<%
			if (check.equalsIgnoreCase("F"))
		
			{
			%>
			<td align="center"><%=fb.textBox("ref_cheque"+i,cdo.getColValue("ref_cheque"),false,false,false,10,10)%></td>
			<%
			} else {
			%>
			<td>&nbsp; </td>
			<% } %>
			<td align="center">&nbsp;
			<%
			if (cdo.getColValue("estado").equalsIgnoreCase("R"))
		//	String valor = cdo.getColValue("marcado"); 
			{
			%>
				<%=fb.checkbox("marcado"+i, cdo.getColValue("marcado"), (cdo.getColValue("marcado").equals("S")?true:false), false, "Text10", "", "onClick=\"javascript:setMonto("+i+")\"")%>
			<%
			}
			%>
			</td>
			<td align="center">
				<%
			if (cdo.getColValue("estado").equalsIgnoreCase("R"))
		//	String valor = cdo.getColValue("marcado"); 
			{
			%>
			
			<img src="../images/dwn.gif" onClick="javascript:diFrame('list','8','rs<%=i%>','750','200','0','0','1','DIVExpandRowsScroll',true,'0','../cxp/cxp_detalle_factura.jsp?anio=<%=cdo.getColValue("anio")%>&num=<%=cdo.getColValue("numero_documento")%>&prov=<%=cdo.getColValue("proveedor")%>&id=<%=i%>',false)" style="cursor:pointer">
			
			<%
			}
			%>
			</td>
		</tr>
<%descripcion = cdo.getColValue("proveedor");
}%>
<%=fb.formEnd(true)%>
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
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
