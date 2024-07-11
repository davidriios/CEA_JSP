<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
sct0200_rrhh				RECURSOS HUMANOS\TRANSACCIONES\Aprobar/Rechazar Sol. Vacaciones
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

if(fg==null) fg = "anio";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(fg.equals("mes")) sql = "select mes||' / '||ano anio,mes as mesCierre,ano as anioActivo,sp_con_verifica_cierre(cod_cia,mes,ano)as msg,'' as anioDesc, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'SHOW_CIERRE_DET'),'N') show_cierre_det from tbl_con_estado_meses where cod_cia = "+(String) session.getAttribute("_companyId")+" and estatus = 'ACT'";	
	else if(fg.equals("TR")) sql = "select (select nombre from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+") nombre_compania, (select ano from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId")+" and estado = 'ACT') anio,'' as anioDesc from dual";
	else sql = "select (select nombre from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+") nombre_compania, (select ano from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId")+" and estado in('TRS')) anio, 13 mes,'ULTIMO AÑO CERRADO '||(select max(ano) from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId")+" and estado ='CER') as anioDesc from dual";
	cdo = SQLMgr.getData(sql);
	if(cdo == null){ cdo = new CommonDataObject();if(fg.equals("mes")){cdo.addColValue("anioDesc","NO EXISTE MES ACTIVO");cdo.addColValue("anio","");}}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - '+document.title;

function doSubmit(value){document.form1.baction.value = value;}
function doAction(){}

function ejecutarJob(job){
if(job==1)
showPopWin('../process/pm_run_job_fact.jsp?fp=CIERRE',winWidth*.75,winHeight*.65,null,null,'');
else if(job==2 || job==3){
	var contrato = document.form1.id_solicitud.value;
	var cantidad = document.form1.cantidad.value;
	if(contrato=='') alert('Seleccione Contrato!');
	else if(cantidad=='' || isNaN(cantidad)) alert('Introduzca Cantidad de Facturas!');
	else {
			if(job==2) {
				var v_msg = 'Y';
				var anio_c = document.form1.anio_c.value;
				var mes_c = document.form1.mes_c.value;
				var apl_desc = document.form1.apl_desc?document.form1.apl_desc.value:'N';
				if (anio!='') v_msg = getDBData('<%=request.getContextPath()%>','chkcontrato('+contrato+', '+anio_c+', '+mes_c+', '+cantidad+')', 'dual', '');
				if(v_msg=='Y') showPopWin('../process/pm_run_crea_fact.jsp?fp=genera_factura&contrato='+contrato+'&cantidad='+cantidad+'&anio='+anio_c+'&mes='+mes_c+'&apl_desc='+apl_desc,winWidth*.75,winHeight*.65,null,null,'');
				else alert(v_msg);
			} else if(job==3) showPopWin('../process/pm_run_reaplica_pagos.jsp?fp=process_admin&contrato='+contrato,winWidth*.75,winHeight*.65,null,null,'');
	}
} else if(job==4){
	var contrato = document.form1.id_solicitud.value;
	var anio = document.form1.anio.value;
	var mes = document.form1.mes.value;
	if(contrato=='') alert('Seleccione Contrato!');
	else if(anio=='' || isNaN(anio)) alert('Introduzca Año!');
	else {
		var facturas = getDBData('<%=request.getContextPath()%>','count(*)', 'tbl_pm_factura', 'estado = \'A\' and mes = '+mes+'and anio = '+anio+' and id_sol_contrato = '+contrato);
		var ajustes = getDBData('<%=request.getContextPath()%>','count(*)', 'tbl_pm_ajuste a, tbl_pm_ajuste_det b', 'a.estado = \'A\' and a.compania = b.compania and a.id = b.id and a.id_solicitud = '+contrato+' and exists (select null from tbl_pm_factura f where f.estado = \'A\' and f.id_sol_contrato = '+contrato+' and f.mes = '+mes+'and f.anio = '+anio+' and b.id_ref = f.numero_factura)');
		if(facturas==0) alert('No existen facturas en este periodo!');
		else if(ajustes!=0){ 
			var reamplazar = confirm('Esta Factura tiene ajustes!, al inactivarla se creará otra factura que la reemplazará!');
			if(reamplazar) showPopWin('../process/pm_run_inactiva_facturas.jsp?fp=process_admin&contrato='+contrato+'&anio='+anio+'&mes='+mes+'&reemplazar=S',winWidth*.75,winHeight*.65,null,null,'');
		
		}
		else	showPopWin('../process/pm_run_inactiva_facturas.jsp?fp=process_admin&contrato='+contrato+'&anio='+anio+'&mes='+mes+'&reemplazar=N',winWidth*.75,winHeight*.65,null,null,'');
	}
} else if(job==5){
	var contrato = document.form1.id_solicitud.value;
	var num_pagos = document.form1.num_pagos.value;
	if(contrato=='') alert('Seleccione Contrato!');
	else {
		showPopWin('../process/pm_run_recal_fact.jsp?fp=process_admin&contrato='+contrato+'&num_pagos='+num_pagos,winWidth*.75,winHeight*.65,null,null,'');
	}
}
}

