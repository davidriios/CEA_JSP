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
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr"/>
<!-- Pantalla: "Reportes de Admisión" (DIAGNOSTICOS DE PACIENTES)   -->
<!-- Reportes: ADM2030, ADM_10013, ADM10060, ADM_10039,             -->
<!-- SAL8001844, CDS200070                                          -->
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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", categoriaDiag = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Reporte de Admision- '+document.title;
function doAction()
{
}

function showCategoriaDiagnostico()
{
 abrir_ventana2('../admision/categoriadiagnostico_list.jsp?fp=rCatDiag');
}

function showReporte(value, xtraParams)
{
	var categoria    = eval('document.form0.categoria').value;
	var categoriaDiag = eval('document.form0.categoriaDiag').value;
 // var tipoAdmision = eval('document.form0.tipoAdmision').value;
	var area         = eval('document.form0.area').value;
	var aseguradora  = eval('document.form0.aseguradora').value;
	var fechaini     = eval('document.form0.fechaini').value;
	var fechafin     = eval('document.form0.fechafin').value;
	var horaini     = eval('document.form0.horaini').value;
	var horafin     = eval('document.form0.horafin').value;
	var medico      = document.form0.medico.value;
	var pCtrlHeader      = document.form0.pCtrlHeader.checked;
/*
	if(value=="0")
	 {
		abrir_ventana2('../admision/print_list_diagnostico.jsp');
	 }*/
	if(value=="1")
	{
				if(!xtraParams)abrir_ventana2('../admision/print_list_diagnosticos_pacts_x_aseg.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&categoriaDiag='+categoriaDiag+'&fechaini='+fechaini+'&fechafin='+fechafin+'&horaini='+horaini+'&horafin='+horafin+'&medico='+medico);
				else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=admision/rpt_list_diagnosticos_pacts_x_aseg.rptdesign&categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&categoriaDiag='+categoriaDiag+'&fechaini='+fechaini+'&fechafin='+fechafin+'&horaini='+horaini+'&horafin='+horafin+'&medico='+medico+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="2")
	{
	abrir_ventana2('../admision/print_list_ingresos_pacts_con_diagnosticos.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&categoriaDiag='+categoriaDiag+'&fechaini='+fechaini+'&fechafin='+fechafin+'&horaini='+horaini+'&horafin='+horafin+'&medico='+medico);
	}
	else if(value=="3")
	{
	abrir_ventana2('../admision/print_list_diagnosticos_salidas_pacts.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&categoriaDiag='+categoriaDiag+'&fechaini='+fechaini+'&fechafin='+fechafin+'&horaini='+horaini+'&horafin='+horafin+'&medico='+medico);
	}
	else if(value=="4")
	{
	abrir_ventana2('../admision/print_diagnosticos_x_categoria.jsp?categoriaDiag='+categoriaDiag);
	}
	else if(value=="5")
	{
	abrir_ventana2('../facturacion/print_transacc_registradas_x_user_new2.jsp');
	}
	else if(value=="6")
	{

		var tipo         = eval('document.form0.tipo').value;
		if(tipo==''){CBMSG.warning('Seleccione el tipo De Reporte a ejecutar');}
	else{
	var msg='';
	var mes      = eval('document.form0.mes').value;
	var anio      = eval('document.form0.anio').value;
	var trimestre      = eval('document.form0.trimestre').value;

	if(tipo=='M'&&(mes==''||anio==''))msg +='Seleccione mes/año';
	else if(tipo=='A'&&anio=='')msg +='Seleccione Año';
	else if(tipo=='T'&&(trimestre==''||anio==''))msg +='Seleccione Trimestre / año';
		if(msg ==''){abrir_ventana('../admision/print_diag_mas_comunes.jsp?tipo='+tipo+'&mes='+mes+'&anio='+anio+'&trimestre='+trimestre+'&medico='+medico);}else CBMSG.warning(msg);
		}
	}else if (value == "7"){
			var cds = $("#cds").val();
			var frecuencia = $("#frecuencia").val();
			var primerDia = $("#primer_dia").val() || '01/01/1900';
			var pCtrlHeader = $("#ctrl_header").is(":checked");
			var xtraParams = "&pCds="+cds+"&pFrecuencia="+frecuencia+"&pPrimerDia="+primerDia+"&pDesde=0&pHasta=0&pCtrlHeader="+pCtrlHeader+'&pMedico='+medico;
			abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admision/rpt_informe_epidemiologicos_enf_notif602.rptdesign"+xtraParams);
		}
		else if (value == "8"){
				abrir_ventana2('../admision/print_list_pacts_x_med_y_diag.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&categoriaDiag='+categoriaDiag+'&fechaini='+fechaini+'&fechafin='+fechafin+'&horaini='+horaini+'&horafin='+horafin+'&medico='+medico);
		}
}

allowWriting({
		inputs: "#medico, #nombreMedico",
		listener: "keydown",
		keycode: 9,
		keyboard: true,
		iframe: "#preventPopupFrame",
		searchParams: {
				medico:"codigo", nombreMedico: "nombre"
		},
		baseUrls: {
				medico: "../common/search_medico.jsp?fp=diag_pacientes&fg=diag_pacientes",
				nombreMedico: "../common/search_medico.jsp?fp=diag_pacientes&fg=diag_pacientes",
		}
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE DIAGNOSTICOS DE PACIENTES"></jsp:param>
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
	 <table align="center" width="90%" cellpadding="0" cellspacing="1">
		<tr>
			<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter" >
					 <td width="20%">Categoria</td>
					 <td width="80%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%></td>
				</tr>

				<tr class="TextFilter" >
					 <td>Categoria Diag.</td>
					 <td>
					 <%=fb.textBox("categoriaDiag","",false,false,false,5)%>
					 <%=fb.textBox("descCategDiag","",false,false,true,54)%>
					 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showCategoriaDiagnostico()\"")%>
					 </td>
				</tr>

				<tr class="TextFilter">
						<td>Area que Admite</td>
						<td><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and si_no = 'S' order by 2","area",area,"T")%></td>
				</tr>

				<tr class="TextFilter">
					<td>Aseguradora</td>
					<td>
					<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa order by 2","aseguradora",aseguradora,"T")%>
					</td>
				</tr>

				<tr class="TextFilter" >
					 <td>Fecha</td>
					 <td>
								<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2"/>
										<jsp:param name="clearOption" value="true"/>
										<jsp:param name="nameOfTBox1" value="fechaini"/>
										<jsp:param name="valueOfTBox1" value="<%=cDateTime%>"/>
										<jsp:param name="nameOfTBox2" value="fechafin"/>
										<jsp:param name="valueOfTBox2" value="<%=cDateTime%>"/>
										</jsp:include>
					</td>
				</tr>

				<tr class="TextFilter" >
					 <td>Hora</td>
					 <td>
								<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2"/>
										<jsp:param name="clearOption" value="true"/>
										<jsp:param name="nameOfTBox1" value="horaini"/>
										<jsp:param name="valueOfTBox1" value=""/>
										<jsp:param name="nameOfTBox2" value="horafin"/>
										<jsp:param name="valueOfTBox2" value=""/>
										<jsp:param name="format" value="hh12:mi pm"/>
								</jsp:include>
					</td>
				</tr>

								<tr class="TextFilter">
					 <td>M&eacute;dico</td>
					 <td>
					 <%=fb.textBox("medico","",false,false,false,10)%>
					 <%=fb.textBox("nombreMedico","",false,false,false,30)%>
					 </td>
				</tr>
								<tr class="TextFilter">
					 <td>Esconder cabecera (Excel)</td>
					 <td>
						 <input type="checkbox" name="pCtrlHeader" id="pCtrlHeader">
					 </td>
				</tr>

								<tr class="TextFilter" >
					 <td colspan="2">
												<iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe>
										 </td>
								</tr>

			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">&nbsp;Reportes de Pacientes y sus Diagnósticos</td>
				</tr>

								<tr class="TextRow01">
					<td><authtype type='4'><label><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte epidemiol&oacute;gico</label></authtype></td>
										<td>
											 <table  width="100%" cellpadding="1" cellspacing="1">
						<tr>
							<td>Primer d&iacute;a:&nbsp;

														<jsp:include page="../common/calendar.jsp" flush="true">
																<jsp:param name="noOfDateTBox" value="1"/>
																<jsp:param name="clearOption" value="true"/>
																<jsp:param name="nameOfTBox1" value="primer_dia"/>
																<jsp:param name="valueOfTBox1" value="<%=cDateTime%>"/>
								</jsp:include><br>
																<strong>** Semana que inicia el domingo (dd/mm/yyyy). No cambiar si no desea filtrar por fecha de ingreso.</strong>
														</td>
						</tr>
						<tr>
							<td>Cds:&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select to_char(c.codigo)  codigo, c.descripcion from tbl_cds_centro_servicio c, tbl_sec_unidad_ejec ua where (c.codigo = ua.codigo and c.compania_unorg = ua.compania) and c.tipo_cds = 'I' and ua.nivel = 3 and ua.codigo < 100 and ua.compania = "+session.getAttribute("_companyId")+" union select 'CDS', '*** TODOS LOS CENTROS ***' from dual order by 2","cds","","")%></td>
						</tr>
						<tr>
							<td>Fecuencia:&nbsp;&nbsp;<%=fb.select("frecuencia","S=SEMANAL,M=MENSUAL,A=ANUAL","S",false,false,0,"Text10",null,null,"","")%></td>
						</tr>
												<tr>
							<td><label><input type="checkbox" name="ctrl_header" id="ctrl_header">Esconder cabecera?:&nbsp;&nbsp;</label></td>
						</tr>
					</table>
										</td>
				</tr>
				<tr class="TextRow01">
					<td width="50%" colspan="2"><authtype type='50'><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Admitidos y sus Diagnósticos - Por Aseguradora
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="Link00Bold" href="javascript:showReporte(1,1)">Excel</a>
										</authtype></td>
				</tr>

								<tr class="TextRow01">
					<td width="50%" colspan="2"><authtype type='54'><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Admitidos x M&eacute;dico y Diagnóstico</authtype></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><authtype type='51'><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Admitidos y sus Diagnósticos - Por Centro de Admisión</authtype></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><authtype type='52'><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Salidas de Pacientes y sus Diagnósticos</authtype></td>
				</tr>
				<tr class="TextRow01">
					<td><authtype type='53'><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>10 Diagnósticos Mas Comunes</authtype></td>
					<td>
					<table>
						<tr>
							<td rowspan="4">Tipo:<%=fb.select("tipo","M=MENSUAL,T=TRIMESTRAL,A=ANUAL","M",false,false,0,"Text10",null,null,"","S")%></td>
						</tr>
						<tr>
							<td>Mes:&nbsp;<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","S")%> </td>
						</tr>
						<tr>
							<td>Año:&nbsp;<%=fb.textBox("anio",anio,false,false,false,7)%> </td>
						</tr>
						<tr>
							<td>Trimestre:<%=fb.select("trimestre","1=PRIMER TRIMESTRE,2=SEGUNDO TRIMESTRE,3=TERCER TRIMESTRE,4=CUARTO TRIMESTRE","",false,false,0,"Text10",null,null,"","S")%></td>
						</tr>
					</table>


					</td>

				</tr>



<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
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

