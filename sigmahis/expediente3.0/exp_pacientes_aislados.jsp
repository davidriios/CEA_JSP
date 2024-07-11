<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
String appendFilter = "";
ArrayList al = new ArrayList();
int rowCount = 0;
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String company = (String) session.getAttribute("_companyId");

String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String nombrePaciente = request.getParameter("nombre_paciente");
String cedula = request.getParameter("cedula");
String fechaDesde = request.getParameter("fdesde");
String fechaHasta = request.getParameter("fhasta");

Hashtable iAislamientos = new Hashtable();
iAislamientos.put("0", "Orientación al paciente y familiar");
iAislamientos.put("1", "Paciente con Aislamiento de Contacto");
iAislamientos.put("2", "Coordinación con la enfermera de nosocomial");
iAislamientos.put("3", "Paciente Con Aislamiento de Gotas");
iAislamientos.put("4", "Colocación del equipo de protección");
iAislamientos.put("5", "Paciente con Aislamiento Respiratorio (Gotitas)");
iAislamientos.put("6", "Otros");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		int recsPerPage = 50;
		String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

		if (request.getParameter("searchQuery") != null){
				nextVal = request.getParameter("nextVal");
				previousVal = request.getParameter("previousVal");
				if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
				if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
				if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
				if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
				if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
				if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
		}

		if (pacId == null) pacId = "";
		if (noAdmision == null) noAdmision = "";
		if (nombrePaciente == null) nombrePaciente = "";
		if (cedula == null) cedula = "";
		if (fechaDesde == null) fechaDesde = cDate;
		if (fechaHasta == null) fechaHasta = cDate;

		StringBuffer sb = new StringBuffer();

		sb.append("select p.pac_id, a.secuencia as admision, p.nombre_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, p.id_paciente as cedula, to_char(a.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, to_char(c.fecha_creacion, 'dd/mm/yyyy') fecha_aislamiento");

		sb.append(", (select cc.descripcion||'            (CAMA: '||(select aa.cama from tbl_adm_atencion_cu aa where aa.pac_id = a.pac_id and aa.secuencia = a.secuencia )||')' from tbl_cds_centro_servicio cc where codigo = (select aa.cds from tbl_adm_atencion_cu aa where aa.pac_id = a.pac_id and aa.secuencia = a.secuencia ) ) centroServicioDesc");

		sb.append(" from vw_adm_paciente p, tbl_adm_admision a, tbl_sal_cuestionarios c where p.pac_id = a.pac_id and a.pac_id = c.pac_id and a.secuencia = c.admision and c.tipo_cuestionario = 'C1' and trunc(c.fecha_creacion) between to_date('");
		sb.append(fechaDesde);
		sb.append("', 'dd/mm/yyyy') and to_date('");
		sb.append(fechaHasta);
		sb.append("', 'dd/mm/yyyy') ");

		if (!nombrePaciente.trim().equals("")) {
				sb.append(" and p.nombre_paciente like '%");
				sb.append(nombrePaciente);
				sb.append("%'");
		}

		if (!cedula.trim().equals("")) {
				sb.append(" and p.id_paciente = '");
				sb.append(cedula);
				sb.append("'");
		}

		if (!pacId.trim().equals("")) {
				sb.append(" and c.pac_id = ");
				sb.append(pacId);

				if (!noAdmision.trim().equals("")) {
						sb.append(" and c.admision = ");
						sb.append(noAdmision);
				}
		}

		sb.append(" order by c.fecha_creacion");

		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sb.toString()+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sb.toString()+")");

		if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var forceCapitalize=true;
$(function(){
		$("#fdesde,#fhasta").css('width', '90px');
});

