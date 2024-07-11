<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCob" scope="session" class="java.util.Vector" />
<jsp:useBean id="vExcl" scope="session" class="java.util.Vector" />
<jsp:useBean id="vNotas" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su descripcion de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String factura = request.getParameter("factura");

String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String xCds = request.getParameter("xCds");//examen search parameter
String examen = request.getParameter("examen");
String cds = request.getParameter("cds");//expediente list parameter
String index = request.getParameter("index");

String key = "";

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (xCds == null) xCds = "";
if (factura == null) factura = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (!codigo.trim().equals("")) appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	if (!descripcion.trim().equals("")) appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	 appendFilter += " and compania_unorg="+(String) session.getAttribute("_companyId");
	
	if (fp.equalsIgnoreCase("DM") || fp.equalsIgnoreCase("RP") || fp.equalsIgnoreCase("US") || fp.equalsIgnoreCase("DUS")||fp.equalsIgnoreCase("RSP")||fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped")||fp.equalsIgnoreCase("escort")){
		if(!UserDet.getUserProfile().contains("0"))
		    if(session.getAttribute("_cds") != null) appendFilter += " and codigo in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))+")";
			else appendFilter += " and codigo in (-1)";

	}
	if (fp.equalsIgnoreCase("laboratorio"))
	{	/*
		En
		SAL310111 - Enfermeria
		SAL310151 - Triage
		SAL310150 - Medico
		SAL310152 - Interconsulta
		Es el mismo query
		sql = "select descripcion, codigo from cds_centro_servicio where estado in ('A', 'I') and reporta_a = 14 and codigo not in (113, 114, 115, 149)";
		*/
		//sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio where estado in ('A','I')  and INTERFAZ = 'LIS'"+appendFilter+" order by descripcion";
		sql = "select codigo, descripcion, estado,cod_centro_sol_lis centroSol from tbl_cds_centro_servicio where estado in ('A') and reporta_a  in(select codigo from tbl_cds_centro_servicio where interfaz='LIS') "+appendFilter+" order by descripcion";


		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+") ");
	}
	else if (fp.equalsIgnoreCase("imagenologia"))
	{
		/*
		En
		SAL310111 - Enfermeria
		SAL310151 - Triage
		SAL310150 - Medico
		SAL310152 - Interconsulta
		Es el mismo query
		sql = "select descripcion, codigo from cds_centro_servicio where reporta_a = 885 and estado = 'A'";
		*/
//		sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio where estado in ('A','I') and reporta_a=885 and codigo not in (113,114,115,149)"+appendFilter+" order by descripcion";
		//sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio where INTERFAZ = 'RIS' "+appendFilter+" order by descripcion";

		sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio where estado in ('A') and reporta_a  in(select codigo from tbl_cds_centro_servicio where interfaz='RIS') "+appendFilter+" order by descripcion";

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
//		rowCount = CmnMgr.getCount("select count(*) from tbl_cds_centro_servicio where estado in ('A','I') and reporta_a=885 and codigo not in (113,114,115,149)"+appendFilter+"");

		rowCount = CmnMgr.getCount("select count(*) from ("+sql+") ");
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura")  || fp.equalsIgnoreCase("convenio_exclusion") || fp.equalsIgnoreCase("pm_convenio_exclusion") || fp.equalsIgnoreCase("convenio_cobertura_solicitud")|| fp.equalsIgnoreCase("notas_ajustes")|| fp.equalsIgnoreCase("cargo_tardio")|| fp.equalsIgnoreCase("ajusteCargo") || fp.equalsIgnoreCase("CTF"))//CTF = cargo tardio filtro
	{
		String v = "";
		if ( (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura")) && vCob.size() > 0)
		{
			v = vCob.toString().replaceAll(", ","','").replaceAll(",''","");
			v = "'"+v.substring(1,v.length() - 1)+"'";
			v = v.replaceAll("C","");
			appendFilter += " and ''||codigo not in ("+v+")";
		}
		else if ( (fp.equalsIgnoreCase("convenio_exclusion") || fp.equalsIgnoreCase("pm_convenio_exclusion")) && vExcl.size() > 0)
		{
			v = vExcl.toString().replaceAll(", ","','").replaceAll(",''","");
			v = "'"+v.substring(1,v.length() - 1)+"'";
			v = v.replaceAll("C","");
			appendFilter += " and ''||codigo not in ("+v+")";
		}
		else if (fp.equalsIgnoreCase("notas_ajustes") && vNotas.size() > 0)
		{
			v = vNotas.toString().replaceAll(", ","','").replaceAll(",''","");
			v = "'"+v.substring(1,v.length() - 1)+"'";
			v = v.replaceAll("C","");
			appendFilter += " and ''||codigo not in ("+v+")";
			
		}

		if(factura.equals("")){
			sql = "select codigo, descripcion, tipo_cds, reporta_a, nvl(incremento,0) incremento, nvl(tipo_incremento, ' ') tipo_incremento, 'N' facturado from tbl_cds_centro_servicio a where estado = 'A'  "+appendFilter+" order by descripcion";
		} else {
			sql = "select codigo, descripcion, tipo_cds, reporta_a, nvl(incremento,0) incremento, nvl(tipo_incremento, ' ') tipo_incremento, decode(a.codigo, b.centro_servicio, 'S', 'N') facturado from tbl_cds_centro_servicio a, (select distinct fac_codigo, centro_servicio from tbl_fac_detalle_factura where fac_codigo = '"+factura+"') b where estado = 'A'  "+appendFilter+" and a.codigo = b.centro_servicio(+) order by decode(a.codigo, b.centro_servicio, 'S', 'N') desc, descripcion";
		}

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("DM") || fp.equalsIgnoreCase("RP") || fp.equalsIgnoreCase("US") || fp.equalsIgnoreCase("DUS"))
	{
		//DM = devolucion de materiales paciente , RP = requisiciones de pacientes urgencias
		//US = REQUISICION MAT. USOS SALAS;  DUS = DEVOLUCION MAT. USOS SALAS

		sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio where estado = 'A' and origen = 'S' and compania_unorg = "+(String) session.getAttribute("_companyId") + appendFilter+" order by descripcion";

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("RSP"))//RSP = RECHAZAR SOLICITUDES DE MATERIALES PARA PACIENTES
	{
		sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio a where estado = 'A' and (origen = 'S' or codigo in (840,12)) and compania_unorg = "+(String) session.getAttribute("_companyId")+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from ("+sql+")");

	}
	else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped"))
	{
		sql = "select codigo, descripcion, estado from tbl_cds_centro_servicio where reporta_a  in (select codigo from tbl_cds_centro_servicio where interfaz in ('RIS','LIS')) and estado='A'"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from tbl_cds_centro_servicio where reporta_a  in (select codigo from tbl_cds_centro_servicio where interfaz in ('RIS','LIS'))  and estado='A'"+appendFilter+"");
	}
	else if (fp.equalsIgnoreCase("cds_solicitud_ima"))
	{
		sql = "select codigo, descripcion, estado, reporta_a, tipo_cds from tbl_cds_centro_servicio where reporta_a  in (select codigo from tbl_cds_centro_servicio where interfaz='RIS') and estado='A' "+appendFilter+" order by 2";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from tbl_cds_centro_servicio where reporta_a  in (select codigo from tbl_cds_centro_servicio where interfaz='RIS') and estado='A'"+appendFilter+"");
	} else if (fp.equalsIgnoreCase("procedimiento") || fp.equalsIgnoreCase("procedimientos"))
	{
		sql = "select codigo, descripcion, estado, reporta_a, tipo_cds from tbl_cds_centro_servicio where estado='A'"+appendFilter+" order by 2";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from tbl_cds_centro_servicio where estado='A'"+appendFilter+"");
	}
	else if (fp.equalsIgnoreCase("saldoIni"))
	{
		sql = "select codigo, descripcion, estado, reporta_a, tipo_cds from tbl_cds_centro_servicio where tipo_cds ='T' and estado='A'"+appendFilter+" order by 2";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("escort")||fp.equalsIgnoreCase("handover")||fp.equalsIgnoreCase("nosocomial_bundle"))
	{
		sql = "select codigo, descripcion from tbl_cds_centro_servicio where estado = ('A') "+appendFilter+" order by descripcion";

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) as count from ("+sql+")");
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if((fp.equalsIgnoreCase("laboratorio")) || (fp.equalsIgnoreCase("imagenologia"))){%>
document.title = 'Examenes - '+document.title;
<%}else if (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura") || fp.equalsIgnoreCase("convenio_exclusion") || fp.equalsIgnoreCase("pm_convenio_exclusion")){%>
document.title = 'Convenio- '+document.title;
<%}else if (fp.equalsIgnoreCase("notas_ajustes")){%>
document.title = 'Facturacion Notas Ajuste- '+document.title;
<%}else{%>
document.title = 'Selección de Centro de Servicio - '+document.title;
<%}%>

function doAction()
{
<%
if (fp.equalsIgnoreCase("laboratorio") || fp.equalsIgnoreCase("imagenologia"))
{
	if (xCds != null && !xCds.trim().equals("") && examen != null)
	{
%>
	 document.CentroServicio.submit();
<%
	}
}
%>
}

function setSearch(k)
{
	var id = eval('document.CentroServicio.codigo'+k).value;
	var descripcion = eval('document.CentroServicio.descripcion'+k).value;
	var cdsSol = eval('document.CentroServicio.centroSol'+k).value;
<%
if((fp.equalsIgnoreCase("laboratorio")))
{
%>
	if(cdsSol !='')
	{
		document.CentroServicio.xCds.value = id;
		document.CentroServicio.xCdsDesc.value = descripcion;

		window.opener.document.form001.xCds.value = id;
		window.opener.document.form001.xCdsDesc.value = descripcion;
		document.CentroServicio.submit();
	}else
	{
		alert('Código de Centro para hacer la Solicitud de Laboratorio no se encuentra. Verificar los parámetros..., VERIFIQUE!');
	}
<%
}
if((fp.equalsIgnoreCase("imagenologia")))
{
%>
	document.CentroServicio.xCds.value = id;
	document.CentroServicio.xCdsDesc.value = descripcion;
	window.opener.document.form001.xCds.value = id;
	window.opener.document.form001.xCdsDesc.value = descripcion;
	document.CentroServicio.submit();
<%
}
else if (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura"))
{
%>
	window.opener.document.form0.tipoServicio<%=index%>.value = '';
	window.opener.document.form0.centroServicio<%=index%>.value = id;
	window.opener.document.form0.codigo<%=index%>.value = id;
	window.opener.document.form0.descripcion<%=index%>.value = descripcion;
	window.opener.document.form0.tipoCobertura<%=index%>.value = 'C';
	window.opener.doSubmit(0,'');
	window.close();
<%
}
else if (fp.equalsIgnoreCase("convenio_exclusion") || fp.equalsIgnoreCase("pm_convenio_exclusion"))
{
%>
	window.opener.document.form1.tipoServicio<%=index%>.value = '';
	window.opener.document.form1.centroServicio<%=index%>.value = id;
	window.opener.document.form1.codigo<%=index%>.value = id;
	window.opener.document.form1.descripcion<%=index%>.value = descripcion;
	window.opener.document.form1.tipoExclusion<%=index%>.value = 'C';
	window.opener.doSubmit(1,'');
	window.close();
<%
}
else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
{
%>
	window.opener.document.form0.tipoServicio<%=index%>.value = '';
	window.opener.document.form0.centroServicio<%=index%>.value = id;
	window.opener.document.form0.codigo<%=index%>.value = id;
	window.opener.document.form0.descripcion<%=index%>.value = descripcion;
	window.opener.document.form0.tipoCobertura<%=index%>.value = 'C';
	//window.opener.doSubmit(0,'');
	window.close();

<%
}
else if (fp.equalsIgnoreCase("notas_ajustes"))
{
%>
	window.opener.document.form1.v_codigo<%=index%>.value = id;
	window.opener.document.form1.name_code<%=index%>.value = descripcion;
	window.close();

<%
}
else if (fp.equalsIgnoreCase("ajusteCargo"))
{
%>
	window.opener.document.form1.centro<%=index%>.value = id;
	window.opener.document.form1.nCentro<%=index%>.value = descripcion;
	window.opener.document.form1.tipoServicio<%=index%>.value = '';
	window.opener.document.form1.nServicio<%=index%>.value = '';
	window.close();
<%
}
else if (fp.equalsIgnoreCase("cargo_tardio"))
{
%>
	window.opener.document.form0.centro.value = id;
	window.opener.document.form0.name_centro.value = descripcion;
	window.close();

<%
}
else if (fp.equalsIgnoreCase("CTF"))
{
%>
	window.opener.document.search01.centro.value = id;
	window.opener.document.search01.name_centro.value = descripcion;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("RSP"))
{
%>
	window.opener.document.search00.centro.value = id;
	window.opener.document.search00.name_centro.value = descripcion;
	window.close();

<%
}
else if (fp.equalsIgnoreCase("RP"))//requisiciones de pacientes
{
%>
	window.opener.document.search02.area.value = id;
	window.opener.document.search02.descArea.value = descripcion;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("DM"))
{
%>
	window.opener.document.devolucion.codigo_sala.value = id;
	window.opener.document.devolucion.desc_codigo_sala.value = descripcion;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("US") || fp.equalsIgnoreCase("DUS"))
{
%>
	var cod_almacen='';
	var desc ='';

	<%if (fp.equalsIgnoreCase("US")){%>
	window.opener.document.requisicion.cod_centro.value = id;
	window.opener.document.requisicion.desc_unidad_adm.value = descripcion;

	window.opener.document.requisicion.u_codigo_almacen.value = cod_almacen;
	window.opener.document.requisicion.codigo_almacen.value = cod_almacen;
	//window.opener.document.requisicion.desc_codigo_almacen.value = desc;
	<%}else{%>
	window.opener.document.devolucion.cod_centro.value = id;
	window.opener.document.devolucion.desc_centro.value = descripcion;

	window.opener.document.devolucion.codigo_almacen.value = cod_almacen;
	window.opener.document.devolucion.desc_codigo_almacen.value = desc;

	window.opener.document.devolucion.change.value = "1";
	window.opener.document.devolucion.action.value = "del";
	window.opener.document.devolucion.mode.value = "<%=mode%>";
	window.opener.document.devolucion.clearHT.value = "S";
	window.opener.document.devolucion.fg.value = "<%=fg%>";
	window.opener.document.devolucion.submit();
	<%}%>


	window.close();
<%
}
else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped"))
{
%>
	window.opener.document.form0.codCentroServicio.value = id;
	window.opener.document.form0.centroServicioDesc.value = descripcion;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
	window.opener.document.form0.codCentroServicio.value = id;
	window.opener.document.form0.centroServicioDesc.value = descripcion;
	window.opener.document.form0.centroServicioReportaA.value = eval('document.CentroServicio.reporta_a'+k).value;
	window.opener.document.form0.centroServicioTipoCds.value = eval('document.CentroServicio.tipo_cds'+k).value;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("procedimiento"))
{
%>
	window.opener.document.form0.cod_cds<%=index%>.value = id;
	window.opener.document.form0.desc_cds<%=index%>.value = descripcion;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("procedimientos"))
{
%>
	window.opener.document.form7.ref_code<%=index%>.value = id;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("saldoIni"))
{
%>
	window.opener.document.form1.id_cliente.value = id;
	if(window.opener.document.form1.id_cliente_view)window.opener.document.form1.id_cliente_view.value = id;
	window.opener.document.form1.nombre.value = descripcion;
	window.close();
<%
}else if ( fp.equalsIgnoreCase("escort") ) {
%>
    window.opener.document.form0.toCDS.value = id;
	window.opener.document.form0.toCdsDesc.value = descripcion;
	window.close()
<%
}else if ( fp.equalsIgnoreCase("handover") ) {
%>  
    <%if(fg.trim().equalsIgnoreCase("recibe")){%>
    if(window.opener.document.form0.centro_servicio_recibe) window.opener.document.form0.centro_servicio_recibe.value = id;
	if(window.opener.document.form0.centro_servicio_recibe_desc)window.opener.document.form0.centro_servicio_recibe_desc.value = descripcion;
    <%} else if (fg.trim().equalsIgnoreCase("reporta")){%>
      if(window.opener.document.form0.cds_persona_que_reporta) {
        window.opener.document.form0.cds_persona_que_reporta.value = id + ' - ' +descripcion;
      }
    <%}%>
	window.close()
<%
}else if ( fp.equalsIgnoreCase("nosocomial_bundle") ) {
%>
    if(window.opener.document.form0.area) window.opener.document.form0.area.value = id;
	if(window.opener.document.form0.area_desc)window.opener.document.form0.area_desc.value = descripcion;
	window.close()
<%
}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("xCds",xCds)%>
<%=fb.hidden("examen",examen)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("factura",factura)%>

				<tr class="TextFilter">
					<td width="50%">
						<cellbytelabel id="1">C&oacute;digo</cellbytelabel>
						<%=fb.textBox("codigo","",false,false,false,20)%>
					</td>
					<td width="50%">
						<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("descripcion","",false,false,false,40)%>
						<%=fb.submit("go","Ir")%>
					</td>
				</tr>
<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("CentroServicio",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("xCds",xCds)%>
<%=fb.hidden("xCdsDesc","")%>
<%=fb.hidden("examen",examen)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("codigo","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("factura",factura)%>

	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<%=fb.hidden("cod","")%>
<%=fb.hidden("descrip","")%>

<table align="center" width="100%" cellpadding="1" cellspacing="1">
<tr class="TextHeader" align="center">
<td width="30%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
<td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	String facturado ="N";
	if (i % 2 == 0) color = "TextRow01";
	if(cdo.getColValue("facturado")!=null && cdo.getColValue("facturado").equals("S")) facturado = "S";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("reporta_a"+i,cdo.getColValue("reporta_a"))%>
				<%=fb.hidden("tipo_cds"+i,cdo.getColValue("tipo_cds"))%>
				<%=fb.hidden("centroSol"+i,cdo.getColValue("centroSol"))%>
				<%=fb.hidden("cod_centro_sol_ris"+i,cdo.getColValue("cod_centro_sol_ris"))%>
				<%if(fp != null && fp.trim().equals("ajusteCargo")){%>
				<%//=fb.hidden("tipo_cds"+i,cdo.getColValue("tipo_cds"))%>
				<%//=fb.hidden("reporta_a"+i,cdo.getColValue("reporta_a"))%>
				<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
				<%=fb.hidden("tipoIncre"+i,cdo.getColValue("tipo_incremento"))%>

				<%}%>

				<tr class="<%=color%>" onClick="javascript:setSearch(<%=i%>)" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
					<td align="right">
					
					<%if(facturado.equals("S")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
					
					<%=cdo.getColValue("codigo")%>
					
					<%if(facturado.equals("S")){%>&nbsp;&nbsp;</label></label><%}%>
					 </td>
					<td><%if(facturado.equals("S")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
					
					<%=cdo.getColValue("descripcion")%>
					
					<%if(facturado.equals("S")){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
				</tr>
<%
}
%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&id="+id+"&seccion="+seccion+"&pacId="+pacId+"&noAdmision="+noAdmision+"&xCds="+xCds+"&examen="+examen+"&index="+index+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValsearchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&cds="+cds+"&factura="+request.getParameter("factura"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&id="+id+"&seccion="+seccion+"&pacId="+pacId+"&noAdmision="+noAdmision+"&xCds="+xCds+"&examen="+examen+"&index="+index+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValsearchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&cds="+cds+"&factura="+request.getParameter("factura"));
		return;
	}

	if (fp.equalsIgnoreCase("laboratorio") || fp.equalsIgnoreCase("imagenologia"))
	{
		if (examen != null && !examen.trim().equals("")) appendFilter = " and upper(coalesce(a.observacion, a.descripcion)) like '%"+examen+"%'";
		/*
		SAL310111 - Enfermeria
		sql = "select a.codigo as codigo, coalesce(a.observacion,a.descripcion) as descripcion, '1' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and b.usado_por_cu='S' and a.codigo=b.cod_procedimiento order by 2";
		SAL310151 - Triage
		sql = "select decode(a.cod_cds, 14, 113, cod_cds) as codigo, coalesce(a.observacion,a.descripcion) as descripcion, '1' as tipoOrden from tbl_cds_procedimiento a where a.cod_cds=decode("+xCds+",113,14,"+xCds+") "+appendFilter+" and a.precio is not null order by coalesce(a.observacion,a.descripcion)";
		SAL310110 - Medico
		sql = "select a.codigo as codigo, coalesce(a.observacion,a.descripcion) as descripcion, '1' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and b.usado_por_cu='S' and a.codigo=b.cod_procedimiento and a.precio is not null order by 2";
		*/
		if (fp.equalsIgnoreCase("imagenologia"))
		{
			//sql = "select a.codigo as codigo, coalesce(a.observacion,a.descripcion) as descripcion, 'N' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and b.usado_por_cu='S' and a.codigo=b.cod_procedimiento order by 2";
			//sal310150
			sql = "select z.*, rownum as secOrden from (select a.codigo, coalesce(a.observacion,a.descripcion)||' ('||a.codigo||')' as descripcion, 0 as producto, b.cod_centro_servicio as centroServicio, a.cod_cds as procedimientoCds, 'H' as prioridad, 'N' as seleccionado, 1 as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo=b.cod_procedimiento and b.cod_centro_servicio="+xCds+appendFilter+" /* and b.usado_por_cu='N'*/ and a.precio is not null and a.estado='A' union select cpt, descripcion||' ('||cpt||')', codigo, cod_centro_servicio, cod_centro_servicio as procedimientoCds, 'H' as prioridad, 'N' as seleccionado, 1 as tipoOrden from tbl_cds_producto_x_cds where cod_centro_servicio="+xCds+((examen != null && !examen.trim().equals(""))?" and upper(descripcion||' ('||cpt||')') like '%"+examen+"%'":"")+" and cpt is not null and not exists (SELECT 1 FROM tbl_CDS_PROCEDIMIENTO A, tbl_CDS_PROCEDIMIENTO_X_CDS B WHERE  A.CODIGO = B.COD_PROCEDIMIENTO AND B.COD_CENTRO_SERVICIO = "+xCds+" AND B.USADO_POR_CU = 'N' and a.precio is not null  and a.codigo = cpt and a.estado = 'A') order by 2) z";
		}
		else if (fp.equalsIgnoreCase("laboratorio"))
		{
			sql = "select decode(cod_centro_sol_lis,null,' ',cod_centro_sol_lis) as cod_centro_sol_lab from tbl_cds_centro_servicio where  codigo="+cds;
			System.out.println("SQL = "+sql);
			al = SQLMgr.getDataList(sql);
			CommonDataObject cdo = new CommonDataObject();
			if (al.size() == 0) throw new Exception("Código de Centro para hacer la Solicitud de Laboratorio no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			else if (al.size() == 1)
			{
				cdo = (CommonDataObject) al.get(0);
				if (cdo.getColValue("cod_centro_sol_lab").trim().equals("")) throw new Exception("Código de Centro para hacer la Solicitud de Laboratorio no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			}
			else throw new Exception("Código de Centro para hacer la solicitud de Laboratorio está duplicado. Verificar los parámetros..., VERIFIQUE!");

			//if (request.getParameter("centroSol") == null || request.getParameter("centroSol").trim().equals("")) throw new Exception("Código de Centro para hacer la Solicitud de Laboratorio no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			//else throw new Exception("Código de Centro para hacer la solicitud de Laboratorio está duplicado. Verificar los parámetros..., VERIFIQUE!");

			//sql = "select a.codigo as codigo, coalesce(a.observacion,a.descripcion) as descripcion, 'N' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and b.usado_por_cu='S' and a.precio is not null and a.codigo=b.cod_procedimiento order by 2";
			//sal310150

			sql = "select a.codigo, /*coalesce(a.observacion,a.descripcion)*/ nvl(b.descripcion_corto,' ') as descripcion, 'N' as seleccionado, "+cdo.getColValue("cod_centro_sol_lab")+" as centroServicio, 1 as tipoOrden, rownum as secOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo=b.cod_procedimiento and b.cod_centro_servicio="+xCds+appendFilter+" /* ya no se utilizará los centros no son los mismos  and b.usado_por_cu='S' */ and a.precio is not null order by 2";
		}
		/*
		SAL310111 - Enfermeria
		sql = "select a.codigo as codigo, b.cod_centro_servicio as procedimiento, getCodCentroSolLab("+(String) session.getAttribute("_companyId")+", a.codigo) as centroServicio, coalesce(a.observacion,a.descripcion) as descripcion, '1' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and b.usado_por_cu='S' and a.codigo=b.cod_procedimiento order by 2";
		SAL310151 - Triage
		sql = "select a.codigo as codigo, b.cod_centro_servicio as procedimiento, getCodCentroSolLab("+(String) session.getAttribute("_companyId")+", a.codigo) as centroServicio, coalesce(a.observacion,a.descripcion) as descripcion, '1' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and a.codigo=b.cod_procedimiento order by 2";
		SAL310150 - Medico
		sql = "select a.codigo as codigo, b.cod_centro_servicio as procedimiento, getCodCentroSolLab("+(String) session.getAttribute("_companyId")+", a.codigo) as centroServicio, coalesce(a.observacion,a.descripcion) as descripcion, '1' as tipoOrden from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where b.cod_centro_servicio="+xCds+appendFilter+" and b.usado_por_cu='S' and a.codigo=b.cod_procedimiento and a.precio is not null order by 2";
		*/
		System.out.println("SQL = "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleOrdenMed.class);
		HashDet.clear();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			DetalleOrdenMed dom = (DetalleOrdenMed) al.get(i-1);

			dom.setKey(key);
			dom.setCheck("N");

			HashDet.put(key,dom);
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
if (fp.equalsIgnoreCase("imagenologia") || fp.equalsIgnoreCase("laboratorio"))
{
%>
	window.opener.setFrameSrc('iExaLab','../expediente/exp_examenes_list.jsp?fp=<%=fp%>&mode=<%=seccion%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&xCds=<%=xCds%>&cds=<%=cds%>');
<%
}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>