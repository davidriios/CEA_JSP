<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
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
sql  ="select codigo, gestacion, parto, aborto, cesarea, menarca, to_char(fum,'dd/mm/yyyy') as fum, ciclo, inicio_sexual, conyuges, to_char(fecha_pap,'dd/mm/yyyy') as fecha_pap, metodo, sustancias, otros, observacion, ectopico,usuario_creacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion ,'U' action, to_char(fecha_fpp,'dd/mm/yyyy') as fecha_fpp, to_char(fecha_edad_gesta,'dd/mm/yyyy') as fecha_edad_gesta, edad_gestacional from tbl_sal_antecedente_ginecologo where pac_id="+pacId+" and nvl(admision,"+noAdmision+")="+noAdmision;
	cdo = SQLMgr.getData(sql);

	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();

		cdo.addColValue("FUM","");
		cdo.addColValue("FECHA_PAP","");
		cdo.addColValue("CODIGO","1");
	}
	else if (!viewMode) modeSec = "edit";
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
		<jsp:include page="../common/calendar_base.jsp" flush="true">
				<jsp:param name="bootstrap" value="bootstrap"/>
		</jsp:include>
		<script>
		document.title = 'EXPEDIENTE - Gineco-Obstetrico - '+document.title;
		var noNewHeight = true;
		function doAction(){}
		function imprimir(){abrir_ventana('../expediente3.0/print_exp_seccion_3.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
		</script>
		<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

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
<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("usuarioCreacion",cdo.getColValue("usuario_creacion"))%>
<%=fb.hidden("fechaCreacion",cdo.getColValue("fecha_creacion"))%>

				<div class="headerform">
		<!--tabla de boton imprimit-->
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr>
		<td><%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir()\"")%></td>
		</tr>
		</table></div>
		<!--fin tabla de boton imprimit-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
		<tr class="bg-headtabla" >
				<th>Descripción</th>
				<th>Valor</th>
				<th>Descripción</th>
				<th>Valor</th>
		</tr>
		</thead>

		<tbody class="text-right">
		<tr>
				<td>Gestación</td>
				<td class="text-left"><label><%=fb.textBox("gesta",cdo.getColValue("GESTACION"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>
				<td>FPP</td>
				<td class="text-left controls form-inline">
					<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha_fpp" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fpp"," ")%>" />
			</jsp:include>
				</td>
		</tr>
		<tr>
				<td>Parto</td>
				<td class="text-left"><label><%=fb.textBox("parto",cdo.getColValue("parto"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>
				<td> FUM</td>
				<td class="text-left controls form-inline">
						 <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fum" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("FUM")%>" />
				</jsp:include>
				</td>
		</tr>
		<tr>
				<td>Aborto</td>
				<td class="text-left"><label><%=fb.textBox("aborto",cdo.getColValue("ABORTO"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>
				<td>Último PAP</td>
				<td class="text-left controls form-inline">
					 <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="pap" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("FECHA_PAP")%>" />
				</jsp:include>
				</td>
		</tr>
		<tr>
				<td>Ces&aacute;rea</td>
				<td class="text-left"><label><%=fb.textBox("cesarea",cdo.getColValue("cesarea"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>
				<td>Ciclo Menstrual</td>
				<td>
				<%=fb.textarea("ciclo",cdo.getColValue("CICLO"),false,false,viewMode,40,2,100,"form-control input-sm","width:100%","")%></td>
		</tr>

		<tr>
				<td>Edad Gestacional</td>
				<td class="text-left controls form-inline">
						<%=fb.intBox("edad_gestacional", cdo.getColValue("edad_gestacional"," "),false,false,viewMode,5,3,"form-control input-sm",null,null)%><cellbytelabel id="7"> Semanas</cellbytelabel>
				</td>
				<td></td>
				<td></td>
		</tr>

		<tr>
				<td>Ect&oacute;pico</td>
				<td class="text-left"><label><%=fb.textBox("ectopico",cdo.getColValue("ectopico"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>
				<td>Método de Planificación</td>
				<td><%=fb.textarea("metodo",cdo.getColValue("metodo"),false,false,viewMode,40,2,100,"form-control input-sm","width:100%","")%></td>
		</tr>
		<tr>
				<td>Menarca</td>
				<td class="text-left"><label><%=fb.textBox("menarca",cdo.getColValue("menarca"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>
				<td rowspan="2"> Exposición a Tóxicos y Substancia<br>Qu&iacute;micas o Radiaciones.</td>
				<td class="text-left" rowspan="2">
				<%=fb.select("exposicion","N=NO,S=SI",cdo.getColValue("SUSTANCIAS"),false,viewMode,0,"form-control input-sm",null,null)%>
				</td>
		</tr>
		<tr>
				<td>I.V.S.A.</td>
				<td class="text-left"><label><%=fb.textBox("ivsa",cdo.getColValue("INICIO_SEXUAL"," "),false,false,false,4,3,"form-control input-sm",null,null)%></label></td>


		</tr>
		<tr>
				<th colspan="2" class="text-left">
								 Observaciones:
								<%=fb.textarea("observacion",cdo.getColValue("OBSERVACION"),false,false,viewMode,40,3,2000,"form-control input-sm","width:100%","")%>
						</th>
				<th colspan="2" class="text-left">
								<%=fb.textarea("otros",cdo.getColValue("otros"),false,false,viewMode,40,3,2000,"form-control input-sm","width:100%","")%>
						</th>
		</tr>

		</tbody>
		</table>
			<div class="footerform">
		 <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		 <% fb.appendJsValidation("if(error>0)doAction();"); %>
		<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
	 </tr>
		</table>
		</div>

		<%=fb.formEnd(true)%>
		</div>

		<!-- FIN contenido del sitio aqui-->
		</div>
		<!-- FIN contenido del sitio aqui-->

		<!--script toggle de panels-->
		<script src="js/toggles.js"></script>
		<!--fin script toggle de panels-->


		<!-- FIN Cuerpo del sitio -->
		</body>
		<!-- FIN Cuerpo del sitio -->


		</html>
		<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sal_antecedente_ginecologo");
	cdo.addColValue("codigo",request.getParameter("codigo"));
	cdo.addColValue("GESTACION",request.getParameter("gesta"));
	cdo.addColValue("PARTO",request.getParameter("parto"));
	cdo.addColValue("ABORTO",request.getParameter("aborto"));
	cdo.addColValue("CESAREA",request.getParameter("cesarea"));
	cdo.addColValue("MENARCA",request.getParameter("menarca"));
	cdo.addColValue("FUM",""+request.getParameter("fum")+"");
	cdo.addColValue("CICLO",request.getParameter("ciclo"));
	cdo.addColValue("INICIO_SEXUAL",request.getParameter("ivsa"));
	cdo.addColValue("CONYUGES",request.getParameter("conyuge"));
	cdo.addColValue("FECHA_PAP",""+request.getParameter("pap")+"");
	cdo.addColValue("METODO",request.getParameter("metodo"));
	cdo.addColValue("SUSTANCIAS",request.getParameter("exposicion"));
	cdo.addColValue("OTROS",request.getParameter("otros"));
	cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
	cdo.addColValue("ECTOPICO",request.getParameter("ectopico"));
	cdo.addColValue("admision",request.getParameter("noAdmision"));
	cdo.addColValue("fecha_edad_gesta",request.getParameter("fecha_edad_gesta"));
	cdo.addColValue("edad_gestacional",request.getParameter("edad_gestacional"));
	cdo.addColValue("fecha_fpp",request.getParameter("fecha_fpp"));

	cdo.addColValue("fecha_modificacion",cDateTime);
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO",request.getParameter("dob"));
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

		SQLMgr.insert(cdo);
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
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
