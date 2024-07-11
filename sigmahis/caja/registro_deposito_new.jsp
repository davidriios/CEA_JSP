<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTotal = new CommonDataObject();
ArrayList alTurnos = new ArrayList();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String compania = request.getParameter("compania");
String caja = request.getParameter("caja");
String banco = request.getParameter("banco");
String consecutivo = request.getParameter("consecutivo");
String cuenta = request.getParameter("cuenta");
String fp = request.getParameter("fp");
String ip = request.getRemoteAddr();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlTot = new StringBuffer();
String fg = request.getParameter("fg");
String regType= request.getParameter("regType");
String fechaDesde = request.getParameter("fechaDesde");
String fechaHasta = request.getParameter("fechaHasta");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (fp == null) fp = "deposito";
if (fg == null) fg = "AUX";
if (regType == null) regType = "EF";

if(mode.equals("view")) viewMode=true;
CommonDataObject cdoEnc = (CommonDataObject) SQLMgr.getData("select to_char(sysdate-3,'dd/mm/yyyy') fechaDesde from dual ");

if (fechaDesde == null){if(cdoEnc!=null && !cdoEnc.getColValue("fechaDesde").equals("")) fechaDesde = cdoEnc.getColValue("fechaDesde");}
if (fechaHasta == null) fechaHasta = cDateTime.substring(0,10);

