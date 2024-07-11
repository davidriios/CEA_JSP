<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ACEMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ACEMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String planilla = request.getParameter("planilla");
String periodo = request.getParameter("periodo");
String compania = (String) session.getAttribute("_companyId"); 
String empId = request.getParameter("empid");
String seccion = request.getParameter("seccion");
String fg = request.getParameter("fg");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = cDateTime.substring(6,10);
String mes = cDateTime.substring(3,5);
String dia = cDateTime.substring(0,2);
String userName = UserDet.getUserName();
int per = 0;

if(Integer.parseInt(dia) >16) per = Integer.parseInt(mes)*2;
else per =  Integer.parseInt(mes)*2-1;

	if (anio == null) anio = anioC;	
	if (periodo == null) periodo = ""+per;
	if (planilla == null) planilla = "1";
	if (fg == null) fg = "";
	
if (request.getMethod().equalsIgnoreCase("GET"))
{
   if (mode.equalsIgnoreCase("view"))
	{
		if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
		if (periodo == null) throw new Exception("El Periodo no es válido. Por favor intente nuevamente!");
	    if (planilla == null) throw new Exception("El Código de Planilla no es válido. Por favor intente nuevamente!");
	
		sql="select distinct(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, b.num_empleado as numEmpleado,  b.emp_id as empId, e.anio, decode(e.forma_pago,'1','CHQ','2','ACH') as formaPago, e.vobo_estado, e.cod_planilla,  substr(p.nombre,10,5)||'-'||e.anio||'-'||e.num_planilla as codigoPla, e.num_planilla, e.num_cheque as cheque, e.num_ach as ach, w.imprimir, w.paseConta, e.cheque_impreso as impreso, decode(e.estado, 'PE' , 'PENDIENTE' , 'AC' , 'ACTUALIZADO' ,'AP','APROBADO') as estado, to_char(e.fecha_cheque,'dd/mm/yyyy') as fecha, e.secuencia as codigo, b.num_empleado as numEmpleado, nvl(b.rata_hora,'1') as rataHora, b.ubic_seccion as grupo, e.emp_id as filtro, to_char((nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0)+ nvl(e.ausencia,0) + nvl(e.tardanza,0)) - (nvl(e.otros_egr,0)),'999,999,990.00') as montoBruto,  to_char(nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0) + nvl(e.seg_social,0) + nvl(e.seg_educativo,0) + nvl(e.imp_renta,0) + nvl(e.total_ded,0)),'999,999,990.00') as montoNeto, to_char(nvl(e.seg_social,0) + nvl(e.seg_educativo,0) + nvl(e.imp_renta,0) + nvl(e.total_ded,0),'999,999,990.00') as montoDesc, p.nombre as nombrePla from tbl_pla_empleado b, tbl_pla_pago_ajuste e, tbl_pla_planilla p , (select 'S' as imprimir, 'SI' as paseConta, c.num_cheque from tbl_pla_parametros b, tbl_con_cheque c where b.cod_compania = "+compania+" and c.cod_compania = b.cod_compania and c.cod_banco = b.cod_banco and c.cuenta_banco = b.cuenta_bancaria ) w where b.emp_id = e.emp_id and b.compania=e.cod_compania and e.cod_planilla = p.cod_planilla and e.cod_compania = p.compania  and b.compania="+compania+appendFilter+" and e.num_cheque = w.num_cheque(+)  ";
		if(fg.trim().equals("AP"))sql +=" and e.estado = 'PE' and e.vobo_estado = 'S' and nvl(e.actualizar,'N') <> 'S' order by b.emp_id";
		else if(fg.trim().equals("RE"))sql +=" and e.estado = 'PE' and e.vobo_estado = 'S' and nvl(e.actualizar,'N') = 'S' order by b.emp_id";
		al=SQLMgr.getDataList(sql);
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;
function actualiza()
{
var msg      ="";
var msg2      ="";
var size     = eval('document.form3.ajusSize').value;
var aniopla  = '';//eval('document.form3.aniopla').value;
var periodo  = '';//eval('document.form3.periodo').value;
//var anioCont = eval('document.form3.ultanio').value;
//var mesCont  = eval('document.form3.ultmes').value;
var cont = 0;

		if (msg=='')
		{
		for(i=0;i<size;i++)
			{
				if (eval('document.form3.check'+i).checked)
				{
				var estado = 'B';
				var anio = eval('document.form3.anio'+i).value;
				var numero = eval('document.form3.noPlanilla'+i).value;
				var planilla = eval('document.form3.codPlanilla'+i).value;
				var totCheck = eval('document.form3.cont').value;
				var numEmpl = eval('document.form3.noEmpleado'+i).value;
				var secuencia = eval('document.form3.secuencia'+i).value;
				var empId = eval('document.form3.empId'+i).value;
				
				
				var estado=getDBData('<%=request.getContextPath()%>','estado','tbl_pla_planilla_encabezado','estado = \'D\' and anio = '+ anio +' and cod_planilla = '+planilla+' and num_planilla = '+numero+' and cod_compania = '+<%=compania%>,'');
					if((estado!='D') || (estado==null)){
						 alert('El ajuste que intenta aplicar corresponde a una planilla que no existe o no ha sido CERRADA aún...Por lo tanto no podra ser seleccionada.... ');
						document.getElementById("check"+i).checked = false; 
						document.getElementById("checkx").checked = false; 
   					document.getElementById("cont").value=totCheck - 1;
					return false;
					
					 }/* else {
							if(confirm('Está seguro de procesar los Ajustes')){ 
											/*showPopWin('../common/run_process.jsp?fp=ACTAJ&actType=50&docType=ACTAJ&docId='+anio+'&docNo='+anio+'&compania=<%=compania%>&anio='+anio+'&noEmpleado='+numEmpl+'&codPlanilla='+planilla+'&numPlanilla='+numero+'&codigo='+secuencia+'&empId='+empId+'&periodo='+periodo,winWidth*.75,winHeight*.65,null,null,'');*/


								/*if(executeDB('<%=request.getContextPath()%>','call sp_pla_actualiza_ajuste(<%=compania%>,'+numEmpl+','+anio+','+planilla+','+numero+','+secuencia+','+empId+',\'<%=(String) session.getAttribute("_userName")%>\','+periodo+')','')){
									alert('Los Ajustes se Actualizaron Satisfactoriamente!');
									window.opener.location = '<%=request.getContextPath()%>/rhplanilla/autoriza_trx.jsp';
									window.close();	
									
								} else alert('Los Ajustes no se Actualizaron (sp_pla_actualiza_ajuste)...  Revisar !'); // execute actualiza
								
							}else alert('Proceso Cancelado!'); // confirm
					 	} // else
						*/
					
				}  else 
						{
						cont += 1;
						if(size==cont)
						msg +='No hay transacción chequeada...Revise!!!';// if checked
						}
			} // end for
		}
		else alert(''+msg);
		
		if(msg=='' && size !=0)document.form3.submit();
		else if(size ==0)alert(' No existen registros para Actualizar... ');

}

function doAction()
{
	//checkRegistros();
}
function checkRegistros()
{
		var size = parseInt(eval('document.form3.ajusSize').value);
		var totalCheck = 0;
		for(i=0;i<size;i++)
		{
			if (eval('document.form3.check'+i).checked)
			totalCheck += 1;
		}
		document.getElementById("cont").value=totalCheck;
}

function verCheck(i)
{
	//checkRegistros();
	var size = parseInt(eval('document.form3.ajusSize').value);
	var cont = parseInt(eval('document.form3.cont').value);
	var totalCheck = 0;
	if(size>0)
	{
			if (eval('document.form3.check'+i).checked)
			document.getElementById("cont").value=cont+1;
			else document.getElementById("cont").value=cont-1;
			//totalCheck += 1;
			//else totalCheck -= 1;
		//document.getElementById("cont").value=cont+totalCheck;
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
			<tr class="TextRow02">
			  <td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
			  <td>&nbsp;</td>
			</tr>

	<tr>
  		<td>
   		 <table width="100%" cellpadding="1" cellspacing="0">

			<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("ajusSize",""+al.size())%>	
			<%=fb.hidden("mode",""+mode)%>		
			<%=fb.hidden("fg",""+fg)%>		

			<!--<tr class="TextHeader">
			  <td colspan="10" align="left">
				Ajustes por Actualizar 
				<br> Año : &nbsp;<%=fb.textBox("aniopla",anio,false,false,true,5)%>
				 &nbsp;&nbsp;&nbsp;
				Periodo : &nbsp;<%=fb.textBox("periodo",periodo,false,false,true,5)%>
				<br> Indique el AÑO/PERIODO en el cual desea 
				<br> que se vean reflejados los ajustes que 
				<br> seleecionará para Apicar  &nbsp; </td>
			</tr> -->
			
			<tr class="TextHeader">
			  <td colspan="9">
				<!--Reporte de Ajustes :
				 &nbsp; <%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:window.print()\"")%> 			 &nbsp;&nbsp;&nbsp;-->
				Actualización de Ajustes<%=(fg.trim().equals("AP"))?"":"(RECHAZAR)"%></td>
				<td  align="right"><%=fb.button("actualiza","Actualizar",true,false,null,null,"onClick=\"javascript:window.actualiza()\"")%> </td>
		    </tr>
			<!--<tr class="TextHeader">
			  <td colspan="10" align="left">
				Ultimo Año/Mes contable procesado :  
				<br> Año : &nbsp;<%=fb.textBox("ultanio","",false,false,true,5)%>
				 &nbsp;&nbsp;&nbsp;
				Periodo : &nbsp;<%=fb.textBox("ultmes","",false,false,true,5)%>
				&nbsp; No se pueden aplicar ajustes a meses contables PROCESADOS  &nbsp;  </td>
			</tr>-->
		 </table>
 		 </td>
	</tr>

	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
			<tr>
				<td>

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer" >
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel" onClick="javascript:verCheck()">
					<td width="95%">&nbsp;Selección</td>
					<td width="5%">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr id="panel4">
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				<tr class="TextHeader" align="center">
					<td width="07%">No.</td>
					<td width="10%">Cédula</td>
					<td width="25%">Nombre del Colaborador</td>
					<td width="10%">Monto Bruto</td>
					<td width="07%">Forma de Pago</td>
					<td width="07%">Imprimir?</td>
					<td width="07%">No. Cheque</td>
					<td width="07%">No. ACH</td>
					<td width="15%">Planilla a Ajustar</td>
					<td width="5%"><%=fb.checkbox("checkx","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this);checkRegistros();\"","Seleccionar todos los Ajustes. !")%></td>
				</tr>
 				 <%  
							for(int i=0; i<al.size(); i++)
							{
							key = al.get(i).toString();	
							CommonDataObject cdo3 = (CommonDataObject) al.get(i);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>		
			
				<%=fb.hidden("key"+i,cdo3.getColValue("key"))%> 
				<%=fb.hidden("fechaAj"+i,cdo3.getColValue("fecha"))%> 
				<%=fb.hidden("secuencia"+i,cdo3.getColValue("codigo"))%> 
				<%=fb.hidden("chequeCreado"+i,cdo3.getColValue("imprimir"))%>
				<%=fb.hidden("anio"+i,cdo3.getColValue("anio"))%>
				<%=fb.hidden("codPlanilla"+i,cdo3.getColValue("cod_planilla"))%>
				<%=fb.hidden("noPlanilla"+i,cdo3.getColValue("num_planilla"))%>
				<%=fb.hidden("noEmpleado"+i,cdo3.getColValue("numEmpleado"))%> 
				<%=fb.hidden("empId"+i,cdo3.getColValue("empId"))%> 
				<%=fb.hidden("remove"+i,"")%>
									
				<tr class="TextRow01">
					<td><%=cdo3.getColValue("numEmpleado")%></td>
					<td><%=cdo3.getColValue("cedula")%></td>
					<td><%=cdo3.getColValue("nombre")%></td>
					<td align="right"><%=cdo3.getColValue("montoBruto")%></td>
					<td align="center"><%=cdo3.getColValue("formaPago")%></td>
					<td align="center"><%=cdo3.getColValue("impreso")%></td>
					<td align="center"><%=cdo3.getColValue("cheque")%></td>
					<td align="right"><%=cdo3.getColValue("ach")%></td>
					<td align="left"><%=cdo3.getColValue("codigoPla")%></td>
					<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"onClick=\"javascript:verCheck("+i+")\"")%></td>
					
				</tr>		
				<%
				}
				%>
			</table>
		</td>
	</tr>
 	 
	<tr class="TextRow01">
      <td align="right">Total de Ajustes <%=(fg.trim().equals("AP"))?" Pendientes por Autorizar :":"para rechazar"%>	  
	   <%=fb.textBox("cant",""+al.size(),false,false,true,4)%> &nbsp;&nbsp;Total de Ajustes Seleccionados para <%=(fg.trim().equals("AP"))?" Autorizar :":" rechazar"%> : <%=fb.textBox("cont","0",false,false,true,4)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	  <% fb.appendJsValidation("if(error>0)doAction();"); %>	
		 
	<tr class="TextRow02">
          <td align="right">
            Opciones de Guardar:
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
            <%=fb.radio("saveOption","C",false,false,false)%>Cerrar
			 <%=fb.button("actualiza2","Actualizar",true,false,null,null,"onClick=\"javascript:window.actualiza()\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
<%=fb.formEnd(true)%>

<!-- =================  F O R M   E N D   H E R E   =============== -->
</table>
			</td>
		  </tr>
		</table>
	</td>
</tr>
</table>

<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
} //GET
else
{

String saveOption 	= request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction 		= request.getParameter("baction");
int keyAjSize		= Integer.parseInt(request.getParameter("ajusSize"));
String itemRemoved 	= "";

   al.clear();
   for(int a=0; a<keyAjSize; a++)
   { 
		CommonDataObject cdo = new CommonDataObject();
		if (request.getParameter("check"+a) != null)
		{
			cdo.addColValue("usuario",(String) session.getAttribute("_userName")); 
			cdo.addColValue("compania",compania); 
			cdo.addColValue("empId",request.getParameter("empId"+a));
			cdo.addColValue("noEmpleado",request.getParameter("noEmpleado"+a));
			cdo.addColValue("anio",request.getParameter("anio"+a));
			cdo.addColValue("codPlanilla",request.getParameter("codPlanilla"+a));
			cdo.addColValue("noPlanilla",request.getParameter("noPlanilla"+a));
			cdo.addColValue("secuencia",request.getParameter("secuencia"+a));
			//cdo.addColValue("periodo",request.getParameter("periodo"));
			if(fg.trim().equals("AP"))cdo.addColValue("actualizar","S");
			else if(fg.trim().equals("RE"))cdo.addColValue("actualizar","N");
			//cdo.addColValue("codPlanillaAjuste",request.getParameter("codPlanillaAjuste"+a));
			al.add(cdo);
		} 
		
  	}//End For
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ACEMgr.actualizarAjustes(al);
	ConMgr.clearAppCtx(null);
	
%> 
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ACEMgr.getErrCode().equals("1"))
{
%>
  alert('<%=ACEMgr.getErrMsg()%>');
<%
    if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/autoriza_trx.jsp"))
    {
%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/autoriza_trx.jsp")%>';
<%
    }
    else
    {
%>
  window.opener.location = '<%=request.getContextPath()%>/rhplanilla/autoriza_trx.jsp';
<%
    }

 if (saveOption.equalsIgnoreCase("O"))
  {
%>
    setTimeout('editMode()',500);
<%
  }
  else if (saveOption.equalsIgnoreCase("C"))
  {
%>
  window.close();
<%
  }
} else throw new Exception(ACEMgr.getErrMsg());
%>
}
function addMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&anio=<%=anio%>&planilla=<%=planilla%>&seccion=<%=seccion%>&periodo=<%=periodo%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

