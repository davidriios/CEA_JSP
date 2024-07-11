<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
sct0230a
sct0230s
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String key = "";

StringBuffer sbSqlGrupo = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String aprobada = request.getParameter("aprobada");
String usuario = (String) session.getAttribute("_userName");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (grupo == null) grupo = "";
if (area == null) area = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (aprobada == null) aprobada = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if (fecha == null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";

//if (fp.equalsIgnoreCase("consulta_x_grupo")) {
	sbSqlGrupo.append("select codigo, codigo||' - '||descripcion from tbl_pla_ct_grupo where compania = ");
	sbSqlGrupo.append(session.getAttribute("_companyId"));
	if (!UserDet.getUserProfile().contains("0")) {
		sbSqlGrupo.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '");
		sbSqlGrupo.append(session.getAttribute("_userName"));
		sbSqlGrupo.append("')");
	}
	sbSqlGrupo.append(" order by descripcion");
	if (grupo.trim().equals("")) {
		cdo = SQLMgr.getData(sbSqlGrupo.toString());
		if (cdo != null) grupo = cdo.getColValue("codigo");
	}
//}

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'RRHH - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();setTextValues();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,100);}

function doSubmit(value){
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function imprimir(){
	abrir_ventana('../inventario/print_list_articulos_axa.jsp');
}

function setTextValues(){
	var grupo = document.form1.grupo.value;
	var uf_codigo = document.form1.uf_codigo.value;
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var aprobada=(document.form1.aprobada)?document.form1.aprobada.value:'N';
	v_user = '<%=(String) session.getAttribute("_userName")%>';
	if(uf_codigo =='') uf_codigo='0';
	if(anio!='' && mes !=''){
		if(executeDB('<%=request.getContextPath()%>', 'call sp_pla_prog_turno_borrador(<%=(String) session.getAttribute("_companyId")%>, ' + grupo + ', ' + uf_codigo + ', ' + anio + ', ' + mes + ', \'' + v_user + '\')', '', '')){
			showHideTD(1);
			window.frames['itemFrame'].location = '../rhplanilla/reg_cambio_turno_borrador_det.jsp?grupo='+grupo+'&uf_codigo='+uf_codigo+'&anio='+anio+'&mes='+mes+'&aprobada='+aprobada+'&fp=<%=fp%>';
		}
	}
}

function showHideTD(x){
	if(x=='2'){
		window.frames['itemFrame'].document.getElementById('col_1_15').style.display = 'none';
		window.frames['itemFrame'].document.getElementById('col_16_31').style.display = '';
		document.getElementById('q1').style.display='';
		document.getElementById('q2').style.display='none';
	} else {
		window.frames['itemFrame'].document.getElementById('col_1_15').style.display = '';
		window.frames['itemFrame'].document.getElementById('col_16_31').style.display = 'none';
		document.getElementById('q1').style.display='none';
		document.getElementById('q2').style.display='';
	}
}

function copiar(){
	var index = document.form1.index.value;
	var flag = document.form1.flag.value;
	var dia = document.form1.dia.value;
	document.form1.copied_flag.value=flag;
	if(flag=='d'){
		document.form1.dia_value.value = window.frames['itemFrame'].document.getElementById('dia'+dia+'_'+index).value;
		document.form1.dsp_dia_value.value = window.frames['itemFrame'].document.getElementById('dsp_dia'+dia+'_'+index).value;
	} else if(flag=='u'){
		document.form1.uf_value.value = window.frames['itemFrame'].document.getElementById('uf_dia'+dia+'_'+index).value;
		document.form1.dsp_uf_value.value = window.frames['itemFrame'].document.getElementById('dsp_uf_dia'+dia+'_'+index).value;
	}
}

function pegar(){
	var index = document.form1.index.value;
	var flag = document.form1.flag.value;
	var dia = document.form1.dia.value;
	if(flag=='d'){
		window.frames['itemFrame'].document.getElementById('dia'+dia+'_'+index).value = document.form1.dia_value.value;
		window.frames['itemFrame'].document.getElementById('dsp_dia'+dia+'_'+index).value = document.form1.dsp_dia_value.value;
	} else if(flag=='u'){
		window.frames['itemFrame'].document.getElementById('uf_dia'+dia+'_'+index).value = document.form1.uf_value.value;
		window.frames['itemFrame'].document.getElementById('dsp_uf_dia'+dia+'_'+index).value = document.form1.dsp_uf_value.value;
	}
}
//function printRpt(aprobado){var grupo=document.form1.grupo.value;var area=document.form1.uf_codigo.value;var anio=document.form1.anio.value;var mes=document.form1.mes.value;abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/programa_turno.rptdesign&cpGrupo='+grupo+'&cpArea='+area+'&pAnio='+anio+'&pMonthId='+mes+'&pAprobado='+aprobado);}
function printRpt(aprobado){
var grupo=document.form1.grupo.value;
var area=document.form1.uf_codigo.value || -1;
var anio=document.form1.anio.value;
var mes=document.form1.mes.value;
abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/programa_turno.rptdesign&cpGrupo='+grupo+'&cpArea='+area+'&pAnio='+anio+'&pMonthId='+mes+'&pAprobado='+aprobado+'&pNumEmpleado=0');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="1" id="_tblMain">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fecha_inicio","")%>
<%=fb.hidden("fecha_final","")%>
<%=fb.hidden("finicio","")%>
<%=fb.hidden("ffinal","")%>
<%=fb.hidden("num_periodo","")%>
<%=fb.hidden("index","")%>
<%=fb.hidden("flag","")%>
<%=fb.hidden("copied_flag","")%>
<%=fb.hidden("dia","")%>
<%=fb.hidden("dia_value","")%>
<%=fb.hidden("dsp_dia_value","")%>
<%=fb.hidden("uf_value","")%>
<%=fb.hidden("dsp_uf_value","")%>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel">
			<td>
				Grupo
				<%=fb.select(ConMgr.getConnection(),sbSqlGrupo.toString(),"grupo",grupo,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/areaXGrupo.xml','uf_codigo','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','')\"")%>
				A&ntilde;o<%=fb.textBox("anio",anio,false,false,false,2,"Text10","","")%>
				Mes<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10","","")%>
				<% if (fp.equalsIgnoreCase("consulta_x_grupo")) { %>Estado<%=fb.select("aprobada","N=PENDIENTE,S=APROBADA",aprobada,false,false,0,"Text10","","")%><% } %>
				<%=fb.button("ir","Ir",false,false,"Text10","","onClick=\"javascript:setTextValues();\"")%>
			</td>
			<td rowspan="2"><a href="javascript:printRpt('N')"><img src="../images/printer.gif" border="0" width="24" height="24" alt="Imprimir Programa Turno Pendientes"></a>Pendientes</td>
			<td rowspan="2"><a href="javascript:printRpt('S')"><img src="../images/printer.gif" border="0" width="24" height="24" alt="Imprimir Programa Turno Aprobadas"></a>Aprobadas</td>
			<% if (fp.trim().equals("")) { %>
			<td rowspan="2"><a href="javascript:copiar()"><img src="../images/copy.png" border="0" width="24" height="24" alt="Copiar"></a></td>
			<td rowspan="2"><a href="javascript:pegar()"><img src="../images/paste.png" border="0" width="24" height="24" alt="Pegar"></a></td>
			<% } %>
			<td rowspan="2"><a href="javascript:showHideTD(1)" id="q1" style="display:none"><img src="../images/back-icon.png" border="0" width="24" height="24" alt="Primera Quincena"></a><a href="javascript:showHideTD(2)" id="q2" style="display:"><img src="../images/next-icon.png" border="0" width="24" height="24" alt="Segunda Quincena"></a></td>
		</tr>
		<tr class="TextPanel">
			<td>
				Ubic./Area Trab.<%=fb.select("uf_codigo","","",false,false,0,"Text10","","")%>
				<script language="javascript">
				loadXML('../xml/areaXGrupo.xml','uf_codigo','<%=area%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")+"-"+grupo%>','KEY_COL','T');
				</script>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="0" scrolling="yes" src="../rhplanilla/reg_cambio_turno_borrador_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>"></iframe></td>
		</tr>
<% if (fp.trim().equals("")) { %>
		<tr class="TextRow02">
			<td align="right">Opciones de Guardar:
			<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto
			<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar
			<%=fb.button("save","Guardar",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
			</td>
		</tr>
<% } %>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (errCode.equals("1")) { %>
alert('<%=errMsg%>');
<% if (saveOption.equalsIgnoreCase("O")) { %>
setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
window.close();
<% } %>
<% } else throw new Exception(errMsg); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=add&grupo=<%=grupo%>&area=<%=area%>&anio=<%=request.getParameter("anio")%>&mes=<%=request.getParameter("mes")%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>