<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
fb = new FormBean("compania",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("La Compañia no es válida. Por favor intente nuevamente!");

		sql = "";
		cdo = SQLMgr.getData(sql);
	}
%>
<html>   
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Compañia Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Compañia Edición - "+document.title;
<%}%>

function add()
{
  abrir_ventana1('ubic_geografica_list.jsp'); 			  	  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - MANTENIMIENTO - COMPANIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">			
            
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">Generales de la Compa&ntilde;ia</td>
				</tr>
				<tr class="TextRow01">
					<td width="17%">Nombre</td>
					<td width="35%"><%=fb.textBox("codigo",cdo.getColValue("codigo"),false,false,true,5)%><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,30)%></td>							
					<td width="15%">Actividad</td>
					<td width="33%"><%=fb.textBox("actividad",cdo.getColValue("actividad"),false,false,false,40)%></td>             			
				</tr>
				<tr class="TextRow01">
					<td>Representante Legal</td>
					<td><%=fb.textBox("repreLegal",cdo.getColValue("repreLegal"),false,false,false,40)%></td>								
					<td>Ruc.</td>
					<td><%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,false,40)%></td>
				</tr>
				<tr class="TextRow01">
					<td>N&uacute;mero de Tel&eacute;fono</td>
					<td><%=fb.textBox("ntelefono",cdo.getColValue("ntelefono"),false,false,false,40)%></td>								
					<td>N&uacute;mero de Fax</td>
					<td><%=fb.textBox("nfax",cdo.getColValue("nfax"),false,false,false,40)%></td>
				</tr>				
				<tr class="TextRow01">
					<td>C&eacute;dula Jur&iacute;dica</td>
					<td><%=fb.textBox("cedJuridica",cdo.getColValue("cedJuridica"),false,false,false,40)%></td>								
					<td>N&uacute;mero Patronal</td>
					<td><%=fb.textBox("numPatronal",cdo.getColValue("numPatronal"),false,false,false,40)%></td>
				</tr>
				<tr class="TextRow01">
					<td>E-mail</td>
					<td><%=fb.textBox("email",cdo.getColValue("email"),false,false,false,40)%></td>								
					<td>Apto. Postal</td>
					<td><%=fb.textBox("apartado",cdo.getColValue("apartado"),false,false,false,40)%></td>	
				</tr>
				<tr class="TextRow01">							
					<td>Zona Postal</td>
					<td><%=fb.textBox("zona",cdo.getColValue("zona"),false,false,false,40)%></td>
					<td>Direcci&oacute;n</td>
					<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,40)%>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">Ubicaci&oacute;n Geogr&aacute;fica</td>
				</tr>							
				<tr class="TextRow01">
					<td>Pa&iacute;s</td>
					<td><%=fb.intBox("paisCode",cdo.getColValue("paisCode"),false,false,true,5)%><%=fb.textBox("pais",cdo.getColValue("pais"),false,false,true,30)%><%=fb.button("btnpais","...",true,false,null,null,"onClick=\"javascript:add()\"")%></td>								
					<td>Distrito</td>
					<td><%=fb.intBox("distCode",cdo.getColValue("distCode"),false,false,true,5)%><%=fb.textBox("distrito",cdo.getColValue("distrito"),false,false,true,30)%></td>
				</tr>
				<tr class="TextRow01">
					<td>Provincia</td>
					<td><%=fb.intBox("provCode",cdo.getColValue("provCode"),false,false,true,5)%><%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,30)%></td>								
					<td>Corregimiento</td>
					<td><%=fb.intBox("corregiCode",cdo.getColValue("corregiCode"),false,false,true,5)%><%=fb.textBox("corregimiento",cdo.getColValue("corregimiento"),false,false,true,30)%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="4">
					<%=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>	
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  cdo = new CommonDataObject();

  

  if (mode.equalsIgnoreCase("add"))
  {
	

	SQLMgr.insert(cdo);
  }
  else
  {
  

	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/company_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/company_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/company_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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