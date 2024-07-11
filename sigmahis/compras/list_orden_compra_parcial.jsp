
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
String sql = "";
String appendFilter = "";

String estado = request.getParameter("estado");
if(estado==null){
	estado = "T";
	appendFilter += " and a.status = 'T'";
} else if(!estado.equals("")){
	appendFilter += " and a.status = '"+estado+"'";
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

	String nDoc="",anio="",tDate="",fDate="",nombre_proveedor="",almacen="";
	if (request.getParameter("nDoc") != null && !request.getParameter("nDoc").trim().equals(""))
	{
		appendFilter += " and upper(a.num_doc) like '%"+request.getParameter("nDoc").toUpperCase()+"%'";
		nDoc = request.getParameter("nDoc");
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and upper(anio) like '%"+request.getParameter("anio").toUpperCase()+"%'";
	    anio = request.getParameter("anio");
	}
	if (request.getParameter("fDate") != null && !request.getParameter("fDate").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_documento) >=to_date('"+request.getParameter("fDate")+"','dd/mm/yyyy')";
	    fDate = request.getParameter("fDate");
	}
	if (request.getParameter("tDate") != null && !request.getParameter("tDate").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_documento) <=to_date('"+request.getParameter("tDate")+"','dd/mm/yyyy')";
	    tDate = request.getParameter("tDate");
	}
	if (request.getParameter("nombre_proveedor") != null && !request.getParameter("nombre_proveedor").trim().equals(""))
	{
		appendFilter += " and upper(b.nombre_proveedor) like '%"+request.getParameter("nombre_proveedor").toUpperCase()+"%'";
	    nombre_proveedor = request.getParameter("nombre_proveedor");
	}
	if (request.getParameter("almacen") != null && !request.getParameter("almacen").trim().equals(""))
	{
		appendFilter += " and a.cod_almacen ="+request.getParameter("almacen");
	    almacen = request.getParameter("almacen");
	}
	
	if (request.getParameter("almacen")!=null){
	sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','C','APROB. CONT.','F','APROB. FIN.','Z','CERRADO') desc_status, to_char(a.monto_total,'99,999,999,990.00') monto_total, nvl(a.cod_proveedor, 0) || ' ' || nvl(b.nombre_proveedor, ' ') nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc,a.usuario FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b, tbl_inv_almacen c where a.cod_proveedor = b.cod_provedor(+) and a.compania=b.compania(+) and a.cod_almacen = c.codigo_almacen and a.compania = c.compania and a.tipo_compromiso = 3 and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by a.anio desc , a.fecha_documento desc,a.num_doc desc ";

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
document.title = 'Inventario - '+document.title;
function add(){abrir_ventana('../compras/reg_orden_compra_parcial.jsp');}
function edit(anio, id, tp){abrir_ventana('../compras/reg_orden_compra_parcial.jsp?mode=edit&id='+id+'&anio='+anio+'&status='+tp);}
function ver(anio, id, tp){abrir_ventana('../compras/reg_orden_compra_parcial.jsp?mode=view&id='+id+'&anio='+anio+'&status='+tp);}
function printList(){abrir_ventana('../compras/print_list_ordencompra_parcial.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRA - ORDEN DE COMPRA PARCIAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nueva Orden de Compra</cellbytelabel> ]</a></authtype>
	</td>
  </tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
	<table width="100%" cellpadding="0" cellspacing="0">
          <%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.fields))\"");%>
          <%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
          <tr class="TextFilter">
		  	<td width="10%">
						<cellbytelabel>Año</cellbytelabel></td>
			<td width="90%">
						<%=fb.intBox("anio",anio,false,false,false,4)%>
						<cellbytelabel>No. Orden</cellbytelabel>
						<%=fb.intBox("nDoc",nDoc,false,false,false,5)%>
						
						<cellbytelabel>Fecha Doc.</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fDate" />
						<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
						<jsp:param name="nameOfTBox2" value="tDate" />
						<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
						</jsp:include>
				<cellbytelabel>Nombre Proveedor</cellbytelabel>
						<%=fb.textBox("nombre_proveedor",nombre_proveedor,false,false,false,30)%>
						</td>
				</tr>
				<tr class="TextFilter">
						<td><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
						<td><%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by 1","almacen",almacen,"T")%>
						<cellbytelabel>Estado</cellbytelabel>
						<%=fb.select("estado","A=Aprobado,N=Anulado,P=Pendiente,R=Procesado,T=Tramite,C=Aprob. cont.,F=Aprob. fin.,Z=Cerrado",estado, false, false, 0, "T")%>
						<%=fb.submit("go","Ir")%>
					</td>
				</tr>
          <%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>&nbsp;</td>
  </tr>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("nDoc",nDoc)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("nDoc",nDoc)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
  </tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="6%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="8%"><cellbytelabel>No. Solicitud</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Fecha Doc</cellbytelabel>.</td>
			<td width="24%"><cellbytelabel>Proveedor</cellbytelabel></td>
			<td width="18%"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Usuario</cellbytelabel> </td>
			<td width="7%"><cellbytelabel>Total</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="4%">&nbsp;</td>
			<td width="6%">&nbsp;</td>
		</tr>
<%
String displayLink = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (cdo.getColValue("status").trim().equalsIgnoreCase("T")) displayLink = "Editar";
	else displayLink = "Ver";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("num_doc")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="left"><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"><%=cdo.getColValue("usuario")%></td>
			<td align="right"><%=cdo.getColValue("monto_total")%></td>
			<td align="center"><%=cdo.getColValue("desc_status")%></td>
			<td align="center">
			<authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>,'<%=cdo.getColValue("status")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
			</td>
			<td align="center">
		
			<%if(cdo.getColValue("status").trim().equalsIgnoreCase("T")){%>
			<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_doc")%>,'<%=cdo.getColValue("status")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
			<%}%>
			</td>
		</tr>
<%
}
%>
		</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("nDoc",nDoc)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("nDoc",nDoc)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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
