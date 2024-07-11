<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="issi.contabilidad.CompDetails"%>
<%@ page import="issi.presupuesto.AjusteDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCta" scope="session" class="java.util.Vector"/>
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alUnd = new ArrayList();

int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String tipoAjuste = request.getParameter("tipoAjuste");
int p_anio = 0;
int lastLineNo = 0;

if(fp==null) fp = "";
if(fg==null) fg = "";
if(request.getParameter("p_anio")!=null) p_anio = Integer.parseInt(request.getParameter("p_anio"));
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String descripcion = request.getParameter("descripcion");
String anioIm = request.getParameter("anioIm");
String unidad = request.getParameter("unidad");
String tipoInv = request.getParameter("tipoInv");

sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_sec_unidad_ejec where nivel =3 and codigo <100 and compania=");
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

	if (cta1 == null) cta1 = "";
	if (cta2 == null) cta2 = "";
	if (cta3 == null) cta3 = "";
	if (descripcion == null) descripcion = "";
	if (anioIm == null) anioIm = "";
	if (unidad == null) unidad = "";
	if (tipoInv == null) tipoInv = "";

	if (!cta1.trim().equals("")) { sbFilter.append(" and c.cta1 = "); sbFilter.append(cta1); }
	if (!cta2.trim().equals("")) { sbFilter.append(" and c.cta2 = "); sbFilter.append(cta2); }
	if (!cta3.trim().equals("")) { sbFilter.append(" and c.cta3 = "); sbFilter.append(cta3); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(c.descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!anioIm.trim().equals("")) { sbFilter.append(" and c.anio = "); sbFilter.append(anioIm); }
	if (!unidad.trim().equals("")) { sbFilter.append(" and c.codigo_ue = "); sbFilter.append(unidad); }
	if (!tipoInv.trim().equals("")) { sbFilter.append(" and c.tipo_inv = "); sbFilter.append(tipoInv); }

	if (fp.equalsIgnoreCase("PRESPO"))
	{
		if(!UserDet.getUserProfile().contains("0"))
		{
			if(session.getAttribute("_ua")!=null)
			{
				sbFilter.append(" and cm.unidad in (");
				sbFilter.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
				sbFilter.append(")");
			}
			else sbFilter.append(" and cm.unidad in (-1)");
		}
	}

	sbSql = new StringBuffer();
	sbSql.append("select p.ano, p.cta1, p.cta2, p.cta3, p.cta4, p.cta5, p.cta6, c.descripcion, c.recibe_mov,c.cta1||'.'||c.cta2||'.'||c.cta3||'.'||c.cta4||'.'||c.cta5||'.'||c.cta6 cuenta from tbl_con_plan_cuentas p, tbl_con_catalogo_gral c where p.cta1 = c.cta1 and p.cta2 = c.cta2 and p.cta3 = c.cta3 and p.cta4 = c.cta4 and p.cta5 = c.cta5 and p.cta6 = c.cta6 and c.status ='A' and p.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and p.ano = ");
	sbSql.append(p_anio);
	sbSql.append(sbFilter);
	sbSql.append(" and c.compania = p.compania and c.recibe_mov = 'S' order by p.ano, p.cta1, p.cta2, p.cta3, p.cta4, p.cta5, p.cta6");

	if (fp.equalsIgnoreCase("PRESPO")) {
		sbSql = new StringBuffer();
		sbSql.append("select cm.anio, cm.cta1||'-'||cm.cta2||'-'||cm.cta3||'-'||cm.cta4||'-'||cm.cta5||'-'||cm.cta6 as numCuenta, initcap(c.descripcion) as descripcion, nvl(cm.compania_origen,cm.compania) as companiaOrigen, cm.cta1, cm.cta2, cm.cta3, cm.cta4, cm.cta5, cm.cta6, cm.compania, cm.mes, (nvl(cm.traslado,0) + nvl(cm.asignacion,0) + nvl(cm.redistribuciones,0) - nvl(cm.consumido,0)) as dspAsignacion from tbl_con_cuenta_mensual cm, tbl_con_catalogo_gral c where (c.cta1 = cm.cta1 and c.cta2 = cm.cta2 and c.cta3 = cm.cta3 and c.cta4 = cm.cta4 and c.cta5 = cm.cta5 and c.cta6 = cm.cta6 and c.compania = nvl(cm.compania_origen,cm.compania)) and c.status ='A' and cm.anio in (select ano from tbl_con_estado_meses where estatus = 'ACT' and cod_cia = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(") and cm.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" and c.recibe_mov = 'S'  order by cm.unidad,cm.mes, c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6");
	} else if (fp.equalsIgnoreCase("PRESPI")) {
		sbSql = new StringBuffer();
		sbSql.append("select c.anio anio, c.tipo_inv as tipoInv, c.compania, c.codigo_ue as codigoUe, c.consec, c.mes, c.estado, (nvl(c.traslado,0) + nvl(c.aprobado,0) + nvl(c.redistribuciones,0) - nvl(c.ejecutado,0)) as dspAsignacion, c.descripcion, (select descripcion from tbl_con_tipo_inversion where tipo_inv = c.tipo_inv and compania = c.compania ) as descTipoInv, (select descripcion from tbl_sec_unidad_ejec where codigo = c.codigo_ue and compania = c.compania) as descUnidad from tbl_con_inversion_mensual c where c.estado in ('ACT','INA') and c.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" and c.recibe_mov = 'S' and c.status ='A' order by c.anio, c.tipo_inv, c.compania, c.codigo_ue, c.consec, c.mes");
	}

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Contabilidad - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - SELECCION DE CUENTAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<% fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("p_anio",""+p_anio)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("tipoAjuste",""+tipoAjuste)%>
<% if (!fp.equalsIgnoreCase("PRESPI")) { %>
			<td width="20%">
				Cta 1
				<%=fb.intBox("cta1",cta1,false,false,false,5,3)%>
			</td>
			<td width="20%">
				Cta 2
				<%=fb.intBox("cta2",cta2,false,false,false,5,2)%>
			</td>
			<td width="20%">
				Cta 3
				<%=fb.intBox("cta3",cta3,false,false,false,5,3)%>
			</td>
			<td width="40%">
				Descripci&oacute;n
				<%=fb.textBox("descripcion","",false,false,false,20)%>
				<%=fb.submit("go","Ir")%>
			</td>
<% } else { %>
			<td width="20%">
				A&ntilde;o
				<%=fb.intBox("anioIm",anioIm,false,false,false,10)%>
			</td>
			<td width="40%">
				Tipo De Inversi&oacute;n
				<%=fb.select(ConMgr.getConnection(),"select a.tipo_inv, a.descripcion||' - '||a.compania||' - '||(select nombre from tbl_sec_compania where codigo = a.compania) from tbl_con_tipo_inversion a where a.compania = "+session.getAttribute("_companyId")+" order by a.descripcion","tipoInv",tipoInv,false,false,0,"S")%>
			</td>
			<td width="40%">
				Unidad <%=fb.select("unidad",alUnd,unidad,"S")%>
				<%=fb.submit("go","Ir")%>
			</td>
<% } %>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("results",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextVal",""+nxtVal)%>
<%=fb.hidden("previousVal",""+preVal)%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("p_anio",""+p_anio)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("tipoAjuste",""+tipoAjuste)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("anioIm",anioIm)%>
<%=fb.hidden("tipoInv",tipoInv)%>
<%=fb.hidden("unidad",unidad)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveNcontT","Agregar y Continuar",true,false)%>
				<%=fb.submit("saveT","Agregar",true,false)%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<% if (!fp.equalsIgnoreCase("PRESPI")) { %>
		<tr class="TextHeader" align="center">
			<% if (fp.equalsIgnoreCase("PRESPO")) { %><td width="5%">Mes</td><% } %>
			<td width="5%">Cta1</td>
			<td width="5%">Cta2</td>
			<td width="5%">Cta3</td>
			<td width="5%">Cta4</td>
			<td width="5%">Cta5</td>
			<td width="5%">Cta6</td>
			<td width="60%">Descrpci&oacute;n</td>
			<td width="10%">&nbsp;</td>
		</tr>
<% } else if (fp.equalsIgnoreCase("PRESPI")) { %>
		<tr class="TextHeader" align="center">
			<td width="5%">Año</td>
			<td width="5%">Compañia</td>
			<td width="5%">Tipo Inv.</td>
			<td width="5%">Mes</td>
			<td width="5%">consec</td>
			<td width="5%">Asignacion</td>
			<td width="5%">Unidad</td>
			<td width="60%">Descrpci&oacute;n</td>
			<td width="10%">&nbsp;</td>
		</tr>
<% } %>

<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key ="";
	key = cdo.getColValue("cta1")+"-"+cdo.getColValue("cta2")+"-"+cdo.getColValue("cta3")+"-"+cdo.getColValue("cta4")+"-"+cdo.getColValue("cta5")+"-"+cdo.getColValue("cta6");
	if (fp.equalsIgnoreCase("PRESPO") || fp.equalsIgnoreCase("PRESPI")) { key = cdo.getColValue("compania")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("mes")+"-"+cdo.getColValue("cta1")+"-"+cdo.getColValue("cta2")+"-"+cdo.getColValue("cta3")+"-"+cdo.getColValue("cta4")+"-"+cdo.getColValue("cta5")+"-"+cdo.getColValue("cta6"); }
	else if (fp.equalsIgnoreCase("PRESPI")) key = cdo.getColValue("compania")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("mes")+"-"+cdo.getColValue("codigoUe")+"-"+cdo.getColValue("consec");
%>
		<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
		<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
		<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
		<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
		<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
		<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("recibe_mov"+i,cdo.getColValue("recibe_mov"))%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
		<%=fb.hidden("dspAsignacion"+i,cdo.getColValue("dspAsignacion"))%>
		<%=fb.hidden("companiaOrigen"+i,cdo.getColValue("companiaOrigen"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("numCuenta"+i,cdo.getColValue("numCuenta"))%>
		<%=fb.hidden("tipoInv"+i,cdo.getColValue("tipoInv"))%>
		<%=fb.hidden("consec"+i,cdo.getColValue("consec"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("codigoUe"+i,cdo.getColValue("codigoUe"))%>
		<%=fb.hidden("descUnidad"+i,cdo.getColValue("descUnidad"))%>
		<%=fb.hidden("cuenta"+i,cdo.getColValue("cuenta"))%>
<% if (!fp.equalsIgnoreCase("PRESPI")) { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<% if (fp.equalsIgnoreCase("PRESPO")) { %><td><%=fb.select("mesDesde"+i,"01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,true,0,null,null,null,"","")%></td><% } %>
			<td><%=cdo.getColValue("cta1")%></td>
			<td><%=cdo.getColValue("cta2")%></td>
			<td><%=cdo.getColValue("cta3")%></td>
			<td><%=cdo.getColValue("cta4")%></td>
			<td><%=cdo.getColValue("cta5")%></td>
			<td><%=cdo.getColValue("cta6")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><% if (fp.equalsIgnoreCase("PRESPO") || fp.equalsIgnoreCase("PRESPI")) { %><%=(vCta.contains(key))?"Elegido":fb.checkbox("check"+i,key,false,false)%><% } else { %><%=fb.checkbox("check"+i,key,false,false)%><% } %></td>
		</tr>
<% } else if (fp.equalsIgnoreCase("PRESPI")) { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=cdo.getColValue("anio")%></td>
			<td><%=cdo.getColValue("compania")%></td>
			<td><%=cdo.getColValue("descTipoInv")%></td>
			<td><%=fb.select("mes"+i+"_","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,true,0,null,null,null,"","")%></td>
			<td><%=cdo.getColValue("consec")%></td>
			<td><%=cdo.getColValue("dspAsignacion")%></td>
			<td><%=cdo.getColValue("descUnidad")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%=(vCta.contains(key))?"Elegido":fb.checkbox("check"+i,key,false,false)%></td>
		</tr>
<% } %>
<%
}

if (al.size() == 0)
{
%>
		<tr>
			<td align="center" colspan="9">No registros encontrados.</td>
		</tr>
<%
}
%>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveNcontB","Agregar y Continuar",true,false)%>
				<%=fb.submit("saveB","Agregar",true,false)%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	if (!fp.equalsIgnoreCase("PRESPO") && !fp.equalsIgnoreCase("PRESPI")) {

		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CompDetails cta = new CompDetails();

				cta.setAnoCta(""+p_anio);
				cta.setCta1(request.getParameter("cta1"+i));
				cta.setCta2(request.getParameter("cta2"+i));
				cta.setCta3(request.getParameter("cta3"+i));
				cta.setCta4(request.getParameter("cta4"+i));
				cta.setCta5(request.getParameter("cta5"+i));
				cta.setCta6(request.getParameter("cta6"+i));
				cta.setDescripcion(request.getParameter("descripcion"+i));
				cta.setRecibeMov(request.getParameter("recibe_mov"+i));
				cta.setValor("0.00");
				cta.setDescCuenta(request.getParameter("descripcion"+i));
				cta.setCuenta(request.getParameter("cuenta"+i));
				cta.setDetalleAux("0");
				if (fp.equalsIgnoreCase("comp_diario")|| fp.equalsIgnoreCase("EC") || fp.equalsIgnoreCase("RE")){cta.setAction("I");cta.setRenglon("-1");}
				lastLineNo++;

				String key = "";
				if (lastLineNo < 10) key = "000"+lastLineNo;
				else if (lastLineNo < 100) key = "00"+lastLineNo;
				else if (lastLineNo < 1000) key = "0"+lastLineNo;
				else key = ""+lastLineNo;
				cta.setKey(key);

				try
				{
					iCta.put(cta.getKey(), cta);
					vCta.add(cta.getCta1()+"-"+cta.getCta2()+"-"+cta.getCta3()+"-"+cta.getCta4()+"-"+cta.getCta5()+"-"+cta.getCta6());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}

	}	else if (fp.equalsIgnoreCase("PRESPO") || fp.equalsIgnoreCase("PRESPI")) {

		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				AjusteDetail ajCta = new AjusteDetail();

				ajCta.setAnio(request.getParameter("anio"+i));
				ajCta.setMes(request.getParameter("mes"+i));
				ajCta.setCta1(request.getParameter("cta1"+i));
				ajCta.setCta2(request.getParameter("cta2"+i));
				ajCta.setCta3(request.getParameter("cta3"+i));
				ajCta.setCta4(request.getParameter("cta4"+i));
				ajCta.setCta5(request.getParameter("cta5"+i));
				ajCta.setCta6(request.getParameter("cta6"+i));
				ajCta.setDescCuenta(request.getParameter("descripcion"+i));
				ajCta.setCompaniaOrigen(request.getParameter("companiaOrigen"+i));
				ajCta.setCompania(request.getParameter("compania"+i));
				ajCta.setDspAsignacion(request.getParameter("dspAsignacion"+i));
				ajCta.setNumCuenta(request.getParameter("numCuenta"+i));

				ajCta.setConsec(request.getParameter("consec"+i));
				ajCta.setCodigoUe(request.getParameter("codigoUe"+i));

				ajCta.setTipoInv(request.getParameter("tipoInv"+i));
				ajCta.setDescUnidad(request.getParameter("descUnidad"+i));
				ajCta.setAnioIm(request.getParameter("anio"+i));

				ajCta.setMontoOrigen("0");
				lastLineNo++;

				String key = "";
				if (lastLineNo < 10) key = "000"+lastLineNo;
				else if (lastLineNo < 100) key = "00"+lastLineNo;
				else if (lastLineNo < 1000) key = "0"+lastLineNo;
				else key = ""+lastLineNo;
				ajCta.setKey(key);

				try
				{
					iCta.put(ajCta.getKey(), ajCta);
					if (fp.equalsIgnoreCase("PRESPO")) vCta.add(ajCta.getCompania()+"-"+ajCta.getAnio()+"-"+ajCta.getMes()+"-"+ajCta.getCta1()+"-"+ajCta.getCta2()+"-"+ajCta.getCta3()+"-"+ajCta.getCta4()+"-"+ajCta.getCta5()+"-"+ajCta.getCta6());
					else vCta.add(ajCta.getCompania()+"-"+ajCta.getAnio()+"-"+ajCta.getMes()+"-"+ajCta.getCodigoUe()+"-"+ajCta.getConsec());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}//for

	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&fg="+fg+"&fp="+fp+"&p_anio="+p_anio+"&lastLineNo="+lastLineNo+"&tipoAjuste="+tipoAjuste+"&cta1="+cta1+"&cta2="+cta2+"&cta3="+cta3+"&descripcion="+descripcion+"&anioIm="+anioIm+"&tipoInv="+tipoInv+"&unidad="+unidad+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&fg="+fg+"&fp="+fp+"&p_anio="+p_anio+"&lastLineNo="+lastLineNo+"&tipoAjuste="+tipoAjuste+"&cta1="+cta1+"&cta2="+cta2+"&cta3="+cta3+"&descripcion="+descripcion+"&anioIm="+anioIm+"&tipoInv="+tipoInv+"&unidad="+unidad+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if (request.getParameter("saveNcontT") != null || request.getParameter("saveNcontB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&fg="+fg+"&fp="+fp+"&p_anio="+p_anio+"&lastLineNo="+lastLineNo+"&tipoAjuste="+tipoAjuste+"&cta1="+cta1+"&cta2="+cta2+"&cta3="+cta3+"&descripcion="+descripcion+"&anioIm="+anioIm+"&tipoInv="+tipoInv+"&unidad="+unidad+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("comp_diario") || fp.equalsIgnoreCase("EC") || fp.equalsIgnoreCase("RE"))
	{
%>
	window.opener.location = '../contabilidad/reg_comp_diario_det.jsp?change=1&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&lastLineNo=<%=lastLineNo%>';
<%
	}else if (fp.equalsIgnoreCase("PRESPO") || fp.equalsIgnoreCase("PRESPI"))
	{
%>
	window.opener.location = '../presupuesto/reg_ajuste_presupuesto_det.jsp?change=1&mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>';
<%
	}

%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>
