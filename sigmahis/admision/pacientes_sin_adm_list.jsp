<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

int iconHeight = 48;
int iconWidth = 48;

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";

String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String status = request.getParameter("status");
String nextBd = request.getParameter("next_bd");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String nombre = request.getParameter("nombre");
String cedula = request.getParameter("cedula");
String pacId = request.getParameter("pac_id");

StringBuffer sbSql= new StringBuffer();

if (status == null) status = "";
if (nextBd == null) nextBd = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (nombre == null) nombre = "";
if (cedula == null) cedula = "";
if (pacId == null) pacId = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
    
    sbSql.append("select p.pac_id, p.codigo, p.nombre_paciente, p.id_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fn, p.edad, n.nacionalidad, p.estatus, p.residencia_direccion, decode(p.estatus,'I','INACTIVO','A','ACTIVO') estatus_desc from vw_adm_paciente p, tbl_sec_pais n ");
    
    if (!nextBd.equals("")){
      sbSql.append(" ,(select trunc(sysdate) + rownum - 1 as myday from dual connect by level <= ");
      sbSql.append(nextBd);
      sbSql.append(") d ");
      
       sbSql.append(" where to_char(d.myday,'MMDD') = to_char(p.fecha_nacimiento,'MMDD') and p.nacionalidad = n.codigo(+) and not exists (select null from tbl_adm_admision a where p.pac_id = a.pac_id) ");
    }
    else 
    sbSql.append(" where p.nacionalidad = n.codigo(+) and not exists (select null from tbl_adm_admision a where p.pac_id = a.pac_id)");
    
    if (!pacId.equals("")) {
      sbSql.append(" and p.pac_id = ");
      sbSql.append(pacId);
    }
    
    if (!status.equals("")) {
      sbSql.append(" and p.estatus = '");
      sbSql.append(status);
      sbSql.append("'");
    }
    if (!fechaNacimiento.equals("")) {
      sbSql.append(" and p.fecha_nacimiento = to_date('");
      sbSql.append(fechaNacimiento);
      sbSql.append("','dd/mm/yyyy')");
    }
    if (!cedula.trim().equals("")) {
      sbSql.append(" and p.id_paciente like '%");
      sbSql.append(cedula);
      sbSql.append("%'");
    }
    if (!nombre.trim().equals("")) {
      sbSql.append(" and p.nombre_paciente like '%");
      sbSql.append(nombre);
      sbSql.append("%'");
    }
    
    sbSql.append(" order by 3");
	
	if (request.getParameter("beginSearch") != null){
	 
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Admisión - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function setIndex(k){document.registros.index.value=k;}

function printList(){
  var i = $("#index").val();
  var pacId = $("#pac_id"+i).val() || 'ALL';
  var fechaNacimiento = $("#fecha_nacimiento").val() || 'ALL';
  var nextBd = $("#next_bd").val() || 'ALL';
  var nombre = $("#nombre").val() || 'ALL';
  var status = $("#status").val() || 'ALL';
  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/rpt_paciente_sin_adm.rptdesign&pacId='+pacId+'&status='+status+'&fechaNacimiento='+fechaNacimiento+'&nextBd='+nextBd+'&nombre='+nombre+'&pCtrlHeader=false');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ADMISION - PACIENTES SIN ADMISIONES"></jsp:param>
</jsp:include>


<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">
				<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("beginSearch","")%>
                <tr class="Text">
                  <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="11">Imprimir Lista</cellbytelabel> ]</a></authtype></td>
                </tr>
			<tr class="TextFilter">
				<td colspan="4">Estado:&nbsp;<%=fb.select("status","A=ACTIVA,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				&nbsp;Fecha Nac.:&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fecha_nacimiento"/>
						<jsp:param name="valueOfTBox1" value="<%=fechaNacimiento%>"/>
						<jsp:param name="clearOption" value="true"/>
					</jsp:include>
               &nbsp;Nombre:&nbsp;<%=fb.textBox("nombre",nombre,false,false,false,30)%>
               &nbsp;Cumplirá en:&nbsp;
               <%=fb.select("next_bd","7=Una semana,15=15 días,30=Un mes,60=Dos meses,90=Tres meses",nextBd,false,false,0,"Text10",null,null,null,"T")%>
               <%=fb.submit("go","Ir")%></td>
			</tr>
			<%=fb.formEnd(true)%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("next_bd",nextBd)%>
				<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
				<%=fb.hidden("nombre",""+nombre)%>
                <%=fb.hidden("beginSearch","")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("next_bd",nextBd)%>
				<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
				<%=fb.hidden("nombre",""+nombre)%>
                <%=fb.hidden("beginSearch","")%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<%fb = new FormBean("registros",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">PID-C&oacute;digo</td>
			<td width="25%">Nombre del Paciente</td>
			<td width="10%">C&eacute;dula</td>
			<td width="10%">Fecha Nac.</td>
			<td width="5%">Edad</td>
			<td width="10%">Nacionalidad</td>
			<td width="20%">Direcci&oacute;n</td>
			<td width="7%">Estado</td>
			<td width="3%">&nbsp;</td>
		</tr>
 <!--Inserte Grilla Aqui -->
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
    <%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
        <td align="center"><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("codigo")%></td>
        <td>&nbsp;<%=cdo.getColValue("nombre_paciente")%></td>
        <td align="center">&nbsp;<%=cdo.getColValue("id_paciente")%></td>
        <td align="center"><%=cdo.getColValue("fn")%></td>
        <td align="center"><%=cdo.getColValue("edad")%></td>
        <td align="center"><%=cdo.getColValue("nacionalidad")%></td>
        <td><%=cdo.getColValue("residencia_direccion")%></td>
        <td align="center"><%=cdo.getColValue("estatus_desc")%></td>
        <td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
    </tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
		</table>
	<%=fb.formEnd()%>
</div>
</div>
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
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("next_bd",nextBd)%>
				<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
				<%=fb.hidden("nombre",""+nombre)%>
                <%=fb.hidden("beginSearch","")%>
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
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
				<%=fb.hidden("next_bd",nextBd)%>
				<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
				<%=fb.hidden("nombre",""+nombre)%>
                <%=fb.hidden("beginSearch","")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%}%>
