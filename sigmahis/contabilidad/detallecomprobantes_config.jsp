<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.DetalleComprobante"%>
<%@ page import="issi.contabilidad.ComprobanteF"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ComprMgr" scope="page" class="issi.contabilidad.ComprobanteFMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ComprMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = ""; 
int lastLineNo = 0;
boolean viewMode = false;

if(mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;

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
document.title = 'Detalle Comprobante - '+document.title;

function addCuenta(i)
{
  abrir_ventana1('ctabancaria_catalogo_list.jsp?indexCta1=cta1'+i+'&indexCta2=cta2'+i+'&indexCta3=cta3'+i+'&indexCta4=cta4'+i+'&indexCta5=cta5'+i+'&indexCta6=cta6'+i+'&indexName=cuenta'+i+'&id=10');
}
function doSubmit()
{
   document.formDetalle.comprobante.value = parent.document.form0.comprobante.value;
   document.formDetalle.descripcion.value = parent.document.form0.descripcion.value; 
   document.formDetalle.clase_comprob.value = parent.document.form0.clase_comprob.value;     
   document.formDetalle.estado.value = parent.document.form0.estado.value;            
   if (formDetalleValidation())document.formDetalle.submit();
   else {parent.form0BlockButtons(false);
	formDetalleBlockButtons(false);}
   
}
function doAction()
{
  <%if(!mode.trim().equals("view")){%>parent.form0BlockButtons(false);<%}%>
   newHeight();calc(false);
}
function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var totalDb=0.00,totalCr=0.00;
	var size=parseInt(document.formDetalle.keySize.value,10);
	var x=0;
	for(i=1;i<=size;i++)
	{
		if(eval('document.formDetalle.action'+i).value!='D' && eval('document.formDetalle.estado'+i).value!='I')
		{
			var typeMov=eval('document.formDetalle.ladoMov'+i).value;
			var valor=0.0;
			if(eval('document.formDetalle.monto'+i).value!='')valor=parseFloat(eval('document.formDetalle.monto'+i).value);
			
			if(typeMov=='DB')totalDb+=valor;
			else totalCr+=valor;
			if(eval('document.formDetalle.cta1'+i).value=='' && document.formDetalle.baction.value=='Guardar'){x++;top.CBMSG.warning('Existen registros con cuentas Incorrectas!. Favor Verifique.');break;return false;}
		}
	}

	//parent.document.form0.sumDebito.value=(totalDb).toFixed(2);
	//parent.document.form0.sumCredito.value=(totalCr).toFixed(2);
	parent.document.form0.totalDb.value=(totalDb).toFixed(2);
	parent.document.form0.totalCr.value=(totalCr).toFixed(2);
	totalDb=(totalDb).toFixed(2);
	totalCr=(totalCr).toFixed(2);
	if(totalDb!=totalCr)
	{
		if(showAlert)top.CBMSG.warning('El Comprobante no está Balanceado');
		return false;
	}
	else if(totalDb==totalCr&&totalDb==0.00)
	{
		if(showAlert)top.CBMSG.warning('El Balance no puede ser igual a Cero (0)');
		return false;
	}
	return true;
}

