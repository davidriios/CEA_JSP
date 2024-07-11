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
ArrayList al = new ArrayList();
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
String fpOtros = "Otros";
try {fpOtros = java.util.ResourceBundle.getBundle("issi").getString("fpOtros"); } catch(Exception e){ fpOtros = "Otros";}
String fechaDesde = request.getParameter("fechaDesde");
String fechaHasta = request.getParameter("fechaHasta");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (fp == null) fp = "deposito";
if (fg == null) fg = "AUX";
if (regType == null) regType = "EF";

CommonDataObject cdoEnc = (CommonDataObject) SQLMgr.getData("select to_char(sysdate-3,'dd/mm/yyyy') fechaDesde from dual ");

if (fechaDesde == null){if(cdoEnc!=null && !cdoEnc.getColValue("fechaDesde").equals("")) fechaDesde = cdoEnc.getColValue("fechaDesde");}
if (fechaHasta == null) fechaHasta = cDateTime.substring(0,10);

if(mode.equals("view")) viewMode=true;
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

sbSql.append("select x.* ,");

if(regType.trim().equals("EF")){
sbSql.append(" (nvl(x.efectivo,0)+nvl(x.cheque,0)) total_cierre, case when (nvl(x.efectivo,0)+nvl(x.cheque,0))-nvl(x.otros,0) > (nvl(x.total_cash,0)+nvl(x.total_cheque,0)) then (nvl(x.efectivo,0)+nvl(x.cheque,0)) -nvl(x.otros,0)-(nvl(x.total_cash,0)+nvl(x.total_cheque,0))  else 0 end as faltante,case when (nvl(x.efectivo,0)+nvl(x.cheque,0)-nvl(x.otros,0)) < (nvl(x.total_cash,0)+nvl(x.total_cheque,0)) then (nvl(x.total_cash,0)+nvl(x.total_cheque,0)-nvl(x.otros,0))-(nvl(x.efectivo,0)+nvl(x.cheque,0)) else 0 end as sobrante ");}
else if(regType.trim().equals("ACH"))
{
sbSql.append(" nvl(x.depAch,0) as total_cierre, case when nvl(x.depAch,0) > nvl(x.depositos,0) then nvl(x.depAch,0) - nvl(x.depositos,0) else 0 end as faltante,case when nvl(x.depAch,0) < nvl(x.depositos,0) then nvl(x.depositos,0)-nvl(x.depAch,0) else 0 end as sobrante ");
}
else
{
sbSql.append(" (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) as total_cierre, case when (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) > nvl(x.tarjetasCierre,0) then (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) - nvl(x.tarjetasCierre,0) else 0 end as faltante,case when (nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) < nvl(x.tarjetasCierre,0) then nvl(x.tarjetasCierre,0)-(nvl(x.tarjetasDb,0)+nvl(x.tarjetasCr,0)) else 0 end as sobrante ");
}

sbSql.append(" from (select a.session_id turno, nvl(a.total_cash,0) total_cash , nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_EFECTIVO'),0) as efectivo,nvl(a.total_cheque,0)as total_cheque,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_CHEQUE'),0) as cheque,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TARJETAS_DB'),0) as tarjetasDb,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TARJETAS_CR'),0) as tarjetasCr,nvl(a.total_accdeposit,0) as depositos, nvl(a.total_creditcard,0)+nvl(a.total_debitcard,0) as tarjetasCierre,nvl(a.final_total,0)as final_total,/*nvl((select nvl(sum(nvl(tp.pago_total,0)),0) as pago_total from tbl_cja_transaccion_pago tp where tp.compania = a.company_id and tp.turno = a.session_id and (tp.rec_status = 'A' or (tp.rec_status = 'I' and tp.turno <> tp.turno_anulacion))),0) total_cja,*/ nvl(a.otros,0)as otros,tc.cod_caja caja,to_char(t.fecha, 'dd/mm/yyyy') fecha,c.nombre nombre_cajera, d.descripcion nombre_caja,0 montoDevTarjeta,a.depositar,nvl(fn_cja_total_fp(a.company_id,a.session_id,'FORMA_PAGO_TRANS_ACH'),0) as depAch");
if(regType.trim().equals("EF"))sbSql.append(" ,nvl(a.diferencia,-0) ");
else if(regType.trim().equals("TR"))sbSql.append(" ,nvl(a.dif_tarjeta,-0) ");
else if(regType.trim().equals("ACH"))sbSql.append(" ,nvl(a.dif_ach,-0) ");
sbSql.append(" as diferencia from tbl_cja_sesdetails a,tbl_cja_turnos t,tbl_cja_turnos_x_cajas tc, tbl_cja_cajera c, tbl_cja_cajas d  where a.session_id =t.codigo and a.company_id =t.compania and a.company_id =");
 sbSql.append((String) session.getAttribute("_companyId"));
 
 	if (!fechaDesde.trim().equals("")){ sbSql.append(" and t.fecha >=to_date('");sbSql.append(fechaDesde);sbSql.append("','dd/mm/yyyy')");}
	if (!fechaHasta.trim().equals("")){ sbSql.append(" and t.fecha <=to_date('");sbSql.append(fechaHasta);sbSql.append("','dd/mm/yyyy')");}

 
