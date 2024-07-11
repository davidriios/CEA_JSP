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
<jsp:useBean id="iControl" scope="session" class="java.util.Hashtable" />
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
String cds = request.getParameter("cds"); 
String desc = request.getParameter("desc");
if ( desc == null ) desc = "";

String key = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cTime = CmnMgr.getCurrentDate("hh12:mi am");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{ 
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	if (change == null)
	{			
		iControl.clear();
	
	sql="select a.id, to_char(a.fecha,'dd/mm/yyyy')fecha, a.usuario_crea, a.usuario_modif, to_char(a.hora_salida,'hh12:mi am')hora_salida, to_char(a.hora_entrada,'hh12:mi am')hora_entrada,  nvl(a.bacinete,'N') bacinete, nvl(a.marquilla,'N') marquilla,/* case when a.hora_entrada is not null or a.hora_salida is not null  then 'I' else*/ nvl(a.status,'A') status,  a.pac_id, a.admision, a.cds, a.observacion,to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea from tbl_sal_control_paciente a where a.cds="+cds+" /* and a.status ='A'*/ and a.pac_id= "+pacId+" and a.admision = "+noAdmision+" ";
	
		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);

			cdo.setKey(i);
			cdo.setAction("U");
			try
			{
				iControl.put(cdo.getKey(), cdo);
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
			cdo.addColValue("status","A");
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("hora_salida",cTime);
			cdo.addColValue("hora_entrada","");
			cdo.addColValue("fecha_crea",cDateTime);
			cdo.addColValue("fecha_modif",cDateTime);
			cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
			cdo.addColValue("bacinete","N");
			cdo.addColValue("marquilla","N");
						
			cdo.setKey(iControl.size()+1);
			cdo.setAction("I");

	     	try
			{
				iControl.put(key, cdo);
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
document.title = 'Control de Entradas y salidas de Pacientes - '+document.title;
function imprimir(){abrir_ventana('../expediente/print_control_salida.jsp?cds=<%=cds%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>');}
function doAction(){}
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
<%=fb.hidden("controlSize",""+iControl.size())%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("desc",desc)%>
    <tr class="TextRow01">
      <td colspan="6" align="right">&nbsp;<!---<a href="javascript:add()" class="Link00">[ Consultar ]</a>&nbsp;&nbsp;<!---
			---><a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel>]</a> </td>
    </tr>
	<tr class="TextRow02">
      <td colspan="6">&nbsp;</td>
    </tr>
    <tr class="TextHeader" align="center">
      <td width="15%" colspan="2">&nbsp;</td>
	  <td width="5%"><cellbytelabel id="2">Bacinete</cellbytelabel></td>
	  <td width="5%"><cellbytelabel id="3">Marquilla</cellbytelabel></td>	 
	  <td width="45%" rowspan="2"><cellbytelabel id="4">Observaci&oacute;n</cellbytelabel></td> 
      <td width="5%" rowspan="2"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
    </tr>
	 <tr class="TextHeader" align="center">
	 <td width="20%"><cellbytelabel id="5">Hora Salida</cellbytelabel> </td>
	  <td width="20%"><cellbytelabel id="6">Hora Entrada</cellbytelabel> </td>
	  <td width="5%"><cellbytelabel id="7">S&iacute;/No</cellbytelabel></td>
	  <td width="5%"><cellbytelabel id="7">S&iacute;/No</cellbytelabel></td>	 
    </tr>
<%
al = CmnMgr.reverseRecords(iControl);	
for (int i=0; i<iControl.size(); i++)
{
	 key = al.get(i).toString();		
	 cdo = (CommonDataObject) iControl.get(key);
	 String color = "TextRow02";
	 boolean isReadOnly = false; 
	 if (i % 2 == 0) color = "TextRow01";
	 if(cdo.getColValue("status").trim().equals("I"))isReadOnly=true;

%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("usuario_crea"+i,cdo.getColValue("usuario_crea"))%>
		<%=fb.hidden("fecha_crea"+i,cdo.getColValue("fecha_crea"))%>
		<%=fb.hidden("usuario_modif"+i,cdo.getColValue("usuario_modif"))%>
		<%=fb.hidden("fecha_modif"+i,cdo.getColValue("fecha_modif"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
	<%if(cdo.getAction().equalsIgnoreCase("D")){%>
		<%=fb.hidden("hora_salida"+i,cdo.getColValue("hora_salida"))%>
		<%=fb.hidden("hora_entrada"+i,cdo.getColValue("hora_entrada"))%>
		<%=fb.hidden("bacinete"+i,cdo.getColValue("bacinete"))%>
		<%=fb.hidden("marquilla"+i,cdo.getColValue("marquilla"))%>
		<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
	<%}else{%>
   
    <tr class="<%=color%>" align="center">
		 <td><jsp:include page="../common/calendar.jsp" flush="true">
		  <jsp:param name="noOfDateTBox" value="1" />
		  <jsp:param name="clearOption" value="true" />
		  <jsp:param name="format" value="hh12:mi am"/>
		  <jsp:param name="nameOfTBox1" value="<%="hora_salida"+i%>" />
		  <jsp:param name="readonly" value="<%=((isReadOnly||viewMode)?"y":"n")%>" />
		  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_salida")%>" />
		   </jsp:include>
		
	  	</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
		  <jsp:param name="noOfDateTBox" value="1" />
		  <jsp:param name="clearOption" value="true" />
		  <jsp:param name="format" value="hh12:mi am"/>
		  <jsp:param name="nameOfTBox1" value="<%="hora_entrada"+i%>" />
		  <jsp:param name="readonly" value="<%=((isReadOnly||viewMode)?"y":"n")%>" />
		  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_entrada")%>" />
		 </jsp:include>
		 
	  	</td>
	  	<td><%=fb.checkbox("bacinete"+i,"S",(cdo.getColValue("bacinete").equalsIgnoreCase("S")),(isReadOnly||viewMode),null,null,"")%></td>
		<td><%=fb.checkbox("marquilla"+i,"S",(cdo.getColValue("marquilla").equalsIgnoreCase("S")),(isReadOnly||viewMode),null,null,"")%></td>
	 <td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(isReadOnly||viewMode),30,2,2000,"","","")%></td> <!---->
      <td><%=fb.submit("rem"+i,"X",false,(!cdo.getColValue("id").trim().equals("0")||viewMode),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
    </tr>
    
<%}}
fb.appendJsValidation("if(error>0)doAction();");
%>
    <tr class="TextRow02">
      <td colspan="6" align="right">
        <cellbytelabel id="8">Opciones de Guardar</cellbytelabel>: 
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="9">Mantener Abierto</cellbytelabel> 
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="10">Cerrar</cellbytelabel> 
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
	int size = Integer.parseInt(request.getParameter("controlSize"));
	//System.out.println("b acticon =    "+baction);
	String itemRemoved = "";
	al.clear();
	iControl.clear();
	for (int i=0; i<size; i++)
	{		
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_control_paciente"); 
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and cds ="+request.getParameter("cds")+"/* and status ='A'*/ and id="+request.getParameter("id"+i));  
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
			cdo.addColValue("status",request.getParameter("status"+i));
				
		}
		else
		{		//System.out.println(" secuencia   =        "+request.getParameter("secuencia"+i));
			//cdo.setWhereClause("id="+request.getParameter("id"));  
			cdo.addColValue("id",request.getParameter("id"+i));
			if((request.getParameter("hora_salida"+i) !=null && !request.getParameter("hora_salida"+i).trim().equals("")) && (request.getParameter("hora_entrada"+i) !=null && !request.getParameter("hora_entrada"+i).trim().equals("")))
			cdo.addColValue("status","I");
			else cdo.addColValue("status",request.getParameter("status"+i));
			
			/*cdo.addColValue("usuario_crea",request.getParameter("usuario_crea"+i));
			cdo.addColValue("fecha_crea",request.getParameter("fecha_crea"+i));	*/	
		}
	
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("fecha",request.getParameter("fecha"+i));
		
		cdo.addColValue("hora_salida",request.getParameter("hora_salida"+i));
		cdo.addColValue("hora_entrada",request.getParameter("hora_entrada"+i));
		
		if (request.getParameter("bacinete"+i)!= null && request.getParameter("bacinete"+i).equalsIgnoreCase("S"))		
		cdo.addColValue("bacinete","S");
		else cdo.addColValue("bacinete","N");
		
		if (request.getParameter("marquilla"+i)!= null && request.getParameter("marquilla"+i).equalsIgnoreCase("S"))		
		cdo.addColValue("marquilla","S");
		else cdo.addColValue("marquilla","N");
		
		cdo.addColValue("cds",request.getParameter("cds"));
		
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
					iControl.put(cdo.getKey(),cdo);
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
		cdo.addColValue("status","A");
		
		
		cdo.addColValue("hora_salida",cTime);
		cdo.addColValue("hora_entrada","");
		cdo.addColValue("fecha",""+cDateTime.substring(0,10));
		
		cdo.addColValue("fecha_crea",cDateTime);
		cdo.addColValue("fecha_modif",cDateTime);
		cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
		cdo.addColValue("bacinete","N");
		cdo.addColValue("marquilla","N");
		cdo.setAction("I");
		cdo.setKey(iControl.size()+1);
		try
		{
			iControl.put(cdo.getKey(),cdo);
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

			cdo.setTableName("tbl_sal_control_paciente");  
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" /*and status ='A'*/ and cds="+request.getParameter("cds")); 						
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
















