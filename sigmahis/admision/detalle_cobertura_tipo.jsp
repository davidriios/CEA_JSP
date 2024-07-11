<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.DetalleCoberturaConvenio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admision.CoberturaDetalladaServicio"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />
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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String tipoCobertura = request.getParameter("tipoCobertura");
String cobertura = request.getParameter("cobertura");
String tipoServicio = request.getParameter("tipoServicio");
int cobDetLastLineNo = 0;
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String secuencia_cob = request.getParameter("secuencia_cob");
String secuencia_sol1= request.getParameter("secuencia_sol1");
String solicitud = request.getParameter("solicitud");
String secuencia_sol2 = request.getParameter("secuencia_sol2");
String filter = "";
String cds = request.getParameter("cds");

if (mode == null) mode = "add";
if (request.getParameter("cobDetLastLineNo") != null) cobDetLastLineNo = Integer.parseInt(request.getParameter("cobDetLastLineNo"));
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (request.getParameter("change") == null)
	{
		iCobDet.clear();
		vCobDet.clear();


		if(!tipoCobertura.trim().equals("T"))
		filter = " and a.secuencia_sol2 = "+secuencia_sol2;

		sql="select to_char(a.fecha_nacimiento,'dd/mm/yyyy')as fecha_nacimiento, a.codigo_paciente as codigoPaciente, a.admision as admision,a.empresa as empresa, a.solicitud as solicitud, a.secuencia_cob as secuenciaCob,a.secuencia_sol1 as secuenciaSol1, a.secuencia_sol2 as secuenciaSol2, a.secuencia as secuencia,a.centro_servicio as centroServicio, a.tipo_servicio as tipoServicio ,a.monto_pac as montoPac,a.monto_emp as montoEmp, a.tipo_val_emp as tipoValEmp, a.procedimiento as procedimiento ,a.cod_flia as codFlia, a.cod_clase as codClase, a.cod_articulo as codArticulo, a.cod_uso as codUso,a.cod_otros as codOtros, a.cod_cds_prod as codCdsProd,a.compania as compania, a.tipo_val_pac as tipoValPac, a.cod_centro_servicio as codCentroServicio,a.pase as pase,a.pase_k as paseK,a.pac_id as pacId,coalesce(decode(a.cod_flia,null,null,decode(a.cod_clase,null,null,decode(a.cod_articulo,null,null, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo))), a.procedimiento, ''||a.cod_uso, ''||a.cod_otros,''|| a.cod_cds_prod )as codigo, coalesce(h.descripcion, c.descripcion, d.observacion, d.descripcion, f.descripcion, g.descripcion) as descripcion from tbl_adm_cobertura_sol3 a,tbl_cds_centro_servicio cd, tbl_inv_articulo c,tbl_cds_procedimiento d,tbl_cds_tipo_servicio b,tbl_sal_uso f, (select codigo, compania, descripcion from tbl_fac_otros_cargos where activo_inactivo='A') g ,(select codigo, cod_centro_servicio, descripcion from tbl_cds_producto_x_cds where estatus='A') h   where a.pac_id = "+pac_id+" and a.admision = "+admision+" and a.empresa ="+empresa+" and solicitud= "+solicitud+"and secuencia_cob= "+secuencia_cob+" and a.secuencia_sol1 = "+secuencia_sol1+" "+filter +" and a.centro_servicio = cd.codigo(+) and  a.tipo_servicio=b.codigo(+)and a.cod_articulo=c.cod_articulo(+) and a.cod_clase=c.cod_clase(+) and a.cod_flia=c.cod_flia(+) and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.cod_uso=f.codigo(+) and a.compania=f.compania(+) and a.cod_otros=g.codigo(+) and a.compania=g.compania(+) and a.cod_cds_prod=h.codigo(+) and a.cod_centro_servicio=h.cod_centro_servicio(+)";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,CoberturaDetalladaServicio.class);

		cobDetLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			CoberturaDetalladaServicio cd = (CoberturaDetalladaServicio) al.get(i-1);

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
document.title = 'Solicitud de beneficio Cobertura Detallada ';

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

	if (tipoServicio == '02' || tipoServicio == '03' ) showArticuloList();//|| tipoServicio == '08' preguntar
	//else if (tipoServicio == '04' || tipoServicio == '05' || tipoServicio == '06' || tipoServicio == '09' || tipoServicio == '10' || tipoServicio == '11' || tipoServicio == '12' || tipoServicio == '13' || tipoServicio == '14') showUsoList();
	else if (tipoServicio == '05') showUsoList();
	else if (tipoServicio == '07') showProcedimientoList();
	else if (tipoServicio == '30') showOtrosCargosList();
	else{ CBMSG.warning('No aplica!'); winClose();}
<%
}
%>
}

function showArticuloList()
{
	abrir_ventana2('../common/check_articulo.jsp?fp=convenio_cobertura_solicitud&mode=<%=mode%>&empresa=<%=empresa%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>&centroServicio=<%=cds%>');
}

