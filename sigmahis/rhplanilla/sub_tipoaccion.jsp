<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.TipoAccion"%>
<%@ page import="issi.rhplanilla.SubTipoAccion"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTAccion" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TipoMgr" scope="page" class="issi.rhplanilla.TipoAccionesMgr" />
<%//<jsp:useBean id="TipoMgr" scope="page" class="issi.rhplanilla.TipoAccionMgr" /
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
TipoMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String id = "";
String key = "";
String sql = "";
int accionLastLineNo= 0;


if (request.getParameter("id") != null && !request.getParameter("id").equals("")) id = request.getParameter("id");
if (request.getParameter("accionLastLineNo") != null && !request.getParameter("accionLastLineNo").equals("")) accionLastLineNo= Integer.parseInt(request.getParameter("accionLastLineNo"));
else accionLastLineNo= 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'SubTipos de Transacciones - '+document.title;

function doSubmit()
{
   document.formSub.tipoDesc.value = parent.document.form0.descripcion.value;
	 if(parent.document.form0.descripcion.value !='')
	 {
			if(formSubValidation())
   		{ 
				 document.formSub.submit(); 
			} 
			
	  } else {alert('Descripcion requiere valor');}
	
	
	
	 
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
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formSub",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("accionLastLineNo",""+accionLastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("id", id)%>
			<%=fb.hidden("tipoDesc","")%>
			<%=fb.hidden("iTSize",""+iTAccion.size())%>			
			
			    
				<tr class="TextRow02">
					<td colspan="5" align="center">&nbsp;</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="15%">C&oacute;digo</td>
					<td width="75%">Descripci&oacute;n</td>							
					<td width="10%"><%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(iTAccion);				
				    for (int i = 1; i <= iTAccion.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  SubTipoAccion sub = (SubTipoAccion) iTAccion.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow01";					  					  
							String displaySubAccion = "";
							if (sub.getStatus() != null && sub.getStatus().equalsIgnoreCase("D"))
							{
								displaySubAccion = " style=\"display:none\"";
							}	
		%>	
				 <tr class="<%=color%>" align="center"<%=displaySubAccion%>>
					 <%=fb.hidden("key"+i,key)%>
					 <%=fb.hidden("remove"+i,"")%>
					 <%=fb.hidden("status"+i,sub.getStatus())%>
					 <td><%=fb.intBox("codigo"+i,sub.getCodigo(),false,false,true,10)%></td>
					 <td><%=fb.textBox("descripcion"+i,sub.getDescripcion(),true,false,false,82,100)%></td>        
					 <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				 </tr>
				<%	
					}
					fb.appendJsValidation("if(error>0)newHeight();");
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
	  int keySize=Integer.parseInt(request.getParameter("iTSize"));	   
	  mode = request.getParameter("mode");
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	  id = request.getParameter("id");
	  
		TipoAccion tip = new TipoAccion();
		tip.setDescripcion(request.getParameter("tipoDesc"));
		tip.setCodigo(id);   	  
	  for (int i=1; i<=keySize; i++)
	  {
	    SubTipoAccion sub = new SubTipoAccion();

	    sub.setCodigo(request.getParameter("codigo"+i));
		  sub.setDescripcion(request.getParameter("descripcion"+i));
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;	
			sub.setStatus("D");	 
		}else sub.setStatus(request.getParameter("status"+i));
	      
				try
				{ 
		        iTAccion.put(key,sub);
						tip.addTipoAccion(sub);   	  
		    }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	  }	//for
	
	  if (!ItemRemoved.equals(""))
	  {
		 response.sendRedirect("../rhplanilla/sub_tipoaccion.jsp?mode="+mode+"&accionLastLineNo="+accionLastLineNo+"&id="+id);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		SubTipoAccion sub = new SubTipoAccion();
				
		++accionLastLineNo;
	    if (accionLastLineNo< 10) key = "00" + accionLastLineNo;
	    else if (accionLastLineNo< 100) key = "0" + accionLastLineNo;
	    else key = "" + accionLastLineNo;
		
		sub.setCodigo("0");
		
		try{ 
		     iTAccion.put(key,sub);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../rhplanilla/sub_tipoaccion.jsp?mode="+mode+"&accionLastLineNo="+accionLastLineNo+"&id="+id);
		return;
	  }
		 
		 
		 if (mode.equalsIgnoreCase("add"))
		 {				
			TipoMgr.add(tip);
			id = TipoMgr.getPkColValue("codigo");
		 }
		 else
		 {	
		    id = request.getParameter("id");
			  TipoMgr.update(tip);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=TipoMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=TipoMgr.getErrMsg()%>';
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