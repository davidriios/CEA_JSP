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
<jsp:useBean id="ausHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");
String seccion = "";
String key = "";
String sql = "";
String entra = "";
String sale = "";

String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

String area = (request.getParameter("mes")==null?"":request.getParameter("mes"));
String mes = (request.getParameter("mes")==null?"":request.getParameter("mes"));
String anio = (request.getParameter("anio")==null?"":request.getParameter("anio"));
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
String grupo = (request.getParameter("grupo")==null?"":request.getParameter("grupo"));
String empNum = (request.getParameter("empNum")==null?"":request.getParameter("empNum"));
String prov = (request.getParameter("prov")==null?"":request.getParameter("prov"));
String sigla = (request.getParameter("sigla")==null?"":request.getParameter("sigla"));
String tomo = (request.getParameter("tomo")==null?"":request.getParameter("tomo"));
String asiento = (request.getParameter("asiento")==null?"":request.getParameter("asiento"));
String nombreEmp = (request.getParameter("nombreEmp")==null?"":request.getParameter("nombreEmp"));
String checkedEmp = (request.getParameter("checkedEmp")==null?"":request.getParameter("checkedEmp"));

int ausLastLineNo = 0;
int count = 0;

if (anio.trim().equals("") || mes.trim().equals("")){
   anio = curDate.substring(6,10);
   mes  = curDate.substring(3,5);
}


System.out.println("::::::::::::::::::::::::::::::::::::::::: anio = "+anio+" ::::::::::::::::::::::::::::::::: mes = "+mes);