function showProcedimientoList()
{
	var centro = '<%=cds%>';
	abrir_ventana2('../common/check_procedimiento.jsp?fp=convenio_cobertura_detSol&mode=<%=mode%>&empresa=<%=empresa%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>&centroServicio=<%=cds%>');
}

function showUsoList()
{
	abrir_ventana2('../common/check_uso.jsp?fp=convenio_cobertura_solicitud&mode=<%=mode%>&empresa=<%=empresa%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>&centroServicio=<%=cds%>');
}
function showOtrosCargosList()
{
	abrir_ventana2('../common/check_otroscargos.jsp?fp=convenio_cobertura_solicitud&mode=<%=mode%>&empresa=<%=empresa%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&ceDetLastLineNo=<%=cobDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>&centroServicio=<%=cds%>');
}
function winClose()
{
	//if(parent.window.frames['iDetalle0'])
	//{
	//	parent.window.frames['iDetalle0'].showSelectBoxes(true);
	//}
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
<%=fb.hidden("tipoCobertura",tipoCobertura)%>
<%=fb.hidden("cobertura",cobertura)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cobDetSize",""+iCobDet.size())%>
<%=fb.hidden("cobDetLastLineNo",""+cobDetLastLineNo)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
<%=fb.hidden("cds",cds)%>

<tr class="TextHeader" align="center">
	<td colspan="7">C O B E R T U R A S &nbsp; D E T A L L A D A S &nbsp; D E &nbsp; I N S U M O S &nbsp; Y / O &nbsp; S E R V I C I O S</td>
</tr>
<tr class="TextHeader" align="center">
	<td width="8%">C&oacute;digo</td>
	<td width="25%">Descripci&oacute;n</td>
	<td width="8%">Paciente</td>
	<td width="4%">%-$</td>
	<td width="8%">Empresa</td>
	<td width="4%">%-$</td>
	<td width="2%"><%=fb.submit("addCobDetalle","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Cobertura Detalle")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iCobDet);
