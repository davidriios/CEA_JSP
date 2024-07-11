<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.EscalaComa"%>
<%@ page import="issi.expediente.DetalleResultadoEscala"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashEsc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaComaMgr"/>
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
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
EscalaComa escComa = new EscalaComa();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String dob = request.getParameter("dob");
String codPac = request.getParameter("codPac");
String fp = request.getParameter("fp");

String fg = request.getParameter("fg");
String subTitle ="",subTitle2="";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "A";
if (fp == null) fp = "E";

if (fg.trim().equals("A")) subTitle += " ADULTO";
else if (fg.trim().equals("N")) subTitle += " PEDIATRICO";
subTitle2 = "EVALUACIÓN DE TRAUMA - "+subTitle;
boolean checkDefault = false;
int rowCount = 0;
String fechaEscala = request.getParameter("fechaEscala");
String horaEscala = request.getParameter("horaEscala");
String fechaEval = request.getParameter("fechaEval");
String horaEval = request.getParameter("horaEval");

int escLastLineNo = 0;
String appendFilter="" , op = "";
String key = "";
int eTotal=0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
HashEsc.clear();
		sql="select to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora , a.total as total,to_char(a.fecha_trauma,'dd/mm/yyyy') as fechaTrauma, to_char(a.hora_trauma,'hh12:mi:ss am') as horaTrauma,a.tipo_eval tipoEval from tbl_sal_escala_coma  a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.tipo ='"+fp+"' and a.tipo_eval = '"+fg+"' order by a.fecha desc, a.hora desc";
al2= SQLMgr.getDataList(sql);

if(fechaEscala == null || fechaEscala.trim().equals(""))
{
		fechaEscala = cDateTime.substring(0,10);
		horaEscala = cDateTime.substring(11);
		modeSec = "add";
		if(!viewMode)viewMode= false;
}

