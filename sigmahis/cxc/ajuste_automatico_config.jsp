<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alFact = new ArrayList();
String key = "";
String sql = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String compId = request.getParameter("compId"); 
String factId = request.getParameter("factura");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
int iconHeight = 40;
int iconWidth = 40;

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
double suma_pagos =0.00; 
if (mode == null) mode = "add";
if (fp == null) fp = "ajuste_automatico";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
if (compId == null) compId = (String) session.getAttribute("_companyId");
if (factId == null) factId ="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(factId != null && !factId.trim().equals(""))
{
	if (factId == null) throw new Exception("El codigo de la factura no es válido. Por favor intente nuevamente!");
	sbSql = new StringBuffer();

 sbSql.append("select nvl((select sum(nvl(monto,0)) from tbl_cja_detalle_pago dp, tbl_cja_transaccion_pago tp where tp.codigo = dp.codigo_transaccion and tp.compania = dp.compania and tp.anio = dp.tran_anio and tp.rec_status <>'I' and dp.fac_codigo = a.codigo and dp.compania = a.compania),0)as monto_pagado,a.pac_id,a.admi_secuencia as admision,a.admi_codigo_paciente as codigo_paciente,to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento,p.nombre_paciente nombre,a.facturar_a,a.cod_empresa,e.nombre as nombre_empresa ,a.codigo,a.compania from tbl_fac_factura a,vw_adm_paciente p,tbl_adm_empresa e where a.codigo = '");
 sbSql.append(factId);
 sbSql.append("' and a.estatus <> 'A' and a.compania= ");
 sbSql.append(compId);
 sbSql.append(" and a.pac_id =p.pac_id(+) and a.cod_empresa=e.codigo(+)");
 cdo = SQLMgr.getData(sbSql.toString());
if(cdo != null)
{ 
 alFact = sbb.getBeanList(ConMgr.getConnection(),"select a.codigo as optValueColumn,a.codigo as optLabelColumn, a.facturar_a||'|'||decode(a.facturar_a,'P','PACIENTE','E','EMPRESA','OTROS')||'~'||decode(a.facturar_a,'P',(select nombre_paciente from vw_adm_paciente where pac_id=a.pac_id),'E',(select nombre from tbl_adm_empresa where codigo= a.cod_empresa))||'~'||a.estatus||'|'||decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA',a.estatus) as optTitleColumn from tbl_fac_factura a where a.pac_id ="+cdo.getColValue("pac_id")+" and a.admi_secuencia = "+cdo.getColValue("admision")+" and a.estatus <>'A' and a.compania= "+compId+" and codigo <> '"+factId+"'  order by a.facturar_a ",CommonDataObject.class);

pacienteId = cdo.getColValue("pac_id");
noAdmision = cdo.getColValue("admision");

//sql="select decode(med_empresa,null,decode(medico,null,centro_servicio,medico),med_empresa )as codigo,to_char(fecha_nacimiento,'dd/mm/yyyy')as fecha_nacimiento,codigo_paciente, admision, facturar_a, centro_servicio, med_empresa, medico,pu_descripcion as descripcion, nvl(monto,0)as monto, nvl(pagos,0) as pagos,nvl(saldo,0) as saldo from vw_fac_ajuste_automatico where codigo='"+factId+"' and compania=1";
sbSql = new StringBuffer();

sbSql.append("select nvl(z.codigo_cs, ' ') codigo_cs, nvl(z.descripcion_cs, ' ') descripcion_cs, nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.credit,0) monto_total , nvl(z.monto,0) monto, nvl(z.debit,0) debit, nvl(z.pagos,0) pagos, nvl(z.credit,0) credit, nvl(z.descuento,0) descuentos, nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.pagos,0)- nvl(z.credit,0)-nvl(z.descuento,0) saldo from ( select getcoddetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) codigo_cs, getdescdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) descripcion_cs, f.monto,  getdebitdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) debit,  getpagosdetecf (f.pac_id,f.compania,f.admi_secuencia,f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.cod_empresa) pagos, getcreditdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) credit, f.descuento, f.saldo from ( select f.pac_id, f.codigo, f.fecha, f.admi_fecha_nacimiento, f.admi_codigo_paciente, f.admi_secuencia, f.cod_empresa, f.usuario_creacion, d.tipo, d.med_empresa, d.medico, d.centro_servicio, sum(nvl(d.monto, 0) + nvl(d.descuento, 0)+ nvl (d.descuento2, 0) /* -- se comenta por que en consulta general y factura este monto sale diferente . Se agrego filtro por fecha para tomar los que son mayores a junio*/ /* - nvl((select sum(nvl(df.monto,0)) from tbl_fac_factura ff, tbl_fac_detalle_factura df where ff.codigo = df.fac_codigo and ff.compania = df.compania and ff.pac_id = f.pac_id and ff.admi_secuencia = f.admi_secuencia and ff.facturar_a = 'P' and ff.estatus = 'P' and f.codigo != ff.codigo and substr(df.descripcion, 10, length(df.descripcion)-9) = cds.descripcion and df.tipo_cobertura = 'CO' and trunc(ff.fecha) >= to_date('01/10/2011','dd/mm/yyyy')), 0) */ -decode(f.nueva_formula,'S',0,decode(f.tipo_cobertura,'S',0,nvl(getCopagoDet(f.compania,f.codigo,nvl(to_char(d.med_empresa),d.medico),cds.descripcion,f.pac_id,f.admi_secuencia,null ),0)))) monto, sum (nvl (d.monto, 0)) saldo, sum (nvl (d.descuento, 0) + nvl (d.descuento2, 0)) descuento, f.facturar_a, f.estatus, f.compania, f.cuenta_i from tbl_fac_factura f, tbl_fac_detalle_factura d, tbl_cds_centro_servicio cds where f.codigo = '");
sbSql.append(factId);
sbSql.append("' and f.compania = ");
sbSql.append(compId);
sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and d.imprimir_sino='S' and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.centro_servicio = cds.codigo(+)) group by f.nueva_formula,f.pac_id,f.codigo,f.fecha,f.admi_fecha_nacimiento,f.admi_codigo_paciente,f.admi_secuencia,f.cod_empresa,f.usuario_creacion,d.tipo, d.med_empresa,d.medico,d.centro_servicio,f.facturar_a,f.estatus,f.compania,f.cuenta_i order by d.centro_servicio asc ) f  ");

