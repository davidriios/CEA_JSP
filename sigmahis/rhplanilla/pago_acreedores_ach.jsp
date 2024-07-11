
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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FPMgr" scope="page" class="issi.rhplanilla.FilePlanillaMgr" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
FPMgr.setConnection(ConMgr);

String almacen = "";
String compania =  (String) session.getAttribute("_companyId");	
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();
int iconHeight = 20;
int iconWidth = 20;
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fecha = request.getParameter("fechaPago");
String cod_acreedor = request.getParameter("cod_acreedor");
String acredorName = request.getParameter("acredorName");

if (anio == null) anio = "";
if (mes == null) mes = "";
if (fecha == null) fecha = "";
if (acredorName == null) acredorName = "";
if (cod_acreedor == null) cod_acreedor = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Planilla - Medio magnético para Pago de Planilla de Acreedores(ACH)_ '+document.title;
function doAction()
{
	fecha();
}

function fecha()
{  
  var anio;
  var mes; 
  var tot = "0.00";
  var dayOfMonth = 0;
  var x = 1;
  var y = 1;
  anio = document.form1.anio.value; 
  mes = document.form1.mes.value;
    
  if (anio!=null && anio!="")
  { 
    dayOfMonth = getDBData('<%=request.getContextPath()%>',"to_char(last_day(to_date('01/"+mes+"/"+anio+"','dd/mm/yyyy')),'dd/mm/yyyy')",'dual','','');
    document.form1.fechaPago.value = dayOfMonth;
	document.form1.fechaEfectiva.value = dayOfMonth;
  } 
  
  if (anio!=null && anio!='' && mes!=null && mes!='')
{
 document.form1.regular.value = ""+tot;
 document.form1.vacacion.value = ""+tot;
 document.form1.anterior.value = ""+tot;
 document.form1.total.value = ""+tot;
var totales = splitRowsCols(getDBData('<%=request.getContextPath()%>','nvl((select sum(nvl(da.monto,0)) from tbl_pla_acreedor a, tbl_pla_descuento_aplicado da, tbl_pla_descuento d, tbl_pla_planilla_encabezado p where p.anio = '+anio+' and to_number(to_char(p.fecha_final,\'mm\'),\'99\') = '+mes+' and p.estado = \'D\' and p.cod_planilla not in (3,4) and a.forma_pago = 2 and (a.cuenta_bancaria is not null or (a.cuenta_bancaria is null and a.tipo_cuenta = \'P\')) and a.ruta is not null and da.num_cheque is null and  nvl(da.procesado_acr,\'N\') =\'N\' and (d.emp_id = da.emp_id and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento) and  (a.cod_acreedor = da.cod_acreedor and a.compania = da.cod_compania) and (da.cod_compania = p.cod_compania and da.anio = p.anio and da.cod_planilla = p.cod_planilla and da.num_planilla = p.num_planilla and da.cod_compania=p.cod_compania) and p.cod_compania = <%=(String) session.getAttribute("_companyId")%>),0)regular,nvl((select sum(nvl(v.monto,0)) from tbl_pla_dist_desctos_vac v, tbl_pla_descuento_aplicado da, tbl_pla_descuento d, tbl_pla_planilla_encabezado p, tbl_pla_empleado e, tbl_pla_acreedor a where p.anio = '+anio+' and to_number(to_char(p.fecha_final,\'mm\'),\'99\') = '+mes+' and v.anio_ac = '+anio+' and to_number(to_char(v.periodo_ac/2,\'99\'),\'99\') = '+mes+' and p.estado = \'D\' and p.cod_planilla = 3 and a.forma_pago = 2 and (a.cuenta_bancaria is not null or (a.cuenta_bancaria is null and a.tipo_cuenta = \'P\')) and a.ruta is not null and da.num_cheque is null and  nvl(da.procesado_acr,\'N\') =\'N\' and (a.cod_acreedor = v.cod_acreedor and a.compania = v.cod_compania) and (da.cod_compania = p.cod_compania and da.anio = p.anio and da.num_planilla = p.num_planilla and da.cod_planilla=p.cod_planilla)  and (e.emp_id = da.emp_id and e.compania = da.cod_compania) and (d.emp_id = da.emp_id and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento) and (v.cod_compania = da.cod_compania and v.anio = da.anio and v.cod_planilla = da.cod_planilla and v.num_planilla = da.num_planilla and v.cod_grupo = da.cod_grupo and v.cod_acreedor = da.cod_acreedor and v.num_descuento = da.num_descuento and v.emp_id = da.emp_id) and p.cod_compania = <%=(String) session.getAttribute("_companyId")%>),0)vacaciones,nvl((select sum(nvl(v.monto,0)) from tbl_pla_dist_desctos_vac v, tbl_pla_descuento_aplicado da, tbl_pla_descuento d, tbl_pla_planilla_encabezado p, tbl_pla_empleado e, tbl_pla_acreedor a where to_char(p.anio,\'fm0009\')||to_char(to_number(to_char(p.fecha_final,\'mm\'),\'99\'),\'fm09\') < '+anio+mes+' and to_char(p.anio,\'fm0009\')||to_char(to_number(to_char(p.fecha_final,\'mm\'),\'99\'),\'fm09\') >=   201202 and to_number(to_char(v.anio_ac,\'fm0009\')||to_char(round(v.periodo_ac/2,0),\'fm09\')) = '+anio+mes+' and p.estado = \'D\' and p.cod_planilla = 3 and a.forma_pago = 2 and (a.cuenta_bancaria is not null or (a.cuenta_bancaria is null and a.tipo_cuenta = \'P\')) and a.ruta is not null and da.num_cheque is null and  nvl(da.procesado_acr,\'N\') =\'N\' and (a.cod_acreedor = v.cod_acreedor and a.compania = v.cod_compania) and (da.cod_compania = p.cod_compania and da.anio = p.anio and da.num_planilla = p.num_planilla and da.cod_planilla=p.cod_planilla)  and (e.emp_id = da.emp_id and e.compania = da.cod_compania) and (d.emp_id = da.emp_id and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento) and (v.cod_compania = da.cod_compania and v.anio = da.anio and v.cod_planilla = da.cod_planilla and v.num_planilla = da.num_planilla and v.cod_grupo = da.cod_grupo and v.cod_acreedor = da.cod_acreedor and v.num_descuento = da.num_descuento and v.emp_id = da.emp_id) and p.cod_compania = <%=(String) session.getAttribute("_companyId")%>),0) anterior','dual',''));
document.form1.regular.value = totales[0][0];
document.form1.vacacion.value = totales[0][1];
document.form1.anterior.value = totales[0][2];
var total = parseFloat(parseFloat(totales[0][0]) + parseFloat(totales[0][1])+ parseFloat(totales[0][2]));
eval('document.form1.total').value = (total).toFixed(2);
}
}
function showReporte()
{
	var anio=document.form1.anio.value;
	var mes=document.form1.mes.value;
	var acr = document.form1.cod_acreedor.value;
	if(anio != null && anio !='')
	abrir_ventana('../rhplanilla/print_resumen_ach_acr.jsp?mes='+mes+'&anio='+anio+'&acreedor='+acr);
	else alert('Introduzca Valor en Campo Año!');
}

