<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
String title = request.getParameter("title");
String displayCompany = request.getParameter("displayCompany");
String width = request.getParameter("width");
String displayLineEffect = request.getParameter("displayLineEffect");
String menuTreeLocation = (String) session.getAttribute("_menuTreeLocation");
String titleWidth = "65%";
String companyWidth = "35%";
String useThis = request.getParameter("useThis");//y=always use from parameter; n=always use from menuTree
String _cia_plan_medico = (String) session.getAttribute("_cia_plan_medico");
String _companyId = (String) session.getAttribute("_companyId");
if (title == null) title = "";
if (displayCompany == null) displayCompany = "Y";
if (displayCompany.equalsIgnoreCase("N"))
{
	titleWidth = "100%";
	companyWidth = "0%";
}
if (width == null) width = "100%";
if (displayLineEffect == null) displayLineEffect = "Y";
// background="<% =request.getContextPath()% >/images/bgTitle.jpg"
if (useThis == null) useThis = "N";
if (menuTreeLocation != null && useThis.equalsIgnoreCase("N"))
{
	/*if (menuTreeLocation.lastIndexOf(">") >= 0) title = menuTreeLocation.substring(menuTreeLocation.lastIndexOf(">") + 1).trim();
	else */if (!menuTreeLocation.equals("")) title = menuTreeLocation;
}
%>
<script language="javascript">
var path_pm = '<%=request.getRequestURI()%>';
var x = path_pm.indexOf('planmedico');
if('<%=_companyId%>'!='<%=_cia_plan_medico%>' && x!=-1){
	if(confirm('Esta compañia no puede usar plan medico!'))
		abrir_ventana('<%=request.getContextPath()%>/admin/user_preferences.jsp?fp=pm');
	else{window.location.reload();}
}
</script>
<table align="center" width="<%=width%>" cellpadding="0" cellspacing="0" id="_tblCommonTitle">
  <tr<%=(displayLineEffect.equalsIgnoreCase("Y"))?" height=\"26\"":""%>>
    <td width="<%=titleWidth%>" class="TextModuleName"><%=title%></td>
    <td width="<%=companyWidth%>" class="TextModuleName RedTextBold" align="right"><%=(displayCompany.equalsIgnoreCase("Y"))?_comp.getNombre():""%></td>
  </tr>
  <tr>
    <td colspan="2" class="TableTopBorderLightGray"<%=(displayLineEffect.equalsIgnoreCase("Y"))?" style=\"font-size:1px\"":""%>>&nbsp;</td>
  </tr>
</table>
