<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String index = request.getParameter("index");
String fp = request.getParameter("fp");
String compania =(String) session.getAttribute("_companyId");
String unidad =request.getParameter("unidad");

if (fp == null || fp.trim().equals("")) fp = " ";

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
	String  descripcion ="",cta1="",cta2="",cta3="",cta4="",cta5="",cta6="",cuenta="";
	if (request.getParameter("account") != null && !request.getParameter("account").trim().equals(""))
	{
		appendFilter += " and upper(a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6) like '%"+request.getParameter("account").toUpperCase()+"%'";
		cuenta = "cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6";
	}
	if (request.getParameter("cta1") != null && !request.getParameter("cta1").trim().equals(""))
	{
	appendFilter += "and a.cta1 like '%"+request.getParameter("cta1").toUpperCase()+"%'";
		cta1 = request.getParameter("cta1");
	}
	if (request.getParameter("cta2") != null && !request.getParameter("cta2").trim().equals(""))
	{
	appendFilter += "and a.cta2 like '%"+request.getParameter("cta2").toUpperCase()+"%'";
		cta2 = request.getParameter("cta2");
	}
	if (request.getParameter("cta3") != null && !request.getParameter("cta3").trim().equals(""))
	{
	appendFilter += "and a.cta3 like '%"+request.getParameter("cta3").toUpperCase()+"%'";
		cta3 = request.getParameter("cta3");
	}
	if (request.getParameter("cta4") != null && !request.getParameter("cta4").trim().equals(""))
	{
	appendFilter += "and a.cta4 like '%"+request.getParameter("cta4").toUpperCase()+"%'";
		cta4 = request.getParameter("cta4");
	}
	if (request.getParameter("cta5") != null && !request.getParameter("cta5").trim().equals(""))
	{
	appendFilter += "and a.cta5 like '%"+request.getParameter("cta5").toUpperCase()+"%'";
		cta5 = request.getParameter("cta5");
	}
	if (request.getParameter("cta6") != null && !request.getParameter("cta6").trim().equals(""))
	{
	appendFilter += "and a.cta6 like '%"+request.getParameter("cta6").toUpperCase()+"%'";
		cta6 = request.getParameter("cta6");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
	 appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		 descripcion = request.getParameter("descripcion");
	}



