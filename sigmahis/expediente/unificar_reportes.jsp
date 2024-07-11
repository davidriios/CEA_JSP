
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Collection" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iOption" class="java.util.Hashtable" scope="session" />
<jsp:useBean id="iOrden" class="java.util.Hashtable" scope="session" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String defaultClass = "TextRow02";
String highlightClass = "TextRow03 Text12Bold";
String estado = request.getParameter("estado");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String docId = request.getParameter("docId")==null?"":request.getParameter("docId");

if (mode == null) mode = "add";
if (estado == null) estado = "";

if (docId.trim().equals("")) throw new Exception("El número del documento es inválido. Contacte su administrador!");

Hashtable iExpPrintPage = new Hashtable();


/*
iExpPrintPage.put("1","print_exp_seccion_1.jsp");
iExpPrintPage.put("2","print_exp_seccion_2.jsp");
iExpPrintPage.put("3","print_exp_seccion_3.jsp");
iExpPrintPage.put("4","print_exp_seccion_4.jsp");
iExpPrintPage.put("5","print_exp_seccion_5.jsp");
iExpPrintPage.put("6","print_exp_seccion_6.jsp");
iExpPrintPage.put("7","print_exp_seccion_7.jsp");
iExpPrintPage.put("8","print_exp_seccion_8.jsp");
iExpPrintPage.put("9","print_exp_seccion_9.jsp");
iExpPrintPage.put("10","print_exp_seccion_10.jsp");
iExpPrintPage.put("11","print_exp_seccion_11.jsp");
iExpPrintPage.put("12","print_exp_seccion_12.jsp");
iExpPrintPage.put("13","print_exp_seccion_13.jsp");
iExpPrintPage.put("14","print_hist_obstetrica1.jsp");
iExpPrintPage.put("15","print_hist_obstetrica2.jsp");
iExpPrintPage.put("16","print_exp_seccion_16.jsp");
// ya estaba iExpPrintPage.put("17","print_exp_seccion_17.jsp");
iExpPrintPage.put("18","print_exp_seccion_18.jsp");
iExpPrintPage.put("19","print_exp_seccion_19.jsp?interfaz=RIS");
iExpPrintPage.put("20","print_exp_seccion_20.jsp");
iExpPrintPage.put("21","print_exp_seccion_21.jsp");
iExpPrintPage.put("22","print_triage.jsp");
iExpPrintPage.put("23","print_exp_seccion_23.jsp");
iExpPrintPage.put("24","print_hoja_medicamento.jsp");
iExpPrintPage.put("25","print_exp_seccion_19.jsp?interfaz=LIS");
// ya estaba iExpPrintPage.put("26","print_exp_seccion_26.jsp");
iExpPrintPage.put("27","print_exp_seccion_27.jsp");
iExpPrintPage.put("28","print_exp_seccion_28.jsp");
iExpPrintPage.put("29","print_exp_seccion_29.jsp");
iExpPrintPage.put("30","print_exp_seccion_30.jsp");
iExpPrintPage.put("31","print_notas_enfermeria.jsp");
// ya estaba iExpPrintPage.put("32","print_notas_enfermeria.jsp");
iExpPrintPage.put("33","print_escala_norton.jsp");
iExpPrintPage.put("34","print_hoja_diabetica.jsp");
iExpPrintPage.put("35","print_hoja_diabetica.jsp");
iExpPrintPage.put("36","print_eval_ulceras.jsp");
iExpPrintPage.put("37","print_exp_seccion_37.jsp");
iExpPrintPage.put("38","print_exp_seccion_38.jsp");
// ya estaba iExpPrintPage.put("39","print_hoja_defuncion.jsp");
// ya estaba iExpPrintPage.put("40","print_hoja_defuncion.jsp");
// ya estaba iExpPrintPage.put("41","print_hoja_defuncion.jsp");
iExpPrintPage.put("42","print_exp_seccion_42.jsp?id_cirugia=0");
iExpPrintPage.put("45","print_exp_seccion_45.jsp");
iExpPrintPage.put("46","print_progreso_clinico.jsp");
iExpPrintPage.put("49","print_exp_seccion_49.jsp");
// ya estaba iExpPrintPage.put("48","print_historia_clinica.jsp");
iExpPrintPage.put("50","print_exp_seccion_50_all.jsp");
iExpPrintPage.put("51","print_exp_seccion_51.jsp");
iExpPrintPage.put("52","print_protocolo_op.jsp");
iExpPrintPage.put("57","print_notas_enfermeria.jsp?fp=HM");
iExpPrintPage.put("58","print_exp_seccion_58.jsp");
iExpPrintPage.put("59","print_datos_salida.jsp");
iExpPrintPage.put("60","print_exp_seccion_61.jsp?refType=HEM");
iExpPrintPage.put("61","print_exp_seccion_61.jsp?refType=RES");
iExpPrintPage.put("62","print_exp_seccion_62.jsp");
iExpPrintPage.put("67","print_exp_seccion_67_a_70.jsp?fg=NIEN");
iExpPrintPage.put("68","print_exp_seccion_67_a_70.jsp?fg=NIPE");
iExpPrintPage.put("69","print_exp_seccion_67_a_70.jsp?fg=NIPA");
iExpPrintPage.put("70","print_exp_seccion_67_a_70.jsp?fg=NINO");
iExpPrintPage.put("71","print_exp_seccion_71.jsp");
iExpPrintPage.put("72","print_exp_seccion_72.jsp");
iExpPrintPage.put("73","print_exp_seccion_73.jsp");
iExpPrintPage.put("76","print_list_ordenmedica.jsp");
iExpPrintPage.put("77","print_exp_seccion_77.jsp");
iExpPrintPage.put("79","print_exp_seccion_79.jsp");
iExpPrintPage.put("80","print_exp_seccion_80.jsp?fg=WB");
iExpPrintPage.put("82","print_exp_seccion_80.jsp?fg=CR");
iExpPrintPage.put("83","print_exp_seccion_80.jsp?fg=NI");
iExpPrintPage.put("84","print_exp_seccion_80.jsp?fg=AN");
iExpPrintPage.put("85","print_exp_seccion_80.jsp?fg=MO");
iExpPrintPage.put("89","print_exp_seccion_89.jsp");
iExpPrintPage.put("90","print_exp_seccion_90.jsp");
iExpPrintPage.put("91","print_escala_norton.jsp?fg=BR");
iExpPrintPage.put("92","print_control_salida.jsp");
iExpPrintPage.put("93","print_resultado_paciente.jsp");
iExpPrintPage.put("94","print_list_ordenes_nutricion.jsp");
iExpPrintPage.put("96","print_escala_norton.jsp?fg=SG");
iExpPrintPage.put("108","print_exp_seccion_108.jsp");
// ya estaba iExpPrintPage.put("111","print_nota_terapias.jsp?fg=2");*/




