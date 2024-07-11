<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
int rowCount = 0;
StringBuffer sql = new StringBuffer();
String appendFilter = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cedulaPasaporte = request.getParameter("cedulaPasaporte");
String dob = request.getParameter("dob");
String codigo = request.getParameter("codigo");
String noAdmision = request.getParameter("noAdmision");
String pacId = request.getParameter("pacId");
String paciente = request.getParameter("paciente");
String factura = request.getParameter("factura");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");

int iconHeight = 20;
int iconWidth = 20;

if (cedulaPasaporte == null) cedulaPasaporte = "";
if (dob == null) dob = "";
if (codigo == null) codigo = "";
if (noAdmision == null) noAdmision = "";
if (pacId == null) pacId = "";
if (paciente == null) paciente = "";
if (factura == null) factura = "";
if (fDate == null) fDate = "";
if (tDate == null) tDate = "";

if (!cedulaPasaporte.trim().equals("")) { appendFilter +=" and upper(x.id_paciente) like '%"+cedulaPasaporte.toUpperCase()+"%'"; }
if (!dob.trim().equals("")) { appendFilter +=" and trunc(to_date(x.fechaNacimiento,'dd/mm/yyyy'))=to_date('"+dob+"','dd/mm/yyyy')"; }
if (!codigo.trim().equals("")) { appendFilter +=" and x.codPac="+codigo; }
if (!noAdmision.trim().equals("")) { appendFilter +=" and x.noAdmision="+noAdmision; }
if (!pacId.trim().equals("")) { appendFilter +=" and x.pac_id="+pacId; }
if (!paciente.trim().equals("")) { appendFilter +=" and upper(x.paciente) like '%"+paciente.toUpperCase()+"%'"; }


//if (!factura.trim().equals("")) { appendFilter +="  and upper(a.codigo) like '%"+factura.toUpperCase()+"%'"; }


if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
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
   
  if (request.getParameter("fDate") != null  && !request.getParameter("fDate").trim().equals("")){
    appendFilter += " and x.fecha >= to_date('"+request.getParameter("fDate")+"','dd/mm/yyyy')";
    fDate     = request.getParameter("fDate");   // 
  } 
  if (request.getParameter("tDate") != null  && !request.getParameter("tDate").trim().equals("")){
    appendFilter += " and x.fecha <= to_date('"+request.getParameter("tDate")+"','dd/mm/yyyy')";
    tDate     = request.getParameter("tDate");   // 
  } 

System.out.println("appendFilter == "+appendFilter);

 if(request.getParameter("factura") != null)
{
sql.append(" select x.* from( select (select nombre from tbl_sec_compania where codigo = a.compania) companiaName, a.compania,a.codigo,a.tipo_cobertura,a.pac_id,a.admi_secuencia noAdmision,a.admi_codigo_paciente codPac,to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') fechaNacimiento,a.FACTURAR_A, b.centro_servicio cds , b.conta_cred ,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)  as paciente,  decode(a.facturar_a,'P','PACIENTE','E','EMPRESA' ) facturarA,(select id_paciente from vw_adm_paciente where pac_id = a.pac_id)id_paciente,a.fecha from tbl_fac_factura a, tbl_adm_admision b where not exists (select 1 from tbl_fac_dgi_documents d where d.tipo_docto = 'FACT' and d.impreso = 'Y' and d.codigo = a.codigo and d.compania = a.compania) ");

if (!factura.trim().equals("")) {sql.append(" and upper(a.codigo) ='");
sql.append(factura.toUpperCase());
sql.append("' "); }

sql.append(" and a.compania = ");
sql.append((String)session.getAttribute("_companyId"));
sql.append(" and a.pac_id =b.pac_id and a.admi_secuencia = b.secuencia and a.facturar_a in ('P','E') and a.estatus in ('P','C')");


if((!UserDet.getUserProfile().contains("0"))){
sql.append(" and  b.centro_servicio IN (SELECT cds FROM   tbl_sec_user_cds ucds where exists (select 1 from tbl_sec_users u WHERE u.user_id = ucds.user_id and u.user_name = '");
sql.append((String)session.getAttribute("_userName"));
sql.append("'))");
}
sql.append(")x where x.codigo is not null ");
sql.append(appendFilter.toString());

al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
   rowCount = CmnMgr.getCount("select count(*) from ("+sql.toString()+")");
}
if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";

  if (searchVal != null && !searchVal.equals("")) searchValDisp=searchVal;
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
document.title = 'Facturas - '+document.title;
function anularFact(compania,factura,tipo_cob,pacId,noAdmision)
{
showPopWin('../common/run_process.jsp?fp=factura&actType=7&docType=FACT&docId='+factura+'&docNo='+factura+'&compania='+compania+'&tipoCob='+tipo_cob+'&pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">

				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<tr class="TextFilter">
					<td width="20%">&nbsp;<cellbytelabel>No. Factura</cellbytelabel>
								<%=fb.textBox("factura","",false,false,false,15,null,null,null)%>
					</td>
					<td width="60%"><cellbytelabel>Fecha</cellbytelabel>
					          <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="nameOfTBox1" value="fDate" />
								<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
								<jsp:param name="nameOfTBox2" value="tDate" />
								<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
								<jsp:param name="fieldClass" value="Text10" />
								<jsp:param name="buttonClass" value="Text10" />
								<jsp:param name="clearOption" value="true" />
							  </jsp:include></td>
				</tr>
				<tr class="TextFilter">
				<td colspan="2">

				Paciente:&nbsp;
							<cellbytelabel>Fecha Nac</cellbytelabel>.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
							<cellbytelabel>C&oacute;d. Pac</cellbytelabel>.
				<%=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>

				<cellbytelabel>No. Adm</cellbytelabel>.
				<%=fb.intBox("noAdmision","",false,false,false,3,"Text10",null,null)%>

				<cellbytelabel>C&eacute;dula / Pasaporte</cellbytelabel>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,20,"Text10",null,null)%>

				<cellbytelabel>ID. Paciente</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,false,5,"Text10",null,null)%>
				<%=fb.textBox("paciente","",false,false,false,35,"Text10",null,null)%>
				<%=fb.submit("go","Ir")%>
			</td>
			</tr>
			<%fb.appendJsValidation("if((document.search01.dob.value!='' && !isValidateDate(document.search01.dob.value)) || (document.search01.fDate.value!='' && !isValidateDate(document.search01.fDate.value))|| (document.search01.tDate.value!='' && !isValidateDate(document.search01.tDate.value))){alert('Formato de fecha inválida!');error++;}");%>

			<%=fb.formEnd(true)%>


			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>

