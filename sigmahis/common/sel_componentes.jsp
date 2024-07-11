<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="issi.facturacion.FactDetTransComp"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="fTranComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCompKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranDComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="FTransDet" scope="session" class="issi.facturacion.FactTransaccion" />
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
XML.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

String keyNPT				= request.getParameter("keyNPT");
String cs 				= request.getParameter("cs");
String tipo_cds 	= request.getParameter("tipo_cds");
String reporta_a 	= request.getParameter("reporta_a");
String mode 			= request.getParameter("mode");
String edad				= request.getParameter("edad");
String v_empresa	= request.getParameter("v_empresa");
String incremento	= request.getParameter("incremento");
String tipoInc	= request.getParameter("tipoInc");
String tipoTransaccion	= request.getParameter("tipoTransaccion");
if (fg == null) fg = "";
if (cs == null) cs = "";

if (tipo_cds == null) tipo_cds = "";
if (reporta_a == null) reporta_a = "";
if (tipoTransaccion	== null) tipoTransaccion = "";
if (tipoInc == null) tipoInc = "";
if (edad == null) edad = "0";
if (v_empresa == null) v_empresa = "0";
if (incremento == null) incremento = "0";
if(keyNPT == null) keyNPT = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
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

	if (request.getParameter("tipo_servicio") != null){
		appendFilter += " upper(tipo_servicio) like '%"+request.getParameter("tipo_servicio").toUpperCase()+"%'";
		searchOn = "tipo_servicio";
		searchVal = request.getParameter("tipo_servicio");
		searchType = "1";
		searchDisp = "Tipo Servicio";
	} else if (request.getParameter("tipo_serv_desc") != null){
		appendFilter += " upper(tipo_serv_desc) like '%"+request.getParameter("tipo_serv_desc").toUpperCase()+"%'";
		searchOn = "tipo_serv_desc";
		searchVal = request.getParameter("tipo_serv_desc");
		searchType = "1";
		searchDisp = "Descripción Tipo Servicio";
	} else if (request.getParameter("trabajo") != null){
		appendFilter += " upper(trabajo) like '%"+request.getParameter("trabajo").toUpperCase()+"%'";
		searchOn = "trabajo";
		searchVal = request.getParameter("trabajo");
		searchType = "1";
		searchDisp = "Trabajo";
	} else if (request.getParameter("descripcion") != null){
		appendFilter += " upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		searchOn = "descripcion";
		searchVal = request.getParameter("descripcion");
		searchType = "1";
		searchDisp = "Descripción";
	} else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST")){
		if (searchType.equals("1")){
			appendFilter += " upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
	} else {
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
	}

	if(fg.equals("PAC")){
		sql = "select a.descripcion, b.tipo_servicio t_s from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo = b.tipo_servicio and b.centro_servicio = "+cs+" order by a.descripcion desc";
	} else if(fg.equals("FH")){
		sql = "select distinct a.descripcion, b.tipo_servicio t_s from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo = b.tipo_servicio and b.tipo_servicio = 03 order by a.descripcion desc";
	}
	al = SQLMgr.getDataList(sql);

	sql = "";
	int x = 0;
	for(int i = 0; i<al.size();i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (cdo.getColValue("t_s").equals("03") && fg.equals("FH")){

			//'LOV_PRODUCTO_X_CDS';

			if(x!=0) sql += " union ";

			if(fg.equals("FH")){
			sql += "select '"+cdo.getColValue("t_s")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, a.cpt trabajo, a.precio monto, ' ' habitacion, 0 servicio_hab, a.codigo cds_producto, 0 cod_uso, 127 centro_costo, a.costo costo_art, ' ' procedimiento, ' ' otros_cargos, 'N' usar_alert, 0 precio1, 0 precio2, nvl(a.incremento, 'S') incremento from tbl_cds_producto_x_cds a where a.tser = '"+cdo.getColValue("t_s")+"' and a.estatus = 'A' and a.cod_centro_servicio = 127 and a.precio > 0 and codigo <> 73";
			}
			x++;


		}
	}

	System.out.println("appendFilter="+appendFilter);

	if(!sql.equals("")){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a "+(!appendFilter.equals("")?" where "+appendFilter:"")+" order by descripcion) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+") "+(!appendFilter.equals("")?" where "+appendFilter:""));
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
<script language="javascript">
document.title = 'Centro de Servicio - '+document.title;

