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
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
900017	VER LISTA DE CUENTAS BANCARIAS
900018	IMPRIMIR LISTA DE CUENTAS BANCARIAS
900019	AGREGAR CUENTA BANCARIA
900020	MODIFICAR CUENTA BANCARIA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900017") || SecMgr.checkAccess(session.getId(),"900018") || SecMgr.checkAccess(session.getId(),"900019") || SecMgr.checkAccess(session.getId(),"900020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

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
	
	String cuentaCode  = "";  // variables para mantener el valor de los campos filtrados en la consulta
	String descripcion     = "";
	String banco       = "";

  if (request.getParameter("cuentaCode") != null && !request.getParameter("cuentaCode").trim().equals(""))
  {
	appendFilter += " and upper(a.cuenta_banco) like '%"+request.getParameter("cuentaCode").toUpperCase()+"%'";
		cuentaCode = request.getParameter("cuentaCode"); // utilizada para mantener la cuenta por la cual se filtr�
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion    = request.getParameter("descripcion"); // utilizada para mantener la descripcion de la cuenta por la que se filtr�
  }
  if (request.getParameter("banco") != null && !request.getParameter("banco").trim().equals(""))
  {
    appendFilter += " and upper(b.nombre) like '%"+request.getParameter("banco").toUpperCase()+"%'";
		banco      = request.getParameter("banco"); // utilizada para mantener el nombre del banco por el que se filtr�
  }
 

  sql = "SELECT a.cuenta_banco as cuentaCode, a.descripcion, a.cod_banco as bancoCode, b.nombre as banco, a.compania,decode(a.estado_cuenta,'ACT','ACTIVO','INA','INACTIVO','CER','CERRADA',a.estado_cuenta) as estadoDesc FROM tbl_con_cuenta_bancaria a, tbl_con_banco b WHERE a.cod_banco = b.cod_banco and a.compania = b.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.descripcion";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_con_cuenta_bancaria a, tbl_con_banco b WHERE a.cod_banco = b.cod_banco and a.compania = b.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);

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
document.title = 'Cuenta Principal - '+document.title;

function add(){abrir_ventana('../bancos/cuenta_bancaria_config.jsp');}
function edit(cuentaCode, bancoCode){abrir_ventana('../bancos/cuenta_bancaria_config.jsp?mode=edit&cuentaCode='+cuentaCode+'&bancoCode='+bancoCode);}
function printList(){abrir_ventana('../bancos/print_list_cta_bancaria.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
    <tr>
        <td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Cuenta ]</a></authtype></td>
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
				    <td width="30%">C&oacute;d. Cuenta
							<%=fb.textBox("cuentaCode",cuentaCode,false,false,false,25)%>
						</td>
				  	<td width="35%">Descripci&oacute;n
							<%=fb.textBox("descripcion",descripcion,false,false,false,35)%>
						</td>
				    <td width="35%">Banco
					<%=fb.textBox("banco",banco,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
    </tr>
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
				<%=fb.hidden("cuentaCode",cuentaCode)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("banco",banco)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("cuentaCode",cuentaCode)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("banco",banco)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="20%">Cuenta del Banco</td>
					<td width="35%">Descripci&oacute;n</td>
					<td width="28%">Banco</td>
					<td width="10%">Estado</td>
					<td width="08%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("cuentaCode")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td> [ <%=cdo.getColValue("bancoCode")%> ] <%=cdo.getColValue("banco")%></td>
					<td><%=cdo.getColValue("estadoDesc")%></td>

					<td align="center"><authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype></td>
				</tr>
				<%
				}
				%>							
			</table>
		</div>
		</div>	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
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
				<%=fb.hidden("cuentaCode",cuentaCode)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("banco",banco)%>
				
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("cuentaCode",cuentaCode)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("banco",banco)%>
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