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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100027") || SecMgr.checkAccess(session.getId(),"100028") || SecMgr.checkAccess(session.getId(),"100029") || SecMgr.checkAccess(session.getId(),"100030"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");


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


		if (request.getParameter("recibo") != null)
		{
			appendFilter += " and upper(b.codigo) like '%"+request.getParameter("recibo").toUpperCase()+"%'";
	
		searchOn = "b.codigo";
		searchVal = request.getParameter("recibo");
		searchType = "1";
		searchDisp = "Recibo";
		}
		else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
		{
		  if (searchType.equals("1"))
		  {
				appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		  }
		}
		else
		{
		  searchOn="SO";
		  searchVal="Todos";
		  searchType="ST";
		  searchDisp="Listado";
		}

	
	

  sql = "select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as cedula,b.pasaporte, a.compania, a.pac_id as pacId, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente, substr(c.descripcion,0,4)||'.' as categoriaDesc, a.centro_servicio as centroServicio, d.descripcion as centroServicioDesc from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d where a.pac_id=b.pac_id and a.categoria=c.codigo and a.centro_servicio=d.codigo and ((a.compania = 1 and a.tipo_admision = 6 and a.categoria = 2 and a.estado = 'A')  or (a.compania = 10 and a.tipo_admision = 8 and a.categoria = 2 and a.estado in ('A','S')) ) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by nvl(a.fecha_ingreso,a.fecha_creacion) desc, nombrePaciente, a.secuencia";
  al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c  where a.pac_id=b.pac_id and a.categoria=c.codigo and ((a.compania = 1 and a.tipo_admision = 6 and a.categoria = 2 and a.estado = 'A')  or (a.compania = 10 and a.tipo_admision = 8 and a.categoria = 2 and a.estado in ('A','S')) ) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);

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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inactivar Admisión Hemodiálisis - '+document.title;
function printList()
{
	abrir_ventana('../admision/print_list_inac_adm_hemodialisis.jsp');
}

function getMain(formx)
{
	formx.status.value = document.search00.status.value;
	return true;
}

function inactivar(){
var error = 0;
var v_fecha ='<%=cDateTime%>';
if(confirm("¿ DESEA ACTUALIZAR EL ESTATUS DE LAS ADMISIONES ?"))
{
			if(executeDB('<%=request.getContextPath()%>','UPDATE tbl_adm_admision SET ESTADO = \'E\', FECHA_EGRESO =  to_date(\''+v_fecha+'\',\'dd/mm/yyyy hh12:mi:ss am\') WHERE ((compania = 1 and TIPO_ADMISION = 6 AND CATEGORIA = 2 AND ESTADO = \'A\')or(compania =10 and tipo_admision = 8 and categoria = 2 and  ESTADO in( \'A\', \'S\'))) and compania = <%=(String) session.getAttribute("_companyId")%>'))
			//if(executeDB('<%=request.getContextPath()%>','UPDATE tbl_adm_admision SET ESTADO = \'E\', FECHA_EGRESO =  to_date(\''+v_fecha+'\',\'dd/mm/yyyy hh12:mi:ss am\') WHERE TIPO_ADMISION = 6 AND CATEGORIA = 2 AND ESTADO = \'A\''))
			{
			} else { 
				error++;
			}  
	
	if(error>0){ CBMSG.warning('Error al Inactivar las admisiones'); }
	else {CBMSG.warning('LAS ADMISIONES HAN SIDO ACTUALIZADAS');}
	window.location.reload(true);
}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INACTIVAR ADMISIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
    <td align="right">&nbsp;
				<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
		</td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("fp",fp)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("fp",fp)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("form1",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("rows",""+al.size())%>
	<tr class="TextHeader">
	    <td width="5%">&nbsp;</td>
		<td width="28%">&nbsp;Paciente</td>
		<td width="13%">&nbsp;Fecha de Nac.</td>
		<td width="5%">&nbsp;No.</td>
		<td width="8%">&nbsp;Admisi&oacute;n</td>
		<td width="5%">&nbsp;Estado</td>
		<td width="15%">&nbsp;C&eacute;dula</td>
		<td width="12%">&nbsp;Pasaporte</td>
		<td width="9%" align="center">
        <%=fb.button("inactivar1","Inactivar",false,false,null,null,"onClick=\"javascript:inactivar();\"")%>
</td>
	</tr>


<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver','TextRow01')" onMouseOut="setoutc(this,'<%=color%>')">
	<%=fb.hidden("v_fecha_nacimiento"+i,cdo.getColValue("fechaNacimiento"))%>
    <%=fb.hidden("p_codigo_paciente"+i,cdo.getColValue("codigoPaciente"))%>
    <%=fb.hidden("p_admision"+i,cdo.getColValue("noAdmision"))%>
    <td align="center">&nbsp;<%=preVal + i%></td>
    <td><%=cdo.getColValue("nombrePaciente")%></td>
    <td>&nbsp;<%=cdo.getColValue("fechaNacimiento")%></td>
    <td>&nbsp;<%=cdo.getColValue("codigoPaciente")%></td>
    <td>&nbsp;<%=cdo.getColValue("noAdmision")%></td>
    <td>&nbsp;<%=cdo.getColValue("estado")%></td>
    <td>&nbsp;<%=cdo.getColValue("cedula")%></td>
    <td>&nbsp;<%=cdo.getColValue("pasaporte")%></td>
    <td>&nbsp;</td>
</tr>
<% } %>

<%=fb.formEnd()%>
</table>
	<!-- ================================       E N D  R E S U L T S              ================================ -->
		</td>
	</tr>		
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("fp",fp)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("fp",fp)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>