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
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
sct0200_rrhh				RECURSOS HUMANOS\TRANSACCIONES\Aprobar/Rechazar Sol. Vacaciones
======================================================================================================================================================
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
	if(fg.equals("mes")) sql = "select mes||' / '||ano anio,mes as mesCierre,ano as anioActivo, nvl(sp_con_verifica_cierre(cod_cia,mes,ano),' ') as msg,'' as anioDesc, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'SHOW_CIERRE_DET'),'N') show_cierre_det from tbl_con_estado_meses where cod_cia = "+(String) session.getAttribute("_companyId")+" and estatus = 'ACT'";
	else if(fg.equals("TR")) sql = "select (select nombre from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+") nombre_compania, (select ano from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId")+" and estado = 'ACT') anio,'' as anioDesc from dual";
	else sql = "select z.nombre, (select ano from tbl_con_estado_anos where cod_cia = z.codigo and estado = 'TRS') as anio, 13 as mes, (select 'ULTIMO AÑO CERRADO '||max(ano) from tbl_con_estado_anos where cod_cia = z.codigo and estado = 'CER') as anioDesc, (select impuesto_renta * 100 from tbl_con_estado_meses where cod_cia=z.codigo and ano = (select ano from tbl_con_estado_anos where cod_cia = z.codigo and estado = 'TRS') and mes = 13) as impuesto_renta from tbl_sec_compania z where codigo = "+(String) session.getAttribute("_companyId");
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
function eject(){
	var accion = getRadioButtonValue(document.form1.accion);
	var msg ='';
	<%if(fg.equals("anio")){%>
	var impuesto ='';//getRadioButtonValue(document.form1.impuesto);
	var incentivo = 0;//document.form1.incentivo.value;
	var anio = '<%=cdo.getColValue("anio")%>';
	if (anio ==null || anio=='')msg= 'No existe año en transicion!!!'
	<%}%>
	var p_compania = '<%=(String) session.getAttribute("_companyId")%>';
	var v_user = '<%=(String) session.getAttribute("_userName")%>';
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var reloadPage = false;
	if(msg !='')alert(msg);
	else {
	if(confirm('Se ejecutará el proceso marcado!')){
		if(confirm('¿Está seguro que desea ejecutar el proceso marcado?')){

			if(accion==1){
				showPopWin('../common/run_process.jsp?fp=CIERRE&actType=51&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>&mes=<%=cdo.getColValue("mes")%>',winWidth*.75,winHeight*.65,null,null,'');
			} else if(accion==2){
			showPopWin('../common/run_process.jsp?fp=CIERRE&actType=52&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>&mes=<%=cdo.getColValue("mes")%>',winWidth*.75,winHeight*.65,null,null,'');
			} else if(accion==3){
				if(isNaN(incentivo)) alert('Introduzca un valor numérico!');
				else if(incentivo == '') incentivo = 'null';

				showPopWin('../common/run_process.jsp?fp=CIERRE&actType=53&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>&mes=<%=cdo.getColValue("mes")%>&incentivo='+incentivo+'&impuesto='+impuesto,winWidth*.75,winHeight*.65,null,null,'');
			} else if(accion==4){
			if(confirm('Estimado usuario antes de realizar este proceso recuerde realizar los pasos del 1 - 2!! \n Desea continuar ?')){

			var cp_gasto = splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_encab_comprob a',' a.compania =<%=(String) session.getAttribute("_companyId")%> and a.ea_ano = '+anio+' and a.mes =13 and a.status =\'AP\' and a.estado =\'A\' and a.clase_comprob  in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name = \'COMPROB_CR_GASTO_COSTO\'),\',\') from dual)) '));

			var cp_ingreso = splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_encab_comprob a',' a.compania =<%=(String) session.getAttribute("_companyId")%> and a.ea_ano = '+anio+' and a.mes =13 and a.status =\'AP\' and a.estado =\'A\' and a.clase_comprob  in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name = \'COMPROB_CR_INGRESO\'),\',\') from dual)) '));
			if('<%=_comp.getHospital().trim()%>' =="N"){
			var cp_mov = splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*) as nReg ','tbl_con_mov_mensual_cta m, vw_con_catalogo_gral_bal c, tbl_con_cla_ctas ct',' m.cat_cta1 = c.cta1 and m.cat_cta2 = c.cta2 and m.cat_cta3 = c.cta3 and m.cat_cta4 = c.cta4 and m.cat_cta5 = c.cta5 and m.cat_cta6 = c.cta6 and m.pc_compania = c.compania and m.ea_ano = c.ea_ano and m.mes = c.mes and c.recibe_mov = \'S\' and c.tipo_cuenta = ct.codigo_clase and c.compania =<%=(String) session.getAttribute("_companyId")%> and ct.codigo_prin in (\'4\',\'5\',\'6\') and m.mes =13 AND m.ea_ano = '+anio+' and (NVL(m.monto_i, 0) + NVL(c.monto_db_cta, 0) - NVL(c.monto_cr_cta, 0))<> 0 '));}

	if((cp_gasto != 0 && cp_ingreso !=0 && '<%=_comp.getHospital().trim()%>' =="S") || (cp_mov ==0 && '<%=_comp.getHospital().trim()%>' =="N")){
		var ir=document.form1.impuesto_renta.value;
		if(ir.trim()=='')alert('Por favor indicar el Porcentaje de Impuesto de Renta para el próximo año!');
		else showPopWin('../common/run_process.jsp?fp=CIERRE&actType=54&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>&mes=<%=cdo.getColValue("mes")%>&impuesto='+ir,winWidth*.75,winHeight*.65,null,null,'');
	}else alert('No se encontro comprobantes de cierre de gastos, costos e ingresos.. !\n Favor revisar los paso 1 y 2 para continuar!!');

				}else alert('Proceso cancelado!');

			} else if(accion==5 && confirm('Desea Realizar el Cierre Mensual. Realmente esta seguro?')){
			$("#lb-cont").show(0);
			var _d, _x;
			var showCierreDet = "<%=cdo.getColValue("show_cierre_det")==null?"N":cdo.getColValue("show_cierre_det")%>";
			if (showCierreDet=="Y"){
				_d = executeDB('<%=request.getContextPath()%>','delete from tbl_con_verifica_cierre_tmp where field0 ='+ p_compania+' ');

				if (_d) {
					_x = executeDB('<%=request.getContextPath()%>',"call sp_con_verfica_cierre_reg(" + p_compania + ", <%=cdo.getColValue("mesCierre")%>,<%=cdo.getColValue("anioActivo")%>,'<%=userName%>','<%=cDateTime%>' ) ");
				}
			}

				//var v_msg = getDBData('<%=request.getContextPath()%>','sp_con_verifica_cierre(<%=(String) session.getAttribute("_companyId")%>,<%=cdo.getColValue("mesCierre")%>,<%=cdo.getColValue("anioActivo")%>)as msg','dual','');
				var v_msg ='<%=(cdo.getColValue("msg") != null && !cdo.getColValue("msg").trim().equals(""))?cdo.getColValue("msg"):""%>';
				if(v_msg !=''){/* v_msg  var x_msg =replaceAll(v_msg,"|","\n -");*/ alert('Estimado usuario existen transacciones / Comprobantes por Revisar: <%=cdo.getColValue("msg")%>');}
				if(v_msg !=''){
					if (_x){
					$("#detCont").show(0);
					$("#btn-continue").show(0);
					$("#iDetCont").attr("src",'../contabilidad/list_verifica_cierre.jsp');
					$("#lb-cont").hide(0);
					}else showExecRunner();
				}
				else {showPopWin('../common/run_process.jsp?fp=CIERRE&actType=55&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>&mes=<%=cdo.getColValue("mes")%>',winWidth*.75,winHeight*.65,null,null,'');}

				//if(executeDB('<%=request.getContextPath()%>','call sp_con_genera_cierre_mes(' + p_compania + ', \''+v_user+'\')')){reloadPage=true;}
			}
		}
	}}
}

