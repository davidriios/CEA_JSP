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
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject empl= new CommonDataObject();

ArrayList al = new ArrayList();

String change = request.getParameter("change");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
String num = request.getParameter("num");
String empId = request.getParameter("emp_id");
String rath = request.getParameter("rath");
String grupo = request.getParameter("grp");
String seccion = "";
String area = "";
String key = "";
String sql = "";
String date = "";
int sobLastLineNo = 0;
int count = 0;
int desclastLineNo =0;

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
 
sql="select b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.segundo_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, f.descripcion as descripcion, b.emp_id as empId, b.estado, c.denominacion, g.descripcion as estadodesc, b.num_empleado as numEmpleado, b.rata_hora as rata, b.ubic_seccion as grupo from tbl_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c, tbl_pla_estado_emp g where b.compania = f.compania and b.ubic_seccion = f.codigo and b.compania = c.compania and b.cargo = c.codigo and b.estado = g.codigo and b.compania="+(String) session.getAttribute("_companyId")+" and b.emp_id = "+empId+" order by b.ubic_seccion, b.primer_apellido";
	   empl = SQLMgr.getData(sql);

	   
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
/*
	document.formSobretiempo.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
     
	   
eval('document.formSobretiempo.provincia'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value; 
eval('document.formSobretiempo.sigla'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value; 
eval('document.formSobretiempo.tomo'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value; 
eval('document.formSobretiempo.asiento'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value; 				    
   eval('document.formSobretiempo.numEmpleado'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
   eval('document.formSobretiempo.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
   */
	 document.formSobretiempo.baction.value = "Guardar";
//	 parent.unCheckAll('2');     
//   if (formIncapacidadValidation())
//   { 	
     document.formSobretiempo.submit(); 
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
	parent.setHeight('extras',document.body.scrollHeight);
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


			count++;
			empId  = eval("document.formSobretiempo.empId").value;
			rata = eval("document.formSobretiempo.rath").value;
	
	
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
			<%=fb.hidden("provincia",prov)%>
			<%=fb.hidden("sigla",sig)%>
			<%=fb.hidden("tomo",tom)%>
			<%=fb.hidden("asiento",asi)%>
			<%=fb.hidden("numEmpleado",num)%>
			<%=fb.hidden("empId",empId)%>
			<%=fb.hidden("rath",rath)%>
			 	
			<tr>
		<td colspan="7">&nbsp;</td>
	</tr>
	
	<tr class="TextRow02">
		<td colspan="7">&nbsp;</td>
	</tr>	
	
	<tr class="TextHeader">
		<td colspan="7">&nbsp;Generales de Empleado</td>
	</tr>		
	<tr class="TextRow01" >
		<td colspan="2">&nbsp;Nombre del Empleado</td>
		<td colspan="2">&nbsp;<%=empl.getColValue("nombre")%></td>
		<td colspan="3">&nbsp;Número de Empleado &nbsp;&nbsp;<%=empl.getColValue("numEmpleado")%>
		</td>
	</tr>

