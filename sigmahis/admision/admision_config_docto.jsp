<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>

<%
/**
==================================================================================
ADM3309
ADM3310_CON_SUP
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Admision adm = new Admision();
Admision resp = new Admision();
String key = "";
StringBuffer sbSql;
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String change = request.getParameter("change");
String fecha="",fechaIngreso="";
int camaLastLineNo = 0;
int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,E=EN ESPERA";//,S=ESPECIAL se quita estado, soliciado el Mon, Aug 20, 2012 9:28 am por catherine.
String contCredOptions = "C=CONTADO, R=CREDITO";
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("con_sup")) { viewMode = true; estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA"; contCredOptions = "C=CONTADO, R=CREDITO"; }
if (fp == null) fp = "adm";
String loadInfo = request.getParameter("loadInfo");
if (loadInfo == null) loadInfo = "N";


if (request.getMethod().equalsIgnoreCase("GET") && loadInfo.equals("S"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iDoc.clear();
		vDoc.clear();
		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		noAdmision = "0";
		adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("P");

		int nRec = 0;
		StringBuffer sbFilter = new StringBuffer();
		if (!UserDet.getUserProfile().contains("0")) { sbFilter.append(" and d.codigo in (select cod_cds from tbl_cds_usuario_x_cds where usuario='"); sbFilter.append(session.getAttribute("_userName")); sbFilter.append("' and crea_admision='S')"); }
		nRec = CmnMgr.getCount("select count(*) from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+"");
		if (nRec == 1)
		{
			CommonDataObject cdo = SQLMgr.getData("select a.categoria, a.codigo as tipoAdmision, a.descripcion as tipoAdmisionDesc, b.descripcion as categoriaDesc, d.codigo as centroServicio, d.descripcion as centroServicioDesc from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+" order by d.descripcion, b.descripcion, a.descripcion");
			adm.setCategoria(cdo.getColValue("categoria"));
			adm.setCategoriaDesc(cdo.getColValue("categoriaDesc"));
			adm.setTipoAdmision(cdo.getColValue("tipoAdmision"));
			adm.setTipoAdmisionDesc(cdo.getColValue("tipoAdmisionDesc"));
			adm.setCentroServicio(cdo.getColValue("centroServicio"));
			adm.setCentroServicioDesc(cdo.getColValue("centroServicioDesc"));
		}
	}
	else
	{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		if (change == null)
		{
			iDoc.clear();
			vDoc.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.documento, a.revisado_admision as revisadoAdmision, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, (select nombre from tbl_adm_documento where codigo=a.documento) as documentoDesc, a.revisado_sala as revisadoSala, a.revisado_fac as revisadoFac, a.revisado_cob as revisadoCob, a.observacion, a.estatus as estado, a.user_entrega as userEntrega, a.user_recibe as userRecibe, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, to_char(a.fecha_recibe,'dd/mm/yyyy') as fechaRecibe, a.area_entrega as areaEntrega, a.area_recibe as areaRecibe, a.pase, a.pase_k as paseK from tbl_adm_documentos_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 1");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iDoc.put(key, obj);
					vDoc.addElement(obj.getDiagnostico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function showDocumentoList(){
	abrir_ventana1('../common/check_documento.jsp?fp=admision_new&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
}

function doAction(){
newHeight();
<%
	if (request.getParameter("type") != null && request.getParameter("type").equals("1")){
%>
	showDocumentoList();
<%
	}
%>
}


function doSubmit(){
	document.form1.fechaNacimiento.value = parent.document.form0.fechaNacimiento.value;
	document.form1.codigoPaciente.value = parent.document.form0.codigoPaciente.value;
}
//window.notAValidDate;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","1")%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("fechaNacimiento","")%>
	<%=fb.hidden("codigoPaciente","")%>
	<%=fb.hidden("pacId",pacId)%>
	<%=fb.hidden("noAdmision",noAdmision)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("docSize",""+iDoc.size())%>
	<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
			<td width="75%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="42">Verificado</cellbytelabel></td>
			<td width="5%"><%=fb.submit("addDocumento","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Documentos")%></td>
		</tr>
		<%
		al = CmnMgr.reverseRecords(iDoc);
		for (int i=1; i<=iDoc.size(); i++)
		{
		key = al.get(i - 1).toString();
		Admision obj = (Admision) iDoc.get(key);
		%>
		<%=fb.hidden("key"+i,obj.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("documento"+i,obj.getDocumento())%>
		<%=fb.hidden("documentoDesc"+i,obj.getDocumentoDesc())%>
		<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
		<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
		<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
		<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
		<%=fb.hidden("revisadoSala"+i,obj.getRevisadoSala())%>
		<%=fb.hidden("revisadoFac"+i,obj.getRevisadoFac())%>
		<%=fb.hidden("revisadoCob"+i,obj.getRevisadoCob())%>
		<%=fb.hidden("observacion"+i,obj.getObservacion())%>
		<%=fb.hidden("estado"+i,obj.getEstado())%>
		<%=fb.hidden("userEntrega"+i,obj.getUserEntrega())%>
		<%=fb.hidden("userRecibe"+i,obj.getUserRecibe())%>
		<%=fb.hidden("fechaEntrega"+i,obj.getFechaEntrega())%>
		<%=fb.hidden("fechaRecibe"+i,obj.getFechaRecibe())%>
		<%=fb.hidden("areaEntrega"+i,obj.getAreaEntrega())%>
		<%=fb.hidden("areaRecibe"+i,obj.getAreaRecibe())%>
		<%=fb.hidden("pase"+i,obj.getPase())%>
		<%=fb.hidden("paseK"+i,obj.getPaseK())%>
		<tr class="TextRow01">
			<td><%=obj.getDocumento()%></td>
			<td><%=obj.getDocumentoDesc()%></td>
			<td align="center"><%=fb.checkbox("revisadoAdmision"+i,"S",(obj.getRevisadoAdmision() != null && obj.getRevisadoAdmision().equalsIgnoreCase("S")),viewMode)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Documento")%></td>
		</tr>
<%
}
%>
		</table>
		</td>
	</tr>

	<tr class="TextRow02">
		<td align="right">
			<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
			<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
			<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
			<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
			<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value);doSubmit();\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";

	adm = new Admision();
	adm.setPacId(request.getParameter("pacId"));
	adm.setNoAdmision(request.getParameter("noAdmision"));
	adm.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	adm.setCodigoPaciente(request.getParameter("codigoPaciente"));
	adm.setCompania((String) session.getAttribute("_companyId"));
	adm.setUsuarioModifica((String) session.getAttribute("_userName"));		
		
		int size = 0;
		if (request.getParameter("docSize") != null) size = Integer.parseInt(request.getParameter("docSize"));
		String itemRemoved = "";

		adm.getDocumentos().clear();
		iDoc.clear();
		vDoc.clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setDocumento(request.getParameter("documento"+i));
			obj.setDocumentoDesc(request.getParameter("documentoDesc"+i));
			if (request.getParameter("revisadoAdmision"+i) != null && request.getParameter("revisadoAdmision"+i).equalsIgnoreCase("S"))
				obj.setRevisadoAdmision("S");
			else
				obj.setRevisadoAdmision("N");
			obj.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
			obj.setFechaCreacion(request.getParameter("fechaCreacion"+i));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));

			obj.setRevisadoSala(request.getParameter("revisadoSala"+i));
			obj.setRevisadoFac(request.getParameter("revisadoFac"+i));
			obj.setRevisadoCob(request.getParameter("revisadoCob"+i));
			obj.setObservacion(request.getParameter("observacion"+i));
			obj.setEstado(request.getParameter("estado"+i));

			obj.setUserEntrega(request.getParameter("userEntrega"+i));
			obj.setUserRecibe(request.getParameter("userRecibe"+i));
			obj.setFechaEntrega(request.getParameter("fechaEntrega"+i));
			obj.setFechaRecibe(request.getParameter("fechaRecibe"+i));
			obj.setAreaEntrega(request.getParameter("areaEntrega"+i));
			obj.setAreaRecibe(request.getParameter("areaRecibe"+i));
			obj.setPase(request.getParameter("pase"+i));
			obj.setPaseK(request.getParameter("paseK"+i));

			//obj.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = "1";
			else
			{
				try
				{
					key = "";
					if (i < 10) key = "00"+i;
					else if (i < 100) key = "0"+i;
					else key = ""+i;
					obj.setKey(key);
					iDoc.put(obj.getKey(),obj);
					adm.addDocumento(obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			/*Admision obj = (Admision) iDoc.get(itemRemoved);
			vDoc.remove(obj.getDocumento());
			iDoc.remove(itemRemoved);*/

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&loadInfo=S");
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&loadInfo=S");
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveDocumento(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
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
	if (parent.window) parent.window.close();
	else window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>