<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="hashCirugia" scope="session" class="java.util.Hashtable" />
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
ArrayList alViaAd = new ArrayList();
ArrayList alAsa  = new ArrayList();
ArrayList alAnest = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String rowSpan ="2";
String desc = request.getParameter("desc");
if (fg == null) fg = "H";
if (!fg.equalsIgnoreCase("H")) rowSpan = "3";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
String key = "";
String fecha = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
 String desc2="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);if(cdo!=null)desc = cdo.getColValue("descripcion");}	
alAnest = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_tipo_anestesia order by 2",CommonDataObject.class);
alAsa = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_tipo_asa order by 2",CommonDataObject.class);

if (change == null)
	{
	hashCirugia.clear();

  sql="select tipo_asa, plan, a.codigo, a.cod_paciente, to_char (a.fec_nacimiento, 'dd/mm/yyyy') as fec_nacimiento, a.edad, a.complicacion, a.observacion, a.tipo_registro, a.diagnostico, a.procedimiento, a.tipo_anestesia as tipoanestesia, to_char (a.fecha, 'dd/mm/yyyy') as fecha, a.pac_id, decode (a.tipo_registro, 'H', a.diagnostico, 'C', a.diagnostico /*a.procedimiento*/) codregistro, decode (a.tipo_registro, 'C', decode (d.observacion, null, d.nombre, d.observacion) /*decode (b.observacion, null, b.descripcion, b.observacion)*/, 'H', decode (d.observacion, null, d.nombre, d.observacion)) as descregistro, c.descripcion as anestesia from tbl_sal_cirugia_paciente a, tbl_cds_procedimiento b, tbl_sal_tipo_anestesia c, tbl_cds_diagnostico d where a.procedimiento = b.codigo(+) and a.tipo_anestesia = c.codigo(+) and pac_id = "+pacId+" and a.diagnostico = d.codigo(+) order by fecha asc";

	al=SQLMgr.getDataList(sql);
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
 		cdo.setKey(i);
		cdo.setAction("U");
		try
		{
			hashCirugia.put(cdo.getKey(),cdo);
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
			cdo.addColValue("EDAD","");
			cdo.addColValue("fecha",fecha);
			cdo.addColValue("tipo_registro",fg);
			cdo.setKey(hashCirugia.size()+1);
			cdo.setAction("I"); 
			try
			{
				hashCirugia.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) modeSec = "edit";

	}//change=null
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'HOSPITALIZACION Y CIRUGIAS - '+document.title;
function doAction(){newHeight();}
function listProcedimiento(k){var tipo = eval('document.form0.tipoRegistro'+k).value;abrir_ventana1('../common/search_diagnostico.jsp?fp=HC&index='+k);}
function listAnestesia(index){abrir_ventana1('../expediente/list_anestesia.jsp?id=1&index='+index);}
function imprimirExp(){abrir_ventana('../expediente/print_exp_seccion_4.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%if(fg.trim().equals("H")){%>
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%}else{%>
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value='EVALUACION PRE - ANESTESICA '></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%}%>

<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
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
			<%=fb.hidden("hosptSize",""+hashCirugia.size())%>
			<%=fb.hidden("fg",fg)%>
            <%=fb.hidden("desc",desc)%>

	<tr class="TextRow02">
		<td colspan="6" align="right">&nbsp;<a href="javascript:imprimirExp()"  class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td>
	</tr>
	<tr class="TextHeader" align="center">
		<td></td>
		<td width="37%" rowspan="2"><cellbytelabel id="2">Diagn&oacute;stico / Procedimiento</cellbytelabel></td>
		<td width="23%" rowspan="2"><cellbytelabel id="3">Anestesia</cellbytelabel></td>
		<td width="4%" rowspan="2"><cellbytelabel id="4">Edad</cellbytelabel></td>
		<td width="17%" rowspan="2"><cellbytelabel id="5">Fecha</cellbytelabel></td>
		<td width="3%" rowspan="2" align="center"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Hospitalización y Cirugía")%></td>
	</tr>
	<tr class="TextHeader">
		<td align="center">Tipo</td>
	</tr>
	<%
	al=CmnMgr.reverseRecords(hashCirugia);
	for(int i=0; i<hashCirugia.size();i++)
	{
	key = al.get(i).toString();

	cdo=(CommonDataObject)hashCirugia.get(key);
	String color = "TextRow01";
	String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
	if (i % 2 == 0) color = "TextRow02";
	%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
	<%if(cdo.getAction().equalsIgnoreCase("D")){%>
	 <%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
	<%}else{%>
	<tr class="<%=color%>">
		<td align="center"><%=fb.select("tipoRegistro"+i,"H=Hospitalización, C=Cirugía",cdo.getColValue("TIPO_REGISTRO"),false,viewMode,0,"Text10",null,null)%></td>
		<td><%=fb.textBox("codRegistro"+i,cdo.getColValue("codRegistro"),false,false,true,3,20,"Text10",null,null)%>
		<%=fb.textBox("descRegistro"+i, cdo.getColValue("descRegistro"),false,false,true,32,200,"Text10",null,null)%>
		<%=fb.button("btnDiagnostico","...",true,viewMode,"Text10",null,"onClick=\"javascript:listProcedimiento("+i+")\"")%>
		</td>
		<td><% if(viewMode){%><%=fb.hidden("tipoanestesia"+i,cdo.getColValue("tipoanestesia"))%><%}%>
				<%=fb.select("tipoanestesia"+i,alAnest,cdo.getColValue("tipoanestesia"),false,viewMode,0,"Text10",null,null,"","S")%></td>
		<td align="center"><%=fb.intBox("edad"+i,cdo.getColValue("edad"),false,false,false,2,3,"",null,null)%></td>
		<td  align="center"><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="format" value="dd/mm/yyyy"/>
							<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
							<jsp:param name="readonly" value="n"/>
							</jsp:include>
        </td>
		<td rowspan="<%=rowSpan%>"><%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
	</tr>
	<tr class="<%=color%>">
		<td colspan="2" align="left"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel>:<br>
		<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,2,2000,null,"width:100%","")%>
		</td>
		<td colspan="3"><cellbytelabel id="7">Complicaci&oacute;n</cellbytelabel>:<br>
		<%=fb.textarea("complicacion"+i,cdo.getColValue("complicacion"),false,false,viewMode,60,2,2000,null,"width:100%","")%></td>
	</tr>
	<%if(!fg.trim().equals("H")){%>
	<tr class="<%=color%>">
		<td colspan="2" align="left">Tipo Asa<%=fb.select("tipo_asa"+i,alAsa,cdo.getColValue("tipo_asa"),false,viewMode,0,"Text10",null,null,"","S")%></td>
		<td colspan="3"><cellbytelabel id="8">Plan</cellbytelabel><br>
		<%=fb.textarea("plan"+i,cdo.getColValue("plan"),false,false,viewMode,60,2,1000,null,"width:100%","")%></td>
	</tr>
	<%}%>
	<%}
	}//End For
	fb.appendJsValidation("if(error>0)doAction();");
	%>
	<tr class="TextRow02" >
		<td colspan="6" align="right">
				<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="11">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
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
	if (request.getParameter("hosptSize") != null)
	size = Integer.parseInt(request.getParameter("hosptSize"));

	al.clear();
	hashCirugia.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("TBL_SAL_CIRUGIA_PACIENTE");
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and codigo="+request.getParameter("codigo"+i));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.addColValue("COMPLICACION",request.getParameter("complicacion"+i));
		if (request.getParameter("codigo"+i) ==null || request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("CODIGO");
			cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId"));
		}
		else cdo.addColValue("codigo",request.getParameter("codigo"+i));

		if (request.getParameter("tipoRegistro"+i) != null && request.getParameter("tipoRegistro"+i).trim().equals("H"))
		{
			cdo.addColValue("diagnostico",request.getParameter("codRegistro"+i));
		}
		else cdo.addColValue("diagnostico",request.getParameter("codRegistro"+i)); //cdo.addColValue("procedimiento",request.getParameter("codRegistro"+i));

		cdo.addColValue("descRegistro",request.getParameter("descRegistro"+i));
		cdo.addColValue("codRegistro",request.getParameter("codRegistro"+i));

		cdo.addColValue("EDAD",request.getParameter("edad"+i));
		cdo.addColValue("FECHA",request.getParameter("fecha"+i));
		cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
		cdo.addColValue("TIPO_REGISTRO",request.getParameter("tipoRegistro"+i));
		cdo.addColValue("TIPO_ANESTESIA",request.getParameter("tipoanestesia"+i));
		cdo.addColValue("tipoanestesia",request.getParameter("tipoanestesia"+i));

		if(!fg.trim().equals("H")){
		cdo.addColValue("tipo_asa",request.getParameter("tipo_asa"+i));
		cdo.addColValue("plan",request.getParameter("plan"+i));
		}

		  cdo.setKey(i);
		  cdo.setAction(request.getParameter("action"+i));
		
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getColValue("key");
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}
			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					hashCirugia.put(cdo.getKey(),cdo);
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&fg="+request.getParameter("fg")+"&desc="+desc);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("CODIGO","0");
		cdo.addColValue("fecha",fecha);
		cdo.addColValue("TIPO_ANESTESIA","");
		cdo.addColValue("PROCEDIMIENTO","");
		cdo.addColValue("tipo_registro",fg);

		cdo.setKey(hashCirugia.size()+1);
		cdo.setAction("I");
		try
		{
			hashCirugia.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&fg="+request.getParameter("fg")+"&desc="+desc);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_cirugia_paciente");
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

