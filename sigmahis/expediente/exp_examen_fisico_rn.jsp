<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alapgar = new ArrayList();
ArrayList alCordon = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
float eTotal1 = 0.0f, eTotal5 = 0.0f;
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String cod_apgar= request.getParameter("cod_apgar");
String cDate="";
String cTime="";
String rouspan="";
int eTotal=0;
int aTotal=0;
boolean checkDefault = false;
if (tab == null) tab = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	sql = "select a.codigo as cod_apgar, a.descripcion as desc_apgar, b.codigo as cod_pto, b.descripcion as desc_pto, b.valor, c.fecha_nacimiento, c.codigo_paciente, c.secuencia, c.pac_id, c.minuto1, c.minuto5 from tbl_sal_indicador_apgar a, tbl_sal_ptje_x_ind_apgar b, tbl_sal_apgar_neonato c where a.codigo=b.cod_apgar and a.codigo=c.cod_apgar(+) and c.pac_id(+)="+pacId+" and c.secuencia(+)="+noAdmision+" order by a.codigo, b.codigo";
	al = SQLMgr.getDataList(sql);

	//----------------------------------             Listado de Cordon Umbilical        ----------------------------------
	sql = "select a.descripcion, a.codigo as cordon, b.secuencia, nvl(b.respuesta,'N') as respuesta from tbl_sal_rn_cordon a, tbl_sal_evaluacion_cordon b where a.codigo=b.cod_cordon(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" order by a.descripcion";
	alCordon = SQLMgr.getDataList(sql);

	sql = "select fecha_nacimiento, codigo_paciente, secuencia, rn_apgar7, rn_calor as calor, rn_secado as secado, rn_asp_nasofar as aspNaso, rn_asp_gast as aspGast, rn_man_esp_rean as reAnimacion, rn_rean_card as cardiaca, rn_metabol as metabolica, rn_estim_ext as estimulacion, rn_estim_ext_otras as otras, rn_talla as talla, rn_peso as peso, rn_edad_gest_ex_fis as edad, rn_dif_resp as difResp, rn_cp_ictericia as piel, rn_cp_palidez as palidez, rn_cp_cianosis as cianosis, rn_malforma as malForm, rn_neuro as neuro, rn_abdomen as abdomen, rn_orino as orino, rn_exp_meco as meconio, rn_cardio as cardio, pac_id, nvl(to_char(dn_fecha_nacimiento,'dd/mm/yyyy'),' ') as dnFechaNac, nvl(to_char(dn_hora_nacimiento,'hh12:mi:ss am'),' ') as dnHoraNac, nvl(dn_sexo,' ') as dnSexo  from tbl_sal_serv_neonatologia where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);
	if (cdo == null)
	{
		if (!viewMode) mode = "add";
		cdo = new CommonDataObject();
		//cdo.addColValue("FUM","");
		cdo.addColValue("PAC_ID","0");
		cdo.addColValue("SECUENCIA","0");
		cdo.addColValue("CODIGO_PACIENTE","0");
		cdo.addColValue("dnFechaNac","");
		cdo.addColValue("dnHoraNac","");
	}
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - EXAMEN FISICO RECIEN NACIDO'+document.title;
function doAction(){newHeight();calcTotal();}
function focusField(k,x){eval('document.form0.eval'+k).value=x;var cod_apgar=eval('document.form0.cod_apgar'+k).value;var opt=eval('document.form0.valor'+cod_apgar);for(i=0;i<opt.length;i++)opt[i].checked=false;}
function setPto(k,pto){var x=eval('document.form0.eval'+k).value;eval('document.form0.minuto'+x+k).value=pto;calcTotal();}
function calcTotal(){var size=parseInt(document.form0.size.value,10);var total1=0.0;var total5=0.0;for(i=0;i<=size;i++){if(eval('document.form0.minuto1'+i).value.trim()!='')total1+=parseFloat(eval('document.form0.minuto1'+i).value);if(eval('document.form0.minuto5'+i).value.trim()!='')total5+=parseFloat(eval('document.form0.minuto5'+i).value);}document.form0.total1.value=total1;document.form0.total5.value=total5;}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_49.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
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
<tr><td align="right" colspan="3"><a href="javascript:printExp();" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td></tr>
<tr>
	<td>
		<!-- MAIN DIV START HERE -->
		<div id = "dhtmlgoodies_tabView1">
		<!-- TAB0 DIV START HERE-->
		<div class = "dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');if(errors==0)calcTotal();");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("sizeCordon",""+alCordon.size())%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="2">PUNTUACION APGAR</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="32%" rowspan="2"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
			<td width="42%" rowspan="2"><cellbytelabel id="4">Escala</cellbytelabel></td>
			<td colspan="2"><cellbytelabel id="5">Minutos</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="13%">1</td>
			<td width="13%">5</td>
		</tr>
