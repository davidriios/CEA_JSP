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
<jsp:useBean id="iResultado" scope="session" class="java.util.Hashtable" />
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
StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String key = "";
if (desc == null ) desc = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cTime = CmnMgr.getCurrentDate("hh12:mi am");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo= (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	if (change == null)
	{
		iResultado.clear();

		sbSql.append("select a.id, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi am') as hora, a.usuario_crea, a.usuario_modif, a.destrostix, a.densidad_urinaria, a.ph, a.glucosa, a.pac_id, a.admision, to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am') as fecha_crea, a.observacion from tbl_sal_resultados_paciente a where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" order by a.fecha, a.hora");

		al = SQLMgr.getDataList(sbSql.toString());
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("U");
			try
			{
				iResultado.put(cdo.getKey(), cdo);
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

			cdo.addColValue("id","0");
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("hora",cTime);
			cdo.addColValue("fecha_crea",cDateTime);
			cdo.addColValue("fecha_modif",cDateTime);
			cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));

			cdo.setKey(iResultado.size()+1);
			cdo.setAction("I");

	     	try
			{
				iResultado.put(key, cdo);
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Control de Destrostix - '+document.title;
function imprimir(){abrir_ventana('../expediente/print_resultado_paciente.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function doAction(){newHeight();}
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
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("resultadoSize",""+iResultado.size())%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow01">
			<td colspan="8" align="right">&nbsp;<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel>]</a><!------> </td>
		</tr>
	<tr class="TextRow02">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextHeader" align="center">
	  <td width="18%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
	  <td width="20%"><cellbytelabel id="3">Hora</cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="4">Destrostix</cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="5">Densidad Urinaria</cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="6">P.H</cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="7">Glucosa</cellbytelabel></td>
	  <td width="20%"><cellbytelabel id="8">Observaci&oacute;n</cellbytelabel></td>
			<td width="3%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
		</tr>
<% al = CmnMgr.reverseRecords(iResultado);
for (int i=0; i<iResultado.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iResultado.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";

%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("usuario_crea"+i,cdo.getColValue("usuario_crea"))%>
		<%=fb.hidden("fecha_crea"+i,cdo.getColValue("fecha_crea"))%>
		<%=fb.hidden("usuario_modif"+i,cdo.getColValue("usuario_modif"))%>
		<%=fb.hidden("fecha_modif"+i,cdo.getColValue("fecha_modif"))%>
		<%//=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%//=fb.hidden("hora_salida"+i,cdo.getColValue("hora_salida"))%>
		<%//=fb.hidden("hora_entrada"+i,cdo.getColValue("hora_entrada"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
		 <%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		 <%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
		 <%=fb.hidden("destrostix"+i,cdo.getColValue("destrostix"))%>
		 <%=fb.hidden("densidad_urinaria"+i,cdo.getColValue("densidad_urinaria"))%>
		 <%=fb.hidden("ph"+i,cdo.getColValue("ph"))%>
		 <%=fb.hidden("glucosa"+i,cdo.getColValue("glucosa"))%>
		 <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
		<%}else{%>
		<tr class="<%=color%>" align="center">
		 <td><jsp:include page="../common/calendar.jsp" flush="true">
		  <jsp:param name="noOfDateTBox" value="1" />
		  <jsp:param name="clearOption" value="true" />
		  <jsp:param name="format" value="dd/mm/yyyy"/>
		  <jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
		  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
		  <jsp:param name="readonly" value="<%=(!cdo.getColValue("id").trim().equals("0"))?"y":"n"%>"/>
		 </jsp:include>	</td><!--  -->
		 <td><jsp:include page="../common/calendar.jsp" flush="true">
		  <jsp:param name="noOfDateTBox" value="1" />
		  <jsp:param name="clearOption" value="true" />
		  <jsp:param name="format" value="hh12:mi am"/>
		  <jsp:param name="nameOfTBox1" value="<%="hora"+i%>" />
		  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora")%>" />
		 </jsp:include>
	  	</td>
		<td><%=fb.textBox("destrostix"+i,cdo.getColValue("destrostix"),false,false,viewMode,10,15,"Text10",null,null)%></td>
		<td><%=fb.textBox("densidad_urinaria"+i,cdo.getColValue("densidad_urinaria"),false,false,viewMode,10,15,"Text10",null,null)%></td>
		<td><%=fb.textBox("ph"+i,cdo.getColValue("ph"),false,false,viewMode,10,15,"Text10",null,null)%></td>
		<td><%=fb.textBox("glucosa"+i,cdo.getColValue("glucosa"),false,false,viewMode,10,15,"Text10",null,null)%></td>
	  	<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode ),20,2,2000,"","","")%></td> <!---->
			<td><%=fb.submit("rem"+i,"X",false,(viewMode),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>

<%}}
fb.appendJsValidation("if(error>0)doAction();");
%>
		<tr class="TextRow02">
			<td colspan="8" align="right">
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
<%@ include file="../common/footer.jsp" %>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("resultadoSize"));
	//System.out.println("b acticon =    "+baction);
	String itemRemoved = "";
	al.clear();
	iResultado.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_resultados_paciente");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and id="+request.getParameter("id"+i));
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));

		cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modif","sysdate");


		if (request.getParameter("id"+i).equals("0")||request.getParameter("id"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("id");
			cdo.addColValue("id",request.getParameter("id"+i));
		}
		else cdo.addColValue("id",request.getParameter("id"+i));
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("hora",request.getParameter("hora"+i));
		cdo.addColValue("destrostix",request.getParameter("destrostix"+i));
		cdo.addColValue("densidad_urinaria",request.getParameter("densidad_urinaria"+i));
		cdo.addColValue("ph",request.getParameter("ph"+i));
		cdo.addColValue("glucosa",request.getParameter("glucosa"+i));
		cdo.setAction(request.getParameter("action"+i));
		cdo.setKey(i);
		if (cdo.getAction().equalsIgnoreCase("I")) {
			cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_crea","sysdate");
		}
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
					iResultado.put(cdo.getKey(),cdo);
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+request.getParameter("cds")+"&desc="+desc);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("id","0");
		cdo.addColValue("hora",cTime);
		cdo.addColValue("fecha",""+cDateTime.substring(0,10));
		cdo.addColValue("fecha_crea","sysdate");
		cdo.addColValue("fecha_modif","sysdate");
		cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
		cdo.setAction("I");
		cdo.setKey(iResultado.size()+1);
		try
		{
			iResultado.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+request.getParameter("cds")+"&desc="+desc);
		return;
	}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_resultados_paciente");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision"));
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
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&cds=<%=cds%>&mode=<%=mode%>&modeSec=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
















