<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String clientId = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");
String compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");
if(clientId == null || clientId.trim().equals("")) clientId = "";
int iconHeight = 48;
int iconWidth = 48;
String cajero = request.getParameter("cajero");
String turno = request.getParameter("turno");
if(cajero==null) cajero = "";
if(turno==null) turno = "";

if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
	}
	String codigo = "", descripcion = "", fDate = "", tDate = "",admision = "";
	if(request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
	if(request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if(request.getParameter("fDate") != null) fDate = request.getParameter("fDate");
	if(request.getParameter("tDate") != null) tDate = request.getParameter("tDate");
	if(request.getParameter("admision") != null) admision = request.getParameter("admision");


	StringBuffer sbSql = new StringBuffer();

	sbSql.append("select oc.descripcion ref_desc, f.doc_id, to_char(f.doc_date, 'dd/mm/yyyy') fecha, f.printed_no factura, f.client_id, f.client_name, decode(f.doc_type, 'NCR', -f.net_amount, f.net_amount) net_amount, oc.refer_to,decode(f.doc_type, 'FAC', f.other3, f.doc_id) codigo_ref,decode(f.doc_type, 'FAC', 'FACP', 'NCR', 'NCP', 'NDB', 'NDP')as tipoDocto, f.doc_type, f.tipo_factura,f.observations as paciente,f.doc_date,f.admision,f.client_ref_id from tbl_fac_trx f, tbl_fac_tipo_cliente oc where f.client_ref_id = oc.codigo and f.company_id = oc.compania and oc.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and oc.es_clt_cr = 'S' and f.client_ref_id = get_sec_comp_param(f.company_id,'TP_CLIENTE_COMP')");

	 sbSql.append(" and f.company_id=");
			sbSql.append(compFar);

	if(!clientId.equalsIgnoreCase("")){
			sbSql.append(" and f.client_id='");
			sbSql.append(clientId);
			sbSql.append("'");
	}
	if(!codigo.equalsIgnoreCase("")){

			sbSql.append(" and f.pac_id=");
			sbSql.append(codigo);
	}
	if(!admision.equalsIgnoreCase("")){

			sbSql.append(" and f.admision=");
			sbSql.append(admision);
	}
	if(!descripcion.equalsIgnoreCase("")){
		sbSql.append(" and upper(f.observations) like '%");
		sbSql.append(descripcion);
		sbSql.append("%'");
	}
	if(!fDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(f.doc_date) >= to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!tDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(f.doc_date) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!cajero.equals("")){
		sbSql.append(" and f.cod_cajero = '");
		sbSql.append(cajero);
		sbSql.append("'");
	}
	if(!turno.equals("")){
		sbSql.append(" and f.turno = ");
		sbSql.append(turno);
	}

	if(request.getParameter("descripcion") != null){

		sbSql.append(" order by f.tipo_factura,f.doc_date desc,f.observations");
		StringBuffer sbSqlT = new StringBuffer();
		sbSqlT.append("select * from (select rownum as rn, z.* from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(") z) where rn between ");
		sbSqlT.append(previousVal);
		sbSqlT.append(" and ");
		sbSqlT.append(nextVal);
		al = SQLMgr.getDataList(sbSqlT.toString());
		sbSqlT = new StringBuffer();
		sbSqlT.append("select count(*) as count from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(")");
		rowCount = CmnMgr.getCount(sbSqlT.toString());
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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Ventas a Crédito - '+document.title;
function view(idRef,tipoDocto){showPopWin('../facturacion/ver_impresion_dgi.jsp?fg=POS&fp=docto_dgi_list&actType=2&docType=DGI&docId='+idRef+'&tipoDocto='+tipoDocto,winWidth*.85,winHeight*.75,null,null,'');}
function showReport(){
	var codigo	= document.search01.codigo.value;
	var admision	= document.search01.admision.value;
	var paciente	= document.search01.descripcion.value;
	var fDate 			= document.search01.fDate.value;
	var tDate 			= document.search01.tDate.value;
		var turno 			= document.search01.turno.value;
		var cajero 			= document.search01.cajero.value;
	var descCajero ='';
	if(cajero!='')descCajero =getSelectedOptionLabel(document.search01.cajero,'');

	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=farmacia/facturas_interfaz_far.rptdesign&codigo='+codigo+'&admision='+admision+'&paciente='+paciente+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&clientId=<%=clientId%>&pTurno='+turno+'&pCajero='+cajero+'&descCajero='+descCajero);
}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='';break;
		case 1:msg='Estado de Cuenta';break;
		case 2:msg='Ver Documento';break;
		case 3:msg='Detalle Cargos Facturados';break;


	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0)add();
	else
	{
	 if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	 else
	 {
		var k=document.form0.index.value;
		if(k=='')CBMSG.warning('Por favor seleccione un registro antes de ejecutar una acción!');
		else
		{
			var codigo_ref = eval('document.form0.codigo_ref'+k).value ;
			var tipoDocto = eval('document.form0.tipoDocto'+k).value ;
			var ref_type = eval('document.form0.client_ref_id'+k).value ;
			var refer_to = eval('document.form0.refer_to'+k).value ;
			var doc_id = eval('document.form0.doc_id'+k).value ;


			if(option==1)printRFP(<%=clientId%>,ref_type,refer_to);
			else if(option==2)view(codigo_ref,tipoDocto);
			else if(option==3)showDetail(doc_id);
		}
	  }
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.35;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;
function printRFP(refId,refType,referTo)
{
	var val = '../common/sel_periodo.jsp?fg=FACT&refId='+refId+'&refType='+refType+'&referTo='+referTo;
	if(refId!='')	window.open(val,'datesWindow',_popUpOptions);
	else CBMSG.warning('El cliente seleccionado no tiene referencia!!!');
}
function showTurno()
{
var cajero = document.search01.cajero.value ;
if(cajero=='') alert('Seleccione Cajero!');
else abrir_ventana2('../caja/turnos_list.jsp?fp=informe_ingresos&cod_cajera='+cajero);
}
function showDetail(docId){abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=farmacia/rpt_cargos_no_fact.rptdesign&pDocId='+docId+'&pacId=0&noAdmision=0&fDesde=&fHasta=&pFamilia=0&pClase=0&pFacturado=S&pCaja=&pTurno=&pCompId=<%=session.getAttribute("_companyId")%>&pCtrlHeader=true');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>

		<authtype type='51'><a href="javascript:goOption(3);" class="hint hint--left" data-hint="Detalle Cargos Facturados"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/print_bill.gif"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(1);" class="hint hint--left" data-hint="Estado de Cuenta"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/estado_de_cuenta.png"></a></authtype>


		<authtype type='1'><a href="javascript:goOption(2)" class="hint hint--left" data-hint="Ver Documento"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)"  src="../images/search.gif"></a></authtype>

		</td>
	</tr>
	<tr>
		<td>
		<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<%
					fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td>
					ID:
					<%=fb.intBox("codigo", codigo, false, false, false, 10, 40, "text12", "", "", "", false, "", "")%>
					Admision:<%=fb.intBox("admision",admision, false, false, false,10, 40, "text12", "", "", "", false, "", "")%>
					Paciente:
					<%=fb.textBox("descripcion", descripcion, false, false, false, 30, 200, "text12", "", "", "", false, "", "")%>
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fDate"/>
					<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
					<jsp:param name="nameOfTBox2" value="tDate"/>
					<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
					</jsp:include>
					Cajero:
					<%=fb.select(ConMgr.getConnection(),"select cod_cajera, lpad(cod_cajera, 3, '0') ||' - ' || nombre descripcion from tbl_cja_cajera where compania = "+(String) session.getAttribute("_companyId")+" order by nombre asc","cajero",cajero,false,false,0,"text10",null,"", "", "S")%>
					Turno:
					<%=fb.textBox("turno",turno,false,false,false,5)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
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

		<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("index","")%>
				<tr class="TextHeader" align="center">
					<td width="8%">Tipo Docto.</td>
					<td width="8%">Fecha</td>
					<td width="16%">No. Docto. Fiscal</td>
					<td width="13%">C&oacute;digo Ref.</td>
					<td width="38%">Paciente</td>
					<td width="12%">Monto</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				double net_amount = 0.00;
				String cltId = "", refDesc = "", tipoFact = "";
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if(cdo.getColValue("doc_type").equals("NCR")) color = "RedText";
				 if((!cltId.equals(cdo.getColValue("client_id")) || !refDesc.equals(cdo.getColValue("ref_desc"))) && i!=0){
				 %>
				<tr class="SpacingTextBold Text14">
					<td align="right" colspan="5">Total:</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
					<td align="right">&nbsp;</td>
				</tr>
				 <%
					net_amount=0.00;
				 }
				 if(!tipoFact.equals(cdo.getColValue("tipo_factura"))){
				 %>
				<tr class="SpacingTextBold Text14">
					<td align="center" colspan="7"><%=(cdo.getColValue("tipo_factura").equals("CR")?"VENTAS A CREDITO":"VENTAS A CONTADO")%></td>
				</tr>
				 <%
				 }
				%>
				<%=fb.hidden("codigo_ref"+i, cdo.getColValue("codigo_ref"))%>
				<%=fb.hidden("tipoDocto"+i, cdo.getColValue("tipoDocto"))%>
				<%=fb.hidden("client_ref_id"+i, cdo.getColValue("client_ref_id"))%>
				<%=fb.hidden("refer_to"+i, cdo.getColValue("refer_to"))%>
				<%=fb.hidden("doc_id"+i, cdo.getColValue("doc_id"))%>


				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

					<td align="center"><%=cdo.getColValue("doc_type")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("factura")%></td>
					<td align="center"><%=cdo.getColValue("codigo_ref")%></td>
					<td align="left"><%=cdo.getColValue("paciente")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
					<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
				</tr>
				<%
					cltId = cdo.getColValue("client_id");
					refDesc = cdo.getColValue("ref_desc");
					tipoFact = cdo.getColValue("tipo_factura");
					if(cdo.getColValue("net_amount")!=null) net_amount += Double.parseDouble(cdo.getColValue("net_amount"));
				}
				if(al.size()!=0){
				 %>
				<tr class="SpacingTextBold Text14">
					<td align="right" colspan="5">Total:</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
					<td align="right">&nbsp;</td>
				</tr>
				 <%
				 }
				 %>
				<%=fb.formEnd()%>
			</table>
			<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</div>
</div>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
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
