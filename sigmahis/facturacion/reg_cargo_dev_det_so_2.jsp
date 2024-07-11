<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.CdcSolicitud"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="issi.facturacion.FactDetTransComp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
<jsp:useBean id="CdcSol" scope="session" class="issi.admision.CdcSolicitud" />
<jsp:useBean id="fTranCargQ" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargQKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargA" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargAKey" scope="session" class="java.util.Hashtable" />
<%
/**
===============================================================================
FORMA								MENU	orden by c.descripcion																																																									NOMBRE EN FORMA
CDC100110_I					INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS\SOLICITUD INSUMOS QUIRURGICOS		SOLICITUD PREVIA DE MAT. Y MED. PARA PACIENTES EN SALON DE OPERACIONES.
CDC100110_IV2				INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - PROGRAMA QUIRURGICO POR CUARTO
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdoX = new CommonDataObject();
CommonDataObject cdoY = new CommonDataObject();

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdoCount = new CommonDataObject();
CommonDataObject cdoP = new CommonDataObject();
ArrayList al = new ArrayList();
String change1 = request.getParameter("change1");
String change2 = request.getParameter("change2");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String id = request.getParameter("id");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String estadoCita = request.getParameter("estadoCita");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String habitacion = request.getParameter("habitacion");
String horaEntrada = request.getParameter("horaEntrada");
String horaSalida = request.getParameter("horaSalida");
String tab = request.getParameter("tab");
String secuencia = "";
String almacenSOP = ResourceBundle.getBundle("issi").getString("almacenSOP");
boolean viewMode = false;
int lineNo = 0, contY = 0;

CdcSolicitud sol = new CdcSolicitud();
System.out.println("tipoSolicitud =============="+tipoSolicitud+"  change1 ============="+change1+"  change2 ============="+change2);
if (mode == null) mode = "add";
if(fp==null) fp="cargo_dev_so";
if (horaEntrada == null) horaEntrada = "";
if (horaSalida == null) horaSalida = "";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select param_value valida_dsp from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name = 'CHECK_DISP' ";
	cdoP = SQLMgr.getData(sql);
	if(cdoP ==null){cdoP =new CommonDataObject();cdoP.addColValue("valida_dsp","S");}

	if (mode.equalsIgnoreCase("add") && change1 == null && tipoSolicitud.equals("Q")){ fTranCargQ.clear();fTranCargQKey.clear();}
	if (mode.equalsIgnoreCase("add") && change2 == null && tipoSolicitud.equals("A")){fTranCargA.clear();fTranCargAKey.clear();}

		sql = "select secuencia from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and trunc(cita_fecha_reg) = to_date('"+fechaCita+"', 'dd/mm/yyyy') and estado = 'T' and tipo_solicitud = '"+tipoSolicitud+"'";
		cdoX = SQLMgr.getData(sql);
		if(cdoX!=null && cdoX.getColValue("secuencia")!=null){
			secuencia = cdoX.getColValue("secuencia");
			
		} else viewMode = true;

		sql = "select count(*) contador from tbl_cdc_solicitud_trx where cita_codigo = "+codCita+" and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"','dd/mm/yyyy') and secuencia = "+secuencia+" and compania = "+(String) session.getAttribute("_companyId")+" and trx_estado = 'P'";
		System.out.println("contY=\n"+sql);
		if(!secuencia.equals("")){
			cdoY = SQLMgr.getData(sql);
			if(cdoY!=null && cdoY.getColValue("contador")!=null){
				contY = Integer.parseInt(cdoY.getColValue("contador"));
			}
		}
		
		if(tipoSolicitud.equals("A")){tab="1";}
		else if(tipoSolicitud.equals("Q")){tab="0";}
		
		
		
		
		sql = "select cita_codigo citaCodigo, cita_fecha_reg citaFechaReg, nvl(to_char(hora_entrada, 'HH12:mi AM'),' ') horaEntrada, nvl(to_char(hora_salida, 'HH12:mi AM') ,' ') horaSalida, nvl(to_char(fecha_documento, 'dd/mm/yyyy'), '') fechaDocumento, centro_servicio centroServicio, nvl(to_char(decode(hora_entrada, null,null,decode(hora_salida, null, null, decode(sign(to_number(to_char(hora_entrada, 'hh24mi'))-to_number(to_char(hora_salida, 'hh24mi'))),1,getTiempo(hora_entrada, to_date(to_char(hora_entrada + 1, 'dd/mm/yyyy')||' '||to_char(hora_salida, 'hh12:mi AM'), 'dd/mm/yyyy hh12:mi AM'), 'H'),getTiempo(hora_entrada, to_date(to_char(hora_entrada, 'dd/mm/yyyy')||' '||to_char(hora_salida, 'hh12:mi AM'),'dd/mm/yyyy hh12:mi AM'), 'H'))))), ' ') dspHoras, nvl(to_char(decode(hora_entrada, null,null,decode(hora_salida, null, null, decode(sign(to_number(to_char(hora_entrada, 'hh24mi'))-to_number(to_char(hora_salida, 'hh24mi'))),1,getTiempo(hora_entrada, to_date(to_char(hora_entrada + 1, 'dd/mm/yyyy')||' '||to_char(hora_salida, 'hh12:mi AM'), 'dd/mm/yyyy hh12:mi AM'), 'M'),getTiempo(hora_entrada, to_date(to_char(hora_entrada, 'dd/mm/yyyy')||' '||to_char(hora_salida, 'hh12:mi AM'),'dd/mm/yyyy hh12:mi AM'), 'M'))))), ' ') dspMin from tbl_cdc_solicitud_enc where trunc(cita_fecha_reg) = to_date('"+fechaCita+"','dd/mm/yyyy') and cita_codigo =" + codCita + " and compania ="+(String) session.getAttribute("_companyId") ;
			if(!mode.equals("view")) sql += " and estado = 'T' ";
			sql += " and tipo_solicitud = '"+tipoSolicitud+"'";
			sol = (CdcSolicitud) sbb.getSingleRowBean(ConMgr.getConnection(), sql, CdcSolicitud.class); 
		
			if(sol==null)sol = new CdcSolicitud();			
			else {if(sol.getHoraEntrada() != null && !sol.getHoraEntrada().trim().equals(""))horaEntrada = sol.getHoraEntrada();
			if(sol.getHoraSalida() != null && !sol.getHoraSalida().trim().equals(""))horaSalida = sol.getHoraSalida(); }
		 
		 
		if((tipoSolicitud.equals("A") && change1 == null)||(tipoSolicitud.equals("Q") && change2 == null)){
			 
			 
			sql = "select b.renglon, b.art_familia artFamilia, b.art_clase artClase, b.cod_articulo codArticulo, b.cantidad, b.despachado, b.precio, b.entrega, b.devolucion, b.adicion, b.paquete, b.cantidad_paquete cantidadPaquete, c.descripcion, c.cod_medida unidad, (select nvl(x.disponible, 0) from tbl_inv_inventario x  where x.cod_articulo = b.cod_articulo and x.compania = b.compania and x.codigo_almacen =    nvl(get_sop_wh(b.compania,c.cod_flia,c.cod_clase,a.codigo_almacen),a.codigo_almacen) ) as disponible, nvl(c.other3,'Y')afecta_inv,a.codigo_almacen, nvl(get_sop_wh(b.compania,c.cod_flia,c.cod_clase,a.codigo_almacen),a.codigo_almacen) as wh ,(select descripcion from tbl_inv_almacen where codigo_almacen =nvl(get_sop_wh(b.compania,c.cod_flia,c.cod_clase,a.codigo_almacen),a.codigo_almacen) and compania=c.compania) descWh from tbl_cdc_solicitud_enc a, tbl_cdc_solicitud_det b, tbl_inv_articulo c, tbl_inv_inventario i where a.cita_codigo = b.cita_codigo and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(b.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.secuencia = b.secuencia and a.tipo_solicitud = '"+tipoSolicitud+"' and a.estado = 'T' and b.cod_articulo = c.cod_articulo and b.compania = c.compania and c.cod_articulo = i.cod_articulo and c.compania = i.compania and i.codigo_almacen = "+almacenSOP+" and a.cita_codigo = " + codCita + " and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and a.compania = " + (String) session.getAttribute("_companyId") + " order by c.descripcion, b.art_familia, b.art_clase, b.cod_articulo";
			System.out.println("sql detail:\n"+sql);
			al = SQLMgr.getDataList(sql);
			
			if(tipoSolicitud.equals("A"))change1 = "1";
			else change2 = "1";
			lineNo = 0;		
			for(int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				CdcSolicitudDet det = new CdcSolicitudDet();
				det.setArtFamilia(cdo.getColValue("artFamilia"));
				det.setArtClase(cdo.getColValue("artClase"));
				det.setCodArticulo(cdo.getColValue("codArticulo"));
				det.setDescripcion(cdo.getColValue("descripcion"));
				det.setPrecio(cdo.getColValue("precio"));
				det.setCantidad(cdo.getColValue("cantidad"));
				det.setPaquete(cdo.getColValue("paquete"));
				det.setCantidadPaquete(cdo.getColValue("cantidadPaquete"));
				det.setUnidad(cdo.getColValue("unidad"));
				det.setAdicion(cdo.getColValue("adicion"));
				det.setEntrega(cdo.getColValue("entrega"));
				det.setRenglon(cdo.getColValue("renglon"));
				det.setDisponible(cdo.getColValue("disponible"));
				det.setDevolucion(cdo.getColValue("devolucion"));
				det.setAfectaInv(cdo.getColValue("afecta_inv"));
				det.setOther1(cdo.getColValue("wh"));
				det.setOther4(cdo.getColValue("descWh"));
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
					try 
					{
						if(tipoSolicitud.equals("A"))fTranCargA.put(key, det);
						if(tipoSolicitud.equals("A"))fTranCargAKey.put(tipoSolicitud+"_"+det.getCodArticulo(), key);
						if(tipoSolicitud.equals("Q"))fTranCargQ.put(key, det);
						if(tipoSolicitud.equals("Q"))fTranCargQKey.put(tipoSolicitud+"_"+det.getCodArticulo(), key);
					}
					catch (Exception e)
					{
						System.out.println("Unable to addget item "+key);
					}
			}//end for
		}		 
		
		
		
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(ref){if(parent.adjustIFrameSize) parent.adjustIFrameSize(window);
var fg = document.form<%=tipoSolicitud%>.fg.value;var codCita = document.form<%=tipoSolicitud%>.codCita.value;var fechaCita = document.form<%=tipoSolicitud%>.fechaCita.value;var secuencia = document.form<%=tipoSolicitud%>.secuencia.value;var habitacion = document.form<%=tipoSolicitud%>.habitacion.value;if(ref!=1){<%if(type!=null && type.equals("1")){%>abrir_ventana1('../common/sel_articles_so.jsp?mode=<%=mode%>&fg='+fg+'&fp=<%=fp%>&inv_almacen=<%=almacenSOP%>&tipoSolicitud=<%=tipoSolicitud%>&codCita='+codCita+'&fechaCita='+fechaCita+'&secuencia='+secuencia+"&habitacion="+habitacion+'&horaSalida=<%=horaSalida%>&horaEntrada=<%=horaEntrada%>&addArt=S');<%} else if(type!=null && type.equals("2")){%>abrir_ventana1('../facturacion/cdc_trx_pendientes.jsp?codCita='+codCita+'&fechaCita='+fechaCita+'&secuencia='+secuencia+'&fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&tipoSolicitud=<%=tipoSolicitud%>');<%}%>calc();}//newHeight();
}


function chkValue(i){var x1 = 0, x2 = 0, x3 = 0;var disponible = parseInt(eval('document.form<%=tipoSolicitud%>.disponible'+i).value, 10);var cantidad = parseInt(eval('document.form<%=tipoSolicitud%>.cantidad'+i).value, 10);var entrega = parseInt(eval('document.form<%=tipoSolicitud%>.entrega'+i).value, 10);var adicion = parseInt(eval('document.form<%=tipoSolicitud%>.adicion'+i).value, 10);var devolucion	=	parseInt(eval('document.form<%=tipoSolicitud%>.devolucion'+i).value, 10);var afecta_inv =eval('document.form<%=tipoSolicitud%>.afecta_inv'+i).value;  if(isNaN(entrega)) entrega = 0;if(isNaN(adicion)) adicion = 0;if(isNaN(devolucion)) devolucion = 0;<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>if(afecta_inv=='Y'){if(((entrega + adicion) - devolucion) > 0){
if(disponible < 0){eval('document.form<%=tipoSolicitud%>.entrega'+i).value = 0;eval('document.form<%=tipoSolicitud%>.adicion'+i).value = 0;x1++;}if(disponible==0){eval('document.form<%=tipoSolicitud%>.entrega'+i).value = 0;eval('document.form<%=tipoSolicitud%>.adicion'+i).value = 0;x2++;}else if(!isNaN(entrega) && entrega > disponible){eval('document.form<%=tipoSolicitud%>.entrega'+i).value = 0;x3++;} else if(!isNaN(entrega) && !isNaN(adicion) && (entrega + adicion) > disponible){eval('document.form<%=tipoSolicitud%>.adicion'+i).value = 0;x3++;}else{eval('document.form<%=tipoSolicitud%>.utilizado'+i).value = entrega + adicion - devolucion;}if((x1+x2+x3)>0){if(x1>0){top.CBMSG.error('No hay existencia...,VERIFIQUE SU INVENTARIO!-DISPONIBLE EN NEGATIVO'); return false;}else if(x2>0){top.CBMSG.error('No hay existencia...,VERIFIQUE SU INVENTARIO!'); return false;}else if(x3>0){top.CBMSG.error('Cantidad NO disponible en Inventario...,VERIFIQUE SU INVENTARIO');return false;}return false;} else return true;
}}else return true;<%}else{%>return true;<%}%>}

function addDevArt(tipoTrx,i){var fg = document.form<%=tipoSolicitud%>.fg.value;var codCita = document.form<%=tipoSolicitud%>.codCita.value;var fechaCita = document.form<%=tipoSolicitud%>.fechaCita.value;var secuencia = document.form<%=tipoSolicitud%>.secuencia.value;var habitacion = document.form<%=tipoSolicitud%>.habitacion.value;

var flia = eval('document.form<%=tipoSolicitud%>.art_familia'+i).value;
var clase = eval('document.form<%=tipoSolicitud%>.art_clase'+i).value;
var articulo = eval('document.form<%=tipoSolicitud%>.cod_articulo'+i).value;

<% if (tipoSolicitud.equalsIgnoreCase("Q")||tipoSolicitud.equalsIgnoreCase("A")) { %>
var entrega = parseInt(eval('document.form<%=tipoSolicitud%>.entrega'+i).value, 10);
var adicion = parseInt(eval('document.form<%=tipoSolicitud%>.adicion'+i).value, 10);
var devolucion	=	parseInt(eval('document.form<%=tipoSolicitud%>.devolucion'+i).value, 10);
if(isNaN(entrega)) entrega = 0;if(isNaN(adicion)) adicion = 0;if(isNaN(devolucion)) devolucion = 0;
if(tipoTrx=='D'){
if(((entrega + adicion) - devolucion) > 0){
showPopWin('../common/sel_articles_so.jsp?mode=<%=mode%>&fg='+fg+'&fp=<%=fp%>&inv_almacen=<%=almacenSOP%>&tipoSolicitud=<%=tipoSolicitud%>&codCita='+codCita+'&fechaCita='+fechaCita+'&secuencia='+secuencia+"&habitacion="+habitacion+'&flia='+flia+'&clase='+clase+'&articulo='+articulo+'&tipoTrx='+tipoTrx,winWidth*.5,winHeight*.3,null,null,'');}else top.CBMSG.error('No hay Cantidad procesada para devolver..');
} else showPopWin('../common/sel_articles_so.jsp?mode=<%=mode%>&fg='+fg+'&fp=<%=fp%>&inv_almacen=<%=almacenSOP%>&tipoSolicitud=<%=tipoSolicitud%>&codCita='+codCita+'&fechaCita='+fechaCita+'&secuencia='+secuencia+"&habitacion="+habitacion+'&flia='+flia+'&clase='+clase+'&articulo='+articulo+'&tipoTrx='+tipoTrx,winWidth*.5,winHeight*.3,null,null,'');
<% } %>
}

function calc(){var x1 = 0, x2 = 0, x3 = 0;var size = document.form<%=tipoSolicitud%>.keySize.value;var action = parent.document.form_1.baction.value;var msg1 = '', msg2 = '', msg3 = '';for(i=0;i<size;i++){

var disponible	= parseInt(eval('document.form<%=tipoSolicitud%>.disponible'+i).value, 10);var cantidad = parseInt(eval('document.form<%=tipoSolicitud%>.cantidad'+i).value, 10);var entrega =	parseInt(eval('document.form<%=tipoSolicitud%>.entrega'+i).value, 10);var adicion =	parseInt(eval('document.form<%=tipoSolicitud%>.adicion'+i).value, 10);var desc =	eval('document.form<%=tipoSolicitud%>.art_familia'+i).value+'-'+eval('document.form<%=tipoSolicitud%>.art_clase'+i).value+'-'+eval('document.form<%=tipoSolicitud%>.cod_articulo'+i).value+'-'+eval('document.form<%=tipoSolicitud%>.descripcion'+i).value;var devolucion=0;if (eval('document.form<%=tipoSolicitud%>.devolucion'+i)!=null) devolucion	=	parseInt(eval('document.form<%=tipoSolicitud%>.devolucion'+i).value, 10);if(isNaN(entrega)) entrega = 0;if(isNaN(adicion)) adicion = 0;if(isNaN(devolucion)) devolucion = 0;var afect_inv =eval('document.form<%=tipoSolicitud%>.afect_inv'+i).value; 
<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>if(afect_inv=='Y'){if(((entrega + adicion) - devolucion) > 0){if(disponible < 0){eval('document.form<%=tipoSolicitud%>.entrega'+i).value = 0;eval('document.form<%=tipoSolicitud%>.adicion'+i).value = 0;x1++;msg1 = 'No hay existencia de ' + desc + ', VERIFIQUE SU INVENTARIO! DISPONIBLE EN NEGATIVO';}if(disponible==0){eval('document.form<%=tipoSolicitud%>.entrega'+i).value = 0;eval('document.form<%=tipoSolicitud%>.adicion'+i).value = 0;x2++;msg2 = 'No hay existencia de ' + desc + ', VERIFIQUE SU INVENTARIO';} else if(!isNaN(entrega) && entrega > disponible){eval('document.form<%=tipoSolicitud%>.entrega'+i).value = 0;x3++;} else if(!isNaN(entrega) && !isNaN(adicion) && (entrega + adicion) > disponible){eval('document.form<%=tipoSolicitud%>.adicion'+i).value = 0;x3++;msg3 = 'Cantidad de ' + desc + ', NO disponible en Inventario!';}}}<%}%>eval('document.form<%=tipoSolicitud%>.utilizado'+i).value = entrega + adicion - devolucion;}if((x1+x2+x3)>0 && action=='Cerrar Solicitud'){if(x1>0){top.CBMSG.error(msg1); return false;}else if(x2>0){ top.CBMSG.error(msg2); return false;}else if(x3>0){top.CBMSG.error(msg3); return false;}return false;}else return true;}
function _doSubmit(valor){parent.document.form_1.baction.value = valor;parent.document.form_1.clearHT.value = 'N';doSubmit();}
function doSubmit(){var cont_trx = parseInt(document.form<%=tipoSolicitud%>.cont_trx.value, 10);var action = parent.document.form_1.baction.value;document.form<%=tipoSolicitud%>.baction.value = parent.document.form_1.baction.value;document.form<%=tipoSolicitud%>.clearHT.value = parent.document.form_1.clearHT.value;document.form<%=tipoSolicitud%>.cod_paciente.value = parent.document.form_1.cod_paciente.value;document.form<%=tipoSolicitud%>.fec_nacimiento.value = parent.document.form_1.fec_nacimiento.value;document.form<%=tipoSolicitud%>.pac_id.value = parent.document.form_1.pac_id.value;	document.form<%=tipoSolicitud%>.admision.value = parent.document.form_1.admision.value;document.form<%=tipoSolicitud%>.codAlmacen.value = parent.document.form_1.codAlmacen.value;/*document.form<%=tipoSolicitud%>.centroServicio.value = parent.document.form_1.centroServicio.value;*/document.form<%=tipoSolicitud%>.copiarInsumos.value = parent.document.form_1.copiarInsumos.value;	document.form<%=tipoSolicitud%>.habitacion.value = parent.document.form_1.habitacion.value;calcTime<%=tipoSolicitud%>();if (!parent.form0Validation()){} else{if (document.form<%=tipoSolicitud%>.baction.value != 'Guardar')parent.form_1BlockButtons(false);<%if(tipoSolicitud.equals("Q")){%>if (document.form<%=tipoSolicitud%>.baction.value == 'Guardar' && <%=fTranCargQ.size()%> == 0)<%} else if(tipoSolicitud.equals("A")){%>if (document.form<%=tipoSolicitud%>.baction.value == 'Guardar' && <%=fTranCargA.size()%> == 0)<%}%>{top.CBMSG.error('Por favor agregue por lo menos un cargo antes de guardar!');parent.form_1BlockButtons(false); return false;} else if(cont_trx>0 && action == 'cerrar'){top.CBMSG.error('No puede cerrar una solicitud que tiene transacciones pendientes,  Verifique e inténtelo nuevamente');parent.form_1BlockButtons(false); return false;} else if(calc()){document.form<%=tipoSolicitud%>.submit();}}}
function cierre<%=tipoSolicitud%>(){var size = document.form<%=tipoSolicitud%>.keySize.value;var paciente = parent.document.form_1.cod_paciente.value;var admision = parent.document.form_1.admision.value;var fec_naci = parent.document.form_1.fec_nacimiento.value;var cod_tipo = parent.document.form_1.cod_tipo.value;	var v_cita_fecha_reg = document.form<%=tipoSolicitud%>.fechaCita.value;var p_cita_codigo = document.form<%=tipoSolicitud%>.codCita.value;var p_compania    = <%=(String) session.getAttribute("_companyId")%>;var p_secuencia   = document.form<%=tipoSolicitud%>.secuencia.value;var p_admision    = parent.document.form_1.admision.value;var habitacion		= document.form<%=tipoSolicitud%>.habitacion.value;var calcular_uso = 0;var tipoSolicitud = '<%=tipoSolicitud%>';var p_dsp_hora   = document.form<%=tipoSolicitud%>.dsp_hora.value;var p_dsp_min   = document.form<%=tipoSolicitud%>.dsp_min.value;var es_quirofano   = parent.document.form_1.es_quirofano.value; var p_form_name     = 'CDC100110_I';<%if(fp.equals("cita_x_hab")){%>p_form_name = 'CDC100110_IV2';<%}%>document.form<%=tipoSolicitud%>.fName.value = p_form_name;document.form<%=tipoSolicitud%>.tipo_cita.value = '0';document.form<%=tipoSolicitud%>.uso.value = 'null';var x = false;var count	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_cdc_solicitud_trx', 'compania = <%=(String) session.getAttribute("_companyId")%> and trx_estado = \'P\' and cita_codigo = '+p_cita_codigo +' and to_date(to_char(cita_fecha_reg, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+v_cita_fecha_reg+'\',\'dd/mm/yyyy\') and secuencia = '+p_secuencia,''),10);if(count>0){alert('No puede cerrar una solicitud que tiene transacciones pendientes,  Verifique e inténtelo nuevamente!');} else {if(paciente != '' && admision != '' && fec_naci != ''){if (confirm('Al ejecutar el CIERRE se estará creando una Requisición, una Entrega y finalmente los CARGOS a la cuenta del paciente.  Está seguro de ejecutarlo?')){for(i=0; i<size; i++){var descripcion	= eval('document.form<%=tipoSolicitud%>.descripcion'+i).value;var flia = eval('document.form<%=tipoSolicitud%>.art_familia'+i).value;var clase = eval('document.form<%=tipoSolicitud%>.art_clase'+i).value;var codigo = eval('document.form<%=tipoSolicitud%>.cod_articulo'+i).value;var utilizado = parseInt(eval('document.form<%=tipoSolicitud%>.utilizado'+i).value);var afecta_inv= eval('document.form<%=tipoSolicitud%>.afect_inv'+i).value;
if(utilizado!='' && !isNaN(utilizado)){<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>if(afecta_inv=='Y'){if(utilizado > 0){if(parseInt(eval('document.form<%=tipoSolicitud%>.disponible'+i).value,10) > 0){var whArt=	eval('document.form<%=tipoSolicitud%>.whArt'+i).value; if(whArt=='')whArt='<%=almacenSOP%>'; var disponible	= getInvDisponible('<%=request.getContextPath()%>',<%=(String) session.getAttribute("_companyId")%>,whArt,flia,clase,codigo);if(isNaN(disponible)){alert('No existe ' + descripcion + ' en el Inventario... Verifique!!!');x = false;break;}else if(disponible==0){alert('No hay existencia de ' + descripcion + '... Verifique!!!');x = false;break;}else if(utilizado > disponible){alert('Cantidad solicitada de ' + descripcion + ' excede la existencia...!!!');x = false;break;}else x = true;}else{ alert('No hay disponibilidad del articulo '+descripcion+", "+flia+"-"+clase+"-"+codigo);x = false;break;}}}<%}else{%>x=true;<%}%>if(x!=false){x=true;}}}} else x = false;  if(tipoSolicitud=='Q'){calcular_uso = 0;} else if(tipoSolicitud=='A'){if(!isNaN(p_dsp_hora)) p_dsp_hora = parseInt(p_dsp_hora,10);if(!isNaN(p_dsp_min)) p_dsp_min = parseInt(p_dsp_min,10);if(es_quirofano == 'S' && (p_dsp_hora + p_dsp_min) > 0){if(confirm('Desea calcular el uso de SOP. Segun la Clasificacion de la Cita y los Usos de Anestesia Configurados en los Procedimientos???')){calcular_uso = cod_tipo;}}}} else {alert('La cita no tiene asignada una ADMISION por lo que no puede ejecutarse el proceso!!!');x = false}if(x){if(confirm('De haber realizado cambios, desea guardarlos antes de realizar el cierre?')){document.form<%=tipoSolicitud%>.cierre.value = 'S';}else {document.form<%=tipoSolicitud%>.cierre.value = 'N';}}document.form<%=tipoSolicitud%>.calcular_uso.value = calcular_uso;parent.document.form_1.baction.value = 'cerrar';document.form<%=tipoSolicitud%>.baction.value = 'cerrar';if(x){_doSubmit('cerrar');}}}
function calMonto(j,k){var cantidad = parseInt(eval('document.form<%=tipoSolicitud%>.cantidad'+j).value,10);var cant_cargo = 0;var cant_devolucion = 0;var monto = eval('document.form<%=tipoSolicitud%>.monto'+j).value;var tipoTransaccion = parent.document.form0.tipoTransaccion.value;var fg = '<%=fg%>';if(isNaN(cantidad) || isNaN(monto)){top.CBMSG.error('Introduzca valores numéricos!');if(x=='c')eval('document.form<%=tipoSolicitud%>.cantidad'+j).value = 0;else if(x=='p')eval('document.form<%=tipoSolicitud%>.monto'+j).value = 0;return false;} else {if(tipoTransaccion=='D' && cantidad > (cant_cargo-cant_devolucion)){top.CBMSG.error('La cantidad a devolver excede la cantidad del cargo...,VERIFIQUE!');eval('document.form<%=tipoSolicitud%>.cantidad'+j).value = 0;eval('document.form<%=tipoSolicitud%>.cantidad'+j).select();return false;} else {eval('document.form<%=tipoSolicitud%>.monto_total'+j).value = (cantidad * monto).toFixed(2);calc();return true;}}}