if (!fp.equalsIgnoreCase("presOp")){
if(!fp.equalsIgnoreCase("almacenCtas"))appendFilter +=" and a.recibe_mov ='S' ";
	sql = "select a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as cta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, decode('"+fp+"','mapping',SUBSTR(a.descripcion,1,50),a.descripcion) as descripcion , a.compania, a.lado_movim lado, (select descripcion from tbl_con_cla_ctas  where codigo_clase = a.tipo_Cuenta )descTipoCta  from tbl_con_catalogo_gral a where a.status ='A' and a.compania="+compania+appendFilter+" order by a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6";
	}
	else
	{System.out.println("compania =="+compania+" unidad ======="+unidad);
				// LISTA DE VALORES PARA CLINICA
			//SET_ITEM_PROPERTY('ACA.CTA1',LOV_NAME,'CUENTA');
			sql="select a.cta1||' '||a.cta2||' '||a.cta3||' '||a.cta4||' '||a.cta5||' '||a.cta6 cta,"+compania+" cia, a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,initcap(a.descripcion) descripcion,initcap(co.nombre) descCompania, initcap(cp.descripcion) desc_prin,a.compania  cia_origen,cc.descripcion descTipoCta from tbl_con_catalogo_gral a,tbl_con_cla_ctas cc, tbl_con_ctas_prin cp, tbl_sec_compania co , tbl_sec_unidad_ejec u where co.codigo  = a.compania and cc.codigo_clase  = a.tipo_cuenta and cp.codigo_prin = cc.codigo_prin and co.codigo = "+compania+" and cp.codigo_prin in ('4','5','6') AND U.COMPANIA = "+compania+"  AND   (U.CODIGO = "+unidad+" or exists   (select 'x' from tbl_con_pres_fusion f   where f.compania_uni_fusion = u.compania and f.unidad_fusion   = "+unidad+" and f.unidad = u.codigo) ) and a.status ='A' and a.RECIBE_MOV = 'S'"+appendFilter+" order by a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,a.compania ";
//sql="select a.cta1||' '||a.cta2||' '||a.cta3||' '||a.cta4||' '||a.cta5||' '||a.cta6 cta,1 cia, a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,initcap(a.descripcion) descripcion,initcap((select nombre from tbl_sec_compania where codigo=a.compania)) descCompania, initcap(cp.descripcion) desc_prin,a.compania  cia_origen,cc.descripcion descTipoCta from tbl_con_catalogo_gral a,tbl_con_cla_ctas cc, tbl_con_ctas_prin cp, tbl_sec_unidad_ejec u ,tbl_con_ua_cuentas mp where   cc.codigo_clase  = a.tipo_cuenta and cp.codigo_prin = cc.codigo_prin and u.compania = "+compania+" and u.codigo = mp.ua and u.compania=mp.compania  and a.cta1 = mp.cta1 and a.cta2 = mp.cta2 and a.cta3 = mp.cta3 and a.cta4 = mp.cta4 and a.cta5 = mp.cta5 and a.cta6 = mp.cta6 and mp.status ='A' and (u.codigo =  "+unidad+" or exists   (select 'x' from tbl_con_pres_fusion f   where f.compania_uni_fusion = u.compania and f.unidad_fusion =  "+unidad+" and f.unidad = u.codigo) ) and a.recibe_mov = 'S' order by a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,a.compania ";
	}

	if(request.getParameter("descripcion") != null ){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");}

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
document.title = 'Catálogo de Cuentas - '+document.title;

function setAccount(k)
{
<%
	if (fp.equalsIgnoreCase("ajuste") || fp.equalsIgnoreCase("tipoCliente")  )
	{
%>
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaDes.value = eval('document.result.descripcion'+k).value;
	<%}else if(fp.equalsIgnoreCase("depBanco")){%>
	
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaDes.value = eval('document.result.descripcion'+k).value;
	
	<%}else if(fp.equalsIgnoreCase("ctaContaPlanillahast")){%>
	window.opener.document.ctaDet.ucta1<%=index%>.value=eval('document.result.cta1'+k).value;
	window.opener.document.ctaDet.ucta2<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.ctaDet.ucta3<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.ctaDet.ucta4<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.ctaDet.ucta5<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.ctaDet.ucta6<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.ctaDet.nameCuenta<%=index%>.value=eval('document.result.descripcion'+k).value;
	window.opener.document.ctaDet.lado<%=index%>.value=eval('document.result.lado'+k).value;
	<%}else if(fp.equalsIgnoreCase("ctasPatronales")){%>
	//Cuenta Patronal
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descripcion.value=eval('document.result.descripcion'+k).value;
	<%}else if(fp.equalsIgnoreCase("tsCtas")){%>
	//Cuenta para costos por tipo Servicio
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaName.value=eval('document.result.descripcion'+k).value;
	<%}else if(fp.equalsIgnoreCase("almacen")){%>
	window.opener.document.form1.cuentas1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cuentas2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cuentas3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cuentas4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cuentas5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cuentas6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaName.value=eval('document.result.descripcion'+k).value;
	<%}else if(fp.equalsIgnoreCase("almacenCtas")){%>
	window.opener.document.form1.cuentas1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cuentas2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cuentas3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cuentas4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cuentas5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cuentas6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaName.value=eval('document.result.descripcion'+k).value;
	 <%}else if(fp.equalsIgnoreCase("ctaContaPlanilla")){%>
	window.opener.document.form1.cuentas1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cuentas2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cuentas3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cuentas4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cuentas5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cuentas6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaName.value=eval('document.result.descripcion'+k).value;
	window.opener.document.form1.lado.value=eval('document.result.lado'+k).value;
	<%}else if(fp.equalsIgnoreCase("familia")){%>
	window.opener.document.form1.ctas1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.ctas2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.ctas3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.ctas4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.ctas5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.ctas6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.nameCuenta.value=eval('document.result.descripcion'+k).value;
	<% } else if (fp.equalsIgnoreCase("cajaCom")) { %>
	window.opener.document.form0.com_cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form0.com_cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form0.com_cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form0.com_cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form0.com_cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form0.com_cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form0.descCuenta.value = eval('document.result.descripcion'+k).value;

	<%} else if (fp.equalsIgnoreCase("cajaDev")){%>
	window.opener.document.form0.dv_cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form0.dv_cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form0.dv_cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form0.dv_cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form0.dv_cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form0.dv_cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form0.descCuentaDev.value = eval('document.result.descripcion'+k).value;

	<%}else if (fp.equalsIgnoreCase("presOp")){%>
		window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descCuenta.value = eval('document.result.descripcion'+k).value;
	window.opener.document.form1.descTipoCta.value = eval('document.result.descTipoCta'+k).value;
	window.opener.document.form1.companiaOrigen.value = eval('document.result.companiaOrigen'+k).value;
	<%}else if(fp.equalsIgnoreCase("almacen")){%>
	window.opener.document.form1.cuentas1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.cuentas2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cuentas3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cuentas4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cuentas5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cuentas6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuentaName.value=eval('document.result.descripcion'+k).value;
	<%}else if(fp.equalsIgnoreCase("familia")){%>
	window.opener.document.form1.ctas1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.ctas2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.ctas3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.ctas4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.ctas5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.ctas6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.nameCuenta.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("ctasPatronales")){%>
	//Cuenta Patronal
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descripcion.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("ctaContaPlanillahast")){%>
	window.opener.document.ctaDet.ucta1<%=index%>.value=eval('document.result.cta1'+k).value; 
	window.opener.document.ctaDet.ucta2<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.ctaDet.ucta3<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.ctaDet.ucta4<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.ctaDet.ucta5<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.ctaDet.ucta6<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.ctaDet.nameCuenta<%=index%>.value=eval('document.result.descripcion'+k).value;
	window.opener.document.ctaDet.lado<%=index%>.value=eval('document.result.lado'+k).value;
<%}else if(fp.equalsIgnoreCase("ctasFlias")){%>
	window.opener.document.form0.cta1<%=index%>.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form0.cta2<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.form0.cta3<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.form0.cta4<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.form0.cta5<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.form0.cta6<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.form0.cuenta<%=index%>.value=eval('document.result.cuenta'+k).value;
	window.opener.document.form0.descCuenta<%=index%>.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("compPlanilla")){%>
	window.opener.document.form1.cta1<%=index%>.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descCuenta<%=index%>.value=eval('document.result.descripcion'+k).value;
	window.opener.document.form1.cuenta<%=index%>.value=eval('document.result.cuenta'+k).value;
<%}else if(fp.equalsIgnoreCase("gastoUnidad")){%>
	window.opener.document.formDetalle.cta1<%=index%>.value=eval('document.result.cta1'+k).value;
	window.opener.document.formDetalle.cta2<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.formDetalle.cta3<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.formDetalle.cta4<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.formDetalle.cta5<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.formDetalle.cta6<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.formDetalle.cuenta<%=index%>.value=eval('document.result.descripcion'+k).value;	
<%}else if(fp.equalsIgnoreCase("activos")){%>
	window.opener.document.form1.activo1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.activo2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.activo3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.activo4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.activo5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.activo6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descActivo.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("depreAcum")){%>
	window.opener.document.form1.acumulada1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.acumulada2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.acumulada3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.acumulada4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.acumulada5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.acumulada6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descAcum.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("gastoDepre")){%>
	window.opener.document.form1.gasto1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.gasto2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.gasto3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.gasto4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.gasto5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.gasto6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descDepre.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("gastoDepreAct")){%>
	window.opener.document.form0.gasto1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form0.gasto2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form0.gasto3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form0.gasto4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form0.gasto5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form0.gasto6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form0.descDepre.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("regAjuste")){%>
	//Cuenta en Tipos de ajustes Facturacion
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value; 
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.cuenta.value=eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("factProv")){%>
	window.opener.document.fact_prov.cta1_<%=index%>.value=eval('document.result.cta1'+k).value;
	window.opener.document.fact_prov.cta2_<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.fact_prov.cta3_<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.fact_prov.cta4_<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.fact_prov.cta5_<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.fact_prov.cta6_<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.fact_prov.descripcion_cuenta<%=index%>.value=eval('document.result.descripcion'+k).value;
	window.opener.document.fact_prov.descCta<%=index%>.value=eval('document.result.cuenta'+k).value+' - '+eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("chequeDet")){%>
	window.opener.document.cheque_det.cta1_<%=index%>.value=eval('document.result.cta1'+k).value;
	window.opener.document.cheque_det.cta2_<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.cheque_det.cta3_<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.cheque_det.cta4_<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.cheque_det.cta5_<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.cheque_det.cta6_<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.cheque_det.descCta<%=index%>.value=eval('document.result.cuenta'+k).value+' - '+eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("clientePos")){%>
	window.opener.document.form1.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.descCuenta.value=eval('document.result.cuenta'+k).value+' - '+eval('document.result.descripcion'+k).value;
<%}else if(fp.equalsIgnoreCase("formaPago")){%>
	window.opener.document.form0.cta1.value=eval('document.result.cta1'+k).value;
	window.opener.document.form0.cta2.value=eval('document.result.cta2'+k).value;
	window.opener.document.form0.cta3.value=eval('document.result.cta3'+k).value;
	window.opener.document.form0.cta4.value=eval('document.result.cta4'+k).value;
	window.opener.document.form0.cta5.value=eval('document.result.cta5'+k).value;
	window.opener.document.form0.cta6.value=eval('document.result.cta6'+k).value;
	window.opener.document.form0.descCuenta.value=eval('document.result.descripcion'+k).value;
<%}else{%>
	window.opener.document.form1.cta1<%=index%>.value=eval('document.result.cta1'+k).value;
	window.opener.document.form1.cta2<%=index%>.value=eval('document.result.cta2'+k).value;
	window.opener.document.form1.cta3<%=index%>.value=eval('document.result.cta3'+k).value;
	window.opener.document.form1.cta4<%=index%>.value=eval('document.result.cta4'+k).value;
	window.opener.document.form1.cta5<%=index%>.value=eval('document.result.cta5'+k).value;
	window.opener.document.form1.cta6<%=index%>.value=eval('document.result.cta6'+k).value;
	window.opener.document.form1.description<%=index%>.value=eval('document.result.descripcion'+k).value;
<%}%>

	window.opener.focus();
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCIONAR CUENTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("unidad",unidad)%>
			<td width="50%">
				<cellbytelabel>Cuenta</cellbytelabel>
				<%=fb.textBox("cta1",cta1,false,false,false,3,3)%>
												<%=fb.textBox("cta2",cta2,false,false,false,3,3)%>
												<%=fb.textBox("cta3",cta3,false,false,false,3,3)%>
												<%=fb.textBox("cta4",cta4,false,false,false,3,3)%>
												<%=fb.textBox("cta5",cta5,false,false,false,3,3)%>
												<%=fb.textBox("cta6",cta6,false,false,false,3,3)%>
			</td>
			<td>
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
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

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel>Cuenta</cellbytelabel></td>

			<%if (fp.equalsIgnoreCase("presOp")){%><td width="35%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td><td width="20"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
													 <td width="15%"><cellbytelabel>Tipo Cuenta</cellbytelabel></td><%}else{%>
													 <td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<%}%>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
		<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
		<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
		<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
		<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
		<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("lado"+i,cdo.getColValue("lado"))%>
		<%=fb.hidden("descTipoCta"+i,cdo.getColValue("descTipoCta"))%>
		<%=fb.hidden("companiaOrigen"+i,cdo.getColValue("cia_origen"))%>
		<%=fb.hidden("cuenta"+i,cdo.getColValue("cta"))%>		

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setAccount(<%=i%>)">
			<td><%=cdo.getColValue("cta")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<%if (fp.equalsIgnoreCase("presOp")){%><td><%=cdo.getColValue("descCompania")%></td>
													 <td><%=cdo.getColValue("descTipoCta")%></td><%}%>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
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
}
%>