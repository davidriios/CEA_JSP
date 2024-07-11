<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.IFClient"%>
<%@ page import="java.util.ArrayList" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
String tipoTrx = request.getParameter("tipoTrx");
String facturaPK = request.getParameter("facturaPK");
String pacId = request.getParameter("pacId");
String renglon = request.getParameter("renglon");
String noAdmision = request.getParameter("noAdmision");
if (tipoTrx == null) tipoTrx = "";
if (facturaPK == null) facturaPK = "";
if (pacId == null) pacId = "";
if (renglon == null) renglon = "";
if (noAdmision == null) noAdmision = "";
if (facturaPK.trim().equals("")) throw new Exception("El Documento no es válido. Por favor consulte con su Administrador!");
if (renglon.trim().equals("")) throw new Exception("El Documento no es válido. Por favor consulte con su Administrador!");
if (pacId.trim().equals("")) throw new Exception("El Numero de Paciente no es válido. Por favor consulte con su Administrador!");
if (noAdmision.trim().equals("")) throw new Exception("El Numero de Admision no es válido. Por favor consulte con su Administrador!");

//* * * * * * * * * *   P R O C E S S   A C T I O N   * * * * * * * * * *

if (request.getMethod().equalsIgnoreCase("POST"))
{

			sbSql.append("call sp_mirth_far_cargos_aut(");
			sbSql.append(facturaPK);
			sbSql.append(",");
			sbSql.append(renglon);
			sbSql.append(",");
			sbSql.append(pacId);
			sbSql.append(",'");
			sbSql.append(tipoTrx);
			sbSql.append("','");
			sbSql.append(IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
			sbSql.append("',");
			sbSql.append(noAdmision);
			sbSql.append(")");
			SQLMgr.execute(sbSql.toString());
			out.println(facturaPK+" se ejecuto con codigo "+SQLMgr.getErrMsg());
			//SQLMgr.getErrMsg();
		
}%>