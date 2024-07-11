
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
<jsp:useBean id="HashFlia" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="VKey" scope="session" class="java.util.Vector" />
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
ArrayList list = new ArrayList();
String almaId = request.getParameter("almaId");
String change = request.getParameter("change");
String filter = " and  a.recibe_mov = 'S'";
String key = "";
String sql = "";
int lastLineNo = 0;
int rowCount = 0;

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("change") == null) change = "0";

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{   
	if (almaId == null) throw new Exception("El Almacen no es válido. Por favor intente nuevamente!");
		
	sql = "SELECT descripcion as alma FROM tbl_inv_almacen WHERE codigo_almacen="+almaId+" and compania="+(String) session.getAttribute("_companyId");
	cdo = SQLMgr.getData(sql);
	
	if (change.equals("0"))	
	{ 	  
	   HashFlia.clear();
	   VKey.clear();
 	   sql = "SELECT a.familia as fliaCode, b.nombre as flia, a.almacen, a.familia||'¦'||a.compania as keyFlia, a.cg_1_cta1, a.cg_1_cta2, a.cg_1_cta3, a.cg_1_cta4, a.cg_1_cta5, a.cg_1_cta6, c.descripcion as cuenta FROM tbl_inv_parametro_inv a, tbl_inv_familia_articulo b, tbl_con_catalogo_gral c WHERE a.familia=b.cod_flia(+) and a.compania=b.compania(+) and a.cg_1_cta1=c.cta1 and a.cg_1_cta2=c.cta2 and a.cg_1_cta3=c.cta3 and a.cg_1_cta4=c.cta4 and a.cg_1_cta5=c.cta5 and a.cg_1_cta6=c.cta6 and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.almacen="+almaId;

	   al = SQLMgr.getDataList(sql);
	   lastLineNo = al.size();
	   
	   for (int i = 1; i <= al.size(); i++)
	   {		    
		  CommonDataObject cdo2 = (CommonDataObject) al.get(i-1);

		  if (i < 10) key = "00" + i;
		  else if (i < 100) key = "0" + i;
		  else key = "" + i;
		  cdo2.addColValue("key",key);

		  try
		  {
			 HashFlia.put(key,cdo2);
			 VKey.addElement(cdo2.getColValue("keyFlia"));			
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
document.title = 'Cuentas de Intercompañias por Familia de Almacén - '+document.title;

function addFamilia()
{
   abrir_ventana1('check_ctas_familia_inventario.jsp?almaId=<%=almaId%>&lastLineNo=<%=lastLineNo%>');
}

function addCuenta(index)
{
   abrir_ventana2('../contabilidad/ctabancaria_catalogo_list.jsp?id=16&index='+index+'&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
function closeWin()
{
   window.opener.location = 'ctas_familia_inventario_list.jsp';
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
	if (request.getParameter("type") != null)
	{
%>
	addFamilia();
<%
	}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - CTAS. ASOC. X FAMILIA DE ALMACÉN"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>		
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("almaId",almaId)%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("keySize",""+HashFlia.size())%>			
			
				<tr class="TextRow02">
				    <td colspan="3"><%=almaId%> - <%=cdo.getColValue("alma")%></td>
					<td colspan="2" align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"00000"))
						//{
					%>
					     <%=fb.submit("btnflia","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Flia")%>
					<%
					    //}
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="10%">Id Flia.</td>
					<td width="31%">Nombre</td>	
					<td width="49%">Cuentas Financiera </td>					
					<td width="5%">&nbsp;</td>
				</tr>			
				<%			  
				    String js = "";
					al = CmnMgr.reverseRecords(HashFlia);				
				    for (int i = 1; i <= HashFlia.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject cdo2 = (CommonDataObject) HashFlia.get(key);					 
				%>					  
					  <%=fb.hidden("remove"+i,"")%>		
					  <%=fb.hidden("fliaCode"+i,cdo2.getColValue("fliaCode"))%>
					  <%=fb.hidden("flia"+i,cdo2.getColValue("flia"))%>
					  <%=fb.hidden("keyFlia"+i,cdo2.getColValue("keyFlia"))%>					  
					  <%=fb.hidden("key"+i,al.get(i - 1).toString())%>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%>
					 <td align="right"><%=i%>&nbsp;</td>
					 <td><%=cdo2.getColValue("fliaCode")%></td>
				     <td><%=cdo2.getColValue("flia")%></td>					 
					 <td>
					 <%=fb.textBox("cg_1_cta1"+i,cdo2.getColValue("cg_1_cta1"),true,false,true,2)%>
					 <%=fb.textBox("cg_1_cta2"+i,cdo2.getColValue("cg_1_cta2"),true,false,true,2)%>
					 <%=fb.textBox("cg_1_cta3"+i,cdo2.getColValue("cg_1_cta3"),true,false,true,2)%>
					 <%=fb.textBox("cg_1_cta4"+i,cdo2.getColValue("cg_1_cta4"),true,false,true,2)%>
					 <%=fb.textBox("cg_1_cta5"+i,cdo2.getColValue("cg_1_cta5"),true,false,true,2)%>
					 <%=fb.textBox("cg_1_cta6"+i,cdo2.getColValue("cg_1_cta6"),true,false,true,2)%>
					 <%=fb.textBox("cuenta"+i,cdo2.getColValue("cuenta"),false,false,true,25)%>
					 <%=fb.button("btncta","...",true,false,null,null,"onClick=\"javascript:addCuenta("+i+")\"")%>
					 </td> 
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>		
				 </tr>															
				<%	
				     js += "if(document."+fb.getFormName()+".cg_1_cta1"+i+".value=='')error--;"; //Si error--, quita el error. Si error++, agrega el error. 
				     js += "if(document."+fb.getFormName()+".cg_1_cta2"+i+".value=='')error--;";
				     js += "if(document."+fb.getFormName()+".cg_1_cta3"+i+".value=='')error--;";
				     js += "if(document."+fb.getFormName()+".cg_1_cta4"+i+".value=='')error--;";
				     js += "if(document."+fb.getFormName()+".cg_1_cta5"+i+".value=='')error--;";
				     js += "if(document."+fb.getFormName()+".cg_1_cta6"+i+".value=='')error--;";
					}
					fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
				%>  	
            			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				<tr class="TextRow02">
					<td colspan="5" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
   lastLineNo = Integer.parseInt(request.getParameter("lastLineNo")); 
   int size = Integer.parseInt(request.getParameter("keySize"));	  
   almaId = request.getParameter("almaId");
   String baction = request.getParameter("baction");
   String itemRemoved = "";
		
   al.clear();		
   for (int i=1; i<=size; i++)
   {   	
	  CommonDataObject cdo3 = new CommonDataObject();
					 
	  cdo3.setTableName("tbl_inv_parametro_inv");
	  cdo3.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and almacen="+almaId);	 
	 
	  cdo3.addColValue("compania",(String) session.getAttribute("_companyId"));
	  cdo3.addColValue("almacen",almaId);
	  cdo3.addColValue("familia",request.getParameter("fliaCode"+i));	 
	  cdo3.addColValue("cg_1_cta1",request.getParameter("cg_1_cta1"+i));
	  cdo3.addColValue("cg_1_cta2",request.getParameter("cg_1_cta2"+i));
	  cdo3.addColValue("cg_1_cta3",request.getParameter("cg_1_cta3"+i));
	  cdo3.addColValue("cg_1_cta4",request.getParameter("cg_1_cta4"+i));
	  cdo3.addColValue("cg_1_cta5",request.getParameter("cg_1_cta5"+i));
	  cdo3.addColValue("cg_1_cta6",request.getParameter("cg_1_cta6"+i));
	  cdo3.addColValue("cuenta",request.getParameter("cuenta"+i));
	  cdo3.addColValue("key",request.getParameter("key"+i));
	  cdo3.addColValue("fliaCode",request.getParameter("fliaCode"+i));	 
	  cdo3.addColValue("flia",request.getParameter("flia"+i));	 
	  cdo3.addColValue("keyFlia",request.getParameter("keyFlia"+i));	 		  
      
	  if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
		 itemRemoved = cdo3.getColValue("key");  
	  else 
	  {
		 try
		 {
		 	HashFlia.put(cdo3.getColValue("key"),cdo3); 
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
	  VKey.remove(((CommonDataObject) HashFlia.get(itemRemoved)).getColValue("keyFlia"));
	  HashFlia.remove(itemRemoved);
	  

	  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?almaId="+almaId+"&lastLineNo="+lastLineNo+"&change=1");
	  return;
   }
   
   if (baction != null && baction.equals("+"))
   {      
	  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?type=1&almaId="+almaId+"&lastLineNo="+lastLineNo+"&change=1");
	  return;
   }
		
   if (al.size() == 0)
   {
	  CommonDataObject cdo4 = new CommonDataObject();

	  cdo4.setTableName("tbl_inv_parametro_inv");
	  cdo4.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and almacen="+almaId);

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/ctas_familia_inventario_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/ctas_familia_inventario_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/ctas_familia_inventario_list.jsp';
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
