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
<%
/**
==============================================================================================
==============================================================================================
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
String date = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String tipoPla = request.getParameter("tipoPla");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
//if (tipoPla==null ) throw new Exception("El Tipo de Planilla no es válida. Por favor intente nuevamente!");

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
 String descripcion ="",periodo="";
 //if (fp.equals("pago_empleado")) appendFilter += " and b.beneficiarios = 'EM' ";

  if (request.getParameter("tipoPla") != null && !request.getParameter("tipoPla").trim().equals(""))
  {
    appendFilter += " and a.tipopla ="+request.getParameter("tipoPla");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(b.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
   if (request.getParameter("periodo") != null && !request.getParameter("periodo").trim().equals(""))
  {
    appendFilter += " and a.periodo ="+request.getParameter("periodo");
	periodo =request.getParameter("periodo");
  }

 date = CmnMgr.getCurrentDate("dd/mm/yyyy");

		sql = "SELECT a.tipopla, a.periodo, to_char(a.fecha_inicial,'dd/mm/yyyy') as fechaInicial, to_char(a.fecha_final,'dd/mm/yyyy') as fechaFinal, to_char(a.trans_desde,'dd/mm/yyyy') as transDesde, to_char(a.trans_hasta,'dd/mm/yyyy') as transHasta, to_char(a.fecha_cierre,'dd/mm/yyyy') as fechaCierre, to_char(a.cierre_cambio_turno,'dd/mm/yyyy') as cambioTurno, b.descripcion nombre, to_number(to_char(a.fecha_inicial,'yyyy')) as anio, '' tipo FROM tbl_pla_calendario a, tbl_pla_tipo_planilla b WHERE  a.tipopla = b.tipopla "+appendFilter+" order by a.tipopla, a.periodo, a.fecha_inicial desc";
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
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
document.title = 'Calendario de Pago - '+document.title;

function setCal(i)
{
<%
if (fp.equalsIgnoreCase("pago_empleado"))
{
%>	//alert('deepak'+<%=index%>);
		window.opener.document.formCal.fechaInicial.value = eval('document.formCal.fechaInicial'+i).value;
		window.opener.document.formCal.fechaFinal.value = eval('document.formCal.fechaFinal'+i).value;
	    window.opener.document.formCal.transDesde.value = eval('document.formCal.transDesde'+i).value;
		window.opener.document.formCal.transHasta.value = eval('document.formCal.transHasta'+i).value;
		window.opener.document.formCal.periodo.value = eval('document.formCal.periodo'+i).value;
		window.opener.document.formCal.fechaFin.value = eval('document.formCal.fechaCierre'+i).value;
		//window.opener.document.formCal.tipoPla.value = eval('document.formCal.tipopla'+i).value;
		window.opener.document.formCal.numPla.value = eval('document.formCal.periodo'+i).value;

	<%
} else if (fp.equalsIgnoreCase("marcacion"))
{
%>
//alert('codigo'+<%=tipoPla%>);
		window.opener.document.form1.fecha_desde.value = eval('document.formCal.transDesde'+i).value;
		window.opener.document.form1.fecha_hasta.value = eval('document.formCal.transHasta'+i).value;
<%
}
%>
		window.close();
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CALENDARIO DE PAGO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">		
					<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("tipoPla",""+tipoPla)%>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel> 
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					</td>
					<td width="50%"><cellbytelabel>Periodo</cellbytelabel>					
					<%=fb.textBox("periodo","",false,false,false,5)%>
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
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("tipoPla",""+tipoPla)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("periodo",""+periodo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("tipoPla",""+tipoPla)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("periodo",""+periodo)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>	
		
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel>Tipo</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Periodo</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Planilla</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Fecha Inicial</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Fecha Final</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Fecha de Cierre</cellbytelabel></td>
				</tr>
				<%fb = new FormBean("formCal",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%
				String descPla = "";
				for (int i=0; i<al.size(); i++)
				{
					
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
					
					if (!descPla.equalsIgnoreCase(cdo.getColValue("nombre")))
			 {
			 %>
			<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
            <td colspan="6" class="TitulosdeTablas"> [<%=cdo.getColValue("tipopla")%>] - <%=cdo.getColValue("nombre")%></td>
            </tr>
			 <%
			 }
			 %>
					
					
						
				
				<%=fb.hidden("tipopla"+i,cdo.getColValue("tipopla"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("fechaInicial"+i,cdo.getColValue("fechaInicial"))%>
				<%=fb.hidden("fechaFinal"+i,cdo.getColValue("fechaFinal"))%>
				<%=fb.hidden("transDesde"+i,cdo.getColValue("transDesde"))%>
				<%=fb.hidden("transHasta"+i,cdo.getColValue("transHasta"))%>
				<%=fb.hidden("fechaCierre"+i,cdo.getColValue("fechaCierre"))%>
				<%=fb.hidden("periodo"+i,cdo.getColValue("periodo"))%>
		
				
				
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setCal(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("tipopla")%></td>
					<td><%=cdo.getColValue("periodo")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("fechaInicial")%></td>
					<td><%=cdo.getColValue("fechaFinal")%></td>
					<td><%=cdo.getColValue("fechaCierre")%></td>
				</tr>
				<%
	         descPla = cdo.getColValue("nombre");
            }
            %>
				
				<%=fb.formEnd()%>						
          </table>	

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	  </td>
   </tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("tipoPla",""+tipoPla)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("periodo",""+periodo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("tipoPla",""+tipoPla)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("periodo",""+periodo)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
	