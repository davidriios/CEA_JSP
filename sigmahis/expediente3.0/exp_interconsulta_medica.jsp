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
<jsp:useBean id="iCon" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
SOLICITUDES DE INTERCONSULTAS . EL MEDICO QUE ATIENTE SOLICITA ESPECIALISTAS Y EXPLICA POR QUE ES LA SOLICITUD.
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
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String from = request.getParameter("from");
String medico = request.getParameter("medico");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (from == null) from = "";
if (medico == null) medico = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	if (change == null)
	{
		iCon.clear();
		/*  11/08/2009 BENITO. SE CONSULTÓ CON KENIA E INDICA QUE LA TABLA DE DETALLE NO SE UTILIZA EN LAS INTERCOSULTAS MEDICAS. */
		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();

			cdo.addColValue("codigo","0");
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("hora",cDateTime.substring(11));
			if ((UserDet.getRefType().trim().equalsIgnoreCase("M")))cdo.addColValue("medico_solicitante",""+UserDet.getRefCode());
			else cdo.addColValue("medico_solicitante","");

			cdo.setKey(iCon.size()+1);
			cdo.setAction("I");

			try
			{
				iCon.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) modeSec = "edit";
	}//change=null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
document.title = 'Solicitud de Interconsultores - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){document.form0.medico.value = '<%=from.equals("salida_pop")?medico:((UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"")%>';checkViewMode();;var val = $("input[name='formaSolicitudX']:checked").val();setFormaSolicitud(val);}
function medicoList(k){abrir_ventana1('../common/search_medico.jsp?fp=exp_interconsultor&index='+k);}
function verIntercon(){abrir_ventana1('../expediente/exp_interconsulta_medica_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_30.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}

function consultas(){
	abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=6&interfaz=');
}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("aMedSize",""+iCon.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("medico",medico)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("formaSolicitud","")%>

<div class="headerform">
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
				<tr>
						<td>
								<%=fb.button("btnConsulta","Consultar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:consultas()\"")%>
								<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir()\"")%>
								<%=fb.button("btnVer","Ver Solicitudes de Interconsulta",false,false,"btn btn-inverse btn-sm|fa fa-search fa-lg",null,"onClick=\"javascript:verIntercon()\"")%>
						</td>
				</tr>
		</table>
</div>

 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
	 <tr class="TextRow01">
			<td colspan="3" class="controls form-inline"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
				<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>&nbsp;&nbsp;&nbsp;Usuario que Recibe, Transcribe, lee y Confirma:
					<%=fb.textBox("userCrea",UserDet.getName(),true, false,true,15,"form-control input-sm","","")%>
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,25,"form-control input-sm","","")%>
								<%=fb.button("searchMedic","...",false,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMedicList()\"")%>
				</td>
		</tr>

				<tr class="bg-headtabla">
						<th><cellbytelabel id="3">M&eacute;dico</cellbytelabel></th>
						<th><cellbytelabel id="4">Especialidad</cellbytelabel></th>
						<th class="text-center">
							<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,null)%>
						</th>
				</tr>
	</thead>
		<tbody>
<%
al = CmnMgr.reverseRecords(iCon);
for (int i=0; i<iCon.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iCon.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("usuario_creac"+i,cdo.getColValue("usuario_creacion"))%>
	<%=fb.hidden("fecha_creac"+i,cdo.getColValue("fecha_creacion"))%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
	<%=fb.hidden("comentario"+i,cdo.getColValue("comentario"))%>
	<%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
	<%=fb.hidden("medico_solicitante"+i,cdo.getColValue("medico_solicitante"))%>
	<%=fb.hidden("cod_medico"+i,cdo.getColValue("medico"))%>
	<%=fb.hidden("action"+i,cdo.getAction())%>
	<%=fb.hidden("key"+i,cdo.getKey())%>
	<%if(cdo.getAction().equalsIgnoreCase("D")){%>
	<%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
	<%=fb.hidden("cod_espec"+i,cdo.getColValue("cod_especialidad"))%>
	<%=fb.hidden("espec"+i,cdo.getColValue("descripcion"))%>
	<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
	<%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>

	<%}else{%>
		<tr>
			<td class="controls form-inline">
			<%=fb.textBox("nombre_medico"+i,cdo.getColValue("nombre_medico"),true,false,true,45,"form-control input-md",null,null)%>

						<%=fb.button("btnMedic","...",false,(viewMode || (cdo.getColValue("medico") != null && !cdo.getColValue("medico").trim().equals(""))),"btn btn-inverse btn-sm",null,"onClick=\"javascript:medicoList("+i+")\"")%>
			</td>
			<td class="controls form-inline"><%=fb.textBox("cod_espec"+i,cdo.getColValue("cod_especialidad"),false,false,true,3,"form-control input-md",null,null)%>
		<%=fb.textBox("espec"+i,cdo.getColValue("descripcion"),false,false,true,30,"form-control input-md",null,null)%></td>

			<td class="text-center">
				<%=fb.submit("rem"+i,"x",true,(viewMode || (cdo.getColValue("codigo") != null && !cdo.getColValue("codigo").trim().equals("0"))),"btn btn-inverse btn-sm",null,"onClick=\"javascript:removeItem(this.form.name,"+i+")\"")%>
			</td>
		</tr>
		<tr id="id<%=i%>">
			<td class="controls form-inline" colspan="3">
		<cellbytelabel id="5"><b>Observaciones del M&eacute;dico:</b>&nbsp;</cellbytelabel><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || (cdo.getColValue("codigo") != null && !cdo.getColValue("codigo").trim().equals("0"))),80,0,2000,"form-control input-md","width:100%","")%></td>
		</tr>
		<%}%>
