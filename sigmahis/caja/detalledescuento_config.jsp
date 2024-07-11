<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.DetalleDescuento"%>
<%@ page import="issi.caja.Descuento"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="DescMgr" scope="page" class="issi.caja.DescuentoMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
DescMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String descCode = request.getParameter("descCode");
String centroCode = request.getParameter("centroCode");
String tipoCdsCode = request.getParameter("tipoCdsCode");
String servicioCode = "";
String servicio = "";
String servKey = "";
String key = "";
String sql = "";
String filter = " and recibe_mov='S'";
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
document.title = 'Detalle Descuento - '+document.title;
function addTipoServ(i)
{
  eval('document.formDetalle.servicioCode'+i).value = "";
  eval('document.formDetalle.servicio'+i).value = "";
}
function addServicio(i)
{
  var tipoServCode="";
  var centroCode="";
  var tipoCdsCode="";
  
  tipoServCode = eval('document.formDetalle.tipo_servicio'+i).value;  
  centroCode = parent.document.form1.centroCode.value;
  tipoCdsCode = parent.document.form1.tipoCdsCode.value;
  abrir_ventana1("detalledescuento_list.jsp?tipoServCode="+tipoServCode+"&i="+i+"&centroCode=<%=centroCode%>&tipoCdsCode=<%=tipoCdsCode%>");
}
function doSubmit()
{
  if (parent.document.form1.centroCode.value == null || parent.document.form1.centroCode.value == "")
  {
     alert('Debe Seleccionar el Centro de Servicio');
	 return;
  }else{
		   document.formDetalle.descuento.value = parent.document.form1.descCode.value;
		   document.formDetalle.centro_servicio.value = parent.document.form1.centroCode.value;
		   
		   document.formDetalle.dcta1.value = parent.document.form1.cta1.value;
		   document.formDetalle.dcta2.value = parent.document.form1.cta2.value;
		   document.formDetalle.dcta3.value = parent.document.form1.cta3.value;
		   document.formDetalle.dcta4.value = parent.document.form1.cta4.value;
		   document.formDetalle.dcta5.value = parent.document.form1.cta5.value;
		   document.formDetalle.dcta6.value = parent.document.form1.cta6.value;  
		   document.formDetalle.submit(); 
       }		   
}
function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
function add()
{
  if (parent.document.form1.centroCode.value == null || parent.document.form1.centroCode.value == "")
  {
     alert('Debe Seleccionar el Centro de Servicio Primero!');
	 return;
  }else{
         document.formDetalle.descuento.value = parent.document.form1.descCode.value;
		 document.formDetalle.centro_servicio.value = parent.document.form1.centroCode.value;
		 document.formDetalle.tipoCdsCode.value = parent.document.form1.tipoCdsCode.value;
  		 document.formDetalle.action.value="addCol";
         document.formDetalle.submit();
	   }	 
}
function del(i)
{
  document.formDetalle.action.value="remove"+i;
  document.formDetalle.submit();
}
function addCuenta(index)
{
  abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=19&index='+index+'&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}

