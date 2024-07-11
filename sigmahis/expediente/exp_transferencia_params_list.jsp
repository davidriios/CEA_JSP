<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String company = (String)session.getAttribute("_companyId");
String tipo = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String descripcion = request.getParameter("descripcion")==null?"":request.getParameter("descripcion");
String status = request.getParameter("status")==null?"":request.getParameter("status");
String appendFilter = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (!tipo.trim().equals("") && !tipo.trim().equals("T")) appendFilter += " and tipo = "+tipo;
if (!descripcion.trim().equals("")) appendFilter += " and descripcion like '%"+descripcion+"%'";
if (!status.trim().equals("") && !status.trim().equals("T")) appendFilter += " and status = '"+status+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
{

sql="select tipo, decode(tipo,1,'CONDICION DEL PACIENTE EN EL MOMENTO DE TRASLADO',2,'REQUERIMIENTO DEL TRASLADO',3,'MOTIVO DEL TRASLADO',4,'DOCUMENTOS') as tipo_desc, status, decode(status,'A','Activo','I','Inactivo') as status_desc, descripcion, id from  tbl_sal_transferencia_params where compania = "+company+appendFilter+" order by tipo,descripcion"; 

al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'EXPEDIENTE - PARAMETROS TRANSFERENCIA '+document.title;
function doAction(){}
function manage(action,ind){
    
   var tipo = $("#tipo"+ind).val()||'0';
   var tipoDesc = $("#tipoDesc"+ind).val()||'';
   
   if(action=="add") abrir_ventana("../expediente/exp_transferencia_params_reg.jsp?mode=add&tipo="+tipo+"&tipoDesc="+tipoDesc);
   else abrir_ventana("../expediente/exp_transferencia_params_reg.jsp?mode=edit&tipo="+tipo+"&tipoDesc="+tipoDesc);
}
function doFilter(obj){
  document.getElementById("search01").submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr class="TextRow02">
		
		<td colspan="4" align="right"> 
		<a class="Link00" href="javascript:manage('add')">Agregar</a>
		<!--<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a>-->
		</td>
	</tr>
	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="4">
			    Tipo&nbsp;<%=fb.select("tipo","T=-TODOS-,1=CONDICION DEL PACIENTE EN EL MOMENTO DE TRASLADO,2=REQUERIMIENTO DEL TRASLADO,3=MOTIVO DEL TRASLADO,4=DOCUMENTOS",tipo,false,false,0,"","width:200px","onchange=doFilter(this)")%>
			    Descripci&oacute;n&nbsp;
				<%=fb.textBox("descripcion",descripcion,false,false,viewMode,80,1000,"Text10",null,null)%>
			    Estado&nbsp;<%=fb.select("status","T=-TODOS-,A=ACTIVO,I=INACTIVO",status,false,false,0,"","","onchange=doFilter(this)")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		<%=fb.formEnd()%>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				
				 <tr class="TextHeader">
				 	<td width="10%">&nbsp;</td>
				 	<td width="70">Descripci&oacute;n</td>
				 	<td align="center" width="10">Estado</td>
				 	<td width="10">&nbsp;</td>
				 </tr>
				
				<% 
				 String grpTipo = "";
				 for (int i = 0; i<al.size(); i++){
					cdo = (CommonDataObject)al.get(i);
					String color = i%2==0?"TextRow02":"TextRow01";
					
					if (!grpTipo.equals(cdo.getColValue("tipo"))){%>
						<tr class="TextHeader">
							<td colspan="3">[<%=cdo.getColValue("tipo")%> ]<%=cdo.getColValue("tipo_desc")%> </td>
							<td align="center"><authtype type='0'><a class="Link03" href="javascript:manage('add','<%=i%>')">Agregar</a></authtype></td>
						</tr>
				   <%}%>
				   
				   <%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
				   <%=fb.hidden("tipoDesc"+i,cdo.getColValue("tipo_desc"))%>
				   <%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				  
				  <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				 	<td width="10%">&nbsp;</td>
				 	<td width="70%"><%=cdo.getColValue("descripcion")%> </td>
				 	<td align="center" width="10%"><%=cdo.getColValue("status_desc")%> </td>
				 	<td width="10%" align="center"> 
					<a class="Link00Bold" href="javascript:manage('edit','<%=i%>')">Editar</a>
					
					</td>
				 </tr>
				<%
				grpTipo = cdo.getColValue("tipo");
				}
				%>
				
				
				
				
				
				
				
				
				
				
				
				 <%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>			

</table>
</body>
</html>
<%}%>