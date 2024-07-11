<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
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
String sql = "", key = "", filterTr ="";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio = request.getParameter("anio");
String almacen = request.getParameter("almacen");
String tr = request.getParameter("tr");

if(anio == null) anio=fecha.substring(6, 10);
String mes = request.getParameter("mes");
if(mes == null) mes=fecha.substring(4,5);
String tipoSolicitud = request.getParameter("tipoSolicitud");
String type = request.getParameter("type");
String utilizaPres = java.util.ResourceBundle.getBundle("issi").getString("utilizaPres");
if(utilizaPres==null || utilizaPres.equals("")) utilizaPres = "S";

int lineNo = 0;
/*
===================================================================================
tr	= 	Tipo de requisicion
===================================================================================
UA	= 	REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMINISTRATIVAS
UAT = 	REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMINISTRATIVAS TEMPORALES
SM	=		REQUISICION DE MATERIALES PARA SERVICIOS DE MANTENIMIENTO
EC	=		REQUISICION DE MATERIALES ENTRE COMPAÑIAS
EA	=		REQUISICION DE MATERIALES ENTRE ALMACENES
===================================================================================
*/

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
		ReqDet.setReqType(tr);
	}
	if (mode.equalsIgnoreCase("approve"))
	{
		if (id == null) throw new Exception("Requisición no es válida. Por favor intente nuevamente!");

		if (change==null){

		if(!UserDet.getUserProfile().contains("0"))
		if(tr.trim().equals("UA") || tr.trim().equals("UAT")|| tr.trim().equals("EC"))
		if(session.getAttribute("_ua")!=null)filterTr += "AND codigo IN ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua"))+")";
		else filterTr += " AND codigo IN (-1)";

			sql = "SELECT a.anio, a.tipo_solicitud tipoSolicitud, a.solicitud_no noSolicitud, a.compania, a.usuario_creacion usuarioCrea, a.fecha_creacion fechaCrea, TO_CHAR(NVL(a.fecha_modificacion,SYSDATE),'dd/mm/yyyy') fechaModifica, a.usuario_modif usuarioModifica, to_char(nvl(a.fecha_documento,sysdate),'dd/mm/yyyy') fechaDocto, NVL(a.observacion,'NA') observacion, NVL(a.sol_mes,0) solMes, NVL(a.estado_solicitud,'T') estadoSolicitud, NVL(a.status,'A') status, NVL(a.tipo_material,'0') tipoMaterial, NVL(a.activa,'A') activa, NVL(a.unidad_administrativa,0) unidadAdmin, NVL(a.codigo_almacen,0) codAlmacen, a.tipo_transferencia tipoTransferencia, NVL(a.codigo_almacen_ent,0) codAlmacenEnt, a.compania_sol companiaSol, nvl(e.nombre,'') descCompaniaSol, NVL(a.codigo_centro,0) codCentro, NVL(a.usuario_aprob,'0') usuarioAprob, NVL(a.num_requi,'0') noRequisicion, nvl(b.descripcion,' ') descUnidadAdmin, NVL(c.descripcion,' ') descCodAlmacen, NVL(d.descripcion,' ') descCodAlmacenEnt FROM TBL_INV_SOLICITUD_REQ a, (SELECT codigo, descripcion FROM TBL_SEC_UNIDAD_EJEC WHERE compania = "+session.getAttribute("_companyId")+" AND nivel > 0 AND codigo >= 1  "+filterTr+" ) b, TBL_INV_ALMACEN c, TBL_INV_ALMACEN d, tbl_sec_compania e WHERE a.unidad_administrativa = b.codigo(+) and a.compania = "+session.getAttribute("_companyId")+" and a.anio = "+anio+" and a.tipo_solicitud = '"+tipoSolicitud+"' and a.solicitud_no="+id+" "+(tr.equals("SM")?" and c.compania = 1 and c.codigo_almacen = 5 ":"AND a.compania_sol = c.compania(+)  AND a.codigo_almacen = c.codigo_almacen(+)")+" AND "+(tr.equals("EC")?"a.compania_sol":"a.compania")+" = d.compania(+) AND a.codigo_almacen_ent = d.codigo_almacen(+) and a.compania_sol = e.codigo(+)";

			if(tr.trim().equals("UA")){


						sql=" select x.*,esm.mescontable mesContable,esm.aniocontable anioContable from ( select a.anio, a.tipo_solicitud tiposolicitud, a.solicitud_no nosolicitud, a.compania, a.usuario_creacion usuariocrea, a.fecha_creacion fechacrea, to_char(nvl(a.fecha_modificacion,sysdate),'dd/mm/yyyy') fechamodifica, a.usuario_modif usuariomodifica, to_char(nvl(a.fecha_documento,sysdate),'dd/mm/yyyy') fechadocto, nvl(a.observacion,' ') observacion, nvl(a.sol_mes,0) solmes, nvl(a.estado_solicitud,'T') estadosolicitud, nvl(a.status,'A') status, nvl(a.tipo_material,'0') tipomaterial, nvl(a.activa,'A') activa, nvl(a.unidad_administrativa,0) unidadAdmin, nvl(a.codigo_almacen,0) codalmacen, a.tipo_transferencia tipotransferencia, nvl(a.codigo_almacen_ent,0) codalmacenent, a.compania_sol companiaSol, nvl(e.nombre,'') desccompaniasol, nvl(a.codigo_centro,0) codcentro, nvl(a.usuario_aprob,'0') usuarioaprob, nvl(a.num_requi,'0') norequisicion, nvl(b.descripcion,' ') descunidadadmin, nvl(c.descripcion,' ') desccodalmacen, nvl(d.descripcion,' ') desccodalmacenent, nvl(zz.cargo,0) cargo from tbl_inv_solicitud_req a,(select nvl(sum(nvl(cargo,0)),0) cargo, unidad from ( select     all sum(nvl(de.cantidad,0)) devuelto, sum(nvl(de.cantidad,0)*nvl(de.precio,0)) cargo,em.unidad_administrativa unidad from     tbl_inv_detalle_entrega de,  tbl_inv_entrega_material em, tbl_inv_solicitud_req sr, tbl_inv_articulo ar where (de.compania =  "+session.getAttribute("_companyId")+"  and em.codigo_almacen = "+almacen+" and to_number(to_char(em.fecha_entrega, 'yyyy')) = "+anio+"and    to_number(to_char(em.fecha_entrega, 'mm')) >= "+mes+" and sr.tipo_transferencia = 'U' and ar.consignacion_sino = 'N') and ((de.anio = em.anio) and (de.no_entrega = em.no_entrega) and (de.compania = em.compania) and (em.req_anio = sr.anio) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_solicitud_no = sr.solicitud_no) and (em.compania_sol = sr.compania) and (de.cod_articulo = ar.cod_articulo)  and (de.compania = ar.compania)) group by em.unidad_administrativa union select     all sum(nvl(dd.cantidad, 0)) entregado, sum(nvl(dd.cantidad, 0)*nvl(dd.precio, 0))*-1 cargo, de.unidad_administrativa from     tbl_inv_detalle_devolucion dd,  tbl_inv_devolucion de, tbl_inv_articulo ar where (dd.compania =  "+session.getAttribute("_companyId")+"  and de.codigo_almacen = "+almacen+" and to_number(to_char(de.fecha_devolucion, 'yyyy')) ="+anio+" and to_number(to_char(de.fecha_devolucion, 'mm')) >= "+mes+" and ar.consignacion_sino = 'N') and ((dd.anio_devolucion = de.anio_devolucion) and (dd.num_devolucion = de.num_devolucion) and (dd.compania = de.compania) and (dd.cod_articulo = ar.cod_articulo) and (dd.compania = ar.compania)) group by de.unidad_administrativa ) group by unidad ) zz,(select codigo, descripcion from tbl_sec_unidad_ejec where compania = "+session.getAttribute("_companyId")+" and nivel >0 and codigo >= 1 "+filterTr+"  ) b, tbl_inv_almacen c, tbl_inv_almacen d, tbl_sec_compania e where a.unidad_administrativa = b.codigo(+) and a.compania = "+session.getAttribute("_companyId")+" and a.anio = "+anio+" and a.tipo_solicitud =  '"+tipoSolicitud+"' and a.solicitud_no= "+id+" and a.compania = c.compania(+) and a.compania = d.compania(+) and a.codigo_almacen = c.codigo_almacen(+) and a.codigo_almacen_ent = d.codigo_almacen(+) and a.compania_sol = e.codigo(+)   and zz.unidad(+) = a.unidad_administrativa group by a.anio, a.tipo_solicitud , a.solicitud_no , a.compania, a.usuario_creacion , a.fecha_creacion , to_char(nvl(a.fecha_modificacion,sysdate),'dd/mm/yyyy') , a.usuario_modif , to_char(nvl(a.fecha_documento,sysdate),'dd/mm/yyyy') , nvl(a.observacion,' ') , nvl(a.sol_mes,0) , nvl(a.estado_solicitud,'T') , nvl(a.status,'A') , nvl(a.tipo_material,'0') , nvl(a.activa,'A') , nvl(a.unidad_administrativa,0) , nvl(a.codigo_almacen,0) , a.tipo_transferencia , nvl(a.codigo_almacen_ent,0) , a.compania_sol , nvl(e.nombre,'') , nvl(a.codigo_centro,0) , nvl(a.usuario_aprob,'0') , nvl(a.num_requi,'0') , nvl(b.descripcion,' ') , nvl(c.descripcion,' ') , nvl(d.descripcion,' ') ,zz.unidad,zz.cargo ) x ,(    select  cod_cia compania , case when   to_number(substr(max(to_number(ano||to_char(mes,'fm09'))),5,2)) >= 12 then to_number(substr(max(to_number(ano||to_char(mes,'fm09'))),1,4)) +1 else to_number(substr(max(to_number(ano||to_char(mes,'fm09'))),1,4)) end  as aniocontable , case when   to_number(substr(max(to_number(ano||to_char(mes,'fm09'))),5,2)) >= 12 then 1 else to_number(substr(max(to_number(ano||to_char(mes,'fm09'))),5,2)) end  as mescontable from tbl_con_estado_meses where    cod_cia = "+session.getAttribute("_companyId")+" and estatus = 'CER' group by cod_cia ) esm where x.compania = esm.compania(+) ";




		}

			System.out.println("sql..apro..="+sql);
			ReqDet = (Requisicion) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Requisicion.class);
			ReqDet.setReqType(tr);
		if(tr.trim().equals("UA"))
		{
			sql="select nvl(sum(asignacion),0) asignacion, nvl(sum(consumido),0) consumido,nvl(sum(variacion),0) variacion from( select aca.unidad,aca.cta1||aca.cta2||aca.cta3||aca.cta4||aca.cta5||aca.cta6||aca.compania_origen cuenta , nvl(sum(nvl(asignacion,0)),0)  asignacion, nvl(sum( nvl(consumido,0)),0)  consumido, nvl((sum( nvl(asignacion,0))- sum(nvl(consumido,0))),0) variacion from tbl_con_cuenta_mensual aca where   aca.compania = "+session.getAttribute("_companyId")+" and anio = "+anio+" and to_number(mes) <= "+mes+" and (aca.cta1||aca.cta2||aca.cta3||aca.cta4||aca.cta5||aca.cta6||aca.compania_origen) in ( select distinct a.cta1||a.cta2||a.cta3||a.cta4||a.cta5||a.cta6||fa.compania from tbl_inv_familia_articulo fa,tbl_inv_unidad_costos a  where fa.compania = "+session.getAttribute("_companyId")+" and fa.cat_cta1 is not null and a.familia=fa.cod_flia and a.cia=fa.compania and  a.unid_adm="+ReqDet.getUnidadAdmin()+") group by aca.unidad, aca.cta1||aca.cta2||aca.cta3||aca.cta4||aca.cta5||aca.cta6||aca.compania_origen )";

			cdo = SQLMgr.getData(sql);
		}
		if(cdo == null)
		{
			cdo = new  CommonDataObject();
			cdo.addColValue("asignacion","0");
			cdo.addColValue("consumido","0");
			cdo.addColValue("variacion","0");
		}
		ReqDet.setAsignacion(cdo.getColValue("asignacion"));
		ReqDet.setConsumido(cdo.getColValue("consumido"));
		ReqDet.setVariacion(cdo.getColValue("variacion"));




			sql = "SELECT  a.*, a.cat_cta1 fliaCta1, a.cat_cta2 fliaCta2, a.cat_cta3 fliaCta3, a.cat_cta4 fliaCta4, a.cat_cta5 fliaCta5, a.cat_cta6 fliaCta6, 'S' fromReq, b.estado_renglon estadoRenglon, b.cantidad, b.despachado, b.costo, NVL(c.asignacion,0) asignacion, NVL(consumido, 0) consumido, (NVL(asignacion,0)-NVL(consumido,0)) - nvl(zz.entregas,0) variacion  ,nvl(zz.entregas,0) entregas FROM (SELECT distinct a.cod_articulo art_key, a.compania, a.cod_flia artFamilia, a.cod_clase artClase, a.cod_articulo codArticulo, a.descripcion artDesc, a.itbm, a.cod_medida unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, (select c.descripcion from tbl_inv_clase_articulo c where c.compania = a.compania AND c.cod_flia = a.cod_flia AND c.cod_clase = a.cod_clase) as descArtClase, d.precio, d.ultimo_precio ultimoPrecio, (b.cat_cta1||'-'||b.cat_cta2||'-'||b.cat_cta3||'-'||b.cat_cta4||'-'||b.cat_cta5||'-'||b.cat_cta6) cta_key, b.cat_cta1, b.cat_cta2, b.cat_cta3, b.cat_cta4, b.cat_cta5, b.cat_cta6,d.codigo_almacen, (select descripcion from tbl_inv_unidad_medida where cod_medida = a.cod_medida) as unidadDesc FROM TBL_INV_ARTICULO a, (SELECT f.compania, f.cod_flia, f.nombre, NVL(f.cat_cta1,'0') cat_cta1, NVL(f.cat_cta2,'0') cat_cta2, NVL(DECODE(f.cat_cta3,'000',TO_CHAR("+ReqDet.getUnidadAdmin()+",'fm009'),f.cat_cta3),'0') cat_cta3, NVL(f.cat_cta4,'0') cat_cta4, NVL(f.cat_cta5,'0') cat_cta5, NVL(f.cat_cta6,'0') cat_cta6 FROM TBL_INV_FAMILIA_ARTICULO f) b, TBL_INV_INVENTARIO d WHERE (d.compania = a.compania AND d.cod_articulo = a.cod_articulo) AND (a.compania = b.compania AND a.cod_flia = b.cod_flia) AND d.compania = "+ReqDet.getCompaniaSol()+" /*"+session.getAttribute("_companyId")+" estaba comentada compañia pero no se por que quite comentario 20091709 benito */ ) a, (SELECT a.cod_articulo art_key, a.estado_renglon, a.cantidad, NVL(a.despachado,0) despachado, NVL(costo,0) costo,decode(tipo_transferencia,'U',x.codigo_almacen,'A',x.codigo_almacen_ent,x.codigo_almacen)codigo_almacen FROM TBL_INV_D_SOL_REQ a,TBL_INV_SOLICITUD_REQ x WHERE a.compania = "+session.getAttribute("_companyId")+" AND a.estado_renglon = 'P' AND a.req_anio = "+ReqDet.getAnio()+" AND a.solicitud_no = "+id+" AND a.tipo_solicitud = '"+tipoSolicitud+"' AND a.compania="+session.getAttribute("_companyId")+" and x.anio =a.req_anio and x.solicitud_no= a.solicitud_no and  x.tipo_solicitud = a.tipo_solicitud and x.compania=a.compania) b, (SELECT (cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6) cta_key, SUM(asignacion) asignacion, SUM(consumido) consumido FROM TBL_CON_CUENTA_MENSUAL WHERE compania = "+session.getAttribute("_companyId")+" AND unidad = "+ReqDet.getUnidadAdmin()+" AND anio = "+ReqDet.getAnio()+" AND TO_NUMBER(mes) <= "+mes+" GROUP BY (cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6)) c, ( /* ********************** entregas y devoluciones ***************************/ select sum(nvl(cargo,0)) entregas, cod_familia from ( select     all de.cod_familia ,sum(nvl(de.cantidad,0)) devuelto, sum(nvl(de.cantidad,0)*nvl(de.precio,0)) cargo from tbl_inv_detalle_entrega de, tbl_inv_entrega_material em,tbl_inv_solicitud_req sr, tbl_inv_articulo ar where (de.compania = "+session.getAttribute("_companyId")+" and de.cod_familia  not in (select column_value from table (select split((get_sec_comp_param(em.compania,'FLIA_ACTIVO')),',') from dual)) and em.codigo_almacen ="+almacen+" and em.unidad_administrativa = "+ReqDet.getUnidadAdmin()+"  and to_number(to_char(em.fecha_entrega, 'YYYY')) = to_number("+(tr.equals("UA")?ReqDet.getAnioContable():ReqDet.getAnio())+") and to_number(to_char(em.fecha_entrega, 'MM')) >=  to_number("+(tr.equals("UA")?ReqDet.getMesContable():mes)+") and sr.tipo_transferencia = 'U' and ar.consignacion_sino = 'N') and ((de.anio = em.anio) and (de.no_entrega = em.no_entrega)  and (de.compania = em.compania) and (em.req_anio = sr.anio) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_solicitud_no = sr.solicitud_no) and (em.compania_sol = sr.compania) and (de.cod_articulo = ar.cod_articulo)  and (de.compania = ar.compania)) group by de.cod_familia  union select all  dd.cod_familia  , sum(nvl(dd.cantidad, 0)) entregado,  sum(nvl(dd.cantidad, 0)*nvl(dd.precio, 0))*-1 cargo from tbl_inv_detalle_devolucion dd,tbl_inv_devolucion de, tbl_inv_articulo ar where (dd.compania = "+session.getAttribute("_companyId")+" and dd.cod_familia not in (select column_value from table (select split((get_sec_comp_param(dd.compania,'FLIA_ACTIVO')),',') from dual)) and de.codigo_almacen = "+almacen+" and de.unidad_administrativa = "+ReqDet.getUnidadAdmin()+"  and to_number(to_char(de.fecha_devolucion, 'YYYY')) = to_number("+(tr.equals("UA")?ReqDet.getAnioContable():ReqDet.getAnio())+") and to_number(to_char(de.fecha_devolucion, 'MM')) >= to_number("+(tr.trim().equals("UA")?ReqDet.getMesContable():mes)+") and ar.consignacion_sino = 'N') and ((dd.anio_devolucion = de.anio_devolucion) and (dd.num_devolucion = de.num_devolucion) and (dd.compania = de.compania) and (dd.cod_articulo = ar.cod_articulo) and (dd.compania = ar.compania) and de.estado = 'R' and dd.estado_renglon= 'E') group by  dd.cod_familia )group by  cod_familia    /* *************************************************/ )zz WHERE a.art_key = b.art_key AND a.cta_key = c.cta_key(+) and a.codigo_almacen=b.codigo_almacen  and a.artfamilia = zz.cod_familia(+) order by artfamilia desc, artclase, codarticulo, artDesc asc ";

			System.out.println("sqlDetails....="+sql);
			ReqDet.setReqDetails(sbb.getBeanList(ConMgr.getConnection(), sql, RequisicionDetail.class));

			sql = "SELECT unidad, cta1 fliaCta1, cta2 fliaCta2, cta3 fliaCta3, cta4 fliaCta4, cta5 fliaCta5, cta6 fliaCta6, sum(nvl(asignacion,0)) asignacion, sum(nvl(consumido,0)) consumido, sum(nvl(asignacion,0) - nvl(consumido,0)) variacion FROM TBL_CON_CUENTA_MENSUAL WHERE compania = "+session.getAttribute("_companyId")+" AND anio = "+ReqDet.getAnio()+" AND TO_NUMBER(mes) <= "+mes+" and unidad =  "+ReqDet.getUnidadAdmin()+" group by unidad, cta1, cta2, cta3, cta4, cta5, cta6";


			rqVar = sbb.getBeanList(ConMgr.getConnection(), sql, RequisicionDetail.class);
			for(int i=0;i<rqVar.size();i++){
				RequisicionDetail req = (RequisicionDetail) rqVar.get(i);
				if(req.getFliaCta3().equals("000")) req.setFliaCta3("00"+ReqDet.getUnidadAdmin());
				String ctaKey = 	req.getUnidad()+"_"+req.getFliaCta1()+"_"+req.getFliaCta2()+"_"+req.getFliaCta3()+"_"+req.getFliaCta4()+"_"+req.getFliaCta5()+"_"+req.getFliaCta6();

				ReqVar.put(ctaKey,req);
			}


			System.out.println("sqlCtas....="+sql);

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
var _var = new Array(<%=rqVar.size()%>);
var i = 0;
<%
for(int i=0;i<rqVar.size();i++){
	RequisicionDetail rqv = (RequisicionDetail) rqVar.get(i);
%>
	var _varDet = new Array(10);
	_varDet[1]=<%=rqv.getUnidad()%>;
	_varDet[2]=<%=rqv.getFliaCta1()%>;
	_varDet[3]=<%=rqv.getFliaCta2()%>;
	_varDet[4]=<%=rqv.getFliaCta3()%>;
	_varDet[5]=<%=rqv.getFliaCta4()%>;
	_varDet[6]=<%=rqv.getFliaCta5()%>;
	_varDet[7]=<%=rqv.getFliaCta6()%>;
	_varDet[8]=<%=rqv.getAsignacion()%>;
	_varDet[9]=<%=rqv.getConsumido()%>;
	_varDet[10]=<%=rqv.getVariacion()%>;
	_var[<%=i%>] = _varDet;
<%
}
%>
function setVariacion(id){

	var size = document.requisicion.keySize.value;
	var variacion = 0;
	for(i=0;i<size;i++){
		if(_var[i][0]==id){
			var cta1 = eval('document.requisicion.cta1_'+i).value;
			var cta2 = eval('document.requisicion.cta2_'+i).value;
			var cta3 = eval('document.requisicion.cta3_'+i).value;
			var cta4 = eval('document.requisicion.cta4_'+i).value;
			var cta5 = eval('document.requisicion.cta5_'+i).value;
			var cta6 = eval('document.requisicion.cta6_'+i).value;
			for(j=0;j<<%=rqVar.size()%>;j++){
				if(id == _var[j][1] && cta1==_var[j][2] && cta2==_var[j][3] && cta3==_var[j][4] && cta4==_var[j][5] && cta5==_var[j][6] && cta6==_var[j][7]){
					variacion=_var[i][10];
				}
			}
			eval('document.requisicion.presDisp'+i).value = variacion;
		}
	}
}
function doAction(){
	var ua = document.requisicion.unidad_administrativa.value;
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../inventario/sel_articles.jsp?fp=approve&tr=<%=tr%>&mode=<%=mode%>&id=<%=id%>&anio=<%=ReqDet.getAnio()%>&unidad_administrativa='+ua+'&tipoSolicitud=<%=tipoSolicitud%>');
	<%
	}
	%>
	<%if(tr.trim().equals("UA")&&utilizaPres.trim().equals("S")){%>
	calMonto();
	<%}%>
}