sbSql.append(" and tc.cod_turno = t.codigo and t.cja_cajera_cod_cajera = c.cod_cajera and tc.cod_caja = d.codigo and tc.compania = d.compania and tc.compania = c.compania and not exists (select null from tbl_cja_turno_cierre y where y.estado = 'A' and y.turno = a.session_id and y.compania = a.company_id and y.reg_type ='");
sbSql.append(regType);
sbSql.append("') /*and  not exists (select 1 from (select to_number(nvl(column_value,-1)) turnos  from table( select split((select join(cursor(select nvl(mb.turnos_cierre,'-1') from tbl_con_movim_bancario mb where turnos_cierre is not null and reg_type ='");
sbSql.append(regType);
sbSql.append("' and compania =");
sbSql.append((String) session.getAttribute("_companyId"));
//select join(cursor(select nvl(mb.turnos_cierre,'-1') from tbl_con_movim_bancario mb where mb.compania =1 and turnos_cierre is not null and compania =1),'|') from dual
sbSql.append("),'|') from dual ),'|') from dual )) y where  y.turnos =a.session_id)*/ ");

sbSql.append(" ) x ");
if(regType.trim().equals("EF")){sbSql.append(" where  ((nvl(efectivo,0) + nvl(cheque,0))<> 0  or  (nvl(total_cash,0)+ nvl(total_cheque,0)) <> 0) ");}
else if(regType.trim().equals("ACH")){sbSql.append(" where  (nvl(depAch,0) <> 0  or  nvl(depositos,0) <> 0) ");}
else sbSql.append(" where  ((nvl(tarjetasCr,0) + nvl(tarjetasDb,0))<> 0  or nvl(tarjetasCierre,0)<> 0)");
sbSql.append("order by /*x.caja,*/ x.turno desc ");

