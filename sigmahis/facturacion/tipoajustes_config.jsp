<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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

ArrayList al= new ArrayList();
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
boolean viewMode = false;
boolean editable = true;
StringBuffer sbSql;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view"))viewMode=true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'FAC_TIPO_DATO_AJ'),'INT') as tipoDato  from dual");
	CommonDataObject cdoE = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	String tipoDato = cdoE.getColValue("tipoDato");
	
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("codigo","");
		cdo.addColValue("regCuenta","");
		cdo.addColValue("editable","S");
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Ajustes no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.codigo, a.descripcion, a.tipo_doc as tipo, estatus, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, nvl((select descripcion from tbl_con_catalogo_gral where cta1 = a.cta1 and cta2 = a.cta2 and cta3 = a.cta3 and cta4 = a.cta4 and cta5 = a.cta5 and cta6 = a.cta6 and compania = a.compania),' ') as cuenta, a.cta_directa, a.mov_honor as honor, a.group_type as grupo, nvl((select reg_cuenta from tbl_fac_adjustment_group where id = a.group_type),'N') as regCuenta, nvl(a.req_aprob,'S') as reqAprob, nvl(a.editable,'S') as editable FROM tbl_fac_tipo_ajuste a WHERE a.codigo = '"+id+"' and a.compania = "+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}
	editable = (cdo != null && (cdo.getColValue("editable").equalsIgnoreCase("S")));
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>document.title="Tipo Ajustes Agregar - "+document.title;<%}else if (mode.equalsIgnoreCase("edit")){%>document.title="Tipo Ajustes Edición - "+document.title;<%}%>
function checkCodigo(obj){var com='<%=(String) session.getAttribute("_companyId")%>';if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_fac_tipo_ajuste','codigo=\''+obj.value+'\' and compania='+com,'<%=cdo.getColValue("codigo").trim()%>')){ document.form1.id.value = '';return true;}else return false;}
function addCatalogo(){var regCuenta = document.form1.regCuenta.value;if(regCuenta=='')regCuenta =getSelectedOptionTitle(document.form1.grupo,document.form1.grupo.value);if(regCuenta=='S')abrir_ventana1('../common/search_catalogo_gral.jsp?fp=regAjuste');else CBMSG.warning('Segun el Grupo de ajuste Seleccionado no es requerido agregar cuenta!.');}
function clearCtas()
{
document.form1.cta1.value = '';
document.form1.cta2.value = '';
document.form1.cta3.value = '';
document.form1.cta4.value = '';
document.form1.cta5.value = '';
document.form1.cta6.value = '';
document.form1.cuenta.value = '';
}
</script>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("regCuenta",cdo.getColValue("regCuenta"))%>
			<%=fb.hidden("editable",cdo.getColValue("editable"))%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="50%"><%=(tipoDato.trim().equals("INT"))?fb.intBox("id",cdo.getColValue("codigo"),true,false,(!mode.trim().equals("add")),10,5,null,null,"onBlur=\"javascript:checkCodigo(this)\""):fb.textBox("id",cdo.getColValue("codigo"),true,false,(!mode.trim().equals("add")),10,5,null,null,"onBlur=\"javascript:checkCodigo(this)\"")%></td>
				<td width="17%"><cellbytelabel>Tipo Docu</cellbytelabel>.</td>
				<td width="18"><%=fb.select("tipo","F=Factura,R=Recibo",cdo.getColValue("tipo"),false,false,viewMode || !editable,0)%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,viewMode || !editable,61)%></td>
				<td><cellbytelabel>Estatus</cellbytelabel></td>
				<td><%=fb.select("estatus","A=Activo,I=Inactivo",cdo.getColValue("estatus"),false,false,viewMode || !editable,0)%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Cat&aacute;logo General</cellbytelabel></td>
				<td><%=fb.textBox("cta1",cdo.getColValue("cta1"),false ,false,true,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3)%><%=fb.textBox("cuenta",cdo.getColValue("cuenta"),false,false,true,25)%>
				<%=fb.button("btncat","...",true,viewMode || !cdo.getColValue("regCuenta").trim().equals("S"),null,null,"onClick=\"javascript:addCatalogo()\"")%></td>
				<td><!--<cellbytelabel>Cta. Directa</cellbytelabel>&nbsp;&nbsp;<%//=fb.select("cta_directa","N=No,S=Sí",cdo.getColValue("cta_directa"))%>--></td>
				<td><!--<cellbytelabel>Honor</cellbytelabel>&nbsp;&nbsp;<%//=fb.select("honor","N=No,S=Sí",cdo.getColValue("honor"))%>--></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Grupo de Ajuste</cellbytelabel></td>
				<td colspan="3"><%//=fb.select("grupo","A=CARGOS Y DEVOLUCIONES,B=DESCUENTOS,C=REBAJAS Y AJUSTES POR EXCEDENTES,D=CORRECCIONES A PAGO,E=AJUSTE A PREFACTURA,F=CHEQUE DEVUELTO,G=INCOBRABLES Y/O REVERSIONES,O=OTROS",cdo.getColValue("grupo"))%>
				<%if(!mode.trim().equals("add")){%>
				<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT id,DESCRIPTION||' - '||id FROM   tbl_fac_adjustment_group  ORDER BY 1","grupoView",cdo.getColValue("grupo"),false,(!mode.trim().equals("add"))?true:false,0)%>
				<%=fb.hidden("grupo",cdo.getColValue("grupo"))%>
				<%}else{%>
						<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT id as optValueColumn,DESCRIPTION||' - '||id as optLabelColumn ,reg_cuenta as optTitleColumn FROM   tbl_fac_adjustment_group where status='A' ORDER BY 1","grupo",cdo.getColValue("grupo"),false,(!mode.trim().equals("add"))?true:false,0,null,null,"onChange=\"javascript:clearCtas()\"")%>
				<%}%>


				</td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Ajuste Requiere Aprobacion</cellbytelabel></td>
				<td><%=fb.select("req_aprob","S=SI,N=NO",cdo.getColValue("reqAprob"),false,false,viewMode||!editable,0)%></td>
				<td>&nbsp;</td>
				<td></td>
			</tr>
			<tr>
				<td colspan="4">
					<jsp:include page="../common/bitacora.jsp" flush="true">
					<jsp:param name="audTable" value="tbl_fac_tipo_ajuste"></jsp:param>
					<jsp:param name="audFilter" value="<%="codigo='"+id+"' and compania="+(String) session.getAttribute("_companyId")%>"></jsp:param>
					</jsp:include>
				</td>
			</tr>
			<tr class="TextRow02">
					<td align="right" colspan="4">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	id = request.getParameter("id");
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_fac_tipo_ajuste");
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("descripcion",request.getParameter("descripcion"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S")||request.getParameter("regCuenta") != null && request.getParameter("regCuenta").equalsIgnoreCase("S"))cdo.addColValue("cta1",request.getParameter("cta1"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S")||request.getParameter("regCuenta") != null && request.getParameter("regCuenta").equalsIgnoreCase("S"))cdo.addColValue("cta2",request.getParameter("cta2"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S")||request.getParameter("regCuenta") != null && request.getParameter("regCuenta").equalsIgnoreCase("S"))cdo.addColValue("cta3",request.getParameter("cta3"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S")||request.getParameter("regCuenta") != null && request.getParameter("regCuenta").equalsIgnoreCase("S"))cdo.addColValue("cta4",request.getParameter("cta4"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S")||request.getParameter("regCuenta") != null && request.getParameter("regCuenta").equalsIgnoreCase("S"))cdo.addColValue("cta5",request.getParameter("cta5"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S")||request.getParameter("regCuenta") != null && request.getParameter("regCuenta").equalsIgnoreCase("S"))cdo.addColValue("cta6",request.getParameter("cta6"));
	
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("cta_directa",request.getParameter("cta_directa"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("mov_honor",request.getParameter("honor"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("estatus",request.getParameter("estatus"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("tipo_doc",request.getParameter("tipo"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("group_type",request.getParameter("grupo"));
	if(request.getParameter("editable") != null && request.getParameter("editable").equalsIgnoreCase("S"))cdo.addColValue("req_aprob",request.getParameter("req_aprob"));
	
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion","sysdate");
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode);
	if (mode.equalsIgnoreCase("add")) {

		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		/*cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId"));*/
		cdo.addColValue("codigo",request.getParameter("id"));
		SQLMgr.insert(cdo);
		id = request.getParameter("id");

	} else {
 		 
		cdo.setWhereClause("codigo = '"+request.getParameter("id")+"' and compania = "+(String) session.getAttribute("_companyId"));
		SQLMgr.update(cdo);
		id = request.getParameter("id");

	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/tipoajustes_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/tipoajustes_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/tipoajustes_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
