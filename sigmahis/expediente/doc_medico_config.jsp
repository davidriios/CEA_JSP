<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%>
<%@ page import="issi.expediente.DocuMedico"%>
<%@ page import="issi.expediente.DocuMedicoAreas"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="DocuMgr" scope="page" class="issi.expediente.DocuMedicoMgr" />
<jsp:useBean id="iCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCds" scope="session" class="java.util.Vector" />
<jsp:useBean id="iProf" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProf" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
DocuMgr.setConnection(ConMgr);

DocuMedico doc = new DocuMedico();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String sql = "";
String mode = "";
String tab = "";
String id = "";
String key = "";
String change = "";
int cdsLastLineNo = 0;
int profLastLineNo = 0;
String userName = (String)session.getAttribute("_userName");
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

Hashtable ht = null;
String imagesFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart")){
   ht = CmnMgr.getMultipartRequestParametersValue(request,imagesFolder,20,true);
  mode = (String)ht.get("mode");
  tab = (String)ht.get("tab");
  change = (String)ht.get("change");
  id = (String)ht.get("id");

  if ((String)ht.get("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt((String)ht.get("cdsLastLineNo"));
  if ((String)ht.get("profLastLineNo") != null) profLastLineNo = Integer.parseInt((String)ht.get("profLastLineNo"));

}else{
   id = request.getParameter("id");
   mode = request.getParameter("mode");
   tab = request.getParameter("tab");
   change = request.getParameter("change");

   if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
   if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
}

if (mode == null || mode.trim().equals("")) mode = "add";
if (tab == null) tab = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		doc.setEdadFrom("0");
		doc.setEdadTo("120");
		
		if (change == null)
		{
		  iCds.clear();
		  vCds.clear();
		  iProf.clear();
			vProf.clear();
		}
	}
	else
	{
		if (id == null) throw new Exception("La Sección de Documento Médico no es válida. Por favor intente nuevamente!");

		sql = "select s.codigo, s.descripcion, s.visible_frm_hist as visibleFrmHist, s.usado_por as usadoPor, s.path, s.report_path as reportPath, s.status, s.report_order as reportOrder, nvl(s.table_name,' ') as tableName, nvl(s.where_clause, ' ') as whereClause, nvl(aud_det_path,' ') as audDetPath, nvl(validar_farmacia,'N') as validarFarmacia, view_path as viewPath, decode(icon_path,null,' ','"+imagesFolder.replaceAll(rootFolder,"..")+"/'||icon_path) iconPath, s.nombre_corto as nombreCorto, s.grupo_exp as grupoExp,nvl(validar_reg,'N') as validarReg, nvl(sexo, 'A') sexo, nvl(edad_from, 0)edadFrom, nvl(edad_to, 120)edadTo from tbl_sal_expediente_secciones s where  s.codigo = "+id;

		doc = (DocuMedico) sbb.getSingleRowBean(ConMgr.getConnection(),sql, DocuMedico.class);

		if (change == null)
		{
			iCds.clear();
			vCds.clear();
			iProf.clear();
			vProf.clear();

			sql = "select a.cod_sec as codSec, a.centro_servicio as centroServicio, b.descripcion as observacion, a.sec_orden as secOrden from tbl_sal_exp_secc_centro a, tbl_cds_centro_servicio b where cod_sec="+id+" and b.codigo=a.centro_servicio order by a.sec_orden";
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DocuMedicoAreas.class);
			cdsLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DocuMedicoAreas area = (DocuMedicoAreas) al.get(i-1);

			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;
				area.setKey(key);

			  iCds.put(key, area);
			  vCds.addElement(area.getCentroServicio());
			}//for

			sql = "select a.profile_id as profileId, a.secc_id as codSec, a.editable, b.profile_name as profileName from tbl_sal_exp_secc_profile a, tbl_sec_profiles b where secc_id="+id+" and a.profile_id=b.profile_id order by a.profile_id";
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DocuMedicoAreas.class);
			profLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DocuMedicoAreas prof = (DocuMedicoAreas) al.get(i-1);

			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;
				prof.setKey(key);

			  iProf.put(key, prof);
			  vProf.addElement(prof.getProfileId());
			}//for

		}//change is null

	}//edit
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title="Sección de Documento Médico - "+document.title;

