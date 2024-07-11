<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DocuMedicoAreas"%>
<%@ page import="issi.expediente.DetalleDocumentos"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iSecc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSecc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSecFlujo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSecFlujo" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSeccRes" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSeccRes" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100027") || SecMgr.checkAccess(session.getId(),"100028") || SecMgr.checkAccess(session.getId(),"100029") || SecMgr.checkAccess(session.getId(),"100030"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = " where status <> 'X' ";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String descripcion = "";
String codigo = "";
String compania = (String) session.getAttribute("_companyId");
int seccLastLineNo = 0;
int cdsLastLineNo = 0;
int profLastLineNo = 0;
int secFlujoLastLineNo = 0;
int seccResLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("seccLastLineNo") != null) seccLastLineNo = Integer.parseInt(request.getParameter("seccLastLineNo"));
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("secFlujoLastLineNo") != null) secFlujoLastLineNo = Integer.parseInt(request.getParameter("secFlujoLastLineNo"));
if (request.getParameter("seccResLastLineNo") != null) seccResLastLineNo = Integer.parseInt(request.getParameter("seccResLastLineNo"));

if (request.getParameter("mode") == null) mode = "add";

String context = request.getParameter("context") == null ? "" : request.getParameter("context");
String jsContext = "window.opener.";
if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage=100;
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

	if (request.getParameter("codigo") != null&&!request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(codigo) = "+request.getParameter("codigo");
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
     codigo = request.getParameter("codigo");
	}
	else if (request.getParameter("descripcion") != null&&!request.getParameter("descripcion").trim().equals(""))
	{
		appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
	descripcion = request.getParameter("descripcion");
	}
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
		{
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
  
	if (fp.equalsIgnoreCase("documentos")||fp.equalsIgnoreCase("trazabilidad"))
	{
		sql = "select codigo, descripcion from tbl_sal_expediente_secciones"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sal_expediente_secciones"+appendFilter);
	}
	else if (fp.equalsIgnoreCase("flujo_atencion")){
	    sql = "select codigo, descripcion from tbl_sal_expediente_secciones"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from  ("+sql+") ");
	}else if (fp.equalsIgnoreCase("secciones_resumen")){
		sql = "select codigo, descripcion, table_name from tbl_sal_expediente_secciones"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sal_expediente_secciones"+appendFilter);
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
document.title = 'Expedientes Secciones - '+document.title;
<%if (fp.equalsIgnoreCase("trazabilidad")){ %>
var ignoreSelectAnyWhere = true;
<%}%>
function setOrden(i){
<%if (fp.equalsIgnoreCase("trazabilidad")){ %>
		if(<%=jsContext%>document.search01.section)<%=jsContext%>document.search01.section.value = eval('document.secciones.codigo'+i).value;
		if(<%=jsContext%>document.search01.section_desc)<%=jsContext%>document.search01.section_desc.value = eval('document.secciones.descripcion'+i).value;
<%}%>

<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
    <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
<%}%>
}

function doAction(){<% if(context.equalsIgnoreCase("preventPopupFrame") && al.size()==1) {%> setOrden(0); <%}%>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DOCUMENTOS - SECCIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
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
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("secFlujoLastLineNo",""+secFlujoLastLineNo)%>
<%=fb.hidden("seccResLastLineNo",""+seccResLastLineNo)%>
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,30)%>
				&nbsp;&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel>&nbsp;<%=fb.textBox("descripcion",descripcion,false,false,false,40)%>
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
<%fb = new FormBean("secciones",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("secFlujoLastLineNo",""+secFlujoLastLineNo)%>
<%=fb.hidden("seccResLastLineNo",""+seccResLastLineNo)%>
<%=fb.hidden("context", context)%>
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

<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<%if(fp.equalsIgnoreCase("flujo_atencion")){%>
			   <td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			   <td width="10%"><cellbytelabel>Orden Flujo</cellbytelabel></td>
			<%}else{%>
			   <td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<%}%>
			<td width="10%"><%=fb.checkbox("check","",false,fp.equalsIgnoreCase("trazabilidad"),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas los centros de servicios listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("table_name"+i,cdo.getColValue("table_name"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onclick="setOrden(<%=i%>)">
			<td><%=cdo.getColValue("codigo")%></td>
			<%if(fp.equalsIgnoreCase("flujo_atencion")){%>
			  <td><%=cdo.getColValue("descripcion")%></td>
			  <td align="center"><%=fb.intBox("orden"+i,""+(i+1),false,false,false,5,3)%></td>
			<%}else{%>
			  <td><%=cdo.getColValue("descripcion")%></td>
			<%}%>
			<td align="center"><%=( vSecc.contains(cdo.getColValue("codigo")) || vSecFlujo.contains(id+"-"+cdo.getColValue("codigo")+"-"+compania)|| vSeccRes.contains(id+"-"+cdo.getColValue("codigo")) )?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,fp.equalsIgnoreCase("trazabilidad"),"check",null,"")%></td>

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
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
		  if (fp.equalsIgnoreCase("documentos"))
		  {
				DetalleDocumentos detDoc = new DetalleDocumentos();

				detDoc.setSeccCode(request.getParameter("codigo"+i));//codigo
				detDoc.setSeccDesc(request.getParameter("descripcion"+i));//descripcion seccion
				detDoc.setDocId(request.getParameter("id"));//id
				seccLastLineNo++;

				String key = "";
				if (seccLastLineNo < 10) key = "00"+seccLastLineNo;
				else if (seccLastLineNo < 100) key = "0"+seccLastLineNo;
				else key = ""+seccLastLineNo;
				detDoc.setKey(key);

				try
				{
					iSecc.put(key,detDoc);
					vSecc.add(detDoc.getSeccCode());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		  }
		  else if (fp.equalsIgnoreCase("flujo_atencion")){
		     
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cod_seccion",request.getParameter("codigo"+i));
				cdo.addColValue("desc_seccion",request.getParameter("descripcion"+i));
				cdo.addColValue("orden",request.getParameter("orden"+i));
				cdo.addColValue("requerido","N");//descripcion seccion
				cdo.setAction("I");
				secFlujoLastLineNo++;

				String key = "";
				
				if (secFlujoLastLineNo < 10) key = "00"+secFlujoLastLineNo;
				else if (secFlujoLastLineNo < 100) key = "0"+secFlujoLastLineNo;
				else key = ""+secFlujoLastLineNo;
				
				cdo.setKey(key);
				cdo.addColValue("key",key);
				
				try
				{
					iSecFlujo.put(key,cdo);
					vSecFlujo.add(id+"-"+request.getParameter("codigo"+i)+"-"+compania);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		  }
		  if (fp.equalsIgnoreCase("secciones_resumen")){
				DetalleDocumentos detDoc = new DetalleDocumentos();

				detDoc.setSeccResId(request.getParameter("codigo"+i));//codigo
				detDoc.setSeccionResDesc(request.getParameter("descripcion"+i));//descripcion seccion
				detDoc.setDocResId(request.getParameter("id"));//id
				detDoc.setResSeccionTabla(request.getParameter("table_name"+i));//id
				detDoc.setDisplayResOrder(""+(i+1));//id
				seccResLastLineNo++;

				String key = "";
				if (seccResLastLineNo < 10) key = "00"+seccResLastLineNo;
				else if (seccResLastLineNo < 100) key = "0"+seccResLastLineNo;
				else key = ""+seccResLastLineNo;
				detDoc.setKey(key);

				try
				{
					iSeccRes.put(key,detDoc);
					vSeccRes.add(id+"-"+request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		  }
		  
		}// checked
	}//for

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&seccLastLineNo="+seccLastLineNo+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&secFlujoLastLineNo="+request.getParameter("secFlujoLastLineNo")+"&context="+request.getParameter("context"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&seccLastLineNo="+seccLastLineNo+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&secFlujoLastLineNo="+request.getParameter("secFlujoLastLineNo")+"&context="+request.getParameter("context"));
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
	if (fp.equalsIgnoreCase("documentos"))
	{
%>
	window.opener.location = '../expediente/exp_doc_secciones.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&seccLastLineNo=<%=seccLastLineNo%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&secFlujoLastLineNo=<%=secFlujoLastLineNo%>';
<%
	} 
	else if (fp.equalsIgnoreCase("flujo_atencion")){%>
	  window.opener.location = '../expediente/exp_flujo_atencion_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&secFlujoLastLineNo=<%=secFlujoLastLineNo%>';
<%	
	}else if (fp.equalsIgnoreCase("secciones_resumen")){%>
	  window.opener.location = '../expediente/exp_doc_secciones.jsp?change=1&tab=4&mode=<%=mode%>&id=<%=id%>&secFlujoLastLineNo=<%=secFlujoLastLineNo%>&seccResLastLineNo=<%=seccResLastLineNo%>';
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