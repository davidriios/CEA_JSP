<%//@ page errorPage="../error.jsp"%>
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
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Solicitud de Interconsultores - '+document.title;
function doAction(){newHeight();document.form0.medico.value = <%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;checkViewMode();setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function medicoList(k){abrir_ventana1('../common/search_medico.jsp?fp=exp_interconsultor&index='+k);}
function verIntercon(){abrir_ventana1('../expediente/exp_interconsulta_medica_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&from=<%=from%>&medico=<%=medico%>');}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_30.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function consultas(){abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=6&interfaz=');}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
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

		<tr class="TextRow02">
			<td colspan="7">&nbsp;</td>
		</tr>
		<tr align="center" class="TextRow01">
				<td colspan="3" align="right">
                <a href="javascript:consultas()" class="Link00Bold">[ <cellbytelabel>Consultar</cellbytelabel> ]</a>
                <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a><a href="javascript:verIntercon()" class="Link00">[ <cellbytelabel id="2">Ver Solicitudes de Interconsulta</cellbytelabel> ]</a></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel> 
				&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>	
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,50,"","","")%>
				<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
			</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="45%"><cellbytelabel id="3">M&eacute;dico</cellbytelabel></td>
			<td width="50%"><cellbytelabel id="4">Especialidad</cellbytelabel></td>
			<td width="05%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Interconsulta")%></td>
		</tr>
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
		<tr class="<%=color%>" align="center">
			<td><%//=fb.textBox("cod_medico"+i,cdo.getColValue("medico"),true,false,true,5,"Text10",null,null)%>
			<%=fb.textBox("nombre_medico"+i,cdo.getColValue("nombre_medico"),true,false,true,45,"Text10",null,null)%><%=fb.button("btnmedico","...",true,(viewMode || (cdo.getColValue("medico") != null && !cdo.getColValue("medico").trim().equals(""))),null,null,"onClick=\"javascript:medicoList("+i+")\"","seleccionar medico")%></td>
			<td><%=fb.textBox("cod_espec"+i,cdo.getColValue("cod_especialidad"),false,false,true,3,"Text10",null,null)%>
		<%=fb.textBox("espec"+i,cdo.getColValue("descripcion"),false,false,true,30,"Text10",null,null)%></td>

		 <td rowspan="2"><%=fb.submit("rem"+i,"X",false,(viewMode || (cdo.getColValue("codigo") != null && !cdo.getColValue("codigo").trim().equals("0"))),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
		<tr id="id<%=i%>" class="<%=color%>">
			<td colspan="2" valign="top">
		<cellbytelabel id="5">Observaciones del Meacute;dico</cellbytelabel><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || (cdo.getColValue("codigo") != null && !cdo.getColValue("codigo").trim().equals("0"))),80,4,2000,"","width:100%","")%></td>
		</tr>
		<%}%>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&medico="+request.getParameter("medico")+"&from="+request.getParameter("from"));
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

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&medico="+request.getParameter("medico")+"&from="+request.getParameter("from"));
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&medico=<%=medico%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>