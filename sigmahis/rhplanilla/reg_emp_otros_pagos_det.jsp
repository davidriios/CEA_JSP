<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr"/>
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<%
/**
===============================================================================
sct0530_rrhh    Propia de Recursos Humanos (fg=O)
sct0530         Departamentos
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);
VacMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alSub = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String grupo = request.getParameter("grupo");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String periodo = request.getParameter("periodo");
String fInicio = request.getParameter("fInicio");
String fFinal = request.getParameter("fFinal");
String change = request.getParameter("change");

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	alSub = sbb.getBeanList(ConMgr.getConnection(),"select a.transaccion||'-'||a.sub_tipo as optValueColumn, a.descripcion||' [ '||b.descripcion||' ]' as optLabelColumn, a.transaccion||'|'||a.sub_tipo||'|'||a.descripcion||'|'||nvl(a.monto,0) as optTitleColumn from tbl_pla_sub_tipo_transaccion a, tbl_pla_tipo_transaccion b where a.transaccion = b.codigo and a.compania = b.compania"+((viewMode)?"":" and a.estado = 'A'")+" and a.compania = "+session.getAttribute("_companyId")+" order by b.descripcion, a.descripcion",CommonDataObject.class);

	if (change == null)
	{
		iEmp.clear();
		if (grupo != null)
		{
			sbSql = new StringBuffer();
			sbSql.append("select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.tipo_trx, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.monto, decode(a.cantidad,null,' ',''||a.cantidad) as cantidad, nvl(to_char(a.fecha_inicio,'dd/mm/yyyy'),' ') as fecha_inicio, nvl(to_char(a.fecha_final,'dd/mm/yyyy'),' ') as fecha_final, decode(a.anio_pago,null,' ',''||a.anio_pago) as anio_pago, decode(a.mes_pago,null,' ',''||a.mes_pago) as mes_pago, decode(a.quincena_pago,null,' ',''||a.quincena_pago) as quincena_pago, decode(a.cod_planilla_pago,null,' ',''||a.cod_planilla_pago) as cod_planilla_pago, nvl(a.estado_pago,' ') as estado_pago, nvl(to_char(a.fecha_pago,'dd/mm/yyyy'),' ') as fecha_pago, a.comentario, nvl(a.accion,' ') as accion, nvl(a.vobo_estado,' ') as vobo_estado, nvl(a.vobo_usuario,' ') as vobo_usuario, nvl(to_char(a.vobo_fecha,'dd/mm/yyyy'),' ') as vobo_fecha, decode(a.grupo,null,' ',''||a.grupo) as grupo, nvl(a.num_empleado,' ') as num_empleado, decode(a.sub_tipo_trx,null,' ',a.sub_tipo_trx) as sub_tipo_trx, decode(a.monto_unitario,null,' ',''||a.monto_unitario) as monto_unitario, nvl(a.aprobacion_estado,' ') as aprobacion_estado, nvl(a.aprobacion_usuario,' ') as aprobacion_usuario, nvl(to_char(a.aprobacion_fecha,'dd/mm/yyyy'),' ') as aprobacion_fecha, decode(a.anio_reporta,null,' ',''||a.anio_reporta) as anio_reporta, decode(a.quincena_reporta,null,' ',''||a.quincena_reporta) as quincena_reporta, decode(a.cod_planilla_reporta,null,' ',a.cod_planilla_reporta) as cod_planilla_reporta, a.emp_id");//, decode(a.estado_pago,'PE','PENDIENTE','PA','PAGADO','AN','ANULADO') as estado, decode(a.accion,'PA','PAGAR','DE','DESCONTAR') as accion
			sbSql.append(", (select primer_nombre||' '||decode(sexo,'F',decode(apellido_casada, null,primer_apellido,decode(usar_apellido_casada,'S','DE '||apellido_casada,primer_apellido)),primer_apellido) from tbl_pla_empleado where emp_id = a.emp_id) as nombre_empleado");
			sbSql.append(", (select descripcion from tbl_pla_tipo_transaccion where compania = a.compania and codigo = a.tipo_trx) as descTrx");
			sbSql.append(" from tbl_pla_transac_emp a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.grupo = ");
			sbSql.append(grupo);
			sbSql.append(" and a.anio_reporta = ");
			sbSql.append(anio);
			if (fg.equalsIgnoreCase("O"))
			{
				sbSql.append(" and a.vobo_estado = 'N' and quincena_pago = ");
				sbSql.append(periodo);
			}
			else sbSql.append(" and a.aprobacion_estado = 'N' and estado_pago = 'PE'");
			sbSql.append(" order by a.anio_pago desc, a.fecha desc, a.codigo desc");
			al = SQLMgr.getDataList(sbSql.toString());
 			System.err.println(sbSql);
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i - 1);
				cdo.setKey(i);
				cdo.setAction("U");
				try
				{
					iEmp.put(cdo.getKey(),cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction()
{
<% if (request.getParameter("type") != null)
{ %>
abrir_ventana('../common/check_empleado.jsp?fp=rrhh_otros_pagos&mode=<%=mode%>&fg=<%=fg%>&grupo=<%=grupo%>&anio=<%=anio%>&mes=<%=mes%>&quincena=<%=quincena%>&periodo=<%=periodo%>&fInicio=<%=fInicio%>&fFinal=<%=fFinal%>');
<% } %>
<% if (!fg.equalsIgnoreCase("O"))
{ %>
newHeight();
<% } %>
}


function doSubmit(baction){
	document.form0.baction.value = baction;
	if(baction == 'Aprobacion'){
		if(chkSelected()) document.form0.submit();
		else alert('Seleccione al menos un Empleado!');
	}
	
	var size = document.form0.keySize.value;
	var x = 0;
	for(i=1;i<=size;i++){
	    var empId = $("#emp_id"+i).val();
	    var empName = $("#nombre_empleado"+i).val();
		if(!$('#tipo_trx'+i).val()) {
		  alert('El tipo de transacción no está definido para el empleado (['+empId+'] - '+empName+' )');
		  x++;
		  break;
		}
	}

	if(form0Validation() && x == 0) document.form0.submit();
	else parent.form0BlockButtons(false);
}


function chkSelected(){
	var size = document.form0.keySize.value;
	var x = 0;
	for(i=1;i<=size;i++){
		if(eval('document.form0.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}

function calcMonto(k){var cantidad=(eval('document.form0.cantidad'+k).value.trim()=='')?0:parseFloat(eval('document.form0.cantidad'+k).value);var monto_unitario=(eval('document.form0.monto_unitario'+k).value.trim()=='')?0:parseFloat(eval('document.form0.monto_unitario'+k).value);var monto=cantidad*monto_unitario;eval('document.form0.monto'+k).value=monto.toFixed(2);}
function setMonto(obj,k){var c=splitCols(getSelectedOptionTitle(obj,'|||0'));eval('document.form0.tipo_trx'+k).value=c[0];eval('document.form0.sub_tipo_trx'+k).value=c[1];eval('document.form0.comentario'+k).value=c[2];var monto=parseFloat(c[3]);eval('document.form0.monto_unitario'+k).value=monto.toFixed(2);calcMonto(k);}
function checkTipoPago(){for(var i=1;i<=<%=iEmp.size()%>;i++){if(eval('document.form0.action'+i).value!='D'&&eval('document.form0.tipo_pago'+i).value==''){alert('Por favor indique el TIPO DE PAGO!');return false;}}return true;}
function deselAll(){
	var size = document.form0.keySize.value;
	for(i=1;i<=size;i++){
		eval('document.form0.chk'+i).checked = false;
	}
}

function selAll(){
	var size = document.form0.keySize.value;
	for(i=1;i<=size;i++){
		eval('document.form0.chk'+i).checked = true;
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document.form0.baction.value=='Guardar'){if(!checkTipoPago())return false;}else return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("periodo",periodo)%>
<%=fb.hidden("fCierre","")%>
<%=fb.hidden("fInicio",fInicio)%>
<%=fb.hidden("fFinal",fFinal)%>
<%=fb.hidden("size",""+iEmp.size())%>
<tr class="TextHeader" align="center">
	<td colspan="10" align="right">


	<%=fb.submit("AddEmploys","Agregar Empleados",true,viewMode,"Text10","","onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"")%>
	</td>
</tr>
<tr class="TextHeader02" align="center">
	<td width="4%">Sec.</td>
	<td width="8%">Fecha Reg.</td>
	<td width="30%">Empleado</td>
	<td width="13%">Fecha </td>
	<%
	if (fg.equalsIgnoreCase("O")) {
	%>
	<td width="13%">Fecha Final</td>
	<% } else {%>
	<td width="13%">&nbsp</td>
	<% } %>
	<td width="8%">Cant.</td>
	<td width="9%">Monto Unit.</td>
	<td width="9%">Total pagar</td>
	<td width="3%">&nbsp;</td>
	<td width="3%"><%=fb.checkbox("chkAct","",false,false,"","","onClick=\"javascript:checkAll(this.form.name,'chk',"+(iEmp.size()+1)+",this,1)\"")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iEmp);
for (int i=1; i<=iEmp.size(); i++)
{
	CommonDataObject ad = (CommonDataObject) iEmp.get(al.get(i - 1).toString());

	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
	String style = (ad.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
%>
	<%=fb.hidden("provincia"+i,ad.getColValue("provincia"))%>
	<%=fb.hidden("sigla"+i,ad.getColValue("sigla"))%>
	<%=fb.hidden("tomo"+i,ad.getColValue("tomo"))%>
	<%=fb.hidden("asiento"+i,ad.getColValue("asiento"))%>
	<%=fb.hidden("codigo"+i,ad.getColValue("codigo"))%>
	<%=fb.hidden("tipo_trx"+i,ad.getColValue("tipo_trx"))%>
	<%=fb.hidden("fecha"+i,ad.getColValue("fecha"))%>
	<%=fb.hidden("grupo"+i,ad.getColValue("grupo"))%>
	<%=fb.hidden("num_empleado"+i,ad.getColValue("num_empleado"))%>
	<%=fb.hidden("sub_tipo_trx"+i,ad.getColValue("sub_tipo_trx"))%>
	<%=fb.hidden("emp_id"+i,ad.getColValue("emp_id"))%>

	<%=fb.hidden("nombre_empleado"+i,ad.getColValue("nombre_empleado"))%>
	<%=fb.hidden("anio_pago"+i,ad.getColValue("anio_pago"))%>
	<%=fb.hidden("periodo_pago"+i,ad.getColValue("periodo_pago"))%>

	<%=fb.hidden("key"+i,ad.getKey())%>
	<%=fb.hidden("action"+i,ad.getAction())%>
	<%=fb.hidden("remove"+i,"")%>
<tr class="<%=color%>" align="center"<%=style%>>
	<td rowspan="2"><%=ad.getColValue("codigo")%></td>
	<td><%=ad.getColValue("fecha")%></td>
	<td align="left"><%=ad.getColValue("num_empleado")%> - <%=ad.getColValue("nombre_empleado")%></td>
	<td>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="nameOfTBox1" value="<%="fecha_inicio"+i%>"/>
		<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("fecha_inicio")==null)?"":ad.getColValue("fecha_inicio")%>"/>
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="buttonClass" value="Text10"/>
		<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
		</jsp:include>
	</td>
	<td>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="nameOfTBox1" value="<%="fecha_final"+i%>"/>
		<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("fecha_final")==null)?"":ad.getColValue("fecha_final")%>"/>
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="buttonClass" value="Text10"/>
		<jsp:param name="readonly" value="<%=(viewMode || !fg.equalsIgnoreCase("O"))?"y":"n"%>"/>
		</jsp:include>
	</td>
	<td><%=fb.decBox("cantidad"+i,ad.getColValue("cantidad"),false,false,viewMode,7,4.2,"Text10",null,"onChange=\"javascript:calcMonto("+i+")\"")%></td>
	<td><%=fb.decBox("monto_unitario"+i,ad.getColValue("monto_unitario"),false,false,viewMode,9,6.2,"Text10","","onChange=\"javascript:calcMonto("+i+")\"")%></td>
	<td><%=fb.decPlusZeroBox("monto"+i,ad.getColValue("monto"),false,false,true,9,6.2,"Text10","","")%></td>
	<td rowspan="2"><%=fb.submit("rem"+i,"X",true,viewMode,"","","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+");\"")%></td>
		<td rowspan="2"><%=fb.checkbox("chk"+i,""+i, false, false, "text10", "", "")%></td>
</tr>
<tr class="<%=color%>" valign="top"<%=style%>>
	<td colspan="2">
		Tipo de Pago
		<%=fb.select("tipo_pago"+i,alSub,ad.getColValue("tipo_trx")+"-"+ad.getColValue("sub_tipo_trx"),false,viewMode,0,"Text10","width:80%","onChange=\"javascript:setMonto(this,"+i+")\"","","S")%>
	</td>
	<td colspan="5">
		Observaci&oacute;n:
		<%=fb.textarea("comentario"+i,ad.getColValue("comentario") ,false,false,viewMode,55,2,500)%>
	</td>
</tr>
<%
}
%>
<%=fb.hidden("keySize",""+iEmp.size())%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	String errCode = "";
	String errMsg = "";
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	iEmp.clear();
	al.clear();
	String itemRemoved = "";
	for (int i=1; i<=size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_pla_transac_emp");
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
		cdo.addColValue("emp_id",request.getParameter("emp_id"+i));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("provincia",request.getParameter("provincia"+i));
		cdo.addColValue("sigla",request.getParameter("sigla"+i));
		cdo.addColValue("tomo",request.getParameter("tomo"+i));
		cdo.addColValue("asiento",request.getParameter("asiento"+i));
		cdo.addColValue("codigo",request.getParameter("codigo"+i));
		cdo.addColValue("tipo_trx",request.getParameter("tipo_trx"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("monto",request.getParameter("monto"+i));
		cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
		cdo.addColValue("fecha_inicio",request.getParameter("fecha_inicio"+i));
		if (fg.equalsIgnoreCase("O")) cdo.addColValue("fecha_final",request.getParameter("fecha_final"+i));
		cdo.addColValue("cod_planilla_pago","1");
		cdo.addColValue("estado_pago","PE");
		cdo.addColValue("comentario",request.getParameter("comentario"+i));
		if (cdo.getAction().equalsIgnoreCase("I"))
		{
			cdo.setAutoIncCol("codigo");
			cdo.setAutoIncWhereClause("compania = "+cdo.getColValue("compania")+" and emp_id = "+cdo.getColValue("emp_id")+" and tipo_trx = "+cdo.getColValue("tipo_trx"));

			cdo.addColValue("anio_pago",request.getParameter("anio_pago"+i));
			cdo.addColValue("quincena_pago",request.getParameter("periodo_pago"+i));
			cdo.addColValue("usuario_creacion",UserDet.getUserName());
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.addColValue("anio_reporta",anio);
			cdo.addColValue("quincena_reporta",periodo);
		}
		else
		{
			cdo.setWhereClause("compania = "+cdo.getColValue("compania")+" and emp_id = "+cdo.getColValue("emp_id")+" and codigo = "+cdo.getColValue("codigo")+" and tipo_trx = "+cdo.getColValue("tipo_trx"));
		}
		cdo.addColValue("usuario_modificacion",UserDet.getUserName());
		cdo.addColValue("fecha_modificacion","sysdate");
		cdo.addColValue("accion","PA");
		cdo.addColValue("vobo_estado","N");
		cdo.addColValue("grupo",grupo);
		cdo.addColValue("anio_pago",anio);
		cdo.addColValue("quincena_pago",periodo);
		cdo.addColValue("num_empleado",request.getParameter("num_empleado"+i));
		cdo.addColValue("sub_tipo_trx",request.getParameter("sub_tipo_trx"+i));
		cdo.addColValue("monto_unitario",request.getParameter("monto_unitario"+i));
		if (fg.equalsIgnoreCase("O")) cdo.addColValue("aprobacion_estado","S");//sct0530_rrhh
		else cdo.addColValue("aprobacion_estado","N");//sct0530
		cdo.addColValue("cod_planilla_reporta","1");

		cdo.addColValue("nombre_empleado",request.getParameter("nombre_empleado"+i));


		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo.getKey();
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}


		if (baction.equalsIgnoreCase("Aprobacion"))
		{
			if(request.getParameter("chk"+i)!=null)
			{
				iEmp.put(cdo.getKey(),cdo);
				al.add(cdo);
			}

		} else 	if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iEmp.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&fg="+fg+"&grupo="+grupo+"&anio="+anio+"&mes="+mes+"&quincena="+quincena+"&periodo="+periodo+"&fInicio="+fInicio+"&fFinal="+fFinal);
		return;
	}
	else if (baction.equalsIgnoreCase("Agregar Empleados"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&fg="+fg+"&grupo="+grupo+"&anio="+anio+"&mes="+mes+"&quincena="+quincena+"&periodo="+periodo+"&fInicio="+fInicio+"&fFinal="+fFinal);
		return;
	}

	else if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.saveList(al,true,false);
		errCode = SQLMgr.getErrCode();
 		errMsg = SQLMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	} 	else if (baction.equalsIgnoreCase("Aprobacion"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 		VacMgr.aprobarOtrosPagos(al);
 		errCode = VacMgr.getErrCode();
 		errMsg = VacMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function closeWindow()
{
<%if (errCode.equals("1"))
{%>
alert('<%=errMsg%>');
parent.showList();
<%} else throw new Exception(errMsg);
%>}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>