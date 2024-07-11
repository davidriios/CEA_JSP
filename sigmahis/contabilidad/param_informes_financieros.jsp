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
CommonDataObject cdoParam = new CommonDataObject();

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

sql = "select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CON_SHOW_REP_BALANCE'),0)  as repBalance  from dual";
	cdoParam = SQLMgr.getData(sql);
	if(cdoParam == null){ cdoParam = new CommonDataObject();cdoParam.addColValue("repBalance","0");}
	
	
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
function doAction(){}
function printRptBI(option){
	 var pAnio = document.getElementById("anioB").value;
	 var pMesDesde  = "";
	 var pConMov  = (document.getElementById("con_movimiento_bph").value==""?"N":document.getElementById("con_movimiento_bph").value);
	 var pMesHasta  = "";
	 var pIncMes13  = document.getElementById("incluir_mes_13").value;
	 var pCtrlHeader = document.getElementById("ctrlHeaderB").checked;
	 var ctaPrincipal = '';
	 var tipoCuenta = '';
	 var excluirCierre='';
 	 if(document.form0.ctaPrin)ctaPrincipal= document.form0.ctaPrin.value;
	 if(document.form0.claseCta)tipoCuenta= document.form0.claseCta.value;
	 if(document.form0.excluirCierre)excluirCierre= document.form0.excluirCierre.value;

	 var cta = getCta('cta_pd', 'cta_ph', 4);

	 var pCtaDesde = cta.CF,pCtaHasta = cta.CT;

	 switch (option){
		 case 1:
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
			abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_balance_prueba.rptdesign&pIncMes13="+pIncMes13+"&pAnio="+pAnio+"&pMesDesde="+pMesDesde+"&pConMov="+pConMov+"&pCtaDesde="+pCtaDesde+"&pCtaHasta="+pCtaHasta+"&pCtrlHeader="+pCtrlHeader+'&pCuentaPrincipal='+ctaPrincipal+'&pTipoCuenta='+tipoCuenta+'&pExcluirCierre='+excluirCierre);
		}
		break;
		case 2:
		  pAnio = document.getElementById("anioBS").value || '0000';
		  pMesDesde  = document.getElementById("mesBS").value || '00';
		  var repBalance ='<%=cdoParam.getColValue("repBalance")%>';
		  if(repBalance=='0')abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_balance_situacion.rptdesign&pAnio="+pAnio+"&pMonthCode="+pMesDesde+"&pCtrlHeader="+pCtrlHeader);
		  else if(repBalance=='1')abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_balance_situacion_new.rptdesign&pAnio="+pAnio+"&pMonthCode="+pMesDesde+"&pCtrlHeader="+pCtrlHeader);
		break;
		case 3:
		  pAnio = document.getElementById("anioER").value || '0000';
		  pMesDesde  = document.getElementById("mesER").value || '00';
		  if(document.form0.excluirCierreR)excluirCierre= document.form0.excluirCierreR.value;
		  abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_estado_resultado.rptdesign&pAnio="+pAnio+"&pMonthCode="+pMesDesde+"&pCtrlHeader="+pCtrlHeader+'&pExcluirCierre='+excluirCierre);
		break;
		case 4:
		  pAnio = document.getElementById("anioHT").value || '0000';
		  pMesDesde  = document.getElementById("mesHT").value || '00';
		  abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_hoja_trabajo.rptdesign&pAnio="+pAnio+"&pMes="+pMesDesde+"&pCtrlHeader="+pCtrlHeader);
		break;
		case 5:
		  pAnio = document.getElementById("anioEGP").value || '0000';
		  pMesDesde  = document.getElementById("mesEGP").value || '00';
		  var pCtaPrin  = document.getElementById("pCtaPrin").value || '';
		  abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_estado_gan_perdida.rptdesign&pAnio="+pAnio+"&pMes="+pMesDesde+"&pCtrlHeader="+pCtrlHeader+"&pCtaPrin="+pCtaPrin);
		break;
	 }
}

