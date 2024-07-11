<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetalleTransFormaPagos"%>




<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashFormPago" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFacturas" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String cantidad = request.getParameter("cantidad");
String key = "";
String sql = "";
int lastLineNo = 0;
int keySize =  0;
int items = 0;
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
document.title = 'Formas de Pago - '+document.title;
function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function setBAction(fName,actionValue){
  var size = <%=HashFormPago.size()%>;
  var cantidad = '<%=cantidad%>';
  if(cantidad=='') cantidad = 0.00;
  cantidad = parseFloat(cantidad);
  var acumCant = 0.00;
  vcount = 0;
  for(i=0;i<size;i++){
    tipo_tarjeta = eval('document.form0.tipo_tarjeta'+i).value;
    num_cheque = eval('document.form0.num_cheque'+i).value;
    banco = eval('document.form0.descripcion_banco'+i).value;
	if(isNaN(eval('document.form0.monto'+i).value)){alert('Valor invalido. Por Favor Revise - '+eval('document.form0.monto'+i).value);break;}
    else acumCant += parseFloat(eval('document.form0.monto'+i).value);
		var fp_codigo = eval('document.form0.fp_codigo'+i).value;
    if(fp_codigo == '2' && num_cheque == ''){
      alert('Introduzca Número de Cheque!');
      vcount++;
      break;
    } else if(fp_codigo == '2' && banco == ''){
      alert('Introduzca Descripción de Banco!');
      vcount++;
      break;
    } else if(fp_codigo == '3' && tipo_tarjeta == ''){
      alert('Seleccione Tipo de Tarjeta!');
      vcount++;
      break;
    }
  }
  
  if(acumCant.toFixed(2)!=cantidad.toFixed(2) && actionValue == "Guardar") alert('La suma de los montos no concuerda con la introducida en la ventana anterior!');
  else if(vcount!=0){}
  else {
  if(actionValue == "Guardar")document.form0.monto.value='0';
    document.forms[fName].baction.value = actionValue;
  if(form0Validation()){document.form0.submit();}else return false;
  }
}

function removeItem(fName,k)
{
  var rem = eval('document.'+fName+'.rem'+k).value;
  eval('document.'+fName+'.remove'+k).value = rem;
  setBAction(fName,rem);
}

function tcredito(k){
  var selObj = document.getElementById('fp_codigo'+k);
  var selectedArray = new Array();    
  var i;
  var count = 0;
  //----------------------------------------------------------------------------
  for (i=0; i<selObj.options.length; i++) {
    if (selObj.options[i].selected) {
      selectedArray[count] = selObj.options[i].value;
      count++;
    }
  }
  if(selectedArray!=3){
    document.getElementById('tipo_tarjeta'+k).options[0].selected=true;
    document.getElementById('tipo_tarjeta'+k).disabled=true; 
  } else {
    document.getElementById('tipo_tarjeta'+k).disabled=false; 
  }
  //------------------------------------------------------------------------------
}

function formCredito(){
  //var items = parseInt(document.getElementById("items").value);
  var items = <%=HashFormPago.size()%>;
  for(k=0; k<items; k++){ 
    //tcredito(k);  
  }
}

function addBilletes(){ 
  abrir_ventana2('../caja/billetes_list.jsp?');
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
<% if(lastLineNo==0){ lastLineNo=HashFormPago.size(); } %>
<%=fb.formStart(true)%> 
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+HashFormPago.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cantidad",cantidad)%>
<tr class="TextHeader" align="center">
  <td width="15%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
  <td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
  <td width="20%"><cellbytelabel>Tarjetas de Cr&eacute;dito</cellbytelabel> </td>
  <td width="10%"><cellbytelabel>Num. Documento</cellbytelabel></td>                  
  <td width="20%"><cellbytelabel>Banco</cellbytelabel></td>
  <td width="10%">&nbsp;</td>
  <td width="3%"></td>
</tr>
<tr class="TextHeader02">
  <%
  sql = "SELECT codigo, descripcion||' - '||codigo, codigo FROM tbl_cja_forma_pago";
  %>
  <td><%=fb.select(ConMgr.getConnection(),sql,"fp_codigo","",false,false,0,"Text10",null,"onChange=\"javascript:tcredito('');\" ")%></td>
  <td><%=fb.decBox("monto","", true, false,false,10,"Text10","","")%></td>
  <td>
  <%
  sql = "SELECT codigo, descripcion||' - '||codigo, codigo FROM tbl_cja_tipo_tarjeta";
  %>
  <%=fb.select(ConMgr.getConnection(),sql,"tipo_tarjeta","",false,false,0,"Text10",null,null,null,"S")%>  </td>        
  <td><%=fb.textBox("num_cheque","", false, false,false,15,"Text10","","")%></td>
  <td align="center"><%=fb.textBox("descripcion_banco","", false, false,false,20,"Text10","","")%></td>
  <td><%=fb.select("tipo_banco","L=LOCAL,E=EXTRANJERO","")%></td>
  <td align="center">
  <%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Adicionar Elemento")%>
  </td>
</tr>
<%
al2 = CmnMgr.reverseRecords(HashFormPago);        
for (int i = 0; i < HashFormPago.size(); i++) {
  items++;
  key = al2.get(i).toString();
  DetalleTransFormaPagos dtfp = (DetalleTransFormaPagos) HashFormPago.get(key);
%>
<%=fb.hidden("key"+i,key)%>
<%=fb.hidden("remove"+i,"")%>

<tr class="TextRow01">
  <td><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM tbl_cja_forma_pago ","fp_codigo"+i,""+dtfp.getFpCodigo(),false,false,0,"Text10",null,"onChange=\"javascript:tcredito('"+i+"');\" ")%></td>
  <td><%=fb.decBox("monto"+i,dtfp.getMonto(), true, false,false,10,12.2,"Text10","","")%></td>
  <td>
  <%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM tbl_cja_tipo_tarjeta","tipo_tarjeta"+i,""+dtfp.getTipoTarjeta(),false,false,0,"Text10",null,null,null,"S")%>  </td>        
  <td><%=fb.textBox("num_cheque"+i,dtfp.getNumCheque(), false, false,false,15,"Text10","","")%></td>
  <td align="center"><%=fb.textBox("descripcion_banco"+i,dtfp.getDescripcionBanco(), false, false,false,20,"Text10","","")%></td>
  <td><%=fb.select("tipo_banco"+i,"L=LOCAL,E=EXTRANJERO",dtfp.getTipoBanco())%></td>
  <td align="center">
  <%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%>
  </td>
</tr>
<%  }  %>
<%=fb.hidden("items",""+items)%>
 <tr class="TextRow01">
   <td>&nbsp;</td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
   <td><cellbytelabel>Total</cellbytelabel>:</td>
   <td align="center">&nbsp;</td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
 </tr>
 <tr class="TextRow01">
   <td colspan="7" align="right">
   <%=fb.button("btnBilletes","Denominaciones",false,false,"Text10",null,"onClick=\"javascript:addBilletes()\"")%>
   <%=fb.button("guardar","Guardar",false,false,"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Guardar")%>
   <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
   </td>
   </tr>