String codigoSeccion = "";

Enumeration enumCode = iExpPrintPage.keys();
	
    Object keys;
    while (enumCode.hasMoreElements()) {
	     keys = enumCode.nextElement();
	     codigoSeccion += keys+",";
	 }
	 //doc_id = 24 expediente gral administrador it
     
sql = "select a.codigo, a.descripcion, b.display_order from tbl_sal_expediente_secciones a, tbl_sal_exp_docs_secc b where a.codigo in ("+codigoSeccion.substring(0, (codigoSeccion.length()-1))+") and b.doc_id="+docId+"  and a.codigo=b.secc_code order by a.descripcion";

/*else sql = "select distinct a.* from (select a.codigo, a.descripcion, decode(c.editable,1,decode(a.status,'A','"+((estado.equalsIgnoreCase("F"))?"view":mode)+"','I','view'),'view') as actionMode, decode(a.status,'A',"+((mode.equalsIgnoreCase("view"))?"0":"c.editable")+",'I',0) as editable, b.display_order, nvl(a.path||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path from tbl_sal_expediente_secciones a, tbl_sal_exp_docs_secc b, (select secc_id, max(editable) as editable from tbl_sal_exp_secc_profile where profile_id in ("+profiles+") group by secc_id) c, tbl_sal_exp_secc_centro d where b.doc_id=8 and a.codigo=b.secc_code and a.codigo=c.secc_id and a.codigo=d.cod_sec and d.centro_servicio in (select cds from tbl_adm_atencion_cu where pac_id="+pacId+((noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0"))?" and secuencia="+noAdmision:"")+") /* and a.status ='A'*/ //order by b.display_order ) a order by descripcion";*/

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head><!--1876px 1756px-->
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<style type="text/css">
#loading{position:absolute;z-index:200;text-align:center;font-family:"Trebuchet MS", verdana, arial,tahoma;font-size:18pt;background-color:rgb(51, 51, 51);width: 100%;opacity:.40;filter: alpha(opacity=40);color:#fff;text-align:center;}
#content{position: absolute;z-index:201;display: block;left: 50%;top: 10%;width: 500px;text-align:center;margin-left:-250px;}
</style>
<script language="javascript">
document.title="Expediente - "+document.title;
var anoFunc ={
	ajaxLoading:function(divEl){
		this.showMessage('loading');
	},
	showMessage:function(el){
		this.getID(el).style.display='';
		this.getID(el).style.height = getTdHeight();
		this.getID(el).firstChild.innerHTML = this.setMsg();
	},
	getID:function(el){
		return document.getElementById(el);
	},
	setMsg:function(){
	   return 'Creando el PDF... Por favor espere!<br><img src="<%=request.getContextPath()%>/images/loading-bar2.gif">';
	}
}