function doAction()
{
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>		
			<%=fb.hidden("lastLineNo", ""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("descuento", descCode)%>
			<%=fb.hidden("keySize", ""+HashDet.size())%>			
			<%=fb.hidden("centro_servicio", centroCode)%>
			<%=fb.hidden("tipoCdsCode", tipoCdsCode)%>
			<%=fb.hidden("action", "")%>
			<%=fb.hidden("dcta1", "")%>
			<%=fb.hidden("dcta2", "")%>
			<%=fb.hidden("dcta3", "")%>
			<%=fb.hidden("dcta4", "")%>
			<%=fb.hidden("dcta5", "")%>
			<%=fb.hidden("dcta6", "")%>
			    
				<tr class="TextRow02">
					<td colspan="5" align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
					//	{
					%>					    
					     <%=fb.button("addCol","Agregar",false,false,null,null,"onClick=\"javascript:add()\"")%>				 
					<%
					   // }
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="25%"><cellbytelabel>Tipo Servicio</cellbytelabel></td>
					<td width="24%"><cellbytelabel>Servicio</cellbytelabel></td>							
					<td width="43%"><cellbytelabel>Cta. Contable</cellbytelabel></td>
					<td width="8%">&nbsp;</td>
				</tr>			
				<%			  
				  if (HashDet.size() > 0) 
				  {  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleDescuento co = (DetalleDescuento) HashDet.get(key);
					  					  
			    %>		
				<%=fb.hidden("secuencia"+i,co.getSecuencia())%>
				<tr class="TextRow01"><%=fb.hidden("key"+i,key)%>					
					<td><%=fb.select(ConMgr.getConnection(),"SELECT codigo, codigo||'-'||descripcion FROM tbl_cds_tipo_servicio ORDER BY descripcion","tipo_servicio"+i,co.getTipoServCode(),false,false,0,"Text10",null,"onChange=\"javascript:addTipoServ("+i+")\"")%></td>
					<%=fb.hidden("procedimiento"+i,co.getProceCode())%><%=fb.hidden("otros_cargos"+i,co.getOtrosCargosCode())%><%=fb.hidden("cds_producto"+i,co.getProductoCode())%><%=fb.hidden("cod_uso"+i,co.getUsoCode())%>
					<%=fb.hidden("proceName"+i,co.getProce())%><%=fb.hidden("otrosCargosName"+i,co.getOtrosCargos())%><%=fb.hidden("productoName"+i,co.getProducto())%><%=fb.hidden("usoName"+i,co.getUso())%>
					<% 
					   if (co.getProceCode()!= null && !co.getProceCode().equals(""))
					   {  
					      System.out.println("if co.getProceCode()!= null && !co.getProceCode().equals()");
					      servicioCode = co.getProceCode();	
						  servicio = co.getProce();						   
						  servKey ="1";					   
					   }
					   else if (co.getOtrosCargosCode()!= null && !co.getOtrosCargosCode().equals(""))
						    {
							   System.out.println("if co.getOtrosCargosCode()!= null && !co.getOtrosCargosCode().equals()");
							   servicioCode = co.getOtrosCargosCode();  
							   servicio = co.getOtrosCargos();
							   servKey ="2";
							}	 
					        else if (co.getProductoCode()!= null && !co.getProductoCode().equals(""))
								 {
								    System.out.println("if co.getProductoCode()!= null && !co.getProductoCode().equals()");
									servicioCode = co.getProductoCode();  
									servicio = co.getProducto();
									servKey ="3";
								 }
								 else if (co.getUsoCode()!= null && !co.getUsoCode().equals(""))
									  {	
									     System.out.println("if co.getUsoCode()!= null && !co.getUsoCode().equals()"); 
										 servicioCode = co.getUsoCode();  
										 servicio = co.getUso();
										 servKey ="4";
									  } 
					 %>
					 <%=fb.hidden("servKey"+i,servKey)%>
					 <td><%=fb.textBox("servicioCode"+i,servicioCode,true,false,true,1,"Text10",null,null)%><%=fb.textBox("servicio"+i,servicio,false,false,true,20,"Text10",null,null)%><%=fb.button("btnServicio"+i,"...",false,false,null,null,"onClick=\"javascript:addServicio("+i+")\"")%></td>        
					 <td><%=fb.textBox("cta1"+i,co.getCta1(),false,false,true,1,"Text10",null,null)%><%=fb.textBox("cta2"+i,co.getCta2(),false,false,true,1,"Text10",null,null)%><%=fb.textBox("cta3"+i,co.getCta3(),false,false,true,1,"Text10",null,null)%><%=fb.textBox("cta4"+i,co.getCta4(),false,false,true,1,"Text10",null,null)%><%=fb.textBox("cta5"+i,co.getCta5(),false,false,true,1,"Text10",null,null)%><%=fb.textBox("cta6"+i,co.getCta6(),false,false,true,1,"Text10",null,null)%><%=fb.textBox("cuenta"+i,co.getCuenta(),false,false,true,20,"Text10",null,null)%><%=fb.button("btncuenta"+i,"...",false,false,null,null,"onClick=\"javascript:addCuenta("+i+")\"")%></td>					 
					 <td align="right"><%=fb.button("remove"+i,"Eliminar",false,false,null,null,"onClick=\"javascript:del("+i+")\"")%></td>		
				 </tr>															

				<%	
				    servicioCode = "";
					servicio = "";
				    }				  
				  }	
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
	  descCode = request.getParameter("descuento");
	  centroCode = request.getParameter("centro_servicio");
	  tipoCdsCode = request.getParameter("tipoCdsCode");
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	    	   	  
	 for (int i=1; i<=keySize; i++)
	 {  	  		
	    DetalleDescuento co = new DetalleDescuento();

	  /*  cdo3.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and centro_servicio="+centroCode+" and descuento="+descCode);
		co.setAutoIncWhereClause("cg_compania="+(String) session.getAttribute("_companyId"));*/
		co.setDescCode(descCode);
		co.setCentroCode(centroCode);
	    co.setSecuencia(request.getParameter("secuencia"+i));
		co.setTipoServCode(request.getParameter("tipo_servicio"+i));
		co.setCompania((String) session.getAttribute("_companyId"));		
		
		if (request.getParameter("servKey"+i).equals("1"))
		{
		co.setProceCode(request.getParameter("procedimiento"+i));
		co.setProce(request.getParameter("proceName"+i));		
		}else if (request.getParameter("servKey"+i).equals("2"))
		{
		co.setOtrosCargosCode(request.getParameter("otros_cargos"+i));	
		co.setOtrosCargos(request.getParameter("otrosCargosName"+i));	
		}else if (request.getParameter("servKey"+i).equals("3"))
		{		
		co.setProductoCode(request.getParameter("cds_producto"+i));	
		co.setProducto(request.getParameter("productoName"+i));	
		}else if (request.getParameter("servKey"+i).equals("4"))
		{		
		co.setUsoCode(request.getParameter("cod_uso"+i));
		co.setUso(request.getParameter("usoName"+i));
		}
				
		co.setCta1(request.getParameter("cta1"+i));	
		co.setCta2(request.getParameter("cta2"+i));	
		co.setCta3(request.getParameter("cta3"+i));		
		co.setCta4(request.getParameter("cta4"+i));		
		co.setCta5(request.getParameter("cta5"+i));		
		co.setCta6(request.getParameter("cta6"+i));
		co.setCuenta(request.getParameter("cuenta"+i));
				 
	    key = request.getParameter("key"+i);
		
		if (!request.getParameter("action").equals("remove"+i))
		{ 
		
		try{ 
		  HashDet.put(key, co);
		  list.add(co);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		 }
		 else
		 {
	      ItemRemoved = key;			    	       
	     }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     HashDet.remove(ItemRemoved);
		 response.sendRedirect("../caja/detalledescuento_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&descCode="+descCode+"&centroCode="+centroCode+"&tipoCdsCode="+tipoCdsCode);
		 return;
	  }
	  		
	  if (request.getParameter("action").equals("addCol"))
	  {	
	   
		DetalleDescuento co = new DetalleDescuento();		
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		co.setSecuencia(""+lastLineNo);
		
		try{ 
		    HashDet.put(key, co);		
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		    response.sendRedirect("../caja/detalledescuento_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&descCode="+descCode+"&centroCode="+centroCode+"&tipoCdsCode="+tipoCdsCode);
		return;
	  }
		 Descuento desc = new Descuento();
		 		 
		 desc.setDescCode(descCode);	 
		 desc.setCentroCode(centroCode);	 
		 desc.setCompania((String) session.getAttribute("_companyId"));
		 desc.setCta1(request.getParameter("dcta1"));
		 desc.setCta2(request.getParameter("dcta2"));
		 desc.setCta3(request.getParameter("dcta3"));
		 desc.setCta4(request.getParameter("dcta4"));
		 desc.setCta5(request.getParameter("dcta5"));
		 desc.setCta6(request.getParameter("dcta6"));		 				
				
		 desc.setDetalle(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {
			desc.setUserCrea(UserDet.getUserEmpId());
			desc.setFechaCrea(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			desc.setUserMod(UserDet.getUserEmpId());
			desc.setFechaMod(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));					
			DescMgr.add(desc);
		 }
		 else
		 {
			desc.setUserMod(UserDet.getUserEmpId());
			desc.setFechaMod(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			DescMgr.update(desc);
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form1.errCode.value = '<%=DescMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=DescMgr.getErrMsg()%>';
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