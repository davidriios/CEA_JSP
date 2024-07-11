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
<jsp:useBean id="iMResponsable" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
ISSUE 1202
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String index = request.getParameter("index");
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int cont = CmnMgr.getCount(" select count(*) from tbl_sal_medico_responsable a, tbl_sec_users b where b.ref_code = a.medico and a.responsable ='S' and estado ='A' and upper(b.user_name)=upper('"+(String) session.getAttribute("_userName")+"') and a.pac_id = "+pacId+" and a.admision="+noAdmision+" ");
if(cont==0){modeSec= "view";viewMode = true;}
if (index == null) index = "0";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
		
	if (change == null )
	{
		 iMResponsable.clear();

		 sql="select a.id, a.pac_id, a.admision,to_char(a.fecha,'dd/mm/yyyy') fecha,nvl(a.estado,'A') estado, nvl(a.responsable,'N')responsable,to_char(a.fecha_mod,'dd/mm/yyyy hh12:mi:ss am')fecha_mod ,a.medico, a.observacion, am.primer_nombre||decode(am.segundo_nombre,'','',' '||am.segundo_nombre)||' '||am.primer_apellido|| decode(am.segundo_apellido, null,'',' '||am.segundo_apellido)||decode(am.sexo,'f', decode(am.apellido_de_casada,'','',' '||am.apellido_de_casada)) as nombre_medico from tbl_sal_medico_responsable a,tbl_adm_medico am where a.pac_id(+)="+pacId+" and a.admision="+noAdmision+" and a.medico=am.codigo order by a.fecha desc";
		 
		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setAction("U");
			cdo.setKey(i);
			try
			{
				iMResponsable.put(cdo.getKey(), cdo);
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
			cdo.addColValue("fecha_mod",cDateTime);
			cdo.addColValue("estado","A");
			cdo.addColValue("responsable","N");
			cdo.setAction("I");
			cdo.setKey(iMResponsable.size()+1); 
			try
			{
				iMResponsable.put(cdo.getKey(), cdo);
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
document.title = 'Medico Responsable - '+document.title;

function doAction(){<%if(cont==0){%>alert('Usted no es el Medico Responsable de la Atencion de Este Paciente!');<%}%>newHeight();}
function medicoList(k){abrir_ventana1('../common/search_medico.jsp?fp=responsable&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&index='+k);}
function getMedico(k){var medico=eval('document.form0.medico'+k).value;var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico ',' codigo=\''+medico+'\'','');eval('document.form0.nombre_medico'+k).value=medDesc}}
function setIndex(k){var index = eval('document.form0.index').value;if(confirm('¿Está seguro que desea Cambiar el Medico Responsable ?')){document.form0.index.value=k;}else{document.form0.responsable[index].checked=true;}}
function isChecked(k){var aMedSize = eval('document.form0.aMedSize').value;if(aMedSize>0)document.form0.responsable.checked=true;}
function imprimir(){abrir_ventana1('../expediente/print_exp_seccion_86.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
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
<%=fb.hidden("aMedSize",""+iMResponsable.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>


		<tr class="TextRow02">
			            <td colspan="5" align="right"><a href="javascript:imprimir()" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td>
		                </tr>
		<tr class="TextHeader" align="center">
			<td width="15%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="65%"><cellbytelabel id="3">M&eacute;dico</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="4">Responsable</cellbytelabel></td>
			<td width="05%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
		</tr>
<%
boolean editar = false;
al = CmnMgr.reverseRecords(iMResponsable);
for (int i=0; i<iMResponsable.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iMResponsable.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	 if(cdo.getColValue("id") != null && !cdo.getColValue("id").trim().equals("0"))editar=true;
	 else editar = false;
	 
	 if(cdo.getColValue("responsable").trim().equals("S")&&cdo.getColValue("estado").trim().equals("A"))
	 index = ""+i;
	 
%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("fecha_mod"+i,cdo.getColValue("fecha_mod"))%>
		<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
		 <%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		 <%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
		 <%=fb.hidden("responsable"+i,cdo.getColValue("responsable"))%>
		 <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
		<%}else{%>
		<tr class="<%=color%>" align="center">
			<td>
			<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
					<jsp:param name="readonly" value="<%="y"%>"/>
					</jsp:include>

					</td>
			<td><%//=fb.textBox("medico"+i,cdo.getColValue("medico"),true,false,true,10,"Text10",null,"onChange=\"javascript:getMedico("+i+")\"")%>
				<%=fb.textBox("nombre_medico"+i,cdo.getColValue("nombre_medico"),true,false,true,55,"Text10",null,null)%><%=fb.button("btnMedico","...",true,editar,null,null,"onClick=\"javascript:medicoList("+i+")\"","seleccionar medico")%></td>
					<td>
					<%=fb.radio("responsable","",(cdo.getColValue("responsable").trim().equals("S")&&cdo.getColValue("estado").trim().equals("A")),viewMode,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
					<%//=fb.checkbox("responsable"+i,"S",(cdo.getColValue("responsable").trim().equals("S")&&cdo.getColValue("estado").trim().equals("A")),viewMode,null,null,"")%></td>
		 <td rowspan="2"><%=fb.submit("rem"+i,"X",false,(viewMode || editar),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
		<tr id="id<%=i%>" class="<%=color%>">
			<td colspan="3" valign="top">
		<cellbytelabel id="5">Observaciones del M&eacute;dico</cellbytelabel><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),true,false,(viewMode || editar),80,3,2000,"","","")%></td>
	
		</tr>
<%}
}

fb.appendJsValidation("if(error>0)doAction();");
%>
<%=fb.hidden("index",""+index)%>

		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<script type="text/javascript">isChecked(<%=index%>);</script>
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
	iMResponsable.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_medico_responsable");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision =  "+request.getParameter("noAdmision")+" and id="+request.getParameter("id"+i));
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));

		if(request.getParameter("index") != null && !request.getParameter("index").trim().equals("") && request.getParameter("index").trim().equals(""+i+""))
		{
				cdo.addColValue("fecha_mod",cDateTime);
				cdo.addColValue("responsable","S");
				cdo.addColValue("estado","A");
		}
		else
		{
				cdo.addColValue("fecha_mod",request.getParameter("fecha_mod"+i));
				cdo.addColValue("responsable","N");
				cdo.addColValue("estado","I");
		}
		
		if (request.getParameter("id"+i).equals("0")||request.getParameter("id"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("id");
			//cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia =  "+request.getParameter("noAdmision"));
		}
		else
		{
			cdo.addColValue("id",request.getParameter("id"+i));
		}

		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("medico",request.getParameter("medico"+i));
		cdo.addColValue("nombre_medico",request.getParameter("nombre_medico"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i));
		
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
				iMResponsable.put(cdo.getKey(),cdo);
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
		cdo.addColValue("id","0");
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("fecha_mod",cDateTime);
		cdo.addColValue("estado","A");
		cdo.addColValue("responsable","N");
			
		cdo.setAction("I");
		cdo.setKey(iMResponsable.size()+1);

		try
		{
			iMResponsable.put(cdo.getKey(),cdo);
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

			cdo.setTableName("tbl_sal_medico_responsable");
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
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>