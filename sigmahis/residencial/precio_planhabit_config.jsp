<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTHab" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTHab" scope="session" class="java.util.Vector" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String change = request.getParameter("change");
String key = "";
String sql = "";
String appendFilter = " WHERE usado_x_res = 'S' and codigo IN (17,18)";
int tLastLineNo = 0;
int rowCount = 0;

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("change") == null) change = "0";

if (request.getParameter("tLastLineNo") != null && !request.getParameter("tLastLineNo").equals("")) tLastLineNo = Integer.parseInt(request.getParameter("tLastLineNo"));
else tLastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{   
	if (id == null) throw new Exception("El Código del Plan no es válido. Por favor intente nuevamente!");
			
	if (change.equals("0"))	
	{ 	  
	   iTHab.clear();
	   vTHab.clear();
 	   sql = "SELECT tipo_habit, b.descripcion as tipoHabitDesc, precio, estado, fraccion, tipo_servicio FROM tbl_res_plan_habit a, tbl_res_tipo_habitacion b WHERE a.tipo_habit=b.secuencia and a.codigo_plan="+id;

	   al = SQLMgr.getDataList(sql);
	   tLastLineNo = al.size();
	   
	   for (int i = 1; i <= al.size(); i++)
	   {		    
		  CommonDataObject cdo2 = (CommonDataObject) al.get(i-1);

		  if (i < 10) key = "00" + i;
		  else if (i < 100) key = "0" + i;
		  else key = "" + i;
		  cdo2.addColValue("key",key);

		  try
		  {
			 iTHab.put(key,cdo2);
			 vTHab.addElement(cdo2.getColValue("tipo_habit"));		
		  }
		  catch(Exception e)
		  {
			 System.err.println(e.getMessage());
		  }
	   }	   
	}	

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Precios x Planes y Tipos de Habitación - '+document.title;

function addTipoHabit()
{
   abrir_ventana1('../common/check_res_tipo_habitacion.jsp?&id=<%=id%>&desc=<%=desc%>&fp=tipoHabit&tLastLineNo=<%=tLastLineNo%>');
}

function addTipoServ(index)
{
   abrir_ventana2('../admision/habitacion_tiposervicio_list.jsp?id=5&index='+index+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function closeWin()
{
   window.opener.location = 'plan_hopedaje_list.jsp';
   window.close();
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

function doAction()
{
<%
	if (request.getParameter("type")!= null && request.getParameter("type").equals("1"))
	{
%>
	addTipoHabit();
<%
	}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RESIDENCIAL - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>		
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("desc",desc)%>
			<%=fb.hidden("tLastLineNo",""+tLastLineNo)%>
			<%=fb.hidden("keySize",""+iTHab.size())%>			
			
				<tr class="TextRow02">
				    <td colspan="6"><%=id%> - <%=desc%></td>
					<td align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"00000"))
						//{
					%>
					     <%=fb.submit("btnPlan","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					<%
					    //}
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="10%">C&oacute;digo</td>
					<td width="30%">Habitaci&oacute;n</td>	
					<td width="10%">Tipo Serv.</td>
					<td width="15%">Precio</td>
					<td width="10%">Precio Diario</td>
					<td width="10%">Estado</td>
					<td width="10%">&nbsp;</td>
				</tr>			
				<%			  
				    String js = "";
					al = CmnMgr.reverseRecords(iTHab);				
				    for (int i = 1; i <= iTHab.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject cdo2 = (CommonDataObject) iTHab.get(key);					 
				%>					  
					  <%=fb.hidden("remove"+i,"")%>		
					  <%=fb.hidden("tipoHabitCode"+i,cdo2.getColValue("tipo_habit"))%>
					  <%=fb.hidden("tipoHabitDesc"+i,cdo2.getColValue("tipoHabitDesc"))%>	
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%>
					 <td><%=cdo2.getColValue("tipo_habit")%></td>
				     <td><%=cdo2.getColValue("tipoHabitDesc")%></td>
					 <td><%=fb.intBox("tipoServCode"+i,cdo2.getColValue("tipo_servicio"),false,false,false,5,2)%><%=fb.button("btnServ","...",true,false,null,null,"onClick=\"javascript:addTipoServ("+i+")\"")%></td>					 
					 <td><%=fb.decBox("precio"+i,cdo2.getColValue("precio"),false,false,false,15,10)%></td>
					 <td><%=fb.decBox("fraccion"+i,cdo2.getColValue("fraccion"),false,false,false,10,10)%></td>
					 <td><%=fb.select("estado"+i,"A=Activo,I=Inactivo",cdo2.getColValue("estado"))%></td>
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>		
				 </tr>															
				<%	
					}					
				%>  	
            			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				<tr class="TextRow02">
					<td colspan="7" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
									  <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>	
	        <%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{     
   tLastLineNo = Integer.parseInt(request.getParameter("tLastLineNo")); 
   int size = Integer.parseInt(request.getParameter("keySize"));	  
   id = request.getParameter("id");
   desc = request.getParameter("desc");
   String baction = request.getParameter("baction");
   String itemRemoved = "";
	
   al.clear();		
   for (int i=1; i<=size; i++)
   {   
	  CommonDataObject cdo3 = new CommonDataObject();
					 
	  cdo3.setTableName("tbl_res_plan_habit");
	  cdo3.setWhereClause("codigo_plan="+id);	 
	  cdo3.addColValue("codigo_plan",id);
	  cdo3.addColValue("tipo_habit",request.getParameter("tipoHabitCode"+i));
	  cdo3.addColValue("tipoHabitDesc",request.getParameter("tipoHabitDesc"+i));	 
	  cdo3.addColValue("tipo_servicio",request.getParameter("tipoServCode"+i));
	  cdo3.addColValue("precio",request.getParameter("precio"+i));
	  cdo3.addColValue("fraccion",request.getParameter("fraccion"+i));
	  cdo3.addColValue("estado",request.getParameter("estado"+i));
      cdo3.addColValue("key",request.getParameter("key"+i));
	        
	  if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
		 itemRemoved = cdo3.getColValue("key");  
	  else 
	  {
		 try
		 {
		 	iTHab.put(cdo3.getColValue("key"),cdo3); 
			al.add(cdo3);
		 }
		 catch(Exception e)
		 {
			System.err.println(e.getMessage());
		 }
	  }	
   }
   if (!itemRemoved.equals(""))
   {  	   
	  vTHab.remove(((CommonDataObject) iTHab.get(itemRemoved)).getColValue("tipo_habit"));
	  iTHab.remove(itemRemoved); 
	  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?id="+id+"&desc="+desc+"&tLastLineNo="+tLastLineNo+"&change=1");
	  return;
   }
   
   if (baction != null && baction.equals("+"))
   {      
	  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?type=1&id="+id+"&desc="+desc+"&tLastLineNo="+tLastLineNo+"&change=1");
	  return;
   }
		
   if (al.size() == 0)
   {
	  CommonDataObject cdo4 = new CommonDataObject();

	  cdo4.setTableName("tbl_res_plan_habit");
	  cdo4.setWhereClause("codigo_plan="+id);

	  al.add(cdo4); 
   } 
	
   SQLMgr.insertList(al);		 
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/residencial/plan_hopedaje_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/residencial/plan_hopedaje_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/residencial/plan_hopedaje_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>