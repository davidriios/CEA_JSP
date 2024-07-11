
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="calen" scope="session" class="java.util.Hashtable"/>
<%

SecMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cal = new CommonDataObject();
String sql="";
String ii="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String change= request.getParameter("change");
String date="";
String anio="";
String compania = (String) session.getAttribute("_companyId"); 
String tipo = "";
double count = 0;
String userName = UserDet.getUserName();
String userId   = UserDet.getUserId();
boolean viewMode = false;
int callastLineNo =0;
int ind=0;
date = CmnMgr.getCurrentDate("dd/mm/yyyy");
anio = CmnMgr.getCurrentDate("yyyy");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		
		id = "0";
		cdo.addColValue("code","0");
		cdo.addColValue("date",date);
		cdo.addColValue("fechaPro",date);
		cdo.addColValue("usuario",userName);
		cdo.addColValue("anio",anio);
		
	}
	
	else
	{
		if (id == null) throw new Exception("El Acreedor del Empleado no es válido. Por favor intente nuevamente!");

		sql = "select a.anio,a.cod_planilla,a.num_planilla, b.nombre, to_char(fecha_inicial,'dd/mm/yyyy') ,to_char(fecha_final,'dd/mm/yyyy') from tbl_pla_planilla_encabezado a,tbl_pla_planilla b where a.estado = 'B' and a.cod_planilla = b.cod_planilla and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and b.compania = a.cod_compania and b.cod_planilla and cod_planilla="+id;
		
		cdo = SQLMgr.getData(sql);
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Cálculo de Planilla - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cálculo de Planilla - Edición - "+document.title;
<%}%>
function rutass()
{
abrir_ventana1('../rhplanilla/list_ruta.jsp');
}

function setBAction(fName,actionValue)
{
  document.formCal.procesoq.value = actionValue;
}
function addPer(index)
{
var tipoPla =document.formCal.tipoPla.value;
if(tipoPla =='')alert('Seleccione tipo de Planilla');
else abrir_ventana('../common/search_calendario.jsp?fp=pago_empleado');
}

function mouseOver(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  var msg='&nbsp;';
  switch(option)
  {
    case 0:msg='Consultar Licencias';break;
    case 1:msg='Horas Regulares No Reg.';break;
    case 2:msg='Calcular Planilla';break;
    case 3:msg='Ver Cálculos';break;
    case 4:msg='Imprimir Reportes';break;
    case 5:msg='Imprimir Cheques/Talonarios';break;
    case 6:msg='Eliminar Planilla';break;
    case 7:msg='Actualizar Planilla';break;
  }
  setoverc(obj,'ImageBorderOver');
  optDescObj.innerHTML=msg;
  obj.alt=msg;
}
function mouseOut(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  setoutc(obj,'ImageBorder');
  optDescObj.innerHTML='&nbsp;';
}

