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
<jsp:useBean id="tranHash" scope="session" class="java.util.Hashtable" />
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
String provincia = request.getParameter("prov");
String sigla = request.getParameter("sig");
String tomo = request.getParameter("tom");
String asiento = request.getParameter("asi");
String numEmpleado =request.getParameter("num");
String rata =request.getParameter("rath");
String empId =request.getParameter("empId");
String seccion = "";
String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
int tranLastLineNo = 0;
int count = 0;

 
if (request.getMethod().equalsIgnoreCase("GET"))
{  
   if (change == null)
   {	
/*     sql = "SELECT a.codigo, to_date(a.fecha,'dd/mm/yyyy') as fecha, a.fecha_inicial, a.fecha_final, a.estado_pago, nvl(a.tipotrx,' ') as tipotrx, b.descripcion as tipotrxDesc FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and provincia="+provincia+" and sigla="+sigla+" and tomo="+tomo+" and asiento="+asiento+" and ue_codigo="+area+" and num_empleado="+numEmpleado+" and a.tipotrx=b.codigo(+)";
	   al = SQLMgr.getDataList(sql); */
		
	   tranHash.clear(); 
	   tranLastLineNo ++;	   			
	   if (tranLastLineNo < 10) key = "00" + tranLastLineNo;
	   else if (tranLastLineNo < 100) key = "0" + tranLastLineNo;
	   else key = "" + tranLastLineNo;
	   
	   date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi");
	   
	   CommonDataObject tran = new CommonDataObject();
	   tran.addColValue("fecha",date.substring(0,10));
	   tran.addColValue("fechaInicial","");
	   tran.addColValue("fechaFinal","");
	   tran.addColValue("codigo",""+tranLastLineNo);
	   tran.addColValue("cantidad",""+0);
	   tran.addColValue("monto_unitario",""+rata);
	   tranHash.put(key,tran);	   
   }	   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Registro de Transacciones - '+document.title;

function doSubmit()
{           
	 document.formRegistro.save.disableOnSubmit = true;
	 if (parent.doRedirect('7','0') == true)
	 {	
	 	document.formRegistro.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
     
	 for (i=0; i<<%=iEmp.size()%>; i++)
     { 
	   
	    eval('document.formRegistro.provincia'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value; 
		eval('document.formRegistro.sigla'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value; 
		eval('document.formRegistro.tomo'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value; 
		eval('document.formRegistro.asiento'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value; 
		eval('document.formRegistro.numEmpleado'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
		eval('document.formRegistro.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
		if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
		   eval("document.formRegistro.check"+i).value = 'S'; 
		}
		else
		{
		   eval("document.formRegistro.check"+i).value = 'N';
		}   
	 }
	 document.formRegistro.baction.value = "Guardar";
	 parent.unCheckAll('2');     
//   if (formRegistroValidation())
//   { 
     document.formRegistro.submit(); 
//   }
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
function doAction()
{   
	newHeight();
	parent.setHeight('secciones',document.body.scrollHeight);
//	sumHoras(0,0,0);
}
function addMotivo(index)
{
    abrir_ventana1("../common/search_tipo_transaccion.jsp?fp=registro&index="+index);
}
function sumHoras()
{ 
  var i = 0;
  var fechaIni = "";
  var fechaFin = "";
  
  for (i=0;i<<%=tranHash.size()%>;i++)
  {
 
	  	  
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
	  
	  eval('document.formRegistro.cantidad'+i).value = hour;
	  eval('document.formRegistro.montoUnitario'+i).value = minu;       
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
     <%fb = new FormBean("formRegistro",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("tranLastLineNo",""+tranLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("keySize",""+tranHash.size())%>	
			
			<%
			   for (int i=0; i<iEmp.size(); i++)
			   {
			%>
			      <%=fb.hidden("provincia"+i,"")%>
				  <%=fb.hidden("sigla"+i,"")%>
				  <%=fb.hidden("tomo"+i,"")%>
				  <%=fb.hidden("asiento"+i,"")%>
				  <%=fb.hidden("numEmpleado"+i,"")%>
				  <%=fb.hidden("empId"+i,"")%>
				  <%=fb.hidden("check"+i,"")%>
			<%	  
			   }  
			%>				
			    
				<tr class="TextRow02">
				<td colspan="2"> REGISTRO DE TRANSACCIONES </td> 
					<td colspan="7" align="right">
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
					<td width="10%">Fecha</td>
          <td width="35%">Tipo de Transacción</td>
					<td width="10%">Fecha Inicial</td>							
					<td width="10%">Fecha Final</td>					
					<td width="8%">Cantidad</td>
					<td width="8%">Monto Unitario</td>
          <td width="8%">Monto </td>
					<td width="5%">Sec.</td>
					<td width="5%">&nbsp;</td>
				</tr>			
				<%	
				  String js = "";	
					String fecha = "";
					String fechaInicial = "";
					String fechaFinal = "";	  
				  al = CmnMgr.reverseRecords(tranHash);				
				  for (int i = 0; i < tranHash.size(); i++)
				    {
					  key = al.get(i).toString();	
					  CommonDataObject tran = (CommonDataObject) tranHash.get(key);	
					  fecha = "fecha"+i;
					  
			    %>		
				<tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	
					<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>	
						<jsp:param name="valueOfTBox1" value="<%=(tran.getColValue("fecha")==null)?"":tran.getColValue("fecha")%>" />
						</jsp:include>
					</td>
          <td><%=fb.intBox("tipotrx"+i,tran.getColValue("tipotrx"),false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("tipotrxDesc"+i,tran.getColValue("tipotrxDesc"),false,false,true,40,50,"Text10",null,null)%><%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
          
					<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fechaInicial" />
						<jsp:param name="valueOfTBox1" value="<%=fechaInicial%>" />
						</jsp:include>
					</td>
					<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fechaFinal" />
						<jsp:param name="valueOfTBox1" value="<%=fechaFinal%>" />
						</jsp:include>
					</td>
					<td><%=fb.textBox("cantidad"+i,tran.getColValue("cantidad"),false,false,false,5,5,"Text10",null,null)%></td>
          <td><%=fb.textBox("montoUnitario"+i,tran.getColValue("monto_unitario"),false,false,false,8,8,"Text10",null,null)%></td>        
					<td><%=fb.textBox("monto"+i,tran.getColValue("monto"),false,false,false,8,8,"Text10",null,null)%></td>     
          <td><%=fb.textBox("codigo"+i,tran.getColValue("codigo"),false,false,false,8,8,"Text10",null,null)%></td>    
					<td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>      
				</tr>				 
				<tr class="TextRow01" >
				    &nbsp;&nbsp;&nbsp;
			    </tr>
			    <tr class="TextRow01" >
				    <td colspan="4">
					    <table>						       
							   <tr>
							       <td><font size="2">Comentario</font></td>
								   <td><%=fb.textarea("comentario"+i,tran.getColValue("comentario"),false,false,false,33,4,"Text11",null,null)%></td>
							   </tr>
						</table>
					</td>		   	   
					<td colspan="5">
					    <table>
							   <tr>
							       <td width="37%"><font size="2">Acci&oacute;n</font></td>
								   <td width="63%"><%=fb.select("estadoPago"+i,"PA=PAGAR,DE=Descontar",tran.getColValue("estado_pago"),false,false,0,"Text10",null,null)%></td>							       
							   </tr>					       
							   <tr>
							       <td><font size="2">Año</font></td>
								    <td><%=fb.textBox("anioPago"+i,tran.getColValue("anio_pago"),false,false,false,5,5,"Text10",null,null)%>
                     Periodo<%=fb.textBox("quincenaPago"+i,tran.getColValue("quincena_pago"),false,false,false,5,5,"Text10",null,null)%></td>
							   </tr>
							   <tr>
							       <td><font size="2">Planilla</font></td>
                      <td><%=fb.select("codPlanilla"+i,"1=Planilla Quincenal,2=Planilla Décimo,3=Planilla de Vacaciones,5=Planilla de Bonificaciones,6=Planilla de Incentivos,7=Planilla de Ajuste,8=Planilla Liquidaciones,9=Participación en Utilidades",tran.getColValue("cod_planilla_pago"),false,false,0,"Text10",null,null)%></td>
								   
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
				<tr class="TextRow02">
					<td align="right" colspan="9"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0,1)\"")%>
					</td>
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
   int keySize=Integer.parseInt(request.getParameter("keySize"));	   
   tranLastLineNo = Integer.parseInt(request.getParameter("tranLastLineNo"));		  
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
	  for (int i=0; i<keySize; i++)
	  {
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
		cdo.addColValue("fecha_final",request.getParameter("fechaFinal"+i));
		cdo.addColValue("fecha_inicial",request.getParameter("fechaInicial"+i));
		cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
		cdo.addColValue("monto_unitario",request.getParameter("montoUnitario"+i));
		cdo.addColValue("tipotrx",request.getParameter("tipotrx"+i));
		cdo.addColValue("tipotrxDesc",request.getParameter("tipotrxDesc"+i));
		cdo.addColValue("monto",request.getParameter("monto"+i));	
		cdo.addColValue("codigo",request.getParameter("codigo"+i));	
		cdo.setAutoIncCol("codigo");
		cdo.addColValue("estado_pago",request.getParameter("estadoPago"+i)); 
		cdo.addColValue("anio_pago",request.getParameter("anioPago"+i));
		cdo.addColValue("lugar",request.getParameter("lugar"+i));
		cdo.addColValue("comentario",request.getParameter("comentario"+i));
		cdo.addColValue("forma_des","1");
				 
	    key = request.getParameter("key"+i);
	    if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{ 	  
	       ItemRemoved = key;		 
		}
		else
		{
		   try{ 
				tranHash.put(key,cdo);
			  }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
		}

	    if (!ItemRemoved.equals(""))
	    {
		   list.remove(tranHash.get(ItemRemoved));
		   tranHash.remove(ItemRemoved);	       
		   response.sendRedirect("../rhplanilla/empl_incapacidades_detail.jsp?change=1&tranLastLineNo="+tranLastLineNo+"&seccion="+seccion);
		   return;
	    }   
      }	
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
           date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	       CommonDataObject cdo2 = new CommonDataObject();
		 		 		
		   cdo2.addColValue("provincia","");
		   cdo2.addColValue("sigla","");
		   cdo2.addColValue("tomo",""); 
		   cdo2.addColValue("asiento","");
		   cdo2.addColValue("compania","");
		   cdo2.addColValue("num_empleado","");
		   cdo2.addColValue("emp_id","");
	       cdo2.addColValue("fecha",date.substring(0,10));
		   cdo2.addColValue("fecha_final",date.substring(11));
		   cdo2.addColValue("fecha_inicial",date.substring(11));
		   cdo2.addColValue("cantidad","0");
		   cdo2.addColValue("monto_unitario","0");
			 cdo2.addColValue("monto","0");
		   cdo2.addColValue("tipotrx","");
		   cdo2.addColValue("tipotrxDesc","");		 
		   cdo2.addColValue("estado_pago","");
		   cdo2.addColValue("anio_pago","");
		   cdo2.addColValue("lugar","");
		   cdo2.addColValue("comentario","");
		
		   tranLastLineNo++;	
		   cdo2.addColValue("codigo",""+tranLastLineNo);	
		   if (tranLastLineNo < 10) key = "00" + tranLastLineNo;
		   else if (tranLastLineNo < 100) key = "0" + tranLastLineNo;
		   else key = "" + tranLastLineNo;
		 
		   tranHash.put(key,cdo2);	

		   response.sendRedirect("../rhplanilla/empl_incapacidades_detail.jsp?change=1&tranLastLineNo="+tranLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo);
		   return;
	  }	  	  
	}
	else
	{ 
	   for (int j=0;j<iEmp.size();j++)
	   {  
	      if (request.getParameter("check"+j).equalsIgnoreCase("S"))
		  {
		     for (int i=0; i<keySize; i++)
			 {
				CommonDataObject cdo = new CommonDataObject();
				
				cdo.setTableName("tbl_pla_incapacidad"); 
				cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+grupo+" and emp_id="+request.getParameter("emp_id"+j) );
		 		cdo.addColValue("ue_codigo",grupo);
		 		cdo.addColValue("provincia",request.getParameter("provincia"+j));
		 		cdo.addColValue("sigla",request.getParameter("sigla"+j));
		 		cdo.addColValue("tomo",request.getParameter("tomo"+j)); 
		 		cdo.addColValue("asiento",request.getParameter("asiento"+j));
		 		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
            	cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));				
				cdo.addColValue("emp_id",request.getParameter("empId"+j));
				cdo.addColValue("fecha",request.getParameter("fecha"+i));
				cdo.addColValue("fecha_final",request.getParameter("fechaFinal"+i));
				cdo.addColValue("fecha_inicial",request.getParameter("fechaInicial"+i));
				cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
				cdo.addColValue("monto_unitario",request.getParameter("montoUnitario"+i));
				cdo.addColValue("monto",request.getParameter("monto"+i));
				cdo.addColValue("tipotrx",request.getParameter("tipotrx"+i));
				cdo.addColValue("tipotrxDesc",request.getParameter("tipotrxDesc"+i));
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.setAutoIncCol("codigo");			
				cdo.addColValue("estado_pago",request.getParameter("estadoPago"+i)); 
				cdo.addColValue("anio_pago",request.getParameter("anioPago"+i));
				cdo.addColValue("lugar",request.getParameter("lugar"+i));
				cdo.addColValue("comentario",request.getParameter("comentario"+i));
				cdo.addColValue("forma_des","1");
				cdo.addColValue("aprobado","N");
						 
				key = request.getParameter("key"+i); 
				tranHash.put(key,cdo);
				list.add(cdo);
		     }
	      }
	   }	   	
    } 			  				
	SQLMgr.insertList(list); 	   
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_incapacidades_detail.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_incapacidades_detail.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>