<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Ajuste"%>
<%@ page import="issi.inventory.AjusteDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="AjuMgr" scope="page" class="issi.inventory.AjusteMgr" />
<jsp:useBean id="AjuDet" scope="page" class="issi.inventory.Ajuste" />
<jsp:useBean id="ajuArt" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ajuArtKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
AjuMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String numero = request.getParameter("numero");
String codigo = request.getParameter("codigo");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
int lineNo = 0;
boolean viewMode = false;
/*
INV250080		fg = DM = SOLICITUD DE DESCARTE DE MERCANCIA
INV250020		fg = ED = AJUSTES POR ERROR O DESCARTE
INV250050		fg = AI = SOLICITUD DE AJUSTE A INVENTARIO
INV250040		fg = ND = AJUSTES POR NOTA DE DEBITO
INV250070		fg = NE = AJUSTES A NOTAS DE ENTREGA
*/


if (mode == null) mode = "add";
if (fp == null) fp = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
			ajuArt.clear();
			ajuArtKey.clear();
	if (mode.equalsIgnoreCase("add"))
	{
		if (change == null)
		{
			AjuDet = new Ajuste();
			session.setAttribute("AjuDet",AjuDet);
			AjuDet.setNumeroAjuste("0");
			AjuDet.setFechaAjuste(CmnMgr.getCurrentDate("dd/mm/yyyy"));
			AjuDet.setAnioAjuste(AjuDet.getFechaAjuste().substring(6));
			AjuDet.setFg(fg);
		}
	}
	else
	{
	sql="select aj.anio_ajuste anioAjuste, aj.numero_ajuste numeroAjuste, aj.compania,aj.codigo_ajuste codigoAjuste, to_char(aj.fecha_ajuste,'dd/mm/yyyy')fechaAjuste, to_char(aj.fecha_sistema,'dd/mm/yyyy') fechaSistema,aj.usuario_mod usuarioMod, to_char(aj.fecha_mod,'dd/mm/yyyy') fechaMod, aj.anio_doc anioDoc,aj.numero_doc numeroDoc, aj.tipo_doc tipoDoc, aj.estado,nvl(aj.observacion,' ') observacion ,aj.itbm, aj.subtotal,aj.total, aj.usuario_creacion usuarioCreacion, to_char(aj.fecha_creacion,'dd/mm/yyyy') fechaCreacion,aj.codigo_almacen codigoAlmacen, aj.n_d nd, aj.cod_proveedor codProveedor,aj.pagado, aj.usuario_modificacion usuarioModificacion, to_char(aj.fecha_modificacion,'dd/mm/yyyy') fechaModificacion,aj.centro_servicio centroServicio, aj.pago,al.descripcion descAlmacen ,p.nombre_proveedor nombreProveedor, nvl(cds.descripcion ,' ') descCentroServ, nvl((select descripcion from tbl_inv_tipo_ajustes where codigo_ajuste = "+codigo+"), ' ') descAjuste, aj.cod_ref as codRef from tbl_inv_ajustes aj, tbl_inv_almacen al, tbl_com_proveedor p, tbl_cds_centro_servicio cds where aj.anio_ajuste = "+anio+" and aj.numero_ajuste = "+numero+" and aj.codigo_ajuste = "+codigo+" and al.compania = aj.compania  and aj.centro_servicio = cds.codigo(+) and aj.compania = "+(String) session.getAttribute("_companyId")+" and aj.codigo_almacen= al.codigo_almacen and aj.cod_proveedor = p.cod_provedor(+)";
		System.out.println("**************************************"+sql);
		AjuDet = (Ajuste) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Ajuste.class);


