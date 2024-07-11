<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.OrdenMedicaMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="java.io.*"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iOrdenes" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
<jsp:useBean id="OrdMgr" scope="page" class="issi.expediente.OrdenMedicaMgr" />
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
OrdMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

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

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
int sLastLineNo =0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String tipoOrden ="8";
String cds ="";
String tipoSolicitud ="P";
String subTipo ="";
if (request.getParameter("sLastLineNo") != null) sLastLineNo = Integer.parseInt(request.getParameter("sLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
sql ="select b.codigo value_col, b.descripcion label_col, b.codigo title_col, b.cod_tipo_ordenvarios key_col from TBL_CDS_OM_VARIOS_SUBTIPO b order by b.cod_tipo_ordenvarios,b.codigo ";
		XMLCreator xc = new XMLCreator(ConMgr);
		 xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"subOrdenVarios.xml",sql);
sql = "select unique a.codigo ordenMed,to_char(a.fecha,'dd/mm/yyyy') fechaOrden,nvl(b.nombre,' ') nombre from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id=b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.tipo_orden = 8  and a.pac_id="+pacId+" and a.secuencia="+noAdmision+" order by a.codigo desc" ;
	  al2 = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);
	
	if (change == null)
	{
		om = new OrdenMedica();
		session.setAttribute("om",om);
		iOrdenes.clear();
		
		if(!id.trim().equals("0"))
		{
		sql = "select cod_paciente, fec_nacimiento, secuencia,tipo_orden tipoOrden, orden_med ordenMed, codigo, nombre, to_char(fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin,  observacion, ejecutado, centro_servicio, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion,tipo_dieta tipoDieta,  cod_tipo_dieta codTipoDieta, tipo_tubo tipoTubo, fecha_orden, omitir_orden, pac_id, fecha_suspencion, obser_suspencion, estado_orden,tipo_ordenvarios tipoOrdenVarios, subtipo_ordenvarios subTipoOrdenVarios from tbl_sal_detalle_orden_med where tipo_orden = 8 and pac_id="+pacId+" and secuencia="+noAdmision+" and orden_med ="+id ;
		
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleOrdenMed.class);

		sLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			try
			{
				iOrdenes.put(key, al.get(i-1));//iInter.put(key, al.get(i-1));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		}
		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			DetalleOrdenMed detOrd  = new DetalleOrdenMed();

			detOrd.setCodigo("0");
			detOrd.setTipoSolicit(""+tipoSolicitud);
			detOrd.setTipoOrden(""+tipoOrden);
			detOrd.setCentroServicio(""+cds);
			detOrd.setFechaInicio(cDateTime);
			

			detOrd.setFechaOrden(cDateTime.substring(0,10));
			sLastLineNo++;
			if (sLastLineNo < 10) key = "00" + sLastLineNo;
			else if (sLastLineNo < 100) key = "0" + sLastLineNo;
			else key = "" + sLastLineNo;
			detOrd.setKey(""+key);

			try
			{
				iOrdenes.put(key, detOrd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//else if (!viewMode) mode = "edit";
	}//change=null

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Ordenes Medicas Varias - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();document.form0.medico.value = <%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;checkViewMode();setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function setEvaluacion(code){window.location = '../expediente/exp_ordenes_varias.jsp?modeSec=view&mode=<%=mode%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&id='+code;}
function add(){window.location = '../expediente/exp_ordenes_varias.jsp?modeSec=add&mode=<%=mode%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&from=<%=from%>&medico=<%=medico%>';}
function imprimirOrden(){abrir_ventana1('../expediente/print_list_ordenmedica.jsp?fg=OV&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipoOrden=8&desc=<%=desc%>&id=<%=id%>');}

function consultas(){
  abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=8&interfaz=');
}
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
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("desc",desc)%>
				 <%=fb.hidden("medico",medico)%>
				 <%=fb.hidden("from",from)%>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Ordenes</cellbytelabel></td>
							<td align="right">
                            <a href="javascript:consultas()" class="Link00Bold">[ <cellbytelabel>Consultar</cellbytelabel> ]</a>
                            <%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Orden</cellbytelabel> ]</a><%}if(modeSec.trim().equals("add")){%>
							<a href="javascript:imprimirOrden()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ]</a>
							<%}if(al2.size()>0){%>
                            <a href="javascript:imprimirOrden()" class="Link00">[ <cellbytelabel id="4">Imprimir Todo</cellbytelabel> ]</a>
                            <%}%>
							</td>
						</tr>
						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="5">C&oacute;digo</cellbytelabel></td>
							<td  width="15%"><cellbytelabel id="6">Fecha</cellbytelabel></td>
							<td  width="65%"><cellbytelabel id="7">Orden</cellbytelabel></td>
						</tr>
<%
String cod = "";

for (int i=1; i<=al2.size(); i++)
{
	DetalleOrdenMed det1 = (DetalleOrdenMed) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
	if(!det1.getOrdenMed().equals(cod)){
%>
		<%=fb.hidden("id"+i,det1.getOrdenMed())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=det1.getOrdenMed()%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=det1.getOrdenMed()%></td>
				<td><%=det1.getFechaOrden()%></td>
				<td><%=det1.getNombre()%></td>
		</tr>
<%

	}
cod = det1.getOrdenMed();
}%>

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
			<%=fb.hidden("dietaSize",""+iOrdenes.size())%>
			<%=fb.hidden("sLastLineNo",""+sLastLineNo)%>
			<%=fb.hidden("medico",medico)%>
			<%=fb.hidden("desc",desc)%>
			<%=fb.hidden("from",from)%>
			<%=fb.hidden("formaSolicitud","")%>
			<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				 <td colspan="3"><cellbytelabel id="8">ORDEN VARIOS</cellbytelabel></td>
				 <!--<td width="60%">Observaciones</td>-->
			  <td width="4%" align="center"><%//=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Orden")%></td>
			</tr>

		<tr class="TextRow01">
			<td colspan="4"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel> 
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>	
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,50,"","","")%>
				<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
			</td>
		</tr>
		<tr class="TextRow02">
		<td width="14%"><cellbytelabel id="9">Tipo</cellbytelabel></td>
    	<td width="32%"><cellbytelabel id="10">SubTipo</cellbytelabel></td>
		<td width="50%"><cellbytelabel id="11">Descripci&oacute;n</cellbytelabel></td>
		<td width="32%">&nbsp;</td>
		</tr>