<%
	String apgar = "";
	String minuto1 = "";
	String minuto5 = "";
	String cod_pto = "";
	int ln = -1;
	for (int i=0; i<al.size(); i++)
	{
		
		CommonDataObject cdoS = (CommonDataObject) al.get(i);

		if (!apgar.equals(cdoS.getColValue("cod_apgar")))
		{
			if (i != 0)
			{
%>
				</table>
			</td>
			<td align="center"><%=fb.decBox("minuto1"+ln,minuto1,false,false,viewMode,5,2.2,"Text10","","onClick=\"javascript:focusField("+ln+",1)\" onBlur=\"javascript:calcTotal()\"")%></td>
			<td align="center"><%=fb.decBox("minuto5"+ln,minuto5,false,false,viewMode,5,2.2,"Text10","","onClick=\"javascript:focusField("+ln+",5)\" onBlur=\"javascript:calcTotal()\"")%></td>
		</tr>
<%
			}
			ln++;
			
			
%>
		<%=fb.hidden("cod_apgar"+ln,cdoS.getColValue("cod_apgar"))%>
       
		<%=fb.hidden("eval"+ln,(cdoS.getColValue("minuto1").trim().equals("")||(!cdoS.getColValue("minuto1").trim().equals("")&&!cdoS.getColValue("minuto5").trim().equals("")))?"1":"5")%>
		<tr class="TextRow01">
			<td><%=cdoS.getColValue("desc_apgar")%></td>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0">
<%
		}
%>
				<tr>
					<td align="right">
						<%=cdoS.getColValue("desc_pto")%>
						<%=fb.radio("valor"+cdoS.getColValue("cod_apgar"),cdoS.getColValue("valor"),false,viewMode,false,"Text10","","onClick=\"javascript:setPto("+ln+","+cdoS.getColValue("valor")+")\"")%>
						[<%=cdoS.getColValue("valor")%>]
                <%=fb.hidden("cod_pto"+i,cdoS.getColValue("cod_pto"))%>         
					</td>
				</tr>
<%
		if (i == (al.size() - 1))
		{
%>
				</table>
			</td>
			<td align="center"><%=fb.decBox("minuto1"+ln,cdoS.getColValue("minuto1"),false,false,viewMode,5,2.2,"Text10","","onClick=\"javascript:focusField("+ln+",1)\" onBlur=\"javascript:calcTotal()\"")%></td>
			<td align="center"><%=fb.decBox("minuto5"+ln,cdoS.getColValue("minuto5"),false,false,viewMode,5,2.2,"Text10","","onClick=\"javascript:focusField("+ln+",5)\" onBlur=\"javascript:calcTotal()\"")%></td>
		</tr>
 <%
		}
		apgar = cdoS.getColValue("cod_apgar");
		minuto1 = cdoS.getColValue("minuto1");
		minuto5 = cdoS.getColValue("minuto5");
		
		
		//System.out.println(">>>>>>::::::::::::::::::::::::"+cod_pto+":::::::::::::::::::::::::::::::::::<<<<<<<");
	}//End For
	//ln++;