function getMain(formx)
{
	formx.cds.value = document.search00.cds.value;
	formx.catCode.value = document.search00.catCode.value;
	return true;
}

function chkValue(i){
	var cantidad = eval('document.detail.cantidad'+i).value;
	if((isNaN(cantidad) || cantidad == '') && (parseFloat(eval('document.detail.cantidad'+i).value) % 1) != 0){
		alert('Introduzca cantidad válida');
		eval('document.detail.cantidad'+i).value = 0;
		eval('document.detail.chkServ'+i).select();
	}
}
function chkValues(){
	var size = parseInt(document.detail.keySize.value);
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.detail.chkServ'+i) && eval('document.detail.chkServ'+i).checked==true && parseInt(eval('document.detail.cantidad'+i).value,2)==0){
			alert('La cantidad no puede ser igual a 0');
			eval('document.detail.chkServ'+i).select();
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE SERVICIOS POR CENTRO DE SERVICIO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipo_cds",tipo_cds)%>
				<%=fb.hidden("reporta_a",reporta_a)%>
				<%=fb.hidden("incremento",incremento)%>
				<%=fb.hidden("tipoInc",tipoInc)%>
				<%=fb.hidden("edad",edad)%>
				<%=fb.hidden("v_empresa",v_empresa)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("keyNPT",keyNPT)%>
				<td width="25%">
					<cellbytelabel>C&oacute;digo Servicio</cellbytelabel>
					<%=fb.intBox("tipo_servicio","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipo_cds",tipo_cds)%>
				<%=fb.hidden("reporta_a",reporta_a)%>
				<%=fb.hidden("incremento",incremento)%>
				<%=fb.hidden("tipoInc",tipoInc)%>
				<%=fb.hidden("edad",edad)%>
				<%=fb.hidden("v_empresa",v_empresa)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("keyNPT",keyNPT)%>
				<td width="25%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("tipo_serv_desc","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipo_cds",tipo_cds)%>
				<%=fb.hidden("reporta_a",reporta_a)%>
				<%=fb.hidden("incremento",incremento)%>
				<%=fb.hidden("tipoInc",tipoInc)%>
				<%=fb.hidden("edad",edad)%>
				<%=fb.hidden("v_empresa",v_empresa)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("keyNPT",keyNPT)%>
				<td width="25%">
					<cellbytelabel>C&oacute;digo Trabajo</cellbytelabel>
					<%=fb.intBox("trabajo","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipo_cds",tipo_cds)%>
				<%=fb.hidden("reporta_a",reporta_a)%>
				<%=fb.hidden("incremento",incremento)%>
				<%=fb.hidden("tipoInc",tipoInc)%>
				<%=fb.hidden("edad",edad)%>
				<%=fb.hidden("v_empresa",v_empresa)%>
				<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
				<%=fb.hidden("keyNPT",keyNPT)%>
				<td width="25%">
					<cellbytelabel>Descripci&oacute;n de Cargo</cellbytelabel>
					<%=fb.intBox("descripcion","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("tipo_cds",tipo_cds)%>
					<%=fb.hidden("reporta_a",reporta_a)%>
					<%=fb.hidden("incremento",incremento)%>
					<%=fb.hidden("tipoInc",tipoInc)%>
					<%=fb.hidden("edad",edad)%>
					<%=fb.hidden("v_empresa",v_empresa)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
					<%=fb.hidden("keyNPT",keyNPT)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("tipo_cds",tipo_cds)%>
					<%=fb.hidden("reporta_a",reporta_a)%>
					<%=fb.hidden("incremento",incremento)%>
					<%=fb.hidden("tipoInc",tipoInc)%>
					<%=fb.hidden("edad",edad)%>
					<%=fb.hidden("v_empresa",v_empresa)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
					<%=fb.hidden("keyNPT",keyNPT)%>
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

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
fb = new FormBean("detail","","post","onSubmit=\"javascript:return(chkValues())\"");
%>
	<%=fb.formStart()%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("cs",cs)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("tipo_cds",tipo_cds)%>
	<%=fb.hidden("reporta_a",reporta_a)%>
	<%=fb.hidden("incremento",incremento)%>
	<%=fb.hidden("tipoInc",tipoInc)%>
	<%=fb.hidden("edad",edad)%>
	<%=fb.hidden("v_empresa",v_empresa)%>
	<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
	<%=fb.hidden("keyNPT",keyNPT)%>
				<tr>
					<td align="right" colspan="7"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel>Servicio</cellbytelabel></td>
					<td width="28%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="29%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Precio Unitario</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
					<td width="3%">&nbsp;</td>
				</tr>
<%=fb.hidden("cs",cs)%>
<%
String onCheck = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	onCheck = "javascript:\"chkValues("+i+")\"";

	%>
	<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
	<%=fb.hidden("tipo_serv_desc"+i,cdo.getColValue("tipo_serv_desc"))%>
	<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
	<%=fb.hidden("trabajo"+i,cdo.getColValue("trabajo"))%>
	<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
	<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
	<%=fb.hidden("servicio_hab"+i,cdo.getColValue("servicio_hab"))%>
	<%=fb.hidden("cds_producto"+i,cdo.getColValue("cds_producto"))%>
	<%=fb.hidden("cod_uso"+i,cdo.getColValue("cod_uso"))%>
	<%=fb.hidden("centro_costo"+i,cdo.getColValue("centro_costo"))%>
	<%=fb.hidden("costo_art"+i,cdo.getColValue("costo_art"))%>
	<%=fb.hidden("procedimiento"+i,cdo.getColValue("procedimiento"))%>
	<%=fb.hidden("otros_cargos"+i,cdo.getColValue("otros_cargos"))%>
	<%=fb.hidden("usar_alert"+i,cdo.getColValue("usar_alert"))%>
	<%=fb.hidden("precio1_"+i,cdo.getColValue("precio1"))%>
	<%=fb.hidden("precio2_"+i,cdo.getColValue("precio2"))%>
	<%=fb.hidden("recargo"+i,cdo.getColValue("recargo"))%>
	<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
	<%
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = keyNPT + "_" + cdo.getColValue("tipo_servicio") +"-"+cdo.getColValue("trabajo");
	if(fTranCompKey.containsKey(cargoKey)) key = (String) fTranCompKey.get(cargoKey);
	if (fTranComp.containsKey(key)){
		FactDetTransaccion dcdo = (FactDetTransaccion) fTranComp.get(key);
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("tipo_servicio")%></td>
			<td>&nbsp;<%=cdo.getColValue("tipo_serv_desc")%></td>
			<td align="center"><%=cdo.getColValue("trabajo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;</td>
			<td><%=fb.intBox("cantidad"+i,dcdo.getCantidad(),false,false,true,10,null,null,"")%></td>
			<td align="center"><cellbytelabel>elegido</cellbytelabel></td>
		</tr>
	<%
	} else {
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("tipo_servicio")%></td>
			<td>&nbsp;<%=cdo.getColValue("tipo_serv_desc")%></td>
			<td align="center"><%=cdo.getColValue("trabajo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;</td>
			<td><%=fb.intBox("cantidad"+i,"0",false,false,false,10,null,null,"onChange=\"javascript:chkValue("+i+");\"")%></td>
			<td align="center"><%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%></td>
		</tr>
	<%
	}
}
if(al.size()==0){
%>
		<tr align="center">
			<td colspan="7"><cellbytelabel>No Registros Encontrados</cellbytelabel></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("tipo_cds",tipo_cds)%>
					<%=fb.hidden("reporta_a",reporta_a)%>
					<%=fb.hidden("incremento",incremento)%>
					<%=fb.hidden("tipoInc",tipoInc)%>
					<%=fb.hidden("edad",edad)%>
					<%=fb.hidden("v_empresa",v_empresa)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
					<%=fb.hidden("keyNPT",keyNPT)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("tipo_cds",tipo_cds)%>
					<%=fb.hidden("reporta_a",reporta_a)%>
					<%=fb.hidden("incremento",incremento)%>
					<%=fb.hidden("tipoInc",tipoInc)%>
					<%=fb.hidden("edad",edad)%>
					<%=fb.hidden("v_empresa",v_empresa)%>
					<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
					<%=fb.hidden("keyNPT",keyNPT)%>
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
else
{
	System.out.println("=====================POST=====================");

	FactDetTransaccion detFTrans = (FactDetTransaccion) FTransDet.getFTransDetail().get(Integer.parseInt(keyNPT)-1);
	int lineNo = 0;//detFTrans.getFDetTransComp().size();

	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String fechaCargo = CmnMgr.getCurrentDate("dd/mm/yyyy");
	for(int i=0;i<keySize;i++){

		FactDetTransComp det = new FactDetTransComp();

		det.setCodProdFar(request.getParameter("trabajo"+i));
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setMonto(request.getParameter("monto"+i));
		det.setCantidad(request.getParameter("cantidad"+i));
		det.setFechaCreacion(fechaCargo);// hh12:mi:ss am

		if(request.getParameter("cds_producto"+i)!=null && !request.getParameter("cds_producto"+i).equals("null") && !request.getParameter("cds_producto"+i).equals("")) det.setCdsProducto(request.getParameter("cds_producto"+i));
		//else det.set("0");
		if(request.getParameter("costo_art"+i)!=null && !request.getParameter("costo_art"+i).equals("null") && !request.getParameter("costo_art"+i).equals("")) det.setCosto(request.getParameter("costo_art"+i));
		//else det.setCostoArt("0");
		if(request.getParameter("recargo"+i)!=null && !request.getParameter("recargo"+i).equals("null") && !request.getParameter("recargo"+i).equals("")) det.setRecargo(request.getParameter("recargo"+i));
		//else det.setRecargo("0");


		if(request.getParameter("chkServ"+i)!=null){

			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			key = keyNPT + "_" + key;
			try {
				fTranComp.put(key, det);
				fTranCompKey.put(keyNPT + "_" + det.getCodProdFar(), key);
				detFTrans.getFDetTransComp().add(det);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}

		}
		/* else if(request.getParameter("del"+i)!=null){
			artDel = det.getCodProdFar();
			if (fTranCompKey.containsKey(artDel)){
				System.out.println("- remove item "+artDel);
				fTranComp.remove((String) fTranCompKey.get(artDel));
				fTranCompKey.remove(artDel);
			}
		}
		*/
	}
	detFTrans.setCompSize(""+lineNo);
	fTranDComp.put(keyNPT,detFTrans.getFDetTransComp());
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_componentes.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&cs="+cs+"&tipo_cds="+tipo_cds+"&reporta_a="+reporta_a+"&incremento="+incremento+"&tipoInc="+tipoInc+"&edad="+edad+"&v_empresa="+v_empresa+"&tipoTransaccion="+tipoTransaccion+"&keyNPT="+keyNPT);
		return;
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("cargo_dev_pac")){%>
	window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det.jsp?change=1&mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&cs=<%=cs%>&tipo_cds=<%=tipo_cds%>&reporta_a=<%=reporta_a%>&incremento=<%=incremento%>&tipoInc=<%=tipoInc%>&edad=<%=edad%>&v_empresa=<%=v_empresa%>&tipoTransaccion=<%=tipoTransaccion%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>