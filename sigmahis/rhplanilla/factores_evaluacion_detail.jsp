<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.EvalEmpleado"%>
<%@ page import="issi.rhplanilla.FactoresEval"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iFact" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFact" scope="session" class="java.util.Vector" />
<jsp:useBean id="EvalMgr" scope="page" class="issi.rhplanilla.EvaluacionMgr"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
EvalMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String id = "";
String prov = "";
String sigla = "";
String tomo = "";
String asiento = "";
String emp_id = "";
String key = "";
String sql = "";
int factLastLineNo = 0;

if (request.getParameter("emp_id") != null && !request.getParameter("emp_id").equals("")) emp_id = request.getParameter("emp_id");
if (request.getParameter("id") != null && !request.getParameter("id").equals("")) id = request.getParameter("id");
if (request.getParameter("prov") != null && !request.getParameter("prov").equals("")) prov = request.getParameter("prov");
if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) sigla = request.getParameter("sigla");
if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) tomo = request.getParameter("tomo");
if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) asiento = request.getParameter("asiento");
if (request.getParameter("factLastLineNo") != null && !request.getParameter("factLastLineNo").equals("")) factLastLineNo = Integer.parseInt(request.getParameter("factLastLineNo"));
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Factores de Evaluación - '+document.title;

function doSubmit()
{   
   
   document.formFactor.prov.value = parent.document.form0.provincia.value;
   document.formFactor.sigla.value = parent.document.form0.sigla.value;
   document.formFactor.tomo.value = parent.document.form0.tomo.value;
   document.formFactor.asiento.value = parent.document.form0.asiento.value;
	 document.formFactor.emp_id.value = parent.document.form0.emp_id.value;
   document.formFactor.provinciaEval.value = parent.document.form0.provinciaEval.value;
   document.formFactor.siglaEval.value = parent.document.form0.siglaEval.value;
   document.formFactor.tomoEval.value = parent.document.form0.tomoEval.value;
   document.formFactor.asientoEval.value = parent.document.form0.asientoEval.value;
   document.formFactor.fechaEvaluacion.value = parent.document.form0.fechaEvaluacion.value;
   document.formFactor.periodoEvdesde.value = parent.document.form0.periodoEvdesde.value;
   document.formFactor.periodoEvhasta.value = parent.document.form0.periodoEvhasta.value;
   document.formFactor.tipoEvaluacion.value = parent.document.form0.tipoEvaluacion.value; 
   document.formFactor.puntajeTotal.value = parent.document.form0.puntajeTotal.value;
   document.formFactor.responsabilidades.value = parent.document.form0.responsabilidades.value;
   document.formFactor.unidadAdm.value = parent.document.form0.unidadAdm.value;
   
   if (formFactorValidation())
   {
     document.formFactor.submit(); 
   } 
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
function sumPuntaje(fName)
{
   var count = 0; 
   var valor = 0;
   var valorMin = 0;
   var valorMax = 0;   
   
   <%
      for (int i = 1; i <= iFact.size(); i++)
	  {         
   %>
         valorMin = parseInt((eval('document.'+fName+'.valorMin'+<%=i%>).value),10);
		 		 valorMax = parseInt((eval('document.'+fName+'.valorMax'+<%=i%>).value),10);
         valor = parseInt((eval('document.'+fName+'.valor'+<%=i%>).value),10);
         if (valor==0 || (valor>=valorMin && valor<=valorMax))
         count = count + valor; 
         else
		 {
		   alert('Valor Fuera del Rango !');
		   return;
		 }  
   <%
      }
   %>   
   parent.document.form0.puntajeTotal.value = count;
   	  	
}
function doAction()
{
	//newHeight();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
function showFactoresList()
{
	abrir_ventana2('../common/check_factores.jsp?mode=<%=mode%>&fp=factoresEval&factLastLineNo=<%=factLastLineNo%>&id=<%=id%>&prov=<%=prov%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&emp_id=<%=emp_id%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formFactor",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("prov",prov)%>
			<%=fb.hidden("sigla",sigla)%>
			<%=fb.hidden("tomo",tomo)%>
			<%=fb.hidden("asiento",asiento)%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("provinciaEval","")%>
			<%=fb.hidden("siglaEval","")%>
			<%=fb.hidden("tomoEval","")%>
			<%=fb.hidden("asientoEval","")%>
			<%=fb.hidden("fechaEvaluacion","")%>
			<%=fb.hidden("periodoEvdesde","")%>
			<%=fb.hidden("periodoEvhasta","")%>
			<%=fb.hidden("tipoEvaluacion","")%>
			<%=fb.hidden("puntajeTotal","")%>
			<%=fb.hidden("responsabilidades","")%>
			<%=fb.hidden("calificacion","")%>
			<%=fb.hidden("aceptoEmpleado","")%>
			<%=fb.hidden("unidadAdm","")%>
			<%=fb.hidden("keySize",""+iFact.size())%>			
			
			    
				<!--<tr class="TextRow02">
					<td colspan="5" align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
						//{
					%>
					     <%//=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					<%
					   // }
					%>
					</td>
				</tr>-->	
			    <tr class="TextHeader" align="center">
					<td width="15%">C&oacute;digo</td>
					<td width="60%">Descripci&oacute;n</td>							
					<td width="25%">Calificaci&oacute;n</td>					
					
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(iFact);				
				    for (int i = 1; i <= iFact.size(); i++)
				    {
					  key = al.get(i - 1).toString();	
					  
					  FactoresEval fa = (FactoresEval) iFact.get(key);
					  								  
					  if (fa.getValor() == null || fa.getValor().equalsIgnoreCase("")) fa.setValor(fa.getValorMin());  					  
			    %>		
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("valorMin"+i,fa.getValorMin())%>
				<%=fb.hidden("valorMax"+i,fa.getValorMax())%>	
				<tr class="TextRow01"><%=fb.hidden("key"+i,key)%>
				
					<td><%=fb.intBox("factor"+i,fa.getFactor(),false,false,true,17)%></td>
					<td><%=fb.textBox("descripcion"+i,fa.getDescripcion(),false,false,true,82,30)%></td>        
					<td align="center"><%=fb.decBox("valor"+i,fa.getValor(),true,false,false,10,5.2,null,null,"onBlur=\"javascript:sumPuntaje('"+fb.getFormName()+"')\"")%>&nbsp;(<%=fa.getValorMin()%> - <%=fa.getValorMax()%>)
					</td>					
					
				</tr>
				<%	 
				     //Si error--, quita el error. Si error++, agrega el error. 
				    // js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
					}
				//	fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
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
	  factLastLineNo = Integer.parseInt(request.getParameter("factLastLineNo"));	
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	  id = request.getParameter("id");
	  prov = request.getParameter("prov");
	  sigla = request.getParameter("sigla");
	  tomo = request.getParameter("tomo");
	  asiento = request.getParameter("asiento");
 	  emp_id = request.getParameter("emp_id");
		
	  for (int i=1; i<=keySize; i++)
	  {
	    FactoresEval fa = new FactoresEval();

	    fa.setFactor(request.getParameter("factor"+i));
			fa.setDescripcion(request.getParameter("descripcion"+i));
			fa.setValor(request.getParameter("valor"+i));
			fa.setValorMin(request.getParameter("valorMin"+i));
			fa.setValorMax(request.getParameter("valorMax"+i));
				 
	    key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iFact.put(key,fa);
		        list.add(fa);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	//for

	  if (!ItemRemoved.equals(""))
	  {
			 vFact.remove(((FactoresEval) iFact.get(ItemRemoved)).getFactor());
			 iFact.remove(ItemRemoved);
			 response.sendRedirect("../rhplanilla/factores_evaluacion_detail.jsp?mode="+mode+"&factLastLineNo="+factLastLineNo+"&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento);
			 return;
	  }

	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		 response.sendRedirect("../rhplanilla/factores_evaluacion_detail.jsp?mode="+mode+"&factLastLineNo="+factLastLineNo+"&type=1&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento);
		 return;
	  }
		 EvalEmpleado eval = new EvalEmpleado();
		
		 eval.setCodigo(id);
		 eval.setCompania((String) session.getAttribute("_companyId"));
		 eval.setProvincia(request.getParameter("prov"));
		 eval.setSigla(request.getParameter("sigla"));
		 eval.setTomo(request.getParameter("tomo"));
		 eval.setAsiento(request.getParameter("asiento"));
		 eval.setEmpId(request.getParameter("emp_id"));
		 eval.setProvinciaEval(request.getParameter("provinciaEval"));
		 eval.setSiglaEval(request.getParameter("siglaEval"));
		 eval.setTomoEval(request.getParameter("tomoEval"));
		 eval.setAsientoEval(request.getParameter("asientoEval"));
		 eval.setFechaEvaluacion(request.getParameter("fechaEvaluacion"));
		 eval.setPeriodoEvdesde(request.getParameter("periodoEvdesde"));
		 eval.setPeriodoEvhasta(request.getParameter("periodoEvhasta"));
		 eval.setTipoEvaluacion(request.getParameter("tipoEvaluacion"));		 
		 eval.setResponsabilidades(request.getParameter("responsabilidades"));
		 eval.setAceptoEmpleado("N");	
		 eval.setPuntajeTotal(request.getParameter("puntajeTotal"));
		 eval.setUnidadAdm(request.getParameter("unidadAdm"));	 
		 				
		 eval.setFactores(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {	 
			EvalMgr.add(eval);
			id = EvalMgr.getPkColValue("codigo");
		 }
		 else if (mode.equalsIgnoreCase("edit"))
		 {	  
		    eval.setCodigo(id);	    
			EvalMgr.update(eval);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=EvalMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=EvalMgr.getErrMsg()%>';
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