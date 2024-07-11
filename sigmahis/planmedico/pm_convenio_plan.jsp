<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.Convenio"%>
<%@ page import="issi.convenio.PlanConvenio"%>
<%@ page import="issi.convenio.ClasificacionPlan"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="pc" scope="session" class="issi.convenio.PlanConvenio" />
<jsp:useBean id="iPlan" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPlan" scope="session" class="java.util.Vector" />
<jsp:useBean id="iClasif" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vClasif" scope="session" class="java.util.Vector" />
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
ConvMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String change = request.getParameter("change");
int planLastLineNo = 0;
int clasifLastLineNo = 0;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null) throw new Exception("El Tipo de Póliza o Plan no es válido. Por favor intente nuevamente!");
if (request.getParameter("planLastLineNo") != null) planLastLineNo = Integer.parseInt(request.getParameter("planLastLineNo"));
if (request.getParameter("clasifLastLineNo") != null) clasifLastLineNo = Integer.parseInt(request.getParameter("clasifLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iClasif.clear();
		vClasif.clear();
		planNo = "0";
	}
	else
	{
		if (change == null)
		{
			if (planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");

			if (planNo.equals("0"))
				sql = "select "+empresa+" as empresa, "+secuencia+" as convenio, 0 as secuencia, a.codigo as tipoPoliza, a.nombre as nombreTipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombreTipoPlan, 'A' as estado from tbl_adm_tipo_poliza a, tbl_adm_tipo_plan b where a.codigo=b.poliza and a.codigo="+tipoPoliza+" and b.tipo_plan="+tipoPlan;
			else
				sql = "select a.empresa, a.convenio, a.secuencia, a.nombre, a.tipo_plan as tipoPlan, a.tipo_poliza as tipoPoliza, a.estado as estado, b.nombre as nombreEmpresa, c.nombre as nombreConvenio, d.nombre as nombreTipoPlan, e.nombre as nombreTipoPoliza from tbl_adm_plan_convenio a, tbl_adm_empresa b, tbl_adm_convenio c, tbl_adm_tipo_plan d, tbl_adm_tipo_poliza e where a.empresa=b.codigo and a.empresa=c.empresa and a.convenio=c.secuencia and a.tipo_poliza=d.poliza and a.tipo_plan=d.tipo_plan and a.tipo_poliza=e.codigo and a.empresa="+empresa+" and a.convenio="+secuencia+" and a.tipo_poliza="+tipoPoliza+" and a.tipo_plan="+tipoPlan+" and a.secuencia="+planNo;
			System.out.println("SQL:\n"+sql);
			pc = (PlanConvenio) sbb.getSingleRowBean(ConMgr.getConnection(),sql,PlanConvenio.class);

			iClasif.clear();
			vClasif.clear();

			sql = "select a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.empresa, a.plan, a.convenio, a.monto_clinica as montoClinica, a.monto_empresa as montoEmpresa, a.monto_paciente as montoPaciente, a.tipo_val_cli as tipoValCli, a.descuento_cli as descuentoCli, a.tipo_val_emp as tipoValEmp, a.tipo_val_pac as tipoValPac, a.tipo_cob_cli as tipoCobCli, a.tipo_cob_emp as tipoCobEmp, a.tipo_cob_pac as tipoCobPac, a.deducible_sino as deducibleSino, a.dias_limite as diasLimite, a.paga_dif as pagaDif, a.ganancia_perdida as gananciaPerdida, a.paga_dias_adic as pagaDiasAdic, a.sol_benef_pac as solBenefPac, a.sol_benef_emp as solBenefEmp, a.pac_hna_sino as pacHnaSino, a.limite_estadia as limiteEstadia, a.procesar_hon as procesarHon, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModificacion, a.estado, a.tipo_pago_pac as tipoPagoPac, a.tipo_pago_emp as tipoPagoEmp, a.perdiem_dsp as perdiemDsp, a.lista_insumo as listaInsumo, b.descripcion as clasifAdmiDesc, c.descripcion as tipoAdmiDesc, d.descripcion as categoriaAdmiDesc, e.nombre as nombreEmpresa, f.nombre as nombrePlan, g.nombre as nombreConvenio from tbl_adm_clasif_x_plan_conv a, tbl_adm_clasif_x_tipo_adm b, tbl_adm_tipo_admision_cia c, tbl_adm_categoria_admision d, tbl_adm_empresa e, tbl_adm_plan_convenio f, tbl_adm_convenio g where a.categoria_admi=b.categoria and a.tipo_admi=b.tipo and a.clasif_admi=b.codigo and a.categoria_admi=c.categoria and a.tipo_admi=c.codigo and a.categoria_admi=d.codigo and a.empresa=e.codigo and a.empresa=f.empresa and a.convenio=f.convenio and a.plan=f.secuencia and a.empresa=g.empresa and a.convenio=g.secuencia and a.empresa="+empresa+" and a.convenio="+secuencia+" and a.plan="+planNo+" and c.compania="+(String) session.getAttribute("_companyId");
			System.out.println("SQL:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,ClasificacionPlan.class);

			clasifLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				ClasificacionPlan cp = (ClasificacionPlan) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cp.setKey(key);

				try
				{
					iClasif.put(cp.getKey(), cp);
					vClasif.addElement(cp.getCategoriaAdmi()+"-"+cp.getTipoAdmi()+"-"+cp.getClasifAdmi());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i
		}//change is null
	}//edit mode
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Registros de Convenios - '+document.title;

function showClasificacionList()
{
	abrir_ventana1('../common/check_clasificacion_adm.jsp?fp=pm_convenio&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&planLastLineNo=<%=planLastLineNo%>&clasifLastLineNo=<%=clasifLastLineNo%>');
}

function doAction()
{
	newHeight();
	parent.form1BlockButtons(false);
<%
	if (request.getParameter("type") != null)
	{
%>
	showClasificacionList();
<%
	}
%>
}

function showDetail(k)
{
	var obj = document.getElementById('detail'+k);
	if (obj.style.display == '')
	{
		obj.style.display = 'none';
		eval('document.form1.expanded'+k).value = '0';
	}
	else
	{
		obj.style.display = '';
		eval('document.form1.expanded'+k).value = '1';
	}
	newHeight();
}

function doSubmit()
{
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.removePlanKey.value = parent.document.form1.removePlanKey.value;
	document.form1.saveOption.value = parent.document.form1.saveOption.value;

	if (!form1Validation())
	{
		parent.form1BlockButtons(false);
		return false;
	}

	document.form1.submit();
}

function removeClasif(k)
{
	var categoria=eval('document.form1.categoriaAdmi'+k).value;
	var tipo=eval('document.form1.tipoAdmi'+k).value;
	var clasif=eval('document.form1.clasifAdmi'+k).value;
	var msg='';

	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cober_x_clasif_plan','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi='+categoria+' and tipo_admi='+tipo+' and clasif_admi='+clasif,''))msg+='\n- Coberturas';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_excl_clasif_plan','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi='+categoria+' and tipo_admi='+tipo+' and clasif_admi='+clasif,''))msg+='\n- Exclusiones';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_aplicacion_beneficio','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admision='+categoria+' and tipo_admision='+tipo+' and clasif_admision='+clasif,''))msg+='\n- Aplicaciones de Beneficio';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi='+categoria+' and tipo_admi='+tipo+' and clasif_admi='+clasif,''))msg+='\n- Beneficios en Admisión';
	if(hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','cod_empresa=<%=empresa%> and convenio=<%=secuencia%> and tipo_plan=<%=planNo%> and categoria_admi='+categoria+' and tipo_admi='+tipo+' and clasif_admi='+clasif,''))msg+='\n- Facturas';

	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar la Clasificación?'))
		{
			removeItem('form1',k);
			parent.form1BlockButtons(true);
			form1BlockButtons(true);
			document.form1.submit();
		}
	}
	else alert('La Clasificación no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}

function showClasif(cTab,categoriaAdm,tipoAdm,clasifAdm)
{
	if (<%=pc.getSecuencia()%> == 0) alert('Por favor guarde antes de continuar!');
	else abrir_ventana1('../planmedico/pm_convenio_clasif.jsp?tab=<%=tab%>&cTab='+cTab+'&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm='+categoriaAdm+'&tipoAdm='+tipoAdm+'&clasifAdm='+clasifAdm);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("planSize",""+iPlan.size())%>
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("clasifSize",""+iClasif.size())%>
<%=fb.hidden("clasifLastLineNo",""+clasifLastLineNo)%>
<%=fb.hidden("removePlanKey","")%>
<%=fb.hidden("saveOption","")%>
				<tr class="TextHeader">
					<td colspan="6" align="center"><cellbytelabel>P L A N</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td width="10%" align="right"><cellbytelabel>Tipo de P&oacute;liza</cellbytelabel></td>
					<td width="30%">[<%=pc.getTipoPoliza()%>] <%=pc.getNombreTipoPoliza()%></td>
					<td width="10%" align="right">Tipo de Plan</td>
					<td width="30%">[<%=pc.getTipoPlan()%>] <%=pc.getNombreTipoPlan()%></td>
					<td width="10%" align="right"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="10%"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",pc.getEstado(),false,false,0,"Text10",null,null)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Nombre del Plan</cellbytelabel></td>
					<td>
						<%=fb.intBox("planNo",pc.getSecuencia(),true,false,true,3,3,"Text10",null,null)%>
						<%=fb.textBox("nombre",pc.getNombre(),true,false,false,40,100,"Text10",null,null)%></td>
					<td align="right"><cellbytelabel>Aplicar Descuentos</cellbytelabel></td>
					<td><%=fb.select("aplica_desc","N=NO APLICA,I=ANTES DE DISTRIBUIR,F=DESPUES DE DISTRIBUIR",pc.getAplicaDesc(),false,false,0,"Text10","","","","")%></td>
					<td align="right"><cellbytelabel>Co-Pago Beneficia a</cellbytelabel></td>
					<td><%=fb.select("aplica_co","E=EMPRESA,A=AMBOS",pc.getAplicaCo(),false,false,0,"Text10","","","","")%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="6" align="center"><cellbytelabel>C L A S I F I C A C I O N E S</cellbytelabel></td>
				</tr>
				<tr>
					<td colspan="6">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader01" align="center">
							<td colspan="2"><cellbytelabel>Categor&iacute;a de Admisi&oacute;n</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Tipo de Admisi&oacute;n</cellbytelabel></td>
							<td colspan="3"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
							<td rowspan="2" width="2%"><%=fb.submit("addClasificacion","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Clasificaciones")%></td>
						</tr>
						<tr class="TextHeader01" align="center">
							<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="27%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="27%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="28%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="1%">&nbsp;</td>
						</tr>
<%
al = CmnMgr.reverseRecords(iPlan);
for (int i=1; i<=iPlan.size(); i++)
{
	key = al.get(i - 1).toString();
	PlanConvenio pcTemp = (PlanConvenio) iPlan.get(key);
%>
						<%=fb.hidden("pcKey"+i,pcTemp.getKey())%>
						<%=fb.hidden("pcTipoPoliza"+i,pcTemp.getTipoPoliza())%>
						<%=fb.hidden("pcNombreTipoPoliza"+i,pcTemp.getNombreTipoPoliza())%>
						<%=fb.hidden("pcTipoPlan"+i,pcTemp.getTipoPlan())%>
						<%=fb.hidden("pcNombreTipoPlan"+i,pcTemp.getNombreTipoPlan())%>
						<%=fb.hidden("pcSecuencia"+i,pcTemp.getSecuencia())%>
						<%=fb.hidden("pcNombre"+i,pcTemp.getNombre())%>
						<%=fb.hidden("pcEstado"+i,pcTemp.getEstado())%>
<%
}//planConvenio

int validClasif = iClasif.size();
al = CmnMgr.reverseRecords(iClasif);
for (int i=1; i<=iClasif.size(); i++)
{
	key = al.get(i - 1).toString();
	ClasificacionPlan cp = (ClasificacionPlan) iClasif.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow02";
	String displayClasif = "";
	if (cp.getEstado() != null && cp.getEstado().equalsIgnoreCase("D"))
	{
		displayClasif = " style=\"display:none\"";
		validClasif--;
	}
%>
						<%=fb.hidden("key"+i,cp.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("categoriaAdmi"+i,cp.getCategoriaAdmi())%>
						<%=fb.hidden("categoriaAdmiDesc"+i,cp.getCategoriaAdmiDesc())%>
						<%=fb.hidden("tipoAdmi"+i,cp.getTipoAdmi())%>
						<%=fb.hidden("tipoAdmiDesc"+i,cp.getTipoAdmiDesc())%>
						<%=fb.hidden("clasifAdmi"+i,cp.getClasifAdmi())%>
						<%=fb.hidden("clasifAdmiDesc"+i,cp.getClasifAdmiDesc())%>
						<%=fb.hidden("estado"+i,cp.getEstado())%>
						<%=fb.hidden("expanded"+i,cp.getExpanded())%>
						<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"<%=displayClasif%>>
							<td align="center"><%=cp.getCategoriaAdmi()%></td>
							<td><%=cp.getCategoriaAdmiDesc()%></td>
							<td align="center"><%=cp.getTipoAdmi()%></td>
							<td><%=cp.getTipoAdmiDesc()%></td>
							<td align="center"><%=cp.getClasifAdmi()%></td>
							<td><%=cp.getClasifAdmiDesc()%></td>
							<td align="center" onClick="javascript:showDetail(<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la Clasificicación"></td>
							<td align="center"><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeClasif('"+i+"')\"","Eliminar Clasificación")%></td>
						</tr>
						<tr class="TextRow08" id="detail<%=i%>" style="display:none">
							<td colspan="2" valign="top">
								<table width="100%" cellpadding="1" cellspacing="0">
								<!--<tr class="TextHeader02">
									<td><cellbytelabel>Descripci&oacute;n del Perdiem</cellbytelabel></td>
								</tr>
								<tr class="TextRow08">
									<td><%//=fb.textarea("perdiemDsp"+i,cp.getPerdiemDsp(),false,false,false,35,3,"Text10",null,null)%></td>
								</tr>-->
								<tr class="TextHeader02">
									<td><cellbytelabel>Descuento de Cl&iacute;nica</cellbytelabel></td>
								</tr>
								<tr class="TextRow08">
									<td>
										<cellbytelabel>Monto</cellbytelabel>
										<%=fb.decBox("montoClinica"+i,"",false,false,false,13,"Text10",null,null)%>
										<%=fb.select("tipoValCli"+i,"P=%",cp.getTipoValCli(),false,false,0,"Text10",null,null)%>
										<%//=fb.select("tipoCobCli"+i,"D=DIARIO,E=EVENTO",cp.getTipoCobCli(),false,false,0,"Text10",null,null)%>
										<%=fb.select("tipoCobCli"+i,"E=EVENTO",cp.getTipoCobCli(),false,false,0,"Text10",null,null)%>
										<br>
										<cellbytelabel>Forma</cellbytelabel>
										<%//=fb.select("descuentoCli"+i,"ST=SOBRE EL TOTAL DE CARGOS,N=NORMAL",cp.getDescuentoCli(),false,false,0,"Text10",null,null,null,"S")%>
										<%=fb.select("descuentoCli"+i,"ST=SOBRE EL TOTAL DE CARGOS",cp.getDescuentoCli(),false,false,0,"Text10",null,null,null,"")%>
									</td>
								</tr>
								</table>
							</td>
							<td colspan="2" valign="top">
								<table width="100%" cellpadding="1" cellspacing="0">
								<tr class="TextHeader02">
									<td><cellbytelabel>Pago del Paciente</cellbytelabel></td>
								</tr>
								<tr class="TextRow08">
									<td>
										<cellbytelabel>Monto</cellbytelabel>
										<%=fb.decBox("montoPaciente"+i,cp.getMontoPaciente(),false,false,false,13,"Text10",null,null)%>
										<%=fb.select("tipoValPac"+i,"P=%,M=$",cp.getTipoValPac(),false,false,0,"Text10",null,null)%>
										<%//=fb.select("tipoCobPac"+i,"D=DIARIO,E=EVENTO",cp.getTipoCobPac(),false,false,0,"Text10",null,null)%>
										<%=fb.select("tipoCobPac"+i,"E=EVENTO",cp.getTipoCobPac(),false,false,0,"Text10",null,null)%>
										<br>
										<!--<cellbytelabel>Tipo de Pago</cellbytelabel>
										<%//=fb.select("tipoPagoPac"+i,"CO=COPAGO,CS=COASEGURO",cp.getTipoPagoPac(),false,false,0,"Text10",null,null,null,"S")%>
										<br>
										<cellbytelabel>L&iacute;mite de D&iacute;as de Co-Pago</cellbytelabel>
										<%//=fb.intBox("diasLimite"+i,cp.getDiasLimite(),false,false,false,13,"Text10",null,null)%>
										<br>
										<cellbytelabel>Co-Pago por Solicitud de Beneficio</cellbytelabel>
										<%//=fb.checkbox("solBenefPac"+i,"S",(cp.getSolBenefPac() != null && cp.getSolBenefPac().equalsIgnoreCase("S")),false)%>-->
										<%=fb.hidden("tipoPagoPac"+i,cp.getTipoPagoPac())%>
										<%=fb.hidden("diasLimite"+i,cp.getDiasLimite())%>
										<span style="visibility:hidden">
										<%=fb.checkbox("solBenefPac"+i,"S",(cp.getSolBenefPac() != null && cp.getSolBenefPac().equalsIgnoreCase("S")),false)%>
										</span>
									</td>
								</tr>
								<tr class="">
									<td><!--Paquetes Obst&eacute;tricos--></td>
								</tr>
								<tr class="TextRow08">
									<td>
										<!--Utilizar lista de insumos detallados-->
										<%=fb.hidden("listaInsumo"+i,"N")%>
									</td>
								</tr>
								</table>
							</td>
							<td colspan="3" valign="top">
								<table width="100%" cellpadding="1" cellspacing="0">
								<tr class="TextHeader02">
									<td colspan="3">
									<!--<cellbytelabel>Pago de la Aseguradora / Empresa</cellbytelabel>-->&nbsp;
									</td>
								</tr>
								<tr class="TextRow08">
									<td colspan="3">
										<%--<cellbytelabel>Monto</cellbytelabel>
										<%=fb.decBox("montoEmpresa"+i,cp.getMontoEmpresa(),false,false,false,13,"Text10",null,null)%>
										<%=fb.select("tipoValEmp"+i,"P=%,M=$",cp.getTipoValEmp(),false,false,0,"Text10",null,null)%>
										<%=fb.select("tipoCobEmp"+i,"D=DIARIO,E=EVENTO",cp.getTipoCobEmp(),false,false,0,"Text10",null,null)%>
										<br>
										<cellbytelabel>D&iacute;as Cubiertos</cellbytelabel>
										<%=fb.intBox("limiteEstadia"+i,cp.getLimiteEstadia(),false,false,false,13,"Text10",null,null)%>
										<br>
										<cellbytelabel>Perdiem</cellbytelabel>
										<%=fb.select("tipoPagoEmp"+i,"P=PERDIEM",cp.getTipoPagoEmp(),false,false,0,"Text10",null,null,null,"S")%>
										<br>
										<cellbytelabel>Por Solicitud de Beneficio</cellbytelabel>
										<%=fb.checkbox("solBenefEmp"+i,"S",(cp.getSolBenefEmp() != null && cp.getSolBenefEmp().equalsIgnoreCase("S")),false)%> --%>
									</td>
									
									<%=fb.hidden("montoEmpresa"+i,cp.getMontoEmpresa())%>
									<%=fb.hidden("tipoValEmp"+i,cp.getTipoValEmp())%>
									<%=fb.hidden("tipoCobEmp"+i,cp.getTipoCobEmp())%>
									<%=fb.hidden("limiteEstadia"+i,cp.getLimiteEstadia())%>
									<%=fb.hidden("tipoPagoEmp"+i,cp.getTipoPagoEmp())%>
									<%=fb.hidden("solBenefEmp"+i,cp.getSolBenefEmp())%>
								</tr>
								<tr align="center" height="35">
									<td width="50%" class="TextHeader02" onMouseOver="setoverc(this,'TextHeaderOver')" onMouseOut="setoutc(this,'TextHeader02')" style="cursor:pointer" onClick="javascript:showClasif(0,<%=cp.getCategoriaAdmi()%>,<%=cp.getTipoAdmi()%>,<%=cp.getClasifAdmi()%>)"><cellbytelabel>COBERTURAS</cellbytelabel></td>
									<td width="50%" class="TextHeader02" onMouseOver="setoverc(this,'TextHeaderOver')" onMouseOut="setoutc(this,'TextHeader02')" style="cursor:pointer" onClick="javascript:showClasif(1,<%=cp.getCategoriaAdmi()%>,<%=cp.getTipoAdmi()%>,<%=cp.getClasifAdmi()%>)"><cellbytelabel>EXCLUSIONES</cellbytelabel></td>
									<td width="34%" class="TextHeader02" onMouseOver="setoverc(this,'TextHeaderOver')" onMouseOut="setoutc(this,'TextHeader02')" style="cursor:pointer" onClick="javascript:showClasif(2,<%=cp.getCategoriaAdmi()%>,<%=cp.getTipoAdmi()%>,<%=cp.getClasifAdmi()%>)"><cellbytelabel>DEFINICION DE CALCULOS</cellbytelabel></td>
								</tr>
								</table>
							</td>
							<td>&nbsp;</td>
						</tr>
<%
	if (cp.getEstado() != null && !cp.getEstado().equals("D") && cp.getExpanded() != null && cp.getExpanded().equals("1"))
	{
%>
						<script language="javascript">showDetail(<%=i%>)</script>
<%
	}
}//ClasificacionPlan
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&"+validClasif+"<=0){alert('Por favor seleccione por lo menos una clasificación para el plan!');error++;}");
%>
						</table>
					</td>
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
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	String itemRemoved = "";

	int planSize = 0;
	if (request.getParameter("planSize") != null) planSize = Integer.parseInt(request.getParameter("planSize"));

	Convenio conv = new Convenio();
	conv.setEmpresa(request.getParameter("empresa"));
	conv.setSecuencia(request.getParameter("secuencia"));

	conv.getPlanConvenio().clear();
	for (int i=1; i<=planSize; i++)
	{
		PlanConvenio pcTemp = new PlanConvenio();

		pcTemp.setKey(request.getParameter("pcKey"+i));
		pcTemp.setTipoPoliza(request.getParameter("pcTipoPoliza"+i));
		pcTemp.setNombreTipoPoliza(request.getParameter("pcNombreTipoPoliza"+i));
		pcTemp.setTipoPlan(request.getParameter("pcTipoPlan"+i));
		pcTemp.setNombreTipoPlan(request.getParameter("pcNombreTipoPlan"+i));
		pcTemp.setSecuencia(request.getParameter("pcSecuencia"+i));
		pcTemp.setNombre(request.getParameter("pcNombre"+i));
		if (request.getParameter("removePlanKey") != null && request.getParameter("removePlanKey").equals(pcTemp.getKey()))
		{
			itemRemoved = pcTemp.getKey();
			pcTemp.setEstado("D");//D=Delete action in ConvenioMgr
			vPlan.remove(pc.getTipoPoliza()+"-"+pc.getTipoPlan());
		}
		else pcTemp.setEstado(request.getParameter("pcEstado"+i));
		pcTemp.setAplicaDesc(request.getParameter("pcAplicaDesc"+i));
		pcTemp.setAplicaCo(request.getParameter("pcAplicaCo"+i));

		try
		{
			iPlan.put(pcTemp.getKey(),pcTemp);
			if (!pcTemp.getTipoPoliza().equals(request.getParameter("tipoPoliza")) && !pcTemp.getTipoPlan().equals(request.getParameter("tipoPlan")) && !pcTemp.getSecuencia().equals(request.getParameter("planNo"))) conv.addPlanConvenio(pcTemp);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&planLastLineNo="+planLastLineNo);
		return;
	}

	int clasifSize = 0;
	if (request.getParameter("clasifSize") != null) clasifSize = Integer.parseInt(request.getParameter("clasifSize"));

	pc.setTipoPoliza(request.getParameter("tipoPoliza"));
	pc.setTipoPlan(request.getParameter("tipoPlan"));
	pc.setSecuencia(request.getParameter("planNo"));
	pc.setNombre(request.getParameter("nombre"));
	pc.setEstado(request.getParameter("estado"));
	pc.setAplicaDesc(request.getParameter("aplica_desc"));
	pc.setAplicaCo(request.getParameter("aplica_co"));

	pc.getClasificacionPlan().clear();
	for (int i=1; i<=clasifSize; i++)
	{
		ClasificacionPlan cp = new ClasificacionPlan();

		cp.setKey(request.getParameter("key"+i));
		cp.setCategoriaAdmi(request.getParameter("categoriaAdmi"+i));
		cp.setCategoriaAdmiDesc(request.getParameter("categoriaAdmiDesc"+i));
		cp.setTipoAdmi(request.getParameter("tipoAdmi"+i));
		cp.setTipoAdmiDesc(request.getParameter("tipoAdmiDesc"+i));
		cp.setClasifAdmi(request.getParameter("clasifAdmi"+i));
		cp.setClasifAdmiDesc(request.getParameter("clasifAdmiDesc"+i));
		cp.setPerdiemDsp(request.getParameter("perdiemDsp"+i));
		cp.setMontoClinica(request.getParameter("montoClinica"+i));
		cp.setTipoValCli(request.getParameter("tipoValCli"+i));
		cp.setTipoCobCli(request.getParameter("tipoCobCli"+i));
		cp.setDescuentoCli(request.getParameter("descuentoCli"+i));
		cp.setMontoPaciente(request.getParameter("montoPaciente"+i));
		cp.setTipoValPac(request.getParameter("tipoValPac"+i));
		cp.setTipoCobPac(request.getParameter("tipoCobPac"+i));
		cp.setTipoPagoPac(request.getParameter("tipoPagoPac"+i));
		cp.setDiasLimite(request.getParameter("diasLimite"+i));
		cp.setSolBenefPac((request.getParameter("solBenefPac"+i)==null)?"N":"S");
		cp.setSolBenefEmp((request.getParameter("solBenefEmp"+i)==null)?"N":"S");
		cp.setListaInsumo(request.getParameter("listaInsumo"+i));
		cp.setMontoEmpresa(request.getParameter("montoEmpresa"+i));
		cp.setTipoValEmp(request.getParameter("tipoValEmp"+i));
		cp.setTipoCobEmp(request.getParameter("tipoCobEmp"+i));
		cp.setLimiteEstadia(request.getParameter("limiteEstadia"+i));
		cp.setTipoPagoEmp(request.getParameter("tipoPagoEmp"+i));
		cp.setUsuarioCreacion((String) session.getAttribute("_userName"));
		cp.setUsuarioModificacion((String) session.getAttribute("_userName"));
		cp.setExpanded(request.getParameter("expanded"+i));

		//Default values from ADM60041
		cp.setDeducibleSino("N");
		cp.setPagaDif("N");
		cp.setGananciaPerdida("N");
		cp.setPagaDiasAdic("N");
		cp.setPacHnaSino("N");
		cp.setProcesarHon("N");
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cp.getKey();
			cp.setEstado("D");//D=Delete action in ConvenioMgr
			vClasif.remove(cp.getCategoriaAdmi()+"-"+cp.getTipoAdmi()+"-"+cp.getClasifAdmi());
		}
		else cp.setEstado(request.getParameter("estado"+i));

		try
		{
			iClasif.put(cp.getKey(),cp);
			pc.addClasificacionPlan(cp);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&planLastLineNo="+planLastLineNo+"&clasifLastLineNo="+clasifLastLineNo);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&planLastLineNo="+planLastLineNo+"&clasifLastLineNo="+clasifLastLineNo);
		return;
	}

	conv.addPlanConvenio(pc);

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConvMgr.savePlan(conv);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	parent.document.form1.tipoPoliza.value='<%=pc.getTipoPoliza()%>';
	parent.document.form1.tipoPlan.value='<%=pc.getTipoPlan()%>';
	parent.document.form1.planNo.value='<%=pc.getSecuencia()%>';
	parent.document.form1.errCode.value='<%=ConvMgr.getErrCode()%>';
	parent.document.form1.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(ConvMgr.getErrMsg())%>';
	parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>