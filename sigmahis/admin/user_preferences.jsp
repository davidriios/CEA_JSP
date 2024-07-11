<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.Compania"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%>
<%@ page import="issi.admin.UserPref"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="issi.admin.SecurityMgr"%>
<jsp:useBean id="_appUsers" scope="application" class="java.util.Hashtable"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="UserMgr" scope="page" class="issi.admin.UserMgr"/>
<jsp:useBean id="UPMgr" scope="page" class="issi.admin.UserPrefMgr"/>
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
UserMgr.setConnection(ConMgr);
UPMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String tab = request.getParameter("tab");
String fp = request.getParameter("fp");
StringBuffer sbSql = new StringBuffer();
if (tab == null) tab = "0";
if (fp == null) fp = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String nNumber = null;
	String nSpecialChar = null;
	String specialChar = null;
	String minLength = null;
	java.util.ResourceBundle rb = java.util.ResourceBundle.getBundle("password");
	if (rb != null)
	{
		nNumber = rb.getString("nNumber");
		nSpecialChar = rb.getString("nSpecialChar");
		specialChar = rb.getString("specialChar");
		minLength = rb.getString("minLength");

		if (nNumber == null || nNumber.trim().equals("")) nNumber = "0";
		if (nSpecialChar == null || nSpecialChar.trim().equals("")) nSpecialChar = "0";
		if (specialChar == null) specialChar = "+-*/#$%&()=¡!¿?[]{}";
		if (minLength == null || minLength.trim().equals("")) minLength = "7";
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Preferencias del Usuario - '+document.title;
function doAction(){}
function isValidPassword(){
	var oldPass=document.form1.oldPassword.value;
	var confirmOldPass=document.form1.confirmOldPassword.value;
	var pass=document.form1.password.value;
	var confirmPass=document.form1.confirmPassword.value;
	var errors=[];
	if(oldPass.trim()!=confirmOldPass.trim()){errors.push('La Contraseña Actual es diferente a la confirmación!');document.form1.confirmOldPassword.focus();}
	else if(pass.trim()!=confirmPass.trim()){errors.push('La Contraseña Nueva es diferente a la confirmación!');document.form1.confirmPassword.focus();}
	else if(oldPass.trim()==pass.trim()){errors.push('La Contraseña Actual es igual a la Nueva. Por favor introduzca una nueva contraseña!');document.form1.password.focus();}
	<% if (rb != null) { %>
	else{
		if(pass.length<<%=minLength%>||pass.search(/[\s]/g)>=0){errors.push('- Mínimo <%=minLength%> carácteres (sin espacios)');}
		if(pass.search(/[a-záéíóúàèìòùäëïöüñ]/gi)<0){errors.push('- Letras');}
		if(<%=nNumber%>>0&&pass.replace(/[^0-9]/g,'').length<<%=nNumber%>){errors.push('- Mínimo <%=nNumber%> número(s)');}
		if(<%=nSpecialChar%>>0&&pass.replace(/[^<%=specialChar.replaceAll("\\\\","\\\\\\\\").replaceAll("]","\\\\]").replaceAll("-","\\\\-")%>]/g,'').length<<%=nSpecialChar%>){errors.push('- Mínimo <%=nSpecialChar%> carácter(es) especial(es) [ <%=specialChar%> ]');}
		if(errors.length>0)errors.unshift('La contraseña debe contener lo siguiente:');
	}
	<% } %>
	if(errors.length>0){alert(errors.join("\n"));return false;}
	return true;
}
function reloadPMPage(){
<%if(fp!=null && fp.equals("pm")){%>
	window.opener.location.reload();
<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="PREFERENCIAS DEL USUARIO"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<!-- MAIN DIV START HERE -->
				<div id="dhtmlgoodies_tabView1">
					<!-- TAB0 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","0")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td width="80%">
							<%//=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||nombre from tbl_sec_compania order by codigo","compId",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:document.form0.submit()\"")%>
							<%=fb.select(ConMgr.getConnection(),"select a.codigo, lpad(a.codigo,5,'0')||' - '||a.nombre from tbl_sec_compania a where a.estado = 'A'"+(UserDet.getUserProfile().contains("0")?"":" and exists (select null from tbl_sec_user_comp where user_id = "+UserDet.getUserId()+" and status = 'A' and company_id = a.codigo)")+" order by a.nombre","compId",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:document.form0.submit(); window.opener.location.reload()\"")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right">
								<!--<%=fb.submit("save","Guardar",true,false,null,null,null)%>-->
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:reloadPMPage();closeWin()\"")%>
							</td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB0 DIV END HERE-->
					<!-- TAB1 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","1")%>
						<%=fb.hidden("fp",fp)%>
						<%fb.appendJsValidation("if(!isValidPassword())error++;");%>
						<tr class="TextRow02">
							<td colspan="42" align="center">&nbsp;<%=(fp.equalsIgnoreCase("newpass"))?"Su contraseña actual ha expirado, debe realizar el cambio de contraseña! Por favor ingrese una nueva contraseña":""%></td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Contrase&ntilde;a Actual</cellbytelabel></td>
							<td width="30%"><%=fb.passwordBox("oldPassword",(fp.trim().equalsIgnoreCase("newpass"))?UserDet.getOldPassword():"",(!fp.trim().equalsIgnoreCase("newpass")),false,(fp.trim().equalsIgnoreCase("newpass")),30,20,null,null,null,null," autocomplete=\"off\"")%></td>
							<td width="20%" align="right"><cellbytelabel>Confimar Contrase&ntilde;a Actual</cellbytelabel></td>
							<td width="30%"><%=fb.passwordBox("confirmOldPassword",(fp.trim().equalsIgnoreCase("newpass"))?UserDet.getOldPassword():"",(!fp.trim().equalsIgnoreCase("newpass")),false,(fp.trim().equalsIgnoreCase("newpass")),30,20,null,null,null,null," autocomplete=\"off\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Contrase&ntilde;a Nueva</cellbytelabel></td>
							<td><%=fb.passwordBox("password","",true,false,false,30,20,null,null,null,null," autocomplete=\"off\"")%></td>
							<td align="right"><cellbytelabel>Confimar Contrase&ntilde;a Nueva</cellbytelabel></td>
							<td><%=fb.passwordBox("confirmPassword","",true,false,false,30,20,null,null,null,null," autocomplete=\"off\"")%></td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right">
							<%=fb.submit("save","Guardar",true,false,null,null,null)%>
							<%=(fp.trim().equalsIgnoreCase("newpass"))?"":fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
							</td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB1 DIV END HERE-->
					<!-- TAB2 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","2")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Almac&eacute;n Cds</cellbytelabel>.</td>
							<td width="80%">
							<%sbSql= new StringBuffer();
							if(!UserDet.getUserProfile().contains("0"))
							{
								sbSql.append(" and codigo_almacen in (");
									if(session.getAttribute("_almacen_cds")!=null)
										sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
									else sbSql.append("-2");
								sbSql.append(")");
							}
							%>
							<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId") +sbSql.toString()+ " order by codigo_almacen","codigo_almacen_cds",(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"almacen_cds").equals("")?SecMgr.getParValue(UserDet,"almacen_cds"):""),false,false,0,null,null,"onChange=\"javascript:document.form2.submit()\"")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right">
								<!--<%=fb.submit("save","Guardar",true,false,null,null,null)%>-->
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
							</td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB2 DIV END HERE-->
					<!-- TAB3 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","3")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Almac&eacute;n Unidad Adm</cellbytelabel>.</td>
							<td width="80%">
							<%sbSql= new StringBuffer();
							if(!UserDet.getUserProfile().contains("0"))
							{
								sbSql.append(" and codigo_almacen in (");
									if(session.getAttribute("_almacen_ua")!=null)
										sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua")));
									else sbSql.append("-2");
								sbSql.append(")");
							}
							%>
							<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by codigo_almacen","codigo_almacen_ua",(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"almacen_cds").equals("")?SecMgr.getParValue(UserDet,"almacen_ua"):""),false,false,0,null,null,"onChange=\"javascript:document.form3.submit()\"")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right"><!--<%=fb.submit("save","Guardar",true,false,null,null,null)%>-->
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%> </td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB3 DIV END HERE-->
					<!-- TAB4 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","4")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="80%">
							<%sbSql= new StringBuffer();
							if(!UserDet.getUserProfile().contains("0"))
							{
								sbSql.append(" and codigo in (");
									if(session.getAttribute("_cds")!=null)
										sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
									else sbSql.append("-1");
								sbSql.append(")");
							}
							%>
								<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where estado = 'A' and compania_unorg = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","cds",(SecMgr.getParValue(UserDet,"cds")!=null && !SecMgr.getParValue(UserDet,"cds").equals("")?SecMgr.getParValue(UserDet,"cds"):""),false,false,0, "text10", "", "onChange=\"javascript:document.form4.submit()\"",null," ")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right"><!--<%=fb.submit("save","Guardar",true,false,null,null,null)%>-->
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%> </td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB4 DIV END HERE-->
					<!-- TAB5 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","5")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
							<td width="80%">
							<%sbSql= new StringBuffer();
							if(!UserDet.getUserProfile().contains("0"))
							{
								sbSql.append(" and codigo in (");
									if(session.getAttribute("_ua")!=null)
										sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")));
									else sbSql.append("-1");
								sbSql.append(")");
							}
							%>
								<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_sec_unidad_ejec where nivel = 3 and compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","ua",(SecMgr.getParValue(UserDet,"ua")!=null && !SecMgr.getParValue(UserDet,"ua").equals("")?SecMgr.getParValue(UserDet,"ua"):""),false,false,0, "text10", "", "onChange=\"javascript:document.form5.submit()\"")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right"><!--<%=fb.submit("save","Guardar",true,false,null,null,null)%>-->
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%> </td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB5 DIV END HERE-->
					<!-- TAB6 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","6")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Almac&eacute;n - Inventario</cellbytelabel>.</td>
							<td width="80%">
							<%sbSql= new StringBuffer();
							if(!UserDet.getUserProfile().contains("0"))
							{
								sbSql.append(" and codigo_almacen in (");
									if(session.getAttribute("_almacen_inv")!=null)
										sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_inv")));
									else sbSql.append("-2");
								sbSql.append(")");
							}
							%>
							<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId") +sbSql.toString()+ " order by codigo_almacen","codigo_almacen_inv",(SecMgr.getParValue(UserDet,"almacen_inv")!=null && !SecMgr.getParValue(UserDet,"almacen_inv").equals("")?SecMgr.getParValue(UserDet,"almacen_inv"):""),false,false,0,null,null,"onChange=\"javascript:this.form.submit()\"")%>
							</td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right">
								<!--<%=fb.submit("save","Guardar",true,false,null,null,null)%>-->
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
							</td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB6 DIV END HERE-->
					<!-- TAB7 DIV START HERE-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","7")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Idioma</cellbytelabel></td>
							<td width="80%"><%=fb.select("lang","es=ESPAÑOL,en=ENGLISH",((session.getAttribute("_locale") == null)?"":((java.util.Locale) session.getAttribute("_locale")).getLanguage()),false,false,0,"Text10",null,"onChange=\"javascript:this.form.submit();\"")%></td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>
					<!-- TAB8 DIV START HERE DGI IMPRESORA HTTP-->
					<div class="dhtmlgoodies_aTab">
						<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
						<%fb = new FormBean("form8",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("tab","8")%>
						<%=fb.hidden("fp",fp)%>
						<tr class="TextRow02">
							<td colspan="42" align="right">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>DGI Printer Connection</cellbytelabel></td>
							<td width="80%"><input type="text" id="dgiPrinter" name = "dgiPrinter" value = "<%=(SecMgr.getParValue(UserDet,"DGI")!=null && !SecMgr.getParValue(UserDet,"DGI").equals("")?SecMgr.getParValue(UserDet,"DGI"):"")%>" class="FormDataObject" size="12" maxLength="18" style="text-align:right;"></td>
						</tr>
						<tr class="TextRow02">
							<td colspan="4" align="right">
							<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:this.form.submit();\"")%>
							<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
						</tr>
						<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</div>

					<!-- TAB8 DIV END HERE-->
				</div>
				<!-- MAIN DIV END HERE -->
				<script type="text/javascript">initTabs('dhtmlgoodies_tabView1',Array('Cambiar Compañía','Cambiar Contraseña','Almacén Cds','Almacén Unid. Adm.','Centro de Servicio','Unidad Adm.','Almacenes - Invantario','Idioma','Fiscal Printer'),<%=tab%>,'100%','','','','',<%=(fp.trim().equalsIgnoreCase("newpass"))?"[0,2,3,4,5,6,7,8]":(fp.trim().equalsIgnoreCase("pm"))?"[1,2,3,4,5,6,7,8]":"''"%>);</script>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String errCode = "";
	String errMsg = "";
	if (tab.trim().equals("0"))//Cambiar Compañia
	{
		String compId = request.getParameter("compId");
		if (compId == null) throw new Exception("La Compañía no es válida. Por favor intente nuevamente!");
		ConMgr.setSessionCtx("company",compId);
		//java.util.ResourceBundle.getBundle("path").getString("companyimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),request.getContextPath())+"/"
		//String sql = "select codigo, nombre, nvl(actividad,' ') as actividad, nvl(representante_legal,' ') as representanteLegal, direccion, telefono, nvl(fax,' ') as fax, nvl(email,' ') as email, nvl(digito_verificador,' ') as digitoVerificador, nvl(ruc,' ') as ruc, nvl(substr(replace(logo,'\\','/'),instr(replace(logo,'\\','/'),'/',-1) + 1),' ') as logo, nvl(apartado_postal,' ') as apartadoPostal, nvl(zona_postal,' ') as zonaPostal, decode(pais,null,' ',pais) as pais, decode(distrito,null,' ',distrito) as distrito, decode(provincia,null,' ',provincia) as provincia, decode(corregimiento,null,' ',corregimiento) as corregimiento, decode(porc_farhosp,null,' ',porc_farhosp) as porcFarhosp, nvl(num_patronal,' ') as numPatronal, nvl(cedula_juridica,' ') as cedulaJuridica, nvl(cedula_natural,' ') as cedulaNatural, nvl(licencia,' ') as licencia, impuesto, nombre_corto nombreCorto,nvl(hospital,'N')hospital from tbl_sec_compania where codigo="+compId;
		CommonDataObject cdoQry = new CommonDataObject();
	cdoQry=SQLMgr.getData("select query from tbl_gen_query where id = 2 and refer_to = 'COMP'");
	//String sql="select * from()";

		System.out.println("SQL="+cdoQry.getColValue("query"));
		Compania comp = (Compania) sbb.getSingleRowBean(ConMgr.getConnection(),cdoQry.getColValue("query").replace("@@compania",compId),Compania.class);
		session.setAttribute("_companyId",compId);
		session.setAttribute("_comp",comp);
		session.setAttribute("_taxPercent",comp.getImpuesto());

		UserDetail ud = null;
		try { ud = (UserDetail) session.getAttribute("UserDet"); } catch(Exception ex) { ud = new UserDetail(); }

		HttpSession userSession = (HttpSession) _appUsers.get((String)session.getAttribute("_userName"));
		SecurityMgr userSecMgr = null;
		try {
			userSecMgr = (SecurityMgr) userSession.getAttribute("SecMgr");
			userSession.setAttribute("__ResetBy__",session.getAttribute("_userName"));
			userSecMgr.resetUserSession(userSession,ud.getUserId());
			userSession.setAttribute("SecMgr",userSecMgr);
		} catch (Exception e) {
			throw new Exception("Ocurrió un error al intentar actualizar la sesión del usuario!");
		} finally {
			userSession = null;
			userSecMgr = null;
		}
	}
	else if (tab.trim().equals("1")) //Cambiar Contraseña
	{
		UserDetail user = new UserDetail();

		user.setUserId(UserDet.getUserId());
		user.setOldPassword(request.getParameter("oldPassword"));
		user.setUserPassword(request.getParameter("password"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UserMgr.updatePassword(user);
		errCode = UserMgr.getErrCode();
		errMsg = UserMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
	else if (tab.trim().equals("2")) //Almacenes Cds
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("almacen_cds");
		up.setValue(request.getParameter("codigo_almacen_cds"));
		up.setModule("NA");
		up.setStatus("A");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UPMgr.add(UserDet, up);
		errCode = UPMgr.getErrCode();
		errMsg = UPMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
		UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
	else if (tab.trim().equals("3")) //Almacenes Unidad Adm.
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("almacen_ua");
		up.setValue(request.getParameter("codigo_almacen_ua"));
		up.setModule("NA");
		up.setStatus("A");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UPMgr.add(UserDet, up);
		errCode = UPMgr.getErrCode();
		errMsg = UPMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
		UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
	else if (tab.trim().equals("4")) //Centro de Servicio
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("cds");
		up.setValue(request.getParameter("cds"));
		up.setModule("NA");
		up.setStatus("A");

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (request.getParameter("cds") != null && request.getParameter("cds").trim().equals("")) {
			SQLMgr.execute("delete from tbl_sec_userpref where user_id = "+UserDet.getUserId()+" and parameter = 'cds'");
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
		} else {
			UPMgr.add(UserDet, up);
			errCode = UPMgr.getErrCode();
			errMsg = UPMgr.getErrMsg();
		}
		ConMgr.clearAppCtx(null);
		if (errCode.equals("1")) UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
	else if (tab.trim().equals("5")) //Unidad Adm.
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("ua");
		up.setValue(request.getParameter("ua"));
		up.setModule("NA");
		up.setStatus("A");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UPMgr.add(UserDet, up);
		errCode = UPMgr.getErrCode();
		errMsg = UPMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
		UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
	else if (tab.trim().equals("6")) //Almacenes Inventario
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("almacen_inv");
		up.setValue(request.getParameter("codigo_almacen_inv"));
		up.setModule("NA");
		up.setStatus("A");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UPMgr.add(UserDet, up);
		errCode = UPMgr.getErrCode();
		errMsg = UPMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
		UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
	else if (tab.trim().equals("7")) //Idioma
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("lang");
		up.setValue(request.getParameter("lang"));
		up.setModule("NA");
		up.setStatus("A");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UPMgr.add(UserDet, up);
		if (UPMgr.getErrCode().equals("1")) session.setAttribute("_locale",new java.util.Locale(request.getParameter("lang")));
		errCode = UPMgr.getErrCode();
		errMsg = UPMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
		UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
	else if (tab.trim().equals("8")) //DGI Printer
	{
		UserPref up = new UserPref();

		up.setUserId(UserDet.getUserId());
		up.setParameter("DGI");
		up.setValue(request.getParameter("dgiPrinter"));
		up.setModule("DGI");
		up.setStatus("A");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		UPMgr.add(UserDet, up);
		errCode = UPMgr.getErrCode();
		errMsg = UPMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
		UserDet.getUserPref().put(up.getParameter().trim(),up);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (tab.trim().equals("0") || tab.trim().equals("2") || tab.trim().equals("3") || tab.trim().equals("4") || tab.trim().equals("5") || tab.trim().equals("6")|| tab.trim().equals("7"))
{
%>
//	alert('<%=java.util.ResourceBundle.getBundle("path").getString("companyimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),request.getContextPath())+"/"+((((issi.admin.Compania) session.getAttribute("_comp")).getLogo().trim().equals(""))?"company_logo.gif":((issi.admin.Compania) session.getAttribute("_comp")).getLogo())%>');
	//window.opener.parent.document.getElementById("_companyLogo").src='<%=java.util.ResourceBundle.getBundle("path").getString("companyimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),request.getContextPath())+"/"+((((issi.admin.Compania) session.getAttribute("_comp")).getLogo().trim().equals(""))?"company_logo.gif":((issi.admin.Compania) session.getAttribute("_comp")).getLogo())%>';
	window.opener.top.frames[2].useTopWinArray=true;
	window.opener.top.frames[2].location.reload(true);//0=menu iframe, 1=unloadFrame iframe 2=content iframe
	window.close();
<%
}
else
{
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
	<% if (fp.trim().equalsIgnoreCase("newpass")) { %>/*alert('Ingrese nuevamente al sistema con su nueva contraseña!');window.location='../logout.jsp';*/window.location='../main.jsp';<% } else {%>window.close();<% } %>
<%
} else throw new Exception(errMsg);
}
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
