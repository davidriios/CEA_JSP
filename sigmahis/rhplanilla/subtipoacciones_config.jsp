<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.TipoTransac"%>
<%@ page import="issi.rhplanilla.SubTipoTransac"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTrans" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TipoMgr" scope="page" class="issi.rhplanilla.TransacMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());

CmnMgr.setConnection(ConMgr);
TipoMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String id = "";
String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("formSub",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("id") != null && !request.getParameter("id").equals("")) id = request.getParameter("id");
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
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
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("id", id)%>
			<%=fb.hidden("tipoDesc", "")%>
			<%=fb.hidden("keySize",""+iTrans.size())%>			
			
			    
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
					<td width="15%">C&oacute;digo</td>
					<td width="60%">Descripci&oacute;n</td>							
					<td width="15%">Pago Base</td>					
					<td width="10%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(iTrans);				
				    for (int i = 1; i <= iTrans.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  SubTipoTransac sub = (SubTipoTransac) iTrans.get(key);					  					  
			    %>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%><%=fb.hidden("fechaCreacion"+i,sub.getFechaCreacion())%><%=fb.hidden("usuarioCreacion"+i,sub.getUsuarioCreacion())%>	
					 <td><%=fb.intBox("subTipo"+i,sub.getSubTipo(),false,false,true,17)%></td>
					 <td><%=fb.textBox("descripcion"+i,sub.getDescripcion(),false,false,false,82,30)%></td>        
					 <td><%=fb.decBox("monto"+i,sub.getMonto(),false,false,false,17,8.2)%>					
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				 </tr>
				<%	
					}
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
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	  id = request.getParameter("id");
	    	   	  
	  for (int i=1; i<=keySize; i++)
	  {
	    SubTipoTransac sub = new SubTipoTransac();

        sub.setCompania((String) session.getAttribute("_companyId"));
	    sub.setSubTipo(request.getParameter("subTipo"+i));
		sub.setDescripcion(request.getParameter("descripcion"+i));
		sub.setMonto(request.getParameter("monto"+i));
		sub.setFechaCreacion(request.getParameter("fechaCreacion"+i));
        sub.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
		sub.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		sub.setUsuarioModificacion((String) session.getAttribute("_userName"));
				 
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iTrans.put(key,sub);
		        list.add(sub);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     iTrans.remove(ItemRemoved);
		 response.sendRedirect("../rhplanilla/subtipo_transacciones_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("Agregar"))
	  {	
		SubTipoTransac sub = new SubTipoTransac();
				
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		sub.setSubTipo(""+lastLineNo);
		sub.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		sub.setUsuarioCreacion((String) session.getAttribute("_userName"));
		
		try{ 
		     iTrans.put(key,sub);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../rhplanilla/subtipo_transacciones_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id);
		return;
	  }
		 TipoTransac tip = new TipoTransac();
		 tip.setDescripcion(request.getParameter("tipoDesc"));
		 tip.setCompania((String) session.getAttribute("_companyId"));				
		 tip.setSubTipo(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {				
		    tip.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		    tip.setUsuarioCreacion((String) session.getAttribute("_userName"));
			TipoMgr.add(tip);
			id = TipoMgr.getPkColValue("codigo");
		 }
		 else
		 {	
		    tip.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  		    tip.setUsuarioModificacion((String) session.getAttribute("_userName"));
		    id = request.getParameter("id");
		    tip.setCodigo(id);	    
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