if(fechaEval == null || fechaEval.trim().equals("")){
fechaEval = cDateTime.substring(0,10);
horaEval = cDateTime.substring(11);}
sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, evaluacion_derecha as evaluacionDerecha, evaluacion_izquierda as evaluacionIzquierda, observacion as observacion , to_char(fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(hora_registro,'hh12:mi:ss am') as horaRegistro, total as total from tbl_sal_escala_coma  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaEval+"','dd/mm/yyyy') and  to_date(to_char(hora,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEval+"','hh12:mi:ss am')  and tipo ='"+fp+"' ";
System.out.println("SQL ==== "+sql);
escComa = (EscalaComa) sbb.getSingleRowBean(ConMgr.getConnection(),sql,EscalaComa.class);

		if(escComa == null)
		{		escComa = new EscalaComa();
				escComa.setHora(cDateTime.substring(11));
				escComa.setFecha(cDateTime.substring(0,10));
				escComa.setTotal("0");
				escComa.setEvaluacionDerecha("1");
				escComa.setEvaluacionIzquierda("1");
		}

		 sql="select x.*,case when x.codigo in (10,11,12,13,15)  then 'T' else 'F' end viewMode,decode(x.codigo,10, decode(cod_escala,0,case when x.codEvaluacion>=13 and  x.codEvaluacion <=15 then 1 "
									+" when x.codEvaluacion>=9 and  x.codEvaluacion <=12 then 2"
									+" when x.codEvaluacion>=6 and  x.codEvaluacion <=8 then 3"
									+" when x.codEvaluacion>=4 and  x.codEvaluacion <=5 then 4"
									+" when x.codEvaluacion =3 then 5 else 0 end,0),"

				 +" 11, decode(cod_escala,0,case when x.codEvaluacion>89  then 1"
								+"   when x.codEvaluacion>80 and  x.codEvaluacion <89 then 2"
								 +"  when x.codEvaluacion>=50 and  x.codEvaluacion <=70 then 3"
								 +"  when x.codEvaluacion>=1 and  x.codEvaluacion <=49 then 4"
									+" when x.codEvaluacion =0 then 5 else 0 end,0),"

					+"12, decode(cod_escala,0,case when (x.codEvaluacion>=10 and x.codEvaluacion <=29) then 1 "
									+" when x.codEvaluacion>29 then 2 "
									 +"when x.codEvaluacion>=6 and  x.codEvaluacion <=9 then 3 "
									+" when x.codEvaluacion>=1 and  x.codEvaluacion <=5 then 4 "
									+" when x.codEvaluacion =0 then 5 else 0 end,0), "

					/*+"12, decode(cod_escala,0,case when (x.codEvaluacion>=10 and x.codEvaluacion <=29) then 4 "
									+" when x.codEvaluacion>29 then 3 "
									 +"when x.codEvaluacion>=6 and  x.codEvaluacion <=9 then 2 "
									+" when x.codEvaluacion>=1 and  x.codEvaluacion <=5 then 1 "
									+" when x.codEvaluacion =0 then 5 else 0 end,0), "*/



					+"13, decode(cod_escala,0,case when x.codEvaluacion>20  then 1"
									+" when x.codEvaluacion>=10 and  x.codEvaluacion <=20	then 2 "
									+" when x.codEvaluacion <10 then 3 "
									+" else 0 end,0),"

					+"15, decode(cod_escala,0,case when x.codEvaluacion /*<=90*/>89  then 1  "
									+" when x.codEvaluacion>=50 and  x.codEvaluacion <=89 then 2  "
									+" when x.codEvaluacion <50  then 3 else 0 end,0), detalle1) detalle "

 +"from( SELECT nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle1, a.descripcion as descripcion , 0 as escala ,b.FECHA_ESCALA, b.HORA_ESCALA , b.OBSERVACION as observacion, nvl(b.VALOR,0) as valor, b.APLICAR  ,decode(a.codigo,10,( select total from tbl_sal_escala_coma where pac_id = "+pacId+" and secuencia = "+noAdmision+" and tipo ='"+fg+"' and  to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaEscala+"','dd/mm/yyyy') and  to_date(to_char(hora,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEscala+"','hh12:mi:ss pm') ),11, (select decode(instr(resultado,'/'),0,null,substr(resultado,1,instr(resultado,'/') - 1)) sistolica from tbl_sal_detalle_signo z where  signo_vital =4 and pac_id="+pacId+"  AND secuencia= "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+"  AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))),12,( select resultado from tbl_sal_detalle_signo z where  signo_vital =3 and pac_id="+pacId+"  AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))), 13,(select resultado  from tbl_sal_detalle_signo z where  /*signo_vital = 6*/ signo_vital = 8  and pac_id="+pacId+" AND secuencia= "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+"  AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))), 15, (select decode(instr(resultado,'/'),0,null,substr(resultado,1,instr(resultado,'/') - 1)) sistolica from tbl_sal_detalle_signo z where  signo_vital =4 and pac_id="+pacId+"  AND secuencia= "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))),'0') codEvaluacion FROM TBL_SAL_TIPO_ESCALA a, (SELECT nvl(TIPO_ESCALA ,0)as tipo_escala, nvl(DETALLE,0)as detalle, FECHA_ESCALA, HORA_ESCALA, OBSERVACION, VALOR, APLICAR FROM TBL_SAL_RESULTADO_ESCALA  where pac_id = "+pacId+"  and secuencia = "+noAdmision+" and to_date(to_char(fecha_escala,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaEval+"','dd/mm/yyyy') and  to_date(to_char(hora_escala,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEval+"','hh12:mi:ss pm') order by 1,2) b where a.codigo=b.tipo_escala(+) and a.tipo = '"+fp+"' union SELECT a.tipo_escala,a.codigo, 0, a.descripcion, a.escala,null, null, null ,0, '',0 FROM TBL_SAL_DETALLE_ESCALA a,(select nvl(TIPO_ESCALA,0) as tipo_escala  from TBL_SAL_RESULTADO_ESCALA a where pac_id = "+pacId+"  and secuencia = "+noAdmision+" order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo='"+fp+"' ORDER BY 1,2 )x ";
		 al = SQLMgr.getDataList(sql);


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'EVALUACION DE TRAUMA - <%=subTitle%> - '+document.title;
function setEscalaValor(k,codigo,valor,value){sumaEscala(value);}
function sumaEscala(valor)
{
	var total = 0; //alert(document.getElementById("alSize").value);
	var subTotal = 0;
	var lc = 0;
	var k =0;
	for (i=1;i<=parseInt(document.getElementById("size").value);i++)
	{
		if(eval('document.form0.escala'+i))
		{	lc =  parseInt(eval('document.form0.lc'+i).value);
			for (j = 0; j < eval('document.form0.escala'+i).length; j++ )
			{
				if(eval('document.form0.escala'+i)[j].checked)
				{
					total +=  parseInt(eval('document.form0.escala'+i)[j].value);
					eval('document.form0.valorL'+i).value = eval('document.form0.escala'+i)[j].value;
					eval('document.form0.escalaDet'+i).value = eval('document.form0.cod_escala'+(lc+j)).value;
				}
			}
		}
		if (eval('document.form0.aux_selected'+i)){
			total +=  parseInt(eval('document.form0.aux_selected'+i).value);
			eval('document.form0.valorL'+i).value = eval('document.form0.aux_selected'+i).value;
			eval('document.form0.escalaDet'+i).value = eval('document.form0.aux_selected'+i).value;
		}
	}
	document.form0.total2.value= total;
}

