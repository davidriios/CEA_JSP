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
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
String num_cheque = request.getParameter("num_cheque");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String beneficiario = request.getParameter("beneficiario");
String fg = request.getParameter("fg");
String solicitadoPor = request.getParameter("solicitadoPor");

if(cod_banco==null) cod_banco = "";
if(cuenta_banco==null) cuenta_banco = "";
if(nombre_cuenta==null) nombre_cuenta = "";
if(num_cheque==null) num_cheque = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";
if(beneficiario == null) beneficiario = "";
if(fg == null) fg = "";
if(solicitadoPor==null) solicitadoPor = "";

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

	if (request.getParameter("cod_banco") != null && !request.getParameter("cod_banco").equals(""))
  {
    appendFilter += " and upper(a.cod_banco) like '%"+request.getParameter("cod_banco").toUpperCase()+"%'";
  }
  
	if (request.getParameter("cuenta_banco") != null && !request.getParameter("cuenta_banco").equals(""))
  {
    appendFilter += " and upper(a.cuenta_banco) like '%"+request.getParameter("cuenta_banco").toUpperCase()+"%'";
  }
	
	 if (request.getParameter("num_cheque") != null && !request.getParameter("num_cheque").equals(""))
  {
    appendFilter += " and upper(a.num_cheque) like '%"+request.getParameter("num_cheque").toUpperCase()+"%'";
  }

  if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
  {
    appendFilter += " and trunc(a.f_emision) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
	}

  if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
  {
    appendFilter += " and trunc(a.f_emision) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
	}
	 if (request.getParameter("beneficiario") != null && !request.getParameter("beneficiario").equals(""))
  {
    appendFilter += " and upper(a.beneficiario) like '%"+request.getParameter("beneficiario").toUpperCase()+"%'";
  }
  if (!solicitadoPor.trim().equals("")){ 
  appendFilter += " and exists (select null from tbl_cxp_orden_de_pago where anio=a.anio and num_orden_pago=a.num_orden_pago and cod_compania=a.cod_compania and solicitado_por = '"+solicitadoPor+"' ) ";
  }
	if(fg.equals("PM")){appendFilter+=" and a.tipo_orden = 4";}
if (request.getParameter("beneficiario") != null){
  sql = "select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.beneficiario, a.monto_girado, to_char(a.f_emision, 'dd/mm/yyyy') f_emision, a.estado_cheque, decode(a.estado_cheque, 'G', 'Girado') estado_desc, a.anio, a.num_orden_pago, (select nombre from tbl_con_banco where compania = a.cod_compania and cod_banco = a.cod_banco) nombre_banco, c.descripcion nombre_cuenta from tbl_con_cheque a, tbl_con_cuenta_bancaria c where a.cod_compania = c.compania and a.cuenta_banco = c.cuenta_banco and a.estado_cheque = 'G' and a.cod_compania = " + (String) session.getAttribute("_companyId")+appendFilter+" order by f_emision desc";
	System.out.println("sql...\n"+sql);
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
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
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Pagos Otros - '+document.title;

function add()
{
	abrir_ventana('../cxp/.jsp');
}

function anular(cod_banco, cuenta_banco, num_cheque)
{
	abrir_ventana('../cxp/cheque.jsp?mode=anular&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&num_cheque='+num_cheque+'&fg=<%=fg%>&solicitadoPor=<%=solicitadoPor%>');
}

function selCuentaBancaria(i){
	var cod_banco = eval('document.search01.cod_banco'+i).value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);
}

function  printList()
{
abrir_ventana('../cxp/print_list_cheques.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - CHEQUES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">
	    		<!--<authtype type='3'><a href="javascript:add()" class="Link00">[ Registro Nuevo ]</a></authtype>-->
	    	</td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
					<%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("solicitadoPor",solicitadoPor)%>
					
          <td>
                Banco:
								<%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+(String) session.getAttribute("_companyId")+" order by nombre","cod_banco",cod_banco,false,false,0, "text10", "", "", "", "T")%>
                Cta.:
                <%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,20,"text10",null,"")%> 
								<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,40,"text10",null,"")%> 
                <%=fb.button("buscarCuenta","...",false, false,"text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
            </td>
            </tr>
			    <tr class="TextFilter">		
          <td>
                <cellbytelabel>No. Cheque</cellbytelabel>
                <%=fb.textBox("num_cheque",num_cheque,false,false,false,20,"text10",null,"")%> 
                <cellbytelabel>Beneficiario</cellbytelabel>
                <%=fb.textBox("beneficiario",beneficiario,false,false,false,40,"text10",null,"")%> 
                <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha_desde" />
                <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
                <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
              </jsp:include>
						<%=fb.submit("go","Ir")%>		  
            </td>
				    <%=fb.formEnd()%>	   
            </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
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
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("num_cheque",num_cheque)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("solicitadoPor",solicitadoPor)%>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("solicitadoPor",solicitadoPor)%>
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
				<tr class="TextHeader">
					<td width="20%" align="center" colspan="2"><cellbytelabel>Banco</cellbytelabel></td>
          <td width="30%" align="center" colspan="2"><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
					<td width="22%"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Num. Cheque</cellbytelabel></td>
          <td width="6%" align="center"><cellbytelabel>Fecha Emisi&oacute;n</cellbytelabel></td>
					<td width="6%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=cdo.getColValue("cod_banco")%></td>
					<td><%=cdo.getColValue("nombre_banco")%></td>
					<td><%=cdo.getColValue("cuenta_banco")%></td>
					<td><%=cdo.getColValue("nombre_cuenta")%></td>
					<td><%=cdo.getColValue("beneficiario")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado"))%>&nbsp;</td>
          <td align="center"><%=cdo.getColValue("num_cheque")%></td>
          <td align="center"><%=cdo.getColValue("f_emision")%></td>
					<td align="center">
					<authtype type='7'><a href="javascript:anular('<%=cdo.getColValue("cod_banco")%>', '<%=cdo.getColValue("cuenta_banco")%>', '<%=cdo.getColValue("num_cheque")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Anular</cellbytelabel></a></authtype>
					</td>
				</tr>
				<%
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
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("num_cheque",num_cheque)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("solicitadoPor",solicitadoPor)%>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("solicitadoPor",solicitadoPor)%>
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