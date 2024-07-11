<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.DetalleContrato"%>
<%@ page import="issi.contabilidad.Contrato"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ContrMgr" scope="page" class="issi.contabilidad.ContratoMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ContrMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);

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
document.title = 'Detalle Contrato - '+document.title;

function addTipoAlq(i)
{
  abrir_ventana1("detalle_tipoalquiler_list.jsp?indexCode=tipoAlqCode"+i+"&indexName=tipoAlq"+i);
}

function addAlquiler(i)
{
  abrir_ventana1("detalle_alquiler_list.jsp?indexCode=alquilerCode"+i+"&indexName=alquiler"+i);
}

function doSubmit()
{
	document.formDetalle.tipoClteCode.value = parent.document.form1.tipoClteCode.value;
	document.formDetalle.tipo.value = parent.document.form1.tipo.value; 
	document.formDetalle.tipoMoroso.value = parent.document.form1.tipoMoroso.value;
	document.formDetalle.morosidad.value = parent.document.form1.morosidad.value;
	document.formDetalle.estado.value = parent.document.form1.estado.value;
	document.formDetalle.clienteCode.value = parent.document.form1.clienteCode.value;
	document.formDetalle.contrato.value = parent.document.form1.contrato.value;  
	/* document.formDetalle.prov.value = parent.document.form1.prov.value;
	document.formDetalle.sigla.value = parent.document.form1.sigla.value;
	document.formDetalle.tomo.value = parent.document.form1.tomo.value;
	document.formDetalle.asiento.value = parent.document.form1.asiento.value;
	document.formdDetalle.noEmp.value = parent.document.form1.noEmp.value;*/
	document.formDetalle.fechaIni.value = parent.document.form1.fechaIni.value;
	document.formDetalle.fechaExp.value = parent.document.form1.fechaExp.value;    
	if (formDetalleValidation()) document.formDetalle.submit(); 
} 

