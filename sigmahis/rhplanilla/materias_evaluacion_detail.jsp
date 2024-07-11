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
<jsp:useBean id="iMat" scope="session" class="java.util.Hashtable" />
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
int matLastLineNo = 0;

fb = new FormBean("formMaterias",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("matLastLineNo") != null && !request.getParameter("matLastLineNo").equals("")) matLastLineNo = Integer.parseInt(request.getParameter("matLastLineNo"));
else matLastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Materias a Mejorar - '+document.title;

function doSubmit()
{
   var acepto = "";
   acepto = parent.document.form1.aceptoEmpleado.value;
   
   alert("Acepto Empleado = "+acepto);
   document.formMaterias.calificacion.value = parent.document.form1.calificacion.value;
   document.formMaterias.aceptoEmpleado.value = parent.document.form1.aceptoEmpleado.value;
   document.formMaterias.comentarioEmpleado.value = parent.document.form1.comentarioEmpleado.value;
   document.formMaterias.observacionesEvaluador.value = parent.document.form1.observacionesEvaluador.value;
      
   if (formMateriasValidation())
   {
     document.formMaterias.submit();
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
			<%=fb.hidden("matLastLineNo",""+matLastLineNo)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("keySize",""+iMat.size())%>			
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
				    al = CmnMgr.reverseRecords(iMat);				
				    for (int i = 1; i <= iMat.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject cdo = (CommonDataObject) iMat.get(key);					  					  
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
	  matLastLineNo = Integer.parseInt(request.getParameter("matLastLineNo"));
	  evaluacion = request.getParameter("evaluacion");
	  prov = request.getParameter("prov");
	  sigla = request.getParameter("sigla");
	  tomo = request.getParameter("tomo");
	  asiento = request.getParameter("asiento");	  
	  
	  String ItemRemoved = "";
	    	   	  
	  for (int i=1; i<=keySize; i++)
	  {
	    CommonDataObject mat = new CommonDataObject();

        mat.setTableName("tbl_pla_materias_mejorar");  
		mat.setWhereClause("evaluacion="+evaluacion+" and provincia="+prov+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and compania="+(String) session.getAttribute("_companyId"));
		mat.addColValue("codigo",request.getParameter("codigo"+i));
		mat.addColValue("provincia",prov);
		mat.addColValue("sigla",sigla);
		mat.addColValue("tomo",tomo);
		mat.addColValue("asiento",asiento);
		mat.addColValue("compania",(String) session.getAttribute("_companyId"));
		mat.addColValue("evaluacion",evaluacion);
	    mat.setAutoIncCol("codigo");
		mat.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		mat.addColValue("descripcion",request.getParameter("descripcion"+i));
				 
	    key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iMat.put(key,mat);
		        list.add(mat);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     iMat.remove(ItemRemoved);
		 response.sendRedirect("../rhplanilla/materias_evaluacion_detail.jsp?mode="+mode+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&id="+evaluacion+"&matLastLineNo="+matLastLineNo);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		CommonDataObject cdo2 = new CommonDataObject();
				
		++matLastLineNo;
	    if (matLastLineNo < 10) key = "00" + matLastLineNo;
	    else if (matLastLineNo < 100) key = "0" + matLastLineNo;
	    else key = "" + matLastLineNo;
		
		cdo2.addColValue("codigo",""+matLastLineNo);
	
		try{ 
		     iMat.put(key,cdo2);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../rhplanilla/materias_evaluacion_detail.jsp?mode="+mode+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&id="+evaluacion+"&matLastLineNo="+matLastLineNo);
		return;
	  }
	  if (list.size() == 0)
	  {
	  	  CommonDataObject cdo3 = new CommonDataObject();

		  cdo3.setTableName("tbl_pla_materias_mejorar");
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
  parent.document.form1.errCode.value = '<%=SQLMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=SQLMgr.getErrMsg()%>';
  parent.document.form1.id.value = '<%=evaluacion%>';
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