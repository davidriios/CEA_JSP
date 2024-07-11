<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
rh10010.fmb
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
int iconHeight = 40;
int iconWidth = 40;
int rowCount = 0;

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String anio = request.getParameter("anio");
String solicitud = request.getParameter("solicitud");
String cedula = request.getParameter("cedula");
String nombre = request.getParameter("nombre");
String apellido = request.getParameter("apellido");

if (anio == null) anio = "";
if (solicitud == null) solicitud = "";
if (cedula == null) cedula = "";
if (nombre == null) nombre = "";
if (apellido == null) apellido = "";

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

	if (!anio.trim().equals("")) { sbFilter.append(" and upper(anio) like '%"); sbFilter.append(anio); sbFilter.append("%'"); }
	if (!solicitud.trim().equals("")) { sbFilter.append(" and upper(consecutivo) like '%"); sbFilter.append(solicitud); sbFilter.append("%'"); }
	if (!cedula.trim().equals("")) { sbFilter.append(" and upper(provincia||'-'||sigla||'-'||tomo||'-'||asiento) like '%"); sbFilter.append(cedula.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!apellido.trim().equals("")) { sbFilter.append(" and upper(primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_casada,null,'',' '||apellido_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }

	sbSql = new StringBuffer();
	sbSql.append("select anio, provincia, sigla, tomo, asiento, compania, consecutivo, anio||' - '||consecutivo as solicitud, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) as nombre, primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_casada,null,'',' '||apellido_casada)) as apellido, provincia||'-'||sigla||'-'||tomo||'-'||asiento as cedula, empleo_solicita1, empleo_solicita2, empleo_solicita3, salario_deseado as salario, lugar_prefiere as lugar, to_char(fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud from tbl_pla_solicitante where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" and estado_solicitante != 5 order by fecha_solicitud desc, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, apellido_casada");
	System.out.println("sql.....\n"+sbSql);

	al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sbSql+") a) WHERE rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_solicitante WHERE compania="+(String) session.getAttribute("_companyId")+sbFilter);

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
<script language="javascript">
document.title = 'Registro de Solicitudes - '+document.title;
function add(){abrir_ventana('../rhplanilla/solicitud_empleado_config.jsp');}
function edit(id,anio,cons,prov,sig,tom,asi){abrir_ventana('../rhplanilla/solicitud_empleado_config.jsp?mode=edit&id='+id+'&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&anio='+anio+'&cons='+cons);}
function printList(){abrir_ventana('../rhplanilla/print_list_solicitud_empleado.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function setIndex(k){document.result.index.value=k;}
function anular(consecutivo, anio){

	if(confirm('Confirma que desea ANULAR la Solicitud?'))
	{
		
				showPopWin('../common/run_process.jsp?fp=ANSOL&actType=7&docType=ANSOL&docId='+anio+'&docNo='+consecutivo+'&compania=<%=(String) session.getAttribute("_companyId")%>&codigo='+consecutivo+'&anio='+anio,winWidth*.75,winHeight*.65,null,null,'');

		
	} else alert('Proceso de Anulación de Solicitud de Empleo, cancelado!');
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Crear Solicitud';break;
		case 1:msg='Editar Solicitud';break;
		case 2:msg='Ver Solicitud';break;
		case 3:msg='Anular Solicitud';break;
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

function goOption(option)
{
	if(option==undefined) alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0)  abrir_ventana('../rhplanilla/solicitud_empleado_config.jsp');
	else
	{
		var k=document.result.index.value;

		if(k=='')alert('Por favor seleccione una solicitud antes de ejecutar una acción!');
		else
		{
			var msg='';
			var anio=eval('document.result.anio'+k).value;
			var consecutivo=eval('document.result.consecutivo'+k).value;
			var provincia=eval('document.result.provincia'+k).value;
			var sigla=eval('document.result.sigla'+k).value;
			var tomo=eval('document.result.tomo'+k).value;
			var asiento=eval('document.result.asiento'+k).value;

			if (option==1)	abrir_ventana('../rhplanilla/solicitud_empleado_config.jsp?mode=edit&anio='+anio+'&cons='+consecutivo+'&prov='+provincia+'&sig='+sigla+'&tom='+tomo+'&asi='+asiento);
			else if (option==2) abrir_ventana('../rhplanilla/solicitud_empleado_config.jsp?mode=view&anio='+anio+'&cons='+consecutivo+'&prov='+provincia+'&sig='+sigla+'&tom='+tomo+'&asi='+asiento);
			else if (option==3) anular(consecutivo, anio);
		}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RHPLANILLA - TRANSACCIONES - REGISTRO DE SOLICITUDES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right" colspan="6">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/notes.gif"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/search.gif"></a></authtype>
		<authtype type='7'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/cancel.gif"></a></authtype>
	</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td width="10%">
				A&ntilde;o
				<%=fb.textBox("anio","",false,false,false,6,"Text10",null,null)%>
			</td>
			<td width="13%">
				Solic.#
				<%=fb.textBox("solicitud","",false,false,false,7,"Text10",null,null)%>
			</td>
			<td width="17%">
				C&eacute;dula
				<%=fb.textBox("cedula","",false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="27%">
				Nombre
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="28%">
				Apellido
				<%=fb.textBox("apellido","",false,false,false,30,"Text10",null,null)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>&nbsp;</td>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="9%">Solicitud</td>
			<td width="13%">C&eacute;dula</td>
			<td width="20%">Nombre</td>
			<td width="20%">Apellido</td>
			<td width="36%">Area de Preferencia</td>
			<td width="3%">&nbsp;</td>
		</tr>
<% fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("consecutivo"+i,cdo.getColValue("consecutivo"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("solicitud")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td><%=cdo.getColValue("lugar")%></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
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