%>
		<%=fb.hidden("size",""+ln)%>
		<tr class="TextHeader">
			<td colspan="2"><cellbytelabel id="6">Si est&aacute; deprimido al 5to minuto. Tiempo en que logra Apgar 7</cellbytelabel>:
			<%=fb.textBox("apgar7",cdo.getColValue("rn_apgar7"),false,false,viewMode,10,10,"Text10",null,null)%></td>
			<td align="center"><%=fb.decBox("total1","",false,false,true,6,3.2,"Text10",null,null)%>Pts</td>
			<td align="center"><%=fb.decBox("total5","",false,false,true,6,3.2,"Text10",null,null)%>Pts</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
		</div>

<!-------------------------------------  TAB1 DIV START HERE (TAB DE CORDON) ------------------------------------------------- -->
		<div class="dhtmlgoodies_aTab">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+ln)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("sizeCordon",""+alCordon.size())%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2"><cellbytelabel id="10">EVALUACION CORDON UMBILICAL</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="75%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="11">Si</cellbytelabel></td>
		</tr>
<%
	for(int i=0; i<alCordon.size();i++)
	{
		CommonDataObject cdoS = (CommonDataObject) alCordon.get(i);
%>
		<%=fb.hidden("cordon"+i,""+cdoS.getColValue("cordon"))%>
		<tr class="TextRow01">
			<td><%//=cdoS.getColValue("cordon")%>&nbsp;<%=cdoS.getColValue("descripcion")%></td>
			<td align="center"><%=fb.checkbox("respuesta"+i,"S",(cdoS.getColValue("respuesta").equalsIgnoreCase("S")),viewMode,null,null,null)%></td>
		</tr>
<%
	}//End For
%>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
		</div>
<!--MAIN DIV END HERE-->

