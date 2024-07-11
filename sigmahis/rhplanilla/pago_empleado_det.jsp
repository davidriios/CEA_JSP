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

String code= request.getParameter("emp_id");
String emp_id = request.getParameter("emp_id");

ArrayList al= new ArrayList();
ArrayList al3= new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET"))
{
desc.addColValue("fecha_inicial",CmnMgr.getCurrentDate("dd/mm/yyyy"));

//saca datos para el encabezado
sql = "SELECT e.num_empleado,TO_CHAR(e.provincia,'09') AS primero, e.sigla AS segundo, TO_CHAR(e.tomo,'09999') AS tercero, TO_CHAR(e.asiento,'099999') AS cuarto, e.primer_nombre AS nameprimer, e.primer_apellido AS Apellido, e.unidad_organi, TO_CHAR(e.salario_base,'999,999,990.00') AS salario, TO_CHAR(e.rata_hora,'990.00') AS rata, u.descripcion AS unidad, uf.descripcion ubic_fisica, NVL(e.gasto_rep,0) gastoRep  FROM TBL_PLA_EMPLEADO e, TBL_SEC_UNIDAD_EJEC u, TBL_SEC_UNIDAD_EJEC uf  WHERE e.unidad_organi=u.codigo(+) AND e.compania=u.compania(+) AND e.compania = "+(String) session.getAttribute("_companyId")+" AND e.emp_id = "+code+" AND uf.codigo = e.ubic_fisica AND e.compania = uf.compania(+)";

desc = SQLMgr.getData(sql); 

if ( desc == null ) desc = new CommonDataObject();

//saca datos de los descuentos, los porcentajes 

sql = "SELECT e.emp_id,p.seg_soc_emp seguro_social, p.seg_edu_emp seguro_edu, e.tipo_pla, d.cod_acreedor, d.descuento_mensual, d.descuento1, a.nombre_corto, a.tipo_cuenta, Get_Valor_Deuda_Porc(e.emp_id)AS porc_deuda, c.clave, c.pago_base, Getcalcular_Isr(c.clave,e.num_dependiente,e.salario_base,e.compania) impuesto_sr   FROM TBL_PLA_DESCUENTO d, TBL_PLA_ACREEDOR a, TBL_PLA_EMPLEADO e, TBL_PLA_PARAMETROS p, TBL_PLA_CLAVE_RENTA c WHERE e.compania = "+(String) session.getAttribute("_companyId")+" AND e.tipo_pla = 1  AND e.emp_id = "+emp_id+" AND e.estado <> 3 AND d.cod_compania = e.compania AND e.emp_id = d.emp_id AND a.cod_acreedor = d.cod_acreedor AND d.estado = 'D' AND p.cod_compania = e.compania and e.tipo_renta = c.clave";

al = SQLMgr.getDataList(sql);


cdoTot = SQLMgr.getData("SELECT NVL(SUM(x.descuento_mensual),0) tot_desc_mes, NVL(SUM(x.descuento1),0) tot_desc_quin FROM (("+sql+")x)");

al3 = SQLMgr.getDataList("SELECT rango_inicial_real ri, rango_final rf, porcentaje porc, cargo_fijo cf FROM TBL_PLA_RANGO_RENTA");
			
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
	         if ( document.getElementById("seguro_soc_gr_f").style.display == "none"){
		          document.getElementById("seguro_soc_gr_f").style.display="block"; 
		     }else{document.getElementById("seguro_soc_gr_f").style.display="none";}
		  break;
		  
		  case 'monto_an':
	         if ( document.getElementById("monto_an_f").style.display == "none"){
		          document.getElementById("monto_an_f").style.display=""; 
		     }else{document.getElementById("monto_an_f").style.display="none";}
		  break;
		  
		   case 'tot_aprox':
	         if ( document.getElementById("tot_aprox_f").style.display == "none"){
		          document.getElementById("tot_aprox_f").style.display=""; 
		     }else{document.getElementById("tot_aprox_f").style.display="none";}
		  break;
		  
		  case 'isr':
	         if ( document.getElementById("isr_f").style.display == "none"){
		          document.getElementById("isr_f").style.display=""; 
		     }else{document.getElementById("isr_f").style.display="none";}
		  break;
		  
		   case 'isr_gr':
	         if ( document.getElementById("isr_gr_f").style.display == "none"){
		          document.getElementById("isr_gr_f").style.display=""; 
		     }else{document.getElementById("isr_gr_f").style.display="none";}
		  break;
	 }//switch
   }//if res
}


