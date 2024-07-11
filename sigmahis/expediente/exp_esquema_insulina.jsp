<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.EsquemaInsulinaMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.io.*"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEsquema" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
<jsp:useBean id="EIMgr" scope="page" class="issi.expediente.EsquemaInsulinaMgr" />
<jsp:useBean id="om" scope="session" class="issi.expediente.OrdenMedica" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
EIMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo =new CommonDataObject();
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String medico = request.getParameter("medico");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (id == null) id = "";
if (id.trim().equals("")) id = "0";
if (from == null) from = "";
if (medico == null) medico = "";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String tipoOrden ="8";
String cds ="";
String tipoSolicitud ="P";
String subTipo ="";
int sLastLineNo =0;
if (request.getParameter("sLastLineNo") != null) sLastLineNo = Integer.parseInt(request.getParameter("sLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo= (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	sql = "select distinct id codigo ,to_char(fecha,'dd/mm/yyyy hh12:mi am') fechaOrden from tbl_sal_esquema_insulina where  pac_id="+pacId+" and admision="+noAdmision+" order by id desc";
		al2 = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);
	if (change == null)
	{
		om = new OrdenMedica();
		session.setAttribute("om",om);
		iEsquema.clear();

		if(!id.trim().equals("0"))
		{

		sql = "select to_char(fecha,'dd/mm/yyyy') fechaOrden,codigo,escala descripcion,valor cantidad,insulina nombre from tbl_sal_esquema_insulina where  pac_id="+pacId+" and admision="+noAdmision+" and id ="+id;
		System.out.println("sql det ===  "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);

		sLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			try
			{
				iEsquema.put(key, al.get(i-1));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		if (!viewMode) modeSec = "edit";
		}
		if (al.size() == 0)
		{
				if (!viewMode) modeSec = "add";

				DetalleOrdenMed detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("    < 150 ");
				detOrd.setCantidad("0 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("151 - 200 ");
				detOrd.setCantidad("2 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("201 - 250 ");
				detOrd.setCantidad("4 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("251 - 300 ");
				detOrd.setCantidad("8 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

				detOrd  = new DetalleOrdenMed();
				//detOrd.setCodigo(id);
				detOrd.setDescripcion("   > 300 ");
				detOrd.setCantidad("10 UNIDADES");

				sLastLineNo++;
				if (sLastLineNo < 10) key = "00" + sLastLineNo;
				else if (sLastLineNo < 100) key = "0" + sLastLineNo;
				else key = "" + sLastLineNo;
				detOrd.setKey(""+key);

				try
				{
					iEsquema.put(key, detOrd);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		}
	}//change=null

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Esquema de Insuluna - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();document.form0.medico.value =
<%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%> ;checkViewMode();setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function setEvaluacion(code){window.location = '../expediente/exp_esquema_insulina.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id='+code;}
function add(){window.location = '../expediente/exp_esquema_insulina.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&from=<%=from%>&medico=<%=medico%>';}
function imprimirOrden(){abrir_ventana1('../expediente/print_exp_seccion_79.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipoOrden=8&id=<%=id%>&desc=<%=desc%>');}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr class="TextRow01">
					<td>
					<div id="main" width="100%" class="exp h100">
					<div id="detalle" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
								 <%=fb.hidden("desc",desc)%>
								 <%=fb.hidden("from",from)%>
								 <%=fb.hidden("medico",medico)%>
				 <td colspan="5" align="right">&nbsp;</td>
		</tr>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Esquema de Insuluna</cellbytelabel></td>
							<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Esquema</cellbytelabel> ]</a><%}%>&nbsp;<a href="javascript:imprimirOrden()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ]</a>
							</td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="5">C&oacute;digo</cellbytelabel></td>
							<td  width="40%"><cellbytelabel id="5">Fecha</cellbytelabel></td>
							<td  width="40%">&nbsp;</td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	DetalleOrdenMed det1 = (DetalleOrdenMed) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,det1.getCodigo())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=det1.getCodigo()%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=det1.getCodigo()%></td>
				<td><%=det1.getFechaOrden()%></td>
				<td><%//=det1.getNombre()%></td>
		</tr>
<%}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>

	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
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
			<%=fb.hidden("esSize",""+iEsquema.size())%>
			<%=fb.hidden("sLastLineNo",""+sLastLineNo)%>
			<%=fb.hidden("medico", medico)%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("formaSolicitud","")%>

			<tr class="TextRow02">
				<td colspan="3">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
			<td colspan="3"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,50,"","","")%>
				<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
			</td>
		</tr>
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iEsquema);
for (int i=1; i<=iEsquema.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iEsquema.get(key);

if(i==1)
{%>

		<tr class="TextRow01">
				 <td colspan="3">Tipo insulina&nbsp;<%=fb.textBox("insulina",detOrd.getNombre(),true,false,(viewMode||isReadOnly),50,100)%> </td>
			</tr>

<tr class="TextHeader" align="center">
				 <td width="35%"><cellbytelabel id="6">Escala</cellbytelabel></td>
				 <td width="60%"><cellbytelabel id="7">Valor</cellbytelabel></td>
				 <td width="5%" align="center"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Orden")%></td>
			</tr>

<%
}


	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>
			<%//=fb.hidden("fecha"+i,detOrd.getFechaOrden())%>
			<%//=fb.hidden("codigo"+i,detOrd.getCodigo())%>

			<tr class="<%=color%>" align="center">
				<td width="35%"><%=fb.textBox("nombre"+i,detOrd.getDescripcion(),false,false,(viewMode||isReadOnly),20,30)%></td>
				<td width="60%"><%=fb.textBox("cantidad"+i,detOrd.getCantidad(),false,false,(viewMode||isReadOnly),20,30)%></td>

				<td width="5%"><%=fb.submit("rem"+i,"X",false,(viewMode||isReadOnly),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>
<%
}
fb.appendJsValidation("if(error>0)newHeight();");
%>
			<tr class="TextRow02" >
				<td colspan="4" align="right">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="9">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="10">Cerrar</cellbytelabel>
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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int size = 0;
	if (request.getParameter("esSize") != null)
	size = Integer.parseInt(request.getParameter("esSize"));

	al.clear();
	om.setPacId(request.getParameter("pacId"));
	om.setCodPaciente(request.getParameter("codPac"));
	om.setFecNacimiento(request.getParameter("dob"));
	om.setSecuencia(request.getParameter("noAdmision"));
	om.setFecha(cDateTime.substring(0,10));
	om.setMedico(request.getParameter("medico"));
	om.setUsuarioCreacion((String) session.getAttribute("_userName"));
	om.setFechaCreacion(cDateTime);
	om.setUsuarioModif((String) session.getAttribute("_userName"));
	om.setTelefonica("N");
	om.setFormaSolicitud(request.getParameter("formaSolicitud"));

	om.setCodigo(request.getParameter("id"));
	//om.setTipoSolicitud(""+tipoSolicitud);
	//om.setTipoSalida(request.getParameter("tipoSalida"));


	//om.setFechaCreacion(cDateTime);
	om.getDetalleOrdenMed().clear();
	//iEsquema.clear();
	for (int i=1; i<=size; i++)
	{
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setKey(request.getParameter("key"+i));
		//detOrd.setCodigo(request.getParameter("codigo"+i));
		//detOrd.setFechaOrden(request.getParameter("fecha"+i));

		detOrd.setNombre(request.getParameter("insulina"));
		detOrd.setDescripcion(request.getParameter("nombre"+i));
		detOrd.setCantidad(request.getParameter("cantidad"+i));
		//detOrd.setFechaFin(request.getParameter("fechaFin"+i));
		//detOrd.setFechaInicio(cDateTime);

		//detOrd.setTipoSolicit(tipoSolicitud);
		//detOrd.setCentroServicio(""+cds);
		detOrd.setTipoOrden(""+tipoOrden);
		detOrd.setEstado("A");


		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = key;
		else
		{
			try
			{
				iEsquema.put(key,detOrd);
				om.getDetalleOrdenMed().add(detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for

	if (!itemRemoved.equals(""))
	{
		iEsquema.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&id="+request.getParameter("id")+"&desc="+desc+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		//cdo = new CommonDataObject();
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setDescripcion("");

		sLastLineNo++;
		if (sLastLineNo < 10) key = "00" + sLastLineNo;
		else if (sLastLineNo < 100) key = "0" + sLastLineNo;
		else key = "" + sLastLineNo;
		//cdo.addColValue("key",key);
		detOrd.setKey(key);
		try
		{
			iEsquema.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&id="+request.getParameter("id")+"&desc="+desc+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equals("add"))
		{
				om.setDescripcion("REVISAR EL ESQUEMA DE INSULINA DEL PACIENTE");
				EIMgr.addEsquema(om);
				id = EIMgr.getPkColValue("id");
		}
		else
		{
			om.setDescripcion("REVISAR EL ESQUEMA DE INSULINA DEL PACIENTE (HA SIDO MODIFICADO)");
			EIMgr.updateEsquema(om);
			id = request.getParameter("id");
		}

		ConMgr.clearAppCtx(null);


	}
	//session.removeAttribute("iEsquema");

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (EIMgr.getErrCode().equals("1"))
{
	session.removeAttribute("om");
%>
	alert('<%=EIMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%if(from.trim().equals("")){%>
	parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
		<%}%>

<%
	}
	else
	{
%>
	<%if(from.trim().equals("")){%>
		parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%}%>
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
} else throw new Exception(EIMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>&medico=<%=medico%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