function buscaUE(){
	abrir_ventana2('../inventario/sel_unid_ejec.jsp?fg=<%=ReqDet.getReqType()%>');
}

function buscaCA(flag){
	if(flag==1)	abrir_ventana2('../inventario/sel_almacen.jsp?tr=<%=tr%>&flag=1');
	<%
	if(ReqDet.getReqType().equals("EA")){
	%>
	var codAlmacen = document.requisicion.codigo_almacen.value;
	if(flag==2){
		if(codAlmacen=="") alert("Seleccione 'Solicitado por' primero!");
		else abrir_ventana2('../inventario/sel_almacen.jsp?tr=<%=tr%>&flag=2&codAlmacen='+codAlmacen);
	}
	<%
	} else if(ReqDet.getReqType().equals("EC")){
	%>
	if(flag==3)	abrir_ventana2('../inventario/sel_almacen.jsp?tr=<%=tr%>&flag=3');
	<%
	}
	%>
}

function buscaCS(){
	abrir_ventana2('../inventario/sel_compania.jsp');
}

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

function calMonto(){
 var size = document.requisicion.keySize.value;
 var x = 0;
 var sub_total = 0.0000;
 var presupuesto =0.0000;
 var consumido =0.0000;
 var entregas =0.0000;
 var v_variacion =0.00;
 if(!isNaN(eval('document.requisicion.presupuesto').value)) presupuesto = parseFloat(document.requisicion.presupuesto.value);
 else if(!isNaN((eval('document.requisicion.presupuesto').value).replace(',',''))) presupuesto = parseFloat((eval('document.requisicion.presupuesto').value).replace(',',''));
 if(!isNaN(eval('document.requisicion.consumido').value)) consumido = parseFloat(document.requisicion.consumido.value);
 else if(!isNaN((eval('document.requisicion.consumido').value).replace(',',''))) consumido = parseFloat((eval('document.requisicion.consumido').value).replace(',',''));
 if(!isNaN(eval('document.requisicion.entregas').value)) entregas = parseFloat(document.requisicion.entregas.value);
 else if(!isNaN((eval('document.requisicion.entregas').value).replace(',',''))) entregas = parseFloat((eval('document.requisicion.entregas').value).replace(',',''));

 //if(!isNaN(eval('document.requisicion.entregas').value)) entregas = parseFloat(document.requisicion.entregas.value);
 for(i=0;i<size;i++)
 {
	if(!isNaN(eval('document.requisicion.cantidad'+i).value))
	{
	if(!isNaN(eval('document.requisicion.presDisp'+i).value)) v_variacion = parseFloat(eval('document.requisicion.presDisp'+i).value);

	cantidad = eval('document.requisicion.cantidad'+i).value;
	_precio  = eval('document.requisicion.precio'+i).value;
	sub_total += (cantidad*_precio);

	 if( v_variacion < 0) alert('Disponible en presupuesto AGOTADO!!!!');

	//eval('document.requisicion.disponible'+i).value = (cantidad * _precio).toFixed(4);

	}
 }
 /*
 alert('presupuesto='+presupuesto);
 alert('consumido='+consumido);
 alert('entregas='+entregas);
 alert('sub_total='+sub_total);
 */
 document.requisicion.presupuesto.value = formatCurrency(presupuesto,2);
 document.requisicion.consumido.value = formatCurrency(consumido,2);
 document.requisicion.entregas.value = formatCurrency(entregas,4);
 document.requisicion.monto_req.value = formatCurrency(sub_total,4);//(sub_total).toFixed(4);
 var disponible = presupuesto - (consumido+entregas+ parseFloat(sub_total));
 document.requisicion.disponible.value =  formatCurrency(disponible,4); /*(disponible).toFixed(4); */
 /*
 document.requisicion.monto_req.value = (sub_total).toFixed(4);
 document.requisicion.disponible.value = (presupuesto - (consumido+entregas+ parseFloat(sub_total))).toFixed(4);
 */

/*
nvl(:cg$ctrl.dsp_presupuestado,0) -
(nvl(:cg$ctrl.dsp_consumido,0) +
 nvl(:cg$ctrl.dsp_entregado,0) +
 nvl(:det_sol3.total_requisicion,0))*/

}
$(document).ready(function(){jqTooltip();});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
	<%
	if(ReqDet.getReqType().equals("UA")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBAR REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN."></jsp:param>
</jsp:include>
	<%
	} else if(ReqDet.getReqType().equals("UAT")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBAR REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN. - TEMPORAL"></jsp:param>
</jsp:include>
	<%
	} else if(ReqDet.getReqType().equals("SM")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBAR REQ. MATERIALES PARA SERVICIOS DE MANTENIMIENTO"></jsp:param>
</jsp:include>
	<%
	} else if(ReqDet.getReqType().equals("EC")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBAR REQ. DE MATERIALES ENTRE COMPA&Ntilde;IAS"></jsp:param>
</jsp:include>
	<%
	} else if(ReqDet.getReqType().equals("EA")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBAR REQ. DE MATERIALES ENTRE ALMACENES"></jsp:param>
</jsp:include>
	<%
	}
	%>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("requisicion",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
	<tr>
		<td class="TableBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow02">
								<td colspan="8" align="right">&nbsp;</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="8">Requisici&oacute;n</td>
							</tr>
							<tr class="TextRow01">
								<td width="12%" align="right">Requisici&oacute;n No.</td>
								<td width="15%">
								<%=fb.textBox("anio",ReqDet.getAnio(),true,false,true,4,null,null,"")%>
								<%=fb.textBox("solicitud_no",(ReqDet.getNoSolicitud()!=null)?ReqDet.getNoSolicitud():"0",true,false,true,4,null,null,"")%>
								</td>

								<td width="6%" align="right">Tipo</td>
								<td width="18%">
								<%
								String e_s = "", t_s = "", t_t = "", label = "", e_r = "";
								//	e_s 	= "A=Aprobado,P=Pendiente,N=Anulado,R=Rechazado,T=Tramite,E=Entregado";
								//	t_s 	= "D=Diaria,S=Semanal,Q=Quincenal,M=Mensual";
								//	e_s		=	ESTADO DE SOLICITUD
								//	t_s		=	TIPO DE SOLICITUD
								//	t_t		=	TIPO DE TRANSFERENCIA
								//	e_r		=	ESTADO DE RENGLON
								//	label	=	Solicitado por / Servicio a / Solicitado a

								if(ReqDet.getReqType().equals("UA")){
									e_s = "T=Tramite,R=Rechazado,A=Aprobado";
									//e_r = "P=Pendiente,E=Entregado,R=Rechazado";//Benito, Jacinto 20130506se comenta estado Entregado ya que no se encontro ninguna funcionalidad.
									e_r = "P=Pendiente,R=Rechazado";
									t_s = "S=Semanal,D=Diaria";
									t_t = "U";
									label = "Solicitado Por";
								} else if(ReqDet.getReqType().equals("UAT")){
									e_s = "T=Tramite,R=Rechazado,A=Aprobado";
									t_s = "D=Diaria,S=Semanal,Q=Quincenal,M=Mensual";
									t_t = "U";
									label = "Solicitado Por";
								} else if(ReqDet.getReqType().equals("EC")){
									e_s = "T=Tramite,R=Rechazado,A=Aprobado";
									t_s = "S=Semanal";
									t_t = "C";
									label = "Solicitado Por";
								} else if(ReqDet.getReqType().equals("SM")){
									e_s = "T=Tramite,R=Rechazado,A=Aprobado";
									t_s = "S=Semanal";
									t_t = "U";
									label = "Servicio a";
								} else if(ReqDet.getReqType().equals("EA")){
									e_s = "A=Aprobado";
									t_s = "D=Diaria";
									t_t = "A";
									label = "Solicitado Por";
								}
								%>
								<%=fb.select("tipo_solicitud",t_s,ReqDet.getTipoSolicitud())%>
								</td>
								<td width="6%" align="right">Fecha</td>
								<td width="18%">
								<%=fb.textBox("fecha_documento",(ReqDet.getFechaDocto()==null)?fecha:ReqDet.getFechaDocto(),true,false,true,10,null,null,"")%>
								</td>
								<td width="7%" align="right">Estado</td>
								<td width="18%">
								<%=fb.select("estado_solicitud",e_s,ReqDet.getEstadoSolicitud())%>
								</td>
							</tr>
							<%
								if(ReqDet.getReqType().equals("UA")) sql = "SELECT codigo_almacen, descripcion FROM TBL_INV_ALMACEN WHERE compania = "+session.getAttribute("_companyId")+" AND codigo_almacen = 1 ";
								else if(ReqDet.getReqType().equals("SM")) sql = "SELECT codigo_almacen, descripcion FROM TBL_INV_ALMACEN WHERE compania = "+session.getAttribute("_companyId")+" AND codigo_almacen = 5 ";

								if((ReqDet.getCodAlmacen() == null || ReqDet.getCodAlmacen().trim().equals("")) &&(ReqDet.getReqType().equals("UA") || ReqDet.getReqType().equals("SM")) ){
									cdo2 = SQLMgr.getData(sql);
									ReqDet.setCodAlmacen(cdo2.getColValue("codigo_almacen"));
									ReqDet.setDescCodAlmacen(cdo2.getColValue("descripcion"));
								}
							%>
								<%=fb.hidden("unidad_administrativa",ReqDet.getUnidadAdmin())%>
								<%=fb.hidden("codigo_almacen",ReqDet.getCodAlmacen())%>
								<%=fb.hidden("codigo_almacen_ent",ReqDet.getCodAlmacenEnt())%>
								<%=fb.hidden("compania_sol",ReqDet.getCompaniaSol())%>
								<%=fb.hidden("tipo_transferencia",ReqDet.getCompaniaSol())%>
								<%
								if(!ReqDet.getReqType().equals("EC")){
								%>
							<tr class="TextRow01">
								<td align="right"><%=label%></td><!--		Solicitado por / Servicio a	-->
								<td colspan="7">
								<%
								if(ReqDet.getReqType().equals("UA") || ReqDet.getReqType().equals("UAT") || ReqDet.getReqType().equals("SM")){
								%>
								<%=fb.textBox("desc_unidad_adm",ReqDet.getDescUnidadAdmin(),true,false,true,40,null,null,"")%>
								<%if(!ReqDet.getReqType().equals("SM")){%>
								<%=fb.button("buscar","Buscar",false,(mode.trim().equals("add"))?false:true,"","","onClick=\"javascript:buscaUE()\"")%>
								<%}%>
								<%
								} else if(ReqDet.getReqType().equals("EA")){
								%>
								<%=fb.textBox("desc_codigo_almacen",ReqDet.getDescCodAlmacen(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,false,"","","onClick=\"javascript:buscaCA(1)\"")%>
								<%
								}
								%>
								</td>
							</tr>
								<%
								} else {
								%>
								<%=fb.hidden("desc_unidad_adm",ReqDet.getDescUnidadAdmin())%>
								<%
								}
								%>
							<tr class="TextRow01">
								<td align="right">Solicitado a</td>
								<td colspan="7">
								<%
								if(ReqDet.getReqType().equals("UA") || ReqDet.getReqType().equals("UAT") || ReqDet.getReqType().equals("SM")){
								%>
								<%=fb.textBox("desc_codigo_almacen",ReqDet.getDescCodAlmacen(),true,false,true,40,null,null,"")%>
								<%if(!ReqDet.getReqType().equals("SM")){%>
								<%=fb.button("buscar","Buscar",false,(mode.trim().equals("add"))?false:true,"","","onClick=\"javascript:buscaCA(1)\"")%>
								<%}%>
								<%
								} else if(ReqDet.getReqType().equals("EC")){
								%>
								<%=fb.textBox("desc_compania_sol",ReqDet.getDescCompaniaSol(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,false,"","","onClick=\"javascript:buscaCS()\"")%>
								<%
								} else if(ReqDet.getReqType().equals("EA")){
								%>
								<%=fb.textBox("desc_codigo_almacen_ent",ReqDet.getDescCodAlmacenEnt(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,true,"","","onClick=\"javascript:buscaCA(2)\"")%>
								<%
								}
								%>
								</td>
							</tr>
							<%
							if(ReqDet.getReqType().equals("EC")){
							%>
							<tr class="TextRow01">
								<td align="right">Almac&eacute;n</td>
								<td colspan="7">
								<%=fb.textBox("desc_codigo_almacen_ent",ReqDet.getDescCodAlmacen(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,(mode.trim().equals("add"))?false:true,"","","onClick=\"javascript:buscaCA(3)\"")%>
								</td>
							</tr>
							<%
							}
							%>

							<tr class="TextRow01">
								<td align="right">Observaci&oacute;n</td>
								<td colspan="7">
								<%=fb.textarea("observacion",ReqDet.getObservacion(),false,false,false,93,5)%>
								</td>
							</tr>
				<%
				if(tr.trim().equals("UA")&& utilizaPres.trim().equals("S")){%>
				<tr class="TextHeader">
				<td colspan="8">
				Resumen de Presupuesto  (Costo + Gastos)
				</td>
			 </tr>
			 <tr>
				<td colspan="8">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td width="20%">Presupuestado</td>
					<td width="20%">Ejecutado</td>
					<td width="20%">Entregas del Mes</td>
					<td width="20%">Requisicion Actual</td>
					<td width="20%">Disponible</td>
				</tr>
				<tr class="TextHeader02">
					<td width="20%"><%=fb.textBox("presupuesto",""+ReqDet.getAsignacion(),false,false,true,30,null,null,"")%> </td>
					<td width="20%"><%=fb.textBox("consumido",ReqDet.getConsumido(),false,false,true,30,null,null,"")%></td>
					<td width="20%"><%=fb.textBox("entregas",ReqDet.getCargo(),false,false,true,30,null,null,"")%></td>
					<td width="20%"><%=fb.textBox("monto_req","",false,false,true,30,null,null,"")%></td>
					<td width="20%"><%=fb.textBox("disponible","",false,false,true,30,null,null,"")%></td>
				</tr>


				</table>
				</td>
			 </tr>
			 <%}%>
						</table>
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
								<%
								String colspan = "2";
								if(ReqDet.getReqType().equals("UA")) colspan = "4";
								%>

							<tr class="TextPanel">
								<td colspan="5">Detalle de la Requisici&oacute;n</td>
								<td colspan="<%=colspan%>" align="right">
								<%if(!ReqDet.getReqType().equals("SM")){%>
								<%=fb.submit("addArticles","Agregar Articulos",false,false)%>
								<%}%>
								</td>
							</tr>
							<tr class="TextHeader">
								<td width="20%" align="center" colspan="3">C&oacute;digo</td>
								<td width="40%" align="center" rowspan="2">Descripci&oacute;n</td>
								<td width="10%" align="center" rowspan="2">Und.</td>
								<td width="17%" align="center" rowspan="2">Cantidad</td>
								<%
								if(ReqDet.getReqType().equals("UA")){
								%>
								<% if (utilizaPres.trim().equalsIgnoreCase("S")) { %><td width="17%" align="center" rowspan="2">Presup. Disp.</td><% } %>
								<td width="10%" align="center" rowspan="2">&nbsp;</td>
								<%
								}
								%>
								<td width="3%" align="center" rowspan="2">&nbsp;</td>
							</tr>
							<tr class="TextHeader">
								<td align="center">Flia.</td>
								<td align="center">Clase</td>
								<td align="center">Art.</td>
							</tr>
							<%
							boolean readOnly = false;
							if(ReqDet.getReqType().equals("SM")) readOnly = true;

							key = "";
							if (rqArt.size() != 0) al = CmnMgr.reverseRecords(rqArt);
							String event = "";
							for (int i=0; i<rqArt.size(); i++)
							{
								key = al.get(i).toString();
								//System.out.println("key...="+key);
								RequisicionDetail rq = (RequisicionDetail) rqArt.get(key);
								String ctaKey2 = 	ReqDet.getUnidadAdmin()+"_"+rq.getFliaCta1()+"_"+rq.getFliaCta2()+"_"+rq.getFliaCta3()+"_"+rq.getFliaCta4()+"_"+rq.getFliaCta5()+"_"+rq.getFliaCta6();
							//System.out.println(" ctaKey2  en el detalle de  la requisicion   *****************= "+ctaKey2);
								if(ReqVar.containsKey(ctaKey2)){
									RequisicionDetail req = (RequisicionDetail) ReqVar.get(ctaKey2);
									rq.setVariacion(req.getVariacion());
								} else if(rq.getVariacion() == null || rq.getVariacion().trim().equals("")){
								 rq.setVariacion("0");
								}

								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("disponible"+i,rq.getDisponible())%>
							<%=fb.hidden("precio"+i,rq.getPrecio())%>
							<%=fb.hidden("ultimo_precio"+i,rq.getUltimoPrecio())%>
							<%=fb.hidden("descuento"+i,rq.getDescuento())%>
							<%=fb.hidden("porcentaje"+i,rq.getPorcentaje())%>
							<%=fb.hidden("fromReq"+i,rq.getFromReq())%>
							<%=fb.hidden("cat1_"+i,rq.getFliaCta1())%>
							<%=fb.hidden("cat2_"+i,rq.getFliaCta2())%>
							<%=fb.hidden("cat3_"+i,rq.getFliaCta3())%>
							<%=fb.hidden("cat4_"+i,rq.getFliaCta4())%>
							<%=fb.hidden("cat5_"+i,rq.getFliaCta5())%>
							<%=fb.hidden("cat6_"+i,rq.getFliaCta6())%>
							<%=fb.hidden("art_familia"+i,rq.getArtFamilia())%>
							<%=fb.hidden("art_clase"+i,rq.getArtClase())%>
							<%=fb.hidden("cod_articulo"+i,rq.getCodArticulo())%>
							<%=fb.hidden("art_descripcion"+i,rq.getArtDesc())%>
							<%=fb.hidden("unidad"+i,rq.getUnidad())%>
							<%=fb.hidden("unidadDesc"+i,rq.getUnidadDesc())%>
							<%//System.out.println("  precio   ====  "+rq.getPrecio());%>
							<tr class="TextRow01">
								<td width="6%"><%=rq.getArtFamilia()%></td>
								<td width="6%"><%=rq.getArtClase()%></td>
								<td width="8%"><%=rq.getCodArticulo()%></td>
								<td width="50%"><%=rq.getArtDesc()%></td>
								<td width="10%" align="center" class="_jqHint" hintMsgId="hintDetail<%=i%>"><%=rq.getUnidad()%><span id="hintDetail<%=i%>" class="_jqHintMsg">[<%=rq.getUnidad()%> - <%=rq.getUnidadDesc()%>]</span></td>
				 <%	if(ReqDet.getReqType().equals("UA")){
					event = "onChange=\"javascript:calMonto()\"";
				 }%>
				 <%if(ReqDet.getCodAlmacen() != null || !ReqDet.getCodAlmacen().trim().equals("") && ReqDet.getCodAlmacen().trim().equals("4")){%>
								<td width="17%" align="center"><%=fb.decBox("cantidad"+i,rq.getCantidad(),true,false,readOnly,10,null,null,event)%></td>
				<%}else {%>

						<td width="17%" align="center"><%=fb.intBox("cantidad"+i,rq.getCantidad(),true,false,readOnly,10,null,null,event)%></td>
				<%}%>

								<%
								if(ReqDet.getReqType().equals("UA")){
								%>
								<% if (utilizaPres.trim().equalsIgnoreCase("S")) { %><td width="17%" align="center"><%=fb.decBox("presDisp"+i,rq.getVariacion(),true,false,true,10,null,null,"")%></td><% } %>
								<td width="10%" align="center"><%=fb.select("status"+i,e_r,rq.getEstadoRenglon())%></td>
								<%
								}
								%>
								<td width="3%" align="center">
								<%if(!ReqDet.getReqType().equals("SM") && !rq.getFromReq().equals("S")){%>
								<%=fb.submit("del"+i,"X",false,false)%>
								<%}%>
								</td>
							</tr>
							<%
							}
							%>
							<%=fb.hidden("keySize",""+ReqDet.getReqDetails().size())%>
							<%
							colspan = "7";
							if(ReqDet.getReqType().equals("UA")) colspan = "9";
							%>
							<tr class="TextRow02">
							<!--submit(String objName, String objValue, boolean disableOnSubmit, boolean isDisabled, String className, String style, String event)-->
								<td colspan="<%=colspan%>" align="right"><%=fb.submit("save","Guardar",true,false,"","","onClick=\"javascript:document.requisicion.action.value = this.value;\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
	ReqDet.setTipoSolicitud(request.getParameter("tipo_solicitud"));
	ReqDet.setFechaDocto(request.getParameter("fecha_documento"));
	ReqDet.setEstadoSolicitud(request.getParameter("estado_solicitud"));
	ReqDet.setUnidadAdmin(request.getParameter("unidad_administrativa"));
	ReqDet.setDescUnidadAdmin(request.getParameter("desc_unidad_adm"));
	ReqDet.setObservacion(request.getParameter("observacion"));
	ReqDet.setTipoTransferencia(request.getParameter("tipo_transferencia"));
	ReqDet.setUsuarioCrea((String) session.getAttribute("_userName"));
	ReqDet.setUsuarioModifica((String) session.getAttribute("_userName"));

	if(ReqDet.getReqType().equals("UA")){
	ReqDet.setAsignacion(request.getParameter("presupuesto"));
	ReqDet.setConsumido(request.getParameter("consumido"));
	ReqDet.setCargo(request.getParameter("entregas"));

	}

	ReqDet.setCodAlmacen(request.getParameter("codigo_almacen"));
	ReqDet.setCodAlmacenEnt(request.getParameter("codigo_almacen_ent"));
	ReqDet.setCompaniaSol(request.getParameter("compania_sol"));
	ReqDet.setDescCodAlmacen(request.getParameter("desc_codigo_almacen"));
	ReqDet.setDescCodAlmacenEnt(request.getParameter("desc_codigo_almacen_ent"));
	ReqDet.setDescCompaniaSol(request.getParameter("desc_compania_sol"));
	System.out.println("ReqDet.getUnidadAdmin()...="+ReqDet.getUnidadAdmin());
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
		rq.setUnidad(request.getParameter("unidad"+i));
		rq.setCantidad(request.getParameter("cantidad"+i));
		rq.setFromReq(request.getParameter("fromReq"+i));
		if(ReqDet.getReqType().equals("UA"))
		{
		 rq.setEstadoRenglon(request.getParameter("status"+i));
		 rq.setVariacion(request.getParameter("presDisp"+i));
		}else rq.setEstadoRenglon("P");
		rq.setFliaCta1(request.getParameter("cta1_"+i));
		rq.setFliaCta2(request.getParameter("cta2_"+i));
		rq.setFliaCta3(request.getParameter("cta3_"+i));
		rq.setFliaCta4(request.getParameter("cta4_"+i));
		rq.setFliaCta5(request.getParameter("cta5_"+i));
		rq.setFliaCta6(request.getParameter("cta6_"+i));
		rq.setUnidadDesc(request.getParameter("unidadDesc"+i));

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
				rqArtKey.put(rq.getCodArticulo(), key);
				ReqDet.getReqDetails().add(rq);
				System.out.println("adding...= "+key);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		} else {
			artDel = rq.getArtFamilia()+"-"+rq.getArtClase()+"-"+rq.getCodArticulo();
			/*
			if (rqArtKey.containsKey(artDel)){
				System.out.println("- remove item "+artDel);
				System.out.println("- remove key "+(String) rqArtKey.get(artDel));
				rqArt.remove((String) rqArtKey.get(artDel));
				rqArtKey.remove(artDel);
				System.out.println("- rqArt.size() = "+rqArt.size());
				System.out.println("- rqArtKey.size() = "+rqArtKey.size());
			}
			*/
		}
	}

	if(ReqDet.getReqType().equals("UA")){
		ReqDet.setCodAlmacen(request.getParameter("codigo_almacen"));
		//ReqDet.setCompaniaSol("1");
		ReqDet.setCompaniaSol((String) session.getAttribute("_companyId"));
		ReqDet.setTipoTransferencia("U");
	} else if(ReqDet.getReqType().equals("UAT")) {
		ReqDet.setCompaniaSol("1");
		ReqDet.setTipoTransferencia("U");
		ReqDet.setCodAlmacenEnt(null);
	} else if(ReqDet.getReqType().equals("SM")) {
		ReqDet.setCodAlmacen("5");
		ReqDet.setCompaniaSol("1");
		ReqDet.setTipoTransferencia("U");
	} else if(ReqDet.getReqType().equals("EC")) {
		ReqDet.setCodAlmacen(ReqDet.getCodAlmacenEnt());
		ReqDet.setTipoTransferencia("C");
	} else if(ReqDet.getReqType().equals("EA")) {
		ReqDet.setCompaniaSol(companyId);
		ReqDet.setUnidadAdmin(null);
		ReqDet.setTipoTransferencia("A");
	}

	if(!artDel.equals("") || clearHT.equals("S")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&change=1&type=2&tr="+tr+"&tipoSolicitud="+tipoSolicitud);
		return;
	}
	if(request.getParameter("addArticles")!=null){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&change=1&type=1&tr="+tr+"&tipoSolicitud="+tipoSolicitud);
		return;
	}

	if (mode.equalsIgnoreCase("approve")){
		ReqMgr.approve(ReqDet);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ReqMgr.getErrCode().equals("1")){
	session.removeAttribute("ReqDet");
	session.removeAttribute("rqArt");
	session.removeAttribute("rqArtKey");
%>

	alert('<%=ReqMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_req_unid_adm.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_req_unid_adm.jsp")%>';
<%
	} else {
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/list_req_unid_adm.jsp?tr=<%=tr%>';
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