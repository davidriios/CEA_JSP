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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
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
String cod_banco = "", cuenta_banco = "", nombre_cuenta = "", deposito ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String tipo = "";

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
<script language="javascript">
document.title = 'Reportes de Bancos- '+document.title;
function doAction()
{
}

function selCuentaBancaria(i){
	var cod_banco = eval('document.search01.cod_banco'+i).value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);
}


function clearCuentaBancaria()
{
  document.search01.cuenta_banco.value='';
  document.search01.nombre_cuenta.value='';
}

function showReporte(value)
{
  var banco  = eval('document.search01.cod_banco').value;
  var cuenta = eval('document.search01.cuenta_banco').value;
  var estado = eval('document.search01.estado').value;
  //var fechaini = eval('document.search01.fechaini').value;
  //var fechafin = eval('document.search01.fechafin').value;

  if(value=="1")
  {
 	var fechaini1 = eval('document.search01.fechaini1').value;
 	abrir_ventana2('../bancos/print_depositos_transito.jsp?banco='+banco+'&cuenta='+cuenta+'&estado='+estado+'&fechaini='+fechaini1);
  }
  else if(value=="2")
  {
 	var fechaini2 = eval('document.search01.fechaini2').value;
 	abrir_ventana2('../bancos/print_cheques_circulacion.jsp?banco='+banco+'&cuenta='+cuenta+'&fechaini='+fechaini2);
	
  }
  else if (value=="3")
  {
 	var fechaini3 = eval('document.search01.fechaini3').value;
 	var fechafin3 = eval('document.search01.fechafin3').value;
 	var deposito = eval('document.search01.deposito').value;
 	abrir_ventana2('../bancos/print_depositos_tipo_mov.jsp?banco='+banco+'&cuenta='+cuenta+'&estado='+estado+'&fechaini='+fechaini3+'&fechafin='+fechafin3+'&deposito='+deposito);
  }
    else if (value=="4")
  {
 	var fechaini4 = eval('document.search01.fechaini4').value;
 	var fechafin4 = eval('document.search01.fechafin4').value;
 	var tipo = eval('document.search01.tipo').value;
 	abrir_ventana2('../bancos/print_list_banco_notas_crdb.jsp?banco='+banco+'&cuenta='+cuenta+'&fechaini='+fechaini4+'&fechafin='+fechafin4+'&tipo='+tipo);
  }
  else if(value=="20")
  {
 	var fechaini2 = eval('document.search01.fechaini2').value; 
	
	var fhArray = fechaini2.split("/"); 
	var fHasta = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];
	//if(cuenta=='')cuenta='0';
	//if(banco=='')banco='0';
	 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=banco/rpt_cheques_circulacion.rptdesign&pBanco='+banco+'&pCuenta='+cuenta+'&fHasta='+fHasta+'&pCtrlHeader=false'); 
  }

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE CONCILIACIÓN BANCARIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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

			  <tr class="TextFilter">
				<td width="30%">Banco</td>
				<td width="70%">
				<%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" order by nombre","cod_banco",cod_banco,false,false,0, "", "", "onChange=\"javascript:clearCuentaBancaria()\"", "", "T")%>
				</td>
			  </tr>
			  <tr class="TextFilter">
				<td width="30%"> Cuenta Bancaria:</td>
				<td width="70%">
				<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,15,"",null,"")%>
				<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,40,"",null,"")%>
				<%=fb.button("buscarCuenta","...",false, false,"","","onClick=\"javascript:selCuentaBancaria('')\"")%>
				</td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">&nbsp;Reportes de Depósitos</td>
				</tr>

			<authtype type='50'>
				<tr class="TextRow01">
					<td width="30%"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depósitos en Tránsito</authtype></td>
					<td width="70%">Hasta el . . .&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechaini1" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;Estado:<%=fb.select("estado","DT=DEPOSITOS EN TRANSITO","",false,false,0,"",null,null,"","")%></td>
				</tr>

				<tr class="TextRow01">
					<td width="30%" rowspan="2"><%=fb.radio("reporte1","3",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depósitos por Tipo</authtype></td>
					<td width="70%">Tipo Depósito:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select t.codigo, t.descripcion from tbl_con_tipo_deposito t union select 99, 'EFECTIVO, ADELANTOS, REDEPOSITOS' from dual order by 1","deposito",deposito,false,false,0, "", "", "", "", "T")%></td>
				</tr>
				<tr class="TextRow01">
					<td width="70%">Del . . .&nbsp;&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechaini3" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hasta el . . .&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechafin3" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include>
					</td>
				</tr>
			</authtype>

			<authtype type='51'>
				<tr class="TextHeader">
				  <td colspan="2">&nbsp;Reportes de Cheques</td>
				</tr>

				<tr class="TextRow01">
					<td  width="30%"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cheques en Circulación
					<a href="javascript:showReporte(20)" class="Link00"> Excel </a>
					</td>
					<td>Hasta el . . .&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechaini2" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include>
					</td>
				</tr>
			</authtype>

			<authtype type='52'>
				<tr class="TextHeader">
				  <td colspan="2">&nbsp;Reportes de Notas D&eacute;bito y Cr&eacute;dito</td>
				</tr>

				<tr class="TextRow01">
					<td  width="30%" rowspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Notas</td>
					<td  width="70%" >Tipo:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select t.cod_transac, t.descripcion from tbl_con_tipo_movimiento t where cod_transac not in (1) order by 2","tipo",tipo,false,false,0, "", "", "", "", "")%></td>
				</tr>
				<tr class="TextRow01">
					<td width="70%">Del . . .&nbsp;&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechaini4" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hasta el . . .&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechafin4" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include>
					</td>
				</tr>
			</authtype>


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

