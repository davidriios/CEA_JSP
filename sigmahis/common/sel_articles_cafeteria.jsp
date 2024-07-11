<%@ page errorPage="../error.jsp"%>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
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
StringBuffer sbFilter = new StringBuffer();

String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String almacen = request.getParameter("almacen");
if(almacen==null) almacen = "2";
if(fp==null) fp = "";

if (request.getMethod().equalsIgnoreCase("GET")){
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
	
  String familia = "", clase = "", articulo = "", descripcion = "", consignacion = "";
	if (request.getParameter("art_familia") != null) familia = request.getParameter("art_familia");
	if (request.getParameter("art_clase") != null) clase = request.getParameter("art_clase");
	if (request.getParameter("cod_articulo") != null) articulo = request.getParameter("cod_articulo");
	if (request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if (request.getParameter("consignacion") != null) consignacion = request.getParameter("consignacion");
	
	
	if (!familia.equals("")){
		sbFilter.append(" and upper(b.nombre) like '%");
		sbFilter.append(familia);
		sbFilter.append("%'");
	}
	if (!clase.equals("")){
		sbFilter.append(" and upper(c.descripcion) like '%");
		sbFilter.append(clase);
		sbFilter.append("%'");
	}
	if (!articulo.equals("")){
		sbFilter.append(" and upper(a.cod_articulo) = ");
		sbFilter.append(articulo);
	}
	if (!descripcion.equals("")){
		sbFilter.append(" and upper(d.descripcion) like '%");
		sbFilter.append(descripcion);
		sbFilter.append("%'");
	}
	
	sbSql.append("select distinct a.* from (select d.cod_flia||'-'||d.cod_clase||'-'||d.cod_articulo art_key, a.compania, a.art_familia cod_flia, a.art_clase cod_clase, a.cod_articulo cod_articulo, d.descripcion art_desc, d.itbm, d.cod_medida, d.precio_venta, d.tipo, d.tipo_material, b.nombre familia_desc, c.descripcion clase_desc, a.precio, a.disponible, d.consignacion_sino, d.other3 afecta_inventario, a.codigo_almacen almacen from tbl_inv_inventario a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c, tbl_inv_articulo d where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.codigo_almacen = ");
	sbSql.append(almacen);
	sbSql.append(" and a.compania = b.compania and d.estado = 'A' and d.venta_sino = 'S' and a.compania = c.compania and a.compania = d.compania and a.art_familia = b.cod_flia and a.art_familia = c.cod_flia and a.art_clase = c.cod_clase and a.art_familia = b.cod_flia and a.art_clase = c.cod_clase and a.art_familia = d.cod_flia and a.art_clase = d.cod_clase and a.cod_articulo = d.cod_articulo ");
	sbSql.append(sbFilter.toString());
	sbSql.append(") a order by a.cod_flia, a.cod_clase, a.cod_articulo, a.art_Desc");
	
	StringBuffer sbAll = new StringBuffer();
	sbAll.append("select * from (select rownum as rn, a.* from (");
	sbAll.append(sbSql.toString());
	sbAll.append(") a) where rn between ");
	sbAll.append(previousVal);
	sbAll.append(" and ");
	sbAll.append(nextVal);
	al = SQLMgr.getDataList(sbAll.toString());
	
	sbAll = new StringBuffer();
	
	sbAll.append("select count(*) count FROM (");
	sbAll.append(sbSql.toString());
	sbAll.append(")");
	rowCount = CmnMgr.getCount(sbAll.toString());

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
</script>
<script language="javascript">

</script>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%if(!fp.equals("fact_cafeteria")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">		
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",""+fg)%>
				<%=fb.hidden("fp",fp)%>
				<td width="15%">Almac&eacute;n:
					<%
					sbSql= new StringBuffer();
					if(!UserDet.getUserProfile().contains("0"))
					{
						sbSql.append(" and codigo_almacen in (");
							if(session.getAttribute("_almacen_ua")!=null)
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua")));
							else sbSql.append("-2");
						sbSql.append(")");
					}
					%>
					<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","almacen",almacen,false,false,0, "text10", "", "")%>
					<%if(!fp.equals("fact_cafeteria")){%>
					Familia
					<%=fb.textBox("art_familia",familia,false,false,false,15)%>
					Clase
					<%=fb.textBox("art_clase",clase,false,false,false,15)%>
					<%}%>
					Art&iacute;culo
					<%=fb.intBox("cod_articulo",articulo,false,false,false,15)%>
					Descripci&oacute;n
					<%=fb.textBox("descripcion",descripcion,false,false,false,20)%>					
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd(true)%>
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("art_familia",familia)%>
				<%=fb.hidden("art_clase",clase)%>
				<%=fb.hidden("cod_articulo",articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("art_familia",familia)%>
				<%=fb.hidden("art_clase",clase)%>
				<%=fb.hidden("cod_articulo",articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<%
//onSubmit=\"javascript:return (chkQty())\"
fb = new FormBean("articles","","post","onSubmit=\"javascript:return (chkQty())\"");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("art_familia",familia)%>
				<%=fb.hidden("art_clase",clase)%>
				<%=fb.hidden("cod_articulo",articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
	<td align="left" class="TableLeftBorder">&nbsp;</td>
	<td align="right" class="TableRightBorder"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader">
				<td width="20%" align="center" colspan="3">C&oacute;digo</td>
				<td width="57%" align="center" rowspan="2">Descripci&oacute;n</td>
				<td width="10%" align="center" rowspan="2">Und.</td>
				<td width="3%" align="center" rowspan="2">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td width="6%" align="center">Familia</td>
				<td width="6%" align="center">Clase</td>
				<td width="8%" align="center">Art&iacute;culo</td>
			</tr>
<%
for (int i=0; i<al.size(); i++){
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
	<%=fb.hidden("cod_clase"+i,cdo.getColValue("cod_clase"))%>
	<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
	<%=fb.hidden("art_desc"+i,cdo.getColValue("art_desc"))%>
	<%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%>
	<%=fb.hidden("unidad"+i,cdo.getColValue("cod_medida"))%>
	<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
	<%=fb.hidden("disponible"+i,cdo.getColValue("disponible"))%>
	<%=fb.hidden("consignacion"+i,cdo.getColValue("consignacion_sino"))%>
	<%=fb.hidden("afecta_inventario"+i,cdo.getColValue("afecta_inventario"))%>
	<%=fb.hidden("almacen"+i,cdo.getColValue("almacen"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("cod_flia")%></td>
			<td><%=cdo.getColValue("cod_clase")%></td>
			<td><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("art_desc")%></td>
			<td align="center"><%=cdo.getColValue("cod_medida")%></td>
			<td align="center"><%=(vDet.contains(cdo.getColValue("cod_articulo")))?"Elegido":fb.checkbox("chk"+i,"",false,false,null,null,"")%></td>
		</tr>
	<%
}

if(al.size()==0){
%>
		<tr><td align="center" colspan="7">No registros encontrados.</td></tr>
<%}%>		
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("art_familia",familia)%>
				<%=fb.hidden("art_clase",clase)%>
				<%=fb.hidden("cod_articulo",articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("consignacion",consignacion)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("art_familia",familia)%>
				<%=fb.hidden("art_clase",clase)%>
				<%=fb.hidden("cod_articulo",articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("consignacion",consignacion)%>
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
else
{
	System.out.println("=====================POST=====================");
	int lineNo = htDet.size();
	String artDel = "", key = "";;	
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for(int i=0;i<keySize;i++){

		CommonDataObject det = new CommonDataObject();
		det.addColValue("id_familia", request.getParameter("cod_flia"+i));
		det.addColValue("id_articulo", request.getParameter("cod_articulo"+i));
		det.addColValue("descripcion", request.getParameter("art_desc"+i));
		det.addColValue("afecta_inventario", request.getParameter("afecta_inventario"+i));
		det.addColValue("almacen", request.getParameter("almacen"+i));
		det.addColValue("id", "0");
		det.addColValue("cantidad", "0");

		if(request.getParameter("chk"+i)!=null && request.getParameter("del"+i)==null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
	
			try {
				htDet.put(key, det);
				vDet.addElement(det.getColValue("id_articulo"));
				System.out.println("addget item "+key);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		} else if(request.getParameter("del"+i)!=null){
			artDel = "1";
		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_articles_cafeteria.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&fp="+fp+"&almacen="+almacen);
		return;
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.opener.document.location = '../pos/reg_caf_menu_det.jsp?change=1';
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
