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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
int rowCount = 0;
String mode = request.getParameter("mode");
String cuenta = request.getParameter("cuenta");
String banco = request.getParameter("banco");
String mes = request.getParameter("mes");
String cons = request.getParameter("cons");
String anio = request.getParameter("anio");
String nombre = request.getParameter("nombre");
String compania =  (String) session.getAttribute("_companyId");	
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sql = "";
String appendFilter = "";
if (mode == null) mode = "edit";


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
	String cheque = request.getParameter("cheque");
	String beneficiario = request.getParameter("beneficiario");
	// variables para mantener el valor de los campos filtrados en la consulta
	String estado = ""; 

	if (tDate == null) tDate = "";
	if (fDate == null) fDate = "";
	if (banco == null) banco = "";
	if (cuenta == null) cuenta = "";
	 if (banco != "")
	{
	 appendFilter = " and upper(a.cod_banco) = '"+request.getParameter("banco").toUpperCase()+"'";
	 appendFilter += " and upper(a.cuenta_banco) = '"+request.getParameter("cuenta").toUpperCase()+"'";	 
    }
  if (request.getParameter("cheque") != null && !request.getParameter("cheque").trim().equals(""))
  {
     appendFilter += " and upper(a.num_cheque) like '%"+request.getParameter("cheque").toUpperCase()+"%'";
		cheque        = request.getParameter("cheque"); // utilizada para mantener la cuenta por la cual se filtró
  		banco        = request.getParameter("banco");
  		cuenta        = request.getParameter("cuenta");
  
  }
  if (request.getParameter("beneficiario") != null && !request.getParameter("beneficiario").trim().equals(""))
  {
    appendFilter += " and upper(a.beneficiario) like '%"+request.getParameter("beneficiario").toUpperCase()+"%'";
		beneficiario      = request.getParameter("beneficiario"); // utilizada para mantener el banco por el que se filtró
 		banco        = request.getParameter("banco");
  		cuenta        = request.getParameter("cuenta");
  }
	if (!tDate.trim().equals("") && !fDate.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.f_emision,'dd/mm/yyyy'),'dd/mm/yyyy')>=to_date('"+tDate+"','dd/mm/yyyy')";
		appendFilter += " and to_date(to_char(a.f_emision,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date('"+fDate+"','dd/mm/yyyy')";
	}
	else if (!tDate.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.f_emision,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+tDate+"','dd/mm/yyyy')";
	}
  
	

    sql = "SELECT a.beneficiario, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.cod_banco as bancoCode, d.nombre as banco, to_char(a.f_emision,'dd/mm/yyyy')as fecha, to_char(a.f_expiracion,'dd/mm/yyyy')as fechaExpira, to_char(a.f_pago_banco,'dd/mm/yyyy')as fechaPago, a.num_cheque cheque, a.monto_girado monto, decode(a.estado_cheque,'G','Girado','P','Pagado','A','Anulado') estadoCk, a.estado_cheque estado, decode(a.tipo_pago,'1','CHEQUE','2','ACH','3','TRANSF.') tipo_pago FROM tbl_con_cheque a, tbl_con_cuenta_bancaria c, tbl_con_banco d where a.cuenta_banco=c.cuenta_banco and a.cod_banco=c.cod_banco and a.cod_compania=c.compania and a.cod_compania = d.compania and a.cod_banco=d.cod_banco and a.estado_cheque = 'G' and a.cod_compania="+ (String) session.getAttribute("_companyId")+appendFilter+" order by a.cod_banco, a.f_emision, a.beneficiario";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
document.title = 'Movimiento Bancario Cheques - '+document.title;

