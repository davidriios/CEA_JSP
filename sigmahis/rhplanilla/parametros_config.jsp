<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%//@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Parametros"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="ParMgr" scope="page" class="issi.rhplanilla.ParametrosMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

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
//SQLMgr.setConnection(ConMgr);
ParMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al= new ArrayList();
Parametros param= new Parametros();	
String sql="";
String mode=request.getParameter("mode");
String compId=request.getParameter("compId");


if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		//id = "0";
		
	}
	else
	{ if (compId == null) throw new Exception("La Compañía no es válido. Por favor intente nuevamente!");
	
sql = "select a.estado, a.tipo_reg as tipo, a.reg_control as control, a.correlativo, a.seg_soc_emp as seguroSEmpleado,a.seg_edu_emp as seguroEEmpleado, a.seg_soc_pat as seguroSPatrono, a.seg_edu_pat as seguroEPatrono, a.riesgo_pro_pat as riesgo,a.salario_limite as salarioLimite, a.valor_dependiente as valorDependiente, a.comprob_compromiso as compromiso, a.comprob_pago as compromisoPago, a.comprob_patronal as compromisoPatronal, a.cod_banco as codigoBanco, a.cuenta_bancaria as ctaBancaria, a.cod_compania as compania, a.prima_antig as primaAntig,a.porc_endeudamiento as endeudamiento, a.valor_alto_riesgo as valorRiesgo, a.gr_porc_no_renta as porcentajeNoRenta, a.gr_limite_no_renta as limiteNoRenta, to_char(a.fecha_limite_aguinaldo, 'dd/mm/yyyy') as fechaLimite, a.no_comprobante as comprobante, a.seg_soc_grep_pat as segurogast, a.seg_soc_grep_pat as seguroSGPatrono, a.seg_soc_grep_emp as seguroSGEmpleado, a.gr_porc_no_ssocial as porcentajeNoSocial, a.ssoc_xiiim_emp as socialDecimoEmpleado, a.ssoc_xiiim_pat as socialDecimoPatrono, a.ssoc_xiiim_gasto_emp as socialGastoEmpleado, a.ssoc_xiiim_gasto_pat as socialGastoPatrono,a.cod_compania as cod, (select nombre from tbl_sec_compania where codigo=a.cod_compania)  as nombreCompania,x.acreedorId, x.grupoId,x.descuentoMensual, x.frecuenciaDesc, x.cot, x.nombreGrupo, x.acredor, x.nombreAcreedor,nvl(reserva_vac,0) as reservaVac,nvl(reserva_dec,0) as reservaDec,nvl(reserva_indem,0) as reservaIndem,nvl(reserva_riesgo,0) as reservaRiesgo,nvl(other1,0)as others1,nvl(other2,0) as others2, nvl(other3,'') as other3,nvl(other4,'')  as other4 from TBL_PLA_PARAMETROS a,(select b.cod_compania compania,b.cod_acreedor as acreedorId, b.cod_grupo as grupoId,b.descuento_mensual as descuentoMensual, b.frecuencia_descuento as frecuenciaDesc, c.cod_grupo as cot, c.nombre as nombreGrupo, d.cod_acreedor as acredor, d.nombre as nombreAcreedor from tbl_pla_parametros_desctos b, tbl_pla_grupo_descuento c,tbl_pla_acreedor d where b.cod_acreedor= d.cod_acreedor and b.cod_compania=d.compania and b.cod_grupo=c.cod_grupo  ) x where  a.cod_compania = x.compania(+) and a.cod_compania="+compId;

System.out.println(sql);

		param = (Parametros) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Parametros.class);

	}

%>
<html> 
<head>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
<%if(mode.equals("add")){%>
document.title="Parámetros Agregar - "+document.title;
<%}else if(mode.equals("edit")){%>
document.title="Parámetros Editar - "+document.title;
<%}%>
function acredores()
{
abrir_ventana1('../common/search_acreedor.jsp?fp=parametros');
}

function grupo()
{
abrir_ventana1('../rhplanilla/lista_grupo.jsp');
}

