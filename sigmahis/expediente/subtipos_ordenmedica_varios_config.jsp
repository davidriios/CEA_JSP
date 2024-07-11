<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.TiposOrdenVarios"%>
<%@ page import="issi.expediente.SubtipoOrdenVarios"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TovMgr" scope="page" class="issi.expediente.TipoOrdenVariosMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
TovMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String id = request.getParameter("id");

String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("formSub",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
//System.out.println("id = "+id);
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'SubTipos de Dietas - '+document.title;

function doSubmit()
{
   document.formSub.tipoDesc.value = parent.document.form0.descripcion.value;
   document.formSub.tipoObserv.value = parent.document.form0.observacion.value;
  document.formSub.tipoEstatus.value = parent.document.form0.estatus.value;
	 //document.formSub.codDieta.value = parent.document.form0.id.value;
 
   if (formSubValidation())
   {
     document.formSub.submit(); 
   } 
}
function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("codDieta",id)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			<%=fb.hidden("tipoDesc", "")%>
			<%=fb.hidden("tipoObserv", "")%>
			<%=fb.hidden("tipoEstatus", "")%>
			    
				<tr class="TextRow02">
					<td colspan="5" align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
						//{
					%>
					     <%=fb.submit("addCol","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					<%
					   // }
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="35%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>							
					<td width="40%"><cellbytelabel id="3">Observaci&oacute;n</cellbytelabel></td>					
					<td width="10%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "",display="";		  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  SubtipoOrdenVarios std = (SubtipoOrdenVarios) HashDet.get(key);		
							if(std.getStatus().trim().equals("A"))
							//display = "style=display:inline";		  					  
			    %>		
					
				<tr class="TextRow01" <%=display%>>
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("remove"+i,"")%>	
				<%=fb.hidden("status"+i,std.getStatus())%>
					<td><%=fb.intBox("codigo"+i,std.getCodigo(),false,false,true,15)%></td>
					<td><%=fb.textBox("descripcion"+i,std.getDescripcion(),true,false,false,45,200)%></td>        
					<td><%=fb.textBox("observacion"+i,std.getObservacion(),false,false,false,55,2000)%>					
					<td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				</tr>
				<%	
				     //Si error--, quita el error. Si error++, agrega el error. 
				     js += "if(document."+fb.getFormName()+".descripcion"+i+".value=='')error--;";
					}
					fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
				%>  				 	
            <%=fb.formEnd(true)%>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
	  int keySize=Integer.parseInt(request.getParameter("keySize"));	   
	  mode = request.getParameter("mode");
	  id = request.getParameter("codDieta");
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	 
	    	   	  
	 for (int i=1; i<=keySize; i++)
	 {
	    SubtipoOrdenVarios std = new SubtipoOrdenVarios();

			std.setCodigo(request.getParameter("codigo"+i));
			std.setDescripcion(request.getParameter("descripcion"+i));
			std.setStatus(request.getParameter("status"+i));
    	if (request.getParameter("observacion"+i) != null) std.setObservacion(request.getParameter("observacion"+i));
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
			std.setStatus("D");//delete
		}
	  else
		{
			  try
				{ 
		        HashDet.put(key, std);
		        list.add(std);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	   }
	  }//for	
	
	  if (!ItemRemoved.equals(""))
	  {
	    HashDet.remove(ItemRemoved);
		 response.sendRedirect("../expediente/subtipos_ordenmedica_varios_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("Agregar"))
	  {	
		SubtipoOrdenVarios std = new SubtipoOrdenVarios();
				
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		
		std.setCodigo("0");
		std.setStatus("A");//active
		try{ 
		     HashDet.put(key, std);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../expediente/subtipos_ordenmedica_varios_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id);
		return;
	    }
		
		 TiposOrdenVarios td = new TiposOrdenVarios();
		 
		 td.setDescripcion(request.getParameter("tipoDesc"));
 		 td.setEstatus(request.getParameter("tipoEstatus"));
		 
		 if (request.getParameter("tipoObserv") != null) td.setObservacion(request.getParameter("tipoObserv"));				
		 td.setDetalle(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {		    					
			TovMgr.add(td);
			id = TovMgr.getPkColValue("codigo");
		 }
		 else
		 {		    
			td.setCodigo(request.getParameter("codDieta"));
			TovMgr.update(td);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=TovMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=TovMgr.getErrMsg()%>';
  parent.document.form0.id.value = '<%=id%>';
  parent.document.form0.submit(); 
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>