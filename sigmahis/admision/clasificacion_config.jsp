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
400015	AGREGAR CLASIFICACION POR TIPO DE ADMISION
400016	MODIFICAR CLASIFICACION POR TIPO DE ADMISION
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"400015") || SecMgr.checkAccess(session.getId(),"400016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String tipoCode = request.getParameter("tipoCode");
String catCode = request.getParameter("catCode");


fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
    code = "0";
		sql = "select categoria as catCode, tipo as tipoCode from tbl_adm_clasif_x_tipo_adm order by categoria, tipo";
		cdo = SQLMgr.getData(sql);
		if(cdo==null) cdo = new CommonDataObject();
	}
	else
	{
		if (code == null) throw new Exception("La Clasificación de Admisión no es válida. Por favor intente nuevamente!");
		if (catCode == null) throw new Exception("La Categoría de Admisión no es válida. Por favor intente nuevamente!");
		if (tipoCode == null) throw new Exception("El Tipo de Admisión no es válido. Por favor intente nuevamente!");
		
		sql = "select a.codigo, a.descripcion, a.categoria as catCode, a.tipo as tipoCode, b.descripcion as catDesc, c.descripcion as tipoDesc from tbl_adm_clasif_x_tipo_adm a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_cia c where a.categoria=b.codigo and a.categoria=c.categoria and a.tipo=c.codigo and a.categoria="+catCode+" and a.tipo="+tipoCode+" and a.codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Clasificación Admisión Edición - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNCA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
			<%=fb.hidden("catCode",cdo.getColValue("catCode"))%>
			<%=fb.hidden("tipoCode",cdo.getColValue("tipoCode"))%>    
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>				
				<tr class="TextRow01">
					<td>Categor&iacute;a</td>
					<td><%=fb.select(ConMgr.getConnection(), "Select codigo, descripcion From tbl_adm_categoria_admision order by descripcion","categoria", cdo.getColValue("catCode"),false,mode.equals("edit"),0,null,null,"onChange=\"javascript:loadXML('../xml/itemTipo.xml','tipo','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','')\"")%></td>
				</tr>						
				<tr class="TextRow01">
					<td>Tipo</td>
					<td><%=fb.select("tipo","","",false,mode.equals("edit"),0)%>
                        <script language="javascript">
			                    loadXML('../xml/itemTipo.xml','tipo','<%=cdo.getColValue("tipoCode")%>','VALUE_COL','LABEL_COL','<%=cdo.getColValue("catCode")%>','KEY_COL','');
			            </script>
					</td>
				</tr>						
				<tr class="TextRow01">
					<td width="12%">C&oacute;digo</td>
					<td width="88%"><%=code%></td>				
				</tr>							
				<tr class="TextRow01">
					<td>Descripci&oacute;n</td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
				</tr>						
                <tr class="TextRow02">
			        <td colspan="2" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
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

  cdo.setTableName("tbl_adm_clasif_x_tipo_adm");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("categoria",request.getParameter("categoria")); 
  cdo.addColValue("tipo",request.getParameter("tipo"));
  
  if (mode.equalsIgnoreCase("add"))
  {
		cdo.setAutoIncCol("codigo");
		cdo.setAutoIncWhereClause("categoria="+request.getParameter("categoria")+" and tipo="+request.getParameter("tipo"));
	     
		SQLMgr.insert(cdo);
  }
  else
  {
        cdo.setWhereClause("categoria="+request.getParameter("catCode")+" and tipo="+request.getParameter("tipoCode")+" and codigo="+request.getParameter("codigo"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/clasificacion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/clasificacion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/clasificacion_list.jsp';
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