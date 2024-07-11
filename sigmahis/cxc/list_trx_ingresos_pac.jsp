<%//@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="htSI" scope="session" class="java.util.Hashtable" />
<%
/*
=========================================================================
=========================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
htSI.clear();
ArrayList al = new ArrayList();
CommonDataObject cdParam = new CommonDataObject();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFiltroFecha = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbFilterFF = new StringBuffer();
String resumido = request.getParameter("resumido");
String resumido_x_aseg = request.getParameter("resumido_x_aseg");
String saldoIni = request.getParameter("saldoIni");
String aseguradora = request.getParameter("aseguradora");
String usa_fecha_apl_pago = request.getParameter("usa_fecha_apl_pago");
String CXC_APLICAR_PAQUETE_CS = "";
  String aseguradoraDesc = request.getParameter("aseguradoraDesc");
  if (aseguradora == null) aseguradora = "";
  if (aseguradoraDesc == null) aseguradoraDesc = "";
if (resumido == null) resumido = "N";
if (resumido_x_aseg == null) resumido_x_aseg = "";
if (saldoIni == null) saldoIni = "";
if (usa_fecha_apl_pago == null) usa_fecha_apl_pago = "N";
String vista = "vw_cxc_mov_adm_new";
if(usa_fecha_apl_pago.equals("S")) vista = "vw_cxc_mov_adm_fa";

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

  cdParam = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'CXC_APLICAR_PAQUETE_CS'), 'N') CXC_APLICAR_PAQUETE_CS from dual");
  CXC_APLICAR_PAQUETE_CS = cdParam.getColValue("CXC_APLICAR_PAQUETE_CS");

  String codigo = request.getParameter("codigo");
  String nombre = request.getParameter("nombre");
   String fecha_ini = request.getParameter("fecha_ini");
  String fecha_fin = request.getParameter("fecha_fin");
  if (codigo == null) codigo = "";
  if (nombre == null) nombre = "";
  if (fecha_ini == null) fecha_ini = CmnMgr.getCurrentDate("dd/mm/yyyy");
  if (fecha_fin == null) fecha_fin = fecha_ini;
  if (!codigo.trim().equals("")) { sbFilter.append(" and upper(x.pac_id) ="); sbFilter.append(codigo.toUpperCase());}
  //if (!nombre.trim().equals("")) { sbFilter.append(" and upper(x.nombre_cliente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
  if(!fecha_ini.trim().equals("")){sbFiltroFecha.append(" and trunc(fecha) >= to_date('"); sbFiltroFecha.append(fecha_ini); sbFiltroFecha.append("','dd/mm/yyyy')"); }
  if(!fecha_fin.trim().equals("")){sbFiltroFecha.append(" and trunc(fecha) <= to_date('"); sbFiltroFecha.append(fecha_fin); sbFiltroFecha.append("','dd/mm/yyyy')");}

  if (!nombre.trim().equals("")) sbSql.append("select * from (");
  sbSql.append("select compania");
  if(resumido.trim().equals("N") || resumido.trim().equals("A")) sbSql.append(", pac_id, nombre, aseguradora, aseguradora_desc ");
  sbSql.append(", sum(saldo_ini) saldo_ini,  sum(cargos) as cargos, sum(factura_pac) as factura_pac, sum(factura_emp) as factura_emp, sum(desc_pac) as desc_pac, sum(desc_emp) as desc_emp, sum(paquete) as paquete, sum(ajuste_pac) as ajuste_pac, sum(ajuste_emp) as ajuste_emp ,sum(saldo) as saldo, sum(pagos_aplicados) pagos_aplicados, sum(pagos_no_aplicados) pagos_no_aplicados, sum(ajuste_recibo) ajuste_recibo, sum(factura_si) factura_si from (");
    sbSql.append(" select  compania, ");
  if(resumido.trim().equals("N")){
    sbSql.append(" pac_id ");
    sbSql.append(", (select (select nombre_paciente from vw_adm_paciente where pac_id =x.pac_id) from dual) as nombre, aseguradora, (select (select nombre from tbl_adm_empresa where codigo =x.aseguradora) from dual) as aseguradora_desc, 0 saldo_ini, ");
  } else if(resumido.trim().equals("A")){
    sbSql.append(" '' pac_id, '' nombre, aseguradora, nvl((select (select nombre from tbl_adm_empresa where codigo =x.aseguradora) from dual), 'N/A') as aseguradora_desc, 0 saldo_ini, ");
  }
  else sbSql.append(" '' as  pac_id, '' as nombre, '' aseguradora, '' aseguradora_desc, 0 saldo_ini, ");
  sbSql.append(" sum(cargos) as cargos,sum(factura_pac) as factura_pac,sum(factura_emp)as factura_emp,sum(desc_pac) as desc_pac,sum(desc_emp) as desc_emp,sum(paquete) as paquete,sum(ajuste_pac) as ajuste_pac,sum(ajuste_emp) as ajuste_emp ,(sum(cargos) +decode('");
  sbSql.append(CXC_APLICAR_PAQUETE_CS);
  sbSql.append("', 'S', sum(paquete),0)) - (sum(desc_pac) + sum(desc_emp)) + sum(ajuste_pac) + sum(ajuste_emp) - ");
  if(usa_fecha_apl_pago.equals("S")){
    sbSql.append("SUM (case when fecha_recibo between TO_DATE ('");
    sbSql.append(fecha_ini);
    sbSql.append("', 'dd/mm/yyyy')  AND TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy')  then pagos_aplicados else 0 end) - (SUM (pagos_no_aplicados)+SUM (case when fecha_recibo > TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end))");
  } else {
    sbSql.append("sum(pagos_aplicados) - sum(pagos_no_aplicados) ");
  }

  sbSql.append(" - sum(ajuste_recibo)+sum(factura_si) as saldo, ");
  if(usa_fecha_apl_pago.equals("S")){
    sbSql.append("SUM (case when fecha_recibo between TO_DATE ('");
    sbSql.append(fecha_ini);
    sbSql.append("', 'dd/mm/yyyy') AND TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end) pagos_aplicados, (SUM (pagos_no_aplicados)+SUM (case when fecha_recibo > TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end)) pagos_no_aplicados");
  } else {
    sbSql.append("sum(pagos_aplicados) pagos_aplicados, sum(pagos_no_aplicados) pagos_no_aplicados");
  }
  sbSql.append(", sum(ajuste_recibo) ajuste_recibo, sum(factura_si) factura_si ");

  sbSql.append(" from ");
  sbSql.append(vista);
  sbSql.append(" x where compania = ");
  sbSql.append(session.getAttribute("_companyId"));
  if (!aseguradora.trim().equals("")) { sbFilter.append(" and aseguradora = "); sbFilter.append(aseguradora);}


  /*if (!aseguradoraDesc.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision z where nvl(z.estado,'A') = 'A' and z.prioridad = 1 and z.pac_id = x.pac_id and z.admision = x.admision and exists (select null from tbl_adm_empresa where codigo = z.empresa and upper(nombre) like '%"); sbFilter.append(aseguradoraDesc.toUpperCase()); sbFilter.append("%'))"); }*/
   sbSql.append(sbFilter);
   sbSql.append(sbFiltroFecha);
   if(resumido.trim().equals("N"))sbSql.append(" group by x.compania, pac_id , x.aseguradora");
   else if(resumido.trim().equals("A"))sbSql.append(" group by x.compania, x.aseguradora");
  else sbSql.append(" group by x.compania");

  sbSql.append(" union ");
  /*========================================================*/
  /*    S   A   L   D   O       I   N   I   C   I   A   L   */
  /*========================================================*/

  sbSql.append("select compania, ");
   if(resumido.trim().equals("N"))sbSql.append(" x.pac_id, (select (select nombre_paciente from vw_adm_paciente where pac_id =x.pac_id) from dual) as nombre, x.aseguradora, (select (select nombre from tbl_adm_empresa where codigo =x.aseguradora) from dual) as aseguradora_desc, ");
   else if(resumido.trim().equals("A") || resumido.trim().equals("N"))sbSql.append(" '' pac_id, '' nombre, x.aseguradora, nvl((select (select nombre from tbl_adm_empresa where codigo =x.aseguradora) from dual), 'N/A') as aseguradora_desc, ");
  else sbSql.append(" '' as  pac_id, '' as nombre, '' aseguradora, '' aseguradora_desc, ");

  /**/
  sbSql.append(" (((sum(cargos) +decode('");
  sbSql.append(CXC_APLICAR_PAQUETE_CS);
  sbSql.append("', 'S', sum(paquete),0)) - (sum(desc_pac) + sum(desc_emp))) + sum(ajuste_pac) + sum(ajuste_emp) - ");
  if(usa_fecha_apl_pago.equals("S")){
    sbSql.append("SUM (case when fecha_recibo < TO_DATE ('");
    sbSql.append(fecha_ini);
    sbSql.append("', 'dd/mm/yyyy') /* AND TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy')*/ then pagos_aplicados else 0 end) - (SUM (pagos_no_aplicados)+SUM (case when fecha_recibo > TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end))");
  } else {
    sbSql.append("sum(pagos_aplicados) - sum(pagos_no_aplicados) ");
  }
  sbSql.append(") - sum(ajuste_recibo)+ sum(factura_si)  as saldo_inicial, ");
  /**/


  sbSql.append(" sum(0) as cargos,sum(0) as factura_pac, sum(0) as factura_emp,sum(0) as desc_pac, sum(0) as desc_emp, sum(0) as paquete, sum(0) as ajuste_pac, sum(0) as ajuste_emp ,sum(0) as saldo, sum(0) pagos_aplicados, sum(0) pagos_no_aplicados, sum(0) ajuste_recibo, sum(0) factura_si from ");
  sbSql.append(vista);
  sbSql.append(" x where compania =");
  sbSql.append(session.getAttribute("_companyId"));
  sbSql.append(" and trunc(fecha) < to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy')");
  sbSql.append(sbFilter);
   if(resumido.trim().equals("N"))sbSql.append(" group by x.compania, pac_id, x.aseguradora");
   else if(resumido.trim().equals("A"))sbSql.append(" group by x.compania, x.aseguradora");
  else sbSql.append(" group by x.compania");
  if(resumido.trim().equals("N"))sbSql.append(") group by compania, pac_id, nombre, aseguradora,aseguradora_desc");
   else if(resumido.trim().equals("A"))sbSql.append(") group by compania, pac_id, nombre, aseguradora,aseguradora_desc");
  else sbSql.append(") group by compania");

  if(resumido.trim().equals("N"))sbSql.append(" order by aseguradora_desc, nombre asc ");
  else if(resumido.trim().equals("A"))sbSql.append(" order by aseguradora_desc asc ");
  else sbSql.append(" order by 1");


  if (!nombre.trim().equals("")) { sbSql.append(") where upper(nombre) like '%"); sbSql.append(nombre.toUpperCase()); sbSql.append("%'"); }

   if(request.getParameter("fecha_fin") != null){
  al = SQLMgr.getDataList("select * from (select rownum as rn, count(*) over() as cont, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
  if(al.size()>0){
    for (int i=0; i<al.size(); i++){
      CommonDataObject cdo = (CommonDataObject) al.get(i);
      rowCount = Integer.parseInt(cdo.getColValue("cont"));
      break;
    }
  }
  //rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
  }
  /*
  sbSql = new StringBuffer();
  sbSql.append("select ");
   if(resumido.trim().equals("N"))sbSql.append(" x.pac_id ,x.compania, x.aseguradora");
   else if(resumido.trim().equals("A"))sbSql.append(" x.compania, x.aseguradora");
  else sbSql.append(" x.compania");
  sbSql.append(", (sum(cargos) +decode('");
  sbSql.append(CXC_APLICAR_PAQUETE_CS);
  sbSql.append("','S',sum(paquete),0)) - (sum(desc_pac) + sum(desc_emp)) + sum(ajuste_pac) +sum(ajuste_emp)-sum(pagos_aplicados)-sum(pagos_no_aplicados)+sum(ajuste_recibo) saldo_inicial from vw_cxc_mov_adm_new x where trunc(fecha) < to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy')");
  sbSql.append(sbFilter);
   if(resumido.trim().equals("N"))sbSql.append(" group by pac_id, x.compania, x.aseguradora");
   else if(resumido.trim().equals("A"))sbSql.append(" group by x.compania, x.aseguradora");
  else sbSql.append(" group by x.compania");
  ArrayList alSI = new ArrayList();
  alSI = SQLMgr.getDataList(sbSql);

  String llave = "";
  for(int i = 0;i<alSI.size();i++){
    CommonDataObject cd = (CommonDataObject) alSI.get(i);
    if(resumido.trim().equals("N")) llave = cd.getColValue("pac_id")+"_"+cd.getColValue("aseguradora");
    else if(resumido.trim().equals("A")) llave = cd.getColValue("aseguradora");
    else llave = "";
    htSI.put(llave, cd);
  }
  */

  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  if (rowCount==0) pVal=0;
  else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Saldos - '+document.title;
var forceList = true;
function view(aseguradora,id){
  var resumido = document.search00.resumido.value;
abrir_ventana('../cxc/trx_ingresos_pac_det.jsp?aseguradora='+aseguradora+'&codigo='+id+'&fecha_ini=<%=fecha_ini%>&fecha_fin=<%=fecha_fin%>&resumido='+resumido+'&usa_fecha_apl_pago=<%=usa_fecha_apl_pago%>');}
function printList(xtraP){
var fecha_ini= document.search00.fecha_ini.value; var fecha_fin =document.search00.fecha_fin.value;
var nombre  = document.search00.nombre.value||'ALL';
var codigo = document.search00.codigo.value||'ALL';
var resumido = document.search00.resumido.value;
var saldoIni = document.search00.saldoIni.checked ? "N":"S";
var aseguradora = document.search00.aseguradora.value||'ALL';
if(resumido=='N'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_hospitalario.rptdesign&fDesdeParam='+fecha_ini+'&fHastaParam='+fecha_fin+'&nombreParam='+nombre+'&codigoParam='+codigo+'&aseguradoraParam='+aseguradora+'&pSaldoIni='+saldoIni+'&aplPaqueteCSParam=<%=CXC_APLICAR_PAQUETE_CS%>&usa_fecha_apl_pago=<%=usa_fecha_apl_pago%>&pCtrlHeader=false');
 } else if(resumido=='A'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_hospitalario_res_aseg.rptdesign&fDesdeParam='+fecha_ini+'&fHastaParam='+fecha_fin+'&nombreParam='+nombre+'&codigoParam='+codigo+'&aseguradoraParam='+aseguradora+'&pSaldoIni='+saldoIni+'&aplPaqueteCSParam=<%=CXC_APLICAR_PAQUETE_CS%>&usa_fecha_apl_pago=<%=usa_fecha_apl_pago%>&pCtrlHeader=false');
 } else if(resumido=='G'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_hospitalario_res_global.rptdesign&fDesdeParam='+fecha_ini+'&fHastaParam='+fecha_fin+'&nombreParam='+nombre+'&codigoParam='+codigo+'&aseguradoraParam='+aseguradora+'&pSaldoIni='+saldoIni+'&aplPaqueteCSParam=<%=CXC_APLICAR_PAQUETE_CS%>&usa_fecha_apl_pago=<%=usa_fecha_apl_pago%>&pCtrlHeader=false');
 }
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function viewDet(id,fg,saldoIni,nombre)
{
<%if(!resumido.trim().equals("S")){%>
showPopWin('../cxc/list_trx_ingresos_pac_det.jsp?codigo='+id+'&fg='+fg+'&fecha_ini=<%=fecha_ini%>&fecha_fin=<%=fecha_fin%>&saldoIni='+saldoIni+'&paciente='+nombre,winWidth*.95,winHeight*.70,null,null,'');
<%}else{%>CBMSG.warning('SOLO  PARA  CONSULTAS DETALLADAS POR PACIENTE!');
<%}%>
}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=rep_aux');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="SALDOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
  <td>
    <table width="100%" cellpadding="1" cellspacing="1">
        <tr>
          <td align="right"><a href="javascript:printList(1)" class="Link00Bold">Imprimir (Excel)</a></td>
        </tr>
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
    <tr class="TextFilter">
      <td>
        <cellbytelabel>C&oacute;digo</cellbytelabel>
        <%=fb.textBox("codigo",codigo,false,false,false,10,"Text10",null,null)%>
        <cellbytelabel>Nombre</cellbytelabel>
        <%=fb.textBox("nombre",nombre, false,false,false,30,"Text10",null,null)%>
        <cellbytelabel>Fecha</cellbytelabel>:
        <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2"/>
          <jsp:param name="nameOfTBox1" value="fecha_ini"/>
          <jsp:param name="valueOfTBox1" value="<%=fecha_ini%>"/>
          <jsp:param name="nameOfTBox2" value="fecha_fin"/>
          <jsp:param name="valueOfTBox2" value="<%=fecha_fin%>"/>
        </jsp:include>
        Resumido:<%=fb.select("resumido","N=No,A=POR ASEGURADORA,G=GLOBAL",resumido,false,false,0,"Text10",null,null,null,"")%>
        Sin Saldo Inicial:<%=fb.checkbox("saldoIni","S",saldoIni.equals("S"),false)%>
        Aseguradora:
        <%=fb.intBox("aseguradora",aseguradora,false,false,false,10,"Text10",null,null)%>
        <%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,false,40,"Text10",null,null)%>
        <%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
        &nbsp;Usa Fecha Apl. Pago?
        <%=fb.select("usa_fecha_apl_pago","N=No,S=SI",usa_fecha_apl_pago,false,false,0,"Text10",null,null,null,"")%>
        <%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
      </td>
    </tr>

<%=fb.formEnd()%>
    </table>
  </td>
</tr>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
 <%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("resumido", resumido)%>
<%=fb.hidden("saldoIni", saldoIni)%>
<%=fb.hidden("usa_fecha_apl_pago", usa_fecha_apl_pago)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
 <%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("resumido", resumido)%>
<%=fb.hidden("saldoIni", saldoIni)%>
<%=fb.hidden("usa_fecha_apl_pago", usa_fecha_apl_pago)%>
      <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
    </tr>
    </table>
  </td>
</tr>
 <tr>
  <td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
     <tr class="TextHeader" align="center">
      <td width="4%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
      <td width="13%"><cellbytelabel>Nombre</cellbytelabel></td>
      <td width="12%"><cellbytelabel>Aseguradora</cellbytelabel></td>
      <td width="7%"><cellbytelabel>S. Anterior</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Fac. S.I.(+-)</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Cargos/Dev. </cellbytelabel></td>
      <td width="6%"><cellbytelabel>Desc Pac.(-)</cellbytelabel></td>
      <td width="6%"><cellbytelabel>Desc Emp.(-)</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Ajuste Pac.(+-)</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Ajuste Emp.(+-)</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Pagos Apl.(-)</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Pagos No Apl.(-)</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Ajuste Rec.</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Paquete</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Saldo</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Facturas Pac.</cellbytelabel></td>
      <td width="7%"><cellbytelabel>Facturas Emp.</cellbytelabel></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%
double saldoTotal =0.00,saldo=0.00,saldoAnt=0.00,facturas_pac=0.00,facturas_emp=0.00,desc_pac=0.00,desc_emp=0.00,saldoFin=0.00,ajuste_pac=0.00,ajuste_emp=0.00,cargos=0.00,paquete=0.00, pagos_aplicados = 0.00, pagos_no_aplicados = 0.00, ajuste_recibo = 0.00, tot_pagos_app = 0.00, tot_pagos_no_app = 0.00, tot_ajuste_recibo = 0.00, factura_si = 0.00, tot_factura_si = 0.00;

for (int i=0; i<al.size(); i++)
{
  CommonDataObject cdo = (CommonDataObject) al.get(i);
  String color = "TextRow02";
  if (i % 2 == 0) color = "TextRow01";

  saldoAnt += Double.parseDouble(cdo.getColValue("saldo_ini"));
  cargos += Double.parseDouble(cdo.getColValue("cargos"));
  facturas_pac += Double.parseDouble(cdo.getColValue("factura_pac"));
  facturas_emp += Double.parseDouble(cdo.getColValue("factura_emp"));
  desc_pac += Double.parseDouble(cdo.getColValue("desc_pac"));
  desc_emp += Double.parseDouble(cdo.getColValue("desc_emp"));
  ajuste_pac += Double.parseDouble(cdo.getColValue("ajuste_pac"));
  ajuste_emp = Double.parseDouble(cdo.getColValue("ajuste_emp"));
  paquete += Double.parseDouble(cdo.getColValue("paquete"));
  saldoFin += Double.parseDouble(cdo.getColValue("saldo_ini"))+Double.parseDouble(cdo.getColValue("saldo"));
  saldo  = Double.parseDouble(cdo.getColValue("saldo_ini"))+Double.parseDouble(cdo.getColValue("saldo"));
  pagos_aplicados  += Double.parseDouble(cdo.getColValue("pagos_aplicados"));
  pagos_no_aplicados  += Double.parseDouble(cdo.getColValue("pagos_no_aplicados"));
  ajuste_recibo  += Double.parseDouble(cdo.getColValue("ajuste_recibo"));
  factura_si  += Double.parseDouble(cdo.getColValue("factura_si"));
  saldoTotal += Double.parseDouble(cdo.getColValue("saldo_ini"))+ Double.parseDouble(cdo.getColValue("saldo"));
  tot_pagos_app += pagos_aplicados;
  tot_pagos_no_app += pagos_no_aplicados;
  tot_ajuste_recibo += ajuste_recibo;

%>
    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
       <td align="center"><%=cdo.getColValue("pac_id")%></td>
      <td><%=cdo.getColValue("nombre")%></td>
      <td><%=cdo.getColValue("aseguradora_desc")%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_ini"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_si"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cargos"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("desc_pac"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("desc_emp"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pac"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_emp"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos_aplicados"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos_no_aplicados"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_recibo"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("paquete"))%></td>
      <td align="right">
        <%if(saldo<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
      <%=CmnMgr.getFormattedDecimal(saldo)%>
        <%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>
      </td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_pac"))%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_emp"))%></td>
      <td align="center">
      <%if(resumido.equals("N")){%>
      <a href="javascript:view('<%=cdo.getColValue("aseguradora")%>','<%=cdo.getColValue("pac_id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">MOV</a>
      <%}%>
      </td>
     </tr>
