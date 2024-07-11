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
CommonDataObject cdo = new CommonDataObject();
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


if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
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
	prop = SQLMgr.getDataProperties("select evaluacion from tbl_sal_nutricion_parenteral where id="+id+" ");
	
	if (prop == null)
	{ 
		prop = new Properties();
		prop.setProperty("id","0");
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora",cDateTime.substring(10));
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
document.title = 'Evaluación Nutricional - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){isChecked();newHeight();checkViewMode();}
function setEvaluacion(code){window.location = '../expediente/exp_evaluacion_risk.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id='+code;}
function add(){window.location = '../expediente/exp_evaluacion_risk.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id=0';}
function showDetail(status){var obj=document.getElementById('detail');if(status=='N'){obj.style.display='none';}else if(status=='S'){obj.style.display='';}doAction();}
function isChecked(){var total =0;var total2 =0;var edad = 0;if(!isNaN(parent.document.paciente.edad.value))edad = parent.document.paciente.edad.value;for(k=1;k<=4;k++){if (eval('document.form0.check'+k).checked)total += parseInt(eval('document.form0.valor'+k).value);if (eval('document.form0.ckPuntos'+k).checked)total2 += parseInt(eval('document.form0.puntos'+k).value);}if(edad>=70){total  +=1;total2 +=1;}eval('document.form0.total1').value=total;eval('document.form0.total2').value=total2;}
function imprimir(){abrir_ventana1('../expediente/print_nutritional_risk.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&seccion=<%=seccion%>&desc=<%=desc%>');}

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
                 <%=fb.hidden("desc",desc)%>
						<tr class="TextRow02">
							<td align="right" colspan="5">
                               <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a>
							   <%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ Agregar Evaluación ]</a><%}%>
                            </td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel>Fecha</cellbytelabel></td>
							<td  width="15%">&nbsp;</td>
                            <td  width="15%"><cellbytelabel>Hora</cellbytelabel></td>
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
                <td>&nbsp;</td>
				<td><%=prop1.getProperty("hora")%></td>
                <td>&nbsp;</td>
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
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("cds",cds)%>	
		<tr class="TextRow02">
			<td colspan="9">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="9"><cellbytelabel>TABLA</cellbytelabel> 1</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="9">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td colspan="4">
								<table align="center" width="100%" cellpadding="1" cellspacing="1">
									<tr class="TextRow01">
										<td width="50%"><cellbytelabel>Fecha</cellbytelabel>:
											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="format" value="dd/mm/yyyy"/>
											<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
											<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
											<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
											</jsp:include>
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Hora</cellbytelabel>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
							      			<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="format" value="hh12:mi:ss am"/>
											<jsp:param name="nameOfTBox1" value="hora" />
											<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
                            				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
											</jsp:include>
                                            </td>
											
										<td colspan="50%"><cellbytelabel>Usuario</cellbytelabel><%=fb.textBox("usuario",prop.getProperty("usuario"),false,false,true,50,"Text10",null,null)%></td>
									</tr>
							
								</table>
							</td>
						</tr>
						<tr class="TextHeader">
							<td width="2%"><cellbytelabel>No</cellbytelabel></td>
							<td width="78%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>SI</cellbytelabel></td>
							<td width="10%"><cellbytelabel>NO</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td>1.</td>
							<td>¿<cellbytelabel>IMC</cellbytelabel> < 20.5?</td>
							<td><%=fb.radio("aplicar1","S",(prop.getProperty("aplicar1").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
							<td><%=fb.radio("aplicar1","N",(prop.getProperty("aplicar1").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td>2.</td>
							<td>¿<cellbytelabel>PERDIDA DE PESO EN LOS ULTIMOS 3 MESES</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar2","S",(prop.getProperty("aplicar2").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
							<td><%=fb.radio("aplicar2","N",(prop.getProperty("aplicar2").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td>3.</td>
							<td>¿<cellbytelabel>DISMINUCI&Oacute;N EN LA INGESTA EN LA &Uacute;LTIMA SEMANA</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar3","S",(prop.getProperty("aplicar3").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
							<td><%=fb.radio("aplicar3","N",(prop.getProperty("aplicar3").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td>4.</td>
							<td>¿<cellbytelabel>ENFERMEDAD GRAVE</cellbytelabel>?</td>
							<td><%=fb.radio("aplicar4","S",(prop.getProperty("aplicar4").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
							<td><%=fb.radio("aplicar4","N",(prop.getProperty("aplicar4").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%></td>
						</tr>
			</table>
			
			<%if(prop.getProperty("aplicar1").equalsIgnoreCase("S") || prop.getProperty("aplicar2").equalsIgnoreCase("S")||prop.getProperty("aplicar3").equalsIgnoreCase("S")|| prop.getProperty("aplicar4").equalsIgnoreCase("S"))displayDetail=""; %>
			
			<tr id="detail" style="display:<%=displayDetail%>">
				<td colspan="9">		
					<table align="center" width="100%" cellpadding="1" cellspacing="1">			
						<tr class="TextHeader">
							<td colspan="8"><cellbytelabel>TABLA</cellbytelabel> 2</td>
						</tr>
						<tr class="TextRow05" align="center">
							<td colspan="4"><cellbytelabel>ESTADO NUTRICIONAL</cellbytelabel></td>
							<td colspan="4"><cellbytelabel>SEVERIDAD ENFERMEDAD</cellbytelabel></td>
						</tr>
						<tr class="TextHeader">
							<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Puntos</cellbytelabel></td>
							<td width="5%"><cellbytelabel>S&iacute;</cellbytelabel>&nbsp;</td>
							<td width="25%">D<cellbytelabel>escripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Puntos</cellbytelabel></td>
							<td width="5%"><cellbytelabel>S&iacute;</cellbytelabel>&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td><cellbytelabel>Estado Nutricional Normal</cellbytelabel></td>
							<td><cellbytelabel>Ausente</cellbytelabel></td>
							<td><%=fb.textBox("valor1","0",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("check1","S",(prop.getProperty("check1").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
							<td><cellbytelabel>Requerimientos Nutricionales Normales</cellbytelabel></td>
							<td><cellbytelabel>Ausente</cellbytelabel></td>
							<td><%=fb.textBox("puntos1","0",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("ckPuntos1","S",(prop.getProperty("ckPuntos1").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
						</tr>
						
						<tr class="TextRow02">
							<td><cellbytelabel>P&eacute;rdida de peso > 5 % en 3 meses &oacute; ingesta 50-75 % requerimientos en la ultima semana</cellbytelabel></td>
							<td><cellbytelabel>Leve</cellbytelabel></td>
							<td><%=fb.textBox("valor2","1",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("check2","S",(prop.getProperty("check2").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
							<td><cellbytelabel>Fractura cadera, pacientes cr&oacute;nicos(cirrosis,EPOC, hemodialisis, DM,Oncológicos)</cellbytelabel></td>
							<td><cellbytelabel>Leve</cellbytelabel></td>
							<td><%=fb.textBox("puntos2","1",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("ckPuntos2","S",(prop.getProperty("ckPuntos2").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
						</tr>
						
						<tr class="TextRow01">
							<td><cellbytelabel>P&eacute;rdida de peso > 5 % en 2 meses &oacute; IMC 18.5 - 20.5 + deterioro estado general &oacute; ingesta 25-60 % requerimientos en la &uacute;ltima semana</cellbytelabel> </td>
							<td><cellbytelabel>Moderado</cellbytelabel></td>
							<td><%=fb.textBox("valor3","2",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("check3","S",(prop.getProperty("check3").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
							<td><cellbytelabel>Cirug&iacute;a mayor abdominal,Ictus,Neumon&iacute;a grave,Neoplasias hemotol&oacute;gicas</cellbytelabel></td>
							<td><cellbytelabel>Moderado</cellbytelabel></td>
							<td><%=fb.textBox("puntos3","2",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("ckPuntos3","S",(prop.getProperty("ckPuntos3").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
						</tr>
						
						<tr class="TextRow02">
							<td>P&eacute;rdida de peso > 5 % en 1 meses(>15 % en 3 meses) &oacute; IMC 18.5 + deterioro estado general &oacute; ingesta 0-25 % requerimientos en la &uacute;ltima semana </td>
							<td>Severo</td>
							<td><%=fb.textBox("valor4","3",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("check4","S",(prop.getProperty("check4").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
							<td><cellbytelabel>TCE,TMO, Pacientes cr&iacute;ticos (UCI)</cellbytelabel></td>
							<td><cellbytelabel>Severo</cellbytelabel></td>
							<td><%=fb.textBox("puntos4","3",false,false,true,5,"Text10",null,"")%></td>
							<td><%=fb.checkbox("ckPuntos4","S",(prop.getProperty("ckPuntos4").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked()\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td colspan="2" align="right"><cellbytelabel>Total</cellbytelabel>: </td>
							<td><%=fb.textBox("total1","0",false,false,true,5,"Text10",null,"")%></td>
							<td></td>
							<td colspan="2" align="right"><cellbytelabel>Total</cellbytelabel></td>
							<td><%=fb.textBox("total2","0",false,false,true,5,"Text10",null,"")%></td>
							<td><%//=fb.checkbox("electro20","S",(prop.getProperty("electro20").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
						</tr>
						<tr class="TextRow03">
							<td colspan="8"><cellbytelabel>Si la suma total es >= 3 requiere iniciar un plan de Terapia Nutricional con:<br>1. Suplementación oral + Dieta usual<br>2. Nutrici&oacute;n Enteral por sonda nasoenteral<br>3. Nutrici&oacute;n Parenteral Total o Perif&eacute;rica</cellbytelabel>
							</td>
						</tr>
					</table>
					</td>
				</tr>
			</td>
		</tr>
		
<%fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td colspan="9" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
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
		
	for(int l=1;l<=4;l++)
	{
		prop.setProperty("puntos"+l,request.getParameter("puntos"+l));
		prop.setProperty("ckPuntos"+l,request.getParameter("ckPuntos"+l));
		prop.setProperty("valor"+l,request.getParameter("valor"+l));
		prop.setProperty("check"+l,request.getParameter("check"+l));
		
		prop.setProperty("aplicar"+l,request.getParameter("aplicar"+l));
	}
	prop.setProperty("usuario_mod",(String) session.getAttribute("_userName"));
	prop.setProperty("fecha_mod",cDateTime.substring(0,10));	
	if ((UserDet.getRefType().trim().equalsIgnoreCase("M")))prop.setProperty("medico",""+UserDet.getRefCode());
	else prop.setProperty("medico","");
	prop.setProperty("fec_nacimiento", request.getParameter("dob"));
	prop.setProperty("cod_paciente",request.getParameter("codPac"));
	prop.setProperty("cds",request.getParameter("cds"));
					
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg);
		if (modeSec.equalsIgnoreCase("add")) 
		{	
			prop.setProperty("usuario_creac",(String) session.getAttribute("_userName"));
			prop.setProperty("fecha_creac",cDateTime.substring(0,10));
			
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>