<%=fb.hidden("size",""+HashFormPago.size())%>
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
  keySize = Integer.parseInt(request.getParameter("keySize"));


//===================== inicio del ciclo FOR ==========================
  if (baction.equals("+")){ 
  //keySize++; 
  /*HashFormPago.clear();*/ 
  }

  DetalleTransFormaPagos dtfp = new DetalleTransFormaPagos();

  for (int i=0; i<keySize; i++){
    key = request.getParameter("key"+i);
    dtfp = new DetalleTransFormaPagos();
    dtfp.setFpCodigo(""+request.getParameter("fp_codigo"+i));
    dtfp.setTipoTarjeta(""+request.getParameter("tipo_tarjeta"+i));
    dtfp.setTipoBanco(""+request.getParameter("tipo_banco"+i));
    if (request.getParameter("monto"+i) != null) { dtfp.setMonto(""+request.getParameter("monto"+i)); } else { dtfp.setMonto(""); }
    if (request.getParameter("num_cheque"+i) != null) { dtfp.setNumCheque(""+request.getParameter("num_cheque"+i)); } else { dtfp.setNumCheque(""); }
    if (request.getParameter("descripcion_banco"+i) != null) { dtfp.setDescripcionBanco(""+request.getParameter("descripcion_banco"+i)); } else { dtfp.setDescripcionBanco(""); }
    dtfp.setKey(request.getParameter("key"+i));

    if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = dtfp.getKey();
    else {
      try { //-- Agregar elemento al Hashtable      
            if (!(baction.equalsIgnoreCase("X"))){ HashFormPago.put(key, dtfp); 
          }
      } catch(Exception e){ 
        System.err.println(e.getMessage()); 
      } 
    }
  }
//===================== FIN del ciclo FOR =============================


  if (baction != null && baction.equals("+")){
    //DetalleTransFormaPagos dtfp = new DetalleTransFormaPagos();
    dtfp = new DetalleTransFormaPagos();
    dtfp.setFpCodigo(""+request.getParameter("fp_codigo"));
    dtfp.setTipoTarjeta(""+request.getParameter("tipo_tarjeta"));
    dtfp.setTipoBanco(""+request.getParameter("tipo_banco"));
    
    if (request.getParameter("monto") != null) dtfp.setMonto(""+request.getParameter("monto")); 
    else dtfp.setMonto("");
    if (request.getParameter("num_cheque") != null) dtfp.setNumCheque(""+request.getParameter("num_cheque"));
    else dtfp.setNumCheque("");
    if (request.getParameter("descripcion_banco") != null) dtfp.setDescripcionBanco(""+request.getParameter("descripcion_banco"));
    else dtfp.setDescripcionBanco("");
    
    dtfp.setKey(request.getParameter("key"));
    lastLineNo++;
    //spl.setSecuencia(""+cLastLineNo);     
    if (lastLineNo < 10) key = "00"+lastLineNo;
    else if (lastLineNo < 100) key = "0"+lastLineNo;
    else key = ""+lastLineNo;
    dtfp.setKey(key);

    try {
      HashFormPago.put(key, dtfp);
    } catch(Exception e) {
      System.err.println(e.getMessage());
    }
    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp=recibos&lastLineNo="+lastLineNo+"&cantidad="+cantidad);
    return;
  }

  if (!itemRemoved.equals("")){ //-- Elimina elemento del Hashtable
    HashFormPago.remove(itemRemoved);
    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&fp=recibos&lastLineNo="+lastLineNo+"&cantidad="+cantidad);
    return;
  }
  
  //response.sendRedirect(request.getContextPath()+request.getServletPath());

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
  window.opener.document.form0.forma_pago.value = '<%=HashFormPago.size()%>';
  window.opener.document.form0.forma_pago_monto.value = '<%=cantidad%>';
  window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>