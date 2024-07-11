<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iLab" scope="session" class="java.util.Hashtable"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String codigo = request.getParameter("codigo");
String tab = request.getParameter("tab");
String codigoLab = request.getParameter("codigo_lab");
String cds = request.getParameter("cds");
String key = "";

String change = request.getParameter("change");
int labLastLineNo =0;
if (request.getParameter("labLastLineNo") != null) labLastLineNo = Integer.parseInt(request.getParameter("labLastLineNo"));

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (from == null) from = "";
if (codigo == null) codigo = "0";
if (codigoLab == null) codigoLab = "0";
if (tab == null) tab = "0";
if (cds == null) cds = "";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

ArrayList al = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

if (codigo.equals("0")) {
		cdo = SQLMgr.getData("select codigo from tbl_sal_hist_clinica_pre_ope where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_hist_clinica_pre_ope where pac_id = "+pacId+" and admision = "+noAdmision+")");

		if (cdo == null) cdo = new CommonDataObject();
		codigo = cdo.getColValue("codigo","0");
}

cdo = SQLMgr.getData("select to_char(fecha_eval, 'dd/mm/yyyy') fecha_eval, to_char(hora_eval, 'hh12:mi:ss am') hora_eval, cod_diag, cod_proc, (select nvl(observacion,nombre) from tbl_cds_diagnostico where codigo = cod_diag and rownum  = 1) desc_diag, (select nvl(observacion,descripcion) from tbl_cds_procedimiento where codigo = cod_proc and rownum  = 1 ) desc_proc from tbl_sal_hist_clinica_pre_ope where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+codigo);

if (cdo == null) cdo = new CommonDataObject();

if (!codigo.equals("0")) {
		if (!viewMode) modeSec = "edit";
}

ArrayList alLab = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

if (request.getMethod().equalsIgnoreCase("GET")){

		al = SQLMgr.getDataList("select codigo,to_char(fecha,'dd/mm/yyyy') fecha ,to_char(fecha,'hh12:mi:ss am') hora from tbl_sal_hist_cli_lab where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc");

		String active0 = "", active1 = "", active2 = "";

		if (tab.equals("0")) active0 = "active";
		else if (tab.equals("1")) active1 = "active";
		else if (tab.equals("2")) active2 = "active";

		ArrayList alA = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = "+codigo+" and tipo = 'A' and a.estado = 'A' order by a.orden");

		ArrayList alB = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = "+codigo+" and tipo = 'B' and a.estado = 'A' order by a.orden");

		ArrayList alC = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = "+codigo+" and tipo = 'C' and a.estado = 'A' order by a.orden, a.observacion");

	if (change == null && !codigo.equals("0")) {
		iLab.clear();

		alLab = SQLMgr.getDataList("select codigo, laboratorio, resultado, to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, nec_cruce, cant_cruce, consulta_esp, observ_esp from tbl_sal_hist_cli_lab where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_eval = "+codigo+" order by codigo");

		labLastLineNo = alLab.size();
		for (int i=0; i<alLab.size(); i++) {
			CommonDataObject cdoLab = (CommonDataObject)alLab.get(i);
			cdoLab.setKey(i);
			cdoLab.setAction("U");

			try{
				iLab.put(cdoLab.getKey(), cdoLab);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (alLab.size() == 0) {
			CommonDataObject cdoLab = new CommonDataObject();

			cdoLab.setKey(iLab.size() + 1);
			cdoLab.setAction("I");
			cdoLab.addColValue("codigo", "0");


			try {
				iLab.put(cdoLab.getKey(), cdoLab);
			}
			catch(Exception e){
				System.err.println(e.getMessage());
			}
		}
	}//change=null

%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Expediente Cellbyte</title>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
		document.title = 'Historia Clínica Pre Operatoria - '+document.title;
		var noNewHeight = true;

		$(function(){
				$('iframe').iFrameResize({
					log: false
				});

				$("input:radio[name*='nec_cruce']").click(function(){
						var i = this.name.replace ( /[^\d.]/g, '' );
						if (this.value == 'S') $("#cant_cruce"+i).prop("readOnly", false);
						else $("#cant_cruce"+i).prop("readOnly", true).val("");
				});

				$("input:radio[name*='consulta_esp']").click(function(){
						var i = this.name.replace ( /[^\d.]/g, '' );
						if (this.value == 'S') $("#observ_esp"+i).prop("readOnly", false);
						else $("#observ_esp"+i).prop("readOnly", true).val("");
				});

				$("a[role='tab']").click(function(){
						var href = $(this).attr('href');
						if (href == '#laboratorios') $("#btn_hist").prop('disabled', false)
						else $("#btn_hist").prop('disabled', true)
				});

		});

		function addLab(){
				// window.location = '../expediente3.0/exp_hist_clinica_pre_ope.jsp?modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo=0&desc=<%=desc%>&tab=1&codigo_lab=0&cds=<%=cds%>';

				$("#form1").find("#baction").val("+");
				$("#form1").submit();
		}

		function displayLab(codigoLab) {
				window.location = '../expediente3.0/exp_hist_clinica_pre_ope.jsp?modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo=0&desc=<%=desc%>&cds=<%=cds%>&blockLab=Y&tab=1&codigo_lab='+codigoLab;
		}

		function doPrint() {
				abrir_ventana('../expediente3.0/print_hist_clinica_pre_ope.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>');
		}

		function addDx(){
				abrir_ventana1('../common/search_diagnostico.jsp?fp=hist_cli_pre_ope&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
		}
		function procedimientoList(){
				abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=hist_cli_pre_ope');
		}

		function verHistorial() {
				$("#hist_container").toggle();
		}
		function canSubmit() {
				var tota = 0, totc = 0;
				var proceed = true;
				$("input:radio.grupo-a").each(function(){
						if(this.checked && this.value == 'S') tota++;
				});
				$("input:radio.grupo-c").each(function(){
						if(this.checked && this.value == 'S') totc++;
				});

				if (tota > 1) {
						proceed = false;
						parent.CBMSG.error("No puedes seleccionar mas de un 'SI' Para 'CAPACIDAD FUNCIONAL'");
				} else if (totc > 1) {
						proceed = false;
						parent.CBMSG.error("No puedes seleccionar mas de un 'SI' Para 'ESTRATIFICACION DE RIESGO QUIRURGICO'");
				}
				return proceed;
		}

		function doPrintHistory() {
				abrir_ventana('../expediente3.0/print_unified_exp.jsp?modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>&cds=<%=cds%>&is_tmp=Y&sections=2,27,4,157,11,10,77,166&custom_first_title=HISTORIA%20CLINICA%20PRE%20OPERATORIA');
		}
</script>
</head>
<body class="body-form">
		<div class="row">
				<div class="table-responsive" data-pattern="priority-columns">

						<div class="headerform">
								<table cellspacing="0" class="table pull-right table-striped table-custom-1">
										<tr>
												<td>
														<%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:doPrint()\"")%>

														<!--<button type="button" class="btn btn-inverse btn-sm" onclick="javascript:doPrintHistory()"><i class="fa fa-print fa-lg"></i> Historial Cl&iacute;nica</button>-->

														<button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()" id="btn_hist"<%=codigoLab.equals("0")?" disabled":""%>>
																<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
														</button>
												</td>
										</tr>
								</table>
						</div>

						<ul class="nav nav-tabs" role="tablist">
								<li role="presentation" class="<%=active0%>">
										<a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Datos Generales</b></a>
								</li>
								<%if (!modeSec.equalsIgnoreCase("add")){%>
								<li role="presentation" class="<%=active1%>">
										<a href="#laboratorios" aria-controls="laboratorios" role="tab" data-toggle="tab"><b>Pruebas de laboratorio y gabinete</b></a>
								</li>
								<li role="presentation" class="<%=active2%>">
										<a href="#documentos" aria-controls="documentos" role="tab" data-toggle="tab"><b>Documentos</b></a>
								</li>
								<%}%>
						</ul>

						<div class="tab-content">

								<!-- Generales -->
								<div role="tabpanel" class="tab-pane <%=active0%>" id="generales">

										<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
										<%=fb.formStart(true)%>
										<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
										<%fb.appendJsValidation("if(!canSubmit()) {error++;}");%>
										<%=fb.hidden("baction","")%>
										<%=fb.hidden("mode",mode)%>
										<%=fb.hidden("modeSec",modeSec)%>
										<%=fb.hidden("seccion",seccion)%>
										<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
										<%=fb.hidden("dob","")%>
										<%=fb.hidden("codPac","")%>
										<%=fb.hidden("pacId",pacId)%>
										<%=fb.hidden("noAdmision",noAdmision)%>
										<%=fb.hidden("desc",desc)%>
										<%=fb.hidden("codigo",codigo)%>
										<%=fb.hidden("tab", "0")%>
										<%=fb.hidden("codigo_lab", codigoLab)%>
										<%=fb.hidden("cds", cds)%>

										<table cellspacing="0" class="table table-small-font table-bordered table-striped">

												<tr>
													<td class="controls form-inline">
														<b>Diagn&oacute;stico:</b>
														<%=fb.textBox("diag",cdo.getColValue("cod_diag"),false,false,true,5,"form-control input-sm",null,"")%>
														<%=fb.textBox("diag_desc",cdo.getColValue("desc_diag"),false,false,true,35,"form-control input-sm",null,"")%>
														<%=fb.button("btn_dx","...",true,viewMode,null,null,"onClick=\"javascript:addDx()\"")%>

														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<b>Procedimiento:</b>
														<%=fb.textBox("procedimiento",cdo.getColValue("cod_proc"),false,false,true,5,"form-control input-sm","",null)%>
														<%=fb.textBox("desc_proc", cdo.getColValue("desc_proc"),false,true,viewMode,35,"form-control input-sm","",null)%>
														<%=fb.button("oper","...",true,viewMode,null,null,"onClick=\"javascript:procedimientoList()\"","seleccionar Operación")%>
													</td>
												</tr>

												<tr>
														<td class="controls form-inline">
																<b><cellbytelabel>Fecha de evaluaci&oacute;n preoperatoria</cellbytelabel>:</b>&nbsp;
																<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
																<jsp:param name="noOfDateTBox" value="1" />
																<jsp:param name="clearOption" value="true" />
																<jsp:param name="nameOfTBox1" value="fecha_eval" />
																<jsp:param name="format" value="dd/mm/yyyy" />
																<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_eval", cDateTime.substring(0,10))%>" />
																<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
																</jsp:include>
																&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
																<b><cellbytelabel>Hora de evaluaci&oacute;n preoperatoria</cellbytelabel>:</b>&nbsp;
																		<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
																		<jsp:param name="noOfDateTBox" value="1" />
																		<jsp:param name="clearOption" value="true" />
																		<jsp:param name="nameOfTBox1" value="hora_eval" />
																		<jsp:param name="format" value="hh12:mi:ss am" />
																		<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_eval", " ").trim()%>" />
																		<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
																		</jsp:include>
																</td>
														</tr>

														<%
														int realSize = 0;
														%>
														<tr>
																<td>
																		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
																				<%for (int a = 0; a < alA.size(); a++) {
																						CommonDataObject cdoA = (CommonDataObject) alA.get(a);

																						if (a == 0) {
																				%>
																						<tr class="bg-headtabla">
																								<td colspan="4" align="center"><%=cdoA.getColValue("titulo")%></td>
																						</tr>
																						<tr class="bg-headtabla2" align="center">
																								<td>METs</td>
																								<td>SI</td>
																								<td>NO</td>
																								<td>DESCRIPCION DE LA ACTIVIDAD REALIZADA</td>
																						</tr>
																						<%}%>

																						<tr>
																								<td><%=cdoA.getColValue("descripcion")%></td>
																								<td align="center">
																										<%=fb.radio("valor"+realSize,"S",cdoA.getColValue("valor")!=null&&cdoA.getColValue("valor").equalsIgnoreCase("S"),viewMode,false,"grupo-a",null,"")%>
																								</td>
																								<td align="center">
																									 <%=fb.radio("valor"+realSize,"N",cdoA.getColValue("valor")!=null&&cdoA.getColValue("valor").equalsIgnoreCase("N"),viewMode,false,"grupo-a",null,"")%>
																								</td>
																								<td>
																										<em><b><%=cdoA.getColValue("observacion")%></b></em>
																								</td>
																						</tr>
																				<%=fb.hidden("cod_param"+realSize, cdoA.getColValue("codigo"))%>
																				<%=fb.hidden("action"+realSize, cdoA.getColValue("action"))%>
																				<%
																				realSize++;
																				}%>
																		</table>
																</td>
														</tr>

														<tr>
																<td>
																		<table width="100%">
																		<tr>
																		<td width="50%">
																		<table cellspacing="0" class="table table-small-font table-bordered table-striped">

																				<%for (int b = 0; b < alB.size(); b++) {
																						CommonDataObject cdoB = (CommonDataObject) alB.get(b);

																						if (b == 0) {
																				%>
																						<tr class="bg-headtabla2" align="center">
																								<td><%=cdoB.getColValue("titulo")%></td>
																								<td>SI</td>
																								<td>NO</td>
																						</tr>
																						<%}%>

																						<tr>
																								<td><%=cdoB.getColValue("descripcion")%></td>
																								<td align="center">
																										<%=fb.radio("valor"+realSize,"S",cdoB.getColValue("valor")!=null&&cdoB.getColValue("valor").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>
																								</td>
																								<td align="center">
																									 <%=fb.radio("valor"+realSize,"N",cdoB.getColValue("valor")!=null&&cdoB.getColValue("valor").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>
																								</td>
																						</tr>
																						<%if(b+1 == alB.size()){%>
																								<tr>
																										<td align="center"><b>Total</b></td>
																										<td></td>
																										<td></td>
																								</tr>
																						<%}%>
																				<%=fb.hidden("cod_param"+realSize, cdoB.getColValue("codigo"))%>
																				<%=fb.hidden("action"+realSize, cdoB.getColValue("action"))%>
																				<%
																				realSize++;
																				}%>

																		</table>
																		</td>


																		<td width="50%" style="vertical-align:top">
																		<table cellspacing="0" class="table table-small-font table-bordered table-striped">

																		<%
																		String groupC = "";
																		for (int c = 0; c < alC.size(); c++) {
																						CommonDataObject cdoC = (CommonDataObject) alC.get(c);

																						if (c == 0) {
																				%>
																						<tr class="bg-headtabla2" align="center">
																								<td><%=cdoC.getColValue("titulo")%><br>&nbsp;</td>
																								<td>SI</td>
																								<td>NO</td>
																						</tr>
																						<%}%>

																						<%if(!groupC.equalsIgnoreCase(cdoC.getColValue("observacion"))){%>
																								<tr>
																										<td colspan="3"><b><%=cdoC.getColValue("observacion")%></b></td>
																								</tr>
																						<%}%>

																						<tr>
																								<td><%=cdoC.getColValue("descripcion")%></td>
																								<td align="center">
																										<%=fb.radio("valor"+realSize,"S",cdoC.getColValue("valor")!=null&&cdoC.getColValue("valor").equalsIgnoreCase("S"),viewMode,false,"grupo-c",null,"")%>
																								</td>
																								<td align="center">
																									 <%=fb.radio("valor"+realSize,"N",cdoC.getColValue("valor")!=null&&cdoC.getColValue("valor").equalsIgnoreCase("N"),viewMode,false,"grupo-c",null,"")%>
																								</td>
																						</tr>
																				<%=fb.hidden("cod_param"+realSize, cdoC.getColValue("codigo"))%>
																				<%=fb.hidden("action"+realSize, cdoC.getColValue("action"))%>
																				<%
																				realSize++;

																				groupC = cdoC.getColValue("observacion");
																				}%>

																		</table>
																		</td>
																		</tr>
																		</table>
																</td>
														</tr>







										</table>
										<div class="footerform">
												<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
														<tr>
														<td>
																<%=fb.hidden("saveOption","O")%>
																<%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
														</td>
														</tr>
												</table>
										</div>
										<%=fb.hidden("realSize", ""+realSize)%>
										<%=fb.formEnd(true)%>
								</div> <!-- Generales -->

								<!-- Laboratorios -->
								<div role="tabpanel" class="tab-pane <%=active1%>" id="laboratorios">

										<%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
										<%=fb.hidden("desc",desc)%>
										<%=fb.hidden("codigo",codigo)%>
										<%=fb.hidden("tab", "1")%>
										<%=fb.hidden("codigo_lab", codigoLab)%>
										<%=fb.hidden("labSize",""+iLab.size())%>
										<%=fb.hidden("labLastLineNo",""+labLastLineNo)%>

										<table cellspacing="0" class="table table-small-font table-bordered table-striped" id="hist_container" style="display:none">
												<tr class="bg-headtabla2">
														<td>C&oacute;digo</td>
														<td>Fecha</td>
														<td>Hora</td>
												</tr>
												<%for (int h = 0; h<al.size(); h++){
														CommonDataObject cdo2 = (CommonDataObject) al.get(h);
												%>
												<tr class="pointer" onclick="displayLab('<%=cdo2.getColValue("codigo")%>')">
														<td><%=cdo2.getColValue("codigo")%></td>
														<td><%=cdo2.getColValue("fecha")%></td>
														<td><%=cdo2.getColValue("hora")%></td>
												</tr>
												<%}%>
										</table>

										<%
										CommonDataObject dhf = new CommonDataObject();
										%>

										<table cellspacing="0" class="table table-small-font table-bordered table-striped">
												<thead>
														<tr class="bg-headtabla">
																<td width="39%">Prueba</td>
																<td width="39%">Resultado</td>
																<td width="17%" align="center">Fecha</td>
																<td width="5%" align="center">
																		<%=fb.button("add","+",false,viewMode,"btn btn-primary btn-xs",null,"onClick='addLab()'","Agregar  Laboratorios")%>
																</td>
														</tr>
												</thead>

												<%
													alLab.clear();
													alLab = CmnMgr.reverseRecords(iLab);
													for (int l=0; l<iLab.size(); l++) {
														key = alLab.get(l).toString();
														dhf = (CommonDataObject) iLab.get(key);
												%>
												<%=fb.hidden("remove"+l,"")%>
												<%=fb.hidden("action"+l,dhf.getAction())%>
												<%=fb.hidden("key"+l,dhf.getKey())%>
												<%=fb.hidden("codigo"+l,dhf.getColValue("codigo"))%>

												<%//if(dhf.getAction().equalsIgnoreCase("D")){%>
												<%//}else{%>

												<tr>
														<td>
																<%=fb.textarea("laboratorio"+l,dhf.getColValue("laboratorio"),false,false,request.getParameter("blockLab")!=null?true:viewMode,40,1,0,"form-control input-sm","","")%>
														</td>
														<td>
																<%=fb.textarea("resultado"+l,dhf.getColValue("resultado"),false,false,request.getParameter("blockLab")!=null?true:viewMode,40,1,0,"form-control input-sm","","")%>
														</td>
														<td class="controls form-inline">
																<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
																		<jsp:param name="noOfDateTBox" value="1" />
																		<jsp:param name="clearOption" value="true" />
																		<jsp:param name="nameOfTBox1" value="<%="fecha"+l%>" />
																		<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
																		<jsp:param name="valueOfTBox1" value="<%=dhf.getColValue("fecha", " ").trim()%>" />
																		<jsp:param name="readonly" value="<%=(request.getParameter("blockLab")!=null||viewMode)?"y":"n"%>"/>
																</jsp:include>
														</td>
														<td>
															<%=fb.submit("rem"+l,"x",false,(!dhf.getColValue("codigo", "0").equals("0")||viewMode),"btn btn-primary btn-xs",null,"onClick=\"removeItem('"+fb.getFormName()+"',"+l+");__submitForm(this.form, this.value)\"","Eliminar")%>
														</td>
												</tr>

												<tr>
														<td colspan="4" class="controls form-inline">
																Necesidad de cruce:&nbsp;
																<label class="pointer">
																<%=fb.radio("nec_cruce"+l,"S",dhf.getColValue("nec_cruce")!=null&&dhf.getColValue("nec_cruce").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;SI
																</label>
																&nbsp;&nbsp;
																<label class="pointer">
																<%=fb.radio("nec_cruce"+l,"N",dhf.getColValue("nec_cruce")!=null&&dhf.getColValue("nec_cruce").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;NO
																&nbsp;&nbsp;&nbsp;&nbsp;
																Cuantas unidaddes:&nbsp;
																<%=fb.textBox("cant_cruce"+l,dhf.getColValue("cant_cruce"),false,false,true,5,"form-control input-sm",null,"")%>
																</label>
																&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

																Consulta con especialista:&nbsp;
																<label class="pointer">
																<%=fb.radio("consulta_esp"+l,"S",dhf.getColValue("consulta_esp")!=null&&dhf.getColValue("consulta_esp").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;SI
																</label>
																&nbsp;&nbsp;
																<label class="pointer">
																<%=fb.radio("consulta_esp"+l,"N",dhf.getColValue("consulta_esp")!=null&&dhf.getColValue("consulta_esp").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;NO
																&nbsp;&nbsp;&nbsp;&nbsp;
																<%=fb.textBox("observ_esp"+l,dhf.getColValue("observ_esp"),false,false,true,40,"form-control input-sm",null,"")%>
														</td>
												</tr>
												<%//}%>
												<%}%>
										</table>

										<div class="footerform">
												<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
														<tr>
														<td>
																<%=fb.hidden("saveOption","O")%>
																<%if(request.getParameter("blockLab")==null){%>
																		<%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
																<%}%>
														</td>
														</tr>
												</table>
										</div>
										<%=fb.hidden("realSize", ""+realSize)%>
										<%=fb.formEnd(true)%>

								</div>


							 <!-- Documentos -->
								<div role="tabpanel" class="tab-pane <%=active2%>" id="documentos">

									 <table width="100%" cellpadding="1" cellspacing="1" >
												<tr>
														<td>
																<iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=hist_cli_pre_ope&docId=46"></iframe>
														</td>
												</tr>
										</table>

								</div>

						</div> <!-- Tabs container -->
				</div>
		</div>
</body>
</html>
<%
} else {

		String saveOption = request.getParameter("saveOption");
		String baction = request.getParameter("baction");
		int realSize = Integer.parseInt(request.getParameter("realSize"));

		al.clear();
		alLab.clear();
		iLab.clear();

		String itemRemoved = "";
		int labSize = 0;
		if (request.getParameter("labSize") != null)
		labSize = Integer.parseInt(request.getParameter("labSize"));

		if (tab.equals("0")) {
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_hist_clinica_pre_ope");
				cdo.addColValue("cod_diag", request.getParameter("diag"));
				cdo.addColValue("cod_proc", request.getParameter("procedimiento"));
				cdo.addColValue("fecha_eval", request.getParameter("fecha_eval"));
				cdo.addColValue("hora_eval", request.getParameter("hora_eval"));

				if (codigo.equals("0")) {
						CommonDataObject cdo1 = SQLMgr.getData("select nvl(max(codigo),0)+1 nextId from tbl_sal_hist_clinica_pre_ope where pac_id = "+pacId+" and admision = "+noAdmision);

						cdo.addColValue("codigo", cdo1.getColValue("nextId"));
						cdo.addColValue("pac_id", pacId);
						cdo.addColValue("admision", noAdmision);
						cdo.addColValue("fecha_creacion", cDateTime);
						cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));

						cdo.setAction("I");

						codigo = cdo1.getColValue("nextId");
				} else {
						cdo.setWhereClause("codigo = "+codigo+" and pac_id = "+pacId+" and admision = "+noAdmision);
						cdo.addColValue("codigo", codigo);
						cdo.setAction("U");

						cdo.addColValue("fecha_modificacion", cDateTime);
						cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				}

				for (int i = 0; i < realSize; i++) {

						if (request.getParameter("valor"+i) != null) {
								CommonDataObject cdo2 = new CommonDataObject();
								cdo2.setTableName("tbl_sal_hist_clini_pre_ope_det");
								cdo2.addColValue("valor", request.getParameter("valor"+i));

								if (request.getParameter("action"+i) != null && request.getParameter("action"+i).equalsIgnoreCase("U")) {
										cdo2.setWhereClause("codigo_eval = "+cdo.getColValue("codigo")+" and pac_id = "+pacId+" and admision = "+noAdmision+" and cod_param = "+request.getParameter("cod_param"+i));
										cdo2.setAction("U");
								} else {
										cdo2.addColValue("codigo_eval", cdo.getColValue("codigo"));
										cdo2.addColValue("pac_id", pacId);
										cdo2.addColValue("admision", noAdmision);
										cdo2.addColValue("cod_param", request.getParameter("cod_param"+i));
										cdo2.setAction("I");
								}

								al.add(cdo2);
						}
				}

				if (al.size() == 0) {
						CommonDataObject cdo2 = new CommonDataObject();
						cdo2.setTableName("tbl_sal_hist_clini_pre_ope_det");
						cdo2.setWhereClause("codigo_eval = "+codigo+" and pac_id = "+pacId+" and admision = "+noAdmision);
						cdo2.setAction("I");

						al.add(cdo2);
				}

				if (baction.equalsIgnoreCase("Guardar")){
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						SQLMgr.save(cdo, al, true ,true, true, true);
						ConMgr.clearAppCtx(null);
				}

		} // tab 0
		else if (tab.equals("1")) {

			CommonDataObject cdo2 = new CommonDataObject();

			System.out.println(".................................................. baction <> baction = "+baction);

			for (int i=0; i<labSize; i++){

						cdo2 = new CommonDataObject();
						cdo2.setTableName("tbl_sal_hist_cli_lab");

						cdo2.setWhereClause("pac_id="+pacId+" and admision = "+noAdmision+" and codigo ="+request.getParameter("codigo"+i));

						cdo2.addColValue("laboratorio", request.getParameter("laboratorio"+i));
						cdo2.addColValue("resultado", request.getParameter("resultado"+i));
						cdo2.addColValue("fecha", request.getParameter("fecha"+i));
						cdo2.addColValue("nec_cruce", request.getParameter("nec_cruce"+i));
						cdo2.addColValue("cant_cruce", request.getParameter("cant_cruce"+i));
						cdo2.addColValue("consulta_esp", request.getParameter("consulta_esp"+i));
						cdo2.addColValue("observ_esp", request.getParameter("observ_esp"+i));


						if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals("")) {
								cdo2.setAutoIncCol("codigo");
								cdo2.addPkColValue("codigo","");
								cdo2.setAutoIncWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
								cdo2.addColValue("pac_id", pacId);
								cdo2.addColValue("admision", noAdmision);
								cdo2.addColValue("codigo_eval", codigo);
								cdo2.addColValue("codigo",request.getParameter("codigo"+i));
						} else {
							 cdo2.addColValue("status","I");
							 cdo2.addColValue("codigo", request.getParameter("codigo"+i));
						}

						cdo2.setAction(request.getParameter("action"+i));
						cdo2.setKey(i);
						if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
								itemRemoved = cdo2.getKey();
								System.out.println("................................. itemRemoved = "+itemRemoved);
								if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
								else cdo2.setAction("D");

								System.out.println("................................. cdo2.getAction() = "+cdo2.getAction());
						 }

							if (!cdo2.getAction().equalsIgnoreCase("X")) {
								try {
									iLab.put(cdo2.getKey(),cdo2);
									alLab.add(cdo2);
								}
								catch(Exception e) {
									System.err.println(e.getMessage());
								}
							}
				} // for

				if (!itemRemoved.equals("")){
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+request.getParameter("cds")+"&desc="+desc+"&tab=1&seccion="+seccion);
					return;
				}

				if (baction.equals("+")) {
					cdo2 = new CommonDataObject();

					cdo2.addColValue("codigo","0");

					cdo2.setAction("I");
					cdo2.setKey(iLab.size()+1);

					System.out.println(".................................................. here = "+baction);
					try{
						iLab.put(cdo2.getKey(),cdo2);
					}
					catch(Exception e){
						System.err.println(e.getMessage());
					}
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+request.getParameter("cds")+"&desc="+desc+"&tab=1&seccion="+seccion);
					return;
				}

				if (baction.equalsIgnoreCase("Guardar")){

					if (alLab.size() == 0) {
							cdo2 = new CommonDataObject();
							cdo2.setTableName("tbl_sal_hist_cli_lab");
							cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision"));
							cdo2.setAction("I");
							alLab.add(cdo2);
					}

					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
					 SQLMgr.saveList(alLab,true);
					ConMgr.clearAppCtx(null);
				}
		}
%>

<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>&tab=<%=tab%>&codigo_lab=<%=codigoLab%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>