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
<jsp:useBean id="sobHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
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
int sobLastLineNo = 0;
int count = 0;

/*if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")) provincia = request.getParameter("provincia");
if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) sigla = request.getParameter("sigla");
if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) tomo = request.getParameter("tomo");
if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) asiento = request.getParameter("asiento");
if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").equals("")) numEmpleado = request.getParameter("numEmpleado");*/
if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("sobLastLineNo") != null && !request.getParameter("sobLastLineNo").equals("")) sobLastLineNo = Integer.parseInt(request.getParameter("sobLastLineNo"));
 
if (request.getMethod().equalsIgnoreCase("GET"))
{  
   if (change == null)
   {	
/*     sql = "SELECT a.codigo, to_date(a.fecha,'dd/mm/yyyy') as fecha, a.hora_entrada, a.hora_salida, a.estado, nvl(a.mfalta,' ') as mfalta, b.descripcion as mfaltaDesc FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and provincia="+provincia+" and sigla="+sigla+" and tomo="+tomo+" and asiento="+asiento+" and ue_codigo="+area+" and num_empleado="+numEmpleado+" and a.mfalta=b.codigo(+)";
	   al = SQLMgr.getDataList(sql); */
	   
 sql = "SELECT periodo, to_char(sysdate,'yyyy') anio FROM tbl_pla_calendario WHERE tipopla = 1 and trans_desde <= to_date(to_char(sysdate,'dd-mm-yyyy'),'dd-mm-yyyy') and trans_hasta >= to_date(to_char(sysdate,'dd-mm-yyyy'),'dd-mm-yyyy')";



       cdo = SQLMgr.getData(sql);  
		
	   sobHash.clear(); 
	   sobLastLineNo ++;	   			
	   if (sobLastLineNo < 10) key = "00" + sobLastLineNo;
	   else if (sobLastLineNo < 100) key = "0" + sobLastLineNo;
	   else key = "" + sobLastLineNo;
	   
	    date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi");
	   
	   CommonDataObject sob = new CommonDataObject();
	   sob.addColValue("fecha","");
	   sob.addColValue("hora_entrada",date.substring(11));
	   sob.addColValue("hora_salida",date.substring(11));
	   sob.addColValue("codigo",""+sobLastLineNo);
	   sob.addColValue("tiempo_horas",""+0);
	   sob.addColValue("tiempo_minutos",""+0);
	   sobHash.put(key,sob);	   
   }	   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Sobretiempo del Empleado - '+document.title;

function doSubmit()
{           
	 document.formSobretiempo.save.disableOnSubmit = true;
	 if (parent.doRedirect('9','0') == true)
	 {	
	 	document.formSobretiempo.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
     
	 for (i=0; i<<%=iEmp.size()%>; i++)
     { 
	   
   eval('document.formSobretiempo.provincia'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value;   eval('document.formSobretiempo.sigla'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value; 
   eval('document.formSobretiempo.tomo'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value; 
   eval('document.formSobretiempo.asiento'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value; 				    
   eval('document.formSobretiempo.numEmpleado'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
   eval('document.formSobretiempo.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
	if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
		   eval("document.formSobretiempo.check"+i).value = 'S'; 
		}
		else
		{
		   eval("document.formSobretiempo.check"+i).value = 'N';
		}   
	 }
	 document.formSobretiempo.baction.value = "Guardar";
	 parent.unCheckAll('2');     
//   if (formIncapacidadValidation())
//   { 
     document.formSobretiempo.submit(); 
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
function addTipo(index)
{
    abrir_ventana1("../common/search_tipoplanilla.jsp?fp=planilla&index="+index);
}
function addMotivo(index)
 { 
var  empId = '';
var  count = 0;
var  rata  = '';
var  cant  = '';
var  factor  = '';
var  multip  = '';

 
  if(eval("document.formSobretiempo.tAsignado"+index).value <= 0)
     {
     alert('seleccione una Cantidad para calcular las Extras');
     return;
	 }

	for (i=0; i<<%=iEmp.size()%>; i++)
    { 
  		if(eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
			count++;
			empId  = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
			rata = eval("parent.frames['iEmpleado'].document.formEmpleado.rata"+i).value;
		}
	}
	
	if(count >1 || count== 0  )
	{
	alert('seleccione un Empleado');
     return;
	 }
	 cant 	 = eval("document.formSobretiempo.tPosterior"+index).value;
	 eval("document.formSobretiempo.rata"+index).value = rata; 
   abrir_ventana1("../common/search_tipohoraExtra.jsp?fp=planilla&index="+index+"&cant="+cant+"&rata="+rata);
}

function funcFecha(i)
{
    var periodo; 
    
	periodo = parseInt(getDBData('<%=request.getContextPath()%>',"periodo as periodo","tbl_pla_calendario","tipopla = 1 and to_date(to_char(sysdate,'dd-mm-yyyy'),'dd-mm-yyyy') >= trans_desde and to_date(to_char(sysdate,'dd-mm-yyyy'),'dd-mm-yyyy') <= trans_hasta",''),10);
	
	eval("document.formSobretiempo.periodo"+i).value = periodo;
	
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
            <%fb = new FormBean("formSobretiempo",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("sobLastLineNo",""+sobLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("keySize",""+sobHash.size())%>	
			
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
				<td colspan="2" > SOBRETIEMPO </td>
				<td colspan="5" align="right">
				<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
						//{
				%>
			    <%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
				<%
					   // }
				%>				</td>
			</tr>	
			<tr class="TextHeader" align="center">
				<td width="3%">Sec.</td>
				<td width="15%">Fecha</td>							
				<td width="10%">T. Generado</td>					
				<td width="10%">T. Aprobado</td>
				<td width="45%">Tipo de H.Extra</td>
				<td width="10%">Aprobado</td>
				<td width="7%">&nbsp;</td>
			</tr>		
			
				
				<%	
				String fecha = "";
				String te_hent = "";
				String te_hsal = "";	  
			    al = CmnMgr.reverseRecords(sobHash);				
			    for (int i = 0; i < sobHash.size(); i++)
				    {
					  key = al.get(i).toString();	
					  CommonDataObject sob = (CommonDataObject) sobHash.get(key);	
					  fecha = "fecha"+i;
						//  te_hent = "te_hent"+i;
					  	//	te_hsal = "te_hsal"+i;	  
			    %>		
	<tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%><%=fb.hidden("periodo"+i,"")%>
			
			<td><%=fb.intBox("codigo"+i,sob.getColValue("codigo"),false,false,true,5,1,"Text10",null,null)%></td>	
					            
            <td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>	
				<jsp:param name="valueOfTBox1" value="<%=(sob.getColValue("fecha")==null)?"":sob.getColValue("fecha")%>" />
				</jsp:include>
			</td>
                
			<td align="center"><%=fb.textBox("tAsignado"+i,sob.getColValue("tAsignado"),false,false,false,8,8)%></td>
			<td align="center"><%=fb.textBox("tPosterior"+i,sob.getColValue("tPosterior"),false,false,false,8,8)%></td>
			<td><%=fb.intBox("tipoext"+i,"",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("tipoextDesc"+i,sob.getColValue("descripcion"),false,false,true,25,25,"Text10",null,null)%><%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
				
			<td><%=fb.checkbox("estado"+i,"S",(sob.getColValue("estado")!=null && sob.getColValue("estado").equalsIgnoreCase("S")),false)%></td>
			<td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>			 		
	</tr>					
			
	<tr class="TextRow01" >
	    	<td colspan="4">
	    	<table >						       
	    <tr>
			<td>Forma de Pago
			<%=fb.select("fPago"+i,"DI=Dinero,GA=Gasto de Alimentacion,TC=Tiempo Compensatorio","",false,false,0,"Text10",null,null)%></td>
			<td> Factor Multiplicador <%=fb.textBox("factor"+i,"",false,false,true,10,10,"Text10",null,null)%></td>
		</tr>
	    </table>
		</td>		   	   

		<td colspan="3">
			<table >						       
			<tr>
			<td> Rata por Hora <%=fb.textBox("rata"+i,"",false,false,true,10,10,"Text10",null,null)%></td>
				<td>Monto</td>
			   	<td><%=fb.decBox("monto"+i,"",false,false,false,10,8.2,"Text10",null,null)%></td>
			</tr>
			</table>
		</td>		
	</tr>
		
	<tr class="TextRow01" >
	    <td colspan="4">
		    <table>						       
		   	<tr>
			   <td><font size="2">Comentarios</font></td>
			   <td><%=fb.textarea("motivo"+i,"",false,false,false,33,3,"Text11",null,null)%></td>
			</tr>
			</table>
		</td>		   	   
					
		<td colspan="3">
		    <table width="97%">
		    <tr>
		       <td width="26%"><font size="2">Año</font></td>
			   <td width="74%"><%=fb.textBox("anio"+i,sob.getColValue("anio"),false,false,false,10,10,"Text10",null,null)%></td>							       	    </tr>					       
		
		    <tr>
		       <td><font size="2">Periodo</font></td>
			   <td><%=fb.intBox("quincena"+i,sob.getColValue("quincena"),false,false,false,3,10,"Text10",null,null)%></td>
		    </tr>
		 
		    <tr>
		       <td><font size="2">Tipo de Planilla</font></td>
			   <td><%=fb.intBox("tipopla"+i,sob.getColValue("tipopla"),false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("tipoplaDesc"+i,sob.getColValue("tipoplaDesc"),false,false,true,25,25,"Text10",null,null)%> <%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addTipo("+i+")\"")%> </td>
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
	
			<td align="right" colspan="7"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0,1)\"")%>				</td>
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
   sobLastLineNo = Integer.parseInt(request.getParameter("sobLastLineNo"));		  
   String ItemRemoved = "";	  
//   provincia = request.getParameter("provincia");
//   sigla = request.getParameter("sigla");
//   tomo = request.getParameter("tomo");
//   asiento = request.getParameter("asiento");
//   numEmpleado = request.getParameter("numEmpleado");
   seccion = request.getParameter("seccion");
 //  area = request.getParameter("area");
   grupo = request.getParameter("grupo");
   
   if (!request.getParameter("baction").equalsIgnoreCase("Guardar"))
   {
	  for (int i=0; i<keySize; i++)
	  {
	    cdo = new CommonDataObject();
        
		cdo.setTableName("tbl_pla_st_det_turext"); 
//		cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area);
//		cdo.addColValue("ue_codigo",area);
//		cdo.addColValue("provincia",provincia);
//		cdo.addColValue("sigla",sigla);
//		cdo.addColValue("tomo",tomo); 
//		cdo.addColValue("asiento",asiento);
//		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
//		cdo.addColValue("num_empleado",numEmpleado);
		cdo.addColValue("anio",request.getParameter("anio"+i));	
		cdo.addColValue("periodo",request.getParameter("quincena"+i));	
	   	cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("codigo",request.getParameter("tipoext"+i));
		cdo.addColValue("cantidad",request.getParameter("tAsignado"+i));	
		
		cdo.addColValue("saldo",request.getParameter("tAsignado"+i));
			
		cdo.addColValue("comentario",request.getParameter("motivo"+i));	
		cdo.addColValue("forma_pago",request.getParameter("fPago"+i));
		cdo.addColValue("cantidad_aprob",request.getParameter("tPosterior"+i));	
		cdo.addColValue("monto",request.getParameter("monto"+i));
		cdo.addColValue("anio_pag",request.getParameter("anio"+i));	
		cdo.addColValue("quincena_pag",request.getParameter("quincena"+i));	
		cdo.addColValue("cod_planilla_pag",request.getParameter("tipopla"+i));	
				 
	    key = request.getParameter("key"+i);
	    if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{ 	  
	       ItemRemoved = key;		 
		}
		else
		{
		   try{ 
				sobHash.put(key,cdo);
			  }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
		}

	    if (!ItemRemoved.equals(""))
	    {
		   list.remove(sobHash.get(ItemRemoved));
		   sobHash.remove(ItemRemoved);	       
		   response.sendRedirect("../rhplanilla/empl_sobretiempo_detail.jsp?change=1&sobLastLineNo="+sobLastLineNo+"&seccion="+seccion);
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
		   cdo2.addColValue("fecha_inicio","");
		   cdo2.addColValue("cantidad","");	
		   cdo2.addColValue("the_codigo","");
		   cdo2.addColValue("saldo","");
		   cdo2.addColValue("comentario","");	
		   cdo2.addColValue("forma_pago","");
		   cdo2.addColValue("cantidad_aprob","");	
		   cdo2.addColValue("monto","");
		   cdo2.addColValue("anio_pag","");	
		   cdo2.addColValue("quincena_pag","");	
		   cdo2.addColValue("cod_planilla_pag","");	
		
		   sobLastLineNo++;	
		   cdo2.addColValue("codigo",""+sobLastLineNo);	
		   if (sobLastLineNo < 10) key = "00" + sobLastLineNo;
		   else if (sobLastLineNo < 100) key = "0" + sobLastLineNo;
		   else key = "" + sobLastLineNo;
		 
		   sobHash.put(key,cdo2);	

		   response.sendRedirect("../rhplanilla/empl_sobretiempo_detail.jsp?change=1&sobLastLineNo="+sobLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo);
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
				cdo = new CommonDataObject();
				
				
				///cdo.setTableName("tbl_pla_st_det_turext"); 
		cdo.setTableName("tbl_pla_t_extraordinario"); 
		cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("empId"+j) );
		 		//cdo.addColValue("ue_codigo",grupo);
		cdo.addColValue("provincia",request.getParameter("provincia"+j));
		cdo.addColValue("sigla",request.getParameter("sigla"+j));
		cdo.addColValue("tomo",request.getParameter("tomo"+j)); 
		cdo.addColValue("asiento",request.getParameter("asiento"+j));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));			
		cdo.addColValue("emp_id",request.getParameter("empId"+j));
				
		cdo.addColValue("fecha_inicio",request.getParameter("fecha"+i));
		cdo.addColValue("cantidad",request.getParameter("tAsignado"+i));
		cdo.addColValue("saldo",request.getParameter("tAsignado"+i));
		cdo.addColValue("aprobado","S");	
		cdo.addColValue("the_codigo",request.getParameter("tipoext"+i));
						
		cdo.addColValue("comentario",request.getParameter("motivo"+i));	
		cdo.addColValue("forma_pago",request.getParameter("fPago"+i));
		cdo.addColValue("anio_pag",request.getParameter("anio"+i));	
		cdo.addColValue("quincena_pag",request.getParameter("quincena"+i));	
		cdo.addColValue("cod_planilla_pag",request.getParameter("tipopla"+i));
		cdo.addColValue("estado_pag","PE");
		cdo.addColValue("cantidad_aprob",request.getParameter("tPosterior"+i));	
		cdo.addColValue("monto",request.getParameter("monto"+i));
		cdo.addColValue("vobo_estado","N");
				
		cdo.addColValue("codigo",request.getParameter("codigo"+i));         
		cdo.setAutoIncCol("codigo");			
					
		  	if(request.getParameter("estado"+i).equalsIgnoreCase("S"))
		  	cdo.addColValue("aprobado","S");
			else
			cdo.addColValue("aprobado","N");
										 
			key = request.getParameter("key"+i); 
			sobHash.put(key,cdo);
			list.add(cdo);
		     }
	      }
	   }	   	
    } 			  				
	SQLMgr.insertList(list,true,false); 	   
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_sobretiempo_detail.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_sobretiempo_detail.jsp")%>';
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