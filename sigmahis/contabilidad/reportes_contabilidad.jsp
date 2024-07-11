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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");
String compania = (String) session.getAttribute("_companyId");

if (mode == null) mode = "add";

ArrayList alClase = sbb.getBeanList(ConMgr.getConnection(),"select codigo_comprob as optValueColumn, descripcion as optLabelColumn, codigo_comprob as optTitleColumn from tbl_con_clases_comprob where estado = 'A' and tipo='C' order by 2",CommonDataObject.class);

String sqlMonth = "select lpad(level,2,0) mes, to_char(to_date('01/'||level||'/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy'),'MONTH') mes_dsp from dual connect by level <= 12 order by 1";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Reportes de Contabilidad - Mayor General - '+document.title;
function doAction()
{
}

function showReporte(value)
{
	 var mes  = eval('document.form0.mes').value ;
	 var anio = eval('document.form0.anio').value ;
	 var anio1 = eval('document.form0.anio1').value ;

	 var mesDesde  = eval('document.form0.mesDesde').value ;
	 var mesHasta  = eval('document.form0.mesHasta').value ;
	 var cta1  = eval('document.form0.cta1').value ;
	 var cta2  = eval('document.form0.cta2').value ;
	 var cta3  = eval('document.form0.cta3').value ;
	 var cta4  = eval('document.form0.cta4').value ;
	 var cta1H  = eval('document.form0.ctah1').value ;
	 var cta2H  = eval('document.form0.ctah2').value ;
	 var cta3H  = eval('document.form0.ctah3').value ;
	 var cta4H  = eval('document.form0.ctah4').value ;

	 var anioB  = eval('document.form0.anioB').value ;
	 var mesB  = eval('document.form0.mesB').value ;


	 var estado = eval('document.form0.estadoC').value;
	 var cuenta1 = eval('document.form0.cuenta1').value;
	 var con_movimiento = eval('document.form0.con_movimiento').value;
	 var con_movimiento_bph = eval('document.form0.con_movimiento_bph').value;

	if(value=="1"||value=="REPDET")
	{
		anio=document.form0.anioC.value;
		mes=document.form0.mesC.value;
		var noComprobante=document.form0.consecutivo.value;
		var fechaIni=document.form0.fechaIni.value;
		var fechaFin=document.form0.fechaFin.value;
		var group_type =document.form0.group_type.value;
		var pRegManual='N';
		if(document.form0.pRegManual)if(document.form0.pRegManual.checked)pRegManual= 'S';

		var clase=$('#clase').val();
		if(clase==null)clase='';
		if(value=="1")abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fg=CD&fp=REP&anio='+anio+'&mes='+mes+'&estado='+estado+'&no='+noComprobante+'&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&clase='+clase+'&group_type='+group_type+'&pMes13=S&pRegManual='+pRegManual);
		else abrir_ventana('../contabilidad/print_comprob_resumido.jsp?fp=mens&anio='+anio+'&mes='+mes+'&estado='+estado+'&no='+noComprobante+'&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&clase='+clase+'&group_type='+group_type+'&pMes13=S&pRegManual='+pRegManual);
	}
	else if(value=="3")
	{
	 anio = eval('document.form0.anioS').value ;
	 mes  = document.form0.mes_3.value ;
	 abrir_ventana2('../contabilidad/print_list_balance_saldo.jsp?anio='+anio+'&cta1='+cuenta1+'&mes='+mes);
	}
	else if(value=="4")
	{
		 con_movimiento = eval('document.form0.con_movimientolib').value;
		if(anio =='' || mes =='')alert('Seleccione parametros');
		else	abrir_ventana2('../contabilidad/print_list_libro_mayor.jsp?anio='+anio+'&mes='+mes+'&pMovimiento='+con_movimiento);
	}
	else if(value=="5")
	{
	 if(anio =='' || mes =='')alert('Seleccione parametros');
		else abrir_ventana('../contabilidad/print_list_libro_mayor.jsp?fp=hist&anio='+anio+'&mes='+mes);
	}
	else if(value =="6")
	{
	 if(anio1 =='' || mesDesde =='' || mesHasta=='')alert('Seleccione parametros');
	 else abrir_ventana('../contabilidad/print_list_movimiento_mayor.jsp?anio='+anio1+'&mes='+mesDesde+'&mesF='+mesHasta+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta1H='+cta1H+'&cta2H='+cta2H+'&cta3H='+cta3H+'&cta4H='+cta4H+'&con_movimiento='+con_movimiento);
	}
	else if(value == "7")
	{
		if(anio1 =='' || mesDesde =='' || mesHasta=='')alert('Seleccione parametros');
		else abrir_ventana('../contabilidad/print_list_movimiento_mayor.jsp?fp=hist&anio='+anio1+'&mes='+mesDesde+'&mesF='+mesHasta+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta1H='+cta1H+'&cta2H='+cta2H+'&cta3H='+cta3H+'&cta4H='+cta4H+'&con_movimiento='+con_movimiento);
	}
	else if(value == "9")
	{


	 var cta1  = eval('document.form0.cta_pd1').value ;
	 var cta2  = eval('document.form0.cta_pd2').value ;
	 var cta3  = eval('document.form0.cta_pd3').value ;
	 var cta4  = eval('document.form0.cta_pd4').value ;
	 var cta1H  = eval('document.form0.cta_ph1').value ;
	 var cta2H  = eval('document.form0.cta_ph2').value ;
	 var cta3H  = eval('document.form0.cta_ph3').value ;
	 var cta4H  = eval('document.form0.cta_ph4').value ;
	 var incluir_mes_13 = document.form0.incluir_mes_13.value;
	 if(anioB =='' || mesB =='' )alert('Seleccione parametros');
	 else abrir_ventana2('../contabilidad/print_list_balance_prueba.jsp?fp=hist&anio='+anioB+'&mes='+mesB+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta1H='+cta1H+'&cta2H='+cta2H+'&cta3H='+cta3H+'&cta4H='+cta4H+'&con_movimiento='+con_movimiento_bph+'&incluir_mes_13='+incluir_mes_13);
	}
	else if(value=="10"||value=="11")
	{
	 anio = eval('document.form0.anioS').value ;
	 mes  = document.form0.mes_3.value ;
	 var movimiento ='';
	 var fg ='SI';
	 if(value=="11")fg='SF';
	 if(document.form0.movimiento) movimiento  = document.form0.movimiento.value ;
	 if(anio !='' && mes !='')abrir_ventana2('../contabilidad/print_list_saldo_inicial.jsp?anio='+anio+'&cta1='+cuenta1+'&mes='+mes+'&movimiento='+movimiento+'&fg='+fg);
	 else alert('Seleccione año/ mes para generar el reporte');
	}

}
function printRptBI(option){
	 var pAnio = document.getElementById("anio1").value;
	 var pMesDesde  = document.getElementById("mesDesde").value;
	 var pConMov  = (document.getElementById("con_movimiento").value==""?"N":document.getElementById("con_movimiento").value);
	 var pMesHasta  = document.getElementById("mesHasta").value
	 var pIncMes13  = document.getElementById("incluir_mes_13").value;
	 var pCtrlHeader = document.getElementById("ctrlHeaderT").checked;
	 
	 var cta = getCta('cta', 'ctah', 4);

	 var pCtaDesde = cta.CF,pCtaHasta = cta.CT;

	 switch (option){
	 case 6:
	 //case 7:
		 //if (option==7 && (pCtaDesde=="0-0-0-0") ) {alert("El rango de cuenta por favor!"); break;}
		 abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_movimiento_mayor.rptdesign&pAnio="+pAnio+"&pMesDesde="+pMesDesde+"&pMesHasta="+pMesHasta+"&pConMov="+pConMov+"&pCtaDesde="+pCtaDesde+"&pCtaHasta="+pCtaHasta+"&pCtrlHeader="+pCtrlHeader+"&pFp="+(option==7?"hist":"0"));
	 break;
		 case 9:
		 pAnio = document.getElementById("anioB").value;
		 pMesDesde  = document.getElementById("mesB").value;
		 pConMov  = (document.getElementById("con_movimiento_bph").value==""?"N":document.getElementById("con_movimiento_bph").value);
		 var pCtrlHeader = document.getElementById("ctrlHeaderB").checked;
		 pCtaDesde = "",pCtaHasta = "";
		 for (i=1; i<=4; i++){
		 pCtaDesde += (document.getElementById("cta_pd"+i).value==""?"0":document.getElementById("cta_pd"+i).value);
		 pCtaHasta += (document.getElementById("cta_ph"+i).value==""?"0":document.getElementById("cta_ph"+i).value);
		 if (i!=4) {pCtaDesde += "-"; pCtaHasta += "-";}
		}
		var _continue = true;
		if (pConMov=="N" || pCtaDesde=="0-0-0-0"){
		if (!confirm("Ejecutar todas las cuentas puede tardar varios minutos")) _continue = false;
		}
		if (_continue){
			abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_balance_prueba.rptdesign&pIncMes13="+pIncMes13+"&pAnio="+pAnio+"&pMesDesde="+pMesDesde+"&pConMov="+pConMov+"&pCtaDesde="+pCtaDesde+"&pCtaHasta="+pCtaHasta+"&pCtrlHeader="+pCtrlHeader);
		}

	 break;
	 case 8:
	    var _continue = true;
		var tipo = $("#curRpt").val();
	    var mesTo = $("#mesF").val() || '0';
		var mesFrom = $("#mesI").val() || '0';
		var anioI = $("#anioI").val() || '0';
		var anioTo = $("#anioAF").val() || $("#anioMF").val();
		var ctaPrin = $("#ctaPrin").val() || 'ALL';
		var claseCta = $("#claseCta").val() || 'ALL';
		var dateTo = "to_date('01/'||"+mesTo+"||'/'||"+anioTo+",'dd/mm/yyyy')";
		var dateFrom = "to_date('01/'||"+mesFrom+"||'/'||"+anioTo+",'dd/mm/yyyy')";
		var c;
		
		try{
		  c = getCta('cta8', 'ctah8', 4);
		  pCtaDesde = c.CF;
		  pCtaHasta = c.CT;
		}catch(e){
		   alert(e.name + "\n" + e.message);
		}
		
		if (canBePrinted()){
		   abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_movimientos.rptdesign&pMesTo="+mesTo+"&pAnioI="+anioI+"&pAnioTo="+anioTo+"&pMesFrom="+mesFrom+"&pCtaDesde="+pCtaDesde+"&pCtaHasta="+pCtaHasta+"&pCtrlHeader="+pCtrlHeader+'&pCtaPrin='+ctaPrin+'&pClaseCta='+claseCta+'&pTipo='+tipo);
		}
		
	 case 10:
	 case 11:
	    var mes = $("#mes").val() || '01';
		var anio = $("#anio").val() || '<%=anio%>';
		var pFp= option==11?"hist":"NH";
		  pConMov  = (document.getElementById("con_movimientolib").value==""?"N":document.getElementById("con_movimientolib").value);
		abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_libro_mayor.rptdesign&pMonthCode="+mes+"&pAnio="+anio+"&pCtrlHeader="+pCtrlHeader+"&pFp="+pFp+"&pConMov="+pConMov);
	 break;
		
	 break;
		 default: alert("No pudimos encontrar el reporte solicitado!");
	 }
}

/**
* @param inObjF : input text name cta from
* @param inObjF : input text name cta to
* @param qty : total of inputs (cta1, ctan)
*
* return object
*
* Example:
* var c = getCtas('ctaF', 'ctaT', 3);
* c.CF = cta desde, c.CT = cta hasta
*
* Enjoy!
*/
function getCta(inObjF, inObjT, qty){
  var pCtaDesde=pCtaHasta="";
  for (i=1; i<=qty; i++){
	pCtaDesde += $("#"+inObjF+""+i).val() || "0";
	pCtaHasta += $("#"+inObjT+""+i).val() || "0";
	if (i!=qty) {pCtaDesde += "-"; pCtaHasta += "-";}
  }
  return {'CF':pCtaDesde,'CT':pCtaHasta};
}
function ctrlRpt(val){
   if (val=="M"){
     $("#rpt_m").show(0);
     $("#rpt_a").hide(0);
	 $("#curRpt").val("M");
	 $("#anioAF").val("");
	 $("#anioI").val("");
   }else if (val=="A"){
     $("#rpt_a").show(0);
     $("#rpt_m").hide(0);
	 $("#curRpt").val("A");
	 $("#mesI").val(""); 
	 $("#mesF").val("");
	 $("#anioMF").val("");
   }
}
function canBePrinted(){
  var curRpt = $("#curRpt").val();
  var flag = true;
  if (curRpt=="") {flag = false; alert("Por favor escoge un reporte!");}
  else if (curRpt=="A"){
    if ($("#anioAF").val()=="" || $("#anioI").val() == ""){flag = false;alert("Por favor indique un rango de años!");}
  }else if (curRpt=="M"){ 
    if ($("#mesI").val()=="" || $("#mesF").val()=="" || $("#anioMF").val() == ""){flag = false;alert("Por favor indique un rango de meses y el año!");}
  }
  return flag;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE CONTABILIDAD"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("curRpt","")%>
<tr>
 <td>
	 <table align="center" width="95%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="3" cellspacing="1">
					<tr class="TextHeader">
						<td colspan="2">REPORTES DIARIOS</td>
					</tr>
					<tr class="TextHeader">
						<td align="center">Nombre del reporte</td>
						<td align="center">Par&aacute;metros <span style="margin-left:100px"><%=fb.checkbox("ctrlHeaderT","")%>Sin Cabacera (Excel)</span></td>
					</tr>
					<tr class="TextRow01">
						<td width="40%"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Balance de Saldos</td>
					 <td width="60%" rowspan="3">A&ntilde;o:&nbsp;<%=fb.select(ConMgr.getConnection(),"select distinct ano,ano,ano from tbl_con_plan_cuentas where compania = "+compania+" order by 1 desc","anioS","",false,false,0,"Text10",null,"",null,"")%>&nbsp;&nbsp;Mes:<%=fb.select("mes_3","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","")%>&nbsp;&nbsp;Cuenta Control:&nbsp;<%=fb.select(ConMgr.getConnection(),"select distinct cta1, lpad(cta1,3,'0'), cta1 from tbl_con_catalogo_gral where compania = "+compania+" order by 2","cuenta1","",false,false,0,"Text10",null,"",null,"S")%> </td>
					</tr>
			<tr class="TextRow01">
						<td width="40%"><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Saldo Inicial</td>
		</tr>
		<tr class="TextRow01">
						<td width="40%"><%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Saldo Final</td>
		</tr>

					<tr class="TextRow01">
						<td>
						<table width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td width="90%"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Libro Mayor</td>
								<td width="10%"><a href="javascript:printRptBI(10)" class="Link01Bold" title="Libro Mayor">Excel</a></td>
							</tr>	
						</table>
						</td>
						<td rowspan="2">A&ntilde;o:&nbsp;<%=fb.textBox("anio",anio,false,false,false,7)%>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","")%> Cuentas:<%=fb.select("con_movimientolib","S=Con Movimiento","",false,false,0,"Text10",null,null,"","T")%></td>
				</tr>

					<tr class="TextRow01">
						<td> &nbsp;
						<!--<table width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td width="90%"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Libro Mayor-Hist&oacute;rico</td>
								<td width="10%"><a href="javascript:printRptBI(11)" class="Link01Bold" title="Libro Mayor-Hist&oacute;rico">Excel</a></td>
								</tr>	
						</table>--></td>

					</tr>
					 <tr class="TextRow01">
								<td width="40%">
									<table width="100%" cellpadding="0" cellspacing="0">
									<tr>
										<td width="90%"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Movimiento Mayor</td>
										<td width="10%"><a href="javascript:printRptBI(6)" class="Link01Bold"title="Movimiento Mayor">Excel</a></td>
									</tr>
									</table>
								</td>
								<td>A&ntilde;o:&nbsp;<%=fb.textBox("anio1",anio,false,false,false,7)%>&nbsp;&nbsp;Mes Desde:&nbsp;<%=fb.select("mesDesde","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","")%> Mes Hasta: &nbsp;<%=fb.select("mesHasta","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","")%>&nbsp;&nbsp;Cuentas:<%=fb.select("con_movimiento","S=Con Movimiento","",false,false,0,"Text10",null,null,"","T")%></td>
					 </tr>

					<tr class="TextRow01">
						<td width="40%">
							&nbsp;<!--<table width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td width="90%"><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Movimiento Mayor-Hist&oacute;rico</td>
								<td width="10%"><a href="javascript:printRptBI(7)" class="Link01Bold" title="Movimiento Mayor-Hist&oacute;rico">Excel</a></td>
							</tr>
							</table>-->
						</td>
						<td>Cuenta Desde:&nbsp;
						<%=fb.textBox("cta1","",false,false,false,3,3)%>
						<%=fb.textBox("cta2","",false,false,false,3,2)%>
						<%=fb.textBox("cta3","",false,false,false,3,3)%>
						<%=fb.textBox("cta4","",false,false,false,3,3)%>&nbsp;&nbsp;Cuenta Hasta:&nbsp;
						<%=fb.textBox("ctah1","",false,false,false,3,3)%>
						<%=fb.textBox("ctah2","",false,false,false,3,2)%>
						<%=fb.textBox("ctah3","",false,false,false,3,3)%>
						<%=fb.textBox("ctah4","",false,false,false,3,3)%></td>
					</tr>
					
					
					
					
					<tr class="TextRow01">
						<td width="40%">
							<table width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td width="90%"><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:ctrlRpt('M')\"")%>Movimientos por Mes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<%=fb.radio("reporte1","12",false,false,false,null,null,"onClick=\"javascript:ctrlRpt('A')\"")%>Movimientos por A&ntilde;o
								</td>
								<td width="10%"><a href="javascript:printRptBI(8)" class="Link01Bold">Excel</a></td>
							</tr>
							</table>
						</td>
						<td>
						<div id="rpt_m" style="display:none">
						Mes Ini.:<%=fb.select("mesI","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL","",false,false,0,"Text10",null,null,"","S")%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mes. Fin.&nbsp;:<%=fb.select("mesF","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL","",false,false,0,"Text10",null,null,"","S")%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A&ntilde;o:&nbsp;<%=fb.select(ConMgr.getConnection(),"select (to_number(to_char(sysdate,'yyyy')) - level)+1 dd from dual connect by level <= 10","anioMF","",false,false,0,"Text10",null,"",null,"S")%>
						</div>
						
						<div id="rpt_a" style="display:none">
						 A&ntilde;o Ini.:&nbsp;<%=fb.select(ConMgr.getConnection(),"select (to_number(to_char(sysdate,'yyyy')) - level)+1 dd from dual connect by level <= 5 order by 1","anioI","",false,false,0,"Text10",null,"",null,"S")%>
						 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						  A&ntilde;o Ini.:&nbsp;<%=fb.select(ConMgr.getConnection(),"select (to_number(to_char(sysdate,'yyyy')) - level)+1 dd from dual connect by level <= 5 order by 1","anioAF","",false,false,0,"Text10",null,"",null,"S")%>
						</div>
						
						<hr />
						
					    Cuenta: <%=fb.select(ConMgr.getConnection(),"select codigo_prin as codigo, descripcion cta_dsp from tbl_con_ctas_prin  order by descripcion","ctaPrin","",false,false,0,"Text10",null,"",null,"T")%>&nbsp;&nbsp;&nbsp;&nbsp;
						Clase: <%=fb.select(ConMgr.getConnection(),"select codigo_clase, descripcion clase_dsp from tbl_con_cla_ctas order by descripcion","claseCta","",false,false,0,"Text10",null,"",null,"T")%> 
					    <hr />
						Cuenta Desde:&nbsp;
						<%=fb.textBox("cta81","",false,false,false,3,3)%>
						<%=fb.textBox("cta82","",false,false,false,3,2)%>
						<%=fb.textBox("cta83","",false,false,false,3,3)%>
						<%=fb.textBox("cta84","",false,false,false,3,3)%>&nbsp;&nbsp;Cuenta Hasta:&nbsp;
						<%=fb.textBox("ctah81","",false,false,false,3,3)%>
						<%=fb.textBox("ctah82","",false,false,false,3,2)%>
						<%=fb.textBox("ctah83","",false,false,false,3,3)%>
						<%=fb.textBox("ctah84","",false,false,false,3,3)%>
						</td>
					</tr>
				<tr class="TextRow01">
					<td colspan="2">&nbsp;</td>
				</tr>

				<tr class="TextHeader">
					<td colspan="2">REPORTES MENSUALES</td>
				</tr>
					<tr class="TextHeader">
						<td align="center">Nombre del reporte</td>
						<td align="center">Par&aacute;metros <span style="margin-left:100px"><%=fb.checkbox("ctrlHeaderB","")%>Sin Cabacera (Excel)</span></td>
					</tr>

				<tr class="TextRow01">
					<td>
					<table width="100%" cellpadding="0" cellspacing="0">
						 <tr>
							 <td width="90%">
						 <%//=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Balance de Prueba - Hist&oacute;rico</td>
						<td width="10%"><a href="javascript:printRptBI(9)" class="Link01Bold">Excel</a></td>
						 </tr>
					 </table>
					</td>
					<td>A&ntilde;o:&nbsp;<%=fb.textBox("anioB",anio,false,false,false,4,4)%>&nbsp;&nbsp;
					Mes: <%=fb.select("mesB","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","")%>&nbsp;&nbsp;Cuentas:<%=fb.select("con_movimiento_bph","S=Con Movimiento","",false,false,0,"Text10",null,null,"","T")%>
					Incluir cierre anual?
					<%=fb.select("incluir_mes_13","Y=Si,N=No","N",false,false,0,"Text10",null,null,"","")%>
					<br>
					Cuenta Desde:&nbsp;<%=fb.textBox("cta_pd1","",false,false,false,3,3)%>
					<%=fb.textBox("cta_pd2","",false,false,false,3,2)%>
					<%=fb.textBox("cta_pd3","",false,false,false,3,3)%>
					<%=fb.textBox("cta_pd4","",false,false,false,3,3)%>&nbsp;&nbsp;
					Cuenta Hasta:&nbsp;
					<%=fb.textBox("cta_ph1","",false,false,false,3,3)%>
					<%=fb.textBox("cta_ph2","",false,false,false,3,2)%>
					<%=fb.textBox("cta_ph3","",false,false,false,3,3)%>
					<%=fb.textBox("cta_ph4","",false,false,false,3,3)%>
					</td>
				</tr>

				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Comprobantes </td>
					<td>
						A&ntilde;o: <%=fb.textBox("anioC",anio,false,false,false,4,4)%>
						Mes: <%=fb.select("mesC","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","S")%>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2"/>
						<jsp:param name="clearOption" value="true"/>
						<jsp:param name="nameOfTBox1" value="fechaIni"/>
						<jsp:param name="valueOfTBox1" value=""/>
						<jsp:param name="nameOfTBox2" value="fechaFin"/>
						<jsp:param name="valueOfTBox2" value=""/>
						</jsp:include>
						</br>
						No. Comprobante: <%=fb.textBox("consecutivo","",false,false,false,10)%>
						Estado: <%=fb.select("estadoC","AP=APROBADO,PE=PENDIENTE",mes,false,false,0,"Text10",null,null,"","T")%>
						</br>
						Grupo de Comprobante:<%=fb.select(ConMgr.getConnection(), "select id, descripcion,id||' - '||descripcion from tbl_con_group_comprob where estado ='A' ", "group_type", "",false,false,0,"S")%><br>
						&nbsp;&nbsp; Solo Registros Manuales:  <%=fb.checkbox("pRegManual","false")%><br>
						Tipo: <%=fb.select("clase",alClase,"",false,true,false,5,"Text10",null,null,null,"T")%>
						<%=fb.button("rep_detallado","Comprobantes Resumidos",false,false,"text10","","onClick=\"javascript:showReporte('REPDET');\"")%>
					</td>
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
