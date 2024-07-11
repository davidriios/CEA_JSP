<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.ClasificacionPlan"%>
<%@ page import="issi.convenio.Cobertura"%>
<%@ page import="issi.convenio.CoberturaCentro"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iCobCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCob" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCob" scope="session" class="java.util.Vector" />
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
String tipoCobertura = request.getParameter("tipoCobertura");
String cobertura = request.getParameter("cobertura");
String index = request.getParameter("index");
String change = request.getParameter("change");
int cobCDLastLineNo = 0;

if (tab == null) tab = "1";
if (cTab == null) cTab = "0";
if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null || planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");
if (categoriaAdm == null || tipoAdm == null || clasifAdm == null) throw new Exception("La Clasificación del Plan no es válida. Por favor intente nuevamente!");
if (tipoCobertura == null || cobertura == null) throw new Exception("La Cobertura no es válida. Por favor intente nuevamente!");
if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
if (request.getParameter("cobCDLastLineNo") != null) cobCDLastLineNo = Integer.parseInt(request.getParameter("cobCDLastLineNo"));
if (change == null) change = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change.trim().equals(""))
	{
		iCobCD.clear();
		vCobCD.clear();

		if (tipoCobertura.equalsIgnoreCase("C"))
		{
			sql = "select a.convenio, a.empresa, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.cobertura, a.tipo_cobertura as tipoCobertura, a.tipo_servicio as tipoServicio, a.monto_cli as montoCli, a.monto_pac as montoPac, a.monto_emp as montoEmp, a.tipo_val_cli as tipoValCli, a.tipo_val_pac as tipoValPac, a.tipo_val_emp as tipoValEmp, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.centro_servicio as centroServicio, a.monto_lim_emp as montoLimEmp, a.tipo_monto_lim_emp as tipoMontoLimEmp, a.monto_exc_emp as montoExcEmp, a.tipo_monto_exc_emp as tipoMontoExcEmp, a.monto_lim,null as montoLim, b.descripcion as tipoServicioDesc from tbl_adm_cobertura_centro a, tbl_cds_tipo_servicio b where a.tipo_servicio=b.codigo and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" and a.cobertura="+cobertura+" and a.tipo_cobertura='"+tipoCobertura+"'";
			//System.out.println("SQL:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,CoberturaCentro.class);

			cobCDLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CoberturaCentro cc = (CoberturaCentro) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cc.setKey(key);

				try
				{
					iCobCD.put(cc.getKey(), cc);
					vCobCD.add(cc.getTipoServicio());
				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}//for i
		}//CentroServicio
		else if (tipoCobertura.equalsIgnoreCase("T"))
		{
			sql = "select a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.empresa, a.convenio, a.plan, a.secuencia, a.tipo_cobertura as tipoCobertura, a.cobertura, a.tipo_servicio as tipoServicio, a.tipo_honorario as tipoHonorario, a.articulo, a.cod_clase as codClase, a.cod_flia as codFlia, a.compania, a.procedimiento, a.tipo_habitacion as tipoHabitacion, a.sth_compania as sthCompania, a.emp_paga_dif as empPagaDif, a.cod_uso as codUso, a.otros_cargos as otrosCargos, a.cds_producto as cdsProducto, a.almacen, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.cerntro_servicio as cerntroServicio, a.monto_cli as montoCli, a.tipo_monto_cli as tipoMontoCli, a.monto_pac as montoPac, a.tipo_monto_pac as tipoMontoPac, a.monto_emp as montoEmp, a.tipo_monto_emp as tipoMontoEmp, a.monto_lim_emp as montoLimEmp, a.tipo_monto_lim_emp as tipoMontoLimEmp, a.monto_exc_emp as montoExcEmp, a.tipo_monto_exc_emp as tipoMontoExcEmp, a.centro_servicio as centroServicio, a.cant_lim as cantLim, a.precio_habitacion as precioHabitacion, a.codigo_medico as codigoMedico, a.codigo_empresa as codigoEmpresa, b.descripcion as tipoServicioDesc, coalesce(decode(a.cod_flia,null,null,decode(a.cod_clase,null,null,decode(a.articulo,null,null,a.cod_flia||'-'||a.cod_clase||'-'||a.articulo))), a.procedimiento, ''||a.tipo_habitacion, ''||a.cod_uso, ''||a.otros_cargos, a.codigo_medico, ''||a.codigo_empresa) as codigo, coalesce(c.descripcion,d.observacion,d.descripcion,e.descripcion,f.descripcion,g.descripcion,h.nombre_medico,i.nombre) as descripcion from tbl_adm_detalle_cobertura a, tbl_cds_tipo_servicio b, tbl_inv_articulo c, tbl_cds_procedimiento d, (select codigo, compania, descripcion||' - '||to_char(precio,'$9,990.00') as descripcion, precio from tbl_sal_tipo_habitacion where estatus='A') e, tbl_sal_uso f, (select codigo, compania, descripcion from tbl_fac_otros_cargos where activo_inactivo='A') g, (select codigo, primer_nombre||' '||segundo_nombre||' '||decode(apellido_de_casada,null,primer_apellido||' '||segundo_apellido,apellido_de_casada) as nombre_medico from tbl_adm_medico where estado='A') h, (select codigo, nombre from tbl_adm_empresa where tipo_empresa=1) i where a.tipo_servicio=b.codigo(+) and a.articulo=c.cod_articulo(+) and a.cod_clase=c.cod_clase(+) and a.cod_flia=c.cod_flia(+) and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.tipo_habitacion=e.codigo(+) and a.compania=e.compania(+) and a.cod_uso=f.codigo(+) and a.compania=f.compania(+) and a.otros_cargos=g.codigo(+) and a.compania=g.compania(+) and a.codigo_medico=h.codigo(+) and a.codigo_empresa=i.codigo(+) and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" and a.cobertura="+cobertura+" and a.tipo_cobertura='"+tipoCobertura+"'";
			//System.out.println("SQL CENDET:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,CoberturaDetalle.class);

			cobCDLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CoberturaDetalle cd = (CoberturaDetalle) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cd.setKey(key);

				try
				{
					iCobCD.put(cd.getKey(), cd);
					vCobCD.add(cd.getCodigo());
				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}//for i
		}//TipoServicio
	}//change is null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cobertura';

