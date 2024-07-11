
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" buffer="16kb" autoFlush="true"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htinsumo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vctarticulo" scope="session" class="java.util.Vector" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alcentro = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id=request.getParameter("id");
String mode= request.getParameter("mode");
//String key="";
String change ="";
int insuLastLineNo = 0;
int usoLastLineNo = 0;
int equipLastLineNo = 0;

if (request.getParameter("insuLastLineNo") != null) insuLastLineNo = Integer.parseInt(request.getParameter("insuLastLineNo"));
if (request.getParameter("usoLastLineNo") != null) usoLastLineNo = Integer.parseInt(request.getParameter("usoLastLineNo"));
if (request.getParameter("equipLastLineNo") != null) equipLastLineNo = Integer.parseInt(request.getParameter("equipLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";


if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos";

  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
	
  }
  String codigo="",descripcion="";
  if (request.getParameter("codigos") != null && !request.getParameter("codigos").trim().equals(""))
  {
    appendFilter += " and upper(a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo) like '%"+request.getParameter("codigos").toUpperCase()+"%'";
    codigo = request.getParameter("codigos");
  }
	
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  
 	sql = "select codigo, descripcion, observacion as observaciones from tbl_cds_maletin where codigo="+id;
	cdo = SQLMgr.getData(sql);
	
	sql="select a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as codigos, a.cod_flia, a.cod_clase, a.cod_articulo, a.descripcion, b.cod_flia as codeflia, b.cod_clase as codeclase, b.descripcion as nom, c.cod_flia as codefamilia, c.nombre from tbl_inv_articulo a, tbl_inv_clase_articulo b, tbl_inv_familia_articulo c where a.cod_flia=b.cod_flia and a.cod_clase= b.cod_clase and a.cod_flia= c.cod_flia and a.compania =b.compania and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.descripcion";
	alcentro  = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
				
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
document.title = 'Lista de Articulos - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="LISTA DE ARTICULO"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">		
					<% 
					 fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%>
					<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
					<%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>	
					<%=fb.hidden("mode",mode)%>
					<td width="50%">&nbsp;C&oacute;digo 
								<%=fb.intBox("codigos","",false,false,false,30,null,null,null)%>
					</td>
					<td width="50%">&nbsp;Descripci&oacute;n
								<%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
								<%=fb.submit("go","Ir")%>	
					</td>
					<%=fb.formEnd()%>	
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<%
	fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%//=fb.hidden("searchValFromDate",searchValFromDate)%>
<%//=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+alcentro.size())%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codigos",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">				
				<tr class="TextPager">
					<td align="right" colspan="2">
					<%=fb.submit("add","Agregar",true,false)%>
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
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="20%">Codigo de Articulos</td>
					<td width="60%">Descripci&oacute;n</td>
					<td width="15%">&nbsp;<%//=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('codigos','check',"+alcentro.size()+",this,0)\"","Seleccionar todas los Códigos del  listadas!")%></td>
				</tr>
				<%
				for (int i=0; i<alcentro.size(); i++)
				{
				 CommonDataObject cdos = (CommonDataObject) alcentro.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("cod_flia"+i,cdos.getColValue("cod_flia"))%>
				<%=fb.hidden("cod_clase"+i,cdos.getColValue("cod_clase"))%>
				<%=fb.hidden("cod_articulo"+i,cdos.getColValue("cod_articulo"))%>		
				<%=fb.hidden("codigos"+i,cdos.getColValue("codigos"))%>					
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=preVal + i%></td>
					<td>&nbsp;<%=cdos.getColValue("codigos")%></td>
					<td>&nbsp;<%=cdos.getColValue("descripcion")%><%=fb.hidden("descripcion"+i,cdos.getColValue("descripcion"))%></td>
					<td><%=(vctarticulo.contains(cdos.getColValue("codigos")))?"Elegido":fb.checkbox("check"+i,""+cdos.getColValue("codigos"),false,false)%></td>
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
}//GET 
else
{ 
 int size = Integer.parseInt(request.getParameter("size"));
 //	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
  for (int i=0; i<size; i++)
  { 
    if (request.getParameter("check"+i) != null)
	 {
	 CommonDataObject cdo1 = new CommonDataObject();	
	 cdo1.addColValue("cod_familia",request.getParameter("cod_flia"+i));	
	 cdo1.addColValue("cod_clase",request.getParameter("cod_clase"+i)); 
	 cdo1.addColValue("cod_articulo",request.getParameter("cod_articulo"+i));
	 cdo1.addColValue("descripcion",request.getParameter("descripcion"+i));
	 cdo1.addColValue("codigos",request.getParameter("codigos"+i));
	insuLastLineNo++;
		String key = "";
			if (insuLastLineNo < 10) key = "00"+insuLastLineNo;
			else if (insuLastLineNo < 100) key = "0"+insuLastLineNo;
			else key = ""+insuLastLineNo;
			cdo1.addColValue("key",key);		
		try
			{
				htinsumo.put(key, cdo1);
				vctarticulo.add(cdo1.getColValue("codigos"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
	   }// checked
	}	//End For
    
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigos="+request.getParameter("codigos")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigos="+request.getParameter("codigos")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
window.opener.location = '../inventario/maletin_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&insuLastLineNo=<%=insuLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&equipLastLineNo=<%=equipLastLineNo%>';
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
