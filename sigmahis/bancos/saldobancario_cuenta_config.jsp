<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"500042")|| SecMgr.checkAccess(session.getId(),"500043")|| SecMgr.checkAccess(session.getId(),"500044"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String cuenta = request.getParameter("cuenta");
String banco = request.getParameter("banco");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String nombre = request.getParameter("nombre");
String sql="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int mesCont =0;
boolean viewMode = false;

if(anio == null)anio=cDateTime.substring(6,10);
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		mes = "0";
	}
	else
	{
		if (mes == null) throw new Exception("El Saldo Bancario Mensual no es válido. Por favor intente nuevamente!");

		sql = "SELECT  saldo_inicial as saldoIni, tot_debito as debitos, tot_credito as creditos, tot_deposito as depositos, tot_girado as girado, saldo_libro as saldo, saldo_banco as banco, b.nombre descBanco, a.cuenta_banco, a.cpto_anio as anio, a.fecha_mes as mes FROM tbl_con_detalle_cuenta a,tbl_con_banco b WHERE a.cuenta_banco='"+cuenta+"' and a.cod_banco='"+banco+"' and a.cpto_anio="+anio+" and a.compania="+(String) session.getAttribute("_companyId")+" and a.fecha_mes="+mes+" and a.compania = b.compania and a.cod_banco = b.cod_banco";

		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Saldo Bancario Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Saldo Bancario Edición - "+document.title;
<%}%>

function addBanco()
{
  abrir_ventana2('../bancos/saldobank_cta_list.jsp?id=1');
}
function doAction()
{

}
function checkMes()
{
	var banco = document.form1.bancoCode.value;
	var cuenta = document.form1.cuentaCode.value;
	var anio = document.form1.anio.value;

///	var v_mes = getDBData('<%=request.getContextPath()%>','nvl(max(mes),0)+1','tbl_con_sb_saldos','cod_banco = \''+banco+'\' and cuenta_banco = \''+cuenta+'\' and anio = '+anio+' and compania = <%=(String) session.getAttribute("_companyId")%>','');
/*
	if(v_mes ==13)
	{
		alert('Ya están todos los meses completos, verifique...');
		return false;

	}else return true;
*/

}

</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="13%">Banco</td>
				<%=fb.hidden("bancoCode",banco)%>
				<%=fb.hidden("cuentaCode",cuenta)%>
				<td width="39%"><%=fb.textBox("ctaBanco",cdo.getColValue("descBanco"),true,false,true,45)%></td>
				<td width="13%">Cuenta</td>
				<td width="35%"><%=fb.textBox("ctaBanco",cdo.getColValue("cuenta_banco"),true,false,true,45)%></td>
			</tr>
			<tr class="TextRow01">
				<td>A&ntilde;o</td>
				<td><%=fb.decBox("anio",cdo.getColValue("anio"),true,false,false,25)%></td>
				<td>Mes</td>
				<td><%=fb.intBox("mes",cdo.getColValue("mes"),true,false,true,25)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Saldo Inicial</td>
				<td><%=fb.decBox("saldoIni",cdo.getColValue("saldoIni"),false,viewMode,false,25)%></td>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td>D&eacute;bitos</td>
				<td><%=fb.decBox("debitos",cdo.getColValue("debitos"),false,viewMode,false,25)%></td>
				<td>Dep&oacute;sitos</td>
				<td><%=fb.decBox("depositos",cdo.getColValue("depositos"),false,viewMode,false,25)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Cr&eacute;ditos</td>
				<td><%=fb.decBox("creditos",cdo.getColValue("creditos"),false,viewMode,false,25)%></td>
				<td>Cheques Girados</td>
				<td><%=fb.decBox("girados",cdo.getColValue("girados"),false,viewMode,false,25)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Saldo Libro</td>
				<td><%=fb.decBox("saldo",cdo.getColValue("saldo"),false,viewMode,false,25)%></td>
				<td>Saldo Banco</td>
				<td><%=fb.decBox("banco",cdo.getColValue("banco"),false,viewMode,false,25)%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
				 <%//fb.appendJsValidation("\n\tif (!checkMes()) error++;\n");%>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  cuenta = request.getParameter("cuentaCode");
  banco = request.getParameter("bancoCode");
  nombre = request.getParameter("ctaBanco");

  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_detalle_cuenta");
  cdo.addColValue("saldo_inicial",request.getParameter("saldoIni"));
  cdo.addColValue("debitos",request.getParameter("debitos"));
  cdo.addColValue("creditos",request.getParameter("creditos"));
  cdo.addColValue("saldo_banco",request.getParameter("banco"));
  cdo.addColValue("saldo_libro",request.getParameter("saldo"));
  //cdo.addColValue("estatus",request.getParameter("estatus"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion",cDateTime);

  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("cod_banco",banco);
    cdo.addColValue("cuenta_banco",cuenta);
    cdo.addColValue("anio",request.getParameter("anio"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.setAutoIncWhereClause("cuenta_banco='"+cuenta+"' and cod_banco='"+banco+"' and cpto_anio="+request.getParameter("anio")+" and compania="+(String) session.getAttribute("_companyId"));
 	cdo.setAutoIncCol("mes");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("cuenta_banco='"+cuenta+"' and cod_banco='"+banco+"' and cpto_anio="+request.getParameter("anio")+" and compania="+(String) session.getAttribute("_companyId")+" and fecha_mes="+request.getParameter("mes"));
	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/saldobancario_config.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/saldobancario_config.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/saldobancario_config.jsp?mode=view&cuenta=<%=cuenta%>&banco=<%=banco%>&nombre=<%=nombre%>&anio=<%=anio%>&mes=<%=mes%>';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>