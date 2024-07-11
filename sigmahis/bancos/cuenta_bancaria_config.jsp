<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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
String sql = "";
String mode = request.getParameter("mode");
String cuentaCode = request.getParameter("cuentaCode");
String bancoCode = request.getParameter("bancoCode");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		fechaCrea = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userCrea = UserDet.getUserEmpId();
		cdo.addColValue("fechaApert",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("fechaCierre","");
		cdo.addColValue("fechaTransaccion","");
	}
	else
	{
		if (cuentaCode == null) throw new Exception("La Cuenta Bancaria no es válida. Por favor intente nuevamente!");


		fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userMod = UserDet.getUserEmpId();

		sql = "SELECT a.cuenta_banco as cuentaCode, a.cod_banco as bancoCode, c.nombre as banco, a.cg_1_cta1 as cta1, a.cg_1_cta2 as cta2, a.cg_1_cta3 as cta3, a.cg_1_cta4 as cta4, a.cg_1_cta5 as cta5, a.cg_1_cta6 as cta6, a.descripcion as descripcion, a.tipo_cuenta as tipoCuenta,  decode(a.f_apertura,null,' ',to_char(a.f_apertura,'dd/mm/yyyy')) as fechaApert, a.estado_cuenta as estadoCuenta, decode(a.f_cierre,null,' ',to_char(a.f_cierre,'dd/mm/yyyy')) as fechaCierre, decode(a.F_TRANSACCION,null,' ', to_char(a.F_TRANSACCION,'dd/mm/yyyy')) as fechaTransaccion, a.saldo_libro as saldoLibro, a.saldo_banco as saldoBanco, a.saldo_inicio_mes as saldoIniMes, a.tot_debito as totalDeb, a.tot_credito as totalCre, a.tot_depositos as totalDep, a.tot_anulado as totalAnul, a.tot_girado as totalGira, a.tot_pagado as totalPag, a.ultimo_cheque as ultCheque,   a.nuevo_saldo_banco as nuevoSaldoBanco, b.descripcion as ctaFinanciera, a.formato,a.rec_dep_caja,a.trx_comision,a.trx_itbms,a.trx_dev,a.dep_tarjeta from tbl_con_cuenta_bancaria a, tbl_con_catalogo_gral b, tbl_con_banco c WHERE a.compania = c.compania and a.cod_banco = c.cod_banco and a.cg_1_cta1=b.cta1    and a.cg_1_cta2=b.cta2(+) and a.cg_1_cta3=b.cta3  and a.cg_1_cta4=b.cta4 and a.cg_1_cta5=b.cta5 and a.cg_1_cta6=b.cta6 and a.compania=b.compania and a.cuenta_banco='"+cuentaCode+"' and a.cod_banco='"+bancoCode+"' and a.compania="+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}
	CommonDataObject cdoParam = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'BAN_DEBITO_ES_CREDITO'),'N') as deb_es_cr from dual");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title=" Cuenta Bancaria - "+document.title;
