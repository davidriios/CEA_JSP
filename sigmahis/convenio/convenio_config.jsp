<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.Convenio"%>
<%@ page import="issi.convenio.PlanConvenio"%>
<%@ page import="issi.convenio.GastoNoCubierto"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iPlan" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPlan" scope="session" class="java.util.Vector" />
<jsp:useBean id="iGNC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vGNC" scope="session" class="java.util.Vector" />
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

Convenio conv = new Convenio();
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
int gncLastLineNo = 0;
String compania = ((String) session.getAttribute("_companyId"));
if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("planLastLineNo") != null) planLastLineNo = Integer.parseInt(request.getParameter("planLastLineNo"));
if (request.getParameter("gncLastLineNo") != null) gncLastLineNo = Integer.parseInt(request.getParameter("gncLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		empresa = "0";
		secuencia = "0";

		conv.setEmpresa(empresa);
		conv.setSecuencia(secuencia);
		conv.setFechaInicial(CmnMgr.getCurrentDate("dd/mm/yyyy"));
	}
	else
	{
		if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");

		sql = "select a.empresa, a.secuencia, a.nombre, a.tipo_convenio as tipoConvenio, to_char(a.fecha_inicial,'dd/mm/yyyy') as fechaInicial, nvl(to_char(a.fecha_final,'dd/mm/yyyy'),' ') as fechaFinal, a.representa_empresa as representaEmpresa, a.representa_clinica as representaClinica, a.contacto, a.tramitante as tramitante, nvl(a.red_medico,'N') as redMedico, a.contenido, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, nvl(a.estatus,'A') as estatus, b.nombre as nombreEmpresa from tbl_adm_convenio a, tbl_adm_empresa b where a.empresa=b.codigo and a.empresa="+empresa+" and a.secuencia="+secuencia;
		System.out.println("SQL:\n"+sql);
		conv = (Convenio) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Convenio.class);

		if (change == null)
		{
			iPlan.clear();
			vPlan.clear();
			iGNC.clear();
			vGNC.clear();

			sql = "select a.empresa, a.convenio, a.secuencia, a.nombre, a.tipo_plan as tipoPlan, a.tipo_poliza as tipoPoliza, a.estado, b.nombre as nombreEmpresa, c.nombre as nombreConvenio, d.nombre as nombreTipoPlan, e.nombre as nombreTipoPoliza, a.aplica_desc as aplicaDesc, a.aplica_co as aplicaCo,a.vip, decode(to_char(a.empresa),nvl(get_sec_comp_param("+compania+",'COD_EMP_PARTICULAR'),'-1'),'S','N') as empresaPart from tbl_adm_plan_convenio a, tbl_adm_empresa b, tbl_adm_convenio c, tbl_adm_tipo_plan d, tbl_adm_tipo_poliza e where a.empresa=b.codigo and a.empresa=c.empresa and a.convenio=c.secuencia and a.tipo_poliza=d.poliza and a.tipo_plan=d.tipo_plan and a.tipo_poliza=e.codigo and a.empresa="+empresa+" and a.convenio="+secuencia;
			System.out.println("SQL:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,PlanConvenio.class);

			planLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				PlanConvenio pc = (PlanConvenio) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				pc.setKey(key);

				try
				{
					iPlan.put(pc.getKey(), pc);
					vPlan.addElement(pc.getTipoPoliza()+"-"+pc.getTipoPlan());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i

			sql = "select a.cod_empresa as codEmpresa, a.cod_convenio as codConvenio, a.secuencia, a.centro_servicio as centroServicio, a.tipo_cds as tipoCds, a.tipo_servicio as tipoServicio, a.compania, a.procedimiento, a.otros_cargos as otrosCargos, a.cds_producto as cdsProducto, a.habitacion, a.inv_articulo as invArticulo, a.art_familia as artFamilia, a.cod_uso as codUso, a.precio, a.monto_clinica as montoClinica, a.tipo_val_cli as tipoValCli, a.monto_paciente as montoPaciente, a.tipo_val_pac as tipoValPac, a.monto_empresa as montoEmpresa, a.tipo_val_emp as tipoValEmp, a.art_clase as artClase, a.inventario_sino as inventarioSino, '['||b.codigo||'] '||b.descripcion as tipoServicioDesc, decode(a.tipo_cds,'I','INTERNO','T','TERCERO','E','EXTERNO','---') as tipoCdsDesc, coalesce(a.procedimiento,/*decode(a.art_familia,null,null,decode(a.art_clase,null,null,*/decode(a.inv_articulo,null,null,a.inv_articulo), ''||a.cod_uso, ''||a.otros_cargos, ''||a.cds_producto) as codigo, coalesce(c.descripcion,d.observacion,d.descripcion,e.descripcion,f.descripcion) as descripcion from tbl_adm_gastos_no_cubiertos a, tbl_cds_tipo_servicio b, tbl_inv_articulo c, tbl_cds_procedimiento d, tbl_sal_uso e, (select codigo, compania, descripcion from tbl_fac_otros_cargos where activo_inactivo='A') f where a.tipo_servicio=b.codigo(+) and a.inv_articulo=c.cod_articulo(+) /*and a.art_clase=c.cod_clase(+) and a.art_familia=c.cod_flia(+) */ and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.cod_uso=e.codigo(+) and a.compania=e.compania(+) and a.otros_cargos=f.codigo(+) and a.compania=f.compania(+) and a.cod_empresa="+empresa+" and a.cod_convenio="+secuencia;
			System.out.println("SQL:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,GastoNoCubierto.class);

			gncLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				GastoNoCubierto gnc = (GastoNoCubierto) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				gnc.setKey(key);

				try
				{
					iGNC.put(gnc.getKey(), gnc);
					String iType = "";
					if (gnc.getProcedimiento() != null && !gnc.getProcedimiento().trim().equals("")) iType = "P";
					else if (gnc.getOtrosCargos() != null && !gnc.getOtrosCargos().trim().equals("")) iType = "O";
					else if (gnc.getCdsProducto() != null && !gnc.getCdsProducto().trim().equals("")) iType = "C";
					else if (gnc.getCodUso() != null && !gnc.getCodUso().trim().equals("")) iType = "U";
					else if (gnc.getHabitacion() != null && !gnc.getHabitacion().trim().equals("")) iType = "H";
					else if (gnc.getInvArticulo() != null && !gnc.getInvArticulo().trim().equals("")) iType = "A";
					vGNC.addElement(iType+"-"+gnc.getCodigo());
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

function showEmpresaList()
{
	abrir_ventana1('../common/search_empresa.jsp?fp=convenio');
}

function showPlanList()
{
	abrir_ventana1('../common/check_tipoPlan_x_tipoPoliza.jsp?fp=convenio&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&planLastLineNo=<%=planLastLineNo%>');
}

function displayPlan(tipoPoliza,tipoPlan,planNo)
{
	setFrameSrc('iDetalle','../convenio/convenio_plan.jsp?tab=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza='+tipoPoliza+'&tipoPlan='+tipoPlan+'&planNo='+planNo);
}

function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
	showPlanList();
<%
		}
		else if (tab.equals("2"))
		{
%>
<%
		}
		else if (tab.equals("3"))
		{
%>
<%
		}
	}

	if (tab.equals("1") && tipoPoliza != null && !tipoPoliza.trim().equals("") && tipoPlan != null && !tipoPlan.trim().equals("") && planNo != null && !planNo.trim().equals(""))
	{
%>
		displayPlan(<%=tipoPoliza%>,<%=tipoPlan%>,<%=planNo%>);
<%
	}
%>
}

function removePlan(k)
{
	var planNo=eval('document.form1.secuencia'+k).value;
	var msg='';

	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cober_x_clasif_plan','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan='+planNo,''))msg+='\n- Coberturas';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_excl_clasif_plan','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan='+planNo,''))msg+='\n- Exclusiones';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_aplicacion_beneficio','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan='+planNo,''))msg+='\n- Aplicaciones de Beneficio';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan='+planNo,''))msg+='\n- Beneficios en Admisión';
	if(hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','cod_empresa=<%=empresa%> and convenio=<%=secuencia%> and tipo_plan='+planNo,''))msg+='\n- Facturas';

	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar el Plan y sus Clasificaciones?'))
		{
			document.form1.removePlanKey.value = eval('document.form1.key'+k).value;
			removeItem('form1',k);
			form1BlockButtons(true);
			if(document.getElementById('iDetalle').src!='')window.frames['iDetalle'].form1BlockButtons(true);
			document.form1.submit();
		}
	}
	else alert('El Plan no se puede eliminar ya que tienen Clasificaciones relacionadas los siguientes documentos:'+msg);
}

