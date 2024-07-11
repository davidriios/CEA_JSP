<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.NotasAjustes"%>
<%@ page import="issi.facturacion.NotasAjustesDet"%>
<%@ page import="issi.facturacion.NotasAjustesMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNotasCargo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="NAMgr" scope="page" class="issi.facturacion.NotasAjustesMgr"/>
<jsp:useBean id="vNotasCargo" scope="session" class="java.util.Vector" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
NAMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String change = request.getParameter("change");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String factura = request.getParameter("factura");
String type = request.getParameter("type");
String index = request.getParameter("index");

String nt = request.getParameter("nt");
String fg = request.getParameter("fg");
String tr = request.getParameter("tr");
String fp = request.getParameter("fp");
if (fp == null) fp = "";
String key = "";
StringBuffer sbSql = new StringBuffer();
String serviceType ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
boolean viewMode = false;
int cargoLastLineNo = 0;
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getParameter("cargoLastLineNo") != null && !request.getParameter("cargoLastLineNo").equals("")) cargoLastLineNo = Integer.parseInt(request.getParameter("cargoLastLineNo"));

sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'COD_TIPO_SERV_HON'),'-') as serviceType from dual");
NotasAjustesDet det = (NotasAjustesDet) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),NotasAjustesDet.class);
if(det != null && !det.getServiceType().equals("-")) serviceType = det.getServiceType();

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Notas Ajustes - '+document.title;
function doSubmit()
{
	 document.form1.baction.value= parent.document.form0.baction.value;
	 document.form1.codigo.value = parent.document.form0.codigo.value;
	 document.form1.compania.value = parent.document.form0.compania.value;
	 document.form1.explicacion.value = parent.document.form0.explicacion.value;
	 document.form1.fecha.value = parent.document.form0.fecha.value;
	 document.form1.usuario_creacion.value = parent.document.form0.usuario_creacion.value;
	 document.form1.fecha_creacion.value = parent.document.form0.fecha_creacion.value;
	 document.form1.tipo_doc.value = parent.document.form0.tipo_doc.value;
	 //document.form1.factura.value = parent.document.form0.factura.value;
	 document.form1.tipo_ajuste.value = parent.document.form0.tipo_ajuste.value;
	 document.form1.recibo.value = parent.document.form0.recibo.value;
	 document.form1.factura_aplic.value = parent.document.form0.factura_aplic.value;
	 document.form1.total.value = parent.document.form0.total.value;
	 document.form1.estatus.value = "P"//parent.document.form0.estatus.value;
	 document.form1.status.value = parent.document.form0.status.value;
	 document.form1.referencia.value = parent.document.form0.referencia.value;
	 document.form1.act_sn.value = parent.document.form0.act_sn.value;
	 document.form1.sigla.value = parent.document.form0.sigla.value;
	 document.form1.tomo.value = parent.document.form0.tomo.value;
	 document.form1.asiento.value = parent.document.form0.asiento.value;
	 document.form1.provincia.value = parent.document.form0.provincia.value;
	 document.form1.credito.value = "N";
	 document.form1.pase.value = parent.document.form0.pase.value;
	 document.form1.pase_k.value = parent.document.form0.pase_k.value;
	 document.form1.ref_reversion.value = parent.document.form0.ref_reversion.value;
	 document.form1.anio_parametro.value = parent.document.form0.anio_parametro.value;
	 document.form1.mes_parametro.value = parent.document.form0.mes_parametro.value;
	 document.form1.codigo_paciente.value = parent.document.paciente.codigoPaciente.value;
	 document.form1.fecha_nacimiento.value = parent.document.paciente.fechaNacimiento.value;
	 document.form1.ref_type.value = parent.document.form0.ref_type.value;
	 document.form1.ref_id.value = parent.document.form0.ref_id.value;
	 if (form1Validation())
	 {
		 if (CheckMonto())
		 document.form1.submit();
	 }else doAction();
}
function doAction(){if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);BtnAct();<%if(type != null && type.trim().equals("1")){%>abrir_ventana('../common/check_servicio_centro_dev.jsp?mode=<%=mode%>&nt=D&fp=notas&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&cargoLastLineNo=<%=cargoLastLineNo%>&factura=<%=factura%>&fg=D&tr=<%=tr%>');<%}else if(type != null && type.trim().equals("2")){%>abrir_ventana('../common/check_servicio_centro_dev.jsp?mode=<%=mode%>&nt=H&fg=D&fp=notas&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&cargoLastLineNo=<%=cargoLastLineNo%>&factura=<%=factura%>&tr=<%=tr%>');<%}%>}
function showDetalle(k){var tipo = eval('document.form1.tipo'+k).value;if(tipo=="E")abrir_ventana2('../common/search_empresa.jsp?fp=notas_h&index='+k);else if(tipo=="H")/*medico*/abrir_ventana2('../common/search_medico.jsp?fp=notas_h&index='+k);}
function BtnAct(){parent.form0BlockButtons(false);}
function CheckMonto(){

var x = 0;var conta = 0;var tot_db = 0;var tot_cr = 0;var aconta = 0;var msg = '';var totalCr =0.00,totalDb =0.00;

if(parent.document.form0.tipo_doc.value == "R" && parent.document.form0.recibo.value==""){top.CBMSG.warning('INTRODUZCA NUMERO DE RECIBO');return false;}

if(x>0){return false;}

else{

var size1 = parseInt(document.getElementById("keySize").value);

for (i=0;i<size1;i++)
{
	if(parent.document.form0.tipo_doc.value == "F" )
	{
		if(eval('document.form1.centro'+i).value==""){msg +=' CENTRO ';	x++;}
		if(eval('document.form1.tipoServicio'+i).value==""){if(msg != '' )msg += ',';msg += ' TIPO SERVICIO ';x++;}
		if(eval('document.form1.codigo_medico'+i))if(eval('document.form1.codigo_medico'+i).value==""){if(msg != '' )msg += ',';msg += ' HONORARIO ';x++;}
	}
	
	if(x>0)	{ top.CBMSG.warning('EL CAMPO CODIGO '+msg+' ESTA EN BLANCO...VERIFIQUE');return false;}if(eval('document.form1.lado_mov'+i).value == "D")tot_db +=  parseFloat(eval('document.form1.monto'+i).value);else if(eval('document.form1.lado_mov'+i).value == "C")				 tot_cr += parseFloat(eval('document.form1.monto'+i).value);}totalCr = tot_cr.toFixed(2);totalDb = tot_db.toFixed(2);if(totalDb > 0 && totalCr > 0){if(totalDb == parseFloat(parent.document.form0.total.value) && totalCr == parseFloat(parent.document.form0.total.value))conta=1;else conta = 2;}if(totalDb >= 0 && totalCr == 0){if(totalDb == parseFloat(parent.document.form0.total.value))conta=1;else conta = 2;}if(totalDb == 0 && totalCr >= 0){if(totalCr == parseFloat(parent.document.form0.total.value))conta=1;else conta = 2;}eval('document.form1.conta').value=conta;if(conta==2){top.CBMSG.warning('REVISE MONTOS DE LA NOTA DE AJUSTE');x++;}if(x>0)return false;else return true;}}