function addCobCD()
{
	setBAction('form0','+');
	parent.form0BlockButtons(true);
	form0BlockButtons(true);
	document.form0.submit();
}

function removeCobCD(k)
{
	var msg='';

	if (document.form0.tipoCobertura.value == 'C')
	{
		var tipoServicio=eval('document.form0.tipoServicio'+k).value;
		if(hasDBData('<%=request.getContextPath()%>','tbl_adm_detalle_cobertura','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_cobertura=\'<%=tipoCobertura%>\' and cobertura=<%=cobertura%> and tipo_servicio=\''+tipoServicio+'\'',''))msg+='\n- Detalles Cobertura';
	}

	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar <%=(tipoCobertura.equalsIgnoreCase("C"))?"la Cobertura por Centro":"el Detalle de la Cobertura"%>?'))
		{
			removeItem('form0',k);
			parent.form0BlockButtons(true);
			form0BlockButtons(true);
			document.form0.submit();
		}
	}
	else alert('<%=(tipoCobertura.equalsIgnoreCase("C"))?"La Cobertura por Centro":"El Detalle de la Cobertura"%> no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
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
	newHeight();
	parent.form0BlockButtons(false);
<%
if (request.getParameter("type") != null)
{
%>
	if (document.form0.tipoCobertura.value == 'C') showTipoServicioList();
	else if (document.form0.tipoCobertura.value == 'T')
	{
		var tipoServicio = parent.document.form0.codigo<%=index%>.value;

		if (tipoServicio == '02' || tipoServicio == '03' || tipoServicio == '08') showArticuloList();
		else if (tipoServicio == '04' || tipoServicio == '05' || tipoServicio == '06' || tipoServicio == '09' || tipoServicio == '10' || tipoServicio == '11' || tipoServicio == '12' || tipoServicio == '13' || tipoServicio == '14') showUsoList();
		else if (tipoServicio == '07') showProcedimientoList();
		else if (tipoServicio == '30') showOtrosCargosList();
		else alert('No aplica!');
	}
<%
}
%>
}

function showTipoServicioList()
{
	var centroServicio = parent.document.form0.centroServicio<%=index%>.value;

	abrir_ventana2('../common/check_tipo_servicio.jsp?fp=convenio_cobertura_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&centroServicio='+centroServicio);
}

