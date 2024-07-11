<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="hashTraum" scope="session" class="java.util.Hashtable" />
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
ArrayList alTraum = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDateTime2 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String key = "";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
		alTraum = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_factor_trauma order by codigo",CommonDataObject.class);
	if (change == null)
	{
	hashTraum.clear();
	sql="select a.cod_paciente, to_char(a.fec_nacimiento,'dd/mm/yyyy') as fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy hh12:mi am') as fecha, a.tipo_trauma, a.observacion, a.pac_id,a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion from tbl_sal_antecedente_trauma a where a.pac_id="+pacId+" order by a.fecha desc";
	al=SQLMgr.getDataList(sql);
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		cdo.setAction("U");
		cdo.setKey(i);
		try
		{
			hashTraum.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}//End For
	
		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();
			cdo.addColValue("CODIGO","0");
			//cdo.addColValue("fec_nacimiento",cDateTime.subString(0,10));
			cdo.addColValue("fecha",cDateTime2);
			cdo.setKey(hashTraum.size()+1);
			cdo.setAction("I");
			try
			{
				hashTraum.put(cdo.getKey(),cdo);
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
document.title = 'TRAUMATISMOS Y SECUELAS - '+document.title;
function doAction(){newHeight();}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_6.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%"  cellpadding="0" cellspacing="0" >
	<tr>
		<td valign="top">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
			<%=fb.hidden("traumaSize",""+hashTraum.size())%>
			<tr class="TextRow02">
			<td colspan="5" align="right"><a href="javascript:imprimir()"  class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
		</tr>
			<tr class="TextHeader" align="center">
				<td width="30%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
				<td width="65%"><cellbytelabel id="3">Tipo de Trauma</cellbytelabel> </td>
				<td width="5%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Traumatismo y Secuela")%></td>
			</tr>
<%
					al = CmnMgr.reverseRecords(hashTraum);
					
					for (int i=0; i<hashTraum.size(); i++)
					{
					key = al.get(i).toString();
					cdo = (CommonDataObject) hashTraum.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
			<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
			<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("tipoTrauma"+i,cdo.getColValue("tipo_trauma"))%>
			<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
			<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
			<%}else{%>
		<tr class="<%=color%>">
			<td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
                                <jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								</jsp:include></td>
			<td><%=fb.select("tipoTrauma"+i,alTraum,cdo.getColValue("tipo_trauma"),false,viewMode,0,"Text10",null,"")%></td>					
			<td align="center" rowspan="2"><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
		<tr class="<%=color%>" >
			<td valign="middle" align="right"><cellbytelabel id="4">Observaciones</cellbytelabel></td>
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,3,2000,null,"width:100%","")%></td>
		</tr>
		<%}%>

<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
			<tr class="TextRow02" >
				<td colspan="4" align="right">
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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int size = 0;
	if (request.getParameter("traumaSize") != null)
	size = Integer.parseInt(request.getParameter("traumaSize"));
	al.clear();
	hashTraum.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_antecedente_trauma");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and codigo="+request.getParameter("codigo"+i));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("FECHA",request.getParameter("fecha"+i));
		cdo.addColValue("TIPO_TRAUMA",request.getParameter("tipoTrauma"+i));
		if(request.getParameter("usuario_creacion"+i) == null ||request.getParameter("usuario_creacion"+i).trim().equals(""))
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		else cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
		if(request.getParameter("fecha_creacion"+i) == null ||request.getParameter("fecha_creacion"+i).trim().equals(""))
		cdo.addColValue("fecha_creacion",cDateTime);
		else cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
		cdo.addColValue("fecha_modificacion",cDateTime);
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("CODIGO");
			cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId"));
		}
		else cdo.addColValue("CODIGO",request.getParameter("codigo"+i));
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.setKey(i);
  		cdo.setAction(request.getParameter("action"+i));
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo.getKey();
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}	
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				al.add(cdo);
				hashTraum.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for
	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+noAdmision+"&seccion="+request.getParameter("seccion")+"&desc="+desc);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("CODIGO","0");
		cdo.addColValue("FECHA",cDateTime2);
		cdo.setAction("I");
		cdo.setKey(hashTraum.size() + 1);
		try
		{
			hashTraum.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+noAdmision+"&seccion="+request.getParameter("seccion")+"&desc="+desc);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_antecedente_trauma");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId"));
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

