<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String id = request.getParameter("id");
String appendFilter = "";
int size = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	sql = "SELECT b.APLICAR AS APLICAR, a.DESCRIPCION AS DESCRIPCION, a.CODIGO AS COD_VACUNA, b.VACUNA AS VACUNA, nvl(b.OBSERVACION,' ') as observacion, b.refuerzo AS refuerzo, b.anio AS anio, b.meses AS meses, to_char(b.FECHA,'dd/mm/yyyy hh12:mi:ss am') AS FECHA,nvl(b.usuario_creacion,user)usuario_creacion,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion ,decode(b.vacuna,null,'I','U') action from tbl_sal_vacuna a, tbl_sal_vacuna_paciente b where a.CODIGO=b.VACUNA(+) AND b.PAC_ID(+)="+pacId+" ORDER BY FECHA DESC NULLS LAST";
	al = SQLMgr.getDataList(sql);
	if (al.size() == 0)
		 if (!viewMode) modeSec = "add";
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
var noNewHeight = true;
document.title = 'Inmunizaciones - '+document.title;
function doAction(){newHeight();}
function isChecked(k){eval('document.form0.observacion'+k).disabled = !eval('document.form0.aplicar'+k).checked;eval('document.form0.anio'+k).disabled = !eval('document.form0.aplicar'+k).checked;eval('document.form0.meses'+k).disabled = !eval('document.form0.aplicar'+k).checked;eval('document.form0.refuerzo'+k).disabled = !eval('document.form0.aplicar'+k).checked;if (eval('document.form0.aplicar'+k).checked){eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';eval('document.form0.anio'+k).className = 'FormDataObjectEnabled';eval('document.form0.meses'+k).className = 'FormDataObjectEnabled';eval('document.form0.refuerzo'+k).className = 'FormDataObjectEnabled';}else{eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';eval('document.form0.anio'+k).className = 'FormDataObjectDisabled';eval('document.form0.meses'+k).className = 'FormDataObjectDisabled';eval('document.form0.refuerzo'+k).className = 'FormDataObjectDisabled';}}
function imprimirExp(){abrir_ventana('../expediente/print_exp_seccion_12.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
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
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("desc",desc)%>
<tr>
	<td colspan="4">
					<table width="100%" border="0" cellpadding="2" cellspacing="1">
					<tr><td align="right" colspan="7">&nbsp;<a href="javascript:imprimirExp()" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td></tr>
						<tr align="center" class="TextHeader">
							<td width="20%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
							<td width="4%"><cellbytelabel id="3">Reg</cellbytelabel>.</td>
							<td width="4%"><cellbytelabel id="4">S&iacute;</cellbytelabel></td>
							<td width="20%"><cellbytelabel id="5">Refuerzo</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="6">A&ntilde;o</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="7">Meses</cellbytelabel></td>
							<td width="40%"><cellbytelabel id="8">Observaci&oacute;n</cellbytelabel></td>
						</tr>
					<%
					int lc = 0;
					for (int i=0; i<al.size(); i++)
					{
					cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					%>
					<%=fb.hidden("fecha"+i,""+cdo.getColValue("FECHA"))%>
					<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
					<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
					<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>

					<% 
					if (lc % 2 == 0) color = "TextRow01"; %>
						<tr class="<%=color%>" >
							<%=fb.hidden("cod_vacuna"+i,cdo.getColValue("cod_vacuna"))%>
							<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
							<td><%=cdo.getColValue("cod_vacuna")%></td>
							<td align="center"><%=fb.checkbox("aplicar"+i,"S",(cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>
							<td align="center"><%=fb.select("refuerzo"+i, "V=VACUNACION,R=REFUERZO,D=DOSIS", cdo.getColValue("refuerzo"),false,((!cdo.getColValue("aplicar").equalsIgnoreCase("S")) || viewMode),1)%></td>
							<td align="center"><%=fb.intBox("anio"+i,cdo.getColValue("anio"),false,(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,2,3,"Text12","","")%></td>
							<td align="center"><%=fb.intBox("meses"+i,cdo.getColValue("meses"),false,(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,2,2,"Text12","","")%></td>
							<td><%=fb.textarea("observacion"+i, cdo.getColValue("observacion"), false, (!cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,50,3,2000,null,"width='100%'",null)%>
						</tr>
					<% lc++;
					}
					%>
<!-- ============================ END HERE ============================ -->
					</table>
		</td>
</tr>
<tr class="TextRow02">
	<td colspan="4" align="right">
				<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="11">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
</td>
</tr>
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
	size = Integer.parseInt(request.getParameter("size"));

//System.out.println("****************************************************************************");
for (int i=0; i<size; i++)
{
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_vacuna_paciente");
	cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and vacuna ="+request.getParameter("cod_vacuna"+i));
			
	if (request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))
	{
			
			cdo.addColValue("cod_paciente",request.getParameter("codPac"));
			cdo.addColValue("fec_nacimiento",request.getParameter("dob"));
			cdo.addColValue("vacuna",request.getParameter("cod_vacuna"+i));
			cdo.addColValue("codigo",request.getParameter("noAdmision"));
			cdo.addColValue("aplicar",(request.getParameter("aplicar"+i)==null)?"N":"S");
			cdo.addColValue("pac_id",request.getParameter("pacId"));

			if(request.getParameter("fecha"+i).trim().equals(""))	cdo.addColValue("FECHA","sysdate");
			else cdo.addColValue("FECHA",request.getParameter("fecha"+i));
			
			cdo.addColValue("anio",request.getParameter("anio"+i));
			cdo.addColValue("meses",request.getParameter("meses"+i));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("refuerzo",request.getParameter("refuerzo"+i));
			if(request.getParameter("usuario_creacion"+i) == null ||request.getParameter("usuario_creacion"+i).trim().equals(""))
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			if(request.getParameter("fecha_creacion"+i) == null ||request.getParameter("fecha_creacion"+i).trim().equals(""))
			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		  	cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.setAction(request.getParameter("action"+i));
			al.add(cdo);
		}
		else if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U"))
		{
			cdo.setAction("D");
			al.add(cdo);
		}
	}
	//System.out.println("===============>>>>>>>><"+al.size());
	if (al.size() == 0)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_vacuna_paciente");
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
