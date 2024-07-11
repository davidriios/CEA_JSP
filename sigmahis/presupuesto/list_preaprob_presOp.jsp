
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="issi.presupuesto.PresDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr" />

<%
/**
==========================================================================================
fp  - PA  - pre-aprovacion
      VB	- vobo
      AP  - Aprobacion
fg	- PO  - presupuesto operativo
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200069") || SecMgr.checkAccess(session.getId(),"200070") || SecMgr.checkAccess(session.getId(),"200071") || SecMgr.checkAccess(session.getId(),"200072"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PresMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo= new CommonDataObject();
int rowCount = 0;
String sql = "";
StringBuffer sbSql = new StringBuffer();
String appendFilter = "";
String anio        = request.getParameter("anio");
String unidad="";
String compania =((String) session.getAttribute("_companyId"));
String fpFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fg==null) fg = "PO";
if(fp==null) fp = "PA";

String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if(anio ==null)anio=cDateTime.substring(6, 10);
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

	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio = "+request.getParameter("anio");
    	anio = request.getParameter("anio");
	}
	if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals(""))
	{
		appendFilter += " and a.unidad = "+request.getParameter("unidad");
    	unidad = request.getParameter("unidad");
	}

	String tableName = "";

	if (request.getParameter("anio") != null )
	{
		if(fp.trim().equals("PA"))fpFilter=" and   a.estado = 'E' ";
		else if(fp.trim().equals("VB"))fpFilter=" and a.estado = 'C' ";
		else if(fp.trim().equals("AP"))fpFilter=" and a.estado = 'V' ";

		sbSql.append("select distinct a.compania,a.unidad,a.anio, ue.descripcion descUnidad,nvl((select sum(nvl(c.asignacion,0)) from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania 	= a.compania and c.unidad = a.unidad	and anio = a.anio),0) totalIngresos,nvl((select sum(nvl(c.asignacion,0)) v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = a.compania and c.unidad = a.unidad and anio = a.anio),0) totalGastos,nvl((select sum(nvl(c.asignacion,0)) v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = a.compania and c.unidad = a.unidad and anio = a.anio),0)totalCostos  from tbl_con_ante_cuenta_mensual a, tbl_sec_unidad_ejec ue where a.compania =");
		sbSql.append(compania);
		sbSql.append(appendFilter);
		sbSql.append(" and ue.codigo = a.unidad and ue.compania= a.compania ");
		sbSql.append(fpFilter);
		sbSql.append(" and (a.unidad,a.compania) in (select distinct b.UNIDAD,b.compania from tbl_con_ante_cuenta_anual b where b.anio = a.anio and b.compania = a.compania and b.unidad = a.unidad");
		if(fp.trim().equals("PA"))sbSql.append(" and b.estado='E'  /*(b.preaprobado = 'N' or b.preaprobado is null)*/");
		else if(fp.trim().equals("VB"))  sbSql.append(" and b.estado='C' /*and b.preaprobado = 'S' and b.estado_aprob = 'N'*/ ");
		else if(fp.trim().equals("AP"))  sbSql.append(" and b.estado = 'V' /*and b.preaprobado = 'S' and b.estado_aprob = 'N'*/ ");
		sbSql.append(" ) order by ue.descripcion, a.unidad");

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		//al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Comprobante.class);
		rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");

		if(fp.trim().equals("PA")) {
			sql=" select  nvl((select sum(nvl(c.asignacion,0))  v_ingresos from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='E' /*c.preaprobado = 'N'*/ ),0)v_ingresos,  nvl((select sum(nvl(c.asignacion,0))  v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='E' /*c.preaprobado = 'N'*/ ),0)v_costos, nvl((select sum(nvl(c.asignacion,0))  v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='E' /*c.preaprobado = 'N'*/ ),0)v_gastos,nvl((select count(distinct c.unidad) from tbl_con_ante_cuenta_mensual c where c.compania = "+compania+" and c.anio ="+anio+" and c.estado='E' /*c.preaprobado = 'N*/ ),0) cPendientes,nvl((select sum(nvl(c.asignacion,0))  v_ingresos from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='C' /*c.preaprobado = 'S'*/ ),0)v_ingresosAprob,  nvl((select sum(nvl(c.asignacion,0))  v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='C' /*c.preaprobado = 'S'*/ ),0)v_costosAprob, nvl((select sum(nvl(c.asignacion,0))  v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='C' /*c.preaprobado = 'S'*/ ),0)v_gastosAprob,nvl((select count(distinct c.unidad) from tbl_con_ante_cuenta_mensual c where c.compania = "+compania+" and c.anio ="+anio+" and c.estado='C' /*c.preaprobado = 'S'*/ ),0) cPreaprobados  from dual ";}
		else if (fp.trim().equals("VB")) {
	 		sql=" select  nvl((select sum(nvl(c.asignacion,0))  v_ingresos from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='C' ),0)v_ingresos,  nvl((select sum(nvl(c.asignacion,0))  v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='C' ),0)v_costos, nvl((select sum(nvl(c.asignacion,0))  v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='C' ),0)v_gastos,nvl((select count(distinct c.unidad) from tbl_con_ante_cuenta_mensual c where c.compania = "+compania+" and c.anio ="+anio+" and c.estado='V'  ),0) cPendientes,nvl((select sum(nvl(c.asignacion,0))  v_ingresos from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='V' ),0)v_ingresosAprob,  nvl((select sum(nvl(c.asignacion,0))  v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='V'  ),0)v_costosAprob, nvl((select sum(nvl(c.asignacion,0))  v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='V' ),0)v_gastosAprob,nvl((select count(distinct c.unidad) from tbl_con_ante_cuenta_mensual c where c.compania = "+compania+" and c.anio ="+anio+" and c.estado='V'  ),0) cPreaprobados  from dual ";}
		else if (fp.trim().equals("AP")) {
	 		sql=" select  nvl((select sum(nvl(c.asignacion,0))  v_ingresos from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='V' ),0)v_ingresos,  nvl((select sum(nvl(c.asignacion,0))  v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='V' /*c.preaprobado = 'N'*/ ),0)v_costos, nvl((select sum(nvl(c.asignacion,0))  v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='V' /*c.preaprobado = 'N'*/ ),0)v_gastos,nvl((select count(distinct c.unidad) from tbl_con_ante_cuenta_mensual c where c.compania = "+compania+" and c.anio ="+anio+" and c.estado='V' /*c.preaprobado = 'N'*/ ),0) cPendientes,nvl((select sum(nvl(c.asignacion,0))  v_ingresos from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='A' /*c.estado_aprob = 'S'*/ ),0)v_ingresosAprob,  nvl((select sum(nvl(c.asignacion,0))  v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='A' /*c.estado_aprob = 'S'*/ ),0)v_costosAprob, nvl((select sum(nvl(c.asignacion,0))  v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = "+compania+" and anio ="+anio+" and c.estado='A' /*c.estado_aprob = 'S'*/ ),0)v_gastosAprob,nvl((select count(distinct c.unidad) from tbl_con_ante_cuenta_mensual c where c.compania = "+compania+" and c.anio ="+anio+" and c.estado='A' /*c.estado_aprob = 'S'*/ ),0) cPreaprobados  from dual ";
		}

		cdo=  SQLMgr.getData(sql);

		if(cdo ==null)
		{
				cdo = new CommonDataObject();
				cdo.addColValue("v_ingresos","0");
				cdo.addColValue("v_costos","0");
				cdo.addColValue("v_gastos","0");
	
				cdo.addColValue("v_ingresosAprob","0");
				cdo.addColValue("v_costosAprob","0");
				cdo.addColValue("v_gastosAprob","0");
				cdo.addColValue("cPreaprobados","0");
				cdo.addColValue("cPendientes","0");
		}
	}else
		{
			cdo = new CommonDataObject();
			cdo.addColValue("v_ingresos","0");
			cdo.addColValue("v_costos","0");
			cdo.addColValue("v_gastos","0");

			cdo.addColValue("v_ingresosAprob","0");
			cdo.addColValue("v_costosAprob","0");
			cdo.addColValue("v_gastosAprob","0");
			cdo.addColValue("cPreaprobados","0");
			cdo.addColValue("cPendientes","0");
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
document.title = 'Presupuesto <%=(fg.equals("PO"))?"Operativo":"De Inversiones"%> - '+document.title;


function checkAprob()
{
	var cantidad = 0;
	var anio = document.search01.anio.value;
	var msg='';
	   if(anio !='')
	   {
	   		for(i=0;i<<%=al.size()%>;i++)
			{
				if(eval('document.form1.check'+i).checked)
				{
					cantidad ++;
				}
			}
	   }
	   else alert('Introduzca El Año');
	<%if(fp.trim().equals("PA")){%>msg='pre - aprobar'; <%}else if(fp.trim().equals("AP")){%>msg=' aprobar';<%} else if (fp.trim().equals("VB")){%>msg=' validar';<%}%>
	if(cantidad == 0){alert('Seleccione los presupuesto a '+msg+'!!');return false;}
	else{alert(' Cantidad  De Registros a '+msg+'=='+cantidad);
	<%if(fg.trim().equals("AP")){%>
		if(confirm('Este Proceso APROBARA el presupuesto de las unidades seleccionadas.  Seguro que desea ejecutarlo?')){return true; }else{return false;}
	<%}else {%>return true;<%}%>
	}
}

function  checkSel(fName,objName,alSize,value,fElement)
{
	checkAll(fName,objName,alSize,value,fElement);
	calSeleccion();
}
function  calSeleccion()
{
	var total  =0;
	var cantidad =0;
	for(i=0;i<<%=al.size()%>;i++)
	{

		if(eval('document.form1.check'+i).checked)
		{
			cantidad ++;
			total  += parseFloat(eval('document.form1.v_ganancia'+i).value);
		}
	}
	document.form1.totalChk.value=(total).toFixed(2);
	document.form1.cantidadChk.value=cantidad;
}

function  checkItem(k)
{
	var total     = parseFloat(document.form1.totalChk.value);
	var cantidad  = parseFloat(document.form1.cantidadChk.value);

		if(eval('document.form1.check'+k).checked)
		{
			cantidad ++;
			total  += parseFloat(eval('document.form1.v_ganancia'+k).value);
			document.form1.totalChk.value=(total).toFixed(2);
			document.form1.cantidadChk.value=cantidad;
		}
		else
		{
			cantidad --;
			total  -= parseFloat(eval('document.form1.v_ganancia'+k).value);
			document.form1.totalChk.value=(total).toFixed(2);
			document.form1.cantidadChk.value=cantidad;
		}
}
function presBorrador()
{
	var anio = document.search01.anio.value;
	abrir_ventana('../presupuesto/list_presupuesto_borrador.jsp?fg=<%=fg%>&fp=<%=fp%>&anio='+anio);
}
function reloadPage(unidad){
	var anio = document.search01.anio.value;
	window.location = '../presupuesto/app_orden_pago.jsp?unidad='+unidad+'&anio='+anio;
}

function printPres(k){
   var anio = eval('document.form1.anio'+k).value
   var unidad = eval('document.form1.unidad'+k).value
   abrir_ventana('../presupuesto/print_presupuesto_ope.jsp?anio='+anio+'&unidad='+unidad);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO OPERATIVO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
	</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="0" cellspacing="0">

<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
		<tr class="TextFilter">
			<td width="44%">
				<cellbytelabel>A&ntilde;o</cellbytelabel>
				<%=fb.intBox("anio",anio,false,false,false,10)%>
		  </td>
			<td width="56%">

				<%//=fb.intBox("unidad",unidad,false,false,false,10)%>
				<%//=fb.select(ConMgr.getConnection(), "select a.unidad, b.descripcion, b.descripcion x from 	tbl_con_ante_cuenta_anual a, tbl_sec_unidad_ejec b where a.compania = " + (String) session.getAttribute("_companyId") +" and a.anio = "+anio+" and b.codigo = a.unidad and b.compania = a.compania and nvl(a.estado,'B') = 'E' and  (preaprobado = 'N' or preaprobado is null) order by b.descripcion, a.unidad", "unidad", unidad, false, false, 0, "", "", "onChange=\"javascript:reloadPage(this.value);\"", "Unidad Administrativa", "T")%>

				<%=fb.submit("go","Ir")%>
				<%=fb.button("borrador","BORRADOR",true,false,null,null,"onClick=\"javascript:presBorrador()\"")%>
		  </td>
		<%=fb.formEnd()%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>

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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>

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
		<%=fb.hidden("size",""+al.size())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
		<%=fb.hidden("baction","")%>
		<tr class="TextHeader" align="center">
			<td width="38%"><cellbytelabel>Unidad</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Ingresos</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Costos</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Gastos</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Ganancia/Perdida</cellbytelabel></td>
            <td width="6%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkSel('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Registros listados!")%></td>
            <td width="4%">&nbsp;</td>
		</tr>
<%double totalPend =0,totalPreAprob =0, v_ganancia=0;

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo2 = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	 v_ganancia = Double.parseDouble(cdo2.getColValue("totalIngresos"))-(Double.parseDouble(cdo2.getColValue("totalCostos"))+Double.parseDouble(cdo2.getColValue("totalGastos")));
	 totalPend = Double.parseDouble(cdo.getColValue("v_ingresos"))-(Double.parseDouble(cdo.getColValue("v_costos"))+Double.parseDouble(cdo.getColValue("v_gastos")));
	 totalPreAprob= Double.parseDouble(cdo.getColValue("v_ingresosAprob"))-(Double.parseDouble(cdo.getColValue("v_costosAprob"))+Double.parseDouble(cdo.getColValue("v_gastosAprob")));
		%>
		<%=fb.hidden("anio"+i,cdo2.getColValue("anio"))%>
		<%=fb.hidden("unidad"+i,cdo2.getColValue("unidad"))%>
		<%=fb.hidden("compania"+i,cdo2.getColValue("compania"))%>
		<%=fb.hidden("gastos"+i,cdo2.getColValue("totalGastos"))%>
		<%=fb.hidden("costos"+i,cdo2.getColValue("totalCostos"))%>
		<%=fb.hidden("ingresos"+i,cdo2.getColValue("totalIngresos"))%>
		<%=fb.hidden("v_ganancia"+i,""+v_ganancia)%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=cdo2.getColValue("unidad")%>] - <%=cdo2.getColValue("descUnidad")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("totalIngresos"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("totalCostos"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("totalGastos"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(v_ganancia)%>&nbsp;</td>
			<td align="center"><%=fb.checkbox("check"+i,""+i,false,false,"","","onClick=\"javascript:checkItem("+i+")\"","")%></td>
			<td align="center"><a href="javascript:printPres(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Reporte"></a></td>
		</tr>
<%
}
%>

		<tr class="TextRow02">
          <td align="right">Cant. Seleccionados</td>
		  <td><%=fb.decBox("cantidadChk","0",false,false,true,10,"Text10",null,null)%></td>
		  <td colspan="2" align="right">Total Ganancia/Perdida de Seleccionados:</td>
		  <td colspan="3"><%=fb.decBox("totalChk","0",false,false,true,10,"Text10",null,null)%></td>
        </tr>
		<tr class="TextRow02">
          <td align="right">Cant. Pendientes:</td>
		  <td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cPendientes"))%><%//=fb.decBox("cantidadPendiente","0",false,false,true,10,"Text10",null,null)%></td>
		  <td colspan="2" align="right">Total Ganancia/Perdida Pendientes:</td>
		  <td colspan="3"><%=CmnMgr.getFormattedDecimal(totalPend)%></td>
        </tr>
		<tr class="TextRow02">
          <td align="right"><%if(fp.trim().equals("PA")) {%>Cant. Pre-Aprobados:<%}else if(fp.trim().equals("AP")){%>Cant. Aprobados:<%} else if (fg.trim().equals("VB")){%>Cant. Validados:<%}%></td>
		  <td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cPreaprobados"))%></td>
		  <td colspan="2" align="right">Total Ganancia/Perdida <%if(fp.trim().equals("PA")) {%> Pre-Aprobados:<%}else if(fp.trim().equals("AP")){%> Aprobados:<%} else if (fp.trim().equals("VB")) {%> Validados:<%}%></td>
		  <td colspan="3"><%=CmnMgr.getFormattedDecimal(totalPreAprob)%></td>
        </tr>


		<tr class="TextRow02">
          <td colspan="1" align="left">
		     <authtype type='52'><%=fb.submit("save","Rechazar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>		  
          <td colspan="6" align="right">
		  <%if(fp.trim().equals("PA")) {%>
		     <authtype type='50'><%=fb.submit("save","Pre - Aprobar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  <%}
		    if(fp.trim().equals("AP")) {%>
		     <authtype type='6'><%=fb.submit("save","Aprobar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  <%}
		    if(fp.trim().equals("VB")) {%>
		     <authtype type='51'><%=fb.submit("save","VoBo",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  <%}%>
		  <%//=fb.button("save","Pre - Aprobar",false,false,null,null,"onClick=\"javascript:checkEstado()\"")%>
		  </td>
        </tr>
		</table>
		<%//if(fg.equals("CD")){fb.appendJsValidation("\n\tif (!checkEstado())\n\t{\n\t\terror++;\n\t}\n");}%>
		<%fb.appendJsValidation("\n\tif (!checkAprob())\n\t{\n\t\terror++;\n\t}\n");%>


        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("unidad",unidad)%>
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
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("unidad",unidad)%>
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
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
	ArrayList al1= new ArrayList();
	String fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	int size =Integer.parseInt(request.getParameter("size"));
	String baction = request.getParameter("baction");

	Presupuesto presup = new Presupuesto();

	presup.setFg(fg);
	presup.setFp(fp);
	//presup.setUnidad(request.getParameter("unidad"));
	presup.setAnio(request.getParameter("anio"));	
	presup.setCompania((String) session.getAttribute("_companyId"));
	presup.setUsuarioModificacion((String) session.getAttribute("_userName"));


	if (baction != null && baction.equalsIgnoreCase("Pre - Aprobar"))
	{
		//presup.setPreaprobado("S");
		presup.setEstado("C");
		presup.setPreaprobadoUsuario((String) session.getAttribute("_userName"));
		presup.setPreaprobadoFecha(cDateTime);

	}
	
	if (baction != null && baction.equalsIgnoreCase("VoBo"))
	{
		presup.setEstado("V");
		presup.setVoboUsuario((String) session.getAttribute("_userName"));
		presup.setVoboFecha(cDateTime);

	}

	if (baction != null && baction.equalsIgnoreCase("Aprobar"))
	{
		presup.setEstado("A");
		presup.setUsuarioAprob((String) session.getAttribute("_userName"));
		presup.setFechaAprob(cDateTime);

	}	

	if (baction != null && baction.equalsIgnoreCase("Rechazar"))
	{
		presup.setFechaRechazo(cDateTime);
		if (fp.trim().equals("PA"))
		{
			presup.setEstado("B");
		} else if (fp.trim().equals("VB"))
		{
			presup.setEstado("C");
		} else if (fp.trim().equals("AP"))
		{
			presup.setEstado("C");
		}
	}
	
 for(int i=0;i<size;i++)
 {
   if (request.getParameter("check"+i) != null)
   {
			PresDetail presDet = new PresDetail();

			presDet.setUnidad(request.getParameter("unidad"+i));
			//presDet.setPreaprobado(presup.getPreaprobado());
			presDet.setEstado(presup.getEstado());
			presup.getPresDetail().add(presDet);
	}
 }
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null && baction.equalsIgnoreCase("Pre - Aprobar"))
	{
		PresMgr.preAprobPres(presup);
	}
	else if (baction != null && baction.equalsIgnoreCase("VoBo"))
	{
		PresMgr.voboPres(presup);
	}
	else if (baction != null && baction.equalsIgnoreCase("Aprobar"))
	{
		PresMgr.aprobar(presup);
	}
	else if (baction != null && baction.equalsIgnoreCase("Rechazar"))
	{
		PresMgr.rechazarPres(presup);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_preaprob_presOp.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_preaprob_presOp.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/presupuesto/list_preaprob_presOp.jsp?fg=<%=fg%>&fp=<%=fp%>&anio=<%=anio%>';
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