function creaArchivo(fName,value)
{
	setBAction(fName,value);
	var anio=document.form1.anio.value;
	if(anio != null && anio !='')document.form1.submit();
	else alert('Introduzca Valor en Campo Año!');
}
function showFile(){

var anio=document.form1.anio.value;
var mes=document.form1.mes.value;
var fechaPago=document.form1.fechaPago.value;


if(anio.trim()==''){alert('Introduzca Año!');return false;}
if(mes.trim()==''){alert('Seleccione Mes!');return false;}
if(fechaPago.trim()==''){alert('Seleccione Fecha!');return false;}
showPopWin('../common/generate_file.jsp?fp=ACHACR&docType=ACHACR&fechaPago='+fechaPago+'&mes='+mes+'&anio='+anio,winWidth*.75,winHeight*.65,null,null,'');}

function paseCont()
{
var anio=document.form1.anio.value;
var mes=document.form1.mes.value;
var total=document.form1.total.value;
var fecha=document.form1.fechaPago.value; 
if(total ==''||isNaN(total))total =0;

	if (anio!=null && anio!='' && mes!=null && mes!='' && fecha!=null && fecha !='' && (parseFloat(total) > 0))
	{
		if(confirm('Este procesos pasa la información de pago a Acreedores a Contabilidad.  Seguro que desea ejecutarlo?'))
		{
			showPopWin('../common/run_process.jsp?fp=ACRACH&actType=53&docType=ACRACH&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&fecha='+fecha,winWidth*.75,winHeight*.65,null,null,'');

		
		}else alert('Proceso Cancelado por el usuario. Contabilida NO actualizada');
	}else if(parseFloat(total)==0){alert('El monto a actualizar es igual  a cero.!!! ');}
	else alert('Introduzca parametros para Generar Proceso (año,mes,fecha)');
     

}

