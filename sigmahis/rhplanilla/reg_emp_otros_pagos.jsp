</%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
===============================================================================
sct0530_rrhh    Propia de Recursos Humanos (fg=O)
sct0530         Departamentos
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
VacMgr.setConnection(ConMgr);
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String fCierre = request.getParameter("fCierre");
String fInicio = request.getParameter("fInicio");
String fFinal = request.getParameter("fFinal");
String periodo = request.getParameter("periodo");
String grupo = request.getParameter("grupo");
String usuario = (String) session.getAttribute("_userName");

if (fg == null) fg = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (quincena == null) quincena = "";
if (fCierre == null) fCierre = "";
if (fInicio == null) fInicio = "";
if (fFinal == null) fFinal = "";
if (periodo == null) periodo = "";
if (grupo == null) grupo = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select codigo, descripcion from tbl_pla_ct_grupo where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	if (fg.equalsIgnoreCase("O")) grupo = "30";
	else if (!UserDet.getUserProfile().contains("0"))
	{
		sbSql.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '");
		sbSql.append(session.getAttribute("_userName"));
		sbSql.append("')");
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
	document.title = 'RRHH - '+document.title;

function doSubmit(value)
{
	document.form0.baction.value = value;
	window.frames['itemFrame'].document.form0.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}
function doAction(){showList();}

//function doAction(){setHeight('itemFrame',document.body.scrollHeight);}

function selAll(){
	var size = window.frames['itemFrame'].document.form0.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form0.chk'+i).checked = true;
	}
}

function deselAll(){
	var size = window.frames['itemFrame'].document.form0.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form0.chk'+i).checked = false;
	}
}


function showList()
{
form0BlockButtons(true);
var grupo=document.form0.grupo.value;
var anio=document.form0.anio.value;
var mes=document.form0.mes.value;
var quincena=document.form0.quincena.value;
var periodo=0;if(grupo.trim()==''||anio.trim()==''||mes.trim()==''||quincena.trim()=='')return false;
var nDay=<%=(fg.equalsIgnoreCase("O"))?10:1%>;
if(grupo==1)nDay=4;
if(quincena==1)periodo=parseInt(mes,10)*2-1;
else periodo=parseInt(mes,10)*2;
var c=splitCols(getDBData('<%=request.getContextPath()%>','to_char(trans_desde,\'dd/mm/yyyy\'), to_char(trans_hasta,\'dd/mm/yyyy\'), to_char(fecha_cierre,\'dd/mm/yyyy\'), case when fecha_cierre + '+nDay+' < trunc(sysdate) then 0 else 1 end','tbl_pla_calendario','periodo = '+periodo+' and tipopla = 1',''));
var fInicio='';
var fFinal='';
var fCierre='';
if(c==null)
{
alert('El CALENDARIO de Planilla no ha sido definida para este periodo!');
}
else
{
fInicio=c[0];
fFinal=c[1];
fCierre=c[2];
if(c[3]==0)
{
fInicio='';
fFinal='';
alert('El CIERRE de la quincena para la cual desea registrar transacciones fue el día: '+fCierre+'. No está permitido registrar transacciones después de esta fecha!');
}}
document.form0.periodo.value=periodo;
document.form0.fInicio.value=fInicio;
document.form0.fFinal.value=fFinal;
document.form0.fCierre.value=fCierre;
var editable=false;
if(periodo!=0&&fInicio.trim()!=''&&fFinal.trim()!='')editable=true;
var mode=(editable)?'':'view';
form0BlockButtons(!editable);
window.frames['itemFrame'].location='../rhplanilla/reg_emp_otros_pagos_det.jsp?mode='+mode+'&fg=<%=fg%>&grupo='+grupo+'&anio='+anio+'&mes='+mes+'&quincena='+quincena+'&periodo='+periodo+'&fInicio='+fInicio+'&fFinal='+fFinal;
return true;
}


function printReport()
{
var grupo			=document.form0.grupo.value;
var anio			=document.form0.anio.value;
var mes				=document.form0.mes.value;
var quincena	=document.form0.quincena.value;
var periodo		=document.form0.periodo.value;
				if(grupo.trim()==''||anio.trim()==''||mes.trim()==''||quincena.trim()==''||periodo.trim()=='')
				alert('Por favor seleccione un grupo o periodo válido!');
				else  abrir_ventana('../rhplanilla/print_emp_otros_pagos.jsp?grupo='+grupo+'&anio='+anio+'&periodo='+periodo);
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Crear Autorización';break;
		case 3:msg='Aprobar Otros Pagos';break;
		case 4:msg='Imprimir Reporte';break;
		case 5:msg='Actualizar Descuento';break;
		case 6:msg='Cancelar Autorización';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}