function company()
{
abrir_ventana1('../rhplanilla/list_compania.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PARÁMETROS DEL SISTEMA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%">
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("compId",compId)%>
<%=fb.hidden("other1",""+param.getOthers1())%>
<%=fb.hidden("other2",""+param.getOthers2())%>
<%=fb.hidden("other3",""+param.getOthers3())%>
<%=fb.hidden("other4",""+param.getOthers4())%>

	<tr>
		<td width="100%">&nbsp;</td>
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
							<tr class="TextHeader">
								<td width="98%">&nbsp;Par&aacute;metros</td>
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
							<td>&nbsp;Compa&ntilde;&iacute;a</td>
							<td colspan="3"><%=fb.intBox("compania",param.getCompania(),true,false,true,5,2)%>
							<%if(mode.equals("add")){%>
							<%=fb.textBox("nombreCompania",param.getNombreCompania(),false,false,true,25,50)%>
							<%=fb.button("btngrupo","...",true,false,null,null,"onClick=\"javascript:company();\"")%>							
							<%} else if(mode.equals("edit")){%>
							<%=fb.textBox("nombreCompania",param.getNombreCompania(),false,false,true,35,50)%>
							<%//=fb.button("btngrupo","...",true,false,null,null,"onClick=\"javascript:company();\"")%>
							<%}%>
							</td>
							<td>&nbsp;Estado de Par&aacute;metros</td>
							<td><%=fb.select("estado","A=Activo,I=Inactivo",param.getEstado())%></td>
						</tr>												
						<tr class="TextRow01">
							<td width="18%">&nbsp;Tipo Registro</td>
							<td width="8%"><%=fb.intBox("tipo",param.getTipo(),true,false,false,5,1)%></td>
							<td width="14%">&nbsp;Registro Control</td>
							<td width="14%"><%=fb.intBox("control",param.getControl(),true,false,false,5,1)%></td>
							<td width="27%">&nbsp;No. Correlativo</td>
							<td width="19%"><%=fb.intBox("correlativo",param.getCorrelativo(),true,false,false,15,5)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="6">&nbsp;Contabilidad</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Asiento Compromiso</td>
							<td><%=fb.intBox("compromiso",param.getCompromiso(),true,false,false,5,2)%></td>
							<td>&nbsp;Asiento Pago</td>
							<td><%=fb.intBox("compromisoPago",param.getCompromisoPago(),true,false,false,5,2)%></td>
							<td>&nbsp;Asiento Patronal</td>
							<td><%=fb.intBox("compromisoPatronal",param.getCompromisoPatronal(),true,false,false,5,2)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="6">Conciliaci&oacute;n</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;N&uacute;mero de Banco</td>
							<td><%=fb.textBox("codigoBanco",param.getCodigoBanco(),true,false,false,5,3)%></td>
							<td>&nbsp;No. Cuenta</td>
							<td><%=fb.textBox("ctaBancaria",param.getCtaBancaria(),true,false,false,15,16)%></td>
							<td>&nbsp;L&iacute;mite para pago Partic. Utilidades</td>
							<td>
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="fechaLimite" />
							<jsp:param name="valueOfTBox1" value="<%=param.getFechaLimite()%>" />
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
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPatronales" align="left" width="100%" onClick="javascript:verocultar(panel3)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TPatronales');" onMouseout="bcolor('#8f9ba9','TPatronales');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextHeader">
								<td width="98%">&nbsp;Cuotas Patronales</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel3" style="display:none">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
						<tr class="TextRow01">
							<td width="20%">&nbsp;</td>
							<td width="13%" align="center">XIIIM</td>
							<td width="67%">&nbsp;Salario</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Seguro Social</td>
							<td><%=fb.decBox("socialDecimoPatrono",param.getSocialDecimoPatrono(),true,false,false,10,6.2)%>&nbsp;%</td>
							<td><%=fb.decBox("seguroSPatrono",param.getSeguroSPatrono(),true,false,false,10,6.2)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Seguro Social - G.Rep:</td>
							<td><%=fb.decBox("socialGastoPatrono",param.getSocialGastoPatrono(),true,false,false,10,6.2)%>&nbsp;%</td>
							<td><%=fb.decBox("seguroSGPatrono",param.getSeguroSGPatrono(),true,false,false,10,6.2)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Seguro Educativo</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("seguroEPatrono",param.getSeguroEPatrono(),true,false,false,10,6.2)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Riesgo Profesional</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("riesgo",param.getRiesgo(),true,false,false,10,6.2)%>&nbsp;%</td>
						</tr>
						
						
						<tr class="TextHeader">
							<td colspan="3">&nbsp;Reservas</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Reserva Prima de Antiguedad</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("primaAntig",param.getPrimaAntig(),true,false,false,10,6.3)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Reserva Para Vacaciones</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("reservaVac",""+param.getReservaVac(),true,false,false,10,6.3)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Reserva Para Decimo</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("reservaDec",""+param.getReservaDec(),true,false,false,10,6.3)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Reserva de Indemnizacion</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("reservaIndem",""+param.getReservaIndem(),true,false,false,10,6.3)%>&nbsp;%</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Reserva de Riesgo Prof.</td>
							<td>&nbsp;</td>
							<td><%=fb.decBox("reservaRiesgo",""+param.getReservaRiesgo(),true,false,false,10,6.3)%>&nbsp;%</td>
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
							<tr class="TextHeader">
								<td width="98%">&nbsp;Empleado</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel1" style="display:none">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="25%">&nbsp;</td>
								<td width="13%" align="center">XIII Mes</td>
								<td width="62%">Salario</td>
							</tr>
							<tr class="TextRow01">
								<td>&nbsp;Seguro Social</td>
								<td><%=fb.decBox("socialDecimoEmpleado",param.getSocialDecimoEmpleado(),true,false,false,10,6.2)%>&nbsp;%</td>
								<td><%=fb.decBox("seguroSEmpleado",param.getSeguroSEmpleado(),true,false,false,10,6.2)%>&nbsp;%</td>
							</tr>
							<tr class="TextRow01">
								<td colspan="2">&nbsp;% Gasto Rep. Excento S.Social</td>
								<td><%=fb.decBox("porcentajeNoSocial",param.getPorcentajeNoSocial(),true,false,false,10,6.2)%>&nbsp;%</td>
							</tr>
							<tr class="TextRow01">
								<td>&nbsp;Seg. Social - G.Rep.</td>
								<td><%=fb.decBox("socialGastoEmpleado",param.getSocialGastoEmpleado(),true,false,false,10,6.2)%>&nbsp;</td>
								<td><%=fb.decBox("seguroSGEmpleado",param.getSeguroSGEmpleado(),true,false,false,10,6.2)%>&nbsp;%</td>
							</tr>
							<tr class="TextRow01">
								<td colspan="2">&nbsp;Seguro Educativo</td>
								<td><%=fb.decBox("seguroEEmpleado",param.getSeguroEEmpleado(),true,false,false,10,6.2)%>&nbsp;</td>
							</tr>
							<tr class="TextRow01">
								<td colspan="2">&nbsp;Valor x Dependiente</td>
								<td><%=fb.decBox("valorDependiente",param.getValorDependiente(),true,false,false,10,6.2)%></td>
							</tr>					
							<tr class="TextRow01">
								<td colspan="2">&nbsp;Salario Mín. Devengar</td>
								<td><%=fb.decBox("salarioLimite",param.getSalarioLimite(),true,false,false,10,6.2)%>
							</tr>
							<tr class="TextRow01">
								<td colspan="2">&nbsp;% de Endeudamiento Permitido</td>
								<td><%=fb.decBox("endeudamiento",param.getEndeudamiento(),true,false,false,10,6.2)%></td>
							</tr>
							<tr class="TextRow01">	
								<td colspan="2">&nbsp;Valor Mensual x Alto Riesgo</td>
								<td><%=fb.decBox("valorRiesgo", param.getValorRiesgo(),true,false,false,10,6.2)%></td>
							</tr>
							<tr class="TextRow01">
								<td colspan="2">&nbsp;% Gasto Rep. Excento Renta</td>
								<td><%=fb.decBox("porcentajeNoRenta",param.getPorcentajeNoRenta(),true,false,false,10,6.2)%>&nbsp;%</td>
							</tr>
							<tr class="TextRow01">
								<td>&nbsp;L&iacute;mite Gasto Rep. Excento Renta</td>
								<td>&nbsp;</td>
								<td><%=fb.decBox("limiteNoRenta",param.getLimiteNoRenta(),true,false,false,10,6.2)%>&nbsp;%</td>
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
					<td id="TDescuentos" align="left" width="100%" onClick="javascript:verocultar(panel2)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TDescuentos');" onMouseout="bcolor('#8f9ba9','TDescuentos');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextHeader">
								<td width="98%">&nbsp;Descuentos a Crear Para Empleados de Nuevo Ingreso</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel2" style="display:none">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextHeader">
								<td width="30%" align="center">&nbsp;Acreedor</td>
								<td width="30%" align="center">&nbsp;Grupo de Descuento</td>
								<td width="20%" align="center">&nbsp;Monto Desc. Mensual</td>
								<td width="18%" align="center">&nbsp;Frecuencia del Descuento</td>
								<td width="02%"><%=fb.submit("btnagregar","+",false,false)%></td>
							</tr>
							
							<tr class="TextRow01">
							<td>
								<%=fb.intBox("acreedorId",param.getAcreedorId(),false,false,true,5,3)%>
								<%=fb.textBox("nombreAcreedor",param.getNombreAcreedor(),false,false,true,20)%>
								<%if(mode.equals("add")){%>
								<%=fb.button("btnacredor","...",true,false,null,null,"onClick=\"javascript:acredores();\"")%>
								<%} else if(mode.equals("edit")){%>
								&nbsp;
								<%}%>
								</td>
							
								<td>
								<%=fb.intBox("grupoId",param.getGrupoId(),false,false,true,5,2)%>
								<%=fb.textBox("nombreGrupo",param.getNombreGrupo(),false,false,true,20)%>
								<%if(mode.equals("add")){%>
								<%=fb.button("btngrupo","...",true,false,null,null,"onClick=\"javascript:grupo();\"")%>				
								<%} else if(mode.equals("edit")){%>
								&nbsp;
								<%}%>
								</td>
							
								<td><%=fb.intBox("descuentoMensual",param.getDescuentoMensual(),false,false,false,10,5)%></td>
							
								<td>&nbsp;Frecuencia de Descuento</td>
								<td><%=fb.select("frecuenciaDesc","1=Primera Quincena,2=Segunda Quincena,3=Ambas", param.getFrecuenciaDesc())%>
							</tr>
						</table>						
					</div>
					</td>
				</tr>					
			</table>	
		</td>
	</tr>	
	<tr class="TextRow02">
		<td align="right"><%=fb.submit("save","Guardar",true,false)%>
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
    //cdo = new CommonDataObject();
   //cdo.setTableName("tbl_pla_parametros");
   //Parametros Param=new Parametros();
  param.setCodigoBanco(request.getParameter("codigoBanco")); 
  param.setCompromiso(request.getParameter("compromiso"));
  param.setCompromisoPago(request.getParameter("compromisoPago"));  
  param.setCompromisoPatronal(request.getParameter("compromisoPatronal"));  
  param.setCorrelativo(request.getParameter("correlativo"));  
  param.setCtaBancaria(request.getParameter("ctaBancaria"));  
  param.setEstado(request.getParameter("estado"));  
  param.setFechaLimite(request.getParameter("fechaLimite"));
  param.setLimiteNoRenta(request.getParameter("limiteNoRenta"));  
  param.setPorcentajeNoRenta(request.getParameter("porcentajeNoRenta"));
  param.setPorcentajeNoSocial(request.getParameter("porcentajeNoSocial"));  
 // Param.setComprobante(request.getParameter("other1"));
  param.setEndeudamiento(request.getParameter("endeudamiento"));
  param.setPrimaAntig(request.getParameter("primaAntig"));
  param.setControl(request.getParameter("control"));
  param.setRiesgo(request.getParameter("riesgo"));
  param.setSalarioLimite(request.getParameter("salarioLimite"));
  param.setSeguroEEmpleado(request.getParameter("seguroEEmpleado"));
  param.setSeguroEPatrono(request.getParameter("seguroEPatrono"));
  param.setSeguroSEmpleado(request.getParameter("seguroSEmpleado"));
  param.setSeguroSGEmpleado(request.getParameter("seguroSGEmpleado"));
  param.setSeguroSGPatrono(request.getParameter("seguroSGPatrono"));
  param.setSeguroSPatrono(request.getParameter("seguroSPatrono"));
  param.setSocialGastoEmpleado(request.getParameter("socialGastoEmpleado"));
  param.setSocialGastoPatrono(request.getParameter("socialGastoPatrono"));
  param.setSocialDecimoPatrono(request.getParameter("socialDecimoPatrono"));
  param.setSocialDecimoEmpleado(request.getParameter("socialDecimoEmpleado"));
  param.setTipo(request.getParameter("tipo"));
  param.setValorRiesgo(request.getParameter("valorRiesgo"));
  param.setUsuarioModif((String) session.getAttribute("_userName"));
  param.setValorDependiente(request.getParameter("valorDependiente"));
  param.setCompania(request.getParameter("compania"));
 // param.setCompania((String) session.getAttribute("_companyId"));
  param.setUsuarioCreacion((String) session.getAttribute("_userName"));
  param.setAcreedorId(request.getParameter("acreedorId"));
  param.setGrupoId(request.getParameter("grupoId"));
  param.setDescuentoMensual(request.getParameter("descuentoMensual"));
  param.setFrecuenciaDesc(request.getParameter("frecuenciaDesc"));
  
  param.setReservaVac(request.getParameter("reservaVac"));
  param.setReservaDec(request.getParameter("reservaDec"));
  param.setReservaIndem(request.getParameter("reservaIndem"));
  param.setReservaRiesgo(request.getParameter("reservaRiesgo"));
  
  param.setOthers1(request.getParameter("other1"));
  param.setOthers2(request.getParameter("other2"));
  param.setOthers3(request.getParameter("other3"));
  param.setOthers4(request.getParameter("other4"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		ParMgr.add(param);
	}
	else 
	{
		ParMgr.update(param);
	}
	ConMgr.clearAppCtx(null);
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ParMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ParMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/parametros.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/parametros.jsp")%>';
<%
	}
	else
	{
%>
window.opener.location = '<%=request.getContextPath()%>/rhplanilla/parametros.jsp';
<%
	}
%>
window.close();
<%
} else throw new Exception(ParMgr.getErrMsg());
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