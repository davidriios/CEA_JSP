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
<jsp:useBean id="iProgreso" scope="session" class="java.util.Hashtable" />
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
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String estado = request.getParameter("estado");
String key = "";
int progresoLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (estado == null) estado = "";
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
		iProgreso.clear();
		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();

			cdo.addColValue("progreso_id","0");
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("hora",cDateTime.substring(11));
			 
			if(UserDet.getRefType().trim().equalsIgnoreCase("M"))
			{
				cdo.addColValue("nombre_medico",""+UserDet.getName());
				cdo.addColValue("medico",""+UserDet.getRefCode());
			}

			cdo.setAction("I");
			cdo.setKey(iProgreso.size()+1);

			try
			{
				iProgreso.put(cdo.getKey(),cdo);
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Progreso Clinico - '+document.title;
function doAction(){newHeight();}
function medicoList(k){abrir_ventana1('../common/search_medico.jsp?fp=progreso&index='+k);}
function getMedico(k){var medico=eval('document.form0.medico'+k).value;var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico ',' codigo=\''+medico+'\'','');eval('document.form0.nombre_medico'+k).value=medDesc;}}
function verProgreso(){abrir_ventana1('../expediente/exp_progreso_clinico_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&estado=<%=estado%>');}
function printExp(){abrir_ventana("../expediente/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
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
<%=fb.hidden("aMedSize",""+iProgreso.size())%>
<%=fb.hidden("progresoLineNo",""+progresoLineNo)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("estado", estado)%>
		<tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr align="center" class="TextRow01">
				<td colspan="3" align="right">
                <a href="javascript:verProgreso()" class="Link00">[ <cellbytelabel id="1">Ver Progreso</cellbytelabel> ]</a>
                <a href="javascript:printExp();" class="Link00">[<cellbytelabel id="2">Imprimir</cellbytelabel>]</a>
                </td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="3">Fecha</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="4">Hora</cellbytelabel></td>
			<td width="60%"><cellbytelabel id="5">M&eacute;dico</cellbytelabel></td>
		</tr>
<%
boolean editar = false;
al = CmnMgr.reverseRecords(iProgreso);
for (int i=0; i<iProgreso.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iProgreso.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	 if(cdo.getColValue("progreso_id") != null && !cdo.getColValue("progreso_id").trim().equals("0"))editar=true;
	 else editar = false;
%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("progreso_id"+i,cdo.getColValue("progreso_id"))%>
		<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("observacion"+i,cdo.getColValue("ordenDiag"))%>
			 <%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
			 <%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
			 <%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
			 
		<%}else{%>
		<tr class="<%=color%>" align="center">
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
				<jsp:param name="readonly" value="<%=(cdo.getColValue("progreso_id") != null && !cdo.getColValue("progreso_id").trim().equals("0"))?"y":"n"%>"/>
				</jsp:include>
			</td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%="hora"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora")%>" />
				<jsp:param name="readonly" value="<%=(cdo.getColValue("progreso_id") != null && !cdo.getColValue("progreso_id").trim().equals("0"))?"y":"n"%>"/>
				<jsp:param name="format" value="hh12:mi am" />
				</jsp:include>
			</td>
			<td>
				<%//=fb.textBox("medico"+i,cdo.getColValue("medico"),true,false,editar,10,"Text10",null,"onChange=\"javascript:getMedico("+i+")\"")%>
				<%=fb.textBox("nombre_medico"+i,cdo.getColValue("nombre_medico"),true,false,true,55,"Text10",null,null)%>
				<%=fb.button("btnMedico","...",true,editar,null,null,"onClick=\"javascript:medicoList("+i+")\"","seleccionar medico")%>
			</td>
		</tr>
		<tr id="id<%=i%>" class="<%=color%>">
			<td colspan="3" valign="top">
				<cellbytelabel id="6">Observaciones del M&eacute;dico</cellbytelabel>
				<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),true,false,(viewMode || editar),80,8,2000,"","","")%>
			</td>
		</tr>
<%}
}

fb.appendJsValidation("if(error>0)doAction();");
%>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
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
	iProgreso.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_progreso_clinico");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision")+" and progreso_id="+request.getParameter("progreso_id"+i));
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));

		if (request.getParameter("progreso_id"+i).equals("0")||request.getParameter("progreso_id"+i).trim().equals(""))cdo.setAutoIncCol("progreso_id");
		else cdo.addColValue("progreso_id",request.getParameter("progreso_id"+i));
		
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("medico",request.getParameter("medico"+i));
		cdo.addColValue("nombre_medico",request.getParameter("nombre_medico"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i)+" "+request.getParameter("hora"+i));
		
		cdo.setAction(request.getParameter("action"+i));
		cdo.setKey(i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo.getKey();
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}
	
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iProgreso.put(cdo.getKey(),cdo);
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision"));
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("progreso_id","0");
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("hora",cDateTime.substring(11));
		cdo.setAction("I");
		cdo.setKey(iProgreso.size()+1);
	
		try
		{
			iProgreso.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision"));
		return;
	}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_progreso_clinico");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
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
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&estado=<%=estado%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>