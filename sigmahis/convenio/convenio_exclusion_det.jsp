<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.ExclusionCentro"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iExclDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclDet" scope="session" class="java.util.Vector" />
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
String tipoExclusion = request.getParameter("tipoExclusion");
String exclusion = request.getParameter("exclusion");
String tipoServicio = request.getParameter("tipoServicio");
int exclDetLastLineNo = 0;
String centroServicio = request.getParameter("centroServicio");
String tipoCds = request.getParameter("tipoCds");
String inventarioSino = request.getParameter("inventarioSino");

if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (tipoPoliza == null || tipoPlan == null || planNo == null) throw new Exception("El Plan no es válido. Por favor intente nuevamente!");
if (categoriaAdm == null || tipoAdm == null || clasifAdm == null) throw new Exception("La Clasificación del Plan no es válida. Por favor intente nuevamente!");
if (tipoExclusion == null || exclusion == null) throw new Exception("La Exclusión no es válida. Por favor intente nuevamente!");
if (tipoServicio == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");
if (request.getParameter("exclDetLastLineNo") != null) exclDetLastLineNo = Integer.parseInt(request.getParameter("exclDetLastLineNo"));
if (centroServicio == null || tipoCds == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
if (inventarioSino == null) inventarioSino = "N";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (request.getParameter("change") == null)
	{
		iExclDet.clear();
		vExclDet.clear();

		sql = "select a.convenio, a.empresa, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, a.secuencia, a.monto_cli as montoCli, a.monto_emp as montoEmp, a.monto_pac as montoPac, a.tipo_val_cli as tipoValCli, a.tipo_val_emp as tipoValEmp, a.tipo_val_pac as tipoValPac, a.tipo_cob_emp as tipoCobEmp, a.tipo_cob_pac as tipoCobPac, a.tipo_exclusion as tipoExclusion, a.exclusion, a.tipo_servicio as tipoServicio, a.procedimiento, a.articulo, a.cod_clase as codClase, a.cod_flia as codFlia, a.compania, a.tipo_habitacion as tipoHabitacion, a.tipo_honorario as tipoHonorario, a.emp_paga_dif as empPagaDif, a.cod_uso as codUso, a.otros_cargos as otrosCargos, a.cds_producto as cdsProducto, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fechaModificacion, a.emp_sol_benef as empSolBenef, a.pac_sol_benef as pacSolBenef, a.centro_servicio as centroServicio, a.pac_sol_benef_det as pacSolBenefDet, a.codigo_medico as codigoMedico, a.codigo_empresa as codigoEmpresa, a.no_cubierto as noCubierto, a.precio_habitacion as precioHabitacion, coalesce(a.procedimiento,decode(a.cod_flia,null,null,decode(a.cod_clase,null,null,decode(a.articulo,null,null,a.cod_flia||'-'||a.cod_clase||'-'||a.articulo))), ''||a.tipo_habitacion, ''||a.cod_uso, ''||a.otros_cargos, ''||a.cds_producto, a.codigo_medico, ''||a.codigo_empresa) as codigo, coalesce(c.descripcion,d.observacion,d.descripcion,e.descripcion,f.descripcion,g.descripcion,h.descripcion) as descripcion from tbl_adm_detalle_exclusion a, tbl_cds_tipo_servicio b, tbl_inv_articulo c, tbl_cds_procedimiento d, (select codigo, compania, descripcion||' - '||to_char(precio,'$9,990.00') as descripcion, precio from tbl_sal_tipo_habitacion where estatus='A') e, tbl_sal_uso f, (select codigo, compania, descripcion from tbl_fac_otros_cargos where activo_inactivo='A') g, (select codigo, descripcion from tbl_cds_producto_x_cds where cod_centro_servicio="+centroServicio+" and tser='"+tipoServicio+"') h where a.tipo_servicio=b.codigo(+) and a.articulo=c.cod_articulo(+) and a.cod_clase=c.cod_clase(+) and a.cod_flia=c.cod_flia(+) and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.tipo_habitacion=e.codigo(+) and a.compania=e.compania(+) and a.cod_uso=f.codigo(+) and a.compania=f.compania(+) and a.otros_cargos=g.codigo(+) and a.compania=g.compania(+) and a.cds_producto=h.codigo(+) and a.convenio="+secuencia+" and a.empresa="+empresa+" and a.plan="+planNo+" and a.categoria_admi="+categoriaAdm+" and a.tipo_admi="+tipoAdm+" and a.clasif_admi="+clasifAdm+" and a.exclusion="+exclusion+" and a.tipo_exclusion='"+tipoExclusion+"' and a.tipo_servicio='"+tipoServicio+"'";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,ExclusionDetalle.class);

		exclDetLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			ExclusionDetalle ed = (ExclusionDetalle) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			ed.setKey(key);

			try
			{
				iExclDet.put(ed.getKey(), ed);
				vExclDet.add(ed.getCodigo());
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
document.title = 'Exclusión Detalle';

function removeExclDet(k)
{
	if(confirm('¿Está seguro de eliminar el Detalle de la Exclusión?'))
	{
		removeItem('form1',k);
		form1BlockButtons(true);
		document.form1.submit();
	}
}

function doAction()
{
<%
if (request.getParameter("type") != null)
{
%>
	var tipoServicio = '<%=tipoServicio%>';
	var inventarioSino = '<%=inventarioSino%>';
	var tipoCds = '<%=tipoCds%>';
//	alert('tipoServicio='+tipoServicio+' inventarioSino='+inventarioSino+' tipoCds='+tipoCds);

	if (tipoServicio == '02' || tipoServicio == '03' || tipoServicio == '04')
		if (inventarioSino == 'S' && tipoCds == 'I') showArticuloList();
		else if (inventarioSino == 'N' && tipoCds == 'I') showUsoList();
		else if (inventarioSino == 'N' && tipoCds == 'T') showProductoCdsList();
		else alert('No Aplica!');
	else if (tipoServicio == '05' || tipoServicio == '06' || tipoServicio == '09' || tipoServicio == '10')
		if (tipoCds == 'I') showUsoList();
		else if (tipoCds == 'T' || tipoCds == 'E') showProductoCdsList();
		else alert('No Aplica!');
	else if (tipoServicio == '07')
		if (tipoCds == 'I') showProcedimientoList();
		else if (tipoCds == 'T' || tipoCds == 'E') showProductoCdsList();
		else alert('No Aplica!');
	else if (tipoServicio == '11' || tipoServicio == '12' || tipoServicio == '13' || tipoServicio == '14') showUsoList();
	else if (tipoServicio == '30') showOtrosCargosList();
	else if (tipoServicio == '08') showArticuloList();
	else if (tipoServicio == '01') showTipoHabitacionList();
	else alert('No Aplica!');
<%
}
%>
}

function showArticuloList()
{
	abrir_ventana2('../common/check_articulo.jsp?fp=convenio_exclusion_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceDetLastLineNo=<%=exclDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>');
}

function showUsoList()
{
	abrir_ventana2('../common/check_uso.jsp?fp=convenio_exclusion_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceDetLastLineNo=<%=exclDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>');
}

function showProductoCdsList()
{
	abrir_ventana2('../common/check_producto_x_cds.jsp?fp=convenio_exclusion_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceDetLastLineNo=<%=exclDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>');
}

function showProcedimientoList()
{
	abrir_ventana2('../common/check_procedimiento.jsp?fp=convenio_exclusion_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceDetLastLineNo=<%=exclDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>');
}

function showOtrosCargosList()
{
	abrir_ventana2('../common/check_otroscargos.jsp?fp=convenio_exclusion_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceDetLastLineNo=<%=exclDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>');
}

function showTipoHabitacionList()
{
	abrir_ventana2('../common/check_tipo_habitacion.jsp?fp=convenio_exclusion_detalle&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCE=<%=tipoExclusion%>&ce=<%=exclusion%>&ceDetLastLineNo=<%=exclDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>');
}

function winClose()
{
	//parent.window.frames['iDetalle1'].showSelectBoxes(true);
	//parent.showSelectBoxes(true);
	parent.hidePopWin(true);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
<%=fb.hidden("tipoExclusion",tipoExclusion)%>
<%=fb.hidden("exclusion",exclusion)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("centroServicio",centroServicio)%>
<%=fb.hidden("tipoCds",tipoCds)%>
<%=fb.hidden("inventarioSino",inventarioSino)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("exclDetSize",""+iExclDet.size())%>
<%=fb.hidden("exclDetLastLineNo",""+exclDetLastLineNo)%>
<tr class="TextHeader" align="center">
	<td colspan="15"><cellbytelabel>E X C L U S I O N E S</cellbytelabel> &nbsp; <cellbytelabel>D E T A L L A D A S</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>I N S U M O S</cellbytelabel> &nbsp; <cellbytelabel>Y / O</cellbytelabel> &nbsp; <cellbytelabel>S E R V I C I O S</cellbytelabel></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="8%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
	<td width="26%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="8%"><cellbytelabel>Descuento</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Paciente</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Dif</cellbytelabel>.</td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Cobertura</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Sol</cellbytelabel>.</td>
	<td width="4%"><cellbytelabel>Det</cellbytelabel>.</td>
	<td width="8%"><cellbytelabel>Empresa</cellbytelabel></td>
	<td width="4%">%-$</td>
	<td width="8%"><cellbytelabel>Cobertura</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Sol</cellbytelabel>.</td>
	<td width="2%"><%=fb.submit("addExclDetalle","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Exclusión Detalle")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iExclDet);
for (int i=1; i<=iExclDet.size(); i++)
{
	key = al.get(i - 1).toString();
	ExclusionDetalle ed = (ExclusionDetalle) iExclDet.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayExclDetalle = "";
	if (ed.getStatus() != null && ed.getStatus().equalsIgnoreCase("D")) displayExclDetalle = " style=\"display:none\"";
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
<%=fb.hidden("tipoHonorario"+i,ed.getTipoHonorario())%>
<%=fb.hidden("codUso"+i,ed.getCodUso())%>
<%=fb.hidden("otrosCargos"+i,ed.getOtrosCargos())%>
<%=fb.hidden("cdsProducto"+i,ed.getCdsProducto())%>
<%=fb.hidden("precioHabitacion"+i,ed.getPrecioHabitacion())%>
<%=fb.hidden("codigoMedico"+i,ed.getCodigoMedico())%>
<%=fb.hidden("codigoEmpresa"+i,ed.getCodigoEmpresa())%>
<%=fb.hidden("codigo"+i,ed.getCodigo())%>
<%=fb.hidden("descripcion"+i,ed.getDescripcion())%>
<tr class="<%=color%>" align="center"<%=displayExclDetalle%>>
	<td><%=ed.getCodigo()%></td>
	<td align="left"><%=ed.getDescripcion()%></td>
	<td><%=fb.decBox("montoCli"+i,ed.getMontoCli(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValCli"+i,"P=%,M=$",ed.getTipoValCli(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoPac"+i,ed.getMontoPac(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.checkbox("noCubierto"+i,"S",(ed.getNoCubierto() != null && ed.getNoCubierto().equals("S")),false)%></td>
	<td><%=fb.select("tipoValPac"+i,"P=%,M=$",ed.getTipoValPac(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.select("tipoCobPac"+i,"D=DIARIO,E=EVENTO",ed.getTipoCobPac(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.checkbox("pacSolBenef"+i,"S",(ed.getPacSolBenef() != null && ed.getPacSolBenef().equals("S")),false)%></td>
	<td><%=fb.checkbox("pacSolBenefDet"+i,"S",(ed.getPacSolBenefDet() != null && ed.getPacSolBenefDet().equals("S")),false)%></td>
	<td><%=fb.decBox("montoEmp"+i,ed.getMontoEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValEmp"+i,"P=%,M=$",ed.getTipoValEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.select("tipoCobEmp"+i,"D=DIARIO,E=EVENTO",ed.getTipoCobEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.checkbox("empSolBenef"+i,"S",(ed.getEmpSolBenef() != null && ed.getEmpSolBenef().equals("S")),false)%></td>
	<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeExclDet('"+i+"')\"","Eliminar Exclusión Detalle")%></td>
</tr>
<%
}
%>
<tr class="TextRow02">
	<td colspan="15" align="right">
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

	ExclusionCentro ec = new ExclusionCentro();
	ec.setEmpresa(request.getParameter("empresa"));
	ec.setConvenio(request.getParameter("secuencia"));
	ec.setPlan(request.getParameter("planNo"));
	ec.setCategoriaAdmi(request.getParameter("categoriaAdm"));
	ec.setTipoAdmi(request.getParameter("tipoAdm"));
	ec.setClasifAdmi(request.getParameter("clasifAdm"));
	ec.setTipoExclusion(request.getParameter("tipoExclusion"));
	ec.setExclusion(request.getParameter("exclusion"));
	ec.setTipoServicio(request.getParameter("tipoServicio"));

	int exclDetSize = 0;
	if (request.getParameter("exclDetSize") != null) exclDetSize = Integer.parseInt(request.getParameter("exclDetSize"));

	for (int i=1; i<=exclDetSize; i++)
	{
		ExclusionDetalle ed = new ExclusionDetalle();

		ed.setKey(request.getParameter("key"+i));
		ed.setSecuencia(request.getParameter("secuencia"+i));
		ed.setCentroServicio(centroServicio);
		ed.setArticulo(request.getParameter("articulo"+i));
		ed.setCodClase(request.getParameter("codClase"+i));
		ed.setCodFlia(request.getParameter("codFlia"+i));
		ed.setCompania(request.getParameter("compania"+i));
		ed.setProcedimiento(request.getParameter("procedimiento"+i));
		ed.setTipoHabitacion(request.getParameter("tipoHabitacion"+i));
		ed.setTipoHonorario(request.getParameter("tipoHonorario"+i));
		ed.setCodUso(request.getParameter("codUso"+i));
		ed.setOtrosCargos(request.getParameter("otrosCargos"+i));
		ed.setCdsProducto(request.getParameter("cdsProducto"+i));
		ed.setPrecioHabitacion(request.getParameter("precioHabitacion"+i));
		ed.setCodigoMedico(request.getParameter("codigoMedico"+i));
		ed.setCodigoEmpresa(request.getParameter("codigoEmpresa"+i));
		ed.setCodigo(request.getParameter("codigo"+i));
		ed.setDescripcion(request.getParameter("descripcion"+i));
		ed.setMontoCli(request.getParameter("montoCli"+i));
		ed.setTipoValCli(request.getParameter("tipoValCli"+i));
		ed.setMontoPac(request.getParameter("montoPac"+i));
		ed.setNoCubierto(request.getParameter("noCubierto"+i));
		ed.setTipoValPac(request.getParameter("tipoValPac"+i));
		ed.setTipoCobPac(request.getParameter("tipoCobPac"+i));
		ed.setPacSolBenef(request.getParameter("pacSolBenef"+i));
		ed.setPacSolBenefDet(request.getParameter("pacSolBenefDet"+i));
		ed.setMontoEmp(request.getParameter("montoEmp"+i));
		ed.setTipoValEmp(request.getParameter("tipoValEmp"+i));
		ed.setTipoCobEmp(request.getParameter("tipoCobEmp"+i));
		ed.setEmpSolBenef(request.getParameter("pacSolBenef"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = ed.getKey();
			ed.setStatus("D");//D=Delete action in ConvenioMgr
			vExclDet.remove(ed.getCodigo());
		}
		else ed.setStatus(request.getParameter("status"+i));

		try
		{
			iExclDet.put(ed.getKey(),ed);
			ec.addExclusionDetalle(ed);
		}
		catch(Exception ex)
		{
			System.err.println(ex.getMessage());
		}
	}//for ExclusionDetalle

	if (!itemRemoved.equals(""))
	{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoExclusion="+tipoExclusion+"&exclusion="+exclusion+"&tipoServicio="+tipoServicio+"&exclDetLastLineNo="+exclDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoExclusion="+tipoExclusion+"&exclusion="+exclusion+"&tipoServicio="+tipoServicio+"&exclDetLastLineNo="+exclDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino);
		return;
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConvMgr.saveExclusionDetalle(ec);
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
	//parent.window.frames['iDetalle1'].showSelectBoxes(true);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoExclusion%>&exclusion=<%=exclusion%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>