<%
}
%>
  <tr class="TextHeader02" align="center">
      <td colspan="3" align="right">TOTALES PAGINA</td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(saldoAnt)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(factura_si)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cargos)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(desc_pac)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(desc_emp)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_pac)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_emp)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(pagos_aplicados)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(pagos_no_aplicados)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_recibo)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(paquete)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(saldoFin)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(facturas_pac)%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(facturas_emp)%></td>
      <td>&nbsp;</td>
    </tr>
    <%if(resumido.trim().equals("S")){%>
    <tr class="TextHeader01" align="center">
      <td colspan="3" align="right"> </td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="center" colspan="2"><%=CmnMgr.getFormattedDecimal(facturas_pac+facturas_emp)%></td>
      <td align="center" colspan="2"><%=CmnMgr.getFormattedDecimal(desc_pac+desc_emp)%></td>
      <td align="center" colspan="2"><%=CmnMgr.getFormattedDecimal(ajuste_pac+ajuste_emp)%></td>
      <td align="center" colspan="1"><%=CmnMgr.getFormattedDecimal(tot_pagos_app)%></td>
      <td align="center" colspan="1"><%=CmnMgr.getFormattedDecimal(tot_pagos_no_app)%></td>
      <td align="center" colspan="1"><%=CmnMgr.getFormattedDecimal(tot_ajuste_recibo)%></td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}%>

     <%=fb.formEnd(true)%>
   </table>
 </div>
</div>


<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
  </td>
</tr>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("resumido", resumido)%>
<%=fb.hidden("saldoIni", saldoIni)%>
<%=fb.hidden("usa_fecha_apl_pago", usa_fecha_apl_pago)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("resumido", resumido)%>
<%=fb.hidden("saldoIni", saldoIni)%>
<%=fb.hidden("usa_fecha_apl_pago", usa_fecha_apl_pago)%>
      <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
    </tr>
    </table>
  </td>
</tr>
</table>
</body>
</html>
<%
}
%>