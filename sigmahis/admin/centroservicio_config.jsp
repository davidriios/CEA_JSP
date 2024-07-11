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
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String paramCitaAut = "N";
try {paramCitaAut =java.util.ResourceBundle.getBundle("issi").getString("auto.pram.cita");}catch(Exception e){ paramCitaAut = "N";}
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");

sql = "select decode(a.interfaz,'RIS','RIS','LIS','LIS','SEL','SELECIONAR','null','SELECIONAR',' ','SELECIONAR',a.interfaz) as interfaz,a.codigo, a.telefono, nvl(a.descripcion, ' ') descripcion, a.tipo_cds as tipo, a.fax,NVL(a.email,'CORREO@EMAIL.COM') as email, a.direccion, NVL(a.observacion,'NA') as observacion, a.reporta_a as administracion, a.compania_unorg,  a.extension, a.origen, a.reporta_a as reportar, a.si_no as admision, a.estado, a.usuario_creacion, a.usuario_modificacion, a.fecha_creacion, a.fecha_modificacion, a.liquidable_sino as liquidable, a.tipo_descuento as tipodesc, a.descuento, a.tipo_incremento as tipoincrem, a.incremento, a.tipo_cupon as tipocupon, a.cupon_desc as cupon, a.abreviatura, a.ruc, NVL(a.dv,'0') as dv, a.cuenta_bancaria as ctabancaria, a.ruta_transito as rutatransito, a.tipo_cuenta as tipocuenta, a.envia_solicitud as envia, a.recibe_solicitud as recibe, b.codigo as cot, nvl(b.descripcion,'NA') as nombre, c.codigo as cod, nvl(c.DESCRIPCION,'NA') as otro, a.cod_centro_sol_ris,a.cod_centro_sol_lis,a.sol_interfaz_ris,a.sol_interfaz_lis ,a.estado_admision admEstado, a.flag_cds, nvl(a.nombre_abreviado, '') nombre_abreviado, a.antibio_ctrl,nvl(a.nombre_corto,'') as nombre_corto,a.ord_cita,nvl(a.gen_cargo,'N')as gen_cargo,nvl(a.uso_cita,'N') as uso_cita, nvl(a.cita_interval,'') as cita_interval, nvl(to_char(a.cita_open_at,'hh12:mi am'),'') as cita_open_at, nvl(to_char(a.cita_close_at,'hh12:mi am'),'') as cita_close_at, nvl(a.usa_pos, 'N') usa_pos, a.permite_traslado from tbl_cds_centro_servicio a, tbl_sec_unidad_ejec b, tbl_cds_centro_servicio c where a.reporta_a=c.codigo(+) AND a.unidad_organi = b.codigo(+) and a.codigo="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Centro de Servicio Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Centro de Servicio Edición - "+document.title;
<%}%>
</script>
<script language="javascript">
function niveles(){abrir_ventana1('../admin/list_reportar.jsp?fp=centroser');}
function nibel(){abrir_ventana1('../admin/list_reportar.jsp');}
function unidades(){abrir_ventana1('../admin/list_unidad.jsp');}
function checkCentro()
{
document.getElementById("cod_centro_sol_lis").value=''
/*
if(interfaz !='')
{

		document.getElementById("lb_cod_centro").style.visibility = "hidden";
		document.getElementById("lb_cod_centro").style.height = "1";
		document.getElementById("lb_cod_centro").style.display = "none";
}
else
{
		document.getElementById("lb_cod_centro").style.visibility = "visible";
		document.getElementById("lb_cod_centro").style.height = "auto";
		document.getElementById("lb_cod_centro").style.display = "";
}*/
}
function checkCentro2()
{
document.getElementById("cod_centro_sol_ris").value=''
}

