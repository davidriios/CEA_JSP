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
<jsp:useBean id="htNotLiq" scope="session" class="java.util.Hashtable"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);
	NotMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);
	CommonDataObject cdo = new CommonDataObject();

	String creatorId = UserDet.getUserEmpId();

	String mode=request.getParameter("mode");
	String change=request.getParameter("change");
	String tipo=request.getParameter("tipo");
	String compId=(String) session.getAttribute("_companyId");
	String codigo = request.getParameter("codigo");
	String id = request.getParameter("id");
	String fg = request.getParameter("fg");
	String tab = request.getParameter("tab");
	String title = "";
	String key = "";
	boolean viewMode = false;
	ArrayList al = new ArrayList();
	StringBuffer sbSql = new StringBuffer();

	if(mode==null) mode="add";
	if(mode.equals("view")) viewMode=true;
	if(fg==null) fg="";
	if (tipo == null) tipo = "";

	if(request.getMethod().equalsIgnoreCase("GET")){
		if ((mode.equals("edit") || mode.equals("view")) && id != null && !id.equals("")){
			sbSql.append("select a.id, a.tipo, a.codigo_reclamo, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.nota, a.usuario, a.estado from tbl_pm_liquidacion_notas a where a.id = ");
			sbSql.append(id);

			if (codigo == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			cdo = SQLMgr.getData(sbSql.toString());
		} else cdo = new CommonDataObject();
		if(mode.equals("edit") && (id == null || id.equals(""))) mode = "add";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){}

function doSubmit(valor){
	document.form1.baction.value = valor;
	document.form1.submit();
}

</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tab",tab)%>

  <table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
			<td class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr>
						<td colspan="4" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<%=(mode.equals("add")?"Agregar":(mode.equals("edit")?"Editar":"Ver"))%> Nota</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
							</table>
						</td>
					</tr>
					<tr id="panel0">
						<td colspan="4">
							<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextRow01">
									<td class="TextLabel" align="right">Nota:</td>
									<td><%=fb.textarea("nota", cdo.getColValue("nota"), true, false, false, 100, 4, 2000, "text12", "", "", "", false, "", "")%></td>
									<td align="right">Estado:</td>
									<td><%=fb.select("estado", "A=Activo, I=Inactivo", cdo.getColValue("estado"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
								</tr>
								<tr class="TextRow02">
									<td colspan="4" align="right">
									Opciones de Guardar: 
									<%=fb.radio("saveOption","N",true,false,false)%>Crear Otro 
									<!--<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto -->
									<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
									<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.parent.window.close()\"")%>
									</td>
								</tr>
							</table>
            </td>
					</tr>
				</table>
			</td>
    </tr>
  </table>
<%=fb.hidden("size", ""+htNotLiq.size())%>	
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
} else if(request.getMethod().equalsIgnoreCase("post")) {
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();
	String returnId = "";
	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("codigo")!=null) cdo.addColValue("codigo_reclamo", request.getParameter("codigo"));
	if(request.getParameter("tipo")!=null) cdo.addColValue("tipo", request.getParameter("tipo"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("nota")!=null) cdo.addColValue("nota", request.getParameter("nota"));
	if(mode.equals("add")) cdo.addColValue("usuario", (String) session.getAttribute("_userName"));
		
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		if(mode.equals("add")){
			NotMgr.addNotasLiq(cdo);
			returnId = NotMgr.getPkColValue("id");
		} else if(mode.equals("edit")){
			returnId = request.getParameter("id");
			NotMgr.updateNotasLiq(cdo);
		}
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<%
if(NotMgr.getErrCode().equals("1")){
%>
	alert('<%=NotMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('editMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}	
} else throw new Exception(NotMgr.getErrMsg());
%>
}

function addMode()
{
	parent.window.location = '../planmedico/reg_notas_liq.jsp?mode=add&tab=<%=tab%>&codigo=<%=codigo%>&tipo=<%=tipo%>';
}

function editMode()
{
	parent.window.location = '../planmedico/reg_notas_liq.jsp?mode=edit&tab=<%=tab%>&codigo=<%=codigo%>&tipo=<%=tipo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
