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
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ENMgr" scope="page" class="issi.expediente.EvaluacionNutricionalMgr" />
<%
/**
==================================================================================
Fg = ENRS = Evaluation Nutritional Risk Screening.
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ENMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
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

if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "ENRS";//Evaluacion Nutricional Adulto
if (id == null) id = "0";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	
  al = SQLMgr.getDataPropertiesList("select evaluacion from tbl_sal_nutricion_parenteral where pac_id="+pacId+" and admision="+noAdmision+"and tipo = '"+fg+"' order by id desc ");
	
	
	if ( !id.equals("0") ){
	   prop = SQLMgr.getDataProperties("select evaluacion from tbl_sal_nutricion_parenteral where pac_id="+pacId+" and admision="+noAdmision+" and tipo = '"+fg+"' and id="+id+" order by id desc");
	}
	
	if (prop == null)
	{ 
		prop = new Properties();
		prop.setProperty("id","0");
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora_inicio","");
		prop.setProperty("usuario",""+(String) session.getAttribute("_userName"));
	}
	else
	{
		if(!viewMode) modeSec = "edit";
	}

%>

<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Evaluaci&oacute;n Nutricional - '+document.title;
function doAction(){newHeight();}
function setEvaluacion(code){
window.location = '../expediente/exp_tamizaje_nutricional.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>&id='+code;}
function add(){window.location = '../expediente/exp_tamizaje_nutricional.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>&id=0';}
function showDetail(status){var obj=document.getElementById('detail');if(status=='N'){obj.style.display='none';}else if(status=='S'){obj.style.display='';}doAction();}
function isChecked(){var total =0;var total2 =0;var edad = 0;if(!isNaN(parent.document.paciente.edad.value))edad = parent.document.paciente.edad.value;for(k=1;k<=4;k++){if (eval('document.form0.check'+k).checked)total += parseInt(eval('document.form0.valor'+k).value);if (eval('document.form0.ckPuntos'+k).checked)total2 += parseInt(eval('document.form0.puntos'+k).value);}if(edad>=70){total  +=1;total2 +=1;}eval('document.form0.total1').value=total;eval('document.form0.total2').value=total2;}
function imprimir(){abrir_ventana1('../expediente/print_tamizaje_nutricional.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function printExpAll(){abrir_ventana("../expediente/print_tamizaje_nutricional_all.jsp?fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>");}
</script>
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
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
							<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%>
                            <%if(al.size() > 0){%>
                            <a href="javascript:printExpAll();">[<cellbytelabel id="3">Imprimir Todo</cellbytelabel>]</a>
							<%}if(!id.trim().equals("0")){%>
                            <a href="javascript:imprimir();">[<cellbytelabel id="4">Imprimir</cellbytelabel>]</a>
                             <%}%>
                            </td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="5">Fecha</cellbytelabel></td>
							<td  width="15%"><cellbytelabel id="6">Hora</cellbytelabel></td>
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
				<td colspan="2"><%=prop1.getProperty("hora")%></td>

		</tr>
<%}%>
			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",id)%>
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
							<td colspan="4">
								<table align="center" width="100%" cellpadding="1" cellspacing="1">
									<tr class="TextRow01">
										<td width="30%"><cellbytelabel id="5">Fecha</cellbytelabel>:
											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="format" value="dd/mm/yyyy"/>
											<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
											<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
											<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
											</jsp:include></td>
											
											<td width="30%"><cellbytelabel id="6">Hora</cellbytelabel>:
											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="format" value="hh12:mi am"/>
											<jsp:param name="nameOfTBox1" value="<%="hora"%>" />
											<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
											<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
											</jsp:include></td>
											
										<td colspan="70%"><cellbytelabel id="7">Usuario</cellbytelabel><%=fb.textBox("usuario",prop.getProperty("usuario"),false,false,viewMode,50,"Text10",null,null)%></td>
									</tr>
								</table>							</td>
						</tr>
						<tr class="TextHeader">
							
							<td width="44%"><strong><cellbytelabel id="8">&Iacute;ndice de Masa Corporal (IMC)</cellbytelabel></strong></td>
							<td width="5%">&nbsp;</td>
							<td width="7%">&nbsp;</td>
						</tr>
						<tr class="TextHeader">
							
							<td width="44%"><cellbytelabel id="9">Descripci&oacute;n/Criterio</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="10">SI</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="11">NO</cellbytelabel></td>
						</tr>
						
						<tr class="TextRow01">
							
							<td><strong><cellbytelabel id="12">Adultos</cellbytelabel>:</strong> <cellbytelabel id="13">menor de 20.5 &oacute; mayor de 30</cellbytelabel></td>
							<td><%=fb.radio("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar1","N",(prop.getProperty("aplicar1").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
							
							<td><strong><cellbytelabel id="14">Adulto Mayor: ( m&aacute;s de 70  a&ntilde;os)</cellbytelabel> </strong> <cellbytelabel id="15">menor de 22 ó mayor de 30</cellbytelabel></td>
							<td><%=fb.radio("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar2","N",(prop.getProperty("aplicar2").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
							
							<td><strong><cellbytelabel id="16">Embarazada</cellbytelabel>:</strong> <cellbytelabel id="17">menor de 20 &oacute; mayor de 30</cellbytelabel></td>
							<td><%=fb.radio("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar3","N",(prop.getProperty("aplicar3").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
							
							<td>&iquest;<cellbytelabel id="18">El paciente ha perdido peso  en los &uacute;ltimos 3 meses</cellbytelabel> ?</td>
							<td><%=fb.radio("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar4","N",(prop.getProperty("aplicar4").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
							
							<td>&iquest;<cellbytelabel id="19">El paciente ha reducido la  ingesta de alimentos en &uacute;ltima semana</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar5","S",(prop.getProperty("aplicar5").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar5","N",(prop.getProperty("aplicar5").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
						
							<td>&iquest;<cellbytelabel id="20">Es un paciente grave</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar6","S",(prop.getProperty("aplicar6").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar6","N",(prop.getProperty("aplicar6").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextHeader">
						
							<td width="44%"><strong><cellbytelabel id="21">Tamizaje Nutricional en  Pediatr&iacute;a</cellbytelabel></strong></td>
							<td width="5%">&nbsp;</td>
							<td width="7%">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							
							<td>&iquest;<cellbytelabel id="22">El paciente ha reducido la  ingesta de alimentos en la &uacute;ltima  semana</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar7","S",(prop.getProperty("aplicar7").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar7","N",(prop.getProperty("aplicar7").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
							
							<td>&iquest;<cellbytelabel id="23">El paciente tiene vomito o  diarrea</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar8","S",(prop.getProperty("aplicar8").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar8","N",(prop.getProperty("aplicar8").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
						
							<td>&iquest;<cellbytelabel id="25">El Paciente tiene s&iacute;ndrome de  down &oacute; par&aacute;lisis cerebral infantil</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar9","S",(prop.getProperty("aplicar9").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar9","N",(prop.getProperty("aplicar9").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextRow01">
							
							<td>&iquest;<cellbytelabel id="25">Es un paciente grave</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar10","S",(prop.getProperty("aplicar10").equalsIgnoreCase("S")),viewMode,false,null,null,"")%></td>
							<td><%=fb.radio("aplicar10","N",(prop.getProperty("aplicar10").equalsIgnoreCase("N")),viewMode,false,null,null,"")%></td>
						</tr>
						<tr class="TextHeader">
							
							<td width="44%"><strong><cellbytelabel id="26">Nota</cellbytelabel>:</strong></td>
							<td width="5%">&nbsp;</td>
							<td width="7%">&nbsp;</td>
						</tr>
						<tr class="TextHeader">
							
							<td colspan="3"  width="44%"><cellbytelabel id="27">Una &oacute; m&aacute;s respuestas positivas: intervenci&oacute;n de la Nutricionista&nbsp;  para una evaluaci&oacute;n de riesgo nutricional</cellbytelabel>.</td>
						</tr>
						<tr class="TextHeader">
							
							<td colspan="3" width="44%"><cellbytelabel id="28">Ninguna respuesta positiva: orientaci&oacute;n nutricional  sobre la dieta prescrita</cellbytelabel>.</td>
						</tr>
			</table>
			
			<%if(prop.getProperty("aplicar1").equalsIgnoreCase("S") || prop.getProperty("aplicar2").equalsIgnoreCase("S")||prop.getProperty("aplicar3").equalsIgnoreCase("S")|| prop.getProperty("aplicar4").equalsIgnoreCase("S")|| prop.getProperty("aplicar5").equalsIgnoreCase("S")|| prop.getProperty("aplicar6").equalsIgnoreCase("S")|| prop.getProperty("aplicar7").equalsIgnoreCase("S")|| prop.getProperty("aplicar8").equalsIgnoreCase("S")|| prop.getProperty("aplicar9").equalsIgnoreCase("S")|| prop.getProperty("aplicar10").equalsIgnoreCase("S"))displayDetail=""; %>
			
					
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
	prop.setProperty("hora",request.getParameter("hora"));
	prop.setProperty("usuario",request.getParameter("usuario"));
	
	prop.setProperty("id",request.getParameter("id"));
	prop.setProperty("tipo",""+fg);
	
	prop.setProperty("total1",request.getParameter("total1"));
	prop.setProperty("total2",request.getParameter("total2"));
	
	//prop.setProperty("usuario",""+UserDet.getName());
		
	for(int l=1;l<=10;l++)
	{
		prop.setProperty("puntos"+l,request.getParameter("puntos"+l));
		prop.setProperty("ckPuntos"+l,request.getParameter("ckPuntos"+l));
		prop.setProperty("valor"+l,request.getParameter("valor"+l));
		prop.setProperty("check"+l,request.getParameter("check"+l));
		
		prop.setProperty("aplicar"+l,request.getParameter("aplicar"+l));
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>