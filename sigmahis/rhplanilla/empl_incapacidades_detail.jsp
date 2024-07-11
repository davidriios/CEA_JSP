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
<jsp:useBean id="incHash" scope="session" class="java.util.Hashtable" />
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
String numEmpleado = "";
String seccion = "";
String area = "";
String key = "";
String sql = "";
String curDate = "";
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String grupo = (request.getParameter("grupo")==null?"":request.getParameter("grupo"));;
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
String empNum = (request.getParameter("empNum")==null?"":request.getParameter("empNum"));
String prov = (request.getParameter("prov")==null?"":request.getParameter("prov"));
String sigla = (request.getParameter("sigla")==null?"":request.getParameter("sigla"));
String tomo = (request.getParameter("tomo")==null?"":request.getParameter("tomo"));
String asiento = (request.getParameter("asiento")==null?"":request.getParameter("asiento"));
String nombreEmp = (request.getParameter("nombreEmp")==null?"":request.getParameter("nombreEmp"));
String checkedEmp = (request.getParameter("checkedEmp")==null?"":request.getParameter("checkedEmp"));

if(mes==null) mes = "";
if(anio==null) anio = "";
int incLastLineNo = 0;
int count = 0;

String emp_id = "";

if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("incLastLineNo") != null && !request.getParameter("incLastLineNo").equals("")) incLastLineNo = Integer.parseInt(request.getParameter("incLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change == null)
	{
	  incHash.clear();
    /*sql = "SELECT a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.hora_entrada, a.hora_salida, a.estado,a.mfalta, b.descripcion as mfaltaDesc FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.mfalta=b.codigo(+)";
		al = SQLMgr.getDataList(sql);

		for(int i=0;i<al.size();i++){
			incLastLineNo ++;
			if (incLastLineNo < 10) key = "00" + incLastLineNo;
			else if (incLastLineNo < 100) key = "0" + incLastLineNo;
			else key = "" + incLastLineNo;

			curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

			CommonDataObject inc = (CommonDataObject) al.get(i);
			incHash.put(key,inc);
		}*/


		incLastLineNo ++;
		if (incLastLineNo < 10) key = "00" + incLastLineNo;
		else if (incLastLineNo < 100) key = "0" + incLastLineNo;
		else key = "" + incLastLineNo;

		curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi");

		CommonDataObject inc = new CommonDataObject();
		inc.addColValue("fecha","");
		inc.addColValue("taHent","");
		inc.addColValue("taHsal","");
		inc.addColValue("hora_entrada","");
		inc.addColValue("hora_salida","");
		inc.addColValue("codigo",""+incLastLineNo);
		inc.addColValue("tiempo_horas",""+0);
		inc.addColValue("tiempo_minutos",""+0);
		incHash.put(key,inc);
  }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Incapacidades del Empleado - '+document.title;

function doSubmit()
{
	 document.formIncapacidad.save.disableOnSubmit = true;
	 var k = "<%=checkedEmp%>";
	 if (window.opener.parent.doRedirect('7','0',k) == true)
	 {
	 	document.formIncapacidad.grupo.value = "<%=grupo%>";
		document.formIncapacidad.baction.value = "Guardar";
		document.formIncapacidad.submit();
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
}
function addMotivo(index)
{
    abrir_ventana1("../common/search_motivo_falta.jsp?fp=incapacidades_empleado&index="+index);
	sumHoras(index);
}

function validaHoras(j)
{
	var fecha = eval('document.formIncapacidad.fecha'+j).value;

	var entrada  = eval('document.formIncapacidad.fecha_entrada'+j).value;
	var salida   = eval('document.formIncapacidad.fecha_salida'+j).value;

	var	fechaIni = salida+" "+eval('document.formIncapacidad.taHsal'+j).value;
	var	fechaFin = entrada+" "+eval('document.formIncapacidad.taHent'+j).value;

	var   horas='', minutos='';
	var arr_cursor = new Array();
	var sqlReturnData = '', sqlFrom = '', sqlWhere = '';
   	eval('document.formIncapacidad.hora_entrada'+j).value = fechaFin;
	eval('document.formIncapacidad.hora_salida'+j).value = fechaIni;

	var ini = new Date(fechaIni);
	var fin = new Date(fechaFin);
	var hour = 0;
	var minu = 0;

	var hourI = 0, hourF = 0;
	var minuI = 0, minuF = 0;

	sec = fin.getSeconds() - ini.getSeconds();
	minu = fin.getMinutes();
	minuI = ini.getMinutes();
	minuF = fin.getMinutes();
	if (sec < 0){
		minu = minu - 1;
		sec = sec + 60;
	}
	minu = minu - ini.getMinutes();
	hour = fin.getHours();
	if (minu < 0){
		hour = hour - 1;
		minu = minu + 60;
	}
	hour = hour - ini.getHours();
	hourI = ini.getHours();
	hourF = fin.getHours();

	if (hourF<hourI) hour = (23 - hourI + hourF)

	eval('document.formIncapacidad.tiempoHoras'+j).value = hour;
	eval('document.formIncapacidad.tiempoMinutos'+j).value = minu;

}

function sumHoras(k){
	var i = 0;
	var fechaIni = '', fechaFin = '';
	var p_emp_id = '', p_num_empleado = '';
	var fecha = eval('document.formIncapacidad.fecha'+k).value;
	p_emp_id = document.formIncapacidad.empId.value;

	var fecha_dev = '';
	if(fecha_dev!='' && fecha_dev != ' ') fecha_dev = '\''+fecha_dev+'\'';
	else fecha_dev = 'null';

	var sqlReturnData = '', sqlFrom = '', sqlWhere = '';
	sqlReturnData = 'to_char(e.fecha_ingreso,\'dd/mm/yyyy\'), decode(nvl(c.dias_vacacion, 30), 45, \'ENF\', \'ADM\') tipo_personal, decode(nvl(c.dias_vacacion, 30), 45, 2.5, 1.5) dias_x_mestrab, h.cant_horas, horario, h.horas_com, h.minutos_com';
	sqlFrom = 'tbl_pla_empleado e, tbl_pla_cargo c, tbl_pla_horario_trab h';
	sqlWhere = 'e.cargo = c.codigo and e.compania = c.compania and e.horario = h.codigo and e.compania = h.compania and e.compania = <%=(String) session.getAttribute("_companyId")%> and e.emp_id = '+p_emp_id;
	var data = getDBData('<%=request.getContextPath()%>', sqlReturnData, sqlFrom, sqlWhere, '');
	var fecha_ingreso = '', tipo_per = '', dias_x_mestrab = '', horas_dia = '', horario = '', horas_com = '', minutos_com = '', horas = '' , minutos = '', entra = '' , sale = '';
	var arr_cursor = new Array();
	arr_cursor = splitCols(data);
	fecha_ingreso 	= arr_cursor[0];
	tipo_per 	= arr_cursor[1];
	dias_x_mestrab	= arr_cursor[2];
	horas_dia 	= arr_cursor[3];
	horario 	= arr_cursor[4];
	horas_com 	= arr_cursor[5];
	minutos_com	= arr_cursor[6];

	document.formIncapacidad.fecha_ingreso.value  = fecha_ingreso;
	document.formIncapacidad.tipo_per.value       = tipo_per;
	document.formIncapacidad.dias_x_mestrab.value = dias_x_mestrab;
	document.formIncapacidad.horas_dia.value      = horas_dia;
	document.formIncapacidad.horario.value 	      = horario;
	data = '';
	data = getDBData('<%=request.getContextPath()%>', 'getIncapacidadData(\''+p_num_empleado+'\','+p_emp_id+',\''+fecha+'\','+fecha_dev+',<%=(String) session.getAttribute("_companyId")%>,\''+horario+'\')', 'dual', '', '');
	arr_cursor = splitCols(data);
	v_turno_asignado 	= arr_cursor[0];
	v_programa 		= arr_cursor[1];
	v_ta_hent		= arr_cursor[2];
	v_ta_hsal 		= arr_cursor[3];
	horas			= arr_cursor[4];
	minutos			= arr_cursor[5];
	sale 			= arr_cursor[6];
	entra			= arr_cursor[7];

	eval('document.formIncapacidad.taHsal'+k).value = v_ta_hent;
	eval('document.formIncapacidad.taHent'+k).value = v_ta_hsal;
	eval('document.formIncapacidad.taHsaL'+k).value = v_ta_hent;
	eval('document.formIncapacidad.taHenT'+k).value = v_ta_hsal;
	eval('document.formIncapacidad.programa'+k).value = v_programa;
	eval('document.formIncapacidad.turnoAsig'+k).value = v_turno_asignado;

	if (sale != "") sale = fecha;
	if (entra !="") entra = fecha;

	fechaIni = sale+" "+eval('document.formIncapacidad.taHsal'+k).value;
	fechaFin = entra+" "+eval('document.formIncapacidad.taHent'+k).value;

	eval('document.formIncapacidad.hora_entrada'+k).value = fechaFin;
	eval('document.formIncapacidad.hora_salida'+k).value = fechaIni;

	eval('document.formIncapacidad.fecha_entrada'+k).value = entra;
	eval('document.formIncapacidad.fecha_salida'+k).value = sale;

	var ini = new Date(fechaIni);
	var fin = new Date(fechaFin);

	var hour = 0;
	var minu = 0;

	sec = fin.getSeconds() - ini.getSeconds();
	minu = fin.getMinutes();
	if (sec < 0){
		minu = minu - 1;
		sec = sec + 60;
	}
	minu = minu - ini.getMinutes();
	hour = fin.getHours();

	if (minu < 0){
		hour = hour - 1;
		minu = minu + 60;
	}
	hour = hour - ini.getHours();

	eval('document.formIncapacidad.tiempoHoras'+k).value = horas;
	eval('document.formIncapacidad.tiempoMinutos'+k).value = minu;

	var motivo = eval('document.formIncapacidad.mfalta'+k).value;
	var motivoDsp = eval('document.formIncapacidad.mfaltaDesc'+k).value;
	var estado = eval('document.formIncapacidad.mfalta'+k).value;
	var cambio = eval('document.formIncapacidad.mfaltaDesc'+k).value;

	if(motivo!=''&&motivo!='39'){

		data = '';
		data = getDBData('<%=request.getContextPath()%>', 'getDisponibilidadInc('+p_emp_id+',\''+p_num_empleado+'\',<%=(String) session.getAttribute("_companyId")%>,'+dias_x_mestrab+','+horas_dia+',\''+horario+'\',\''+tipo_per+'\',\''+fecha_ingreso+'\',\''+fecha+'\',\''+fecha+'\')', 'dual', '', '');
		arr_cursor = splitCols(data);
		v_ta_hent		= arr_cursor[0];
		v_ta_hsal 		= arr_cursor[1];
		hour			= arr_cursor[2];
		minu			= arr_cursor[3];
		motivo			= arr_cursor[4];
		motivoDsp		= arr_cursor[5];
		estado			= arr_cursor[6];
		cambio			= arr_cursor[7];

		eval('document.formIncapacidad.motivo'+k).value = motivoDsp;
	}

}





</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
     <%fb = new FormBean("formIncapacidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("incLastLineNo",""+incLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("keySize",""+incHash.size())%>
			<%=fb.hidden("fecha_ingreso", "")%>
      <%=fb.hidden("tipo_per", "")%>
      <%=fb.hidden("dias_x_mestrab", "")%>
      <%=fb.hidden("horas_dia", "")%>
      <%=fb.hidden("horario", "")%>

      <%=fb.hidden("provincia", prov)%>
      <%=fb.hidden("sigla", sigla)%>
      <%=fb.hidden("tomo", tomo)%>
      <%=fb.hidden("asiento", asiento)%>
      <%=fb.hidden("numEmpleado", empNum)%>
      <%=fb.hidden("empId", empId)%>
      <%=fb.hidden("area", area)%>
      <%=fb.hidden("check", "")%>

				<tr class="TextRow02">
					<td colspan="8">&nbsp;</td>
				</tr>

				<tr class="TextPanel">
					<td colspan="8">registro del empleado</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="4">C&eacute;dula:
					<%=prov%>-<%=sigla%>-<%=tomo%>-<%=asiento%>
					</td>
					<td colspan="4">Nombre:
					[<%=empId%>]&nbsp;<%=nombreEmp%>
					</td>
				</tr>
			    <tr class="TextHeader" align="center">
					<td width="17%">Fecha</td>
					<td width="17%">Desde</td>
					<td width="17%">Hasta</td>
					<td width="5%">Hras.</td>
					<td width="5%">Min.</td>
					<td width="28%">Motivo de Incapacidad</td>
					<td width="8%">No.</td>
					<td width="3%" align="center">
					<%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					</td>
				</tr>
				<%
				    String js = "";
					String fecha = "";
					String taHent = "";
					String taHsal = "";
				    al = CmnMgr.reverseRecords(incHash);
				    for (int i = 0; i < incHash.size(); i++)
				    {
					  key = al.get(i).toString();
					  CommonDataObject inc = (CommonDataObject) incHash.get(key);
					  fecha = "fecha"+i;
					  taHent = "taHent"+i;
					  taHsal = "taHsal"+i;
					///	String  functionName = "sumHoras("+i+")" , functionHour = "sumHoras("+i+")";
						String  functionName = "sumHoras("+i+")" , functionHour = "validaHoras("+i+")";


			    %>
				<tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	<%=fb.hidden("turnoAsig"+i, "")%>
				 <%=fb.hidden("programa"+i,"")%> <%=fb.hidden("hora_entrada"+i,inc.getColValue("hora_entrada"))%>
				 <%=fb.hidden("hora_salida"+i,inc.getColValue("hora_salida"))%>
				 <%=fb.hidden("fecha_entrada"+i,"")%>  <%=fb.hidden("fecha_salida"+i,"")%> <%=fb.hidden("estadoInc"+i,"")%>
				 <%=fb.hidden("taHsaL"+i,"")%>  <%=fb.hidden("taHenT"+i,"")%>

<td>	<jsp:include page="../common/calendar.jsp" flush="true">
      	<jsp:param name="noOfDateTBox" value="1" />
      	<jsp:param name="clearOption" value="true" />
      	<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>
      	<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("fecha")==null)?"":inc.getColValue("fecha")%>" />
      	<jsp:param name="fieldClass" value="Text10" />
      	<jsp:param name="buttonClass" value="Text10" />
      	<jsp:param name="clearOption" value="true" />
      	<jsp:param name="jsEvent" value="<%=functionName%>" />
	<jsp:param name="onChange" value="<%=functionName%>"/>
	</jsp:include>
</td>

<td> 	<jsp:include page="../common/calendar.jsp" flush="true">
	<jsp:param name="noOfDateTBox" value="1" />
      	<jsp:param name="clearOption" value="true" />
	<jsp:param name="nameOfTBox1" value="<%=taHsal%>"/>
	<jsp:param name="format" value="hh12:mi am" />
	<jsp:param name="jsEvent" value="<%=functionHour%>" />
	<jsp:param name="onChange" value="<%=functionHour%>"/>
        <jsp:param name="fieldClass" value="text10"/>
        <jsp:param name="buttonClass" value="text10"/>
	<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("ta_hsal")==null)?"":inc.getColValue("ta_hsal")%>" />
	</jsp:include>
</td>

<td>
	<jsp:include page="../common/calendar.jsp" flush="true">
	<jsp:param name="noOfDateTBox" value="1" />
   	<jsp:param name="clearOption" value="true" />
	<jsp:param name="nameOfTBox1" value="<%=taHent%>"/>
	<jsp:param name="format" value="hh12:mi am" />
	<jsp:param name="jsEvent" value="<%=functionHour%>" />
	<jsp:param name="onChange" value="<%=functionHour%>"/>
	<jsp:param name="fieldClass" value="text10"/>
	<jsp:param name="buttonClass" value="text10"/>
	<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("ta_hent")==null)?"":inc.getColValue("ta_hent")%>" />				</jsp:include>			</td>
	<td><%=fb.intBox("tiempoHoras"+i,inc.getColValue("tiempo_horas"),false,false,false,5,2 ,"Text10",null,null)%></td>
	<td><%=fb.intBox("tiempoMinutos"+i,inc.getColValue("tiempo_minutos"),false,false,false,5,2,"Text10",null,null)%></td>
	<td><%=fb.intBox("mfalta"+i,inc.getColValue("mfalta"),false,false,true,5,3,"Text10",null,null)%>
		<%=fb.textBox("mfaltaDesc"+i,inc.getColValue("mfaltaDesc"),false,false,true,28,50,"Text10",null,null)%>
		<%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
	<td><%=fb.intBox("codigo"+i,inc.getColValue("codigo"),false,false,true,10,1,"Text10",null,null)%></td>
	<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>

</tr>
	<tr class="TextRow01" >
	    <td colspan="4">
		    <table>
			   <tr>
			    <td><font size="2">Observaci&oacute;n</font></td>
			   	<td><%=fb.textarea("motivo"+i,inc.getColValue("motivo"),false,false,false,33,4,"Text11",null,null)%></td>
			   </tr>
		    </table>
	    </td>
	    <td colspan="5">
		    <table width="97%">
			   <tr>
			    <td width="32%"><font size="2">No.Incapacidad </font></td>
	  		   	<td width="68%" align="left"><%=fb.intBox("no_referencia"+i,inc.getColValue("no_referencia"),true,false,false,7,12,"Text10",null,null)%>&nbsp;
	  		   			Acci&oacute;n <%=fb.select("estado"+i,"ND=No Descontar,DS=Descontar",inc.getColValue("estado"),false,false,0,"Text10",null,null)%>									 </td>
			   </tr>
			   <tr>
			    <td><font size="2">Tipo de Lugar</font></td>
			   	<td><%=fb.select("lugar"+i,"1=Clínica Privada,2=Caja de Seguro Social,3=Clínica Externa,4=Centro Médico,5=Otro",inc.getColValue("lugar"),false,false,0,"Text10",null,null)%></td>
			   </tr>
			   <tr>
			    <td><font size="2">Nombre Lugar</font></td>
			    <td><%=fb.textBox("lugarNombre"+i,inc.getColValue("lugar_nombre"),false,false,false,40,60,"Text10",null,null)%></td>
			   </tr>
		    </table>
	    </td>
	</tr>
	<% //Si error--, quita el error. Si error++, agrega el error.
	   // js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
		}
	   //fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");
	%>
	<tr class="TextRow02">
		<td align="right" colspan="9"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>					</td>
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
	incLastLineNo = Integer.parseInt(request.getParameter("incLastLineNo"));
	String ItemRemoved = "";
	provincia = request.getParameter("provincia");
	sigla = request.getParameter("sigla");
	tomo = request.getParameter("tomo");
	asiento = request.getParameter("asiento");
	numEmpleado = request.getParameter("numEmpleado");
	seccion = request.getParameter("seccion");
	area = request.getParameter("area");
	grupo = request.getParameter("grupo");
	emp_id = request.getParameter("empId");

	//incHash.clear();
  	//list.clear();
	//incLastLineNo = 1;
	for (int i=0; i<keySize; i++)
	{
		key = request.getParameter("key"+i);
		if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{
			ItemRemoved = key;
		} else {
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_pla_incapacidad");
			cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+grupo+" and emp_id="+request.getParameter("emp_id"));
			cdo.addColValue("ue_codigo",grupo);
			cdo.addColValue("provincia",provincia);
			cdo.addColValue("sigla",sigla);
			cdo.addColValue("tomo",tomo);
			cdo.addColValue("asiento",asiento);
			cdo.addColValue("emp_id",request.getParameter("empId"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("num_empleado",numEmpleado);
			cdo.addColValue("fecha",request.getParameter("fecha"+i));
			cdo.addColValue("hora_salida",request.getParameter("hora_salida"+i));
			cdo.addColValue("hora_entrada",request.getParameter("hora_entrada"+i));
			cdo.addColValue("ta_hsal",request.getParameter("taHsal"+i));
			cdo.addColValue("ta_hent",request.getParameter("taHent"+i));
			cdo.addColValue("tiempo_horas",request.getParameter("tiempoHoras"+i));
			cdo.addColValue("tiempo_minutos",request.getParameter("tiempoMinutos"+i));
			cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
			cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.setAutoIncWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and fecha = to_date('"+request.getParameter("fecha"+i)+"','dd/mm/yyyy') and emp_id = "+request.getParameter("empId"));
			cdo.setAutoIncCol("codigo");

			if(request.getParameter("estado"+i)!=null && !request.getParameter("estado"+i).equals("")) cdo.addColValue("estado",request.getParameter("estado"+i));
			else  cdo.addColValue("estado",request.getParameter("estadoInc"+i));
			cdo.addColValue("lugar_nombre",request.getParameter("lugarNombre"+i));
			cdo.addColValue("lugar",request.getParameter("lugar"+i));
			cdo.addColValue("motivo",request.getParameter("motivo"+i));
			cdo.addColValue("no_referencia",request.getParameter("no_referencia"+i));
			cdo.addColValue("programa",request.getParameter("programa"+i));
			cdo.addColValue("turno_asignado",request.getParameter("turnoAsig"+i));
			cdo.addColValue("forma_des","1");
			cdo.addColValue("aprobado","N");
			cdo.addColValue("fecha_modificacion", "sysdate");
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion", "sysdate");
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

			if (incLastLineNo < 10) key = "00" + incLastLineNo;
			else if (incLastLineNo < 100) key = "0" + incLastLineNo;
			else key = "" + incLastLineNo;

			try	{
				incHash.put(key,cdo);
				list.add(cdo);
				} catch(Exception e){ System.err.println(e.getMessage()); }
			}  // end else
	}  ///  end for
	if (!ItemRemoved.equals("")){
		response.sendRedirect("../rhplanilla/empl_incapacidades_detail.jsp?change=1&incLastLineNo="+incLastLineNo+"&seccion="+seccion);
		return;
	}
	if (request.getParameter("baction") != null && request.getParameter("baction").equals("+")){
		curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.addColValue("provincia","");
		cdo2.addColValue("sigla","");
		cdo2.addColValue("tomo","");
		cdo2.addColValue("asiento","");
		cdo2.addColValue("compania","");
		cdo2.addColValue("num_empleado","");
		cdo2.addColValue("emp_id","");
		cdo2.addColValue("fecha",curDate.substring(0,10));
		cdo2.addColValue("hora_salida","");
		cdo2.addColValue("hora_entrada","");
		cdo2.addColValue("tiempo_horas","0");
		cdo2.addColValue("tiempo_minutos","0");
		cdo2.addColValue("mfalta","");
		cdo2.addColValue("mfaltaDesc","");
		cdo2.addColValue("estado","");
		cdo2.addColValue("lugar_nombre","");
		cdo2.addColValue("lugar","");
		cdo2.addColValue("motivo","");
		cdo2.addColValue("no_referencia","");

		incLastLineNo++;
		cdo2.addColValue("codigo",""+incLastLineNo);
		if (incLastLineNo < 10) key = "00" + incLastLineNo;
		else if (incLastLineNo < 100) key = "0" + incLastLineNo;
		else key = "" + incLastLineNo;

		incHash.put(key,cdo2);

		response.sendRedirect("../rhplanilla/empl_incapacidades_detail.jsp?change=1&incLastLineNo="+incLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo+"&prov="+provincia+"&empId="+emp_id+"&empNum="+numEmpleado+"&tomo="+tomo+"&asiento="+asiento+"&checkedEmp="+checkedEmp+"&sigla="+sigla);
		return;
	}
	SQLMgr.insertList(list);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_incapacidad_list.jsp?grupo=<%=grupo%>&empId=<%=emp_id%>';

	window.close();
<%
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