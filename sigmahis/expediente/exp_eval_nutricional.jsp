<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDiagNu" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagNu" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPlan" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPlan" scope="session" class="java.util.Vector" />

<!-- Pantalla: "Evaluación Nutricional"        -->
<!-- Fecha: 22/04/2010                         -->

<%
/**
==================================================================================

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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String sql = "", sqlTitle ="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
 
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision"); 
String fg = request.getParameter("fg"); 
String tab = request.getParameter("tab");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");


if (fg == null) fg = "I";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tab == null) tab = "0";

int rowCount = 0;
String sql2 = "";

String change = request.getParameter("change");
String code = request.getParameter("code");

int diagLastLineNo =0,pLastLineNo=0; 

String filter ="", filter2 ="";
String key = "";
if(code == null)code = "0";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("pLastLineNo") != null) pLastLineNo = Integer.parseInt(request.getParameter("pLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc == null) desc = "";

//sql=" select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.diag_pre_operatorio, a.diag_post_operatorio, a.procedimiento,	coalesce(f.observacion,f.nombre) descdiagpre ,coalesce(g.observacion,g.nombre) descdiagpost,	decode(h.observacion , null , h.descripcion,h.observacion)descproc from tbl_sal_protocolo_operatorio a,tbl_cds_diagnostico f, tbl_cds_diagnostico g,tbl_cds_procedimiento h where a.diag_pre_operatorio = f.codigo and a.diag_post_operatorio = g.codigo and a.procedimiento = h.codigo and a.admision = "+noAdmision+" and a.pac_id = "+pacId+" order by to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc ";

sql=" select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.evaluado_por from tbl_sal_evaluacion_nutricion a where a.admision = "+noAdmision+" and a.pac_id = "+pacId+" order by to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc, 1 desc ";
al2 = SQLMgr.getDataList(sql);

 sql="select nvl(a.codigo,0) codigo,a.codigo_eval, g.id cod_guia,g.nombre,  a.observacion,a.cds,nvl(a.aplicar,'N') aplicar  from tbl_sal_eval_nutric_plan a, tbl_sal_guia g where a.cod_guia(+) = g.id and a.codigo_eval(+) = "+code+" and g.tipo ='PA'  order by a.codigo asc";
 al3 = SQLMgr.getDataList(sql);

if(!code.trim().equals("0"))
{

sql= " select nutric.codigo as codigo, to_char(nutric.fecha,'dd/mm/yyyy') as fecha, "
+" nutric.eval_inicial, nutric.recomendacion, "
+" nutric.observacion, nutric.evaluado_por,clasificacion,peso,talla,imc,alimentacion,actividad,patron,interaccion,terapia_nutricional,patron_alimentario "
+" from tbl_sal_evaluacion_nutricion nutric "
+" where "
+" nutric.codigo = "+code
+" order by to_date(to_char(nutric.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc ";

cdo = SQLMgr.getData(sql);

if(change == null)
{		
	iDiagNu.clear();
	vDiagNu.clear();
	iPlan.clear();
	vPlan.clear();
	
 sql="select  a.codigo_eval, a.diagnostico, coalesce(g.observacion,g.nombre) descDiagnostico, a.observacion observDiag from tbl_sal_eval_nutric_diag a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.codigo_eval = "+code+"  order by a.codigo_eval desc";
 
al = SQLMgr.getDataList(sql);
diagLastLineNo = al.size();
      for (int i=0; i<al.size(); i++)
      {
        cdo1 = (CommonDataObject) al.get(i);

        if (i < 10) key = "00" + i;
        else if (i < 100) key = "0" + i;
        else key = "" + i;
        cdo1.addColValue("key",key);

        try
        {
          iDiagNu.put(key, cdo1);
          vDiagNu.addElement(cdo1.getColValue("diagnostico"));
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }
	  
	 /* sql="select a.codigo,a.codigo_eval, a.cod_guia,g.nombre,  a.observacion,a.cds,nvl(a.aplicar,'N') aplicar  from tbl_sal_eval_nutric_plan a, tbl_sal_guia g where a.cod_guia(+) = g.id and a.codigo_eval(+) = "+code+" and g.tipo ='PA'  order by a.codigo asc";
	  al2 = SQLMgr.getDataList(sql);
	  
	  pLastLineNo = al.size();
      for (int i=0; i<al.size(); i++)
      {
        cdo1 = (CommonDataObject) al.get(i);

        if (i < 10) key = "00" + i;
        else if (i < 100) key = "0" + i;
        else key = "" + i;
        cdo1.addColValue("key",key);

        try
        {
          iPlan.put(key, cdo1);
          vPlan.addElement(cdo1.getColValue("cod_guia"));
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }
	*/
}