if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("ausLastLineNo") != null && !request.getParameter("ausLastLineNo").equals("")) ausLastLineNo = Integer.parseInt(request.getParameter("ausLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET")){
	if (change == null){
		sql = "select 'S' saved, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.ue_codigo, a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, to_char(a.ta_hent, 'dd/mm/yyyy HH12:MI AM') ta_hent, to_char(a.ta_hsal, 'dd/mm/yyyy HH12:MI AM') ta_hsal, a.tiempo_horas, a.tiempo_minutos, a.causa, a.aprobacion, a.mfalta, a.aprobado_por, to_char(a.fecha_aprobacion, 'dd/mm/yyyy') fecha_aprobacion, a.programa, a.turno_asignado, a.fecha_creacion, a.usuario_creacion, a.fecha_modificacion, a.usuario_modificacion, a.estado, to_char(a.fecha_anulacion, 'dd/mm/yyyy') fecha_anulacion, a.usuario_anulacion, a.anio_dev, a.periodo_dev, a.usuario_dev, to_char(a.fecha_dev, 'dd/mm/yyyy') fecha_dev, a.dev_aprobada, a.dev_aprobada_por, to_char(a.dev_aprobada_fecha, 'dd/mm/yyyy') dev_aprobada_fecha, a.emp_id as empId, b.descripcion mfaltaDesc from tbl_pla_inasistencia_emp a, tbl_pla_motivo_falta b where a.estado <> 'EL' and ((to_char(a.fecha,'yyyy') = '"+anio+"' and to_char(a.fecha,'mm') = '"+mes+"' and (a.aprobacion is null or a.aprobacion = 'N')) or (to_char(a.fecha_dev,'yyyy') = '"+anio+"' and to_char(a.fecha_dev,'mm') = '"+mes+"' and a.aprobacion = 'S')) and a.mfalta = b.codigo and a.emp_id = " + empId;
	   al = SQLMgr.getDataList(sql);

	   ausHash.clear();
		 for(int i=0;i<al.size();i++){
			 ausLastLineNo ++;
			 if (ausLastLineNo < 10) key = "00" + ausLastLineNo;
			 else if (ausLastLineNo < 100) key = "0" + ausLastLineNo;
			 else key = "" + ausLastLineNo;

			 CommonDataObject aus = (CommonDataObject) al.get(i);
			 ausHash.put(key,aus);
		 }
		 ausLastLineNo ++;
		 if (ausLastLineNo < 10) key = "00" + ausLastLineNo;
		 else if (ausLastLineNo < 100) key = "0" + ausLastLineNo;
		 else key = "" + ausLastLineNo;
		 CommonDataObject aus = new CommonDataObject();
		 aus.addColValue("fecha","");
		 aus.addColValue("ta_hent","");
		 aus.addColValue("ta_hsal","");
		 aus.addColValue("tiempo_horas","");
		 aus.addColValue("tiempo_minutos","");
		 ausHash.put(key,aus);
   }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Ausencias Del Empleado - '+document.title;

function doSubmit(){
	var fechaTemp = "";
	document.formAusencia.save.disableOnSubmit = true;
	if (window.opener.parent.doRedirect('8','0') == true){
		for (j=0; j<<%=ausHash.size()%>; j++){
			if (j==0){
				fechaTemp = eval('document.formAusencia.fecha'+j).value;
			}
			if (j>0){
				if (fechaTemp == eval('document.formAusencia.fecha'+j).value){
					alert('No pueden haber más de una ausencia en el mismo día !!');
					return;
				}
			}
		}
		document.formAusencia.baction.value = "Guardar";
		document.formAusencia.submit();
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
	parent.doAction();
//	sumHoras(0,0,0);
}

function addMotivo(index)
{
    abrir_ventana1("../common/search_motivo_falta.jsp?fp=ausencias&index="+index);
}


function validaHoras(j)
{
var fecha = eval('document.formAusencia.fecha'+j).value;
var	fechaIni = fecha+" "+eval('document.formAusencia.taHsal'+j).value;
var	fechaFin = fecha+" "+eval('document.formAusencia.taHent'+j).value;
   		eval('document.formAusencia.hora_entrada'+j).value = fechaFin;
		eval('document.formAusencia.hora_salida'+j).value = fechaIni;
 		eval('document.formAusencia.fecha'+j).value = fecha;
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

		eval('document.formAusencia.tiempoHoras'+j).value = hour;
		eval('document.formAusencia.tiempoMinutos'+j).value = minu;
	}



function sumHoras(j){
	var i = 0;
	var fechaIni = '', fechaFin = '';
	var p_emp_id = '<%=empId%>', p_num_empleado = '<%=empNum%>';
	var fecha = eval('document.formAusencia.fecha'+j).value;

	var fecha_dev = eval('document.formAusencia.devolucion'+j).value;
	eval('document.formAusencia.fecha'+j).value = fecha;
	if(fecha_dev!='' && fecha_dev != ' ') fecha_dev = '\''+fecha_dev+'\'';
	else fecha_dev = 'null';

	var sqlReturnData = '', sqlFrom = '', sqlWhere = '';
	sqlReturnData = 'e.fecha_ingreso, decode(nvl(c.dias_vacacion, 30), 45, \'ENF\', \'ADM\') tipo_personal, decode(nvl(c.dias_vacacion, 30), 45, 2.5, 1.5) dias_x_mestrab, h.cant_horas, horario';
	sqlFrom = 'tbl_pla_empleado e, tbl_pla_cargo c, tbl_pla_horario_trab h';
	sqlWhere = 'e.cargo = c.codigo and e.compania = c.compania and e.horario = h.codigo and e.compania = h.compania and e.compania = <%=(String) session.getAttribute("_companyId")%> and e.emp_id = '+p_emp_id;
	var data = getDBData('<%=request.getContextPath()%>', sqlReturnData, sqlFrom, sqlWhere, '');
	var fecha_ingreso = '', tipo_per = '', dias_x_mestrab = '', horas_dia = '', horario = '';
	var arr_cursor = new Array();
	arr_cursor = splitCols(data);
	fecha_ingreso 	= arr_cursor[0];
	tipo_per 		= arr_cursor[1];
	dias_x_mestrab	= arr_cursor[2];
	horas_dia 		= arr_cursor[3];
	horario 		= arr_cursor[4];

	document.formAusencia.fecha_ingreso.value 	= fecha_ingreso;
	document.formAusencia.tipo_per.value 		= tipo_per;
	document.formAusencia.dias_x_mestrab.value 	= dias_x_mestrab;
	document.formAusencia.horas_dia.value 		= horas_dia;
	document.formAusencia.horario.value 		= horario;
	data = '';
	data = getDBData('<%=request.getContextPath()%>', 'getAusenciaData(\''+p_num_empleado+'\','+p_emp_id+',\''+fecha+'\','+fecha_dev+',<%=(String) session.getAttribute("_companyId")%>,\''+horario+'\')', 'dual', '', '');
	arr_cursor = splitCols(data);
	v_turno_asignado 	= arr_cursor[0];
	v_programa 			= arr_cursor[1];
	v_ta_hent			= arr_cursor[2];
	v_ta_hsal 			= arr_cursor[3];

	eval('document.formAusencia.taHent'+j).value = v_ta_hent;
	eval('document.formAusencia.taHsal'+j).value = v_ta_hsal;
	eval('document.formAusencia.programa'+j).value = v_programa;
	eval('document.formAusencia.turnoAsig'+j).value = v_turno_asignado;
	fechaIni = eval('document.formAusencia.taHent'+j).value;
	fechaFin = eval('document.formAusencia.taHsal'+j).value;

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
	hour = hour - ini.getHours() ;

	if (fechaIni=="")
	{ hour=0;
	  minu = 0;
	}

	eval('document.formAusencia.tiempoHoras'+j).value = hour;
	eval('document.formAusencia.tiempoMinutos'+j).value = minu;
	eval('document.formAusencia.fecha'+j).value = fecha;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
      <%fb = new FormBean("formAusencia",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("ausLastLineNo",""+ausLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("keySize",""+ausHash.size())%>
      <%=fb.hidden("fecha_ingreso", "")%>
      <%=fb.hidden("tipo_per", "")%>
      <%=fb.hidden("dias_x_mestrab", "")%>
      <%=fb.hidden("horas_dia", "")%>
      <%=fb.hidden("horario", "")%>

	  <%=fb.hidden("prov", prov)%>
      <%=fb.hidden("sigla", sigla)%>
      <%=fb.hidden("tomo", tomo)%>
      <%=fb.hidden("asiento", asiento)%>
      <%=fb.hidden("empNum", empNum)%>
      <%=fb.hidden("empId", empId)%>
      <%=fb.hidden("nombreEmp", nombreEmp)%>
      <%=fb.hidden("check", "")%>
      <%=fb.hidden("mes", mes)%>
      <%=fb.hidden("anio", anio)%>

	<tr class="TextRow02">
		<td colspan="2"> REGISTRO DE AUSENCIAS </td>
		<td colspan="6" align="right">
		   <%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
		</td>
	</tr>

  <tr class="TextHeader" align="center">
    <td width="13%">Fecha</td>
		<td width="20%">Hora Desde</td>
		<td width="20%">Hora Hasta</td>
		<td width="5%">Hras.</td>
		<td width="5%">Min.</td>
		<td width="34%">Motivo de Ausencia</td>
		<td width="3%">&nbsp;</td>
	</tr>
		<%
		    String js = "";
				String fecha = "";
				String taHent = "";
				String taHsal = "";
			    al = CmnMgr.reverseRecords(ausHash);
			    for (int i = 0; i < ausHash.size(); i++)
			    {
				  key = al.get(i).toString();
				  CommonDataObject aus = (CommonDataObject) ausHash.get(key);
				  fecha = "fecha"+i;
				  taHent = "taHent"+i;
				  taHsal = "taHsal"+i;
				String jsFunction = "sumHoras("+i+")", functionHour = "validaHoras("+i+")";
	  %>

  <tr class="TextRow01"><%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>	<%=fb.hidden("turnoAsig"+i, "")%>
      <%=fb.hidden("programa"+i, "")%>  <%=fb.hidden("hora_entrada"+i,"")%>  <%=fb.hidden("hora_salida"+i,"")%>

    	<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>
				<jsp:param name="fieldClass" value="text10"/>
        			<jsp:param name="buttonClass" value="text10"/>
				<jsp:param name="valueOfTBox1" value="<%=(aus.getColValue("fecha")==null)?"":aus.getColValue("fecha")%>" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="jsEvent" value="<%=jsFunction%>"/>
				<jsp:param name="onChange" value="<%=jsFunction%>" />
				</jsp:include>
			</td>

			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
    	  			<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%=taHent%>"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="jsEvent" value="<%=functionHour%>"/>
				<jsp:param name="onChange" value="<%=functionHour%>" />
        			<jsp:param name="fieldClass" value="text10"/>
        			<jsp:param name="buttonClass" value="text10"/>
				<jsp:param name="valueOfTBox1" value="<%=(aus.getColValue("ta_hent")==null)?"":aus.getColValue("ta_hent")%>" />
				</jsp:include>
			</td>

    	<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
      				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%=taHsal%>"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="jsEvent" value="<%=functionHour%>"/>
				<jsp:param name="onChange" value="<%=functionHour%>" />
        			<jsp:param name="fieldClass" value="text10"/>
        			<jsp:param name="buttonClass" value="text10"/>
				<jsp:param name="valueOfTBox1" value="<%=(aus.getColValue("ta_hsal")==null)?"":aus.getColValue("ta_hsal")%>" />
				</jsp:include>
	</td>
    	<td><%=fb.intBox("tiempoHoras"+i,aus.getColValue("tiempo_horas"),false,false,false,3,2 ,"Text10",null,null)%></td>
	<td><%=fb.intBox("tiempoMinutos"+i,aus.getColValue("tiempo_minutos"),false,false,false,3,2,"Text10",null,null)%></td>
	<td><%=fb.intBox("mfalta"+i,aus.getColValue("mfalta"),false,false,true,3,3,"Text10",null,null)%><%=fb.textBox("mfaltaDesc"+i,aus.getColValue("mfaltaDesc"),false,false,true,40,50,"Text10",null,null)%><%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%></td>
	<td align="right">
      		<%if(aus.getColValue("saved")!=null && aus.getColValue("saved").equals("S")){} else {%>
		<%=fb.submit("rem"+i,"X",true,false,"text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>
      		<%}%>
      	</td>
	</tr>

  	<tr class="TextRow01" >
				    &nbsp;&nbsp;&nbsp;
	</tr>

  	<tr class="TextRow01" >
	 	<td colspan="5"><font size="2">Observaci&oacute;n</font>&nbsp;&nbsp;<%=fb.textarea("causa"+i,aus.getColValue("causa"),false,false,false,60,3,"Text10",null,null)%></td>
	 	<td colspan="2">
	 	<table width="100%">

  	<tr>
		<td width="35%"><font size="2">Devoluci&oacute;n</font></td>
		<td width="65%"><%=fb.intBox("devolucion"+i,aus.getColValue("devolucion"),false,false,true,10,1,"Text10",null,null)%></td>
	</tr>

  	<tr>
		<td><font size="2">Acci&oacute;n</font></td>
		<td><%=fb.select("estado"+i,"DS=Descontar,ND=No Descontar",aus.getColValue("estado"),false,false,0,"Text10","","")%>


		</td>
	</tr>
	</table>
	</td>
	</tr>
			<%
				     //Si error--, quita el error. Si error++, agrega el error.
				    // js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
					}
					//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");
			%>
	<tr class="TextRow02">
		<td align="right" colspan="7"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
else{
	int keySize=Integer.parseInt(request.getParameter("keySize"));
	ausLastLineNo = Integer.parseInt(request.getParameter("ausLastLineNo"));
	String ItemRemoved = "";
	prov = request.getParameter("prov");
		sigla = request.getParameter("sigla");
		tomo = request.getParameter("tomo");
		asiento = request.getParameter("asiento");
	empNum = request.getParameter("empNum");
	seccion = request.getParameter("seccion");
	area = request.getParameter("area");
	grupo = request.getParameter("grupo");
	empId = request.getParameter("empId");
	nombreEmp = request.getParameter("nombreEmp");
	anio = request.getParameter("anio");
	mes = request.getParameter("mes");

	if (!request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		for (int i=0; i<keySize; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_inasistencia_emp");
	    	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	   		cdo.addColValue("num_empleado",empNum);
			cdo.addColValue("fecha",request.getParameter("fecha"+i));
			cdo.addColValue("ta_hent",request.getParameter("taHent"+i));
			cdo.addColValue("ta_hsal",request.getParameter("taHsal"+i));
			cdo.addColValue("tiempo_horas",request.getParameter("tiempoHoras"+i));
			cdo.addColValue("tiempo_minutos",request.getParameter("tiempoMinutos"+i));
			cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
			cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("causa",request.getParameter("causa"+i));
			cdo.addColValue("fecha_modificacion", "sysdate");
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

	    		key = request.getParameter("key"+i);
	    		if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
	    		{
				ItemRemoved = key;
			} else {
				try{
				     ausHash.put(key,cdo);
			  	   } catch(Exception e){ System.err.println(e.getMessage());}
			        }

		}
	if (!ItemRemoved.equals("")){
		response.sendRedirect("../rhplanilla/empl_ausencias_detail.jsp?change=1&ausLastLineNo="+ausLastLineNo+"&seccion="+seccion);
		return;
	}




		if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  	{

			CommonDataObject cdo2 = new CommonDataObject();
			cdo2.addColValue("provincia","");
			cdo2.addColValue("sigla","");
			cdo2.addColValue("tomo","");
			cdo2.addColValue("asiento","");
			cdo2.addColValue("compania","");
			cdo2.addColValue("num_empleado","");
			cdo2.addColValue("ue_codigo","");
			cdo2.addColValue("empId","");
			cdo2.addColValue("fecha","");
			cdo2.addColValue("ta_hsal","");
			cdo2.addColValue("ta_hent","");
			cdo2.addColValue("tiempo_horas","0");
			cdo2.addColValue("tiempo_minutos","0");
			cdo2.addColValue("mfalta","");
			cdo2.addColValue("mfaltaDesc","");
			cdo2.addColValue("estado","");
			cdo2.addColValue("causa","");

			ausLastLineNo++;
			if (ausLastLineNo < 10) key = "00" + ausLastLineNo;
			else if (ausLastLineNo < 100) key = "0" + ausLastLineNo;
			else key = "" + ausLastLineNo;

			ausHash.put(key,cdo2);

			response.sendRedirect("../rhplanilla/empl_ausencias_detail.jsp?change=1&ausLastLineNo="+ausLastLineNo+"&type=1&seccion="+seccion+"&area="+area+"&grupo="+grupo+"&prov="+prov+"&empId="+empId+"&empNum="+empNum+"&tomo="+tomo+"&asiento="+asiento+"&checkedEmp="+checkedEmp+"&sigla="+sigla+"&nombreEmp="+nombreEmp+"&anio="+anio+"&mes="+mes);
			return;
		}  // end if  (+)
	}	// end if !Guardar
	else {
		for (int i=0; i<keySize; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_pla_inasistencia_emp");
			cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+grupo+" and emp_id="+request.getParameter("empId"));
			cdo.addColValue("ue_codigo",grupo);
			cdo.addColValue("provincia",request.getParameter("prov"));
			cdo.addColValue("sigla",request.getParameter("sigla"));
			cdo.addColValue("tomo",request.getParameter("tomo"));
			cdo.addColValue("asiento",request.getParameter("asiento"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("num_empleado",request.getParameter("empNum"));
			cdo.addColValue("emp_id",request.getParameter("empId"));
			cdo.addColValue("fecha",request.getParameter("fecha"+i));
			cdo.addColValue("ta_hsal",request.getParameter("taHsal"+i));
			cdo.addColValue("ta_hent",request.getParameter("taHent"+i));
			cdo.addColValue("tiempo_horas",request.getParameter("tiempoHoras"+i));
			cdo.addColValue("tiempo_minutos",request.getParameter("tiempoMinutos"+i));
			cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
			cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
			cdo.addColValue("fecha_creacion", "sysdate");
			cdo.addColValue("fecha_modificacion", "sysdate");
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("causa",request.getParameter("causa"+i));
			cdo.addColValue("programa",request.getParameter("programa"+i));
			cdo.addColValue("turno_asignado",request.getParameter("turnoAsig"+i));
			cdo.addColValue("aprobacion","N");
			//cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("estado","DS");

			key = request.getParameter("key"+i);
			ausHash.put(key,cdo);
			list.add(cdo);
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
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_ausencia_list.jsp?grupo=<%=grupo%>&empId=<%=empId%>';
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