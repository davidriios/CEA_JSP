<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.CoberturaCentro"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iCobDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobDet" scope="session" class="java.util.Vector" />
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
String tipoServicio = request.getParameter("tipoServicio");
int cobDetLastLineNo = 0;

if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null || planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");
if (categoriaAdm == null || tipoAdm == null || clasifAdm == null) throw new Exception("La Clasificación del Plan no es válida. Por favor intente nuevamente!");
if (tipoCobertura == null || cobertura == null) throw new Exception("La Cobertura no es válida. Por favor intente nuevamente!");
if (tipoServicio == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");
if (request.getParameter("cobDetLastLineNo") != null) cobDetLastLineNo = Integer.parseInt(request.getParameter("cobDetLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (request.getParameter("change") == null)
	{
		iCobDet.clear();
		vCobDet.clear();

		sql = "select a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.empresa, a.convenio, a.plan, a.secuencia, a.tipo_cobertura as tipoCobertura, a.cobertura, a.tipo_servicio as tipoServicio, a.tipo_honorario as tipoHonorario, a.articulo, a.cod_clase as codClase, a.cod_flia as codFlia, a.compania, a.procedimiento, a.tipo_habitacion as tipoHabitacion, a.sth_compania as sthCompania, a.emp_paga_dif as empPagaDif, a.cod_uso as codUso, a.otros_cargos as otrosCargos, a.cds_producto as cdsProducto, a.almacen, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.cerntro_servicio as cerntroServicio, a.monto_cli as montoCli, a.tipo_monto_cli as tipoMontoCli, a.monto_pac as montoPac, a.tipo_monto_pac as tipoMontoPac, a.monto_emp as montoEmp, a.tipo_monto_emp as tipoMontoEmp, a.monto_lim_emp as montoLimEmp, a.tipo_monto_lim_emp as tipoMontoLimEmp, a.monto_exc_emp as montoExcEmp, a.tipo_monto_exc_emp as tipoMontoExcEmp, a.centro_servicio as centroServicio, a.cant_lim as cantLim, a.precio_habitacion as precioHabitacion, a.codigo_medico as codigoMedico, a.codigo_empresa as codigoEmpresa, b.descripcion as tipoServicioDesc, coalesce(decode(a.cod_flia,null,null,decode(a.cod_clase,null,null,decode(a.articulo,null,null,a.cod_flia||'-'||a.cod_clase||'-'||a.articulo))), a.procedimiento, ''||a.tipo_habitacion, ''||a.cod_uso, ''||a.otros_cargos, a.codigo_medico, ''||a.codigo_empresa) as codigo, coalesce(c.descripcion,d.observacion,d.descripcion,e.descripcion,f.descripcion,g.descripcion,h.nombre_medico,i.nombre) as descripcion from tbl_adm_detalle_cobertura a, tbl_cds_tipo_servicio b, tbl_inv_articulo c, tbl_cds_procedimiento d, (select codigo, compania, descripcion||' - '||to_char(precio,'$9,990.00') as descripcion, precio from tbl_sal_tipo_habitacion where estatus='A') e, tbl_sal_uso f, (select codigo, compania, descripcion from tbl_fac_otros_cargos where activo_inactivo='A') g, (select codigo, primer_nombre||' '||segundo_nombre||' '||decode(apellido_de_casada,null,primer_apellido||' '||segundo_apellido,apellido_de_casada) as nombre_medico from tbl_adm_medico where estado='A') h, (select codigo, nombre from tbl_adm_empresa where tipo_empresa=1) i where a.tipo_servicio=b.codigo(+) and a.articulo=c.cod_articulo(+) and a.cod_clase=c.cod_clase(+) and a.cod_flia=c.cod_flia(+) and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.tipo_habitacion=e.codigo(+) and a.compania=e.compania(+) and a.cod_uso=f.codigo(+) and a.compania=f.compania(+) and a.otros_cargos=g.codigo(+) and a.compania=g.compania(+) and a.codigo_medico=h.codigo(+) and a.codigo_empresa=i.codigo(+) and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" and a.cobertura="+cobertura+" and a.tipo_cobertura='"+tipoCobertura+"' and a.tipo_servicio='"+tipoServicio+"'";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,CoberturaDetalle.class);

		cobDetLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			CoberturaDetalle cd = (CoberturaDetalle) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cd.setKey(key);

			try
			{
				iCobDet.put(cd.getKey(), cd);
				vCobDet.add(cd.getCodigo());
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
<script language="javascript">
document.title = 'Cobertura Detalle';

function removeCobDet(k)
{
	if(confirm('¿Está seguro de eliminar el Detalle de la Cobertura?'))
	{
		removeItem('form0',k);
		form0BlockButtons(true);
		document.form0.submit();
	}
}

function doAction()
{
<%
if (request.getParameter("type") != null)
{
%>
	var tipoServicio = '<%=tipoServicio%>';
//	alert(tipoServicio);

	if (tipoServicio == '02' || tipoServicio == '03' || tipoServicio == '08') showArticuloList();
	else if (tipoServicio == '04' || tipoServicio == '05' || tipoServicio == '06' || tipoServicio == '09' || tipoServicio == '10' || tipoServicio == '11' || tipoServicio == '12' || tipoServicio == '13' || tipoServicio == '14' || tipoServicio == '19') showUsoList();
	else if (tipoServicio == '07') showProcedimientoList();
	else if (tipoServicio == '30') showOtrosCargosList();
	else if (tipoServicio == '01') showTipoHabitacionList();
	else if (tipoServicio == '27') showMedicoList();
	else alert('No aplica!');
<%
}
%>
}

function showArticuloList()
{
	abrir_ventana2('../common/check_articulo.jsp?fp=pm_convenio_cobertura_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>');
}

function showUsoList()
{
	abrir_ventana2('../common/check_uso.jsp?fp=pm_convenio_cobertura_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>');
}

function showProcedimientoList()
{
	abrir_ventana2('../common/check_procedimiento.jsp?fp=pm_convenio_cobertura_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>');
}

function showOtrosCargosList()
{
	abrir_ventana2('../common/check_otroscargos.jsp?fp=pm_convenio_cobertura_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>');
}

function showTipoHabitacionList()
{
	abrir_ventana2('../common/check_tipo_habitacion.jsp?fp=pm_convenio_cobertura_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>');
}

function showMedicoList()
{
	abrir_ventana2('../common/check_empresa_medico.jsp?fp=pm_convenio_cobertura_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>');
}

function winClose()
{
	//parent.window.frames['iDetalle0'].showSelectBoxes(true);
	//parent.showSelectBoxes(true);
	parent.hidePopWin(true);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
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
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cobDetSize",""+iCobDet.size())%>
<%=fb.hidden("cobDetLastLineNo",""+cobDetLastLineNo)%>
<tr class="TextHeader" align="center">
	<td colspan="14"><cellbytelabel>C O B E R T U R A S</cellbytelabel> &nbsp; <cellbytelabel>D E T A L L A D A S</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>I N S U M O S</cellbytelabel> &nbsp; <cellbytelabel>Y / O</cellbytelabel> &nbsp; <cellbytelabel>S E R V I C I O S</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="8%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
	<td width="61%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Cant</cellbytelabel>.</td>
	<td width="8%"><cellbytelabel>Descuento</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Paciente</cellbytelabel></td>
	<td width="4%">%-$</td>
	<!--<td width="8%"><cellbytelabel>Empresa</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>L&iacute;mite</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Exced</cellbytelabel>.</td>
	<td width="4%">%-$</td>-->
	<td width="2%"><%=fb.submit("addCobDetalle","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Cobertura Detalle")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iCobDet);
for (int i=1; i<=iCobDet.size(); i++)
{
	key = al.get(i - 1).toString();
	CoberturaDetalle cd = (CoberturaDetalle) iCobDet.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayCobDetalle = "";
	if (cd.getStatus() != null && cd.getStatus().equalsIgnoreCase("D")) displayCobDetalle = " style=\"display:none\"";
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
<%=fb.hidden("codigo"+i,cd.getCodigo())%>
<%=fb.hidden("descripcion"+i,cd.getDescripcion())%>
<tr class="<%=color%>" align="center"<%=displayCobDetalle%>>
	<td><%=cd.getCodigo()%></td>
	<td align="left"><%=cd.getDescripcion()%></td>
	<td><%=fb.intBox("cantLim"+i,cd.getCantLim(),false,false,false,3,3,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoCli"+i,cd.getMontoCli(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMontoCli"+i,"P=%,M=$",cd.getTipoMontoCli(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoPac"+i,cd.getMontoPac(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMontoPac"+i,"P=%,M=$",cd.getTipoMontoPac(),false,false,0,"Text10",null,null)%></td>
	<!--<td><%//=fb.decBox("montoEmp"+i,cd.getMontoEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%//=fb.select("tipoMontoEmp"+i,"P=%,M=$",cd.getTipoMontoEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%//=fb.decBox("montoLimEmp"+i,cd.getMontoLimEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%//=fb.select("tipoMontoLimEmp"+i,"P=%,M=$",cd.getTipoMontoLimEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%//=fb.decBox("montoExcEmp"+i,cd.getMontoExcEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%//=fb.select("tipoMontoExcEmp"+i,"P=%,M=$",cd.getTipoMontoExcEmp(),false,false,0,"Text10",null,null)%></td>-->
	
	<%=fb.hidden("montoEmp"+i,cd.getMontoEmp())%>
	<%=fb.hidden("tipoMontoEmp"+i,cd.getTipoMontoEmp())%>
	<%=fb.hidden("montoLimEmp"+i,cd.getMontoLimEmp())%>
	<%=fb.hidden("tipoMontoLimEmp"+i,cd.getTipoMontoLimEmp())%>
	<%=fb.hidden("montoExcEmp"+i,cd.getMontoExcEmp())%>
	<%=fb.hidden("tipoMontoExcEmp"+i,cd.getTipoMontoExcEmp())%>
	<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeCobDet('"+i+"')\"","Eliminar Cobertura Detalle")%></td>
</tr>
<%
}
%>
<tr class="TextRow02">
	<td colspan="14" align="right">
		<cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%--<%=fb.radio("saveOption","N")%>Crear Otro--%>
		<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.submit("save","Guardar",true,false)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:winClose()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";

	CoberturaCentro cc = new CoberturaCentro();
	cc.setEmpresa(request.getParameter("empresa"));
	cc.setConvenio(request.getParameter("secuencia"));
	cc.setPlan(request.getParameter("planNo"));
	cc.setCategoriaAdmi(request.getParameter("categoriaAdm"));
	cc.setTipoAdmi(request.getParameter("tipoAdm"));
	cc.setClasifAdmi(request.getParameter("clasifAdm"));
	cc.setTipoCobertura(request.getParameter("tipoCobertura"));
	cc.setCobertura(request.getParameter("cobertura"));
	cc.setTipoServicio(request.getParameter("tipoServicio"));

	int cobDetSize = 0;
	if (request.getParameter("cobDetSize") != null) cobDetSize = Integer.parseInt(request.getParameter("cobDetSize"));

	for (int i=1; i<=cobDetSize; i++)
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
		cd.setMontoCli(request.getParameter("montoCli"+i));
		cd.setTipoMontoCli(request.getParameter("tipoMontoCli"+i));
		cd.setMontoPac(request.getParameter("montoPac"+i));
		cd.setTipoMontoPac(request.getParameter("tipoMontoPac"+i));
		cd.setMontoEmp(request.getParameter("montoEmp"+i));
		cd.setTipoMontoEmp(request.getParameter("tipoMontoEmp"+i));
		cd.setMontoLimEmp(request.getParameter("montoLimEmp"+i));
		cd.setTipoMontoLimEmp(request.getParameter("tipoMontoLimEmp"+i));
		cd.setMontoExcEmp(request.getParameter("montoExcEmp"+i));
		cd.setTipoMontoExcEmp(request.getParameter("tipoMontoExcEmp"+i));
		cd.setUsuarioCreacion((String) session.getAttribute("_userName"));
		cd.setUsuarioModificacion((String) session.getAttribute("_userName"));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cd.getKey();
			cd.setStatus("D");//D=Delete action in ConvenioMgr
			vCobDet.remove(cd.getCodigo());
		}
		else cd.setStatus(request.getParameter("status"+i));

		try
		{
			iCobDet.put(cd.getKey(),cd);
			cc.addCoberturaDetalle(cd);
		}
		catch(Exception ex)
		{
			System.err.println(ex.getMessage());
		}
	}//for CoberturaDetalle

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&tipoServicio="+tipoServicio+"&cobDetLastLineNo="+cobDetLastLineNo);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&tipoServicio="+tipoServicio+"&cobDetLastLineNo="+cobDetLastLineNo);
		return;
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConvMgr.saveCoberturaDetalle(cc);
	ConMgr.clearAppCtx(null);
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
	//parent.window.frames['iDetalle0'].showSelectBoxes(true);
	//parent.showSelectBoxes(true);
	parent.hidePopWin(true);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCobertura%>&cobertura=<%=cobertura%>&tipoServicio=<%=tipoServicio%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>