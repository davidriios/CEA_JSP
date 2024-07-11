<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.SolicitudInsumos"%>
<%@ page import="issi.expediente.DetalleSolicitud"%>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="insumos" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vInsumos" scope="session" class="java.util.Vector" />
<jsp:useBean id="InsumosMgr" scope="page" class="issi.expediente.SolicitudInsumoMgr" />
<jsp:useBean id="sInsumo" scope="session" class="issi.expediente.SolicitudInsumos"/>
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
InsumosMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
//SolicitudInsumos sInsumo = new SolicitudInsumos();

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || (noAdmision == null ||noAdmision.trim().equals("") )) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (codCita == null || fechaCita == null) throw new Exception("Los datos de la citaa no son válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String observacion = request.getParameter("observacion");
String cds = request.getParameter("cds");
String type = request.getParameter("type");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");

int rowCount = 0;
int  insumoLastLineNo =0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = cDateTime.substring(6,10);
String key = "";
String cda = ResourceBundle.getBundle("issi").getString("almacenSOP");
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change == null)
	{
		insumos.clear();
		vInsumos.clear();
		sInsumo = new SolicitudInsumos();
		session.setAttribute("sInsumo",sInsumo);
		sInsumo.setEstado("P");
		sInsumo.setAnio(anio);
		sInsumo.setCodigoAlmacen(cda);
		mode = "add";
		
		sql="select  nvl(count(cu.secuencia),0)secuencia from tbl_sal_cargos_usos cu where compania = "+(String) session.getAttribute("_companyId")+" and cu.cod_cita = "+codCita+" and trunc(cu.fecha_cita) =to_date('"+fechaCita+"','dd/mm/yyyy') and cu.estado = 'A' and cu.tipo = 'C' and cu.sop = 'S'"; 
		cdo = SQLMgr.getData(sql);
			if(cdo!=null && cdo.getColValue("secuencia")!=null){
				rowCount = Integer.parseInt(cdo.getColValue("secuencia"));
			}
			if(rowCount>0)throw new Exception("La cita seleccionada ya tiene los USOS registrados!"); 
		
		  sql = "select 'U' tipo,0 renglon,a.cod_uso codUso,avg(nvl(a.cantidad,0))cantidadUso,a.tipo_uso,b.descripcion /*||decode(a.tipo_uso,'A',' / AUTOMATICO','  / MANUAL')*/ as descripcion,nvl(b.precio_venta,0) precio,0 costo,b.tipo_servicio tipoServicio FROM tbl_cds_activo_x_proc a,tbl_sal_uso b,tbl_cdc_cita_procedimiento p WHERE a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.procedimiento =p.procedimiento and p.cod_cita= "+codCita+" and trunc(p.fecha_cita) =to_date('"+fechaCita+"','dd/mm/yyyy') and a.tipo_uso in('M','A') and a.cod_uso = b.codigo and a.cod_compania = b.compania and b.estatus = 'A' group by 'U',0,a.cod_uso ,a.tipo_uso,b.descripcion,nvl(b.precio_venta,0),0,b.tipo_servicio order by a.cod_uso ";
			//al  = SQLMgr.getDataList(sql); 
					
			al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleSolicitud.class);
			insumoLastLineNo = al.size();
				
			for (int i=0; i<al.size(); i++)
			{
					DetalleSolicitud det = (DetalleSolicitud) al.get(i);
				  try {
						
						key = det.getCodUso()+det.getTipo();
						insumos.put(key, det);
						vInsumos.addElement(det.getCodUso()+det.getTipo());
						
					} catch(Exception e) {
						System.out.println("Unable to add item...");
					}
			}
				
				

	}


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE '+document.title;
function showListInsumo(){abrir_ventana1('../common/check_insumos.jsp?fp=usosSop&tipo=U&noAdmision=<%=noAdmision%>&pacId=<%=pacId%>&mode=<%=mode%>&cds=<%=cds%>&cda=<%=cda%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>');}
function doAction()
{
	newHeight();
	<%if(type!=null && type.equals("1")){	%>
		showListInsumo();
	<%}%>
	var codPac= eval('document.paciente.codigoPaciente').value;
	var dob= eval('document.paciente.fechaNacimiento').value;
	document.form0.dob.value=dob;
	document.form0.codPac.value=codPac;
	
}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_28.jsp?fg=USOS&fp=SOP&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>');}
function _doSubmit(valor){
  if (!document.form0.codigoAlmacen.value) {
     alert('Por favor escoge un almacén!');
     return;
  }

  document.form0.baction.value = valor;
  if (confirm('Al ejecutar este proceso se estará creando la Solicitud de Usos y se generaran los CARGOS a la cuenta del paciente.  Está seguro de ejecutarlo?')){document.form0.submit();}else CBMSG.warning('Proceso Cancelado');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()" >
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="GENERAR USOS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr class="TextRow02">
		<td>
	<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="fp" value="<%=fp%>"></jsp:param>
							<jsp:param name="tr" value="<%=fg%>"></jsp:param>
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
						</jsp:include>
		</td>
	</tr>
	<tr>
		<td>
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1"    >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>

				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("seccion",seccion)%>
				<%//fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				<%=fb.hidden("dob","")%>
				<%=fb.hidden("codPac","")%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("insumoSize",""+insumos.size())%>
				 <%=fb.hidden("solicitudNo","0")%>
				 <%=fb.hidden("fechaDoc",cDateTime.substring(0,10))%>
				 <%=fb.hidden("anio",anio)%>
				 <%=fb.hidden("insumoLastLineNo",""+insumoLastLineNo)%>
				 <%=fb.hidden("usuario_creac",(String) session.getAttribute("_userName"))%>
				 <%=fb.hidden("fecha_creac",cDateTime)%>
				 <%=fb.hidden("usuario_modific",(String) session.getAttribute("_userName"))%>
				 <%=fb.hidden("fecha_modific",cDateTime)%>
				 <%=fb.hidden("estadoSol","T")%>
				 <%//=fb.hidden("CodigoAlmacen",cda)%>
				 <%=fb.hidden("centroServicio",cds)%>
				 <%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
				 <%=fb.hidden("desc",desc)%>
				 <%=fb.hidden("fechaCita",fechaCita)%>
				 <%=fb.hidden("codCita",codCita)%>
				  
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel>SOLICITUD DE USOS</cellbytelabel></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right"><!--<a href="javascript:imprimir()" class="Link00">[ Imprimir ]</a>--></td>
		</tr>
		<tr class="TextRow02" >
			<td colspan="4">Almac&eacute;n:<%=fb.select(ConMgr.getConnection(),"SELECT a.almacen, b.descripcion||' - '||a.almacen, a.almacen FROM tbl_sec_cds_almacen a,tbl_inv_almacen b where a.almacen=b.codigo_almacen  and a.cds = "+cds+" and a.almacen ="+cda+" and b.compania = "+(String) session.getAttribute("_companyId")+" ORDER  BY 1","codigoAlmacen",sInsumo.getCodigoAlmacen(),false,(viewMode),0,"Text10",null,null,"","")%>							            </td>
		</tr>
					<tr class="TextRow02" >
						<td colspan="2">
							<cellbytelabel>Observaci&oacute;n</cellbytelabel>:
							<%=fb.textarea("observacion",sInsumo.getObservaciones(),false,viewMode,false,60,4,2000,"","width:100%","")%></td>
						 <td colspan="2">Estado<%=fb.select("estado","P=PENDIENTE","P",false,viewMode,1,"Text10",null,null)%></td>

					</tr>
					<tr class="TextRow01" >
					 <td colspan="4">&nbsp;</td>
					</tr>
					<tr class="TextHeader" align="center" >
							<td width="13%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="38%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="5%"><cellbytelabel>Cantidad</cellbytelabel></td>
							<td width="5%"><%//=fb.button("addInsumo","+",true,viewMode,null,null,"onClick=\"javascript:showListInsumo()\"","Agregar insumos")%>
							<%=fb.submit("addInsumo","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar insumos")%></td>

					</tr>
					<% 	al = CmnMgr.reverseRecords(insumos);
							for (int i=1; i<=insumos.size(); i++)
							{
								key = al.get(i - 1).toString();
								DetalleSolicitud ds = (DetalleSolicitud) insumos.get(key);
								if(ds.getTipo() != null && ds.getTipo().trim().equals("U"))
								key = (String) ds.getCodUso()+ds.getTipo();
								else key = (String) ds.getCodArticulo()+ds.getArtClase()+ds.getArtFamilia();


								String color = "TextRow01";
									if (i % 2 == 0) color = "TextRow02";
					%>
								<%=fb.hidden("key"+i,key)%>
								<%=fb.hidden("remove"+i,"")%>
								<%=fb.hidden("descripcion"+i,ds.getDescripcion())%>
								<%=fb.hidden("tipo"+i,ds.getTipo())%>
								<%=fb.hidden("precio"+i,ds.getPrecio())%>
								<%=fb.hidden("costo"+i,ds.getCosto())%>
								<%=fb.hidden("renglon"+i,ds.getRenglon())%>
							<tr class="<%=color%>" align="center">
							<td><%=fb.intBox("cod_uso"+i,ds.getCodUso(),false,viewMode,true,5,"",null,null)%>	</td>
							<td align="left" class="Text10"><%=ds.getDescripcion()%>	</td>
							<td><%=fb.intBox("cant_uso"+i,ds.getCantidadUso(),true,viewMode,false,3,null,null,"")%></td>
<td align="center"><%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td> 

					</tr>
	<%
		}
		fb.appendJsValidation("if(error>0)doAction();");
	%>
					<tr class="TextRow02" >
						<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","N",true,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%//=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:_doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
//------------------------------- -----------------------------------
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	String itemRemovedVector = "";
	String op = "";
	String op1 = "";
	cda = request.getParameter("codigoAlmacen");
	sInsumo.setPaciente(request.getParameter("codPac"));
	sInsumo.setAdmSecuencia(request.getParameter("noAdmision"));
	sInsumo.setFechaNacimiento(request.getParameter("dob"));
	sInsumo.setPacId(request.getParameter("pacId"));
	sInsumo.setUsuarioCreacion(request.getParameter("usuario_creac"));
	sInsumo.setFechaCreacion(request.getParameter("fecha_creac"));
	sInsumo.setUsuarioModif(request.getParameter("usuario_modific"));
	sInsumo.setFechaModif(request.getParameter("fecha_modific"));
	sInsumo.setAnio(request.getParameter("anio"));
	sInsumo.setEstado(request.getParameter("estado"));
	sInsumo.setCodigoAlmacen(request.getParameter("codigoAlmacen"));
	sInsumo.setCentroServicio(request.getParameter("centroServicio"));
	sInsumo.setCompania(request.getParameter("compania"));
	sInsumo.setFechaDocumento(request.getParameter("fechaDoc"));
	sInsumo.setObservaciones(request.getParameter("observacion"));
	sInsumo.setSolicitudNo(request.getParameter("solicitudNo"));
	sInsumo.setSecuenciaUso("0");
	sInsumo.setSop("S");
	sInsumo.setTipoTransaccion("C");
	sInsumo.setFlag("DCU");
	sInsumo.setFechaCita(fechaCita);
	sInsumo.setCodCita(codCita);
	int size = 0;

	if (request.getParameter("insumoSize")!= null)size =Integer.parseInt(request.getParameter("insumoSize"));
	al.clear();
	insumos.clear();
	sInsumo.getDetalleSolicitud().clear();
	for (int i=1; i<=size; i++)
	{
		DetalleSolicitud detal = new DetalleSolicitud();

		if(request.getParameter("tipo"+i).equals("U"))op1="02";

		detal.setCompania(request.getParameter("compania"));
		detal.setRenglon(request.getParameter("renglon"+i));
		detal.setCodUso(request.getParameter("cod_uso"+i));
		detal.setTipo(request.getParameter("tipo"+i));
		detal.setCantidadUso(request.getParameter("cant_uso"+i));
		detal.setPrecio(request.getParameter("precio"+i));
		detal.setCosto(request.getParameter("costo"+i));
		detal.setEstadoRenglon("A");
		detal.setAnio(request.getParameter("anio"));
		detal.setDescripcion(request.getParameter("descripcion"+i));
		detal.setCargoTardio("N");
		key=request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = key;
			if(detal.getTipo().equals("U"))
				itemRemovedVector = detal.getCodArticulo()+detal.getTipo();
		}
		else
		{
			try
			{
				insumos.put(key,detal);
				al.add(detal);
				sInsumo.addDetalleSolicitud(detal);
			}

			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//end For

	if(!itemRemoved.equals(""))
	{
		vInsumos.remove(itemRemovedVector);
		insumos.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&observacion="+request.getParameter("observacion")+"&cds="+request.getParameter("centroServicio")+"&cda="+request.getParameter("codigoAlmacen")+"&desc="+desc+"&fechaCita="+fechaCita+"&codCita="+codCita);
		return;
	}
	if (baction.equalsIgnoreCase("+")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&observacion="+request.getParameter("observacion")+"&cds="+request.getParameter("centroServicio")+"&cda="+request.getParameter("codigoAlmacen")+"&desc="+desc+"&fechaCita="+fechaCita+"&codCita="+codCita);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar") && al.size() != 0)
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			String secuenciaCorte = null;
			//cdo = SQLMgr.getData("select max(secuencia) as secuenciaCorte from tbl_adm_admision where pac_id="+pacId+" and adm_root="+noAdmision);
			secuenciaCorte = noAdmision;
			sInsumo.setAdmSecuencia(secuenciaCorte);
			InsumosMgr.add(sInsumo,op,op1);
		}
		ConMgr.clearAppCtx(null);
	}
	else throw new Exception("No hay insumos agregados !!");
	session.removeAttribute("sInsumo");
	session.removeAttribute("insumo");
	session.removeAttribute("vInsumo");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (InsumosMgr.getErrCode().equals("1"))
{
%>
	alert('<%=InsumosMgr.getErrMsg()%>');
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
	window.close();
<%
	}
} else throw new Exception(InsumosMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&observacion=<%=observacion%>&cds=<%=request.getParameter("centroServicio")%>&cda=<%=request.getParameter("codigoAlmacen")%>&fg=<%=fg%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?cda=<%=cda%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
