<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.facturacion.NotasAjustes"%>
<%@ page import="issi.facturacion.NotasAjustesDet"%>
<%@ page import="java.util.StringTokenizer"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iNotasCargo" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vNotasCargo" scope="session" class="java.util.Vector"/>
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
NotasAjustes ajuste = new NotasAjustes();
CommonDataObject cdoParam = new CommonDataObject();
String key = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String codigo = request.getParameter("codigo");
String cod = request.getParameter("cod");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String factura = request.getParameter("factura");
String nt =request.getParameter("nt");
String compania = request.getParameter("compania");
String desc = "",st="";
String tr = request.getParameter("tr");//para controlar los estados.
String ref_id = request.getParameter("ref_id");
String ref_type = request.getParameter("ref_type");
String validaSaldo ="N";
String pValidaSaldo ="N";
if(fp==null) fp = "cargo_dev";
if (compania == null) compania = (String) session.getAttribute("_companyId");
if(tr==null) tr = "";
if (cod == null) cod = "";
boolean viewMode = false;
boolean flag = true;
int cargoLastLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (nt == null) nt = "C";
if (mode == null) mode = "add";
if (request.getParameter("cargoLastLineNo") != null) cargoLastLineNo = Integer.parseInt(request.getParameter("cargoLastLineNo"));
cod = cod.replace("~",",");
if (ref_type == null) ref_type = "";
if (ref_id == null) ref_id = "";
String  docAjFisico= "N";
try {docAjFisico =java.util.ResourceBundle.getBundle("issi").getString("docAjFisico");}catch(Exception e){ docAjFisico = "N";}
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");sbSql.append(session.getAttribute("_companyId"));sbSql.append(",'FACT_AJ_VALIDA_SALDO'),'N') as pValidaSaldo from dual");
	cdoParam = SQLMgr.getData(sbSql);
	if(cdoParam!=null && !cdoParam.getColValue("pValidaSaldo").equals("")) pValidaSaldo = cdoParam.getColValue("pValidaSaldo");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	StringTokenizer stk = new StringTokenizer(cod,",");
		while (stk.hasMoreTokens()){
			if(flag && (codigo==null || codigo.trim().equals(""))){
				codigo = stk.nextToken();
			} else break;
		}
	if (mode.equalsIgnoreCase("add"))
	{
		iNotasCargo.clear();
		vNotasCargo.clear();
		codigo = "0";
		ajuste = new NotasAjustes();
		ajuste.setFecha(cDateTime.substring(0,10));
		ajuste.setFechaCreacion(cDateTime);
		ajuste.setUsuarioCreacion((String) session.getAttribute("_userName"));
		ajuste.setCtrlAjuste("N");
		ajuste.setFactura(factura);
	}
	else
	{
		if (codigo == null) throw new Exception("El codigo de la nota de ajuste no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select a.compania, a.codigo, nvl(a.explicacion,' ') as explicacion, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy  hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.tipo_doc as tipoDoc, a.factura, a.tipo_ajuste as tipoAjuste, nvl(a.recibo,' ') as recibo, a.factura_aplic as facturaAplic, a.total, a.estatus, nvl(''||a.referencia,' ') as referencia, a.act_sn as actSn, nvl(a.ctrl_ajuste,'N') as ctrlAjuste, a.pase, nvl(a.comprobante,'N') as paseK, a.ref_reversion as refReversion, a.provincia, a.sigla, a.tomo,a.asiento, a.anio_parametro as anioParametro, a.mes_parametro as mesParametro, (select descripcion from tbl_fac_tipo_ajuste where codigo = a.tipo_ajuste and compania = a.compania) as descAjuste, a.status, nvl(tipo,'C') as tipo, nvl(tipo_transaccion,'C') as tipoTransaccion, (select pac_id from tbl_fac_factura where codigo = a.factura and compania = a.compania) as pacId, (select admi_secuencia from tbl_fac_factura where codigo = a.factura and compania = a.compania) as admision from tbl_con_adjustment a where a.codigo = ");
		sbSql.append(codigo);
		sbSql.append(" and a.compania = ");
		sbSql.append(compania);
		System.out.println("SQL:\n"+sbSql.toString());
		ajuste = (NotasAjustes) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),NotasAjustes.class);

		if (ajuste != null)
		{
			fg = ajuste.getTipo();
			nt = ajuste.getTipoTransaccion();
			pacienteId = ajuste.getPacId();
			noAdmision = ajuste.getAdmision();
			if (mode.equalsIgnoreCase("view") || (!mode.equalsIgnoreCase("edit") && !ajuste.getStatus().trim().equals("O")))
			{
				viewMode = true;
				mode = "view";
			}
		}

		if (change == null)
		{
			iNotasCargo.clear();
			vNotasCargo.clear();

			sbSql = new StringBuffer();
			sbSql.append("select decode(a.tipo,'H',a.medico,'E',to_char(a.empresa)) as detalleServicio, decode(a.tipo,'C',to_char(a.centro),'E',to_char(a.empresa),'H',a.medico) as desc_Centro, a.nota_ajuste as notaAjuste, a.compania, a.secuencia, a.descripcion, a.monto, a.tipo, a.lado_mov as ladoMov, a.centro, a.empresa, a.medico, a.factura, a.cod_banco as codBanco, coalesce((select descripcion from tbl_cds_centro_servicio where codigo = a.centro),(select nombre from tbl_adm_empresa where codigo = a.empresa), (select primer_nombre||' '||segundo_nombre||' '||decode(apellido_de_casada,null,primer_apellido||' '||segundo_apellido,apellido_de_casada) from tbl_adm_medico where codigo = a.medico)) as descCentro, a.cuenta_banco as cuentaBanco, nvl(a.pagado,'N') as pagado, a.monto_saldo as montoSaldo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.num_cheque as numCheque, a.paciente, a.amision, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.cliente_emp as clienteEmp, a.farhosp, a.afecta, a.pase, a.pase_k as paseK, a.puntos_sino as puntosSino, a.fact_clinica as factClinica, a.pac_id as pacId, a.service_type as serviceType, (select descripcion from tbl_cds_tipo_servicio where codigo = a.service_type) as descTipoServicio,  a.monto montoCargo, decode(a.tipo,'H',(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo =a.medico),'E',to_char(a.empresa)) as regMedico from tbl_con_adjustment_det a where a.nota_ajuste = ");
			sbSql.append(codigo);
			sbSql.append(" and a.compania = ");
			sbSql.append(compania);
			System.out.println("SQL:\n"+sbSql.toString());

			al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),NotasAjustesDet.class);
			cargoLastLineNo = al.size();
			for (int i=0; i<al.size(); i++)
			{
				NotasAjustesDet notas = (NotasAjustesDet) al.get(i);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				notas.setKey(key);

				try
				{
					iNotasCargo.put(notas.getKey(), notas);
					 if(nt != null && nt.trim().equals("H"))
					{
						vNotasCargo.addElement(notas.getServiceType()+"-"+notas.getCentro()+"-"+notas.getDetalleServicio());
					}else vNotasCargo.addElement(notas.getServiceType()+"-"+notas.getCentro());

				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}//for i
		}//if change
	}

	if(nt != null && nt.equals("C") && fg != null  && fg.equals("C") )
	desc="AJUSTE DE CARGO";
	else if(nt != null && nt.equals("D") && fg != null  && fg.equals("D") ){desc="AJUSTE DE DEVOLUCION";validaSaldo = "S";}
	if(nt != null && nt.equals("H") && fg != null  && fg.equals("C") )
	desc="AJUSTE A CARGO DE HONORARIOS";
	else if(nt != null && nt.equals("H") && fg != null  && fg.equals("D") ){desc="AJUSTE A DEVOLUCION DE HONORARIOS";validaSaldo = "S";}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Notas de Ajuste a Cargos y Devoluciones - '+document.title;
