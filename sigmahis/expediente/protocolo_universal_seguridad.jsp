<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ENMgr" scope="page" class="issi.expediente.EvaluacionNutricionalMgr" />
<%
/**
==================================================================================
Fg = PUSP = Prococolo Universal de Seguridad de Paciente
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ENMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String displayDetail = "none";
String desc = request.getParameter("desc");
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");

if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "PUSP";//PUSP Prococolo Universal de Seguridad
if (id == null) id = "0";
if (estado == null) estado = "";

if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
		al = SQLMgr.getDataPropertiesList("select evaluacion from tbl_sal_nutricion_parenteral where pac_id="+pacId+" and admision="+noAdmision+"and tipo = '"+fg+"' order by id desc ");
	prop = SQLMgr.getDataProperties("select evaluacion from tbl_sal_nutricion_parenteral where id="+id+" ");
	
	if (prop == null)
	{ 
		prop = new Properties();
		prop.setProperty("id","0");
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora_inicio","");
		prop.setProperty("usuario",""+(String) session.getAttribute("_userName"));
		sql=" select (select join(cursor(select a.descripcion||': '||b.observacion||' ' alergias from tbl_sal_tipo_alergia a, tbl_sal_alergia_paciente b where a.codigo=b.tipo_alergia and b.pac_id="+pacId+" ORDER BY a.DESCRIPCION  ),'; ') alergias from dual ) alergias  from dual";
		cdo1 = SQLMgr.getData(sql);//
		if(cdo1 != null)prop.setProperty("observacion5",cdo1.getColValue("alergias"));
	}
	else
	{
		if(!viewMode) mode = "edit";
	}

%>

<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Evaluación Nutricional - '+document.title;

function doAction()
{
	
	//isChecked();
	newHeight();
	
}
function setEvaluacion(code)
{
window.location = '../expediente/protocolo_universal_seguridad.jsp?mode=view&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>&estado=<%=estado%>&id='+code;
}
function add()
{
window.location = '../expediente/protocolo_universal_seguridad.jsp?mode=add&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>&id=0&estado=<%=estado%>';
}
function showDetail(status)
{ 
	var obj=document.getElementById('detail');
	if(status=='N')
	{
		obj.style.display='none';
	}
	else if(status=='S')
	{
		obj.style.display='';
	}
	//newHeight();
	doAction();
}

function checking(val)
{
var chkObj = eval('document.form0.'+val);
if(chkObj.checked == true) {eval('document.form0.'+val).className = 'FormDataObjectDisabled'; eval('document.form0.'+val).readOnly=false; eval('document.form0.'+val).disabled = false;}
else {eval('document.form0.'+val).className = 'FormDataObjectEnabled'; eval('document.form0.'+val).readOnly=true; eval('document.form0.'+val).disabled = true;}
}





//function isChecked()
//{
//	var total =0;
//	var total2 =0;
//	var edad = 0;
//	if(!isNaN(parent.document.paciente.edad.value))
//	edad = parent.document.paciente.edad.value;
//	for(k=1;k<=4;k++)
//	{
//		if (eval('document.form0.check'+k).checked)
//		total += parseInt(eval('document.form0.valor'+k).value);
//		if (eval('document.form0.ckPuntos'+k).checked)
//		total2 += parseInt(eval('document.form0.puntos'+k).value);
//		
//	}
//	if(edad>=70)
//	{
//		total  +=1;
//		total2 +=1;
//	}
//	
//	eval('document.form0.total1').value=total;
//	eval('document.form0.total2').value=total2;
//	
//}
function printExp(option){
   if (typeof option == "undefined"){
       abrir_ventana("../expediente/print_protocolo_univ_seguridad.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>");
   }else{
      abrir_ventana("../expediente/print_protocolo_univ_seguridad.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>");
   }
}

</script>
<style type="text/css">
<!--
.style1 {color: #0033CC}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">


<tr class="TextRow01">
					<td>
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("estado", estado)%>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1"><cellbytelabel>Listado de Pausa Quir&uacute;gica</cellbytelabel></cellbytelabel></td>
							<td align="right">
							<%if(!id.equals("0")){%>
							     <a href="javascript:printExp()" class="Link00">[ <cellbytelabel id="32"><cellbytelabel>Imprimir</cellbytelabel></cellbytelabel> ]</a>
							<%}%>
							<a href="javascript:printExp('ALL')" class="Link00">[ <cellbytelabel id="33"><cellbytelabel>Imprimir Todo</cellbytelabel></cellbytelabel> ]</a>
						
							<%if(estado.equalsIgnoreCase("F")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2"><cellbytelabel>Agregar Pausa Quir&uacute;gica</cellbytelabel></cellbytelabel> ]</a><%}%></td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="3">Fecha</cellbytelabel></td>
							<td  width="15%">&nbsp;</td>
							<td  width="65%">&nbsp;</td>
						</tr>
<%
for (int i=1; i<=al.size(); i++)
{
	Properties prop1 = (Properties) al.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,prop1.getProperty("id"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=prop1.getProperty("id")%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=prop1.getProperty("fecha")%></td>
				<td colspan="2"><%//=prop1.getProperty("hora")%></td>

		</tr>
<%}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>

		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("cds",cds)%>		
		<tr class="TextRow02">
			<td colspan="9">&nbsp;</td>
		</tr>
		
		<tr class="TextHeader">
			<td colspan="9"></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="9">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td colspan="6">
								<table align="center" width="100%" cellpadding="1" cellspacing="1">
									<tr class="TextRow01">
										<td width="30%"><cellbytelabel id="3">Fecha</cellbytelabel>:
											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="format" value="dd/mm/yyyy"/>
											<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
											<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
											<jsp:param name="readonly" value="<%=(viewMode||mode.trim().equals("edit"))?"y":"n"%>"/>
											</jsp:include></td>
											
<td colspan="70%"><cellbytelabel id="4">Usuario</cellbytelabel><%=fb.textBox("usuario",prop.getProperty("usuario"),false,false,true,50,"Text10",null,null)%></td>
									</tr>
							
								</table>
							</td>
						</tr>
						<tr class="TextHeader">
							<td width="2%"><cellbytelabel id="5">No</cellbytelabel></td>
							<td width="48%"><cellbytelabel id="6">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="7">SI</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="8">NO</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="9">No Es necesario</cellbytelabel></td>
							<td width="20%"><cellbytelabel id="10">Observaci&oacute;n</cellbytelabel></td>
						</tr>
<tr class="TextRow01">
	<td>1.</td>
	<td><cellbytelabel id="11">Estudios por Imagenes</cellbytelabel></td>
<td><%=fb.radio("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
<td><%=fb.radio("aplicar1","N",(prop.getProperty("aplicar1").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:checking('aplicar1')\"")%></td>
<td><%=fb.radio("aplicar1","NN",(prop.getProperty("aplicar1").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
<td ><%=fb.textBox("observacion1",(prop.getProperty("observacion1")),false,false,false,60,"Text10","","")%>



</tr>

<tr class="TextRow01">
	<td>2.</td>
	<td><cellbytelabel id="12">Ex&aacute;menes de Laboratorio</cellbytelabel></td>
		<td><%=fb.radio("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar2","N",(prop.getProperty("aplicar2").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar2","NN",(prop.getProperty("aplicar2").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion2",(prop.getProperty("observacion2")),false,false,false,60,"Text10","","")%>
</tr>
<tr class="TextRow01">
	<td>3.</td>
	<td><cellbytelabel id="13">Historia Cl&iacute;nica</cellbytelabel></td>
	<td><%=fb.radio("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar3","N",(prop.getProperty("aplicar3").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar3","NN",(prop.getProperty("aplicar3").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion3",(prop.getProperty("observacion3")),false,false,false,60,"Text10","","")%>
</tr>
<tr class="TextRow01">
	<td>4.</td>
	<td><cellbytelabel id="14">Antibi&oacute;tico Profilaxis</cellbytelabel></td>
	<td><%=fb.radio("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar4","N",(prop.getProperty("aplicar4").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar4","NN",(prop.getProperty("aplicar4").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion4",(prop.getProperty("observacion4")),false,false,false,60,"Text10","","")%>
</tr>
<tr class="TextRow01">
	<td>5.</td>
	<td><cellbytelabel id="15">Alergias</cellbytelabel></td>
	<td><%=fb.radio("aplicar5","S",(prop.getProperty("aplicar5").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar5","N",(prop.getProperty("aplicar5").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar5","NN",(prop.getProperty("aplicar5").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion5",(prop.getProperty("observacion5")),false,false,false,60,"Text10","","")%>
</tr>

<tr class="TextRow01">
	<td>6.</td>
	<td><cellbytelabel id="16">Consentimiento Quir&uacute;rgico firmado por el m&eacute;dico y paciente</cellbytelabel></td>
	<td><%=fb.radio("aplicar6","S",(prop.getProperty("aplicar6").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar6","N",(prop.getProperty("aplicar6").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar6","NN",(prop.getProperty("aplicar6").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion6",(prop.getProperty("observacion6")),false,false,false,60,"Text10","","")%>
</tr>

<tr class="TextRow01">
	<td>7.</td>
	<td><cellbytelabel id="17">Consentimiento de Anestesia firmado por el m&eacute;dico y paciente</cellbytelabel></td>
	<td><%=fb.radio("aplicar7","S",(prop.getProperty("aplicar7").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar7","N",(prop.getProperty("aplicar7").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar7","NN",(prop.getProperty("aplicar7").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion7",(prop.getProperty("observacion7")),false,false,false,60,"Text10","","")%>
</tr>

<tr class="TextRow01">
	<td>8.</td>
	<td><cellbytelabel id="18">Consentimiento de Hemoderivados firmado</cellbytelabel></td>
	<td><%=fb.radio("aplicar8","S",(prop.getProperty("aplicar8").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar8","N",(prop.getProperty("aplicar8").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar8","NN",(prop.getProperty("aplicar8").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion8",(prop.getProperty("observacion8")),false,false,false,60,"Text10","","")%>
</tr>
<tr class="TextRow01">
	<td>9.</td>
	<td><cellbytelabel id="19">Presentaci&oacute;n del Personal Quir&uacute;rgico</cellbytelabel></td>
	<td><%=fb.radio("aplicar9","S",(prop.getProperty("aplicar9").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar9","N",(prop.getProperty("aplicar9").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td><%=fb.radio("aplicar9","NN",(prop.getProperty("aplicar9").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion9",(prop.getProperty("observacion9")),false,false,false,60,"Text10","","")%>
</tr>
<tr class="TextRow01">
	<td>10.</td>
	<td><cellbytelabel id="19">Marcaci&oacute;n del Sitio Quir&uacute;rgico por el M&eacute;dico con sus iniciales</cellbytelabel></td>
<td><%=fb.radio("aplicar10","S",(prop.getProperty("aplicar10").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
<td><%=fb.radio("aplicar10","N",(prop.getProperty("aplicar10").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
<td><%=fb.radio("aplicar10","NN",(prop.getProperty("aplicar10").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion10",(prop.getProperty("observacion10")),false,false,false,60,"Text10","","")%>
</tr>
<tr class="TextRow01">
	<td>11.</td>
	<td><cellbytelabel id="20">Confirmación de Equipos especiales y/o Implantes por la Enfermera de Quir&oacute;fano</cellbytelabel>.</td>
<td><%=fb.radio("aplicar11","S",(prop.getProperty("aplicar11").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
<td><%=fb.radio("aplicar11","N",(prop.getProperty("aplicar11").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
<td><%=fb.radio("aplicar11","NN",(prop.getProperty("aplicar11").equalsIgnoreCase("NN")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
	<td ><%=fb.textBox("observacion11",(prop.getProperty("observacion11")),false,false,false,60,"Text10","","")%>
</tr>
						</table>
			
			<%if(prop.getProperty("aplicar1").equalsIgnoreCase("S") || prop.getProperty("aplicar2").equalsIgnoreCase("S")||prop.getProperty("aplicar3").equalsIgnoreCase("S")|| prop.getProperty("aplicar4").equalsIgnoreCase("S"))displayDetail=""; %>
			
			<tr id="detail" style="display:<%=displayDetail%>">
				<td colspan="9">		
					<table align="center" width="100%" cellpadding="1" cellspacing="1">			
						<tr class="TextHeader">
							<td colspan="8"><cellbytelabel id="21">TABLA</cellbytelabel> 2</td>
						</tr>
						<tr class="TextRow05" align="center">
							<td colspan="4"><cellbytelabel id="22">PAUSA DE SEGURIDAD(TIME OUT)</cellbytelabel></td>
							<td colspan="4"></td>
						</tr>
						<tr class="TextHeader">
							<td width="5%" rowspan="2"><cellbytelabel id="5">No</cellbytelabel></td>
							<td width="25%" rowspan="2"><cellbytelabel id="6">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%" colspan="2"><cellbytelabel id="23">Paciente Correcto</cellbytelabel></td>
							<td width="10%" colspan="2"><cellbytelabel id="24">Procedimiento</cellbytelabel></td>
							<td width="10%" colspan="2"><cellbytelabel id="25">Sitio Correcto</cellbytelabel></td>				
 						</tr>
						<tr class="TextHeader">
							<td width="10%"><cellbytelabel id="29">Si</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="30">NO</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="31">Si</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="32">NO</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="33">Si</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="34">NO</cellbytelabel></td>			
 						</tr>
					    
<tr class="TextRow01">
	<td>1.</td>
	<td><cellbytelabel id="26">Cirujano y Asistentes</cellbytelabel></td>
	<td><%=fb.radio("check1","S",(prop.getProperty("check1").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
	<td><%=fb.radio("check1","N",(prop.getProperty("check1").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>	
	<td><%=fb.radio("check2","S",(prop.getProperty("check2").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
	<td><%=fb.radio("check2","N",(prop.getProperty("check2").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>	
	<td><%=fb.radio("check3","S",(prop.getProperty("check3").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
	<td><%=fb.radio("check3","N",(prop.getProperty("check3").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>	
</tr>
						
<tr class="TextRow02">
<td>2.</td>
<td><cellbytelabel id="27">Anestesiologo y asistente</cellbytelabel></td>
<td><%=fb.radio("check4","S",(prop.getProperty("check4").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check4","N",(prop.getProperty("check4").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check5","S",(prop.getProperty("check5").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check5","N",(prop.getProperty("check5").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check6","S",(prop.getProperty("check6").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check6","N",(prop.getProperty("check6").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
</tr>
				
<tr class="TextRow01">
<td>3.</td>
<td><cellbytelabel id="28">Instrumentista/circulador,otros</cellbytelabel></td>
<td><%=fb.radio("check7","S",(prop.getProperty("check7").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check7","N",(prop.getProperty("check7").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check8","S",(prop.getProperty("check8").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check8","N",(prop.getProperty("check8").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check9","S",(prop.getProperty("check9").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
<td><%=fb.radio("check9","N",(prop.getProperty("check9").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>		
</tr>
						
						
						
					</table>
					</td>
				</tr>
			</td>
		</tr>
		
<%fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td colspan="9" align="right">
				<cellbytelabel id="29">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="30">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="31">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	prop = new Properties();

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));

	prop.setProperty("fecha",request.getParameter("fecha"));
	prop.setProperty("usuario",request.getParameter("usuario"));
	
	prop.setProperty("id",request.getParameter("id"));
	prop.setProperty("tipo",""+fg);
	
	prop.setProperty("total1",request.getParameter("total1"));
	prop.setProperty("total2",request.getParameter("total2"));
	
	//prop.setProperty("usuario",""+UserDet.getName());
		
	for(int l=1;l<=11;l++)
	{
		//prop.setProperty("puntos"+l,request.getParameter("puntos"+l));
		//prop.setProperty("ckPuntos"+l,request.getParameter("ckPuntos"+l));
		//prop.setProperty("valor"+l,request.getParameter("valor"+l));
		if ( (l>=1) && (l<=9) ){
		   prop.setProperty("check"+l,request.getParameter("check"+l));
		 }
		
		prop.setProperty("aplicar"+l,request.getParameter("aplicar"+l));
		prop.setProperty("observacion"+l,request.getParameter("observacion"+l));
	}
	prop.setProperty("usuario_mod",(String) session.getAttribute("_userName"));
	prop.setProperty("fecha_mod",cDateTime);	
	if ((UserDet.getRefType().trim().equalsIgnoreCase("M")))prop.setProperty("medico",""+UserDet.getRefCode());
	else prop.setProperty("medico","");
	prop.setProperty("fec_nacimiento", request.getParameter("dob"));
	prop.setProperty("cod_paciente",request.getParameter("codPac"));
	prop.setProperty("cds",request.getParameter("cds"));
					
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg);
		if (mode.equalsIgnoreCase("add")) 
		{	
			prop.setProperty("usuario_creac",(String) session.getAttribute("_userName"));
			prop.setProperty("fecha_creac",cDateTime);
			ENMgr.add(prop);
			id = ENMgr.getPkColValue("id");
		}
		else ENMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ENMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ENMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(ENMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&cds=<%=cds%>&estado=<%=estado%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>