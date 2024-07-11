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
String pase= request.getParameter("pase");

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
  String codigo="",nombre="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(a.recibo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("recibo") != null && !request.getParameter("recibo").trim().equals(""))
  {
    appendFilter += " and upper(a.recibo) like '%"+request.getParameter("recibo").toUpperCase()+"%'";
    codigo = request.getParameter("recibo");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(a.nombre) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }


   if (!appendFilter.trim().equals(""))
   {
sql="select a.pago_total as pagoTotal, a.recibo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo_cliente as tipoCliente, a.codigo, a.anio, nvl(a.nombre,' ') as nombre, (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo) as aplicado, nvl((select  nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')),0)as ajustado, 0 as porAplicar ,to_char(a.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento,a.pac_id,a.codigo_paciente,a.ref_type,a.ref_id from tbl_cja_transaccion_pago a where  a.compania ="+(String) session.getAttribute("_companyId")+" and nvl(a.rec_status,'A') <> 'I' and nvl(a.anulada,'N') ='N' "+appendFilter;

al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
   rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Lista de Recibos - '+document.title;
function returnValue(k)
{
var pase='<%=pase%>';
var total = parseFloat(eval('document.form0.pagoTotal'+k).value);
var aplicado =  parseFloat(eval('document.form0.aplicado'+k).value);
var ajuste =  parseFloat(eval('document.form0.ajustado'+k).value);
var porAplicar =parseFloat(eval('document.form0.porAplicar'+k).value);
var t = total-(aplicado+ajuste);
//CBMSG.warning('monto total = '+total+' monto aplicado ='+aplicado+' monto distribuido ='+dist+' monto ajustado = '+ajuste+'  ');
if(pase=="N")
{
	if(porAplicar >0)
	{
	window.opener.document.form0.recibo.value=eval('document.form0.codigo'+k).value;
	window.opener.document.form0.total.value=(porAplicar/100).toFixed(2);
	window.opener.document.form0.totalRecibo.value=(porAplicar/100).toFixed(2);
	window.opener.document.form0.fecha_nacimiento.value=eval('document.form0.fecha_nacimiento'+k).value;
	window.opener.document.form0.pac_id.value=eval('document.form0.pac_id'+k).value;
	window.opener.document.form0.codigo_paciente.value=eval('document.form0.codigo_paciente'+k).value;
	window.opener.document.form0.ref_type.value=eval('document.form0.ref_type'+k).value;
	window.opener.document.form0.ref_id.value=eval('document.form0.ref_id'+k).value;
	window.close();
	}
	else {
	CBMSG.warning('NO PUEDE HACER EL AJUSTE SOBRE ESTE RECIBO YA ESTA AGOTADO: TOTAL DEL RECIBO: '+ total +' TOTAL APLICADO: '+aplicado +' TOTAL AJUSTADO EN RECIBO: '+ajuste);
	window.opener.document.form0.recibo.value = "";
	}
}
else
{CBMSG.warning('Pase para Arreglar');
window.opener.document.form0.recibo.value=eval('document.form0.codigo'+k).value;
window.opener.document.form0.fecha_nacimiento.value=eval('document.form0.fecha_nacimiento'+k).value;
window.opener.document.form0.pac_id.value=eval('document.form0.pac_id'+k).value;
window.opener.document.form0.codigo_paciente.value=eval('document.form0.codigo_paciente'+k).value;
window.opener.document.form0.ref_type.value=eval('document.form0.ref_type'+k).value;
window.opener.document.form0.ref_id.value=eval('document.form0.ref_id'+k).value;

window.close();
}
/*
window.opener.document.form0.recibo.value = eval('document.form0.codigo'+k).value;
window.close();		*/

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECIBOS"></jsp:param>
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
				<%=fb.hidden("pase",pase)%>
				<td width="50%">&nbsp;<cellbytelabel>Recibo</cellbytelabel>
							<%=fb.textBox("codigo","",false,false,false,30,null,null,null)%>
				</td>
				<td width="50%">&nbsp;<cellbytelabel>Nombre</cellbytelabel>
							<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%>
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
					<%=fb.hidden("pase",pase)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("nombre",""+nombre)%>

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
					<%=fb.hidden("pase",pase)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("nombre",""+nombre)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">
	<tr class="TextHeader">
	  <td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
	  <td width="40%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
	  <td width="15%"><cellbytelabel>Pago Total</cellbytelabel></td>
	  <td width="15%"><cellbytelabel>Aplicado</cellbytelabel></td>
	  <td width="10%"><cellbytelabel>Ajustado</cellbytelabel></td>
	  <td width="10%"><cellbytelabel>Por Aplicar</cellbytelabel></td>
	</tr>
	<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	 double total = Double.parseDouble(cdo.getColValue("pagoTotal"));
	 double aplicado = Double.parseDouble(cdo.getColValue("aplicado"));
	 double ajustado = Double.parseDouble(cdo.getColValue("ajustado"));
	 double porAplicar = Math.round((total - aplicado + ajustado) * 100);
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("recibo"))%>
	<%=fb.hidden("pagoTotal"+i,cdo.getColValue("pagoTotal"))%>
	<%=fb.hidden("aplicado"+i,cdo.getColValue("aplicado"))%>
	<%=fb.hidden("ajustado"+i,cdo.getColValue("ajustado"))%>
	<%=fb.hidden("porAplicar"+i,""+porAplicar)%>
	<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
	<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
	<%=fb.hidden("codigo_paciente"+i,cdo.getColValue("codigo_paciente"))%>
	<%=fb.hidden("ref_type"+i,cdo.getColValue("ref_type"))%>
	<%=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="cursor:pointer">
		<td>&nbsp;<%=cdo.getColValue("recibo")%></td>
		<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagoTotal"))%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(aplicado)%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(ajustado)%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(porAplicar / 100)%></td>
	</tr>
	<%
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
					<%=fb.hidden("pase",pase)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("nombre",""+nombre)%>
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
					<%=fb.hidden("pase",pase)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("nombre",""+nombre)%>
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