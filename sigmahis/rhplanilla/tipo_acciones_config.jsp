<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.rhplanilla.TipoAccion"%>
<%@ page import="issi.rhplanilla.SubTipoAccion"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTAccion" scope="session" class="java.util.Hashtable" />
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

TipoAccion tip = new TipoAccion();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
int accionLastLineNo = 0;

if (mode == null) mode = "add";
if (request.getParameter("accionLastLineNo") != null) accionLastLineNo = Integer.parseInt(request.getParameter("accionLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
	    iTAccion.clear();
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Transacciones no es válido. Por favor intente nuevamente!");
		
		sql = "SELECT codigo, nvl(descripcion,'') as descripcion FROM tbl_pla_ap_tipo_accion WHERE codigo="+id+"";
		tip = (TipoAccion) sbb.getSingleRowBean(ConMgr.getConnection(),sql, TipoAccion.class);		

		if (change == null)
		{
			sql = "SELECT tipo_accion, codigo, descripcion from tbl_pla_ap_sub_tipo  WHERE tipo_accion="+id+" ORDER BY codigo";
            al = sbb.getBeanList(ConMgr.getConnection(), sql, SubTipoAccion.class);

            iTAccion.clear(); 
			accionLastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;
				try
				{
			       iTAccion.put(key, al.get(i-1));	
				}	
				catch(Exception e)
				{
				 System.err.println(e.getMessage()); 
				}		
		    }  	 			
		}
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipos de Acciones - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipos de Acciones - Edición - "+document.title;
<%}%>

function saveMethod()
{
	 window.frames['itemFrame'].formSub.baction.value = "Guardar";
	 //if(form0Validation()){form0BlockButtons(false); 
	  window.frames['itemFrame'].doSubmit();
	 //document.form0.baction.value     = "Guardar"; 

	//window.frames['iDetalle0'].doSubmit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RHPLANILLA - MANTENIMIENTO - ACCIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>	
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("accionLastLineNo",""+accionLastLineNo)%>
<%=fb.hidden("iTSize",""+iTAccion.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Tipos de Acciones</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="10%">C&oacute;digo</td>
							    <td width="30%"><%=fb.intBox("codigo",id,false,false,true,10,2)%></td>														
								<td width="15%">Descripci&oacute;n</td>
							    <td width="45%"><%=fb.textBox("descripcion",tip.getDescripcion(),true,false,false,50,30)%></td>							
							</tr>														
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;SubTipos de Acciones</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../rhplanilla/sub_tipoaccion.jsp?mode=<%=mode%>&accionLastLineNo=<%=accionLastLineNo%>&id=<%=id%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
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
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/tipo_accion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/tipo_accion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/tipo_accion_list.jsp';
<%
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{	
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>