<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.Servicios"%>
<%@ page import="issi.facturacion.Puntos"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iServ" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="PtoMgr" scope="page" class="issi.facturacion.PuntosMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PtoMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
String code = "";
int lastLineNo = 0;

if (request.getParameter("mode") != null && !request.getParameter("mode").equals("")) mode = request.getParameter("mode");
else mode = "add";
if (request.getParameter("code") != null && !request.getParameter("code").equals("")) code = request.getParameter("code");
fb = new FormBean("formPuntos",request.getContextPath()+request.getServletPath(),FormBean.POST);

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
document.title = 'Servicios Relacionados - '+document.title;

function doSubmit()
{
   document.formPuntos.codCat.value = parent.document.form0.codCat.value;
   document.formPuntos.code.value = parent.document.form0.code.value;
   document.formPuntos.descripcion.value = parent.document.form0.descripcion.value;
   document.formPuntos.valor.value = parent.document.form0.valor.value;
   document.formPuntos.capCode.value = parent.document.form0.capCode.value;
   document.formPuntos.estado.value = parent.document.form0.estado.value;
   
   if (formPuntosValidation())
   {
     document.formPuntos.submit(); 
   } 
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
function addCentroServ(index)
{
   abrir_ventana2('../admision/habitacion_centroservicio_list.jsp?id=11&index='+index);
}
function addTipoServ(index)
{
   abrir_ventana2('../admision/habitacion_tiposervicio_list.jsp?id=6&index='+index);
}
function addArticulo(index)
{
   abrir_ventana2('../common/search_articulo.jsp?id=1&index='+index);
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
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("keySize",""+iServ.size())%>						
			<%=fb.hidden("descripcion", "")%>
			<%=fb.hidden("valor", "")%>
			<%=fb.hidden("capCode", "")%>
			<%=fb.hidden("estado", "")%>
			<%=fb.hidden("codCat", "")%>
			<%=fb.hidden("code", code)%>
			    
				<tr class="TextRow02">
					<td colspan="8" align="right">
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
					<td width="8%"><cellbytelabel>Sec</cellbytelabel>.</td>
					<td width="8%"><cellbytelabel>Cod.Serv</cellbytelabel></td>
					<td width="13%"><cellbytelabel>Centro</cellbytelabel></td>							
					<td width="13%"><cellbytelabel>Serv</cellbytelabel>.</td>
					<td width="8%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>					
					<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
					<td width="10%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(iServ);				
				    for (int i = 1; i <= iServ.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  Servicios serv = (Servicios) iServ.get(key);					  					  
			    %>		
				      <%=fb.hidden("codFlia"+i,serv.getCodFlia())%>
					  <%=fb.hidden("codClase"+i,serv.getCodClase())%>
					  <%=fb.hidden("fechaCreacion"+i,serv.getFechaCreacion())%>
					  <%=fb.hidden("usuarioCreacion"+i,serv.getUsuarioCreacion())%>
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	
					 <td><%=fb.intBox("secuencia"+i,serv.getSecuencia(),false,false,true,6)%></td>
					 <td><%=fb.intBox("codServ"+i,code,true,false,false,6,3)%></td>        
					 <td><%=fb.intBox("centroServicio"+i,serv.getCentroServicio(),false,false,false,9,5)%><%=fb.button("btnCentro","...",true,false,null,null,"onClick=\"javascript:addCentroServ("+i+")\"")%></td>
					 <td><%=fb.textBox("tipoServicio"+i,serv.getTipoServicio(),false,false,false,9,5)%><%=fb.button("btnTipoServ","...",true,false,null,null,"onClick=\"javascript:addTipoServ("+i+")\"")%></td>        
					 <td><%=fb.intBox("codArticulo"+i,serv.getCodArticulo(),false,false,true,8,10)%></td>
					 <td><%=fb.textBox("codArticuloDesc"+i,serv.getCodArticuloDesc(),false,false,true,34,50)%><%=fb.button("btnArticulo","...",true,false,null,null,"onClick=\"javascript:addArticulo("+i+")\"")%></td>
					 <td><%=fb.intBox("cantidad"+i,serv.getCantidad(),false,false,false,8,3)%></td>
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				 </tr>
				<%	
				     //Si error--, quita el error. Si error++, agrega el error. 
				     js += "if(document."+fb.getFormName()+".descripcion"+i+".value=='')error--;";
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
	  code = request.getParameter("code");
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	  String id = "";
	    	   	  
	 for (int i=1; i<=keySize; i++)
	  {
	    Servicios serv = new Servicios();

		serv.setSecuencia(request.getParameter("secuencia"+i));
		serv.setCodServ(request.getParameter("codServ"+i));
		serv.setCentroServicio(request.getParameter("centroServicio"+i));
		serv.setTipoServicio(request.getParameter("tipoServicio"+i));
		serv.setCodArticulo(request.getParameter("codArticulo"+i));
		serv.setCodArticuloDesc(request.getParameter("codArticuloDesc"+i));
		serv.setCodFlia(request.getParameter("codFlia"+i));
		serv.setCodClase(request.getParameter("codClase"+i));
		serv.setCantidad(request.getParameter("cantidad"+i));
        serv.setFechaCreacion(request.getParameter("fechaCreacion"+i));
        serv.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
		serv.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		serv.setUsuarioModificacion((String) session.getAttribute("_userName"));
				 
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iServ.put(key,serv);
		        list.add(serv);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     iServ.remove(ItemRemoved);
		 response.sendRedirect("../facturacion/serviciosrela_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&code="+code);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("Agregar"))
	  {	
		Servicios serv = new Servicios();
				
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		serv.setSecuencia(""+lastLineNo);
		serv.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		serv.setUsuarioCreacion((String) session.getAttribute("_userName"));
		
		try{ 
		     iServ.put(key,serv);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../facturacion/serviciosrela_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&code="+code);
		return;
	  }
		 Puntos pto = new Puntos();
		  
		 pto.setCodCat(request.getParameter("codCat")); 
		 pto.setCompania((String) session.getAttribute("_companyId")); 
		 pto.setDescripcion(request.getParameter("descripcion"));
		 if (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals(""))
		 pto.setValor(request.getParameter("valor"));
		 if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
		 pto.setEstado(request.getParameter("estado"));				
		 if (request.getParameter("capCode") != null && !request.getParameter("capCode").trim().equals(""))
		 pto.setCapCode(request.getParameter("capCode"));				
		 
		 pto.setServicios(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {	
		    pto.setUsuarioCreacion((String) session.getAttribute("_userName"));
			pto.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	    					
			PtoMgr.add(pto);
			id = PtoMgr.getPkColValue("codigo");
		 }
		 else
		 {	
		    pto.setUsuarioModificacion((String) session.getAttribute("_userName"));
			pto.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		    id = request.getParameter("code");
		    pto.setCodigo(id);	    
			PtoMgr.update(pto);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=PtoMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=PtoMgr.getErrMsg()%>';
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