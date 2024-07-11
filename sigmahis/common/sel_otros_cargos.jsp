<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactDetCargoCliente"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="OtroCargo" scope="session" class="issi.facturacion.FactCargoCliente" />
<jsp:useBean id="CdcSol" scope="session" class="issi.admision.CdcSolicitud" />
<%
/**
==================================================================================
fg = zzz	Listado de Articulos que se muestran en la forma CDC100120
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
XML.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String devol = request.getParameter("devol");
String medico = request.getParameter("medico");
String empresa = request.getParameter("empresa");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String inv_almacen = "", tipo_servicio = "", sqlInv = "", sqlTS = "", tipo_detalle = "";

String tipoTransaccion	= request.getParameter("tipoTransaccion");
String tipo_clte	= request.getParameter("tipo_clte");
String fck = "";
String codigo ="",codigoArt="",descripcion ="",familia="",clase="";
if (fg == null) fg = "xxx";
if(tipo_clte==null)tipo_clte = "";
String tipoClteFilter = "";
if(tipo_clte.equals("12")) tipoClteFilter = " and c.codigo_empresa = " + empresa;
else if(tipo_clte.equals("13")) tipoClteFilter = " and c.codigo_medico = " + medico;

if(fg.equals("yyy") || fg.equals("www")){
	sqlInv = "select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion";
	sqlTS = "select codigo, descripcion from tbl_cds_tipo_servicio where codigo in ('02','03','04','08','30') and compania = "+(String) session.getAttribute("_companyId")+" order by descripcion";
	if(fg.equals("www")){
		sqlTS = "select codigo, descripcion from tbl_cds_tipo_servicio where codigo in ('02','03','04','05','30') /*and compania = "+(String) session.getAttribute("_companyId")+"*/ order by descripcion";
	}

	CommonDataObject cdoI = SQLMgr.getData(sqlInv);
	CommonDataObject cdoTS = SQLMgr.getData(sqlTS);
	inv_almacen = cdoI.getColValue("codigo_almacen");
	if(cdoTS!=null) tipo_servicio = cdoTS.getColValue("codigo");
}

if(request.getParameter("inv_almacen")!=null && !request.getParameter("inv_almacen").trim().equals("")) inv_almacen = request.getParameter("inv_almacen");
if(request.getParameter("tipo_servicio")!=null) tipo_servicio = request.getParameter("tipo_servicio");
if(request.getParameter("tipo_detalle")!=null) tipo_detalle = request.getParameter("tipo_detalle");
else if(fg.equals("yyy")) tipo_detalle = "O";
else if(fg.equals("www")) tipo_detalle = "I";

