<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String fecha_desde = "", fecha_hasta = "", tipo_liq="HO";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

String factura = "", nombre = "", identificacion = "", p_lista="";
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

  if(request.getParameter("fecha_desde")!=null) fecha_desde = request.getParameter("fecha_desde");
	if(request.getParameter("fecha_hasta")!=null) fecha_hasta = request.getParameter("fecha_hasta");
	if(request.getParameter("factura")!=null) factura = request.getParameter("factura");
	if(request.getParameter("tipo_liq")!=null) tipo_liq = request.getParameter("tipo_liq");
	if(request.getParameter("p_lista")!=null) p_lista = request.getParameter("p_lista");


	sbSql = new StringBuffer();
	if((!fecha_desde.equals("") && !fecha_hasta.equals("")) || !p_lista.equals("")){
		sbSql.append("select a.*, total_x_fila-nvl((select nvl(monto_paciente, 0) + nvl(monto_descuento, 0) from tbl_fac_factura f where f.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and f.codigo = a.factura), 0) total from (select a.categoria, (select descripcion from tbl_adm_categoria_admision ca where ca.codigo = a.categoria) categoria_desc, a.pac_id, a.factura, a.admision, a.nombre, to_char(a.fecha_factura, 'dd/mm/yyyy') fecha_factura, sum(nvl(a.monto, 0)) monto, sum(nvl(a.cantidad, 0)) cantidad, sum(nvl(a.total_x_fila, 0)) total_x_fila from vw_pm_fact_a_reclamar a where 1=1");
		if(!fecha_desde.equals("")){
		sbSql.append(" and fecha_factura >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
		}
		if(!fecha_hasta.equals("")){
			sbSql.append(" and fecha_factura <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
		}
		if(tipo_liq.equals("HO")) sbSql.append(" and a.categoria = 1");
		else  sbSql.append(" and a.categoria in (2, 3, 4, 5)");
		if(!factura.equals("")){
			sbSql.append(" and a.factura = '");
			sbSql.append(factura);
			sbSql.append("'");
			
		}
		sbSql.append(" and not exists (select null from tbl_pm_det_liq_reclamo d, tbl_pm_liquidacion_reclamo l where d.pac_id = l.pac_id and d.fac_secuencia = l.admi_secuencia and l.num_factura = a.factura and l.status not in ('R', 'N') and l.tipo = 1)");
		if(!p_lista.equals("")){
		sbSql.append(" and exists (select null from   tbl_fac_lista_envio l, tbl_fac_lista_envio_det ld where l.id = ");
		sbSql.append(p_lista);
		sbSql.append(" and l.id = ld.id and l.compania = ld.compania and ld.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and ld.factura = a.factura and ld.estado = 'A' and l.enviado = 'S')");
		}

		sbSql.append(" group by a.categoria, a.pac_id, a.factura, a.admision, a.nombre, to_char(a.fecha_factura, 'dd/mm/yyyy')");
		
		sbSql.append(" order by a.factura) a ");
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
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
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;

function doAction(){changeAltTitleAttr();}
function doProcess(f_desde, f_hasta, pac_id, admision, factura, i){
	if($("#factura"+i).val()==''){
	if(confirm('Desea generar la liquidación para la factura '+factura+'?')){
		executeDB('<%=request.getContextPath()%>','call sp_pm_liq_reclamo_lote(\'<%=tipo_liq%>\', \''+f_desde+'\', \''+f_hasta+'\', \''+factura+'\', '+pac_id+', '+admision+', \'<%=(String) session.getAttribute("_userName")%>\')','','');
		$("#factura"+i).val(i);
		alert('Proceso ejecutado!');
	} 
	} else alert('Liquidacion generada previamente!');
}


function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal,curIndex){document.getElementById("curVal").value = curVal;
document.getElementById("curIndex").value = curIndex;}
function generar(){
	var tipo = document.search01.tipo_liq.value;
	var fecha_desde = document.search01.fecha_desde.value;
	var fecha_hasta= document.search01.fecha_hasta.value;
	var p_lista = document.search01.p_lista.value;
	if(tipo=='') alert('Seleccione Tipo de Reclamo!');
	//else if(fecha_desde=='') alert('Seleccione Fecha Desde!');
	//else if(fecha_hasta=='') alert('Seleccione Fecha Hasta!');
	else if(p_lista=='') alert('Introduzca ID de Lista!');
	else showPopWin('../process/pm_liquidacion_lote.jsp?tipo='+tipo+'&f_desde='+fecha_desde+'&f_hasta='+fecha_hasta+'&no_lista='+p_lista,winWidth*.95,_contentHeight*.75,null,null,'');
}
function getLista(){
	abrir_ventana1('../common/sel_lista_envio.jsp');
}

function printList(){
	var fDesde= document.search01.fecha_desde.value||'ALL';
	var fHasta= document.search01.fecha_hasta.value||'ALL';
	var tipo_liq= document.search01.tipo_liq.value;
	var no_lista= document.search01.p_lista.value;
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_liq_reclamo_lista.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&tipoCategoria='+tipo_liq+'&no_lista='+no_lista);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">&nbsp;<cellbytelabel id="2">Fecha Factura</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_desde" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
			<jsp:param name="nameOfTBox2" value="fecha_hasta" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
			</jsp:include>
			Tipo Liquidaci&oacute;n:
			<%=fb.select("tipo_liq","HO=HOSPITALIZADO,CE=CONSULTA EXTERNA",tipo_liq,false,false,0,"",null,"","","")%>
			Factura:
			<%=fb.textBox("factura",factura,false,false,false,10,10)%>
			
			ID. Lista:
			<%=fb.textBox("p_lista",p_lista,false,false,false,10,10)%>
			<%=fb.button("seleccionar","...",true,false,null,null,"onClick=\"javascript:getLista();\"")%>
			<%=fb.submit("go","Ir")%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<%=fb.button("save","Generar Lote",true,false,null,null,"onClick=\"javascript:generar();\"")%>
			<%=fb.button("imprime","Imprimir",true,false,null,null,"onClick=\"javascript:printList();\"")%>
			</td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<!--<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		</td>
	</tr>-->
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
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("tipo_liq",tipo_liq)%>
				<%=fb.hidden("p_lista",p_lista)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("tipo_liq",tipo_liq)%>
				<%=fb.hidden("p_lista",p_lista)%>
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
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;<cellbytelabel>Categor&iacute;a</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>Paciente</cellbytelabel></td>
		<td width="20%">&nbsp;<cellbytelabel>Factura</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Fecha Fact.</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
	<%=fb.hidden("curIndex","")%>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("categoria_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=cdo.getColValue("factura")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_factura")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("total")%></td>
					<td align="center">
					  <a href="javascript:doProcess('<%=fecha_desde%>', '<%=fecha_hasta%>', <%=cdo.getColValue("pac_id")%>, <%=cdo.getColValue("admision")%>, '<%=cdo.getColValue("factura")%>', <%=i%>)" class="Link00">Generar</a>
					</td>
				</tr>
				<%=fb.hidden("factura"+i,"")%>
				<%
				}
				%>
<%=fb.formEnd(true)%>
</table>
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
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("tipo_liq",tipo_liq)%>
				<%=fb.hidden("p_lista",p_lista)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("tipo_liq",tipo_liq)%>
				<%=fb.hidden("p_lista",p_lista)%>
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