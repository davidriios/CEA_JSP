<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.residencial.Suplente"%>
<%@ page import="issi.residencial.Custodio"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iSuple" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSuple" scope="session" class="java.util.Vector" />
<jsp:useBean id="CustoMgr" scope="page" class="issi.residencial.CustodioMgr" />
<%
/**
==================================================================================
==================================================================================                                          
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CustoMgr.setConnection(ConMgr);

CommonDataObject obj = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String modeCust = request.getParameter("modeCust");
String change = request.getParameter("change");
int cLastLineNo = 0;

if (tab == null) tab = "0";
if (request.getParameter("cLastLineNo") != null) cLastLineNo = Integer.parseInt(request.getParameter("cLastLineNo"));

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
document.title = 'Tabs Custodio - '+document.title;

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function addPlanHabit()
{
   abrir_ventana1('../common/check_planes_x_habitacion.jsp?modeAdm=<%=modeCust%>&fp=custodio&cLastLineNo=<%=cLastLineNo%>');
}
function doSubmit()
{ 
   if (form2Validation())
   {   
	   document.form2.secCustodio.value = parent.document.form2.secuencia.value;
	   document.form2.admisionC.value = parent.document.form2.admision.value;
	   document.form2.asientoC.value = parent.document.form2.asiento.value;
	   document.form2.tomoC.value = parent.document.form2.tomo.value;
	   document.form2.siglaC.value = parent.document.form2.sigla.value;
	   document.form2.provinciaC.value = parent.document.form2.prov.value;
	   document.form2.identificacionC.value = parent.document.form2.identificacion.value;
	   document.form2.primerApellidoC.value = parent.document.form2.primerApellido.value;
	   document.form2.apellidoCasadaC.value = parent.document.form2.apellidoCasada.value;
	   document.form2.segundoApellidoC.value = parent.document.form2.segundoApellido.value;
	   document.form2.estadoC.value = parent.document.form2.estado.value;
	   document.form2.direccionC.value = parent.document.form2.direccion.value;
	   document.form2.sexoC.value = parent.document.form2.sexo.value;
	   document.form2.parentescoC.value = parent.document.form2.parentesco.value;  
	   document.form2.ocupacionC.value = parent.document.form2.ocupacion.value;
	   document.form2.telefonoCasaC.value = parent.document.form2.telefonoCasa.value;
	   document.form2.telefonoOficinaC.value = parent.document.form2.telefonoOficina.value;
	   document.form2.faxC.value = parent.document.form2.fax.value;
	   document.form2.celularC.value = parent.document.form2.celular.value;
	   document.form2.apartadoC.value = parent.document.form2.apartado.value;
	   document.form2.emailC.value = parent.document.form2.email.value;
	   document.form2.observacionesC.value = parent.document.form2.observaciones.value;
	   document.form2.empresaC.value = parent.document.form2.empresa.value;
	   document.form2.primerNombreC.value = parent.document.form2.primerNombre.value;
	   document.form2.segundoNombreC.value = parent.document.form2.segundoNombre.value;
	  
	   document.form2.submit(); 
   }
} 
function addHab(i)
{
   abrir_ventana1('../common/search_cama.jsp?fp=planHabit&index='+i);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("modeCust",modeCust)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("iSupleSize",""+iSuple.size())%>
<%=fb.hidden("cLastLineNo",""+cLastLineNo)%>
<%=fb.hidden("secCustodio","")%>
<%=fb.hidden("admisionC","")%>
<%=fb.hidden("asientoC","")%>
<%=fb.hidden("tomoC","")%>
<%=fb.hidden("siglaC","")%>
<%=fb.hidden("provinciaC","")%>
<%=fb.hidden("identificacionC","")%>
<%=fb.hidden("primerApellidoC","")%>
<%=fb.hidden("apellidoCasadaC","")%>
<%=fb.hidden("segundoApellidoC","")%>
<%=fb.hidden("estadoC","")%>
<%=fb.hidden("direccionC","")%>
<%=fb.hidden("sexoC","")%>
<%=fb.hidden("parentescoC","")%>
<%=fb.hidden("ocupacionC","")%>
<%=fb.hidden("telefonoCasaC","")%>
<%=fb.hidden("telefonoOficinaC","")%>
<%=fb.hidden("faxC","")%>
<%=fb.hidden("celularC","")%>
<%=fb.hidden("apartadoC","")%>
<%=fb.hidden("emailC","")%>
<%=fb.hidden("observacionesC","")%>
<%=fb.hidden("empresaC","")%>
<%=fb.hidden("primerNombreC","")%>
<%=fb.hidden("segundoNombreC","")%>

<tr class="TextHeader" align="center">
	<td width="7%">Ced./Pasap.</td>
	<td width="26%">Nombres</td>
	<td width="30%">Apellidos</td>
	<td width="10%">Parentesco</td>
	<td width="7%">Tel&eacute;fono</td>
	<td width="8%">Celular</td>
	<td width="7%">Estado</td>
	<td width="5%"><%=fb.submit("addSuple","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
</tr>
<%
String js = "";	
al = CmnMgr.reverseRecords(iSuple);				
for (int i=1; i<=iSuple.size(); i++)
{
	key = al.get(i - 1).toString();									  
	Suplente spl = (Suplente) iSuple.get(key);
%>
<%=fb.hidden("secuencia"+i,spl.getSecuencia())%>
<%=fb.hidden("key"+i,spl.getKey())%>
<%=fb.hidden("supleCustodio"+i,spl.getSupleCustodio())%>
<%=fb.hidden("remove"+i,"")%>
<tr class="TextRow01">
	<td><%=fb.textBox("identificacion"+i,spl.getIdentificacion(),true,false,false,20,15)%></td>
	<td><%=fb.textBox("nombres"+i,spl.getNombres(),false,false,false,20,30)%></td>
	<td><%=fb.textBox("apellidos"+i,spl.getApellidos(),false,false,false,20,100)%></td>
	<td><%=fb.textBox("parentesco"+i,spl.getParentesco(),false,false,false,20,30)%></td>
	<td><%=fb.textBox("telefonoCasa"+i,spl.getTelefonoCasa(),false,false,false,10,10)%></td>
	<td><%=fb.textBox("telefonoCelular"+i,spl.getTelefonoCelular(),false,false,false,10,10)%></td>
	<td><%=fb.select("estado"+i,"A=Activo,I=Inactivo",spl.getEstado())%></td>
	<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
</tr>
<%
 //Si error--, quita el error. Si error++, agrega el error. 
 js += "if(document."+fb.getFormName()+".identificacion"+i+".value=='')error--;";
}
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");
%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	int size = 0;
	if (request.getParameter("iSupleSize") != null) size = Integer.parseInt(request.getParameter("iSupleSize"));
	String itemRemoved = "";
	String code = "";

	al.clear();

	for (int i=1; i<=size; i++)
	{
		Suplente spl = new Suplente();
        
		spl.setSecuencia(request.getParameter("secuencia"+i)); 
		spl.setKey(request.getParameter("key"+i));
		spl.setSupleCustodio(request.getParameter("supleCustodio"+i));
		spl.setIdentificacion(request.getParameter("identificacion"+i));	
		  
		if (request.getParameter("nombres"+i) != null && !request.getParameter("nombres"+i).trim().equals(""))
		{
			spl.setNombres(request.getParameter("nombres"+i));
		}
		if (request.getParameter("apellidos"+i) != null && !request.getParameter("apellidos"+i).trim().equals(""))
		{
			spl.setApellidos(request.getParameter("apellidos"+i));
		}		
		if (request.getParameter("parentesco"+i) != null && !request.getParameter("parentesco"+i).trim().equals(""))
		{
			spl.setParentesco(request.getParameter("parentesco"+i));
		}
		if (request.getParameter("telefonoCasa"+i) != null && !request.getParameter("telefonoCasa"+i).trim().equals(""))
		{
			spl.setTelefonoCasa(request.getParameter("telefonoCasa"+i));
		}
		if (request.getParameter("telefonoCelular"+i) != null && !request.getParameter("telefonoCelular"+i).trim().equals(""))
		{
			spl.setTelefonoCelular(request.getParameter("telefonoCelular"+i));
		}
		if (request.getParameter("estado"+i) != null && !request.getParameter("estado"+i).trim().equals(""))
		{
			spl.setEstado(request.getParameter("estado"+i));
		}		

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
			itemRemoved = spl.getKey();  
		else 
		{
			try
			{
				iSuple.put(spl.getKey(),spl);
				al.add(spl); 
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}	
    }
	
		if (!itemRemoved.equals(""))
		{
		  vSuple.remove(((Suplente) iSuple.get(itemRemoved)).getSupleCustodio());
    	  iSuple.remove(itemRemoved);

	      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?modeCust="+modeCust+"&cLastLineNo="+cLastLineNo); 
    	return;
		}

		if (baction != null && baction.equals("+"))
		{ 
		   Suplente spl = new Suplente();

           cLastLineNo++;
		   spl.setSecuencia(""+cLastLineNo); 


		   if (cLastLineNo < 10) key = "00"+cLastLineNo;
		   else if (cLastLineNo < 100) key = "0"+cLastLineNo;
		   else key = ""+cLastLineNo;
		   spl.setKey(key);

		   try
		   {
			  iSuple.put(key,spl);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

	      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?modeCust="+modeCust+"&cLastLineNo="+cLastLineNo);
    	return;
		}

		Custodio cust = new Custodio(); 

		cust.setSecuencia(request.getParameter("secCustodio"));
		cust.setAdmision(request.getParameter("admisionC"));
		cust.setIdentificacion(request.getParameter("identificacionC"));		
		cust.setAsientoR(request.getParameter("asientoC"));
		cust.setTomoR(request.getParameter("tomoC"));
		cust.setSiglaR(request.getParameter("siglaC"));
		cust.setProvinciaR(request.getParameter("provinciaC"));
		cust.setCiaR((String) session.getAttribute("_companyId"));
		
		if (request.getParameter("fNacimientoC")!= null && !request.getParameter("fNacimientoC").equals(""))
		cust.setFNacimiento(request.getParameter("fNacimientoC"));
		if (request.getParameter("primerApellidoC")!= null && !request.getParameter("primerApellidoC").trim().equals(""))
		cust.setPrimerApellido(request.getParameter("primerApellidoC"));
		if (request.getParameter("segundoApellidoC")!= null && !request.getParameter("segundoApellidoC").trim().equals(""))
		cust.setSegundoApellido(request.getParameter("segundoApellidoC"));
		if (request.getParameter("apellidoCasadaC")!= null && !request.getParameter("apellidoCasadaC").trim().equals(""))
		cust.setApellidoCasada(request.getParameter("apellidoCasadaC"));
		if (request.getParameter("estadoC")!= null && !request.getParameter("estadoC").trim().equals(""))
		cust.setEstado(request.getParameter("estadoC"));
		if (request.getParameter("direccionC")!= null && !request.getParameter("direccionC").trim().equals(""))
		cust.setDireccion(request.getParameter("direccionC"));
		if (request.getParameter("sexo")!= null && !request.getParameter("sexoC").trim().equals(""))
		cust.setSexo(request.getParameter("sexoC"));
		if (request.getParameter("parentescoC")!= null && !request.getParameter("parentescoC").trim().equals(""))
		cust.setParentesco(request.getParameter("parentescoC"));
		if (request.getParameter("ocupacionC")!= null && !request.getParameter("ocupacionC").trim().equals(""))
		cust.setOcupacion(request.getParameter("ocupacionC"));
		if (request.getParameter("telefonoCasaC")!= null && !request.getParameter("telefonoCasaC").trim().equals(""))
		cust.setTelefonoCasa(request.getParameter("telefonoCasaC"));
		if (request.getParameter("telefonoOficinaC")!= null && !request.getParameter("telefonoOficinaC").trim().equals(""))
		cust.setTelefonoOficina(request.getParameter("telefonoOficinaC"));
		if (request.getParameter("faxC")!= null && !request.getParameter("faxC").trim().equals(""))
		cust.setFax(request.getParameter("faxC"));
		if (request.getParameter("celularC")!= null && !request.getParameter("celularC").trim().equals(""))
		cust.setCelular(request.getParameter("celular"));
		if (request.getParameter("apartadoC")!= null && !request.getParameter("apartadoC").trim().equals(""))
		cust.setApartado(request.getParameter("apartadoC"));
		if (request.getParameter("emailC")!= null && !request.getParameter("emailC").trim().equals(""))
		cust.setEmail(request.getParameter("emailC"));
		if (request.getParameter("observacionesC")!= null && !request.getParameter("observacionesC").trim().equals(""))
		cust.setObservaciones(request.getParameter("observacionesC"));
		if (request.getParameter("primerNombreC")!= null && !request.getParameter("primerNombreC").trim().equals(""))
		cust.setPrimerNombre(request.getParameter("primerNombreC"));
		if (request.getParameter("segundoNombreC")!= null && !request.getParameter("segundoNombreC").trim().equals(""))
		cust.setSegundoNombre(request.getParameter("segundoNombreC"));
			
		cust.setSuplente(al);

		if (modeCust.equalsIgnoreCase("add"))
		{  	 
		   cust.setUsuarioCreacion(UserDet.getUserEmpId());
		   cust.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));		   
		   CustoMgr.add(cust);
		   code = CustoMgr.getPkColValue("secuencia");
	    }
		else if (modeCust.equalsIgnoreCase("edit"))
		{	    
		   cust.setUsuarioModificacion(UserDet.getUserEmpId());
		   cust.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		   CustoMgr.update(cust);
		}		
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form2.errCode.value = '<%=CustoMgr.getErrCode()%>';
  parent.document.form2.errMsg.value = '<%=CustoMgr.getErrMsg()%>';
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