if (tipoTransaccion == null) tipoTransaccion = "";
if (tipoSolicitud == null) tipoSolicitud = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
  appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
	 if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
	if (request.getParameter("familia") != null && !request.getParameter("familia").trim().equals("")){
    appendFilter += " and upper(i.art_familia) like '%"+request.getParameter("familia").toUpperCase()+"%'";
    familia = request.getParameter("familia");
  }
	if (request.getParameter("clase") != null && !request.getParameter("clase").trim().equals("")){
    appendFilter += " and upper(i.art_clase) like '%"+request.getParameter("clase").toUpperCase()+"%'";
    clase = request.getParameter("clase");
  }
	if (request.getParameter("codigoArt") != null && !request.getParameter("codigoArt").trim().equals("")){
    appendFilter += " and upper(i.cod_articulo) like '%"+request.getParameter("codigoArt").toUpperCase()+"%'";
    codigoArt = request.getParameter("codigoArt");
  }

	sql = "";
	int x = 0;
	if(tipoTransaccion.equals("C")){
		if(fg.equals("xxx")){
			sql = "select a.codigo cod_otro, a.descripcion, nvl(a.precio, 0) precio, a.tipo_servicio, b.descripcion tipo_servicio_desc, ' ' act_secuencia from tbl_fac_otros_cargos a, tbl_cds_tipo_servicio b where a.tipo_servicio = b.codigo and a.compania = b.compania and a.codigo_tipo is not null and a.activo_inactivo = 'A' and a.compania = "+(String) session.getAttribute("_companyId") +" "+appendFilter+" order by a.descripcion";
		} else if(fg.equals("yyy")){
			if(tipo_detalle.equals("I") && (tipo_servicio.equals("02") || tipo_servicio.equals("03") || tipo_servicio.equals("04") || tipo_servicio.equals("08"))){
				sql = "select i.art_familia, i.art_clase, i.cod_articulo, a.descripcion, i.art_familia || '-' || i.art_clase || '-' || i.cod_articulo v_codigo, i.disponible, nvl(decode('"+tipo_servicio+"','08', decode(i.codigo_almacen, 4, i.precio, a.precio_venta), a.precio_venta), 0) precio_venta, nvl(i.precio, 0) precio, ' ' act_secuencia, ' ' cod_otro, a.itbm from tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_familia_articulo f, tbl_inv_clase_articulo c where f.tipo_servicio = '"+tipo_servicio+"' and i.codigo_almacen = "+inv_almacen+" and i.compania = "+(String) session.getAttribute("_companyId")+" and ((i.compania = a.compania and i.art_familia = a.cod_flia and i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and (a.compania = c.compania and a.cod_flia = c.cod_flia and a.cod_clase = c.cod_clase) and (c.compania = f.compania and c.cod_flia = f.cod_flia)) "+appendFilter+" order by a.descripcion";
			} else if(tipo_detalle.equals("O") && tipo_servicio.equals("30")){
				sql = "select a.codigo cod_otro, a.descripcion, nvl(a.precio, 0) precio, a.tipo_servicio, a.codigo v_codigo, ' ' act_secuencia from tbl_fac_otros_cargos  a where a.codigo_tipo is not null and a.compania = "+(String) session.getAttribute("_companyId") +" and a.activo_inactivo = 'A' "+appendFilter+" order by a.descripcion";
			} else if(tipo_detalle.equals("A")){
				sql = "select all d.secuencia act_secuencia, a.descripcion, d.secuencia v_codigo, ' ' cod_otro from tbl_con_detalle a, tbl_con_activos d where ((a.cod_espec = d.cuentah_activo) and (a.codigo_subesp = d.cuentah_espec) and (a.codigo_detalle = d.cuentah_detalle) and (a.cod_compania = d.compania)) "+appendFilter+" order by a.descripcion";
			}
		} else if(fg.equals("zzz")){
			sql = "select nvl(i.disponible, 0) disponible, a.descripcion, a.cod_medida, i.cod_articulo, i.art_familia, i.art_clase, nvl(i.precio, 0) precio, a.itbm from tbl_inv_inventario i, tbl_inv_articulo a where a.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and a.venta_sino = 'S' and i.codigo_almacen = "+inv_almacen+" "+appendFilter+" order by a.descripcion";
			System.out.println("SQL zzz...\n"+sql);
		} else if(fg.equals("www")){
			if(tipo_detalle.equals("I") && (tipo_servicio.equals("02") || tipo_servicio.equals("03") || tipo_servicio.equals("04") || tipo_servicio.equals("30"))){
				if((tipo_servicio.equals("02") || tipo_servicio.equals("04") || tipo_servicio.equals("30")) && tipo_clte.equals("16")) tipo_servicio = "03";
				sql = "select i.art_familia, i.art_clase, i.cod_articulo, a.descripcion, i.art_familia || '-' || i.art_clase || '-' || i.cod_articulo v_codigo, i.disponible, a.precio_venta, decode(i.art_familia, null, i.precio, decode("+tipo_clte+", 16, nvl (i.precio, 0)*1.33, decode(nvl(d.precio, 0), 0, i.precio, d.precio))) precio, ' ' act_secuencia, ' ' cod_otro, a.itbm from tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_familia_articulo f, tbl_inv_clase_articulo c, (select i.compania, i.codigo_almacen, i.art_familia, i.art_clase, i.cod_articulo, nvl(c.precio_x_cli, 0) precio from tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_art_precio_x_cliente c, tbl_inv_familia_articulo f where i.compania = a.compania and i.compania = "+(String) session.getAttribute("_companyId")+" and (c.tipo_cliente = "+tipo_clte + tipoClteFilter+") and c.estado = 'A' and i.art_familia = a.cod_flia and i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo and i.art_familia = c.cod_flia and i.art_clase = c.cod_clase and i.cod_articulo = c.cod_articulo and i.codigo_almacen = c.almacen and i.compania = c.compania and i.art_familia = f.cod_flia and i.compania = f.compania) d where f.tipo_servicio = '"+tipo_servicio+"' and i.codigo_almacen = "+inv_almacen+" and i.compania = "+(String) session.getAttribute("_companyId")+" and ((i.compania = a.compania and i.art_familia = a.cod_flia and i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo ) and (a.compania = c.compania and a.cod_flia = c.cod_flia and a.cod_clase = c.cod_clase ) and (c.compania = f.compania and c.cod_flia = f.cod_flia)) and i.compania = d.compania(+) and i.codigo_almacen = d.codigo_almacen(+) and i.art_familia = d.art_familia(+) and i.art_clase = d.art_clase(+) and i.cod_articulo = d.cod_articulo(+) "+appendFilter+" order by a.descripcion";
			} else if(tipo_detalle.equals("Q")){
				sql = "select a.codigo cod_uso, a.descripcion, a.precio_venta precio, a.costo_pamd costo from tbl_sal_uso a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.tipo_servicio = '"+tipo_servicio+"' "+appendFilter+" order by a.descripcion ";
			}
			System.out.println("SQL www...\n"+sql);
		}
	} else if(tipoTransaccion.equals("D")){
	}

	System.out.println("sql.....="+sql);

	if(!sql.equals("")){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a ) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+") ");
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
document.title = 'Centro de Servicio - '+document.title;

