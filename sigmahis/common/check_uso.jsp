<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<%@ page import="issi.admision.DetalleCoberturaConvenio"%>
<%@ page import="issi.admision.CoberturaDetalladaServicio"%>
<%@ page import="issi.admision.CitaEquipo"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iUso" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vUso" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCobCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExclCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCobDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExclDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPension" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPension" scope="session" class="java.util.Vector" />
<jsp:useBean id="htEquipo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htEquipoKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEqui" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEqui" scope="session" class="java.util.Vector" />
<jsp:useBean id="vCAUT" scope="session" class="java.util.Vector" />
<jsp:useBean id="vEvoDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPaqUso" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqUso" scope="session" class="java.util.Vector" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500021") || SecMgr.checkAccess(session.getId(),"500022") || SecMgr.checkAccess(session.getId(),"500023") || SecMgr.checkAccess(session.getId(),"500024"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int colLastLineNo = 0;
int insLastLineNo = 0;
int usoLastLineNo = 0;
int persLastLineNo = 0;
int honLastLineNo = 0;
int sopLastLineNo = 0;
int paqUsoLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
if (id == null) id = "";
if (request.getParameter("colLastLineNo") != null) colLastLineNo = Integer.parseInt(request.getParameter("colLastLineNo"));
if (request.getParameter("insLastLineNo") != null) insLastLineNo = Integer.parseInt(request.getParameter("insLastLineNo"));
if (request.getParameter("usoLastLineNo") != null) usoLastLineNo = Integer.parseInt(request.getParameter("usoLastLineNo"));
if (request.getParameter("persLastLineNo") != null) persLastLineNo = Integer.parseInt(request.getParameter("persLastLineNo"));
if (request.getParameter("honLastLineNo") != null) honLastLineNo = Integer.parseInt(request.getParameter("honLastLineNo"));
if (request.getParameter("sopLastLineNo") != null) sopLastLineNo = Integer.parseInt(request.getParameter("sopLastLineNo"));
if (request.getParameter("paqUsoLastLineNo") != null) paqUsoLastLineNo = Integer.parseInt(request.getParameter("paqUsoLastLineNo"));

//convenio_cobertura_centro, convenio_exclusion_centro
String tab = request.getParameter("tab");
String cTab = request.getParameter("cTab");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
String tipoCE = request.getParameter("tipoCE");
String ce = request.getParameter("ce");
String index = request.getParameter("index");
int ceCDLastLineNo = 0;
String tipoServicio = request.getParameter("tipoServicio");
//convenio solicitud de beneficio
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String secuencia_cob = request.getParameter("secuencia_cob");
String secuencia_sol1= request.getParameter("secuencia_sol1");
String secuencia_sol2= request.getParameter("secuencia_sol2");
String solicitud = request.getParameter("solicitud");
String tipoId = request.getParameter("tipoId");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String curIndex = request.getParameter("curIndex");
String cCama = request.getParameter("cCama");
String cHab = request.getParameter("cHab");
String idParam = request.getParameter("id");
String context = request.getParameter("context")==null?"":request.getParameter("context");
String noResultClose = request.getParameter("noResultClose")==null?"":request.getParameter("noResultClose");

if (tab == null) tab = "";
if (cTab == null) cTab = "";
if (empresa == null) empresa = "";
if (secuencia == null) secuencia = "";
if (tipoPoliza == null) tipoPoliza = "";
if (tipoPlan == null) tipoPlan = "";
if (planNo == null) planNo = "";
if (categoriaAdm == null) categoriaAdm = "";
if (tipoAdm == null) tipoAdm = "";
if (clasifAdm == null) clasifAdm = "";
if (tipoCE == null) tipoCE = "";
if (ce == null) ce = "";
if (index == null) index = "";
if (curIndex==null) curIndex = "0";
if (cCama==null) cCama= "";
if (cHab==null) cHab= "";
if (request.getParameter("ceCDLastLineNo") != null) ceCDLastLineNo = Integer.parseInt(request.getParameter("ceCDLastLineNo"));
if (tipoServicio == null) tipoServicio = "";
if (idParam == null) idParam = "";

//convenio_cobertura_detalle, pm_convenio_cobertura_detalle, convenio_exclusion_detalle, pm_convenio_exclusion_detalle
int ceDetLastLineNo = 0;
String centroServicio = request.getParameter("centroServicio");
String tipoCds = request.getParameter("tipoCds");
String inventarioSino = request.getParameter("inventarioSino");

if (request.getParameter("ceDetLastLineNo") != null) ceDetLastLineNo = Integer.parseInt(request.getParameter("ceDetLastLineNo"));
if (centroServicio == null) centroServicio = "";
if (tipoCds == null) tipoCds = "";
if (inventarioSino == null) inventarioSino = "";

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
  String codigo="",descripcion="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
		appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
   		codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
		appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	    descripcion = request.getParameter("descripcion");
  }
  if (request.getParameter("tipoServicio") != null && !request.getParameter("tipoServicio").trim().equals(""))
  {
		appendFilter += " and tipo_servicio = '"+request.getParameter("tipoServicio")+"'";
  }
  if (fp.equalsIgnoreCase("procedimiento"))
	{
		sql = "select codigo, descripcion, precio_venta, compania from tbl_sal_uso where compania="+(String) session.getAttribute("_companyId")+"  and estatus = 'A'"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	if (fp.equalsIgnoreCase("paquete_cargos"))
	{
		sql = "select codigo, descripcion, precio_venta, tipo_servicio , (select ts.descripcion from tbl_cds_tipo_servicio ts where codigo = tipo_servicio and compania = "+(String) session.getAttribute("_companyId")+") as tipo_servicio_desc from tbl_sal_uso where compania="+(String) session.getAttribute("_companyId")+"  and estatus = 'A'"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("convenio_exclusion_centro") || fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") || fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle") || fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
		sql = "select codigo, descripcion, precio_venta, compania from tbl_sal_uso where compania="+(String) session.getAttribute("_companyId")+"  and estatus = 'A' and tipo_servicio="+tipoServicio+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("SOP"))
	{
		sql = "SELECT codigo, descripcion, 0 precio_venta, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter+" and tipo_servicio in (select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and  param_name ='TP_SER_USOS_SOP') and estatus = 'A' ORDER BY descripcion";
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("edit_cita")||fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia")) 
	{
		sql = "SELECT codigo, descripcion, 0 precio_venta, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter+"  and estatus = 'A' ORDER BY descripcion";
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("cargos_aut")) 
	{
		sql = "SELECT codigo, descripcion, precio_venta, tipo_servicio,(select count(a.compania) from tbl_sal_cargos_automaticos a where a.compania = compania and a.codigo_item = codigo and a.tipo_referencia = 'US' and a.cama = '"+cCama+"' and a.habitacion = '"+cHab+"') tot FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter+"  and estatus = 'A' ORDER BY descripcion";
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("comodato")) 
	{
		sql = "SELECT codigo, descripcion, precio_venta, tipo_servicio FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter+"  and estatus = 'A' ORDER BY descripcion";
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("evo_param_det") || fp.equalsIgnoreCase("convenio_beneficio_new")|| fp.equalsIgnoreCase("adm_cargos_aut")) 
	{
		sql = "SELECT codigo, descripcion, precio_venta, tipo_servicio FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter+"  and estatus = 'A' ORDER BY descripcion";
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
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
  
  String jsContext = "window.opener.";
  if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Usos - '+document.title;

function doAction(){<% if(context.equalsIgnoreCase("preventPopupFrame")) { if (al.size()==1){%> setUso(0); <%}}%>
<%if(noResultClose.equals("1") && al.size() < 1){%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}%>
}

function setUso(cInd){ 
  <% if (fp.equalsIgnoreCase("cargos_aut")){%>
    if (eval('document.articulo.ignoreClick'+cInd) == null){
    window.opener.document.getElementById("codigo_item<%=curIndex%>").value= eval('document.articulo.codigo'+cInd).value;
    window.opener.document.getElementById("descripcion<%=curIndex%>").value= eval('document.articulo.descripcion'+cInd).value;
    window.opener.document.getElementById("tipo_servicio<%=curIndex%>").value= eval('document.articulo.tipo_servicio'+cInd).value;
	window.close();
	}
  <%}else if (fp.equalsIgnoreCase("adm_cargos_aut")){%>
    if (eval('document.articulo.ignoreClick'+cInd) == null){
    window.opener.document.getElementById("cod_ref<%=curIndex%>").value= eval('document.articulo.codigo'+cInd).value;
    window.opener.document.getElementById("descItem<%=curIndex%>").value= eval('document.articulo.descripcion'+cInd).value;
    window.opener.document.getElementById("uso_price<%=curIndex%>").value= eval('document.articulo.precio_venta'+cInd).value;
	window.close();
	}
  <%}else if (fp.equalsIgnoreCase("evo_param_det")){%>
	//if (eval('document.articulo.ignoreClick'+cInd) != null) return false;
	window.opener.document.getElementById("codigo_uso<%=curIndex%>").value= eval('document.articulo.codigo'+cInd).value;
    window.opener.document.getElementById("uso_desc<%=curIndex%>").value= eval('document.articulo.descripcion'+cInd).value;
    window.opener.document.getElementById("uso_price<%=curIndex%>").value= eval('document.articulo.precio_venta'+cInd).value;
	window.close();
  <%} else if (fp.equalsIgnoreCase("citas")){%>	
  <%} else if (fp.equalsIgnoreCase("convenio_beneficio_new")){%>
    <%=jsContext%>document.getElementById("codigo_detalle<%=curIndex%>").value = eval('document.articulo.codigo'+cInd).value;
    <%=jsContext%>document.getElementById("desc_detalle<%=curIndex%>").value = eval('document.articulo.descripcion'+cInd).value;  
  <%} else{%>
	window.opener.document.getElementById("referencia").value= eval('document.articulo.codigo'+cInd).value;
    window.opener.document.getElementById("desc_referencia").value= eval('document.articulo.descripcion'+cInd).value;
	window.close(); 
	<%}%>
    <%if(context.equalsIgnoreCase("preventPopupFrame")){%>
           <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
		<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE USOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
					<%
					fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
					<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
					<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
					<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
					<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>
					<%=fb.hidden("sopLastLineNo",""+sopLastLineNo)%>
					<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("cTab",cTab)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("secuencia",secuencia)%>
					<%=fb.hidden("tipoPoliza",tipoPoliza)%>
					<%=fb.hidden("tipoPlan",tipoPlan)%>
					<%=fb.hidden("planNo",planNo)%>
					<%=fb.hidden("categoriaAdm",categoriaAdm)%>
					<%=fb.hidden("tipoAdm",tipoAdm)%>
					<%=fb.hidden("clasifAdm",clasifAdm)%>
					<%=fb.hidden("tipoCE",tipoCE)%>
					<%=fb.hidden("ce",ce)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
					<%=fb.hidden("tipoServicio",tipoServicio)%>
					<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
					<%=fb.hidden("centroServicio",centroServicio)%>
					<%=fb.hidden("tipoCds",tipoCds)%>
					<%=fb.hidden("inventarioSino",inventarioSino)%>
					<%=fb.hidden("secuencia_cob",secuencia_cob)%>
					<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("cod_pac",cod_pac)%>
					<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
					<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
					<%=fb.hidden("solicitud",solicitud)%>
					<%=fb.hidden("tipoId",tipoId)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("curIndex",curIndex)%>
					<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
					<%=fb.hidden("context",context)%>
					<%=fb.hidden("noResultClose",noResultClose)%>
					<td width="50%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,30)%>
					</td>
					
					<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
			  </tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("articulo",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("nextVal",""+(nxtVal))%>
<%=fb.hidden("previousVal",""+(preVal))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>
<%=fb.hidden("sopLastLineNo",""+sopLastLineNo)%>
<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab",cTab)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("tipoCE",tipoCE)%>
<%=fb.hidden("ce",ce)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
<%=fb.hidden("centroServicio",centroServicio)%>
<%=fb.hidden("tipoCds",tipoCds)%>
<%=fb.hidden("inventarioSino",inventarioSino)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("tipoId",tipoId)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("curIndex",curIndex)%>
<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr align="right" class="TextPager" style="display:<%=(fp.equals("cargos_aut")||fp.equals("comodato")||fp.equals("evo_param_det")||fp.equals("convenio_beneficio_new")||fp.equals("adm_cargos_aut") )?"none":"block"%>">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%><%=fb.submit("addCont","Agregar y Continuar")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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

			<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="55%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<%if(!fp.equals("citas")){%><td width="10%"><cellbytelabel id="5">Precio</cellbytelabel></td><%}%>
					<td width="10%"><%if(fp.equalsIgnoreCase("procedimiento")||fp.equalsIgnoreCase("paquete_cargos")){%><cellbytelabel id="6">Cantidad</cellbytelabel><%}%>&nbsp;</td>
					<td width="10%"><%=((!fp.equals("cargos_aut")&&!fp.equals("comodato")&&!fp.equals("evo_param_det")&&!fp.equals("adm_cargos_aut")))?fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los uso listados!"):""%></td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				<%=fb.hidden("precio_venta"+i,CmnMgr.getFormattedDecimal(cdo.getColValue("precio_venta")))%>
				<%if(fp.equalsIgnoreCase("cargos_aut") || fp.equalsIgnoreCase("evo_param_det")|| fp.equalsIgnoreCase("paquete_cargos")||fp.equals("adm_cargos_aut")){%>
				<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
				<%=fb.hidden("tipo_servicio_desc"+i,cdo.getColValue("tipo_servicio_desc"))%>
				  <%if(cdo.getColValue("tot")!=null &&Integer.parseInt(cdo.getColValue("tot")) > 0||vCAUT.contains("US-"+cdo.getColValue("codigo"))||vEvoDet.contains(idParam+"-"+cdo.getColValue("codigo"))){%>
				     <%=fb.hidden("ignoreClick"+i,"S")%>
				  <%}%>
				<%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setUso(<%=i%>)">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<%if(!fp.equals("citas")){%><td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio_venta"))%></td><%}%>
					<td align="right"><%if(fp.equalsIgnoreCase("procedimiento")||fp.equalsIgnoreCase("paquete_cargos")){%>
					<%=(vPaqUso.contains(id+"-U-"+cdo.getColValue("codigo")))?"":fb.intBox("cantidad"+i,"1",false,false,(vUso.contains(cdo.getColValue("codigo"))||vPaqUso.contains(id+"-U-"+cdo.getColValue("codigo"))),5,2,null,null,"onChange=\"javascript:setChecked(this,document.articulo.check"+i+")\"")%>
					<%}%>&nbsp;</td>
					<td align="center">
					<%=((fp.equalsIgnoreCase("procedimiento") && vUso.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_cobertura_centro") && vCobCD.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_exclusion_centro") && vExclCD.contains(cdo.getColValue("codigo"))) || ( (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") ) && vCobDet.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_cobertura_solicitud") && vCobDet.contains(cdo.getColValue("codigo")))|| (fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle") ) && vExclDet.contains(cdo.getColValue("codigo"))) || ( (fp.equalsIgnoreCase("SOP") && vPension.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("edit_cita") && htEquipoKey.containsKey(cdo.getColValue("codigo")))|| (fp.equalsIgnoreCase("citas") && vEqui.contains(""+cdo.getColValue("codigo")))|| (fp.equalsIgnoreCase("paquete_cargos") && vPaqUso.contains(id+"-U-"+cdo.getColValue("codigo"))) )?"Elegido":((!fp.equalsIgnoreCase("cargos_aut")&&!fp.equalsIgnoreCase("comodato")&&!fp.equalsIgnoreCase("evo_param_det")&&!fp.equals("adm_cargos_aut"))?fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false): ((cdo.getColValue("tot")!=null &&Integer.parseInt(cdo.getColValue("tot")) > 0)||(vCAUT.contains("US-"+cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setUso("+i+")\"","") ) )%>
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
				<tr class="TextPager" style="display:<%=(fp.equals("cargos_aut")||fp.equals("comodato")||fp.equals("evo_param_det")||fp.equals("convenio_beneficio_new")||fp.equals("adm_cargos_aut"))?"none":"'inline'"%>">
					<td align="right">
						<%=fb.submit("save2","Guardar",true,false)%><%=fb.submit("addCont2","Agregar y Continuar")%>
						<%=fb.button("cancel2","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	if (fp.equalsIgnoreCase("procedimiento"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cod_uso",request.getParameter("codigo"+i));
				cdo.addColValue("observacion",request.getParameter("descripcion"+i));
				cdo.addColValue("cantidad",request.getParameter("cantidad"+i));

				usoLastLineNo++;

				String key = "";
				if (usoLastLineNo < 10) key = "00"+usoLastLineNo;
				else if (usoLastLineNo < 100) key = "0"+usoLastLineNo;
				else key = ""+usoLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iUso.put(key, cdo);
					vUso.add(request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//procedimiento
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalle cd = new CoberturaDetalle();

				cd.setSecuencia("0");
				cd.setCompania(request.getParameter("compania"+i));
				cd.setCodUso(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));

				ceCDLastLineNo++;

				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				cd.setKey(key);

				try
				{
					iCobCD.put(key, cd);
					vCobCD.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_centro
	else if (fp.equalsIgnoreCase("convenio_exclusion_centro"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				ExclusionDetalle ed = new ExclusionDetalle();

				ed.setSecuencia("0");
				ed.setCompania(request.getParameter("compania"+i));
				ed.setCodUso(request.getParameter("codigo"+i));
				ed.setCodigo(request.getParameter("codigo"+i));
				ed.setDescripcion(request.getParameter("descripcion"+i));

				ceCDLastLineNo++;

				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				ed.setKey(key);

				try
				{
					iExclCD.put(key, ed);
					vExclCD.add(ed.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_exclusion_centro
	else if (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") )
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalle cd = new CoberturaDetalle();

				cd.setSecuencia("0");
				cd.setCompania(request.getParameter("compania"+i));
				cd.setCodUso(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));

				ceDetLastLineNo++;

				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				cd.setKey(key);

				try
				{
					iCobDet.put(key, cd);
					vCobDet.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_detalle, pm_convenio_cobertura_detalle
	else if (fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				ExclusionDetalle ed = new ExclusionDetalle();

				ed.setSecuencia("0");
				ed.setCompania(request.getParameter("compania"+i));
				ed.setCodUso(request.getParameter("codigo"+i));
				ed.setCodigo(request.getParameter("codigo"+i));
				ed.setDescripcion(request.getParameter("descripcion"+i));

				ceDetLastLineNo++;

				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				ed.setKey(key);

				try
				{
					iExclDet.put(key, ed);
					vExclDet.add(ed.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_exclusion_detalle, pm_convenio_exclusion_detalle
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalladaServicio cd = new CoberturaDetalladaServicio();

				cd.setSecuencia("0");
				cd.setCompania(request.getParameter("compania"+i));
				cd.setCodUso(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));
				ceDetLastLineNo++;

				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				cd.setKey(key);

				try
				{
					iCobDet.put(key, cd);
					vCobDet.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_solicitud
	else if (fp.equalsIgnoreCase("SOP"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cod_uso",request.getParameter("codigo"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));

				sopLastLineNo++;

				String key = "";
				if (sopLastLineNo < 10) key = "00"+sopLastLineNo;
				else if (sopLastLineNo < 100) key = "0"+sopLastLineNo;
				else key = ""+sopLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iPension.put(key, cdo);
					vPension.add(request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_solicitud
	else if (fp.equalsIgnoreCase("edit_cita"))
	{
		int lineNo = htEquipo.size();
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CitaEquipo cdo = new CitaEquipo();

				cdo.setUsoCodigo(request.getParameter("codigo"+i));
				cdo.setUsoDesc(request.getParameter("descripcion"+i));
				cdo.setCompania((String) session.getAttribute("_companyId"));
				lineNo++;

				String key = "";
				if (lineNo< 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try
				{
					htEquipo.put(key, cdo);
					htEquipoKey.put(cdo.getUsoCodigo(), key);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//edit_cita
	else if (fp.equalsIgnoreCase("citas"))
	{
		int lineNo = iEqui.size();
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CitaEquipo cdo = new CitaEquipo();

				cdo.setUsoCodigo(request.getParameter("codigo"+i));
				cdo.setUsoDesc(request.getParameter("descripcion"+i));
				cdo.setCompania((String) session.getAttribute("_companyId"));
				cdo.setStatus("N");
				cdo.setKey(""+i,3);
				
				lineNo++;

				String key = "";
				if (lineNo< 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				
				key = cdo.getKey();

				try
				{
					iEqui.put(key, cdo);
					vEqui.addElement(cdo.getUsoCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//edit_cita
	
	else if (fp.equalsIgnoreCase("paquete_cargos"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cod_cargo",request.getParameter("codigo"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
				cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+i));
				cdo.addColValue("tipo_servicio_desc",request.getParameter("tipo_servicio_desc"+i));
				cdo.addColValue("tipo_cargo","U");
				
				cdo.addColValue("_usoCode",id+"-U-"+request.getParameter("codigo"+i));

				paqUsoLastLineNo++;

				String key = "";
				if (paqUsoLastLineNo < 10) key = "00"+paqUsoLastLineNo;
				else if (paqUsoLastLineNo < 100) key = "0"+paqUsoLastLineNo;
				else key = ""+paqUsoLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iPaqUso.put(key, cdo);
					vPaqUso.add(id+"-U-"+request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//paquete_cargos
	
	
	
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&sopLastLineNo="+sopLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&tipoId="+request.getParameter("tipoId")+"&codCita="+codCita+"&fechaCita="+fechaCita+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&context="+context+"&noResultClose="+noResultClose);
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&sopLastLineNo="+sopLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&tipoId="+request.getParameter("tipoId")+"&codCita="+codCita+"&fechaCita="+fechaCita+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&context="+context+"&noResultClose="+noResultClose);
		return;
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/check_uso.jsp?fp="+fp+"&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&sopLastLineNo="+sopLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&tipoId="+request.getParameter("tipoId")+"&codCita="+codCita+"&fechaCita="+fechaCita+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&context="+context+"&noResultClose="+noResultClose);

		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("procedimiento"))
	{
%>
	window.opener.location = '../admision/procedimientos_config.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&colLastLineNo=<%=colLastLineNo%>&insLastLineNo=<%=insLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&honLastLineNo=<%=honLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro"))
	{
%>
	window.opener.location = '../convenio/convenio_cobertura_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&index=<%=index%>&cobCDLastLineNo=<%=ceCDLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_exclusion_centro"))
	{
%>
	window.opener.location = '../convenio/convenio_exclusion_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&index=<%=index%>&exclCDLastLineNo=<%=ceCDLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_detalle"))
	{
%>
	window.opener.location = '../convenio/convenio_cobertura_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_cobertura_detalle"))
	{
%>
	window.opener.location = '../planmedico/pm_convenio_cobertura_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%	
	}
	else if (fp.equalsIgnoreCase("convenio_exclusion_detalle"))
	{
%>
	window.opener.location = '../convenio/convenio_exclusion_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
%>	
	window.opener.location = '../planmedico/pm_convenio_exclusion_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
	
<%	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
%>
	window.opener.location = '../admision/detalle_cobertura_tipo.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&tipoServicio=<%=tipoServicio%>&cds=<%=centroServicio%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoCds=<%=tipoCds%>&secuencia_cob=<%=secuencia_cob%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&solicitud=<%=solicitud%>&admision=<%=admision%>&fecha_nacimiento=<%=fecha_nacimiento%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&index=<%=index%>';
<%
	}
	else if (fp.equalsIgnoreCase("SOP"))
	{
%>
	window.opener.location = '../inventario/pension_x_tipo_cita.jsp?change=1&tipoId=<%=tipoId%>&sopLastLineNo=<%=sopLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("edit_cita")||fp.equalsIgnoreCase("citas"))
	{
%>
	window.opener.location = '../cita/edit_cita.jsp?mode=edit&change=1&tab=<%=tab%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>';
<%
	}
	else if (fp.equalsIgnoreCase("paquete_cargos"))
	{
%>
	window.opener.location = '../admision/paquete_cargo_config.jsp?change=1&tab=1&paqUsoLastLineNo=<%=paqUsoLastLineNo%>&mode=edit&comboId=<%=id%>';
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