function showExecRunner(){
	if(confirm('Desea Continuar con este proceso???')){
		$("#lb-cont").hide(0);
	return showPopWin('../common/run_process.jsp?fp=CIERRE&actType=55&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>&mes=<%=cdo.getColValue("mes")%>',winWidth*.75,winHeight*.65,null,null,'');
	}
	$("#lb-cont").hide(0);
	return false;
}

function cierreTransitorio(){
if(confirm('¿Está seguro que desea ejecutar el proceso < Cierre Transitorio para el Año <%=cdo.getColValue("anio")%> >?')){
showPopWin('../common/run_process.jsp?fp=CIERRE&actType=50&docType=CIERRE&docId=<%=cdo.getColValue("anio")%>&docNo=<%=cdo.getColValue("anio")%>&anio=<%=cdo.getColValue("anio")%>&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');}else alert('Proceso Cancelado!');
}
function _print(){
	document.getElementById('iDetCont').contentWindow._print();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
							<tr>
								<td><table align="center" width="100%" cellpadding="0" cellspacing="1">
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
											<td><table width="100%" cellpadding="1" cellspacing="0">
													<%if(fg.equals("anio")){%>
													<tr class="TextPanel">
														<td colspan="2">
														Cierre Anual
														</td>
													</tr>
													<tr class="TextHeader02">
														<td><!--Compa&ntilde;&iacute;a a Trabajar:&nbsp;<%//=cdo.getColValue("nombre_compania")%>--></td>
														<td>A&ntilde;o a Trabajar:&nbsp;<%=cdo.getColValue("anio")%>&nbsp;&nbsp;&nbsp;&nbsp;<%=((cdo.getColValue("anio")!="")?"":cdo.getColValue("anioDesc"))%></td>
													</tr>
													<tr class="textRow01">
														<td width="65%">
														<%=fb.radio("accion", "1", true, false, false,"text10","","")%>&nbsp;Generar comprobante de cierre de Gastos y Costos
														</td>
														<td>&nbsp;
														<!--REBAJA POR BENEFICIO O INCENTIVO:&nbsp;<%=fb.decBox("incentivo", "0.00",false,false,false,10,12)%>--></td>
													</tr>
													<tr class="textRow02">
														<td width="65%">
														<%=fb.radio("accion", "2", false, false, false,"text10","","")%>&nbsp;Generar comprobante de cierre de Ingresos
														</td>
														<td>&nbsp;
														<!--IMPUESTO A UTILIZAR:&nbsp;
														<%=fb.radio("impuesto", "1", true, false, false,"text10","","")%>&nbsp;Imp. Normal
														<%=fb.radio("impuesto", "2", false, false, false,"text10","","")%>&nbsp;Imp. CAIR-->
														</td>
													</tr>
													<!--<tr class="textRow01">
														<td width="65%">
														<%=fb.radio("accion", "3", false, false, false,"text10","","")%>&nbsp;Generar comprobante de Resultado de las Operaciones
														</td>
														<td>&nbsp;</td>
													</tr>-->
													<tr class="textRow02">
														<td width="65%">
														<%=fb.radio("accion", "4", false, false, false,"text10","","")%>&nbsp;Realizar Cierre Anual &nbsp; &nbsp;<label class="RedTextBold">% IMPUESTO DE RENTA PROX. A&Ntilde;O: </label><%=fb.decBox("impuesto_renta",cdo.getColValue("impuesto_renta"),true,false,false,11,6.4)%>
														</td>
														<td><%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:eject();\"")%></td>
													</tr>
													<tr class="textRow01">
														<td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Generar Comprobante de Cierre de Costos y Gastos, revisar y mayorizarlo.</td>
													</tr>
													<tr class="textRow01">
														<td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Generar Comprobante de Cierre de Ingresos, revisar y mayorizarlo.</td>
													</tr>
													<!--<tr class="textRow01">
														<td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Generar Comprobante de Resultado de Operaciones, tomando en cuenta rebaja por beneficio e incentivo (en el caso que exista) revisar y mayorizarlo.</td>
													</tr>-->
													<tr class="textRow01">
														<td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Realizar el Cierre Anual.</td>
													</tr>
													<%} else if(fg.equals("mes")){%>
													<tr class="TextPanel">
														<td colspan="2">
														Cierre Mensual
														</td>
													</tr>
													<tr class="TextHeader02">
														<td></td>
														<td>Mes/A&ntilde;o:&nbsp;<%=cdo.getColValue("anio")%><%=cdo.getColValue("anioDesc")%></td>
													</tr>
													<tr class="textRow02">
														<td width="65%">
														<%=fb.radio("accion", "5", true, false, false,"text10","","")%>&nbsp;Realizar Cierre Mensual

								<font color="#FF0000" size="+1"><br>*AL REALIZAR ESTE PROCESO SE GENERARA: </font>
								<font color="#FF0000" size="-1"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*SALDO FINAL PARA EL MES ACTUAL
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*CREACION DE CUENTAS PARA EL SIGUIENTE MES
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*SALDO INICIAL DE CUENTAS PARA EL SIGUIENTE MES
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*SE INACTIVA EL MES ACTUAL
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*SE PROCEDE A ACTIVAR EL SIGUIENTE MES
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* [NOTA: NO HAY REVERSION PARA ESTE PROCESO]
								<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* [NOTA: RECUERDE REALIZAR LAS CONCILIACIONES BANCARIAS]</font>
														</td>
														<td><authtype type='50'><%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:eject();\"")%></authtype>&nbsp;&nbsp;
							<span id="lb-cont" style="display:none">Cargango...</span>
							</td>
													</tr>

							<tr class="textRow02"><td colspan="2">&nbsp;</td></tr>
							<tr class="textRow02" style="display:none" id="btn-continue"><td colspan="2" align="right">
								<%=fb.button("btnContinue","Continuar",false,false,"text10","","onClick=\"javascript:showExecRunner();\"")%>
							&nbsp;
							<%=fb.button("btnPrint","Imprimir",false,false,"text10","","onClick=\"javascript:_print();\"")%></td></tr>
							<tr class="textRow02" style="display:none" id="detCont">
								<td colspan="2">
								 <iframe id="iDetCont" src="" frameborder="0" style="width:100%; height:300px"></iframe>
								</td>
							</tr>




													<%}else if(fg.equals("TR")){%>
													<tr class="TextPanel">
														<td colspan="2">
														Cierre Anual
														</td>
													</tr>
													<tr class="TextHeader02">
														<td>Compa&ntilde;&iacute;a a Trabajar:&nbsp;<%=cdo.getColValue("nombre_compania")%></td>
														<td>A&ntilde;o a Trabajar:&nbsp;<%=cdo.getColValue("anio")%></td>
													</tr>
							 <tr class="textRow02">
														<td width="65%">
														<%=fb.radio("accion", "4", true, false, false,"text10","","")%>&nbsp;Realizar el Cierre Anual Transitorio.
														</td>
														<td><authtype type='51'><%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:cierreTransitorio();\"")%></authtype></td>
													</tr>
							<%}%>
												</table></td>
										</tr>
										<%=fb.formEnd(true)%>
										<!-- ================================   F O R M   E N D   H E R E   ================================ -->
									</table></td>
							</tr>
						</table></td>
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
