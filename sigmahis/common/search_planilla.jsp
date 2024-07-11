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
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String filter = "";
String id = "";
String fp = request.getParameter("fp");
String anio = request.getParameter("anio");
String index = request.getParameter("index");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (request.getParameter("filter") != null) filter = request.getParameter("filter");
  if (request.getParameter("id") != null) id = request.getParameter("id");
  
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
  String descripcion="",codigo="";
  if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
  {
    appendFilter += " and upper(a.anio) like '%"+request.getParameter("anio").toUpperCase()+"%'";
    anio = request.getParameter("anio");
  }
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(a.num_planilla) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {    
    appendFilter += " and upper(b.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }

if(fp.equalsIgnoreCase("pago_ach")){
		appendFilter += " and a.estado = 'B' and b.beneficiarios = 'EM' ";
	}	else if(fp.equalsIgnoreCase("asiento_pago")){
		appendFilter += " and a.estado =  'D'";
	
	}  else if(fp.equalsIgnoreCase("pago_acr")) {
	    appendFilter += " and a.cod_planilla != 4  and (a.anio, a.cod_planilla, a.num_planilla) not in (select pa.da_anio, pa.da_cod_planilla, pa.da_num_planilla from tbl_pla_pago_acreedor pa where pa.anio =  "+anio+"  and pa.cod_compania = "+(String) session.getAttribute("_companyId")+" and pa.cod_planilla = 4 )" ;
			
	}  else if(fp.equalsIgnoreCase("planillaAjuste")){
		appendFilter += " and a.cod_planilla !=4";
		appendFilter += " and a.estado= 'D'";
	}else if(fp.trim().equals("regPlanillaAjuste"))  appendFilter += "  and (a.anio,a.cod_planilla,a.num_planilla) in (select pa.anio, pa.cod_planilla, pa.num_planilla from tbl_pla_pago_ajuste pa where pa.estado = 'PE' and  pa.vobo_estado = 'S' and  pa.actualizar = 'S' ) ";
	else if(fp.trim().equals("planillaAjusteRep"))  appendFilter += "  and (a.anio,a.cod_planilla,a.num_planilla) in (select pa.anio, pa.cod_planilla, pa.num_planilla from tbl_pla_pago_ajuste pa where pa.estado = 'AC' and  pa.vobo_estado = 'S' and  pa.actualizar = 'S' ) ";

	sql = "select a.anio, a.cod_planilla as codPlanilla, decode(a.estado,'B','Borrador','D','Definitiva','A','Anulada') as descEstado, a.num_planilla as numPlanilla, a.periodo, to_char(a.fecha_pago,'dd-mm-yyyy') as fechaPago, to_char(a.fecha_inicial,'dd/mm/yyyy') as fechaInical, to_char(a.fecha_final,'dd/mm/yyyy') as fechaFinal, a.estado, ltrim(b.nombre,18)||' del '||a.fecha_inicial||' al '||a.fecha_final as descripcion, b.nombre as nombre, a.cod_compania compania,'_'||decode(a.periodo_mes,'1','I','2','II',a.periodo_mes)||'_'||to_char (to_date (to_char(a.fecha_inicial,'DD/MM/YYYY'),'DD/MM/YYYY'), 'MONTH','NLS_DATE_LANGUAGE=SPANISH') desc_mes from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla  and a.cod_compania=b.compania"+appendFilter+ " and a.cod_compania = "+(String) session.getAttribute("_companyId") +" order by a.cod_planilla, a.anio desc";
	
	
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");


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
document.title = 'Planillas - '+document.title;

function returnValue(anio,cod,num,desc,nombreFile)
{
<%
 if(fp.equalsIgnoreCase("pago_acr"))
{
%>
window.opener.document.formCal.anioPlanilla.value=anio;
window.opener.document.formCal.codPlanilla.value=cod; 
window.opener.document.formCal.numPlanilla.value=num; 
window.opener.document.formCal.descPlanilla.value=desc; 
window.close();
<%
} else if(fp.equalsIgnoreCase("planillaAjuste"))
{
%>
window.opener.document.form0.anio.value=anio;
window.opener.document.form0.codPlanilla.value=cod; 
window.opener.document.form0.noPlanilla.value=num; 
//window.opener.document.formCal.descPlanilla.value=desc; 
window.close();
<%
} else if(fp.equalsIgnoreCase("planillaAjusteRep"))
{
%>
window.opener.document.formUnidad.anio.value=anio;
window.opener.document.formUnidad.codPlanilla.value=cod; 
window.opener.document.formUnidad.numPlanilla.value=num; 
window.opener.document.formUnidad.descPlanilla.value=desc; 
window.close();
<%
} 
 else if(fp.equalsIgnoreCase("regPlanillaAjuste"))
{
%>
window.opener.document.formCal.anioOrg.value=anio;
window.opener.document.formCal.codPlaOrg.value=cod; 
window.opener.document.formCal.numplaOrg.value=num; 
window.opener.document.formCal.descPlanillaOrg.value=desc; 
window.close();
<%
}
else
{
%>
window.opener.document.form0.cod.value=cod; 
window.opener.document.form0.num.value=num; 
window.opener.document.form0.anio.value=anio;
if(window.opener.document.form0.nombreFile)window.opener.document.form0.nombreFile.value=nombreFile; 
<%if(fp.equalsIgnoreCase("pago_ach")){%>window.opener.calculo();<%}%>
window.close();
<%
}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Planilla - PLANILLAS GENERADAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">	                    
					<%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart(true)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
				    <td width="50%"><cellbytelabel>A&ntilde;o</cellbytelabel>:<%=fb.intBox("anio","",false,false,false,10)%> <cellbytelabel>Num. Planilla</cellbytelabel>					
					<%=fb.intBox("codigo","",false,false,false,40)%>
					</td>
				   <td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd(true)%>		
			    </tr>
			</table>
		</td>
	</tr>
    
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("index",index)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
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
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("index",index)%>
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
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
            <%=fb.formStart(true)%>
			
				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="10%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
					<td width="15%"><cellbytelabel>C&oacute;digo de Planilla</cellbytelabel></td>
					<td width="15%"><cellbytelabel>N&uacute;mero de Planilla</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Fecha de Pago</cellbytelabel></td>
				</tr>				
				<%
				String nombre="";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if (!nombre.equalsIgnoreCase(cdo.getColValue("nombre")))
				 {
				%>
				  
			<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
            <td colspan="5" class="TitulosdeTablas"> [<%=cdo.getColValue("codPlanilla")%>] - <%=cdo.getColValue("nombre")%></td>
            </tr>
				<%
				   }
				%>
					
				<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%><%=fb.hidden("codPlanilla"+i,cdo.getColValue("codPlanilla"))%><%=fb.hidden("numPlanilla"+i,cdo.getColValue("numPlanilla"))%><%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codPlanilla")%>','<%=cdo.getColValue("numPlanilla")%>','<%=cdo.getColValue("descripcion")%>','<%=cdo.getColValue("desc_mes")%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td align="center"><%=cdo.getColValue("anio")%></td>
					<td align="center"><%=cdo.getColValue("codPlanilla")%></td>
					<td align="center"><%=cdo.getColValue("numPlanilla")%></td>
					<td><%=cdo.getColValue("descripcion")%>-<%=cdo.getColValue("desc_mes")%></td>
					<td align="center">&nbsp;<a href="javascript:returnValue('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codPlanilla")%>','<%=cdo.getColValue("numPlanilla")%>','<%=cdo.getColValue("descripcion")%>','<%=cdo.getColValue("desc_mes")%>')" class="Link00"><%=cdo.getColValue("fechaPago")%></a></td>
															
				</tr>
				<%
					nombre = cdo.getColValue("nombre");
				}
				%>	
			<%=fb.formEnd(true)%>						
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("index",index)%>
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
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("index",index)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>				</tr>
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