function add()
{
 abrir_ventana('../bancos/movimientobancario_config.jsp');
}
function edit(tipo,cuenta,banco,fecha,consecutivo)
{
 abrir_ventana('../bancos/movimientobancario_config.jsp?mode=edit&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo);
}
function actualiza(tipo,cuenta,banco,fecha,consecutivo)
{
 abrir_ventana('../bancos/movimientobancario_config.jsp?mode=view&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo);
}
function showList()
{
	abrir_ventana1('../bancos/movimientobancario_config.jsp');
}
function printList()
{
	abrir_ventana('../bancos/print_list_mov_bancario.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function checkAll()
{
	var size = document.form1.keySize.value;

	for (i=0; i<size; i++)
	{
		if (eval('document.form1.check').checked)
		{
			eval('document.form1.check'+i).checked = true;
		}
		else
		{
			eval('document.form1.check'+i).checked = false;
		}
	}
}

function anular(cod_banco, cuenta_banco, num_cheque)
{
	abrir_ventana('../cxp/cheque.jsp?mode=edit&fp=conciliacion&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&num_cheque='+num_cheque);
}

function fechaChk(i)
{
	var fecha = eval('document.form1.fechaPago'+i).value;

		if (eval('document.form1.check'+i).checked)
		{
			if(fecha == '' || fecha == null) 
			{
			alert('Seleccione una Fecha'+fecha);
			 eval('document.form1.check'+i).checked = false;
			 }  
		} 
		
}

function actCheque()
{
var cheque = "";
var banco = "";
var cuenta = "";
var v_fecha = "";
var chk = ""; 
var countCHK = 0;
var user = '<%=userName%>'
var msg = '';
var size = document.form1.keySize.value;
var fechaMod = '<%=cDateTime%>'


for(i=0;i<size;i++){
  fechaChk(i);
		if(eval('document.form1.check'+i).checked)
		{
			v_fecha = eval('document.form1.fechaPago'+i).value;
			banco = eval('document.form1.bancoCode'+i).value;
			cuenta = eval('document.form1.cuentaCode'+i).value;
			cheque = eval('document.form1.cheque'+i).value;
										
		if(executeDB('<%=request.getContextPath()%>','UPDATE tbl_con_cheque SET estado_cheque = \'P\', f_pago_banco =  to_date(\''+v_fecha+'\',\'dd/mm/yyyy\'), fecha_modificacion = to_date(\''+fechaMod+'\',\'dd/mm/yyyy hh12:mi:ss am\'), usuario_modificacion = \''+user+'\' WHERE cod_banco = \''+banco+'\' and cuenta_banco = \''+cuenta+'\' and num_cheque = \''+cheque+'\' and cod_compania = <%=(String) session.getAttribute("_companyId")%>'))
		{
					countCHK++;
					
		
		} else {
		alert('No hay Cheques Seleccionados ... Verifique...!!');
		}
		}
		}
	if(countCHK>0) 
	{
	alert('Cambio Realizado...');
	window.location.reload(true);
	} else 	alert('No hay Seleccionados...Verifique...!');
		
		
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
        <td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">&nbsp;</a></authtype></td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
           		 	<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
                    <%=fb.hidden("banco",banco)%>
                    <%=fb.hidden("cuenta",cuenta)%>
                    <%=fb.hidden("mode",mode)%>
					<td width="30%">Número de Cheque
						<%=fb.textBox("cheque",cheque,false,false,false,15,null,null,null)%>
					</td>
				    <td width="35%">Beneficiario
						<%=fb.textBox("beneficiario",beneficiario,false,false,false,45,null,null,null)%>
					</td>
				  	
					<td width="35%">Fecha
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
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right"><%=fb.button("actualiza","Actualizar",true,false,null,null,"onClick=\"javascript:actCheque()\"")%></td>
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
				<%=fb.hidden("cuenta",cuenta)%>
				<%=fb.hidden("banco",banco)%>
                <%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
			
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
				<%=fb.hidden("cuenta",cuenta)%>
				<%=fb.hidden("banco",banco)%>
                <%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
				
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
            <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
            <%=fb.hidden("keySize",""+al.size())%>
				<tr class="TextHeader">
					<td width="10%" align="center">Num.Cheque</td>
					<td width="25%" align="center">Beneficiario</td>
   					<td width="10%" align="center">Fecha Emisión</td>
					<td width="10%" align="center">Fecha Expiración</td>
                    <td width="05%" align="center">Tipo</td>
					<td width="05%" align="center">Estado</td>
                    <td width="10%" align="right">Monto</td>
    				<td width="10%" align="center">Fecha de Pago</td>
                    
                    <td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los cheques listados!")%></td>
                    <td width="10%" align="center">&nbsp;</td>
				</tr>				
				<%
				String cta = "";
				String bank = "";
				for (int i=0; i<al.size(); i++)
				{
				 cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
                <%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
                <%=fb.hidden("cheque"+i,cdo.getColValue("cheque"))%>
                <%=fb.hidden("beneficiario"+i,cdo.getColValue("beneficiario"))%>
               
                <%=fb.hidden("fechaExpira"+i,cdo.getColValue("fechaExpira"))%>
                <%=fb.hidden("cuentaCode"+i,cdo.getColValue("cuentaCode"))%>
                <%=fb.hidden("bancoCode"+i,cdo.getColValue("bancoCode"))%>
                <%=fb.hidden("consecutivo"+i,cdo.getColValue("consecutivo"))%>
                               
                <%
					if (!bank.equalsIgnoreCase(cdo.getColValue("bancoCode")))
				{
				%>
                <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td colspan="10"> Banco : [ <%=cdo.getColValue("bancoCode")%> ] <%=cdo.getColValue("banco")%>   </td>
                </tr>
                <% }
				%>
                   <%
					if (!cta.equalsIgnoreCase(cdo.getColValue("cuentaCode")))
				{
				%>
                <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td colspan="10">  Cuenta Bancaria   : <%=cdo.getColValue("cuenta")%> </td>
                </tr>
                <% }
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
                	<td><%=cdo.getColValue("cheque")%></td>
					<td><%=cdo.getColValue("beneficiario")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("fechaExpira")%></td>
                    <td align="center"><%=cdo.getColValue("tipo_pago")%></td>
					<td align="center"><%=cdo.getColValue("estado")%></td>
                    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td align="center">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="<%="fechaPago"+i%>" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fechaPago") != null)?cdo.getColValue("fechaPago"):""%>" />
                        <jsp:param name="readonly" value="<%=(!mode.trim().equalsIgnoreCase("edit"))?"y":"n"%>"/>
						</jsp:include>	
					</td>
                   <td align="center">
                    <%=fb.checkbox("check"+i,"S",false, false, "", "", "onClick=\"javascript:fechaChk("+i+")\"")%>
                    </td>
                    <td align="center">
                    <authtype type='4'><a href="javascript:anular('<%=cdo.getColValue("bancoCode")%>', '<%=cdo.getColValue("cuentaCode")%>', '<%=cdo.getColValue("cheque")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Anular</a></authtype>
                    
                    </td>
				</tr>
                
				<%
				bank = cdo.getColValue("bancoCode");
				cta = cdo.getColValue("cuentaCode");
				}
				%>	
            <tr class="TextRow02">
				<td colspan="10" align="right"> 
				<%=fb.button("actualiza","Actualizar",true,false,null,null,"onClick=\"javascript:actCheque()\"")%></td>
			</tr>	
			
            <tr>
				<td colspan="10">&nbsp;</td>
			</tr>
				
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
				<%=fb.hidden("cuenta",cuenta)%>
				<%=fb.hidden("banco",banco)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
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
				<%=fb.hidden("cuenta",cuenta)%>
				<%=fb.hidden("banco",banco)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
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
