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
JOSUE ACTIVO LAS OPCIONES DE: EDITAR E ELIMINAR (REEMPLAZABDO (viewMode || editar) POR FALSE).
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
String userName = UserDet.getUserName();
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (desc == null) desc = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	if (change == null)
	{
		iProgreso.clear();
		 sql="SELECT a.nota_id, a.pac_id, a.admision,to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_crea,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion , a.codigo_terapia,a.nota_terapia, a.usuario_creacion, usuario_modificacion, am.descripcion  FROM tbl_sal_nota_terapia a, tbl_sal_tipo_terapia am WHERE a.pac_id(+) = "+pacId+" AND a.admision = "+noAdmision+" AND a.codigo_terapia = am.codigo order by a.fecha_creacion desc";


		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("U");

			try
			{
				iProgreso.put(cdo.getKey(),cdo);
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

			cdo.addColValue("nota_id","0");
			cdo.addColValue("fecha_crea",cDateTime.substring(0,10));
     		cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			 
			cdo.setKey(iProgreso.size()+1);
			cdo.setAction("I");

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
<script>
var noNewHeight = true;
document.title = 'Notas de Terapista - '+document.title;
function doAction(){newHeight();}
function terapiaList(k){abrir_ventana1('../common/search_terapia.jsp?fp=progreso&index='+k);}
function printExp(){abrir_ventana('../expediente/print_exp_seccion_62.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
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
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td colspan="3" align="right">&nbsp;<a href="javascript:printExp()" class="Link00">[<cellbytelabel id="1">Imprimrir</cellbytelabel>]</a></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="75%"><cellbytelabel id="3">Terapia</cellbytelabel></td>
			<td width="05%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
		</tr>
<%
boolean editar = true;
al = CmnMgr.reverseRecords(iProgreso);
for (int i=0; i<iProgreso.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iProgreso.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	 if(cdo.getColValue("nota_id") != null && !cdo.getColValue("nota_id").trim().equals("0")){if(!viewMode)editar=true;}
	 else {if(!viewMode)editar = false;}
%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("nota_id"+i,cdo.getColValue("nota_id"))%>
        <%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
        <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
	<%if(cdo.getAction().equalsIgnoreCase("D")){%>
	 <%=fb.hidden("codigo_terapia"+i,cdo.getColValue("codigo_terapia"))%>
	 <%=fb.hidden("nota_terapia"+i,cdo.getColValue("nota_terapia"))%>
	<%}else{%>
		
		<tr class="<%=color%>" align="center">
			<td><%if(!editar){%> 
			<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="<%="fecha_crea"+i%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_crea")%>" />
					</jsp:include>
					<%}else{%>
					<%=fb.textBox("fecha_crea"+i,cdo.getColValue("fecha_crea"),false,false,true,10)%>
					<%}%>
					</td>
			<td><%=fb.textBox("codigo_terapia"+i,cdo.getColValue("codigo_terapia"),true,false,true,10,"Text10",null,null)%>
				<%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,true,55,"Text10",null,null)%><%=fb.button("btnTerapia"+i,"...",true,editar,null,null,"onClick=\"javascript:terapiaList("+i+")\"","seleccionar terapia")%></td>
		 <td rowspan="2"><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td> <!--(viewMode || editar)-->
		</tr>
		<tr id="id<%=i%>" class="<%=color%>">
			<td colspan="2" valign="top">
		<cellbytelabel id="4">Observaciones del M&eacute;dico</cellbytelabel><%=fb.textarea("nota_terapia"+i,cdo.getColValue("nota_terapia"),true,false,false,80,3,2000,"","width:100%","")%></td>
		</tr>
		
<%}
}

fb.appendJsValidation("if(error>0)doAction();");
%>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="7">Cerrar</cellbytelabel>
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
		cdo.setTableName("tbl_sal_nota_terapia");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision =  "+request.getParameter("noAdmision")+" and nota_id="+request.getParameter("nota_id"+i));
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
		
		cdo.addColValue("USUARIO_CREACION",request.getParameter("usuario_creacion"+i));
		cdo.addColValue("FECHA_CREACION",request.getParameter("fecha_creacion"+i));
		cdo.addColValue("FECHA_CREA",request.getParameter("fecha_crea"+i));
		cdo.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
		cdo.addColValue("FECHA_MODIFICACION","sysdate");

		if (request.getParameter("nota_id"+i).equals("0")||request.getParameter("nota_id"+i).trim().equals("")){cdo.setAutoIncCol("nota_id");}
		else{cdo.addColValue("nota_id",request.getParameter("nota_id"+i));}
		
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.addColValue("codigo_terapia",request.getParameter("codigo_terapia"+i));
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("nota_terapia",request.getParameter("nota_terapia"+i));
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();

		cdo.addColValue("nota_id","0");
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("fecha_crea",cDateTime.substring(0,10));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
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

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_nota_terapia");	
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