alTurnos = SQLMgr.getDataList(sbSql.toString());
}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Registro de Depósitos- '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){if(document.getElementById('_cMain'))resetFrameHeight(document.getElementById('_cMain'),xHeight,400);}
function doSearch(value){var tipoDep=document.form0.tipo_deposito.value; var regType='';if(tipoDep=='1')regType='EF';else if(tipoDep=='2')regType='TR';else if(tipoDep=='4')regType='ACH';var fechaDesde	= document.form0.fechaDesde.value;var fechaHasta=document.form0.fechaHasta.value;window.location = '../caja/reg_turnos_x_depositar.jsp?fp=<%=fp%>&fg=<%=fg%>&regType='+regType+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta;}
function printTurnos(fg)
{
var tipoDep = eval('document.form0.tipo_deposito').value;var fechaDesde	= document.form0.fechaDesde.value;var fechaHasta	= document.form0.fechaHasta.value;
abrir_ventana1('../caja/print_turnos_x_depositar.jsp?regType=<%=regType%>&tipoDep='+tipoDep+'&fg='+fg+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta);
//print_turnos_x_depositar.jsp
}
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
			<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
			<%=fb.hidden("turnosSize",""+alTurnos.size())%>
			<%=fb.hidden("regType",regType)%>
 				
		<tr>
			<td colspan="4" class="TextHeader">TURNO PENDIENTES DE DEPOSITOS</td>
		</tr>
		<tr class="TextRow01">
					<td>Fecha 
					 <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fechaDesde" />
                            <jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
                            <jsp:param name="nameOfTBox2" value="fechaHasta" />
                            <jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
							<jsp:param name="clearOption" value="true" />
                            </jsp:include><cellbytelabel>Tipo de Deposito</cellbytelabel></td>
					<td colspan="2"> 
					<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_con_tipo_deposito where  codigo in(1,2,4) "+(!mode.trim().equals("view")?" and estado='A'":"")+"  order by descripcion asc","tipo_deposito",cdo.getColValue("regType"),true,viewMode,false,0,null,null,"onChange=\"javascript:doSearch(this.value)\"")%>
					
					<%=fb.button("buscar","Buscar",true,false,null,null,"onClick=\"javascript:doSearch('')\"")%>
					</td>
					<td><%=fb.button("imprimir2","TURNOS A DEPOSITAR ",true,false,null,null,"onClick=\"javascript:printTurnos('DEP')\"")%>
						<%=fb.button("imprimir","TURNOS PARA NO DEPOSITAR ",true,false,null,null,"onClick=\"javascript:printTurnos('DP')\"")%>
					</td>
				</tr>
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
						<td width="15%"><cellbytelabel>Total Sist.</cellbytelabel></td>
						<%if(regType.trim().equals("EF")){%>
						<td width="15%"><cellbytelabel>Efectivo</cellbytelabel></td>
						<td width="15%"><cellbytelabel>Cheque</cellbytelabel></td>
						<td width="15%"><cellbytelabel><cellbytelabel><%=fpOtros%></cellbytelabel></cellbytelabel></td>
						<%}else if(regType.trim().equals("ACH")){%>
						<td width="15%"><cellbytelabel>Ach</cellbytelabel></td>
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
						<td width="05%"><authtype type='50'>No Depositar<br><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','aplicar',"+alTurnos.size()+",this)\"","Seleccionar todas los Registros listados!")%></authtype></td>
					  </tr>

				<%String caja1 ="",turno="",descCajero="",diferencia="0";
  							for (int i=0; i<alTurnos.size(); i++)
							{   diferencia="0";
								CommonDataObject cdo1  = (CommonDataObject)alTurnos.get(i);
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							System.out.println(" DIFERENCIA  ============ "+cdo1.getColValue("diferencia")+" turno ==="+cdo1.getColValue("turno"));
								if(cdo1.getColValue("diferencia") !=null && !cdo1.getColValue("diferencia").trim().equals("")&& !cdo1.getColValue("diferencia").trim().equals("-0") )diferencia = cdo1.getColValue("diferencia");
								
							 
								
								/*else{
								if(cdo1.getColValue("faltante") !=null && !cdo1.getColValue("faltante").trim().equals("")&& !cdo1.getColValue("faltante").trim().equals("0"))
								diferencia = cdo1.getColValue("faltante");
								else if(cdo1.getColValue("sobrante") !=null && !cdo1.getColValue("sobrante").trim().equals("")&& !cdo1.getColValue("sobrante").trim().equals("0"))
								diferencia = cdo1.getColValue("sobrante");}*/
							%>
							<%=fb.hidden("caja"+i,cdo1.getColValue("caja"))%>
							<%=fb.hidden("turno"+i,cdo1.getColValue("turno"))%>
							<%=fb.hidden("depositar"+i,cdo1.getColValue("depositar"))%>


				<tr class=<%=color%>>

					<td><%=cdo1.getColValue("nombre_caja")%></td>
					<td><%=cdo1.getColValue("fecha")%></td>
					<td><%=cdo1.getColValue("nombre_cajera")%></td>
					<td><%=cdo1.getColValue("turno")%></td>
					<td><%=fb.decBox("total_cja"+i,cdo1.getColValue("total_cierre"),false,false,true,5,12.2)%>
					<%if(regType.trim().equals("EF")){%>
					<td><%=fb.decBox("montoEfectivo"+i,cdo1.getColValue("efectivo"),false,false,true,5,12.2)%>
					<td><%=fb.decBox("montoCheque"+i,cdo1.getColValue("cheque"),false,false,true,5,12.2)%></td>
					<td><%=fb.decBox("montoOtros"+i,cdo1.getColValue("otros"),false,false,true,5,12.2)%></td>
					<%}else if(regType.trim().equals("ACH")){%>
					<td><%=fb.decBox("montoAch"+i,cdo1.getColValue("depAch"),false,false,true,5,12.2)%>
					<%}else{%>
					<td><%=fb.decBox("montoTarjeta"+i,cdo1.getColValue("tarjetasDb"),false,false,true,5,12.2)%></td>
					<td><%=fb.decBox("montoTarjetaCr"+i,cdo1.getColValue("tarjetasCr"),false,false,true,5,12.2)%></td>
					<%}%>					
					<td><%=fb.decBox("diferencia"+i,diferencia,false,false,false,5,12.2)%></td>
					<!--<td><%//=fb.decBox("montoDevTarjeta"+i,cdo1.getColValue("montoDevTarjeta"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoComision"+i,cdo1.getColValue("montoComision"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoTransferencia"+i,cdo1.getColValue("depositos"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoFaltante"+i,cdo1.getColValue("faltante"),false,false,true,5,12.2)%></td>
					<td><%//=fb.decBox("montoSobrante"+i,cdo1.getColValue("sobrante"),false,false,true,5,12.2)%></td>-->
					<td><authtype type='50'><%=fb.checkbox("aplicar"+i,"S",(cdo1.getColValue("depositar").trim().equals("N")),false,null,null,"")%></authtype></td>
 				</tr>
							<%
							}
							%>
				</table>
			</div>
			</div>
		</td>
	<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						<!-- <%=fb.radio("saveOption","N")%>Crear Otro--->
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:seBaction('"+fb.getFormName()+"',this.value)\"")%>
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
	int keySize = Integer.parseInt(request.getParameter("turnosSize"));
	al.clear();
	for (int i=0; i<keySize; i++)
	{
		cdo = new CommonDataObject();
		System.out.println(" aplicar ==="+request.getParameter("aplicar"+i)+" depositar ======= "+request.getParameter("depositar"+i));
		if ((request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))||(request.getParameter("diferencia"+i)!= null && !request.getParameter("diferencia"+i).trim().equals("")))
		{
			
			cdo.setTableName("tbl_cja_sesdetails");
			cdo.setWhereClause("session_id="+request.getParameter("turno"+i)+" and company_id ="+request.getParameter("compania"));
			//cdo.addColValue("company_id",request.getParameter("compania"));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",cDateTime);
			if(regType.trim().equals("EF"))cdo.addColValue("diferencia",request.getParameter("diferencia"+i));
			if(regType.trim().equals("TR"))cdo.addColValue("dif_tarjeta",request.getParameter("diferencia"+i));
			if(regType.trim().equals("ACH"))cdo.addColValue("dif_ach",request.getParameter("diferencia"+i));
			if ((request.getParameter("depositar"+i)!= null && !request.getParameter("depositar"+i).equalsIgnoreCase("")))cdo.addColValue("depositar",request.getParameter("depositar"+i)); 
			if ((request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S")))cdo.addColValue("depositar","N");
			else cdo.addColValue("depositar","S");
			
			 
			cdo.setAction("U");
			al.add(cdo);
		}
	}
	
	if (al.size() == 0)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_cja_sesdetails");
		cdo.setWhereClause("session_id=-2 and company_id ="+request.getParameter("compania"));
		cdo.setAction("I");
		al.add(cdo);
	}

	//ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
	//ConMgr.clearAppCtx(null);

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
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/transacciones_depositos_list.jsp?fp="+fp)%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/caja/transacciones_depositos_list.jsp?fp=<%=fp%>';
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
	setTimeout('addMode()',500);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&fp=<%=fp%>&fg=<%=fg%>&regType=<%=regType%>&fechaDesde=<%=fechaDesde%>&fechaHasta=<%=fechaHasta%>'; 
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