if(!viewMode) mode = "edit";

}else if(code.trim().equals("0") || cdo == null)
{
	
		cdo = new CommonDataObject();
		cdo.addColValue("fecha",cDateTime.substring(0,10));	
		cdo.addColValue("evaluacionInicial","");
		cdo.addColValue("evaluado_por",""+UserDet.getName());	
		
		if(!viewMode) mode = "add";
		if(change == null)
		{
		 iDiagNu.clear();
		 vDiagNu.clear();
		}
}


%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'EVALUACION NUTRICIONAL - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function add()
{ 
	window.location = '../expediente/exp_eval_nutricional.jsp?mode=add&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';
}

function showDiagnostico()
{
	abrir_ventana1('../common/check_diagnostico.jsp?fp=evaluacionNutricional&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&diagLastLineNo=<%=diagLastLineNo%>');
}
function setNutricion(k)
{
		var code = eval('document.form00.codigo'+k).value;
		window.location = '../expediente/exp_eval_nutricional.jsp?mode=edit&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+code;
}
function doAction()
{
	//showHide(0);
	setHeight();
	<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("1"))
	{%>
	showDiagnostico();	
	<%}%>
	checkViewMode();
}
function setHeight()
{
	newHeight();
	
}
function isChecked(k)
{
	eval('document.form2.observacion'+k).disabled = !eval('document.form2.aplicar'+k).checked;
	if (eval('document.form2.aplicar'+k).checked)
	{
		eval('document.form2.observacion'+k).className = 'FormDataObjectEnabled';
	}
	else
	{
		eval('document.form2.observacion'+k).className = 'FormDataObjectDisabled';
	}
}



