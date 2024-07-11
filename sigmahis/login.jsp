<%@ page errorPage="error.jsp"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Compania"%>
<%@ page import="issi.admin.MessageCode"%>
<%@ page import="issi.admin.UserDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="_appUsers" scope="application" class="java.util.Hashtable"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="SQLMgr" scope="session" class="issi.admin.SQLMgr"/>
<%
SecMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String user = request.getParameter("user");
String pass = request.getParameter("pass");
String token = request.getParameter("token");
String lang = request.getParameter("lang");
String ip = request.getRemoteAddr();
String hostName = request.getRemoteHost();
String furl = request.getParameter("furl");
String pacId = "";
String admision = "";
if (furl == null) furl = "";
String index = "index.jsp";
if (furl.equalsIgnoreCase("external")) index = "ExtAuthLogin.jsp";

if (SecMgr.checkLogin(session.getId())) {
	UserDetail ud = SecMgr.getUserDetails(session.getId());
	if (ud.getUserName().equalsIgnoreCase(user)) {
		if (!ud.getUserProfile().contains("0") && SecMgr.showPasswordChange(ud)) {
			response.sendRedirect(request.getContextPath()+"/admin/user_preferences.jsp?fp=newpass&tab=1");
			return;
		} else {
			response.sendRedirect(request.getContextPath()+"/main.jsp");
			return;
		}
	} else {
		response.sendRedirect(request.getContextPath()+"/sys_session_alert.jsp");
		return;
	}
}
String appCompLogoFile="images/lgc.png";
try {appCompLogoFile = java.util.ResourceBundle.getBundle("cellbyteFrontEnd").getString("app.company.logo");}catch(Exception ex){appCompLogoFile = "images/lgc.png";}
session.setAttribute("_appCompLogoFile",appCompLogoFile);

int maxInactiveInterval = 30;//30 mins -> default value
try { maxInactiveInterval = Integer.parseInt(java.util.ResourceBundle.getBundle("issi").getString("inactivity.timeout")); } catch (Exception e) {}
if (maxInactiveInterval <= 0) maxInactiveInterval = 30;
maxInactiveInterval *= 60;

if (user != null && !user.trim().equals("") && pass != null && !pass.trim().equals("")) {

	if (furl.equalsIgnoreCase("external")) {
		//validate all required parameters mrn, token, tstamp
		String mrn = request.getParameter("mrn");
		StringTokenizer st = new StringTokenizer(mrn,"-");
		if (st.countTokens() == 2) {
			pacId = st.nextToken();
			admision = st.nextToken();
		}
	}

	user = user.toLowerCase();
	//to avoid sql injection
	if (user.length() > 15) user = user.substring(0,15);
	if (pass.length() > 20) pass = pass.substring(0,20);

	//remove old session if exists
	javax.servlet.http.HttpSession ses = (HttpSession) _appUsers.get(user);
	if (ses != null) {
	try { issi.admin.SecurityMgr SecMgrOld = (issi.admin.SecurityMgr) ses.getAttribute("SecMgr"); SecMgrOld.removeUsers(ses.getId()); } catch(Exception ex) { }
	_appUsers.remove(user);
    }
	SecMgr.login(session, user, pass, ip, hostName);

} else if (token != null && !token.trim().equals("")) {

	SecMgr.login(session, token, ip, hostName);

} else {

	response.sendRedirect(request.getContextPath()+"/"+index+"?msg=Por favor ingrese el usuario y password"+((!furl.equalsIgnoreCase("external") && (new issi.admin.CommonMgr()).isValidFpType("USR"))?", o el usuario y Huella Dactilar!":"!"));
	return;

}
/*else if (compId != null && compId.trim().equals(""))
{
	response.sendRedirect(request.getContextPath()+"/"+index+"?msg=Por favor seleccione la compañía!");
	return;
}*/