function setAlert(){alert('No se ha realizado la evaluación');}
function printEscala(){abrir_ventana1('../expediente/print_eval_trauma.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&fp=<%=fp%>&fechaEscala=<%=fechaEscala%>&horaEscala=<%=horaEscala%>&fechaEval=<%=fechaEval%>&horaEval=<%=horaEval%>');}
function verEscala(k,mode){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;var hora_e = eval('document.form0.hora_evaluacion'+k).value ;var fecha_t = eval('document.form0.fecha_trauma'+k).value ;var hora_t = eval('document.form0.hora_trauma'+k).value ;window.location = '../expediente/exp_evaluacion_trauma.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&fg=<%=fg%>&fp=<%=fp%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codPac=<%=codPac%>&dob=<%=dob%>&fechaEscala='+fecha_t+'&horaEscala='+hora_t+'&fechaEval='+fecha_e+'&horaEval='+hora_e;}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMainHeader'),xHeight,200,.25);resetFrameHeight(document.getElementById('_cMain'),xHeight,200,.75);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value= '<%=subTitle2%>'></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<jsp:include page="../common/paciente.jsp" flush="true">
			<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="mode" value="view"></jsp:param>
			<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
		</jsp:include>
	</td>
</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%//fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob",""+dob)%>
<%=fb.hidden("codPac",""+codPac)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("horaEscala",horaEscala)%>
<%=fb.hidden("fechaEscala",fechaEscala)%>
<tr>
	<td>
