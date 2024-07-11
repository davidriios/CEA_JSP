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
<jsp:useBean id="NotMgr" scope="page" class="issi.planmedico.NotaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htNot" scope="session" class="java.util.Hashtable"/>
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);
	NotMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	String creatorId = UserDet.getUserEmpId();

	String mode=request.getParameter("mode");
	boolean viewMode = false;
	String change=request.getParameter("change");
	String type=request.getParameter("type");
	String compId=(String) session.getAttribute("_companyId");
	String tipo = request.getParameter("tipo");
	String id_trx = request.getParameter("id_trx");
	String id = request.getParameter("id");
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
	if(id==null) id="";

	if(request.getMethod().equalsIgnoreCase("GET")){
		if (change==null){
			htNot.clear();
			sbSql.append("select a.id, a.tipo, a.id_trx, to_char(a.fecha, 'dd/mm/yyyy hh12:mi am') fecha, substr(nota, 0, 90) || (case when length(nota) > 90 then '...' else '' end) nota, a.usuario, a.estado, a.id_parent, (select name from tbl_sec_users u where u.user_name = a.usuario) user_name, decode(a.estado, 'A', 'Activo', 'I', 'Inactivo', a.estado) estado_desc from tbl_gen_notas a where a.id_trx = '");
			sbSql.append(id_trx);
			sbSql.append("' and tipo = '");
			sbSql.append(tipo);
			sbSql.append("' order by fecha desc");

			if (id_trx == null || tipo == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			al = SQLMgr.getDataList(sbSql.toString());
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					htNot.put(key, cdoDet);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	document.form1.tab.value = parent.document.form2.tab.value;
if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
window.frames['iFrameNotas'].doAction();
}

function doSubmit(valor){
	document.form1.submit();
}

function ver(id_trx, id, mode){
	var iFrameName = '', page = '';
	iFrameName='iFrameNotas';
	page = '../planmedico/det_notas.jsp?tipo=<%=tipo%>&id_trx=<%=id_trx%>&fg=<%=fg%>&id='+id+'&mode='+mode;
	window.frames[iFrameName].location=page;
}

</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id_trx",id_trx)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tab",tab)%>
	<table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
			<td class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextRow02">
						<td colspan="4">Notas</td>
					</tr>
					<tr class="" align="center">
						<td colspan="4">
						<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:240">
						<!--<div id="list_op" width="100%" style="overflow;position:absolute">-->
							<table width="99%" border="0" align="center">
								<tr class="TextHeader">
									<td width="12%">Fecha</td>
									<td width="15%">Usuario</td>
									<td width="53%">Nota</td>
									<td width="10%">Estado</td>
									<td align="center" width="4%">&nbsp;</td>
									<td align="center" width="6%"><%=fb.button("addClte","Agregar",false,viewMode,"text10","","onClick=\"javascript:ver("+id_trx+", 0, 'add');\"")%></td>
								</tr>
								<%
								key = "";
								if (htNot.size() != 0) al = CmnMgr.reverseRecords(htNot);
								for (int i=0; i<htNot.size(); i++){
									key = al.get(i).toString();
									CommonDataObject cdo = (CommonDataObject) htNot.get(key);
									String color = "";
									if (i%2 == 0) color = "TextRow02";
									else color = "TextRow01";
								%>
								<%=fb.hidden("id"+i, cdo.getColValue("id"))%>
								<%=fb.hidden("id_trx"+i, cdo.getColValue("id_trx"))%>
								<tr class="<%=color%>" align="center">
									<td><%=cdo.getColValue("fecha")%></td>
									<td><%=cdo.getColValue("user_name")%></td>
									<td align="left"><%=cdo.getColValue("nota")%></td>
									<td><%=cdo.getColValue("estado_desc")%></td>
									<td align="center"><authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("id_trx")%>, <%=cdo.getColValue("id")%>, 'view')" class="Link02Bold">Ver</a></authtype></td>
									<td align="center"><authtype type='4'><%if(mode.equals("edit") || (mode.equals("add") && cdo.getColValue("usuario").equals((String) session.getAttribute("_userId")))){%><a href="javascript:ver(<%=cdo.getColValue("id_trx")%>, <%=cdo.getColValue("id")%>, 'edit')" class="Link02Bold">Editar</a><%}%></authtype></td>
								</tr>
								<%}%>
							</table>
						</div>
						</div>
						</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameNotas" id="iFrameNotas" frameborder="0" align="center" width="100%" height="220" scrolling="yes" src="../planmedico/det_notas.jsp?tipo=<%=tipo%>&mode=<%=mode%>&id_trx=<%=id_trx%>&id=<%=id%>&fg=<%=fg%>"></iframe>
						</td>
					</tr>			
				</table>
			</td>
		</tr>
	</table>
<%=fb.hidden("size", ""+htNot.size())%>	
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
}//post
%>
