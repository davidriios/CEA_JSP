<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.ClasificacionPlan"%>
<%@ page import="issi.convenio.Cobertura"%>
<%@ page import="issi.convenio.Exclusion"%>
<%@ page import="issi.convenio.AplicacionBeneficio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iCob" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCob" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExcl" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExcl" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDef" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDef" scope="session" class="java.util.Vector" />
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
String cTab = request.getParameter("cTab");
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
String change = request.getParameter("change");
int cobLastLineNo = 0;
int exclLastLineNo = 0;
int defLastLineNo = 0;
String tipoCE = request.getParameter("tipoCE");
String ce = request.getParameter("ce");
int ceCDLastLineNo = 0;
String index = request.getParameter("index");

if (tab == null) tab = "0";
if (cTab == null) cTab = "0";
if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null || planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");
if (categoriaAdm == null || tipoAdm == null || clasifAdm == null) throw new Exception("La Clasificación del Plan no es válida. Por favor intente nuevamente!");
if (request.getParameter("cobLastLineNo") != null) cobLastLineNo = Integer.parseInt(request.getParameter("cobLastLineNo"));
if (request.getParameter("exclLastLineNo") != null) exclLastLineNo = Integer.parseInt(request.getParameter("exclLastLineNo"));
if (request.getParameter("defLastLineNo") != null) defLastLineNo = Integer.parseInt(request.getParameter("defLastLineNo"));
if (change == null) change = "";
if (tipoCE == null) tipoCE = "";
if (ce == null) ce = "";
if (request.getParameter("ceCDLastLineNo") != null) ceCDLastLineNo = Integer.parseInt(request.getParameter("ceCDLastLineNo"));
if (index == null) index = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change.trim().equals(""))
	{
		iCob.clear();
		vCob.clear();
		iExcl.clear();
		vExcl.clear();
		iDef.clear();
		vDef.clear();

		sql = "select a.convenio, a.empresa, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.tipo_cobertura as tipoCobertura, a.secuencia, a.tipo_servicio as tipoServicio, a.centro_servicio as centroServicio, a.monto_cli as montoCli, a.monto_pac as montoPac, a.monto_emp as montoEmp, a.tipo_val_cli as tipoValCli, a.tipo_val_emp as tipoValEmp, a.tipo_val_pac as tipoValPac, a.cantidad_proc as cantidadProc, a.monto_proc as montoProc, a.desc_excedente as descExcedente, a.tipo_val_excedente as tipoValExcedente, a.limite_diario as limiteDiario, a.limite_evento as limiteEvento, a.paga_dif_sino as pagaDifSino, a.tipo_cob_pac as tipoCobPac, a.tipo_cob_emp as tipoCobEmp, a.monto_emp_exc as montoEmpExc, a.tipo_val_emp_exc as tipoValEmpExc, a.monto_margen_limite as montoMargenLimite, a.aplicar_param as aplicarParam, coalesce(''||a.centro_servicio,a.tipo_servicio) as codigo, coalesce(b.descripcion,c.descripcion) as descripcion,'U' as status from tbl_adm_cober_x_clasif_plan a, tbl_cds_centro_servicio b, tbl_cds_tipo_servicio c where a.centro_servicio=b.codigo(+) and a.tipo_servicio=c.codigo(+) and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" order by a.tipo_cobertura, a.secuencia";
		System.out.println("SQL ==============>>>>:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,Cobertura.class);

		cobLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			Cobertura c = (Cobertura) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			c.setKey(key);
			if (cTab.equals("0") && index.equals(""+i)) c.setExpanded("1");

			try
			{
				iCob.put(c.getKey(), c);
				vCob.add(c.getTipoCobertura()+((c.getCentroServicio() == null)?"":c.getCentroServicio())+((c.getTipoServicio() == null)?"":c.getTipoServicio()));
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}//for i


		sql = "select a.convenio, a.empresa, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.tipo_exclusion as tipoExclusion, a.secuencia, a.tipo_servicio as tipoServicio, a.centro_servicio as centroServicio, a.monto_cli as montoCli, a.monto_pac as montoPac, a.monto_emp as montoEmp, a.tipo_val_cli as tipoValCli, a.tipo_val_pac as tipoValPac, a.tipo_val_emp as tipoValEmp, a.paga_dif as pagaDif, a.pac_sol_benef as pacSolBenef, a.emp_sol_benef as empSolBenef, a.tipo_cob_pac as tipoCobPac, a.tipo_cob_emp as tipoCobEmp, a.no_cubierto as noCubierto, coalesce(''||a.centro_servicio,a.tipo_servicio) as codigo, coalesce(b.descripcion,c.descripcion) as descripcion, b.tipo_cds as tipoCds from tbl_adm_excl_clasif_plan a, tbl_cds_centro_servicio b, tbl_cds_tipo_servicio c where a.centro_servicio=b.codigo(+) and a.tipo_servicio=c.codigo(+) and a.empresa="+empresa+" and a.convenio="+secuencia+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" order by a.tipo_exclusion, a.secuencia";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,Exclusion.class);

		exclLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			Exclusion e = (Exclusion) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			e.setKey(key);
			if (cTab.equals("1") && index.equals(""+i)) e.setExpanded("1");

			try
			{
				iExcl.put(e.getKey(), e);
				vExcl.add(e.getTipoExclusion()+((e.getCentroServicio() == null)?"":e.getCentroServicio())+((e.getTipoServicio() == null)?"":e.getTipoServicio()));
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}//for i


		sql = "select a.codigo, a.secuencia, b.descripcion from tbl_adm_aplicacion_beneficio a, tbl_adm_calculo_beneficio b where a.codigo=b.codigo and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admision="+categoriaAdm+" and a.tipo_admision="+tipoAdm+" and a.clasif_admision="+clasifAdm+" order by a.secuencia";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,AplicacionBeneficio.class);

		defLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			AplicacionBeneficio ab = (AplicacionBeneficio) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			ab.setKey(key);

			try
			{
				iDef.put(ab.getKey(), ab);
				vDef.add(ab.getCodigo());
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}//for i
	}//change is null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Coberturas, Exclusiones y Definición de Cálculos';