function doRedirect(k)
{
var msg = '';

var anio    = eval('document.formCal.anio').value ;
var codpla  = eval('document.formCal.tipoPla').value ;
var numpla  = eval('document.formCal.numPla').value ;
var estado  = eval('document.formCal.estado').value ;
var fProc   = eval('document.formCal.fechaInicial').value ;
var fCierre = eval('document.formCal.fechaFinal').value ;
var periodo = eval('document.formCal.periodo').value ;
var cheque  = eval('document.formCal.cheque').value ;
var comprob = eval('document.formCal.comprob').value ;
var fechaPago  = eval('document.formCal.fechaPago').value ;
var fechaCheck = eval('document.formCal.fechaCheck').value ;
var fechaini  = eval('document.formCal.fechaIni').value ;
var fechacie  = eval('document.formCal.fechaFin').value ;
var fechatini = eval('document.formCal.transDesde').value ;
var fechatfin = eval('document.formCal.transHasta').value ;
//var proceso = eval('document.formCal.procesoq').value ;

var proceso = getRadioButtonValue(document.formCal.procesoq);
var legales = eval('document.formCal.legales').value ;
var acreedores = eval('document.formCal.acreedores').value ;
var periodomes = eval('document.formCal.perMes').value ;
var user   = eval('document.formCal.userCrea').value ;
var anioOrg='';
var codPlaOrg='';
var numplaOrg='';
if(document.formCal.anioOrg)anioOrg = document.formCal.anioOrg.value;
if(document.formCal.codPlaOrg)codPlaOrg = document.formCal.codPlaOrg.value;
if(document.formCal.numplaOrg)numplaOrg = document.formCal.numplaOrg.value;

var usuario = 'ibiz';
var estado = 'B';
var ret = 0;

if ((proceso == "") || (proceso == null))
proceso = 'Q';
if(anio == "")
msg = ' Año ';
if(estado == "")
msg += ', estado ';
if(codpla == "")
msg = ' Codigo ';
if(numpla == "")
msg += ', Planilla ';
if(periodo == "")
msg += ', Periodo ';
if((cheque == "") || (comprob == "") )
msg += ' Ck. / Comprobante ';
if((fProc == "") || (fCierre == "") || (fechaPago == "") || (fechaCheck == ""))
msg += 'fecha ';
if(msg == '')
{
if(codpla !='7'){
if(estado != "D" && proceso != "I" && proceso != "B")
{
 if(confirm('Se Procesará la Planilla'))
 {
   if(executeDB('<%=request.getContextPath()%>','call sp_pla_crea_encab(<%=compania%>,'+codpla+','+numpla+','+anio+','+comprob+','+cheque+',\''+fechaini+'\',\''+fechacie+'\',\''+fCierre+'\',\''+fProc+'\',\''+fechatini+'\',\''+fechatfin+'\',\''+fechaCheck+'\',\''+fechaPago+'\','+periodo+','+periodomes+',\''+estado+'\',\''+user+'\')'))
   {
		
		//   verifica si hay empleados sin ubicacion dentro de la tabla de empleados
var x=getDBData('<%=request.getContextPath()%>','SP_PLA_VERIFICA_EMPLEADO(<%=compania%>,'+codpla+',\''+fCierre+'\')','dual','','');
  if (x == 0)
  {
    var y=getDBData('<%=request.getContextPath()%>','SP_PLA_VERIFICA_PAGO(<%=compania%>,'+codpla+','+numpla+','+anio+')','dual','','');	
    if (y== 0)			
	{
	  	if (proceso == "Q")
			{
			if(executeDB('<%=request.getContextPath()%>','call sp_pla_calculo_quincenal(<%=compania%>,'+codpla+','+numpla+','+anio+','+comprob+','+cheque+',\''+fCierre+'\',\''+fProc+'\',\''+fechaPago+'\','+periodo+','+periodomes+',\''+legales+'\',\''+acreedores+'\',\''+user+'\')'))
				{
					
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_cierre(<%=compania%>)','tbl_pla_temporal_emp,tbl_pla_temporal_descuento_apl'))
						  {
						alert('La Planilla se generó Satisfactoriamente!');	
						window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_list.jsp';
							window.close();
						  } else 
						  {
						  ret =1;
						  alert('No se ha generado la Planilla  Consulte al Administrador!');
						  }
				} else 
					{
					ret = 1;
				alert('Planilla  no se ha  generado  Revisar...!'); //executeDb sp_pla_calculo_quincenal
					}
			} // end Q
			
		else if(proceso == "V")
		{
			if(confirm('Se Procesará la Planilla de Vacaciones'))
			{
			  if(executeDB('<%=request.getContextPath()%>','call sp_pla_calculo_vacacion('+codpla+',<%=compania%>,'+numpla+','+anio+','+comprob+','+cheque+','+periodo+',\''+legales+'\',\''+acreedores+'\',\''+fechaPago+'\',\''+fechaini+'\',\''+fechacie+'\',\''+user+'\')'))
			  {
			    if(executeDB('<%=request.getContextPath()%>','call sp_pla_cierre(<%=compania%>)','tbl_pla_temporal_emp,tbl_pla_temporal_descuento_apl'))
				{
				alert('La Planilla de Vacaciones se generó Satisfactoriamente!');	
				window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_list.jsp';
				window.close();
			 	} else alert('No se ha generado la Planilla de Vacaciones Consulte al Administrador!');	
			  } else alert('Planilla  no se ha  generado  Revisar...!'); //executeDb 	
			}
		}  // end V
		else if(proceso=="D")
		{
			if(confirm('Se Procesará la Planilla de Decimo'))
			{
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_calculo_decimo('+codpla+',<%=compania%>,'+numpla+','+anio+','+comprob+','+cheque+','+periodo+',\''+legales+'\',\''+fechaPago+'\')'))
				{
				    if(executeDB('<%=request.getContextPath()%>','call sp_pla_cierre(<%=compania%>)','tbl_pla_temporal_emp,tbl_pla_temporal_descuento_apl'))
			   	    {
					alert('La Planilla de Décimo se generó Satisfactoriamente!');	
					window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_list.jsp';
					window.close();
					 } else alert('No se ha generado la Planilla del Décimo Consulte al Administrador!');	
				 } else alert('Planilla  no se ha  generado  Revisar...!'); //executeDb 	
			 }
		} //  end D	 
		else if(proceso=='I' || proceso =='B')
		{
			if(confirm('Se Procesará la Planilla de Incentivos'))
			{
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_calculo_incentivo(<%=compania%>,'+codpla+','+numpla+','+anio+','+comprob+','+cheque+',\''+fechacie+'\',\''+fechaini+'\',\''+fechaPago+'\','+periodo+','+periodo+',\''+legales+'\',\''+acreedores+'\',\''+proceso+'\',\''+user+'\')'))
				{
					if(executeDB('<%=request.getContextPath()%>','call sp_pla_cierre(<%=compania%>)','tbl_pla_temporal_emp,tbl_pla_temporal_descuento_apl'))
			   	    {
					alert('La Planilla de Incentivos se generó Satisfactoriamente!');	
					window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_list.jsp';
					window.close();
					 } else alert('No se ha generado la Planilla del Incentivos Consulte al Administrador!');	
				 } else alert('Planilla  no se ha  generado  Revisar Procedimiento...!'); //executeDb 	
			 }
		} //  end D	 
		} else alert('La Planilla ya Existe...Verifique.. !');  //y
  } else alert('Empleados sin Ubicación Revisar.. !');   //x
			
		
	} else alert('No se creo encabezado para esta planilla .. ó .. La Planilla existe.... Revisar...!');	
	
 }  //confirm
	
if (ret != 0)
{
 executeDB('<%=request.getContextPath()%>','call sp_pla_elimina_encab('+codpla+',<%=compania%>,'+numpla+','+anio+')')
} 

}//if estado != 'I'
else if(proceso == 'I' || proceso == 'B' ){

var trx ='';
if(proceso == 'I' )trx='43';
else if(proceso == 'B' ) trx='42';
					  
showPopWin('../common/run_process.jsp?fp=PLA&actType=50&docType=PLA&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&periodo='+periodo+'&codPlanilla='+codpla+'&numPlanilla='+numpla+'&comprob='+comprob+'&cheque='+cheque+'&trxs='+trx+'&legales='+legales+'&acreedores='+acreedores+'&periodoMes='+periodomes+'&fechaIni='+fechaini+'&fechaFin='+fechacie+'&fechaFinal='+fCierre+'&fechaInicia='+fProc+'&transDesde='+fechatini+'&transHasta='+fechatfin+'&fechaCheck='+fechaCheck+'&fecha='+fechaPago+'&estado='+estado+'&cheque2=0',winWidth*.75,winHeight*.65,null,null,'');
}
}//Distinta de Ajustes
else {
 
showPopWin('../common/run_process.jsp?fp=PLA&actType=51&docType=PLA&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&periodo='+periodo+'&codPlanilla='+codpla+'&numPlanilla='+numpla+'&comprob='+comprob+'&cheque='+cheque+'&trxs='+trx+'&legales='+legales+'&acreedores='+acreedores+'&periodoMes='+periodomes+'&fechaIni='+fechaini+'&fechaFin='+fechacie+'&fechaFinal='+fCierre+'&fechaInicia='+fProc+'&transDesde='+fechatini+'&transHasta='+fechatfin+'&fechaCheck='+fechaCheck+'&fecha='+fechaPago+'&estado='+estado+'&cheque2=0&pAnioOr='+anioOrg+'&pCodPlanillaOr='+codPlaOrg+'&pNoPlanillaOr='+numplaOrg,winWidth*.75,winHeight*.65,null,null,'');

}
} //msg
else alert('Seleccione '+msg);
}
function addPlaAjuste()
{
var anio = eval('document.formCal.anio').value;
abrir_ventana1('../common/search_planilla.jsp?fp=regPlanillaAjuste&anio='+anio);
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CALCULO DE PLANILLA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	  <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		
	<%fb = new FormBean("formCal",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart(true)%><%=fb.hidden("mode",mode)%><%=fb.hidden("id",id)%><%=fb.hidden("cot",cdo.getColValue("cot"))%> <%=fb.hidden("code",cdo.getColValue("code"))%> <%=fb.hidden("alterno",cdo.getColValue("alterno"))%><%=fb.hidden("date",date)%><%fb.hidden("usuario",(String) session.getAttribute("_userName"));%><%fb.hidden("date",request.getParameter("date"));%>
          <td colspan="7">&nbsp;</td>
        </tr>
		

			 <tr class="TextHeader" align="left">
          <td colspan="7">&nbsp;Encabezado de Planilla</td>
        </tr>
		
        <tr class="TextRow01">
		 <td colspan="2">Planilla <%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where compania="+(String) session.getAttribute("_companyId")+" and is_visible ='S' order by 1","tipoPla","",false,false,0,"Text10",null,null,null,"S")%></td>
          <td colspan="2">&nbsp;Calendario de Planilla <%=fb.button("btnper","...",true,false,null,null,"onClick=\"javascript:addPer()\"")%></td>
          <td align="left">A&ntilde;o</td>
          <td colspan="2"><%=fb.textBox("anio",cdo.getColValue("anio"),true,false,false,5)%></td>
		  
		   
        </tr>
        <tr class="TextRow01" >
          <td width="16%">&nbsp;Num. Planilla</td>
          <td width="13%"><%=fb.intBox("numPla",cdo.getColValue("numPla"),true,false,true,5,5)%></td>
          <td width="10%">Fecha de Proceso</td>
          <td width="19%"> <%=fb.textBox("fechaIni",cdo.getColValue("date"),true,false,true,10,10)%></td>
          <td width="13%">Fecha de Cierre</td>
          <td width="19%"> <%=fb.textBox("fechaFin",cdo.getColValue("fechaFin"),true,false,true,10,10)%></td>
		  <td width="10%">Periodo &nbsp;<%=fb.intBox("periodo",cdo.getColValue("periodo"),true,false,true,2,2)%></td>
        </tr>
        <tr class="TextRow01">
          <td>Período Mes</td>
          <td><%=fb.select("perMes","1=Uno,2=Dos",cdo.getColValue("perMes"))%></td>
          <td>Fecha Inicial</td>
          <td><%=fb.textBox("fechaInicial",cdo.getColValue("fechaInicial"),false,false,true,10,10)%></td>
		   <td>&nbsp;</td>
          <td>Fecha Final</td>
          <td><%=fb.textBox("fechaFinal",cdo.getColValue("fechaFinal"),false,false,true,10,10)%></td>
</tr>

<tr class="TextRow01">
          <td colspan="2">&nbsp;Transacciones  =======></td>
          <td>Fecha Inicial</td>
          <td><%=fb.textBox("transDesde",cdo.getColValue("transDesde"),false,false,true,10,10)%></td>
		   <td>&nbsp;</td>
          <td>Fecha Final</td>
          <td><%=fb.textBox("transHasta",cdo.getColValue("transHasta"),false,false,true,10,10)%></td>
</tr>
	 <tr class="TextRow01">
          <td colspan="2">&nbsp;Secuencias Inicial=====></td>
         <td># Cheque Inicial</td>
         <td><%=fb.textBox("cheque",cdo.getColValue("cheque"),true,false,false,10,10)%></td>
		 <td>&nbsp;</td>
         <td>Comprobante Inicial</td>
         <td><%=fb.textBox("comprob",cdo.getColValue("comprob"),true,false,false,10,10)%></td>
</tr>

		 <tr class="TextRow01" >
          <td colspan="2" >&nbsp;</td>
          <td >Fecha de Pago</td>
         	<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaPago"/>	
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fechaPago")==null)?"":cdo.getColValue("fechaPago")%>" />
				</jsp:include>
				</td>
          <td>Fecha de Cheques</td>
          <td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaCheck"/>	
			<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fechaCheck")==null)?"":cdo.getColValue("fechaCheck")%>" />
			</jsp:include>
			</td>
		  <td> <%=fb.select("estado","B=BORRADOR",cdo.getColValue("estado"),false,true,0,"",null,null,null,"B")%></td>
        </tr>
		
		
        <tr class="TextRow02">
          <td colspan="7">&nbsp;</td>
        </tr>
		<tr class="RedTextBold">
          <td colspan="7">PLANILLA A AJUSTAR: 
		  	Año <%=fb.intBox("anioOrg","",false,false,true,5,4,"Text12",null,null)%>
			Cod. Planilla<%=fb.intBox("codPlaOrg","",false,false,true,5,4,"Text12",null,null)%>
			<%=fb.intBox("descPlanillaOrg","",false,false,true,20,"Text12",null,null)%>
			
			No. Planilla<%=fb.intBox("numplaOrg","",false,false,true,5,4,"Text12",null,null)%><%=fb.button("btnper2","...",true,viewMode,null,null,"onClick=\"javascript:addPlaAjuste()\"","")%></td>
        </tr>
		
         <tr class="TextHeader" align="left">
          <td colspan="7">&nbsp;Procesos</td>
        </tr>
		
        <tr class="TextRow01">
          <td>&nbsp;</td>
		 
         <td align="center"><%=fb.radio("procesoq","Q",true,viewMode,false)%>Quincenal</td>
		 <td align="center"><%=fb.radio("procesoq","V",false,viewMode,false)%>Vacaciones</td>
		 <td align="center"><%=fb.radio("procesoq","D",false,viewMode,false)%>Décimo</td>
		 <td align="center"><%=fb.radio("procesoq","B",false,viewMode,false)%>Bonificación</td>
		 <td align="center"><%=fb.radio("procesoq","I",false,viewMode,false)%>Incentivo</td>
		 <td align="center"><!--<%=fb.radio("procesoq","U",false,viewMode,false)%>Participación Util--></td>
		 
		</tr>
		
		
		<tr class="TextRow01">
          <td colspan="3" align="right">&nbsp;Aplicar Descuentos:</td>
         <td align="center"><%=fb.checkbox("legales","S",true,false)%>Legales</td>
         <td align="center"><%=fb.checkbox("acreedores","S",true,false)%>Acreedores</td>
          <td colspan="2">&nbsp;</td>
          </tr>
        <tr class="TextRow01">
          <td colspan="7">&nbsp;</td>
        </tr>
         <tr class="TextHeader" align="left">
          <td colspan="7">&nbsp;Bitàcora</td>
        </tr>
        <tr class="TextRow01">
		  <td>&nbsp;</td>
          <td colspan="2">&nbsp;Fecha de Creaciòn: </td>
          <td><%=fb.textBox("fechaCrea",cdo.getColValue("date"),true,false,true,10,10)%></td>
          <td>&nbsp;Creado por:</td>
          <td><%=fb.textBox("userCrea",cdo.getColValue("usuario"),true,false,true,10,10)%></td>
          <td>&nbsp;</td>    
		</tr>
        <tr class="TextRow01">
		  <td>&nbsp;</td>
          <td colspan="2">&nbsp;Fecha de Modificaciòn:</td>
          <td><%=fb.textBox("fechaMod",cdo.getColValue("date"),true,false,true,10,10)%></td>
          <td>&nbsp;Modificado por:</td>
          <td><%=fb.textBox("userMod",cdo.getColValue("usuario"),true,false,true,10,10)%></td>
          <td>&nbsp;</td>
		</tr>
        <tr class="TextRow02">
          <td colspan="7" align="right"><%=fb.button("procesar","Procesar",true,false,null,null,"onClick=\"javascript:doRedirect('3')\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
		
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
	</tr>
</table>		

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_encabezado");
  cdo.addColValue("trans_desde",request.getParameter("transDesde"));
  cdo.addColValue("trans_hasta",request.getParameter("transHasta"));
  cdo.addColValue("anio", request.getParameter("anio")); 
  cdo.addColValue("cod_planilla",request.getParameter("tipoPla"));
  cdo.addColValue("num_planilla",request.getParameter("numPla"));
  cdo.addColValue("periodo",request.getParameter("periodo"));
  cdo.addColValue("periodo_mes",request.getParameter("perMes"));
  cdo.addColValue("fecha_proceso",request.getParameter("fechaIni"));
  cdo.addColValue("fecha_cierre",request.getParameter("fechaFin"));
  cdo.addColValue("fecha_pago",request.getParameter("fechaPago"));
  cdo.addColValue("fecha_inicial",request.getParameter("fechaInicial"));
  cdo.addColValue("fecha_final",request.getParameter("fechaFinal"));
  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("fecha_cheque",request.getParameter("fechaCheck"));
  //cdo.addColValue("planilla_mensual",request.getParameter("plames"));
  cdo.addColValue("estado","B");
  cdo.addColValue("cheque_inicial",request.getParameter("cheque"));
  cdo.addColValue("comprobante_inicial",request.getParameter("comprob"));
  cdo.addColValue("asiento_generado","N");
  //cdo.addColValue("asgenerado_por", request.getParameter("asgenera")); 
  //cdo.addColValue("asfecha_generado",request.getParameter("asfecha"));
  //cdo.addColValue("asconsecutivo",request.getParameter("asconsec"));
  
 
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
	
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and num_planilla="+request.getParameter("tipoPla"));

	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/calculo_planilla_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/calculo_planilla_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
