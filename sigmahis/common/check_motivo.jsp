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
<jsp:useBean id="iMotivo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMotivo" scope="session" class="java.util.Vector" />
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
String tab = request.getParameter("tab");
String cDateTime =  CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

int motiLastLineNo =0; 
int incenLastLineNo =0; 
int sueldoLastLineNo =0; 
int aumenLastLineNo =0; 
int bonoLastLineNo =0; 

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("motiLastLineNo") != null) motiLastLineNo = Integer.parseInt(request.getParameter("motiLastLineNo"));
if (request.getParameter("incenLastLineNo") != null) incenLastLineNo = Integer.parseInt(request.getParameter("incenLastLineNo"));
if (request.getParameter("sueldoLastLineNo") != null) sueldoLastLineNo = Integer.parseInt(request.getParameter("sueldoLastLineNo"));
if (request.getParameter("aumenLastLineNo") != null) aumenLastLineNo = Integer.parseInt(request.getParameter("aumenLastLineNo"));
if (request.getParameter("bonoLastLineNo") != null) bonoLastLineNo = Integer.parseInt(request.getParameter("bonoLastLineNo"));

if (mode == null) mode = "add";
if (id == null) id = "";
if (tab == null) tab = "";

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

	if (request.getParameter("code") != null)
	{
		
		appendFilter += " where upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";

    searchOn = "codigo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
	}
	else if (request.getParameter("name") != null)
	{
		appendFilter += " where upper(descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";

    searchOn = "descripcion";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Nombre";
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

	if (fp.equalsIgnoreCase("convencion"))
	{
		sql ="select codigo as motivo_falta, descripcion from tbl_pla_motivo_falta "+appendFilter+" order by codigo asc";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_pla_motivo_falta  "+appendFilter);
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
document.title = 'Motivos de falta - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MOTIVOS DE FALTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
				 <%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
				 <%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
				 <%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
				 <%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>
				<%=fb.hidden("tab",tab)%>
				<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("code","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
				 <%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
				 <%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
				 <%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
				 <%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>
				<%=fb.hidden("tab",tab)%>
				<td width="50%">
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("name","",false,false,false,40)%>
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
<%
fb = new FormBean("tipoServicio",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
<%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
<%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
<%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
<%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>
<%=fb.hidden("tab",tab)%>

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
		<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="75%"><cellbytelabel>Desripci&oacute;n</cellbytelabel></td>
		<td width="15%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los documentos listados!")%></td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("motivo_falta"+i,cdo.getColValue("motivo_falta"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("motivo_falta")%></td>
				<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=((fp.equalsIgnoreCase("convencion") && vMotivo.contains(cdo.getColValue("motivo_falta"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("motivo_falta"),false,false)%></td>
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
	if (fp.equalsIgnoreCase("convencion"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
	
				cdo.addColValue("motivo_falta",request.getParameter("motivo_falta"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				cdo.addColValue("fecha_creacion",cDateTime);   
			  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
				motiLastLineNo++;
	
				String key = "";
				if (motiLastLineNo < 10) key = "00"+motiLastLineNo;
				else if (motiLastLineNo < 100) key = "0"+motiLastLineNo;
				else key = ""+motiLastLineNo;
				cdo.addColValue("key",key);
		
				try
				{
					iMotivo.put(key, cdo);
					vMotivo.add(cdo.getColValue("motivo_falta"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}//for
	}//convencion 
	

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo+"&tab="+tab+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
		
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo+"&tab="+tab+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	if (fp.equalsIgnoreCase("convencion"))
	{
%>
	window.opener.location = '../rhplanilla/convencion_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&motiLastLineNo=<%=motiLastLineNo%>&incenLastLineNo=<%=incenLastLineNo%>&sueldoLastLineNo=<%=sueldoLastLineNo%>&aumenLastLineNo=<%=aumenLastLineNo%>&bonoLastLineNo=<%=bonoLastLineNo%>';
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