$(document).ready(function(r){
	$("#save").click(function(c){
		 var _proceed = true;

	 var citaInterval = $.trim($("#cita_interval").val());
	 var citaOpenAt   = $.trim($("#cita_open_at").val());
	 var citaCloseAt  = $.trim($("#cita_close_at").val());

	 var citaIntervalT = $.trim($("#cita_interval_t").val());
	 var citaOpenAtT   = $.trim($("#cita_open_at_t").val());
	 var citaCloseAtT  = $.trim($("#cita_close_at_t").val());

	 if ( citaOpenAt  && citaCloseAt && !hasDBData('<%=request.getContextPath()%>',"(select case when to_date('"+citaOpenAt+"','hh12:mi am') >= to_date('"+citaCloseAt+"','hh12:mi am') then null  else '1' end b from dual)",'b is not null','') ) {alert("Parece que esta tratando de crear un horario inválido.");_proceed = false;}
		 if (_proceed == true) $("#form1").submit();
	});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%">
	<div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>

	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
 <tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TGenerales" align="left" width="100%"  onClick="javascript:verocultar(panel0)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TGenerales');" onMouseout="bcolor('#8f9ba9','TGenerales');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;<cellbytelabel>Generales de Centro de Servicio</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel0" style="visibility:visible;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
						<tr class="TextRow01">
							<td width="17%"><cellbytelabel>Nombre</cellbytelabel></td>



							<td width="33%"><%= (mode.equals("add")) ? fb.intBox("codigo","00",true,true,true,10) : fb.intBox("codigo",cdo.getColValue("codigo"),true,mode.equals("edit"),true,10)%><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,mode.equals("edit"),false,28)%><%//=fb.button("report","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:niveles();\"")%></td>
							<td width="15%"><cellbytelabel>Tipo</cellbytelabel></td>
							<td width="35%"><%=fb.select("tipo","I=Interno,E=Externo,T=Tercero",cdo.getColValue("tipo"))%></td>
						</tr>
						<tr class="TextRow01">
							<td><cellbytelabel>Tipo Or&iacute;gen</cellbytelabel></td>
							<td><%=fb.select("origen","C=Centro Servicio,S=Sala / Sección,A=Área,O=Otro",cdo.getColValue("origen"))%></td>
							<td><cellbytelabel>Estado</cellbytelabel></td>
							<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
						</tr>
						<tr class="TextRow01" >
							<td colspan="2">&Aacute;rea de Admisi&oacute;n?(Hospital o Ambulatorio) <%=fb.select("admision","S=Si ,N=No",cdo.getColValue("admision"))%>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							Traslado:<%=fb.select("permite_traslado","N=No,Y=Si",cdo.getColValue("permite_traslado"))%>
							</td>
							<td>Liquidable</td>
							<td><%=fb.select("liquidable","S=Si ,N=No",cdo.getColValue("liquidable"))%></td>
						</tr>
						<tr class="TextRow01">
							<td><cellbytelabel>Reportar A</cellbytelabel></td>
							<td><%=fb.intBox("reportar",cdo.getColValue("reportar"),false,false,true,10)%>
							<%=fb.textBox("otro",cdo.getColValue("otro"),false,false,true,28)%>
							<%=fb.button("report","...",true,false,null,null,"onClick=\"javascript:nibel();\"")%></td>							<td>Direcci&oacute;n</td>
							<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,40)%></td>
						</tr>

						<tr class="TextRow01">
							<td><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
							<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,40)%></td>
							<td>Fax</td>
							<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,20)%>&nbsp;Extensi&oacuten&nbsp;<%=fb.textBox("extension",cdo.getColValue("extension"),false,false,false,5)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Email</td>
							<td><%=fb.emailBox("email",cdo.getColValue("email"),false,false,false,40)%></td>
							<td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
							<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,30,2)%></td>
						 </tr>
						 <tr class="TextRow01">
	<td><cellbytelabel>Unidad Administrativa</cellbytelabel>&nbsp;&nbsp;</td>
	<td><%=fb.intBox("administracion",cdo.getColValue("cot"),true,false,true,10)%><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,true,28)%><%=fb.button("report","...",true,false,null,null,"onClick=\"javascript:unidades();\"")%></td>

							<td>Interfaz</td>
									<td><%=fb.select("interfaz","RIS=RIS,LIS=LIS,BDS=BDS",cdo.getColValue("interfaz"),false,false,0,"","","","","S")%></td>
						</tr>
						<tr class="TextRow01">
							 <td colspan="2"><cellbytelabel>Estado Admision</cellbytelabel>&nbsp;<%=fb.select("admEstado","A=ACTIVA,I=INACTIVA,E=EN ESPERA,S=ESPECIAL",cdo.getColValue("admEstado"))%></td>

							 <td>Flag CDS</td>
							 <td><%=fb.select("flag_cds","LAB=LABORATORIO,IMA=IMAGENOLOGIA,SOP=SALON OP,HEM=HEMODINAMICA,ENDO=ENDOSCOPIA,SAL=SALAS,ICU=INTENSIVO ADULTO,CUI=INTENSIVO PED.,CU=CUARTO URG.,CEX=CONSULTAS EXTERNAS",cdo.getColValue("flag_cds"),false,false,0,"","","","","S")%>
							 <%//=fb.textBox("flag_cds",cdo.getColValue("flag_cds"),false,false,(UserDet.getUserProfile().contains("0")),4)%>
							 </td>

						 </tr>
						<tr class="TextRow01">
							<td colspan="4">
							<div id="lb_cod_centro" name="lb_cod_centro">
								<table width="100%">
											<tr class="TextRow01">
								 <td width="25%" rowspan="2"><cellbytelabel>Solicita por Interfaz</cellbytelabel>??</td>
								 <td width="10%"><%=fb.select("sol_interfaz_lis","LIS=LIS",cdo.getColValue("sol_interfaz_lis"),false,false,0,"","","onChange=\"javascript:checkCentro();\"","","S")%>
								 </td>
								 <td width="30%"><cellbytelabel>Centro que Procesa Solicitud</cellbytelabel></td>
								 <td width="35%"><%=fb.select(ConMgr.getConnection(),"select a.codigo,  a.descripcion||' - '||a.codigo, a.codigo FROM tbl_cds_centro_servicio a where interfaz in ('LIS')","cod_centro_sol_lis",cdo.getColValue("cod_centro_sol_lis"),false,false,0,"Text10",null,null,"","S")%>

								 </td>
								</tr>
								<tr class="TextRow01">
								 <td width="10%"><%=fb.select("sol_interfaz_ris","RIS=RIS",cdo.getColValue("sol_interfaz_ris"),false,false,0,"","","onChange=\"javascript:checkCentro2();\"","","S")%>



								 <%//=fb.select("sol_interfaz_ris","RIS=RIS",cdo.getColValue("sol_interfaz_ris"),false,false,0,"","","","","S")%>

								 </td>
								 <td width="30%"><cellbytelabel>Centro que Procesa Solicitud</cellbytelabel></td>
								 <td width="35%"><%=fb.select(ConMgr.getConnection(),"select a.codigo,  a.descripcion||' - '||a.codigo, a.codigo FROM tbl_cds_centro_servicio a where interfaz in ('RIS')","cod_centro_sol_ris",cdo.getColValue("cod_centro_sol_ris"),false,false,0,"Text10",null,null,"","S")%>

								 </td>
								</tr>
							</table>
							</div>
							</td>
						</tr>

						</table>
					 </div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TOtros" align="left" width="100%" onClick="javascript:verocultar(panel1)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TOtros');" onMouseout="bcolor('#8f9ba9','TOtros');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel1" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="20%"><cellbytelabel>Descuento</cellbytelabel></td>
								<td width="30%"><%=fb.select("tipodesc","M=Monetario, P=Porcentual",cdo.getColValue("tipodesc"))%>&nbsp;&nbsp;&nbsp;Monto&nbsp;<%=fb.decBox("descuento",cdo.getColValue("descuento"),false,false,false,10)%></td>
								<td width="15%"><cellbytelabel>Incremento</cellbytelabel></td>
								<td width="35%"><%=fb.select("tipoincrem","M=Monetario,P=Porcentual",cdo.getColValue("tipoincrem"))%>&nbsp;&nbsp;&nbsp;Monto&nbsp;<%=fb.decBox("incremento",cdo.getColValue("incremento"),false,false,false,10)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Cup&oacute;n de Descuento</cellbytelabel></td>
								<td><%=fb.select("tipocupon","M=Monetario, P=Porcentual",cdo.getColValue("tipocupon"))%>&nbsp;&nbsp;&nbsp;<cellbytelabel>Monto</cellbytelabel>&nbsp;<%=fb.decBox("cupon",cdo.getColValue("cupon"),false,false,false,10)%></td>
								<td><cellbytelabel>Expediente Cl&iacute;nico</cellbytelabel></td>
								<td><cellbytelabel>Envia Solicitud de Examen</cellbytelabel>&nbsp;
