<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alEval = new ArrayList();
CommonDataObject cdoEval = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String code = request.getParameter("code");

if (code == null) code = "0";
if (modeSec == null || modeSec.equals("")) modeSec = "add";
if (mode == null || mode.equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF from TBL_SAL_RESULTADO_EKG where pac_id="+pacId+" and secuencia="+noAdmision +" order by FECHA_CREAC DESC";

alEval = SQLMgr.getDataList(sql);

if(!code.trim().equals("0")){

		sql = "select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF from TBL_SAL_RESULTADO_EKG where pac_id="+pacId+" and secuencia="+noAdmision+" and codigo="+code;

cdo1 = SQLMgr.getData(sql);
}

if (cdo1 == null || code.trim().equals("0"))
{
		if (!viewMode) modeSec = "add";
		cdo1 = new CommonDataObject();

		cdo1.addColValue("CODIGO","1");
		cdo1.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
		cdo1.addColValue("FECHA_CREAC",cDateTime);
		cdo1.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
		cdo1.addColValue("FECHA_MODIF",cDateTime);
}
%>
<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
<!--Para mas Informacion leer (info_v3.txt)-->
<!--Done by. eduardo.b@issi-panama.com-->
<!DOCTYPE html>
<html lang="en">
<!--comienza el head-->
<head>
<meta charset="utf-8">
<title>Expediente Cellbyte</title>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function imprimir(fg){abrir_ventana('../expediente/print_exp_seccion_51.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&code=<%=code%>&fg='+fg);}
function setEkg(p){var code = eval('document.form0.codigo'+p).value;window.location = '../expediente3.0/exp_ekg.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+code;}
function add(){window.location = '../expediente3.0/exp_ekg.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}
$(function(){
doAction();
})
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<!--termina el head-->

<!--comienza el cuerpo del sitio-->
<body class="body-forminside">

		<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
<!--INICIO de una fila de elementos-->
<div class="row">
<!--INICIO de una fila de elementos-->

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
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
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("code",code)%>

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td>
		<%if(!mode.trim().equals("view")){%>
			<%=fb.button("btnAdd","Agregar",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onClick=\"javascript:add()\"")%>
		<%}%>
		<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir('')\"")%>
		<%=fb.button("btnPrintAll","Imprimir Todo",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimir('TD')\"")%>
</td>
</tr>
		<tr><th class="bg-headtabla">LISTADO DE RESULTADOS</th></tr>
</table>
<!--fin tabla de boton imprimit-->
<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
		<tr class="bg-headtabla2">
		<th style="vertical-align: middle !important;">C&oacute;digo</th>
		<th style="vertical-align: middle !important;">Fecha</th>
		</thead>
<tbody>
<%
for (int p = 1; p<=alEval.size(); p++){
		cdoEval = (CommonDataObject)alEval.get(p-1);
		%>

<tr onclick="javascript:setEkg(<%=p%>)">
<td><%=cdoEval.getColValue("CODIGO")%></td>
<td><%=cdoEval.getColValue("FECHA_CREAC")%></td>
</tr>
<%=fb.hidden("codigo"+p,cdoEval.getColValue("CODIGO"))%>
<%
	}
%>

</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
 <tbody>
		 <tr>
				<th class="bg-headtabla">Datos Generales</th>
		 </tr>

		 <tr>
				<td>
						<cellbytelabel><strong>Descripci&oacute;n</strong></cellbytelabel>
						<br><%=fb.textarea("descripcion",cdo1.getColValue("DESCRIPCION"),true,false,viewMode,60,0,2000,"form-control input-sm","width:100%","")%>
				</td>
				<%=fb.hidden("remove"+code,code)%>
				<%=fb.hidden("usuario_creac",cdo1.getColValue("usuario_creac"))%>
				<%=fb.hidden("fecha_creac",cdo1.getColValue("fecha_creac"))%>
				<%=fb.hidden("usuario_modific",cdo1.getColValue("usuario_modif"))%>
				<%=fb.hidden("fecha_modific",cdo1.getColValue("fecha_modif")) %>
		</tr>



</tbody>
</table>


<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
		</table> </div>


<%=fb.formEnd(true)%>
</div>

<!-- FIN contenido del sitio aqui-->
</div>
<!-- FIN contenido del sitio aqui-->


<!-- FIN Cuerpo del sitio -->
</body>
<!-- FIN Cuerpo del sitio -->


</html>
<%
}//fin GET
//------------------------------- -----------------------------------
else
{			String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
			String baction = request.getParameter("baction");

					cdo = new CommonDataObject();
					cdo.setTableName("TBL_SAL_RESULTADO_EKG");

					cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));

					cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"));
					cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"));
					cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"));
					cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
					cdo.addColValue("FECHA_MODIF",cDateTime);

					cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
					cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
					cdo.addColValue("SECUENCIA",request.getParameter("noAdmision"));
					cdo.addColValue("PAC_ID",request.getParameter("pacId"));

					//if ((UserDet.getRefType().trim().equalsIgnoreCase("M")))cdo.addColValue("medico",""+UserDet.getRefCode());
					//else cdo.addColValue("medico","");

					if(modeSec.equalsIgnoreCase("add")){
						cdo.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
						cdo.addColValue("FECHA_CREAC",cDateTime);
						cdo.addColValue("CODIGO",request.getParameter("code"));
						cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"));
						//cdo.addColValue("EKG",request.getParameter("EKG"));
						cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
						cdo.setAutoIncCol("codigo");
									cdo.addPkColValue("codigo","");

						SQLMgr.insert(cdo);
						code = SQLMgr.getPkColValue("CODIGO");

					}else{
						cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"));
						cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"));

						cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision")+" and codigo = "+code);
						SQLMgr.update(cdo);
					}

					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>