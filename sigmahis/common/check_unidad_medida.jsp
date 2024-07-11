<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="mFactor" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFactor" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);%><%
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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

int mFLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mFLastLineNo") != null) mFLastLineNo = Integer.parseInt(request.getParameter("mFLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

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
	
	String codigo  = "";                 // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = "";

  if (request.getParameter("code") != null)
  {
    appendFilter += " Where upper(cod_medida) like '%"+request.getParameter("code").toUpperCase()+"%'";
    searchOn = "cod_medida";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
		codigo     = request.getParameter("code");    // utilizada para mantener el Código de la Unidad de Medida
	
  }
  else if (request.getParameter("descripcion") != null)
  {    
    appendFilter += " Where upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
	  descrip    = request.getParameter("descripcion");  // utilizada para mantener la Descripción de la Unidad de Medida
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
	 
   }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
  
 if (fp.equalsIgnoreCase("listFactor"))
	{		
	appendFilter += " ORDER BY descripcion asc";	
	sql="select cod_medida , descripcion  from tbl_inv_unidad_medida "+appendFilter;
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  	rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_inv_unidad_medida"+appendFilter);
	
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

//--------------------------------------------------

%>
<html>
<head>
<%@ include file="nocache.jsp"%>
<%@ include file="header_param.jsp"%>
<script language="javascript">
document.title = 'UNIDADES DE MEDIDAS  - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION - UNIDADES DE MEDIDAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("mode",""+mode)%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("size",""+al.size())%>
			<%=fb.hidden("mFLastLineNo",""+mFLastLineNo)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="50%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("code",codigo,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>	
		<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("mode",""+mode)%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("size",""+al.size())%>
			<%=fb.hidden("mFLastLineNo",""+mFLastLineNo)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion",descrip,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>	
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>
<!--------------------------------------------------------  --->
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	  <tr>
  			  <td align="right">&nbsp;</td>
 	 </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("medidas",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
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
<%=fb.hidden("mFLastLineNo",""+mFLastLineNo)%>

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
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
	
		<td width="30%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel> </td>
		<td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
		<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todas las unidades de medida listadas!")%></td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("cod_medida"+i,cdo.getColValue("cod_medida"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		    <td><%=cdo.getColValue("cod_medida")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=(vFactor.contains(cdo.getColValue("cod_medida")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("cod_medida"),false,false)%></td>
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
<%@ include file="footer.jsp"%>
</body>
</html>
<%
}//get 
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("cod_medida",request.getParameter("cod_medida"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("comentario"," ");
			mFLastLineNo++;
			String key = "";
			if (mFLastLineNo < 10) key = "00"+mFLastLineNo;
			else if (mFLastLineNo < 100) key = "0"+mFLastLineNo;
			else key = ""+mFLastLineNo;
			cdo.addColValue("key",key);
	
			try
			{
				mFactor.put(key, cdo);
				vFactor.add(cdo.getColValue("cod_medida"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// if checked
	}//for
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change =1 &mode="+mode+"&id="+id+"&mFLastLineNo="+mFLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		
		
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change =1 &mode="+mode+"&id="+id+"&mFLastLineNo="+mFLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		
	
		
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
	if (fp.equalsIgnoreCase("listFactor"))
	{
%>
	window.opener.location = '../expediente/antecedente_neonatal_list_medida.jsp?change=1&mode=<%=mode%>&id=<%=id%>&mFLastLineNo=<%=mFLastLineNo%>';
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