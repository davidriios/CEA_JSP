
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
/**
================================================================================
================================================================================
**/
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
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
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

		sql = "select a.anio,a.cod_planilla,a.num_planilla numPla, c.periodo, b.nombre, to_char(c.fecha_inicial,'dd/mm/yyyy') ,to_char(c.fecha_final,'dd/mm/yyyy'), a.anio||' - '||a.num_planilla as descPla from tbl_pla_planilla_encabezado a,tbl_pla_planilla b, tbl_pla_calendario c where a.estado = 'B' and a.cod_planilla = b.cod_planilla and a.cod_planilla = c.tipopla and to_char(sysdate,'dd/mm/yyyy') BETWEEN to_char(c.fecha_inicial,'dd/mm/yyyy') AND  to_char(c.fecha_final,'dd/mm/yyyy') and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and b.compania = a.cod_compania and b.cod_planilla ="+id;
		
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
/*if(tipoPla =='')alert('Seleccione tipo de Planilla');
else abrir_ventana('../common/search_calendario.jsp?fp=pago_empleado&tipoPla='+tipoPla);*/
abrir_ventana('../common/search_calendario.jsp?fp=pago_empleado');
}


function addPla(anio)
{
var anio = document.formCal.anio.value;
abrir_ventana1('../common/search_planilla.jsp?fp=pago_acr&anio='+anio);
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
var daanio  = eval('document.formCal.anioPlanilla').value ;
var dacodpla = eval('document.formCal.codPlanilla').value ;
var danumpla = eval('document.formCal.numPlanilla').value ;
var fechaPago  = eval('document.formCal.fechaPago').value ;
var fechaCheck = eval('document.formCal.fechaCheck').value ;
var fechaini  = eval('document.formCal.fechaIni').value ;
var fechacie  = eval('document.formCal.fechaFin').value ;
var fechatini = '' ;
var fechatfin = '' ;

var periodomes = eval('document.formCal.perMes').value ;
var user   = eval('document.formCal.userCrea').value ;
var cheque  = 0;
var comprob = 0;
var usuario = 'ibiz';
var estado = 'B';
var ret = 0;
var proceso = 'A' ;

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

if((fProc == "") || (fCierre == "") || (fechaPago == "") || (fechaCheck == ""))
msg += 'fecha ';
if(msg == '')
{
if(estado != "D")
{
 if(confirm('Se Procesará la Planilla'))
 	{
	if(executeDB('<%=request.getContextPath()%>','call sp_pla_crea_encab(<%=compania%>,'+codpla+','+numpla+','+anio+','+comprob+','+cheque+',\''+fechaini+'\',\''+fechacie+'\',\''+fCierre+'\',\''+fProc+'\',\''+fechatini+'\',\''+fechatfin+'\',\''+fechaCheck+'\',\''+fechaPago+'\','+periodo+','+periodomes+',\''+estado+'\',\''+user+'\')'))
		{
		
		var y=getDBData('<%=request.getContextPath()%>','SP_PLA_VERIFICAR_ACREEDOR(<%=compania%>,'+anio+','+codpla+','+numpla+')','dual','','');	
    	if (y== 0)			
		{
	 		if(executeDB('<%=request.getContextPath()%>','call sp_pla_calculo_acreedores(<%=compania%>,'+anio+','+codpla+','+numpla+','+daanio+','+dacodpla+','+danumpla+')'))
			    {
					alert('El Proceso se generó Satisfactoriamente!');	
					window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_acr_list.jsp';
					window.close();
				}	 else 
				{
					ret =1;
					alert('No se ha generado la Planilla **** Consulte al Administrador!||<%=compania%>||'+anio+'||'+codpla+'||'+numpla+'||'+daanio+'||'+dacodpla+'||'+danumpla+'');
				}
		} else alert('La Planilla ya Existe...Verifique.. !');  //y
		} else alert('No se creo encabezado para esta planilla .. ó .. La Planilla existe.... Revisar...!');
	}  //confirm
}//if estado != 'D'
} //msg
else alert('Seleccione '+msg);
if (ret != 0)
{
 executeDB('<%=request.getContextPath()%>','call sp_pla_elimina_encab('+codpla+',<%=compania%>,'+numpla+','+anio+')')
} 
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CALCULO DE PLANILLA ACREEDORES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	  <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		
	<%fb = new FormBean("formCal",request.getContextPath()+"/common/urlRedirect.jsp");%>
	
	<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("id",id)%> <%=fb.hidden("cot",cdo.getColValue("cot"))%> <%=fb.hidden("code",cdo.getColValue("code"))%> <%=fb.hidden("alterno",cdo.getColValue("alterno"))%><%=fb.hidden("date",date)%><%fb.hidden("usuario",(String) session.getAttribute("_userName"));%><%fb.hidden("date",request.getParameter("date"));%>
          <td colspan="7">&nbsp;</td>
        </tr>
		

			 <tr class="TextHeader" align="left">
          <td colspan="7">&nbsp;Encabezado de Planilla</td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;Año </td>
          <td><%=fb.textBox("anio",cdo.getColValue("anio"),true,false,false,5)%></td>
		   <td colspan="3"> Tipo de Planilla <%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where cod_planilla = 4 and compania="+(String) session.getAttribute("_companyId")+" order by 1","tipoPla","",false,false,0,"Text10",null,null,null,"4")%></td>
		    <td colspan="2">&nbsp;</td>
		   
        </tr>
        <tr class="TextRow01" >
          <td width="10%">&nbsp;Num. Planilla</td>
          <td width="11%"><%=fb.intBox("numPla",cdo.getColValue("numPla"),true,false,false,5,5)%></td>
          <td width="14%">Fecha de Proceso</td>
         <td width="19%"> <%=fb.textBox("fechaIni",date,true,false,false,10,10)%></td>
          <td width="13%">Fecha de Cierre</td>
          <td width="19%"> <%=fb.textBox("fechaFin",date,true,false,false,10,10)%></td>
		           <td width="14%">Periodo &nbsp;<%=fb.intBox("periodo",cdo.getColValue("periodo"),true,false,false,2,2)%></td>
        </tr>
        <tr class="TextRow01">
          <td>Período Mes</td>
          <td><%=fb.select("perMes","1=Uno,2=Dos",cdo.getColValue("perMes"))%></td>
          <td>Fecha Inicial</td>
          <td><%=fb.textBox("fechaInicial",cdo.getColValue("fechaInicial"),false,false,false,10,10)%></td>
		  <td>Fecha Final</td>
          <td><%=fb.textBox("fechaFinal",cdo.getColValue("fechaFinal"),false,false,false,10,10)%></td>
		  <td>&nbsp;</td>
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
		  <td> <%=fb.select("estado","B=BORRADOR,D=DEFINITIVA,A=ANULADA",cdo.getColValue("estado"),false,true,0,"",null,null,null,"B")%></td>
        </tr>



        <tr class="TextRow02">
          <td colspan="7">&nbsp;</td>
        </tr>
         <tr class="TextHeader" align="left">
          <td colspan="7">&nbsp;Descuentos de Empleados</td>
        </tr>
		
        <tr class="TextRow01">
          <td>&nbsp;Planilla &nbsp;<%=fb.button("btnper","...",true,false,null,null,"onClick=\"javascript:addPla()\"","")%></td>
		 
        <td colspan="6"> &nbsp; Año: &nbsp;<%=fb.textBox("anioPlanilla","",false,false,false,5,5)%>&nbsp; Cód.: &nbsp;<%=fb.textBox("codPlanilla","",false,false,false,5,5)%>&nbsp; Num.: &nbsp;<%=fb.textBox("numPlanilla","",false,false,false,5,5)%> &nbsp; <%=fb.textBox("descPlanilla","",false,false,true,70,100)%></td>
		
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
          <td><%=fb.textBox("fechaCrea",date,true,false,true,10,10)%></td>
          <td>&nbsp;Creado por:</td>
          <td><%=fb.textBox("userCrea",userName,true,false,true,10,10)%></td>
          <td>&nbsp;</td>    
		</tr>
        <tr class="TextRow01">
		  <td>&nbsp;</td>
          <td colspan="2">&nbsp;Fecha de Modificaciòn:</td>
          <td><%=fb.textBox("fechaMod",date,true,false,true,10,10)%></td>
          <td>&nbsp;Modificado por:</td>
          <td><%=fb.textBox("userMod",userName,true,false,true,10,10)%></td>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/calculo_planilla_acr_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/calculo_planilla_acr_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_acr_list.jsp';
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
