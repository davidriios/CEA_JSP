<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="perHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");
String provincia = "";
String sigla = "";
String tomo = "";
String asiento = "";
String numEmpleado = "";
String empId = "";
String seccion = "";
String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
String mode = request.getParameter("mode");
int perLastLineNo = 0;
int count = 0;
boolean viewMode = true;
if(mode == null) mode = "add";

if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("perLastLineNo") != null && !request.getParameter("perLastLineNo").equals("")) perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
   if (change == null)
   {

	 if(grupo!= null && !grupo.trim().equals(""))
	 {
	 sql = "SELECT a.codigo, to_date(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora_entrada,'hh:mi:ss am') hora_entrada, to_char(a.hora_salida,'hh:mi:ss am') hora_salida, a.estado, a.mfalta, b.descripcion as mfaltaDesc FROM tbl_pla_permiso a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and  ue_codigo="+grupo+" and a.mfalta=b.codigo(+)";
	   al = SQLMgr.getDataList(sql);
	}
	   perHash.clear();
	   perLastLineNo ++;
	   if (perLastLineNo < 10) key = "00" + perLastLineNo;
	   else if (perLastLineNo < 100) key = "0" + perLastLineNo;
	   else key = "" + perLastLineNo;

	   date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi");

	   CommonDataObject per = new CommonDataObject();
	   /*
		 per.addColValue("fecha",date.substring(0,10));
	   per.addColValue("fechaFin",date.substring(0,10));
	   per.addColValue("horaEntrada",date.substring(11));
	   per.addColValue("horaSalida",date.substring(11));
	   per.addColValue("horaDesde",date.substring(11));
	   per.addColValue("horaHasta",date.substring(11));
		 */
	   per.addColValue("codigo",""+perLastLineNo);
	   perHash.put(key,per);
   }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Permisos del Empleado - '+document.title;

