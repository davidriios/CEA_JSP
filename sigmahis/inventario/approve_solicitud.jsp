<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Requisicion"%>
<%@ page import="issi.inventory.RequisicionDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="ReqDet" scope="session" class="issi.inventory.Requisicion"/>
<jsp:useBean id="rqArt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="rqArtKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ReqVar" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="ReqMgr" scope="page" class="issi.inventory.RequisicionMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="cdo2" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
==========================================================================================
Unified inv220020 and inv220070
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ReqMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList rqVar = new ArrayList();

String sql = "", key = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio = request.getParameter("anio");
if(anio == null) anio=fecha.substring(6, 10);
String mes = fecha.substring(4,5);
String type = request.getParameter("type");
int lineNo = 0;

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "approve";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change==null){
		ReqDet = new Requisicion();
		session.setAttribute("ReqDet",ReqDet);
		rqArt.clear();
		rqArtKey.clear();
		ReqDet.setAnio(anio);
		//ReqDet.setReqType(tr);
	}
	if (mode.equalsIgnoreCase("approve"))
	{
		if (id == null) throw new Exception("Requisición no es válida. Por favor intente nuevamente!");

		if (change==null){
			sql = "SELECT requi_anio anio, requi_numero noSolicitud, requi_numero noRequisicion, a.compania, to_char(requi_fecha,'dd/mm/yyyy') fechaDocto, estado_requi estadoSolicitud, NVL(observaciones,' ') observacion, NVL(monto_total,0) montoTotal, NVL(subtotal,0) subtotal, NVL(itbm,0) itbm, nvl(activa,' ') activa, nvl(unidad_administrativa,0) unidadAdmin, nvl(a.codigo_almacen,0) codAlmacen, b.descripcion descCodAlmacen,c.descripcion descUnidadAdmin, NVL(especificacion, ' ') especificacion FROM TBL_INV_REQUISICION a, TBL_INV_ALMACEN b, TBL_SEC_UNIDAD_EJEC c WHERE a.compania = "+session.getAttribute("_companyId")+" and a.requi_anio = "+anio+" and a.requi_numero="+id+" AND a.compania = b.compania(+) AND a.codigo_almacen = b.codigo_almacen(+) and a.unidad_administrativa=c.codigo(+)";
			System.out.println("sql....="+sql);
			ReqDet = (Requisicion) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Requisicion.class);



			sql = "SELECT a.*, b.estado_renglon estadoRenglon, b.cantidad, b.costo, b.renglon, nvl(b.especificacion,' ') as especificacion, nvl(b.comentario,' ') as comentario FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia artFamilia, a.cod_clase artClase, a.cod_articulo codArticulo, a.descripcion artDesc, a.itbm, coalesce(a.other1, a.cod_medida) unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase, d.precio, d.ultimo_precio ultimoPrecio, (select descripcion from tbl_inv_unidad_medida where cod_medida = a.cod_medida) as unidadDesc, (select descripcion from tbl_inv_unidad_medida where cod_medida = a.other1) as unidadEmpDesc FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c, TBL_INV_INVENTARIO d WHERE (d.compania = a.compania AND d.art_familia = a.cod_flia AND d.art_clase = a.cod_clase AND d.cod_articulo = a.cod_articulo) AND (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND d.compania = "+session.getAttribute("_companyId")+" AND d.codigo_almacen = "+ReqDet.getCodAlmacen()+") a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo art_key, a.estado_renglon, a.cantidad, precio_cotizado costo, renglon, especificacion, comentario FROM TBL_INV_DETALLE_REQ a WHERE a.compania = "+session.getAttribute("_companyId")+" AND a.estado_renglon = 'P' AND a.requi_anio = "+ReqDet.getAnio()+" and a.requi_numero = "+id+" and a.compania="+session.getAttribute("_companyId")+") b WHERE a.art_key = b.art_key";
			System.out.println("sqlDetails....="+sql);
			ReqDet.setReqDetails(sbb.getBeanList(ConMgr.getConnection(), sql, RequisicionDetail.class));

			for(int i=0;i<ReqDet.getReqDetails().size();i++){
				RequisicionDetail rq = (RequisicionDetail) ReqDet.getReqDetails().get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					rqArt.put(key, rq);
					rqArtKey.put(rq.getArtFamilia()+"-"+rq.getArtClase()+"-"+rq.getCodArticulo(), key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp"%>
<script language="javascript">
document.title = 'Administración - '+document.title;


function chkCeroValues(){
	var size = document.requisicion.keySize.value;
	var x = 0;

	if(document.requisicion.action.value=="Guardar"){
		for(i=0;i<size;i++){
			if(eval('document.requisicion.cantidad'+i).value<=0){
				alert('La cantidad no puede ser menor o igual a 0!');
				eval('document.requisicion.cantidad'+i).focus();
				x++;
				break;
			}
		}
	}
	if(x==0) return true;
	else return false;
}

function chkCeroRegisters(){
	var size = document.requisicion.keySize.value;
	if(size>0) return true;
	else{
		if(document.requisicion.action.value!='Guardar') return true;
		else {
			alert('Seleccione al menos un (1) articulo!');
			document.requisicion.action.value = '';
			return false;
		}
	}
}
$(document).ready(function(){jqTooltip();});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBAR REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN."></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("requisicion",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextPanel">
								<td colspan="8">Requisici&oacute;n</td>
							</tr>
							<tr class="TextRow01">
								<td width="12%" align="right">Requisici&oacute;n No.</td>
								<td width="15%">
								<%=fb.textBox("anio",ReqDet.getAnio(),true,false,true,4,null,null,"")%>
								<%=fb.textBox("solicitud_no",(ReqDet.getNoSolicitud()!=null)?ReqDet.getNoSolicitud():"0",true,false,true,4,null,null,"")%>
								</td>

								<td width="6%" align="right">&nbsp;</td>
								<td width="18%">&nbsp;</td>
								<td width="6%" align="right">Fecha</td>
								<td width="18%">
								<%=fb.textBox("fecha_documento",(ReqDet.getFechaDocto()==null)?fecha:ReqDet.getFechaDocto(),true,false,true,10,null,null,"")%>
								</td>
								<td width="7%" align="right">Estado</td>
								<td width="18%">
								<%=fb.select("estado_solicitud","P=Pendiente, A=Aprobado, R=Rechazado",ReqDet.getEstadoSolicitud())%>
								</td>
							</tr>
								<%=fb.hidden("unidad_administrativa",ReqDet.getUnidadAdmin())%>
								<%=fb.hidden("codigo_almacen",ReqDet.getCodAlmacen())%>
							<tr class="TextRow01">
								<td align="right">Almac&eacute;n</td>
								<td colspan="7">
								<%=fb.textBox("desc_codigo_almacen",ReqDet.getDescCodAlmacen(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,true,"","","")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td align="right">Unidad Admin.</td>
								<td colspan="7">
								<%=fb.textBox("desc_unidad_adm",ReqDet.getDescUnidadAdmin(),false,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,true,"","","")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td align="right">Observaci&oacute;n</td>
								<td colspan="7">
								<%=fb.textarea("observacion",ReqDet.getObservacion(),false,false,true,93,5)%>
								</td>
							</tr>
						</table>
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextPanel">
								<td colspan="8">Detalle de la Solicitud</td>
							</tr>
							<tr class="TextHeader">
								<td width="13%" align="center" colspan="3">C&oacute;digo</td>
								<td width="35%" align="center">Descripci&oacute;n</td>
								<td width="14%" align="center">Especificaci&oacute;n</td>
								<td width="25%" align="center">Comentario</td>
								<td width="5%" align="center">Und.</td>
								<td width="8%" align="center">Cantidad</td>
							</tr>
							<%
							boolean readOnly = false;
							key = "";
							if (rqArt.size() != 0) al = CmnMgr.reverseRecords(rqArt);
							for (int i=0; i<rqArt.size(); i++)
							{
								key = al.get(i).toString();
								//System.out.println("key...="+key);
								RequisicionDetail rq = (RequisicionDetail) rqArt.get(key);
								String color = "TextRow02 Text10";
								if (i % 2 == 0) color = "TextRow01 Text10";
							%>
							<%=fb.hidden("disponible"+i,rq.getDisponible())%>
							<%=fb.hidden("precio"+i,rq.getPrecio())%>
							<%=fb.hidden("ultimo_precio"+i,rq.getUltimoPrecio())%>
							<%=fb.hidden("descuento"+i,rq.getDescuento())%>
							<%=fb.hidden("porcentaje"+i,rq.getPorcentaje())%>
							<%=fb.hidden("art_familia"+i,rq.getArtFamilia())%>
							<%=fb.hidden("art_clase"+i,rq.getArtClase())%>
							<%=fb.hidden("cod_articulo"+i,rq.getCodArticulo())%>
							<%=fb.hidden("art_descripcion"+i,rq.getArtDesc())%>
							<%=fb.hidden("unidad"+i,rq.getUnidad())%>
							<%=fb.hidden("especificacion"+i,rq.getEspecificacion())%>
							<%=fb.hidden("comentario"+i,rq.getComentario())%>
							<%=fb.hidden("unidad"+i,rq.getUnidad())%>
							<%=fb.hidden("cantidad"+i,rq.getCantidad())%>
							<%=fb.hidden("fromReq"+i,rq.getFromReq())%>
							<tr class="TextRow01 Text10">
								<td align="right" width="4%"><%=rq.getArtFamilia()%></td>
								<td align="right" width="4%"><%=rq.getArtClase()%></td>
								<td align="right" width="5%"><%=rq.getCodArticulo()%></td>
								<td><%=rq.getArtDesc()%></td>
								<td align="center"><%=rq.getEspecificacion()%></td>
								<td><%=rq.getComentario()%></td>
								<td align="center" class="_jqHint" hintMsgId="hintDetail<%=i%>"><%=rq.getUnidad()%><span id="hintDetail<%=i%>" class="_jqHintMsg">[<%=rq.getUnidad()%> - <%=rq.getUnidadDesc()%>]</span></td>
								<td align="right"><%=rq.getCantidad()%></td>
							</tr>
							<%
							}
							%>
							<%=fb.hidden("keySize",""+ReqDet.getReqDetails().size())%>
							<tr class="TextRow02">
							<!--submit(String objName, String objValue, boolean disableOnSubmit, boolean isDisabled, String className, String style, String event)-->
								<td colspan="8" align="right"><%=fb.submit("save","Guardar",true,false,"","","onClick=\"javascript:document.requisicion.action.value = this.value;\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
							</tr>
			</table></td>
	</tr>
<%
fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();

	String companyId = (String) session.getAttribute("_companyId");
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	System.out.println("clearHT...="+clearHT);
	String artDel = "";
	ReqDet.setCompania(companyId);
	ReqDet.setAnio(request.getParameter("anio"));
	ReqDet.setNoSolicitud(request.getParameter("solicitud_no"));
	ReqDet.setFechaDocto(request.getParameter("fecha_documento"));
	ReqDet.setEstadoSolicitud(request.getParameter("estado_solicitud"));
	ReqDet.setObservacion(request.getParameter("observacion"));
	ReqDet.setUsuarioCrea((String) session.getAttribute("_userName"));
	ReqDet.setUsuarioModifica((String) session.getAttribute("_userName"));

	ReqDet.setCodAlmacen(request.getParameter("codigo_almacen"));
	ReqDet.setDescCodAlmacen(request.getParameter("desc_codigo_almacen"));
	/*
	ReqDet.set(request.getParameter(""));
	*/

	ReqDet.getReqDetails().clear();
	rqArt.clear();
	rqArtKey.clear();
	for(int i=0;i<keySize;i++){
		RequisicionDetail rq = new RequisicionDetail();
		rq.setArtFamilia(request.getParameter("art_familia"+i));
		rq.setArtClase(request.getParameter("art_clase"+i));
		rq.setCodArticulo(request.getParameter("cod_articulo"+i));
		rq.setArtDesc(request.getParameter("art_descripcion"+i));
		rq.setDisponible(request.getParameter("disponible"+i));
		rq.setPrecio(request.getParameter("precio"+i));
		rq.setUltimoPrecio(request.getParameter("ultimo_precio"+i));
		rq.setDescuento(request.getParameter("descuento"+i));
		rq.setPorcentaje(request.getParameter("porcentaje"+i));
		rq.setEspecificacion(request.getParameter("especificacion"+i));
		rq.setUnidad(request.getParameter("unidad"+i));
		rq.setCantidad(request.getParameter("cantidad"+i));
		rq.setEstadoRenglon("P");
		rq.setRenglon(""+(i+1));

		/*
		rq.set(request.getParameter(""+i));
		*/

		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		if(request.getParameter("del"+i)==null){
			try {
				rqArt.put(key, rq);
				rqArtKey.put(rq.getArtFamilia()+"-"+rq.getArtClase()+"-"+rq.getCodArticulo(), key);
				ReqDet.getReqDetails().add(rq);
				System.out.println("adding...= "+key);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		} else {
			artDel = rq.getArtFamilia()+"-"+rq.getArtClase()+"-"+rq.getCodArticulo();
		}
	}

	if(!artDel.equals("") || clearHT.equals("S")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&change=1&type=2");
		return;
	}
	if(request.getParameter("addArticles")!=null){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&change=1&type=1");
		return;
	}

	if (mode.equalsIgnoreCase("approve")){
		ReqMgr.appSolicitud(ReqDet);
	}
	session.removeAttribute("ReqDet");
	session.removeAttribute("rqArt");
	session.removeAttribute("rqArtKey");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ReqMgr.getErrCode().equals("1")){
%>
	alert('<%=ReqMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_approve_solicitud_compra.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_approve_solicitud_compra.jsp")%>';
<%
	} else {
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/list_approve_solicitud_compra.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(ReqMgr.getErrMsg());
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
