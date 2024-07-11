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
900035	AGREGAR GRUPO DE REPORTE
900036	MODIFICAR GRUPO DE REPORTE
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900035") || SecMgr.checkAccess(session.getId(),"900036"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String repCode=request.getParameter("repCode");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";		
		CommonDataObject cdoDet = SQLMgr.getData("select codigo as reportCode, descripcion as reporte from tbl_con_reporte where  codigo="+repCode+" and compania="+(String) session.getAttribute("_companyId"));
		cdo.addColValue("cod_rep",cdoDet.getColValue("reportCode"));
		cdo.addColValue("reporte",cdoDet.getColValue("reporte"));
	}
	else
	{
		if (id == null) throw new Exception("El Grupo de Reporte no es válido. Por favor intente nuevamente!");
		if (repCode == null) throw new Exception("El Reporte no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.codigo, a.descripcion, a.cod_rep, a.nota, a.pertenece, b.descripcion as reporte, a.orden, a.es_total, a.aum_dis FROM tbl_con_grupos_rep a, tbl_con_reporte b WHERE a.cod_rep = b.codigo and a.compania=b.compania and a.codigo="+id+" and a.cod_rep="+repCode+" and a.compania="+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction();">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Grupo Reporte Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Grupo Reporte Edición - "+document.title;
<%}%>
function doAction(){
	chkThis();
}
function addRep()
{
  abrir_ventana1('grupo_reportes_list.jsp')
}

function chkThis(){
	var val = document.getElementById('es_total').value;
	if(val=='S'){
		document.getElementById('trSelect').style.display='';
	} else {
		document.getElementById('trSelect').style.display='none';
	}
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("repCode",repCode)%>
		
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>						
			<tr class="TextRow01">
				<td width="20%">Reporte</td>
				<td width="80%"><%=cdo.getColValue("cod_rep")%> - <%=cdo.getColValue("reporte")%></td>
			</tr>								
			<tr class="TextRow01">
				<td>Grupo</td>
				<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,5)%><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,49)%></td>
			</tr>
			<tr class="TextRow01">
				<!--<td>Tipo de Reporte</td>-->
				<td>Orden</td>				
				<td align="left">
<%//=fb.select(ConMgr.getConnection(),"Select codigo, descripcion From tbl_con_grupos_rep_consol Where cod_rep="+5,"tipo",cdo.getColValue("pertenece"))%>
        &nbsp;&nbsp;&nbsp;<%=fb.intBox("orden",cdo.getColValue("orden"),false,false,false,4, 4)%>
        &nbsp;
        Tipo L&iacute;nea:&nbsp;<%=fb.select("es_total", "N=Normal, S=Sub-Total, T=Total", cdo.getColValue("es_total"), false, false, 0, "", "", "onChange=\"javascript:chkThis(this.value);\"")%><div id="divSelect"></div>
				</td>
			</tr>
			<tr class="TextRow01" id="trSelect" style="display:none">
				<td>Este Subtotal</td>				
				<td align="left">
        <%=fb.select("aum_dis", "+=Aumenta, -=Disminuye", cdo.getColValue("aum_dis"), false, false, 0, "", "", "")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>Anular?</td>				
				<td align="left">
        <%=fb.select("anular", "N=No, S=Si", "", false, false, 0, "", "", "")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>Notas</td>
				<td><%=fb.textarea("nota",cdo.getColValue("nota"),false,false,false,46,6)%></td>
			</tr>					
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  repCode = request.getParameter("repCode");
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_grupos_rep");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));   
  cdo.addColValue("nota",request.getParameter("nota"));
 // cdo.addColValue("pertenece",request.getParameter("tipo"));
	cdo.addColValue("es_total",request.getParameter("es_total"));
	if(cdo.getColValue("es_total").equals("S")) cdo.addColValue("aum_dis", request.getParameter("aum_dis"));
	if(request.getParameter("orden")!=null && !request.getParameter("orden").equals("")) cdo.addColValue("orden",request.getParameter("orden"));
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("cod_rep",repCode);
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_rep="+repCode);
	cdo.setAutoIncCol("codigo");
	SQLMgr.insert(cdo);
  }
  else
  {
    if(request.getParameter("anular")!=null && request.getParameter("anular").equals("S")){
		SQLMgr.execute("call sp_con_anula_grupo("+repCode+", "+request.getParameter("id")+", "+(String) session.getAttribute("_companyId")+")");
	} else {
		cdo.setWhereClause("codigo="+request.getParameter("id")+" and cod_rep="+repCode+" and compania="+(String) session.getAttribute("_companyId"));
		SQLMgr.update(cdo);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/gruporeportes_list.jsp?repCode="+repCode))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/gruporeportes_list.jsp?repCode="+repCode)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/gruporeportes_list.jsp?repCode=<%=repCode%>';
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