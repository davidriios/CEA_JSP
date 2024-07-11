<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.ClasificacionPlan"%>
<%@ page import="issi.convenio.Exclusion"%>
<%@ page import="issi.convenio.ExclusionCentro"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iExclCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExcl" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExcl" scope="session" class="java.util.Vector" />
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
String tipoExclusion = request.getParameter("tipoExclusion");
String exclusion = request.getParameter("exclusion");
String index = request.getParameter("index");
String change = request.getParameter("change");
int exclCDLastLineNo = 0;
boolean viewMode = false;

if (tab == null) tab = "1";
if (cTab == null) cTab = "1";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view"))viewMode = true;

if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null || planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");
if (categoriaAdm == null || tipoAdm == null || clasifAdm == null) throw new Exception("La Clasificación del Plan no es válida. Por favor intente nuevamente!");
if (tipoExclusion == null || exclusion == null) throw new Exception("La Exclusión no es válida. Por favor intente nuevamente!");
if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
if (request.getParameter("exclCDLastLineNo") != null) exclCDLastLineNo = Integer.parseInt(request.getParameter("exclCDLastLineNo"));
if (change == null) change = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change.trim().equals(""))
	{
		iExclCD.clear();
		vExclCD.clear();

		if (tipoExclusion.equalsIgnoreCase("C"))
		{
			sql = "select a.convenio, a.empresa, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.exclusion, a.tipo_servicio as tipoServicio, a.tipo_exclusion as tipoExclusion, a.monto_cli as montoCli, a.monto_pac as montoPac, a.monto_emp as montoEmp, a.tipo_val_cli as tipoValCli, a.tipo_val_pac as tipoValPac, a.tipo_val_emp as tipoValEmp, a.pac_sol_benef as pacSolBenef, a.emp_sol_benef as empSolBenef, a.centro_servicio as centroServicio, a.inventario_sino as inventarioSino, a.no_cubierto as noCubierto, b.descripcion as tipoServicioDesc from tbl_adm_exclusion_centro a, tbl_cds_tipo_servicio b where a.tipo_servicio=b.codigo and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" and a.exclusion="+exclusion+" and a.tipo_exclusion='"+tipoExclusion+"'";
			//System.out.println("SQL:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,ExclusionCentro.class);

			exclCDLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				ExclusionCentro ec = (ExclusionCentro) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				ec.setKey(key);

				try
				{
					iExclCD.put(ec.getKey(), ec);
					vExclCD.add(ec.getTipoServicio());
				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}//for i
		}//CentroServicio
		else if (tipoExclusion.equalsIgnoreCase("T"))
		{
			sql = "select a.convenio, a.empresa, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.secuencia, a.monto_cli as montoCli, a.monto_emp as montoEmp, a.monto_pac as montoPac, a.tipo_val_cli as tipoValCli, a.tipo_val_emp as tipoValEmp, a.tipo_val_pac as tipoValPac, a.tipo_cob_emp as tipoCobEmp, a.tipo_cob_pac as tipoCobPac, a.tipo_exclusion as tipoExclusion, a.exclusion, a.tipo_servicio as tipoServicio, a.procedimiento, a.articulo, a.cod_clase as codClase, a.cod_flia as codFlia, a.compania, a.tipo_habitacion as tipoHabitacion, a.tipo_honorario as tipoHonorario, a.emp_paga_dif as empPagaDif, a.cod_uso as codUso, a.otros_cargos as otrosCargos, a.cds_producto as cdsProducto, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.emp_sol_benef as empSolBenef, a.pac_sol_benef as pacSolBenef, a.centro_servicio as centroServicio, a.pac_sol_benef_det as pacSolBenefDet, a.codigo_medico as codigoMedico, a.codigo_empresa as codigoEmpresa, a.no_cubierto as noCubierto, a.precio_habitacion as precioHabitacion, coalesce(a.procedimiento,decode(a.cod_flia,null,null,decode(a.cod_clase,null,null,decode(a.articulo,null,null,a.cod_flia||'-'||a.cod_clase||'-'||a.articulo))), ''||a.tipo_habitacion, ''||a.cod_uso, ''||a.otros_cargos, ''||a.cds_producto, a.codigo_medico, ''||a.codigo_empresa) as codigo, coalesce(c.descripcion,d.observacion,d.descripcion,e.descripcion,f.descripcion,g.descripcion) as descripcion from tbl_adm_detalle_exclusion a, tbl_cds_tipo_servicio b, tbl_inv_articulo c, tbl_cds_procedimiento d, (select codigo, compania, descripcion||' - '||to_char(precio,'$9,990.00') as descripcion, precio from tbl_sal_tipo_habitacion where estatus='A') e, tbl_sal_uso f, (select codigo, compania, descripcion from tbl_fac_otros_cargos where activo_inactivo='A') g where a.tipo_servicio=b.codigo(+) and a.articulo=c.cod_articulo(+) and a.cod_clase=c.cod_clase(+) and a.cod_flia=c.cod_flia(+) and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.tipo_habitacion=e.codigo(+) and a.compania=e.compania(+) and a.cod_uso=f.codigo(+) and a.compania=f.compania(+) and a.otros_cargos=g.codigo(+) and a.compania=g.compania(+) and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" and a.exclusion="+exclusion+" and a.tipo_exclusion='"+tipoExclusion+"'";
			//System.out.println("SQL:\n"+sql);
			al = sbb.getBeanList(ConMgr.getConnection(),sql,ExclusionDetalle.class);

			exclCDLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				ExclusionDetalle ed = (ExclusionDetalle) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				ed.setKey(key);

				try
				{
					iExclCD.put(ed.getKey(), ed);
					vExclCD.add(ed.getCodigo());
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
document.title = 'Exclusión';

function addExclCD()
{
	setBAction('form1','+');
	parent.form1BlockButtons(true);
	form1BlockButtons(true);
	document.form1.submit();
}

function removeExclCD(k)
{
	var msg='';

	if (document.form1.tipoExclusion.value == 'C')
	{
		var tipoServicio=eval('document.form1.tipoServicio'+k).value;
		if(hasDBData('<%=request.getContextPath()%>','tbl_adm_detalle_exclusion','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_exclusion=\'<%=tipoExclusion%>\' and exclusion=<%=exclusion%> and tipo_servicio=\''+tipoServicio+'\'',''))msg+='\n- Detalles Exclusión';
	}

	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar <%=(tipoExclusion.equalsIgnoreCase("C"))?"la Exclusión por Centro":"el Detalle de la Exclusión"%>?'))
		{
			removeItem('form1',k);
			parent.form1BlockButtons(true);
			form1BlockButtons(true);
			document.form1.submit();
		}
	}
	else alert('<%=(tipoExclusion.equalsIgnoreCase("C"))?"La Exclusión por Centro":"El Detalle de la Exclusión"%> no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
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
	<%if (!viewMode){%>
	parent.form1BlockButtons(false);
<%}
if (request.getParameter("type") != null)
{
%>
	if (document.form1.tipoExclusion.value == 'C') showTipoServicioList();
	else if (document.form1.tipoExclusion.value == 'T')
	{
		var tipoServicio = parent.document.form1.codigo<%=index%>.value;

		if (tipoServicio == '02' || tipoServicio == '03' || tipoServicio == '08') showArticuloList();
		else if (tipoServicio == '04' || tipoServicio == '05' || tipoServicio == '06' || tipoServicio == '09' || tipoServicio == '10' || tipoServicio == '11' || tipoServicio == '12' || tipoServicio == '13' || tipoServicio == '14') showUsoList();
		else if (tipoServicio == '07') showProcedimientoList();
		else if (tipoServicio == '30') showOtrosCargosList();
		else alert('No Aplica!');
	}
<%
}
%>
}

function showTipoServicioList()
{
	var centroServicio = parent.document.form1.centroServicio<%=index%>.value;

	abrir_ventana2('../common/check_tipo_servicio.jsp?fp=pm_convenio_exclusion_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&index=<%=index%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&centroServicio='+centroServicio);
}

function showArticuloList()
{
	var tipoServicio = parent.document.form1.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_articulo.jsp?fp=convenio_exclusion_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&index=<%=index%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function showUsoList()
{
	var tipoServicio = parent.document.form1.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_uso.jsp?fp=convenio_exclusion_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&index=<%=index%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function showProcedimientoList()
{
	var tipoServicio = parent.document.form1.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_procedimiento.jsp?fp=convenio_exclusion_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&index=<%=index%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function showOtrosCargosList()
{
	var tipoServicio = parent.document.form1.tipoServicio<%=index%>.value;

	abrir_ventana2('../common/check_otroscargos.jsp?fp=convenio_cobertura_centro&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&index=<%=index%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&tipoServicio='+tipoServicio);
}

function doSubmit()
{
	if (document.form1.baction.value == '') document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.saveOption.value = parent.document.form1.saveOption.value;
	document.form1.cobSize.value = parent.document.form1.cobSize.value;
	document.form1.cobLastLineNo.value = parent.document.form1.cobLastLineNo.value;
	document.form1.exclSize.value = parent.document.form1.exclSize.value;
	document.form1.exclLastLineNo.value = parent.document.form1.exclLastLineNo.value;
	document.form1.defSize.value = parent.document.form1.defSize.value;
	document.form1.defLastLineNo.value = parent.document.form1.defLastLineNo.value;
<%
for (int i=1; i<=iExcl.size(); i++)
{
%>
	document.form1.cKey<%=i%>.value = parent.document.form1.key<%=i%>.value;
	document.form1.cRemove<%=i%>.value = parent.document.form1.remove<%=i%>.value;
	document.form1.cStatus<%=i%>.value = parent.document.form1.status<%=i%>.value;
	document.form1.cExpanded<%=i%>.value = parent.document.form1.expanded<%=i%>.value;
	document.form1.cSecuencia<%=i%>.value = parent.document.form1.secuencia<%=i%>.value;
	document.form1.cTipoExclusion<%=i%>.value = parent.document.form1.tipoExclusion<%=i%>.value;
	document.form1.cTipoServicio<%=i%>.value = parent.document.form1.tipoServicio<%=i%>.value;
	document.form1.cCentroServicio<%=i%>.value = parent.document.form1.centroServicio<%=i%>.value;
	document.form1.cTipoCds<%=i%>.value = parent.document.form1.tipoCds<%=i%>.value;
	document.form1.cCodigo<%=i%>.value = parent.document.form1.codigo<%=i%>.value;
	document.form1.cDescripcion<%=i%>.value = parent.document.form1.descripcion<%=i%>.value;
	document.form1.cMontoCli<%=i%>.value = parent.document.form1.montoCli<%=i%>.value;
	document.form1.cTipoValCli<%=i%>.value = parent.document.form1.tipoValCli<%=i%>.value;
	document.form1.cMontoPac<%=i%>.value = parent.document.form1.montoPac<%=i%>.value;
	document.form1.cTipoValPac<%=i%>.value = parent.document.form1.tipoValPac<%=i%>.value;
	document.form1.cTipoCobPac<%=i%>.value = parent.document.form1.tipoCobPac<%=i%>.value;
	document.form1.cPacSolBenef<%=i%>.value = (parent.document.form1.pacSolBenef<%=i%>.checked)?'S':'';
	document.form1.cNoCubierto<%=i%>.value = (parent.document.form1.noCubierto<%=i%>.checked)?'S':'';
	document.form1.cMontoEmp<%=i%>.value = parent.document.form1.montoEmp<%=i%>.value;
	document.form1.cTipoValEmp<%=i%>.value = parent.document.form1.tipoValEmp<%=i%>.value;
	document.form1.cTipoCobEmp<%=i%>.value = parent.document.form1.tipoCobEmp<%=i%>.value;
	document.form1.cEmpSolBenef<%=i%>.value = (parent.document.form1.empSolBenef<%=i%>.checked)?'S':'';
	document.form1.cPagaDif<%=i%>.value = (parent.document.form1.pagaDif<%=i%>.checked)?'S':'';
<%
}//exclusion
%>

	if (document.form1.baction.value == 'Guardar' && !form1Validation())
	{
		form1BlockButtons(false);
		parent.form1BlockButtons(false);
		return false;
	}

	document.form1.submit();
}

function showModal(k)
{
	var tipoServicio = eval('document.form1.tipoServicio'+k).value;
	var inventarioSino = eval('document.form1.inventarioSino'+k).checked?'S':'N';

	if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_exclusion_centro','empresa=<%=empresa%> and convenio=<%=secuencia%> and plan=<%=planNo%> and categoria_admi=<%=categoriaAdm%> and tipo_admi=<%=tipoAdm%> and clasif_admi=<%=clasifAdm%> and tipo_exclusion=\'<%=tipoExclusion%>\' and exclusion=<%=exclusion%> and tipo_servicio=\''+tipoServicio+'\'',''))
		alert('Por favor guarde los cambios antes de ver los detalles!');
	else
	{
		var centroServicio = parent.document.form1.centroServicio<%=index%>.value;
		var tipoCds = parent.document.form1.tipoCds<%=index%>.value;
		//parent.showSelectBoxes(false);
		//showSelectBoxes(false);
		parent.showPopWin('../planmedico/pm_convenio_exclusion_det.jsp?mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoExclusion%>&exclusion=<%=exclusion%>&tipoServicio='+tipoServicio+'&centroServicio='+centroServicio+'&tipoCds='+tipoCds+'&inventarioSino='+inventarioSino,parent.winWidth*.95,parent.winHeight*.85,null,null,'');
		//parent.window.frames[\'iDetalle1\'].showSelectBoxes(true);parent.showSelectBoxes(true);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
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
<%=fb.hidden("tipoExclusion",tipoExclusion)%>
<%=fb.hidden("exclusion",exclusion)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("exclCDSize",""+iExclCD.size())%>
<%=fb.hidden("exclCDLastLineNo",""+exclCDLastLineNo)%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("cobSize","")%>
<%=fb.hidden("cobLastLineNo","")%>
<%=fb.hidden("exclSize","")%>
<%=fb.hidden("exclLastLineNo","")%>
<%=fb.hidden("defSize","")%>
<%=fb.hidden("defLastLineNo","")%>
<%
al = CmnMgr.reverseRecords(iExcl);
for (int i=1; i<=iExcl.size(); i++)
{
	key = al.get(i - 1).toString();
%>
<%=fb.hidden("cKey"+i,"")%>
<%=fb.hidden("cRemove"+i,"")%>
<%=fb.hidden("cStatus"+i,"")%>
<%=fb.hidden("cExpanded"+i,"")%>
<%=fb.hidden("cSecuencia"+i,"")%>
<%=fb.hidden("cTipoExclusion"+i,"")%>
<%=fb.hidden("cTipoServicio"+i,"")%>
<%=fb.hidden("cCentroServicio"+i,"")%>
<%=fb.hidden("cTipoCds"+i,"")%>
<%=fb.hidden("cCodigo"+i,"")%>
<%=fb.hidden("cDescripcion"+i,"")%>
<%=fb.hidden("cMontoCli"+i,"")%>
<%=fb.hidden("cTipoValCli"+i,"")%>
<%=fb.hidden("cMontoPac"+i,"")%>
<%=fb.hidden("cTipoValPac"+i,"")%>
<%=fb.hidden("cTipoCobPac"+i,"")%>
<%=fb.hidden("cPacSolBenef"+i,"")%>
<%=fb.hidden("cNoCubierto"+i,"")%>
<%=fb.hidden("cMontoEmp"+i,"")%>
<%=fb.hidden("cTipoValEmp"+i,"")%>
<%=fb.hidden("cTipoCobEmp"+i,"")%>
<%=fb.hidden("cEmpSolBenef"+i,"")%>
<%=fb.hidden("cPagaDif"+i,"")%>
<%
}//exclusion
%>
<%
if (tipoExclusion.equalsIgnoreCase("C"))
{
%>
<tr class="TextHeader" align="center">
	<td colspan="13"><cellbytelabel>E X C L U S I O N E S</cellbytelabel> &nbsp; <cellbytelabel>P O R</cellbytelabel> &nbsp; <cellbytelabel>T I P O</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>S E R V I C I O</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="8%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
	<td width="41%"><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Descuento</cellbytelabel></td>
	<td width="5%">%-$</td>
	<td width="10%"><cellbytelabel>Paciente</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Sol</cellbytelabel>.</td>
	<td width="4%"><cellbytelabel>Dif</cellbytelabel>.</td>
	<td width="5%">%-$</td>
	<!--<td width="10%"><cellbytelabel>Empresa</cellbytelabel></td>
	<td width="5%">%-$</td>-->
	<td width="10%"><cellbytelabel>Insumo de Inventario</cellbytelabel></td>
	<td width="1%">&nbsp;</td>
	<td width="2%"><%=fb.button("addExclCentro","+",true,viewMode,null,null,"onClick=\"javascript:addExclCD()\"","Agregar Exclusión Centro")%></td>
</tr>
<%
	int validExclCentro = iExclCD.size();
	al = CmnMgr.reverseRecords(iExclCD);
	for (int i=1; i<=iExclCD.size(); i++)
	{
		key = al.get(i - 1).toString();
		ExclusionCentro ec = (ExclusionCentro) iExclCD.get(key);
		String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow01";
		String displayExclCentro = "";
		if (ec.getStatus() != null && ec.getStatus().equalsIgnoreCase("D"))
		{
			displayExclCentro = " style=\"display:none\"";
			validExclCentro--;
		}
%>
<%=fb.hidden("key"+i,ec.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,ec.getStatus())%>
<%=fb.hidden("tipoServicio"+i,ec.getTipoServicio())%>
<%=fb.hidden("tipoServicioDesc"+i,ec.getTipoServicioDesc())%>
<tr class="<%=color%>" align="center"<%=displayExclCentro%>>
	<td><%=ec.getTipoServicio()%></td>
	<td align="left"><%=ec.getTipoServicioDesc()%></td>
	<td><%=fb.decBox("montoCli"+i,ec.getMontoCli(),false,false,viewMode,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValCli"+i,"P=%,M=$",ec.getTipoValCli(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoPac"+i,ec.getMontoPac(),false,false,viewMode,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.checkbox("pacSolBenef"+i,"S",(ec.getPacSolBenef() != null && ec.getPacSolBenef().equals("S")),viewMode)%></td>
	<td><%=fb.checkbox("noCubierto"+i,"S",(ec.getNoCubierto() != null && ec.getNoCubierto().equals("S")),viewMode)%></td>
	<td><%=fb.select("tipoValPac"+i,"P=%,M=$",ec.getTipoValPac(),false,viewMode,0,"Text10",null,null)%></td>
	<!--<td><%//=fb.decBox("montoEmp"+i,ec.getMontoEmp(),false,false,viewMode,10,11.2,"Text10",null,null)%></td>
	<td><%//=fb.select("tipoValEmp"+i,"P=%,M=$",ec.getTipoValEmp(),false,viewMode,0,"Text10",null,null)%></td>-->
	<td><%=fb.checkbox("inventarioSino"+i,"S",(ec.getInventarioSino() != null && ec.getInventarioSino().equals("S")),viewMode)%></td>
	<td onClick="javascript:showModal(<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la exclusión"></td>
	<td><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeExclCD('"+i+"')\"","Eliminar Exclusión Centro")%></td>
	<%=fb.hidden("montoEmp"+i,ec.getMontoEmp())%>
	<%=fb.hidden("tipoValEmp"+i,ec.getTipoValEmp())%>
</tr>
<%
	}
}
else if (tipoExclusion.equalsIgnoreCase("T"))
{
%>
<tr class="TextHeader" align="center">
	<td colspan="12"><cellbytelabel>E X C L U S I O N E S</cellbytelabel> &nbsp; <cellbytelabel>P O R</cellbytelabel> &nbsp; <cellbytelabel>T I P O</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>S E R V I C I O</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="10%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
	<td width="26%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="8%"><cellbytelabel>Monto Cl&iacute;nica</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Monto Paciente</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Cobertura</cellbytelabel></td>
	<td width="8%"><cellbytelabel>Empresa</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Cobertura</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Tipo Honorario</cellbytelabel></td>
	<td width="2%"><%=fb.button("addExclDetalle","+",true,viewMode,null,null,"onClick=\"javascript:addExclCD()\"","Agregar Exclusión Detalle")%></td>
</tr>
<%
	int validExclDetalle = iExclCD.size();
	al = CmnMgr.reverseRecords(iExclCD);
	for (int i=1; i<=iExclCD.size(); i++)
	{
		key = al.get(i - 1).toString();
		ExclusionDetalle ed = (ExclusionDetalle) iExclCD.get(key);
		String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow01";
		String displayExclDetalle = "";
		if (ed.getStatus() != null && ed.getStatus().equalsIgnoreCase("D"))
		{
			displayExclDetalle = " style=\"display:none\"";
			validExclDetalle--;
		}
%>
<%=fb.hidden("key"+i,ed.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,ed.getStatus())%>
<%=fb.hidden("secuencia"+i,ed.getSecuencia())%>
<%=fb.hidden("articulo"+i,ed.getArticulo())%>
<%=fb.hidden("codClase"+i,ed.getCodClase())%>
<%=fb.hidden("codFlia"+i,ed.getCodFlia())%>
<%=fb.hidden("compania"+i,ed.getCompania())%>
<%=fb.hidden("procedimiento"+i,ed.getProcedimiento())%>
<%=fb.hidden("tipoHabitacion"+i,ed.getTipoHabitacion())%>
<%=fb.hidden("codUso"+i,ed.getCodUso())%>
<%=fb.hidden("otrosCargos"+i,ed.getOtrosCargos())%>
<%=fb.hidden("precioHabitacion"+i,ed.getPrecioHabitacion())%>
<%=fb.hidden("codigoMedico"+i,ed.getCodigoMedico())%>
<%=fb.hidden("codigoEmpresa"+i,ed.getCodigoEmpresa())%>
<%=fb.hidden("codigo"+i,ed.getCodigo())%>
<%=fb.hidden("descripcion"+i,ed.getDescripcion())%>
<tr class="<%=color%>" align="center"<%=displayExclDetalle%>>
	<td><%=ed.getCodigo()%></td>
	<td align="left"><%=ed.getDescripcion()%></td>
	<td><%=fb.decBox("montoCli"+i,ed.getMontoCli(),false,false,viewMode,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValCli"+i,"P=%,M=$",ed.getTipoValCli(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoPac"+i,ed.getMontoPac(),false,false,viewMode,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValPac"+i,"P=%,M=$",ed.getTipoValPac(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.select("tipoCobPac"+i,"D=DIARIO,E=EVENTO",ed.getTipoCobPac(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoEmp"+i,ed.getMontoEmp(),false,false,viewMode,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValEmp"+i,"P=%,M=$",ed.getTipoValEmp(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.select("tipoCobEmp"+i,"D=DIARIO,E=EVENTO",ed.getTipoCobEmp(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.select("tipoHonorario"+i,"M=HONORARIOS MEDICOS,P=PROCEDIMIENTOS ESPECIALES,O=OTROS",ed.getTipoHonorario(),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeExclCD('"+i+"')\"","Eliminar Exclusión Detalle")%></td>
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

	if (cTab.equals("1")) //EXCLUSIONES
	{
		int exclSize = 0;
		if (request.getParameter("exclSize") != null)
		{
			if (request.getParameter("exclSize").trim().equals(""))//action coming from iframe and not from parent, because iframe.doSubmit() set this value
			{
				int exclCDSize = 0;
				if (request.getParameter("exclCDSize") != null) exclCDSize = Integer.parseInt(request.getParameter("exclCDSize"));

				if (request.getParameter("tipoExclusion").equalsIgnoreCase("C"))
				{
					for (int i=1; i<=exclCDSize; i++)
					{
						ExclusionCentro ec = new ExclusionCentro();

						ec.setKey(request.getParameter("key"+i));
						ec.setTipoServicio(request.getParameter("tipoServicio"+i));
						ec.setTipoServicioDesc(request.getParameter("tipoServicioDesc"+i));
						ec.setMontoCli(request.getParameter("montoCli"+i));
						ec.setTipoValCli(request.getParameter("tipoValCli"+i));
						ec.setMontoPac(request.getParameter("montoPac"+i));
						ec.setPacSolBenef(request.getParameter("pacSolBenef"+i));
						ec.setNoCubierto(request.getParameter("noCubierto"+i));
						ec.setTipoValPac(request.getParameter("tipoValPac"+i));
						ec.setMontoEmp(request.getParameter("montoEmp"+i));
						ec.setTipoValEmp(request.getParameter("tipoValEmp"+i));
						ec.setInventarioSino(request.getParameter("inventarioSino"+i));

						if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
						{
							itemRemoved = ec.getKey();
							ec.setStatus("D");//D=Delete action in ConvenioMgr
							vExclCD.remove(ec.getTipoServicio());
						}
						else ec.setStatus(request.getParameter("status"+i));

						try
						{
							iExclCD.put(ec.getKey(),ec);
						}
						catch(Exception ex)
						{
							System.err.println(ex.getMessage());
						}
					}//for ExclusionCentro
				}//ExclusionCentro
				else if (request.getParameter("tipoExclusion").equalsIgnoreCase("T"))
				{
					for (int i=1; i<=exclCDSize; i++)
					{
						ExclusionDetalle ed = new ExclusionDetalle();

						ed.setKey(request.getParameter("key"+i));
						ed.setSecuencia(request.getParameter("secuencia"+i));
						ed.setArticulo(request.getParameter("articulo"+i));
						ed.setCodClase(request.getParameter("codClase"+i));
						ed.setCodFlia(request.getParameter("codFlia"+i));
						ed.setCompania(request.getParameter("compania"+i));
						ed.setProcedimiento(request.getParameter("procedimiento"+i));
						ed.setTipoHabitacion(request.getParameter("tipoHabitacion"+i));
						ed.setCodUso(request.getParameter("codUso"+i));
						ed.setOtrosCargos(request.getParameter("otrosCargos"+i));
						ed.setPrecioHabitacion(request.getParameter("precioHabitacion"+i));
						ed.setCodigoMedico(request.getParameter("codigoMedico"+i));
						ed.setCodigoEmpresa(request.getParameter("codigoEmpresa"+i));
						ed.setCodigo(request.getParameter("codigo"+i));
						ed.setDescripcion(request.getParameter("descripcion"+i));
						ed.setMontoCli(request.getParameter("montoCli"+i));
						ed.setTipoValCli(request.getParameter("tipoValCli"+i));
						ed.setMontoPac(request.getParameter("montoPac"+i));
						ed.setTipoValPac(request.getParameter("tipoValPac"+i));
						ed.setTipoCobPac(request.getParameter("tipoCobPac"+i));
						ed.setMontoEmp(request.getParameter("montoEmp"+i));
						ed.setTipoValEmp(request.getParameter("tipoValEmp"+i));
						ed.setTipoCobEmp(request.getParameter("tipoCobEmp"+i));
						ed.setTipoHonorario(request.getParameter("tipoHonorario"+i));

						if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
						{
							itemRemoved = ed.getKey();
							ed.setStatus("D");//D=Delete action in ConvenioMgr
							vExclCD.remove(ed.getCodigo());
						}
						else ed.setStatus(request.getParameter("status"+i));

						try
						{
							iExclCD.put(ed.getKey(),ed);
						}
						catch(Exception ex)
						{
							System.err.println(ex.getMessage());
						}
					}//for ExclusionDetalle
				}//ExclusionDetalle

				if (!itemRemoved.equals(""))
				{
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoExclusion="+tipoExclusion+"&exclusion="+exclusion+"&index="+index+"&exclCDLastLineNo="+exclCDLastLineNo);
					return;
				}

				if (baction != null && baction.equals("+"))
				{
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoExclusion="+tipoExclusion+"&exclusion="+exclusion+"&index="+index+"&exclCDLastLineNo="+exclCDLastLineNo);
					return;
				}
			}//exclCDSize == ""
			else
			{
				exclSize = Integer.parseInt(request.getParameter("exclSize"));

				cp.getExclusion().clear();
				for (int i=1; i<=exclSize; i++)
				{
					Exclusion e = new Exclusion();

					e.setKey(request.getParameter("cKey"+i));
					e.setExpanded(request.getParameter("cExpanded"+i));
					e.setSecuencia(request.getParameter("cSecuencia"+i));
					e.setTipoExclusion(request.getParameter("cTipoExclusion"+i));
					e.setTipoServicio(request.getParameter("cTipoServicio"+i));
					e.setCentroServicio(request.getParameter("cCentroServicio"+i));
					e.setTipoCds(request.getParameter("cTipoCds"+i));
					e.setCodigo(request.getParameter("cCodigo"+i));
					e.setDescripcion(request.getParameter("cDescripcion"+i));
					e.setMontoCli(request.getParameter("cMontoCli"+i));
					e.setTipoValCli(request.getParameter("cTipoValCli"+i));
					e.setMontoPac(request.getParameter("cMontoPac"+i));
					e.setTipoValPac(request.getParameter("cTipoValPac"+i));
					e.setTipoCobPac(request.getParameter("cTipoCobPac"+i));
					e.setPacSolBenef(request.getParameter("cPacSolBenef"+i));
					e.setNoCubierto(request.getParameter("cNoCubierto"+i));
					e.setMontoEmp(request.getParameter("cMontoEmp"+i));
					e.setTipoValEmp(request.getParameter("cTipoValEmp"+i));
					e.setTipoCobEmp(request.getParameter("cTipoCobEmp"+i));
					e.setEmpSolBenef(request.getParameter("cEmpSolBenef"+i));
					e.setPagaDif(request.getParameter("cPagaDif"+i));

					if (request.getParameter("cRemove"+i) != null && !request.getParameter("cRemove"+i).equals(""))
					{
						itemRemoved = e.getKey();
						e.setStatus("D");//D=Delete action in ConvenioMgr
						vExcl.remove(e.getTipoExclusion()+((e.getCentroServicio() == null)?"":e.getCentroServicio())+((e.getTipoServicio() == null)?"":e.getTipoServicio()));
					}
					else e.setStatus(request.getParameter("cStatus"+i));

					if (e.getStatus() != null && !e.getStatus().equalsIgnoreCase("D") && e.getTipoExclusion().equalsIgnoreCase(request.getParameter("tipoExclusion")) && e.getSecuencia().equalsIgnoreCase(request.getParameter("exclusion")))
					{
						int exclCDSize = 0;
						if (request.getParameter("exclCDSize") != null) exclCDSize = Integer.parseInt(request.getParameter("exclCDSize"));

						if (e.getTipoExclusion().equalsIgnoreCase("C"))
						{
							e.getExclusionCentro().clear();
							for (int j=1; j<=exclCDSize; j++)
							{
								ExclusionCentro ec = new ExclusionCentro();

								ec.setKey(request.getParameter("key"+j));
								ec.setTipoServicio(request.getParameter("tipoServicio"+j));
								ec.setTipoServicioDesc(request.getParameter("tipoServicioDesc"+j));
								ec.setMontoCli(request.getParameter("montoCli"+j));
								ec.setTipoValCli(request.getParameter("tipoValCli"+j));
								ec.setMontoPac(request.getParameter("montoPac"+j));
								if (request.getParameter("noCubierto"+j) != null) ec.setNoCubierto(request.getParameter("noCubierto"+j));
								else ec.setNoCubierto("N");
								if (request.getParameter("pacSolBenef"+j) != null) ec.setPacSolBenef(request.getParameter("pacSolBenef"+j));
								else ec.setPacSolBenef("N");

								ec.setTipoValPac(request.getParameter("tipoValPac"+j));
								ec.setMontoEmp(request.getParameter("montoEmp"+j));
								ec.setTipoValEmp(request.getParameter("tipoValEmp"+j));
								if (request.getParameter("inventarioSino"+j) != null) ec.setInventarioSino(request.getParameter("inventarioSino"+j));
								else ec.setInventarioSino("N");
								ec.setStatus(request.getParameter("status"+j));

								try
								{
									iExclCD.put(ec.getKey(),ec);
									e.addExclusionCentro(ec);
								}
								catch(Exception ex)
								{
									System.err.println(ex.getMessage());
								}
							}//for ExclusionCentro
						}//ExclusionCentro
						else if (e.getTipoExclusion().equalsIgnoreCase("T"))
						{
							e.getExclusionDetalle().clear();
							for (int j=1; j<=exclCDSize; j++)
							{
								ExclusionDetalle ed = new ExclusionDetalle();

								ed.setKey(request.getParameter("key"+j));
								ed.setSecuencia(request.getParameter("secuencia"+j));
								ed.setArticulo(request.getParameter("articulo"+j));
								ed.setCodClase(request.getParameter("codClase"+j));
								ed.setCodFlia(request.getParameter("codFlia"+j));
								ed.setCompania(request.getParameter("compania"+j));
								ed.setProcedimiento(request.getParameter("procedimiento"+j));
								ed.setTipoHabitacion(request.getParameter("tipoHabitacion"+j));
								ed.setCodUso(request.getParameter("codUso"+j));
								ed.setOtrosCargos(request.getParameter("otrosCargos"+j));
								ed.setPrecioHabitacion(request.getParameter("precioHabitacion"+j));
								ed.setCodigoMedico(request.getParameter("codigoMedico"+j));
								ed.setCodigoEmpresa(request.getParameter("codigoEmpresa"+j));
								ed.setCodigo(request.getParameter("codigo"+j));
								ed.setDescripcion(request.getParameter("descripcion"+j));
								ed.setMontoCli(request.getParameter("montoCli"+j));
								ed.setTipoValCli(request.getParameter("tipoValCli"+j));
								ed.setMontoPac(request.getParameter("montoPac"+j));
								ed.setTipoValPac(request.getParameter("tipoValPac"+j));
								ed.setTipoCobPac(request.getParameter("tipoCobPac"+j));
								ed.setMontoEmp(request.getParameter("montoEmp"+j));
								ed.setTipoValEmp(request.getParameter("tipoValEmp"+j));
								ed.setTipoCobEmp(request.getParameter("tipoCobEmp"+j));
								ed.setTipoHonorario(request.getParameter("tipoHonorario"+j));
								ed.setStatus(request.getParameter("status"+j));
								ed.setUsuarioCreacion((String) session.getAttribute("_userName"));
								ed.setUsuarioModificacion((String) session.getAttribute("_userName"));

								try
								{
									iExclCD.put(ed.getKey(),ed);
									e.addExclusionDetalle(ed);
								}
								catch(Exception ex)
								{
									System.err.println(ex.getMessage());
								}
							}//for exclusionDetalle
						}//exclusionDetalle
					}//detail belongs to exclusion

					try
					{
						iExcl.put(e.getKey(),e);
						cp.addExclusion(e);
						key = e.getTipoExclusion()+((e.getCentroServicio() == null)?"":e.getCentroServicio())+((e.getTipoServicio() == null)?"":e.getTipoServicio());
						if (!e.getStatus().equalsIgnoreCase("D") && !key.equalsIgnoreCase("C") && !key.equalsIgnoreCase("T") && !vExcl.contains(key))
							vExcl.add(key);
					}
					catch(Exception ex)
					{
						System.err.println(ex.getMessage());
					}
				}//for exclusion
			}//cobSize != ""
		}//cobSize != null

		if (baction != null && baction.equals("+"))
		{
			Exclusion e = new Exclusion();

			exclLastLineNo++;
			if (exclLastLineNo < 10) key = "00" + exclLastLineNo;
			else if (exclLastLineNo < 100) key = "0" + exclLastLineNo;
			else key = "" + exclLastLineNo;
			e.setKey(key);

			e.setSecuencia("0");

			try
			{
				iExcl.put(e.getKey(),e);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}

		if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConvMgr.saveExclusion(cp);
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
	parent.location = '../planmedico/pm_convenio_clasif.jsp?change=1&type=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&index=<%=index%>&cobLastLineNo=<%=cobLastLineNo%>&exclLastLineNo=<%=exclLastLineNo%>&defLastLineNo=<%=defLastLineNo%>';
<%
	}
	else if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
%>
	parent.document.form1.errCode.value='<%=ConvMgr.getErrCode()%>';
	parent.document.form1.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(ConvMgr.getErrMsg())%>';
	parent.document.form1.tipoCE.value='<%=tipoExclusion%>';
	parent.document.form1.ce.value='<%=exclusion%>';
	parent.document.form1.index.value='<%=index%>';
	parent.document.form1.submit();
<%
	}
	else
	{
%>
	parent.location = '../planmedico/pm_convenio_clasif.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceCDLastLineNo=<%=exclCDLastLineNo%>&index=<%=index%>&cobLastLineNo=<%=request.getParameter("cobLastLineNo")%>&exclLastLineNo=<%=request.getParameter("exclLastLineNo")%>&defLastLineNo=<%=request.getParameter("defLastLineNo")%>';
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