function getCuentaBanco()
{
	abrir_ventana('../bancos/ctabancaria_banco_list.jsp');
}
function getCatalogo()
{
	abrir_ventana('../contabilidad/ctabancaria_catalogo_list.jsp?id=1');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
<table id="tbl_generales" width="100%" cellpadding="0" border="0" cellspacing="1" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("userCrea",userCrea)%>
<%=fb.hidden("userMod",userMod)%>
<%=fb.hidden("fechaCrea",fechaCrea)%>
<%=fb.hidden("fechaMod",fechaMod)%>

	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<td align="left" width="100%" onClick="javascript:showHide(0)">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="97%" >&nbsp;Generales de la Cuenta Bancaria</td>
								<td width="3%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel0" style="visibility:visible;">
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td>Banco</td>
								<td colspan="3">
								<%=fb.textBox("bancoCode",cdo.getColValue("bancoCode"),true,false,true,15)%>
								<%=fb.textBox("banco",cdo.getColValue("banco"),true,false,true,34)%>
								<%=fb.button("btnbanco","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:getCuentaBanco()\"")%></td>
							</tr>
							<tr class="TextRow01">
								<td width="15%">Cuenta de Banco</td>
								<td width="37%"><%=fb.textBox("cuentaCode",cdo.getColValue("cuentaCode"),true,false,(mode.equalsIgnoreCase("add")?false:true),45,30)%></td>
								<td width="18%">Descripci&oacute;n</td>
								<td width="30%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,40)%></td>
							</tr>
							<tr class="TextRow01">
								<td>Cuenta Financiera</td>
								<td colspan="3"><%=fb.textBox("cuenta1",cdo.getColValue("cta1"),true,false,true,2)%><%=fb.textBox("cuenta2",cdo.getColValue("cta2"),true,false,true,2)%><%=fb.textBox("cuenta3",cdo.getColValue("cta3"),true,false,true,2)%><%=fb.textBox("cuenta4",cdo.getColValue("cta4"),true,false,true,2)%><%=fb.textBox("cuenta5",cdo.getColValue("cta5"),true,false,true,2)%><%=fb.textBox("cuenta6",cdo.getColValue("cta6"),true,false,true,2)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.textBox("ctaFinanciera",cdo.getColValue("ctaFinanciera"),true,false,true,60)%><%=fb.button("btncuenta","...",true,false,null,null,"onClick=\"javascript:getCatalogo()\"")%></td>
							</tr>
							<tr class="TextRow01">
								<td>Tipo de Cuenta</td>
								<td><%=fb.select("tipoCuenta","CC=CUENTA CORRIENTE,PF=PLAZO FIJO,CA=CUENTA DE AHORRO",cdo.getColValue("tipoCuenta"))%></td>
								<td>Estado de Cuenta</td>
								<td><%=fb.select("estadoCuenta","ACT=ACTIVO,INA=INACTIVO,CER=CERRADA",cdo.getColValue("estadoCuenta"))%>
								&nbsp;Recibe Dep. Caja<%=fb.select("rec_dep_caja","S=SI,N=NO",cdo.getColValue("rec_dep_caja"))%>
								</td>
							</tr>

							<tr class="TextRow01">
								<td>Fecha de Apertura</td>
								<td>
										<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="nameOfTBox1" value="fechaApert"/>
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaApert")%>"/>
									</jsp:include>
								</td>
								<td>Fecha de Cierre</td>
								<td>
										<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="nameOfTBox1" value="fechaCierre"/>
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCierre")%>"/>
									</jsp:include>
								</td>
							</tr>
							<tr class="TextRow01">
								<td>No. &Uacute;ltimo Cheque</td>
								<td>
									<%=fb.intBox("ultCheque",cdo.getColValue("ultCheque"),false,false,false,11,11)%>
									Formato
									<%=fb.select("formato","L=PERSONALIZADO,X=ANSI X9.7",cdo.getColValue("formato"))%></td>   
								<td>Fecha de Transacci&oacute;n</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="nameOfTBox1" value="fechaTransaccion"/>
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaTransaccion")%>"/>
									</jsp:include></td>
							</tr>
							<tr class="TextRow01">
							<td>Tipo de Nota Credito Comisiones</td>
							<td colspan="2"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo from tbl_con_tipo_nota_cr_db where tipo_mov ="+((cdoParam.getColValue("deb_es_cr").trim().equals("S"))?"'DB'":"'CR'")+" and compania="+(String) session.getAttribute("_companyId")+" order by descripcion", "trx_comision", cdo.getColValue("trx_comision"), false,false, 0, "Text10", null, "", "", "S")%>
							</td>
							<td>&nbsp;</td>
							</tr>
							<tr class="TextRow01">
							<td>Tipo de Nota Credito ITBMS Comisiones</td>
							<td colspan="2"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo from tbl_con_tipo_nota_cr_db where tipo_mov = "+((cdoParam.getColValue("deb_es_cr").trim().equals("S"))?"'DB'":"'CR'")+" and compania="+(String) session.getAttribute("_companyId")+" order by descripcion", "trx_itbms", cdo.getColValue("trx_itbms"), false,false, 0, "Text10", null, "", "", "S")%>
							</td>
							<td>&nbsp;</td>
							</tr>
							<tr class="TextRow01">
							<td>Tipo de Nota Credito Dev. Tarj.</td>
							<td colspan="2"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo from tbl_con_tipo_nota_cr_db where tipo_mov = "+((cdoParam.getColValue("deb_es_cr").trim().equals("S"))?"'DB'":"'CR'")+" and compania="+(String) session.getAttribute("_companyId")+" order by descripcion", "trx_dev", cdo.getColValue("trx_dev"), false,false, 0, "Text10", null, "", "", "S")%>
							</td>
							<td>&nbsp;</td>
							</tr>
							<tr class="TextRow01">
							<td>Cuenta acepta Depositos de Tarjetas</td>
							<td colspan="2"><%=fb.select("dep_tarjeta","N=NO,S=SI",cdo.getColValue("dep_tarjeta"))%>
							</td>
							<td>&nbsp;</td>
							</tr>
							
						</table>
					</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<td id="TDetalle" align="left" width="100%" onClick="javascript:showHide(1)">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="97%">Detalles de la Cuenta Bancarias</td>
								<td width="3%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel1" style="display:'';">
						<table width="100%" cellpadding="1" cellspacing="1">
							 <tr class="TextRow01">
								 <td colspan="2">Libro</td>
								 <td colspan="2">Banco</td>
							 </tr>
									 <tr class="TextRow01">
								 <td width="15%">Saldo Inicio Mes</td>
								 <td width="37%"><%=fb.decBox("saldoIniMes",cdo.getColValue("saldoIniMes"),false, false, (!mode.trim().equals("add")), 45)%></td>
								 <td width="15%">Saldo Inicio Mes</td>
								 <td width="33%"><%=fb.decBox("nuevoSaldoBanco",cdo.getColValue("nuevoSaldoBanco"),false, false, (!mode.trim().equals("add")), 40)%></td>
							 </tr>
							 <tr class="TextRow01">
								 <td>Saldo Actual</td>
								 <td><%=fb.decBox("saldoLibro",cdo.getColValue("saldoLibro"),true, false, (!mode.trim().equals("add")), 45)%></td>
								 <td>Saldo Fin Mes</td>
								 <td><%=fb.decBox("saldoBanco",cdo.getColValue("saldoBanco"),false, false, (!mode.trim().equals("add")), 40)%></td>
							 </tr>
							 <tr class="TextRow01">
								 <td>Total D&eacute;bito</td>
								 <td><%=fb.decBox("totalDeb",cdo.getColValue("totalDeb"),false, false, (!mode.trim().equals("add")), 45)%></td>
								 <td>Total Cr&eacute;dito</td>
								 <td><%=fb.decBox("totalCre",cdo.getColValue("totalCre"),false, false, (!mode.trim().equals("add")), 40)%></td>
							 </tr>
							 <tr class="TextRow01">
								 <td>Total Girado</td>
								 <td><%=fb.decBox("totalGira",cdo.getColValue("totalGira"),false, false, (!mode.trim().equals("add")), 45)%></td>
								 <td>Total Dep&oacute;sito</td>
								 <td><%=fb.decBox("totalDep",cdo.getColValue("totalDep"),false, false, (!mode.trim().equals("add")), 40)%></td>
							 </tr>
							 <tr class="TextRow01">
								 <td>Total Pagado</td>
								 <td><%=fb.decBox("totalPag",cdo.getColValue("totalPag"),false, false, (!mode.trim().equals("add")), 45)%></td>
								 <td>Total Anulado</td>
								 <td><%=fb.decBox("totalAnul",cdo.getColValue("totalAnul"),false, false, (!mode.trim().equals("add")), 40)%></td>
							 </tr>
						 </table>
					</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<jsp:include page="../common/bitacora.jsp" flush="true">
			<jsp:param name="audTable" value="tbl_con_cuenta_bancaria"></jsp:param>
			<jsp:param name="audFilter" value="<%="cuenta_banco='"+cuentaCode+"' and cod_banco="+bancoCode+" and compania="+(String) session.getAttribute("_companyId")%>"></jsp:param>
			</jsp:include>
		</td>
	</tr>
	<tr class="TextRow02">
			<td align="right">
		Opciones de Guardar:
		<%=fb.radio("saveOption","N")%>Crear Otro
		<%=fb.radio("saveOption","O")%>Mantener Abierto
		<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
		<%=fb.submit("save","Guardar",true,false)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	cuentaCode = request.getParameter("cuentaCode");
	bancoCode = request.getParameter("bancoCode");
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_con_cuenta_bancaria");
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("cg_1_cta1",request.getParameter("cuenta1"));
	cdo.addColValue("cg_1_cta2",request.getParameter("cuenta2"));
	cdo.addColValue("cg_1_cta3",request.getParameter("cuenta3"));
	cdo.addColValue("cg_1_cta4",request.getParameter("cuenta4"));
	cdo.addColValue("cg_1_cta5",request.getParameter("cuenta5"));
	cdo.addColValue("cg_1_cta6",request.getParameter("cuenta6"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("tipo_cuenta",request.getParameter("tipoCuenta"));
	if (request.getParameter("fechaApert") != null && !request.getParameter("fechaApert").trim().equals("")) cdo.addColValue("f_apertura",request.getParameter("fechaApert"));
	cdo.addColValue("estado_cuenta",request.getParameter("estadoCuenta"));
	if (request.getParameter("fechaCierre") != null && !request.getParameter("fechaCierre").trim().equals("")) cdo.addColValue("f_cierre",request.getParameter("fechaCierre"));
	cdo.addColValue("saldo_libro",request.getParameter("saldoLibro"));
	if(request.getParameter("fechaTransaccion") != null && !request.getParameter("fechaTransaccion").trim().equals("")) cdo.addColValue("F_TRANSACCION",request.getParameter("fechaTransaccion"));
	cdo.addColValue("saldo_banco",request.getParameter("saldoBanco"));
	cdo.addColValue("saldo_inicio_mes",request.getParameter("saldoIniMes"));
	cdo.addColValue("tot_debito",request.getParameter("totalDeb"));
	cdo.addColValue("tot_credito",request.getParameter("totalCre"));
	cdo.addColValue("tot_depositos",request.getParameter("totalDep"));
	cdo.addColValue("tot_anulado",request.getParameter("totalAnul"));
	cdo.addColValue("tot_girado",request.getParameter("totalGira"));
	cdo.addColValue("tot_pagado",request.getParameter("totalPag"));
	cdo.addColValue("ultimo_cheque",request.getParameter("ultCheque"));
	cdo.addColValue("nuevo_saldo_banco",request.getParameter("nuevoSaldoBanco"));
	cdo.addColValue("usuario_creacion",request.getParameter("userCrea"));
	cdo.addColValue("usuario_modificacion",request.getParameter("userMod"));
	cdo.addColValue("fecha_creacion",request.getParameter("fechaCrea"));
	cdo.addColValue("fecha_modificacion",request.getParameter("fechaMod"));

	cdo.addColValue("formato",request.getParameter("formato"));
	cdo.addColValue("rec_dep_caja",request.getParameter("rec_dep_caja"));
	cdo.addColValue("trx_comision",request.getParameter("trx_comision"));
	cdo.addColValue("trx_itbms",request.getParameter("trx_itbms")); 
	cdo.addColValue("trx_dev",request.getParameter("trx_dev")); 
	cdo.addColValue("dep_tarjeta",request.getParameter("dep_tarjeta")); 
	
	cdo.setCreateXML(true);
	cdo.setFileName("cuentaBanco.xml");
	cdo.setOptValueColumn("cuenta_banco");
	cdo.setOptLabelColumn("cuenta_banco|| ' - ' || descripcion");
	cdo.setKeyColumn("cod_banco||'-'||compania");
	cdo.setXmlWhereClause("");

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		 cdo.addColValue("cuenta_banco",request.getParameter("cuentaCode"));
		 cdo.addColValue("cod_banco",request.getParameter("bancoCode"));
		 SQLMgr.insert(cdo);
	}
	else
	{
		 cdo.setWhereClause("cuenta_banco='"+request.getParameter("cuentaCode")+"' and cod_banco='"+request.getParameter("bancoCode")+"' and compania="+(String) session.getAttribute("_companyId"));

		 SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../build/web/js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/cuenta_bancaria_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/cuenta_bancaria_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/cuenta_bancaria_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&cuentaCode=<%=cuentaCode%>&bancoCode=<%=bancoCode%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>