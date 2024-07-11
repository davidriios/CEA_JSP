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
String mode = request.getParameter("mode");
String code = request.getParameter("codigo");
String desc = request.getParameter("desc");
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
	
	String codigo  = "";  // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = "";

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");  // utilizada para mantener el código por el cual se filtró
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip    = request.getParameter("descripcion"); // utilizada para mantener la descripción de la categoria de admision
  }

sql= "select a.secuencia, a.tipo_tarjeta usoCode, b.descripcion descCode, a.comision otrosCargos, decode(a.tipo_valor,'P','PORCENTAJE','M','MONETARIO') tipoServ, nvl(a.rango_inicial,'0') cta1, nvl(a.rango_final,'0') cta2 from tbl_cja_comision_tarjetas a, tbl_cja_tipo_tarjeta b where a.tipo_tarjeta(+) = b.codigo and b.codigo = "+code+" order by a.secuencia";

  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  
  rowCount = CmnMgr.getCount("SELECT count(*) from tbl_cja_comision_tarjetas a, tbl_cja_tipo_tarjeta b where a.tipo_tarjeta(+) = b.codigo and b.codigo = "+code+appendFilter);

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
document.title = 'Tipos de Tarjetas -  Comisiones '+document.title;
function add(){	abrir_ventana('../caja/tipo_comision_config.jsp?mode=add&code=<%=codigo%>&desc=<%=IBIZEscapeChars.forURL(desc)%>');}
function edit(code,sec){abrir_ventana('../caja/tipo_comision_config.jsp?mode=edit&desc=<%=IBIZEscapeChars.forURL(desc)%>&code='+code+'&sec='+sec);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNICA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>
	
<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">
        		<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Comisión ]</a></authtype>
	    </td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <td width="100%" align="left">
						&nbsp;Tipos de Tarjetas
					</td>
				</tr>
                
                 <tr class="TextFilter">		
                    <td width="100%" align="left">
						&nbsp;Código : <%=codigo%> &nbsp; &nbsp; <%=desc%>
					</td>
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
		<td class="TableLeftBorder TableRightBorder">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
				    <td width="15%">No.</td>
					<td width="35%">Tipo de Valor</td>
					<td width="10%" align="center">Comisión</td>
					<td width="15%" align="center">Rango Inicial</td>
                    <td width="15%" align="center">Rango Final</td>
                    <td width="10%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="left"><%=cdo.getColValue("secuencia")%></td>
					<td align="left"><%=cdo.getColValue("tipoServ")%></td>        
					<td align="center"><%=cdo.getColValue("otrosCargos")%></td>
                    <% if(cdo.getColValue("secuencia") == null || cdo.getColValue("secuencia") == "") 
					{ %>
                     <td colspan="3">&nbsp;  </td>
                      <% } else { %>
                    <td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cta1"))%></td>
                    <td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cta2"))%></td>					 
					<td align="center">
					<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("usoCode")%>,<%=cdo.getColValue("secuencia")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
                    </td>
                    <% } %>
				</tr>
				<%				
				}
				%>							
			</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
		</td>
	</tr>
</table>			


<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>