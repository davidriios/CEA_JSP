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
<jsp:useBean id="iAlergia" scope="session" class="java.util.Hashtable" />
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
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	sql = "select a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar,decode(b.tipo_alergia,null,'I','U') action,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,b.usuario_creacion from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo=b.tipo_alergia and b.pac_id="+pacId+" and nvl(b.admision,"+noAdmision+") = "+noAdmision+" ORDER BY b.fecha desc nulls last ";
	al = SQLMgr.getDataList(sql);
	
	session.setAttribute("iAntAler$",al);
	session.setAttribute("iAntAlerType$","ArrayList");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - Antecedente Alergico - '+document.title;
function doAction(){newHeight();}
function isChecked(k){eval('document.form0.observacion'+k).disabled = !eval('document.form0.aplicar'+k).checked;eval('document.form0.edad'+k).disabled = !eval('document.form0.aplicar'+k).checked;eval('document.form0.meses'+k).disabled = !eval('document.form0.aplicar'+k).checked;if (eval('document.form0.aplicar'+k).checked){
eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';eval('document.form0.edad'+k).className = 'FormDataObjectEnabled';eval('document.form0.meses'+k).className = 'FormDataObjectEnabled';}else{eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';eval('document.form0.edad'+k).className = 'FormDataObjectDisabled';eval('document.form0.meses'+k).className = 'FormDataObjectDisabled';}}
function imprimirExp(){abrir_ventana('../expediente/print_exp_seccion_11.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("seccion",seccion)%>

		<tr class="TextHeader" align="center">
			<td width="47%"><cellbytelabel id="2">Tipo de Alerg&iacute;a</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="3">Si</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="4">Edad</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="5">Meses</cellbytelabel></td>
			<td width="34%"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("cod_alergia"+i,""+cdo.getColValue("codigoalergia"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("cod"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<tr class="<%=color%>" align="center">
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%=fb.checkbox("aplicar"+i,"S",(cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>
			<td><%=fb.intBox("edad"+i,cdo.getColValue("edad"),false,(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,4,3)%></td>
			<td><%=fb.intBox("meses"+i,cdo.getColValue("meses"),false,(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,4,3)%></td>
			<td align="left"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,50,2,2000,null,"width='100%'",null)%></td>
		</tr>
<%
}
%>

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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	al.clear();

	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("TBL_SAL_ALERGIA_PACIENTE");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and codigo ="+request.getParameter("codigo"+i));
			
		if (request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))
		{
 			cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
			cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
			cdo.addColValue("PAC_ID",request.getParameter("pacId"));
			cdo.addColValue("TIPO_ALERGIA",request.getParameter("cod_alergia"+i));
			
			if(request.getParameter("usuario_creacion"+i) == null ||request.getParameter("usuario_creacion"+i).trim().equals(""))
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			if(request.getParameter("fecha_creacion"+i) == null ||request.getParameter("fecha_creacion"+i).trim().equals(""))
			cdo.addColValue("fecha_creacion",cDateTime);
			
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			
			if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
			{
				cdo.setAutoIncCol("CODIGO");
				cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId"));
			}
			else{ cdo.addColValue("CODIGO",request.getParameter("codigo"+i));cdo.setAction("U");}
			cdo.addColValue("EDAD",request.getParameter("edad"+i));
			cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
			if(request.getParameter("fecha"+i).trim().equals(""))	cdo.addColValue("FECHA","sysdate");
			else cdo.addColValue("FECHA",request.getParameter("fecha"+i));
			cdo.addColValue("MESES",request.getParameter("meses"+i));
			cdo.addColValue("APLICAR","S");
			cdo.setAction(request.getParameter("action"+i));
 			al.add(cdo);
		}
		else if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U"))
		{
			cdo.setAction("D");
			al.add(cdo);
		}
	}//for

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("TBL_SAL_ALERGIA_PACIENTE");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId"));
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>




