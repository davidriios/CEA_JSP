<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDiagFlujo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagFlujo" scope="session" class="java.util.Vector" />
<%
/*
==========================================================
500045	VER LISTA DE ENFERMEDADES NOTIFICABLES
500047	AGREGAR ENFERMEDADES NOTIFICABLES
500048	MODIFICAR ENFERMEDAD NOTIFICABLE
==========================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500047") || SecMgr.checkAccess(session.getId(),"500048"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String key = "";
String fp = request.getParameter("fp");

ArrayList al = new ArrayList();

int diagLastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (fp == null) fp = "ctrlFlujo";

// TODO: REMOVE
//iDiagFlujo.clear();
//vDiagFlujo.clear();

if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));

CommonDataObject cdoEnf = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdo = new CommonDataObject();
	
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdoEnf.addColValue("codigo","0");
		cdoEnf.addColValue("email","");

		iDiagFlujo.clear();
		vDiagFlujo.clear();
	}
	else
	{
		if (id == null) throw new Exception("La Enfermedad Notificable no es válido. Por favor intente nuevamente!");

		sql = "select codigo, nombre, notificacion_inmediata as notificacion, observacion, tipo_diag tipoDiag, categoria_enf categoriaEnfermedad, email, tipo_organismo tipoOrga from tbl_cds_enfermedad_notificable where codigo="+id;
		
		cdoEnf = SQLMgr.getData(sql);
		
		if (change == null){
			System.out.println("THEBRAIN > ::::::::::::::::::::::::::::::::::::::GET CHANGE = "+change);
		
			sql = "select aa.id_enf, aa.id_diag, aa.status, aa.observacion, d.nombre descDiagnostico from tbl_sal_diags_x_enf aa, tbl_cds_diagnostico d where aa.id_diag = d.codigo and aa.id_enf = "+id;
			
		   al = SQLMgr.getDataList(sql);
		   
		   iDiagFlujo.clear();
		   vDiagFlujo.clear();
		   
		   diagLastLineNo = al.size();
		   
		   for (int i=1; i<=al.size(); i++){
				cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iDiagFlujo.put(key, cdo);
					vDiagFlujo.addElement(cdo.getColValue("id_diag"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i
		}// change == null
	}
	
	if (cdoEnf == null) cdoEnf = new CommonDataObject();

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
function doAction(){
  <%if (request.getParameter("type") != null){%>
	<%if (tab.equals("1")){%>
	   showDiagnosticoList();
	<%}%>
  <%}%>
	ctrlSendEmail();
}
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Enfermedad Notificable - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Enfermedad Notificable - Edición - "+document.title;
<%}%>
function ctrlSendEmail(){
    var notificacion = document.getElementById("notificacion").value;
    if (notificacion == "S"){
	   document.getElementById("email").readOnly = false;
	   document.getElementById("email").className="FormDataObjectEnabled";
	}else{
	    document.getElementById("email").readOnly = true;
	    document.getElementById("email").className="FormDataObjectDisabled";
		document.getElementById("email").value = "";
	}
}
function checkBlankEmail(){
   var notificacion = document.getElementById("notificacion").value;
   var email = document.getElementById("email").value;
   var btnSaveObj =  document.getElementById("save");
   if (notificacion == "S"){
      if (email == ""){
	    CBMSG.warning("Si usted escoge \"Notificación Inmediata\", debe proveer los correos a cuales notificar"); 
	    return false;
	  }
   }
   return true;
}
function doSubmit(fName){
  if (checkBlankEmail()){
    document.forms[fName].submit();
  }
}

function showDiagnosticoList(){
	abrir_ventana1('../common/check_diagnostico.jsp?fp=<%=fp%>&mode=<%=mode%>&id=<%=id%>&diagLastLineNo=<%=diagLastLineNo%>');
}

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ENFERMEDAD NOTIFICABLE"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<!-- MAIN DIV STARTS HERE -->
			<div id = "dhtmlgoodies_tabView1">

			<!-- TAB0 DIV STARTS HERE-->
			<div class = "dhtmlgoodies_aTab">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("codigo",cdoEnf.getColValue("codigo"))%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("nombreEnf",cdoEnf.getColValue("nombre"))%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("diagSize",""+iDiagFlujo.size())%>
			<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel id="1">Enfermedad Notificable</cellbytelabel></td>
				</tr>	
				<tr class="TextRow01" >
					<td width="20%">&nbsp;<cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="80%">&nbsp;<%=cdoEnf.getColValue("codigo")%></td>				
				</tr>							
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Nombre</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("nombre",cdoEnf.getColValue("nombre"),true,false,false,45)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">Observaciones</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("observacion",cdoEnf.getColValue("observacion"),false,false,false,45)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="5">Notificaci&oacute;n Inmediata</cellbytelabel></td>
					<td>
					 <table>
					 	<tr>
						    <td width="10%"><%=fb.select("notificacion","S=Si,N=No",cdoEnf.getColValue("notificacion"),false,false,0,null,null,"onchange=\"ctrlSendEmail()\"")%></td>
							<td width="20%" align="right"><cellbytelabel id="6">Notificar a(email separado por coma)</cellbytelabel>:</td>
					 		<td width="30%">
							   <%=fb.textarea("email",cdoEnf.getColValue("email"),false,false,((request.getParameter("notificacion")!=null && request.getParameter("notificacion").equals("S"))||!cdoEnf.getColValue("email").equals("")?false:true),30,2,1000,null,null,null)%>
							</td>
							<td width="10%"><cellbytelabel id="7">Tipo diagn&oacute;stico</cellbytelabel></td>
							<td width="30%">
							   <%=fb.select("tipoDiag","E=Entrada,S=Salida,A=Ambos",cdoEnf.getColValue("tipoDiag"),false,false,0,null,"","")%>
							</td>
					 	</tr>
					 </table>
					 
					</td>
				</tr>	
				<tr class="TextRow01">
				<td><cellbytelabel id="8">Aplicado a organismo</cellbytelabel>:</td>
				  <td>
				     <table>
				     	<tr>
							<td width="30%"><%=fb.select("tipoOrga","N=Nacional,I=Internacional,A=Ambos",cdoEnf.getColValue("tipoOrga"),false,false,0,null,"display:inline","")%></td>
							<td width="40%" align="right"><cellbytelabel id="9">Tipo Enfermedad</cellbytelabel></td>
							<td width="30%">
							  <%//=fb.select("categoriaEnfermedad","1=Normal,2=Contagioso,3=Fatal",cdoEnf.getColValue("categoriaEnfermedad"),false,false,0,null,"display:inline","")%>
							  <%=fb.select("categoriaEnfermedad","","",false,false,0)%>
							  <script type="text/javascript">
							    loadXML("../xml/fixed_params/categoriaEnfermedad.xml","categoriaEnfermedad","<%=cdoEnf.getColValue("categoriaEnfermedad")%>","VALUE_COL","LABEL_COL","KEY_COL");
							  </script>
							</td>
				     	</tr>
				     </table>
				  </td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
					<% String form = "'"+fb.getFormName()+"'";%>
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value); doSubmit("+form+")\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>	
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		   </div><!-- TAB0 DIV ENDS HERE -->
			
		   <!-- TAB1 DIV STARTS HERE -->	
		   <div class="dhtmlgoodies_aTab">
				
				  <table align="center" width="100%" cellpadding="0" cellspacing="1">
				    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codigo","")%>
					<%=fb.hidden("tab","1")%>
					<%=fb.hidden("id",""+id)%>
					<%=fb.hidden("diagSize",""+iDiagFlujo.size())%>
					<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
					 <tr class="TextHeader">
						  <td colspan="5" align="left">&nbsp;Diagn&oacute;sticos</td>
					 </tr>
					 <tr class="TextHeader01">
					 	<td colspan="5">[<%=id%>]<%=cdoEnf.getColValue("nombre")%></td>
					 </tr>
					 <tr class="TextHeader02">
					 	<td width="10%">Id Diagn&oacute;stico</td>
						<td width="30%">Descripci&oacute;n</td>
						<td width="6%" align="center">Status</td>
						<td width="49%">Observaciones</td>
						<td width="5%" align="center">
						<% form = "'"+fb.getFormName()+"'";%>
						<%=fb.submit("addDiagnostico","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Diagnósticos")%>
						</td>
					 </tr>
					 
					<%
						al = CmnMgr.reverseRecords(iDiagFlujo);
						for (int i=1; i<=iDiagFlujo.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdoDiagDet = (CommonDataObject) iDiagFlujo.get(key);
					%>
					<tr class="TextRow01">
						<td><%=cdoDiagDet.getColValue("id_diag")%></td>
						<td><%=cdoDiagDet.getColValue("descDiagnostico")%></td>
						<td align="center"><%=fb.select("status"+i,"A=Activo,I=Inactivo",cdoDiagDet.getColValue("status"),false,false,0,null,null,null)%>
						<%//=fb.select("tipoOrga","N=Nacional,I=Internacional,A=Ambos",cdo.getColValue("tipoOrga"),false,false,0,null,"display:inline","")%>
						</td>
						<td>
						<%=fb.textarea("observacion"+i,cdoDiagDet.getColValue("observacion"),false,false,false,50,2)%>
						</td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar Diagnósticos")%></td>
					</tr>
					<%=fb.hidden("key"+i,cdoDiagDet.getColValue("key"))%>
					<%=fb.hidden("remove"+i,"")%>
					<%=fb.hidden("status"+i,cdoDiagDet.getColValue("status"))%> 
					<%=fb.hidden("observacion"+i,cdoDiagDet.getColValue("observacion"))%>
					<%=fb.hidden("id_diag"+i,cdoDiagDet.getColValue("id_diag"))%>
					<%=fb.hidden("descDiagnostico"+i,cdoDiagDet.getColValue("descDiagnostico"))%>
					 <%  }  %>
					 
					 
				 <tr class="TextRow02">
					<td align="right" colspan="5">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>
				
		   </div><!-- TAB1 DIV ENDS HERE -->	   
		   
		   </div><!-- MAIN DIV ENDS HERE -->      
		</td>
	</tr>
</table>
<script type="text/javascript">
<%  
String tabLabel = "'Enfermedad Notificable'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Diagnósticos'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>		

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	
	if (tab.equals("0")){
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_cds_enfermedad_notificable"); 
		cdo.addColValue("nombre",request.getParameter("nombre")); 
		cdo.addColValue("notificacion_inmediata",request.getParameter("notificacion")); 
		cdo.addColValue("observacion",request.getParameter("observacion")); 
		
		/********************/
		cdo.addColValue("email",request.getParameter("email")); 
		cdo.addColValue("tipo_diag",request.getParameter("tipoDiag")); 
		cdo.addColValue("tipo_organismo",request.getParameter("tipoOrga")); 
		cdo.addColValue("categoria_enf",request.getParameter("categoriaEnfermedad")); 
		/*-----------------*/
	  if (mode.equalsIgnoreCase("add"))
	  {
		cdo.setAutoIncCol("codigo");

		SQLMgr.insert(cdo);
	  }
	  else
	  {
		cdo.setWhereClause("codigo="+request.getParameter("codigo"));

		SQLMgr.update(cdo);
	  }
	  
    }
  	else if (tab.equals("1")) //DIAGNOSTICOS
	{
		int size = 0;
		if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
		String itemRemoved = "";
		al.clear();

		for (int i=1; i<=size; i++)
		{
			System.out.println("THEBRAIN > :::::::::::::::::::::::::::::::::::::: POST FOR I");
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_diags_x_enf");  
			cdo.setWhereClause("id_enf="+id+"");
			
			cdo.addColValue("id_enf",id);
			cdo.addColValue("id_diag",request.getParameter("id_diag"+i));
			cdo.addColValue("status",request.getParameter("status"+i));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("descDiagnostico",request.getParameter("descDiagnostico"+i));
			
			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iDiagFlujo.put(cdo.getColValue("key"),cdo);
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vDiagFlujo.remove(((CommonDataObject) iDiagFlujo.get(itemRemoved)).getColValue("id_diag"));
    	    iDiagFlujo.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&id="+id);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			System.out.println("THEBRAIN > :::::::::::::::::::::::::::::::::::::: IS IN TAB1 diagLastLineNo = "+diagLastLineNo);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&id="+id);
			return;
		}
		
		if (al.size() == 0)
		{
		    System.out.println("THEBRAIN > :::::::::::::::::::::::::::::::::::::: POST AL = 0");
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_diags_x_enf");
			cdo.setWhereClause("id_enf="+id);

			al.add(cdo); 
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
		System.out.println("THEBRAIN > :::::::::::::::::::::::::::::::::::::: AFTER INSERTING AL ="+al.size());
	}
  
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/enfermedad_notific_list.jsp"))
	{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/enfermedad_notific_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/enfermedad_notific_list.jsp';
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
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&id=<%=id%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>&mode=edit&tab=<%=tab%>&fp=<%=fp%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>