function doAction()
{
<%
if (request.getParameter("type") != null)
{
	if (tab.equals("1"))
	{
%>
	 showCdsList();
<%
	}
	else if (tab.equals("2"))
	{
%>
	 showProfileList();
<%
	}
}
%>
}

function showCdsList()
{
  abrir_ventana1('../common/check_cds.jsp?fp=seccion&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>');
}

function showProfileList()
{
  abrir_ventana1('../common/check_profile.jsp?fp=seccion&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
<tr>
	<td class="TableBorder">

<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<%//fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null, FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("id",id)%>
<%//=fb.hidden("seccionId",doc.getSeccionId())%>
<%//=fb.hidden("categoriaId",doc.getCategoriaId())%>

		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="35%"><%=fb.intBox("codigo",doc.getCodigo(),false,false,true,30,3)%></td>
			<td width="15%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("descripcion",doc.getDescripcion(),true,false,false,50,2000)%></td>
		</tr>

   <tr class="TextRow01">
			<td width="15%"><cellbytelabel id="2">Grupo</cellbytelabel></td>
			<td width="35%">
        <%=fb.select("grupo_exp","OM=ORDEN MEDICA,ANT=ANTECEDENTES,UC=USO CONSTANTE,OTH=OTROS",doc.getGrupoExp(),"S")%>
       </td>
			<td width="15%"><cellbytelabel id="1">Nombre Corto</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("nombre_corto",doc.getNombreCorto(),false,false,false,30,15)%></td>
		</tr>
		
		<tr class="TextRow01">
			<td>Sexo</td>
			<td><%=fb.select("sexo","A=AMBOS,F=FMENINO,M=MASCULINO",doc.getSexo(),"")%></td>
			<td>Edad desde</td>
			<td>
        <%=fb.intBox("edad_from",doc.getEdadFrom(),false,false,false,4,4)%>
        &nbsp;&nbsp;&nbsp;Edad hasta:
        <%=fb.intBox("edad_to",doc.getEdadTo(),false,false,false,4,4)%>
			</td>
		</tr>

		<tr class="TextRow01">
			<td><cellbytelabel id="3">Visible</cellbytelabel></td>
			<td><%=fb.checkbox("visibleFrmHist","S",doc.getVisibleFrmHist()!=null && doc.getVisibleFrmHist().equalsIgnoreCase("S"),false)%></td>
			<td><cellbytelabel id="4">Usado Por</cellbytelabel></td>
			<td><%=fb.select("usadoPor","EF=ENFERMERIA,MD=MEDICO,TG=TRIAGE,ME=MEDICO Y ENFERMERIA,IC=INTERCONSULTOR,MI=MEDICO E INTERCONSULTOR,MIE=MEDICO, INTERCONSULTOR Y ENFERMERIA,MEA=MEDICO, INTERCONSULTOR, ENFERMERIA Y ASIST. ADMIN,AA=ASISTENTE ADMINISTRATIVO ,EA=ENFERMERA Y ASIST. ADMINISTRATIVO,AM=TODOS",doc.getUsadoPor())%></td>
		</tr>

		<tr class="TextRow01">
			<td>Ruta Pantalla</td>
			<td><%=fb.textBox("path",doc.getPath(),false,false,false,50,250,"ignore",null, null)%></td>
			<td>Estado</td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO",doc.getStatus())%></td>
		</tr>

		<tr class="TextRow01">
			<td>Ruta Reporte</td>
			<td><%=fb.textBox("reportPath",doc.getReportPath(),false,false,false,50,250,"ignore",null, null)%></td>
			<td>Orden de impresi&oacute;n</td>
			<td><%=fb.intBox("reportOrder",doc.getReportOrder(),false,false,false,4,4)%>
			</td>
		</tr>

		<% if(UserDet.getUserProfile().contains("0")){ %>
		  <tr class="TextRow01">
			<td>Tabla Audit.</td>
			<td><%=fb.textBox("table_name",doc.getTableName(),false,false,false,50,30)%></td>
			<td>Where Clause Audit.</td>
			<td><%=fb.textBox("where_clause",doc.getWhereClause(),false,false,false,50,500)%></td>
		  </tr>

		  <tr class="TextRow01">
			<td>Ruta Detalle Audit</td>
			<td colspan="3"><%=fb.textBox("aud_det_path",doc.getAudDetPath(),false,false,false,152,250)%></td>
		  </tr>

		  <tr class="TextRow01">
			<td>Ruta Validaci&oacute;n Far.</td>
			<td><%=fb.textBox("view_path",doc.getViewPath(),false,false,false,50,250)%></td>
			<td><label for="validar_farmacia" class="pointer">Activar Validaci&oacute;n?</label></td>
			<td>
			<%=fb.checkbox("validar_farmacia","S",(doc.getValidarFarmacia().equalsIgnoreCase("S")),false,null,null,"")%>
			</td>
		  </tr>
		<% } %>
<tr class="TextRow01">
			<td></td>
			<td></td>
			<td><label for="validar_reg" class="pointer">Validar al Anular Adm.?</label></td>
			<td>


			<%=fb.checkbox("validar_reg","S",(doc.getValidarReg().equalsIgnoreCase("S")),false,null,null,"")%>
			</td>

		  </tr>

		<tr class="TextRow01">
			<td><cellbytelabel>Icono</cellbytelabel></td>
			<td colspan="3"><%=fb.fileBox("icon_path", doc.getIconPath(),false,false,16)%></td>
		</tr>

		<tr class="TextRow02">
			<td align="right" colspan="4">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel id="9">Crear Otro </cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="11">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.submit("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("id",id)%>

		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4"><cellbytelabel id="12">Secci&oacute;n</cellbytelabel>: [<%=doc.getCodigo()%>] <%=doc.getDescripcion()%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="13">Ar&eacute;as que utilizan la Secci&oacute;n</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="65%">Centro de Servicio</td>
			<td width="10%">Sec. Orden</td>
			<td width="5%"><%=fb.submit("addCds","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Centro de Servicios")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iCds);
for (int i=1; i<=iCds.size(); i++)
{
	key = al.get(i - 1).toString();
	DocuMedicoAreas area = (DocuMedicoAreas) iCds.get(key);
%>
<%=fb.hidden("key"+i,area.getKey())%>
<%=fb.hidden("centroServicio"+i,area.getCentroServicio())%>
<%=fb.hidden("observacion"+i,area.getObservacion())%>
<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td><%=area.getCentroServicio()%></td>
			<td><%=area.getObservacion()%></td>
			<td align="center"><%=fb.intBox("secOrden"+i,area.getSecOrden(),true,false,false,9,5)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="4">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%><cellbytelabel id="9">Crear Otro</cellbytelabel> -->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="11">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.submit("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("id",id)%>

		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4"><cellbytelabel id="12">Secci&oacute;n</cellbytelabel>: [<%=doc.getCodigo()%>] <%=doc.getDescripcion()%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="14">Perfiles que utilizan la Secci&oacute;n</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="65%"><cellbytelabel id="15">Perfil</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="16">Editable</cellbytelabel></td>
			<td width="5%"><%=fb.submit("addProf","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Perfiles")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iProf);
for (int i=1; i<=iProf.size(); i++)
{
	key = al.get(i - 1).toString();
	DocuMedicoAreas prof = (DocuMedicoAreas) iProf.get(key);
%>
<%=fb.hidden("key"+i,prof.getKey())%>
<%=fb.hidden("profileId"+i,prof.getProfileId())%>
<%=fb.hidden("profileName"+i,prof.getProfileName())%>
<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td><%=prof.getProfileId()%></td>
			<td><%=prof.getProfileName()%></td>
			<td align="center"><%=fb.checkbox("editable"+i,"1",(prof.getEditable() != null && prof.getEditable().equals("1")),false)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="4">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%><cellbytelabel id="9">Crear Otro</cellbytelabel> -->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="11">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.submit("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

	</td>
</tr>
</table>
<script type="text/javascript">
<%
String tabLabel = "'Sección'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Centro de Servicio','Perfiles'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	DocuMedico docu = new DocuMedico();
	docu.setCodigo(id);

	if (tab.equals("0"))
	{
		saveOption = (String)ht.get("saveOption");
		baction = (String)ht.get("baction");

		docu.setDescripcion((String)ht.get("descripcion"));
		docu.setVisibleFrmHist( (String)ht.get("visibleFrmHist") != null && ((String)ht.get("visibleFrmHist")).equals("S")?"S":"N");
		docu.setUsadoPor((String)ht.get("usadoPor"));
		docu.setTipoExpediente("ECA");

		docu.setPath((String)ht.get("path"));
		docu.setStatus((String)ht.get("status"));
		docu.setReportPath((String)ht.get("reportPath"));
		docu.setReportOrder((String)ht.get("reportOrder"));
		docu.setTableName((String)ht.get("table_name"));
		docu.setWhereClause((String)ht.get("where_clause"));

		docu.setAudDetPath((String)ht.get("aud_det_path"));
		docu.setValidarFarmacia((String)ht.get("validar_farmacia"));

		docu.setValidarReg((String)ht.get("validar_reg"));

		docu.setViewPath((String)ht.get("view_path"));
		docu.setIconPath((String)ht.get("icon_path"));

    docu.setNombreCorto((String)ht.get("nombre_corto"));
    docu.setGrupoExp((String)ht.get("grupo_exp"));
    docu.setSexo((String)ht.get("sexo"));
    docu.setEdadFrom((String)ht.get("edad_from"));
    docu.setEdadTo((String)ht.get("edad_to"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			DocuMgr.add(docu);
			id = DocuMgr.getPkColValue("codigo");
		}
		else
		{
			DocuMgr.update(docu);
		}
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1"))
	{
		int size = Integer.parseInt(request.getParameter("cdsSize"));
		String itemRemoved = "";

		docu.getAreas().clear();
		for (int i=1; i<=size; i++)
		{
			DocuMedicoAreas area = new DocuMedicoAreas();

			area.setCentroServicio(request.getParameter("centroServicio"+i));
			area.setObservacion(request.getParameter("observacion"+i));
			area.setSecOrden(request.getParameter("secOrden"+i));
			area.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = area.getKey();
			else
			{
				try
				{
					iCds.put(area.getKey(),area);
					docu.addAreas(area);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vCds.remove(((DocuMedicoAreas) iCds.get(itemRemoved)).getCentroServicio());
			iCds.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		DocuMgr.addAreas(docu);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2"))
	{
		int size = Integer.parseInt(request.getParameter("profSize"));
		String itemRemoved = "";

		docu.getProfile().clear();
		for (int i=1; i<=size; i++)
		{
			DocuMedicoAreas prof = new DocuMedicoAreas();

			prof.setProfileId(request.getParameter("profileId"+i));
			prof.setProfileName(request.getParameter("profileName"+i));
			prof.setEditable((request.getParameter("editable"+i)==null)?"0":"1");
			prof.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = prof.getKey();
			else
			{
				try
				{
					iProf.put(prof.getKey(),prof);
					docu.addProfile(prof);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vProf.remove(((DocuMedicoAreas) iProf.get(itemRemoved)).getProfileId());
			iProf.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		DocuMgr.addProfile(docu);
		ConMgr.clearAppCtx(null);
	}
%>
<!doctype html>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (DocuMgr.getErrCode().equals("1"))
{
%>
	alert('<%=DocuMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/doc_medico_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/doc_medico_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/doc_medico_list.jsp';
<%
	}
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
} else throw new Exception(DocuMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
