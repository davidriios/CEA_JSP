<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
CommonDataObject cdoR = null;

String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String type = request.getParameter("type");
String pacIdRef = request.getParameter("pacIdRef");
String admisionRef = request.getParameter("admisionRef");
String admStatusRef = request.getParameter("admStatusRef");

if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (type == null) type = "";

if (pacIdRef != null && admisionRef != null && admStatusRef != null) {

	cdoR = new CommonDataObject();
	cdoR.addColValue("pac_id_ref",pacIdRef);
	cdoR.addColValue("admision_ref",admisionRef);
	cdoR.addColValue("estado_ref",admStatusRef);

} else {

	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'INT_HIS_DB_LINK'),'-') as dblink from dual");

	if (p != null && p.getColValue("dblink") != null && !p.getColValue("dblink").trim().equals("-")) {

		if (!pacId.trim().equals("") && !admision.trim().equals("")) {

			sbSql.append("select decode(z.pac_id_ref,null,' ',''||z.pac_id_ref) as pac_id_ref, decode(z.admision_ref,null,' ',''||z.admision_ref) as admision_ref, nvl((select decode(estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA','I','INACTIVA') from tbl_adm_admision");
			sbSql.append(p.getColValue("dblink"));
			sbSql.append(" where pac_id = z.pac_id_ref and secuencia = z.admision_ref),' ') as estado_ref from tbl_adm_admision z where z.pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and z.secuencia = ");
			sbSql.append(admision);

		}

		if (sbSql.length() > 0) {

			cdoR = SQLMgr.getData(sbSql.toString());

			if (type.equalsIgnoreCase("benef") && cdoR != null) {

				if(cdoR.getColValue("pac_id_ref") !=null && !cdoR.getColValue("pac_id_ref").trim().equals("") ){
				sbSql = new StringBuffer();
				sbSql.append("select nvl(z.poliza,' ') as poliza, nvl(z.certificado,' ') as certificado, z.prioridad, z.empresa, (select nombre from tbl_adm_empresa");
				sbSql.append(p.getColValue("dblink"));
				sbSql.append(" where codigo = z.empresa) as nombreEmpresa from tbl_adm_beneficios_x_admision"+p.getColValue("dblink")+" z where nvl(z.estado,'A') = 'A' and z.pac_id = ");
				sbSql.append(cdoR.getColValue("pac_id_ref"));
				sbSql.append(" and z.admision = ");
				sbSql.append(cdoR.getColValue("admision_ref"));
				sbSql.append(" order by 3");
				al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);
				}

			}

		}

	}

}
%>
<% if (cdoR != null && !cdoR.getColValue("pac_id_ref").trim().equals("")) { %>
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("refForm",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("type",type)%>
<%=(pacIdRef == null)?"":fb.hidden("pacIdRef",pacIdRef)%>
<%=(admisionRef == null)?"":fb.hidden("admisionRef",admisionRef)%>
<%=(admStatusRef == null)?"":fb.hidden("admStatusRef",admStatusRef)%>
<tr class="TextPanel02">
	<td><cellbytelabel>DATOS DE REFERENCIA</cellbytelabel></td>
	<td align="right" colspan="3"><cellbytelabel>CUENTA</cellbytelabel>: <font class="RedTextBold Text14"><%=cdoR.getColValue("pac_id_ref")%>-<%=cdoR.getColValue("admision_ref")%></font> --> <font class="RedTextBold Text14"><%=cdoR.getColValue("estado_ref")%></font></td>
</tr>
<% if (type.equalsIgnoreCase("benef")) { %>
<tr class="TextPanel02" align="center">
	<td width="50%"><cellbytelabel>Aseguradora</cellbytelabel></td>
	<td width="20%"><cellbytelabel>P&oacute;liza</cellbytelabel></td>
	<td width="20%"><cellbytelabel>Certificado</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Prioridad</cellbytelabel></td>
</tr>
<% for (int i=0; i<al.size(); i++) { Admision adm = (Admision) al.get(i); %>
<tr class="TextResultRowsWhite">
	<td><%=adm.getEmpresa()%> - <%=adm.getNombreEmpresa()%></td>
	<td><%=adm.getPoliza()%></td>
	<td><%=adm.getCertificado()%></td>
	<td align="center"><%=adm.getPrioridad()%></td>
</tr>
<% } %>
<% } %>
<%=fb.formEnd(true)%>
</table>
<% } %>
