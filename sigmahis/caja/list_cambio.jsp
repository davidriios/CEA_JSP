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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
int iconHeight = 48;
int iconWidth = 48;

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

	String codigo = request.getParameter("codigo");
	String turno = request.getParameter("turno");
	String nombre = request.getParameter("nombre");
	String descripcion = request.getParameter("descripcion");
	String fecha = request.getParameter("fecha");
	String status = request.getParameter("status");
	if (codigo == null) codigo = "";
	if (turno == null) turno = "";
	if (nombre == null) nombre = "";
	if (descripcion == null) descripcion = "";
	if (fecha == null) fecha = "";
	if (status == null) status = "";
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!turno.trim().equals("")) { sbFilter.append(" and upper(turno) like '%"); sbFilter.append(turno.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!fecha.trim().equals("")) { sbFilter.append(" and fecha = to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }
	if (!status.trim().equals("")) { sbFilter.append(" and status = '"); sbFilter.append(status); sbFilter.append("'"); }

	sbSql.append("select codigo, turno, to_char(fecha,'dd/mm/yyyy') as fecha, nombre, nvl(descripcion,' ') as descripcion, referencia, monto, status, decode(status,'A','ACTIVO','I','ANULADO',status) as estado from tbl_cja_cambio where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" order by codigo desc");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_cja_cambio where compania="+(String) session.getAttribute("_companyId")+sbFilter);

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
document.title = 'LISTADO DE CAMBIOS - '+document.title;
function printList(){abrir_ventana('../caja/print_list_cambio.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function add(){abrir_ventana('../caja/reg_cambio.jsp');}
function view(codigo){abrir_ventana('../caja/reg_cambio.jsp?mode=view&codigo='+codigo);}
function printCambio(codigo){abrir_ventana('../caja/print_cambio.jsp?codigo='+codigo);}
function anulate(codigo){showPopWin('../common/run_process.jsp?fp=cambio&actType=7&docType=CHG&docId='+codigo+'&docNo='+codigo,winWidth*.75,winHeight*.65,null,null,'');}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Cambio';break;
		case 1:msg='Ver Cambio';break;
		case 2:msg='Imprimir Cambio';break;
		case 3:msg='Anular Cambio';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function setIndex(k){if(document.form01.index.value!=k){document.form01.index.value=k;}}
function goOption(option)
{
	if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0)add();
	else
	{
		var k=parseInt(document.form01.index.value,10);
		if(k==-1)alert('Por favor seleccione un Cambio antes de ejecutar una acción!');
		else
		{
			var codigo=eval('document.form01.codigo'+k).value;
			var status=eval('document.form01.status'+k).value;
			if(option==1){view(codigo);}
			else if(option==2){}
			else if(option==3){anulate(codigo);}
		}
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - LISTADO DE CAMBIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/payment.jpg"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/search.gif"></a></authtype>
		<!--<authtype type='2'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/printer.gif"></a></authtype>-->
		<authtype type='7'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/cancel.gif"></a></authtype>
	</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td width="10%">
				C&oacute;digo
				<br>
				<%=fb.textBox("codigo",codigo,false,false,false,10,"Text10",null,null)%>
			</td>
			<td width="10%">
				Turno
				<br>
				<%=fb.intBox("turno",turno,false,false,false,10,"Text10",null,null)%>
			</td>
			<td width="25%">
				Nombre
				<br>
				<%=fb.textBox("nombre",nombre,false,false,false,40,"Text10",null,null)%>
			</td>
			<td width="25%">
				Descripci&oacute;n
				<br>
				<%=fb.textBox("descripcion",descripcion,false,false,false,40,"Text10",null,null)%>
			</td>
			<td width="15%">
				Fecha
				<br>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
			</td>
			<td width="15%">
				Estado
				<br>
				<%=fb.select("status","A=ACTIVO,I=ANULADO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("status",status)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("status",status)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<%fb = new FormBean("form01","","");%>
<%=fb.formStart()%>
<%=fb.hidden("index","-1")%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="7,8">
		<tr class="TextHeader" align="center">
			<td width="8%">C&oacute;digo</td>
			<td width="8%">Turno</td>
			<td width="29%">Nombre</td>
			<td width="29%">Descripci&oacute;n</td>
			<td width="8%">Fecha</td>
			<td width="8%">Monto</td>
			<td width="7%">Estado</td>
			<td width="3%">&nbsp;</td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="8" class="TextRow01" align="center"><font color="#FF0000">
			<% if (request.getParameter("codigo") == null) { %>
			I N T R O D U Z C A &nbsp; P A R A M E T R O S &nbsp; P A R A &nbsp; B U S Q U E D A
			<% } else { %>
			R E G I S T R O ( S ) &nbsp; N O &nbsp; E N C O N T R A D O ( S )
			<% } %>
			</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("turno"+i,cdo.getColValue("turno"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><authtype type='1'><a href="javascript:view(<%=cdo.getColValue("codigo")%>)" class="Link02"><%=cdo.getColValue("codigo")%></a></authtype></td>
			<td align="center"><%=cdo.getColValue("turno")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
			<td align="center"><%=cdo.getColValue("estado")%></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("status",status)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("status",status)%>
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