<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Delivery"%>
<%@ page import="issi.inventory.DeliveryItem"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="DelMgr" scope="page" class="issi.inventory.DeliveryMgr" />
<jsp:useBean id="DI" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="del" scope="page" class="issi.inventory.Delivery" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="iActivos" scope="session" class="java.util.Hashtable" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdo3 = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
DeliveryItem act = new DeliveryItem();
String mode = request.getParameter("mode");
String costo = request.getParameter("costo");
String articulo = request.getParameter("articulo");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String index = request.getParameter("index");
String descripcion = request.getParameter("descripcion");
String compania =(String) session.getAttribute("_companyId");
String actCodProveedor =request.getParameter("actCodProveedor");
String actVidaUtil =request.getParameter("actVidaUtil");
String actPlaca =request.getParameter("actPlaca");
String actDescProveedor =request.getParameter("actDescProveedor");
String actNumFactura = request.getParameter("actNumFactura");
String key = "";
String sql = "";
int lastLineNo = 0,cantidad=0,cantidadOld=0;
int keySize =  0;
int dif=0;
int items = 0;
System.out.println(">>>>iActivos.size()>>>>"+iActivos.size()+">>>>cantidad>>>>"+cantidad);
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
if (request.getParameter("cantidad") != null && !request.getParameter("cantidad").equals("")) cantidad = Integer.parseInt(request.getParameter("cantidad"));
if (request.getParameter("cantidadOld") != null && !request.getParameter("cantidadOld").equals("")) cantidadOld = Integer.parseInt(request.getParameter("cantidadOld"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
  	sql ="select to_char(LPAD("+compania+",2,0)||LPAD("+articulo+",2,0)||(select to_char(nvl(max(to_number(secuencia_placa)),0)+1) from tbl_con_temp_activo where compania = "+compania+" )) nuevaPlaca from  dual ";
 cdo3 = SQLMgr.getData(sql);
  
 if(articulo!=null&&!articulo.trim().equals("")&&iActivos.size()!=0)
 {
 	if(cantidad > cantidadOld)dif=cantidad-cantidadOld;
	for (int i =0;i<cantidadOld;i++)
	{System.out.println(">>>>"+cantidad);
		if(i < cantidad){
			act = (DeliveryItem)iActivos.get(articulo+"_"+i); 
			al2.add(act);
		}
		else iActivos.remove(articulo+"_"+i);
	} 
	if(dif !=0){
	
		for(int j= 0;j<dif; j++)
		{
			al2.add(act);
		}
	
	}
}
	/*if(cantidadOld ==0)
	{
		for (int i =0;i<cantidad;i++)
		{
			 act = new DeliveryItem();
			 al2.add(act);
		}
	}*/

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle de Activos Fijos - '+document.title;
function setActiveDetails(k,codArticulo){var aplicar='';if(document.form0.checkAplicar.checked==true){aplicar='T';}abrir_ventana1('../inventario/active_details.jsp?fg=ACT&index='+k+'&codArticulo='+codArticulo+'&cantidad=<%=cantidad%>&aplicar='+aplicar);}
function setBAction(fName,actionValue)
{
  document.forms[fName].baction.value = actionValue;
  if(form0Validation()){
		
 if(document.form0.actNumFactura.value!='')parent.window.frames['itemFrame'].document.form1.actNumFactura<%=index%>.value =document.form0.actNumFactura.value;
 if(document.form0.actCodProveedor.value!='')parent.window.frames['itemFrame'].document.form1.actCodProveedor<%=index%>.value =document.form0.actCodProveedor.value;
 if(document.form0.actDescProveedor.value!='')parent.window.frames['itemFrame'].document.form1.actDescProveedor<%=index%>.value =document.form0.actDescProveedor.value;
 if(document.form0.actPlaca.value!='')parent.window.frames['itemFrame'].document.form1.actPlaca<%=index%>.value =document.form0.actPlaca.value;
 if(document.form0.actVidaUtil.value!='')parent.window.frames['itemFrame'].document.form1.actVidaUtil<%=index%>.value =document.form0.actVidaUtil.value;
  parent.window.frames['itemFrame'].document.form1.cantidadOld<%=index%>.value =<%=cantidad%> ;
  document.form0.submit();}else return false;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"><!-- onLoad="javascript:formCredito()"-->
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="FORMAS DE PAGO"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableBorder">

<table align="center" width="100%" cellpadding="0" cellspacing="1">   
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%> 
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+iActivos.size())%>
<%=fb.hidden("alSize",""+al2.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cantidad",""+cantidad)%>
<%=fb.hidden("index",""+index)%>
<%=fb.hidden("actCodProveedor",""+actCodProveedor)%>
<%=fb.hidden("actVidaUtil",""+actVidaUtil)%>
<%=fb.hidden("actPlaca",""+actPlaca)%>
<%=fb.hidden("actDescProveedor",""+actDescProveedor)%>
<%=fb.hidden("actNumFactura",""+actNumFactura)%>
<%=fb.hidden("articulo",""+articulo)%>

<tr class="TextRow02">
					<td colspan="4">SIGUIENTE SECUENCIA DE PLACAS AUTOMATICAS: <font color="#FF0000" size="+3"><%=cdo3.getColValue("nuevaPlaca")%></font>(compañia + codigo de articulo + Secuencia de activo)</td>
					<td colspan="3"><%=fb.checkbox("checkAplicar","",true,false,null,null,"")%><font color="#FF0000" size="+1">APLICAR PARA TODOS LOS REGISTROS:</font></td>
				</tr>
<tr class="TextHeader" align="center">
  <td width="10%"><cellbytelabel>Articulo</cellbytelabel></td>
  <td width="25%"><cellbytelabel>Descripcion</cellbytelabel></td>
  <td width="25%"><cellbytelabel>Proveedor</cellbytelabel></td>
  <td width="10%"><cellbytelabel>No. Factura</cellbytelabel> </td>
  <td width="10%"><cellbytelabel>Vida Util</cellbytelabel></td>                  
  <td width="10%"><cellbytelabel>No. Placa</cellbytelabel></td>
  <td width="10%"><cellbytelabel>No. Serie</cellbytelabel></td>
</tr>
<%
for (int i = 0; i < al2.size(); i++) { 
  DeliveryItem di = (DeliveryItem)al2.get(i);
%>
<%=fb.hidden("familyCode"+i,familia)%>
<%=fb.hidden("classCode"+i,clase)%>
<%=fb.hidden("itemCode"+i,articulo)%>
<%=fb.hidden("description"+i,descripcion)%>
<%=fb.hidden("cost"+i,costo)%>

<tr class="TextRow01">
  <td><%=familia+"-"+clase+"-"+articulo%></td>
  <td><%=descripcion%></td>
  <td align="center"><%=fb.textBox("actCodProveedor"+i,""+di.getActCodProveedor(),true,false,true,15)%><%=fb.textBox("actDescProveedor"+i,""+di.getActDescProveedor(),false,false,true,20)%>
  <%=fb.button("activo"+i,"...",false,false,null,null,"onClick=\"javascript:setActiveDetails("+i+","+articulo+")\"")%>
  </td>
  <td align="center"><%=fb.textBox("actNumFactura"+i,""+di.getActNumFactura(),true,false,true,15)%></td>
  <td align="center"><%=fb.intBox("actVidaUtil"+i,""+di.getActVidaUtil(),true,false,true,5)%></td>
  <td align="center"><%=fb.textBox("actPlaca"+i,""+di.getActPlaca(),false,false,false,10)%></td>
  <td align="center"><%=fb.textBox("actSerie"+i,""+di.getActSerie(),false,false,false,10,100)%></td>
</tr>
<%  }  %>
 
 <tr class="TextRow01">
   <td colspan="7" align="right">
   <%=fb.button("guardar","Guardar",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Guardar")%>
   <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false)\"")%>
   </td>
   </tr>

<%=fb.formEnd(true)%>     
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>

</td>
</tr>
</table>

<%@ include file="../common/footer.jsp"%>

</body>
</html>
<%
}//GET
else
{ 
  String itemRemoved = "";
  String baction = request.getParameter("baction");
  lastLineNo  = Integer.parseInt(request.getParameter("lastLineNo"));
  keySize = Integer.parseInt(request.getParameter("alSize")); //Integer.parseInt(request.getParameter("keySize"));

  DeliveryItem di = new DeliveryItem();
  iActivos.remove(articulo);   
  for (int i=0; i<keySize; i++){
    di = new DeliveryItem();
   		di.setFamilyCode(request.getParameter("familyCode"+i));
		di.setClassCode(request.getParameter("classCode"+i));
		di.setItemCode(request.getParameter("itemCode"+i));
		di.setDescription(request.getParameter("description"+i));
		di.setCost(request.getParameter("cost"+i));
		if(request.getParameter("actNumFactura"+i)!=null && !request.getParameter("actNumFactura"+i).equals("")) di.setActNumFactura(request.getParameter("actNumFactura"+i));
		else di.setActNumFactura("null");
		di.setActCodProveedor(request.getParameter("actCodProveedor"+i));
		di.setActPlaca(request.getParameter("actPlaca"+i));
		if(request.getParameter("actVidaUtil"+i)!=null && !request.getParameter("actVidaUtil"+i).equals("")) di.setActVidaUtil(request.getParameter("actVidaUtil"+i));
		else di.setActVidaUtil("null");
		if(request.getParameter("actSerie"+i)!=null && !request.getParameter("actSerie"+i).equals("")) di.setActSerie(request.getParameter("actSerie"+i));
		else di.setActSerie("null");
		if(request.getParameter("actDescProveedor"+i)!=null && !request.getParameter("actDescProveedor"+i).equals("")) di.setActDescProveedor(request.getParameter("actDescProveedor"+i));
		else di.setActDescProveedor("");

   
      try { //-- Agregar elemento al Hashtable   
	  		iActivos.remove(articulo+"_"+i);   
			iActivos.put(articulo+"_"+i,di); 
			//System.out.println("size ===   ="+iActivos.size()); 
      } catch(Exception e){ 
        System.err.println("erroro ="+e.getMessage()); 
      }  
  }
//===================== FIN del ciclo FOR =============================

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
  //window.opener.document.form1.actSize<%=index%>.value = '<%=keySize%>';
  //window.close();
  parent.window.frames['itemFrame'].document.form1.actSize<%=index%>.value = '<%=keySize%>';
  parent.hidePopWin(false);
  
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>