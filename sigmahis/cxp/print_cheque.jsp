<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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

StringBuffer sbSql = new StringBuffer();
StringBuffer sbURL = new StringBuffer();
StringBuffer sbQS = new StringBuffer();
String fp = request.getParameter("fp");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String cod_compania = request.getParameter("cod_compania");
String num_ck = request.getParameter("num_ck");
String fecha_emi = request.getParameter("fecha_emi");
String fg = request.getParameter("fg");
String referencia = request.getParameter("referencia");
if (cod_compania == null || cod_compania.trim().equals(""))cod_compania= (String)session.getAttribute("_companyId");
if(referencia==null) referencia = "";
if (fp != null) { sbQS.append("&fp="); sbQS.append(fp); }
if (cod_banco != null) { sbQS.append("&cod_banco="); sbQS.append(cod_banco); }
if (cuenta_banco != null) { sbQS.append("&cuenta_banco="); sbQS.append(cuenta_banco); }
if (cod_compania != null) { sbQS.append("&cod_compania="); sbQS.append(cod_compania); }
if (num_ck != null) { sbQS.append("&num_ck="); sbQS.append(num_ck); }
if (fecha_emi != null) { sbQS.append("&fecha_emi="); sbQS.append(fecha_emi); }
if (fg != null) { sbQS.append("&fg="); sbQS.append(fg); }
if (referencia != null) { sbQS.append("&referencia="); sbQS.append(referencia); }	

sbURL.append(request.getContextPath());

sbSql.append("select nvl((select formato from tbl_con_cuenta_bancaria where cod_banco = '");
sbSql.append(cod_banco);
sbSql.append("' and compania = ");
sbSql.append(cod_compania);
sbSql.append(" and cuenta_banco = '");
sbSql.append(cuenta_banco);
sbSql.append("'),' ') as formato, lower(nvl(get_sec_comp_param(-1,'CXP_CHECK_FILE'),'/cxp/print_check.jsp')) as chk_file from dual");
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
if (cdo == null) sbURL.append("/cxp/print_check.jsp");
else {

	if (cdo.getColValue("formato").equalsIgnoreCase("X")) sbURL.append("/cxp/print_check_ansix97.jsp");
	else sbURL.append(cdo.getColValue("chk_file"));

}

if (sbQS.length() != 0) { sbURL.append("?"); sbURL.append(sbQS.substring(1)); }

System.out.println("................."+sbURL);
response.sendRedirect(sbURL.toString());
%>