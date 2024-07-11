<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />

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
String sala = "";
String proveedor = "";
String clasificacion = "";
String cuenta = "";
String tipo = "";
String salida = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<style type="text/css">
 span.hint{color:#f00; background-color:#fff;}
</style>
<script language="javascript">
document.title = 'Reporte de Activos Fijos - '+document.title;
function doAction()
{
}

function showReporte(value, bi, contotal)
{
	 var proveedor = document.form0.proveedor.value;
	 var fechaini   = document.form0.fechaini.value;
	 var fechafin   = document.form0.fechafin.value;
	 var cuenta  = document.form0.cuenta.value ;
	 var unidad = document.form0.unidad.value;
	 var placa = document.form0.placa.value;
	 var tipo = document.form0.salida.value;
	 var estatus = document.form0.estatus.value;
	 var fechaFinal = document.form0.fechaFinal.value;
	 var fechaInicial = document.form0.fechaInicial.value;
     
	if(value=="1")
	{
		abrir_ventana('../activos/print_list_activos_fijos.jsp?desde='+fechaini+'&hasta='+fechafin+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus);
	}
	if(value=="2")
	{
		var msg='';

			if(msg=='')
				abrir_ventana('../activos/print_list_activos_proveedor.jsp?desde='+fechaini+'&hasta='+fechafin+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus);
			else alert('Seleccione '+msg);
	}
	if(value=="3") {
    if (bi) {
        if(!contotal) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=activos/rpt_print_list_activos_cuenta.rptdesign&desde='+fechaini+'&hasta='+fechafin+'&cuenta='+cuenta+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus+'&pCtrlHeader=true');
        else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=activos/rpt_print_list_activos_cuenta_con_totales.rptdesign&desde='+fechaini+'&hasta='+fechafin+'&cuenta='+cuenta+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus+'&pCtrlHeader=true');
    }
    else abrir_ventana('../activos/print_list_activos_cuenta.jsp?desde='+fechaini+'&hasta='+fechafin+'&cuenta='+cuenta+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus);
	}
	else if(value=="4")
	{
	 var clasificacion  = eval('document.form0.clasificacion').value ;
	 abrir_ventana('../activos/print_list_activos_tipo.jsp?desde='+fechaini+'&hasta='+fechafin+'&clasificacion='+clasificacion+'&unidad='+unidad+'&proveedor='+proveedor+'&activo='+placa+'&fechaFinal='+fechaFinal+'&estatus='+estatus);
	}
	else if(value=="5")
	{
	 abrir_ventana('../activos/print_list_activos_unidad.jsp?desde='+fechaini+'&hasta='+fechafin+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus);
	}
	else if(value =="6")
	{
		abrir_ventana('../activos/print_list_activos_tran.jsp?placa='+placa);
	}
	else if(value == "7")
	{
		 //abrir_ventana('../activos/print_list_deprec_acum.jsp?desde='+fechaini+'&hasta='+fechafin);
		 abrir_ventana('../activos/print_list_activos_tran.jsp?placa='+placa);
	}
	else if(value == "8")
	{
		if (fechaini=="") fechaini = "0";
		if (fechafin=="") fechafin = "0";
		if (tipo == "") tipo = "0";
		var pCtrlHeader = "false";
		if (document.getElementById("pCtrlHeader").checked==true) pCtrlHeader = "true";
		abrir_ventana("../cellbyteWV/report_container.jsp?reportName=activos/rpt_print_list_activos_salida2013.rptdesign&pType="+tipo+"&pFrom="+fechaini+"&pTo="+fechafin+"&pCtrlHeader="+pCtrlHeader);
	}
	else if(value == "9")
	{
		 var anio  = eval('document.form0.anio').value ;
		 var mes  = eval('document.form0.mes').value ;

		 if (anio=='' || mes=='')  alert('Por favor introduzca el periodo de la Depreciación (Mes - Año)');
		 else
		 {
			 //abrir_ventana('../activos/print_list_deprec_acum.jsp?desde='+fechaini+'&hasta='+fechafin);
			 abrir_ventana('../activos/print_list_resumen_deprec.jsp?fg=d&anio='+anio+'&mes='+mes);
		}
	}
    else if (value == 10){
      abrir_ventana('../activos/print_list_activos_fijos_fecha_salida.jsp?desde='+fechaini+'&hasta='+fechafin+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus+'&fechaInicial='+fechaInicial);
    }
	else if(value==11){
		 var anio  = eval('document.form0.anio').value ;
		 var mes  = eval('document.form0.mes').value ;
		 cuenta  = eval('document.form0.cuentaDet').value ;
		 if (anio=='' || mes=='')  alert('Por favor introduzca el periodo de la Depreciación (Mes - Año)');
		 else
		 {
	
	abrir_ventana('../activos/print_list_activos_cuenta_mes.jsp?mes='+mes+'&anio='+anio+'&cuenta='+cuenta);}
	}else if(value==12){
		 var anio  = eval('document.form0.anio').value ;
		 var mes  = eval('document.form0.mes').value ;
		 cuenta  = eval('document.form0.cuentaDet').value ;
		 if (anio=='' || mes=='')  alert('Por favor introduzca el periodo de la Depreciación (Mes - Año)');
		 else
		 {
	
	abrir_ventana('../activos/print_list_resumen_deprec_cta.jsp?mes='+mes+'&anio='+anio+'&cuenta='+cuenta);}
	}
	else if(value=="13") {
     
         abrir_ventana('../cellbyteWV/report_container.jsp?reportName=activos/rpt_print_list_activos_mg.rptdesign&desde='+fechaini+'&hasta='+fechafin+'&cuenta='+cuenta+'&proveedor='+proveedor+'&activo='+placa+'&unidad='+unidad+'&fechaFinal='+fechaFinal+'&estatus='+estatus+'&pCtrlHeader=true');         
     
	}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE ACTIVOS FIJOS"></jsp:param>
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
						<td colspan="2">REPORTE DE ACTIVOS FIJOS </td>
					</tr>

					<tr class="TextFilter" >
						 <td width="30%">Fecha de Entrada:&nbsp;&nbsp;</td>
						 <td width="70%"> <jsp:include page="../common/calendar.jsp" flush="true">
															<jsp:param name="noOfDateTBox" value="2" />
															<jsp:param name="clearOption" value="true" />
															<jsp:param name="nameOfTBox1" value="fechaini" />
															<jsp:param name="valueOfTBox1" value="" />
															<jsp:param name="nameOfTBox2" value="fechafin" />
															<jsp:param name="valueOfTBox2" value="" />
															</jsp:include>
															<span class="hint">** = Puede mandar un rango de fecha</span>
						 </td>
					</tr>

					<tr class="TextFilter" >
						 <td width="30%">Proveedor:&nbsp;&nbsp;</td>
						 <td width="70%"><%=fb.select(ConMgr.getConnection(),"SELECT cod_provedor codigo, nombre_proveedor||' - '||cod_provedor from tbl_com_proveedor where estado_proveedor = 'ACT' and compania = "+(String) session.getAttribute("_companyId")+" ORDER BY 2","proveedor",proveedor,"T")%></td>
					</tr>

					<tr class="TextFilter" >
						<td>Unidad :&nbsp;</td>
						<td><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+" and nivel=3 and codigo <=100 order by 2","unidad","","T")%></td>
					</tr>

					<tr class="TextFilter" >
						<td>Activo #:&nbsp;</td>
						<td><%=fb.textBox("placa","",false,false,false,8,5)%></td>
					</tr>

					<tr class="TextFilter" >
						<td>Estado del Activo:&nbsp;</td>
						<td><%=fb.select("estatus","ACTI=ACTIVO,RETIR=INACTIVO","",false,false,0,null,null,null,null,"T")%></td>
					</tr>
					
					<tr class="TextFilter" >
						 <td width="30%">Garantia/Salida:&nbsp;&nbsp;</td>
						 <td width="70%">
                                                            
                                                            <jsp:include page="../common/calendar.jsp" flush="true">
															<jsp:param name="noOfDateTBox" value="2" />
															<jsp:param name="clearOption" value="true" />
															<jsp:param name="nameOfTBox1" value="fechaInicial" />
															<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
															<jsp:param name="nameOfTBox2" value="fechaFinal" />
															<jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
															</jsp:include>
																					 
                                                                                     
                                                                                     
                                                                                     
                                                                                     </td>
					</tr>
					


					<authtype type='50'>
						<tr class="TextRow01">
							<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Generales del Activo</td>
						</tr>
					</authtype>

					<authtype type='51'>
						<tr class="TextRow02">
							<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos por Orden de Compra / Proveedor</td>
						</tr>
					</authtype>

					<authtype type='52'>
						<tr class="TextRow01">
							<td>
                <%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos por Cuenta Contable
                &nbsp;&nbsp;&nbsp;<a href="javascript:showReporte(3, true)">Excel</a>
                &nbsp;&nbsp;&nbsp;<a href="javascript:showReporte(3, true, true)">Excel (Con totales)</a>
                </td>
							<td>Cuenta :&nbsp;<%=fb.select(ConMgr.getConnection(),"select cta1_activo||'.'||cta2_activo||'.'||cta3_activo||'.'||cta4_activo||'.'||cta5_activo||'.'||cta6_activo CODIGO, cta1_activo||'.'||cta2_activo||'.'||cta3_activo||'.'||cta4_activo||'.'||cta5_activo||'.'||cta6_activo||'  '||descripcion descripcion from tbl_con_especificacion where compania = "+(String) session.getAttribute("_companyId")+" ORDER BY 1","cuenta",cuenta,"T")%></td>
						</tr>
					</authtype>

					<authtype type='53'>
						 <tr class="TextRow02">
							 <td><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos por Clasificación </td>
							 <td>Clasificación :&nbsp;<%=fb.select(ConMgr.getConnection()," select  codigo_detalle, descripcion from tbl_con_detalle_otro where cod_compania = "+(String) session.getAttribute("_companyId")+" ORDER BY 2","clasificacion",clasificacion,"T")%></td>
						 </tr>
					</authtype>

					<authtype type='54'>
						<tr class="TextRow01">
							<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos por Departamento </td>
						</tr>
					</authtype>
                    
                    <authtype type='50'>
						<tr class="TextRow01">
							<td colspan="2"><label><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Generales del activo x fecha de salida</label></td>
						</tr>
					</authtype>

				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>

				<authtype type='55,56'>
					<tr class="TextHeader">
						<td colspan="2">REPORTES DE ACCIONES SOBRE ACTIVOS </td>
					</tr>
				</authtype>
				<%=fb.hidden("tipo","T")%>
				<!--<authtype type='55'>
					<tr  class="TextRow02">
						<td><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Transferencias de Activos </td>
						 <td>&nbsp;&nbsp;Tipo de Transferencia :&nbsp;<%=fb.select("tipo","I=PERMANENTE, T=TEMPORAL",tipo,false,false,0,"",null,null,"","T")%>  </td>
					</tr>
				</authtype>-->

				<authtype type='56'>
					<tr class="TextRow01">
						<td><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Salidas de Activos&nbsp;&nbsp;<span class="hint">**</span></td>
						<td>&nbsp;&nbsp;Tipos de Salidas: &nbsp;<%=fb.select(ConMgr.getConnection(),"SELECT cod_salida codigo, cod_salida||'-'||descripcion FROM tbl_con_tipo_salida order by cod_salida","salida",salida,false,false,0,"S")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Esconder Cabecera (Excel)<%=fb.checkbox("pCtrlHeader","")%></td>
					</tr>
				</authtype>

				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>

				<authtype type='57'>
						<tr class="TextHeader">
							<td colspan="2">DEPRECIACION  DE ACTIVOS FIJOS </td>
						</tr>
							<tr class="TextHeader">
								<td align="center">Nombre del reporte</td>
								<td align="center">Parámetros</td>
							</tr>

						<tr class="TextRow01">
							<td><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depreciaci&oacute;n Mensual</td>
							<td rowspan="3"><%=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"",null,null,"","S")%> &nbsp;&nbsp;Año:&nbsp;<%=fb.textBox("anio",anio,false,false,false,7)%>
							Cuenta :&nbsp;<%=fb.select(ConMgr.getConnection(),"select cta1_depre_acum||'.'||cta2_depre_acum||'.'||cta3_depre_acum||'.'||cta4_depre_acum||'.'||cta5_depre_acum||'.'||cta6_depre_acum CODIGO, cta1_depre_acum||'.'||cta2_depre_acum||'.'||cta3_depre_acum||'.'||cta4_depre_acum||'.'||cta5_depre_acum||'.'||cta6_depre_acum||'  '||descripcion descripcion from tbl_con_especificacion where compania = "+(String) session.getAttribute("_companyId")+" ORDER BY 1","cuentaDet","","T")%>
							
							</td>
						</tr>
						<tr class="TextRow01">
							<td><%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depreciaci&oacute;n Mensual Detallada</td>
							 
						</tr>
						<tr class="TextRow01">
							<td><%=fb.radio("reporte1","12",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depreciaci&oacute;n Mensual (Cuentas)</td>
							 
						</tr>
						<tr class="TextRow01">
							<td> Depreciaci&oacute;n Mensual (Cuentas) Comparativo Contabilidad
							<a href="javascript:showReporte(13, true)">Excel</a>
							
							</td>
							 
						</tr>
				</authtype>

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