function doSubmit()
{
	 var keySize = 0;
	 keySize = parseInt(document.formPermiso.keySize.value);
	 var msg ='';
	 var x =0;

	 for (j=0; j<keySize; j++)
     {
	 	if(eval('document.formPermiso.horaSalida'+j).value ==null || eval('document.formPermiso.horaSalida'+j).value =='' )x++;
		if(eval('document.formPermiso.fecha'+j).value ==null || eval('document.formPermiso.fecha'+j).value =='' )x++;
		if(eval('document.formPermiso.horaEntrada'+j).value ==null || eval('document.formPermiso.horaEntrada'+j).value =='' )x++;
	 }
	 if(x>0){alert('Los Campos Fecha, hora salida y hora Entrada son requeridos Verifique!!'); return false;}
	 if (formPermisoValidation())
	  {

		 document.formPermiso.submit();
	  }
	 document.formPermiso.save.disableOnSubmit = true;
	 if (parent.doRedirect('5','0') == true)
	 {
	 document.formPermiso.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value;
	 for (i=0; i<<%=iEmp.size()%>; i++)
     {

eval('document.formPermiso.provincia'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value;
eval('document.formPermiso.sigla'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value;
eval('document.formPermiso.tomo'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value;
eval('document.formPermiso.asiento'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value;
eval('document.formPermiso.numEmpleado'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
eval('document.formPermiso.empId'+i).value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;

   if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked)
		{
		   eval("document.formPermiso.check"+i).value = 'S';
		}
		else
		{
		   eval("document.formPermiso.check"+i).value = 'N';
		}
	 }
	 document.formPermiso.baction.value = "Guardar";
	 parent.unCheckAll('2');
	 //rte
   	  if (formPermisoValidation())
	  {

		 document.formPermiso.submit();
	  }
     }
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}


function doAction()
{
	newHeight();
	parent.setHeight('secciones',document.body.scrollHeight);
//	sumHoras(0,0,0);
}
function sumHoras()
{
  var i = 0;
  var fechaIni = "";
  var fechaFin = "";

  for (i=0;i<<%=perHash.size()%>;i++)
  {
    fechaIni = eval('document.formPermiso.fecha'+i).value;
	fechaFin = eval('document.formPermiso.fechaFin'+i).value;

	  var ini = new Date(fechaIni);
	  var fin = new Date(fechaFin);
	  var hour = 0;
	  var minu = 0;

	  eval('document.formPermiso.cod_turno_ini'+i).value = hour;
	  eval('document.formPermiso.dsp_turno_ini'+i).value = ini;

	  eval('document.formPermiso.cod_turno_fin'+i).value = hour;
	  eval('document.formPermiso.dsp_turno_fin'+i).value = fin;

  }
}


function getDiasLaborados()
{
	var fecha_final = document.form2.fecha_final.value;
	var fecha_inicio = document.form2.fecha_inicio.value;
	var emp_id = document.form2.emp_id.value;
	var rata_x_hora = document.form2.rata_x_hora.value;
	var rata_x_horagr = document.form2.rata_x_horagr.value;

	if(fecha_inicio != '' && fecha_final != '')
	{
		var x = getDBData('<%=request.getContextPath()%>', 'getDiasLaborados(<%=(String) session.getAttribute("_companyId")%>, '+emp_id+', \''+fecha_inicio+'\', \''+fecha_final+'\')','dual','','');
		var arr_cursor = new Array();
		if(x!='')
		{
			arr_cursor = splitCols(x);
			if(arr_cursor[0]!=' ') document.form2.horas_regulares.value	= arr_cursor[0];
			if(arr_cursor[1]!=' ') document.form2.horas_sabados.value	= arr_cursor[1];
			if(arr_cursor[2]!=' ') document.form2.dias_laborados.value	= arr_cursor[2];
			document.form2.salario_pagar.value = arr_cursor[0] * rata_x_hora;
			document.form2.salario_pagargr.value = arr_cursor[0] * rata_x_horagr;

		}
	}
}


function turnoIni(i)
{
  var fechaIni = "";
  var cod = 0;
	var nulo = 0;
	var emp_id = "";
	var num_emp = "";
  var msg ="";
	var anio = "";
	var mes = "";
	var dia ="";
	var mode = "add";
	var grupo = "";

	 for (j=0; j<<%=iEmp.size()%>; j++)
    {
		 if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+j).checked)
				{
				msg = ' .';
				cod ++;
				emp_id =	eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+j).value;
				num_emp =	eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+j).value;
			  grupo =	eval("parent.frames['iEmpleado'].document.formEmpleado.grupo").value;
						if (cod == 1 ) msg = '';
				} else nulo++;
		}

	if (nulo == <%=iEmp.size()%>)  msg += '.. No hay seleccionados..';

	if(msg!='')
	{
	alert('Verifique la Seleccion de Empleados'+msg+'!');
	 } else
	{

			for (i=0;i<<%=perHash.size()%>;i++)
			{
			fechaIni = eval('document.formPermiso.fecha'+i).value;
		 	var ini = new Date(fechaIni);

			var count	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_inasistencia_emp', 'compania = <%=(String) session.getAttribute("_companyId")%> and estado <> \'EL\'  and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaIni+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
			if(count>0){ alert('Tiene registrada una Inasistencia para esta fecha,  Verifique e inténtelo nuevamente!'); }
			else
			{
			var countIn	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_permiso', 'compania = <%=(String) session.getAttribute("_companyId")%> and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaIni+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
			if(countIn>0)
			{ alert('Tiene registrada un Permiso para esta fecha,  Verifique e inténtelo nuevamente!'); }
			else { if(fechaIni != '' )
			{
			var x = getDBData('<%=request.getContextPath()%>', 'getDataVarios(\''+fechaIni+'\','+emp_id+',\''+num_emp+'\',<%=(String) session.getAttribute("_companyId")%>,'+grupo+',\''+mode+'\')','dual','','');

			var arr_cursor = new Array();
			if(x!='')
			{
			arr_cursor = splitCols(x);
			if(arr_cursor[3]!=' ') eval('document.formPermiso.prog_turno_ini'+i).value = arr_cursor[3];
			if(arr_cursor[4]!=' ') eval('document.formPermiso.cod_turno_ini'+i).value = arr_cursor[4];
			if(arr_cursor[5]!=' ') eval('document.formPermiso.dsp_turno_ini'+i).value = arr_cursor[5];
			}
			}}}
			}	} }