sql = "select da.compania, da.anio_ajuste, da.numero_ajuste,da.codigo_ajuste,da.cod_familia codFamilia, da.cod_clase codClase,da.cod_articulo codArticulo, da.cantidad_ajuste cantidadAjuste, da.precio,da.observacion, da.usuario_creacion, da.usuario_modificacion,da.check_aprov as checkAprov,nvl(da.cantidad_facturada,0) cantFact,nvl(da.cantidad_recibida,0) cantRec,nvl(da.unidad,' ') cantUnidad,a.descripcion articulo, nvl(a.cod_barra,' ')as codBarra from tbl_inv_detalle_ajustes da,tbl_inv_articulo a where da.cod_articulo = a.cod_articulo and da.anio_ajuste = "+anio+" and da.numero_ajuste = "+numero+" and da.codigo_ajuste = "+codigo+"  and da.compania = "+(String) session.getAttribute("_companyId")+" and a.compania = da.compania ";

			al = sbb.getBeanList(ConMgr.getConnection(), sql, AjusteDetails.class);
		System.out.println("sql = "+sql);

		for(int i=0;i<al.size();i++)
			{
				AjusteDetails det = (AjusteDetails) al.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try
				{
					ajuArt.put(key, det);
					ajuArtKey.put(det.getCodFamilia()+"-"+det.getCodClase()+"-"+det.getCodArticulo(), key);
				}	catch (Exception e)
				{
					System.out.println("Unable to addget item "+key);
				}
			}
			AjuDet.setFg(fg);
			session.setAttribute("AjuDet",AjuDet);
	}

    CommonDataObject cdo1 = (CommonDataObject)SQLMgr.getData(" select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'INV_OBLIGAR_COD_REF') as is_req_cod_ref from dual ");
    if (cdo1==null) cdo1 = new CommonDataObject();
    boolean isRefCodeRequired = ((cdo1.getColValue("is_req_cod_ref","N")).equalsIgnoreCase("Y") || (cdo1.getColValue("is_req_cod_ref","N")).equalsIgnoreCase("S"));
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script>
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Ajustes al Inventario - "+document.title;
<%}%>
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();checkTipoAjuste();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,100);}

function checkTipoAjuste(){
	var codigoAjuste = document.form1.codigoAjuste.value;
	if(codigoAjuste!='') setSignTA();
	else CBMSG.warning('Tipo de Ajuste Indefinido!');
}

function doSubmit(baction)
{
	document.form1.baction.value = baction;
	if(checkEstado())window.frames['itemFrame'].doSubmit();else CBMSG.warning('Revise Fecha de la transaccion');
}

function buscaCA(){
	codAlmacen = document.form1.codigoAlmacen.value;
	abrir_ventana2('../inventario/sel_aju_almacen.jsp?fg=<%=fg%>&codAlmacen='+codAlmacen);
}

function buscaP(){
	abrir_ventana1('../inventario/sel_proveedor.jsp?fp=ajuste&fg=<%=fg%>');
	$("#nombre_proveedor").val("");
	$("#anio_doc").val("");
	$("#numero_doc").val("");
	$("#num_factura").val("");
}

function buscaDoc(){
	var codProveedor = $("#proveedor").val();
	if(codProveedor=='') CBMSG.warning('Seleccione Proveedor!');
	else abrir_ventana1('../inventario/sel_recepcion.jsp?fp=ajuste&fg=<%=fg%>&codProveedor='+codProveedor);
}

function buscaCS(){
	abrir_ventana1('../inventario/sel_centro_serv.jsp?fp=ajuste&fg=<%=fg%>');
}
function reporte(fg){

	var wh = $("#codigoAlmacen").val();
	abrir_ventana1('../inventario/print_inv_ajustes_aprobados.jsp?fg='+fg+'&anio=<%=anio%>&noAjuste=<%=numero%>&codigo_ajuste=<%=codigo%>&almacen='+wh);
}

function chkDetail(){
	var size = window.frames['itemFrame'].document.form1.size.value;
	if(size>0){
		window.frames['itemFrame'].document.form1.clearHT.value="S";
		window.frames['itemFrame'].document.form1.submit();
	}
}

/*
function checkND(obj)
{
	var codProveedor = document.form1.proveedor.value;
	if(codProveedor=="") CBMSG.warning('Seleccione Proveedor!');
	else
	{
		if(hasDBData('<%=request.getContextPath()%>','tbl_inv_ajustes','n_d=\''+obj.value+'\' and codigo_ajuste=3 and cod_proveedor='+codProveedor,''))
		{
			CBMSG.warning('La Nota de Débito ya existe!');
			obj.focus();
		}
	}
}
*/
function viewSala(id)
{
var obj=document.getElementById('idSala');
if(id == '1')
obj.style.display='';
else obj.style.display='none';

}

