<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;

if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
	}
	String cedulaPaciente = "", pidPaciente = "", nombrePaciente = "", nombreMedico = "";
	
	if(request.getParameter("cedula_paciente") != null) cedulaPaciente = request.getParameter("cedula_paciente");
	if(request.getParameter("pid_paciente") != null) pidPaciente = request.getParameter("pid_paciente");
	if(request.getParameter("nombre_paciente") != null) nombrePaciente = request.getParameter("nombre_paciente");
	if(request.getParameter("nombre_medico") != null) nombreMedico = request.getParameter("nombre_medico");
	
	StringBuffer sbSql = new StringBuffer();
	
	sbSql.append("select a.no_receta, a.pac_id, a.admision, a.medicamento, a.indicacion, a.dosis, a.duracion, a.frecuencia, a.cantidad, p.nombre_paciente, p.id_paciente");
	sbSql.append(" from tbl_sal_salida_medicamento a, vw_adm_paciente p where a.pac_id = p.pac_id and a.NO_RECETA is not null");
	

	if(!cedulaPaciente.equalsIgnoreCase("")){
			sbSql.append(" and p.id_paciente_f3 = '");
			sbSql.append(cedulaPaciente);
			sbSql.append("'");
	}
	
	if(!pidPaciente.equalsIgnoreCase("")){
			sbSql.append(" and p.pac_id||'-'||a.admision = '");
			sbSql.append(pidPaciente);
			sbSql.append("'");
	}

	if(!nombrePaciente.equalsIgnoreCase("")){
		sbSql.append(" and upper(p.nombre_paciente) like '%");
		sbSql.append(nombrePaciente);
		sbSql.append("%'");
	}
	
  StringBuffer sbSqlT = new StringBuffer();
  sbSqlT.append("select * from (select rownum as rn, z.* from (");
  sbSqlT.append(sbSql.toString());
  sbSqlT.append(") z) where rn between ");
  sbSqlT.append(previousVal);
  sbSqlT.append(" and ");
  sbSqlT.append(nextVal);
  al = SQLMgr.getDataList(sbSqlT.toString());
  
  sbSqlT = new StringBuffer();
  sbSqlT.append("select count(*) as count from (");
  sbSqlT.append(sbSql.toString());
  sbSqlT.append(")");
  rowCount = CmnMgr.getCount(sbSqlT.toString());

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Interfaz Mirth Farmacia Cargos- '+document.title;
function doAction(){}

function showReport(pacId, admision) {
  abrir_ventana("../expediente/exp_gen_recetas.jsp?pacId="+pacId+"&noAdmision="+admision);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
		<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<%
					fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td>
					C&eacute;dula:
					<%=fb.textBox("cedula_paciente", cedulaPaciente, false, false, false, 10, 40, "text12", "", "", "", false, "", "")%>
					PID-ADM:
					<%=fb.textBox("pid_paciente", pidPaciente, false, false, false, 10, 40, "text12", "", "", "", false, "", "")%>
					Nombre:
					<%=fb.textBox("nombre_paciente", nombrePaciente, false, false, false, 40, 100, "text12", "", "", "", false, "", "")%>
					Nombre m&eacute;dico:
					<%=fb.textBox("nombre_medico", nombreMedico, false, false, false, 40, 100, "text12", "", "", "", false, "", "")%>
					
					<%=fb.submit("go","Ir")%>
					</td>	
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("cedula_paciente", cedulaPaciente)%>
					<%=fb.hidden("pid_paciente", pidPaciente)%>
					<%=fb.hidden("nombre_paciente", nombrePaciente)%>
					<%=fb.hidden("nombre_medico", nombreMedico)%>
				
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("cedula_paciente", cedulaPaciente)%>
					<%=fb.hidden("pid_paciente", pidPaciente)%>
					<%=fb.hidden("nombre_paciente", nombrePaciente)%>
					<%=fb.hidden("nombre_medico", nombreMedico)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

				<tr class="TextHeader" align="center">
					<td width="35%">Medicamento</td>
					<td width="10%">#Receta</td>
					<td width="10%">Cantidad</td>
					<td width="10%">Indicaci&oacute;n</td>
					<td width="10%">Dosis</td>
					<td width="10%">Duraci&oacute;n</td>
					<td width="10%">Frecuencia</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				String pacGroup = "";
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 
				 if (!pacGroup.equals(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision"))) {
				 %>  
            <tr class="TextHeader02">
                <td>Paciente: <%=cdo.getColValue("nombre_paciente")%></td>
                <td align="center">PID-ADM:</td>
                <td align="center"><%=cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")%></td>
                <td align="center">C&eacute;dula:</td>
                <td align="center"><%=cdo.getColValue("id_paciente")%></td>
                <td align="center" colspan="3"><authtype type='0'><a href="javascript:showReport('<%=cdo.getColValue("pac_id")%>', '<%=cdo.getColValue("admision")%>')" class="Link04">[ Imprimir receta ]</a></authtype></td>
            </tr>
				 <%  
				 }
				 %>
				 
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=fb.textBox("medicamento"+i,cdo.getColValue("medicamento"),false,false,true,65,null,"",null)%></td>
					<td align="center"><%=cdo.getColValue("no_receta")%></td>
					<td align="center"><%=cdo.getColValue("cantidad")%></td>
					<td><%=fb.textBox("indicacion"+i,cdo.getColValue("indicacion"),false,false,true,15,null,"",null)%></td>
					<td><%=fb.textBox("dosis"+i,cdo.getColValue("dosis"),false,false,true,15,null,"",null)%></td>
					<td><%=fb.textBox("duracion"+i,cdo.getColValue("duracion"),false,false,true,15,null,"",null)%></td>
					<td><%=fb.textBox("frecuencia"+i,cdo.getColValue("frecuencia"),false,false,true,15,null,"",null)%></td>
					
				 	<td align="center"></td>
				</tr>
				<%
          pacGroup = cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision");
				 }
				 %>
			</table>
			<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
			   	<%=fb.hidden("cedula_paciente", cedulaPaciente)%>
					<%=fb.hidden("pid_paciente", pidPaciente)%>
					<%=fb.hidden("nombre_paciente", nombrePaciente)%>
					<%=fb.hidden("nombre_medico", nombreMedico)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("cedula_paciente", cedulaPaciente)%>
					<%=fb.hidden("pid_paciente", pidPaciente)%>
					<%=fb.hidden("nombre_paciente", nombrePaciente)%>
					<%=fb.hidden("nombre_medico", nombreMedico)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>
