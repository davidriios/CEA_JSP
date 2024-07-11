
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();

String estado = request.getParameter("estado");
String tipo = request.getParameter("tipo");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String almacen = request.getParameter("almacen");
String articulo = request.getParameter("articulo");

if(tipo==null)tipo="";
if(fecha_desde==null)fecha_desde="";
if(fecha_hasta==null)fecha_hasta="";
if(almacen==null)almacen=""; 
if(articulo==null)articulo="";

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

	sbSql.append("select vl.tipo, vl.tipo_desc, vl.anio_docto, vl.no_docto, vl.compania, to_char(vl.fecha_docto, 'dd/mm/yyyy') fecha_docto, to_char(vl.fecha_sistema, 'dd/mm/yyyy hh12:mi am') fecha_sistema, vl.fecha_sistema system_date, vl.codigo_almacen, vl.tipo_mov, vl.tipo_docto, vl.cod_extra, vl.pac_id, vl.admision, (select descripcion from tbl_inv_almacen a where a.compania = vl.compania and a.codigo_almacen = vl.codigo_almacen) almacen_desc from vw_inv_trx_lote vl where not exists (select null from tbl_inv_art_lote al where al.ref_type = vl.tipo and al.ref_code = vl.anio_docto||'|'||vl.no_docto) and vl.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	if(!tipo.equals("")){
		sbSql.append(" and vl.tipo = '");
		sbSql.append(tipo);
		sbSql.append("'");		
	}
	if(!fecha_desde.equals("")){
		sbSql.append(" and vl.fecha_docto >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");		
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and vl.fecha_docto <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");		
	}	
	if(!almacen.equals("")){
		sbSql.append(" and vl.codigo_almacen = ");
		sbSql.append(almacen);		
	}
	
	if(!articulo.equals("")){
		sbSql.append(" and exists ( select null from vw_inv_trx_lote_item a where a.compania = vl.compania and a.anio_docto = vl.anio_docto and a.no_docto =vl.no_docto and a.tipo = vl.tipo and a.cod_articulo = ");
  sbSql.append(articulo);	 
  sbSql.append(" )  "); 	
	} 
	
	sbSql.append(" order by system_date desc /*vl.tipo, vl.anio_docto desc, vl.no_docto desc*/");
	if(!fecha_desde.equals("") && !fecha_hasta.equals("")){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");
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
function add(tipo, anio, no){abrir_ventana3('../inventario/reg_lote_fecha_vencimiento.jsp?fp=list_lote_fv&ref_type='+tipo+'&ref_code='+anio+encodeURIComponent('|')+no+'&articulo=<%=articulo%>');}
function printList(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - RECEPCION MAT. Y EQUIPOS SIN ORDEN DE COMPRA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
          <%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.fields))\"");%>
          <%=fb.formStart()%> 
		  <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
		  <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
          <td> 
						Tipo Docto.:
						<%=fb.select("tipo","delivery=ENTREGA, recepc=RECEPCION, AJU=AJUSTE, DEV=DEVOLUCION, DEVPR=DEVOLUCION PROVEEDOR, CARGO=CARGO, FACP=FACTURA POS, NCP=NOTA CREDITO POS",tipo, false, false, 0, "T")%> 
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha_desde" />
					<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
					<jsp:param name="nameOfTBox2" value="fecha_hasta" />
					<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
					</jsp:include>
					Almac&eacute;n:
					<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+(UserDet.getUserProfile().contains("0")?"":" and codigo_almacen in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua"))+")")+" order by descripcion","almacen",almacen,false,false,0, "text10", "", "", "", "T")%>
					Articulo: <%=fb.textBox("articulo",articulo,false,false,false,15,null,null,null)%>
						<%=fb.submit("go","Ir")%> 
					</td>
          <%=fb.formEnd()%>
				</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right"> 
			<!-- <authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>--> 
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("articulo",articulo)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("articulo",articulo)%>
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
		<tr class="TextHeader" align="center">
			<td width="20%">Tipo Docto.</td>
			<td width="10%">A&ntilde;o</td>
			<td width="10%">No.</td>
			<td width="10%">Fecha Trx.</td>
			<td width="20%">Almac&eacute;n</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("tipo_desc")%></td>
			<td align="center"><%=cdo.getColValue("anio_docto")%></td>
			<td align="center"><%=cdo.getColValue("no_docto")%></td>
			<td align="center"><%=cdo.getColValue("fecha_sistema")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("codigo_almacen")+" "+cdo.getColValue("almacen_desc")%></td>
			<td align="center">
			<authtype type='2'><a href="javascript:add('<%=cdo.getColValue("tipo")%>', <%=cdo.getColValue("anio_docto")%>, <%=cdo.getColValue("no_docto")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Agregar</a></authtype>
			</td>
		</tr>
<%
}
%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("articulo",articulo)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("articulo",articulo)%>
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
