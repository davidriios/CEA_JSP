<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="INCMgr" scope="page" class="issi.cxc.IncobrablesMgr"/>
<jsp:useBean id="iIncob" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vIncob" scope="session" class="java.util.Vector"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==========================================================================================
fg = FI  --> FACTURAS INCOBRABLES EMPRESA 108
FG = FIS  --> FACTURAS INCOBRABLES PACIENTES
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
INCMgr.setConnection(ConMgr);

int iconHeight = 20;
int iconWidth = 20;
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String fg = request.getParameter("fg");
String mode =  request.getParameter("mode");
String anio = request.getParameter("anio");
String lista = request.getParameter("lista");
String listaReg = request.getParameter("listaReg");
String cDateTime= CmnMgr.getCurrentDate("yyyy");
String change =  request.getParameter("change");
String tipo_ajuste =  request.getParameter("tipo_ajuste");
String aType = request.getParameter("aType");
String aValue = request.getParameter("aValue");

if (fg == null) fg = "";
if (mode == null) mode = "";
if (anio == null ) anio = "";
if (lista == null ) lista = "";
if (tipo_ajuste == null ) tipo_ajuste = "";
if (listaReg == null ) listaReg = "";
if (mode.trim().equals("")) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (change == null) {

		iIncob.clear();
		vIncob.clear();

		if (!lista.equals("") && !lista.equals("0")) {

			sbSql.append("select nvl(a_type,'P') as a_type, decode(a_value,null,' ',''||a_value) as a_value from tbl_cxc_cuentasm where compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and anio = ");
			sbSql.append(anio);
			sbSql.append(" and lista = ");
			sbSql.append(lista);
			sbSql.append(" and rownum = 1");
			CommonDataObject h = SQLMgr.getData(sbSql.toString());
			aType = h.getColValue("a_type");
			aValue = h.getColValue("a_value");

			//sbSql.append("/*, c.centro, c.medico, c.empresa, c.monto_rebajado saldo, c.cargos monto, c.pagos, c.usuario_creacion, c.fecha_creacion, c.usuario_modifica,  c.pase, c.descripcion, c.pase_k, c.compania ,decode(c.centro , null,decode(c.empresa,null,c.medico,c.empresa),c.centro) codigo_cs ,decode ( c.centro , null,decode(c.empresa,null,(select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' '||apellido_de_casada from tbl_adm_medico where codigo = c.medico ),(select nombre from tbl_adm_empresa where codigo = c.empresa)),(select descripcion from tbl_cds_centro_servicio where codigo =c.centro)) descripcion_cs,*/");

			sbSql = new StringBuffer();
			sbSql.append("select cm.pac_id, to_char(cm.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, cm.codigo_paciente, cm.secuencia as admision, to_char(cm.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, cm.factura as codigo, cm.lista, cm.rebajar, cm.categoria, cm.estado, cm.empresa as empresaEnc, cm.cobrador, cm.anio, cm.id");
			sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = cm.pac_id) as nombre_paciente");
			sbSql.append(", (select to_char(fecha,'dd/mm/yyyy') from tbl_fac_factura where compania = cm.compania and codigo = cm.factura) as fecha");
			sbSql.append(", (select grang_total from tbl_fac_factura where compania = cm.compania and codigo = cm.factura) as grang_total");
			sbSql.append(", nvl((select to_char(max(ctp.fecha),'dd/mm/yyyy') ultimo_pago from tbl_cja_transaccion_pago ctp, tbl_cja_distribuir_pago cdp where cdp.fac_codigo = cm.factura and cdp.compania = cm.compania and (cdp.codigo_transaccion = ctp.codigo and cdp.tran_anio = ctp.anio) and ctp.rec_status = 'A'),' ') as ultimo_pago");
			sbSql.append(", (select descripcion from tbl_adm_categoria_admision where codigo = cm.categoria) as descCategoria");
			sbSql.append(", nvl((select nombre from tbl_adm_empresa where codigo = cm.empresa),' ') as descEmpresa");
			sbSql.append(", cm.monto_lista as saldo, 0 as saldo_terceros");
			sbSql.append(", nvl((select sum(nvl(a_amount,monto_rebajado)) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura),0) as ajustar");
			sbSql.append(", nvl((select sum(nvl(a_amount,monto_rebajado)) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and centro is not null),0) as saldo_clinica");
			sbSql.append(", nvl((select sum(nvl(a_amount,monto_rebajado)) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and medico is not null),0) as saldo_medicos");
			sbSql.append(", nvl((select sum(nvl(a_amount,monto_rebajado)) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and empresa is not null),0) as saldo_empresas");
			sbSql.append(" from tbl_cxc_cuentasm cm where cm.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and cm.anio = ");
			sbSql.append(anio);
			sbSql.append(" and cm.lista = ");
			sbSql.append(lista);
			sbSql.append(" and cm.status != 'I' order by 15, cm.secuencia");
			al = SQLMgr.getDataList(sbSql.toString());

			for(int i=0;i<al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				cdo.setKey(iIncob.size()+1);


				try {
					iIncob.put(cdo.getKey(),cdo);
					vIncob.addElement(cdo.getColValue("factura"));
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}/**/
			sbSql = new StringBuffer();


		} else {

			lista = "0";
			mode = "add";

		}

		if (anio == null || anio.trim().equals("")) anio = cDateTime;

	}//else mode = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();<% if (request.getParameter("type") != null  && request.getParameter("type").equals("1")) { %>abrir_ventana('../common/check_fac_incobrables.jsp?fp=incob&fg=<%=fg%>&mode=<%=mode%>&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>&aType=<%=aType%>&aValue=<%=aValue%>');<% }/*else if(request.getParameter("type") != null  && request.getParameter("type").equals("3")){%>abrir_ventana('../cxc/print_fact_incobrables.jsp?anio=<%=anio%>&lista=<%=lista%>');<%}*/%>