function setSignTA(){
	var codigoAjuste = document.form1.codigoAjuste.value;
	var x = getDBData('<%=request.getContextPath()%>','sign_tipo_ajuste', 'tbl_inv_tipo_ajustes','codigo_ajuste='+codigoAjuste,'');
	document.form1.sign_tipo_ajuste.value = x;
}
var esInv ='S';
var whInv ='null';
function checkEstado(){
var estado = document.form1.estado.value; 
var wh = document.form1.codigoAlmacen.value;if(wh!='')whInv=wh; 
if(estado!='R'){
var fecha = document.form1.fechaAjuste.value;var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.form1.fechaAjuste.value='';return false;}else return true;}else return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%if(fg.equals("DM")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - SOLICITUD DE DESCARTE DE MERCANCIA"></jsp:param>
</jsp:include>
<%} else if(fg.equals("ED")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - AJUSTES POR ERROR O DESCARTE"></jsp:param>
</jsp:include>
<%} else if(fg.equals("AI")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - SOLICITUD DE AJUSTE A INVENTARIO"></jsp:param>
</jsp:include>
<%} else if(fg.equals("ND")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - AJUSTES POR NOTA DE DEBITO"></jsp:param>
</jsp:include>
<%} else if(fg.equals("NE")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - AJUSTES A NOTAS DE ENTREGA"></jsp:param>
</jsp:include>
<%}%>

