<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
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
String sql = "";
String appendFilter = "";
String codigo = "";
String name = "", estado="";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbAppendFilter = new StringBuffer();
String schemaName ="";
String schemaTblPrexix ="";
String userName = request.getParameter("user_name");
String companyId = (String)session.getAttribute("_companyId");
String process = request.getParameter("process")==null?"":request.getParameter("process");
String subProcess = request.getParameter("sub_process")==null?"":request.getParameter("sub_process");
String processName = request.getParameter("processName")==null?"":request.getParameter("processName");
String fromDate = request.getParameter("from_date")==null?"":request.getParameter("from_date");
String toDate = request.getParameter("to_date")==null?"":request.getParameter("to_date");
String innerAppendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String idDoc = request.getParameter("idDoc")==null?"":request.getParameter("idDoc");
String noDoc = request.getParameter("noDoc")==null?"":request.getParameter("noDoc");
String almacen = request.getParameter("almacen")==null?"":request.getParameter("almacen");

ArrayList<String> alTblTitle = new ArrayList<String>();

CommonDataObject cdoS = SQLMgr.getData("select nvl(get_sec_comp_param("+companyId+",'AUD_SCHEMA'),'-1') as schemaData from dual");

if (cdoS != null){
		String _schemaData = cdoS.getColValue("schemaData");
	try{
		schemaName = _schemaData.split("@@")[0];
		schemaTblPrexix = _schemaData.split("@@")[1];
	}catch(Exception e){e.printStackTrace();}
}

if (userName == null || "".equals(userName)) userName = (String)session.getAttribute("_userName");
if (fromDate.equals("")) fromDate = cDateTime.substring(0,10);
if (toDate.equals("")) toDate = cDateTime.substring(0,10);

Exception up = new Exception("No pudimos identificar el nombre del esquema!");
if (schemaName.trim().equals("")) throw up; //--> classic :D
else if (schemaName.equals("-1")) throw new Exception("El sistema no tiene habilitado Auditorías. Por favor consulte con su Administrador!");

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=1000;
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

	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
		appendFilter += " and upper(a.aud_action) = '"+request.getParameter("estado").toUpperCase()+"'";
		searchOn = "estado";
		searchVal = request.getParameter("estado");
		searchType = "1";
		searchDisp = "Estado";
		estado = request.getParameter("estado");
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
	 if (searchType.equals("1"))
	 {
		 appendFilter += " where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
	 }
	}
	else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
	}


if (process.trim().equals("ART")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment
	 alTblTitle.clear();
/*
1. Precio
2. Ultimo Precio de compra
3. Pto_reorden
4. Max_punto reorden
5. Anaquel.
*/
	 alTblTitle.add("1@@Cód.Art@@7@@center");
	 alTblTitle.add("2@@PRECIO@@10@@right");
	 alTblTitle.add("3@@ULT. PRECIO COMPRA@@4@@right");
	 alTblTitle.add("4@@PTO. REORDEN@@4@@center");
	 alTblTitle.add("5@@MAX. PTO. REORDEN@@4@@center");
	 alTblTitle.add("6@@ANAQUEL@@5@@center");



	 sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.cod_articulo field1, a.precio as field2, a.ultimo_precio as field3, pto_reorden field4, a.pto_max_existencia as field5, a.codigo_anaquel as field6, (select nombre from tbl_inv_familia_articulo where cod_flia = a.art_familia and compania = a.compania )||' - '||a.art_familia fieldGr1, (select descripcion from tbl_inv_clase_articulo where compania = a.compania and cod_flia = a.art_familia and cod_clase = a.art_clase )||' - '||a.art_clase as fieldGr2 from ");
		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("INV_INVENTARIO a");
		sbSql.append(" where compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and cod_articulo = ");
		sbSql.append(idDoc);
		if(!almacen.equals("")){
		sbSql.append(" and codigo_almacen = ");
		sbSql.append(almacen);
		}
		if (!fromDate.trim().equals("")) {
			sbSql.append(" and trunc(aud_timestamp) >= to_date('");
			sbSql.append(fromDate);
			sbSql.append("','dd/mm/yyyy')");
		}
		if (!toDate.trim().equals("")) {
			sbSql.append(" and trunc(aud_timestamp) <= to_date('");
			sbSql.append(toDate);
			sbSql.append("','dd/mm/yyyy')");
		}
		sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc");

}

