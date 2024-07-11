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
	FORMA              REPORTE              FLAG                DESCRIPCION
	SB5000.FMB      -------              --             PROCESO PARA CONCILIACION (SALDO BANCARIO)
						CB1240							CONCILIACION BANCARIA
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String almacen = "";
String compania =  (String) session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();
String ct_concil_rep = "N";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Bancos - Conciliación _ '+document.title;
function doAction()
{
}
function getBanco()
{
abrir_ventana1('../common/search_cuentabanco.jsp?fp=cierre');
}
function proceso(obj)
{
	var banco=document.form0.banco.value;
	var cuenta=document.form0.cuenta.value;
	var mes = document.form0.mes.value;
	var anio = document.form0.anio.value;
	var nombre=document.form0.nombre.value;
	var saldo_banco=document.form0.saldo_banco.value||"0";
	var estadoMes = document.form0.estadoMes.value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	var user = '<%=(String) session.getAttribute("_userName")%>';
	var cont = 0;
	var dep = 0;
	var msg = '';
	var err = '';
	
		if(banco.trim()==''||cuenta.trim()==''||anio.trim()==''||mes.trim()=='')  alert('Seleccione los Parámetros ... Verifique');
		else {
			if(obj=='CB'){
				if(hasDBData('<%=request.getContextPath()%>','tbl_con_resumen_concil','cb_compania='+compania+' and cb_cod_banco=\''+banco+'\' and cb_cuenta_banco=\''+cuenta+'\' and anio='+anio+' and mes_conciliado='+mes+'','')){
					cont++;
					document.form0.revertir.disabled = false;
					alert('**Existe un Resumen de Conciliación previo para este Rango de Fecha.....REVIERTA EL PROCESO....VERIFIQUE **!');
				} else if(hasDBData('<%=request.getContextPath()%>','tbl_con_detalle_cuenta','compania=<%=(String) session.getAttribute("_companyId")%> and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and fecha_mes = '+mes+' and cpto_anio = '+anio+'','')){
					cont++;
					if(document.form0.revertir)document.form0.revertir.disabled = true;
					alert('**** La Conciliación fué Realizada para este Rango de Fecha......VERIFIQUE REPORTE ****!');
					//document.form0.fecha_desde.value='';
					//document.form0.fecha_hasta.value='';
				} else if(executeDB('<%=request.getContextPath()%>','call sp_con_concil(\''+banco+'\',\''+cuenta+'\','+compania+','+mes+','+anio+','+saldo_banco+')','')){
					//if(executeDB('<%=request.getContextPath()%>','call sp_con_reporte_temporal(\''+banco+'\',\''+cuenta+'\','+compania+','+anio+','+mes+')','')){
						
						if(hasDBData('<%=request.getContextPath()%>','tbl_con_temp_detalle_conci','compania='+compania+' and cod_banco=\''+banco+'\' and cuenta=\''+cuenta+'\' and anio='+anio+' and mes='+mes+'','')){alert('*** P R O C E S O  F I N A L I Z A D O ***!    ');						
						}else alert('*** P R O C E S O  F I N A L I Z A D O -  SIN REGISTROS.!');
						if(document.form0.revertir)document.form0.revertir.disabled = false;
						if(document.form0.cierre)document.form0.cierre.disabled = false;						
						
				}  else alert('*** 	ERROR AL GENERAR PROCESO  - SP_CON_CONCIL.!');
			} else if(obj=='IF'){// end obj= CB
				if(hasDBData('<%=request.getContextPath()%>','tbl_con_resumen_concil','cb_compania='+compania+' and cb_cod_banco=\''+banco+'\' and cb_cuenta_banco=\''+cuenta+'\' and anio='+anio+' and mes_conciliado='+mes+'','')){
					abrir_ventana('../bancos/print_resumen_conciliacion.jsp?fp='+obj+'&cuenta='+cuenta+'&anio='+anio+'&mes='+mes+'&banco='+banco+'&nombre='+nombre);
					document.form0.revertir.disabled = false;
				} else alert('*** PROCESO NO ENCONTRO REGISTROS ***!   ');
			}   else if(obj=='RC'){ // end obj= IF

				if(hasDBData('<%=request.getContextPath()%>','tbl_con_detalle_cuenta','compania='+compania+' and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and cpto_anio='+anio+' and fecha_mes='+mes+'','') && estadoMes=='CER'){
					alert('** La Conciliación fué Cerrada para este Rango de Fecha......VERIFIQUE **!');
					document.form0.revertir.disabled = true;
				} else {
					if(executeDB('<%=request.getContextPath()%>','delete from tbl_con_detalle_cuenta where compania=<%=compania%> and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and cpto_anio='+anio+' and fecha_mes='+mes+'','')){
					if(executeDB('<%=request.getContextPath()%>','delete from tbl_con_resumen_concil where cb_compania=<%=compania%> and cb_cod_banco=\''+banco+'\' and cb_cuenta_banco=\''+cuenta+'\' and anio='+anio+' and mes_conciliado='+mes+'','tbl_con_resumen_concil')){
						if(executeDB('<%=request.getContextPath()%>','delete from tbl_con_temp_detalle_conci where compania=<%=compania%> and cod_banco=\''+banco+'\' and cuenta=\''+cuenta+'\' and mes='+mes+' and anio='+anio+'','tbl_con_temp_detalle_conci')){
							alert('Reversión Terminada.....CONTINUE!');
							if(document.form0.revertir)document.form0.revertir.disabled = true;
							if(document.form0.cierre)document.form0.cierre.disabled = true;
						} else alert('No se pudo borrar el Temp Detalle..  Consulte con su Administrador.....');
					} else alert('No se pudo borrar el Resumen Concil..  Consulte con su Administrador.....');
					} else alert('No se pudo borrar el Detalle Cuenta..  Consulte con su Administrador.....');
				}  // end else
			} // obj = IF                   // end obj = RC
		} // msg
}

