<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DocuMedicoAreas"%>
<%@ page import="issi.expediente.DetalleDocumentos"%>
<%@ page import="issi.expediente.DetalleCara"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCds" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDetCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDetCds" scope="session" class="java.util.Vector" />
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
String caract = request.getParameter("caract");

int cdsLastLineNo = 0;
int uaLastLineNo = 0;
int seccLastLineNo = 0;
int profLastLineNo = 0;
int detLastLineNo = 0;
int detCdsLastLineNo = 0;
int uawhLastLineNo = 0;
int cdswhLastLineNo = 0;
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getParameter("uaLastLineNo") != null) uaLastLineNo = Integer.parseInt(request.getParameter("uaLastLineNo"));
if (request.getParameter("seccLastLineNo") != null) seccLastLineNo = Integer.parseInt(request.getParameter("seccLastLineNo"));
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("detLastLineNo") != null) detLastLineNo = Integer.parseInt(request.getParameter("detLastLineNo"));
if (request.getParameter("detCdsLastLineNo") != null) detCdsLastLineNo = Integer.parseInt(request.getParameter("detCdsLastLineNo"));
if (request.getParameter("uawhLastLineNo") != null) uawhLastLineNo = Integer.parseInt(request.getParameter("uawhLastLineNo"));
if (request.getParameter("cdswhLastLineNo") != null) cdswhLastLineNo = Integer.parseInt(request.getParameter("cdswhLastLineNo"));

if (mode == null) mode = "add";

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

	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (!codigo.trim().equals("")) appendFilter += " and codigo="+codigo;
	if (!descripcion.trim().equals("")) appendFilter += " and upper(descripcion) like '%"+descripcion.toUpperCase()+"%'";

	sql = "select codigo, descripcion from tbl_cds_centro_servicio where estado='A'"+appendFilter+" order by descripcion";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_cds_centro_servicio where estado='A'"+appendFilter);

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
document.title = 'Centro de Servicio - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
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
<%=fb.hidden("caract",caract)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
<%=fb.hidden("detCdsLastLineNo",""+detCdsLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
			<td width="50%">
				<cellbytelabel id="1">C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,15)%>
			</td>
			<td width="50%">
				<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
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
<%=fb.hidden("caract",caract)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
<%=fb.hidden("detCdsLastLineNo",""+detCdsLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
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
			<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel><%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="70%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas los centros de servicios listados!")%></td>
		</tr>
<%
String displayCheck = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (fp.equalsIgnoreCase("areaDetalle")) displayCheck = (vDetCds.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false);
	else displayCheck = (vCds.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false);
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=displayCheck%></td>
		</tr>
<%
}
%>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			if (fp.equalsIgnoreCase("documentos"))
			{
				DetalleDocumentos detDoc = new DetalleDocumentos();
				detDoc.setCdsCode(request.getParameter("codigo"+i));
				detDoc.setCdsDesc(request.getParameter("descripcion"+i));
				detDoc.setDocId(request.getParameter("id"));

				cdsLastLineNo++;

				String key = "";
				if (cdsLastLineNo < 10) key = "00"+cdsLastLineNo;
				else if (cdsLastLineNo < 100) key = "0"+cdsLastLineNo;
				else key = ""+cdsLastLineNo;
				detDoc.setKey(key);

				try
				{
					iCds.put(key, detDoc);
					vCds.add(detDoc.getCdsCode());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("user"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cds",request.getParameter("codigo"+i));
				cdo.addColValue("cdsDesc",request.getParameter("descripcion"+i));
				cdo.addColValue("comments","");
				
				cdo.setKey(iCds.size()+1);
				cdo.setAction("I");
				try
				{
					iCds.put(cdo.getKey(), cdo);
					vCds.add(cdo.getColValue("cds"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("seccion"))
			{
				DocuMedicoAreas area = new DocuMedicoAreas();

				area.setCentroServicio(request.getParameter("codigo"+i));
				area.setObservacion(request.getParameter("descripcion"+i));
				cdsLastLineNo++;

				String key = "";
				if (cdsLastLineNo < 10) key = "00"+cdsLastLineNo;
				else if (cdsLastLineNo < 100) key = "0"+cdsLastLineNo;
				else key = ""+cdsLastLineNo;
				area.setKey(key);

				try
				{
					iCds.put(key, area);
					vCds.add(request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("areaCorporal"))
			{
				DetalleCara det = new DetalleCara();

				det.setCodigo(request.getParameter("codigo"+i));
				det.setDescripcion(request.getParameter("descripcion"+i));
				cdsLastLineNo++;

				String key = "";
				if (cdsLastLineNo < 10) key = "00"+cdsLastLineNo;
				else if (cdsLastLineNo < 100) key = "0"+cdsLastLineNo;
				else key = ""+cdsLastLineNo;
				det.setKey(key);

				try
				{
					iCds.put(key, det);
					vCds.add(request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("areaDetalle"))
			{
				CommonDataObject det = new CommonDataObject();

				det.addColValue("centro_servicio",request.getParameter("codigo"+i));
				det.addColValue("descripcion",request.getParameter("descripcion"+i));
				detCdsLastLineNo++;

				String key = "";
				if (detCdsLastLineNo < 10) key = "00"+detCdsLastLineNo;
				else if (detCdsLastLineNo < 100) key = "0"+detCdsLastLineNo;
				else key = ""+detCdsLastLineNo;
				det.addColValue("key",key);

				try
				{
					iDetCds.put(key, det);
					vDetCds.add(request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("guia"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cds",request.getParameter("codigo"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				
				cdsLastLineNo++;
				String key = "";
				if (cdsLastLineNo < 10) key = "00"+cdsLastLineNo;
				else if (cdsLastLineNo < 100) key = "0"+cdsLastLineNo;
				else key = ""+cdsLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iCds.put(key, cdo);
					vCds.add(cdo.getColValue("cds"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&caract="+caract+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo+"&detLastLineNo="+detLastLineNo+"&detCdsLastLineNo="+detCdsLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));

		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&caract="+caract+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo+"&detLastLineNo="+detLastLineNo+"&detCdsLastLineNo="+detCdsLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
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
	if (fp.equalsIgnoreCase("user"))
	{
%>
	window.opener.location = '../admin/reg_user.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&uawhLastLineNo=<%=uawhLastLineNo%>&cdswhLastLineNo=<%=cdswhLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("seccion"))
	{
%>
		window.opener.location = '../expediente/doc_medico_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("documentos"))
	{
%>
		window.opener.location = '../expediente/exp_doc_secciones.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&seccLastLineNo=<%=seccLastLineNo%>&profLastLineNo=<%=profLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("areaCorporal"))
	{
%>
		window.opener.location = '../expediente/areacorporal_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&detLastLineNo=<%=detLastLineNo%>&cdsLastLineNo=<%=cdsLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("areaDetalle"))
	{
%>
		window.opener.location = '../expediente/area_caract_cds.jsp?change=1&id=<%=id%>&caract=<%=caract%>&detCdsLastLineNo=<%=detCdsLastLineNo%>';
<%
	}
    else if (fp.equalsIgnoreCase("guia"))
	{
%>
		window.opener.location = '../expediente/guia_cuidados_config.jsp?change=1&id=<%=id%>&mode=<%=mode%>&tab=1&cdsLastLineNo=<%=cdsLastLineNo%>';
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