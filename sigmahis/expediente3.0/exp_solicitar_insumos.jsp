<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.SolicitudInsumos"%>
<%@ page import="issi.expediente.DetalleSolicitud"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="insumos" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vInsumos" scope="session" class="java.util.Vector" />
<jsp:useBean id="InsumosMgr" scope="page" class="issi.expediente.SolicitudInsumoMgr" />
<jsp:useBean id="sInsumo" scope="session" class="issi.expediente.SolicitudInsumos" />
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
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
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

String change = request.getParameter("change");
String observacion = request.getParameter("observacion");
String cda = request.getParameter("cda");
String cds = request.getParameter("cds");
String type = request.getParameter("type");

int rowCount = 0;
int  insumoLastLineNo =0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = cDateTime.substring(6,10);
String key = "";

if (request.getParameter("insumoLastLineNo") != null) insumoLastLineNo = Integer.parseInt(request.getParameter("insumoLastLineNo"));
String secuenciaCorte = request.getParameter("secuenciaCorte");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	

						if(change == null)
						{
							insumos.clear();
							vInsumos.clear();
							//System.out.println("insumos null");
							sInsumo = new SolicitudInsumos();
							session.setAttribute("sInsumo",sInsumo);
							sInsumo.setEstado("P");
							sInsumo.setAnio(anio);
							sInsumo.setCodigoAlmacen(cda);
							modeSec = "add";
						
						}
			
	cdo = SQLMgr.getData("select max(secuencia) as secuenciaCorte,nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CHECK_DISP'),'S') as valida_dsp from tbl_adm_admision where pac_id="+pacId+" and adm_root="+noAdmision+" and estado in ('A','E') ");
	if (cdo != null) secuenciaCorte = cdo.getColValue("secuenciaCorte");
	if (secuenciaCorte == null || secuenciaCorte.trim().equals("")) secuenciaCorte = noAdmision;


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE '+document.title;
function showListInsumo(){var cds =eval('document.form0.CentroServicio').value; abrir_ventana1('../common/check_insumos.jsp?fp=listInsumo&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&pacId=<%=pacId%>&modeSec=<%=modeSec%>&mode=<%=mode%>&insumoLastLineNo=<%=insumoLastLineNo%>&cds='+cds+'&cda=<%=cda%>&desc=<%=desc%>&secuenciaCorte=<%=secuenciaCorte%>&saleItem=S');}
function validar(obj,k){var afecta_inv =  eval('document.form0.afecta_inv'+k).value;if(afecta_inv =='Y'){<%if(cdo.getColValue("valida_dsp").trim().equals("S")){%>var cant =  parseInt(eval('document.form0.cant_uso'+k).value);var disponible = parseInt(eval('document.form0.cantidad'+k).value);var tipoart = eval('document.form0.tipo'+k).value;if(cant > 0){ if(disponible < cant && tipoart=="I"){ alert('No hay cantidad disponible!');document.getElementById("cant_uso"+k).value="";obj.focus();}}else	{ alert('Cantidad inválida'); document.getElementById("cant_uso"+k).value="";}<%}%>}
}
function doAction(){var cda = document.form0.codigoAlmacen.value;if(cda==''){ alert('No se puede general la Solicigud, no se ha encontrado el cÓdigo de almacén..., VERIFIQUE!');}else{<%if(type!=null && type.equals("1")){%>showListInsumo();<%}%>}}
function checkArticulos(){var size = document.form0.insumoSize.value;var x=0,count = 0;var cda = document.form0.codigoAlmacen.value;if(cda=='' || cda == null){alert('El Centro de Servicio No tiene Almacen Asigando para las Solicitudes de Material e Insumos.....');return false;}else{if(size==0){alert('No Hay Insumos seleccionados');return false;}else{count =  getDBData('<%=request.getContextPath()%>','count(*) count','tbl_adm_beneficios_x_admision ',' pac_id=<%=pacId%> and admision=<%=noAdmision%> and  prioridad = 1 and estado =\'A\' ','');if(count >1){alert('El paciente tiene más de un Beneficio con Prioridad 1 activo   Verifique!!!');return  false;}else return true;}}}
function imprimir(fg){var admision = document.form0.admision.value;abrir_ventana('../expediente/print_exp_seccion_28.jsp?fp=SEC&pacId=<%=pacId%>&noAdmision='+admision+'&seccion=<%=seccion%>&desc=<%=desc%>&fg='+fg);}
function validarWh(obj){<%if(insumos.size() > 0 ){%>alert('No Puede Cambiar de almacen, Existe articulos Seleccionados!!!');<%}%>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()" >
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1"    >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				 <%=fb.hidden("dob","")%>
				 <%=fb.hidden("codPac","")%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("insumoSize",""+insumos.size())%>
				 <%=fb.hidden("solicitudNo","0")%>
				 <%=fb.hidden("fechaDoc",cDateTime)%>
				 <%=fb.hidden("anio",anio)%>
				 <%=fb.hidden("insumoLastLineNo",""+insumoLastLineNo)%>
				 <%=fb.hidden("usuario_creac",(String) session.getAttribute("_userName"))%>
				 <%=fb.hidden("fecha_creac",cDateTime)%>
				 <%=fb.hidden("usuario_modific",(String) session.getAttribute("_userName"))%>
				 <%=fb.hidden("fecha_modific",cDateTime)%>
				 <%=fb.hidden("estadoSol","T")%>
				 <%//=fb.hidden("CodigoAlmacen",cda)%>
				 <%=fb.hidden("CentroServicio",cds)%>
				 <%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
				  <%=fb.hidden("desc",desc)%>
				  <%=fb.hidden("secuenciaCorte",secuenciaCorte)%>
				  

					<tr class="TextRow02">
			<td colspan="5" align="right"><a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir(Insumos)</cellbytelabel> ]</a></td>
			<td colspan="3" align="right"><a href="javascript:imprimir('USOS')" class="Link00">[ <cellbytelabel id="1">Imprimir(Usos)</cellbytelabel> ]</a></td>
		</tr>
					<tr class="TextRow02" >
						<td colspan="8"><cellbytelabel id="2">Admisiones (Solo Para reporte)</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"select secuencia from tbl_adm_admision where pac_id="+pacId+" and adm_root="+noAdmision,"admision",secuenciaCorte,false,false,0,"Text10",null,null,"","")%></td>
					</tr>
					<tr class="TextRow02" >
						<td colspan="8"><cellbytelabel id="3">Almacen</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"SELECT distinct a.almacen, b.descripcion||' - '||a.almacen, a.almacen FROM tbl_sec_cds_almacen a,tbl_inv_almacen b where a.almacen=b.codigo_almacen and b.compania="+(String) session.getAttribute("_companyId")+" and a.cds = "+cds+" ORDER  BY 1","codigoAlmacen",sInsumo.getCodigoAlmacen(),false,(viewMode),0,"Text10",null,"onFocus=\"javascript:validarWh(this)\"")%></td>
					</tr>
					<tr class="TextRow02" >
						<td colspan="5">
							<cellbytelabel id="4">Observaci&oacute;n</cellbytelabel>:
						<%=fb.textarea("observacion",sInsumo.getObservaciones(),false,viewMode,false,60,4,2000,"","width:100%","")%></td>

						 <td colspan="3"><cellbytelabel id="5">Estado</cellbytelabel><%=fb.select("estado","P=PENDIENTE","P",false,viewMode,1,"Text10",null,null)%></td>

					</tr>
					 <tr class="TextRow01" >
					 <td colspan="8">&nbsp;</td>
					 </tr>
					<tr class="TextHeader" align="center" >
							<td width="13%"><cellbytelabel id="6">C&oacute;digo de U</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="7">Familia</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="8">Clase</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="9">&Aacute;rticulo</cellbytelabel></td>
							<td width="38%"><cellbytelabel id="10">Descripci&oacute;n del Insumo</cellbytelabel></td>
							<td width="14%"><cellbytelabel id="11">Disponible</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="12">Cantidad</cellbytelabel></td>
							<td width="5%"><%//=fb.button("addInsumo","+",true,viewMode,null,null,"onClick=\"javascript:showListInsumo()\"","Agregar insumos")%>
							<%=fb.submit("addInsumo","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar insumos")%></td>

					</tr>
					 <tr class="TextRow02" >
					 <td colspan="8">&nbsp;</td>
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
								<%=fb.hidden("afecta_inv"+i,ds.getAfectaInv())%>
					<tr class="<%=color%>" align="center">
							<td><%=fb.intBox("cod_uso"+i,ds.getCodUso(),false,viewMode,true,5,"",null,null)%>	</td>
							<td><%=fb.intBox("familia"+i,ds.getArtFamilia(),false,viewMode,true,5,"",null,null)%>	</td>
							<td><%=fb.intBox("clase"+i,ds.getArtClase(),false,viewMode,true,5,"",null,null)%>	</td>
							<td><%=fb.intBox("articulo"+i,ds.getCodArticulo(),false,viewMode,true,5,"",null,null)%>	</td>
							<td align="left" class="Text10"><%=ds.getDescripcion()%>	</td>
							<td><%=fb.intBox("cantidad"+i,ds.getCantidad(),false,viewMode,true,5,"",null,null)%>	</td>
							<td><%=fb.intBox("cant_uso"+i,ds.getCantidadUso(),true,viewMode,false,3,null,null,"onBlur=\"javascript:validar(this,'"+i+"')\"")%></td>
