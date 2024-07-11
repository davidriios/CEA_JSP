
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDet = new ArrayList();
int rowCount = 0;
String sql = "";
String sqlT = "";
String sqlU = "";
String appendFilter = "";
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");

CommonDataObject cdUD = SQLMgr.getData("select (to_char(last_day(to_date('01/'||to_char("+mes+", '09')||'/'||'"+anio+"', 'DD/MM/YYYY')), 'DD')) ||' de '|| to_char(to_date(to_char("+mes+",'09'),'MM'),'MONTH', 'NLS_DATE_LANGUAGE=SPANISH') ||' de '|| to_char("+anio+") ud from dual");
		String dia = (cdUD.getColValue("ud"));


if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", 
	searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  String codigo  = ""; // variables para mantener el valor de los campos filtrados en la consulta
  String descripcion = "";
	 
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  { 
  	appendFilter += " and upper(codigo_detalle) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");  // utilizada para mantener el código por el cual se filtró
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descripcion    = request.getParameter("descripcion"); // utilizada para mantener la descripción del activo por el cual se filtró
  }
	
	sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1, nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2, nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4, nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6,  a.ue_codigo, u.DESCRIPCION, sum(d.monto_depre) totales, d.cod_ano, d.cod_mes from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" group by a.ue_codigo,a.gasto1,a.gasto2,a.gasto3,a.gasto4,a.gasto5,a.gasto6,a.compania,a.cod_flia,u.descripcion,d.cod_ano,d.cod_mes order by 1,2,3,4,5,6";

		
 	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
	
	//sqlT = "select sum(d.monto_depre) totales from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cod_ano = "+anio+" and d.cod_mes = "+mes;
	
	
	sql= "select e.cta1_depre_acum,e.cta2_depre_acum, e.cta3_depre_acum, e.cta4_depre_acum, e.cta5_depre_acum,e.cta6_depre_acum, e.descripcion desc_acum, e.cta_control||e.codigo_espec codes, sum(nvl(d.monto_depre,0)) tot_acum, sum(nvl(d.depre_acum_act,0)) tot_depre_acum, d.cod_ano, d.cod_mes from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e where a.secuencia = d.activo_sec and a.compania = d.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" group by e.cta1_depre_acum, e.cta2_depre_acum, e.cta3_depre_acum, e.cta4_depre_acum, e.cta5_depre_acum, e.cta6_depre_acum, e.descripcion, e.cta_control||e.codigo_espec, d.cod_ano, d.cod_mes";	
		alDet = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	
	//sqlU= " select sum(nvl(d.depre_acum_act,0)) total from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e where a.secuencia = d.activo_sec and a.compania = d.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and d.cod_ano = "+anio+" and d.cod_mes = "+mes;	
	
 
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
document.title = 'RESUMEN DE ACTIVO FIJO POR DEPARTAMENTO Y DEPRECIACION ACUMULADA - '+document.title;
function printList(){abrir_ventana('../activos/print_list_resumen_deprec.jsp?anio=<%=anio%>&mes=<%=mes%>&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function displayDet(k)
{
	var obj=document.getElementById('detalle'+k);
if(obj.style.display=='none')obj.style.display='';
else obj.style.display='none';
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - ACTIVO FIJO - TRANSACCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  

    <tr>
        <td align="right">&nbsp;
		<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></td>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.formEnd()%>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
	<tr>
		<td class="TableLeftBorder TableRightBorder">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tbody id="list">
					<tr class="TextHeader">
					<td colspan="10" align="center">RESUMEN DE ACTIVO FIJO POR DEPARTAMENTO  </td>
				</tr>	
				
				<tr class="TextHeader">
					<td colspan="10" align="center">Depreciación hasta el : <%=cdUD.getColValue("ud")%></td>
				</tr>	
				
				<tr class="TextRow03">
					<td>Departamento</td>
					<td colspan="6" align="center">Cuenta Gasto de Depreciación</td>
					<td align="center">&nbsp;</td>
					<td align="right">Depreciación</td>
					<td align="center">&nbsp;</td>
				</tr>				
				<%double totales =0.00;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 	
				%>
					<%=fb.hidden("cod_anio"+i,cdo.getColValue("cod_ano"))%>
					<%=fb.hidden("cod_mes"+i,cdo.getColValue("cod_mes"))%>
					<%=fb.hidden("ue_codigo"+i,cdo.getColValue("ue_codigo"))%>
					<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
					<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td width="36%"><%=cdo.getColValue("descripcion")%></td>
					<td width="6%"><%=cdo.getColValue("cta1")%></td>	
					<td width="6%"><%=cdo.getColValue("cta2")%></td>
					<td width="6%"><%=cdo.getColValue("cta3")%></td>	
					<td width="6%"><%=cdo.getColValue("cta4")%></td>
					<td width="6%"><%=cdo.getColValue("cta5")%></td>	
					<td width="6%"><%=cdo.getColValue("cta6")%></td>
					<td width="10%" align="right"> Ver<img src="../images/dwn.gif" onClick="javascript:diFrame('list','9','rs<%=i%>','900','400','0','0','1','DIVExpandRowsScroll',true,'0','../activos/list_depreciacion.jsp?anio=<%=cdo.getColValue("cod_ano")%>&mes=<%=cdo.getColValue("cod_mes")%>&unidad=<%=cdo.getColValue("ue_codigo")%>&id=<%=i%>',false)" style="cursor:pointer">
					</td>	
					<td width="10%" align="right"><%=cdo.getColValue("totales")%></td>	
					<td width="8%" align="center">&nbsp; </td>
				</tr>
				<%
				totales += Double.parseDouble(cdo.getColValue("totales"));
				}
				%>	
				<%
				{
					//CommonDataObject cdo1 = SQLMgr.getData(sqlT);
					String color1 = "TextRow00";
				%>
				<tr class="<%=color1%>">
				<td colspan="8" align="right">&nbsp;Total : &nbsp; </td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(totales)%> </td>
					<td>&nbsp; </td>
				</tr>
				<%
				}
				%>
					<tr class="TextRow00">
					<td colspan="10" align="center">&nbsp; </td>
				</tr>	
					<tr class="TextRow00">
					<td colspan="10" align="center">&nbsp; </td>
				</tr>	
				
				<tr class="TextHeader">
					<td colspan="10" align="center">&nbsp;RESUMEN DE ACTIVO FIJO POR DEPRECIACION ACUMULADA </td>
				</tr>	
				
					<tr class="TextRow03">
					<td>Nombre de la Cuenta</td>
					<td colspan="6" align="center">Cuenta Depreciación Acumulada</td>
					<td align="center">Monto Mensual</td>
					<td align="right">Depreciación Acumulada</td>
					<td align="center">&nbsp;</td>
				</tr>	
					<%double totales2=0.00;
				for (int i=0; i<alDet.size(); i++)
				{
				 CommonDataObject cdo1 = (CommonDataObject) alDet.get(i);
				 String color1 = "TextRow02";
				 if (i % 2 == 0) color1= "TextRow01";
				 	
				%>
					<%=fb.hidden("cod_aniod"+i,cdo1.getColValue("cod_ano"))%>
					<%=fb.hidden("cod_mesd"+i,cdo1.getColValue("cod_mes"))%>
					<%=fb.hidden("codes"+i,cdo1.getColValue("codes"))%>
								
				<tr id="rsd<%=i%>" class="<%=color1%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color1%>')">
					<td width="36%"><%=cdo1.getColValue("desc_acum")%></td>
					<td width="6%"><%=cdo1.getColValue("cta1_depre_acum")%></td>	
					<td width="6%"><%=cdo1.getColValue("cta2_depre_acum")%></td>
					<td width="6%"><%=cdo1.getColValue("cta3_depre_acum")%></td>	
					<td width="6%"><%=cdo1.getColValue("cta4_depre_acum")%></td>
					<td width="6%"><%=cdo1.getColValue("cta5_depre_acum")%></td>
					<td width="6%"><%=cdo1.getColValue("cta6_depre_acum")%></td>
					<td width="10%" align="right"><%=cdo1.getColValue("tot_acum")%></td>	
					<td width="10%" align="right"><%=cdo1.getColValue("tot_depre_acum")%></td>	
					<td width="8%" align="right"> Ver<img src="../images/dwn.gif" onClick="javascript:diFrame('list','9','rsd<%=i%>','900','400','0','0','1','DIVExpandRowsScroll',true,'0','../activos/list_depreciacion_acum.jsp?anio=<%=cdo1.getColValue("cod_ano")%>&mes=<%=cdo1.getColValue("cod_mes")%>&codes=<%=cdo1.getColValue("codes")%>&id=<%=i%>',false)" style="cursor:pointer">
					</td>	
				
				</tr>
				<%totales2 += Double.parseDouble(cdo1.getColValue("tot_depre_acum"));
				}
				%>	
				<%
				{
					//CommonDataObject cdo2 = SQLMgr.getData(sqlU);
				%>
				<tr class="TextRow00">
				<td colspan="8" align="right">&nbsp;Total : &nbsp; </td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(totales2)%> </td>
					<td>&nbsp; </td>
				</tr>
				<%
				}
				%>
				
				
				 </tbody>						
			</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
		</td>
	</tr>
	 <%@ page import="java.util.Hashtable" %>	
	 <%=fb.formEnd(true)%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.formEnd()%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
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
