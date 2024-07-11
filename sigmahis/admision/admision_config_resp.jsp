<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iResp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vResp" scope="session" class="java.util.Vector"/>
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
SQLMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alRefType = new ArrayList();

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
int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (fp == null) fp = "adm";
String loadInfo = request.getParameter("loadInfo");
String compania = (String) session.getAttribute("_companyId");

String fromNewView = request.getParameter("from_new_view");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");

if (fromNewView == null) fromNewView = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";

if (loadInfo == null) loadInfo = "N";
if (request.getMethod().equalsIgnoreCase("GET") && loadInfo.equals("S"))
{
			alRefType = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = "+compania+" and resp_pac='S' order by 2",CommonDataObject.class);

	if (mode.equalsIgnoreCase("add"))
	{
		iResp.clear();
		vResp.clear();		
	}
	else
	{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		if (change == null)
		{
			iResp.clear();
			vResp.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.identificacion, a.tipo_identificacion, a.nombre, nvl(a.sexo,' ') as sexo, decode(a.nacionalidad,null,' ',a.nacionalidad) as nacionalidad, nvl(a.direccion,' ') as direccion, decode(a.comunidad, null, ' ', a.comunidad) as comunidad, decode(a.corregimiento, null, ' ', a.corregimiento) as corregimiento, decode(a.distrito, null, ' ', a.distrito) as distrito, decode(a.provincia, null, ' ', a.provincia) as provincia, decode(a.pais, null, ' ', a.pais) as pais, nvl(a.telefono_residencia,' ') as telefono_residencia, nvl(a.apartado_postal,' ') as apartado_postal, nvl(a.zona_postal,' ') as zona_postal, decode(a.ingreso_mensual,null,' ',a.ingreso_mensual) as ingreso_mensual, decode(a.anios_laborados,null,' ',a.anios_laborados) as anios_laborados, decode(a.meses_laborados,null,' ',a.meses_laborados) as meses_laborados, decode(a.otros_ingresos,null,' ',a.otros_ingresos) as otros_ingresos, nvl(a.fuente_otros_ingresos,' ') as fuente_otros_ingresos, nvl(a.lugar_de_trabajo,' ') as lugar_de_trabajo, nvl(a.puesto_que_ocupa,' ') as puesto_que_ocupa, nvl(a.direccion_trabajo,' ') as direccion_trabajo, nvl(a.telefono_de_trabajo,' ') as telefono_de_trabajo, nvl(a.extension,' ') as extension, nvl(a.parentesco,' ') as parentesco, nvl(a.fax,' ') as fax, nvl(a.e_mail,' ') as e_mail, nvl(a.observacion,' ') as observacion, nvl(a.lugar_nac,' ') as lugar_nac, a.principal, nvl(a.seguro_social,' ') as seguro_social, a.compania, a.usuario_creacion, a.usuario_modifica, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, to_char(a.fecha_modifica,'dd/mm/yyyy') as fecha_modifica, a.pac_id as pacId, nvl((select nacionalidad from tbl_sec_pais where codigo=a.nacionalidad),' ') as nacionalidadDesc, nvl((select decode(nombre_comunidad,'NA',null,nombre_comunidad) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad),' ') as nombreComunidad, nvl((select decode(nombre_corregimiento,'NA',null,nombre_corregimiento) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombreCorregimiento, nvl((select decode(nombre_distrito,'NA',null,nombre_distrito) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombreDistrito, nvl((select decode(nombre_provincia,'NA',null,nombre_provincia) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombreProvincia, nvl((select decode(nombre_pais,'NA',null,nombre_pais) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombrePais,a.ref_id,a.ref_type,a.estado,a.id, nvl(a.usa_en_impresion_dgi, 'N') usa_en_impresion_dgi from tbl_adm_responsable a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 30 desc,a.estado");
			al=SQLMgr.getDataList(sbSql.toString());
			for(int h=0;h<al.size();h++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(h);
				cdo2.setKey(h);
				cdo2.setAction("U");
				iResp.put(cdo2.getKey(),cdo2);
			}
			if (al.size() == 0)
			{
				CommonDataObject cdo2 = new CommonDataObject();
				cdo2.setKey(iResp.size()+1);
				cdo2.setAction("I");
				cdo2.addColValue("id","0");
				try
				{
					iResp.put(cdo2.getKey(),cdo2);
				}
				catch(Exception e)
				{
					//System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script>
document.title = 'Admisión - '+document.title;
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
function doAction(){newHeight();}

function doSubmit(){    
    <%if(!fromNewView.equals("")){%>
      document.form1.fechaNacimiento.value = "<%=fechaNacimiento%>";
	    document.form1.codigoPaciente.value = "<%=codigoPaciente%>";
    <%} else {%>
      document.form1.fechaNacimiento.value = parent.document.form0.fechaNacimiento.value;
      document.form1.codigoPaciente.value = parent.document.form0.codigoPaciente.value;
    <%}%>
}

function getClient(k){var referTo=getSelectedOptionTitle(eval('document.form1.ref_type'+k),eval('document.form1.ref_type'+k).value);var ref_id = eval('document.form1.ref_type'+k).value;  if(ref_id!=''){abrir_ventana('../pos/sel_otros_cliente.jsp?fp=admision_medico_resp_new&fg=<%=fg%>&mode=<%=mode%>&Refer_To='+referTo+'&ref_id='+ref_id+'&idx='+k); }else{CBMSG.warning('Seleccione Tipo Cliente');}}
function showNacionalidadList(k){abrir_ventana1('../rhplanilla/list_pais.jsp?id=7&index='+k);}
function showUbicacionGeoList(k){abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=admision_new&index='+k);}
function clearRef(k){eval('document.form1.ref_id'+k).value="";eval('document.form1.nombre'+k).value="";eval('document.form1.identificacion'+k).value="";}
function isDuplicatedStatus(){var respSize=parseInt(document.form1.respSize.value,10);var x=0;for(i=0;i<respSize;i++){if(eval('document.form1.estado'+i).value=='A' && eval('document.form1.action'+i).value!='D'){ x++;}}if(x>1){CBMSG.warning('No se permite mas de un responsable Con estado Activo! Favor verifique');return false;}else return true;}

$(document).ready(function(){
  $( "select[name^='ref_type']" ).change(function(){
     var val = $(this).val();
	 var valName=$(this).attr("name").toString();
	 var i = valName.match(/\d+$/)[0];
	 if (!val) {
	   $("#ref_id"+i).val("0");
	   $("#nombre"+i).attr("readonly",false);
	   $("#btnRef"+i).attr("disabled",true);
	 }
	 else {
	   $("#nombre"+i).attr("readonly",true);
	   $("#btnRef"+i).attr("disabled",false);
	 }
  });
});
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
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
	<%=fb.hidden("respSize",""+iResp.size())%>
	<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
		<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="12%"><cellbytelabel id="61">Tipo Cliente</cellbytelabel></td>
				<td width="15%"><cellbytelabel id="62">Cliente</cellbytelabel></td>
				<td width="13%"><cellbytelabel id="63">No. S.S.</cellbytelabel></td>
				<td width="50%"><cellbytelabel id="64">Nombre Completo</cellbytelabel></td>
				<td width="5%"><cellbytelabel id="65">Sexo</cellbytelabel></td>
				<td width="5%" align="center"><%=fb.submit("addResponsable","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Responsables")%></td>
			</tr>
			<%
			al = CmnMgr.reverseRecords(iResp);
			for (int i=0; i<iResp.size(); i++)
			{
				key = al.get(i).toString();
				CommonDataObject cdo =(CommonDataObject) iResp.get(key);
				String panelId = "Audit51."+i;
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";
			%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("usuarioCreacion"+i,cdo.getColValue("usuario_creacion"))%>
			<%=fb.hidden("fechaCreacion"+i,cdo.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuarioModifica"+i,cdo.getColValue("usuario_modifica"))%>
			<%=fb.hidden("fechaModifica"+i,cdo.getColValue("fecha_modifica"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("identificacion"+i,cdo.getColValue("identificacion"))%>
			<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
			<tr class="<%=color%>" align="center">
				<td><%=fb.select("ref_type"+i,alRefType,cdo.getColValue("ref_type"),false,(viewMode),0,"Text10",null,"onChange=\"javascript:clearRef("+i+")\"",null,"S")%></td>
				<td><%=fb.textBox("ref_id"+i,( cdo.getColValue("ref_type")==null||"".equals(cdo.getColValue("ref_type"))?"0":cdo.getColValue("ref_id")),true,false,true,20,30,"Text10",null,null)%></td>
				<td><%=fb.textBox("seguroSocial"+i,cdo.getColValue("seguro_social"),false,false,viewMode,15,13,"Text10",null,null)%></td>
				<td>
				<%=fb.textBox("nombre"+i,cdo.getColValue("nombre"),true,false,( cdo.getColValue("ref_id")!=null&& !"0".equals(cdo.getColValue("ref_id"))  ),60,100,"Text10",null,null)%>
				<%=fb.button("btnRef"+i,"...",true,( cdo.getColValue("ref_type")==null||"".equals(cdo.getColValue("ref_type") ) )  ?true:viewMode,"Text10", null,"onClick=\"javascript:getClient("+i+");\"" )%></td>
				<td><%=fb.select("sexo"+i,"M,F",cdo.getColValue("sexo"),false,viewMode,0,"Text10",null,null,null,"S")%></td>
				<td align="center" rowspan="2"><%=fb.submit("rem"+i,"X",true,(viewMode||!cdo.getColValue("id").trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Responsable")%></td>
			</tr>
			<tr class="<%=color%>">
				<td colspan="4">
					<cellbytelabel id="69">Parentesco</cellbytelabel>
					<%=fb.textBox("parentesco"+i,cdo.getColValue("parentesco"),false,false,viewMode,30,30,"Text10",null,null)%>
					<cellbytelabel id="70">Es el Principal de la p&oacute;liza?</cellbytelabel>
					<%=fb.checkbox("principal"+i,"S",(cdo.getColValue("principal") != null && cdo.getColValue("principal").equalsIgnoreCase("S")),viewMode)%> &nbsp;&nbsp;&nbsp;Estado: <%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,viewMode,0,"Text10",null,"onChange=\"javascript:isDuplicatedStatus()\"")%>
					<cellbytelabel id="97">Factura Fiscal con Nombre de Responsable?</cellbytelabel>
					<%=fb.checkbox("usa_en_impresion_dgi"+i,"S",(cdo.getColValue("usa_en_impresion_dgi") != null && cdo.getColValue("usa_en_impresion_dgi").equalsIgnoreCase("S")),viewMode)%> 
					 			<br>
					<cellbytelabel id="71">Nacionalidad</cellbytelabel>
					<%=fb.intBox("nacionalidad"+i,cdo.getColValue("nacionalidad"),false,false,true,5,"Text10",null,null)%>
					<%=fb.textBox("nacionalidadDesc"+i,cdo.getColValue("nacionalidadDesc"),false,false,true,40,"Text10",null,null)%>
					<%=fb.button("btnNacionalidad"+i,"...",false,viewMode,"Text10",null,"onClick=\"javascript:showNacionalidadList("+i+")\"")%>
					<br>
					<cellbytelabel id="72">Lugar de Nacimiento</cellbytelabel>
					<%=fb.textBox("lugarNac"+i,cdo.getColValue("lugar_nac"),false,false,viewMode,75,100,"Text10",null,null)%>
				</td>
				<td align="center" onClick="javascript:showHide('51.<%=i%>')" style="text-decoration:none; cursor:pointer" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<i><label id="plus51.<%=i%>" style="display:none">+</label><label id="minus51.<%=i%>">-</label> <cellbytelabel id="71">Detalles</cellbytelabel></i>
				</td>
			</tr>
			<tr id="panel51.<%=i%>" style="display:">
				<td colspan="6">
					<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<td onClick="javascript:showHide('51.<%=i%>.0')" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel" height="25">
								<td width="95%">&nbsp;<cellbytelabel id="72">Ingresos</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51.<%=i%>.0" style="display:none">+</label><label id="minus51.<%=i%>.0">-</label></font>]&nbsp;</td>
							</tr>
							</table>
						</td>
					</tr>
					<tr id="panel51.<%=i%>.0">
						<td>
							<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="<%=color%>">
								<td align="right"><cellbytelabel id="73">Lugar de Trabajo</cellbytelabel></td>
								<td colspan="3"><%=fb.textBox("lugarDeTrabajo"+i,cdo.getColValue("lugar_de_trabajo"),false,false,viewMode,80,80,"Text10",null,null)%></td>
							</tr>
							<tr class="<%=color%>">
								<td align="right"><cellbytelabel id="74">Puesto que ocupa</cellbytelabel></td>
								<td colspan="3"><%=fb.textBox("puestoQueOcupa"+i,cdo.getColValue("puesto_que_ocupa"),false,false,viewMode,80,80,"Text10",null,null)%></td>
							</tr>
							<tr class="<%=color%>">
								<td align="right"><cellbytelabel id="75">Direcci&oacute;n del Trabajo</cellbytelabel></td>
								<td colspan="3"><%=fb.textBox("direccionTrabajo"+i,cdo.getColValue("direccion_trabajo"),false,false,viewMode,80,100,"Text10",null,null)%></td>
							</tr>
							<tr class="<%=color%>">
								<td width="15%" align="right"><cellbytelabel id="76">Tel&eacute;fono del Trabajo</cellbytelabel></td>
								<td width="35%"><%=fb.textBox("telefonoDeTrabajo"+i,cdo.getColValue("telefono_de_trabajo"),false,false,viewMode,15,13,"Text10",null,null)%></td>
								<td width="15%" align="right"><cellbytelabel id="77">Extensi&oacute;n Telef&oacute;nica</cellbytelabel></td>
								<td width="35%"><%=fb.textBox("extension"+i,cdo.getColValue("extension"),false,false,viewMode,10,6,"Text10",null,null)%></td>
							</tr>
							<tr class="<%=color%>">
								<td align="right"><cellbytelabel id="78">A&ntilde;os Laborados</cellbytelabel></td>
								<td><%=fb.intBox("aniosLaborados"+i,cdo.getColValue("anios_laborados"),false,false,viewMode,5,2,"Text10",null,null)%></td>
								<td align="right"><cellbytelabel id="79">Meses Laborados</cellbytelabel></td>
								<td><%=fb.intBox("mesesLaborados"+i,cdo.getColValue("meses_laborados"),false,false,viewMode,5,2,"Text10",null,null)%></td>
							</tr>
							<tr class="<%=color%>">
								<td align="right"><cellbytelabel id="80">Ingreso Mensual</cellbytelabel></td>
								<td><%=fb.decBox("ingresoMensual"+i,cdo.getColValue("ingreso_mensual"),false,false,viewMode,15,8.2,"Text10",null,null)%></td>
								<td align="right"><cellbytelabel id="81">Otros Ingresos</cellbytelabel></td>
								<td><%=fb.decBox("otrosIngresos"+i,cdo.getColValue("otros_ingresos"),false,false,viewMode,15,8.2,"Text10",null,null)%></td>
							</tr>
							<tr class="<%=color%>">
								<td align="right"><cellbytelabel id="82">Fuente de otros ingresos</cellbytelabel></td>
								<td colspan="3"><%=fb.textBox("fuenteOtrosIngresos"+i,cdo.getColValue("fuente_otros_ingresos"),false,false,viewMode,80,100,"Text10",null,null)%></td>
							</tr>
							</table>
						</td>
					</tr>

					<tr>
						<td onClick="javascript:showHide('51.<%=i%>.1')" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel" height="25">
								<td width="95%">&nbsp;<cellbytelabel id="83">Generales</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51.<%=i%>.1" style="display:none">+</label><label id="minus51.<%=i%>.1">-</label></font>]&nbsp;</td>
							</tr>
							</table>
						</td>
					</tr>
					<tr id="panel51.<%=i%>.1">
						<td>
							<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="<%=color%>">
									<td align="right"><cellbytelabel id="84">Direcci&oacute;n Residencial</cellbytelabel></td>
									<td colspan="3"><%=fb.textBox("direccion"+i,cdo.getColValue("direccion"),false,false,viewMode,80,100,"Text10",null,null)%></td>
								</tr>
								<tr class="<%=color%>">
									<td width="15%" align="right"><cellbytelabel id="85">Pa&iacute;s</cellbytelabel></td>
									<td width="35%">
										<%=fb.intBox("pais"+i,cdo.getColValue("pais"),false,false,true,4,"Text10",null,null)%>
										<%=fb.textBox("nombrePais"+i,cdo.getColValue("nombrePais"),false,false,true,40,"Text10",null,null)%>
										<%=fb.button("btnUbicacionGeo"+i,"...",false,viewMode,"Text10",null,"onClick=\"javascript:showUbicacionGeoList("+i+")\"")%>
									</td>
									<td width="15%" align="right"><cellbytelabel id="86">Provincia</cellbytelabel></td>
									<td width="35%">
										<%=fb.intBox("provincia"+i,cdo.getColValue("provincia"),false,false,true,2,"Text10",null,null)%>
										<%=fb.textBox("nombreProvincia"+i,cdo.getColValue("nombreProvincia"),false,false,true,40,"Text10",null,null)%>
									</td>
								</tr>
								<tr class="<%=color%>">
									<td align="right"><cellbytelabel id="87">Distrito</cellbytelabel></td>
									<td>
										<%=fb.intBox("distrito"+i,cdo.getColValue("distrito"),false,false,true,3,"Text10",null,null)%>
										<%=fb.textBox("nombreDistrito"+i,cdo.getColValue("nombreDistrito"),false,false,true,40,"Text10",null,null)%>
									</td>
									<td align="right"><cellbytelabel id="88">Corregimiento</cellbytelabel></td>
									<td>
										<%=fb.intBox("corregimiento"+i,cdo.getColValue("corregimiento"),false,false,true,4,"Text10",null,null)%>
										<%=fb.textBox("nombreCorregimiento"+i,cdo.getColValue("nombreCorregimiento"),false,false,true,40,"Text10",null,null)%>
									</td>
								</tr>
								<tr class="<%=color%>">
									<td align="right"><cellbytelabel id="89">Comunidad</cellbytelabel></td>
									<td>
										<%=fb.intBox("comunidad"+i,cdo.getColValue("comunidad"),false,false,true,6,"Text10",null,null)%>
										<%=fb.textBox("nombreComunidad"+i,cdo.getColValue("nombreComunidad"),false,false,true,40,"Text10",null,null)%>
									</td>
									<td align="right"><cellbytelabel id="90">Correo Electr&oacute;nico</cellbytelabel></td>
									<td><%=fb.textBox("eMail"+i,cdo.getColValue("e_mail"),false,false,viewMode,50,100,"Text10",null,null)%></td>
								</tr>
								<tr class="<%=color%>">
									<td align="right"><cellbytelabel id="91">Tel&eacute;fono Residencial</cellbytelabel></td>
									<td><%=fb.textBox("tel_responsable"+i,cdo.getColValue("telefono_residencia"),false,false,viewMode,15,13,"Text10",null,null)%></td>
									<td align="right"><cellbytelabel id="92">Fax</cellbytelabel></td>
									<td><%=fb.textBox("fax"+i,cdo.getColValue("fax"),false,false,viewMode,15,13,"Text10",null,null)%></td>
								</tr>
								<tr class="<%=color%>">
									<td align="right"><cellbytelabel id="93">Zona Postal</cellbytelabel></td>
									<td><%=fb.textBox("zonaPostal"+i,cdo.getColValue("zona_postal"),false,false,viewMode,20,20,"Text10",null,null)%></td>
									<td align="right"><cellbytelabel id="94">Apartado Postal</cellbytelabel></td>
									<td><%=fb.textBox("apartadoPostal"+i,cdo.getColValue("apartado_postal"),false,false,viewMode,20,20,"Text10",null,null)%></td>
								</tr>
							</table>
						</td>
					</tr>

					<tr>
						<td onClick="javascript:showHide('51.<%=i%>.2')" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel" height="25">
								<td width="95%">&nbsp;<cellbytelabel id="95">Observaci&oacute;n</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51.<%=i%>.2" style="display:none">+</label><label id="minus51.<%=i%>.2">-</label></font>]&nbsp;</td>
							</tr>
							</table>
						</td>
					</tr>
					<tr id="panel51.<%=i%>.2">
						<td>
							<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="<%=color%>">
								<td width="15%" align="right"><cellbytelabel id="96">Observaciones</cellbytelabel></td>
								<td width="85%" colspan="3"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,80,5)%></td>
							</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<%
		}
		fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&!isDuplicatedStatus())error++;");
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
  	int size = 0;
	if (request.getParameter("respSize") != null) size = Integer.parseInt(request.getParameter("respSize"));
	String itemRemoved = "";

	ArrayList list= new ArrayList();
	iResp.clear();
	for (int i=0; i<size; i++)
	{				 
    CommonDataObject cdo2 = new CommonDataObject();
	cdo2.setTableName("tbl_adm_responsable");
	
	cdo2.setWhereClause("id="+request.getParameter("id"+i));
	cdo2.addColValue("fecha_nacimiento",request.getParameter("fechaNacimiento"));
	cdo2.addColValue("paciente",request.getParameter("codigoPaciente"));
	cdo2.addColValue("admision",request.getParameter("noAdmision"));
	cdo2.addColValue("identificacion",request.getParameter("identificacion"+i));
	cdo2.addColValue("tipo_identificacion",request.getParameter("tipoIdentificacion"+i));
	cdo2.addColValue("nombre",request.getParameter("nombre"+i));
	cdo2.addColValue("sexo",request.getParameter("sexo"+i));
	cdo2.addColValue("nacionalidad",request.getParameter("nacionalidad"+i));
	cdo2.addColValue("nacionalidadDesc",request.getParameter("nacionalidadDesc"+i));
	cdo2.addColValue("cod_empresa",request.getParameter("empresa"+i));
	cdo2.addColValue("od_medico",request.getParameter("medico"+i));
	cdo2.addColValue("num_empleado",request.getParameter("numEmpleado"+i));
	cdo2.addColValue("parentesco",request.getParameter("parentesco"+i));
	if (request.getParameter("principal"+i) != null && request.getParameter("principal"+i).equalsIgnoreCase("S"))
	cdo2.addColValue("principal",request.getParameter("principal"+i));
	else cdo2.addColValue("principal","N");
	if (request.getParameter("usa_en_impresion_dgi"+i) != null && request.getParameter("usa_en_impresion_dgi"+i).equalsIgnoreCase("S"))
	cdo2.addColValue("usa_en_impresion_dgi",request.getParameter("usa_en_impresion_dgi"+i));
	else cdo2.addColValue("usa_en_impresion_dgi","N");
	cdo2.addColValue("lugar_nac",request.getParameter("lugarNac"+i));
	cdo2.addColValue("lugar_de_trabajo",request.getParameter("lugarDeTrabajo"+i));
	cdo2.addColValue("puesto_que_ocupa",request.getParameter("puestoQueOcupa"+i));
	cdo2.addColValue("direccion_trabajo",request.getParameter("direccionTrabajo"+i));
	cdo2.addColValue("telefono_de_trabajo",request.getParameter("telefonoDeTrabajo"+i));
	cdo2.addColValue("extension",request.getParameter("extension"+i));
	cdo2.addColValue("anios_laborados",request.getParameter("aniosLaborados"+i));
	cdo2.addColValue("meses_laborados",request.getParameter("mesesLaborados"+i));
	cdo2.addColValue("ingreso_mensual",request.getParameter("ingresoMensual"+i));
	cdo2.addColValue("otros_ingresos",request.getParameter("otrosIngresos"+i));
	cdo2.addColValue("fuente_otros_ingresos",request.getParameter("fuenteOtrosIngresos"+i));
	cdo2.addColValue("direccion",request.getParameter("direccion"+i));
	cdo2.addColValue("pais",request.getParameter("pais"+i));
	cdo2.addColValue("nombrePais",request.getParameter("nombrePais"+i));
	cdo2.addColValue("provincia",request.getParameter("provincia"+i));
	cdo2.addColValue("nombreProvincia",request.getParameter("nombreProvincia"+i));
	cdo2.addColValue("distrito",request.getParameter("distrito"+i));
	cdo2.addColValue("nombreDistrito",request.getParameter("nombreDistrito"+i));
	cdo2.addColValue("corregimiento",request.getParameter("corregimiento"+i));
	cdo2.addColValue("nombreCorregimiento",request.getParameter("nombreCorregimiento"+i));
	cdo2.addColValue("comunidad",request.getParameter("comunidad"+i));
	cdo2.addColValue("nombreComunidad",request.getParameter("nombreComunidad"+i));
	cdo2.addColValue("e_mail",request.getParameter("eMail"+i));
	cdo2.addColValue("telefono_residencia",request.getParameter("tel_responsable"+i));
	cdo2.addColValue("fax",request.getParameter("fax"+i));
	cdo2.addColValue("zona_postal",request.getParameter("zonaPostal"+i));
	cdo2.addColValue("apartado_postal",request.getParameter("apartadoPostal"+i));
	cdo2.addColValue("observacion",request.getParameter("observacion"+i));
	cdo2.addColValue("pase",request.getParameter("pase"+i));
	cdo2.addColValue("pase_k",request.getParameter("pase_k"+i));
	cdo2.addColValue("zona_postal",request.getParameter("zonaPostal"+i));
	cdo2.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo2.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
	cdo2.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));	
	cdo2.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
	cdo2.addColValue("pac_id",request.getParameter("pacId"));
	cdo2.addColValue("seguro_social",request.getParameter("seguroSocial"+i));
	cdo2.addColValue("estado",request.getParameter("estado"+i));
	cdo2.addColValue("ref_type",request.getParameter("ref_type"+i));
	cdo2.addColValue("ref_id",request.getParameter("ref_id"+i));
	cdo2.addColValue("fecha_modifica",cDateTime);
	cdo2.addColValue("id",request.getParameter("id"+i));  
	cdo2.setAction(request.getParameter("action"+i));
    cdo2.setAutoIncCol("id");
    cdo2.setKey(i);

    if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
	{
		itemRemoved = cdo2.getColValue("id");
		if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
		else cdo2.setAction("D");
	}

	if (!cdo2.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iResp.put(cdo2.getKey(),cdo2);
			list.add(cdo2);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
 }//End For
if(!itemRemoved.equals(""))
{
 response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&loadInfo=S&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
 return;
}
		if (baction != null && baction.equals("+"))
		{
 			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("id","0");  
			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.setAction("I");
			cdo.addColValue("estado","A");
			cdo.setKey(iResp.size() + 1);

			try
			{
				iResp.put(cdo.getKey(),cdo); 
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&loadInfo=S&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
			return;
		}

		
if(list.size()==0){
CommonDataObject cdo = new CommonDataObject();
cdo.setTableName("tbl_adm_responsable");
cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
cdo.setKey(iResp.size() + 1);
cdo.setAction("I");
list.add(cdo);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);
	
	
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>