function mostrarEsconder(pla,f){

	if ( !f ){
	   var f = "";
	}

	if ( pla != "" ){
		
		var planilla = document.getElementById("planilla"+pla);
		var plus = document.getElementById("plus"+pla);
		
		if ( planilla && plus ) {
		
		if ( planilla.style.display == "none" ){
		     planilla.style.display = "block";
			 
			 if(f !=""){
			    autoResizer(f);
			 }
			 
			 plus.innerHTML = "[-]";
		}else{planilla.style.display = "none"; plus.innerHTML = "[+]";}
	}//if not null
	
	}//if planilla and plus
}


function autoResizer(f){
//f = iframe
   var new_height;
   var new_width;
      
   if ( f != null || f != "" ){
   
   if (document.getElementById){
   		new_height=document.getElementById(f).contentWindow.document.body.scrollHeight;
		new_width=document.getElementById(f).contentWindow.document.body.scrollWidth;
   }
   document.getElementById(f).height = (new_height)+"px";
   }
   
}

function changeSalBase(){

// RECALCULAMOS EL NUEVO SALARIO SI EL USUARIO LLENA LOS CAMPOS DE DATOS EXTRAS
// isr = impuesto sobre la renta

    var salarioBase = parseFloat(document.getElementById("salario_base").value);
	var xtra = (document.getElementById("xtra").value==""?0:document.getElementById("xtra").value);
	var otrosIngresos = (document.getElementById("otros_ingresos").value==""?0:document.getElementById("otros_ingresos").value)
	var ausenciaTardanza = (document.getElementById("ausenciaTardanza").value==""?0:document.getElementById("ausenciaTardanza").value);
	var otrosEgresos = (document.getElementById("otros_egresos").value==""?0:document.getElementById("otros_egresos").value);
	
	// RELLENA EL CAMPO SI EL USUARIO BORRA EL VALOR Y NO INTRODUZCA NADA
	if (xtra == "") document.getElementById("xtra").value = "0.00";
	if (otrosIngresos == "") document.getElementById("otros_ingresos").value = "0.00";
	if (ausenciaTardanza == "") document.getElementById("ausenciaTardanza").value = "0.00";
	if (otrosEgresos == "") document.getElementById("otros_egresos").value = "0.00";
	
	var tmp_tot = salarioBase + ( parseFloat(xtra) + parseFloat(otrosIngresos) ) - ( parseFloat(ausenciaTardanza) + parseFloat(otrosEgresos) );
	
	document.getElementById("nuevo_sal_base").value = tmp_tot.toFixed(2);
	document.getElementById("new_sal_base").innerHTML = tmp_tot.toFixed(2);

    doProcess(tmp_tot);
}

function doAction(){
	var salarioBase = parseFloat(document.getElementById("salario_base").value);
	doProcess(salarioBase);
	
	//newHeight();

}

