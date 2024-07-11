<%@ page errorPage="../error.jsp"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="issi.admin.UserDetail"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="_appUsers" scope="application" class="java.util.Hashtable"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
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

SQLMgr.setConnection(ConMgr);

SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss aa");
long currentTime = System.currentTimeMillis();
String schema = new issi.admin.StringEncrypter().decrypt(java.util.ResourceBundle.getBundle("connection").getString("db_username")).toUpperCase();
String usuario = request.getParameter("usuario");
String compania = request.getParameter("compania");
if (compania == null) compania = "";
if (usuario == null) usuario = "";
int maxInactiveInterval = 30;//30 mins -> default value
try { maxInactiveInterval = Integer.parseInt(java.util.ResourceBundle.getBundle("issi").getString("inactivity.timeout")); } catch (Exception e) {}
if (maxInactiveInterval <= 0) maxInactiveInterval = 30;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Usuarios Conectados - '+document.title;
timer(300,true,'timerMsgTop,timerMsgBottom','sss seg. para refrescar','reloadPage()',false,'_timer');
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function reloadPage(){window.location='../admin/app_users.jsp?usuario='+document.search00.usuario.value+'&compania='+document.search00.compania.value;}
function view(id,user){showPopWin('../admin/app_users_details.jsp?id='+id+'&user='+user,winWidth*.75,winHeight*.65,null,null,'');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="USUARIOS CONECTADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td colspan="5">
				<cellbytelabel>Usuario</cellbytelabel>
				<%=fb.textBox("usuario",usuario,false,false,false,30,"Text10",null,null)%>
				<cellbytelabel>Compañia</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||nombre from tbl_sec_compania where estado = 'A' order by codigo","compania",compania,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		<tr class="TextPager">
			<td width="10%">&nbsp;</td>
			<td width="30%">Total Registro(s) <label id="nRecsTop"><%=_appUsers.size()%></label></td>
			<td width="20%" align="center"><label id="timerMsgTop"></label></td>
			<td width="30%" align="right"><%=sdf.format(new java.util.Date(currentTime))%></td>
			<td width="10%" align="right">&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="9" oddClass="TextRow01" evenClass="TextRow02" sortColumn="7" sortType="desc">
		<tr class="TextHeader" align="center">
			<td width="15%">Direcci&oacute;n IP [ PID ]</td>
			<td width="10%">Usuario</td>
			<td width="18%">Nombre</td>
			<td width="17%">Departamento</td>
			<td width="17%">Compañia</td>
			<td width="7%">Fecha Acceso</td>
			<td width="7%">Ultimo Acceso</td>
			<td width="4%">Inact. (min)</td>
			<td width="2%">&nbsp;</td>
			<td width="3%"><img src="../images/reload.gif" height="20" width="20" onClick="javascript:reloadPage()" style="cursor:pointer" alt="Actualizar Listado!"></td>
		</tr>
<%
int i = 0;
long creationTime = 0, lastAccessedTime = 0, maxInactiveTime = 0;
StringBuffer sbSql;
for (Enumeration e = _appUsers.keys(); e.hasMoreElements();) {
	UserDetail ud = null;
	String userName = (String) e.nextElement();
	HttpSession ses = null;

	if (!usuario.trim().equals("")) {

		if (_appUsers.containsKey(usuario.toLowerCase())) {

			ses = (HttpSession) _appUsers.get(usuario.toLowerCase());
			userName = usuario.toLowerCase();

		} else break;

	} else ses = (HttpSession) _appUsers.get(userName);

	String sesCompania = "";
	try { ses.getAttribute("_companyId"); sesCompania = (String) ses.getAttribute("_companyId"); } catch(Exception ex) { }
	if (compania.trim().equals("") || compania.equals(sesCompania)) {

	try { ud = (UserDetail) ses.getAttribute("UserDet"); } catch(Exception ex) { ud = null; }
	if (ud == null) { ud = new UserDetail(); }
	try { creationTime = ses.getCreationTime(); } catch (Exception ex) { creationTime = 0; }
	try { lastAccessedTime = ses.getLastAccessedTime(); } catch (Exception ex) { lastAccessedTime = 0; }
	try { maxInactiveTime = ses.getMaxInactiveInterval() * 1000; } catch (Exception ex) { maxInactiveTime = 1000; }
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (maxInactiveTime == 1000 || (lastAccessedTime > 0 && maxInactiveTime > 0 && (currentTime - lastAccessedTime) > maxInactiveTime) || ud.getClientIP() == null) {
		color = "TextRowPink";
		if (ses != null) SecMgr.removeUsers(ses.getId());
		_appUsers.remove(userName);
	}
	i++;
	sbSql = new StringBuffer();
	sbSql.append("select join(cursor(select sid from v$session where username = '");
	sbSql.append(schema);
	sbSql.append("' and client_identifier = '");
	sbSql.append(userName);
	sbSql.append(":");
	sbSql.append(ud.getClientIP());
	sbSql.append("' order by sid),', ') as sids, (");
	if (sesCompania.trim().equals("")) sbSql.append("' '");
	else {
		sbSql.append("select nombre from tbl_sec_compania where codigo =");
		sbSql.append(sesCompania);
	}
	sbSql.append(") as companiaDesc from dual");
	CommonDataObject cdo = SQLMgr.getData(sbSql);
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=(ud.getClientIP() == null)?"":ud.getClientIP()%></br>[ <%=(cdo.getColValue("sids") == null)?"":cdo.getColValue("sids")%> ]</td>
			<td><%=userName%></td>
			<td><%=(ud.getName() == null)?"":ud.getName()%></td>
			<td><%=(ud.getDepartmentName() == null)?"":ud.getDepartmentName()%></td>
			<td><%=(cdo.getColValue("companiaDesc") == null)?"":cdo.getColValue("companiaDesc")%></td>
			<td align="center"><%=(maxInactiveTime == 1000)?"":sdf.format(new java.util.Date(creationTime))%></td>
			<td align="center"><%=(maxInactiveTime == 1000)?"":sdf.format(new java.util.Date(lastAccessedTime))%></td>
			<td align="center"><%=(ud.getOther1() != null && ud.getOther1().trim().equals(""))?maxInactiveInterval:ud.getOther1()%></td>
			<td align="center"><%=(maxInactiveTime == 1000)?"*":""%></td>
			<td align="center"><img src="../images/search.gif" height="20" width="20" onClick="javascript:view(<%=ud.getUserId()%>,'<%=userName%>')" style="cursor:pointer" alt="Ver detalles de la Sesión del Usuario!"></td>
		</tr>
<%
	}
	if (!usuario.trim().equals("") && _appUsers.containsKey(usuario.toLowerCase())) break;
}
%>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%">&nbsp;</td>
			<td width="30%">Total Registro(s) <label id="nRecsBottom"><%=_appUsers.size()%></label></td>
			<td width="20%" align="center"><label id="timerMsgBottom"></label></td>
			<td width="30%" align="right"><%=sdf.format(new java.util.Date(currentTime))%></td>
			<td width="10%" align="right">&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<% if (!usuario.trim().equals("") || !compania.trim().equals("")) { %>
<script type="text/javascript">
displayElementValue('nRecsTop',<%=i%>);
displayElementValue('nRecsBottom',<%=i%>);
</script>
<% } %>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