function removeItemComp(k)
{
	removeItem('formDetalle',k);
	parent.form0BlockButtons(true);
	formDetalleBlockButtons(true);
	document.formDetalle.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
<%fb.appendJsValidation("\n\tif(document."+fb.getFormName()+".baction.value!='Guardar') return true;");%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("comprobante", "")%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			<%=fb.hidden("descripcion", "")%>
			<%=fb.hidden("clase_comprob", "")%>
			<%=fb.hidden("estado", "")%>    
				<tr class="TextRow02">
					<td colspan="6" align="right"><%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>					 
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					
					<td width="55%">Cuenta</td>
					<td width="5%">Lado Mov.</td>							
					<td width="8%">Monto</td>
					<td width="24%">Nota</td>
					<td width="5%">Estado</td>
					<td width="3%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "";		
									  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleComprobante co = (DetalleComprobante) HashDet.get(key);	
					  String color = "";
						if (i%2 == 0) color = "TextRow02";
						else color = "TextRow01";
					  String style = (co.getAction().equalsIgnoreCase("D"))?" style=\"display:none\"":"";	
					  			  					  
			    %>		
				<%=fb.hidden("key"+i,co.getKey())%>
				<%=fb.hidden("renglon"+i,co.getRenglon())%>
				<%=fb.hidden("action"+i,co.getAction())%>
				<%=fb.hidden("other1"+i,co.getOther1())%>
				<%=fb.hidden("remove"+i,"")%>
				
				<tr class="<%=color%>" <%=style%> >
				<%=fb.hidden("fechaCrea"+i,co.getFechaCrea())%><%=fb.hidden("userCrea"+i,co.getUserCrea())%>
					<td><%=fb.textBox("cta1"+i,co.getCta1(),true,false,true,3)%><%=fb.textBox("cta2"+i,co.getCta2(),true,false,true,3)%><%=fb.textBox("cta3"+i,co.getCta3(),true,false,true,3)%><%=fb.textBox("cta4"+i,co.getCta4(),true,false,true,3)%><%=fb.textBox("cta5"+i,co.getCta5(),true,false,true,3)%><%=fb.textBox("cta6"+i,co.getCta6(),true,false,true,3)%><%=fb.textBox("cuenta"+i,co.getCuenta(),true,false,true,50)%>
					<%=fb.button("btncuenta"+i,"...",true,(viewMode ||(co.getOther1().trim().equals("S"))),null,null,"onClick=\"javascript:addCuenta("+i+")\"")%></td>
					<td><%=fb.select("ladoMov"+i,"CR=CR,DB=DB",co.getLadoMov(),false,(viewMode ||(co.getOther1().trim().equals("S"))),1,"Text10","","onChange=\"javascript:calc(false)\"")%></td> 					 
					<td><%//=fb.decBox("monto"+i,co.getMonto(),true,false,viewMode,10,"Text10",null,"onChange=\"javascript:calc(false)\"")%>
					<%=fb.decPlusZeroBox("monto"+i,co.getMonto(),true,false,(viewMode ||(co.getOther1().trim().equals("S"))),8,"10.2","Text10",null,"onChange=\"javascript:calc(false)\"","Monto",false,"")%>
					
					</td>	        
					<td><%=fb.textBox("nota"+i,co.getNota(),false,(viewMode),false,35,200)%></td>
					<td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",co.getEstado(),false,false,0)%></td>
					<td align="right"><%//=fb.submit("remove"+i,"X",false,false)%>
					<%=fb.button("rem"+i,"X",true,(viewMode ||(co.getOther1().trim().equals("S"))),null,null,"onClick=\"javascript:removeItemComp("+i+")\"","Eliminar Cuenta")%>
					
					</td>		
				</tr>
				<%					     
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
	  int size=Integer.parseInt(request.getParameter("keySize"));	   
	  mode = request.getParameter("mode"); 
	  ArrayList list = new ArrayList();	  
	  String itemRemoved = "";
	  String code = "";
	  String baction = request.getParameter("baction");
	  String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	  ComprobanteF compr = new ComprobanteF();
		 
		 compr.setComprobante(request.getParameter("comprobante"));	 
		 compr.setDescripcion(request.getParameter("descripcion"));
		 compr.setOther1(request.getParameter("clase_comprob"));
		 compr.setEstado(request.getParameter("estado"));
		 compr.setUserMod((String) session.getAttribute("_userName")); 	
		 				 
	 
	 HashDet.clear();   
	 compr.getDetalle().clear();	   
	 	  
	 for (int i=1; i<=size; i++)
	  {
	    DetalleComprobante co = new DetalleComprobante();

	    co.setKey(request.getParameter("key"+i));
		co.setRenglon(request.getParameter("renglon"+i));
		co.setCta1(request.getParameter("cta1"+i));
		co.setCta2(request.getParameter("cta2"+i));
		co.setCta3(request.getParameter("cta3"+i));
		co.setCta4(request.getParameter("cta4"+i));
		co.setCta5(request.getParameter("cta5"+i));
		co.setCta6(request.getParameter("cta6"+i));
		co.setCuenta(request.getParameter("cuenta"+i));		
		co.setLadoMov(request.getParameter("ladoMov"+i));
		co.setMonto(request.getParameter("monto"+i));
		co.setNota(request.getParameter("nota"+i));
		co.setEstado(request.getParameter("estado"+i));
		co.setOther1(request.getParameter("other1"+i));
						
		co.setUserCrea(request.getParameter("userCrea"+i)); 
		co.setFechaCrea(request.getParameter("fechaCrea"+i));
		co.setUserMod((String) session.getAttribute("_userName"));
		co.setFechaMod(cDateTime);		
		co.setAction(request.getParameter("action"+i));
		
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = co.getKey();
			if (co.getAction().equalsIgnoreCase("I")) co.setAction("X");//if it is not in DB then remove it
			else co.setAction("D");
		}
		
		if (!co.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				HashDet.put(co.getKey(),co);
				compr.getDetalle().add(co);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}
		
	  }	
	
	  if (!itemRemoved.equals(""))
	  {
	     //HashDet.remove(itemRemoved);
		 response.sendRedirect("../contabilidad/detallecomprobantes_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		DetalleComprobante co = new DetalleComprobante();
		
		co.setUserCrea((String) session.getAttribute("_userName")); 
		co.setFechaCrea(cDateTime);
		co.setUserMod((String) session.getAttribute("_userName")); 
		co.setFechaMod(cDateTime);
				
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		co.setAction("I");
		co.setRenglon("0");
		co.setKey(key);
		
		try{ 
		     HashDet.put(co.getKey(),co);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../contabilidad/detallecomprobantes_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		return;
	  }
		
		 
		 if (mode.equalsIgnoreCase("add"))
		 {	
		    compr.setCompania((String) session.getAttribute("_companyId"));
			compr.setUserCrea((String) session.getAttribute("_userName")); 						
			ComprMgr.add(compr);
			
			code = ComprMgr.getPkColValue("codigo");
		 }
		 else
		 {	
		    compr.setCompania((String) session.getAttribute("_companyId"));
			compr.setFechaMod(cDateTime);
			compr.setComprobante(request.getParameter("comprobante"));
			code=request.getParameter("comprobante");
			ComprMgr.update(compr);		   
		 }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=ComprMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=ComprMgr.getErrMsg()%>';
  parent.document.form0.comprobante.value = '<%=code%>';
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