function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
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
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>		
			<%=fb.hidden("baction", "")%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			<%=fb.hidden("tipoClteCode", "")%>
			<%=fb.hidden("tipo", "")%>
			<%=fb.hidden("tipoMoroso", "")%>
			<%=fb.hidden("morosidad", "")%>
			<%=fb.hidden("estado", "")%>
			<%=fb.hidden("clienteCode", "")%>			
			<%=fb.hidden("prov", "")%>
			<%=fb.hidden("sigla", "")%>
			<%=fb.hidden("tomo", "")%>
			<%=fb.hidden("asiento", "")%>
			<%=fb.hidden("noEmp", "")%>
			<%=fb.hidden("fechaIni", "")%>
			<%=fb.hidden("fechaExp", "")%>
			    
				<tr class="TextRow02">
					<td colspan="6" align="right">
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
					<td width="5%">Rengl&oacute;n</td>
					<td width="30%">Tipo Alquiler</td>
					<td width="35%">Tipo Cargo Fijo</td>							
					<td width="15%">Precio</td>
					<td width="10%">Cobrar?</td>
					<td width="5%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleContrato co = (DetalleContrato) HashDet.get(key);
					  					  
			    %>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("fechaCrea"+i,co.getFechaCrea())%><%=fb.hidden("userCrea"+i,co.getUserCrea())%><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	
					 <td><%=fb.textBox("secuencia"+i, co.getSecuencia(),false,false,false,5,"Text10",null,null)%></td>
					 <td><%=fb.intBox("tipoAlqCode"+i, co.getTipoAlqCode(),true,false,true,5,"Text10",null,null)%><%=fb.textBox("tipoAlq"+i, co.getTipoAlq(),false,false,true,27,"Text10",null,null)%><%=fb.button("btnTipoAlq"+i,"...",true,false,null,null,"onClick=\"javascript:addTipoAlq("+i+")\"")%></td>
					 <td><%=fb.intBox("alquilerCode"+i, co.getAlquilerCode(),true,false,true,5,"Text10",null,null)%><%=fb.textBox("alquiler"+i,co.getAlquiler(),false,false,true,34,"Text10",null,null)%><%=fb.button("btnAlquiler"+i,"...",true,false,null,null,"onClick=\"javascript:addAlquiler("+i+")\"")%></td>        
					 <td><%=fb.decBox("precio"+i, co.getPrecio(),false,false,false,11,"Text10",null,null)%>
					 <td><%=fb.select("estatus"+i,"I=Inactivo,A=Activo",co.getEstatus(),false,false,0,"Text10",null,null)%></td>
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>		
				 </tr>															

				<%				    
				     //Si error--, quita el error. Si error++, agrega el error. 
				     js += "if(document."+fb.getFormName()+".tipoAlqCode"+i+".value=='')error--;";
				     js += "if(document."+fb.getFormName()+".alquilerCode"+i+".value=='')error--;";
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
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	  String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	  code = request.getParameter("code");
	  
	    	   	   
	  for (int i=1; i<=keySize; i++)
	  {
	    DetalleContrato co = new DetalleContrato();

	    co.setSecuencia(request.getParameter("secuencia"+i));
		co.setTipoAlqCode(request.getParameter("tipoAlqCode"+i));
		co.setTipoAlq(request.getParameter("tipoAlq"+i));
		co.setAlquilerCode(request.getParameter("alquilerCode"+i));
		co.setAlquiler(request.getParameter("alquiler"+i));
		co.setPrecio(request.getParameter("precio"+i));
		co.setEstatus(request.getParameter("estatus"+i));
						
		co.setUserCrea(request.getParameter("userCrea"+i)); 
		co.setFechaCrea(request.getParameter("fechaCrea"+i));
		co.setUserMod(UserDet.getUserEmpId()); 
		co.setFechaMod(fecha);
		 
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 
		  ItemRemoved = key;			 
		}
		else
		{
	      try{ 
		       HashDet.put(key, co);
		       list.add(co);
		     }catch(Exception e){ System.err.println(e.getMessage()); }		    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     HashDet.remove(ItemRemoved);
		 response.sendRedirect("../contabilidad/detallecontrato_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&code="+code);
		 return;
	  }
	  		
	  if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("Agregar"))
	  {	
		DetalleContrato co = new DetalleContrato();
		co.setUserCrea(UserDet.getUserEmpId()); 
		co.setFechaCrea(fecha);
		co.setUserMod(UserDet.getUserEmpId()); 
		co.setFechaMod(fecha);
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		co.setSecuencia(""+lastLineNo);
		
		try{ 
		  HashDet.put(key, co);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../contabilidad/detallecontrato_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&code="+code);
		return;
	  }
		 Contrato contr = new Contrato();
		 
		 contr.setCompania((String) session.getAttribute("_companyId")); 
		 contr.setContrato(request.getParameter("code"));	 
		 contr.setTipoClteCode(request.getParameter("tipoClteCode"));
		 contr.setTipoContrCode(request.getParameter("tipo"));
		 contr.setTipoMoroso(request.getParameter("tipoMoroso"));
		 contr.setMorosidad(request.getParameter("morosidad"));		 
		 contr.setEstado(request.getParameter("estado"));
		 contr.setClienteCode(request.getParameter("clienteCode"));		 
		/* contr.setProvEmp(request.getParameter("prov"));
		 contr.setSiglaEmp(request.getParameter("sigla"));
		 contr.setTomoEmp(request.getParameter("tomo"));
		 contr.setAsientoEmp(request.getParameter("asiento"));
		 contr.setEmpCode(request.getParameter("noEmp")); */
		 contr.setFechaIni(request.getParameter("fechaIni"));
		 contr.setFechaExp(request.getParameter("fechaExp"));		 				
				
		 contr.setDetalle(list);
		 
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{		 
			contr.setUserCrea(UserDet.getUserEmpId());
			contr.setFechaCrea(fecha);
			contr.setUserMod(UserDet.getUserEmpId());
			contr.setFechaMod(fecha);					
			ContrMgr.add(contr);
			code = ContrMgr.getPkColValue("contrato");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{		    
			contr.setUserMod(UserDet.getUserEmpId());
			contr.setFechaMod(fecha);
			code = request.getParameter("code");
			contr.setContrato(code);	 
			ContrMgr.update(contr);
		}		
		ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form1.errCode.value = '<%=ContrMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=ContrMgr.getErrMsg()%>';
  parent.document.form1.code.value = '<%=code%>';
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