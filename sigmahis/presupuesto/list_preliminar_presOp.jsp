<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="issi.presupuesto.PresDetail"%>
<%@ page import="java.util.Vector" %>
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
fg= PO  ---> Preliminar ante proyecto del Presupuesto Operativo
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alUE = new ArrayList();

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
alUE = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(), CommonDataObject.class);

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
		String mes="";

	if (unidad != null && !unidad.trim().equals("")) { appendFilter += " and aca.unidad = "+unidad;	}


	String tableName = "",sbField="";

	if (request.getParameter("anio")!= null){
	if(!UserDet.getUserProfile().contains("0"))
	{
	    appendFilter +=" and ue.codigo in(";
		if(session.getAttribute("_ua")!=null) appendFilter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
		else appendFilter +="-1";
		appendFilter +=")";
    }

		sql.append("select x.cta1,x.cta2,x.cta3,x.cta4,x.cta5,x.cta6,x.tipo_cuenta, x.descCuenta, x.dsp_tipo_cuenta descTipoCta, x.codigo_prin codigoPrin, sum(x.enero) enero, sum(x.febrero) febrero, sum(x.marzo)marzo, sum(x.abril) abril, sum(x.mayo) mayo, sum(x.junio) junio, sum(x.julio) julio, sum(x.agosto) agosto, sum(x.septiembre) septiembre, sum(x.octubre) octubre, sum(x.noviembre) noviembre,sum(x.diciembre) diciembre,sum(x.aenero)aenero, sum(x.afebrero)afebrero,sum(x.amarzo)amarzo, sum(x.aabril)aabril, sum(x.amayo) amayo, sum(x.ajunio)ajunio,sum(x.ajulio)ajulio, sum(x.aagosto)aagosto, sum(x.aseptiembre)aseptiembre, sum(x.aoctubre)aoctubre, sum(x.anoviembre)anoviembre, sum(x.adiciembre)adiciembre ,x.descUnidad,sum(x.enero+x.febrero+x.marzo+x.abril+x.mayo+x.junio+x.julio+x.agosto+x.septiembre+ x.octubre+x.noviembre+x.diciembre) totalanual ,sum(x.aenero+x.afebrero+x.amarzo+x.aabril+x.amayo+x.ajunio+x.ajulio+x.aagosto+x.aseptiembre+x.aoctubre+x.anoviembre+x.adiciembre) totalAnteriorAnual, x.compania_origen  from (select  aca.mes, cp.codigo_prin, cg.tipo_cuenta,decode(cp.codigo_prin,'4','INGRESOS','5','COSTOS','6','GASTOS','')DSP_TIPO_CUENTA,decode(cp.codigo_prin,'4',1,'5',2,'6',3)Dsp_orden, cc.descripcion, cg.descripcion descCuenta, nvl(to_number(decode(to_number(aca.mes),1,nvl(ASIGNACION,0))),0) enero, nvl(to_number(decode(to_number(aca.mes),2,nvl(ASIGNACION,0))),0) febrero,nvl(to_number(decode(to_number(aca.mes),3,nvl(ASIGNACION,0))),0) marzo, nvl(to_number(decode(to_number(aca.mes),4,nvl(ASIGNACION,0))),0) abril, nvl(to_number(decode(to_number(aca.mes),5,nvl(ASIGNACION,0))),0) mayo, nvl(to_number(decode(to_number(aca.mes),6,nvl(ASIGNACION,0))),0) junio,nvl(to_number(decode(to_number(aca.mes),7,nvl(ASIGNACION,0))),0) julio, nvl(to_number(decode(to_number(aca.mes),8,nvl(ASIGNACION,0))),0) agosto,nvl(to_number(decode(to_number(aca.mes),9,nvl(ASIGNACION,0))),0) septiembre, nvl(to_number(decode(to_number(aca.mes),10,nvl(ASIGNACION,0))),0) octubre, nvl(to_number(decode(to_number(aca.mes),11,nvl(ASIGNACION,0))),0) noviembre, nvl(to_number(decode(to_number(aca.mes),12,nvl(ASIGNACION,0))),0) diciembre, AcA.ANIO, cG.CTA1, cG.CTA2, cG.CTA3, cG.CTA4, cG.CTA5, cG.CTA6 ,cg.cta1||cg.cta2||cg.cta3||cg.cta4||cg.cta5||cg.cta6 cuenta , aca.COMPANIA CIA , nvl(aca.compania_origen,aca.compania) compania_origen , C.NOMBRE , nvl(to_number(decode(to_number(aca.mes),1,nvl(aca.anterior,0))),0) aenero,nvl(to_number(decode(to_number(aca.mes),2,nvl(aca.anterior,0))),0) afebrero, nvl(to_number(decode(to_number(aca.mes),3,nvl(aca.anterior,0))),0) amarzo,nvl(to_number(decode(to_number(aca.mes),4,nvl(aca.anterior,0))),0) aabril, nvl(to_number(decode(to_number(aca.mes),5,nvl(aca.anterior,0))),0) amayo,nvl(to_number(decode(to_number(aca.mes),6,nvl(aca.anterior,0))),0) ajunio, nvl(to_number(decode(to_number(aca.mes),7,nvl(aca.anterior,0))),0) ajulio,nvl(to_number(decode(to_number(aca.mes),8,nvl(aca.anterior,0))),0) aagosto, nvl(to_number(decode(to_number(aca.mes),9,nvl(aca.anterior,0))),0) aseptiembre,nvl(to_number(decode(to_number(aca.mes),10,nvl(aca.anterior,0))),0) aoctubre, nvl(to_number(decode(to_number(aca.mes),11,nvl(aca.anterior,0))),0) anoviembre,nvl(to_number(decode(to_number(aca.mes),12,nvl(aca.anterior,0))),0) adiciembre,ue.descripcion descUnidad from  tbl_con_ante_cuenta_mensual aca, tbl_con_ctas_prin cp, tbl_con_cla_ctas cc, tbl_con_catalogo_gral cg , tbl_sec_COMPANIA C ,tbl_sec_unidad_ejec ue where cg.CTA1 = aca.cta1 and cg.CTA2  = aca.cta2 and cg.CTA3 = aca.cta3 and cg.CTA4 = aca.cta4 and cg.CTA5  = aca.cta5 and cg.CTA6  = aca.cta6 and cg.COMPANIA  = nvl(aca.compania_origen,aca.compania) and cp.codigo_prin  in ('4','5','6') and cc.codigo_prin  = cp.codigo_prin AND cg.tipo_cuenta  = cc.codigo_clase   AND C.CODIGO = aca.COMPANIA  AND CG.RECIBE_MOV = 'S' and aca.unidad = ue.codigo and aca.compania = ue.compania and aca.compania =");

	sql.append(((String) session.getAttribute("_companyId")));
	sql.append(appendFilter);
	if(!anio.trim().equals("")){sql.append(" and aca.anio =");sql.append(anio);}
	sql.append(" order by cg.tipo_cuenta)x group by x.compania_origen,x.cta1,x.cta2,x.cta3,x.cta4,x.cta5,x.cta6, x.tipo_cuenta,  x.descCuenta, x.dsp_tipo_cuenta, x.codigo_prin,x.descUnidad order by x.descUnidad,x.tipo_cuenta");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	if(al.size()==0)
	{mode ="add";
	sql = new StringBuffer();
		sql.append("select  x.cta1,x.cta2,x.cta3,x.cta4,x.cta5,x.cta6,x.tipo_cuenta, x.descCuenta, x.dsp_tipo_cuenta descTipoCta, x.codigo_prin codigoPrin, sum(x.enero) enero, sum(x.febrero) febrero, sum(x.marzo)marzo, sum(x.abril) abril, sum(x.mayo) mayo, sum(x.junio) junio, sum(x.julio) julio, sum(x.agosto) agosto, sum(x.septiembre) septiembre, sum(x.octubre) octubre, sum(x.noviembre) noviembre,sum(x.diciembre) diciembre,sum(x.aenero)aenero, sum(x.afebrero)afebrero,sum(x.amarzo)amarzo, sum(x.aabril)aabril, sum(x.amayo) amayo, sum(x.ajunio)ajunio,sum(x.ajulio)ajulio, sum(x.aagosto)aagosto, sum(x.aseptiembre)aseptiembre, sum(x.aoctubre)aoctubre, sum(x.anoviembre)anoviembre, sum(x.adiciembre)adiciembre,x.descUnidad , sum(x.enero+x.febrero+x.marzo+x.abril+x.mayo+x.junio+x.julio+x.agosto+x.septiembre+ x.octubre+x.noviembre+x.diciembre) totalAnual,sum(x.aenero+x.afebrero+x.amarzo+x.aabril+x.amayo+x.ajunio+x.ajulio+x.aagosto+x.aseptiembre+x.aoctubre+x.anoviembre+x.adiciembre) totalAnteriorAnual,x.compania_origen from (select  aca.mes, cp.codigo_prin, cg.tipo_cuenta,decode(cp.codigo_prin,'4','INGRESOS','5','COSTOS','6','GASTOS','')DSP_TIPO_CUENTA,decode(cp.codigo_prin,'4',1,'5',2,'6',3)Dsp_orden, cc.descripcion, cg.descripcion descCuenta, nvl(to_number(decode(to_number(aca.mes),1,nvl(ASIGNACION,0))),0) aenero, nvl(to_number(decode(to_number(aca.mes),2,nvl(ASIGNACION,0))),0) afebrero,nvl(to_number(decode(to_number(aca.mes),3,nvl(ASIGNACION,0))),0) amarzo, nvl(to_number(decode(to_number(aca.mes),4,nvl(ASIGNACION,0))),0) aabril,nvl(to_number(decode(to_number(aca.mes),5,nvl(ASIGNACION,0))),0) amayo, nvl(to_number(decode(to_number(aca.mes),6,nvl(ASIGNACION,0))),0) ajunio, nvl(to_number(decode(to_number(aca.mes),7,nvl(ASIGNACION,0))),0) ajulio,nvl(to_number(decode(to_number(aca.mes),8,nvl(ASIGNACION,0))),0) aagosto,nvl(to_number(decode(to_number(aca.mes),9,nvl(ASIGNACION,0))),0) aseptiembre,nvl(to_number(decode(to_number(aca.mes),10,nvl(ASIGNACION,0))),0) aoctubre,nvl(to_number(decode(to_number(aca.mes),11,nvl(ASIGNACION,0))),0) anoviembre, nvl(to_number(decode(to_number(aca.mes),12,nvl(ASIGNACION,0))),0) adiciembre,CG.CTA1, CG.CTA2, CG.CTA3, CG.CTA4, CG.CTA5, CG.CTA6 ,cg.cta1||cg.cta2||cg.cta3||cg.cta4||cg.cta5||cg.cta6 cuenta , aca.COMPANIA CIA , nvl(aca.compania_origen,aca.compania)   compania_origen , C.NOMBRE ,0 enero,0 febrero, 0 marzo,0 abril, 0 mayo,0 junio, 0 julio,0 agosto, 0 septiembre,0 octubre, 0 noviembre,0 diciembre,ue.descripcion descUnidad from  tbl_con_ante_cuenta_mensual aca, tbl_con_ctas_prin cp, tbl_con_cla_ctas cc, tbl_con_catalogo_gral cg , tbl_sec_COMPANIA C ,tbl_sec_unidad_ejec ue where cg.CTA1 = aca.cta1 and cg.CTA2  = aca.cta2 and cg.CTA3 = aca.cta3 and cg.CTA4 = aca.cta4 and cg.CTA5  = aca.cta5 and cg.CTA6  = aca.cta6 and cg.COMPANIA  = nvl(aca.compania_origen,aca.compania) and cp.codigo_prin  in ('4','5','6') and cc.codigo_prin  = cp.codigo_prin AND cg.tipo_cuenta  = cc.codigo_clase   AND C.CODIGO = aca.COMPANIA  AND CG.RECIBE_MOV = 'S' and aca.unidad = ue.codigo and aca.compania = ue.compania and aca.compania =");

	sql.append(((String) session.getAttribute("_companyId")));
	sql.append(appendFilter);


	if(!anio.trim().equals("")){sql.append(" and aca.anio =");
		sql.append((Integer.parseInt(anio)-1));}

	sql.append("order by cg.tipo_cuenta)x group by x.compania_origen,x.cta1,x.cta2,x.cta3,x.cta4,x.cta5,x.cta6,x.tipo_cuenta,  x.descCuenta, x.dsp_tipo_cuenta, x.codigo_prin,x.descUnidad order by x.descUnidad, x.tipo_cuenta");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	}
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql.toString()+")");

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
document.title = 'Presupuesto <%=(fg.equals("OP"))?"Operativo":" De Inversiones"%> - '+document.title;