function paraCierre(obj)
{
	var banco=document.form0.banco.value;
	var cuenta=document.form0.cuenta.value;
	var mes = document.form0.mes.value;
	var anio = document.form0.anio.value;
	var nombre=document.form0.nombre.value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	var user = '<%=(String) session.getAttribute("_userName")%>';
	var cont = 0;
	var dep = 0;
	var msg = '';
	if(banco == '')  alert('Seleccione los Parámetros ... Verifique');
	else {

		if(confirm("A T E N C I O N:\n Usted ejecutará el proceso de CIERRE MENSUAL, una vez inicie el proceso, NO PODRA CANCELARSE!!!.\n Antes de ejecutarlo verifique que los datos a procesar son los correctos!... \n Si los datos son correcto presione ACEPTAR de otro modo presione CANCELAR."))
		{

				if(obj=='CM')	{
					if(hasDBData('<%=request.getContextPath()%>','tbl_con_resumen_concil','cb_compania='+compania+' and cb_cod_banco=\''+banco+'\' and cb_cuenta_banco=\''+cuenta+'\' and anio='+anio+' and mes_conciliado='+mes+'','')){
						if(executeDB('<%=request.getContextPath()%>','call sp_con_cierre(\''+banco+'\',\''+cuenta+'\','+compania+','+mes+','+anio+')','')){
							if(executeDB('<%=request.getContextPath()%>','call sp_con_actualizar(\''+banco+'\',\''+cuenta+'\','+compania+','+mes+','+anio+')','')){
								alert('*** P R O C E S O  F I N A L I Z A D O ***!    ');
								if(document.form0.revertir)document.form0.revertir.disabled = true;
								if(document.form0.cierre)document.form0.cierre.disabled = true;
								if(document.form0.report1)document.form0.report1.disabled = true;
							} else alert('*** PROCESO NO ENCONTRO REGISTROS SP_CON_ACTUALIZA***!   ');
						} else alert('*** PROCESO NO ENCONTRO REGISTROS SP_CON_CIERRE***!   ');
					} else  alert('*** PROCESO NO ENCONTRO REGISTROS PARA HACER CIERRE***!   ');
				} // obj = IF

		} else // confirm
		{
			alert('Proceso de CIERRE  C A N C E L A D O por el USUARIO!');
		}

	} // msg
}
function checkEstado()
{ 
 var mes = document.form0.mes.value;
 var anio = document.form0.anio.value;
 var compania = '<%=(String) session.getAttribute("_companyId")%>';
 var banco=document.form0.banco.value;
 var cuenta=document.form0.cuenta.value;
 if(mes!=''&&anio!=''&&banco!=''&&cuenta!='')
 {
	if(hasDBData('<%=request.getContextPath()%>','tbl_con_detalle_cuenta','compania='+compania+' and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and cpto_anio='+anio+' and fecha_mes='+mes+'',''))
	{
	  if(hasDBData('<%=request.getContextPath()%>','tbl_con_estado_meses','cod_cia='+compania+' and ano='+anio+' and mes=\''+mes+'\' and nvl(estatus,\'INA\') !=\'CER\'',''))
	  {
		document.form0.revertir.disabled = false;
	  }else document.form0.revertir.disabled = true;
	}else document.form0.revertir.disabled = true;
 }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="BANCOS - CONCILIACION BANCARIA"></jsp:param>
</jsp:include>
<table align="center" width="85%" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("ct_concil_rep","")%>
				<%=fb.hidden("estadoMes","")%>				
				<tr class="TextHeader">
					<td colspan="3">Proceso: Conciliación Bancaria </td>
				</tr>
				<tr class="TextRow01">
					<td width="20%">Banco</td>
					<td colspan="2">
					<%=fb.intBox("banco","",false,false,false,5,5)%>
					<%=fb.textBox("nombre","",false,false,false,75)%>
					<%=fb.button("cta","..Ir..",true,false,null,null,"onClick=\"javascript:getBanco()\"","Seleccionar Cuenta Bancaria")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>Cuenta de Banco</td>
					<td colspan="2">
						<%=fb.textBox("cuenta","",false,false,false,40,"Text10",null,"")%>
						&nbsp;
						Saldo seg&uacute;n banco:
						<%=fb.textBox("saldo_banco","",false,false,false,15,"Text10",null,"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td width="20%">Ultimo mes CERRADO:</td>
					<td colspan="2">
					<%=fb.textBox("ultMesProc","",false,false,true,50)%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td width="20%">A&ntilde;o&nbsp;&frasl;&nbsp;Mes:</td>
					<td colspan="2">
					<%=fb.textBox("anio","",false,false,false,5,"","","onChange=\"javascript:checkEstado();\"")%>
					<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE","",false,false,0,"","","onChange=\"javascript:checkEstado();\"")%> 
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td width="20%" align="center">
						<authtype type='50'><%=fb.button("report1","Conciliación",true,false,null,null,"onClick=\"javascript:proceso('CB');\"")%> </authtype>
					</td>
					<td width="40%" align="center">
						<authtype type='51'><%=fb.button("informe","Informe Final",true,false,null,null,"onClick=\"javascript:proceso('IF');\"")%> </authtype>
					</td>
					<td width="60%" align="right">
						<authtype type='52'><%=fb.button("cierre","Cierre Mensual",true,true,null,null,"onClick=\"javascript:paraCierre('CM');\"")%> </authtype>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3" align="center"><authtype type='53'><%=fb.button("revertir","Revertir Proceso de Conciliación",true,true,null,null,"onClick=\"javascript:proceso('RC');\"")%> </authtype></td>
				</tr>

				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
