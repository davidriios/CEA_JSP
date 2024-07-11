<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList aj = new ArrayList();
int rowCount = 0;
String sql = "";
String compania = (String) session.getAttribute("_companyId"); 
String appendFilter = "";
String appendFilter1 = "";
String appendFilter2 = "";
String appendFilter3 = "";
String cod_honorario = "";
String descripcion = "";
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

  if (request.getParameter("cod_honorario") != null)
  {
    appendFilter += " and upper(a.cod_honorario) like '%"+request.getParameter("cod_honorario").toUpperCase()+"%'";
    searchOn = "a.cod_honorario";
    searchVal = request.getParameter("cod_honorario");
    searchType = "1";
    searchDisp = "Código";
    cod_honorario = request.getParameter("cod_honorario");	
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter1 = " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = " a.tipo = 'C' or b.descripcion ";
    searchVal = request.getParameter("descripcion");
    searchType = "2";
    searchDisp = "Descripción";
    descripcion = request.getParameter("descripcion");	
  }
	else if (request.getParameter("descripcion") != null)
  {
    appendFilter2 = " and upper(c.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = " a.tipo = 'E' or c.nombre  ";
    searchVal = request.getParameter("descripcion");
    searchType = "3";
    searchDisp = "Descripción";
    descripcion = request.getParameter("descripcion");	
  }
	else if (request.getParameter("descripcion") != null)
  {
    appendFilter3 = " and upper(d.primer_nombre||' '||d.primer_apellido) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = " a.tipo = 'M' or d.primer_nombre||' '||d.primer_apellido ";
    searchVal = request.getParameter("descripcion");
    searchType = "4";
    searchDisp = "Descripción";
    descripcion = request.getParameter("descripcion");	
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
	 
	 if (searchType.equals("2"))
   {
     appendFilter1 = " and (upper(b.descripcion)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
   }
	 
	  if (searchType.equals("3"))
   {
    appendFilter2 = " and (upper(c.nombre)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
   }
	   if (searchType.equals("4"))
   {
     appendFilter3 = " and (upper(d.primer_nombre||' '||d.primer_apellido)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
   }
	 
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	sql = "select a.cod_honorario, 'Centro' tipoDesc, a.tipo,  b.descripcion, nvl(a.saldo,0) saldo from tbl_con_saldo_medicos a, tbl_cds_centro_servicio b where a.tipo = 'C' and a.cod_honorario = b.codigo "+appendFilter+appendFilter1;
	sql +=" union ";
  sql += " select a.cod_honorario, 'Empresa' tipoDesc, a.tipo,  c.nombre descripcion, nvl(a.saldo,0) saldo from tbl_con_saldo_medicos a, tbl_adm_empresa c where a.tipo = 'E' and a.cod_honorario = c.codigo "+appendFilter+appendFilter2;
	sql +=" union ";
  sql += " select a.cod_honorario, 'Médico' tipoDesc, a.tipo, d.primer_nombre||' '||d.primer_apellido descripcion, nvl(a.saldo,0) saldo from tbl_con_saldo_medicos a, tbl_adm_medico d where a.tipo = 'M' and a.cod_honorario = d.codigo "+appendFilter+appendFilter3+" order by 2, 4";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	aj=SQLMgr.getDataList(sql);
	
	
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
document.title = 'Actualización de Saldos de Honorarios - '+document.title;

function callProcess()
{
	var size = document.formDigito.size.value;
	var cia = '<%=(String) session.getAttribute("_companyId")%>';
  var cont=0;
	var cod=0;
	var tipo='';
	var saldo=0;
///alert('.......'+size);

	for (i=0; i<size; i++)
		{
			 cod  = eval('document.formDigito.cod_honorario'+i).value;
			 tipo  = eval('document.formDigito.tipo'+i).value;
		   saldo = eval('document.formDigito.saldo'+i).value;	
				if (eval('document.formDigito.saldo'+i).value!=null)	
				{		
					if(executeDB('<%=request.getContextPath()%>','update tbl_con_saldo_medicos set saldo = '+saldo+' where cod_honorario = \''+cod+'\' and tipo = \''+tipo+'\'','tbl_con_saldo_medicos'))
					 {
					 cont++;
				
					 }
				}0	 
		}
		alert('Se Guardó la Actualización de Saldos ....!');
}


function  printList()
{
abrir_ventana('../rhplanilla/print_list_digito.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - MANTENIMIENTO "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
	
		<td colspan="4" align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800059"))
{
%>
		&nbsp;
<%
}
%>
		</td>
	</tr>	
	
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="50%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel> &nbsp;
					<%=fb.textBox("cod_honorario","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>	
		<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="50%">&nbsp;<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>	</td>
		<%=fb.formEnd()%>	
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"> <%=fb.button("Guardar","Guardar",true,false,null,null,"onClick=\"javascript:callProcess()\"")%>
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
	 <% fb = new FormBean("formDigito",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
 		<%=fb.hidden("size",""+al.size())%>

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
		<tr class="TextHeader">
					<td width="5%">&nbsp;</td>
					<td width="15%"><cellbytelabel>Tipo</cellbytelabel></td>
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Saldo</cellbytelabel></td>
					
				</tr>
<%
				
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 %>
				 <%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
				 <%=fb.hidden("cod_honorario"+i,cdo.getColValue("cod_honorario"))%>
				 
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("tipoDesc")%></td>
					<td><%=cdo.getColValue("cod_honorario")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="right"><%=fb.decBox("saldo"+i,CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),false,false,false,20)%></td>
					
				</tr>
				<%
				}
			  %>						
								
</table>	

<!-- =================   R E S U L T S   E N D   H E R E   ====================== -->

	</td>
</tr>
 <%=fb.formEnd()%>
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
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"> <%=fb.button("Guardar","Guardar",true,false,null,null,"onClick=\"javascript:callProcess()\"")%>
		</td>
	</tr>	
</table>	

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}// else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>
