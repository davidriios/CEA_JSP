<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String itemCode = (request.getParameter("itemCode")==null?"":request.getParameter("itemCode"));
String companyCode = (String) session.getAttribute("_companyId");

String itemDesc = (request.getParameter("itemDesc")==null?"":request.getParameter("itemDesc"));
 
if ( itemCode.trim().equals("") ) throw new Exception("Lo sentimos, pero necesitamos el código del artículo!");

sbSql.append("select to_char(p.fecha_creacion,'dd/mm/yyyy') as fc, p.action, decode(p.action,1,'INCREMENTO','DECREMENTO') as action_desc, p.usuario_creacion, decode(p.action,1,'+','-')||p.porcentaje as porcentaje, p.precio as precio_actual, /*((p.precio * 100) / (100 + decode(p.action,1,p.porcentaje,-p.porcentaje)))*/nvl(p.precio_ant,0) as precio_anterior from tbl_fac_pricexlote p where p.codigo = ");
sbSql.append(itemCode);
sbSql.append(" and p.compania = ");
sbSql.append(companyCode); 
sbSql.append(" order by p.fecha_creacion desc");
al = SQLMgr.getDataList(sbSql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Admin - Cambiar Precios - '+document.title;

function printPriceHistory(){
	abrir_ventana('../admin/print_price_history.jsp?itemCode=<%=itemCode%>&familyCode=<%=familyCode%>&companyCode=<%=companyCode%>&itemDesc=<%=itemDesc%>&itemFamilyDesc=<%=itemFamilyDesc%>&itemFamilyDesc=<%=itemFamilyDesc%>&itemClaseDesc=<%=itemClaseDesc%>');
}
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<tr>
	<td class="TableLeftBorder TableRightBorder TableBottomBorder TableTopBorder">
		<%fb = new FormBean("formDetail",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart()%>

		<td>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
					<tr class="TextHeader01">
						<td colspan="6">[<%=itemFamilyDesc%>]&nbsp;<%=itemClaseDesc%></td>
					</tr>
				 <tr class="TextHeader01">
						<td colspan="5"><cellbytelabel>Art&iacute;culo</cellbytelabel>:&nbsp;[<%=itemCode%>]&nbsp;<%=itemDesc%></td>
					<td align="center"><%=fb.button("btnPrint","Imprimir",true,false,null,"","onClick=\"javascript:printPriceHistory()\"")%></td>
					</tr>
				<tr class="TextHeader">
					<td width="10%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Acci&oacute;n</cellbytelabel></td>
					<td width="20%" align="center"><cellbytelabel>Porcentaje</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Usuario</cellbytelabel></td>
					<td width="15%" align="right"><cellbytelabel>Precio Ant.</cellbytelabel></td>
					<td width="15%" align="right"><cellbytelabel>Precio Act.</cellbytelabel></td>
				</tr>
				<%
					CommonDataObject cdo = new CommonDataObject();
					for (int i = 0; i<al.size(); i++){

						cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
					<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
						<td align="center"><%=cdo.getColValue("fc")%></td>
						<td align="center"><%=cdo.getColValue("action_desc")%></td>
						 <td align="center"><%=cdo.getColValue("porcentaje")%></td>
						<td><%=cdo.getColValue("usuario_creacion")%></td>
						<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio_anterior"))%></td>
						<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio_actual"))%></td>
					</tr>
				<%
					}//for i
				%>

			</table>
		</td>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>