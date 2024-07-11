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
<jsp:useBean id="cdoB" scope="page" class="issi.admin.CommonDataObject" />
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

 	    sql = "SELECT cpto_anio anio, fecha_mes as mes, saldo_inicial as saldoIni, tot_debito as debitos, tot_credito as creditos, tot_deposito as depositos, tot_girado as girado, saldo_libro as saldo, saldo_banco as banco, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fcreacion FROM tbl_con_detalle_cuenta WHERE cuenta_banco='"+cuenta+"' and cod_banco='"+banco+"' and cpto_anio = "+anio+" and compania="+(String) session.getAttribute("_companyId")+" order by cpto_anio desc, fecha_mes desc";
	    al = SQLMgr.getDataList(sql);

	   	sql = "select '['||cod_banco||'] -'||nombre nombreBanco from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" and cod_banco="+banco;
	   	cdoB = SQLMgr.getData(sql);

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Saldo Bancario - '+document.title;

function add()
{
	abrir_ventana1('../bancos/saldobancario_cuenta_config.jsp');
}

function edit(banco,cuenta,anio,mes,nombre)
{
	abrir_ventana1('../bancos/saldobancario_cuenta_config.jsp?mode=edit&banco='+banco+'&cuenta='+cuenta+'&anio='+anio+'&mes='+mes+'&nombre='+nombre);
}
function ver(banco,cuenta,anio,mes,nombre)
{
	abrir_ventana1('../bancos/saldobancario_cuenta_config.jsp?mode=view&banco='+banco+'&cuenta='+cuenta+'&anio='+anio+'&mes='+mes+'&nombre='+nombre);
}
function printList(banco,cuenta,anio)
{
	abrir_ventana('../bancos/print_list_saldobancario.jsp?banco='+banco+'&cuenta='+cuenta+'&anio='+anio);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SALDOS BANCARIO <%=nombre%>"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
   <tr>
        <td align="right"><authtype type='0'><a href="javascript:printList('<%=banco%>','<%=cuenta%>',<%=anio%>)" class="Link00">[ Imprimir Lista ]</a></authtype></td>
    </tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="10%">Banco:</td>
					<td width="40%"><%=cdoB.getColValue("nombreBanco")%></td>
					<td width="10%">Cuenta</td>
					<td width="13%"><%=cuenta%></td>
				</tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="5%">A&ntilde;o</td>
					<td width="4%">Mes</td>
					<td width="13%">Saldo Inicial</td>
					<td width="13%">D&eacute;bitos</td>
					<td width="13%">Cr&eacute;ditos</td>
					<td width="13%">Dep&oacute;sitos</td>
					<td width="13%">Ck.Girados</td>
					<td width="13%">Saldo Libro</td>
					<td width="13%">Saldo Banco</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("anio")%></td>
					<td><%=cdo.getColValue("mes")%></td>
					<td><%=cdo.getColValue("saldoIni")%></td>
					<td><%=cdo.getColValue("debitos")%></td>
					<td><%=cdo.getColValue("creditos")%></td>
					<td><%=cdo.getColValue("depositos")%></td>
					<td><%=cdo.getColValue("girado")%></td>
					<td><%=cdo.getColValue("saldo")%></td>
					<td><%=cdo.getColValue("banco")%></td>
					<td align="center">&nbsp;
					<%/*if (i==0){%><authtype type='4'><a href="javascript:edit('<%=banco%>','<%=cuenta%>',<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("mes")%>,'<%=nombre%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype><% } else {*/%><authtype type='1'><a href="javascript:ver('<%=banco%>','<%=cuenta%>',<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("mes")%>,'<%=nombre%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype><%/*}*/%>
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