function printExp() {
		abrir_ventana('../expediente3.0/print_pacientes_aislados.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombre_paciente=<%=nombrePaciente%>&cedula=<%=cedula%>&fdesde=<%=fechaDesde%>&fhasta=<%=fechaHasta%>');
}
</script>
</head>
<body class="body-form" style="padding-top: 0 !important;">
<div class="row">
		<div class="table-responsive" data-pattern="priority-columns" style="margin:10px auto">
				<table cellspacing="0" width="100%" class="table table-bordered table-striped">
						<tr class="bg-headtabla2">
								<td width="90%">PACIENTES AISLADOS</td>
								<td align="center">
										<a href="javascript:printExp()" class="btn btn-inverse btn-sm"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></a>
								</td>
						</tr>
				</table>

				<table width="99%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean2("search00",request.getContextPath()+request.getServletPath());%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

				<tr>
						<td class="controls form-inline">
								<b>PID:</b>
								<%=fb.textBox("pacId","",false,false,false,5,"form-control input-sm",null,null)%>
								- <%=fb.textBox("noAdmision","",false,false,false,2,"form-control input-sm",null,null)%>
								&nbsp;&nbsp;&nbsp;
								<b>Nombre:</b>
								<%=fb.textBox("nombre_paciente","",false,false,false,40,"form-control input-sm",null,null)%>
								&nbsp;&nbsp;&nbsp;
								<b>C&eacute;dula:</b>
								<%=fb.textBox("cedula","",false,false,false,7,"form-control input-sm",null,null)%>

								&nbsp;&nbsp;&nbsp;
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2"/>
										<jsp:param name="format" value="dd/mm/yyyy"/>
										<jsp:param name="nameOfTBox1" value="fdesde" />
										<jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
										<jsp:param name="nameOfTBox2" value="fhasta" />
										<jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
								</jsp:include>

								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<%=fb.submit("go","IR",true,false,"btn btn-inverse btn-sm",null,null)%>
						</td>
				</tr>

				<%=fb.formEnd()%>
			 </table>

						<table cellspacing="0" width="100%" class="table table-bordered table-striped">
								<tr>
										<td colspan="5">
												<table align="center" width="100%" cellpadding="1" cellspacing="0">
														<tr class="TextPager">
<%fb = new FormBean2("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("nombre_paciente",nombrePaciente)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("fhasta",fechaHasta)%>
<%=fb.hidden("fdesde",fechaDesde)%>
																<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
																<td width="40%"><b><cellbytelabel id="3">&nbsp;Total Registro(s)</cellbytelabel> <%=rowCount%></b></td>
																<td width="40%" align="right"><b><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></b>&nbsp;</td>
<%fb = new FormBean2("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("nombre_paciente",nombrePaciente)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("fhasta",fechaHasta)%>
<%=fb.hidden("fdesde",fechaDesde)%>
																<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
														</tr>
												</table>
										</td>
								</tr>

								<tr class="bg-headtabla">
										<td>PID</td>
										<td>Nombre</td>
										<td>F.Nac.</td>
										<td>F.Ingreso</td>
										<td>F.Aislamiento</td>
								</tr>
								<%

								for (int i = 0; i < al.size(); i++){%>
										<%cdo = (CommonDataObject) al.get(i);

												String tipoAislamientos = "";
												Properties prop = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+cdo.getColValue("pac_id")+" and admision="+cdo.getColValue("admision"));
												if (prop == null) prop = new Properties();

												for (int a = 0; a < 8; a++) {
														if (prop.getProperty("aislamiento_det"+a) != null && !"".equals(prop.getProperty("aislamiento_det"+a)) ) tipoAislamientos += ( iAislamientos.get(prop.getProperty("aislamiento_det"+a)) + "<br>");
												}

												if (prop.getProperty("observacion27") != null && !"".equals(prop.getProperty("observacion27"))) tipoAislamientos = tipoAislamientos+"<br>"+prop.getProperty("observacion27");

												if (!tipoAislamientos.trim().equals("")){
								%>
										<tr>
												<td><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
												<td><%=cdo.getColValue("nombre_paciente")%></td>
												<td><%=cdo.getColValue("fecha_nacimiento")%></td>
												<td><%=cdo.getColValue("fecha_ingreso")%></td>
												<td><%=cdo.getColValue("fecha_aislamiento")%></td>
										</tr>
										<tr>
												<td colspan="5">
														<b>
																Ubicaci&oacute;n: <%=cdo.getColValue("centroServicioDesc"," ")%>
														<b>
												</td>
										</tr>
										<tr>
												<td colspan="5">
														<b><%=tipoAislamientos%><b>
												</td>
										</tr>
								<%}}%>
								<tr>
										<td colspan="5">
												<table align="center" width="100%" cellpadding="1" cellspacing="0">
														<tr class="TextPager">
<%fb = new FormBean2("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("nombre_paciente",nombrePaciente)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("fhasta",fechaHasta)%>
<%=fb.hidden("fdesde",fechaDesde)%>
																<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
																<td width="40%"><b><cellbytelabel id="3">&nbsp;Total Registro(s)</cellbytelabel> <%=rowCount%></b></td>
																<td width="40%" align="right"><b><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></b>&nbsp;</td>
<%fb = new FormBean2("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("nombre_paciente",nombrePaciente)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("fhasta",fechaHasta)%>
<%=fb.hidden("fdesde",fechaDesde)%>
																<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
														</tr>
												</table>
										</td>
								</tr>
						</table>
		</div>
</div>

</body>
</html>
<%
}
%>