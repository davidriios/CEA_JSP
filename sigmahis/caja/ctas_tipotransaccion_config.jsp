<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cta = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("code");
int size = 0;
String filter = " and recibe_mov='S'";

if (tab == null) tab = "0";
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Tipo Transacción no es válido. Por favor intente nuevamente!");

		sql = "SELECT codigo, descripcion FROM tbl_cja_tipo_transaccion WHERE codigo="+id;
		cdo = SQLMgr.getData(sql);

		sql = "SELECT a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as cuenta FROM tbl_con_conta_transaccion_cta a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania=b.compania and a.codigo="+id+" and a.compania="+(String) session.getAttribute("_companyId");
		
		cta = SQLMgr.getData(sql); 		  	
		size = CmnMgr.getCount(sql);
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Cuentas Asociadas a Tipo de Transacción -  Edición - '+document.title;
function addCuenta()
{
   abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=22&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - MANTENIMIENTO - CTAS. ASOCIADAS A TIPOS DE TRANSACCIÓN"></jsp:param>
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

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<cellbytelabel>Tipo Transacci&oacute;n</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="12%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							    <td width="88%"><%=fb.intBox("codigo",id,false,false,true,30)%></td>							
							</tr>
							<tr  class="TextRow01"> 	
							    <td>Descripci&oacute;n</td>
							    <td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,60,100)%></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+size)%>


					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Cuenta Contable</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="15%"><cellbytelabel>Cuenta Contable</cellbytelabel></td>
								<td width="85%"><%=fb.textBox("cta1",cta.getColValue("cta1"),false,false,true,3)%><%=fb.textBox("cta2",cta.getColValue("cta2"),false,false,true,3)%><%=fb.textBox("cta3",cta.getColValue("cta3"),false,false,true,3)%><%=fb.textBox("cta4",cta.getColValue("cta4"),false,false,true,3)%><%=fb.textBox("cta5",cta.getColValue("cta5"),false,false,true,3)%><%=fb.textBox("cta6",cta.getColValue("cta6"),false,false,true,3)%><%=fb.textBox("cuenta",cta.getColValue("cuenta"),false,false,true,50)%><%=fb.button("btnCuenta","...",true,false,null,null,"onClick=\"javascript:window.addCuenta()\"")%></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Principal'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Principal','Cuenta Contable'),<%=tab%>,'100%','');
<%
}
%>
</script>

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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
    id = request.getParameter("id"); 
	 
	if (tab.equals("0")) //TIPOS DE TRANSACCIONES
	{
		cdo = new CommonDataObject();

   	    cdo.setTableName("tbl_cja_tipo_transaccion");
		cdo.addColValue("descripcion",request.getParameter("descripcion"));
		
	    if (mode.equalsIgnoreCase("add"))
		{
		   cdo.addColValue("user_creacion",(String) session.getAttribute("_userName"));
		   cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		   cdo.setAutoIncCol("codigo");
		   SQLMgr.insert(cdo);	
		}
		else
		{
		   cdo.setWhereClause("codigo="+id);
		   cdo.addColValue("user_modificacion",(String) session.getAttribute("_userName"));
		   cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		   SQLMgr.update(cdo);
		}
		
	}
	else if (tab.equals("1")) //CUENTA CONTABLE 
	{	
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_con_conta_transaccion_cta");  
		cdo.addColValue("cta1",request.getParameter("cta1"));
		cdo.addColValue("cta2",request.getParameter("cta2"));
		cdo.addColValue("cta3",request.getParameter("cta3"));
		cdo.addColValue("cta4",request.getParameter("cta4"));
		cdo.addColValue("cta5",request.getParameter("cta5"));
		cdo.addColValue("cta6",request.getParameter("cta6"));	
		
		if (request.getParameter("size").equals("0"))
		{		  
		   cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
		   cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		   cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		   cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		   cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		   cdo.addColValue("codigo",id);		   
		   SQLMgr.insert(cdo);	
		}
		else
		{
		   cdo.setWhereClause("codigo="+id+" and compania="+(String) session.getAttribute("_companyId"));
		   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		   cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
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
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/ctas_tipotransaccion_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/ctas_tipotransaccion_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/ctas_tipotransaccion_list.jsp';
<%
		}
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&code=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>