function turnoFin(i)
{
  var fechaFin = "";
  var cod = 0;
	var nulo = 0;
	var emp_id = "";
	var num_emp = "";
  var msg ="";
	var anio = "";
	var mes = "";
	var dia ="";
	var mode = "add";
	var grupo = "";

	 for (j=0; j<<%=iEmp.size()%>; j++)
    {
		 if (eval("parent.frames['iEmpleado'].document.formEmpleado.check"+j).checked)
				{
				msg = ' .';
				cod ++;
				emp_id =	eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+j).value;
				num_emp =	eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+j).value;
			  grupo =	eval("parent.frames['iEmpleado'].document.formEmpleado.grupo").value;
				if (cod == 1 ) msg = '';
				} else nulo++;
		}

	if (nulo == <%=iEmp.size()%>)  msg += '.. No hay seleccionados..';

	if(msg!='')
	{
	alert('Verifique la Seleccion de Empleados'+msg+'!');
	 } else
	{

			for (i=0;i<<%=perHash.size()%>;i++)
			{
			fechaFin = eval('document.formPermiso.fechaFin'+i).value;
		 	var ini = new Date(fechaFin);

		var count	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_inasistencia_emp', 'compania = <%=(String) session.getAttribute("_companyId")%> and estado <> \'EL\'  and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaFin+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
		if(count>0){
						alert('Tiene registrada una Inasistencia para esta fecha,  Verifique e inténtelo nuevamente!');
							}
							else
							{
		var countIn	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_permiso', 'compania = <%=(String) session.getAttribute("_companyId")%> and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaFin+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
					if(countIn>0)
						{
						alert('Tiene registrada un Permiso para esta fecha,  Verifique e inténtelo nuevamente!');
						}
					else
						{
					if(fechaFin != '' )
					{
		var x = getDBData('<%=request.getContextPath()%>', 'getDataVarios(\''+fechaFin+'\','+emp_id+',\''+num_emp+'\',<%=(String) session.getAttribute("_companyId")%>,'+grupo+',\''+mode+'\')','dual','','');

				var arr_cursor = new Array();
						if(x!='')
							{
								arr_cursor = splitCols(x);
								if(arr_cursor[3]!=' ') eval('document.formPermiso.prog_turno_fin'+i).value = arr_cursor[3];
								if(arr_cursor[4]!=' ') eval('document.formPermiso.cod_turno_fin'+i).value = arr_cursor[4];
							  if(arr_cursor[5]!=' ') eval('document.formPermiso.dsp_turno_fin'+i).value = arr_cursor[5];
							}
						}}}
  		}}}


function addMotivo(index)
{
 abrir_ventana1("../common/search_motivo_falta.jsp?fp=permisos_empleado&index="+index);
}

