<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="ACTTMgr" scope="page" class="issi.bancos.ActualizarTransacMgr"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
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
ACTTMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String mode = request.getParameter("mode");
String banco = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String nombre = request.getParameter("nombre");
String docType = request.getParameter("docType");
String codigo = request.getParameter("codigo");
String codigoDesde = request.getParameter("codigoDesde");
String codigoHasta = request.getParameter("codigoHasta");
String beneficiario = request.getParameter("beneficiario");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String estado_dep = request.getParameter("estado_dep");
String estado = request.getParameter("estado");
String fechaCorreccion = request.getParameter("fechaCorreccion");
String clearHT = request.getParameter("clearHT");
String orderBy = request.getParameter("orderBy");
String userName = UserDet.getUserName();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cDateTime.substring(0,10);

if (mode == null) mode = "edit";
if (banco == null || banco.trim().equals("")) throw new Exception("Codigo del Banco no es válido. Por favor intente nuevamente!");
if (cuenta == null || cuenta.trim().equals("")) throw new Exception("La Cuenta no es válida. Por favor intente nuevamente!");
if (nombre == null) nombre = "";
if (fechaCorreccion == null || fechaCorreccion.trim().equals("")) fechaCorreccion = cDate;
if (clearHT == null) clearHT = "Y";
if (orderBy == null) orderBy = "6";

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

	if (docType == null) docType = "";
	if (codigo == null) codigo = "";
	if (codigoDesde == null) codigoDesde = "";
	if (codigoHasta == null) codigoHasta = "";
	if (beneficiario == null) beneficiario = "";
	if (tDate == null) tDate = "";
	if (fDate == null) fDate = "";
	if (estado_dep == null) estado_dep = "";
	if (estado == null) estado = "";

	if (clearHT.trim().equalsIgnoreCase("Y")) iDoc.clear();
	if (request.getParameter("docType") != null)
	{
		if (!docType.trim().equals("")) { sbFilter.append(" and upper(x.tipoTrx) = '"); sbFilter.append(docType.toUpperCase()); sbFilter.append("'"); }
		if (!codigo.trim().equals("")) { sbFilter.append(" and upper(x.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
		if (!codigoDesde.trim().equals("")) { sbFilter.append(" and x.codigo >= '"); sbFilter.append(codigoDesde); sbFilter.append("'"); }
		if (!codigoHasta.trim().equals("")) { sbFilter.append(" and x.codigo <= '"); sbFilter.append(codigoHasta); sbFilter.append("'"); }
		if (!beneficiario.trim().equals("")) { sbFilter.append(" and upper(x.beneficiario) like '%"); sbFilter.append(beneficiario.toUpperCase()); sbFilter.append("%'"); }
		if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(x.f_emision) >= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(x.f_emision) <= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
		if (!estado_dep.trim().equals("")) { sbFilter.append(" and x.estado_dep = '"); sbFilter.append(estado_dep); sbFilter.append("'"); }
		if (!estado.trim().equals("")) { sbFilter.append(" and x.estado = '"); sbFilter.append(estado); sbFilter.append("'"); }

		sbSql.append("select x.beneficiario, x.cuentaCode, x.cuenta, x.bancoCode, x.banco, x.f_emision, x.fecha, x.fechaExpira, x.fechaPago, x.codigo_order, x.codigo, x.monto, x.estadoTrx, x.estado, x.tipo_pago, x.tipo_mov, x.docType, x.estado_dep, x.tooltip from (");
			sbSql.append("select a.beneficiario, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.cod_banco as bancoCode, d.nombre as banco, a.f_emision, to_char(a.f_emision,'dd/mm/yyyy') as fecha, to_char(a.f_expiracion,'dd/mm/yyyy') as fechaExpira, nvl(to_char(a.f_pago_banco,'dd/mm/yyyy'),' ') as fechaPago, (case when instr(a.num_cheque, 'A' ) = 1 then 'A' when instr(a.num_cheque, 'T' ) = 1 then 'T' when instr(a.num_cheque, '-A' ) = 1 then 'A' when instr(a.num_cheque, '-T' ) = 1 then '-T' when instr(a.num_cheque, '-' ) = 1 then '-' else 'C' end) || lpad(trim(TRANSLATE(a.num_cheque, '-AT', '  ')), 10, '0') codigo_order, a.num_cheque as codigo, a.monto_girado as monto, decode(a.estado_cheque,'G','GIRADO','P','PAGADO','A','ANULADO') as estadoTrx, a.estado_cheque as estado, decode(a.tipo_pago,'1','CHEQUE','2','ACH','3','TRANSF.') as tipo_pago, a.tipo_pago as tipo_mov, 'CHK' as docType, decode(a.tipo_pago,'1','4','2','5','3','6') as tipoTrx, ' ' as estado_dep, ' ' as tooltip from tbl_con_cheque a, tbl_con_cuenta_bancaria c, tbl_con_banco d where a.cuenta_banco = c.cuenta_banco and a.cod_banco = c.cod_banco and a.cod_compania = c.compania and a.cod_compania = d.compania and a.cod_banco = d.cod_banco and a.cod_compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and upper(a.cod_banco) = '");
			sbSql.append(banco.toUpperCase());
			sbSql.append("' and upper(a.cuenta_banco) = '");
			sbSql.append(cuenta.toUpperCase());
			sbSql.append("'");

			sbSql.append(" union all ");

			sbSql.append("select b.descripcion||decode(e.descripcion,null,'',' - '||e.descripcion) as tipo, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.banco as bancoCode, d.nombre as banco, a.f_movimiento, to_char(a.f_movimiento,'dd/mm/yyyy') as fecha, to_char(a.f_movimiento,'dd/mm/yyyy') as fechaExpira, nvl(to_char(a.fecha_pago,'dd/mm/yyyy'),' ') as fechaPago, lpad(a.consecutivo_ag, 10,'0')codigo_order, to_char(a.consecutivo_ag) as codigo, a.monto, decode(a.estado_trans,'T','TRAMITADA','C','CONCILIADA','A','ANULADA') as estadoTrx, a.estado_trans as estado, decode(a.tipo_movimiento,'1','DEPOSITO','2','N/DEBITO','3','N/CREDITO','OTRAS TRX BANCO') as tipo_pago, to_number(a.tipo_movimiento) as tipo_mov, 'DEP' as docType, decode(a.tipo_movimiento,'1','1','2','2','3','3','7') as tipoTrx, nvl(a.estado_dep,'-') as estado_dep, a.descripcion as tooltip from tbl_con_movim_bancario a, tbl_con_tipo_movimiento b, tbl_con_cuenta_bancaria c, tbl_con_banco d, tbl_con_tipo_deposito e where a.tipo_dep = e.codigo(+) and nvl(e.mov_banco,'S') = 'S' and a.tipo_movimiento = b.cod_transac and b.cod_transac != -1 and a.cuenta_banco = c.cuenta_banco and a.banco = c.cod_banco and a.compania = c.compania and a.compania = d.compania and a.banco = d.cod_banco and a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and upper(a.banco) = '");
			sbSql.append(banco.toUpperCase());
			sbSql.append("' and upper(a.cuenta_banco) = '");
			sbSql.append(cuenta.toUpperCase());
			sbSql.append("'");
			sbSql.append(" order by ");
			sbSql.append(orderBy);
		sbSql.append(") x");
		if (sbFilter.length() > 0) { sbSql.append(" where "); sbSql.append(sbFilter.substring(4)); }
		//sbSql.append(" order by 6");

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql+")");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
var ignoreSelectAnyWhere = true;
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
	abrir_ventana('../bancos/print_list_mov_banco.jsp?banco=<%=banco%>&cuenta=<%=cuenta%>&nombre=<%=nombre%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&orderBy=<%=orderBy%>');
}

function checkAll()
{
	var size = document.form1.keySize.value;
	var fechaCorrec = document.search00.fechaCorreccion.value;

	for (i=0; i<size; i++)
	{

			var fecha = eval('document.form1.fPago'+i).value;

		if (eval('document.form1.check').checked)
		{
			if(fecha == '' || fecha == null)
			{
				eval('document.form1.check'+i).checked = true;
				if(fechaCorrec != '' && fechaCorrec != null){fechaChk(i);}
				//eval('document.form1.fechaPago'+i).value='';
			}
		}
		else
		{
			if(fecha == '' || fecha == null)
			{
				 eval('document.form1.check'+i).checked = false;
				 eval('document.form1.fechaPago'+i).value='';
			}
		}

	}
}

function anular(cod_banco, cuenta_banco, num_cheque)
{
	abrir_ventana('../cxp/cheque.jsp?mode=edit&fp=conciliacion&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&num_cheque='+num_cheque);
}

function fechaChk(i)
{
	var fecha=eval('document.form1.fechaPago'+i).value;
	var pagado=eval('document.form1.estado'+i).value;
	var cColor=eval('document.form1.cColor'+i).value;
	var fechaPag='<%=cDate%>';
	var fechaPago = document.search00.fechaCorreccion.value;
	if(fechaPago!=null&&fechaPago.trim()!='')fechaPag=fechaPago;
	if(eval('document.form1.check'+i).checked)
	{
		if(pagado!='A'){
			if(pagado!='P') eval('document.form1.fechaPago'+i).value=fechaPag;
			eval('document.form1.check'+i).checked=true;
		}else if ((fecha==null||fecha.trim()=='')&&pagado!='P'){
		   if($("#cRow"+i).hasClass("TextRowOver")) setoutc($("#cRow"+i).get(0),cColor)
			eval('document.form1.check'+i).checked=false;
			eval('document.form1.check'+i).disabled=true;
		}
		
		//if((fecha==null||fecha.trim()=='')&&pagado!='P'&&pagado!='A')
		/* if((fecha==null||fecha.trim()=='')&&pagado!='P'&&pagado!='A')
		{
			eval('document.form1.fechaPago'+i).value=fechaPag;
			eval('document.form1.check'+i).checked=true;
		}else{
			if($("#cRow"+i).hasClass("TextRowOver")) setoutc($("#cRow"+i).get(0),cColor)
			eval('document.form1.check'+i).checked=false;
			eval('document.form1.check'+i).disabled=true;
		} */
	}
	else {
		if(pagado!='A') eval('document.form1.fechaPago'+i).value='';
	}
}

function chkDate(i){
	var fecha = eval('document.form1.fechaPago'+i).value;
	var pagado = eval('document.form1.estado'+i).value;
	
	if(pagado != 'C'){
		if((fecha.trim() == '' || fecha == null) && pagado != "P"){
			eval('document.form1.check'+i).checked = false;
		} else {
			eval('document.form1.check'+i).checked = true;
		}
	} else {
		eval('document.form1.check'+i).disabled = true;
		eval('document.form1.check'+i).checked = false;
	}

}


function fechaPago(i)
{
var fecha=eval('document.form1.fechaEmision'+i).value;
var fechaPago=eval('document.form1.fechaPago'+i).value;
if(fecha==''||fecha==null)alert('No hay Fecha Registrada');
else
{
	eval('document.form1.fechaPago'+i).value=fecha;
	eval('document.form1.check'+i).checked=true;
}
}

function actCheque(){
	var cheque = "";
	var banco = "";
	var cuenta = "";
	var v_fecha = "";
	var doc = "";
	var chk = "";
	var mov = "";
	var icount = 0;
	var msg = '';
	var size = document.form1.keySize.value;


	for(i=0;i<size;i++){
		if(eval('document.form1.check'+i).checked){ icount++;}
	}
	if(icount==0&&<%=iDoc.size()%>==0){alert('No hay Registros Seleccionados...Por Favor Verifique...!');
	return false;}
	else {document.form1.baction.value='Guardar';document.form1.submit();}
}

function free(bancoCode, cuentaCode, codigo, i){
	var vals = " estado_cheque = 'G', f_pago_banco=null, observacion=observacion||' LIBERADO POR <%=userName%>', usuario_modificacion='<%=userName%>', fecha_modificacion = to_date('<%=cDateTime%>','dd/mm/yyyy hh12:mi:ss am') ";
	var where = " where cuenta_banco = '"+cuentaCode+"' and cod_banco = '"+bancoCode+"' and num_cheque = '"+codigo+"' and estado_cheque = 'P' and f_pago_banco is not null ";
	var saved = false;

	if(!$("#free"+i).val()) {
		$("#free_noti"+i).text("Liberando...");
	   saved = executeDB('<%=request.getContextPath()%>'," UPDATE tbl_con_cheque set "+vals+" "+where,'');
	}
	
	if (saved) {
	  $("#free"+i).val("Y");
	  //$("#actualiza, #actualiza2").prop("disabled",true);
	  $("#free_noti"+i).text("Liberado");
	  $("#fechaPago"+i).val("");
	  
	  $("#estado"+i).val("G");
	  $("#status_dsp"+i).text("GIRADO");
	}
	else {
	  if ($("#free"+i).val()) alert("El cheque ya se ha liberado. Por favor actualiza la página!");
	  else{
	    $("#free_noti"+i).text("Liberar");
		alert("Error trantando de actualizar el estado del cheque!");
	  }
	}
}
$(function(){
  $(".tt").tooltip({
	content: function () {

	  var $i = $(this).data("i");
	  var $type = $(this).data("type");
	  var $title = $($(this).prop('title'));
	  var $content;
	 	  
	  if($type == "1" ) $content = $("#ttContent"+$i).val(); 
		
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
  });
});

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - TRANSACCIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("banco",banco)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("clearHT","N")%>
<tr class="TextFilter">
	<td width="50%">
		Tipo Doc.
		<%=fb.select("docType","1=DEPOSITO,2=N/DEBITO,3=N/CREDITO,4=CHEQUE,5=ACH,6=TRANSF.,7=OTRAS TRX BANCO",docType,false,false,0,"Text10",null,"","","T")%>
		No. Doc.
		<%=fb.textBox("codigo",codigo,false,false,false,11,11,null,null,null)%>
	</td>
	<td width="50%">
		No. Doc. Desde
		<%=fb.textBox("codigoDesde",codigoDesde,false,false,false,11,11,null,null,null)%>
		Hasta
		<%=fb.textBox("codigoHasta",codigoHasta,false,false,false,11,11,null,null,null)%>
	</td>
</tr>
<tr class="TextFilter">
	<td>
		Beneficiario
		<%=fb.textBox("beneficiario",beneficiario,false,false,false,45,null,null,null)%>
	</td>
	<td>
		Fecha
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="nameOfTBox1" value="tDate"/>
		<jsp:param name="valueOfTBox1" value="<%=tDate%>"/>
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="buttonClass" value="Text10"/>
		<jsp:param name="nameOfTBox2" value="fDate"/>
		<jsp:param name="valueOfTBox2" value="<%=fDate%>"/>
		<jsp:param name="jsEvent" value="chkDate();"/>
		<jsp:param name="onChange" value="chkDate();"/>
		</jsp:include>
	</td>
</tr>
<tr class="TextFilter">
	<td>
		Estado Dep.
		<%=fb.select("estado_dep","DT=EN TRANSITO,DN=DEPOSITADO",estado_dep,false,false,0,"Text10",null,"","","T")%>
		Estado
		<%=fb.select("estado","G=GIRADO,P=PAGADO,A=ANULADO,T=TRAMITADA,C=CONCILIADA",estado,false,false,0,"Text10",null,"","","T")%>
		Ordenar por:
		<%=fb.select("orderBy","6=FECHA EMISION,10=CHEQUE",orderBy,false,false,0,"Text10",null,"","","")%>
		<%=fb.submit("go","Ir")%>
	</td>
	<td>
		Fecha De Pago a Actualizar
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1"/>
		<jsp:param name="nameOfTBox1" value="fechaCorreccion"/>
		<jsp:param name="valueOfTBox1" value="<%=fechaCorreccion%>"/>
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="buttonClass" value="Text10"/>
		<jsp:param name="clearOption" value="true"/>
		</jsp:include>
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td colspan="2" align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("document.form1.fechaCorreccion.value=document.search00.fechaCorreccion.value;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("banco",banco)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("codigoDesde",codigoDesde)%>
<%=fb.hidden("codigoHasta",codigoHasta)%>
<%=fb.hidden("beneficiario",beneficiario)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("estado_dep",estado_dep)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("fechaCorreccion",fechaCorreccion)%>
<%=fb.hidden("orderBy",orderBy)%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("clearHT","N")%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow02">
			<td colspan="10" align="right"> <authtype type='50'>
				<%=fb.button("actualiza2","Actualizar",true,false,null,null,"onClick=\"javascript:actCheque()\"")%></authtype>
				<%=fb.button("Cancelar2","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="8%">No. Doc.</td>
			<td width="20%">Beneficiario</td>
			<td width="12%">Fecha Emisi&oacute;n</td>
			<td width="8%">Fecha Exp.</td>
			<td width="8%">Tipo</td>
			<td width="8%">Estado</td>
			<td width="10%">Monto</td>
			<td width="12%">Fecha Pago</td>
			<td width="3%">
			<%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los cheques listados!")%>
			</td>
			<td width="17%" align="center">&nbsp;</td>
		</tr>
<%
String cta = "";
String bank = "";
String key = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	key = cdo.getColValue("docType")+"-"+cdo.getColValue("tipo_mov")+"-"+cdo.getColValue("codigo")+"-"+cdo.getColValue("fecha");
	boolean isDisabled = false;
	//if ((cdo.getColValue("docType").equalsIgnoreCase("DEP") && cdo.getColValue("estado_dep").equalsIgnoreCase("DN")) || (cdo.getColValue("docType").equalsIgnoreCase("CHK") && cdo.getColValue("estado").equalsIgnoreCase("P")) || !cdo.getColValue("fechaPago").trim().equals("")) isDisabled = true;
	if (cdo.getColValue("estado")!=null && cdo.getColValue("estado").equalsIgnoreCase("C")) isDisabled = true;
	
	if (cdo.getColValue("estado").equalsIgnoreCase("A")) isDisabled = true;
%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("cheque"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("beneficiario"+i,cdo.getColValue("beneficiario"))%>
		<%=fb.hidden("fechaEmision"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("fechaExpira"+i,cdo.getColValue("fechaExpira"))%>
		<%=fb.hidden("cuentaCode"+i,cdo.getColValue("cuentaCode"))%>
		<%=fb.hidden("bancoCode"+i,cdo.getColValue("bancoCode"))%>
		<%=fb.hidden("consecutivo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo_mov"))%>
		<%=fb.hidden("docType"+i,cdo.getColValue("docType"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("fPago"+i,cdo.getColValue("fechaPago"))%>
		<%=fb.hidden("cColor"+i,color)%>
		<%=fb.hidden("ttContent"+i,"<label class='ttContent' style='font-size:11px'>"+(cdo.getColValue("tooltip")==null?"":cdo.getColValue("tooltip"))+"</label>")%>
		<% if (!bank.equalsIgnoreCase(cdo.getColValue("bancoCode"))) { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td colspan="10">Banco: [ <%=cdo.getColValue("bancoCode")%> ] <%=cdo.getColValue("banco")%></td>
		</tr>
		<% } %>
		<% if (!cta.equalsIgnoreCase(cdo.getColValue("cuentaCode"))) { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td colspan="10">Cuenta Bancaria: <%=cdo.getColValue("cuenta")%></td>
		</tr>
		<% } %>
		<tr id="cRow<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><span class="tt" title="" data-i="<%=i%>" data-type="1"><%=cdo.getColValue("beneficiario")%></span></td>
			<td align="center">
				<%=cdo.getColValue("fecha")%>
				<%=fb.button("btnFecha"+i,"==>",true,isDisabled,null,null,"onClick=\"javascript:fechaPago("+i+")\"","Fecha de Pago")%><%=cdo.getColValue("docType")%>
			</td>
			<td align="center"><%=cdo.getColValue("fechaExpira")%></td>
			<td align="center"><%=cdo.getColValue("tipo_pago")%></td>
			<td align="center"><span id="status_dsp<%=i%>"><%=cdo.getColValue("estadoTrx")%></span></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
			<td align="center">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="<%="fechaPago"+i%>"/>
				<jsp:param name="valueOfTBox1" value="<%=(iDoc.containsKey(key))?((CommonDataObject) iDoc.get(key)).getColValue("fecha_pago"):cdo.getColValue("fechaPago").trim()%>"/>
				<jsp:param name="readonly" value="<%=(/*!mode.trim().equalsIgnoreCase("edit") || (cdo.getColValue("fechaPago") != null && !cdo.getColValue("fechaPago").trim().equals(""))*/  (isDisabled))?"y":"n"%>"/>
				<jsp:param name="onChange" value="<%="chkDate("+i+")"%>"/>
				<jsp:param name="jsEvent" value="<%="chkDate("+i+")"%>"/>
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
			</td>
			<td align="center"><%=fb.checkbox("check"+i,"S",(iDoc.containsKey(key)),isDisabled,"","","onClick=\"javascript:fechaChk("+i+")\"")%></td>
			<td align="center">&nbsp;
			<% if (!cdo.getColValue("docType").equalsIgnoreCase("DEP") && (cdo.getColValue("estado").equalsIgnoreCase("G"))) 
			{ %>
				<!--<authtype type='7'>
					<a href="javascript:anular('<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">
					Anular
					</a>
				</authtype>-->
			<% }  else if (!cdo.getColValue("docType").equalsIgnoreCase("DEP") && (cdo.getColValue("estado").equalsIgnoreCase("A"))) 
			{ %>
				<authtype type='51'>
					<a href="javascript:anular('<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">
					Cambiar Fecha
					</a>
				</authtype>
			<% } else if(cdo.getColValue("docType")!=null&&cdo.getColValue("docType").equals("CHK") && cdo.getColValue("estado")!=null&&cdo.getColValue("estado").equals("P") && cdo.getColValue("fechaPago")!=null&&!cdo.getColValue("fechaPago").trim().equals("")){%>
			  <authtype type='51'>
					<a href="javascript:free('<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("codigo")%>',<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">
					<span id="free_noti<%=i%>">Liberar</span>
					</a>
				</authtype>
				<%=fb.hidden("free"+i,"")%>
			<%}%>
			</td>
		</tr>

<%
	bank = cdo.getColValue("bancoCode");
	cta = cdo.getColValue("cuentaCode");
}
%>
		<tr class="TextRow02">
			<td colspan="10" align="right">
			<authtype type='50'><%=fb.button("actualiza","Actualizar",true,false,null,null,"onClick=\"javascript:actCheque()\"")%></authtype>
			<%=fb.button("Cancelar","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("keySize"));
	String key = "";
	for (int i=0; i<size; i++)
	{
		key = request.getParameter("docType"+i)+"-"+request.getParameter("tipo"+i)+"-"+request.getParameter("codigo"+i)+"-"+request.getParameter("fechaEmision"+i);

		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("docType",request.getParameter("docType"+i));
			cdo.addColValue("tipo",request.getParameter("tipo"+i));
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("fechaEmision",request.getParameter("fechaEmision"+i));

			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion","sysdate");
			if (request.getParameter("fechaPago"+i) != null/* && !request.getParameter("fechaPago"+i).trim().equals("")*/) cdo.addColValue("fecha_pago",request.getParameter("fechaPago"+i));
			else cdo.addColValue("fecha_pago",request.getParameter("fechaEmision"+i));

			if (request.getParameter("docType"+i).equalsIgnoreCase("CHK"))
			{
				cdo.addColValue("num_cheque",request.getParameter("codigo"+i));
				cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
				cdo.addColValue("cod_banco",request.getParameter("bancoCode"+i));
				cdo.addColValue("cuenta_banco",request.getParameter("cuentaCode"+i));

				if (request.getParameter("estado"+i).equalsIgnoreCase("A")) cdo.addColValue("estado_cheque","A");
				else{if(cdo.getColValue("fecha_pago")!=null && !cdo.getColValue("fecha_pago").trim().equals("")) cdo.addColValue("estado_cheque","P");}
				cdo.addColValue("f_pago_banco",cdo.getColValue("fecha_pago"));
			}
			else if (request.getParameter("docType"+i).equalsIgnoreCase("DEP"))
			{
				cdo.addColValue("consecutivo_ag",request.getParameter("codigo"+i));
				cdo.addColValue("f_movimiento",request.getParameter("fechaEmision"+i));
				cdo.addColValue("banco",request.getParameter("bancoCode"+i));
				cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
				cdo.addColValue("cuenta_banco",request.getParameter("cuentaCode"+i));
				cdo.addColValue("tipo_movimiento",request.getParameter("tipo"+i));

				cdo.addColValue("estado_dep","DN");
				cdo.addColValue("fecha_pago",cdo.getColValue("fecha_pago"));
			}

			try
			{
				iDoc.put(key,cdo);
			}
			catch(Exception e)
			{
				System.out.println("Unable to add document to Hashtable!");
			}
		}
		else if (iDoc.containsKey(key)) iDoc.remove(key);
	}//end for

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&banco="+banco+"&cuenta="+cuenta+"&nombre="+nombre+"&docType="+docType+"&codigo="+codigo+"&codigoDesde="+codigoDesde+"&codigoHasta="+codigoHasta+"&beneficiario="+beneficiario+"&fDate="+fDate+"&tDate="+tDate+"&estado_dep="+estado_dep+"&estado="+estado+"&fechaCorreccion="+fechaCorreccion+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&clearHT=N");

		return;
	}
	else if (request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&banco="+banco+"&cuenta="+cuenta+"&nombre="+nombre+"&docType="+docType+"&codigo="+codigo+"&codigoDesde="+codigoDesde+"&codigoHasta="+codigoHasta+"&beneficiario="+beneficiario+"&fDate="+fDate+"&tDate="+tDate+"&estado_dep="+estado_dep+"&estado="+estado+"&fechaCorreccion="+fechaCorreccion+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&clearHT=N");
		return;
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		if (iDoc.size() == 0) throw new Exception("No hay documentos para conciliar!");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		ACTTMgr.updateTrx(iDoc);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (ACTTMgr.getErrCode().equals("1")) { %>
alert('<%=ACTTMgr.getErrMsg()%>');
window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&banco=<%=banco%>&cuenta=<%=cuenta%>&nombre=<%=nombre%>&docType=<%=docType%>&codigo=<%=codigo%>&codigoDesde=<%=codigoDesde%>&codigoHasta=<%=codigoHasta%>&beneficiario=<%=beneficiario%>&fDate=<%=fDate%>&tDate=<%=tDate%>&estado_dep=<%=estado_dep%>&estado=<%=estado%>&fechaCorreccion=<%=fechaCorreccion%>';
//window.close();
<% } else throw new Exception(ACTTMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>