function getMain(formx){return true;}
function chkValues(){
	var size = parseInt(document.detail.keySize.value);
	for(i=0;i<size;i++){
		chkValue(i);
	}
	return true;
}

function chkValue(i){
	var tipoTransaccion	= document.detail.tipoTransaccion.value;
	var fg			 				= document.detail.fg.value;
	var monto 					= 0.00, recargo = 0.00;
	var art_flia 				= eval('document.detail.art_familia'+i).value;
	var art_clase 			= eval('document.detail.art_clase'+i).value;
	var cod_art 				= eval('document.detail.cod_articulo'+i).value;
	var monto 					= parseFloat(eval('document.detail.precio_venta'+i).value);
	var tipo_servicio		= document.detail.tipo_servicio.value;
	var tipo_clte				= document.detail.tipo_clte.value;
	var almacen = '<%=inv_almacen%>';
	var cia = <%=(String) session.getAttribute("_companyId")%>;

	if(tipoTransaccion=='C'){
		var disponible = getInvDisponible('<%=request.getContextPath()%>', cia, almacen, art_flia, art_clase, cod_art);

		if(!isNaN(parseFloat(disponible))){
			disponible = parseFloat(disponible);
			if(disponible>0.00){
				<%if(fg.equals("xxx") || fg.equals("yyy")){%>
				if(tipo_servicio=='03' && art_flia == '1' && art_clase == '23' && (cod_art == '1' || cod_art == '2' || cod_art == '3') && monto != 0.00 && (tipo_clte == '1' || tipo_clte == '3' || tipo_clte == '4')){
					if(confirm('De clic en OK para Facturar Producto a Precio de Venta; Cancelar para Precio de Costo')){
						eval('document.detail.precio'+i).value = eval('document.detail.precio_venta'+i).value;
					}
				} else{eval('document.detail.precio'+i).value = eval('document.detail.precio_venta'+i).value;setChecked(eval('document.detail.cantidad'+i), eval('document.detail.chkServ'+i));}
				<%}else{%> setChecked(eval('document.detail.cantidad'+i), eval('document.detail.chkServ'+i));<%}%>
			} else {
				alert('No hay cantidad disponible para este artículo!');
				if(confirm('Desea agregar el articulo sin disponibilidad')){setChecked(eval('document.detail.cantidad'+i), eval('document.detail.chkServ'+i));}
				else{eval('document.detail.chkServ'+i).checked=false;}
			}
		}
	} else if(tipoTransaccion=='D'){
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE OTROS CARGOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
      	<%
				if(fg.equals("xxx")){
				%>
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("devol",devol)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("tipo_clte",tipo_clte)%>
				<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
				<td width="18%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,8)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("devol",devol)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("tipo_clte",tipo_clte)%>
				<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
				<td width="32%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,26)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
				 	<%
				}else if(fg.equals("zzz")){
				%>
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("devol",devol)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("tipo_clte",tipo_clte)%>
				<%=fb.hidden("inv_almacen",inv_almacen)%>
				<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
				<td width="50%">
					<cellbytelabel>Familia</cellbytelabel> <%=fb.textBox("familia","",false,false,false,8)%>
					<cellbytelabel>Clase</cellbytelabel>  <%=fb.textBox("clase","",false,false,false,8)%>
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigoArt","",false,false,false,8)%>

				</td>
				<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,26)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
        <%} else if(fg.equals("yyy")){%>
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("devol",devol)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("tipo_clte",tipo_clte)%>
				<%=fb.hidden("tipo_servicio",tipo_servicio)%>
				<%=fb.hidden("inv_almacen",inv_almacen)%>
				<%=fb.hidden("medico",medico)%>
				<%=fb.hidden("empresa",empresa)%>
				<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>

        	<td><%=fb.select("tipo_detalle", "A=Activo",tipo_detalle)%></td>
				<td>
					<cellbytelabel>Secuencia</cellbytelabel>
					<%=fb.textBox("secuencia","",false,false,false,8)%>
				</td>
				<td>
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,26)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("devol",devol)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("tipo_clte",tipo_clte)%>
				<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
        <td><%=fb.select("tipo_detalle", "I=Inventario,O=Otro",tipo_detalle)%></td>
				<td colspan="2">
					<cellbytelabel>Tipo Servicio</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_tipo_servicio where codigo in ('02','03','04','08','30') /*and compania = "+(String) session.getAttribute("_companyId")+"*/ order by descripcion", "tipo_servicio", tipo_servicio)%>
					&nbsp;
          <cellbytelabel>Almac&eacute;n</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select a.codigo_almacen, a.descripcion from tbl_inv_almacen a where a.compania = "+(String) session.getAttribute("_companyId")+" and exists (select '*' from tbl_sec_almacenistas_x_almacen aa where aa.compania = a.compania and aa.codigo_almacen = a.codigo_almacen and aa.usuario = '"+(String) session.getAttribute("_userName")+"') order by descripcion", "inv_almacen",inv_almacen)%>
          &nbsp;
          <cellbytelabel>Descripci&oacute;n</cellbytelabel>
          <%=fb.textBox("descripcion","",false,false,false,26)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
        <%} else if(fg.equals("www")){%>
				<tr class="TextFilter">
				<%
        fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
        %>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
        <%=fb.hidden("devol",devol)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
        <%=fb.hidden("tipo_clte",tipo_clte)%>
        <%=fb.hidden("medico",medico)%>
        <%=fb.hidden("empresa",empresa)%>
				<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
        <td><%=fb.select("tipo_detalle", "I=Inventario,Q=Usos",tipo_detalle)%></td>
				<td colspan="2">
					<cellbytelabel>Tipo Servicio</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_tipo_servicio where codigo in ('02','03','04','05','30') /*and compania = "+(String) session.getAttribute("_companyId")+"*/ order by descripcion", "tipo_servicio", tipo_servicio)%>
					&nbsp;
          <cellbytelabel>Almac&eacute;n</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select a.codigo_almacen, a.descripcion from tbl_inv_almacen a where a.compania = "+(String) session.getAttribute("_companyId")+" and exists (select '*' from tbl_sec_almacenistas_x_almacen aa where aa.compania = a.compania and aa.codigo_almacen = a.codigo_almacen and aa.usuario = '"+(String) session.getAttribute("_userName")+"') order by descripcion", "inv_almacen",inv_almacen)%>
          &nbsp;
          <cellbytelabel>Descripci&oacute;n</cellbytelabel>
          <%=fb.textBox("descripcion","",false,false,false,26)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
        <%}%>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
          <%=fb.hidden("devol",devol)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
          <%=fb.hidden("tipo_detalle",tipo_detalle)%>
          <%=fb.hidden("tipo_servicio",tipo_servicio)%>
          <%=fb.hidden("inv_almacen",inv_almacen)%>
					<%=fb.hidden("tipo_clte",tipo_clte)%>
					<%=fb.hidden("medico",medico)%>
          <%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("codigoArt",codigoArt)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("descripcion",descripcion)%>
				    <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
          			<%=fb.hidden("devol",devol)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				    <%=fb.hidden("tipo_detalle",tipo_detalle)%>
				    <%=fb.hidden("tipo_servicio",tipo_servicio)%>
				    <%=fb.hidden("inv_almacen",inv_almacen)%>
					<%=fb.hidden("tipo_clte",tipo_clte)%>
					<%=fb.hidden("medico",medico)%>
         			<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("codigoArt",codigoArt)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("descripcion",descripcion)%>
				    <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
