<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.expediente.BalanceHidrico"%>
<%@ page import="issi.expediente.DetalleBalance"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="LAdmin" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="LElim" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="BHMgr" scope="session" class="issi.expediente.BalanceHidricoMgr"/>
<jsp:useBean id="iBalance" scope="session" class="java.util.Hashtable"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
BHMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
BalanceHidrico balance = new BalanceHidrico();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String sql = "";
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha_eval = request.getParameter("fecha_eval");
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String filter = "", op="", appendFilter = "";
int size = 0;
int LElimLastLineNo = 0;
int LAdminLastLineNo = 0;
int balLastLineNo = 0;

if (desc == null) desc = "";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if (seccion == null) throw new Exception("La Secci�n no es v�lida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisi�n no es v�lida. Por favor intente nuevamente!");
if (request.getParameter("LAdminLastLineNo") != null) LAdminLastLineNo = Integer.parseInt(request.getParameter("LAdminLastLineNo"));
if (request.getParameter("LElimLastLineNo") != null) LElimLastLineNo = Integer.parseInt(request.getParameter("LElimLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	//sql="select to_char(a.fecha,'dd/mm/yyyy') as fecha from tbl_sal_balance_hidrico where pac_id="+pacId+" and secuencia="+noAdmision+" order by fecha_creacion desc";
	sql = "select to_char(a.fecha,'dd/mm/yyyy') as fecha,nvl(b.ingreso,0)ingreso,nvl(b.egreso,0)egreso, nvl(decode(sign(b.balance),1,'+'||b.balance,''||b.balance),0) as balance from tbl_sal_balance_hidrico a, (select z.pac_id, z.adm_secuencia, z.fecha, sum(decode(y.tipo_liquido,'I',z.cantidad,'E',-1*z.cantidad,0)) as balance , sum(decode(y.tipo_liquido,'I',z.cantidad,0))ingreso,sum(decode(y.tipo_liquido,'E',z.cantidad,0))egreso from tbl_sal_detalle_balance z, tbl_sal_via_admin y where z.pac_id="+pacId+" and z.adm_secuencia="+noAdmision+" and z.via_administracion=y.codigo group by z.pac_id, z.adm_secuencia, z.fecha) b where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.pac_id=b.pac_id and a.secuencia=b.adm_secuencia and a.fecha=b.fecha order by a.fecha_creacion desc";
	al2 = SQLMgr.getDataList(sql);

	balLastLineNo = al2.size();
	iBalance.clear();
	for (int i=1; i<=al2.size(); i++) {
		cdo = (CommonDataObject) al2.get(i-1);
		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;
		cdo.addColValue("key",key);

		if (cdo.getColValue("fecha").equals(cDateTime.substring(0,10))) {
			cdo.addColValue("OBSERVACION","EVALUACION ACTUAL");
			op = "0";
		} else {
			cdo.addColValue("OBSERVACION","EVALUACION "+ (1+balLastLineNo - i));
			appendFilter = "1";
		}
		try {
			iBalance.put(key, cdo);
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}//for

	if(al2.size() == 0) {
		cdo = new CommonDataObject();
		cdo.addColValue("FECHA",cDateTime.substring(0,10));
		cdo.addColValue("OBSERVACION","EVALUACION ACTUAL");
		cdo.addColValue("ingreso","0");
		cdo.addColValue("egreso","0");
		cdo.addColValue("balance","0");
		balLastLineNo++;
		if (balLastLineNo < 10) key = "00" + balLastLineNo;
		else if (balLastLineNo < 100) key = "0" + balLastLineNo;
		else key = "" + balLastLineNo;
		cdo.addColValue("key",key);
		try {
			iBalance.put(key, cdo);
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	if (fecha_eval != null) {
		filter = fecha_eval;
		if (fecha_eval.equals(cDateTime.substring(0,10))) {
			modeSec="edit";
			if (!viewMode) viewMode = false;
		}
	} else filter = cDateTime.substring(0,10);

	sql="SELECT a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo_personal as tipoPersonal, a.personal_g as personalG, a.emp_provincia as empProvincia, a.emp_sigla as empSigla, a.emp_tomo as empTomo, a.emp_asiento as empAsiento, a.emp_compania as empCompania, a.personal as personal, a.usuario_creacion as usuarioCeacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion, a.emp_id as empId FROM TBL_SAL_BALANCE_HIDRICO a where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy')";
	//System.out.println("sql==="+sql);
	balance = (BalanceHidrico) sbb.getSingleRowBean(ConMgr.getConnection(), sql, BalanceHidrico.class);

	if (balance == null) {
		balance = new BalanceHidrico();
		balance.setFecha(cDateTime.substring(0,10));
		balance.setUsuarioCreacion(UserDet.getUserName());
		balance.setFechaCreacion(cDateTime);
		balance.setUsuarioModificacion(UserDet.getUserName());
		balance.setFechaModificacion(cDateTime);
		balance.setCodigo("0");
		balance.setEmpCompania((String) session.getAttribute("_companyId"));
		if (!viewMode) modeSec = "add";
	} else if (!viewMode) modeSec = "edit";

	if (change == null) {
		LAdmin.clear();
		LElim.clear();
		sql="SELECT to_char(b.fecha,'dd/mm/yyyy') as fecha, b.cod_balance as codBalance, b.via_administracion as viaAdministracion, b.codigo as codigo, to_char(b.hora,'hh12:mi:ss am') as hora, b.fluido as fluido,b.peso as peso, b.cantidad as cantidad, b.unidad as unidad, b.observacion as observacion, b.seleccionar as seleccionar, v.descripcion as descripcion, v.tipo_liquido as tipoLiquido FROM TBL_SAL_DETALLE_BALANCE b ,tbl_sal_via_admin v where b.pac_id="+pacId+" and b.adm_secuencia="+noAdmision+"and v.codigo=b.via_administracion and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy') order by to_date(to_char(b.fecha,'dd/mm/yyyy')||' '||to_char(b.hora,'hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss')";

		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleBalance.class);
		//System.out.println("sqldet==="+sql);
		for (int i=1; i<=al.size(); i++) {
			try {
				DetalleBalance newBal = (DetalleBalance) al.get(i-1);
				if (newBal.getTipoLiquido().equalsIgnoreCase("I")) {
					LAdminLastLineNo++;
					if (LAdminLastLineNo < 10) key = "00" + LAdminLastLineNo;
					else if (LAdminLastLineNo < 100) key = "0" + LAdminLastLineNo;
					else key = "" + LAdminLastLineNo;
					LAdmin.put(key, al.get(i-1));
				} else if(newBal.getTipoLiquido().equalsIgnoreCase("E")) {
					LElimLastLineNo++;
					if (LElimLastLineNo < 10) key = "00" + LElimLastLineNo;
					else if (LElimLastLineNo < 100) key = "0" + LElimLastLineNo;
					else key = "" + LElimLastLineNo;
					LElim.put(key, al.get(i-1));
				}
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
		}//for

		if (al.size() == 0 || (LAdmin.size()==0 || LElim.size() == 0)) {
			//if (!viewMode) mode = "add";
			DetalleBalance newBalance = new DetalleBalance();
			newBalance.setHora(cDateTime.substring(11));
			newBalance.setFecha(balance.getFecha());
			newBalance.setCodBalance(balance.getCodigo());
			newBalance.setCodigo("0");
			newBalance.setUnidad("CC");

			LAdminLastLineNo++;
			LElimLastLineNo++;
			if (LAdminLastLineNo < 10) key = "00" + LAdminLastLineNo;
			else if (LAdminLastLineNo < 100) key = "0" + LAdminLastLineNo;
			else key = "" + LAdminLastLineNo;
			try {
				if (LAdmin.size() == 0) LAdmin.put(key, newBalance);
				if (LElim.size() == 0) LElim.put(key,newBalance);
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
		}//else if (!viewMode) mode = "edit";

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - Balance Hidrico - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function addVia(bal,tab){abrir_ventana1('../expediente/via_admin_list.jsp?fp=balHidrico&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo<%=LElimLastLineNo%>&LAdminLastLineNo<%=LAdminLastLineNo%>&bal='+bal+'&tab='+tab);}
function verControl(k){
  var fecha_e=eval('document.listado.fecha_evaluacion'+k).value;
  var estadoAtencion = $("#estadoAtencion", parent.document).val() || '';
  var modeSec = 'view';
  if (estadoAtencion == 'P') modeSec = '';
  if(fecha_e=='<%=cDateTime.substring(0,10)%>') modeSec='';
  window.location='../expediente/exp_balance_hidrico.jsp?&modeSec='+modeSec+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fecha_eval='+fecha_e;
}
function setHeight(){newHeight();}
function getHorario(ddl){var selVal=ddl.options[ddl.selectedIndex].value;if(selVal=='todos'){document.getElementById('rangoFecha').style.display='';}else{document.getElementById('rangoFecha').style.display='none';}return selVal;}
function imprimir(){var horario=getHorario(document.listado.horario);var fecha=document.form0.balFechaIn.value;var from=document.listado.from.value;var to=document.listado.to.value;if(from==null||from==undefined||to==null||to==undefined){from='';to='';}abrir_ventana1('../expediente/print_balance_hidrico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&desc=<%=desc%>&horario='+horario+'&from='+from+'&to='+to);}
function imprimirChart(){var horario=getHorario(document.listado.horario);var fecha=document.form0.balFechaIn.value;var from=document.listado.from.value;var to=document.listado.to.value;if(from==null||from==undefined||to==null||to==undefined){from='';to='';}abrir_ventana1('../expediente/print_balance_hidrico_chart.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&desc=<%=desc%>&horario='+horario+'&from='+from+'&to='+to);}
function imprimirBalanceDet(){var fecha=document.form0.balFechaIn.value;abrir_ventana1('../expediente/print_balance_hidrico_ingresos_egresos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fecha='+fecha);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();setHeight();checkViewMode();getHorario(document.listado.horario);}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200,75);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("desc",desc)%>
		<tr>
			<td>
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr>
					<td align="right" colspan="2">
						<cellbytelabel id="4">Horario</cellbytelabel>: <%=fb.select("horario","todos=TODOS,_24h=ULTIMAS 24/H,turnoActual=TURNO ACTUAL","",false,false,0,"Text10",null,"onChange=\"getHorario(this)\"",null," ")%>
						<a href="javascript:imprimirBalanceDet()" class="Link00">[ <cellbytelabel id="1">Ver Balance</cellbytelabel> ]</a>
						<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="3">Imprimir Evaluaci&oacute;n</cellbytelabel> ]</a>
						<a href="javascript:imprimirChart()" class="Link00">[ <cellbytelabel id="6">Imprimir Gr&aacute;fica</cellbytelabel> ]</a>
					</td>
				</tr>
				<tr>
					<td align="right" colspan="2">
						<span style="text-align:right; display:none;" id="rangoFecha">
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2"/>
							<jsp:param name="nameOfTBox1" value="from"/>
							<jsp:param name="valueOfTBox1" value=""/>
							<jsp:param name="nameOfTBox2" value="to"/>
							<jsp:param name="valueOfTBox2" value=""/>
							<jsp:param name="fieldClass" value="Text10"/>
							<jsp:param name="buttonClass" value="Text10"/>
							<jsp:param name="clearOption" value="true"/>
							</jsp:include>
						</span>
					</td>
				</tr>
				<tr class="TextHeader">
					<td align="center" colspan="2"><cellbytelabel id="7">LISTADO DE EVALUACIONES</cellbytelabel></td>
				</tr>
				</table>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
							<table width="100%" cellpadding="1" cellspacing="0">
								<tr class="TextHeader">
									<td width="15%"><cellbytelabel id="8">Fecha</cellbytelabel></td>
									<td width="25%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></td>
									<td width="10%"><cellbytelabel id="10">Admin</cellbytelabel>.</td>
									<td width="10%"><cellbytelabel id="11">Elim</cellbytelabel>.</td>
									<td width="10%"><cellbytelabel id="12">Balance</cellbytelabel></td>
									<td width="15%"><cellbytelabel id="13">Tet</cellbytelabel></td>
									<td width="15%">&nbsp;</td>
								</tr>
								<%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
								<%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
								<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')" style="cursor:pointer" onClick="javascript:verControl(0)" >
									<td><%=cDateTime.substring(0,10)%></td>
									<td><cellbytelabel id="14">Evaluaci&oacute;n Actual</cellbytelabel></td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
								<%}
al2 = CmnMgr.reverseRecords(iBalance);
for (int i=1; i<=iBalance.size(); i++)
{
	key = al2.get(i-1).toString();
	cdo = (CommonDataObject) iBalance.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>
								<%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
								<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verControl(<%=i%>)" >
									<td><%=cdo.getColValue("fecha")%></td>
									<td><%=cdo.getColValue("observacion")%></td>
									<td><%=cdo.getColValue("ingreso")%></td>
									<td><%=cdo.getColValue("egreso")%></td>
									<td><%=cdo.getColValue("balance")%></td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
								<%
}
%>
							</table>
</div>
</div>
				</td>
		</tr>
<%=fb.formEnd(true)%>



		<tr class="TextRow01">
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">


<!-- TAB0 DIV START HERE-->

<div class = "dhtmlgoodies_aTab">

				<table width="100%" cellpadding="1" cellspacing="1" >
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("adminSize",""+LAdmin.size())%>
<%=fb.hidden("elimSize",""+LElim.size())%>
<%=fb.hidden("LAdminLastLineNo",""+LAdminLastLineNo)%>
<%=fb.hidden("LElimLastLineNo",""+LElimLastLineNo)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("codigo",balance.getCodigo())%>
<%=fb.hidden("tipoPersonal",balance.getTipoPersonal())%>
<%=fb.hidden("personalG",balance.getPersonalG())%>
<%=fb.hidden("empProvincia",balance.getEmpProvincia())%>
<%=fb.hidden("empSigla",balance.getEmpSigla())%>
<%=fb.hidden("empTomo",balance.getEmpTomo())%>
<%=fb.hidden("empAsiento",balance.getEmpAsiento())%>
<%=fb.hidden("empCompania",balance.getEmpCompania())%>
<%=fb.hidden("personal",balance.getPersonal())%>
<%=fb.hidden("usuarioCreacion",balance.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",balance.getFechaCreacion())%>
<%=fb.hidden("usuarioModificacion",balance.getUsuarioModificacion())%>
<%=fb.hidden("fechaModificacion",balance.getFechaModificacion())%>
<%=fb.hidden("empId",balance.getEmpId())%>
<%=fb.hidden("desc",desc)%>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="8">Fecha</cellbytelabel></td>
					<td>
              <jsp:include page="../common/calendar.jsp" flush="true">
              <jsp:param name="noOfDateTBox" value="1"/>
              <jsp:param name="clearOption" value="true"/>
              <jsp:param name="nameOfTBox1" value="balFechaIn"/>
              <jsp:param name="valueOfTBox1" value="<%=balance.getFecha()%>"/>
              <jsp:param name="readonly" value="<%=(modeSec.equalsIgnoreCase("view"))?"y":"n"%>"/>
              <jsp:param name="fieldClass" value="Text10"/>
              <jsp:param name="buttonClass" value="Text10"/>
              </jsp:include>					
					</td>
					<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader" align="center">
			<td width="19%"><cellbytelabel id="15">Hora</cellbytelabel></td>
				<td width="40%"><cellbytelabel id="16">Descripci&oacute;n</cellbytelabel></td>
				<td width="8%"><cellbytelabel id="17">Peso</cellbytelabel></td>
				<td width="11%"><cellbytelabel id="18">Fluido</cellbytelabel></td>
				<td width="9%"><cellbytelabel id="19">Cantidad</cellbytelabel></td>
				<td width="8%"><cellbytelabel id="20">Unidad</cellbytelabel></td>
				<td width="5%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Item")%></td>
			</tr>
			<%
				al.clear();
				al = CmnMgr.reverseRecords(LAdmin);

				for (int i = 1; i <= LAdmin.size(); i++)
				{
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";

				key = al.get(i - 1).toString();
				DetalleBalance newBalance =  (DetalleBalance) LAdmin.get(key);
				boolean readOnly = (viewMode);// || !newBalance.getCodigo().equals("0")
				%>
				<%=fb.hidden("fechaDetalle"+i,newBalance.getFecha())%>
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("codBalance"+i,newBalance.getCodBalance())%>
				<%=fb.hidden("codigobal"+i,newBalance.getCodigo())%>
				<%=fb.hidden("seleccionar"+i,newBalance.getSeleccionar())%>

				<tr class="<%=color%>" align="center">
				<td align="center">
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="format" value="hh12:mi:ss am"/>
					<jsp:param name="nameOfTBox1" value="<%="horaIn"+i%>"/>
					<jsp:param name="valueOfTBox1" value="<%=newBalance.getHora()%>"/>
					<jsp:param name="readonly" value="<%=readOnly ? "y" : "n"%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
					</jsp:include>				</td>
				<td>
				<%=fb.textBox("idAdmin"+i,newBalance.getViaAdministracion(), true, false, true, 2, "Text10", "", "")%>
				<%=fb.textBox("descripcion"+i,newBalance.getDescripcion(), false, false, true, 30, "Text10", "", "")%>
				<%=fb.button("btn_administrado"+i,"...",true,readOnly,"Text10",null,"onClick=\"javascript:addVia('"+i+"',0)\"")%></td>
				<td><%=fb.textBox("peso"+i,newBalance.getPeso(), false,false,readOnly, 3, "Text10", "", "")%></td>
				<td align="center"><%=fb.textBox("fluido"+i,newBalance.getFluido(), false, false,readOnly,10, "Text10", "", "")%></td>
				<td align="center"><%=fb.decBox("cantidad"+i,newBalance.getCantidad(),true,false,readOnly,5,6.2, "Text10", "", "")%></td>
				<td align="center"><%=fb.textBox("unidad"+i,newBalance.getUnidad(), false, false, true,5, "Text10", "", "")%></td>
				<td rowspan="2" align="center"><%=fb.submit("rem"+i,"X",false,readOnly,"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>

			<tr  class="<%=color%>">
				<td align="right"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("observacion"+i,newBalance.getObservacion(), false, false,readOnly, 0, 2,2000, "", "width:100%", "")%></td>
			</tr>
<%
}//for
	fb.appendJsValidation("if(error>0)setHeight();");
%>
		<!-- //////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
			<tr  class="TextRow02">
			<td align="right" colspan="6">
				<cellbytelabel id="21">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="22">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="23">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>			</td>
			</tr>
<%=fb.formEnd(true)%>
</table>
<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("adminSize",""+LAdmin.size())%>
<%=fb.hidden("elimSize",""+LElim.size())%>
<%=fb.hidden("LAdminLastLineNo",""+LAdminLastLineNo)%>
<%=fb.hidden("LElimLastLineNo",""+LElimLastLineNo)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("codigo",balance.getCodigo())%>
<%=fb.hidden("tipoPersonal",balance.getTipoPersonal())%>
<%=fb.hidden("personalG",balance.getPersonalG())%>
<%=fb.hidden("empProvincia",balance.getEmpProvincia())%>
<%=fb.hidden("empSigla",balance.getEmpSigla())%>
<%=fb.hidden("empTomo",balance.getEmpTomo())%>
<%=fb.hidden("empAsiento",balance.getEmpAsiento())%>
<%=fb.hidden("empCompania",balance.getEmpCompania())%>
<%=fb.hidden("personal",balance.getPersonal())%>
<%=fb.hidden("usuarioCreacion",balance.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",balance.getFechaCreacion())%>
<%=fb.hidden("usuarioModificacion",balance.getUsuarioModificacion())%>
<%=fb.hidden("fechaModificacion",balance.getFechaModificacion())%>
<%=fb.hidden("empId",balance.getEmpId())%>
<%=fb.hidden("desc",desc)%>

			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="8">Fecha</cellbytelabel></td>
					<td>

											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="clearOption" value="true"/>
											<jsp:param name="nameOfTBox1" value="balFechaOut"/>
											<jsp:param name="valueOfTBox1" value="<%=balance.getFecha()%>"/>
					<jsp:param name="readonly" value="<%=(!modeSec.equals("add")?"y":"n")%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
											</jsp:include>					</td>
					<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader" align="center">
				<td width="19%"><cellbytelabel id="15">Hora</cellbytelabel></td>
				<td width="40%"><cellbytelabel id="16">Descripci&oacute;n</cellbytelabel></td>
				<td width="8%"><cellbytelabel id="17">Peso</cellbytelabel></td>
				<td width="11%"><cellbytelabel id="18">Fluido</cellbytelabel></td>
				<td width="9%"><cellbytelabel id="19">Cantidad</cellbytelabel></td>
				<td width="8%"><cellbytelabel id="20">Unidad</cellbytelabel></td>
				<td width="5%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Item")%></td>
			</tr>
			<%
				al.clear();
				al = CmnMgr.reverseRecords(LElim);

				for (int i = 1; i <= LElim.size(); i++)
				{
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";

				key = al.get(i - 1).toString();
				DetalleBalance newBalance =  (DetalleBalance) LElim.get(key);
				boolean readOnly = (viewMode);// || !newBalance.getCodigo().equals("0")
				%>
				<%=fb.hidden("fechaDetalle"+i,newBalance.getFecha())%>
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("codBalance"+i,newBalance.getCodBalance())%>
				<%=fb.hidden("codigobal"+i,newBalance.getCodigo())%>
				<%=fb.hidden("seleccionar"+i,newBalance.getSeleccionar())%>

				<tr class="<%=color%>" align="center">
				<td align="center">
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="format" value="hh12:mi:ss am"/>
					<jsp:param name="nameOfTBox1" value="<%="horaOut"+i%>"/>
					<jsp:param name="valueOfTBox1" value="<%=newBalance.getHora()%>"/>
					<jsp:param name="readonly" value="<%=readOnly?"y":"n"%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
					</jsp:include>				</td>
				<td>
				<%=fb.textBox("idAdminE"+i,newBalance.getViaAdministracion(), true, false,true, 2, "Text10", "", "")%>
				<%=fb.textBox("descripcion"+i,newBalance.getDescripcion(), false,false, true, 30, "Text10", "", "")%>
				<%=fb.button("btn_administrado"+i,"...",true,readOnly,"Text10",null,"onClick=\"javascript:addVia('"+i+"',1)\"")%></td>
				<td><%=fb.textBox("peso"+i,newBalance.getPeso(), false,false,readOnly, 3, "Text10", "", "")%></td>
				<td align="center"><%=fb.textBox("fluido"+i,newBalance.getFluido(), false, false,readOnly,10, "Text10", "", "")%></td>
				<td align="center"><%=fb.decBox("cantidad"+i,newBalance.getCantidad(),true,false,readOnly,5,6.2, "Text10", "", "")%></td>
				<td align="center"><%=fb.textBox("unidad"+i,newBalance.getUnidad(), false, false, true,5, "Text10", "", "")%></td>
				<td rowspan="2" align="center"><%=fb.submit("rem"+i,"X",false,readOnly,"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>

			<tr  class="<%=color%>">
				<td align="right"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("observacion"+i,newBalance.getObservacion(), false, false,readOnly, 0, 2,2000, "", "width:100%", "")%></td>
			</tr>
<%
}//for
	fb.appendJsValidation("if(error>0)setHeight();");
%>

		<!-- //////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
			<tr  class="TextRow02">
<td align="right" colspan="6">
				<cellbytelabel id="21">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="22">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="23">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%></td>
</tr>
<%=fb.formEnd(true)%>
</table>
<!-- TAB1 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Liquidos Administrados','Liquidos Eliminados'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>					</td>
				</tr>
			</table>

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
	
	System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: modeSec = "+modeSec);

	if (tab.equals("0")) //Liquidos administrados
	{
		int sizeAdmin = 0;
		if (request.getParameter("adminSize") != null) sizeAdmin = Integer.parseInt(request.getParameter("adminSize"));
		String itemRemoved = "";
		al.clear();
		BalanceHidrico bal = new BalanceHidrico();
		bal.setCodigo(request.getParameter("codigo"));
		bal.setSecuencia(request.getParameter("noAdmision"));
		bal.setCodPaciente(request.getParameter("codPac"));
		bal.setFecNacimiento(request.getParameter("dob"));
		bal.setFecha(request.getParameter("balFechaIn"));
		bal.setTipoPersonal(request.getParameter("tipoPersonal"));
		bal.setPersonalG(request.getParameter("personalG"));
		bal.setEmpProvincia(request.getParameter("empProvincia"));
		bal.setEmpSigla(request.getParameter("empSigla"));
		bal.setEmpTomo(request.getParameter("empTomo"));
		bal.setEmpAsiento(request.getParameter("empAsiento"));
		bal.setEmpCompania(request.getParameter("empCompania"));
		bal.setPersonal(request.getParameter("personal"));
		bal.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
		bal.setFechaCreacion(request.getParameter("fechaCreacion"));
		bal.setUsuarioModificacion(request.getParameter("usuarioModificacion"));
		bal.setFechaModificacion(request.getParameter("fechaModificacion"));
		bal.setPacId(request.getParameter("pacId"));
		bal.setEmpId(request.getParameter("empId"));


		for (int i=1; i<= sizeAdmin; i++)
		{
				DetalleBalance detBal = new DetalleBalance();

				detBal.setFecha(request.getParameter("fechaDetalle"+i));
				detBal.setCodBalance(request.getParameter("codBalance"+i));
				detBal.setAdmSecuencia(request.getParameter("noAdmision"));
				detBal.setFechaNacimiento(request.getParameter("dob"));
				detBal.setCodigoPaciente(request.getParameter("codPac"));
				detBal.setViaAdministracion(request.getParameter("idAdmin"+i));
				detBal.setDescripcion(request.getParameter("descripcion"+i));
				detBal.setCodigo(""+i);//detBal.setCodigo(request.getParameter("codigobal"+i));
				detBal.setHora(request.getParameter("horaIn"+i));
				detBal.setPeso(request.getParameter("peso"+i));
				detBal.setFluido(request.getParameter("fluido"+i));
				detBal.setCantidad(request.getParameter("cantidad"+i));
				detBal.setUnidad(request.getParameter("unidad"+i));
				detBal.setObservacion(request.getParameter("observacion"+i));
				detBal.setSeleccionar("S");
				detBal.setPacId(request.getParameter("pacId"));
				detBal.setDescripcion(request.getParameter("descripcion"+i));

				key = request.getParameter("key"+i);

				if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = key;
				else
				{
				 try
					{

						al.add(detBal);
						LAdmin.put(key,detBal);
						bal.addDetalleBalance(detBal);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}

		}
		if(!itemRemoved.equals(""))
		{
			LAdmin.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&modeSec="+modeSec+"&mode="+mode+"&LElimLastLineNo="+LElimLastLineNo+"&LAdminLastLineNo="+LAdminLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc"));

return;

		}

		if(baction.equals("+"))//Agregar
		{
				DetalleBalance newBalance = new DetalleBalance();

						newBalance.setFecha(request.getParameter("balFecha"));
						newBalance.setHora(cDateTime.substring(11));
						newBalance.setCodBalance(request.getParameter("codigo"));
						newBalance.setCodigo("0");
						newBalance.setUnidad("CC");

						LAdminLastLineNo++;
						if (LAdminLastLineNo < 10) key = "00" + LAdminLastLineNo;
						else if (LAdminLastLineNo < 100) key = "0" + LAdminLastLineNo;
						else key = "" + LAdminLastLineNo;
						try
						{
							LAdmin.put(key,newBalance);
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}

						response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&modeSec="+modeSec+"&mode="+mode+"&LElimLastLineNo="+LElimLastLineNo+"&LAdminLastLineNo="+LAdminLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc"));
				return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (modeSec.equalsIgnoreCase("add"))
				{
						BHMgr.add(bal);
				}
				else if (modeSec.equalsIgnoreCase("edit"))
				{
						BHMgr.update(bal,"I");

				}
						ConMgr.clearAppCtx(null);
		}

	}
	if (tab.equals("1")) //Liquido  Eliminados
	{
		int sizeElim = 0;
		if (request.getParameter("elimSize") != null) sizeElim = Integer.parseInt(request.getParameter("elimSize"));
		String itemRemoved = "";
		al.clear();
		BalanceHidrico bal = new BalanceHidrico();
		bal.setCodigo(request.getParameter("codigo"));
		bal.setSecuencia(request.getParameter("noAdmision"));
		bal.setCodPaciente(request.getParameter("codPac"));
		bal.setFecNacimiento(request.getParameter("dob"));
		bal.setFecha(request.getParameter("balFechaOut"));
		bal.setTipoPersonal(request.getParameter("tipoPersonal"));
		bal.setPersonalG(request.getParameter("personalG"));
		bal.setEmpProvincia(request.getParameter("empProvincia"));
		bal.setEmpSigla(request.getParameter("empSigla"));
		bal.setEmpTomo(request.getParameter("empTomo"));
		bal.setEmpAsiento(request.getParameter("empAsiento"));
		bal.setEmpCompania(request.getParameter("empCompania"));
		bal.setPersonal(request.getParameter("personal"));
		bal.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
		bal.setFechaCreacion(request.getParameter("fechaCreacion"));
		bal.setUsuarioModificacion((String)session.getAttribute("_userName"));
		bal.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am"));
		bal.setPacId(request.getParameter("pacId"));
		bal.setEmpId(request.getParameter("empId"));


		for (int i=1; i<= sizeElim; i++)
		{
				DetalleBalance detBal = new DetalleBalance();

				detBal.setFecha(request.getParameter("fechaDetalle"+i));
				detBal.setCodBalance(request.getParameter("codBalance"+i));
				detBal.setAdmSecuencia(request.getParameter("noAdmision"));
				detBal.setFechaNacimiento(request.getParameter("dob"));
				detBal.setCodigoPaciente(request.getParameter("codPac"));
				detBal.setViaAdministracion(request.getParameter("idAdminE"+i));
				detBal.setDescripcion(request.getParameter("descripcion"+i));
				detBal.setCodigo(""+i);
				detBal.setHora(request.getParameter("horaOut"+i));
				detBal.setPeso(request.getParameter("peso"+i));
				detBal.setFluido(request.getParameter("fluido"+i));
				detBal.setCantidad(request.getParameter("cantidad"+i));
				detBal.setUnidad(request.getParameter("unidad"+i));
				detBal.setObservacion(request.getParameter("observacion"+i));
				detBal.setSeleccionar("S");
				detBal.setPacId(request.getParameter("pacId"));
				detBal.setDescripcion(request.getParameter("descripcion"+i));

				key = request.getParameter("key"+i);

				if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = key;
				else
				{
				 try
					{
						al.add(detBal);
						LElim.put(key,detBal);
						bal.addDetalleBalance(detBal);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
		}
		if(!itemRemoved.equals(""))
		{
			LElim.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&LElimLastLineNo="+LElimLastLineNo+"&LAdminLastLineNo="+LAdminLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc"));

return;
		}
		if(baction.equals("+"))//Agregar
		{
				DetalleBalance newBalance = new DetalleBalance();

						newBalance.setFecha(request.getParameter("balFechaOut"));
						newBalance.setHora(cDateTime.substring(11));
						newBalance.setCodBalance(request.getParameter("codigo"));
						newBalance.setCodigo("0");
						newBalance.setUnidad("CC");
						LElimLastLineNo++;
						if (LElimLastLineNo < 10) key = "00" + LElimLastLineNo;
						else if (LElimLastLineNo < 100) key = "0" + LElimLastLineNo;
						else key = "" + LElimLastLineNo;
						try
						{
							LElim.put(key,newBalance);
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
						response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&LElimLastLineNo="+LElimLastLineNo+"&LAdminLastLineNo="+LAdminLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc"));
				return;
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
						System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "+((String)session.getAttribute("_userName")));
						System.out.println(" modeSec = :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "+modeSec);
						
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				if (modeSec.equalsIgnoreCase("add"))
				{
						BHMgr.add(bal);
				}
				else if (modeSec.equalsIgnoreCase("edit"))
				{
						BHMgr.update(bal,"E");
				}
						ConMgr.clearAppCtx(null);
		}		
	}

%>
<html>
<head>

<script language="javascript">
function closeWindow()
{
<%
if (BHMgr.getErrCode().equals("1"))
{
%>
	alert('<%=BHMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_redirect.jsp"))
	{
%>
window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_redirect.jsp")%>';
<%
	}
	else
	{
%>
//window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_redirect.jsp';
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
parent.doRedirect(0);
<%
}
} else throw new Exception(BHMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>';
}
</script>

</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>

