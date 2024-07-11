<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Vector" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
fg= PO  --->  Registro de ante proyecto del Presupuesto Operativo
fg= UPO --->  Actualizacion del Presupuesto Operativo( Monto Consumido)
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alUnd = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String unidad = request.getParameter("unidad");
String anio        = request.getParameter("anio");
String clase       = request.getParameter("clase_comprob");

String fgFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fg==null) fg = "PO";
if(fp==null) fp = "";
StringBuffer sbSql = new StringBuffer();
sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_sec_unidad_ejec where  nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  ))  and compania=");
/* and codigo <100 */
sbSql.append(session.getAttribute("_companyId"));

/*  se omite el join  **and ue.codigo in(**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */

/*
if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_ua")!=null){
	sbSql.append(" and codigo in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
	sbSql.append(")");}
	else sbSql.append(" and codigo in (-1)");
}

*/
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
		String mes="";
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio = "+request.getParameter("anio");
			anio = request.getParameter("anio");
	}
	if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals("") ){
		appendFilter += " and a.unidad = "+request.getParameter("unidad");
			unidad = request.getParameter("unidad");
	}
	if (request.getParameter("tipoInv") != null && !request.getParameter("tipoInv").trim().equals("") ){
		appendFilter += " and a.tipo_inv = "+request.getParameter("tipoInv");
			clase = request.getParameter("tipoInv");
	}


	String tableName = "",sbField="";
	
	/*  se omite el join  **and ue.codigo in(**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */

	
/*
	if(!UserDet.getUserProfile().contains("0"))
	{
	    appendFilter +=" and ue.codigo in(";
		if(session.getAttribute("_ua")!=null) appendFilter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
		else appendFilter +="-1";
		appendFilter +=")";
    }
	*/
	if (request.getParameter("anio")!= null){
	
	if(fg.trim().equals("PO"))
	{tableName="tbl_con_ante_cuenta_anual";
	 sbField = ", nvl(a.asignacion_actual,0) asignacion,nvl(a.estado,'N') estado ";
	}
	else if(fg.trim().equals("UPO"))
	{
		tableName="tbl_con_cuenta_anual";
		sbField = ", nvl(a.asignacion,0) asignacion,'N' estado";
	}

	sql = "select a.anio, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5,a.cta6, a.compania, a.unidad, a.compania_origen companiaOrigen,a.preaprobado, to_char(a.preaprobado_fecha,'dd/mm/yyyy') preaprobadoFecha, a.preaprobado_usuario preaprobadoUsuario,cg.descripcion desccuenta ,ue.descripcion descunidad,(select descripcion from tbl_con_cla_ctas  where codigo_clase = cg.tipo_Cuenta )descTipoCta, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5 cuenta"+sbField+" from "+tableName+" a,tbl_con_catalogo_gral cg ,tbl_sec_unidad_ejec ue where ue.nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  )) and a.compania="+((String) session.getAttribute("_companyId"))+appendFilter+"  and a.cta1 =cg.cta1 and a.cta2 =cg.cta2 and a.cta3 =cg.cta3 and a.cta4 =cg.cta4 and a.cta5 =cg.cta5 and a.cta6 =cg.cta6 and a.compania_origen =cg.compania and a.unidad = ue.codigo and a.compania = ue.compania order by a.anio desc,a.unidad asc";
	/* and ue.codigo < 100 */
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
function add(){abrir_ventana('../presupuesto/reg_presupuesto.jsp?mode=add&fg=<%=fg%>');}
function edit(anio,cta1,cta2,cta3,cta4,cta5,cta6,unidad){abrir_ventana('../presupuesto/reg_presupuesto.jsp?mode=edit&fg=<%=fg%>&anio='+anio+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&unidad='+unidad);}
function view(anio,cta1,cta2,cta3,cta4,cta5,cta6,unidad){abrir_ventana('../presupuesto/reg_presupuesto.jsp?mode=view&fg=<%=fg%>&anio='+anio+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&unidad='+unidad);}
function printList(){abrir_ventana('../presupuesto/print_list_presupuesto_ope.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');}
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
	<td align="right">&nbsp;
		<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Presupuesto Operativo</cellbytelabel> ]</a></authtype>
	</td>
</tr>
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
			<td width="20%">
				<%//=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","")%>
			</td>
			<td width="80%">
				<cellbytelabel>Unidad</cellbytelabel>
				<%=fb.select("unidad",alUnd,unidad,"S")%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>

		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
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

		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list" >
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Unidad</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Cuenta</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Tipo Cuenta</cellbytelabel>.</td>
			<td width="10%"><cellbytelabel>Asignaci&oacute;n</cellbytelabel></td>
						<td width="5%">&nbsp;</td>
			<td width="5%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td><%=cdo.getColValue("descUnidad")%></td>
			<td><%=cdo.getColValue("cuenta")%></td>
			<td><%=cdo.getColValue("descCuenta")%></td>
			<td><%=cdo.getColValue("descTipoCta")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("asignacion"))%>&nbsp;</td>
			<td align="center">
			<%if (cdo.getColValue("estado").equals("B")|| fg.equals("UPO")){//editar..
%>
						<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,'<%=cdo.getColValue("cta1")%>','<%=cdo.getColValue("cta2")%>','<%=cdo.getColValue("cta3")%>','<%=cdo.getColValue("cta4")%>','<%=cdo.getColValue("cta5")%>','<%=cdo.getColValue("cta6")%>',<%=cdo.getColValue("unidad")%>)" class="Link02Bold"><cellbytelabel>Editar</cellbytelabel></a></authtype>
				<%}%>
						</td>
						<td align="center">
				 <authtype type='1'><a href="javascript:view(<%=cdo.getColValue("anio")%>,'<%=cdo.getColValue("cta1")%>','<%=cdo.getColValue("cta2")%>','<%=cdo.getColValue("cta3")%>','<%=cdo.getColValue("cta4")%>','<%=cdo.getColValue("cta5")%>','<%=cdo.getColValue("cta6")%>',<%=cdo.getColValue("unidad")%>)" class="Link02Bold"><cellbytelabel>ver</cellbytelabel></a></authtype>
			</td>
		</tr>
<%
}
%>
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
}
%>