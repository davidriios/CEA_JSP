<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector"%>
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
<jsp:useBean id="iProf" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProf" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iUser" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUser" scope="session" class="java.util.Vector"/>
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
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String key = "";
String tab = request.getParameter("tab");
String change = request.getParameter("change");
int profLastLineNo = 0;
int userLastLineNo = 0;

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("id",id);
		cdo.addColValue("display_date","");
		cdo.addColValue("hide_date","");
		iProf.clear();
		vProf.clear();
		iUser.clear();
		vUser.clear();
	}
	else
	{
		if (id == null) throw new Exception("La Alerta no es válida. Por favor intente nuevamente!");

		sql = "select id, name, message, message_type, to_char(display_date,'dd/mm/yyyy hh24:mi') as display_date, status, to_char(hide_date,'dd/mm/yyyy hh24:mi') as hide_date from tbl_sec_alert where id="+id;
		cdo = SQLMgr.getData(sql);

		if (change == null)
		{
			iProf.clear();
			vProf.clear();
			iUser.clear();
			vUser.clear();

			sql = "select a.profile_id, (select profile_name from tbl_sec_profiles where profile_id=a.profile_id) as profile_name from tbl_sec_alert_profile a where a.alert_id="+id+" order by 2";
			al  = SQLMgr.getDataList(sql);

			profLastLineNo = al.size();
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject det = (CommonDataObject) al.get(i);

				det.setKey(i);
				det.setAction("U");

				try
				{
					iProf.put(det.getKey(), det);
					vProf.addElement(det.getColValue("profile_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sql = "select a.user_id, (select user_name from tbl_sec_users where user_id=a.user_id) as user_name, (select name from tbl_sec_users where user_id=a.user_id) as name from tbl_sec_alert_user a where a.alert_id="+id+" order by 3";
			al  = SQLMgr.getDataList(sql);

			userLastLineNo = al.size();
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject det = (CommonDataObject) al.get(i);

				det.setKey(i);
				det.setAction("U");
				try
				{
					iUser.put(det.getKey(), det);
					vUser.addElement(det.getColValue("user_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//change == null
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Mantenimiento de Alertas - '+document.title;
function showProfileList(){abrir_ventana1('../common/check_profile.jsp?fp=alert&mode=<%=mode%>&id=<%=id%>&profLastLineNo=<%=profLastLineNo%>&userLastLineNo=<%=userLastLineNo%>');}
function showUserList(){abrir_ventana1('../common/check_user.jsp?fp=alert&mode=<%=mode%>&id=<%=id%>&profLastLineNo=<%=profLastLineNo%>&userLastLineNo=<%=userLastLineNo%>');}
function doAction(){
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1")){%>	showProfileList();
		<%}else if (tab.equals("2")){%>showUserList();<%}
	}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - ALERTA"></jsp:param>
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
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,40,100,null,null,null)%></td>
			<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="35%"><%=cdo.getColValue("id")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Mensaje</cellbytelabel></td>
			<td colspan="3"><%=fb.textarea("message",cdo.getColValue("message"),true,false,false,80,5,4000)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"></td>
			<td colspan="4"><cellbytelabel>Fecha / Hora de Referencia</cellbytelabel>: <%=CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Fecha / Hora</cellbytelabel></td>
			<td colspan="3">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="display_date"/>
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("display_date")%>"/>
				<jsp:param name="nameOfTBox2" value="hide_date"/>
				<jsp:param name="valueOfTBox2" value="<%=cdo.getColValue("hide_date")%>"/>
				<jsp:param name="format" value="dd/mm/yyyy hh24:mi"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Tipo Mensaje</cellbytelabel></td>
			<td><%=fb.select("message_type","C=CONFIRMACION",cdo.getColValue("message_type"))%></td>
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo.getColValue("status"))%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
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

<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("name",cdo.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("userSize",""+iUser.size())%>
				<tr class="TextRow02">
					<td align="right">&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Alerta</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cdo.getColValue("id")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=cdo.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Perfiles</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="75%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addProf","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Perfiles")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iProf);
for (int i=0; i<iProf.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject det = (CommonDataObject) iProf.get(key);
%>

						<%=fb.hidden("profile_id"+i,det.getColValue("profile_id"))%>
						<%=fb.hidden("profile_name"+i,det.getColValue("profile_name"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,det.getKey())%>
						<%=fb.hidden("action"+i,det.getAction())%>
						<%if(!det.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=det.getColValue("profile_id")%></td>
							<td><%=det.getColValue("profile_name")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("name",cdo.getColValue("name"))%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("userSize",""+iUser.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Alerta</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cdo.getColValue("id")%></td>
							<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="35%"><%=cdo.getColValue("name")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuarios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="30%"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="65%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addUser","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Usuarios")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iUser);
for (int i=0; i<iUser.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject det = (CommonDataObject) iUser.get(key);
%>
						<%=fb.hidden("user_id"+i,det.getColValue("user_id"))%>
						<%=fb.hidden("user_name"+i,det.getColValue("user_name"))%>
						<%=fb.hidden("name"+i,det.getColValue("name"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>

						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=det.getColValue("user_name")%></td>
							<td><%=det.getColValue("name")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>



<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Alerta'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Perfiles','Usuarios'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

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
	String baction = request.getParameter("baction");

	if (tab.equals("0")) //Alerta
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sec_alert");
		cdo.addColValue("name",request.getParameter("name"));
		cdo.addColValue("message",request.getParameter("message"));
		cdo.addColValue("message_type",request.getParameter("message_type"));
		cdo.addColValue("display_date",request.getParameter("display_date"));
		cdo.addColValue("status",request.getParameter("status"));
		cdo.addColValue("hide_date",request.getParameter("hide_date"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			cdo.setAutoIncCol("id");

			cdo.addPkColValue("id","");
			SQLMgr.insert(cdo);
			id = SQLMgr.getPkColValue("id");
		}
		else
		{
			cdo.setWhereClause("id="+id);

			SQLMgr.update(cdo);
		}
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1")) //Profiles
	{
		int size = 0;
		if (request.getParameter("profSize") != null) size = Integer.parseInt(request.getParameter("profSize"));
		String itemRemoved = "";
		vProf.clear();
		al.clear();
		iProf.clear();
		for (int i=0; i<size; i++)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_alert_profile");
			cdo.setWhereClause("alert_id="+id+" and profile_id="+request.getParameter("profile_id"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("alert_id",id);
			cdo.addColValue("profile_id",request.getParameter("profile_id"+i));
			cdo.addColValue("profile_name",request.getParameter("profile_name"+i));
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iProf.put(cdo.getKey(),cdo);
					vProf.add(cdo.getColValue("profile_id"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id);
			return;
		}

		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_alert_profile");
			cdo.setWhereClause("alert_id="+id);
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2")) //Centros de Servicios
	{
		int size = 0;
		if (request.getParameter("userSize") != null) size = Integer.parseInt(request.getParameter("userSize"));
		String itemRemoved = "";

		al.clear();
		vUser.clear();
		iUser.clear();
		for (int i=0; i<size; i++)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_alert_user");
			cdo.setWhereClause("alert_id="+id+" and user_id="+request.getParameter("user_id"+i));
			cdo.addColValue("alert_id",id);
			cdo.addColValue("user_id",request.getParameter("user_id"+i));
			cdo.addColValue("user_name",request.getParameter("user_name"+i));
			cdo.addColValue("name",request.getParameter("name"+i));
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iUser.put(cdo.getKey(),cdo);
					vUser.add(cdo.getColValue("user_id"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&id="+id);
			return;
		}

		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_alert_user");
			cdo.setWhereClause("alert_id="+id);
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_alert.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_alert.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_alert.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>