function solTrx(){parent.document.form_1.baction.value = 'solTrx';document.form<%=tipoSolicitud%>.baction.value = 'solTrx';	document.form<%=tipoSolicitud%>.submit();}

function printSolPrevMat(tipoSolicitud){var fechaCita = document.form<%=tipoSolicitud%>.fechaCita.value;var codCita = document.form<%=tipoSolicitud%>.codCita.value;var admision = parent.document.form_1.admision.value;var cod_paciente= parent.document.form_1.cod_paciente.value;var fec_nacimiento= parent.document.form_1.fec_nacimiento.value;abrir_ventana1('../facturacion/print_sol_prev_mat.jsp?fechaRegistro='+fechaCita+'&codCita='+codCita+'&cod_paciente='+cod_paciente+'&fec_nacimiento='+fec_nacimiento+'&admision='+admision+'&tipoSolicitud='+tipoSolicitud);}
function devolver<%=tipoSolicitud%>(){var fg= document.form<%=tipoSolicitud%>.fg.value;var codCita = document.form<%=tipoSolicitud%>.codCita.value;var fechaCita = document.form<%=tipoSolicitud%>.fechaCita.value;var secuencia = document.form<%=tipoSolicitud%>.secuencia.value;var habitacion = document.form<%=tipoSolicitud%>.habitacion.value;abrir_ventana1('../facturacion/cdc_dev_x_lote.jsp?mode=<%=mode%>&fg='+fg+'&fp=<%=fp%>&inv_almacen=<%=almacenSOP%>&tipoSolicitud=<%=tipoSolicitud%>&codCita='+codCita+'&fechaCita='+fechaCita+'&secuencia='+secuencia+"&habitacion="+habitacion);}
function setCantidad(j){var cantidad= parseInt(eval('document.form<%=tipoSolicitud%>.cantidad'+j).value,10);if(eval('document.form<%=tipoSolicitud%>.paquete'+j).checked){eval('document.form<%=tipoSolicitud%>.cantidad_paquete'+j).value = cantidad;eval('document.form<%=tipoSolicitud%>.paquete'+j).value = 'S';}else{eval('document.form<%=tipoSolicitud%>.cantidad_paquete'+j).value = '';}}
function calcTime<%=tipoSolicitud%>(){var hora_entrada = document.form<%=tipoSolicitud%>.hora_entrada.value;var hora_salida = document.form<%=tipoSolicitud%>.hora_salida.value;	if(hora_entrada!='' && hora_salida!=''){var v_hora	= getDBData('<%=request.getContextPath()%>', '(decode(sign(to_number(to_char(to_date(\''+hora_entrada+'\',\'hh12:mi am\'), \'hh24mi\')) - to_number (to_char (to_date(\''+hora_salida+'\',\'hh12:mi am\'), \'hh24mi\'))), 1, gettiempo(to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\'), to_date(to_char(to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\') + 1,\'dd-mm-yyyy\') || \' \' || \''+hora_salida+'\',\'dd-mm-yyyy hh12:mi am\'),\'H\'),gettiempo (to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\'), to_date(to_char(to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\'), \'dd-mm-yyyy\') || \' \' || \''+hora_salida+'\', \'dd-mm-yyyy hh12:mi am\'), \'H\'))) hora', 'dual', '','');var v_min	= getDBData('<%=request.getContextPath()%>', '(decode(sign(to_number(to_char(to_date(\''+hora_entrada+'\',\'hh12:mi am\'), \'hh24mi\')) - to_number (to_char (to_date(\''+hora_salida+'\',\'hh12:mi am\'), \'hh24mi\'))), 1, gettiempo(to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\'), to_date(to_char(to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\') + 1,\'dd-mm-yyyy\') || \' \' || \''+hora_salida+'\',\'dd-mm-yyyy hh12:mi am\'),\'M\'),gettiempo (to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\'), to_date(to_char(to_date(to_char(sysdate,\'dd-mm-yyyy\')||\' \'||\''+hora_entrada+'\',\'dd/mm/yyyy hh12:mi am\'), \'dd-mm-yyyy\') || \' \' || \''+hora_salida+'\', \'dd-mm-yyyy hh12:mi am\'), \'M\'))) min', 'dual', '','');document.form<%=tipoSolicitud%>.dsp_hora.value = v_hora;document.form<%=tipoSolicitud%>.dsp_min.value = v_min;}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form"+tipoSolicitud,request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("estadoCita",estadoCita)%>
<%=fb.hidden("codAlmacen","")%>
<%//=fb.hidden("centroServicio","")%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("copiarInsumos","")%>
<%=fb.hidden("habitacion",habitacion)%>
<%=fb.hidden("cierre","")%>
<%=fb.hidden("cod_paciente","")%>
<%=fb.hidden("fec_nacimiento","")%>
<%=fb.hidden("admision","")%>
<%=fb.hidden("calcular_uso","0")%>
<%=fb.hidden("es_quirofano","N")%>
<%=fb.hidden("horaEntrada",""+horaEntrada)%>
<%=fb.hidden("horaSalida",""+horaSalida)%>
<%=fb.hidden("fName","")%>
<%=fb.hidden("uso","")%>
<%=fb.hidden("tipo_cita","")%>
<%=fb.hidden("pac_id","")%>

<%
int colspan = 13;
if(tipoSolicitud.equals("A")) colspan = 12;
String onChange = "javascript:calcTime"+tipoSolicitud+"();";
String jsEvent = "calcTime"+tipoSolicitud+"()";
%>
<table width="100%" align="center">
	<tr>
		<td colspan="<%=colspan%>"><table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextRow02">
				<td><cellbytelabel>HORA ENTRADA</cellbytelabel><%=((tipoSolicitud.equals("Q"))?" A SALON":" A ANESTESIA")%></td>
				<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="hora_entrada" />
					<jsp:param name="valueOfTBox1" value="<%=(sol.getHoraEntrada()!=null && !sol.getHoraEntrada().trim().equals(""))?sol.getHoraEntrada():horaEntrada%>" />
					<jsp:param name="fieldClass" value="Text10" />
					<jsp:param name="buttonClass" value="Text10" />
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="onChange" value="<%=onChange%>" />
					<jsp:param name="jsEvent" value="<%=jsEvent%>" />
					<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
				</jsp:include>
				</td>
				<td rowspan="2"><cellbytelabel>Tiempo de</cellbytelabel>&nbsp;
				<%if(tipoSolicitud.equals("Q")){%><cellbytelabel>uso del SOP</cellbytelabel><%}else{%><cellbytelabel>Anestesia</cellbytelabel><%}%>
				<%//=((tipoSolicitud.equals("Q"))?"uso del SOP":" Anestesia")%>
				<br>
							<%=fb.textBox("dsp_hora",sol.getDspHoras(),false,false,true,3)%>&nbsp;h.&nbsp;<%=fb.textBox("dsp_min",sol.getDspMin(),false,false,true,3)%>&nbsp;m.</td>
				<td><cellbytelabel>Fecha Solicitud</cellbytelabel></td>
				<td><%=sol.getFechaDocumento()%></td>
			</tr>
			<tr class="TextRow02">
				<td><cellbytelabel>HORA SALIDA</cellbytelabel> &nbsp;
				<%if(tipoSolicitud.equals("Q")){%><cellbytelabel>DE SALON</cellbytelabel><%}else{%><cellbytelabel>DE ANESTESIA</cellbytelabel><%}%>
				<%//=((tipoSolicitud.equals("Q"))?" DE SALON":" DE ANESTESIA")%></td>
				<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="hora_salida" />
					<jsp:param name="valueOfTBox1" value="<%=(sol.getHoraSalida()!=null && !sol.getHoraSalida().trim().equals(""))?sol.getHoraSalida():horaSalida%>" />
					<jsp:param name="fieldClass" value="Text10" />
					<jsp:param name="buttonClass" value="Text10" />
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="onChange" value="<%=onChange%>" />
					<jsp:param name="jsEvent" value="<%=jsEvent%>" />
					<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>					
				</jsp:include>
				</td>
				<td><cellbytelabel>AREA</cellbytelabel></td>
				<td><%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_centro_servicio where flag_cds = 'SOP'", "centroServicio",sol.getCentroServicio(),false,viewMode,0)%></td>
			</tr>
		</table></td>
	</tr>
	<tr class="TextHeader" align="center">
		<td colspan="<%=colspan%>" align="right"><%=fb.button("devolver", "Devolver x Lote", false, viewMode, "", "", "onClick=\"javascript: devolver"+tipoSolicitud+"();\"")%>
		<%=fb.button("addCargos", "Agregar Articulos", false, viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
	</tr>
	<tr class="TextHeader02">
		<td width="10%" align="center" colspan="3"><cellbytelabel>C&oacute;digo art&iacute;culo</cellbytelabel></td>
		<td width="28%" align="center"><cellbytelabel>Nombre del Art&iacute;culo</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Almacen</cellbytelabel></td>
		<td width="7%" align="center"><cellbytelabel>Und</cellbytelabel>.</td>
		<td width="7%" align="center"><cellbytelabel>Pedido</cellbytelabel></td>
		<td width="7%" align="center"><cellbytelabel>ENTREGA</cellbytelabel></td>
		<td width="7%" ><cellbytelabel>ADICION</cellbytelabel></td>
		<td width="7%" align="right"><cellbytelabel>DEVOLUC</cellbytelabel>.</td>
		<td width="7%" align="right"><cellbytelabel>UTILIZADO</cellbytelabel></td>
		<%
	if(tipoSolicitud.equals("Q")){
	%>
		<td width="10%" align="right">Paqte?</td>
		<%}%>
		<td width="3">&nbsp;</td>
	</tr>
	<%
CdcSolicitudDet ad = new CdcSolicitudDet();
if (tipoSolicitud.equals("Q")) al = CmnMgr.reverseRecords(fTranCargQ);
else if (tipoSolicitud.equals("A")) al = CmnMgr.reverseRecords(fTranCargA);

for (int i=0; i<al.size(); i++){
	key = al.get(i).toString();

	if(tipoSolicitud.equals("Q")) ad = (CdcSolicitudDet) fTranCargQ.get(key);
	else if(tipoSolicitud.equals("A")) ad = (CdcSolicitudDet) fTranCargA.get(key);
	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	boolean readonly = true;
%>
	<%=fb.hidden("disponible"+i,ad.getDisponible())%>
	<%=fb.hidden("renglon"+i,ad.getRenglon())%>

	<%=fb.hidden("art_familia"+i,ad.getArtFamilia())%>
	<%=fb.hidden("art_clase"+i,ad.getArtClase())%>
	<%=fb.hidden("cod_articulo"+i,ad.getCodArticulo())%>
	<%=fb.hidden("descripcion"+i,ad.getDescripcion())%>
	<%=fb.hidden("afect_inv"+i,ad.getAfectaInv())%>
	<%=fb.hidden("whArt"+i,ad.getOther1())%>
	<%=fb.hidden("descWh"+i,ad.getOther4())%>

	<tr class="<%=color%>" align="center">
		<td colspan="3"><%=ad.getArtFamilia()+"-"+ad.getArtClase()+"-"+ad.getCodArticulo()%></td>
		<td align="left"><%=ad.getDescripcion()%></td>
		<td align="left"><%=ad.getOther4()%></td>
		<td><%=fb.textBox("unidad"+i, ad.getUnidad(), false, false, true, 3, "Text10", "", "")%></td>
		<td><%=fb.intBox("cantidad"+i, ad.getCantidad(), false, false, true, 3, "Text10", null, "")%></td>
		<td><%=fb.intBox("entrega"+i, ad.getEntrega(), false, false, true, 3, "Text10", null, "onChange=\"javascript:chkValue("+i+")\"")%></td>
		<td><%=fb.intBox("adicion"+i, ad.getAdicion(), false, false, true, 3, "Text10", null, "onChange=\"javascript:chkValue("+i+")\"")%>
		<a href="javascript:addDevArt('A',<%=i%>);" title="Solicitar Cantidad Adicional"><img src="../images/plus_green.gif" height="17" width="16" border="0"></a>
		</td>
		<td><%=fb.intBox("devolucion"+i, ad.getDevolucion(), false, false, true, 3, "Text10", null, "onChange=\"javascript:chkValue("+i+")\"")%>
		<a href="javascript:addDevArt('D',<%=i%>);" title="Devolver Cantidad"><img src="../images/minus_red.gif" height="17" width="16" border="0"></a>
		</td>
		<td><%=fb.intBox("utilizado"+i, "", false, false, true, 3, "Text10", null, "")%></td>
		<%
	if(tipoSolicitud.equals("Q")){
	%>
		<td><%=fb.checkbox("paquete"+i, ad.getPaquete(), (ad.getPaquete().equals("S")?true:false), false, "Text10", "", "onClick=\"javascript:setCantidad("+i+")\"")%><%=fb.intBox("cantidad_paquete"+i,ad.getCantidadPaquete(),false,false,viewMode,4,"Text10",null,"")%></td>
		<%}%>
		<td align="center"><%
	if(ad.getRenglon().equals("")){
	%>
				<%//=fb.submit("del"+i,"x",false,viewMode)%>
				<%
	}
	%>
		</td>
	</tr>
	<%
}
%>
	<%
if(tipoSolicitud.equals("Q")){
%>
	<%=fb.hidden("keySize",""+fTranCargQ.size())%>
	<%
} else if(tipoSolicitud.equals("A")){
%>
	<%=fb.hidden("keySize",""+fTranCargA.size())%>
	<%
}
%>
	<%=fb.hidden("cont_trx",""+contY)%>
	<tr>
		<td colspan="<%=(tipoSolicitud.equals("A")?"6":"5")%>" align="left"><a href="javascript:solTrx()"><font color="#FF0000" size="+1"><%=((contY>0)?"Hay Transacciones Pendientes":"")%></font></a></td>
		<td colspan="<%=(tipoSolicitud.equals("Q")?"7":"5")%>" align="right">
		<%=fb.button("imprimir","Reporte Solic. Materiales",true,viewMode,null,null,"onClick=\"javascript:printSolPrevMat('"+tipoSolicitud+"')\"")%>
		<authtype type='50'><%=fb.button("cerrar_sol","Cerrar Solicitud",true,viewMode,null,null,"onClick=\"javascript:cierre"+tipoSolicitud+"()\"")%></authtype>
		</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="<%=colspan%>" align="right"> <cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:_doSubmit(this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%> </td>
	</tr>
</table>
<script type="text/javascript">calcTime<%=tipoSolicitud%>();doAction(1);</script>


<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "";
	//Ajuste CdcSol = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	String anio = CmnMgr.getCurrentDate("yyyy");

	CdcSol.setCompania(request.getParameter("compania"));
	CdcSol.setCitaCodigo(request.getParameter("codCita"));
	CdcSol.setCitaFechaReg(request.getParameter("fechaCita"));
	CdcSol.setCodigoAlmacen(request.getParameter("codAlmacen"));
	CdcSol.setCentroServicio(request.getParameter("centroServicio"));
	CdcSol.setTipoSolicitud(request.getParameter("tipoSolicitud"));
	CdcSol.setCopiarInsumos(request.getParameter("copiarInsumos"));
	CdcSol.setEstado("P");
	if(CdcSol.getTipoSolicitud()!=null && CdcSol.getTipoSolicitud().equals("A")) CdcSol.setDescricion("ANESTESIA");
	else if(CdcSol.getTipoSolicitud()!=null && CdcSol.getTipoSolicitud().equals("Q")) CdcSol.setDescricion("QUIRURGICO");
	//if(request.getParameter("habitacion")!=null && request.getParameter("habitacion").equals("E")) CdcSol.setCentroServicio("4");

	if(request.getParameter("admision") !=null && !request.getParameter("admision").equals("")) CdcSol.setAdmision(request.getParameter("admision"));
	if(request.getParameter("pac_id") !=null && !request.getParameter("pac_id").equals("")) CdcSol.setPacId(request.getParameter("pac_id"));
	if(request.getParameter("fec_nacimiento") !=null && !request.getParameter("fec_nacimiento").equals("")) CdcSol.setFechaNacimiento(request.getParameter("fec_nacimiento"));
	if(request.getParameter("cod_paciente") !=null && !request.getParameter("cod_paciente").equals("")) CdcSol.setCodigoPaciente(request.getParameter("cod_paciente"));
	if(request.getParameter("secuencia") !=null && !request.getParameter("secuencia").equals("")) CdcSol.setSecuencia(request.getParameter("secuencia"));
	if(request.getParameter("hora_entrada") !=null && !request.getParameter("hora_entrada").equals("")) CdcSol.setHoraEntrada(request.getParameter("hora_entrada"));
	if(request.getParameter("hora_salida") !=null && !request.getParameter("hora_salida").equals("")) CdcSol.setHoraSalida(request.getParameter("hora_salida"));
	//if(request.getParameter("") !=null && !request.getParameter("").equals("")) CdcSol.set(request.getParameter(""));
	if(request.getParameter("fName") !=null && !request.getParameter("fName").equals("")) CdcSol.setFormName(request.getParameter("fName"));
	if(request.getParameter("estadoCita") !=null && !request.getParameter("estadoCita").equals("")) CdcSol.setEstadoCita(request.getParameter("estadoCita"));
	if(request.getParameter("habitacion") !=null && !request.getParameter("habitacion").equals("")) CdcSol.setHabitacion(request.getParameter("habitacion"));
	if(request.getParameter("dsp_hora") !=null && !request.getParameter("dsp_hora").trim().equals("")) CdcSol.setDspHoras(request.getParameter("dsp_hora"));
	else CdcSol.setDspHoras("0");
	if(request.getParameter("dsp_min") !=null && !request.getParameter("dsp_min").trim().equals("")) CdcSol.setDspMin(request.getParameter("dsp_min"));
	else CdcSol.setDspMin("0");
	if(request.getParameter("calcular_uso") !=null && !request.getParameter("calcular_uso").equals("")) CdcSol.setCalcularUso(request.getParameter("calcular_uso"));
	
	CdcSol.setUso(request.getParameter("uso"));
	CdcSol.setTipoCita(request.getParameter("tipo_cita"));
	
	CdcSol.getCdcSolicitudDetail().clear();
	fTranCargQ.clear();
	lineNo = 0;

	String _key = "", okey = "";
	
	for (int i=0; i<keySize; i++){
		CdcSolicitudDet det = new CdcSolicitudDet();
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setCantidad(request.getParameter("cantidad"+i));
		det.setEstadoRenglon("Q");
		det.setPaquete("N");
		//det.setDescuento(request.getParameter("desc"+i));
		det.setAfectaInv(request.getParameter("afecta_inv"+i));

		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));
		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));
		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));
		if(request.getParameter("unidad"+i)!=null && !request.getParameter("unidad"+i).equals("null") && !request.getParameter("unidad"+i).equals("")) det.setUnidad(request.getParameter("unidad"+i));
		if(request.getParameter("entrega"+i)!=null && !request.getParameter("entrega"+i).equals("null") && !request.getParameter("entrega"+i).equals("")) det.setEntrega(request.getParameter("entrega"+i));
		if(request.getParameter("adicion"+i)!=null && !request.getParameter("adicion"+i).equals("null") && !request.getParameter("adicion"+i).equals("")) det.setAdicion(request.getParameter("adicion"+i));
		if(request.getParameter("devolucion"+i)!=null && !request.getParameter("devolucion"+i).equals("null") && !request.getParameter("devolucion"+i).equals("")) det.setDevolucion(request.getParameter("devolucion"+i));
		if(request.getParameter("paquete"+i)!=null && !request.getParameter("paquete"+i).equals("null") && !request.getParameter("paquete"+i).equals("")) det.setPaquete(request.getParameter("paquete"+i));
		if(request.getParameter("cantidad_paquete"+i)!=null && !request.getParameter("cantidad_paquete"+i).equals("null") && !request.getParameter("cantidad_paquete"+i).equals("")) det.setCantidadPaquete(request.getParameter("cantidad_paquete"+i));
		if(request.getParameter("renglon"+i)!=null && !request.getParameter("renglon"+i).equals("null") && !request.getParameter("renglon"+i).equals("")) det.setRenglon(request.getParameter("renglon"+i));
		det.setOther1(request.getParameter("whArt"+i));		

		String fck = tipoSolicitud+"_"+det.getCodArticulo();
		if(request.getParameter("del"+i)==null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			if(tipoSolicitud.equals("A")){
				try{
					fTranCargA.put(key,det);
					fTranCargAKey.put(fck, key);
					if(request.getParameter("utilizado"+i)!=null && !request.getParameter("utilizado"+i).equals("") && request.getParameter("baction") != null && !request.getParameter("baction").equalsIgnoreCase("Cerrar")){
						CdcSol.getCdcSolicitudDetail().add(det);
					}
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			} else if(tipoSolicitud.equals("Q")){
				try{
					fTranCargQ.put(key,det);
					fTranCargQKey.put(fck, key);
					if(request.getParameter("utilizado"+i)!=null && !request.getParameter("utilizado"+i).equals("") && request.getParameter("baction") != null && !request.getParameter("baction").equalsIgnoreCase("Cerrar")){
						CdcSol.getCdcSolicitudDetail().add(det);
					}
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			}

		} else {
			dl = fck;
			if(tipoSolicitud.equals("A")){
				if (fTranCargAKey.containsKey(dl)){
					fTranCargA.remove((String) fTranCargAKey.get(dl));
					fTranCargAKey.remove(dl);
				}
			} else if(tipoSolicitud.equals("Q")){
				if (fTranCargQKey.containsKey(dl)){
					fTranCargQ.remove((String) fTranCargQKey.get(dl));
					fTranCargQKey.remove(dl);
				}
			}
			//CdcSol.getCdcSolail().remove(i);
		}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode+"&fp="+fp+"&change1=1&change2=1&type=2&fg="+fg+"&tipoSolicitud="+tipoSolicitud+"&secuencia="+secuencia+"&codCita="+codCita+"&fechaCita="+fechaCita+"&habitacion="+habitacion+"&estadoCita="+estadoCita+"&horaEntrada="+request.getParameter("hora_entrada")+"&horaSalida="+request.getParameter("hora_salida"));
		return;
	}

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Agregar Articulos")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode+"&fp="+fp+"&id="+id+"&change1=1&change2=1&type=1&tipoTrx=A&fg="+fg+"&tipoSolicitud="+tipoSolicitud+"&secuencia="+secuencia+"&codCita="+codCita+"&fechaCita="+fechaCita+"&habitacion="+habitacion+"&estadoCita="+estadoCita+"&horaEntrada="+request.getParameter("hora_entrada")+"&horaSalida="+request.getParameter("hora_salida"));
		return;
	}

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("solTrx")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode+"&fp="+fp+"&id="+id+"&change1=1&change2=1&type=2&fg="+fg+"&tipoSolicitud="+tipoSolicitud+"&secuencia="+secuencia+"&codCita="+codCita+"&fechaCita="+fechaCita+"&habitacion="+habitacion+"&estadoCita="+estadoCita+"&horaEntrada="+request.getParameter("hora_entrada")+"&horaSalida="+request.getParameter("hora_salida")+"&solTrx=S");
		return;
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar") || request.getParameter("baction").equalsIgnoreCase("cerrar")){
	
	if (request.getParameter("baction").equalsIgnoreCase("cerrar")){CdcSol.setFg("CERRAR");}//Cerrar solicitudes
	if (request.getParameter("cierre").equalsIgnoreCase("N")){CdcSol.setAccion("");}
	else if (request.getParameter("baction")!=null && !request.getParameter("baction").trim().equals(""))CdcSol.setAccion(request.getParameter("baction"));//Accion
	
		CdcSol.setCompania((String) session.getAttribute("_companyId"));
		CdcSol.setUsuarioCreacion((String) session.getAttribute("_userName"));
		CdcSol.setUsuarioModif((String) session.getAttribute("_userName"));
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&fg="+fg+"&baction="+request.getParameter("baction"));
		CdcSolMgr.addSolicitudDetTrx(CdcSol);
		ConMgr.clearAppCtx(null);
	}
	/*
	session.removeAttribute("fTranCargQ");
	session.removeAttribute("fTranCargQKey");
	session.removeAttribute("fTranCargA");
	session.removeAttribute("fTranCargAKey");
	*/

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(cerrar)
{
	var closed = false;
	var cierre = 'N';
	var cerrado = 'N';
	<%
	if(CdcSolMgr.getErrCode().equals("1")){
	%>
	if(cerrar=='S'){
		cerrado = 'S';
		cierre = 'S';
	}

	<%
	}
	if(tipoSolicitud.equals("Q")){
	%>
	parent.document.form0.errCode.value = <%=CdcSolMgr.getErrCode()%>;
	parent.document.form0.errMsg.value = '<%=CdcSolMgr.getErrMsg()%>';
	parent.document.form0.baction.value = '<%=request.getParameter("baction")%>';
	parent.document.form0.saveOption.value = '<%=request.getParameter("saveOption")%>';
	parent.document.form0.cierre.value = cierre;
	parent.document.form0.cerrado.value = cerrado;
	parent.document.form0.fp.value = '<%=fp%>';
	parent.document.form0.submit();
	<%
	} else if(tipoSolicitud.equals("A")){
	%>
	parent.document.form1.errCode.value = <%=CdcSolMgr.getErrCode()%>;
	parent.document.form1.errMsg.value = '<%=CdcSolMgr.getErrMsg()%>';
	parent.document.form1.baction.value = '<%=request.getParameter("baction")%>';
	parent.document.form1.saveOption.value = '<%=request.getParameter("saveOption")%>';
	parent.document.form1.cierre.value = cierre;
	parent.document.form1.cerrado.value = cerrado;
	parent.document.form0.fp.value = '<%=fp%>';
    parent.document.form1.submit();
	<%
	}
	%>
}
</script>
</head>
<body onLoad="closeWindow('<%=request.getParameter("cierre")%>')">
</body>
</html>
<%
}//POST
%>