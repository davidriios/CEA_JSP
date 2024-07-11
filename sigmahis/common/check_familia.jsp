<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<%@ page import="issi.admision.CoberturaDetalladaServicio"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iFlia" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFlia" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCtaFlia" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCtaFlia" scope="session" class="java.util.Vector"/>
<jsp:useBean id="HashFlia" scope="session" class="java.util.Hashtable"/>
<%
/**
==============================================================================
==============================================================================
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
String tab = request.getParameter("tab");
String compania = request.getParameter("compania");

int fliaLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
if (id == null) id = "";
if (tab == null) tab = "";
if (request.getParameter("fliaLastLineNo") != null) fliaLastLineNo = Integer.parseInt(request.getParameter("fliaLastLineNo"));


if (request.getMethod().equalsIgnoreCase("GET"))
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
	if(fp.equals("descuento")||fp.equals("ctasInv")||fp.equals("gastoUnd")) compania = (String) session.getAttribute("_companyId");
	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (compania == null) compania = "";
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (!compania.trim().equals("")) appendFilter += " and a.compania="+compania;
	if (!codigo.trim().equals("")) appendFilter += " and a.cod_flia like '"+codigo+"%'";
	if (!descripcion.trim().equals("")) appendFilter += " and upper(a.nombre) like '%"+descripcion.toUpperCase()+"%'";

	sql = "select a.cod_flia as familia, a.compania, a.nombre as desc_flia, (select nombre from tbl_sec_compania where codigo=a.compania) as compania_name from tbl_inv_familia_articulo a where a.cod_flia!=-1"+appendFilter+" order by 3";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_inv_familia_articulo a where a.cod_flia!=0"+appendFilter);

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
document.title = 'Familia - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE FAMILIAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("fliaLastLineNo",""+fliaLastLineNo)%>
<%=fb.hidden("tab",tab)%>
			<td width="40%">
				<cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||nombre from tbl_sec_compania where estado = 'A' "+((fp.equals("descuento")||fp.equals("ctasInv")||fp.equals("gastoUnd"))?" and codigo = "+compania:"")+" order by codigo","compania",compania,false,false,0,"T")%>
			</td>
			<td width="20%">
				<cellbytelabel>Cod. Familia</cellbytelabel>
				<%=fb.textBox("codigo","",false,false,false,10,null,null,null)%>
			</td>
			<td width="40%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion","",false,false,false,40,null,null,null)%>
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
<%fb = new FormBean("familia",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
<%=fb.hidden("fliaLastLineNo",""+fliaLastLineNo)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
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
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
			<td width="30%"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Familia</cellbytelabel></td>
			<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los articulos listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
<%=fb.hidden("familyCode"+i,cdo.getColValue("familia"))%>
<%=fb.hidden("companiaName"+i,cdo.getColValue("compania_name"))%>
<%=fb.hidden("desc_flia"+i,cdo.getColValue("desc_flia"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("compania_name")%></td>
			<td align="center"><%=cdo.getColValue("familia")%></td>
			<td><%=cdo.getColValue("desc_flia")%></td>
			<td align="center"><%=((fp.equalsIgnoreCase("profile") && vFlia.contains(cdo.getColValue("compania")+"-"+cdo.getColValue("familia")))||(fp.equalsIgnoreCase("descuento") && vDet.contains("F_"+cdo.getColValue("familia")))||(fp.equalsIgnoreCase("ctasInv") && vCtaFlia.contains(cdo.getColValue("familia")))||(fp.equalsIgnoreCase("gastoUnd") && vCtaFlia.contains(cdo.getColValue("familia"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("familia"),false,false)%></td>
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
	<td class="TableLeftBorder TableRightBorder">
	<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
	if (fp.equalsIgnoreCase("profile"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("familia",request.getParameter("familyCode"+i));
				cdo.addColValue("compania",request.getParameter("compania"+i));
				cdo.addColValue("compania_name",request.getParameter("companiaName"+i));
				cdo.addColValue("desc_familia",request.getParameter("desc_flia"+i));
				fliaLastLineNo++;

				String key = "";
				if (fliaLastLineNo < 10) key = "00"+fliaLastLineNo;
				else if (fliaLastLineNo < 100) key = "0"+fliaLastLineNo;
				else key = ""+fliaLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iFlia.put(key, cdo);
					vFlia.add(request.getParameter("compania"+i)+"-"+request.getParameter("familyCode"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			
			}// checked
		}
	}//procedimiento
	else if (fp.equalsIgnoreCase("descuento"))
	{
		fliaLastLineNo = iDet.size();
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("codigo",request.getParameter("familyCode"+i));
				cdo.addColValue("descripcion",request.getParameter("desc_flia"+i));
				cdo.addColValue("tipo_desc", "F");
				cdo.addColValue("secuencia", "0");
				fliaLastLineNo++;

				String key = "";
				if (fliaLastLineNo < 10) key = "00"+fliaLastLineNo;
				else if (fliaLastLineNo < 100) key = "0"+fliaLastLineNo;
				else key = ""+fliaLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDet.put(key, cdo);
					vDet.add("F_"+request.getParameter("familyCode"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
	else if (fp.equalsIgnoreCase("ctasInv"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("cod_flia",request.getParameter("familyCode"+i));
				cdo.addColValue("familia",request.getParameter("familyCode"+i));
				cdo.addColValue("descFlia",request.getParameter("familyCode"+i)+" - "+request.getParameter("desc_flia"+i));
				cdo.addColValue("estado", "A");
				cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
				cdo.addColValue("fecha_creacion","sysdate");
				cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
				cdo.addColValue("usuario_modificacion","");
				cdo.addColValue("fecha_modificacion","");
				
				cdo.setAction("I");				
				cdo.setKey(iCtaFlia.size()+1);

				try
				{
					iCtaFlia.put(cdo.getKey(), cdo);
					vCtaFlia.add(cdo.getColValue("cod_flia"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
	else if (fp.equalsIgnoreCase("gastoUnd"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("fliaCode",request.getParameter("familyCode"+i));
				cdo.addColValue("familia",request.getParameter("familyCode"+i));
				cdo.addColValue("flia",request.getParameter("desc_flia"+i));
				cdo.addColValue("cia",(String) session.getAttribute("_companyId"));
				
				
				cdo.setAction("I");				
				cdo.setKey(HashFlia.size()+1);

				try
				{
					HashFlia.put(cdo.getKey(), cdo);
					vCtaFlia.add(cdo.getColValue("fliaCode"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}


	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&fliaLastLineNo="+fliaLastLineNo+"&tab="+tab+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&fliaLastLineNo="+fliaLastLineNo+"&tab="+tab+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
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
	if (fp.equalsIgnoreCase("profile"))
	{
%>
	window.opener.location = '../admin/reg_profile.jsp?change=1&tab=<%=tab%>&mode=<%=mode%>&id=<%=id%>&fliaLastLineNo=<%=fliaLastLineNo%>';
<%
	} else if (fp.equalsIgnoreCase("descuento"))
	{
%>
	window.opener.location = '../pos/reg_descuento_det.jsp?change=1&mode=<%=mode%>&loadInfo=S';
<%
	}else if (fp.equalsIgnoreCase("ctasInv"))
	{
%>
	window.opener.location = '../inventario/mapping_flias.jsp?change=1&mode=<%=mode%>&loadInfo=S&wh=<%=id%>';
<%
	}
	else if (fp.equalsIgnoreCase("gastoUnd"))
	{
%>
	window.opener.location = '../inventario/clasificacion_gasto_config.jsp?change=1&compId=<%=compania%>&unidadId=<%=id%>';
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