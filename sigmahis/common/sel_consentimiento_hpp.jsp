<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);


ArrayList al = new ArrayList();
int rowCount = 0;
String date = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String pac_id = request.getParameter("pacId");
String no_adm = request.getParameter("noAdmision");
String compania = request.getParameter("compania");
if(fp==null) fp = "";
if(fg==null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Common - '+document.title;

function setValues(){
	var x = getRadioButtonValue(document.dates.check);
	var pac_id = document.dates.pac_id.value;
	if( x==1)
	abrir_ventana('../admision/print_consentimiento_general_hpp.jsp?pac_id='+pac_id);
	if( x==2)
	abrir_ventana('../admision/print_parking_hpp.jsp?pac_id='+pac_id);
	if( x==3)
	abrir_ventana('../admision/print_valores_paciente_hpp.jsp?pac_id='+pac_id);
	if( x==4)
	abrir_ventana('../admision/print_asignacion_caja_hpp.jsp?pac_id='+pac_id);
	
	if(x == 5){
	     abrir_ventana('../admision/print_consentimiento_servicio_comida_hpp.jsp?pac_id='+pac_id);
	}else

	if(x == 6){
	     abrir_ventana('../admision/print_consentimiento_financiero_hpp.jsp?pac_id='+pac_id);
	}else
	
	if(x == 7){
	     abrir_ventana('../admision/print_noti_honorarios_medicos_hpp.jsp?pac_id='+pac_id);
	}else
	if(x == 8){
	     abrir_ventana('../admision/print_consentimiento_fotografico_hpp.jsp?pac_id='+pac_id);
	}else
	if(x == 9){
	     abrir_ventana('../admision/print_consentimiento_farma_terapeutica_hpp.jsp?pac_id='+pac_id);

	}else
	if(x == 11){
	     abrir_ventana('../admision/print_realizacion_de_examen_tratamiento_hpp.jsp?pac_id='+pac_id);
	}else
	if(x == 10){
	     abrir_ventana('../admision/print_denegacion_consentimiento_hpp.jsp?pac_id='+pac_id);
	}else
	if(x == 12){
	     abrir_ventana('../admision/print_label_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>');
	
	}else
	if(x == 13){
	     abrir_ventana('../admision/print_reg_sal_er_hpp.jsp?pac_id='+pac_id+'&noAdmision=<%=no_adm%>');
	}
	else
	  if(x == 14){
	   abrir_ventana('../admision/print_procedimiento_form_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>');
	}
	else
	if ( x == 15 ){
		abrir_ventana('../admision/print_deberes_derechos_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>&lng=es');
	}
	else
	if ( x == 16 ){
		abrir_ventana('../admision/print_deberes_derechos_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>&lng=en');
	}
	else
	if ( x == 17 ){
		abrir_ventana('../admision/ingreso_consumo_alimentos_externos_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>');
	}
	else
	if ( x == 18 ){
		abrir_ventana('../admision/decoracion_puertas_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>');
	}
	else
	if ( x == 19 ){
		abrir_ventana('../admision/ref_credito_hpp.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>');
	}
	else if ( x == 20 ){abrir_ventana('../admision/print_label_unico.jsp?pacId='+pac_id+'&noAdmision=<%=no_adm%>');}
}

function setIndex(k)
{
	document.result.index.value=k;
	//checkOne('result','check',<%//=al.size()%>,eval('document.result.check'+k),0);
	getPatientDetails(k);
}

function ListConsentimiento(file_name){
		
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="84%" cellpadding="0" cellspacing="0">
<tr><td>&nbsp;</td></tr>
<tr><td>&nbsp;</td></tr>
<tr><td>&nbsp;</td></tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder"><table align="center" width="90%" cellpadding="1" cellspacing="0">
      <%
      fb = new FormBean("dates","","post","");
      %>
      <%=fb.formStart()%> <%=fb.hidden("pac_id",pac_id)%>
      <tr class="TextPager">
        <td width="34%">&nbsp;</td>
      </tr>
      <tr class="TextPager">
        <td class="TextHeader" colspan="9">Seleccione Consentimiento Para Imprimir </td>
      </tr>
      <tr class="TextPager">
        <td colspan="9">&nbsp;</td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Consentimiento General</td>
        <td width="23%" align="left"><%=fb.radio("check","1",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Demesa</td>
        <td align="left"><%=fb.radio("check","2",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Valores De Paciente</td>
        <td align="left"><%=fb.radio("check","3",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Asignacion De Caja De Seguridad</td>
        <td align="left"><%=fb.radio("check","4",false,false,false,null,null,"")%></td> 
	 </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Servicio De Comida Kosher</td>
        <td align="left"><%=fb.radio("check","5",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Consentimiento Financiero</td>
        <td align="let"><%=fb.radio("check","6",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Notificación De Honrarios Médicos</td>
        <td align="left"><%=fb.radio("check","7",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Consentimiento Fotografía</td>
        <td align="left"><%=fb.radio("check","8",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Comité de Farmacia y Terapéutica</td>
        <td align="left"><%=fb.radio("check","9",false,false,false,null,null,"")%></td>
	 </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
        <td align="left" style="color:#333; font-weight:bold; font-size:12px;">Realización de Examen y/o Tratamientos</td>
        <td align="left"><%=fb.radio("check","11",false,false,false,null,null,"")%></td>
     </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Denegación de consentimiento</td>
		  <td width="3%" align="left"><%=fb.radio("check","10",false,false,false,null,null,"")%></td>
      </tr>
	  <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Impresión de Label de Paciente</td>
		  <td width="3%" align="left"><%=fb.radio("check","12",false,false,false,null,null,"")%></td>
      </tr>
	  <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Impresión de Label de Paciente INDIVIDUAL</td>
		  <td width="3%" align="left"><%=fb.radio("check","20",false,false,false,null,null,"")%></td>
      </tr>
	  <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Registro de Admision</td>
		  <td width="3%" align="left"><%=fb.radio("check","13",false,false,false,null,null,"")%></td>
      </tr>
	  <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Registro de Admisión (HSP)</td>
		  <td width="3%" align="left"><%=fb.radio("check","14",false,false,false,null,null,"")%></td>
      </tr>	  
	  <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Deberes y Derechos</td>
		  <td width="3%" align="left"><%=fb.radio("check","15",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Deberes y Derechos (Ingl&eacute;s)</td>
		  <td width="3%" align="left"><%=fb.radio("check","16",false,false,false,null,null,"")%></td>
      </tr>	 
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Ingreso y Consumo Alimentos Externos</td>
		  <td width="3%" align="left"><%=fb.radio("check","17",false,false,false,null,null,"")%></td>
      </tr>
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Procedimeiento para la decoraci&oacute;o de las puertas</td>
		  <td width="3%" align="left"><%=fb.radio("check","18",false,false,false,null,null,"")%></td>
      </tr> 
      <tr class="TextPager" onMouseOver="setoverc(this, 'TextRowOver')" onMouseOut="setoutc(this,'TextPager')">
         <td width="34%" align="left" style="color:#333; font-weight:bold; font-size:12px;">Referencias de cr&eacute;dito</td>
		  <td width="3%" align="left"><%=fb.radio("check","19",false,false,false,null,null,"")%></td>
      </tr>   
	  
      <tr class="TextPager">
        <td align="center" colspan="9"><%=fb.button("btn","Imprimir",true,false,null,"Text10","onClick=\"javascript:setValues()\"")%> <%=fb.button("btnClose","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
      </tr>
      <tr class="TextPager">
        <td>&nbsp;</td>
      </tr>
      <%=fb.formEnd()%>
    </table></td>
</tr>
<tr><td>&nbsp;</td></tr>
</table>
</body>
</html>
<%
}
%>
