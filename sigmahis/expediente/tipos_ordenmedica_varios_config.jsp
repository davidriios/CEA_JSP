<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.TiposOrdenVarios"%>
<%@ page import="issi.expediente.SubtipoOrdenVarios"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

TiposOrdenVarios td = new TiposOrdenVarios();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
int lastLineNo = 0;

if (mode == null) mode = "add";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
	    HashDet.clear();
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Dieta no es v�lido. Por favor intente nuevamente!");

		sql = "SELECT codigo, descripcion, observacion,estatus FROM TBL_CDS_ORDENMEDICA_VARIOS WHERE codigo="+id;
		td = (TiposOrdenVarios) sbb.getSingleRowBean(ConMgr.getConnection(),sql, TiposOrdenVarios.class);		
		
		if (change == null)
		{
			sql = "SELECT 'A' status, codigo, cod_tipo_ordenvarios, descripcion, observacion FROM TBL_CDS_OM_VARIOS_SUBTIPO WHERE COD_TIPO_ORDENVARIOS="+id+" ORDER BY codigo";
            al = sbb.getBeanList(ConMgr.getConnection(), sql, SubtipoOrdenVarios.class);

            HashDet.clear(); 
			lastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  HashDet.put(key, al.get(i-1));			
		    }  	 			
		}
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript" src="<%=request.getContextPath()%>/js/iframes_jq.js"></script>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipos de Dieta - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipos de Dieta - Edici�n - "+document.title;
<%}%>

function adjustIFrameSize (iframeWindow) 
{
	if (iframeWindow.document.height) {
	var iframeElement = document.getElementById (iframeWindow.name);
	iframeElement.style.height = (parseInt(iframeWindow.document.height,10) + 16) + 'px';
//            iframeElement.style.width = iframeWindow.document.width + 'px';
	}
	else if (document.all) {
	var iframeElement = document.all[iframeWindow.name];
	if (iframeWindow.document.compatMode &&
	iframeWindow.document.compatMode != 'BackCompat')
	{
	iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 5 + 'px';
	}
	else {
	iframeElement.style.height = iframeWindow.document.body.scrollHeight + 5 + 'px';
	}
	}
}
function saveMethod()
{
  if (form0Validation())
  {  
     window.frames['subTipo'].formSub.baction.value = "Guardar";
     window.frames['subTipo'].doSubmit();
  }  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
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
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Tipos de Dietas</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							
							<tr class="TextRow01">
								<td width="8%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							    <td width="34%"><%=fb.intBox("codigo",id,false,false,true,30,3)%></td>														
								<td width="14%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
							    <td width="2%"><%=fb.textBox("descripcion",td.getDescripcion(),true,false,false,50,50)%></td>							
							</tr>	
							
							<tr class="TextRow01">
								<td width="8%"><cellbytelabel id="4">Observaci&oacute;n</cellbytelabel></td>
						        <td width="34%"><%=fb.textarea("observacion",td.getObservacion(),false,false,false,58,4)%></td>
								<td width="14%"><cellbytelabel id="5">Estatus</cellbytelabel></td>
							    <td width="36%" colspan="3"><%=fb.select("estatus","A=Activo,I=Inactivo",td.getEstatus(),false,false,0)%></td>																											
							</tr>														
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<cellbytelabel id="6">Subtipos de Dietas</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<iframe name="subTipo" id="subTipo" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../expediente/subtipos_ordenmedica_varios_config.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>&id=<%=id%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="8">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="9">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="10">Cerrar</cellbytelabel> 
						<%=fb.button("save","Guardar",false,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/tipos_ordenmedica_varios_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/tipos_ordenmedica_varios_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/tipos_ordenmedica_varios_list.jsp';
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