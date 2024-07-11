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

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String pacName = request.getParameter("pacName");
String careDate = request.getParameter("careDate");
String patientCode = request.getParameter("patientCode");
String dob = request.getParameter("dob");
String parent = request.getParameter("parent");

String fechaCreaF = request.getParameter("fechaCreaF");
String fechaCreaT = request.getParameter("fechaCreaT");

String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (pacId == null) pacId = "0";
if (noAdmision == null) noAdmision = "0";
if (pacName == null) pacName = "";
if (fechaCreaF==null) fechaCreaF = cDate;
if (fechaCreaT==null) fechaCreaT = cDate;
if (parent==null) parent = "";


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
	
	String codigo  = "";
	String descrip = "";

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and s.codigo = "+request.getParameter("codigo");
	codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(s.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip = request.getParameter("descripcion");
  }
  
  sql = "select s.codigo, s.descripcion, s.table_name, s.where_clause, decode(usado_por,'EF','ENFERMERIA','MD','MEDICO','TG','TRIAGE','ME','MEDICO Y ENFERMERIA','AM','TODOS','IC','INTERCONSULTOR','MI','MEDICO E INTERCONSULTOR','MIE','MEDICO, INTERCONSULTOR, ENFERMERA','EA','ENFERMERA Y ASIST. ADM.','AA','ASISTENTE ADMINISTRATIVO','MEA','MEDICO, ENFERMERA Y ASIST. ADM.')as usadopor, nvl(s.path||decode(instr(s.path,'?'),0,'?',null,'','&'),' ') as path, s.aud_det_path from tbl_sal_expediente_secciones s where s.table_name is not null /*and s.aud_det_path is not null*/ "+appendFilter+" order by 2";
  
  if (request.getParameter("beginSearch")!=null){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount(" SELECT count(*) FROM ("+sql+") ");
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
document.title = 'Secciones de Documentos Médicos - '+document.title;
function add(){<%if (UserDet.getUserProfile().contains("0")) {%>abrir_ventana('../expediente/doc_medico_config.jsp');<%}%>}
function edit(id){abrir_ventana('../expediente/doc_medico_config.jsp?mode=edit&id='+id);}
function printList(){abrir_ventana('../expediente/print_list_sec_doc_medico.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}

function showPacienteList(i)
{
	if(i==1)abrir_ventana1('../common/search_paciente.jsp?fp=secciones_guardadas');
	else if(i==2){
	  var pacId= document.search01.pacId.value;
	  if(pacId)abrir_ventana1('../common/sel_paciente.jsp?fp=secciones_guardadas&cod_paciente='+pacId);
	  else alert("Por favor seleccione el paciente!");
	}
}

function showDetails(i){
    var pacId = $("#pacId").val() || '0';
    var noAdmision = $("#noAdmision").val() || '0';
    var careDate = $("#careDate").val() || '';
    var patientCode = $("#patientCode").val() || '0';
    var dob = $("#dob").val() || '';
    var section = $("#section"+i).val() || '';
    var sectionDesc = $("#sectionDesc"+i).val() || '';
    var path = $("#path"+i).val() || '';
    var audDetPath = $("#aud_det_path"+i).val() || '';
    var _qry = $("#qry"+i).val() || '';
    var tot = $("#tot"+i).val() || '0';
		
	if (parseInt(pacId,10) && parseInt(noAdmision,10) && careDate && parseInt(tot)){
		if (audDetPath) <%=parent.trim().equals("")?"":parent+"."%>showPopWin(audDetPath+'&mode=view',winWidth*.75,winHeight*.65,null,null,'');
		else showPopWin('../expediente/expediente_list.jsp?fp=secciones_guardadas&codigo='+pacId+'&noAdmision='+noAdmision+'&statusAdm=A,E,I&careDate='+careDate+'&dob='+dob+'&pacientCode='+patientCode+'&section='+section+'&sectionDesc='+sectionDesc+'&path='+path,winWidth*.75,winHeight*.65,null,null,'');
	}
	//debug(_qry)
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("beginSearch","")%>
		<%=fb.hidden("careDate",careDate)%>
		<%=fb.hidden("patientCode",patientCode)%>
		<%=fb.hidden("dob",dob)%>
		<%=fb.hidden("parent",parent)%>
		<tr class="TextFilter">		
			<td width="100%">
				<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo",codigo,false,false,false,5)%>
				<cellbytelabel id="3">Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion",descrip,false,false,false,20)%>
				&nbsp;&nbsp;&nbsp;
				PacId
				<%=fb.textBox("pacId",pacId,false,false,true,10,"Text10","","")%>
				<%=fb.textBox("pacName",pacName,false,false,true,50,"Text10","","")%>
				<%=fb.button("btnPacienteAdd","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList(1)\"","BUSCAR ADMISION")%>
				&nbsp;&nbsp;&nbsp;
				Admisi&oacute;n
				<%=fb.textBox("noAdmision",noAdmision,false,false,true,5,"Text10","","")%>
				<%=fb.button("btnAdmAdd","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList(2)\"","BUSCAR ADMISION")%> 
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="100%">
			   <jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="nameOfTBox1" value="fechaCreaF" />
					<jsp:param name="valueOfTBox1" value="<%=fechaCreaF%>" />
					<jsp:param name="nameOfTBox2" value="fechaCreaT" />
					<jsp:param name="valueOfTBox2" value="<%=fechaCreaT%>" />
				</jsp:include>
				&nbsp;&nbsp;&nbsp;
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<!--
<tr>
	<td align="right">&nbsp<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
-->
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descrip)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("careDate",careDate)%>
<%=fb.hidden("patientCode",patientCode)%>
<%=fb.hidden("dob",dob)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descrip)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("careDate",careDate)%>
<%=fb.hidden("patientCode",patientCode)%>
<%=fb.hidden("dob",dob)%>
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
	
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader">
			<td width="15%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
			<td width="50%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="8">Usado por</cellbytelabel></td>
			<td width="10%" align="center">Total</td>
		</tr>				
<%
String t = "", code="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
	String whereClause = cdo.getColValue("where_clause");
	whereClause = whereClause.replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision).replaceAll("@@FCF","to_date('"+fechaCreaF+"','dd/mm/yyyy')").replaceAll("@@FCT","to_date('"+fechaCreaT+"','dd/mm/yyyy')");
	
	String audDetPath = cdo.getColValue("aud_det_path");
	audDetPath = audDetPath.replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision).replaceAll("@@SECTION",cdo.getColValue("codigo"));
	
	String _sql = "select count(*) as tot from ("+cdo.getColValue("table_name")+") where "+whereClause;
		
	CommonDataObject cdoT = (CommonDataObject) SQLMgr.getData(_sql);
	if (cdoT==null){
		cdoT = new CommonDataObject();
		cdoT.addColValue("tot","0");
		t += _sql+"\n";
	}else code += cdo.getColValue("codigo")+(al.size()==(1+i)?"":",");
	
%>
		
		<%=fb.hidden("section"+i, cdo.getColValue("codigo"))%>
		<%=fb.hidden("sectionDesc"+i, cdo.getColValue("descripcion"))%>
		<%=fb.hidden("path"+i, cdo.getColValue("path"))%>
		<%=fb.hidden("aud_det_path"+i,audDetPath)%>
		<%=fb.hidden("qry"+i,_sql)%>
		<%=fb.hidden("tot"+i,cdoT.getColValue("tot"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:showDetails(<%=i%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("usadoPor")%></td>
			<td align="center"><%=cdoT.getColValue("tot")%></td>
		</tr>
<%
}
System.out.println("Please Correct:");
System.out.println(t);
System.out.println(code);
System.out.println("................................................");
%>							
		</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
	</td>
</tr>
</table>				

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descrip)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("careDate",careDate)%>
<%=fb.hidden("patientCode",patientCode)%>
<%=fb.hidden("dob",dob)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descrip)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("careDate",careDate)%>
<%=fb.hidden("patientCode",patientCode)%>
<%=fb.hidden("dob",dob)%>
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