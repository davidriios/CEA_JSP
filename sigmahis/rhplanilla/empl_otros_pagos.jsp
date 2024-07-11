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
<jsp:useBean id="otroHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="calenHash" scope="session" class="java.util.Hashtable" />
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
ArrayList cal = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");
String grupo = request.getParameter("grupo");
String provincia = "";
String sigla = "";
String tomo = "";
String asiento = "";
String numEmpleado = "";
String empId = "";
String seccion = "";
String area = "";
String key = "";
String key_date = "";
String key_anio = "";
String key_mes = "";
String key_qmes = "";
String sql = "";
String date = "";
String dateRec = "";
String estado = "PE";
int otroLastLineNo = 0;
int count = 0;

/*if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")) provincia = request.getParameter("provincia");
if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) sigla = request.getParameter("sigla");
if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) tomo = request.getParameter("tomo");
if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) asiento = request.getParameter("asiento");
if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").equals("")) numEmpleado = request.getParameter("numEmpleado");*/
if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("otroLastLineNo") != null && !request.getParameter("otroLastLineNo").equals("")) otroLastLineNo = Integer.parseInt(request.getParameter("otroLastLineNo"));
 
if (request.getMethod().equalsIgnoreCase("GET"))
{  
   if (change == null)
   {	
   
       date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi");
	   dateRec = CmnMgr.getCurrentDate("dd/mm/yyyy");
     sql = "select trans_desde as desde, trans_hasta as hasta, periodo, to_char(fecha_inicial,'dd/mm/yyyy') as fechaInicio, to_char(fecha_cierre,'dd/mm/yyyy') as fechaCierre, to_char(fecha_inicial,'mm') as mesInicio, to_char(fecha_inicial,'yyyy') as anioInicio, to_number(to_char(fecha_inicial,'mm'))*2 -1 as qReporta from tbl_pla_calendario where tipopla=1 and fecha_cierre+2 >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') and trans_desde <= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') and trans_hasta+1 >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') and rownum = 1";
	  
	   cal = SQLMgr.getDataList(sql); 
	   for (int i=0; i<cal.size(); i++) 
	   { 
	   calenHash.clear(); 
	   CommonDataObject calen = (CommonDataObject) cal.get(i);
	   key_date=calen.getColValue("fechaCierre");
	   key_anio=calen.getColValue("anioInicio");
	   key_mes=calen.getColValue("mesInicio");
	   key_qmes=calen.getColValue("qReporta");
	  
	   }
	   
		
	   otroHash.clear(); 
	   otroLastLineNo ++;	   			
	   if (otroLastLineNo < 10) key = "00" + otroLastLineNo;
	   else if (otroLastLineNo < 100) key = "0" + otroLastLineNo;
	   else key = "" + otroLastLineNo;
	    
	   
	   CommonDataObject otro = new CommonDataObject();
	   otro.addColValue("fecha",date.substring(0,10));
	   otro.addColValue("dateRec",dateRec.substring(0,10));
	   otro.addColValue("fechaFin",date.substring(0,10));
	   otro.addColValue("anio",dateRec.substring(6,10));
	   otro.addColValue("horaSalida",date.substring(11));
	   otro.addColValue("horaDesde",date.substring(11));
	   otro.addColValue("horaHasta",date.substring(11));
	   otro.addColValue("codigo",""+otroLastLineNo);
	   otro.addColValue("grupo",""+grupo);
	   otro.addColValue("fechaInicio",""+key_date);
	   otroHash.put(key,otro);	   
   }	   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Otros Pagos - '+document.title;

function doSubmit()
{ 
	 document.formOtro.save.disableOnSubmit = true;
	    document.formOtro.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
	 if (parent.doRedirect('6','0') == true)
	 {	 
	 document.formOtro.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
	   for (i=0; i<<%=iEmp.size()%>; i++)
     { 
	  
eval('document.formOtro.provincia'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value; 
eval('document.formOtro.sigla'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value; 
eval('document.formOtro.tomo'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value; 
eval('document.formOtro.asiento'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value; 
eval('document.formOtro.numEmpleado'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
eval('document.formOtro.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
		
   if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
		   eval("document.formOtro.check"+i).value = 'S'; 
		}
		else
		{
		   eval("document.formOtro.check"+i).value = 'N';
		}   
	 }
	 document.formOtro.baction.value = "Guardar"; 
	 parent.unCheckAll('2');  
	 //rte    
//   if (formIncapacidadValidation())
//   { 
 
     document.formOtro.submit(); 
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
function pago(k)
{ 
  var i = 0;
  var cant = 1;
  var monto = 35.00;
  
	 cant = eval('document.formOtro.cantidad'+k).value;
	  monto = eval('document.formOtro.monto'+k).value;
	
	 eval('document.formOtro.pago'+k).value = cant*monto; 
	// eval('document.formOtro.pago').value = eval('document.formOtro.monto').value  
	// eval('document.formOtro.pago').value = (cant * monto).toFixed(2);     
  }
  
  function reporta(k)
  {
  var q;
  var mes;
   q = eval('document.formOtro.quincena'+k).value; 
   mes = eval('document.formOtro.mes'+k).value; 
   
   if (q==1)
   { 
   eval('document.formOtro.qReporta'+k).value = (mes*2) - 1; 
   }
   else if(q==2)
   { 
   eval('document.formOtro.qReporta'+k).value = (mes*2);
   }
  }
          
function addMotivo(index)
{
   abrir_ventana1('../common/search_motivo_falta.jsp?fp=otros_empleado&index='+index);
}
function addLicencia(index)
{
   var inact ="";
   {
   abrir_ventana1('../common/search_motivo_licencia.jsp?fp=otros_empleado&index='+index);
}
}

function addPert(index)
{

abrir_ventana1('../common/search_tipo_transaccion.jsp?fp=otro_pago&index='+index);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formOtro",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
		<%=fb.hidden("baction","")%>	
		<%=fb.hidden("perLastLineNo",""+otroLastLineNo)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("area",area)%>
		<%=fb.hidden("ue_codigo",grupo)%>
		<%=fb.hidden("grupo",""+grupo)%>
		<%=fb.hidden("numId","")%>
		<%=fb.hidden("keySize",""+otroHash.size())%>	
			
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
		<%	
		String js = "";	
		String fecha = "";
		String anio = "";
		String g = "";
		String fechaFin = "";
		String horaEntrada = "";
		String horaSalida = "";	
		String horaDesde = "";
		String horaHasta = ""; 
		
		//String fechaInicio = "";
		//String periodo = "";
		//String fechaIniTran = "";	
		//String fechaFinTran = "";
		//String fechaFinal = ""; 
	
	
	
			    al = CmnMgr.reverseRecords(otroHash);				
			    for (int i = 0; i < otroHash.size(); i++)
			    {
				  key = al.get(i).toString();	
				  CommonDataObject otro = (CommonDataObject) otroHash.get(key);	
				  fecha = "fecha"+i;
				  fechaFin = "fechaFin"+i;
				  anio = "anio"+i;
				  horaEntrada = "horaEntrada"+i;
				  horaSalida = "horaSalida"+i;
				  horaDesde = "horaDesde"+i;
				  horaHasta = "horaHasta"+i;
				  estado = "estado"+i;	
			
				 %>	
			
	<tr class="TextRow01">
		
		<td width="450"> REGISTRO DE OTROS PAGOS </td>
		<td width="500"> </td>
	</tr>
	<tr class="TextRow02"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>
		<td width="450">&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Solicitud&nbsp;<%=fb.textBox("dateRec",otro.getColValue("dateRec"),false,false,true,10)%>&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.hidden("estado"+i,otro.getColValue("estado"))%><%=fb.hidden("estado_pago"+i,"PE")%></td>
		<td width="500">C&oacute;digo&nbsp;&nbsp;<%=fb.intBox("codigo"+i,otro.getColValue("codigo"),true,false,true,5,1)%><%=fb.textBox("fechaInicio"+i,otro.getColValue("fechaInicio"),false,false,true,10,10)%></td>
	</tr>
	
		<tr class="TextRow01">
		<td width="450">&nbsp;&nbsp;Año&nbsp;&nbsp;<%=fb.intBox("anio"+i,key_anio,true,false,false,4,4)%>&nbsp;&nbsp;Mes&nbsp;&nbsp;<%=fb.intBox("mes"+i,key_mes,true,false,false,3,3)%>&nbsp;&nbsp;Quincena&nbsp;&nbsp;<%=fb.select("quincena"+i,"1=PRIMERA,2=SEGUNDA","",false,false,0,"Text10",null,"onChange=\"javascript:reporta('"+i+"')\"")%></td>
	
		<td width="500">Fecha Cierre&nbsp;&nbsp;<%=fb.intBox("fechaCierre"+i,key_date,true,false,false,10,10)%>&nbsp;&nbsp;Quincena Reporta&nbsp;&nbsp;<%=fb.intBox("qReporta"+i,key_qmes,true,false,false,4,4)%></td>
	</tr>
	
	
	<tr class="TextHeader" >&nbsp;&nbsp;&nbsp;	
        <td colspan="2">&nbsp;	</td>
	</tr>
		
		  		
	<tr class="TextRow01">
	   
	  <td>&nbsp;&nbsp;Tipo de Pago <%=fb.intBox("codPert",otro.getColValue("codPert"),false,false,true,5,15,"Text10",null,null)%><%=fb.textBox("pertDesc",otro.getColValue("pertDesc"),false,false,true,30,30,"Text10",null,null)%><%=fb.button("btnpert","...",true,false,null,null,"onClick=\"javascript:addPert('"+i+"')\"")%>	</td>
	  <td>Fecha de Trx.
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fechaFin"/>						
		<jsp:param name="valueOfTBox1" value="<%=(otro.getColValue("fechaFin")==null)?"":otro.getColValue("fechaFin")%>" />
		</jsp:include>
		Tipo de Trx. <%=fb.intBox("transaccion",otro.getColValue("transaccion"),false,false,true,5,5,"Text10",null,null)%>	</td>
	</tr>

	<tr class="TextRow02">
	 
	  <td>&nbsp;&nbsp;Cantidad &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.intBox("cantidad"+i,"1",true,false,false,10,null,null,"onChange=\"javascript:pago('"+i+"')\"")%></td>
	
	  <td>Monto Unitario  &nbsp;&nbsp;<%=fb.decBox("monto"+i,otro.getColValue("monto"),true,false,false,10,8.2,null,null,"onChange=\"javascript:pago('"+i+"')\"")%> &nbsp;&nbsp; Total a pagar <%=fb.decBox("pago"+i,otro.getColValue("pago"),true,false,true,10,8.2)%></td>
	</tr>
	<tr class="TextRow01" >
	   
	    <td colspan="2">&nbsp;&nbsp;Observación &nbsp;<%=fb.textarea("motivo",otro.getColValue("motivo"),false,false,false,77,3)%></td>		
	</tr>	
				<%	 
				 }                                    
				%>
	<tr class="TextRow01">
		<td align="right" colspan="9"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0,1)\"")%>					</td>
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
 // vacLastLineNo = Integer.parseInt(request.getParameter("vacLastLineNo"));		  
  String ItemRemoved = "";	  
//   provincia = request.getParameter("provincia");
//   sigla = request.getParameter("sigla");
//   tomo = request.getParameter("tomo");
//   asiento = request.getParameter("asiento");
//   empId = request.getParameter("empId");
   seccion = request.getParameter("seccion");
   area = request.getParameter("area");
   grupo = request.getParameter("grupo");
   
   if (!request.getParameter("baction").equalsIgnoreCase("Guardar"))
   {
	
	  for (int i=0; i<keySize; i++)
	  {
	    CommonDataObject cdo = new CommonDataObject();
       
		cdo.setTableName("tbl_pla_transac_emp"); 
	//	cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area);
	//	cdo.addColValue("ue_codigo",grupo);
	//	cdo.addColValue("provincia",provincia);
	//	cdo.addColValue("sigla",sigla);
	//	cdo.addColValue("tomo",tomo); 
	//	cdo.addColValue("asiento",asiento);
	//	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	//	cdo.addColValue("num_empleado",numEmpleado);
	 	cdo.addColValue("emp_id",empId);
	    cdo.addColValue("fecha",request.getParameter("dateRec"));
		cdo.addColValue("tipo_trx",request.getParameter("transaccion"));
		cdo.addColValue("hora_salida",request.getParameter("horaSalida"+i));
	    cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"+i));
		cdo.addColValue("horas_desde",request.getParameter("horaDesde"+i));
		cdo.addColValue("hora_hasta",request.getParameter("horaHasta"+i));
		cdo.addColValue("fecha_fin",request.getParameter("fechaFin"+i));
		cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
		//cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
		cdo.addColValue("codigo",request.getParameter("codigo"+i));	
		cdo.setAutoIncCol("codigo");
		cdo.addColValue("estado",request.getParameter("estado"+i)); 
		cdo.addColValue("forma_des","1");
		cdo.addColValue("aprobado","N");		 
	    key = request.getParameter("key"+i);
	
	if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{ 	  
	    ItemRemoved = key;		 
		}
	else
		{
	try{ 
		otroHash.put(key,cdo);
	    }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
		}

	if (!ItemRemoved.equals(""))
	    {
	   list.remove(otroHash.get(ItemRemoved));
		   otroHash.remove(ItemRemoved);	       
		   response.sendRedirect("../rhplanilla/empl_otros_pagos.jsp?change=1&otroLastLineNo="+otroLastLineNo+"&area="+area+"&seccion="+seccion+"&area="+area+"&grupo="+grupo);
		   return;
	    }   
      }	
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
	
           date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	       CommonDataObject cdo2 = new CommonDataObject();
		   cdo2.addColValue("compania","");		 		
		   cdo2.addColValue("provincia","");
		   cdo2.addColValue("sigla","");
		   cdo2.addColValue("tomo",""); 
		   cdo2.addColValue("asiento","");
		   cdo2.addColValue("fecha",date.substring(0,10));
		   cdo2.addColValue("hora_salida",date.substring(11));
		   cdo2.addColValue("hora_entrada",date.substring(11));
		   cdo2.addColValue("estado","");
		   cdo2.addColValue("forma_des","");
		   cdo2.addColValue("ue_codigo","");
		   cdo2.addColValue("num_empleado","");
		   cdo2.addColValue("mfalta","");
	       cdo2.addColValue("emp_id","");
		   cdo2.addColValue("hora_desde","");
		   cdo2.addColValue("hora_hasta","");
		   cdo2.addColValue("codigo","");
		   cdo2.addColValue("fecha_fin","");
		   otroLastLineNo++;	
		   //cdo2.addColValue("codigo",""+perLastLineNo);	
		  
		   if (otroLastLineNo < 10) key = "00" + otroLastLineNo;
		   else if (otroLastLineNo < 100) key = "0" + otroLastLineNo;
		   else key = "" + otroLastLineNo;
		 
		   otroHash.put(key,cdo2);	

		   response.sendRedirect("../rhplanilla/empl_otros_pagos.jsp?change=1&otroLastLineNo="+otroLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo);
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
			cdo.setTableName("tbl_pla_transac_emp"); 
		//	cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("emp_id"+j));
		cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("emp_id"+j));
				///System.out.println("**eeeeeeeeeeeeeeeeeee**"+grupo+request.getParameter("provincia"+j)+request.getParameter("sigla"+j)+request.getParameter("asiento"+j)+request.getParameter("numEmpleado"+j)+request.getParameter("empId"+j)+request.getParameter("dateRec")+request.getParameter("transaccion"+i)+request.getParameter("motivo")+request.getParameter("fechaFin")+request.getParameter("codPert")+request.getParameter("monto")+request.getParameter("cantidad")+request.getParameter("codigo"+i)+request.getParameter("anio"+i));
										
			
	cdo.addColValue("grupo",grupo);
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("provincia",request.getParameter("provincia"+j));
	cdo.addColValue("sigla",request.getParameter("sigla"+j));
	cdo.addColValue("tomo",request.getParameter("tomo"+j)); 
	cdo.addColValue("asiento",request.getParameter("asiento"+j));
	cdo.addColValue("codigo",request.getParameter("codigo"+i));         
	cdo.setAutoIncCol("codigo");
	
	cdo.addColValue("fecha",request.getParameter("dateRec"));
	cdo.addColValue("monto",request.getParameter("pago"+i));	
	cdo.addColValue("fecha_creacion",request.getParameter("dateRec")); 
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
	cdo.addColValue("fecha_modificacion",request.getParameter("dateRec")); 
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName")); 	
	cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));
	cdo.addColValue("tipo_trx",request.getParameter("transaccion"));
	cdo.addColValue("emp_id",request.getParameter("empId"+j));
	cdo.addColValue("fecha_inicio",request.getParameter("fechaFin"));
	cdo.addColValue("sub_tipo_trx",request.getParameter("codPert"));
		
			cdo.addColValue("monto_unitario",request.getParameter("monto"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));		
			cdo.addColValue("estado_pago","PE"); 
			
			cdo.addColValue("anio_pago",request.getParameter("anio"+i)); 
			cdo.addColValue("mes_pago",request.getParameter("mes"+i)); 
			cdo.addColValue("quincena_pago",request.getParameter("qReporta"+i));
			cdo.addColValue("quincena_reporta",request.getParameter("qReporta"+i));
			cdo.addColValue("periodof_final",request.getParameter("fechaFin")); 
			cdo.addColValue("comentario",request.getParameter("motivo")); 
			cdo.addColValue("accion","PA");
			cdo.addColValue("vobo_estado","N");
			cdo.addColValue("aprobacion_estado","N");
			cdo.addColValue("cod_planilla_pago","1");
			cdo.addColValue("anio_reporta",request.getParameter("anio"+i));
			cdo.addColValue("cod_planilla_reporta","1");
			cdo.addColValue("bonif_por_reemplazo","D"); 
				//key = request.getParameter("key"+i); 
				//vacHash.put(key,cdo);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_otros_pagos.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_otros_pagos.jsp")%>';
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