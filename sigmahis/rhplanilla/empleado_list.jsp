<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
int iconHeight = 40;
int iconWidth = 40;
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String estado = request.getParameter("estado");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
if(fp == null || fp == "") fp ="RRHH";
if(fg == null || fg == "") fg ="RRH";

if (codigo == null) codigo = "";
if (estado == null) estado = "";
if (fDate == null) fDate = "";
if (tDate == null) tDate = "";


if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  String unidad = "",descripcion="",cedula="",nombre="",cargo="",numEmpleado ="",empId="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
    appendFilter += " and upper(nvl(a.pasaporte,a.cedula1)) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
	cedula = request.getParameter("cedula");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(a.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
	nombre = request.getParameter("nombre");
  }
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
  {
    appendFilter += " and upper(a.estado) = "+request.getParameter("estado").toUpperCase();
	estado = request.getParameter("estado");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descripcion = request.getParameter("descripcion");
  }
  if (request.getParameter("codDept") != null && !request.getParameter("codDept").trim().equals(""))
  {
    appendFilter += " and nvl(a.ubic_seccion,seccion) = "+request.getParameter("codDept");
  }
  if (request.getParameter("cargo") != null && !request.getParameter("cargo").trim().equals(""))
  {
    appendFilter += " and c.codigo = "+request.getParameter("cargo");
	cargo = request.getParameter("cargo");
  }
  if (request.getParameter("nameCargo") != null && !request.getParameter("nameCargo").trim().equals(""))
  {
    appendFilter += " and upper(c.denominacion) like '"+request.getParameter("nameCargo").toUpperCase()+"%'";
  }
  if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").trim().equals(""))
  {
    appendFilter += " and upper(a.num_empleado) like '%"+request.getParameter("numEmpleado").toUpperCase()+"%'";
	numEmpleado  = request.getParameter("numEmpleado");
  }
  if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
  {
    appendFilter += " and upper(a.emp_id) like '"+request.getParameter("empId").toUpperCase()+"%'";
	empId = request.getParameter("empId");
  }
  
  if (!fDate.equals("") && !tDate.equals("")){
    appendFilter += " and trunc(a.fecha_ingreso) between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy') ";
  }

		sql="select nvl(a.pasaporte,a.cedula1) as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.nombre_empleado  as nombre ,a.primer_nombre, a.primer_apellido, coalesce(a.ubic_seccion,seccion,-999) as seccion, nvl(b.descripcion,'SIN UBICACION') as descripcion, a.emp_id as empId,a.estado,c.denominacion, d.descripcion as estadodesc, a.num_empleado as numEmpleado, to_char(a.fecha_ingreso,'dd/mm/yyyy') as  fechaIngreso, a.ubic_seccion grupo,a.rata_hora rata from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo c, tbl_pla_estado_emp d where a.compania = b.compania(+) and nvl(a.ubic_seccion,seccion) = b.codigo(+) and a.compania = c.compania and a.cargo = c.codigo and a.estado = d.codigo and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.ubic_seccion, a.nombre_empleado";
	if (request.getParameter("numEmpleado") != null){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");}

if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";

  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);

  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;

  if(rowCount==0) pVal=0;
  else pVal=preVal;

 %>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Planilla - Expedientes de Empleados - '+document.title;