function showArticuloList()
{
	var tipoServicio = parent.document.form0.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_articulo.jsp?fp=convenio_cobertura_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function showUsoList()
{
	var tipoServicio = parent.document.form0.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_uso.jsp?fp=convenio_cobertura_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function showProcedimientoList()
{
	var tipoServicio = parent.document.form0.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_procedimiento.jsp?fp=convenio_cobertura_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function showOtrosCargosList()
{
	var tipoServicio = parent.document.form0.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_otroscargos.jsp?fp=convenio_cobertura_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function doSubmit()
{
	if (document.form0.baction.value == '') document.form0.baction.value = parent.document.form0.baction.value;
	document.form0.saveOption.value = parent.document.form0.saveOption.value;
	document.form0.cobSize.value = parent.document.form0.cobSize.value;
	document.form0.cobLastLineNo.value = parent.document.form0.cobLastLineNo.value;
	document.form0.exclSize.value = parent.document.form0.exclSize.value;
	document.form0.exclLastLineNo.value = parent.document.form0.exclLastLineNo.value;
	document.form0.defSize.value = parent.document.form0.defSize.value;
	document.form0.defLastLineNo.value = parent.document.form0.defLastLineNo.value;
<%
for (int i=1; i<=iCob.size(); i++)
{
%>
	document.form0.cKey<%=i%>.value = parent.document.form0.key<%=i%>.value;
	document.form0.cRemove<%=i%>.value = parent.document.form0.remove<%=i%>.value;
	document.form0.cStatus<%=i%>.value = parent.document.form0.status<%=i%>.value;
	document.form0.cExpanded<%=i%>.value = parent.document.form0.expanded<%=i%>.value;
	document.form0.cSecuencia<%=i%>.value = parent.document.form0.secuencia<%=i%>.value;
	document.form0.cTipoCobertura<%=i%>.value = parent.document.form0.tipoCobertura<%=i%>.value;
	document.form0.cTipoServicio<%=i%>.value = parent.document.form0.tipoServicio<%=i%>.value;
	document.form0.cCentroServicio<%=i%>.value = parent.document.form0.centroServicio<%=i%>.value;
	document.form0.cCodigo<%=i%>.value = parent.document.form0.codigo<%=i%>.value;
	document.form0.cDescripcion<%=i%>.value = parent.document.form0.descripcion<%=i%>.value;
	document.form0.cMontoProc<%=i%>.value = parent.document.form0.montoProc<%=i%>.value;
	document.form0.cPagaDifSino<%=i%>.value = (parent.document.form0.pagaDifSino<%=i%>.checked)?'S':'';
	document.form0.cMontoCli<%=i%>.value = parent.document.form0.montoCli<%=i%>.value;
	document.form0.cTipoValCli<%=i%>.value = parent.document.form0.tipoValCli<%=i%>.value;
	document.form0.cLimiteEvento<%=i%>.value = parent.document.form0.limiteEvento<%=i%>.value;
	document.form0.cAplicarParam<%=i%>.value = (parent.document.form0.aplicarParam<%=i%>.checked)?'S':'';
	document.form0.cMontoMargenLimite<%=i%>.value = parent.document.form0.montoMargenLimite<%=i%>.value;
	document.form0.cCantidadProc<%=i%>.value = parent.document.form0.cantidadProc<%=i%>.value;
	document.form0.cMontoPac<%=i%>.value = parent.document.form0.montoPac<%=i%>.value;
	document.form0.cTipoValPac<%=i%>.value = parent.document.form0.tipoValPac<%=i%>.value;
	document.form0.cMontoEmp<%=i%>.value = parent.document.form0.montoEmp<%=i%>.value;
	document.form0.cTipoValEmp<%=i%>.value = parent.document.form0.tipoValEmp<%=i%>.value;
	document.form0.cTipoCobEmp<%=i%>.value = parent.document.form0.tipoCobEmp<%=i%>.value;
	document.form0.cMontoEmpExc<%=i%>.value = parent.document.form0.montoEmpExc<%=i%>.value;
	document.form0.cTipoValEmpExc<%=i%>.value = parent.document.form0.tipoValEmpExc<%=i%>.value;
<%
}//cobertura
%>

	if (document.form0.baction.value == 'Guardar' && !form0Validation())
	{
		form0BlockButtons(false);
		parent.form0BlockButtons(false);
		return false;
	}

	document.form0.submit();
}

function showModal(k)
{
	var tipoServicio = eval('document.form0.tipoServicio'+k).value;

	if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_centro','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_cobertura=\'<%=tipoCobertura%>\' and cobertura=<%=cobertura%> and tipo_servicio=\''+tipoServicio+'\'',''))
		alert('Por favor guarde los cambios antes de ver los detalles!');
	else
	{
		//parent.showSelectBoxes(false);
		//showSelectBoxes(false);
		parent.showPopWin('../convenio/convenio_cobertura_det.jsp?mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCobertura%>&cobertura=<%=cobertura%>&tipoServicio='+tipoServicio,parent.winWidth*.95,parent.winHeight*.85,null,null,'');
		//parent.window.frames[\'iDetalle0\'].showSelectBoxes(true);parent.showSelectBoxes(true);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
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
<%=fb.hidden("tipoCobertura",tipoCobertura)%>
<%=fb.hidden("cobertura",cobertura)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cobCDSize",""+iCobCD.size())%>
<%=fb.hidden("cobCDLastLineNo",""+cobCDLastLineNo)%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("cobSize","")%>
<%=fb.hidden("cobLastLineNo","")%>
<%=fb.hidden("exclSize","")%>
<%=fb.hidden("exclLastLineNo","")%>
<%=fb.hidden("defSize","")%>
<%=fb.hidden("defLastLineNo","")%>
<%
al = CmnMgr.reverseRecords(iCob);
for (int i=1; i<=iCob.size(); i++)
{
	key = al.get(i - 1).toString();
%>
<%=fb.hidden("cKey"+i,"")%>
<%=fb.hidden("cRemove"+i,"")%>
<%=fb.hidden("cStatus"+i,"")%>
<%=fb.hidden("cExpanded"+i,"")%>
<%=fb.hidden("cSecuencia"+i,"")%>
<%=fb.hidden("cTipoCobertura"+i,"")%>
<%=fb.hidden("cTipoServicio"+i,"")%>
<%=fb.hidden("cCentroServicio"+i,"")%>
<%=fb.hidden("cCodigo"+i,"")%>
<%=fb.hidden("cDescripcion"+i,"")%>
<%=fb.hidden("cMontoProc"+i,"")%>
<%=fb.hidden("cPagaDifSino"+i,"")%>
<%=fb.hidden("cMontoCli"+i,"")%>
<%=fb.hidden("cTipoValCli"+i,"")%>
<%=fb.hidden("cLimiteEvento"+i,"")%>
<%=fb.hidden("cAplicarParam"+i,"")%>
<%=fb.hidden("cMontoMargenLimite"+i,"")%>
<%=fb.hidden("cCantidadProc"+i,"")%>
<%=fb.hidden("cMontoPac"+i,"")%>
<%=fb.hidden("cTipoValPac"+i,"")%>
<%=fb.hidden("cMontoEmp"+i,"")%>
<%=fb.hidden("cTipoValEmp"+i,"")%>
<%=fb.hidden("cTipoCobEmp"+i,"")%>
<%=fb.hidden("cMontoEmpExc"+i,"")%>
<%=fb.hidden("cTipoValEmpExc"+i,"")%>
<%
}//cobertura
%>
<%
if (tipoCobertura.equalsIgnoreCase("C"))
{
%>
<tr class="TextHeader" align="center">
	<td colspan="15"><cellbytelabel>C O B E R T U R A S</cellbytelabel> &nbsp; <cellbytelabel>P O R</cellbytelabel> &nbsp; <cellbytelabel>T I P O</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>S E R V I C I O</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="7%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
	<td width="22%"><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
	<td width="8%"><cellbytelabel>Lim. Paq</cellbytelabel>.</td>
	<td width="8%"><cellbytelabel>Descuento</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Paciente</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Empresa</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%">L&iacute;mite</td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Excedente</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="1%">&nbsp;</td>
	<td width="2%"><%=fb.button("addCobCentro","+",true,false,null,null,"onClick=\"javascript:addCobCD()\"","Agregar Cobertura Centro")%></td>
</tr>
<%
	int validCobCentro = iCobCD.size();
	al = CmnMgr.reverseRecords(iCobCD);
	for (int i=1; i<=iCobCD.size(); i++)
	{
		key = al.get(i - 1).toString();
		CoberturaCentro cc = (CoberturaCentro) iCobCD.get(key);
		String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow01";
		String displayCobCentro = "";
		if (cc.getStatus() != null && cc.getStatus().equalsIgnoreCase("D"))
		{
			displayCobCentro = " style=\"display:none\"";
			validCobCentro--;
		}
%>
<%=fb.hidden("key"+i,cc.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,cc.getStatus())%>
<%=fb.hidden("tipoServicio"+i,cc.getTipoServicio())%>
<%=fb.hidden("tipoServicioDesc"+i,cc.getTipoServicioDesc())%>
<tr class="<%=color%>" align="center"<%=displayCobCentro%>>
	<td><%=cc.getTipoServicio()%></td>
	<td align="left"><%=cc.getTipoServicioDesc()%></td>
	<td><%=fb.decBox("montoLim"+i,cc.getMontoLim(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoCli"+i,cc.getMontoCli(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValCli"+i,"P=%,M=$",cc.getTipoValCli(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoPac"+i,cc.getMontoPac(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValPac"+i,"P=%,M=$",cc.getTipoValPac(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoEmp"+i,cc.getMontoEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValEmp"+i,"P=%,M=$",cc.getTipoValEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoLimEmp"+i,cc.getMontoLimEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMontoLimEmp"+i,"P=%,M=$",cc.getTipoMontoLimEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoExcEmp"+i,cc.getMontoExcEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMontoExcEmp"+i,"P=%,M=$",cc.getTipoMontoExcEmp(),false,false,0,"Text10",null,null)%></td>
	<td onClick="javascript:showModal(<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la Cobertura"></td>
	<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeCobCD('"+i+"')\"","Eliminar Cobertura Centro")%></td>
</tr>
<%
	}
}
else if (tipoCobertura.equalsIgnoreCase("T"))
{
%>
<tr class="TextHeader" align="center">
	<td colspan="4"><cellbytelabel>C O B E R T U R A S</cellbytelabel> &nbsp; <cellbytelabel>P O R</cellbytelabel> &nbsp; <cellbytelabel>T I P O</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>S E R V I C I O</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="18%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
	<td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Cant</cellbytelabel>.</td>
	<td width="2%"><%=fb.button("addCobDetalle","+",true,false,null,null,"onClick=\"javascript:addCobCD()\"","Agregar Cobertura Detalle")%></td>
</tr>
<%
	int validCobDetalle = iCobCD.size();
	al = CmnMgr.reverseRecords(iCobCD);
	for (int i=1; i<=iCobCD.size(); i++)
	{
		key = al.get(i - 1).toString();
		CoberturaDetalle cd = (CoberturaDetalle) iCobCD.get(key);
		String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow01";
		String displayCobDetalle = "";
		if (cd.getStatus() != null && cd.getStatus().equalsIgnoreCase("D"))
		{
			displayCobDetalle = " style=\"display:none\"";
			validCobDetalle--;
		}
%>
<%=fb.hidden("key"+i,cd.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,cd.getStatus())%>
<%=fb.hidden("secuencia"+i,cd.getSecuencia())%>
<%=fb.hidden("articulo"+i,cd.getArticulo())%>
<%=fb.hidden("codClase"+i,cd.getCodClase())%>
<%=fb.hidden("codFlia"+i,cd.getCodFlia())%>
<%=fb.hidden("compania"+i,cd.getCompania())%>
<%=fb.hidden("procedimiento"+i,cd.getProcedimiento())%>
<%=fb.hidden("tipoHabitacion"+i,cd.getTipoHabitacion())%>
<%=fb.hidden("sthCompania"+i,cd.getSthCompania())%>
<%=fb.hidden("codUso"+i,cd.getCodUso())%>
<%=fb.hidden("otrosCargos"+i,cd.getOtrosCargos())%>
<%=fb.hidden("precioHabitacion"+i,cd.getPrecioHabitacion())%>
<%=fb.hidden("codigoMedico"+i,cd.getCodigoMedico())%>
<%=fb.hidden("codigoEmpresa"+i,cd.getCodigoEmpresa())%>
<%=fb.hidden("codigo"+i,cd.getCodigo())%></td>
<%=fb.hidden("descripcion"+i,cd.getDescripcion())%></td>
<tr class="<%=color%>" align="center"<%=displayCobDetalle%>>
	<td><%=cd.getCodigo()%></td>
	<td align="left"><%=cd.getDescripcion()%></td>
	<td><%=fb.intBox("cantLim"+i,cd.getCantLim(),false,false,false,3,3,"Text10",null,null)%></td>
	<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeCobCD('"+i+"')\"","Eliminar Cobertura Detalle")%></td>
</tr>
<%
	}
}
%>
<%=fb.formEnd(true)%>
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
	int cobLastLineNo = 0;
	int exclLastLineNo = 0;
	int defLastLineNo = 0;
	if (request.getParameter("cobLastLineNo") != null && !request.getParameter("cobLastLineNo").equals("")) cobLastLineNo = Integer.parseInt(request.getParameter("cobLastLineNo"));
	if (request.getParameter("exclLastLineNo") != null && !request.getParameter("exclLastLineNo").equals("")) exclLastLineNo = Integer.parseInt(request.getParameter("exclLastLineNo"));
	if (request.getParameter("defLastLineNo") != null && !request.getParameter("defLastLineNo").equals("")) defLastLineNo = Integer.parseInt(request.getParameter("defLastLineNo"));

	ClasificacionPlan cp = new ClasificacionPlan();
	cp.setEmpresa(request.getParameter("empresa"));
	cp.setConvenio(request.getParameter("secuencia"));
	cp.setPlan(request.getParameter("planNo"));
	cp.setCategoriaAdmi(request.getParameter("categoriaAdm"));
	cp.setTipoAdmi(request.getParameter("tipoAdm"));
	cp.setClasifAdmi(request.getParameter("clasifAdm"));

	if (cTab.equals("0")) //COBERTURAS
	{
		int cobSize = 0;
		if (request.getParameter("cobSize") != null)
		{
			if (request.getParameter("cobSize").trim().equals(""))//action coming from iframe and not from parent, because iframe.doSubmit() set this value
			{
				int cobCDSize = 0;
				if (request.getParameter("cobCDSize") != null) cobCDSize = Integer.parseInt(request.getParameter("cobCDSize"));

				if (request.getParameter("tipoCobertura").equalsIgnoreCase("C"))
				{
					for (int i=1; i<=cobCDSize; i++)
					{
						CoberturaCentro cc = new CoberturaCentro();

						cc.setKey(request.getParameter("key"+i));
						cc.setTipoServicio(request.getParameter("tipoServicio"+i));
						cc.setTipoServicioDesc(request.getParameter("tipoServicioDesc"+i));
						cc.setMontoLim(request.getParameter("montoLim"+i));
						cc.setMontoCli(request.getParameter("montoCli"+i));
						cc.setTipoValCli(request.getParameter("tipoValCli"+i));
						cc.setMontoPac(request.getParameter("montoPac"+i));
						cc.setTipoValPac(request.getParameter("tipoValPac"+i));
						cc.setMontoEmp(request.getParameter("montoEmp"+i));
						cc.setTipoValEmp(request.getParameter("tipoValEmp"+i));
						cc.setMontoLimEmp(request.getParameter("montoLimEmp"+i));
						cc.setTipoMontoLimEmp(request.getParameter("tipoMontoLimEmp"+i));
						cc.setMontoExcEmp(request.getParameter("montoExcEmp"+i));
						cc.setTipoMontoExcEmp(request.getParameter("tipoMontoExcEmp"+i));

						if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
						{
							itemRemoved = cc.getKey();
							cc.setStatus("D");//D=Delete action in ConvenioMgr
							vCobCD.remove(cc.getTipoServicio());
						}
						else cc.setStatus(request.getParameter("status"+i));

						try
						{
							iCobCD.put(cc.getKey(),cc);
						}
						catch(Exception ex)
						{
							System.err.println(ex.getMessage());
						}
					}//for CoberturaCentro
				}//CoberturaCentro
				else if (request.getParameter("tipoCobertura").equalsIgnoreCase("T"))
				{
					for (int i=1; i<=cobCDSize; i++)
					{
						CoberturaDetalle cd = new CoberturaDetalle();

						cd.setKey(request.getParameter("key"+i));
						cd.setSecuencia(request.getParameter("secuencia"+i));
						cd.setArticulo(request.getParameter("articulo"+i));
						cd.setCodClase(request.getParameter("codClase"+i));
						cd.setCodFlia(request.getParameter("codFlia"+i));
						cd.setCompania(request.getParameter("compania"+i));
						cd.setProcedimiento(request.getParameter("procedimiento"+i));
						cd.setTipoHabitacion(request.getParameter("tipoHabitacion"+i));
						cd.setSthCompania(request.getParameter("sthCompania"+i));
						cd.setCodUso(request.getParameter("codUso"+i));
						cd.setOtrosCargos(request.getParameter("otrosCargos"+i));
						cd.setPrecioHabitacion(request.getParameter("precioHabitacion"+i));
						cd.setCodigoMedico(request.getParameter("codigoMedico"+i));
						cd.setCodigoEmpresa(request.getParameter("codigoEmpresa"+i));
						cd.setCodigo(request.getParameter("codigo"+i));
						cd.setDescripcion(request.getParameter("descripcion"+i));
						cd.setCantLim(request.getParameter("cantLim"+i));

						if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
						{
							itemRemoved = cd.getKey();
							cd.setStatus("D");//D=Delete action in ConvenioMgr
							vCobCD.add(cd.getCodigo());
						}
						else cd.setStatus(request.getParameter("status"+i));

						try
						{
							iCobCD.put(cd.getKey(),cd);
						}
						catch(Exception ex)
						{
							System.err.println(ex.getMessage());
						}
					}//for CoberturaDetalle
				}//CoberturaDetalle

				if (!itemRemoved.equals(""))
				{
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&index="+index+"&cobCDLastLineNo="+cobCDLastLineNo);
					return;
				}

				if (baction != null && baction.equals("+"))
				{
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&index="+index+"&cobCDLastLineNo="+cobCDLastLineNo);
					return;
				}
			}//cobSize == ""
			else
			{
				cobSize = Integer.parseInt(request.getParameter("cobSize"));

				cp.getCobertura().clear();
				for (int i=1; i<=cobSize; i++)
				{
					Cobertura c = new Cobertura();

					c.setKey(request.getParameter("cKey"+i));
					c.setExpanded(request.getParameter("cExpanded"+i));
					c.setSecuencia(request.getParameter("cSecuencia"+i));
					c.setTipoCobertura(request.getParameter("cTipoCobertura"+i));
					c.setTipoServicio(request.getParameter("cTipoServicio"+i));
					c.setCentroServicio(request.getParameter("cCentroServicio"+i));
					c.setCodigo(request.getParameter("cCodigo"+i));
					c.setDescripcion(request.getParameter("cDescripcion"+i));
					c.setMontoProc(request.getParameter("cMontoProc"+i));
					c.setPagaDifSino(request.getParameter("cPagaDifSino"+i));
					c.setMontoCli(request.getParameter("cMontoCli"+i));
					c.setTipoValCli(request.getParameter("cTipoValCli"+i));
					c.setLimiteEvento(request.getParameter("cLimiteEvento"+i));
					c.setAplicarParam(request.getParameter("cAplicarParam"+i));
					c.setMontoMargenLimite(request.getParameter("cMontoMargenLimite"+i));
					c.setCantidadProc(request.getParameter("cCantidadProc"+i));
					c.setMontoPac(request.getParameter("cMontoPac"+i));
					c.setTipoValPac(request.getParameter("cTipoValPac"+i));
					c.setMontoEmp(request.getParameter("cMontoEmp"+i));
					c.setTipoValEmp(request.getParameter("cTipoValEmp"+i));
					c.setTipoCobEmp(request.getParameter("cTipoCobEmp"+i));
					c.setMontoEmpExc(request.getParameter("cMontoEmpExc"+i));
					c.setTipoValEmpExc(request.getParameter("cTipoValEmpExc"+i));
					c.setExpanded(request.getParameter("cExpanded"+i));

					if (request.getParameter("cRemove"+i) != null && !request.getParameter("cRemove"+i).equals(""))
					{
						itemRemoved = c.getKey();
						c.setStatus("D");//D=Delete action in ConvenioMgr
						vCob.remove(c.getTipoCobertura()+((c.getCentroServicio() == null)?"":c.getCentroServicio())+((c.getTipoServicio() == null)?"":c.getTipoServicio()));
					}
					else c.setStatus(request.getParameter("cStatus"+i));

					if (c.getStatus() != null && !c.getStatus().equalsIgnoreCase("D") && c.getTipoCobertura().equalsIgnoreCase(request.getParameter("tipoCobertura")) && c.getSecuencia().equalsIgnoreCase(request.getParameter("cobertura")))
					{
						int cobCDSize = 0;
						if (request.getParameter("cobCDSize") != null) cobCDSize = Integer.parseInt(request.getParameter("cobCDSize"));

						if (c.getTipoCobertura().equalsIgnoreCase("C"))
						{
							c.getCoberturaCentro().clear();
							for (int j=1; j<=cobCDSize; j++)
							{
								CoberturaCentro cc = new CoberturaCentro();

								cc.setKey(request.getParameter("key"+j));
								cc.setTipoServicio(request.getParameter("tipoServicio"+j));
								cc.setTipoServicioDesc(request.getParameter("tipoServicioDesc"+j));
								cc.setMontoLim(request.getParameter("montoLim"+j));
								cc.setMontoCli(request.getParameter("montoCli"+j));
								cc.setTipoValCli(request.getParameter("tipoValCli"+j));
								cc.setMontoPac(request.getParameter("montoPac"+j));
								cc.setTipoValPac(request.getParameter("tipoValPac"+j));
								cc.setMontoEmp(request.getParameter("montoEmp"+j));
								cc.setTipoValEmp(request.getParameter("tipoValEmp"+j));
								cc.setMontoLimEmp(request.getParameter("montoLimEmp"+j));
								cc.setTipoMontoLimEmp(request.getParameter("tipoMontoLimEmp"+j));
								cc.setMontoExcEmp(request.getParameter("montoExcEmp"+j));
								cc.setTipoMontoExcEmp(request.getParameter("tipoMontoExcEmp"+j));
								cc.setStatus(request.getParameter("status"+j));
								cc.setUsuarioCreacion((String) session.getAttribute("_userName"));
								cc.setUsuarioModificacion((String) session.getAttribute("_userName"));

								try
								{
									iCobCD.put(cc.getKey(),cc);
									c.addCoberturaCentro(cc);
								}
								catch(Exception ex)
								{
									System.err.println(ex.getMessage());
								}
							}//for CoberturaCentro
						}//CoberturaCentro
						else if (c.getTipoCobertura().equalsIgnoreCase("T"))
						{
							c.getCoberturaDetalle().clear();
							for (int j=1; j<=cobCDSize; j++)
							{
								CoberturaDetalle cd = new CoberturaDetalle();

								cd.setKey(request.getParameter("key"+j));
								cd.setSecuencia(request.getParameter("secuencia"+j));
								cd.setArticulo(request.getParameter("articulo"+j));
								cd.setCodClase(request.getParameter("codClase"+j));
								cd.setCodFlia(request.getParameter("codFlia"+j));
								cd.setCompania(request.getParameter("compania"+j));
								cd.setProcedimiento(request.getParameter("procedimiento"+j));
								cd.setTipoHabitacion(request.getParameter("tipoHabitacion"+j));
								cd.setSthCompania(request.getParameter("sthCompania"+j));
								cd.setCodUso(request.getParameter("codUso"+j));
								cd.setOtrosCargos(request.getParameter("otrosCargos"+j));
								cd.setPrecioHabitacion(request.getParameter("precioHabitacion"+j));
								cd.setCodigoMedico(request.getParameter("codigoMedico"+j));
								cd.setCodigoEmpresa(request.getParameter("codigoEmpresa"+j));
								cd.setCodigo(request.getParameter("codigo"+j));
								cd.setDescripcion(request.getParameter("descripcion"+j));
								cd.setCantLim(request.getParameter("cantLim"+j));
								cd.setStatus(request.getParameter("status"+j));
								cd.setUsuarioCreacion((String) session.getAttribute("_userName"));
								cd.setUsuarioModificacion((String) session.getAttribute("_userName"));

								try
								{
									iCobCD.put(cd.getKey(),cd);
									c.addCoberturaDetalle(cd);
								}
								catch(Exception ex)
								{
									System.err.println(ex.getMessage());
								}
							}//for CoberturaDetalle
						}//CoberturaDetalle
					}//detail belongs to Cobertura

					try
					{
						iCob.put(c.getKey(),c);
						cp.addCobertura(c);
						key = c.getTipoCobertura()+((c.getCentroServicio() == null)?"":c.getCentroServicio())+((c.getTipoServicio() == null)?"":c.getTipoServicio());
						if (!c.getStatus().equalsIgnoreCase("D") && !key.equalsIgnoreCase("C") && !key.equalsIgnoreCase("T") && !vCob.contains(key))
							vCob.add(key);
					}
					catch(Exception ex)
					{
						System.err.println(ex.getMessage());
					}
				}//for Cobertura
			}//cobSize != ""
		}//cobSize != null

		if (baction != null && baction.equals("+"))
		{
			Cobertura c = new Cobertura();

			cobLastLineNo++;
			if (cobLastLineNo < 10) key = "00" + cobLastLineNo;
			else if (cobLastLineNo < 100) key = "0" + cobLastLineNo;
			else key = "" + cobLastLineNo;
			c.setKey(key);

			c.setSecuencia("0");

			try
			{
				iCob.put(c.getKey(),c);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}

		if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConvMgr.saveCobertura(cp);
			ConMgr.clearAppCtx(null);
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (baction != null && baction.equals("+"))
	{
%>
	parent.location = '../convenio/convenio_clasif.jsp?change=1&type=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&index=<%=index%>&cobLastLineNo=<%=cobLastLineNo%>&exclLastLineNo=<%=exclLastLineNo%>&defLastLineNo=<%=defLastLineNo%>';
<%
	}
	else if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
%>
	parent.document.form0.errCode.value='<%=ConvMgr.getErrCode()%>';
	parent.document.form0.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(ConvMgr.getErrMsg())%>';
	parent.document.form0.tipoCE.value='<%=tipoCobertura%>';
	parent.document.form0.ce.value='<%=cobertura%>';
	parent.document.form0.index.value='<%=index%>';
	parent.document.form0.submit();
<%
	}
	else
	{
%>
	parent.location = '../convenio/convenio_clasif.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&index=<%=index%>&cobLastLineNo=<%=request.getParameter("cobLastLineNo")%>&exclLastLineNo=<%=request.getParameter("exclLastLineNo")%>&defLastLineNo=<%=request.getParameter("defLastLineNo")%>';
<%
	}
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