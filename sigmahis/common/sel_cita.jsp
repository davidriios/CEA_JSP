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
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String compania = (String)session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String habitacion = "", tipoCita = "", estadoCita = "";
String fromDate = request.getParameter("from_date");
String toDate = request.getParameter("to_date");

if(fromDate == null) fromDate = cDateTime.substring(0,10);
if(toDate == null) toDate = cDateTime.substring(0,10);

if(fp == null) fp = "";
if(fg == null) fg = "";

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

	if (request.getParameter("habitacion") != null && !request.getParameter("habitacion").trim().equals("")){
		appendFilter += " and c.habitacion = '"+request.getParameter("habitacion")+"'";
		habitacion = request.getParameter("habitacion");
	}
	
	if (request.getParameter("tipo_cita") != null && !request.getParameter("tipo_cita").trim().equals("")){
		appendFilter += " and c.cod_tipo = "+request.getParameter("tipo_cita");
		tipoCita = request.getParameter("tipo_cita");
	}
	
	if (request.getParameter("estado_cita") != null && !request.getParameter("estado_cita").trim().equals("")){
		appendFilter += " and c.estado_cita = '"+request.getParameter("estado_cita")+"'";
		estadoCita = request.getParameter("estado_cita");
	}
	
	if (request.getParameter("from_date") != null && !request.getParameter("from_date").trim().equals("") && request.getParameter("to_date") != null && !request.getParameter("to_date").trim().equals("")){
		appendFilter += " and trunc(c.fecha_registro) between to_date('"+request.getParameter("from_date")+"','dd/mm/yyyy') and to_date('"+request.getParameter("to_date")+"','dd/mm/yyyy')";
		fromDate = request.getParameter("from_date"); 
		toDate = request.getParameter("to_date"); 
    }
	
	if (fp.equals("AUD_CITA")){
	    appendFilter += " order by c.codigo, c.hora_cita";
	    sql = "select c.codigo, to_char(c.hora_cita,'dd/mm/yyyy hh12:mi am') as fecha_cita, decode(c.estado_cita,'R','RESERVADA','C','CANCELADA','E','REALIZADA','T','TRANSFERIDA') estado_cita, (select descripcion from tbl_cdc_tipo_cita where codigo = c.cod_tipo and rownum = 1) tipo_cita, (select descripcion from tbl_cds_centro_servicio where codigo = c.centro_servicio and rownum = 1)  cds, (select descripcion from tbl_sal_habitacion where codigo = c.habitacion and rownum = 1) habitacion,nvl((select nombre_paciente from vw_adm_paciente where pac_id=c.pac_id),c.nombre_paciente) as nombre  from tbl_cdc_cita c where 1=1 "+appendFilter;
	}
	
	if (request.getParameter("beginSearch") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a ) where rn between "+previousVal+" and "+nextVal);
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Common - '+document.title;

function setValue(i){
	<%
	if(fp.equals("AUD_CITA")){%>
		window.opener.document.search01.idDoc.value = eval('document.detail.cod_cita'+i).value;		
	<%}%>
	window.close();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CITAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr> <td align="right">&nbsp;</td></tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">

			<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("beginSearch","")%>
				<td width="100%">
					<cellbytelabel>Habitaci&oacute;n</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_sal_habitacion order by 2", "habitacion",habitacion, false, false, 0, "Text10", null, "",null,"T")%>
					
					&nbsp;&nbsp;&nbsp;&nbsp; <cellbytelabel>Tipo Cita</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cdc_tipo_cita order by 2", "tipo_cita",tipoCita, false, false, 0, "Text10", null, "",null,"T")%>
					
					&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Estado Cita</cellbytelabel>
					<%=fb.select("estado_cita","C=CANCELADA,E=REALIZADA,R=RESERVADA,T=TRANSFERIDA",estadoCita,false,false,0,"Text10","","","","T")%>
										
					&nbsp;&nbsp;&nbsp;&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="nameOfTBox1" value="from_date"/>
					<jsp:param name="valueOfTBox1" value="<%=fromDate%>"/>
					<jsp:param name="nameOfTBox2" value="to_date"/>
					<jsp:param name="valueOfTBox2" value="<%=toDate%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
					</jsp:include>
					<%=fb.submit("go","Ir")%>
				</td>
			<%=fb.formEnd()%>
			</tr>
			</table>
		</td>
	</tr>
    <tr><td align="right">&nbsp;</td></tr>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("tipo_cita",tipoCita)%>
				<%=fb.hidden("estado_cita",estadoCita)%>
				<%=fb.hidden("beginSearch","")%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("tipo_cita",tipoCita)%>
				<%=fb.hidden("estado_cita",estadoCita)%>
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
		<table width="100%" cellpadding="0" cellspacing="1">
		  <tr class="TextHeader">
			  <td width="5%" align="center">#Cita</td>
			  <td width="15%" align="center">Fecha Cita</td>
			  <td width="20%">Tipo Cita</td>
			  <td width="20%">Centro de Servicio</td>
			  <td width="20%">Paciente</td>
			  <td width="10%">Habitaci&oacute;n</td>
			  <td width="10%" align="center">Estado</td>
		  </tr>
		  <%
			fb = new FormBean("detail","","post",null);
		  %>
			<%=fb.formStart()%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
		<%
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
		%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValue('<%=i%>')">
			  <td align="center"><%=cdo.getColValue("codigo")%></td>
			  <td align="center"><%=cdo.getColValue("fecha_cita")%></td>
			  <td><%=cdo.getColValue("tipo_cita")%></td>
			  <td><%=cdo.getColValue("cds")%></td>
			  <td><%=cdo.getColValue("nombre")%></td>
			  <td><%=cdo.getColValue("habitacion")%></td>
			  <td align="center"><%=cdo.getColValue("estado_cita")%></td>
			</tr>
			<%=fb.hidden("cod_cita"+i,cdo.getColValue("codigo"))%>
		<%}%>
	    <%=fb.hidden("keySize",""+al.size())%>
		<%=fb.formEnd()%>
		</table>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("tipo_cita",tipoCita)%>
				<%=fb.hidden("estado_cita",estadoCita)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("tipo_cita",tipoCita)%>
				<%=fb.hidden("estado_cita",estadoCita)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%}%>