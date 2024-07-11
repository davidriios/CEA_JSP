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
<jsp:useBean id="iAlimentacion" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
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
String turno = request.getParameter("turno"); 
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String turnoActual = "";

if ( desc == null ) desc = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{ 
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	sql=" select case when to_date(to_char(sysdate,'hh12 am'),'hh12 am') between to_date('03 pm','hh12 am') and to_date('11 pm','hh12 am')then '2=3/11' when to_date(to_char(sysdate,'hh12 am'),'hh12 am') between to_date('07 am','hh12 am') and to_date('03 pm','hh12 am')then '1=7/3' else '3=11/7' end turno from dual ";
	
	cdo = SQLMgr.getData(sql);
	turno = cdo.getColValue("turno");
	if (change == null)
	{			
		iAlimentacion.clear();
	sql="select a.id, to_char(a.fecha,'dd/mm/yyyy')fecha, a.turno, a.usuario_crea,a.cama, a.nombre, a.alimentacion, a.tipo_alimentacion, a.toma,to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea, a.observacion, a.peso from tbl_sal_alimentacion_paciente a where a.pac_id= "+pacId+" and a.admision = "+noAdmision+" and turno = "+turno.substring(0,1);
		
		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("U");

			try
			{
				iAlimentacion.put(cdo.getKey(), cdo);
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
			cdo.addColValue("turno","");
			cdo.addColValue("fecha_crea",cDateTime);
			cdo.addColValue("fecha_modif",cDateTime);
			cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
			
			cdo.setKey(iAlimentacion.size()+1);
			cdo.setAction("I");

	     	try
			{
				iAlimentacion.put(key, cdo);
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
<script>
var noNewHeight = true;
document.title = 'Alimentación Neonatal - '+document.title;
function imprimir(){abrir_ventana('../expediente/print_list_ordenes_nutricion.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function doAction(){}
</script>
<style type="text/css">
<!--
.style1 {color: #990000}
-->
</style>
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
<%=fb.hidden("modeSec",modeSec)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+iAlimentacion.size())%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%//=fb.hidden("turno",turno)%>
    <tr class="TextRow01">
      <td colspan="8" align="right">&nbsp;<!---<a href="javascript:add()" class="Link00">[ Consultar ]</a>&nbsp;&nbsp;-->
			<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel>]</a><!------> </td>
    </tr>
	<tr class="TextRow02">
      <td colspan="8">&nbsp;</td>
    </tr>
	<tr class="TextRow02">
      <td colspan="4" bordercolor="#990000">&nbsp;<cellbytelabel id="2">Fecha</cellbytelabel>:
        <jsp:include page="../common/calendar.jsp" flush="true">
		  <jsp:param name="noOfDateTBox" value="1" />
		  <jsp:param name="clearOption" value="true" />
		  <jsp:param name="format" value="dd/mm/yyyy"/>
		  <jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
		  <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
		 </jsp:include>
        <span class="style1">**<cellbytelabel id="3">Solo para registros Nuevos</cellbytelabel></span> </td>
	  <td colspan="4">&nbsp;<cellbytelabel id="4">Turno</cellbytelabel>: <%=fb.select("turno",turno,turno,false,false,0,"")%></td>
    </tr>
    <tr class="TextHeader" align="center">
	  <td width="10%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="5">Cama</cellbytelabel></td>
	  <td width="24%"><cellbytelabel id="6">Nombre</cellbytelabel></td>
	  <td width="24%"><cellbytelabel id="7">Alimentaci&aacute;n</cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="8">Tipo</cellbytelabel></td>	 
	  <td width="10%"><cellbytelabel id="9">Toma</cellbytelabel> # </td>	 
	  <td width="09%"><cellbytelabel id="10">Peso</cellbytelabel></td>
      <td width="3%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
    </tr>
<% 
al = CmnMgr.reverseRecords(iAlimentacion);	
for (int i=0; i<iAlimentacion.size(); i++)
{
	 key = al.get(i).toString();		
	 cdo = (CommonDataObject) iAlimentacion.get(key);
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
		<%//=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("turno"+i,cdo.getColValue("turno"))%>
   		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
   <%if(cdo.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
			<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
			<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
			<%=fb.hidden("alimentacion"+i,cdo.getColValue("alimentacion"))%>
			<%=fb.hidden("tipo_alimentacion"+i,cdo.getColValue("tipo_alimentacion"))%>
			<%=fb.hidden("toma"+i,cdo.getColValue("toma"))%>
			<%=fb.hidden("peso"+i,cdo.getColValue("peso"))%>
	<%}else{%>
    <tr class="<%=color%>" align="center">
		<td><%=fb.textBox("fecha"+i,cdo.getColValue("fecha"),false,false,true,8,10,"Text10",null,null)%></td>
     	<td><%=fb.textBox("cama"+i,cdo.getColValue("cama"),false,false,viewMode,5,10,"Text10",null,null)%></td>
	 	<td><%=fb.textBox("nombre"+i,cdo.getColValue("nombre"),true,false,viewMode,30,150,"Text10",null,null)%></td>
		<td><%=fb.textBox("alimentacion"+i,cdo.getColValue("alimentacion"),false,false,viewMode,20,1000,"Text10",null,null)%></td>
		<td><%//=fb.textBox("tipo_alimentacion"+i,cdo.getColValue("tipo_alimentacion"),false,false,viewMode,10,15,"Text10",null,null)%>
		
		<%=fb.select("tipo_alimentacion"+i,"F=FORMULA,P=PECHO,A=AMBOS",cdo.getColValue("tipo_alimentacion"),false,false,0,"S")%></td>
		
		<td><%=fb.textBox("toma"+i,cdo.getColValue("toma"),false,false,viewMode,5,2,"Text10",null,null)%><%//=fb.select("toma","T1=TOMA # 1,T2=TOMA # 2,T3=TOMA # 3,T4=TOMA # 4,T5=TOMA # 5",cdo.getColValue("toma"),false,false,0,"Text10",null,null)%></td>
		<td><%=fb.textBox("peso"+i,cdo.getColValue("peso"),false,false,viewMode,5,15,"Text10",null,null)%></td>
	  	<td rowspan="2"><%=fb.submit("rem"+i,"X",false,(viewMode),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
    </tr>
    <tr class="<%=color%>" align="center">
		<td colspan="7"><cellbytelabel id="11">Observaci&aacute;n</cellbytelabel>:<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode ),50,2,2000,"","","")%></td> <!---->
	</tr>
<%}
}
fb.appendJsValidation("if(error>0)doAction();");
%>
    <tr class="TextRow02">
      <td colspan="8" align="right">
        <cellbytelabel id="12">Opciones de Guardar</cellbytelabel>: 
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="13">Mantener Abierto</cellbytelabel> 
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="14">Cerrar</cellbytelabel> 
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
	int size = Integer.parseInt(request.getParameter("size"));
	//System.out.println("b acticon =    "+baction);
	String itemRemoved = "";
	al.clear();
	iAlimentacion.clear();
	for (int i=0; i<size; i++)
	{		
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_alimentacion_paciente"); 
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and turno="+request.getParameter("turno")+" and id="+request.getParameter("id"+i));  
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
				
		cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modif",cDateTime);	 
		cdo.addColValue("usuario_crea",request.getParameter("usuario_crea"+i));
		cdo.addColValue("fecha_crea",request.getParameter("fecha_crea"+i));
	
	
		if (request.getParameter("id"+i).equals("0")||request.getParameter("id"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("id");
			cdo.addColValue("id",request.getParameter("id"+i));
			cdo.addColValue("turno",request.getParameter("turno"));
			cdo.addColValue("fecha",request.getParameter("fecha"));
		}
		else
		{		
			cdo.addColValue("id",request.getParameter("id"+i));
			cdo.addColValue("turno",request.getParameter("turno"+i));
			cdo.addColValue("fecha",request.getParameter("fecha"+i));
		}

		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("cama",request.getParameter("cama"+i));
		cdo.addColValue("nombre",request.getParameter("nombre"+i));
		cdo.addColValue("alimentacion",request.getParameter("alimentacion"+i));
		cdo.addColValue("tipo_alimentacion",request.getParameter("tipo_alimentacion"+i));
		cdo.addColValue("toma",request.getParameter("toma"+i));
		cdo.addColValue("peso",request.getParameter("peso"+i));
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
					iAlimentacion.put(cdo.getKey(),cdo);
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&turno="+request.getParameter("turno")+"&desc="+desc);
		return;
	}
	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("id","0");
		cdo.addColValue("fecha",""+cDateTime.substring(0,10));
		cdo.addColValue("fecha_crea",cDateTime);
		cdo.addColValue("fecha_modif",cDateTime);
		cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
		cdo.setAction("I");
		cdo.setKey(iAlimentacion.size()+1);

		try
		{
			iAlimentacion.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&turno="+request.getParameter("turno")+"&desc="+desc);
		return;
	}	

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_alimentacion_paciente");  
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and turno="+request.getParameter("turno"));   						
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&turno=<%=turno%>&mode=edit&pacId=<%=pacId%>&modeSec=<%=modeSec%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
