function addLicencia(index)
{
   var inact ="";
   {
   abrir_ventana1("../common/search_motivo_licencia.jsp?fp=permisos_empleado&index="+index);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
    <%fb = new FormBean("formPermiso",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("perLastLineNo",""+perLastLineNo)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("area",area)%>
		<%=fb.hidden("ue_codigo",grupo)%>
		<%=fb.hidden("grupo",grupo)%>
		<%=fb.hidden("keySize",""+perHash.size())%>

		<%
		   for (int i=0; i<iEmp.size(); i++)
		   {
		%>
		<%=fb.hidden("provincia"+i,"")%>
		<%=fb.hidden("sigla"+i,"")%>
		<%=fb.hidden("tomo"+i,"")%>
		<%=fb.hidden("asiento"+i,"")%>
		<%=fb.hidden("numEmpleado"+i,"")%>
		<%=fb.hidden("empId"+i,"")%>
		<%=fb.hidden("check"+i,"")%>
		<%
			   }
		%>
		<%
				  String js = "";
					String j = "1";
					// 	String fecha_tasignado = "fecha_tasignado"+j, functionName = "verificaData("+j+")";
				    al = CmnMgr.reverseRecords(perHash);
				    for (int i = 0; i <perHash.size(); i++)
						//perHash.size()
				    {
					  key = al.get(i).toString();
					  CommonDataObject per = (CommonDataObject) perHash.get(key);
						String functionName = "turnoIni("+i+")" , functionFin = "turnoFin("+i+")";

		%>

	<tr class="TextHeader01">
		<td colspan="3">REGISTRO DE PERMISOS</td>
	</tr>
		<tr class="TextRow01">
		<td width="92">&nbsp;</td>
		<td width="443">&nbsp;</td>
		<td width="430">&nbsp;</td>
	</tr>

  <tr class="TextRow02"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	<td width="85">Motivo</td>
			<td width="398"><%=fb.intBox("mfalta"+i,per.getColValue("mfalta"),true,false,true,5,3,"Text10",null,null)%><%=fb.textBox("mfaltaDesc"+i,per.getColValue("mfaltaDesc"),false,false,true,40,60,"Text10",null,null)%><%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
			<td width="498">C&oacute;digo&nbsp;&nbsp;<%=fb.intBox("codigo"+i,per.getColValue("codigo"),false,false,true,10,1)%></td>
	</tr>


  <tr class="TextRow01">
			<td>Tipo Licencia</td>
			<td><%=fb.intBox("motivo_lic"+i,per.getColValue("motivo_lic"),false,false,true,5,4,"Text10",null,null)%>
			<%=fb.textBox("motivoLicDesc"+i,per.getColValue("motivoLicDesc"),false,false,true,40,60,"Text10",null,null)%>
			<%=fb.button("btnlicencia"+i,"...",false,viewMode,null,null,"onClick=\"javascript:addLicencia("+i+")\"")%>	</td>

			<td>Estado&nbsp;&nbsp;<%=fb.select("estado"+i,"ND=No Descontar,DS=Descontar, PE=Pendiente, DV=Devolver",per.getColValue("estado"),false,false,0,"Text10",null,null)%></td>
	</tr>

	<tr class="TextRow01">
	    <td>Fecha Inicio</td>
			<td>	 <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%="fecha"+i%>"/>
      <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("fecha")==null)?"":per.getColValue("fecha")%>" />
      <jsp:param name="fieldClass" value="Text10" />
      <jsp:param name="buttonClass" value="Text10" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="jsEvent" value="<%=functionName%>" />
      <jsp:param name="onChange" value="<%=functionName%>" />
			</jsp:include>  <%=fb.hidden("cod_turno_ini"+i,per.getColValue("cod_turno_ini"))%><%=fb.hidden("prog_turno_ini"+i,per.getColValue("prog_turno_ini"))%> &nbsp;<%=fb.textBox("dsp_turno_ini"+i,per.getColValue("dsp_turno_ini"),false,false,true,40,80,"Text10",null,null)%>
			</td>


			<td> Desde<jsp:include page="../common/calendar.jsp" flush="true">
				 	<jsp:param name="noOfDateTBox" value="1" />
				 	<jsp:param name="nameOfTBox1" value="<%="horaSalida"+i%>"/>
					<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("horaSalida")==null)?"":per.getColValue("horaSalida")%>" />
				 	<jsp:param name="format" value="hh12:mi am" />
				 	<jsp:param name="jsEvent" value="sumHoras()" />
				 	</jsp:include>
					hasta
					<jsp:include page="../common/calendar.jsp" flush="true">
				 	<jsp:param name="noOfDateTBox" value="1" />
				 	<jsp:param name="nameOfTBox1" value="<%="horaEntrada"+i%>"/>
					<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("horaEntrada")==null)?"":per.getColValue("horaEntrada")%>" />
				 	<jsp:param name="format" value="hh12:mi am" />
				 	<jsp:param name="jsEvent" value="sumHoras()" />
				 	</jsp:include>
					</td>
	</tr>

	<tr class="TextRow01">
	    <td>Fecha Final</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%="fechaFin"+i%>"/>
      <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("fechaFin")==null)?"":per.getColValue("fechaFin")%>" />
      <jsp:param name="fieldClass" value="Text10" />
      <jsp:param name="buttonClass" value="Text10" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="jsEvent" value="<%=functionFin%>" />
      <jsp:param name="onChange" value="<%=functionFin%>" />
			</jsp:include> <%=fb.hidden("cod_turno_fin"+i,per.getColValue("cod_turno_fin"))%><%=fb.hidden("prog_turno_fin"+i,per.getColValue("prog_turno_fin"))%>&nbsp;
						<%=fb.textBox("dsp_turno_fin"+i,per.getColValue("dsp_turno_fin"),false,false,true,40,80,"Text10",null,null)%>						</td>
		<td>Desde<jsp:include page="../common/calendar.jsp" flush="true">
				 <jsp:param name="noOfDateTBox" value="1" />
	  			 <jsp:param name="nameOfTBox1" value="<%="horaDesde"+i%>"/>
				 <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("horaDesde")==null)?"":per.getColValue("horaDesde")%>" />
				 <jsp:param name="format" value="hh12:mi am" />
				 <jsp:param name="jsEvent" value="sumHoras()" />
				 </jsp:include>
				 hasta
				 <jsp:include page="../common/calendar.jsp" flush="true">
				 <jsp:param name="noOfDateTBox" value="1" />
	  			 <jsp:param name="nameOfTBox1" value="<%="horaHasta"+i%>"/>
				 <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("horaHasta")==null)?"":per.getColValue("horaHasta")%>" />
				 <jsp:param name="format" value="hh12:mi am" />
				 <jsp:param name="jsEvent" value="sumHoras()" />
				 </jsp:include>
				</td>
	</tr>

	<tr class="TextRow01" >
	    <td>Observaci&oacute;n</td>
	    <td colspan="2"><%=fb.textarea("motivo"+i,per.getColValue("motivo"),false,false,false,77,3)%></td>
	</tr>
				<%}%>
	<tr class="TextRow02">
		<td align="right" colspan="9"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%>
		<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0,1)\"")%>					</td>
	</tr>
            <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
   int keySize=Integer.parseInt(request.getParameter("keySize"));
   perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));
   String ItemRemoved = "";
