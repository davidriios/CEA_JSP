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
<jsp:useBean id="iDieta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDieta" scope="session" class="java.util.Vector" />

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
String cds = request.getParameter("cds");
String exp = request.getParameter("exp");
String restrictNutri = request.getParameter("restrict_nutri");
String restrictNutriObs = request.getParameter("restrict_nutri_obs");
String index = request.getParameter("index");
if (exp == null) exp = "";
if (restrictNutri == null) restrictNutri = "";
if (restrictNutriObs == null) restrictNutriObs = "";
if (index == null) index = "";
if (fg == null) fg = "";

int diagLastLineNo = 0;
int medLastLineNo = 0;
int dietaLastLineNo = 0;
int cuidadoLastLineNo = 0;

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

  if (request.getParameter("codigo") != null)
  {
    appendFilter += " and upper(c.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "c.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter += " and upper(coalesce(c.descripcion,c.observacion)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "coalesce(c.descripcion,c.observacion)";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
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

	if (fp.equalsIgnoreCase("pSalida") )//pSalida = Plan de Salida.  
	{
		sql=" select c.codigo codDieta,b.codigo codSubTipo, c.descripcion descDieta,c.observacion obserDieta,b.observacion obserSubDieta,b.descripcion descSubTipo  from tbl_cds_subtipo_dieta b,tbl_cds_tipo_dieta c where  b.cod_tipo_dieta = c.codigo "+appendFilter+" order by c.codigo asc , b.codigo asc ";
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
<script>
document.title = 'Dietas - '+document.title;

function setDieta(codDieta, codSubTipo, descDieta, descSubTipo) {
	<%if(fg.equalsIgnoreCase("PSLO") && fp.equalsIgnoreCase("pSalida")){%>
	$("#tipo_dieta<%=index%>", window.opener.document).val(codDieta);
	$("#descDieta<%=index%>", window.opener.document).val(descDieta);
	$("#subtipo_dieta<%=index%>", window.opener.document).val(codSubTipo);
	$("#descSubTipo<%=index%>", window.opener.document).val(descSubTipo);
	window.close();
	<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE DIETAS"></jsp:param>
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
				<%=fb.hidden("cds",""+cds)%>
                <%=fb.hidden("desc",""+desc)%>
                <%=fb.hidden("exp",exp)%>
                <%=fb.hidden("restrictNutriObs",restrictNutriObs)%>
                <%=fb.hidden("restrictNutri",restrictNutri)%>
                <%=fb.hidden("index",index)%>
                <%=fb.hidden("fg",fg)%>
				<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,20)%>
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
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
				<%=fb.hidden("dietaLastLineNo",""+dietaLastLineNo)%>
				<%=fb.hidden("cuidadoLastLineNo",""+cuidadoLastLineNo)%>
				<%=fb.hidden("seccion",""+seccion)%>
				<%=fb.hidden("cds",""+cds)%>
                <%=fb.hidden("desc",""+desc)%>
                <%=fb.hidden("exp",exp)%>
                <%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
                <%=fb.hidden("restrict_nutri",restrictNutri)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("fg",fg)%>
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
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("desc",""+desc)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
<%=fb.hidden("restrict_nutri",restrictNutri)%>
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
					<td width="10%">
					<%=fb.checkbox("check","",false,fg.equalsIgnoreCase("PSLO"),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas las Dietas listados!")%></td>
				</tr>
<%
String dieta ="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codDieta"+i,cdo.getColValue("codDieta"))%>
				<%=fb.hidden("descDieta"+i,cdo.getColValue("descDieta"))%>
				<%=fb.hidden("codSubTipo"+i,cdo.getColValue("codSubTipo"))%>
				<%=fb.hidden("descSubTipo"+i,cdo.getColValue("descSubTipo"))%>
				<%if(!dieta.trim().equals(cdo.getColValue("codDieta"))){%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td colspan="3">[  <%=cdo.getColValue("codDieta")%>  ] [  <%=cdo.getColValue("descDieta")%>  ]</td>
					
				</tr>
				<%}%>
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="setDieta('<%=cdo.getColValue("codDieta")%>','<%=cdo.getColValue("codSubTipo")%>','<%=cdo.getColValue("descDieta")%>','<%=cdo.getColValue("descSubTipo")%>')">
					<td align="right"><%=cdo.getColValue("codSubTipo")%></td>
					<td><%=cdo.getColValue("descSubTipo")%></td>
					<td align="center"><%=((fp.equalsIgnoreCase("pSalida") && vDieta.contains(cdo.getColValue("codDieta")+"-"+cdo.getColValue("codSubTipo"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codDieta")+"-"+cdo.getColValue("codSubTipo"),false,false)%></td>
				</tr>
<%dieta =cdo.getColValue("codDieta");
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
				cdo.addColValue("tipo_dieta",request.getParameter("codDieta"+i));
				cdo.addColValue("descDieta",request.getParameter("descDieta"+i));
				cdo.addColValue("subtipo_dieta",request.getParameter("codSubTipo"+i));
				cdo.addColValue("descSubTipo",request.getParameter("descSubTipo"+i));
				cdo.addColValue("restrict_nutri", restrictNutri);
				cdo.addColValue("restrict_nutri_obs", restrictNutriObs);

				dietaLastLineNo++;

				String key = "";
				if (dietaLastLineNo < 10) key = "00"+dietaLastLineNo;
				else if (dietaLastLineNo < 100) key = "0"+dietaLastLineNo;
				else key = ""+dietaLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDieta.put(key, cdo);
					vDieta.add(cdo.getColValue("tipo_dieta")+"-"+cdo.getColValue("subtipo_dieta"));
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&cds="+cds+"&diagLastLineNo="+diagLastLineNo+"&medLastLineNo="+medLastLineNo+"&dietaLastLineNo="+dietaLastLineNo+"&cuidadoLastLineNo="+cuidadoLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&desc="+desc+"&exp="+exp+"&restrict_nutri="+restrictNutri+"&restrict_nutri_obs="+restrictNutriObs+"&fg="+fg);
		return;
	}
	
	
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&cds="+cds+"&diagLastLineNo="+diagLastLineNo+"&medLastLineNo="+medLastLineNo+"&dietaLastLineNo="+dietaLastLineNo+"&cuidadoLastLineNo="+cuidadoLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&desc="+desc+"&exp="+exp+"&restrict_nutri="+restrictNutri+"&restrict_nutri_obs="+restrictNutriObs+"&fg="+fg);
		return;
	}
	
	
%>
<html>
<head>
<script>
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("pSalida"))
	{
%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_plan_salida.jsp?change=1&tab=3&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagLastLineNo=<%=diagLastLineNo%>&medLastLineNo=<%=medLastLineNo%>&dietaLastLineNo=<%=dietaLastLineNo%>&cuidadoLastLineNo=<%=cuidadoLastLineNo%>&seccion=<%=seccion%>&cds=<%=cds%>&desc=<%=desc%>&exp=<%=exp%>&restrict_nutri<%=restrictNutri%>&restrict_nutri_obs=<%=restrictNutriObs%>&fg=<%=fg%>';
	
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