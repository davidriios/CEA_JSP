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
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String fp= request.getParameter("fp");
String index = request.getParameter("index");
String nt = request.getParameter("nt");
String fecha = request.getParameter("fecha");
//int rowCount = 0;
int iconHeight = 48;
int iconWidth = 48;
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
    appendFilter += " and upper(f.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "f.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
	
  else if (request.getParameter("paciente") != null)
  {
     appendFilter += " and upper(m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||decode(m.primer_apellido,null,'',' '||m.primer_apellido)||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada))) like '%"+request.getParameter("paciente").toUpperCase()+"%'";
		 
    searchOn = "m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||decode(m.primer_apellido,null,'',' '||m.primer_apellido)||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada))";
    searchVal = request.getParameter("paciente");
    searchType = "1";
    searchDisp = "nombre";
  }
	
	else if (request.getParameter("fecha") != null)
  {
    appendFilter += " and to_date(to_char(f.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha+"','dd/mm/yyyy')";
    searchOn = "f.fecha";
    searchValFromDate = fecha;
    searchType = "1";
    searchDisp = "Fecha de Factura";
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
sql="select e.nombre as emp_nombre,m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE||' '||DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO,m.APELLIDO_DE_CASADA)as pac_nombre,decode(f.facturar_a,'P', 'PACIENTE', 'E','EMPRESA', 'O','OTROS') as fact_a, f.codigo,f.facturar_a, to_char(f.fecha,'dd/mm/yyyy')fecha, f.monto_total, f.admi_secuencia admision,to_char(f.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento,f.admi_codigo_paciente as paciente, f.numero_factura, f.pac_id, coalesce(e.nombre, m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE||''||DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO,m.APELLIDO_DE_CASADA))as descripcion, m.PROVINCIA||'-'||m.SIGLA||'-'||m.TOMO||'-'||m.ASIENTO||'-'||m.D_CEDULA cedula,decode(f.estatus,'P','PENDIENTE','C','CANCELADA') descEstatus, f.estatus from tbl_fac_factura f,tbl_adm_empresa e,tbl_adm_paciente m where f.cod_empresa= e.codigo(+) and f.pac_id= m.pac_id(+) and  f.estatus in('P','C') and f.facturar_a in ('P','E') and f.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by f.fecha,f.facturar_a desc";	

al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
   rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Facturas - '+document.title;

function setFactura(k)
{
		
		window.opener.document.form0.codigo.value 	= eval('document.form0.codigo'+k).value;
		window.opener.document.form0.codPac.value 	= eval('document.form0.paciente'+k).value;
		window.opener.document.form0.pac_id.value 					= eval('document.form0.pac_id'+k).value;
		window.opener.document.form0.fecha_nacimiento.value	= eval('document.form0.fecha_nacimiento'+k).value;
		window.opener.document.form0.nombre.value 	= eval('document.form0.nombre_paciente'+k).value;
		window.opener.document.form0.fecha.value		= eval('document.form0.fecha'+k).value;
		window.opener.document.form0.admision.value		= eval('document.form0.admision'+k).value;
		window.opener.document.form0.cedula.value		= eval('document.form0.cedula'+k).value;
		window.opener.document.form0.total.value					= eval('document.form0.total'+k).value;
		
		if(eval('document.form0.estatus'+k).value =="P")
		window.opener.document.form0.status[0].checked = true ;
		else 
		window.opener.document.form0.status[1].checked = true ;

		
		window.close();

}
function setIndex(k)
{
  document.form0.index.value=k;
  checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
		
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nt",nt)%>
				<td width="50%">&nbsp;<cellbytelabel>No. Factura</cellbytelabel>
							<%=fb.textBox("codigo","",false,false,false,20,null,null,null)%>
							<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>	
				
				<%
				fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nt",nt)%>
				
				<td width="50%">&nbsp;<cellbytelabel>Fecha</cellbytelabel> <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="" />
								</jsp:include> 
							<%=fb.submit("go","Ir")%>	
				</td>
				
				
				
				<%=fb.formEnd()%>	
			</tr>
			<tr class="TextFilter">		
				<%
				fb = new FormBean("search04",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nt",nt)%>
				<td colspan="2">&nbsp;<cellbytelabel>Paciente</cellbytelabel>
							<%=fb.textBox("paciente","",false,false,false,60,null,null,null)%>
							<%=fb.submit("go","Ir")%>	
				</td>
				<%=fb.formEnd()%>	
			</tr>
			
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	
</table>	
<tr><td colspan="2">&nbsp;</td></tr>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("nt",nt)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					
<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("nt",nt)%>
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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">
	<tr class="TextHeader">
	  	<td width="10%">&nbsp;<cellbytelabel>No. Factura</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>Estado</cellbytelabel>.</td>	
		<td width="10%">&nbsp;<cellbytelabel>Codigo Pac</cellbytelabel>.</td>	
	  	<td width="8%">&nbsp;<cellbytelabel>Fecha Nacimiento</cellbytelabel></td>	
		<td width="5%">&nbsp;<cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
		<td width="15%">&nbsp;<cellbytelabel>C&eacute;dula</cellbytelabel></td>
		<td width="32%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="10%" align="right"><cellbytelabel>Monto</cellbytelabel></td>	
		
	</tr>
	
	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
	<%=fb.hidden("paciente"+i,cdo.getColValue("paciente"))%>
	<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
	<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
	<%=fb.hidden("nombre_paciente"+i,cdo.getColValue("pac_nombre"))%>
	<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
	<%=fb.hidden("total"+i,cdo.getColValue("monto_total"))%>
	<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
	<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>


	
	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setFactura(<%=i%>)" style="text-decoration:none; cursor:pointer">
		<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td>&nbsp;<%=cdo.getColValue("descEstatus")%></td>
		<td>&nbsp;<%=cdo.getColValue("paciente")%></td>
		<td>&nbsp;<%=cdo.getColValue("fecha_nacimiento")%></td>
		<td>&nbsp;<%=cdo.getColValue("admision")%></td>
		<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
		<td>&nbsp;<%=cdo.getColValue("pac_nombre")%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))%></td>
	</tr>
	<%
	}
	%>						
					
</table>
<%=fb.formEnd()%>			
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table> 

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("nt",nt)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("nt",nt)%>
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