if (request.getParameter("beginSearch")!=null && !sbSql.toString().equals("")){
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
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
document.title = 'Administración - Auditoria - '+document.title;
var sbAppendFilter = "<%=sbAppendFilter%>";
var appendFilter = "<%=appendFilter%>";
var sbSql = "<%=sbSql%>";

$(document).ready(function(){


	$("#go").click(function(){
		var process = "<%=process%>";
		var idDoc = $("#idDoc").val();
		var fromDate = $("#from_date").val();
		var toDate = $("#to_date").val();
		var __doSearch = false;

		$("#search01").submit();
	});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - AUDITORIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">&nbsp;

		</td>
	</tr>
	<tr>
		<td colspan="4" align="right">
			<!--<authtype type='3'><a href="javascript:manageConsentimiento()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Consentimiento</cellbytelabel> ]</a></authtype>-->
		</td>
	</tr>

	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("process",process)%>
			<%=fb.hidden("idDoc",idDoc)%>
			<td colspan="2">&nbsp;
			<%if(process.trim().equals("ART")){%>
			<cellbytelabel id="2">Almacen:</cellbytelabel>&nbsp;
			<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+" order by 2","almacen",almacen, false, false,0,null,"width:200px","","Proceso","S")%>


				From:<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="from_date"/>
				<jsp:param name="valueOfTBox1" value="<%=fromDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				To:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="to_date"/>
				<jsp:param name="valueOfTBox1" value="<%=toDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>

				<%}%>
				<%=fb.button("go","Ir",true,false,null,null,"")%>
			</td>
		<%=fb.formEnd(true)%>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
			<!--<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>-->
		</td>
	</tr>
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
				<%=fb.hidden("process",process)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("user_name",userName)%>
				<%=fb.hidden("idDoc",idDoc)%>
				<%=fb.hidden("noDoc",noDoc)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel>&nbsp;<%=rowCount%>&nbsp;</td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>&nbsp;<%=pVal%>&nbsp;<cellbytelabel id="7">hasta</cellbytelabel>&nbsp;<%=nVal%></td>
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
					<%=fb.hidden("process",process)%>
					<%=fb.hidden("from_date",fromDate)%>
						<%=fb.hidden("to_date",toDate)%>
					<%=fb.hidden("user_name",userName)%>
					<%=fb.hidden("idDoc",idDoc)%>
					<%=fb.hidden("noDoc",noDoc)%>
				<%=fb.hidden("almacen",almacen)%>
					<%=fb.hidden("beginSearch","")%>
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
			<tr class="TextHeader">
				<td width="12%">&nbsp;AUD User</td>
				<td width="13%" align="center">AUD Fecha</td>
				<td width="7%" align="center">AUD Acci&oacute;n</td>
				<%
					for (int t = 0; t<alTblTitle.size(); t++){
					String _title = (alTblTitle.get(t)).split("@@")[1];
					String _width = (alTblTitle.get(t)).split("@@")[2];
					String _align = (alTblTitle.get(t)).split("@@")[3];
					%>
					 <td width="<%=_width%>%" align="<%=_align%>"><%=_title%></td>
				<%
				}
				%>
			</tr>
			<%  String fieldNum = "", groupName = "", groupName1 = "", groupName2 = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";

					if (cdo.getColValue("fieldGr") != null && !groupName.equalsIgnoreCase(cdo.getColValue("fieldGr")))
					{
				%>
				<tr class="TextHeader01">
					<td colspan="13">&nbsp;<%=cdo.getColValue("fieldGr")%></td>
				</tr>
			<%
					}
			%>

			<%if (cdo.getColValue("fieldGr1") != null && !groupName1.equalsIgnoreCase(cdo.getColValue("fieldGr1"))){%>
					<tr class="TextHeader02">
					<td colspan="<%=alTblTitle.size()+3%>">&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("fieldGr1")%></td>
				</tr>
			<%}%>

			<%if (cdo.getColValue("fieldGr2") != null && !groupName2.equalsIgnoreCase(cdo.getColValue("fieldGr2"))){%>
					<tr class="TextHeader02">
					<td colspan="<%=alTblTitle.size()+3%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("fieldGr2")%></td>
				</tr>
			<%}%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("aud_webuser_ip")%></td>
					<td align="center"><%=cdo.getColValue("aud_timestamp")%></td>
					<td align="center"><%=cdo.getColValue("aud_action_desc")%></td>
					<%
						for (int t = 0; t<alTblTitle.size(); t++){
							String _align = (alTblTitle.get(t)).split("@@")[3];
							fieldNum = (alTblTitle.get(t)).split("@@")[0];
					%>
						<td align="<%=_align%>"><%=cdo.getColValue("field"+fieldNum)%></td>
					<%}%>
				</tr>
				<%
				groupName = cdo.getColValue("fieldGr");
				groupName1 = cdo.getColValue("fieldGr1");
				groupName2 = cdo.getColValue("fieldGr2");
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
				<%=fb.hidden("process",process)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("user_name",userName)%>
				<%=fb.hidden("idDoc",idDoc)%>
				<%=fb.hidden("noDoc",noDoc)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel>&nbsp;<%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>&nbsp;<%=pVal%>&nbsp;<cellbytelabel id="7">hasta</cellbytelabel>&nbsp;<%=nVal%></td>
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
					<%=fb.hidden("process",process)%>
					<%=fb.hidden("from_date",fromDate)%>
						<%=fb.hidden("to_date",toDate)%>
					<%=fb.hidden("user_name",userName)%>
					<%=fb.hidden("idDoc",idDoc)%>
					<%=fb.hidden("noDoc",noDoc)%>
				<%=fb.hidden("almacen",almacen)%>
					<%=fb.hidden("beginSearch","")%>
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
