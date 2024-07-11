<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	String creatorId = UserDet.getUserEmpId();

	String mode=request.getParameter("mode");
	boolean viewMode = false;
	String change=request.getParameter("change");
	String type=request.getParameter("type");
	String compId=(String) session.getAttribute("_companyId");
	String id_cliente = request.getParameter("id_cliente");
	String fg = request.getParameter("fg");
	String tab = request.getParameter("tab");
	String title = "";
	String key = "";
	ArrayList al = new ArrayList();
	StringBuffer sbSql = new StringBuffer();

	if(mode==null) mode="add";
	if(mode.equals("view")) viewMode=true;
	if(fg==null) fg="";
	if (type == null) type = "0";

	if(request.getMethod().equalsIgnoreCase("GET")){
			sbSql.append("select a.id id_pregunta, a.pregunta, a.tipo_pregunta, nvl(b.respuesta, ' ') respuesta, nvl(b.detalle, ' ') detalle, nvl(b.id, 0) id from tbl_pm_cuestionario_salud a, tbl_pm_cliente_cuestionario b where a.estado = 'A' and a.id = b.id_pregunta");
			sbSql.append(" and id_cliente(+) = ");
			sbSql.append(id_cliente);
			sbSql.append(" order by a.id");
			System.out.println("sbSql cuestionario = "+sbSql.toString());
			if (id_cliente == null) throw new Exception("El Parametro Id Cliente no es válido. Por favor intente nuevamente!");
			al = SQLMgr.getDataList(sbSql.toString());

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
//	document.form1.tab.value = parent.document.form3.tab.value;
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
//	window.frames['iFrameSeguimiento'].doAction();
}

</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id_cliente",id_cliente)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
	<table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
			<td class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextPanel">
						<td colspan="4">CUESTIONARIO DE SALUD</td>
					</tr>
					<tr class="" align="center">
						<td colspan="4">
						<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:100">
						<!--<div id="list_op" width="100%" style="overflow;position:absolute">-->
							<table width="99%" border="0" align="center">
								<!--
								<tr class="TextHeader">
									<td width="12%">Fecha</td>
									<td width="10%">Fecha Seguimiento</td>
									<td width="15%">Usuario</td>
									<td width="43%">Nota</td>
									<td width="10%">Estado</td>
									<td align="center" width="4%">&nbsp;</td>
									<td align="center" width="6%"><%=fb.button("addClte","Agregar",false,viewMode,"text10","","onClick=\"javascript:ver("+id_cliente+", 0, 'add');\"")%></td>
								</tr>
								-->
								<%
								for (int i=0; i<al.size(); i++){
									CommonDataObject cd = (CommonDataObject) al.get(i);
									String color = "";
									if (i%2 == 0) color = "TextRow02";
									else color = "TextRow01";
								%>
								<tr>
									<td><%=(i+1)%>. <%=cd.getColValue("pregunta")%></td>
									<td align="center">
									<%if(cd.getColValue("tipo_pregunta").equals("1")){%>
									<%=fb.select("respuesta"+i,"S=Si,N=No",cd.getColValue("respuesta"),false,false,0,null,null,null)%>
									<%}%>
									</td>
								<%if(cd.getColValue("tipo_pregunta").equals("1")){%>
									<td>Indique Cu&aacute;l:<%=fb.textarea("detalle"+i, cd.getColValue("detalle"), false, false, false, 60, 2, 1000, "text10", "", "", "", false, "", "")%></td>
								<%}%>								</tr>

								<%}%>
							</table>
						</div>
						</div>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
}//post
%>