sbSql.append(" union all ");

sbSql.append(" select to_char(a.centro) codigo_cs,decode(a.tipo,'C',(select descripcion from tbl_cds_centro_servicio where codigo=a.centro),'P','COPAGO','M','PERDIEM') descripcion_cs,0 monto, a.debit, nvl (a.pagos, 0) pagos, a.credit, 0 descuento, (a.debit - nvl (a.pagos, 0) - a.credit) saldo from (select   f.codigo, n.centro, nvl(sum (nvl (decode (n.lado_mov, 'D', n.monto), 0)),0) debit, nvl(sum (nvl (decode (n.lado_mov, 'C', n.monto), 0)),0) credit,n.tipo ,getPagosCNF(f.codigo,n.centro,f.compania,n.tipo) pagos    from tbl_fac_factura f, vw_con_adjustment_gral n where  f.compania = n.compania and f.compania =");
sbSql.append(compId);
sbSql.append(" and f.codigo = n.factura and f.codigo = '");
sbSql.append(factId);
sbSql.append("' and nvl(n.centro,-1) <> 0 and n.monto <> 0 and nvl(n.centro,-1) not in (select distinct nvl (b.centro_servicio,-1) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania = ");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo ='");
sbSql.append(factId);
sbSql.append("' and nvl(b.centro_servicio,-1) <> 0 and b.imprimir_sino='S' ) group by f.codigo, n.centro,n.tipo,f.compania ) a "); 

sbSql.append(" union all ");

sbSql.append(" select coalesce (a.cod_medico, to_char (a.cod_empresa), ' ') codigo_cs, coalesce (b.nombre_medico, c.nombre_empresa, ' ') descripcion_cs, 0 monto, a.debit, nvl (getpagospdetecf (a.codigo, a.cod_medico, a.cod_empresa,");
	sbSql.append(compId);
	sbSql.append("), 0) pagos, a.credit, 0 descuentos, (a.debit - nvl (getpagospdetecf (a.codigo, a.cod_medico, a.cod_empresa,");
	sbSql.append(compId);
	sbSql.append("), 0) - a.credit) saldo from (select distinct f.codigo, nvl (n.centro, 0) centro_servicio, nvl(sum (decode (n.lado_mov, 'D', n.monto)),0) debit, nvl(sum (decode (n.lado_mov, 'C', n.monto)),0) credit, n.empresa cod_empresa, n.medico cod_medico from tbl_fac_factura f, vw_con_adjustment_gral n where n.tipo_ajuste <> '68' and f.compania = n.compania and f.compania = ");
