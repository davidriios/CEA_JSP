<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<%@ page import="issi.admision.CoberturaDetalladaServicio"%>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iIns" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vIns" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCobCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExclCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCobDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExclDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPaqInsumo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqInsumo" scope="session" class="java.util.Vector" />
<jsp:useBean id="iArtMapping" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vArtMapping" scope="session" class="java.util.Vector"/>
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
int paqInsumoLastLineNo = 0;
int artLastLineNoMapping = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
if (request.getParameter("colLastLineNo") != null) colLastLineNo = Integer.parseInt(request.getParameter("colLastLineNo"));
if (request.getParameter("insLastLineNo") != null) insLastLineNo = Integer.parseInt(request.getParameter("insLastLineNo"));
if (request.getParameter("usoLastLineNo") != null) usoLastLineNo = Integer.parseInt(request.getParameter("usoLastLineNo"));
if (request.getParameter("persLastLineNo") != null) persLastLineNo = Integer.parseInt(request.getParameter("persLastLineNo"));
if (request.getParameter("honLastLineNo") != null) honLastLineNo = Integer.parseInt(request.getParameter("honLastLineNo"));
if (request.getParameter("paqInsumoLastLineNo") != null) paqInsumoLastLineNo = Integer.parseInt(request.getParameter("paqInsumoLastLineNo"));
if (request.getParameter("artLastLineNoMapping") != null) artLastLineNoMapping = Integer.parseInt(request.getParameter("artLastLineNoMapping"));

//convenio_cobertura_centro, pm_convenio_cobertura_centro, convenio_exclusion_centro, pm_convenio_exclusion_centro
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
String classCode = request.getParameter("classCode");
String familyCode = request.getParameter("familyCode");
String subClass = request.getParameter("subclase");
String context = request.getParameter("context")==null?"":request.getParameter("context");
String noResultClose = request.getParameter("noResultClose")==null?"":request.getParameter("noResultClose");
String revenueId = request.getParameter("revenueId")==null?"":request.getParameter("revenueId");
String cds = request.getParameter("cds")==null?"":request.getParameter("cds");