function goOption(option)
{
	//var k=document.result.index.value;

	var anio='';
	var codigo='';
	var empId='';
	var status ='';

	if(option==0) abrir_ventana('../rhplanilla/reg_autoriza_descuento.jsp?mode=add');
	else
	{
			if (option==3)
			{

				approb();
				}
					else if (option==2)
				{

					window.frames['itemFrame'].document.form0.baction.value = "Aprobacion";
						window.frames['itemFrame'].doSubmit("Aprobacion");
				}

			else if (option==4)
			{
			var grupo			=document.form0.grupo.value;
			var anio			=document.form0.anio.value;
			var mes				=document.form0.mes.value;
			var quincena	=document.form0.quincena.value;
			var periodo		=document.form0.periodo.value;
				if(grupo.trim()==''||anio.trim()==''||mes.trim()==''||quincena.trim()==''||periodo.trim()=='')
				alert('Por favor seleccione un grupo o periodo válido!');
				else  abrir_ventana('../rhplanilla/print_emp_otros_pagos.jsp?grupo='+grupo+'&anio='+anio+'&periodo='+periodo);
				}

			else if (option==5)
			{
				document.result.baction.value = "ACTUALIZAR";document.result.submit();}

			else if (option==6)
			{
				document.result.baction.value = "CANCELAR";document.result.submit();}

	}
}  // end

function approb()
{
	var user = document.form0.usuario.value;
	var size = window.frames['itemFrame'].document.form0.keySize.value;
	var emp_id = "";
	var cadena = "";
		for(i=1;i<=size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form0.chk'+i).checked == true){

		emp_id = eval('window.frames[\'itemFrame\'].document.form0.emp_id'+i).value;
	  cadena = ""+cadena+" "+emp_id+", ";
		}
}  cadena = "("+cadena+" "+emp_id+")";

if (emp_id!='') {

		for(i=1;i<=size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form0.chk'+i).checked == true){

					var anio 						= document.form0.anio.value;
					var mes							= document.form0.mes.value;
					var quincena 					= document.form.periodo.value;
					var grupo							= document.form0.grupo.value;

		if(executeDB('<%=request.getContextPath()%>','call sp_pla_aprobar_otros_pagos('+grupo+',\''+unidad+'\')'));

	}
}

  } else {
alert('Selleccione al menos un Empleado');
 }
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="OTROS PAGOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("errCode","")%>
										<%=fb.hidden("errMsg","")%>
<%=fb.hidden("periodo",periodo)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fInicio",fInicio)%>
<%=fb.hidden("fFinal",fFinal)%>
	<%=fb.hidden("usuario",usuario)%>
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>

	 <authtype type='52'><a href="javascript:goOption(2)"><img height="40" width="40" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/actualizar.gif"></a></authtype>
	 <authtype type='50'><a href="javascript:goOption(4)"><img height="40" width="40" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/printer.gif"></a></authtype> </td>
 </tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel">
			<td>Grupo y Periodo a Reportar</td>
		</tr>
		<tr class="TextFilter">
			<td>
				A&ntilde;o:
				<%=fb.intBox("anio",anio,true,false,false,4,4,"Text10",null,"onChange=\"javascript:showList();\"")%>
				Mes:
				<%=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,"onChange=\"javascript:showList();\"","","S")%>
				Quincena:
				<%=fb.select("quincena","1=PRIMERA,2=SEGUNDA",quincena,false,false,0,"Text10",null,"onChange=\"javascript:showList();\"","","S")%>
				Fecha Cierre:
				<%=fb.textBox("fCierre",fCierre,true,false,true,8,"Text10",null,null)%>
				<% if (fg.equalsIgnoreCase("O")) { %>
				<%=fb.hidden("grupo",grupo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("quincena",quincena)%>

				<%//=fb.button("go","Ir",false,false,"Text10","","onClick=\"javascript:showList()\"")%>
				<% } else { %>
				Grupo:
				<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"grupo",grupo,false,false,0,"Text10",null,"onChange=\"javascript:showList()\"","","S")%>
				<% } %>
			</td>
		</tr>
		<tr class="TextRow02">
			<td align="right">
				<% if (!fg.equalsIgnoreCase("O")) { %>
				<%=fb.button("saveT","Guardar",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
				<%=fb.button("closeT","Cerrar",false,false,"","","onClick=\"javascript:closeWin();\"")%>
				<% } %>
			</td>
		</tr>
		<tr>
			<td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="350" scrolling="yes"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td align="right">
				<%=fb.button("saveB","Guardar",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
				<% if (!fg.equalsIgnoreCase("O")) { %><%=fb.button("closeB","Cerrar",false,false,"","","onClick=\"javascript:closeWin();\"")%><% } %>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<% if (!fg.equalsIgnoreCase("O")) { %>
<%@ include file="../common/footer.jsp"%>
<% } %>
</body>
</html>
<%
}//GET
else
{
///	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fg = request.getParameter("fg");
	if (request.getParameter("baction").equalsIgnoreCase("Notificacion")){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	} else	if (request.getParameter("baction").equalsIgnoreCase("Aprobacion")){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
<%
} else throw new Exception(errMsg);
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>