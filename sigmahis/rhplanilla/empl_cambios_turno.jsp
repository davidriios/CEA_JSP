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
<jsp:useBean id="perHash" scope="session" class="java.util.Hashtable" />
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
//String com = request.getParameter("compania"); 
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
String dateRec = "";

int perLastLineNo = 0;
int count = 0;

/*if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")) provincia = request.getParameter("provincia");
if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) sigla = request.getParameter("sigla");
if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) tomo = request.getParameter("tomo");
if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) asiento = request.getParameter("asiento");
if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").equals("")) numEmpleado = request.getParameter("numEmpleado");*/
if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("perLastLineNo") != null && !request.getParameter("perLastLineNo").equals("")) perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));
 
if (request.getMethod().equalsIgnoreCase("GET"))
{  
   if (change == null)
   {	
/*     sql = "select a.codigo, to_date(a.fecha,'dd/mm/yyyy') as fecha, a.hora_entrada, a.hora_salida, a.estado, nvl(a.mfalta,' ') as mfalta, b.descripcion as mfaltaDesc FROM tbl_pla_ct_programa a, tbl_pla_ct_turno b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and provincia="+provincia+" and sigla="+sigla+" and tomo="+tomo+" and asiento="+asiento+" and ue_codigo="+area+" and num_empleado="+numEmpleado+" and a.dia||=b.codigo(+)";
	   al = SQLMgr.getDataList(sql); */
	   perHash.clear(); 
	   perLastLineNo ++;	   			
	   if (perLastLineNo < 10) key = "00" + perLastLineNo;
	   else if (perLastLineNo < 100) key = "0" + perLastLineNo;
	   else key = "" + perLastLineNo;
	   
	   date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	   dateRec = CmnMgr.getCurrentDate("dd/mm/yyyy");
	   
	   CommonDataObject per = new CommonDataObject();
	   per.addColValue("fecha",date.substring(0,10));
	   per.addColValue("dateRec",dateRec.substring(0,10));
	   per.addColValue("hora_entrada",date.substring(11));
	   per.addColValue("mes",date.substring(3,5));
	   per.addColValue("anio",date.substring(6,10));
	    per.addColValue("mesnew",date.substring(3,5));
	   per.addColValue("anionew",date.substring(6,10));
	   per.addColValue("hora_salida",date.substring(11));
	   per.addColValue("codigo",""+perLastLineNo);
	   perHash.put(key,per);	   
   }	   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Cambio de Turno de Empleados - '+document.title;

function doSubmit()
{ 
	 document.formCambio.save.disableOnSubmit = true;
	 if (parent.doRedirect('3','0') == true)
	 {	 
	  document.formCambio.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
     for (i=0; i<<%=iEmp.size()%>; i++)
     { 
	   
	 eval('document.formCambio.provincia'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value; 
	eval('document.formCambio.sigla'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value; 
	eval('document.formCambio.tomo'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value; 
	eval('document.formCambio.asiento'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value; 
	eval('document.formCambio.numEmpleado'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
	eval('document.formCambio.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
		
	if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
	   eval("document.formCambio.check"+i).value = 'S'; 
	   eval("document.formCambio.numId").value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
		}
		else
		{
	   eval("document.formCambio.check"+i).value = 'N';
		}   
	 }
	 document.formCambio.baction.value = "Guardar";     
//   if (formIncapacidadValidation())
//   { 
     document.formCambio.submit(); 
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


function cambioHora()
{ 
  var i = 0;
  var fechaIni = "";
  var mes= "";
  var anio= "";
  var fechaCambio = "";
  var diaNew  = "";
  var mesNew  = "";
  var anioNew = "";
  
  for (i=0;i<<%=perHash.size()%>;i++)
  {
    mes = (eval('document.formCambio.fechaFin'+i).value).substring(3,5);
    anio = (eval('document.formCambio.fechaFin'+i).value).substring(6,10);
	  	  
		 var fechaNueva = new Date(fechaCambio);
	  eval('document.formCambio.mes').value = mes;
	  eval('document.formCambio.anio').value = anio; 
	  
	  eval('document.formCambio.fechaFin'+i).value = fechaNueva;
	     
		 diaNew = (eval('document.formCambio.fechaFin'+i).value).substring(0,1);
	     mesNew = (eval('document.formCambio.fechaFin'+i).value).substring(3,5);
         anioNew = (eval('document.formCambio.fecha'+i).value).substring(6,10);
		
	        
  }
}
function regFecha()
{ 
  var i = 0;
  var fechaIni = "";
  var fechaFin = "";
  var mes= "";
  var anio= "";
  	  
  for (i=0;i<<%=perHash.size()%>;i++)
     {
      mes = (eval('document.formCambio.fecha'+i).value).substring(3,5);
	  anio = (eval('document.formCambio.fecha'+i).value).substring(6,10);
	  	  
	  eval('document.formCambio.mes').value = mes;
	  eval('document.formCambio.anio').value = anio;       
     }
  }


function newFecha()
{ 
  var i = 0;
  var fechaIni = "";
  var fechaFin = "";
  var dia = "";
  var mes= "";
  var anio= "";
  var mesnew= "";
  var anionew= "";
  var dia="";
  var numId="";

  dia = (eval('document.formCambio.fechaFin'+i).value).substring(0,2); 
  if (dia > 9) 
    {
      dia = 'a.dia'+(eval('document.formCambio.fechaFin'+i).value).substring(0,2);
    }
	else
	{
	  dia = 'a.dia'+(eval('document.formCambio.fechaFin'+i).value).substring(1,2);
	}
    anionew = (eval('document.formCambio.fechaFin'+i).value).substring(6,10);
    mesnew = (eval('document.formCambio.fechaFin'+i).value).substring(3,5);
	  eval('document.formCambio.mesnew'+i).value = mesnew;
	  eval('document.formCambio.anionew'+i).value = anionew;  


 for (i=0; i<<%=iEmp.size()%>; i++)
     { 
	eval('document.formCambio.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
		
	if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
	eval("document.formCambio.numId").value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
	
	 numId = (eval('document.formCambio.empId'+i).value)
	 
 var cod = getDBData('<%=request.getContextPath()%>','b.codigo, b.descripcion','tbl_pla_ct_tprograma a, tbl_pla_ct_turno b','b.codigo = '+dia+' and  a.compania = b.compania and a.anio = '+anionew+' and a.mes = '+mesnew+' and a.emp_id = '+numId+'','');
	
	var pos = cod.indexOf("|");
	var turno = cod.substr(0,pos);
	var desc_turno = cod.substr(pos+1,cod.length);
	
	 eval('document.formCambio.motivo'+i).value = 'empleado con turno '+turno+' '+desc_turno;
	 eval('document.formCambio.cod_turno_fin'+i).value = turno;
	 eval('document.formCambio.dsp_turno_fin').value = desc_turno;
	
	if (pos < 0 )
	 {
	 var empl = getDBData('<%=request.getContextPath()%>','b.codigo, b.descripcion','tbl_pla_ct_turno b, tbl_pla_empleado c','b.compania = c.compania and b.codigo = c.horario and c.emp_id = '+numId+'','');
	
	var pos = empl.indexOf("|");
	var turno = empl.substr(0,pos);
	var desc_turno = empl.substr(pos+1,empl.length);
	var pos = empl.indexOf("|");
	 eval('document.formCambio.motivo'+i).value = 'empleado con turno '+turno+' '+desc_turno;
	 eval('document.formCambio.cod_turno_fin'+i).value = turno;
	 eval('document.formCambio.dsp_turno_fin').value = desc_turno;
	}
	 
	}
	 }
	
}


function addTurno()
{
   abrir_ventana1('../common/search_turno.jsp?fp=cambios_empleado');
}

function addPert()
{
var group = parent.frames['iEmpleado'].document.formEmpleado.grupo.value; 
   abrir_ventana1('../common/search_empleado_otros.jsp?fp=cambio_turno&grupo='+group);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formCambio",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
		<%=fb.hidden("baction","")%>	
		<%=fb.hidden("perLastLineNo",""+perLastLineNo)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("area",area)%>
		<%=fb.hidden("grupo",grupo)%>
		<%=fb.hidden("numId","")%>
		<%=fb.hidden("dateRec",dateRec)%>
		<%=fb.hidden("keySize",""+perHash.size())%>	
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
		  String fechaFin = "";
		  String horaEntrada = "";
		  String horaSalida = "";	
		  String horaDesde = "";
		  String horaHasta = ""; 
		  String mes = "";
		  String anio = ""; 
		  String mesnew = "";
		  String anionew = ""; 
		  al = CmnMgr.reverseRecords(perHash);				
			    for (int i = 0; i < perHash.size(); i++)
				    {
				  key = al.get(i).toString();	
				  CommonDataObject per = (CommonDataObject) perHash.get(key);	
				  fecha = "fecha"+i;
				  fechaFin = "fechaFin"+i;
				  mes = "mes";
				  anio = "anio";
				  mesnew = "mesnew";
				  anionew = "anionew";	  
		  %>	
	<tr class="TextRow01">
		<td width="245"> </td>
		<td width="347"> CAMBIO DE TURNO </td>
		<td width="373"> C&oacute;digo&nbsp;&nbsp;<%=fb.intBox("codigo"+i,per.getColValue("codigo"),false,false,true,10,1)%></td>
	</tr>
		<tr class="TextRow02">
	    <td>Fecha de Registro </td>
	    <td><jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />        
        <jsp:param name="clearOption" value="true" />        
        <jsp:param name="nameOfTBox1" value="<%=fecha%>" />        
        <jsp:param name="jsEvent" value="regFecha()"/>        
        <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("fecha")==null)?"":per.getColValue("fecha")%>"/>        
</jsp:include></td>
	    <td>Mes&nbsp;<%=fb.textBox("mes",per.getColValue("mes"),true,false,true,3)%>&nbsp;A&ntilde;o&nbsp;<%=fb.textBox("anio",per.getColValue("anio"),true,false,true,3)%></td>
	</tr>
				
	<tr class="TextHeader" >
                  &nbsp;&nbsp;&nbsp;	
        <td colspan="3">&nbsp;	</td>
	</tr>
				
	<tr class="TextRow01">	
		<td height="56">Fecha Asignada </td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />                    
            <jsp:param name="clearOption"  value="true" />                    
            <jsp:param name="nameOfTBox1"  value="<%=fechaFin%>"/>                    
            <jsp:param name="jsEvent"      value="newFecha()"/>                    
            <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("fechaFin")==null)?"":per.getColValue("fechaFin")%>" />                    
            </jsp:include>
			<%=fb.hidden("mesnew"+i,mesnew)%>
		    <%=fb.hidden("anionew"+i,anionew)%>			</td>
		<td>Turno <%=fb.intBox("cod_turno_fin"+i,per.getColValue("cod_turno_fin"),true,false,true,3,3,"Text10",null,null)%><%=fb.textBox("dsp_turno_fin",per.getColValue("dsp_turno_fin"),false,false,true,40,40)%></td>      
	</tr>			 
				
	<tr class="TextRow02"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>				    
	 	<td width="245">Turno a Realizar:</td>
	    <td width="347"><%=fb.intBox("codTurno",per.getColValue("codTurno"),true,false,true,5,3,"Text10",null,null)%><%=fb.textBox("turnoDesc",per.getColValue("turnoDesc"),false,false,true,30,30,"Text10",null,null)%><%=fb.button("btnturno","...",true,false,null,null,"onClick=\"javascript:addTurno()\"")%></td>
		<td>Acción&nbsp;&nbsp;<%=fb.select("estado"+i,"1= Mutuo Acuerdo entre Trabajadores, 2= Mutuo Acuerdo(Empleado - Empresa) Solicitado por Empleado, 3= Mutuo Acuerdo(Empleado - Empresa) Solicitado por la Empresa, 4= Mutuo Acuerdo(Empleado - Empresa) Turno Adicional, 5= Mutuo Acuerdo(Empleado - Empleado) Turno Adicional, 6= Mutuo Acuerdo(Cambio de Día Libre) Solicitado por la Empresa, 7= Mutuo Acuerdo(Cambio de Día Libre) Solicitado por el Empleado",per.getColValue("estado"),false,false,0,"Text10",null,null)%></td>	
	</tr>
	
	<tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>				    
		<td width="245">Pertenece a:</td>
	    <td width="347"><%=fb.intBox("codPert",per.getColValue("codPert"),false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("pertDesc",per.getColValue("pertDesc"),false,false,true,30,30,"Text10",null,null)%><%=fb.button("btnpert","...",true,false,null,null,"onClick=\"javascript:addPert()\"")%></td>
		<td>&nbsp;&nbsp;</td>	
	</tr>
		
	<tr class="TextRow02" >
	    <td>Observaci&oacute;n</td> 
	    <td colspan="2"><%=fb.textarea("motivo"+i,per.getColValue("motivo"),false,false,false,77,3)%></td>		
	</tr>	
			<%	 
				     //Si error--, quita el error. Si error++, agrega el error. 
				    // js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
					}                                    
					//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
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
   perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));		  
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
        
		cdo.setTableName("tbl_pla_ct_det_cambio_programa"); 
//		cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area);
//		cdo.addColValue("ue_codigo",area);
//		cdo.addColValue("provincia",provincia);
//		cdo.addColValue("sigla",sigla);
//		cdo.addColValue("tomo",tomo); 
//		cdo.addColValue("asiento",asiento);
//		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
//		cdo.addColValue("num_empleado",numEmpleado);
	    cdo.addColValue("fecha",request.getParameter("dateRec"));
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
	       ItemRemoved = key;		 
		}
		else
		{
		   try{ 
				perHash.put(key,cdo);
			  }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
		}

	    if (!ItemRemoved.equals(""))
	    {
		   list.remove(perHash.get(ItemRemoved));
		   perHash.remove(ItemRemoved);	       
		   response.sendRedirect("../rhplanilla/empl_cambios_turno.jsp?change=1&perLastLineNo="+perLastLineNo+"&area="+area+"&seccion="+seccion+"&area="+area+"&grupo="+grupo);
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
		
		   perLastLineNo++;	
		   cdo2.addColValue("codigo",""+perLastLineNo);	
		   if (perLastLineNo < 10) key = "00" + perLastLineNo;
		   else if (perLastLineNo < 100) key = "0" + perLastLineNo;
		   else key = "" + perLastLineNo;
		 
		   perHash.put(key,cdo2);	

		   response.sendRedirect("../rhplanilla/empl_cambios_turno.jsp?change=1&perLastLineNo="+perLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo);
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
			cdo.setTableName("tbl_pla_ct_det_cambio_programa"); 
			//	cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area+" and provincia="+request.getParameter("provincia"+j)+" and sigla='"+request.getParameter("sigla"+j)+"' and tomo="+request.getParameter("tomo"+j)+" and asiento="+request.getParameter("asiento"+j)+" and num_empleado="+request.getParameter("numEmpleado"+j));
				
	cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("emp_id"+j));
			//	System.out.println("**eeeeeeeeeeeeeeeeeee**"+grupo+request.getParameter("provincia"+j)+request.getParameter("sigla"+j)+request.getParameter("asiento"+j)+request.getParameter("numEmpleado"+j)+request.getParameter("empId"+j)+request.getParameter("cod_turno_fin"+i)+request.getParameter("motivo"+i)+request.getParameter("fechaFin"+i)+request.getParameter("codTurno")+request.getParameter("fecha"+i)+request.getParameter("estado"+i)+request.getParameter("cod_turno_fin"+i)+request.getParameter("dateRec")+request.getParameter("codigo"+i)+request.getParameter("mes")+request.getParameter("anio")+request.getParameter("secuencia")+request.getParameter("anionew"+i)+request.getParameter("codPert")+request.getParameter("aprobado"));
							
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("anio",request.getParameter("anio"));
	cdo.addColValue("mes",request.getParameter("mes"));			
	cdo.addColValue("grupo",grupo);
	cdo.addColValue("codigo",request.getParameter("codigo"+i));
	cdo.setAutoIncCol("codigo");
	cdo.addColValue("motivo_cambio",request.getParameter("estado"+i));	
	cdo.addColValue("fecha_solicitud",request.getParameter("fecha"+i));		
	cdo.addColValue("provincia",request.getParameter("provincia"+j));
	cdo.addColValue("sigla",request.getParameter("sigla"+j));
	cdo.addColValue("tomo",request.getParameter("tomo"+j)); 
	cdo.addColValue("asiento",request.getParameter("asiento"+j));
	cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));
	cdo.addColValue("emp_id",request.getParameter("empId"+j));
	cdo.addColValue("turno_asignado",request.getParameter("cod_turno_fin"+i));
	cdo.addColValue("fecha_tasignado",request.getParameter("fechaFin"+i));
	cdo.addColValue("turno_nuevo",request.getParameter("codTurno"));
	cdo.addColValue("fecha_tnuevo",request.getParameter("fechaFin"+i));
	cdo.addColValue("fecha_creacion",request.getParameter("dateRec")); 
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",request.getParameter("dateRec"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("secuencia",request.getParameter("codigo"+i));
	cdo.setAutoIncCol("secuencia");	
	cdo.addColValue("observaciones",request.getParameter("motivo"+i));
	cdo.addColValue("num_empleado_ca",request.getParameter("codPert"));
	cdo.addColValue("anio_ca",request.getParameter("anionew"+i));
	cdo.addColValue("mes_ca",request.getParameter("mesnew"+i));
	cdo.addColValue("ta_programado","S");
	cdo.addColValue("tn_programado","S");
	cdo.addColValue("aprobado","N");
					
						 
				key = request.getParameter("key"+i); 
				perHash.put(key,cdo);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_cambios_turno.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_cambios_turno.jsp")%>';
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