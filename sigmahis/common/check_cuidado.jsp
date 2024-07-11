<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCuidado" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCuidado" scope="session" class="java.util.Vector" />

<%
/*
==================================================================================
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500037") || SecMgr.checkAccess(session.getId(),"500038") || SecMgr.checkAccess(session.getId(),"500039") || SecMgr.checkAccess(session.getId(),"500040"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String tab = request.getParameter("tab");
String cds = request.getParameter("cds");
String exp = request.getParameter("exp");
String index = request.getParameter("index");
if (exp == null) exp = "";
if (index == null) index = "";
if (fg == null) fg = "";

int diagLastLineNo = 0;
int medLastLineNo = 0;
int dietaLastLineNo = 0;
int cuidadoLastLineNo = 0;
if (cds == null)cds="";
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("medLastLineNo") != null) medLastLineNo      =Integer.parseInt(request.getParameter("medLastLineNo"));
if (request.getParameter("dietaLastLineNo") != null) dietaLastLineNo  =Integer.parseInt(request.getParameter("dietaLastLineNo"));
if (request.getParameter("cuidadoLastLineNo")!= null)cuidadoLastLineNo=Integer.parseInt(request.getParameter("cuidadoLastLineNo"));

String desc = request.getParameter("desc");
if (desc == null) desc = "";


if(request.getMethod().equalsIgnoreCase("GET"))
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
  String codigo ="",descripcion="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(id) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  
 	  if (!cds.trim().equals(""))
	  {
		appendFilter += " and b.cds ="+cds;
	  }

	if (fp.equalsIgnoreCase("pSalida") )//pSalida = Plan de Salida.  
	{
  sql="select distinct a.id, a.nombre , a.descripcion,a.tipo, decode(a.status,'A','ACTIVO','INACTIVO') status from tbl_sal_guia a,tbl_sal_guia_cds b where a.tipo = 'C' and a.status ='A' and a.id = b.cod_guia "+appendFilter+" order by nombre";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ( "+sql+")");
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
document.title = 'Cuidados - '+document.title;

function setCuidado(id, desc) {
	<%if(fg.equalsIgnoreCase("PSLO") && fp.equalsIgnoreCase("pSalida")){%>
	$("#guia_id<%=index%>", window.opener.document).val(id);
	$("#descGuia<%=index%>", window.opener.document).val(desc);
	window.close();
	<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CUIDADOS"></jsp:param>
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
		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
				<%=fb.hidden("dietaLastLineNo",""+dietaLastLineNo)%>
				<%=fb.hidden("cuidadoLastLineNo",""+cuidadoLastLineNo)%>
				<%=fb.hidden("seccion",""+seccion)%>
                <%=fb.hidden("desc",""+desc)%>
                <%=fb.hidden("exp",exp)%>
                <%=fb.hidden("index",index)%>
                <%=fb.hidden("fg",fg)%>
				<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,20)%>
				</td>
				<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
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
<%
fb = new FormBean("cds",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
<%=fb.hidden("dietaLastLineNo",""+dietaLastLineNo)%>
<%=fb.hidden("cuidadoLastLineNo",""+cuidadoLastLineNo)%>
<%=fb.hidden("seccion",""+seccion)%>
<%=fb.hidden("codigo",""+descripcion)%>
<%=fb.hidden("descripcion",""+descripcion)%>
<%=fb.hidden("desc",""+desc)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("fg",fg)%>
	<%if(!fg.equalsIgnoreCase("PSLO")){%>
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
	<%}%>
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
					<td width="80%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,fg.equalsIgnoreCase("PSLO"),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los Cuidados listados!")%></td>
				</tr>
<%
String dieta ="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codGuia"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("descCuidado"+i,cdo.getColValue("nombre"))%>
				
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="setCuidado('<%=cdo.getColValue("id")%>','<%=cdo.getColValue("nombre")%>')">
					<td align="right"><%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=((fp.equalsIgnoreCase("pSalida") && vCuidado.contains(cdo.getColValue("id"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("id"),false,false)%></td>
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
	<%if(!fg.equalsIgnoreCase("PSLO")){%>
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
	<%}%>
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
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			 if (fp.equalsIgnoreCase("pSalida"))
			{
				
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("codigo","0");
				cdo.addColValue("guia_id",request.getParameter("codGuia"+i));
				cdo.addColValue("descGuia",request.getParameter("descCuidado"+i));

				cuidadoLastLineNo++;

				String key = "";
				if (cuidadoLastLineNo < 10) key = "00"+cuidadoLastLineNo;
				else if (cuidadoLastLineNo < 100) key = "0"+cuidadoLastLineNo;
				else key = ""+cuidadoLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iCuidado.put(key, cdo);
					vCuidado.add(cdo.getColValue("guia_id"));
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&diagLastLineNo="+diagLastLineNo+"&medLastLineNo="+medLastLineNo+"&dietaLastLineNo="+dietaLastLineNo+"&cuidadoLastLineNo="+cuidadoLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&desc="+desc+"&exp="+exp+"&index="+index+"&fg="+fg);
		return;
	}
	
	
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&diagLastLineNo="+diagLastLineNo+"&medLastLineNo="+medLastLineNo+"&dietaLastLineNo="+dietaLastLineNo+"&cuidadoLastLineNo="+cuidadoLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&desc="+desc+"&exp="+exp+"&index="+index+"&fg="+fg);
		return;
	}
	
	
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("pSalida"))
	{
%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_plan_salida.jsp?change=1&tab=4&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagLastLineNo=<%=diagLastLineNo%>&medLastLineNo=<%=medLastLineNo%>&dietaLastLineNo=<%=dietaLastLineNo%>&cuidadoLastLineNo=<%=cuidadoLastLineNo%>&seccion=<%=seccion%>&cds=<%=cds%>&desc=<%=desc%>&index=<%=index%>&fg=<%=fg%>';
	
<%}%>

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