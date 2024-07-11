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
if (
!( SecMgr.checkAccess(session.getId(),"0") 
	|| ((SecMgr.checkAccess(session.getId(),"200069") || SecMgr.checkAccess(session.getId(),"200070") || SecMgr.checkAccess(session.getId(),"200071") || SecMgr.checkAccess(session.getId(),"200072"))) )
	) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String listado = "";
String fecha = "";
if(estado==null){
	estado = "";
	//appendFilter += " and a.status = ''";
} else if(!estado.equals("")){
	appendFilter += " and a.status = '"+estado+"'";
}

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null)
{
  if (alWh.size() > 0)
	{ 
		wh = ((CommonDataObject) alWh.get(0)).getOptValueColumn();
		appendFilter += " and a.cod_almacen="+wh;
	}
  else wh = "";
}
else if (!wh.trim().equals(""))
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
	if (request.getParameter("num_doc") != null)
	{
		vDoc = request.getParameter("num_doc");
		appendFilter += " and upper(a.num_doc) like '%"+request.getParameter("num_doc").toUpperCase()+"%'";

    searchOn = "a.num_doc";
    searchVal = request.getParameter("num_doc");
    searchType = "2";
    searchDisp = "No. Solicitud";
	}
	if (request.getParameter("fecha") != null)
	{
	vFecha = request.getParameter("fecha");
	appendFilter += " and upper(a.fecha_entrega_vencimiento) like '%"+request.getParameter("fecha").toUpperCase()+"%'";

    searchOn = "a.fecha_entrega_vencimiento";
    searchVal = request.getParameter("fecha");
    searchType = "2";
    searchDisp = "Fecha Vencimiento";
	}
	if (request.getParameter("tipo") != null)
	{
	vTipo = request.getParameter("tipo");
	appendFilter += " and upper(a.tipo_compromiso) like '%"+request.getParameter("tipo").toUpperCase()+"%'";

    searchOn = "a.tipo_compromiso";
    searchVal = request.getParameter("tipo");
    searchType = "2";
    searchDisp = "Tipo Compromiso";
	}
		if (request.getParameter("listado") != null)
	{
	listado = request.getParameter("listado");
	}
	String fields = "";       // variable para mantener el valor de los campos filtrados en la consulta
		
	// Puedes buscar por año, solicitud, fecha, código o nombre del proveedor, código o nombre de almacen
	if (request.getParameter("fields") != null)
	{
		appendFilter += " and upper(a.anio||' '||a.num_doc||' '||to_char(a.fecha_documento,'dd/mm/yyyy')||' '||a.cod_proveedor||' '||b.nombre_proveedor||' '||a.cod_almacen||' '||c.descripcion) like '%"+request.getParameter("fields").toUpperCase()+"%'";
    searchOn = "";
    searchVal = request.getParameter("fields");
    searchType = "1";
    searchDisp = "Busqueda Combinada"; 
		fields     = request.getParameter("fields");  // variable para mantener el valor de los campos filtrados en la consulta
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
			appendFilter += " and upper(a.anio||' '||a.num_doc||' '||to_char(a.fecha_documento,'dd/mm/yyyy')||' '||a.cod_proveedor||' '||b.nombre_proveedor||' '||a.cod_almacen||' '||c.descripcion) like '%"+searchVal.toUpperCase()+"%'";
    }
	if (request.getParameter("num_doc") != null & request.getParameter("fecha") != null & request.getParameter("tipo") != null)
	{
	 if (searchType.equals("2"))
   {
     appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
	
	}
	
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, d.descripcion, to_char(a.monto_total,'999,999,999,990.00') as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(a.monto_pagado,'0.00') as monto_pago, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,999,990.00') as saldo, a.cod_proveedor"
+ " FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d"
+ " where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen=c.codigo_almacen and a.status='A' and a.tipo_compromiso <> 2 and"
+ " a.compania = c.compania  and a.tipo_compromiso = d.tipo_com and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by a.cod_proveedor, a.anio, a.fecha_documento, a.num_doc";	 		 
al = SQLMgr.getDataList(sql); 

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

function add()
{
	abrir_ventana('../compras/reg_orden_compra_normal.jsp');
}

function edit(anio, id, tp)
{

for (var i=0; i < document.searchMain.listado.length; i++)
   {
   if (document.searchMain.listado[i].checked)
      {
      var rad_val = document.searchMain.listado[i].value;
      }
   }

if (rad_val=='P')
	{
	abrir_ventana('../compras/orden_compra_recepcion_prov.jsp?mode=view&id='+id+'&anio='+anio);
		
}
if (rad_val=='A')
{
	abrir_ventana('../compras/reg_orden_compra_normal.jsp?mode=edit&id='+id+'&anio='+anio);

}	
}
	

function printList(id,anio)
{
for (var i=0; i < document.searchMain.listado.length; i++)
   {
   if (document.searchMain.listado[i].checked)
      {
      var rad_val = document.searchMain.listado[i].value;
      }
   }

if (rad_val=='P')
	{
	abrir_ventana('../compras/print_list_ordencompra_prov.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

if (rad_val=='A')
	{
	abrir_ventana('../compras/print_list_ordencompra_art.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
}
function getMain(formX)
{ 
	formX.wh.value = document.searchMain.wh.value;
    formX.listado.value = document.searchMain.listado.value;
	return true;
}

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
      <%=fb.formStart()%>
      <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
      <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			
    <td> 
      <cellbytelabel>Almac&eacute;n</cellbytelabel>
      <%=fb.select("wh",alWh,wh, false, false, 0,"T")%>
      <%=fb.submit("go","Ir")%>
              <cellbytelabel>Opciones del Listado</cellbytelabel>: 
                          <%=fb.radio("listado","P",true,false,false)%><cellbytelabel>Por Proveedores</cellbytelabel> 
                          <%=fb.radio("listado","A",false,false,false)%><cellbytelabel>Por Art&iacute;culos</cellbytelabel> 
						
    </td>
		
    <%=fb.formEnd()%> 
  </tr>
        
				<tr class="TextFilter">
          <%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>	
					
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
									
          <td> 
						<cellbytelabel>B&uacute;squeda Combinada</cellbytelabel>
						<%=fb.textBox("fields",fields,false,false,false,50)%> 
						<%=fb.submit("go","Ir")%> </td>
						
          <%=fb.formEnd()%>
				</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200070"))
{
%>
			<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
<%
}
%>
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
				<%=fb.hidden("fecha",fecha)%>
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
				<%=fb.hidden("fecha",fecha)%>
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
			<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
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
     
	    <td colspan="9" class="TitulosdeTablas"> <%=cdo.getColValue("nombre_proveedor")%></td>
        
		           </tr>
				<%
				descripcion = "";
				   }
				 
	 if (!descripcion.equalsIgnoreCase(cdo.getColValue("descripcion")))
				 {
%>
		<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
        <td colspan="9" class="TitulosdeTablas"> [<%=cdo.getColValue("tipo_compromiso")%>] - <%=cdo.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				  %>
		
		<tr  id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("num_doc")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"> <%=cdo.getColValue("numero_factura")%></td>
			<td align="center"><%=cdo.getColValue("fechaVence")%></td>
			<td align="center"><%=cdo.getColValue("desc_status")%></td>
			<td align="right"><%=cdo.getColValue("monto_total")%></td>
			<td align="center">	<%
		if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200072"))
		
			{
			%>
					
			<a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>,<%=cdo.getColValue("tipo_compromiso")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link02Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a>
			
			<%}%></td>
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
				<%=fb.hidden("fecha",fecha)%>
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
				<%=fb.hidden("fecha",fecha)%>
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