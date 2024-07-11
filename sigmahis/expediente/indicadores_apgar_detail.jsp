<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.expediente.DetalleIndicadorApgar"%>
<%@ page import="issi.expediente.IndicadorApgar"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TescMgr" scope="page" class="issi.expediente.IndicadorApgarMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
TescMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();

String mode = request.getParameter("mode");
String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);

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
document.title = 'Indicadores Apgar - '+document.title;

function doSubmit()
{
	if(formDetalleValidation()){
	   document.formDetalle.codigo.value = parent.document.form1.id.value; 
	   document.formDetalle.descripcion.value = parent.document.form1.descripcion.value; 
	   document.formDetalle.submit(); 
   } else {
   		parent.form1BlockButtons(false)
   }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td  align="center">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("baction", "")%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("descripcion", "")%>
			    
				<tr class="TextRow02">
					<td colspan="4" align="right">
					<%
					/*
						if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
						{
					*/
					%>
					     <%=fb.submit("addCol","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					<% /*   }	*/
					%>					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>							
					<td width="25%"><cellbytelabel id="3">Valor</cellbytelabel></td>
				    <td width="25%">&nbsp;</td>
			    </tr>			
				<%
				
				  if (HashDet.size() > 0) 
				  {  
				    
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleIndicadorApgar co = (DetalleIndicadorApgar) HashDet.get(key);
					  					  
			    %>
				<tr class="TextRow01" align="center">
					<%=fb.hidden("key"+i,key)%>
					<%=fb.hidden("remove"+i,"")%>
					<td><%=fb.textBox("codigo"+i, co.getCodigo(),false,false,false,5)%></td>
					<td><%=fb.textBox("descripcion"+i, co.getDescripcion(),true,false,false,50)%></td>        
					<td><%=fb.decBox("valor"+i, co.getValor(),true,false,false,20,4)%></td>  
					<td align="center"><%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
				</tr>
				<%	
				
				  }				  
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
  	  String id = "";
	  
	  for (int i=1; i<=keySize; i++)
	  { // start for
	    DetalleIndicadorApgar te = new DetalleIndicadorApgar();
	    
	
		   te.setCodigo(request.getParameter("codigo"+i));
		   te.setDescripcion(request.getParameter("descripcion"+i));
		   te.setValor(request.getParameter("valor"+i));		
		
		key = request.getParameter("key"+i);


//==================================== ASIGNAR KEY REMOVER ============================================================		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 
		  ItemRemoved = key;
		}
		else
		{
	      try{ 
		       HashDet.put(key, te);
		       list.add(te);
		     }catch(Exception e){ System.err.println(e.getMessage()); }		    	       
	    }
		
		
		
		/// end for
	  }
	  
	  
	  
	  // ==================== Eliminar o remover un Item del Hashtable ======================
	  if (!ItemRemoved.equals(""))
	  {
	     HashDet.remove(ItemRemoved);
		 response.sendRedirect("../expediente/indicadores_apgar_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		 return;
	  }
	  
	  
	  //====================================  Agregar al Arraylist ===============================================
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("Agregar"))
	  {	
		DetalleIndicadorApgar te = new DetalleIndicadorApgar();		
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		te.setCodigo(""+lastLineNo);
		
		
		try{
		    HashDet.put(key, te);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../expediente/indicadores_apgar_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		return;
	  }
	  
//======================================= GUARDAR ========================================================

		
		IndicadorApgar dte = new IndicadorApgar();
		dte.setCodigo(request.getParameter("codigo"));		
		dte.setDescripcion(request.getParameter("descripcion"));	// guarda sólo el campo descripcion	
		dte.setMatrizIndicadorApgar(list); // guarda la matriz ya cargada
		
		if (mode.equalsIgnoreCase("add"))
		 {
		 TescMgr.add(dte);
		 id = TescMgr.getPkColValue("codigo");
		 
		 } else if (mode.equalsIgnoreCase("edit")){
		  id = request.getParameter("codigo");
		 	TescMgr.update(dte);
		 }
		

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{

  parent.document.form1.errCode.value = '<%=TescMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=TescMgr.getErrMsg()%>';
  parent.document.form1.id.value = '<%=id%>';
  parent.document.form1.submit();  
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>