function doProcess(sal,nuevoSalBase){
// sal = salario base
//nuevoSalBase = nuevo salario base
   
   if ( sal != null ){
   
   if (!nuevoSalBase){
      var nuevoSalBase = sal;
   }
   
    var seguroSocial = (document.getElementById("seguroSocial")==null?0.0:document.getElementById("seguroSocial").value);
	var seguroEducativo = (document.getElementById("seguroEducativo")==null?0.0:document.getElementById("seguroEducativo").value);
	var gastoRep = (document.getElementById("gastoRep")==null?0.0:document.getElementById("gastoRep").value);
	var isrGrep = 0;
	var seguroSocialGastoRep = 0;
	var asterix = "*";
	var resaltar = "";
	var asterix2 = "*";
	var resaltar2 = "";
	var rangoRenta = "";
	var isr = '0';
	var pagoBase = (document.getElementById("pagoBase")==null?0.0:document.getElementById("pagoBase").value);
	var rangoRentaSize = (document.getElementById("rangoRentaSize")==null?0.0:document.getElementById("rangoRentaSize").value);
	var size = (document.getElementById("size")==null?0.0:document.getElementById("size").value);
	var descuentosVoluntarios = 0;
	var tot_neto = 0;
	
	if ( gastoRep == "" ){
	   gastoRep = 0;
	}else{
	   gastoRep = parseFloat(document.getElementById("gastoRep").value);
	}
	
	//ss = seguro social
	var ss = (seguroSocial/100) * sal;
	if (document.getElementById("seguro_social")){
		document.getElementById("seguro_social").innerHTML = ss.toFixed(2);
		document.getElementById("ss_q").innerHTML = (ss/2).toFixed(2);
	}

	if (gastoRep && gastoRep > 0){
	 if ( (gastoRep*13) > 0 && (gastoRep*13) <= 25000){
	     seguroSocialGastoRep = ((gastoRep*9)/100);
		 isrGrep = ((gastoRep*10)/100);
		 document.getElementById("gr_row1").style.backgroundColor = "#FF0";
		 document.getElementById("gr1").innerHTML  = "*";
		 document.getElementById("seguro_social_gr").innerHTML = seguroSocialGastoRep.toFixed(2);
		 document.getElementById("ss_gr").innerHTML = (seguroSocialGastoRep/2).toFixed(2);
		 document.getElementById("t_isr_gr").innerHTML = (isrGrep).toFixed(2);
		 document.getElementById("t_isr_gr_q").innerHTML = (isrGrep/2).toFixed(2);
         document.getElementById("isr_gr_f").firstChild.innerHTML = "Mensual = (gasto rep. * 10 / 100)<br />Quincenal = Mensual / 2";
	 }else
	 if ( (gastoRep*13) > 25000 && (gastoRep*13) <= 9999999 ){
	     seguroSocialGastoRep = ((gastoRep*9)/100);
		 isrGrep = ((gastoRep*15)/100);
		 document.getElementById("gr_row2").style.backgroundColor = "#FF0";
		 document.getElementById("gr2").innerHTML  = "*";
		 document.getElementById("seguro_social_gr").innerHTML = seguroSocialGastoRep.toFixed(2);
		 document.getElementById("ss_gr").innerHTML = (seguroSocialGastoRep/2).toFixed(2);
		document.getElementById("isr_gr_f").firstChild.innerHTML = "Mensual = (gasto rep. * 15 / 100)<br />Quincenal = Mensual / 2";
	 }
	}//if gastoRep
	
	//ss = seguro educativo
	var se = (seguroEducativo/100) * sal;
	if ( document.getElementById("seguro_edu")){
		document.getElementById("seguro_edu").innerHTML = se.toFixed(2);
		document.getElementById("se_q").innerHTML = (se/2).toFixed(2);
	}
	
	pagoBase = (pagoBase==""?0:pagoBase);
	rangoRenta = (nuevoSalBase*13) - pagoBase;
	
	if (document.getElementById("rangoRenta")){
		document.getElementById("rangoRenta").innerHTML = rangoRenta.toFixed(2);
	}

	for ( i = 0; i<rangoRentaSize; i++){
		if (rangoRenta > document.getElementById("ri"+i).value && rangoRenta <= document.getElementById("rf"+i).value){
//alert(document.getElementById("ri"+i).value);
			isr = splitRows(getDBData('<%=request.getContextPath()%>','Getcalcular_Isr(tipo_renta,num_dependiente,'+sal+',<%=(String) session.getAttribute("_companyId")%>) imp_renta','tbl_pla_empleado','emp_id=<%=emp_id%>'));
			if ( isr != "" ){
				document.getElementById("t_isr").innerHTML = Number(isr).toFixed(2);
				document.getElementById("t_isr_q").innerHTML = Number(isr/2).toFixed(2);
				document.getElementById("imp_sr").value = Number(isr).toFixed(2);
			}
			document.getElementById("resaltar"+i).style.backgroundColor = "#FF0"; 
		}else{document.getElementById("resaltar"+i).style.backgroundColor = "";}
	}


    for ( p = 0; p<size; p++ ){
		descuentosVoluntarios += parseFloat(document.getElementById("desc_men"+p).value);
	}

   tot_neto = parseFloat(sal) - parseFloat(ss) - parseFloat(se) - parseFloat(isr) - parseFloat(descuentosVoluntarios);
   
   if ( document.getElementById("tot_neto")){
		document.getElementById("tot_neto").innerHTML = tot_neto.toFixed(2);
		document.getElementById("tot_neto_q").innerHTML = (tot_neto/2).toFixed(2);
    }
   
   //document.getElementById("nuevo_sal_base").value = nuevoSalBase.toFixed(2);
   //alert(sal);
   
}//if sal not null
   
}

