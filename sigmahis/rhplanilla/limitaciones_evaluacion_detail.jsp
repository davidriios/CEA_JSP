<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iLim" scope="session" class="java.util.Hashtable" />
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
String mode = request.getParameter("mode");
String key = "";
String sql = "";
String evaluacion = request.getParameter("id");
String prov = request.getParameter("prov");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
int limLastLineNo = 0;

fb = new FormBean("formLimitaciones",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("limLastLineNo") != null && !request.getParameter("limLastLineNo").equals("")) limLastLineNo = Integer.parseInt(request.getParameter("limLastLineNo"));
else limLastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Limitaciones Encontradas - '+document.title;

function doSubmit()
{
   document.formLimitaciones.calificacion.value = parent.document.form2.calificacion.value;
   document.formLimitaciones.aceptoEmpleado.value = parent.document.form2.aceptoEmpleado.value;
   document.formLimitaciones.comentarioEmpleado.value = parent.document.form2.comentarioEmpleado.value;
   document.formLimitaciones.observacionesEvaluador.value = parent.document.form2.observacionesEvaluador.value;
      
   if (formLimitacionesValidation())
   {
     document.formLimitaciones.submit();
   }   
}
function doAction()
{
	newHeight();
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
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("limLastLineNo",""+limLastLineNo)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("keySize",""+iLim.size())%>			
			<%=fb.hidden("prov",prov)%>
			<%=fb.hidden("sigla",sigla)%>
			<%=fb.hidden("tomo",tomo)%>
			<%=fb.hidden("asiento",asiento)%>
			<%=fb.hidden("evaluacion",evaluacion)%>
			<%=fb.hidden("aceptoEmpleado","")%>
			<%=fb.hidden("calificacion","")%>
			<%=fb.hidden("comentarioEmpleado","")%>
			<%=fb.hidden("observacionesEvaluador","")%>
			    
				<tr class="TextRow02">
					<td colspan="5" align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
						//{
					%>
					     <%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					<%
					   // }
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="20%">C&oacute;digo</td>
					<td width="70%">Descripci&oacute;n</td>								
					<td width="10%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(iLim);				
				    for (int i = 1; i <= iLim.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject cdo = (CommonDataObject) iLim.get(key);					  					  
			    %>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	
					 <td><%=fb.intBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,15)%></td>
					 <td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,false,false,85)%></td>        
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
	  limLastLineNo = Integer.parseInt(request.getParameter("limLastLineNo"));
	  evaluacion = request.getParameter("evaluacion");
	  prov = request.getParameter("prov");
	  sigla = request.getParameter("sigla");
	  tomo = request.getParameter("tomo");
	  asiento = request.getParameter("asiento");	  
	  
	  String ItemRemoved = "";
	    	   	  
	  for (int i=1; i<=keySize; i++)
	  {
	    CommonDataObject lim = new CommonDataObject();

        lim.setTableName("tbl_pla_limitacion");  
		lim.setWhereClause("evaluacion="+evaluacion+" and provincia="+prov+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and compania="+(String) session.getAttribute("_companyId"));
		lim.addColValue("codigo",request.getParameter("codigo"+i));
		lim.addColValue("provincia",prov);
		lim.addColValue("sigla",sigla);
		lim.addColValue("tomo",tomo);
		lim.addColValue("asiento",asiento);
		lim.addColValue("compania",(String) session.getAttribute("_companyId"));
		lim.addColValue("evaluacion",evaluacion);
	    lim.setAutoIncCol("codigo");
		lim.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		lim.addColValue("descripcion",request.getParameter("descripcion"+i));
				 
	    key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iLim.put(key,lim);
		        list.add(lim);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     iLim.remove(ItemRemoved);
		 response.sendRedirect("../rhplanilla/limitaciones_evaluacion_detail.jsp?mode="+mode+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&id="+evaluacion+"&limLastLineNo="+limLastLineNo);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		CommonDataObject cdo2 = new CommonDataObject();
				
		++limLastLineNo;
	    if (limLastLineNo < 10) key = "00" + limLastLineNo;
	    else if (limLastLineNo < 100) key = "0" + limLastLineNo;
	    else key = "" + limLastLineNo;
		
		cdo2.addColValue("codigo",""+limLastLineNo);

		try{ 
		     iLim.put(key,cdo2);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../rhplanilla/limitaciones_evaluacion_detail.jsp?mode="+mode+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&id="+evaluacion+"&limLastLineNo="+limLastLineNo);
		return;
	  }
	  if (list.size() == 0)
	  {
	  	  CommonDataObject cdo3 = new CommonDataObject();

		  cdo3.setTableName("tbl_pla_limitacion");
		  cdo3.setWhereClause("evaluacion="+evaluacion+" and provincia="+prov+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and compania="+(String) session.getAttribute("_companyId"));
		  list.add(cdo3); 
	  }
	  
	  CommonDataObject eval = new CommonDataObject();
	  
	  eval.setTableName("tbl_pla_evaluacion");	  
	  eval.addColValue("calificacion",request.getParameter("calificacion"));
	  eval.addColValue("comentario_empleado",request.getParameter("comentarioEmpleado"));
	  eval.addColValue("observaciones_evaluador",request.getParameter("observacionesEvaluador"));
      eval.addColValue("acepto_empleado",(request.getParameter("aceptoEmpleado") == null)?"N":"S");    
      eval.setWhereClause("provincia="+prov+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and compania="+(String) session.getAttribute("_companyId")+" and codigo="+evaluacion);
	  SQLMgr.update(eval);
       
	  SQLMgr.insertList(list);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form2.errCode.value = '<%=SQLMgr.getErrCode()%>';
  parent.document.form2.errMsg.value = '<%=SQLMgr.getErrMsg()%>';
  parent.document.form2.id.value = '<%=evaluacion%>';
  parent.document.form2.submit(); 
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>