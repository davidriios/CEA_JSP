<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
SAL310004						INVENTARIO (CUARTO DE URGENCIA)\TRANSACCIONES\INVENTARIO (CU/EXPEDIENTE).		CUARTO DE URGENCIAS-ADULTO.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String fPage = request.getParameter("fPage");
String fechai = request.getParameter("fechai");
String fechaf = request.getParameter("fechaf");
String area = request.getParameter("area");
String codAlmacen = request.getParameter("codAlmacen");
if(fg==null) fg = "";
if(fp==null) fp = "cargo_uso_insumo";
if(fPage==null) fPage = "";
if (fechai == null) fechai = "";
if (fechaf == null || fechaf.trim().equals("")) fechaf = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (mode == null) mode = "add";
if (codAlmacen == null) codAlmacen = "";

String cds1 = (String) session.getAttribute("COD_CENTRO1");
String cds2 = (String) session.getAttribute("COD_CENTRO2");
//System.out.println("cds1="+cds1+", cds2="+cds2);
StringBuffer strAreas = new StringBuffer();
StringBuffer strWh = new StringBuffer();
StringBuffer strCds = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbSql = new StringBuffer();

if (request.getParameter("fechai") == null) {
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'INV_INSUMO_EXP_IDATE_EMPTY'),'-') as empty_idate from dual");
	CommonDataObject p = SQLMgr.getData(sbSql);
	if (p == null) { p = new CommonDataObject(); p.addColValue("empty_idate","-"); }
	if (p.getColValue("empty_idate").equalsIgnoreCase("N")) fechai = CmnMgr.getCurrentDate("dd/mm/yyyy");
}

if (cds1 == null) cds1 = "";
if (cds2 == null) cds2 = "";
Vector v1 = CmnMgr.str2vector(cds1);
Vector v2 = CmnMgr.str2vector(cds2);

if (area == null) area = "";
String xCds = "";
/*
if (!cds1.trim().equals("")) {xCds = cds1; if (area.trim().equals("")) area = cds1;}
if (!xCds.trim().equals("") && !cds2.trim().equals("") && !cds1.equals(cds2)) xCds += ","+cds2;
else if (!cds2.trim().equals("")) xCds = cds2;
*/
if(!area.trim().equals(""))cds1=area;

strAreas.append(" select codigo, descripcion from tbl_cds_centro_servicio where estado = 'A' and compania_unorg = ");
strAreas.append(session.getAttribute("_companyId"));

strWh.append("select codigo_almacen, codigo_almacen||'-'||descripcion from tbl_inv_almacen where compania = ");
strWh.append(session.getAttribute("_companyId"));

if (!UserDet.getUserProfile().contains("0")) {
	if (session.getAttribute("_cds") != null) strCds.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
	else strCds.append("-1");
	
	strAreas.append(" and codigo in (");
	strAreas.append(strCds);
	strAreas.append(")");

	strWh.append(" and codigo_almacen in (");
	if (session.getAttribute("_almacen_cds") != null) strWh.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
	else strWh.append("-2");
	strWh.append(")");
}