function printTrx()
{
	var msg='';
	var std='D';  
	var anio;
	var mes; 
	var proveedor; 
	var tot = "0.00";
	var dayOfMonth = 0;
	var x = 1;
	var y = 1;
	anio = document.form1.anio.value; 
	mes = document.form1.mes.value;
	proveedor = document.form1.cod_acreedor.value;
	var formaPago = document.form1.formaPago.value;
   
	if(mes =='')msg=' Mes';
	if(anio =='')msg=' , anio';
	if(msg=='')
	{
	abrir_ventana1('../rhplanilla/print_list_descuento_resumen.jsp?mes='+mes+'&anio='+anio+'&p_proveedor='+proveedor+'&formaPago='+formaPago);
	
	}else alert('Seleccione '+msg);	 
}
function Acreedor(){abrir_ventana1('../common/search_acreedor.jsp?fp=acreedoresAch');}
function clearACr(){document.form1.cod_acreedor.value='';document.form1.acredorName.value='';}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="MEDIO MAGNETICO PARA PAGO DE PLANILLA ACREEDORES(ACH) "></jsp:param>
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
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("fechaEfectiva",""+fecha)%>
			<%=fb.hidden("baction","")%>
			
			<tr class="TextHeader">
				<td colspan="2">Medio Magnético para Pago a Acreedores por ACH </td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">Proceso </td>
			</tr>
				
			<tr class="TextRow02">
				<td width="50%">&nbsp;	
					<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow02">
							<td width="30%">Año</td>
							<td width="20%"><%=fb.intBox("anio",anio,false,false,false,5,4,null,null,"onChange=\"javascript:fecha()\"")%></td>
							<td width="20%">Mes</td>
							<td width="30%"><%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,null,null,"onChange=\"javascript:fecha()\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td>Fecha Efectiva de Pago</td>
							<td colspan="3"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fechaPago"/>
								<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow02">
							<td>Acreedor</td>
							<td colspan="3" o><%=fb.intBox("cod_acreedor",cod_acreedor,true,false,true,5,4,null,"","onDblClick=\"javascripts:clearACr()\"")%> 
						  		  <%=fb.textBox("acredorName",acredorName,false,false,true,28)%> 
								  <%=fb.button("btnAcreedor","...",true,false,null,null,"onClick=\"javascript:Acreedor();\"")%> </td>
						</tr>
						<tr class="TextRow02">
							<td colspan="2">Planillas Regulares Mes Actual:</td>
							<td colspan="2"><%=fb.decBox("regular","",false,false,true,10,8.2,"Text12",null,null)%></td>
						</tr>
						<tr class="TextRow02">
							<td colspan="2">Planillas Vacaciones Mes Actual;</td>
							<td colspan="2"><%=fb.decBox("vacacion","",false,false,true,10,8.2,"Text12",null,null)%></td>
						</tr>
						<tr class="TextRow02">
							<td colspan="2">Planillas Vacaciones Meses Anteriores:</td>
							<td colspan="2"><%=fb.decBox("anterior","",false,false,true,10,8.2,"Text12",null,null)%></td>
						</tr>
						<tr class="TextRow02">
							<td colspan="2">Monto Total a Pagar ACH  :</td>
							<td colspan="2"><%=fb.decBox("total","0",false,false,true,10,8.2,"Text12",null,null)%></td>
						</tr>
						
					</table>
				 </td>
				<td width="50%">
					<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow02">
							<td width="40%">Disco Ach</td>
							<td width="60%"><authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/ach.jpg" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Generar File')" onClick="javascript:showFile('<%=fb.getFormName()%>','Generar')"></authtype>
							<%//=fb.button("btnper","ACH",true,false,null,null,"onClick=\"javascript:addPla()\"")%></td>
						</tr>
						<tr class="TextRow02">
							<td>Resumen ACH</td>
							<td><authtype type='52'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:showReporte()"></authtype></td>
						</tr>
						<tr class="TextRow02">
							<td>Actualizar Contab.</td>
							<td><authtype type='53'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/actualizar.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:paseCont()"></authtype></td>
						</tr>
						<tr class="TextRow02">
							<td>Trx.Generadas &nbsp;&nbsp;<%=fb.select("formaPago","1=CHEQUE,2=ACH","2",false,false,0,null,null,"")%></td>
							<td><authtype type='54'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/proceso.bmp" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:printTrx()"></authtype></td>
						</tr>
					</table>
				 </td>
			</tr>
			
			
	
	<%=fb.formEnd(true)%>
	<!-- ========================   F O R M   E N D   H E R E   ========================= -->
	</table>
		
</td></tr>
		

</table>
</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");

			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("mes",request.getParameter("mes"));
			cdo.addColValue("anio",request.getParameter("anio"));
			cdo.addColValue("fecha_efectiva",request.getParameter("fechaPago"));
			cdo.addColValue("fg","ACHACR");
			cdo.addColValue("name","ACHACR");
			
			
		
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	//if (baction.equalsIgnoreCase("Generar")) FPMgr.createFile(cdo);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){<%if (FPMgr.getErrCode().equals("1")) { %>alert('<%=FPMgr.getErrMsg()%>');window.location= '<%=request.getContextPath()+request.getServletPath()%>?anio=<%=anio%>&mes=<%=mes%>&fecha=<%=fecha%>&acredorName=<%=acredorName%>&cod_acreedor=<%=cod_acreedor%>';
<% } else throw new Exception(FPMgr.getErrException());%>}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>