/**
* @param inObjF : input text name cta_pd from
* @param inObjF : input text name cta_ph to
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
	<table align="center" width="95%" cellpadding="0" cellspacing="1">
		<tr>
			<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
				<table align="center" width="100%" cellpadding="3" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">REPORTES MENSUALES</td>
				</tr>
				<tr class="TextHeader">
					<td align="center">Nombre del reporte</td>
					<td align="center">Par&aacute;metros <span style="margin-left:100px"><%=fb.checkbox("ctrlHeaderB","")%>Sin Cabacera (Excel)</span></td>
				</tr>
				<tr class="TextRow01">
					<td>
							 <authtype type='50'>
					<table width="100%" cellpadding="0" cellspacing="0">
						 <tr>
							 <td width="90%">
						 Balance de Prueba - Hist&oacute;rico
						 </td>
						<td width="10%" align="right"><a href="javascript:printRptBI(1)" class="Link01Bold">Excel</a></td>
						 </tr>
					 </table>
						 </authtype>
					</td>
					<td>
					 Cuenta Principal:&nbsp; <%=fb.select(ConMgr.getConnection(),"select codigo_prin as codigo, descripcion cta_dsp from tbl_con_ctas_prin  order by descripcion","ctaPrin","",false,false,0,"Text10",null,"",null,"T")%>&nbsp;&nbsp;&nbsp;&nbsp;<br>
					 Clase Cuenta:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo_clase, descripcion clase_dsp from tbl_con_cla_ctas order by descripcion","claseCta","",false,false,0,"Text10",null,"",null,"T")%> <br>
					
					A&ntilde;o :&nbsp;<%=fb.textBox("anioB",anio,false,false,false,4,4)%>&nbsp;&nbsp;
					Mes: <%=fb.select("mesB","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","")%>&nbsp;&nbsp;Cuentas:<%=fb.select("con_movimiento_bph","S=Con Movimiento,SS=Con Mov. Sin Saldo,CS=Con Mov. Con Saldo","",false,false,0,"Text10",null,null,"","T")%><br>
					Incluir cierre anual. Solo para DIC.?
					<%=fb.select("incluir_mes_13","Y=Si,N=No","N",false,false,0,"Text10",null,null,"","")%>
					<br>
					Excluir Comprobantes de Cierre. Solo para Mes CIERRE?
					<%=fb.select("excluirCierre","Y=Si,N=No","N",false,false,0,"Text10",null,null,"","")%>
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
					<td>
					<authtype type='51'>
					Balance de Situaci&oacute;n
					</authtype>
					<span style="float:right">
					 <a href="javascript:printRptBI(2)" class="Link01Bold">Excel</a>
					</span>
					</td>
					<td>
						A&ntilde;o: <%=fb.textBox("anioBS",anio,false,false,false,4,4)%>
						Mes: <%=fb.select("mesBS","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","S")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>
					<authtype type='52'>
					Estado de Resultado 
					<span style="float:right">
					 <a href="javascript:printRptBI(3)" class="Link01Bold">Excel</a>
					</span>
					</td>
					</authtype>
					<td>
						Excluir Comprobantes de Cierre. Solo para Mes CIERRE?
					<%=fb.select("excluirCierreR","Y=Si,N=No","Y",false,false,0,"Text10",null,null,"","")%>
					<br>
						A&ntilde;o: <%=fb.textBox("anioER",anio,false,false,false,4,4)%>
						Mes: <%=fb.select("mesER","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","S")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>
					<authtype type='53'>
					Hoja de Trabajo
					<span style="float:right">
					 <a href="javascript:printRptBI(4)" class="Link01Bold">Excel</a>
					</span>
					</td>
					</authtype>
					<td>
						A&ntilde;o: <%=fb.textBox("anioHT",anio,false,false,false,4,4)%>
						Mes: <%=fb.select("mesHT","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","S")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>
					<authtype type='54'>
					Estado de <%=fb.select("pCtaPrin","G=GANANCIA Y PERDIDAS, I=BALANCE DE SITUACION","",false,false,0,"Text10",null,null,"","")%>
					<span style="float:right">
					 <a href="javascript:printRptBI(5)" class="Link01Bold">Excel</a>
					</span>
					</td>
					</authtype>
					<td>
						A&ntilde;o: <%=fb.textBox("anioEGP",anio,false,false,false,4,4)%>
						Mes: <%=fb.select("mesEGP","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL",mes,false,false,0,"Text10",null,null,"","S")%>
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
</table>
</body>
</html>
<%
}//GET
%>