<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("clearHT","")%>
      <%=fb.hidden("sign_tipo_ajuste","")%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">Ajuste al Inventario</td>
			</tr>
				<tr class="TextRow01">
					<td width="15%" align="right">Secuencia</td>
					<td width="35%">
					<%=fb.textBox("anio",AjuDet.getAnioAjuste(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("noAjuste",AjuDet.getNumeroAjuste(),false,false,true,10, "text10", null, null)%>
					</td>
					<td width="15%" align="right">Fecha Ajuste</td>
					
					<% //  se abre registro de fecha a solicitud de Depto. Compras HCH. 14/6/13  %>
					<td width="35%"><%String checkEstado = "javascript:checkEstado();newHeight();";%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="fechaAjuste"/>
				<jsp:param name="valueOfTBox1" value="<%=AjuDet.getFechaAjuste()%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="jsEvent" value="<%=checkEstado%>" />
				<jsp:param name="onChange" value="<%=checkEstado%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"N"%>"/>
				</jsp:include></td>
				</tr>
				<%
				String codAjuste = "", estado = "", displayDetail = "none";
				estado = "T=TRAMITE";

				// 	if(fg.equals("FAC")) estado = "A=APROBADO";   PARA USAR PROCESSO DE APROBACION DE AJUSTE POR QUE NO ESTABA REBAJNDO INVENTARIO CAUNDO TIPO DE AJUSTE ES ANULACION DE FACTURACION

				if(fg.equals("FAC")) estado = "T=TRAMITE";
				if(mode != null && mode.trim().equals("view")){
				estado = "T=TRAMITE,A=APROBADO,P=PENDIENTE,R=RECHAZADO";
				} else if(fp.equals("aprob")){
				estado = "T=TRAMITE,A=APROBADO,R=RECHAZADO";
				}
				%>
				<tr class="TextRow01" >
					<td align="right">Tipo</td>
					<td colspan="3">
          <%if(fp.equals("aprob")||viewMode){%>
					<%=fb.textBox("codigoAjuste",AjuDet.getCodigoAjuste(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("descAjuste",AjuDet.getDescAjuste(),false,false,true,50, "text10", null, null)%>
          <%} else {%>
					<%=fb.select(ConMgr.getConnection(),"select codigo_ajuste, descripcion from tbl_inv_tipo_ajustes where tipo_ajuste = '"+fg+"' and estado = 'A'","codigoAjuste",AjuDet.getCodigoAjuste(),false,(mode.trim().equals("view"))?true:false,0, "text10", "", "onChange=\"javascript:setSignTA(this.value)\"")%>
          <%}%>
                    &nbsp;&nbsp;
                    <cellbytelabel>C&oacute;d. Ref.</cellbytelabel>
                    <%=fb.textBox("cod_ref",AjuDet.getCodRef(),isRefCodeRequired,false,viewMode,20,30,null,null,"",null,false,isRefCodeRequired?"data-req='true'":"")%>
                    </td>
				</tr>
				<%if(fg.equals("GEN")){%>
				<tr class="TextRow01" >
					<td align="right">Proveedor</td>
					<td colspan="3">
					<%=fb.textBox("proveedor",AjuDet.getCodProveedor(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("nombre_proveedor",AjuDet.getNombreProveedor(),false,false,true,40, "text10", null, null)%>
					<%=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:buscaP()\"")%>
					</td>
				</tr>
				<%}%>
				<%if(fg.equals("FAC")){%>
				<tr class="TextRow02">
					<td colspan="4">Documento</td>
				</tr>
				<tr class="TextRow01" >
					<td align="right">Proveedor</td>
					<td colspan="3">
					<%=fb.textBox("proveedor",AjuDet.getCodProveedor(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("nombre_proveedor",AjuDet.getNombreProveedor(),false,false,true,40, "text10", null, null)%>
					<%=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:buscaP()\"")%>
					</td>
				</tr>
				<tr class="TextRow01" >
					<td align="right">N&uacute;mero</td>
					<td colspan="3">
					<%=fb.textBox("anio_doc",AjuDet.getAnioDoc(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("numero_doc",AjuDet.getNumeroDoc(),false,false,true,10, "text10", null, null)%>
					&nbsp;
					Factura
					&nbsp;
					<%
					if(mode.trim().equalsIgnoreCase("add")) {%>
					<%=fb.textBox("num_factura",AjuDet.getNumFactura(),false,false,true,10, "text10", null, null)%>
					<%=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:buscaDoc()\"")%>
					<%
					} else {
					%>
		<%=fb.select(ConMgr.getConnection(), "select numero_factura from tbl_inv_recepcion_material where anio_recepcion="+AjuDet.getAnioDoc()+" and numero_documento="+AjuDet.getNumeroDoc()+" and compania= "+(String) session.getAttribute("_companyId"), "num_factura", AjuDet.getNumFactura(),false,true,0,"","","")%>
					<%
					}
					%>
					</td>
				</tr>
				<%}%>
				<%if(fg.equals("NE")){%>
				<tr class="TextRow02">
					<td colspan="4">Documento</td>
				</tr>
				<tr class="TextRow01" >
					<td align="right">Proveedor</td>
					<td colspan="3">
					<%=fb.textBox("proveedor",AjuDet.getCodProveedor(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("nombre_proveedor",AjuDet.getNombreProveedor(),false,false,true,40, "text10", null, null)%>
					<%=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:buscaP()\"")%>
					</td>
				</tr>
				<tr class="TextRow01" >
					<td align="right">N&uacute;mero de Documento</td>
					<td colspan="3">
					<%=fb.textBox("numero_doc",AjuDet.getNumeroDoc(),false,false,viewMode,10, "text10", null, null)%>
					</td>
				</tr>
				<%}%>
				<tr class="TextRow01">
          <td align="right">Observaci&oacute;n</td>
          <td colspan="3"><%=fb.textarea("observacion",AjuDet.getObservacion(),false,false,viewMode,60,4)%> </td>
        </tr>
				<tr class="TextRow01" >
					<td align="right">Almac&eacute;n</td>
					<td colspan="3">
          <%if(fp.equals("aprob")){%>
					<%=fb.textBox("codigoAlmacen",AjuDet.getCodigoAlmacen(),false,false,true,5, "text10", null, null)%>
					<%=fb.textBox("nombreAlmacen",AjuDet.getDescAlmacen(),false,false,true,40, "text10", null, null)%>
          <%} else {%>
          <%
				StringBuffer sbSql = new StringBuffer();
				if(!UserDet.getUserProfile().contains("0")&&!mode.trim().equals("view"))
				{
					sbSql.append(" and codigo_almacen in (");
						if(session.getAttribute("_almacen_inv")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_inv")));
						else sbSql.append("-2");
					sbSql.append(")");
				}

					sql = "select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion";
					if(fg.equals("NE"))
						sql = "select distinct a.codigo_almacen, a.descripcion from tbl_inv_recepcion_material b, tbl_inv_almacen a where b.compania = a.compania and     b.codigo_almacen = a.codigo_almacen and b.fre_documento = 'NE' and a.compania = "+session.getAttribute("_companyId") + " order by a.descripcion";
					%>
					<%=fb.select(ConMgr.getConnection(),sql,"codigoAlmacen",(AjuDet.getCodigoAlmacen()!=null && !AjuDet.getCodigoAlmacen().equals("")?AjuDet.getCodigoAlmacen():(SecMgr.getParValue(UserDet,"almacen_inv")!=null && !SecMgr.getParValue(UserDet,"almacen_inv").equals("")?SecMgr.getParValue(UserDet,"almacen_inv"):"")),false,(mode.trim().equals("view"))?true:false,0, "text10", "", "onChange=\"javascript:chkDetail();\"")%>
          <%}%>
					&nbsp;
					Estado
					<%=fb.select("estado",estado,AjuDet.getEstado(), false, (mode.trim().equals("view"))?true:false, 0, "text10", null, null)%>
					<%=fb.button("imprimir","Reporte",false,(!mode.trim().equals("add"))?false:true,"","","onClick=\"javascript:reporte('AJ')\"")%>
					<%=fb.button("imprimir","Art. Aprobados",false,(!mode.trim().equals("add"))?false:true,"","","onClick=\"javascript:reporte('AP')\"")%>
					</td>
				</tr>
				<%if(fg.equals("AI")){%>
				<tr class="TextRow01" id="idSala" style="display:<%=displayDetail%>">
					<td align="right">Sala/Centro</td>
					<td colspan="3">
					<%=fb.textBox("sala",AjuDet.getCentroServicio(),false,false,true,5)%>
					<%=fb.textBox("desc_centro",AjuDet.getDescCentroServ(),false,false,true,40)%>
					<%=fb.button("buscarCS","...",false,viewMode,"","","onClick=\"javascript:buscaCS()\"")%>
					</td>
				</tr>
				<%}%>
				<tr>
					<td colspan="4"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="0" scrolling="yes" src="../inventario/reg_ajuste_item.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","N")%>Crear Otro
						<!--<%=fb.radio("saveOption","O")%>Mantener Abierto -->
						<%=fb.radio("saveOption","C",true,false,viewMode)%>Cerrar
						<%if(fg.equals("GEN") && fp.equals("aprob")){%>
						<authtype type='50'>
						<%=fb.radio("saveOption","A",true,false,viewMode)%>Crear Ajuste CXP
						</authtype>
						<%}%>
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				   		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<%fb.appendJsValidation("if(!checkEstado()){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");%>
				<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String errCode = "";
	String errMsg = "";
	String wh = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
		anio = request.getParameter("anio");
		numero = request.getParameter("noAjuste");
		codigo = request.getParameter("codigoAjuste");
		wh = request.getParameter("codigoAlmacen");

	}

	session.removeAttribute("AjuDet");
	session.removeAttribute("ajuArt");
	session.removeAttribute("ajuArtKey");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
closeChild=false;
function closeWindow()
{
<%
if (request.getParameter("baction").equalsIgnoreCase("Cancelar"))
{
%>
	window.close();
<%
}
else
{
	if (errCode.equals("1"))
	{
%>
	alert('<%=errMsg%>');
<%
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_ajuste.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_ajuste.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/list_ajuste.jsp?fg=<%=fg%>&fp=<%=fp%>';
<%
		}

		if (request.getParameter("saveOption") != null && request.getParameter("saveOption").equals("N"))
		{
%>
	window.location = '../inventario/reg_ajuste.jsp?fg=<%=fg%>&fp=<%=fp%>';
<%
		}
		else
		{
		
		if(fp.equals("aprob") && request.getParameter("saveOption") != null && request.getParameter("saveOption").equals("A")&& request.getParameter("estado").trim().equals("A") ){
		%>
		abrir_ventana2('../inventario/print_inv_ajustes_aprobados.jsp?fg=AP&anio=<%=anio%>&noAjuste=<%=numero%>&codigo_ajuste=<%=codigo%>&almacen=<%=wh%>');
		window.location = '../cxp/nota_ajuste_config.jsp?fp=INV&anio=<%=anio%>&numero=<%=numero%>&codigo=<%=codigo%>';
		<%
		} else {
%>
<%
	if(fp.equals("aprob")){
	if(request.getParameter("estado").trim().equals("A")){
%>		abrir_ventana2('../inventario/print_inv_ajustes_aprobados.jsp?fg=AP&anio=<%=anio%>&noAjuste=<%=numero%>&codigo_ajuste=<%=codigo%>&almacen=<%=wh%>');
<%}%>
	window.close();
	<%} else {%>
	setTimeout('closeW()',500);
<%}}%>
	//window.close();
<%
		}
	} else throw new Exception(errMsg);
}
%>
}
function closeW()
{
	window.location = '<%=request.getContextPath()%>/inventario/print_inv_ajustes_aprobados.jsp?fg=AJ&anio=<%=anio%>&noAjuste=<%=numero%>&codigo_ajuste=<%=codigo%>&almacen=<%=wh%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