<td align="center"><%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td> 

					</tr>
	<%
		}
		fb.appendJsValidation("\n\tif (!checkArticulos()) error++;\n");
		fb.appendJsValidation("if(error>0)doAction();");
	%>
					<tr class="TextRow02" >
						<td colspan="8" align="right">
				<cellbytelabel id="13">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto-->
				<%=fb.radio("saveOption","N",true,viewMode,false)%><cellbytelabel id="14">Crear Otro</cellbytelabel>
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
	//SolicitudInsumos solInsumo = new SolicitudInsumos();
	//System.out.println("cda == "+request.getParameter("CodigoAlmacen"));
	//System.out.println("cds == "+request.getParameter("CentroServicio"));
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
	sInsumo.setCentroServicio(request.getParameter("CentroServicio"));
	sInsumo.setCompania(request.getParameter("compania"));
	sInsumo.setFechaDocumento(request.getParameter("fechaDoc"));
	sInsumo.setObservaciones(request.getParameter("observacion"));
	sInsumo.setSolicitudNo(request.getParameter("solicitudNo"));
	sInsumo.setSecuenciaUso("0");
	int size = 0;

	if (request.getParameter("insumoSize")!= null)
	size = Integer.parseInt(request.getParameter("insumoSize"));
	al.clear();
	insumos.clear();
	sInsumo.getDetalleSolicitud().clear();
	for (int i=1; i<=size; i++)
	{
		DetalleSolicitud detal = new DetalleSolicitud();

		if(request.getParameter("tipo"+i).equals("I"))
			op="01";
		if(request.getParameter("tipo"+i).equals("U"))
			op1="02";

		detal.setCompania(request.getParameter("compania"));
		detal.setRenglon(request.getParameter("renglon"+i));
		detal.setArtFamilia(request.getParameter("familia"+i));
		detal.setArtClase(request.getParameter("clase"+i));
		detal.setCodArticulo(request.getParameter("articulo"+i));
		detal.setCodUso(request.getParameter("cod_uso"+i));
		detal.setTipo(request.getParameter("tipo"+i));
		detal.setCantidad(request.getParameter("cantidad"+i));
		detal.setCantidadUso(request.getParameter("cant_uso"+i));
		detal.setPrecio(request.getParameter("precio"+i));
		detal.setCosto(request.getParameter("costo"+i));
		detal.setEstadoRenglon(request.getParameter("estado"));
		detal.setAnio(request.getParameter("anio"));
		detal.setDescripcion(request.getParameter("descripcion"+i));
		detal.setCargoTardio("N");
		detal.setAfectaInv(request.getParameter("afecta_inv"+i));
		key=request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = key;
			if(detal.getTipo().equals("U"))
				itemRemovedVector = detal.getCodArticulo()+detal.getTipo();
			else
				itemRemovedVector = detal.getCodArticulo()+detal.getArtClase()+detal.getArtFamilia();
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
		//if(((DetalleSolicitud) insumos.get(itemRemoved)).getCodUso().equals("0"))
			//vInsumos.remove(((DetalleSolicitud) insumos.get(itemRemoved)).getCodArticulo());  //,insumos.get(itemRemoved)).getCodClase(),insumos.get(itemRemoved)).getArtFamilia());
		//else
		//vInsumos.remove(((DetalleSolicitud) insumos.get(itemRemoved)).getCodUso());
		//,insumos.get(itemRemoved)).getCodClase(),insumos.get(itemRemoved)).getArtFamilia());

		vInsumos.remove(itemRemovedVector);
		insumos.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&observacion="+request.getParameter("observacion")+"&cds="+request.getParameter("CentroServicio")+"&cda="+request.getParameter("codigoAlmacen")+"&desc="+desc+"&secuenciaCorte="+secuenciaCorte);
		return;
	}
	if (baction.equalsIgnoreCase("+")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&modeSec="+modeSec+"&mode="+mode+"&insumoLastLineNo="+insumoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&observacion="+request.getParameter("observacion")+"&cds="+request.getParameter("CentroServicio")+"&cda="+request.getParameter("codigoAlmacen")+"&desc="+desc+"&secuenciaCorte="+secuenciaCorte);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar") && al.size() != 0)
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
		{
			if (secuenciaCorte == null || secuenciaCorte.trim().equals("")) secuenciaCorte = noAdmision;
			sInsumo.setAdmSecuencia(secuenciaCorte);
			InsumosMgr.add(sInsumo,op,op1);
		}
		ConMgr.clearAppCtx(null);
	}
	else throw new Exception("No hay insumos agregados !!");
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
	session.removeAttribute("sInsumo");
	session.removeAttribute("insumo");
	session.removeAttribute("vInsumo");

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
} else throw new Exception(InsumosMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&observacion=<%=observacion%>&cds=<%=request.getParameter("CentroServicio")%>&cda=<%=request.getParameter("codigoAlmacen")%>&desc=<%=desc%>&secuenciaCorte=<%=secuenciaCorte%>';
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