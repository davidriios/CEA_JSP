<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
sct0095_correc: para editar y consultar
sct0095_ces: solo para consultar
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

SQLMgr.setConnection(ConMgr);

String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

int iconHeight = 24;
int iconWidth = 24;
CommonDataObject cdo;
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String empId = request.getParameter("empId");
String fecha = request.getParameter("fecha");

if (empId == null) empId = "";
if (fecha == null) fecha = "";

if (empId.trim().equals("")) throw new Exception("Empleado inválido!");
if (fecha.trim().equals("")) throw new Exception("Fecha inválida!");

if (request.getMethod().equalsIgnoreCase("GET")) {
	sbSql.append("select provincia, sigla, tomo, asiento, num_empleado, primer_nombre||' '||primer_apellido||' '||case when sexo = 'F' and apellido_casada is not null then apellido_casada else segundo_apellido end as nombre from tbl_pla_empleado where emp_id = ");
	sbSql.append(empId);
	cdo = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select tipo_marcacion, to_char(to_date(marcacion,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh12:mi:ss am') as marcacion, decode(tipo_marcacion,1,'ENTRADA',3,'SALIDA','COD. ERRADO') as tipo_marcacion_dsp, substr(marcacion,1,10) as dialDate, to_char(to_date(marcacion,'dd/mm/yyyy hh24:mi:ss'),'hh12:mi PM') as dialTime from tbl_pla_temporal_marcacion_nv where emp_id = ");
	sbSql.append(empId);
	sbSql.append(" and to_date(substr(marcacion,1,10),'dd/mm/yyyy') = to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy') order by 2");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Marcación - '+document.title;
function doAction(){}
function copiar(d,t){if(d.trim()==''||t.trim()==''){alert('La marcación a copiar no es válida!');return false;}else{parent.document.form0.dialTime.value=t;parent.document.form0.dialDate.value=d;parent.tTime=parent.document.form0.dialTime;parent.tDate=d;parent.document.form0.cpDate.value=d;parent.document.form0.cpTime.value=t;parent.displayElementValue('lblCP',d+' '+t); parent.document.form0.fromPopupMarcacion.value="Y";
parent.document.form0.copyingDate.value=d;
parent.document.form0.copyingTime.value=t;}return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MARCACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("size",""+al.size())%>
		<tr class="TextFilter">
			<td width="10%" align="right">Empl. Id</td>
			<td width="25%"><%=empId%></td>
			<td width="10%" align="right">C&eacute;dula</td>
			<td width="55%"><%=cdo.getColValue("provincia")%>-<%=cdo.getColValue("sigla")%>-<%=cdo.getColValue("tomo")%>-<%=cdo.getColValue("asiento")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right"># Empl.</td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td align="right">Nombre</td>
			<td><%=cdo.getColValue("nombre")%></td>
		</tr>
		<tr>
			<td colspan="4">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="25%">Tipo</td>
					<td width="70%">Marcaci&oacute;n</td>
					<td width="5%">&nbsp;</td>
				</tr>
<% for (int i=0; i<al.size(); i++) { cdo = (CommonDataObject) al.get(i); %>
				<tr class="TextRow01" align="center" id="marc<%=i%>">
					<td><%=cdo.getColValue("tipo_marcacion_dsp")%></td>
					<td><%=cdo.getColValue("marcacion")%></td>
					<td><% if (!viewMode) { %><img src="../images/copy.png" border="0" width="<%=iconWidth%>" height="<%=iconHeight%>" alt="Copiar" onClick="javascript:copiar('<%=cdo.getColValue("dialDate")%>','<%=cdo.getColValue("dialTime")%>')" style="cursor:pointer"><% } else { %>&nbsp;<% } %></td>
				</tr>
<% } %>
				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<%=fb.button("cancel","Cerrar",false,false,"","","onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>