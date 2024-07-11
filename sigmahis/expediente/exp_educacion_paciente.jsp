<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />
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

ArrayList alMed = new ArrayList();
ArrayList alDiag = new ArrayList();
ArrayList alDiagSal = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();


boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (desc == null ) desc = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cod_Historia ="0";
String key = "";
String urlCarnotes ="";
int diagLastLineNo = 0;

if (tab == null) tab = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{


sbSql.append("select contacto ,parentezco_contacto ,telefono_contacto from tbl_adm_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
cdo1 = SQLMgr.getData(sbSql.toString());
if(cdo1 == null)
{
cdo1 =  new CommonDataObject();
if (!viewMode) modeSec = "add";
}
else if (!viewMode) modeSec = "edit";

	sbSql = new StringBuffer();
	sbSql.append("select a.orden_med, to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica, a.nombre as medicamento, a.dosis, (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia, a.frecuencia as descfrecuencia, a.observacion,(select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'--') usuario_omit, /*a.usuario_creacion*/'['||a.usuario_creacion||'] - '||b.name  as usuario_crea, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, a.codigo from tbl_sal_detalle_orden_med a, tbl_sec_users b  where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and b.user_name(+) = a.usuario_creacion and a.tipo_orden=2 and nvl(a.omitir_orden,'N')='N'");
	sbSql.append(" order by a.fecha_orden desc, a.codigo desc");
	alMed = SQLMgr.getDataList(sbSql.toString());

	// DIAGNOSTICOS DE INGRESO.

	sbSql = new StringBuffer();

	sbSql.append("select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision=");
	sbSql.append(noAdmision);
	sbSql.append(" and a.pac_id=");
	sbSql.append(pacId);
	sbSql.append(" and tipo = 'I' order by a.orden_diag");
	
  alDiag = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();

	sbSql.append("select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision=");
	sbSql.append(noAdmision);
	sbSql.append(" and a.pac_id=");
	sbSql.append(pacId);
	sbSql.append(" and tipo = 'S' order by a.orden_diag");
	
  alDiagSal = SQLMgr.getDataList(sbSql.toString());
  sbSql = new StringBuffer();
  sbSql.append("select get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'EXP_URL_CARNOTES') as urlCarnotes from dual ");
		cdo = SQLMgr.getData(sbSql.toString());
sbSql = new StringBuffer();
if(cdo ==null)cdo = new CommonDataObject();	
urlCarnotes = cdo.getColValue("urlCarnotes");

	%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE-DIAGNOSTICOS DE INGRESO '+document.title;
function doAction(){newHeight();<%if (request.getParameter("type") != null){%>showDiagnosticoList();<%}%>}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_89.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
function showInfoMicromedex(application, searchText,tipo){var a = searchText.split("/");var noAdmision = '<%=noAdmision%>';var pacId = '<%=pacId%>';var patientName = parent.document.paciente.nombrePaciente.value;var caregiverName = parent.document.paciente.medicoCabecera.value+ ' - '+parent.document.paciente.nombreMedicoCabecera.value;if (parent.document.paciente.medicoCabecera.value == '') caregiverName = parent.document.paciente.medico.value+ ' - '+parent.document.paciente.nombreMedico.value;var cedula = parent.document.paciente.cedulaPasaporte.value;var fingreso = parent.document.paciente.fechaIngreso.value;var areaadm = parent.document.paciente.cds.value+ ' - '+parent.document.paciente.cdsDesc.value;var url = '';if(application=='ProblemList') {
	/*
	if(tipo=='C') window.top.showPopWin('http://www.thomsonhc.com/infobutton/librarian/access?mainSearchConcept='+a[0].trim()+'^I9^HL70396^^&applicationContext='+application+'^HL7IBAppContext^^^&institution= Infovision%20Solutions^INFOSOL^T157047&contentTarget=C^HL70242^^^&responseFormat=html&language=spa',winWidth*.75,winHeight*.80,null,null,'');
	else window.top.showPopWin('http://www.thomsonhc.com/infobutton/librarian/access?mainSearchConcept=^^^^'+a[0].trim()+'&applicationContext='+application+'^HL7IBAppContext^^^&institution= Infovision%20Solutions^INFOSOL^T157047&contentTarget=C^HL70242^^^&responseFormat=html&language=spa',winWidth*.75,winHeight*.80,null,null,'');
	*/
	if(tipo=='C') url = '<%=urlCarnotes%>?mainSearchConcept='+a[0].trim()+'^I9^HL70396^^&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
else url = '<%=urlCarnotes%>?mainSearchConcept=^^^^'+a[0].trim()+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
	window.top.showPopWin(url,winWidth*.75,winHeight*.80,null,null,'');
} else {
	url = '<%=urlCarnotes%>?mainSearchConcept=^^^^'+a[0].trim()+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
window.top.showPopWin(url,winWidth*.75,winHeight*.80,null,null,'');}}
function getCarenotes(application, flag, tipo){
var sizeM = <%=alMed.size()%>;
var sizeDI = <%=alDiag.size()%>;
var sizeDO = <%=alDiagSal.size()%>;
var url = '';
var searchText = '', x=false;
var noAdmision = '<%=noAdmision%>';
var pacId = '<%=pacId%>';
var patientName = parent.document.paciente.nombrePaciente.value;
var caregiverName = parent.document.paciente.medicoCabecera.value+ ' - '+parent.document.paciente.nombreMedicoCabecera.value;
if (parent.document.paciente.medicoCabecera.value == '') caregiverName = parent.document.paciente.medico.value+ ' - '+parent.document.paciente.nombreMedico.value;
var cedula = parent.document.paciente.cedulaPasaporte.value;
var fingreso = parent.document.paciente.fechaIngreso.value;
var areaadm = parent.document.paciente.cds.value+ ' - '+parent.document.paciente.cdsDesc.value;

	if(flag=='M'){
		for(i=0;i<sizeM;i++){
			if(eval('document.form0.chkMed'+i).checked){
				var med = eval('document.form0.medicamento'+i).value;
								var a = med.split("/");
								if(x) searchText+='&';
								searchText += 'mainSearchConcept=^^^^'+a[0].trim();
				x=true;
			}
		}
	} else if(flag=='DI'){
		for(i=0;i<sizeDI;i++){
			if(eval('document.form0.chkDiagIn'+i).checked){
				if(x) searchText+='&';
				searchText += 'mainSearchConcept=^^^^'+ eval('document.form0.diagnosticoDescI'+i).value;
				x=true;
			}
		}
	} else if(flag=='DO'){
		for(i=0;i<sizeDO;i++){
			if(eval('document.form0.chkDiagOut'+i).checked){
				if(x) searchText+='&';
				searchText += 'mainSearchConcept=^^^^'+ eval('document.form0.diagnosticoDescO'+i).value;
				x=true;
			}
		}
	}
	
	if(!x) alert('Seleccione al menos 1 Item!');
	else {
		if(application=='ProblemList') {
			url = '<%=urlCarnotes%>?'+searchText+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
			window.top.showPopWin(url,winWidth*.75,winHeight*.80,null,null,'');
		} else {
			url = '<%=urlCarnotes%>?'+searchText+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
			window.top.showPopWin(url,winWidth*.75,winHeight*.80,null,null,'');
		}
	}
}

function chkAll(flag){
var sizeM = <%=alMed.size()%>;
var sizeDI = <%=alDiag.size()%>;
var sizeDO = <%=alDiagSal.size()%>;
	if(flag=='M'){
		for(i=0;i<sizeM;i++){
			eval('document.form0.chkMed'+i).checked = document.form0.chkAllMed.checked;
		}
	} else if(flag=='DI'){
		for(i=0;i<sizeDI;i++){
			eval('document.form0.chkDiagIn'+i).checked = document.form0.chkAllDiagIn.checked;
		}
	} else if(flag=='DO'){
		for(i=0;i<sizeDO;i++){
			eval('document.form0.chkDiagOut'+i).checked = document.form0.chkAllDiagOut.checked;
		}
	}
}


//window.top.showPopWin('http://www.thomsonhc.com/infobutton/librarian/access?mainSearchConcept='+a[0].trim()+'^I9^HL70396^^&applicationContext='+application+'^HL7IBAppContext^^^&institution= Infovision%20Solutions^INFOSOL^T157047&contentTarget=C^HL70242^^^&responseFormat=html&language=spa',winWidth*.75,winHeight*.80,null,null,'');
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr class="TextRow01">
		<td colspan="4" align="right"> <!-----> </td>
	</tr>
	<tr>
		<td colspan="4">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("desc",desc)%>
				<tr>
					<td colspan="2" align="center" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%" align="center" >&nbsp;<cellbytelabel id="1">Medicamentos y Diagn&oacute;sticos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
          <td valign="top" width = "50%" class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="TextHeader">
                <td align="center" colspan="3"><cellbytelabel id="2">MEDICAMENTOS</cellbytelabel></td>
								<td align="center" colspan="3"><%=fb.button("medcarenotes","Carenotes",false,viewMode,null,null,"onClick=\"javascript:getCarenotes('MedicationList', 'M','D')\"")%>
					</td></td>
							</tr>
							<tr class="TextHeader02">
								<td width="3%" align="center"><%=fb.checkbox("chkAllMed","",false,false, "", "", "onClick=\"javascript:chkAll('M')\"")%></td>
                <td width="10%" align="center"><cellbytelabel id="3">FECHA</cellbytelabel></td>
                <td width="57%" align="center"><cellbytelabel id="4">MEDICAMENTO</cellbytelabel></td>
                <td width="15%" align="center"><cellbytelabel id="5">VIA</cellbytelabel></td>
                <td width="12%" align="center"><cellbytelabel id="6">FRECUENCIA</cellbytelabel></td>
								<td width="3%" align="center">&nbsp;</td>
              </tr>
              <%
							//ProblemList
							for (int i=0; i<alMed.size(); i++)
							{
								CommonDataObject cd = (CommonDataObject) alMed.get(i);
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("medicamento"+i,cd.getColValue("medicamento"))%>
              <tr class="<%=color%>">
                <td><%=fb.checkbox("chkMed"+i,""+i,false,false, "", "", "")%></td>
								<td><%=cd.getColValue("fechamedica")%></td>
                <td><%=cd.getColValue("medicamento")%></td>
                <td align="center"><%=cd.getColValue("descVia")%></td>
                <td align="center"><%=cd.getColValue("descFrecuencia")%></a></td>
								<td align="center"><a href="javascript:showInfoMicromedex('MedicationList', '<%=cd.getColValue("medicamento")%>','D')"><img height="20" width="20" class="ImageBorder" src="../images/but_orange.png"></a></td>
              </tr>
							<%}%>
            </table></td>
						<td valign = "top" width = "50%" class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="TextHeader">
                <td align="center" colspan="3"><cellbytelabel id="7">DIAGNOSTICOS DE INGRESO</cellbytelabel></td>
								<td align="center" colspan="2"><%=fb.button("ingdcarenotes","Carenotes",false,viewMode,null,null,"onClick=\"javascript:getCarenotes('ProblemList', 'DI','C')\"")%></td>
							</tr>
							<tr class="TextHeader02">
								<td width="3%" align="center"><%=fb.checkbox("chkAllDiagIn","",false,false, "", "", "onClick=\"javascript:chkAll('DI')\"")%></td>
                <td width="10%" align="center"><cellbytelabel id="8">CODIGO</cellbytelabel></td>
                <td width="74%" align="center"><cellbytelabel id="9">NOMBRE</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel id="10">PRIORIDAD</cellbytelabel></td>
								<td width="3%" align="center">&nbsp;</td>
              </tr>
              <%
							for (int i=0; i<alDiag.size(); i++)
							{
								CommonDataObject cd = (CommonDataObject) alDiag.get(i);
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("diagnosticoI"+i,cd.getColValue("diagnostico"))%>
							<%=fb.hidden("diagnosticoDescI"+i,cd.getColValue("diagnosticoDesc"))%>
              <tr class="<%=color%>">
								<td><%=fb.checkbox("chkDiagIn"+i,""+i,false,false, "", "", "")%></td>
                <td><%=cd.getColValue("diagnostico")%></td>
                <td><%=cd.getColValue("diagnosticoDesc")%></td>
                <td align="center"><%=cd.getColValue("orden_diag")%></td>
								<td align="center"><a href="javascript:showInfoMicromedex('ProblemList', '<%=cd.getColValue("diagnostico")%>','C')"><img alt="Buscar por ICD 9" height="20" width="20" class="ImageBorder" src="../images/but_orange.png"></a><a href="javascript:showInfoMicromedex('ProblemList', '<%=cd.getColValue("diagnosticoDesc")%>','D')"><img alt="Buscar por Descripcion" height="20" width="20" class="ImageBorder" src="../images/but_red.png"></a></td>
              </tr>
							<%}%>
							<tr class="TextHeader">
                <td align="center" colspan="3"><cellbytelabel id="11">DIAGNOSTICOS DE SALIDA</cellbytelabel></td>
								<td align="center" colspan="2"><%=fb.button("egrdcarenotes","Carenotes",false,viewMode,null,null,"onClick=\"javascript:getCarenotes('ProblemList', 'DO','C')\"")%></td>
							</tr>
							<tr class="TextHeader02">
								<td width="3%" align="center"><%=fb.checkbox("chkAllDiagOut","",false,false, "", "", "onClick=\"javascript:chkAll('DO')\"")%></td>
                <td width="10%" align="center"><cellbytelabel id="8">CODIGO</cellbytelabel></td>
                <td width="74%" align="center"><cellbytelabel id="9">NOMBRE</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel id="10">PRIORIDAD</cellbytelabel></td>
								<td width="3%" align="center">&nbsp;</td>
              </tr>
              <%
							for (int i=0; i<alDiagSal.size(); i++)
							{
								CommonDataObject cd = (CommonDataObject) alDiagSal.get(i);
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("diagnosticoO"+i,cd.getColValue("diagnostico"))%>
							<%=fb.hidden("diagnosticoDescO"+i,cd.getColValue("diagnosticoDesc"))%>
              <tr class="<%=color%>">
								<td><%=fb.checkbox("chkDiagOut"+i,""+i,false,false, "", "", "")%></td>
                <td><%=cd.getColValue("diagnostico")%></td>
                <td><%=cd.getColValue("diagnosticoDesc")%></td>
                <td align="center"><%=cd.getColValue("orden_diag")%></td>
								<td align="center"> <a href="javascript:showInfoMicromedex('ProblemList', '<%=cd.getColValue("diagnostico")%>','C')"><img alt="Buscar por ICD 9" height="20" width="20" class="ImageBorder" src="../images/info_icon.png"></a> <a href="javascript:showInfoMicromedex('ProblemList', '<%=cd.getColValue("diagnosticoDesc")%>','D')"><img alt="Buscar por Descripcion height="20" width="20" class="ImageBorder" src="../images/info_icon.png"></a> </td> 
              </tr>
							<%}%>
            </table></td>
        </tr>
				<tr>
					<td colspan="2" align="center" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%" align="center" >&nbsp;<cellbytelabel id="12">Laboratorios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
          <td width = "50%" class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="TextHeader">
                <td align="center" colspan="6"><cellbytelabel id="13">LABORATORIOS</cellbytelabel></td>
							</tr>
							<tr class="TextHeader02">
								<td width="3%" align="center">&nbsp;</td>
                <td width="10%" align="center"><cellbytelabel id="8">CODIGO</cellbytelabel></td>
                <td width="57%" align="center"><cellbytelabel id="14">DESCRIPCION</cellbytelabel></td>
								<td width="3%" align="center">&nbsp;</td>
              </tr>
            </table></td>
						<td valign = "top" width = "50%" class="TableBorder"></td>
        </tr>
	</td>
</tr>
</table>

</body>
</html>
<%
}
%>