function Calc()
{
var total = 0;
var talla =0;
var peso=0;

if(isNaN(eval('document.form0.peso').value) || eval('document.form0.peso').value=='') 
alert('Introduzca Peso correcto');
else peso = parseFloat(eval('document.form0.peso').value);


if(isNaN(eval('document.form0.talla').value) || eval('document.form0.talla').value=='') 
alert('Introduzca Volumen correcto');
else talla = parseFloat(eval('document.form0.talla').value);

total = peso / talla;

eval('document.form0.imc').value =total.toFixed(4);
}
function imprimir(){
 abrir_ventana1('../expediente/print_exp_seccion_81.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&code=<%=code%>&desc=<%=desc%>');
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="<%=desc%>"></jsp:param>
  <jsp:param name="displayCompany" value="n"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		    <table align="center" width="100%" cellpadding="5" cellspacing="0">
   
	
				<tr class="TextRow01">
					<td>
						<div id="proc" width="100%" class="exp h150">
						<div id="proced" width="98%" class="child">
						
							<table width="100%" cellpadding="1" cellspacing="0">
							
						 <%fb = new FormBean("form00",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
						 <%=fb.hidden("code",code)%>
                         <%=fb.hidden("desc",desc)%>
							<tr class="TextRow02">
							<tr class="TextRow02">
			<td colspan="3" align="right"></td>
		</tr>
								<td colspan="2">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
								<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar</cellbytelabel> ]</a><%}%>&nbsp;<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ]</a></td>
							</tr>
						 
							<tr class="TextHeader"> 
								<td width="15%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
								<td width="15%"><cellbytelabel id="5">Fecha</cellbytelabel></td>
								<td width="70%"><cellbytelabel id="6">Evaluador</cellbytelabel></td>
							</tr>
	<%
	for (int i=1; i<=al2.size(); i++)
	{
		CommonDataObject cdo2 = (CommonDataObject) al2.get(i-1);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
	%>
			<%=fb.hidden("codigo"+i,cdo2.getColValue("codigo"))%>	
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setNutricion(<%=i%>)" style="text-decoration:none; cursor:pointer">
					
					<!--td><%=i%></td-->
					<td><%=cdo2.getColValue("codigo")%></td>
					<td><%=cdo2.getColValue("fecha")%></td>
					<td><%=cdo2.getColValue("evaluado_por")%></td>
			</tr>
	<%
	}%>
				 <%fb.appendJsValidation("if(error>0)setHeight();");%>			
				<%=fb.formEnd(true)%>	
					
				</table>
			</div>
			</div>
					</td>
				</tr>
	 </table>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB-0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table width="100%" cellpadding="1" cellspacing="1" >
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
  <%=fb.hidden("code",code)%> 
  <%=fb.hidden("tab","0")%> 
  <%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
  <%=fb.hidden("pLastLineNo",""+pLastLineNo)%> 
  <%=fb.hidden("preSize",""+iDiagNu.size())%>
  <%=fb.hidden("desc",desc)%>
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="5">Fecha</cellbytelabel>
      <jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />  
        <jsp:param name="clearOption" value="true" />  
        <jsp:param name="nameOfTBox1" value="fecha" />  
        <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />  
      </jsp:include>
    </td>
	


	<td width="18%"><cellbytelabel id="7">Peso(Kg.)</cellbytelabel>&nbsp; <%=fb.decBox("peso",cdo.getColValue("peso"),true,false,viewMode,7,"Text10",null,"")%></td>
	<td width="49%" colspan="2"><cellbytelabel id="8">Talla(M.)</cellbytelabel>&nbsp; <%=fb.decBox("talla",cdo.getColValue("talla"),true,false,viewMode,7,"Text10",null,"onChange=\"javascript:Calc()\"")%>&nbsp;&nbsp;<cellbytelabel id="9">IMC</cellbytelabel>&nbsp;&nbsp;<%=fb.textBox("imc",cdo.getColValue("imc"),true,false,false,7,7,"Text10","","")%></td>
	
  </tr>
  <tr class="TextRow01">
    <td><cellbytelabel id="10">Evaluado por</cellbytelabel></td>
    <!--td colspan="3"><%=fb.textarea("evaluado_por",cdo.getColValue("evaluado_por"),true,false,viewMode,60,2,200,"","width:100%","")%></td-->
	<td colspan="3"><%=fb.textBox("evaluado_por",cdo.getColValue("evaluado_por"),true,false,false,60,"Text10","","")%>
	
  </tr>
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="11">Evaluaci&oacute;n Inicial</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("eval_inicial",cdo.getColValue("eval_inicial"),true,false,viewMode,60,2,200,"","width:100%","")%></td>
  </tr>
  
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="12">Clasificaci&oacute;n Nutricional</cellbytelabel></td>
    <td colspan="3"><%=fb.select("clasificacion","1=RIESGO DE DESNUTRICION,2=DESNUTRICION, 3=BAJO PESO,4=NORMAL,5=SOBREPESO,6=OBESIDAD,7=OBESIDAD MÓRBIDA",cdo.getColValue("clasificacion"),false,false,0,"S")%></td>
  </tr>
  
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="13">Patr&oacute;n Alimentario Actual</cellbytelabel></td>
    <td colspan="3"><%=fb.select("alimentacion","1=ADECUADO,2=INADECUADO, 3=EXCESIVO,4=DEFICIENTE",cdo.getColValue("alimentacion"),false,false,0,"S")%></td>
  </tr>
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="14">Actividad F&iacute;sica</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("actividad",cdo.getColValue("actividad"),false,false,viewMode,60,2,500,"","width:100%","")%></td>
  </tr>
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="15">Patr&oacute;n Usual de Alimentaci&oacute;n</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("patron_alimentario",cdo.getColValue("patron_alimentario"),false,false,viewMode,60,2,500,"","","")%></td>
  </tr>
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="16">Patr&oacute;n de Evacuaci&oacute;n</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("patron",cdo.getColValue("patron"),false,false,viewMode,60,2,500,"","","")%></td>
  </tr>
   
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="17">Interacci&oacute;n F&aacute;rmaco - Nutrientes</cellbytelabel> </td>
    <td colspan="3"><%=fb.textarea("interaccion",cdo.getColValue("interaccion"),false,false,viewMode,60,2,500,"","","")%></td>
  </tr>
  
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="18">Recomendaciones</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("recomendacion",cdo.getColValue("recomendacion"),true,false,viewMode,60,2,500,"","","")%></td>
  </tr>
  
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="19">Terapia Nutricional Ordenada</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("terapia_nutricional",cdo.getColValue("terapia_nutricional"),false,false,viewMode,60,2,500,"","","")%></td>
  </tr>
 
  
  <tr class="TextRow01">
    <td width="33%"><cellbytelabel id="20">Observaciones</cellbytelabel></td>
    <td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),true,false,viewMode,60,3,500,"","","")%></td>
  </tr>
  <%	
	fb.appendJsValidation("if(error>0)setHeight();");
	%>
  <tr class="TextRow02" align="right">
    <td colspan="4"> <cellbytelabel id="21">Opciones de Guardar</cellbytelabel>:
      <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="22">Mantener Abierto</cellbytelabel> <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="23">Cerrar</cellbytelabel> <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%> </td>
  </tr>
  <%=fb.formEnd(true)%>