//SecMgr.login(sessionId, user, pass, ip, clientMacName);
if (SecMgr.getErrCode().equals(MessageCode.LOGIN_SUCCESS) || SecMgr.getErrCode().equals(MessageCode.LOGOUT_LOGIN_IP) || SecMgr.getErrCode().equals(MessageCode.LOGOUT_LOGIN_SESSION)) {
	//Set session inactive time validation variables
	session.setAttribute("_maxInactiveInterval",""+(maxInactiveInterval * 1000));
	session.setAttribute("_previousAccessTime",""+System.currentTimeMillis());
	UserDetail ud = SecMgr.getUserDetails(session.getId());
	//if (ud.getUserProfile().contains("0"))
	session.setMaxInactiveInterval(maxInactiveInterval);
	//ud = SecMgr.loadParameters(ud,ud.getDefaultCompania(),null);
	/*
	--values already set when login
	session.setAttribute("_companyId",ud.getDefaultCompania());
	session.setAttribute("_userName",ud.getUserName());
	session.setAttribute("_userCompleteName",ud.getName().toLowerCase());
	session.setAttribute("UserDet",ud);
	*/
	session.setAttribute("_sessionIp",ip);
	session.setAttribute("_connexPort","9233");
	issi.admin.ISSILogger.setSession(session);

	if (SecMgr.getErrCode().equals(MessageCode.LOGIN_SUCCESS)) SecMgr.setErrMsg("");
	ConMgr.setClientIdentifier(user+":"+ip);
	ConMgr.setNlsDateLanguage();

	ConMgr.setSessionCtx("company",ud.getDefaultCompania());

	//if (compId == null) throw new Exception("La Compañía no es válida. Por favor intente nuevamente!");
	//ConMgr.setSessionCtx("company",compId);
	//compId = ud.getDefaultCompania();

	//Language
	if (lang == null) lang = "";

	//if language is not selected then search in the following order: preference, session, browser)
	if (lang.trim().equals("")) {

		if (!SecMgr.getParValue(ud,"lang").trim().equals("")) lang = SecMgr.getParValue(ud,"lang");
		else if (session.getAttribute("_locale") != null) lang = ((java.util.Locale) session.getAttribute("_locale")).getLanguage();
		else lang = request.getLocale().getLanguage();

	}

	session.setAttribute("_locale",new java.util.Locale(lang));
	//java.util.ResourceBundle.getBundle("path").getString("companyimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),request.getContextPath())+"/"
	//String sql = "select codigo, nombre, nvl(actividad,' ') as actividad, nvl(representante_legal,' ') as representanteLegal, direccion, telefono, nvl(fax,' ') as fax, nvl(email,' ') as email, nvl(digito_verificador,' ') as digitoVerificador, nvl(ruc,' ') as ruc, nvl(substr(replace(logo,'\\','/'),instr(replace(logo,'\\','/'),'/',-1) + 1),' ') as logo, nvl(apartado_postal,' ') as apartadoPostal, nvl(zona_postal,' ') as zonaPostal, decode(pais,null,' ',pais) as pais, decode(distrito,null,' ',distrito) as distrito, decode(provincia,null,' ',provincia) as provincia, decode(corregimiento,null,' ',corregimiento) as corregimiento, decode(porc_farhosp,null,' ',porc_farhosp) as porcFarhosp, nvl(num_patronal,' ') as numPatronal, nvl(cedula_juridica,' ') as cedulaJuridica, nvl(cedula_natural,' ') as cedulaNatural, nvl(licencia,' ') as licencia, impuesto, nombre_corto nombreCorto from tbl_sec_compania where codigo="+ud.getDefaultCompania();
	//System.out.println("SQL="+sql);

	CommonDataObject cdoQry = SQLMgr.getData("select query, replace(nvl(get_sec_comp_param(-1,'AUD_SCHEMA'),'-'),'@@','.') as aud_schema_prefix, nvl(get_sec_comp_param(-1,'COMPANIA_PLAN_MEDICO'),'1') as compania_plan_medico, nvl(get_sec_comp_param(-1,'CRYPT_BARCODE_FILTER'),'N') as crypt from tbl_gen_query where id = 2 and refer_to = 'COMP'");
	if (cdoQry.getColValue("aud_schema_prefix").equals("-")) throw new Exception("El parámetro del Esquema de Auditoría no está definido. Por favor consulte con su administrador!");
	session.setAttribute("_aud_schema_prefix",cdoQry.getColValue("aud_schema_prefix"));
	session.setAttribute("_cia_plan_medico",cdoQry.getColValue("compania_plan_medico"));
	session.setAttribute("_crypt",cdoQry.getColValue("crypt"));

	Compania comp = (Compania) sbb.getSingleRowBean(ConMgr.getConnection(),cdoQry.getColValue("query").replace("@@compania",ud.getDefaultCompania()),Compania.class);
	//Compania comp = (Compania) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Compania.class);
	session.setAttribute("_companyId",ud.getDefaultCompania());
	session.setAttribute("_comp",comp);
	session.setAttribute("_nombre",comp.getNombre());
	session.setAttribute("_userName",ud.getUserName());
	session.setAttribute("_menuId","0");
	session.setAttribute("_menuTree","");
	session.setAttribute("_menuTreeLocation","");
	session.setAttribute("_taxPercent",comp.getImpuesto());
	//loaded parameters
	/*if(ud.getVectorParameter("familia").size()>0 && !ud.getVectorParameter("familia").contains("-1"))session.setAttribute("_familia",ud.getVectorParameter("familia"));
	if(ud.getVectorParameter("almacen_ua").size()>0 && !ud.getVectorParameter("almacen_ua").contains("-2"))session.setAttribute("_almacen_ua",ud.getVectorParameter("almacen_ua"));
	if(ud.getVectorParameter("ua").size()>0 && !ud.getVectorParameter("ua").contains("-1"))session.setAttribute("_ua",ud.getVectorParameter("ua"));
	if(ud.getVectorParameter("cds").size()>0 && !ud.getVectorParameter("cds").contains("-1"))session.setAttribute("_cds",ud.getVectorParameter("cds"));
	if(ud.getVectorParameter("almacen_cds").size()>0 && !ud.getVectorParameter("almacen_cds").contains("-2"))session.setAttribute("_almacen_cds",ud.getVectorParameter("almacen_cds"));*/

	//include session timeout variable as per user configuration
 %>
 <%@include file="login_timeout.jsp" %>
 <%
	boolean changePass = false;
	//validate password expiration only when NORMAL(user/password) LOGIN and not superuser
	if (token == null) changePass = SecMgr.showPasswordChange(ud);

	String rPage = "/main.jsp?msg="+issi.admin.IBIZEscapeChars.forURL(SecMgr.getErrMsg())+"&furl="+furl;
	if (furl.equalsIgnoreCase("external")) {
		maxInactiveInterval = 15 * 60;//for external, change to 15 minutes inactive interval
		session.setAttribute("_maxInactiveInterval",""+(maxInactiveInterval * 1000));
		session.setMaxInactiveInterval(maxInactiveInterval);
		rPage = "/expediente/expediente_list.jsp?fp=external&codigo="+pacId+"&noAdmision="+admision;
	} else {
		if (changePass) rPage = "/admin/user_preferences.jsp?fp=newpass&tab=1";
	}
	response.sendRedirect(request.getContextPath()+rPage);

} else {

	ConMgr.close();
	response.sendRedirect(request.getContextPath()+"/"+index+"?msg="+issi.admin.IBIZEscapeChars.forURL(SecMgr.getErrMsg()));

}
%>
