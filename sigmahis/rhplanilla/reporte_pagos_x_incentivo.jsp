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
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();

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
document.title = 'Reporte de Pagos por Incentivo / Bonificación- '+document.title;


function doAction()
{
}
function showReporte(id)
{
var msg= '';
var com = <%=(String) session.getAttribute("_companyId")%>;
var fecha_ini = eval('document.form0.fecha_ini').value ;
var fecha_fin = eval('document.form0.fecha_fin').value ;

var sal_inicio = eval('document.form0.sal_inicio').value ;
var sal_final = eval('document.form0.sal_final').value ;

var rxh_inicio  = eval('document.form0.rxh_inicio').value ;
var rxh_final  = eval('document.form0.rxh_final').value ;

var hora_inicio = eval('document.form0.hora_inicio').value ;
var hora_final = eval('document.form0.hora_final').value ;

var cargo  = eval('document.form0.cargo').value ;
var unidad = eval('document.form0.unidad').value ;

var monto  = eval('document.form0.monto').value ;
var tipoTrx = eval('document.form0.tipo_trx').value ;
var anio  = eval('document.form0.anio').value ;
var quinc = eval('document.form0.quinc').value ;
var planilla  = eval('document.form0.planilla').value ;
var accion = eval('document.form0.accion').value ;
var fecha = eval('document.form0.fecha').value ;
var comentario = eval('document.form0.comentario').value ;
if(unidad=="") unidad ="0";
if(cargo=="") cargo ="0";
if(fecha_ini=="") fecha_ini ="01/01/1900";
if(fecha_fin=="") fecha_fin ='<%=cDate%>';
if(sal_inicio=="") sal_inicio ="0";
if(sal_final=="") sal_final ="0";
if(rxh_inicio=="") rxh_inicio ="0";
if(rxh_final=="") rxh_final ="0";
if(hora_inicio=="") hora_inicio ="0";
if(hora_final=="") hora_final ="0";

if(comentario=="") comentario ="Registro Automatico";
if(com == "")
msg = ', compañia';
if(monto == "")
msg = ', Monto';
if(tipoTrx == "")
msg = ', Tipo de Transaccion';
if(accion == "")
msg = ', Accion';
if(anio == "")
msg = ', Año';
if(quinc == "")
msg = ', Quincena';
if(planilla == "")
msg = ', Planilla';
if(fecha == "")
msg = ', Fecha';
if(msg == ""){
if(id=="0")
abrir_ventana2('../rhplanilla/print_pago_incentivo.jsp?anio='+anio+'&cod='+planilla+'&quinc='+quinc+'&fecha=\''+fecha+'\'');
else if(id=="1")
{
 if(confirm('Se Procesarán las Transacciones ... Desea Continuar...'))
 {
	if(executeDB('<%=request.getContextPath()%>','call sp_pla_genera_trx_incentivo('+planilla+','+com+','+quinc+','+anio+',\'<%=(String)session.getAttribute("_userName")%>\','+planilla+','+monto+','+tipoTrx+',\''+accion+'\',\''+comentario+'\','+unidad+',\''+fecha+'\',\''+fecha_ini+'\',\''+fecha_fin+'\','+sal_inicio+','+sal_final+','+rxh_inicio+','+rxh_final+','+hora_inicio+','+hora_final+','+cargo+')'))
	{
	alert('Las Transacciones se generarón Satisfactoriamente!...  Proceda a la Autorización....');	
	window.location.reload(true);
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/print_pago_incentivo.jsp?anio='+anio+'&cod='+planilla+'&quinc='+quinc+'&fecha=\''+fecha+'\'';
	window.close();
	}
	}	
	} // end id=1
	else if(id=="2")
if(confirm('Se Borrará las Transacciones Generadas.... Desea Continuar'))
 	{
		if(executeDB('<%=request.getContextPath()%>','call sp_pla_elimina_transaccion('+planilla+','+com+','+quinc+','+anio+','+tipoTrx+',\''+accion+'\')'))
			{
			alert('Las Transacciones han sido Borradas Satisfactoriamente!');	
			 window.location.reload(true);
			 } else alert('No se ha podido borrar las Transacciones...Consulte al Administrador!');
	}
/*	if(executeDB('<%//=request.getContextPath()%>','call sp_pla_genera_trx_incentivo('+planilla+','+com+','+quinc+','+anio+',\'<%//=(String)session.getAttribute("_userName")%>\','+planilla+','+monto+','+tipoTrx+',\''+accion+'\',\''+fecha+'\',\''+comentario+'\',\''+fProc+'\',\''+fechatini+'\',\''+fechatfin+'\',\''+fechaCheck+'\',\''+fechaPago+'\','+periodo+','+periodomes+',\''+estado+'\',\''+user+'\')'))
	*/
		
}else alert('Introduzca Valor en '+msg);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE PAGOS POR INCENTIVO"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">  
<tr>  
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
            <%=fb.hidden("usuario",userName)%>
				<tr class="TextHeader">
							<td colspan="3">Parámetros de Búsqueda y Carga de Registros</td>
				</tr>
                
                <tr class="TextHeader">
							<td colspan="1" align="center">CRITERIO</td>
                            <td colspan="2" align="center">VALORES</td>
				</tr>
				<!--
        <tr class="TextRow01"> 
					<td>Compania</td>
					<td colspan="3">
  				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || nombre descripcion from tbl_sec_compania where estado = 'A' order by nombre asc","conpania",(String) session.getAttribute("_companyId"),false,viewMode,0,null,null,"")%>
					<%//=fb.textBox("compania",(String) session.getAttribute("_companyId"),true,false,false,5)%></td>
				</tr>
        -->
        
        		<tr class="TextRow01"> 
					<td width="35%">FECHA DE INGRESO</td>
					<td width="30%">Desde :&nbsp;
                    <jsp:include page="../common/calendar.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha_ini" />
                    <jsp:param name="valueOfTBox1" value="" />
                    </jsp:include></td>
					<td width="35%">Hasta :&nbsp; 
                    <jsp:include page="../common/calendar.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha_fin" />
                    <jsp:param name="valueOfTBox1" value="" />
                    </jsp:include></td>
         			</tr>
                
                <tr class="TextRow01"> 
					<td>SALARIO BASE</td>
					<td>Desde : &nbsp; <%=fb.decBox("sal_inicio","",false,false,false,10,10.2,"Text10",null,null)%></td>
                    <td>Hasta : &nbsp; <%=fb.decBox("sal_final","",false,false,false,10,10.2,"Text10",null,null)%></td>
				</tr>
                    
                <tr class="TextRow01"> 
					<td>RATA X HORA</td>
					<td>Desde : &nbsp; <%=fb.decBox("rxh_inicio","",false,false,false,10,10.2,"Text10",null,null)%></td>
                    <td>Hasta : &nbsp; <%=fb.decBox("rxh_final","",false,false,false,10,10.2,"Text10",null,null)%></td>
				</tr>
                
                   <tr class="TextRow01"> 
					<td>HORAS TRABAJADAS(MES)</td>
					<td>Desde : &nbsp; <%=fb.decBox("hora_inicio","",false,false,false,10,10.2,"Text10",null,null)%></td>
                    <td>Hasta : &nbsp; <%=fb.decBox("hora_final","",false,false,false,10,10.2,"Text10",null,null)%></td>
				</tr>
                    
        
				<tr class="TextRow01"> 
					<td>CARGO / POSICION</td>
					<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || denominacion descripcion from tbl_pla_cargo where compania = "+(String) session.getAttribute("_companyId")+" order by denominacion asc","cargo","",false,false,0,"text10",null,"", "", "S")%>
				</tr>
                
                <tr class="TextRow01"> 
					<td>UNIDAD ADMINISTRATIVA</td>
					<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+" and nivel = 3 order by descripcion asc","unidad","",false,false,0,"text10",null,"", "", "S")%>
				</tr>
                
                <tr class="TextHeader">
							<td colspan="3">DATOS GENERALES APLICADOS A TRANSACCIONES</td>
				</tr>
                <tr class="TextRow01"> 
					<td> FECHA DE TRANSACCION : &nbsp;&nbsp;&nbsp;
                    <jsp:include page="../common/calendar.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha" />
                    <jsp:param name="valueOfTBox1" value="" />
                    </jsp:include></td>
                   <td colspan="2"> Comentarios :&nbsp;
				   <%=fb.textarea("comentario","",false,false,false,50,3,"Text11",null,null)%></td>
                 </tr>  
                               
                <tr class="TextHeader">
							<td colspan="3">DATOS DE LA TRANSACCION</td>
				</tr>
                
                 <tr class="TextRow01"> 
					<td>Monto a Aplicar: &nbsp; <%=fb.decBox("monto","",false,false,false,10,10.2,"Text10",null,null)%></td>
					<td colspan="2" align="center">Año : &nbsp; <%=fb.textBox("anio","",false,false,false,3)%>&nbsp;&nbsp;Quinc.: &nbsp; <%=fb.textBox("quinc","",false,false,false,3)%> &nbsp;&nbsp;Planilla: &nbsp; <%=fb.select(ConMgr.getConnection(),"select cod_planilla codigo, cod_planilla ||' - ' || nombre descripcion from tbl_pla_planilla where compania = "+(String) session.getAttribute("_companyId")+" order by nombre asc","planilla","",false,false,0,"text10",null,"", "", "S")%> </td>
				</tr>
                
                  <tr class="TextRow01"> 
					<td colspan="3">Tipo de Trx : &nbsp; <%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_pla_tipo_transaccion where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion asc","tipo_trx","",false,false,0,"text10",null,"", "", "S")%></td>
					
				</tr>
                
                   <tr class="TextRow01"> 
					<td colspan="3">Acción : &nbsp; <%=fb.select("accion","PA=Pagar, DE=Descontar", "",false,false,0,"Text12",null,null)%></td>
					
				</tr>
                
                
                				
				<tr class="TextRow01"> 
					<td colspan="3" align="center">
					<%=fb.button("addReporte","Reporte",false,false,null,null,"onClick=\"javascript:showReporte(0)\"","Reporte de Transacciones")%>
					<%=fb.button("addTrx","Generar Transacciones",false,false,null,null,"onClick=\"javascript:showReporte(1)\"","Generar Transacciones")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
                
                <tr class="TextRow01"> 
					<td colspan="3" align="center">
					<%=fb.button("delTrx","Proceso para Borrar Transacciones Generadas",false,false,null,null,"onClick=\"javascript:showReporte(2)\"","Eliminar Transacciones")%>
					</td>
				</tr>
			
	<%fb.appendJsValidation("if(error>0)doAction();");%>		
	<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>