function addCob()
{
	setBAction('form0','+');
	form0BlockButtons(true);
	window.frames['iDetalle0'].doSubmit();
}

function removeCob(k)
{
	var tipoCobertura=eval('document.form0.tipoCobertura'+k).value;
	var cobertura=eval('document.form0.secuencia'+k).value;
	var msg='';

	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_centro','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_cobertura=\''+tipoCobertura+'\' and cobertura='+cobertura,''))msg+='\n- Coberturas Centro';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_detalle_cobertura','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_cobertura=\''+tipoCobertura+'\' and cobertura='+cobertura,''))msg+='\n- Detalles Cobertura';

	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar la Cobertura?'))
		{
			removeItem('form0',k);
			form0BlockButtons(true);
			window.frames['iDetalle0'].doSubmit();
		}
	}
	else alert('La Cobertura no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}


function addExcl()
{
	setBAction('form1','+');
	form1BlockButtons(true);
	window.frames['iDetalle1'].doSubmit();
}

function removeExcl(k)
{
	var tipoExclusion=eval('document.form1.tipoExclusion'+k).value;
	var exclusion=eval('document.form1.secuencia'+k).value;
	var msg='';

	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_exclusion_centro','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_exclusion=\''+tipoExclusion+'\' and exclusion='+exclusion,''))msg+='\n- Exclusiones Centro';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_detalle_exclusion','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_exclusion=\''+tipoExclusion+'\' and exclusion='+exclusion,''))msg+='\n- Detalles Exclusión';

	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar la Exclusión?'))
		{
			removeItem('form1',k);
			form1BlockButtons(true);
			window.frames['iDetalle1'].doSubmit();
		}
	}
	else alert('La Exclusión no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}

function showDetail(cTab,k)
{
	var obj = document.getElementById('detail'+cTab+'-'+k);
	if (obj.style.display == '')
	{
		obj.style.display = 'none';
		eval('document.form'+cTab+'.expanded'+k).value = '0';
	}
	else
	{
		obj.style.display = '';
		eval('document.form'+cTab+'.expanded'+k).value = '1';
	}
}

function doAction()
{
<%
if (request.getParameter("type") != null)
{
	if (cTab.equals("2"))
	{
%>
	showCalculoBeneficioList();
<%
	}
}
%>
}

function showCalculoBeneficioList()
{
	abrir_ventana2('../common/check_calculo_beneficio.jsp?fp=convenio&tab=<%=tab%>&cTab=2&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&cobLastLineNo=<%=cobLastLineNo%>&exclLastLineNo=<%=exclLastLineNo%>&defLastLineNo=<%=defLastLineNo%>');
}

function doSubmit(cTab,baction)
{
	if (cTab == 0)
	{
		setBAction('form0',baction);
		if(form0Validation())window.frames['iDetalle0'].doSubmit();
	}
	else if (cTab == 1)
	{
		setBAction('form1',baction);
		if(form1Validation())window.frames['iDetalle1'].doSubmit();
	}
}

function showServiceList(cTab,k)
{
	var tipo = '';
	var fp = '';
	if (cTab == 0)
	{
		tipo = eval('document.form0.tipoCobertura'+k).value;
		fp = 'convenio_cobertura';
	}
	else if (cTab == 1)
	{
		tipo = eval('document.form1.tipoExclusion'+k).value;
		fp = 'convenio_exclusion';
	}
	if (tipo == 'C') abrir_ventana2('../common/search_centro_servicio.jsp?fp='+fp+'&index='+k);
	else if (tipo == 'T') abrir_ventana2('../common/search_tipo_servicio.jsp?fp='+fp+'&index='+k);
}

function clearService(cTab,k)
{
	eval('document.form'+cTab+'.tipoServicio'+k).value = '';
	eval('document.form'+cTab+'.centroServicio'+k).value = '';
	eval('document.form'+cTab+'.codigo'+k).value = '';
	eval('document.form'+cTab+'.descripcion'+k).value = '';
}

function displayDetail(cTab,tipo,secuencia,k)
{
	if (eval('document.form'+cTab+'.secuencia'+k).value == '0' || eval('document.form'+cTab+'.codigo'+k).value == '') alert('Por favor seleccione un Centro/Tipo de Servicio y guarde, antes de agregar detalles!');
	else
	{
		if (cTab == 0) setFrameSrc('iDetalle'+cTab,'../convenio/convenio_cobertura_cendet.jsp?tab=<%=tab%>&cTab='+cTab+'&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura='+tipo+'&cobertura='+secuencia+'&index='+k);
		else if (cTab == 1) setFrameSrc('iDetalle'+cTab,'../convenio/convenio_exclusion_cendet.jsp?tab=<%=tab%>&cTab='+cTab+'&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion='+tipo+'&exclusion='+secuencia+'&index='+k);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE CONVENIO - DETALLE DE CLASIFICACION"></jsp:param>
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

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextRow02">
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TextRow01">
		<div id="coberturas" style="overflow:scroll; position:static; height:250">
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("tab",tab)%>
		<%=fb.hidden("cTab","0")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("empresa",empresa)%>
		<%=fb.hidden("secuencia",secuencia)%>
		<%=fb.hidden("tipoPoliza",tipoPoliza)%>
		<%=fb.hidden("tipoPlan",tipoPlan)%>
		<%=fb.hidden("planNo",planNo)%>
		<%=fb.hidden("categoriaAdm",categoriaAdm)%>
		<%=fb.hidden("tipoAdm",tipoAdm)%>
		<%=fb.hidden("clasifAdm",clasifAdm)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("cobSize",""+iCob.size())%>
		<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
		<%=fb.hidden("exclSize",""+iExcl.size())%>
		<%=fb.hidden("exclLastLineNo",""+exclLastLineNo)%>
		<%=fb.hidden("defSize",""+iDef.size())%>
		<%=fb.hidden("defLastLineNo",""+defLastLineNo)%>
		<%=fb.hidden("errCode","")%>
		<%=fb.hidden("errMsg","")%>
		<%=fb.hidden("tipoCE","")%>
		<%=fb.hidden("ce","")%>
		<%=fb.hidden("index","")%>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel>No</cellbytelabel>.</td>
			<td width="18%"><cellbytelabel>Cobertura Por</cellbytelabel></td>
			<td width="10%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="43%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Monto x Proc. Adicionales</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Paga la Dif</cellbytelabel>.</td>
			<td width="1%">&nbsp;</td>
			<td width="2%"><%=fb.button("addCobertura","+",true,false,null,null,"onClick=\"javascript:addCob()\"","Agregar Cobertura")%></td>
		</tr>
<%
int validCob = iCob.size();
al = CmnMgr.reverseRecords(iCob);
for (int i=1; i<=iCob.size(); i++)
{
	key = al.get(i - 1).toString();
	Cobertura c = (Cobertura) iCob.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayCob = "";
	if (c.getStatus() != null && c.getStatus().equalsIgnoreCase("D"))
	{
		displayCob = " style=\"display:none\"";
		validCob--;
	}
%>
		<%=fb.hidden("key"+i,c.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("status"+i,c.getStatus())%>
		<%=fb.hidden("expanded"+i,c.getExpanded())%>
		<%=fb.hidden("tipoServicio"+i,c.getTipoServicio())%>
		<%=fb.hidden("centroServicio"+i,c.getCentroServicio())%>
		<%=fb.hidden("secuencia"+i,c.getSecuencia())%>
		<tr class="<%=color%>" align="center"<%=displayCob%>>
			<td><%=c.getSecuencia()%></td>
			<td>
<%if (c.getSecuencia() != null && !c.getSecuencia().equals("0") || (c.getSecuencia() != null && c.getSecuencia().equals("0") && c.getCodigo() != null && !c.getCodigo().trim().equals(""))) {%>
				<%=fb.hidden("tipoCobertura"+i,c.getTipoCobertura())%>
				<%//=(c.getTipoCobertura().equalsIgnoreCase("C"))?"CENTRO DE SERVICIO":"TIPO DE SERVICIO"%>
				<%if(c.getTipoCobertura().equalsIgnoreCase("C")){%>
				 <cellbytelabel>CENTRO DE SERVICIO</cellbytelabel>
				<%}else{%>
				 <cellbytelabel>TIPO DE SERVICIO</cellbytelabel>
				<%}%>
                
<%} else {%>
				<%=fb.select("tipoCobertura"+i,"C=CENTRO DE SERVICIO,T=TIPO DE SERVICIO",c.getTipoCobertura(),false,false,0,"Text10",null,"onChange=\"javascript:clearService(0,"+i+")\"")%>
<%}%>
			</td>
			<td><%=fb.textBox("codigo"+i,c.getCodigo(),false,false,true,5,"Text10",null,null)%></td>
			<td>
				<%=fb.textBox("descripcion"+i,c.getDescripcion(),false,false,true,60,"Text10",null,null)%>
				<%=(c.getCodigo() != null && !c.getCodigo().trim().equals(""))?"":fb.button("btnService"+i,"...",true,false,null,null,"onClick=\"javascript:showServiceList(0,"+i+")\"")%>
				<%--Disable the button when the service is choosen, because if the button is enabled, it will be a problem when selecting another service, the choosen service will be stored in a vector, so it never getting deleted when changing service, if we want to remove the old service then the service listing page has to do a submit action to delete the item. S A M E   N O T E   G O E S   T O   E X C L U S I O N--%>
			</td>
			<td><%=fb.decBox("montoProc"+i,c.getMontoProc(),false,false,false,0,11.2,"Text10",null,null)%></td>
			<td><%=fb.checkbox("pagaDifSino"+i,"S",(c.getPagaDifSino() != null && c.getPagaDifSino().equals("S")),false)%></td>
			<td onClick="javascript:showDetail(0,<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la Cobertura"></td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeCob('"+i+"')\"","Eliminar Cobertura")%></td>
		</tr>
		<tr class="TextRow08" id="detail0-<%=i%>" style="display:none">
			<td colspan="7">
				<table width="100%" border="0" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02">
					<td width="30%"><cellbytelabel>Descuento de Cl&iacute;nica</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Pago de Paciente</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Pago de Aseguradora</cellbytelabel></td>
				</tr>
				<tr class="TextRow08">
					<td valign="top">
						<cellbytelabel>Monto</cellbytelabel>
						<%=fb.decBox("montoCli"+i,c.getMontoCli(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValCli"+i,"P=%,M=$",c.getTipoValCli(),false,false,0,"Text10",null,null)%>
					</td>
					<td valign="top" rowspan="2">
						<cellbytelabel>Monto L&iacute;mite a cubrir</cellbytelabel>
						<%=fb.decBox("limiteEvento"+i,c.getLimiteEvento(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.checkbox("aplicarParam"+i,"S",(c.getAplicarParam() != null && c.getAplicarParam().equals("S")),false)%>
						<br>
						<cellbytelabel>Margen</cellbytelabel>
						<%=fb.decBox("montoMargenLimite"+i,c.getMontoMargenLimite(),false,false,false,0,11.2,"Text10",null,null)%>
						<br>
						<cellbytelabel>L&iacute;mite de Proc.(Cantidad)</cellbytelabel>
						<%=fb.intBox("cantidadProc"+i,c.getCantidadProc(),false,false,false,0,3,"Text10",null,null)%>
						<br>
						<cellbytelabel>Monto Paciente</cellbytelabel>
						<%=fb.decBox("montoPac"+i,c.getMontoPac(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValPac"+i,"P=%,M=$",c.getTipoValPac(),false,false,0,"Text10",null,null)%>
					</td>
					<td valign="top" rowspan="2">
						<cellbytelabel>L&iacute;mite  (Monto Emp.)</cellbytelabel>
						<%=fb.decBox("montoEmp"+i,c.getMontoEmp(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValEmp"+i,"P=%,M=$",c.getTipoValEmp(),false,false,0,"Text10",null,null)%>
						<%=fb.select("tipoCobEmp"+i,"D=DIARIO,E=EVENTO",c.getTipoCobEmp(),false,false,0,"Text10",null,null)%>
						<br>
						<cellbytelabel>Excedente</cellbytelabel> 
						<%=fb.decBox("montoEmpExc"+i,c.getMontoEmpExc(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValEmpExc"+i,"P=%,M=$",c.getTipoValEmpExc(),false,false,0,"Text10",null,null)%>
					</td>
				</tr>
				<tr>
<%////if (c.getSecuencia() != null && !c.getSecuencia().equals("0")) {%>
					<td class="TextHeader02" onMouseOver="setoverc(this,'TextHeaderOver')" onMouseOut="setoutc(this,'TextHeader02')" style="cursor:pointer" onClick="javascript:displayDetail(0,'<%=c.getTipoCobertura()%>',<%=c.getSecuencia()%>,<%=i%>)" align="center"><cellbytelabel>A G R E G A R</cellbytelabel> &nbsp; <cellbytelabel>D E T A L L E</cellbytelabel></td>
<%//} else {%>
					<!--<td>&nbsp;</td>-->
<%//}%>
				</tr>
				</table>
			</td>
			<td>&nbsp;</td>
		</tr>
<%
	if (c.getStatus() != null && !c.getStatus().equals("D") && c.getExpanded() != null && c.getExpanded().equals("1"))
	{
%>
						<script language="javascript">showDetail(0,<%=i%>)</script>
<%
	}
}
//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&"+validCob+"<=0){alert('Por favor agregue por lo menos una cobertura para la clasificación del plan!');error++;}");
%>
		</table>
		</div>
		<iframe id="iDetalle0" name="iDetalle0" width="100%" height="0" scrolling="no" frameborder="0" src="../convenio/convenio_cobertura_cendet.jsp?tab=<%=tab%>&cTab=0&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobCDLastLineNo=<%=ceCDLastLineNo%>&index=<%=index%>&change=<%=change%>"></iframe>
	</td>
</tr>
<tr class="TextRow02">
	<td align="right">
		<cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%--<%=fb.radio("saveOption","N")%>Crear Otro--%>
		<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(0,this.value)\"")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextRow02">
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TextRow01">
		<div id="coberturas" style="overflow:scroll; position:static; height:250">
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("tab",tab)%>
		<%=fb.hidden("cTab","1")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("empresa",empresa)%>
		<%=fb.hidden("secuencia",secuencia)%>
		<%=fb.hidden("tipoPoliza",tipoPoliza)%>
		<%=fb.hidden("tipoPlan",tipoPlan)%>
		<%=fb.hidden("planNo",planNo)%>
		<%=fb.hidden("categoriaAdm",categoriaAdm)%>
		<%=fb.hidden("tipoAdm",tipoAdm)%>
		<%=fb.hidden("clasifAdm",clasifAdm)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("cobSize",""+iCob.size())%>
		<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
		<%=fb.hidden("exclSize",""+iExcl.size())%>
		<%=fb.hidden("exclLastLineNo",""+exclLastLineNo)%>
		<%=fb.hidden("defSize",""+iDef.size())%>
		<%=fb.hidden("defLastLineNo",""+defLastLineNo)%>
		<%=fb.hidden("errCode","")%>
		<%=fb.hidden("errMsg","")%>
		<%=fb.hidden("tipoCE","")%>
		<%=fb.hidden("ce","")%>
		<%=fb.hidden("index","")%>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel>No</cellbytelabel>.</td>
			<td width="18%"><cellbytelabel>Exclusi&oacute;n Por</cellbytelabel></td>
			<td width="10%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="63%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="1%">&nbsp;</td>
			<td width="2%"><%=fb.button("addExclusion","+",true,false,null,null,"onClick=\"javascript:addExcl()\"","Agregar Exclusion")%></td>
		</tr>
<%
int validExcl = iExcl.size();
al = CmnMgr.reverseRecords(iExcl);
for (int i=1; i<=iExcl.size(); i++)
{
	key = al.get(i - 1).toString();
	Exclusion e = (Exclusion) iExcl.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayExcl = "";
	if (e.getStatus() != null && e.getStatus().equalsIgnoreCase("D"))
	{
		displayExcl = " style=\"display:none\"";
		validExcl--;
	}
%>
		<%=fb.hidden("key"+i,e.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("status"+i,e.getStatus())%>
		<%=fb.hidden("expanded"+i,e.getExpanded())%>
		<%=fb.hidden("tipoServicio"+i,e.getTipoServicio())%>
		<%=fb.hidden("centroServicio"+i,e.getCentroServicio())%>
		<%=fb.hidden("tipoCds"+i,e.getTipoCds())%>
		<%=fb.hidden("secuencia"+i,e.getSecuencia())%>
		<tr class="<%=color%>" align="center"<%=displayExcl%>>
			<td><%=e.getSecuencia()%></td>
			<td>
		<%if (e.getSecuencia() != null && !e.getSecuencia().equals("0") || (e.getSecuencia() != null && e.getSecuencia().equals("0") && e.getCodigo() != null && !e.getCodigo().trim().equals(""))) {%>
			<%=fb.hidden("tipoExclusion"+i,e.getTipoExclusion())%>
			<%if(e.getTipoExclusion().equalsIgnoreCase("C")){%>CENTRO DE SERVICIO
			<%}else{%>
			<%if(e.getTipoExclusion().equalsIgnoreCase("D")){%>
			   <cellbytelabel>DIAGNOSTICO</cellbytelabel>
			<%}else{%>
			   <cellbytelabel>TIPO SERVICIO</cellbytelabel>
			<%}}%>
			<%//=(e.getTipoExclusion().equalsIgnoreCase("C"))?"CENTRO DE SERVICIO":(e.getTipoExclusion().equalsIgnoreCase("D"))?"DIAGNOSTICO":"TIPO DE SERVICIO"%>
		<%} else {%>
			<%=fb.select("tipoExclusion"+i,"C=CENTRO DE SERVICIO,T=TIPO DE SERVICIO",e.getTipoExclusion(),false,false,0,"Text10",null,"onChange=\"javascript:clearService(1,"+i+")\"")%>
		<%}%>
			</td>
			<td><%=fb.textBox("codigo"+i,e.getCodigo(),false,false,true,5,"Text10",null,null)%></td>
			<td>
				<%=fb.textBox("descripcion"+i,e.getDescripcion(),false,false,true,60,"Text10",null,null)%>
				<%=(e.getCodigo() != null && !e.getCodigo().trim().equals(""))?"":fb.button("btnService"+i,"...",true,false,null,null,"onClick=\"javascript:showServiceList(1,"+i+")\"")%>
				<%--C H E C K   C O B E R T U R A   N O T E S--%>
			</td>
			<td onClick="javascript:showDetail(1,<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la Exclusion"></td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeExcl('"+i+"')\"","Eliminar Exclusion")%></td>
		</tr>
		<tr class="TextRow08" id="detail1-<%=i%>" style="display:none">
			<td colspan="5">
				<table width="100%" border="0" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02">
					<td width="30%"><cellbytelabel>Descuento de Cl&iacute;nica</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Pago de Paciente</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Pago de Aseguradora</cellbytelabel></td>
				</tr>
				<tr class="TextRow08">
					<td valign="top">
						<cellbytelabel>Monto</cellbytelabel>
						<%=fb.decBox("montoCli"+i,e.getMontoCli(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValCli"+i,"P=%,M=$",e.getTipoValCli(),false,false,0,"Text10",null,null)%>
					</td>
					<td valign="top" rowspan="2">
						<cellbytelabel>Monto</cellbytelabel>
						<%=fb.decBox("montoPac"+i,e.getMontoPac(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValPac"+i,"P=%,M=$",e.getTipoValPac(),false,false,0,"Text10",null,null)%>
						<%=fb.select("tipoCobPac"+i,"D=DIARIO,E=EVENTO",e.getTipoCobPac(),false,false,0,"Text10",null,null)%>
						<br>
						<%=fb.checkbox("pacSolBenef"+i,"S",(e.getPacSolBenef() != null && e.getPacSolBenef().equals("S")),false)%>
						<cellbytelabel>Solicitud de Beneficios</cellbytelabel>
						<br>
						<%=fb.checkbox("noCubierto"+i,"S",(e.getNoCubierto() != null && e.getNoCubierto().equals("S")),false)%>
						<cellbytelabel>Diferencia</cellbytelabel>
					</td>
					<td valign="top" rowspan="2">
						<cellbytelabel>Monto</cellbytelabel>
						<%=fb.decBox("montoEmp"+i,e.getMontoEmp(),false,false,false,0,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValEmp"+i,"P=%,M=$",e.getTipoValEmp(),false,false,0,"Text10",null,null)%>
						<%=fb.select("tipoCobEmp"+i,"D=DIARIO,E=EVENTO",e.getTipoCobEmp(),false,false,0,"Text10",null,null)%>
						<br>
						<%=fb.checkbox("empSolBenef"+i,"S",(e.getEmpSolBenef() != null && e.getEmpSolBenef().equals("S")),false)%>
						<cellbytelabel>Solicitud de Beneficios</cellbytelabel>
						<br>
						<%=fb.checkbox("pagaDif"+i,"S",(e.getPagaDif() != null && e.getPagaDif().equals("S")),false)%>
						<cellbytelabel>Paga Diferencia</cellbytelabel>
					</td>
				</tr>
				<tr>
					<td class="TextHeader02" onMouseOver="setoverc(this,'TextHeaderOver')" onMouseOut="setoutc(this,'TextHeader02')" style="cursor:pointer" onClick="javascript:displayDetail(1,'<%=e.getTipoExclusion()%>',<%=e.getSecuencia()%>,<%=i%>)" align="center"><cellbytelabel>A G R E G A R</cellbytelabel> &nbsp; <cellbytelabel>D E T A L L E</cellbytelabel></td>
				</tr>
				</table>
			</td>
			<td>&nbsp;</td>
		</tr>
<%
	if (e.getStatus() != null && !e.getStatus().equals("D") && e.getExpanded() != null && e.getExpanded().equals("1"))
	{
%>
						<script language="javascript">showDetail(1,<%=i%>)</script>
<%
	}
}
//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&"+validExcl+"<=0){alert('Por favor agregue por lo menos una exclusión para la clasificación del plan!');error++;}");
%>
		</table>
		</div>
		<iframe id="iDetalle1" name="iDetalle1" width="100%" height="0" scrolling="no" frameborder="0" src="../convenio/convenio_exclusion_cendet.jsp?tab=<%=tab%>&cTab=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclCDLastLineNo=<%=ceCDLastLineNo%>&index=<%=index%>&change=<%=change%>"></iframe>
	</td>
</tr>
<tr class="TextRow02">
	<td align="right">
		<cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%--<%=fb.radio("saveOption","N")%>Crear Otro--%>
		<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(1,this.value)\"")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

<!-- TAB1 DIV END HERE-->
</div>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cobSize",""+iCob.size())%>
<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
<%=fb.hidden("exclSize",""+iExcl.size())%>
<%=fb.hidden("exclLastLineNo",""+exclLastLineNo)%>
<%=fb.hidden("defSize",""+iDef.size())%>
<%=fb.hidden("defLastLineNo",""+defLastLineNo)%>
<tr class="TextHeader" align="center">
	<td width="15%"><cellbytelabel>Referencia</cellbytelabel></td>
	<td width="78%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Orden</cellbytelabel></td>
	<td width="2%"><%=fb.submit("addDefinicion","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Definición de Cálculos")%></td>
</tr>
<%
int validDef = iDef.size();
al = CmnMgr.reverseRecords(iDef);
for (int i=1; i<=iDef.size(); i++)
{
	key = al.get(i - 1).toString();
	AplicacionBeneficio ab = (AplicacionBeneficio) iDef.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayDef = "";
	if (ab.getStatus() != null && ab.getStatus().equalsIgnoreCase("D"))
	{
		displayDef = " style=\"display:none\"";
		validDef--;
	}
%>
<%=fb.hidden("key"+i,ab.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,ab.getStatus())%>
<%=fb.hidden("codigo"+i,ab.getCodigo())%>
<%=fb.hidden("descripcion"+i,ab.getDescripcion())%>
<%=fb.hidden("secuencia"+i,ab.getSecuencia())%>
<tr class="<%=color%>"<%=displayDef%>>
	<td align="center"><%=ab.getCodigo()%></td>
	<td><%=ab.getDescripcion()%></td>
	<td align="center"><%=ab.getSecuencia()%></td>
	<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"','"+i+"')\"","Eliminar Definición de Cálculos")%></td>
</tr>
<%
}
//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&"+validDef+"<=0){alert('Por favor agregue por lo menos una definición de cálculo para la clasificación del plan!');error++;}");
%>
<tr class="TextRow02">
	<td colspan="8" align="right">
		<cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%--<%=fb.radio("saveOption","N")%>Crear Otro--%>
		<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.submit("save","Guardar",true,false)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

<!-- TAB2 DIV END HERE-->
</div>




<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Coberturas','Exclusiones'),<%=cTab%>,'100%','');//,'Definición de Cálculos'
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

	String itemRemoved = "";
	ClasificacionPlan cp = new ClasificacionPlan();
	cp.setEmpresa(request.getParameter("empresa"));
	cp.setConvenio(request.getParameter("secuencia"));
	cp.setPlan(request.getParameter("planNo"));
	cp.setCategoriaAdmi(request.getParameter("categoriaAdm"));
	cp.setTipoAdmi(request.getParameter("tipoAdm"));
	cp.setClasifAdmi(request.getParameter("clasifAdm"));

	if (cTab.equals("0") || cTab.equals("1")) //COBERTURAS
	{
		if (!request.getParameter("errCode").equals(""))
		{
			ConvMgr.setErrCode(request.getParameter("errCode"));
			ConvMgr.setErrMsg(request.getParameter("errMsg"));
		}
	}//cTab = 0 or 1
	else if (cTab.equals("2")) //DEFINICION DE CALCULOS
	{
		int defSize = 0;
		if (request.getParameter("defSize") != null) defSize = Integer.parseInt(request.getParameter("defSize"));

		cp.getAplicacionBeneficio().clear();
		for (int i=1; i<=defSize; i++)
		{
			AplicacionBeneficio ab = new AplicacionBeneficio();

			ab.setKey(request.getParameter("key"+i));
			ab.setCodigo(request.getParameter("codigo"+i));
			ab.setDescripcion(request.getParameter("descripcion"+i));
			ab.setSecuencia(request.getParameter("secuencia"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = ab.getKey();
				ab.setStatus("D");//D=Delete action in ConvenioMgr
				vDef.remove(ab.getCodigo());
			}
			else ab.setStatus(request.getParameter("status"+i));

			try
			{
				iDef.put(ab.getKey(),ab);
				cp.addAplicacionBeneficio(ab);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&cobLastLineNo="+cobLastLineNo+"&exclLastLineNo="+exclLastLineNo+"&defLastLineNo="+defLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&cobLastLineNo="+cobLastLineNo+"&exclLastLineNo="+exclLastLineNo+"&defLastLineNo="+defLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConvMgr.saveAplicacionBeneficio(cp);
		ConMgr.clearAppCtx(null);
	}//cTab = 2
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?tab=<%=tab%>&cTab=<%=cTab%>&mode=edit&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCE%>&ce=<%=ce%>&index=<%=index%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>