function addSolicitud(){
	abrir_ventana('../planmedico/pm_sel_solicitud.jsp?fp=genera_factura');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td>
						<table align="center" width="100%" cellpadding="0" cellspacing="1">
							<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
							<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("baction","")%>
							<%=fb.hidden("fg",fg)%>
							<%=fb.hidden("clearHT","")%>
							<tr>
								<td>
									<table width="100%" cellpadding="1" cellspacing="0">
										<tr class="TextPanel">
											<td colspan="2">
											Procesos
											</td>
										</tr>
										<tr class="textRow02">
											<td width="75%">
											<%=fb.radio("accion", "1", true, false, false,"text10","","")%>&nbsp;Ejecutar Job de Facturas.
											</td>
											<td><authtype type='50'><%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:ejecutarJob(1);\"")%></authtype></td>
										</tr>
										<tr class="textRow02">
											<td coslpan="2" align="center">Contrato:
											<%=fb.textBox("id_solicitud","",true,false,true,10,"Text12",null,null)%>
											<%=fb.button("btnsolicitud","Contrato",true,false,null,null,"onClick=\"javascript:addSolicitud()\"")%></td>
										</tr>
										<tr class="textRow02">
											<td width="65%">
											<%=fb.radio("accion", "2", true, false, false,"text10","","")%>&nbsp;Crear Facturas.
											&nbsp;
											A&ntilde;o:
											<%=fb.textBox("anio_c","",false,false,false,5,"Text12",null,null)%>
											Mes <%=fb.select("mes_c","01=Enero, 02=Febrero, 03=Marzo, 04=Abril, 05=Mayo, 06=Junio, 07=Julio, 08=Agosto, 09 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre","",false,false,false,0,"Text12","","")%>
											&nbsp;
											<authtype type='54'>
											Aplicar Descuento? <%=fb.select("apl_desc","N=NO,S=SI","",false,false,false,0,"Text12","","")%>
											</authtype>
											</td>
											<td>
											Facturas:
											<%=fb.textBox("cantidad","1",true,false,false,3,"Text10",null,null)%>
											<authtype type='51'>
											<%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:ejecutarJob(2);\"")%>
											</authtype>
											</td>
										</tr>
										<tr class="textRow02">
											<td width="65%">
											<%=fb.radio("accion", "3", true, false, false,"text10","","")%>&nbsp;Reaplicar Pagos.
											</td>
											<td>
											<authtype type='52'>
											<%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:ejecutarJob(3);\"")%>
											</authtype>
											</td>
										</tr>
										<%//if(UserDet.getUserProfile().contains("0")){%>
										<tr class="textRow02">
											<td width="65%">
											<%=fb.radio("accion", "4", true, false, false,"text10","","")%>&nbsp;Anular Facturas
											&nbsp;
											A&ntilde;o:
											<%=fb.textBox("anio","",true,false,false,5,"Text12",null,null)%>
											Mes <%=fb.select("mes","01=Enero, 02=Febrero, 03=Marzo, 04=Abril, 05=Mayo, 06=Junio, 07=Julio, 08=Agosto, 09 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre","",false,false,false,0,"Text12","","")%>
											&nbsp;
											<font class="RedTextBold">Si la factura tiene Ajuste se creará otra factura para reemplazarla y relacionar los ajustes!</font>
											</td>
											<td>
											<authtype type='53'>
											<%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:ejecutarJob(4);\"")%>
											</authtype>
											</td>
										</tr>
										<tr class="textRow02">
											<td width="65%">
											<%=fb.radio("accion", "2", true, false, false,"text10","","")%>&nbsp;Recalcular Facturas Canceladas seg&uacute;n Historial de Pago.
											&nbsp;
											Num. Pagos:
											<%=fb.textBox("num_pagos","",false,false,false,5,"Text12",null,null)%>
											</td>
											<td>
											<authtype type='54'>
											<%=fb.button("recal","Ejecutar",false,false,"text10","","onClick=\"javascript:ejecutarJob(5);\"")%>
											</authtype>
											</td>
										</tr>
										<%//}%>
										</table>
								</td>
							</tr>
							<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</td>
				</tr>
			</table>
		</td>
</tr>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table></td>
	</tr>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
<%
} else throw new Exception(errMsg);
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