function getTdHeight(){
   return Math.max(document.getElementById("container")["clientHeight"], document.getElementById("container")["scrollHeight"],document.documentElement["offsetHeight"]);
}

function doAction(){newHeight();}
function printUnifiedExp(){abrir_ventana("../expediente/print_unified_exp.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>");}
function _checkAll(){
 var size = document.getElementById("size").value;
   if ( document.getElementById("check").checked == true ){
   document.getElementById("print").disabled = "";
       for (i = 0; i<size; i++){
          document.getElementById("option"+i).checked = "checked";
		  document.getElementById("orden"+i).value = (i+1);
		  document.form0.ultimoOrden.value = (i+1);
        }//for i 
   }//if checked
   else{
       for (i = 0; i<size; i++){
	      document.getElementById("print").disabled = "disabled";
          document.getElementById("option"+i).checked = "";
		  document.getElementById("orden"+i).value = "";
		   
       }//for i 
	   document.form0.ultimoOrden.value = 0;
  }
}
function checkOrden(id,fg){
var size = document.form0.size.value;
var ultimoOrden = parseInt(document.form0.ultimoOrden.value);
var orden =0;
var x=0;
if(eval('document.form0.option'+id).checked==true || (fg=='OM' && eval('document.form0.orden'+id).value !='' ))
{
	x++;
	if(fg =='AU')
	{
		if(ultimoOrden ==0)orden=1;else orden = ultimoOrden+1;
		document.form0.ultimoOrden.value = orden;
		eval('document.form0.orden'+id).value = orden;
	}
	else
	{
		if(eval('document.form0.option'+id).checked !=true && eval('document.form0.orden'+id).value !='')
	    eval('document.form0.option'+id).checked  = true;
		
		  var ordenDesel = eval('document.form0.orden'+id).value;
		  var ordenDeselX = 0;
		  if(ultimoOrden ==0){  document.form0.ultimoOrden.value = ordenDesel;ultimoOrden=ordenDesel;}
		  else if(ultimoOrden < ordenDesel) ultimoOrden = ordenDesel;
		  
		  for (var i=0; i <size; i++)
		  {
			  if(eval('document.form0.orden'+i).value !='' &&( i != id && ordenDesel !='' ))
			  {
				if(parseInt(eval('document.form0.orden'+i).value) ==  ordenDesel)
				{
					alert('El valor ya existe');
					eval('document.form0.orden'+id).value='';
					 eval('document.form0.option'+id).checked  = false;
				}
				else{  if(parseInt(eval('document.form0.orden'+i).value) >  ordenDesel && parseInt(eval('document.form0.orden'+i).value) > ultimoOrden )ultimoOrden = eval('document.form0.orden'+i).value;}
				
				if(ultimoOrden < parseInt(eval('document.form0.orden'+i).value))
				ultimoOrden =  parseInt(eval('document.form0.orden'+i).value);
			  }else
			  {
			    if(eval('document.form0.option'+id).checked==true && eval('document.form0.orden'+i).value=='')eval('document.form0.option'+i).checked  = false;
			  }			  			  		  
		  }
		  document.form0.ultimoOrden.value = ultimoOrden;
	}
}
else
{
  var ordenDesel = eval('document.form0.orden'+id).value;
  var ordenDeselX = 0;
  eval('document.form0.orden'+id).value ='';

  for (var i=0; i <size; i++)
  {
  	  if(eval('document.form0.orden'+i).value !='')
	  {
	  	if(parseInt(eval('document.form0.orden'+i).value) >  ordenDesel)
		{
			ordenDeselX = eval('document.form0.orden'+i).value;
			eval('document.form0.orden'+i).value=ordenDesel;
			if(ordenDesel !=0)orden = ordenDesel;
			else  orden = ordenDeselX ;
			ordenDesel = ordenDeselX;
		}
		else orden = eval('document.form0.orden'+i).value;
	  }
  }
  document.form0.ultimoOrden.value = orden;
}
goPrint();
}
function checkBoleta(){
    if ( document.getElementById("boletaAdm").checked == true ){
	    alert("La boleta de admisión se imprimirá en la posición 1!");
		document.getElementById("print").disabled = "";
	}else{goPrint();}
}
function goPrint(){
     var size = document.getElementById("size").value;
     var counter = 0;
	 if ( document.getElementById("boletaAdm").checked != true ){ 
		 for ( i = 0; i<size; i++ ){
			  if ( document.getElementById("option"+i).checked == true ){
				 counter++;
			  }
		 }
		 if ( counter < 1){
			 document.getElementById("print").disabled = "disabled";  return false;
		 }else{ document.getElementById("print").disabled = "";
 return true;}
	 }else{
	   return true;
	 }
 }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="LISTA DE REPORTES"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
		<td class="TableBorder">
		    <table width="100%" border="0" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0","print_unified_exp.jsp",FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("section","")%>
				<%=fb.hidden("defaultClass",defaultClass)%>
				<%=fb.hidden("highlightClass",highlightClass)%>
				<%=fb.hidden("size",""+al.size())%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("cds",cds)%>
				<%=fb.hidden("ultimoOrden","0")%>
				<%fb.appendJsValidation("if(!goPrint()){alert('No podemos procesar su orden, al menos selecciona un reporte.');error++;}");%>
				<%fb.appendJsValidation("anoFunc.ajaxLoading();");%>
				
                <tr>
					<td id="container" colspan="3">
						<table width="100%" border="0" cellpadding="1" cellspacing="1">
							<tr>
								<td colspan="3"> 
									<div id="loading" style="display:none;">
										<div id="content">&nbsp;</div>
									</div>
								</td>
							</tr>
							<%
							for (int i=0; i<al.size(); i++)
							{
								cdo = (CommonDataObject) al.get(i);
								String color = "TextRow02";
								

								if ( i%2 == 0 ) color = "TextRow01";
								
								if ( i == 0 ){
							%>
							    <tr class="TextHeader">
									<td colspan="3" align="right"><cellbytelabel id="1">INCLUIR BOLETA DE ADMISION</cellbytelabel>&nbsp;<%=fb.checkbox("boletaAdm","S",false,false,null,null,"onClick=\"checkBoleta()\"","Incluir boleta de admisión!")%>&nbsp;<%=fb.submit("print","Imprimir",true,true,null,null,"")%>&nbsp;&nbsp;&nbsp;
									</td>
							    </tr>
							    <tr class="TextHeader" >
								    <td align="center"><cellbytelabel id="2">Secciones</cellbytelabel></td><td><%=fb.checkbox("check","",false,false,null,null,"onkeypress =\"_checkAll()\" onClick=\"_checkAll()\"","Seleccionar todas las secciones listadas!")%>&nbsp;<cellbytelabel id="3">Todas</cellbytelabel></td><td><cellbytelabel id="4">Orden</cellbytelabel></td>
							    </tr>
							<%}%>
									<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
									<%=fb.hidden("ordenVal"+i,""+i)%>
									<%//=fb.hidden("path"+i,cdo.getColValue("path"))%>
									<%=fb.hidden("desc"+i,""+cdo.getColValue("descripcion"))%>
									<tr class="<%=color%>" onMouseOver="setoverc(this,(document.form0.section.value==<%=cdo.getColValue("codigo")%>)?'TextRowOver Text12Bold':'TextRowOver')" onMouseOut="setoutc(this,(document.form0.section.value==<%=cdo.getColValue("codigo")%>)?'<%=highlightClass%>':'<%=color%>')" id="section<%=cdo.getColValue("codigo")%>">
										<td style="padding-left:10px;"><%=cdo.getColValue("descripcion")+" ["+cdo.getColValue("codigo")+"]"%></td>
										<td><%=fb.checkbox("option"+i, cdo.getColValue("codigo"), false, false, null, null, "onClick=\"javascript:checkOrden("+i+",'AU')\"")%></td>
										<td><%=fb.intBox("orden"+i, "", false, false, false, 2, (String.valueOf(al.size()).trim().length()), null, null, "onBlur=\"checkOrden("+i+",'OM')\"")%></td>
									</tr>
							<%
							}
							%>
						</table>	
						<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	    </td>
    </tr>
</table>
</body>
</html>
<%
}//GET

else{
for ( int o = 0; o<al.size(); o++){
   if ( request.getParameter("option"+o) != null ){
      iOption.put(o,request.getParameter("codigo"+o)+"::"+request.getParameter("desc"+o)+"::"+request.getParameter("orden"+o));
	  //iOrden.put(o,request.getParameter("orden"+o));
   }
}
}
%>