<!------------------------------------ TAB2 DIV START HERE (TAB DE MANIOBRAS ) --------------------------------------------->
		<div class = "dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+ln)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("sizeCordon",""+alCordon.size())%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="12">GENERALES DEL RECIEN NACIDO</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="25%"><cellbytelabel id="13">Fecha Nacimiento</cellbytelabel></td>
			<td width="22%"><cellbytelabel id="14">Hora Nacimiento</cellbytelabel></td>
			<td colspan="2"><cellbytelabel id="15">Sexo</cellbytelabel></td>

		</tr>
		<tr class="TextRow01" align="center">
			<td>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="dnFechaNac" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("dnFechaNac")%>" />
					</jsp:include>
			</td>
			<td>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="format" value="hh12:mi:ss am" />
					<jsp:param name="nameOfTBox1" value="dnHoraNac" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("dnHoraNac")%>" />
					</jsp:include>
			</td>
			<td>
				<%=fb.radio("dnSexo","F",((cdo.getColValue("dnSexo")!=null && cdo.getColValue("dnSexo").equals("F"))),viewMode,false)%><cellbytelabel id="16">Ni&ntilde;a</cellbytelabel>
			</td>
			<td>
				<%=fb.radio("dnSexo","M",((cdo.getColValue("dnSexo")!=null && cdo.getColValue("dnSexo").equals("M"))),viewMode,false)%><cellbytelabel id="17">Ni&ntilde;o</cellbytelabel>
			</td>
		</tr>

		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="18">MANIOBRAS DE RUTINA</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="25%"><cellbytelabel id="19">Calor</cellbytelabel></td>
			<td width="22%"><cellbytelabel id="20">Secado</cellbytelabel></td>
			<td width="28%"><cellbytelabel id="21">Aspiraci&oacute;n Nasofaringea</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="22">Aspiraci&oacute;n Gastrica</cellbytelabel></td>
		</tr>
		<tr class="TextRow01" align="center">
			<td>
				<%=fb.radio("calor","S",((cdo.getColValue("calor")!=null && cdo.getColValue("calor").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="11">Si</cellbytelabel>
				<%=fb.radio("calor","N",((cdo.getColValue("calor")!=null && cdo.getColValue("calor").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
			</td>
			<td>
				<%=fb.radio("secado","S",((cdo.getColValue("secado")!=null && cdo.getColValue("secado").equals("S"))?true:false),viewMode,false).replaceAll(" id=\"secado\"","")%><cellbytelabel id="11">Si</cellbytelabel>
				<%=fb.radio("secado","N",((cdo.getColValue("secado")!=null && cdo.getColValue("secado").equals("N"))?true:false),viewMode,false).replaceAll(" id=\"secado\"","")%><cellbytelabel id="23">No</cellbytelabel>
			</td>
			<td>
				<%=fb.radio("aspNaso","S",((cdo.getColValue("aspNaso")!= null && cdo.getColValue("aspNaso").equals("S"))?true:false),viewMode,false).replaceAll(" id=\"aspNaso\"","")%><cellbytelabel id="11">Si</cellbytelabel>
				<%=fb.radio("aspNaso","N",((cdo.getColValue("aspNaso")!= null && cdo.getColValue("aspNaso").equals("N"))?true:false),viewMode,false).replaceAll(" id=\"aspNaso\"","")%><cellbytelabel id="23">No</cellbytelabel>
			</td>
			<td>
				<%=fb.radio("aspGast","S",((cdo.getColValue("aspGast")!= null && cdo.getColValue("aspGast").equals("S"))?true:false),viewMode,false).replaceAll(" id=\"aspGasto\"","")%><cellbytelabel id="11">Si</cellbytelabel>
				<%=fb.radio("aspGast","N",((cdo.getColValue("aspGast")!= null && cdo.getColValue("aspGast").equals("N"))?true:false),viewMode,false).replaceAll(" id= \"aspGast\"","")%><cellbytelabel id="23">No</cellbytelabel>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="24">MANIOBRAS ESPECIALES DE REANIMACION</cellbytelabel></td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="28%"><cellbytelabel id="25">Reanimaci&oacute;n</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="26">Cardiaca</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="27">Metab&oacute;lica</cellbytelabel></td>
					<td width="17%"><cellbytelabel id="28">Estimulaci&oacute;n Externa</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="29">Otras</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><%=fb.radio("reanimacion","NH",((cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("NH"))?true:false),viewMode,false)%><cellbytelabel id="30">No se hizo</cellbytelabel></td>
					<td><%=fb.radio("cardiaca","NH",((cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("NH"))?true:false),viewMode,false)%><cellbytelabel id="30">No se hizo</cellbytelabel></td>
					<td><%=fb.radio("metabolica","NH",((cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("NH"))?true:false),viewMode,false)%><cellbytelabel id="30">No se hizo</cellbytelabel></td>
					<td><%=fb.radio("Estimulacion","S",((cdo.getColValue("Estimulacion")!=null && cdo.getColValue("Estimulacion").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute</cellbytelabel>;</td>
					<td><%=fb.radio("otras","S",((cdo.getColValue("otras")!=null && cdo.getColValue("otras").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><%=fb.radio("reanimacion","MS",((cdo.getColValue("reanimacion")!=null && cdo.getColValue("reanimacion").equals("MS"))?true:false),viewMode,false)%><cellbytelabel id="31">M&aacute;scara Simple</cellbytelabel></td>
					<td><%=fb.radio("cardiaca","ME",((cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("ME"))?true:false),viewMode,false)%><cellbytelabel id="33">Masaje Externo</cellbytelabel></td>
					<td><%=fb.radio("metabolica","AL",((cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("AL"))?true:false),viewMode,false)%><cellbytelabel id="34">Alcalinizantes</cellbytelabel></td>
					<td><%=fb.radio("Estimulacion","N",((cdo.getColValue("Estimulacion")!=null && cdo.getColValue("Estimulacion").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></td>
					<td><%=fb.radio("otras","N",((cdo.getColValue("otras")!=null && cdo.getColValue("otras").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><%=fb.radio("reanimacion","MP",((cdo.getColValue("reanimacion")!=null && cdo.getColValue("reanimacion").equals("MP"))?true:false),viewMode,false)%><cellbytelabel id="35">M&aacute;scara Presi&oacute;n Positiva</cellbytelabel></td>
					<td><%=fb.radio("cardiaca","DG",((cdo.getColValue("cardiaca")!= null && cdo.getColValue("cardiaca").equals("DG"))?true:false),viewMode,false)%><cellbytelabel id="36">Drogas</cellbytelabel></td>
					<td colspan="3"><%=fb.radio("metabolica","OT",((cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("OT"))?true:false),viewMode,false)%>Otros</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="5"><%=fb.radio("reanimacion","IN",((cdo.getColValue("reanimacion")!=null && cdo.getColValue("reanimacion").equals("IN"))?true:false),viewMode,false)%>Intubaci&oacute;n</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1" >
					<tr class="TextHeader" align="center">
					<td width="25%"><cellbytelabel id="37">Talla</cellbytelabel></td>
					<td width="22%"><cellbytelabel id="38">Peso</cellbytelabel></td>
					<td width="28%"><cellbytelabel id="39">Edad Gest. por Examen F&iacute;sico</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="40">Dificultad Respiratoria</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" align="center">
					<td><%=fb.textBox("talla",cdo.getColValue("talla"),false,false,viewMode,15,15,"Text10",null,null)%></td>
					<td><%=fb.textBox("peso",cdo.getColValue("peso"),false,false,viewMode,15,15,"Text10",null,null)%></td>
					<td><cellbytelabel id="41">Semanas</cellbytelabel><%=fb.intBox("edad",cdo.getColValue("edad"),false,false,viewMode,5,2)%></td>
					<td>
						<%=fb.radio("difResp","S",((cdo.getColValue("difResp")!=null && cdo.getColValue("difResp").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("difResp","N",((cdo.getColValue("difResp")!=null && cdo.getColValue("difResp").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1" >
				<tr class="TextHeader" align="center">
					<td width="25%"><cellbytelabel id="42">Color de la Piel Ictericia</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="43">Palidez</cellbytelabel></td>
					<td width="18%"><cellbytelabel id="44">Cianosis</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="45">Malformaciones</cellbytelabel></td>
					<td width="22%"><cellbytelabel id="46">Neurologico</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" align="center">
					<td>
						<%=fb.radio("piel","S",((cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("piel","N",((cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("palidez","S",((cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("palidez","N",((cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("cianosis","S",((cdo.getColValue("cianosis")!= null && cdo.getColValue("cianosis").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("cianosis","N",((cdo.getColValue("cianosis")!=null && cdo.getColValue("cianosis").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("malform","S",((cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("malform","N",((cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td align="left">
						<%=fb.radio("neuro","N",((cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="47">Normal</cellbytelabel><br>
						<%=fb.radio("neuro","D",((cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("D"))?true:false),viewMode,false)%><cellbytelabel id="48">Deprimido</cellbytelabel><br>
						<%=fb.radio("neuro","E",((cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("E"))?true:false),viewMode,false)%><cellbytelabel id="49">Exaltado</cellbytelabel>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="25%"><cellbytelabel id="50">Abdomen</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="51">orin&oacute;</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="52">Expulso Meconio</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="53">Cardiovascular</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" align="center">
					<td>
						<%=fb.radio("abdomen","N",((cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="47">Normal</cellbytelabel>
						<%=fb.radio("abdomen","A",((cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("A"))?true:false),viewMode,false)%><cellbytelabel id="54">Anormal</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("orino","S",((cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("orino","N",((cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("meconio","S",((cdo.getColValue("meconio")!=null && cdo.getColValue("meconio").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("meconio","N",((cdo.getColValue("meconio")!=null && cdo.getColValue("meconio").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td colspan="2">
						<%=fb.radio("cardio","S",((cdo.getColValue("cardio")!=null && cdo.getColValue("cardio").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="47">Normal</cellbytelabel>
						<%=fb.radio("cardio","N",((cdo.getColValue("cardio")!= null && cdo.getColValue("cardio").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="54">Anormal</cellbytelabel>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">&nbsp;</td>
		</tr>
		<% fb.appendJsValidation("if(error>0)doAction();"); %>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
		</div>
<!-- MAIN DIV END HERE -->
		</div>
<script type="text/javascript">
<%
String tabLabel = "'Evaluacion Apgar','Cordon','Maniobras'";
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
	int size = Integer.parseInt(request.getParameter("size"));
	int sizeCordon = Integer.parseInt(request.getParameter("sizeCordon"));
	if(tab.equals("0"))
	{
		al = new ArrayList();
		for(int i=0; i<=size; i++)
		{
			CommonDataObject apgar = new CommonDataObject();

			apgar.setTableName("TBL_SAL_APGAR_NEONATO");
			apgar.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
			apgar.addColValue("fecha_nacimiento",request.getParameter("dob"));
			apgar.addColValue("codigo_paciente",request.getParameter("codPac"));
			apgar.addColValue("secuencia",noAdmision);
			apgar.addColValue("cod_apgar",request.getParameter("cod_apgar"+i));
			//apgar.addColValue("cod_ptje",request.getParameter("cod_pto"+i));
			
			apgar.addColValue("minuto1",request.getParameter("minuto1"+i));
			apgar.addColValue("minuto5",request.getParameter("minuto5"+i));
			apgar.addColValue("pac_id",pacId);

			al.add(apgar);
		}//End For

		if(al.size() ==0)
		{
			CommonDataObject apgar = new CommonDataObject();

			apgar.setTableName("TBL_SAL_APGAR_NEONATO");
			apgar.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);

			al.add(apgar);
		}//End If

		CommonDataObject apgar7 = null;
		String apgarMode = "add";
		if (request.getParameter("apgar7") != null && !request.getParameter("apgar7").trim().equals(""))
		{
			apgar7 = new CommonDataObject();
			apgar7.setTableName("TBL_SAL_SERV_NEONATOLOGIA");
			apgar7.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
			apgar7.addColValue("rn_apgar7",request.getParameter("apgar7"));
			if (CmnMgr.getCount("select count(*) from TBL_SAL_SERV_NEONATOLOGIA where pac_id="+pacId+" and secuencia="+noAdmision) > 0) apgarMode = "edit";
			else
			{
				apgar7.addColValue("fecha_nacimiento",request.getParameter("dob"));
				apgar7.addColValue("codigo_paciente",request.getParameter("codPac"));
				apgar7.addColValue("secuencia",noAdmision);
				apgar7.addColValue("pac_id",pacId);
			}
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (apgar7 == null)	SQLMgr.insertList(al);
		else
		{
			SQLMgr.insertList(al,true,true,true,false);
			if (apgarMode.equalsIgnoreCase("add")) SQLMgr.insert(apgar7);
			else if (apgarMode.equalsIgnoreCase("edit")) SQLMgr.update(apgar7);
		}
		ConMgr.clearAppCtx(null);
	}//Enf Tab
	else if (tab.equals("1"))  // Entro en el Tab de Cordon
	{
		al = new ArrayList();
		for (int i=0; i<sizeCordon; i++)
		{
			if (request.getParameter("respuesta"+i) != null && request.getParameter("respuesta"+i).trim().equals("S"))
			{
				CommonDataObject cordon = new CommonDataObject();

				cordon.setTableName("TBL_SAL_EVALUACION_CORDON");
				cordon.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
				cordon.addColValue("fecha_nacimiento",request.getParameter("dob"));
				cordon.addColValue("codigo_paciente",request.getParameter("codPac"));
				cordon.addColValue("pac_id",pacId);
				cordon.addColValue("secuencia",noAdmision);
				cordon.addColValue("respuesta","S");
				cordon.addColValue("cod_cordon",request.getParameter("cordon"+i));

				al.add(cordon);
			}//End IF
		}//End For

		if (alCordon.size() == 0)
		{
			CommonDataObject cordon = new CommonDataObject();

			cordon.setTableName("TBL_SAL_EVALUACION_CORDON");
			cordon.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);

			al.add(cordon);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	else if(tab.equals("2"))//Entro en el Tab de Maniobras
	{
		CommonDataObject neo = new CommonDataObject();

		neo.setTableName("TBL_SAL_SERV_NEONATOLOGIA");
		neo.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
		if(request.getParameter("dnFechaNac")!= null) neo.addColValue("dn_fecha_nacimiento",request.getParameter("dnFechaNac"));
		if(request.getParameter("dnHoraNac")!= null) neo.addColValue("dn_hora_nacimiento",request.getParameter("dnHoraNac"));
		if(request.getParameter("dnSexo")!= null) neo.addColValue("dn_sexo",request.getParameter("dnSexo"));
		if(request.getParameter("calor")!= null) neo.addColValue("rn_calor",request.getParameter("calor"));
		if(request.getParameter("secado") != null) neo.addColValue("rn_secado",request.getParameter("secado"));
		if(request.getParameter("aspNaso") != null) neo.addColValue("rn_asp_nasofar",request.getParameter("aspNaso"));
		if(request.getParameter("aspGast") != null) neo.addColValue("rn_asp_gast",request.getParameter("aspGast"));
		if(request.getParameter("reanimacion") != null) neo.addColValue("rn_man_esp_rean",request.getParameter("reanimacion"));
		if(request.getParameter("cardiaca") != null) neo.addColValue("rn_rean_card",request.getParameter("cardiaca"));
		if(request.getParameter("metabolica") != null) neo.addColValue("rn_metabol",request.getParameter("metabolica"));
		if(request.getParameter("Estimulacion") != null) neo.addColValue("rn_estim_ext",request.getParameter("Estimulacion"));
		if(request.getParameter("otras") != null) neo.addColValue("rn_estim_ext_otras",request.getParameter("otras"));
		neo.addColValue("rn_talla",request.getParameter("talla"));
		neo.addColValue("rn_peso",request.getParameter("peso"));
		neo.addColValue("rn_edad_gest_ex_fis",request.getParameter("edad"));
		if(request.getParameter("difResp") != null) neo.addColValue("rn_dif_resp",request.getParameter("difResp"));
		if(request.getParameter("piel") != null) neo.addColValue("rn_cp_ictericia",request.getParameter("piel"));
		if(request.getParameter("palidez") != null) neo.addColValue("rn_cp_palidez",request.getParameter("palidez"));
		if(request.getParameter("cianosis") != null) neo.addColValue("rn_cp_cianosis",request.getParameter("cianosis"));
		if(request.getParameter("malform") != null) neo.addColValue("rn_malforma",request.getParameter("malform"));
		if(request.getParameter("neuro") != null) neo.addColValue("rn_neuro",request.getParameter("neuro"));
		if(request.getParameter("abdomen") != null) neo.addColValue("rn_abdomen",request.getParameter("abdomen"));
		if(request.getParameter("orino") != null) neo.addColValue("rn_orino",request.getParameter("orino"));
		if(request.getParameter("meconio") != null) neo.addColValue("rn_exp_meco",request.getParameter("meconio"));
		if(request.getParameter("cardio") != null) neo.addColValue("rn_cardio",request.getParameter("cardio"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
		{
			neo.addColValue("fecha_nacimiento",request.getParameter("dob"));
			neo.addColValue("codigo_paciente",request.getParameter("codPac"));
			neo.addColValue("pac_id",pacId);
			neo.addColValue("secuencia",noAdmision);
			SQLMgr.insert(neo);
		}
		else if (modeSec.equalsIgnoreCase("edit"))
		{
			neo.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
			SQLMgr.update(neo);
		}
		ConMgr.clearAppCtx(null);
	}//Enf Tab
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?tab=<%=tab%>&seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>