<%=fb.checkbox("envia","S",(cdo.getColValue("envia") != null && cdo.getColValue("envia").equalsIgnoreCase("S")),false)%><br>
Recibe Solicitud de Examen&nbsp;<%=fb.checkbox("recibe","S",(cdo.getColValue("recibe") != null && cdo.getColValue("recibe").equalsIgnoreCase("S")),false)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Requisici&oacute;n Genera Cargos</cellbytelabel>?</td>
								<td><%=fb.select("genera_cargo_auto","0=No, 1=Opcional, 2=Si",cdo.getColValue("genera_cargo_auto"))%></td>
								<td>&nbsp;</td>
								<td>Controlado?&nbsp;<%=fb.checkbox("controlado","N",(cdo.getColValue("antibio_ctrl") != null && cdo.getColValue("antibio_ctrl").equalsIgnoreCase("S")),false,null,null,null,"Sirve para saber si el centro esta controlado (antibióticos).")%></td>
							</tr>
							<%--<tr class="TextRow01">
								<td>&nbsp;Procedimientos</td>
								<td><%//=fb.button("procedimientos","Procedimientos",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
								<td>&nbsp;Producto</td>
								<td><%//=fb.button("productos","Productos",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
							</tr>	--%>
						</table>
					</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="Tctas" align="left" width="100%"  onClick="javascript:verocultar(panel2)" style=" background-color:#770000; border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#770000','Tctas');" onMouseout="bcolor('#770000','Tctas');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel" height="25">
								<td width="98%">&nbsp;</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;" color="#FFFFFF">[+]</font>&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<div id="panel2" style="display:inline">
						<table width="100%" cellpadding="1" cellspacing="1" border="1" bordercolor="d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="20%"><cellbytelabel>Abreviatura</cellbytelabel></td>
								<td width="30%"><%=fb.textBox("abreviatura",cdo.getColValue("abreviatura"),false,false,false,25)%></td>
								<td width="20%"><cellbytelabel>Ruc</cellbytelabel></td>
								<td width="30%"><%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,false,15)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Dv</cellbytelabel></td>
								<td><%=fb.intBox("dv",cdo.getColValue("dv"),false,false,false,10)%></td>
								<td><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
								<td><%=fb.textBox("ctabancaria",cdo.getColValue("ctabancaria"),false,false,false,15)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Ruta de Transito</cellbytelabel></td>
								<td><%=fb.textBox("rutatransito",cdo.getColValue("rutatransito"),false,false,false,25)%> </td>
								<td><cellbytelabel>Tipo de cuenta</cellbytelabel></td>
								<td><%=fb.textBox("tipocuenta",cdo.getColValue("tipocuenta"),false,false,false,15)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Abreviatura DGI Centros Terceros</cellbytelabel></td>
								<td><%=fb.textBox("nombre_abreviado",cdo.getColValue("nombre_abreviado"),false,false,false,4,4)%> </td>
								<td>Usa POS?</td>
								<td><%=fb.select("usa_pos","N=NO,S=SI",cdo.getColValue("usa_pos"))%></td>
							</tr>
							<%if(paramCitaAut.trim().equals("S")){%>
							<tr class="TextHeader01">
								<td colspan="4">PARAMETROS PARA USO DE CENTROS - CITAS</td>
							</tr>
							<tr class="TextRow01">
								<td>Mostrar en Citas</td>
								<td><%=fb.select("uso_cita","N=NO,S=SI",cdo.getColValue("uso_cita"))%></td>
								<td><cellbytelabel>Genera cargos (Citas)</cellbytelabel></td>
								<td><%=fb.select("gen_cargo","N=NO,S=SI",cdo.getColValue("gen_cargo"))%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Nombre Corto(Citas)</cellbytelabel></td>
								<td><%=fb.textBox("nombre_corto",cdo.getColValue("nombre_corto"),false,false,false,4,4)%> </td>
								<td>Orden de Despliegue</td>
								<td><%=fb.intBox("ord_cita",cdo.getColValue("ord_cita"),false,false,false,5,5)%></td>
							</tr>
								<%}%>

							<tr class="TextHeader01">
								<td colspan="4">INT&Eacute;VALO Y HORARIO DE CITA</td>
							</tr>

							<tr class="TextRow01">
								<td colspan="4">Int&eacute;rvalo
									 <%=fb.hidden("cita_interval_t",cdo.getColValue("cita_interval"))%>
									 <%=fb.hidden("cita_open_at_t",cdo.getColValue("cita_open_at"))%>
									 <%=fb.hidden("cita_close_at_t",cdo.getColValue("cita_close_at"))%>

									 <%=fb.intBox("cita_interval",cdo.getColValue("cita_interval"),false,false,false,5,2)%>&nbsp;min(s)
									 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										Atiende
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2" />
										<jsp:param name="nameOfTBox1" value="cita_open_at" />
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("cita_open_at")==null?"":cdo.getColValue("cita_open_at")%>" />
										<jsp:param name="nameOfTBox2" value="cita_close_at" />
										<jsp:param name="valueOfTBox2" value="<%=cdo.getColValue("cita_close_at")==null?"":cdo.getColValue("cita_close_at")%>" />
										<jsp:param name="format" value="hh12:mi am" />
										<jsp:param name="fromLbl" value="De" />
										<jsp:param name="toLbl" value="A" />
									</jsp:include>
								</td>
							</tr>
						</table>
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="TextRow02">
		<td align="right"><%=fb.button("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
<%=fb.formEnd(true)%>
</table>
	</td>
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

	cdo.setTableName("tbl_cds_centro_servicio");
	cdo.addColValue("telefono",request.getParameter("telefono"));
	cdo.addColValue("tipo_cds",request.getParameter("tipo"));
	cdo.addColValue("fax",request.getParameter("fax"));
	cdo.addColValue("email",request.getParameter("email"));
	cdo.addColValue("direccion",request.getParameter("direccion"));
	if (request.getParameter("observacion") != null)
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("unidad_organi",request.getParameter("administracion"));
	cdo.addColValue("extension",request.getParameter("extension"));
	cdo.addColValue("origen",request.getParameter("origen"));
	if (request.getParameter("reportar") != null)
	cdo.addColValue("reporta_a",request.getParameter("reportar"));
	cdo.addColValue("si_no",request.getParameter("admision"));
	cdo.addColValue("estado",request.getParameter("estado"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
		cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("liquidable_sino",request.getParameter("liquidable"));
	cdo.addColValue("tipo_descuento",request.getParameter("tipodesc"));
	if (request.getParameter("descuento") != null)
	cdo.addColValue("descuento",request.getParameter("descuento"));
	cdo.addColValue("tipo_incremento",request.getParameter("tipoincrem"));
	if (request.getParameter("incremento") != null)
	cdo.addColValue("incremento",request.getParameter("incremento"));
	cdo.addColValue("tipo_cupon",request.getParameter("tipocupon"));
		if (request.getParameter("cupon") != null)
	cdo.addColValue("cupon_desc",request.getParameter("cupon"));
	cdo.addColValue("abreviatura",request.getParameter("abreviatura"));
	cdo.addColValue("ruc",request.getParameter("ruc"));
	if (request.getParameter("dv") != null)
	cdo.addColValue("dv",request.getParameter("dv"));
	cdo.addColValue("cuenta_bancaria",request.getParameter("ctabancaria"));
	cdo.addColValue("ruta_transito",request.getParameter("rutatransito"));
	cdo.addColValue("tipo_cuenta",request.getParameter("tipocuenta"));
	if (request.getParameter("envia") == null) cdo.addColValue("envia_solicitud","N");
	else cdo.addColValue("envia_solicitud",request.getParameter("envia"));
	if (request.getParameter("recibe") == null) cdo.addColValue("recibe_solicitud","N");
	else cdo.addColValue("recibe_solicitud",request.getParameter("recibe"));
	cdo.addColValue("estado_admision",request.getParameter("admEstado"));
	cdo.addColValue("interfaz",request.getParameter("interfaz"));
	cdo.addColValue("genera_cargo_auto",request.getParameter("genera_cargo_auto"));
	if(request.getParameter("nombre_abreviado")!=null) cdo.addColValue("nombre_abreviado",request.getParameter("nombre_abreviado"));

	cdo.addColValue("sol_interfaz_ris",request.getParameter("sol_interfaz_ris"));
	cdo.addColValue("cod_centro_sol_ris",request.getParameter("cod_centro_sol_ris"));
	cdo.addColValue("sol_interfaz_lis",request.getParameter("sol_interfaz_lis"));
	cdo.addColValue("cod_centro_sol_lis",request.getParameter("cod_centro_sol_lis"));
	if(request.getParameter("flag_cds")!=null && !request.getParameter("flag_cds").equals(""))cdo.addColValue("flag_cds",request.getParameter("flag_cds"));
	else cdo.addColValue("flag_cds","");

	if (request.getParameter("controlado") != null){
			cdo.addColValue("antibio_ctrl","S");
	}else{cdo.addColValue("antibio_ctrl","N");}

	if(request.getParameter("uso_cita")!=null) cdo.addColValue("uso_cita",request.getParameter("uso_cita"));
	if(request.getParameter("ord_cita")!=null) cdo.addColValue("ord_cita",request.getParameter("ord_cita"));
	if(request.getParameter("gen_cargo")!=null) cdo.addColValue("gen_cargo",request.getParameter("gen_cargo"));
	if(request.getParameter("nombre_corto")!=null) cdo.addColValue("nombre_corto",request.getParameter("nombre_corto"));

	if(request.getParameter("cita_interval").trim()!=null) cdo.addColValue("cita_interval",request.getParameter("cita_interval"));
	if(request.getParameter("cita_open_at").trim()!=null) cdo.addColValue("cita_open_at",request.getParameter("cita_open_at"));
	if(request.getParameter("cita_close_at").trim()!=null) cdo.addColValue("cita_close_at",request.getParameter("cita_close_at"));

	cdo.addColValue("permite_traslado",request.getParameter("permite_traslado"));


	cdo.addColValue("usa_pos",request.getParameter("usa_pos"));
	cdo.setCreateXML(true);
	cdo.setFileName("cds_all.xml");
	cdo.setOptValueColumn("codigo");
	cdo.setOptLabelColumn("codigo||' - '||descripcion");
	cdo.setKeyColumn("compania_unorg");
	cdo.setXmlWhereClause("estado = 'A'");
	cdo.setXmlOrderBy("descripcion");

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("descripcion",request.getParameter("descripcion"));
		cdo.addColValue("compania_unorg",(String) session.getAttribute("_companyId"));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
		cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.setAutoIncCol("codigo");

		SQLMgr.insert(cdo);
	}
	else
	{
				cdo.setWhereClause("compania_unorg="+(String) session.getAttribute("_companyId")+" and codigo="+request.getParameter("id"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/centro_servicio_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/centro_servicio_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/centro_servicio_list.jsp';
<%
	}
%>
	//window.opener.location.reload(true);
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