</table>
<tr><td colspan="2">&nbsp;</td></tr>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("fDate",fDate)%>
					<%=fb.hidden("tDate",tDate)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("pacId",pacId)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("fDate",fDate)%>
					<%=fb.hidden("tDate",tDate)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("pacId",pacId)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">
	<tr class="TextHeader">
	  	<td width="10%">&nbsp;<cellbytelabel>No. Factura</cellbytelabel></td>
		<td width="25%">&nbsp;<cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel> </td>
		<td width="10%"<cellbytelabel>>F.Nacimiento</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Cod. Paciente</cellbytelabel></td>
		<td width="10%"><cellbytelabel>No. Admisi&oacute;n</cellbytelabel></td>
	    <td width="30%">&nbsp;<cellbytelabel>Paciente</cellbytelabel></td>
		<td width="5%" align="right"><cellbytelabel>Anular</cellbytelabel></td>
	</tr>

	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
	<%=fb.hidden("paciente"+i,cdo.getColValue("paciente"))%>
	<%=fb.hidden("tipo_cobertura"+i,cdo.getColValue("tipo_cobertura"))%>
	<%=fb.hidden("pagos"+i,cdo.getColValue("pagos"))%>
	<%=fb.hidden("pendiente"+i,cdo.getColValue("pendiente"))%>
	<%=fb.hidden("facturarA"+i,cdo.getColValue("facturarA"))%>
	<%=fb.hidden("noAdmision"+i,cdo.getColValue("noAdmision"))%>
	<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>


	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td>&nbsp;<%=cdo.getColValue("companiaName")%></td>
		<td>&nbsp;<%=cdo.getColValue("fechaNacimiento")%></td>
		<td>&nbsp;<%=cdo.getColValue("pac_id")%></td>
		<td>&nbsp;<%=cdo.getColValue("noAdmision")%></td>
		<td>&nbsp;<%=cdo.getColValue("paciente")%></td>
		<td align="center">&nbsp;<authtype type='7'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/cancel.gif" style="text-decoration:none; cursor:pointer"  onClick="javascript:anularFact('<%=cdo.getColValue("compania")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("tipo_cobertura")%>','<%=cdo.getColValue("pac_id")%>','<%=cdo.getColValue("noAdmision")%>')">
	 </authtype>
		</td>


		<td align="center"></td>
	</tr>
	<%
	}
	%>

</table>
<%=fb.formEnd()%>
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("fDate",fDate)%>
					<%=fb.hidden("tDate",tDate)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("pacId",pacId)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

					<%//list_hon_liquidables.jsp
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("fDate",fDate)%>
					<%=fb.hidden("tDate",tDate)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("pacId",pacId)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
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