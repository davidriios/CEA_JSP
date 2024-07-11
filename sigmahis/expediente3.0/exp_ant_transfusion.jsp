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
<jsp:useBean id="iAntTransf" scope="session" class="java.util.Hashtable" />
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

Hashtable ht = null;

boolean viewMode = false;
String sql = "", sqlTitle ="";
String change = "";
String mode = "";
String modeSec = "";
String seccion = "";
String pacId = "";
String noAdmision = "";
String key = "";
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

	if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
	{
		 ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("expedientedocs"),20);
		 mode = (String) ht.get("mode");
		 modeSec = (String) ht.get("modeSec");
		 seccion = (String) ht.get("seccion");
		 pacId = (String) ht.get("pacId");
		 noAdmision = (String) ht.get("noAdmision");
		 change = (String) ht.get("change");
	}
	else
	{
		 mode = request.getParameter("mode");
		 modeSec = request.getParameter("modeSec");
		 seccion = request.getParameter("seccion");
		 pacId = request.getParameter("pacId");
		 noAdmision = request.getParameter("noAdmision");
		 change = request.getParameter("change");
	}



if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	if (change == null)
	{
		iAntTransf.clear();
sql="select transfusion_id, pac_id, admision,to_char(fecha,'dd/mm/yyyy') fecha,documento documento1, decode(documento,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||documento) as documento, observacion from tbl_sal_ant_transfusion where pac_id = "+pacId;

		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("U");
			try
			{
				iAntTransf.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();
			cdo.addColValue("transfusion_id","0");
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("admision",noAdmision);
			cdo.setKey(iAntTransf.size()+1);
			cdo.setAction("I");
			try
			{
				iAntTransf.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) modeSec = "edit";
	}//change=null
%>
		<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
		<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
		<!--Para mas Informacion leer (info_v3.txt)-->
		<!--Done by. eduardo.b@issi-panama.com-->
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<%@ include file="../common/nocache.jsp"%>
		<%@ include file="../common/header_param_bootstrap.jsp"%>
		<jsp:include page="../common/calendar_base.jsp" flush="true">
				<jsp:param name="bootstrap" value="bootstrap"/>
		</jsp:include>
		<script>
				function imprimir(){abrir_ventana('../expediente3.0/print_exp_seccion_16.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}

				$(function(){
						$("#niega").click(function(e){
								if (this.checked) {
										$("#agregar").prop("disabled",true);
										$("button[name*='rem']").prop("disabled",true);
										$("input[name*='fecha']").prop("readOnly",true);
										$("button[name*='resetfecha']").prop("disabled",true);
										$("textarea[name*='observacion']").prop("readOnly",true).val("PACIENTE INDICA NO TIENE ANTECEDENTES");
										$("input[name*='documento']").prop("disabled",true).val("");
								} else {
										$("#agregar").prop("disabled",false);
										$("button[name*='rem']").prop("disabled",false);
										$("input[name*='fecha']").prop("readOnly",false);
										$("button[name*='resetfecha']").prop("disabled",false);
										$("textarea[name*='observacion']").prop("readOnly",false).val("");
										$("input[name*='documento']").prop("disabled",false);
								}
				});
				});
		</script>
		<style>
		a {color: #f00;}
		a:hover {color: #0f0;}
		</style>
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
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST,null,FormBean2.MULTIPART);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("aTransfSize",""+iAntTransf.size())%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("desc",desc)%>

				<div class="headerform">
		<!--tabla de boton imprimir-->
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr>
		<td><%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir()\"")%></td>
		</tr>
		</table></div>
		<!--fin tabla de boton imprimir-->


		<!--cuerpo del formulario aqui-->
		<!--el class de este sitio siempre debe tener el class="table table-small-font table-bordered table-striped"-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">

				<%if(iAntTransf.size() == 1){%>
				<tr>
						<td colspan="4" align="left">
								<label class="pointer"><%=fb.checkbox("niega","S",false,viewMode,"",null,"")%>
								&nbsp;<b>Paciente indica no tiene antecedentes</b>
								</label>
						</td>
				</tr>
				<%}%>

		<thead>
		<tr class="bg-headtabla" >
				<th style="vertical-align: middle !important;">Fecha</th>
				<th style="vertical-align: middle !important;">Observaci&oacute;n</th>
				<th style="vertical-align: middle !important;">Documento</th>
				<th class="text-center" style="vertical-align: middle !important;">
				<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,"")%>
			 </th>
		</tr>
		</thead>

		<tbody>

		<%
boolean visible = false;
boolean hasImage = false;
al = CmnMgr.reverseRecords(iAntTransf);
for (int i=0; i<iAntTransf.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iAntTransf.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	 if(!cdo.getColValue("admision").trim().equals(noAdmision))
	 {
		visible = true;%>

	<%}else visible = false;
%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("transfusion_id"+i,cdo.getColValue("transfusion_id"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
			<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
			<%=fb.hidden("documento"+i,cdo.getColValue("documento1"))%>
		<%}else{%>
		<tr class="text-center">
			<td class="controls form-inline">
			<%if(cdo.getColValue("admision").trim().equals(noAdmision)){%>
					<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
					</jsp:include>
					<%}else{%>
					<%=fb.textBox("fecha"+i,cdo.getColValue("fecha"),false,true,false,10)%>
					<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
					<%=fb.hidden("documento"+i,cdo.getColValue("documento1"))%>
					<%}%>

			</td>

			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,(visible||viewMode),false,30,1,2000,"form-control input-sm","width:100%","")%></td>
			<td>
			<%
			String doc = cdo.getColValue("documento")==null?"":cdo.getColValue("documento");
			hasImage = doc.toLowerCase().endsWith(".gif") || doc.toLowerCase().endsWith(".jpg") || doc.toLowerCase().endsWith(".jpeg")
					|| doc.toLowerCase().endsWith(".png") || doc.toLowerCase().endsWith(".bmp") || doc.toLowerCase().endsWith(".tiff");


			%>

			<% if (hasImage){ %>
				<%//=fb.button("docView"+i," ",false,false,"btn btn-reverse btn-sm|fa fa-file fa-printico",null,"",null," data-toggle=\"lightbox\" data-remote=\""+cdo.getColValue("documento")+"\"")%>
				<img src="../images/search.gif" id="scan<%=i%>" width="20" height="20" onClick="javascript:abrir_ventana('../common/abrir_ventana.jsp?fileName=<%=cdo.getColValue("documento")%>')" style="cursor:pointer;" title="AA <%=doc%>"/>
			<%}%>
			<% if (!hasImage && (modeSec.trim().equals("add") || modeSec.trim().equals("edit"))){ %>
			<%=fb.fileBox("documento"+i,cdo.getColValue("documento"),false,(visible||viewMode),"btn btn-primary btn-file btn-sm","a","b")%>
			<%}%>
			<% if (!hasImage && !doc.trim().equals("")){ %>
			<img src="../images/search.gif" id="scan<%=i%>" width="20" height="20" onClick="javascript:abrir_ventana('../common/abrir_ventana.jsp?fileName=<%=cdo.getColValue("documento")%>')" style="cursor:pointer;" title="AA <%=doc%>"/>
			</td>
		 <%}%>

			<td>
						<%=fb.submit("rem"+i,"x",true,visible||viewMode,"btn btn-inverse btn-sm",null,"onclick=\"removeItem(this.form.name,"+i+")\"")%>
						 </td>
		</tr>
<%}
}
%>

		</tbody>
		</table>
		<!--cuerpo del formulario hasta aqui-->



		<!--tabla de boton botones guardar cancelar-->
				<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>

		</table> </div>
		<!--tabla de boton botones guardar cancelar-->

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
}//GET
else
{
	String saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = (String) ht.get("baction");
	desc = (String) ht.get("desc");

	int size = Integer.parseInt((String) ht.get("aTransfSize"));

	String itemRemoved = "";
	al.clear();
	iAntTransf.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_ant_transfusion");
		cdo.setWhereClause("pac_id="+pacId+" and transfusion_id="+(String)ht.get("transfusion_id"+i));
		cdo.addColValue("pac_id",""+pacId);
		cdo.addColValue("admision",""+noAdmision);
		cdo.addColValue("fecha",(String) ht.get("fecha"+i));
		cdo.addColValue("documento",(String) ht.get("documento"+i));
		cdo.addColValue("observacion",(String) ht.get("observacion"+i));
		
		if (((String)ht.get("transfusion_id"+i)).trim().equals("0")|| ((String)ht.get("transfusion_id"+i)).trim().equals(""))
		{
			cdo.setAutoIncCol("transfusion_id");
			//cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId"));
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",cDateTime);
		}
		else
		{
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("transfusion_id",(String)ht.get("transfusion_id"+i));
		}

		cdo.setKey(i);
		cdo.setAction((String)ht.get("action"+i));


		if (((String)ht.get("remove"+i)) != null && !((String)ht.get("remove"+i)).equals(""))
		{	itemRemoved = cdo.getKey();
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iAntTransf.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+(String)ht.get("seccion")+"&pacId="+(String)ht.get("pacId")+"&noAdmision="+(String)ht.get("noAdmision")+"&desc="+(String)ht.get("desc"));
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();

		cdo.addColValue("transfusion_id","0");
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("admision",noAdmision);
		cdo.setAction("I");
		cdo.setKey(iAntTransf.size()+1);
		try
		{
			iAntTransf.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&modeSec="+modeSec+"&seccion="+(String)ht.get("seccion")+"&pacId="+(String)ht.get("pacId")+"&noAdmision="+(String)ht.get("noAdmision")+"&desc="+(String)ht.get("desc"));
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_ant_transfusion");
			cdo.setWhereClause("pac_id="+pacId);
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
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
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>