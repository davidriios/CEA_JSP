
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String newsql = "";
String appendFilter = "";
String empId = request.getParameter("empId");
String fg = request.getParameter("fg");
if(fg == null)fg="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	
	String anio = "",quincena = "",planilla  = "";
	
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))anio  = request.getParameter("anio");
	if (request.getParameter("quincena") != null && !request.getParameter("quincena").trim().equals(""))quincena  = request.getParameter("quincena");
	if (request.getParameter("planilla") != null && !request.getParameter("planilla").trim().equals(""))planilla  = request.getParameter("planilla");
	
	sbSql.append("SELECT a.codigo, a.tipo_trx AS tipoTrx, TO_CHAR(a.fecha,'dd/mm/yyyy') AS fecha,to_char(a.cantidad,'999,999,990.00') cantidad, TO_CHAR(a.monto,'999,999,990.00') AS monto, TO_CHAR(a.fecha_inicio,'dd/mm/yyyy') AS fechaInicial, TO_CHAR(a.fecha_final,'dd-mm-yyyy') AS fechaFinal, a.anio_pago AS anioPago, a.mes_pago AS mesPago, a.quincena_pago AS quincenaPago, a.cod_planilla_pago AS planillaPago, DECODE(a.estado_pago,'PE','PENDIENTE','PA','PAGADO','AN','ANULADO') AS estado, TO_CHAR(a.fecha_pago,'dd/mm/yyyy') AS fechaPago, a.comentario, DECODE(a.accion,'PA','PAGAR','DE','DESCONTAR')AS accion, a.vobo_estado AS voboEstado, a.grupo, a.sub_tipo_trx AS subTrx, TO_CHAR(a.monto_unitario,'990.000000') AS montoUnitario, a.aprobacion_estado AS aprobacionEstado, a.anio_reporta AS anioReporta, a.quincena_reporta AS quincenaReporta, a.cod_planilla_reporta AS codPlanilla, TO_CHAR(b.rata_hora,'999,990.00') AS rataHora, SUBSTR(e.descripcion,1,20) AS descTrx, b.tipo_renta||'-'||TO_CHAR(b.num_dependiente,'990') AS tipoRenta, SUBSTR(d.nombre,10,10) AS descripcion, c.denominacion, d.nombre AS planilla,b.provincia||'-'||DECODE(b.sigla,'0','')||b.tomo||' '||b.asiento AS cedula, b.num_empleado AS numEmpleado FROM TBL_PLA_TRANSAC_EMP a, TBL_PLA_EMPLEADO b, TBL_PLA_CARGO c, TBL_PLA_PLANILLA d, TBL_PLA_TIPO_TRANSACCION e WHERE a.emp_id = b.emp_id AND a.compania = b.compania AND a.compania = c.compania AND b.cargo = c.codigo AND a.compania=d.compania AND a.compania = e.compania AND a.tipo_trx = e.codigo AND d.cod_planilla = a.cod_planilla_pago AND a.aprobacion_estado = 'S' and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.emp_id=");
	sbSql.append(empId);
	if (!anio.trim().equals("")){sbSql.append(" and a.anio_pago=");sbSql.append(anio);}
	if (!quincena.trim().equals("")){sbSql.append(" and a.quincena_pago=");sbSql.append(quincena);}
	if (!planilla.trim().equals("")){sbSql.append(" and a.cod_planilla_pago=");sbSql.append(planilla);}
	
	sbSql.append(" UNION ALL SELECT   0 AS codigo, a.codigo AS tipotrx,  TO_CHAR (a.fecha_inicio, 'dd/mm/yyyy') AS fecha, to_char(a.cantidad,'999,999,990.00') cantidad,   TO_CHAR (a.monto, '999,999,990.00') AS monto,   TO_CHAR (a.fecha_inicio, 'dd/mm/yyyy') AS fechainicial,   TO_CHAR (a.fecha_final, 'dd/mm/yyyy') AS fechafinal,   a.anio_pag AS aniopago, a.mes_pag AS mespago,   a.quincena_pag AS quincenapago, a.cod_planilla_pag AS planillapago,   DECODE (a.estado_pag,  'PE', 'PENDIENTE',  'PA', 'PAGADO',    'AN', 'ANULADO'   ) AS estado,     TO_CHAR (a.fecha_pag, 'dd/mm/yyyy') AS fechapago, a.comentario,  DECODE (a.forma_pago, 'DI', 'DINERO', 'GA', 'GASTOS DE ALIMENTACION','TC','TIEMPO COMPENSATORIO') AS accion,   a.vobo_estado AS voboestado, 0 AS grupo, a.the_codigo AS subtrx,   TO_CHAR (e.factor_multi, '990.000000') AS montounitario,   a.vobo_estado AS aprobacionestado, a.anio_pag AS anioreporta,  a.quincena_pag AS quincenareporta, a.cod_planilla_pag AS codplanilla, TO_CHAR (b.rata_hora, '990.000000') AS ratahora,   SUBSTR (e.descripcion, 1, 20) AS desctrx,   b.tipo_renta || '-'    || TO_CHAR (b.num_dependiente, '990') AS tiporenta,  SUBSTR (d.nombre, 10, 10) AS descripcion, c.denominacion,  d.nombre AS planilla,  b.provincia || '-'  || DECODE (b.sigla, '0', '')   || b.tomo   || ' '  || b.asiento AS cedula,  b.num_empleado AS numempleado    FROM TBL_PLA_T_EXTRAORDINARIO a,   TBL_PLA_EMPLEADO b,   TBL_PLA_CARGO c,  TBL_PLA_PLANILLA d,  TBL_PLA_T_HORAS_EXT e    WHERE a.emp_id = b.emp_id  AND a.compania = b.compania  AND a.compania = c.compania   AND b.cargo = c.codigo  AND a.compania = d.compania  AND a.the_codigo = e.codigo  AND d.cod_planilla = a.cod_planilla_pag and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.emp_id=");
	sbSql.append(empId);
	if (!anio.trim().equals("")){sbSql.append(" and a.anio_pag=");sbSql.append(anio);}
	if (!quincena.trim().equals("")){sbSql.append(" and a.quincena_pag=");sbSql.append(quincena);}
	if (!planilla.trim().equals("")){sbSql.append(" and a.cod_planilla_pag=");sbSql.append(planilla);}

	sbSql.append(" UNION ALL SELECT   0 AS codigo, a.tipo_trx AS tipotrx,  TO_CHAR (a.fecha_des, 'dd/mm/yyyy') AS fecha, to_char(a.tiempo,'999,999,990.00') AS cantidad,   TO_CHAR (a.monto, '999,999,990.00') AS monto,   TO_CHAR (a.fecha_des, 'dd/mm/yyyy') AS fechainicial,   TO_CHAR (a.fecha_des, 'dd-mm-yyyy') AS fechafinal,   a.anio_des AS aniopago, a.mes_des AS mespago,   a.quincena_des AS quincenapago, a.cod_planilla_des AS planillapago,   DECODE (a.estado_des,  'PE', 'PENDIENTE','PA', 'PAGADO','AN', 'ANULADO','DS','DESCONTADO'   ) AS estado,     TO_CHAR (a.fecha_des, 'dd/mm/yyyy') AS fechapago, a.comentario,  DECODE (a.ACCION, 'ND', 'NO DESCONTAR', 'DS', 'DESCONTAR','DV','DEVOLVER') AS accion,   a.vobo_estado AS voboestado, 0 AS grupo, a.motivo_falta AS subtrx,   TO_CHAR (b.rata_hora, '990.000000') AS montounitario,a.vobo_estado AS aprobacionestado, a.anio_des AS anioreporta,  a.quincena_des AS quincenareporta, a.cod_planilla_des AS codplanilla,TO_CHAR (b.rata_hora, '990.000000') AS ratahora,   SUBSTR (e.descripcion, 1, 20) AS desctrx,   b.tipo_renta || '-'    || TO_CHAR (b.num_dependiente, '990') AS tiporenta,  SUBSTR (d.nombre, 10, 10) AS descripcion, c.denominacion,  d.nombre AS planilla,  b.provincia || '-'  || DECODE (b.sigla, '0', '')   || b.tomo   || ' '  || b.asiento AS cedula,  b.num_empleado AS numempleado    FROM TBL_PLA_AUS_Y_TARD a,   TBL_PLA_EMPLEADO b,   TBL_PLA_CARGO c,  TBL_PLA_PLANILLA d,  TBL_PLA_MOTIVO_FALTA e    WHERE a.emp_id = b.emp_id  AND a.compania = b.compania   AND a.compania = c.compania   AND b.cargo = c.codigo  AND a.compania = d.compania  AND a.motivo_falta = e.codigo  AND d.cod_planilla = a.cod_planilla_des and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.emp_id=");
	sbSql.append(empId);
	if (!anio.trim().equals("")){sbSql.append(" and a.anio_des=");sbSql.append(anio);}
	if (!quincena.trim().equals("")){sbSql.append(" and a.quincena_des=");sbSql.append(quincena);}
	if (!planilla.trim().equals("")){sbSql.append(" and a.cod_planilla_des=");sbSql.append(planilla);}
 

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+" ORDER BY 8 desc,10 desc,11 asc) a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");
   
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
	document.title = 'Planilla - Consulta de Transacciones '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PAGO DE PLANILLA "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
			&nbsp;<!--<a href="javascript:add()" class="Link00">[ Registrar Nueva Planilla ]</a>-->
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
<%fb = new FormBean("search11",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("fg",fg)%>
				<td width="25%">
					C&oacute;digo de Planilla
					<%=fb.intBox("planilla",planilla,false,false,false,10)%>
				</td>
				<td width="20%">
					Año<%=fb.intBox("anio",anio,false,false,false,10)%>
				</td>
				<td width="20%">
					Periodo<%=fb.intBox("quincena",quincena,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd(true)%>
		
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("planilla",planilla)%>
				<%=fb.hidden("quincena",quincena)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("empId",""+empId)%>
				<td width="6%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="39%">Total Registro(s) <%=rowCount%></td>
				<td width="25%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("planilla",planilla)%>
				<%=fb.hidden("quincena",quincena)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("empId",""+empId)%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%> </td>
		<td  width="10%" align="right">&nbsp; </td>
		<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ===========   R E S U L T S   S T A R T   H E R E   ============== -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRowWhite">
			<td colspan="12">
			<jsp:include page="../common/empleado.jsp" flush="true">
			<jsp:param name="empId" value="<%=empId%>"></jsp:param>
			<jsp:param name="fp" value="verTransacciones"></jsp:param>
			<jsp:param name="mode" value="view"></jsp:param>
			</jsp:include>
			</td>
		</tr>

		<tbody id="list">
	  <tr align="center" class="TextHeader">
    	<td colspan="9" align="center">Detalle de Transacciones </td>
    	<td colspan="3" align="center">Detalle de Pago</td>
	  </tr>
	  <tr class="TextHeader" align="center">
			<td width="8%">Fecha</td>
			<td width="5%">Cod.</td>
			<td width="18%">Transacción</td>
			<td width="10%">Estado&nbsp;</td>
			<td width="5%">Cantidad&nbsp;</td>
			<td width="8%">Monto</td>
			<td width="10%">Total&nbsp;</td>
			<td width="10%">Accion&nbsp;</td>
			<td width="5%">Año&nbsp;</td>
			<td width="5%">Periodo&nbsp;</td>
		  <td width="13%">Planilla&nbsp;</td>
	  </tr> <%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";						
%>
 <tr align="center" class="<%=color%>">
    <td align="center"><%=cdo.getColValue("fecha")%></td>
    <td align="center"><%=cdo.getColValue("tipotrx")%></td>
    <td align="left"><%=cdo.getColValue("descTrx")%></td>
    <td align="center"><%=cdo.getColValue("estado")%></td>
    <td align="center"><%=cdo.getColValue("cantidad")%></td>
    <td align="right"><%=cdo.getColValue("montoUnitario")%></td>
    <td align="right"><%=cdo.getColValue("monto")%></td>
   	<td align="center"><%=cdo.getColValue("accion")%></td>
   	<td align="center"><%=cdo.getColValue("anioPago")%></td>
   	<td align="center"><%=cdo.getColValue("quincenaPago")%></td>
   	<td align="left"><%=cdo.getColValue("descripcion")%></td>
  </tr>
  <%}%>
 </tbody>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("planilla",planilla)%>
				<%=fb.hidden("quincena",quincena)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("empId",""+empId)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="35%">Total Registro(s) <%=rowCount%></td>
				<td width="25%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("planilla",planilla)%>
			<%=fb.hidden("quincena",quincena)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("empId",""+empId)%>
			
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<td  width="10%" align="right">&nbsp; </td>
			<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
			
			
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//POST
%>
