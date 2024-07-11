<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
int iconHeight = 48;
int iconWidth = 48;
int nRecs = 1000;

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

	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String paciente = request.getParameter("paciente");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");

	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (paciente == null) paciente = "";
	if (tDate == null) tDate = "";
	if (fDate == null) fDate = "";
	//if (!cedulaPasaporte.trim().equals("")) appendFilter += " and upper (a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
	if (!cedulaPasaporte.trim().equals("")) appendFilter += " and upper(coalesce(a.pasaporte,a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento)) like '%"+request.getParameter("cedulaPasaporte").toUpperCase()+"%'";
	if (!dob.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.fecha_nacimiento,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+dob+"','dd/mm/yyyy')";
	}
	
	if (!tDate.trim().equals("") && !fDate.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.fecha_registro,'dd/mm/yyyy'),'dd/mm/yyyy')>=to_date('"+tDate+"','dd/mm/yyyy')";
		appendFilter += " and to_date(to_char(a.fecha_registro,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date('"+fDate+"','dd/mm/yyyy')";
	}else if (!tDate.trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.fecha_registro,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+tDate+"','dd/mm/yyyy')";
	}
	if (!codigo.trim().equals(""))
	{
		appendFilter += " and a.codigo="+codigo;
	}
	if (!paciente.trim().equals("")) appendFilter += " and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||decode(a.primer_apellido,null,'',' '||a.primer_apellido)||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) like '%"+paciente.toUpperCase()+"%'";
	//if (!fDate.trim().equals("")) appendFilter += " and a.fecha_ingreso=to_date('"+fDate+"','dd/mm/yyyy')";

	StringBuffer sbSql = new StringBuffer();
	/* * * * *   C O L U M N S   * * * * */
	sbSql.append("select  distinct a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||decode(a.primer_apellido,null,'',' '||a.primer_apellido)||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada) as nombrePaciente, coalesce(a.pasaporte,a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) as cedulaPasaporte,a.codigo , to_char(a.fecha_nacimiento,'dd/mm/yyyy') fechaNacimiento , to_char(a.fecha_registro,'dd/mm/yyyy') fechaRegistro ,nvl(trunc(months_between(sysdate,a.fecha_nacimiento)/12),0) as edad /* a.f_p_p, a.g, a.p, a.a, a.c,  a.medico, a.fecha_registro, a.residencia_direccion, a.residencia_comunidad, a.residencia_corregimiento, a.residencia_distrito,  a.residencia_provincia, a.residencia_pais, a.telefono,  a.persona_de_urgencia, a.direccion_de_urgencia, a.telefono_urgencia,  a.identificacion_conyugue, a.nombre_conyugue, a.lugar_trabajo_conyugue,  a.telefono_trabajo_conyugue, a.conyugue_nacionalidad, a.tipo_sangre,  a.rh, a.usuario_adiciona, a.fecha_adiciona,  a.usuario_modifica, a.fecha_modifica, a.estatus,  a.edad, a.mes*/ FROM tbl_adm_monitoreo  a /* where codigo =2407*/ where a.primer_nombre is not null "+appendFilter+" order by nvl(a.fecha_adiciona,a.fecha_registro) desc ");
//if(!appendFilter.trim().equals(""))
//{
	
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
//}
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
document.title = 'Admision - '+document.title;

function activarExpediente()
{
}

function printList()
{
	abrir_ventana('../expediente/print_list_expediente.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&nRecs=<%=nRecs%>');
}

function doAction()
{
}
function setIndex(k)
{
	var id = eval('document.form01.codigo'+k).value;
	if(document.form01.index.value!=k)
	{
		document.form01.index.value=k;
		
		//getPatientDetails(k);
	}
		abrir_ventana('../admision/reg_monitoreos.jsp?mode=edit&id='+id);

}

function goOption(option)
{

}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Expediente';break;
		case 1:msg='Cargos / Devoluciones';break;
		case 2:msg='Honorario Médico';break;
		case 3:msg='Imprimir Informe Atención CU';break;
		case 4:msg='Imprimir Detalles de Cargos';break;
		case 5:msg='Cambiar Diagnóstico';break;
		case 6:msg='Activar Expediente';break;
		case 7:msg='Observaciones Administrativas';break;
		case 8:msg='Ver Expediente';break;
		case 9:msg='Plan de Cuidados';break;
		//case 10:msg='Imprimir Expediente';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}

function doSearch()
{
	document.main.submit();
}

function checkPendingOM()
{
}

function getPatientDetails(k)
{
	
}

function displayValue(k,type,value)
{
	//document.getElementById('lbl'+type+k).innerHTML=value;
}
function add()
{
	abrir_ventana('../admision/reg_monitoreos.jsp?mode=add');
}
function imprimirReporte()
{
	var tDate = eval('document.main.tDate').value;
	var fDate = eval('document.main.fDate').value;
	if(tDate==''||fDate=='')alert('Seleccione rango de Fecha');
	else abrir_ventana1('../admision/print_monitoreos.jsp?fp=monitoreos&tDate='+tDate+'&fDate='+fDate);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:imprimirReporte()" class="Link00">[ Generar Estadistica ]</a><a href="javascript:add()" class="Link00">[ Registrar Nuevo Monitoreo ]</a></authtype></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("main",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td colspan="2" class="Text10">&nbsp;</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2" class="Text10">
				C&oacute;digo.
				<%=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>
				C&eacute;dula/Pasaporte
				<%=fb.textBox("cedulaPasaporte","",false,false,false,15,"Text10",null,null)%>
				
				Paciente
				<%=fb.textBox("paciente","",false,false,false,40,"Text10",null,null)%>
				Fecha Ingreso
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="tDate" />
				<jsp:param name="valueOfTBox1" value="<%=tDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox2" value="fDate" />
				<jsp:param name="valueOfTBox2" value="<%=fDate%>" />
				</jsp:include>
				<!--jsp:param name="nameOfTBox2" value="tDate" /-->
				<!--jsp:param name="valueOfTBox2" value="<%=tDate%>" /-->
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
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
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

		<div id="expedienteMain" width="100%" style="overflow:scroll;position:relative;height:500">
		<div id="expediente" width="98%" style="overflow;position:absolute">
<%fb = new FormBean("form01","","");%>
<%=fb.formStart()%>
<%=fb.hidden("index","-1")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tbody id="list">
		<tr class="TextHeader" align="center">
			<td width="6%">Id.</td>
			<td width="50%">Nombre</td>
			<td width="7%">Fecha Nac.</td>
			<td width="13%">C&eacute;dula / Pasaporte</td>
			<td width="3%">Edad</td>
			<td width="9%">Fecha Ingreso</td>
			<td width="3%">&nbsp;Editar</td>
		</tr>
<%
int gExe = 0;
int gTot = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

%>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fechaNacimiento"))%>
<%=fb.hidden("codPac"+i,cdo.getColValue("codigoPaciente"))%>
<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombrePaciente")%></td>
			<td align="center"><%=cdo.getColValue("fechaNacimiento")%></td>
			<td><%=cdo.getColValue("cedulaPasaporte")%></td>
			<td align="center"><%=cdo.getColValue("edad")%></td>
			<td align="center"><%=cdo.getColValue("fechaRegistro")%></td>
			<!--<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>--->
			<td  align="center" onMouseOver="javascript:displayValue(<%=i%>,'Edit','Editar');" onMouseOut="javascript:displayValue(<%=i%>,'edit','');"><label id="lblEdit<%=i%>"></label><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
		</tbody>
		</table>
<%=fb.formEnd()%>
		</div>
		</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>

<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>