int contTrx =0;
String pacId = request.getParameter("pacId");
String paciente = request.getParameter("paciente");
if (pacId == null) pacId = "";
if (paciente == null) paciente = "";
if (codAlmacen != null && !codAlmacen.trim().equals(""))	{

	sbFilter.append(" and codigo_almacen in ("); sbFilter.append(codAlmacen); sbFilter.append(")");
	if (!pacId.trim().equals("")) { sbFilter.append(" and pac_id = "); sbFilter.append(pacId); }
	if (!paciente.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_paciente where pac_id = z.pac_id and primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada)) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%')"); }

	sbSql = new StringBuffer();
	sbSql.append("select sum(cont) from (");
		sbSql.append("select count(*) as cont from tbl_inv_solicitud_pac z where estado = 'P'");
		if (!area.trim().equals("")) { sbSql.append(" and centro_servicio in ("); sbSql.append(area); sbSql.append(")"); }
		else if (strCds.length() > 0) { sbSql.append(" and centro_servicio in ("); sbSql.append(strCds); sbSql.append(")"); }
		if (!fechai.trim().equals("")) { sbSql.append(" and trunc(fecha_documento) >= to_date('"); sbSql.append(fechai); sbSql.append("','dd/mm/yyyy')"); }
		if (!fechaf.trim().equals("")) { sbSql.append(" and trunc(fecha_documento) <= to_date('"); sbSql.append(fechaf); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(sbFilter);
		sbSql.append(" union all select count(*) as cont from tbl_sal_cargos_usos z where estado = 'P' and sop = 'N'");
		if (!area.trim().equals("")) { sbSql.append(" and centro_servicio in ("); sbSql.append(area); sbSql.append(")"); }
		else if (strCds.length() > 0) { sbSql.append(" and centro_servicio in ("); sbSql.append(strCds); sbSql.append(")"); }
		if (!fechai.trim().equals("")) { sbSql.append(" and trunc(fecha) >= to_date('"); sbSql.append(fechai); sbSql.append("','dd/mm/yyyy')"); }
		if (!fechaf.trim().equals("")) { sbSql.append(" and trunc(fecha) <= to_date('"); sbSql.append(fechaf); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(sbFilter);
		sbSql.append(" union all select count(*) as cont from tbl_inv_devolucion_pac z where estado = 'T'");
		if (!area.trim().equals("")) { sbSql.append(" and sala_cod in ("); sbSql.append(area); sbSql.append(")"); }
		else if (strCds.length() > 0) { sbSql.append(" and sala_cod in ("); sbSql.append(strCds); sbSql.append(")"); }
		if (!fechai.trim().equals("")) { sbSql.append(" and trunc(fecha) >= to_date('"); sbSql.append(fechai); sbSql.append("','dd/mm/yyyy')"); }
		if (!fechaf.trim().equals("")) { sbSql.append(" and trunc(fecha) <= to_date('"); sbSql.append(fechaf); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(sbFilter);
	sbSql.append(")");
	contTrx = CmnMgr.getCount(sbSql.toString());
}

if (request.getMethod().equalsIgnoreCase("GET")) {
	if (mode.equalsIgnoreCase("add")) {
		if ((fechai == null || fechai.trim().equals("")) && (fechaf == null || fechaf.trim().equals(""))) throw new Exception("La Fecha no es válida. Por favor intente nuevamente!");
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturación - '+document.title;
function doAlert(){
	timer();
}

function timer()
{
	var msec='';

	<%if(area != null && !area.trim().equals("")){%>getDBData('<%=request.getContextPath()%>','nvl(tref_frm_tri_msec,5000)','tbl_sal_exp_cli_param','centro_servicio=<%=area%>','');
	<%}%>
	if(msec=='')msec='2000';
	setTimeout('reloadPage()',parseInt(msec,10) * 10);
}

function reloadPage()
{
	window.location.reload(true);
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();doAlert();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame0'),xHeight,100,1/3);resetFrameHeight(document.getElementById('itemFrame1'),xHeight,100,1/3);resetFrameHeight(document.getElementById('itemFrame2'),xHeight,100,1/3);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mode",mode)%> <%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%> <%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%> <%=fb.hidden("clearHT","")%>
<%=fb.hidden("fPage",fPage)%> 
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("usa_filtro","S")%>
		<tr class="TextRow02">
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="nameOfTBox1" value="fechai"/>
					<jsp:param name="valueOfTBox1" value="<%=fechai%>"/>
					<jsp:param name="nameOfTBox2" value="fechaf"/>
					<jsp:param name="valueOfTBox2" value="<%=fechaf%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
					<jsp:param name="format" value="dd/mm/yyyy"/>
				</jsp:include>
				&nbsp;
				<%
				String user_cds = (SecMgr.getParValue(UserDet,"cds")!=null && !SecMgr.getParValue(UserDet,"cds").equals("")?SecMgr.getParValue(UserDet,"cds"):"");
				%>
				Centro de Serv.
				<%=fb.select(ConMgr.getConnection(), strAreas.toString(), "area", (area!=null && !area.equals("")?area:(request.getParameter("usa_filtro")==null?user_cds:"")), false, false, 0, "T")%>
				Almacen<%=fb.select(ConMgr.getConnection(), strWh.toString(), "codAlmacen", (codAlmacen!=null && !codAlmacen.equals("")?codAlmacen:(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"almacen_cds").equals("")?SecMgr.getParValue(UserDet,"almacen_cds"):"")), false, false, 0, "text10", "", "")%></br>
				<cellbytelabel id="3">Paciente</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,false,10,"Text10",null,null)%>
				<%=fb.textBox("paciente","",false,false,false,25,"Text10",null,null)%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
				<% if (contTrx > 0) { %><font size="4" id="ordMedMsg"><%=contTrx+" solicitud(es) pendientes(s)!!!"%></font><embed src="../media/chimes.wav" autostart="true" hidden="true" loop="true"></embed><script language="javascript">blinkId('ordMedMsg','red','white');</script><% } %>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		<tr class="TextPanel">
			<td>SOLICITUD DE INSUMOS</td>
		</tr>
<%
System.out.println("area.........................................="+area);
System.out.println("cds.........................................="+SecMgr.getParValue(UserDet,"cds"));
System.out.println("usa_filtro.........................................="+request.getParameter("usa_filtro"));%>
		<tr>
			<td class="TableBorder"><iframe name="itemFrame0" id="itemFrame0" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../inventario/reg_cargo_uso_insumo_cu_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&codAlmacen=<%=codAlmacen%>&cds=<%=(area!=null && !area.equals("")?area:(request.getParameter("usa_filtro")==null?user_cds:""))%>&type=SP&fechai=<%=fechai%>&fechaf=<%=fechaf%>&pacId=<%=pacId%>&paciente=<%=paciente%>"></iframe></td>
		</tr>
		<tr class="TextPanel">
			<td>SOLICITUD Y DEVOLUCIONES DE USOS</td>
		</tr>
		<tr>
			<td class="TableBorder"><iframe name="itemFrame1" id="itemFrame1" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../inventario/reg_cargo_uso_insumo_cu_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&codAlmacen=<%=codAlmacen%>&cds=<%=(area!=null && !area.equals("")?area:(request.getParameter("usa_filtro")==null?user_cds:""))%>&type=CU&fechai=<%=fechai%>&fechaf=<%=fechaf%>&pacId=<%=pacId%>&paciente=<%=paciente%>"></iframe></td>
		</tr>
		<tr class="TextPanel">
			<td>SOLICITUD DE DEVOLUCION</td>
		</tr>
		<tr>
			<td class="TableBorder"><iframe name="itemFrame2" id="itemFrame2" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../inventario/reg_cargo_uso_insumo_cu_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&cds=<%=(area!=null && !area.equals("")?area:(SecMgr.getParValue(UserDet,"cds")!=null && !SecMgr.getParValue(UserDet,"cds").equals("")?SecMgr.getParValue(UserDet,"cds"):""))%>&codAlmacen=<%=codAlmacen%>&type=DP&fechai=<%=fechai%>&fechaf=<%=fechaf%>&pacId=<%=pacId%>&paciente=<%=paciente%>"></iframe></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar") || request.getParameter("baction").equalsIgnoreCase("cerrar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
} else throw new Exception(errMsg);
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
