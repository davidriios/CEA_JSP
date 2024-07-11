<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String sala = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String mes  = cDateTime.substring(3,5);
String mes1  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");

if (mode == null) mode = "add";
boolean soloPermiteAdm = false;

cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'SOLO_CDS_PERMITE_ADM'),'N') as soloPermiteAdm from dual");
soloPermiteAdm = (cdo != null && cdo.getColValue("soloPermiteAdm").trim().equals("S"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Reporte de Admision y Censo de Pacientes - '+document.title;
function doAction()
{
}

function showReporte(value)
{
	 var sala = eval('document.form0.sala').value  ;
	 var mes  = document.getElementById('mes').value;
	 var mes1  = $('#mes1').val();
	 var anio = document.getElementById('anio').value;
	 var anio1 = eval('document.form0.anio1').value ;
	 var diasT = eval('document.form0.diasT').value ;
	 var fechaini   = eval('document.form0.fechaini').value;
	 var aseguradora = eval('document.form0.aseguradora').value;
	 var habitacion  = eval('document.form0.habitacion').value;
	 var aseguradora1 = eval('document.form0.aseguradora1').value;
	 var fechaHasta ='';
	 var fechaDesde ='';
	 var sala1 ='';

	 if(document.form0.fechahasta)fechaHasta=document.form0.fechahasta.value;
	 if(document.form0.fechadesde)fechaDesde=document.form0.fechadesde.value;
	 if(document.form0.sala1)sala1=document.form0.sala1.value;
     if(value=="0")
	   abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admision/pacientes_activos_diarios.rptdesign&pFechaIngreso="+$("#fecha_ingreso").val());
	else if (value=="13") abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admision/pacientes_activos_diarios_x_tipo_adm.rptdesign&pFechaIngreso="+$("#fecha_ingreso").val());
	
	else if(value=="1")abrir_ventana('../admision/print_list_censo_amanecer_fecha_actual.jsp');
	else if(value=="2"){var msg='';if(mes =='')msg =' Mes';if(anio =='')if(msg =='')msg +='Año';else msg +=' , Año';if(msg=='')abrir_ventana('../admision/print_reporte_censo_mensual_new.jsp?anio='+anio+'&mes='+mes+'&aseguradora='+aseguradora);else CBMSG.warning('Seleccione '+msg);}
	//if(value=="3")abrir_ventana2('../admision/print_list_pacientes_activos_al_dia.jsp');
	if(value=="3")abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admision/pacientes_activos.rptdesign");
	else if(value=="4")abrir_ventana2('../admision/print_hoja_trabajo_ingdiarios.jsp?sala='+sala);
	else if(value=="5")abrir_ventana2('../admision/print_p_activos_x_seccion_adm10010.jsp?sala='+sala);
	else if(value =="6")abrir_ventana('../admision/print_pacientes_x_anio.jsp?anio='+anio1+'&dia='+diasT);
	else if(value == "7")abrir_ventana2('../admision/print_censo_pacts_x_habitacion.jsp?habitacion='+habitacion);
	else if(value == "8"){if(fechaini=='')CBMSG.warning('Por favor indique el día (Fecha)');else abrir_ventana2('../admision/print_censo_det_pacts_x_sala.jsp?aseguradora='+aseguradora+'&fechaini='+fechaini);}
	else if(value == "9")abrir_ventana2('../admision/print_pacientes_activos_aseg.jsp?aseguradora='+aseguradora1);
	else if(value == "12"){abrir_ventana2('../admision/print_censos_habi_x_paciente_cargos.jsp?aseguradora='+aseguradora1+'&sala='+sala1);}
	else if(value == "11"){abrir_ventana2('../admision/print_cenos_diag_x_paciente_hosp.jsp?sala='+sala1);}
	else if (value == "20"){abrir_ventana2('../admision/print_historial_ubicacion_pac.jsp?fp=CS&cds='+sala1+'&fechaInicio='+fechaDesde+'&fechaFin='+fechaHasta);}
	else if(value=="10"||value=="10d"){
		var anio = $.trim($("#anio10").val());
		var mes = $("#mes10").val();
		var msg = '';
		var nh='';
		if(document.form0.nh.checked==true) nh = "S";
		if(!anio) msg +=' Por favor indique el Año';
		else {
			if (value == "10") abrir_ventana('../admision/print_reporte_nacimiento.jsp?anio='+anio+'&mes='+mes+'&nh='+nh);
			else if (value == "10d") { var mesDesc = (mes == '')?'':jQuery('#mes10 option:selected').text(); abrir_ventana('../admision/print_reporte_nacimiento_det.jsp?anio='+anio+'&mes='+mes+'&nh='+nh+'&mesDesc='+mesDesc); }
		}
	} else if (value == '21') {
		var cds = $("#centro_servicio").val() || -1;
		var cdsDesc = $("#centro_servicio").selText() || 'TODOS';
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admin/rpt_procedimiento_x_cds.rptdesign&cds='+cds+'&pCtrlHeader=false&cds_desc='+cdsDesc);
	}


}
function showDynamicQry(queryId){
	var month = document.getElementById("mes").value;
	var year = document.getElementById("anio").value;
	var insuranceId = document.getElementById("aseguradora").value;
	showPopWin('../common/view_dynamic_qry.jsp?queryId='+queryId+'&month='+month+'&year='+year+'&insuranceId='+insuranceId,winWidth*.75,winHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE RECIBOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
<tr>
 <td>
	 <table align="center" width="95%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
					<tr class="TextHeader">
						<td colspan="2">REPORTE DE ADMISION</td>
					</tr>
					<tr class="TextHeader">
						<td align="center">Nombre del reporte</td>
						<td align="center">Parámetros</td>
					</tr>

					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","0",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Activos Diarios</td>
						<td width="50%" rowspan="2">
						   F. Ingreso:&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="fecha_ingreso"/>
								<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>"/>
							</jsp:include>
						</td>
					</tr>
					
					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","13",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Activos Diarios Por tipo de admisi&oacute;n</td>
					</tr>
					
					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Activos Global</td>
						<td width="50%">&nbsp;</td>
					</tr>

					<tr class="TextRow01">
						<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Hoja de Trabajo por Sección para Ingresos Diarios</td>
					</tr>
					<tr class="TextRow01">
						<td ><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Activos por Sección </td>
						<td>&nbsp;&nbsp;Sala:&nbsp;
						<% if (!soloPermiteAdm){%>
							<%=fb.select(ConMgr.getConnection(),"SELECT CODIGO,DESCRIPCION||' - '||codigo FROM   tbl_cds_centro_servicio where ORIGEN = 'S' AND CODIGO NOT IN (887) and compania_unorg="+(String)session.getAttribute("_companyId")+" ORDER BY descripcion","sala",sala,"T")%>
						<%}else{%>	
						   <%=fb.select(ConMgr.getConnection(),"SELECT CODIGO,DESCRIPCION||' - '||codigo FROM   tbl_cds_centro_servicio where estado = 'A' and si_no = 'S' and compania_unorg="+(String)session.getAttribute("_companyId")+" ORDER BY descripcion","sala",sala,"T")%>
						<%}%>
						</td>
					</tr>

					 <tr class="TextRow01">
								<td width="50%"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Promedio de pacientes hospitalizados según fecha de ingreso</td>
								<td>&nbsp;&nbsp;Año:&nbsp;<%=fb.textBox("anio1",anio,false,false,false,7)%>&nbsp;&nbsp;Días transcurridos:&nbsp;<%=fb.intBox("diasT","1",false,false,false,4)%></td>
					 </tr>

					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Activos por Aseguradora</td>
						<td>&nbsp;&nbsp;Aseguradora&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora1","","T")%></td>
					</tr>
                    
                    <tr class="TextRow01">
						<td ><%=fb.radio("reporte1","21",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Procedimientos x Centro Servicios</td>
						<td>&nbsp;&nbsp;Centro de Servicios:&nbsp;
						   <%=fb.select(ConMgr.getConnection(),"SELECT CODIGO,DESCRIPCION||' - '||codigo FROM   tbl_cds_centro_servicio where estado = 'A' and compania_unorg="+(String)session.getAttribute("_companyId")+" ORDER BY descripcion","centro_servicio","","T")%>
						</td>
					</tr>


				<tr class="TextRow01">
					<td colspan="2">&nbsp;</td>
				</tr>

				<tr class="TextHeader">
					<td colspan="2">REPORTES DE CENSO</td>
				</tr>
					<tr class="TextHeader">
						<td align="center">Nombre del reporte</td>
						<td align="center">Parámetros</td>
					</tr>

				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Censo de Habitaciones por Categoria de Admisión</td>
					<td>&nbsp;&nbsp;Habitación:&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo as codigo from tbl_sal_habitacion where compania = "+session.getAttribute("_companyId")+" and quirofano != 2 order by 2","habitacion","","T")%></td>
				</tr>

				<tr class="TextRow01">
				 <td><authtype type='61'><%=fb.radio("reporte1","20",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Censo de Habitaciones por Sala</authtype></td>
				 <td>
						<table>
						 <tr>
							<td>
							 F. Desde:&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="clearOption" value="true"/>
											<jsp:param name="nameOfTBox1" value="fechadesde"/>
											<jsp:param name="valueOfTBox1" value=""/>
								</jsp:include>
									 F. Hasta:&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="clearOption" value="true"/>
											<jsp:param name="nameOfTBox1" value="fechahasta"/>
											<jsp:param name="valueOfTBox1" value=""/>
								</jsp:include>
						</td>
						 </tr>
					 </table>
				 </td>
				</tr>
			<tr  class="TextRow01">
					<td><%=fb.radio("reporte1","12",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos Por Camas Por Paciente </td>
				 <td rowspan="2">&nbsp;&nbsp;Sala:&nbsp;<%=fb.select(ConMgr.getConnection(),"SELECT CODIGO,DESCRIPCION||' - '||codigo FROM   tbl_cds_centro_servicio where ORIGEN = 'S' ORDER BY descripcion","sala1",sala,"T")%></td>
				</tr>
 <tr  class="TextRow01">
					<td><%=fb.radio("reporte1","11",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Diagnostico Por Camas Por Paciente </td>
				</tr>
				<tr  class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Censo a la Fecha </td>
				</tr>
				<tr class="TextRow01">
					<td rowspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Censo Mensual </td>
					<td>&nbsp;&nbsp;Aseguradora&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora","","T")%></td>
				</tr>
				<tr class="TextRow01">
					<td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;Año:&nbsp;<%=fb.textBox("anio",anio,false,false,false,7)%>
				<!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" onClick="javascript:showDynamicQry('CENSOMENSUAL');" class="Link00">Ver query</a>-->
			</td>
				</tr>
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Censo - Detalle Diario de Ubicación de Pacientes</td>
					<td>&nbsp;&nbsp;Fecha:&nbsp;
										<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="clearOption" value="true"/>
											<jsp:param name="nameOfTBox1" value="fechaini"/>
											<jsp:param name="valueOfTBox1" value=""/>
										</jsp:include>
					 </td>
				</tr>
				<tr class="TextRow01">
					<td>
						<%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte De Nacimiento Resumido
						<br>
						<%=fb.radio("reporte1","10d",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte De Nacimiento Detallado
					</td>
					<td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes10","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE","",false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;Año:&nbsp;<%=fb.textBox("anio10",anio,false,false,false,7)%>&nbsp;<font class="RedText" size="2">Nacidos en Hospital</font><%=fb.checkbox("nh","false")%></td>
				</tr>


					<!--<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%></td>
				</tr>--->
					<%=fb.formEnd(true)%>
				</table>
			<!-- ================================   F O R M   E N D   H E R E   ================================ --></td>
	</tr>
</table>
 </td>
	</tr>
	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
%>
