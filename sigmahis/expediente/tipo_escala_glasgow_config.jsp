<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.expediente.DetalleTipoEscala"%>
<%@ page import="issi.expediente.TipoEscala"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900093") || SecMgr.checkAccess(session.getId(),"900094") || SecMgr.checkAccess(session.getId(),"900095") || SecMgr.checkAccess(session.getId(),"900096") || SecMgr.checkAccess(session.getId(),"900097") || SecMgr.checkAccess(session.getId(),"900098") || SecMgr.checkAccess(session.getId(),"900099") || SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
//ArrayList tp = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

String key = "";

int lastLineNo = 0;
TipoEscala tp = new TipoEscala();
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")){
////System.out.println("=================================== GET ===============================");	

	if (mode.equalsIgnoreCase("add"))
	{ 
			HashDet.clear(); 
			id = "0";		 	 
	}
	else
	{
	/* ========= Editar ========= */
	
		sql = "SELECT codigo, descripcion,tipo,estado from tbl_sal_tipo_escala where codigo="+id+"  ";
		tp = (TipoEscala) sbb.getSingleRowBean(ConMgr.getConnection(), sql, TipoEscala.class); 
		
		sql = "SELECT codigo, descripcion, escala,estado FROM tbl_sal_detalle_escala WHERE tipo_escala="+id+" ORDER BY codigo ASC ";
		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleTipoEscala.class);                   
		
		HashDet.clear(); 
			
		for (int i = 1; i <= al.size(); i++)
		{
		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;
		
		HashDet.put(key, al.get(i-1));
		lastLineNo = i;
		}  	
	}
//	fb.appendJsValidation("if(error>0)doAction();");
%>

<!--  ========= INICIO HTML =========   -->
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">


<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Mantenimiento - Tipo Escala Glasgow - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Mantenimiento - Tipo Escala Glasgow - Edición - "+document.title;
<%}%>
</script>

<script type="text/javascript">
function save1(){
	
	if(form1Validation()){	
	window.frames['detalle'].formDetalle.baction.value = "Guardar";
	window.frames['detalle'].doSubmit(); 
	}
}
</script>

<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - TIPO ESCALA GLASGOW"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableBorder">
<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>

	<%=fb.formStart(true)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("errCode","")%>
	<%=fb.hidden("errMsg","")%>
		<tr><td colspan="4">&nbsp;</td></tr>
			<tr class="TextRow02"><td colspan="4">&nbsp;</td></tr>			
				<tr class="TextRow01" >
				<td><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
				<td colspan="3"><%=id%></td>
				</tr>	
				<tr class="TextRow01" >
					<td width="20%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="30%"><%=fb.textBox("descripcion",tp.getDescripcion(),true,false,false,40)%></td>
					<td width="25%"><cellbytelabel id="3">Tipo</cellbytelabel> <%=fb.select("tipo","A=ADULTOS,N=NIÑOS",tp.getTipo(),false,false,0,"")%></td>
					<td width="25%"><cellbytelabel id="4">Estado</cellbytelabel> <%=fb.select("estado","A=ACTIVO,I=INACTIVO",tp.getEstado(),false,false,0,"")%></td>
				</tr>	
				<tr class="TextRow02">
				<td colspan="4" align="right">&nbsp;</td>
				</tr>
			<tr class="TextRow02">
			<td colspan="4">
		<div id="panel1" style="inline:display;">
		<iframe name="detalle" id="detalle" width="100%" height="50" scrolling="no" frameborder="0" src="../expediente/tipo_escala_glasgow_detail.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>"></iframe>
		</div>
	</td>
	</tr>
	<tr class="TextRow02">
	<td colspan="4" align="right"><cellbytelabel id="5">Opciones de Guardar</cellbytelabel>: 
	<%=fb.radio("saveOption","N")%><cellbytelabel id="6">Crear Otro</cellbytelabel> 
	<%=fb.radio("saveOption","O")%><cellbytelabel id="7">Mantener Abierto</cellbytelabel> 
	<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>

	<%=fb.button("save","Guardar",true,false,null, null, "onClick=\"javascript:save1()\"")%>
	<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr><tr><td colspan="4">&nbsp;</td></tr>
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

//System.out.println("=================================== POST ===============================");

  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  String baction = request.getParameter("baction");
  
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

//System.out.println(errCode);

if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/tipo_escala_glasgow_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/tipo_escala_glasgow_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/tipo_escala_glasgow_list.jsp';
<%
	}
%>

<%

	if (saveOption.equalsIgnoreCase("N"))																					
	{
%>
	setTimeout('addMode()',900);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',900);
	
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	//window.close();
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=request.getParameter("id")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>