sbSql.append(compId);
sbSql.append(" and f.codigo = n.factura and f.codigo = '");
sbSql.append(factId);
sbSql.append("' and n.monto <> 0 and (n.centro = 0) and ((n.medico not in (select distinct nvl (b.medico, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo = '");
sbSql.append(factId);
sbSql.append("' and nvl (b.centro_servicio, 0) = 0 and b.imprimir_sino='S' and (b.medico is not null or b.med_empresa is not null))) or (n.empresa not in (select distinct nvl (b.med_empresa, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo = '");
sbSql.append(factId);
sbSql.append("' and nvl (b.centro_servicio, 0) = 0 and b.imprimir_sino='S'  and (b.medico is not null or b.med_empresa is not null)))) group by f.codigo, n.centro, n.empresa, n.medico) a,    (select codigo, primer_nombre || ' '|| segundo_nombre|| ' '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada nombre_medico from tbl_adm_medico) b, (select codigo, nombre nombre_empresa from tbl_adm_empresa) c where a.cod_medico = b.codigo(+) and a.cod_empresa = c.codigo(+) ) z order by lpad(z.codigo_cs,5,'0') ");

		al = SQLMgr.getDataList(sbSql.toString()); 
}
else 
{
	cdo= new CommonDataObject();
	pacienteId = "0";
	noAdmision ="0";
}
}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Ajuste automático a factura- '+document.title;
function doAction()
{
}
function exeFactura2()
{
var facturaPrimaria = eval('document.form0.facturaPrimaria').value;
var factura = eval('document.form0.factura').value;
var facturar_a = eval('document.form0.facturadoA').value;
var cod_empresa1 = eval('document.form0.cod_empresa1').value;

var x=0;
var saldo_factura = parseFloat(eval('document.form0.saldo').value);
var monto_pagado = parseFloat(eval('document.form0.monto_pagado').value);
var fecha_nacimiento = eval('document.paciente.fechaNacimiento').value;
var codigo_paciente = eval('document.paciente.codigoPaciente').value;
var pacId = eval('document.paciente.pacienteId').value;
var noAdmision = eval('document.paciente.admSecuencia').value;
var suma_pagos =parseFloat(eval('document.form0.distribuido').value);

			if(fecha_nacimiento =='')
			{
				alert('No ha seleccionado la FACTURA...');
				return false;
			}
			
			if(saldo_factura == 0)
			{
				alert('No puede ejecutar este proceso, la factura '+facturaPrimaria+' no tiene SALDO pendiente...');
				return false;
			}
			else if(saldo_factura < 0)
			{
			alert('No puede ejecutar este proceso, la factura '+facturaPrimaria+' está en CREDITO...'); 
				return false;
			}
			else if(monto_pagado >= saldo_factura+suma_pagos)
			{
				alert('monto_pagado='+monto_pagado+'  saldo_factura =='+saldo_factura+'  suma_pagos= '+suma_pagos);
				alert('No puede ejecutar este proceso, los PAGOS APLICADOS cancelan el saldo de la Factura '+facturaPrimaria); 
				return false;
			}
			
			if(confirm('Estimado usuario: Al ejecutar este Proceso estará realizando: \n - 1. Nota de Credito a la Factura # '+facturaPrimaria+' por el saldo Pendiente. \n - 2. Nota de Debito a la Factura # '+factura+' por el saldo Pendiente en la Factura # '+facturaPrimaria+'  \n Está seguro que desea Contunuar????')){
			
			if(factura.trim() !='') {showPopWin('../common/run_process.jsp?fp=factura&actType=50&docType=FACT&docId='+facturaPrimaria+'&docNo='+facturaPrimaria+'&compania=<%=compId%>&factura='+factura+'&pacId='+pacId+'&noAdmision='+noAdmision+'&monto='+saldo_factura+'&aseguradora='+cod_empresa1+'&facturarA='+facturar_a,winWidth*.75,winHeight*.65,null,null,'');}
			else{alert('No Ha seleccionado Factura Para generar Ajuste');}
			}
			else alert('Proceso Cancelado!!');
/*
if(executeDB('<%=request.getContextPath()%>','CALL CXC_AJUSTA_FACTURA2(<%=compId%>,\''+factura+'\',\''+factura2+'\''+saldo_factura+',\''+fecha_nacimiento+'\','+codigo_paciente+',<%=noAdmision%>,'+cod_empresa+',<%=pacienteId%>)','tbl_fac_nota_ajuste, tbl_fac_det_nota_ajuste,tbl_fac_factura'))
{
	alert('La 2da Factura se ha Ajustado Satisfactoriamente');
}
else alert('No se ha podido Ajustar la 2da Factura');*/
}
function showConsumos(){var factura = eval('document.form0.facturaPrimaria').value;if(factura != '')window.location = '../cxc/ajuste_automatico_config.jsp?mode=<%=mode%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&factura='+factura;else alert('Indroduzca el No. de Factura');}
function getDesc(obj){var cliente = getSelectedOptionTitle(obj,'');var facturado = cliente.substring(0,cliente.indexOf('~'));var estadoDesc = cliente.substring(cliente.lastIndexOf('~')+1);document.form0.facturadoA.value= facturado.substring(0,facturado.indexOf('|'));document.form0.facturadoDesc.value= facturado.substring(facturado.lastIndexOf('|')+1);document.form0.estado.value= estadoDesc.substring(0,estadoDesc.indexOf('|'));document.form0.descEstado.value= estadoDesc.substring(estadoDesc.indexOf('|')+1);document.form0.descFact.value= cliente.substring(cliente.indexOf('~')+1,cliente.lastIndexOf('~'));}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="AJUSTE AUTOMATICO"></jsp:param>
	
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="1">   
<tr>
	 <td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">   
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="0" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%"><cellbytelabel>Datos del Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacienteId%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="fp" value="<%=fp%>"></jsp:param>
							<jsp:param name="tr" value="<%=fg%>"></jsp:param>
							<jsp:param name="mode" value="view"></jsp:param>
						</jsp:include>
					</td>
				</tr>
	 
		</table>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">	
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("compId",compId)%>
			<%=fb.hidden("cod_empresa1",cdo.getColValue("cod_empresa"))%>
			
				<tr class="TextHeader">
							<td colspan="5"><cellbytelabel>DATOS DE LA FACTURA</cellbytelabel></td>
				</tr>
				<tr>
				<td colspan="5">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow01"> 
					<td width="10%"><cellbytelabel>Factura</cellbytelabel> # :</td>
					<td width="25%"><%=fb.textBox("facturaPrimaria",factId,true,false,((factId.trim().equals(""))?false:true),10,15,null,null,"")%>
					<%=((!factId.trim().equals(""))?"":fb.button("addConsumo","CONSUMO",(!viewMode),viewMode,null,null,"onClick=\"javascript:showConsumos()\"","Consumos"))%></td>
					<td width="10%"><%=fb.select("facturar_1","P = PACIENTE, E=EMPRESA , O=OTROS",cdo.getColValue("facturar_a"),false,true,0,"",null,"")%></td>
					<td width="35%"><cellbytelabel>Empresa</cellbytelabel> <%=fb.textBox("empresa1",cdo.getColValue("nombre_empresa"),false,false,true,25,100,null,null,"")%></td>
					<td width="20%"><cellbytelabel>Pagos aplicados</cellbytelabel> <%=fb.decBox("monto_pagado",cdo.getColValue("monto_pagado"),false,false,true,10,10.2,null,null,"")%>
							</td>
				</tr>
				</table>
				</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="5"><cellbytelabel>CONSUMO</cellbytelabel></td>
				</tr>		
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="30%" align="left"><cellbytelabel>Centro de Servicio</cellbytelabel></td>		
					<td width="15%"><cellbytelabel>Lo Facturado</cellbytelabel> </td>
					<td width="15%"><cellbytelabel>Pago Distribuido</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Saldo</cellbytelabel></td>				
				</tr>		
				<%	double total = 0.00,saldo=0.00, porAplicar =0.0,porAplicar2 =0.0,porAplicar3 =0.0;
				    for (int i = 0; i < al.size(); i++)
				    {
					  key = al.get(i).toString();	
					  cdo2 =  (CommonDataObject) al.get(i);
						String color = "TextRow02";
	 					if (i % 2 == 0) color = "TextRow01";
						suma_pagos += Double.parseDouble(cdo2.getColValue("pagos"));
						total += Double.parseDouble(cdo2.getColValue("monto_total"));
						saldo += Double.parseDouble(cdo2.getColValue("saldo"));
						
						double tmp = Math.round((saldo) * 100);
						 porAplicar = tmp / 100;
						 double tmp2 = Math.round((total) * 100);
						 porAplicar2 = tmp2 / 100;
						 double tmp3 = Math.round((suma_pagos) * 100);
						 porAplicar3 = tmp3 / 100;
						 cdo.addColValue("saldo",""+porAplicar);
						 cdo.addColValue("suma_pagos",""+porAplicar3);
						 cdo.addColValue("total",""+porAplicar2);
			    %>
				<%=fb.hidden("pac_id"+i,"")%>
				<%=fb.hidden("facturar_a"+i,"")%>
				<%=fb.hidden("key"+i,key)%> 
				<%=fb.hidden("remove"+i,"")%>
				
			  <tr class="<%=color%>" align="center"> 
					<td><%=fb.intBox("sec"+i,""+(i+1),false,false,true,5,5,"Text10",null,null)%></td>
					<td align="left"><%=fb.textBox("centro"+i,cdo2.getColValue("codigo_cs"),false,false,true,5,12,"Text10",null,null)%>
							<%=fb.textBox("name_centro"+i,cdo2.getColValue("descripcion_cs"),false,false,true,30,50,"Text10",null,null)%></td>
					<td><%=fb.decBox("monto"+i,cdo2.getColValue("monto_total"),false,false,true,12,30,"Text10",null,null)%></td>
					<td><%=fb.decBox("pago"+i,cdo2.getColValue("pagos"),false,false,true,12,4,"Text10",null,null)%></td>
					<td><%=fb.decBox("saldo"+i,cdo2.getColValue("saldo"),false,false,true,12,4,"Text10",null,null)%></td>
		   </tr>
			 <%}System.out.println("porAplicar ==="+porAplicar+"  total ===="+total);%>
			<tr class="TextRow01"> 
					<td colspan="2" align="right"><cellbytelabel>Total</cellbytelabel></td>
					<td align="center"><%=fb.decBox("saldo_factura",""+cdo.getColValue("total"),false,false,true,12,15.2,"Text10",null,null)%></td>
					<td align="center"><%=fb.decBox("distribuido",""+cdo.getColValue("suma_pagos"),false,false,true,12,15.2,"Text10",null,null)%></td>
					<td align="center"><%=fb.decBox("saldo",""+cdo.getColValue("saldo"),false,false,true,12,15.2,"Text10",null,null)%></td>
					
		    </tr>
			 
			 <tr class="TextHeader">
					<td colspan="5"><cellbytelabel>FACTURAS</cellbytelabel></td>
			 </tr>		
			 <tr class="TextRow01">
			  <td colspan="5">
			 	<table align="center" width="100%" cellpadding="0" cellspacing="1">
					<tr class="TextHeader"> 
						<td width="15%"><cellbytelabel>No. Factura</cellbytelabel></td>
						<td width="15%"><cellbytelabel>Facturado A</cellbytelabel></td>
						<td width="15%"><cellbytelabel>Estado</cellbytelabel></td>
						<td width="25%"><cellbytelabel>Empresa/Paciente</cellbytelabel></td>
 						<td width="25%">&nbsp;</td>
					</tr>
					<%=fb.hidden("facturadoA","")%>
					<%=fb.hidden("estado","")%>
					<tr class="TextRow01"> 
						<td rowspan="2"><%=fb.select("factura",alFact,"",false,false,0,"Text10",null,"onChange=\"javascript:getDesc(this)\"",null,"S")%></td>
						<td rowspan="2"><%=fb.textBox("facturadoDesc","",false,false,true,15)%></td>
						<td rowspan="2"><%=fb.textBox("descEstado","",false,false,true,25)%></td>
						<td rowspan="2"><%=fb.textBox("descFact","",false,false,true,35)%></td>
						<td><%//=fb.button("addNota","Nota Debito",(!viewMode),viewMode,null,null,"onClick=\"javascript:setNota()\"","Nota Debito")%></td>
			 		</tr>
					<tr class="TextRow01"> 
					<td><!--<a href="javascript:exeFactura2();"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder"  src="../images/payment_adjust.gif"></a>--><%=fb.button("addfactura2","AJUSTAR FACTURAS",(!viewMode),viewMode,null,null,"onClick=\"javascript:exeFactura2()\"","GENERAR NOTA DE CREDITO Y AJUSTAR 2DA FACTURA")%></td>
			 		</tr>
				</table>
			   </td>
			  </tr>		 
			  <tr class="TextRow01">
			  	<td colspan="5" align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			  </tr>	
	

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>		 
</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>