//   provincia = request.getParameter("provincia");
//   sigla = request.getParameter("sigla");
//   tomo = request.getParameter("tomo");
//   asiento = request.getParameter("asiento");
//   empId = request.getParameter("empId");
   seccion = request.getParameter("seccion");
   area = request.getParameter("area");
   grupo = request.getParameter("grupo");

   if (!request.getParameter("baction").equalsIgnoreCase("Guardar"))
   {
	  for (int i=0; i<keySize; i++)
	  {
	    CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_pla_permiso");

	 	cdo.addColValue("emp_id",empId);
	  cdo.addColValue("fecha",request.getParameter("fecha"+i));
		cdo.addColValue("hora_salida",request.getParameter("horaSalida"+i));
	  cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"+i));
		cdo.addColValue("horas_desde",request.getParameter("horaDesde"+i));
		cdo.addColValue("hora_hasta",request.getParameter("horaHasta"+i));
		cdo.addColValue("fecha_fin",request.getParameter("fechaFin"+i));
		cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
		cdo.addColValue("motivo",request.getParameter("motivo"+i));
		cdo.addColValue("cod_turno_ini",request.getParameter("cod_turno_ini"+i));
		cdo.addColValue("prog_turno_ini",request.getParameter("prog_turno_ini"+i));
		cdo.addColValue("cod_turno_fin",request.getParameter("cod_turno_fin"+i));
		cdo.addColValue("prog_turno_fin",request.getParameter("prog_turno_fin"+i));
		cdo.addColValue("codigo",request.getParameter("codigo"+i));
		cdo.setAutoIncCol("codigo");
		cdo.setAutoIncWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and fecha = '"+request.getParameter("fecha"+i)+"' and emp_id = "+request.getParameter("empId"+i));
		cdo.addColValue("estado",request.getParameter("estado"+i));
		cdo.addColValue("forma_des","1");
		cdo.addColValue("aprobado","N");
		cdo.addColValue("fecha_modificacion", "sysdate");
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	    key = request.getParameter("key"+i);

	if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{
	    ItemRemoved = key;
		}
	else
		{
	try{
		perHash.put(key,cdo);
	    }catch(Exception e){ System.err.println(e.getMessage()); }
		}

	if (!ItemRemoved.equals(""))
	    {
	   list.remove(perHash.get(ItemRemoved));
		   perHash.remove(ItemRemoved);
		   response.sendRedirect("../rhplanilla/empl_permisos_detail.jsp?change=1&perLastLineNo="+perLastLineNo+"&area="+area+"&seccion="+seccion+"&area="+area+"&grupo="+grupo);
		   return;
	    }
      }
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {
           date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	       CommonDataObject cdo2 = new CommonDataObject();
		   cdo2.addColValue("compania","");
		   cdo2.addColValue("provincia","");
		   cdo2.addColValue("sigla","");
		   cdo2.addColValue("tomo","");
		   cdo2.addColValue("asiento","");
		   cdo2.addColValue("fecha",date.substring(0,10));
		   cdo2.addColValue("hora_salida",date.substring(11));
		   cdo2.addColValue("hora_entrada",date.substring(11));
		   cdo2.addColValue("estado","");
		   cdo2.addColValue("forma_des","");
		   cdo2.addColValue("ue_codigo","");
		   cdo2.addColValue("num_empleado","");
		   cdo2.addColValue("mfalta","");
			 cdo2.addColValue("motivo","");
	     cdo2.addColValue("emp_id","");
		   cdo2.addColValue("hora_desde","");
		   cdo2.addColValue("prog_turno_ini","");
			 cdo2.addColValue("cod_turno_ini","");
			 cdo2.addColValue("prog_turno_fin","");
			 cdo2.addColValue("cod_turno_fin","");
		   cdo2.addColValue("hora_hasta","");
		   cdo2.addColValue("codigo","");
		   cdo2.addColValue("fecha_fin","");
		   perLastLineNo++;
		   //cdo2.addColValue("codigo",""+perLastLineNo);

		   if (perLastLineNo < 10) key = "00" + perLastLineNo;
		   else if (perLastLineNo < 100) key = "0" + perLastLineNo;
		   else key = "" + perLastLineNo;

		   perHash.put(key,cdo2);

		   response.sendRedirect("../rhplanilla/empl_permisos_detail.jsp?change=1&perLastLineNo="+perLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo);
		   return;
	  }
	}
	else
	{
	   for (int j=0;j<iEmp.size();j++)
	   {
	    if (request.getParameter("check"+j).equalsIgnoreCase("S"))
		  {
		   for (int i=0; i<keySize; i++)
			 {
		    CommonDataObject cdo = new CommonDataObject();
		  	cdo.setTableName("tbl_pla_permiso");
				cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+grupo+" and emp_id="+request.getParameter("emp_id"+j));

				cdo.addColValue("ue_codigo",grupo);
			//	System.out.println("**eeeeeeeeeeeeeeeeeee**"+grupo+request.getParameter("provincia"+j)+request.getParameter("sigla"+j)+request.getParameter("asiento"+j)+request.getParameter("numEmpleado"+j)+request.getParameter("empId"+j)+request.getParameter("fecha"+i)+request.getParameter("horaSalida"+i)+request.getParameter("horaEntrada"+i)+request.getParameter("mfalta"+i)+request.getParameter("estado"+i));
		 		cdo.addColValue("provincia",request.getParameter("provincia"+j));
		 		cdo.addColValue("sigla",request.getParameter("sigla"+j));
		 		cdo.addColValue("tomo",request.getParameter("tomo"+j));
		 		cdo.addColValue("asiento",request.getParameter("asiento"+j));
		 		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
        cdo.addColValue("num_empleado",request.getParameter("numEmpleado"+j));
				cdo.addColValue("emp_id",request.getParameter("empId"+j));
				cdo.addColValue("fecha",request.getParameter("fecha"+i));
				cdo.addColValue("hora_salida",request.getParameter("horaSalida"+i));
				cdo.addColValue("hora_entrada",request.getParameter("horaEntrada"+i));
				cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
				cdo.addColValue("motivo_lic",request.getParameter("motivo_lic"+i));
				cdo.addColValue("cod_turno_ini",request.getParameter("cod_turno_ini"+i));
		    cdo.addColValue("prog_turno_ini",request.getParameter("prog_turno_ini"+i));
				cdo.addColValue("cod_turno_fin",request.getParameter("cod_turno_fin"+i));
				cdo.addColValue("prog_turno_fin",request.getParameter("prog_turno_fin"+i));
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.setAutoIncWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and fecha = '"+request.getParameter("fecha"+i)+"' and emp_id = "+request.getParameter("empId"+j));
				cdo.setAutoIncCol("codigo");
				cdo.addColValue("estado",request.getParameter("estado"+i));
				cdo.addColValue("forma_des","1");
				cdo.addColValue("aprobado","N");
			  cdo.addColValue("fecha_creacion", "sysdate");
			  cdo.addColValue("fecha_modificacion", "sysdate");
				cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
				cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
				cdo.addColValue("motivo",request.getParameter("motivo"+i));
				cdo.addColValue("hora_desde",request.getParameter("horaDesde"+i));
				cdo.addColValue("hora_hasta",request.getParameter("horaHasta"+i));
				cdo.addColValue("fecha_fin",request.getParameter("fechaFin"+i));

				key = request.getParameter("key"+i);
				perHash.put(key,cdo);
				list.add(cdo);
		     }
	      }
	   }
    }
	SQLMgr.insertList(list);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_permisos_detail.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_permisos_detail.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
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