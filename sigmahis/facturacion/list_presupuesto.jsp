<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
consulta de notas de ajustes
fp = REV  = reversion de incobrable
FP= CS = CONSULTA DE AJUSTES
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sql = new StringBuffer();
StringBuffer apFilter = new StringBuffer();
String sqlCds = "";
String fp = request.getParameter("fp");
int iconHeight = 40;
int iconWidth = 40;
if(fp == null)fp="";
  
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

	String medico = "",nombre_medico="",fecha_hasta="",fecha_desde="",procedimiento="", sexo="";
	if(request.getParameter("medico")!=null)medico = request.getParameter("medico");
	if(request.getParameter("nombre_medico")!=null)nombre_medico = request.getParameter("nombre_medico");
	if(request.getParameter("procedimiento")!=null)procedimiento = request.getParameter("procedimiento");
	if(request.getParameter("fecha_desde")!=null)fecha_desde = request.getParameter("fecha_desde");
	if(request.getParameter("fecha_hasta")!=null)fecha_hasta = request.getParameter("fecha_hasta");
	if(request.getParameter("sexo")!=null)sexo = request.getParameter("sexo");
	if(!medico.equals("")) { apFilter.append(" and exists (select null from tbl_adm_medico where codigo = a.cod_medico and nvl(reg_medico,cod_medico) = '"); apFilter.append(medico); apFilter.append("')"); }
	if(!procedimiento.equals("")){ apFilter.append(" and (a.observacion like '%");apFilter.append(procedimiento);apFilter.append("%' or (exists (select null from tbl_cdc_cita_procedimiento cp where cp.cod_cita = a.codigo and cp.fecha_cita = a.fecha_registro and exists (select null from tbl_cds_procedimiento p where p.codigo = cp.procedimiento and (descripcion like '%");apFilter.append(procedimiento);apFilter.append("%' or observacion like '%");apFilter.append(procedimiento);apFilter.append("%')))))");}
	if(!sexo.equals("")){ apFilter.append(" and exists (select null from tbl_adm_paciente p where p.pac_id = a.pac_id and p.sexo = '");apFilter.append(sexo);apFilter.append("')");}
	if(!fecha_desde.equals("") && !fecha_hasta.equals("")){ apFilter.append(" and exists (select null from tbl_adm_admision ad where ad.pac_id = a.pac_id and ad.secuencia = a.admision and ad.fecha_ingreso between to_date('");apFilter.append(fecha_desde);apFilter.append("', 'dd/mm/yyyy') and to_date('");apFilter.append(fecha_hasta);apFilter.append("', 'dd/mm/yyyy'))");}

	
  sql.append("select a.codigo, to_char (a.fecha_registro, 'dd/mm/yyyy') as fecharegistro, nvl (to_char (a.fec_nacimiento, 'dd/mm/yyyy'), ' ') as fecnacimiento, a.cod_paciente as codpaciente, cod_medico codmedico, nvl (nombre_medico, (select aa.primer_apellido || decode (aa.segundo_apellido, null, '', ' ' || aa.segundo_apellido) || ' ' || decode ( aa.sexo, 'F', decode (aa.apellido_de_casada, null, '', ' ' || aa.apellido_de_casada)) from tbl_adm_medico aa where aa.codigo = a.cod_medico)) as mediconombre, a.centro_servicio as centroservicio, a.cod_tipo as codtipo, a.estado_cita as estadocita, nvl (a.motivo_cita, ' ') as motivocita, nvl (a.anestesia, ' ') as anestesia, nvl (a.observacion, ' ') as observacion, nvl (a.habitacion, ' ') as habitacion, decode (a.pac_id, null, nvl (a.nombre_paciente, ''), (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombrepaciente, nvl (to_char (a.pac_id), '') as pac_id, nvl (probable_hospitalizacion, ' ') as probablehospitalizacion, a.nombre_medico_externo nombremedexterno, a.admision  from tbl_sal_habitacion sh, tbl_cdc_cita a where sh.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and sh.codigo = a.habitacion and sh.quirofano = 2 and exists (select null from tbl_adm_admision ad where ad.estado = 'I' and ad.secuencia = a.admision and ad.pac_id = a.pac_id)");
	sql.append(apFilter.toString());
	
	if(!medico.equals("") || !procedimiento.equals("") || !fecha_desde.equals("") || !fecha_hasta.equals("") || !sexo.equals("")){
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	}
	 
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
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Listado de Notas de Ajustes- '+document.title;
function printList(){
abrir_ventana('../facturacion/print_list_notas_ajustes_cargo.jsp?fg=CS&apFilter=<%=IBIZEscapeChars.forURL(apFilter.toString())%>');
}
function printExcel(){
	var admisiones = document.search01.test.value;
abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_presupuesto.rptdesign&adminParam='+admisiones);	
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
//function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function clearMedico(){document.search01.medico.value='';document.search01.nombre_medico.value='';}
function showMedicoList(fg){abrir_ventana1('../common/search_medico.jsp?fp=presupuesto&fg='+fg);}
function addAdm(id){
	var admisiones = document.search01.test.value;
	var admin = eval('document.form0.adm'+id).value
	if(eval('document.form0.check'+id).checked) admisiones += ', '+admin; 
	else admisiones = admisiones.replace(', '+admin, '');
	document.search01.test.value = admisiones;
}
function print_cargos(pacId, noAdmision){
abrir_ventana('../facturacion/print_cargo_dev_neto.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="NOTAS AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">

<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<tr class="TextFilter">
	<td width="60%">
		<cellbytelabel>Procedimiento</cellbytelabel>: <%=fb.textBox("procedimiento",procedimiento,false,false,false,40,"Text10",null,null)%>
	</td>
	<td width="40%">M&eacute;dico:
	<%=fb.textBox("medico",medico,false,false,false,4,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>								
	<%=fb.textBox("nombre_medico",nombre_medico,false,false,false,40,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>
	<%=fb.button("btnMedico","...",true,false,"Text10",null,"onClick=\"javascript:showMedicoList('dr_reserva')\"")%>
	</td>
</tr>
<tr class="TextFilter">
	<td colspan="2">Fecha:<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha_desde" />
				<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
				<jsp:param name="nameOfTBox2" value="fecha_hasta" />
				<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
				</jsp:include>
				Sexo Paciente:<%=fb.select("sexo","F=FEMENINO, M=MASCULINO",sexo,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.hidden("test","")%>
	<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
 <tr>
        <td align="right">&nbsp;
					<authtype type='0'><a href="javascript:printExcel()" class="Link00">[ <cellbytelabel>Excel</cellbytelabel> ]</a></authtype>
		</td>
 </tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%> 
					<%=fb.hidden("procedimiento",""+procedimiento)%>  
					<%=fb.hidden("medico",""+medico)%>  
					<%=fb.hidden("nombre_medico",""+nombre_medico)%>  
					<%=fb.hidden("fecha_desde",""+fecha_desde)%>  
					<%=fb.hidden("fecha_hasta",""+fecha_hasta)%>  
					<%=fb.hidden("sexo",""+sexo)%>  

					
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("procedimiento",""+procedimiento)%>  
					<%=fb.hidden("medico",""+medico)%>  
					<%=fb.hidden("nombre_medico",""+nombre_medico)%>  
					<%=fb.hidden("fecha_desde",""+fecha_desde)%>  
					<%=fb.hidden("fecha_hasta",""+fecha_hasta)%>  
					<%=fb.hidden("sexo",""+sexo)%>  
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
<tr>
  <td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	<!--<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">-->
		<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("index","")%>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="%"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
				<td width="%"><cellbytelabel>Procedimiento</cellbytelabel></td>
				<td width="%"><cellbytelabel>Paciente</cellbytelabel></td>
				<td width="%"><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
				<td width="5%">&nbsp;</td>
			</tr>
		<%
		for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
		%>
		<%=fb.hidden("adm"+i,cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="left"><%=cdo.getColValue("mediconombre")%></td>
			<td align="left"><%=cdo.getColValue("observacion")%></td>
			<td align="left"><%=cdo.getColValue("nombrepaciente")%></td>
			<td align="center" style="cursor:pointer;" onDblClick="javascript:print_cargos(<%=cdo.getColValue("pac_id")%>,<%=cdo.getColValue("admision")%>);"><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
			<td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:addAdm("+i+")\"")%></td>
		</tr>
		<% } %>
		</table>
		<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		<%=fb.formEnd()%>
	<!--</div>
	</div>-->
 </td>
</tr>
 	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("procedimiento",""+procedimiento)%>  
					<%=fb.hidden("medico",""+medico)%>  
					<%=fb.hidden("nombre_medico",""+nombre_medico)%>  
					<%=fb.hidden("fecha_desde",""+fecha_desde)%>  
					<%=fb.hidden("fecha_hasta",""+fecha_hasta)%>  
					<%=fb.hidden("sexo",""+sexo)%>  
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("procedimiento",""+procedimiento)%>  
					<%=fb.hidden("medico",""+medico)%>  
					<%=fb.hidden("nombre_medico",""+nombre_medico)%>  
					<%=fb.hidden("fecha_desde",""+fecha_desde)%>  
					<%=fb.hidden("fecha_hasta",""+fecha_hasta)%>  
					<%=fb.hidden("sexo",""+sexo)%>  
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>
