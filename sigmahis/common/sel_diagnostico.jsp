<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.admision.CitaProcedimiento"%>
<%@ page import="issi.admision.ProcedDiagnostico"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htProcKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htDiag" scope="page" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500005") || SecMgr.checkAccess(session.getId(),"500006") || SecMgr.checkAccess(session.getId(),"500007") || SecMgr.checkAccess(session.getId(),"500008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDiag = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String procKey = request.getParameter("procKey");
String fp = request.getParameter("fp");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String tab = request.getParameter("tab");

if (procKey == null) procKey = "";
CitaProcedimiento obj = (CitaProcedimiento) htProc.get(procKey);

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("codigo") != null){
    appendFilter += " where upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  } else if (request.getParameter("descripcion") != null){
    appendFilter += " where upper(decode(observacion, null, nombre, observacion)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "decode(observacion, null, nombre, observacion)";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
  } else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST")){
		if (searchType.equals("1")){
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

	if(fp.equals("edit_cita")){
		sql = "select codigo, nvl(observacion, nombre) descripcion from tbl_cds_diagnostico "+appendFilter+" /*orden by nvl(observacion, nombre)*/";
	}
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Diagnósticos - '+document.title;

function verificarCant(){
	size = <%=al.size()%>;
	var cont = <%=obj.getProcedDiagnosticos().size()%>;
	var contChk =0;
	for(i=0;i<size;i++){
		if(eval('document.procedimiento.chkDiag'+i) && eval('document.procedimiento.chkDiag'+i).checked) contChk++;
		if((contChk+cont)==3){
			alert('No puede seleccionar más de 2 diagnósticos!')
			eval('document.procedimiento.chkDiag'+i).checked = false;
			break;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CENTRO DE SERVICIO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("procKey",procKey)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codCita",codCita)%>
				<%=fb.hidden("fechaCita",fechaCita)%>
				<%=fb.hidden("tab",tab)%>
				<td width="40%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,15)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("procKey",procKey)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codCita",codCita)%>
				<%=fb.hidden("fechaCita",fechaCita)%>
				<%=fb.hidden("tab",tab)%>
				<td width="60%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,70)%>
					<%=fb.submit("go","Ir")%>
				</td>
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
					<%=fb.hidden("procKey",procKey)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("procKey",procKey)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
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
<%
fb = new FormBean("procedimiento","","post","");
%>
<%=fb.formStart()%>
<%=fb.hidden("procKey",procKey)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%
				if(fp.equals("edit_cita")){
				%>
				<tr>
					<td align="right" colspan="3"><%=fb.submit("add","Agregar")%><!--<%=fb.submit("addCont","Agregar y Continuar")%>--></td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="3%">&nbsp;</td>
				</tr>
				<%
				}
				%>							
<%
for (int i=0; i<obj.getProcedDiagnosticos().size(); i++){
	ProcedDiagnostico det = (ProcedDiagnostico) obj.getProcedDiagnosticos().get(i);
	htDiag.put(det.getDiagnostico(), det);
}
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				
				<%
				if(fp.equals("edit_cita")){
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center">
					<%if(fp.equals("edit_cita") && htDiag.containsKey(cdo.getColValue("codigo"))){
					%>
          <cellbytelabel>elegido</cellbytelabel>
          <%} else if(fp.equals("edit_cita") && !htDiag.containsKey(cdo.getColValue("codigo"))){%>
					<%=fb.checkbox("chkDiag"+i,""+i,false, false, "", "", "onClick=\"javascript:verificarCant()\"")%>
					<%}%>
					</td>
				</tr>
				<%
				}
				%>							
<%
}
%>							
<%=fb.hidden("keySize",""+al.size())%>
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
					<%=fb.hidden("procKey",procKey)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("procKey",procKey)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
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
else
{
	System.out.println("=====================POST=====================");
	alDiag = new ArrayList();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	if(fp.equalsIgnoreCase("edit_cita")){
		CitaProcedimiento cp = (CitaProcedimiento) htProc.get(procKey);
		for(int i=0;i<keySize;i++){
			ProcedDiagnostico det = new ProcedDiagnostico();
			det.setCodigo("");
			det.setDiagnostico(request.getParameter("codigo"+i));
			det.setDiagnosticoDesc(request.getParameter("descripcion"+i));
	
			if(request.getParameter("chkDiag"+i)!=null){
				cp.getProcedDiagnosticos().add(det);
			}
		}
	}
	/*
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_diagnostico.jsp?change=1&type=1&procKey="+procKey+"&fp="+fp+"&cs="+cs);
		return;
	}
	*/
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("edit_cita")){%>
	window.opener.location = '<%=request.getContextPath()+"/cita/edit_cita.jsp?mode=edit&change=1&procKey="+procKey%>&fp=<%=fp%>&tab=<%=tab%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>';
	<%}%>
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