<%
}
%>
</tbody>
		</table>

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

		 <%=fb.formEnd(true)%>
		</div>
		<!-- FIN contenido del sitio aqui-->
		</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("aMedSize"));

	String itemRemoved = "";
	al.clear();
	iCon.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_interconsultor");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia =  "+request.getParameter("noAdmision"));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("secuencia",request.getParameter("noAdmision"));

		if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("codigo");
			cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia =  "+request.getParameter("noAdmision"));
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion","sysdate");
		}
		else
		{
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creac"+i));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creac"+i));
		}
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion","sysdate");
		cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
		cdo.addColValue("medico",request.getParameter("cod_medico"+i));
		cdo.addColValue("nombre_medico",request.getParameter("nombre_medico"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("cod_especialidad",request.getParameter("cod_espec"+i));
		cdo.addColValue("descripcion",request.getParameter("espec"+i));
		cdo.addColValue("comentario",request.getParameter("comentario"+i));
		cdo.addColValue("hora",request.getParameter("hora"+i));
		cdo.addColValue("medico_solicitante",request.getParameter("medico"));
		cdo.addColValue("forma_solicitud",request.getParameter("formaSolicitud"));

		//cdo.addColValue("medico_solicitante","252");
		cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			key = request.getParameter("key"+i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = key;
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
					try
						{
							al.add(cdo);
					iCon.put(cdo.getKey(),cdo);
						}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		}
	}//for

	if (!itemRemoved.equals(""))
	{
		//iCon.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&from="+request.getParameter("from")+"&medico="+request.getParameter("medico"));
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();

		cdo.addColValue("codigo","0");
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("hora",cDateTime.substring(11));
		//cdo.addColValue("medico_solicitante",""+UserDet.getRefCode());
		if ((UserDet.getRefType().trim().equalsIgnoreCase("M")))cdo.addColValue("medico_solicitante",""+UserDet.getRefCode());
			else cdo.addColValue("medico_solicitante","");

		cdo.setAction("I");
		cdo.setKey(iCon.size()+1);

		try
		{
			iCon.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&from="+request.getParameter("from")+"&medico="+request.getParameter("medico"));
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_interconsultor");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision"));
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		//SQLMgr.insertList(al,true,false);
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

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&from=<%=from%>&medico=<%=medico%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>