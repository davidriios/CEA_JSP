<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iLim" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vLim" scope="session" class="java.util.Vector"/>
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
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String esJubilado = request.getParameter("esJubilado");

if (id == null) id = "0";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (esJubilado == null) esJubilado = "N";

boolean viewMode = false;
String mode = request.getParameter("mode");
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql = new StringBuffer();
	if (!vLim.contains("-999")) sbSql.append("select -999, 'TODOS', -999 as title from dual union all ");
	sbSql.append("select z.codigo, z.descripcion, z.codigo as title from tbl_cds_centro_servicio z where z.compania_unorg = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and exists (select null from tbl_fac_det_tran where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and fac_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" and centro_servicio = z.codigo)");
	if (vLim.size() != 0) { sbSql.append(" and codigo not in ("); sbSql.append(CmnMgr.vector2numSqlInClause(vLim)); sbSql.append(")"); }
	sbSql.append(" order by 2");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){newHeight(null,true);}
function setDetails(obj){if(obj.value.trim()==''){document.form0.descripcion.value='';}else{document.form0.descripcion.value=getSelectedOptionLabel(obj,'');}}
</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("esJubilado",esJubilado)%>
<tr class="TextHeader" align="center">
	<td width="35%"><%=fb.select(ConMgr.getConnection(),sbSql.toString(),"cds","",true,false,viewMode,0,"Text10",null,"onChange=\"javascript:setDetails(this)\"",null,"S")%></td>
	<td width="32%"><%=fb.textBox("descripcion","",true,false,viewMode,40,100,"Text10",null,null)%></td>
	<td width="12%"><%=fb.decPlusZeroBox("monto","",true,false,viewMode,10,10.2,"Text10",null,null)%></td>
	<td width="16%"><%=fb.select("aplicarA","P=PACIENTE,E=EMPRESA","",true,false,viewMode,0,"Text10",null,null,null,"S")%></td>
	<td width="5%"><%=fb.submit("add","+",true,viewMode,null,null,null)%></td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
} else {
	CommonDataObject cdo = new CommonDataObject();
	cdo.addColValue("cds",request.getParameter("cds"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("monto",request.getParameter("monto"));
	cdo.addColValue("aplicarA",request.getParameter("aplicarA"));
	try {
		if (!vLim.contains(cdo.getColValue("cds"))) vLim.addElement(cdo.getColValue("cds"));

		if (iLim.size() == 0) {

			cdo.setKey(iLim.size());
			cdo.setAction("I");
			iLim.put(cdo.getKey(),cdo);

		} else {

			boolean found = false;
			al = CmnMgr.reverseRecords(iLim);
			for (int i=0; i<iLim.size(); i++) {
				CommonDataObject o = (CommonDataObject) iLim.get(al.get(i).toString());

				if (o.getColValue("cds").equalsIgnoreCase(cdo.getColValue("cds")) && o.getAction() != null && o.getAction().equalsIgnoreCase("D")) {

					cdo.setAction("U");
					iLim.put(o.getKey(),cdo);
					found = true;

				}
			}

			if (!found) {

				cdo.setKey(iLim.size());
				cdo.setAction("I");
				iLim.put(cdo.getKey(),cdo);

			}

		}
	} catch (Exception ex) {
		System.out.println("Unable to add CDS LIMIT! ERROR: "+ex);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){parent.window.location=window.location='../facturacion/apply_limit.jsp?change=1&mode=<%=mode%>&id=<%=id%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&esJubilado=<%=esJubilado%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
