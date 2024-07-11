<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iWH" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vWH" scope="session" class="java.util.Vector" />
<jsp:useBean id="iUAWH" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vUAWH" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCDSWH" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCDSWH" scope="session" class="java.util.Vector" />
<jsp:useBean id="iWhInv" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vWhInv" scope="session" class="java.util.Vector" />
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fg = request.getParameter("fg");

int cdsLastLineNo = 0;
int uaLastLineNo = 0;
int profLastLineNo = 0;
int whLastLineNo = 0;
int uawhLastLineNo = 0;
int cdswhLastLineNo = 0;

int tServLastLineNo = 0;
int userLastLineNo = 0;
int tAdmLastLineNo = 0;
int pamLastLineNo = 0;
int procLastLineNo = 0;
int docLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getParameter("uaLastLineNo") != null) uaLastLineNo = Integer.parseInt(request.getParameter("uaLastLineNo"));
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("whLastLineNo") != null) whLastLineNo = Integer.parseInt(request.getParameter("whLastLineNo"));
if (request.getParameter("uawhLastLineNo") != null) uawhLastLineNo = Integer.parseInt(request.getParameter("uawhLastLineNo"));
if (request.getParameter("cdswhLastLineNo") != null) cdswhLastLineNo = Integer.parseInt(request.getParameter("cdswhLastLineNo"));
if (request.getParameter("tServLastLineNo") != null) tServLastLineNo = Integer.parseInt(request.getParameter("tServLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));
if (request.getParameter("tAdmLastLineNo") != null) tAdmLastLineNo = Integer.parseInt(request.getParameter("tAdmLastLineNo"));
if (request.getParameter("pamLastLineNo") != null) pamLastLineNo = Integer.parseInt(request.getParameter("pamLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));

if (request.getParameter("mode") == null) mode = "add";

if(request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

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

	String compania = request.getParameter("compania");
	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (fp.equalsIgnoreCase("ua_references")) compania = (String) session.getAttribute("_companyId");
	else if (compania == null) compania = "";
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (!compania.trim().equals("")) appendFilter += " and a.compania="+compania;
	if (!codigo.trim().equals("")) appendFilter += " and a.codigo_almacen like '"+codigo+"%'";
	if (!descripcion.trim().equals("")) appendFilter += " and upper(a.descripcion) like '%"+descripcion.toUpperCase()+"%'";

	if (fp.equalsIgnoreCase("user_ua")) appendFilter += " and (a.compania, a.codigo_almacen) in (select distinct compania, almacen from tbl_sec_ua_almacen where (compania, ua) in (select compania, ua from tbl_sec_user_ua where user_id="+id+"))";
	else if (fp.equalsIgnoreCase("user_cds")) appendFilter += " and (a.compania, a.codigo_almacen) in (select distinct compania, almacen from tbl_sec_cds_almacen where cds in (select cds from tbl_sec_user_cds where user_id="+id+"))";

	sql = "select a.codigo_almacen, a.descripcion, a.compania, (select nombre from tbl_sec_compania where codigo=a.compania) as compania_nombre from tbl_inv_almacen a where a.codigo_almacen!=0"+appendFilter+" order by 3, 2";
	al = SQLMgr.getDataList(sql);
	rowCount = CmnMgr.getCount("select count(*) from tbl_inv_almacen a where a.codigo_almacen!=0"+appendFilter);

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
document.title = 'Almacén - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE ALMACEN"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("fg",fg)%>
			<td width="40%">
<%
if (fp.equalsIgnoreCase("ua_references"))
{
%>
<%=fb.hidden("compania",compania)%>
<%
}
else
{
%>
				<cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||nombre from tbl_sec_compania"+((fp.equalsIgnoreCase("ua_references"))?" where codigo="+(String) session.getAttribute("_companyId"):"")+" order by codigo","compania",compania,false,false,0,((fp.equalsIgnoreCase("ua_references"))?"":"T"))%>
<%
}
%>
			</td>
			<td width="20%">
				C&oacute;digo
				<%=fb.intBox("codigo","",false,false,false,15)%>
			</td>
			<td width="40%">
				Descripci&oacute;n
				<%=fb.textBox("descripcion","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("cds",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fg",fg)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="20%">C&oacute;digo</td>
			<td width="70%">Descripci&oacute;n</td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los almacenes listados!")%></td>
		</tr>
<%
String displayComp = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	boolean checked = false;
	if (fp.equalsIgnoreCase("user_ua")) { if (vUAWH.contains(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"))) checked = true; }
	else if (fp.equalsIgnoreCase("user_cds")) { if (vCDSWH.contains(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"))) checked = true; }
	else if (fp.equalsIgnoreCase("user_inv")) { if (vWhInv.contains(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"))) checked = true; }
	else if (vWH.contains(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"))) checked = true;

	if (!displayComp.trim().equalsIgnoreCase(cdo.getColValue("compania_nombre")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="3">[ <%=cdo.getColValue("compania")%> ] <%=cdo.getColValue("compania_nombre")%></td>
		</tr>
<%
	}
%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("compania_nombre"+i,cdo.getColValue("compania_nombre"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo_almacen"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo_almacen")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=(checked)?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo_almacen"),false,false)%></td>
		</tr>
<%
	displayComp = cdo.getColValue("compania_nombre");
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	int lineNo = 0;
	if (fp.equalsIgnoreCase("user_ua")) lineNo = uawhLastLineNo;
	else if (fp.equalsIgnoreCase("user_cds")) lineNo = cdswhLastLineNo;
	else lineNo = whLastLineNo;
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("compania",request.getParameter("compania"+i));
			cdo.addColValue("compania_name",request.getParameter("compania_nombre"+i));
			cdo.addColValue("codigo_almacen",request.getParameter("codigo"+i));
			cdo.addColValue("desc_almacen",request.getParameter("descripcion"+i));
			lineNo++;

			String key = "";
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			if (fp.equalsIgnoreCase("user_ua")||fp.equalsIgnoreCase("user_cds")||fp.equalsIgnoreCase("user_inv")){cdo.setAction("I");}
			else cdo.addColValue("key",key);

			try
			{
				if (fp.equalsIgnoreCase("user_ua"))
				{
					cdo.setKey(iUAWH.size()+1);
					iUAWH.put(cdo.getKey(), cdo);
					vUAWH.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
				else if (fp.equalsIgnoreCase("user_cds"))
				{
					cdo.setKey(iCDSWH.size()+1);
					iCDSWH.put(cdo.getKey(), cdo);
					vCDSWH.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
				else if (fp.equalsIgnoreCase("user_inv"))
				{
					cdo.setKey(iWhInv.size()+1);
					iWhInv.put(cdo.getKey(), cdo);
					vWhInv.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
				else
				{
					iWH.put(key, cdo);
					vWH.add(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
				}
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}
	if (fp.equalsIgnoreCase("user_ua")) uawhLastLineNo = lineNo;
	else if (fp.equalsIgnoreCase("user_cds")) cdswhLastLineNo = lineNo;
	else whLastLineNo = lineNo;

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&profLastLineNo="+profLastLineNo+"&whLastLineNo="+whLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&profLastLineNo="+profLastLineNo+"&whLastLineNo="+whLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("user_ua"))
	{
%>
	window.opener.location = '../admin/reg_user.jsp?change=1&tab=4&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&uawhLastLineNo=<%=uawhLastLineNo%>&cdswhLastLineNo=<%=cdswhLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("user_cds"))
	{
%>
	window.opener.location = '../admin/reg_user.jsp?change=1&tab=5&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&uawhLastLineNo=<%=uawhLastLineNo%>&cdswhLastLineNo=<%=cdswhLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("user_inv"))
	{
%>
	window.opener.location = '../admin/reg_user.jsp?change=1&tab=7&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&uawhLastLineNo=<%=uawhLastLineNo%>&cdswhLastLineNo=<%=cdswhLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("cds_references"))
	{
%>
	window.opener.location = '../admin/reg_cds_references.jsp?change=1&tab=5&mode=<%=mode%>&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("ua_references"))
	{
%>
	window.opener.location = '../rhplanilla/unidadesadm_config.jsp?fp=<%=fg%>&change=1&tab=1&mode=<%=mode%>&id=<%=id%>&whLastLineNo=<%=whLastLineNo%>';
<%
	}
%>
window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>