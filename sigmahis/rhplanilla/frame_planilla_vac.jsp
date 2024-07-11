<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%--<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />--%>
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable"/>
<%
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800055") || SecMgr.checkAccess(session.getId(),"800056"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject desc= new CommonDataObject();
CommonDataObject cdo3 = new CommonDataObject();
CommonDataObject cdoTot = new CommonDataObject();
String sql="";
String key="";
String code= request.getParameter("emp_id");
String prov=request.getParameter("prov");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String por=request.getParameter("porc");
String des=request.getParameter("desc");
String emp_id = request.getParameter("emp_id");

ArrayList al= new ArrayList();
ArrayList al3= new ArrayList();
String change= request.getParameter("change");
//String fecha_inicial=
int desclastLineNo =0;

if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
		
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction();">
<script language="javascript">
document.title="Descuento de Empleados - Agregar - "+document.title;

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


function showFormula(res){

   if ( res != "" ){
   
      switch (res){
	  
	      case 'seguro_edu':
	         if ( document.getElementById("seguro_edu_f").style.display == "none"){
		          document.getElementById("seguro_edu_f").style.display=""; 
		     }else{document.getElementById("seguro_edu_f").style.display="none";}
		  break;
		  
		   case 'seguro_soc':
	         if ( document.getElementById("seguro_soc_f").style.display == "none"){
		          document.getElementById("seguro_soc_f").style.display=""; 
		     }else{document.getElementById("seguro_soc_f").style.display="none";}
		  break;
		  
		   case 'seguro_soc_gr':
	         if ( document.getElementById("seguro_soc_f2").style.display == "none"){
		          document.getElementById("seguro_soc_f2").style.display=""; 
		     }else{document.getElementById("seguro_soc_f2").style.display="none";}
		  break;
		  
		  case 'isr':
	         if ( document.getElementById("isr_f").style.display == "none"){
		          document.getElementById("isr_f").style.display=""; 
		     }else{document.getElementById("isr_f").style.display="none";}
		  break;
		  
		   case 'tot_aprox':
	         if ( document.getElementById("tot_aprox_f").style.display == "none"){
		          document.getElementById("tot_aprox_f").style.display=""; 
		     }else{document.getElementById("tot_aprox_f").style.display="none";}
		  break;
	 }//switch
   }//if res
}


function changeSalBase(){

    var sal_base = parseFloat(document.getElementById("salario_base").value);
	var xtra = parseFloat(document.getElementById("xtra").value);
	var otros_ing = parseFloat(document.getElementById("otros_ingresos").value);
	var aus_tar = parseFloat(document.getElementById("aus_tar").value);
	var otros_eg = parseFloat(document.getElementById("otros_egresos").value);
	
	var tmp_tot = sal_base + (xtra+otros_ing) - (aus_tar+otros_eg);
	document.getElementById("nuevo_sal_base").value = tmp_tot.toFixed(2);
 	doProcess(tmp_tot);
}

function doAction(){
	var sal_base = parseFloat(document.getElementById("salario_base").value);
	//doProcess(sal_base);
	
	newHeight();
}