function  printList(){abrir_ventana('../rhplanilla/print_list_expediente_empleados.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Crear Expediente';break;
		case 1:msg='Editar Expediente';break;
		case 2:msg='Ver Expediente';break;
		case 3:msg='Imprimir Expediente';break;
		case 4:msg='Corregir Cédula/Pass.';break;
		case 5:msg='Registrar Fallecimiento';break;
		case 6:msg='Corregir Número de Empleado';break;
		case 7:msg='Horas Extras';break;
		case 8:msg='Ausencias y Tardanzas';break;
		case 9:msg='Otras Transacciones';break;
		case 10:msg='Ver Transacciones';break;
		case 11:msg='Registrar Liquidacion';break;
		case 12:msg='Imprimir Idoneidad';break;
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
function setIndex(k)
{
	document.result.index.value=k;
}
function goOption(option)
{
	if(option==undefined) alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0) abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?fp=<%=fp%>&fg=<%=fg%>');
    else if (option==12) {
       var empId = "&emp_id="; 
       if (document.result.index.value) empId += document.getElementById("empId"+document.result.index.value).value
       abrir_ventana("../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_list_idoneidad.rptdesign&pCtrlHeader=false&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>"+empId);
    }
	else
	{
		var k=document.result.index.value;
		if(k=='')alert('Por favor seleccione un empleado antes de ejecutar una acción!');
		else
		{
			var msg='';
			var empId=eval('document.result.empId'+k).value;
			var prov=eval('document.result.provincia'+k).value;
			var sigla=eval('document.result.sigla'+k).value;
			var tomo=eval('document.result.tomo'+k).value;
			var asiento=eval('document.result.asiento'+k).value;
			var estado=eval('document.result.estado'+k).value;
			var numEmp=eval('document.result.numEmp'+k).value;
			var grupo=eval('document.result.grupo'+k).value;
			var rata=eval('document.result.rata'+k).value;
			var fDate= document.getElementById("fDate").value ? $("#fDate").toRptFormat() : '1970-01-01';
			var tDate= document.getElementById("tDate").value ? $("#tDate").toRptFormat() : '1970-01-01';

	if (estado==3 && (option==5||option==7||option==8||option==9||option==11))alert('Accion No está permitida para empleados en estado INACTIVO/CESANTE');
	else if(option==1)abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=edit&prov='+prov+'&sig='+sigla+'&tom='+tomo+'&asi='+asiento+'&emp_id='+empId);
	else if (option==2) abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=view&prov='+prov+'&sig='+sigla+'&tom='+tomo+'&asi='+asiento+'&emp_id='+empId);
	else if (option==3) abrir_ventana('../rhplanilla/check_tabular_emp.jsp?fp=Exped&empId='+empId);
	else if (option==4) abrir_ventana('../rhplanilla/editar_cedula.jsp?mode=edit&id='+empId+'&fp=<%=fp%>');
	else if (option==5)abrir_ventana('../rhplanilla/empl_fallecimiento_detail.jsp?mode=add&provincia='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento+"&empId="+empId+'&numEmpleado='+numEmp+'&fp=<%=fp%>');
	else if (option==6) abrir_ventana('../rhplanilla/editar_cedula.jsp?mode=edit&id='+empId+'&fg=num_empl&fp=<%=fp%>');
	else if (option==7) abrir_ventana('../rhplanilla/reg_sobretiempo_config.jsp?mode=add&prov='+prov+'&sig='+sigla+'&tom='+tomo+'&asi='+asiento+'&grp='+grupo+'&num='+numEmp+'&rath='+rata+"&emp_id="+empId+'&fp=<%=fp%>');
	else if (option==8) abrir_ventana('../rhplanilla/reg_ausencia_config.jsp?mode=add&empId='+empId+'&fp=<%=fp%>');
	else if (option==9) abrir_ventana('../rhplanilla/reg_transac_config.jsp?mode=add&empId='+empId+'&fp=<%=fp%>');
	else if (option==10) abrir_ventana('../rhplanilla/registro_transacciones_list.jsp?empId='+empId+'&fp=<%=fp%>');
	else if (option==11) abrir_ventana('../rhplanilla/reg_liquidacionNew.jsp?empId='+empId+'&fp=<%=fp%>');
		}
	}
}

$(function(){
    allowWriting({
        inputs: "#cargo,#nameCargo",
        listener: "keydown",
        keycode: 9,
        keyboard: true,
        iframe: "#preventPopupFrame",
        searchParams: {
            cargo: "codigo", nameCargo: "denominacion"
        },
        baseUrls: {
            cargo: "../rhplanilla/list_cargo.jsp?noResultClose=1",
            nameCargo: "../rhplanilla/list_cargo.jsp?noResultClose=1",
        }
    });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - MANTENIMIENTO - EXPEDIENTE DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr>
<td><iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe></td>
</tr>


<tr>
	<td align="right" colspan="6">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<%if(!fp.equals("trx")&& !fp.trim().equals("ASIST")){%>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/notes.gif"></a></authtype>
		<%}%>
		<%if(!fp.trim().equals("ASIST")){%>
		<authtype type='1'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/search.gif"></a></authtype>
		<authtype type='2'>
        <a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/printer.gif"></a>
        <a href="javascript:goOption(12)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,12)" onMouseOut="javascript:mouseOut(this,12)" src="../images/print_idoneidad.png"></a>
        </authtype>
	<authtype type='53'><a href="javascript:goOption(4);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/actualizar.gif"></a></authtype>
		<authtype type='51'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/cancel.gif"></a></authtype>
		<authtype type='54'><a href="javascript:goOption(6);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/numeric_cube.gif"></a></authtype>
		<%}%>
		<%if(fp.trim().equals("trx")||fp.trim().equals("ASIST")){%>
		<authtype type='55'><a href="javascript:goOption(7);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/scheduled-tasks.jpg"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(8);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/dollar_circle.gif"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(9);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/dollar_circle_adjust.gif"></a></authtype>
		<authtype type='58'><a href="javascript:goOption(10);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/open-folder.jpg"></a></authtype>
		<%if(fp.trim().equals("trx")){%>
		<authtype type='59'><a href="javascript:goOption(11);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/liq.jpg"></a></authtype><!----><%}}%>
	 </td>
</tr>

	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
		<tr class="TextFilter">
			<td>&nbsp;<cellbytelabel>Nombre</cellbytelabel>:
			<%=fb.textBox("nombre","",false,false,false,15,null,null,null)%>
			&nbsp;<cellbytelabel>C&eacute;dula/Pass</cellbytelabel>:
			<%=fb.textBox("cedula","",false,false,false,8,null,null,null)%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>:
			<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_pla_estado_emp order by codigo", "estado",estado,false,false,0,"Text10",null,null,null,"T")%>
            &nbsp;<cellbytelabel>Cargo</cellbytelabel>:
            <%=fb.textBox("cargo","",false,false,false,5,12)%>
			<%=fb.textBox("nameCargo","",false,false,false,25)%>
            </td>
		</tr>
		<tr class="TextFilter">
			<td>
			&nbsp;<cellbytelabel>N&uacute;mero</cellbytelabel>
			<%=fb.textBox("numEmpleado","",false,false,false,13,null,null,null)%>ID.<%=fb.textBox("empId","",false,false,false,13,null,null,null)%>
			
            
            <cellbytelabel id="9">Fecha Ingreso</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
				<jsp:param name="nameOfTBox2" value="tDate"/>
				<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
                <jsp:param name="clearOption" value="true"/>
				</jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <%=fb.submit("go","Ir")%></td>
		</tr>
		<%=fb.formEnd()%>



	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>


</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><authtype type='0'>	<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("cargo",cargo)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("fg",fg)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cargo",cargo)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("fg",fg)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
	<tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
		<td width="10%">&nbsp;<cellbytelabel>C&eacute;dula/Pas.</cellbytelabel></td>
		<td width="25%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>Num. Empleado</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>F.Ingreso</cellbytelabel></td>
		<td width="25%">&nbsp;<cellbytelabel>Cargo</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("fg",fg)%>
  <%String descripcionArea = "";
		for (int i=0; i<al.size(); i++)
		{
			 CommonDataObject cdo = (CommonDataObject) al.get(i);
			 String color = "TextRow02";
			 if (i % 2 == 0) color = "TextRow01";
			 if (!descripcionArea.equalsIgnoreCase(cdo.getColValue("descripcion")))
			 {
				%>
				   <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
 	          <td colspan="8" class="TextHeader01"> [<%=cdo.getColValue("seccion")%>] - <%=cdo.getColValue("descripcion")%></td>
           </tr>
		  <%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
						<%=fb.hidden("empId"+i,cdo.getColValue("empId"))%>
						<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
						<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
						<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
						<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
						<%=fb.hidden("numEmp"+i,cdo.getColValue("numEmpleado"))%>
						<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
						<%=fb.hidden("grupo"+i,cdo.getColValue("grupo"))%>
						<%=fb.hidden("rata"+i,cdo.getColValue("rata"))%>
					<td align="right"><%//=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("numEmpleado")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fechaIngreso")%></td>
					<td align="left">&nbsp;<%=cdo.getColValue("denominacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estadodesc")%></td>
					<td align="center">
							<%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
					</td>

				</tr>
                            <%
	descripcionArea = cdo.getColValue("descripcion");
}
%>
<%=fb.formEnd()%>

</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("cargo",cargo)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("fg",fg)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cargo",cargo)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("fg",fg)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>