<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
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
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
int lastLineNo = 0;

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
document.title = 'Detalle Depósitos x Caja - '+document.title;

function doSubmit()
{
   document.formDetalle.submit(); 
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
            <%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%> 
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			    
				<tr class="TextRow02">
					<td colspan="11" align="right">
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
					<td width="8%"><cellbytelabel>Turno</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Consec.</cellbytelabel>#</td>							
					<td width="10%"><cellbytelabel>Banco</cellbytelabel></td>					
					<td width="10%"><cellbytelabel>Cuenta</cellbytelabel></td>
					<td width="10%"><cellbytelabel>F. Dep&oacute;sito</cellbytelabel></td>
					<td width="10%"># <cellbytelabel>Voucher/Tem.</cellbytelabel></td>
					<td width="8%">&nbsp;</td>
					<td width="8%"><cellbytelabel>Venta Bruta Tarjeta</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Devoluc. Tarjeta</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Comisi&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Gran Total Dep&oacute;sitado</cellbytelabel></td>
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject cdo2 = (CommonDataObject) HashDet.get(key);					  					  
			    %>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	
					 <td><%=fb.textBox("turno"+i,"",false,false,true,5)%></td>
					 <td><%=fb.textBox("consec"+i,"",false,false,false,5)%></td>        
					 <td><%=fb.textBox("banco"+i,"",false,false,false,10)%></td>
					 <td><%=fb.textBox("cuenta"+i,"",false,false,false,10)%></td>
					 <td><%=fb.textBox("fechaDeposito"+i,"",false,false,false,10)%></td>
					 <td><%=fb.textBox("noVoucher"+i,"",false,false,false,5)%></td>					
					 <td><%=fb.textBox("textBox"+i,"",false,false,false,5)%></td>	
					 <td><%=fb.intBox("ventaTarjeta"+i,"",false,false,false,5)%></td>
					 <td><%=fb.intBox("devolucionTarjeta"+i,"",false,false,false,5)%></td>					
					 <td><%=fb.intBox("comision"+i,"",false,false,false,5)%></td>	
					 <td><%=fb.intBox("total"+i,"",false,false,false,10)%></td>				
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				 </tr>
				<%	
				     //Si error--, quita el error. Si error++, agrega el error. 
				    //js += "if(document."+fb.getFormName()+".descripcion"+i+".value=='')error--;";
				    //js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
					}
					//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
				%>  
				<tr class="TextRow02">
				    <td align="right" colspan="7">Totales&nbsp;&nbsp;</td>
					<td><%=fb.intBox("totalVenta","",false,false,false,5)%></td>
					<td><%=fb.intBox("totalDevolucion","",false,false,false,5)%></td>
					<td><%=fb.intBox("totalComision","",false,false,false,5)%></td>
					<td><%=fb.intBox("totalDeposito","",false,false,false,10)%></td>
				 </tr>	  	 	
				<tr class="TextRow01">
				    <td align="right" colspan="11"><%=fb.button("btnFormPago","Forma de Pago",false,false,null,null,"onClick=\"javascript:pago()\"")%><%=fb.button("btnVerDistr","Ver Distribución",false,false,null,null,"onClick=\"javascript:ver()\"")%><%=fb.button("btnAjuste","Ajuste a Rec.",false,false,null,null,"onClick=\"javascript:ajuste()\"")%></td>
				</tr>				 	
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
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.formRecibo.submit(); 
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>