<% if (!mode.equalsIgnoreCase("view")) { %>calc();<% } %>}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,450);}
function printFactura(factura){abrir_ventana('../facturacion/print_factura.jsp?factura='+factura+'&compania=<%=session.getAttribute("_companyId")%>');}
function showDetail(factura){showPopWin('../common/factura_detalle.jsp?factura='+factura,winWidth*.75,winHeight*.65,null,null,'');}
function printEC(factId,pacId){abrir_ventana('../facturacion/print_estado_cargo_det.jsp?factId='+factId+'&pacId='+pacId);}
function printList(){var titulo = document.form0.titulo.value;abrir_ventana('../cxc/print_fact_incobrables.jsp?anio=<%=anio%>&lista=<%=lista%>&titulo='+titulo);}
function anulaFactList(factura)
{
	 showPopWin('../process/cxc_anul_fac_aju_inc.jsp?mode=ina&fp=edit_lista_inc&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>&fg=<%=fg%>&factura='+factura,winWidth*.45,_contentHeight*.25,null,null,'');
}
function printListAjuste(){
	var titulo = document.form0.titulo.value;
	abrir_ventana('../facturacion/print_list_ajuste_automatico.jsp?fg=ajuste_automatico&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>&titulo='+titulo);
}
function calc(){
	var aType=(document.form0.aType.value.trim()=='')?'P':document.form0.aType.value;
	var aValue=parseFloat(document.form0.aValue.value);
	if(aType=='P'){
		if(document.form0.aValue.value.trim()=='')aValue=100;
		else if(document.form0.aValue.value>100){
			alert('El porcentaje no puede ser mayor al 100%!');
			aValue=100;
			document.form0.aValue.value=aValue;
		}
	}
	var tSaldo=0;
	var tClinica=0;
	var tTercero=0;
	var tMedico=0;
	var tEmpresa=0;
	for(i=0;i<<%=iIncob.size()%>;i++){
		var saldo=parseFloat(eval('document.form0.saldo'+i).value);
		var pCli=parseFloat(eval('document.form0.saldo_clinica'+i).value)/saldo;
		var pTer=parseFloat(eval('document.form0.saldo_terceros'+i).value)/saldo;
		var pMed=parseFloat(eval('document.form0.saldo_medicos'+i).value)/saldo;
		var pEmp=parseFloat(eval('document.form0.saldo_empresas'+i).value)/saldo;
		var amt=aValue;
		if(aType=='P')amt=Math.round(saldo*aValue)/100;
		else if(amt>saldo)amt=saldo;
		console.log('amount='+amt);
		if(eval('document.form0.ajustar'+i))eval('document.form0.ajustar'+i).value=amt.toFixed(2);
		tSaldo+=amt;
		tClinica+=amt*pCli;
		tTercero+=amt*pTer;
		tMedico+=amt*pMed;
		tEmpresa+=amt*pEmp;
	}
	document.form0.total.value=tSaldo.toFixed(2);
	document.form0.tClinica.value=tClinica.toFixed(2);
	document.form0.tTercero.value=tTercero.toFixed(2);
	document.form0.tMedico.value=tMedico.toFixed(2);
	document.form0.tEmpresa.value=tEmpresa.toFixed(2);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CXC - CUENTAS INCOBRABLES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+iIncob.size())%>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr align="right">
			<td colspan="2">T&iacute;tulo:<%=fb.textBox("titulo","",false,false,false,50,"Text10",null,null)%>&nbsp;<a href="javascript:printList()" class="Link00">[ Imprimir ]</a><authtype type='53'><a href="javascript:printListAjuste()" class="Link00">[ Reporte Distribuido ]</a></authtype></td>
		</tr>
		<tr class="TextFilter SpacingText">
			<td colspan="2">
				A&Ntilde;O: <%=fb.intBox("anio",anio,false,false,true,10,"Text10",null,null)%>
				NO. LISTA: <%=fb.intBox("lista",lista,false,false,true,15,"Text10",null,null)%>
				Tipo de Ajuste:
					<%=fb.select(ConMgr.getConnection(),"select fta.codigo as codigo,fta.descripcion as descripcion,decode(fta.tipo_doc,'R','RECIBO','FACTURA')||' - '||(select description from tbl_fac_adjustment_group where id = fta.group_type and status ='A')descGrupo from tbl_fac_tipo_ajuste fta where fta.compania = "+(String) session.getAttribute("_companyId")+" and fta.group_type in ('B','C','F','G','J') and fta.estatus = 'A' and fta.tipo_doc = 'F' order by fta.group_type, fta.descripcion ","tipo_ajuste",tipo_ajuste,true,false,false,0,"Text10","",null,null,"")%>
				APLICAR AL SALDO
				<%=fb.select("aType","P=%,M=$",aType,false,false,false,0,"","","onChange=\"javascript:calc()\"")%>
				<%=fb.decBox("aValue",aValue,false,false,false,8,6.2,"","","onChange=\"javascript:calc()\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
				<td><authtype type='52'><%=fb.submit("Finalizar","Finalizar",true,(mode.equalsIgnoreCase("add") || mode.equalsIgnoreCase("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype></td>
				<td align="right">
					<authtype type='3'><%=fb.submit("agregar","+",true,(mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					</authtype>
					<authtype type='53'><%=fb.submit("save","Guardar",true,(iIncob.size() == 0 || mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
				</td>
		</tr>
		<tr>
			<td colspan="2" class="TableBorder">
		<div id="_cMain" class="Container">
		<div id="_cContent" class="ContainerContent">
			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
				<tr class="TextHeader" align="center">
					<td width="15%">Nombre</td>
					<td width="6%">F.Nac.</td>
					<td width="4%">C&oacute;d.Pac.</td>
					<td width="4%">Adm.</td>
					<td width="8%">Categor&iacute;a</td>
					<td width="6%">F.Ing.</td>
					<td width="15%">Aseg.</td>
					<td width="7%">Factura</td>
					<td width="5%">Fecha</td>
					<td width="6%">Monto</td>
					<td width="6%">Saldo</td>
					<td width="6%">Ajustar</td>
					<td width="6%">Ult.Pago</td>
					<td width="3%">Incob.</td>
					<td width="3%">&nbsp;</td>
					<td width="3%">&nbsp;</td>
					<td width="3%">&nbsp;</td>
				</tr>
<%
double tAjustar = 0, tSaldo = 0, tSaldoClinica = 0, tSaldoTerceros = 0, tSaldoMedicos = 0, tSaldoEmpresas = 0;
al = CmnMgr.reverseRecords(iIncob);
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) iIncob.get(al.get(i).toString());
	tAjustar += Double.parseDouble(cdo.getColValue("ajustar"));
	tSaldo += Double.parseDouble(cdo.getColValue("saldo"));
	tSaldoClinica += Double.parseDouble(cdo.getColValue("saldo_clinica"));
	tSaldoTerceros += Double.parseDouble(cdo.getColValue("saldo_terceros"));
	tSaldoMedicos += Double.parseDouble(cdo.getColValue("saldo_medicos"));
	tSaldoEmpresas += Double.parseDouble(cdo.getColValue("saldo_empresas"));
%>
				<%=fb.hidden("key"+i,cdo.getKey())%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
				<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
				<%=fb.hidden("codigo_paciente"+i,cdo.getColValue("codigo_paciente"))%>
				<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
				<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
				<%=fb.hidden("grang_total"+i,cdo.getColValue("grang_total"))%>
				<%=fb.hidden("cobrador"+i,cdo.getColValue("cobrador"))%>
				<%=fb.hidden("rebajar"+i,cdo.getColValue("rebajar"))%>
				<%=fb.hidden("nombre_paciente"+i,cdo.getColValue("nombre_paciente"))%>
				<%=fb.hidden("fecha_ingreso"+i,cdo.getColValue("fecha_ingreso"))%>
				<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
				<%=fb.hidden("descCategoria"+i,cdo.getColValue("descCategoria"))%>
				<%=fb.hidden("descEmpresa"+i,cdo.getColValue("descEmpresa"))%>
				<%=fb.hidden("ultimo_pago"+i,cdo.getColValue("ultimo_pago"))%>
				<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>
				<%=fb.hidden("saldo_clinica"+i,cdo.getColValue("saldo_clinica"))%>
				<%=fb.hidden("saldo_terceros"+i,cdo.getColValue("saldo_terceros"))%>
				<%=fb.hidden("saldo_medicos"+i,cdo.getColValue("saldo_medicos"))%>
				<%=fb.hidden("saldo_empresas"+i,cdo.getColValue("saldo_empresas"))%>
				<%=fb.hidden("rebajado"+i,cdo.getColValue("rebajado"))%>
				<%=fb.hidden("noLista"+i,cdo.getColValue("noLista"))%>
				<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("aType"+i,cdo.getColValue("aType"))%>
				<%=fb.hidden("aValue"+i,cdo.getColValue("aValue"))%>
				<tr class="TextRow04" align="center">
					<td align="left"><%=cdo.getColValue("nombre_paciente")%></td>
					<td><%=cdo.getColValue("fecha_nacimiento")%></td>
					<td><%=cdo.getColValue("pac_id")%></td>
					<td><%=cdo.getColValue("admision")%></td>
					<td><%=cdo.getColValue("descCategoria")%></td>
					<td><%=cdo.getColValue("fecha_ingreso")%></td>
					<td align="left"><%=cdo.getColValue("descEmpresa")%></td>
					<td><a href="javascript:showDetail('<%=cdo.getColValue("codigo")%>');" class="Link00"><%=cdo.getColValue("codigo")%></a></td>
					<td><%=cdo.getColValue("fecha")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%></td>
					<td><%=fb.decBox("ajustar"+i,CmnMgr.getFormattedDecimal(cdo.getColValue("ajustar")).replaceAll(",",""),false,false,true,7,"Text10",null,null)%></td>
					<td align="right"><%=cdo.getColValue("ultimo_pago")%></td>
					<td><%=fb.checkbox("rebajarDsp"+i,"S",(cdo.getColValue("rebajar") != null && cdo.getColValue("rebajar").equalsIgnoreCase("S")),true,"","","onClick=javascript:isValid("+i+",'"+cdo.getColValue("rebajado")+"')","")%></td>
					<td><authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onClick="javascript:printFactura('<%=cdo.getColValue("codigo")%>')"></authtype></td>
					<td><authtype type='51'><a href="javascript:printEC('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("pac_id")%>')" class="Link00">EC</a></authtype></td>
					<td>
					<%if(mode.equals("edit")){%><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/cancel.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Anular Factura')" onClick="javascript:anulaFactList('<%=cdo.getColValue("codigo")%>')"><%} else {%>
					<%=fb.submit("del"+i,"x",false,mode.equalsIgnoreCase("view"),"","","onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value;\"")%>
					<%}%>
					</td>

				</tr>
<% } %>
				</table>
		</div>
		</div>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02 SpacingText">
					<td colspan="4">&nbsp;Montos de la Lista</td>
					<td width="60%" align="right" rowspan="3">TOTAL DE LA LISTA: <!--<label class="YellowText"><%=CmnMgr.getFormattedDecimal(tSaldo)%></label>--><%=fb.decBox("total",CmnMgr.getFormattedDecimal(tAjustar),false,false,true,10,"YellowTextBold SpacingText",null,null)%>&nbsp;</td>
				</tr>
				<tr class="TextRow01" align="right">
					<td width="10%">Cl&iacute;nica:</td>
					<td width="10%"><!--<%=CmnMgr.getFormattedDecimal(tSaldoClinica)%>--><%=fb.decBox("tClinica",CmnMgr.getFormattedDecimal(tSaldoClinica),false,false,true,10,"",null,null)%></td>
					<td width="10%">Terceros:</td>
					<td width="10%"><!--<%=CmnMgr.getFormattedDecimal(tSaldoTerceros)%>--><%=fb.decBox("tTercero",CmnMgr.getFormattedDecimal(tSaldoTerceros),false,false,true,10,"",null,null)%></td>
				</tr>
				<tr class="TextRow01" align="right">
					<td>M&eacute;dicos:</td>
					<td><!--<%=CmnMgr.getFormattedDecimal(tSaldoMedicos)%>--><%=fb.decBox("tMedico",CmnMgr.getFormattedDecimal(tSaldoMedicos),false,false,true,10,"",null,null)%></td>
					<td>Empresas:</td>
					<td><!--<%=CmnMgr.getFormattedDecimal(tSaldoEmpresas)%>--><%=fb.decBox("tEmpresa",CmnMgr.getFormattedDecimal(tSaldoEmpresas),false,false,true,10,"",null,null)%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><authtype type='52'><%=fb.submit("Finalizar2","Finalizar",true,(mode.equalsIgnoreCase("add") || mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype></td>
			<td align="right">
				<authtype type='3'><%=fb.submit("agregar2","+",true,(mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></authtype>
				<authtype type='53'><%=fb.submit("save2","Guardar",true,(iIncob.size() == 0 || mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
} else {

	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	iIncob.clear();
	vIncob.clear();
	String dl = "";
	for (int i=0; i<size; i++) {
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("anio",anio);

		/*cdo.addColValue("lista","");
		if (mode.equalsIgnoreCase("edit"))
		*/System.out.println("LISTA:==== "+lista+" size = "+size+" i ===== "+i);
		cdo.addColValue("lista",lista);

		cdo.addColValue("id",request.getParameter("id"+i));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("codigo",request.getParameter("codigo"+i));
		cdo.addColValue("admision",request.getParameter("admision"+i));
		cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"+i));
		cdo.addColValue("codigo_paciente",request.getParameter("codigo_paciente"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("estado",request.getParameter("estado"+i));
		cdo.addColValue("empresa",request.getParameter("empresa"+i));
		cdo.addColValue("pac_id",request.getParameter("pac_id"+i));
		cdo.addColValue("grang_total",request.getParameter("grang_total"+i));
		cdo.addColValue("cobrador",request.getParameter("cobrador"+i));
		cdo.addColValue("rebajar",request.getParameter("rebajar"+i));
		cdo.addColValue("nombre_paciente",request.getParameter("nombre_paciente"+i));
		cdo.addColValue("fecha_ingreso",request.getParameter("fecha_ingreso"+i));
		cdo.addColValue("categoria",request.getParameter("categoria"+i));
		cdo.addColValue("descCategoria",request.getParameter("descCategoria"+i));
		cdo.addColValue("descEmpresa",request.getParameter("descEmpresa"+i));
		cdo.addColValue("ultimo_pago",request.getParameter("ultimo_pago"+i));
		cdo.addColValue("saldo",request.getParameter("saldo"+i));
		cdo.addColValue("saldo_clinica",request.getParameter("saldo_clinica"+i));
		cdo.addColValue("saldo_terceros",request.getParameter("saldo_terceros"+i));
		cdo.addColValue("saldo_medicos",request.getParameter("saldo_medicos"+i));
		cdo.addColValue("saldo_empresas",request.getParameter("saldo_empresas"+i));
		cdo.addColValue("rebajado",request.getParameter("rebajado"+i));
		cdo.addColValue("noLista",request.getParameter("noLista"+i));
		cdo.addColValue("tipo_ajuste",request.getParameter("tipo_ajuste"));
		cdo.addColValue("tipo",request.getParameter("tipo"+i));

		cdo.addColValue("secuencia",request.getParameter("admision"+i));
		cdo.addColValue("factura",request.getParameter("codigo"+i));
		cdo.addColValue("monto_lista",request.getParameter("saldo"+i));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("fecha_modifica","sysdate");
		cdo.addColValue("a_type",request.getParameter("aType"));
		cdo.addColValue("a_value",request.getParameter("aValue"));
		cdo.addColValue("aType",request.getParameter("aType"));
		cdo.addColValue("aValue",request.getParameter("aValue"));
		cdo.addColValue("ajustar",request.getParameter("ajustar"+i));

		if(request.getParameter("del"+i)==null){
			cdo.setKey(iIncob.size()+1);

			try {
				al.add(cdo);
				iIncob.put(cdo.getKey(),cdo);
				vIncob.addElement(cdo.getColValue("codigo"));
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
		} else {
			dl = "1";
		}
	}

	if(!dl.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+request.getParameter("fg")+"&mode="+request.getParameter("mode")+"&anio="+request.getParameter("anio")+"&lista="+request.getParameter("lista")+"&type=2&change=1&tipo_ajuste="+request.getParameter("tipo_ajuste")+"&aType="+request.getParameter("aType")+"&aValue="+request.getParameter("aValue"));
		return;
	}

	if (baction.equalsIgnoreCase("+")) {

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+request.getParameter("fg")+"&mode="+request.getParameter("mode")+"&anio="+request.getParameter("anio")+"&lista="+request.getParameter("lista")+"&type=1&change=1&tipo_ajuste="+request.getParameter("tipo_ajuste")+"&aType="+request.getParameter("aType")+"&aValue="+request.getParameter("aValue"));
		return;

	} else {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"baction="+baction+" anio="+anio+" lista="+lista);

		if (baction.equalsIgnoreCase("Guardar")) {

			INCMgr.saveList(al);
			if (mode.equalsIgnoreCase("add")) lista = INCMgr.getPkColValue("lista");
			mode = "edit";

		} else if (baction.equalsIgnoreCase("Finalizar")) {

			INCMgr.cerrarLista(anio,lista,(String) session.getAttribute("_companyId"), request.getParameter("tipo_ajuste"));
			mode = "view";

		}

		ConMgr.clearAppCtx(null);

	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<% if (INCMgr.getErrCode().equals("1")) { %>
	alert('<%=INCMgr.getErrMsg()%>. Lista No. '+<%=lista%>);
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/list_fact_incob_x_saldo.jsp")) { %>
	window.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/list_fact_incob_x_saldo.jsp")%>&anio=<%=anio%>';
<% } else { %>
	window.location = '<%=request.getContextPath()%>/cxc/list_fact_incob_x_saldo.jsp?fg=<%=fg%>&mode=<%=mode%>&anio=<%=anio%>&lista=<%=lista%>&type=3&tipo_ajuste=<%=tipo_ajuste%>&aType=<%=aType%>&aValue=<%=aValue%>';
<% } %>

window.opener.location = '../cxc/ajuste_auto_list.jsp';

<% } else throw new Exception(INCMgr.getErrMsg()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>