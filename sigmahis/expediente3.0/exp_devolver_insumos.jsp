<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DevolucionInsumo"%>
<%@ page import="issi.expediente.DetalleDevolucion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="devInsumos" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="DIMgr" scope="page" class="issi.expediente.DevolucionInsumoMgr" />

<%
/**
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
DIMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cda = request.getParameter("cda");
String cds = request.getParameter("cds");
String cdsDesc = "CUARTO DE URGENCIA"; //request.getParameter("cdsdesc");
boolean op =true, dev = true;

int nDev = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = cDateTime.substring(6,10);

if (request.getMethod().equalsIgnoreCase("GET")) {
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	String secuenciaCorte = null;
	if(cda != null && !cda.trim().equals("")) {
		sbSql.append("select max(secuencia) as secuenciaCorte from tbl_adm_admision where pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and adm_root = ");
		sbSql.append(noAdmision);
		sbSql.append(" and estado in ('A','E')");
		cdo = SQLMgr.getData(sbSql.toString());
		if (cdo != null) secuenciaCorte = cdo.getColValue("secuenciaCorte");
		if (secuenciaCorte == null || secuenciaCorte.trim().equals("")) secuenciaCorte = noAdmision;

		sbSql = new StringBuffer();
		sbSql.append("select dev.renglon, nvl(dev.cantidad_uso,0) as cantidad_uso, dev.cod_familia, dev.cod_clase, dev.cod_articulo, dev.cod_uso, dev.tipo, decode(dev.tipo,'I',nvl(dev.cantidad,0),'U',nvl(dev.cantidad_uso,0)) as cantidad, dev.precio, dev.costo, dev.estado, dev.anio as anioDev, dev.dev as noDev, dev.articulo_desc, nvl(dev.devolver,0) as devolver, nvl(dev.devolver_todo,'N') as devolverTodo, dev.usuario_creacion, dev.fecha_creacion, nvl((select  sum(decode(fdt.tipo_transaccion,'D',(cantidad),0)) from tbl_fac_detalle_transaccion fdt where pac_id = dev.pac_id and fac_secuencia = dev.secuencia and fecha_cargo = dev.fecha_cargo and decode(dev.tipo,'I',fdt.inv_articulo,fdt.cod_uso) = decode(dev.tipo,'I',dev.cod_articulo,dev.cod_uso) and fdt.inv_almacen = td.codigo_almacen and fdt.compania = dev.compania and fdt.centro_servicio = td.centro_servicio),0) as devuelto, nvl(dev.devuelto,0) as dev_devuelto, nvl(dev.transito,0) as transito, nvl(dev.cantidad2,0) as cantidad2, dev.pac_id, decode(dev.tipo,'I',nvl((select sum(b.cantidad) from tbl_inv_detalle_paciente b, tbl_inv_devolucion_pac a where a.pac_id = dev.pac_id and a.adm_secuencia = dev.secuencia and a.compania = dev.compania and b.cod_articulo = dev.cod_articulo and trunc(b.fecha_cargo) = trunc(dev.fecha_cargo) and b.dev_stdev = dev.dev and b.anio_stdev = dev.anio and a.estado = 'T' and a.anio = b.anio_devolucion and a.num_devolucion = b.num_devolucion and a.compania = b.compania),0),'U',nvl((select sum(b.cantidad_uso) from tbl_sal_cargos_det_usos b, tbl_sal_cargos_usos a where a.pac_id = dev.pac_id and a.adm_secuencia = dev.secuencia and a.compania = dev.compania and b.cod_uso = dev.cod_uso and trunc(b.fecha_cargo) = trunc(dev.fecha_cargo) and a.estado = 'P' and a.anio = b.anio and a.secuencia = b.secuencia_uso and a.compania = b.compania),0)) as en_transito, to_char(dev.fecha_cargo,'dd/mm/yyyy') as fecha_cargo");
		sbSql.append(" from tbl_sal_transacc_det_dev dev, tbl_sal_transacc_dev td");
		sbSql.append(" where dev.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and dev.estado = 'P' and dev.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and dev.secuencia = ");
		sbSql.append(secuenciaCorte);
		sbSql.append(" and td.compania = dev.compania and td.anio = dev.anio and td.dev = dev.dev and td.codigo_almacen = ");
		sbSql.append(cda);
		sbSql.append(" and td.centro_servicio = ");
		sbSql.append(cds);
		sbSql.append(" order by dev.tipo, dev.fecha_creacion desc");
		al = SQLMgr.getDataList(sbSql.toString());
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - Devolver Insumos - '+document.title;
function validar(obj,k){var cant = parseInt(eval('document.form0.cant_solicitada'+k).value);var devolver = parseInt(eval('document.form0.devolver'+k).value);var trans = parseInt(eval('document.form0.transito'+k).value);var dev = parseInt(eval('document.form0.devuelto'+k).value);var resp = devolver + trans + dev;var resp1 = trans + dev;if(cant<resp){alert(' Verifique cantidad a devolver');document.getElementById("devolver"+k).value='';obj.focus();}}
function isChecked(k){if (eval('document.form0.check'+k).checked == true){var cant = parseInt(eval('document.form0.cant_solicitada'+k).value);var resp1 = parseInt(eval('document.form0.transito'+k).value) + parseInt(eval('document.form0.devuelto'+k).value);if(cant > resp1)eval('document.form0.devolver'+k).value = cant-resp1;}else eval('document.form0.devolver'+k).value = '';}
function doAction(){<%if(cda == null || cda.trim().equals("")){%>alert('No Existe Almacen Seleccionado');<%}%>}
function MsgAlert(){alert('No existen insumos para devolver');}
function checkArticulos(){var size = document.form0.devSize.value;var x=0,count = 0;var devItemI=0,devItemU=0;for(i=0;i<size;i++){var cantidad  = eval('document.form0.devolver'+i).value;if (isNaN(cantidad) || (cantidad == '')|| (cantidad == '0')){x++;}else{if(eval('document.form0.tipo'+i).value=='I')devItemI++;else if(eval('document.form0.tipo'+i).value=='U')devItemU++;}}if(x==size){alert('No Hay Insumos seleccionados para devolver');return false;}else if(devItemI>0&&devItemU>0){alert('Por favor devolver insumos del mismo tipo (Artículos o Usos)!');return false;}else{count =  getDBData('<%=request.getContextPath()%>','count(*) count','tbl_adm_beneficios_x_admision ',' pac_id=<%=pacId%> and admision=<%=noAdmision%> and  prioridad = 1 and estado =\'A\' ','');if(count >1){alert('El paciente tiene más de un Beneficio con Prioridad 1 activo.   Verifique!!!');return  false;}else return true;}}
function imprimir(fg,fp){var admision = document.form0.admision.value;abrir_ventana('../expediente/print_exp_seccion_29.jsp?fp=SEC&pacId=<%=pacId%>&noAdmision='+admision+'&seccion=<%=seccion%>&desc=<%=desc%>&tipoTrx='+fg+'&fg='+fp);}
function doSub(action){document.form0.baction.value=action;document.form0.submit();}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()" >
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1">
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				 <%=fb.hidden("dob","")%>
				 <%=fb.hidden("codPac","")%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("secuenciaCorte",secuenciaCorte)%>
				 <%=fb.hidden("devSize",""+al.size())%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%=fb.hidden("usuario_creac",UserDet.getUserName())%>
				 <%=fb.hidden("fecha_creac",cDateTime)%>
				 <%=fb.hidden("usuario_modific",UserDet.getUserName())%>
				 <%=fb.hidden("fecha_modific",cDateTime)%>
				 <%=fb.hidden("estado","T")%>
				 <%=fb.hidden("codigoAlmacen",cda)%>
				 <%=fb.hidden("centroServicio",cds)%>
				 <%=fb.hidden("CdsDesc",cdsDesc)%>
				 <%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
				 <%=fb.hidden("anio",anio)%>
				 <%=fb.hidden("desc",desc)%>

					 <tr class="TextRow01">
					 <td colspan="12">&nbsp;</td>
					 </tr>
					 <tr class="TextRow02" >
						<td colspan="12"><cellbytelabel id="2">Admisiones (Solo Para reporte)</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"select secuencia from tbl_adm_admision where pac_id="+pacId+" and adm_root="+noAdmision,"admision",secuenciaCorte,false,false,0,"Text10",null,null,"","")%></td>
					</tr>
					<tr class="TextRow01">
					 <td colspan="6">
					 <cellbytelabel id="1">Centro</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"SELECT distinct a.centro_servicio, b.descripcion||' - '||a.centro_servicio, a.centro_servicio FROM tbl_sal_transacc_dev a, tbl_cds_centro_servicio b where a.centro_servicio=b.codigo and a.secuencia="+((secuenciaCorte != null)?secuenciaCorte:noAdmision)+" and a.pac_id="+pacId+" and a.compania=b.compania_unorg and a.compania="+(String) session.getAttribute("_companyId")+"  ORDER  BY 1","centro",cds,false,(viewMode),0,"Text10",null,"onChange=\"javascript:doSub('Ir')\"")%>
					 <cellbytelabel id="1">Almacen</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"SELECT distinct a.almacen, b.descripcion||' - '||a.almacen, a.almacen FROM tbl_sec_cds_almacen a,tbl_inv_almacen b where a.almacen=b.codigo_almacen  and a.cds = "+cds+" and b.compania="+(String) session.getAttribute("_companyId")+"  ORDER  BY 1","CodigoAlmacen",cda,false,(viewMode),0,"Text10",null,null,"","")%>
					 <%=fb.submit("almacen","Ir",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					 </td>
					 <td colspan="3" align="right"><a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir(Insumos)</cellbytelabel> ]</a></td>
					 <td colspan="3" align="right"><a href="javascript:imprimir('D','USOS')" class="Link00">[ <cellbytelabel id="1">Imprimir(Usos)</cellbytelabel> ]</a></td>
					</tr>

					<tr class="TextHeader" align="center">
							<td width="8%"><cellbytelabel id="2">C&oacute;digo de uso</cellbytelabel></td>
							<td width="8%"><cellbytelabel id="3">Familia</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="4">Clase</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="5">&Aacute;rticulo</cellbytelabel></td>
							<td width="28%"><cellbytelabel id="6">Descripci&oacute;n del Insumo</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="6">F. Cargo</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="7">Cantidad Uso</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="8">Solicitada</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="9">Devuelto</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="10">Transito</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="11">Devolver</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="12">S/N</cellbytelabel></td>

					</tr>
					<%
							boolean _dev = false;
							for (int i=0; i<al.size(); i++)
							{
								cdo = (CommonDataObject) al.get(i);
								String color = "TextRow01";
									if (i % 2 == 0) color = "TextRow02";

									op = (boolean)(Integer.parseInt(cdo.getColValue("en_transito"))+Integer.parseInt(cdo.getColValue("devuelto"))>= Integer.parseInt(cdo.getColValue("cantidad2")));

					%>
					<%=fb.hidden("descripcion"+i,cdo.getColValue("articulo_desc"))%>
					<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
					<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
					<%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
					<%=fb.hidden("noDev"+i,cdo.getColValue("noDev"))%>
					<%=fb.hidden("anioDev"+i,cdo.getColValue("anioDev"))%>
					<%=fb.hidden("fecha_cargo"+i,cdo.getColValue("fecha_cargo"))%>
					<tr class="<%=color%>" align="center">
						<td><%=fb.intBox("cod_uso"+i,cdo.getColValue("cod_uso"),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("familia"+i,cdo.getColValue("cod_familia"),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("clase"+i,cdo.getColValue("cod_clase"),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("articulo"+i,cdo.getColValue("cod_articulo"),false,viewMode,true,5,"Text10",null,null)%></td>
						<td align="left" class="Text10"><%=cdo.getColValue("articulo_desc")%></td>
						<td align="center"><%=cdo.getColValue("fecha_cargo")%></td>
						<td><%=fb.intBox("cant_uso"+i,cdo.getColValue("cantidad_uso"),false,viewMode,true,5,10,null,null,"")%></td>
						<td><%=fb.intBox("cant_solicitada"+i,cdo.getColValue("cantidad2"),false,viewMode,true,5,10,"Text10",null,null)%></td>
						<td><%=fb.intBox("devuelto"+i,cdo.getColValue("devuelto"),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("transito"+i,cdo.getColValue("en_transito"),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("devolver"+i,"",false,(viewMode ||(op)),false,5,8,null,null,"onFocus=\"this.select();\" onChange=\"javascript:validar(this,'"+i+"')\"","Cantidad a Devolver",false," tabindex=\""+(i+1)+"\"")%></td>
						<td><%=fb.checkbox("check"+i,"S",(cdo.getColValue("devolverTodo").equalsIgnoreCase("S")),(viewMode || op),null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>


					</tr>
		<%
		}
		fb.appendJsValidation("\n\tif (!checkArticulos()) error++;\n");
		fb.appendJsValidation("if(error>0)doAction();");
		%>
					<tr class="TextRow02" >
						<td colspan="12" align="right">
				<cellbytelabel id="13">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="14">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="15">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
						</td>
					</tr>
					<%=fb.formEnd(true)%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = 0;
	String centro=request.getParameter("centro");
	String wh = "";
	if (baction.equalsIgnoreCase("Ir")){
		if(!centro.trim().equals(request.getParameter("centroServicio")))wh="";
		else wh =request.getParameter("CodigoAlmacen");
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&modeSec="+modeSec+"&mode="+mode+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&cds="+centro+"&cda="+wh);
		return;
	}
	if (request.getParameter("devSize")!= null) size = Integer.parseInt(request.getParameter("devSize"));

	al.clear();
	devInsumos.clear();

	DevolucionInsumo devI = new DevolucionInsumo();
	devI.setCompania(request.getParameter("compania"));
	devI.setAnio(request.getParameter("anio"));
	devI.setNumDevolucion("0");
	devI.setFecha(cDateTime);
	devI.setFechaNacimiento(request.getParameter("dob"));
	devI.setPaciente(request.getParameter("codPac"));
	devI.setAdmSecuencia(request.getParameter("secuenciaCorte"));
	devI.setPacId(request.getParameter("pacId"));
	devI.setMonto("");
	devI.setSubtotal("");
	devI.setItbm("");
	devI.setCodigoAlmacen(request.getParameter("codigoAlmacen"));
	devI.setUsuarioCreacion(request.getParameter("usuario_creac"));
	devI.setFechaCreacion(request.getParameter("fecha_creac"));
	devI.setUsuarioModif((String) session.getAttribute("_userName"));
	devI.setFechaModif(cDateTime);
	devI.setEstado(request.getParameter("estado"));
	devI.setSala(request.getParameter("CdsDesc"));
	devI.setSalaCod(request.getParameter("centroServicio"));
	cds = request.getParameter("centroServicio");
	cda=request.getParameter("codigoAlmacen");
	int devItemI = 0;
	int devItemU = 0;
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("devolver"+i) != null &&!request.getParameter("devolver"+i).trim().equals("") && !request.getParameter("devolver"+i).equals("0") )
		{
			DetalleDevolucion detDev  = new DetalleDevolucion();

			if(request.getParameter("tipo"+i)!= null && !request.getParameter("tipo"+i).trim().equals("") && request.getParameter("tipo"+i).trim().equals("I")) devItemI++;
			else if(request.getParameter("tipo"+i)!= null && !request.getParameter("tipo"+i).trim().equals("") && request.getParameter("tipo"+i).trim().equals("U")) devItemU++;

			detDev.setCompania(request.getParameter("compania"));
			detDev.setAnioDevolucion(request.getParameter("anio"));
			detDev.setNumDevolucion("0");
			detDev.setCodFamilia(request.getParameter("familia"+i));
			detDev.setCodClase(request.getParameter("clase"+i));
			detDev.setCodArticulo(request.getParameter("articulo"+i));
			detDev.setRenglon("0");
			detDev.setCantidad(request.getParameter("devolver"+i));
			detDev.setPrecio(request.getParameter("precio"+i));
			detDev.setCosto(request.getParameter("costo"+i));
			detDev.setCantidadSol(request.getParameter("cant_solicitada"+i));
			detDev.setAnioStDev(request.getParameter("anioDev"+i));
			detDev.setDevStDev(request.getParameter("noDev"+i));
			detDev.setDevTodo(request.getParameter("check"+i));
			detDev.setTipo(request.getParameter("tipo"+i));
			detDev.setCodUso(request.getParameter("cod_uso"+i));
			detDev.setDescripcion(request.getParameter("descripcion"+i));
			detDev.setCantidadUso(request.getParameter("cant_uso"+i));
			detDev.setFechaCargo(request.getParameter("fecha_cargo"+i));


			al.add(detDev);
			devI.addDetalleDevolucion(detDev);
		}
	}//end For
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0) throw new Exception("No hay insumos seleccionados para devolver !!!!");
		else if (devItemI > 0 && devItemU > 0) throw new Exception("Por favor devolver insumos del mismo tipo (Artículos o Usos)!");
		else
		{
			if (devItemI > 0) devI.setTipo("I");
			else if (devItemU > 0) devI.setTipo("U");

			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			DIMgr.add(devI);
			ConMgr.clearAppCtx(null);
		}
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (DIMgr.getErrCode().equals("1"))
{
%>
	alert('<%=DIMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(DIMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&cda=<%=cda%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>