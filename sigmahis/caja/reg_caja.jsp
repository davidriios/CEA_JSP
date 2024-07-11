<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
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
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");

String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'INT_REPL_DBLINK'),'-') as db_link from dual");
	if (p == null) { p = new CommonDataObject(); p.addColValue("db_link","-"); }
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("codigo",id);
	}
	else
	{
		if (id == null) throw new Exception("El C�digo de Caja no es v�lido. Por favor intente nuevamente!");

		sbSql.append("select a.codigo, a.descripcion, nvl(a.ubicacion,' ') as ubicacion, a.estado, nvl(a.ip,' ') as ip, nvl(a.codigo_mef,' ') as codigo_mef, nvl(a.serie,' ') as serie, nvl(a.no_recibo,0) as no_recibo,a.com_cta1,a.com_cta2,a.com_cta3,a.com_cta4,a.com_cta5,a.com_cta6,cg.descripcion descCuenta,cg2.descripcion descCuentaDev ,a.dv_cta1,a.dv_cta2,a.dv_cta3,a.dv_cta4,a.dv_cta5,a.dv_cta6");
		if (!p.getColValue("db_link").equals("-")) sbSql.append(", decode(a.int_caja,null,' ',a.int_caja) as int_caja");
		sbSql.append(", print_dgi from tbl_cja_cajas a,tbl_con_catalogo_gral cg,tbl_con_catalogo_gral cg2  where codigo = ");
		sbSql.append(id);
		sbSql.append(" and a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.com_cta1 = cg.cta1(+) and a.com_cta2= cg.cta2(+) and a.com_cta3= cg.cta3(+) and a.com_cta4= cg.cta4(+) and a.com_cta5= cg.cta5(+) and a.com_cta6 = cg.cta6(+) and a.compania = cg.compania(+) and a.dv_cta1 = cg2.cta1(+) and a.dv_cta2= cg2.cta2(+) and a.dv_cta3= cg2.cta3(+) and a.dv_cta4= cg2.cta4(+) and a.dv_cta5= cg2.cta5(+) and a.dv_cta6 = cg2.cta6(+) and a.compania = cg2.compania(+)");
		cdo = SQLMgr.getData(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Mantenimiento de Caja - "+document.title;
function checkIP(obj){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cja_cajas','ip=\''+obj.value+'\' and compania=<%=session.getAttribute("_companyId")%>','<%=cdo.getColValue("ip")%>');}
function add(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=cajaCom');}
function cajaDev(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=cajaDev');}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - MANTENIMIENTO - CAJA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%//fb.appendJsValidation("if(checkIP(document.form0.ip))error++;");%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01" >
			<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="40%"><%=fb.textBox("codigo",cdo.getColValue("codigo"),false,false,true,2,null,null,null)%></td>
			<td width="10%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="40%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,viewMode,50)%></td>
		</tr>
		<tr class="TextRow01" >
			<td><cellbytelabel>Ubicaci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("ubicacion",cdo.getColValue("ubicacion"),false,false,viewMode,50)%></td>
			<td><cellbytelabel>Direcci&oacute;n IP</cellbytelabel></td>
			<td><%//=fb.textBox("ip",cdo.getColValue("ip"),true,false,viewMode,40,40,null,null,"onChange=\"javascript:checkIP(this)\"")%>
			<%=fb.textBox("ip",cdo.getColValue("ip"),true,false,viewMode,40,40,null,null,"")%>
			</td>
		</tr>
		 <tr class="TextRow01">
					<td><cellbytelabel>C&oacute;digo MEF</cellbytelabel></td>
					<td><%=fb.textBox("codigo_mef",cdo.getColValue("codigo_mef"),false,false,viewMode,30)%></td>
					<td><cellbytelabel>Serie</cellbytelabel></td>
					<td><%=fb.textBox("serie",cdo.getColValue("serie"),false,false,viewMode,30)%></td>
				</tr>
				<tr class="TextRow01">
				<!--<td><cellbytelabel>Ultimo No. Recibo</cellbytelabel></td>
					<td><%//=fb.intBox("no_recibo",cdo.getColValue("no_recibo"),true,false,viewMode,8,8)%></td>-->
					<td><cellbytelabel>Estado</cellbytelabel></td>
					<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,viewMode,0,null,null,null,null,"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Cuenta para Comisiones</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("com_cta1",cdo.getColValue("com_cta1"),true,false,true,3)%>
								<%=fb.textBox("com_cta2",cdo.getColValue("com_cta2"),true,false,true,3)%>
								<%=fb.textBox("com_cta3",cdo.getColValue("com_cta3"),true,false,true,3)%>
								<%=fb.textBox("com_cta4",cdo.getColValue("com_cta4"),true,false,true,3)%>
								<%=fb.textBox("com_cta5",cdo.getColValue("com_cta5"),true,false,true,3)%>
								<%=fb.textBox("com_cta6",cdo.getColValue("com_cta6"),true,false,true,3)%>&nbsp;
								<%=fb.textBox("descCuenta",cdo.getColValue("descCuenta"),false,false,true,51)%>&nbsp;
								<%=fb.button("btnCta","...",true,false,null,null,"onClick=\"javascript:add();\"")%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Cuenta para Devoluciones</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("dv_cta1",cdo.getColValue("dv_cta1"),true,false,true,3)%>
								<%=fb.textBox("dv_cta2",cdo.getColValue("dv_cta2"),true,false,true,3)%>
								<%=fb.textBox("dv_cta3",cdo.getColValue("dv_cta3"),true,false,true,3)%>
								<%=fb.textBox("dv_cta4",cdo.getColValue("dv_cta4"),true,false,true,3)%>
								<%=fb.textBox("dv_cta5",cdo.getColValue("dv_cta5"),true,false,true,3)%>
								<%=fb.textBox("dv_cta6",cdo.getColValue("dv_cta6"),true,false,true,3)%>&nbsp;
								<%=fb.textBox("descCuentaDev",cdo.getColValue("descCuentaDev"),false,false,true,51)%>&nbsp;
								<%=fb.button("btnCtaDev","...",true,false,null,null,"onClick=\"javascript:cajaDev();\"")%></td>

		</tr>
<% if (!p.getColValue("db_link").equals("-")) { %>
		<tr class="TextRow01">
			<td><cellbytelabel>C&oacute;digo Caja Interfaz</cellbytelabel></td>
			<td><%=fb.textBox("int_caja",cdo.getColValue("int_caja"),false,false,viewMode,2)%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
<% } %>
<tr class="TextRow01">
					<td><cellbytelabel>Imprime Documentos DGI?</cellbytelabel></td>
					<td colspan="3"><%=fb.select("print_dgi","S=SI,N=NO",cdo.getColValue("print_dgi"),false,viewMode,0,null,null,null,null,"")%>&nbsp;<font class="RedTextBold">Define si desde esta caja se pueden o no imprimir Documentos DGI.</font></td>

		</tr>

	 <tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_cja_cajas");
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("ubicacion",request.getParameter("ubicacion"));
	cdo.addColValue("ip",request.getParameter("ip"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion","sysdate");
	cdo.addColValue("codigo_mef",request.getParameter("codigo_mef"));
	cdo.addColValue("serie",request.getParameter("serie"));
	//cdo.addColValue("no_recibo",request.getParameter("no_recibo"));
	cdo.addColValue("estado",request.getParameter("estado"));

	cdo.addColValue("com_cta1",request.getParameter("com_cta1"));
	cdo.addColValue("com_cta2",request.getParameter("com_cta2"));
	cdo.addColValue("com_cta3",request.getParameter("com_cta3"));
	cdo.addColValue("com_cta4",request.getParameter("com_cta4"));
	cdo.addColValue("com_cta5",request.getParameter("com_cta5"));
	cdo.addColValue("com_cta6",request.getParameter("com_cta6"));

	cdo.addColValue("dv_cta1",request.getParameter("dv_cta1"));
	cdo.addColValue("dv_cta2",request.getParameter("dv_cta2"));
	cdo.addColValue("dv_cta3",request.getParameter("dv_cta3"));
	cdo.addColValue("dv_cta4",request.getParameter("dv_cta4"));
	cdo.addColValue("dv_cta5",request.getParameter("dv_cta5"));
	cdo.addColValue("dv_cta6",request.getParameter("dv_cta6"));
	cdo.addColValue("print_dgi",request.getParameter("print_dgi"));

	cdo.addColValue("int_caja",request.getParameter("int_caja"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&codigo="+id);
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("estado","I");
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");

		cdo.setAutoIncCol("codigo");
		cdo.setAutoIncWhereClause("compania = "+session.getAttribute("_companyId"));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addPkColValue("codigo","");
		cdo.setWhereClause("compania = "+session.getAttribute("_companyId"));

		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.setWhereClause("codigo = "+id+" and compania = "+session.getAttribute("_companyId"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/caja_list.jsp")) { %>
	window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/caja_list.jsp")%>';
<% } else { %>
	window.opener.location='<%=request.getContextPath()%>/caja/caja_list.jsp';
<% } if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } } else throw new Exception(SQLMgr.getErrMsg()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>