</table>

</div><!-- TAB-0 DIV END HERE-->


<!-- TAB-1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" > 
					 <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","1")%>
					 <%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
					 <%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
					 <%=fb.hidden("preSize",""+iDiagNu.size())%>
                     <%=fb.hidden("desc",desc)%>
						<tr class="TextHeader">
								<td width="10%"><cellbytelabel id="24">Diagn&oacute;stico</cellbytelabel></td>
								<td width="45%"><cellbytelabel id="25">Descripci&oacute;n</cellbytelabel></td>
								<td width="40%"><cellbytelabel id="26">Observaci&oacute;n</cellbytelabel></td>								
								<td width="05%" align="center"><%=fb.submit("addDiag","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnostico")%></td>
								
					</tr>
					<%
						al = CmnMgr.reverseRecords(iDiagNu);
for (int i=0; i<iDiagNu.size(); i++)
{
  key = al.get(i).toString();
  cdo1 = (CommonDataObject) iDiagNu.get(key);
				%>		
				 		<%=fb.hidden("key"+i,key)%>
           				<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">						
						<td><%=fb.textBox("diagnostico"+i,cdo1.getColValue("diagnostico"),true,false,true,10,"Text10","","")%></td>
						<td><%=fb.textBox("descDiagnostico"+i,cdo1.getColValue("descDiagnostico"),false,false,true,50,"Text10","","")%></td>					
						<td><%=fb.textarea("observacion"+i,cdo1.getColValue("observDiag"),false,false,(viewMode),30,2,2000,null,"",null)%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>  
						</tr>
							
 <%	}
	fb.appendJsValidation("if(error>0)doAction();");  
	%> 
									
						<tr class="TextRow02" align="right">
								<td colspan="3">
      	<cellbytelabel id="21">Opciones de Guardar</cellbytelabel>: 
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="22">Mantener Abierto</cellbytelabel> 
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="23">Cerrar</cellbytelabel> 
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%> 
								</td>
						</tr>
						<%=fb.formEnd(true)%>				
			</table>	