<tr class="TextRow02" >
		<td colspan="2">&nbsp;N&uacute;mero de C&eacute;dula</td>
		<td colspan="2">&nbsp;<%=empl.getColValue("provincia")%>-&nbsp;<%=empl.getColValue("sigla")%>-&nbsp;<%=empl.getColValue("tomo")%>-&nbsp;<%=empl.getColValue("asiento")%></td>
		<td colspan="3">&nbsp;Estado&nbsp;&nbsp;<%=empl.getColValue("estadodesc")%>
		</td>
	</tr>
	
	<tr class="TextRow01" >
		<td colspan="2">&nbsp;Departamento</td>
		<td colspan="2">&nbsp;<%=empl.getColValue("descripcion")%></td>
		<td colspan="3">&nbsp;Cargo &nbsp;&nbsp;<%=empl.getColValue("denominacion")%></td>
	</tr>

			    
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
				<td width="15%">T. Generado</td>					
				<td width="15%">T. Aprobado</td>
				<td width="35%">Tipo de H.Extra</td>
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
			<td><%=fb.intBox("tipoext"+i,"",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("tipoextDesc"+i,sob.getColValue("descripcion"),false,false,true,35,35,"Text10",null,null)%><%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
				
			<td><%=fb.checkbox("estado","S",(sob.getColValue("estado")!=null && sob.getColValue("estado").equalsIgnoreCase("S")),false)%></td>
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
			<td> Rata por Hora <%=fb.textBox("rata"+i,rath,false,false,true,10,10,"Text10",null,null)%></td>
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
	
			<td align="right" colspan="7"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>				</td>
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

else if(request.getMethod().equalsIgnoreCase("POST"))
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
//desclastLineNo= Integer.parseInt(request.getParameter("desclastLineNo"));
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";

for(int a=0; a<keySize; a++)
{ 
 CommonDataObject cdo1 = new CommonDataObject();
   
  cdo1.setTableName("tbl_pla_t_extraordinario");
  cdo1.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi+" and emp_id="+empId);
  //cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+emp_id);
  cdo1.addColValue("emp_id",empId);
  cdo1.addColValue("provincia",prov); 
  cdo1.addColValue("sigla",sig);
  cdo1.addColValue("tomo",tom);
  cdo1.addColValue("asiento",asi);   
  cdo1.addColValue("compania",(String) session.getAttribute("_companyId"));
 	cdo1.addColValue("fecha_inicio",request.getParameter("fecha"+a));
		cdo1.addColValue("cantidad",request.getParameter("tAsignado"+a));	
		cdo1.addColValue("the_codigo",request.getParameter("tipoext"+a));
		cdo1.addColValue("saldo",request.getParameter("tAsignado"+a));
			
		cdo1.addColValue("comentario",request.getParameter("motivo"+a));	
		cdo1.addColValue("forma_pago",request.getParameter("fPago"+a));
		cdo1.addColValue("cantidad_aprob",request.getParameter("tPosterior"+a));	
		cdo1.addColValue("monto",request.getParameter("monto"+a));
		cdo1.addColValue("anio_pag",request.getParameter("anio"+a));	
		cdo1.addColValue("quincena_pag",request.getParameter("quincena"+a));	
		cdo1.addColValue("cod_planilla_pag",request.getParameter("tipopla"+a));	
  
   cdo1.addColValue("codigo",request.getParameter("codigo"+a));  
  cdo1.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sig")+"' and tomo="+request.getParameter("tom")+" and asiento="+request.getParameter("asi")+" and emp_id="+request.getParameter("empId"));
  cdo1.setAutoIncCol("codigo");  
  key=request.getParameter("key"+a);
  
  if(request.getParameter("remover"+a)==null)
  {
	  try
	  {
	  htdesc.put(key,cdo1);
	  list.add(cdo1);
	  }
	  catch(Exception e)
	  {
	   System.err.println(e.getMessage()); 
	  }	
  } 
  else itemRemoved= key;
 }//End For
 
if(!itemRemoved.equals(""))
{
htdesc.remove(key);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&emp_id="+empId+"&desclastLineNo="+desclastLineNo);
//response.sendRedirect("../rhplanilla/descuento_config.jsp?change=1&desclastLineNo="+desclastLineNo+"&emp_id="+emp_id);
return;
}

if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo2 = new CommonDataObject();
//cdo.addColValue("tipo_trx","");
//cdo.addColValue("codigo","0");
//cdo.addColValue("fecha_inicio","");
//cdo.addColValue("fecha_final","");

//cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
desclastLineNo++;

if(desclastLineNo<10)
key="00" + desclastLineNo;
else if(desclastLineNo<100)
key="0"+desclastLineNo;
else key=""+desclastLineNo;
htdesc.put(key,cdo);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&emp_id="+empId+"&desclastLineNo="+desclastLineNo);
 return;
}

SQLMgr.insertList(list);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/reg_sobretiempo_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/reg_sobretiempo_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/reg_sobretiempo_list.jsp';
<%
	}
	%>
	//window.opener.location.reload(true);
	window.close();
<%
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