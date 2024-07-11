<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.DetalleTipoEscala"%>
<%@ page import="issi.expediente.TipoEscala"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TescMgr" scope="page" class="issi.expediente.TipoEscalaMgr" />
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
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");

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
document.title = 'Tipo Escala Glasgow - '+document.title;

function doSubmit()
{
	document.formDetalle.codigo.value = parent.document.form1.id.value; 
	document.formDetalle.descripcion.value = parent.document.form1.descripcion.value; 
	document.formDetalle.tipo.value = parent.document.form1.tipo.value; 
	document.formDetalle.estado.value = parent.document.form1.estado.value; 
	if(formDetalleValidation()){
		
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
		<td class="TableBorder" align="center">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction", "")%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("descripcion", "")%>
			<%=fb.hidden("tipo", "")%>
			<%=fb.hidden("estado", "")%>
				<tr class="TextRow02">
					<td colspan="5" align="right">
					<%=fb.submit("addCol","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="40"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>							
					<td width="25%"><cellbytelabel id="3">Escala</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="4">Estado</cellbytelabel></td>
				  <td width="10%">&nbsp;</td>
			    </tr>			
				<%
				  if (HashDet.size() > 0) 
				  {  
				    String js = "";		
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleTipoEscala co = (DetalleTipoEscala) HashDet.get(key);
			    %>
				<tr class="TextRow01" align="center">
					<%=fb.hidden("key"+i,key)%> 
					<%=fb.hidden("remove"+i,"")%>
					<td><%=fb.textBox("codigo"+i, co.getCodigo(),false,false,true,5)%></td>
					<td><%=fb.textBox("descripcion"+i, co.getDescripcion(),true,false,false,50,200)%></td>        
					<td><%=fb.decBox("escala"+i, co.getEscala(),true,false,false,20,4)%></td> 
					<td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",co.getEstado(),false,false,0,"")%> </td> 
				    <td><%=fb.submit("rem"+i,"X",false,(!co.getCodigo().trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
				</tr>
				<%	
				  }				  
					 fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");	
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
	    DetalleTipoEscala te = new DetalleTipoEscala();
	    
		// te.setTipoEscala(request.getParameter("secuencia"+i));
		   te.setCodigo(request.getParameter("codigo"+i));
		   te.setDescripcion(request.getParameter("descripcion"+i));
		   te.setEscala(request.getParameter("escala"+i));
		   if(request.getParameter("estado") != null && request.getParameter("estado").trim().equals("I"))
		   	te.setEstado(request.getParameter("estado"));	
		   else te.setEstado(request.getParameter("estado"+i));	
		
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
		 response.sendRedirect("../expediente/tipo_escala_glasgow_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		 return;
	  }
	  //====================================  Agregar al Arraylist ===============================================
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("Agregar"))
	  {	
		DetalleTipoEscala te = new DetalleTipoEscala();		
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		te.setCodigo("0");
		try{
		    HashDet.put(key, te);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../expediente/tipo_escala_glasgow_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		return;
	  }
//======================================= GUARDAR ========================================================
		TipoEscala dte = new TipoEscala();
		dte.setCodigo(request.getParameter("codigo"));
		dte.setDescripcion(request.getParameter("descripcion"));	// guarda sólo el campo descripcion	
		dte.setTipo(request.getParameter("tipo"));
		dte.setEstado(request.getParameter("estado"));
		
		dte.setMatrizTipoEscala(list); // guarda la matriz ya cargada
		
		if (mode.equalsIgnoreCase("add"))
		 {
		 //System.out.println("------------ INGRESO DEL ADD -------------");
		 TescMgr.add(dte);
		 id = TescMgr.getPkColValue("codigo");
		 } 
		 else if (mode.equalsIgnoreCase("edit"))
		 {
		   id = dte.getCodigo();
			 TescMgr.update(dte);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  <%if (TescMgr.getErrCode().equals("1")){%>
	  parent.document.form1.errCode.value = '<%=TescMgr.getErrCode()%>';
	  parent.document.form1.errMsg.value = '<%=TescMgr.getErrMsg()%>';
	  parent.document.form1.id.value = '<%=id%>';
	  parent.document.form1.submit(); 
  <%} else throw new Exception(TescMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>