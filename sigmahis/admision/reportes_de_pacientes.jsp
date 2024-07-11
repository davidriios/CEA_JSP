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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<!-- Desarrollado por: José A. Acevedo C.              -->
<!-- Pantalla: "Reportes de Pacientes"                 -->
<!-- Reportes: ADM3087, FAC70680, ADM3040, ADM3035,    -->
<!-- ADM3060, ADM3031, ADM_10035, ADM_10033, ADM_10034 -->
<!-- Clínica Hospital San Fernando                     -->
<!-- Fecha: 25/02/2010                                 -->

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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", habitacion = "", cpt = "", aseg = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg =  request.getParameter("fg");

if (mode == null) mode = "add";
if (fg == null) fg = "REPPAC";

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
document.title = 'Reporte de Admision- '+document.title;
function doAction()
{
}

function showCPT()
{
 abrir_ventana2('../common/search_diagnostico.jsp?fp=rDiag');
}

function showMedicos()
{
 abrir_ventana2('../common/search_medico.jsp?fp=pac_x_medicos');
}

function showReporte(value)
{
	var habitacion    = "";
	if(document.form0.habitacion)habitacion = document.form0.habitacion.value;
	var area         ="";	
	if(document.form0.area)area = document.form0.area.value;
	var aseguradora  = document.form0.aseguradora.value;
	var cpt          = document.form0.cpt.value;
	var medico       = document.form0.medico.value;
	var fechaini     = document.form0.fechaini.value;
	var fechafin     = document.form0.fechafin.value;
	var poliza     = ""
	if(document.form0.poliza)poliza = document.form0.poliza.value;
	
	var cdsAdm=document.form0.cdsAdm.value;
	var cdsAdmDesc=(cdsAdm.trim()=='')?'':getSelectedOptionLabel(document.form0.cdsAdm,'');
	if(value=="1")
	{
 abrir_ventana2('../admision/print_list_pacientes_fallecidos.jsp?area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&aseguradora='+aseguradora+'&habitacion='+habitacion+'&cdsAdm='+cdsAdm+'&cdsAdmDesc='+cdsAdmDesc);
	}
	else if(value=="2")
	{
	abrir_ventana2('../admision/print_list_pacientes_x_cia_de_seguros.jsp?aseguradora='+aseguradora+'&habitacion='+habitacion+'&poliza='+poliza+'&cdsAdm='+cdsAdm+'&cdsAdmDesc='+cdsAdmDesc);
	}
	else if(value=="3")
	{
abrir_ventana2('../admision/print_pacientes_admitidos_x_medico.jsp?medico='+medico+'&fechaini='+fechaini+'&fechafin='+fechafin+'&habitacion='+habitacion+'&cdsAdm='+cdsAdm+'&cdsAdmDesc='+cdsAdmDesc);
	}
	else if(value=="4")
	{
	abrir_ventana2('../admision/print_pacientes_x_diagnostico.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&cpt='+cpt+'&habitacion='+habitacion+'&cdsAdm='+cdsAdm+'&cdsAdmDesc='+cdsAdmDesc);
	}
	else if(value == "5")
	{
	abrir_ventana2('../admision/print_pacientes_x_seccion.jsp?habitacion='+habitacion+'&sala='+area+'&aseguradora='+aseguradora+'&cdsAdm='+cdsAdm+'&cdsAdmDesc='+cdsAdmDesc);
	}
	else if(value == "6")
	{
	abrir_ventana2('../admision/print_habitaciones_en_uso.jsp?habitacion='+habitacion+'&sala='+area+'&aseguradora='+aseguradora+'&cdsAdm='+cdsAdm+'&cdsAdmDesc='+cdsAdmDesc);
	}
	else if(value == "7")
	{	
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/rpt_admisiones_jubilados.rptdesign&pCtrlHeader=true&pCds='+cdsAdm+'&pAseguradora='+aseguradora+'&pDiagnostico='+cpt+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pMedico='+medico);
	}
	/*else if(value=="7")
	{
	abrir_ventana2('../admision/print_pacientes_cu_axa_hna.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&aseg='+aseg);
	}*/
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%if(fg.trim().equals("REPPAC")){%>
				<tr class="TextFilter">
					<td width="8%">Centro</td>
					<td width="92%" >
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where compania_unorg = "+session.getAttribute("_companyId")+" and estado ='A' order by 2","area",area,false,false,0,"","","onChange=\"javascript:loadXML('../xml/hab_cds_x_unidad.xml','habitacion','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','S')\"",null,"T")%>
					</td>
				</tr>
				
				<tr class="TextFilter">
					<td width="8%">Habitación</td>
					<td width="92%">
                    
                    <%=fb.select("habitacion","","",false,false,0,null,null,"",null,"T")%>
                    <script language="javascript">
                    loadXML('../xml/hab_cds_x_unidad.xml','habitacion','<%=habitacion%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+document.search00.cds.value,'KEY_COL','S');
                    </script>
                    
                    </td>
				</tr>
				<%}else{%>
				<%=fb.hidden("habitacion","")%>
				<%}%>
				<tr class="TextFilter">
					<td width="8%">Aseguradora</td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa in (2,5) and estado = 'A' order by 2","aseguradora",aseguradora,"T")%>
					</td>
				</tr>
				<tr class="TextFilter" >
					 <td width="8%">Diagnósticos</td>
					 <td width="92%">
					 <%=fb.textBox("cpt","",false,false,false,5)%>
					 <%=fb.textBox("descripcion","",false,false,true,40)%>
					 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showCPT()\"")%>
					 </td>
				</tr>
				<tr class="TextFilter" >
					 <td width="8%">Médico</td>
					 <td width="92%">
					 <%=fb.hidden("medico","")%>
					 <%=fb.textBox("reg_medico","",false,false,false,5)%>
					 <%=fb.textBox("nombre","",false,false,true,40)%>
					 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showMedicos()\"")%>
					 </td>
				</tr>
				
				<tr class="TextFilter" >
					 <td width="50%">Fecha</td>
					 <td width="50%">
						Desde &nbsp;&nbsp;
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="clearOption" value="true"/>
										<jsp:param name="nameOfTBox1" value="fechaini"/>
										<jsp:param name="valueOfTBox1" value=""/>
									</jsp:include>
						Hasta &nbsp;&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="nameOfTBox1" value="fechafin"/>
									<jsp:param name="valueOfTBox1" value=""/>
								</jsp:include>
					 </td>
				</tr>
 				<%//if(fg.trim().equals("REPPAC")){%>
				<tr class="TextFilter">
					<td>Admitido por (CDS)</td>
					<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion centroServicio, codigo as title from tbl_cds_centro_servicio where si_no = 'S' order by 2","cdsAdm","",false,false,0,"","","",null,"T")%>
					</td>
				</tr>
				<%//}%>
 
			</table>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">Reportes de Pacientes</td>
				</tr>
				<%if(fg.trim().equals("REPPAC")){%>
				<authtype type='50'>
					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Informe de Pacientes Fallecidos</td>
						<td width="50%">&nbsp;</td>
					</tr>
				</authtype>

				<authtype type='51'>
					<tr class="TextRow01">
						<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Informe de Pacientes por Cia. de Seguros, &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;P&oacute;liza:<%=fb.textBox("poliza","",false,false,false,20)%></td>
					</tr>
				</authtype>

				<authtype type='52'>
					<tr class="TextRow01">
						<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Informe de Pacientes Admitidos por Médico</td>
					</tr>
				</authtype>

				<authtype type='53'>
					<tr class="TextRow01">
						<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Lista de Pacientes por Diagnósitco</td>
					</tr>
				</authtype>

				<authtype type='54'>
					<tr class="TextRow01">
						<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,  "onClick=\"javascript:showReporte(this.value)\"")%>Total de Habitaciones (Privada/Semi-Privada)</td>
					</tr>
				</authtype>

				<authtype type='55'>
					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Habitaciones en Uso</td>
						<td width="50%">&nbsp;</td>
					</tr>
				</authtype>
				 <%}else if(fg.trim().equals("REPPACJ")){%>
				 
				 <authtype type='56'>
					<tr class="TextRow01">
						<td width="50%"><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Paciente Tercera Edad </td>
						<td width="50%">&nbsp;</td>
					</tr>
				</authtype>
				 <%}%>
			</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</td>
	</tr>
   </table>
  </td>
</tr>
	<%=fb.formEnd(true)%>

	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
%>

