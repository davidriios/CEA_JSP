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

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String compania =  (String) session.getAttribute("_companyId");
int iconHeight = 20;
int iconWidth = 20;
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Planilla - Medio magnético para Pago de Planilla (ACH)_ '+document.title;
function doAction(){}
function addPla(){abrir_ventana1('../common/search_planilla.jsp?fp=pago_ach');}
function calculo(){var anio = eval('document.form0.anio').value;var cod = eval('document.form0.cod').value;var num = eval('document.form0.num').value;var totales = splitRowsCols(getDBData('<%=request.getContextPath()%>','sum(cantidad) as cantidad,nvl(to_char(sum(sal_neto), \'999,999,990.00\'),0)','(select count(*) as cantidad,nvl(sum(a.sal_neto),0) as sal_neto from tbl_pla_pago_empleado a, tbl_pla_empleado e, tbl_pla_planilla b where b.cod_planilla = a.cod_planilla and b.compania = a.cod_compania and e.emp_id = a.emp_id and e.forma_pago = 2 and e.num_cuenta is not null and e.ruta_bancaria is not null and a.cheque_pago is null and a.anio = '+anio+' and a.cod_planilla = '+cod+' and a.num_planilla = '+num+' and a.cod_compania = <%=(String) session.getAttribute("_companyId")%> union all select count(*) as cantidad,nvl(sum(a.sal_neto),0) as sal_neto from tbl_pla_pago_liquidacion a, tbl_pla_empleado e, tbl_pla_planilla b where b.cod_planilla = a.cod_planilla and b.compania = a.cod_compania and e.emp_id = a.emp_id and e.forma_pago = 2 and e.num_cuenta is not null and e.ruta_bancaria is not null and a.cheque_pago is null and a.anio = '+anio+' and a.cod_planilla = '+cod+' and a.num_planilla = '+num+' and a.cod_compania = <%=(String) session.getAttribute("_companyId")%>)','',''));document.form0.empleados.value = totales[0][0];document.form0.monto.value = totales[0][1];}
function showFile(obj){var msg='';var std='D';var anio=document.form0.anio.value;var codPlanilla=document.form0.cod.value;var noPlanilla=document.form0.num.value;var banco=document.form0.ruta.value;var nombreFile=document.form0.nombreFile.value;var nombre ='';if(noPlanilla =='')msg=' Número de Planilla';if(anio =='')msg=' , anio';if(codPlanilla =='')msg=' , código de planilla';if(banco =='')msg=' , banco ';if(msg==''){nombre = getSelectedOptionTitle(document.form0.ruta,'GRL');if(hasDBData('<%=request.getContextPath()%>','tbl_pla_planilla_encabezado',' cod_compania='+<%=compania%>+' and cod_planilla='+codPlanilla+' and num_planilla='+noPlanilla+' and estado =\''+std+'\' and anio='+anio,'')){alert('Ya esta Planilla está en Definitiva, Proceso Cancelado');}else{		if(confirm('Esta seguro de generar el archivo !')){showPopWin('../common/generate_file.jsp?fp=ACHEMP&docType=ACHEMP&anio='+anio+'&codPlanilla='+codPlanilla+'&noPlanilla='+noPlanilla+'&banco='+banco+'&nombreRuta='+nombreFile+'_'+nombre,winWidth*.75,winHeight*.65,null,null,'');}else alert('Proceso cancelado!!');}}else alert('Seleccione '+msg);}
function creaConta(){var msg='';var std='D';var anio=document.form0.anio.value;var codPlanilla=document.form0.cod.value;var noPlanilla=document.form0.num.value;var monto=document.form0.monto.value;var fecha=document.form0.fechaPago.value;if(noPlanilla =='')msg=+', Número de Planilla';if(anio =='')msg=+' , anio';if(codPlanilla =='')msg=+' , código de planilla';if(monto != '' && monto !='0'){if(msg==''){if(hasDBData('<%=request.getContextPath()%>','tbl_pla_planilla_encabezado',' cod_compania='+<%=compania%>+' and cod_planilla='+codPlanilla+' and num_planilla='+noPlanilla+' and estado =\''+std+'\' and anio='+anio,'')){alert('Ya esta Planilla está en Definitiva, Proceso Cancelado');}else{if(confirm('Este procesos pasa la información de Pago a Empleados por ACH a Contabilidad.  Seguro que desea ejecutarlo?')){showPopWin('../common/run_process.jsp?fp=ACHEMPAC&actType=51&docType=ACHEMPAC&docId='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&docNo='+anio+'&fecha='+fecha+'&numPlanilla='+noPlanilla+'&anio='+anio+'&codPlanilla='+codPlanilla,winWidth*.75,winHeight*.65,null,null,'');}else alert('Proceso Cancelado !');}}else alert('Seleccione '+msg.substring(1));}else alert(' Monto Invalido');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="MEDIO MAGNETICO PARA PAGO DE PLANILLA (ACH) "></jsp:param>
	</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<tr class="TextHeader">
				<td colspan="2"><cellbytelabel>Proceso Para Generar el Archivo de Pago a Empleados (ACH)</cellbytelabel> </td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2"><cellbytelabel>1. Seleccione la planilla que desea para generar el ACH archivo(TXT)</cellbytelabel> </td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2"><cellbytelabel>2. Registre la "fecha de pago" para el Banco y el Banco a pagar</cellbytelabel>. </td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2"><cellbytelabel>3. Presione el botón para generar el ACH archivo(TXT)</cellbytelabel>. </td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Planilla</cellbytelabel></td>
			<%=fb.hidden("nombreFile","")%>
			<td><cellbytelabel>A&ntilde;o</cellbytelabel> &nbsp;<%=fb.textBox("anio","",true,false,true,5)%>
			<cellbytelabel>C&oacute;d. Planilla</cellbytelabel> &nbsp;<%=fb.textBox("cod","",true,false,true,5)%>
			<cellbytelabel>N&uacute;m. Planilla</cellbytelabel> &nbsp;<%=fb.textBox("num","",true,false,true,5,null,null,"onBlur=\"javascript:calculo()\"")%>
			<%=fb.button("btnper","...",true,false,null,null,"onClick=\"javascript:addPla()\"")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td width="40%"><cellbytelabel>Fecha Efectiva de Pago</cellbytelabel></td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaPago"/>
				<jsp:param name="valueOfTBox1" value=" " />
				<jsp:param name="jsEvent" value="" />
				</jsp:include>
				</td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Banco</cellbytelabel></td>
				<td><%=fb.select(ConMgr.getConnection(),"select ruta, nombre_banco as nombre,nombre_ach from tbl_adm_ruta_transito order by 2","ruta","",false,false,0,"Text10",null,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="center">&nbsp;<label id="lblAchId" class="RedTextBold"></label></td>
				<td align="center">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
			<td align="center">
			<authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/ach.jpg" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('lblAchId','Generar Archivo')" onMouseOut="javascript:displayElementValue('lblAchId','')" onClick="javascript:showFile()"></authtype>
			<!--<authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/actualizar.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('lblAchId','Actualizar Contabilidad')" onMouseOut="javascript:displayElementValue('lblAchId','')"onClick="javascript:creaConta()"></authtype> -->
			<td>&nbsp;&nbsp;<cellbytelabel>Cantidad de TRX del ACH</cellbytelabel> :&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=fb.textBox("empleados","",false,false,true,5)%>  <br>&nbsp;&nbsp;<cellbytelabel>Monto Total a Pagar en ACH</cellbytelabel> :&nbsp;&nbsp; <%=fb.textBox("monto","",false,false,true,10,10)%></td>
			</tr>
	<%=fb.formEnd(true)%>
	<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