String onSubmit = "";
//if(fg.equals("FH")) onSubmit = "onSubmit=\"javascript:return(chkValues())\"";
fb = new FormBean("detail","","post",onSubmit);
%>
	<%=fb.formStart()%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
    <%=fb.hidden("tipo_detalle",tipo_detalle)%>
    <%=fb.hidden("tipo_servicio",tipo_servicio)%>
    <%=fb.hidden("inv_almacen",inv_almacen)%>
	<%=fb.hidden("tipo_clte",tipo_clte)%>
    <%=fb.hidden("devol",devol)%>
	<%=fb.hidden("medico",medico)%>
    <%=fb.hidden("empresa",empresa)%>
	<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
	<%
	if(fg.equals("xxx")){
	%>
				<tr>
					<td align="right" colspan="6"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="33%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Tipo Serv</cellbytelabel>.</td>
					<td width="34%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
					<td width="3%">&nbsp;</td>
				</tr>
	<%
	} else if(fg.equals("yyy")){
		if(tipo_detalle.equals("A")){
	%>
				<tr>
					<td align="right" colspan="3"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="33%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="3%">&nbsp;</td>
				</tr>
  <%
  	} else if(tipo_detalle.equals("I")){
  %>
      <tr>
        <td align="right" colspan="7"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
      </tr>
			<tr class="TextHeader" align="center">
					<td width="15%" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="33%" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%" rowspan="2"><cellbytelabel>Disponible</cellbytelabel></td>
					<td width="10%" rowspan="2"><cellbytelabel>Precio</cellbytelabel></td>
					<td width="3%" rowspan="2">&nbsp;</td>
				</tr>
				<tr class="TextHeader" align="center">
					<td><cellbytelabel>Flia</cellbytelabel>.</td>
					<td><cellbytelabel>Clase</cellbytelabel></td>
					<td><cellbytelabel>Cod</cellbytelabel>.</td>
				</tr>
  <%
  	} else if(tipo_detalle.equals("O")){
  %>
      <tr>
        <td align="right" colspan="4"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
      </tr>
			<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="33%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
					<td width="3%">&nbsp;</td>
				</tr>
	<%
		}
	} else if(fg.equals("zzz")){
  %>
      <tr>
        <td align="right" colspan="7"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
      </tr>
			<tr class="TextHeader" align="center">
					<td width="10%" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="27%" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%" rowspan="2"><cellbytelabel>Disponible</cellbytelabel></td>
					<td width="10%" rowspan="2"><cellbytelabel>Precio</cellbytelabel></td>
					<td width="10%" rowspan="2"><cellbytelabel>Cantidad</cellbytelabel></td>
					<td width="3%" rowspan="2">&nbsp;</td>
				</tr>
				<tr class="TextHeader" align="center">
					<td><cellbytelabel>Flia</cellbytelabel>.</td>
					<td><cellbytelabel>Clase</cellbytelabel></td>
					<td><cellbytelabel>Cod</cellbytelabel>.</td>
				</tr>
	<%
	} else if(fg.equals("www")){
  %>
      <tr>
        <td align="right" colspan="7"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
      </tr>
      <%if(tipo_detalle.equals("I")){%>
			<tr class="TextHeader" align="center">
        <td width="15%" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
        <td width="33%" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
        <td width="10%" rowspan="2"><cellbytelabel>Disponible</cellbytelabel></td>
        <td width="10%" rowspan="2"><cellbytelabel>Precio</cellbytelabel></td>
        <td width="3%" rowspan="2">&nbsp;</td>
      </tr>
      <tr class="TextHeader" align="center">
        <td><cellbytelabel>Flia</cellbytelabel>.</td>
        <td><cellbytelabel>Clase</cellbytelabel></td>
        <td><cellbytelabel>Cod</cellbytelabel>.</td>
      </tr>
      <%} else if(tipo_detalle.equals("Q")){%>
			<tr class="TextHeader" align="center">
        <td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
        <td width="33%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
        <td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
        <td width="3%">&nbsp;</td>
      </tr>
      <%}%>
<%
	}
	%>
