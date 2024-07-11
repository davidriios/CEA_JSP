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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sql = new StringBuffer();
String appendFilter = "";

String cCompany = (String)session.getAttribute("_companyId");
String archivoId = request.getParameter("archivoId")==null?"-1":request.getParameter("archivoId");

if(request.getMethod().equalsIgnoreCase("GET"))
{
	sql.append("select 'PDT' tipo, t.codigo_barra, t.qty, t.anaquel, t.error, t.pase , t.anaquel as anaquel_desc, c.almacen, (select descripcion from tbl_inv_articulo a where a.compania = c.company_id and a.cod_barra = t.codigo_barra and rownum = 1) desc_articulo from tbl_inv_pdt_archivo_tmp t, tbl_inv_pdt_archivo c where t.archivo_id = ");
	sql.append(archivoId);
	sql.append(" and t.archivo_id = c.id and t.company_id = c.company_id and c.company_id = ");
	sql.append(cCompany);
	sql.append("union all select 'xanaquel' tipo, a.cod_barra, i.disponible, aa.descripcion, '' error, 'N' pase, aa.descripcion anaquel_desc, i.codigo_almacen, a.descripcion desc_articulo from tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_anaqueles_x_almacen aa, tbl_inv_pdt_archivo pa where i.compania = a.compania and i.disponible <> 0 and i.cod_articulo = a.cod_articulo and aa.compania = i.compania and aa.codigo_almacen = i.codigo_almacen and aa.codigo = i.codigo_anaquel and pa.company_id = i.compania and pa.almacen = i.codigo_almacen and pa.anaquel = aa.cod_anaquel and pa.id = ");
	sql.append(archivoId);
	sql.append(" and pa.company_id = ");
	sql.append(cCompany);
	sql.append(" and not exists (select null from tbl_inv_pdt_archivo_tmp tmp where pa.id = tmp.archivo_id and tmp.codigo_barra = a.cod_barra and tmp.company_id = pa.company_id ) order by 1");
	
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function add(){abrir_ventana('../inventario/cargar_archivo_pdt_config.jsp');}
function edit(id){abrir_ventana('../inventario/cargar_archivo_pdt_config.jsp?mode=edit&archivoId='+id);}
function printList(){abrir_ventana('../inventario/print_cargar_archivo_pdt_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">	
<tr>
  <td class="TableLeftBorder TableRightBorder" colspan="">
    <div id="_cMain" class="Container">
	  <div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader">
				<td width="15%">&nbsp;C&oacute;digo Barra</td>
				<td width="20%">&nbsp;Descripci&oacute;n</td>
				<td width="5%" align="center">&nbsp;Cantidad</td>
				<td width="25%">&nbsp;Anaquel</td>
				<td width="30%">&nbsp;Error</td>
				<td width="5%" align="center">&nbsp;Pase?</td>
			</tr>
				<%
				boolean mostrar = true;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 
				%>
				<%if(cdo.getColValue("tipo").equalsIgnoreCase("xanaquel") && mostrar){%>
				<tr class="TextPanel01"><td colspan="6">Articulos no registrados en el archivo, pero que existen en el anaquel</td></tr>
				<%
				mostrar = false;
				}%>
				<tr class="<%=color%> <%=(cdo.getColValue("pase").equalsIgnoreCase("N")?"RedText":"")%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("codigo_barra")%></td>
					<td>&nbsp;<%=cdo.getColValue("desc_articulo")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("qty")%></td>
					<td>&nbsp;[<%=cdo.getColValue("anaquel")%>]<%=cdo.getColValue("anaquel_desc")%></td>
					<td>&nbsp;<%=cdo.getColValue("error")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("pase")%></td>
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
	
</table>
</body>
</html>
<%
}
%>
