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
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
	CommonDataObject cdo = new CommonDataObject();
int rowCount = 0;
String sql = "";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String appendFilter = "";
String sqlCds = "";
String fp = request.getParameter("fp");
int iconHeight = 40;
int iconWidth = 40;
String p_anio = request.getParameter("anio");
String p_mes = request.getParameter("mes");
String categoria = request.getParameter("categoria");
String admType = request.getParameter("admType");
String tipoRep = request.getParameter("tipoRep");
if(fp == null)fp="";
if(tipoRep == null)tipoRep="HR";
if(p_anio == null)p_anio=cDateTime.substring(6,10);
if(p_mes == null)p_mes=cDateTime.substring(3,5);
if (categoria == null) categoria = "";
if (admType == null) admType = "";
String mesReporte ="";
int dias =0;

 	sbSql.append("select to_char(decode(to_char(sysdate,'yyyymm'),'");
	sbSql.append(p_anio);
	sbSql.append(p_mes);
	sbSql.append("',sysdate,last_day(to_date('");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("','mm/yyyy'))),'dd') as last_day, to_char(to_date('");
	sbSql.append(p_mes);
	sbSql.append("','mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') as mes_desc from dual");

	 cdo = SQLMgr.getData(sbSql.toString());
	 dias = Integer.parseInt(cdo.getColValue("last_day"));
	 mesReporte = cdo.getColValue("mes_desc");

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


	if(request.getParameter("anio") != null ){

		sbSql = new StringBuffer();
		if (tipoRep.trim().equals("HR")) {

			sbSql.append("select b.interval_60_min/*decode(b.interval_60_min,00,'12',b.interval_60_min)*/ as hora   ");
			for(int ii = 1; ii <= dias; ii++){
				sbSql.append(",nvl(sum(decode(a.dia,");
				sbSql.append(ii);
				sbSql.append(",decode(b.interval_60_min,a.hora,a.cnt,0),0)),0) as dia"+ii);
			}
			sbSql.append(" from (select count(*) cnt,hora,dia,mes,anno from (select xx.fecha_ingreso,xx.fecha_creacion,to_char(xx.fecha_ingreso,'mm') as mes,to_char(xx.fecha_ingreso,'yyyy') as anno,to_char(xx.fecha_creacion,'HH24') hora,to_char(xx.fecha_creacion,'mi') mminut,to_char(xx.fecha_ingreso,'dd') as dia from tbl_adm_admision xx where estado not in ('N')  and xx.fecha_ingreso >= to_date('01/");
			sbSql.append(p_mes);
			sbSql.append("/");
			sbSql.append(p_anio);
			sbSql.append("','dd/mm/yyyy') and xx.fecha_ingreso <= last_day(to_date('");
			sbSql.append(p_mes);
			sbSql.append("/");
			sbSql.append(p_anio);
			sbSql.append("', 'mm/yyyy'))");
			if(!categoria.trim().equals("")){ sbSql.append(" and xx.categoria="); sbSql.append(categoria);}
			if (!admType.trim().equals("")) { sbSql.append(" and exists (select null from tbl_adm_categoria_admision where codigo = xx.categoria and adm_type = '"); sbSql.append(admType); sbSql.append("')"); }
		  sbSql.append(" order by xx.fecha_ingreso) tt group by dia,mes,anno,hora order by hora) a,(SELECT To_Char(trunc(SYSDATE) + (LEVEL/1440*60), 'HH24') interval_60_min FROM dual CONNECT BY LEVEL <= 24) b where a.hora(+)=B.interval_60_min group by b.interval_60_min order by b.interval_60_min ");

		} else if(tipoRep.trim().equals("CAT")) {

			sbSql.append("select y.* ,nvl((select nombre_corto from tbl_adm_categoria_admision where codigo =y.categoria),'TOTAL') as catDesc from (select * from (select categoria,to_number(nvl(to_char(fecha_ingreso,'dd'),-1)) as dia,count(*) as cnt from tbl_adm_admision xx where estado not in ('N') and fecha_ingreso >= to_date('01/");
			sbSql.append(p_mes);
			sbSql.append("/");
			sbSql.append(p_anio);
			sbSql.append("','dd/mm/yyyy') and xx.fecha_ingreso <= last_day(to_date('");
			sbSql.append(p_mes);
			sbSql.append("/");
			sbSql.append(p_anio);
			sbSql.append("', 'mm/yyyy'))");
			if(!categoria.trim().equals("")){ sbSql.append(" and xx.categoria="); sbSql.append(categoria);}
			if (!admType.trim().equals("")) { sbSql.append(" and exists (select null from tbl_adm_categoria_admision where codigo = xx.categoria and adm_type = '"); sbSql.append(admType); sbSql.append("')"); }
			sbSql.append(" group by cube(categoria,to_char(fecha_ingreso,'dd'))) pivot(sum(cnt) for dia in (1 as dia1,2 as dia2,3 as dia3,4 as dia4,5 as dia5,6 as dia6,7 as dia7,8 as dia8,9 as dia9,10 as dia10,11 as dia11,12 as dia12,13 as dia13,14 as dia14,15 as dia15,16 as dia16,17 as dia17,18 as dia18,19 as dia19,20 as dia20,21 as dia21,22 as dia22,23 as dia23,24 as dia24,25 as dia25,26 as dia26,27 as dia27,28 as dia28,29 as dia29,30 as dia30,31 as dia31,-1 as total)) order by categoria) y order by y.categoria ");

		}

    al = SQLMgr.getDataList(sbSql.toString());
    //rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
		//rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_sal_recuperacion_anestesia "+appendFilter);

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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Listado de Notas de Ajustes- '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function printList(){var cat=document.search01.categoria.value;var admType=document.search01.admType.value;
var tipoRep ='<%=tipoRep%>';
if(tipoRep=='HR') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/print_list_admision_hora.rptdesign&pCtrlHeader=true&pMes=<%=p_mes%>&pAnio=<%=p_anio%>&pCategoria='+cat+'&pAdmType='+admType);
else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/print_list_admision_hora_cat.rptdesign&pCtrlHeader=true&pMes=<%=p_mes%>&pAnio=<%=p_anio%>&pCategoria='+cat+'&pAdmType='+admType); }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ADMISIONES POR HORA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
		<td align="right">
		</td>
	</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<tr class="TextFilter">
	<td width="100%"><cellbytelabel>Año</cellbytelabel>
			<%=fb.intBox("anio",p_anio,false,false,false,10)%>&nbsp;&nbsp;&nbsp; Mes: Mes:&nbsp;<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",p_mes,false,false,0,"Text10",null,null,"","S")%>
			&nbsp;&nbsp;&nbsp;
			<cellbytelabel id="2">Categor&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
				&nbsp;&nbsp;&nbsp;
				<%=fb.select("admType","I=INPATIENT,O=OUTPATIENT",admType,false,false,0,"Text10",null,null,null,"T")%>
				&nbsp;&nbsp;&nbsp;
				<%=fb.select("tipoRep","HR=REPORTE POR HORA,CAT=REPORTE POR CATEGORIA",tipoRep,false,false,0,"Text10",null,null,null,"")%>
				<%=fb.submit("go","Ir")%>
	</td>
</tr>
 <%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
 <tr>
        <td align="right">&nbsp;
					<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype><!---->
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("anio",p_anio)%>
					<%=fb.hidden("mes",p_mes)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("tipoRep",tipoRep)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("anio",p_anio)%>
					<%=fb.hidden("mes",p_mes)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("tipoRep",tipoRep)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
<tr>
  <td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">
		<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("index","")%>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader" align="center">
				<%if(tipoRep.trim().equals("HR")){%>
				<td width="3%"><cellbytelabel>Hora</cellbytelabel></td>
				<%}else{%>
				<td width="3%"><cellbytelabel>CAT</cellbytelabel></td>
				<%
				dias=31;
				}%>
				<%for(int j = 1; j <= dias; j++){%>
					<td width="3%"><cellbytelabel>DIA&nbsp;<%=j%></cellbytelabel></td>
				<%}%>
				<td width="3%"><cellbytelabel>TOT</cellbytelabel></td>
			</tr>
		<%
		int totDia1 = 0,totDia2 = 0, totDia3 = 0,totDia4 = 0, totDia5 = 0;
		int totDia6 = 0,totDia7 = 0, totDia8 = 0,totDia9 = 0, totDia10 = 0;
		int totDia11 = 0,totDia12 = 0, totDia13 = 0,totDia14 = 0, totDia15 = 0;
		int totDia16 = 0,totDia17 = 0, totDia18 = 0,totDia19 = 0, totDia20 = 0;
		int totDia21 = 0,totDia22 = 0, totDia23 = 0,totDia24 = 0, totDia25 = 0;
		int totDia26 = 0,totDia27 = 0, totDia28 = 0,totDia29 = 0, totDia30 = 0, totDia31 = 0;
		int tot=0;
		for (int i=0; i<al.size(); i++){
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
		%>
		<%//=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
 		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		<td align="center"><%=((tipoRep.trim().equals("HR"))?cdo1.getColValue("hora"):cdo1.getColValue("catDesc"))%></td>
		<%for(int l = 1; l <= dias; l++){%>
					<td width="3%"><%=(!cdo1.getColValue("dia"+l).trim().equals("0")?cdo1.getColValue("dia"+l):"")%></td>


		<%}
		if(tipoRep.trim().equals("HR")){
		if(cdo1.getColValue("dia1") != null)tot  += Integer.parseInt(cdo1.getColValue("dia1"));
        if(cdo1.getColValue("dia2") != null)tot  += Integer.parseInt(cdo1.getColValue("dia2"));
        if(cdo1.getColValue("dia3") != null)tot  += Integer.parseInt(cdo1.getColValue("dia3"));
        if(cdo1.getColValue("dia4") != null)tot  += Integer.parseInt(cdo1.getColValue("dia4"));
        if(cdo1.getColValue("dia5") != null)tot  += Integer.parseInt(cdo1.getColValue("dia5"));
        if(cdo1.getColValue("dia6") != null)tot  += Integer.parseInt(cdo1.getColValue("dia6"));
        if(cdo1.getColValue("dia7") != null)tot  += Integer.parseInt(cdo1.getColValue("dia7"));
        if(cdo1.getColValue("dia8") != null)tot  += Integer.parseInt(cdo1.getColValue("dia8"));
        if(cdo1.getColValue("dia9") != null)tot  += Integer.parseInt(cdo1.getColValue("dia9"));
        if(cdo1.getColValue("dia10") != null)tot  += Integer.parseInt(cdo1.getColValue("dia10"));
        if(cdo1.getColValue("dia11") != null)tot  += Integer.parseInt(cdo1.getColValue("dia11"));
        if(cdo1.getColValue("dia12") != null)tot  += Integer.parseInt(cdo1.getColValue("dia12"));
        if(cdo1.getColValue("dia13") != null)tot  += Integer.parseInt(cdo1.getColValue("dia13"));
        if(cdo1.getColValue("dia14") != null)tot  += Integer.parseInt(cdo1.getColValue("dia14"));
        if(cdo1.getColValue("dia15") != null)tot  += Integer.parseInt(cdo1.getColValue("dia15"));
        if(cdo1.getColValue("dia16") != null)tot  += Integer.parseInt(cdo1.getColValue("dia16"));
        if(cdo1.getColValue("dia17") != null)tot  += Integer.parseInt(cdo1.getColValue("dia17"));
        if(cdo1.getColValue("dia18") != null)tot  += Integer.parseInt(cdo1.getColValue("dia18"));
        if(cdo1.getColValue("dia19") != null)tot  += Integer.parseInt(cdo1.getColValue("dia19"));
        if(cdo1.getColValue("dia20") != null)tot  += Integer.parseInt(cdo1.getColValue("dia20"));
        if(cdo1.getColValue("dia21") != null)tot  += Integer.parseInt(cdo1.getColValue("dia21"));
        if(cdo1.getColValue("dia22") != null)tot  += Integer.parseInt(cdo1.getColValue("dia22"));
        if(cdo1.getColValue("dia23") != null)tot  += Integer.parseInt(cdo1.getColValue("dia23"));
        if(cdo1.getColValue("dia24") != null)tot  += Integer.parseInt(cdo1.getColValue("dia24"));
        if(cdo1.getColValue("dia25") != null)tot  += Integer.parseInt(cdo1.getColValue("dia25"));
        if(cdo1.getColValue("dia26") != null)tot  += Integer.parseInt(cdo1.getColValue("dia26"));
        if(cdo1.getColValue("dia27") != null)tot  += Integer.parseInt(cdo1.getColValue("dia27"));
        if(cdo1.getColValue("dia28") != null)tot  += Integer.parseInt(cdo1.getColValue("dia28"));
        if(cdo1.getColValue("dia29") != null)tot  += Integer.parseInt(cdo1.getColValue("dia29"));
        if(cdo1.getColValue("dia30") != null)tot  += Integer.parseInt(cdo1.getColValue("dia30"));
        if(cdo1.getColValue("dia31") != null)tot  += Integer.parseInt(cdo1.getColValue("dia31"));
		}
		%>
		<td><%=((tipoRep.trim().equals("HR"))?tot:cdo1.getColValue("total"))%></td>
					<% tot =0;%>
		<%
		if(tipoRep.trim().equals("HR")){
		if(cdo1.getColValue("dia1") != null)totDia1  += Integer.parseInt(cdo1.getColValue("dia1"));
		if(cdo1.getColValue("dia2") != null)totDia2  += Integer.parseInt(cdo1.getColValue("dia2"));
		if(cdo1.getColValue("dia3") != null)totDia3  += Integer.parseInt(cdo1.getColValue("dia3"));
		if(cdo1.getColValue("dia4") != null)totDia4  += Integer.parseInt(cdo1.getColValue("dia4"));
		if(cdo1.getColValue("dia5") != null)totDia5  += Integer.parseInt(cdo1.getColValue("dia5"));
		if(cdo1.getColValue("dia6") != null)totDia6  += Integer.parseInt(cdo1.getColValue("dia6"));
		if(cdo1.getColValue("dia7") != null)totDia7  += Integer.parseInt(cdo1.getColValue("dia7"));
		if(cdo1.getColValue("dia8") != null)totDia8  += Integer.parseInt(cdo1.getColValue("dia8"));
		if(cdo1.getColValue("dia9") != null)totDia9  += Integer.parseInt(cdo1.getColValue("dia9"));
		if(cdo1.getColValue("dia10") != null)totDia10  += Integer.parseInt(cdo1.getColValue("dia10"));
		if(cdo1.getColValue("dia11") != null)totDia11  += Integer.parseInt(cdo1.getColValue("dia11"));
		if(cdo1.getColValue("dia12") != null)totDia12  += Integer.parseInt(cdo1.getColValue("dia12"));
		if(cdo1.getColValue("dia13") != null)totDia13  += Integer.parseInt(cdo1.getColValue("dia13"));
		if(cdo1.getColValue("dia14") != null)totDia14  += Integer.parseInt(cdo1.getColValue("dia14"));
		if(cdo1.getColValue("dia15") != null)totDia15  += Integer.parseInt(cdo1.getColValue("dia15"));
		if(cdo1.getColValue("dia16") != null)totDia16  += Integer.parseInt(cdo1.getColValue("dia16"));
		if(cdo1.getColValue("dia17") != null)totDia17  += Integer.parseInt(cdo1.getColValue("dia17"));
		if(cdo1.getColValue("dia18") != null)totDia18  += Integer.parseInt(cdo1.getColValue("dia18"));
		if(cdo1.getColValue("dia19") != null)totDia19  += Integer.parseInt(cdo1.getColValue("dia19"));
		if(cdo1.getColValue("dia20") != null)totDia20  += Integer.parseInt(cdo1.getColValue("dia20"));
		if(cdo1.getColValue("dia21") != null)totDia21  += Integer.parseInt(cdo1.getColValue("dia21"));
		if(cdo1.getColValue("dia22") != null)totDia22  += Integer.parseInt(cdo1.getColValue("dia22"));
		if(cdo1.getColValue("dia23") != null)totDia23  += Integer.parseInt(cdo1.getColValue("dia23"));
		if(cdo1.getColValue("dia24") != null)totDia24  += Integer.parseInt(cdo1.getColValue("dia24"));
		if(cdo1.getColValue("dia25") != null)totDia25  += Integer.parseInt(cdo1.getColValue("dia25"));
		if(cdo1.getColValue("dia26") != null)totDia26  += Integer.parseInt(cdo1.getColValue("dia26"));
		if(cdo1.getColValue("dia27") != null)totDia27  += Integer.parseInt(cdo1.getColValue("dia27"));
		if(cdo1.getColValue("dia28") != null)totDia28  += Integer.parseInt(cdo1.getColValue("dia28"));
		if(cdo1.getColValue("dia29") != null)totDia29  += Integer.parseInt(cdo1.getColValue("dia29"));
		if(cdo1.getColValue("dia30") != null)totDia30  += Integer.parseInt(cdo1.getColValue("dia30"));
		if(cdo1.getColValue("dia31") != null)totDia31  += Integer.parseInt(cdo1.getColValue("dia31"));
			}
		%>


		</tr>
		<% } %>
		<%if(tipoRep.trim().equals("HR")){%>
		<tr class="TextHeader" align="center">
				<td>Total</td>

					<%if(dias>=1){%><td><%=totDia1%></td><%}%>
					<%if(dias>=2){%><td><%=totDia2%></td><%}%>
					<%if(dias>=3){%><td><%=totDia3%></td><%}%>
					<%if(dias>=4){%><td><%=totDia4%></td><%}%>
					<%if(dias>=5){%><td><%=totDia5%></td><%}%>
					<%if(dias>=6){%><td><%=totDia6%></td><%}%>
					<%if(dias>=7){%><td><%=totDia7%></td><%}%>
					<%if(dias>=8){%><td><%=totDia8%></td><%}%>
					<%if(dias>=9){%><td><%=totDia9%></td><%}%>
					<%if(dias>=10){%><td><%=totDia10%></td><%}%>
					<%if(dias>=11){%><td><%=totDia11%></td><%}%>
					<%if(dias>=12){%><td><%=totDia12%></td><%}%>
					<%if(dias>=13){%><td><%=totDia13%></td><%}%>
					<%if(dias>=14){%><td><%=totDia14%></td><%}%>
					<%if(dias>=15){%><td><%=totDia15%></td><%}%>
					<%if(dias>=16){%><td><%=totDia16%></td><%}%>
					<%if(dias>=17){%><td><%=totDia17%></td><%}%>
					<%if(dias>=18){%><td><%=totDia18%></td><%}%>
					<%if(dias>=19){%><td><%=totDia19%></td><%}%>
					<%if(dias>=20){%><td><%=totDia20%></td><%}%>
					<%if(dias>=21){%><td><%=totDia21%></td><%}%>
					<%if(dias>=22){%><td><%=totDia22%></td><%}%>
					<%if(dias>=23){%><td><%=totDia23%></td><%}%>
					<%if(dias>=24){%><td><%=totDia24%></td><%}%>
					<%if(dias>=25){%><td><%=totDia25%></td><%}%>
					<%if(dias>=26){%><td><%=totDia26%></td><%}%>
					<%if(dias>=27){%><td><%=totDia27%></td><%}%>
					<%if(dias>=28){%><td><%=totDia28%></td><%}%>
					<%if(dias>=29){%><td><%=totDia29%></td><%}%>
					<%if(dias>=30){%><td><%=totDia30%></td><%}%>
					<%if(dias>=31){%><td><%=totDia31%></td><%}%>
							<td>&nbsp;</td>
			</tr>
		<%}%>
		</table>
		<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		<%=fb.formEnd()%>
	</div>
	</div>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("anio",p_anio)%>
				<%=fb.hidden("mes",p_anio)%>
				<%=fb.hidden("categoria",categoria)%>
				<%=fb.hidden("tipoRep",tipoRep)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("anio",p_anio)%>
					<%=fb.hidden("mes",p_anio)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("tipoRep",tipoRep)%>
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
