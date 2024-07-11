<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="incHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
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
String change = request.getParameter("change");
String provincia = "";
String sigla = "";
String tomo = "";
String asiento = "";
String numEmpleado = "";
String seccion = "";
String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
int incLastLineNo = 0;
int count = 0;

/*if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")) provincia = request.getParameter("provincia");
if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) sigla = request.getParameter("sigla");
if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) tomo = request.getParameter("tomo");
if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) asiento = request.getParameter("asiento");
if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").equals("")) numEmpleado = request.getParameter("numEmpleado");*/
if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("incLastLineNo") != null && !request.getParameter("incLastLineNo").equals("")) incLastLineNo = Integer.parseInt(request.getParameter("incLastLineNo"));
 
if (request.getMethod().equalsIgnoreCase("GET"))
{  
   if (change == null)
   {	
/*     sql = "SELECT a.codigo, to_date(a.fecha,'dd/mm/yyyy') as fecha, a.hora_entrada, a.hora_salida, a.estado, nvl(a.mfalta,' ') as mfalta, b.descripcion as mfaltaDesc FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and provincia="+provincia+" and sigla="+sigla+" and tomo="+tomo+" and asiento="+asiento+" and ue_codigo="+area+" and num_empleado="+numEmpleado+" and a.mfalta=b.codigo(+)";
	   al = SQLMgr.getDataList(sql); */
		
	   incHash.clear(); 
	   incLastLineNo ++;	   			
	   if (incLastLineNo < 10) key = "00" + incLastLineNo;
	   else if (incLastLineNo < 100) key = "0" + incLastLineNo;
	   else key = "" + incLastLineNo;
	   
	   date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	   
	   CommonDataObject inc = new CommonDataObject();
	   inc.addColValue("fecha",date.substring(0,10));
	   inc.addColValue("hora_entrada",date.substring(11));
	   inc.addColValue("hora_salida",date.substring(11));
	   inc.addColValue("codigo",""+incLastLineNo);
	   inc.addColValue("tiempo_horas",""+0);
	   inc.addColValue("tiempo_minutos",""+0);
	   incHash.put(key,inc);	   
   }	   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Incapacidades Del Empleado - '+document.title;

function doSubmit()
{ 
     alert('doSubmit');
     for (i=1; i<=<%=iEmp.size()%>; i++)
     {  
	    eval('document.formIncapacidad.provincia'+i).value = eval('parent.form0.provincia'+i).value; 
		eval('document.formIncapacidad.sigla'+i).value = eval('parent.form0.sigla'+i).value; 
		eval('document.formIncapacidad.tomo'+i).value = eval('parent.form0.tomo'+i).value; 
		eval('document.formIncapacidad.asiento'+i).value = eval('parent.form0.asiento'+i).value; 
		eval('document.formIncapacidad.numEmpleado'+i).value = eval('parent.form0.numEmpleado'+i).value;
		if (eval('parent.form0.check'+i).checked)
		{
		   eval('document.formIncapacidad.check'+i).value = 'S'; 
		}
		else
		{
		   eval('document.formIncapacidad.check'+i).value = 'N';
		}   
	 }     
//   if (formIncapacidadValidation())
//   { 
     document.formIncapacidad.submit(); 
//   }       
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
function doAction()
{   
	newHeight();
	parent.doAction(); 
//	sumHoras(0,0,0);
}
function addMotivo(index)
{
    abrir_ventana1("../common/search_motivo_falta.jsp?fp=incapacidades_empleado&index="+index);
}
function sumHoras()
{ 
  alert('sumHoras');
  var i = 0;
  var fechaIni = "";
  var fechaFin = "";
  
  for (i=1;i<=<%=incHash.size()%>;i++)
  {
      alert(' i = '+i);
      fechaIni = "06/01/2008 "+eval('document.formIncapacidad.horaEntrada'+i).value;
	  fechaFin = "06/01/2008 "+eval('document.formIncapacidad.horaSalida'+i).value;
	  	  
	  var ini = new Date(fechaIni);
	  var fin = new Date(fechaFin);	  
	  var hour = 0;
	  var minu = 0;
	
	  sec = fin.getSeconds() - ini.getSeconds();
	  minu = fin.getMinutes();
	  if (sec < 0)
	  {
		minu = minu - 1;
		sec = sec + 60;
	  }
	  minu = minu - ini.getMinutes();
	  hour = fin.getHours();  
	  if (minu < 0)
	  {
		hour = hour - 1;
		minu = minu + 60;
	  }
	  hour = hour - ini.getHours();   
	  
	  eval('document.formIncapacidad.tiempoHoras'+i).value = hour;
	  eval('document.formIncapacidad.tiempoMinutos'+i).value = minu;       
  }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
            <%fb = new FormBean("formIncapacidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("incLastLineNo",""+incLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("area",area)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("keySize",""+incHash.size())%>	
			
			<%
			   System.out.println("**************************************************FORM - CREATING EMPLEADO OBJECT");
			   for (int i=1; i<=iEmp.size(); i++)
			   {
			%>
			      <%=fb.hidden("provincia"+i,"")%>
				  <%=fb.hidden("sigla"+i,"")%>
				  <%=fb.hidden("tomo"+i,"")%>
				  <%=fb.hidden("asiento"+i,"")%>
				  <%=fb.hidden("numEmpleado"+i,"")%>
				  <%=fb.hidden("check"+i,"")%>
			<%	  
			   }  
			%>		
			
			    
				<tr class="TextRow02">
					<td colspan="8" align="right">
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
					<td width="17%">Fecha</td>
					<td width="17%">Desde</td>							
					<td width="17%">Hasta</td>					
					<td width="5%">Hras.</td>
					<td width="5%">Min.</td>
					<td width="26%">Motivo de Incapacidad</td>
					<td width="8%">No.</td>
					<td width="5%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "";	
					String fecha = "";
					String horaEntrada = "";
					String horaSalida = "";	  
				    al = CmnMgr.reverseRecords(incHash);				
				    for (int i = 1; i <= incHash.size(); i++)
				    {
					  key = al.get(i - 1).toString();	
					  CommonDataObject inc = (CommonDataObject) incHash.get(key);	
					  fecha = "fecha"+i;
					  horaEntrada = "horaEntrada"+i;
					  horaSalida = "horaSalida"+i;	  
			    %>		
				<tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	
					<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>	
						<jsp:param name="jsEvent" value="sumHoras()"/>					
						<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("fecha")==null)?"":inc.getColValue("fecha")%>" />
						</jsp:include>
					</td>
					<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="<%=horaEntrada%>"/>
						<jsp:param name="format" value="hh24:mi:ss" />
						<jsp:param name="jsEvent" value="sumHoras()" />
						<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("hora_entrada")==null)?"":inc.getColValue("hora_entrada")%>" />
						</jsp:include>
					</td>
					<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="<%=horaSalida%>"/>
						<jsp:param name="format" value="hh24:mi:ss" />
						<jsp:param name="jsEvent" value="sumHoras()" />
						<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("hora_salida")==null)?"":inc.getColValue("hora_salida")%>" />
						</jsp:include>
					</td>
					<td><%=fb.intBox("tiempoHoras"+i,inc.getColValue("tiempo_horas"),false,false,true,5,2 ,"Text10",null,null)%></td>
					<td><%=fb.intBox("tiempoMinutos"+i,inc.getColValue("tiempo_minutos"),false,false,true,5,2,"Text10",null,null)%></td>        
					<td><%=fb.intBox("mfalta"+i,inc.getColValue("mfalta"),false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("mfaltaDesc"+i,inc.getColValue("mfaltaDesc"),false,false,true,20,3,"Text10",null,null)%><%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
                    <td><%=fb.intBox("codigo"+i,inc.getColValue("codigo"),false,false,true,10,1,"Text10",null,null)%></td> 
					<td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>      
				</tr>				 
				<tr class="TextRow01" >
				    &nbsp;&nbsp;&nbsp;
			    </tr>
			    <tr class="TextRow01" >
				    <td colspan="4">
					    <table>						       
							   <tr>
							       <td><font size="2">Observaci&oacute;n</font></td>
								   <td><%=fb.textarea("motivo"+i,inc.getColValue("motivo"),false,false,false,33,4,"Text11",null,null)%></td>
							   </tr>
						</table>
					</td>		   	   
					<td colspan="5">
					    <table>
							   <tr>
							       <td width="37%"><font size="2">Acci&oacute;n</font></td>
								   <td width="63%"><%=fb.select("estado"+i,"ND=No Descontar,DS=Descontar",inc.getColValue("estado"),false,false,0,"Text10",null,null)%></td>							       
							   </tr>					       
							   <tr>
							       <td><font size="2">Tipo de Lugar</font></td>
								   <td><%=fb.select("lugar"+i,"1=Clínica San Fernando,2=Caja de Seguro Social,3=Clínica Externa,4=Centro Médico,5=Otro",inc.getColValue("lugar"),false,false,0,"Text10",null,null)%></td>
							   </tr>
							   <tr>
							       <td><font size="2">Nombre Lugar</font></td>
								   <td><%=fb.textBox("lugarNombre"+i,inc.getColValue("lugar_nombre"),false,false,false,38,60,"Text10",null,null)%></td>
							   </tr>
						</table>
				    </td> 		
				</tr>	
				<%	 
				     //Si error--, quita el error. Si error++, agrega el error. 
				    // js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
					}                                    
					//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
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
   incLastLineNo = Integer.parseInt(request.getParameter("incLastLineNo"));		  
   String ItemRemoved = "";	  
//   provincia = request.getParameter("provincia");
//   sigla = request.getParameter("sigla");
//   tomo = request.getParameter("tomo");
//   asiento = request.getParameter("asiento");
//   numEmpleado = request.getParameter("numEmpleado");
   seccion = request.getParameter("seccion");
   area = request.getParameter("area");
   grupo = request.getParameter("grupo");
   if (!request.getParameter("baction").equalsIgnoreCase("Guardar"))
   {
      System.out.println("*******************************************************POST - WHEN baction != guardar");
	  System.out.println("*******************************************************POST - WHEN baction != guardar - BEFORE CYCLE - keySize = "+keySize);
	  for (int i=1; i<=keySize; i++)
	  {
	    System.out.println("*******************************************************POST - WHEN baction != guardar - INSIDE CYCLE");
	    CommonDataObject cdo = new CommonDataObject();
        
		cdo.setTableName("tbl_pla_incapacidad"); 
//		cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area);
//		cdo.addColValue("ue_codigo",area);
//		cdo.addColValue("provincia",provincia);
//		cdo.addColValue("sigla",sigla);
//		cdo.addColValue("tomo",tomo); 
//		cdo.addColValue("asiento",asiento);
//		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
//		cdo.addColValue("num_empleado",numEmpleado);
	    cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("hora_salida",request.getParameter("horaSalida"+i));
		cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"+i));
		cdo.addColValue("tiempo_horas",request.getParameter("tiempoHoras"+i));
		cdo.addColValue("tiempo_minutos",request.getParameter("tiempoMinutos"+i));
		cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
		cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
		cdo.addColValue("codigo",request.getParameter("codigo"+i));
		cdo.setAutoIncCol("codigo");
		cdo.addColValue("estado",request.getParameter("estado"+i)); 
		cdo.addColValue("lugar_nombre",request.getParameter("lugarNombre"+i));
		cdo.addColValue("lugar",request.getParameter("lugar"+i));
		cdo.addColValue("motivo",request.getParameter("motivo"+i));
		cdo.addColValue("forma_des","1");
				 
	    key = request.getParameter("key"+i);
	    if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{ 
		   System.out.println("**********************************************************POST - WHEN baction != guardar - INSIDE CYCLE - if remove != null");	  
	       ItemRemoved = key;		 
		}
		else
		{
		   try{ 
				incHash.put(key,cdo);
			  }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
		}
	

	    if (!ItemRemoved.equals(""))
	    {
		   System.out.println("*******************************************************POST - WHEN baction != guardar - INSIDE ItemRemoved");
		   list.remove(incHash.get(ItemRemoved));
		   incHash.remove(ItemRemoved);	       
		   response.sendRedirect("../rhplanilla/empl_incapacidades_detail.jsp?change=1&incLastLineNo="+incLastLineNo+"&area="+area+"&seccion="+seccion+"&area="+area+"&grupo="+grupo);
		   return;
	    }   
      }	
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		   System.out.println("*******************************************************POST - WHEN baction != guardar - INSIDE WHEN baction == +");
           date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	       CommonDataObject cdo2 = new CommonDataObject();
		 		 		
		   cdo2.addColValue("provincia","");
		   cdo2.addColValue("sigla","");
		   cdo2.addColValue("tomo",""); 
		   cdo2.addColValue("asiento","");
		   cdo2.addColValue("compania","");
		   cdo2.addColValue("num_empleado","");
	       cdo2.addColValue("fecha",date.substring(0,10));
		   cdo2.addColValue("hora_salida",date.substring(11));
		   cdo2.addColValue("hora_entrada",date.substring(11));
		   cdo2.addColValue("tiempo_horas","0");
		   cdo2.addColValue("tiempo_minutos","0");
		   cdo2.addColValue("mfalta","");
		   cdo2.addColValue("mfaltaDesc","");		 
		   cdo2.addColValue("estado","");
		   cdo2.addColValue("lugar_nombre","");
		   cdo2.addColValue("lugar","");
		   cdo2.addColValue("motivo","");
		
		   incLastLineNo++;	
		   cdo2.addColValue("codigo",""+incLastLineNo);	
		   if (incLastLineNo < 10) key = "00" + incLastLineNo;
		   else if (incLastLineNo < 100) key = "0" + incLastLineNo;
		   else key = "" + incLastLineNo;
		 
		   incHash.put(key,cdo2);	

		   response.sendRedirect("../rhplanilla/empl_incapacidades_detail.jsp?change=1&incLastLineNo="+incLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo);
		   return;
	  }	  	  
	}
	else
	{ 
	System.out.println("********************************************************POST - WHEN baction = Guardar");
	   for (int j=1;j<=iEmp.size();j++)
	   {  
	      System.out.println("********************************************************POST - WHEN baction = Guardar - INSIDE iEmp CYCLES");
	      if (request.getParameter("check"+j).equalsIgnoreCase("S"))
		  {
		  System.out.println("********************************************************POST - WHEN baction = Guardar - INSIDE iEmp CYCLES - IF request.getParameter(check).equalsIgnoreCase(S)");
		     for (int i=1; i<=keySize; i++)
			 {
			    System.out.println("********************************************************POST - WHEN baction = Guardar - INSIDE iEmp CYCLES - IF request.getParameter(check).equalsIgnoreCase(S) - INSIDE CYCLE");
				CommonDataObject cdo = new CommonDataObject();
				
				cdo.setTableName("tbl_pla_incapacidad"); 
				cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area+" and provincia="+request.getParameter("provincia"+j)+" and sigla='"+request.getParameter("sigla"+j)+"' and tomo="+request.getParameter("tomo"+j)+" and asiento="+request.getParameter("asiento"+j)+" and num_empleado="+request.getParameter("numEmpleado"+j));
		 		cdo.addColValue("ue_codigo",area);
		 		cdo.addColValue("provincia",request.getParameter("provincia"+j));
		 		cdo.addColValue("sigla",request.getParameter("sigla"+j));
		 		cdo.addColValue("tomo",request.getParameter("tomo"+j)); 
		 		cdo.addColValue("asiento",request.getParameter("asiento"+j));
		 		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
            	cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));
				cdo.addColValue("fecha",request.getParameter("fecha"+i));
				cdo.addColValue("hora_salida",request.getParameter("horaSalida"+i));
				cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"+i));
				cdo.addColValue("tiempo_horas",request.getParameter("tiempoHoras"+i));
				cdo.addColValue("tiempo_minutos",request.getParameter("tiempoMinutos"+i));
				cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
				cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.setAutoIncCol("codigo");
				cdo.addColValue("estado",request.getParameter("estado"+i)); 
				cdo.addColValue("lugar_nombre",request.getParameter("lugarNombre"+i));
				cdo.addColValue("lugar",request.getParameter("lugar"+i));
				cdo.addColValue("motivo",request.getParameter("motivo"+i));
				cdo.addColValue("forma_des","1");
				cdo.addColValue("aprobado","N");
						 
				key = request.getParameter("key"+i); 
				incHash.put(key,cdo);
				list.add(cdo);
		     }
	      }
	   }	   	
    } 			  				
	SQLMgr.insertList(list); 	   
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=SQLMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=SQLMgr.getErrMsg()%>';  
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