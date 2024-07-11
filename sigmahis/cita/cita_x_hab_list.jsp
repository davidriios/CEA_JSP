<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr"	scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr"	scope="session" class="issi.admin.SecurityMgr"	/>
<jsp:useBean id="UserDet"	scope="session" class="issi.admin.UserDetail"	/>
<jsp:useBean id="CmnMgr"	scope="page"	class="issi.admin.CommonMgr"	/>
<jsp:useBean id="SQLMgr"	scope="page"	class="issi.admin.SQLMgr"		/>
<jsp:useBean id="fb"		scope="page"	class="issi.admin.FormBean"		/>
<%
/**
======================================================================================================================================================
FORMA							MENU																																										NOMBRE EN FORMA
CDC100100					CITAS\TRANSACCIONES\CRONOGRAMA DE QUIROFANOS																						SALON DE OPERACIONES PROGRAMA QUIRURGICO
Cuando se edita llama a la forma CDC100010
CDC100100_CONV7		INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS	SOP- CONSULTA DE PROGRAMA QUIRURGICO	
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

String fechaCita = CmnMgr.getCurrentDate("dd/mm/yyyy"); 
if (request.getParameter("fechaCita")!= null) fechaCita = request.getParameter("fechaCita");
String habitacion = "1";
if(request.getParameter("habitacion")!=null) habitacion = request.getParameter("habitacion");
String fg = "SO";
int iconHeight = 48;
int iconWidth = 48;
int contTrx = CmnMgr.getCount("select count(*) cont from tbl_cdc_solicitud_trx where trx_estado = 'P'");

if(request.getParameter("fg")!=null) fg = request.getParameter("fg");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function goOption(option)
{
	//var k=document.frmSearch.index.value;

	var fechaCita = document.frmSearch.fechaRegistro.value;
	var codCita = document.frmSearch.codCita.value;
	var habitacion = document.frmSearch.habitacion.value;
	var existe = 'N';
	if((fechaCita == '' || codCita == '') && option!=3 && option!=4)alert('Por favor una Cita!');
	else if(option==3){
		if(habitacion=='') alert('Seleccione Habitación');
		else abrir_ventana('../cita/reg_cita.jsp?mode=add&habitacion='+habitacion);
	} else if(option==4){
		var fechaCita = document.frmSearch.fechaCita.value;
		abrir_ventana('../cita/print_citas_quirofano.jsp?fechaCita='+fechaCita);
		//abrir_ventana('../inventario/print_cdc_programa.jsp?fecha='+fechaCita);
	} else {
		if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
		else if(option==0 || option == 2){
			var tipoSolicitud = 'Q';
			if(option == 2) tipoSolicitud = 'A';
			var estado=getDBData('<%=request.getContextPath()%>','estado','tbl_cdc_solicitud_enc','cita_codigo = ' + codCita + ' and to_date(to_char(cita_fecha_reg, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+ fechaCita + '\', \'dd/mm/yyyy\') and tipo_solicitud = \'' + tipoSolicitud + '\'','');
			if(estado!='') existe = 'S';
			if(existe=='N' || (existe=='S' && estado =='P')) abrir_ventana('../facturacion/reg_cargo_dev_so.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaCita+'&tipoSolicitud='+tipoSolicitud);
			else {
				if(estado=='E') alert('La solicitud QUIRURGICA ya fue CERRADA!!!');
				else if(estado=='A') alert('La solicitud QUIRURGICA fue ANULADA!!!');
				else if(estado=='T'){
					abrir_ventana('../facturacion/reg_cargo_dev_so_2.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaCita+'&tipoSolicitud=Q&estadoCita='+estado);
				}
			}
		}
		else
		{
			
			if(fechaCita == '' || codCita == '')alert('Por favor una Cita!');
			else
			{
				var msg='';
				//var estado=eval('document.result.estado'+k).value;
	
				if(option==1)abrir_ventana('../admision/admision_config.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);
				else if(option==2)abrir_ventana('../admision/print_admision.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);
			}//admision selected
		}//valid option
	}
}

function mouseOver(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  var msg='&nbsp;';
  switch(option)
  {
    case 0:msg='Solicitud Insumos Quirúrgicos';break;
    case 1:msg='Imprimir Detalles de Cargos';break;
    case 2:msg='Solicitud Insumos Anestesia';break;
    case 3:msg='Agregar Cita';break;
		case 4:msg='Imprimir Programa Quirúrgico';break;
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

function solTrx(){
	var fechaCita = document.frmSearch.fechaCita.value;
	abrir_ventana1('../facturacion/cdc_trx_pendientes.jsp?fp=quirofano&fg=<%=fg%>&fechaCita='+fechaCita);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="QUIROFANO - LISTA"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0" style="BORDER-RIGHT: #c1dad7 1px solid; BORDER-TOP: #c1dad7 1px solid; TEXT-TRANSFORM: uppercase; COLOR: #4f6b72; BORDER-BOTTOM: #c1dad7 1px solid; LETTER-SPACING: 2px;  TEXT-ALIGN: left;">		
<%fb = new FormBean("frmSearch",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>		
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fechaRegistro","")%>
<%=fb.hidden("codCita","")%>
  <tr>
    <td align="right">
      <div id="optDesc" class="TextInfo Text10">&nbsp;</div>
      <%if(fg.equalsIgnoreCase("inv")){%>
      <authtype type='50'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/surgical.gif"></a></authtype>
      <!--<a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/print-shopping-cart.gif"></a>-->
      <authtype type='51'><a href="javascript:goOption(2);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/anestesia.gif"></a></authtype>
      <%} else if(fg.equalsIgnoreCase("SO")){%>
      <!--<a href="javascript:goOption(3);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/appointment.gif"></a>-->
      <authtype type='52'><a href="javascript:goOption(4);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/print_surgical_appointment.gif"></a></authtype>
      <%}%>
    </td>
  </tr> 
<tr>
	<td width="100%"><cellbytelabel>Habitaci&oacute;n</cellbytelabel>
	<%=fb.select(ConMgr.getConnection(), "select codigo, nvl(descripcion,' ') descripcion from tbl_sal_habitacion where /*unidad_admin = 11*/  compania = "+(String) session.getAttribute("_companyId")+" and quirofano=2", "habitacion", habitacion, false, false, 0, "Text10", "", "")%> &nbsp;
  Fecha&nbsp;
	<jsp:include page="../common/calendar.jsp" flush="true">
    <jsp:param name="noOfDateTBox" value="1" />
    <jsp:param name="nameOfTBox1" value="fechaCita" />
    <jsp:param name="valueOfTBox1" value="<%=fechaCita%>" />
    </jsp:include>
	<%=fb.submit("btnver", "Ir", true, false, "", "", "")%>&nbsp;
	<img src="../images/lampara_amarilla.gif" alt="Reservada"> <cellbytelabel>RESERVADA</cellbytelabel>
  <img src="../images/lampara_verde.gif" alt="Realizada"> <cellbytelabel>REALIZADA</cellbytelabel>
  <authtype type='53'><a href="javascript:solTrx()"><font class="Link05Bold"> <%=(contTrx>0?""+contTrx+" solicitud(es) pendientes(s)!!!":"")%> </font> </a></authtype>
  </td>
</tr>
<%=fb.formEnd()%>	
</table>

<iframe name="ifRooms" id="ifRooms" src="cita_x_hab_det.jsp?fechaCita=<%=fechaCita%>&habitacion=<%=habitacion%>&fg=<%=fg%>" width="100%" height="440" allowtransparency scrolling="auto"></iframe>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>