if (request.getMethod().equalsIgnoreCase("GET"))
{
if (mode.equalsIgnoreCase("add"))
	{
		consecutivo = "0";
		cdo = new CommonDataObject();
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("usuario",(String) session.getAttribute("_userName"));
		cdo.addColValue("tipo_dep","1");
		cdo.addColValue("tipo_tarjeta","1");
		cdo.addColValue("sobrante","N");
		if(regType.trim().equals("EF"))cdo.addColValue("regType","1");
		else if(regType.trim().equals("TR"))cdo.addColValue("regType","2");
		else if(regType.trim().equals("ACH"))cdo.addColValue("regType","4");
		else cdo.addColValue("regType","");
		if (!viewMode) mode = "add";

		sbSql = new StringBuffer();
		/*sbSql.append("select a.compania, a.cod_turno turno, a.cod_caja caja, b.cja_cajera_cod_cajera cod_cajera, a.estatus, c.nombre nombre_cajera, d.descripcion nombre_caja, to_char(b.hora_inicio, 'hh12:mi am') hora_inicio, to_char(b.fecha, 'dd/mm/yyyy') fecha,b.fecha f_t from tbl_cja_turnos_x_cajas a, tbl_cja_turnos b, tbl_cja_cajera c, tbl_cja_cajas d where a.cod_turno = b.codigo and b.cja_cajera_cod_cajera = c.cod_cajera and a.cod_caja = d.codigo and a.compania = d.compania and a.compania = c.compania and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
 		sbSql.append(" order by b.fecha asc,3,2");
	alTurnos = SQLMgr.getDataList(sbSql.toString());*/


if(request.getParameter("fechaDesde")!=null){

sbSql.append("select x.* ,case when nvl(x.total_cja,0) > nvl(x.final_total,0) then nvl(x.final_total,0) - nvl(x.total_cja,0)  else 0 end as faltante,case when nvl(x.total_cja,0) < nvl(x.final_total,0) then nvl(x.final_total,0)-nvl(x.total_cja,0)  else 0 end as sobrante from (select a.session_id turno, nvl(a.total_cash,0) as total_cash, nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_EFECTIVO'),0)efectivo,nvl(a.total_cheque,0)as total_cheque,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_CHEQUE'),0) as cheque,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TARJETAS_DB'),0) as tarjetasDb,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TARJETAS_CR'),0) as tarjetasCr, nvl(a.total_accdeposit,0) as depositos, nvl(a.total_creditcard,0)+nvl(a.total_debitcard,0) as tarjetasCierre,nvl(a.final_total,0)as final_total,nvl((select nvl(sum(nvl(tp.pago_total,0)),0) as pago_total from tbl_cja_transaccion_pago tp where tp.compania = a.company_id and tp.turno = a.session_id and (tp.rec_status = 'A' or (tp.rec_status = 'I' and tp.turno <> tp.turno_anulacion))),0) total_cja,nvl(a.otros,0)as otros,tc.cod_caja caja,to_char(t.fecha, 'dd/mm/yyyy') fecha,c.nombre nombre_cajera, d.descripcion nombre_caja,0 montoDevTarjeta,a.depositar,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TRANS_ACH'),0) as depAch ");
if(regType.trim().equals("EF"))sbSql.append(" ,nvl(a.diferencia,0) ");
else if(regType.trim().equals("TR"))sbSql.append(" ,nvl(a.dif_tarjeta,0) ");
else if(regType.trim().equals("ACH"))sbSql.append(" ,nvl(a.dif_ach,0) ");
 sbSql.append(" as diferencia from tbl_cja_sesdetails a,tbl_cja_turnos t,tbl_cja_turnos_x_cajas tc, tbl_cja_cajera c, tbl_cja_cajas d  where a.depositar = 'S'  and a.session_id =t.codigo and a.company_id =t.compania and a.company_id =");
 sbSql.append((String) session.getAttribute("_companyId"));
  	if (!fechaDesde.trim().equals("")){ sbSql.append(" and t.fecha >=to_date('");sbSql.append(fechaDesde);sbSql.append("','dd/mm/yyyy')");}
	if (!fechaHasta.trim().equals("")){ sbSql.append(" and t.fecha <=to_date('");sbSql.append(fechaHasta);sbSql.append("','dd/mm/yyyy')");}
sbSql.append(" and not exists (select null from tbl_cja_turno_cierre y where y.estado = 'A' and y.turno = a.session_id and y.compania = a.company_id and y.reg_type ='");
sbSql.append(regType);
sbSql.append("') /*and  not exists (select 1 from (select to_number(nvl(column_value,-1)) turnos  from table( select split(( select join(cursor(select nvl(mb.turnos_cierre,'-1') from tbl_con_movim_bancario mb where turnos_cierre is not null and reg_type ='");
sbSql.append(regType);
sbSql.append("' and compania =");
sbSql.append((String) session.getAttribute("_companyId"));

sbSql.append(" ),'|') from dual ),'|') from dual )) y where  y.turnos =a.session_id)*/ ");


sbSql.append(" and tc.cod_turno = t.codigo and t.cja_cajera_cod_cajera = c.cod_cajera and tc.cod_caja = d.codigo and tc.compania = d.compania and tc.compania = c.compania ) x ");
if(regType.trim().equals("EF")){sbSql.append(" where  ((nvl(efectivo,0) + nvl(cheque,0))<> 0  or  (nvl(total_cash,0)+ nvl(total_cheque,0)) <> 0) ");}
else if(regType.trim().equals("ACH")){sbSql.append(" where  (nvl(depAch,0) <> 0  or  nvl(depositos,0) <> 0) ");}
else sbSql.append(" where  ((nvl(tarjetasCr,0) + nvl(tarjetasDb,0))<> 0  or nvl(tarjetasCierre,0)<> 0)");
sbSql.append(" order by x.caja,x.turno");


alTurnos = SQLMgr.getDataList(sbSql.toString());

sbSqlTot.append("select sum (nvl(efectivo,0))as efectivo, sum(nvl(cheque,0))as cheque, sum(nvl(depositos,0)) as depositos, sum(nvl(tarjetasDb,0)) as tarjetasDb,sum(nvl(tarjetasCr,0)) as tarjetasCr,sum(nvl(final_total,0))as final_total,sum(nvl(total_cja,0))as total_cja,sum(nvl(faltante,0))as faltante ,sum(nvl(sobrante,0))as sobrante,sum(nvl(otros,0))as otros from(");sbSqlTot.append(sbSql);
sbSqlTot.append(")");
if(alTurnos.size()!=0){cdoTotal = SQLMgr.getData(sbSqlTot.toString());

if(regType.trim().equals("EF")||regType.trim().equals("ACH")){
cdoTotal.addColValue("tarjetasDb","0");
cdoTotal.addColValue("tarjetasCr","0");
if(!regType.trim().equals("ACH"))cdoTotal.addColValue("depAch","0");
}
}
else{ cdoTotal = new CommonDataObject();
cdoTotal.addColValue("efectivo","0");
cdoTotal.addColValue("depositos","0");
cdoTotal.addColValue("cheque","0");
cdoTotal.addColValue("tarjeta_cr","0");
cdoTotal.addColValue("tarjetasDb","0");
cdoTotal.addColValue("tarjetasCr","0");
cdoTotal.addColValue("depAch","0");
cdoTotal.addColValue("tarjeta_db","0");
cdoTotal.addColValue("otros","0");
cdoTotal.addColValue("final_total","0");
cdoTotal.addColValue("total_cja","0");
cdoTotal.addColValue("faltante","0");
cdoTotal.addColValue("sobrante","0");
}




}
	}
	else
	{
			if (consecutivo == null || caja == null || banco== null || cuenta==null) throw new Exception("Los datos del Depósito no son válido. Por favor intente nuevamente!");
sql="SELECT a.CONSECUTIVO_AG, a.BANCO, a.COMPANIA,a.CUENTA_BANCO as cuenta, to_char(a.F_MOVIMIENTO,'dd/mm/yyyy') as fecha, a.TIPO_MOVIMIENTO,t.descripcion as tipoMovimiento,a.DESCRIPCION, a.NUM_DOCUMENTO, to_char(a.FECHA_CREACION,'dd/mm/yyyy') as fecha_creacion,a.USUARIO_CREACION as usuario,a.VERIFICACION, a.MONTO, a.LADO,a.ESTADO_TRANS, to_char(a.F_ANULACION,'dd/mm/yyyy') as fANULACION, a.OBSERVACION, a.NOTAS_DEBITO, a.NOTAS_CREDITO,a.ESTADO_DEP, to_char(a.FECHA_PAGO,'dd/mm/yyyy') as FECHAPAGO, a.CAJA, nvl(a.MTO_TOT_TARJETA,'') as MTO_TOT_TARJETA  , nvl(a.TIPO_TARJETA,'1')as tipo_tarjeta, nvl(a.COMISION,'') as comision, a.DEVOLUC_TARJ as devolucion, nvl(a.TIPO_DEP,'1')as tipo_dep, a.DEP_MODIF, a.TURNO, a.PAGO, nvl(a.SOBRANTE,'N')as sobrante , co.nombre as nombreCompania, ca.descripcion as nombreCaja,ban.nombre as nombreBanco, cu.descripcion as nombreCuenta,(select c.nombre nombre_cajera from tbl_cja_turnos_x_cajas x,tbl_cja_turnos b, tbl_cja_cajera c where x.cod_turno = b.codigo and b.cja_cajera_cod_cajera = c.cod_cajera and x.compania = c.compania and x.compania = a.compania and x.cod_caja = a.caja and x.cod_turno=a.turno)cajero,(select sum(nvl(column_value,0))  from table( select split((a.monto_efectivo),'|') from dual  ) )monto_efectivo,(select sum(nvl(column_value,0))  from table( select split((a.monto_cheque),'|') from dual  ) ) as monto_cheque,'EN ESTE DEPOSITO SE REGISTRARON LOS SIGUIENTES TURNOS --> '||replace(a.turnos_cierre,'|',',') turnos,replace(a.turnos_cierre,'|',',') turnos_dep,(select sum(nvl(column_value,0))  from table( select split((nvl(a.monto_tarjeta,0)),'|') from dual  ) )tarjetasDb,(select sum(nvl(column_value,0))  from table( select split((nvl(a.monto_tarjetacr,0)),'|') from dual  ) )tarjetasCr,(select sum(nvl(column_value,0))  from table( select split((a.diferencia),'|') from dual)) diferencia,decode(a.reg_type,'EF',1,'TR',2,0) as regType,(select sum(nvl(column_value,0))  from table( select split((a.monto_ach),'|') from dual)) as monto_ach FROM TBL_CON_MOVIM_BANCARIO a , TBL_SEC_COMPANIA co ,TBL_CJA_CAJAS ca ,TBL_CON_BANCO ban, TBL_CON_CUENTA_BANCARIA cu,TBL_CON_TIPO_MOVIMIENTO t where a.CONSECUTIVO_AG ='"+consecutivo+"' and a.banco = '"+banco+"' and co.codigo=a.COMPANIA and ca.codigo(+) =a.caja and ca.compania(+) = a.compania and a.compania = ban.compania and ban.cod_banco=a.banco and cu.cod_banco = a.banco and cu.compania = a.compania and cu.cuenta_banco=a.CUENTA_BANCO and a.cuenta_banco='"+cuenta+"' and a.compania="+compania+" and t.COD_TRANSAC = a.tipo_movimiento and a.tipo_movimiento=1";
cdo = SQLMgr.getData(sql);

if (!viewMode) mode = "edit";



}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Registro de Depósitos- '+document.title;
function doSubmit(fName,baction){
document.form0.baction.value=baction;
if(form0Validation()){document.form0.submit();}
}
function CheckFecha()
{
		var x=0;
		var com = eval('document.form0.compania').value;
		var fecha = '<%=cDateTime.substring(0,10)%>';
		var fecha_cierre = getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+com+' and  nvl(comprobante,\'A\')= \'S\' and to_date(to_char(fecha,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+fecha+'\',\'dd/mm/yyyy\')','');
		if(fecha_cierre !="0")
		{

			x++;
			alert('Esta fecha ya esta Procesada en el Departamento de Contabilidad...');

		}
		//return false;
		if(x>0)	return false;
			else  return true;
}
function showComprobante()
{<%if (!mode.equalsIgnoreCase("add")){%>
var turnos = eval('document.form0.turnos').value;
abrir_ventana2('../caja/print_reporte_deposito.jsp?fg=CONTA&turno='+turnos+'&usuario=<%=(String) session.getAttribute("_userName")%>&consecutivo=<%=consecutivo%>&banco=<%=banco%>&cuenta=<%=cuenta%>');
<%}%>
}
function showBanco(){
	var compania = eval('document.form0.compania').value;
	if(compania!=""){
		abrir_ventana1('../bancos/saldobank_cta_list.jsp?id=4&fp=deposito&compania='+compania);
	} else alert('Seleccione Compañia');
}
function showCompania(){abrir_ventana1('../caja/compania_caja_list.jsp?fp=deposito');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();<%if(!mode.trim().equals("view")){%>setTotal(-1);<%}%>}
function resizeFrame(){if(document.getElementById('_cMain'))resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function setTotal(k)
{
		var totalEfectivo = 0;
		var totalCheque = 0;
		var totalTarjeta =0;
		var totalTarjetaCr =0;
		var totalAch=0;
		var total = 0;
		var diferencia =0;
		var size = document.form0.turnosSize.value;
 		for(j=0;j<size;j++)
		{
			var checkReg = 'N';
			if(eval('document.form0._aplicar'+j+'Dsp')) checkReg=eval('document.form0._aplicar'+j+'Dsp').value;
			if(eval('document.form0.aplicar'+j).checked==true||('<%=fg%>'=='AUX' && checkReg =='S')){
			if(eval('document.form0.montoEfectivo'+j).value!=''){ total += parseFloat(eval('document.form0.montoEfectivo'+j).value);totalEfectivo += parseFloat(eval('document.form0.montoEfectivo'+j).value);}
			if(eval('document.form0.montoCheque'+j).value!=''){ total += parseFloat(eval('document.form0.montoCheque'+j).value);totalCheque += parseFloat(eval('document.form0.montoCheque'+j).value);}
			if(eval('document.form0.montoTarjeta'+j).value!=''){ total += parseFloat(eval('document.form0.montoTarjeta'+j).value);totalTarjeta += parseFloat(eval('document.form0.montoTarjeta'+j).value);}
			if(eval('document.form0.montoTarjetaCr'+j).value!=''){ total += parseFloat(eval('document.form0.montoTarjetaCr'+j).value);totalTarjetaCr += parseFloat(eval('document.form0.montoTarjetaCr'+j).value);}
			if(eval('document.form0.montoAch'+j).value!=''){ total += parseFloat(eval('document.form0.montoAch'+j).value);totalAch += parseFloat(eval('document.form0.montoAch'+j).value);}
			if(eval('document.form0.diferencia'+j).value!=''){ total += parseFloat(eval('document.form0.diferencia'+j).value);diferencia += parseFloat(eval('document.form0.diferencia'+j).value);}
			}
		}
		document.form0.montoEfectivo.value=totalEfectivo.toFixed(2);
		document.form0.montoCheque.value=totalCheque.toFixed(2);
		document.form0.montoTarjeta.value=totalTarjeta.toFixed(2);
		document.form0.montoTarjetaCr.value=totalTarjetaCr.toFixed(2);
		document.form0.total.value=total.toFixed(2);
		document.form0.montoAch.value=totalAch.toFixed(2);
		var label ='';
		<%if(regType.trim().equals("EF")){%> label='EN EFECTIVOS , CHEQUES  ';<%} else if(regType.trim().equals("ACH")){%> label='EN ACH/TRANSFERENCIAS  ';<%}else{%>label='TARJETAS CREDITOS Y DEBITOS  '; <%}%>
		document.form0.observacion.value="TOTAL DE DEPOSITOS EN "+label+total.toFixed(2);

}
function doSearch(value){var tipoDep=document.form0.tipo_deposito.value; var regType='';if(tipoDep=='1')regType='EF';else if(tipoDep=='2')regType='TR';else if(tipoDep=='4')regType='ACH';var fechaDesde	= document.form0.fechaDesde.value;var fechaHasta=document.form0.fechaHasta.value;window.location = '../caja/registro_deposito_new.jsp?fp=<%=fp%>&fg=<%=fg%>&regType='+regType+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE DEPÓSITOS DIARIOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" id="_tblMain">
	<tr>
		<td>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.hidden("venta_bruta",cdo.getColValue("monto"))%>
			<%=fb.hidden("consecutivo",cdo.getColValue("consecutivo_ag"))%>
			<%=fb.hidden("turnos",cdo.getColValue("turnos_dep"))%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("regType",regType)%>
			<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
			<%=fb.hidden("turnosSize",""+alTurnos.size())%>
 				<tr class="TextRow01">
					<td><cellbytelabel>Tipo de Deposito</cellbytelabel></td>
					<td colspan="3">
					<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_con_tipo_deposito where  codigo in(1,2,4) "+(!mode.trim().equals("view")?" and estado='A'":"")+"  order by descripcion asc","tipo_deposito",cdo.getColValue("regType"),true,viewMode,false,0,null,null,"onChange=\"javascript:doSearch(this.value)\"")%>&nbsp;&nbsp;

					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fechaDesde" />
                            <jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
                            <jsp:param name="nameOfTBox2" value="fechaHasta" />
                            <jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
							<jsp:param name="clearOption" value="true" />
                            </jsp:include>
						<%=fb.button("buscar","Buscar",true,false,null,null,"onClick=\"javascript:doSearch('')\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Banco</cellbytelabel></td>
					<td colspan="3">
					<%=fb.textBox("banco",cdo.getColValue("banco"),true,false,true,10)%>
					<%=fb.textBox("name_banco",cdo.getColValue("nombrebanco"),false,false,true,30)%>
					<%=fb.button("addBanco","...",true,(!mode.equalsIgnoreCase("add")),null,null,"onClick=\"javascript:showBanco()\"","Agregar Banco")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
					<td colspan="3">
					<%=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,30)%>
					<%=fb.textBox("name_cuenta",cdo.getColValue("nombrecuenta"),false,false,true,30)%>
					<%//=fb.button("addCuenta","...",true,false,null,null,"onClick=\"javascript:showCuenta()\"","Agregar Cuenta")%></td>
				</tr>


		<%if(mode.trim().equals("add")){%>
		<tr>
			<td colspan="4">
				<div id="_cMain" class="Container">
					<div id="_cContent" class="ContainerContent">
					<table align="center" width="100%" cellpadding="1" cellspacing="1">
					  <tr class="TextHeader">
					  	<td width="25%"><cellbytelabel>Caja</cellbytelabel></td>
						<td width="10%"><cellbytelabel>Fecha De Turno</cellbytelabel></td>
						<td width="20%"><cellbytelabel>Cajer@</cellbytelabel></td>
						<td width="10%"><cellbytelabel>Turno</cellbytelabel></td>
						<%if(regType.trim().equals("EF")){%>
						<td width="15%"><cellbytelabel>Efectivo</cellbytelabel></td>
						<td width="15%"><cellbytelabel>Cheque</cellbytelabel></td>
						<%}else if(regType.trim().equals("ACH")){%>
						<td width="30%"><cellbytelabel>Ach</cellbytelabel></td>
						<%}else{%>
						<td width="09%"><cellbytelabel>Tarjeta DB</cellbytelabel></td>
						<td width="09%"><cellbytelabel>Tarjeta CR</cellbytelabel></td>
						<%}%>
						<td width="09%"><cellbytelabel>Sobrante/Faltante</cellbytelabel></td>
						<!--<td width="09%"><cellbytelabel>Dev. Tarjeta</cellbytelabel></td>
						<td width="09%"><cellbytelabel>Comision En Tarj.</cellbytelabel></td>
						<td width="09%"><cellbytelabel>Transferencias</cellbytelabel></td>
						<td width="09%"><cellbytelabel>Faltante</cellbytelabel></td>
						<td width="08%"><cellbytelabel>Sobrante</cellbytelabel></td>-->
						<td width="05%">&nbsp;<%=fb.checkbox("check","",false,(fg.trim().equals("AUX")||viewMode),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','aplicar',"+alTurnos.size()+",this);setTotal(0)\"","Seleccionar todas los Registros listados!")%></td>
					  </tr>

				<%String caja1 ="",turno="",descCajero="";
  							for (int i=0; i<alTurnos.size(); i++)
							{
								CommonDataObject cdo1  = (CommonDataObject)alTurnos.get(i);
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("caja"+i,cdo1.getColValue("caja"))%>
							<%=fb.hidden("turno"+i,cdo1.getColValue("turno"))%>
							<%//=fb.hidden("turno"+i,cdo1.getColValue("turno"))%>


				<tr class=<%=color%>>

					<td><%=cdo1.getColValue("nombre_caja")%></td>
					<td><%=cdo1.getColValue("fecha")%></td>
					<td><%=cdo1.getColValue("nombre_cajera")%></td>
					<td><%=cdo1.getColValue("turno")%></td>
					<%if(regType.trim().equals("EF")){%>
					<td><%=fb.decBox("montoEfectivo"+i,cdo1.getColValue("efectivo"),false,false,true,5,12.2)%></td>
					<td><%=fb.decBox("montoCheque"+i,cdo1.getColValue("cheque"),false,false,true,5,12.2)%></td>
					<%=fb.hidden("montoTarjeta"+i,"0")%>
					<%=fb.hidden("montoTarjetaCr"+i,"0")%>
					<%=fb.hidden("montoAch"+i,"0")%>
					<%}else if(regType.trim().equals("ACH")){%>
					<td><%=fb.decBox("montoAch"+i,cdo1.getColValue("depAch"),false,false,true,5,12.2)%></td>
					<%=fb.hidden("montoTarjeta"+i,"0")%>
					<%=fb.hidden("montoTarjetaCr"+i,"0")%>
					<%=fb.hidden("montoEfectivo"+i,"0")%>
					<%=fb.hidden("montoCheque"+i,"0")%>
					<%}else{%>
					<%=fb.hidden("montoEfectivo"+i,"0")%>
					<%=fb.hidden("montoCheque"+i,"0")%>
					<%=fb.hidden("montoAch"+i,"0")%>
					<td><%=fb.decBox("montoTarjeta"+i,cdo1.getColValue("tarjetasDb"),false,false,true,5,12.2)%></td>
					<td><%=fb.decBox("montoTarjetaCr"+i,cdo1.getColValue("tarjetasCr"),false,false,true,5,12.2)%></td>
					<%}%>
					<td><%=fb.decBox("diferencia"+i,cdo1.getColValue("diferencia"),false,false,true,5,12.2)%></td>
					<!--<td><%//=fb.decBox("montoDevTarjeta"+i,cdo1.getColValue("montoDevTarjeta"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoComision"+i,cdo1.getColValue("montoComision"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoTransferencia"+i,cdo1.getColValue("depositos"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoFaltante"+i,cdo1.getColValue("faltante"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoSobrante"+i,cdo1.getColValue("sobrante"),false,false,true,5,12.2)%></td>-->
					<td><%=fb.checkbox("aplicar"+i,"S",(cdo1.getColValue("depositar").trim().equals("S"))?true:false,((fg.trim().equals("AUX")&&cdo1.getColValue("depositar").trim().equals("S"))||viewMode),null,null,"onClick=\"javascript:setTotal("+i+")\"")%></td>
 				</tr>
							<%
							}
							%>
				</table>
			</div>
			</div>
		</td>
	</tr><%}else {%>
	<tr class="TextRow01">
			<td colspan="4">TURNOS DEPOSITADOS:<%=fb.textarea("observacion_view",cdo.getColValue("turnos"),false,false,true,60,3,200,"","width:100%","")%></td>
	</tr>
	<%}%>
	<tr>
		<td colspan="4">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">
					  <tr class="TextRow02">
						<td width="25%">TOTALES </td>
						<td width="10%">&nbsp;</td>
						<td width="20%">&nbsp;</td>

						<%if(regType.trim().equals("EF")){%>
						<%=fb.hidden("montoTarjeta","0")%>
						<%=fb.hidden("montoTarjetaCr","0")%>
						<%=fb.hidden("montoAch","0")%>
						<td width="15%">EFECTIVO<%=fb.decBox("montoEfectivo",cdo.getColValue("monto_efectivo"),true,false,true,15,12.2)%>
						<td width="15%">CHEQUES<%=fb.decBox("montoCheque",cdo.getColValue("monto_cheque"),true,false,true,15,12.2)%></td>
						<%}else if(regType.trim().equals("ACH")){%>
						<%=fb.hidden("montoTarjeta","0")%>
						<%=fb.hidden("montoTarjetaCr","0")%>
						<%=fb.hidden("montoEfectivo","0")%>
						<%=fb.hidden("montoCheque","0")%>
						<td width="15%">ACH<%=fb.decBox("montoAch",cdo.getColValue("monto_ach"),true,false,true,15,12.2)%>
						<td width="15%">&nbsp;</td>
						<%}else{%>
						<%=fb.hidden("montoEfectivo","0")%>
						<%=fb.hidden("montoCheque","0")%>
						<%=fb.hidden("montoAch","0")%>
						<td width="15%">TARJETAS DB<%=fb.decBox("montoTarjeta",cdo.getColValue("tarjetasDb"),true,false,true,15,12.2)%></td>
						<td width="15%">TARJETAS CR<%=fb.decBox("montoTarjetaCr",cdo.getColValue("tarjetasCr"),true,false,true,15,12.2)%></td>
						<%}%>
						<!--
						<td width="09%"><%//=fb.decBox("montoTarjeta",cdoTotal.getColValue("tarjetas"),false,false,true,5,12.2)%></td>
						<td width="09%"><%//=fb.decBox("montoDevTarjeta",cdoTotal.getColValue("devTarjeta"),false,false,true,5,12.2)%></td>
						<td width="09%"><%//=fb.decBox("montoComision",cdoTotal.getColValue("comision"),false,false,true,5,12.2)%></td>
						<td width="09%"><%//=fb.decBox("montoTransferencia",cdoTotal.getColValue("depositos"),false,false,true,5,12.2)%></td>
						<td width="09%"><%//=fb.decBox("montoFaltante",cdoTotal.getColValue("faltante"),false,false,true,5,12.2)%></td>
						<td width="09%"><%//=fb.decBox("montoSobrante",cdoTotal.getColValue("sobrante"),false,false,true,5,12.2)%></td>-->
						<td width="06%">&nbsp;</td>
						<td width="20%">&nbsp;</td>
					  </tr>
					   <tr class="TextRow02">
						<%if(!regType.trim().equals("ACH")){%>
						<td colspan="4">TOTALES<%if(regType.trim().equals("EF")){%> EFECTIVO Y CHEQUE <%}else if(regType.trim().equals("ACH")){%> ACH <%}else{%> TARJETAS DB Y CR<%}%></td>
						<%}if(regType.trim().equals("ACH")){%>
						<td colspan="3">TOTALES<%if(regType.trim().equals("EF")){%> EFECTIVO Y CHEQUE <%}else if(regType.trim().equals("ACH")){%> ACH <%}else{%> TARJETAS DB Y CR<%}%></td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.decBox("total",cdo.getColValue("monto"),true,false,(fg.trim().equals("AUX"))?true:false,15,12.2)%></td>
						<td>&nbsp;</td><td>&nbsp;</td>
						<%}else{%>
						<td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.decBox("total",cdo.getColValue("monto"),true,false,(fg.trim().equals("AUX"))?true:false,15,12.2)%></td>
						<%}%>
						<td>&nbsp;</td>
					  </tr>
			</table>
		</td>
	</tr>

				<tr class="TextRow01">
						<td width="20%">Observaciones</td>
						<td width="20%">&nbsp;</td>
						<td width="20%">Creado Por</td>
						<td width="40%">Fecha</td>
				</tr>
				<tr class="TextRow01">
						<td colspan="2" rowspan="2"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,60,3,200,"","width:100%","")%></td>
						<td rowspan="2"><%=fb.textBox("usuario",cdo.getColValue("usuario"),false,false,true,15)%></td>
						<td><%=fb.textBox("fecha",cdo.getColValue("fecha"),false,false,true,15)%></td>
				 </tr>
				 <tr class="TextRow01">
				 	<td><%=fb.button("addComprobante","Comprobante",false,false,null,null,"onClick=\"javascript:showComprobante()\"","Comprobante de registro de Depósito")%></td>
				 </tr>
	<%//fb.appendJsValidation("\n\tif (!VerificaTarjeta()) error++;\n");%>
	<%//fb.appendJsValidation("\n\tif (!CheckTurno()) error++;\n");%>
	<%fb.appendJsValidation("\n\tif (!CheckFecha()) error++;\n");%>
	<%//fb.appendJsValidation("\n\tif (!CheckMonto()) error++;\n");%>

	<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						<!--< ---><%=fb.radio("saveOption","N")%>Crear Otro
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String monto="0";
	banco = request.getParameter("banco");
	cuenta = request.getParameter("cuenta");
	caja = request.getParameter("caja");
	compania = request.getParameter("compania");
	fp = request.getParameter("fp");
	caja = request.getParameter("caja");

					cdo = new CommonDataObject();
					cdo.setTableName("TBL_CON_MOVIM_BANCARIO");

					cdo.addColValue("tipo_dep",request.getParameter("tipo_deposito"));
 					monto = request.getParameter("total");

					cdo.addColValue("MONTO",monto);
					cdo.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
					cdo.addColValue("FECHA_MODIFICACION",cDateTime);

					cdo.addColValue("DESCRIPCION","DEPOSITO POR CIERRE DE CAJAS/TURNOS");

					int keySize = Integer.parseInt(request.getParameter("turnosSize"));
					String turnos="",montoEfectivo="",montoCheque="",diferencia="",montoTarjeta="",montoTarjetaCr="",montoAch="";
					for (int i=0; i<keySize; i++)
					{
						if (request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))
						{
							if(turnos.trim().equals(""))turnos =request.getParameter("turno"+i);
							else turnos +="|"+request.getParameter("turno"+i);

							if(montoEfectivo.trim().equals(""))montoEfectivo =request.getParameter("montoEfectivo"+i);
							else montoEfectivo +="|"+request.getParameter("montoEfectivo"+i);

							if(montoCheque.trim().equals(""))montoCheque =request.getParameter("montoCheque"+i);
							else montoCheque +="|"+request.getParameter("montoCheque"+i);
							if(montoTarjeta.trim().equals(""))montoTarjeta =request.getParameter("montoTarjeta"+i);
							else montoTarjeta +="|"+request.getParameter("montoTarjeta"+i);
							if(diferencia.trim().equals(""))diferencia =request.getParameter("diferencia"+i);
							else diferencia +="|"+request.getParameter("diferencia"+i);
							if(montoTarjetaCr.trim().equals(""))montoTarjetaCr =request.getParameter("montoTarjetaCr"+i);
							else montoTarjetaCr +="|"+request.getParameter("montoTarjetaCr"+i);
							if(montoAch.trim().equals(""))montoAch =request.getParameter("montoAch"+i);
							else montoAch +="|"+request.getParameter("montoAch"+i);
						}
					}

					cdo.addColValue("monto_cheque",montoCheque);
					cdo.addColValue("monto_efectivo",montoEfectivo);
					cdo.addColValue("turnos_cierre",turnos);
					cdo.addColValue("dep_conta","S");
					cdo.addColValue("diferencia",diferencia);
					cdo.addColValue("monto_tarjeta",montoTarjeta);
					cdo.addColValue("monto_tarjetacr",montoTarjetaCr);
					cdo.addColValue("monto_ach",montoAch);
					cdo.addColValue("reg_type",regType);

                    if(request.getParameter("observacion") !=null && !request.getParameter("observacion").trim().equals(""))
					cdo.addColValue("OBSERVACION",request.getParameter("observacion")+" --> TURNOS "+turnos);
					else cdo.addColValue("observacion","DEPOSITO DE EFECTIVO Y CHEQUES - -->TURNOS "+turnos);

					if (mode.equalsIgnoreCase("add"))
					{
						cdo.setWhereClause("compania="+request.getParameter("compania")+" and cuenta_banco='"+request.getParameter("cuenta")+"' and banco='"+request.getParameter("banco")+"' and tipo_movimiento='1'");
							cdo.addColValue("F_MOVIMIENTO",request.getParameter("fecha"));
							cdo.addColValue("CUENTA_BANCO",request.getParameter("cuenta"));
							cdo.addColValue("BANCO",request.getParameter("banco"));
							cdo.addColValue("COMPANIA",request.getParameter("compania"));
							cdo.addColValue("ESTADO_TRANS","T");
							cdo.addColValue("TIPO_MOVIMIENTO","1");//deposito
							cdo.addColValue("LADO","DB");//lado debito
							cdo.addColValue("ESTADO_DEP","DT");
							//cdo.addColValue("CAJA",request.getParameter("caja"));

							cdo.addColValue("USUARIO_CREACION",(String) session.getAttribute("_userName"));
							cdo.addColValue("FECHA_CREACION",cDateTime);

							cdo.setAutoIncWhereClause("compania="+request.getParameter("compania")+" and cuenta_banco='"+request.getParameter("cuenta")+"' and banco='"+request.getParameter("banco")+"' and tipo_movimiento='1'");
							cdo.setAutoIncCol("consecutivo_ag");
							cdo.addPkColValue("consecutivo_ag","");

							ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							SQLMgr.insert(cdo);
							consecutivo = SQLMgr.getPkColValue("consecutivo_ag");
							ConMgr.clearAppCtx(null);
					}
					/*else if (mode.equalsIgnoreCase("edit"))
					{
						 cdo.addColValue("DEP_MODIF","S");
						 consecutivo = request.getParameter("consecutivo");
						 cdo.setWhereClause("compania="+request.getParameter("compania")+" and cuenta_banco='"+request.getParameter("cuenta")+"' and banco='"+request.getParameter("banco")+"' and tipo_movimiento='1' and consecutivo_ag="+consecutivo);
						 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						 SQLMgr.update(cdo);
						 ConMgr.clearAppCtx(null);
					}*/


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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/transacciones_depositos_list.jsp?fp="+fp))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/transacciones_depositos_list.jsp?fp="+fp)%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/transacciones_depositos_list.jsp?fp=<%=fp%>';
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
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&fp=<%=fp%>&fg=<%=fg%>&compania=<%=compania%>&caja=<%=caja%>&banco=<%=banco%>&cuenta=<%=cuenta%>&consecutivo=<%=consecutivo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