function showCentro(k){var factura = document.form1.factura.value;abrir_ventana2('../common/search_centro_servicio.jsp?fp=ajusteCargo&index='+k+'&factura='+factura);}
function showServicio(k){var cs = eval('document.form1.centro'+k).value;if(cs!=""){abrir_ventana2('../common/search_tipo_servicio.jsp?fp=ajuste_cargoDev&index='+k+'&centro='+cs);}
else top.CBMSG.warning('Seleccione Centro de servicio ');}
function clearCodigo(k){eval('document.form1.codigo_medico'+k).value="";eval('document.form1.descripcion'+k).value="";eval('document.form1.monto'+k).value="";eval('document.form1.reg_medico'+k).value="";}
function checkMonto(i){<%if(fg.trim().equals("D")){%>var montoCargo =  parseFloat(eval('document.form1.montoCargo'+i).value);var montoAjuste =  parseFloat(eval('document.form1.monto'+i).value);if(montoCargo<montoAjuste){ top.CBMSG.warning('El monto a ajustar es mayor que el monto del Cargo. \n Favor revise!!!');eval('document.form1.monto'+i).value=0;}<%}%>}
function showDet(k)
{
var pase_k = parent.document.form0.pase_k.value;
var cds = eval('document.form1.centro'+k).value;
var ts = eval('document.form1.tipoServicio'+k).value;
var codDet = eval('document.form1.secuencia'+k).value;
var codigo = eval('document.form1.nota_ajuste'+k).value; 
var fact= parent.document.form0.factura.value;
if(pase_k=='N'){
 top.CBMSG.confirm('En caso que el monto a registrar en el detalle sea mayor se actualizará en base a los articulos seleccionados. \n ¿Desea continuar?',{opacity:.2,btnTxt:'Si,No',cb:function(r){
                              if (r=="Si")abrir_ventana('../facturacion/detalle_ajuste.jsp?mode=<%=mode%>&fp=<%=fp%>&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&factura='+fact+'&fg=<%=fg%>&tr=<%=tr%>&nt=<%=nt%>&cds='+cds+'&ts='+ts+'&codigo='+codigo+'&codDet='+codDet); 
                            }});	
		}
		else
		{
		 top.CBMSG.alert('El ajuste ya tiene Comprobante Generado. \n Favor revise !!!');
		}
 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("cargoLastLineNo",""+cargoLastLineNo)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo","")%>
			<%=fb.hidden("conta","")%>
			<%=fb.hidden("compania","")%>
			<%=fb.hidden("explicacion","")%>
			<%=fb.hidden("fecha","")%>
			<%=fb.hidden("usuario_creacion","")%>
			<%=fb.hidden("fecha_creacion","")%>
			<%=fb.hidden("tipo_doc","")%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("tipo_ajuste","")%>
			<%=fb.hidden("recibo","")%>
			<%=fb.hidden("factura_aplic","")%>
			<%=fb.hidden("total","")%>
			<%=fb.hidden("estatus","")%>
			<%=fb.hidden("status","")%>
			<%=fb.hidden("referencia","")%>
			<%=fb.hidden("act_sn","")%>
			<%=fb.hidden("credito","")%>
			<%=fb.hidden("pase","")%>
			<%=fb.hidden("pase_k","")%>
			<%=fb.hidden("ref_reversion","")%>
			<%=fb.hidden("provincia","")%>
			<%=fb.hidden("sigla","")%>
			<%=fb.hidden("tomo","")%>
			<%=fb.hidden("asiento","")%>
			<%=fb.hidden("anio_parametro","")%>
			<%=fb.hidden("mes_parametro","")%>
			<%=fb.hidden("pacienteId",pacienteId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("codigo_paciente","")%>
			<%=fb.hidden("fecha_nacimiento","")%>

			<%=fb.hidden("keySize",""+iNotasCargo.size())%>
			<%=fb.hidden("nt",nt)%>
			<%=fb.hidden("index",index)%>
			<%=fb.hidden("fg",fg)%>
            <%=fb.hidden("tr",tr)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("ref_type","")%>
			<%=fb.hidden("ref_id","")%>

			<tr class="TextHeader" align="center">
				<td width="22%"><cellbytelabel>Centro</cellbytelabel></td>
				<td width="22%"><cellbytelabel>Tipo Servicio</cellbytelabel></td>
				<%if(nt != null && nt.trim().equals("H"))
				{%>
				<td width="28%"><cellbytelabel>Honorarios</cellbytelabel></td>
				<td width="6%"><cellbytelabel>Monto</cellbytelabel></td>
				<%}else{%>
				<td width="6%" colspan="2"><cellbytelabel>Monto</cellbytelabel></td>

				<%}%>
				<td width="2%"><%=fb.submit("agregar","+",true,((!tr.trim().equals("RE") && !tr.trim().equals("ED"))|| viewMode),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				<td width="2%">&nbsp;Detalle</td>
		</tr>
				<%
						String js = "";
						al = CmnMgr.reverseRecords(iNotasCargo);
						for (int i = 0; i < iNotasCargo.size(); i++)
						{
						key = al.get(i).toString();
						NotasAjustesDet na = (NotasAjustesDet) iNotasCargo.get(key);
						String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";
					%>
				<%=fb.hidden("nota_ajuste"+i,na.getNotaAjuste())%>
				<%=fb.hidden("compania"+i,na.getCompania())%>
				<%=fb.hidden("cod_banco"+i,na.getCodBanco())%>
				<%=fb.hidden("cuenta_banco"+i,na.getCuentaBanco())%>
				<%=fb.hidden("monto_saldo"+i,na.getMontoSaldo())%>
				<%=fb.hidden("precio"+i,"")%>
				<%=fb.hidden("usuario_creacion"+i,na.getUsuarioCreacion())%>
				<%=fb.hidden("fecha_creacion"+i,na.getFechaCreacion())%>
				<%=fb.hidden("paciente"+i,na.getPaciente())%>
				<%=fb.hidden("amision"+i,na.getAmision())%>
				<%=fb.hidden("fecha_nacimiento"+i,na.getFechaNacimiento())%>
				<%=fb.hidden("pac_id"+i,na.getPacId())%>
				<%=fb.hidden("cliente_emp"+i,na.getClienteEmp())%>
				<%=fb.hidden("afecta"+i,na.getAfecta())%>
				<%=fb.hidden("pase"+i,na.getPase())%>
				<%=fb.hidden("fact_clinica"+i,na.getFactClinica())%>
				<%=fb.hidden("puntos_sino"+i,na.getPuntosSino())%>
				<%=fb.hidden("empresa"+i,na.getEmpresa())%>
				<%=fb.hidden("medico"+i,na.getMedico())%>
				<%=fb.hidden("tipo_cds"+i,"")%>
				<%=fb.hidden("reportaA"+i,"")%>
				<%=fb.hidden("incremento"+i,"")%>
				<%=fb.hidden("tipoIncremento"+i,"")%>
				<%=fb.hidden("pase_k"+i,na.getPaseK())%>
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("secuencia"+i,na.getSecuencia())%>
				<%=fb.hidden("num_cheque"+i,na.getNumCheque())%>
				<%=fb.hidden("farhosp"+i,na.getFarhosp())%>
				<%=fb.hidden("lado_mov"+i,na.getLadoMov())%>
				<%=fb.hidden("detServicio"+i,na.getDetalleServicio())%>
				<%=fb.hidden("montoCargo"+i,na.getMontoCargo())%>

				<%if (mode.equalsIgnoreCase("edit") && nt != null && nt.trim().equals("C")){%>
				<%=fb.hidden("tipo"+i,na.getTipo())%>
				<%}%>
				<tr class="<%=color%>">
				<td><%=fb.textBox("centro"+i,na.getCentro(),true,false,true,5,12,"Text10",null,null)%>
						<%=fb.textBox("nCentro"+i,na.getDescCentro(),false,false,true,25,50,"Text10",null,null)%><%=fb.button("addDesc"+i,"...",true,(viewMode || !nt.trim().equals("C")),null,null,"onClick=\"javascript:showCentro("+i+")\"","Centro servicio")%></td>
				<td><%=fb.textBox("tipoServicio"+i,na.getServiceType(),true,false,true,5,30,"Text10",null,null)%>
						<%=fb.textBox("nServicio"+i,na.getDescTipoServicio(),false,false,true,25,50,"Text10",null,null)%><%=fb.button("addServicio"+i,"...",true,(viewMode || !nt.trim().equals("C")),null,null,"onClick=\"javascript:showServicio("+i+")\"","Tipo Servicio")%></td>

				<%if(nt != null && nt.trim().equals("H"))
				{%>
				<td>
				<%=fb.select("tipo"+i,"E = EMPRESA,H=MEDICO",na.getTipo(),false,viewMode,0,"",null,"onChange=\"javascript:clearCodigo("+i+")\"")%>
				<%=fb.hidden("codigo_medico"+i,(na.getMedico()!=null && !na.getMedico().trim().equals(""))?na.getMedico():na.getEmpresa())%>
				<%=fb.textBox("reg_medico"+i,(na.getRegMedico()!=null && !na.getRegMedico().trim().equals(""))?na.getRegMedico():na.getEmpresa(),false,false,true,3,20,"Text10",null,null)%>
				<%=fb.textBox("descripcion"+i,na.getDescripcion(),false,false,true,15,"Text10",null,null)%>
				<%=fb.button("addDesc"+i,"...",true,(viewMode || !fg.trim().equals("C")),null,null,"onClick=\"javascript:showDetalle("+i+")\"","Detalle")%>
				</td>
				<td align="center"><%=fb.decBox("monto"+i,na.getMonto(),true,false,(viewMode),10,15.2,"Text10",null,"onChange=\"javascript:checkMonto("+i+")\"")%></td>
				<%
				}else{
				%>

			<td align="center" colspan="2"><%=fb.decBox("monto"+i,na.getMonto(),true,false,(viewMode),10,15.2,"Text10",null,"onChange=\"javascript:checkMonto("+i+")\"")%></td>
				<%}%>
				<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
				
				<td align="center">
				<%=fb.button("addDet"+i,"...",true,(nt.trim().equals("H")),null,null,"onClick=\"javascript:showDet("+i+")\"","Detalle")%></td>
		</tr>
				<%}%>
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
else
{
		int keySize=Integer.parseInt(request.getParameter("keySize"));
		mode = request.getParameter("mode");
		compania = request.getParameter("compania");
		pacienteId = request.getParameter("pacienteId");
		noAdmision = request.getParameter("noAdmision");
		factura = request.getParameter("factura");
		index = request.getParameter("index");
		nt = request.getParameter("nt");
		fg = request.getParameter("fg");
		fp = request.getParameter("fp");
		cargoLastLineNo = Integer.parseInt(request.getParameter("cargoLastLineNo"));
		ArrayList list = new ArrayList();
		String ItemRemoved = "";
		NotasAjustes nAjust = new NotasAjustes();
		for (int i=0; i<keySize; i++)
		{
			NotasAjustesDet nDet = new NotasAjustesDet();

			 nDet.setNotaAjuste(codigo);
			 nDet.setCompania(request.getParameter("compania"+i));
			 nDet.setSecuencia(request.getParameter("secuencia"+i));
			 nDet.setMonto(request.getParameter("monto"+i));
			 if(request.getParameter("descripcion"+i) != null && !request.getParameter("descripcion"+i).trim().equals("") )
					nDet.setDescripcion(request.getParameter("descripcion"+i));
			 else nDet.setDescripcion(request.getParameter("nServicio"+i));
			 nDet.setFactura(request.getParameter("factura"));
			 nDet.setCodBanco(request.getParameter("cod_banco"+i));
			 nDet.setCuentaBanco(request.getParameter("cuenta_banco"+i));
			 nDet.setMontoSaldo(request.getParameter("monto_saldo"+i));
			 nDet.setMontoCargo(request.getParameter("montoCargo"+i));
			 nDet.setUsuarioCreacion(request.getParameter("usuario_creacion"+i));
			 nDet.setUsuarioModificacion((String) session.getAttribute("_userName"));
			 nDet.setFechaCreacion(request.getParameter("fecha_creacion"+i));
			 nDet.setFechaModificacion(cDateTime);
			 nDet.setNumCheque(request.getParameter("num_cheque"+i));

			 nDet.setPaciente(request.getParameter("codigo_paciente"));
			 nDet.setAmision(noAdmision);
			 nDet.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
			 nDet.setPacId(pacienteId);
			 nDet.setClienteEmp(request.getParameter("cliente_emp"+i));
			 nDet.setFarhosp(request.getParameter("farhosp"+i));/////cambiar
			 nDet.setAfecta(request.getParameter("afecta"+i));
			 nDet.setPase(request.getParameter("pase"+i));
			 nDet.setPaseK(request.getParameter("pase_k"+i));
			 nDet.setPuntosSino(request.getParameter("puntos_sino"+i));
			 nDet.setFactClinica(request.getParameter("fact_clinica"+i));
			 nDet.setLadoMov(request.getParameter("lado_mov"+i));

			 //C = centro H = medico E = empresa
			 if(nt != null && nt.trim().equals("C") && fg != null && fg.trim().equals("C") || nt != null && nt.trim().equals("D") && fg != null && fg.trim().equals("D"))
			 {
					nDet.setTipo("C");
			 }
			 nDet.setCentro(request.getParameter("centro"+i));
			 nDet.setDescCentro(request.getParameter("nCentro"+i));
			 nDet.setServiceType(request.getParameter("tipoServicio"+i));
			 nDet.setDescTipoServicio(request.getParameter("nServicio"+i));

			 if(request.getParameter("reg_medico"+i)!=null) nDet.setRegMedico(request.getParameter("reg_medico"+i));

			 nDet.setDetalleServicio(request.getParameter("codigo_medico"+i));

			 if(nt != null && nt.trim().equals("H") && (fg != null && fg.trim().equals("D")|| fg != null && fg.trim().equals("C")))
			 {
						if(request.getParameter("tipo"+i) != null && request.getParameter("tipo"+i).trim().equals("E"))
						{
							nDet.setEmpresa(request.getParameter("codigo_medico"+i));
							nDet.setTipo("E");
						}
						else if(request.getParameter("tipo"+i) != null && request.getParameter("tipo"+i).trim().equals("H"))
						{
							nDet.setMedico(request.getParameter("codigo_medico"+i));
							nDet.setTipo("H");
						}
			 }
			 key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			ItemRemoved = key;
		}
		else
		{
				try{
						iNotasCargo.put(key,nDet);
						 if(nt != null && nt.trim().equals("H"))
						 {
											vNotasCargo.addElement(nDet.getServiceType()+"-"+nDet.getCentro()+"-"+nDet.getDetalleServicio());
						 }else vNotasCargo.addElement(nDet.getServiceType()+"-"+nDet.getCentro());
						 nAjust.addNotasDetalle(nDet);
						 list.add(nDet);
				 }catch(Exception e){ System.err.println(e.getMessage()); }
			}
		}	//for

		if (!ItemRemoved.equals(""))
		{

			 vNotasCargo.remove(((NotasAjustesDet) iNotasCargo.get(ItemRemoved)).getPase());
			 iNotasCargo.remove(ItemRemoved);
			 response.sendRedirect("../facturacion/notas_ajuste_det.jsp?change=1&mode="+mode+"&cargoLastLineNo="+cargoLastLineNo+"&codigo="+codigo+"&nt="+nt+"&fg="+fg+"&pacienteId="+pacienteId+"&noAdmision="+noAdmision+"&factura="+factura+"&tr="+tr+"&fp="+fp);
			 return;
		}

		if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
		{
				if( nt != null && nt.trim().equals("C") || nt.trim().equals("H") && fg != null && fg.trim().equals("C"))	{
				NotasAjustesDet naj = new NotasAjustesDet();

				if(nt.trim().equals("H") && fg != null && fg.trim().equals("C") )
				{
				naj.setCentro("0");
				naj.setDescCentro("HONORARIOS");
				naj.setServiceType(""+serviceType);

				naj.setDescTipoServicio("HONORARIOS");
				}
				naj.setSecuencia("0");
				naj.setPagado("N");
				naj.setFarhosp("N");
				if (fg.equalsIgnoreCase("C")) naj.setLadoMov("D");
				else if (fg.equalsIgnoreCase("D")) naj.setLadoMov("C");

				naj.setUsuarioCreacion((String) session.getAttribute("_userName"));
				naj.setFechaCreacion(cDateTime);
				cargoLastLineNo++;
				if (cargoLastLineNo < 10) key = "00" +cargoLastLineNo;
				else if (cargoLastLineNo < 100) key = "0" +cargoLastLineNo;
				else key = "" +cargoLastLineNo;
				naj.setKey(key);
				try
				{
						iNotasCargo.put(key,naj);
				}
				catch(Exception e)
				{
						System.err.println(e.getMessage());
				}

			 response.sendRedirect("../facturacion/notas_ajuste_det.jsp?change=1&mode="+mode+"&cargoLastLineNo="+cargoLastLineNo+"&codigo="+codigo+"&nt="+nt+"&fg="+fg+"&pacienteId="+pacienteId+"&noAdmision="+noAdmision+"&factura="+factura+"&tr="+tr+"&fp="+fp);
			 return;
			}
			else if( nt != null && nt.trim().equals("H") && fg != null && fg.trim().equals("D"))
			{

			response.sendRedirect("../facturacion/notas_ajuste_det.jsp?type=2&change=1&mode="+mode+"&cargoLastLineNo="+cargoLastLineNo+"&codigo="+codigo+"&nt="+nt+"&fg="+fg+"&pacienteId="+pacienteId+"&noAdmision="+noAdmision+"&factura="+factura+"&tr="+tr+"&fp="+fp);
			return;
			}
			else{
					 response.sendRedirect("../facturacion/notas_ajuste_det.jsp?type=1&change=1&mode="+mode+"&cargoLastLineNo="+cargoLastLineNo+"&type=1&codigo="+codigo+"&nt="+nt+"&fg="+fg+"&pacienteId="+pacienteId+"&noAdmision="+noAdmision+"&factura="+factura+"&tr="+tr+"&fp="+fp);
		return;
			}

		}//baction +

		 nAjust.setStatus(request.getParameter("status"));
		 nAjust.setConta(request.getParameter("conta"));
		 nAjust.setCompania((String) session.getAttribute("_companyId"));
		 nAjust.setCodigo(request.getParameter("codigo"));
		 nAjust.setExplicacion(request.getParameter("explicacion"));
		 nAjust.setFecha(request.getParameter("fecha"));
		 nAjust.setUsuarioCreacion(request.getParameter("usuario_creacion"));
		 nAjust.setUsuarioModificacion((String) session.getAttribute("_userName"));
		 nAjust.setFechaCreacion(request.getParameter("fecha_creacion"));
		 nAjust.setFechaModificacion(cDateTime);
		 nAjust.setTipoDoc(request.getParameter("tipo_doc"));
		 nAjust.setFactura(request.getParameter("factura"));
		 nAjust.setTipoAjuste(request.getParameter("tipo_ajuste"));
		 nAjust.setRecibo(request.getParameter("recibo"));
		 nAjust.setFacturaAplic(request.getParameter("factura_aplic"));
		 nAjust.setTotal(request.getParameter("total"));
		 nAjust.setEstatus(request.getParameter("estatus"));
		 nAjust.setReferencia(request.getParameter("referencia"));
		 nAjust.setActSn(request.getParameter("act_sn"));
		 nAjust.setCtrlAjuste("N");
		 nAjust.setPase(request.getParameter("pase"));
		 nAjust.setPaseK(request.getParameter("pase_k"));
		 nAjust.setRefReversion (request.getParameter("ref_reversion"));
		 nAjust.setProvincia(request.getParameter("provincia"));
		 nAjust.setSigla(request.getParameter("sigla"));
		 nAjust.setTomo(request.getParameter("tomo"));
		 nAjust.setAsiento(request.getParameter("asiento"));
		 nAjust.setAnioParametro(request.getParameter("anio_parametro"));
		 nAjust.setMesParametro(request.getParameter("mes_parametro"));
		 nAjust.setTipo(fg);
		 nAjust.setTipoTransaccion(nt);
		 nAjust.setRefType(request.getParameter("ref_type"));
		 nAjust.setRefId(request.getParameter("ref_id"));


		 if(fp.trim().equals("Aprob") && nAjust.getStatus().trim().equals("A"))
		 {
		 	//nAjust.setUsuarioAprob((String) session.getAttribute("_userName"));
			//nAjust.setFechaAprob(cDateTime);

		 }
		 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		 ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&nt="+nt+"&fp="+fp+"&tr="+tr);
		 if (mode.equalsIgnoreCase("add"))
		 {
			NAMgr.add(nAjust,1);
			codigo = NAMgr.getPkColValue("codigo");
		 }
		 else if (mode.equalsIgnoreCase("edit"))
		 {
			NAMgr.update(nAjust,1);
		 }
		 ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (NAMgr.getErrCode().equals("1")){%>
	parent.document.form0.errCode.value = '<%=NAMgr.getErrCode()%>';
	parent.document.form0.errMsg.value = '<%=NAMgr.getErrMsg()%>';
	parent.document.form0.codigo.value = '<%=codigo%>';
	parent.document.form0.compania.value = '<%=compania%>';

	parent.document.form0.nt.value = '<%=nt%>';
	parent.document.form0.fg.value = '<%=fg%>';
	parent.document.form0.noAdmision.value = '<%=noAdmision%>';
	parent.document.form0.pacienteId.value = '<%=pacienteId%>';
	parent.document.form0.tr.value = '<%=tr%>';

  parent.document.form0.submit();
  <%} else throw new Exception(NAMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