function setBAction(fName,actionValue){document.forms[fName].baction.value = actionValue;window.frames['itemFrame'].doSubmit();}
function checkPagos(){var pagos = getDBData('<%=request.getContextPath()%>','chkPagoFact(<%=(String) session.getAttribute("_companyId")%>,  \'<%=factura%>\')','dual','');if(pagos=='S') CBMSG.warning('Esta factura tiene pagos aplicados, Favor Verifique los Saldo de los centros que tienen Distribuciones!');}
function saveMethod(){var saldo =-1.0;<%if(validaSaldo.trim().equals("S")&& pValidaSaldo.trim().equals("S")){%>checkPagos();saldo = parseFloat(getDBData('<%=request.getContextPath()%>','nvl(fn_cja_saldo_fact(null,<%=(String) session.getAttribute("_companyId")%>, \'<%=factura%>\',null),0)','dual',''));<%}%>
if(saldo != 0){if(form0Validation()){if(window.frames['itemFrame'].CheckMonto()){document.form0.baction.value = "Guardar";window.frames['itemFrame'].doSubmit();}else window.frames['itemFrame'].BtnAct();}}else CBMSG.warning('Esta factura no tiene Saldo para aplicar nota de Credito!');}
function showMedicoList(){abrir_ventana1('../common/search_medico.jsp?fp=cargo_dev');}
function doAction(){<%if(validaSaldo.trim().equals("S")){%>checkPagos();<%}%>}
function selCServicio(){var fg = document.form0.fg.value;var cs = document.form0.centroServicio.value;abrir_ventana1('../common/sel_centro_servicio.jsp?fp=cargo_dev&mode=<%=mode%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&fg='+fg+"&cs="+cs);}
function setTipo(){var tipo = document.form0.tipoTransaccion.value;document.getElementById("itemFrame").src='../facturacion/notas_ajuste_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=edit&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&nt='+tipo;}
function showAjuste(){var tipoDoc = document.form0.tipo_doc.value;if(tipoDoc =='')CBMSG.warning('Seleccione Tipo De Documento!!');abrir_ventana('../facturacion/tipo_ajustes_list.jsp?fp=cargo_dev&tipoDoc='+tipoDoc);}
function checkReferencia(obj){<%if (!mode.equalsIgnoreCase("view")){%>if(eval('document.form0.tipo_ajuste').value != "1"){var com = '<%=compania%>';if(!isNaN(obj.value)){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_con_adjustment','referencia=\''+obj.value+'\' and compania='+com+'','<%=ajuste.getReferencia().trim()%>')}else CBMSG.warning('Valor Invalido, Solo es permitido valores Numericos!!');}<%}%>}
function Recibos(){var pase="N";abrir_ventana2('../facturacion/recibos_list.jsp?pase='+pase);}
function showComprobante(){<%if (!mode.equalsIgnoreCase("add")){%>	abrir_ventana1('../facturacion/print_nota_ajuste.jsp?fg=ajust&compania=<%=compania%>&codigo=<%=codigo%>');<%}else{%>CBMSG.warning('Guarde la nota de ajuste para Generar el Comprobante');<%}%>}
function changeCod(codigo){var cod = document.form0.cod.value;window.location = '../facturacion/notas_ajuste_cargo_dev.jsp?mode=view&fp=cons_ajuste&nt=<%=nt%>&fg=<%=fg%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&factura=<%=factura%>&tr=<%=tr%>&codigo='+codigo+'&cod='+cod;}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="NOTAS AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
			<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Datos del Paciente</cellbytelabel></td>
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
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("usuario_creacion",ajuste.getUsuarioCreacion())%>
			<%=fb.hidden("fecha_creacion",ajuste.getFechaCreacion())%>
			<%=fb.hidden("pase",ajuste.getPase())%>
			<%=fb.hidden("pase_k",ajuste.getPaseK())%>
			<%=fb.hidden("act_sn",ajuste.getActSn())%>
			<%=fb.hidden("ref_reversion",ajuste.getRefReversion())%>
			<%=fb.hidden("provincia",ajuste.getProvincia())%>
			<%=fb.hidden("sigla",ajuste.getSigla())%>
			<%=fb.hidden("tomo",ajuste.getTomo())%>
			<%=fb.hidden("asiento",ajuste.getAsiento())%>
			<%=fb.hidden("anio_parametro",ajuste.getAnioParametro())%>
			<%=fb.hidden("mes_parametro",ajuste.getMesParametro())%>
			<%=fb.hidden("factura_aplic",ajuste.getFacturaAplic())%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("compania",compania)%>
			<%=fb.hidden("fecha",ajuste.getFecha())%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("nt",nt)%>
			<%=fb.hidden("tr",tr)%>
			<%=fb.hidden("cod",cod)%>
			<%=fb.hidden("ref_type",ref_type)%>
			<%=fb.hidden("ref_id",ref_id)%>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>AJUSTES</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
					<td width="10%"><cellbytelabel>Tipo de Ajustes</cellbytelabel></td>
					<td width="25%">
					<%=fb.textBox("tipo_ajuste",ajuste.getTipoAjuste(),true,false,true,10)%>
					<%=fb.textBox("name_ajuste",ajuste.getDescAjuste(),false,false,true,30)%>
					<%=fb.button("addAjuste","...",(!viewMode),viewMode,null,null,"onClick=\"javascript:showAjuste()\"","Agregar Ajuste")%>
					</td>
					<td width="18%" align="right"><cellbytelabel>Ajuste</cellbytelabel> #: </td>
					<td width="18%"><%if(fp.equalsIgnoreCase("cons_ajuste")){%>
					<%=fb.select("codigo",cod,codigo,false,false,0,"",null,"onChange=\"javascript:changeCod(this.value);\"")%>
					<%} else {%>
					<%=fb.textBox("codigo",codigo,false,false,true,10)%>
					<%}%>
					</td>
				</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Factura</cellbytelabel></td>
							<td><%=fb.textBox("factura",ajuste.getFactura(),true,false,true,10)%>
						</td>
							<td align="right"><cellbytelabel>Tipo</cellbytelabel></td>
							<td><%=fb.textBox("tipoTransaccion",desc,false,false,true,30)%></td>
						</tr>
						<tr class="TextRow01">
							<td><cellbytelabel>Documento</cellbytelabel> # :</td>
					<td><%=fb.intBox("referencia",(ajuste.getReferencia()!=null && !ajuste.getReferencia().trim().equals(""))?ajuste.getReferencia():"",(docAjFisico.trim().equals("N"))?false:true,false,(docAjFisico.trim().equals("N")||viewMode),10,10,null,null,"onBlur=\"javascript:checkReferencia(this)\"")%></td>
							<td align="right">Estatus <%if(!tr.trim().equals("")){%>( Actual)<%=fb.select("statusIni","O=ABIERTO, C=CERRADO, A=APROBADO, R=RECHAZADO, I=ANULADO",ajuste.getStatus(),false,true,0,"",null,"")%><%}%></td>
							<td>
							<%
							//ajuste.setStatus("A");
							/*if(tr.trim().equals("CS"))
							else*/ if(tr.trim().equals("RE") ||tr.trim().equals("ED"))st = "O=ABIERTO, C=CERRADO";//registro y edicion
							else if(tr.trim().equals("AP")){if(!ajuste.getStatus().trim().equals("A"))st = "A=APROBADO, R=RECHAZADO";else st = "R=RECHAZADO";}//aprobar o rechazar
							else if(tr.trim().equals("AN"))st = "I=ANULADO";//anular
							else st = "O=ABIERTO, C=CERRADO, A=APROBADO, R=RECHAZADO, I=ANULADO";//consulta
							 %>

							<%=fb.select("status",st,ajuste.getStatus(),false,viewMode,0,"",null,"")%>


							</td>
						</tr>
						<tr class="TextRow01">
							<td><cellbytelabel>Tipo Doc</cellbytelabel>:</td>
							<td><%=fb.select("tipo_doc","F = FACTURA",ajuste.getTipoDoc(),false,viewMode,0,"",null,"")%></td>
							<td><!--<cellbytelabel>Recibo</cellbytelabel>:-->	
							<%=fb.hidden("recibo",ajuste.getRecibo())%>
							<%//=fb.textBox("recibo",(ajuste.getRecibo()!=null && !ajuste.getRecibo().trim().equals(""))?ajuste.getRecibo():"",false,false,true,20,12)%>
							<%//=fb.button("addRecibo","...",true,true,null,null,"onClick=\"javascript:Recibos()\"","Agregar Recibo")%></td>
							<td><cellbytelabel>Monto</cellbytelabel><%=fb.decBox("total",ajuste.getTotal(),true,false,viewMode,15,10.2)%>
						 <!--<%=fb.checkbox("ctrlajuste","S",(ajuste.getCtrlAjuste().trim().equals("S")),viewMode,null,null,"")%>Cr&eacute;dito--></td>
				</tr>


						<tr class="TextRow01">
							<td><cellbytelabel>Anotaciones</cellbytelabel></td>
							<td colspan="2"><%=fb.textarea("explicacion",ajuste.getExplicacion(),true,false,viewMode,60,3,200,"","width:100%","")%></td>
							<td>
								<%=fb.button("addComprobante","Comprobante",(!viewMode),false,null,null,"onClick=\"javascript:showComprobante()\"","Imprimir Comprobante de Ajuste")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
							<td><%=ajuste.getFechaCreacion()%></td>
							<td colspan="2"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel>: <%=ajuste.getUsuarioCreacion()%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../facturacion/notas_ajuste_det.jsp?fp=<%=fp%>&fg=<%=fg%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&nt=<%=nt%>&factura=<%=factura%>&mode=<%=mode%>&codigo=<%=codigo%>&compania=<%=compania%>&cargoLastLineNo=<%=cargoLastLineNo%>&tr=<%=tr%>"></iframe>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!---<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro --->
						<%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",(!viewMode),viewMode,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");

	%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/list_notas_ajustes.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/list_notas_ajustes.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_notas_ajustes.jsp';
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=(mode.trim().equals("add"))?"edit":mode%>&codigo=<%=codigo%>&compania=<%=compania%>&fp=<%=fp%>&fg=<%=fg%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&nt=<%=nt%>&factura=<%=factura%>&tr=<%=tr%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
