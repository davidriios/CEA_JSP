
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
200007	AGREGAR ANAQUEL POR ALMACENES
200008	MODIFICAR ANAQUEL POR ALMACENES
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200007") || SecMgr.checkAccess(session.getId(),"200008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String almacen=request.getParameter("almacen");


if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (almacen == null && id == null) throw new Exception("El Anaquel por Almac&eacute;n no es válido. Por favor intente nuevamente!");

		sql = "select a.compania, a.codigo_almacen as almacen, a.codigo, a.descripcion as name, b.codigo_almacen as co, b.descripcion as nombre ,a.consignacion, a.cod_anaquel from tbl_inv_anaqueles_x_almacen a, tbl_inv_almacen b where a.CODIGO_ALMACEN= b.CODIGO_ALMACEN and a.codigo="+id+" and a.compania = b.compania and a.codigo_almacen = "+almacen+" and a.compania = "+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Anaqueles por Almacen - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Anaqueles por Almacen - Edición - "+document.title;
<%}%>
</script>
<script language="javascript"> 
function checkArticulo(wh)
{
var almacen = document.form1.wh.value; 
var anaquel = document.form1.id.value; 


if(almacen!=wh && '<%=mode%>'!='add')
{
	var cont = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_inv_inventario','compania=<%=(String) session.getAttribute("_companyId")%> and codigo_almacen='+almacen+' and codigo_anaquel='+anaquel));
	var  an = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_inv_anaqueles_x_almacen','compania=<%=(String) session.getAttribute("_companyId")%> and codigo_almacen='+wh+' and codigo='+anaquel));
	var msg='';
	if(cont!=0||an!=0){
	if(cont!=0) msg +=': existen articulos asignados ';
	if(an!=0)if(msg!='')msg +=', existe otro anaquel con el mismo Codigo ';
	if(msg!='')msg +=', en el almacen seleccionado.';
	
	CBMSG.warning('No es posible cambiar el almacen del anaquel # '+anaquel+' '+msg);
	document.form1.almacen.value=almacen; 
	document.form1.upd.value="N"; 

	}else document.form1.upd.value="S"; 
}
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ANAQUELES POR ALMACEN"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("wh",cdo.getColValue("almacen"))%>
			<%=fb.hidden("upd","")%>
			
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;Almac&eacute;n</td>
				</tr>	
				<tr class="TextRow01" >
					<td width="17%">&nbsp;C&oacute;digo</td>
					<td width="83%">&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen","almacen",cdo.getColValue("almacen"),false,false,0,"",null,"onChange=\"javascript:checkArticulo(this.value)\"")%>
				
				</td>	
				</tr>	
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;Anaqueles</td>
				</tr>					
				<tr class="TextRow01" >
					<td>&nbsp;C&oacute;digo</td>
					<td>&nbsp;<%=fb.textBox("cod_anaquel",(cdo.getColValue("cod_anaquel")!=null && !cdo.getColValue("cod_anaquel").equals("")?cdo.getColValue("cod_anaquel"):cdo.getColValue("name")),true,false,false,55)%></td>
				</tr>	
				<tr class="TextRow01" >
					<td>&nbsp;Descripcion</td>
					<td>&nbsp;<%=fb.textBox("name",cdo.getColValue("name"),true,false,false,55)%></td>
				</tr>	
				<tr class="TextRow01" >
					<td>&nbsp;Consignaci&oacute;n??</td>
					<td>&nbsp;<%=fb.checkbox("consignacion","S",(cdo.getColValue("consignacion") != null && cdo.getColValue("consignacion").trim().equals("S")),false)%></td>
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_inv_anaqueles_x_almacen");  
  cdo.addColValue("descripcion",request.getParameter("name")); 
   	if (request.getParameter("consignacion") != null && !request.getParameter("consignacion").trim().equals("")&& request.getParameter("consignacion").trim().equals("S"))
	cdo.addColValue("consignacion",request.getParameter("consignacion")); 
	else cdo.addColValue("consignacion","N");
	if(request.getParameter("cod_anaquel")!=null && !request.getParameter("cod_anaquel").equals("")) cdo.addColValue("cod_anaquel", request.getParameter("cod_anaquel"));
	
	
  if (mode.equalsIgnoreCase("add"))
  { 
    cdo.addColValue("codigo_almacen",request.getParameter("almacen"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncCol("codigo");
	SQLMgr.insert(cdo);
  }
  else
  {
    if(request.getParameter("upd")!=null && !request.getParameter("upd").equals("")&& request.getParameter("upd").equals("S")) cdo.addColValue("codigo_almacen",request.getParameter("almacen"));
	cdo.setWhereClause("codigo="+request.getParameter("id")+" and compania="+(String)session.getAttribute("_companyId")+" and codigo_almacen="+request.getParameter("wh"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/anaqueles_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/anaqueles_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/anaqueles_list.jsp';
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
