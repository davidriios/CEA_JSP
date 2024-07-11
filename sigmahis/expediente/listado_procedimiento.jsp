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
String sql = "";
String appendFilter = "";
String filter = "";
String index = "";
String id = "";
String fp = request.getParameter("fp");
String context = request.getParameter("context")==null?"":request.getParameter("context");
String name="",code="";
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (request.getParameter("filter") != null)	 filter = request.getParameter("filter");
  if (request.getParameter("index") != null && !request.getParameter("index").trim().equals(""))
	 index = request.getParameter("index");
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
  if(request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
  {
		appendFilter += " and upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
    code = request.getParameter("code");
  }
  if (request.getParameter("name") != null && !request.getParameter("name").trim().equals(""))
  {    
		appendFilter += " and upper(decode(observacion , null , descripcion,observacion)) like '%"+request.getParameter("name").toUpperCase()+"%'";
    name = request.getParameter("name");
  }
		

if (fp.equalsIgnoreCase("exp_hospitalizacion_cirugia"))
	{
  sql = "SELECT CODIGO, decode(observacion , null , descripcion, observacion) as descripcion FROM TBL_CDS_PROCEDIMIENTO WHERE TIPO_CATEGORIA = 2 and estado = 'A' "+appendFilter+" ORDER BY 1";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
}
else if (fp.equalsIgnoreCase("exp_recuperacion_anestesia") || fp.equalsIgnoreCase("convenio_beneficio")|| fp.equalsIgnoreCase("convenio_beneficio_new") || fp.equalsIgnoreCase("prot_operatorio") || fp.equalsIgnoreCase("proc_y_cirugia_ambu") || fp.equalsIgnoreCase("hist_cli_pre_ope") || fp.equalsIgnoreCase("recuperacion_anes_sop") || fp.equalsIgnoreCase("HC") || fp.equalsIgnoreCase("eval_preanestesia") || fp.equalsIgnoreCase("exp_verif_cuidad_pre_oper"))
	{
		sql = "SELECT codigo, decode(observacion , null , descripcion,observacion) as descripcion FROM tbl_cds_procedimiento where estado = 'A'  "+appendFilter+" order by 1";
al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	
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
  
  String jsContext = "window.opener.";
  if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";

%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Listado de Procedimientos - '+document.title;

function returnValue(i)
{ 
  	var code = eval('document.listProceso.codigo'+i).value;
	var name = eval('document.listProceso.descripcion'+i).value; 
	
 	<%if(fp.equalsIgnoreCase("exp_hospitalizacion_cirugia")){%>
	     eval('window.opener.document.form0.codRegistro<%=index%>').value = code;
         eval('window.opener.document.form0.descRegistro<%=index%>').value = name;
		 window.close();
	<%}else if (fp.equalsIgnoreCase("exp_recuperacion_anestesia")){%>
		eval('window.opener.document.form0.procedimiento').value = code;
    	eval('window.opener.document.form0.desProc').value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("convenio_beneficio")){%>	
		eval('window.opener.document.form1.codigo<%=index%>').value = code;
    	eval('window.opener.document.form1.descDiagnostico<%=index%>').value = name;
		window.close();
	<%} else if (fp.equalsIgnoreCase("convenio_beneficio_new")){%>
		<%=jsContext%>document.getElementById("codigo_detalle<%=index%>").value = code;
    	<%=jsContext%>document.getElementById("desc_detalle<%=index%>").value = name;
	<%}else if (fp.equalsIgnoreCase("prot_operatorio")){%>	
		eval('window.opener.document.form0.codProc').value = code;
    	eval('window.opener.document.form0.descProc').value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("proc_y_cirugia_ambu")){%>	
		if(window.opener.document.form0.procedimiento) window.opener.document.form0.procedimiento.value = code;
    	 if(window.opener.document.form0.desc_proc) window.opener.document.form0.desc_proc.value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("hist_cli_pre_ope")){%>	
		if(window.opener.document.form0.procedimiento) window.opener.document.form0.procedimiento.value = code;
    	 if(window.opener.document.form0.desc_proc) window.opener.document.form0.desc_proc.value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("recuperacion_anes_sop")){%>	
		if(window.opener.document.form0.procedimiento) window.opener.document.form0.procedimiento.value = code;
    	 if(window.opener.document.form0.desc_proc) window.opener.document.form0.desc_proc.value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("HC")){%>	
		if(window.opener.document.form0.codRegistro<%=index%>) window.opener.document.form0.codRegistro<%=index%>.value = code;
    	 if(window.opener.document.form0.descRegistro<%=index%>) window.opener.document.form0.descRegistro<%=index%>.value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("eval_preanestesia")){%>	
		if(window.opener.document.form0.procedimiento) window.opener.document.form0.procedimiento.value = code;
    	if(window.opener.document.form0.nombre_procedimiento) window.opener.document.form0.nombre_procedimiento.value = name;
		window.close();
	<%}else if (fp.equalsIgnoreCase("exp_verif_cuidad_pre_oper")){%>	
		if(window.opener.document.form0.cirugia) window.opener.document.form0.cirugia.value = code;
    	if(window.opener.document.form0.desc_cirugia) window.opener.document.form0.desc_cirugia.value = name;
		window.close();
	<%}%>  
    
    <%if(context.equalsIgnoreCase("preventPopupFrame")){%>
       <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
    <%}else{%>
       window.close();
    <%}%>
}

function doAction(){<% if(context.equalsIgnoreCase("preventPopupFrame")) { if (al.size()==1){%> returnValue(0); <%}}%>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="LISTADO DE PROCEDIMIENTOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">	                    
					<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				  <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				  <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>				
					<%=fb.hidden("fp",fp)%>
				    <td width="50%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel>					
					<%=fb.textBox("code","",false,false,false,40)%>
					</td>
				    <td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("name","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("filter",filter)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("name",""+name)%>
				<%=fb.hidden("code",""+code)%>
				<%=fb.hidden("context",context)%>
				
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("name",""+name)%>
					<%=fb.hidden("code",""+code)%>
                    <%=fb.hidden("context",context)%>
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
			<%fb = new FormBean("listProceso",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
            <%=fb.formStart(true)%>
				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="25%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="70%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="text-decoration:none; cursor:pointer">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>				
				</tr>
				<%
				}
				%>	
			<%=fb.formEnd(true)%>						
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("filter",filter)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("name",""+name)%>
				<%=fb.hidden("code",""+code)%>
                <%=fb.hidden("context",context)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("name",""+name)%>
					<%=fb.hidden("code",""+code)%>
                    <%=fb.hidden("context",context)%>
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
}else
{

if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&index="+request.getParameter("index")+"&filter="+request.getParameter("filter")+"&id="+request.getParameter("id")+"&name="+request.getParameter("name")+"&code="+request.getParameter("code")+"&context="+request.getParameter("context"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&index="+request.getParameter("index")+"&filter="+request.getParameter("filter")+"&id="+request.getParameter("id")+"&name="+request.getParameter("name")+"&code="+request.getParameter("code")+"&context="+request.getParameter("context"));
		return;
	}




}%>