</div><!-- TAB-1 DIV END HERE-->
<!-- TAB-2 DIV START HERE-->

<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" > 
					 <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","2")%>
					 <%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
					 <%=fb.hidden("pSize",""+al3.size())%>
                     <%=fb.hidden("desc",desc)%>
						<tr class="TextHeader">
								<td width="40%"><cellbytelabel id="25">Descripci&oacute;n</cellbytelabel></td>
								<td width="5%">&nbsp;</td>
								<td width="50%"><cellbytelabel id="26">Observaci&oacute;n</cellbytelabel></td>								
								<td width="05%" align="center"><%//=fb.submit("addPlan","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Plan")%></td>
								
					</tr>
					<%
						//al = CmnMgr.reverseRecords(iPlan);
for (int i=0; i<al3.size(); i++)
{
  key = al3.get(i).toString();
  cdo1 = (CommonDataObject) al3.get(i);
  //cdo1 = (CommonDataObject) iPlan.get(key);
%>		
				 		<%=fb.hidden("key"+i,key)%>
            			<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("cod_guia"+i,cdo1.getColValue("cod_guia"))%>
						<%=fb.hidden("nombre"+i,cdo1.getColValue("nombre"))%>
						<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
						<%=fb.hidden("cds"+i,cdo1.getColValue("cds"))%>
						<%//=fb.hidden("cod_guia"+i,cdo1.getColValue("cod_guia"))%>
						<%//=fb.hidden("cod_guia"+i,cdo1.getColValue("cod_guia"))%>
						<tr class="TextRow01">						
						<td><%=cdo1.getColValue("nombre")%></td>
						<td><%=fb.checkbox("aplicar"+i,"S",(cdo1.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>
						<td><%=fb.textarea("observacion"+i,cdo1.getColValue("observacion"),false,(!cdo1.getColValue("aplicar").equalsIgnoreCase("S")),(viewMode),40,2,2000,null,"",null)%></td>					
						<td align="center"><%//=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>  
						</tr>
 <%	}
	fb.appendJsValidation("if(error>0)doAction();");  %> 
									
						<tr class="TextRow02" align="right">
								<td colspan="3">
      	<cellbytelabel id="21">Opciones de Guardar</cellbytelabel>: 
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="22">Mantener Abierto</cellbytelabel> 
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="23">Cerrar</cellbytelabel> 
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%> 
								</td>
						</tr>
						<%=fb.formEnd(true)%>				
			</table>	
</div><!-- TAB-1 DIV END HERE-->
<!-- MAIN DIV START HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Datos Generales'";
if (!mode.equalsIgnoreCase("add")){
   tabLabel += ",'Diagnóstico','Plan de Accion'";
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

		</td>
	</tr> 		
</table>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	
	
  if (tab.equals("0")) //Evaluacion Nutricional
  {	
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_evaluacion_nutricion");  
	//cdo.setWhereClause("codigo="+request.getParameter("code"));
	
	cdo.addColValue("fecha",request.getParameter("fecha"));
	cdo.addColValue("evaluado_por",request.getParameter("evaluado_por"));	
	cdo.addColValue("eval_inicial",request.getParameter("eval_inicial"));			
	cdo.addColValue("recomendacion",request.getParameter("recomendacion"));
	cdo.addColValue("observacion",request.getParameter("observacion"));	  
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",cDateTime);
	
	cdo.addColValue("clasificacion",request.getParameter("clasificacion"));
	cdo.addColValue("peso",request.getParameter("peso"));
	cdo.addColValue("talla",request.getParameter("talla"));
	cdo.addColValue("imc",request.getParameter("imc"));
	
	cdo.addColValue("alimentacion",request.getParameter("alimentacion"));
	cdo.addColValue("actividad",request.getParameter("actividad"));
	cdo.addColValue("patron",request.getParameter("patron"));
	cdo.addColValue("interaccion",request.getParameter("interaccion"));
	cdo.addColValue("terapia_nutricional",request.getParameter("terapia_nutricional"));
	cdo.addColValue("patron_alimentario",request.getParameter("patron_alimentario"));
	
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion",cDateTime);
		
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");

		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.setWhereClause("codigo="+request.getParameter("code"));
		code = request.getParameter("code");
		SQLMgr.update(cdo);
	}							
	ConMgr.clearAppCtx(null);
	
	}
	else if (tab.equals("1")) //diagnosticos nutricional.
  {
    int size = 0;
    if (request.getParameter("preSize") != null) size = Integer.parseInt(request.getParameter("preSize"));
    String itemRemoved = "",removedItem ="";
		al.clear();
		for (int i=0; i< size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_eval_nutric_diag");  
				cdo.setWhereClause("codigo_eval="+code+" ");
		
			/*	if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{*/
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("codigo_eval="+code+" ");  
				/*}
				else
				{
					cdo.addColValue("codigo",request.getParameter("codigo"+i));
				}*/
				cdo.addColValue("codigo_eval",""+code);	
				cdo.addColValue("diagnostico",request.getParameter("diagnostico"+i));	
				cdo.addColValue("descDiagnostico",request.getParameter("descDiagnostico"+i));	
				cdo.addColValue("observacion",request.getParameter("observacion"+i));
				
				key = request.getParameter("key"+i);

				if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				{
					itemRemoved = key;
					removedItem = request.getParameter("diagnostico"+i);
				}
				else
				{
				 try
					{

						al.add(cdo);
						iDiagNu.put(key,cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}

		}
		if(!itemRemoved.equals(""))
		{
			vDiagNu.remove(removedItem);
			iDiagNu.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&cds="+cds+"&desc="+desc);

return;

		}

		if(baction.equals("+"))//Agregar
		{
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab=1&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&cds="+cds+"&desc="+desc);
				return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();
	
				cdo.setTableName("tbl_sal_eval_nutric_diag");
				cdo.setWhereClause("codigo_eval="+code+" ");
	
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertList(al);
			ConMgr.clearAppCtx(null);
		}
		
	}//END TAB 1
	else if (tab.equals("2")) //Plan de Accion nutricional.
	{
		int size = 0;
		if (request.getParameter("pSize") != null) size = Integer.parseInt(request.getParameter("pSize"));
		
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))
			{
				cdo = new CommonDataObject();
	
				cdo.setTableName("tbl_sal_eval_nutric_plan");  
				cdo.setWhereClause("codigo_eval="+code+" ");
		
				cdo.addColValue("codigo_eval",""+code);	
				cdo.addColValue("cod_guia",request.getParameter("cod_guia"+i));	
				cdo.addColValue("nombre",request.getParameter("nombre"+i));	
						
				key = request.getParameter("key"+i);
				
				if (request.getParameter("cds"+i).equals("0")||request.getParameter("cds"+i).trim().equals(""))
				{
					cdo.addColValue("cds",""+cds);
				}
				else cdo.addColValue("cds",request.getParameter("cds"+i));
				
				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("codigo_eval="+code);
				}
				else cdo.addColValue("codigo",request.getParameter("codigo"+i));
				
				cdo.addColValue("observacion",request.getParameter("observacion"+i));
				cdo.addColValue("aplicar","S");
	
				al.add(cdo);
			}
		}//for
	
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
	
			cdo.setTableName("tbl_sal_eval_nutric_plan");
			cdo.setWhereClause("codigo_eval="+code);
	
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);

	
	
	}
	
		
	
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&cds=<%=cds%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">  
</body>
</html>
<%
}//POST
%>
