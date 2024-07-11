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
==========================================================================================
==========================================================================================
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
String mode = request.getParameter("mode");
String cuenta = request.getParameter("cuenta");
String banco = request.getParameter("banco");
String nombre = request.getParameter("nombre");
String anio = request.getParameter("anio");

String agregar = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cuenta = "0";
		banco = "0";
		nombre ="";		
	}
	else
	{
		if (cuenta == null || banco == null) throw new Exception("El Banco no es válido. Por favor intente nuevamente!");
		
		agregar = "disabled";
		
 	    sql = "SELECT a.banco, nvl(a.monto_retenido,0) monto, decode(a.tipo_movimiento,'DB',nvl(a.monto_retenido,0),0) debito, decode(a.tipo_movimiento,'CR',nvl(a.monto_retenido,0),0) credito, a.revertido, a.aprobado, a.observacion, a.tipo_movimiento lado, a.consecutivo_ag, to_char(a.f_movimiento,'dd/mm/yyyy') fecha, a.num_cheque, a.consecutivo, a.anio, a.tipo_documento, '[ ' ||a.tipo_documento || ' ] ' ||b.descripcion documento, c.saldo_inicial, c.saldo FROM tbl_con_saldo_bancario_f a, tbl_con_sb_tipo_documento b, tbl_con_sb_saldos c WHERE a.tipo_documento = b.tipo_documento and a.cuenta_banco='"+cuenta+"' and a.banco='"+banco+"' and a.banco = c.cod_banco and a.compania = c.compania and a.cuenta_banco = c.cuenta_banco and c.estatus = 'A' and a.compania="+(String) session.getAttribute("_companyId")+" order by a.consecutivo, a.tipo_documento ";
			
	    al = SQLMgr.getDataList(sql); 
	}	
%> 
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Movimiento Bancario - '+document.title;

function add(banco,cuenta,nombre)
{
	abrir_ventana1('../contabilidad/movimiento_bancario_config.jsp?mode=add&banco='+banco+'&cuenta='+cuenta+'&nombre='+nombre);
}

function edit(banco,cuenta,anio,nombre,cons)
{
	abrir_ventana1('../contabilidad/movimiento_bancario_config.jsp?mode=edit&banco='+banco+'&cuenta='+cuenta+'&anio='+anio+'&nombre='+nombre+'&cons='+cons);
}
function printList(banco,cuenta,nombre)
{
	abrir_ventana('../contabilidad/print_list_movimiento_bancario.jsp?banco='+banco+'&cuenta='+cuenta+'&nombre='+nombre);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MOVIMIENTO BANCARIO <%=nombre%>"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
 	<tr>
        <td align="right"><authtype type='0'><a href="javascript:add('<%=banco%>','<%=cuenta%>','<%=nombre%>')" class="Link00">[ Registrar Movimiento ]</a></authtype></td>
    </tr>
 
  <tr class="TextHeader">
  		<td>&nbsp; </td>
    </tr>
 
 	<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
  		<td> BANCO :  <%=nombre%> </td>
    </tr>
 
 	<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
  		<td> CUENTA BANCARIA :  <%=cuenta%> </td>
    </tr>
 
 
  <tr>
   <td align="right"><authtype type='0'><a href="javascript:printList('<%=banco%>','<%=cuenta%>','<%=nombre%>')" class="Link00">[ Imprimir Lista ]</a></authtype></td>
  </tr>
  
  
  
  <tr>
		<td class="TableLeftBorder TableRightBorder">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1"> 
				<tr class="TextHeader">
                    <td width="5%">Cons.</td>
					<td width="5%" align="center">A&ntilde;o</td>
					<td width="25%">Tipo de Documento</td>
					<td width="10%" align="center">Fecha</td>
					<td width="10%" align="right">Débito</td>
					<td width="10%" align="right">Crédito</td>
					<td width="25%" align="center">Observación</td>
					<td width="10%">&nbsp;</td>
				</tr>				
				<%
				double saldoBanco = 0.00;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
                
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
                	<td><%=cdo.getColValue("consecutivo")%></td>
					<td align="center"><%=cdo.getColValue("anio")%></td>
					<td><%=cdo.getColValue("documento")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
					<td><%=cdo.getColValue("observacion")%></td>
					<td align="center">&nbsp;							
					<authtype type='4'><a href="javascript:edit('<%=banco%>','<%=cuenta%>',<%=cdo.getColValue("anio")%>,'<%=nombre%>',<%=cdo.getColValue("consecutivo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
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

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>