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
/*------------------------------------------------------------------------------------------------*/
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
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
String codigo = request.getParameter("codigo");
String key = "";

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

int iconHeight = 20;
int iconWidth = 20;

if(codigo==null) codigo = "";

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

  if (!codigo.trim().equals("")){
    sbFilter.append(" and a.fac_codigo ='");
		sbFilter.append(codigo);
		sbFilter.append("'");
  }
  
		if(!codigo.equals("")){
		sbSql.append(" select a.secuencia, decode(a.tipo, 'H', 'MEDICO', 'E', 'EMPRESA', 'C', 'CARGO',null,'CO-PAGO') tipo_desc, a.centro_servicio, decode(a.tipo, 'H', a.med_codigo, 'E', a.empre_codigo, 'C', a.centro_servicio) codigoCs, decode(a.tipo, 'H', (select primer_apellido||' '||segundo_apellido||' '||apellido_de_casada ||' '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo), 'E', (select nombre from tbl_adm_empresa where codigo = a.empre_codigo), 'C', (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio)) descripcion, a.monto, to_char(a.fecha, 'dd/mm/yyyy') fecha, decode(a.pagado, 'S', 'PAGADO', 'N', 'POR PAGAR') pagado, a.num_cheque, decode(a.distribucion, 'A', 'Automatica', 'M', 'Manual') distribucion, a.tipo_cobertura,a.fac_codigo,a.tran_anio anio,a.codigo_transaccion codigo,  a.secuencia_pago from tbl_cja_distribuir_pago a where a.compania = ");
		 sbSql.append(session.getAttribute("_companyId"));
  		 sbSql.append(sbFilter.toString());
		 sbSql.append(" and a.monto <> 0");
		 al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
 		 rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturas - '+document.title;
function corregir(secuencia, secuencia_pago, codigo,anio,factura){
showPopWin('../common/run_process.jsp?fp=corregir_dist&actType=50&docType=DIST&docId='+codigo+'&docNo='+secuencia_pago+'&anio='+anio+'&codigo='+secuencia+'&factura='+factura+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.20,null,null,'')
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td><cellbytelabel>No. Factura</cellbytelabel>
							<%=fb.textBox("codigo",codigo,false,false,false,12,null,null,null)%>
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
					<%=fb.hidden("codigo",""+codigo)%>
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
					<%=fb.hidden("codigo",""+codigo)%>
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
	<div id="admisionMain" width="100%" style="overflow:scroll;position:relative;height:300">
	<div id="admision" width="98%" style="overflow;position:absolute">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode","")%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg","")%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 

<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="10"><cellbytelabel>Distribuci&oacute;n Pago</cellbytelabel>:</td>
          <td align="center">&nbsp;</td>
        </tr>
        <tr class="TextHeader">
          <td width="8%" align="center"><cellbytelabel>Secuencia</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Tipo</cellbytelabel></td>
          <td width="31%" align="center" colspan="2"><cellbytelabel>Distribuido A</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Pagado por CXP</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Num. Cheque</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Tipo de Dist.</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Tipo Cobert.</cellbytelabel></td>
		  <td width="5%" align="center">&nbsp;</td>
        </tr>
        <%
				key = "";
				double monto_total = 0.00;
				for (int i=0; i<al.size(); i++){
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					monto_total += Double.parseDouble(cdo.getColValue("monto"));

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("monto"+i,cdo.getColValue("monto"))%> 
        <tr class="<%=color%>" >
          <td align="center"><%=cdo.getColValue("secuencia")%></td>
          <td align="center"><%=cdo.getColValue("tipo_desc")%></td>
          <td align="center"><%=cdo.getColValue("centro_servicio")%></td>
          <td align="center"><%=cdo.getColValue("descripcion")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;&nbsp; </td>
          <td align="center"><%=cdo.getColValue("fecha")%></td>
          <td align="center"><%=cdo.getColValue("pagado")%></td>
          <td align="center"><%=cdo.getColValue("num_cheque")%></td>
          <td align="center"><%=cdo.getColValue("distribucion")%></td>
          <td align="center"><%=cdo.getColValue("tipo_cobertura")%></td>
		  <td align="center"><!--<%/*if (UserDet.getUserProfile().contains("0")){*/%><authtype type='50'><a href="javascript:corregir('<%=cdo.getColValue("secuencia")%>','<%=cdo.getColValue("secuencia_pago")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("fac_codigo")%>')"><img id="imgCorregir<%=i%>" height="20" width="20" class="ImageBorder" src="../images/actualizar.gif"></a></authtype><%//}%>-->
	  </td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="4" align="right">&nbsp;<cellbytelabel>Monto Total</cellbytelabel></td>
          <td align="right"><%=fb.decBox("monto_total",CmnMgr.getFormattedDecimal(monto_total),false,false,true,10, 8.2,"text10",null,"","",false,"")%>&nbsp;&nbsp;</td>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+al.size())%> 
      </table></td>
  </tr>
</table>
<%=fb.formEnd(true)%>
</div>
</div>
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
					<%=fb.hidden("codigo",""+codigo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

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
					<%=fb.hidden("codigo",""+codigo)%>
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