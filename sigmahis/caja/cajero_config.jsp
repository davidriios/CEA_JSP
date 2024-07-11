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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String tab = request.getParameter("tab");
if (tab == null) tab = "0";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")) {
	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'INT_REPL_DBLINK'),'-') as db_link from dual");
	if (p == null) { p = new CommonDataObject(); p.addColValue("db_link","-"); }

	if (mode.equalsIgnoreCase("add")) {
		id = "0";
		cdo.addColValue("cod_cajera","0");
	} else {
		if (id == null) throw new Exception("El Cajero no es válido. Por favor intente nuevamente!");
		sbSql = new StringBuffer();
		sbSql.append("select a.cod_cajera as cod_cajera, nvl((select user_name from tbl_sec_users where user_name = a.usuario),' ') as users, a.nombre, a.usuario, a.usuario_creacion, a.usuario_modificacion, a.fecha_creacion, a.fecha_modificacion, a.estado, a.tipo");
		if (!p.getColValue("db_link").equals("-")) sbSql.append(", decode(a.int_cajera,null,' ',a.int_cajera) as int_cajera");
		sbSql.append(" from tbl_cja_cajera a where a.cod_cajera = '");
		sbSql.append(id);
		sbSql.append("'");
		cdo = SQLMgr.getData(sbSql);
	}

	sbSql = new StringBuffer();
	sbSql.append("select a.codigo as cod_caja, a.compania as compania_caja, a.descripcion as nombre_caja, nvl((select usuario_creacion from tbl_cja_cajas_x_cajero where cod_cajero = '");
	sbSql.append(id);
	sbSql.append("' and cod_caja = a.codigo and compania_caja = a.compania),' ') as usuario_creacion, nvl((select to_char(fecha_creacion,'dd/mm/yyyy') from tbl_cja_cajas_x_cajero where cod_cajero = '");
	sbSql.append(id);
	sbSql.append("' and cod_caja = a.codigo and compania_caja = a.compania),' ') as fecha_creacion, nvl((select decode(cod_caja,null,'N','S') from tbl_cja_cajas_x_cajero where cod_cajero = '");
	sbSql.append(id);
	sbSql.append("' and cod_caja = a.codigo and compania_caja = a.compania),' ') as checked from tbl_cja_cajas a where estado != 'I' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	al = SQLMgr.getDataList(sbSql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Cajeros - "+document.title;
function checkCode(obj){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cja_cajera','cod_cajera = \''+obj.value+'\'','<%=cdo.getColValue("cod_cajera")%>');}
function selUser(){abrir_ventana1('../common/check_user.jsp?fp=cajero');}
</script>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAJA - MANTENIMIENTO - CAJEROS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("tab","0")%>
		<%fb.appendJsValidation("if(checkCode(document.form0.codigo))error++;");%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01" >
			<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("codigo",cdo.getColValue("cod_cajera"),true,false,true,15,12,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>
			<td width="15%" align="right"><cellbytelabel>Tipo</cellbytelabel></td>
			<td width="35%"><%=fb.select("tipo","C=CAJERO,S=SUPERVISOR,A=AMBOS",cdo.getColValue("tipo"))%></td>
		</tr>
		<tr class="TextRow01" >
			<td align="right"><cellbytelabel>Usuario</cellbytelabel></td>
			<td>
				<%=fb.textBox("usuario",cdo.getColValue("usuario"),true,false,true,30,50,null,null,"")%>
				<%=fb.button("buscar","...",true,false,null,null,"onClick=\"javascript:selUser()\"")%>
				<%//=fb.select(ConMgr.getConnection(),"select user_name user_id, user_name from tbl_sec_users order by user_name","usuario",cdo.getColValue("usuario"))%>
			</td>
			<td align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,45,100)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
<% if (p.getColValue("db_link").equals("-")) { %>
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td>
<% } else { %>
			<td align="right"><cellbytelabel>C&oacute;digo Cajera Interfaz</cellbytelabel></td>
			<td><%=fb.textBox("int_cajera",cdo.getColValue("int_cajera"),false,false,false,15,12,null,null,null)%></td>
<% } %>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar:</cellbytelabel>
				<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro </cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto </cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
		<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
