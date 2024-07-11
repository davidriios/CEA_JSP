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
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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

CommonDataObject cdo = new CommonDataObject();
Hashtable ht = null;

boolean viewMode = false;
String sql = "";
String mode = ""; 
String modeSec = ""; 
String seccion = "";
String pacId = "";
String noAdmision = ""; 
String desc = "";

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{
	 ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("expedientedocs"),20);
	 mode = (String) ht.get("mode");
 	 modeSec = (String) ht.get("modeSec");
	 seccion = (String) ht.get("seccion");
	 pacId = (String) ht.get("pacId");
	 noAdmision = (String) ht.get("noAdmision");
	 desc = (String) ht.get("desc");
}
else
{
 mode = request.getParameter("mode"); 
 modeSec = request.getParameter("modeSec"); 
 seccion = request.getParameter("seccion");
 pacId = request.getParameter("pacId");
 noAdmision = request.getParameter("noAdmision"); 
 desc = request.getParameter("desc");
}

if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	sql = "select numero_acta, to_char(fecha_muerte,'dd/mm/yyyy')fecha_muerte, to_char(hora_muerte,'hh:mi:ss pm') hora_muerte,observa_a ,observa_b,observa_c,estado_patologo,decode(documento,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||documento) as documento from tbl_sal_defuncion where pac_id = "+pacId;
	cdo = SQLMgr.getData(sql);

	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();
		cdo.addColValue("fecha_muerte",cDateTime.substring(0,10));	
	}
	else if (!viewMode) modeSec = "edit";
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - HOJA DE DEFUNCION - '+document.title;
function doAction(){newHeight();}
function imprimir(){abrir_ventana('../expediente/print_hoja_defuncion.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
<jsp:param name="title" value="<%=desc%>"></jsp:param>
  <jsp:param name="displayCompany" value="n"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >   
<tr>  
  <td>   
    <table width="100%" cellpadding="1" cellspacing="1" > 
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("usuario_creac",cdo.getColValue("USUARIO_CREAC"))%>
<%=fb.hidden("fecha_creac",cdo.getColValue("FECHA_CREAC"))%>
<%=fb.hidden("usuario_modific",cdo.getColValue("USUARIO_MODIF"))%>
<%=fb.hidden("fecha_modific",cdo.getColValue("FECHA_MODIF")) %>
<%=fb.hidden("codigo",cdo.getColValue("CODIGO"))%>
<%=fb.hidden("desc",desc)%>

    <tr class="TextRow02">
     <tr class="TextRow02">
			<td colspan="2" align="right"><a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
		</tr>
      <td>
        <cellbytelabel id="2">Numero de Acta</cellbytelabel> &nbsp;&nbsp; <%=fb.intBox("numero_acta",cdo.getColValue("numero_acta"),true,false,viewMode,15,10)%>
      </td> 
	  
	  <td>
        <cellbytelabel id="3">Fecha de la muerte</cellbytelabel> <jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fecha_muerte" />
		<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_muerte")%>" />
		</jsp:include>
		<cellbytelabel id="4">Hora</cellbytelabel>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_muerte" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_muerte")==null?"":cdo.getColValue("hora_muerte"))%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include>	  
      </td> 
	  
    </tr>	
    <tr class="TextHeader">
      <td colspan="2">
        <cellbytelabel id="5">Causas de la Defunci&oacute;n</cellbytelabel>
      </td> 
    </tr>	
	 <tr class="TextRow01">
      <td width="40%">
        <cellbytelabel id="6">PARTE I<br><br>
			Enfermedad o estado patol&oacute;gico que produjo la muerte directamente</cellbytelabel>
        
      </td> 
	  <td width="60%">
        <cellbytelabel id="7">A: Debido a (o como consecuencia de B)</cellbytelabel>  <%=fb.textarea("observa_a",cdo.getColValue("observa_a"),false,false,viewMode,60,6,500,"","width:100%","")%>
      </td> 
    </tr>	
	 <tr class="TextRow02">
      <td width="40%" rowspan="2">
        <cellbytelabel id="8">CAUSAS ANTECEDENTES<br><br>Estados morbosos, si existiera alguno, que originaron la causa consignada arriba, mencionàndose en C, la causa bàsica o fundamental.</cellbytelabel>
        
      </td> 
	  <td width="60%">
       <cellbytelabel id="9"> B.&nbsp; Debido a (o como consecuencia de C)</cellbytelabel> &nbsp;&nbsp;&nbsp;  <%=fb.textarea("observa_b",cdo.getColValue("observa_b"),false,false,viewMode,60,6,500,"","width:100%","")%>
      </td> 
    </tr>	
	<tr class="TextRow02">
	  <td>
        <cellbytelabel id="10">C.&nbsp;Causa bàsica o fundamental</cellbytelabel>&nbsp;&nbsp;&nbsp;  <%=fb.textarea("observa_c",cdo.getColValue("observa_c"),false,false,viewMode,60,6,500,"","width:100%","")%>
      </td> 
    </tr>	
	<tr class="TextRow01">
      <td width="40%">
        <cellbytelabel id="11">PARTE II<br><br>Otros estados patológicos significativos que contribuyaron a la muerte, pero, no relacionados
	con la enfemedad señalada en c.</cellbytelabel>
        
      </td> 
	  <td>
        <%=fb.textarea("estado_patologo",cdo.getColValue("estado_patologo"),false,false,viewMode,60,6,500,"","width:100%","")%>
      </td> 
    </tr>	
	<tr class="TextRow01">
		<td colspan="2"><cellbytelabel id="12">Documento</cellbytelabel>&nbsp;&nbsp;
		<%=fb.fileBox("documento",cdo.getColValue("documento"),false,viewMode,40)%>
		</td>
	</tr>
	<tr class="TextRow02" align="right">
		<td colspan="2">
	<cellbytelabel id="13">Opciones de Guardar</cellbytelabel>: 
	<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
	<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="14">Mantener Abierto</cellbytelabel> 
	<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="14">Cerrar</cellbytelabel> 
	<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
	  <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
		</td>
	</tr>
<%fb.appendJsValidation("if(error>0)doAction();");%>
<%=fb.formEnd(true)%>
		</table>				
  </td>
</tr> 		
</table>
</body>
</html>
<%
}//GET 
else
{
	String saveOption =  (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = (String) ht.get("baction");

					
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sal_defuncion"); 
	cdo.setWhereClause("pac_id="+(String)ht.get("pacId"));
	cdo.addColValue("numero_acta",(String)ht.get("numero_acta"));
	cdo.addColValue("observa_a",(String)ht.get("observa_a"));
	cdo.addColValue("observa_b",(String)ht.get("observa_b"));
	cdo.addColValue("observa_c",(String)ht.get("observa_c"));	
	cdo.addColValue("fecha_muerte",(String)ht.get("fecha_muerte"));		
	cdo.addColValue("estado_patologo",(String)ht.get("estado_patologo"));
	cdo.addColValue("documento",(String)ht.get("documento"));
	cdo.addColValue("hora_muerte",(String)ht.get("hora_muerte"));
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("pac_id",(String)ht.get("pacId"));
		cdo.addColValue("fec_nacimiento",(String)ht.get("dob"));	
		cdo.addColValue("cod_paciente",(String)ht.get("codPac"));	
		SQLMgr.insert(cdo);
	}
	else
	{
		cdo.setWhereClause("pac_id="+(String)ht.get("pacId"));
		SQLMgr.update(cdo);
	}							
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec<%=modeSec%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

