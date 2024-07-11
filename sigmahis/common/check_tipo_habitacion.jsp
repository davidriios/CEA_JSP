<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCobDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExclDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclDet" scope="session" class="java.util.Vector" />
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
String mode = request.getParameter("mode");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";

//convenio_cobertura_detalle, pm_convenio_cobertura_detalle, convenio_exclusion_detalle, pm_convenio_exclusion_detalle
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
String tipoCE = request.getParameter("tipoCE");
String ce = request.getParameter("ce");
int ceDetLastLineNo = 0;
String tipoServicio = request.getParameter("tipoServicio");
String centroServicio = request.getParameter("centroServicio");
String tipoCds = request.getParameter("tipoCds");
String inventarioSino = request.getParameter("inventarioSino");

if (empresa == null) empresa = "";
if (secuencia == null) secuencia = "";
if (tipoPoliza == null) tipoPoliza = "";
if (tipoPlan == null) tipoPlan = "";
if (planNo == null) planNo = "";
if (categoriaAdm == null) categoriaAdm = "";
if (tipoAdm == null) tipoAdm = "";
if (clasifAdm == null) clasifAdm = "";
if (tipoCE == null) tipoCE = "";
if (ce == null) ce = "";
if (request.getParameter("ceDetLastLineNo") != null) ceDetLastLineNo = Integer.parseInt(request.getParameter("ceDetLastLineNo"));
if (tipoServicio == null) tipoServicio = "";
if (centroServicio == null) centroServicio = "";
if (tipoCds == null) tipoCds = "";
if (inventarioSino == null) inventarioSino = "";

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

  if (request.getParameter("codigo") != null)
  {
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "a.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
		appendFilter += " and upper(a.descripcion||' - '||to_char(a.precio,'$9,990.00')) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "a.descripcion||' - '||to_char(a.precio,'$9,990.00')";
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

	if (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") || fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
		sql = "select distinct a.codigo, a.descripcion||' - '||to_char(a.precio,'$9,990.00') as descripcion, a.precio, decode(a.categoria_hab,'P','Privada','Q','Quirófano','S','Semiprivada','C','Compartida','T','Suite','E','Económica','O','Otros') as categoria_hab, a.tipo_valor, a.compania from tbl_sal_tipo_habitacion a, tbl_sal_habitacion b, tbl_sal_cama c where a.compania=c.compania and a.codigo=c.tipo_hab and b.compania=c.compania and b.codigo=c.habitacion and a.estatus='A' and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by 2";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from (select distinct a.codigo, a.descripcion||' - '||to_char(a.precio,'$9,990.00') as descripcion, a.precio, a.categoria_hab, a.tipo_valor, a.compania from tbl_sal_tipo_habitacion a, tbl_sal_habitacion b, tbl_sal_cama c where a.compania=c.compania and a.codigo=c.tipo_hab and b.compania=c.compania and b.codigo=c.habitacion and a.estatus='A' and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+")");
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
document.title = 'Tipos de Habitación - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE TIPOS DE HABITACION"></jsp:param>
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
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("secuencia",secuencia)%>
					<%=fb.hidden("tipoPoliza",tipoPoliza)%>
					<%=fb.hidden("tipoPlan",tipoPlan)%>
					<%=fb.hidden("planNo",planNo)%>
					<%=fb.hidden("categoriaAdm",categoriaAdm)%>
					<%=fb.hidden("tipoAdm",tipoAdm)%>
					<%=fb.hidden("clasifAdm",clasifAdm)%>
					<%=fb.hidden("tipoCE",tipoCE)%>
					<%=fb.hidden("ce",ce)%>
					<%=fb.hidden("tipoServicio",tipoServicio)%>
					<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
					<%=fb.hidden("centroServicio",centroServicio)%>
					<%=fb.hidden("tipoCds",tipoCds)%>
					<%=fb.hidden("inventarioSino",inventarioSino)%>
					<td width="50%"><cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,30)%>
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
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("secuencia",secuencia)%>
					<%=fb.hidden("tipoPoliza",tipoPoliza)%>
					<%=fb.hidden("tipoPlan",tipoPlan)%>
					<%=fb.hidden("planNo",planNo)%>
					<%=fb.hidden("categoriaAdm",categoriaAdm)%>
					<%=fb.hidden("tipoAdm",tipoAdm)%>
					<%=fb.hidden("clasifAdm",clasifAdm)%>
					<%=fb.hidden("tipoCE",tipoCE)%>
					<%=fb.hidden("ce",ce)%>
					<%=fb.hidden("tipoServicio",tipoServicio)%>
					<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
					<%=fb.hidden("centroServicio",centroServicio)%>
					<%=fb.hidden("tipoCds",tipoCds)%>
					<%=fb.hidden("inventarioSino",inventarioSino)%>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
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
fb = new FormBean("tipohabitacion",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("tipoCE",tipoCE)%>
<%=fb.hidden("ce",ce)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
<%=fb.hidden("centroServicio",centroServicio)%>
<%=fb.hidden("tipoCds",tipoCds)%>
<%=fb.hidden("inventarioSino",inventarioSino)%>
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
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
					<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los tipos de habitaciones listados!")%></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=cdo.getColValue("categoria_hab")%></td>
					<td align="center"><%=(( ( fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle")) && vCobDet.contains(cdo.getColValue("codigo"))) || ( ( fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle")) && vExclDet.contains(cdo.getColValue("codigo"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%></td>
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
	if (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalle cd = new CoberturaDetalle();
	
				cd.setSecuencia("0");
				cd.setCompania(request.getParameter("compania"+i));
				cd.setTipoHabitacion(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));
	
				ceDetLastLineNo++;
	
				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				cd.setKey(key);
		
				try
				{
					iCobDet.put(key, cd);
					vCobDet.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_detalle, pm_convenio_cobertura_detalle
	else if (fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				ExclusionDetalle ed = new ExclusionDetalle();
	
				ed.setSecuencia("0");
				ed.setCompania(request.getParameter("compania"+i));
				ed.setTipoHabitacion(request.getParameter("codigo"+i));
				ed.setCodigo(request.getParameter("codigo"+i));
				ed.setDescripcion(request.getParameter("descripcion"+i));
	
				ceDetLastLineNo++;
	
				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				ed.setKey(key);
		
				try
				{
					iExclDet.put(key, ed);
					vExclDet.add(ed.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_exclusion_detalle, pm_convenio_exclusion_detalle

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	if (fp.equalsIgnoreCase("convenio_cobertura_detalle"))
	{
%>
	window.opener.location = '../convenio/convenio_cobertura_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_cobertura_detalle"))
	{
%>	
	window.opener.location = '../planmedico/pm_convenio_cobertura_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%	
	}
	else if (fp.equalsIgnoreCase("convenio_exclusion_detalle"))
	{
%>
	window.opener.location = '../convenio/convenio_exclusion_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
%>	
	window.opener.location = '../planmedico/pm_convenio_exclusion_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
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