<div id="_cMainHeader" class="Container">
<div id="_cContentHeader" class="ContainerContent">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel">
			<td colspan="4">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones de Trauma</cellbytelabel> [<%=subTitle%>]</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="25%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="3">Hora</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="4">Puntos</cellbytelabel></td>
			<td width="25%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al2.size(); i++) {
	key = al2.get(i).toString();
	cdo = (CommonDataObject) al2.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("hora_evaluacion"+i,cdo.getColValue("hora"))%>
		<%=fb.hidden("fecha_trauma"+i,cdo.getColValue("fechaTrauma"))%>
		<%=fb.hidden("hora_trauma"+i,cdo.getColValue("horaTrauma"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verEscala(<%=i%>,'view')" align="center">
			<td><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("hora")%></td>
			<td align="center"><%=cdo.getColValue("total")%></td>
			<td>&nbsp;<%//=cdo.getColValue("observacion")%></td>
		</tr>
<% } %>
		</table>
</div>
</div>
	</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td width="45%">
				<cellbytelabel id="2">Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fechaEscala%>"/>
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include>
			</td>
			<td width="45%">
				<cellbytelabel id="3">Hora</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi:ss am"/>
				<jsp:param name="nameOfTBox1" value="hora"/>
				<jsp:param name="valueOfTBox1" value="<%=escComa.getHora()%>"/>
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include>
			</td>
			<td width="10%" align="right"><a href="javascript:printEscala()" class="Link00">[ <cellbytelabel id="5">Imprimir</cellbytelabel> ]</a></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="6">Funciones Neurol&oacute;gicas</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="7">Valor</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="8">Escala</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></td>
		</tr>
<%
int lc=0  ;
String codE = "", observ = "";
String codAnt = "";//al = CmnMgr.reverseRecords(HashDet);
String detalleCod = "",cod_escala="";
boolean codDetSig = false;
for (int i = 0; i <al.size(); i++) {
	key = al.get(i).toString();
	cdo = (CommonDataObject) al.get(i);
	codE = cdo.getColValue("codigo");

	String color = "TextRow02";
	if (cdo.getColValue("cod_escala").equals("0")) {
		lc++;
		if (lc % 2 == 0) color = "TextRow01";
		eTotal += Integer.parseInt(cdo.getColValue("valor"));
		detalleCod = cdo.getColValue("detalle");

		observ = cdo.getColValue("observacion");
		if (cdo.getColValue("detalle").equals("0") && !viewMode) codDetSig = true;
%>
		<%=fb.hidden("tipo_escala"+lc,cdo.getColValue("codigo"))%>
		<%=fb.hidden("codDetalle"+lc,"0")%>
		<%=fb.hidden("opcion","0")%>
		<tr class="<%=color%>">
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%=(cdo.getColValue("codEvaluacion").equals("0")?"":cdo.getColValue("codEvaluacion"))%></td>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="<%=color%>">
<%
		cod_escala ="";
	} else if (!cdo.getColValue("cod_escala").equals("0")) {
%>
		<%=fb.hidden("codDetalle1"+lc,cdo.getColValue("cod_escala"))%>
		<%=fb.hidden("viewMode"+lc,""+cdo.getColValue("viewMode"))%>
		<% if(cod_escala.trim().equals("")) { %>
		<%=fb.hidden("escalaDet"+lc,"")%>
		<%=fb.hidden("valorL"+lc,"")%>
		<%=fb.hidden("lc"+lc,""+i)%>
		<% cod_escala =cdo.getColValue("cod_escala"); } %>

		<%if(detalleCod.equals(cdo.getColValue("cod_escala")) && fg.trim().equals("A")){%>
			<%=fb.hidden("aux_selected"+lc,cdo.getColValue("escala"))%>
		<%}%>
		<tr>
			<td width="5%" valign="top"><%//=lc%>
			<%//=lc%><!---codDetSig ||--para que el primer check este seleccionado-->
			<%=fb.radio("escala"+lc, cdo.getColValue("escala"),(detalleCod.equals(cdo.getColValue("cod_escala"))),(viewMode||fg.trim().equals("A")||cdo.getColValue("viewMode").trim().equals("T")), false , "", "", "onClick=\"javascript:setEscalaValor('"+lc+"','"+cdo.getColValue("cod_escala")+"','"+cdo.getColValue("escala")+"','"+cdo.getColValue("escala")+"')\"")%></td>
			<td valign="top" width="85%"><%=cdo.getColValue("descripcion")%></td>
			<td width="10%" align="right" valign="middle">[<%=cdo.getColValue("escala")%>]</td>
		</tr>
<%
		codDetSig=false;
		if (i < al.size() - 1) {
			CommonDataObject cdox = (CommonDataObject) al.get(i+1);
			codAnt = cdox.getColValue("codigo");
		} else {
%>
				</table>
			</td>
			<td><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,40,3,2000,null,"",null)%></td>
		</tr>
<%
			detalleCod="";
		}
		if (!codAnt.equals(codE)) {
%>
				</table>
			</td>
			<td><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,40,3,2000,null,"",null)%></td>
		</tr>
<%
			detalleCod="";
		}
	}//else
%>
			<%=fb.hidden("valorEscala"+i,cdo.getColValue("escala"))%>
			<%=fb.hidden("cod_escala"+i,cdo.getColValue("cod_escala"))%>
			<%=fb.hidden("desc"+i,cdo.getColValue("descripcion"))%>

<% } %>
<%=fb.hidden("size",""+lc)%>
<%=fb.hidden("alSize",""+al.size())%>
		</table>
</div>
</div>
	</td>
</tr>
<tr class="TextRow02">
	<td align="center"><cellbytelabel id="10">Total</cellbytelabel>:<%=fb.intBox("total2",""+eTotal+"",false,false,true,2)%></td>
</tr>
<tr>
	<td class="TextRow05">
		<% if (fg.equals("A")) { %>
		<cellbytelabel id="11">La puntuaci&oacute;n 0 - 1 - 2 (Alto grado de severidad y baja probabilidades de supervivencia)<br>
			Las puntuaciones 3 - 4 (Altas posibilidades de supervivencia )</cellbytelabel>
		<% } else { %>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td width="25%" class="TextRow05">
				<cellbytelabel id="12">
					9 - 12 Trauma menor<br>
					6 - 8  Muerte Potencial<br>
					0 - 5  Amenaza de muerte<br>
					6 - 1  Usualmente Fatal<br>
				</cellbytelabel>
			</td>
			<td width="75%" class="TextRow05">
				<cellbytelabel id="13">
					1 - No asistencia requerida.<br>
					2 - Proteger via &aacute;erea. Requiere monitoreo continuo si hay cambios, puede requerir posicionamiento.<br>
					3 - Requiere via &aacute;erea definitva.<br>
					4 - Responde a voces, dolor, p&eacute;rdida de consciencia - trastornos.<br>
					5 - Abraz&oacute;n, laceraci&oacute;n menor, quemadura con 10% y que no envuelma mano, cara, pies, genitales.<br>
					6 - Penetraci&oacute;n, lacraci&oacute;n, quemadura > 10% o que no mueva manos,cara, pies.<br>
				</cellbytelabel>
			</td>
		</tr>
		</table>
		<% } %>
	</td>
