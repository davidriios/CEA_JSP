
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="issi.presupuesto.PresDetail"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr"/>
<%
/**
==========================================================================================
PRESF009
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
PresMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alUnd = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int rowCount = 0;
StringBuffer sql = new StringBuffer();
String appendFilter = "";
String unidad = request.getParameter("unidad");
String anio        = request.getParameter("anio");
String mode       = request.getParameter("mode");

String fgFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(mode==null) mode = "edit";
if(fg==null) fg = "PO";
if(fp==null) fp = "";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if(anio ==null)anio=""+(Integer.parseInt(cDateTime.substring(6, 10))+1);

StringBuffer sbSql = new StringBuffer();
sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_sec_unidad_ejec where compania=");
sbSql.append(session.getAttribute("_companyId"));
if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_ua")!=null){
	sbSql.append(" and codigo in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
	sbSql.append(")");}
	else sbSql.append(" and codigo in (-1)");
}
sbSql.append(" order by descripcion,codigo");
alUnd = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(), CommonDataObject.class);

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

if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals("") ){
		appendFilter += " and aca.unidad = "+request.getParameter("unidad");
		unidad = request.getParameter("unidad");
}


String tableName = "",sbField="";

	if(!UserDet.getUserProfile().contains("0"))
	{
	    appendFilter +=" and ue.codigo in(";
		if(session.getAttribute("_ua")!=null) appendFilter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
		else appendFilter +="-1";
		appendFilter +=")";
    }
sql.append("select xx.unidad, xx.unidadDesc, xx.tipo_cuenta tipoCuenta, xx.codigo_prin codigoPrin, xx.dsp_tipo_cuenta dspTipoCuenta, xx.dsc_cuenta descTipoCuenta, sum(enero) enero, sum(febrero) febrero, sum(marzo) marzo, sum(abril) abril , sum(mayo) mayo, sum(junio) junio,  sum(julio) julio,  sum(agosto) agosto, sum(septiembre) septiembre, sum(octubre) octubre, sum(noviembre) noviembre, sum(diciembre) diciembre, sum(enero_c) enero_c, sum(febrero_c) febrero_c, sum(marzo_c) marzo_c, sum(abril_c) abril_c , sum(mayo_c) mayo_c, sum(junio_c) junio_c,  sum(julio_c) julio_c,  sum(agosto_c) agosto_c, sum(septiembre_c) septiembre_c, sum(octubre_c) octubre_c, sum(noviembre_c) noviembre_c, sum(diciembre_c) diciembre_c, sum(enero_v) enero_v, sum(febrero_v) febrero_v, sum(marzo_v) marzo_v, sum(abril_v) abril_v , sum(mayo_v) mayo_v, sum(junio_v) junio_v,  sum(julio_v) julio_v,  sum(agosto_v) agosto_v, sum(septiembre_v) septiembre_v, sum(octubre_v) octubre_v, sum(noviembre_v) noviembre_v, sum(diciembre_v) diciembre_v,sum(xx.enero+xx.febrero+xx.marzo+xx.abril+xx.mayo+xx.junio+xx.julio+xx.agosto+xx.septiembre+xx.octubre+xx.noviembre+xx.diciembre) ac_asignacion, sum(xx.enero_c+xx.febrero_c+xx.marzo_c+xx.abril_c+xx.mayo_c+xx.junio_c+xx.julio_c+xx.agosto_c+xx.septiembre_c+xx.octubre_c+xx.noviembre_c+xx.diciembre_c) ac_consumo, sum(xx.enero_v+xx.febrero_v+xx.marzo_v+xx.abril_v+xx.mayo_v+xx.junio_v+xx.julio_v+xx.agosto_v+xx.septiembre_v+xx.octubre_v+xx.noviembre_v+xx.diciembre_v) ac_variacion  from ( ");

sql.append("select ACA.ANIO, ACA.UNIDAD, ue.descripcion unidadDesc, aca.mes, cp.codigo_prin, cg.tipo_cuenta, decode(cp.codigo_prin,'4','INGRESOS','5','COSTOS','6','GASTOS','') DSP_TIPO_CUENTA, decode(cp.codigo_prin,'4',1,'5',2,'6',3) Dsp_orden, cg.descripcion DSC_CUENTA,");
sql.append(" decode(to_number(aca.mes), 1, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) enero, decode(to_number(aca.mes),1, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  enero_c,");
sql.append(" decode(to_number(aca.mes), 1,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) enero_v,");
sql.append(" decode(to_number(aca.mes), 2, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) febrero,  decode(to_number(aca.mes),2, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  febrero_c,");
sql.append(" decode(to_number(aca.mes), 2,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) febrero_v,");
sql.append(" decode(to_number(aca.mes), 3, nvl(ASIGNACION,0) + nvl(traslado,0) + nvl(redistribuciones,0),0) marzo,  decode(to_number(aca.mes),3, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  marzo_c,");
sql.append(" decode(to_number(aca.mes), 3,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) marzo_v,");
sql.append(" decode(to_number(aca.mes), 4, nvl(ASIGNACION,0) + nvl(traslado,0) + nvl(redistribuciones,0),0) abril,  decode(to_number(aca.mes),4, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  abril_c,");
sql.append("decode(to_number(aca.mes), 4,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) abril_v,");
sql.append(" decode(to_number(aca.mes), 5, nvl(ASIGNACION,0) + nvl(traslado,0) + nvl(redistribuciones,0),0) mayo,  decode(to_number(aca.mes),5, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  mayo_c,");
sql.append(" decode(to_number(aca.mes), 5,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) mayo_v,");
sql.append("decode(to_number(aca.mes), 6, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) junio,  decode(to_number(aca.mes),6, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  junio_c,");
sql.append(" decode(to_number(aca.mes), 6,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) junio_v,");
sql.append(" decode(to_number(aca.mes), 7, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) julio,  decode(to_number(aca.mes),7, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  julio_c,");
sql.append(" decode(to_number(aca.mes), 7,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) julio_v,");
sql.append(" decode(to_number(aca.mes), 8, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) agosto, decode(to_number(aca.mes),8, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  agosto_c,");
sql.append(" decode(to_number(aca.mes), 8,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) agosto_v,");
sql.append(" decode(to_number(aca.mes), 9, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) septiembre, decode(to_number(aca.mes),9, nvl(CONSUMIDO,0)+nvl(vcg.balance,0),0 )  septiembre_c,");
sql.append(" decode(to_number(aca.mes), 9,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) septiembre_v,");
sql.append(" decode(to_number(aca.mes), 10, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) octubre,  decode(to_number(aca.mes),10, nvl(CONSUMIDO,0) + nvl(vcg.balance,0),0 )  octubre_c,");
sql.append(" decode(to_number(aca.mes), 10,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) octubre_v,");
sql.append(" decode(to_number(aca.mes), 11, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) noviembre, decode(to_number(aca.mes),11, nvl(CONSUMIDO,0) + nvl(vcg.balance,0),0 )  noviembre_c,");
sql.append(" decode(to_number(aca.mes), 11,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) noviembre_v,");
sql.append(" decode(to_number(aca.mes), 12, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) diciembre,  decode(to_number(aca.mes),12, nvl(CONSUMIDO,0) + nvl(vcg.balance,0),0 )  diciembre_c,");
sql.append(" decode(to_number(aca.mes), 12,decode(cp.codigo_prin,'4',(nvl(consumido,0) + nvl(vcg.balance,0)) - (nvl(asignacion,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0)), (nvl(CONSUMIDO,0) + nvl(vcg.balance,0)) - (nvl(ASIGNACION,0) + nvl(aca.traslado,0) + nvl(aca.redistribuciones,0))),0) diciembre_v");
sql.append(" from tbl_con_cuenta_mensual aca, tbl_con_ctas_prin cp, tbl_con_cla_ctas cc, tbl_con_catalogo_gral cg, tbl_sec_unidad_ejec ue, vw_con_catalogo_gral_bal vcg  where  cg.cta1  = aca.cta1 and cg.cta2 = aca.cta2 and cg.cta3 = aca.cta3 and cg.cta4 = aca.cta4 and cg.cta5  = aca.cta5 and cg.cta6  = aca.cta6 and aca.cta1  = vcg.cta1(+) and aca.cta2 = vcg.cta2(+) and aca.cta3 = vcg.cta3(+) and aca.cta4 = vcg.cta4(+) and aca.cta5 = vcg.cta5(+) and aca.cta6  = vcg.cta6(+)  and aca.compania = vcg.compania(+) and aca.anio = vcg.ea_ano(+) and aca.mes = vcg.mes(+) and cg.compania = nvl(aca.compania_origen,aca.compania) and cp.codigo_prin  in ('4','5','6') and cc.codigo_prin  = cp.codigo_prin  and cg.tipo_cuenta = cc.codigo_clase  and cg.recibe_mov = 'S' and aca.compania  = ");

sql.append(((String) session.getAttribute("_companyId")));
sql.append(appendFilter);
sql.append(" and aca.anio = ");
sql.append(anio);
sql.append(" and ue.codigo = aca.unidad and aca.compania = ue.compania ORDER by aca.unidad, cg.tipo_cuenta, to_number(aca.mes), decode(cp.codigo_prin,'4',1,'5',2,'6',3),cg.cta1, cg.cta2, cg.cta3");
sql.append(" )xx group by xx.unidad, xx.unidadDesc, xx.tipo_cuenta , xx.codigo_prin, xx.dsp_tipo_cuenta , xx.dsc_cuenta order by xx.unidad, xx.codigo_prin, xx.tipo_cuenta");

//System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: theBrain año = "+anio);


al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

rowCount = CmnMgr.getCount("select count(*) count from ("+sql.toString()+")");


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
document.title = 'Presupuesto <%=(fg.equals("OP"))?"Operativo":" De Inversiones"%> - '+document.title;

function reloadPage(unidad){
var anio = document.search01.anio.value;
window.location = '../presupuesto/consultas_pres_ope.jsp?fg=<%=fg%>&unidad='+unidad+'&anio='+anio;
}

function printPres(){
	var unidad = document.search01.unidad.value;
	if('<%=anio%>' !='')
	abrir_ventana("../presupuesto/print_consultas_pres_ope.jsp?anio=<%=anio%>&unidad="+unidad);
	else alert('Año Invalido!');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="PRESUPUESTO"></jsp:param>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>

<td width="15%">
	<cellbytelabel>A&ntilde;o</cellbytelabel>
	<%=fb.intBox("anio",anio,false,false,false,10)%>
</td>
<td width="15%">
	 <%//=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","")%>
</td>
<td>
	Unidad <%=fb.select("unidad",alUnd,unidad,false, false, 0, "", "", "onChange=\"javascript:reloadPage(this.value);\"", "Unidad Administrativa", "S")%>

	<%=fb.submit("go","Ir")%>
	<%=fb.button("print","Imprimir",false,false,"","height:30px","onClick=\"javascript:printPres()\"")%>
</td>
<%=fb.formEnd()%>

</tr>
</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

</td>
</tr>
<!--<tr>
<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
</tr>-->
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("mode",mode)%>
<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("mode",mode)%>
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
<div id="mesesMain" width="99%" style="overflow:scroll;position:relative;height:500">
<div id="meses" width="98%" style="overflow;position:absolute">


<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->


<table align="center" cellpadding="1" cellspacing="1">
<tr class="TextHeader" align="center">
<td rowspan="3"><cellbytelabel>Cuenta</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td colspan="36"><cellbytelabel>Meses</cellbytelabel></td>
<td colspan="3" rowspan="2"><cellbytelabel>Acumulado</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td colspan="3"><cellbytelabel>Enero</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Febrero</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Marzo</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Abril</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Mayo</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Junio</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Julio</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Agosto</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Septiembre</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Octubre</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Noviembre</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Diciembre</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>

	<td width="4%"><cellbytelabel>Objetivo</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Consumido</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Variaci&oacute;n</cellbytelabel></td>
</tr>
<%
int valSize = 5;
String valClass = "Text10";
double valLength= 13.2;
String groupBy ="",descTipoCta="", groupUnidad = "";
String color = "TextRow02";
double totalEnero =0,totalFebrero =0,totalMarzo =0,totalAbril =0,totalMayo =0,totalJunio =0,totalJulio =0,totalAgosto=0,totalSeptiembre =0,totalOctubre =0,totalNoviembre =0,totalDiciembre =0, totalAcAsignacion = 0;
double totalEnero_c =0,totalFebrero_c =0,totalMarzo_c =0,totalAbril_c =0,totalMayo_c =0,totalJunio_c =0,totalJulio_c =0,totalAgosto_c =0,totalSeptiembre_c =0,totalOctubre_c =0,totalNoviembre_c =0,totalDiciembre_c =0, totalAcConsumo = 0;
double totalEnero_v =0,totalFebrero_v =0,totalMarzo_v =0,totalAbril_v =0,totalMayo_v =0,totalJunio_v =0,totalJulio_v =0,totalAgosto_v =0,totalSeptiembre_v =0,totalOctubre_v =0,totalNoviembre_v =0,totalDiciembre_v =0, totalAcVariacion = 0;

for (int i=0; i<al.size(); i++)
{
CommonDataObject cdo = (CommonDataObject) al.get(i);

if (!groupUnidad.trim().equals(cdo.getColValue("unidad"))){
	 if ( i!=0 ){
%>

<tr class="Link01Bold">
	<td>&nbsp;&nbsp;&nbsp;Total de:&nbsp;&nbsp;<%=descTipoCta%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalEnero)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalEnero_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalEnero_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalFebrero)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalFebrero_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalFebrero_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMarzo)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMarzo_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMarzo_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAbril)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAbril_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAbril_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMayo)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMayo_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMayo_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJunio)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJunio_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJunio_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJulio)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJulio_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJulio_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAgosto)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAgosto_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAgosto_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalSeptiembre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalSeptiembre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalSeptiembre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalOctubre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalOctubre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalOctubre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalNoviembre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalNoviembre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalNoviembre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalDiciembre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalDiciembre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalDiciembre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAcAsignacion)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAcConsumo)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAcVariacion)%></td>
</tr>
<%
totalEnero =0;totalFebrero =0;totalMarzo =0;totalAbril =0;totalMayo =0;totalJunio =0;totalJulio =0;totalAgosto=0;totalSeptiembre =0;totalOctubre =0;totalNoviembre =0;totalDiciembre =0; totalAcAsignacion = 0;
totalEnero_c =0;totalFebrero_c =0;totalMarzo_c =0;totalAbril_c =0;totalMayo_c =0;totalJunio_c =0;totalJulio_c =0;totalAgosto_c =0;totalSeptiembre_c =0;totalOctubre_c =0;totalNoviembre_c =0;totalDiciembre_c =0; totalAcConsumo = 0;
totalEnero_v =0;totalFebrero_v =0;totalMarzo_v =0;totalAbril_v =0;totalMayo_v =0;totalJunio_v =0;totalJulio_v =0;totalAgosto_v =0;totalSeptiembre_v =0;totalOctubre_v =0;totalNoviembre_v =0;totalDiciembre_v =0; totalAcVariacion = 0;
} //i<> 0%>
	<tr class="TextHeader01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		<td colspan="40"><%=cdo.getColValue("unidadDesc")%></td>
	</tr>

	<tr class="TextHeader02" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		<td colspan="40"><%=cdo.getColValue("dspTipoCuenta")%></td>
	</tr>

<%
 } // groupUnidad
%>

<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

		<td><%=cdo.getColValue("descTipoCuenta")%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("enero"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("enero_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("enero_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("febrero"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("febrero_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("febrero_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("marzo"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("marzo_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("marzo_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("abril"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("abril_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("abril_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("mayo"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("mayo_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("mayo_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("junio"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("junio_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("junio_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("julio"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("julio_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("julio_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("agosto"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("agosto_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("agosto_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("septiembre"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("septiembre_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("septiembre_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("octubre"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("octubre_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("octubre_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("noviembre"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("noviembre_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("noviembre_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("diciembre"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("diciembre_c"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("diciembre_v"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ac_asignacion"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ac_consumo"))%></td>
	<td width="4%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ac_variacion"))%></td>

</tr>
<%
groupBy=cdo.getColValue("codigoPrin");
descTipoCta=cdo.getColValue("dspTipoCuenta");
groupUnidad = cdo.getColValue("unidad");


totalEnero += Double.parseDouble(cdo.getColValue("enero"));
totalFebrero += Double.parseDouble(cdo.getColValue("febrero"));
totalMarzo += Double.parseDouble(cdo.getColValue("marzo"));
totalAbril += Double.parseDouble(cdo.getColValue("abril"));
totalMayo += Double.parseDouble(cdo.getColValue("mayo"));
totalJunio += Double.parseDouble(cdo.getColValue("junio"));
totalJulio += Double.parseDouble(cdo.getColValue("julio"));
totalAgosto += Double.parseDouble(cdo.getColValue("agosto"));
totalSeptiembre += Double.parseDouble(cdo.getColValue("septiembre"));
totalOctubre += Double.parseDouble(cdo.getColValue("octubre"));
totalNoviembre += Double.parseDouble(cdo.getColValue("noviembre"));
totalDiciembre += Double.parseDouble(cdo.getColValue("diciembre"));
totalAcAsignacion += Double.parseDouble(cdo.getColValue("ac_asignacion"));
totalEnero_c += Double.parseDouble(cdo.getColValue("enero_c"));
totalFebrero_c += Double.parseDouble(cdo.getColValue("febrero_c"));
totalMarzo_c += Double.parseDouble(cdo.getColValue("marzo_c"));
totalAbril_c += Double.parseDouble(cdo.getColValue("abril_c"));
totalMayo_c += Double.parseDouble(cdo.getColValue("mayo_c"));
totalJunio_c += Double.parseDouble(cdo.getColValue("junio_c"));
totalJulio_c += Double.parseDouble(cdo.getColValue("julio_c"));
totalAgosto_c += Double.parseDouble(cdo.getColValue("agosto_c"));
totalSeptiembre_c += Double.parseDouble(cdo.getColValue("septiembre_c"));
totalOctubre_c += Double.parseDouble(cdo.getColValue("octubre_c"));
totalNoviembre_c += Double.parseDouble(cdo.getColValue("noviembre_c"));
totalDiciembre_c += Double.parseDouble(cdo.getColValue("diciembre_c"));
totalAcConsumo += Double.parseDouble(cdo.getColValue("ac_consumo"));
totalEnero_v += Double.parseDouble(cdo.getColValue("enero_v"));
totalFebrero_v += Double.parseDouble(cdo.getColValue("febrero_v"));
totalMarzo_v += Double.parseDouble(cdo.getColValue("marzo_v"));
totalAbril_v += Double.parseDouble(cdo.getColValue("abril_v"));
totalMayo_v += Double.parseDouble(cdo.getColValue("mayo_v"));
totalJunio_v += Double.parseDouble(cdo.getColValue("julio_v"));
totalJulio_v += Double.parseDouble(cdo.getColValue("julio_v"));
totalAgosto_v += Double.parseDouble(cdo.getColValue("agosto_v"));
totalSeptiembre_v += Double.parseDouble(cdo.getColValue("septiembre_v"));
totalOctubre_v += Double.parseDouble(cdo.getColValue("octubre_v"));
totalNoviembre_v += Double.parseDouble(cdo.getColValue("noviembre_v"));
totalDiciembre_v += Double.parseDouble(cdo.getColValue("diciembre_v"));
totalAcVariacion += Double.parseDouble(cdo.getColValue("ac_variacion"));

} // for i
%>
<tr class="Link01Bold">
	<td>&nbsp;&nbsp;&nbsp;Total de:&nbsp;&nbsp;<%=descTipoCta%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalEnero)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalEnero_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalEnero_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalFebrero)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalFebrero_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalFebrero_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMarzo)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMarzo_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMarzo_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAbril)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAbril_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAbril_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMayo)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMayo_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalMayo_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJunio)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJunio_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJunio_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJulio)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJulio_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalJulio_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAgosto)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAgosto_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAgosto_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalSeptiembre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalSeptiembre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalSeptiembre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalOctubre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalOctubre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalOctubre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalNoviembre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalNoviembre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalNoviembre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalDiciembre)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalDiciembre_c)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalDiciembre_v)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAcAsignacion)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAcConsumo)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(totalAcVariacion)%></td>
</tr>

</table>


</div>
</div>
</td>
</tr>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("mode",mode)%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("mode",mode)%>
<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
</tr>
</table>
</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//End Method GET
%>
