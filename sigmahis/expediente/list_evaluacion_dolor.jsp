<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
if(fg ==null)fg="";
if(desc ==null)desc = "LISTADO DE EVALUACIONES DEL DOLOR";

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {
  
  if (!fg.equalsIgnoreCase("BR") && !fg.equalsIgnoreCase("SG") ) {
    sbSql.append("select to_char(fecha,'dd/mm/yyyy') as fecha_dsp, to_char(hora,'hh12:mi:ss am') as hora, total, localizacion");
    if (fg.equalsIgnoreCase("AN") || fg.equalsIgnoreCase("MM5") || fg.equalsIgnoreCase("CA")) {
      sbSql.append(", join(cursor(select descripcion from tbl_sal_dolor d where estado = 'A' and tipo = z.tipo and exists ((select * from table(split(z.dolor,'|')) where column_value = d.codigo))),', ') as dolor");
      sbSql.append(", join(cursor(select descripcion from tbl_sal_intervencion_dolor d where estado = 'A' and tipo = 'ME' and exists ((select * from table(split(z.intervencion,'|')) where column_value = d.codigo))),', ') as intervencion");
    } else sbSql.append(", dolor, intervencion");
    sbSql.append(", usuario, usuario_mod, to_char(fecha_mod,'hh12:mi:ss am') as horaI, tipo from tbl_sal_escalas z where pac_id = ");
    sbSql.append(pacId);
    sbSql.append(" and admision = ");
    sbSql.append(noAdmision);
    sbSql.append(" and tipo = '");
    sbSql.append(fg);
    sbSql.append("'  order by z.fecha desc, z.hora desc");
	} else {
	  sbSql.append("select to_char(fecha,'dd/mm/yyyy') as fecha_dsp, to_char(hora,'hh12:mi:ss am') as hora, total, '' localizacion, '' dolor, '' intervencion, usuario_creacion as usuario, usuario_modificacion as usuario_mod, to_char(fecha_modificacion,'hh12:mi:ss am') as horaI, tipo from tbl_sal_escala_norton where pac_id = ");
	  sbSql.append(pacId);
    sbSql.append(" and secuencia = ");
    sbSql.append(noAdmision);
    sbSql.append(" and tipo = '");
    sbSql.append(fg);
    sbSql.append("'  order by fecha desc, hora desc");
	}
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Listado de Evaluaciones del Dolor - '+document.title;

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="0" cellspacing="0" class="TableBorderLightGray">
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextRow02">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="8"><cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
		</tr>
		<tr class="TextHeader">
			<td width="10%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Hora</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="4">Total</cellbytelabel></td>
			<%if(!fg.trim().equals("MO")){%>
			<td width="10%"><cellbytelabel id="5">Localizaci&oacute;n</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="6">Descripci&oacute;n</cellbytelabel></td>
			<%}%>
			<td width="10%"><cellbytelabel id="7">Usuario</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="8">Hora Inter</cellbytelabel>.</td>
			<td width="20%"><cellbytelabel id="9">Intervenci&oacute;n</cellbytelabel></td>
		</tr>
<%
String fecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		
		
		
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("fecha_dsp")%></td>
			<td><%=cdo.getColValue("hora")%></td>
			<td><%=cdo.getColValue("total")%></td>
			<%if(!fg.trim().equals("MO")){%>
			<td><%=cdo.getColValue("localizacion")%></td>
			<td><%=cdo.getColValue("dolor")%></td>
			<%}%>
			<td><%=cdo.getColValue("usuario_mod")%></td>
			<td><%=cdo.getColValue("horaI")%></td>
			<td><%=cdo.getColValue("intervencion")%></td>
		</tr>
		
	<%	}%>			
				
				</table>
			</td>
		</tr>
		
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<tr>
	<td colspan="8" align="right">
		<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>