<%
boolean isReadOnly = false;
al = CmnMgr.reverseRecords(iOrdenes);
for (int i=1; i<=iOrdenes.size(); i++)
{
	key = al.get(i-1).toString();
	DetalleOrdenMed detOrd = (DetalleOrdenMed) iOrdenes.get(key);
////System.out.println("codigo ===== "+detOrd.getCodigo());
	if((!detOrd.getCodigo().trim().equals("")) && !detOrd.getCodigo().trim().equals("0"))
	isReadOnly =true;
	else isReadOnly =false;

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha"+i,detOrd.getFechaOrden())%>
			<%=fb.hidden("codigo"+i,detOrd.getCodigo())%>

			<tr class="<%=color%>">
<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion  from TBL_CDS_ORDENMEDICA_VARIOS "+(viewMode?"":" where estatus = 'A'"),"tipoVarios"+i,detOrd.getTipoOrdenVarios(),false,(viewMode||isReadOnly),0,"Text10",null,"onChange=\"javascript:loadXML('../xml/subOrdenVarios.xml','subTipoVarios"+i+"','"+detOrd.getSubTipoOrdenVarios()+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','')\"")%></td>

<td><%=fb.select("subTipoVarios"+i,"","",false,false,0,"Text10",null,"")%>
		<script language="javascript">loadXML('../xml/subOrdenVarios.xml','subTipoVarios<%=i%>','<%=detOrd.getSubTipoOrdenVarios()%>','VALUE_COL','LABEL_COL',<%=(detOrd.getTipoOrdenVarios() != null && !detOrd.getTipoOrdenVarios().trim().equals(""))?detOrd.getTipoOrdenVarios():"document.form0.tipoVarios"+i+".value"%>,'KEY_COL','');</script>
				</td>
				<td><%=fb.textarea("nombre"+i,detOrd.getNombre(),true,false,(viewMode||isReadOnly),44,2,2000,null,"","")%></td>
				
				<td width="4%" align="center"><%=fb.submit("rem"+i,"X",false,(viewMode||isReadOnly),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
			<tr class="TextRow02" >
				<td colspan="4" align="right">
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
	if (request.getParameter("dietaSize") != null)
	size = Integer.parseInt(request.getParameter("dietaSize"));

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
	//om.setTipoSolicitud(""+tipoSolicitud);
	//om.setTipoSalida(request.getParameter("tipoSalida"));


	//om.setFechaCreacion(cDateTime);
	om.getDetalleOrdenMed().clear();
	iOrdenes.clear();
	for (int i=1; i<=size; i++)
	{
		//cdo = new CommonDataObject();

		//cdo.setTableName("TBL_SAL_MEDICACION_PACIENTE");
		//cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
		//cdo.addColValue("SECUENCIA", request.getParameter("noAdmision"));
		//cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		//cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		//cdo.addColValue("PAC_ID",request.getParameter("pacId"));

		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setKey(request.getParameter("key"+i));
		detOrd.setCodigo(request.getParameter("codigo"+i));
		detOrd.setFechaOrden(request.getParameter("fecha"+i));

		//detOrd.setObservacion(request.getParameter("observacion"+i));
		detOrd.setNombre(request.getParameter("nombre"+i));
		//detOrd.setFechaFin(request.getParameter("fechaFin"+i));
		detOrd.setFechaInicio(cDateTime);

		//detOrd.setTipoSolicit(tipoSolicitud);
		//detOrd.setCentroServicio(""+cds);
		detOrd.setTipoOrden(""+tipoOrden);
		detOrd.setEstado("A");
		detOrd.setTipoOrdenVarios(request.getParameter("tipoVarios"+i));
		detOrd.setSubTipoOrdenVarios(request.getParameter("subTipoVarios"+i));


		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = key;
		else
		{
			try
			{
				iOrdenes.put(key,detOrd);
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
		iOrdenes.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&from="+from+"&medico="+medico);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		//cdo = new CommonDataObject();
		DetalleOrdenMed detOrd = new DetalleOrdenMed();

		detOrd.setCodigo("0");
		detOrd.setFechaOrden(cDateTime.substring(0,10));
		detOrd.setFechaInicio(cDateTime);
		//cdo.addColValue("CODIGO","0");
		//cdo.addColValue("FECHA",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		sLastLineNo++;
		if (sLastLineNo < 10) key = "00" + sLastLineNo;
		else if (sLastLineNo < 100) key = "0" + sLastLineNo;
		else key = "" + sLastLineNo;
		//cdo.addColValue("key",key);
		detOrd.setKey(key);
		try
		{
			iOrdenes.put(key, detOrd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&sLastLineNo="+sLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&from="+from+"&medico="+medico);
		return;
	}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equals("add"))
		{
				OrdMgr.addOrden(om);
				id = OrdMgr.getPkColValue("id");
		}
		ConMgr.clearAppCtx(null);
	}
	
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (OrdMgr.getErrCode().equals("1"))
{
%>
	alert('<%=OrdMgr.getErrMsg()%>');
<%	session.removeAttribute("om");
	session.removeAttribute("iOrdenes");

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
} else throw new Exception(OrdMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&medico=<%=medico%>&from=<%=from%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
