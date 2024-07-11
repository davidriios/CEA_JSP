<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.Factores"%>
<%@ page import="issi.expediente.DetalleFactor"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="FactMgr" scope="page" class="issi.expediente.FactorMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
FactMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("formFactor",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Detalle Factores - '+document.title;

function doSubmit()
{
   document.formFactor.factorDesc.value = parent.document.form0.descripcion.value;
   document.formFactor.id.value = parent.document.form0.id.value;
   document.formFactor.estado.value = parent.document.form0.estado.value;
   document.formFactor.fg.value = parent.document.form0.fg.value;
   <%if(fg.trim().equalsIgnoreCase("DO")){%>
   document.formFactor.presentar_check.value = parent.document.form0.presentar_check.value;
   <%}%>
   
   if (parent.document.form0.orden) document.formFactor.orden.value = parent.document.form0.orden.value
   if (parent.document.form0.habilitar_intervencion) document.formFactor.habilitar_intervencion.value = parent.document.form0.habilitar_intervencion.value

   if (formFactorValidation())
   {
     document.formFactor.submit(); 
   } 
}
/*function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}*/
function removeItem(fName,k)
{
	 var code =  parent.document.form0.id.value;
	 var subCode = eval('document.formFactor.secuencia'+k).value;
	 var existe = 0;
	 
	 //parent.form0BlockButtons(false);
	 
	  existe = getDBData('<%=request.getContextPath()%>',' count(*) existe','tbl_sal_det_escala_norton',' cod_concepto = '+code+' and cod_subconcepto = '+subCode+' ','');
		existe += getDBData('<%=request.getContextPath()%>',' count(*) existe','tbl_sal_detalle_esc',' cod_escala = '+code+' and detalle = '+subCode+' and tipo=\'<%=fg%>\' ','');

		if(existe >0)
		{
			alert('No se puede eliminar el registro.');
			return;
		}
		else
		{
			eval('document.formFactor.status'+k).value='D';
			var rem = eval('document.'+fName+'.rem'+k).value;
			eval('document.'+fName+'.remove'+k).value = rem;
			setBAction(fName,rem);
			document.formFactor.submit(); 
		}
	
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
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			<%=fb.hidden("factorDesc", "")%>
			<%=fb.hidden("estado", "")%>
			<%=fb.hidden("id", "")%>
			<%=fb.hidden("presentar_check", "")%>
			<%=fb.hidden("orden", "")%>
			<%=fb.hidden("habilitar_intervencion", "")%>
			<%=fb.hidden("fg", ""+fg)%>
			    
				<tr class="TextRow02">
					<td colspan="5" align="right">
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
					<td width="15%"><cellbytelabel id="1">Secuencia</cellbytelabel></td>
					<td width="45%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="3">Estado</cellbytelabel></td>								
					<td width="10%"><cellbytelabel id="4">Valor</cellbytelabel></td>					
					<td width="10%" align="center">Orden</td>
					<td width="5%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "",displayLine="";  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleFactor fa = (DetalleFactor) HashDet.get(key);	
							if((fa.getStatus()!=null && !fa.getStatus().trim().equals("")) && fa.getStatus().trim().equals("D"))displayLine="none";
								else displayLine=""; 				  					  
			    %>		
				 <tr class="TextRow01" style="display:<%=displayLine%>">
				 			<%=fb.hidden("key"+i,key)%>
							<%=fb.hidden("remove"+i,"")%>	
							<%=fb.hidden("status"+i,fa.getStatus())%>	
					 <td><%=fb.intBox("secuencia"+i,fa.getSecuencia(),false,false,true,15)%></td>
					 <td><%=fb.textBox("descripcion"+i,fa.getDescripcion(),true,false,false,85)%></td>   
					 <td align="center"><%=fb.select("estado"+i,"A= ACTIVO,I=INACTIVO",fa.getEstado(),false,false,0,"",null,"")%></td>				     
					 <td><%=fb.intBox("valor"+i,fa.getValor(),true,false,false,10,2)%>					
					 <td align="center"><%=fb.intBox("orden"+i,fa.getOrden(),false,false,false,5,2)%>					
					 <td align="right"><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				 </tr>
				<%	
				    if(!fa.getStatus().trim().equals("D")){
						 //Si error--, quita el error. Si error++, agrega el error. 
				     js += "if(document."+fb.getFormName()+".descripcion"+i+".value=='')error--;";
				     js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
						 }
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
	  String id = "";
	  HashDet.clear();
		   	  
	 for (int i=1; i<=keySize; i++)
	  {
	    DetalleFactor fa = new DetalleFactor();

	    fa.setSecuencia(request.getParameter("secuencia"+i));
			fa.setCodigo(request.getParameter("codigo"+i));
			fa.setDescripcion(request.getParameter("descripcion"+i));
			fa.setValor(request.getParameter("valor"+i));
			fa.setEstado(request.getParameter("estado"+i));
			fa.setStatus(request.getParameter("status"+i));
			fa.setOrden(request.getParameter("orden"+i));
			key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		/*else
		{*/
	      try{ 
		        HashDet.put(key, fa);
		        list.add(fa);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	   //}
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	    // HashDet.remove(ItemRemoved);
		 response.sendRedirect("../expediente/detallefactor_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&fg="+fg);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("Agregar"))
	  {	
		DetalleFactor fa = new DetalleFactor();
				
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		fa.setSecuencia("0");
		fa.setStatus("A");
		
		try{ 
		     HashDet.put(key, fa);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../expediente/detallefactor_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&fg="+fg);
		return;
	  }
		 Factores fact = new Factores();
		  
		 fact.setDescripcion(request.getParameter("factorDesc"));
		 fact.setEstado(request.getParameter("estado"));
		 fact.setTipo(request.getParameter("fg"));
		 fact.setPresentarCheck(request.getParameter("presentar_check")!=null?"Y":"N");
		 fact.setHabilitarInterv(request.getParameter("habilitar_intervencion")!=null&&!request.getParameter("habilitar_intervencion").equals("")?"Y":"N");
		 fact.setOrden(request.getParameter("orden"));
		 				
		 fact.setDetalle(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {		    					
			FactMgr.add(fact);
			id = FactMgr.getPkColValue("codigo");
		 }
		 else
		 {	
		    id = request.getParameter("id");
		    fact.setCodigo(id);	    
			FactMgr.update(fact);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
 <% if(FactMgr.getErrCode().trim().equals("1")){%>
	parent.document.form0.errCode.value = '<%=FactMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=FactMgr.getErrMsg()%>';
  parent.document.form0.id.value = '<%=id%>';
  
  parent.document.form0.submit(); 

<%} else{ %>//alert('error al guardar.... ');
parent.form0BlockButtons(false);
<%throw new Exception(FactMgr.getErrMsg());}%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>