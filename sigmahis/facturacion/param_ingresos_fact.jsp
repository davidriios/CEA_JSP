<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

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

String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg = request.getParameter("fg");

if (mode == null) mode = "add";
if (fg == null) fg = "RE";

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
document.title = 'Consumo por Centro de Servicio - '+document.title;
function doAction()
{
}

function showReporte(value,xls)
{
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;
  <%if(fg.trim().equals("RE")){%>
  	var categoria    = eval('document.form0.categoria2').value;
	var factA     = eval('document.form0.factA').value;
	var pacId     = eval('document.form0.pacId').value;
	var aseguradora     = eval('document.form0.aseguradora').value;
	var admType     = eval('document.form0.categoria').value;
	var status     = eval('document.form0.status').value;
	var jubilado        = '';
	var rep_type = '',anuladasPosterior='';
	var cds     = eval('document.form0.cds').value;
	if(eval('document.form0.jubilados').checked)jubilado='S';

if(fechaini != '' && fechafin !='' )
{
	if(value=='1')
	{
		rep_type = '';
		if(document.form0.rep_type2) rep_type =document.form0.rep_type2.value;
		if(document.form0.anuladasPosterior) anuladasPosterior =document.form0.anuladasPosterior.value;
		
 	abrir_ventana('../facturacion/print_ingresos_facturas.jsp?categoria='+categoria+'&fechaIni='+fechaini+'&fechaFin='+fechafin+"&pacId="+pacId+"&aseguradora="+aseguradora+"&facturar_a="+factA+"&admType="+admType+'&status='+status+'&jubilado='+jubilado+'&rep_type='+rep_type+'&anuladasPosterior='+anuladasPosterior);
	}
	else if(value=='2')
	{
		if(xls==undefined)abrir_ventana('../facturacion/print_descuentos_x_cds.jsp?fechaIni='+fechaini+'&fechaFin='+fechafin+'&pacId='+pacId+'&aseguradora='+aseguradora+'&facturar_a='+factA+'&status='+status+'&jubilado='+jubilado+'&cds='+cds);
		else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/descuentos_x_centros.rptdesign&fDate='+fechaini+'&tDate='+fechafin+'&pacId='+pacId+'&aseguradora='+aseguradora+'&facturarA='+factA+'&status='+status+'&jubilado='+jubilado+'&cds='+cds+'&pCtrlHeader=true');
	}
	else if(value=='3')
	{
 		var doc_type = '';
		rep_type = '';
		if(document.form0.doc_type) doc_type =document.form0.doc_type.value;
		if(document.form0.rep_type) rep_type =document.form0.rep_type.value;
		abrir_ventana('../facturacion/print_ingresos_facturas_otros.jsp?fechaIni='+fechaini+'&fechaFin='+fechafin+'&status='+status+'&doc_type='+doc_type+'&rep_type='+rep_type);
	}
	}
else CBMSG.warning('Seleccione rango de Fecha');


	<%}else {%>
		if(fechaini != '' && fechafin !='' )
		{
			if(value=='4')
			{
				abrir_ventana('../facturacion/print_ingresos_otros_x_cta.jsp?fechaIni='+fechaini+'&fechaFin='+fechafin);
			}
		}else CBMSG.warning('Seleccione rango de Fecha');

	<%}%>
}
function showEmpresaList()
{
	abrir_ventana1('../common/search_empresa.jsp?fp=facturacion');
}
function showPacienteList()
{
	abrir_ventana1('../common/search_paciente.jsp?fp=facturacion');
}
function showPaciente()
{
	abrir_ventana1('../common/sel_paciente.jsp?fp=SALDO');
}
function generarFactura()
{
var msg='';
var facturar_a=document.form0.factA.value;
var pacId=document.form0.pacId.value;
var noAdmision=document.form0.noAdmision.value;
var nombre=document.form0.nombre.value;
var noFactura='0';//document.form0.noFactura.value;
//if(noFactura=='') msg +=',FACTURA'
if(pacId=='') msg +=',PACIENTE'

if(msg !='')CBMSG.warning('Favor completar la siguiente informacion:  '+msg.substring(1));
else{
		if(confirm('Está seguro de Generar Factura con saldo = 0 Para la Admisión: '+noAdmision+' Del Paciente: '+nombre))
		{
				showPopWin('../common/run_process.jsp?fp=SALDO0&actType=50&docType=SALDO0&docId='+noAdmision+'&docNo='+noAdmision+'&compania=<%=(String) session.getAttribute("_companyId")%>&pacId='+pacId+'&noAdmision='+noAdmision+'&facturarA='+facturar_a+'&factura='+noFactura,winWidth*.75,winHeight*.65,null,null,'');
	
		}else alert('Proceso Cancelado por el usuario.');
	}
}
function checkFactura(obj)
{
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_fac_factura','codigo=(select   substr(to_number (to_char (sysdate, \'yyyy\')), 3, 2) from dual)||-\''+obj.value+'\' and compania='+compania+'','');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR CENTRO"></jsp:param>
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
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
			  <%if(fg.trim().equals("RE")){%>
			  <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Tipo de Categor&iacute;a</cellbytelabel></td>
				   <td width="85%">
           <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
           </td>
			  </tr>
         <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
				   <td width="85%">
           <%=fb.select(ConMgr.getConnection(),"select distinct  codigo,descripcion||' - '||codigo from tbl_adm_categoria_admision order by 1","categoria2","","T")%>
           </td>
			  </tr>

				<tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
				   <td width="50%">
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="2" />
        	<jsp:param name="clearOption" value="true" />
        	<jsp:param name="nameOfTBox1" value="fechaini" />
        	<jsp:param name="valueOfTBox1" value="" />
          <jsp:param name="nameOfTBox2" value="fechafin" />
        	<jsp:param name="valueOfTBox2" value="" />
			</jsp:include>
		           </td>
			  </tr>
        <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Facturar A</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.select("factA","P=PACIENTE,E=EMPRESA,PE=PACIENTE Y EMPRESA,O=OTROS","PE",false,false,0,"Text10",null,null,null,"T")%>
           </td>
			  </tr>
	    <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Estatus</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.select("status","P=PENDIENTE,C=CANCELADA,A=ANULADA,N=NO ANULADAS","N",false,false,0,"Text10",null,null,null,"T")%>
           </td>
		</tr>
        <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Paciente</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.intBox("pacId","",false,false,false,5,"Text10",null,null)%>
									<%=fb.textBox("nombre","",false,false,true,35,"Text10",null,null)%>
                  <%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
           </td>
		</tr>
        <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Aseguradora</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.intBox("aseguradora","",false,false,false,5,"Text10",null,null)%>
									<%=fb.textBox("aseguradoraDesc","",false,false,true,35,"Text10",null,null)%>
                  <%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
           </td>
		</tr>
		 <tr class="TextFilter" >
			   <td><cellbytelabel>Descuentos A Jubilados</cellbytelabel></td>
			   <td><%=fb.checkbox("jubilados","N",false,false,"","","")%></td>
		 </tr>
		 <tr class="TextFilter">
				<td><cellbytelabel>Centro de Servicio(Solo para descuentos x Centros)</cellbytelabel></td>
				<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by descripcion","cds","","T")%>

				</td>
		</tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Ingresos Por Factura y Descuentos</cellbytelabel>&nbsp;&nbsp;&nbsp; Tipo	<%=fb.select("rep_type2","R=RESUMIDO,D=DETALLADO","",false,false,0,"Text10",null,null,null,"T")%>	
					&nbsp;&nbsp;&nbsp; FACT. ANULADAS DESPUES DE FECHA FINAL	<%=fb.select("anuladasPosterior","S=SI,N=NO","",false,false,0,"Text10",null,null,null,"T")%>	</td>
				</tr>
				</authtype>
				<authtype type='51'>
				<tr class="TextRow02">
							<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Descuentos A Facturas(por Centros)</cellbytelabel>&nbsp;&nbsp;&nbsp; <a href="javascript:showReporte(2,'xls')" class="Link00"> Excel </a></td>
				</tr>
				</authtype>
				<uthtype type='52'>
				<tr class="TextRow01">
							<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Ingresos Por Factura y Descuentos(Otros)
					&nbsp;&nbsp;&nbsp; Tipo Doc.	<%=fb.select("doc_type","FAC=FACTURA,NCR=NOTA CREDITO,NDB=NOTA DEBITO","T",false,false,0,"Text10",null,null,null,"T")%>	
						&nbsp;&nbsp;&nbsp; Tipo	<%=fb.select("rep_type","R=RESUMIDO,D=DETALLADO","T",false,false,0,"Text10",null,null,null,"T")%>	
						
							</td>
				</tr>
				</authtype><!---->
				<%}else if(!fg.trim().equals("SALDO")){%>

				<tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
				   <td width="50%">
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="2" />
        	<jsp:param name="clearOption" value="true" />
			<jsp:param name="format" value="dd/mm/yyyy"/>
        	<jsp:param name="nameOfTBox1" value="fechaini" />
			<jsp:param name="valueOfTBox1" value="" />
          	<jsp:param name="nameOfTBox2" value="fechafin" />
        	<jsp:param name="valueOfTBox2" value="" />
			</jsp:include>
		           </td>
			  </tr>
			  <authtype type='53'>
				<tr class="TextRow01">
							<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Ingresos Por Factura y Descuentos(Otros Clientes)</cellbytelabel></td>
				</tr>
				</authtype>
				<%}else if(fg.trim().equals("SALDO")){%>
				
		<tr class="TextFilter" >
		   <td width="15%"><cellbytelabel>Facturar A</cellbytelabel></td>
		   <td width="85%">
		  <%=fb.select("factA","P=PACIENTE,E=EMPRESA","P",false,false,0,"Text10",null,null,null,"")%>
           </td>
		</tr>
		<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Paciente</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.intBox("pacId","",false,false,true,5,"Text10",null,null)%>
				  <cellbytelabel>Admisi&oacute;n</cellbytelabel>:<%=fb.intBox("noAdmision","",false,false,true,5,"Text10",null,null)%>
									<%=fb.textBox("nombre","",false,false,true,35,"Text10",null,null)%>
                  <%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPaciente()\"")%>
           </td>
		   <tr class="TextFilter" >
				   <td><cellbytelabel>No. Factura</cellbytelabel></td>
				   <td>
                  	   <%=fb.intBox("noFactura","",false,false,true,10,9,null,null,"onBlur=\"javascript:checkFactura(this)\"")%>
           </td>
		   <tr class="TextFilter" >
				   <td align="center" colspan="2">
				   <authtype type='54'><%=fb.button("btnGenerar","GENERAR FACTURA CON SALDO 0",true,false,"Text10",null,"onClick=\"javascript:generarFactura()\"")%></authtype></td>
		</tr>					   
												   
				
				<%}%>

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