if (id == null) id = "";
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
if (request.getParameter("ceCDLastLineNo") != null) ceCDLastLineNo = Integer.parseInt(request.getParameter("ceCDLastLineNo"));
if (tipoServicio == null) tipoServicio = "";
if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";
if (subClass == null) subClass = "";

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
  String codigo ="",descripcion ="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
	appendFilter += " and a.cod_articulo = "+request.getParameter("codigo");
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
	appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  
  if (request.getParameter("familyCode") != null && !request.getParameter("familyCode").trim().equals(""))
  {
	appendFilter += " and a.cod_flia = "+request.getParameter("familyCode");
    familyCode = request.getParameter("familyCode");
  }
  
  if (request.getParameter("classCode") != null && !request.getParameter("classCode").trim().equals(""))
  {
	appendFilter += " and a.cod_clase = "+request.getParameter("classCode");
    classCode = request.getParameter("classCode");
  } 
  
  if (request.getParameter("subclase") != null && !request.getParameter("subclase").trim().equals(""))
  {
	appendFilter += " and a.cod_subclase = "+request.getParameter("subclase");
    subClass = request.getParameter("subclase");
  }
  
 

	if (fp.equalsIgnoreCase("procedimiento"))
	{	String almacenSOP = ResourceBundle.getBundle("issi").getString("almacenSOP");
		appendFilter +=" and i.codigo_almacen="+almacenSOP;
		sql = "SELECT a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_subclase, a.cod_articulo as itemCode, a.descripcion as item, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, a.compania FROM tbl_inv_articulo a,tbl_inv_inventario i WHERE a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo and a.compania =i.compania and a.venta_sino='S' order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("convenio_exclusion_centro") || fp.equalsIgnoreCase("convenio_cobertura_detalle")  || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") || fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle") || fp.equalsIgnoreCase("convenio_cobertura_solicitud")|| fp.equalsIgnoreCase("convenio_beneficio_new"))
	{
		sql = "select a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_subclase, a.cod_articulo as itemCode, a.descripcion as item, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, a.compania from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and b.tipo_servicio='"+tipoServicio+"' and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.venta_sino='S' order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and b.tipo_servicio='"+tipoServicio+"' and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);
	}
	else if (fp.equalsIgnoreCase("MAPPING_CPT"))
	{
		sql = "select a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_subclase, a.cod_articulo as itemCode, a.descripcion as item, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, a.compania from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia  and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.venta_sino='S' order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and b.tipo_servicio='"+tipoServicio+"' and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);
	} else if (fp.equalsIgnoreCase("descuento"))
	{
		sql = "select a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_subclase, a.cod_articulo as itemCode, a.descripcion as item, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, a.compania from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.venta_sino='S' and a.estado = 'A' and a.replicado_far='N' and a.precio_venta > 0 order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and a.venta_sino='S' and a.estado = 'A' and a.precio_venta > 0 and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);
	}else
	if (fp.equalsIgnoreCase("paquete_cargos"))
	{	
		sql = "select a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as item, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as code, a.compania, b.tipo_servicio, (select ts.descripcion from tbl_cds_tipo_servicio ts where codigo = b.tipo_servicio and compania = "+(String) session.getAttribute("_companyId")+") as tipo_servicio_desc ,'' as cod_subclase from tbl_inv_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.venta_sino='S' and a.replicado_far='N' order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
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
document.title = 'Articulos - '+document.title;
function doAction(){<% if(context.equalsIgnoreCase("preventPopupFrame")) { if (al.size()==1){%> setArticulo(0); <%}}%>
<%if(noResultClose.equals("1") && al.size() < 1){%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}%>
}

function setArticulo(i){
   <% if (fp.equalsIgnoreCase("convenio_beneficio_new")){%>
    <% if (fp.equalsIgnoreCase("convenio_beneficio_new")){%>
    <%=jsContext%>document.getElementById("codigo_detalle<%=index%>").value = eval('document.articulo.codigo_articulo'+i).value;
    <%=jsContext%>document.getElementById("desc_detalle<%=index%>").value = eval('document.articulo.item'+i).value;  
  <%}%>

    <%if(context.equalsIgnoreCase("preventPopupFrame")){%>
       <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
    <%}else{%>
    window.close();
    <%}}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE ARTICULOS"></jsp:param>
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
					<%=fb.hidden("artLastLineNoMapping",""+artLastLineNoMapping)%>
					<%=fb.hidden("revenueId",""+revenueId)%>
					<%=fb.hidden("cds",""+cds)%>
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
					<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
					<%=fb.hidden("centroServicio",centroServicio)%>
					<%=fb.hidden("tipoCds",tipoCds)%>
					<%=fb.hidden("inventarioSino",inventarioSino)%>
					<%=fb.hidden("solicitud",solicitud)%>
					<%=fb.hidden("secuencia_cob",secuencia_cob)%>
					<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("cod_pac",cod_pac)%>
					<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
					<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
                    <%=fb.hidden("context",context)%>
                    <%=fb.hidden("noResultClose",noResultClose)%>

					<td width="100%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,10,null,null,null)%>
					<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
					
					Familia
					<%=fb.select("familyCode","","",false,false,0,null,"width:150px","onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
					<script language="javascript">
					loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
					</script>
					Clase
					<%=fb.select("classCode","","",false,false,0,null,"width:150px",null)%>
					<script language="javascript">
					loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search01.familyCode.value"%>,'KEY_COL','T');
					</script>
					Sub-clase
					<%=fb.textBox("subclase",subClass,false,false,false,5,null,null,null)%>
					
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
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
<%=fb.hidden("classCode",classCode)%>
<%=fb.hidden("familyCode",familyCode)%>
<%=fb.hidden("subClass",subClass)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>

	<tr<%=fp.equalsIgnoreCase("convenio_beneficio_new")?" style='display:none;'":""%>>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%><%if(fp.equalsIgnoreCase("procedimiento")||fp.equalsIgnoreCase("paquete_cargos")){%><%=fb.submit("addCont","Agregar y Continuar")%><%}%>
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
					<td width="30%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<%if(fp.equalsIgnoreCase("procedimiento")){%><td width="10%"><cellbytelabel id="5">Cantidad</cellbytelabel></td><td width="10%"><cellbytelabel id="6">Paquete</cellbytelabel></td><%}%>
					
					<%if(fp.equalsIgnoreCase("paquete_cargos")){%><td width="10%"><cellbytelabel id="5">Cantidad</cellbytelabel></td><td width="10%"></td><%}%>
					
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los articulos listados!")%></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				<%=fb.hidden("familyCode"+i,cdo.getColValue("familyCode"))%>
				<%=fb.hidden("classCode"+i,cdo.getColValue("classCode"))%>
				<%=fb.hidden("itemCode"+i,cdo.getColValue("itemCode"))%>
				<%=fb.hidden("subclase"+i,cdo.getColValue("cod_subclase"))%>
				<%=fb.hidden("item"+i,cdo.getColValue("item"))%>
				<%=fb.hidden("code"+i,cdo.getColValue("code"))%>
				<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
				<%=fb.hidden("tipo_servicio_desc"+i,cdo.getColValue("tipo_servicio_desc"))%>
				<%=fb.hidden("codigo_articulo"+i,cdo.getColValue("code")+"-"+cdo.getColValue("cod_subclase"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" <%if(!fp.equals("descuento")){%>onClick="setArticulo(<%=i%>)"<%}%>>
					<td align="center"><%=cdo.getColValue("code")%>-<%=cdo.getColValue("cod_subclase")%></td>
					<td><%=cdo.getColValue("item")%></td>
					
					<%if(fp.equalsIgnoreCase("procedimiento")){%><td align="center">
					<%=fb.intBox("cantidad"+i,"1",false,false,(fp.equalsIgnoreCase("procedimiento") && vIns.contains(cdo.getColValue("code"))),3,null,null,"onChange=\"javascript:setChecked(this,document.articulo.check"+i+")\"")%></td><td align="center"><%=fb.checkbox("paquete"+i,"",false,(fp.equalsIgnoreCase("paquete_cargos")))%>
					</td><%}%>
					
					<%if(fp.equalsIgnoreCase("paquete_cargos")){%><td align="center">
					<%=(vPaqInsumo.contains(id+"-I-"+cdo.getColValue("itemCode")))?"":fb.intBox("cantidad"+i,"1",false,false,(fp.equalsIgnoreCase("procedimiento") && vIns.contains(cdo.getColValue("code"))),3,null,null,"onChange=\"javascript:setChecked(this,document.articulo.check"+i+")\"")%></td><td align="center"></td><%}%>
					
					
					<td align="center"><%=((fp.equalsIgnoreCase("procedimiento") && vIns.contains(cdo.getColValue("code"))) || (fp.equalsIgnoreCase("convenio_cobertura_centro") && vCobCD.contains(cdo.getColValue("code"))) || (fp.equalsIgnoreCase("convenio_exclusion_centro") && vExclCD.contains(cdo.getColValue("code"))) || ( (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") ) && vCobDet.contains(cdo.getColValue("code")))|| (fp.equalsIgnoreCase("convenio_cobertura_solicitud") && vCobDet.contains(cdo.getColValue("code"))) || ( (fp.equalsIgnoreCase("convenio_exclusion_detalle") ||fp.equalsIgnoreCase("pm_convenio_exclusion_detalle") )&& vExclDet.contains(cdo.getColValue("code"))) || (fp.equalsIgnoreCase("descuento")&& vDet.contains("A_"+cdo.getColValue("itemCode"))) || (fp.equalsIgnoreCase("paquete_cargos")&& vPaqInsumo.contains(id+"-I-"+cdo.getColValue("itemCode"))) || (fp.equalsIgnoreCase("MAPPING_CPT")&& vArtMapping.contains(cdo.getColValue("itemCode"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("code"),false,false)%></td>
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
	<tr<%=fp.equalsIgnoreCase("convenio_beneficio_new")?" style='display:none;'":""%>>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%if(fp.equalsIgnoreCase("procedimiento")||fp.equalsIgnoreCase("paquete_cargos")){%><%=fb.submit("addContB","Agregar y Continuar")%><%}%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	
				cdo.addColValue("art_familia",request.getParameter("familyCode"+i));
				cdo.addColValue("art_clase",request.getParameter("classCode"+i));
				cdo.addColValue("articulo",request.getParameter("itemCode"+i));
				cdo.addColValue("descripcion",request.getParameter("item"+i));
				cdo.addColValue("code",request.getParameter("code"+i));
				cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
				if (request.getParameter("paquete"+i) != null)
				cdo.addColValue("paquete","S");
				else cdo.addColValue("paquete","N");
				insLastLineNo++;
	
				String key = "";
				if (insLastLineNo < 10) key = "00"+insLastLineNo;
				else if (insLastLineNo < 100) key = "0"+insLastLineNo;
				else key = ""+insLastLineNo;
				cdo.addColValue("key",key);
		
				try
				{
					iIns.put(key, cdo);
					vIns.add(request.getParameter("code"+i));
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
				cd.setArticulo(request.getParameter("itemCode"+i));
				cd.setCodClase(request.getParameter("classCode"+i));
				cd.setCodFlia(request.getParameter("familyCode"+i));
				cd.setCodigo(request.getParameter("code"+i));
				cd.setDescripcion(request.getParameter("item"+i));
				cd.setStatus("I");
	
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
				ed.setArticulo(request.getParameter("itemCode"+i));
				ed.setCodClase(request.getParameter("classCode"+i));
				ed.setCodFlia(request.getParameter("familyCode"+i));
				ed.setCodigo(request.getParameter("code"+i));
				ed.setDescripcion(request.getParameter("item"+i));
	
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
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalladaServicio cd = new CoberturaDetalladaServicio();
	
				cd.setSecuencia("0");
				cd.setTipoServicio(request.getParameter("tipoServicio"));
				cd.setCompania(request.getParameter("compania"+i));
				cd.setCodArticulo(request.getParameter("itemCode"+i));
				cd.setCodClase(request.getParameter("classCode"+i));
				cd.setCodFlia(request.getParameter("familyCode"+i));
				cd.setCodigo(request.getParameter("code"+i));
				cd.setDescripcion(request.getParameter("item"+i));
	
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
	}//convenio_cobertura_detSol
	
	else if (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalle cd = new CoberturaDetalle();
	
				cd.setSecuencia("0");
				cd.setCompania(request.getParameter("compania"+i));
				cd.setArticulo(request.getParameter("itemCode"+i));
				cd.setCodClase(request.getParameter("classCode"+i));
				cd.setCodFlia(request.getParameter("familyCode"+i));
				cd.setCodigo(request.getParameter("code"+i));
				cd.setDescripcion(request.getParameter("item"+i));
	
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
				ed.setArticulo(request.getParameter("itemCode"+i));
				ed.setCodClase(request.getParameter("classCode"+i));
				ed.setCodFlia(request.getParameter("familyCode"+i));
				ed.setCodigo(request.getParameter("code"+i));
				ed.setDescripcion(request.getParameter("item"+i));
	
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
	else if (fp.equalsIgnoreCase("descuento"))
	{
		int itemNo = iDet.size();
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject des = new CommonDataObject();
	
				des.addColValue("codigo", request.getParameter("itemCode"+i));
				des.addColValue("descripcion", request.getParameter("item"+i));
				des.addColValue("tipo_desc", "A");
				des.addColValue("secuencia", "0");
	
				itemNo++;
	
				String key = "";
				if (itemNo < 10) key = "00"+itemNo;
				else if (itemNo < 100) key = "0"+itemNo;
				else key = ""+itemNo;
				des.setKey(key);
		
				try
				{
					iDet.put(key, des);
					vDet.add("A_"+des.getColValue("codigo"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
	else
	if (fp.equalsIgnoreCase("paquete_cargos"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
				
				System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::: paqInsumoLastLineNo1 = "+paqInsumoLastLineNo);
				
				cdo.addColValue("_usoCode",id+"-I-"+request.getParameter("codigo"+i));
				cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+i));
				cdo.addColValue("tipo_servicio_desc",request.getParameter("tipo_servicio_desc"+i));
				cdo.addColValue("tipo_cargo","I");
				cdo.addColValue("cod_cargo",request.getParameter("itemCode"+i));
				cdo.addColValue("descripcion",request.getParameter("item"+i));
				cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
				
				cdo.addColValue("_usoCode",id+"-I-"+request.getParameter("itemCode"+i));
				
				paqInsumoLastLineNo++;
	
				String key = "";
				if (paqInsumoLastLineNo < 10) key = "00"+paqInsumoLastLineNo;
				else if (paqInsumoLastLineNo < 100) key = "0"+paqInsumoLastLineNo;
				else key = ""+paqInsumoLastLineNo;
				cdo.addColValue("key",key);
				
				System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::: paqInsumoLastLineNo2 = "+paqInsumoLastLineNo);
				System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::: _usoCode = "+cdo.getColValue("_usoCode"));
		
				try
				{
					iPaqInsumo.put(key, cdo);
					vPaqInsumo.add(id+"-I-"+request.getParameter("itemCode"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//paquete_cargos
	else if (fp.equalsIgnoreCase("MAPPING_CPT"))
	{
		System.out.println("..................MAPPING_CPT");
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
	
				cdo.addColValue("codigo",request.getParameter("itemCode"+i));
				cdo.addColValue("descArt",request.getParameter("item"+i));
				cdo.setAction("I");
				
				artLastLineNoMapping++;
	
				String key = "";
				if (artLastLineNoMapping < 10) key = "00"+artLastLineNoMapping;
				else if (artLastLineNoMapping < 100) key = "0"+artLastLineNoMapping;
				else key = ""+artLastLineNoMapping;
				cdo.addColValue("key",key);
		
				try
				{
					iArtMapping.put(key, cdo);
					vArtMapping.add(request.getParameter("itemCode"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}

System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::: iCobCD.size() = "+iCobCD.size());
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&context="+context+"&noResultClose="+noResultClose+"&artLastLineNoMapping="+artLastLineNoMapping);
		return;

	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&context="+context+"&noResultClose="+noResultClose+"&artLastLineNoMapping="+artLastLineNoMapping);
		return;
	}
	if(request.getParameter("addCont")!=null||request.getParameter("addContB")!=null){
		response.sendRedirect("../common/check_articulo.jsp?fp="+fp+"&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&context="+context+"&noResultClose="+noResultClose+"&artLastLineNoMapping="+artLastLineNoMapping);

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
	window.opener.location = '../admision/procedimientos_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&colLastLineNo=<%=colLastLineNo%>&insLastLineNo=<%=insLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&honLastLineNo=<%=honLastLineNo%>';
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
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
%>
	window.opener.location = '../admision/detalle_cobertura_tipo.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&cds=<%=centroServicio%>&tipoCds=<%=tipoCds%>&secuencia_cob=<%=secuencia_cob%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&solicitud=<%=solicitud%>&admision=<%=admision%>&fecha_nacimiento=<%=fecha_nacimiento%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>';
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
<%	
	} else if (fp.equalsIgnoreCase("descuento"))
	{
%>	
	window.opener.location = '../pos/reg_descuento_det.jsp?change=1&mode=<%=mode%>&loadInfo=S'; 
<%	
	}
	else if (fp.equalsIgnoreCase("paquete_cargos")){
%>	
	  window.opener.location = '../admision/paquete_cargo_config.jsp?change=1&tab=2&paqInsumoLastLineNo=<%=paqInsumoLastLineNo%>&mode=edit&comboId=<%=id%>';
<%	  
	} else if (fp.equalsIgnoreCase("MAPPING_CPT")){ %>

window.opener.location="<%=request.getContextPath()%>/admin/mapping_art_det.jsp?fp=MAPPING_CPT&mode=edit&change=1&id=<%=id%>&artLastLineNoMapping=<%=artLastLineNoMapping%>&revenueId=<%=revenueId%>&cds=<%=cds%>";

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