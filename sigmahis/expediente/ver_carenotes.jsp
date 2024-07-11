<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
CommonDataObject cdo = new CommonDataObject();

String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String noAdmision = request.getParameter("noAdmision");
String pacId = request.getParameter("pacId");
String urlCarnotes ="";
if(fg==null) fg = "";
if(fp==null) fp = "";
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
sbSql.append("select get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'EXP_URL_CARNOTES') as urlCarnotes from dual ");
		cdo = SQLMgr.getData(sbSql.toString());
sbSql = new StringBuffer();
if(cdo ==null)cdo = new CommonDataObject();	
urlCarnotes = cdo.getColValue("urlCarnotes");
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/autocomplete_header.jsp"%>
<script language="javascript">
document.title = 'CARENOTES - '+document.title;

function setValues(){
var noAdmision = '<%=noAdmision%>';
var pacId = '<%=pacId%>';
var patientName = document.paciente.nombrePaciente.value;
var caregiverName = document.paciente.medicoCabecera.value+ ' - '+document.paciente.nombreMedicoCabecera.value;
if (document.paciente.medicoCabecera.value == '') caregiverName = document.paciente.medico.value+ ' - '+document.paciente.nombreMedico.value;

var cedula = document.paciente.cedulaPasaporte.value;
var fingreso = document.paciente.fechaIngreso.value;
var areaadm = document.paciente.cds.value+ ' - '+document.paciente.cdsDesc.value;
var searchText = document.form1.searchText.value;
var application = document.form1.application.value;//http://www.thomsonhc.com/infobutton/librarian/access?mainSearchConcept='+a[0].trim()+'^I9^HL70396^^&applicationContext='+application+'^HL7IBAppContext^^^&institution= Infovision%20Solutions^INFOSOL^T157047&contentTarget=C^HL70242^^^&responseFormat=html&language=spa
	if(searchText=='') alert('Introduzca valor a buscar!');
	else {
		if(application=='ProblemList') {
			//url = 'http://hpplabcore:9090/ips/SessionServlet1?mainSearchConcept=^^^^'+searchText.trim()+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
			url = '<%=urlCarnotes%>?mainSearchConcept=^^^^'+searchText.trim()+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
		} else if(application=='ProblemCode'){
			url = '<%=urlCarnotes%>?mainSearchConcept='+searchText.trim()+'^ICD9^HL70396^^&applicationContext=ProblemList^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
		}else{
			//url = 'http://hpplabcore:9090/ips/SessionServlet1?mainSearchConcept=^^^^'+searchText.trim()+'&applicationContext='+application+'^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
			url = '<%=urlCarnotes%>?mainSearchConcept=^^^^'+searchText.trim()+'&applicationContext=MedicationList^HL7IBAppContext^^^&institution=HPP^HOSPPP^T152421&responseFormat=html&docType=(All)&locationName=HPP&patient_name='+patientName+'&mrn='+pacId+' - '+noAdmision+'&pid='+pacId+'&caregiverName='+caregiverName+'&cedula='+cedula+'&fingreso='+fingreso+'&department='+areaadm;
		} 
		window.frames['itemFrame'].location = url;
	}	
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARENOTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
							<tr class="">
                <td align="left"><img class="" src="../images/lgc.png"></td>
								<td align="right"><img class="" src="../images/micromedex.gif"></td>
              </tr>
							<tr>
                <td colspan="2">
								<jsp:include page="../common/paciente.jsp" flush="true">
								<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
								<jsp:param name="fp" value="expediente"></jsp:param>
								<jsp:param name="mode" value="view"></jsp:param>
								<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
								</jsp:include>
								</td>
							</tr>
							<tr>
                <td colspan="2"><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath());%>
                    <%=fb.formStart(true)%>
										<%=fb.hidden("mode",mode)%>
										<%=fb.hidden("fg",fg)%>
										<%=fb.hidden("fp",fp)%>
										<%=fb.hidden("clearHT","")%>
										<%=fb.hidden("noAdmision",noAdmision)%>
										<%=fb.hidden("pacId",pacId)%>
										<%=fb.hidden("fecha",fecha)%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                      		
													<!--
													<tr class="">
                            <td align="right"><img class="" src="../images/carenotes_logo.gif"></td>
                          </tr>
													-->
                          <tr class="TextRowYell">
                            <td width="15%"><cellbytelabel id="1">Buscar</cellbytelabel>
					<%=fb.select("application","MedicationList=Medicamentos,ProblemList=Diagnosticos,ProblemCode=ICD9 Code","",false,false,0,"Text10",null,null,"","")%></td><td width="65%" class="RedText Text14">
                    					<jsp:include page="../common/autocomplete.jsp" flush="true">
										<jsp:param name="fieldId" value="searchText"/>
										<jsp:param name="fieldValue" value=""/>
										<jsp:param name="fieldIsRequired" value="y"/>
										<jsp:param name="fieldIsReadOnly" value="n"/>
										<jsp:param name="fieldClass" value="RedText10"/>
										<jsp:param name="containerSize" value="110%"/>
										<jsp:param name="maxDisplay" value="30"/>
										<jsp:param name="minChars" value="3"/>
										<jsp:param name="containerFormat" value="@@id - @@description"/>
										<jsp:param name="dsType" value="TRANSLATE"/>
										<jsp:param name="dsMatchBy" value="id"/>
										<jsp:param name="matchContains" value="y"/>
									</jsp:include></td><td width="10%">&nbsp;&nbsp;
					  			<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:setValues();\"")%>
                            </td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="450" scrolling="yes" src=""></iframe></td>
                    </tr>
										<%fb.appendJsValidation("setValues();error++;");%>
                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>