<%
String onCheck = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	%>
	<%=fb.hidden("cod_otro"+i,cdo.getColValue("cod_otro"))%>
	<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
	<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
	<%=fb.hidden("desc_tipo_servicio"+i,cdo.getColValue("tipo_servicio_desc"))%>
	<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
    <%=fb.hidden("act_secuencia"+i,cdo.getColValue("act_secuencia"))%>
    <%=fb.hidden("art_familia"+i,cdo.getColValue("art_familia"))%>
    <%=fb.hidden("art_clase"+i,cdo.getColValue("art_clase"))%>
    <%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
    <%=fb.hidden("disponible"+i,cdo.getColValue("disponible"))%>
	<%=fb.hidden("precio_venta"+i,cdo.getColValue("precio_venta"))%>
	<%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%>
	<%

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = "";
	if(fg.equals("xxx") || fg.equals("yyy")){
		cargoKey = fg+"_"+cdo.getColValue("cod_otro")+"_"+cdo.getColValue("art_familia")+"_"+cdo.getColValue("art_clase")+"_"+cdo.getColValue("cod_articulo")+"_"+cdo.getColValue("act_secuencia");
	} else if(fg.equals("zzz"))
		cargoKey = tipoSolicitud+"_"+cdo.getColValue("cod_articulo");
	if(fg.equals("xxx")){
		if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("cod_otro")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td>&nbsp;<%=cdo.getColValue("tipo_servicio")%></td>
			<td align="center"><%=cdo.getColValue("tipo_servicio_desc")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%>&nbsp;</td>
			<td align="center"><%=fb.intBox("cantidad"+i,"0",true,false,(fTranCarg.containsKey(key)),3, 4, "", "",onCheck, "", false)%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      elegido
      <%} else {%>
	  
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
      </td>
		</tr>
	<%
	} else if(fg.equals("yyy")){
		if(tipo_detalle.equals("A")){
			if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("act_secuencia")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      elegido
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
			</td>
		</tr>
	<%
  	} else if(tipo_detalle.equals("I")){
			if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
			onCheck = "onClick=\"javascript:chkValue("+i+");\"";
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("art_familia")%></td>
			<td align="center"><%=cdo.getColValue("art_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("disponible")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio_venta"))%></td>
			<td align="center"><%=fb.intBox("cantidad"+i,"0",true,false,(fTranCarg.containsKey(key)),3, 4, "", "",onCheck, "", false)%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      <cellbytelabel>elegido</cellbytelabel>
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
			</td>
		</tr>
	<%
  	} else if(tipo_detalle.equals("O")){
			if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("cod_otro")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      <cellbytelabel>elegido</cellbytelabel>
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
			</td>
		</tr>
	<%
		}
	} else if(fg.equals("zzz")){
	
 			if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
			onCheck = "onChange=\"javascript:chkValue("+i+");\"";
	%>
  	<%=fb.hidden("unidad"+i, cdo.getColValue("cod_medida"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("art_familia")%></td>
			<td align="center"><%=cdo.getColValue("art_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="center">
			 <%
			 String redTextClass = "";
			 if(Double.parseDouble(cdo.getColValue("disponible")) <=0) redTextClass = "RedTextBold";
			 //if(Double.parseDouble(cdo.getColValue("disponible")) <=0){%>
			    <!--<label class="<%//=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%//=cdo.getColValue("disponible")%>		  
		   	  <%//if(Double.parseDouble(cdo.getColValue("disponible")) <=0){%>&nbsp;&nbsp;</label></label>--><%//}}%>
			  
			    <label class="<%=color%> <%=redTextClass%>"><%=cdo.getColValue("disponible")%></label>

			  
  		    </td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
			<td align="center"><%=fb.intBox("cantidad"+i,"0",false,false,(fTranCarg.containsKey(key)),3, 4, "", "",onCheck, "", false)%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      <cellbytelabel>elegido</cellbytelabel>
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
			</td>
		</tr>
	<%
	} else if(fg.equals("www")){
 			if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
			onCheck = "onClick=\"javascript:chkValue("+i+");\"";
	%>
  	<%if(tipo_detalle.equals("I")){%>
  	<%=fb.hidden("unidad"+i, cdo.getColValue("cod_medida"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("art_familia")%></td>
			<td align="center"><%=cdo.getColValue("art_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("disponible")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      <cellbytelabel>elegido</cellbytelabel>
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
			</td>
		</tr>
    <%} else if(tipo_detalle.equals("Q")){%>
		<%=fb.hidden("cod_uso"+i,cdo.getColValue("cod_uso"))%>
    <%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("cod_uso")%></td>
			<td align="center"><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("precio")%></td>
			<td align="center">
      <%if (fTranCarg.containsKey(key)){%>
      <cellbytelabel>elegido</cellbytelabel>
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
			</td>
		</tr>
    <%}%>
<%
 }
}
if(al.size()==0){
%>
		<tr align="center">
			<td colspan="6"><cellbytelabel>No Registros Encontrados</cellbytelabel></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
          <%=fb.hidden("devol",devol)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
          <%=fb.hidden("tipo_detalle",tipo_detalle)%>
          <%=fb.hidden("tipo_servicio",tipo_servicio)%>
          <%=fb.hidden("inv_almacen",inv_almacen)%>
					<%=fb.hidden("tipo_clte",tipo_clte)%>
					<%=fb.hidden("medico",medico)%>
          <%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("codigoArt",codigoArt)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("descripcion",descripcion)%>)%>
					<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
					
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
          <%=fb.hidden("devol",devol)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
          <%=fb.hidden("tipo_detalle",tipo_detalle)%>
          <%=fb.hidden("tipo_servicio",tipo_servicio)%>
          <%=fb.hidden("inv_almacen",inv_almacen)%>
					<%=fb.hidden("tipo_clte",tipo_clte)%>
					<%=fb.hidden("medico",medico)%>
          <%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("codigoArt",codigoArt)%>
					<%=fb.hidden("familia",familia)%>
					<%=fb.hidden("clase",clase)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	System.out.println("=====================POST=====================");
	String artDel = "", key = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	if(fg.equals("xxx") || fg.equals("yyy") || fg.equals("www")){
		int lineNo = OtroCargo.getFacDetCargoClientes().size();
		for(int i=0;i<keySize;i++){

			FactDetCargoCliente det = new FactDetCargoCliente();

			det.setCodOtro(request.getParameter("cod_otro"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setMonto(request.getParameter("precio"+i));
			det.setTipoDetalle(request.getParameter("tipo_detalle"));
			if(fg.equals("xxx")) det.setTipoDetalle("O");
			det.setMontoRecargo("0");
			//det.setCantidad("1");
if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).equals("null") && !request.getParameter("cantidad"+i).equals("")) det.setCantidad(request.getParameter("cantidad"+i));



			if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setInvArtFamilia(request.getParameter("art_familia"+i));
			if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setInvArtClase(request.getParameter("art_clase"+i));
			if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setInvCodArticulo(request.getParameter("cod_articulo"+i));
			if(request.getParameter("disponible"+i)!=null && !request.getParameter("disponible"+i).equals("null") && !request.getParameter("disponible"+i).equals("")) det.setDisponible(request.getParameter("disponible"+i));
			if(request.getParameter("act_secuencia"+i)!=null && !request.getParameter("act_secuencia"+i).equals("null") && !request.getParameter("act_secuencia"+i).equals("")) det.setActSecuencia(request.getParameter("act_secuencia"+i));
			if(request.getParameter("tipo_servicio")!=null && !request.getParameter("tipo_servicio").equals("null") && !request.getParameter("tipo_servicio").equals("")) det.setTipoServicio(request.getParameter("tipo_servicio"));
			if(request.getParameter("inv_almacen")!=null && !request.getParameter("inv_almacen").equals("null") && !request.getParameter("inv_almacen").equals("") && request.getParameter("tipo_detalle").equals("I")) det.setInvAlmacen(request.getParameter("inv_almacen"));
			if(request.getParameter("itbm"+i)!=null && !request.getParameter("itbm"+i).equals("null") && !request.getParameter("itbm"+i).equals("")) det.setItbm(request.getParameter("itbm"+i));
			if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals("")) det.setCodUso(request.getParameter("cod_uso"+i));
			if(det.getTipoDetalle().equals("I") && (fg.equals("yyy") || fg.equals("www"))){
				det.setCosto(request.getParameter("precio"+i));
			} else {
				if(request.getParameter("costo"+i)!=null && !request.getParameter("costo"+i).equals("null") && !request.getParameter("costo"+i).equals("")) det.setCosto(request.getParameter("costo"+i));
			}

			//if(request.getParameter(""+i)!=null && !request.getParameter(""+i).equals("null") && !request.getParameter(""+i).equals("")) det.set(request.getParameter(""+i));

			if(Double.parseDouble(det.getMonto())!=0.00) det.setCeroValue("1");
			else det.setCeroValue("0");
			if(request.getParameter("chkServ"+i)!=null){
				fck = fg+"_"+det.getCodOtro()+"_"+det.getInvArtFamilia()+"_"+det.getInvArtClase()+"_"+det.getInvCodArticulo()+"_"+det.getActSecuencia();
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					fTranCarg.put(key, det);
					fTranCargKey.put(fck, key);
					OtroCargo.getFacDetCargoClientes().add(det);
					//System.out.println("adding item "+key+" _ "+fck);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	} else if(fg.equals("zzz")){
		int lineNo = CdcSol.getCdcSolicitudDetail().size();
		for(int i=0;i<keySize;i++){

			CdcSolicitudDet det = new CdcSolicitudDet();

			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setPrecio(request.getParameter("precio"+i));			
			det.setConfiguradoCpt("N"); 
			if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).equals("null") && !request.getParameter("cantidad"+i).equals("")) det.setCantidad(request.getParameter("cantidad"+i));



			if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));
			if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));
			if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));
			if(request.getParameter("disponible"+i)!=null && !request.getParameter("disponible"+i).equals("null") && !request.getParameter("disponible"+i).equals("")) det.setDisponible(request.getParameter("disponible"+i));
			if(request.getParameter("unidad"+i)!=null && !request.getParameter("unidad"+i).equals("null") && !request.getParameter("unidad"+i).equals("")) det.setUnidad(request.getParameter("unidad"+i));
			//if(request.getParameter("itbm")!=null && !request.getParameter("itbm").equals("null") && !request.getParameter("itbm").equals("")) det.setItbm(request.getParameter("itbm"));

			//if(request.getParameter(""+i)!=null && !request.getParameter(""+i).equals("null") && !request.getParameter(""+i).equals("")) det.set(request.getParameter(""+i));

			if(request.getParameter("chkServ"+i)!=null){
				fck = tipoSolicitud+"_"+det.getCodArticulo();
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					fTranCarg.put(key, det);
					fTranCargKey.put(fck, key);
					CdcSol.getCdcSolicitudDetail().add(det);
					//System.out.println("adding item "+key+" _ "+fck);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_otros_cargos.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&tipoTransaccion="+tipoTransaccion+"&inv_almacen="+inv_almacen+"&devol="+devol+"&tipoSolicitud="+tipoSolicitud);
		return;
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("cargo_dev_pac_oc")){%>
	window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_oc.jsp?change=1&mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&tipoTransaccion=<%=tipoTransaccion%>&devol=<%=devol%>';
	<%} else if(fp!= null && fp.equals("cargo_dev_so")){%>
	window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_so.jsp?change=1&mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&tipoTransaccion=<%=tipoTransaccion%>&tipoSolicitud=<%=tipoSolicitud%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>