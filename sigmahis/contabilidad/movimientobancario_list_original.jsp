<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
900101	VER LISTA DE MOVIMIENTOS BANCARIOS
900102	IMPRIMIR LISTA DE MOVIMIENTOS BANCARIOS
900103	AGREGAR MOVIMIENTO BANCARIO
900104	MODIFICAR MOVIMIENTO BANCARIO
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
ArrayList alBank = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String key = "";
int lastLineNo = 0;

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
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	String cod_banco  = "", cuenta_banco = ""; // variables para mantener el valor de los campos filtrados en la consulta
	String estado = "", cheque = "", nombre_cuenta = ""; 

	if (tDate == null) tDate = "";
	if (fDate == null) fDate = "";
	if (request.getParameter("estado") != null && !request.getParameter("estado").equals("")) 
  {
		appendFilter = appendFilter+" and a.estado_trans='"+request.getParameter("estado").toUpperCase()+"' ";	
		estado = request.getParameter("estado");	 // utilizada para mantener el estado de la cuenta por la que se filtró		
  } 
  else 
  {
   appendFilter = appendFilter+" and a.estado_trans='T' ";	
   estado = request.getParameter("estado");
  }
  
  	if (request.getParameter("cod_banco") != null && !request.getParameter("cod_banco").equals(""))
  {
    appendFilter += " and upper(a.banco) like '%"+request.getParameter("cod_banco").toUpperCase()+"%'";
//	cod_banco      = request.getParameter("cod_banco"); // utilizada para mantener el banco por el que se filtró
  }
  
	if (request.getParameter("cuenta_banco") != null && !request.getParameter("cuenta_banco").equals(""))
  {
    appendFilter += " and upper(a.cuenta_banco) like '%"+request.getParameter("cuenta_banco").toUpperCase()+"%'";
//	cuenta_banco        = request.getParameter("cuenta_banco"); // utilizada para mantener la cuenta por la cual se filtró
  }
	
		 
 if (!tDate.trim().equals("") && !fDate.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.f_movimiento,'dd/mm/yyyy'),'dd/mm/yyyy')>=to_date('"+tDate+"','dd/mm/yyyy')";
		appendFilter += " and to_date(to_char(a.f_movimiento,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date('"+fDate+"','dd/mm/yyyy')";
	}
	else if (!tDate.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.f_movimiento,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+tDate+"','dd/mm/yyyy')";
	}
  
	if(!appendFilter.trim().equals(""))
	{
  sql = "SELECT a.consecutivo_ag, a.tipo_movimiento as tipoCode, b.descripcion as tipo, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.banco as bancoCode, d.nombre as banco, to_char(a.f_movimiento,'dd/mm/yyyy')as fecha, to_char(a.fecha_pago,'dd/mm/yyyy')as fechaPago, a.consecutivo_ag as consecutivo, a.estado_dep, a.lado, decode(a.estado_trans,'T','Tramitada','C','Conciliada','A','Anulada') as estado FROM tbl_con_movim_bancario a, tbl_con_tipo_movimiento b, tbl_con_cuenta_bancaria c, tbl_con_banco d where a.tipo_movimiento = b.cod_transac and a.cuenta_banco = c.cuenta_banco and a.banco = c.cod_banco and a.compania = c.compania and a.compania = d.compania and a.banco = d.cod_banco and a.compania = "+ (String) session.getAttribute("_companyId")+appendFilter+" order by a.banco, c.descripcion, d.nombre, a.tipo_movimiento";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
  
  
  sql = "SELECT c.cod_banco bancoCode, c.cuenta_banco cuentaCode, d.nombre FROM tbl_con_cuenta_bancaria c, tbl_con_banco d WHERE c.compania = d.compania and c.cod_banco = d.cod_banco and c.compania ="+ (String) session.getAttribute("_companyId")+" order by c.cod_banco";
  alBank = SQLMgr.getDataList("sql");
    HashDet.clear(); 
			lastLineNo = alBank.size();
			for (int i = 1; i <= alBank.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  HashDet.put(key, alBank.get(i-1));			
		    }  	 			
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
document.title = 'Movimiento Bancario - '+document.title;

function add()
{
 abrir_ventana('../contabilidad/movimientobancario_config.jsp');
}
function edit(tipo,cuenta,banco,fecha,consecutivo)
{
 abrir_ventana('../contabilidad/movimientobancario_config.jsp?mode=edit&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo);
}
function editCheque(cuenta,banco)
{
 abrir_ventana('../contabilidad/movimientobancario_cheque_list.jsp?mode=edit&cuenta='+cuenta+'&banco='+banco);
}
function actualiza(tipo,cuenta,banco,fecha,consecutivo)
{
 abrir_ventana('../contabilidad/movimientobancario_config.jsp?mode=view&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo);
}
function showList()
{
var cuenta="";
var banco="";
	abrir_ventana1('../contabilidad/movimientobancario_cheque_list.jsp?mode=edit&cuenta='+cuenta+'&banco='+banco);
}

function selCuentaBancaria(i){
	var cod_banco = eval('document.search01.cod_banco'+i).value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);
}

function printList()
{
	abrir_ventana('../contabilidad/print_list_mov_bancario.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Movimiento Bancario ]</a></authtype></td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
           		 	<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td width="55%">Cuenta
						 <%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" order by nombre","cod_banco",cod_banco,false,false,0, "text10", "", "", "", "T")%>
                Cta.:
                <%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,15,"text10",null,"")%> 
								<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,40,"text10",null,"")%> 
                <%=fb.button("buscarCuenta","...",false, false,"text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
					</td>
				    <td width="45%"> Estado :
						<%=fb.select("estado","T=Tramitada,C=Conciliada,A=Anulada",estado)%>
					&nbsp;&nbsp;
                    Fecha
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="nameOfTBox1" value="tDate" />
						<jsp:param name="valueOfTBox1" value="<%=tDate%>" />
						<jsp:param name="fieldClass" value="Text10" />
						<jsp:param name="buttonClass" value="Text10" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox2" value="fDate" />
						<jsp:param name="valueOfTBox2" value="<%=fDate%>" />
						</jsp:include>
						
						<%=fb.submit("go","Ir")%>
					</td>
                    </tr>
				   <tr class="TextFilter">	
                  
                  	
                   <td colspan="2" align="right">
                        <%=fb.button("btnList","CHEQUES",true,false,null,null,"onClick=\"javascript:showList()\"")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<%	fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp"); %>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
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
					<td width="25%" align="center">Banco</td>
					<td width="25%" align="center">Cuenta</td>
   					<td width="10%" align="center">Tipo</td>
					<td width="10%" align="center">Fecha</td>
					<td width="10%" align="center">Estado</td>
    				<td width="10%">&nbsp;</td>
                    <td width="10%">&nbsp;</td>
				</tr>				
				<%
				String bank="";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
                
                
                 <%
					if (!bank.equalsIgnoreCase(cdo.getColValue("bancoCode")))
				{
				%>
                <tr class="TextRow03" onMouseOver="setoverc(this,'TextRow03')" onMouseOut="setoutc(this,'TextRow03')">
				<td colspan="5"> Banco : [ <%=cdo.getColValue("bancoCode")%> ] <%=cdo.getColValue("banco")%>  Cta : <%=cdo.getColValue("cuenta")%> </td>
                <td colspan="2" align="center">
					<authtype type='4'><a href="javascript:editCheque('<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Actualizar Cheques</a></authtype>
					</td>
                </tr>
                <% }
				%>
                  <%=fb.hidden("estado",cdo.getColValue("estado"))%>         
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("banco")%></td>
					<td><%=cdo.getColValue("cuenta")%></td>
					<td><%=cdo.getColValue("tipo")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("estado")%></td>
					<td align="center">
					<authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
					</td>
                    <td align="center">
                    <% if((cdo.getColValue("estado").equals("Tramitada") && cdo.getColValue("estado_dep").equals("DT")) || (cdo.getColValue("estado").equals("Tramitada") && !cdo.getColValue("tipoCode").equals("1")))
					{
					%>
					<authtype type='4'><a href="javascript:actualiza('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Actualizar</a></authtype>
                    <%
					} else {
					%>
                   &nbsp;
                    <% } %>
					</td>
				</tr>
				<%
				bank = cdo.getColValue("bancoCode");
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
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