</div>
<div class="dhtmlgoodies_aTab">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("tab","1")%>
		<%=fb.hidden("size",""+al.size())%>
		<%fb.appendJsValidation("if(checkCode(document.form1.codigo))error++;");%>
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel>Codigo Caja</cellbytelabel></td>
			<td width="60%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos las cajas listadas!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdoC = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("usuario_creacion"+i,cdoC.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdoC.getColValue("fecha_creacion"))%>
		<%=fb.hidden("compania_caja"+i,cdoC.getColValue("compania_caja"))%>
		<%=fb.hidden("cod_caja"+i,cdoC.getColValue("cod_caja"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdoC.getColValue("cod_caja")%></td>
			<td><%=cdoC.getColValue("nombre_caja")%></td>
			<td align="center"><%=fb.checkbox("check"+i,""+i,(cdoC.getColValue("checked").equals("S")?true:false),false)%></td>
		</tr>
<% } %>
		<tr class="TextRow02">
			<td colspan="3" align="right">
				<cellbytelabel>Opciones de Guardar:</cellbytelabel>
				<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
		<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
</div>
</div>
<script type="text/javascript">
<%
String tabLabel = "'Cajero/Supervisor','Cajas por Supervisor'";
String tabInactivo = "";
System.out.println("tipo="+cdo.getColValue("tipo"));
if (mode.equalsIgnoreCase("add")) tabInactivo = "1";
else if (mode.equalsIgnoreCase("edit") && cdo.getColValue("tipo") != null && cdo.getColValue("tipo").equalsIgnoreCase("C")) tabInactivo = "1";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','','','','',[<%=tabInactivo%>]);
</script>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	if (tab.equals("0")) {

		cdo = new CommonDataObject();

		cdo.setTableName("tbl_cja_cajera");
		cdo.addColValue("nombre",request.getParameter("nombre"));
		cdo.addColValue("usuario",request.getParameter("usuario"));
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("tipo",request.getParameter("tipo"));
		cdo.addColValue("int_cajera",request.getParameter("int_cajera"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&id="+id);
		if (mode.equalsIgnoreCase("add")) {
			cdo.setAutoIncCol("cod_cajera");
			cdo.addPkColValue("cod_cajera","");

			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			SQLMgr.insert(cdo);
			id = SQLMgr.getPkColValue("cod_cajera");
		} else {
			cdo.setWhereClause("cod_cajera = "+request.getParameter("id"));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion","sysdate");
			SQLMgr.update(cdo);
		}
		ConMgr.clearAppCtx(null);

	} else if (tab.equals("1")) {

		int size = Integer.parseInt(request.getParameter("size"));
		String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
		al.clear();
		for (int i=0; i<size; i++) {
			if (request.getParameter("check"+i) != null) {
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_cja_cajas_x_cajero");

				if(request.getParameter("usuario_creacion"+i)!=null && !request.getParameter("usuario_creacion"+i).equals("")) cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
				else cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				if(request.getParameter("fecha_creacion"+i)!=null && !request.getParameter("fecha_creacion"+i).equals("")) cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
				else cdo.addColValue("fecha_creacion", fecha);
				cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_modificacion", fecha);
				cdo.addColValue("compania_caja",request.getParameter("compania_caja"+i));
				cdo.addColValue("cod_caja",request.getParameter("cod_caja"+i));
				cdo.addColValue("cod_cajero",request.getParameter("id"));
				cdo.setWhereClause("cod_cajero = '" + request.getParameter("id") + "'");

				al.add(cdo);
			}
		}
		if (al.size() ==0) {
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_cja_cajas_x_cajero");
			cdo.setWhereClause("cod_cajero = '" + request.getParameter("id") + "'");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&id="+id);
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/cajeros_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/cajeros_list.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/caja/cajeros_list.jsp';
<% } %>
<% if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } %>
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=add';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&tab=<%=request.getParameter("tab")%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
