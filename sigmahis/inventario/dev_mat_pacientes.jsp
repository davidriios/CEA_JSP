<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.inventory.DevolucionPaciente"%>
<%@ page import="issi.inventory.DevDetSolPac"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iDevMateriales" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDetMat" scope="session" class="java.util.Vector"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
/**
==================================================================================
	FG    FP          DESCRIPCION
	DM 		SOLICITUD DE DEVOLUCION DE MATERIALES PACIENTE.
	DMA 	APROBACION DE SOLICITUD DE DEVOLUCION DE MATERIALES DE PACIENTE.
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

DevolucionPaciente devP = new DevolucionPaciente();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String idDev = request.getParameter("idDev");
StringBuffer sbSql = new StringBuffer();
String centro = "";
String empresa = "";
String filter = "";
String anio = request.getParameter("anio");
boolean viewMode = false;

int devLastLineNo = 0;

System.out.println("anio = "+anio);
if (mode == null) mode = "add";
if (anio == null) anio = cDateTime.substring(6,10) ;
if (id == null) id = "0";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if(mode.trim().equals("view")) viewMode = true;

if (request.getParameter("devLastLineNo") != null) devLastLineNo = Integer.parseInt(request.getParameter("devLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
			iDevMateriales.clear();
			vDetMat.clear();
			id = "0";
			devP =  new DevolucionPaciente();
			devP.setFecha(cDateTime.substring(0,10));
			devP.setEstado("T");
			devP.setCompania((String) session.getAttribute("_companyId"));
			devP.setUsuarioCreacion((String) session.getAttribute("_userName"));
			devP.setUsuarioModif((String) session.getAttribute("_userName"));
			devP.setSubtotal("0.0");
			devP.setAsientoSino("N");
			sql = "select a.nombre_empleado nombre,a.provincia, a.sigla, a.tomo, a.asiento, a.emp_id from vw_pla_empleado a, tbl_sec_users b where a.emp_id = b.ref_code and b.user_type = 1 and b.user_name = '"+(String) session.getAttribute("_userName")+"'";

			cdo = SQLMgr.getData(sql);
			if(cdo == null) cdo = new CommonDataObject();else{
			devP.setProvinciaEnv(cdo.getColValue("provincia"));
			devP.setSiglaEnv(cdo.getColValue("sigla"));
			devP.setTomoEnv(cdo.getColValue("tomo"));
			devP.setAsientoEnv(cdo.getColValue("asiento"));
			devP.setEmpIdEnv(cdo.getColValue("emp_id"));
			devP.setNombreEmpleado(cdo.getColValue("nombre"));
		}
	}
	else
	{
		if (id == null) throw new Exception("El Numero de Transaccion no es válido. Por favor intente nuevamente!");

sql="select (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as descTipoAdm, dp.anio, dp.num_devolucion numDevolucion, dp.compania, nvl(to_char(dp.fecha, 'dd/mm/yyyy'), ' ') fecha, nvl(dp.provincia_env, 0) provinciaEnv, nvl(dp.sigla_env, ' ') siglaEnv, nvl(dp.tomo_env, 0) tomoEnv, nvl(dp.asiento_env, 0) asientoEnv, nvl(dp.provincia_rec, 0) provinciaRec, nvl(dp.sigla_rec, ' ') siglaRec, nvl(dp.tomo_rec, 0) tomoRec, nvl(dp.asiento_rec, 0) asientoRec, nvl(dp.monto, 0) monto, nvl(dp.subtotal,0) suttotal, nvl(dp.itbm,0)itbm , nvl(dp.usuario_creacion,' ') usuarioCreacion, nvl(to_char(dp.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am'), ' ') fechaCreacion, nvl(dp.usuario_modif,' ') usuarioModif, nvl(to_char(dp.fecha_modif, 'dd/mm/yyyy hh12:mi:ss am'), ' ') fechaModif, nvl(to_char(dp.fecha_nacimiento,'dd/mm/yyyy'),' ')fechaNacimiento, nvl(dp.paciente,0)paciente, nvl(dp.codigo_almacen,0) codigoAlmacen,  nvl(dp.anio_entrega,0) anioEntrega, nvl(dp.no_entrega,0)noEntrega, nvl(dp.adm_secuencia,0) admSecuencia, nvl(dp.asiento_sino, 'N')asientoSino,  nvl(dp.estado,' ') estado, nvl(dp.sala,' ') sala, nvl(dp.observacion,' ') observacion, nvl(dp.cod_medico,' ') codMedico, nvl(dp.sala_cod,0) salaCod, nvl(dp.no_receta, 0) noReceta,  nvl(dp.solicitud_pac_pamd,0) solicitudPacPamd, nvl(dp.anio_solic_pac_pamd,0) anioSolicPacPamd,  nvl(dp.emp_id_env,0) empIdEnv, nvl(dp.emp_id_rec,0)empIdRec,    nvl(dp.pac_id,0) pacId, nvl(cs.descripcion,' ') as descCentro, nvl(al.descripcion,' ') descAlmacen, nvl(e.emp_id,0) empId ,p.nombre_paciente as  nombrePaciente ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento, nvl(p.pasaporte,' ')pasaporte, e.nombre_empleado as nombreEmpleado, decode(dp.emp_id_rec ,null ,' ',r.nombre_empleado) as nombreEmpleadoRec ,ta.descripcion as descTipoAdmision, nvl(decode(a.fecha_egreso, null, to_char(sysdate, 'dd/mm/yyyy'), to_char(a.fecha_egreso, 'dd/mm/yyyy')), ' ') fechaEgreso from tbl_inv_devolucion_pac dp, tbl_cds_centro_servicio cs, vw_pla_empleado e, vw_pla_empleado r,tbl_inv_almacen al,vw_adm_paciente p,tbl_adm_tipo_admision_cia ta, tbl_adm_admision a where dp.anio = "+anio+" and dp.compania = "+(String) session.getAttribute("_companyId")+" and  dp.num_devolucion= "+id+" and dp.pac_id= "+pacId+" and dp.adm_secuencia= "+noAdmision+" and dp.sala_cod = cs.codigo(+) and dp.emp_id_env = e.emp_id(+) and dp.emp_id_rec = r.emp_id(+) and dp.compania = r.compania(+) and dp.compania = e.compania(+) and dp.codigo_almacen= al.codigo_almacen(+) and dp.compania = al.compania(+) and dp.pac_id = p.pac_id(+) and a.pac_id = " + pacId +" and a.secuencia = " + noAdmision + " and (ta.categoria = a.categoria and ta.codigo = a.tipo_admision) and a.compania="+(String) session.getAttribute("_companyId");

		System.out.println("*******SQL:\n"+sql);
		devP = (DevolucionPaciente) sbb.getSingleRowBean(ConMgr.getConnection(),sql, DevolucionPaciente.class);

		centro = devP.getSalaCod();
		empresa = devP.getEmpresa();

		filter = "";
		if(fg.equals("DMA")&& devP.getEmpIdRec().trim().equals("0") ){
			sql = "select a.nombre_empleado nombre,a.provincia, a.sigla, a.tomo, a.asiento, a.emp_id from vw_pla_empleado a, tbl_sec_users b where a.emp_id = b.ref_code and b.user_type = 1 and b.user_name = '"+(String) session.getAttribute("_userName")+"'";

			cdo = SQLMgr.getData(sql);
			if(cdo == null) cdo = new CommonDataObject();
			devP.setProvinciaRec(cdo.getColValue("provincia"));
			devP.setSiglaRec(cdo.getColValue("sigla"));
			devP.setTomoRec(cdo.getColValue("tomo"));
			devP.setAsientoRec(cdo.getColValue("asiento"));
			devP.setEmpIdRec(cdo.getColValue("emp_id"));
			devP.setNombreEmpleadoRec(cdo.getColValue("nombre"));
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Devolucion de materiales - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Devolucion de materiales  - Edición - "+document.title;
<%}
else{%>
document.title="Devolucion de materiales  - Consultas - "+document.title;
<%}%>
function saveMethod(baction){
var pacId =document.devolucion.pacId.value;
var noAdmision =document.devolucion.noAdmision.value; 
var benef = getDBData('<%=request.getContextPath()%>','count(*)','TBL_ADM_BENEFICIOS_X_ADMISION ','pac_id='+pacId+' and admision='+noAdmision+' AND prioridad=1 and estado=\'A\'','');
if(parseInt(benef)==0){CBMSG.warning('La admision no tiene Beneficios asignados... VERIFIQUE!!!');}else{
setBAction('devolucion',baction);if(devolucionValidation())window.frames['iDetalle0'].doSubmit();}
}
function showPacienteList()
{
	var status = '';//document.devolucion.status.value;
	var centro = document.devolucion.codigo_sala.value;
	var flag_cds = document.devolucion.flag_cds.value;
	var size = window.frames['iDetalle0'].document.forms['formSub'].devSize.value;
	var categoria = '';
	if(size==0)
	{
		if(document.devolucion.codigo_sala.value != '')
		abrir_ventana1('../common/sel_paciente.jsp?fp=<%=fg%>&fg='+flag_cds+'&estado='+status+'&centro='+centro+'&categoria='+categoria);
		else alert('seleccione Sala');
	}
	else alert('No puede Cambiar de Paciente ya tiene Registros Agregados....');
}
function showEmpleadoList(){var emp_id_env = document.devolucion.emp_id_env.value;abrir_ventana1('../common/search_empleado.jsp?fg=<%=fp%>&fp=<%=fg%>&emp_id_env='+emp_id_env);}
function buscaSala(){var size = window.frames['iDetalle0'].document.forms['formSub'].devSize.value;if(size>0){document.devolucion.nombrePaciente.focus();return false;} else {setFlagCds();return true;}}
function setFlagCds()
{
	var cds = document.devolucion.codigo_sala.value;
	var x = getDBData('<%=request.getContextPath()%>', 'nvl(flag_cds, \'-1\') flag_cds','tbl_cds_centro_servicio','estado = \'A\' and codigo = '+cds,'');
	var arr_cursor = new Array();
	if(x!=''){
		if(x!='-1') document.devolucion.flag_cds.value	= x;
		else document.devolucion.flag_cds.value = '';
	}
}

function buscaCA(){
	var codAlmacen = document.devolucion.codigo_almacen.value;
	var size = window.frames['iDetalle0'].document.forms['formSub'].devSize.value;
	if(size==0)
	abrir_ventana1('../inventario/sel_dev_almacen.jsp?fg=<%=fg%>&fp=<%=fp%>&codAlmacen='+codAlmacen);
}

function doAction(){
	var cds = document.devolucion.codigo_sala.value;
	if(cds!='') setFlagCds();
<%
if (request.getParameter("type") != null && request.getParameter("type").trim().equals("2"))
	{ %>
		showSolicitud();
	<%}else if (request.getParameter("type") != null && request.getParameter("type").trim().equals("3")){%>
	abrir_ventana1('../inventario/print_devolucion_paciente.jsp?fg=<%=fg%>&fp=<%=fp%>&id=<%=idDev%>');
	<%}%>
}
function showSolicitud(){abrir_ventana1('../inventario/print_devolucion_paciente.jsp?id=<%=anio%><%=id%>&fg=<%=fg%>&fp=<%=fp%>');}
function reporte(){abrir_ventana1('../inventario/print_devolucion_paciente.jsp?id=<%=anio%><%=id%>&fg=<%=fg%>&fp=<%=fp%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - TRANSACCIONES - DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="0">
				<tr>
					<td><table align="center" width="100%" cellpadding="0" cellspacing="0">
							<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
							<%fb = new FormBean("devolucion",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
							<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
							<%=fb.hidden("id",id)%>
							<%=fb.hidden("baction","")%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("devLastLineNo",""+devLastLineNo)%>
							<%=fb.hidden("devSize",""+iDevMateriales.size())%>
							<%=fb.hidden("fg",fg)%>
							<%=fb.hidden("fp",fp)%> 
							<%=fb.hidden("emp_id",devP.getEmpIdEnv())%>
							<%=fb.hidden("compania",devP.getCompania())%>
							<%if(fg.trim().equals("DM")){%>
							<%=fb.hidden("provincia_rec",devP.getProvinciaRec())%>
							<%=fb.hidden("sigla_rec",devP.getSiglaRec())%>
							<%=fb.hidden("tomo_rec",devP.getTomoRec())%>
							<%=fb.hidden("asiento_rec",devP.getAsientoRec())%>
							<%}%>
							<%=fb.hidden("monto","")%>
							<%//=fb.hidden("subtotal","")%>
							<%=fb.hidden("itbm","")%>
							<%=fb.hidden("usuario_creacion",devP.getUsuarioCreacion())%>
							<%=fb.hidden("fecha_creacion",devP.getFechaCreacion())%>
							<%=fb.hidden("usuario_modif",devP.getUsuarioModif())%>
							<%=fb.hidden("fecha_modif",devP.getFechaModif())%>
							<%=fb.hidden("anio_entrega",devP.getAnioEntrega())%>
							<%=fb.hidden("no_entrega",devP.getNoEntrega())%>
							<%=fb.hidden("asiento_sino",devP.getAsientoSino())%>
							<%=fb.hidden("estado",devP.getEstado())%>
							<%=fb.hidden("cod_medico",devP.getCodMedico())%>
							<%=fb.hidden("no_receta",devP.getNoReceta())%>
							<%=fb.hidden("solicitud_pac_pamd",devP.getSolicitudPacPamd())%>
							<%=fb.hidden("anio_solic_pac_pamd",devP.getAnioSolicPacPamd())%>
							<%=fb.hidden("emp_id_env",devP.getEmpIdEnv())%>
							<%=fb.hidden("emp_id_rec",devP.getEmpIdRec())%>
							<%=fb.hidden("empresa",devP.getEmpresa())%>
							<%=fb.hidden("edad",devP.getEdad())%>
							<%=fb.hidden("tipo_incremento",devP.getTipoIncremento())%>
							<%=fb.hidden("incremento",devP.getIncremento())%>
							<%=fb.hidden("clasificacion",devP.getClasificacion())%>
							<%=fb.hidden("fecha_egreso",devP.getFechaEgreso())%>
							<%=fb.hidden("flag_cds","")%>
							<tr>
								<td colspan="5"><table align="center" width="100%" cellpadding="0" cellspacing="1">
										<tr>
											<td colspan="5">&nbsp;</td>
										</tr>
										<tr class="TextRow02">
											<td colspan="5" align="right">&nbsp;</td>
										</tr>
										<tr class="TextPanel">
											<td colspan="5">Devoluci&oacute;n</td>
										</tr>
										<tr class="TextRow01" >
											<td width="12%" align="right">N&uacute;mero:</td>
											<td width="16%">
											<%=fb.intBox("anio",anio,true,viewMode,true,4,null,null,"")%> <%=fb.intBox("num_dev",id,true,viewMode,true,4,null,null,"")%>
											</td>
											<td width="20%" align="center">
					<%sbSql = new StringBuffer();
					if(!UserDet.getUserProfile().contains("0"))
					{
						sbSql.append(" and codigo_almacen in (");
							if(session.getAttribute("_almacen_cds")!=null)
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
							else sbSql.append("-2");
						sbSql.append(")");
					}%>
											<%
											String label ="",sql1="";
											sql1= "select codigo_almacen, codigo_almacen||' - '||descripcion  from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+ sbSql.toString()+" order by 1 ";
											%>
											</td>
											<td width="10%" align="right">Fecha de Devoluci&oacute;n</td>
											<td width="16%"><%=fb.textBox("fecha",devP.getFecha(),true,viewMode,true,10,null,null,"")%>
											<%//=fb.textBox("fecha_devolucion",(DevDet.getFechaDevolucion()==null)?fecha:DevDet.getFechaDevolucion(),true,false,true,10,null,null,"")%>
											</td>
										</tr>
										<tr class="TextPanel">
											<td colspan="5">Almac&eacute;n</td>
										</tr>
										<tr class="TextRow01" >
											<td align="right">C&oacute;digo</td>
											<td colspan="2">
												<%if(mode.trim().equals("add")){%>
												<%=fb.select(ConMgr.getConnection(),sql1,"codigo_almacen",(devP.getCodigoAlmacen()!=null && !devP.getCodigoAlmacen().equals("")?devP.getCodigoAlmacen():(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"almacen_cds").equals("")?SecMgr.getParValue(UserDet,"almacen_cds"):"")),false,false,0,null,null,"")%>
												<%}else{%>
												<%=fb.intBox("codigo_almacen",devP.getCodigoAlmacen(),true,viewMode,true,5,null,null,"")%>
												<%=fb.textBox("desc_codigo_almacen",devP.getDescAlmacen(),true,viewMode,true,30,null,null,"")%>
												<%}%>
												<%//=fb.button("buscar","...",(!viewMode),(viewMode || fp.trim().equals("DMA")),"","","onClick=\"javascript:buscaCA()\"")%>
											</td>
											<td colspan="3">
					 <%sbSql = new StringBuffer();
					if(!UserDet.getUserProfile().contains("0"))
					{
						sbSql.append(" and codigo in (");
							if(session.getAttribute("_cds")!=null)
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
							else sbSql.append("-1");
						sbSql.append(")");
					}%>
						Sala:
											<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where estado = 'A' /*and origen = 'S'*/ and compania_unorg = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","codigo_sala",(devP.getSalaCod()!=null && !devP.getSalaCod().equals("")?devP.getSalaCod():(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"cds").equals("")?SecMgr.getParValue(UserDet,"cds"):"")),false,false,0, "text10", "", "onClick=\"javascript:return(buscaSala());\"")%>
												<%//=fb.intBox("codigo_sala",devP.getSalaCod(),true,viewMode,true,5,null,null,"")%>
												<%//=fb.textBox("desc_codigo_sala",devP.getDescCentro(),true,viewMode,true,30,null,null,"")%>
												<%//=fb.button("buscar","...",false,(viewMode || fg.trim().equals("DMA")),"","","onClick=\"javascript:buscaSala()\"")%>
											</td>
										</tr>
										<tr>
											<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer" colspan="5"><table width="100%" cellpadding="0" cellspacing="0">
													<tr class="TextPanel">
														<td width="95%">&nbsp;Paciente</td>
														<td width="5%" align="right">[<font face="Courier New, Courier, mono">
															<label id="plus0" style="display:none">+</label>
															<label id="minus0">-</label>
															</font>]&nbsp;</td>
													</tr>
												</table></td>
										</tr>
										<tr id="panel0">
											<td colspan="5"><table width="100%" cellpadding="0" cellspacing="1">
													<tr class="TextRow01">
														<td align="right">Nombre</td>
														<td colspan="3">
														<%=fb.textBox("nombrePaciente",devP.getNombrePaciente(),true,viewMode,true,50)%>
														<%=fb.button("btnPac_id","...",false,(viewMode || fg.trim().equals("DMA")),"","","onClick=\"javascript:showPacienteList()\"")%>
														</td>
													</tr>
													<tr class="TextRow01">
														<td width="15%" align="right">C&eacute;dula</td>
														<td width="35%">
														<%=fb.intBox("provincia",devP.getProvincia(),false,viewMode,true,2)%>
														<%=fb.textBox("sigla",devP.getSigla(),false,viewMode,true,2)%>
														<%=fb.intBox("tomo",devP.getTomo(),false,viewMode,true,4)%>
														<%=fb.intBox("asiento",devP.getAsiento(),false,viewMode,true,5)%>
														</td>
														<td width="15%" align="right">Pasaporte</td>
														<td width="35%"><%=fb.textBox("pasaporte",devP.getPasaporte(),false,viewMode,true,20)%></td>
													</tr>
													<tr class="TextRow01">
														<td align="right">Còdigo</td>
														<td>
														<%=fb.hidden("fechaNacimiento",devP.getFechaNacimiento())%>
														<%=fb.hidden("codigoPaciente",devP.getPaciente())%>
														<%=fb.intBox("pacId",devP.getPacId(),false,viewMode,true,10,30)%>							
														<%=fb.intBox("noAdmision",devP.getAdmSecuencia(),false,viewMode,true,3)%>
														</td>
														<td align="right">Tipo Admisión</td>
														<td><%=fb.textBox("descAdmision",devP.getDescTipoAdm(),false,viewMode,true,30)%> </td>
													</tr>
												</table></td>
										</tr>
										<%//if(fp.trim().equals("DM")){%>
										<tr class="TextPanel">
											<td colspan="5">Oficinista</td>
										</tr>
										<tr class="TextRow01">
											<td align="right">Generado Por</td>
											<td colspan="4">
											<%=fb.textBox("empProvincia",devP.getProvinciaEnv(),false,viewMode,true,2)%>
											<%=fb.textBox("empSigla",devP.getSiglaEnv(),false,viewMode,true,2)%>
											<%=fb.textBox("empTomo",devP.getTomoEnv(),false,viewMode,true,5)%>
											<%=fb.textBox("empAsiento",devP.getAsientoEnv(),false,viewMode,true,5)%>
											<%=fb.textBox("empNombre",devP.getNombreEmpleado(),false,viewMode,true,40)%>

											<%if(!fg.trim().equals("DMA") ){%>
											<%=fb.button("btnOficinista","...",(!viewMode ),(viewMode || fg.trim().equals("DM")),null,null,"onClick=\"javascript:showEmpleadoList()\"")%>
											<%}%>

											</td>
										</tr>
										<%//}%>
										<%if(fg.trim().equals("DMA") || mode.trim().equals("view")){%>
										<tr class="TextPanel">
											<td colspan="5">Almacenista</td>
										</tr>
										<tr class="TextRow01">
											<td align="right">Recibido Por</td>
											<td colspan="4">
											<%=fb.textBox("provincia_rec",devP.getProvinciaRec(),false,viewMode,true,2)%>
											<%=fb.textBox("sigla_rec",devP.getSiglaRec(),false,viewMode,true,2)%>
											<%=fb.textBox("tomo_rec",devP.getTomoRec(),false,viewMode,true,5)%>
											<%=fb.textBox("asiento_rec",devP.getAsientoRec(),false,viewMode,true,5)%>
											<%=fb.textBox("nombre_rec",devP.getNombreEmpleadoRec(),false,viewMode,true,40)%>

												<%//=fb.button("btnOficinista","...",(!viewMode),viewMode,null,null,"onClick=\"javascript:showEmpleadoList()\"")%>
												<%if(fg.trim().equals("DMA") ){%>
												<%=fb.button("btnOficinista","...",(!viewMode ),(viewMode || fg.trim().equals("DM")),null,null,"onClick=\"javascript:showEmpleadoList()\"")%>
												<%}%>

											</td>
										</tr>
										<%}%>
					 <tr class="TextRow02">
											<td align="right">Usuario Creacion:</td>
						<td align="right"><%=devP.getUsuarioCreacion()%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=devP.getFechaCreacion()%></td>
						<td align="right">Usuario Modificacion :</td>
						<td align="right" colspan="2"><%=devP.getUsuarioModif()%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=devP.getFechaModif()%></td>
					</tr>
										<tr class="TextRow01">
											<td align="right">Comentarios</td>
											<td colspan="3"><%=fb.textarea("observacion",devP.getObservacion(),false,viewMode,false,60,4)%></td>
											<%if(!mode.trim().equals("add") ){%>
											<td><%=fb.button("btnSol","Imprimr reporte",false,false,null,null,"onClick=\"javascript:reporte()\"")%></td>
											<%}else{%>
											<td>&nbsp;</td>
											<%}%>
										</tr>
									</table></td>
							</tr>
							<tr>
								<td align="center" colspan="5" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="0" cellspacing="1">
										<tr class="TextPanel">
											<td width="94%">&nbsp;Detalle</td>
											<td width="5%" align="right">[<font face="Courier New, Courier, mono">
												<label id="plus1" style="display:none">+</label>
												<label id="minus1">-</label>
												</font>]&nbsp;</td>
										</tr>
									</table></td>
							</tr>
							<tr id="panel1">
								<td colspan="5"><iframe name="iDetalle0" id="iDetalle0" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../inventario/dev_pac_det.jsp?mode=<%=mode%>&devLastLineNo=<%=devLastLineNo%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&anio=<%=anio%>&fp=<%=fp%>&fg=<%=fg%>&centro=<%=centro%>&empresa=<%=empresa%>&wh=<%=devP.getCodigoAlmacen()%>"></iframe></td>
							</tr>
							<%//}%>
							<tr class="TextRow02">
								<td align="right" colspan="5">
								Opciones de Guardar:
								<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
								<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto
								<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar
								<%=fb.button("save","Guardar",(!viewMode),viewMode,null,null,"onClick=\"javascript:saveMethod(this.value)\"")%>
								<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
								</td>
							</tr>
						</table>
						<%

				%>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
					</td>
				</tr>
			</table></td>
	</tr>
</table>
</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode  	= request.getParameter("errCode");
	String errMsg   	= request.getParameter("errMsg");
	pacId           	=  request.getParameter("pacId");
	noAdmision      	=  request.getParameter("noAdmision");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_devolucion_paciente.jsp?fp='"+fp+"&fg="+fg))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_devolucion_paciente.jsp?fp='"+fp+"&fg="+fg)%>';

<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/list_devolucion_paciente.jsp?fp=<%=fp%>&fg=<%=fg%>';
<%
	}

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
	 setTimeout('closeW()',500);
	// window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}
function closeW()
{
	window.location = '<%=request.getContextPath()%>/inventario/print_devolucion_paciente.jsp?id=<%=anio%><%=id%>';
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?type=3&idDev=<%=anio%><%=id%>&mode=add&fp=<%=fp%>&fg=<%=fg%>';
}
function editMode()
{
<%if(fg.trim().equals("DM")){%>
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&type=2&id=<%=id%>&anio<%=anio%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&fg=<%=fg%>';
	<%}else if(fg.trim().equals("DMA")){%>
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&type=2&id=<%=id%>&anio<%=anio%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&fg=<%=fg%>';
	<%}%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