</tr>
<tr>
	<td align="right">
		<cellbytelabel id="24">Opciones de Guardar</cellbytelabel>:
		<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
		<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="15">Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="16">Cerrar</cellbytelabel>
		<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
<script type="text/javascript">sumaEscala();</script>
</table>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String escala ="";
	int size = 0;
	int tpuntos=0;
	fechaEscala = request.getParameter("fechaEscala");
	horaEscala = request.getParameter("horaEscala");

	fechaEval = request.getParameter("fecha");
	horaEval = request.getParameter("hora");
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

	EscalaComa eco = new EscalaComa();
	eco.setCodPaciente(request.getParameter("codPac"));
	eco.setFecNacimiento(request.getParameter("dob"));
	eco.setSecuencia(request.getParameter("noAdmision"));
	eco.setPacId(request.getParameter("pacId"));
	eco.setFecha(request.getParameter("fecha"));
	eco.setHora(request.getParameter("hora"));
	cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	eco.setFechaRegistro(cDateTime);
	eco.setHoraRegistro(cDateTime.substring(11));
	eco.setEvaluacionDerecha(request.getParameter("derecha"));
	eco.setEvaluacionIzquierda(request.getParameter("izquierda"));
	eco.setFechaCreacion(cDateTime);
	eco.setFechaModificacion(cDateTime);
	eco.setUsuarioCreacion((String) session.getAttribute("_userName"));
	eco.setUsuarioModificacion((String) session.getAttribute("_userName"));
	eco.setTipo(request.getParameter("fp"));


	System.out.println(" fecha trauma ===  "+request.getParameter("fechaEscala"));


	eco.setFechaTrauma(request.getParameter("fechaEscala"));
	eco.setHoraTrauma(request.getParameter("horaEscala"));
	eco.setTipoEval(request.getParameter("fg"));


for (int i=1; i<=size; i++)
{

			System.out.println(" tipo escala( codigo )== "+request.getParameter("tipo_escala"+i)+"escala == "+request.getParameter("escalaDet"+i));

			//if(fp.trim().equals("E"))
			escala = request.getParameter("escalaDet"+i);
			//else escala = request.getParameter("escala"+i);

			if(escala != null && !escala.trim().equals("")){

			DetalleResultadoEscala dre = new DetalleResultadoEscala();

			dre.setTipoEscala(request.getParameter("tipo_escala"+i));//codigo

			//if(request.getParameter("valIni").equals("1"))
			//{
					dre.setDetalle(request.getParameter("escalaDet"+i));//codDetalle
					dre.setValor(request.getParameter("valorL"+i));//
					tpuntos += Integer.parseInt(request.getParameter("valorL"+i));
			//}
			/*else if(request.getParameter("escala"+i) != null)
			{
					dre.setDetalle(request.getParameter("codDetalle"+i));//codDetalle
					dre.setValor(request.getParameter("valor"+i));//
					tpuntos = Integer.parseInt(request.getParameter("total2"));
			}*/
			dre.setAplicar("S");//
			dre.setObservacion(request.getParameter("observacion"+i));	//obsservacion
			dre.setCodPaciente(request.getParameter("codPac"));
			dre.setFecNacimiento(request.getParameter("dob"));
			dre.setSecuencia(request.getParameter("noAdmision"));
			dre.setPacId(request.getParameter("pacId"));
			dre.setFechaEscala(request.getParameter("fecha"));
			dre.setHoraEscala(request.getParameter("hora"));
			eco.addDetalleResultadoEscala(dre);
			}
}
						eco.setTotal(""+tpuntos);
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							ECMgr.add(eco);
						ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ECMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_escala_glasgow.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_escala_glasgow.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%	} %>
<%
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
	window.close();//parent.doRedirect(0);
<%
	}
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&fg=<%=fg%>&fp=<%=fp%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codPac=<%=codPac%>&dob=<%=dob%>&fechaEscala=<%=fechaEscala%>&horaEscala=<%=horaEscala%>&fechaEval=<%=fechaEval%>&horaEval=<%=horaEval%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