function printPagoEmp(opt){
   if ( opt ) {
  	   
       var salarioBase = parseInt(document.getElementById("nuevo_sal_base").value);
	   var xtra = parseInt(document.getElementById("xtra").value);
	   var otrosIngresos = parseInt(document.getElementById("otros_ingresos").value);
	   var ausenciaTardanza = parseInt(document.getElementById("ausenciaTardanza").value);
	   var otrosEgresos = parseInt(document.getElementById("otros_egresos").value);
	   var otrosEgresos = parseInt(document.getElementById("otros_egresos").value);
	   var gastoRep = (document.getElementById("gastoRep")==null?0.0:document.getElementById("gastoRep").value);
	   
	   var impuesto_sr = document.getElementById("imp_sr").value;
	
	   abrir_ventana("../rhplanilla/print_pago_empleado.jsp?print="+opt+"&empId=<%=emp_id%>&nsb="+salarioBase+"&xt="+xtra+"&oi="+otrosIngresos+"&at="+ausenciaTardanza+"&oe="+otrosEgresos+"&gr="+gastoRep+"&isr="+impuesto_sr);
	   }
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DESCUENTO DE EMPLEADOS"></jsp:param>
</jsp:include>
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
	<td colspan="4">&nbsp;</td>	
	</tr>
	
	<tr class="TextRow02">
		
		<td colspan="4" align="right" style="height:20px;"><a href="javascript:printPagoEmp('all')" class="Link01Bold">[ Imprimir Todo ]</a></td>
	</tr>	
	
	<tr class="TextHeader">
		<td colspan="4">&nbsp;Generales de Empleado</td>
	</tr>		
	
	<tr class="TextRow01" >
		<td height="22">&nbsp;N&uacute;mero de C&eacute;dula</td>
		<td colspan="3">&nbsp;<%=desc.getColValue("primero")%>&nbsp;-&nbsp;<%=desc.getColValue("segundo")%>&nbsp;-&nbsp;<%=desc.getColValue("tercero")%>&nbsp;-&nbsp;<%=desc.getColValue("cuarto")%></td>
	</tr>
	
	<tr class="TextRow01">
		<td width="16%">&nbsp;Nombre</td>
		<td width="34%">&nbsp;<%=desc.getColValue("namePrimer")%></td>
		<td width="20%">&nbsp;Apellido</td>
		<td width="30%">&nbsp;<%=desc.getColValue("Apellido")%></td>
	</tr>		
	
	<tr class="TextRow01">
		<td>&nbsp;Unidad Administrativa</td>
		<td>&nbsp;<%=desc.getColValue("unidad")%></td>
		<td>&nbsp;Salario Base</td>
		<td>&nbsp;<%=desc.getColValue("salario")%></td>
	</tr>
	<tr class="TextRow01">
		<td>&nbsp;Ubicaci&oacute;n f&iacute;sica</td>
		<td>&nbsp;<%=desc.getColValue("ubic_fisica")%></td>
		<td>&nbsp;Gasto rep.</td>
		<td>&nbsp;<%=CmnMgr.getFormattedDecimal(desc.getColValue("gastoRep"))%></td>
	</tr>
	
	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr class="TextHeader">
		<td colspan="4" height="20" style="cursor:pointer" onClick="javascript:mostrarEsconder(1)">
		   <span style="width:97%">&nbsp;&nbsp;PLANILLA QUINCENAL</span>
		   <strong id="plus1">[-]</strong>
		</td>
	</tr>
	</table></td></tr>
	<%
	   String groupByPerc = "";
	   CommonDataObject cdo2 = new CommonDataObject();	
	   double tipo_renta = 0.00;
	   double isr = 0.0;
	   double seguroSocial = 0.00;
	   double seguroEducativo  = 0.00;
	   double seguroSocialGastoRep = 0.00;
	   String formula = "";
	   String resaltar2 = "", asterisco2 = "";
	%>
	<tr>
        <td class="TableBorder" style="display:block;" id="planilla1">
			<table width="99%" cellpadding="0" cellspacing="1" align="center">
				<tr class="TextHeader02">
					<td colspan="8">Datos extras (afectan al salario bruto)</td>
					<td align="right"><a title="Imprimir planilla quincenal" href="javascript:printPagoEmp('pla_q')" class="Link03Bold">[ Imprimir ]</a></td>
				</tr>
				<tr class="TextRow01">
					<td>Extra:<br /><%=fb.intBox("xtra","0.00",false,false,false,10,10,null,null,"onfocus=\"this.select();\" onblur=\"changeSalBase()\"")%></td>
					<td>Otros ingresos:<br /><%=fb.intBox("otros_ingresos","0.00",false,false,false,10,10,null,null,"onfocus=\"this.select();\" onblur=\"changeSalBase()\"")%></td>
					<td>&nbsp;</td>
					<td>Ausencia/Tardanza:<br /> <%=fb.intBox("ausenciaTardanza","0.00",false,false,false,10,10,null,null,"onfocus=\"this.select();\" onblur=\"changeSalBase()\"")%></td>
					<td>Otros egresos:<br /> <%=fb.intBox("otros_egresos","0.00",false,false,false,10,10,null,null,"onfocus=\"this.select();\" onblur=\"changeSalBase()\"")%></td>
					<td colspan="4">Nuevo salario base:<br /> <%=fb.intBox("nuevo_sal_base",""+desc.getColValue("salario"),false,false,true,10,10)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="9">Descuentos legales</td>
				</tr>
				<%=fb.hidden("size",""+al.size())%>
				
		<%
		 for ( int p = 0; p<al.size(); p++ ){
		    
			cdo2 = (CommonDataObject)al.get(p);
			
			if ( !groupByPerc.equals(cdo2.getColValue("emp_id")) ){ 
			     seguroSocial = (Double.parseDouble(cdo2.getColValue("seguro_social"))/100)*Double.parseDouble(desc.getColValue("salario"));
				 seguroEducativo = (Double.parseDouble(cdo2.getColValue("seguro_edu"))/100)*Double.parseDouble(desc.getColValue("salario"));
			
			%>
			    <%=fb.hidden("seguroSocial",cdo2.getColValue("seguro_social"))%>
				<%=fb.hidden("seguroEducativo",cdo2.getColValue("seguro_edu"))%>
				<%=fb.hidden("gastoRep",desc.getColValue("gastoRep"))%>
				<%=fb.hidden("impuesto_sr",cdo2.getColValue("impuesto_sr"))%>
				<%=fb.hidden("pagoBase",cdo2.getColValue("pago_base"))%>
				
				<tr class="TextHeader02">
				  <td width="10%">Seguro Social</td>
				  <td width="15%">&nbsp;</td>
				  <td width="20%">&nbsp;</td>
				  <td width="10%">Mensual</td>
				  <td width="10%">Quincenal</td>
				<td colspan="4">&nbsp;</td>
				</tr>
				
				<tr class="TextRow01">
				  <td><%=cdo2.getColValue("seguro_social")+ "%"%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td><a title="Ver f&oacute;rmula" href="javascript:showFormula('seguro_soc')" class="Link00" id="seguro_social">
				  &nbsp;</a></td>
				  <td><label id="ss_q">&nbsp;</label></td>	<td colspan="4">&nbsp;</td>
				</tr>
				
					<tr class="TextRow02" style="display:none;" id="seguro_soc_f">
				      <td colspan="9" style="padding:15px;">
					      Mensual&nbsp;&nbsp;=&nbsp;salario base * (9/100) <br />
						  Quincenal&nbsp;&nbsp;=&nbsp;(salario base/2) * (9/100)
					  </td>
				    </tr>
				
				
				
				 <% if( Double.parseDouble(desc.getColValue("gastoRep")) > 0 ) {  
				 		if ( (Double.parseDouble(desc.getColValue("gastoRep"))*13) > 0 && (Double.parseDouble(desc.getColValue("gastoRep"))*13) <=25000 ){				     seguroSocialGastoRep = (((10/100) * Double.parseDouble(desc.getColValue("gastoRep"))) * (9/100));
							 formula = "Mensual   = (gasto rep. * (10/100)) * (9/100) <br />Quincenal   = [(gasto rep. * (10/100)) * (9/100)]/2"; 				 resaltar2 = "style=\"background-color:#ff0;\"";
							 asterisco2 ="* (Dentro de ese rango)";
						}else
						if ( (Double.parseDouble(desc.getColValue("gastoRep"))*13) > 25000 && (Double.parseDouble(desc.getColValue("gastoRep"))*13) <=9999999 ){				    
						   seguroSocialGastoRep = (((15/100) * Double.parseDouble(desc.getColValue("gastoRep"))) * (9/100));
						    formula = "Mensual   = (gasto rep. * (15/100)) * (9/100) \nQuincenal   = [(gasto rep. * (15/100)) * (9/100)]/2"; 				resaltar2 = "style=\"background-color:#ff0;\"";
							asterisco2 ="* (Dentro de ese rango)";
						}
				 
				 %>
				
				<tr class="TextHeader02">
				  <td colspan="2">Seguro Social en base del gasto rep.</td>
				  <td>&nbsp;</td>
				  <td>Mensual</td>
				  <td>Quincenal</td>
				  <td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
				  <td colspan="2">9%</td>
				  <td>&nbsp;</td>
				  <td><a title="Ver f&oacute;rmula" href="javascript:showFormula('seguro_soc_gr')" class="Link00" id="seguro_social_gr">&nbsp;</a></td>
				   <td><label id="ss_gr">&nbsp;</label></td>
				   <td colspan="4">&nbsp;</td>
				</tr>
				
				<tr class="TextRow02" style="display:none;" id="seguro_soc_gr_f">
				    <td colspan="9" style="padding:15px;">
					     <label>Mensual   = (gasto rep. * 9 / 100) <br />Quincenal   = [(gasto rep. * 9 / 100)]/2
						 </label>
					</td>
				</tr>
						
				
				<%}%>
						
				<tr class="TextHeader02">
				  <td width="15%">Seguro Educativo</td>
				  <td width="10%">&nbsp;</td>
				  <td width="20%">&nbsp;</td>
				  <td width="10%">Mensual</td>
				  <td width="10%">Quincenal</td>
				  <td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
				  <td><%=cdo2.getColValue("seguro_edu")+ "%"%></td>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td><a title="Ver f&oacute;rmula" href="javascript:showFormula('seguro_edu')" class="Link00" id="seguro_edu">&nbsp;</a></td>
				  <td><label id="se_q">&nbsp;</label></td>		<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02" style="display:none;" id="seguro_edu_f">
				    <td colspan="9" style="padding:15px;">
					      Mensual&nbsp;&nbsp;=&nbsp;salario base * (1.25/100) <br />
						  Quincenal&nbsp;&nbsp;=&nbsp;(salario base/2) * (1.25/100)					</td>
				</tr>
				<%
				    tipo_renta = Double.parseDouble(desc.getColValue("salario"))*13-Double.parseDouble(cdo2.getColValue("pago_base"));                 String resaltar = "";
					String asterisco = "";
					isr = (cdo2.getColValue("impuesto_sr")==null||cdo2.getColValue("impuesto_sr").equals("")?0.0:Double.parseDouble(cdo2.getColValue("impuesto_sr")));
				  %>
				
				<tr class="TextHeader02">
				  <td colspan="3">Impuesto sobre la Renta</td>
				  <td width="10%">Mensual</td>
				  <td width="10%">Quincenal</td>
				  <td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
				  <td colspan="3">&nbsp;</td>
				  <td><a title="Ver f&oacute;rmula" href="javascript:showFormula('isr');" class="Link00" id="t_isr">0.00</a></td>
				  <td id="t_isr_q">0.00</td>		
				  <td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02" style="display:none;" id="isr_f">
				       <td colspan="9" style="padding:15px;">
					       Mensual = (((Monto anual - Rango inicial) * (porcentaje/100)) + Cargo fijo) / 13 <br />
						   Quincenal = Mensual / 2
					   </td>
				</tr>
				<%=fb.hidden("imp_sr","0.00")%>
				<tr>	
				  <td class="TextRow01" colspan="3">Tipo Renta:&nbsp;&nbsp;&nbsp;<%=cdo2.getColValue("clave")+" 0 (Valor dependiente)"%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pago Base:&nbsp;&nbsp;&nbsp;<%=cdo2.getColValue("pago_base")%>   </td>	
				  	
				  <td colspan="6" class="TextRow01">Monto anual: <a title="Ver f&oacute;rmula" href="javascript:showFormula('monto_an');" class="Link00" id="rangoRenta">&nbsp;</a></td>
				</tr>
				   
				   
				   	<tr class="TextRow02" style="display:none;" id="monto_an_f">
				       <td colspan="9" style="padding:15px;">
					      Monto anual&nbsp;&nbsp;=&nbsp;(salario base * 13) - pago base <br />
				      </td>
				   </tr>
				  
				   <tr>	
				  	<td colspan="9">
					    <table width="100%"  cellpadding="0" cellspacing="1" align="center">
						  <tr class="TextHeader"> <td align="center" colspan=9">Rango de Renta</td></tr>
						  <tr class="TextHeader02">
						     <td width="15%">Rango Inicial</td>
							 <td width="15%">Rango Final</td>
							 <td width="5%">%</td>
							 <td width="15%">Cargo Fijo</td>
							 <td width="50%" colspan="5">Cae</td>
						  </tr>
						  <%=fb.hidden("rangoRentaSize",""+al3.size())%>
						  
						  <%
						  
						  
						  //tipo_renta = 51000.00;
						    for ( int r = 0; r<al3.size(); r++ ){
							  cdo3 = (CommonDataObject)al3.get(r);
							  
							  if ( tipo_renta > Double.parseDouble(cdo3.getColValue("ri")) && tipo_renta <= Double.parseDouble(cdo3.getColValue("rf"))){resaltar = "style=\"background-color:#ff0;\"";
							  asterisco="* (Dentro de ese rango)";
							  }else{resaltar=""; asterisco ="";}
							  
							   
						  %>
							
							<tr class="TextRow01" id="resaltar<%=r%>"> 
							   <td><%=cdo3.getColValue("ri")%></td> 
							   <td><%=cdo3.getColValue("rf")%></td> 
							   <td ><%=cdo3.getColValue("porc")%></td>
							   <td><%=cdo3.getColValue("cf")%></td> 
							   <td colspan="5">&nbsp;</td> 
							 </tr>
							 <%=fb.hidden("ri"+r,""+cdo3.getColValue("ri"))%>
							 <%=fb.hidden("rf"+r,""+cdo3.getColValue("rf"))%>
						    <%
						      }
						   %>
						  
						  <%
						  	if ( Double.parseDouble(desc.getColValue("gastoRep")) > 0 ) { %>
							<tr class="TextRow02"><td colspan="9">&nbsp;</td>
							
							
							<tr class="TextHeader02" style="height:28px;">
							  <td colspan="3">Impuesto sobre la Renta (Gasto Rep.)</td>
							  <td width="10%">Mensual</td>
							  <td width="10%" colspan="5">Quincenal</td>
							</tr>
							<tr class="TextRow01">
							  <td colspan="3">&nbsp;</td>
							  <td><a title="Ver f&oacute;rmula" href="javascript:showFormula('isr_gr');" class="Link00" id="t_isr_gr">0.00</a></td>
							  <td id="t_isr_gr_q" colspan="5" >0.00</td>		
							</tr>
							<tr class="TextRow02" style="display:none;" id="isr_gr_f">
								   <td colspan="9" style="padding:15px;">&nbsp;</td>
							</tr>
							<tr class="TextRow01"><td colspan="9">&nbsp;</td>	
							
							
							<tr class="TextHeader"><td colspan="9">Tarifa de impuesto en base al cargo de representaci&oacute;n</td></tr>						
							<tr class="TextHeader02">
						     <td width="15%">Rango Inicial</td>
							 <td width="15%">Rango Final</td>
							 <td width="5%">%</td>
							 <td width="15%">Cargo Fijo</td>
							 <td width="50%" colspan="5">Cae</td>
						  </tr>
							<tr class="TextRow01" id="gr_row1"  <%=resaltar2%>> 
							   <td>0.00</td> 
							   <td>25,000.00</td> 
							   <td >10</td>
							   <td>0.00</td> 
							   <td colspan="5"><label id="gr1">&nbsp;</label></td> 
							 </tr>
							 <tr class="TextRow01" id="gr_row2"> 
							   <td>25,000.00</td> 
							   <td>y m&aacute;s</td> 
							   <td >15</td>
							   <td>2,500.00</td> 
							   <td colspan="5"><label id="gr2" >&nbsp;</label></td> 
							 </tr>
			
							<tr class="TextRow02"><td colspan="9">&nbsp;</td>
						  <%}%>
						</table>					 </td>
				   </tr>
			
			    <tr class="TextHeader">
				    <td colspan="9">Descuentos voluntarios</td>
			    </tr>
				
				<tr class="TextRow01">
				  <td colspan="9">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Porcentaje de Endeudamiento:   [ <%=cdo2.getColValue("porc_deuda")+ " %"%> ]</td>
				</tr>
				
				
				
					<tr class="TextHeader02">
				        <td colspan="3">Acreedor</td>
					    <td>Descuento Mensual</td>
					    <td>Descuento Quincenal</td>
						<td colspan="4">&nbsp;</td>
				     </tr> 
				
				
			<%}//group by%>
			
			
			<tr class="TextRow01">
			   <td colspan="3"><%=cdo2.getColValue("nombre_corto")+" [ "+cdo2.getColValue("cod_acreedor")+" ]"%></td>
			   <td><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("descuento_mensual"))%></td>
			   <td><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("descuento1"))%></td>
			   <td colspan="4">&nbsp;</td>
			</tr>
			<%=fb.hidden("desc_men"+p,cdo2.getColValue("descuento_mensual"))%>
			<%
			
			groupByPerc = cdo2.getColValue("emp_id");
			} //for
			%>
			
			<tr class="TextRow02">
			    <td colspan="9">&nbsp;</td>
			</tr> 
			
			<tr class="TextHeader">
			    <td colspan="3" rowspan="3">Salario aprox. en base del salario bruto (<label id="new_sal_base"><%=desc.getColValue("salario")%></label>)</td>
			</tr>
			<tr class="TextHeader02">
			    <td>Mensual</td>
				<td>Quincenal</td>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td><a title="Ver f&oacute;rmula" href="javascript:showFormula('tot_aprox');" class="Link00" id="tot_neto">&nbsp;</a></td>
				<td><label id="tot_neto_q">&nbsp;</label></td>
				<td colspan="4">&nbsp;</td>
			</tr>
			
				<tr class="TextRow02" style="display:none;" id="tot_aprox_f">
				    <td colspan="9" style="padding:15px;">
					      Mensual&nbsp;&nbsp;=&nbsp;salario base - seguro social - seguro social gasto rep - seguro educativo - impuesto sobre la renta - descuentos voluntarios  <br />
						  Quincenal&nbsp;&nbsp;=&nbsp;(salario base - seguro social - seguro social gasto rep - seguro educativo - impuesto sobre la renta - descuentos voluntarios) / 2					</td>
				</tr>
			</table>
		</td>	
	</tr>
		
	<tr class="TextHeader" style="width:50%;">
		<td colspan="4" height="20" style="cursor:pointer" onClick="javascript:mostrarEsconder(2,'pla_vac')">
		   <span style="width:97%">&nbsp;&nbsp;PLANILLA VACACIONAL</span>
		   <strong id="plus2">[-]</strong>
		</td>
	</tr>
		
	<tr style="display:block;" id="planilla2">
	   <td colspan="4">
	   <iframe name="pla_vac" id="pla_vac" style="width:100%;" src="frame_planilla_vac.jsp?emp_id=<%=emp_id%>" scrolling="no"></iframe></td>
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