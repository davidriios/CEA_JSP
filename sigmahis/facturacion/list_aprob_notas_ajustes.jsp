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
String fp = request.getParameter("fp");
int iconHeight = 20;
int iconWidth = 20;

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
	
	// variable para mantener el valor de los campos filtrados en la consulta
	String codigo  = "",descrip = "",fecha="",factura="",tipo ="";

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))  
  {
    appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");
  }
  /*if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))  
  {
    appendFilter += " and upper(a.explicacion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip    = request.getParameter("descripcion");   
  }*/
  if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))  
  {
    appendFilter += " and trunc(a.fecha) = to_date('"+request.getParameter("fecha")+"','dd/mm/yyyy')";
	fecha    = request.getParameter("fecha");   
  }
  if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals(""))  
  {
    appendFilter += " and upper(a.factura) like '%"+request.getParameter("factura").toUpperCase()+"%'";
	factura    = request.getParameter("factura");   
  }
  if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals(""))  
  {
    appendFilter += " and a.tipo_transaccion ='"+request.getParameter("tipo")+"'";
	tipo    = request.getParameter("tipo");   
  }
	
	
	
  
if(request.getParameter("tipo") != null)
{
  sql = "SELECT a.COMPANIA, a.CODIGO, a.EXPLICACION,to_char(a.fecha,'dd/mm/yyyy')as fecha,decode(a.TIPO_DOC,'F', 'FACTURA', 'R','RECIBO') as TIPO_DOC,a.TIPO_AJUSTE, a.RECIBO, nvl(a.TOTAL,0)total,nvl(a.factura,' ')factura, b.descripcion,a.tipo_transaccion, a.tipo ,f.pac_id pacId, f.admi_secuencia noAdmision ,a.status FROM tbl_con_adjustment a, tbl_fac_tipo_ajuste b,tbl_fac_factura f where  a.tipo_ajuste=b.codigo and b.compania=a.compania and f.codigo = a.factura and f.compania=f.compania and f.compania ="+ (String) session.getAttribute("_companyId")+"  "+appendFilter+" order by a.codigo desc";
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Listado de Notas de Ajustes- '+document.title;

function add()
{
	abrir_ventana('../facturacion/notas_ajustes_config.jsp');
}
function edit(k,mode,fg)
{
		var factura = eval('document.form0.factura'+k).value ;
		var id = eval('document.form0.codigo'+k).value ;
		var compania = eval('document.form0.compania'+k).value ;
		var tipoTransaccion = eval('document.form0.tipoTransaccion'+k).value ;
		var tipo = eval('document.form0.tipo'+k).value ;
		var pacId = eval('document.form0.pacId'+k).value ;
		var noAdmision = eval('document.form0.noAdmision'+k).value ;
		
		abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode='+mode+'&codigo='+id+'&compania='+compania+'&nt='+tipoTransaccion+'&fg='+tipo+'&pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&tr='+fg);
}
function printList()
{
	abrir_ventana('../facturacion/print_list_notas_ajustes_cargo.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function imprimirNota(id,compania,data_ref)
{
		if(data_ref =='O')
		abrir_ventana1('../facturacion/print_nota_ajuste.jsp?compania='+compania+'&codigo='+id);
		else abrir_ventana1('../facturacion/print_nota_ajuste.jsp?fg=ajust&compania='+compania+'&codigo='+id);		
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="NOTAS DE AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="1" cellspacing="0">
<tr>
<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<tr class="TextFilter">
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>

<td width="20%">C&oacute;digo: <%=fb.intBox("codigo",codigo,false,false,false,15,10,null,null,null)%> </td>
<td width="20%">Factura: <%=fb.textBox("factura","",false,false,false,20,12,null,null,null)%></td>	
<td width="30%">Fecha:		<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="fecha" />
									<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
								</jsp:include></td>
<td width="30%">Tipo <%=fb.select("tipo","C= AJUSTE A CARGO,D=AJUSTE DEVOLUCION,H=AJUSTE A HONORARIOS",tipo,false,false,0,"S")%>
<%=fb.submit("go","Ir")%></td>

<%=fb.formEnd()%>
</tr>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
	
		  <authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
       
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("fecha",fecha)%>
					<%=fb.hidden("tipo",tipo)%>
					
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("fecha",fecha)%>
					<%=fb.hidden("tipo",tipo)%>
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
	
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr class="TextHeader">
<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
<td width="9%"><cellbytelabel>Fecha</cellbytelabel></td>
<td width="9%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
<td width="10%"><cellbytelabel>Factura</cellbytelabel></td>
<td width="8%"><cellbytelabel>Recibo</cellbytelabel></td>
<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
<td width="8%"><cellbytelabel>Monto</cellbytelabel></td>
<td width="5%">&nbsp;</td>
<td width="6%">&nbsp;</td>
<td width="7%">&nbsp;</td>
<td width="6%">&nbsp;</td>

</tr>	
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
<%=fb.hidden("factura"+i,cdo.getColValue("factura"))%>

<%=fb.hidden("tipoTransaccion"+i,cdo.getColValue("tipo_transaccion"))%>
<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
<%=fb.hidden("pacId"+i,cdo.getColValue("pacId"))%>
<%=fb.hidden("noAdmision"+i,cdo.getColValue("noAdmision"))%>

<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td align="center"><%=cdo.getColValue("codigo")%></td>
<td><%=cdo.getColValue("fecha")%></td>		
<td><%=cdo.getColValue("tipo_doc")%></td>
		
<td><%=cdo.getColValue("factura")%></td>
<td><%=cdo.getColValue("recibo")%></td>
<td><%=cdo.getColValue("descripcion")%></td>

<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total"))%></td>
<td align="center">
<authtype type='1'><a href="javascript:edit(<%=i%>,'view','CS')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype>

</td>
<td align="center"><%if(cdo.getColValue("status")!=null && !cdo.getColValue("status").trim().equals("") &&(cdo.getColValue("status").trim().equals("O"))){%>
<authtype type='4'><a href="javascript:edit(<%=i%>,'edit','ED')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype><%}%>

</td>
<td align="center">
<%if(cdo.getColValue("status")!=null && !cdo.getColValue("status").trim().equals("") &&(cdo.getColValue("status").trim().equals("C"))){%>
<authtype type='6'><a href="javascript:edit(<%=i%>,'edit','AP')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">
<cellbytelabel>Aprob</cellbytelabel>.</a></authtype><%}%></td>
<td align="center">
<%if(cdo.getColValue("status")!=null && !cdo.getColValue("status").trim().equals("") &&(cdo.getColValue("status").trim().equals("A"))){%>
<!--<authtype type='7'><a href="javascript:edit(<%=i%>,'edit','AN')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Anular</a></authtype>---><%}%>
<authtype type='2'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:imprimirNota('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("compania")%>','<%=cdo.getColValue("data_refer")%>')"></authtype>

</td>

</tr>
<% } %>	

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
					<%=fb.hidden("fp",fp)%>			
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("fecha",fecha)%>
					<%=fb.hidden("tipo",tipo)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("fecha",fecha)%>
					<%=fb.hidden("tipo",tipo)%>
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