function removeGNC(k)
{
	if(confirm('¿Está seguro de eliminar el Gasto No Cubierto?'))
	{
		removeItem('form2',k);
		form2BlockButtons(true);
		document.form2.submit();
	}
}

function doSubmit()
{
	setBAction('form1','Guardar');
	if(form1Validation())
		if(document.getElementById('iDetalle').src!='')window.frames['iDetalle'].doSubmit();
		else document.form1.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE CONVENIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("planSize",""+iPlan.size())%>
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("gncSize",""+iGNC.size())%>
<%=fb.hidden("gncLastLineNo",""+gncLastLineNo)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Empresa</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("empresa",conv.getEmpresa(),true,false,true,5)%>
								<%=fb.textBox("nombreEmpresa",conv.getNombreEmpresa(),true,false,true,80)%>
								<%=fb.button("btnEmpresa","...",false,(mode.equalsIgnoreCase("edit")),null,null,"onClick=\"javascript:showEmpresaList()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Convenio</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("secuencia",conv.getSecuencia(),true,false,true,3)%>
								<%=fb.textBox("nombre",conv.getNombre(),true,false,false,80,100)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
							<td width="35%">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fechaInicial" />
								<jsp:param name="valueOfTBox1" value="<%=conv.getFechaInicial()%>" />
								</jsp:include>
							</td>
							<td width="15%" align="right"><cellbytelabel>Fecha Final</cellbytelabel></td>
							<td width="35%">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fechaFinal" />
								<jsp:param name="valueOfTBox1" value="<%=conv.getFechaFinal()%>" />
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Utiliza Red de M&eacute;dico</cellbytelabel></td>
							<td><%=fb.checkbox("redMedico","S",(conv.getRedMedico() != null && conv.getRedMedico().equals("S")),false)%></td>
							<td align="right">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Representante Empresa</cellbytelabel></td>
							<td><%=fb.textBox("representaEmpresa",conv.getRepresentaEmpresa(),false,false,false,50,100)%></td>
							<td align="right">Representante Clinica</td>
							<td><%=fb.textBox("representaClinica",conv.getRepresentaClinica(),false,false,false,50,100)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Contacto</cellbytelabel></td>
							<td><%=fb.textBox("contacto",conv.getContacto(),true,false,false,50,100)%></td>
							<td align="right">Tramitante</td>
							<td><%=fb.textBox("tramitante",conv.getTramitante(),false,false,false,50,100)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Contenido</cellbytelabel></td>
							<td colspan="3"><%=fb.textarea("contenido",conv.getContenido(),true,false,false,80,5,2000)%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
<jsp:include page="../common/bitacora.jsp" flush="true">
	<jsp:param name="audTable" value="tbl_adm_convenio"></jsp:param>
	<jsp:param name="audFilter" value="<%="empresa="+empresa+" and secuencia="+secuencia%>"></jsp:param>
</jsp:include>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("planSize",""+iPlan.size())%>
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("gncSize",""+iGNC.size())%>
<%=fb.hidden("gncLastLineNo",""+gncLastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Convenio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Empresa</cellbytelabel></td>
							<td width="85%" colspan="3">[<%=conv.getEmpresa()%>] <%=conv.getNombreEmpresa()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Convenio</cellbytelabel></td>
							<td>[<%=conv.getSecuencia()%>] <%=conv.getNombre()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Lista de Planes</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td class="TextRow01">
						<div id="planes" style="overflow:scroll; position:static; height:135">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel>Tipo de P&oacute;liza</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Tipo de Plan</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Plan</cellbytelabel></td>
							<td rowspan="2" width="7%"><cellbytelabel>Estado</cellbytelabel></td>
							<td rowspan="2" width="1%">&nbsp;</td>
							<td rowspan="2" width="2%"><%=fb.submit("addPlan","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Planes")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="24%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="24%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>No</cellbytelabel>.</td>
							<td width="27%"><cellbytelabel>Nombre</cellbytelabel></td>
						</tr>
<%=fb.hidden("removePlanKey","")%>
<%
String newPlan = "N";
al = CmnMgr.reverseRecords(iPlan);
for (int i=1; i<=iPlan.size(); i++)
{
	key = al.get(i - 1).toString();
	PlanConvenio pc = (PlanConvenio) iPlan.get(key);

	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	if (pc.getSecuencia() != null && pc.getSecuencia().equals("0") && !pc.getEstado().equalsIgnoreCase("D")) newPlan = "Y";
%>
						<%=fb.hidden("key"+i,pc.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("tipoPoliza"+i,pc.getTipoPoliza())%>
						<%=fb.hidden("nombreTipoPoliza"+i,pc.getNombreTipoPoliza())%>
						<%=fb.hidden("tipoPlan"+i,pc.getTipoPlan())%>
						<%=fb.hidden("nombreTipoPlan"+i,pc.getNombreTipoPlan())%>
						<%=fb.hidden("secuencia"+i,pc.getSecuencia())%>
						<%=fb.hidden("nombre"+i,pc.getNombre())%>
						<%=fb.hidden("estado"+i,pc.getEstado())%>
						<%=fb.hidden("aplica_desc"+i,pc.getAplicaDesc())%>
						<%=fb.hidden("aplica_co"+i,pc.getAplicaCo())%>
						<%=fb.hidden("vip"+i,pc.getVip())%>
						<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"<%=(pc.getEstado() != null && pc.getEstado().equalsIgnoreCase("D"))?" style=\"display:none\"":""%>>
							<td align="center"><%=pc.getTipoPoliza()%></td>
							<td><%=pc.getNombreTipoPoliza()%></td>
							<td align="center"><%=pc.getTipoPlan()%></td>
							<td><%=pc.getNombreTipoPlan()%></td>
							<td align="center"><%=pc.getSecuencia()%></td>
							<td><%=pc.getNombre()%></td>
							<td align="center">
								<% if(pc.getEstado() != null && !pc.getEstado().trim().equals("") && pc.getEstado().equalsIgnoreCase("A")){%><cellbytelabel>ACTIVO</cellbytelabel><%}else{%>
								<cellbytelabel>INACTIVO</cellbytelabel><%}%>
							</td>
							<td align="center" onClick="javascript:displayPlan(<%=pc.getTipoPoliza()%>,<%=pc.getTipoPlan()%>,<%=pc.getSecuencia()%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Ver / Editar detalles del Plan"></td>
							<td align="center"><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removePlan('"+i+"')\"","Eliminar Plan")%></td>
						</tr>
<%
}//PlanConvenio
%>
						</table>
						</div>
						<iframe id="iDetalle" name="iDetalle" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					</td>
				</tr>
<%=fb.hidden("newPlan",newPlan)%>
<%fb.appendJsValidation("if(document.form1.baction.value=='+'&&document.form1.newPlan.value=='Y'){alert('Por favor guarde antes de continuar agregando otro plan!');error++;}");%>
<%//fb.appendJsValidation("if(error==0&&document.getElementById('iDetalle').src!='')window.frames['iDetalle'].doSubmit();");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("planSize",""+iPlan.size())%>
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("gncSize",""+iGNC.size())%>
<%=fb.hidden("gncLastLineNo",""+gncLastLineNo)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Convenio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Empresa</cellbytelabel></td>
							<td width="85%" colspan="3">[<%=conv.getEmpresa()%>] <%=conv.getNombreEmpresa()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Convenio</cellbytelabel></td>
							<td>[<%=conv.getSecuencia()%>] <%=conv.getNombre()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Gastos No Cubiertos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Tipo de CDS</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Inventario</cellbytelabel></td>
							<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="37%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="12%"><cellbytelabel>Precio</cellbytelabel></td>
							<td width="3%">&nbsp;<%//=fb.submit("addGNC","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Gasto No Cubierto")%></td>
						</tr>
						<tr>
							<td colspan="7">
								<iframe id="iDetalleGNC" name="iDetalleGNC" width="100%" height="25" scrolling="no" frameborder="0" src="../convenio/add_gnc.jsp?tab=2&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&gncLastLineNo=<%=gncLastLineNo%>"></iframe>
							</td>
						</tr>
<%
al = CmnMgr.reverseRecords(iGNC);
for (int i=1; i<=iGNC.size(); i++)
{
	key = al.get(i - 1).toString();
	GastoNoCubierto gnc = (GastoNoCubierto) iGNC.get(key);

	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
%>
						<%=fb.hidden("key"+i,gnc.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("status"+i,gnc.getStatus())%>
						<%=fb.hidden("secuencia"+i,gnc.getSecuencia())%>
						<%=fb.hidden("tipoCds"+i,gnc.getTipoCds())%>
						<%=fb.hidden("tipoCdsDesc"+i,gnc.getTipoCdsDesc())%>
						<%=fb.hidden("tipoServicio"+i,gnc.getTipoServicio())%>
						<%=fb.hidden("tipoServicioDesc"+i,gnc.getTipoServicioDesc())%>
						<%=fb.hidden("compania"+i,gnc.getCompania())%>
						<%=fb.hidden("procedimiento"+i,gnc.getProcedimiento())%>
						<%=fb.hidden("otrosCargos"+i,gnc.getOtrosCargos())%>
						<%=fb.hidden("cdsProducto"+i,gnc.getCdsProducto())%>
						<%=fb.hidden("habitacion"+i,gnc.getHabitacion())%>
						<%=fb.hidden("invArticulo"+i,gnc.getInvArticulo())%>
						<%=fb.hidden("artFamilia"+i,gnc.getArtFamilia())%>
						<%=fb.hidden("artClase"+i,gnc.getArtClase())%>
						<%=fb.hidden("codUso"+i,gnc.getCodUso())%>
						<%=fb.hidden("precio"+i,gnc.getPrecio())%>
						<%=fb.hidden("inventarioSino"+i,gnc.getInventarioSino())%>
						<%=fb.hidden("codigo"+i,gnc.getCodigo())%>
						<%=fb.hidden("descripcion"+i,gnc.getDescripcion())%>
						<tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"<%=(gnc.getStatus() != null && gnc.getStatus().equalsIgnoreCase("D"))?" style=\"display:none\"":""%>>
							<td><%=gnc.getTipoServicioDesc()%></td>
							<td><%=gnc.getTipoCdsDesc()%></td>
							<td><%=(gnc.getInventarioSino() != null && gnc.getInventarioSino().equalsIgnoreCase("S"))?"SI":"NO"%></td>
							<td><%=gnc.getCodigo()%></td>
							<td align="left"><%=gnc.getDescripcion()%></td>
							<td align="right"><%=CmnMgr.getFormattedDecimal(gnc.getPrecio())%></td>
							<td align="center"><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeGNC('"+i+"')\"","Eliminar Gasto No Cubierto")%></td>
						</tr>
<%
}//Gasto No Cubierto
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>



<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Convenios'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Planes','Gastos No Cubiertos'";//,'Emp. Contratantes'
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

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
	String baction = request.getParameter("baction");

	conv = new Convenio();
	conv.setEmpresa(request.getParameter("empresa"));
	conv.setSecuencia(request.getParameter("secuencia"));

	if (tab.equals("0")) //CONVENIO
	{
		conv.setNombre(request.getParameter("nombre"));
		conv.setFechaInicial(request.getParameter("fechaInicial"));
		conv.setFechaFinal(request.getParameter("fechaFinal"));
		conv.setRepresentaEmpresa(request.getParameter("representaEmpresa"));
		conv.setRepresentaClinica(request.getParameter("representaClinica"));
		conv.setContacto(request.getParameter("contacto"));
		conv.setTramitante(request.getParameter("tramitante"));
		if (request.getParameter("redMedico") != null && request.getParameter("redMedico").equalsIgnoreCase("S")) conv.setRedMedico("S");
		else conv.setRedMedico("N");
		conv.setContenido(request.getParameter("contenido"));
		conv.setUsuarioModificacion((String) session.getAttribute("_userName"));

		if (mode.equalsIgnoreCase("add"))
		{
			conv.setUsuarioCreacion((String) session.getAttribute("_userName"));
			conv.setEstatus("A");

			//default values from ADM60041
			conv.setTipoConvenio("C");

			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConvMgr.add(conv);
			ConMgr.clearAppCtx(null);
			secuencia = ConvMgr.getPkColValue("secuencia");
		}
		else ConvMgr.update(conv);
	}
	else if (tab.equals("1")) //PLANES
	{
		int planSize = 0;
		if (request.getParameter("planSize") != null) planSize = Integer.parseInt(request.getParameter("planSize"));
		String itemRemoved = "";

		conv.getPlanConvenio().clear();
		for (int i=1; i<=planSize; i++)
		{
			PlanConvenio pc = new PlanConvenio();

			pc.setKey(request.getParameter("key"+i));

			pc.setTipoPoliza(request.getParameter("tipoPoliza"+i));
			pc.setNombreTipoPoliza(request.getParameter("nombreTipoPoliza"+i));
			pc.setTipoPlan(request.getParameter("tipoPlan"+i));
			pc.setNombreTipoPlan(request.getParameter("nombreTipoPlan"+i));
			pc.setSecuencia(request.getParameter("secuencia"+i));
			pc.setNombre(request.getParameter("nombre"+i));
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = pc.getKey();
				pc.setEstado("D");//D=Delete action in ConvenioMgr
				vPlan.remove(pc.getTipoPoliza()+"-"+pc.getTipoPlan());
			}
			else pc.setEstado(request.getParameter("estado"+i));
			pc.setAplicaDesc(request.getParameter("aplica_desc"+i));
			pc.setAplicaCo(request.getParameter("aplica_co"+i));
			pc.setVip(request.getParameter("vip"+i));

			try
			{
				iPlan.put(pc.getKey(),pc);
				conv.addPlanConvenio(pc);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo"+planNo+"&planLastLineNo="+planLastLineNo+"&gncLastLineNo="+gncLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo"+planNo+"&planLastLineNo="+planLastLineNo+"&gncLastLineNo="+gncLastLineNo);
			return;
		}

		if (request.getParameter("errCode").equals(""))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConvMgr.savePlan(conv);
			ConMgr.clearAppCtx(null);
		}
		else
		{
			ConvMgr.setErrCode(request.getParameter("errCode"));
			ConvMgr.setErrMsg(request.getParameter("errMsg"));
		}
	}
	else if (tab.equals("2")) //GASTOS NO CUBIERTOS
	{
		int gncSize = 0;
		if (request.getParameter("gncSize") != null) gncSize = Integer.parseInt(request.getParameter("gncSize"));
		String itemRemoved = "";

		conv.getGastoNoCubierto().clear();
		for (int i=1; i<=gncSize; i++)
		{
			GastoNoCubierto gnc = new GastoNoCubierto();

			gnc.setKey(request.getParameter("key"+i));
			gnc.setSecuencia(request.getParameter("secuencia"+i));
			gnc.setTipoCds(request.getParameter("tipoCds"+i));
			gnc.setTipoCdsDesc(request.getParameter("tipoCdsDesc"+i));
			gnc.setTipoServicio(request.getParameter("tipoServicio"+i));
			gnc.setTipoServicioDesc(request.getParameter("tipoServicioDesc"+i));
			gnc.setCompania(request.getParameter("compania"+i));
			gnc.setProcedimiento(request.getParameter("procedimiento"+i));
			gnc.setOtrosCargos(request.getParameter("otrosCargos"+i));
			gnc.setCdsProducto(request.getParameter("cdsProducto"+i));
			gnc.setHabitacion(request.getParameter("habitacion"+i));
			gnc.setInvArticulo(request.getParameter("invArticulo"+i));
			gnc.setArtFamilia(request.getParameter("artFamilia"+i));
			gnc.setArtClase(request.getParameter("artClase"+i));
			gnc.setCodUso(request.getParameter("codUso"+i));
			gnc.setPrecio(request.getParameter("precio"+i));
			gnc.setInventarioSino(request.getParameter("inventarioSino"+i));
			gnc.setCodigo(request.getParameter("codigo"+i));
			gnc.setDescripcion(request.getParameter("descripcion"+i));
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = gnc.getKey();
				gnc.setStatus("D");//D=Delete action in ConvenioMgr
				String iType = "";
				if (gnc.getProcedimiento() != null && !gnc.getProcedimiento().trim().equals("")) iType = "P";
				else if (gnc.getOtrosCargos() != null && !gnc.getOtrosCargos().trim().equals("")) iType = "O";
				else if (gnc.getCdsProducto() != null && !gnc.getCdsProducto().trim().equals("")) iType = "C";
				else if (gnc.getCodUso() != null && !gnc.getCodUso().trim().equals("")) iType = "U";
				else if (gnc.getHabitacion() != null && !gnc.getHabitacion().trim().equals("")) iType = "H";
				else if (gnc.getInvArticulo() != null && !gnc.getInvArticulo().trim().equals("")) iType = "A";
				vGNC.remove(iType+"-"+gnc.getCodigo());
			}
			else gnc.setStatus(request.getParameter("status"+i));

			try
			{
				iGNC.put(gnc.getKey(),gnc);
				conv.addGastoNoCubierto(gnc);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo"+planNo+"&planLastLineNo="+planLastLineNo+"&gncLastLineNo="+gncLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConvMgr.saveGastoNoCubierto(conv);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ConvMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ConvMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/convenio/convenio_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/convenio/convenio_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/convenio/convenio_list.jsp';
<%
		}
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
} else throw new Exception(ConvMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>