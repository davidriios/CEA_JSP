<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.residencial.DetallePlan"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iHab" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vHab" scope="session" class="java.util.Vector" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500021") || SecMgr.checkAccess(session.getId(),"500022") || SecMgr.checkAccess(session.getId(),"500023") || SecMgr.checkAccess(session.getId(),"500024"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String modeAdm = request.getParameter("modeAdm");
String id = request.getParameter("id");
int pLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("pLastLineNo") != null) pLastLineNo = Integer.parseInt(request.getParameter("pLastLineNo"));

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

  if (request.getParameter("tipoHabit") != null)
  {
		appendFilter += " and upper(a.tipo_habit) like '%"+request.getParameter("tipoHabit").toUpperCase()+"%'";
    searchOn = "a.tipo_habit";
    searchVal = request.getParameter("tipoHabit");
    searchType = "1";
    searchDisp = "Tipo Habitación";
  }
  else if (request.getParameter("tipoHabitDesc") != null)
  {
		appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("tipoHabitDesc").toUpperCase()+"%'";
    searchOn = "b.descripcion";
    searchVal = request.getParameter("tipoHabitDesc");
    searchType = "1";
    searchDisp = "Descripcion Tipo Habitación";
  }
  else if (request.getParameter("codigoPlan") != null)
  {
		appendFilter += " and upper(a.codigo_plan) like '%"+request.getParameter("codigoPlan").toUpperCase()+"%'";
    searchOn = "a.codigo_plan";
    searchVal = request.getParameter("codigoPLan");
    searchType = "1";
    searchDisp = "Código Plan";
  }
  else if (request.getParameter("codigoPlanDesc") != null)
  {
		appendFilter += " and upper(c.descripcion) like '%"+request.getParameter("codigoPlanDesc").toUpperCase()+"%'";
    searchOn = "c.descripcion";
    searchVal = request.getParameter("codigoPlanDesc");
    searchType = "1";
    searchDisp = "Descripción de Código de Planes";
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

	if (fp.equalsIgnoreCase("tipoHabit"))
	{
		sql = "SELECT a.tipo_habit as tipoHabit, b.descripcion as tipoHabitDesc, a.codigo_plan as codigoPlan, c.descripcion as codigoPlanDesc, a.precio, a.codigo_plan||'-'||a.tipo_habit as planHabit FROM tbl_res_plan_habit a, tbl_res_tipo_habitacion b, tbl_res_planes c WHERE a.tipo_habit=b.secuencia(+) and a.codigo_plan=c.codigo(+) "+appendFilter+" ORDER BY a.tipo_habit, b.descripcion";
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_res_plan_habit a, tbl_res_tipo_habitacion b, tbl_res_planes c WHERE a.tipo_habit=b.secuencia(+) and a.codigo_plan=c.codigo(+) "+appendFilter);
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
document.title = 'Precios x Planes x Habitación - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PRECIOS X PLANES X HABITACIÓN"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("modeAdm",modeAdm)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
					<td width="20%"><cellbytelabel>C&oacute;d. Tipo</cellbytelabel>
					<%=fb.textBox("tipoHabit","",false,false,false,10)%>
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
					<%=fb.hidden("modeAdm",modeAdm)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
					<td width="30%"><cellbytelabel>Desc</cellbytelabel>.
					<%=fb.textBox("tipoHabitDesc","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>					
					<%
					fb = new FormBean("search03",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("modeAdm",modeAdm)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
					<td width="20%"><cellbytelabel>C&oacute;d. Plan</cellbytelabel>
					<%=fb.textBox("codigoPlan","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
					<%
					fb = new FormBean("search04",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("modeAdm",modeAdm)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
					<td width="30%"><cellbytelabel>Desc</cellbytelabel>.
					<%=fb.textBox("codigoPlanDesc","",false,false,false,30)%>
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
fb = new FormBean("planesHabit",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("modeAdm",modeAdm)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
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
					<td width="10%"><cellbytelabel>C&oacute;d. Plan</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Desc. Plan</cellbytelabel></td>
					<td width="10%"><cellbytelabel>C&oacute;d. Tipo</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Desc. Tipo Hab</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Precios x Planes x Iipos de Habitación listados!")%></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
				<%=fb.hidden("codigoPlan"+i,cdo.getColValue("codigoPlan"))%>
				<%=fb.hidden("codigoPlanDesc"+i,cdo.getColValue("codigoPlanDesc"))%>
				<%=fb.hidden("tipoHabit"+i,cdo.getColValue("tipoHabit"))%>
				<%=fb.hidden("tipoHabitDesc"+i,cdo.getColValue("tipoHabitDesc"))%>
				<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
				<%=fb.hidden("planHabit"+i,cdo.getColValue("planHabit"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigoPlan")%></td>
					<td><%=cdo.getColValue("codigoPlanDesc")%></td>
					<td><%=cdo.getColValue("tipoHabit")%></td>
					<td><%=cdo.getColValue("tipoHabitDesc")%></td>
					<td><%=cdo.getColValue("precio")%></td>
					<td align="center"><%=(vHab.contains(cdo.getColValue("planHabit")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("planHabit"),false,false)%></td>
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
	String key = "";
	
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			DetallePlan pl = new DetallePlan();
            
			pl.setPlanes(request.getParameter("codigoPlan"+i));
			pl.setPlanesDesc(request.getParameter("codigoPlanDesc"+i));
			pl.setTipoHab(request.getParameter("tipoHabit"+i));
			pl.setTipoHabDesc(request.getParameter("tipoHabitDesc"+i));
			pl.setPrecio(request.getParameter("precio"+i));		
			pl.setPlanHabit(request.getParameter("planHabit"+i));		

			pLastLineNo++;
			
			pl.setSecuencia(""+pLastLineNo);
			
			if (pLastLineNo < 10) key = "00"+pLastLineNo;
			else if (pLastLineNo < 100) key = "0"+pLastLineNo;
			else key = ""+pLastLineNo;
			
			pl.setKey(key);
	
			try
			{
				iHab.put(key,pl);
				vHab.add(request.getParameter("planHabit"+i));				
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&modeAdm="+modeAdm+"&id="+id+"&pLastLineNo="+pLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&modeAdm="+modeAdm+"&id="+id+"&pLastLineNo="+pLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	if (fp.equalsIgnoreCase("tipoHabit"))
	{
%>
	window.opener.location = '../residencial/planesresidentes_config.jsp?change=1&modeAdm=<%=modeAdm%>&pLastLineNo=<%=pLastLineNo%>';
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