for (int i=1; i<=iCobDet.size(); i++)
{
	key = al.get(i - 1).toString();
	CoberturaDetalladaServicio cd = (CoberturaDetalladaServicio) iCobDet.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayCobDetalle = "";
%>
<%=fb.hidden("key"+i,cd.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,cd.getStatus())%>
<%=fb.hidden("secuencia"+i,cd.getSecuencia())%>
<%=fb.hidden("articulo"+i,cd.getCodArticulo())%>
<%=fb.hidden("codClase"+i,cd.getCodClase())%>
<%=fb.hidden("codFlia"+i,cd.getCodFlia())%>
<%=fb.hidden("compania"+i,cd.getCompania())%>
<%=fb.hidden("procedimiento"+i,cd.getProcedimiento())%>
<%=fb.hidden("codUso"+i,cd.getCodUso())%>
<%=fb.hidden("otrosCargos"+i,cd.getCodOtros())%>
<%=fb.hidden("codigo"+i,cd.getCodigo())%>
<%=fb.hidden("codCdsProd"+i,cd.getCodCdsProd())%>
<%=fb.hidden("codCentroServicio"+i,cd.getCodCentroServicio())%>
<%=fb.hidden("centroServicio"+i,cd.getCentroServicio())%>
<%=fb.hidden("descripcion"+i,cd.getDescripcion())%>
<tr class="<%=color%>" align="center"<%=displayCobDetalle%>>
	<td><%=cd.getCodigo()%></td>
	<td align="left"><%=cd.getDescripcion()%></td>
	<td><%=fb.decBox("montoPac"+i,cd.getMontoPac(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMontoPac"+i,"P=%,M=$",cd.getTipoValPac(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoEmp"+i,cd.getMontoEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMontoEmp"+i,"P=%,M=$",cd.getTipoValEmp(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"Eliminar Cobertura Detalle")%>		</td>
</tr>
<%
}
%>
<tr class="TextRow02">
	<td colspan="7" align="right">
		Opciones de Guardar:
		<%--<%=fb.radio("saveOption","N")%>Crear Otro--%>
		<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
		<%=fb.radio("saveOption","C")%>Cerrar
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

	DetalleCoberturaConvenio cc = new DetalleCoberturaConvenio();
	cc.setEmpresa(request.getParameter("empresa"));
	cc.setTipoServicio(request.getParameter("tipoServicio"));
	cc.setSolicitud(request.getParameter("solicitud"));
	cc.setPacId(request.getParameter("pac_id"));
	cc.setCodigoPaciente(request.getParameter("cod_pac"));
	cc.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
	cc.setAdmision(request.getParameter("admision"));
	cc.setSecuenciaCob(request.getParameter("secuencia_cob"));
	cc.setSecuenciaSol1(request.getParameter("secuencia_sol1"));
	cc.setSecuenciaSol2(request.getParameter("secuencia_sol2"));

	int cobDetSize = 0;
	if (request.getParameter("cobDetSize") != null) cobDetSize = Integer.parseInt(request.getParameter("cobDetSize"));

	for (int i=1; i<=cobDetSize; i++)
	{
		CoberturaDetalladaServicio cd = new CoberturaDetalladaServicio();

		cd.setKey(request.getParameter("key"+i));
		cd.setSecuencia(request.getParameter("secuencia"+i));
		cd.setCodArticulo(request.getParameter("articulo"+i));
		cd.setCodClase(request.getParameter("codClase"+i));
		cd.setCodFlia(request.getParameter("codFlia"+i));
		cd.setCompania(request.getParameter("compania"+i));
		cd.setProcedimiento(request.getParameter("procedimiento"+i));
		cd.setCodUso(request.getParameter("codUso"+i));
		cd.setCodOtros(request.getParameter("otrosCargos"+i));
		cd.setCodigo(request.getParameter("codigo"+i));
		cd.setDescripcion(request.getParameter("descripcion"+i));
		cd.setTipoValPac(request.getParameter("tipoMontoPac"+i));
		cd.setMontoPac(request.getParameter("montoPac"+i));
		cd.setMontoEmp(request.getParameter("montoEmp"+i));
		cd.setTipoValEmp(request.getParameter("tipoMontoEmp"+i));
		cd.setSolicitud(request.getParameter("solicitud"));
		cd.setPacId(request.getParameter("pac_id"));
		cd.setCodigoPaciente(request.getParameter("cod_pac"));
		cd.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
		cd.setAdmision(request.getParameter("admision"));
		cd.setSecuenciaCob(request.getParameter("secuencia_cob"));
		cd.setSecuenciaSol1(request.getParameter("secuencia_sol1"));
		cd.setSecuenciaSol2(request.getParameter("secuencia_sol2"));
		cd.setEmpresa(request.getParameter("empresa"));
		cd.setCodCdsProd(request.getParameter("codCdsProd"+i));
		if (request.getParameter("codCentroServicio"+i) != null && !request.getParameter("codCentroServicio"+i).equals(""))
					cd.setCodCentroServicio(request.getParameter("codCentroServicio"+i));
		else cd.setCodCentroServicio(request.getParameter("cds"));

		if (request.getParameter("centroServicio"+i) != null && !request.getParameter("centroServicio"+i).equals(""))
		cd.setCentroServicio(request.getParameter("centroServicio"+i));
		else cd.setCentroServicio(request.getParameter("cds"));
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cd.getKey();
			cd.setStatus("D");//D=Delete action
			vCobDet.remove(cd.getCodigo());
		}
		else cd.setStatus(request.getParameter("status"+i));
		try
		{
			iCobDet.put(cd.getKey(),cd);
			cc.addCoberturaDet(cd);
		}
		catch(Exception ex)
		{
			System.err.println(ex.getMessage());
		}
	}//for Detalle
	if (!itemRemoved.equals(""))
	{
				iCobDet.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&empresa="+empresa+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&tipoServicio="+tipoServicio+"&cobDetLastLineNo="+cobDetLastLineNo+"&pac_id="+pac_id+"&cod_pac="+cod_pac+"&fecha_nacimiento="+fecha_nacimiento+"&admision="+admision+"&solicitud="+solicitud+"&secuencia_cob="+secuencia_cob+"&empresa="+empresa+"&secuencia_sol1="+secuencia_sol1+"&secuencia_sol2="+secuencia_sol2+"&cds="+cds);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&empresa="+empresa+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&tipoServicio="+tipoServicio+"&cobDetLastLineNo="+cobDetLastLineNo+"&pac_id="+pac_id+"&cod_pac="+cod_pac+"&fecha_nacimiento="+fecha_nacimiento+"&admision="+admision+"&solicitud="+solicitud+"&secuencia_cob="+secuencia_cob+"&secuencia_sol1="+secuencia_sol1+"&secuencia_sol2="+secuencia_sol2+"&cds="+cds);
		return;
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SBMgr.saveSol3(cc);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SBMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SBMgr.getErrMsg()%>');
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
	//if(parent.window.frames['iDetalle0'])
	//{
	//	parent.window.frames['iDetalle0'].showSelectBoxes(true);
	//}
	//parent.showSelectBoxes(true);
	parent.hidePopWin(true);


<%
	}
} else throw new Exception(SBMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	//if(parent.window.frames['iDetalle0'])
	//{
	//	parent.window.frames['iDetalle0'].showSelectBoxes(true);
	//}
	//parent.showSelectBoxes(true);




	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&empresa=<%=empresa%>&tipoCobertura=<%=tipoCobertura%>&cobertura=<%=cobertura%>&tipoServicio=<%=tipoServicio%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&admision=<%=admision%>&solicitud=<%=solicitud%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>&cds=<%=cds%>';

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>