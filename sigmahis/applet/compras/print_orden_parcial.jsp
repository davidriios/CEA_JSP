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

String anio = request.getParameter("anio");
String num = request.getParameter("num");
String tp = request.getParameter("tp");
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");

if (anio == null) anio = "";
if (num == null) num = "";
if (tp == null) tp = "";
if (fp == null) fp = "";
if (anio.trim().equals("") || num.trim().equals("") || tp.trim().equals("")) throw new Exception("La Orden de Compra es inválida!");
if (compania == null || compania.trim().equals(""))compania= (String)session.getAttribute("_companyId");

if (fp != null) { sbQS.append("&fp="); sbQS.append(fp); }
if (anio != null) { sbQS.append("&anio="); sbQS.append(anio); }
if (num != null) { sbQS.append("&num="); sbQS.append(num); }
if (tp != null) { sbQS.append("&tp="); sbQS.append(tp); }
 
sbURL.append(request.getContextPath());

sbSql.append("select lower(nvl(get_sec_comp_param(");
sbSql.append(compania);
sbSql.append(",'COMP_ORDEN_COMP_FILE'),'/compras/print_orden_parcial_new.jsp')) as orden_file from dual");

CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

if (cdo == null) sbURL.append("/compras/print_orden_parcial_new.jsp");
else sbURL.append(cdo.getColValue("orden_file"));

if (sbQS.length() != 0) { sbURL.append("?"); sbURL.append(sbQS.substring(1)); }

System.out.println("................."+sbURL);
response.sendRedirect(sbURL.toString());
%>