function add(){
	abrir_ventana('../presupuesto/reg_presupuesto.jsp?mode=add&fg=<%=fg%>');
}
function edit(anio,cta1,cta2,cta3,cta4,cta5,cta6,unidad){
	abrir_ventana('../presupuesto/reg_presupuesto.jsp?mode=edit&fg=<%=fg%>&anio='+anio+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&unidad='+unidad);
}
function view(anio,cta1,cta2,cta3,cta4,cta5,cta6,unidad){
	abrir_ventana('../presupuesto/reg_presupuesto.jsp?mode=view&fg=<%=fg%>&anio='+anio+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&unidad='+unidad);
}
function printList(){
	//abrir_ventana('../inventario/');
}
function reloadPage(unidad){
	var anio = document.search01.anio.value;
	window.location = '../presupuesto/list_preliminar_presOp.jsp?fg=<%=fg%>&unidad='+unidad+'&anio='+anio;
}
function  calSeleccion()
{
	var total  =0,totalPorcMes=0,totalMes=0;
	var totalMesNuevoAnual =0;
	var totalAnteriorAnual =0,totalMes=0;
	var totalAnualPorc = 0,totalMensualPorc=0,totalAnualPorcCuenta=0;
	var totalMes1=0,totalMes2=0,totalMes3=0,totalMes4=0,totalMes5=0,totalMes6=0,totalMes7=0,totalMes8=0,totalMes9=0,totalMes10=0,totalMes11=0,totalMes12=0;
	var nMes ='totalMes';
	var myarray  = new Array(0,0,0,0,0,0,0,0,0,0,0,0);
	var myarray2 = new Array(0,0,0,0,0,0,0,0,0,0,0,0);
	var groupBy ='';
	for(i=0;i<<%=al.size()%>;i++)
	{
		if(eval('document.form1.totalAnteriorAnual'+i).value !='' && eval('document.form1.totalAnteriorAnual'+i).value !='0')
				totalAnteriorAnual = parseFloat(eval('document.form1.totalAnteriorAnual'+i).value);

		if(i!=0)
		{
		 if(groupBy!=eval('document.form1.groupBy'+i).value)
		 {
			for(k=1;k<=12;k++)
			{
				eval('document.form1.tnuevoMes'+k+groupBy).value=(myarray[k-1]).toFixed(2);
				eval('document.form1.tporcMes'+k+groupBy).value =(myarray2[k-1]).toFixed(2);
			}
			eval('document.form1.nuevoTotalAnual'+groupBy).value =(totalMes).toFixed(2);
			eval('document.form1.porcAcumuladoAnual'+groupBy).value =(totalAnualPorcCuenta).toFixed(2);
			totalMes=0;
			totalAnualPorcCuenta=0;
			myarray  = new Array(0,0,0,0,0,0,0,0,0,0,0,0);
					myarray2 = new Array(0,0,0,0,0,0,0,0,0,0,0,0);
		 }
		}

			for(j=1;j<=12;j++)
			{
				var nuevoMes =0,actualMes=0,porcMes=0;
				if(eval('document.form1.mes'+j+i).value !='')
				{
					actualMes = parseFloat(eval('document.form1.mes'+j+i).value);
				}
				if(eval('document.form1.nuevoMes'+j+i).value !='')
				{
					nuevoMes = parseFloat(eval('document.form1.nuevoMes'+j+i).value);
					total = myarray[j-1];
					myarray[j-1]= parseFloat(total)+nuevoMes;

				}
				if(totalAnteriorAnual!=0)
				{
					porcMes = ((nuevoMes - actualMes)/totalAnteriorAnual)*100;
					totalAnualPorc += porcMes;
					totalAnualPorcCuenta+= porcMes;
					eval('document.form1.porcMes'+j+i).value=(porcMes).toFixed(2);
					totalPorcMes = myarray2[j-1];
					myarray2[j-1]= parseFloat(totalPorcMes)+porcMes;

				}
				totalMesNuevoAnual +=  nuevoMes;
				totalMes += nuevoMes;
			}//meses
			eval('document.form1.porcAcumuladoAnual'+i).value=(totalAnualPorc).toFixed(2);
			eval('document.form1.nuevoTotalAnual'+i).value=(totalMesNuevoAnual).toFixed(2);
			totalMesNuevoAnual=0;
			totalAnualPorc =0;
		groupBy = eval('document.form1.groupBy'+i).value;

	}

			for(k=1;k<=12;k++)
			{

				eval('document.form1.tnuevoMes'+k+groupBy).value=(myarray[k-1]).toFixed(2);
				//alert('groupBy =='+groupBy+' array en '+k+' value=='+myarray2[k-1]);
				eval('document.form1.tporcMes'+k+groupBy).value =(myarray2[k-1]).toFixed(2);
			}
			eval('document.form1.nuevoTotalAnual'+groupBy).value =(totalMes).toFixed(2);
			eval('document.form1.porcAcumuladoAnual'+groupBy).value =(totalAnualPorcCuenta).toFixed(2);
			totalMes=0;
			totalAnualPorc=0;
}
function printPres(){
var unidad = document.search01.unidad.value;
if(unidad !='' && '<%=anio%>' !='')
	 abrir_ventana("../presupuesto/print_presupuesto_ope.jsp?anio=<%=anio%>&unidad="+unidad);
	 else alert('Unidad o Año Invalido ');
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
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
				<cellbytelabel>Unidad</cellbytelabel>
				<%=fb.select("unidad",alUE,unidad,false,false,0,"",null,"onChange=\"javascript:reloadPage(this.value);\"","","S")%>
				<%=fb.submit("go","Ir")%>
				<%=fb.button("print","Imprimir",false,false,"","height:30px","onClick=\"javascript:printPres()\"")%>
			</td>
<%=fb.formEnd()%>

		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

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
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("mode",mode)%>
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
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
		<tr class="TextRow02">
					<td align="right"><authtype type='52'><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
			</td>
		</tr>

<tr>
	<td class="TableLeftBorder TableRightBorder">
				<div id="_cMain" class="Container">
				<div id="_cContent" class="ContainerContent">


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
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>
			<td width="3%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="3%">%</td>

			<td width="5%"><cellbytelabel>Actual</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Nuevo</cellbytelabel></td>
			<td width="5%">%</td>
		</tr>
<%
int valSize = 5;
String valClass = "Text10";
double valLength= 13.2;
String groupBy ="",descTipoCta="";
String color = "TextRow02";
double totalEnero =0,totalFebrero =0,totalMarzo =0,totalAbril =0,totalMayo =0,totalJunio =0,totalJulio =0,totalAgosto=0,totalSeptiembre =0,totalOctubre =0,totalNoviembre =0,totalDiciembre =0;
double totalNuevoEnero =0,totalNuevoFebrero =0,totalNuevoMarzo =0,totalNuevoAbril =0,totalNuevoMayo =0,totalNuevoJunio =0,totalNuevoJulio =0,totalNuevoAgosto=0,totalNuevoSeptiembre =0,totalNuevoOctubre =0,totalNuevoNoviembre =0,totalNuevoDiciembre =0;
double totalPorcEnero =0,totalPorcFebrero =0,totalPorcMarzo =0,totalPorcAbril =0,totalPorcMayo =0,totalPorcJunio =0,totalPorcJulio =0,totalPorcAgosto=0,totalPorcSeptiembre =0,totalPorcOctubre =0,totalPorcNoviembre =0,totalPorcDiciembre =0;

double porcEnero =0,porcFebrero =0,porcMarzo =0,porcAbril =0,porcMayo =0,porcJunio =0,porcJulio =0,porcAgosto=0,porcSeptiembre =0,porcOctubre =0,porcNoviembre =0,porcDiciembre =0;
double totalPorc =0,totalAnual =0,totalAnteriorAnual =0,totalPorcFinal=0;

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	if (i % 2 == 0) color = "TextRow01";
if(cdo.getColValue("totalAnteriorAnual")!= null && !cdo.getColValue("totalAnteriorAnual").trim().equals("")&& Double.parseDouble(cdo.getColValue("totalAnteriorAnual"))>0){

porcEnero =Math.round((((Double.parseDouble(cdo.getColValue("enero")) - Double.parseDouble(cdo.getColValue("aenero")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcFebrero =Math.round((((Double.parseDouble(cdo.getColValue("febrero")) - Double.parseDouble(cdo.getColValue("afebrero")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcMarzo =Math.round((((Double.parseDouble(cdo.getColValue("marzo")) - Double.parseDouble(cdo.getColValue("amarzo")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcAbril =Math.round((((Double.parseDouble(cdo.getColValue("abril")) - Double.parseDouble(cdo.getColValue("aabril")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcMayo =Math.round((((Double.parseDouble(cdo.getColValue("mayo")) - Double.parseDouble(cdo.getColValue("amayo")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcJunio =Math.round((((Double.parseDouble(cdo.getColValue("junio")) - Double.parseDouble(cdo.getColValue("ajunio")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcJulio =Math.round((((Double.parseDouble(cdo.getColValue("julio")) - Double.parseDouble(cdo.getColValue("ajulio")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcAgosto =Math.round((((Double.parseDouble(cdo.getColValue("agosto")) - Double.parseDouble(cdo.getColValue("aagosto")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcSeptiembre =Math.round((((Double.parseDouble(cdo.getColValue("septiembre")) - Double.parseDouble(cdo.getColValue("aseptiembre")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcOctubre =Math.round((((Double.parseDouble(cdo.getColValue("octubre")) - Double.parseDouble(cdo.getColValue("aoctubre")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcNoviembre =Math.round((((Double.parseDouble(cdo.getColValue("noviembre")) - Double.parseDouble(cdo.getColValue("anoviembre")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );
porcDiciembre =Math.round((((Double.parseDouble(cdo.getColValue("diciembre")) - Double.parseDouble(cdo.getColValue("adiciembre")))/Double.parseDouble(cdo.getColValue("totalAnteriorAnual")))*100) );

totalPorc = porcEnero+porcFebrero+porcMarzo+porcAbril+ porcMayo+porcJunio+porcJulio+porcAgosto+porcSeptiembre+porcOctubre+porcNoviembre+porcDiciembre;


}

%>
<%=fb.hidden("groupBy"+i,cdo.getColValue("codigoPrin"))%>
<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>
<%=fb.hidden("compania_origen"+i,cdo.getColValue("compania_origen"))%>



		<%if(!groupBy.trim().equals(cdo.getColValue("codigoPrin"))){
		if(i!=0)
		{%>

		<tr class="TextHeader02" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>T O T A L    D E    <%=descTipoCta%></td>
			<td><%=fb.decBox("tMes1"+groupBy,""+totalEnero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes1"+groupBy,""+totalNuevoEnero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes1"+groupBy,""+totalPorcEnero,false,false,true,valSize,valClass,null,"")%></td>

			<td><%=fb.decBox("tMes2"+groupBy,""+totalFebrero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes2"+groupBy,""+totalNuevoFebrero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes2"+groupBy,""+totalPorcFebrero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes3"+groupBy,""+totalMarzo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes3"+groupBy,""+totalNuevoMarzo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes3"+groupBy,""+totalPorcMarzo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes4"+groupBy,""+totalAbril,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes4"+groupBy,""+totalNuevoAbril,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes4"+groupBy,""+totalPorcAbril,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes5"+groupBy,""+totalMayo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes5"+groupBy,""+totalNuevoMayo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes5"+groupBy,""+totalPorcMayo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes6"+groupBy,""+totalJunio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes6"+groupBy,""+totalJunio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes6"+groupBy,""+totalPorcJunio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes7"+groupBy,""+totalJulio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes7"+groupBy,""+totalNuevoJulio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes7"+groupBy,""+totalPorcJulio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes8"+groupBy,""+totalAgosto,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes8"+groupBy,""+totalNuevoAgosto,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes8"+groupBy,""+totalPorcAgosto,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes9"+groupBy,""+totalSeptiembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes9"+groupBy,""+totalNuevoSeptiembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes9"+groupBy,""+totalPorcSeptiembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes10"+groupBy,""+totalOctubre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes10"+groupBy,""+totalNuevoOctubre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes10"+groupBy,""+totalPorcOctubre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes11"+groupBy,""+totalNoviembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes11"+groupBy,""+totalNuevoNoviembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes11"+groupBy,""+totalPorcNoviembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes12"+groupBy,""+totalDiciembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes12"+groupBy,""+totalNuevoDiciembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes12"+groupBy,""+totalPorcDiciembre,false,false,true,valSize,valClass,null,"")%></td>

			<td><%=fb.decBox("totalAnteriorAnual"+groupBy,""+totalAnteriorAnual,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("nuevoTotalAnual"+groupBy,""+totalAnual,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("porcAcumuladoAnual"+groupBy,""+totalPorcFinal,false,false,true,valSize,valClass,null,"")%></td>
		</tr>


		<%
		totalEnero =0;totalFebrero =0;totalMarzo =0;totalAbril =0;totalMayo =0;totalJunio =0;totalJulio =0;totalAgosto=0;totalSeptiembre =0;totalOctubre =0;totalNoviembre =0;totalDiciembre =0;
	totalNuevoEnero =0;totalNuevoFebrero =0;totalNuevoMarzo =0;totalNuevoAbril =0;totalNuevoMayo =0;totalNuevoJunio =0;totalNuevoJulio =0;totalNuevoAgosto=0;totalNuevoSeptiembre =0;totalNuevoOctubre =0;totalNuevoNoviembre =0;totalNuevoDiciembre =0;
	totalPorcEnero =0;totalPorcFebrero =0;totalPorcMarzo =0;totalPorcAbril =0;totalPorcMayo =0;totalPorcJunio =0;totalPorcJulio =0;totalPorcAgosto=0;totalPorcSeptiembre =0;totalPorcOctubre =0;totalPorcNoviembre =0;totalPorcDiciembre =0;

		porcEnero =0;porcFebrero =0;porcMarzo =0;porcAbril =0;porcMayo =0;porcJunio =0;porcJulio =0;porcAgosto=0;porcSeptiembre =0;porcOctubre =0;porcNoviembre =0;porcDiciembre =0;

		}%>

		<tr class="TextHeader02" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td colspan="40"><%=cdo.getColValue("descTipoCta")%></td>
		</tr>


		<%}%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

			<td><%=cdo.getColValue("descCuenta")%></td>
							<td width="3%"><%=fb.decBox("mes1"+i,cdo.getColValue("aenero"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes1"+i,cdo.getColValue("enero"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes1"+i,""+porcEnero,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes2"+i,cdo.getColValue("afebrero"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes2"+i,cdo.getColValue("febrero"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes2"+i,""+porcFebrero,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes3"+i,cdo.getColValue("amarzo"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes3"+i,cdo.getColValue("marzo"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes3"+i,""+porcMarzo,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes4"+i,cdo.getColValue("aabril"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes4"+i,cdo.getColValue("abril"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes4"+i,""+porcAbril,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes5"+i,cdo.getColValue("amayo"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes5"+i,cdo.getColValue("mayo"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes5"+i,""+porcMayo,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes6"+i,cdo.getColValue("ajunio"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes6"+i,cdo.getColValue("junio"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes6"+i,""+porcJunio,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes7"+i,cdo.getColValue("ajulio"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes7"+i,cdo.getColValue("julio"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes7"+i,""+porcJulio,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes8"+i,cdo.getColValue("aagosto"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes8"+i,cdo.getColValue("agosto"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes8"+i,"0",false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes9"+i,cdo.getColValue("aseptiembre"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes9"+i,cdo.getColValue("septiembre"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes9"+i,""+porcSeptiembre,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes10"+i,cdo.getColValue("aoctubre"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes10"+i,cdo.getColValue("octubre"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes10"+i,""+porcOctubre,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes11"+i,cdo.getColValue("anoviembre"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes11"+i,cdo.getColValue("noviembre"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes11"+i,""+porcNoviembre,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("mes12"+i,cdo.getColValue("adiciembre"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoMes12"+i,cdo.getColValue("diciembre"),false,false,false, valSize,valLength,valClass,null,"onChange=\"javascript:calSeleccion();\"")%></td>
							<td width="3%"><%=fb.decBox("porcMes12"+i,""+porcDiciembre,false,false,true, valSize,valLength,valClass,null,"")%></td>

							<td width="3%"><%=fb.decBox("totalAnteriorAnual"+i,cdo.getColValue("totalAnteriorAnual") ,false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("nuevoTotalAnual"+i,cdo.getColValue("totalAnual"),false,false,true, valSize,valLength,valClass,null,"")%></td>
							<td width="3%"><%=fb.decBox("porcAcumuladoAnual"+i,""+totalPorc,false,false,true, valSize,valLength,valClass,null,"")%></td>

		</tr>
<%
groupBy=cdo.getColValue("codigoPrin");
descTipoCta=cdo.getColValue("descTipoCta");

totalAnual += Double.parseDouble(cdo.getColValue("totalAnual"));
totalAnteriorAnual += Double.parseDouble(cdo.getColValue("totalAnteriorAnual"));
totalPorcFinal =+totalPorc;


totalEnero += Double.parseDouble(cdo.getColValue("aenero"));
totalNuevoEnero += Double.parseDouble(cdo.getColValue("enero"));

totalFebrero += Double.parseDouble(cdo.getColValue("afebrero"));
totalNuevoFebrero += Double.parseDouble(cdo.getColValue("febrero"));

totalMarzo += Double.parseDouble(cdo.getColValue("amarzo"));
totalNuevoMarzo += Double.parseDouble(cdo.getColValue("marzo"));
totalAbril += Double.parseDouble(cdo.getColValue("aabril"));
totalNuevoAbril += Double.parseDouble(cdo.getColValue("abril"));
totalMayo += Double.parseDouble(cdo.getColValue("amayo"));
totalNuevoMayo += Double.parseDouble(cdo.getColValue("mayo"));
totalJunio += Double.parseDouble(cdo.getColValue("ajunio"));
totalNuevoJunio += Double.parseDouble(cdo.getColValue("junio"));
totalJulio += Double.parseDouble(cdo.getColValue("ajulio"));
totalNuevoJulio += Double.parseDouble(cdo.getColValue("julio"));
totalAgosto += Double.parseDouble(cdo.getColValue("aagosto"));
totalNuevoAgosto += Double.parseDouble(cdo.getColValue("agosto"));
totalSeptiembre += Double.parseDouble(cdo.getColValue("aseptiembre"));
totalNuevoSeptiembre += Double.parseDouble(cdo.getColValue("septiembre"));
totalOctubre += Double.parseDouble(cdo.getColValue("aoctubre"));
totalNuevoOctubre += Double.parseDouble(cdo.getColValue("octubre"));
totalNoviembre += Double.parseDouble(cdo.getColValue("anoviembre"));
totalNuevoNoviembre += Double.parseDouble(cdo.getColValue("noviembre"));
totalDiciembre += Double.parseDouble(cdo.getColValue("adiciembre"));
totalNuevoDiciembre += Double.parseDouble(cdo.getColValue("diciembre"));


totalPorcEnero  += porcEnero;
totalPorcFebrero  += porcFebrero;
totalPorcMarzo  += porcMarzo;
totalPorcAbril  += porcAbril;
totalPorcMayo  += porcMayo;
totalPorcJunio  += porcJunio;
totalPorcJulio  += porcJulio;
totalPorcAgosto  += porcAgosto;
totalPorcSeptiembre  += porcSeptiembre;
totalPorcOctubre  += porcOctubre;
totalPorcNoviembre  += porcNoviembre;
totalPorcDiciembre  += porcDiciembre;


}
%>
		<tr class="TextHeader02" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

			<td><cellbytelabel>T O T A L    D E</cellbytelabel>    <%=descTipoCta%></td>
			<td><%=fb.decBox("tMes1"+groupBy,""+totalEnero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes1"+groupBy,""+totalNuevoEnero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes1"+groupBy,""+totalPorcEnero,false,false,true,valSize,valClass,null,"")%></td>

			<td><%=fb.decBox("tMes2"+groupBy,""+totalFebrero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes2"+groupBy,""+totalNuevoFebrero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes2"+groupBy,""+totalPorcFebrero,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes3"+groupBy,""+totalMarzo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes3"+groupBy,""+totalNuevoMarzo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes3"+groupBy,""+totalPorcMarzo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes4"+groupBy,""+totalAbril,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes4"+groupBy,""+totalNuevoAbril,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes4"+groupBy,""+totalPorcAbril,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes5"+groupBy,""+totalMayo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes5"+groupBy,""+totalNuevoMayo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes5"+groupBy,""+totalPorcMayo,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes6"+groupBy,""+totalJunio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes6"+groupBy,""+totalJunio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes6"+groupBy,""+totalPorcJunio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes7"+groupBy,""+totalJulio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes7"+groupBy,""+totalNuevoJulio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes7"+groupBy,""+totalPorcJulio,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes8"+groupBy,""+totalAgosto,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes8"+groupBy,""+totalNuevoAgosto,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes8"+groupBy,""+totalPorcAgosto,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes9"+groupBy,""+totalSeptiembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes9"+groupBy,""+totalNuevoSeptiembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes9"+groupBy,""+totalPorcSeptiembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes10"+groupBy,""+totalOctubre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes10"+groupBy,""+totalNuevoOctubre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes10"+groupBy,""+totalPorcOctubre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes11"+groupBy,""+totalNoviembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes11"+groupBy,""+totalNuevoNoviembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes11"+groupBy,""+totalPorcNoviembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tMes12"+groupBy,""+totalDiciembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tnuevoMes12"+groupBy,""+totalNuevoDiciembre,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("tporcMes12"+groupBy,""+totalPorcDiciembre,false,false,true,valSize,valClass,null,"")%></td>

			<td><%=fb.decBox("totalAnteriorAnual"+groupBy,""+totalAnteriorAnual,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("nuevoTotalAnual"+groupBy,""+totalAnual,false,false,true,valSize,valClass,null,"")%></td>
			<td><%=fb.decBox("porcAcumuladoAnual"+groupBy,""+totalPorcFinal,false,false,true,valSize,valClass,null,"")%></td>


		</tr>

		</table>


		</div>
			</div>
		</td>
		</tr>

		<tr class="TextRow02">
					<td align="right"><authtype type='52'><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
			</td>
		</tr>
	<%=fb.formEnd(true)%>

		

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	
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
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
ArrayList al1= new ArrayList();
 int size =Integer.parseInt(request.getParameter("size"));
 String baction = request.getParameter("baction");

/*
	INSERT INTO ANTE_CUENTA_ANUAL(	ANIO, CTA1, CTA2, CTA3, CTA4, CTA5, CTA6, COMPANIA, ASIGNACION_ACTUAL,
									ASIGNACION_ANTERIOR, EJECUTADO_DIC, JUSTIFICACION, EJECUTADO, ESTADO_APROB,
									FECHA_APROB, USUARIO_APROB, UNIDAD, COMPANIA_ORIGEN, PREAPROBADO,
									PREAPROBADO_FECHA, PREAPROBADO_USUARIO, USUARIO_CREACION, FECHA_CREACION )
								VALUES( :CG$CTRL.ANIO, :ING.CTA1, :ING.CTA2, :ING.CTA3, :ING.CTA4, :ING.CTA5, :ING.CTA6,
									:ING.COMPANIA, V_TOTAL_NUEVO, 0, 0, NULL, V_TOTAL_ACTUAL, 'N',
									NULL, NULL, :CG$CTRL.UNIDAD, :ING.COMPANIA_ORIGEN, 'N', NULL, NULL,
									USER, V_SYSFECHA );	*/


 for(int i=0;i<size;i++)
 {

			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("anio",request.getParameter("anio"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("unidad",request.getParameter("unidad"));
			cdo.addColValue("fechaCreacion",cDateTime);
			cdo.addColValue("usuarioCreacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fechaModificacion",cDateTime);
			cdo.addColValue("usuarioModificacion",(String) session.getAttribute("_userName"));

			cdo.addColValue("cta1",request.getParameter("cta1"+i));
			cdo.addColValue("cta2",request.getParameter("cta2"+i));
			cdo.addColValue("cta3",request.getParameter("cta3"+i));
			cdo.addColValue("cta4",request.getParameter("cta4"+i));
			cdo.addColValue("cta5",request.getParameter("cta5"+i));
			cdo.addColValue("cta6",request.getParameter("cta6"+i));
			cdo.addColValue("compania_origen",request.getParameter("compania_origen"+i));
			cdo.addColValue("mode",request.getParameter("mode"));
			cdo.addColValue("nuevoTotalAnual",request.getParameter("nuevoTotalAnual"+i));
			cdo.addColValue("totalAnteriorAnual",request.getParameter("totalAnteriorAnual"+i));
			cdo.addColValue("ejecutado",request.getParameter("totalAnteriorAnual"+i));
			cdo.addColValue("ejecutadoDic","0");


			for(int j=1;j<=12;j++)
			{
				cdo.addColValue("mes"+j,""+j);
				//if(request.getParameter("mes"+j+i) !=  null && !request.getParameter("mes"+j+i).trim().equals("")&& !request.getParameter("mes"+j+i).trim().equals("0"))
					cdo.addColValue("anteriormes"+j,request.getParameter("mes"+j+i));
		//if(request.getParameter("nuevoMes"+j+i) !=  null && !request.getParameter("nuevoMes"+j+i).trim().equals("")&& !request.getParameter("nuevoMes"+j+i).trim().equals("0"))
					cdo.addColValue("nuevoMes"+j,request.getParameter("nuevoMes"+j+i));
					cdo.addColValue("estado"+j,"I");
			}

			cdo.addColValue("estado_aprob","N");
			cdo.addColValue("preaprobado","N");


			al1.add(cdo);

 }
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		PresMgr.presPreliminar(al1);
	}

	ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (PresMgr.getErrCode().equals("1"))
{
%>
	alert('<%=PresMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_preliminar_presOp.jsp"))
	{

%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_preliminar_presOp.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/presupuesto/list_preliminar_presOp.jsp?fg=<%=fg%>&unidad=<%=unidad%>&anio=<%=anio%>';
<%
	}
%>
	//window.close();
<%
} else throw new Exception(PresMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>