function doProcess(sal,nl){
   
   if ( sal != null ){
   
   if (!nl){
      var nl = sal;
   }
   
    var seg_soc = document.getElementById("seg_soc").value;
	var seg_edu = document.getElementById("seg_edu").value;
	var gasto_rep = document.getElementById("gasto_rep").value;
	var seg_soc_gr = 0;
	var asterix = "*";
	var resaltar = "";
	var asterix2 = "*";
	var resaltar2 = "";
	var rango_renta = "";
	var isr = "";
	var pago_base = document.getElementById("pago_base").value;
	var rr = document.getElementById("rr").value;
	var isr = document.getElementById("imp_sr").value;
	var size = document.getElementById("size").value;
	var desc_v = 0;
	var tot_neto = 0;
	
	isr = (isr==""?0:isr);
	
	if ( gasto_rep == "" ){
	   gasto_rep = 0;
	}else{
	   gasto_rep = parseFloat(document.getElementById("gasto_rep").value);
	}
	
	var ss = (seg_soc/100) * sal;
	document.getElementById("seguro_social").innerHTML = ss.toFixed(2);
	document.getElementById("ss_q").innerHTML = (ss/2).toFixed(2);
	
	if (gasto_rep && gasto_rep > 0){
	
	 if ( gasto_rep > 0 && gasto_rep <= 2500){
	     seg_soc_gr = ((10/100)*(gasto_rep))*(9/100);
		 document.getElementById("gr_row1").style.backgroundColor = "#FF0";
		 document.getElementById("gr1").innerHTML  = "*";
		 document.getElementById("seguro_social_gr").innerHTML = seg_soc_gr.toFixed(2);
		 document.getElementById("ss_gr").innerHTML = (seg_soc_gr/2).toFixed(2);
		 document.getElementById("seguro_soc_f2").innerHTML = "Mensual   = (gasto rep. * (10/100)) * (9/100) <br />Quincenal   = [(gasto rep. * (10/100)) * (9/100)]/2"; 

	 }else
	 if ( gasto_rep > 25000 && gasto_rep <= 9999999 ){
	     seg_soc_gr = ((15/100)*(gasto_rep))*(9/100);
		 document.getElementById("gr_row2").style.backgroundColor = "#FF0";
		 document.getElementById("gr2").innerHTML  = "*";
		 document.getElementById("seguro_social_gr").innerHTML = seg_soc_gr.toFixed(2);
		 document.getElementById("ss_gr").innerHTML = (seg_soc_gr/2).toFixed(2);
		 document.getElementById("seguro_soc_f2").innerHTML = "Mensual   = (gasto rep. * (15/100)) * (9/100) <br />Quincenal   = [(gasto rep. * (15/100)) * (9/100)]/2"; 
		 
	 }
	}//if gasto_rep
	
	var se = (seg_edu/100) * sal;
	document.getElementById("seguro_edu").innerHTML = se.toFixed(2);
	document.getElementById("se_q").innerHTML = (se/2).toFixed(2);
	
	pago_base = (pago_base==""?0:pago_base);
	rango_renta = (nl*13) - pago_base;
	
	document.getElementById("rango_renta").innerHTML = rango_renta.toFixed(2);

	for ( i = 0; i<rr; i++){
		if (rango_renta > document.getElementById("ri"+i).value && rango_renta <= document.getElementById("rf"+i).value){
			document.getElementById("resaltar"+i).style.backgroundColor = "#FF0"; 
		}else{document.getElementById("resaltar"+i).style.backgroundColor = "";}
	}


    for ( p = 0; p<size; p++ ){
		desc_v += parseFloat(document.getElementById("desc_men"+p).value);
	}

   tot_neto = parseFloat(sal) - parseFloat(ss) - parseFloat(seg_soc_gr) - parseFloat(se) - parseFloat(isr) - parseFloat(desc_v);
   document.getElementById("tot_neto").innerHTML = tot_neto.toFixed(2);
   document.getElementById("tot_neto_q").innerHTML = (tot_neto/2).toFixed(2);
   
   //document.getElementById("nuevo_sal_base").value = nl.toFixed(2);
   
}//if sal not null
   
}

function printPagoEmp(opt){
   if ( opt ) {

   var salarioBase = parseFloat(document.getElementById("salario_base").value);
   
       var salarioBase = (document.getElementById("nuevo_sal_base")==null?0.0:document.getElementById("nuevo_sal_base").value);
	   var xtra = (document.getElementById("xtra")==null?0.0:document.getElementById("xtra").value);
	   var otrosIngresos = (document.getElementById("otros_ingresos")==null?0.0:document.getElementById("otros_ingresos").value);
	   var ausenciaTardanza = (document.getElementById("ausenciaTardanza")==null?0.0:document.getElementById("ausenciaTardanza").value);
	   var otrosEgresos = (document.getElementById("otros_egresos")==null?0.0:document.getElementById("otros_egresos").value);
	   var otrosEgresos = (document.getElementById("otros_egresos")==null?0.0:document.getElementById("otros_egresos").value);
	   var gastoRep = (document.getElementById("gastoRep")==null?0.0:document.getElementById("gastoRep").value);
	   
	   abrir_ventana("../rhplanilla/print_pago_empleado.jsp?print="+opt+"&empId=<%=emp_id%>&nsb="+salarioBase+"&xt="+xtra+"&oi="+otrosIngresos+"&at="+ausenciaTardanza+"&oe="+otrosEgresos+"&gr="+gastoRep);
	   }
}

</script>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("code",code)%>
	<%=fb.hidden("baction","")%> 
	<%=fb.hidden("salario_base",desc.getColValue("salario"))%>
	<tr>
		<td colspan="4" style="height:20px; text-align:right;" colspan="4" class="TextHeader02">
		<a href="javascript:printPagoEmp('pla_v');" class="Link03Bold">[Imprimir]</a></td>
	</tr>
	
	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
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
%>
